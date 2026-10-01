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
"""Summarise the GAP package releases made since a date, from their CHANGES.md.

    package_changes.py 2026-08-23              # releases after GAP 4.16.1
    package_changes.py 2026-08-23 --until 2026-09-30 --json

Reads <root>/<package>/CHANGES.md for every package clone below --root (default:
the current directory), e.g. clones of all repositories of the gap-packages
GitHub organisation; update them first. Prints, per package, each release
dated after SINCE (and up to --until) with its notes, as Markdown. A release in
PackageInfo.g that CHANGES.md lacks is listed without notes.

CHANGES.md format: free preamble, then one entry per release, newest first,

    ## 1.2.3 (2026-08-12)       a release
    ## 1.2 (2009-05)            only the month is known
    ## 1.1                      date unknown
    ## 1.3.0 (unreleased)       pending, version known
    ## Unreleased               pending
    ## 2.7 (never released)

each followed by its notes.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

ENTRY = re.compile(r"^## (?P<head>\S.*?)\s*$")
RELEASE = re.compile(r"^(?P<ver>v?\d[\w.+-]*)(?:\s+\((?P<when>[^)]*)\))?$")
FULL_DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
MONTH = re.compile(r"^(\d{4})-(\d{2})$")
PENDING = {"unreleased", "never released"}


@dataclass
class Release:
    version: str | None  # None for `## Unreleased`
    date: dt.date | None  # first day of the month if only that is known
    precision: str  # "day", "month", "none", "unreleased", "never released"
    notes: str
    header: str

    @property
    def released(self) -> bool:
        return self.precision in ("day", "month", "none")


@dataclass
class Changelog:
    package: str
    releases: list[Release] = field(default_factory=list)
    problems: list[str] = field(default_factory=list)
    # Version and Date of PackageInfo.g, if both are readable
    current: tuple[str, dt.date] | None = None


def parse(text: str, package: str = "") -> Changelog:
    """Split a CHANGES.md into its releases, in file order (newest first)."""
    log = Changelog(package)
    entries: list[tuple[str, list[str]]] = []
    for line in text.splitlines():
        if m := ENTRY.match(line):
            entries.append((m["head"], []))
        elif entries:
            entries[-1][1].append(line)

    for head, body in entries:
        notes = "\n".join(body).strip("\n")
        if head.lower() == "unreleased":
            log.releases.append(Release(None, None, "unreleased", notes, head))
            continue
        m = RELEASE.match(head)
        if not m:
            log.problems.append(f"not a release header: ## {head}")
            continue
        ver, when = m["ver"], (m["when"] or "").strip()
        rel = Release(ver, None, "none", notes, head)
        try:
            if when.lower() in PENDING:
                rel.precision = when.lower()
            elif FULL_DATE.match(when):
                rel.date, rel.precision = dt.date.fromisoformat(when), "day"
            elif mm := MONTH.match(when):
                rel.date, rel.precision = dt.date(int(mm[1]), int(mm[2]), 1), "month"
            elif when:
                log.problems.append(f"unreadable date: ## {head}")
        except ValueError:
            log.problems.append(f"invalid date: ## {head}")
        log.releases.append(rel)
    return log


def package_info(repo: Path) -> tuple[str, tuple[str, dt.date] | None]:
    """Return the package name and its (Version, Date) from PackageInfo.g."""
    info = repo / "PackageInfo.g"
    if not info.exists():
        return repo.name, None
    text = info.read_text(errors="replace")
    name = re.search(r'PackageName\s*:=\s*"([^"]+)"', text)
    ver = re.search(r'^\s*Version\s*:=\s*"([^"]+)"', text, re.M)
    date = re.search(r'^\s*Date\s*:=\s*"(\d\d)/(\d\d)/(\d{4})"', text, re.M)
    current = None
    if ver and date:
        try:
            current = ver[1], dt.date(int(date[3]), int(date[2]), int(date[1]))
        except ValueError:
            pass
    return (name[1] if name else repo.name), current


def read_changes(repo: Path, branch: str | None) -> str | None:
    """Return CHANGES.md from `origin/<branch>` if that exists, else the work tree."""
    if branch:
        show = subprocess.run(
            ["git", "show", f"origin/{branch}:CHANGES.md"],
            cwd=repo,
            capture_output=True,
            text=True,
            errors="replace",
        )
        if show.returncode == 0:
            return show.stdout
    path = repo / "CHANGES.md"
    return path.read_text(errors="replace") if path.exists() else None


def load_all(root: Path, branch: str | None = None) -> list[Changelog]:
    """Read the CHANGES.md of every package clone below `root`."""
    logs = []
    for repo in sorted(root.iterdir(), key=lambda p: p.name.lower()):
        if not (repo / "PackageInfo.g").exists():
            continue
        name, current = package_info(repo)
        text = read_changes(repo, branch)
        log = parse(text, name) if text is not None else Changelog(name)
        if text is None:
            log.problems.append("no CHANGES.md")
        log.current = current
        logs.append(log)
    return logs


def select(log: Changelog, since: dt.date, until: dt.date | None) -> list[Release]:
    """Return the releases of `log` in the window, newest first.

    The release in PackageInfo.g is added if CHANGES.md lacks it, so that no
    package update goes unmentioned.
    """
    rels = [r for r in log.releases if in_window(r, since, until)]
    if log.current and not re.search(r"dev", log.current[0], re.I):
        ver, date = log.current
        known = {r.version.lstrip("v") for r in log.releases if r.version}
        if (
            ver.lstrip("v") not in known
            and date > since
            and (not until or date <= until)
        ):
            rels.insert(0, Release(ver, date, "day", "", f"{ver} ({date})"))
            log.problems.append(f"{ver} ({date}) is not in CHANGES.md")
    return rels


def in_window(rel: Release, since: dt.date, until: dt.date | None) -> bool:
    """Whether `rel` was released after `since`, up to `until`.

    A month-only date counts if the whole month lies after `since`.
    """
    if not rel.released or rel.date is None:
        return False
    if until and rel.date > until:
        return False
    if rel.precision == "month":
        return rel.date > since.replace(day=1)
    return rel.date > since


def markdown(
    selected: list[tuple[Changelog, list[Release]]],
    since: dt.date,
    until: dt.date | None,
) -> str:
    span = f"after {since}" + (f" up to {until}" if until else "")
    n = sum(len(rels) for _, rels in selected)
    out = [
        f"# GAP package releases {span}",
        "",
        f"{n} releases of {len(selected)} packages.",
        "",
    ]
    for log, rels in selected:
        out.append(f"## {log.package}")
        out.append("")
        for rel in rels:
            date = (
                f"{rel.date:%Y-%m-%d}"
                if rel.precision == "day"
                else f"{rel.date:%Y-%m}"
            )
            out += [f"### {rel.version} ({date})", ""]
            if rel.notes:
                # headings in the notes go below the release heading
                out += [re.sub(r"(?m)^(#{3,})(?=\s)", r"#\1", rel.notes), ""]
            else:
                out += ["(no notes found in CHANGES.md)", ""]
    return "\n".join(out)


def parse_date(text: str) -> dt.date:
    try:
        return dt.date.fromisoformat(text)
    except ValueError:
        raise argparse.ArgumentTypeError(f"not a date in YYYY-MM-DD form: {text}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("since", type=parse_date, help="list releases after this date")
    parser.add_argument("--until", type=parse_date, help="and up to this date")
    parser.add_argument(
        "--root",
        type=Path,
        default=Path.cwd(),
        help="directory holding the package clones",
    )
    parser.add_argument(
        "--branch",
        metavar="NAME",
        help="read CHANGES.md from origin/NAME where it exists, e.g. "
        "changes-md to include unmerged pull requests",
    )
    parser.add_argument(
        "--json", action="store_true", help="print JSON instead of Markdown"
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="report CHANGES.md headers that cannot be read",
    )
    args = parser.parse_args()

    logs = load_all(args.root, args.branch)
    selected = []
    for log in logs:
        rels = select(log, args.since, args.until)
        if rels:
            selected.append((log, rels))

    if args.verbose:
        for log in logs:
            for problem in log.problems:
                print(f"{log.package}: {problem}", file=sys.stderr)
    else:
        # an entry without a readable header can hide a release in the window;
        # a header with an unreadable date like `(??)` is an old release
        troubled = [
            log.package
            for log in logs
            if any(not p.startswith("unreadable date") for p in log.problems)
        ]
        if troubled:
            print(
                f"warning: {len(troubled)} packages have no CHANGES.md or headers "
                "that cannot be read, so releases may be missing (see -v): "
                + ", ".join(troubled),
                file=sys.stderr,
            )

    if args.json:
        print(
            json.dumps(
                {
                    log.package: [
                        {
                            "version": r.version,
                            "date": r.date.isoformat(),
                            "date_precision": r.precision,
                            "notes": r.notes,
                        }
                        for r in rels
                    ]
                    for log, rels in selected
                },
                indent=2,
            )
        )
    else:
        print(markdown(selected, args.since, args.until))


if __name__ == "__main__":
    main()
