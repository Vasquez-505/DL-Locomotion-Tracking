# SLEAP-NN Network Architectures — Drosophila Leg Tracking

**Project:** MSc Mechanical Engineering — Design of Mechatronic Systems, IST Lisboa  
**Student:** Pedro P. C. A. Vasques  
**Framework:** sleap-nn v0.1.3 · Single-Instance Pipeline · Set B (hot colourmap, 160×480 RGB)

---

## Table of Contents
1. [Shared Input Pipeline](#1-shared-input-pipeline)
2. [Shared Output Head — Confidence Maps](#2-shared-output-head--confidence-maps)
3. [Shared Training Setup](#3-shared-training-setup)
4. [Model 1 — U-Net 64](#4-model-1--u-net-64)
5. [Model 2 — ConvNeXt-Tiny](#5-model-2--convnext-tiny)
6. [Model 3 — Swin Transformer Tiny](#6-model-3--swin-transformer-tiny)
7. [Architecture Comparison](#7-architecture-comparison)

---

## 1. Shared Input Pipeline

All three models receive exactly the same input. The pipeline is:

```
Raw .avi frame (160 × 480 px, 3-channel hot colourmap)
        │
        ▼
[1] Ensure RGB          ensure_rgb: true — guarantees 3-channel input even
                        if a frame is accidentally greyscale
        │
        ▼
[2] Size cap            max_height: 138, max_width: 468, scale: 1.0
                        SLEAP rescales the image proportionally so it fits
                        within 138×468 px. For 160×480 px frames the scale
                        factor is min(138/160, 468/480) = 0.8625, giving a
                        resized image of 138 × 414 px. It is then padded to
                        138 × 468 px by the size matcher and finally padded
                        to 160 × 480 px so both dimensions are divisible by
                        max_stride = 32.
        │
        ▼
[3] Geometric augmentation  (TRAIN only — val/test see no augmentation)
        │   rotation:   uniform in [-15°, +15°], applied every sample
        │   scale:      uniform in [0.9, 1.1], applied every sample
        │   all wrapped in an affine transform (affine_p: 1.0)
        │   NO intensity/noise/brightness augmentation (all p: 0.0)
        │   Reason: FTIR imaging — brightness changes can create
        │           artificial foot-contact signals on dark background
        │
        ▼
[4] Batch assembly      batch_size: 6 for both TRAIN and VAL loaders
                        num_workers: 2, shuffle: true for TRAIN
        │
        ▼
[5] Normalise           Pixel values divided by 255 → range [0.0, 1.0],
                        applied to the batch before model forward.
                        No mean/std normalisation (unlike ImageNet-style).
```

**Why geometric-only augmentation?**  
In FTIR imaging the fly's foot contact appears as a bright 1–3 px spot on a near-black background. Brightness augmentation could shift the pixel intensities of the background into the range of real contact signals, teaching the model to predict contacts where there are none. Geometric augmentation (rotation, scale) increases pose variability without corrupting the photometric signal.

---

## 2. Shared Output Head — Confidence Maps

All three models share an identical output head, regardless of backbone.

```
Backbone feature map  (H/4 × W/4 × C_backbone)
        │
        ▼
1×1 Convolution       C_backbone → 9 channels (one per keypoint)
        │
        ▼
Confidence maps       shape: H/4 × W/4 × 9
                      each channel predicts the confidence for one keypoint.
                      During training, the target for each visible keypoint is
                      a 2D Gaussian blob with σ = 2.5 grid units in the
                      downsampled space at output_stride = 4.
```

**Output stride = 4** means the spatial resolution of the output is 1/4 of the padded network input. For the 160×480 tensor this gives a 40×120 output grid. Each cell covers 4×4 px in the preprocessed image space; SLEAP stores the effective scale factor and maps coordinates back to the original video frame after peak finding.

**Confidence map target:** For a keypoint at position (x, y) in the preprocessed image frame, the ground-truth confidence map for that keypoint is equivalently:

```
GT(i, j) = exp( -[(i - y/4)² + (j - x/4)²] / (2 σ²) )
```

If the keypoint is `visible = 0` (leg not in ground contact), the entire channel is **all zeros** — the network is trained to suppress any activation for that leg in that frame. This is a key design choice reflecting the FTIR physics.

**Loss function:** PyTorch `nn.MSELoss()` between predicted and ground-truth confidence maps. With the default mean reduction, the squared error is averaged over batch, keypoint channels, height, and width. Online hard keypoint mining is disabled in these runs (`online_mining: false`).

**Coordinate extraction at inference:**  
SLEAP-NN uses global peak finding on each confidence map channel. In the default no-refinement case this is equivalent to taking the grid-aligned maximum above the peak threshold, multiplying by `output_stride` (4), then undoing the preprocessing scale via `eff_scale` to recover coordinates in the original video frame. If integral refinement is enabled, a small local refinement offset is added before rescaling.

---

## 3. Shared Training Setup

| Parameter | Value | Source |
|---|---|---|
| Optimiser | Adam with AMSGrad | `optimizer_name: Adam`, `amsgrad: true` |
| Learning rate (initial) | 1 × 10⁻⁴ | `lr: 0.0001` |
| LR scheduler | ReduceLROnPlateau | triggered when val loss plateaus |
| Scheduler factor | × 0.5 | halves LR on plateau |
| Scheduler patience | 20 epochs | waits 20 epochs before halving |
| Scheduler cooldown | 3 epochs | waits 3 epochs after a reduction |
| Minimum LR | 1 × 10⁻⁶ | `min_lr: 1e-06` |
| Early stopping patience | 20 epochs | monitors val loss |
| Max epochs | 200 | `max_epochs: 200` |
| Min steps/epoch | 200 | each epoch runs at least 200 gradient updates |
| Batch size | 6 (train + val) | `batch_size: 6` |
| Platform | Google Colab T4 GPU | `trainer_accelerator: gpu` |
| Random seed | 42 | `seed: 42` |
| TRAIN frames | 755 | 6 videos, Set B |
| VAL frames | 120 | 1 video (Fly3.1), Set B |

**AMSGrad** is a variant of Adam that uses the maximum of past squared gradients rather than the exponential moving average, giving more stable convergence on non-convex problems.

**ReduceLROnPlateau** is the standard schedule for keypoint detection: the LR is kept constant until the network stops improving, then halved, allowing the network to "settle" at a finer scale without oscillating.

---

## 4. Model 1 — U-Net 64

**Run name:** `drosophila_unet64_setB_260407_092817`  
**Total parameters:** 11,740,217 (~11.7M)  
**Pretrained:** No — trained from random initialisation  
**Reference:** Ronneberger, Fischer & Brox, 2015

### 4.1 Architecture Overview

U-Net is an **encoder-decoder** with **skip connections**. The encoder progressively downsamples the image, extracting increasingly abstract features at decreasing spatial resolution. The decoder progressively upsamples back towards the original resolution, but at each step it receives not just the upsampled features from the previous decoder stage but also the corresponding feature map from the encoder (the skip connection). This lets the decoder combine high-level semantic information (from the deep bottleneck) with local spatial detail (from the shallow encoder).

```
Input image
    │
    ├──────────────── ENCODER (compresses spatial, expands channels) ──────────────────┐
    │                                                                                   │
    ▼ Block 0                                                                          │
    ▼ Block 1  ─── skip 1 ─────────────────────────────────────────────────────────┐  │
    ▼ Block 2  ─── skip 2 ──────────────────────────────────────────────────────┐  │  │
    ▼ Block 3  ─── skip 3 ───────────────────────────────────────────────────┐  │  │  │
    ▼ Block 4  ─── skip 4 ────────────────────────────────────────────────┐  │  │  │  │
    ▼ Middle block (bottleneck)                                            │  │  │  │  │
    │                                                                      │  │  │  │  │
    ├──────────────── DECODER (expands spatial, compresses channels) ──────┘──┘──┘──┘  │
    │   UpBlock D4: upsample + skip4 → conv                                            │
    │   UpBlock D3: upsample + skip3 → conv                                            │
    │   UpBlock D2: upsample + skip2 → conv  ← output_stride=4 stops here             │
    │                                                                                   │
    ▼ Confmaps head (1×1 conv → 9 channels)                                           │
                                                                                        │
    [Block 0 and Block 1 are not used as skips because output_stride=4]               ─┘
```

### 4.2 Encoder — Step by Step

Each encoder block consists of **2 × (Conv 3×3 → ReLU)** (no BatchNorm — `batch_norm=False` in sleap-nn v0.1.3), i.e. `convs_per_block: 2`. After each block (except the first), a MaxPool 2×2 halves the spatial dimensions.

The number of filters at each block follows: `filters × filters_rate^block_index`, starting from `filters = 64` with `filters_rate = 1.5`:

| Block | Spatial size (H × W) | In ch | Out ch | Operation |
|---|---|---|---|---|
| Input | 160 × 480 | 3 | — | Resized + padded network tensor |
| **Block 0** | 160 × 480 | 3 | **64** | 2 × (Conv 3×3, pad=same → ReLU) |
| MaxPool | 80 × 240 | 64 | 64 | MaxPool 2×2, stride 2 |
| **Block 1** | 80 × 240 | 64 | **96** | 2 × (Conv 3×3, pad=same → ReLU) |
| MaxPool | 40 × 120 | 96 | 96 | MaxPool 2×2, stride 2 |
| **Block 2** | 40 × 120 | 96 | **144** | 2 × (Conv 3×3, pad=same → ReLU) |
| MaxPool | 20 × 60 | 144 | 144 | MaxPool 2×2, stride 2 |
| **Block 3** | 20 × 60 | 144 | **216** | 2 × (Conv 3×3, pad=same → ReLU) |
| MaxPool | 10 × 30 | 216 | 216 | MaxPool 2×2, stride 2 |
| **Block 4** | 10 × 30 | 216 | **324** | 2 × (Conv 3×3, pad=same → ReLU) |
| MaxPool | 5 × 15 | 324 | 324 | MaxPool 2×2, stride 2 |
| **Middle block** | 5 × 15 | 324 | **486** | 2 × (Conv 3×3 → ReLU) — bottleneck |

**Notes on the encoder:**
- `max_stride: 32` means the encoder downsamples by a total factor of 32 (5 MaxPool steps: 2⁵ = 32).
- `middle_block: true` adds an extra block at the deepest level (stride 32) without further downsampling — this is the bottleneck that integrates the most global context.
- The channel counts are not rounded: 64 × 1.5 = 96; 96 × 1.5 = 144; 144 × 1.5 = 216; 216 × 1.5 = 324; 324 × 1.5 = 486.
- Padding = "same" ensures spatial dimensions are preserved within each block (only MaxPool changes the resolution).

### 4.3 Decoder — Step by Step

The decoder recovers spatial resolution only up to `output_stride = 4`. Since the encoder reached stride 32, the decoder needs 3 upsampling steps (32 → 16 → 8 → 4). Blocks 0 and 1 skip connections are **not used** — the decoder stops at stride 4.

Each decoder step:
1. **Bilinear upsampling ×2** (`up_interpolate: true`) — doubles H and W
2. **Skip connection concatenation** — the feature map from the corresponding encoder block at the same spatial resolution is concatenated along the channel dimension
3. **2 × (Conv 3×3 → ReLU)** — reduces the concatenated channels and refines features (no BatchNorm)

| Decoder block | Spatial size | Input ch (up + skip) | Out ch | Description |
|---|---|---|---|---|
| **D4** (32→16) | 5→10 × 15→30 | 486 + 324 = **810** | **324** | Bilinear ×2 + concat Block 4 skip + 2 convs |
| **D3** (16→8) | 10→20 × 30→60 | 324 + 216 = **540** | **216** | Bilinear ×2 + concat Block 3 skip + 2 convs |
| **D2** (8→4) | 20→40 × 60→120 | 216 + 144 = **360** | **144** | Bilinear ×2 + concat Block 2 skip + 2 convs |

**Why stop at stride 4 and not go all the way to stride 1?**  
The target confidence maps are generated at stride 4 (`output_stride: 4`). The configured `sigma = 2.5` is in output-grid units, equivalent to 10 px in the preprocessed image space. Going to stride 1 would quadruple the memory and computation while changing the target representation used for training.

### 4.4 Confmaps Head

```
Decoder output: 40 × 120 × 144
        │
1×1 Conv (no activation): 144 → 9
        │
Output: 40 × 120 × 9  (one confidence map per keypoint)
```

### 4.5 Why U-Net Works for This Task

- **Skip connections** preserve the precise spatial location of the bright foot-contact spots (1–3 px wide). Without them, the bottleneck representation would be too spatially coarse to localise sub-pixel contacts.
- **Convolutional inductive bias** (translation equivariance) is well-suited to detecting a consistent local feature (bright spot) regardless of where the fly is in the frame.
- **No ImageNet pretraining** — there is no applicable pretrained UNet available in SLEAP-NN for this domain. The model trains from random initialisation. Note: this is a limitation, not a design choice.
- **Limitation:** No multi-scale attention, no long-range context. If two legs are close together, purely local convolutions may confuse which leg is which.

---

## 5. Model 2 — ConvNeXt-Tiny

**Run name:** `drosophila_convnext_pt_setB_260408_085648`  
**Total parameters:** 87,545,769 (~87.5M)  
**Pretrained:** Yes — ImageNet-1K initialization via torchvision ConvNeXt-Tiny weights (`ConvNeXt_Tiny_Weights`).  
**Reference:** Liu et al., "A ConvNet for the 2020s", CVPR 2022  

### 5.1 Architecture Overview

ConvNeXt is a **pure convolutional** network that modernises the classic ResNet by borrowing design choices from Vision Transformers (ViT/SwinT) while remaining entirely convolutional. Key ideas: inverted bottleneck blocks (narrow ends, **wide middle** — C → 4C → C), depthwise separable convolutions with large kernels (7×7), Layer Normalisation instead of Batch Normalisation, fewer but wider stages.

In SLEAP-NN, ConvNeXt is used as the **encoder** (feature extractor), and a custom **UNet-style decoder** is attached on top to upsample back to output_stride = 4.

```
Input image
    │
    ▼ Stem (4×4 Conv stride 2 → LN)              ← 3→96 ch, stride 2
    │
    ├─── Stage 1 (3 ConvNeXt blocks, 96 ch, stride 2)
    │         │ Downsampler 1→2 (LN + 2×2 Conv, 96→192 ch) ── DS1 skip (192 ch @stride 4) ──┐
    ├─── Stage 2 (3 ConvNeXt blocks, 192 ch, stride 4)                                        │
    │         │ Downsampler 2→3 (LN + 2×2 Conv, 192→384 ch) ─ DS2 skip (384 ch @stride 8) ───┤
    ├─── Stage 3 (9 ConvNeXt blocks, 384 ch, stride 8)                                        │
    │         │ Downsampler 3→4 (LN + 2×2 Conv, 384→768 ch) ─ DS3 skip (768 ch @stride 16) ──┤
    ├─── Stage 4 (3 ConvNeXt blocks, 768 ch, stride 16)                                       │
    │         │ additional_pool (MaxPool → stride 32, 768 ch)                                  │
    │         ▼ Middle block 1 (Conv 3×3 → ReLU, 768→1536 ch)                                 │
    │         ▼ Middle block 2 (Conv 3×3 → ReLU, 1536→1536 ch)                                │
    │                                                                                           │
    ├─── DECODER (UNet-style) ──────────────────────────────────────────────────────────────────┘
    │         D3: 1536 upsample + DS3(768)  = 2304 → 768 ch  (stride 32→16)
    │         D2:  768 upsample + DS2(384)  = 1152 → 384 ch  (stride 16→8)
    │         D1:  384 upsample + DS1(192)  =  576 → 192 ch  (stride 8→4)
    │
    ▼ Confmaps head (1×1 conv, 192 → 9 channels)
```

### 5.2 Stem

The stem replaces the traditional 7×7 Conv stride-2 + MaxPool of ResNets with a single large-kernel patchwise convolution:

```
Input: 160 × 480 × 3
Conv2d: kernel=4×4, stride=2, out_ch=96
LayerNorm (LN): applied across the channel dimension
Output: 80 × 240 × 96  (stride 2)
```

**Why 4×4 stride 2 instead of 4×4 stride 4?**  
In the original ConvNeXt paper the stem is 4×4 stride 4 (non-overlapping patches). SLEAP-NN uses `stem_patch_stride: 2` — overlapping patches — which preserves more spatial information at the cost of slightly more computation. This is better suited to fine-grained localisation tasks like keypoint detection.

**LayerNorm vs BatchNorm:**  
LN normalises across channels for a single sample, making it independent of batch size and stable even with batch_size = 6. BN normalises across the batch, which can be noisy at small batch sizes.

### 5.3 ConvNeXt Block (Inverted Bottleneck)

Each ConvNeXt block processes features without changing spatial resolution or channel count:

```
Input: H × W × C
        │
Depthwise Conv2d  7×7, groups=C (one filter per channel, padding=3)
LayerNorm         normalises across channels
Pointwise Conv    C → 4C  (expand)
GELU activation
Pointwise Conv    4C → C  (project back)
        │
+ Residual (skip-add input)
        │
Output: H × W × C
```

**Key ideas in this block:**
- **Depthwise 7×7 conv:** each channel is filtered independently with a 7×7 kernel. This captures a large receptive field per channel without the parameter cost of full 7×7 conv. Functionally similar to the self-attention window in SwinT.
- **Inverted bottleneck (C → 4C → C):** expanding first then projecting back concentrates computation in the higher-dimensional space where features are richer. This is the same pattern as in MLP blocks in Transformers.
- **GELU activation:** smoother than ReLU, consistently preferred in Transformer-derived architectures.
- **Layer Normalisation:** placed after the depthwise conv (post-conv LN), in contrast to pre-activation BN in ResNets.
- **No BatchNorm:** removed entirely in favour of LN.

### 5.4 Encoder Stages

ConvNeXt-Tiny has 4 stages with depths [3, 3, 9, 3] and channel widths [96, 192, 384, 768]. With `stem_patch_stride: 2`, Stage 1 runs at stride 2. SLEAP-NN adds `additional_pool` (MaxPool) after Stage 4 to reach `max_stride: 32`, followed by two middle conv blocks:

| Stage | ConvNeXt blocks | In ch | Out ch | Spatial size | Stride |
|---|---|---|---|---|---|
| Stem | — | 3 | **96** | H/2 × W/2 | 2 |
| **Stage 1** | 3 blocks | 96 | **96** | H/2 × W/2 | 2 |
| Downsampler 1→2 | — | 96 | **192** | H/2 → H/4 | 4 |
| **Stage 2** | 3 blocks | 192 | **192** | H/4 × W/4 | 4 |
| Downsampler 2→3 | — | 192 | **384** | H/4 → H/8 | 8 |
| **Stage 3** | 9 blocks | 384 | **384** | H/8 × W/8 | 8 |
| Downsampler 3→4 | — | 384 | **768** | H/8 → H/16 | 16 |
| **Stage 4** | 3 blocks | 768 | **768** | H/16 × W/16 | 16 |
| additional_pool *(SLEAP-NN)* | — | 768 | **768** | H/16 → H/32 | 32 |
| **Middle block 1** | — | 768 | **1536** | H/32 × W/32 | 32 |
| **Middle block 2** | — | 1536 | **1536** | H/32 × W/32 | 32 |

**`additional_pool` (SLEAP-NN):** After Stage 4 (stride 16), SLEAP-NN applies an additional MaxPool2d (stride 2) to produce a stride-32 feature map (768 ch). This compensates for the stride-2 stem and reaches `max_stride: 32`. It is a plain spatial downsampling — channels do not change.

**Middle blocks:** Two simple conv blocks (Conv 3×3 → ReLU, no BatchNorm) bridge the encoder and decoder at stride 32. With `filters_rate: 2.0`, channels expand 768 → 1536 (block 1) and remain at 1536 (block 2). These are the **actual decoder input**, not Stage 4 directly.

**Standard Downsamplers** between stages: LN + 2×2 Conv stride 2, doubling channels (96→192→384→768). With the stem at stride 2, Stage 1 runs at stride 2 and the downsampler outputs land at strides 4, 8, 16 — these downsampler tensors are the **skip connection sources** for the decoder (not the post-stage outputs).

**Stage 3 has 9 blocks** (vs 3 in stages 1, 2, 4) because this is where the deepest pre-bottleneck features accumulate (stride 8 = large receptive field). More blocks = more capacity to learn complex patterns at that scale.

**`filters_rate: 2.0`** reflects the channel doubling at each downsampler: 96 → 192 → 384 → 768.

**`kernel_size: 3` in config** refers to the *decoder and middle block* convolution kernels. The ConvNeXt-Tiny backbone blocks themselves use **7×7 depthwise convolutions** as per the original paper and are not exposed as a user-configurable `kernel_size`.

### 5.5 Decoder

The decoder is a UNet-style decoder. It starts from the **middle block output** (1536 ch at stride 32). Skip connections are taken from the **downsampler outputs** — the even-indexed encoder outputs in reverse (`enc_output[::2][::-1]`), which selects the three downsampler tensors at strides 16, 8, 4:

| Decoder block | Spatial size | Upsampled ch | Skip source | Skip ch | Total in | Out ch |
|---|---|---|---|---|---|---|
| **D3** (32→16) | H/32 → H/16 | 1536 | Downsampler 3→4 (stride 16) | 768 | **2304** | **768** |
| **D2** (16→8) | H/16 → H/8 | 768 | Downsampler 2→3 (stride 8) | 384 | **1152** | **384** |
| **D1** (8→4) | H/8 → H/4 | 384 | Downsampler 1→2 (stride 4) | 192 | **576** | **192** |

Each step: bilinear ×2 + concat skip + 2 × (Conv 3×3 → ReLU, no BatchNorm).

Stage 1 (stride 2, 96 ch) and the stem output are not used as skips — the decoder stops at stride 4 (output_stride=4). The shallowest skip is the Downsampler 1→2 output (192 ch, stride 4).

### 5.6 Architectural Interpretation

Architecturally, ConvNeXt is useful here because:
- ImageNet-1K pretraining provides a strong visual feature prior before fine-tuning on the smaller FTIR dataset.
- The hierarchical backbone provides much larger effective context than the plain UNet while still preserving convolutional locality.
- 7×7 depthwise convolutions give each block a broad local receptive field with relatively efficient parameter use.
- The UNet-style decoder restores stride-4 spatial detail using skip connections from the learned downsampler outputs.

---

## 6. Model 3 — Swin Transformer Tiny

**Run name:** `drosophila_swint_pt_setB_260420_145559`  
**Total parameters:** ~87.25M (computed from the sleap-nn v0.1.3 SwinT-Tiny wrapper plus single-instance confmaps head; not stored in this model's saved config)  
**Pretrained:** Yes — ImageNet-1K initialization via torchvision Swin-Tiny weights (`Swin_T_Weights`).  
**Reference:** Liu et al., "Swin Transformer", ICCV 2021  

### 6.1 Architecture Overview

Swin Transformer is a **hierarchical Vision Transformer** that replaces standard global self-attention (ViT) with **local window-based self-attention**. The key innovation is the **shifted window** mechanism: attention is computed within small non-overlapping local windows (7×7 tokens), and windows are shifted between consecutive Transformer blocks to allow cross-window communication. This gives SwinT a hierarchical structure similar to CNNs (4 stages with progressively smaller spatial resolution and larger channel count) while retaining the attention mechanism.

In SLEAP-NN, SwinT is used as the **encoder** with the same UNet-style decoder as ConvNeXt.

```
Input image
    │
    ▼ Patch Embedding (4×4 Conv stride 2 → LN → 96 ch)
    │
    ├─── Stage 1: 2 SwinT blocks (96 ch, stride 2 — no skip used)
    │         │ Patch Merging 1: 96→192, stride 4 ─── PM1 skip (192 ch @stride 4) ────┐
    ├─── Stage 2: 2 SwinT blocks (192 ch, stride 4)                                     │
    │         │ Patch Merging 2: 192→384, stride 8 ─── PM2 skip (384 ch @stride 8) ────┤
    ├─── Stage 3: 6 SwinT blocks (384 ch, stride 8)                                     │
    │         │ Patch Merging 3: 384→768, stride 16 ── PM3 skip (768 ch @stride 16) ───┤
    ├─── Stage 4: 2 SwinT blocks (768 ch, stride 16)                                    │
    │         │ additional_pool (MaxPool → stride 32, 768 ch)                           │
    │         ▼ Middle block 1 (Conv 3×3 → ReLU, 768→1536 ch)                          │
    │         ▼ Middle block 2 (Conv 3×3 → ReLU, 1536→1536 ch)                         │
    │                                                                                    │
    ├─── DECODER (UNet-style) ───────────────────────────────────────────────────────────┘
    │         D3: 1536 upsample + PM3(768)  = 2304 → 768 ch  (stride 32→16)
    │         D2:  768 upsample + PM2(384)  = 1152 → 384 ch  (stride 16→8)
    │         D1:  384 upsample + PM1(192)  =  576 → 192 ch  (stride 8→4)
    │
    ▼ Confmaps head (1×1 conv, 192 → 9 channels)
```

### 6.2 Patch Embedding (Stem)

```
Input: 160 × 480 × 3
Conv2d: kernel=4×4 (patch_size), stride=2 (stem_patch_stride), out_ch=96
LayerNorm
Output: 80 × 240 × 96  (stride 2)
```

Same approach as ConvNeXt stem — 4×4 overlapping patch embedding (stride 2 instead of 4 for better spatial resolution). Projects each 4×4 patch into a 96-dimensional token.

After the stem, the spatial grid is a sequence of **tokens** (not pixels). Each token is produced by a 4×4 convolution (`patch_size: 4`) applied at stride 2 — adjacent token centres are 2 pixels apart, so patches overlap by 2 pixels. Each token carries a 96-dimensional feature vector.

### 6.3 Swin Transformer Block

This is the core difference from U-Net and ConvNeXt. Instead of a convolutional filter, each Swin block uses **self-attention within a local window**. Consecutive blocks alternate non-shifted and shifted windows:

```
Input: H/s × W/s × C  (sequence of tokens at stride s)
        │
Block k (even index)
        │
Partition into non-overlapping windows of size 7×7 tokens
        │
W-MSA (Window Multi-head Self-Attention)
│   Within each 7×7 window: compute Q, K, V projections
│   Attention: softmax(QKᵀ / √d_k + B) V  where B = relative position bias
│   Multiple heads (typically 3, 6, 12, 24 for stages 1–4 in SwinT)
        │
LayerNorm + MLP block (2-layer GELU MLP, expand ratio=4, same as ConvNeXt)
        │
Block k+1 (odd index)
        │
Shift windows by (3, 3), then partition into 7×7 windows
        │
SW-MSA (Shifted-Window Multi-head Self-Attention)
│   Same as W-MSA but on shifted windows → enables cross-window attention
│   Uses cyclic shift + masking to handle boundary effects efficiently
        │
LayerNorm + MLP block
        │
Output: H/s × W/s × C  (same shape as input, attention refined tokens)
```

**W-MSA and SW-MSA alternate across consecutive blocks** — in each stage, even-indexed blocks use non-shifted windows and odd-indexed blocks use shifted windows. For SwinT-Tiny the stage depths are even ([2, 2, 6, 2]), so the blocks form W-MSA/SW-MSA pairs.

**Relative position bias B:** Unlike absolute position encoding, SwinT adds a learned bias based on the *relative* position of query and key tokens within the window. This makes the model sensitive to spatial layout without being tied to absolute coordinates.

**Window size = 7 (tokens):** configured as `window_size: 7`. At stride 2 (after patch embedding), a 7-token window covers 7 × 2 = 14 px of the original image in each direction. This is the local context each token can "see" via attention.

### 6.4 Encoder Stages

| Stage | SwinT blocks | In ch | Out ch | Spatial tokens | Stride |
|---|---|---|---|---|---|
| Patch Embed | — | 3 | **96** | H/2 × W/2 | 2 |
| **Stage 1** | 2 (W-MSA + SW-MSA) | 96 | **96** | H/2 × W/2 | 2 |
| Patch Merging | — | 96 | **192** | H/2 → H/4 | 4 |
| **Stage 2** | 2 blocks | 192 | **192** | H/4 × W/4 | 4 |
| Patch Merging | — | 192 | **384** | H/4 → H/8 | 8 |
| **Stage 3** | 6 blocks | 384 | **384** | H/8 × W/8 | 8 |
| Patch Merging | — | 384 | **768** | H/8 → H/16 | 16 |
| **Stage 4** | 2 blocks | 768 | **768** | H/16 × W/16 | 16 |
| additional_pool *(SLEAP-NN)* | — | 768 | **768** | H/16 → H/32 | 32 |
| **Middle block 1** | — | 768 | **1536** | H/32 × W/32 | 32 |
| **Middle block 2** | — | 1536 | **1536** | H/32 × W/32 | 32 |

**Patch Merging** (standard, between stages 1–4): concatenates 2×2 neighbouring tokens → ×4 channels, then linear projection back to ×2. Halves spatial dimensions, doubles channel count.

**`additional_pool` (SLEAP-NN):** After Stage 4 (stride 16), SLEAP-NN applies `MaxPool2dWithSamePadding` (stride 2) to reach `max_stride: 32`. This is **not** a Patch Merging layer — it is plain spatial downsampling with no channel change (768→768).

**Middle blocks:** Two simple conv blocks (Conv 3×3 → ReLU, no BatchNorm) expand 768 → 1536 → 1536 at stride 32 and serve as the actual decoder input.

**Skip sources (SLEAP-NN):** The decoder uses `enc_output[::2][::-1]` — every-other encoder output in reverse. The even-indexed outputs are the **Patch Merging outputs** (before each stage, not after). For output_stride=4, the three used skips are PM3 (768 ch, stride 16), PM2 (384 ch, stride 8), PM1 (192 ch, stride 4). Post-stage attention outputs are NOT skip sources.

**Stage 3 has 6 blocks** (vs 2 in stages 1, 2, 4): the same reason as ConvNeXt stage 3 — the mid-level features at stride 8 carry the most useful information for distinguishing contact vs. non-contact patterns, so more computation is invested there.

### 6.5 Decoder

Identical structure to the ConvNeXt decoder. It starts from the **middle block output** (1536 ch at stride 32). Skip connections are the **Patch Merging outputs** (`enc_output[::2][::-1]` — every-other encoder output in reverse):

| Decoder block | Spatial size | Upsampled ch | Skip source | Skip ch | Total in | Out ch |
|---|---|---|---|---|---|---|
| **D3** (32→16) | H/32 → H/16 | 1536 | Patch Merging 3 (stride 16) | 768 | **2304** | **768** |
| **D2** (16→8) | H/16 → H/8 | 768 | Patch Merging 2 (stride 8) | 384 | **1152** | **384** |
| **D1** (8→4) | H/8 → H/4 | 384 | Patch Merging 1 (stride 4) | 192 | **576** | **192** |

Each step: bilinear ×2 + concat skip + 2 × (Conv 3×3 → ReLU, no BatchNorm).

Note: Stage 1 (stride 2, 96 ch) and all post-stage attention outputs are **not used** as skips. The skips are the Patch Merging tensors (the downsampled token grids *before* the next stage refines them). The shallowest skip used is PM1 (192 ch at stride 4).

### 6.6 Architectural Interpretation

SwinT brings a different inductive bias from U-Net and ConvNeXt:
1. **Local self-attention:** each token aggregates information from other tokens in the same 7×7 window rather than applying a fixed convolutional kernel.
2. **Shifted windows:** alternating W-MSA and SW-MSA blocks allow information to move across neighbouring windows without the cost of global attention.
3. **Hierarchical token pyramid:** Patch Merging gives SwinT the same coarse-to-fine structure as a CNN backbone: spatial resolution decreases while channel width increases.
4. **ImageNet-1K pretraining:** the backbone starts from learned visual representations before being adapted to FTIR confidence-map prediction.
5. **UNet-style decoder:** SLEAP-NN adds the same stride-32 → stride-4 decoder pattern used for ConvNeXt, so SwinT still recovers spatial detail through skip connections.

---

## 7. Architecture Comparison

| Property | U-Net 64 | ConvNeXt-Tiny | SwinT-Tiny |
|---|---|---|---|
| **Type** | Conv encoder-decoder | Hierarchical ConvNet + decoder | Hierarchical ViT + decoder |
| **Parameters** | 11.7M | 87.5M | ~87.25M |
| **Pretrained** | No | ImageNet-1K | ImageNet-1K |
| **Attention** | None | None | Local window self-attention |
| **Kernel / window** | 3×3 conv | 7×7 depthwise conv | 7×7 token window |
| **Normalisation** | None (Conv → ReLU, no BN) | LayerNorm (backbone); no BN in decoder | LayerNorm (backbone); no BN in decoder |
| **Encoder depths** | 5 encoder blocks + middle block | [3, 3, 9, 3] ConvNeXt blocks + 2 middle blocks | [2, 2, 6, 2] Swin blocks + 2 middle blocks |
| **Channel schedule** | 64 → 96 → 144 → 216 → 324 → 486 | 96 → 192 → 384 → 768 → 1536 | 96 → 192 → 384 → 768 → 1536 |
| **Max stride** | 32 via 5 MaxPool operations | 32 via stride-2 stem, 3 downsamplers, additional_pool | 32 via stride-2 patch embed, 3 Patch Merging layers, additional_pool |
| **Skip connections** | Max stride = 32, skip from 3 levels (Blocks 2, 3, 4) | Downsampler outputs (192/384/768 ch at strides 4/8/16) | Patch Merging outputs (192/384/768 ch at strides 4/8/16) |
| **Decoder output channels** | 144 | 192 | 192 |
| **Output head** | 1×1 conv → 9 confidence maps | 1×1 conv → 9 confidence maps | 1×1 conv → 9 confidence maps |
| **Temporal context** | None | None | None |

### Architectural Takeaways

1. **U-Net 64** is the most direct dense-prediction architecture: local 3×3 convolutions, explicit encoder-decoder symmetry, and skip connections from matching spatial scales.
2. **ConvNeXt-Tiny** keeps the convolutional inductive bias but modernises the encoder with 7×7 depthwise convolutions, LayerNorm, inverted bottlenecks, and ImageNet-1K pretraining.
3. **SwinT-Tiny** replaces fixed convolutional filtering with shifted-window self-attention while preserving a CNN-like hierarchy through Patch Merging.
4. **All three models** are frame-wise SLEAP-NN single-instance confidence-map predictors. They do not use temporal context.

### Temporal Information

None of the three models use temporal information. Each predicts keypoints from a single frame. This is the primary difference from the **ADPT model** (which processes a T=9 frame temporal window through a Transformer Encoder) — the ADPT can leverage frame-to-frame continuity to suppress brief false positives, but requires the full temporal context and is harder to fine-tune.

---

*Sources: training_config.yaml from each model folder · Ronneberger et al. 2015 (U-Net) · Liu et al. 2022 (ConvNeXt) · Liu et al. 2021 (SwinT) · Pereira et al. 2022 (SLEAP-NN)*
