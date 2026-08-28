# Plan: Refactor GAP for Precise Julia GC

## Purpose

This note describes the current migration plan for making the GAP kernel
compatible with Julia's precise garbage collector without relying on
conservative stack-scanning callbacks.

The goal is not a one-shot conversion. The goal is a staged process that can
be executed incrementally, tested continuously, and handed off cleanly between
developers.

This document is now a status-aware execution plan. It records completed
groundwork, active conversion work already present on this branch, the
remaining milestones, and the later runtime-hardening work that should only
start once the precise-rooting path has stronger evidence behind it.

## Current situation

Today, GAP can be built against Julia GC via `src/julia_gc.c`. Even though
Julia GC is precise, this integration currently enables conservative support
and installs callbacks for

- root stack scanning,
- task stack scanning,
- pre-GC hooks, and
- post-GC hooks.

In particular, `GAP_InitJuliaMemoryInterface` currently calls

- `jl_gc_enable_conservative_gc_support()`,
- `jl_gc_set_cb_root_scanner(GapRootScanner, 1)`,
- `jl_gc_set_cb_task_scanner(GapTaskScanner, 1)`,
- `jl_gc_set_cb_pre_gc(PreGCHook, 1)`,
- `jl_gc_set_cb_post_gc(PostGCHook, 1)`.

This keeps the existing GAP kernel working, because much of the kernel assumes
that live `Obj` references can be recovered conservatively from C stacks. But
it has several downsides:

- extra GC overhead from scanning stacks and task stacks,
- ongoing coupling to Julia GC internals,
- fragility around tasks, guard pages, and callback behavior,
- difficulty reasoning locally about object liveness.

## Target state

The target state is a GAP kernel that is valid under a precise rooting model:

- C/C++ locals that hold GC-managed GAP objects are rooted explicitly when
  needed.
- Functions are annotated so we can distinguish code that may trigger GC from
  code that provably cannot.
- Conservative stack scanning remains available during the transition, but it
  stops being a hidden correctness requirement for converted kernel code.
- The Julia integration becomes smaller and less dependent on invasive runtime
  callbacks.
- Ordinary GAP users running with GASMAN should see no runtime cost from this
  project: for that configuration, the new rooting and annotation machinery
  should compile away completely.

This work is about the kernel in `src/`, not the higher-level GAP.jl package
integration.

## Main idea

Adopt, in GAP, the same two ingredients that Julia uses for its own C/C++
runtime code:

1. Explicit GC rooting macros such as `JL_GC_PUSH*` / `JL_GC_POP`.
2. Function and argument annotations such as `JL_NOTSAFEPOINT`,
   `JL_PROPAGATES_ROOT`, `JL_MAYBE_UNROOTED`, `JL_ROOTS_TEMPORARILY`,
   `JL_ROOTING_ARGUMENT`, and `JL_ROOTED_ARGUMENT`.

GAP should expose these through GAP-owned wrapper macros. For Julia-GC builds,
the wrappers map to Julia's runtime and analyzer model. For GASMAN builds, they
compile away. For static analysis, the analyzer must still see the relevant
annotations.

## Constraints and assumptions

- GAP must remain buildable with GASMAN throughout the transition.
- The end result must not make the normal GASMAN configuration worse for
  users. In particular, the added rooting and annotation support should impose
  zero runtime overhead when compiling with GASMAN.
- The refactoring should be incremental; large all-at-once edits across the
  whole kernel are too risky.
- We should preserve out-of-tree builds as the main workflow for Julia-GC
  development.
- Conservative stack scanning should not be tightened or removed until we have
  both static-analysis coverage and runtime validation for enough of the
  kernel.
- GAP's own kernel is not the whole story: some GAP packages ship kernel
  extensions, typically small C/C++ loadable modules, and those will also need
  an eventual migration path for the precise-rooting model.

## Current branch status

This branch has already completed part of the original plan.

Completed groundwork:

- GAP-owned wrapper headers now exist:
  - `src/precise_gc.h` for analyzer-visible annotations,
  - `src/precise_gc_julia.h` for runtime rooting wrappers.
- GAP-local wrapper names (`GAP_GC_*`) are now the chosen internal interface.
  Julia names remain an implementation detail of Julia-GC builds.
- A supported local analyzer runner exists:
  - `dev/run-julia-gc-analyzer.sh BUILD_DIR SOURCE`
- The analyzer workflow and local Julia-handoff conventions are documented in
  `dev/julia-gc-handoff.md`.

Conversion work already underway on this branch:

- annotation and rooting changes in object/list/set/range-related code,
- broader migration work in `calls.c`, `compiler.c`, and `vars.c`,
- additional Julia-GC-facing annotation work in low-level headers and
  integration code.

This means the branch is beyond a narrow pilot. The next planning task is not
to invent infrastructure, but to stabilize the low-level safepoint model and
apply sharper completion criteria to subsystem batches.

## Batch model and completion rule

The rest of this project should proceed in explicit subsystem batches rather
than one large tree-wide rewrite.

Each batch may include three kinds of work:

1. annotation/modeling work,
2. rooting fixes required by analyzer findings,
3. structural refactors needed to shorten lifetimes or reduce rooting
   pressure.

A subsystem batch is only considered converted when all of the following hold:

- the targeted translation units are analyzer-clean for the intended checker
  configuration,
- GAP starts and completes the agreed smoke run in a Julia-GC build,
- `make check` passes in at least one Julia-GC out-of-tree build.

Each future batch entry in this plan should therefore name:

- the target translation units,
- the expected analyzer command or commands,
- the smoke command or startup path to exercise,
- the build directory in which `make check` is required.

## Revised phases

### Phase 0: Baseline and inventory

Keep a clear record of the current Julia-GC integration assumptions before
tightening runtime behavior.

Tasks:

- maintain the inventory of Julia-GC integration points in `src/julia_gc.c`,
  especially allocation paths, marking, callbacks, and conservative-scanning
  assumptions,
- keep track of the main GC safepoint entry points exposed to the rest of the
  kernel, starting with `NewBag`, `ResizeBag`, and explicit collection entry
  points,
- record recurring patterns that require manual rooting or structural
  refactoring.

Deliverable:

- this plan file, kept current as the migration progresses.

### Phase 1: Completed groundwork for wrappers and local interfaces

This phase is largely done on the current branch.

Completed decisions:

- use GAP-owned wrapper names rather than exposing Julia names directly in GAP
  code,
- keep annotation wrappers in `src/precise_gc.h`,
- keep runtime rooting wrappers in `src/precise_gc_julia.h`,
- make the wrappers compile away for non-Julia builds.

Remaining work in this phase:

- fill gaps only if later conversion experience shows that the wrapper surface
  is missing a needed analyzer or runtime concept.

Success criterion:

- kernel code continues to use a stable GAP-owned macro layer rather than
  depending directly on Julia spellings.

### Phase 2: Completed groundwork for the analyzer workflow

This phase is also largely done on the current branch.

Completed decisions:

- use Julia's GC checker as the main static-analysis tool,
- support single-file analyzer runs first,
- treat `dev/run-julia-gc-analyzer.sh BUILD_DIR SOURCE` as the supported local
  entrypoint until a build-system target is clearly justified.

Current workflow:

1. Build Julia's checker plugin in the Julia tree:
   - `make -C /path/to/julia/src clangsa`
2. Configure and build GAP in an out-of-tree build against Julia.
3. Run the helper script from the GAP repository root, for example:
   - `JULIA_GC_ANALYZER_CHECKERS=julia.GCChecker dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev src/julia_gc.c`
   - `JULIA_GC_ANALYZER_CHECKERS=julia.GCChecker dev/run-julia-gc-analyzer.sh out-of-tree/julia-dev src/compiler.c`

Remaining work in this phase:

- decide later whether the build system should gain a helper target,
- move toward CI integration once batch-level workflows are stable enough.

Success criterion:

- analyzer runs remain reproducible and actionable for chosen GAP translation
  units.

### Phase 3: Stabilize GAP's safepoint model

This is the next technical milestone.

The analyzer only becomes trustworthy once GAP has a documented and stable
model of which operations may trigger GC.

Tasks:

- classify low-level functions into:
  - may safepoint / may allocate,
  - not safepoints,
  - propagate roots from arguments to results,
  - temporarily root unrooted arguments,
- start with the GC-facing API in `src/gasman.h` and the Julia-specific
  implementation in `src/julia_gc.c`,
- stabilize annotations on `NewBag` first, because it is the kernel's key
  allocation primitive and the natural source of many diagnostics,
- review `ResizeBag`, explicit collection routines, and nearby helpers that can
  lead directly or indirectly to a GC cycle,
- mark obviously leaf-style helpers as not safepoints where correct.

Deliverable:

- a stable annotated low-level contract that higher-level files can rely on.

### Phase 4: Complete the first real subsystem batches

This phase is already underway on the current branch. It should now be treated
as real conversion work, not just an exploratory pilot.

Active batch families already represented on this branch:

1. allocation-heavy object and mutation code,
2. core list/set/range/record-style helpers,
3. interpreter and call machinery.

Tasks for each batch:

- settle the relevant low-level annotations the batch depends on,
- run the analyzer on the batch's target files,
- add explicit roots where locals must survive allocation or collection points,
- refactor functions when lifetimes are too long or rooting pressure becomes
  unclear,
- record patterns worth reusing in later batches,
- do not mark the batch complete until it passes the batch completion rule.

Current expectations:

- smaller collection/object files can be used to settle conventions quickly,
- larger files such as `calls.c`, `compiler.c`, and `vars.c` remain part of the
  official migration path and should not be treated as outside the plan.

### Phase 5: Expand subsystem by subsystem

After the first converted batches are stable, continue through the remaining
kernel in manageable increments.

Suggested batching order:

1. remaining allocation-heavy constructors and mutators,
2. remaining traversal / list / plist / record helpers,
3. remaining interpreter and call paths,
4. specialty subsystems and clean-up of cross-cutting APIs.

Tasks for each batch:

- define the target files and required analyzer invocations up front,
- perform annotation/modeling work first,
- add rooting fixes next,
- perform structural refactors only where the previous two are insufficient,
- run the required smoke test and `make check`,
- land the batch before broadening scope again.

### Phase 6: Runtime hardening and reduced scanning

This phase is intentionally deferred.

Do not introduce explicit runtime modes such as "conservative", "hybrid", or
"strict" yet. Those switches should be added only when they help validate a
substantial amount of already-converted code rather than complicating early
development.

Prerequisites before this phase starts:

- multiple subsystem batches have passed the batch completion rule,
- the low-level safepoint model has been stable long enough that analyzer
  results are trustworthy,
- runtime validation in ordinary Julia-GC builds is no longer regularly
  finding first-order rooting mistakes in converted code.

Tasks once the prerequisites are met:

- make conservative root/task scanning conditional on a build-time or runtime
  mechanism,
- compare stricter behavior against the current conservative baseline,
- use the stricter modes as evidence-gathering tools, not as the first line of
  development,
- remove now-unnecessary hacks only after their original purpose is gone.

Success criterion:

- GAP can execute meaningful workloads under Julia GC with reduced or disabled
  conservative stack scanning for converted code paths.

### Phase 7: Final cleanup and simplification

Once precise rooting is the default correctness model:

- remove obsolete callback plumbing from `src/julia_gc.c`,
- remove conservative-only caches or scanning support that no longer serves a
  purpose,
- document the kernel rooting rules for future contributors,
- keep analyzer integration as part of ongoing development hygiene,
- add or maintain CI coverage for the GC analyzer so new pull requests do not
  silently regress the rooting discipline,
- define and document the migration story for package kernel extensions.

## Coding guidelines

- Root as locally as possible. Prefer small GC frames with short lifetimes.
- Prefer refactoring long functions over accumulating many rooted locals.
- Treat `NewBag` as the default safepoint boundary until proven otherwise.
- Use annotations to express real invariants, not to silence diagnostics.
- When a helper returns an object stored inside another rooted object, prefer a
  propagation annotation over redundant rooting.
- Do not tighten conservative-scanning behavior until the precise path is
  validated.

## Build and test workflow

This project needs a reproducible Julia-GC development workflow.

Current out-of-tree builds:

- `out-of-tree/julia-dev`
- `out-of-tree/julia-dev-debug`

Local Julia checkout discovery and analyzer prerequisites are documented in
`dev/julia-gc-handoff.md`.

The current working convention is that `dev/julia` points at the Julia checkout
used for this project.

The current configure commands are:

```sh
mkdir -p out-of-tree/julia-dev
cd out-of-tree/julia-dev
../../configure \
  --with-julia=/path/to/julia \
  --with-gc=julia
make
```

```sh
mkdir -p out-of-tree/julia-dev-debug
cd out-of-tree/julia-dev-debug
../../configure \
  --with-julia=/path/to/julia-debug \
  --with-gc=julia \
  --enable-debug \
  CFLAGS=-g \
  CXXFLAGS=-g
make
```

Per-batch required validation:

- run the analyzer on the batch's target files,
- run a Julia-GC startup or smoke test from the selected out-of-tree build,
- run `make check` in at least one Julia-GC build directory before marking the
  batch complete.

Periodic deeper validation:

- repeat smoke testing and `make check` in `out-of-tree/julia-dev-debug` after
  several batches or before any stricter runtime experiment,
- treat this as a milestone gate, not a requirement for every small annotation
  commit.

The smoke test matters because GC-related regressions can already show up while
GAP is starting, even though some bugs will only surface under longer or more
specialized runs.

## Risks

- Some existing code may rely on conservative liveness in subtle ways that only
  show up under real workloads.
- Annotation mistakes can hide real bugs if we over-assert `NOTSAFEPOINT` or
  root propagation.
- Parts of the kernel may need structural refactoring, not just macro
  insertion.
- The analyzer integration may still need build-system work before it becomes
  convenient enough for routine CI use.
- HPC-GAP or other alternate configurations may need separate review later.
- Even outside Julia integration, the long-term direction matters because
  stack scanning may become less viable over time. Existing code already leans
  on undocumented compiler behavior and uses `setjmp` in ways that are more of
  a pragmatic workaround than a principled interface.

## Longer-term perspective

Although this project is driven by the Julia GC integration, it may also be
useful for GAP more broadly. If we succeed in making the kernel work under a
precise rooting discipline, then in the long run GASMAN might also be able to
move away from stack scanning. That is not part of the present project plan,
but it is a plausible future payoff.

There is also a broader ecosystem angle. Some GAP packages include kernel
extensions, meaning dynamically loaded C/C++ modules that participate in the
same object model. Those extensions will eventually need to adopt the same
discipline, so the core-kernel work should aim to leave behind reusable
headers, conventions, and documentation rather than a solution that only works
inside the GAP repository.

## Immediate next steps

The next implementation steps should be:

1. Stabilize annotations on `NewBag`, `ResizeBag`, and nearby low-level GC
   entry points.
2. Re-evaluate current branch work against explicit subsystem batch boundaries.
3. Finish the first batch or batches using the analyzer-plus-smoke-plus-check
   completion rule.
4. Use the resulting experience to decide the next subsystem order.
5. Postpone runtime strictness experiments until several batches are complete
   and stable.

## Open questions

These questions no longer block current work, but they should be revisited
later:

- When should GAP gain a build-system target for GC-analyzer runs instead of
  relying on the helper script?
- At what point is analyzer coverage and runtime validation strong enough to
  justify reduced-scanning experiments?
- What is the right migration and documentation story for package kernel
  extensions once the core-kernel rules have settled?
