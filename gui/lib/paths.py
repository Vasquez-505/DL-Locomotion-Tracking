"""Central path resolution for the GUI.

Layout:
    Model_Design_&_Training/
        gui/           ← GUI_DIR  (this file lives in gui/lib/)
        Inference_Pipeline/  ← NB_DIR  (where the notebooks live)
"""
from pathlib import Path

_HERE = Path(__file__).resolve()
GUI_DIR = _HERE.parent.parent        # .../gui/
ROOT_DIR = GUI_DIR.parent            # .../Model_Design_&_Training/
NB_DIR = ROOT_DIR / "Inference_Pipeline"

BULK_NB = NB_DIR / "Bulk_Pipeline.ipynb"
AL_NB = NB_DIR / "Active_Learning.ipynb"
