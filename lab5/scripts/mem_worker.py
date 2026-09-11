#!/usr/bin/env python3
import sys
import os
from datetime import datetime

if len(sys.argv) < 4:
    print("usage: mem_worker.py <report> <mem_log> <step_file>", file=sys.stderr)
    sys.exit(1)

report, mem_log, step_file = sys.argv[1], sys.argv[2], sys.argv[3]

def log(path, msg):
    with open(path, "a") as f:
        f.write(f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}; {msg}\n")

log(mem_log, f"START: mem_worker pid={os.getpid()}")

array = []
step = 0
chunk = list(range(1, 11))

while True:
    array.extend(chunk)
    step += 1

    if step % 1000 == 0:
        with open(step_file, "w") as f:
            f.write(str(step))

    if step % 100000 == 0:
        msg = f"step={step}; size={len(array)}"
        log(report, msg)
        log(mem_log, msg)