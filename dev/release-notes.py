#!/usr/bin/env python3
#
# Usage: ./release-notes.py YYYY-MM-DD
# 
# Input:
# A start date in the format YYYY-MM-DD. If one is in the folder of "release-notes.py", it can then be called using: python release-notes.py YYYY-MM-DD
#
# Output and description: 
# This script is used to automatically generate the release notes based on the associated labels of pull requests 
# that have been merged with the master branch since "startdate". 
# This script gets the title, the PR number and the labels and categorizes them based on the priority list and discussion from #4257.
# In addition, a file is generated of PR that could not be categorized and a file for the browse function by Thomas Breuer (see #4257).

import sys
import json
import os.path
from github import Github
from datetime import datetime

def usage():
    print("Usage: ./release-notes.py YYYY-MM-DD")

def get_prs(repo,startdate):
    """Retrieves data for PRs matching selection criteria and puts them in a dictionary,
       which is then saved in a json file, and also returned for immediate use."""
    prs = {}
    all_pulls = repo.get_pulls(state="closed", sort="created", direction="desc", base="master")
    # We need to run this over the whole list of PRs. Sorting by creation date descending
    # is not really helping - could be that some very old PRs are being merged.
    for pr in all_pulls:
        print(pr.number, end=" ")
        # flush stdout immediately, to see progress indicator
        sys.stdout.flush()
        if pr.merged:
            if pr.closed_at > datetime.fromisoformat(startdate):
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

def changes_overview(prs,startdate):
    """Writes files with information for release notes."""

    #TODO: using cached data, check that the starting date is the same
    # Also save the date when cache was saved (warning if old?)
    print("## Changes since", startdate)

    # Opening files with "w" resets them
    f = open("releasenotes.md", "w")
    f2 = open("remainingPR.md", "w")
    f3 = open("releasenotes.json", "w")
    jsondict = prs.copy()

    # the following is a list of pairs [LABEL, DESCRIPTION]; the first entry is the name of a GitHub label
    # (be careful to match them precisely), the second is a headline for a section the release notes; any PR with
    # the given label is put into the corresponding section; each PR is put into only one section, the first one
    # one from this list it fits in.
    # See also <https://github.com/gap-system/gap/issues/4257>.
    prioritylist = [
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

    # TODO: why does this need a special treatment? 
    # Adding it to the prioritylist could ensure that it goes first
    f.write("## Release Notes \n\n")
    f.write("### " + "New features and major changes" + "\n")
    removelist = []
    for k in prs:
        # The format of an entry of list is: ["title of PR", "Link" (Alternative the PR number can be used), [ list of labels ] ]
        if "release notes: highlight" in prs[k]["labels"]:
            # TODO: writing up these details should be a function
            title = prs[k]["title"]
            f.write(f"- [#{k}](https://github.com/gap-system/gap/pull/{k}) {title}\n")
            removelist.append(k)
    for item in removelist:
        del prs[item]
    f.write("\n")


    removelist = []
    for k in prs:
        if "release notes: not needed" in prs[k]["labels"]:
            removelist.append(k)
    for item in removelist:
        del prs[item]
        del jsondict[item]


    f2.write("### " + "release notes: to be added" + "\n")
    removelist = []
    for k in prs:
        if "release notes: to be added" in prs[k]["labels"]:
            f2.write("- [#")
            issuenumber = str(k)
            f2.write(issuenumber)
            f2.write("](")
            f2.write("https://github.com/gap-system/gap/pull/" + str(k))
            f2.write(") ")
            f2.write(prs[k]["title"])
            f2.write("\n")
            removelist.append(k)
    for item in removelist:
        del prs[item]
    f2.write("\n")


    f2.write("### Uncategorized PR" + "\n")
    removelist = []
    for k in prs:
        #if not "release notes: use title" in item[2]:
        if not "release notes: added" in prs[k]["labels"]:
            f2.write("- [#")
            issuenumber = str(k)
            f2.write(issuenumber)
            f2.write("](")
            f2.write("https://github.com/gap-system/gap/pull/" + str(k))
            f2.write(") ")
            f2.write(prs[k]["title"])
            f2.write("\n")
            removelist.append(k)
    for item in removelist:
        del prs[item]
    f2.close()
    

    for priorityobject in prioritylist:
        f.write("### " + priorityobject[1] + "\n")
        removelist = []
        for k in prs:
            if priorityobject[0] in prs[k]["labels"]:
                f.write("- [#")
                issuenumber = str(k)
                f.write(issuenumber)
                f.write("](")
                f.write("https://github.com/gap-system/gap/pull/" + str(k))
                f.write(") ")
                f.write(prs[k]["title"])
                f.write("\n")
                removelist.append(k)
        for item in removelist:
            del prs[item]
        f.write("\n")
    f.close()

    f3.write("[")
    jsonlist = []
    for k in jsondict:
        temp = []
        temp.append(str(jsondict[k]["title"]))
        temp.append(str(k))
        temp.append(jsondict[k]["labels"])
        jsonlist.append(temp)
    for item in jsonlist:
        f3.write("%s\n" % item)
    f3.write("]")
    f3.close

def main(startdate):

    # Authentication and checking current API capacity
    # TODO: for now this will do, use Sergio's code later
    with open("/Users/alexk/.github_shell_token", "r") as f:
        accessToken=f.read().replace("\n", "")
    g=Github(accessToken)

    orgName = "gap-system"
    repoName = "gap"
    repo = g.get_repo( orgName + "/" + repoName)
    
    # There is a GitHub API capacity of 5000 per hour i.e. that a maximum of 5000 requests can be made to GitHub per hour.
    # Therefore, the following line indicates how many requests are currently still available
    print("Current GitHub API capacity", g.rate_limiting, "at", datetime.now().isoformat() )

    # TODO: we cache PRs data in a local file. For now, if it exists, it will be used, 
    # otherwise it will be recreated. Later, there may be an option to use the cache or 
    # to enforce retrieving updated PR details from Github. I think default is to update 
    # from GitHub (to get newly merged PRs, updates of labels, PR titles etc., while the
    # cache could be used for testing and polishing the code to generate output )

    if os.path.isfile("prscache.json"):
        print("Using cached data from prscache.json ...")
        with open("prscache.json", "r") as read_file:
            prs = json.load(read_file)
    else:    
        print("Retriving data using GitHub API ...")
        prs = get_prs(repo,startdate)
  
    changes_overview(prs,startdate)
    print("Remaining GitHub API capacity", g.rate_limiting, "at", datetime.now().isoformat() )
    
if __name__ == "__main__":
    if len(sys.argv) != 2: # the argument is the start date in ISO 8601
        usage()
       	sys.exit(0)

    try:
        datetime.fromisoformat(sys.argv[1])
        
    except:
        print("The date is not in ISO8601 format!")
        usage()
       	sys.exit(0)

    main(sys.argv[1])
