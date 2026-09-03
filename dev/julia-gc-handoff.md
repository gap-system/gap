# Julia GC Handoff

This file records what the GAP precise-GC work needs from Julia and how the
analysis tooling is set up.

## The Julia source checkout

The static analyses need two things that are not part of a Julia binary
installation: Julia's clang, and the analyzer plugins built from Julia's
`src/clangsa`. Both come from a Julia *source* checkout in which
`make -C src install-analysis-deps clangsa` has been run (that needs no Julia
build, only the LLVM it downloads). When the Julia given to `configure` is
such a checkout, built in place, `configure` creates the symlink `dev/julia`
in the build directory pointing at it, and the scripts in `dev/` take clang
and the plugins from there (a `dev/julia` in the source tree is honoured
too). Otherwise they assume the configured Julia is such a checkout's `usr/`.
Individual pieces can be overridden with the environment variables listed in
each script.

## Expected Julia State

The Julia-side changes this GAP work depends on are two pull requests
against JuliaLang/julia:

- JuliaLang/julia#62889 `mh/gc_mark_stack-immediate-pointers`, "Skip tagged
  immediates in JL_GC_PUSH roots": the run-time patch. Without it Julia's
  root scanner dereferences a tagged immediate held in a `GAP_GC_PUSH*`
  frame. It also extends the skip to `JL_GC_PUSHARGS` frames.
- JuliaLang/julia#62928 `mh/JL_GC_TRACKED_TYPE`, "clangsa: Mark GC-tracked
  types with an attribute": analyzer only. The checker recognises the types
  it tracks by that attribute alone; GAP marks `struct OpaqueBag` with
  `GAP_GC_TRACKED_TYPE`, which spells the same attribute.

For local work, use a checkout of JuliaLang/julia with both pull requests
applied. Only the first is needed at run time; until it is in a Julia
release, GAP.jl cannot use precise mode with a released Julia.
`juliaup add pr62889` gives a prebuilt Julia of that pull request, enough to
build and test precise mode; `juliaup add pr62928` gives one whose headers
carry the attribute, which the analyzer needs. `.github/workflows/julia-gc.yml`
uses both.

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
After a Julia update that changes the LLVM version, install the matching
tooling before rebuilding the plugin (`dev/julia` here and below is the
symlink to the Julia checkout, in the build directory or the source tree):

```sh
make -C dev/julia/src install-analysis-deps
```

A version mismatch shows up as a `dyld` "Symbol not found" error naming
`libclang-cpp.dylib` and `libLLVM.dylib` when the analyzer starts.

Build Julia's GC analyzer plugin with:

```sh
make -C dev/julia/src clangsa
```

The GAP analyzer runs assume that the plugins have been built in the checkout
reached via `dev/julia`.

The GAP-side analyzer helper script is:

```sh
dev/run-julia-gc-analyzer.sh BUILD_DIR SOURCE
```

Example:

```sh
JULIA_GC_ANALYZER_CHECKERS=julia.GCChecker \
  dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev src/objects.c
```

## GAP Build Directories

Everything here uses out-of-tree builds: a build directory anywhere in the
file system, configured with the `configure` script of the source tree (see
`README.buildsys.md`, section "Out-of-tree builds"). The directories used in
this document live under `out-of-tree/` in the source tree; for example

```sh
mkdir -p out-of-tree/julia-dev && cd out-of-tree/julia-dev
../../configure --with-gc=julia --with-julia=$JULIA
make -j4
```

where `$JULIA` is the Julia installation to build against (its `bin/julia`,
or the prefix). This is the configuration the analyzer scripts run on:
`dev/run-julia-gc-analyzer-all.sh out-of-tree/julia-dev`. The precise-mode
configurations add `-DDISABLE_STACK_SCAN` to the compiler flags; `CFLAGS=`
given to `configure` replaces GAP's default `-g -O2` rather than adding to
it, so spell the defaults out:

```sh
../../configure --with-gc=julia --with-julia=$JULIA \
  CFLAGS="-g -O2 -DDISABLE_STACK_SCAN" CXXFLAGS="-g -O2 -DDISABLE_STACK_SCAN"
```

After changing the analyzer plugins, rebuild them and then the GAP build
directories that are analyzed (`dev/julia` here is the build directory's
symlink to the Julia checkout):

```sh
make -C out-of-tree/julia-dev/dev/julia/src clangsa
make -C out-of-tree/julia-dev -j4
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

- Use `GAP_GC_PUSH1` through `GAP_GC_PUSH9` for GAP `Obj` locals. These
  fixed-arity frames store addresses of locals, and a GAP `Obj` may be a
  tagged immediate: Julia's root scanner skips those only with
  JuliaLang/julia#62889. That pull request also extends the skip to
  `JL_GC_PUSHARGS` frames, which store values directly; GAP's two
  `GAP_GC_PUSHARGS` users (`src/vecgf2.c`, and the type array in
  `DoOperationNArgs` in `src/opers.cc`) hold bags only, so they do not
  depend on that part.
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
it around the workload. To cover startup itself, set the period from the
environment and pass `--enableMemCheck`:

```sh
GAP_MEMCHECK_PERIOD=200 ./gap --enableMemCheck -l . -q -A -T
```

Period 500 boots and gets through the first 40 test files in about 25
minutes with the checks live from the first allocation. Every allocation
is a sample point, the body allocation inside NewBag and ResizeBag
included - that is where a caller loses an object it holds only in a C
local. Expect `weakptr.tst` to differ under any period: it encodes when
the collector runs.

To turn an intermittent report into a deterministic one, sample densely only
around the point where it was seen. The abort output carries an allocation
count; `GAP_MEMCHECK_START` and `GAP_MEMCHECK_STOP` bound the checks to
that range of bag allocations, and period 1 there costs only minutes:

```sh
GAP_MEMCHECK_START=15000 GAP_MEMCHECK_STOP=45000 GAP_MEMCHECK_PERIOD=1 \
  ./gap --enableMemCheck -l . -q -A -T
```

The sampled collections are full by default. A full collection cannot expose
a missing write barrier: it reaches the young child of a promoted parent
through the parent. Only a young collection frees such a child, so to hunt
barrier bugs set `GAP_MEMCHECK_FULL_EVERY=n`: n-1 of every n samples are
then young collections, cheap enough for period 1 over a whole test file,
and the nth is a full one that validates the old parents and reports the
dead child.

```sh
GAP_MEMCHECK_PERIOD=1 GAP_MEMCHECK_FULL_EVERY=100 \
  ./gap --enableMemCheck -l . -q -A -T
```

Two more memory-checking aids: every `GAP_GC_PUSH*` is recorded with its
source location and every `GAP_GC_POP` checked against that record, so a
push without a pop is reported at the pop that finds the mismatch, and the
dead-reference report lists the recorded frames. That record alone cannot
see an unwind that skipped `GAP_GC_RESTORE_STACK_STATE`: `GAP_GC_POP`
hands over the chain top, so the pops after such an unwind quietly pop the
dead frames instead of their own and keep chain and ledger consistent.
Both push and pop therefore also compare the frame with the current stack
pointer - a frame below it belongs to a function that has returned - and
abort at the first push or pop that touches such a frame.

A root pushed before it is initialised is the hardest case: the collector
reads whatever the stack held, which differs between builds, so a fault in
the optimized build (the marker dereferencing a small constant such as
`0x110050`) can be absent from every memory-checking build. Configure one
more memory-checking build with `-ftrivial-auto-var-init=pattern` added to
`CFLAGS` and `CXXFLAGS`: every uninitialised local then holds `0xAA` bytes,
and the push records abort at the push whose slot carries that pattern,
independent of collection timing. And
`GAP_MEMCHECK_MARK_ANYWAY=1` marks a child the validator rejected instead of
aborting, which distinguishes a genuinely dead object (Julia then aborts on
its type tag) from one the validator misjudged. Period 1000 gets through `testinstall` in hours.
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
