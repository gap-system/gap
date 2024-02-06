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
##  This script makes a github release and uploads all tar balls as assets.
##  The name of the target repository CURRENT_REPO_NAME is defined in
##  utils.py.
##
##  If we do import * from utils, then initialize_github can't overwrite the
##  global CURRENT_REPO variables.
##
import sys

import utils
import utils_github
from utils import error, notice

if len(sys.argv) != 3:
    error("usage: " + sys.argv[0] + " <tag_name> <path_to_release>")

TAG_NAME = sys.argv[1]
PATH_TO_RELEASE = sys.argv[2]
VERSION = TAG_NAME[1:]  # strip 'v' prefix

utils.verify_git_clean()
utils.verify_is_possible_gap_release_tag(TAG_NAME)
utils_github.initialize_github()

# Error if the tag TAG_NAME hasn't been pushed to CURRENT_REPO yet.
if not any(tag.name == TAG_NAME for tag in utils_github.CURRENT_REPO.get_tags()):
    error(f"Repository {utils_github.CURRENT_REPO_NAME} has no tag '{TAG_NAME}'")

# make sure that TAG_NAME
# - exists
# - is an annotated tag
# - points to current HEAD
utils.check_git_tag_for_release(TAG_NAME)

# Error if this release has been already created on GitHub
if any(r.tag_name == TAG_NAME for r in utils_github.CURRENT_REPO.get_releases()):
    error(f"Github release with tag '{TAG_NAME}' already exists!")

# Create release
RELEASE_NOTE = (
    f"For an overview of changes in GAP {VERSION} see the "
    + f"[CHANGES.md](https://github.com/gap-system/gap/blob/{TAG_NAME}/CHANGES.md) file."
)
notice(f"Creating release {TAG_NAME}")
RELEASE = utils_github.CURRENT_REPO.create_git_release(
    TAG_NAME, TAG_NAME, RELEASE_NOTE, prerelease=True
)

with utils.working_directory(PATH_TO_RELEASE):
    manifest_filename = "MANIFEST"
    with open(manifest_filename, "r") as manifest_file:
        manifest = manifest_file.read().splitlines()

    notice(f"Contents of {manifest_filename}:")
    for filename in manifest:
        print(filename)

    # Now check that TAG_NAME and the created archives belong together
    main_archive_name = "gap-" + VERSION + ".tar.gz"
    if not main_archive_name in manifest:
        error(f"Expected to find {main_archive_name} in MANIFEST, but did not!")

    # Upload all assets to release
    notice("Uploading release assets")
    for filename in manifest:
        utils_github.upload_asset_with_checksum(RELEASE, filename)
