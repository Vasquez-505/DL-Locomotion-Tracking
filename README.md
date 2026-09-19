# DL Locomotion Tracking

Deep learning pose estimation for *Drosophila melanogaster* ground-contact leg
tracking from FTIR high-speed video, replacing the auto-detection step in the
MATLAB **FlyWalker** gait analysis software.

MSc thesis project (Mechanical Engineering, Design of Mechatronic Systems,
IST Lisboa), supervised by Prof. Rui Moura Coelho (IST) and Prof. César Mendes
(NOVA Medical School).

## Background

FTIR (frustrated total internal reflection) illumination makes a fly's legs
visible only while they are physically touching the glass surface underneath
it; legs in the air are invisible in the footage. The model's job is
therefore not to track all six legs at all times, but to detect **which**
legs are currently in contact with the ground and **where**. A missing
keypoint prediction is a real airborne leg, not a labelling gap.

## Pipeline

```
raw video → background subtraction → DL model inference → SLEAP correction → FlyWalker analysis
```

1. **Preprocessing** — background-subtracted, hot-colourmap `.avi` video (250 FPS)
2. **Inference** — a trained pose model predicts (x, y) ground-contact positions per frame, for whichever legs are touching
3. **Correction** — predictions are loaded into [SLEAP](https://sleap.ai/) for visual inspection and manual correction
4. **Export** — corrected labels are converted into a `TRACKS.mat` file and analysed by the existing FlyWalker MATLAB scripts

Two model families are implemented:

- **SLEAP-NN** (primary) — single-instance pose models (UNet, ConvNeXt, SwinT
  backbones, with/without ImageNet pretraining) trained via
  [`sleap-nn`](https://github.com/talmolab/sleap-nn)
- **ADPT** (secondary, thesis reference) — a custom ResNet-50 + Transformer
  architecture based on Tang et al., *eLife* 2025, implemented in PyTorch

The best-performing model to date is a pretrained ConvNeXt-tiny SLEAP-NN
model (test set mean position error ≈1.4 px on a 9-keypoint skeleton: head,
thorax, abdomen, and six leg tips).

## Repository layout

| Path | Contents |
|---|---|
| `gui/` | Streamlit app (Bulk Pipeline + Active Learning workflows) |
| `Inference_Pipeline/` | Dataset, trained models, inference/training notebooks |
| `SLEAP_Dataset_Utils/` | Standalone scripts for scaling/relinking `.slp` label files and embedding frames for Colab |

## Setup

Requires Python 3.10+ with a conda environment containing at minimum:

```
streamlit  sleap-nn  sleap-io  torch  torchvision  opencv-python
h5py  scipy  imageio[ffmpeg]  pillow  pandas  numpy  pyyaml
```

Model training and fine-tuning run on Google Colab (see the notebooks in
`Inference_Pipeline/`); local inference and the GUI can run on CPU.

## Running the GUI

```bash
streamlit run gui/app.py
```

On Windows, `launch_gui.bat` locates a conda environment with Streamlit
installed and launches the app automatically.

The GUI has two pages:

- **Bulk Pipeline** — runs preprocessing, inference, and FlyWalker export
  end-to-end for a batch of videos, plus an annotated-video overlay for
  visual QC of predictions
- **Active Learning** — merges corrected SLEAP labels back into the training
  set and fine-tunes a model from its best checkpoint (locally or via Colab)

## Status

Actively developed as part of an ongoing thesis. See commit history for
current progress; model checkpoints and evaluation metrics live under
`Inference_Pipeline/Models/SLEAP_Models/`.
