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

# Usage:
#     ./generate_package_release_notes.py old-package-infos.json new-package-infos.json
#
# TODO: allow specifying tags instead and download the json files from there
# TODO: "guess" the tag of the previous/old version so it can be completely omitted
# TODO: if the new package list is omitted, download the one from the PackageDistro?
# TODO: integrate this script into generate_release_notes.py

import sys
import os
import json
import gzip
import requests

from utils import *

def usage():
    print("Usage: `./generate_package_release_notes.py OLD_GAP_VERSION NEW_GAP_VERSION`")
    sys.exit(1)


def find_previous_version(version: str) -> str:
    major, minor, patchlevel = version.split(".")
    if major != "4":
        error("unexpected GAP version, not starting with '4.'")
    if patchlevel != "0":
        patchlevel = int(patchlevel) - 1
        return f"{major}.{minor}.{patchlevel}"
    minor = int(minor) - 1
    patchlevel = 0
    while True:
        v = f"{major}.{minor}.{patchlevel}"
        if not is_existing_tag("v" + v):
            break
        patchlevel += 1
    if patchlevel == 0:
        error("could not determine previous version")
    patchlevel -= 1
    return f"{major}.{minor}.{patchlevel}"

def package_infos_url(tag):
    return f"https://github.com/gap-system/PackageDistro/releases/download/{tag}/package-infos.json.gz"

def url_exists(url):
    response = requests.get(url)
    return response.status_code == 200


def main(new_gap_version):

    # create tmp directory
    tmpdir = os.getcwd() + "/tmp"
    notice(f"Files will be put in {tmpdir}")
    try:
        os.mkdir(tmpdir)
    except FileExistsError:
        pass

    old_gap_version = find_previous_version(new_gap_version)
    notice(f"generating package release notes for {old_gap_version} -> {new_gap_version}")

    oldtag = "v" + old_gap_version
    newtag = "v" + new_gap_version
    if not url_exists(package_infos_url(newtag)):
        warning("no package infos found for {newtag}, switching to latest")
        newtag = "latest"

    # download package metadata
    old_json_file = f"{tmpdir}/package-infos-{oldtag}.json.gz"
    new_json_file = f"{tmpdir}/package-infos-{newtag}.json.gz"

    download_with_sha256(package_infos_url(oldtag), old_json_file)
    download_with_sha256(package_infos_url(newtag), new_json_file)

    # parse package metadata
    with gzip.open(old_json_file, "r") as f:
        old_json = json.load(f)

    with gzip.open(new_json_file, "r") as f:
        new_json = json.load(f)

    print("### Package distribution")
    print()

    #
    # Detect new packages
    #
    added = new_json.keys() - old_json.keys()
    if len(added) > 0:
        print("#### New packages redistributed with GAP")
        print()
        for p in sorted(added):
            pkg = new_json[p]
            name = pkg["PackageName"]
            home = pkg["PackageWWWHome"]
            desc = pkg["Subtitle"]
            vers = pkg["Version"]
            authors = [x["FirstNames"]+" "+x["LastName"] for x in pkg["Persons"] if x["IsAuthor"]]
            authors = ", ".join(authors)
            print(f"- [**{name}**]({home}) {vers}: {desc}, by {authors}")
        print()

    #
    # Detect new packages
    #
    removed = old_json.keys() - new_json.keys()
    if len(removed) > 0:
        print("#### Packages no longer redistributed with GAP")
        print()
        for p in sorted(removed):
            name = old_json[p]["PackageName"]
            print(f"- **{name}**: TODO")
        print()

    #
    # Detect new packages
    #
    updated = new_json.keys() & old_json.keys()
    updated = [p for p in updated if old_json[p]["Version"] != new_json[p]["Version"]]
    if len(updated) > 0:
        print(f"""
#### Updated packages redistributed with GAP

The GAP {new_gap_version} distribution contains {len(new_json)} packages, of which {len(updated)} have been
updated since GAP {old_gap_version}. The full list of updated packages is given below:
""".lstrip())
        for p in sorted(updated):
            old = old_json[p]
            new = new_json[p]
            name = new["PackageName"]
            home = new["PackageWWWHome"]
            oldversion = old["Version"]
            newversion = new["Version"]
            print(f"- [**{name}**]({home}): {oldversion} -> {newversion}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        usage()

    main(sys.argv[1])
