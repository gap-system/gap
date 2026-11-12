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
"""Time the benchmark cases for the partition backtrack, see README.md.

Runs every case of cases.g in a GAP process of its own, once per seed and
with a time limit, and writes the times and results to a JSON file for
compare.py.
"""

import argparse
import concurrent.futures
import datetime
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))


def runcase(args, variables, timeout=None):
    """Read runcase.g in a new GAP with these variables set."""
    out = subprocess.run(
        [args.gap, "-q", "-A", "--quitonbreak", "-l", args.gaproot + ";",
         "-c", variables, "runcase.g"],
        cwd=HERE, capture_output=True, text=True, stdin=subprocess.DEVNULL,
        timeout=timeout, check=False)
    return out.stdout + out.stderr


def time_case(args, name):
    """Run a case once per seed; return its status, times in ms and result."""
    case = {"status": "ok", "ms": []}
    for seed in range(1, args.seeds + 1):
        variables = f'PBT_CASE := "{name}";; PBT_SEED := {seed};;'
        try:
            out = runcase(args, variables, args.timeout)
        except subprocess.TimeoutExpired:
            case["status"] = "timeout"
            break
        found = re.search(r"^@RESULT\t(\d+)\t(.*)$", out, re.MULTILINE)
        if found is None:
            case["status"] = "error"
            case["error"] = " ".join(out.split())[-200:]
            break
        if case.setdefault("result", found[2]) != found[2]:
            case["status"] = "error"
            case["error"] = f"seed {seed} gives {found[2]}"
            break
        case["ms"].append(int(found[1]))
    return case


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--gap", default=os.path.join(ROOT, "gap"),
                   help="GAP executable (default: %(default)s)")
    p.add_argument("--gaproot", default=ROOT,
                   help="GAP root directory whose library is timed "
                        "(default: %(default)s)")
    p.add_argument("--filter", default="", metavar="REGEX",
                   help="only the cases whose name matches")
    p.add_argument("--list", action="store_true",
                   help="print the names of the cases and exit")
    p.add_argument("--seeds", type=int, default=1, metavar="N",
                   help="run each case with the seeds 1 to N (default: 1)")
    p.add_argument("--timeout", type=int, default=120, metavar="SECONDS",
                   help="time limit for each run (default: 120)")
    p.add_argument("--jobs", type=int, default=1, metavar="N",
                   help="number of GAP processes to run at once (default: 1)")
    p.add_argument("-o", "--output", default="pbt.json", metavar="FILE",
                   help="where to write the results (default: %(default)s)")
    args = p.parse_args()
    args.gap = os.path.abspath(args.gap)
    args.gaproot = os.path.abspath(args.gaproot)

    out = runcase(args, "PBT_CASE := fail;;")
    names = re.findall(r"^@CASE\t(.*)$", out, re.MULTILINE)
    if not names:
        sys.exit("cannot list the cases:\n" + out)
    names = [name for name in names if re.search(args.filter, name)]
    if args.list:
        print("\n".join(names))
        return

    cases = {}
    width = max(map(len, names))
    with concurrent.futures.ThreadPoolExecutor(args.jobs) as pool:
        timed = pool.map(lambda name: time_case(args, name), names)
        for name, case in zip(names, timed):
            cases[name] = case
            if case["status"] == "ok":
                shown = min(case["ms"]), case["result"]
            else:
                shown = case["status"], case.get("error", "")
            print(f"{name:{width}} {shown[0]:>8}  {shown[1]}", flush=True)

    commit = subprocess.run(
        ["git", "-C", args.gaproot, "describe", "--always", "--dirty"],
        capture_output=True, text=True, check=False).stdout.strip()
    with open(args.output, "w", encoding="utf-8") as f:
        date = datetime.datetime.now().isoformat(timespec="minutes")
        json.dump({"commit": commit, "date": date, "seeds": args.seeds,
                   "timeout": args.timeout, "cases": cases}, f, indent=1)
        f.write("\n")
    notok = sum(case["status"] != "ok" for case in cases.values())
    print(f"\n{len(cases)} cases, {notok} not ok; written to {args.output}")


if __name__ == "__main__":
    main()
