import release_notes

CHANGES_MD = """# GAP - history of changes

## GAP 4.13.1 (June 2024)

- something

## GAP 4.13.0 (March 2024)

- something else
"""


def write_changes(tmp_path, content=CHANGES_MD):
    path = tmp_path / "CHANGES.md"
    path.write_text(content, encoding="utf-8")
    return str(path)


def test_update_changes_md_inserts_new_section(tmp_path):
    path = write_changes(tmp_path)
    release_notes.update_changes_md(
        path, "4.14.0", "## GAP 4.14.0 (May 2026)\n\n- new\n"
    )
    assert open(path, encoding="utf-8").read() == """# GAP - history of changes

## GAP 4.14.0 (May 2026)

- new

## GAP 4.13.1 (June 2024)

- something

## GAP 4.13.0 (March 2024)

- something else
"""


def test_update_changes_md_is_idempotent(tmp_path):
    path = write_changes(tmp_path)
    section = "## GAP 4.14.0 (May 2026)\n\n- new\n"
    release_notes.update_changes_md(path, "4.14.0", section)
    once = open(path, encoding="utf-8").read()
    release_notes.update_changes_md(path, "4.14.0", section)
    assert open(path, encoding="utf-8").read() == once


def test_update_changes_md_replaces_existing_section(tmp_path):
    path = write_changes(tmp_path)
    release_notes.update_changes_md(
        path, "4.13.1", "## GAP 4.13.1 (June 2024)\n\n- rewritten\n"
    )
    content = open(path, encoding="utf-8").read()
    assert "- rewritten\n" in content
    assert "- something\n" not in content
    assert "- something else\n" in content


def test_update_changes_md_inserts_in_the_middle(tmp_path):
    path = write_changes(
        tmp_path,
        "# GAP - history of changes\n\n## GAP 4.13.1 (June 2024)\n\n- a\n\n"
        "## GAP 4.12.2 (December 2022)\n\n- b\n",
    )
    release_notes.update_changes_md(
        path, "4.13.0", "## GAP 4.13.0 (March 2024)\n\n- c\n"
    )
    content = open(path, encoding="utf-8").read()
    assert (
        content.index("## GAP 4.13.1")
        < content.index("## GAP 4.13.0")
        < content.index("## GAP 4.12.2")
    )


def test_update_changes_md_appends_oldest_section(tmp_path):
    path = write_changes(tmp_path)
    release_notes.update_changes_md(
        path, "4.12.2", "## GAP 4.12.2 (December 2022)\n\n- old\n"
    )
    content = open(path, encoding="utf-8").read()
    assert content.endswith("## GAP 4.12.2 (December 2022)\n\n- old\n")
    assert content.index("## GAP 4.13.0") < content.index("## GAP 4.12.2")


def test_update_changes_md_supersedes_prereleases(tmp_path):
    path = write_changes(tmp_path)
    release_notes.update_changes_md(
        path, "4.14.0-beta1", "## GAP 4.14.0-beta1 (April 2026)\n\n- beta1\n"
    )
    release_notes.update_changes_md(
        path, "4.14.0-beta2", "## GAP 4.14.0-beta2 (April 2026)\n\n- beta2\n"
    )
    content = open(path, encoding="utf-8").read()
    assert "beta1" not in content
    assert content.count("## GAP 4.14.0") == 1

    release_notes.update_changes_md(
        path, "4.14.0", "## GAP 4.14.0 (May 2026)\n\n- final\n"
    )
    content = open(path, encoding="utf-8").read()
    assert "beta" not in content
    assert content == """# GAP - history of changes

## GAP 4.14.0 (May 2026)

- final

## GAP 4.13.1 (June 2024)

- something

## GAP 4.13.0 (March 2024)

- something else
"""


def test_update_changes_md_keeps_neighbours_of_a_prerelease(tmp_path):
    path = write_changes(
        tmp_path,
        "# GAP - history of changes\n\n## GAP 4.13.1-beta1 (May 2024)\n\n- beta\n\n"
        "## GAP 4.13.0 (March 2024)\n\n- older\n",
    )
    release_notes.update_changes_md(
        path, "4.13.1", "## GAP 4.13.1 (June 2024)\n\n- final\n"
    )
    content = open(path, encoding="utf-8").read()
    assert "- older\n" in content
    assert content.index("## GAP 4.13.1 (June 2024)") < content.index("## GAP 4.13.0")


def test_parse_version_accepts_prereleases():
    assert release_notes.parse_version("4.13.1") == (4, 13, 1)
    assert release_notes.parse_version("4.13.1-beta1") == (4, 13, 1)
    assert release_notes.parse_version("4.13.0-rc2") == (4, 13, 0)


def test_is_dependabot_pr_detects_dependabot_author():
    pr = {
        "author": {"is_bot": True, "login": "app/dependabot"},
        "labels": [
            {"name": "dependencies"},
            {"name": "github_actions"},
        ],
    }

    assert release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"is_bot": True, "login": "app/notdependabot"},
        "labels": [
            {"name": "dependencies"},
            {"name": "github_actions"},
        ],
    }

    assert release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"is_bot": False, "login": "app/dependabot"},
        "labels": [
            {"name": "dependencies"},
            {"name": "github_actions"},
        ],
    }

    assert release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"is_bot": False, "login": "app/notdependabot"},
        "labels": [
            {"name": "dependencies"},
            {"name": "github_actions"},
        ],
    }

    assert not release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"is_bot": False, "login": "app/dependabot"},
        "labels": [
            {"name": "github_actions"},
        ],
    }

    assert release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"is_bot": False, "login": "app/notdependabot"},
        "labels": [
            {"name": "github_actions"},
        ],
    }

    assert not release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"is_bot": True, "login": "app/notdependabot"},
        "labels": [
            {"name": "github_actions"},
        ],
    }

    assert not release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"is_bot": False, "login": "dependabot[bot]"},
        "labels": [
            {"name": "github_actions"},
        ],
    }

    assert release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"login": "dependabot[bot]"},
        "labels": [
            {"name": "github_actions"},
        ],
    }

    assert release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"login": "app/notdependabot"},
        "labels": [
            {"name": "github_actions"},
        ],
    }

    assert not release_notes.is_dependabot_pr(pr)

    pr = {
        "author": {"login": "app/notdependabot"},
        "labels": [
            {"name": "dependencies"},
            {"name": "github_actions"},
        ],
    }

    assert not release_notes.is_dependabot_pr(pr)


def make_pr(number, title="", labels=(), body=""):
    return {
        "number": number,
        "title": title,
        "labels": [{"name": x} for x in labels],
        "body": body,
    }


def entries_of(pr):
    return [
        (e["title"], [x["name"] for x in e["labels"]])
        for e in release_notes.release_notes_entries(pr)
    ]


def test_release_notes_entries_use_title():
    pr = make_pr(1, "Fix `Foo`", ["release notes: use title", "kind: bug"])
    assert entries_of(pr) == [("Fix `Foo`", ["release notes: use title", "kind: bug"])]
    assert entries_of(make_pr(1, "Fix `Foo`", ["kind: bug"])) == []


def test_release_notes_entries_use_body():
    body = (
        "Summary\r\n\r\n## Text for release notes\r\n\r\n"
        "- Fix `Foo` {kind: bug}\r\n"
        "* Speed up `Bar` for\r\n"
        "  large groups {topic: performance, release notes: highlight}\r\n"
        "- Document `Baz`\r\n\r\n"
        "Not an entry\r\n\r\n"
        "## Further details\r\n\r\n- not an entry either\r\n"
    )
    pr = make_pr(7, "ignored", ["release notes: use body", "kind: bug"], body)
    assert entries_of(pr) == [
        ("Fix `Foo`", ["kind: bug"]),
        (
            "Speed up `Bar` for large groups",
            ["topic: performance", "release notes: highlight"],
        ),
        ("Document `Baz`", ["release notes: use body", "kind: bug"]),
    ]


def test_release_notes_entries_accepts_oscar_heading():
    pr = make_pr(7, "", ["release notes: use body"], "## Release Notes\n- Fix `Foo`\n")
    assert entries_of(pr) == [("Fix `Foo`", ["release notes: use body"])]


def test_release_notes_section_sorts_body_entries(monkeypatch):
    monkeypatch.setattr(release_notes, "package_updates", lambda out, version: None)
    body = (
        "## Text for release notes\n\n"
        "- Fix `Foo` {kind: bug}\n"
        "- Speed up `Bar` {topic: performance}\n"
    )
    prs = [
        make_pr(2, "Add `Qux`", ["release notes: use title", "kind: new feature"]),
        make_pr(1, "ignored", ["release notes: use body"], body),
    ]
    section = release_notes.release_notes_section(prs, "4.14.0")
    assert section.endswith("""### New features

- [#2](https://github.com/gap-system/gap/pull/2) Add `Qux`

### Performance improvements

- [#1](https://github.com/gap-system/gap/pull/1) Speed up `Bar`

### Other fixed bugs

- [#1](https://github.com/gap-system/gap/pull/1) Fix `Foo`
""")


def test_body_problem():
    labels = ["release notes: use body"]
    assert release_notes.body_problem(make_pr(1, "", labels, "")) == "no entries"
    body = "## Text for release notes\n\nsee title\n"
    assert release_notes.body_problem(make_pr(1, "", labels, body)) == "no entries"
    body = (
        "## Text for release notes\n\n- Fix `Foo` {kind: bug, kind:bug}\n- Fix `Bar`\n"
    )
    assert (
        release_notes.body_problem(make_pr(1, "", labels, body))
        == "labels not in prioritylist: kind:bug"
    )
    body = "## Text for release notes\n\n- Fix `Foo` {kind: bug}\n- Fix `Bar`\n"
    assert release_notes.body_problem(make_pr(1, "", labels, body)) == ""
