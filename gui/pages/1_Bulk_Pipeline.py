from __future__ import annotations
import html as _html
import sys
from pathlib import Path
import streamlit as st

# ── path setup ────────────────────────────────────────────────────────────────
_GUI = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(_GUI))

from lib.paths import NB_DIR, BULK_NB
from lib.runner import StreamingSubprocess
from lib import nb_utils
from lib.styles_v2 import (
    inject, inject_stop_style, status_dot, section_banner, phase_label,
    PURPLE, TEAL, GREEN, MUTED, TEXT, BORDER, SURFACE, log_to_html,
)
from lib.persistence import load as _load_state, save as _save_state

inject()
inject_stop_style()
_load_state(st.session_state)

st.markdown(
    f'<h2 style="margin-bottom:2px;color:{TEXT}">Bulk Inference &amp; FlyWalker Pipeline</h2>'
    f'<p style="color:{MUTED};font-size:0.85em;margin-bottom:6px">'
    f'Run the three sections in order — each streams live output below.</p>',
    unsafe_allow_html=True,
)

if not BULK_NB.exists():
    st.error(f"Notebook not found: `{BULK_NB}`")
    st.stop()

# ── state helpers ─────────────────────────────────────────────────────────────

def _state(key, default=None):
    return st.session_state.get(f"bp_{key}", default)


def _set(key, val):
    st.session_state[f"bp_{key}"] = val


def render_log(key):
    lines = _state(f"{key}_log", [])
    text = "\n".join(lines) if lines else "(no output yet)"
    st.markdown(
        f'<div class="log-box">{log_to_html(text)}</div>',
        unsafe_allow_html=True,
    )


def start_phase(key: str, script_path: Path):
    _set(f"{key}_log", [])
    _set(f"{key}_status", "running")
    proc = StreamingSubprocess(
        [sys.executable, "-u", str(script_path)],
        cwd=str(NB_DIR),
    )
    proc.start()
    _set(f"{key}_proc", proc)


def stop_phase(key: str):
    proc = _state(f"{key}_proc")
    if proc is not None:
        proc.terminate()
    _set(f"{key}_status", "idle")
    _set(f"{key}_proc", None)


# ── fragment polling ──────────────────────────────────────────────────────────

def _poll_inner(key: str):
    proc = _state(f"{key}_proc")
    if proc is not None:
        new_lines = proc.drain()
        if new_lines:
            log = _state(f"{key}_log", [])
            log.extend(new_lines)
            _set(f"{key}_log", log)

    render_log(key)

    if proc is not None and proc.done:
        _set(f"{key}_status", "success" if proc.returncode == 0 else "error")
        _set(f"{key}_proc", None)
        st.rerun()


@st.fragment(run_every=1.0)
def _s1_log():  _poll_inner("s1")

@st.fragment(run_every=1.0)
def _ph4_log(): _poll_inner("ph4")

@st.fragment(run_every=1.0)
def _ph5_log(): _poll_inner("ph5")

@st.fragment(run_every=1.0)
def _ph6_log(): _poll_inner("ph6")

@st.fragment(run_every=1.0)
def _s3_log():  _poll_inner("s3")


# ── detect available videos / models ─────────────────────────────────────────

def detected_videos() -> list[str]:
    pred_dir = NB_DIR / "Predictions"
    if not pred_dir.exists():
        return []
    return sorted(p.name for p in pred_dir.iterdir() if p.is_dir() and not p.name.startswith("."))


def detected_raw_videos() -> list[str]:
    """Videos available as raw PNGs — candidates for Section 1 inference."""
    raw_dir = NB_DIR / "PNGs" / "Raw_PNGs"
    if not raw_dir.exists():
        return []
    return sorted(p.name for p in raw_dir.iterdir() if p.is_dir() and not p.name.startswith("."))


def detected_models(kind: str) -> list[str]:
    if kind == "ADPT":
        # ADPT models are .pt files directly inside VS Code Models/
        d = NB_DIR / "Models" / "VS Code Models"
        if not d.exists():
            return []
        return sorted(p.name for p in d.iterdir()
                      if p.is_file() and p.suffix == ".pt" and not p.name.startswith("."))
    else:
        d = NB_DIR / "Models" / "SLEAP_Models"
        if not d.exists():
            return []
        return sorted(p.name for p in d.iterdir()
                      if p.is_dir() and not p.name.startswith("."))


# ── Sidebar — Configuration ───────────────────────────────────────────────────

with st.sidebar:
    st.markdown(
        '<div style="color:white;font-weight:600;font-size:0.72em;'
        'letter-spacing:0.10em;text-transform:uppercase;'
        'opacity:0.55;margin-bottom:8px">Configuration</div>',
        unsafe_allow_html=True,
    )

    inference_model = st.segmented_control(
        "Inference model", ["SLEAP", "Local"],
        default="SLEAP", key="bp_inf_model",
    )
    video_set = st.segmented_control(
        "Video set", ["B", "C", "D"],
        default="B", key="bp_video_set",
        help="B = hot colourmap  ·  C = no colourmap  ·  D = raw",
    )

    inference_model = "ADPT" if inference_model == "Local" else (inference_model or "SLEAP")
    video_set       = video_set or "B"

    avail_models = detected_models(inference_model)
    # One stable key so React updates options in place instead of replacing the
    # DOM node (which causes a visible size flash on mode switch).
    if avail_models:
        _cur = st.session_state.get("bp_model_name")
        if _cur not in avail_models:
            st.session_state["bp_model_name"] = avail_models[0]
        model_name = st.selectbox("Model", avail_models, key="bp_model_name")
    else:
        model_name = st.text_input(
            "Model",
            value="drosophila_unet64_setB_260407_092817",
            key="bp_model_name_fb",
        )


# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1 — DL Model Inference (Phases 1–3)
# ─────────────────────────────────────────────────────────────────────────────

_s1_status = _state("s1_status", "idle")
st.markdown(
    section_banner(PURPLE, "1", "DL Model Inference",
        "Phase 1: Raw processing &nbsp;·&nbsp; Phase 2: Video export &nbsp;·&nbsp; Phase 3: Pose estimation",
        status_dot(_s1_status, PURPLE)),
    unsafe_allow_html=True,
)

with st.expander("What this does", expanded=False):
    st.markdown(
        """
        **Phase 1** — Background subtraction for every video:
        raw PNGs → Set B (hot colourmap) + Set C (no colourmap) + Set D (raw).

        **Phase 2** — PNG sets → lossless AVI (FFV1 codec, 250 FPS).

        **Phase 3** — SLEAP `sleap-nn track` or ADPT `inference.py` →
        `.predictions.slp` per video, relinked to Set B for SLEAP GUI display.
        """
    )

# Videos input — lives under Section 1
st.markdown(
    f'<div style="color:{PURPLE};font-size:0.72em;font-weight:700;'
    f'text-transform:uppercase;letter-spacing:0.1em;margin-bottom:4px">'
    f'Videos for inference</div>',
    unsafe_allow_html=True,
)
_avail_raw = detected_raw_videos() or detected_videos()
if _avail_raw:
    video_names_inf = st.multiselect(
        "Videos for inference", options=_avail_raw,
        default=[v for v in _avail_raw if v in st.session_state.get("bp_video_input_ms", _avail_raw[:2])],
        key="bp_video_input_ms",
        label_visibility="collapsed",
        help="Folder names under Inference_Pipeline/PNGs/Raw_PNGs/",
    )
else:
    _txt = st.text_area(
        "Videos for inference",
        value="CantonS_unamp_Fly1.2\nCantonS_unamp_Fly3.1",
        height=90, key="bp_video_input", label_visibility="collapsed",
        help="Folder names under Inference_Pipeline/PNGs/Raw_PNGs/",
    )
    video_names_inf = [v.strip() for v in _txt.splitlines() if v.strip()]
st.caption(f"{len(video_names_inf)} video(s) selected")

_s1_log()
run_s1 = stop_s1 = False
if _s1_status == "running":
    stop_s1 = st.button("■  Stop", key="btn_s1_stop")
else:
    run_s1 = st.button("▶  Run Section 1", key="btn_s1")

if run_s1:
    if not video_names_inf:
        st.warning("Add at least one video name.")
    else:
        flags = {
            "VIDEO_FOLDER_NAMES_INF": video_names_inf,
            "INFERENCE_MODEL": inference_model,
            "VIDEO_SET": video_set,
            "MODEL_NAME": model_name,
        }
        try:
            script = nb_utils.bulk_section1_script(BULK_NB, flags)
            start_phase("s1", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

if stop_s1:
    stop_phase("s1")
    st.rerun()


# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2 — Predictions Inspection (Phases 4–6)
# ─────────────────────────────────────────────────────────────────────────────

_s2_status = (
    "running" if any(_state(f"{k}_status", "idle") == "running" for k in ["ph4", "ph5", "ph6"])
    else "success" if any(_state(f"{k}_status", "idle") == "success" for k in ["ph4", "ph5", "ph6"])
    else "idle"
)
st.markdown(
    section_banner(TEAL, "2", "Predictions Inspection",
        "Phase 4: SLEAP correction &nbsp;·&nbsp; Phase 5: Trim frames &nbsp;·&nbsp; Phase 6: Pre-flight validation",
        status_dot(_s2_status, TEAL)),
    unsafe_allow_html=True,
)

# ── Phase 4 — SLEAP GUIs ──────────────────────────────────────────────────────
_ph4_status = _state("ph4_status", "idle")
st.markdown(
    phase_label(TEAL, "4", "Open SLEAP GUIs for Correction", status_dot(_ph4_status, TEAL)),
    unsafe_allow_html=True,
)

with st.expander("Instructions", expanded=False):
    st.markdown(
        """
        After Section 1, open the SLEAP GUIs for each video and:
        1. Review predicted keypoints frame by frame.
        2. Correct wrong positions — drag markers to correct locations.
        3. Verify leg contacts match FTIR visibility (only ground-touching legs visible).
        4. **Save** the `.slp` file before closing.

        **FlyWalker requires:** ≥ 4 distinct contact events per leg,
        both L/R sides detected at least once, ≥ 1 tripod stance frame.
        """
    )

avail_vids = detected_videos()
if avail_vids:
    _default_ana = [v for v in video_names_inf if v in avail_vids] or avail_vids[:min(2, len(avail_vids))]
    videos_ana = st.multiselect(
        "Videos to open in SLEAP", options=avail_vids, default=_default_ana, key="bp_videos_ana",
    )
else:
    videos_ana_raw = st.text_area(
        "Video names (one per line)", value="\n".join(video_names_inf), height=70, key="bp_videos_ana_txt",
    )
    videos_ana = [v.strip() for v in videos_ana_raw.splitlines() if v.strip()]

_ph4_log()
run_ph4 = stop_ph4 = False
if _ph4_status == "running":
    stop_ph4 = st.button("■  Stop", key="btn_ph4_stop")
else:
    run_ph4 = st.button("▶  Open SLEAP GUIs", key="btn_ph4")

if run_ph4:
    if not videos_ana:
        st.warning("Select at least one video.")
    else:
        flags_a = {
            "VIDEO_FOLDER_NAMES_INF": video_names_inf,
            "INFERENCE_MODEL": inference_model,
            "VIDEO_SET": video_set,
            "MODEL_NAME": model_name,
        }
        try:
            script = nb_utils.bulk_phase4_script(BULK_NB, flags_a, videos_ana)
            start_phase("ph4", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

if stop_ph4:
    stop_phase("ph4")
    st.rerun()

# ── Phase 5 — Trim tail frames ────────────────────────────────────────────────
_ph5_status = _state("ph5_status", "idle")
st.markdown(
    phase_label(TEAL, "5", "Trim Tail Frames", f"optional &nbsp;·&nbsp; {status_dot(_ph5_status, TEAL)}"),
    unsafe_allow_html=True,
)
st.markdown(
    f'<p style="color:{MUTED};font-size:0.83em;margin-bottom:8px">'
    f'Remove trailing frames where the fly stopped. Enter the last frame to keep (1-based) per video.</p>',
    unsafe_allow_html=True,
)

_trim_options = detected_videos() or list(dict.fromkeys(videos_ana + video_names_inf))
trim_vids = st.multiselect(
    "Videos to trim", options=_trim_options,
    default=[v for v in videos_ana if v in _trim_options], key="bp_trim_vids",
)
trim_data = {}
for vfn in trim_vids:
    n = st.number_input(
        f"{vfn} — keep up to frame", min_value=1, max_value=10000, value=200, step=1, key=f"trim_{vfn}",
    )
    trim_data[vfn] = int(n)

_ph5_log()
run_ph5 = stop_ph5 = False
if _ph5_status == "running":
    stop_ph5 = st.button("■  Stop", key="btn_ph5_stop")
else:
    run_ph5 = st.button("▶  Trim Frames", key="btn_ph5")

if run_ph5:
    if not trim_vids:
        st.warning("Select at least one video to trim.")
    else:
        flags_a = {
            "VIDEO_FOLDER_NAMES_INF": video_names_inf,
            "INFERENCE_MODEL": inference_model,
            "VIDEO_SET": video_set,
            "MODEL_NAME": model_name,
        }
        try:
            script = nb_utils.bulk_trim_script(BULK_NB, flags_a, trim_data)
            start_phase("ph5", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

if stop_ph5:
    stop_phase("ph5")
    st.rerun()


# ── FLAGS B — videos for Phase 6 and Section 3 ───────────────────────────────
st.markdown(
    f'<div style="color:{TEAL};font-size:0.72em;font-weight:700;'
    f'text-transform:uppercase;letter-spacing:0.1em;margin:16px 0 4px">'
    f'Videos for Phase 6 &amp; Section 3</div>',
    unsafe_allow_html=True,
)
if avail_vids:
    videos_c = st.multiselect(
        "Select videos for analysis", options=avail_vids,
        default=videos_ana if videos_ana else avail_vids[:min(2, len(avail_vids))],
        key="bp_videos_c",
    )
else:
    videos_c_raw = st.text_area(
        "Video names (one per line)", value="\n".join(videos_ana), height=70, key="bp_videos_c_txt",
    )
    videos_c = [v.strip() for v in videos_c_raw.splitlines() if v.strip()]


# ── Phase 6 — Pre-flight Validation ──────────────────────────────────────────
_ph6_status = _state("ph6_status", "idle")
st.markdown(
    phase_label(TEAL, "6", "Pre-flight Validation", status_dot(_ph6_status, TEAL)),
    unsafe_allow_html=True,
)

with st.expander("What this checks", expanded=False):
    st.markdown(
        """
        Validates each corrected `.slp` for FlyWalker compatibility:
        - Leg contact counts (≥ 4 usable events per leg required)
        - Left / right side completeness
        - Tripod gait detection
        - Support polygon crash risk
        - Single-leg frames, isolated 1-frame contacts, same-side-only frames

        Fix any FAIL/WARN items before running Section 3.
        """
    )

_ph6_log()
run_ph6 = stop_ph6 = False
if _ph6_status == "running":
    stop_ph6 = st.button("■  Stop", key="btn_ph6_stop")
else:
    run_ph6 = st.button("▶  Run Pre-flight Validation", key="btn_ph6")

if run_ph6:
    if not videos_c:
        st.warning("Select at least one video.")
    else:
        flags_a = {
            "VIDEO_FOLDER_NAMES_INF": video_names_inf,
            "INFERENCE_MODEL": inference_model,
            "VIDEO_SET": video_set,
            "MODEL_NAME": model_name,
        }
        try:
            script = nb_utils.bulk_preflight_script(BULK_NB, flags_a, videos_c)
            start_phase("ph6", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

if stop_ph6:
    stop_phase("ph6")
    st.rerun()


# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3 — FlyWalker Analysis (Phases 7–10)
# ─────────────────────────────────────────────────────────────────────────────

_s3_status = _state("s3_status", "idle")
st.markdown(
    section_banner(GREEN, "3", "FlyWalker Analysis",
        "Phase 7: Export labels &nbsp;·&nbsp; Phase 8: Extract tracks &nbsp;·&nbsp; "
        "Phase 9: Write MATLAB data &nbsp;·&nbsp; Phase 10: FlyWalker analysis",
        status_dot(_s3_status, GREEN)),
    unsafe_allow_html=True,
)

with st.expander("What this does", expanded=False):
    st.markdown(
        """
        **Phase 7** — `sleap-convert` → `.analysis.h5`

        **Phase 8** — Extract body position, orientation, leg contacts from HDF5.

        **Phase 9** — Write `TRACKS.mat` (MATLAB struct, FlyWalker format).

        **Phase 10** — Launch FlyWalker MATLAB analysis → graphs + `ResultSummary.xlsx`.
        If MATLAB headless launch fails, a `_run_flywalker.m` script is written for manual execution.

        > **Note:** `ResultSummary.xlsx` may not be saved on MATLAB R2025b+ due to a
        > known COM API incompatibility. All `.fig` plots are saved regardless.
        """
    )

_s3_log()
run_s3 = stop_s3 = False
if _s3_status == "running":
    stop_s3 = st.button("■  Stop", key="btn_s3_stop")
else:
    run_s3 = st.button("▶  Run Section 3", key="btn_s3")

if run_s3:
    if not videos_c:
        st.warning("Select at least one video for analysis.")
    else:
        flags_a = {
            "VIDEO_FOLDER_NAMES_INF": video_names_inf,
            "INFERENCE_MODEL": inference_model,
            "VIDEO_SET": video_set,
            "MODEL_NAME": model_name,
        }
        try:
            script = nb_utils.bulk_section3_script(BULK_NB, flags_a, videos_c)
            start_phase("s3", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

if stop_s3:
    stop_phase("s3")
    st.rerun()


# ── Output reference ──────────────────────────────────────────────────────────
with st.expander("Output files reference", expanded=False):
    st.markdown(
        """
        All outputs land in `Inference_Pipeline/Predictions/<VIDEO_FOLDER_NAME>/`:

        | File | Description |
        |------|-------------|
        | `<name>.predictions.slp` | SLEAP labels (corrected) |
        | `<name>.analysis.h5` | SLEAP analysis HDF5 |
        | `TRACKS.mat` | FlyWalker input (MATLAB struct) |
        | `FlyWalker_<name>/` | FlyWalker output graphs (`.fig`) |
        | `ResultSummary.xlsx` | FlyWalker results table (may fail on R2025b+) |
        | `_run_flywalker.m` | Manual MATLAB script (fallback) |
        """
    )

_save_state(st.session_state)
