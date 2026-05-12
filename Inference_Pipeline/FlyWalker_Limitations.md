# FlyWalker Limitations

Software: FlyWalker (Mendes et al., eLife 2013)  
MATLAB script: `EvaluateFlyTable_activex_hexa.m`

---

## 1. Crashes with 1 or 2 simultaneous leg contacts

**What happens:** FlyWalker crashes with `Index in position 1 exceeds array bounds` during the triangle-plotting section.

**Why:** The polygon-building code only handles 3 contacts (tripod triangle) or 4 contacts (tetrapod quadrilateral). Frames with exactly 1 or 2 legs touching have no handler — the code tries to index a 3-element array from a 1- or 2-element input and crashes.

**Is the data wrong?** No. At 250 FPS, gait transition frames (the brief moment between one tripod stance and the next) are always captured and show 1–2 legs in contact. This is real biology. FlyWalker was designed/tested at lower frame rates where these transitions fall between frames and are never seen.

**Outputs affected:**
- Support polygon plots — NOT produced
- Tripod/tetrapod stance phase diagrams — NOT produced
- Any result depending on frame-by-frame polygon geometry — NOT produced

**Outputs still produced** (before the crash):
- Step distance, step speed, duty cycle (from "Calculating step distances" section)

**Fix:** Would require adding an `if n_contacts >= 3` guard in FlyWalker's triangle-plotting loop. Not done — data is correct, this is a FlyWalker limitation.

---

## 2. Minimum contact event length — `p.minframe = 2`

**What happens:** Contact events shorter than 2 consecutive frames are silently discarded before any analysis.

**Where:** `Parameters.m`, line `p.minframe = 2`.

**Impact:** A leg that touches for only 1 frame is treated as if it never touched. This is intentional FlyWalker behaviour (noise filtering), but means very brief contacts are invisible to all downstream metrics.

> **Pipeline note:** The `minframe` field in TRACKS.mat must match this value (`2.0`). An earlier bug in Phase 7 of the pipeline was writing `3.0` instead of `2.0`, causing FlyWalker to discard more events than intended and triggering downstream crashes. Fixed in the current pipeline.

---

## 3. Minimum usable contact events per leg — 4 events required

**What happens:** FlyWalker crashes with index-out-of-bounds if any leg has fewer than 4 surviving contact events (after the `minframe` filter).

**Why (two crash sites):**
- `calculate_stc_trc_cluster.m` — clustering code references `min_steps = 3` but allocates step-interval arrays of size `n_events - 1`. With exactly 3 events → 2 intervals; if any downstream code accesses a 3rd interval it crashes with `Index must not exceed 2`.
- Step distance calculation — same root cause: 3 events → 2 intervals, code assumes ≥ 3.

No try/catch anywhere — crash halts the entire script with zero outputs.

**Result if crashed:** Zero outputs — no graphs, no `ResultSummary.xlsx`.

**Pre-flight check (Phase 4.5):** Uses `MIN_STEPS = 4`. If any leg has < 4 usable events, the video is flagged `NOT READY`.

**Fix:** Add more labeled contact frames for the failing leg (≥ 2 consecutive frames per event, ≥ 4 events total surviving the `minframe` filter).

---

## 4. No error recovery — crash = zero outputs

FlyWalker has no try/catch wrappers around its analysis sections. Any runtime error (array bounds, missing field, etc.) immediately halts MATLAB execution. When FlyWalker crashes, **no output files are written** — not even partial results up to the crash point, because most write operations happen at the very end.

---

## 5. Headless MATLAB launch on Windows

FlyWalker cannot be reliably launched headlessly from Python on Windows:

- `matlab -batch` → MathWorks online license check error 5201
- `matlab -nosplash -nodesktop -r` → silent crash, exit code 1

**Workaround (Phase 8):** The pipeline writes `_run_flywalker.m` to `Predictions/{VIDEO_FOLDER_NAME}/` and attempts both headless modes. If both fail, open MATLAB manually and run:
```matlab
run('C:/.../Predictions/{VIDEO_FOLDER_NAME}/_run_flywalker.m')
```
