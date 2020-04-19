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

import os
import re
import sys
import io
import json  # added for GAP
import mmap  # added for GAP
import hashlib  # added for GAP

from argparse import ArgumentParser
from os.path import normpath
from tempfile import mkdtemp
from shutil import rmtree

from gcovr.configuration import (
    argument_parser_setup, merge_options_and_set_defaults,
    parse_config_file, parse_config_into_dict, OutputOrDefault)
from gcovr.gcov import (find_existing_gcov_files, find_datafiles,
                   process_existing_gcov_file, process_datafile)
from gcovr.json_generator import (gcovr_json_files_to_coverage)
from gcovr.utils import (get_global_stats, AlwaysMatchFilter,
                    DirectoryPrefixFilter, Logger)
from gcovr.version import __version__
from gcovr.workers import Workers

# generators
# from .cobertura_xml_generator import print_xml_report
# from .html_generator import print_html_report
# from .txt_generator import print_text_report
# from .summary_generator import print_summary
# from .sonarqube_generator import print_sonarqube_report
# from .json_generator import print_json_report

# BEGIN GAP MOD
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

        for line in sorted(data.lines):
            line_cov = data.lines[line]
            if not line_cov.is_covered and not line_cov.is_uncovered:
                continue
            hits = line_cov.count
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

# END GAP MOD

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


def create_argument_parser():
    """Create the argument parser."""

    parser = ArgumentParser(add_help=False)
    parser.usage = "gcovr [options] [search_paths...]"
    parser.description = \
        "A utility to run gcov and summarize the coverage in simple reports."

    parser.epilog = "See <http://gcovr.com/> for the full manual."

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

    argument_parser_setup(parser, options)

    return parser


COPYRIGHT = (
    "Copyright 2013-2018 the gcovr authors\n"
    "Copyright 2013 Sandia Corporation\n"
    "Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,\n"
    "the U.S. Government retains certain rights in this software."
)


def find_config_name(partial_options):
    cfg_name = getattr(partial_options, 'config', None)
    if cfg_name is not None:
        return cfg_name

    root = getattr(partial_options, 'root', '')
    if root:
        cfg_name = os.path.join(root, 'gcovr.cfg')
    else:
        cfg_name = 'gcovr.cfg'

    if os.path.isfile(cfg_name):
        return cfg_name

    return None


class Options(object):
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)


def main(args=None):
    parser = create_argument_parser()
    cli_options = parser.parse_args(args=args)

    # load the config
    cfg_name = find_config_name(cli_options)
    cfg_options = {}
    if cfg_name is not None:
        with io.open(cfg_name, encoding='UTF-8') as cfg_file:
            cfg_options = parse_config_into_dict(
                parse_config_file(cfg_file, filename=cfg_name))

    options_dict = merge_options_and_set_defaults(
        [cfg_options, cli_options.__dict__])
    options = Options(**options_dict)

    logger = Logger(options.verbose)

    if cli_options.version:
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
            f.build_filter(logger) for f in options.exclude_dirs]

    options.exclude = [f.build_filter(logger) for f in options.exclude]
    options.filter = [f.build_filter(logger) for f in options.filter]
    if not options.filter:
        options.filter = [DirectoryPrefixFilter(options.root_dir)]

    options.gcov_exclude = [
        f.build_filter(logger) for f in options.gcov_exclude]
    options.gcov_filter = [f.build_filter(logger) for f in options.gcov_filter]
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

    covdata = dict()
    if options.add_tracefile:
        collect_coverage_from_tracefiles(covdata, options, logger)
    else:
        collect_coverage_from_gcov(covdata, options, logger)

    logger.verbose_msg("Gathered coveraged data for {} files", len(covdata))

    # BEGIN GAP MOD
    logger.verbose_msg("e {} files", len(covdata))
    write_coveralls_json(covdata, options)
    # Print reports
    #print_reports(covdata, options, logger)

    #if options.fail_under_line > 0.0 or options.fail_under_branch > 0.0:
    #    fail_under(covdata, options.fail_under_line, options.fail_under_branch)
    # END GAP MOD


def collect_coverage_from_tracefiles(covdata, options, logger):
    datafiles = set()

    for trace_file in options.add_tracefile:
        if not os.path.exists(normpath(trace_file)):
            logger.error(
                "Bad --add-tracefile option.\n"
                "\tThe specified file does not exist.")
            sys.exit(1)
        datafiles.add(trace_file)
    options.root_dir = os.path.abspath(options.root)
    gcovr_json_files_to_coverage(datafiles, covdata, options)


def collect_coverage_from_gcov(covdata, options, logger):
    datafiles = set()

    find_files = find_datafiles
    process_file = process_datafile
    if options.gcov_files:
        find_files = find_existing_gcov_files
        process_file = process_existing_gcov_file

    # Get data files
    if not options.search_paths:
        options.search_paths = [options.root]

        if options.objdir is not None:
            options.search_paths.append(options.objdir)

    for search_path in options.search_paths:
        datafiles.update(find_files(search_path, logger, options.exclude_dirs))

    # Get coverage data
    with Workers(options.gcov_parallel, lambda: {
                 'covdata': dict(),
                 'workdir': mkdtemp(),
                 'toerase': set(),
                 'options': options}) as pool:
        logger.verbose_msg("Pool started with {} threads", pool.size())
        for file_ in datafiles:
            pool.add(process_file, file_)
        contexts = pool.wait()

    toerase = set()
    for context in contexts:
        for fname, cov in context['covdata'].items():
            if fname not in covdata:
                covdata[fname] = cov
            else:
                covdata[fname].update(cov)
        toerase.update(context['toerase'])
        rmtree(context['workdir'])
    for filepath in toerase:
        if os.path.exists(filepath):
            os.remove(filepath)


def print_reports(covdata, options, logger):
    reports_were_written = False
    default_output = OutputOrDefault(options.output)

    generators = []

    generators.append((
        lambda: options.xml or options.prettyxml,
        [options.xml],
        print_xml_report,
        lambda: logger.warn(
            "Cobertura output skipped - "
            "consider providing an output file with `--xml=OUTPUT`.")))

    generators.append((
        lambda: options.html or options.html_details,
        [options.html, options.html_details],
        print_html_report,
        lambda: logger.warn(
            "HTML output skipped - "
            "consider providing an output file with `--html=OUTPUT`.")))

    generators.append((
        lambda: options.sonarqube,
        [options.sonarqube],
        print_sonarqube_report,
        lambda: logger.warn(
            "Sonarqube output skipped - "
            "consider providing output file with `--sonarqube=OUTPUT`.")))

    generators.append((
        lambda: options.json or options.prettyjson,
        [options.json],
        print_json_report,
        lambda: logger.warn(
            "JSON output skipped - "
            "consider providing output file with `--json=OUTPUT`.")))

    generators.append((
        lambda: not reports_were_written,
        [],
        print_text_report,
        lambda: None))

    for should_run, output_choices, generator, on_no_output in generators:
        if should_run():
            output = OutputOrDefault.choose(output_choices,
                                            default=default_output)
            if output is default_output:
                default_output = None
            if output is not None:
                generator(covdata, output.value, options)
                reports_were_written = True
            else:
                on_no_output()

    if default_output is not None and default_output.value is not None:
        logger.warn("--output={!r} option was provided but not used.",
                    default_output.value)

    if options.print_summary:
        print_summary(covdata)


if __name__ == '__main__':
    main()
