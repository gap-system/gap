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
##  This script makes a github release and uploads all tarballs as assets.
##
import re
import subprocess
import sys

import utils
import utils_github
from utils import error, notice

if len(sys.argv) != 3:
    error("usage: " + sys.argv[0] + " <tag_name> <path_to_release>")


def is_possible_gap_release_tag(tag: str) -> bool:
    return re.fullmatch(r"v[1-9]+\.[0-9]+\.[0-9]+(-.+)?", tag) is not None


def verify_is_possible_gap_release_tag(tag: str) -> None:
    if not is_possible_gap_release_tag(tag):
        error(f"{tag} does not look like the tag of a GAP release version")


# lightweight vs annotated
# https://stackoverflow.com/questions/40479712/how-can-i-tell-if-a-given-git-tag-is-annotated-or-lightweight#40499437
def is_annotated_git_tag(tag: str) -> bool:
    res = subprocess.run(
        ["git", "for-each-ref", "refs/tags/" + tag],
        capture_output=True,
        text=True,
        check=False,
    )
    return res.returncode == 0 and res.stdout.split()[1] == "tag"


def check_git_tag_for_release(tag: str) -> None:
    if not is_annotated_git_tag(tag):
        error(f"There is no annotated tag {tag}")
    # check that tag points to HEAD
    tag_commit = subprocess.run(
        ["git", "rev-parse", tag + "^{}"], check=True, capture_output=True, text=True
    ).stdout.strip()
    head = subprocess.run(
        ["git", "rev-parse", "HEAD"], check=True, capture_output=True, text=True
    ).stdout.strip()
    if tag_commit != head:
        error(
            f"The tag {tag} does not point to the current commit {head} but"
            + f" instead points to {tag_commit}"
        )


TAG_NAME = sys.argv[1]
PATH_TO_RELEASE = sys.argv[2]
VERSION = TAG_NAME[1:]  # strip 'v' prefix

utils.verify_git_clean()
verify_is_possible_gap_release_tag(TAG_NAME)
repo = utils_github.initialize_github()

# Error if the tag TAG_NAME hasn't been pushed out yet.
if not any(tag.name == TAG_NAME for tag in repo.get_tags()):
    error(f"Repository {repo.full_name} has no tag '{TAG_NAME}'")

# make sure that TAG_NAME
# - exists
# - is an annotated tag
# - points to current HEAD
check_git_tag_for_release(TAG_NAME)

# Error if this release has been already created on GitHub
if any(r.tag_name == TAG_NAME for r in repo.get_releases()):
    error(f"Github release with tag '{TAG_NAME}' already exists!")

# Create release
RELEASE_NOTE = (
    f"For an overview of changes in GAP {VERSION} see the "
    + f"[CHANGES.md](https://github.com/gap-system/gap/blob/{TAG_NAME}/CHANGES.md) file."
)
notice(f"Creating release {TAG_NAME}")
RELEASE = repo.create_git_release(TAG_NAME, TAG_NAME, RELEASE_NOTE, prerelease=True)

with utils.working_directory(PATH_TO_RELEASE):
    manifest_filename = "MANIFEST"
    with open(manifest_filename, "r", encoding="utf-8") as manifest_file:
        manifest = manifest_file.read().splitlines()

    notice(f"Contents of {manifest_filename}:")
    for filename in manifest:
        print(filename)

    # Now check that TAG_NAME and the created archives belong together
    main_archive_name = "gap-" + VERSION + ".tar.gz"
    if main_archive_name not in manifest:
        error(f"Expected to find {main_archive_name} in MANIFEST, but did not!")

    # Upload all assets to release
    notice("Uploading release assets")
    for filename in manifest:
        utils_github.upload_asset_with_checksum(RELEASE, filename)
