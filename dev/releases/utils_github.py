#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
import os
import subprocess

import github
from utils import error, notice, sha256file

from typing import Optional


# If no token is provided, this uses the value of the environment variable
# GITHUB_TOKEN.
def initialize_github(token: Optional[str] = None) -> github.Repository.Repository:
    if token is None and "GITHUB_TOKEN" in os.environ:
        token = os.environ["GITHUB_TOKEN"]
    if token is None:
        temp = subprocess.run(
            ["git", "config", "--get", "github.token"],
            text=True,
            capture_output=True,
            check=False,
        )
        if temp.returncode == 0:
            token = temp.stdout.strip()
    if token is None and os.path.isfile(
        os.path.expanduser("~") + "/.github_shell_token"
    ):
        with open(
            os.path.expanduser("~") + "/.github_shell_token", "r", encoding="utf-8"
        ) as token_file:
            token = token_file.read().strip()
    if token is None:
        error("Error: no access token found or provided")
    g = github.Github(auth=github.Auth.Token(token))
    repo_name = os.environ.get("GITHUB_REPOSITORY", "gap-system/gap")
    notice(f"Accessing repository {repo_name}")
    try:
        return g.get_repo(repo_name)
    except github.GithubException:
        error("Error: the access token may be incorrect")


def verify_via_checksumfile(filename: str) -> None:
    actual_checksum = sha256file(filename)
    with open(filename + ".sha256", "r", encoding="utf-8") as f:
        expected_checksum = f.read().strip()
    if expected_checksum != actual_checksum:
        error(
            f"checksum for '{filename}' expected to be {expected_checksum} but got {actual_checksum}"
        )


# Given the <filename> of a file that does not end with .sha256, create or get
# the corresponding sha256 checksum file <filename>.sha256, (comparing checksums
# just to be safe, in the latter case). Then upload the files <filename> and
# <filename>.sha256 as assets to the GitHub <release>.
# Files already ending in ".sha256" are ignored.
def upload_asset_with_checksum(
    release: github.GitRelease.GitRelease, filename: str
) -> None:
    if not os.path.isfile(filename):
        error(f"{filename} not found")

    if filename.endswith(".sha256"):
        notice(f"Skipping provided checksum file {filename}")
        return

    notice(f"Processing {filename}")

    checksum_filename = filename + ".sha256"
    if os.path.isfile(checksum_filename):
        notice("Comparing actual checksum with pre-existing checksum file")
        verify_via_checksumfile(filename)
    else:
        notice("Writing new checksum file")
        with open(checksum_filename, "w", encoding="utf-8") as checksumfile:
            checksumfile.write(sha256file(filename))

    for file in [filename, checksum_filename]:
        try:
            notice(f"Uploading {file}")
            release.upload_asset(file)
        except github.GithubException:
            error("Error: The upload failed")
