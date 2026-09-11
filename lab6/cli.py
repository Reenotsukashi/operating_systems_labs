import os
import sys
import argparse
import subprocess
import logging

from fuse import FUSE

from fs import ConvertFS
from logger import log, LOG_FILE


def cmd_mount(args):
    original = os.path.abspath(args.original)
    mount = os.path.abspath(args.mount)

    if not os.path.isdir(original):
        print(f"error: original dir not found: {original}", file=sys.stderr)
        sys.exit(1)
    if not os.path.isdir(mount):
        print(f"error: mountpoint not found: {mount}", file=sys.stderr)
        sys.exit(1)

    log.info("mount %s -> %s", original, mount)
    FUSE(
        ConvertFS(original),
        mount,
        foreground=args.foreground,
        nothreads=True,
        allow_other=False,
        ro=False,
    )


def cmd_list(args):
    try:
        out = subprocess.check_output(["mount"], text=True)
    except subprocess.CalledProcessError:
        return
    for line in out.splitlines():
        if "fuse" in line:
            print(line)


def cmd_umount(args):
    mount = os.path.abspath(args.mount)
    log.info("umount %s", mount)
    subprocess.run(["fusermount", "-u", mount], check=False)


def main():
    p = argparse.ArgumentParser(prog="lab6-fuse")
    sub = p.add_subparsers(dest="cmd", required=True)

    pm = sub.add_parser("mount", help="mount the FS")
    pm.add_argument("original", help="directory with source png files")
    pm.add_argument("mount", help="mountpoint")
    pm.add_argument("-f", "--foreground", action="store_true")
    pm.set_defaults(func=cmd_mount)

    pl = sub.add_parser("list", help="list mounted fuse filesystems")
    pl.set_defaults(func=cmd_list)

    pu = sub.add_parser("umount", help="unmount")
    pu.add_argument("mount")
    pu.set_defaults(func=cmd_umount)

    args = p.parse_args()
    log.info("cmd=%s args=%s", args.cmd, vars(args))
    args.func(args)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log.info("SIGINT received")
        print("\ninterrupted", file=sys.stderr)
        sys.exit(130)
    finally:
        log.info("logfile: %s", LOG_FILE)