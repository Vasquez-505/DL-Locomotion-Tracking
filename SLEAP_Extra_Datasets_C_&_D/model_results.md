# Model Results — SLEAP Hyperparameter Tuning

**Dataset:** Set B — hot colourmap, 160×480px RGB
**Splits:** 755 TRAIN / 120 VAL / 117 TEST frames
**Primary metric:** val avg_dist (px) — lower is better

---

## Results Table

| Field | R1 | R3 | R4 | R5 |
|-------|----|----|----|----|
| **Run ID** | R1 | R3 | R4 | R5 |
| **Backbone** | UNet | ConvNeXt | SwinT | SwinT |
| **Pretrained** | ❌ | ✅ ImageNet | ❌ | ✅ ImageNet |
| **Filters/Size** | 64 | tiny | tiny | tiny |
| **Aug** | ✅ | ✅ | ✅ | ✅ |
| **Sigma** | 2.5 | 2.5 | 2.5 | 2.5 |
| **Parameters** | ~5M | 87.5M | — | — |
| **Epochs (total/best)** | 81 / 59 | 62 / 40 | — | — |
| **val/train loss ratio** | 1.257 | 2.215 | — | — |
| **Train time** | ~47 min | 215 min | — | — |
| **Run name** | `drosophila_unet64_setB_260407_092817` | `drosophila_convnext_pt_setB_260408_085648` | — | — |
| | | | | |
| **— VAL METRICS —** | | | | |
| `avg_dist (px)` | 1.178 | 1.148 | — | — |
| `p50 (px)` | 1.101 | 1.072 | — | — |
| `p75 (px)` | 1.534 | 1.416 | — | — |
| `p90 (px)` | 1.947 | 1.893 | — | — |
| `p95 (px)` | 2.211 | 2.129 | — | — |
| `p99 (px)` | 2.831 | 2.650 | — | — |
| `mOKS` | nan | nan | — | — |
| `mAP` | nan | 0.857 | — | — |
| `mAR` | nan | 0.884 | — | — |
| `mPCK` | 0.699 | 0.698 | — | — |
| `PCK@5px` | 0.747 | 0.744 | — | — |
| `vis_Prec` | 0.983 | 0.993 | — | — |
| `vis_Rec` | 0.996 | 0.991 | — | — |
| `vis_FP` | 14 | 6 | — | — |
| `vis_FN` | 3 | 7 | — | — |
| `Global MPE (px)` | 1.163 | 1.124 | — | — |
| `Global FP rate (%)` | 5.20 | 2.23 | — | — |
| `Global FN rate (%)` | 0.37 | 0.86 | — | — |
| `TD (px/frame)` | 1.169 | 1.100 | — | — |
| `CR_frame (%)` | 15.0 | 10.8 | — | — |
| `CR_kp (%)` | 1.7 | 1.2 | — | — |
| | | | | |
| **— TRAIN METRICS —** | | | | |
| `avg_dist (px)` | 1.137 | 1.029 | — | — |
| `p50 (px)` | 1.063 | 1.009 | — | — |
| `p90 (px)` | 1.816 | 1.640 | — | — |
| `p95 (px)` | 2.092 | 1.826 | — | — |
| `mPCK` | 0.660 | 0.668 | — | — |
| `PCK@5px` | 0.703 | 0.706 | — | — |
| `vis_Prec` | 0.989 | 0.998 | — | — |
| `vis_Rec` | 0.996 | 0.999 | — | — |
| `vis_FP` | 55 | 9 | — | — |
| `vis_FN` | 19 | 6 | — | — |
| `Global FP rate (%)` | 2.59 | 1.18 | — | — |
| `Global FN rate (%)` | 0.83 | 0.10 | — | — |
| `TD (px/frame)` | 15.448 | 15.617 | — | — |
| `CR_frame (%)` | 8.4 | 3.9 | — | — |
| `CR_kp (%)` | 1.4 | 0.4 | — | — |

> Note: TRAIN TD is meaningless (shuffled data, no temporal order). Only VAL TD is interpretable.
> Note: mOKS/mAP/mAR show nan for R1 — likely a .npz key mismatch in Step 8; raw values from training log: mOKS≈0.914 (train), 0.919 (val).

---

## Per-Keypoint VAL Detail — R1 (UNet64)

| Keypoint | MPE (px) | FP% | FN% | TD (px/fr) | CR_kp% | TP | FP | FN | TN | n_contact | n_airborne |
|----------|----------|-----|-----|-----------|--------|----|----|----|----|-----------|------------|
| head | 1.253 | — | 0.00 | 2.701 | 0.0 | 120 | 0 | 0 | 0 | 120 | 0 |
| thorax | 1.147 | — | 0.00 | 2.564 | 0.0 | 120 | 0 | 0 | 0 | 120 | 0 |
| abdomen | 1.362 | — | 0.00 | 2.576 | 0.0 | 120 | 0 | 0 | 0 | 120 | 0 |
| forelegR | 1.015 | 0.00 | 0.00 | 0.292 | 0.0 | 76 | 0 | 0 | 44 | 76 | 44 |
| forelegL | 1.384 | 11.36 | 0.00 | 0.535 | 4.2 | 76 | 5 | 0 | 39 | 76 | 44 |
| midlegR | 1.165 | 0.00 | 1.20 | 0.328 | 0.8 | 82 | 0 | 1 | 37 | 83 | 37 |
| midlegL | 0.968 | 2.94 | 2.33 | 0.525 | 3.3 | 84 | 1 | 2 | 33 | 86 | 34 |
| hindlegR | 1.018 | 5.77 | 0.00 | 0.396 | 2.5 | 68 | 3 | 0 | 49 | 68 | 52 |
| hindlegL | 1.154 | 8.62 | 0.00 | 0.607 | 4.2 | 62 | 5 | 0 | 53 | 62 | 58 |

---

## Notes per Run

**R1 — UNet64, scratch, aug=True**
- Checkpoint: `models/drosophila_unet64_setB_260407_092817/`
- Best epoch 59/81 — healthy early stopping, low overfitting (ratio=1.257)
- FP concentrated on forelegL (5) and hindlegL (5) — left hind legs harder to distinguish
- All body keypoints (head/thorax/abdomen) perfect FP/FN=0, expected (always visible in FTIR)

**R3 — ConvNeXt-tiny, ImageNet pretrained, aug=True**
- Checkpoint: `models/drosophila_convnext_pt_setB_260408_085648/`
- 215 min training (4.5× longer than R1), 87.5M params (17× more)
- val/train ratio=2.215 — more overfitting than R1 on 755 frames
- Marginally better avg_dist (1.148 vs 1.178 px, Δ=0.03px) — negligible
- Better FP (6 vs 14) but worse FN (7 vs 3) — more conservative on contact detection
- Better CR_frame (10.8% vs 15.0%) and CR_kp (1.2% vs 1.7%)

> ⚠️ R2 (ConvNeXt scratch) was skipped — jumped from R1 to R3. Add if needed.

---

## Phase 1 Status

| Run | Config | Status | val avg_dist | CR_frame% | Notes |
|-----|--------|--------|-------------|-----------|-------|
| R1 | UNet64, scratch | ✅ Done | 1.178 px | 15.0% | 🏆 Current best (efficiency) |
| R2 | ConvNeXt-tiny, scratch | ⏭️ Skipped | — | — | — |
| R3 | ConvNeXt-tiny, pretrained | ✅ Done | 1.148 px | 10.8% | Marginal gain, 4.5× cost |
| R4 | SwinT-tiny, scratch | 📋 Next | — | — | — |
| R5 | SwinT-tiny, pretrained | 📋 Next | — | — | — |

**Interim verdict:** UNet64 wins on efficiency. ConvNeXt-pt gives 0.03px better localisation and better CR_frame (10.8% vs 15.0%) but at 4.5× training cost and 17× parameters. SwinT runs will determine final Phase 1 winner.

---

## Change Log

| Date | Change |
|------|--------|
| 2026-04-07 | File created. R1 partial results recorded. |
| 2026-04-08 | R3 (ConvNeXt pretrained) results added. |
| 2026-04-10 | R1 full metrics filled in from Step 8 re-run. Per-keypoint VAL table added. |
