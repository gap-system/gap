#!/usr/bin/env python3
#
# This script is intended to implement step 7 of
# <https://hackmd.io/AWds-AnZT72XXsbA0oVC6A>, i.e.:
#
# 7. Update the website

# FIXME standardise on single or double quotes for strings

#import subprocess
import argparse
import sys
import requests
import datetime
import dateutil.parser
import tempfile
import tarfile
from utils import *
from git import Repo


################################################################################
# Insist on Python >= 3.6
if sys.version_info < (3,6):
    error("Python 3.6 or newer is required")


################################################################################
# Utility functions
def is_possible_gap4_release_tag(tag):
    tag = tag.split('.')
    return len(tag) == 3 and tag[0] == 'v4' and all(x.isdigit() for x in tag[1:])

def mb_bytes(nrbytes):
    return str(round(int(nrbytes) / (1024 * 1024)))


################################################################################
# Define the arguments

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,

description=
"""A script to update the GAP website according to a GAP release on GitHub.

Run this from within a git clone of the GapWWW repository, checked out at the
version you want to update from (most likely the master branch, up to date with
the master branch of github.com/gap-system/GapWWW).

This tool queries the GitHub releases API for the appropriate release, downloads
a corresponding tarball, and extracts relevant data about the included packages
from their PackageInfo.g files. The tools adds this information to website, and
creates a pull request.""",

epilog=
"""Notes:
* To learn how to create a GitHub access token, please consult
  https://help.github.com/articles/creating-an-access-token-for-command-line-use/
""")

# TODO Idea: allow there to be different options: whether or not the release
# we're dealing with represents the 'latest' release this might be useful if,
# for instance, we want to to update the details/assets of an older GAP version
# if they change later, or if GAP 4.13.4 is released after GAP 4.14.0, say.
# TODO allow user to specify which branch to make the changes on?
# TODO Let the user choose between pushing directly and making a PR?
# TODO let the user supply a gaproot containing the downloaded and unpacked GAP archive?
# TODO implement some or all of these
#parser.add_argument('-p', '--push', action='store_true',
#                    help='also perform the final push, completing the release')
parser.add_argument('-f', '--force', action='store_true',
                    help='force push to --push-remeote/--branch')

group = parser.add_argument_group('GAP release details')

group.add_argument('-t', '--tag', type=str,
                   help='git tag of the GAP release, e.g. v4.15.2 (default: latest release)')
# TODO Perhaps the default should be to use the date in GAP's "configure" file?
# TODO This should be an option at least!
group.add_argument('-d', '--date', type=str,
                   help='YYYY-MM-DD GAP release date (default: today\'s date)')
group.add_argument('--use-github-date', action='store_true',
                   help='use the GitHub release publish date as the GAP release date')

group = parser.add_argument_group('Paths')

group.add_argument('--tmpdir', type=str,
                   help='path to the directory in which to download and extract the GAP release (default: a new temporary directory)')
#group.add_argument('--gap', type=str,
#                   help='skip downloading an archive and use the GAP located at...')

group = parser.add_argument_group('Repository details and access')

group.add_argument('--token', type=str,
                   help='GitHub access token')
group.add_argument('--branch', type=str,
                   help='branch in which to make the changes (default: gap-4.X.Y)')
group.add_argument('--push-remote', type=str, default="origin",
                   help='git remote to which --branch is pushed (default: origin)')
group.add_argument('--pr-remote', type=str, default="origin", # TODO
                   help='git remote to which a PR is made (default: origin)')
group.add_argument('--gap-fork', type=str, default="gap-system",
                   help='GitHub GAP fork to search for releases (default: gap-system)')

args = parser.parse_args()


################################################################################
# Verify that commands are available
verify_command_available("git")
# Verify that the pwd is a clean git repo
verify_git_repo()
verify_git_clean()


################################################################################
# Validate the arguments

if args.tag != None and not is_possible_gap4_release_tag(args.tag):
    error('unrecognised format for GAP release tag: ' + args.tag)

if args.use_github_date and args.date:
    error('--use-github-date and --date/-d were both specified; use at most one')
elif args.date:
    try:
        release_date = datetime.datetime.strptime(args.date, '%Y-%m-%d')
    except ValueError:
        error("--date YYYY-MM-DD")
elif not args.use_github_date:
    release_date = datetime.datetime.today()

if (args.push_remote != None and len(args.push_remote) == 0) or (args.pr_remote != None and len(args.pr_remote) == 0):
    error("--push-remote and --pr-remote cannot be empty strings")

if args.tmpdir != None:
    if not os.path.isdir(args.tmpdir) or not os.access(args.tmpdir, os.W_OK):
        error("--tmpdir does not describe a writeable directory")
    tmpdir = args.tmpdir
else:
    tmpdir = tempfile.gettempdir()
if not tmpdir[-1] == '/':
    tmpdir += '/'

if args.token:
    token = args.token
else:
    temp = subprocess.run(["git", "config", "--get", "github.token"], text=True, capture_output=True)
    if temp.returncode == 0:
        token = temp.stdout.strip()
    elif os.path.isfile(os.path.expanduser('~') + '/.github_shell_token'):
        with open(os.path.expanduser('~') + '/.github_shell_token', 'r') as token_file:
            token = token_file.read().replace('\n', '')
    elif 'GITHUB_TOKEN' in os.environ:
        token = os.environ['GITHUB_TOKEN']
    elif 'TOKEN' in os.environ:
        token = os.environ['TOKEN']
if token == None or token == '':
    error("could not determine GitHub access token, please use --token")
initialize_github(token)


################################################################################
# Use the GitHub API to find the GAP release on GitHub
# TODO do this via the python GitHub module
github_releases_url = 'https://api.github.com/repos/' + args.gap_fork + '/gap/releases'
request = requests.get(github_releases_url)
try:
    request.raise_for_status()
except:
    error('failed to connect to GitHub API at ' + github_releases_url)

# Select the appropriate release (as a dictionary)
releases = request.json()
releases = [ x for x in releases if is_possible_gap4_release_tag(x['tag_name']) ]
if len(releases) == 0:
    error("no GAP v4.X.Y releases found on GitHub!")
if args.tag == None:
    # Using latest release; therefore ignore drafts and prerelease
    release = [ x for x in releases if not x['draft'] and not x['prerelease']]
    if not release:
        error("cannot determine the latest (non-draft, non-prerelease) release")
    release = release[0]
else:
    release = [ x for x in releases if x['tag_name'] == args.tag ]
    if len(release) != 1:
        error("non-existent or ambiguous release tag name: " + args.tag)
    release = release[0]

# Divide the assets betwen Windows and UNIX assets
# TODO should archives e.g.  packages-required-v4.11.0.tar.gz be in assets_unix?
assets = release['assets']
def is_windows_asset(name):
    return any(name.endswith(x) for x in ['exe', '-win.zip', '-win32.zip'])
assets_windows = []
assets_unix = []
for asset in assets:
    if not asset['name'].endswith('sha256'):
        if is_windows_asset(asset['name']):
            assets_windows.append(asset)
        else:
            assets_unix.append(asset)

# Release date
if args.use_github_date:
    release_date = dateutil.parser.isoparse(release['published_at'])
year  = release_date.strftime('%Y')
month = release_date.strftime('%B')
date  = release_date.strftime('%d %B %Y')

# Version
gap_version = release['tag_name'][1:]
gap_version_major, gap_version_minor = gap_version.split('.')[1:]

if not args.branch == None:
    branch = args.branch
else:
    branch = "gap-" + gap_version
try:
    subprocess.run(["git", "checkout", "-b", branch], check=True)
except:
    error("branch " + branch + " already exists")

notice("on git branch " + branch + " of GapWWW")
notice("using GAP tag " + release['tag_name'])
notice("using GAP release: " + gap_version)
notice("using release date: " + date)
notice("using temporary directory: " + tmpdir)


################################################################################
# Download and extract the release asset named 'gap-4.X.Y.tar.gz'
# TODO perhaps don't hardcode this name?
tarball = 'gap-' + gap_version + '.tar.gz'
tarball_url = [ x for x in assets_unix if x['name'] == tarball ]
try:
    tarball_url = tarball_url[0]['browser_download_url']
except:
    error("cannot find " + tarball + " in release at tag " + relrease['tag_name'])

gaproot = tmpdir + 'gap-' + gap_version + '/'
pkg_dir = gaproot + 'pkg/'
gap_exe = gaproot + 'bin/gap.sh'

# TODO error handling
with working_directory(tmpdir):
    # TODO only extract if I need to?
    notice('downloading ' + tarball_url + ' (if not already downloaded) to ' + tmpdir + ' . . .')
    download_with_sha256(tarball_url, tarball)
    notice('extracting ' + tarball + ' to ' + gaproot + ' . . .')
    with tarfile.open(tarball) as tar:
        tar.extractall()


################################################################################
# Compile newly-download GAP so that we can use its executable
# TODO error handling
with working_directory(gaproot):
    if os.path.isfile('bin/gap.sh'):
        # TODO The tarball is currently always extracted, overwriting any old one,
        # so GAP will never be already compiled by this point
        notice("GAP is already compiled, not recompiling")
    else:
        notice("compiling newly downloaded GAP to use it for extracting package data")
        notice("running configure . . .")
        with open("../configure.log", "w") as fp:
            subprocess.run(["./configure"], check=True, stdout=fp)
        notice("building GAP . . .")
        with open("../make.log", "w") as fp:
            subprocess.run(["make"], check=True, stdout=fp)

notice("Using GAP root: " + gaproot)
notice("Using GAP executable: " + gap_exe)
notice("Using GAP package directory: " + pkg_dir)


################################################################################
# Rewrite _data/release.yml
notice("writing new _data/release.yml file")
with open('_data/release.yml', 'w') as release_yml:
    release_yml.write("# Release details concerning the most recently released GAP version\n")
    release_yml.write("# This file is automatically updated as part of the GAP release process\n")
    release_yml.write("version: '" + gap_version + "'\n")
    release_yml.write("date: '" + date + "'\n")
    release_yml.write("year: '" + year + "'\n")


# This is currently unnecessary for new releases since we're only linking to
# downloads on GitHub; if this changes, this code should maybe be reinstated
################################################################################
# Append to _data/gap.yml if necessary
#with open('_data/gap.yml', 'r+') as gap_yml:
#    for line in gap_yml:
#        if line.startswith("gap4" + gap_version_major + "dist:"):
#            break
#    else:
#        notice("appending \"gap4" + gap_version_major + "dist: 'https://files.gap-system.org/gap-4." + gap_version_major + "/'\" to _data/gap.yml")
#        gap_yml.write("gap4" + gap_version_major + "dist: 'https://files.gap-system.org/gap-4." + gap_version_major + "/'\n")
#        subprocess.run(["git", "add", "_data/data.yml"], check=True)


################################################################################
# Update/rewrite the YAML data files in _Package for each package in pkg_dir

notice("running etc/rebuild_Packages_dir.sh")
subprocess.run(["etc/rebuild_Packages_dir.sh", pkg_dir, gap_exe], check=True)


################################################################################
# Rewrite _data/help.yml
notice("running GAP on etc/LinksOfAllHelpSections.g")
subprocess.run([gap_exe, "-A", "-r", "-q", "--nointeract", "--norepl", "etc/LinksOfAllHelpSections.g"], check=True)


################################################################################
# Write _Releases/4.X.Y.html
release_file = "_Releases/" + gap_version + ".html"
notice("writing a new release file: " + release_file)

with open(release_file, 'w') as new_file:
    new_file.write("---\n")
    new_file.write("version: " + gap_version + "\n")
    new_file.write('date: "' + month + ' ' + year + '"\n')
    new_file.write("packages:")

# Insert brief YAML data describing each package included in this GAP release
notice("running etc/release_helper.sh")
subprocess.run(["etc/release_helper.sh", gaproot, release_file], check=True)

# TODO Max Horn: probably better to only produce a YAML file below, and then add
# a template to GapWWW using it; this way, we don't need to duplicate specific
# HTML code here. But that can happen at a later point in the futre
# Wilf Wilson: Agreed 100%.
def write_asset_table_row(out, asset):
    # TODO use already-downloaded sha256 file that is in the tmpdir
    request = requests.get(asset['browser_download_url'] + '.sha256')
    try:
        request.raise_for_status()
    except:
        error('failed to download ' + asset['browser_download_url'] + '.sha256')
    sha256 = request.text.strip()
    out.write('\n<tr>\n')
    out.write('  <td align="left"><a href="' + asset['browser_download_url'] + '">' + asset['name'] + '</a></td>\n')
    out.write('  <td align="left">' + mb_bytes(asset['size']) + ' MB</td>\n')
    out.write('  <td align="left">sha256: ' + sha256 + '</td>\n')
    out.write('</tr>')

with open(release_file, 'a') as new_file:
    new_file.write("""
---

<h2>Linux and OS X</h2>

<p>
Download one of the <code>gap-{{page.version}}.*</code> archives below, unpack it and run <code>./configure &amp;&amp; make</code>
in the unpacked directory. Then change to the <code>pkg</code> subdirectory and call
<code>../bin/BuildPackages.sh</code> to run the script which will build most of the
packages that require compilation (provided sufficiently many libraries, headers and
tools are available). For further details, see <a href="../Download/index.html">here</a>.
Expert users can find the description of all installation options in the
<a href="https://github.com/gap-system/gap/blob/v{{page.version}}/INSTALL.md">INSTALL.md</a> file.
</p>

<table>
 <colgroup>
  <col width="30%">
  <col width="20%">
  <col width="50%">
 </colgroup>""")
    for asset in assets_unix:
        write_asset_table_row(new_file, asset)
    new_file.write("""
</table>

<p>
You may also consider one of the
<a href="../Download/alternatives.html">alternative distributions</a>.
Note, however, that these are updated independently and may not yet
provide the latest GAP release.
</p>""")
    new_file.write("""
<h2>Packages included in this release</h2>

<p>
Each of the GAP {{page.version}} archives contains 
the core GAP system (the source code,
<a href="../Datalib/datalib.html">data libraries</a>, regression tests and 
<a href="../Doc/manuals.html">documentation</a>), and the following selection of
<a href="../Packages/packages.html">packages</a>:
</p>
""")
# TODO say something about how Windows is coming...


################################################################################
# Commit, push, and create pull request to github.com/gap-system/GapWWW

subprocess.run(["git", "add", "_data/release.yml", "_Packages/*.html", "_data/help.yml", release_file], check=True)

# TODO if git is clean, then the website is already up to date, so we should
# exit gracefully

try:
    subprocess.run(["git", "commit", "-m", "'Update website for GAP " + gap_version + " release'"], check=True)
except:
    error("failed to commit to new branch")

try:
    verify_git_clean()
except:
    error("files have changed that we didn't expect (check git status)")

try:
    # TODO push with token!
    #REMOTE="https://$GITHUB_USER:$TOKEN@github.com/$REPO"
    if args.force:
        command = ["git", "push", "-f", args.push_remote, branch]
    else:
        command = ["git", "push", args.push_remote, branch]
    subprocess.run(command, check=True)
except:
    error("failed to push " + branch + " to " + args.push_remote)

notice("TODO: create pull request")

# TODO Download all package tarballs, and compute their sizes and sha256 checksums
# TODO sftp tarballs from GitHub release system to gap-system.org
# TODO sftp package manuals
#
# also commit and/or upload the GAP and GAP package manuals somewhere (HTML and PDF could go into different places)
# possibly helpful for inspiration:

#  https://github.com/BryanSchuetz/jekyll-deploy-gh-pages uses an GitHub Action to push to a branch
#  https://github.com/marketplace/actions/create-pull-reques
