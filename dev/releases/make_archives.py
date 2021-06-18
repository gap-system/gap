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
##  This script create the archives that form a GA{} release.
##  
##  The version of the gap release is taken from the Makefile variable
##  GAP_BUILD_VERSION.
##  
from utils import *

import glob
import gzip
import re
import shutil
import subprocess
import sys
import tarfile
import json

# Insist on Python >= 3.6 for f-strings and other goodies
if sys.version_info < (3,6):
    error("Python 3.6 or newer is required")

notice("Checking prerequisites")
verify_command_available("curl")
verify_command_available("git")
verify_command_available("autoconf")
verify_command_available("make")
verify_git_repo()
verify_git_clean()

# fetch tags, so we can properly detect
safe_git_fetch_tags()

# Creating tmp directory
tmpdir = os.getcwd() + "/tmp"
notice(f"Files will be put in {tmpdir}")
try:
    os.mkdir(tmpdir)
except FileExistsError:
    pass

# extract the GAP version from this directory *NOT THE SNAPSHOT DIR*
try:
    gapversion = get_makefile_var("GAP_BUILD_VERSION")
except:
    error("make sure GAP has been compiled via './configure && make'")
notice(f"Detected GAP version {gapversion}")

if re.fullmatch( r"[1-9]+\.[0-9]+\.[0-9]+", gapversion) != None:
    notice(f"--- THIS LOOKS LIKE A RELEASE ---")
else:
    notice(f"--- THIS LOOKS LIKE A NIGHTLY BUILD ---")


# extract commit_date with format YYYY-MM-DD
# TODO: is that really what we want? Or should it be the date this
# script was run? Or for releases, perhaps use the TaggerDate of the
# release tag (but then we need to find and process that tag)
commit_date = subprocess.run(["git", "show", "-s", "--format=%as"],
                             check=True, capture_output=True, text=True)
commit_date = commit_date.stdout.strip()
commit_year = commit_date[0:4]

# derive tarball names
basename = f"gap-{gapversion}"
all_packages = f"packages-v{gapversion}" # only the pkg dir
all_packages_tarball = f"{all_packages}.tar.gz"
req_packages = f"packages-required-v{gapversion}" # a subset of the above
req_packages_tarball = f"{req_packages}.tar.gz"

# Exporting repository content into tmp
notice("Exporting repository content via `git archive`")
rawbasename = "gap-raw"
rawgap_tarfile = f"{tmpdir}/{rawbasename}.tar"
subprocess.run(["git", "archive",
                f"--prefix={basename}/",
                f"--output={rawgap_tarfile}",
                "HEAD"], check=True)

notice("Extracting exported content")
shutil.rmtree(basename, ignore_errors=True) # remove any leftovers
with tarfile.open(rawgap_tarfile) as tar:
    tar.extractall(path=tmpdir)
os.remove(rawgap_tarfile)

notice("Processing exported content")
manifest_list = [] # collect names of assets to be uploaded to GitHub release

with working_directory(tmpdir + "/" + basename):
    # This sets the version, release day and year of the release we are
    # creating.
    notice("Patching configure.ac")
    patchfile("configure.ac", r"m4_define\(\[gap_version\],[^\n]+", r"m4_define([gap_version], ["+gapversion+"])")
    patchfile("configure.ac", r"m4_define\(\[gap_releaseday\],[^\n]+", r"m4_define([gap_releaseday], ["+commit_date+"])")
    patchfile("configure.ac", r"m4_define\(\[gap_releaseyear\],[^\n]+", r"m4_define([gap_releaseyear], ["+commit_year+"])")

    # Building GAP
    notice("Running autogen.sh")
    subprocess.run(["./autogen.sh"], check=True)

    notice("Running configure")
    run_with_log(["./configure"], "configure")

    notice("Building GAP")
    run_with_log(["make", "-j8"], "make")

    # TODO should we verify somewhere that an actual release vX.Y.Z is made from
    # a stable branch, with branchname=stable-X.Y? Or will this be checked
    # somewhere else in practice, and it would just be an annoyance for people
    # wanting to test these scripts in the master branch?

    # build HPC-GAP so we can get its c_oper1.c and c_type1.c for redistribution
    notice("Building HPC-GAP")
    os.mkdir("hpcgap-build")
    with working_directory("hpcgap-build"):
        run_with_log(["../configure", "--enable-hpcgap"], "../configure-hpcgap")
        run_with_log(["make", "-j8"], "../make-hpcgap")

    notice("Copy GAP-to-C compilation results")
    shutil.copy("build/c_oper1.c", "src")
    shutil.copy("build/c_type1.c", "src")
    shutil.copy("hpcgap-build/build/c_oper1.c", "src/hpc")
    shutil.copy("hpcgap-build/build/c_type1.c", "src/hpc")

    notice("Removing HPC-GAP build directory")
    shutil.rmtree("hpcgap-build")

    # extract some values from the build system
    branchname = get_makefile_var("PKG_BRANCH")
    PKG_BOOTSTRAP_URL = get_makefile_var("PKG_BOOTSTRAP_URL")
    PKG_MINIMAL = get_makefile_var("PKG_MINIMAL")
    PKG_FULL = get_makefile_var("PKG_FULL")
    notice(f"branchname = {branchname}")
    notice(f"PKG_BOOTSTRAP_URL = {PKG_BOOTSTRAP_URL}")
    notice(f"PKG_MINIMAL = {PKG_MINIMAL}")
    notice(f"PKG_FULL = {PKG_FULL}")

    notice("Downloading package tarballs")   # ... outside of the directory we just created
    download_with_sha256(PKG_BOOTSTRAP_URL+PKG_MINIMAL, tmpdir+"/"+req_packages_tarball)
    download_with_sha256(PKG_BOOTSTRAP_URL+PKG_FULL, tmpdir+"/"+all_packages_tarball)
    manifest_list.append(req_packages_tarball)
    manifest_list.append(all_packages_tarball)

    notice("Extracting package tarballs")
    with tarfile.open(tmpdir+"/"+all_packages_tarball) as tar:
        tar.extractall(path="pkg")
    with tarfile.open(tmpdir+"/"+req_packages_tarball) as tar:
        tar.extractall(path=tmpdir+"/"+req_packages)

    notice("Building GAP's manuals")
    run_with_log(["make", "doc"], "gapdoc", "building the manuals")

    # Now we create the files package-infos.json and help-links.json. We build
    # the json package, create the files, then clean up the package again.
    notice("Compiling json package")
    path_to_json_package = glob.glob(f'{tmpdir}/{basename}/pkg/json*')[0]
    with working_directory(path_to_json_package):
        subprocess.run(["./configure"], check=True)
        subprocess.run(["make"], check=True)

    for x in [ ["package-infos", "PackageInfos-to-JSON"], ["help-links", "HelpLinks-to-JSON"] ]:
        notice(f"Constructing {x[0]} JSON file")
        json_output = subprocess.run(
                ["./bin/gap.sh", "-r", "--quiet", "--quitonbreak", f"dev/releases/{x[1]}.g"],
                check=True, capture_output=True, text=True)
        formatted_json = json.dumps(json.loads(json_output.stdout), indent=2)
        with working_directory(tmpdir):
            with gzip.open(f"{x[0]}.json.gz", 'wb') as file:
                file.write(formatted_json.encode('utf-8'))
            manifest_list.append(f"{x[0]}.json.gz")

    notice("Cleaning up the json package")
    with working_directory(path_to_json_package):
        subprocess.run(["make", "clean"], check=True)
        shutil.rmtree("bin")
        os.remove("Makefile")

    notice("Removing unwanted version-controlled files")
    badfiles = [
    ".codecov.yml",
    ".ctags",
    ".gitattributes",
    ".gitignore",
    ".mailmap",
    ]

    shutil.rmtree("benchmark")
    shutil.rmtree("dev")
    shutil.rmtree("doc/dev")
    shutil.rmtree(".github")
    for f in badfiles:
        try:
            os.remove(f)
        except:
            pass


    notice("Removing generated files we don't want to distribute")
    run_with_log(["make", "distclean"], "make-distclean", "make distclean")


# Create an archive in the current directory with shutil.make_archive, and
# record the filename of the new archive in <manifest_list>.
# The arguments of this function match those to shutil.make_archive.
def make_and_record_archive(name, compression, root_dir, base_dir):
    # Deduce file extension from compression
    if compression == "gztar":
        ext = ".tar.gz"
    elif compression == "zip":
        ext = ".zip"
    else:
        error(f"unknown compression type {compression} (not gztar or zip)")

    filename = f"{name}{ext}"
    notice(f"Creating {filename}")
    shutil.make_archive(name, compression, root_dir, base_dir)
    manifest_list.append(filename)

# Create the remaining archives
notice("Creating remaining GAP and package archives")
with working_directory(tmpdir):
    make_and_record_archive(basename, "gztar", ".", basename)
    make_and_record_archive(basename, "zip",   ".", basename)
    make_and_record_archive(all_packages, "zip", basename, "pkg")
    make_and_record_archive(req_packages, "zip", ".", req_packages)
    notice("Removing packages to facilitate creating the GAP core archives")
    shutil.rmtree(basename + "/pkg")
    make_and_record_archive(basename + "-core", "gztar", ".", basename)
    make_and_record_archive(basename + "-core", "zip",   ".", basename)

    # If you create additional archives, make sure to add them to manifest_list!
    manifest_filename = "MANIFEST"
    notice(f"Creating the manifest, with name {manifest_filename}")
    with open(manifest_filename, 'w') as manifest:
        for filename in manifest_list:
            manifest.write(f"{filename}\n")

# The end
notice("DONE")
