#!/usr/bin/env python3

# This script is intended to implement step 6 of
# <https://hackmd.io/AWds-AnZT72XXsbA0oVC6A>, i.e.
# it makes a github release and uploads all tar balls as assets.
# The target repository is hardcoded in utils.py:
#   CURRENT_REPO_NAME
#
# As in make_tarball.py, the version of the gap release is taken from the
# Makefile variable GAP_BUILD_VERSION.

# If we do import * from utils, then initialize_github can't overwrite the
# global GITHUB_INSTANCE and CURRENT_REPO variables.
import utils
import github
import os

# Identify GAP release version
try:
    GAPVERSION = utils.get_makefile_var("GAP_BUILD_VERSION")
except:
    utils.error("Could not get GAP version")

utils.notice(f"Detected GAP version {GAPVERSION}")

utils.initialize_github()

# Error if this release has been already created on GitHub
if utils.check_whether_github_release_exists("v"+GAPVERSION):
    utils.error(f"Release v{GAPVERSION} already exists!")

# Create release
CURRENT_BRANCH = utils.get_makefile_var("PKG_BRANCH")
RELEASE_NOTE = f"For an overview of changes in GAP {GAPVERSION} see" \
    + "[CHANGES.md](https://github.com/gap-system/gap/blob/master/CHANGES.md) file."
utils.notice(f"Creating release v{GAPVERSION}")
RELEASE = utils.CURRENT_REPO.create_git_release("v"+GAPVERSION, "v"+GAPVERSION,
                                                RELEASE_NOTE,
                                                target_commitish=CURRENT_BRANCH,
                                                prerelease=True)

tmpdir = os.getcwd() + "/tmp"
with utils.working_directory(tmpdir):
    manifest_filename = "__manifest_make_tarball"
    with open(manifest_filename, 'r') as manifest_file:
        manifest = manifest_file.read().splitlines()
    # Upload all assets to release
    try:
        for filename in manifest:
            utils.notice("Uploading " + filename)
            RELEASE.upload_asset(filename)
    except github.GithubException:
        utils.error("Error: The upload failed")
