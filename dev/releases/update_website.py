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
##
##  This script updates the website when there is a new GAP release.
##  It is to be run from inside a clone of the gap-system/GapWWW repository.

import argparse
import datetime
import gzip
import json
import os
import re
import shutil
import sys
import tarfile
import tempfile

import github
import requests
import utils
from utils import error, notice

if sys.version_info < (3, 6):
    error("Python 3.6 or newer is required")

parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
    description="""Update the GAP website from the GAP releases data on GitHub.

Run this script in the root of a clone of the GapWWW repository, \
checked out at the version from which you want to update \
(most likely the master branch of github.com/gap-system/GapWWW). \
The script modifies the working directory according to the information \
on GitHub.""",
)
group = parser.add_argument_group("Repository details and access")
group.add_argument(
    "--gap-fork",
    type=str,
    default="gap-system",
    help="GitHub GAP fork to search for releases (for testing; default: gap-system)",
)
args = parser.parse_args()

utils.verify_command_available("git")
utils.verify_git_repo()
utils.verify_git_clean()

pwd = os.getcwd()
tmpdir = tempfile.gettempdir()


# Downloads the asset with name <asset_name> from the current GitHub release
# (global variable <release>, with assets <assets>) to <writedir>.
def download_asset_by_name(asset_name: str, writedir: str) -> None:
    global assets
    try:
        url = [x for x in assets if x.name == asset_name][0].browser_download_url
    except:
        error(
            f"Cannot find {asset_name} in the GitHub release with tag {release.tag_name}"
        )

    with utils.working_directory(writedir):
        notice(f"Downloading {url} to {writedir} . . .")
        utils.download_with_sha256(url, asset_name)


def extract_tarball(tball: str) -> None:
    notice(f"Extracting {tball} . . .")
    with tarfile.open(tball) as tar:
        try:
            tar.extractall()
        except:
            error(f"Failed to extract {tball}!")


def get_date_from_configure_ac(gaproot: str) -> str:
    with open(f"{gaproot}/configure.ac", "r", encoding="utf-8") as configure_ac:
        filedata = configure_ac.read()
        try:  # Expect date in YYYY-MM-DD format
            release_date = re.search(
                r"\[gap_releaseday\], \[(\d{4}-\d{2}-\d{2})\]", filedata
            ).group(1)
            release_date = datetime.datetime.strptime(release_date, "%Y-%m-%d")
            return release_date.strftime("%d %B %Y")
        except:
            error("Cannot find the release date in configure.ac!")


# This function deals with package-infos.json.gz and help-links.json.gz.
# The function downloads the release asset called <asset_name> to the tmpdir.
# The asset is assumed to be gzipped. It is extracted to the filepath <dest>.
def download_and_extract_json_gz_asset(asset_name: str, dest: str) -> None:
    download_asset_by_name(asset_name, tmpdir)
    with utils.working_directory(tmpdir):
        with gzip.open(asset_name, "rt", encoding="utf-8") as file_in:
            with open(dest, "w", encoding="utf-8") as file_out:
                shutil.copyfileobj(file_in, file_out)


################################################################################
# Get latest GAP release
notice(f"Will use temporary directory: {tmpdir}")

g = github.Github()  # no token required as we just read a little data
repo = g.get_repo(f"{args.gap_fork}/gap")
release = repo.get_latest_release()

notice(f"Latest GAP release is {release.title} at tag {release.tag_name}")
if release.tag_name[0] != "v":
    error("Tag name has unexpected format")
version = release.tag_name[1:]


# Determine which version is currently in GapWWW
with open("_data/release.json", "r", encoding="utf-8") as f:
    release_json = json.load(f)
www_release = release_json["version"]

notice(f"GAP release in GapWWW is {www_release}")

# TODO: abort if identical or even older


# For all releases, record the assets (in case they were deleted/updated/added)
notice(f"Collecting GitHub release asset data in _data/assets.json")
assets = release.get_assets()
asset_data = []
for asset in assets:
    if asset.name.endswith(".sha256") or asset.name.endswith(".json.gz"):
        continue
    request = requests.get(f"{asset.browser_download_url}.sha256")
    try:
        request.raise_for_status()
        sha256 = request.text.strip()
    except:
        error(f"Failed to download {asset.browser_download_url}.sha256")
    filtered_asset = {
        "bytes": asset.size,
        "name": asset.name,
        "sha256": sha256,
        "url": asset.browser_download_url,
    }
    asset_data.append(filtered_asset)
asset_data.sort(key=lambda s: list(map(str, s["name"])))
with open(f"{pwd}/_data/assets.json", "wb") as outfile:
    outfile.write(json.dumps(asset_data, indent=2).encode("utf-8"))

# Extract the release date from the configure.ac file contained in
# gap-{version}-core.tar.gz.
# This date is set by the make_archives.py script.
# First download gap-X.Y.Z-core.tar.gz, extract, and fetch the date.
tarball = f"gap-{version}-core.tar.gz"
download_asset_by_name(tarball, tmpdir)
with utils.working_directory(tmpdir):
    extract_tarball(tarball)
date = get_date_from_configure_ac(f"{tmpdir}/gap-{version}")
notice(f"Using release date {date} for GAP {version}")

notice(f"Writing the file assets/package-infos.json")
download_and_extract_json_gz_asset(
    "package-infos.json.gz", f"{pwd}/assets/package-infos.json"
)

notice("Rewriting the _data/release.json file")
release_data = {
    "version": version,
    "date": date,
}
with open(f"{pwd}/_data/release.json", "wb") as outfile:
    outfile.write(json.dumps(release_data, indent=2).encode("utf-8"))

notice("Overwriting _data/help.json with the contents of help-links.json.gz")
download_and_extract_json_gz_asset("help-links.json.gz", f"{pwd}/_data/help.json")
