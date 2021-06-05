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

from utils import *

import subprocess

# Insist on Python >= 3.6 for f-strings and other goodies
if sys.version_info < (3,6):
    error("Python 3.6 or newer is required")

notice("Checking prerequisites")
verify_command_available("git")
verify_git_repo()
verify_git_clean()

# TODO: verify that we are on `master`, and that we are up-to-date (`git pull`)

# TODO: verify that `./configure && make` were already run


gapversion = "X.Y"
nextgapversion = "X.(Y+1)"  # TODO: compute this
stable_branch = "stable-" + gapversion # TODO: how to specify this? probably have the version as argument?

# TODO: error out if the branch already exists

# TODO: Create a pair of labels for GitHub issues called backport-to-X.Y and backport-to-X.Y-DONE.

# TODO: Create a GitHub milestone for GAP X.Y.0 release.

subprocess.run(["git", "branch", stable_branch], check=True)


notice("Updating configure.ac on master branch")
patchfile("configure.ac", r"m4_define\(\[gap_version\],[^\n]+", r"m4_define([gap_version], ["+nextgapversion+"dev])")

notice("Regenerate some files")
run_with_log(["make", "CITATION", "doc/versiondata"], "make")

notice("Commit master branch updates")
subprocess.run(["git", "commit", "-A", "-m", "Start work on GAP "+nextgapversion], check=True)

notice(f"Tag master with v{nextgapversion}")
subprocess.run(["git", "tag", "-m", "Start work on GAP "+nextgapversion, "v"+nextgapversion], check=True)

# TODO: push tags/commits? actually, we disabled direct pushes to
# master, so perhaps we should have created the above commit on a pull
# request, and create the tag only after it is merged?!? but then the
# sha changes ... so perhaps better is that an admin temporarily
# disables the branch protection rule so they can push
subprocess.run(["git", "push"], check=True)


notice(f"Updating {stable_branch} branch")
subprocess.run(["git", "checkout", stable_branch], check=True)

notice("Patching files")
patchfile("Makefile.rules", r"PKG_BRANCH = master", r"PKG_BRANCH = "+stable_branch)
patchfile("README.md", r"master", r""+stable_branch)
patchfile("configure.ac", r"m4_define\(\[gap_version\],[^\n]+", r"m4_define([gap_version], ["+gapversion+"dev])")

notice("Regenerate some files")
run_with_log(["make", "CITATION", "doc/versiondata"], "make")

notice(f"Create start commit for {stable_branch} branch")
subprocess.run(["git", "commit", "-A", "-m", f"Create {stable_branch} branch"], check=True)
