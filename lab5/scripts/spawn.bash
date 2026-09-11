#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

N="${1:?usage: spawn.bash N K}"
K="${2:?usage: spawn.bash N K}"

[[ -x "$SCRIPT_DIR/newmem.bash" ]] || { echo "newmem.bash not found"; exit 1; }

echo "$(date '+%Y-%m-%d %H:%M:%S'); spawn: N=$N K=$K"

PIDS=()
for i in $(seq 1 "$K"); do
    "$SCRIPT_DIR/newmem.bash" "$N" &
    PIDS+=("$!")
    sleep 1
done

FAIL=0
for pid in "${PIDS[@]}"; do
    if ! wait "$pid"; then
        FAIL=$((FAIL + 1))
    fi
done

echo "$(date '+%Y-%m-%d %H:%M:%S'); spawn: finished $K runs, failed=$FAIL"