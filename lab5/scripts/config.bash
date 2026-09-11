#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
CONFIG_LOG="$LOG_DIR/config.log"

mkdir -p "$LOG_DIR"
: > "$CONFIG_LOG"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'); CONFIG: $1" >> "$CONFIG_LOG"
}

log "RAM total: $(awk '/MemTotal/ {print $2" "$3}' /proc/meminfo)"
log "RAM free: $(awk '/MemFree/ {print $2" "$3}' /proc/meminfo)"
log "RAM available: $(awk '/MemAvailable/ {print $2" "$3}' /proc/meminfo)"
log "Swap total: $(awk '/SwapTotal/ {print $2" "$3}' /proc/meminfo)"
log "Swap free: $(awk '/SwapFree/ {print $2" "$3}' /proc/meminfo)"
log "Page size: $(getconf PAGE_SIZE) bytes"
log "Swap partitions:"
while read -r line; do
    log "  $line"
done < <(tail -n +2 /proc/swaps)
log "CPU cores: $(nproc)"
log "=== free -b ==="
while read -r line; do
    log "  $line"
done < <(free -b)

echo "Saved to $CONFIG_LOG"