"""
inference.py — ADPT model inference on a full unlabeled video.

Slides a T=9 temporal window across every frame of the video, runs the
DrosophilaModel, applies the calibrated threshold θ, and writes all
predictions to a SLEAP-compatible .slp file.

The output .slp always references the Set B (colormap) video so it opens
correctly in the SLEAP GUI regardless of which video set was used for
inference.

Usage
-----
    python inference.py \\
        --model   Models/VS_Code_Models/best_model.pt \\
        --video   Inference_Pipeline/Videos/PROCESSED_Colormap_Videos/CantonS_unamp_Fly1.1.avi \\
        --video_b Inference_Pipeline/Videos/PROCESSED_Colormap_Videos/CantonS_unamp_Fly1.1.avi \\
        --output  Inference_Pipeline/Predictions/CantonS_unamp_Fly1.1/CantonS_unamp_Fly1.1.predictions.slp \\
        --set     B
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
from pathlib import Path

import cv2
import h5py
import numpy as np

# ── torch / model are only needed for ADPT inference, not for utility fns ──
# Import lazily so this module can be imported in SLEAP-only environments.
try:
    import torch
    from model import DrosophilaModel, N_KP
    _TORCH_AVAILABLE = True
except ImportError:
    _TORCH_AVAILABLE = False
    N_KP = 9  # head, thorax, abdomen, forelegR/L, midlegR/L, hindlegR/L

# ── model.py lives in the same folder as inference.py ──────────────────────
ROOT = Path(__file__).parent          # Inference_Pipeline/
sys.path.insert(0, str(ROOT))

# Keypoint names — hardcoded to remove dataset.py dependency
KEYPOINT_NAMES = [
    "head", "thorax", "abdomen",
    "forelegR", "forelegL",
    "midlegR",  "midlegL",
    "hindlegR", "hindlegL",
]
T              = 9
OUTPUT_STRIDE  = 4
TEMPLATE_SLP   = ROOT / "Drosophila_TRAIN_set.slp"   # skeleton template for SLEAP GUI

# ── Normalisation constants (must match dataset.py) ────────────────────────
_MEAN_RGB  = np.array([0.485, 0.456, 0.406], dtype=np.float32)
_STD_RGB   = np.array([0.229, 0.224, 0.225], dtype=np.float32)
_MEAN_GREY = np.array([0.449],               dtype=np.float32)
_STD_GREY  = np.array([0.226],               dtype=np.float32)

_SET_CFG: dict[str, dict] = {
    "B": {"input_size": (160, 480), "in_channels": 3, "mean": _MEAN_RGB, "std": _STD_RGB},
    "C": {"input_size": (160, 480), "in_channels": 1, "mean": _MEAN_GREY, "std": _STD_GREY},
    "D": {"input_size": (160, 480), "in_channels": 1, "mean": _MEAN_GREY, "std": _STD_GREY},
}


# ── Model loading ───────────────────────────────────────────────────────────

def load_model(model_path: str, device: "torch.device"):
    if not _TORCH_AVAILABLE:
        raise RuntimeError("torch is not installed — ADPT inference requires PyTorch.")
    ckpt = torch.load(model_path, map_location=device, weights_only=False)
    in_channels = ckpt.get("in_channels", 3)
    theta       = float(ckpt.get("theta", 0.5))
    model       = DrosophilaModel(in_channels=in_channels).to(device)
    model.load_state_dict(ckpt["model"])
    model.eval()
    return model, in_channels, theta


# ── Video loading ───────────────────────────────────────────────────────────

def load_video(
    video_path: str,
    in_channels: int,
    input_size: tuple[int, int],
) -> tuple[list[np.ndarray], int, int]:
    """Load every frame → (frames, native_W, native_H).

    Frames are resized to input_size for model input.
    native_W / native_H are the original video dimensions, needed to scale
    predictions back to the coordinate space SLEAP expects.
    """
    H_in, W_in = input_size
    cap    = cv2.VideoCapture(video_path)
    native_W = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    native_H = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    frames: list[np.ndarray] = []
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        if in_channels == 3:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame = cv2.resize(frame, (W_in, H_in), interpolation=cv2.INTER_LINEAR)
        else:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            frame = cv2.resize(frame, (W_in, H_in), interpolation=cv2.INTER_LINEAR)
            frame = frame[:, :, np.newaxis]
        frames.append(frame)
    cap.release()
    return frames, native_W, native_H


def preprocess(frame: np.ndarray, mean: np.ndarray, std: np.ndarray) -> torch.Tensor:
    """Normalise and convert to (C, H, W) float32 tensor."""
    img = frame.astype(np.float32) / 255.0
    img = (img - mean) / std
    return torch.from_numpy(img.transpose(2, 0, 1))


# ── Sliding-window inference ────────────────────────────────────────────────

def _build_window(n_frames: int, target_idx: int) -> tuple[list[int], int]:
    """Asymmetric boundary window — same logic as DrosophilaDataset."""
    half      = T // 2
    win_start = max(0, target_idx - half)
    win_end   = win_start + T
    if win_end > n_frames:
        win_end   = n_frames
        win_start = max(0, win_end - T)
    anchor_idx = target_idx - win_start
    frame_idxs = list(range(win_start, win_end))
    return frame_idxs, anchor_idx


_no_grad = torch.no_grad() if _TORCH_AVAILABLE else (lambda f: f)

@_no_grad
def run_inference(
    model:          DrosophilaModel,
    frames_tensors: list[torch.Tensor],
    device:         torch.device,
    theta:          float,
) -> np.ndarray:
    """
    Slide window over all frames.

    Returns
    -------
    preds : np.ndarray  shape (n_frames, N_KP, 3)
        last dim = [x, y, visible]  in input-resolution pixels
    """
    n = len(frames_tensors)
    preds = np.zeros((n, N_KP, 3), dtype=np.float32)

    for target_idx in range(n):
        frame_idxs, anchor_idx = _build_window(n, target_idx)
        window = [frames_tensors[i] for i in frame_idxs]

        win_t    = torch.stack(window, dim=0).unsqueeze(0).to(device)   # (1, T, C, H, W)
        anch_t   = torch.tensor([anchor_idx], device=device)

        out      = model(win_t, anch_t)
        heatmaps = out["heatmaps"][0]       # (N_KP, Ho, Wo)
        refines  = out["refinements"][0]    # (2*N_KP, Ho, Wo)

        Ho, Wo = heatmaps.shape[1], heatmaps.shape[2]

        for k in range(N_KP):
            hm         = heatmaps[k]
            confidence = hm.max().item()

            if confidence > theta:
                peak      = hm.flatten().argmax().item()
                py, px    = divmod(peak, Wo)
                dx = refines[2 * k,     py, px].item()
                dy = refines[2 * k + 1, py, px].item()
                x  = (px + dx) * OUTPUT_STRIDE
                y  = (py + dy) * OUTPUT_STRIDE
                preds[target_idx, k] = [x, y, 1.0]
            # else: remains [0, 0, 0] (invisible / airborne)

        if (target_idx + 1) % 50 == 0 or target_idx + 1 == n:
            print(f"  Frame {target_idx + 1}/{n}", flush=True)

    return preds


# ── .slp writer ────────────────────────────────────────────────────────────

def write_slp(
    output_path:  str,
    predictions:  np.ndarray,
    video_b_path: str,
    template_slp: str = str(TEMPLATE_SLP),
) -> None:
    """
    Write predictions to a SLEAP-compatible .slp file.

    Uses the training .slp as a template to preserve the skeleton definition
    (node names, edges) required by the SLEAP GUI.  Replaces frames/instances/
    points datasets with the new predictions and relinks the video to Set B.

    Parameters
    ----------
    output_path   : destination .slp path
    predictions   : (n_frames, N_KP, 3)  — x, y, visible per kp per frame
    video_b_path  : absolute path to the Set B .avi video (shown in SLEAP GUI)
    template_slp  : path to a .slp file with a valid SLEAP skeleton definition
    """
    n_frames, n_kp, _ = predictions.shape
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)

    # ── Exact dtypes from the actual .slp files ───────────────────────────
    pts_dt = np.dtype([
        ("x",        "<f8"),
        ("y",        "<f8"),
        ("visible",  "?"),
        ("complete", "?"),
    ])
    inst_dt = np.dtype([
        ("instance_id",    "<i8"),
        ("instance_type",  "u1"),
        ("frame_id",       "<u8"),
        ("skeleton",       "<u4"),
        ("track",          "<i4"),
        ("from_predicted", "<i8"),
        ("score",          "<f4"),
        ("point_id_start", "<u8"),
        ("point_id_end",   "<u8"),
        ("tracking_score", "<f4"),
    ])
    frm_dt = np.dtype([
        ("frame_id",          "<u8"),
        ("video",             "<u4"),
        ("frame_idx",         "<u8"),
        ("instance_id_start", "<u8"),
        ("instance_id_end",   "<u8"),
    ])

    # ── Place invisible keypoints at anatomically sensible positions ──────
    # Invisible keypoints default to (0,0) — top-left corner — which is
    # awkward to grab in the SLEAP GUI.  Instead, place them at their
    # expected anatomical position relative to the thorax, using the
    # head→abdomen axis to define the fly's own body frame per frame.
    #
    # Offsets are in body-frame units of (forward, right) where 1.0 equals
    # the thorax→head distance.  "right" = fly's right (90° CW from forward).
    #   KP: head(0) thorax(1) abdomen(2) forelegR(3) forelegL(4)
    #       midlegR(5) midlegL(6) hindlegR(7) hindlegL(8)
    _BODY_OFFSETS = [
        None,           # 0  head     — always visible
        None,           # 1  thorax   — always visible
        None,           # 2  abdomen  — always visible
        ( 0.5,  0.7),   # 3  forelegR  forward + right
        ( 0.5, -0.7),   # 4  forelegL  forward + left
        ( 0.0,  0.9),   # 5  midlegR   right
        ( 0.0, -0.9),   # 6  midlegL   left
        (-0.5,  0.7),   # 7  hindlegR  backward + right
        (-0.5, -0.7),   # 8  hindlegL  backward + left
    ]
    _KP_HEAD    = 0
    _KP_THORAX  = 1
    _KP_ABDOMEN = 2

    preds = predictions.copy()
    for fi in range(n_frames):
        hx, hy   = preds[fi, _KP_HEAD,    0], preds[fi, _KP_HEAD,    1]
        ax, ay   = preds[fi, _KP_ABDOMEN, 0], preds[fi, _KP_ABDOMEN, 1]
        tx, ty   = preds[fi, _KP_THORAX,  0], preds[fi, _KP_THORAX,  1]
        head_vis = preds[fi, _KP_HEAD,    2] > 0
        abd_vis  = preds[fi, _KP_ABDOMEN, 2] > 0
        tho_vis  = preds[fi, _KP_THORAX,  2] > 0

        if tho_vis and head_vis and abd_vis:
            # Body axis: abdomen → head (forward direction)
            fx, fy = hx - ax, hy - ay
            body_len = np.hypot(fx, fy)
            if body_len > 1e-6:
                fx /= body_len; fy /= body_len           # forward unit vector
                rx,  ry = fy, -fx                        # right unit vector (90° CW)
                scale = body_len / 2.0                   # 1 unit = thorax→head dist
                for k in range(n_kp):
                    if preds[fi, k, 2] == 0 and _BODY_OFFSETS[k] is not None:
                        fwd, rgt = _BODY_OFFSETS[k]
                        preds[fi, k, 0] = tx + (fx * fwd + rx * rgt) * scale
                        preds[fi, k, 1] = ty + (fy * fwd + ry * rgt) * scale
        elif tho_vis:
            # Thorax known but not body axis: fall back to thorax position
            for k in range(n_kp):
                if preds[fi, k, 2] == 0:
                    preds[fi, k, 0] = tx
                    preds[fi, k, 1] = ty

    # ── Build arrays ──────────────────────────────────────────────────────
    pts_arr  = np.zeros(n_frames * n_kp, dtype=pts_dt)
    inst_arr = np.zeros(n_frames,        dtype=inst_dt)
    frm_arr  = np.zeros(n_frames,        dtype=frm_dt)

    for fi in range(n_frames):
        for k in range(n_kp):
            idx = fi * n_kp + k
            pts_arr[idx]["x"]        = float(preds[fi, k, 0])
            pts_arr[idx]["y"]        = float(preds[fi, k, 1])
            pts_arr[idx]["visible"]  = bool(preds[fi, k, 2])
            pts_arr[idx]["complete"] = True

        inst_arr[fi]["instance_id"]    = fi
        inst_arr[fi]["instance_type"]  = 0
        inst_arr[fi]["frame_id"]       = fi
        inst_arr[fi]["skeleton"]       = 0
        inst_arr[fi]["track"]          = -1
        inst_arr[fi]["from_predicted"] = -1
        inst_arr[fi]["score"]          = 0.0
        inst_arr[fi]["point_id_start"] = fi * n_kp
        inst_arr[fi]["point_id_end"]   = (fi + 1) * n_kp
        inst_arr[fi]["tracking_score"] = 0.0

        frm_arr[fi]["frame_id"]          = fi
        frm_arr[fi]["video"]             = 0
        frm_arr[fi]["frame_idx"]         = fi
        frm_arr[fi]["instance_id_start"] = fi
        frm_arr[fi]["instance_id_end"]   = fi + 1

    # ── Build videos_json ─────────────────────────────────────────────────
    video_b_path = str(Path(video_b_path).resolve())
    cap     = cv2.VideoCapture(video_b_path)
    n_vf    = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    vid_H   = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    vid_W   = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    cap.release()

    vid_json = json.dumps({
        "filename": video_b_path,
        "backend": {
            "type":         "MediaVideo",
            "shape":        [n_vf, vid_H, vid_W, 3],
            "filename":     video_b_path,
            "grayscale":    False,
            "bgr":          True,
            "dataset":      "",
            "input_format": "",
        },
    })
    vid_bytes = vid_json.encode("utf-8")

    # ── Copy template (preserves skeleton JSON in metadata attrs) ─────────
    shutil.copy2(template_slp, output_path)

    with h5py.File(output_path, "r+") as f:
        # Replace core datasets
        for ds_name in ("frames", "instances", "points"):
            if ds_name in f:
                del f[ds_name]
        f.create_dataset("frames",    data=frm_arr)
        f.create_dataset("instances", data=inst_arr)
        f.create_dataset("points",    data=pts_arr)

        # Replace videos_json (link to Set B)
        if "videos_json" in f:
            del f["videos_json"]
        f.create_dataset("videos_json", data=np.array([vid_bytes]))

        # Empty out pred_points (no pre-existing predictions)
        if "pred_points" in f:
            del f["pred_points"]
        pred_dt = np.dtype([("x","<f8"),("y","<f8"),("visible","?"),
                            ("complete","?"),("score","<f8")])
        f.create_dataset("pred_points", data=np.zeros(0, dtype=pred_dt))

        # Empty suggestion / session / track lists
        for ds_name in ("suggestions_json", "sessions_json", "tracks_json"):
            if ds_name in f:
                del f[ds_name]
        f.create_dataset("suggestions_json", data=np.zeros(0, dtype="float64"))
        f.create_dataset("sessions_json",    data=np.zeros(0, dtype="float64"))
        f.create_dataset("tracks_json",      data=np.zeros(0, dtype="float64"))

    print(f"Saved: {output_path}  ({n_frames} frames, {n_kp} keypoints)")


# ── Video relinking helper (used by notebook for SLEAP predictions) ─────────

def relink_slp_to_setb(pred_file: str, video_b_path: str) -> None:
    """
    Update the video reference in a SLEAP .slp file to point to Set B video.
    Used after `sleap-track` to ensure the SLEAP GUI shows the colourmap video.
    """
    video_b_path = str(Path(video_b_path).resolve())
    with h5py.File(pred_file, "r+") as f:
        vids_raw = f["videos_json"][:]
        new_vids = []
        for v in vids_raw:
            try:
                obj = json.loads(v.decode("utf-8"))
            except Exception:
                obj = json.loads(v)
            obj["filename"] = video_b_path
            if "backend" in obj:
                obj["backend"]["filename"] = video_b_path
            new_vids.append(json.dumps(obj).encode("utf-8"))
        del f["videos_json"]
        f.create_dataset("videos_json", data=np.array(new_vids))
    print(f"Relinked {pred_file} -> Set B video")


# ── SLEAP predictions reader ────────────────────────────────────────────────

def sleap_predictions_to_array(slp_path: str, n_video_frames: int) -> np.ndarray:
    """
    Read a SLEAP .predictions.slp file and extract coordinates into the same
    (n_frames, N_KP, 3) array format used by run_inference().

    SLEAP stores predictions in `pred_points` (not `points`) with instance_type=1.
    Frames with no prediction remain [0, 0, 0] (invisible / not detected).

    Parameters
    ----------
    slp_path       : path to the .predictions.slp file from sleap-track
    n_video_frames : total number of frames in the video (from cv2)

    Returns
    -------
    preds : np.ndarray  shape (n_video_frames, N_KP, 3)
        last dim = [x, y, visible]
    """
    preds = np.zeros((n_video_frames, N_KP, 3), dtype=np.float32)

    with h5py.File(slp_path, "r") as f:
        frames_ds = f["frames"][()]
        inst_ds   = f["instances"][()]
        pred_pts  = f["pred_points"][()]
        pts       = f["points"][()]

    # Use pred_points (raw SLEAP output) if non-empty, else fall back to points
    # (file already converted by a previous Phase 3.5b run)
    pt_source = pred_pts if len(pred_pts) > 0 else pts

    for frm in frames_ds:
        frame_idx  = int(frm["frame_idx"])
        inst_start = int(frm["instance_id_start"])
        inst_end   = int(frm["instance_id_end"])

        if inst_start >= inst_end or frame_idx >= n_video_frames:
            continue

        inst     = inst_ds[inst_start]           # single fly — take first instance
        pt_start = int(inst["point_id_start"])
        pt_end   = int(inst["point_id_end"])

        for k, pt_idx in enumerate(range(pt_start, pt_end)):
            if k >= N_KP:
                break
            pt = pt_source[pt_idx]
            if not np.isnan(float(pt["x"])) and not np.isnan(float(pt["y"])):
                preds[frame_idx, k, 0] = float(pt["x"])
                preds[frame_idx, k, 1] = float(pt["y"])
                preds[frame_idx, k, 2] = 1.0 if bool(pt["visible"]) else 0.0

    return preds


# ── Main ────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="ADPT inference on a full video")
    parser.add_argument("--model",    required=True,  help=".pt checkpoint path")
    parser.add_argument("--video",    required=True,  help="Inference video (set B/C/D)")
    parser.add_argument("--video_b",  required=True,  help="Set B video path (for SLEAP GUI)")
    parser.add_argument("--output",   required=True,  help="Output .slp path")
    parser.add_argument("--set",      default="B",    choices=["B", "C", "D"],
                        help="Which video set is being used for inference")
    parser.add_argument("--template", default=str(TEMPLATE_SLP),
                        help="Training .slp used as skeleton template")
    args = parser.parse_args()

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device      : {device}")

    cfg         = _SET_CFG[args.set]
    in_channels = cfg["in_channels"]
    input_size  = cfg["input_size"]
    mean        = cfg["mean"].reshape(1, 1, -1)
    std         = cfg["std"].reshape(1, 1, -1)

    # Load model
    print("Loading model ...")
    model, ckpt_ch, theta = load_model(args.model, device)
    if ckpt_ch != in_channels:
        print(f"  WARNING: checkpoint in_channels={ckpt_ch} but set {args.set} "
              f"expects {in_channels}.  Using checkpoint value ({ckpt_ch}).")
        in_channels = ckpt_ch
    print(f"  in_channels={in_channels}, theta={theta:.3f}")

    # Load video
    print("Loading video frames ...")
    raw_frames, native_W, native_H = load_video(args.video, in_channels, input_size)
    n = len(raw_frames)
    print(f"  {n} frames  native={native_H}x{native_W}  model_input={input_size[0]}x{input_size[1]}")

    # Preprocess
    tensors = [preprocess(f, mean, std) for f in raw_frames]

    # Inference
    print("Running inference ...")
    preds = run_inference(model, tensors, device, theta)

    # Scale predictions from model input space (H_in x W_in) back to native
    # video resolution so SLEAP GUI coordinates are correct.
    H_in, W_in = input_size
    scale_x = native_W / W_in
    scale_y = native_H / H_in
    visible = preds[:, :, 2] > 0
    preds[:, :, 0] = np.where(visible, preds[:, :, 0] * scale_x, 0.0)
    preds[:, :, 1] = np.where(visible, preds[:, :, 1] * scale_y, 0.0)
    print(f"  Scaled predictions to native resolution ({scale_x:.4f}x, {scale_y:.4f}y)")

    vis_count = int(preds[:, :, 2].sum())
    print(f"  {vis_count} keypoint contacts predicted across {n} frames")

    # Write .slp
    print("Writing .slp ...")
    write_slp(args.output, preds, args.video_b, template_slp=args.template)
    print("Done.")


if __name__ == "__main__":
    main()
