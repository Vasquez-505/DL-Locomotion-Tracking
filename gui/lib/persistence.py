from __future__ import annotations
import json
from pathlib import Path

# Stored next to the gui/ folder so it isn't inside lib/
_STATE_FILE = Path(__file__).resolve().parent.parent / ".gui_state.json"

# Explicit set of widget keys to persist (no runtime state: _proc, _log, _status)
_PERSIST_KEYS: frozenset[str] = frozenset({
    # Bulk Pipeline — sidebar controls
    "bp_inf_model", "bp_video_set",
    "bp_model_name", "bp_model_name_fb",
    # Bulk Pipeline — video selections
    "bp_video_input_ms", "bp_video_input",
    "bp_videos_ana",    "bp_videos_ana_txt",
    "bp_videos_c",      "bp_videos_c_txt",
    "bp_trim_vids", "bp_fps",
    # Active Learning — sidebar
    "al_base_model", "al_new_videos_sel",
    # Active Learning — settings
    "al_orig_train", "al_orig_val", "al_orig_test",
    "al_mode", "al_epochs", "al_batch",
    # Active Learning — inspect panel
    "al_inspect_sel",
})

_SAFE = (str, int, float, bool, list, dict, type(None))


def load(ss: dict) -> None:
    """On session start, populate session_state from the saved JSON.

    Only sets keys that are not yet in session_state (preserves same-session state
    across Streamlit reruns — widgets already own their keys after first render).
    """
    if not _STATE_FILE.exists():
        return
    try:
        saved: dict = json.loads(_STATE_FILE.read_text(encoding="utf-8"))
    except Exception:
        return
    for k, v in saved.items():
        if k in _PERSIST_KEYS and k not in ss:
            ss[k] = v
        elif k.startswith("trim_") and k not in ss and isinstance(v, (int, float)):
            ss[k] = v
        elif k.startswith("distcal_") and k not in ss and isinstance(v, (int, float)):
            ss[k] = v


def save(ss: dict) -> None:
    """Write current widget state to disk.

    Called at the end of each page render so state is always up-to-date.
    JSON-unsafe values (StreamingSubprocess, etc.) are skipped silently.
    """
    current: dict = {}
    try:
        if _STATE_FILE.exists():
            current = json.loads(_STATE_FILE.read_text(encoding="utf-8"))
    except Exception:
        pass

    for k in _PERSIST_KEYS:
        if k in ss and isinstance(ss[k], _SAFE):
            current[k] = ss[k]

    # Dynamic per-video trim-frame keys (trim_<video_name>)
    for k, v in ss.items():
        if k.startswith("trim_") and isinstance(v, (int, float)):
            current[k] = v

    for k, v in ss.items():
        if k.startswith("distcal_") and isinstance(v, (int, float)):
            current[k] = v

    try:
        _STATE_FILE.write_text(json.dumps(current, indent=2, ensure_ascii=False), encoding="utf-8")
    except Exception:
        pass
