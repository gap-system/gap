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
            print(pr.number, pr.title)
            if pr.closed_at > datetime.fromisoformat(startdate):
                labs = [lab.name for lab in list(pr.get_labels())]
                if 'release notes: added' in labs:
                    prs[pr.number] = { "title" : pr.title, 
                                       "closed_at" : pr.closed_at.isoformat(), 
                                       "labels" : [lab for lab in labs if lab.startswith('kind') or lab.startswith('topic')] }
                    if len(prs)>10: # for quick testing
                        break
    return prs;

# TODO - print markdown to a file, on screen for now
def changes_overview(prs,startdate):
    print("--------------------------------------")
    print("## Changes since", startdate)
    for k in prs:
        print(k,prs[k]["title"], prs[k]["labels"] )
    print("--------------------------------------")

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
