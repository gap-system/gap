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

Pull requests should follow the same style: a short summary up top, concise
prose describing the change, issue references when applicable, and an explicit
AI-disclosure note if AI tools were used.

Pull requests should normally target `master`. Changes intended only for the
current stable release series may target `stable-4.X` when appropriate.


## Changelog

This project keeps a changelog in `CHANGES.md` but that is automatically
updated by scripts, based on pull request titles. So you don't need to
update it.
