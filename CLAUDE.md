# Project Context — Drosophila Leg Tracking (SLEAP + ADPT Deep Learning)

**Student:** Pedro Palácios Castanheira Almeida Vasques  
**Programme:** MSc Mechanical Engineering – Design of Mechatronic Systems, IST Lisboa (Jan 2026)  
**Supervisors:** Prof. Dr. Rui Moura Coelho (IST), Prof. Dr. César Mendes (NOVA Medical School)

---

## Objective

Build a deep learning pose estimation model to detect *Drosophila melanogaster* **ground-contact leg positions** from FTIR high-speed video, replacing the error-prone auto-detection in the existing MATLAB **FlyWalker** software.

**The physics of FTIR imaging is fundamental to the model's purpose:** the FTIR system only makes legs visible when they are physically touching the glass surface. Legs in the air are invisible (or near-invisible) in the image. Therefore:

- The model's job is **not** to track all 6 legs at all times
- The model's job is to **detect which legs are currently touching the ground and where**
- A keypoint with `visible=0` in the labels means that leg is in the air — this is real biological information, not a labelling gap
- Typically only 3–4 legs are visible (in contact) at any given frame

**The full pipeline:**
1. Raw video from FlyWalker → background-subtracted + hot-colourmap processed `.avi`
2. **DL model inference** → (x, y) ground-contact predictions per frame, for whichever legs are touching
3. Predictions loaded into **SLEAP** for visual inspection and manual correction
4. Corrected predictions exported to a FlyWalker-compatible CSV → existing gait analysis scripts run unchanged

**Current primary approach: SLEAP-NN models** (sleap-nn library, single-instance pipeline). The ADPT custom model is trained and operational but secondary. SLEAP ConvNeXt-pretrained is the best performing model.

---

## Experimental Setup

- **System:** FlyWalker (NOVA Medical School) — FTIR illumination + high-speed camera filming freely walking flies from below
- **Frame rate:** 250 FPS
- **Image appearance:** Background-subtracted frames processed with a hot colourmap. Foot contact points appear as bright spots (1–3 pixels wide) on a black background. The fly body is clearly visible; legs not touching the ground are invisible — **this is intentional and expected**.

---

## Keypoints (9 total)

| Index | Name       | Notes                              |
|-------|------------|------------------------------------|
| 0     | head       | always visible                     |
| 1     | thorax     | body centroid, always visible      |
| 2     | abdomen    | always visible                     |
| 3     | forelegR   | right foreleg tip                  |
| 4     | forelegL   | left foreleg tip                   |
| 5     | midlegR    | right midleg tip                   |
| 6     | midlegL    | left midleg tip                    |
| 7     | hindlegR   | right hindleg tip                  |
| 8     | hindlegL   | left hindleg tip                   |

**Important:** Leg keypoints with `visible=0` mean the leg is **not in contact with the ground at that moment** — FTIR physics makes airborne legs invisible, so this is real ground-truth biological data, not a labelling error.

**Skeleton edges:**
```
thorax(1) → head(0)
thorax(1) → abdomen(2)
thorax(1) → forelegR(3)
thorax(1) → forelegL(4)
thorax(1) → midlegR(5)
thorax(1) → midlegL(6)
thorax(1) → hindlegR(7)
thorax(1) → hindlegL(8)
```

---

## Dataset

Labels were created manually in **SLEAP** and saved as `.slp` files (HDF5 v0, SLEAP v2 format).

### File locations (on Pedro's Windows machine)

All active SLEAP dataset files live under `Inference_Pipeline/`:

| File | Location |
|------|----------|
| TRAIN (current, 755 frames) | `Inference_Pipeline/SLEAP_Dataset/Drosophila_TRAIN_set_setB.slp` + `.pkg.slp` |
| TRAIN (test AL run, 1057 frames) | `Inference_Pipeline/SLEAP_Dataset/Drosophila_TRAIN_set_setB_1057frames.slp` + `.pkg.slp` |
| VAL (120 frames) | `Inference_Pipeline/SLEAP_Dataset/Drosophila_VAL_set_setB.slp` + `.pkg.slp` |
| TEST (117 frames) | `Inference_Pipeline/SLEAP_Dataset/Drosophila_TEST_set_setB.slp` + `.pkg.slp` |
| Colab upload config | `Inference_Pipeline/SLEAP_Dataset/colab_config.json` |
| Videos (Set B, active) | `Inference_Pipeline/Videos/PROCESSED_Colormap_Videos/` |

No pre-embedded Set B `.pkg.slp` files currently exist on disk — see "Frame embedding for Colab" below.

`colab_config.json` points to the 1057-frame set — this was a **test run** of the active learning pipeline, not the canonical TRAIN set. The current official TRAIN set is the 755-frame `Drosophila_TRAIN_set_setB.slp`.

### TRAIN set — 755 labeled frames (current)

6 training videos: CantonS_unamp_Fly1.3, Fly1.1, Fly7.1, Fly4.1, Fly6.2, Fly14.1. All 4 SLEAP models were trained on this set.

### VAL set — 120 labeled frames

`CantonS_unamp_Fly3.1.avi` — one continuous run (frames 0–119). Unchanged since initial labelling.

### TEST set — 117 labeled frames

`CantonS_unamp_Fly1.2.avi` — one continuous run (frames 0–116). Unchanged since initial labelling.

### Keypoint visibility stats

Head, thorax, abdomen are **always labeled** (100% visible). Leg visibility varies — legs off the ground are labeled `visible=0` intentionally:

| Keypoint | TRAIN visible% | VAL visible% | TEST visible% |
|----------|---------------|-------------|--------------|
| head     | 100% | 100% | 100% |
| thorax   | 100% | 100% | 100% |
| abdomen  | 100% | 100% | 100% |
| forelegR | 57%  | 63%  | 57%  |
| forelegL | 60%  | 63%  | 59%  |
| midlegR  | 63%  | 69%  | 58%  |
| midlegL  | 63%  | 72%  | 63%  |
| hindlegR | 55%  | 57%  | 39%  |
| hindlegL | 43%  | 52%  | 29%  |

---

## .slp File Format

`.slp` files are HDF5 v0. The key datasets and their binary layouts are:

### `points` dataset — 18 bytes/record
```
x        : float64 (8 bytes)  — pixel x in original video frame
y        : float64 (8 bytes)  — pixel y in original video frame
visible  : uint8   (1 byte)   — 1 = keypoint visible/on ground, 0 = not
complete : uint8   (1 byte)   — always 1 in this dataset
```

### `instances` dataset — 57 bytes/record
```
instance_id      : uint64 (8B)
instance_type    : uint8  (1B)
frame_id         : uint64 (8B)
skeleton         : uint32 (4B)
track            : uint32 (4B)
from_predicted   : uint64 (8B)
score            : uint64 (8B)
point_id_start   : uint64 (8B)  ← index into points array
point_id_end     : uint64 (8B)  ← exclusive end index
tracking_score   : float32(4B)
```

### `frames` dataset — 36 bytes/record
```
frame_id         : uint64 (8B)
video_id         : uint32 (4B)  ← index into vid_map
frame_idx        : uint32 (4B)  ← 0-based frame number in the .avi
_padding         : uint64 (8B)
instance_id_start: uint64 (8B)  ← index into instances array
instance_id_end  : uint64 (8B)  ← exclusive end index
```

The video_id maps to the ordered list of `MediaVideo` JSON blobs embedded in the file binary (extracted with regex `{"type":"MediaVideo","shape":[nf,H,W,3],"filename":"..."}`).

There is **one instance per frame** (single fly), so `instance_id_end = instance_id_start + 1` always.

**Duplicate frames:** deduplication implemented in `parse_slp()` (`seen: set` block) — keeps first occurrence, warns if any are removed.

---

## SLEAP Models (Primary Approach)

All models use **sleap-nn** (not legacy sleap), single-instance pipeline, Set B (hot colourmap, 160×480 RGB), trained on Google Colab (T4 GPU). Model folders live in `Inference_Pipeline/Models/SLEAP_Models/`.

### Trained models — performance on TEST set

| Model folder | Backbone | Pretrained | TRAIN frames | TEST MPE (px) | TEST CR_frame (%) | TEST FP (%) | TEST FN (%) |
|---|---|---|---|---|---|---|---|
| `drosophila_unet64_setB_260407_092817` | UNet-64 | No | 755 | 1.68 | 37.6 | 14.83 | 0.99 |
| `drosophila_convnext_setB_260407_164511` | ConvNeXt | No | 755 | 2.44 | 64.1 | 22.09 | 1.27 |
| `drosophila_convnext_pt_setB_260408_085648` | ConvNeXt | Yes (ImageNet) | 755 | **1.37** | **17.1** | **4.94** | 1.27 |
| `drosophila_swint_pt_setB_260420_145559` | SwinT | Yes (ImageNet) | 755 | 1.37 | 22.2 | 5.81 | 1.55 |

**Best model: `drosophila_convnext_pt_setB_260408_085648`** — lowest TEST MPE and CR_frame. ConvNeXt-pretrained is the recommended default for new inference runs.

Each model folder contains:
- `best.ckpt` — best checkpoint by val loss
- `training_config.yaml` — full training configuration
- `training_log.csv` — per-epoch loss curves
- `eval_metrics_summary.csv` — SLEAP + custom metrics for TRAIN/VAL/TEST splits
- `eval_kp_metrics_*.png` — per-keypoint metric plots
- `labels_pr.*.slp` / `labels_gt.*.slp` — predicted vs ground-truth `.slp` files for each split

### SLEAP training configuration (Set B)

- **Architecture:** single-instance, confmaps head, output_stride=4, sigma=2.5
- **Backbone variants:** UNet (filters=64), ConvNeXt (tiny), SwinT (tiny)
- **Pretrained weights:** ImageNet (ConvNeXt, SwinT); none (UNet)
- **Optimiser:** Adam, lr=1e-4, amsgrad=True
- **LR schedule:** ReduceLROnPlateau (factor=0.5, patience=20, min_lr=1e-6)
- **Early stopping:** patience=20 on val loss
- **Max epochs:** 200, min 200 steps/epoch
- **Batch size:** 6 (TRAIN), 6 (VAL)
- **Augmentation:** SLEAP default (enabled for TRAIN only)
- **Training notebook:** `Inference_Pipeline/Training_and_inference_using_Google_Drive.ipynb` (Colab)

### Config reconstruction from checkpoint

The GUI (`gui/lib/nb_utils.py`, function `_ev_reconstruct_config`) can reconstruct a `training_config.yaml` from `best.ckpt` alone by inspecting state_dict key shapes. Key rules:
- `features.0.0.weight: [embed_dim, in_ch, 4, 4]` → SwinT; embed_dim 96=tiny, 128=small, 192=base
- `stem.0.weight: [C_out, in_ch, K, K]` → ConvNeXt
- `encoder.encoder_stack.0.blocks.0.weight` → UNet
- For SwinT and ConvNeXt: `output_stride=4` for both backbone and confmaps head (3 decoder stages, ends at stride 4)

### Evaluation metrics

**SLEAP built-in** (from `sleap_nn.cli eval`):
- mOKS, mAP, mAR — object keypoint similarity, precision, recall
- Avg dist / p50 / p90 — distance percentiles in pixels
- mPCK, PCK@5px — percentage of correct keypoints
- Vis Precision / Vis Recall — contact detection performance

**Custom thesis metrics** (computed in GUI + notebooks):
- **MPE** (px) — mean position error on visible keypoints (identical to SLEAP avg_dist)
- **FP rate (%)** — false contact predictions when leg is airborne
- **FN rate (%)** — missed contacts when leg is on ground
- **TD (px/fr)** — tracking drift, frame-to-frame displacement
- **CR_frame (%)** — % of frames needing at least one correction (primary metric for Prof. César)
- **CR_kp (%)** — % of keypoint-frames needing correction (τ=5px threshold)

**Global FP/FN rates** are true global ratios (total_FP / total_airborne, total_FN / total_visible) — not `nanmean` of per-keypoint rates.

---

## GUI (Streamlit)

The primary interface for running inference and active learning is a Streamlit GUI in `gui/`.

**Launch:** `streamlit run gui/app.py` from the project root (or via the configured `.streamlit/` settings).

### Pages

**1 — Bulk Pipeline** (`gui/pages/1_Bulk_Pipeline.py`):
- Select video folder from `Inference_Pipeline/Videos/PROCESSED_Colormap_Videos/`
- Select inference model (SLEAP model folder or ADPT `.pt`)
- Run Phases 1–8 end-to-end via `gui/lib/nb_utils.py`
- Outputs land in `Inference_Pipeline/Predictions/{VIDEO_FOLDER_NAME}/`

**2 — Active Learning** (`gui/pages/2_Active_Learning.py`):
- Browse trained SLEAP models, display eval metrics + plots
- Run training evaluation (TRAIN/VAL/TEST) on any selected model
- Run active learning fine-tune round: merge corrected `.slp` predictions into TRAIN set → fine-tune → new model

### Key backend — `gui/lib/nb_utils.py`

Contains all the logic called by the GUI pages:
- `_ev_reconstruct_config()` — reconstructs `training_config.yaml` from `best.ckpt` alone
- `_ev_run_inference()` — runs `sleap_nn.cli track` on TRAIN/VAL/TEST splits
- `_ev_run_sleap_eval()` — runs `sleap_nn.cli eval` and parses metrics
- `_ev_compute_custom()` — computes MPE, FP/FN, TD, CR_frame, CR_kp from `.slp` files
- `_ev_build_plots()` — generates per-keypoint metric plots
- Phase runner functions for the Bulk Pipeline

### Image display

`_safe_image()` in `2_Active_Learning.py` reads images as PIL bytes to prevent Streamlit browser-level caching. This ensures switching models always shows fresh plots rather than stale cached images.

---

## Active Learning Pipeline

The active learning loop uses corrected SLEAP predictions from previous inference runs to expand the TRAIN set and fine-tune the model.

### Notebooks

- **Local fine-tune:** `Inference_Pipeline/Active_Learning.ipynb`
- **Colab fine-tune:** `Inference_Pipeline/Active_Learning_Colab.ipynb`
- **Full Colab training:** `Inference_Pipeline/Training_and_inference_using_Google_Drive.ipynb` (same file as above)

### Workflow

1. Run inference on a new video (`Bulk_Pipeline`)
2. Open SLEAP GUI, manually correct predictions (`sleap-label`)
3. Save corrected `.slp` to `Inference_Pipeline/Predictions/{VIDEO_FOLDER_NAME}/`
4. Run Active Learning notebook — merges corrected file with current TRAIN set:
   ```bash
   sleap-merge Drosophila_TRAIN_set_setB.slp corrected.slp -o merged_train.slp
   ```
5. Build fine-tune config YAML: lower LR (1e-5), fewer epochs (50), `pretrained_backbone_weights` + `pretrained_head_weights` pointing to `best.ckpt` of base model
6. Train on Colab → download new model folder to `Inference_Pipeline/Models/SLEAP_Models/`
7. New model becomes available in GUI

**Current state:** One active learning test run completed to verify the pipeline works. Base UNet64 (755 frames) → merged with corrected Fly1.3 predictions → 1057-frame file created. This was a pipeline validation run, not the official next TRAIN set. The 1057-frame `.slp` exists in `SLEAP_Dataset/` but the canonical TRAIN set remains the 755-frame base.

### Frame embedding for Colab

Colab cannot read local video files directly — frames must be embedded in the `.pkg.slp` file. `embed_frames.py` handles this, but currently only exists for the Set C/D prep datasets at `SLEAP_Extra_Datasets_C_&_D/embed_frames.py`. No pre-embedded Set B TRAIN/VAL files currently exist — re-run the embedding step before a fresh Colab upload of Set B data if needed.

---

## Inference Pipeline

The pipeline is now **primarily GUI-driven** via the Bulk Pipeline page. All phases are implemented in `gui/lib/nb_utils.py`.

### Phases

1. **Phase 1:** Raw PNGs → BG subtraction → processed PNG sets (B=colormap, C=no-colormap, D=raw)
2. **Phase 2:** PNG sets → lossless AVI videos (FFV1, 250 FPS)
3. **Phase 3:** Model inference — SLEAP (`sleap_nn.cli track`) or ADPT (`inference.py`)
4. **Phase 3.5:** Relink `.slp` video reference to Set B (SLEAP GUI always shows colourmap)
5. **Phase 4:** Open SLEAP GUI for visual inspection and manual correction
6. **Phase 5:** `.slp` → `.analysis.h5` via `sleap-convert`
7. **Phase 6:** Analysis HDF5 → FlyWalker field arrays (body direction, leg positions, distcal applied)
8. **Phase 7:** Write `TRACKS.mat` via `scipy.io.savemat` — MATLAB struct format for FlyWalker
9. **Phase 8:** Run FlyWalker MATLAB analysis → graphs + `ResultSummary.xlsx`

All outputs land in `Inference_Pipeline/Predictions/{VIDEO_FOLDER_NAME}/`.

### SLEAP analysis HDF5 — tracks array layout

The `tracks` dataset shape is `(n_coords, n_nodes, n_tracks, n_frames)` = e.g. `(2, 9, 1, 191)`. After squeeze + correct transpose:
```python
tracks = np.squeeze(tracks_raw)      # (2, 9, n_frames)
tracks = tracks.transpose(2, 1, 0)   # (n_frames, n_nodes, 2)  ← correct
# NOT transpose(2, 0, 1) which gives (n_frames, 2, n_nodes) — wrong
```

### distcal (FlyWalker pixel/µm calibration)

```python
_DISTCAL_NOVA = 2.125 / 100          # Set A — NOVA resolution calibration
DISTCAL = _DISTCAL_NOVA if VIDEO_SET == "A" else _DISTCAL_NOVA / 1.46
```
Sets B/C/D are at 1/1.46 the NOVA resolution → fewer pixels per µm → divide by 1.46.

### FlyWalker TRACKS.mat sentinel

FlyWalker uses `~= -1` (not `isnan`) to detect missing contact data. The `_empty()` helper must return `-1.0`, not `np.nan`. This was a confirmed bug fix.

### Phase 8 — MATLAB on Windows

MATLAB R2025b on Windows cannot be reliably launched headlessly from Python via subprocess (`-batch` triggers license check error 5201; `-nosplash -nodesktop -r` crashes silently). Phase 8 writes `run_flywalker.m` to `Predictions/{VIDEO_FOLDER_NAME}/` and attempts headless launch, then falls back to printing the manual command. **If headless fails, open MATLAB and run:**
```matlab
run('C:/.../Predictions/{VIDEO_FOLDER_NAME}/run_flywalker.m')
```

### FlyWalker_Results_Gen folder

`Inference_Pipeline/FlyWalker_Results_Gen/` contains the minimal MATLAB files needed: `EvaluateFlyTable_activex_hexa.m`, `Parameters.m`, `smooth.m`, `line_dist.m`, `p_poly_dist.m`, `calculate_stc_trc_cluster.m`, `MultiEvaluate.m`.

---

## Local File Structure (Pedro's Windows machine)

```
Project root: C:\Users\pepev\Desktop\103665_THESIS_DL_Model\Model_Design_&_Training\
│
├── CLAUDE.md
├── gui\                                    ← Streamlit GUI (primary interface)
│   ├── app.py
│   ├── pages\
│   │   ├── 1_Bulk_Pipeline.py
│   │   └── 2_Active_Learning.py
│   └── lib\
│       ├── nb_utils.py                     ← all backend logic
│       └── styles_v2.py
│
├── Inference_Pipeline\
│   ├── Active_Learning.ipynb               ← local fine-tune notebook
│   ├── Active_Learning_Colab.ipynb         ← Colab fine-tune notebook
│   ├── Bulk_Pipeline.ipynb                 ← manual bulk pipeline notebook
│   ├── Training_and_inference_using_Google_Drive.ipynb  ← Colab training notebook
│   ├── inference.py                        ← ADPT inference script
│   ├── model.py                            ← ADPT model definition
│   ├── requirements.txt
│   ├── FlyWalker_Results_Gen\              ← minimal MATLAB FlyWalker files
│   ├── Models\
│   │   ├── SLEAP_Models\                   ← 4 trained SLEAP models (primary)
│   │   │   ├── drosophila_unet64_setB_260407_092817\
│   │   │   ├── drosophila_convnext_setB_260407_164511\
│   │   │   ├── drosophila_convnext_pt_setB_260408_085648\   ← BEST
│   │   │   └── drosophila_swint_pt_setB_260420_145559\
│   │   └── VS Code Models\
│   │       └── best_model.pt               ← ADPT model checkpoint (secondary)
│   ├── SLEAP_Dataset\
│   │   ├── Drosophila_TRAIN_set_setB_1057frames.slp + .pkg.slp  ← CURRENT TRAIN
│   │   ├── Drosophila_TRAIN_set_setB.slp + .pkg.slp             ← base (755 frames)
│   │   ├── Drosophila_VAL_set_setB.slp + .pkg.slp
│   │   ├── Drosophila_TEST_set_setB.slp + .pkg.slp
│   │   └── colab_config.json               ← records current active training set
│   ├── Videos\
│   │   └── PROCESSED_Colormap_Videos\      ← Set B videos (active)
│   └── Predictions\                        ← per-video outputs
│       └── {VIDEO_FOLDER_NAME}\
│           ├── *.predictions.slp
│           ├── *.analysis.h5
│           ├── *.TRACKS.mat
│           └── *.png (graphs)
│
└── SLEAP_Extra_Datasets_C_&_D\             ← Set C/D dataset prep (different purpose, not used by current SLEAP models)
    ├── SLEAP_Training_Plan.md
    ├── create_scaled_slp.py
    ├── embed_frames.py                     ← embeds frames into .pkg.slp for Colab (Set C/D only)
    ├── model_results.md
    ├── Drosophila_TRAIN_set_setC.slp + .pkg.slp
    ├── Drosophila_VAL_set_setC.slp + .pkg.slp
    ├── Drosophila_TEST_set_setC.slp + .pkg.slp
    ├── Drosophila_TRAIN_set_setD.slp + .pkg.slp
    ├── Drosophila_VAL_set_setD.slp + .pkg.slp
    └── Drosophila_TEST_set_setD.slp + .pkg.slp
```

---

## Current Status

- [x] SLEAP models trained and evaluated (4 models, Set B, single-instance)
- [x] **Best model identified:** `drosophila_convnext_pt_setB_260408_085648` — TEST MPE=1.37px, CR_frame=17.1%
- [x] End-to-end inference pipeline working (GUI Bulk Pipeline + manual notebooks)
- [x] Streamlit GUI complete — Bulk Pipeline + Active Learning pages
- [x] Active learning loop operational — merge corrected labels → fine-tune → new model (pipeline validated with a test run)
- [x] TRAIN set is 755 frames (official); 1057-frame merged file exists as a test AL run artifact, not yet adopted as canonical
- [x] Predictions generated for 4 videos (Fly1.1, Fly1.2, Fly1.3, Fly3.1) in `Inference_Pipeline/Predictions/`
- [x] FlyWalker TRACKS.mat output working; Phase 8 MATLAB partial (headless launch unreliable on Windows)
- [x] SwinT config reconstruction from checkpoint fixed (`output_stride=4` for backbone + head)
- [x] Image persistence bug fixed in Active Learning GUI (PIL bytes bypass browser cache)
- [x] Step 8.5 (TEST set evaluation) added to both copies of Training_and_inference notebook
- [ ] Download fine-tuned UNet64 (1057 frames) from Colab → add to SLEAP_Models
- [ ] Re-run VIDEO_Generation_&_Treatment.ipynb for remaining videos with corrected BG subtraction
- [ ] Run full pipeline end-to-end on new videos with ConvNeXt-pretrained model

---

## ADPT Model (Secondary / Thesis Reference)

The custom ADPT-style CNN-Transformer model was fully implemented in PyTorch but SLEAP models outperform it in practice and are the primary inference tool. The ADPT model checkpoint is at `Inference_Pipeline/Models/VS Code Models/best_model.pt` and is available via the GUI (select "Local" / ADPT in the Bulk Pipeline page).

### Architecture summary

ResNet-50 backbone (layer1 only, H/4 output) → PatchEncoder → Transformer Encoder ×6 (BERT-style, h=8, d=256) → decoder with skip connections → 3 output heads (heatmaps, refinements, LRSS). T=9 temporal window. BAF excluded (single-animal). 8.86M parameters.

Based on: **Tang et al., eLife 2025.** PyTorch implementation (paper uses TF 2.9).

### Key ADPT design decisions

| Decision | Value | Rationale |
|----------|-------|-----------|
| T (window size) | 9 | Symmetric 4+1+4; shortest run = 12 frames |
| Heatmap loss | Unmasked, POSITIVE_WEIGHT=50 | GT=zero for airborne KP; weighted to address imbalance (~12 vs 4800 pixels) |
| Backbone | ResNet-50 layer1 only | H/4 output (256ch); layer2+ too abstract for keypoint localisation |
| Augmentation | Geometric only (hflip, vflip, rotation ±15°, scale ±10%) | Brightness/contrast removed — FTIR: additive beta lifts BG to fake contact signals |
| Loss | Weighted RMSE (heatmap) + RMSE (refinement) + 0.1×BCE (LRSS) | Conservative LRSS λ; BAF excluded |
| Optimiser | AdamW, warmup 10 ep (1e-5→1e-3) + cosine 190 ep (1e-3→1e-5) | Directly from ADPT paper |

### ADPT inference coordinate handling

`inference.py` scales predictions from model input space (160×480) back to native video resolution before writing the `.slp`:
```python
scale_x = native_W / W_in
scale_y = native_H / H_in
preds[:, :, 0] = np.where(visible, preds[:, :, 0] * scale_x, 0.0)
preds[:, :, 1] = np.where(visible, preds[:, :, 1] * scale_y, 0.0)
```

---

## Key References

- [ADPT] Tang et al., eLife 2025 — custom model architecture. Code: https://github.com/tangguoling/ADPT
- [SLEAP-NN] Pereira et al., Nature Methods 2022 — primary inference library
- [FlyWalker] Mendes et al., eLife 2013
- [DeepLabCut] Mathis et al., Nature Neuroscience 2018
- [Vaswani] Vaswani et al., NeurIPS 2017 — "Attention Is All You Need" (Transformer)
