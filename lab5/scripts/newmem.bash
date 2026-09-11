#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
MEM_LOG="$LOG_DIR/newmem.log"
STEP_FILE="$SCRIPT_DIR/../.step_counter_new"

N="${1:?usage: newmem.bash N}"

mkdir -p "$LOG_DIR"
echo 0 > "$STEP_FILE"

trap 'echo "$(date); SIGNAL: SIGINT"; exit 0' SIGINT
trap 'echo "$(date); SIGNAL: SIGTERM"; exit 0' SIGTERM

echo "$(date); START: newmem.bash pid=$$ N=$N" >> "$MEM_LOG"

exec python3 "$SCRIPT_DIR/newmem_worker.py" "$N" "$MEM_LOG" "$STEP_FILE"