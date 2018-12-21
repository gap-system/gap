#!/usr/bin/env python
# -*- coding:utf-8 -*-
#
# A report generator for gcov 3.4
#
# This routine generates a format that is similar to the format generated
# by the Python coverage.py module.  This code is similar to the
# data processing performed by lcov's geninfo command.  However, we
# don't worry about parsing the *.gcna files, and backwards compatibility for
# older versions of gcov is not supported.
#
# Outstanding issues
#   - verify that gcov 3.4 or newer is being used
#   - verify support for symbolic links
#
# For documentation, bug reporting, and updates,
# see http://gcovr.com/
#
#  _________________________________________________________________________
#
#  Gcovr: A parsing and reporting tool for gcov
#  Copyright (c) 2013 Sandia Corporation.
#  This software is distributed under the BSD License.
#  Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
#  the U.S. Government retains certain rights in this software.
#  For more information, see the README.md file.
# _________________________________________________________________________
#
# !! ** !! ** !!
#
# This file is entirely based on gcovr's main file, plus a json output
# generator. I will try to get some changes pushed upstream
#

import locale
import os
import re
import sys
import json
import mmap
import hashlib

from argparse import ArgumentParser, ArgumentTypeError
from os.path import normpath
from multiprocessing import cpu_count
from tempfile import mkdtemp
from shutil import rmtree

from gcovr.gcov import get_datafiles, process_existing_gcov_file, process_datafile
from gcovr.utils import (get_global_stats, build_filter, AlwaysMatchFilter,
                    DirectoryPrefixFilter, Logger)
from gcovr.version import __version__
from gcovr.workers import Workers
from gcovr.coverage import CoverageData

# generators

# count the number of lines in a file
def mapcount(filename):
    f = open(filename, "r+")
    buf = mmap.mmap(f.fileno(), 0)
    lines = 0
    readline = buf.readline
    while readline():
        lines += 1
    return lines

# compute the md5 sum of a file
def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


# TODO: branches?
def write_coveralls_json(covdata, options):
    report = {}
    files = [] 
    for file in covdata.keys():
        data = covdata[file]
        nlines = mapcount(file)
        coverage = [ None ] * nlines

        for line in data.all_lines:
            hits = data.covered.get(line, 0)
            if line - 1 < len(coverage):
                coverage[line-1] = hits 
            else:
                # TODO: Log error
                pass

        files.append( { "name": options.root_filter.sub('', file)
                    , "source_digest": md5(file)
                    , "coverage": coverage } )

    # these would need determination from the environment
    # since in GAP we merge the results output by this script
    # with output from the GAP coverage, we will just use the
    # GAP part
    # report["service_name"] = ""
    # report["service_job_id"] = os.environ.get("TRAVIS_JOB_ID", "")
    # report["parallel"] = True
    report["source_files"] = files

    if options.output:
        output = open(options.output, "w+")
    else:
        output = sys.stdout

    json.dump(report, output)
    if options.output:
        output.close()


#
# Exits with status 2 if below threshold
#
def fail_under(covdata, threshold_line, threshold_branch):
    (lines_total, lines_covered, percent,
        branches_total, branches_covered,
        percent_branches) = get_global_stats(covdata)

    if branches_total == 0:
        percent_branches = 100.0

    if percent < threshold_line and percent_branches < threshold_branch:
        sys.exit(6)
    if percent < threshold_line:
        sys.exit(2)
    if percent_branches < threshold_branch:
        sys.exit(4)


# helper for percentage actions
def check_percentage(value):
    try:
        x = float(value)
        if not (0.0 <= x <= 100.0):
            raise ValueError()
    except ValueError:
        raise ArgumentTypeError(
            "{value} not in range [0.0, 100.0]".format(value=value))
    return x


def create_argument_parser():
    """Create the argument parser."""

    parser = ArgumentParser(add_help=False)
    parser.usage = "gcovr [options] [search_paths...]"
    parser.description = \
        "A utility to run gcov and summarize the coverage in simple reports."

    parser.epilog = "See <http://gcovr.com/> for the full manual."

    # Style guide for option help messages:
    # - Prefer complete sentences.
    # - Phrase first sentence as a command:
    #   “Print report”, not “Prints report”.
    # - Must be readable on the command line,
    #   AND parse as reStructured Text.

    options = parser.add_argument_group('Options')
    options.add_argument(
        "-h", "--help",
        help="Show this help message, then exit.",
        action="help"
    )
    options.add_argument(
        "--version",
        help="Print the version number, then exit.",
        action="store_true",
        dest="version",
        default=False
    )
    options.add_argument(
        "-v", "--verbose",
        help="Print progress messages. "
             "Please include this output in bug reports.",
        action="store_true",
        dest="verbose",
        default=False
    )
    options.add_argument(
        "-r", "--root",
        help="The root directory of your source files. "
             "Defaults to '%(default)s', the current directory. "
             "File names are reported relative to this root. "
             "The --root is the default --filter.",
        action="store",
        dest="root",
        default='.'
    )
    options.add_argument(
        'search_paths',
        help="Search these directories for coverage files. "
             "Defaults to --root and --object-directory.",
        nargs='*',
    )
    options.add_argument(
        "--fail-under-line",
        type=check_percentage,
        metavar="MIN",
        help="Exit with a status of 2 "
             "if the total line coverage is less than MIN. "
             "Can be ORed with exit status of '--fail-under-branch' option.",
        action="store",
        dest="fail_under_line",
        default=0.0
    )
    options.add_argument(
        "--fail-under-branch",
        type=check_percentage,
        metavar="MIN",
        help="Exit with a status of 4 "
             "if the total branch coverage is less than MIN. "
             "Can be ORed with exit status of '--fail-under-line' option.",
        action="store",
        dest="fail_under_branch",
        default=0.0
    )
    options.add_argument(
        '--source-encoding',
        help="Select the source file encoding. "
             "Defaults to the system default encoding (%(default)s).",
        action='store',
        dest='source_encoding',
        default=locale.getpreferredencoding()
    )

    output_options = parser.add_argument_group(
        "Output Options",
        description="Gcovr prints a text report by default, "
                    "but can switch to XML or HTML."
    )
    output_options.add_argument(
        "-o", "--output",
        help="Print output to this filename. Defaults to stdout. "
             "Required for --html-details.",
        action="store",
        dest="output",
        default=None
    )
    output_options.add_argument(
        "-b", "--branches",
        help="Report the branch coverage instead of the line coverage. "
             "For text report only.",
        action="store_true",
        dest="show_branch",
        default=None
    )
    output_options.add_argument(
        "-u", "--sort-uncovered",
        help="Sort entries by increasing number of uncovered lines. "
             "For text and HTML report.",
        action="store_true",
        dest="sort_uncovered",
        default=None
    )
    output_options.add_argument(
        "-p", "--sort-percentage",
        help="Sort entries by increasing percentage of uncovered lines. "
             "For text and HTML report.",
        action="store_true",
        dest="sort_percent",
        default=None
    )
    output_options.add_argument(
        "-x", "--xml",
        help="Generate a Cobertura XML report.",
        action="store_true",
        dest="xml",
        default=False
    )
    output_options.add_argument(
        "--xml-pretty",
        help="Pretty-print the XML report. Implies --xml. Default: %(default)s.",
        action="store_true",
        dest="prettyxml",
        default=False
    )
    output_options.add_argument(
        "--html",
        help="Generate a HTML report.",
        action="store_true",
        dest="html",
        default=False
    )
    output_options.add_argument(
        "--html-details",
        help="Add annotated source code reports to the HTML report. "
             "Requires --output as a basename for the reports. "
             "Implies --html.",
        action="store_true",
        dest="html_details",
        default=False
    )
    output_options.add_argument(
        "--html-title",
        metavar="TITLE",
        help="Use TITLE as title for the HTML report. Default is %(default)s.",
        action="store",
        dest="html_title",
        default="Head"
    )
    options.add_argument(
        "--html-medium-threshold",
        type=check_percentage,
        metavar="MEDIUM",
        help="If the coverage is below MEDIUM, the value is marked "
             "as low coverage in the HTML report. "
             "MEDIUM has to be lower than or equal to value of --html-high-threshold. "
             "If MEDIUM is equal to value of --html-high-threshold the report has "
             "only high and low coverage. Default is %(default)s.",
        action="store",
        dest="html_medium_threshold",
        default=75.0
    )
    options.add_argument(
        "--html-high-threshold",
        type=check_percentage,
        metavar="HIGH",
        help="If the coverage is below HIGH, the value is marked "
             "as medium coverage in the HTML report. "
             "HIGH has to be greater than or equal to value of --html-medium-threshold. "
             "If HIGH is equal to value of --html-medium-threshold the report has "
             "only high and low coverage. Default is %(default)s.",
        action="store",
        dest="html_high_threshold",
        default=90.0
    )
    output_options.add_argument(
        "--html-absolute-paths",
        help="Use absolute paths to link the --html-details reports. "
             "Defaults to relative links.",
        action="store_false",
        dest="relative_anchors",
        default=True
    )
    output_options.add_argument(
        '--html-encoding',
        help="Override the declared HTML report encoding. "
             "Defaults to %(default)s. "
             "See also --source-encoding.",
        action='store',
        dest='html_encoding',
        default='UTF-8'
    )
    output_options.add_argument(
        "-s", "--print-summary",
        help="Print a small report to stdout "
             "with line & branch percentage coverage. "
             "This is in addition to other reports. "
             "Default: %(default)s.",
        action="store_true",
        dest="print_summary",
        default=False
    )

    filter_options = parser.add_argument_group(
        "Filter Options",
        description="Filters decide which files are included in the report. "
                    "Any filter must match, and no exclude filter must match. "
                    "A filter is a regular expression that matches a path. "
                    "Filter paths use forward slashes, even on Windows."
    )
    filter_options.add_argument(
        "-f", "--filter",
        help="Keep only source files that match this filter. "
             "Can be specified multiple times. "
             "If no filters are provided, defaults to --root.",
        action="append",
        dest="filter",
        default=[]
    )
    filter_options.add_argument(
        "-e", "--exclude",
        help="Exclude source files that match this filter. "
             "Can be specified multiple times.",
        action="append",
        dest="exclude",
        default=[]
    )
    filter_options.add_argument(
        "--gcov-filter",
        help="Keep only gcov data files that match this filter. "
             "Can be specified multiple times.",
        action="append",
        dest="gcov_filter",
        default=[]
    )
    filter_options.add_argument(
        "--gcov-exclude",
        help="Exclude gcov data files that match this filter. "
             "Can be specified multiple times.",
        action="append",
        dest="gcov_exclude",
        default=[]
    )
    filter_options.add_argument(
        "--exclude-directories",
        help="Exclude directories that match this regex "
             "while searching raw coverage files. "
             "Can be specified multiple times.",
        action="append",
        dest="exclude_dirs",
        default=[]
    )

    gcov_options = parser.add_argument_group(
        "GCOV Options",
        "The 'gcov' tool turns raw coverage files (.gcda and .gcno) "
        "into .gcov files that are then processed by gcovr. "
        "The gcno files are generated by the compiler. "
        "The gcda files are generated when the instrumented program is executed."
    )
    gcov_options.add_argument(
        "--gcov-executable",
        help="Use a particular gcov executable. "
             "Must match the compiler you are using, "
             "e.g. 'llvm-cov gcov' for Clang. "
             "Can include additional arguments. "
             "Defaults to the GCOV environment variable, "
             "or 'gcov': '%(default)s'.",
        action="store",
        dest="gcov_cmd",
        default=os.environ.get('GCOV', 'gcov')
    )
    gcov_options.add_argument(
        "--exclude-unreachable-branches",
        help="Exclude branch coverage with LCOV/GCOV exclude markers. "
             "Additionally, exclude branch coverage from lines "
             "without useful source code "
             "(often, compiler-generated \"dead\" code). "
             "Default: %(default)s.",
        action="store_true",
        dest="exclude_unreachable_branches",
        default=False
    )
    gcov_options.add_argument(
        "-g", "--use-gcov-files",
        help="Use existing gcov files for analysis. Default: %(default)s.",
        action="store_true",
        dest="gcov_files",
        default=False
    )
    gcov_options.add_argument(
        '--gcov-ignore-parse-errors',
        help="Skip lines with parse errors in GCOV files "
             "instead of exiting with an error. "
             "A report will be shown on stderr. "
             "Default: %(default)s.",
        action="store_true",
        dest="gcov_ignore_parse_errors",
        default=False
    )
    gcov_options.add_argument(
        '--object-directory',
        help="Override normal working directory detection. "
             "Gcovr needs to identify the path between gcda files "
             "and the directory where the compiler was originally run. "
             "Normally, gcovr can guess correctly. "
             "This option specifies either "
             "the path from gcc to the gcda file (i.e. gcc's '-o' option), "
             "or the path from the gcda file to gcc's working directory.",
        action="store",
        dest="objdir",
        default=None
    )
    gcov_options.add_argument(
        "-k", "--keep",
        help="Keep gcov files after processing. "
             "This applies both to files that were generated by gcovr, "
             "or were supplied via the --use-gcov-files option. "
             "Default: %(default)s.",
        action="store_true",
        dest="keep",
        default=False
    )
    gcov_options.add_argument(
        "-d", "--delete",
        help="Delete gcda files after processing. Default: %(default)s.",
        action="store_true",
        dest="delete",
        default=False
    )
    gcov_options.add_argument(
        "-j",
        help="Set the number of threads to use in parallel.",
        nargs="?",
        const=cpu_count(),
        type=int,
        dest="gcov_parallel",
        default=1
    )
    return parser


COPYRIGHT = (
    "Copyright 2013-2018 the gcovr authors\n"
    "Copyright 2013 Sandia Corporation\n"
    "Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,\n"
    "the U.S. Government retains certain rights in this software."
)


def main(args=None):
    parser = create_argument_parser()
    options = parser.parse_args(args=args)

    logger = Logger(options.verbose)

    if options.version:
        logger.msg(
            "gcovr {version}\n"
            "\n"
            "{copyright}",
            version=__version__, copyright=COPYRIGHT)
        sys.exit(0)

    if options.html_medium_threshold > options.html_high_threshold:
        logger.error(
            "value of --html-medium-threshold={} should be\n"
            "lower than or equal to the value of --html-high-threshold={}.",
            options.html_medium_threshold, options.html_high_threshold)
        sys.exit(1)

    if options.output is not None:
        options.output = os.path.abspath(options.output)

    if options.objdir is not None:
        if not options.objdir:
            logger.error(
                "empty --object-directory option.\n"
                "\tThis option specifies the path to the object file "
                "directory of your project.\n"
                "\tThis option cannot be an empty string.")
            sys.exit(1)
        tmp = options.objdir.replace('/', os.sep).replace('\\', os.sep)
        while os.sep + os.sep in tmp:
            tmp = tmp.replace(os.sep + os.sep, os.sep)
        if normpath(options.objdir) != tmp:
            logger.warn(
                "relative referencing in --object-directory.\n"
                "\tthis could cause strange errors when gcovr attempts to\n"
                "\tidentify the original gcc working directory.")
        if not os.path.exists(normpath(options.objdir)):
            logger.error(
                "Bad --object-directory option.\n"
                "\tThe specified directory does not exist.")
            sys.exit(1)

    options.starting_dir = os.path.abspath(os.getcwd())
    if not options.root:
        logger.error(
            "empty --root option.\n"
            "\tRoot specifies the path to the root "
            "directory of your project.\n"
            "\tThis option cannot be an empty string.")
        sys.exit(1)
    options.root_dir = os.path.abspath(options.root)

    #
    # Setup filters
    #

    # The root filter isn't technically a filter,
    # but is used to turn absolute paths into relative paths
    options.root_filter = re.compile(re.escape(options.root_dir + os.sep))

    if options.exclude_dirs is not None:
        options.exclude_dirs = [
            build_filter(logger, f) for f in options.exclude_dirs]

    options.exclude = [build_filter(logger, f) for f in options.exclude]
    options.filter = [build_filter(logger, f) for f in options.filter]
    if not options.filter:
        options.filter = [DirectoryPrefixFilter(options.root_dir)]

    options.gcov_exclude = [
        build_filter(logger, f) for f in options.gcov_exclude]
    options.gcov_filter = [
        build_filter(logger, f) for f in options.gcov_filter]
    if not options.gcov_filter:
        options.gcov_filter = [AlwaysMatchFilter()]

    # Output the filters for debugging
    for name, filters in [
        ('--root', [options.root_filter]),
        ('--filter', options.filter),
        ('--exclude', options.exclude),
        ('--gcov-filter', options.gcov_filter),
        ('--gcov-exclude', options.gcov_exclude),
        ('--exclude-directories', options.exclude_dirs),
    ]:
        logger.verbose_msg('Filters for {}: ({})', name, len(filters))
        for f in filters:
            logger.verbose_msg('- {}', f)

    # Get data files
    if not options.search_paths:
        options.search_paths = [options.root]

        if options.objdir is not None:
            options.search_paths.append(options.objdir)
    datafiles = get_datafiles(options.search_paths, options)

    # Get coverage data
    with Workers(options.gcov_parallel, lambda: {
                 'covdata': dict(),
                 'workdir': mkdtemp(),
                 'toerase': set(),
                 'options': options}) as pool:
        logger.verbose_msg("Pool started with {} threads", pool.size())
        for file_ in datafiles:
            if options.gcov_files:
                pool.add(process_existing_gcov_file, file_)
            else:
                pool.add(process_datafile, file_)
        contexts = pool.wait()

    covdata = dict()
    toerase = set()
    for context in contexts:
        for fname, cov in context['covdata'].items():
            if fname not in covdata:
                covdata[fname] = CoverageData(fname)
            covdata[fname].update(
                uncovered=cov.uncovered,
                uncovered_exceptional=cov.uncovered_exceptional,
                covered=cov.covered,
                branches=cov.branches,
                noncode=cov.noncode)
        toerase.update(context['toerase'])
        rmtree(context['workdir'])
    for filepath in toerase:
        if os.path.exists(filepath):
            os.remove(filepath)

    logger.verbose_msg("Gathered coveraged data for {} files", len(covdata))
    write_coveralls_json(covdata, options)

main()

