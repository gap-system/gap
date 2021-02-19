#!/usr/bin/env python3
#
# Usage ./release-notes.py
#

import sys
from github import Github
from datetime import datetime

def get_prs(repo,startdate):
    prs = {}
    all_pulls = repo.get_pulls(state='closed', sort='created', direction='desc', base='master')
    for pr in all_pulls:
        if pr.merged:
            if pr.closed_at > datetime.fromisoformat(startdate):
                labs = [lab.name for lab in list(pr.get_labels())]
                prs[pr.number] = { "title" : pr.title,
                                    "closed_at" : pr.closed_at.isoformat(),
                                    "labels" : labs }
                # How long do we have to run this?
                if len(prs)>423: # for quick testing
                    break
    return prs;

# TODO - print markdown to a file, on screen for now
def changes_overview(prs,startdate):
    #print("--------------------------------------")
    #print("## Changes since", startdate)
    #for k in prs:
    #    print(k,prs[k]["title"], prs[k]["labels"] )
    #print("--------------------------------------")
    print("## Changes since", startdate)
    f = open("releasenotes.md", "a")
    f2 = open("remainingPR.md", "a")
    f3 = open("releasenotes.json", "a")
    jsondict = prs.copy()

    prioritylist = ["kind: bug: wrong result", "kind: bug: crash", "kind: bug: unexpected error", "kind: bug", "kind: enhancement", "kind: new feature", "kind: performance", "topic:libgap", "topic: julia", "topic: documentation", "topic: packages"]

    f.write("Release Notes \n\n\n\n")
    f.write("Category " + "release notes: highlight" + "\n")
    removelist = []
    for k in prs:
        # The format of an entry of list is: ['title of PR', 'Link' (Alternative the PR number can be used), [ list of labels ] ]
        if "release notes: highlight" in prs[k]["labels"]:
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
    with open('/Users/alexk/.github_shell_token', 'r') as f:
        accessToken=f.read().replace('\n', '')
    g=Github(accessToken)

    orgName = "gap-system"
    repoName = "gap"
    repo = g.get_repo( orgName + "/" + repoName)
    
    print("Current GitHub API capacity", g.rate_limiting)
    prs = get_prs(repo,startdate)
    changes_overview(prs,startdate)
    print("Remaining GitHub API capacity", g.rate_limiting)

    
if __name__ == "__main__":
    print("script name is", sys.argv[0])
    if (len(sys.argv) != 2): # the argument is the start date in ISO 8601
        usage()              # to be defined
       	sys.exit(0)          # exit with return value of 0
    main(sys.argv[1])
