import release_notes


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
