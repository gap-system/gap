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
"""Compare two JSON outputs of run.py and flag what changed.

A case is flagged as slower or faster if the ratio of the minimal timings
exceeds the threshold and the absolute difference exceeds the floor. Any
difference in results or in status (ok, timeout, error, skipped) is flagged
as well. The exit code is 1 if a result or status got worse, so this can
gate a change; with --strict, slower cases count too.
"""

import argparse
import json
import sys


def load(path):
    with open(path) as f:
        return json.load(f)


def fmt_ms(r):
    if r["status"] == "ok":
        return str(min(r["ms"]))
    return r["status"]


def compare(old, new, threshold=1.5, floor_ms=20):
    """Returns (rows, summary, bad, slower) for the cases in both files."""
    rows = []
    bad = []
    slower = []
    totals = {}
    for name in sorted(set(old["cases"]) | set(new["cases"]),
                       key=lambda n: ((old["cases"].get(n) or new["cases"][n])["category"], n)):
        o = old["cases"].get(name)
        n = new["cases"].get(name)
        if o is None or n is None:
            rows.append((name, (o or n)["category"], fmt_ms(o) if o else "-",
                         fmt_ms(n) if n else "-", "", "added" if o is None else "removed"))
            continue
        flag = ""
        ratio = ""
        if o["status"] == "ok" and n["status"] == "ok":
            a, b = min(o["ms"]), min(n["ms"])
            cat = totals.setdefault(n["category"], [0, 0, 0])
            cat[0] += a
            cat[1] += b
            cat[2] += 1
            if a > 0 and b > 0:
                ratio = "%.2f" % (b / a)
            if b > threshold * a and b - a > floor_ms:
                flag = "slower"
                slower.append(name)
            elif a > threshold * b and a - b > floor_ms:
                flag = "faster"
            if o["result"] != n["result"]:
                flag = "RESULT DIFFERS"
                bad.append(name)
        elif o["status"] != n["status"]:
            flag = "%s -> %s" % (o["status"], n["status"])
            if n["status"] in ("timeout", "error") or (
                    n["status"] == "skipped" and o["status"] == "ok"):
                bad.append(name)
        rows.append((name, n["category"], fmt_ms(o), fmt_ms(n), ratio, flag))
    return rows, totals, bad, slower


def compare_files(old_path, new_path, threshold=1.5, floor_ms=20, strict=False,
                  only_flagged=False):
    old, new = load(old_path), load(new_path)
    rows, totals, bad, slower = compare(old, new, threshold, floor_ms)
    print("old: %s (%s, %s)" % (old_path, old.get("commit", ""), old.get("date", "")))
    print("new: %s (%s, %s)" % (new_path, new.get("commit", ""), new.get("date", "")))
    print()
    width = max([len(r[0]) for r in rows] + [10])
    print("%-*s  %-12s  %9s  %9s  %6s  %s" % (width, "case", "category", "old ms",
                                              "new ms", "ratio", ""))
    for name, cat, a, b, ratio, flag in rows:
        if only_flagged and not flag:
            continue
        print("%-*s  %-12s  %9s  %9s  %6s  %s" % (width, name, cat, a, b, ratio, flag))
    print()
    for cat in sorted(totals):
        a, b, k = totals[cat]
        print("%-12s  %7d -> %7d ms over %d cases both ok%s" % (
            cat, a, b, k, "  (%.2fx)" % (b / a) if a else ""))
    print()
    print("%d slower, %d results or statuses worse" % (len(slower), len(bad)))
    if bad:
        print("worse:", ", ".join(bad))
    if strict and slower:
        print("slower:", ", ".join(slower))
    return 1 if bad or (strict and slower) else 0


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("old")
    p.add_argument("new")
    p.add_argument("--threshold", type=float, default=1.5,
                   help="ratio of minimal timings to flag (default: 1.5)")
    p.add_argument("--floor-ms", type=int, default=20,
                   help="ignore differences below this (default: 20)")
    p.add_argument("--strict", action="store_true",
                   help="exit code 1 also for slower cases")
    p.add_argument("--only-flagged", action="store_true",
                   help="list only cases with a flag")
    args = p.parse_args()
    sys.exit(compare_files(args.old, args.new, args.threshold, args.floor_ms,
                           args.strict, args.only_flagged))


if __name__ == "__main__":
    main()
