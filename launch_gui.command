#!/bin/bash
# macOS launcher (double-click in Finder). Counterpart of launch_gui.bat.
# Uses the env at $FLYTRACK_ENV, default ~/.venvs/flytrack (see MACOS_SETUP.md).
cd "$(dirname "$0")" || exit 1
ENV_DIR="${FLYTRACK_ENV:-$HOME/.venvs/flytrack}"

if [ ! -x "$ENV_DIR/bin/streamlit" ]; then
    echo "No environment with Streamlit found at: $ENV_DIR"
    echo "Create it as described in MACOS_SETUP.md, or set FLYTRACK_ENV to its path."
    read -r -p "Press Enter to close..."
    exit 1
fi

source "$ENV_DIR/bin/activate"   # puts sleap-label / sleap-convert / sleap-nn on PATH
exec streamlit run gui/app.py
