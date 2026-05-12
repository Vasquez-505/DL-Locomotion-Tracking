"""Drosophila DL Tracking Suite — navigation entrypoint."""
import base64
import streamlit as st
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from lib.paths import NB_DIR, ROOT_DIR, BULK_NB, AL_NB
from lib.nb_utils import scan_slp_paths, fix_slp_paths
from lib.styles_v2 import inject, inject_stop_style, PURPLE, TEAL, GREEN, AMBER, SURFACE, BORDER, MUTED, TEXT

st.set_page_config(
    page_title="Drosophila DL Tracking Suite",
    page_icon=":material/home:",
    layout="wide",
    initial_sidebar_state="expanded",
)


# ── Logo ──────────────────────────────────────────────────────────────────────
def _logo_img_tag() -> str:
    assets = Path(__file__).parent / "assets"
    out = []
    for fname, css_cls in [("logo_dark.png", "ft-logo-dark"), ("logo_light.png", "ft-logo-light")]:
        p = assets / fname
        if not p.exists():
            continue
        with open(p, "rb") as fh:
            b64 = base64.b64encode(fh.read()).decode()
        out.append(
            f'<img class="{css_cls}" src="data:image/png;base64,{b64}"'
            f' style="width:96px;height:96px;object-fit:contain;'
            f'vertical-align:middle;margin-right:14px"/>'
        )
    return "".join(out)


# ── Home page content ─────────────────────────────────────────────────────────
def _home():
    inject()
    inject_stop_style()

    st.markdown(
        f'<div style="display:flex;align-items:center;margin-bottom:4px">'
        f'{_logo_img_tag()}'
        f'<div>'
        f'<h1 style="margin:0;font-size:1.95em;color:{TEXT};'
        f'font-family:\'DM Serif Display\',Georgia,serif;font-weight:400;'
        f'letter-spacing:0.01em;line-height:1.15">Drosophila DL Tracking Suite</h1>'
        f'<p style="margin:4px 0 0 0;color:{MUTED};font-size:0.76em;'
        f'font-family:\'JetBrains Mono\',monospace;letter-spacing:0.04em">'
        f'FTIR pose estimation &nbsp;&middot;&nbsp; ground-contact tracking &nbsp;&middot;&nbsp; gait analysis'
        f'</p>'
        f'</div>'
        f'</div>',
        unsafe_allow_html=True,
    )
    st.divider()

    # ── Status cards ──────────────────────────────────────────────────────────
    bulk_ok   = BULK_NB.exists()
    al_ok     = AL_NB.exists()
    nb_dir_ok = NB_DIR.exists()

    def _status_card(label, ok):
        color  = GREEN if ok else "#ef4444"
        status = "Ready" if ok else "Not found"
        return (
            f'<div class="ft-status-card" style="background:{SURFACE};border:1px solid {BORDER};'
            f'border-radius:6px;padding:14px 18px">'
            f'<div class="ft-card-label" style="color:{MUTED};font-size:0.78em;margin-bottom:4px">{label}</div>'
            f'<div class="ft-card-status" style="color:{color};font-weight:600;font-size:0.95em">&#9679; {status}</div>'
            f'</div>'
        )

    c1, c2, c3 = st.columns(3)
    with c1: st.markdown(_status_card("Inference Pipeline folder", nb_dir_ok), unsafe_allow_html=True)
    with c2: st.markdown(_status_card("Bulk Pipeline notebook",    bulk_ok),   unsafe_allow_html=True)
    with c3: st.markdown(_status_card("Active Learning notebook",  al_ok),     unsafe_allow_html=True)

    st.divider()

    # ── Pipeline overview ──────────────────────────────────────────────────────
    st.markdown(
        f'<h3 style="color:{TEXT};margin-bottom:6px">Pipeline Overview</h3>'
        f'<p style="color:{MUTED};font-size:0.88em;line-height:1.7;margin-bottom:18px">'
        f'The <strong style="color:{TEXT}">Bulk Pipeline</strong> automates the full journey from raw FTIR video to gait analysis — '
        f'the DL model extracts ground-contact predictions frame by frame, which are reviewed and corrected in SLEAP, '
        f'then exported to FlyWalker for stance/swing analysis and result graphs. '
        f'The <strong style="color:{TEXT}">Active Learning loop</strong> uses those corrected labels as new training data '
        f'to fine-tune the model from its best checkpoint, feeding an improved model back into Phase 3 '
        f'so each correction cycle reduces the manual effort needed on future videos.'
        f'</p>',
        unsafe_allow_html=True,
    )

    # ── Layout helpers ─────────────────────────────────────────────────────────
    def _section_hdr(color, label, title, detail):
        return (
            f'<div style="background:{color}12;border:1px solid {color}30;border-left:3px solid {color};'
            f'border-radius:6px;padding:10px 16px;margin-bottom:6px;display:flex;'
            f'align-items:center;gap:14px">'
            f'<div>'
            f'<div style="color:{color};font-size:0.67em;font-weight:700;text-transform:uppercase;'
            f'letter-spacing:0.1em;margin-bottom:2px">{label}</div>'
            f'<div class="ft-section-hdr-title" style="color:{TEXT};font-weight:700;font-size:0.95em">{title}</div>'
            f'</div>'
            f'<div class="ft-section-hdr-detail" style="color:#4b5563;font-size:0.8em;border-left:1px solid {BORDER};'
            f'padding-left:14px;line-height:1.4">{detail}</div>'
            f'</div>'
        )

    def _phase_card(num, name, desc, color, step=False):
        badge = f"STEP {num}" if step else f"PHASE {num}"
        return (
            f'<div class="ft-phase-card" style="flex:1;min-width:0;background:#0b0f19;border:1px solid {BORDER};'
            f'border-top:2px solid {color};border-radius:0 0 6px 6px;padding:10px 12px">'
            f'<div style="color:{color};font-size:0.62em;font-weight:700;letter-spacing:0.08em;'
            f'margin-bottom:4px">{badge}</div>'
            f'<div class="ft-pc-name" style="color:{TEXT};font-weight:600;font-size:0.84em;margin-bottom:5px">{name}</div>'
            f'<div class="ft-pc-desc" style="color:#4b5563;font-size:0.76em;line-height:1.4">{desc}</div>'
            f'</div>'
        )

    def _row(*cards):
        inner = '<div style="width:5px;flex-shrink:0"></div>'.join(cards)
        return f'<div style="display:flex;gap:0">{inner}</div>'

    def _arrow(color_top, color_bot, label):
        return (
            f'<div style="display:flex;align-items:center;gap:10px;margin:6px 0 6px 16px">'
            f'<div style="display:flex;flex-direction:column;align-items:center">'
            f'<div style="width:2px;height:16px;background:linear-gradient({color_top},{color_bot})"></div>'
            f'<div style="color:{color_bot};font-size:0.85em;line-height:1">&#9660;</div>'
            f'</div>'
            f'<span class="ft-arrow-label" style="color:#374151;font-size:0.77em">{label}</span>'
            f'</div>'
        )

    # ─── SECTION 1 ────────────────────────────────────────────────────────────
    st.markdown(_section_hdr(PURPLE, "SECTION 1", "DL Model Inference",
        "Raw FTIR video &rarr; background-subtracted PNGs &rarr; AVI videos &rarr; ground-contact predictions"),
        unsafe_allow_html=True)
    p1 = _phase_card("1", "Raw Video Processing",  "BG subtraction &rarr; 3 PNG sets (colormap, no-colormap, raw)", PURPLE)
    p2 = _phase_card("2", "Video Export",           "PNG sets &rarr; lossless AVI (FFV1 codec, 250 FPS)", PURPLE)
    p3 = _phase_card("3", "Pose Estimation",        "SLEAP/ADPT model &rarr; per-frame ground-contact predictions", PURPLE)
    st.markdown(_row(p1, p2, p3), unsafe_allow_html=True)
    _cl, _ = st.columns([2, 8])
    with _cl: st.page_link("pages/1_Bulk_Pipeline.py", label="Open Bulk Pipeline →")

    st.markdown(_arrow(PURPLE, TEAL, "Inference complete — open SLEAP to review predictions"), unsafe_allow_html=True)

    # ─── SECTION 2 ────────────────────────────────────────────────────────────
    st.markdown(_section_hdr(TEAL, "SECTION 2", "Predictions Inspection",
        "Manual correction in SLEAP &rarr; trim frames &rarr; validate for FlyWalker"),
        unsafe_allow_html=True)
    p4 = _phase_card("4", "SLEAP Correction",       "Review keypoints frame by frame. Correct leg contacts (FTIR: only ground-touching legs visible).", TEAL)
    p5 = _phase_card("5", "Trim Frames",            "Remove trailing frames where fly stopped. Optional — skip if full video is usable.", TEAL)
    p6 = _phase_card("6", "Pre-flight Validation",  "Check leg event counts, L/R completeness, polygon crash risk. Fix FAILs before Section 3.", TEAL)
    st.markdown(_row(p4, p5, p6), unsafe_allow_html=True)

    st.markdown(_arrow(TEAL, GREEN, "Corrections saved — proceed to FlyWalker analysis"), unsafe_allow_html=True)

    # ─── SECTION 3 ────────────────────────────────────────────────────────────
    st.markdown(_section_hdr(GREEN, "SECTION 3", "FlyWalker Analysis",
        "Corrected labels &rarr; TRACKS.mat &rarr; MATLAB FlyWalker &rarr; gait analysis graphs"),
        unsafe_allow_html=True)
    p7  = _phase_card("7",  "Export Labels",    ".slp &rarr; .analysis.h5 via sleap-convert", GREEN)
    p8  = _phase_card("8",  "Extract Tracks",   "Body position, orientation &amp; leg contacts from HDF5", GREEN)
    p9  = _phase_card("9",  "Write MATLAB Data", "Generate TRACKS.mat in FlyWalker struct format", GREEN)
    p10 = _phase_card("10", "FlyWalker Analysis","MATLAB &rarr; stance/swing graphs + ResultSummary.xlsx", GREEN)
    st.markdown(_row(p7, p8, p9, p10), unsafe_allow_html=True)

    # ── Connector: Section 3 → Active Learning ────────────────────────────────
    st.markdown(
        f'<div style="display:flex;align-items:center;gap:10px;margin:8px 0 8px 16px">'
        f'<div style="display:flex;flex-direction:column;align-items:center">'
        f'<div style="width:2px;height:16px;background:linear-gradient({GREEN},{AMBER})"></div>'
        f'<div style="color:{AMBER};font-size:0.85em;line-height:1">&#9660;</div>'
        f'</div>'
        f'<span class="ft-arrow-label" style="color:#374151;font-size:0.77em">Corrected predictions become new labeled training data</span>'
        f'</div>',
        unsafe_allow_html=True,
    )

    # ─── ACTIVE LEARNING ──────────────────────────────────────────────────────
    st.markdown(_section_hdr(AMBER, "ACTIVE LEARNING", "Model Fine-tuning Loop",
        "Corrected data &rarr; merge &rarr; fine-tune &rarr; evaluate &rarr; improved model back to Section 1"),
        unsafe_allow_html=True)
    a1 = _phase_card("1", "Verify Labels",    "Check corrected .slp files and frame counts", AMBER, step=True)
    a2 = _phase_card("2", "Merge Datasets",   "Merge TRAIN + new videos, embed frames &rarr; .pkg.slp", AMBER, step=True)
    a3 = _phase_card("3", "Inspect (opt.)",   "Visual check in SLEAP GUI before training", AMBER, step=True)
    a4 = _phase_card("4", "Build Config",     "Fine-tune YAML: &frac110; LR, pretrained best.ckpt weights", AMBER, step=True)
    a5 = _phase_card("5", "HW Check (opt.)",  "Report CPU / GPU / RAM for training", AMBER, step=True)
    a6 = _phase_card("6", "Train",            "Fine-tune locally (CPU) or prepare Colab zip (GPU)", AMBER, step=True)
    a7 = _phase_card("7", "Evaluate",         "MPE, FP/FN rates, CR_frame vs base model", AMBER, step=True)
    st.markdown(_row(a1, a2, a3, a4, a5, a6, a7), unsafe_allow_html=True)
    _cl, _ = st.columns([2, 8])
    with _cl: st.page_link("pages/2_Active_Learning.py", label="Open Active Learning →")

    # ── Feedback loop indicator ───────────────────────────────────────────────
    st.markdown(
        f'<div style="border:1px dashed {AMBER}80;border-radius:6px;padding:10px 16px;'
        f'background:{AMBER}08;margin-top:10px;display:flex;align-items:center;gap:12px">'
        f'<span style="color:{AMBER};font-size:1.6em;line-height:1">&#8635;</span>'
        f'<div>'
        f'<div style="color:{AMBER};font-size:0.72em;font-weight:700;text-transform:uppercase;'
        f'letter-spacing:0.08em;margin-bottom:3px">Active Learning Loop</div>'
        f'<div style="color:{MUTED};font-size:0.82em">'
        f'Fine-tuned model returns to <strong style="color:{PURPLE}">Section 1, Phase 3</strong>'
        f' &mdash; set it as <code>MODEL_NAME</code> for better predictions on the next batch.'
        f'</div>'
        f'</div>'
        f'</div>',
        unsafe_allow_html=True,
    )

    st.divider()

    # ── Workflow guide ─────────────────────────────────────────────────────────
    st.markdown(f'<h3 style="color:{TEXT};margin-bottom:8px">Workflow</h3>', unsafe_allow_html=True)
    st.markdown(
        """
**Processing a new video batch:**
1. Go to **Bulk Pipeline → Section 1** — run Phases 1–3 to generate predictions.
2. Open SLEAP (Phase 4) and correct any wrong or missing leg contacts frame by frame.
3. Optionally trim trailing frames (Phase 5) if the fly stopped before the video ended.
4. Run **Pre-flight Validation (Phase 6)** — fix any FAILs before continuing.
5. Run **Section 3** — export labels, build TRACKS.mat, and run FlyWalker analysis.

**Improving the model (Active Learning):**
- After correcting predictions in SLEAP, go to **Active Learning**.
- Steps 1–2 merge the corrected labels with the original training set.
- Steps 4–5 fine-tune the model and evaluate it against the baseline.
- Set the new model as `MODEL_NAME` in Section 1, Phase 3 for the next batch.
        """
    )

    with st.expander("Path diagnostics & .slp health check", expanded=False):
        # ── Notebook paths ────────────────────────────────────────────────────
        bulk_ok = BULK_NB.exists()
        al_ok   = AL_NB.exists()
        st.code(
            f"NB_DIR  : {NB_DIR}\n"
            f"BULK_NB : {BULK_NB}  ({'exists' if bulk_ok else 'MISSING'})\n"
            f"AL_NB   : {AL_NB}  ({'exists' if al_ok else 'MISSING'})",
            language="",
        )

        st.markdown("---")
        st.markdown(
            f'<div class="ft-diag-title" style="color:{TEXT};font-weight:600;font-size:0.9em;margin-bottom:6px">'
            f'.slp video path health</div>'
            f'<div class="ft-diag-hint" style="color:{MUTED};font-size:0.8em;margin-bottom:10px">'
            f'Each .slp label file embeds absolute paths to its source videos. '
            f'If you move or rename the project folder, those paths break. '
            f'This scans all four locations — Dataset, Model Labels, Predictions, and '
            f'SLEAP Training — and re-links any broken paths to the current '
            f'<code>Videos/</code> folder automatically.'
            f'</div>',
            unsafe_allow_html=True,
        )

        if st.button("Scan .slp files", key="slp_scan"):
            st.session_state["slp_scan_results"] = scan_slp_paths(NB_DIR, ROOT_DIR)

        results = st.session_state.get("slp_scan_results")
        if results is not None:
            if not results:
                st.info("No .slp files found to check.")
            else:
                _CATEGORY_META = {
                    "dataset":     ("SLEAP Dataset",            "Inference_Pipeline/SLEAP_Dataset/"),
                    "models":      ("Model Eval Labels",         "Inference_Pipeline/Models/SLEAP_Models/*/"),
                    "predictions": ("Predictions",               "Inference_Pipeline/Predictions/"),
                    "training":    ("SLEAP Training (Colab)",    "SLEAP_Training/"),
                }

                # Group by category (preserving declaration order)
                grouped: dict[str, list[dict]] = {}
                for r in results:
                    grouped.setdefault(r["category"], []).append(r)

                any_fixable_global = any(r["paths_fixable"] for r in results)
                any_broken_global  = any(not r["all_ok"]    for r in results)

                for cat, cat_results in grouped.items():
                    cat_label, cat_hint = _CATEGORY_META.get(cat, (cat, ""))
                    n_ok    = sum(1 for r in cat_results if r["all_ok"])
                    n_total = len(cat_results)

                    all_cat_ok   = n_ok == n_total
                    any_cat_fix  = any(r["paths_fixable"] for r in cat_results)
                    any_cat_bad  = any(not r["all_ok"]    for r in cat_results)
                    hdr_color    = GREEN if all_cat_ok else AMBER if (not any_cat_bad or any_cat_fix) else "#ef4444"
                    hdr_icon     = "✓" if all_cat_ok else "⚠" if any_cat_fix else "✗"

                    st.markdown(
                        f'<div style="margin-top:14px;margin-bottom:4px;display:flex;'
                        f'align-items:baseline;gap:8px">'
                        f'<span class="ft-diag-icon" style="color:{hdr_color};font-size:0.78em">{hdr_icon}</span>'
                        f'<span class="ft-diag-title" style="color:{TEXT};font-weight:600;font-size:0.84em">{cat_label}</span>'
                        f'<span class="ft-diag-hint" style="color:{MUTED};font-size:0.74em">{n_ok}/{n_total} files OK'
                        f'&nbsp;&middot;&nbsp;{cat_hint}</span>'
                        f'</div>',
                        unsafe_allow_html=True,
                    )

                    for r in cat_results:
                        try:
                            rel = r["slp"].relative_to(ROOT_DIR)
                        except ValueError:
                            rel = r["slp"].name

                        if r["all_ok"]:
                            icon, color, detail = "✓", GREEN, "all paths OK"
                        elif r["all_fixable"]:
                            icon, color, detail = "⚠", AMBER, f"{len(r['paths_broken'])} broken — fixable"
                        else:
                            unfixable = len(r["paths_broken"]) - len(r["paths_fixable"])
                            icon, color, detail = "✗", "#ef4444", (
                                f"{len(r['paths_broken'])} broken"
                                + (f", {unfixable} video(s) not found in Videos/" if unfixable else " — fixable")
                            )

                        st.markdown(
                            f'<div style="font-family:monospace;font-size:0.78em;'
                            f'padding:2px 0 2px 16px;">'
                            f'<span class="ft-diag-icon" style="color:{color}">{icon}</span> '
                            f'<span class="ft-diag-path" style="color:{TEXT}">{rel}</span> '
                            f'<span class="ft-diag-det" style="color:{MUTED}">— {detail}</span>'
                            f'</div>',
                            unsafe_allow_html=True,
                        )

                        if not r["all_ok"] and r["paths_broken"]:
                            for bp in r["paths_broken"]:
                                fix_path = r["paths_fixable"].get(bp) or r["paths_fixable"].get(
                                    next((k for k in r["paths_fixable"]
                                          if k.replace("\\\\", "/").replace("\\", "/") == bp), None)
                                )
                                arrow = f"→ {fix_path}" if fix_path else "→ not found in Videos/"
                                st.markdown(
                                    f'<div class="ft-diag-det" style="font-family:monospace;font-size:0.72em;'
                                    f'color:{MUTED};padding-left:32px">'
                                    f'{bp}<br>{arrow}</div>',
                                    unsafe_allow_html=True,
                                )

                st.markdown("<div style='margin-top:10px'></div>", unsafe_allow_html=True)

                if any_fixable_global:
                    if st.button("Fix all fixable paths", key="slp_fix"):
                        fixed, failed = 0, 0
                        for r in results:
                            if r["paths_fixable"]:
                                ok, msg = fix_slp_paths(r["slp"], r["paths_fixable"])
                                if ok:
                                    fixed += 1
                                else:
                                    failed += 1
                                    st.warning(f"{r['slp'].name}: {msg}")
                        if fixed:
                            st.success(f"Fixed {fixed} file(s). Re-scan to verify.")
                            st.session_state.pop("slp_scan_results", None)
                        if failed:
                            st.error(f"{failed} file(s) could not be fixed — see warnings above.")
                elif any_broken_global:
                    st.warning(
                        "Some broken paths could not be resolved — the source video was not "
                        "found in any Videos/ subfolder. Move the video there and re-scan."
                    )
                else:
                    st.success("All .slp files have valid video paths.")

    st.markdown(
        f'<p style="color:#2d3748;font-size:0.70em;font-family:\'JetBrains Mono\',monospace;'
        f'margin-top:24px;letter-spacing:0.03em">'
        f'MSc Thesis &nbsp;&middot;&nbsp; Pedro Vasques &nbsp;&middot;&nbsp;'
        f'IST Lisboa / NOVA Medical School &nbsp;&middot;&nbsp; 2026'
        f'</p>',
        unsafe_allow_html=True,
    )


# ── Navigation ────────────────────────────────────────────────────────────────
pg = st.navigation([
    st.Page(_home,                          title="Home",            icon=":material/home:",           default=True),
    st.Page("pages/1_Bulk_Pipeline.py",     title="Bulk Pipeline",   icon=":material/biotech:"),
    st.Page("pages/2_Active_Learning.py",   title="Active Learning", icon=":material/model_training:"),
])
pg.run()
