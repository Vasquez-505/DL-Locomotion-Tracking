"""
create_scaled_slp.py — Cria ficheiros .slp com coordenadas escaladas para os
Sets B / C / D, actualizando as referências de vídeo para as pastas correctas.

Os ficheiros originais (.slp) têm coordenadas na resolução NOVA (~1.46× original).
Este script cria cópias com coordenadas escaladas por 1/1.46 e com os paths dos
vídeos actualizados — prontos para abrir no GUI do SLEAP e verificar visualmente
o alinhamento dos keypoints com a mosca.

Saída (na mesma pasta dos .slp originais):
    Drosophila_TRAIN_set_setB.slp
    Drosophila_VAL_set_setB.slp
    Drosophila_TEST_set_setB.slp
    Drosophila_TRAIN_set_setC.slp   (mesmas coords que B, vídeos diferentes)
    ...
    Drosophila_TRAIN_set_setD.slp
    ...

Usage:
    py create_scaled_slp.py              # cria todos os sets (B, C, D)
    py create_scaled_slp.py --sets B D   # apenas sets B e D
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
from pathlib import Path

import h5py
import numpy as np

# ── Config ────────────────────────────────────────────────────────────────────

PROJ_DIR       = Path(__file__).parent
COORD_SCALE    = 1.0 / 1.46   # labels em resolução NOVA → resolução original
ALIGN_BODY_AXIS = True         # thorax → midpoint(head, abdomen) after scaling

# Keypoint indices (must match dataset.py)
KP_HEAD    = 0
KP_THORAX  = 1
KP_ABDOMEN = 2

SET_CONFIG = {
    "B": PROJ_DIR / "Videos" / "PROCESSED_Colormap_Videos",
    "C": PROJ_DIR / "Videos" / "PROCESSED_NO_Colormap_Videos",
    "D": PROJ_DIR / "Videos" / "RAW_Videos",
}

SLP_FILES = [
    PROJ_DIR / "Drosophila_TRAIN_set.slp",
    PROJ_DIR / "Drosophila_VAL_set.slp",
    PROJ_DIR / "Drosophila_TEST_set.slp",
]

# ── Helpers ───────────────────────────────────────────────────────────────────

def _update_video_json(raw_bytes: bytes, new_video_dir: Path) -> bytes:
    """
    Parse the JSON video entry, update the filename to point to new_video_dir,
    and return the re-encoded bytes (same length padding with spaces if needed).
    """
    text = raw_bytes.decode("utf-8", errors="replace").rstrip("\x00")
    obj  = json.loads(text)

    # Filename is at the top level; path is stored inside backend too
    old_name = os.path.basename(obj.get("filename", ""))
    new_path = str(new_video_dir / old_name)

    obj["filename"] = new_path
    if "backend" in obj and "filename" in obj["backend"]:
        obj["backend"]["filename"] = new_path

    new_text  = json.dumps(obj, separators=(",", ":"))
    new_bytes = new_text.encode("utf-8")
    # h5py variable-length strings don't need padding, but fixed-length do.
    # Return as bytes; h5py will handle the dtype.
    return new_bytes


def create_scaled_slp(
    src_slp:       Path,
    dst_slp:       Path,
    new_video_dir: Path,
    coord_scale:   float,
) -> None:
    """
    Copy src_slp to dst_slp, then:
      - Scale all x, y coordinates by coord_scale
      - Update videos_json entries to point to new_video_dir
    """
    shutil.copy2(src_slp, dst_slp)

    with h5py.File(dst_slp, "r+") as f:

        # ── Scale keypoint coordinates ────────────────────────────────────────
        pts = f["points"]   # compound dataset — fields: x, y, visible, complete

        # h5py compound datasets: read as structured numpy array, modify, write back
        data = pts[:]   # numpy structured array

        # Fields are named; check available names
        x_field = "x" if "x" in data.dtype.names else data.dtype.names[0]
        y_field = "y" if "y" in data.dtype.names else data.dtype.names[1]

        data[x_field] = (data[x_field].astype(np.float64) * coord_scale)
        data[y_field] = (data[y_field].astype(np.float64) * coord_scale)

        # ── Align body axis: thorax = midpoint(head, abdomen) ─────────────────
        if ALIGN_BODY_AXIS:
            instances_ds = f["instances"][:]
            for inst in instances_ds:
                pid_start = int(inst["point_id_start"])
                # Each instance has 9 keypoints starting at pid_start
                i_head    = pid_start + KP_HEAD
                i_thorax  = pid_start + KP_THORAX
                i_abdomen = pid_start + KP_ABDOMEN
                # Only apply if both head and abdomen are visible
                if data["visible"][i_head] and data["visible"][i_abdomen]:
                    data[x_field][i_thorax] = (data[x_field][i_head] + data[x_field][i_abdomen]) / 2.0
                    data[y_field][i_thorax] = (data[y_field][i_head] + data[y_field][i_abdomen]) / 2.0

        pts[...] = data

        # ── Update video paths in videos_json ─────────────────────────────────
        vj = f["videos_json"]
        updated = []
        for entry in vj[:]:
            if isinstance(entry, bytes):
                updated.append(_update_video_json(entry, new_video_dir))
            else:
                updated.append(_update_video_json(entry.encode("utf-8"), new_video_dir))

        # Overwrite with updated entries (variable-length strings)
        dt = h5py.string_dtype(encoding="utf-8")
        del f["videos_json"]
        f.create_dataset("videos_json", data=[u if isinstance(u, bytes) else u.encode() for u in updated], dtype=dt)

    print(f"  {src_slp.name}  ->  {dst_slp.name}   (scale={coord_scale:.4f}, dir={new_video_dir.name})")


# ── Main ──────────────────────────────────────────────────────────────────────

def main(sets: list[str]) -> None:
    for set_id in sets:
        video_dir = SET_CONFIG[set_id]
        if not video_dir.exists():
            print(f"[SKIP] Set {set_id}: video dir not found: {video_dir}")
            continue

        print(f"\nCreating Set {set_id} labels (coord_scale={COORD_SCALE:.4f}):")
        for src in SLP_FILES:
            if not src.exists():
                print(f"  [SKIP] {src.name} not found")
                continue
            stem    = src.stem                            # e.g. "Drosophila_TRAIN_set"
            out_dir = PROJ_DIR / ".slp Verification Datasets"
            out_dir.mkdir(exist_ok=True)
            dst     = out_dir / f"{stem}_set{set_id}.slp"
            create_scaled_slp(src, dst, video_dir, COORD_SCALE)

    print("\nDone.")
    print("Open the generated .slp files in the SLEAP GUI to verify keypoint alignment.")
    print("The videos referenced inside each .slp point to the correct folder for that set.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create scaled .slp files for Sets B/C/D")
    parser.add_argument(
        "--sets", nargs="+", choices=["B", "C", "D"], default=["B", "C", "D"],
        help="Which sets to generate (default: B C D)"
    )
    args = parser.parse_args()
    main(args.sets)
