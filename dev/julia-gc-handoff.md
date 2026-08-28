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

- branch: `mh/precise-julia-gc-for-gap`
- tip commit: `1b50352c1d`
- rebased onto upstream `origin/master` at `7e75a8061a`
- upstream: none configured; this branch is intentionally local-only for now

The current Julia-side commits this GAP work depends on are:

- `611d5a73e7 Skip tagged immediates in JL_GC_PUSH roots`
- `8dd8a5b6a1 Teach GC checker about GAP bag types`
- `1b50352c1d clangsa: Preserve caller GC frames on noreturn`

Only the first of these is needed at run time; the other two only affect the
static analyzer. The run-time one has no upstream equivalent yet, so GAP.jl
cannot use a released Julia until it lands.

If the Julia-side branch moves, update the branch name, tip commit, and commit
list here.

## Julia Build and Analyzer Commands

The analyzer runs with the `clang` from Julia's optional analysis
dependencies, which must match the LLVM version Julia itself is built against.
Julia moved to LLVM 22 in the range this branch was rebased over, so after a
rebase install the matching tooling before rebuilding the plugin:

```sh
make -C dev/julia/src install-analysis-deps
```

A version mismatch shows up as a `dyld` "Symbol not found" error naming
`libclang-cpp.dylib` and `libLLVM.dylib` when the analyzer starts.

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

### Analyzer Sweep

Instead of a hand-maintained list of clean files, sweep the whole in-scope tree:

```sh
dev/run-julia-gc-analyzer-all.sh out-of-tree/julia-dev
```

It analyzes every `src/*.c` and `src/*.cc` except the files listed above, writes
one log per translation unit into `gc-analysis/`, lists the failures in
`gc-analysis/failed`, and exits non-zero if anything was reported. Keep a copy
of the log directory to diff a later run against.

The logs carry ANSI colour codes, so read one with:

```sh
sed 's/\x1b\[[0-9;]*m//g' gc-analysis/NAME.log | grep -E 'error:|warning:'
```

The first-declaration check is a separate, cheaper pass. Julia annotations that
sit on a later declaration are silently ignored by clang, so run its clang-tidy
check over GAP too. It needs the plugin built by `make -C src clangsa` in the
Julia checkout:

```sh
dev/run-first-decl-check.sh out-of-tree/julia-dev src/julia_gc.c
dev/run-first-decl-check.sh out-of-tree/julia-dev src/*.c src/*.cc
```

It also reports GAP functions assigned to a Julia callback type that requires
`JL_NOTSAFEPOINT` without carrying the annotation themselves.

None of these scripts is tied to a particular checkout: each reads the compile
flags from the given build directory and locates the Julia tree, clang, and the
analyzer plugins from the `-I` flag recorded there. Override any of it with
`JULIA_INCLUDE_DIR`, `JULIA_GC_ANALYZER_CLANG`, `JULIA_GC_ANALYZER_PLUGIN`,
`JULIA_CLANG_TIDY` or `JULIA_FIRST_DECL_PLUGIN`.

### Safepoint Annotations

`GAP_GC_CANSAFEPOINT` and its ENTER/LEAVE variants feed Clang Thread Safety
Analysis, the counterpart to Julia's `make -C src safesrc`. Run it with:

```sh
dev/run-safepoint-check.sh out-of-tree/julia-dev src/FILE.c
```

Unlike the GC checker this analysis has no implicit default: a function that
reaches a safepoint must say so, and is flagged as soon as it calls a
`GAP_GC_CANSAFEPOINT` function without being one itself. The kernel is
annotated for it. The GC checker's own model, where an unannotated function is
assumed to be a safepoint and `GAP_GC_NOTSAFEPOINT` opts out, is unaffected
and remains the one the rooting work relies on.

Both annotations may never sit on the same declaration. If the analysis wants
`GAP_GC_CANSAFEPOINT` on something already promising `GAP_GC_NOTSAFEPOINT`,
one of the two is wrong; do not add the second. The panic path in `system.h`
shows the third option: a function that never returns promises callers no
safepoint, while its own body opts out of the analysis with
`GAP_GC_NO_SAFEPOINT_ANALYSIS`.

### Status

As of 2026-08-28, against Julia `1b50352c1d`:

- all 77 in-scope translation units are analyzer-clean,
- the first-declaration check is clean,
- the safepoint check is clean,
- `make -C out-of-tree/julia-dev check` passes with `0 failures in 318 files`.

Still outstanding: switching GAP off the Julia GC's stack scanner add-on and
onto exact stack scanning, and carrying the same work into the packages that
ship kernel extensions.

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

See the Live GAP Status section above for the current sweep results.

Known pitfall:

- Use `GAP_GC_PUSH1` through `GAP_GC_PUSH9` for GAP `Obj` locals that may hold
  tagged immediate values. These fixed-arity frames store addresses of locals,
  and the patched Julia scanner skips tagged immediates while reading them.
  `JL_GC_PUSHARGS` stores values directly and uses Julia-specific low-bit tag
  semantics, so `GAP_GC_PUSHARGS` must not be used for arrays that can contain
  GAP immediate values. `src/vecgf2.c` is the one remaining `GAP_GC_PUSHARGS`
  user; its roots are all bags, never immediates.
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
