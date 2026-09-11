#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

[[ -x "$SCRIPT_DIR/mem.bash" ]]  || { echo "mem.bash not found";  exit 1; }
[[ -x "$SCRIPT_DIR/mem2.bash" ]] || { echo "mem2.bash not found"; exit 1; }

"$SCRIPT_DIR/mem.bash" &
PID1=$!
"$SCRIPT_DIR/mem2.bash" &
PID2=$!

echo "$(date '+%Y-%m-%d %H:%M:%S'); run_two: started mem.bash pid=$PID1, mem2.bash pid=$PID2"

wait "$PID1"
RC1=$?
wait "$PID2"
RC2=$?

echo "$(date '+%Y-%m-%d %H:%M:%S'); run_two: mem.bash rc=$RC1, mem2.bash rc=$RC2"