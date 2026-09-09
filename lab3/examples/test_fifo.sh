#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
FIFO_PATH="$SCRIPT_DIR/../watcher.fifo"
echo "test_event_from_fifo" > "$FIFO_PATH"
echo "STATUS" > "$FIFO_PATH"