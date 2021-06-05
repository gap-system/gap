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
##  This script is supposed to download the release asset with name <asset> to
##  the directory <download_dir> from the GitHub release at utils.CURRENT_REPO
##  with the tag <tag_name>.
##  
##  It checks that <download_dir> exists, that <tag_name> is a release, and
##  that <asset> is the name of a file attached to the release.
##
import os
import sys
import utils

if len(sys.argv) != 4:
    utils.error("usage: "+sys.argv[0]+" <tag_name> <asset> <download_dir>")

TAG_NAME = sys.argv[1]
ASSET = sys.argv[2]
DOWNLOAD_DIR = sys.argv[3]

if not os.path.isdir(DOWNLOAD_DIR):
    utils.error(f"{DOWNLOAD_DIR} seems not to be a directory")
utils.verify_is_possible_gap_release_tag(TAG_NAME)
utils.initialize_github()

try:
    RELEASE = utils.CURRENT_REPO.get_release(TAG_NAME)
except:
    utils.error(f"{utils.CURRENT_REPO_NAME} contains no release {TAG_NAME}")

assets = [ x for x in RELEASE.get_assets() if ASSET == x.name ]
if len(assets) != 1:
    utils.error(f"No unique file {FILE} exists on the release {TAG_NAME}")

utils.download_with_sha256(assets[0].browser_download_url, os.path.realpath(DOWNLOAD_DIR) + "/" + ASSET)
