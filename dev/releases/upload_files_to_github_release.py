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
##  This script is supposed to upload the files at <path_to_file1> [...] to
##  the GitHub release at utils.CURRENT_REPO with the tag <tag_name>.
##
##  It checks that each <path_to_file1> (etc) is a file, that <tag_name> is a
##  release, and that there are not already any files with the same name
##  attached to the release.
##
import os
import sys
import utils

if len(sys.argv) < 3:
    utils.error("usage: "+sys.argv[0]+" <tag_name> <path_to_file1> [...]")

TAG_NAME = sys.argv[1]
ASSETS = sys.argv[2:]

for ASSET in ASSETS:
    if not os.path.isfile(ASSET):
        utils.error(f"{ASSET} not found")

utils.verify_is_possible_gap_release_tag(TAG_NAME)
utils.initialize_github()

try:
    RELEASE = utils.CURRENT_REPO.get_release(TAG_NAME)
except:
    utils.error(f"{utils.CURRENT_REPO_NAME} contains no release {TAG_NAME}")

for ASSET in ASSETS:
    FILE = os.path.basename(ASSET)
    if any(FILE == x.name for x in RELEASE.get_assets()):
        utils.error(f"A file {FILE} already exists on the release {TAG_NAME}")

for ASSET in ASSETS:
    utils.upload_asset_with_checksum(RELEASE, ASSET)
