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
"""Summarise the GAP package releases made since a date, from their changelogs.

    package_changes.py 2026-08-23              # releases after GAP 4.16.1
    package_changes.py 2026-08-23 --until 2026-09-30 --json

Reads the changelog of every package clone below --root (default: the current
directory), e.g. clones of all repositories of the gap-packages GitHub
organisation; update them first. Prints, per package, each release dated after
SINCE (and up to --until) with its notes, as Markdown. A release in
PackageInfo.g that the changelog lacks is listed without notes.

The changelog is the file CHANGES.md, or else one named CHANGES, CHANGELOG, NEWS
or HISTORY, in any case, with the extension .md, .txt or none.

Its format: free preamble, then one entry per release, newest first,

    ## 1.2.3 (2026-08-12)       a release
    ## 1.2 (2009-05)            only the month is known
    ## 1.1                      date unknown
    ## 1.3.0 (unreleased)       pending, version known
    ## Unreleased               pending
    ## 2.7 (never released)

each followed by its notes. A file without any such header is read on a best
effort basis as one of the older formats, e.g. `Version 1.2.3 (12/08/2026)`,
`1.2.2 -> 1.2.3` or `Changes from 1.2.2 to 1.2.3 (August 2026)`.
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

# file names of a changelog and their extensions, best first
CHANGELOG_NAMES = ("changes", "changelog", "news", "history")
CHANGELOG_SUFFIXES = (".md", ".txt", "")

ENTRY = re.compile(r"^## (?P<head>\S.*?)\s*$")
RELEASE = re.compile(r"^(?P<ver>v?\d[\w.+-]*)(?:\s+\((?P<when>[^)]*)\))?$")
FULL_DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
PENDING = {"unreleased", "never released", "tbd"}

# Headers of the older formats. Each ends in an optional date, in parentheses
# or not, which may follow a note such as "for GAP 4.16.1".
VER = r"\d+(?:\.\d+)+[\w+-]*"
OLD_HEADER_TAIL = (
    r"\s*(?:(?:ready\s+)?for\s+GAP\s+[\d.]+)?\s*[-:,]?\s*"
    r"(?:\(\s*(?:released\s+)?(?P<paren>[^()]*?)\s*\)|(?P<plain>[^()]*?))\s*:?\s*$"
)
OLD_HEADERS = [
    re.compile(start + OLD_HEADER_TAIL, re.IGNORECASE)
    for start in (
        # Changes from 1.36 to 1.37 / Main changes from GRAPE 4.9.2 to GRAPE 4.9.3
        # / Changes between RCWA 4.10.0 and RCWA 4.10.1
        rf"^(?:main\s+)?changes?\s+(?:from|between)\s+(?:\w+\s+)?v?{VER}"
        rf"\s+(?:to|and)\s+(?:\w+\s+)?v?(?P<ver>{VER})",
        # Changes for 1.1.0
        rf"^changes\s+for\s+v?(?P<ver>{VER})",
        # 1.16 -> 1.17 / Changes v4.0 -> 4.1
        rf"^(?:changes\s+)?v?{VER}\s*->\s*v?(?P<ver>{VER})",
        # [v1.2.4] - 2026-04-28
        rf"^\[v?(?P<ver>{VER})\]",
        # 1.2.3 / v1.2.3 / Version 1.2.3
        rf"^(?:version\s+)?v?(?P<ver>{VER})",
    )
]
SEPARATOR = re.compile(r"^\s*#?\s*(?:=+|-{3,})\s*$")
MONTHS = {
    name.lower(): number
    for number, name in enumerate(
        "January February March April May June July August September October "
        "November December".split(),
        1,
    )
}


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


def release_date(text: str) -> tuple[dt.date | None, str]:
    """Read a date as (date, "day" or "month"), or (None, "") if it is none."""

    def make(year: str, month: object, day: object = 1) -> dt.date | None:
        y = int(year)
        if y < 100:
            y += 2000 if y < 70 else 1900
        try:
            return dt.date(y, int(str(month)), int(str(day)))
        except ValueError:
            return None

    s = text.strip().rstrip(".:,")
    date, precision = None, "day"
    if m := re.fullmatch(r"(\d{4})[-/](\d{1,2})[-/](\d{1,2})", s):  # 2026-08-12
        date = make(m[1], m[2], m[3])
    elif m := re.fullmatch(r"(\d{1,2})/(\d{1,2})/(\d{2,4})", s):  # 12/08/2026
        date = make(m[3], m[2], m[1])
    elif m := re.fullmatch(r"([A-Za-z]+)\s+(\d{1,2}),\s*(\d{4})", s):  # August 12, 2026
        date = make(m[3], MONTHS.get(m[1].lower(), 0), m[2])
    elif m := re.fullmatch(r"(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})", s):  # 12 August 2026
        date = make(m[3], MONTHS.get(m[2].lower(), 0), m[1])
    elif m := re.fullmatch(r"(\d{4})-(\d{2})", s):  # 2026-08
        date, precision = make(m[1], m[2]), "month"
    elif m := re.fullmatch(r"([A-Za-z]+)\s+(\d{4})", s):  # August 2026
        date, precision = make(m[2], MONTHS.get(m[1].lower(), 0)), "month"
    elif m := re.fullmatch(r"(\d{1,2})-(\d{4})", s):  # 8-2026
        date, precision = make(m[2], m[1]), "month"
    return (date, precision) if date else (None, "")


def new_header(line: str) -> tuple[str | None, str] | None:
    """Return (version, text in parentheses) of a `## ` release header.

    The version is None for `## Unreleased`.
    """
    m = ENTRY.match(line)
    if not m:
        return None
    if m["head"].lower() == "unreleased":
        return None, "unreleased"
    if r := RELEASE.match(m["head"]):
        return r["ver"], (r["when"] or "").strip()
    return None


def old_header(line: str) -> tuple[str | None, str] | None:
    """Return (version, date text) if `line` heads a release in an older format."""
    if line[:1].isspace() and not re.match(r" version\b", line, re.IGNORECASE):
        return None
    text = re.sub(r"^#{1,3}\s+", "", line.strip())
    text = re.sub(r"^[-*]\s+", "", text)
    if text.lower() in ("unreleased", "[unreleased]"):
        return None, "unreleased"
    for rx in OLD_HEADERS:
        if m := rx.match(text):
            when = (m["paren"] if m["paren"] is not None else m["plain"]).strip()
            # prose starting with a version number is no header
            if when and when.lower() not in PENDING and not release_date(when)[0]:
                return None
            return m["ver"], when
    return None


def old_notes(body: list[str]) -> str:
    """Join the lines of an entry, without separator lines and indentation."""
    lines = [line.rstrip() for line in body if not SEPARATOR.match(line)]
    indents = [len(line) - len(line.lstrip()) for line in lines if line]
    cut = min(indents, default=0)
    return "\n".join(line[cut:] for line in lines).strip("\n")


def parse(text: str, package: str = "") -> Changelog:
    """Split a changelog into its releases, in file order."""
    log = Changelog(package)
    lines = text.splitlines()
    # one `## VERSION` header makes the file one in the current format, in
    # which nothing else is a header
    current_format = any(new_header(line) for line in lines)

    entries: list[tuple[str, str | None, str, list[str]]] = []
    body: list[str] | None = None
    for line in lines:
        header = new_header(line) if current_format else old_header(line)
        if header:
            body = []
            entries.append((line.strip(), *header, body))
        elif current_format and ENTRY.match(line):
            log.problems.append(f"not a release header: {line.strip()}")
            body = None
        elif body is not None:
            body.append(line)
    if not entries:
        log.problems.append("no release entries found")

    for head, ver, when, body in entries:
        notes = "\n".join(body).strip("\n") if current_format else old_notes(body)
        rel = Release(ver, None, "none", notes, head)
        if ver is None or when.lower() in PENDING or "dev" in ver.lower():
            pending = when.lower() if when.lower() in PENDING else "unreleased"
            rel.precision = "unreleased" if pending == "tbd" else pending
        elif when:
            date, precision = release_date(when)
            if date:
                rel.date, rel.precision = date, precision
            elif FULL_DATE.match(when):
                log.problems.append(f"invalid date: {head}")
            else:
                log.problems.append(f"unreadable date: {head}")
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


def find_changelog(names: list[str]) -> str | None:
    """Pick the changelog among the file names of a package's top directory."""
    ranked = []
    for name in names:
        stem, dot, extension = name.lower().partition(".")
        if stem in CHANGELOG_NAMES and dot + extension in CHANGELOG_SUFFIXES:
            rank = CHANGELOG_NAMES.index(stem), CHANGELOG_SUFFIXES.index(
                dot + extension
            )
            ranked.append((rank, name))
    return min(ranked)[1] if ranked else None


def read_changes(repo: Path, branch: str | None) -> str | None:
    """Return the changelog from `origin/<branch>` if it has one, else the work tree's."""

    def git(*args: str) -> str | None:
        result = subprocess.run(
            ["git", *args], cwd=repo, capture_output=True, text=True, errors="replace"
        )
        return result.stdout if result.returncode == 0 else None

    if branch:
        listing = git("ls-tree", "--name-only", f"origin/{branch}")
        name = find_changelog(listing.splitlines()) if listing else None
        if name:
            return git("show", f"origin/{branch}:{name}")
    name = find_changelog([p.name for p in repo.iterdir() if p.is_file()])
    return (repo / name).read_text(errors="replace") if name else None


def load_all(root: Path, branch: str | None = None) -> list[Changelog]:
    """Read the changelog of every package clone below `root`."""
    logs = []
    for repo in sorted(root.iterdir(), key=lambda p: p.name.lower()):
        if not (repo / "PackageInfo.g").exists():
            continue
        name, current = package_info(repo)
        text = read_changes(repo, branch)
        log = parse(text, name) if text is not None else Changelog(name)
        if text is None:
            log.problems.append("no changelog")
        log.current = current
        if current:
            # an undated entry for the current version was released on the
            # date in PackageInfo.g
            for rel in log.releases:
                if rel.precision == "none" and rel.version.lstrip("v") == current[0]:
                    rel.date, rel.precision = current[1], "day"
        logs.append(log)
    return logs


def select(log: Changelog, since: dt.date, until: dt.date | None) -> list[Release]:
    """Return the releases of `log` in the window, newest first.

    The release in PackageInfo.g is added if the changelog lacks it, so that no
    package update goes unmentioned.
    """
    rels = [r for r in log.releases if in_window(r, since, until)]
    rels.sort(key=lambda r: r.date or dt.date.min, reverse=True)
    if log.current and not re.search(r"dev", log.current[0], re.I):
        ver, date = log.current
        known = {r.version.lstrip("v") for r in log.releases if r.version}
        if (
            ver.lstrip("v") not in known
            and date > since
            and (not until or date <= until)
        ):
            rels.insert(0, Release(ver, date, "day", "", f"{ver} ({date})"))
            log.problems.append(f"{ver} ({date}) is not in the changelog")
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
                out += ["(no notes found)", ""]
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
        help="read the changelog from origin/NAME where it exists, e.g. "
        "changes-md to include unmerged pull requests",
    )
    parser.add_argument(
        "--json", action="store_true", help="print JSON instead of Markdown"
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="report changelog headers that cannot be read",
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
                f"warning: {len(troubled)} packages have no changelog or headers "
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
