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
#     ./generate_release_notes.py minor
# or
#     ./generate_release_notes.py major
# 
# to specify the type of the release.
#
# Output and description: 
# This script is used to automatically generate the release notes based on the labels of
# pull requests that have been merged into the master branch since the starting date
# specified in the `history_start_date` variable below.
#
# For each such pull request (PR), this script extracts from GitHub its title, number and
# labels, using the GitHub API via the PyGithub package (https://github.com/PyGithub/PyGithub).
# To help to track the progress, it will output the number of the currently processed PR.
# For API requests using Basic Authentication or OAuth, you can make up to 5,000 requests
# per hour (https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting).
# As of March 2021 this script consumes about 3400 API calls and runs for about 25 minutes.
# This is why, to reduce the number of API calls and minimise the need to retrieve the data,
# PR details will be stored in the file `prscache.json`, which will then be used to
# categorise PR following the priority list and discussion from #4257, and output three
# files:
# - "releasenotes_*.md"   : list of PR by categories for adding to release notes
# - "unsorted_PRs_*.md"    : list of PR that could not be categorised
# - "releasenotes_*.json" : data for `BrowseReleaseNotes` function by Thomas Breuer (see #4257).
# where "*" is "minor" or "major" depending on the type of the release.
#
# If this script detects the file `prscache.json` it will use it, otherwise it will retrieve
# new data from GitHub. Thus, if new PR were merged, or there were updates of titles and labels
# of merged PRs, you need to delete `prscache.json` to enforce updating local data (TODO: make
# this turned on/off via a command line option in the next version).
#
# To find out when a branch was created, use e.g.
#     git show --summary `git merge-base stable-4.11 master`
#

import sys
import json
import os.path
from github import Github
from datetime import datetime
import utils


#############################################################################
#
# Configuration parameters
#
# the earliest date we need to track for the next minor/major releases
history_start_date = "2019-09-09"

# the date of the last minor release (later, we may need to have more precise timestamp
# - maybe extracted from the corresponding release tag)
minor_branch_start_date = "2021-03-03" # next day after the minor release (starts at midnight)
# question: what if it was merged into master before 4.11.1, but backported after?
# Hopefully, before publishing 4.11.1 we have backported everything that had to be
# backported, so this was not the case.

# this version number needed to form labels like "backport-to-4.11-DONE"
minor_branch_version = "4.11"

# not yet - will make sense after branching the `stable-4.12` branch:
# major_branch_start_date = "2019-09-09"
# major_branch_version = "4.12"
# note that we will have to collate together PRs which are not backported to stable-4.11
# between `history_start_date` and `major_branch_start_date`, and PRs backported to
# stable-4.12 after `major_branch_start_date`
#
#############################################################################

def usage():
    print("Usage: `./release-notes.py minor` or `./release-notes.py major`")
    sys.exit(1)


def get_prs(repo,startdate):
    """Retrieves data for PRs matching selection criteria and puts them in a dictionary,
       which is then saved in a json file, and also returned for immediate use."""
    # The output `prs` is a dictionary with keys being PR numbers, and values being
    # dictionaries with keys "title", "closed_at" and "labels", for example:
    #
    # "3355": {
    #     "title": "Allow packages to use ISO 8601 dates in their PackageInfo.g",
    #     "closed_at": "2021-02-20T15:44:48",
    #     "labels": [
    #         "gapdays2019-spring",
    #         "gapsingular2019",
    #         "kind: enhancement",
    #         "release notes: to be added"
    #     ]
    # },
  
    prs = {}
    all_pulls = repo.get_pulls(state="closed", sort="created", direction="desc", base="master")
    # We need to run this over the whole list of PRs. Sorting by creation date descending
    # is not really helping - could be that some very old PRs are being merged.
    for pr in all_pulls:
        print(pr.number, end=" ")
        # flush stdout immediately, to see progress indicator
        sys.stdout.flush()
        if pr.merged:
            if pr.closed_at > datetime.fromisoformat(history_start_date):
                # getting labels will cost further API calls - if the startdate is
                # too far in the past, that may exceed the API capacity
                labs = [lab.name for lab in list(pr.get_labels())]
                prs[pr.number] = { "title" : pr.title,
                                    "closed_at" : pr.closed_at.isoformat(),
                                    "labels" : labs }
#                 if len(prs)>5: # for quick testing (maybe later have an optional argument)
#                     break
    print("\n")
    with open("prscache.json", "w", encoding="utf-8") as f:
        json.dump(prs, f, ensure_ascii=False, indent=4)
    return prs    


def filter_prs(prs,rel_type):
    newprs = {}

    if rel_type == "minor":

        # For minor release, list PRs backported to the stable-4.X brach since the previous minor release.
        for k,v in sorted(prs.items()):
            if "backport-to-" + minor_branch_version + "-DONE" in v["labels"]:
                if datetime.fromisoformat(v["closed_at"]) > datetime.fromisoformat(minor_branch_start_date):
                    newprs[k] = v
        return newprs

    elif rel_type == "major":

        # For major release, list PRs not backported to the stable-4.X brach.
        # After branching stable-4.12 this will have to be changed to stop checking
        # for "backport-to-4.11-DONE" at the date of the branching, and check for
        # "backport-to-4.12-DONE" after that date
        for k,v in sorted(prs.items()):
            if not "backport-to-" + minor_branch_version + "-DONE" in v["labels"]:
                newprs[k] = v
        return newprs

    else:

        usage()


def pr_to_md(k, title):
    """Returns markdown string for the PR entry"""
    return f"- [#{k}](https://github.com/gap-system/gap/pull/{k}) {title}\n"


def changes_overview(prs,startdate,rel_type):
    """Writes files with information for release notes."""

    # Opening files with "w" resets them
    relnotes_file = open("releasenotes_" + rel_type + ".md", "w")
    unsorted_file = open("unsorted_PRs_" + rel_type + ".md", "w")
    relnotes_json = open("releasenotes_" + rel_type + ".json", "w")
    jsondict = prs.copy()

    # the following is a list of pairs [LABEL, DESCRIPTION]; the first entry is the name of a GitHub label
    # (be careful to match them precisely), the second is a headline for a section the release notes; any PR with
    # the given label is put into the corresponding section; each PR is put into only one section, the first one
    # one from this list it fits in.
    # See also <https://github.com/gap-system/gap/issues/4257>.
    prioritylist = [
        ["release notes: highlight", "New features and major changes"],
        ["kind: bug: wrong result", "Fixed bugs that could lead to incorrect results"],
        ["kind: bug: crash", "Fixed bugs that could lead to crashes"],
        ["kind: bug: unexpected error", "Fixed bugs that could lead to break loops"],
        ["kind: bug", "Other fixed bugs"],
        ["kind: enhancement", "Improved and extended functionality"],
        ["kind: new feature", "New features"], 
        ["kind: performance", "Performance improvements"],
        ["topic: libgap", "Improvements to the interface which allows 3rd party code to link GAP as a library"],
        ["topic: julia", "Improvements in the support for using the **Julia** garbage collector"],
        ["topic: documentation", "Changed documentation"],
        ["topic: packages", "Packages"]
    ]

    # Could also introduce some consistency checks here for wrong combinations of labels

    # Drop PRs not needed for release notes
    removelist = []
    for k in prs:
        if "release notes: not needed" in prs[k]["labels"]:
            removelist.append(k)
    for item in removelist:
        del prs[item]
        del jsondict[item]

    # Report PRs that have to be updated before inclusion into release notes.
    unsorted_file.write("### " + "release notes: to be added" + "\n\n")
    unsorted_file.write("If there are any PRs listed below, check their title and labels.\n")
    unsorted_file.write("When done, change their label to \"release notes: use title\".\n\n")
    removelist = []
    for k in prs:
        if "release notes: to be added" in prs[k]["labels"]:
            unsorted_file.write(pr_to_md(k, prs[k]["title"]))
            removelist.append(k)
    for item in removelist:
        del prs[item]
    unsorted_file.write("\n")

    # Report PRs that have neither "to be added" nor "added" or "use title" label
    unsorted_file.write("### Uncategorized PR" + "\n\n")
    unsorted_file.write("If there are any PRs listed below, either apply the same steps\n")
    unsorted_file.write("as above, or change their label to \"release notes: not needed\".\n\n")
    removelist = []
    for k in prs:
        # we need to use both old "release notes: added" label and
        # the newly introduced in "release notes: use title" label
        # since both label may appear in GAP 4.12.0 changes overview
        if not ("release notes: added" in prs[k]["labels"] or "release notes: use title" in prs[k]["labels"]):
            unsorted_file.write(pr_to_md(k, prs[k]["title"]))
            removelist.append(k)
    for item in removelist:
        del prs[item]
    unsorted_file.close()

    # All remaining PRs are to be included in the release notes

    relnotes_file.write("## Release Notes \n\n")

    for priorityobject in prioritylist:
        relnotes_file.write("### " + priorityobject[1] + "\n\n")
        removelist = []
        for k in prs:
            if priorityobject[0] in prs[k]["labels"]:
                relnotes_file.write(pr_to_md(k, prs[k]["title"]))
                removelist.append(k)
        for item in removelist:
            del prs[item]
        relnotes_file.write("\n")

    # The remaining PRs have no "kind" or "topic" label from the priority list
    # (may have other "kind" or "topic" label outside the priority list).
    # Check their list in the release notes, and adjust labels if appropriate.
    relnotes_file.write("### Other changes \n\n")
    for k in prs:
        relnotes_file.write(pr_to_md(k, prs[k]["title"]))
    relnotes_file.write("\n")
    relnotes_file.close()

    relnotes_json.write("[")
    jsonlist = []
    for k in jsondict:
        temp = []
        temp.append(str(jsondict[k]["title"]))
        temp.append(str(k))
        temp.append(jsondict[k]["labels"])
        jsonlist.append(temp)
    for item in jsonlist:
        relnotes_json.write("%s\n" % item)
    relnotes_json.write("]")
    relnotes_json.close


def main(rel_type):

    utils.initialize_github()
    g = utils.GITHUB_INSTANCE
    repo = utils.CURRENT_REPO
    
    # There is a GitHub API capacity of 5000 per hour i.e. that a maximum of 5000 requests can be made to GitHub per hour.
    # Therefore, the following line indicates how many requests are currently still available
    print("Current GitHub API capacity", g.rate_limiting, "at", datetime.now().isoformat() )

    # If this limit is exceeded, an exception will be raised:
    # github.GithubException.RateLimitExceededException: 403
    # {"message": "API rate limit exceeded for user ID XXX.", "documentation_url":
    # "https://docs.github.com/rest/overview/resources-in-the-rest-api#rate-limiting"}


    # TODO: we cache PRs data in a local file. For now, if it exists, it will be used, 
    # otherwise it will be recreated. Later, there may be an option to use the cache or 
    # to enforce retrieving updated PR details from Github. I think default is to update 
    # from GitHub (to get newly merged PRs, updates of labels, PR titles etc., while the
    # cache could be used for testing and polishing the code to generate output )

    # TODO: add some data to the cache, e.g. when the cache is saved.
    # Produce warning if old.

    if os.path.isfile("prscache.json"):
        print("Using cached data from prscache.json ...")
        with open("prscache.json", "r") as read_file:
            prs = json.load(read_file)
    else:    
        print("Retrieving data using GitHub API ...")
        prs = get_prs(repo,history_start_date)
  
    prs = filter_prs(prs,rel_type)
    changes_overview(prs,history_start_date,rel_type)
    print("Remaining GitHub API capacity", g.rate_limiting, "at", datetime.now().isoformat() )

    
if __name__ == "__main__":
    # the argument is "minor" or "major" to specify release kind
    if len(sys.argv) != 2 or not sys.argv[1] in ["minor","major"]:
        usage()

    main(sys.argv[1])
