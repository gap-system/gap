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
- tip commit: `bf12152801`
- rebased onto upstream `origin/master` at `c1b783ae21`
- upstream: none configured; this branch is intentionally local-only for now

The current Julia-side commits this GAP work depends on are:

- `7ba07bc397 clangsa: Mark GC-tracked types with an attribute`
- `3f93c78ca9 Skip tagged immediates in JL_GC_PUSH roots`
- `bf12152801 clangsa: Annotate the remaining GC-managed types`

Only the second is needed at run time; the other two only affect the static
analyzer. The run-time one has no upstream equivalent yet, so GAP.jl cannot
use a released Julia until it lands. GAP marks `struct OpaqueBag` with
`JL_GC_TRACKED_TYPE` (as `GAP_GC_TRACKED_TYPE`), so no checker patch naming
GAP's types is needed any more.

If the Julia-side branch moves, update the branch name, tip commit, and commit
list here.

## Julia Build and Analyzer Commands

After a full Julia rebuild that picked up a new LLVM (upstream bumps it
regularly), the clang headers the checker plugin needs are gone until the
analysis dependencies are reinstalled; without that `make -C src clangsa`
fails with `clang/AST/ParentMapContext.h file not found`, and the failed
rebuild removes the old plugin, so GAP's analyzer sweep stops working too:

```sh
make -C src install-analysis-deps
make -C src clangsa
```

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
dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev src/julia_gc.c
```

```sh
dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev src/compiler.c
```

Do not narrow `JULIA_GC_ANALYZER_CHECKERS` to `julia.GCChecker` alone: without
`core` the checker cannot see that a call does not return, and reports
missing pops in every function that raises an error.

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
  GAP immediate values. The `GAP_GC_PUSHARGS` users are `src/vecgf2.c` and the
  type array in `DoOperationNArgs` (`src/opers.cc`); their roots are all bags,
  never immediates.
- Do not assume GAP CLI modes are interchangeable for scripted reproductions.
  In particular, my ad hoc attempts to feed `.tst` files through improvised
  `-r` or stdin workflows produced misleading
  `Variable: 'gap' must have a value` errors that were not the real bug under
  investigation. Prefer the known-good commands above unless and until the
  exact GAP CLI semantics are re-checked.

## GC Stress Mode and Dead-Reference Diagnostics

A rooting bug under a precise collector only shows when a collection lands
in its window, so the suite passes most runs and crashes elsewhere on the
others. Memory checking removes the luck: every bag allocation collects.

Build:

```sh
../../configure --with-gc=julia --with-julia=$JULIA \
  --enable-memory-checking --enable-debug \
  CFLAGS="-g -O2 -DDISABLE_STACK_SCAN" CXXFLAGS="-g -O2 -DDISABLE_STACK_SCAN"
```

`CFLAGS=` given to configure replaces GAP's default `-g -O2` rather than
adding to it; always spell the defaults out.

`GASMAN_MEM_CHECK(n)` collects at every `n`th allocation, `0` turns it off.
Period 1 cannot get through library loading; start GAP normally and enable
it around the workload. Period 1000 gets through `testinstall` in hours.
Smaller periods find more but which allocations get sampled depends on the
period, so a failure at one period can pass at another.

Known reproducer of the class of bug this finds:

```sh
./gap -q -A -T -c 'GASMAN_MEM_CHECK(37); Irr(SmallGroup(240,109)); QUIT_GAP(0);'
```

This failed deterministically at period 37 and passed at 100 and 1000. It
was `Remove(list)` returning an element it had already let die, fixed in
`src/listfunc.c`.

A second one, from the same family, at period 1:

```
keys := List([1..40], i -> (i*7919) mod 101);;
sh := List([1..40], i -> rec(i := i));;
GASMAN_MEM_CHECK(1);
SortParallel(keys, sh, function(a, b) local s; s := String(a); return a < b; end);
ForAll(sh, IsRecord);
```

The shadow element is shifted out of its list and held only by a C
temporary while the comparison allocates; the comparison never sees it, so
nothing roots it. Plain `Sort` with the same comparison is safe only because
the comparison's parameters root the elements it is given - do not take that
as evidence the kernel is rooting them. Fixed in `src/sortbase.h`.

What the build prints when it finds one (under `GAP_MEM_CHECK`, before
Julia's own marker aborts on the bad type tag):

```
### dead child 0x1175700f0 in a bag of tnum 55 (immutable plain list of cyclotomics)
    dead bag: tnum 4 (cyclotomic) size 36
    parent: 29 slots; [0]:imm [1]:imm ... [28]=DEAD
    GAP stack: Gcd ? List IrrBaumClausen for a (solvable) group Irr ...
```

followed by a C backtrace. The parent is the bag still holding the dead
reference, and the GAP stack is within one allocation of the code that let
the element go: every allocation collects, so the parent became reachable
between two consecutive allocations. Julia's own dump of the mark queue is
useless here - GAP bags print as `ERROR in jl_`.

Where to look once you have the parent: the analyzer cannot see this shape,
because a value loaded from a rooted list counts as rooted by the list, and
the checker has no way to notice the slot being cleared or the list being
resized underneath it. So audit by hand for

- load an element from a container, take it out of the container (clear
  the slot, unbind, shrink, shift another element over it), hit a
  safepoint, then return or store it, and
- resize a container before the value about to be stored has any other root.

Pitfalls when reproducing:

- Under `lldb`, pass Julia's safepoint signals through or the run hangs:
  `process handle SIGSEGV SIGBUS SIGUSR2 -s false -n false -p true`.
- Run with `-T` and stdin from `/dev/null`; a break loop waiting on a
  terminal looks like a hang.
- A run that never prints anything is a segfault before the first output;
  macOS keeps the report in `~/Library/Logs/DiagnosticReports/gap-*.ips`.

## Refresh Checklist

When the Julia-side work changes:

- update the branch name here if it changed
- update the expected tip commit here
- update the short Julia commit list here
- update any Julia build or analyzer command differences here

If only the local symlink target changes, no repo change is needed unless the
commands or assumptions in this file also change.
