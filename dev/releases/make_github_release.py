#!/usr/bin/env python3

# This script is intended to implement step 6 of
# <https://hackmd.io/AWds-AnZT72XXsbA0oVC6A>, i.e.
# it makes a github release and uploads all tar balls as assets.
# The name of the target repository CURRENT_REPO_NAME is defined in utils.py.

# If we do import * from utils, then initialize_github can't overwrite the
# global GITHUB_INSTANCE and CURRENT_REPO variables.
import utils
import github
import os
import sys
import re

if len(sys.argv) != 3:
    utils.error("usage: "+sys.argv[0]+" <tag_name> <path_to_release>")

utils.verify_git_clean()

TAG_NAME = sys.argv[1]
PATH_TO_RELEASE = sys.argv[2]

if re.fullmatch( r"v[1-9]+\.[0-9]+\.[0-9]+", TAG_NAME) == None:
    utils.error("This does not look like a release version")

# make sure that TAG_NAME
# - exists
# - is an annotated tag
# - points to current HEAD
utils.check_git_tag_for_release(TAG_NAME)

# Initialize GITHUB_INSTANCE and CURRENT_REPO
utils.initialize_github()

# Error if this release has been already created on GitHub
if any(r.tag_name == TAG_NAME for r in utils.CURRENT_REPO.get_releases()):
    utils.error(f"Github release with tag '{TAG_NAME}' already exists!")

# Create release
RELEASE_NOTE = f"For an overview of changes in GAP {TAG_NAME[1:]} see the " \
    + f"[CHANGES.md](https://github.com/gap-system/gap/blob/{TAG_NAME}/CHANGES.md) file."
utils.notice(f"Creating release {TAG_NAME}")
RELEASE = utils.CURRENT_REPO.create_git_release(TAG_NAME, TAG_NAME,
                                                RELEASE_NOTE,
                                                prerelease=True)

with utils.working_directory(PATH_TO_RELEASE):
    manifest_filename = "MANIFEST"
    with open(manifest_filename, 'r') as manifest_file:
        manifest = manifest_file.read().splitlines()
    # Now check that TAG_NAME and the created archives belong together
    main_archive_name = "gap-" + TAG_NAME[1:] + ".tar.gz"
    if not main_archive_name in manifest:
        error(f"Expected a file {main_archive_name} but it does not exist!")
    # Upload all assets to release
    try:
        for filename in manifest:
            utils.notice("Uploading " + filename)
            RELEASE.upload_asset(filename)
    except github.GithubException:
        utils.error("Error: The upload failed")
