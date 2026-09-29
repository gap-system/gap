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
