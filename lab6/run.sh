#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
VENV_DIR="$SCRIPT_DIR/.venv"
LOG_FILE="$SCRIPT_DIR/logs/fuse.log"

ensure_venv() {
    if [[ ! -d "$VENV_DIR" ]]; then
        echo "creating venv..."
        python3 -m venv "$VENV_DIR"
        "$VENV_DIR/bin/pip" install --quiet --upgrade pip
        "$VENV_DIR/bin/pip" install --quiet fusepy Pillow
    fi
}

cleanup() {
    echo "$(date); SIGNAL: cleanup" >> "$LOG_FILE"
    if mountpoint -q "$SCRIPT_DIR/mnt" 2>/dev/null; then
        fusermount -u "$SCRIPT_DIR/mnt" 2>/dev/null
    fi
}

trap cleanup SIGINT SIGTERM

ensure_venv
exec "$VENV_DIR/bin/python" "$SCRIPT_DIR/cli.py" "$@"