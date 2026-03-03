# Julia GC Handoff

This file records the local Julia prerequisite for the GAP precise-GC work.
Until the Julia-side work is published somewhere durable, this file is the
source of truth for finding the Julia checkout used by this project.

## Local Convention

The local convention is that `dev/julia` is a symlink to the patched Julia
checkout used for this work.

All Julia commands documented in this GAP repository assume that `dev/julia`
exists and points to that checkout.

`dev/julia` is a local convenience path and should not be committed. Its target
may vary from machine to machine.

On the current machine, a known working target is
`/Users/mhorn/Projekte/Julia/julia.spielwiese`, but that is only an example,
not a required path.

## Expected Julia State

The current expected Julia checkout state is:

- branch: `codex/precise-julia-gc-for-gap`
- tip commit: `380505b20a2da26adc4dcb5d9b84dd3bd69674a1`
- upstream: none configured; this branch is intentionally local-only for now

The current Julia-side commits this GAP work depends on are:

- `380505b20a Teach GC checker about GAP bag types`
- `b50a6f9e12 Skip tagged immediates in JL_GC_PUSH roots`

If the Julia-side branch moves, update the branch name, tip commit, and commit
list here.

## Julia Build and Analyzer Commands

Build Julia's GC analyzer plugin with:

```sh
make -C dev/julia/src clangsa
```

This project currently assumes that both a normal Julia build and a debug Julia
build already exist under the checkout reached via `dev/julia`, and that the
GC analyzer plugin has been built there before GAP analyzer runs are attempted.

The GAP-side analyzer helper script is:

```sh
dev/run-julia-gc-analyzer.sh BUILD_DIR SOURCE
```

Example:

```sh
JULIA_GC_ANALYZER_CHECKERS=julia.GCChecker \
  dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev src/objects.c
```

## GAP Build Integration

The currently used out-of-tree GAP build directories are:

- `out-of-tree/julia-dev`
- `out-of-tree/julia-dev-debug`

These builds are expected to be configured against the Julia checkout reached
via `dev/julia`.

The fast Julia-side rebuild workflow for analyzer work is currently:

```sh
make -C dev/julia/src clangsa
make -C out-of-tree/julia-dev -j4
make -C out-of-tree/julia-dev-debug -j4
```

When running the analyzer, compile GAP first, then analyze one translation unit
at a time with `dev/run-julia-gc-analyzer.sh`.

## Files To Exclude For Julia-GC Analyzer Work

The following files are currently out of scope for the Julia-GC analyzer pass
because they are tied to alternative GC backends or configurations that are not
used in the Julia-GC build:

- `src/boehm_gc.c`
- `src/gasman.c`
- `src/hpc/*`
- `src/sysmem.c`

Do not spend migration effort on these files unless the Julia-GC integration
changes to require them.

## Live GAP Status

This section is intentionally mutable. Keep it up to date as analyzer work and
runtime validation progress.

### Known Analyzer-Clean Files

The following translation units have been confirmed analyzer-clean on this
branch state:

- `src/ariths.c`
- `src/bags.c`
- `src/bool.c`
- `src/finfield.c`
- `src/gaptime.c`
- `src/iostream.c`
- `src/precord.c`
- `src/records.c`
- `src/range.c`
- `src/scanner.c`
- `src/sha256.c`
- `src/symbols.c`
- `src/sysroots.c`
- `src/vecffe.c`
- `src/weakptr.c`

### Recently Rechecked

These files were rechecked after the rollback of the incorrect `RetypeBag`
contract changes and subsequent unwind/runtime fixes:

- `src/ariths.c`: clean
- `src/bags.c`: clean
- `src/bool.c`: clean
- `src/finfield.c`: clean
- `src/gaptime.c`: clean
- `src/iostream.c`: clean
- `src/precord.c`: clean
- `src/range.c`: clean
- `src/records.c`: clean
- `src/scanner.c`: clean
- `src/sha256.c`: clean
- `src/symbols.c`: clean
- `src/sysroots.c`: clean
- `src/vecffe.c`: clean
- `src/weakptr.c`: clean

### Needs Recheck

No currently tracked files are waiting for recheck from the reverted
`RetypeBag` contract changes.

### Known Analyzer-Dirty Files

This list is only a pointer to known work items, not a full inventory.

- `src/julia_gc.c`
  - currently expected to stay dirty in stack-scanning code until that path is
    disabled or otherwise revised

### Known Runtime Regressions

- An earlier `RetypeBag` contract widening was wrong and had to be backed out.
  Re-run analyzer checks for previously clean files after that rollback.
- Julia-GC stack frames now unwind correctly across GAP error handling after
  saving/restoring the GC stack in `GAP_TRY` and `TRY_IF_NO_ERROR`.
- `make -C out-of-tree/julia-dev check` currently passes with `0 failures in
  301 files`.

## Working GAP Commands

The following commands are known-good on the current machine and are worth
reusing verbatim before trying ad hoc variants.

Minimal smoke test:

```sh
./gap -q -A -b -c 'QUIT_GAP(0);'
```

Single translation unit analyzer examples:

```sh
JULIA_GC_ANALYZER_CHECKERS=julia.GCChecker \
  dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev src/julia_gc.c
```

```sh
JULIA_GC_ANALYZER_CHECKERS=julia.GCChecker \
  dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev src/compiler.c
```

Full Julia-GC rebuild:

```sh
make -C out-of-tree/julia-dev -j4
```

Base test suite:

```sh
make -C out-of-tree/julia-dev check
```

Current status as of this branch state:

- the smoke command above succeeds,
- analyzer runs for `src/julia_gc.c`, `src/compiler.c`, `src/objects.c`,
  `src/lists.c`, `src/set.c`, and `src/range.c` succeed,
- `make -C out-of-tree/julia-dev check` passes.

Known pitfall:

- Do not assume GAP CLI modes are interchangeable for scripted reproductions.
  In particular, my ad hoc attempts to feed `.tst` files through improvised
  `-r` or stdin workflows produced misleading
  `Variable: 'gap' must have a value` errors that were not the real bug under
  investigation. Prefer the known-good commands above unless and until the
  exact GAP CLI semantics are re-checked.

## Refresh Checklist

When the Julia-side work changes:

- update the branch name here if it changed
- update the expected tip commit here
- update the short Julia commit list here
- update any Julia build or analyzer command differences here

If only the local symlink target changes, no repo change is needed unless the
commands or assumptions in this file also change.
