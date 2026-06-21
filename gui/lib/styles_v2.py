"""Dark Field Microscopy aesthetic — drop-in replacement for styles.py."""
import html as _html_mod
import re as _re
import streamlit as st

# ── Colour palette ─────────────────────────────────────────────────────────────
BG       = "#020408"
SURFACE  = "#080d18"
BORDER   = "#141e2e"
ACCENT   = "#ff6835"

PURPLE   = "#818cf8"
PURPLE_H = "#6d7fef"
TEAL     = "#22d3ee"
TEAL_H   = "#06b6d4"
GREEN    = "#4ade80"
GREEN_H  = "#22c55e"
AMBER    = "#fbbf24"
ROSE     = "#fb7185"
ROSE_H   = "#f43f5e"

TEXT     = "#e2e8f0"
MUTED    = "#8899b4"

# ── Log helpers ────────────────────────────────────────────────────────────────
_SEP_RE  = _re.compile(r'^[=\-─]{6,}\s*$')
_ERR_RE  = _re.compile(r'\b(error|fail|failed|traceback|exception|fatal|critical)\b', _re.I)
_OK_RE   = _re.compile(r'\b(ok|pass|done|success|complete|saved|found|loaded|finished|written)\b', _re.I)
_WARN_RE = _re.compile(r'\b(warn|warning|skip|skipping|note|caution)\b', _re.I)


def log_to_html(text: str) -> str:
    lines = text.splitlines()
    n = len(lines)
    out = []
    for i, line in enumerate(lines):
        esc = _html_mod.escape(line)
        s   = line.strip()
        if _SEP_RE.match(s):
            out.append(f'<span style="color:#141e2e;font-size:6px;display:block;line-height:2.2">{esc}</span>')
        elif s and (
            (i > 0     and _SEP_RE.match(lines[i - 1].strip())) or
            (i < n - 1 and _SEP_RE.match(lines[i + 1].strip()))
        ):
            out.append(f'<span style="color:#4a5568;font-size:9px;font-weight:600;letter-spacing:0.06em">{esc}</span>')
        elif _ERR_RE.search(s):
            out.append(f'<span style="color:{ROSE}">{esc}</span>')
        elif _OK_RE.search(s):
            out.append(f'<span style="color:{GREEN}">{esc}</span>')
        elif _WARN_RE.search(s):
            out.append(f'<span style="color:{AMBER}">{esc}</span>')
        else:
            out.append(esc)
    return "\n".join(out)


# ── CSS ────────────────────────────────────────────────────────────────────────
COMMON_CSS = f"""
<style>
@import url('https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=JetBrains+Mono:wght@400;600;700&display=swap');

/* ── Grain ──────────────────────────────────────────────────────────────────── */
body::after {{
    content:'';position:fixed;inset:0;pointer-events:none;z-index:2147483646;
    background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.75' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");
    background-size:200px 200px;opacity:0.025;mix-blend-mode:overlay;
}}

/* ── Base ───────────────────────────────────────────────────────────────────── */
.stApp {{ background-color:{BG}; }}
.stSidebar {{ background-color:{SURFACE};border-right:1px solid {BORDER}; }}
.stMainBlockContainer {{ padding-top:2.5rem !important; }}

/* ── Sidebar header — compress Streamlit's large default padding ─────────────── */
[data-testid="stSidebarHeader"] {{
    padding-top:14px !important;
    padding-bottom:12px !important;
    align-items:center !important;
    border-bottom:1px solid {BORDER};
}}

/* ── Sidebar text ────────────────────────────────────────────────────────────── */
.stSidebar label,.stSidebar .stSelectbox label,.stSidebar .stTextInput label,
.stSidebar .stTextArea label,.stSidebar p,.stSidebar span {{ color:white !important; }}
.stSidebar [data-testid="stVerticalBlock"] > * + * {{ margin-top:6px !important; }}
.stSidebar [data-testid="stWidgetLabel"] {{
    font-size:0.70em !important;letter-spacing:0.03em !important;
    margin-bottom:2px !important;opacity:0.75;
}}

/* ── Sidebar select border — applies to both selectbox and multiselect ────────── */
.stSidebar [data-baseweb="select"] > div {{
    border-color:rgba(255,255,255,0.15) !important;border-radius:3px !important;
}}
.stSidebar [data-baseweb="select"] > div:focus-within {{ border-color:rgba(255,255,255,0.55) !important; box-shadow:0 0 0 1px rgba(255,255,255,0.10) !important; }}
/* ── Sidebar SELECTBOX only — compact height, vertically centred, ellipsis ────── */
/* (multiselect is deliberately excluded so video tags are unaffected)            */
.stSidebar [data-testid="stSelectbox"] [data-baseweb="select"] > div {{
    min-height:24px !important;max-height:32px !important;overflow:hidden !important;
}}
.stSidebar [data-testid="stSelectbox"] [data-baseweb="selectValueContainer"] {{
    min-height:0 !important;padding-top:0 !important;padding-bottom:0 !important;
    display:flex !important;align-items:center !important;flex-wrap:nowrap !important;
}}
.stSidebar [data-testid="stSelectbox"] [data-baseweb="selectValueContainer"] > div,
.stSidebar [data-testid="stSelectbox"] [data-baseweb="selectValueContainer"] span {{
    white-space:nowrap !important;overflow:hidden !important;
    text-overflow:ellipsis !important;max-width:100% !important;
    font-size:0.76em !important;line-height:1 !important;
}}
.stSidebar [data-testid="stSelectbox"] label,
.stSidebar [data-testid="stMultiSelect"] label {{ font-size:0.70em !important;margin-bottom:1px !important; }}
/* ── Sidebar TEXT INPUT — identical sizing to selectbox (used as fallback widget) */
.stSidebar [data-testid="stTextInput"] [data-baseweb="input"] {{
    min-height:24px !important;max-height:32px !important;overflow:hidden !important;
    padding-top:0 !important;padding-bottom:0 !important;border-radius:3px !important;
    border-color:rgba(255,255,255,0.15) !important;
}}
.stSidebar [data-testid="stTextInput"] [data-baseweb="input"]:focus-within {{
    border-color:rgba(255,255,255,0.55) !important;
    box-shadow:0 0 0 1px rgba(255,255,255,0.10) !important;
}}
.stSidebar [data-testid="stTextInput"] input {{
    font-size:0.76em !important;padding-top:0 !important;padding-bottom:0 !important;
}}
.stSidebar [data-testid="stTextInput"] label {{
    font-size:0.70em !important;margin-bottom:1px !important;
}}

/* ── Segmented control — size only; native Streamlit style handles selection ──── */
.stSidebar [data-testid="stButtonGroup"] button {{
    font-size:9px !important;padding:2px 8px !important;
    transition:none !important;  /* kill transition to stop black flicker on selection change */
}}
.stSidebar [data-testid="stButtonGroup"] label {{ font-size:0.70em !important;margin-bottom:1px !important; }}

/* ── Main content select/multiselect labels ──────────────────────────────────── */
[data-testid="stMain"] [data-testid="stSelectbox"] label,
[data-testid="stMain"] [data-testid="stMultiSelect"] label {{
    font-size:0.8em !important;margin-bottom:1px !important;
}}

/* ── Multiselect tags — compact monospace card ───────────────────────────────── */
[data-baseweb="tag"] {{
    background:#050b14 !important;
    border:1px solid rgba(255,255,255,0.07) !important;
    border-left:2px solid {PURPLE} !important;  /* section colour overridden by JS */
    border-radius:2px !important;
    height:22px !important;min-height:22px !important;
    padding:0 !important;margin-left:3px !important;
    max-width:none !important;white-space:nowrap !important;
    transition:color 0.12s,background-color 0.12s,border-color 0.12s !important;
}}
[data-baseweb="tag"] span {{
    font-family:'JetBrains Mono',monospace !important;
    font-size:11px !important;line-height:22px !important;
    max-width:none !important;overflow:visible !important;
    text-overflow:unset !important;white-space:nowrap !important;
    padding:0 6px 0 9px !important;
}}
[data-baseweb="tag"] span[role="presentation"] {{
    padding:0 5px 0 0 !important;line-height:22px !important;
    font-size:11px !important;opacity:0.38 !important;
}}
/* ── Multiselect dropdown list items ─────────────────────────────────────────── */
[data-baseweb="menu"] [role="option"],
[data-baseweb="option"] {{
    font-family:'JetBrains Mono',monospace !important;
    font-size:11px !important;
}}
[data-baseweb="menu"] [data-baseweb="menu-item"],
[data-baseweb="popover"] [role="option"] {{
    font-family:'JetBrains Mono',monospace !important;
    font-size:11px !important;
}}

/* ── Input focus ─────────────────────────────────────────────────────────────── */
input:focus,textarea:focus,
[data-baseweb="input"] input:focus,[data-baseweb="textarea"] textarea:focus,
[data-baseweb="input"]:focus-within,[data-baseweb="textarea"]:focus-within {{
    border-color:rgba(255,255,255,0.55) !important;
    box-shadow:0 0 0 1px rgba(255,255,255,0.10) !important;outline:none !important;
}}

/* ── Regular st.button (non-icon) ────────────────────────────────────────────── */
[data-testid="stButton"] button:not(.vsc-btn) {{
    background:transparent !important;border:1px solid rgba(255,255,255,0.10) !important;
    border-radius:3px !important;color:rgba(255,255,255,0.55) !important;
    font-family:'JetBrains Mono',monospace !important;font-size:0.73em !important;
    letter-spacing:0.05em !important;transition:border-color 0.15s,background-color 0.15s,color 0.15s !important;
}}
[data-testid="stButton"] button:not(.vsc-btn):hover {{
    background:rgba(255,255,255,0.04) !important;
    border-color:rgba(255,255,255,0.22) !important;color:{TEXT} !important;
}}

/* ── Alert boxes ─────────────────────────────────────────────────────────────── */
[data-testid="stAlert"] {{ border-radius:3px !important;border-left-width:3px !important;font-size:0.83em !important; }}

/* ── Log boxes ───────────────────────────────────────────────────────────────── */
.log-box {{
    background:#040810;color:{MUTED};
    font-family:'JetBrains Mono','Fira Code',monospace;font-size:9.5px;
    padding:12px 14px;border-radius:4px;
    border-top:1px solid {BORDER};border-right:1px solid {BORDER};
    border-bottom:1px solid {BORDER};border-left:2px solid #22263a;
    height:260px;overflow-y:auto;white-space:pre-wrap;word-break:break-word;line-height:1.65;
}}
.log-box-tall {{
    background:#040810;color:{MUTED};
    font-family:'JetBrains Mono','Fira Code',monospace;font-size:9.5px;
    padding:12px 14px;border-radius:4px;
    border-top:1px solid {BORDER};border-right:1px solid {BORDER};
    border-bottom:1px solid {BORDER};border-left:2px solid #22263a;
    height:520px;overflow-y:auto;white-space:pre-wrap;word-break:break-word;line-height:1.65;
}}

/* ── Run-name box ────────────────────────────────────────────────────────────── */
.run-name-box {{
    background:#06101a;color:{TEAL};font-family:'JetBrains Mono',monospace;font-size:0.90em;
    padding:9px 14px;border-radius:3px;border:1px solid #0c2030;border-left:3px solid {TEAL};margin:8px 0;
}}

/* ── Schematic cards ─────────────────────────────────────────────────────────── */
.schematic-card {{
    background:{SURFACE};border:1px solid {BORDER};border-radius:4px;padding:14px 18px;flex:1;
}}

/* ── Number input buttons ────────────────────────────────────────────────────── */
[data-testid="stNumberInput"] button {{
    background-color:transparent !important;color:{MUTED} !important;box-shadow:none !important;
}}
[data-testid="stNumberInput"] button:hover {{
    background-color:rgba(255,255,255,0.05) !important;color:{TEXT} !important;
}}
[data-testid="stNumberInput"] button:focus,[data-testid="stNumberInput"] button:active {{
    background-color:rgba(255,255,255,0.05) !important;color:{TEXT} !important;
    box-shadow:none !important;outline:none !important;
}}

/* ── Expanders ───────────────────────────────────────────────────────────────── */
[data-testid="stExpander"] [data-testid="stMarkdownContainer"] p,
[data-testid="stExpander"] [data-testid="stMarkdownContainer"] li,
[data-testid="stExpander"] [data-testid="stMarkdownContainer"] blockquote {{
    font-size:0.81em !important;line-height:1.55 !important;color:{MUTED} !important;
}}
[data-testid="stExpander"] [data-testid="stMarkdownContainer"] strong {{ color:{TEXT} !important; }}
[data-testid="stExpander"] [data-testid="stMarkdownContainer"] code {{ font-size:0.87em !important; }}
[data-testid="stExpander"] [data-testid="stMarkdownContainer"] table {{ font-size:0.80em !important; }}

/* ── vsc-btn wrapper ─────────────────────────────────────────────────────────── */
[data-testid="stButton"]:has(button.vsc-btn) {{
    padding:0 !important;margin:4px 0 0 0 !important;line-height:1 !important;
    display:flex !important;align-items:flex-start !important;
    width:auto !important;min-width:0 !important;
}}
/* Hide unprocessed run/abort buttons until JS stamps .vsc-btn or data-vsc-done */
[data-testid="stMain"] [data-testid="stButton"] button:not(.vsc-btn):not([data-vsc-done]) {{
    opacity:0 !important;
}}

/* ── Animations ──────────────────────────────────────────────────────────────── */
@keyframes vsc-btn-in {{
    from {{ opacity:0;transform:translateX(-4px); }}
    to   {{ opacity:1;transform:translateX(0);    }}
}}
@keyframes vsc-pulse {{
    0%   {{ opacity:1;  transform:scale(1);    }}
    50%  {{ opacity:0.3;transform:scale(1.55); }}
    100% {{ opacity:1;  transform:scale(1);    }}
}}
@keyframes ft-brand-in {{
    from {{ opacity:0; }}
    to   {{ opacity:1; }}
}}

/* ── Theme toggle button — prevent Streamlit from adding its own hover styles ─── */
button.ft-theme-btn {{ outline:none !important; box-shadow:none !important; }}

/* ── Suppress Streamlit loading animation ────────────────────────────────────── */
[data-testid="stStatusWidget"] {{ display:none !important; }}
[data-testid="stSkeleton"],[data-testid="stSkeleton"] * {{ display:none !important; }}
[data-testid="stAppViewContainer"] > * {{ opacity:1 !important;transition:none !important; }}
[data-stale] {{ opacity:1 !important;transition:none !important; }}

/* ── Transitions on key switching elements ───────────────────────────────────── */
.stApp, [data-testid="stMain"], .stMainBlockContainer,
[data-baseweb="input"], [data-baseweb="textarea"],
[data-baseweb="select"] > div,
[data-testid="stButton"] button {{ transition: background-color 0.25s ease, color 0.25s ease, border-color 0.25s ease !important; }}
.ft-section-banner {{ transition: background-color 0.25s ease !important; }}
.ft-sb-title, .ft-sb-sub, .ft-pl-name, .ft-pl-note {{ transition: color 0.25s ease !important; }}

/* ── Prevent expander header flicker from fragment run_every polling ─────────── */
[data-testid="stExpander"] details > summary,
[data-testid="stExpander"] details > summary * {{
    transform: translateZ(0);
    -webkit-backface-visibility: hidden;
    backface-visibility: hidden;
    transition: none !important;
}}

/* ── Logo swap: dark/light theme ─────────────────────────────────────────────── */
.ft-logo-light {{ display:none !important; }}
.flytrack-light .ft-logo-dark {{ display:none !important; }}
.flytrack-light .ft-logo-light {{ display:inline-block !important; }}

/* ── Light theme ─────────────────────────────────────────────────────────────── */
/* Override Streamlit's dark theme CSS variables so they don't bleed into widgets */
.flytrack-light {{ --secondary-background-color:#ffffff; --background-color:#f0f4f8; }}

.flytrack-light .stApp, .flytrack-light [data-testid="stMain"],
.flytrack-light .stMainBlockContainer {{ background-color:#f0f4f8 !important; }}

/* Main content text — p is medium grey so strong at #0f172a stands out clearly */
.flytrack-light [data-testid="stMain"] p,
.flytrack-light [data-testid="stMain"] h1, .flytrack-light [data-testid="stMain"] h2,
.flytrack-light [data-testid="stMain"] h3,
.flytrack-light [data-testid="stMain"] li,
.flytrack-light [data-testid="stMain"] label {{ color:#475569 !important; }}
.flytrack-light [data-testid="stMain"] h1, .flytrack-light [data-testid="stMain"] h2,
.flytrack-light [data-testid="stMain"] h3 {{ color:#1e293b !important; }}
.flytrack-light [data-testid="stMain"] [data-testid="stMarkdownContainer"] p,
.flytrack-light [data-testid="stMain"] [data-testid="stMarkdownContainer"] li {{ color:#475569 !important; }}
/* strong tags have inline color styles — !important overrides them */
.flytrack-light [data-testid="stMain"] strong {{ color:#0f172a !important; }}
.flytrack-light [data-testid="stMain"] [data-testid="stMarkdownContainer"] strong {{ color:#0f172a !important; }}

/* Inputs/selects in main content */
.flytrack-light [data-testid="stMain"] [data-baseweb="input"],
.flytrack-light [data-testid="stMain"] [data-baseweb="textarea"] {{ background-color:#ffffff !important; border-color:rgba(15,23,42,0.14) !important; }}
.flytrack-light [data-testid="stMain"] input,
.flytrack-light [data-testid="stMain"] textarea {{ color:#0f172a !important; background-color:#ffffff !important; }}
/* Multiselect search input sits on top of the first tag — must be transparent */
.flytrack-light [data-testid="stMain"] [data-testid="stMultiSelect"] input {{ background-color:transparent !important; }}
.flytrack-light [data-baseweb="select"] > div {{ background-color:#ffffff !important; border-color:rgba(15,23,42,0.14) !important; }}

/* Expander header hover in light */
.flytrack-light [data-testid="stExpander"] summary {{
    transition:background-color 0.15s !important;
    border-radius:4px !important;
}}
.flytrack-light [data-testid="stExpander"] summary:hover {{
    background-color:rgba(15,23,42,0.04) !important;
    cursor:pointer !important;
}}

/* Expander text in light */
.flytrack-light [data-testid="stExpander"] summary {{ color:#0f172a !important; }}
.flytrack-light [data-testid="stExpander"] [data-testid="stMarkdownContainer"] p,
.flytrack-light [data-testid="stExpander"] [data-testid="stMarkdownContainer"] li {{ color:#64748b !important; }}
.flytrack-light [data-testid="stExpander"] [data-testid="stMarkdownContainer"] strong {{ color:#0f172a !important; }}

/* Expander border/bg — target all nested layers Streamlit might use */
.flytrack-light [data-testid="stExpander"],
.flytrack-light [data-testid="stExpander"] details,
.flytrack-light [data-testid="stExpander"] details > *,
.flytrack-light [data-testid="stExpanderDetails"] {{
    background-color:#f8fafc !important;
    border-color:rgba(15,23,42,0.09) !important;
}}

/* Tags in main content — base style; JS overrides with section colors */
.flytrack-light [data-testid="stMain"] [data-baseweb="tag"] {{ background-color:#e8edf4 !important; border-color:rgba(15,23,42,0.12) !important; border-left-color:#4f46e5 !important; }}
.flytrack-light [data-testid="stMain"] [data-baseweb="tag"] span {{ color:#0f172a !important; }}

/* Dropdown popup menus — target popover + all intermediate wrapper divs BaseWeb injects */
.flytrack-light [data-baseweb="popover"],
.flytrack-light [data-baseweb="popover"] > div,
.flytrack-light [data-baseweb="popover"] > div > div,
.flytrack-light [data-baseweb="popover"] > div > div > div {{ background-color:#ffffff !important; border-color:rgba(15,23,42,0.10) !important; }}
.flytrack-light [data-baseweb="menu"],
.flytrack-light [data-baseweb="menu"] > ul {{ background-color:#ffffff !important; }}
.flytrack-light [data-baseweb="menu"] [role="option"] {{ color:#0f172a !important; background-color:#ffffff !important; }}
.flytrack-light [data-baseweb="menu"] [role="option"] *,
.flytrack-light [data-baseweb="menu"] [role="option"] span,
.flytrack-light [data-baseweb="menu"] [role="option"] div {{ color:#0f172a !important; }}
.flytrack-light [data-baseweb="menu"] [role="option"]:hover {{ background-color:#f0f4f8 !important; }}
.flytrack-light [data-baseweb="menu"] [role="option"][aria-selected="true"] {{ background-color:#e8edf4 !important; }}
/* "No results" / "No options" message — plain div/li not marked as role=option */
.flytrack-light [data-baseweb="menu"] li {{ background-color:#ffffff !important; color:#64748b !important; }}
.flytrack-light [data-baseweb="menu"] > div {{ background-color:#ffffff !important; color:#64748b !important; }}
.flytrack-light [data-baseweb="menu"] p {{ background-color:#ffffff !important; color:#64748b !important; }}

/* Section banners in light */
.flytrack-light .ft-section-banner {{ background-color:#ffffff !important; }}
.flytrack-light .ft-sb-title {{ color:#0f172a !important; }}
.flytrack-light .ft-sb-sub {{ color:#64748b !important; }}

/* Phase label names in light */
.flytrack-light .ft-pl-name {{ color:#0f172a !important; }}
.flytrack-light .ft-pl-note {{ color:#64748b !important; }}

/* Run/stop buttons */
.flytrack-light [data-testid="stButton"] button:not(.vsc-btn) {{ border-color:rgba(15,23,42,0.14) !important; color:rgba(15,23,42,0.50) !important; }}
.flytrack-light [data-testid="stButton"] button:not(.vsc-btn):hover {{ background:rgba(15,23,42,0.04) !important; border-color:rgba(15,23,42,0.25) !important; color:#0f172a !important; }}

/* Number input — container border + input text */
.flytrack-light [data-testid="stNumberInput"] > div,
.flytrack-light [data-testid="stNumberInput"] [data-baseweb="input"],
.flytrack-light [data-testid="stNumberInput"] [data-baseweb="base-input"] {{
    background-color:#ffffff !important; border-color:rgba(15,23,42,0.14) !important;
    transition:border-color 0.15s,box-shadow 0.15s !important;
}}
.flytrack-light [data-testid="stNumberInput"] input {{ color:#0f172a !important; background-color:transparent !important; }}
.flytrack-light [data-testid="stNumberInput"] button {{ color:#64748b !important; }}
.flytrack-light [data-testid="stNumberInput"] button:hover {{ background-color:rgba(15,23,42,0.05) !important; color:#0f172a !important; }}
/* Number input focus — outer ring on whole box only */
.flytrack-light [data-testid="stNumberInput"] > div:focus-within {{
    border-color:rgba(15,23,42,0.80) !important;
    box-shadow:0 0 0 2px rgba(15,23,42,0.08) !important;
    outline:none !important;
}}
/* Inner elements: darken border only — no shadow (prevents the inner shadow near the +/- buttons) */
.flytrack-light [data-testid="stNumberInput"] > div:focus-within [data-baseweb="input"],
.flytrack-light [data-testid="stNumberInput"] > div:focus-within [data-baseweb="base-input"] {{
    border-color:rgba(15,23,42,0.80) !important;
    box-shadow:none !important;
    outline:none !important;
}}

/* Focus selection ring — all input/select/textarea boxes in light mode */
.flytrack-light [data-baseweb="input"],
.flytrack-light [data-baseweb="textarea"],
.flytrack-light [data-baseweb="select"] > div {{
    transition:border-color 0.15s,box-shadow 0.15s !important;
}}
.flytrack-light [data-baseweb="input"]:focus-within,
.flytrack-light [data-baseweb="textarea"]:focus-within {{
    border-color:rgba(15,23,42,0.80) !important;
    box-shadow:0 0 0 2px rgba(15,23,42,0.08) !important;
    outline:none !important;
}}
/* Select ring — JS observer handles this via aria-expanded; CSS :focus is a fallback for the click moment */
.flytrack-light [data-baseweb="select"] > div[aria-expanded="true"],
.flytrack-light [data-baseweb="select"] > div:focus {{
    border-color:rgba(15,23,42,0.80) !important;
    box-shadow:0 0 0 2px rgba(15,23,42,0.08) !important;
    outline:none !important;
}}
/* Suppress browser default grey outline on all focusable inputs in light mode */
.flytrack-light input:focus,
.flytrack-light textarea:focus,
.flytrack-light [data-baseweb="select"] > div:focus-visible {{
    outline:none !important;
}}

/* Alert boxes */
.flytrack-light [data-testid="stAlert"] {{ background-color:#ffffff !important; }}

/* Code blocks — st.code() widget; force all token spans dark (overrides syntax highlighting) */
.flytrack-light [data-testid="stCode"] {{ background-color:#f1f5f9 !important; border:1px solid rgba(15,23,42,0.08) !important; border-radius:4px !important; }}
.flytrack-light [data-testid="stCode"] pre {{ background-color:#f1f5f9 !important; color:#334155 !important; }}
.flytrack-light [data-testid="stCode"] code,
.flytrack-light [data-testid="stCode"] code * {{ background-color:transparent !important; color:#334155 !important; }}
/* Inline code — keep the professional green look, use dark green readable on light bg */
.flytrack-light [data-testid="stMain"] code:not([data-testid="stCode"] code),
.flytrack-light [data-testid="stExpander"] code:not([data-testid="stCode"] code) {{ background-color:#dcfce7 !important; color:#15803d !important; border-radius:3px !important; }}

/* Grain — lighter touch on light bg */
.flytrack-light body::after {{ opacity:0.018 !important; mix-blend-mode:multiply !important; }}

/* ── Sidebar light ───────────────────────────────────────────────────────── */
.flytrack-light .stSidebar {{
    background-color:#f8fafc !important;
    border-right-color:rgba(15,23,42,0.09) !important;
}}
.flytrack-light [data-testid="stSidebarHeader"] {{
    border-bottom-color:rgba(15,23,42,0.09) !important;
}}
.flytrack-light .stSidebar label,
.flytrack-light .stSidebar .stSelectbox label,
.flytrack-light .stSidebar .stTextInput label,
.flytrack-light .stSidebar .stTextArea label,
.flytrack-light .stSidebar p,
.flytrack-light .stSidebar span {{ color:#0f172a !important; }}
.flytrack-light .stSidebar [data-testid="stWidgetLabel"] {{ opacity:0.60 !important; }}
.flytrack-light .stSidebar [data-baseweb="select"] > div {{
    background-color:#ffffff !important;
    border-color:rgba(15,23,42,0.14) !important;
}}
.flytrack-light .stSidebar [data-testid="stTextInput"] [data-baseweb="input"],
.flytrack-light .stSidebar [data-testid="stTextInput"] [data-baseweb="base-input"] {{
    background-color:#ffffff !important;
    border-color:rgba(15,23,42,0.14) !important;
}}
.flytrack-light .stSidebar [data-testid="stTextInput"] [data-baseweb="input"]:focus-within {{
    border-color:rgba(15,23,42,0.80) !important;
    box-shadow:0 0 0 2px rgba(15,23,42,0.08) !important;
}}
.flytrack-light .stSidebar [data-testid="stTextInput"] input {{
    color:#0f172a !important;
    background-color:transparent !important;
}}

/* ── Top / header bar light ──────────────────────────────────────────────── */
.flytrack-light [data-testid="stHeader"] {{
    background-color:#f8fafc !important;
    border-bottom:1px solid rgba(15,23,42,0.09) !important;
}}
.flytrack-light [data-testid="stToolbar"] button,
.flytrack-light [data-testid="stDecoration"] {{ color:#64748b !important; }}

/* ── Log boxes light ─────────────────────────────────────────────────────── */
.flytrack-light .log-box,
.flytrack-light .log-box-tall {{
    background:#f1f5f9 !important;
    color:#334155 !important;
    border-top-color:rgba(15,23,42,0.08) !important;
    border-right-color:rgba(15,23,42,0.08) !important;
    border-bottom-color:rgba(15,23,42,0.08) !important;
    border-left-color:rgba(15,23,42,0.20) !important;
}}

/* ── Home page status cards light ────────────────────────────────────────── */
.flytrack-light .ft-status-card {{
    background-color:#ffffff !important;
    border-color:rgba(15,23,42,0.09) !important;
}}
.flytrack-light .ft-status-card .ft-card-label {{ color:#64748b !important; }}
/* Remap neon green "Ready" to readable dark green */
.flytrack-light .ft-card-status[style*="#4ade80"] {{ color:#16a34a !important; }}

/* ── Home page phase cards light ─────────────────────────────────────────── */
.flytrack-light .ft-phase-card {{
    background-color:#ffffff !important;
    border-color:rgba(15,23,42,0.09) !important;
}}
.flytrack-light .ft-phase-card .ft-pc-name {{ color:#0f172a !important; }}
.flytrack-light .ft-phase-card .ft-pc-desc {{ color:#64748b !important; }}

/* ── Home page section headers light ─────────────────────────────────────── */
.flytrack-light .ft-section-hdr-title {{ color:#475569 !important; }}
.flytrack-light .ft-section-hdr-detail {{ color:#64748b !important; border-left-color:rgba(15,23,42,0.09) !important; }}

/* ── Connector / arrow text light ────────────────────────────────────────── */
.flytrack-light .ft-arrow-label {{ color:#475569 !important; }}

/* ── Path diagnostics scan output light ─────────────────────────────────── */
.flytrack-light .ft-diag-title {{ color:#1e293b !important; }}
.flytrack-light .ft-diag-hint  {{ color:#64748b !important; }}
.flytrack-light .ft-diag-path  {{ color:#334155 !important; }}
.flytrack-light .ft-diag-det   {{ color:#64748b !important; }}
/* Remap neon dark-mode status colours to readable light-mode equivalents */
.flytrack-light .ft-diag-icon[style*="#4ade80"] {{ color:#16a34a !important; }}
.flytrack-light .ft-diag-icon[style*="#fbbf24"] {{ color:#d97706 !important; }}

/* ── Segmented control (sidebar) — strip Streamlit's grey container ────── */
/* JS handles per-button bg/color; CSS baseline prevents dark flash before JS fires */
.flytrack-light .stSidebar [data-testid="stButtonGroup"],
.flytrack-light .stSidebar [data-testid="stButtonGroup"] > div {{
    background-color:transparent !important;
    border-color:rgba(15,23,42,0.10) !important;
}}
/* CSS baseline: unselected buttons are transparent/grey — matches JS value exactly.
   This means buttons are NEVER dark on first render in light mode; JS only upgrades
   the selected button to white+shadow without any visible intermediate dark state. */
.flytrack-light .stSidebar [data-testid="stButtonGroup"] button {{
    background-color:transparent !important;
    color:#94a3b8 !important;
    border-color:transparent !important;
}}

/* ── Segmented control (main content) — same baseline as sidebar ─────── */
.flytrack-light [data-testid="stMain"] [data-testid="stButtonGroup"],
.flytrack-light [data-testid="stMain"] [data-testid="stButtonGroup"] > div {{
    background-color:transparent !important;
    border-color:rgba(15,23,42,0.10) !important;
}}
.flytrack-light [data-testid="stMain"] [data-testid="stButtonGroup"] button {{
    background-color:transparent !important;
    color:#94a3b8 !important;
    border-color:transparent !important;
}}

/* ── Sidebar select value text / section headers ─────────────────────── */
.flytrack-light .stSidebar [data-baseweb="selectValueContainer"],
.flytrack-light .stSidebar [data-baseweb="selectValueContainer"] * {{ color:#0f172a !important; }}
.flytrack-light .stSidebar [data-testid="stMarkdownContainer"] div {{ color:#0f172a !important; }}

/* ── Main content select/multiselect value text ──────────────────────── */
.flytrack-light [data-testid="stMain"] [data-baseweb="selectValueContainer"],
.flytrack-light [data-testid="stMain"] [data-baseweb="selectValueContainer"] * {{ color:#0f172a !important; }}
/* singleValue = the element BaseWeb actually puts selected text into (different Streamlit versions vary) */
.flytrack-light [data-baseweb="singleValue"] {{ color:#0f172a !important; }}
.flytrack-light [data-testid="stMain"] [data-baseweb="select"] input {{ color:#0f172a !important; }}
.flytrack-light [data-testid="stMain"] [data-baseweb="selectPlaceholder"] {{ color:#94a3b8 !important; }}
/* Selectbox label in light mode — Streamlit defaults to its dark-theme label colour */
.flytrack-light [data-testid="stMain"] [data-testid="stSelectbox"] label {{ color:#475569 !important; }}

/* ── Multiselect left-border not clipped (dark + light) ─────────────── */
/* overflow:visible on all three levels so flex layout can't clip the tag left border */
[data-testid="stMain"] [data-testid="stMultiSelect"] [data-baseweb="select"] {{
    overflow:visible !important;
}}
[data-testid="stMain"] [data-testid="stMultiSelect"] [data-baseweb="select"] > div {{
    overflow:visible !important;
}}
[data-testid="stMain"] [data-testid="stMultiSelect"] [data-baseweb="selectValueContainer"] {{
    padding-left:3px !important;overflow:visible !important;
}}

/* ── Markdown tables in light mode ───────────────────────────────────── */
.flytrack-light [data-testid="stMarkdownContainer"] td,
.flytrack-light [data-testid="stMarkdownContainer"] th {{ color:#334155 !important; }}
.flytrack-light [data-testid="stMarkdownContainer"] th {{
    background-color:rgba(15,23,42,0.04) !important;
}}
.flytrack-light [data-testid="stMarkdownContainer"] table,
.flytrack-light [data-testid="stMarkdownContainer"] td,
.flytrack-light [data-testid="stMarkdownContainer"] th {{
    border-color:rgba(15,23,42,0.10) !important;
}}

/* ── Image zoom wrapper & expand button ─────────────────────────────── */
.ft-img-wrap {{ position:relative; display:block; }}
.ft-img-wrap img {{ display:block; border-radius:3px; width:100%; }}
.ft-img-btn {{
    position:absolute; top:8px; right:8px;
    width:28px; height:28px;
    background:rgba(2,4,8,0.58);
    border:1px solid rgba(255,255,255,0.18);
    border-radius:6px;
    display:flex; align-items:center; justify-content:center;
    cursor:pointer; opacity:0;
    transition:opacity 0.18s ease, background 0.12s ease;
    color:rgba(255,255,255,0.82);
    padding:0;
}}
.ft-img-wrap:hover .ft-img-btn {{ opacity:1; }}
.ft-img-btn:hover {{ background:rgba(2,4,8,0.88) !important; color:rgba(255,255,255,1) !important; }}
.flytrack-light .ft-img-btn {{
    background:rgba(255,255,255,0.86);
    border-color:rgba(15,23,42,0.16);
    color:rgba(15,23,42,0.60);
}}
.flytrack-light .ft-img-btn:hover {{ background:rgba(255,255,255,1) !important; color:rgba(15,23,42,0.90) !important; }}

/* ── Compact number inputs (main content only — sidebar inputs match selectbox) */
[data-testid="stMain"] [data-testid="stNumberInput"] label{{font-size:0.80em !important;margin-bottom:1px !important;line-height:1.2 !important;}}
[data-testid="stMain"] [data-testid="stNumberInput"] [data-baseweb="input"]{{min-height:30px !important;height:30px !important;}}
[data-testid="stMain"] [data-testid="stNumberInput"] input{{font-size:0.84em !important;padding:2px 8px !important;height:30px !important;}}
[data-testid="stMain"] [data-testid="stNumberInput"]{{margin-bottom:4px !important;}}

</style>
"""

_STOP_JS = """
<script>
(function() {
    try {
        var doc     = window.parent.document;
        var banners = [];

        // ── Theme initialisation from localStorage ──
        // Default is light; only use dark if the user has explicitly saved 'dark'.
        (function(){
            var saved = localStorage.getItem('flytrack-theme');
            if (saved !== 'dark') {
                doc.body.classList.add('flytrack-light');
                if (!saved) localStorage.setItem('flytrack-theme', 'light');
            }
        })();
        // Inject persistent <head> style immediately — survives page navigation, prevents black flash.
        // Function declaration is hoisted so calling it here (before its definition) is safe.
        injectPersistentStyle();

        function isDark() { return !doc.body.classList.contains('flytrack-light'); }

        // Persistent <head> style: minimal critical CSS that survives Streamlit page navigation.
        // COMMON_CSS is injected into the React root (body) on each page — there's a gap between
        // navigation and re-injection where these head styles are the only thing keeping the bg correct.
        function injectPersistentStyle() {
            var _id = 'ft-persistent';
            var _el = doc.getElementById(_id);
            if (!_el) { _el = doc.createElement('style'); _el.id = _id; doc.head.appendChild(_el); }
            var _light = !isDark();
            _el.textContent = (
                // Always active: smooth bg transition so page-switch doesn't snap to black then back
                '.stApp,[data-testid="stMain"],.stMainBlockContainer,'
                +'.stSidebar,[data-testid="stHeader"],[data-testid="stSidebarHeader"]{'
                +'transition:background-color 0.20s ease!important}'
            ) + (_light ? (
                // Light mode: force bg immediately (before COMMON_CSS loads on next page)
                'body.flytrack-light{background-color:#f0f4f8!important}'
                +'.flytrack-light .stApp,.flytrack-light [data-testid="stAppViewContainer"],'
                +'.flytrack-light [data-testid="stMain"],.flytrack-light .stMainBlockContainer,'
                +'.flytrack-light [data-testid="stAppViewBlockContainer"]'
                +'{background-color:#f0f4f8!important}'
                +'.flytrack-light .stSidebar,.flytrack-light .stSidebar>div'
                +'{background-color:#f8fafc!important}'
                +'.flytrack-light [data-testid="stHeader"],'
                +'.flytrack-light [data-testid="stSidebarHeader"]'
                +'{background-color:#f8fafc!important}'
                // Select value text — put in <head> so it wins source-order battles against
                // Emotion/Styletron which also inject into <head> but after COMMON_CSS (body)
                +'.flytrack-light [data-baseweb="singleValue"],'
                +'.flytrack-light [data-baseweb="selectValueContainer"] *'
                +'{color:#0f172a!important}'
            ) : '');
        }

        // ── Theme toggle — flag-based so the button works across page navigations ──
        // The button onclick ONLY writes doc._vscThemeFlag (a property on the stable
        // parent document object — no cross-iframe function calls, no dead globals).
        // styleAll() checks the flag on every 150ms tick and applies the theme there,
        // inside the currently alive iframe's own execution context.
        window.parent.flytrackToggleTheme = function() {
            doc._vscThemeFlag = doc.body.classList.contains('flytrack-light') ? 'dark' : 'light';
        };

        function computeBanners() {
            banners = [];
            var dark = isDark();
            doc.querySelectorAll('[data-testid="stMarkdownContainer"]').forEach(function(el) {
                var t = el.textContent || '';
                var color = null;
                if      (t.indexOf('Section 1') !== -1 && t.indexOf('DL Model') !== -1)    color = '#818cf8';
                else if (t.indexOf('Section 2') !== -1 && t.indexOf('Predictions') !== -1) color = '#22d3ee';
                else if (t.indexOf('Section 3') !== -1 && t.indexOf('FlyWalker') !== -1)   color = '#4ade80';
                else if (t.indexOf('ACTIVE LEARNING') !== -1)                               color = '#fbbf24';
                if (color) banners.push({el:el, color:color});
            });
            banners.sort(function(a,b){ return (a.el.compareDocumentPosition(b.el)&4)?-1:1; });
        }

        function sectionColor(el) {
            var clr = '#818cf8';
            for (var i=0;i<banners.length;i++)
                if (banners[i].el.compareDocumentPosition(el)&4) clr = banners[i].color;
            return clr;
        }

        function styleSegCtrl(grp) {
            var dark = isDark();
            // Strip Streamlit's dark inline background from container + inner wrapper
            grp.style.setProperty('background-color','transparent','important');
            var inner = grp.querySelector('div');
            if (inner) inner.style.setProperty('background-color','transparent','important');

            // Filter out help/tooltip buttons (Streamlit renders "?" inside stButtonGroup
            // when help= is set on st.segmented_control — skip those non-option buttons)
            var buttons = [];
            grp.querySelectorAll('button').forEach(function(b){
                var txt = (b.textContent || '').trim();
                if (txt && txt !== '?' && !b.closest('[data-testid*="Tooltip"]')) buttons.push(b);
            });
            if (!buttons.length) return;

            // ── Detect which button Streamlit considers selected ──────────────
            // On the very first call after a (re)render, Streamlit's React has already
            // set an inline background-color on the selected button — read it before
            // we clear anything. Store in dataset so we don't re-detect next tick.
            if (!grp.dataset.vscSegDone) {
                grp.dataset.vscSegDone = '1';
                var foundIdx = -1;
                buttons.forEach(function(b, i){
                    // Try aria attributes first (future-proof)
                    if (b.getAttribute('aria-pressed')==='true'
                     || b.getAttribute('aria-checked')==='true'
                     || b.getAttribute('aria-selected')==='true'
                     || b.getAttribute('data-active')==='true') {
                        foundIdx = i; return;
                    }
                    // Fallback: detect from Streamlit's inline background
                    var bg = b.style.backgroundColor;
                    if (foundIdx === -1 && bg && bg !== 'transparent' && bg !== 'rgba(0, 0, 0, 0)' && bg !== '') {
                        foundIdx = i;
                    }
                });
                grp.dataset.vscSegSel = String(foundIdx !== -1 ? foundIdx : 0);

                // Track user clicks — re-filter at click time to get correct index
                grp.addEventListener('click', function(e){
                    var btn = e.target.closest('button');
                    if (!btn) return;
                    var txt2 = (btn.textContent || '').trim();
                    if (!txt2 || txt2 === '?' || btn.closest('[data-testid*="Tooltip"]')) return;
                    var curBtns = [];
                    grp.querySelectorAll('button').forEach(function(b2){
                        var t = (b2.textContent || '').trim();
                        if (t && t !== '?' && !b2.closest('[data-testid*="Tooltip"]')) curBtns.push(b2);
                    });
                    var idx = -1;
                    curBtns.forEach(function(b2, i){ if (b2 === btn) idx = i; });
                    if (idx !== -1) { grp.dataset.vscSegSel = String(idx); }
                });
            }

            var selIdx = parseInt(grp.dataset.vscSegSel || '0', 10);

            buttons.forEach(function(b, i){
                b.style.setProperty('padding',  '2px 8px','important');
                b.style.setProperty('font-size','9px','important');
                var sel = (i === selIdx);
                if (sel) {
                    b.style.setProperty('background-color', dark ? 'rgba(255,255,255,0.16)' : '#ffffff','important');
                    b.style.setProperty('color',            dark ? '#ffffff'                 : '#0f172a','important');
                    b.style.setProperty('box-shadow', dark ? '0 0 0 1px rgba(255,255,255,0.10)' : '0 2px 6px rgba(15,23,42,0.20)','important');
                    b.style.setProperty('font-weight','600','important');
                } else {
                    b.style.setProperty('background-color','transparent','important');
                    b.style.setProperty('color', dark ? 'rgba(255,255,255,0.40)' : '#94a3b8','important');
                    b.style.setProperty('box-shadow','none','important');
                    b.style.setProperty('font-weight','400','important');
                }
            });
        }

        function styleButton(b) {
            if (b.closest('[data-testid="stSidebar"]')) { b.dataset.vscDone='1'; return; }
            var txt   = (b.innerText||b.textContent||'').trim();
            var first = txt.charAt(0);
            if (first!=='\u25b6' && first!=='\u25a0' && first!=='\u21ba') { b.dataset.vscDone='1'; return; }

            var dis = b.disabled;
            var clr = sectionColor(b);

            if (!b.dataset.vscLabel) {
                var raw = txt.slice(1).trim().toLowerCase();
                b.dataset.vscLabel = raw || (first==='\u25a0'?'abort':'run');
            }
            var label = b.dataset.vscLabel;

            var wrapper = b.closest('[data-testid="stButton"]');
            if (wrapper && !wrapper.dataset.vscWrapper) {
                wrapper.dataset.vscWrapper='1';
                wrapper.style.setProperty('padding','0','important');
                wrapper.style.setProperty('margin','4px 0 0 0','important');
                wrapper.style.setProperty('line-height','1','important');
                wrapper.style.setProperty('display','flex','important');
                wrapper.style.setProperty('align-items','flex-start','important');
                wrapper.style.setProperty('width','auto','important');
                wrapper.style.setProperty('min-width','0','important');
            }

            if (!b.classList.contains('vsc-btn')) {
                b.classList.add('vsc-btn');
                b.style.setProperty('animation','vsc-btn-in 0.18s ease-out both','important');
                setTimeout(function(){ b.style.removeProperty('animation'); },250);
            }

            b.style.setProperty('width','auto','important');
            b.style.setProperty('min-width','140px','important');
            b.style.setProperty('height','32px','important');
            b.style.setProperty('min-height','32px','important');
            b.style.setProperty('border-radius','3px','important');
            b.style.setProperty('padding','0 16px 0 10px','important');
            b.style.setProperty('display','flex','important');
            b.style.setProperty('align-items','center','important');
            b.style.setProperty('justify-content','flex-start','important');
            b.style.setProperty('gap','8px','important');
            b.style.setProperty('line-height','1','important');
            b.style.setProperty('box-shadow','none','important');
            b.style.setProperty('font-family','JetBrains Mono,Fira Code,monospace','important');
            b.style.setProperty('font-size','0.71em','important');
            b.style.setProperty('letter-spacing','0.06em','important');
            b.style.setProperty('transition',
                'background-color 0.15s ease,border-color 0.15s ease,color 0.15s ease','important');

            if (!b.dataset.vscHover) {
                b.dataset.vscHover='1';
                b._vscHovering=false;
                b.addEventListener('mouseenter',function(){
                    this._vscHovering=true;
                    if (!this.disabled&&this._vscBgHover)
                        this.style.setProperty('background-color',this._vscBgHover,'important');
                });
                b.addEventListener('mouseleave',function(){
                    this._vscHovering=false;
                    if (!this.disabled&&this._vscBgIdle)
                        this.style.setProperty('background-color',this._vscBgIdle,'important');
                });
            }

            if (first==='\u25b6') {
                if (!b.querySelector('.vsc-lbl')) {
                    b.innerHTML='<span style="font-size:10px;opacity:0.9;flex-shrink:0">\u25b6</span>'+
                                '<span class="vsc-lbl" style="white-space:nowrap">'+label+'</span>';
                }
                if (dis) {
                    var _dk=isDark();
                    b.style.setProperty('background-color','transparent','important');
                    b.style.setProperty('border','1px solid '+(_dk?'rgba(255,255,255,0.06)':'rgba(15,23,42,0.07)'),'important');
                    b.style.setProperty('border-left','3px solid '+(_dk?'rgba(255,255,255,0.08)':'rgba(15,23,42,0.09)'),'important');
                    b.style.setProperty('color',_dk?'rgba(255,255,255,0.18)':'rgba(15,23,42,0.22)','important');
                    b.style.setProperty('cursor','default','important');
                    b._vscBgIdle=null;b._vscBgHover=null;
                } else {
                    var _dk=isDark();
                    b._vscBgIdle = clr+(_dk?'10':'18'); b._vscBgHover = clr+(_dk?'22':'28');
                    b.style.setProperty('background-color',
                        (b._vscHovering ? b._vscBgHover : b._vscBgIdle),'important');
                    b.style.setProperty('border','1px solid '+clr+(_dk?'35':'55'),'important');
                    b.style.setProperty('border-left','3px solid '+clr,'important');
                    b.style.setProperty('color',clr,'important');
                    b.style.setProperty('cursor','pointer','important');
                }
                return;
            }

            if (first==='\u21ba') {
                if (!b.querySelector('.vsc-lbl')) {
                    b.innerHTML='<span style="font-size:11px;opacity:0.9;flex-shrink:0">\u21ba</span>'+
                                '<span class="vsc-lbl" style="white-space:nowrap">'+label+'</span>';
                }
                var _dk=isDark();
                b._vscBgIdle = clr+(_dk?'10':'18'); b._vscBgHover = clr+(_dk?'22':'28');
                b.style.setProperty('background-color',
                    (b._vscHovering ? b._vscBgHover : b._vscBgIdle),'important');
                b.style.setProperty('border','1px solid '+clr+(_dk?'35':'55'),'important');
                b.style.setProperty('border-left','3px solid '+clr,'important');
                b.style.setProperty('color',clr,'important');
                b.style.setProperty('cursor','pointer','important');
                return;
            }

            if (first==='\u25a0') {
                if (dis) {
                    if (!b.querySelector('.vsc-lbl')) {
                        b.innerHTML='<span style="font-size:10px;opacity:0.3;flex-shrink:0">\u25a0</span>'+
                                    '<span class="vsc-lbl" style="white-space:nowrap;opacity:0.3">stop</span>';
                    }
                    var _dk=isDark();
                    b.style.setProperty('background-color','transparent','important');
                    b.style.setProperty('border','1px solid '+(_dk?'rgba(255,255,255,0.05)':'rgba(15,23,42,0.06)'),'important');
                    b.style.setProperty('border-left','3px solid '+(_dk?'rgba(255,255,255,0.07)':'rgba(15,23,42,0.08)'),'important');
                    b.style.setProperty('color',_dk?'rgba(255,255,255,0.20)':'rgba(15,23,42,0.20)','important');
                    b.style.setProperty('cursor','default','important');
                    b._vscBgIdle=null;b._vscBgHover=null;
                } else {
                    if (!b.querySelector('.vsc-pulse-dot')) {
                        b.innerHTML='<span class="vsc-pulse-dot" style="'+
                            'display:inline-block;width:7px;height:7px;border-radius:50%;'+
                            'background:'+clr+';flex-shrink:0;'+
                            'animation:vsc-pulse 1.4s ease-in-out infinite'+
                            '"></span>'+
                            '<span class="vsc-lbl" style="white-space:nowrap">abort</span>';
                    }
                    var _dk=isDark();
                    b._vscBgIdle = clr+(_dk?'10':'18'); b._vscBgHover = clr+(_dk?'22':'28');
                    b.style.setProperty('background-color',
                        (b._vscHovering ? b._vscBgHover : b._vscBgIdle),'important');
                    b.style.setProperty('border','1px solid '+clr+(_dk?'35':'55'),'important');
                    b.style.setProperty('border-left','3px solid '+clr,'important');
                    b.style.setProperty('color',clr,'important');
                    b.style.setProperty('cursor','pointer','important');
                }
            }
        }

        function injectBrand(header) {
            if (!header || header.querySelector('.ft-brand')) return;
            var dark          = isDark();
            var titleColor    = dark ? 'white'                  : '#0f172a';
            var subtitleColor = dark ? '#8899b4'                : '#64748b';
            var btnColor      = dark ? 'rgba(255,255,255,0.45)' : 'rgba(15,23,42,0.35)';
            var btnHoverColor = dark ? 'rgba(255,255,255,0.9)'  : 'rgba(15,23,42,0.8)';
            var btnHoverBg    = dark ? 'rgba(255,255,255,0.08)' : 'rgba(15,23,42,0.06)';
            var brand = doc.createElement('div');
            brand.className = 'ft-brand';
            brand.style.cssText = 'display:flex;align-items:center;gap:9px;flex:1 1 auto;min-width:0;animation:ft-brand-in 0.15s ease-out';
            brand.innerHTML = (
                '<div>'+
                    '<div style="font-family:DM Serif Display,Georgia,serif;'+
                        'color:'+titleColor+';font-size:18px;font-weight:400;'+
                        'letter-spacing:0.04em;line-height:1.2">Flytrack</div>'+
                    '<div style="font-family:JetBrains Mono,monospace;'+
                        'color:'+subtitleColor+';font-size:9px;letter-spacing:0.10em;'+
                        'text-transform:uppercase;margin-top:2px">NOVA Medical School</div>'+
                '</div>'
            );
            var tBtn = doc.createElement('button');
            tBtn.className = 'ft-theme-btn';
            tBtn.textContent = dark ? '◐' : '◑';
            tBtn.title       = dark ? 'Switch to light mode' : 'Switch to dark mode';
            tBtn.style.cssText = (
                'background:none;border:none;cursor:pointer;padding:5px;'
                +'color:'+btnColor+';font-size:15px;line-height:1;'
                +'display:flex;align-items:center;justify-content:center;'
                +'border-radius:3px;transition:color 0.15s,background-color 0.15s;'
                +'flex-shrink:0;margin-left:auto'
            );
            tBtn.onmouseenter = function(){
                this.style.setProperty('color', btnHoverColor, 'important');
                this.style.setProperty('background-color', btnHoverBg, 'important');
            };
            tBtn.onmouseleave = function(){
                this.style.setProperty('color', btnColor, 'important');
                this.style.setProperty('background-color', 'transparent', 'important');
            };
            // Only write a flag on the stable parent doc — no cross-iframe function calls.
            // styleAll() picks it up on its next 150ms tick and applies the theme safely.
            tBtn.onclick = function() {
                doc._vscThemeFlag = doc.body.classList.contains('flytrack-light') ? 'dark' : 'light';
            };
            brand.appendChild(tBtn);
            header.insertBefore(brand, header.firstElementChild);
        }

        // Walk up/down from node to find the nearest [data-baseweb="singleValue"] element.
        function findSingleValue(node) {
            if (node.getAttribute && node.getAttribute('data-baseweb')==='singleValue') return node;
            if (node.querySelector) { var _sv=node.querySelector('[data-baseweb="singleValue"]'); if (_sv) return _sv; }
            return (node.closest ? node.closest('[data-baseweb="singleValue"]') : null);
        }

        // Disconnect any stale observer left over from a previous iframe (hot-reload / browser
        // refresh keeps the parent doc alive so _vscObserver persists).  Two observers firing
        // simultaneously on the same mutations doubled the feedback loop frequency.
        if (doc._vscObserver) { try { doc._vscObserver.disconnect(); } catch(e){} doc._vscObserver = null; }
        doc._vscObserver=new MutationObserver(function(mutations){
                try {
                    computeBanners();
                    mutations.forEach(function(m){
                        m.addedNodes.forEach(function(node){
                            if (node.nodeType!==1) return;
                            // Re-inject brand immediately when stSidebarHeader is recreated
                            if (node.dataset && node.dataset.testid==='stSidebarHeader') {
                                injectBrand(node);
                            } else if (node.querySelectorAll) {
                                var hdr = node.querySelector('[data-testid="stSidebarHeader"]');
                                if (hdr) injectBrand(hdr);
                            }
                            if (node.tagName==='BUTTON') {
                                styleButton(node);
                                var grp = node.closest('[data-testid="stButtonGroup"]');
                                if (grp) styleSegCtrl(grp);
                            } else if (node.querySelectorAll) {
                                node.querySelectorAll('button').forEach(styleButton);
                                // Handle when the added node itself is the button group
                                if (node.dataset && node.dataset.testid==='stButtonGroup') {
                                    styleSegCtrl(node);
                                }
                                node.querySelectorAll('[data-testid="stButtonGroup"]').forEach(styleSegCtrl);
                            }
                            // Fix singleValue colour immediately — avoids grey flash before 150ms styleAll() tick
                            if (!isDark()) {
                                var _svFix = findSingleValue(node);
                                if (_svFix) _svFix.style.setProperty('color','#0f172a','important');
                            }
                            // Immediately fix popover colours in light mode — prevents black→white flicker
                            if (!isDark()) {
                                var pop = (node.getAttribute && node.getAttribute('data-baseweb')==='popover')
                                    ? node
                                    : (node.querySelector ? node.querySelector('[data-baseweb="popover"]') : null);
                                if (pop) {
                                    pop.querySelectorAll('div,ul,li,p,span').forEach(function(d){
                                        if (d.closest('[data-baseweb="tag"]')) return;
                                        if (d.closest('[role="option"]')) return;
                                        d.style.setProperty('background-color','#ffffff','important');
                                        d.style.setProperty('color','#64748b','important');
                                    });
                                    pop.querySelectorAll('[role="option"]').forEach(function(opt){
                                        opt.style.setProperty('color','#0f172a','important');
                                        opt.querySelectorAll('span,div,p').forEach(function(el){
                                            el.style.setProperty('color','#0f172a','important');
                                        });
                                    });
                                    // A popover just opened — apply ring to whichever select is open
                                    doc.querySelectorAll('[data-baseweb="select"]').forEach(function(s){
                                        var c = s.firstElementChild;
                                        if (!c || c.tagName!=='DIV') return;
                                        var isOpen = s.getAttribute('aria-expanded')==='true'
                                                  || c.getAttribute('aria-expanded')==='true'
                                                  || (s.matches && s.matches(':focus-within'));
                                        if (isOpen) {
                                            c.style.setProperty('border-color','rgba(15,23,42,0.80)','important');
                                            c.style.setProperty('box-shadow','0 0 0 2px rgba(15,23,42,0.08)','important');
                                            c.dataset.ftOpen = '1';
                                        }
                                    });
                                }
                            }
                        });
                        // Popover removed — dropdown closed — clear the open-ring flag on all select controls
                        m.removedNodes && m.removedNodes.forEach && m.removedNodes.forEach(function(rn){
                            if (rn.nodeType!==1) return;
                            if (!isDark() && rn.getAttribute && rn.getAttribute('data-baseweb')==='popover') {
                                doc.querySelectorAll('[data-baseweb="select"] > div').forEach(function(c){
                                    delete c.dataset.ftOpen;
                                    c.style.setProperty('border-color','rgba(15,23,42,0.14)','important');
                                    c.style.removeProperty('box-shadow');
                                });
                            }
                        });
                        if (m.type==='childList' && m.target && m.target.tagName==='BUTTON') {
                            styleButton(m.target);
                        }
                        if (m.type==='attributes' && m.target.tagName==='BUTTON') {
                            if (m.attributeName==='aria-checked' || m.attributeName==='aria-pressed') {
                                var grp = m.target.closest('[data-testid="stButtonGroup"]');
                                if (grp) styleSegCtrl(grp);
                            }
                            if (m.attributeName !== 'style') { styleButton(m.target); }
                        }
                        // BaseWeb resets singleValue inline color on re-render; lock prevents observer loop
                        if (m.type==='attributes' && m.attributeName==='style' && !isDark()) {
                            var _svTgt = (m.target.getAttribute && m.target.getAttribute('data-baseweb')==='singleValue') ? m.target : null;
                            if (_svTgt && !_svTgt._ftSvLock) {
                                _svTgt._ftSvLock = true;
                                _svTgt.style.setProperty('color','#0f172a','important');
                                setTimeout(function(){ _svTgt._ftSvLock = false; }, 200);
                            }
                        }
                        // Select ring — fires immediately when dropdown opens/closes (aria-expanded change)
                        // aria-expanded may be on [data-baseweb="select"] itself OR on its > div child
                        if (m.type==='attributes' && m.attributeName==='aria-expanded' && !isDark()) {
                            var _el = m.target;
                            var _selEl = (_el.getAttribute && _el.getAttribute('data-baseweb')==='select')
                                ? _el : (_el.closest ? _el.closest('[data-baseweb="select"]') : null);
                            if (_selEl) {
                                var _ctrl = _selEl.firstElementChild;
                                if (_ctrl && _ctrl.tagName==='DIV') {
                                    var _open = _selEl.getAttribute('aria-expanded')==='true'
                                             || _ctrl.getAttribute('aria-expanded')==='true';
                                    if (_open) { _ctrl.dataset.ftOpen = '1'; } else { delete _ctrl.dataset.ftOpen; }
                                    _ctrl.style.setProperty('border-color', _open ? 'rgba(15,23,42,0.80)' : 'rgba(15,23,42,0.14)', 'important');
                                    _ctrl.style.setProperty('box-shadow',   _open ? '0 0 0 2px rgba(15,23,42,0.08)' : 'none', 'important');
                                }
                            }
                        }
                    });
                } catch(e){}
            });
        doc._vscObserver.observe(doc.body,{
            childList:true,subtree:true,attributes:true,
            attributeFilter:['disabled','class','aria-checked','aria-pressed','aria-expanded','style']
        });

        function styleSelects() {
            var sidebar = doc.querySelector('[data-testid="stSidebar"]');
            var main    = doc.querySelector('[data-testid="stMain"]');

            function compactCtrl(el, minH, fontSize, padV) {
                if (el.dataset.vscSelect===minH) return;
                el.dataset.vscSelect=minH;
                el.style.setProperty('min-height',    minH,    'important');
                el.style.setProperty('font-size',     fontSize,'important');
                el.style.setProperty('padding-top',   padV,    'important');
                el.style.setProperty('padding-bottom',padV,    'important');
                el.style.setProperty('padding-left',  '8px',   'important');
                el.style.setProperty('padding-right', '4px',   'important');
                el.style.setProperty('display',       'flex',  'important');
                el.style.setProperty('align-items',   'center','important');
            }

            if (sidebar) {
                // Selectbox only — compact tight height (multiselect needs room for tags)
                sidebar.querySelectorAll('[data-testid="stSelectbox"] [data-baseweb="select"] > div').forEach(function(el){
                    compactCtrl(el,'24px','0.76em','1px');
                });
                // Multiselect — original values, untouched
                sidebar.querySelectorAll('[data-testid="stMultiSelect"] [data-baseweb="select"] > div').forEach(function(el){
                    compactCtrl(el,'27px','0.72em','2px');
                });
                sidebar.querySelectorAll('[data-testid="stSelectbox"] label,[data-testid="stMultiSelect"] label')
                    .forEach(function(el){ el.style.setProperty('font-size','0.70em','important'); });
            }
            if (main) {
                // Only selectbox — multiselect control divs must not get display:flex / padding-left:8px
                // because that conflicts with tag layout (first tag's border-left gets clipped).
                main.querySelectorAll('[data-testid="stSelectbox"] [data-baseweb="select"] > div').forEach(function(el){
                    compactCtrl(el,'32px','0.80em','3px');
                });
                main.querySelectorAll('[data-testid="stSelectbox"] label,[data-testid="stMultiSelect"] label')
                    .forEach(function(el){ el.style.setProperty('font-size','0.78em','important'); });
            }
        }

        function styleAll() {
            try {
                // Flag written by button onclick — safe to read here (alive iframe context).
                if (doc._vscThemeFlag) {
                    var _flag = doc._vscThemeFlag;
                    doc._vscThemeFlag = null;
                    if (_flag === 'light') doc.body.classList.add('flytrack-light');
                    else                  doc.body.classList.remove('flytrack-light');
                    localStorage.setItem('flytrack-theme', _flag);
                    injectPersistentStyle();
                    var _eb = doc.querySelector('.ft-brand');
                    if (_eb) _eb.remove();
                    injectBrand(doc.querySelector('[data-testid="stSidebarHeader"]'));
                }
                computeBanners();
                doc.querySelectorAll('button').forEach(function(b){ styleButton(b); });
                styleSelects();

                // Multiselect tags — section colour left-accent + text
                var sidebarAmber   = isDark() ? '#fbbf24' : '#d97706';
                var sidebarAmberBg = isDark() ? '#fbbf2412' : '#d9770610';
                doc.querySelectorAll('[data-baseweb="tag"]').forEach(function(tag){
                    if (tag.closest('[data-testid="stSidebar"]')) {
                        // Sidebar multiselect tags — amber (AL page video selector)
                        tag.dataset.vscTag='';  // always refresh sidebar tags on theme change
                        tag.style.setProperty('background-color', sidebarAmberBg, 'important');
                        tag.style.setProperty('border-left-color',sidebarAmber,   'important');
                        tag.style.setProperty('color',            sidebarAmber,   'important');
                        return;
                    }
                    var color = sectionColor(tag);
                    var bgSuffix = isDark() ? '0e' : '10';
                    if (tag.dataset.vscTag===color) return;
                    tag.dataset.vscTag=color;
                    tag.style.setProperty('background-color', color+bgSuffix,'important');
                    tag.style.setProperty('border-left-color',color,         'important');
                    tag.style.setProperty('color',            color,         'important');
                });

                var sidebar = doc.querySelector('[data-testid="stSidebar"]');
                if (sidebar) {
                    // Segmented control — stButtonGroup is the correct testid in Streamlit 1.36+
                    sidebar.querySelectorAll('[data-testid="stButtonGroup"]').forEach(styleSegCtrl);

                    // Radio dots — white
                    sidebar.querySelectorAll('[role="radio"]').forEach(function(radio){
                        var checked   = radio.getAttribute('aria-checked')==='true';
                        var indicator = radio.querySelector('div');
                        if (indicator) {
                            if (checked) {
                                indicator.style.setProperty('border-color','white','important');
                                indicator.style.setProperty('background-color','white','important');
                                var inner=indicator.querySelector('div');
                                if (inner) inner.style.setProperty('background-color','#080d18','important');
                            } else {
                                indicator.style.setProperty('border-color','rgba(255,255,255,0.28)','important');
                                indicator.style.setProperty('background-color','transparent','important');
                            }
                        }
                    });

                    // Brand — injected by injectBrand(); poll as fallback for first render
                    injectBrand(doc.querySelector('[data-testid="stSidebarHeader"]'));

                    // Fix 3: sidebar select value text — cast a wide net over all text elements
                    var light = !isDark();
                    sidebar.querySelectorAll('[data-baseweb="select"] span, [data-baseweb="select"] div, [data-baseweb="select"] p').forEach(function(el){
                        if (el.children.length === 0 || el.textContent.trim()) {  // leaf or text-bearing
                            if (light) el.style.setProperty('color','#0f172a','important');
                            else el.style.removeProperty('color');
                        }
                    });
                }

                // Segmented controls in main content (e.g. Active Learning training mode)
                var _main = doc.querySelector('[data-testid="stMain"]');
                if (_main) _main.querySelectorAll('[data-testid="stButtonGroup"]').forEach(styleSegCtrl);

                // Tag clipping fix — pad ctrl div + value container + tag margin all via inline style
                doc.querySelectorAll('[data-testid="stMain"] [data-testid="stMultiSelect"]').forEach(function(ms){
                    var sel = ms.querySelector('[data-baseweb="select"]');
                    if (sel) {
                        if (sel.firstElementChild) {
                            sel.firstElementChild.style.setProperty('padding-left','3px','important');
                        }
                        // In light mode, BaseWeb sets overflow:hidden on an intermediate wrapper
                        // div (between ctrl and selectValueContainer) when the select is closed,
                        // clipping the first tag. Force overflow:visible on every descendant div.
                        if (!isDark()) {
                            sel.querySelectorAll('div').forEach(function(d){
                                d.style.setProperty('overflow','visible','important');
                            });
                        }
                    }
                    var vc = ms.querySelector('[data-baseweb="selectValueContainer"]');
                    if (vc) {
                        vc.style.setProperty('padding-left','3px','important');
                    }
                    ms.querySelectorAll('[data-baseweb="tag"]').forEach(function(tag){
                        tag.style.setProperty('margin-left','3px','important');
                    });
                });

                // Popover dropdown menus — BaseWeb injects inline dark bg on child divs;
                // force white bg + dark text in light mode (runs after user opens dropdown, 150ms delay fine)
                if (!isDark()) {
                    doc.querySelectorAll('[data-baseweb="popover"]').forEach(function(pop){
                        pop.querySelectorAll('div,ul,li,p,span').forEach(function(d){
                            if (d.closest('[data-baseweb="tag"]')) return;
                            if (d.closest('[role="option"]')) return;
                            d.style.setProperty('background-color','#ffffff','important');
                            d.style.setProperty('color','#64748b','important');
                        });
                        // Option text — BaseWeb CSS-in-JS overrides our stylesheet; must use inline !important
                        pop.querySelectorAll('[role="option"]').forEach(function(opt){
                            opt.style.setProperty('color','#0f172a','important');
                            opt.querySelectorAll('span,div,p').forEach(function(el){
                                el.style.setProperty('color','#0f172a','important');
                            });
                        });
                    });
                }

                // Fix 4: main content select containers — override Streamlit's dark inline bg
                var light = !isDark();
                doc.querySelectorAll('[data-baseweb="select"]').forEach(function(selEl){
                    var ctrl = selEl.firstElementChild;
                    if (ctrl) {
                        var _t2 = ctrl.firstElementChild;
                        var isOpen = selEl.getAttribute('aria-expanded')==='true'
                                  || ctrl.getAttribute('aria-expanded')==='true'
                                  || (selEl.matches && selEl.matches(':focus-within'))
                                  || ctrl.dataset.ftOpen === '1';
                        var _isMultiSel = selEl.closest('[data-testid="stMultiSelect"]') !== null;
                        [ctrl, _t2].forEach(function(t){
                            if (!t || t.tagName !== 'DIV') return;
                            if (light) {
                                t.style.setProperty('background-color', (t===_t2 && _isMultiSel) ? 'transparent' : '#ffffff', 'important');
                                if (t===_t2) t.style.setProperty('overflow','visible','important');
                                if (t===ctrl && isOpen) {
                                    t.style.setProperty('border-color','rgba(15,23,42,0.80)','important');
                                    t.style.setProperty('box-shadow','0 0 0 2px rgba(15,23,42,0.08)','important');
                                } else {
                                    t.style.setProperty('border-color','rgba(15,23,42,0.14)','important');
                                    if (t===ctrl) t.style.removeProperty('box-shadow');
                                }
                            } else {
                                t.style.removeProperty('background-color');
                                t.style.removeProperty('border-color');
                                if (t===_t2) t.style.removeProperty('overflow');
                                if (t===ctrl) t.style.removeProperty('box-shadow');
                            }
                        });
                    }
                    // Value text color — span/p + everything in valueContainer + singleValue (BaseWeb's actual selected-value node)
                    selEl.querySelectorAll(
                        'span, p, [data-baseweb="selectValueContainer"] *, [data-baseweb="singleValue"], [data-baseweb="singleValue"] *'
                    ).forEach(function(el){
                        if (light) el.style.setProperty('color','#0f172a','important');
                        else el.style.removeProperty('color');
                    });
                    // Dropdown arrow SVG
                    selEl.querySelectorAll('svg').forEach(function(svg){
                        if (light) svg.style.setProperty('color','#64748b','important');
                        else svg.style.removeProperty('color');
                    });
                });
                // Belt-and-suspenders: force dark on every div/span inside any select,
                // skipping only the arrow icon container. Catches value text regardless
                // of what data-baseweb attribute (or none) BaseWeb uses in this version.
                if (!isDark()) {
                    doc.querySelectorAll('[data-baseweb="select"]').forEach(function(s){
                        var _icon = s.querySelector('[data-baseweb="selectIconContainer"]');
                        s.querySelectorAll('div, span').forEach(function(el){
                            if (!_icon || !_icon.contains(el)) {
                                el.style.setProperty('color','#0f172a','important');
                            }
                        });
                    });
                }
            } catch(e){}
            // Debounced loop: cancel any pending tick, reschedule at 150ms
            if (doc._vscStyleTimer) clearTimeout(doc._vscStyleTimer);
            doc._vscStyleTimer = setTimeout(styleAll, 150);
        }

        // On each new iframe startup, remove any stale .ft-brand so that injectBrand()
        // creates a fresh button whose onclick closure belongs to this (alive) iframe.
        // Without this, navigating pages leaves the old button (dead-iframe closure) in place.
        (function(){
            var hdr = doc.querySelector('[data-testid="stSidebarHeader"]');
            if (hdr) { var sb = hdr.querySelector('.ft-brand'); if (sb) sb.remove(); }
        })();

        // ── Lightbox overlay — injected once into <html> so it escapes every stacking context ──
        (function(){
            if (doc.getElementById('ft-lightbox')) return;
            var lb = doc.createElement('div');
            lb.id = 'ft-lightbox';
            // z-index max (2^31-1) + appended to <html> not <body> — ensures it paints above
            // Streamlit's sidebar/header even when they create their own stacking contexts.
            lb.style.cssText = 'display:none;position:fixed;inset:0;z-index:2147483647;'
                +'background:rgba(2,4,8,0.90);cursor:zoom-out;'
                +'align-items:center;justify-content:center;opacity:0;transition:opacity 0.15s ease';
            var lbImg = doc.createElement('img');
            lbImg.id = 'ft-lightbox-img';
            lbImg.style.cssText = 'max-width:96vw;max-height:96vh;width:auto;height:auto;object-fit:contain;'
                +'border-radius:4px;box-shadow:0 25px 60px rgba(0,0,0,0.65);cursor:default';
            lbImg.addEventListener('click', function(e){ e.stopPropagation(); });
            var lbClose = doc.createElement('div');
            lbClose.style.cssText = 'position:absolute;top:16px;right:20px;color:rgba(255,255,255,0.55);'
                +'font-size:22px;line-height:1;cursor:pointer;user-select:none;transition:color 0.12s';
            lbClose.textContent = '✕';
            lbClose.addEventListener('mouseenter', function(){ this.style.color='rgba(255,255,255,0.9)'; });
            lbClose.addEventListener('mouseleave', function(){ this.style.color='rgba(255,255,255,0.55)'; });
            lbClose.addEventListener('click', function(e){
                e.stopPropagation();
                lb.style.opacity='0'; setTimeout(function(){ lb.style.display='none'; }, 150);
            });
            lb.appendChild(lbImg); lb.appendChild(lbClose);
            lb.addEventListener('click', function(){
                lb.style.opacity='0'; setTimeout(function(){ lb.style.display='none'; }, 150);
            });
            doc.documentElement.appendChild(lb);
            doc.addEventListener('keydown', function(e){
                if (e.key==='Escape') {
                    var l=doc.getElementById('ft-lightbox');
                    if (l&&l.style.display!=='none') { l.style.opacity='0'; setTimeout(function(){ l.style.display='none'; },150); }
                }
            });
        })();
        // Event delegation for .ft-img-wrap clicks — CSP-safe, no inline onclick needed.
        // Runs once per iframe lifecycle; works for images added at any time via MutationObserver.
        (function(){
            // Guard: only attach once per parent-document lifetime
            if (doc._ftImgClickBound) return;
            doc._ftImgClickBound = true;
            doc.addEventListener('click', function(e) {
                var wrap = e.target.closest ? e.target.closest('.ft-img-wrap') : null;
                if (!wrap) return;
                var img = wrap.querySelector('.ft-zoomable');
                var src = img ? img.src : (e.target.tagName==='IMG' ? e.target.src : null);
                if (!src) return;
                var lb=doc.getElementById('ft-lightbox'), lbi=doc.getElementById('ft-lightbox-img');
                if (lb&&lbi) {
                    lbi.src=src;
                    lb.style.opacity='0'; lb.style.display='flex';
                    setTimeout(function(){ lb.style.opacity='1'; }, 10);
                }
            });
        })();

        doc._vscStyleAll = styleAll;
        doc._vscComputeBanners = computeBanners;

        styleAll();
    } catch(e){}
})();
</script>
"""


def inject():
    st.markdown(COMMON_CSS, unsafe_allow_html=True)


def inject_stop_style():
    import streamlit.components.v1 as components
    components.html(_STOP_JS, height=0, scrolling=False)


def status_dot(status: str, color: str = AMBER) -> str:
    if status == "idle":
        return '<span style="color:#1e2d42;font-size:1em">●</span>'
    if status == "error":
        return f'<span style="color:{ROSE};font-size:1em">●</span>'
    if status == "running":
        return (f'<span style="color:{color};font-size:1em;display:inline-block;'
                f'animation:vsc-pulse 1.4s ease-in-out infinite">●</span>')
    return f'<span style="color:{color};font-size:1em">●</span>'


def section_label(title: str, status: str = "idle") -> str:
    return f"{status_dot(status)} &nbsp;{title}"


def sidebar_brand() -> str:
    """Kept for import compatibility — brand is now injected by JS."""
    return ""


def section_banner(color: str, num: str, title: str, subtitle: str,
                   dot_html: str, label: str = "") -> str:
    badge     = label.upper() if label else f"Section {num}"
    ghost_num = num.zfill(2)
    return (
        f'<div class="ft-section-banner" style="position:relative;overflow:hidden;background:{BG};'
        f'border:1px solid {color}20;border-left:3px solid {color};'
        f'border-radius:4px;padding:18px 24px;margin:24px 0 16px">'
        f'<div style="position:absolute;right:18px;top:50%;transform:translateY(-50%);'
        f'font-family:\'JetBrains Mono\',monospace;font-size:4.8em;font-weight:700;'
        f'color:{color};opacity:0.13;line-height:1;pointer-events:none;user-select:none;'
        f'letter-spacing:-0.04em">{ghost_num}</div>'
        f'<div style="position:relative;z-index:1">'
        f'<div style="font-family:\'JetBrains Mono\',monospace;color:{color};'
        f'font-size:0.56em;font-weight:700;text-transform:uppercase;letter-spacing:0.20em;'
        f'margin-bottom:6px;opacity:0.80">{badge}</div>'
        f'<div class="ft-sb-title" style="font-family:\'DM Serif Display\',Georgia,serif;color:#f8fafc;'
        f'font-size:1.08em;font-weight:400;margin-bottom:4px;letter-spacing:0.01em;'
        f'line-height:1.25">{title}</div>'
        f'<div class="ft-sb-sub" style="font-family:\'JetBrains Mono\',monospace;color:{MUTED};'
        f'font-size:0.69em;letter-spacing:0.01em">{subtitle}</div>'
        f'</div>'
        f'<div style="position:absolute;right:24px;top:50%;transform:translateY(-50%);'
        f'font-size:1.15em;z-index:1">{dot_html}</div>'
        f'</div>'
    )


def phase_label(color: str, num: str, name: str, note: str = "") -> str:
    note_html = (
        f'<span class="ft-pl-note" style="font-family:\'JetBrains Mono\',monospace;color:{MUTED};'
        f'font-weight:400;font-size:0.78em;margin-left:6px">{note}</span>'
        if note else ""
    )
    return (
        f'<div style="display:flex;align-items:center;gap:10px;margin:16px 0 8px">'
        f'<span style="font-family:\'JetBrains Mono\',monospace;color:{color};'
        f'background:{color}10;border:1px solid {color}30;'
        f'font-size:0.57em;font-weight:700;text-transform:uppercase;letter-spacing:0.14em;'
        f'padding:3px 9px;border-radius:2px;white-space:nowrap">Phase {num}</span>'
        f'<span class="ft-pl-name" style="color:#f1f5f9;font-weight:600;font-size:0.90em">{name}{note_html}</span>'
        f'</div>'
    )
