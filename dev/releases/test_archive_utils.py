import os
import stat

from utils import normalize_archive_permissions


def mode(path):
    return stat.S_IMODE(os.stat(path).st_mode)


def test_normalize_archive_permissions_removes_group_and_other_write_bits(tmp_path):
    package_dir = tmp_path / "pkg"
    package_dir.mkdir()
    private_dir = package_dir / "private"
    private_dir.mkdir()
    unreadable_dir = package_dir / "unreadable"
    unreadable_dir.mkdir()
    world_writable_file = package_dir / "data.g"
    world_writable_file.write_text("data", encoding="utf-8")
    executable_file = package_dir / "script.sh"
    executable_file.write_text("#!/bin/sh\n", encoding="utf-8")
    oddly_executable_file = package_dir / "odd.g"
    oddly_executable_file.write_text("data", encoding="utf-8")

    os.chmod(package_dir, 0o777)
    os.chmod(private_dir, 0o700)
    os.chmod(unreadable_dir, 0o600)
    os.chmod(world_writable_file, 0o666)
    os.chmod(executable_file, 0o777)
    os.chmod(oddly_executable_file, 0o654)

    normalize_archive_permissions(tmp_path)

    assert mode(package_dir) == 0o755
    assert mode(private_dir) == 0o755
    assert mode(unreadable_dir) == 0o755
    assert mode(world_writable_file) == 0o644
    assert mode(executable_file) == 0o755
    assert mode(oddly_executable_file) == 0o644
