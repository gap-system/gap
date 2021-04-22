#!/usr/bin/env python3
#
# Usage:
#     ./package_status.py
# or
#     ./package_status.py pkg-name
# or
#     ./package_status.py account/pkg-name
# 

import sys
import json
import os.path
from github import Github
from datetime import datetime
import utils


def usage():
    print("""Usage:
        ./package_status.py
    or
        ./package_status.py pkg-name
    or
        ./package_status.py account/pkg-name""")
    sys.exit(1)


def package_report(repo):

    # could be a string or a repo object
    if type(repo)==str:
         repo = g.get_repo("gap-packages/"+repo)

    print("#", repo.name)

    # report lates release
    nr_releases = repo.get_releases().totalCount
    if nr_releases > 0:
        latest_release = repo.get_latest_release()
        print("Latest release", latest_release.tag_name, "on", latest_release.published_at)        
    else:
        print("No releases")
        return
 
    # count commits since the last release (TODO: check to which branch)
    new_commits = repo.get_commits(since = latest_release.published_at)
    nr_new_commits = 0
    for c in new_commits:
            nr_new_commits = nr_new_commits +1
    print("Commits since latest release:", nr_new_commits)

    # find approved PRs and PRs awaiting for the review to start
    approved_prs = []
    unseen_prs = []
    nr_open_prs = 0 
    # TODO: what if branch is 'main'
    prs = repo.get_pulls(state='open', sort='created', base='master')
    for pr in prs:
        nr_open_prs = nr_open_prs + 1
        approve_count = 0
        for review in pr.get_reviews():
            if review.state == 'APPROVED':
                approve_count = approve_count + 1
        if approve_count > 0:  
            approved_prs.append([pr.number,pr.title,approve_count])
    print("Open pull requests:", nr_open_prs)
    print("- of them approved:", len(approved_prs))

                    
def full_report():
    # TODO: way to take repositories from gap-distribution list instead, in alphabetic order
    # below, most recently updated repositories will be listed first
    repos = g.search_repositories(query="org:gap-packages", sort = "updated", order ="desc")
    for repo in repos:
        package_report(repo)
        print()


if __name__ == "__main__":
    if len(sys.argv) > 2:
        usage()
    else:
        utils.initialize_github()
        g = utils.GITHUB_INSTANCE
        print("Current GitHub API capacity", g.rate_limiting, "at", datetime.now().isoformat(), "\n" )

        if len(sys.argv) == 1:
            full_report()
        if len(sys.argv) == 2:
            package_report(sys.argv[1])

        print("Remaining GitHub API capacity", g.rate_limiting, "at", datetime.now().isoformat(), "\n" )
