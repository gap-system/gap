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
##  This script is intended to implement step 7 of
##  <https://hackmd.io/AWds-AnZT72XXsbA0oVC6A>, i.e.:
##
##  7. Update the website

import argparse
import datetime
import gzip
import json
import os
import re
import requests
import shutil
import sys
import tarfile
import tempfile
import utils

if sys.version_info < (3,6):
    utils.error("Python 3.6 or newer is required")

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
description=
"""Update the GAP website from the GAP releases data on GitHub.

Run this script in the root of a clone of the GapWWW repository, \
checked out at the version from which you want to update \
(most likely the master branch of github.com/gap-system/GapWWW). \
The script modifies the working directory according to the information \
on GitHub.""",
epilog=
"""Notes:
* To learn how to create a GitHub access token, please consult \
  https://help.github.com/articles/creating-an-access-token-for-command-line-use
""")
group = parser.add_argument_group("Repository details and access")
group.add_argument("--token", type=str, help="GitHub access token")
group.add_argument("--gap-fork", type=str, default="gap-system",
        help="GitHub GAP fork to search for releases (for testing; default: gap-system)")
args = parser.parse_args()

utils.verify_command_available("git")
utils.verify_git_repo()
utils.verify_git_clean()

pwd = os.getcwd()
tmpdir = tempfile.gettempdir()


# Downloads the asset with name <asset_name> from the current GitHub release
# (global variable <release>, with assets <assets>) to <writedir>.
def download_asset_by_name(asset_name, writedir):
    try:
        url = [ x for x in assets if x.name == asset_name ][0].browser_download_url
    except:
        utils.error(f"Cannot find {asset_name} in the GitHub release with tag {release.tag_name}")

    with utils.working_directory(writedir):
        utils.notice(f"Downloading {url} to {writedir} . . .")
        utils.download_with_sha256(url, asset_name)

def extract_tarball(tarball):
    utils.notice(f"Extracting {tarball} . . .")
    with tarfile.open(tarball) as tar:
        try:
            tar.extractall()
        except:
            utils.error(f"Failed to extract {tarball}!")

def get_date_from_configure_ac(gaproot):
    with open(f"{gaproot}/configure.ac", "r") as configure_ac:
        filedata = configure_ac.read()
        try: # Expect date in YYYY-MM-DD format
            release_date = re.search("\[gap_releaseday\], \[(\d{4}-\d{2}-\d{2})\]", filedata).group(1)
            release_date = datetime.datetime.strptime(release_date, "%Y-%m-%d")
        except:
            utils.error("Cannot find the release date in configure.ac!")
    return release_date.strftime("%d %B %Y")

# This function deals with package-infos.json.gz and help-links.json.gz.
# The function downloads the release asset called <asset_name> to the tmpdir.
# The asset is assumed to be gzipped. It is extracted to the filepath <dest>.
def download_and_extract_json_gz_asset(asset_name, dest):
    download_asset_by_name(asset_name, tmpdir)
    with utils.working_directory(tmpdir):
        with gzip.open(asset_name, "rt", encoding="utf-8") as file_in:
            with open(dest, "w") as file_out:
                shutil.copyfileobj(file_in, file_out)


################################################################################
# Get all releases from 4.11.0 onwards, that are not a draft or prerelease
utils.CURRENT_REPO_NAME = f"{args.gap_fork}/gap"
utils.initialize_github(args.token)
utils.notice(f"Will use temporary directory: {tmpdir}")

releases = [ x for x in utils.CURRENT_REPO.get_releases() if
                not x.draft and
                not x.prerelease and
                utils.is_possible_gap_release_tag(x.tag_name) and
                (int(x.tag_name[1:].split('.')[0]) > 4 or
                    (int(x.tag_name[1:].split('.')[0]) == 4 and
                     int(x.tag_name[1:].split('.')[1]) >= 11)) ]
if releases:
    utils.notice(f"Found {len(releases)} published GAP releases >= v4.11.0")
else:
    utils.notice("Found no published GAP releases >= v4.11.0")
    sys.exit(0)

# Sort by version number, biggest to smallest
releases.sort(key=lambda s: list(map(int, s.tag_name[1:].split('.'))))
releases.reverse()


################################################################################
# For each release, extract the appropriate information
for release in releases:
    version = release.tag_name[1:]
    version_safe = version.replace(".", "-")  # Safe for the Jekyll website
    utils.notice(f"\nProcessing GAP {version}...")

    # Work out the relevance of this release
    known_release = os.path.isfile(f"_Releases/{version}.html")
    newest_release = releases.index(release) == 0
    if known_release:
        utils.notice(f"I have seen this release before")
    elif newest_release:
        utils.notice(f"This is a new release to me, and it has the biggest version number")
    else:
        utils.notice(f"This is a new release to me, but I know about releases with bigger version numbers")

    # For all releases, record the assets (in case they were deleted/updated/added)
    utils.notice(f"Collecting GitHub release asset data in _data/assets/{version_safe}.json")
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
            utils.error(f"Failed to download {asset.browser_download_url}.sha256")
        filtered_asset = {
            "bytes": asset.size,
            "name": asset.name,
            "sha256": sha256,
            "url": asset.browser_download_url,
        }
        asset_data.append(filtered_asset)
    asset_data.sort(key=lambda s: list(map(str, s['name'])))
    with open(f"{pwd}/_data/assets/{version_safe}.json", "wb") as file:
        file.write(json.dumps(asset_data, indent=2).encode("utf-8"))

    # For new-to-me relases create a file in _Releases/ and _data/package-infos/
    if not known_release:
        # When we find a previously unknown release, we extract the release date
        # from the configure.ac file contained in gap-{version}-core.tar.gz.
        # This date is set by the make_archives.py script.
        # First download gap-X.Y.Z-core.tar.gz, extract, and fetch the date.
        tarball = f"gap-{version}-core.tar.gz"
        download_asset_by_name(tarball, tmpdir)
        with utils.working_directory(tmpdir):
            extract_tarball(tarball)
        date = get_date_from_configure_ac(f"{tmpdir}/gap-{version}")
        utils.notice(f"Using release date {date} for GAP {version}")

        utils.notice(f"Writing the file _Releases/{version}.html")
        with open(f"{pwd}/_Releases/{version}.html", "w") as file:
            file.write(f"---\nversion: {version}\ndate: '{date}'\n---\n")

        utils.notice(f"Writing the file _data/package-infos/{version_safe}.json")
        download_and_extract_json_gz_asset("package-infos.json.gz", f"{pwd}/_data/package-infos/{version_safe}.json")

    # For a new-to-me release with biggest version number, also set this is the
    # 'default'/'main' version on the website (i.e. the most prominent release).
    # Therefore update _data/release.json, _data/help.json, and _Packages/.
    if not known_release and newest_release:
        utils.notice("Rewriting the _data/release.json file")
        release_data = {
            "version": version,
            "version-safe": version_safe,
            "date": date,
        }
        with open(f"{pwd}/_data/release.json", "wb") as file:
            file.write(json.dumps(release_data, indent=2).encode("utf-8"))

        utils.notice("Overwriting _data/help.json with the contents of help-links.json.gz")
        download_and_extract_json_gz_asset("help-links.json.gz", f"{pwd}/_data/help.json")

        utils.notice("Repopulating _Packages/ with one HTML file for each package in packages-info.json")
        shutil.rmtree("_Packages")
        os.mkdir("_Packages")
        with open(f"{pwd}/_data/package-infos/{version_safe}.json", "rb") as file:
            data = json.loads(file.read())
            for pkg in data:
                with open(f"{pwd}/_Packages/{pkg}.html", "w+") as pkg_file:
                    pkg_file.write(f"---\ntitle: {data[pkg]['PackageName']}\n---\n")
