r"""
embed_frames.py
---------------
Re-saves .pkg.slp files with video frames embedded (embed=True).
Run in your SLEAP conda environment:

    Anaconda Prompt:
        conda activate sleap
        cd "<project>\SLEAP_Training"
        python embed_frames.py

Output files are saved alongside the originals with '_embedded' suffix.
Upload the _embedded files to MyDrive/sleap/ replacing the originals.
"""

import os
import sleap_io as sio

# ── Files to embed ────────────────────────────────────────────────────────────
BASE = os.path.dirname(os.path.abspath(__file__))

FILES = [
    "Drosophila_TRAIN_set_setB.pkg.slp",
    "Drosophila_VAL_set_setB.pkg.slp",
]
# ─────────────────────────────────────────────────────────────────────────────

for fname in FILES:
    src = os.path.join(BASE, fname)
    dst = os.path.join(BASE, fname.replace(".pkg.slp", "_embedded.pkg.slp"))

    if not os.path.exists(src):
        print(f"[SKIP] Not found: {src}")
        continue

    print(f"\nLoading  : {fname}")
    labels = sio.load_slp(src)
    print(f"  Frames : {len(labels)} labeled frames")
    print(f"  Videos : {[v.filename for v in labels.videos]}")

    print(f"Embedding: {dst}")
    sio.save_slp(labels, dst, embed=True)

    size_mb = os.path.getsize(dst) / 1e6
    print(f"  Done   : {size_mb:.1f} MB  ← should be >> original if frames embedded")

print("\nAll done. Upload the _embedded files to MyDrive/sleap/")
print("Rename them to remove '_embedded' so the notebook paths still work.")
