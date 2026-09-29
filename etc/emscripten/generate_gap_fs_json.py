#!/usr/bin/env python3
"""Read a list of file paths from stdin (one per line) and write them as a
JSON array to gap-fs.json in the current directory."""

import json
import sys

paths = [line.strip() for line in sys.stdin if line.strip()]
with open("gap-fs.json", "w", encoding="utf-8") as f:
    json.dump(paths, f, separators=(",", ":"))
print(f"wrote {len(paths)} files to gap-fs.json", file=sys.stderr)
