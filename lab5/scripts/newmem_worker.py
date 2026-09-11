#!/usr/bin/env python3
import sys
import os
from datetime import datetime

if len(sys.argv) < 4:
    print("usage: newmem_worker.py <N> <mem_log> <step_file>", file=sys.stderr)
    sys.exit(1)

N = int(sys.argv[1])
mem_log, step_file = sys.argv[2], sys.argv[3]

def log(path, msg):
    with open(path, "a") as f:
        f.write(f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}; {msg}\n")

log(mem_log, f"START: newmem_worker pid={os.getpid()} N={N}")

array = []
step = 0
chunk = list(range(1, 11))

while len(array) <= N:
    array.extend(chunk)
    step += 1
    if step % 1000 == 0:
        with open(step_file, "w") as f:
            f.write(str(step))

log(mem_log, f"FINISH: newmem_worker pid={os.getpid()} size={len(array)} step={step}")