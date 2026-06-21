from __future__ import annotations
import html as _html
import sys
from pathlib import Path
import streamlit as st


# ── path setup ────────────────────────────────────────────────────────────────
_GUI = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(_GUI))

from lib.paths import NB_DIR, AL_NB
from lib.runner import StreamingSubprocess
from lib import nb_utils
from lib.styles_v2 import (
    inject, inject_stop_style, status_dot,
    section_banner, phase_label,
    AMBER, MUTED, TEXT, log_to_html,
)
from lib.persistence import load as _load_state, save as _save_state

inject()
inject_stop_style()
_load_state(st.session_state)

# Page-specific styles
st.markdown(f"""
<style>
/* ── Workflow summary card — light-mode text fix ────────────────────────── */
.flytrack-light .al-wf-text {{ color: #334155 !important; }}

/* ── Metrics table (HTML, replaces st.dataframe) ─────────────────────── */
.ft-metrics-tbl {{
    width: 100%; border-collapse: collapse;
    font-family: 'JetBrains Mono', monospace; font-size: 0.78em; margin: 4px 0;
}}
.ft-metrics-tbl th {{
    background: {AMBER}15; color: {AMBER}; font-weight: 600;
    text-transform: uppercase; letter-spacing: 0.07em; font-size: 0.79em;
    padding: 6px 10px; border-bottom: 1px solid {AMBER}35; text-align: left;
}}
.ft-metrics-tbl td {{
    color: {MUTED}; padding: 4px 10px; border-bottom: 1px solid {AMBER}12;
}}
.ft-metrics-tbl td:first-child {{ color: {TEXT}; font-weight: 500; }}
.flytrack-light .ft-metrics-tbl th {{
    color: #92400e; background: rgba(251,191,36,0.12); border-bottom-color: rgba(251,191,36,0.28);
}}
.flytrack-light .ft-metrics-tbl td {{ color: #475569; border-bottom-color: rgba(251,191,36,0.10); }}
.flytrack-light .ft-metrics-tbl td:first-child {{ color: #0f172a; }}

/* ── Compact inputs inside the Advanced settings expander ───────────────── */
[data-testid="stExpander"] [data-testid="stTextInput"] label,
[data-testid="stExpander"] [data-testid="stNumberInput"] label {{
    font-size: 0.76em !important;
    color: #94a3b8 !important;
    margin-bottom: 1px !important;
    line-height: 1.2 !important;
}}
/* The visible styled box (BaseWeb container) */
[data-testid="stExpander"] [data-testid="stTextInput"] [data-baseweb="input"],
[data-testid="stExpander"] [data-testid="stNumberInput"] [data-baseweb="input"] {{
    min-height: 30px !important;
    height: 30px !important;
    padding: 0 8px !important;
    display: flex !important;
    align-items: center !important;
}}
/* The raw <input> element inside */
[data-testid="stExpander"] [data-testid="stTextInput"] input,
[data-testid="stExpander"] [data-testid="stNumberInput"] input {{
    font-size: 0.82em !important;
    padding: 0 !important;
    height: 28px !important;
    line-height: 28px !important;
}}
/* +/− stepper buttons */
[data-testid="stExpander"] [data-testid="stNumberInput"] button {{
    height: 30px !important;
    min-height: 30px !important;
    width: 28px !important;
    font-size: 0.82em !important;
    padding: 0 !important;
}}
/* ── Sidebar video multiselect — amber section colour ───────────────────── */
[data-testid="stSidebar"] [data-testid="stMultiSelect"] [data-baseweb="tag"] {{
    background-color: {AMBER}12 !important;
    border-left-color: {AMBER} !important;
    color: {AMBER} !important;
}}
[data-testid="stSidebar"] [data-testid="stMultiSelect"] [data-baseweb="tag"] span {{
    color: {AMBER} !important;
}}
/* Input area (the click-to-open container) */
[data-testid="stSidebar"] [data-testid="stMultiSelect"] [data-baseweb="select"] > div {{
    border-color: {AMBER}30 !important;
}}
[data-testid="stSidebar"] [data-testid="stMultiSelect"] [data-baseweb="select"] > div:focus-within {{
    border-color: rgba(255,255,255,0.55) !important;
    box-shadow: 0 0 0 1px rgba(255,255,255,0.10) !important;
}}
</style>
""", unsafe_allow_html=True)

# ── state helpers ─────────────────────────────────────────────────────────────

def _state(key, default=None):
    return st.session_state.get(f"al_{key}", default)


def _set(key, val):
    st.session_state[f"al_{key}"] = val


_TALL_KEYS = {"s7", "ie"}


def render_log(key, tall=False):
    lines = _state(f"{key}_log", [])
    text  = "\n".join(lines) if lines else "(no output yet)"
    cls   = "log-box-tall" if tall else "log-box"
    st.markdown(f'<div class="{cls}">{log_to_html(text)}</div>', unsafe_allow_html=True)


def _poll_inner(key: str):
    """Drain new output, render log, finalize when proc is done.

    Called directly from the page body (no fragments).  A full-page rerun
    loop at the bottom of the script drives the 1-second polling cadence —
    only while a proc is active, so the page is completely static when idle.
    """
    proc = _state(f"{key}_proc")
    if proc is not None:
        new_lines = proc.drain()
        if new_lines:
            log = _state(f"{key}_log", [])
            log.extend(new_lines)
            _set(f"{key}_log", log)
            if key == "s2":
                for line in new_lines:
                    if "RUN_NAME" in line and ":" in line:
                        rn = line.split(":", 1)[-1].strip()
                        if rn and not rn.startswith("#"):
                            _set("run_name", rn)
                    if "Merged .slp saved" in line and ":" in line:
                        slp_name = line.split(":", 1)[-1].strip()
                        if slp_name and slp_name.endswith(".slp"):
                            _set("merged_slp_name", slp_name)
    # Always render (shows accumulated output whether running or done)
    render_log(key, tall=(key in _TALL_KEYS))
    if proc is not None and proc.done:
        _set(f"{key}_status", "success" if proc.returncode == 0 else "error")
        _set(f"{key}_proc", None)
        st.rerun()


def start_step(key: str, script_path: Path):
    _set(f"{key}_log", [])
    _set(f"{key}_status", "running")
    proc = StreamingSubprocess(
        [sys.executable, "-u", str(script_path)],
        cwd=str(NB_DIR),
    )
    proc.start()
    _set(f"{key}_proc", proc)


def stop_step(key: str):
    proc = _state(f"{key}_proc")
    if proc is not None:
        proc.terminate()
    _set(f"{key}_status", "idle")
    _set(f"{key}_proc", None)


# ── helpers ───────────────────────────────────────────────────────────────────

def _strip_td(text: str) -> str:
    """Remove tracking drift rows from evaluation results text."""
    skip_kw = ("tracking drift", "tracking_drift", "track drift")
    out = []
    for line in text.splitlines():
        ll = line.lower()
        if any(kw in ll for kw in skip_kw):
            continue
        out.append(line)
    return "\n".join(out)


def detected_predictions() -> list[str]:
    pred_dir = NB_DIR / "Predictions"
    if not pred_dir.exists():
        return []
    return sorted(
        p.name for p in pred_dir.iterdir()
        if p.is_dir() and not p.name.startswith(".")
    )


def detected_sleap_models() -> list[str]:
    d = NB_DIR / "Models" / "SLEAP_Models"
    if not d.exists():
        return []
    return sorted(
        p.name for p in d.iterdir()
        if p.is_dir() and not p.name.startswith(".")
    )


def show_run_name():
    rn = _state("run_name")
    if rn:
        st.markdown(
            f'<div style="background:{AMBER}0a;border:1px solid {AMBER}25;'
            f'border-radius:6px;padding:10px 16px;margin:8px 0">'
            f'<span style="color:{AMBER};font-size:0.82em">'
            f'Current run: <code>{rn}</code>'
            f'</span></div>',
            unsafe_allow_html=True,
        )


# ── Configuration — sidebar ───────────────────────────────────────────────────
with st.sidebar:
    st.markdown(
        '<div style="color:white;font-weight:600;font-size:0.72em;'
        'letter-spacing:0.10em;text-transform:uppercase;'
        'opacity:0.55;margin-bottom:8px">Configuration</div>',
        unsafe_allow_html=True,
    )

    avail_models = detected_sleap_models()
    if st.session_state.get("al_base_model") not in avail_models:
        st.session_state.pop("al_base_model", None)
    if avail_models:
        base_model = st.selectbox(
            "Base SLEAP model",
            avail_models,
            key="al_base_model",
        )
    else:
        base_model = st.text_input(
            "Base model folder name",
            value="drosophila_unet64_setB_260407_092817",
            key="al_base_model",
        )

    st.markdown(
        f'<div style="color:{AMBER};font-weight:700;font-size:0.70em;'
        f'letter-spacing:0.10em;text-transform:uppercase;'
        f'margin-top:10px;margin-bottom:4px">New corrected videos</div>',
        unsafe_allow_html=True,
    )
    avail_preds = detected_predictions()
    _prev = st.session_state.get("al_new_videos_sel", [])
    _default = [v for v in _prev if v in avail_preds] or avail_preds[:min(2, len(avail_preds))]
    new_videos = st.multiselect(
        "New corrected videos",
        options=avail_preds,
        default=_default,
        key="al_new_videos_sel",
        label_visibility="collapsed",
        help="Must have been through Phases 1–4 and corrected in SLEAP.",
    )
    if not avail_preds:
        st.caption("No prediction folders found — run Bulk Pipeline first.")
    else:
        st.caption(f"{len(new_videos)} video(s) selected")


if not AL_NB.exists():
    st.error(f"Notebook not found: `{AL_NB}`")
    st.stop()

# ── Section banner ────────────────────────────────────────────────────────────
_overall_status = "idle"
for _k in ["s1", "s2", "s4", "s6", "s7"]:
    if _state(f"{_k}_status", "idle") == "running":
        _overall_status = "running"
        break
if _overall_status == "idle" and _state("s7_status", "idle") == "success":
    _overall_status = "success"

st.markdown(
    section_banner(
        AMBER, "",
        "Active Learning",
        "Merge corrected predictions → fine-tune SLEAP model → improved model back to Section 1",
        status_dot(_overall_status, AMBER),
        label="Active Learning",
    ),
    unsafe_allow_html=True,
)

# ── Advanced settings (collapsed — defaults work for most runs) ───────────────
with st.expander("Advanced settings — dataset paths & training parameters", expanded=True):
    st.markdown(
        f'<p style="color:{MUTED};font-size:0.82em;margin:2px 0 12px">'
        f'Defaults are correct for Set B. Only edit if your dataset filenames or '
        f'hyperparameters differ.</p>',
        unsafe_allow_html=True,
    )
    _dc1, _dc2, _dc3 = st.columns(3)
    with _dc1:
        orig_train = st.text_input("TRAIN .slp",   value="Drosophila_TRAIN_set_setB.slp",   key="al_orig_train")
    with _dc2:
        orig_val   = st.text_input("VAL .slp",     value="Drosophila_VAL_set_setB.slp",     key="al_orig_val",
                                   help=".pkg.slp is generated automatically from the .slp if not already present.")
    with _dc3:
        orig_test  = st.text_input("TEST .slp",    value="Drosophila_TEST_set_setB.slp",    key="al_orig_test")

    _tc1, _tc2, _tc3 = st.columns([3, 1, 1])
    with _tc1:
        _mode_opts = ["local", "colab"]
        _mode_sel  = st.segmented_control(
            "Training mode",
            options=_mode_opts,
            default="colab",
            key="al_mode",
            help="local = CPU training here | colab = prepare zip for Google Colab GPU",
        )
        mode = _mode_sel if _mode_sel else "colab"
    with _tc2:
        max_epochs = st.number_input("Max epochs", min_value=1, max_value=500, value=50, step=1, key="al_epochs")
    with _tc3:
        batch_size = st.number_input("Batch size", min_value=1, max_value=64,  value=6,  step=1, key="al_batch")

# ── FLAGS dict ────────────────────────────────────────────────────────────────
FLAGS = {
    "NEW_VIDEOS":          new_videos,
    "BASE_MODEL_NAME":     base_model,
    "ORIG_TRAIN_SLP_NAME": orig_train,
    "ORIG_VAL_SLP_NAME":   orig_val,
    "ORIG_TEST_SLP_NAME":  orig_test,
    "MAX_EPOCHS":          int(max_epochs),
    "BATCH_SIZE":          int(batch_size),
    "MODE":                mode,
}

# ── Workflow summary card ─────────────────────────────────────────────────────
st.markdown(
    f'<div style="background:{AMBER}0d;border:1px solid {AMBER}30;'
    f'border-radius:6px;padding:10px 16px;margin:10px 0 4px">'
    f'<span class="al-wf-text" style="color:{TEXT};font-size:0.88em">'
    f'Adding <strong>{len(new_videos)}</strong> video(s) &nbsp;&middot;&nbsp; '
    f'Base model: <code>{base_model}</code> &nbsp;&middot;&nbsp; '
    f'Mode: <strong>{mode}</strong> &nbsp;|&nbsp; '
    f'Epochs: {max_epochs} &nbsp;|&nbsp; Batch: {batch_size}'
    f'</span>'
    f'</div>',
    unsafe_allow_html=True,
)
show_run_name()


# ─────────────────────────────────────────────────────────────────────────────
# Step 1 — Verify corrected labels
# ─────────────────────────────────────────────────────────────────────────────
_s1_status = _state("s1_status", "idle")
st.markdown(phase_label(AMBER, "1", "Verify Corrected Labels", status_dot(_s1_status, AMBER)), unsafe_allow_html=True)
with st.expander("Details", expanded=False):
    st.markdown(
        "Checks that each video in **NEW_VIDEOS** has a `.slp` file under "
        "`Predictions/<video>/`, auto-patches the video path reference, "
        "and prints frame counts."
    )

_poll_inner("s1")
run_s1 = stop_s1 = False
if _s1_status == "running":
    stop_s1 = st.button("■  Stop", key="btn_al_s1_stop")
else:
    run_s1 = st.button("▶  Run Step 1", key="btn_al_s1")

if run_s1:
    if not new_videos:
        st.warning("Add at least one video in the sidebar.")
    else:
        try:
            script = nb_utils.al_step1_script(AL_NB, FLAGS)
            start_step("s1", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

if stop_s1:
    stop_step("s1")
    st.rerun()


# ─────────────────────────────────────────────────────────────────────────────
# Step 2 — Merge datasets + generate .pkg.slp
# ─────────────────────────────────────────────────────────────────────────────
_s2_status = _state("s2_status", "idle")
st.markdown(phase_label(AMBER, "2", "Merge Datasets + Generate .pkg.slp", f"slowest step &nbsp;·&nbsp; {status_dot(_s2_status, AMBER)}"), unsafe_allow_html=True)
with st.expander("Details", expanded=False):
    st.markdown(
        """
        - Converts `PredictedInstance` keypoints to `Instance`
        - Filters empty frames
        - Merges original TRAIN + new corrected videos into one dataset
        - Generates **RUN_NAME** `drosophila_<backbone>_ft_<N>frames_<timestamp>`
        - Embeds video frames → `Drosophila_TRAIN_set_setB_<N>frames.pkg.slp` (needed for Colab)
        - Writes HDF5 sanity check

        > **Slowest step** — embedding frames can take 1–5 minutes.
        """
    )

_poll_inner("s2")
run_s2 = stop_s2 = False
if _s2_status == "running":
    stop_s2 = st.button("■  Stop", key="btn_al_s2_stop")
else:
    run_s2 = st.button("▶  Run Step 2", key="btn_al_s2")

if run_s2:
    try:
        script = nb_utils.al_step2_script(AL_NB, FLAGS)
        start_step("s2", script)
        st.rerun()
    except Exception as e:
        st.error(f"Could not build script: {e}")

if stop_s2:
    stop_step("s2")
    st.rerun()

show_run_name()


# ─────────────────────────────────────────────────────────────────────────────
# Step 3 — Inspect merged dataset in SLEAP (optional)
# ─────────────────────────────────────────────────────────────────────────────
_s3_status = _state("s3_status", "idle")
st.markdown(phase_label(AMBER, "3", "Inspect Merged Dataset in SLEAP", f"optional &nbsp;·&nbsp; {status_dot(_s3_status, AMBER)}"), unsafe_allow_html=True)
with st.expander("▸ Run (optional — click to expand)", expanded=False):
    st.markdown(
        "Opens the merged `.slp` in the SLEAP GUI for visual verification "
        "before training."
    )
    _poll_inner("s3")
    open_s3 = stop_s3 = False
    if _s3_status == "running":
        stop_s3 = st.button("■  Stop", key="btn_al_s3_stop")
    else:
        open_s3 = st.button("▶  Launch SLEAP", key="btn_al_s3")

    if open_s3:
        merged_slp_name = _state("merged_slp_name")
        if not merged_slp_name:
            st.warning("Run Step 2 first (merged dataset path not yet available).")
        else:
            dataset_dir = NB_DIR / "SLEAP_Dataset"
            merged_slp  = dataset_dir / merged_slp_name
            inline = (
                "import subprocess, sys\n"
                f"merged = {str(merged_slp)!r}\n"
                "from pathlib import Path\n"
                "if not Path(merged).exists():\n"
                "    print(f'File not found: {merged}')\n"
                "    sys.exit(1)\n"
                "print(f'Opening {merged} in SLEAP...')\n"
                "import os as _os\n"
                "_env = _os.environ.copy()\n"
                "_env.pop('MPLBACKEND', None)\n"
                "subprocess.Popen(['sleap-label', merged], shell=False, env=_env)\n"
                "print('SLEAP GUI launched.')\n"
            )
            from lib.nb_utils import write_temp_script
            script = write_temp_script(
                "import sys; sys.stdout.reconfigure(encoding='utf-8')\n" + inline
            )
            start_step("s3", script)
            st.rerun()

    if stop_s3:
        stop_step("s3")
        st.rerun()


# ─────────────────────────────────────────────────────────────────────────────
# Step 4 — Build fine-tune config YAML
# ─────────────────────────────────────────────────────────────────────────────
_s4_status = _state("s4_status", "idle")
st.markdown(phase_label(AMBER, "4", "Build Fine-tune Config YAML", status_dot(_s4_status, AMBER)), unsafe_allow_html=True)
with st.expander("Details", expanded=False):
    st.markdown(
        """
        - Loads `training_config.yaml` from the base model folder
        - Sets LR = base_lr ÷ 10 (conservative fine-tune rate)
        - Writes `single_instance_ft.yaml` with merged dataset as TRAIN,
          original VAL unchanged, pretrained weights from `best.ckpt`
        - Writes `colab_config.json` for Colab mode
        """
    )

_poll_inner("s4")
run_s4 = stop_s4 = False
if _s4_status == "running":
    stop_s4 = st.button("■  Stop", key="btn_al_s4_stop")
else:
    run_s4 = st.button("▶  Run Step 4", key="btn_al_s4")

if run_s4:
    run_name = _state("run_name")
    if not run_name:
        st.warning("Run Step 2 first so RUN_NAME is known.")
    else:
        try:
            script = nb_utils.al_step3_script(AL_NB, FLAGS, run_name)
            start_step("s4", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

if stop_s4:
    stop_step("s4")
    st.rerun()


# ─────────────────────────────────────────────────────────────────────────────
# Step 5 — Hardware check (optional)
# ─────────────────────────────────────────────────────────────────────────────
_s5_status = _state("s5_status", "idle")
st.markdown(phase_label(AMBER, "5", "Hardware Check", f"optional &nbsp;·&nbsp; {status_dot(_s5_status, AMBER)}"), unsafe_allow_html=True)
with st.expander("▸ Run (optional — click to expand)", expanded=False):
    st.markdown("Reports CPU, RAM, and GPU VRAM available for training.")
    _poll_inner("s5")
    check_s5 = stop_s5 = False
    if _s5_status == "running":
        stop_s5 = st.button("■  Stop", key="btn_al_s5_stop")
    else:
        check_s5 = st.button("▶  Check Hardware", key="btn_al_s5")

    if check_s5:
        run_name = _state("run_name") or "placeholder"
        try:
            script = nb_utils.al_step35_script(AL_NB, FLAGS, run_name)
            start_step("s5", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

    if stop_s5:
        stop_step("s5")
        st.rerun()


# ─────────────────────────────────────────────────────────────────────────────
# Step 6 — Train
# ─────────────────────────────────────────────────────────────────────────────
_s6_status = _state("s6_status", "idle")
st.markdown(phase_label(AMBER, "6", "Train", status_dot(_s6_status, AMBER)), unsafe_allow_html=True)

if mode == "local":
    with st.expander("Local training details", expanded=False):
        st.markdown(
            "Runs `sleap_nn.cli train single_instance_ft.yaml` in the `sleap` environment. "
            "Uses CPU (or GPU if CUDA is available). Training streams live. "
            "Early stopping is active — may finish before MAX_EPOCHS."
        )
else:
    with st.expander("Colab mode — what happens", expanded=False):
        st.markdown(
            """
            Creates `colab_upload.zip` in `SLEAP_Dataset/` containing:
            - `Drosophila_TRAIN_set_setB_<N>frames.pkg.slp` (embedded training frames)
            - `Drosophila_VAL_set_setB.pkg.slp`
            - `single_instance_ft.yaml` + `colab_config.json`
            - `best_ft_base.ckpt` (base model weights)
            - `base_metrics/` (base model eval metrics for comparison)

            Then opens Google Drive and Google Colab in your browser.
            Upload the zip to Drive, run `Active_Learning_Colab.ipynb`.
            """
        )

_poll_inner("s6")
run_s6 = stop_s6 = False
btn_label = "▶  Train"
if _s6_status == "running":
    stop_s6 = st.button("■  Stop", key="btn_al_s6_stop")
else:
    run_s6 = st.button(btn_label, key="btn_al_s6")

if run_s6:
    run_name = _state("run_name")
    if not run_name:
        st.warning("Run Steps 1–4 first so RUN_NAME is known.")
    else:
        try:
            script = nb_utils.al_step4_script(AL_NB, FLAGS, run_name)
            start_step("s6", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

if stop_s6:
    stop_step("s6")
    st.rerun()


# ─────────────────────────────────────────────────────────────────────────────
# Step 7 — Evaluate & compare results
# ─────────────────────────────────────────────────────────────────────────────
_s7_status = _state("s7_status", "idle")
st.markdown(phase_label(AMBER, "7", "Evaluate &amp; Compare Results", status_dot(_s7_status, AMBER)), unsafe_allow_html=True)
with st.expander("What this generates", expanded=False):
    st.markdown(
        """
        - **Loss curves** (train / val loss, LR schedule)
        - **SLEAP built-in metrics** (mOKS, mAP, mAR) for train / val / test
        - **Custom metrics** (MPE per keypoint, FP/FN contact rates, tracking drift,
          CR_kp, CR_frame)
        - **Comparison table (VAL)** — fine-tuned vs base model, 20+ metrics
        - **Comparison table (TEST)** — if TEST pkg available

        Results stream to the log. For rich plots, open the notebook directly.
        """
    )

_poll_inner("s7")
run_s7 = stop_s7 = False
if _s7_status == "running":
    stop_s7 = st.button("■  Stop", key="btn_al_s7_stop")
else:
    run_s7 = st.button("▶  Run Step 7", key="btn_al_s7")

if run_s7:
    run_name = _state("run_name")
    if not run_name:
        st.warning("Run Steps 1–4 first so RUN_NAME is known.")
    else:
        try:
            script = nb_utils.al_step5_script(AL_NB, FLAGS, run_name)
            start_step("s7", script)
            st.rerun()
        except Exception as e:
            st.error(f"Could not build script: {e}")

if stop_s7:
    stop_step("s7")
    st.rerun()


# ── Next-step instructions ────────────────────────────────────────────────────
run_name = _state("run_name")
if run_name and _s7_status == "success":
    st.markdown(
        f'<div style="background:{AMBER}12;border:1px solid {AMBER}40;'
        f'border-left:4px solid {AMBER};border-radius:6px;padding:12px 16px;margin-top:18px">'
        f'<div style="color:{AMBER};font-size:0.72em;font-weight:700;text-transform:uppercase;'
        f'letter-spacing:0.08em;margin-bottom:4px">Next Step</div>'
        f'<div style="color:{TEXT};font-size:0.9em">'
        f'Set <code>MODEL_NAME = \'{run_name}\'</code> in the '
        f'<strong>Bulk Pipeline</strong> sidebar to use the fine-tuned model.</div>'
        f'</div>',
        unsafe_allow_html=True,
    )
elif run_name:
    st.markdown(
        f'<div style="background:{AMBER}0a;border:1px solid {AMBER}25;'
        f'border-radius:6px;padding:10px 16px;margin-top:14px">'
        f'<span style="color:{AMBER};font-size:0.82em">'
        f'After Step 7, update <strong>Bulk Pipeline → Configuration → Model name</strong> to: '
        f'<code>{run_name}</code></span>'
        f'</div>',
        unsafe_allow_html=True,
    )


# ─────────────────────────────────────────────────────────────────────────────
# Inspect Model Results
# ─────────────────────────────────────────────────────────────────────────────
st.markdown(
    f'<div style="background:linear-gradient(120deg,{AMBER}12,{AMBER}04);'
    f'border:1px solid {AMBER}25;border-left:3px solid {AMBER};'
    f'border-radius:6px;padding:10px 16px;margin:30px 0 10px;'
    f'display:flex;align-items:center;gap:10px">'
    f'<div style="color:{AMBER};font-size:0.65em;font-weight:700;text-transform:uppercase;'
    f'letter-spacing:0.12em">Inspect Model Results</div>'
    f'<div style="color:{MUTED};font-size:0.78em;border-left:1px solid {AMBER}25;'
    f'padding-left:10px">Browse any trained model — view files, training log, and evaluation outputs</div>'
    f'</div>',
    unsafe_allow_html=True,
)

_all_models = detected_sleap_models()
if st.session_state.get("al_inspect_sel") not in _all_models:
    st.session_state.pop("al_inspect_sel", None)
if not _all_models:
    st.caption("No models found in `Models/SLEAP_Models/`.")
else:
    _sel_model = st.selectbox(
        "Select model",
        _all_models,
        index=_all_models.index(run_name) if run_name and run_name in _all_models else 0,
        key="al_inspect_sel",
    )
    if _sel_model:
        # Detect model switch — wipe stale evaluation log/status from previous model
        _prev_inspect = st.session_state.get("al_inspect_sel_prev")
        if _prev_inspect is not None and _prev_inspect != _sel_model:
            for _k in ("ie_status", "ie_log"):
                st.session_state.pop(f"al_{_k}", None)
        st.session_state["al_inspect_sel_prev"] = _sel_model

        _mdir = NB_DIR / "Models" / "SLEAP_Models" / _sel_model

        # ── Row 1: file inventory + training log ──────────────────────────────
        _KEY_FILES = {
            "best.ckpt":                    ("Trained weights",       AMBER),
            "training_config.yaml":         ("Training config",       MUTED),
            "training_log.csv":             ("Training log",          MUTED),
            "training_curves.png":          ("Loss curves",           MUTED),
            "eval_kp_metrics_val.png":      ("VAL keypoint plot",     MUTED),
            "eval_kp_metrics_test.png":     ("TEST keypoint plot",    MUTED),
            "eval_kp_metrics_train.png":    ("TRAIN keypoint plot",   MUTED),
            "comparison_vs_base.csv":       ("VAL comparison table",  MUTED),
            "comparison_vs_base_test.csv":  ("TEST comparison table", MUTED),
            "labels_pr.val.0.slp":          ("VAL predictions",       MUTED),
            "labels_pr.test.0.slp":         ("TEST predictions",      MUTED),
            "metrics.val.0.npz":            ("VAL SLEAP metrics",     MUTED),
            "metrics.test.0.npz":           ("TEST SLEAP metrics",    MUTED),
        }
        _files = sorted(_mdir.iterdir()) if _mdir.exists() else []

        _fc1, _fc2 = st.columns([3, 2])
        with _fc1:
            st.markdown(
                f'<div style="color:{MUTED};font-size:0.75em;font-weight:600;'
                f'text-transform:uppercase;letter-spacing:0.08em;margin-bottom:6px">'
                f'Files in {_html.escape(_sel_model)}</div>',
                unsafe_allow_html=True,
            )
            for _f in _files:
                _size            = _f.stat().st_size if _f.is_file() else None
                _label, _col     = _KEY_FILES.get(_f.name, (_f.name, MUTED))
                _size_str = (
                    f"{_size/1e6:.1f} MB" if _size and _size >= 1e6 else
                    f"{_size/1e3:.0f} KB" if _size and _size >= 1e3 else
                    f"{_size} B"          if _size else "dir"
                )
                st.markdown(
                    f'<div style="display:flex;justify-content:space-between;'
                    f'padding:3px 0;border-bottom:1px solid {AMBER}15">'
                    f'<span style="color:{_col};font-size:0.82em">{_html.escape(_f.name)}</span>'
                    f'<span style="color:{MUTED};font-size:0.78em">{_size_str}</span>'
                    f'</div>',
                    unsafe_allow_html=True,
                )

        with _fc2:
            _log_path = _mdir / "training_log.csv"
            if _log_path.exists():
                try:
                    _lines  = _log_path.read_text(encoding="utf-8").strip().splitlines()
                    _header = _lines[0] if _lines else ""
                    _cols   = [c.strip() for c in _header.split(",")]
                    _recent = _lines[-10:] if len(_lines) > 1 else []
                    st.markdown(
                        f'<div style="color:{MUTED};font-size:0.75em;font-weight:600;'
                        f'text-transform:uppercase;letter-spacing:0.08em;margin-bottom:6px">'
                        f'Training log (last {len(_recent)} epochs)</div>',
                        unsafe_allow_html=True,
                    )
                    _ep_i    = _cols.index("epoch") if "epoch" in _cols else None
                    _loss_i  = next((i for i, c in enumerate(_cols) if "val"  in c and "loss" in c), None)
                    _tloss_i = next((i for i, c in enumerate(_cols) if "train" in c and "loss" in c), None)
                    for _row in _recent:
                        _vals  = [v.strip() for v in _row.split(",")]
                        _ep    = _vals[_ep_i]    if _ep_i    is not None and _ep_i    < len(_vals) else "?"
                        _vloss = _vals[_loss_i]  if _loss_i  is not None and _loss_i  < len(_vals) else "?"
                        _tloss = _vals[_tloss_i] if _tloss_i is not None and _tloss_i < len(_vals) else None
                        try: _vloss = f"{float(_vloss):.4f}"
                        except (ValueError, TypeError): pass
                        try: _tloss = f"{float(_tloss):.4f}" if _tloss else None
                        except (ValueError, TypeError): pass
                        _right = (f"train {_tloss} &nbsp;·&nbsp; val {_vloss}"
                                  if _tloss else f"val {_vloss}")
                        st.markdown(
                            f'<div style="display:flex;justify-content:space-between;'
                            f'padding:2px 0;border-bottom:1px solid {AMBER}10">'
                            f'<span style="color:{MUTED};font-size:0.76em">Epoch {_html.escape(str(_ep))}</span>'
                            f'<span style="color:{MUTED};font-size:0.76em">{_right}</span>'
                            f'</div>',
                            unsafe_allow_html=True,
                        )
                except Exception:
                    st.caption("Could not parse training log.")
            else:
                st.caption("No training log found.")

        # ── Row 2: evaluation results (always shown when files exist) ────────
        _has_any_eval = (_mdir / "eval_kp_metrics_val.png").exists()

        def _safe_image(path, **kwargs):
            """Display image via st.image(bytes) — bytes are hashed by Streamlit to
            generate a unique URL per content, so switching models always shows the
            new model's plots even when filenames are identical.  st.image() also
            provides the native Streamlit expand button (click to fullscreen).
            """
            try:
                _caption = kwargs.pop("caption", None)
                _ucw     = kwargs.pop("use_container_width", True)
                _bytes   = path.read_bytes()
                st.image(_bytes, use_container_width=_ucw, caption=_caption)
            except Exception as _img_err:
                st.warning(f"`{path.name}` could not be displayed ({_img_err}). "
                           "Regenerate evaluation to rebuild it.")

        if _has_any_eval:
            # Loss / training curves
            _curves = _mdir / "training_curves.png"
            if _curves.exists():
                st.markdown(
                    f'<div style="color:{MUTED};font-size:0.75em;font-weight:600;'
                    f'text-transform:uppercase;letter-spacing:0.08em;margin:18px 0 8px">'
                    f'Training Curves</div>',
                    unsafe_allow_html=True,
                )
                _safe_image(_curves, use_container_width=True)

            # Metrics summary table
            _metrics_csv = _mdir / "eval_metrics_summary.csv"
            if _metrics_csv.exists():
                try:
                    import pandas as _pd
                    _df_m = _pd.read_csv(_metrics_csv)
                    st.markdown(
                        f'<div style="color:{MUTED};font-size:0.75em;font-weight:600;'
                        f'text-transform:uppercase;letter-spacing:0.08em;margin:18px 0 6px">'
                        f'Evaluation Metrics</div>',
                        unsafe_allow_html=True,
                    )
                    _df_t = _df_m.set_index("Split").T.rename_axis("Metric").reset_index()
                    _thead_html = "".join(f'<th>{_html.escape(str(_c))}</th>' for _c in _df_t.columns)
                    _tbody_html = "".join(
                        "<tr>" + "".join(
                            f'<td>{_html.escape(str(_v)) if _v is not None and str(_v) != "nan" else "—"}</td>'
                            for _v in _row
                        ) + "</tr>"
                        for _row in _df_t.itertuples(index=False, name=None)
                    )
                    st.markdown(
                        f'<table class="ft-metrics-tbl"><thead><tr>{_thead_html}</tr></thead>'
                        f'<tbody>{_tbody_html}</tbody></table>',
                        unsafe_allow_html=True,
                    )
                except Exception:
                    pass

            # Per-keypoint metric plots — VAL and TEST side by side if both exist
            _kp_val   = _mdir / "eval_kp_metrics_val.png"
            _kp_test  = _mdir / "eval_kp_metrics_test.png"
            _kp_train = _mdir / "eval_kp_metrics_train.png"
            _kp_plots = [p for p in [_kp_val, _kp_test] if p.exists()]
            if _kp_plots:
                st.markdown(
                    f'<div style="color:{MUTED};font-size:0.75em;font-weight:600;'
                    f'text-transform:uppercase;letter-spacing:0.08em;margin:18px 0 8px">'
                    f'Per-Keypoint Metrics</div>',
                    unsafe_allow_html=True,
                )
                if len(_kp_plots) == 2:
                    _kc1, _kc2 = st.columns(2)
                    with _kc1:
                        _safe_image(_kp_val,  use_container_width=True, caption="VAL set")
                    with _kc2:
                        _safe_image(_kp_test, use_container_width=True, caption="TEST set")
                else:
                    _lbl = "VAL set" if _kp_plots[0].name.endswith("val.png") else "TEST set"
                    _safe_image(_kp_plots[0], use_container_width=True, caption=_lbl)
            if _kp_train.exists():
                _safe_image(_kp_train, use_container_width=True, caption="TRAIN set")

        # ── Regenerate button — always visible ────────────────────────────────
        _ie_status = _state("ie_status", "idle")
        _poll_inner("ie")

        st.markdown('<div style="margin-top:12px"></div>', unsafe_allow_html=True)
        _run_ie = _stop_ie = False
        if _ie_status == "running":
            _stop_ie = st.button("■  Stop", key="btn_al_ie_stop")
        else:
            _run_ie = st.button("↺  Regenerate Evaluation", key="btn_al_ie")

        if _run_ie:
            _eval_flags = {
                "ORIG_TRAIN_SLP_NAME": orig_train,
                "ORIG_VAL_SLP_NAME":   orig_val,
                "ORIG_TEST_SLP_NAME":  orig_test,
                "BASE_MODEL_NAME":     base_model,
            }
            try:
                _ie_script = nb_utils.al_eval_only_script(AL_NB, _eval_flags, _sel_model)
                start_step("ie", _ie_script)
                st.rerun()
            except Exception as _e:
                st.error(f"Could not build eval script: {_e}")

        if _stop_ie:
            stop_step("ie")
            st.rerun()

        if _state("ie_status") == "success":
            st.rerun()

_save_state(st.session_state)

# ── Auto-rerun while any subprocess is active ─────────────────────────────────
# Drives the live-log polling cadence without fragments (which cause dimming).
# When no proc is running the page is completely static — no timer, no flicker.
_POLL_KEYS = ("s1", "s2", "s3", "s4", "s5", "s6", "s7", "ie")
if any(_state(f"{k}_proc") is not None for k in _POLL_KEYS):
    import time as _time
    _time.sleep(1)
    st.rerun()
