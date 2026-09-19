# GUI + Pipeline — Improvement Plan

Items are numbered to match the discussion order.
Phase column: D = diagnosis only, F = fix required, A = new addition.

---

## 1. Session persistence of TRAIN / VAL / TEST paths  [D → resolved]

**Status: working correctly.**
`gui/lib/persistence.py` saves `al_orig_train`, `al_orig_val`, `al_orig_test` to `.gui_state.json`
alongside the other persisted keys. Values survive page close and browser restart.

---

## 2. Distcal bug — per-video calibration not written correctly  [F]

**Status: FIXED 2026-09-06.** Both edits below applied to `Bulk_Pipeline.ipynb`; verified that
the GUI-generated `bulk_section3_script` inherits them and that a mixed-calibration two-video
batch now writes each video's own value.

Phase 8 (extract tracks, `Bulk_Pipeline.ipynb` cell "Phase 8 --") computes `DISTCAL` inside a
`for VFN in VIDEO_FOLDER_NAMES_ANA` loop but never stores it in `_phase6_results[VFN]`.
Phase 9 (write TRACKS.mat) then reads the bare global `DISTCAL`, which holds the value from
the **last video** in the loop. For multi-video batches every video gets that last video's
distcal value, not its own.

**Fix (notebook):**
- End of Phase 8 loop: `_phase6_results[VFN]['distcal'] = DISTCAL`
- Phase 9: replace `np.array([[DISTCAL]])` with `np.array([[r['distcal']]])`

The same logic change must be verified in the GUI-generated script (via `bulk_section3_script`
in `nb_utils.py`) — the script is built from these same notebook cells, so fixing the notebook
fixes the script automatically.

---

## 3. Active Learning page — full path review  [F / verify]

Check both training paths end-to-end:

**3a. Local training path**
- Step 1: verify corrected labels (auto-patch SLP)
- Step 2: merge datasets + embed frames
- Step 3: build fine-tune config YAML
- Step 4: run local fine-tune (Active_Learning.ipynb)
- Step 5: evaluate new model
- Verify all `al_step*_script()` builders in `nb_utils.py` produce correct output.
- Verify dataset paths (`al_orig_train`, `al_orig_val`, `al_orig_test`) flow through correctly.

**3b. Colab training path**
- Verify colab upload cell / `colab_config.json` generation is up to date.
- Verify frame embedding step is triggered when needed.
- Confirm the Colab notebook cells referenced by `nb_utils.py` still exist and match expected
  cell markers.

---

## 4. Results / metrics — code review for currency  [F / verify]

- Confirm CR_kp is the primary metric shown everywhere (TD removed from all outputs).
- Verify `_ev_compute_custom()` in `nb_utils.py` matches the current metric definitions:
  MPE (visible kp only), global FP/FN (not per-kp nanmean), CR_kp (τ=5px), CR_frame.
- Check that eval runs against all three splits (TRAIN / VAL / TEST) correctly.
- Confirm `eval_metrics_summary.csv` and `per_keypoint_metrics_*.csv` are written with the
  right columns for the Inspect panel display.

---

## 5. New feature: prediction overlay video  [A]

Generate an annotated video file showing model predictions overlaid on the fly footage.

**Proposed design:**
- New phase (Phase 3.6 or standalone) in the Bulk Pipeline.
- Input: `*.predictions.slp` + the Set B AVI video for that folder.
- Output: `{VFN}_annotated.mp4` in `Predictions/{VFN}/`.
- Rendering: read each frame from the AVI, draw keypoint dots (colour-coded by keypoint type,
  invisible kp skipped) and skeleton edges on the frame, write to output video with OpenCV or
  imageio.
- Skeleton colour scheme: body kp (head/thorax/abdomen) in one colour, leg kp in another;
  consider a brief legend overlaid in the first N frames.
- GUI control: checkbox "Generate annotated video" in the Bulk Pipeline sidebar.

**Feasibility:** `sleap-nn` predictions are in `.slp` (HDF5); the video is a standard AVI.
Both are readable with existing dependencies (h5py, OpenCV via `cv2` or imageio+ffmpeg).
This is self-contained and does not block any other phase.

---

## 6. Code review, simplification, and comment humanisation  [F]

**Scope:** `gui/pages/1_Bulk_Pipeline.py`, `gui/pages/2_Active_Learning.py`,
`gui/lib/nb_utils.py`, `gui/lib/persistence.py`, `gui/lib/runner.py`, `gui/lib/paths.py`.

**Tasks:**
- Remove dead code (unused functions, commented-out blocks that are no longer relevant).
- Simplify over-complex flows (e.g. redundant state checks, duplicate logic between pages).
- Replace AI-style comments (over-explained, redundant, or "what" instead of "why") with
  concise, human-sounding notes where a comment is actually needed.
- Run through the humanizer checklist: no em dashes, no inline-header lists, no "ensures X",
  no sycophantic phrasing in user-facing strings.
- Use the `code-simplifier` agent for a systematic pass after the manual review.

---

## 7. Easy installer for handover  [A]

Make the project straightforward for a new person to install and run.

**Tasks:**
- Audit `Inference_Pipeline/Installation_requirements.txt` — confirm it matches actual imports.
- Write or update a top-level `README.md` with: prerequisites (Python version, CUDA optional),
  install steps, how to launch the GUI, how to point it at videos.
- Consider a `setup.bat` (Windows) that: creates a venv, installs requirements, and launches
  the GUI — one double-click to start.
- Verify the GUI's `launch_gui.bat` still works after any code changes.
- Document any MATLAB dependency (Phase 10 / FlyWalker) and the workaround for headless failure.

---

## Execution order

| # | Item                              | Phase    | Depends on |
|---|-----------------------------------|----------|------------|
| 2 | Distcal bug fix                   | Fix now  | —          |
| 3 | AL page full review               | Next     | —          |
| 4 | Metrics code currency check       | Next     | —          |
| 5 | Annotated video feature           | After 3  | —          |
| 6 | Code review + humanisation        | After 5  | 2,3,4,5    |
| 7 | Installer / handover docs         | Last     | 6          |
| 1 | ~~Session persistence~~           | Done     | —          |
