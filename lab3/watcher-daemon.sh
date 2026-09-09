#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
WATCHER_PID_FILE="$SCRIPT_DIR/watcher.pid"

if [[ "$1" == "start" ]]; then
    setsid "$SCRIPT_DIR/watcher.sh" &
    echo $! > "$WATCHER_PID_FILE"
elif [[ "$1" == "stop" ]]; then
    if [[ -f "$WATCHER_PID_FILE" ]]; then
        PID=$(cat "$WATCHER_PID_FILE")
        kill -TERM "$PID"
        rm -f "$WATCHER_PID_FILE"
    fi
elif [[ "$1" == "status" ]]; then
    if [[ -f "$WATCHER_PID_FILE" ]]; then
        PID=$(cat "$WATCHER_PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "Process is working (PID $PID)"
        else
            echo "Process is dead (stale PID)"
        fi
    else
        echo "No PID file"
    fi
fi