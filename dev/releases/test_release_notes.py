import importlib.util
from pathlib import Path


def load_release_notes_module():
    module_path = Path(__file__).with_name("release_notes.py")
    spec = importlib.util.spec_from_file_location("release_notes", module_path)
    assert spec is not None
    assert spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_is_dependabot_pr_detects_dependabot_author():
    release_notes = load_release_notes_module()
    pr = {
        "author": {"is_bot": True, "login": "app/dependabot"},
        "labels": [
            {"name": "dependencies"},
            {"name": "github_actions"},
        ],
    }

    assert release_notes.is_dependabot_pr(pr)
