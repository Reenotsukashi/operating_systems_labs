#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
MONITOR_LOG="$LOG_DIR/monitor.log"

INTERVAL="${1:-1}"

mkdir -p "$LOG_DIR"
: > "$MONITOR_LOG"

(
    while true; do
        TS="$(date '+%Y-%m-%d %H:%M:%S')"
        {
            echo "$TS; MONITOR: === tick ==="
            awk -v ts="$TS" '
                /MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree|Buffers|Cached/ {
                    print ts "; MEMINFO: " $0
                }' /proc/meminfo
            top -b -n1 | head -13 | while IFS= read -r line; do
                echo "$TS; TOP: $line"
            done
            top -b -n1 | grep -E "mem\.bash|mem2\.bash|newmem" | while IFS= read -r line; do
                echo "$TS; PROC: $line"
            done
        } >> "$MONITOR_LOG"
        sleep "$INTERVAL"
    done
) &
WRITER_PID=$!

cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'); MONITOR: stopping (pid=$WRITER_PID)" >> "$MONITOR_LOG"
    kill "$WRITER_PID" 2>/dev/null
    wait "$WRITER_PID" 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM

echo "monitor started, pid=$WRITER_PID, interval=${INTERVAL}s, log=$MONITOR_LOG"
echo "press Ctrl+C to stop"

wait "$WRITER_PID"