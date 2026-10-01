import datetime as dt

import package_changes

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
        "invalid date: ## 0.8 (2025-20-06)",
        "not a release header: ## 0.7 and earlier",
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
