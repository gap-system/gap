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
more than 10% and by more than 20 ms, with both times and the factor, and
then sums up each family of cases, the part of the name before the slash.
The time of a case is the minimum over its seeds. For a case that exceeded
the time limit the limit is taken, so the factor is a lower bound then. The
exit code is 1 if a result differs or a case that was ok no longer is.
"""

import argparse
import json
import sys

FACTOR = 1.1
FLOOR_MS = 20


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def time(case):
    """The time of a case in ms, or its status if that is not ok."""
    return min(case["ms"]) if case["status"] == "ok" else case["status"]


def change(old, new, limits):
    """How a case changed, the ms it saved, and whether the change is bad."""
    was, now = old["status"], new["status"]
    if was == now != "ok":
        return "", 0, False
    if "error" in (was, now):
        return f"{was} -> {now}", 0, now != "ok"
    if was == now and old["result"] != new["result"]:
        return "RESULT DIFFERS", 0, True
    a = time(old) if was == "ok" else limits[0]
    b = time(new) if now == "ok" else limits[1]
    if was != now:
        return f"{was} -> {now}", a - b, now != "ok"
    if b > FACTOR * a and b - a > FLOOR_MS:
        return "slower", a - b, False
    if a > FACTOR * b and a - b > FLOOR_MS:
        return "faster", a - b, False
    return "", 0, False


def describe(what, old, new, limits):
    """The text shown for a change, such as "4.2x faster"."""
    if what in ("", "RESULT DIFFERS") or "error" in what:
        return what
    a = time(old) if old["status"] == "ok" else limits[0]
    b = time(new) if new["status"] == "ok" else limits[1]
    times = max(a, b) / max(min(a, b), 1)
    if times >= 10:
        text = f"{times:.0f}x"
    elif times >= 2:
        text = f"{times:.1f}x"
    else:
        text = f"{times:.2f}x"
    text += " faster" if a > b else " slower"
    if what in ("faster", "slower"):
        return text
    return f"{what}, over {text}"


def differ(a, b):
    """Whether two times in ms are not about the same."""
    return max(a, b) > FACTOR * min(a, b) and abs(a - b) > FLOOR_MS


def bold_lower(a, b, both):
    """The cells for a and b, with the lower one in bold if both is true."""
    cells = [str(a), str(b)]
    if both and a != b:
        i = 0 if a < b else 1
        cells[i] = f"**{cells[i]}**"
    return cells


def print_text(header, rows, families, summary, limits):
    print("\n".join(header) + "\n")
    width = max([len(row[0]) for row in rows] + [4])
    print(f"{'case':{width}} {'old ms':>8} {'new ms':>8}")
    for name, o, n, what, _ in rows:
        print(f"{name:{width}} {time(o):>8} {time(n):>8}  "
              f"{describe(what, o, n, limits)}")
    print(f"\n{'':20} {'not ok':>17} {'ms where both ok':>21}")
    print(f"{'family':14} {'cases':>5} {'old':>8} {'new':>8} "
          f"{'old':>10} {'new':>10}")
    for name, (k, a, b, c, d) in families.items():
        print(f"{name:14} {k:5} {a:8} {b:8} {c:10} {d:10}")
    print("\n" + summary)


def print_markdown(header, rows, families, summary, limits):
    """The same as Markdown tables; of two times that are not about the
    same, the lower one is in bold."""
    print("  \n".join(header) + "\n")
    if rows:
        print("| case | change | old ms | new ms |")
        print("|---|---|--:|--:|")
    for name, o, n, what, _ in rows:
        cells = [str(time(o)), str(time(n))]
        if what in ("faster", "slower"):
            cells = bold_lower(time(o), time(n), True)
        elif what.endswith("-> ok"):
            cells[1] = f"**{cells[1]}**"
        elif what.startswith("ok -> "):
            cells[0] = f"**{cells[0]}**"
        print(f"| `{name}` | {describe(what, o, n, limits)} | "
              f"{cells[0]} | {cells[1]} |")
    print("\n| family | cases | not ok, old | not ok, new "
          "| ms where both ok, old | ms where both ok, new |")
    print("|---|--:|--:|--:|--:|--:|")
    for name, (k, a, b, c, d) in families.items():
        c, d = bold_lower(c, d, differ(c, d))
        print(f"| {name} | {k} | {a} | {b} | {c} | {d} |")
    print("\n" + summary)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("old")
    p.add_argument("new")
    p.add_argument("--all", action="store_true",
                   help="list all cases, not only those that changed")
    p.add_argument("--top", type=int, metavar="N",
                   help="of the cases that got faster or slower, list only "
                        "the N that gained or lost the most time")
    p.add_argument("--markdown", action="store_true",
                   help="print Markdown tables, with the lower of two "
                        "times that are not about the same in bold")
    args = p.parse_args()
    old, new = load(args.old), load(args.new)
    header = [f"{label}: {path} ({data['commit']}, {data['date']}, "
              f"{data['seeds']} seeds, limit {data['timeout']} s)"
              for label, path, data in (("old", args.old, old),
                                        ("new", args.new, new))]
    names = [name for name in old["cases"] if name in new["cases"]]
    header.append(f"{len(names)} cases in both files")
    limits = 1000 * old["timeout"], 1000 * new["timeout"]

    rows = []
    families = {}
    counts = {}
    bad = False
    for name in names:
        o, n = old["cases"][name], new["cases"][name]
        what, saved, isbad = change(o, n, limits)
        bad = bad or isbad
        rows.append((name, o, n, what, saved))
        if not what:
            what = "about the same" if o["status"] == "ok" else "not ok in both"
        counts[what] = counts.get(what, 0) + 1
        # cases, not ok in old, not ok in new, ms in old and new if both ok
        family = families.setdefault(name.split("/")[0], [0, 0, 0, 0, 0])
        family[0] += 1
        family[1] += o["status"] != "ok"
        family[2] += n["status"] != "ok"
        if o["status"] == "ok" and n["status"] == "ok":
            family[3] += time(o)
            family[4] += time(n)

    if args.top is not None:
        faster = sorted((row for row in rows if row[4] > 0),
                        key=lambda row: -row[4])
        slower = sorted((row for row in rows if row[4] < 0),
                        key=lambda row: row[4])
        rows = (faster[:args.top] + slower[:args.top]
                + [row for row in rows if row[3] and row[4] == 0])
    elif not args.all:
        rows = [row for row in rows if row[3]]
    summary = ", ".join(f"{k} {what}" for what, k in counts.items())
    show = print_markdown if args.markdown else print_text
    show(header, rows, families, summary, limits)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
