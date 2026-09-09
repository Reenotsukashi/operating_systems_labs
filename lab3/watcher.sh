#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
TRACKED_FILE="$SCRIPT_DIR/events.txt"
LOGGING_FILE="$SCRIPT_DIR/logs/watcher.log"
FIFO_PATH="$SCRIPT_DIR/watcher.fifo"
COUNT_FILE="$SCRIPT_DIR/.count_viewed"
COUNT_VIEWED=0
LOGGING_LEVEL=0

if [[ ! -f "$COUNT_FILE" ]]; then
	echo 0 > "$COUNT_FILE"
fi

if [[ ! -p "$FIFO_PATH" ]]; then
	rm -f "$FIFO_PATH"
	mkfifo "$FIFO_PATH"
fi

process_sighup() {
	echo "$(date); SIGNAL: SIGHUP" >> "$LOGGING_FILE";
}
process_sigint() {
	echo "$(date); SIGNAL: SIGINT" >> "$LOGGING_FILE";
	pkill -P $$ tail
	kill "$FIFO_PID" 2>/dev/null
	rm -f "$FIFO_PATH" "$COUNT_FILE"
	exit 0;
}
process_sigterm() {
	echo "$(date); SIGNAL: SIGTERM" >> "$LOGGING_FILE";
	pkill -P $$ tail
	kill "$FIFO_PID" 2>/dev/null
	rm -f "$FIFO_PATH" "$COUNT_FILE"
	exit 0;
}
process_sigusr1() {
	echo "$(date); SIGNAL: SIGUSR1, count viewed: $(cat "$COUNT_FILE")" >> "$LOGGING_FILE";
}
process_sigusr2() {
	mv "$SCRIPT_DIR/logs/watcher.log" "$SCRIPT_DIR/logs/archive_log.$(date +%Y%m%d_%H%M%S).txt"
	touch "$SCRIPT_DIR/logs/watcher.log"
	LOGGING_LEVEL=$(((LOGGING_LEVEL + $1) % 2))
	echo "$(date); SIGNAL: SIGUSR2" >> "$LOGGING_FILE";
}

trap process_sighup SIGHUP
trap process_sigint SIGINT
trap process_sigterm SIGTERM
trap process_sigusr1 SIGUSR1
trap 'process_sigusr2 1' SIGUSR2

echo "$(date); NOTE: file being tracked: $TRACKED_FILE" >> "$LOGGING_FILE"

(
	while true; do
		if [[ ! -p "$FIFO_PATH" ]]; then
			rm -f "$FIFO_PATH"
			mkfifo "$FIFO_PATH"
		fi
		while read -r line; do
			if [[ "$line" == "STATUS" ]]; then
				echo "$(date); STATUS: FIFO, count viewed: $(cat "$COUNT_FILE")" >> "$LOGGING_FILE"
				COUNT=$(cat "$COUNT_FILE")
				echo $((COUNT + 1)) > "$COUNT_FILE"
			else
				echo "$(date); EVENT: $line" >> "$LOGGING_FILE"
				COUNT=$(cat "$COUNT_FILE")
				echo $((COUNT + 1)) > "$COUNT_FILE"
			fi
		done < "$FIFO_PATH"
	done
) &
FIFO_PID=$!

while read -r line; do
	if [[ "$LOGGING_LEVEL" -eq 0 ]]; then
		echo "$(date); EVENT: $line" >> "$LOGGING_FILE"
		COUNT=$(cat "$COUNT_FILE")
		echo $((COUNT + 1)) > "$COUNT_FILE"
	elif [[ "$LOGGING_LEVEL" -eq 1 ]]; then
		:
	else
		exit 1
	fi
done < <(tail -n0 -F "$TRACKED_FILE")

kill "$FIFO_PID" 2>/dev/null
rm -f "$COUNT_FILE"