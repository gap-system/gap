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

# Usage:
#     ./release_notes.py VERSION
#
# For example
#     ./release_notes.py 4.13.1
#
# A version ending in .0 is considered MAJOR, any other MINOR.
#
# Pre-releases such as 4.13.1-beta1 are supported, and are treated exactly like
# the release they lead up to: the notes always cover everything since the
# previous release. Hence writing the notes for 4.13.1-beta2 or for 4.13.1
# replaces the section of any earlier pre-release of 4.13.1.
#
# The tag marking the start of the release period must exist: v4.13dev for a
# major release 4.13.0, and v4.13.0 for a minor release 4.13.1.
#
# The release notes are written directly into CHANGES.md, replacing any section
# for the same version that is already there. So the script can be run
# repeatedly while tweaking PR labels and titles:
#
#     git add CHANGES.md && ./release_notes.py 4.13.1 && git diff CHANGES.md
#
# PRs which still need attention are reported on stderr, not written to a file.

import gzip
import io
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from typing import Any, Dict, List, Tuple

import requests
from utils import (
    download_with_sha256,
    error,
    notice,
    verify_command_available,
    warning,
)

# heading of a release section in CHANGES.md, e.g. "## GAP 4.13.1 (June 2024)"
# or "## GAP 4.13.1-beta1 (May 2024)"
RELEASE_HEADING = re.compile(r"^## GAP (\d+)\.(\d+)\.(\d+)(-\S+)? ", re.MULTILINE)


def usage(name: str) -> None:
    print(f"Usage: `{name} NEWVERSION`")
    sys.exit(1)


def parse_version(version: str) -> Tuple[int, int, int]:
    """Returns the numeric part of a version such as 4.13.1 or 4.13.1-beta1.

    A pre-release and the release it leads up to have the same numeric part, and
    thus share a single section in CHANGES.md."""
    base, _, prerelease = version.partition("-")
    try:
        major, minor, patchlevel = map(int, base.split("."))
    except ValueError:
        error(f"invalid version '{version}', expected something like '4.13.1'")
    if major != 4:
        error("unexpected GAP version, not starting with '4.'")
    if "-" in version and not re.fullmatch(r"[A-Za-z][A-Za-z0-9.]*", prerelease):
        error(f"invalid pre-release suffix '-{prerelease}', expected e.g. '-beta1'")
    return major, minor, patchlevel


def heading_version(m: "re.Match[str]") -> Tuple[int, int, int]:
    return (int(m.group(1)), int(m.group(2)), int(m.group(3)))


def repo_root() -> str:
    res = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        check=False,
        capture_output=True,
        text=True,
    )
    if res.returncode != 0:
        error("not inside a git repository")
    return res.stdout.strip()


def is_existing_tag(tag: str) -> bool:
    res = subprocess.run(
        ["git", "show-ref", "--quiet", "--verify", "refs/tags/" + tag], check=False
    )
    return res.returncode == 0


def find_previous_version(version: str) -> str:
    major, minor, patchlevel = parse_version(version)
    if patchlevel != 0:
        patchlevel -= 1
        return f"{major}.{minor}.{patchlevel}"
    minor -= 1
    patchlevel = 0
    while True:
        v = f"{major}.{minor}.{patchlevel}"
        if not is_existing_tag("v" + v):
            break
        patchlevel += 1
    if patchlevel == 0:
        error("could not determine previous version")
    patchlevel -= 1
    return f"{major}.{minor}.{patchlevel}"


def package_infos_url(tag: str) -> str:
    return f"https://github.com/gap-system/PackageDistro/releases/download/{tag}/package-infos.json.gz"


def url_exists(url: str) -> bool:
    response = requests.head(url, allow_redirects=True)
    return response.status_code == 200


def package_updates(relnotes_file: io.StringIO, new_gap_version: str) -> None:
    # create tmp directory
    tmpdir = os.path.join(repo_root(), "tmp")
    notice(f"Files will be put in {tmpdir}")
    try:
        os.mkdir(tmpdir)
    except FileExistsError:
        pass

    old_gap_version = find_previous_version(new_gap_version)
    notice(
        f"generating package release notes for {old_gap_version} -> {new_gap_version}"
    )

    oldtag = "v" + old_gap_version
    newtag = "v" + new_gap_version
    if not url_exists(package_infos_url(newtag)):
        warning(
            f"no package infos found for {newtag} -- did you forget to tag "
            "gap-system/PackageDistro? Using latest instead"
        )
        newtag = "latest"

    # download package metadata
    old_json_file = f"{tmpdir}/package-infos-{oldtag}.json.gz"
    new_json_file = f"{tmpdir}/package-infos-{newtag}.json.gz"

    download_with_sha256(package_infos_url(oldtag), old_json_file)
    download_with_sha256(package_infos_url(newtag), new_json_file)

    # parse package metadata
    with gzip.open(old_json_file, "r") as f:
        old_json = json.load(f)

    with gzip.open(new_json_file, "r") as f:
        new_json = json.load(f)

    relnotes_file.write("### Package distribution\n\n")

    #
    # Detect new packages
    #
    added = new_json.keys() - old_json.keys()
    if len(added) > 0:
        relnotes_file.write("#### New packages redistributed with GAP\n\n")
        for p in sorted(added):
            pkg = new_json[p]
            name = pkg["PackageName"]
            home = pkg["PackageWWWHome"]
            desc = pkg["Subtitle"]
            vers = pkg["Version"]
            authors = ", ".join(
                [
                    x["FirstNames"] + " " + x["LastName"]
                    for x in pkg["Persons"]
                    if x["IsAuthor"]
                ]
            )
            relnotes_file.write(
                f"- [**{name}**]({home}) {vers}: {desc}, by {authors}\n"
            )
        relnotes_file.write("\n")

    #
    # Detect removed packages
    #
    removed = old_json.keys() - new_json.keys()
    if len(removed) > 0:
        relnotes_file.write("#### Packages no longer redistributed with GAP\n\n")
        for p in sorted(removed):
            name = old_json[p]["PackageName"]
            relnotes_file.write(f"- **{name}**: TODO\n")
        relnotes_file.write("\n")

    #
    # Detect updated packages
    #
    updated = new_json.keys() & old_json.keys()
    updated = [p for p in updated if old_json[p]["Version"] != new_json[p]["Version"]]
    if len(updated) > 0:
        relnotes_file.write(f"""
#### Updated packages redistributed with GAP

The GAP {new_gap_version} distribution contains {len(new_json)} packages, of which {len(updated)} have been
updated since GAP {old_gap_version}. The full list of updated packages is given below:

""".lstrip())
        for p in sorted(updated):
            old = old_json[p]
            new = new_json[p]
            name = new["PackageName"]
            home = new["PackageWWWHome"]
            oldversion = old["Version"]
            newversion = new["Version"]
            relnotes_file.write(
                f"- [**{name}**]({home}): {oldversion} -> {newversion}\n"
            )


# the following is a list of pairs [LABEL, DESCRIPTION]; the first entry is the name of a GitHub label
# (be careful to match them precisely), the second is a headline for a section the release notes; any PR with
# the given label is put into the corresponding section; each PR is put into only one section, the first one
# one from this list it fits in.
# See also <https://github.com/gap-system/gap/issues/4257>.
prioritylist = [
    ["release notes: highlight", "Highlights"],
    ["kind: new feature", "New features"],
    ["topic: performance", "Performance improvements"],
    ["kind: enhancement", "Improved and extended functionality"],
    ["kind: removal or deprecation", "Removed or obsolete functionality"],
    ["topic: packages", "Changes related to handling of packages"],
    ["topic: gac", "Changes to the GAP compiler"],
    ["topic: documentation", "Changes in the documentation"],
    ["topic: build system", "Build system"],
    ["topic: julia", "Changes to the **Julia** integration"],
    ["topic: libgap", "Changes to the `libgap` interface"],
    ["topic: HPC-GAP", "Changes to HPC-GAP"],
    ["kind: bug: wrong result", "Fixed bugs that could lead to incorrect results"],
    ["kind: bug: crash", "Fixed bugs that could lead to crashes"],
    [
        "kind: bug: unexpected error",
        "Fixed bugs that could lead to unexpected errors",
    ],
    ["kind: bug", "Other fixed bugs"],
]


def get_tag_date(tag: str) -> str:
    if not is_existing_tag(tag):
        error(f"tag '{tag}' does not exist")
    res = subprocess.run(
        ["git", "for-each-ref", "--format=%(creatordate:short)", "refs/tags/" + tag],
        check=True,
        capture_output=True,
        text=True,
    )
    return res.stdout.strip()


PR_LIMIT = 500


def get_pr_list(date: str, extra: str) -> List[Dict[str, Any]]:
    query = f'merged:>={date} -label:"release notes: not needed" base:master {extra}'
    print("query: ", query)
    res = subprocess.run(
        [
            "gh",
            "pr",
            "list",
            "--search",
            query,
            "--json",
            "number,title,closedAt,labels,mergedAt,author",
            "--limit",
            str(PR_LIMIT),
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    prs = json.loads(res.stdout.strip())
    if len(prs) >= PR_LIMIT:
        warning(f"hit the limit of {PR_LIMIT} PRs, some may be missing")
    # sort by PR number, newest first, so that re-runs produce identical output
    return sorted(prs, key=lambda pr: pr["number"], reverse=True)


def pr_to_md(pr: Dict[str, Any]) -> str:
    """Returns markdown string for the PR entry"""
    k = pr["number"]
    title = pr["title"]
    return f"- [#{k}](https://github.com/gap-system/gap/pull/{k}) {title}\n"


def has_label(pr: Dict[str, Any], label: str) -> bool:
    return any(x["name"] == label for x in pr["labels"])


def is_dependabot_pr(pr: Dict[str, Any]) -> bool:
    author = pr.get("author") or {}
    login = author.get("login")
    if login in ("app/dependabot", "dependabot[bot]"):
        return True
    return author.get("is_bot", False) and has_label(pr, "dependencies")


def release_notes_section(prs: List[Dict[str, Any]], new_version: str) -> str:
    """Returns the CHANGES.md section for the given release."""

    month = datetime.now().strftime("%B")
    year = datetime.now().year

    out = io.StringIO()
    prs_with_use_title = [pr for pr in prs if has_label(pr, "release notes: use title")]
    out.write(f"""## GAP {new_version} ({month} {year})

The following gives an overview of the changes compared to the previous
release. This list is not complete, many more internal or minor changes
were made, but we tried to only list those changes which we think might
affect some users directly.

""")

    for label, headline in prioritylist:
        matches = [pr for pr in prs_with_use_title if has_label(pr, label)]
        print(f"PRs with label '{label}': ", len(matches))
        if len(matches) == 0:
            continue
        out.write("### " + headline + "\n\n")
        for pr in matches:
            out.write(pr_to_md(pr))
            prs_with_use_title.remove(pr)
        out.write("\n")

    # The remaining PRs have no "kind" or "topic" label from the priority list
    # (may have other "kind" or "topic" label outside the priority list).
    # Check their list in the release notes, and adjust labels if appropriate.
    if len(prs_with_use_title) > 0:
        out.write("### Other changes\n\n")
        for pr in prs_with_use_title:
            out.write(pr_to_md(pr))
        out.write("\n")

    package_updates(out, new_version)

    return out.getvalue().rstrip("\n") + "\n"


def update_changes_md(path: str, new_version: str, section: str) -> None:
    """Insert `section` into the CHANGES.md file at `path`, replacing any existing
    sections for the same version -- including those of its pre-releases, which
    the new section supersedes. Running this repeatedly for one version is
    idempotent."""

    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    key = parse_version(new_version)
    section = section.rstrip("\n") + "\n\n"
    headings = list(RELEASE_HEADING.finditer(content))

    # byte ranges of the sections superseded by the new one
    obsolete = [
        (m.start(), headings[i + 1].start() if i + 1 < len(headings) else len(content))
        for i, m in enumerate(headings)
        if heading_version(m) == key
    ]

    if obsolete:
        replaced = [
            m.group(0).removeprefix("## ").strip()
            for m in headings
            if heading_version(m) == key
        ]
        # cut from the back, so that the offsets of earlier sections still apply
        for start, end in reversed(obsolete):
            content = content[:start] + content[end:]
        at = obsolete[0][0]
        content = content[:at] + section + content[at:]
        notice(f"Replaced in {path}: " + ", ".join(replaced))
    else:
        older = next(
            (m.start() for m in headings if heading_version(m) < key), len(content)
        )
        content = content[:older].rstrip("\n") + "\n\n" + section + content[older:]
        notice(f"Inserted a GAP {new_version} section into {path}")

    with open(path, "w", encoding="utf-8") as f:
        f.write(content.rstrip("\n") + "\n")


def pr_to_line(pr: Dict[str, Any]) -> str:
    k = pr["number"]
    return f"  https://github.com/gap-system/gap/pull/{k}  {pr['title']}"


def report_unsorted_prs(prs: List[Dict[str, Any]]) -> None:
    """Report PRs which need manual attention on stderr."""

    to_be_added = [pr for pr in prs if has_label(pr, "release notes: to be added")]
    uncategorized = [
        pr
        for pr in prs
        if not has_label(pr, "release notes: to be added")
        and not has_label(pr, "release notes: use title")
    ]

    if to_be_added:
        warning(f'{len(to_be_added)} PRs labelled "release notes: to be added":')
        for pr in to_be_added:
            print(pr_to_line(pr), file=sys.stderr)
        warning(
            'Check their title and labels, then relabel to "release notes: use title".'
        )

    if uncategorized:
        warning(f"{len(uncategorized)} PRs without any release notes label:")
        for pr in uncategorized:
            print(pr_to_line(pr), file=sys.stderr)
        warning(
            'Apply the same steps as above, or label them "release notes: not needed".'
        )

    if not to_be_added and not uncategorized:
        notice("All PRs are categorized")


def main(new_version: str) -> None:
    verify_command_available("git")
    verify_command_available("gh")
    major, minor, patchlevel = parse_version(new_version)
    if patchlevel == 0:
        # "major" GAP release which changes just the minor version
        previous_minor = minor - 1
        basetag = f"v{major}.{minor}dev"
        # *exclude* PRs backported to previous stable-4.X branch
        extra = f'-label:"backport-to-{major}.{previous_minor}-DONE"'
    else:
        # "minor" GAP release which changes just the patchlevel
        previous_patchlevel = patchlevel - 1
        basetag = f"v{major}.{minor}.{previous_patchlevel}"
        # *include* PRs backported to current stable-4.X branch
        extra = f'label:"backport-to-{major}.{minor}-DONE"'

    print("Base tag is", basetag)

    startdate = get_tag_date(basetag)
    print("Base tag was created ", startdate)

    print("Downloading filtered PR list")
    prs = get_pr_list(startdate, extra)
    prs = [pr for pr in prs if not is_dependabot_pr(pr)]
    # print(json.dumps(prs, sort_keys=True, indent=4))

    changes_md = os.path.join(repo_root(), "CHANGES.md")
    update_changes_md(changes_md, new_version, release_notes_section(prs, new_version))
    report_unsorted_prs(prs)


if __name__ == "__main__":
    # the argument is the new version
    if len(sys.argv) != 2:
        usage(sys.argv[0])

    main(sys.argv[1])
