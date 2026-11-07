# macOS setup and port notes

Tested on an Apple Silicon Mac (M5 Pro, macOS 26.4) with MATLAB R2025b.
All changes are cross-platform: Windows behaviour is unchanged.

## 1. Setup

```bash
# Python environment (uv; conda works the same way)
uv venv -p 3.11 ~/.venvs/flytrack
uv pip install --python ~/.venvs/flytrack/bin/python --override <(echo "sleap-io==0.9.2") \
  torch==2.11.0 torchvision==0.26.0 sleap-nn==0.3.1 sleap-io==0.9.2 sleap==1.6.2 \
  h5py==3.16.0 pandas==3.0.2 matplotlib==3.10.8 psutil==7.0.0 PyYAML==6.0.2 \
  opencv-python==4.13.0.92 scipy==1.17.1 streamlit==1.56.0 "imageio[ffmpeg]" pillow
```

`--override` is needed because `sleap==1.6.2` declares `sleap-io<0.7`, while the
checkpoints need `sleap-io 0.9.2` (pip only warns; uv refuses without it).

Launch: double-click `launch_gui.command` (or `FLYTRACK_ENV=/path/to/env ./launch_gui.command`).

Data moved from Windows: on the GUI Home page, run **Scan .slp files → fix** once,
so `.slp` files point to the local `Videos/` folder.

## 2. Code changes

| File | Change | Why |
|---|---|---|
| `launch_gui.command` (new) | Activates `~/.venvs/flytrack`, runs Streamlit | `launch_gui.bat` is Windows-only |
| `.gitattributes` (new) | `*.command eol=lf` | A CRLF checkout would break the shell script |
| `Bulk_Pipeline.ipynb` Phase 4, `Active_Learning.ipynb` Step 3b | Look for `sleap-label` next to `sys.executable` first | Only `Scripts\*.exe` was checked |
| `Bulk_Pipeline.ipynb` Phase 7 | Same for `sleap-convert` | Same |
| `Bulk_Pipeline.ipynb` Phase 10 | Also search `/Applications/MATLAB_*.app/bin/matlab`; use `-batch` off Windows | Only `C:\Program Files` was searched; `-wait` is Windows-only |
| `Bulk_Pipeline.ipynb` Phase 11 | macOS font paths (Arial, Helvetica) | Fonts were read from `%WINDIR%` only |
| `gui/lib/nb_utils.py` `_ev_find_sleap_py` | Return `sys.executable` when it imports `sleap_nn` | Built a `python.exe` path (wrong on macOS) |
| `Active_Learning.ipynb` Step 6 | Same interpreter fix | Same |
| `Active_Learning.ipynb` Steps 4/5/6, `inference.py` | Accelerator/device `mps` when no CUDA | Use the Apple GPU instead of CPU |
| `FlyWalker_Results_Gen/+xlsxshim/` (new) + `EvaluateFlyTable_activex_hexa.m` | Off Windows, `actxserver` is replaced by a small stand-in that records the same calls and writes `.xlsx` directly (formulas kept, recalculated on open); paths use `filesep` | Excel COM is Windows-only: the old fallback lost 10 of 20 sheets and the trajectory plot |

## 3. Bugs fixed along the way (affect Windows too)

- `nb_utils.fix_slp_paths` silently **truncated** `videos_json` when the new path was
  longer than the old one (fixed-width HDF5 string), corrupting the `.slp`. It now
  widens the dataset and verifies the result.
- "Evaluate selected model" (Active Learning page) evaluated the model in
  `.al_run_state.json` instead of the selected one. The state header is now skipped.

## 4. Known differences / limits

- `ResultSummary.xlsx` on macOS has no font colours. Formula cells have no cached
  values until opened in Excel/Numbers. Decimal strings that the Windows (comma-decimal)
  locale kept as text are written as numbers.
- FlyWalker can still stop on some videos (e.g. Fly1.2, `EvaluateFlyTable_activex_hexa.m`
  line 1568). Same on Windows; Phase 6 pre-flight warns about it.
- Model evaluation inference runs with `--device cpu` (hard-coded, as on Windows).
