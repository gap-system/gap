import contextlib
import hashlib
import os
import re
import shutil
import subprocess
import sys
from getpass import getpass
import github

CURRENT_REPO_NAME = os.environ.get("GITHUB_REPOSITORY", "gap-system/gap")

# Initialized by initialize_github
GITHUB_INSTANCE = None
CURRENT_REPO = None

# print notices in green
def notice(msg):
    print("\033[32m" + msg + "\033[0m")

# print warnings in yellow
def warning(msg):
    print("\033[33m" + msg + "\033[0m")

# print error in red and exit
def error(msg):
    print("\033[31m" + msg + "\033[0m")
    sys.exit(1)

def verify_command_available(cmd):
    if shutil.which(cmd) == None:
        error(f"the '{cmd}' command was not found, please install it")
    # TODO: do the analog of this in ReleaseTools bash script:
    # command -v curl >/dev/null 2>&1 ||
    #     error "the 'curl' command was not found, please install it"

def verify_git_repo():
    res = subprocess.run(["git", "--git-dir=.git", "rev-parse"], stderr = subprocess.DEVNULL)
    if res.returncode != 0:
        error("current directory is not a git root directory")

# check for uncommitted changes
def verify_git_clean():
    res = subprocess.run(["git", "update-index", "--refresh"])
    if res.returncode == 0:
        res = subprocess.run(["git", "diff-index", "--quiet", "HEAD", "--"])
    if res.returncode != 0:
        error("uncommitted changes detected")

# from https://code.activestate.com/recipes/576620-changedirectory-context-manager/
@contextlib.contextmanager
def working_directory(path):
    """A context manager which changes the working directory to the given
    path, and then changes it back to its previous value on exit.

    """
    prev_cwd = os.getcwd()
    os.chdir(path)
    yield
    os.chdir(prev_cwd)

# helper for extracting values of variables set in the GAP Makefiles.rules
def get_makefile_var(var):
    res = subprocess.run(["make", f"print-{var}"], check=True, capture_output=True)
    kv = res.stdout.decode('ascii').strip().split('=')
    assert len(kv) == 2
    assert kv[0] == var
    return kv[1]

# compute the sha256 checksum of a file
def sha256file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        # Read and update hash string value in blocks of 4K
        for data in iter(lambda: f.read(4096), b""):
            h.update(data)
        return h.hexdigest()

# read a file into memory, apply some transformations, and write it back
def patchfile(path, pattern, repl):
    # Read in the file
    with open(path, 'r') as file :
        filedata = file.read()

    # Replace the target string
    filedata = re.sub(pattern, repl, filedata)

    # Write the file out again
    with open(path, 'w') as file:
        file.write(filedata)

# download file at the given URL to path `dst`
def download(url, dst):
    res = subprocess.run(["curl", "-L", "-C", "-", "-o", dst, url])
    if res.returncode != 0:
        error('failed downloading ' + url)

# download file at the given URL to path `dst` unless we detect
# that the file in the given URL was already downloaded to path `dst`
def download_with_sha256(url, dst):
    download(url + ".sha256", dst + ".sha256")
    with open(dst + ".sha256", "r") as f:
        expected_checksum = f.read().strip()
    if not os.path.isfile(dst):
        download(url, dst)
    actual_checksum = sha256file(dst)
    if expected_checksum != actual_checksum:
        error(f"checksum for 'dst' expected to be {expected_checksum} but got {actual_checksum}")

# Run what ever <args> command and create appropriate log file
def run_with_log(args, name, msg = None):
    if msg == None:
        msg = name
    with open("../"+name+".log", "w") as fp:
        try:
            subprocess.run(args, check=True, stdout=subprocess.PIPE, stderr=fp)
        except subprocess.CalledProcessError:
            error(msg+" failed. See "+name+".log.")

# Error checked git fetch of tags
def safe_git_fetch_tags():
    try:
        subprocess.run(["git", "fetch", "--tags"], check=True)
    except subprocess.CalledProcessError:
        error('failed to fetch tags, you may have to do \n'
              + 'git fetch --tags -f')


# Returns a boolean
def check_whether_git_tag_exists(tag):
    safe_git_fetch_tags()
    res = subprocess.run(["git", "tag", "-l"],
                         capture_output=True,
                         text=True,
                         check=True)
    tags = res.stdout.split('\n')
    for s in tags:
        if tag == s:
            return True
    return False

# Returns a boolean
def check_whether_github_release_exists(tag):
    if CURRENT_REPO == None:
        print("CURRENT_REPO is not initialized. Call initialize_github first")
    releases = CURRENT_REPO.get_releases()
    for release in releases:
        if release.tag_name == tag:
            return True
    return False

# sets the global variables GITHUB_INSTANCE and CURRENT_REPO
# If no token is provided, this uses the value of the environment variable
# GITHUB_TOKEN.
def initialize_github(token=None):
    global GITHUB_INSTANCE, CURRENT_REPO
    if GITHUB_INSTANCE != None or CURRENT_REPO != None:
        error("Global variables GITHUB_INSTANCE and CURRENT_REPO "
              + " are already initialized.")
    if token == None and "GITHUB_TOKEN" in os.environ:
        token = os.environ["GITHUB_TOKEN"]
    if token == None:
        error("Error: no access token found or provided")
    g = github.Github(token)
    GITHUB_INSTANCE = g
    notice(f"Accessing repository {CURRENT_REPO_NAME}")
    try:
        CURRENT_REPO = GITHUB_INSTANCE.get_repo(CURRENT_REPO_NAME)
    except github.GithubException:
        error("Error: the access token may be incorrect")
