# SLEAP Dataset Utils

Two standalone helper scripts for preparing `.slp` label files outside the main
GUI/notebook pipeline. Both operate on the SLEAP HDF5 format directly (via
`h5py` or `sleap_io`), not through `sleap-nn`.

## `create_scaled_slp.py`

Copies a `.slp` file's coordinates scaled by a fixed factor (default `1/1.46`,
correcting for the NOVA-resolution vs. Set B/C/D resolution difference — see
`DISTCAL` in `CLAUDE.md`) and rewrites its embedded `videos_json` to point at
a different video folder. Useful for re-checking keypoint alignment in the
SLEAP GUI after switching which video set a label file should reference,
without touching the original file.

```bash
py create_scaled_slp.py              # all sets (B, C, D)
py create_scaled_slp.py --sets B D   # only the sets listed
```

Output lands in a new `.slp Verification Datasets/` folder next to the source
files.

## `embed_frames.py`

Re-saves `.pkg.slp` files with video frames embedded (`embed=True`), producing
a `_embedded.pkg.slp` copy. Colab can't read local video files, so any `.slp`
uploaded there for training or fine-tuning needs its frames embedded first.
Run from inside the `sleap` conda environment:

```bash
conda activate sleap
python embed_frames.py
```

Edit the `FILES` list at the top of the script to point at whichever
`.pkg.slp` files need embedding before a Colab upload.
