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
#     ./generate_release_notes.py VERSION
#
# For example
#     ./generate_release_notes.py 4.13.1
#
# This assumes that the tags named v4.13.1, 4.13dev (?) and v4.13.0 (???) already exists.
#
# A version ending in .0 is consider MAJOR, any other MINOR
# Don't use this with versions like 4.13.0-beta1

import json
import gzip
import os
import requests
import subprocess
import sys

from utils import error, notice, warning, is_existing_tag, download_with_sha256


def usage(name: str) -> None:
    print(f"Usage: `{name} NEWVERSION`")
    sys.exit(1)


def find_previous_version(version: str) -> str:
    major, minor, patchlevel = version.split(".")
    if major != "4":
        error("unexpected GAP version, not starting with '4.'")
    if patchlevel != "0":
        patchlevel = int(patchlevel) - 1
        return f"{major}.{minor}.{patchlevel}"
    minor = int(minor) - 1
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


def package_infos_url(tag):
    return f"https://github.com/gap-system/PackageDistro/releases/download/{tag}/package-infos.json.gz"


def url_exists(url):
    response = requests.get(url)
    return response.status_code == 200


def package_updates(relnotes_file, new_gap_version):
    # create tmp directory
    tmpdir = os.getcwd() + "/tmp"
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
        warning(f"no package infos found for {newtag}, switching to latest")
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
            authors = [
                x["FirstNames"] + " " + x["LastName"]
                for x in pkg["Persons"]
                if x["IsAuthor"]
            ]
            authors = ", ".join(authors)
            relnotes_file.write(
                f"- [**{name}**]({home}) {vers}: {desc}, by {authors}\n"
            )
        relnotes_file.write("\n")

    #
    # Detect new packages
    #
    removed = old_json.keys() - new_json.keys()
    if len(removed) > 0:
        relnotes_file.write("#### Packages no longer redistributed with GAP\n\n")
        for p in sorted(removed):
            name = old_json[p]["PackageName"]
            relnotes_file.write(f"- **{name}**: TODO\n")
        relnotes_file.write("\n")

    #
    # Detect new packages
    #
    updated = new_json.keys() & old_json.keys()
    updated = [p for p in updated if old_json[p]["Version"] != new_json[p]["Version"]]
    if len(updated) > 0:
        relnotes_file.write(
            f"""
#### Updated packages redistributed with GAP

The GAP {new_gap_version} distribution contains {len(new_json)} packages, of which {len(updated)} have been
updated since GAP {old_gap_version}. The full list of updated packages is given below:

""".lstrip()
        )
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
    ["topic: packages", "Changes related to handling of packages"],
    ["topic: gac", "Changes to the GAP compiler"],
    ["topic: documentation", "Changes in the documentation"],
    ["topic: performance", "Performance improvements"],
    ["topic: build system", "Build system"],
    ["topic: julia", "Changes to the **Julia** integration"],
    ["topic: libgap", "Changes to the `libgap` interface"],
    ["topic: HPC-GAP", "Changes to HPC-GAP"],
    ["kind: new feature", "New features"],
    ["kind: enhancement", "Improved and extended functionality"],
    ["kind: removal or deprecation", "Removed or obsolete functionality"],
    ["kind: bug: wrong result", "Fixed bugs that could lead to incorrect results"],
    ["kind: bug: crash", "Fixed bugs that could lead to crashes"],
    [
        "kind: bug: unexpected error",
        "Fixed bugs that could lead to unexpected errors",
    ],
    ["kind: bug", "Other fixed bugs"],
]


def get_tag_date(tag: str) -> str:
    # TODO: validate the tag exists
    res = subprocess.run(
        ["git", "for-each-ref", "--format=%(creatordate:short)", "refs/tags/" + tag],
        check=True,
        capture_output=True,
        text=True,
    )
    if res.returncode != 0:
        error("error trying to dettermine tag date")
    return res.stdout.strip()


def get_pr_list(date: str, extra: str) -> str:
    query = f'merged:>={date} -label:"release notes: not needed" -label:"release notes: added" base:master {extra}'
    print("query: ", query)
    res = subprocess.run(
        [
            "gh",
            "pr",
            "list",
            "--search",
            query,
            "--json",
            "number,title,closedAt,labels,mergedAt",
            "--limit",
            "200",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    if res.returncode != 0:
        error("error trying to dettermine tag date")
    return json.loads(res.stdout.strip())


def pr_to_md(pr):
    """Returns markdown string for the PR entry"""
    k = pr["number"]
    title = pr["title"]
    return f"- [#{k}](https://github.com/gap-system/gap/pull/{k}) {title}\n"


def has_label(pr, label):
    return any(x["name"] == label for x in pr["labels"])


def changes_overview(prs, startdate, new_version):
    """Writes files with information for release notes."""

    # Could also introduce some consistency checks here for wrong combinations of labels
    filename = "releasenotes_" + new_version + ".md"
    notice("Writing release notes into file " + filename)
    relnotes_file = open(filename, "w")
    prs_with_use_title = [pr for pr in prs if has_label(pr, "release notes: use title")]

    # Write out all PRs with 'use title'
    relnotes_file.write(
        f"""
## GAP {new_version} (TODO insert date here, )

The following gives an overview of the changes compared to the previous
release. This list is not complete, many more internal or minor changes
were made, but we tried to only list those changes which we think might
affect some users directly.

"""
    )

    for priorityobject in prioritylist:
        matches = [pr for pr in prs_with_use_title if has_label(pr, priorityobject[0])]
        print("PRs with label '" + priorityobject[0] + "': ", len(matches))
        if len(matches) == 0:
            continue
        relnotes_file.write("### " + priorityobject[1] + "\n\n")
        for pr in matches:
            relnotes_file.write(pr_to_md(pr))
            prs_with_use_title.remove(pr)
        relnotes_file.write("\n")

    # The remaining PRs have no "kind" or "topic" label from the priority list
    # (may have other "kind" or "topic" label outside the priority list).
    # Check their list in the release notes, and adjust labels if appropriate.
    if len(prs_with_use_title) > 0:
        relnotes_file.write("### Other changes\n\n")
        for pr in prs_with_use_title:
            relnotes_file.write(pr_to_md(pr))
        relnotes_file.write("\n")

    package_updates(relnotes_file, new_version)

    relnotes_file.close()

    notice("Release notes were written into file " + filename)

    unsorted_file = open("unsorted_PRs_" + new_version + ".md", "w")

    # Report PRs that have to be updated before inclusion into release notes.
    unsorted_file.write("### " + "release notes: to be added" + "\n\n")
    unsorted_file.write(
        "If there are any PRs listed below, check their title and labels.\n"
    )
    unsorted_file.write(
        'When done, change their label to "release notes: use title".\n\n'
    )
    removelist = []
    for pr in prs:
        if has_label(pr, "release notes: to be added"):
            unsorted_file.write(pr_to_md(pr))

    prs = [pr for pr in prs if not has_label(pr, "release notes: to be added")]

    unsorted_file.write("\n")

    # Report PRs that have neither "to be added" nor "added" or "use title" label
    unsorted_file.write("### Uncategorized PR" + "\n\n")
    unsorted_file.write(
        "If there are any PRs listed below, either apply the same steps\n"
    )
    unsorted_file.write(
        'as above, or change their label to "release notes: not needed".\n\n'
    )
    removelist = []
    for pr in prs:
        # we need to use both old "release notes: added" label and
        # the newly introduced in "release notes: use title" label
        # since both label may appear in GAP 4.12.0 changes overview
        if not (
            has_label(pr, "release notes: added")
            or has_label(pr, "release notes: use title")
        ):
            unsorted_file.write(pr_to_md(pr))
    unsorted_file.close()


def main(new_version: str) -> None:
    major, minor, patchlevel = new_version.split(".")
    if major != "4":
        error("unexpected GAP version, not starting with '4.'")
    if patchlevel == "0":
        # "major" GAP release which changes just the minor version
        previous_minor = int(minor) - 1
        basetag = f"v{major}.{minor}dev"
        # *exclude* PRs backported to previous stable-4.X branch
        extra = f'-label:"backport-to-{major}.{previous_minor}-DONE"'
    else:
        # "minor" GAP release which changes just the patchlevel
        previous_patchlevel = int(patchlevel) - 1
        basetag = f"v{major}.{minor}.{previous_patchlevel}"
        # *include* PRs backported to current stable-4.X branch
        extra = f'label:"backport-to-{major}.{minor}-DONE"'

    print("Base tag is", basetag)

    startdate = get_tag_date(basetag)
    print("Base tag was created ", startdate)

    print("Downloading filtered PR list")
    prs = get_pr_list(startdate, extra)
    # print(json.dumps(prs, sort_keys=True, indent=4))

    changes_overview(prs, startdate, new_version)


if __name__ == "__main__":
    # the argument is the new version
    if len(sys.argv) != 2:
        usage(sys.argv[0])

    main(sys.argv[1])
