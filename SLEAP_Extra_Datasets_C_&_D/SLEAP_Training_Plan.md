# SLEAP Training Plan — Drosophila FTIR Leg Tracking

**Student:** Pedro Vasques | MSc Mechanical Engineering, IST Lisboa
**Last updated:** 2026-04-07
**Library:** sleap-nn 0.1.3 (PyTorch)
**Dataset:** Set B — hot colourmap, 160×480px RGB
**Splits:** 755 TRAIN / 120 VAL / 117 TEST frames

---

## Metrics

| Metric | Definition |
|--------|-----------|
| **avg_dist** | Mean Euclidean distance pred→GT (px), visible keypoints only — **primary ranking metric** |
| **mOKS** | Mean Object Keypoint Similarity (0–1, higher=better) |
| **vis_Prec** | Precision of contact detection (TP / (TP+FP)) |
| **vis_Rec** | Recall of contact detection (TP / (TP+FN)) |
| **CR_frame%** | % frames needing ≥1 manual correction (τ=5px) — most practical for Prof. César |
| **FP / FN** | Raw false contact / missed contact counts on VAL set |

**Decision rule:** lowest val avg_dist wins. Ties (≤0.05px) broken by simpler model.

---

## Fixed Hyperparameters (all runs)

| Parameter | Value | Source |
|-----------|-------|--------|
| Dataset | Set B (hot colourmap) | Best visual input for FTIR |
| sigma | 2.5 px | FTIR contact spots 1–3px wide |
| output_stride | 4 | SLEAP 2022 default |
| optimizer | Adam + AMSGrad, lr=1e-4 | SLEAP 2022 |
| lr_scheduler | ReduceLROnPlateau, factor=0.5, patience=20 | SLEAP 2022 |
| early_stopping | patience=20 on val loss | SLEAP 2022 |
| batch_size | 6 | GPU memory limit |
| MAX_EPOCHS | 200 | — |
| augmentation (when on) | rotation ±15°, scale 0.9–1.1, no intensity | FTIR physics |

---

## Phase 1 — Architecture Comparison

**Variable:** backbone × ImageNet pretrained weights
**Fixed:** aug=True, sigma=2.5, all other defaults

| Run | Backbone | Pretrained | Status | val avg_dist | mOKS | vis_Prec | vis_Rec | FP | FN | CR_frame% | Notes |
|-----|----------|------------|--------|-------------|------|----------|---------|----|----|-----------|-------|
| R1 | UNet-64 | ❌ No | ✅ Done | 1.18 px | 0.919 | 0.983 | 0.996 | 14 | 3 | ? | Baseline |
| R2 | ConvNeXt-tiny | ❌ No | 📋 Next | — | — | — | — | — | — | — | Fair comparison |
| R3 | ConvNeXt-tiny | ✅ ImageNet | 📋 | — | — | — | — | — | — | — | Real ConvNeXt |
| R4 | SwinT-tiny | ❌ No | 📋 | — | — | — | — | — | — | — | Fair comparison |
| R5 | SwinT-tiny | ✅ ImageNet | 📋 | — | — | — | — | — | — | — | Real SwinT |

**Why test scratch AND pretrained for ConvNeXt/SwinT:**
If pretrained beats scratch → the advantage is ImageNet pretraining, not the architecture.
If scratch is competitive → small dataset equalises architectures.
Both findings are interesting for the thesis.

**Phase 1 winner:** *(to be filled)*
**Key learning:** *(to be filled)*

---

## Phase 2 — Tune the Winner

Runs only after Phase 1 winner is identified. Only one track runs.

### Track A — If UNet wins
Variable: filters × augmentation (2×2 factorial)

| Run | Filters | Aug | Status | val avg_dist | mOKS | CR_frame% | Notes |
|-----|---------|-----|--------|-------------|------|-----------|-------|
| R6 | 32 | ✅ Yes | ⏳ P2 | — | — | — | Half params — still competitive? |
| R7 | 64 | ❌ No | ⏳ P2 | — | — | — | Does aug help on clean FTIR? |
| R8 | 32 | ❌ No | ⏳ P2 | — | — | — | Minimal model |

### Track B — If ConvNeXt wins
Variable: model size × augmentation

| Run | Size | Pretrained | Aug | Status | val avg_dist | mOKS | CR_frame% | Notes |
|-----|------|------------|-----|--------|-------------|------|-----------|-------|
| R6 | tiny | ✅ | ❌ No | ⏳ P2 | — | — | — | Does aug help? |
| R7 | small | ✅ | ✅ Yes | ⏳ P2 | — | — | — | More capacity worth it? |

### Track C — If SwinT wins
Variable: model size × augmentation

| Run | Size | Pretrained | Aug | Status | val avg_dist | mOKS | CR_frame% | Notes |
|-----|------|------------|-----|--------|-------------|------|-----------|-------|
| R6 | tiny | ✅ | ❌ No | ⏳ P2 | — | — | — | Does aug help? |
| R7 | small | ✅ | ✅ Yes | ⏳ P2 | — | — | — | More capacity worth it? |

**Phase 2 winner:** *(to be filled)*
**Key learning:** *(to be filled)*

---

## Phase 3 — Sigma Sweep

Run on best model from Phase 2. All other settings unchanged.

| Run | Sigma | Status | val avg_dist | mOKS | CR_frame% | Notes |
|-----|-------|--------|-------------|------|-----------|-------|
| R9  | 1.5 px | ⏳ P3 | — | — | — | Tighter — sharper localisation? |
| R10 | 3.5 px | ⏳ P3 | — | — | — | Broader — better contact detection? |

**Context:** FTIR contact spots are 1–3px wide. Default 2.5px is a midpoint estimate.
R1 avg_dist=1.18px suggests good localisation — tighter sigma may push this further.

**Phase 3 winner:** *(to be filled)*
**Key learning:** *(to be filled)*

---

## What We Are NOT Testing (and why)

| Parameter | Reason skipped |
|-----------|---------------|
| Batch size | Plateau LR scheduler adapts; negligible effect on final accuracy |
| Learning rate | 1e-4 + ReduceLROnPlateau well-chosen; not a bottleneck |
| UNet filters=128 | R1 at 64 gets 1.18px — diminishing returns expected |
| Sets C/D (greyscale) | Set B colourmap is the richest input; inferior inputs not needed |
| output_stride=2 | 4x output resolution but large memory cost, no guaranteed gain |

---

## Best Model (running)

| Field | Value |
|-------|-------|
| Run | R1 (current best) |
| Backbone | UNet-64 |
| val avg_dist | 1.18 px |
| mOKS | 0.919 |
| Checkpoint | `models/drosophila_unet64_setB_260407_092817/` |

---

## Estimated Timeline

| Phase | Runs | Colab time |
|-------|------|-----------|
| Phase 1 | R2–R5 (4 runs) | ~3–4h |
| Phase 2 | R6–R8 (3 runs) | ~2–3h |
| Phase 3 | R9–R10 (2 runs) | ~1–2h |
| **Total** | **9 more runs** | **~6–9h** |

---

## Change Log

| Date | Change |
|------|--------|
| 2026-04-07 | Document created. R1 results recorded. Plan agreed. |
