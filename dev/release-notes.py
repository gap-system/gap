#!/usr/bin/env python3
#
# Usage ./release-notes.py YYYY-MM-DD
#

import sys
import json
import os.path
from github import Github
from datetime import datetime


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

    prioritylist = ["kind: bug: wrong result", 
                    "kind: bug: crash", 
                    "kind: bug: unexpected error", 
                    "kind: bug", "kind: enhancement", 
                    "kind: new feature", 
                    "kind: performance", 
                    "topic:libgap", 
                    "topic: julia", 
                    "topic: documentation", 
                    "topic: packages"]

    f.write("Release Notes \n\n\n\n")
    f.write("Category " + "release notes: highlight" + "\n")
    removelist = []
    for k in prs:
        # The format of an entry of list is: ["title of PR", "Link" (Alternative the PR number can be used), [ list of labels ] ]
        if "release notes: highlight" in prs[k]["labels"]:
            # TODO: writing up these details should be a function
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
    f.write("\n\n\n")


    removelist = []
    for k in prs:
        if "release notes: not needed" in prs[k]["labels"]:
            removelist.append(k)
    for item in removelist:
        del prs[item]
        del jsondict[item]


    f2.write("Category " + "release notes: to be added" + "\n")
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
    f2.write("\n\n\n")


    f2.write("Uncategorized PR" + "\n")
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
        f.write("Category " + priorityobject + "\n")
        removelist = []
        for k in prs:
            if priorityobject in prs[k]["labels"]:
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
        f.write("\n\n\n")
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
    
    print("Current GitHub API capacity", g.rate_limiting)
    # TODO: also print timestamp

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
    print("Remaining GitHub API capacity", g.rate_limiting)
    # TODO: also print timestamp
    
if __name__ == "__main__":
    print("script name is", sys.argv[0])
    if (len(sys.argv) != 2): # the argument is the start date in ISO 8601
        usage()              # to be defined
       	sys.exit(0)          # exit with return value of 0
    main(sys.argv[1])
