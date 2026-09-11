#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/some_project"
VERSIONS_DIR="$PROJECT_DIR/versions"
CURRENT_LINK="$PROJECT_DIR/current_version"
HARDLINKS_DIR="$PROJECT_DIR/hardlinks"

rm -rf "$PROJECT_DIR"

mkdir -p "$VERSIONS_DIR"/{v1,v2,v3}

touch "$VERSIONS_DIR/v1/README.md"
touch "$VERSIONS_DIR/v2/README.md"
touch "$VERSIONS_DIR/v3/README.md"

ln -sfn versions/v1 "$CURRENT_LINK"

mkdir -p "$HARDLINKS_DIR"

ln "$PROJECT_DIR/$(readlink "$CURRENT_LINK")"/* "$HARDLINKS_DIR/"

ln -sfn versions/v2 "$CURRENT_LINK"

echo "current_version was switched to versions/v2."
echo "Hard links in hardlinks/ still point to the inodes of v1 files."
echo "Reason: a hard link is bound to an inode, not to a path/name."
echo "A symbolic link stores a path, so switching it does not affect hard links."