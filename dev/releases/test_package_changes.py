import datetime as dt

import package_changes
import pytest

CHANGES_MD = """This file describes changes in the example package.

## Unreleased

- pending

## 1.2 (2026-01-02)

- added `Foo`

### Fixed

- bar

## 1.1 (2025-11)

## 1.0

## 0.9 (never released)

## 0.8 (2025-20-06)

## 0.7 and earlier
"""

PACKAGE_INFO = """SetPackageInfo( rec(
PackageName := "Example",
Version := "1.3",
Date := "15/02/2026",
));
"""


def test_parse():
    log = package_changes.parse(CHANGES_MD, "example")
    got = [(r.version, r.date, r.precision) for r in log.releases]
    assert got == [
        (None, None, "unreleased"),
        ("1.2", dt.date(2026, 1, 2), "day"),
        ("1.1", dt.date(2025, 11, 1), "month"),
        ("1.0", None, "none"),
        ("0.9", None, "never released"),
        ("0.8", None, "none"),
    ]
    assert log.releases[1].notes == "- added `Foo`\n\n### Fixed\n\n- bar"
    assert log.problems == [
        "not a release header: ## 0.7 and earlier",
        "invalid date: ## 0.8 (2025-20-06)",
    ]


def test_in_window_month_counts_only_if_whole_month_is_after():
    log = package_changes.parse(CHANGES_MD)
    in_window = package_changes.in_window

    def versions(since):
        return [r.version for r in log.releases if in_window(r, since, None)]

    assert versions(dt.date(2025, 10, 15)) == ["1.2", "1.1"]
    assert versions(dt.date(2025, 11, 15)) == ["1.2"]
    assert versions(dt.date(2026, 1, 2)) == []


def test_select_adds_release_missing_from_changes(tmp_path):
    repo = tmp_path / "example"
    repo.mkdir()
    (repo / "PackageInfo.g").write_text(PACKAGE_INFO, encoding="utf-8")
    (repo / "CHANGES.md").write_text(CHANGES_MD, encoding="utf-8")

    [log] = package_changes.load_all(tmp_path)
    assert log.package == "Example"
    rels = package_changes.select(log, dt.date(2025, 12, 1), None)
    assert [(r.version, r.notes) for r in rels] == [
        ("1.3", ""),
        ("1.2", "- added `Foo`\n\n### Fixed\n\n- bar"),
    ]


def test_markdown_demotes_headings_in_notes():
    log = package_changes.parse(CHANGES_MD, "example")
    text = package_changes.markdown(
        [(log, [log.releases[1]])], dt.date(2025, 12, 1), None
    )
    assert "## example\n\n### 1.2 (2026-01-02)\n\n- added `Foo`" in text
    assert "\n#### Fixed\n" in text


@pytest.mark.parametrize(
    "names, expected",
    [
        (["README.md", "ChangeLog", "CHANGES.md"], "CHANGES.md"),
        (["CHANGES", "CHANGELOG.md"], "CHANGES"),
        (["Changelog"], "Changelog"),
        (["changes.txt", "LICENSE"], "changes.txt"),
        (["NEWS", "HISTORY.md"], "NEWS"),
        (["history.md"], "history.md"),
        (["CHANGES.html", "changes24-28.txt", "README"], None),
    ],
)
def test_find_changelog(names, expected):
    assert package_changes.find_changelog(names) == expected


def test_load_all_reads_other_file_names(tmp_path):
    repo = tmp_path / "example"
    repo.mkdir()
    (repo / "PackageInfo.g").write_text(PACKAGE_INFO, encoding="utf-8")
    (repo / "ChangeLog").write_text("## 1.3 (2026-02-15)\n\n- x\n", encoding="utf-8")

    [log] = package_changes.load_all(tmp_path)
    assert [(r.version, r.notes) for r in log.releases] == [("1.3", "- x")]
    assert log.problems == []


# headers of older formats still in use, each with (version, date, precision)
OLD_HEADERS = [
    ("1.2.3 (2026-08-12)", "1.2.3", dt.date(2026, 8, 12), "day"),
    ("# 1.2.3 (2026-08-12)", "1.2.3", dt.date(2026, 8, 12), "day"),
    ("Version 3.3.3 (2025-11-25)", "3.3.3", dt.date(2025, 11, 25), "day"),
    ("Version 4.4.1: 2025-06-20", "4.4.1", dt.date(2025, 6, 20), "day"),
    ("Version 4.3.2: 2022/08/01", "4.3.2", dt.date(2022, 8, 1), "day"),
    ("- Version 1.57 (2024-07-07):", "1.57", dt.date(2024, 7, 7), "day"),
    ("* 1.27 (2022-08-09)", "1.27", dt.date(2022, 8, 9), "day"),
    ("- Version 1.8.2, 01/10/2019", "1.8.2", dt.date(2019, 10, 1), "day"),
    (" Version 0.7.2  (25/02/25)", "0.7.2", dt.date(2025, 2, 25), "day"),
    ("## Version 0.3 (released 22/10/2022)", "0.3", dt.date(2022, 10, 22), "day"),
    (
        "## Version 1.84 for GAP 4.16.1 (10/09/26)",
        "1.84",
        dt.date(2026, 9, 10),
        "day",
    ),
    ("## 2.98 -> 2.99 (19/08/2026)", "2.99", dt.date(2026, 8, 19), "day"),
    (
        "## 2.49 -> 2.51 for GAP 4.16.0 (06/08/26)",
        "2.51",
        dt.date(2026, 8, 6),
        "day",
    ),
    ("1.16 -> 1.17", "1.17", None, "none"),
    ("Changes v4.0 -> 4.1", "4.1", None, "none"),
    ("Changes from 1.3.2 to 1.3.3", "1.3.3", None, "none"),
    ("Changes from version 1.36 to 1.37:", "1.37", None, "none"),
    ("Changes for 1.1.0 (2024-08-29)", "1.1.0", dt.date(2024, 8, 29), "day"),
    (
        "Main changes from GRAPE 4.9.2 to GRAPE 4.9.3 (06 September 2025)",
        "4.9.3",
        dt.date(2025, 9, 6),
        "day",
    ),
    (
        "Main changes from DESIGN 1.8.1 to DESIGN 1.8.2 (November 2024)",
        "1.8.2",
        dt.date(2024, 11, 1),
        "month",
    ),
    (
        "## Changes between RCWA 4.10.0 and RCWA 4.10.1 (September 8, 2026):",
        "4.10.1",
        dt.date(2026, 9, 8),
        "day",
    ),
    ("Version 3.21 (2-2026)", "3.21", dt.date(2026, 2, 1), "month"),
    ("## [v1.2.4] - 2026-04-28", "1.2.4", dt.date(2026, 4, 28), "day"),
    ("Version 2.3.11", "2.3.11", None, "none"),
    ("0.2.5", "0.2.5", None, "none"),
    ("v1.1.0", "1.1.0", None, "none"),
    ("Version 3.4.0 (unreleased)", "3.4.0", None, "unreleased"),
    ("## 1.32 -> 1.32dev (16/03/26)", "1.32dev", None, "unreleased"),
]


@pytest.mark.parametrize("header, version, date, precision", OLD_HEADERS)
def test_parse_old_header(header, version, date, precision):
    log = package_changes.parse(f"Some preamble.\n\n{header}\n  - a change\n")
    assert [(r.version, r.date, r.precision) for r in log.releases] == [
        (version, date, precision)
    ]
    assert log.releases[0].notes == "- a change"


@pytest.mark.parametrize(
    "line",
    [
        "This file describes changes in the example package.",
        "  1.2.3 (2026-08-12)",
        "- Changes in DotSplash due to viz.js reallocation",
        "Changes in function names:",
        "- 2.0 is twice as fast",
        "version 2 or higher.",
        "4.5, the interface between GRAPE and dreadnaut is now done entirely in",
        "===============",
    ],
)
def test_parse_old_format_ignores_other_lines(line):
    log = package_changes.parse(f"1.0 (2020-01-02)\n  - a\n{line}\n")
    assert [r.version for r in log.releases] == ["1.0"]


def test_parse_old_format_file():
    text = """=============
 Version 0.4.0  (30/08/2024)
=============
- first
- second
=============
 Version 0.3.0  (03/06/2022)
=============
    * third
      continued
"""
    log = package_changes.parse(text)
    got = [(r.version, r.date, r.notes) for r in log.releases]
    assert got == [
        ("0.4.0", dt.date(2024, 8, 30), "- first\n- second"),
        ("0.3.0", dt.date(2022, 6, 3), "* third\n  continued"),
    ]
    assert log.problems == []


def test_new_format_is_not_read_as_old():
    # in the current format, only `## ` lines are release headers
    text = "## 1.1 (2026-01-02)\n\n- Version 1.0 (2020-01-01):\n1.0 (2020-01-01)\n"
    log = package_changes.parse(text)
    assert [r.version for r in log.releases] == ["1.1"]


def test_select_sorts_newest_first():
    log = package_changes.parse("1.0 (2026-01-02)\n- a\n\n1.1 (2026-02-03)\n- b\n")
    rels = package_changes.select(log, dt.date(2025, 1, 1), None)
    assert [r.version for r in rels] == ["1.1", "1.0"]


def test_load_all_dates_current_release_from_package_info(tmp_path):
    repo = tmp_path / "example"
    repo.mkdir()
    (repo / "PackageInfo.g").write_text(PACKAGE_INFO, encoding="utf-8")
    (repo / "CHANGES").write_text(
        "Version 1.3\n  - new\n\nVersion 1.2\n  - old\n", encoding="utf-8"
    )

    [log] = package_changes.load_all(tmp_path)
    got = [(r.version, r.date, r.precision) for r in log.releases]
    assert got == [("1.3", dt.date(2026, 2, 15), "day"), ("1.2", None, "none")]
    rels = package_changes.select(log, dt.date(2026, 1, 1), None)
    assert [(r.version, r.notes) for r in rels] == [("1.3", "- new")]
