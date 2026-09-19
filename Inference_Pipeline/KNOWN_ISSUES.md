# Known Issues & Reference Notes

Working notes for the pipeline codebase, not thesis content. Found during the Chapter 3 fact-check pass (2026-08-04).

---

## Bug: per-video `distcal` gets overwritten before Phase 9 writes it

**Where:** `Inference_Pipeline/Bulk_Pipeline.ipynb`, Phase 8 ("Extract Tracks") and Phase 9 ("Write MATLAB Data") cells.

**What's happening:** `DISTCAL` is a single global variable, recomputed on every iteration of Phase 8's per-video loop from `DISTCAL_MAP.get(VFN, default)`. Phase 9 runs as a *separate* loop afterward, and writes `p_dict['distcal'] = np.array([[DISTCAL]])` using whatever `DISTCAL` happens to be left over once Phase 8's loop has already finished for every video.

**Impact:** in a batch run of more than one video where different videos have different `DISTCAL_MAP` overrides, every video's `TRACKS.mat` ends up with the *last processed video's* calibration value, not its own. Silent, no error raised. Only matters when a batch mixes videos with different per-video distcal overrides; a batch using the same value (or all defaults) for every video is unaffected.

**Fix applied:** Phase 8 now records each video's calibration alongside its results
(`_phase6_results[VFN]['distcal'] = DISTCAL`), and Phase 9 reads `np.array([[r['distcal']]])`
instead of the shared global.

**Status:** FIXED 2026-09-06. Verified by simulating a two-video batch with different
`DISTCAL_MAP` overrides (68.7 and 55.0 µm/px): before the fix both videos were written
0.018182 px/µm; after it each receives its own (0.014556 and 0.018182).

`fps` does not have this problem since it's intentionally a single global value for the whole batch (no per-video fps mechanism exists at all, unlike distcal).

---

## Pipeline phase names: thesis text vs. actual code

The thesis (`Thesis_Report/Drafts/chapter3_prose.md`) uses slightly different phase names than the ones printed by the actual pipeline (`Bulk_Pipeline.ipynb` cell headers / `gui/pages/1_Bulk_Pipeline.py` section banners). Keeping this table here since the code names may change in the future and the thesis will need to be re-synced whenever that happens.

| # | Name used in thesis (chapter3_prose.md) | Real name in code | Source |
|---|---|---|---|
| 1 | Background Subtraction | Raw Video Processing | `Bulk_Pipeline.ipynb:144`, `1_Bulk_Pipeline.py:194` |
| 2 | Video Export | Video Export | matches |
| 3 | DL Model Inference | Pose Estimation | `1_Bulk_Pipeline.py:194` ("DL Model Inference" is actually the *Section 1* title, not Phase 3's own name) |
| 4 | Manual Correction (SLEAP GUI) | Open SLEAP GUIs | `Bulk_Pipeline.ipynb:396` |
| 5 | Trim Frames | Trim Frames | matches |
| 6 | Pre-flight Validation | FlyWalker Pre-flight Validation | `Bulk_Pipeline.ipynb:554` |
| 7 | Predictions Analysis Export | Export Labels | `Bulk_Pipeline.ipynb:850` |
| 8 | Parameter Calculation | Extract Tracks | `Bulk_Pipeline.ipynb` cell 16 header |
| 9 | TRACKS.mat Assembly | Write MATLAB Data | `Bulk_Pipeline.ipynb:880` |
| 10 | FlyWalker Analysis | FlyWalker Analysis | matches |

Three-section grouping (Phases 1-3 / 4-6 / 7-10) matches the GUI's own `section_banner` calls (`1_Bulk_Pipeline.py:193,276,499`), so that part of the thesis's structure is accurate even where individual phase names drift.
