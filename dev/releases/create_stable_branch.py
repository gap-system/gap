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

# TODO: this is incomplete work in progress

# TODO: implement parts of the steps described in
# <https://github.com/gap-system/gap-distribution/blob/master/DistributionUpdate/STABLE_BRANCH_CHECKLIST.md>

import subprocess
import sys

import utils
from utils import error, notice, patchfile

# Insist on Python >= 3.6 for f-strings and other goodies
if sys.version_info < (3, 6):
    error("Python 3.6 or newer is required")


def usage(name: str) -> None:
    print(f"Usage: `{name} MINOR`  creates the branch `stable-4.MINOR`")
    sys.exit(1)


def main(gap_minor_version_str: str) -> None:
    gap_minor_version = int(gap_minor_version_str)
    gapversion = f"4.{gap_minor_version}"
    nextgapversion = f"4.{gap_minor_version+1}"
    stable_branch = "stable-" + gapversion

    notice("Checking prerequisites")
    utils.verify_command_available("git")
    utils.verify_git_repo()
    utils.verify_git_clean()

    notice("Switching to master branch")
    subprocess.run(["git", "switch", "master"], check=True)

    notice("Ensure branch is up-to-date")
    subprocess.run(["git", "pull", "--ff-only"], check=True)

    # create the new branch now, before we add a commit to master
    notice(f"Creating branch {stable_branch}")
    subprocess.run(["git", "branch", stable_branch], check=True)

    # list of files which (potentially) are updated
    files = [
        "CITATION",
        "configure.ac",
        "doc/versiondata",
    ]

    notice(f"Updating version to {nextgapversion} on master branch")
    for f in files:
        notice("  patching " + f)
        patchfile(f, gapversion + "dev", nextgapversion + "dev")

    notice("Commit master branch updates")
    subprocess.run(
        ["git", "commit", "-m", f"Start work on GAP {nextgapversion}", *files],
        check=True,
    )

    notice(f"Tag master with v{nextgapversion}dev")
    subprocess.run(
        [
            "git",
            "tag",
            "-m",
            f"Start work on GAP {nextgapversion}",
            f"v{nextgapversion}dev",
        ],
        check=True,
    )

    notice(f"Switching to {stable_branch} branch")
    subprocess.run(["git", "switch", stable_branch], check=True)

    notice("Patching files")
    patchfile("Makefile.rules", "PKG_BRANCH = master", "PKG_BRANCH = " + stable_branch)
    # adjust the CI and code coverage badges in README.md
    patchfile("README.md", "master", stable_branch)

    notice(f"Create start commit for {stable_branch} branch")
    files = [
        "Makefile.rules",
        "README.md",
    ]
    subprocess.run(
        ["git", "commit", "-m", f"Create {stable_branch} branch", *files], check=True
    )

    # push to the server
    input(
        f"Please 'git push origin master {stable_branch} v{nextgapversion}dev' now (you may have to temporarily change branch protection rules), then press ENTER"
    )

    input(
        f"Please create GitHub labels backport-to-{gapversion} and backport-to-{gapversion}-DONE, then press ENTER"
    )

    input(
        f"Please create a GitHub milestone for GAP {nextgapversion}.0 , then press ENTER"
    )


if __name__ == "__main__":
    # the argument is the new version
    if len(sys.argv) != 2:
        usage(sys.argv[0])

    main(sys.argv[1])
