#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
REPORT="$SCRIPT_DIR/../reports/report2.log"
MEM_LOG="$LOG_DIR/mem2.log"
STEP_FILE="$SCRIPT_DIR/../.step_counter2"

mkdir -p "$LOG_DIR" "$(dirname "$REPORT")"
: > "$REPORT"
echo 0 > "$STEP_FILE"

trap 'echo "$(date); SIGNAL: SIGINT"; exit 0' SIGINT
trap 'echo "$(date); SIGNAL: SIGTERM"; exit 0' SIGTERM

echo "$(date); START: mem2.bash pid=$$" >> "$MEM_LOG"

exec python3 "$SCRIPT_DIR/mem_worker.py" "$REPORT" "$MEM_LOG" "$STEP_FILE"