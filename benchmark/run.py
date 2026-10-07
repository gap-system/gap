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
"""Run a benchmark suite, one GAP process per case, and record timings.

Each case runs in its own process with a time limit, so a slow case cannot
hide or distort the others. Timings are CPU milliseconds as reported by
GAP's Runtime() for the timed part of the case only; setting up the
problem is not timed. See README for the file format and compare.py.
"""

import argparse
import concurrent.futures
import datetime
import json
import os
import re
import statistics
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DEFAULT_EXCLUDE = ["sweep"]


def gap_command(args, extra):
    cmd = [args.gap, "-q", "-b", "-A", "--quitonbreak", "-l", args.gaproot + ";"]
    if args.memory:
        cmd += ["-o", args.memory]
    cmd += ["-c", extra, os.path.join(HERE, "runcase.g")]
    return cmd


def gap_record(fields):
    return "BENCH := rec(" + ", ".join(fields) + ");;"


def gap_string(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def list_cases(args):
    rec = gap_record([
        "dir := " + gap_string(HERE),
        "suite := " + gap_string(args.suite),
        "list := true",
        "reproducible := false",
    ])
    out = subprocess.run(gap_command(args, rec), capture_output=True, text=True,
                         stdin=subprocess.DEVNULL, check=False)
    cases = []
    for line in out.stdout.splitlines():
        if not line.startswith("@CASE\t"):
            continue
        _, name, category, needs = line.split("\t")
        cases.append({"name": name, "category": category,
                      "needs": needs.split(",") if needs else []})
    if not cases:
        sys.exit("no cases found; GAP output was:\n" + out.stdout + out.stderr)
    return cases


def select(cases, args):
    chosen = []
    for case in cases:
        if args.category and case["category"] not in args.category:
            continue
        if not args.category and case["category"] in args.exclude_category:
            continue
        if args.filter and not any(re.search(f, case["name"]) for f in args.filter):
            continue
        chosen.append(case)
    return chosen


def run_case(case, args):
    rec = gap_record([
        "dir := " + gap_string(HERE),
        "suite := " + gap_string(args.suite),
        "case := " + gap_string(case["name"]),
        "repeats := " + str(args.repeat),
        "reproducible := " + ("true" if args.reproducible else "false"),
    ])
    result = {"category": case["category"], "status": "error", "ms": [],
              "result": "", "error": ""}
    try:
        out = subprocess.run(gap_command(args, rec), capture_output=True,
                             text=True, stdin=subprocess.DEVNULL,
                             timeout=args.timeout, check=False)
    except subprocess.TimeoutExpired:
        result["status"] = "timeout"
        result["ms"] = [args.timeout * 1000] * args.repeat
        return result
    for line in out.stdout.splitlines():
        if not line.startswith("@BENCH\t"):
            continue
        parts = line.split("\t")
        status = parts[2]
        result["status"] = status
        if status == "ok":
            result["ms"] = [int(x) for x in parts[3].split(",")]
            result["result"] = parts[4] if len(parts) > 4 else ""
        else:
            result["error"] = parts[4] if len(parts) > 4 else ""
        return result
    tail = (out.stdout + out.stderr).strip().splitlines()[-5:]
    result["error"] = "no result line; exit code %d; %s" % (
        out.returncode, " | ".join(tail))
    return result


def git_describe(root):
    try:
        rev = subprocess.run(["git", "-C", root, "rev-parse", "--short", "HEAD"],
                             capture_output=True, text=True, check=True).stdout.strip()
        dirty = subprocess.run(["git", "-C", root, "status", "--porcelain",
                                "--untracked-files=no"],
                               capture_output=True, text=True, check=True).stdout.strip()
        return rev + ("+dirty" if dirty else "")
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


def summarize(ms):
    if not ms:
        return None, None
    return min(ms), int(statistics.median(ms))


def print_table(results):
    width = max(len(name) for name in results) if results else 10
    print("%-*s  %-12s  %-8s  %9s  %9s  %s" % (width, "case", "category",
                                               "status", "min ms", "median", "result"))
    for name in sorted(results, key=lambda n: (results[n]["category"], n)):
        r = results[name]
        mn, md = summarize(r["ms"])
        shown = r["result"] if r["status"] == "ok" else r["error"]
        print("%-*s  %-12s  %-8s  %9s  %9s  %s" % (
            width, name, r["category"], r["status"],
            "" if mn is None else mn, "" if md is None else md, shown[:50]))
    totals = {}
    counts = {}
    for r in results.values():
        totals.setdefault(r["category"], 0)
        counts.setdefault(r["category"], [0, 0])
        if r["status"] == "ok":
            totals[r["category"]] += min(r["ms"])
            counts[r["category"]][0] += 1
        else:
            counts[r["category"]][1] += 1
    print()
    for cat in sorted(totals):
        print("%-12s  %6d ms over %d cases, %d not ok" % (
            cat, totals[cat], counts[cat][0], counts[cat][1]))


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--gap", default=os.path.join(ROOT, "gap"),
                   help="GAP executable (default: gap in the repository root)")
    p.add_argument("--gaproot", default=ROOT,
                   help="GAP root whose library to use, passed via -l; "
                        "lets one binary benchmark several checkouts")
    p.add_argument("--suite", default="pbt", help="suite directory (default: pbt)")
    p.add_argument("--list", action="store_true", help="list the cases and exit")
    p.add_argument("--filter", action="append", default=[], metavar="REGEX",
                   help="only cases whose name matches (repeatable)")
    p.add_argument("--category", action="append", default=[], metavar="CAT",
                   help="only these categories (repeatable); overrides the "
                        "default exclusion of %s" % ", ".join(DEFAULT_EXCLUDE))
    p.add_argument("--exclude-category", action="append", default=DEFAULT_EXCLUDE,
                   metavar="CAT")
    p.add_argument("--repeat", type=int, default=1,
                   help="repetitions per case; the minimum is compared")
    p.add_argument("--timeout", type=int, default=300, metavar="SEC",
                   help="time limit per case process (default: 300)")
    p.add_argument("--jobs", type=int, default=1,
                   help="parallel processes; timings suffer from contention")
    p.add_argument("--memory", default="", metavar="SIZE",
                   help="GAP -o option, e.g. 8g")
    p.add_argument("--no-reproducible", dest="reproducible", action="store_false",
                   help="do not set the ReproducibleBehaviour preference")
    p.add_argument("--output", "-o", default=None, metavar="FILE",
                   help="JSON output (default: benchmark-<suite>.json)")
    p.add_argument("--baseline", metavar="FILE",
                   help="compare with this earlier JSON output afterwards")
    p.add_argument("--quiet", action="store_true")
    args = p.parse_args()
    args.gap = os.path.abspath(args.gap)
    args.gaproot = os.path.abspath(args.gaproot)
    if args.output is None:
        args.output = "benchmark-%s.json" % args.suite

    cases = select(list_cases(args), args)
    if args.list:
        for case in cases:
            print("%-40s %-12s %s" % (case["name"], case["category"],
                                      ",".join(case["needs"])))
        return

    results = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = {pool.submit(run_case, case, args): case for case in cases}
        for fut in concurrent.futures.as_completed(futures):
            case = futures[fut]
            results[case["name"]] = fut.result()
            if not args.quiet:
                r = results[case["name"]]
                mn, _ = summarize(r["ms"])
                print("%-40s %-8s %9s  %s" % (
                    case["name"], r["status"], "" if mn is None else mn,
                    (r["result"] if r["status"] == "ok" else r["error"])[:40]),
                    flush=True)

    data = {
        "suite": args.suite,
        "gap": args.gap,
        "gaproot": args.gaproot,
        "commit": git_describe(args.gaproot),
        "date": datetime.datetime.now().isoformat(timespec="seconds"),
        "repeat": args.repeat,
        "timeout": args.timeout,
        "reproducible": args.reproducible,
        "cases": results,
    }
    with open(args.output, "w") as f:
        json.dump(data, f, indent=1, sort_keys=True)
        f.write("\n")
    print()
    print_table(results)
    print("\nwritten to", args.output)

    if args.baseline:
        sys.path.insert(0, HERE)
        import compare
        print()
        sys.exit(compare.compare_files(args.baseline, args.output))


if __name__ == "__main__":
    main()
