"""
model.py — ADPT-style CNN-Transformer for Drosophila FTIR pose estimation.

Architecture summary (see PROJECT_CONTEXT.md for full details):

    Input: (B, T, 3, H, W)  — T=9 frames, shared-weight CNN backbone
        |
    ResNet-50 stem + layer1  ->  (B*T, 256, H/4, W/4)
        |
        +-- SC1  ->  Conv3x3  ->  (B*T, 64,  H/4, W/4)
        |
    MaxPool  ->  (B*T, 256, H/8, W/8)
        |
        +-- SC2  ->  Conv3x3  ->  (B*T, 128, H/8, W/8)
        |
    Conv3x3 s=2  ->  (B*T, 256, H/16, W/16)
        |
    PatchEncoder + sinusoidal PE  ->  (B, T*n_tok, 256)
        |
    Transformer Encoder x6 (flash attention)  ->  (B, T*n_tok, 256)
        |
    Select anchor frame tokens + SC1/SC2  ->  (B, 256, H/16, W/16)
        |
    Decoder Stage 1: bilinear x2 + concat SC2  ->  (B, 256, H/8, W/8)
    Decoder Stage 2: bilinear x2 + concat SC1  ->  (B, 256, H/4, W/4)
        |
    3 output heads  ->  heatmaps  (B, 9, H/4, W/4)
                        refinements (B, 18, H/4, W/4)
                        lrss        (B, 1, H/4, W/4)

All targets are for the anchor frame only. The other T-1 frames provide
temporal context through the Transformer's cross-frame self-attention.
"""

from __future__ import annotations

import math
import os
os.environ.setdefault("KMP_DUPLICATE_LIB_OK", "TRUE")

import torch
import torch.nn as nn
import torch.nn.functional as F
from torchvision.models import resnet50, ResNet50_Weights

N_KP = 9


# ──────────────────────────────────────────────────────────────────────────────
# Positional encoding
# ──────────────────────────────────────────────────────────────────────────────

def sinusoidal_pe(seq_len: int, d_model: int, device: torch.device) -> torch.Tensor:
    """
    Standard 1D sinusoidal positional encoding (Vaswani et al. 2017).

    The token sequence is ordered as [frame0_tok0, ..., frame0_tokN,
    frame1_tok0, ...], so adjacent tokens within a frame are close in
    position and frame boundaries are implicit in the encoding.

    Returns
    -------
    torch.Tensor  shape (1, seq_len, d_model)  — ready to add to token tensor
    """
    pe       = torch.zeros(seq_len, d_model, device=device)
    position = torch.arange(seq_len, device=device).unsqueeze(1).float()
    div_term = torch.exp(
        torch.arange(0, d_model, 2, device=device).float()
        * (-math.log(10000.0) / d_model)
    )
    pe[:, 0::2] = torch.sin(position * div_term)
    pe[:, 1::2] = torch.cos(position * div_term)
    return pe.unsqueeze(0)   # (1, seq_len, d_model)


# ──────────────────────────────────────────────────────────────────────────────
# Transformer block
# ──────────────────────────────────────────────────────────────────────────────

class TransformerBlock(nn.Module):
    """
    Single Transformer encoder block (BERT-style):
        LayerNorm -> MHSA (flash attention) -> residual
        LayerNorm -> FFN (GELU)             -> residual

    Uses torch.nn.functional.scaled_dot_product_attention which dispatches
    to Flash Attention when available (PyTorch >= 2.0, CUDA).
    """

    def __init__(
        self,
        d_model:  int   = 256,
        n_heads:  int   = 8,
        ffn_dim:  int   = 1024,
        dropout:  float = 0.1,
    ) -> None:
        super().__init__()
        assert d_model % n_heads == 0, "d_model must be divisible by n_heads"
        self.n_heads = n_heads
        self.d_head  = d_model // n_heads
        self.dropout = dropout

        self.norm1    = nn.LayerNorm(d_model)
        self.norm2    = nn.LayerNorm(d_model)
        self.qkv      = nn.Linear(d_model, 3 * d_model, bias=False)
        self.out_proj = nn.Linear(d_model, d_model, bias=False)
        self.ffn = nn.Sequential(
            nn.Linear(d_model, ffn_dim),
            nn.GELU(),
            nn.Dropout(dropout),
            nn.Linear(ffn_dim, d_model),
            nn.Dropout(dropout),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """x: (B, L, d_model)"""
        B, L, D = x.shape

        # Multi-head self-attention
        normed = self.norm1(x)
        qkv = self.qkv(normed)                              # (B, L, 3*D)
        qkv = qkv.reshape(B, L, 3, self.n_heads, self.d_head)
        qkv = qkv.permute(2, 0, 3, 1, 4)                   # (3, B, heads, L, d_head)
        q, k, v = qkv.unbind(0)                             # each (B, heads, L, d_head)

        attn_out = F.scaled_dot_product_attention(
            q, k, v,
            dropout_p=self.dropout if self.training else 0.0,
        )                                                    # (B, heads, L, d_head)
        attn_out = attn_out.transpose(1, 2).reshape(B, L, D)
        attn_out = self.out_proj(attn_out)
        x = x + attn_out

        # Feed-forward
        x = x + self.ffn(self.norm2(x))
        return x


# ──────────────────────────────────────────────────────────────────────────────
# Building blocks
# ──────────────────────────────────────────────────────────────────────────────

def _conv_bn_relu(in_ch: int, out_ch: int, stride: int = 1) -> nn.Sequential:
    """Conv3x3 + BN + ReLU."""
    return nn.Sequential(
        nn.Conv2d(in_ch, out_ch, 3, stride=stride, padding=1, bias=False),
        nn.BatchNorm2d(out_ch),
        nn.ReLU(inplace=True),
    )


def _upsample_block(in_ch: int, out_ch: int) -> nn.Sequential:
    """Bilinear upsample x2 + Conv3x3 + BN + ReLU (no checkerboard artefacts)."""
    return nn.Sequential(
        nn.Upsample(scale_factor=2, mode="bilinear", align_corners=False),
        nn.Conv2d(in_ch, out_ch, 3, padding=1, bias=False),
        nn.BatchNorm2d(out_ch),
        nn.ReLU(inplace=True),
    )


# ──────────────────────────────────────────────────────────────────────────────
# Main model
# ──────────────────────────────────────────────────────────────────────────────

class DrosophilaModel(nn.Module):
    """
    ADPT-style CNN-Transformer for Drosophila FTIR leg-contact pose estimation.

    Parameters
    ----------
    T           : temporal window length (must match dataset, default 9)
    in_channels : input channels per frame — 3 for RGB (Sets A/B), 1 for greyscale (Sets C/D)
    d_model     : Transformer embedding dimension (default 256)
    n_heads     : number of attention heads (default 8)
    n_layers    : number of Transformer blocks (default 6)
    ffn_dim     : FFN hidden dimension (default 1024)
    n_kp        : number of keypoints (default 9)
    dropout     : dropout rate in Transformer (default 0.1)

    Forward inputs
    --------------
    frames     : (B, T, in_channels, H, W)  float32 — normalised frames
    anchor_idx : (B,)                       int64   — anchor position in [0, T-1]

    Returns
    -------
    dict with keys:
        heatmaps    : (B, N_KP, H/4, W/4)   float32  [0, 1]
        refinements : (B, 2*N_KP, H/4, W/4) float32  sub-pixel offsets
        lrss        : (B, 1, H/4, W/4)       float32  [0, 1]
    """

    def __init__(
        self,
        T:           int   = 9,
        in_channels: int   = 3,
        d_model:     int   = 256,
        n_heads:     int   = 8,
        n_layers:    int   = 6,
        ffn_dim:     int   = 1024,
        n_kp:        int   = N_KP,
        dropout:     float = 0.1,
    ) -> None:
        super().__init__()
        self.T           = T
        self.in_channels = in_channels
        self.d_model     = d_model
        self.n_kp        = n_kp

        # ── ResNet-50 backbone (ImageNet pretrained) ───────────────────────────
        backbone = resnet50(weights=ResNet50_Weights.IMAGENET1K_V1)

        # Build conv1 to match in_channels, then transfer ImageNet weights.
        # For in_channels=3: copy weights directly (identical to original).
        # For in_channels=1: average the 3 input channels → shape (64, 1, 7, 7).
        #   Averaging preserves magnitude (vs. summing which would triple it)
        #   and retains all ImageNet structure (vs. random init).
        conv1 = nn.Conv2d(in_channels, 64, kernel_size=7, stride=2, padding=3, bias=False)
        if in_channels == 3:
            conv1.weight.data = backbone.conv1.weight.data.clone()
        else:  # in_channels == 1
            conv1.weight.data = backbone.conv1.weight.data.mean(dim=1, keepdim=True)

        # Stem: Conv1(7x7 s=2) + BN + ReLU + MaxPool(s=2) → H/4, 64ch
        self.stem = nn.Sequential(
            conv1,
            backbone.bn1,
            backbone.relu,
            backbone.maxpool,
        )
        # layer1: 3 bottleneck blocks, no spatial downsampling → H/4, 256ch
        self.layer1 = backbone.layer1

        # ── Skip connection projections ────────────────────────────────────────
        self.sc1_conv = _conv_bn_relu(256, 64)    # SC1: H/4, 256 → 64ch
        self.sc2_conv = _conv_bn_relu(256, 128)   # SC2: H/8, 256 → 128ch

        # ── Downsampling H/4 → H/8 → H/16 ────────────────────────────────────
        self.maxpool2  = nn.MaxPool2d(2)                            # H/4 → H/8
        self.down_conv = _conv_bn_relu(256, d_model, stride=2)      # H/8 → H/16

        # ── Transformer ───────────────────────────────────────────────────────
        self.transformer = nn.ModuleList([
            TransformerBlock(d_model, n_heads, ffn_dim, dropout)
            for _ in range(n_layers)
        ])
        self.transformer_norm = nn.LayerNorm(d_model)

        # ── Decoder ───────────────────────────────────────────────────────────
        # Stage 1: H/16 → H/8, then concat SC2 (128ch) → 384ch → 256ch
        self.up1    = _upsample_block(d_model, d_model)          # 256 → 256
        self.merge1 = _conv_bn_relu(d_model + 128, d_model)      # 384 → 256

        # Stage 2: H/8 → H/4, then concat SC1 (64ch) → 320ch → 256ch
        self.up2    = _upsample_block(d_model, d_model)          # 256 → 256
        self.merge2 = _conv_bn_relu(d_model + 64, d_model)       # 320 → 256

        # ── Output heads ──────────────────────────────────────────────────────
        self.head_heatmap    = nn.Conv2d(d_model, n_kp,      3, padding=1)
        self.head_refinement = nn.Conv2d(d_model, 2 * n_kp,  3, padding=1)
        self.head_lrss       = nn.Conv2d(d_model, 1,         3, padding=1)

    # ── Helpers ───────────────────────────────────────────────────────────────

    def _select_anchor_feat(
        self,
        feat:       torch.Tensor,   # (B*T, C, H, W)
        anchor_idx: torch.Tensor,   # (B,) int64
        T:          int,
    ) -> torch.Tensor:
        """Select each batch item's anchor frame from a (B*T, C, H, W) tensor.
        Returns (B, C, H, W)."""
        B = feat.shape[0] // T
        C, Hf, Wf = feat.shape[1], feat.shape[2], feat.shape[3]
        feat = feat.reshape(B, T, C, Hf, Wf)
        idx  = anchor_idx.view(B, 1, 1, 1, 1).expand(B, 1, C, Hf, Wf)
        return feat.gather(1, idx).squeeze(1)   # (B, C, Hf, Wf)

    # ── Forward ───────────────────────────────────────────────────────────────

    def forward(
        self,
        frames:     torch.Tensor,   # (B, T, 3, H, W)
        anchor_idx: torch.Tensor,   # (B,) int64
    ) -> dict[str, torch.Tensor]:

        B, T, C, H, W = frames.shape
        anchor_idx = anchor_idx.long()

        # ── CNN backbone: all T frames in one pass ─────────────────────────────
        x = frames.reshape(B * T, C, H, W)
        x = self.stem(x)      # (B*T, 64,  H/4,  W/4)
        x = self.layer1(x)    # (B*T, 256, H/4,  W/4)

        # Skip connections
        sc1 = self.sc1_conv(x)           # (B*T, 64,  H/4, W/4)

        x   = self.maxpool2(x)           # (B*T, 256, H/8, W/8)
        sc2 = self.sc2_conv(x)           # (B*T, 128, H/8, W/8)

        x   = self.down_conv(x)          # (B*T, 256, H/16, W/16)
        Hf, Wf = x.shape[2], x.shape[3] # feature map spatial dims (H/16, W/16)
        n_tok  = Hf * Wf                 # tokens per frame

        # ── PatchEncoder: flatten spatial dims, merge T frames ─────────────────
        tokens = x.flatten(2).transpose(1, 2)   # (B*T, n_tok, 256)
        tokens = tokens.reshape(B, T * n_tok, self.d_model)

        # Add sinusoidal positional encoding
        tokens = tokens + sinusoidal_pe(T * n_tok, self.d_model, tokens.device)

        # ── Transformer encoder (cross-frame attention) ────────────────────────
        for block in self.transformer:
            tokens = block(tokens)
        tokens = self.transformer_norm(tokens)   # (B, T*n_tok, 256)

        # ── Select anchor frame BEFORE decoder ────────────────────────────────
        # tokens: (B, T*n_tok, 256) → (B, T, n_tok, 256) → (B, n_tok, 256)
        tokens  = tokens.reshape(B, T, n_tok, self.d_model)
        idx_tok = anchor_idx.view(B, 1, 1, 1).expand(B, 1, n_tok, self.d_model)
        anchor_tokens = tokens.gather(1, idx_tok).squeeze(1)   # (B, n_tok, 256)

        # Reshape back to 2D feature map
        anchor_feat = anchor_tokens.transpose(1, 2).reshape(B, self.d_model, Hf, Wf)

        # Select SC1 and SC2 for anchor frame
        sc1_a = self._select_anchor_feat(sc1, anchor_idx, T)   # (B, 64,  H/4, W/4)
        sc2_a = self._select_anchor_feat(sc2, anchor_idx, T)   # (B, 128, H/8, W/8)

        # ── Decoder: anchor frame only ─────────────────────────────────────────
        # Stage 1: H/16 → H/8
        d = self.up1(anchor_feat)                           # (B, 256, H/8, W/8)
        d = self.merge1(torch.cat([d, sc2_a], dim=1))       # (B, 256, H/8, W/8)

        # Stage 2: H/8 → H/4
        d = self.up2(d)                                     # (B, 256, H/4, W/4)
        d = self.merge2(torch.cat([d, sc1_a], dim=1))       # (B, 256, H/4, W/4)

        # ── Output heads ──────────────────────────────────────────────────────
        heatmaps    = torch.sigmoid(self.head_heatmap(d))   # (B, 9,  H/4, W/4)
        refinements = self.head_refinement(d)               # (B, 18, H/4, W/4)
        lrss        = torch.sigmoid(self.head_lrss(d))      # (B, 1,  H/4, W/4)

        return {
            "heatmaps":    heatmaps,
            "refinements": refinements,
            "lrss":        lrss,
        }


# ──────────────────────────────────────────────────────────────────────────────
# Standalone verification
# ──────────────────────────────────────────────────────────────────────────────

def count_parameters(model: nn.Module) -> int:
    return sum(p.numel() for p in model.parameters() if p.requires_grad)


if __name__ == "__main__":
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device: {device}")

    B, T = 2, 9
    anchor_idx = torch.tensor([0, 4], device=device)

    for in_ch, H, W in [(3, 160, 480), (1, 160, 480)]:
        print(f"\n--- in_channels={in_ch}  input=({H},{W}) ---")
        model = DrosophilaModel(T=T, in_channels=in_ch).to(device)
        print(f"Parameters: {count_parameters(model):,}")

        frames = torch.randn(B, T, in_ch, H, W, device=device)

        model.eval()
        with torch.no_grad():
            out = model(frames, anchor_idx)

        Ho, Wo = H // 4, W // 4
        assert out["heatmaps"].shape    == (B, N_KP,     Ho, Wo), f"heatmaps shape wrong: {out['heatmaps'].shape}"
        assert out["refinements"].shape == (B, 2 * N_KP, Ho, Wo), f"refinements shape wrong"
        assert out["lrss"].shape        == (B, 1,         Ho, Wo), f"lrss shape wrong"
        assert out["heatmaps"].min() >= 0.0 and out["heatmaps"].max() <= 1.0, "heatmaps not in [0,1]"
        assert out["lrss"].min()     >= 0.0 and out["lrss"].max()     <= 1.0, "lrss not in [0,1]"

        print(f"heatmaps    : {tuple(out['heatmaps'].shape)}  range [{out['heatmaps'].min():.3f}, {out['heatmaps'].max():.3f}]")
        print(f"refinements : {tuple(out['refinements'].shape)}")
        print(f"lrss        : {tuple(out['lrss'].shape)}  range [{out['lrss'].min():.3f}, {out['lrss'].max():.3f}]")
        print(f"All shape and value checks passed.")

        if device.type == "cuda":
            print(f"GPU memory allocated: {torch.cuda.memory_allocated(device)/1e9:.2f} GB")
