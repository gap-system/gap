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
import json

def usage():
    print("Usage: `./generate_package_release_notes.py old-package-infos.json new-package-infos.json`")
    sys.exit(1)

def main(old_json_file, new_json_file):
    old_gap_version = "4.11.1" # TODO/FIXME: pass this as an argument?
    new_gap_version = "4.12.0" # TODO/FIXME: pass this as an argument?

    with open(old_json_file, "r") as f:
        old_json = json.load(f)

    with open(new_json_file, "r") as f:
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
            desc = pkg["Subtitle"]
            vers = pkg["Version"]
            authors = [x["FirstNames"]+" "+x["LastName"] for x in pkg["Persons"] if x["IsAuthor"]]
            authors = ", ".join(authors)
            print(f"- **{name}** {vers}: {desc}, by {authors}")
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

The GAP {new_gap_version} distribution contains {len(new_json)}
packages, of which {len(updated)} have been updated since GAP
{old_gap_version}. The full list of updated packages is given below:
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
    if len(sys.argv) != 3:
        usage()

    main(sys.argv[1], sys.argv[2])
