#!/usr/bin/env python3
#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
"""Compare two JSON files written by run.py, see README.md.

Lists the cases whose status or result differs, or whose time differs by
more than a factor of 1.5 and by more than 20 ms, and then sums up each
family of cases, the part of the name before the slash. The time of a case
is the minimum over its seeds. The exit code is 1 if a result differs or a
case that was ok no longer is.
"""

import argparse
import json
import sys

FACTOR = 1.5
FLOOR_MS = 20


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def time(case):
    """The time of a case in ms, or its status if that is not ok."""
    return min(case["ms"]) if case["status"] == "ok" else case["status"]


def change(old, new):
    """What to say about a case, and whether that is bad."""
    if old["status"] != new["status"]:
        return f"{old['status']} -> {new['status']}", new["status"] != "ok"
    if old["status"] != "ok":
        return "", False
    if old["result"] != new["result"]:
        return "RESULT DIFFERS", True
    a, b = time(old), time(new)
    if b > FACTOR * a and b - a > FLOOR_MS:
        return "slower", False
    if a > FACTOR * b and a - b > FLOOR_MS:
        return "faster", False
    return "", False


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("old")
    p.add_argument("new")
    p.add_argument("--all", action="store_true",
                   help="list all cases, not only those that changed")
    args = p.parse_args()
    old, new = load(args.old), load(args.new)
    for label, path, data in ("old", args.old, old), ("new", args.new, new):
        print(f"{label}: {path} ({data['commit']}, {data['date']}, "
              f"{data['seeds']} seeds, limit {data['timeout']} s)")
    names = [name for name in old["cases"] if name in new["cases"]]
    print(f"{len(names)} cases in both files\n")

    width = max(map(len, names))
    print(f"{'case':{width}} {'old ms':>8} {'new ms':>8}")
    families = {}
    counts = {}
    bad = False
    for name in names:
        o, n = old["cases"][name], new["cases"][name]
        what, isbad = change(o, n)
        bad = bad or isbad
        if what:
            counts[what] = counts.get(what, 0) + 1
        if what or args.all:
            print(f"{name:{width}} {time(o):>8} {time(n):>8}  {what}")
        # cases, not ok in old, not ok in new, ms in old and new if both ok
        family = families.setdefault(name.split("/")[0], [0, 0, 0, 0, 0])
        family[0] += 1
        family[1] += o["status"] != "ok"
        family[2] += n["status"] != "ok"
        if o["status"] == "ok" and n["status"] == "ok":
            family[3] += time(o)
            family[4] += time(n)

    print(f"\n{'':20} {'not ok':>17} {'ms where both ok':>21}")
    print(f"{'family':14} {'cases':>5} {'old':>8} {'new':>8} "
          f"{'old':>10} {'new':>10}")
    for name, (k, a, b, c, d) in families.items():
        print(f"{name:14} {k:5} {a:8} {b:8} {c:10} {d:10}")
    print("\n" + (", ".join(f"{k} {what}" for what, k in counts.items())
                  or "no changes"))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
