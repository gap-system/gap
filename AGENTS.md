# AGENTS.md

This repository contains the core GAP system sources.

## AI disclosure

Any use of AI tools for preparing code, documentation, tests, commit messages,
pull requests, issue comments, or reviews for this repository must be
disclosed. Include a brief note saying which AI tool was used and what kind of
assistance it provided. Add the AI tool as a Git co-author on all commits
created by that tool (e.g. via an `Co-authored-by: ` line).

## Repository layout

Important top-level paths:

- `src/`: GAP kernel sources in C/C++.
- `lib/`: GAP library code.
- `tst/`: test suites, including `testinstall`, `teststandard`, `testextra`,
  and `testbugfix`.
- `doc/`: manual sources and generated documentation assets.
- `pkg/`: bundled GAP packages.
- `hpcgap/`: HPC-GAP sources and support files.
- `cnf/`, `configure.ac`, `autogen.sh`, `Makefile.rules`,
  `README.buildsys.md`: build system inputs and documentation.
- `dev/`: developer utilities and CI/release scripts.

## Generated files

Do not edit generated build outputs such as `configure` directly. For build
system changes, update the source inputs such as `configure.ac`, files in
`cnf/`, or related makefiles, then regenerate derived files with
`./autogen.sh` as needed. If you are working on the build system itself, read
`README.buildsys.md`.

## Common commands

Run all commands from the repository root.

### Build GAP

For a fresh git checkout, generate `configure` first:

```sh
./autogen.sh
./configure
make
```

If `configure` already exists and you just need to rebuild, use:

```sh
./configure
make
```

### Installing packages

If you need a package bundle for development or testing, bootstrap it with one
of:

```sh
make bootstrap-pkg-minimal
make bootstrap-pkg-full
```

### Working in a git worktree

A `git worktree` checkout has no `pkg` directory, so GAP started from it cannot
find any packages -- including the ones it needs in order to start at all. Do
not bootstrap a second package bundle for it; instead symlink the `pkg`
directory of your main GAP checkout, for example:

```sh
ln -s /path/to/your/main/gap/pkg pkg
```

This is needed in addition to the usual `./configure && make`.

### Build the manual

```sh
make html
```

### Run tests

Quick core test suite:
```sh
make check
```

Common direct test entry points:
```sh
./gap tst/testinstall.g
./gap tst/teststandard.g
./gap tst/testextra.g
./gap tst/testbugfix.g
```

To run a specific test file, pass it to `./gap`, for example:

```sh
./gap -q tst/testinstall/magma.tst -c 'QUIT;'
```

### REPL / break-loop output tests

Use `tst/testspecial/` for tests that exercise the interactive REPL,
break loops, or other output that depends on GAP's terminal handling.

- `./tst/testspecial/run_gap.sh ./gap tst/testspecial/<name>.g [outfile]`
  runs a single special test, captures combined output, prevents GAP from
  attaching to the terminal, and rewrites local paths in the transcript.
- From `tst/testspecial/`, `GAPDIR=../.. ./run_all.sh` runs the full special
  test suite.
- From `tst/testspecial/`, `./regenerate_tests.sh` regenerates all expected
  `.out` files.

## Commit messages and pull requests

When writing commit messages, use the title format `component: Brief summary`.
In the body, give a brief prose summary of the purpose of the change. Do not
specifically call out added tests, comments, documentation, and similar
supporting edits unless that is the main purpose of the change. Do not include
the test plan unless it differs from the instructions in this file. If the
change fixes one or more issues, add `Fixes #...` at the end of the commit
message body, not in the title.

Pull request descriptions should follow the same style: a short summary up top,
concise prose describing the change, issue references when applicable, and an
explicit AI-disclosure note if AI tools were used.

A pull request *title*, however, is not a commit title: for pull requests
labelled `release notes: use title` it is used verbatim as their release notes
entry. Write it as a self-contained sentence describing the change from a user
perspective, and in particular do not use the `component:` prefix there. See
`CHANGES.md` for the expected style, for example "Add `IsSquareMat` and
`IsAntisymmetricMat`" or "Speed up `IsSubset` for cyclotomic domains". Note
that GitHub derives the title of a pull request from the commit title if the
branch contains a single commit, so in that case the commit title should
already be written this way.

Pull requests should normally target `master`. Changes intended only for the
current stable release series may target `stable-4.X` when appropriate.


## Pull request labels

The script `dev/releases/release_notes.py` generates the release notes from the
merged pull requests and their labels, so every pull request should be labelled:

- exactly one `release notes: ...` label, stating what should happen with it:
  `use title` if its title can be used as the release notes entry as-is,
  `not needed` for changes irrelevant to users, `to be added` if an entry is
  needed but the title does not suffice, and additionally `highlight` for
  changes prominent enough to be listed at the very top;
- a `kind: ...` label, such as `kind: new feature`, `kind: enhancement` or one
  of the `kind: bug...` labels;
- one or more `topic: ...` labels naming the affected part of GAP, such as
  `topic: library`, `topic: kernel`, `topic: documentation` or
  `topic: performance`.

The `prioritylist` in `dev/releases/release_notes.py` maps labels to release
notes sections; a pull request is listed only in the section belonging to the
first matching label, so consult that list to see which label wins. Labels are
matched by their exact name, so take them from there or from `gh label list`
rather than guessing.


## Changelog

This project keeps a changelog in `CHANGES.md` but that is automatically
updated by scripts, based on pull request titles. So you don't need to
update it.
