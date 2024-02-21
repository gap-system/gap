#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
import contextlib
import hashlib
import os
import re
import shutil
import subprocess
import sys
from typing import Iterator, List, NoReturn, Optional

import requests


# print notices in green
def notice(msg: str) -> None:
    print("\033[32m" + msg + "\033[0m")


# print warnings in yellow
def warning(msg: str) -> None:
    print("\033[33m" + msg + "\033[0m", file=sys.stderr)


# print error in red and exit
def error(msg: str) -> NoReturn:
    print("\033[31m" + msg + "\033[0m", file=sys.stderr)
    sys.exit(1)


def verify_command_available(cmd: str) -> None:
    if shutil.which(cmd) is None:
        error(f"the '{cmd}' command was not found, please install it")
    # TODO: do the analog of this in ReleaseTools bash script:
    # command -v curl >/dev/null 2>&1 ||
    #     error "the 'curl' command was not found, please install it"


def verify_git_repo() -> None:
    res = subprocess.run(
        ["git", "--git-dir=.git", "rev-parse"], stderr=subprocess.DEVNULL, check=False
    )
    if res.returncode != 0:
        error("current directory is not a git root directory")


# check for uncommitted changes
def is_git_clean() -> bool:
    res = subprocess.run(["git", "update-index", "--refresh"], check=False)
    if res.returncode == 0:
        res = subprocess.run(["git", "diff-index", "--quiet", "HEAD", "--"])
    return res.returncode == 0


def verify_git_clean() -> None:
    if not is_git_clean():
        error("uncommitted changes detected")


# from https://code.activestate.com/recipes/576620-changedirectory-context-manager/
@contextlib.contextmanager
def working_directory(path: str) -> Iterator[None]:
    """A context manager which changes the working directory to the given
    path, and then changes it back to its previous value on exit.

    """
    prev_cwd = os.getcwd()
    os.chdir(path)
    yield
    os.chdir(prev_cwd)


# helper for extracting values of variables set in the GAP Makefiles.rules
def get_makefile_var(var: str) -> str:
    res = subprocess.run(["make", f"print-{var}"], check=True, capture_output=True)
    kv = res.stdout.decode("ascii").strip().split("=")
    assert len(kv) == 2
    assert kv[0] == var
    return kv[1]


# compute the sha256 checksum of a file
def sha256file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        # Read and update hash string value in blocks of 4K
        for data in iter(lambda: f.read(4096), b""):
            h.update(data)
        return h.hexdigest()


# read a file into memory, apply some transformations, and write it back
def patchfile(path: str, pattern: str, repl: str) -> None:
    # Read in the file
    with open(path, "r", encoding="utf-8") as file:
        filedata = file.read()

    # Replace the target string
    filedata = re.sub(pattern, repl, filedata)

    # Write the file out again
    with open(path, "w", encoding="utf-8") as file:
        file.write(filedata)


# download file at the given URL to path `dst`
def download(url: str, dst: str) -> None:
    notice(f"Downlading {url} to {dst}")
    res = subprocess.run(["curl", "-L", "-C", "-", "-o", dst, url], check=False)
    if res.returncode != 0:
        error("failed downloading " + url)


# Download file at the given URL to path `dst`, unless we detect that a file
# already exists at `dst` with the expected checksum.
def download_with_sha256(url: str, dst: str) -> None:
    # fetch the checksum file directly into memory
    r = requests.get(url + ".sha256")
    if r.status_code != 200:
        error(f"Failed to download sha256 file {url}.sha256")
    expected_checksum = r.text.strip()
    if os.path.isfile(dst):
        actual_checksum = sha256file(dst)
        if expected_checksum == actual_checksum:
            return
        notice(f"{dst} exists but does not match the checksumfile; redownloading")
        os.remove(dst)
    download(url, dst)
    actual_checksum = sha256file(dst)
    if expected_checksum != actual_checksum:
        error(
            f"checksum for '{dst}' expected to be {expected_checksum} but got {actual_checksum}"
        )


# Run what ever <args> command and create appropriate log file
def run_with_log(args: List[str], name: str, msg: Optional[str] = None) -> None:
    if not msg:
        msg = name
    with open("../" + name + ".log", "w", encoding="utf-8") as fp:
        try:
            subprocess.run(args, check=True, stdout=fp, stderr=fp)
        except subprocess.CalledProcessError:
            error(msg + " failed. See " + name + ".log.")


def is_possible_gap_release_tag(tag: str) -> bool:
    return re.fullmatch(r"v[1-9]+\.[0-9]+\.[0-9]+(-.+)?", tag) is not None


def verify_is_possible_gap_release_tag(tag: str) -> None:
    if not is_possible_gap_release_tag(tag):
        error(f"{tag} does not look like the tag of a GAP release version")


def is_existing_tag(tag: str) -> bool:
    res = subprocess.run(
        ["git", "show-ref", "--quiet", "--verify", "refs/tags/" + tag], check=False
    )
    return res.returncode == 0


# Error checked git fetch of tags
def safe_git_fetch_tags() -> None:
    try:
        subprocess.run(["git", "fetch", "--tags"], check=True)
    except subprocess.CalledProcessError:
        error("failed to fetch tags, you may have to do \n" + "git fetch --tags -f")


# lightweight vs annotated
# https://stackoverflow.com/questions/40479712/how-can-i-tell-if-a-given-git-tag-is-annotated-or-lightweight#40499437
def is_annotated_git_tag(tag: str) -> bool:
    res = subprocess.run(
        ["git", "for-each-ref", "refs/tags/" + tag],
        capture_output=True,
        text=True,
        check=False,
    )
    return res.returncode == 0 and res.stdout.split()[1] == "tag"


def check_git_tag_for_release(tag: str) -> None:
    if not is_annotated_git_tag(tag):
        error(f"There is no annotated tag {tag}")
    # check that tag points to HEAD
    tag_commit = subprocess.run(
        ["git", "rev-parse", tag + "^{}"], check=True, capture_output=True, text=True
    ).stdout.strip()
    head = subprocess.run(
        ["git", "rev-parse", "HEAD"], check=True, capture_output=True, text=True
    ).stdout.strip()
    if tag_commit != head:
        error(
            f"The tag {tag} does not point to the current commit {head} but"
            + f" instead points to {tag_commit}"
        )
