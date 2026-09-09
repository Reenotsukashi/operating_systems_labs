#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
LOGGING_FILE="$SCRIPT_DIR/logs/watcher.log"
DIRECTORY="$SCRIPT_DIR/reports"

mkdir -p "$DIRECTORY"

REPORT_FILE="$DIRECTORY/rep$(date +%Y%m%d_%H%M%S).txt"

EVENT_COUNT=$(grep -c "EVENT:" "$LOGGING_FILE")

{
	echo "$EVENT_COUNT, date: $(date)"
} > "$REPORT_FILE"
