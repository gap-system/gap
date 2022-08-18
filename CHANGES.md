# GAP - history of changes

## GAP 4.12.0 (August 2022)

The following gives an overview of the changes compared to the previous
release. This list is not complete, many more internal or minor changes
were made, but we tried to keep it to changes which we think might
affect some users directly.

### Highlights

- **Added the missing perfect groups of order up to two million**

  Added perfect groups of orders that had been missing in the Holt/Plesken book
  (newly computed).
  This increases the number of groups in the perfect groups library from 1098
  to 15768.
  Also added five groups that were found missing in the existing lists.
  See PR [#3925](https://github.com/gap-system/gap/pull/3925) and [#4530](https://github.com/gap-system/gap/pull/4530) for details.

- **The windows installer for GAP has been completely rewritten**

  There are many changes and minor fixes, the most significant are:
  - GAP can be installed globally into "Program Files".
  - GAP can also be installed without admin access into the user's home directory.
  - Almost all packages work, including those with kernel modules and external programs.
  - The default directory for saving is the user's "Documents" folder.
  - There is no longer possible to choose which packages are installed.
  - Windows versions before 8 are no longer supported.

- **Initial support for `make install` available**

  This is mostly of interest for downstream packagers, e.g. for Linux
  distributions. One major caveat is that it does not deal with installing
  packages (handling that still requires some more planing and thought). The
  feature is also still rather new and as such is likely to still have rough
  edges, but we welcome you to try it, and share your feedback with us.
  See PR [#4492](https://github.com/gap-system/gap/pull/4492).

### Changes to the `libgap` interface

- [#4215](https://github.com/gap-system/gap/pull/4215) Add `GAP_MarkBag`, `GAP_CollectBags`, a minimal interface to the garbage collector
- [#4501](https://github.com/gap-system/gap/pull/4501) Add `GAP_CallFunc[0-3]Args`
- [#4531](https://github.com/gap-system/gap/pull/4531) Add `GAP_IsMatrix`
- [#4621](https://github.com/gap-system/gap/pull/4621) Add `GAP_NewRange`, `GAP_NewObjIntFromInt`, `GAP_ValueInt` to the libgap API
- [#4644](https://github.com/gap-system/gap/pull/4644) Make `libgap-api.h` safe to use from C++ code

### Changes to the GAP compiler

- [#4746](https://github.com/gap-system/gap/pull/4746) Rewrite `gac` to not use libtool
- [#4778](https://github.com/gap-system/gap/pull/4778) Remove support for static linking from `gac`, it was rarely if ever used but required a disproportionate amount of effort to keep it working
- [#4933](https://github.com/gap-system/gap/pull/4933) Improve `gac` to print errors to stderr and in color

### Changes in the documentation

- [#4168](https://github.com/gap-system/gap/pull/4168) Improve the documentation concerning GASMAN, add `CollectGarbage`
- [#4339](https://github.com/gap-system/gap/pull/4339) Document `TensorProduct`, `ExteriorPower` and `SymmetricPower` (they existed since at least GAP 4.4)
- [#4438](https://github.com/gap-system/gap/pull/4438) Improve documentation for random sources
- [#4475](https://github.com/gap-system/gap/pull/4475) Improve argument checking and documentation for `FreeGroup`, `FreeMonoid`, `FreeSemigroup`, `FreeMagmaWithOne`, and `FreeMagma`
- [#4529](https://github.com/gap-system/gap/pull/4529) Document `IsNoImmediateMethodsObject` officially, so that packages are free to use it (it already existed for a long time)
- [#4672](https://github.com/gap-system/gap/pull/4672) Clarify documentation of `IsFFECollection`
- [#4925](https://github.com/gap-system/gap/pull/4925) Document `IsSquareInt` (it has been around for a long time)

### Performance improvements

- [#3721](https://github.com/gap-system/gap/pull/3721) Add optimised `SmallestMovedPoint` implementation
- [#3740](https://github.com/gap-system/gap/pull/3740) Speed up printing of large permutations
- [#4186](https://github.com/gap-system/gap/pull/4186) Speed up `CoefficientsQadic` for long results
- [#4331](https://github.com/gap-system/gap/pull/4331) Speed up building stabchain from base and strong generators
- [#4411](https://github.com/gap-system/gap/pull/4411) Speed up automorphism group and group isomorphism computations
- [#4411](https://github.com/gap-system/gap/pull/4411) Speed up `IntermediateSubgroups` if the smaller subgroup has many orbits
- [#4599](https://github.com/gap-system/gap/pull/4599) Speed up `PositionSublist` by using `Position` to search for first entry
- [#4622](https://github.com/gap-system/gap/pull/4622) Speed up `AlgebraicExtension` and `AlgebraicExtensionNC` for larger degrees
- [#4683](https://github.com/gap-system/gap/pull/4683) Speed up `Embedding` for wreath products
- [#4836](https://github.com/gap-system/gap/pull/4836) Speed up calculation of character tables, in particular for solvable groups
- [#4874](https://github.com/gap-system/gap/pull/4874) Speed up computation of the intersection of group cosets in the generic cases and even more so for permutation groups
- [#4902](https://github.com/gap-system/gap/pull/4902) Speed up `Exponent` for groups with known conjugacy classes
- [#4905](https://github.com/gap-system/gap/pull/4905) Speed up `IrrBaumClausen` (used for computing character tables of supersolvable groups, including $p$-groups)
- [#4910](https://github.com/gap-system/gap/pull/4910) Speed up `LinearCharacters` for $p$-groups, and `IrrConlon` (used for computing character tables of supersolvable groups, including $p$-groups)

### Changes to HPC-GAP

- [#3759](https://github.com/gap-system/gap/pull/3759) Fix an issue with error reporting in parallel threads
- [#3761](https://github.com/gap-system/gap/pull/3761) Fix bugs in HPC-GAP serialization code and improve its tests
- [#3822](https://github.com/gap-system/gap/pull/3822) Make the assertion level (which controls `Assert` statements) thread local when using HPC-GAP

### New features

- [#3858](https://github.com/gap-system/gap/pull/3858) Add `DeclareGlobalName`; together with `BindGlobal` it can be used to replace uses of `DeclareGlobalVariable` & `InstallValue` (which are not thread safe and have other dangers)
- [#3914](https://github.com/gap-system/gap/pull/3914) Add `InnerAutomorphismGroup` attribute for groups
- [#3992](https://github.com/gap-system/gap/pull/3992) Add `Pluralize` function for strings
- [#4074](https://github.com/gap-system/gap/pull/4074) Add `IteratorOfPartitionsSet` an iterator for all unordered partitions of a set into pairwise disjoint nonempty sets
- [#4104](https://github.com/gap-system/gap/pull/4104) Add `TaylorSeriesRationalFunction` and improve `Derivative` for univariate rational functions
- [#4126](https://github.com/gap-system/gap/pull/4126) Add command line option `--version`
- [#4128](https://github.com/gap-system/gap/pull/4128) Add `OutputGzipFile`, in order to create a gzip compressed file
- [#4207](https://github.com/gap-system/gap/pull/4207) Add group constructors `PGammaL`, `PSigmaL`, and their methods for permutation groups
- [#4219](https://github.com/gap-system/gap/pull/4219) Add `CompositionSeriesThrough`
- [#4249](https://github.com/gap-system/gap/pull/4249) Add `ARCH_IS_WSL` to detect Windows Subsystem for Linux
- [#4295](https://github.com/gap-system/gap/pull/4295) Add `OpenExternal`, a function for opening files in the OS
- [#4334](https://github.com/gap-system/gap/pull/4334) Add group constructors `PGO` and `PSO`
- [#4410](https://github.com/gap-system/gap/pull/4410) Add `ListWreathProductElement` and `WreathProductElementList`
- [#4465](https://github.com/gap-system/gap/pull/4465) Add command line option `--print-gaproot`
- [#4557](https://github.com/gap-system/gap/pull/4557) Add `InstallEarlyMethod` which allows installing special methods that bypass method selection (and thus its overhead)
- [#4893](https://github.com/gap-system/gap/pull/4893) Add `HexSHA256` function for computing SHA256 checksums

### Improved and extended functionality

- [#3355](https://github.com/gap-system/gap/pull/3355) Allow packages to use ISO 8601 dates in their `PackageInfo.g` files (so `YYYY-MM-DD` instead of `DD/MM/YYYY`)
- [#3628](https://github.com/gap-system/gap/pull/3628) Add `Info` statement triggered when re-assigning already assigned attributes and the info level `InfoAttributes` is at least 3
- [#3643](https://github.com/gap-system/gap/pull/3643) Start the process of making vector and matrix objects official
- [#3668](https://github.com/gap-system/gap/pull/3668) Support several package instances with same version
- [#3713](https://github.com/gap-system/gap/pull/3713) Add tracing and counting of built-in operations
- [#3861](https://github.com/gap-system/gap/pull/3861) Extend the range of precomputed simple groups from orders up to 10^18 to orders up to about 10^27
- [#3901](https://github.com/gap-system/gap/pull/3901) Allow function-call syntax for general mappings.
- [#3920](https://github.com/gap-system/gap/pull/3920) Admit `CentralIdempotentsOfAlgebra` for algebras without `One`
- [#3933](https://github.com/gap-system/gap/pull/3933) Add libtool versioning to libgap shared library
- [#3939](https://github.com/gap-system/gap/pull/3939) Improve handling of temp directory in GAP for Windows
- [#3986](https://github.com/gap-system/gap/pull/3986) Add methods taking machine floats for `Sinh`, `Cosh`, `Tanh`, `Asinh`, `Acosh`, `Atanh`, `CubeRoot`, `Erf`, `Gamma`
- [#4000](https://github.com/gap-system/gap/pull/4000) Enhance `NormalClosure` to accept a list of normal generators (instead of a group) as second argument
- [#4050](https://github.com/gap-system/gap/pull/4050) Use `Pluralize` to give correct pluralization in many GAP library methods
- [#4099](https://github.com/gap-system/gap/pull/4099) Passing a `.tst` file as a command line argument to `gap` will now invoke `Test` on it
- [#4105](https://github.com/gap-system/gap/pull/4105) Add an optional third argument to `OrderMod` that is a multiple of the order one wants to compute
- [#4111](https://github.com/gap-system/gap/pull/4111) Enhance `FreeGroup` to support the option `generatorNames` to prescribe the names of the generators
- [#4142](https://github.com/gap-system/gap/pull/4142) Extend `BindConstant`, `MakeConstantGlobal` to all object types.
- [#4144](https://github.com/gap-system/gap/pull/4144) Avoid overflows when converting rationals with large denominator and/or numerator to floating point
- [#4145](https://github.com/gap-system/gap/pull/4145) Improve errors messages for various set operations (`AddSet`, `UniteSet`, ...)
- [#4146](https://github.com/gap-system/gap/pull/4146) Fix `Cite` to honor `GAPInfo.TermEncoding` for its printing; let `BibEntry` always use encoding "UTF-8"
- [#4170](https://github.com/gap-system/gap/pull/4170) Improve `Test` to use colors to highlight failures and diffs
- [#4201](https://github.com/gap-system/gap/pull/4201) Support optional `transformFunction` in `Test`, similar to `compareFunction`.
- [#4231](https://github.com/gap-system/gap/pull/4231) Add `LoadKernelExtension`, `IsKernelExtensionAvailable`
- [#4274](https://github.com/gap-system/gap/pull/4274) Enable color prompt by default
- [#4275](https://github.com/gap-system/gap/pull/4275) Enable `SaveAndRestoreHistory` by default
- [#4296](https://github.com/gap-system/gap/pull/4296) Allow function-call syntax for evaluating univariate polynomials
- [#4332](https://github.com/gap-system/gap/pull/4332) Rewrite and officially document `PlainListCopy`
- [#4333](https://github.com/gap-system/gap/pull/4333) Add `GO(1,q)`, `SO(1,q)`, `Omega(1,q)`, `Omega(-1,2,q)`
- [#4361](https://github.com/gap-system/gap/pull/4361) Add `\in` method for `GO(e,d,q)` and `SO(e,d,q)` that is based on the stored invariant quadratic form
- [#4366](https://github.com/gap-system/gap/pull/4366) Improve `(New)ZeroMatrix`, `(New)IdentityMatrix`, `(New)ZeroVector` to better reject invalid input
- [#4373](https://github.com/gap-system/gap/pull/4373) Support `IsCommutative`/`IsAssociative` for `IsCollection`, rather than just for `IsMagma`
- [#4483](https://github.com/gap-system/gap/pull/4483) Write `--help` output to `*stdout*` not `*errout*`
- [#4489](https://github.com/gap-system/gap/pull/4489) The functions `GO`, `GU`, `Omega`, `SO`, `SU`, and `Sp` now allow to specify an invariant form for the group in question; the methods that do the work are provided by the Forms package
- [#4506](https://github.com/gap-system/gap/pull/4506) Change the *default* representation for perfect groups to `IsPermGroup` (previously `IsFpGroup`)
- [#4517](https://github.com/gap-system/gap/pull/4517) Add basic operations for row/column reductions in matrix objects
- [#4528](https://github.com/gap-system/gap/pull/4528) Improve `SizeOfFieldOfDefinition` such that `fail` is no longer returned when the first argument is a (Brauer) character
- [#4537](https://github.com/gap-system/gap/pull/4537) Implement `IsMinimalNonmonomial` for nonsolvable groups
- [#4555](https://github.com/gap-system/gap/pull/4555) Fix `PrintFormattingStatus` and `SetPrintFormattingStatus` for the standard output (i.e., when the first argument is `"*stdout*"` and add a variant that deals with the current output (whatever that may be), reachable by using `"*current*"` as first argument
- [#4632](https://github.com/gap-system/gap/pull/4632) Document and unify the order in which GAP evaluates function arguments and options
- [#4639](https://github.com/gap-system/gap/pull/4639) Add `LatticeSubgroups` method for the case `IsHandledByNiceMonomorphism`
- [#4653](https://github.com/gap-system/gap/pull/4653) Add `IsQuasisimpleGroup`, `IsQuasisimpleCharacterTable`
- [#4668](https://github.com/gap-system/gap/pull/4668) Add `SpinorNorm`
- [#4764](https://github.com/gap-system/gap/pull/4764) Admit `g^chi` and `chi^g` for Brauer characters `chi` and group elements `g`
- [#4810](https://github.com/gap-system/gap/pull/4810) Enhance `SimplifiedFpGroup` and `IsomorphismSimplifiedFpGroup` to transfer attributes (such as size, being abelian etc.) to the simplified group

### Removed or obsolete functionality

- [#3694](https://github.com/gap-system/gap/pull/3694) Deprecate undocumented extra arguments for `DeclareGlobalFunction` and `InstallGlobalFunction`
- [#3702](https://github.com/gap-system/gap/pull/3702) Make `TmpNameAllArchs` obsolete by enhancing `TmpName`
- [#3796](https://github.com/gap-system/gap/pull/3796) Remove command line option `-B` which could be used to override the architecture
- [#3862](https://github.com/gap-system/gap/pull/3862) Rename `QUIT_GAP`, `FORCE_QUIT_GAP` and `GAP_EXIT_CODE` to `QuitGap`, `ForceQuitGap` and `GapExitCode` (the old names remain available as synonyms)
- [#4493](https://github.com/gap-system/gap/pull/4493) Remove optional `crc` argument to `LoadDynamicModule` and `LoadStaticModule`
- [#4504](https://github.com/gap-system/gap/pull/4504) Turn `IsLexicographicallyLess` into an obsolete synonym for `\<`
- [#4519](https://github.com/gap-system/gap/pull/4519) Make third argument of `DeclareRepresentation` and `NewRepresentation` optional, and document that it and the fourth argument are (and always were) unused
- [#4655](https://github.com/gap-system/gap/pull/4655) Rename `RadicalGroup` to `SolvableRadical` (the old name is still supported as an obsolete synonym)
- [#4697](https://github.com/gap-system/gap/pull/4697) Disable `NaturalHomomorphism` for `FactorGroup`, as it has side effects (code using this should be rewritten to use `NaturalHomomorphismByNormalSubgroup` instead)

### Fixed bugs that could lead to incorrect results

- [#4035](https://github.com/gap-system/gap/pull/4035) Fix `DirectoriesPackagePrograms` to ignore case of package name, like `LoadPackage` does
- [#4206](https://github.com/gap-system/gap/pull/4206) Fix `DirectoriesPackageLibrary`, `DirectoriesPackagePrograms` when they are called during package loading
- [#4219](https://github.com/gap-system/gap/pull/4219) Fix `IntermediateGroup` to not return `fail` if the index is large but subgroups exist
- [#4320](https://github.com/gap-system/gap/pull/4320) Fix missing outer automorphisms of certain Chevalley groups of type O_n-(q), n>=8  even; this also fixes calculation of certain normalizers in S_n
- [#4327](https://github.com/gap-system/gap/pull/4327) Fix `InvariantQuadraticForm` for `Omega(-1, 2*d, 2^n)`
- [#4372](https://github.com/gap-system/gap/pull/4372) Fix argument checking in `FreeSemigroup`, prevent creation of inconsistent objects
- [#4373](https://github.com/gap-system/gap/pull/4373) Fix `AsSemigroup` to reject non-associative inputs
- [#4396](https://github.com/gap-system/gap/pull/4396) Fix computation of all maximal subgroups (under specific circumstances, an incomplete list was returned)
- [#4411](https://github.com/gap-system/gap/pull/4411) Fix `RankAction` to reject intransitive actions instead of returning potentially misleading results
- [#4482](https://github.com/gap-system/gap/pull/4482) Fix bug in `MakeImagesInfoLinearGeneralMappingByImages` that could lead to errors resp. wrong results if multiplication with coefficients from the right is not defined resp. not commutative
- [#4634](https://github.com/gap-system/gap/pull/4634) Fix test for subgroup conjugacy for cyclic permutation groups (If A,B are cyclic conjugate subgroups of G, and A <= C, with C abelian, the error could have caused a claim of C being conjugate to B)
- [#4660](https://github.com/gap-system/gap/pull/4660) Fix (rare) wrong result for stabilizer computations
- [#4664](https://github.com/gap-system/gap/pull/4664) Fix `WreathProduct` to return correct generators when given a matrix group and an intransitive top group
- [#4665](https://github.com/gap-system/gap/pull/4665) Fix `RootSystem` to use the correct field for determining eigenvectors
- [#4703](https://github.com/gap-system/gap/pull/4703) Fix `Coefficients` for large finite fields created via a polynomial
- [#4718](https://github.com/gap-system/gap/pull/4718) Fix `LatticeSubgroup` sometimes returning wrong results for matrix groups
- [#4822](https://github.com/gap-system/gap/pull/4822) Fix bug in computing canonical class representative for pc groups which could yield wrong results in larger groups
- [#4907](https://github.com/gap-system/gap/pull/4907) Fix `IsTransitive` to require that the group actually acts on the given domain (strictly speaking, the previous behavior was "as documented", but it made no sense and led to bugs elsewhere)
- [#4992](https://github.com/gap-system/gap/pull/4992) Fix `Gcd` for multivariate polynomials to always return a standard associate element

### Fixed bugs that could lead to crashes

- [#3808](https://github.com/gap-system/gap/pull/3808) Fix a crash when using a constant global variable (created via `MakeConstantGlobal`, such as `IsHPCGAP`) as index variable of a `for` loop
- [#3825](https://github.com/gap-system/gap/pull/3825) Fix some crashes caused by running out of memory
- [#4407](https://github.com/gap-system/gap/pull/4407) Fix crash when accessing `mat[i,j]` and `mat[i]` is unbound
- [#4442](https://github.com/gap-system/gap/pull/4442) Fix crash when incorrectly accessing a compressed vector `v` via  `v{...}[...]` or `v{...}{...}` as if it was a matrix
- [#4508](https://github.com/gap-system/gap/pull/4508) Fix crash in `LocationFunc` when the input has incomplete location information
- [#4544](https://github.com/gap-system/gap/pull/4544) Forbid installing an operation as method for itself, as that leads to crashes
- [#4579](https://github.com/gap-system/gap/pull/4579) Fix crash when methods for mutable attribute do not return a value
- [#4823](https://github.com/gap-system/gap/pull/4823) Fix crash when `QuitGap` is called while reading from an `InputTextString`

### Fixed bugs that could lead to break loops

- [#3693](https://github.com/gap-system/gap/pull/3693) Fix `ViewString` for string to correctly escape characters needing it
- [#3747](https://github.com/gap-system/gap/pull/3747) Fix unexpected error when testing permutation groups for conjugacy
- [#3903](https://github.com/gap-system/gap/pull/3903) Fix `Cycles((),[ ])` to correctly return `[ ]`
- [#4023](https://github.com/gap-system/gap/pull/4023) Fix the floating point number parser for certain exotic formats, e.g. `1.0e0i_` and `1.0e0i_y` now work as intended
- [#4037](https://github.com/gap-system/gap/pull/4037) Change `IsPackageLoaded` and `TestPackage` to ignore case of package name, like `LoadPackage` does
- [#4108](https://github.com/gap-system/gap/pull/4108) Fix some unexpected error when inverting or computing random elements of algebraic extensions of finite fields of size > 256
- [#4239](https://github.com/gap-system/gap/pull/4239) Add missing `\=` method for `IsMultiplicativeElement` and `IsObjWithMemory` (the other direction was already present)
- [#4245](https://github.com/gap-system/gap/pull/4245) Admit non-fields as left acting domains for free (associative or Lie) algebras, and fix the zero-dimensional case
- [#4411](https://github.com/gap-system/gap/pull/4411) Fix an assertion error in `AllHomomorphismClasses`
- [#4427](https://github.com/gap-system/gap/pull/4427) Fix `QuaternionAlgebra` bug that caused `QuaternionAlgebra( [1], 2, 5 ).1` to error the second time it was invoked
- [#4566](https://github.com/gap-system/gap/pull/4566) Fix an unexpected error in `FrobeniusCharacterValue` when the rows of the equation system have different lengths
- [#4875](https://github.com/gap-system/gap/pull/4875) Fix an unexpected error when computing conjugacy classes in certain large permutation groups (and other improvements)

### Other fixed bugs

- [#3695](https://github.com/gap-system/gap/pull/3695) Fix `Test` to correctly handle test outputs which do not end with a newline when using `rewriteToFile`
- [#3931](https://github.com/gap-system/gap/pull/3931) Do not ignore `#@` comments after empty line at start of test file
- [#4132](https://github.com/gap-system/gap/pull/4132) Fix a long standing bug which prevented `SetPrintFormattingStatus( "*stdout*", false );` from working as expected
- [#4232](https://github.com/gap-system/gap/pull/4232) Fix a bug where calling `NextIterator` on a "done" list iterator caused it to seemingly switch back to "not done" status
- [#4317](https://github.com/gap-system/gap/pull/4317) Fix `Cite` to again properly compute the year in which GAP was released
- [#4386](https://github.com/gap-system/gap/pull/4386) Fix the broken `--strict` option to `BuildPackages.sh`, but only if `--parallel` is not also specified
- [#4451](https://github.com/gap-system/gap/pull/4451) Fix printing of GAP code containing nested logical operators to correctly use parentheses (try e.g. `Print(x -> (x = x) = true);`)
- [#4759](https://github.com/gap-system/gap/pull/4759) Fix `Earns` to always returns a list, as documented (and other improvements)
- [#4794](https://github.com/gap-system/gap/pull/4794) Remove incorrect line breaks in the output of `StringFormatted`
- [#4855](https://github.com/gap-system/gap/pull/4855) Fix `SubgroupsSolvableGroup` to honor `retnorm` option even for trivial groups
- [#4928](https://github.com/gap-system/gap/pull/4928) Fix off-by-one error in `CopyListEntries` that could end up creating lists in which the last element is unbound

### Package distribution

#### New packages redistributed with GAP

- **classicpres** 1.22: Classical Group Presentations, by Alexander Hulpke, Eamonn O'Brien, Charles Leedham-Green, Madeleine Whybrow, Giovanni de Franceschi
- **StandardFF** 0.9.4: Standard finite fields and cyclic generators, by Frank Lübeck
- **UGALY** 4.0.3: Universal Groups Acting LocallY, by Khalil Hannouch, Stephan Tornier

#### Updated packages redistributed with GAP

The GAP 4.12.0 distribution contains 154
packages, of which 121 have been updated since GAP
4.11.1. The full list of updated packages is given below:

- [**4ti2Interface**](https://homalg-project.github.io/pkg/4ti2Interface): 2020.10-02 -> 2022.08-03
- [**ACE**](https://gap-packages.github.io/ace): 5.3 -> 5.5
- [**Alnuth**](https://gap-packages.github.io/alnuth): 3.1.2 -> 3.2.1
- [**ANUPQ**](https://gap-packages.github.io/anupq/): 3.2.1 -> 3.2.6
- [**AtlasRep**](https://www.math.rwth-aachen.de/~Thomas.Breuer/atlasrep): 2.1.0 -> 2.1.4
- [**AutoDoc**](https://gap-packages.github.io/AutoDoc): 2020.08.11 -> 2022.07.10
- [**Automata**](https://gap-packages.github.io/automata/): 1.14 -> 1.15
- [**AutPGrp**](https://gap-packages.github.io/autpgrp/): 1.10.2 -> 1.11
- [**Browse**](https://www.math.rwth-aachen.de/~Browse): 1.8.11 -> 1.8.14
- [**CAP**](https://homalg-project.github.io/pkg/CAP): 2020.10-01 -> 2022.08-05
- [**CaratInterface**](https://www.math.uni-bielefeld.de/~gaehler/gap/packages.php): 2.3.3 -> 2.3.4
- [**CddInterface**](https://homalg-project.github.io/CddInterface): 2020.06.24 -> 2022.08.11
- [**Circle**](https://gap-packages.github.io/circle): 1.6.3 -> 1.6.5
- [**cohomolo**](https://gap-packages.github.io/cohomolo): 1.6.8 -> 1.6.10
- [**Congruence**](https://gap-packages.github.io/congruence): 1.2.3 -> 1.2.4
- [**CoReLG**](https://gap-packages.github.io/corelg/): 1.54 -> 1.56
- [**CRIME**](https://gap-packages.github.io/crime/): 1.5 -> 1.6
- [**Cryst**](https://www.math.uni-bielefeld.de/~gaehler/gap/packages.php): 4.1.23 -> 4.1.25
- [**CrystCat**](https://www.math.uni-bielefeld.de/~gaehler/gap/packages.php): 1.1.9 -> 1.1.10
- [**CTblLib**](https://www.math.rwth-aachen.de/~Thomas.Breuer/ctbllib): 1.3.1 -> 1.3.4
- [**Cubefree**](https://gap-packages.github.io/cubefree/): 1.18 -> 1.19
- [**curlInterface**](https://gap-packages.github.io/curlInterface/): 2.2.1 -> 2.2.3
- [**cvec**](https://gap-packages.github.io/cvec): 2.7.4 -> 2.7.6
- [**datastructures**](https://gap-packages.github.io/datastructures): 0.2.5 -> 0.2.7
- [**DeepThought**](https://gap-packages.github.io/DeepThought/): 1.0.2 -> 1.0.5
- [**Digraphs**](https://digraphs.github.io/Digraphs): 1.3.1 -> 1.5.3
- [**Example**](https://gap-packages.github.io/example): 4.2.1 -> 4.3.2
- [**ExamplesForHomalg**](https://homalg-project.github.io/pkg/ExamplesForHomalg): 2020.10-02 -> 2022.08-02
- [**ferret**](https://gap-packages.github.io/ferret/): 1.0.3 -> 1.0.8
- [**FinInG**](https://gap-packages.github.io/FinInG): 1.4.1 -> 1.5
- [**float**](https://gap-packages.github.io/float/): 0.9.1 -> 1.0.3
- [**Forms**](https://gap-packages.github.io/forms): 1.2.5 -> 1.2.8
- [**FPLSA**](https://gap-packages.github.io/FPLSA): 1.2.4 -> 1.2.5
- [**FR**](https://gap-packages.github.io/fr): 2.4.6 -> 2.4.10
- [**GAPDoc**](http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc): 1.6.4 -> 1.6.6
- [**Gauss**](https://homalg-project.github.io/pkg/Gauss): 2020.10-02 -> 2022.08-04
- [**GaussForHomalg**](https://homalg-project.github.io/pkg/GaussForHomalg): 2020.10-02 -> 2022.08-02
- [**GBNP**](https://gap-packages.github.io/gbnp/): 1.0.3 -> 1.0.5
- [**GeneralizedMorphismsForCAP**](https://homalg-project.github.io/pkg/GeneralizedMorphismsForCAP): 2020.10-01 -> 2022.05-01
- [**genss**](https://gap-packages.github.io/genss): 1.6.6 -> 1.6.7
- [**GradedModules**](https://homalg-project.github.io/pkg/GradedModules): 2020.10-02 -> 2022.08-02
- [**GradedRingForHomalg**](https://homalg-project.github.io/pkg/GradedRingForHomalg): 2020.10-02 -> 2022.08-02
- [**GRAPE**](https://gap-packages.github.io/grape): 4.8.3 -> 4.8.5
- [**groupoids**](https://gap-packages.github.io/groupoids/): 1.68 -> 1.71
- [**Guarana**](https://gap-packages.github.io/guarana/): 0.96.2 -> 0.96.3
- [**GUAVA**](https://gap-packages.github.io/guava): 3.15 -> 3.16
- [**HAP**](https://gap-packages.github.io/hap): 1.29 -> 1.47
- [**HAPcryst**](https://gap-packages.github.io/hapcryst/): 0.1.13 -> 0.1.15
- [**homalg**](https://homalg-project.github.io/pkg/homalg): 2020.10-02 -> 2022.08-03
- [**HomalgToCAS**](https://homalg-project.github.io/pkg/HomalgToCAS): 2020.10-02 -> 2022.08-02
- [**idrel**](https://gap-packages.github.io/idrel/): 2.43 -> 2.44
- [**images**](https://gap-packages.github.io/images/): 1.3.0 -> 1.3.1
- [**IntPic**](https://gap-packages.github.io/intpic): 0.2.4 -> 0.3.0
- [**IO**](https://gap-packages.github.io/io): 4.7.0 -> 4.7.2
- [**IO_ForHomalg**](https://homalg-project.github.io/pkg/IO_ForHomalg): 2020.10-02 -> 2022.08-03
- [**IRREDSOL**](http://www.icm.tu-bs.de/~bhoeflin/irredsol/index.html): 1.4.1 -> 1.4.3
- [**ITC**](https://gap-packages.github.io/itc/): 1.5 -> 1.5.1
- [**json**](https://gap-packages.github.io/json/): 2.0.2 -> 2.1.0
- [**JupyterKernel**](https://gap-packages.github.io/JupyterKernel/): 1.3 -> 1.4.1
- [**JupyterViz**](https://nathancarter.github.io/jupyterviz): 1.5.1 -> 1.5.6
- [**kan**](https://gap-packages.github.io/kan/): 1.32 -> 1.34
- [**LAGUNA**](https://gap-packages.github.io/laguna): 3.9.3 -> 3.9.5
- [**LiePRing**](https://gap-packages.github.io/liepring/): 1.9.2 -> 2.7
- [**LieRing**](https://gap-packages.github.io/liering/): 2.4.1 -> 2.4.2
- [**LinearAlgebraForCAP**](https://homalg-project.github.io/pkg/LinearAlgebraForCAP): 2020.10-01 -> 2022.08-03
- [**LocalizeRingForHomalg**](https://homalg-project.github.io/pkg/LocalizeRingForHomalg): 2020.10-02 -> 2022.08-02
- [**loops**](https://gap-packages.github.io/loops/): 3.4.1 -> 3.4.2
- [**lpres**](https://gap-packages.github.io/lpres): 1.0.1 -> 1.0.3
- [**MapClass**](https://gap-packages.github.io/MapClass): 1.4.4 -> 1.4.5
- [**matgrp**](http://www.math.colostate.edu/~hulpke/matgrp): 0.64 -> 0.70
- [**MatricesForHomalg**](https://homalg-project.github.io/pkg/MatricesForHomalg): 2020.10-04 -> 2022.08-02
- [**ModIsom**](https://gap-packages.github.io/modisom/): 2.5.1 -> 2.5.3
- [**ModulePresentationsForCAP**](https://homalg-project.github.io/pkg/ModulePresentationsForCAP): 2020.10-01 -> 2022.08-02
- [**Modules**](https://homalg-project.github.io/pkg/Modules): 2020.10-02 -> 2022.08-03
- [**MonoidalCategories**](https://homalg-project.github.io/pkg/MonoidalCategories): 2020.10-01 -> 2022.08-03
- [**Nilmat**](https://gap-packages.github.io/nilmat): 1.4 -> 1.4.2
- [**NoCK**](https://gap-packages.github.io/NoCK): 1.4 -> 1.5
- [**NormalizInterface**](https://gap-packages.github.io/NormalizInterface): 1.1.0 -> 1.3.4
- [**nq**](https://gap-packages.github.io/nq/): 2.5.4 -> 2.5.8
- [**NumericalSgps**](https://gap-packages.github.io/numericalsgps): 1.2.2 -> 1.3.1
- [**OpenMath**](https://gap-packages.github.io/openmath): 11.5.0 -> 11.5.1
- [**orb**](https://gap-packages.github.io/orb): 4.8.3 -> 4.8.5
- [**PackageManager**](https://gap-packages.github.io/PackageManager/): 1.1 -> 1.3
- [**permut**](https://gap-packages.github.io/permut/): 2.0.3 -> 2.0.4
- [**Polenta**](https://gap-packages.github.io/polenta/): 1.3.9 -> 1.3.10
- [**polymaking**](https://gap-packages.github.io/polymaking/): 0.8.2 -> 0.8.6
- [**PrimGrp**](https://gap-packages.github.io/primgrp/): 3.4.1 -> 3.4.2
- [**profiling**](https://gap-packages.github.io/profiling/): 2.3 -> 2.5.0
- [**QPA**](https://folk.ntnu.no/oyvinso/QPA/): 1.31 -> 1.34
- [**QuaGroup**](https://gap-packages.github.io/quagroup/): 1.8.2 -> 1.8.3
- [**RadiRoot**](https://gap-packages.github.io/radiroot/): 2.8 -> 2.9
- [**RCWA**](https://gap-packages.github.io/rcwa/): 4.6.4 -> 4.7.0
- [**RDS**](https://gap-packages.github.io/rds/): 1.7 -> 1.8
- [**RepnDecomp**](https://gap-packages.github.io/RepnDecomp): 1.1.0 -> 1.2.1
- [**ResClasses**](https://gap-packages.github.io/resclasses/): 4.7.2 -> 4.7.3
- [**RingsForHomalg**](https://homalg-project.github.io/pkg/RingsForHomalg): 2020.11-01 -> 2022.08-03
- [**SCO**](https://homalg-project.github.io/pkg/SCO): 2020.10-02 -> 2022.08-02
- [**Semigroups**](https://semigroups.github.io/Semigroups): 3.4.0 -> 5.0.2
- [**SglPPow**](https://gap-packages.github.io/sglppow/): 2.1 -> 2.2
- [**SgpViz**](https://gap-packages.github.io/sgpviz): 0.999.4 -> 0.999.5
- [**simpcomp**](https://simpcomp-team.github.io/simpcomp): 2.1.10 -> 2.1.14
- [**SmallGrp**](https://gap-packages.github.io/smallgrp/): 1.4.2 -> 1.5
- [**Smallsemi**](https://gap-packages.github.io/smallsemi/): 0.6.12 -> 0.6.13
- [**SONATA**](https://gap-packages.github.io/sonata/): 2.9.1 -> 2.9.4
- [**Sophus**](https://gap-packages.github.io/sophus/): 1.24 -> 1.27
- [**SymbCompCC**](https://gap-packages.github.io/SymbCompCC/): 1.3.1 -> 1.3.2
- [**Thelma**](https://gap-packages.github.io/Thelma): 1.02 -> 1.3
- [**ToolsForHomalg**](https://homalg-project.github.io/pkg/ToolsForHomalg): 2020.10-03 -> 2022.08-02
- [**ToricVarieties**](https://homalg-project.github.io/ToricVarieties_project/ToricVarieties): 2021.01.12 -> 2022.07.13
- [**TransGrp**](https://www.math.colostate.edu/~hulpke/transgrp): 3.0 -> 3.6.3
- [**Unipot**](https://gap-packages.github.io/unipot/): 1.4 -> 1.5
- [**UnitLib**](https://gap-packages.github.io/unitlib): 4.0.0 -> 4.1.0
- [**utils**](https://gap-packages.github.io/utils): 0.69 -> 0.76
- [**uuid**](https://gap-packages.github.io/uuid/): 0.6 -> 0.7
- [**walrus**](https://gap-packages.github.io/walrus): 0.999 -> 0.9991
- [**Wedderga**](https://gap-packages.github.io/wedderga): 4.10.0 -> 4.10.2
- [**XGAP**](https://gap-packages.github.io/xgap): 4.30 -> 4.31
- [**XMod**](https://gap-packages.github.io/xmod/): 2.82 -> 2.88
- [**XModAlg**](https://gap-packages.github.io/xmodalg/): 1.18 -> 1.22
- [**YangBaxter**](https://gap-packages.github.io/YangBaxter): 0.9.0 -> 0.10.1
- [**ZeroMQInterface**](https://gap-packages.github.io/ZeroMQInterface/): 0.12 -> 0.14


## GAP 4.11.1 (March 2021)

### Fixed bugs that could lead to incorrect results

- [#4178](https://github.com/gap-system/gap/pull/4178) Fixed bugs in `RestrictedPerm` with second argument a range

### Fixed bugs that could lead to crashes

- [#3965](https://github.com/gap-system/gap/pull/3965) Fix potential garbage collector crashes on 64bit ARM systems
- [#4076](https://github.com/gap-system/gap/pull/4076) Fix an infinite loop in `BoundedRefinementEANormalSeries` if large factors could not be refined, fix protected option of `IsomorphismSimplifiedFpGroup`, improve documentation of `IsAutomorphismGroup`

### Fixed bugs that could lead to error messages

- [#3980](https://github.com/gap-system/gap/pull/3980) Fixed `Gcd` for rational polynomials

### Other fixed bugs

- [#3963](https://github.com/gap-system/gap/pull/3963) Provide automatic decompression of filenames ending `.gz` (as is in the documentation of `InputTextFile`)
- [#3944](https://github.com/gap-system/gap/pull/3944) The error checking in `PartialPerm` has been corrected such that invalid inputs (numbers < 1) are detected
- [#4006](https://github.com/gap-system/gap/pull/4006) Fix `gac` to ensure that binaries it creates on Linux can load and run, even if a GAP package with a compiled kernel extension (such as `IO`) is present

### Improved and extended functionality

- [#3790](https://github.com/gap-system/gap/pull/3790) Add further information to the library of simple groups
- [#3840](https://github.com/gap-system/gap/pull/3840) Speed up garbage collection

### Packages

- [#4016](https://github.com/gap-system/gap/pull/4016) Improved `etc/Makefile.gappkg` (used by GAP packages that want to build a simple GAP kernel extension)

### Fixes/improvements in the experimental way to allow 3rd party code to link GAP as a library (libgap)

- [#4081](https://github.com/gap-system/gap/pull/4081) Enhance `GAP_ValueGlobalVariable` to supported automatic variables (see `DeclareAutoreadableVariables`)
- [#4258](https://github.com/gap-system/gap/pull/4258) Fixed `GAP_Enter` macro so that GAP's recursion depth counter is saved/restored. Without this, if too many GAP errors occurred during runtime a segmentation fault could occur in the program using libgap

### Fixes and improvements for the **Julia** integration

- [#4042](https://github.com/gap-system/gap/pull/4042) Avoid access to JuliaTLS members by using `jl_threadid()` and `jl_get_current_task()` helpers, fix compiler constness warnings in weakptr.c
- [#4053](https://github.com/gap-system/gap/pull/4053) Fix the logic for scanning tasks in the Julia GC
- [#4058](https://github.com/gap-system/gap/pull/4058) Refine the logic for scanning Julia stacks
- [#4071](https://github.com/gap-system/gap/pull/4071) Make the Julia GC threadsafe when used from GAP.jl

### Other changes

- [#3922](https://github.com/gap-system/gap/pull/3922) Build system: New feature to execute `BuildPackages.sh` in parallel mode by adding `--parallel`
- [#4041](https://github.com/gap-system/gap/pull/4041) Build system: Fix `make check` in out-of-tree builds

### Packages no longer redistributed with GAP

**PolymakeInterface**: Following the withdrawal of the package **Convex** in GAP 4.11.0 because of being superseded by **NConvex**, the **PolymakeInterface** has also been withdrawn. These two packages are now replaced by **NormalizInterface** and **NConvex**.

### Updated packages redistributed with GAP

The GAP 4.11.1 distribution contains 151 packages, of which 49 have been updated since GAP 4.11.0. The changes include extending the Transitive Groups Library with representatives for all transitive permutation groups of degree at most 47 (due to Derek Holt), and fixing the ordering of groups of orders 3^7, 5^7, 7^7, 11^7 in the Small Groups Library. For other changes, we refer to the documentation of the packages. The full list of updated packages in the GAP 4.11.1 distribution is given below:

- [**4ti2Interface**](https://homalg-project.github.io/homalg_project/4ti2Interface/): 2019.09.02 -> 2020.10-02
- [**AGT**](https://github.com/rhysje00/agt): 0.1 -> 0.2
- [**AutoDoc**](https://gap-packages.github.io/AutoDoc): 2019.09.04 -> 2020.08.11
- [**Browse**](http://www.math.rwth-aachen.de/~Browse): 1.8.8 -> 1.8.11
- [**CAP**](http://homalg-project.github.io/CAP_project/CAP/): 2019.06.07 -> 2020.10-01
- [**CddInterface**](https://homalg-project.github.io/CddInterface): 2020.01.01 -> 2020.06.24
- [**CTblLib**](http://www.math.rwth-aachen.de/~Thomas.Breuer/ctbllib): 1.2.2 -> 1.3.1
- [**curlInterface**](https://gap-packages.github.io/curlInterface/): 2.1.1 -> 2.2.1
- [**Digraphs**](https://gap-packages.github.io/Digraphs): 1.1.1 -> 1.3.1
- [**ExamplesForHomalg**](https://homalg-project.github.io/homalg_project/ExamplesForHomalg/): 2019.09.02 -> 2020.10-02
- [**ferret**](https://gap-packages.github.io/ferret/): 1.0.2 -> 1.0.3
- [**GAPDoc**](http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc): 1.6.3 -> 1.6.4
- [**Gauss**](https://homalg-project.github.io/homalg_project/Gauss/): 2019.09.02 -> 2020.10-02
- [**GaussForHomalg**](https://homalg-project.github.io/homalg_project/GaussForHomalg/): 2019.09.02 -> 2020.10-02
- [**GeneralizedMorphismsForCAP**](http://homalg-project.github.io/CAP_project/GeneralizedMorphismsForCAP/): 2019.01.16 -> 2020.10-01
- [**GradedModules**](https://homalg-project.github.io/homalg_project/GradedModules/): 2020.01.02 -> 2020.10-02
- [**GradedRingForHomalg**](https://homalg-project.github.io/homalg_project/GradedRingForHomalg/): 2020.01.02 -> 2020.10-02
- [**HAP**](https://gap-packages.github.io/hap): 1.25 -> 1.29
- [**homalg**](https://homalg-project.github.io/homalg_project/homalg/): 2019.09.01 -> 2020.10-02
- [**HomalgToCAS**](https://homalg-project.github.io/homalg_project/HomalgToCAS/): 2019.12.08 -> 2020.10-02
- [**IO_ForHomalg**](https://homalg-project.github.io/homalg_project/IO_ForHomalg/): 2019.09.02 -> 2020.10-02
- [**IRREDSOL**](http://www.icm.tu-bs.de/~bhoeflin/irredsol/index.html): 1.4 -> 1.4.1
- [**json**](https://gap-packages.github.io/json/): 2.0.1 -> 2.0.2
- [**kan**](https://gap-packages.github.io/kan/): 1.29 -> 1.32
- [**LinearAlgebraForCAP**](http://homalg-project.github.io/CAP_project/LinearAlgebraForCAP/): 2019.01.16 -> 2020.10-01
- [**LocalizeRingForHomalg**](https://homalg-project.github.io/homalg_project/LocalizeRingForHomalg/): 2019.09.02 -> 2020.10-02
- [**matgrp**](http://www.math.colostate.edu/~hulpke/matgrp): 0.63 -> 0.64
- [**MatricesForHomalg**](https://homalg-project.github.io/homalg_project/MatricesForHomalg/): 2020.01.02 -> 2020.10-04
- [**ModulePresentationsForCAP**](http://homalg-project.github.io/CAP_project/ModulePresentationsForCAP/): 2019.01.16 -> 2020.10-01
- [**Modules**](https://homalg-project.github.io/homalg_project/Modules/): 2019.09.02 -> 2020.10-02
- [**MonoidalCategories**](http://homalg-project.github.io/CAP_project/MonoidalCategories/): 2019.06.07 -> 2020.10-01
- [**NConvex**](https://homalg-project.github.io/NConvex): 2019.12.10 -> 2020.11-04
- [**NumericalSgps**](https://gap-packages.github.io/numericalsgps): 1.2.1 -> 1.2.2
- [**PackageManager**](https://gap-packages.github.io/PackageManager/): 1.0 -> 1.1
- [**Polycyclic**](https://gap-packages.github.io/polycyclic/): 2.15.1 -> 2.16
- [**PrimGrp**](https://gap-packages.github.io/primgrp/): 3.4.0 -> 3.4.1
- [**profiling**](https://gap-packages.github.io/profiling/): 2.2.1 -> 2.3
- [**QPA**](https://folk.ntnu.no/oyvinso/QPA/): 1.30 -> 1.31
- [**RingsForHomalg**](https://homalg-project.github.io/homalg_project/RingsForHomalg/): 2019.12.08 -> 2020.11-01
- [**SCO**](https://homalg-project.github.io/homalg_project/SCO/): 2019.09.02 -> 2020.10-02
- [**Semigroups**](https://gap-packages.github.io/Semigroups): 3.2.3 -> 3.4.0
- [**singular**](https://gap-packages.github.io/singular/): 2019.10.01 -> 2020.12.18
- [**SmallGrp**](https://gap-packages.github.io/smallgrp/): 1.4.1 -> 1.4.2
- [**ToolsForHomalg**](https://homalg-project.github.io/homalg_project/ToolsForHomalg/): 2019.09.02 -> 2020.10-03
- [**ToricVarieties**](https://homalg-project.github.io/ToricVarieties_project/ToricVarieties/): 2019.12.05 -> 2021.01.12
- [**TransGrp**](https://www.math.colostate.edu/~hulpke/transgrp): 2.0.5 -> 3.0
- [**Wedderga**](https://gap-packages.github.io/wedderga): 4.9.5 -> 4.10.0
- [**XMod**](https://gap-packages.github.io/xmod/): 2.77 -> 2.82
- [**XModAlg**](https://gap-packages.github.io/xmodalg/): 1.17 -> 1.18


## GAP 4.11.0 (February 2020)

### New features and major changes

- **Removed ability to return objects from many error break loops**

  Many error break loops in GAP used to allow replacing an object in a
  computation by another one. This ability was very tricky to use, and leads
  to computation results that are difficult to reproduce. At the same time,
  supporting this adds complexity to the GAP kernel. We therefore decided to
  remove this feature. Right now, this is not yet fully done, but we removed
  about 3/4 of these, and will remove the rest in a future GAP release. (See
  e.g. PR [#2966](https://github.com/gap-system/gap/pull/2966)).

- **GAP now contains some C++ code**

  Therefore, in order to compile it, you need a C++ compiler. See
  [#2667](https://github.com/gap-system/gap/pull/2667) for the rationale.

- **HPC-GAP**

  The `ward` tool has been decommissioned in PR
  [#2870](https://github.com/gap-system/gap/pull/2870). In the future, guard
  checks will be performed in a different way; however, this code is not yet
  complete (see PR [#2845](https://github.com/gap-system/gap/pull/2845)). In
  the meantime, guard checking is broken. If you are interested in using
  HPC-GAP, please consider helping us to fix this and other issues with it.

- **Syntax trees**

  Functions were added which allow converting a GAP function object into an
  abstract syntax tree which can be parsed and modified from within GAP code
  (see PR [#2628](https://github.com/gap-system/gap/pull/2628)). Moreover, it
  is possible to convert such a syntax tree (possibly after modifying it) back
  into a GAP function object (see PR
  [#3371](https://github.com/gap-system/gap/pull/3371)).

### Improved and extended functionality

- [#1633](https://github.com/gap-system/gap/pull/1633) Allow local variables in test files via `#@local <list of variables to be local>`, and conditional execution of tests via `#@if`, `#@else`, `#@endif`
- [#2520](https://github.com/gap-system/gap/pull/2520) Overhaul tracking of current statement, fixing several bugs where the break loop error message referenced the wrong statement
- [#2772](https://github.com/gap-system/gap/pull/2772) Add support for profiling interpreted code
- [#2773](https://github.com/gap-system/gap/pull/2773) Reorder methods after new implications are added
- [#2830](https://github.com/gap-system/gap/pull/2830) Undocumented functionality has now been extended and documented that allows one to construct the Green's classes of a semigroup that are contained in another Green's class (e.g. constructing the H-classes contained in an R-class)
- [#2856](https://github.com/gap-system/gap/pull/2856) Make `AtExit` a stack and make `DirectoryTemporary` more robust
- [#2869](https://github.com/gap-system/gap/pull/2869) Fix `+` and `*` methods for a `DirectProductElement` and a non-list collection
- [#2873](https://github.com/gap-system/gap/pull/2873) The GAP kernel version is now available in the configure script
- [#2876](https://github.com/gap-system/gap/pull/2876) `IsomorphismTransformationSemigroup` now returns an `IdentityMapping` for a transformation semigroup
- [#2923](https://github.com/gap-system/gap/pull/2923) Extend obsolete to support multiple levels
- [#2936](https://github.com/gap-system/gap/pull/2936) Add back `ViewObj` method for generic fields
- [#2952](https://github.com/gap-system/gap/pull/2952) Add command line option `--bare` to start GAP without even needed packages (developer tool)
- [#2960](https://github.com/gap-system/gap/pull/2960) Add `List` method accepting an iterator and a function
- [#2946](https://github.com/gap-system/gap/pull/2946),
  [#2955](https://github.com/gap-system/gap/pull/2955),
  [#2974](https://github.com/gap-system/gap/pull/2974),
  [#3372](https://github.com/gap-system/gap/pull/3372) Improve many error messages
- [#2985](https://github.com/gap-system/gap/pull/2985) Improve support for custom list object implementations
- [#2998](https://github.com/gap-system/gap/pull/2998),
  [#2999](https://github.com/gap-system/gap/pull/2999),
  [#3007](https://github.com/gap-system/gap/pull/3007) Expose additional functionality related to chars, floats and integers via the libgap API
- [#2900](https://github.com/gap-system/gap/pull/2900) Teach `Test` to abort test if ctrl-C is pressed
- [#2910](https://github.com/gap-system/gap/pull/2910) Add custom `SetDimension` implementation, and call `SetDimension(A,0)` in places creating trivial modules or algebras
- [#2924](https://github.com/gap-system/gap/pull/2924) Improve performance of `NormalizerViaRadical`
- [#3031](https://github.com/gap-system/gap/pull/3031) Improve performance of `ConjugacyClasses` for solvable groups
- [#3053](https://github.com/gap-system/gap/pull/3053) More properties can now be preserved when constructing direct products of semigroups
- [#3075](https://github.com/gap-system/gap/pull/3075) Special redispatch for `Nat.Hom.ByNS` if group is found out to be finite
- [#3076](https://github.com/gap-system/gap/pull/3076) Add `IsAutoGlobal` for testing whether a variable was declared using `DeclareAutoreadableVariables`
- [#3077](https://github.com/gap-system/gap/pull/3077) Allow appending to the command line history
- [#3078](https://github.com/gap-system/gap/pull/3078) Avoid memory issues in solvable conjugacy classes routine
- [#3080](https://github.com/gap-system/gap/pull/3080) Method to compute Hall subgroups of arbitrary finite groups.
- [#3093](https://github.com/gap-system/gap/pull/3093) Methods transforming small matrix groups into permutation groups now work for objects of type `IsMatrixObj`
- [#3099](https://github.com/gap-system/gap/pull/3099) Show a warning when `GroupWithGenerators` called on a domain
- [#3104](https://github.com/gap-system/gap/pull/3104) Extend `IntegratedStraightLineProgram` to the situation that some of the input programs return lists of elements
- [#3118](https://github.com/gap-system/gap/pull/3118) Make `Refinements` an `AtomicRecord` so it can be added to by users
- [#3129](https://github.com/gap-system/gap/pull/3129) `BrauerTableOp` now works for cyclic defect such that all Brauer characters lift to characteristic zero
- [#3168](https://github.com/gap-system/gap/pull/3168) Allow input and output to be mixed in `Test`
- [#3207](https://github.com/gap-system/gap/pull/3207) Display for functions with large literals is improved
- [#3626](https://github.com/gap-system/gap/pull/3626) Customisable names of classes and characters in `Display` of character tables
- [#3621](https://github.com/gap-system/gap/pull/3621) Add `Display` method for PC group
- [#3209](https://github.com/gap-system/gap/pull/3209) Enable backtraces with `--enable-debug`
- [#3226](https://github.com/gap-system/gap/pull/3226) Make `last`, `last2`, `last3`,`time` and `memory_allocated` read-only
- [#3231](https://github.com/gap-system/gap/pull/3231) Speed up `IsConjugate` for `IsNaturalSymmetricGroup`
- [#3247](https://github.com/gap-system/gap/pull/3247) `CloseMutableBasis` now returns `true` if the basis was extended and `false` otherwise
- [#3252](https://github.com/gap-system/gap/pull/3252) Improve gac to preserve argument names of compiled functions
- [#3253](https://github.com/gap-system/gap/pull/3253) `CharacterTableIsoclinic` now works for groups of type p.G.p
- [#3267](https://github.com/gap-system/gap/pull/3267) Change `StructureDescription` of an infinite cyclic group from `C0` to `Z`
- [#3278](https://github.com/gap-system/gap/pull/3278) Improve method for `IsSolvableGroup`
- [#3335](https://github.com/gap-system/gap/pull/3335) Reduce memory usage on windows when running external programs
- [#3365](https://github.com/gap-system/gap/pull/3365) Add `First(list)`, `Last(list)` and `Last(list,func)`
- [#3370](https://github.com/gap-system/gap/pull/3370) Pragmas are now available
- [#3376](https://github.com/gap-system/gap/pull/3376) `SortedList` now accepts a function as the second argument
- [#3383](https://github.com/gap-system/gap/pull/3383) Implement 2-cohomology and module computations for arbitrary finite groups, not just solvable ones, via `TwoCohomologyGeneric`
- [#3384](https://github.com/gap-system/gap/pull/3384) Improve performance of subgroup calculations (e.g. via `ConjugacyClassesSubgroups`) in some cases
- [#3385](https://github.com/gap-system/gap/pull/3385) Add `FlipBlist`, `ClearAllBlist`, `SetAllBlist`
- [#3387](https://github.com/gap-system/gap/pull/3387) Add `ShowUsedInfoClasses`
- [#3394](https://github.com/gap-system/gap/pull/3394) Make the descriptions for TNUMs (which we print in some error messages) more user friendly
- [#3399](https://github.com/gap-system/gap/pull/3399) Support floating point numbers when specifying how much memory GAP should use, for example "-o 2.5G"
- [#3420](https://github.com/gap-system/gap/pull/3420) Give more library methods human-readable names. These are used when profiling
- [#3423](https://github.com/gap-system/gap/pull/3423) Improve gac to support calls to custom function objects
- [#3430](https://github.com/gap-system/gap/pull/3430) `NameFunction` now is an attribute so that custom function objects can implement support for it
- [#3454](https://github.com/gap-system/gap/pull/3454) Improve error handling for `Image`, `Images`, `PreImage` and `PreImages`
- [#3455](https://github.com/gap-system/gap/pull/3455) New function `DirectProductFamily`
- [#3459](https://github.com/gap-system/gap/pull/3459) Add `ShowDeclarationsOfOperation` helper
- [#3473](https://github.com/gap-system/gap/pull/3473) Improve an `AsList` method for domains with stored `GeneratorsOfDomain`
- [#3483](https://github.com/gap-system/gap/pull/3483) Change the pre-set memory limit default from 2GB to 3/4 of physical memory. Use the `-o` option if you want to change this limit.
- [#3501](https://github.com/gap-system/gap/pull/3501) `MaximalSubgroups` now works even if `tomlib` is not available
- [#3504](https://github.com/gap-system/gap/pull/3504) `make bootstrap` now uses `curl` if `wget` is unavailable under macOS
- [#3516](https://github.com/gap-system/gap/pull/3516) Improve performance of the Julia GC integration
- [#3520](https://github.com/gap-system/gap/pull/3520) Clarify when *nonabelian* simple groups are meant in the documentation
- [#3522](https://github.com/gap-system/gap/pull/3522) Add `IsNonabelianSimpleGroup`
- [#3542](https://github.com/gap-system/gap/pull/3542) Add `--add-package-config-<PACKAGENAME>="<CONFIG_ARGS>"` option to `BuildPackages.sh` where `<CONFIG_ARGS>` are passed through to the configure script of package `<PACKAGENAME>`
- [#3543](https://github.com/gap-system/gap/pull/3543) Add `PositionSortedBy`
- [#3551](https://github.com/gap-system/gap/pull/3551) Add new kernel operations `ELM_MAT`, `ASS_MAT`
- [#3513](https://github.com/gap-system/gap/pull/3513) Use `posix_spawn` in `iostreams` if available
- [#3554](https://github.com/gap-system/gap/pull/3554) Add basic libgap APIs for working with matrices
- [#3564](https://github.com/gap-system/gap/pull/3564) Add `WhereWithVars`, an extended version of `Where` which prints the values of all arguments and locals
- [#3566](https://github.com/gap-system/gap/pull/3566) Optimise operations involving identity permutations, improve printing of permutations
- [#3630](https://github.com/gap-system/gap/pull/3630) Speed up `MaximalAbelianQuotient` for subgroups of fp groups
- [#3579](https://github.com/gap-system/gap/pull/3579) Speed up writing to global variables
- [#3592](https://github.com/gap-system/gap/pull/3592) The values of computed attributes will no longer be stored automatically in mutable attribute-storing objects
- [#3604](https://github.com/gap-system/gap/pull/3604) Add `EuclideanDegree` and `QuotientRemainder` for Z/nZ
- [#3619](https://github.com/gap-system/gap/pull/3619) `Randomize` is now documented, and its definition changed: **note** that it is now `Randomize(random_source, obj)`
- [#3620](https://github.com/gap-system/gap/pull/3620) `make html` can be used to compile only HTML versions of the GAP manuals, without a PDF.
- [#3683](https://github.com/gap-system/gap/pull/3683) Add `etc/Makefile.gappkg`, for use in the build system of GAP package with kernel extensions
- [#3690](https://github.com/gap-system/gap/pull/3690) Improve `NullspaceModQ` to support arbitrary moduli, and renamed it to `NullspaceModN` (the old name is still available as a synonym)
- [#3711](https://github.com/gap-system/gap/pull/3711) Adjust `TestPackage` to return information about the test result
- [#3715](https://github.com/gap-system/gap/pull/3715) Allow HPC-GAP to run as a forkable server process
- [#3745](https://github.com/gap-system/gap/pull/3745) Add a new kernel header `gap_all.h` for use by package authors instead of `compiled.h`
- [#3746](https://github.com/gap-system/gap/pull/3746) Allow package build systems to detect GAP version by inserting `GAP_VERSION` into `sysinfo.gap`
- [#3606](https://github.com/gap-system/gap/pull/3606) Add BindingsOfClosure helper (_Work in progress_)


### Changed documentation

- [#3886](https://github.com/gap-system/gap/pull/3886) Convert `Changes` manuals book into markdown
- [#2798](https://github.com/gap-system/gap/pull/2798) Clarify `MemoizePosIntFunction` documentation
- [#2946](https://github.com/gap-system/gap/pull/2946) Document what a "small integer" resp. "immediate integer" is
- [#2953](https://github.com/gap-system/gap/pull/2953) Document that `PermutationGModule` works not just for finite fields
- [#3101](https://github.com/gap-system/gap/pull/3101) Remove Section 87.2-5 on "Avoiding multiplication of permutations" in the reference manual (the described functionality does not actually work)
- [#3348](https://github.com/gap-system/gap/pull/3348) Add explanation for a workaround regarding the ^-key on OSX to `INSTALL.md`
- [#3358](https://github.com/gap-system/gap/pull/3358) Document the two-argument version of `Set`
- [#3360](https://github.com/gap-system/gap/pull/3360) Improve discoverability of `rewriteToFile` option in `Test`
- [#3363](https://github.com/gap-system/gap/pull/3363) Add some information in the documentation of `IsPrimitive`.
- [#3374](https://github.com/gap-system/gap/pull/3374) Document that InputTextFile should not be used for binary files
- [#3449](https://github.com/gap-system/gap/pull/3449) Clarify and corrects documentation of `CompositionMapping`
- [#3453](https://github.com/gap-system/gap/pull/3453) Improve documentation of `GeneratorsOfDomain`
- [#3468](https://github.com/gap-system/gap/pull/3468) New `PrintObj` method for general domains which know their `GeneratorsOfDomain`
- [#3469](https://github.com/gap-system/gap/pull/3469) `DeclareCategoryCollections`, `constructors` are now documented and parts of the reference manual are refactored
- [#3472](https://github.com/gap-system/gap/pull/3472) Document `IsRangeRep` and improve the documentation of `ConvertToRangeRep`, `IsRange`, and the section `Ranges`
- [#3529](https://github.com/gap-system/gap/pull/3529) Document `CharacteristicSubgroups`
- [#3591](https://github.com/gap-system/gap/pull/3591) Improve parts of the documentation in Chapter 41.
- [#3615](https://github.com/gap-system/gap/pull/3615) Document basic representations of objects (`IsInternalRep`, `IsDataObjectRep`, `IsComponentObjectRep`, `IsPositionalObjectRep`, `IsAttributeStoringRep`, `IsPlistRep`)
- [#3612](https://github.com/gap-system/gap/pull/3612) Improves the documentation of `Quotient` to make it sensible for non-commutative rings, and rings with zero divisors

### Fixed bugs that could lead to crashes

- [#3151](https://github.com/gap-system/gap/pull/3151) Fix crash when `ApplicableMethod` is called incorrectly
- [#3221](https://github.com/gap-system/gap/pull/3221) Handle infinite recursion in attribute methods
- [#3491](https://github.com/gap-system/gap/pull/3491) Fix crashes when passing invalid arguments to functions for records: `\.`, `IsBound\.`, `Unbind\.` and `\.\:\=`
- [#3738](https://github.com/gap-system/gap/pull/3738) Fix bug in `CycleStructurePerm` for a single cycle of length 2^16 that caused wrong answers and memory corruption

### Fixed bugs that could lead to incorrect results

- [#2938](https://github.com/gap-system/gap/pull/2938) Fix bug related to `ImaginaryPart` for quaternion algebras
- [#3103](https://github.com/gap-system/gap/pull/3103) This fixes [#3097](https://github.com/gap-system/gap/issues/3097), a problem with `Order` of automorphism
    and [#3100](https://github.com/gap-system/gap/issues/3100), a problem with `GroupHomomorphismByImages`
- [#3392](https://github.com/gap-system/gap/pull/3392) Prevent blist functions that modify an argument in-place (such as `UniteBlist`) from modifying immutable blists
- [#3522](https://github.com/gap-system/gap/pull/3522) `IsSimpleGroup` does not imply `IsAlmostSimpleGroup` anymore
- [#3575](https://github.com/gap-system/gap/pull/3575) Fix bug in calculating x/p for an integer x and permutation p, if p has been 'trimmed'.
- [#3603](https://github.com/gap-system/gap/pull/3603) Fix bug where the result of `StandardAssociateUnit` could be not a unit.
- [#3611](https://github.com/gap-system/gap/pull/3611) Fix `StandardAssociateUnit` for polynomial rings to return a polynomial, not an element of the coefficient ring
- [#3646](https://github.com/gap-system/gap/pull/3646) Fix bug in `MinimalFaithfulPermutationDegree` that reported a too large degree for certain groups representable as subdirect product
- [#3662](https://github.com/gap-system/gap/pull/3662) Fix bug in `MaximalSubgroupClassReps` that could lead to a wrong result
- [#3689](https://github.com/gap-system/gap/pull/3689) Fix bug in `BlistList` for two ranges that could lead to wrong results
- [#3690](https://github.com/gap-system/gap/pull/3690) Fix bug `NullspaceModQ` that could lead to wrong results
- [#3733](https://github.com/gap-system/gap/pull/3733) Fix `ConstituentsOfCharacter` for Brauer character: its result, when called with a Brauer character as its only argument, was not reliable. (This bug has been reported by Gabriel Navarro.) Also, calling it with a Brauer character table and a virtual Brauer character caused error messages

### Fixed bugs that could lead to break loops

- [#3038](https://github.com/gap-system/gap/pull/3038) Fix `RankOfPartialPermSemigroup` for partial perm groups with empty `GeneratorsOfGroup`
- [#3052](https://github.com/gap-system/gap/pull/3052) Fix the viewing of empty transformation semigroups
- [#3110](https://github.com/gap-system/gap/pull/3110) Workaround for Issue [#3055](https://github.com/gap-system/gap/issues/3055) and fix for `GQuotient`
- [#3142](https://github.com/gap-system/gap/pull/3142) Fix `Int` and `Rat` for float values `nan`, `inf`, `-inf`
- [#3192](https://github.com/gap-system/gap/pull/3192) Catch some corner cases for trivial group
- [#3331](https://github.com/gap-system/gap/pull/3331) Fix an issue with `IsomorphismGroups` if one group is finite and the other is infinite.
- [#3375](https://github.com/gap-system/gap/pull/3375) Improve warnings when using tabs in continuations
- [#3401](https://github.com/gap-system/gap/pull/3401) `SSortedLists` is not required to be homogeneous anymore
- [#3437](https://github.com/gap-system/gap/pull/3437) Fix a bug with in calculating `SubdirectProducts` which could sometimes fail on valid input.
- [#3559](https://github.com/gap-system/gap/pull/3559) Fix `IsUpperTriangularMat` for non-square matrices
- [#3571](https://github.com/gap-system/gap/pull/3571) Fix `NrCols` and `NumberColumns` for empty matrices in `IsMatrix`
- [#3763](https://github.com/gap-system/gap/pull/3763) Fix bug in `IrrConlon` leading to unexpected errors
- [#3865](https://github.com/gap-system/gap/pull/3865) Fix the code setting up a subgroup data structure by the solvable radical method, which could lead to unexpected errors

### Other fixed bugs

- [#2595](https://github.com/gap-system/gap/pull/2595) Fix missing syntax warning for using undefined global variable
- [#2756](https://github.com/gap-system/gap/pull/2756) Reject invalid AND-filters such as `Center and IsAssociative`
- [#2903](https://github.com/gap-system/gap/pull/2903) Kernel: make `OnLeftInverse` use `LQUO`
- [#2908](https://github.com/gap-system/gap/pull/2908) Fix profiling when `IO_Fork` from the `IO package` is used
- [#2977](https://github.com/gap-system/gap/pull/2977) This fixes an infinite recursion if the rank of `IsGroup` and `IsFinite` becomes very large
- [#3189](https://github.com/gap-system/gap/pull/3189) Ensure `IsHomogeneousList("")` return `true`
- [#3229](https://github.com/gap-system/gap/pull/3229) Fix the fact that the `^^^^` markers on unbound globals would point to the wrong place.
- [#3320](https://github.com/gap-system/gap/pull/3320) Fix the problem whereby if GAP on windows sees a `\r`, it will remove the next `\n`, no matter how far away it is.
- [#3325](https://github.com/gap-system/gap/pull/3325) Fix libgap's `GAP_ENTER_DEBUG` macro (using it previously lead to a linker error)
- [#3390](https://github.com/gap-system/gap/pull/3390) Corrects input limit on 64Bit `SetCyclotomicsLimit`
- [#3395](https://github.com/gap-system/gap/pull/3395) `PrintObj(1.)` now correctly prints `1.`
- [#3400](https://github.com/gap-system/gap/pull/3440) Fix the line breaking hints in the `ViewString` method for finite lists.
- [#3428](https://github.com/gap-system/gap/pull/3428) Fix GNU readline detection on OpenBSD, and make the configure test for it more robust
- [#3444](https://github.com/gap-system/gap/pull/3444) Remove obsolete `-a` command line option
- [#3481](https://github.com/gap-system/gap/pull/3481) Fix bug which caused code which calls `PrintCSV` many times with a filename to fail eventually
- [#3580](https://github.com/gap-system/gap/pull/3580) Fix potential infinite loop or recursion when computing the size of infinite cyclic groups
- [#3847](https://github.com/gap-system/gap/pull/3847) Fix printing of certain words in free groups (if subexpressions occur as powers iteratedly then nonsense could be displayed, but the data internally was correct)
- [#3610](https://github.com/gap-system/gap/pull/3610) Invalid use of `/` on ZmodZ (e.g. dividing a unit by a zero divisor) will produce an `Error`
- [#3612](https://github.com/gap-system/gap/pull/3612) fixes some methods for `Quotient`, in particular `Quotient(R, x, Zero(R))` now returns `fail`

### Removed or obsolete functionality

- [#2237](https://github.com/gap-system/gap/pull/2237) The undocumented (!) functions `InfoRead1` and `InfoRead2` are obsolete
- [#2237](https://github.com/gap-system/gap/pull/2237),
  [#2961](https://github.com/gap-system/gap/pull/2961) Remove the obsolete synonyms `MutableIdentityMat` (for `IdentityMat`), `MutableNullMat` (for `NullMat`) and `SHALLOW_SIZE` (for `SIZE_OBJ`), `DEBUG_LOADING` (for `GAPInfo.CommandLineOptions.D`)
- [#2919](https://github.com/gap-system/gap/pull/2919) The undocumented (!) function `SetFeatureObj` is obsolete; use `SetFilterObj` resp. `ResetFilterObj` instead.
- [#3185](https://github.com/gap-system/gap/pull/3185) `(Un)HideGlobalVariables` is obsolete
- [#3269](https://github.com/gap-system/gap/pull/3269) `TemporaryGlobalVarName` is obsolete
- [#3409](https://github.com/gap-system/gap/pull/3409) Remove `BANNER`, `QUIET`

### Packages

- [#3215](https://github.com/gap-system/gap/pull/3215) Issue tracker, maintainers and contributors are printed in package banners
- [#3286](https://github.com/gap-system/gap/pull/3286) Teach `ValidatePackageInfo` about the optional `License` field

### Other changes

- [#2709](https://github.com/gap-system/gap/pull/2709) Rename `MultRowVector` to `MultVector` (the old name is still supported, but marked as obsolete)
- [#2729](https://github.com/gap-system/gap/pull/2729) Rename `QuaternionGroup` to `DicyclicGroup`, document `IsDihedralGroup` and `IsQuaternionGroup`
- [#3010](https://github.com/gap-system/gap/pull/3010) Read `lib/transatl.g` before any `gap.ini` file, when GAP is loaded
- [#3406](https://github.com/gap-system/gap/pull/3406) Remove RXVT-shell support for Windows
- [#3480](https://github.com/gap-system/gap/pull/3480) `BuildPackages.sh` now executes `make clean` before full build

### New packages redistributed with GAP

- [AGT](https://gap-packages.github.io/agt/) A library of strongly regular graphs on at most 40 vertices, and functionality to inspect combinatorial and algebraic properties of graphs in GRAPE format, by Rhys J. Evans
- [CddInterface](https://homalg-project.github.io/CddInterface/) GAP interface to cdd, by Kamal Saleh
- [DifSets](https://dylanpeifer.github.io/difsets/)  Enumeration of the difference sets (up to equivalence) in groups, by Dylan Peifer
- [ferret](https://gap-packages.github.io/ferret/) C++ reimplementation of Jeffery Leon’s Partition Backtrack framework for solving problems in permutation groups, by Christopher Jefferson
- [images](https://gap-packages.github.io/images/) Finding minimal and canonical images in permutation groups, by Christopher Jefferson, Markus Pfeiffer, Rebecca Waldecker, Eliza Jonauskyte
- [NCOnvex](https://homalg-project.github.io/NConvex/) Polyhedral constructions and computations for cones, polyhedrons, polytopes and fans, by Kamal Saleh, Sebastian Gutsche
- [NoCK](https://pjastr.github.io/NoCK/) Computation of Tolzanos’s obstruction for compact Clifford-Klein forms, by Maciej Bocheński, Piotr Jastrzębski, Anna Szczepkowska, Aleksy Tralle, Artur Woike
- [RepnDecomp](https://gap-packages.github.io/RepnDecomp/) Algorithms for decomposing linear representations of finite groups, by Kaashif Hymabaccus

## GAP 4.10.2 (June 2019)

### Improvements in the experimental way to allow 3rd party code to link GAP as a library:

  - Add `GAP_AssignGlobalVariable` and
    `GAP_IsNameOfWritableGlobalVariable` to the **libGAP** API
    ([#3438](https://github.com/gap-system/gap/pull/3438)).

### Fixes in the experimental support for using the **Julia** garbage collector:

  - Fix of a problem where the Julia GC during a partial sweep frees
    some, but not all objects of an unreachable data structure, and also
    may erroneously try to mark the deallocated objects
    ([#3412](https://github.com/gap-system/gap/pull/3412)).

  - Fix stack scanning for the Julia GC when GAP is used as a library
    ([#3432](https://github.com/gap-system/gap/pull/3432)).

### Fixed bugs that could lead to crashes:

  - Fix a bug in `TransformationListList` which could cause a crash
    ([#3463](https://github.com/gap-system/gap/pull/3463)).

### Fixed bugs that could lead to incorrect results:

  - Fix a bug in `ClassPositionsOfLowerCentralSeries`. (Reported by Frieder
    Ladisch) ([#3321](https://github.com/gap-system/gap/pull/3321)).

  - Fix a dangerous bug in the comparison of large negative integers,
    introduced in GAP 4.10.1: if `x` and `y` were equal, but not
    identical, large negative numbers then `x < y` returned `true`
    instead of `false`.
    ([#3478](https://github.com/gap-system/gap/pull/3478)).

### Fixed bugs that could lead to break loops:

  - If the group has been obtained as subgroup from a Fitting
    free/solvable radical computation, the data is inherited and might
    not guarantee that the factor group really is Fitting free. Added a
    check and an assertion to catch this situation
    ([#3154](https://github.com/gap-system/gap/pull/3154)).

  - Fix declaration of sparse action homomorphisms
    ([#3281](https://github.com/gap-system/gap/pull/3281)).

  - `LatticeViaRadical` called `ClosureSubgroupNC` assuming that the
    parent contained all generators. It now calls `ClosureSubgroup`
    instead, since this cannot always be guaranteed (this could
    happen, for example, in perfect subgroup computation). Also
    added an assertion to `ClosureSubgroupNC` to catch this
    situation in other cases. (Reported by Serge Bouc)
    ([#3397](https://github.com/gap-system/gap/pull/3397)).

  - Fix a "method not found" error in `SubdirectProduct`
    ([#3485](https://github.com/gap-system/gap/pull/3485)).

### Other fixed bugs:

  - Fix corner case in modified Todd-Coxeter algorithm when relator is
    trivial ([#3311](https://github.com/gap-system/gap/pull/3311)).

### New and updated packages since GAP 4.10.1

GAP 4.10.2 distribution contains 145 packages, including updated
versions of 55 packages from GAP 4.10.1 distribution,

A new package **MonoidalCategories** by Mohamed Barakat, Sebastian
Gutsche and Sebastian Posur have been added to the distribution. It is
based on the **CAP** package and implements monoidal structures for
**CAP**.

Unfortunately we had to withdraw the **QaoS** package from distribution
of GAP, as the servers it crucially relies on for its functionality have
been permanently retired some time ago and are not coming back
([details](https://github.com/gap-packages/qaos/issues/13)).


## GAP 4.10.1 (February 2019)

### Fixes in the experimental way to allow 3rd party code to link GAP as a library:

  - Do not start a session when loading workspace if `--nointeract`
    command line option is used
    ([#2840](https://github.com/gap-system/gap/pull/2840)).

  - Add prototype for `GAP_Enter` and `GAP_Leave` macros
    ([#3096](https://github.com/gap-system/gap/pull/3096)).

  - Prevent infinite recursions in `echoandcheck` and `SyWriteandcheck`
    ([#3102](https://github.com/gap-system/gap/pull/3102)).

  - Remove `environ` arguments and `sysenviron`
    ([#3111](https://github.com/gap-system/gap/pull/3111)).

### Fixes in the experimental support for using the Julia garbage collector:

  - Fix task scanning for the Julia GC
    ([#2969](https://github.com/gap-system/gap/pull/2969)).

  - Fix stack marking for the Julia GC
    ([#3199](https://github.com/gap-system/gap/pull/3199)).

  - Specify the Julia binary instead of the Julia prefix
    ([#3243](https://github.com/gap-system/gap/pull/3243)).

  - Export Julia `CFLAGS`, `LDFLAGS`, and `LIBS` to `sysinfo.gap`
    ([#3248](https://github.com/gap-system/gap/pull/3248)).

  - Change `MPtr` Julia type of GAP objects to be a subtype of the
    abstract Julia `GapObj` type provided by the Julia package
    `GAPTypes.jl`
    ([#3497](https://github.com/gap-system/gap/pull/3497)).

### Improved and extended functionality:

  - Always generate `sysinfo.gap` (previously, it was only generated if
    the "compatibility mode" of the build system was enabled)
    ([#3042](https://github.com/gap-system/gap/pull/3042)).

  - Add support for writing to `ERROR_OUTPUT` from kernel code
    ([#3043](https://github.com/gap-system/gap/pull/3043)).

  - Add `make check`
    ([#3285](https://github.com/gap-system/gap/pull/3285)).

### Changed documentation:

  - Fix documentation of `NumberFFVector`
    and add an example
    ([#3079](https://github.com/gap-system/gap/pull/3079)).

### Fixed bugs that could lead to crashes:

  - Fix readline crash when using autocomplete with
    `colored-completion-prefix` turned on in Bash
    ([#2991](https://github.com/gap-system/gap/pull/2991)).

  - Fix overlapping `memcpy` in `APPEND_LIST`
    ([#3216](https://github.com/gap-system/gap/pull/3216)).

### Fixed bugs that could lead to incorrect results:

  - Fix bugs in the code for partial permutations
    ([#3220](https://github.com/gap-system/gap/pull/3220)).

  - Fix a bug in `Gcd` for polynomials not returning standard
    associates, introduced in GAP 4.10.0
    ([#3227](https://github.com/gap-system/gap/pull/3227)).

### Fixed bugs that could lead to break loops:

  - Change `GroupWithGenerators` to
    accept collections again (to avoid regressions in code that relied
    on this undocumented behavior)
    ([#3095](https://github.com/gap-system/gap/pull/3095)).

  - Fix `ShallowCopy` for for a Knuth-Bendix
    rewriting system
    ([#3128](https://github.com/gap-system/gap/pull/3128)). (Reported
    by Ignat Soroko)

  - Fix `IsMonomialMatrix` to work with
    compressed matrices
    ([#3149](https://github.com/gap-system/gap/pull/3149)). (Reported
    by Dominik Bernhardt)

### Removed or obsolete functionality:

  - Disable `make install` (previously it displayed a warning which
    often got ignored)
    ([#3005](https://github.com/gap-system/gap/pull/3005)).

### Other fixed bugs:

  - Fix some errors which stopped triggering a break loop
    ([#3013](https://github.com/gap-system/gap/pull/3013)).

  - Fix compiler error with GCC 4.4.7
    ([#3026](https://github.com/gap-system/gap/pull/3026)).

  - Fix string copying logic
    ([#3071](https://github.com/gap-system/gap/pull/3071)).

### New and updated packages since GAP 4.10.0

GAP 4.10.1 distribution contains 145 packages, including updated
versions of 35 packages from GAP 4.10.0 distribution, and also the
following five new packages:

  - **MajoranaAlgebras** by Markus Pfeiffer and Madeleine Whybrow, which
    constructs Majorana representations of finite groups.

  - **PackageManager** by Michael Torpey, providing a collection of
    functions for installing and removing GAP packages, with the
    eventual aim of becoming a full pip-style package manager for the
    GAP system.

  - **Thelma** by Victor Bovdi and Vasyl Laver, implementing algorithms
    to deal with threshold elements.

  - **walrus** by Markus Pfeiffer, providing methods for proving
    hyperbolicity of finitely presented groups in polynomial time.

  - **YangBaxter** by Leandro Vendramin and Alexander Konovalov, which
    provides functionality to construct classical and skew braces, and
    also includes a database of classical and skew braces of small
    orders.


## GAP 4.10.0 (November 2018)

### New features and major changes

  - **Reduce impact of immediate methods**
    GAP allows declaring so-called "immediate methods". The idea is
    that these are very simple and fast methods which are immediately
    called if information about an object becomes known, in order to
    perform some quick deduction. For example, if the order of a group
    is set, there might be immediate methods which update the filters
    `IsFinite` and `IsTrivial` of the group suitably.

    While this can be very elegant and useful in interactive GAP
    sessions, the overhead for running these immediate methods and
    applying their results can become a major factor in the runtime of
    complex computations that create thousands or millions of objects.

    To address this, various steps were taken:

      - some immediate methods were turned into regular methods;

      - a special handlers for `SetSize` was created that deduces
        properties which previously were taken care of by immediate
        methods;

      - some immediate methods were replaced by implications (set via
        `InstallTrueMethod`), a mechanism that essentially adds zero
        overhead, unlike immediate methods;

      - various group constructors were modified to precompute and
        preset properties of freshly created group objects, to avoid
        triggering immediate methods for these.

    As a result of these and other changes, consider the following
    example; with GAP 4.9, it takes about 130 seconds on one test
    system, while with GAP 4.10 it runs in about 22 seconds, i.e.,
    more than six times
        faster.

        G:=PcGroupCode( 741231213963541373679312045151639276850536621925972119311,11664);;
        IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))<>fail;

    Relevant pull requests and issues:
    [#2386](https://github.com/gap-system/gap/pull/2386),
    [#2387](https://github.com/gap-system/gap/pull/2387),
    [#2522](https://github.com/gap-system/gap/pull/2522).

  - **Change definition of `IsPGroup` to *not* require finiteness**
    This is a small change in terms of amount of code changed, but we
    list it here as it has a potential (albeit rather unlikely) impact
    on the code written by GAP users: In the past, the GAP
    manual entry for `IsPGroup` defined p-groups as being finite groups,
    which differs from the most commonly used definition for p-groups.
    Note however that there was not actual implication installed from
    `IsPGroup` to `IsFinite`, so it always was possible to actually
    created infinite groups in the filter `IsPGroup`. In GAP 4.10,
    we adjusted (in
    [#1545](https://github.com/gap-system/gap/pull/1545)) the
    documentation for `IsPGroup` to the commonly accepted definition for
    p-groups. In addition, code in the GAP library and in packages
    using `IsPGroup` was audited and (in a very few cases) adjusted to
    explicitly check `IsFinite` (see e.g.
    [#2866](https://github.com/gap-system/gap/pull/2866)).

  - **Experimental support for using the **Julia** garbage collector**
    It is now possible to use the garbage collector of the [Julia
    language](https://julialang.org) instead of GAP's traditional
    **GASMAN** garbage collector. This is partly motivated by a desire
    to allow tight integration with GAP and **Julia** in the future.
    Warning: right now, this is *slower*, and also requires a patched
    version of **Julia**.

    Relevant pull requests:
    [#2092](https://github.com/gap-system/gap/pull/2092),
    [#2408](https://github.com/gap-system/gap/pull/2408),
    [#2461](https://github.com/gap-system/gap/pull/2461),
    [#2485](https://github.com/gap-system/gap/pull/2485),
    [#2495](https://github.com/gap-system/gap/pull/2495),
    [#2672](https://github.com/gap-system/gap/pull/2672),
    [#2688](https://github.com/gap-system/gap/pull/2688),
    [#2793](https://github.com/gap-system/gap/pull/2793),
    [#2904](https://github.com/gap-system/gap/pull/2904),
    [#2905](https://github.com/gap-system/gap/pull/2905),
    [#2931](https://github.com/gap-system/gap/pull/2931).

  - ****libGAP** (work in progress)**
    We now provide a experimental way to allow 3rd party code to link
    GAP as a library; this is based on the **libGAP** code by
    [SageMath](https://www.sagemath.org), but different: while we aim to
    provide the same functionality, we do not rename any symbols, and we
    do not provide the same API. We hope that a future version of
    **SageMath** can drop its custom modifications for GAP and use
    this interface instead. Work is underway to achieve this goal. If
    you are interested in this kind of interface, please get in touch
    with us to help us improve it. See also [this
    email](https://mail.gap-system.org/pipermail/gap/2018-August/001123.html).

    To get an idea how **libGAP** works, you can configure GAP as
    normal, and then execute `make testlibgap` which will build a small
    program that uses some of the existing API and links GAP.
    Relevant pull requests:

      - [#1690](https://github.com/gap-system/gap/pull/1690) Add a
        callback to `FuncJUMP_TO_CATCH`

      - [#2528](https://github.com/gap-system/gap/pull/2528) Add
        `IsLIBGAP` constant

      - [#2702](https://github.com/gap-system/gap/pull/2702) Add
        GAP kernel API

      - [#2723](https://github.com/gap-system/gap/pull/2723) Introduce
        command line options `--norepl` and `--nointeract`

### Improved and extended functionality

  - [#2041](https://github.com/gap-system/gap/pull/2041) Teach
    `FrattiniSubgroup` methods to check for solvability

  - [#2053](https://github.com/gap-system/gap/pull/2053) Faster
    computation of modular inverses of integers

  - [#2057](https://github.com/gap-system/gap/pull/2057) Various
    changes, including:

      - Improve computation of automorphism groups for fp groups (we
        still recommend to instead first convert the group to a
        computationally nice representation, such as a perm or pc group)

      - Add `MinimalFaithfulPermutationDegree` attribute for finite groups

      - Improve performance of `GQuotients(F,G)` when `F` is an fp group

      - Some other performance and documentation tweaks

  - [#2061](https://github.com/gap-system/gap/pull/2061),
    [#2086](https://github.com/gap-system/gap/pull/2086),
    [#2159](https://github.com/gap-system/gap/pull/2159),
    [#2306](https://github.com/gap-system/gap/pull/2306) Speed up
    `GcdInt`, `LcmInt`, `PValuation`, `RootInt`, `SmallestRootInt`,
    `IsPrimePowerInt`

  - [#2063](https://github.com/gap-system/gap/pull/2063) Teach GAP
    that BPSW pseudo primes less than 2^64 are all known to be prime
    (the previous limit was 10^13)

  - [#2091](https://github.com/gap-system/gap/pull/2091) Refactor
    `DeclareAttribute` and `NewAttribute` (arguments are now verified
    stricter)

  - [#2115](https://github.com/gap-system/gap/pull/2115),
    [#2204](https://github.com/gap-system/gap/pull/2204),
    [#2272](https://github.com/gap-system/gap/pull/2272) Allow
    (optionally) passing a random source to many more `Random` methods
    than before, and also to `RandomList`

  - [#2136](https://github.com/gap-system/gap/pull/2136) Add
    `shortname` entry to record returned by
    `IsomorphismTypeInfoFiniteSimpleGroup`

  - [#2181](https://github.com/gap-system/gap/pull/2181) Implement
    `Union(X,Y)`, where `X` and `Y` are in `PositiveIntegers`,
    `NonnegativeIntegers`, `Integers`, `GaussianIntegers`, `Rationals`,
    `GaussianRationals`, `Cyclotomics`, at least where a suitable output
    object exists (we already provided `Intersection(X,Y)` for a long
    time)

  - [#2185](https://github.com/gap-system/gap/pull/2185) Implement
    `IsCentral(M,x)`, where `M` is a magma, monoid, group, ring,
    algebra, etc. and `x` an element of `M` (the documentation already
    claimed that these exist for a long time)

  - [#2199](https://github.com/gap-system/gap/pull/2199) Optimize
    true/false conditions when coding if-statements

  - [#2200](https://github.com/gap-system/gap/pull/2200) Add
    `StringFormatted`, `PrintFormatted`, `PrintToFormatted`

  - [#2222](https://github.com/gap-system/gap/pull/2222) Turn hidden
    implications into actual implications

  - [#2223](https://github.com/gap-system/gap/pull/2223) Add operation
    `PositionsBound` which returns the set
    of all bound positions in a given list

  - [#2224](https://github.com/gap-system/gap/pull/2224),
    [#2243](https://github.com/gap-system/gap/pull/2243),
    [#2340](https://github.com/gap-system/gap/pull/2340) Improve
    `ShowImpliedFilters` output

  - [#2225](https://github.com/gap-system/gap/pull/2225) Improve
    `LocationFunc` for kernel function

  - [#2232](https://github.com/gap-system/gap/pull/2232) Make
    `ValueGlobal` faster

  - [#2242](https://github.com/gap-system/gap/pull/2242) Add global
    function `CycleFromList`

  - [#2244](https://github.com/gap-system/gap/pull/2244) Make `rank`
    argument to `InstallImmediateMethod` optional, similar to
    `InstallMethod`

  - [#2274](https://github.com/gap-system/gap/pull/2274) Ensure uniform
    printing of machine floats `nan`, `inf`, `-inf` across different
    operating systems

  - [#2287](https://github.com/gap-system/gap/pull/2287) Turn
    `IsInfiniteAbelianizationGroup` into a property and add some
    implications involving it

  - [#2293](https://github.com/gap-system/gap/pull/2293),
    [#2602](https://github.com/gap-system/gap/pull/2602),
    [#2718](https://github.com/gap-system/gap/pull/2718) Improved and
    documented various kernel and memory debugging facilities (requires
    recompiling GAP with `--enable-debug`, `--enable-valgrind` resp.
    `--enable-memory-checking`)

  - [#2308](https://github.com/gap-system/gap/pull/2308) Method
    selection code was rewritten from GAP to C

  - [#2326](https://github.com/gap-system/gap/pull/2326) Change
    `SimpleGroup` to perform better input validation and improve or
    correct error message for type 2E

  - [#2375](https://github.com/gap-system/gap/pull/2375) Make `last2`
    and `last3` available in break loops

  - [#2383](https://github.com/gap-system/gap/pull/2383) Speed
    improvements for automorphism groups

  - [#2393](https://github.com/gap-system/gap/pull/2393) Track location
    of `InstallMethod` and `InstallImmediateMethod`

  - [#2422](https://github.com/gap-system/gap/pull/2422) Improve
    tracking of `InstallMethod` and `DeclareOperation`

  - [#2426](https://github.com/gap-system/gap/pull/2426) Speed up
    `InverseMatMod` with integer modulus

  - [#2427](https://github.com/gap-system/gap/pull/2427) Fix and
    complete support for custom functions (i.e., objects which can be
    called like a function using `obj(arg)` syntax)

  - [#2456](https://github.com/gap-system/gap/pull/2456) Add
    `PrintString` and `ViewString` methods for character tables

  - [#2474](https://github.com/gap-system/gap/pull/2474) Change
    `IsConstantRationalFunction` and `IsUnivariateRationalFunction` to
    return `false` if input isn't a rational function (instead of an
    error)

  - [#2474](https://github.com/gap-system/gap/pull/2474) Add methods
    for multiplying rational functions over arbitrary rings by rationals

  - [#2496](https://github.com/gap-system/gap/pull/2496) Finite groups
    whose order is known and not divisible by 4 are immediately marked
    as solvable

  - [#2509](https://github.com/gap-system/gap/pull/2509) Rewrite
    support for `.gz` compressed files to use **zlib**, now works on
    Windows

  - [#2519](https://github.com/gap-system/gap/pull/2519),
    [#2524](https://github.com/gap-system/gap/pull/2524),
    [#2531](https://github.com/gap-system/gap/pull/2531) `Test` now
    rejects empty inputs and warns if the input contains no test

  - [#2574](https://github.com/gap-system/gap/pull/2574) When reporting
    syntax errors, GAP now "underlines" the complete last token, not
    just the position where it stopped parsing

  - [#2577](https://github.com/gap-system/gap/pull/2577),
    [#2613](https://github.com/gap-system/gap/pull/2613) Add quadratic
    and bilinear add forms for `Omega(e,d,q)`

  - [#2598](https://github.com/gap-system/gap/pull/2598) Add
    `BannerFunction` to `PackageInfo.g`

  - [#2606](https://github.com/gap-system/gap/pull/2606) Improve
    `PageSource` to work on functions that were read from a file given
    by a relative path

  - [#2616](https://github.com/gap-system/gap/pull/2616) Speed up
    computation of quotients of associative words by using existing (but
    previously unused) kernel functions for that

  - [#2640](https://github.com/gap-system/gap/pull/2640) Work on
    `MatrixObj` and `VectorObj`

  - [#2654](https://github.com/gap-system/gap/pull/2654) Make `Sortex`
    stable

  - [#2666](https://github.com/gap-system/gap/pull/2666),
    [#2686](https://github.com/gap-system/gap/pull/2686) Add
    `IsBiCoset` attribute for right cosets, which is true if the right
    coset is also a left coset

  - [#2684](https://github.com/gap-system/gap/pull/2684) Add
    `NormalSubgroups` methods for symmetric and alternating permutation
    groups

  - [#2726](https://github.com/gap-system/gap/pull/2726) Validate
    `PackageInfo.g` when loading packages

  - [#2733](https://github.com/gap-system/gap/pull/2733) Minor
    performance improvements, code cleanup and very local fixes

  - [#2750](https://github.com/gap-system/gap/pull/2750) Reject some
    invalid uses of `~`

  - [#2812](https://github.com/gap-system/gap/pull/2812) Reduce memory
    usage and improve performance the MTC (modified Todd-Coxeter) code
    that was rewritten in GAP 4.9, but which was much slower than
    the old (but buggy) code it replaced; the difference is now small,
    but the old code still is faster in some case.

  - [#2855](https://github.com/gap-system/gap/pull/2855),
    [#2877](https://github.com/gap-system/gap/pull/2877) Add
    `IsPackageLoaded`

  - [#2878](https://github.com/gap-system/gap/pull/2878) Speed up
    conjugacy tests for permutation by using random permutation of
    points when selecting base in centraliser

  - [#2899](https://github.com/gap-system/gap/pull/2899)
    `TestDirectory` reports number of failures and failed files

### Changed documentation

  - [#2192](https://github.com/gap-system/gap/pull/2192) Add an example
    for `PRump`

  - [#2219](https://github.com/gap-system/gap/pull/2219) Add examples
    to the relations chapter.

  - [#2360](https://github.com/gap-system/gap/pull/2360) Document
    `IdealDecompositionsOfPolynomial` (also accessible via its synonym
    `DecomPoly`) and `NormalizerViaRadical`

  - [#2366](https://github.com/gap-system/gap/pull/2366) Do not
    recommend avoiding `X` which is a synonym for `Indeterminate`

  - [#2432](https://github.com/gap-system/gap/pull/2432) Correct a
    claim about the index of `Omega(e,p,q)` in `SO(e,p,q)` (see `SO`)

  - [#2549](https://github.com/gap-system/gap/pull/2549) Update
    documentation of the `-T` command line option

  - [#2551](https://github.com/gap-system/gap/pull/2551) Add new
    command line option `--alwaystrace` which ensures error backtraces
    are printed even if break loops are disabled

  - [#2681](https://github.com/gap-system/gap/pull/2681) Documented
    `ClassPositionsOfSolvableRadical` and
    `CharacterTableOfNormalSubgroup`

  - [#2834](https://github.com/gap-system/gap/pull/2834) Improve manual
    section about `Info` classes

### Fixed bugs that could lead to crashes

  - [#2154](https://github.com/gap-system/gap/pull/2154),
    [#2242](https://github.com/gap-system/gap/pull/2242),
    [#2294](https://github.com/gap-system/gap/pull/2294),
    [#2344](https://github.com/gap-system/gap/pull/2344),
    [#2353](https://github.com/gap-system/gap/pull/2353),
    [#2736](https://github.com/gap-system/gap/pull/2736) Fix several
    potential (albeit rare) crashes related to garbage collection

  - [#2196](https://github.com/gap-system/gap/pull/2196) Fix crash in
    `HasKeyBag` on SPARC Solaris 11

  - [#2305](https://github.com/gap-system/gap/pull/2305) Fix crash in
    `PartialPerm([1,2,8],[3,4,1,2]);`

  - [#2477](https://github.com/gap-system/gap/pull/2477) Fix crash if
    `~` is used to modify list

  - [#2499](https://github.com/gap-system/gap/pull/2499) Fix crash in
    the kernel functions `{8,16,32}Bits_ExponentSums3`

  - [#2601](https://github.com/gap-system/gap/pull/2601) Fix crash in
    `MakeImmutable(rec(x:=~));`

  - [#2665](https://github.com/gap-system/gap/pull/2665) Fix crash when
    an empty filename is passed

  - [#2711](https://github.com/gap-system/gap/pull/2711) Fix crash when
    tracing buggy attribute/property methods that fail to return a value

  - [#2766](https://github.com/gap-system/gap/pull/2766) Fix obscure
    crashes by using `a!{l}` syntax inside a function (this syntax never
    was fully implemented and was unusable, and now has been removed)

### Fixed bugs that could lead to incorrect results

  - [#2085](https://github.com/gap-system/gap/pull/2085) Fix bugs in
    `JenningsLieAlgebra` and `PCentralLieAlgebra` that could e.g. lead
    to incorrect `LieLowerCentralSeries` results

  - [#2113](https://github.com/gap-system/gap/pull/2113) Fix
    `IsMonomial` for reducible characters and some related improvements

  - [#2183](https://github.com/gap-system/gap/pull/2183) Fix bug in
    `ValueMolienSeries` that could lead to `ValueMolienSeries(m,0)` not
    being 1

  - [#2198](https://github.com/gap-system/gap/pull/2198) Make
    multiplication of larger integers by tiny floats commutative (e.g.
    now 10.^-300 \* 10^400 and 10^400 \* 10.^-300 both give infinity,
    while before 10^400 \* 10.^-300 gave 1.e+100); also ensure various
    strange inputs, like `rec()^1;`, produce an error (instead of
    setting `a^1 = a` and `1*a = a` for almost any kind of object)

  - [#2273](https://github.com/gap-system/gap/pull/2273) Fix
    `TypeOfOperation` for setters of and-filters

  - [#2275](https://github.com/gap-system/gap/pull/2275),
    [#2280](https://github.com/gap-system/gap/pull/2280) Fix
    `IsFinitelyGeneratedGroup` and `IsFinitelyGeneratedMonoid` to not
    (incorrectly) assume that a given infinite generating set implies
    that there is no finite generating set

  - [#2311](https://github.com/gap-system/gap/pull/2311) Do not set
    `IsFinitelyGeneratedGroup` for finitely generated magmas which are
    not groups

  - [#2452](https://github.com/gap-system/gap/pull/2452) Fix bug that
    allowed creating empty magmas in the filters `IsTrivial` and
    `IsMagmaWithInverses`

  - [#2689](https://github.com/gap-system/gap/pull/2689) Fix `LogFFE`
    to not return negative results on 32 bit systems

  - [#2766](https://github.com/gap-system/gap/pull/2766) Fix a bug that
    allowed creating corrupt permutations

### Fixed bugs that could lead to break loops

  - [#2040](https://github.com/gap-system/gap/pull/2040) Raise error if
    eager float literal conversion fails (fixes
    [#1105](https://github.com/gap-system/gap/pull/1105))

  - [#2582](https://github.com/gap-system/gap/pull/2582) Fix
    `ExtendedVectors` for trivial vector spaces

  - [#2617](https://github.com/gap-system/gap/pull/2617) Fix
    `HighestWeightModule` for Lie algebras in certain cases

  - [#2829](https://github.com/gap-system/gap/pull/2829) Fix
    `ShallowCopy` for `IteratorOfCartesianProduct`

### Other fixed bugs

  - [#2220](https://github.com/gap-system/gap/pull/2220) Do not set
    `IsSubsetLocallyFiniteGroup` filter for finite fields

  - [#2268](https://github.com/gap-system/gap/pull/2268) Handle spaces
    in filenames of gzipped filenames

  - [#2269](https://github.com/gap-system/gap/pull/2269),
    [#2660](https://github.com/gap-system/gap/pull/2660) Fix some
    issues with the interface between GAP and **XGAP** (or other
    similar frontends for GAP)

  - [#2315](https://github.com/gap-system/gap/pull/2315) Prevent
    creation of groups of floats, just like we prevent creation of
    groups of cyclotomics

  - [#2350](https://github.com/gap-system/gap/pull/2350) Fix prompt
    after line continuation

  - [#2365](https://github.com/gap-system/gap/pull/2365) Fix tracing of
    mutable variants of `One`/`Zero`/`Inv`/`AInv`

  - [#2398](https://github.com/gap-system/gap/pull/2398) Fix
    `PositionStream` to report correct position

  - [#2467](https://github.com/gap-system/gap/pull/2467) Fix support
    for identifiers of length 1023 and more

  - [#2470](https://github.com/gap-system/gap/pull/2470) Do not display
    garbage after certain syntax error messages

  - [#2533](https://github.com/gap-system/gap/pull/2533) Fix composing
    a map with an identity map to not produce a range that is too big

  - [#2638](https://github.com/gap-system/gap/pull/2638) Fix result of
    `Random` on 64 bit big endian system to match those on little
    endian, and on 32 bit big endian

  - [#2672](https://github.com/gap-system/gap/pull/2672) Fix
    `MakeImmutable` for weak pointer objects, which previously failed to
    make subobjects immutable

  - [#2674](https://github.com/gap-system/gap/pull/2674) Fix
    `SaveWorkspace` to return `false` in case of an error, and `true`
    only if successful

  - [#2681](https://github.com/gap-system/gap/pull/2681) Fix `Display`
    for the character table of a trivial group

  - [#2716](https://github.com/gap-system/gap/pull/2716) When seeding a
    Mersenne twister from a string, the last few characters would not be
    used if the string length was not a multiple of 4. Fixing this may
    lead to different series of random numbers being generated.

  - [#2720](https://github.com/gap-system/gap/pull/2720) Reject
    workspaces made in a GAP with readline support in a GAP
    without, and vice versa, instead of crashing

  - [#2657](https://github.com/gap-system/gap/pull/2657) The subobjects
    of the mutable values of the attributes `ComputedClassFusions`,
    `ComputedIndicators`, `ComputedPowerMaps`, `ComputedPrimeBlockss`
    are now immutable. This makes sure that the values are not
    accidentally changed. This change may have side-effects in users'
    code, for example the object returned by `0 * ComputedPowerMaps(
    CharacterTable( "A5" ) )[2]` had been a mutable list before the
    change, and is an immutable list from now on.

### Removed or obsolete functionality

  - Remove multiple undocumented internal functions. Nobody should have
    been using them, but if you were, you may extract it from a previous
    GAP release that still contained it.
    ([#2670](https://github.com/gap-system/gap/pull/2670),
    [#2781](https://github.com/gap-system/gap/pull/2781) and more)

  - [#2335](https://github.com/gap-system/gap/pull/2335) Remove several
    functions and variables that were deprecated for a long time:
    `DiagonalizeIntMatNormDriven`, `DeclarePackageDocumentation`,
    `KERNEL_VERSION`, `GAP_ROOT_PATHS`, `LOADED_PACKAGES`,
    `PACKAGES_VERSIONS`, `IsTuple`, `StateRandom`, `RestoreStateRandom`,
    `StatusRandom`, `FactorCosetOperation`, `ShrinkCoeffs`,
    `ExcludeFromAutoload`, `CharacterTableDisplayPrintLegendDefault`,
    `ConnectGroupAndCharacterTable`, `IsSemilatticeAsSemigroup`,
    `CreateCompletionFiles`, `PositionFirstComponent`, `ViewLength`

  - [#2502](https://github.com/gap-system/gap/pull/2502) Various kernel
    functions now validate their inputs more carefully (making it harder
    to produce bad effects by accidentally passing bad data to them)

  - [#2700](https://github.com/gap-system/gap/pull/2700) Forbid
    constructors with 0 arguments (they were never meaningful)

### Packages

GAP 4.10.0 distribution includes 140 packages.

Added to the distribution:

  - The **francy** package by Manuel Martins, which provides an
    interface to draw graphics using objects. This interface allows
    creation of directed and undirected graphs, trees, line charts, bar
    charts and scatter charts. These graphical objects are drawn inside
    a canvas that includes a space for menus and to display informative
    messages. Within the canvas it is possible to interact with the
    graphical objects by clicking, selecting, dragging and zooming.

  - The **JupyterVis** package by Nathan Carter, which is intended for
    use in Jupyter Notebooks running GAP kernels and adds
    visualization tools for use in such notebooks, such as charts and
    graphs.

No longer redistributed with GAP:

  - The **linboxing** package has been unusable (it does not compile)
    for several years now, and is unmaintained. It was therefore dropped
    from the GAP package distribution. If anybody is willing to take
    over and fix the package, the latest sources are available at
    <https://github.com/gap-packages/linboxing>.

  - The **recogbase** package has been merged into the `recog` package,
    and therefore is no longer distributed with GAP.

## GAP 4.9.3 (September 2018)

### Fixed bugs that could lead to break loops:

  - Fixed a regression in `HighestWeightModule` caused by changes in
    sort functions introduced in GAP 4.9 release
    ([#2617](https://github.com/gap-system/gap/pull/2617)).

### Other fixed bugs and further improvements:

  - Fixed a compile time assertion that caused compiler error on some
    systems ([#2691](https://github.com/gap-system/gap/pull/2691)).

### New and updated packages since GAP 4.9.2

This release contains updated versions of 18 packages from GAP 4.9.2
distribution. Additionally, it has three new packages:

  - The **curlInterface** package by Christopher Jefferson and Michael
    Torpey, which provides a simple wrapper around [**libcurl**](https://curl.haxx.se/)
    to allow downloading files over http, ftp and https protocols.

  - The **datastructures** package by Markus Pfeiffer, Max Horn,
    Christopher Jefferson and Steve Linton, which aims at providing
    standard datastructures, consolidating existing code and improving
    on it, in particular in view of **HPC-GAP**.

  - The **DeepThought** package by Nina Wagner and Max Horn, which
    provides functionality for computations in finitely generated
    nilpotent groups given by a suitable presentation using Deep Thought
    polynomials.


## GAP 4.9.2 (July 2018)

### Fixed bugs that could lead to break loops:

  - Fixed a bug in iterating over an empty cartesian product
    ([#2421](https://github.com/gap-system/gap/pull/2421)). (Reported
    by @isadofschi)

### Fixed bugs that could lead to crashes:

  - Fixed a crash after entering `return;` in a "method not found" break
    loop ([#2449](https://github.com/gap-system/gap/pull/2449)).

  - Fixed a crash when an error occurs and `OutputLogTo` points to a
    stream which internally uses another stream
    ([#2596](https://github.com/gap-system/gap/pull/2596)).

### Fixed bugs that could lead to incorrect results:

  - Fixed a bug in computing maximal subgroups, which broke some other
    calculations, in particular, computing intermediate subgroups.
    ([#2488](https://github.com/gap-system/gap/pull/2488)). (Reported
    by Seyed Hassan Alavi)

### Other fixed bugs and further improvements:

  - Profiling now correctly handles calls to `longjmp` and allows to
    generate profiles using version 2.0.1 of the **Profiling** package
    ([#2444](https://github.com/gap-system/gap/pull/2444)).

  - The `bin/gap.sh` script now respects the `GAP_DIR` environment
    variable ([#2465](https://github.com/gap-system/gap/pull/2465)).
    (Contributed by RussWoodroofe)

  - The `bin/BuildPackages.sh` script now properly builds binaries for
    the **simpcomp** package
    ([#2475](https://github.com/gap-system/gap/pull/2475)).

  - Fixed a bug in restoring a workspace, which prevented GAP from
    saving the history if a workspace was loaded during startup
    ([#2578](https://github.com/gap-system/gap/pull/2578)).

### New and updated packages since GAP 4.9.1

This release contains updated versions of 22 packages from GAP 4.9.1
distribution. Additionally, it has three new packages. The new
**JupyterKernel** package by Markus Pfeiffer provides a so-called
*kernel* for the [Jupyter](https://jupyter.org/) interactive document system.
This package requires Jupyter to be installed
on your system ([instructions](https://jupyter.org/install)). It
also requires GAP packages **IO**, **ZeroMQInterface**, **json**,
and also two new packages by Markus Pfeiffer called **crypting** and
**uuid**, all included into GAP 4.9.2 distribution. The
**JupyterKernel** package is not yet usable on
Windows.


## GAP 4.9.1 (May 2018)

This is the first public release of GAP 4.9.

### Major changes:

  - Merged **HPC-GAP** into GAP. For details, please refer to the end of
    these release notes.

  - GAP has a new build system, which resolves many quirks and issues
    with the old system, and will be easier to maintain. For regular
    users, the usual `./configure && make` should work fine as before.
    If you are interested in technical details on the new build system,
    take a look at `README.buildsys.md`.

  - The guidelines for developing GAP packages were revised and moved
    from the Example package to the reference manual.
    ([#484](https://github.com/gap-system/gap/pull/484)).

  - In addition to supporting single argument lambda functions like
    `a -> a+1`, GAP now supports lambdas with fewer or more than one
    argument, or even a variable number. E.g. `{a,b} -> a+b` is a
    shorthand for `function(a,b) return a+b; end`. For details on how
    to use this, please refer to the reference manual. For technical
    details, e.g. why we did not choose the syntax `(a,b) -> a+b`, see
    [#490](https://github.com/gap-system/gap/pull/490).

  - Function calls, list accesses and records accesses now can be
    nested. For example, you can now write `y := f().x;` (essentially
    equivalent to `y := f();; y := y.x;`), which previously would have
    resulted in an error; see
    [#457](https://github.com/gap-system/gap/issues/457) and
    [#462](https://github.com/gap-system/gap/pull/462)).

  - The libraries of small, primitive and transitive groups which
    previously were an integral part of GAP were split into three
    separate packages
    [PrimgGrp](http://gap-packages.github.io/primgrp/),
    [SmallGrp](https://gap-packages.github.io/smallgrp/) and
    [TransGrp](http://www.math.colostate.edu/~hulpke/transgrp/). For
    backwards compatibility, these are required packages in GAP 4.9
    (i.e., GAP will not start without them). We plan to change this
    for GAP 4.10 (see
    [#2434](https://github.com/gap-system/gap/pull/2434)), once all
    packages which currently implicitly rely on these new packages had
    time to add explicit dependencies on them
    ([#1650](https://github.com/gap-system/gap/pull/1650),
    [#1714](https://github.com/gap-system/gap/pull/1714)).

  - The performance of GAP's sorting functions (such as `Sort`,
    `SortParallel`, etc.) has been substantially improved, in some
    examples by more than a factor of four: as a trivial example,
    compare the timing for `Sort([1..100000000] * 0)`. As a side
    effect, the result of sorting lists with equal entries may produce
    different answers compared to previous GAP versions. If you would
    like to make your code independent of the exact employed sorting
    algorithm, you can use the newly added `StableSort`, `StableSortBy`
    and `StableSortParallel`. (For some technical details, see
    [#609](https://github.com/gap-system/gap/pull/609)).

  - We removed our old home-grown big integer code, and instead always
    use the GMP based big integer code. This means that the GMP library
    now is a required dependency, not just an optional one. Note that
    GAP has been using GMP big integer arithmetic for a long time by
    default, and we also have been bundling GMP with GAP. So this
    change mostly removed code that was never in use for most users.

  - A number of improvements have been made to `Random`. These may lead
    to different sequences of numbers being created. On the up side,
    many more methods for `Random` (and other `RandomXYZ` operations)
    now optionally take an explicit `RandomSource` as first argument
    (but not yet all: help with issue
    [#1098](https://github.com/gap-system/gap/pull/1098) is welcome).
    Some relevant pull requests:

      - Allow creating random permutations using a random source
        ([#1165](https://github.com/gap-system/gap/pull/1165))

      - Let more `Random` methods use an alternative
        source ([#1168](https://github.com/gap-system/gap/pull/1168))

      - Help `Random` methods to use `RandomSource`
        ([#810](https://github.com/gap-system/gap/pull/810))

      - Remove uses of old random generator
        ([#808](https://github.com/gap-system/gap/pull/808))

      - Fix `Random` on long (\>2^28) lists
        ([#781](https://github.com/gap-system/gap/pull/781))

      - Fix `RandomUnimodularMat`
        ([#1511](https://github.com/gap-system/gap/pull/1511))

      - Use `RandomSource` in a few more
        places ([#1599](https://github.com/gap-system/gap/pull/1599))

  - The output and behaviour of the profiling system has been
    substantially improved:

      - Make profiling correctly handle the same file being opened
        multiple times
        ([#1069](https://github.com/gap-system/gap/pull/1069))

      - Do not profile the `return` statements inserted into the end
        of functions
        ([#1073](https://github.com/gap-system/gap/pull/1073))

      - Ensure we reset `OutputtedFilenameList` in profiling when a
        workspace is restored
        ([#1164](https://github.com/gap-system/gap/pull/1164))

      - Better tracking of amounts of memory allocated and time spent in
        the garbage collector
        ([#1806](https://github.com/gap-system/gap/pull/1806))

      - Allow profiling of memory usage
        ([#1808](https://github.com/gap-system/gap/pull/1808))

      - Remove profiling limit on files with \<= 2^16 lines
        ([#1913](https://github.com/gap-system/gap/pull/1913))

  - In many cases GAP now outputs the filename and location of
    functions in helpful places, e.g. in error messages or when
    displaying compiled functions. We also try to always use the format
    `FILENAME:LINE`, which various utilities already know how to parse
    (e.g. in **iTerm2**, cmd-clicking on such a string can be configured
    to open an editor for the file at the indicated line). For some
    technical details, see
    [#469](https://github.com/gap-system/gap/pull/469),
    [#755](https://github.com/gap-system/gap/pull/755\)),
    [#1058](https://github.com/gap-system/gap/pull/1058).

  - GAP now supports constant variables, whose value cannot change
    anymore during runtime; code using such constants can then be
    slightly optimized by GAP. E.g. if `foo` is turned into a
    constant variable bound to the value `false`, then GAP can
    optimize `if foo then ... fi;` blocks completely away. For details,
    see the documentation for `MakeConstantGlobal`.
    ([#1682](https://github.com/gap-system/gap/pull/1682),
    [#1770](https://github.com/gap-system/gap/pull/1770))

### Other changes:

  - Enhance `StructureDescription` with a major rewrite, enhancing
    `DirectFactorsOfGroup"` and adding `SemidirectDecompositions`; the
    core algorithm now also works for infinite abelian groups. Further,
    it became faster by quickly finding abelian direct factors and
    recognizing several cases where the group is direct indecomposable.
    ([#379](https://github.com/gap-system/gap/pull/379),
    [#763](https://github.com/gap-system/gap/pull/763),
    [#985](https://github.com/gap-system/gap/pull/985))

  - Mark `FittingSubgroup` and `FrattiniSubgroup` as nilpotent
    ([#400](https://github.com/gap-system/gap/pull/400))

  - Add method for `Socle` for finite nilpotent
    groups ([#402](https://github.com/gap-system/gap/pull/402))

  - Change `ViewString` and `String` methods for various inverse
    semigroups and monoids
    ([#438](https://github.com/gap-system/gap/pull/438),
    [#880](https://github.com/gap-system/gap/pull/880),
    [#882](https://github.com/gap-system/gap/pull/882))

  - Enhance some nilpotent and p-group attributes
    ([#442](https://github.com/gap-system/gap/pull/442))

  - Improve `Union` for a list with many ranges
    ([#444](https://github.com/gap-system/gap/pull/444))

  - Add `UserHomeExpand`, a function to expand `~` in filenames.
    ([#447](https://github.com/gap-system/gap/pull/447))

  - Extra hint in "No Method Found" error message if one of the arguments
    is `fail` ([#460](https://github.com/gap-system/gap/pull/460))

  - Tell Sylow subgroups of natural A_n or S_n their size when we make
    them ([#529](https://github.com/gap-system/gap/pull/529))

  - Some small enhancements on Sylow and Hall subgroup computations,
    mostly for nilpotent groups.
    ([#535](https://github.com/gap-system/gap/pull/535))

  - Remove `.zoo` archive related tools
    ([#540](https://github.com/gap-system/gap/pull/540))

  - Add new `FrattiniSubgroup`, `MaximalNormalSubgroups`,
    `MinimalNormalSubgroups` and `Socle` methods for abelian and/or
    solvable groups, even infinite ones. The new methods are only
    triggered if the group already knows that it is abelian and/or
    solvable. ([#552](https://github.com/gap-system/gap/pull/552),
    [#583](https://github.com/gap-system/gap/pull/583),
    [#606](https://github.com/gap-system/gap/pull/606))

  - New attribute `NormalHallSubgroups`, returning a list of all normal
    Hall subgroups of a group.
    ([#561](https://github.com/gap-system/gap/pull/561))

  - Add `ComplementClassesRepresentatives` fallback method for arbitrary
    groups ([#563](https://github.com/gap-system/gap/pull/563))

  - ([#612](https://github.com/gap-system/gap/pull/612)) Add parsing of
    hex literals in strings, e.g. `"\0x61"` is turned into `"a"`
    ([#612](https://github.com/gap-system/gap/pull/612))

  - Collection of enhancements
    ([#683](https://github.com/gap-system/gap/pull/683))

  - Various speed improvements to polynomial factorisation and the GAP
    MeatAxe ([#720](https://github.com/gap-system/gap/pull/720),
    [#1027](https://github.com/gap-system/gap/pull/1027))

  - The code and documentation for transformations is improved and
    corrected in many instances
    ([#727](https://github.com/gap-system/gap/pull/727),
    [#732](https://github.com/gap-system/gap/pull/732))

  - Change `RootFFE` to optionally takes a field or field size as first
    argument, from which the roots will be taken
    ([#761](https://github.com/gap-system/gap/pull/761))

  - Change `Permanent` from a global function to an attribute
    ([#777](https://github.com/gap-system/gap/pull/777))

  - Add `CallFuncListWrap` to wrap return value to allow distinguishing
    between functions which return and functions which don't
    ([#824](https://github.com/gap-system/gap/pull/824))

  - Allow repeated use of same `DeclareSynonym` call
    ([#835](https://github.com/gap-system/gap/pull/835))

  - New implementation of modified Todd-Coxeter (the old one had bugs,
    see [#302](https://github.com/gap-system/gap/issues/302)),
    [#843](https://github.com/gap-system/gap/pull/843))

  - New functionality: Cannon/Holt automorphisms and others
    ([#878](https://github.com/gap-system/gap/pull/878))

  - Add `IsPowerfulPGroup` property, and a `FrattiniSubgroup` method for
    powerful p-groups
    ([#894](https://github.com/gap-system/gap/pull/894))

  - Improve performance for group isomorphism/automorphisms
    ([#896](https://github.com/gap-system/gap/pull/896),
    [#968](https://github.com/gap-system/gap/pull/968))

  - Make `ListX`, `SetX`, `SumX` and `ProductX` support lists which are
    not collections
    ([#903](https://github.com/gap-system/gap/pull/903))

  - Some improvements for `LatticeByCyclicExtension`
    ([#905](https://github.com/gap-system/gap/pull/905))

  - Add helpers to retrieve information about operations and filters:
    `CategoryByName`, `TypeOfOperation`, `FilterByName`, `FiltersObj`,
    `FiltersType`, `IdOfFilter`, `IdOfFilterByName`, `IsAttribute`,
    `IsCategory`, `IsProperty`, `IsRepresentation`
    ([#925](https://github.com/gap-system/gap/pull/925),
    [#1593](https://github.com/gap-system/gap/pull/1593))

  - Add case-insensitive autocomplete
    ([#928](https://github.com/gap-system/gap/pull/928))

  - Give better error message if a help file is missing
    ([#939](https://github.com/gap-system/gap/pull/939))

  - Add `LowercaseChar` and `UppercaseChar`
    ([#952](https://github.com/gap-system/gap/pull/952))

  - Add `PositionMaximum` and `PositionMinimum`
    ([#956](https://github.com/gap-system/gap/pull/956))

  - Switching default command history length from infinity to 1000
    ([#960](https://github.com/gap-system/gap/pull/960))

  - Allow conversion of `-infinity` to float via `NewFloat` and
    `MakeFloat` ([#961](https://github.com/gap-system/gap/pull/961))

  - Add option `NoPrecomputedData` to avoid use of data libraries in
    certain computations (useful if one wants to verify the content of
    these data libraries)
    ([#986](https://github.com/gap-system/gap/pull/986))

  - Remove one-argument version of `AsPartialPerm` for a transformation
    ([#1036](https://github.com/gap-system/gap/pull/1036))

  - Partial perms now have a `MultiplicativeZero` rather than a `Zero`,
    since they are multiplicative rather than additive elements
    ([#1040](https://github.com/gap-system/gap/pull/1040))

  - Various enhancements:
    ([#1046](https://github.com/gap-system/gap/pull/1046))

      - A bugfix in `NaturalHomomorphismByIdeal` for polynomial rings

      - Improvements in handling solvable permutation groups

      - The trivial group now is a member of the perfect groups library

      - Improvements in using tabulated data for maximal subgroups

  - New tests for group constructors and some fixes (e.g. `GO(1,4,5)`
    used to trigger an error)
    ([#1053](https://github.com/gap-system/gap/pull/1053))

  - Make `HasSolvableFactorGroup` slightly more efficient
    ([#1062](https://github.com/gap-system/gap/pull/1062))

  - Enhance `HasXXFactorGroup`
    ([#1066](https://github.com/gap-system/gap/pull/1066))

  - Remove GAP4stones from tests
    ([#1072](https://github.com/gap-system/gap/pull/1072))

  - `AsMonoid` and `AsSemigroup` are now operations, and various bugs
    were resolved related to isomorphisms of semigroups and monoids
    ([#1112](https://github.com/gap-system/gap/pull/1112))

  - Mark isomorphisms between trivial groups as bijective
    ([#1116](https://github.com/gap-system/gap/pull/1116))

  - Speed up `RootMod` and `RootsMod` for moduli with large prime
    factors; also add `IS_PROBAB_PRIME_INT` kernel function
    ([#1141](https://github.com/gap-system/gap/pull/1141))

  - The search for the documentation of system setters and testers now
    returns corresponding attributes and properties
    ([#1144](https://github.com/gap-system/gap/pull/1144))

  - Remove command line options `-c`, `-U`, `-i` and `-X`, add
    `--quitonbreak`
    ([#1192](https://github.com/gap-system/gap/pull/1192),
    [#1265](https://github.com/gap-system/gap/pull/1265),
    [#1421](https://github.com/gap-system/gap/pull/1421),
    [#1448](https://github.com/gap-system/gap/pull/1448))

  - Remove Itanium support
    ([#1163](https://github.com/gap-system/gap/pull/1163))

  - Adding two strings now shows a more helpful error message
    ([#1314](https://github.com/gap-system/gap/pull/1314))

  - Suppress `Unbound global variable` warning in `IsBound`
    ([#1334](https://github.com/gap-system/gap/pull/1334))

  - Increase warning level for Conway polynomial
    ([#1363](https://github.com/gap-system/gap/pull/1363))

  - Performance improvements to maximal and intermediate subgroups, fix
    of `RepresentativeAction`
    ([#1390](https://github.com/gap-system/gap/pull/1390))

  - Revise Chapter 52 of the reference manual (fp semigroups and monoids)
    ([#1441](https://github.com/gap-system/gap/pull/1441))

  - Improve the performance of the `Info` statement
    ([#1464](https://github.com/gap-system/gap/pull/1464),
    [#1770](https://github.com/gap-system/gap/pull/1770))

  - When printing function bodies, avoid some redundant spaces
    ([#1498](https://github.com/gap-system/gap/pull/1498))

  - Add kernel functions for directly accessing entries of GF2/8bit
    compressed matrices
    ([#1585](https://github.com/gap-system/gap/pull/1585))

  - Add `String` method for functions
    ([#1591](https://github.com/gap-system/gap/pull/1591))

  - Check modules were compiled with the same version of GAP when loading
    them ([#1600](https://github.com/gap-system/gap/pull/1600))

  - When printing function, reproduce `TryNextMethod()` correctly
    ([#1613](https://github.com/gap-system/gap/pull/1613))

  - New "Bitfields" feature providing efficient support for packing
    multiple data items into a single word for cache and memory
    efficiency ([#1616](https://github.com/gap-system/gap/pull/1616))

  - Improved `bin/BuildPackages.sh`, in particular added option to abort
    upon failure ([#2022](https://github.com/gap-system/gap/pull/2022))

  - Rewrote integer code (GMP) for better performance of certain large
    integer operations, and added kernel implementations of various
    functions, including these:

      - Add kernel implementations of `AbsInt`, `SignInt`; add new kernel
        functions `ABS_RAT`, `SIGN_RAT`; and speed up `mod`, `RemInt`,
        `QuoInt` for divisors which are small powers of 2
        ([#1045](https://github.com/gap-system/gap/pull/1045))

      - Add kernel implementations of `Jacobi`, `PowerModInt`,
        `Valuation` (for integers), `PValuation` (for integers)
        ([#1075](https://github.com/gap-system/gap/pull/1045))

      - Add kernel implementation of `Factorial`
        ([#1969](https://github.com/gap-system/gap/pull/1969))

      - Add kernel implementation of `Binomial`
        ([#1921](https://github.com/gap-system/gap/pull/1921))

      - Add kernel implementation of `LcmInt`
        ([#2019](https://github.com/gap-system/gap/pull/2019))

  - Check version of kernel for package versions
    ([#1600](https://github.com/gap-system/gap/pull/1600))

  - Add new `AlgebraicExtensionNC` operation
    ([#1665](https://github.com/gap-system/gap/pull/1665))

  - Add `NumberColumns` and `NumberRows` to `MatrixObj` interface
    ([#1657](https://github.com/gap-system/gap/pull/1657))

  - `MinimalGeneratingSet` returns an answer for non-cyclic groups that
    already have a generating set of size 2 (which hence is minimal)
    ([#1755](https://github.com/gap-system/gap/pull/1755))

  - Add `GetWithDefault` which returns the n-th element of the list if it
    is bound, and the default value otherwise
    ([#1762](https://github.com/gap-system/gap/pull/1762))

  - Fast method for `ElmsBlist` when positions are a range with increment
    1 ([#1773](https://github.com/gap-system/gap/pull/1773))

  - Make permutations remember their inverses
    ([#1831](https://github.com/gap-system/gap/pull/1831))

  - Add invariant forms for `GU(1,q)` and `SU(1,q)`
    ([#1874](https://github.com/gap-system/gap/pull/1874))

  - Implement `StandardAssociate` and `StandardAssociateUnit` for
    `ZmodnZ`, clarify documentation for `IsEuclideanRing`
    ([#1990](https://github.com/gap-system/gap/pull/1990))

  - Improve documentation and interface for floats
    ([#2016](https://github.com/gap-system/gap/pull/2016))

  - Add `PositionsProperty` method for non-dense lists
    ([#2021](https://github.com/gap-system/gap/pull/2021))

  - Add `TrivialGroup(IsFpGroup)`
    ([#2037](https://github.com/gap-system/gap/pull/2037))

  - Change `ObjectifyWithAttributes` to return the new objects
    ([#2098](https://github.com/gap-system/gap/pull/2098))

  - Removed a never released undocumented **HPC-GAP** syntax extension
    which allowed to use a backtick/backquote as alias for
    `MakeImmutable`.
    ([#2202](https://github.com/gap-system/gap/pull/2202)).

  - Various changes
    ([#2253](https://github.com/gap-system/gap/pull/2253)):

      - Improve performance and memory usage of
        `ImageKernelBlocksHomomorphism"`

      - Document `LowIndexSubgroups`

      - Correct `ClassesSolvableGroup` documentation to clarify that it
        requires, but does not test membership

      - fix `IsNaturalGL` for trivial matrix groups with empty generating
        set

  - Make it possible to interrupt `repeat continue; until false;` and
    similar tight loops with "Ctrl-C"
    ([#2259](https://github.com/gap-system/gap/pull/2259)).

  - Improved GAP testing infrastructure, extended GAP test suite, and
    increased code coverage

  - Countless other tweaks, improvements, fixes were applied to the GAP
    library, kernel and manual

### Fixed bugs:

  - Fix bugs in `NormalSubgroups` and `PrintCSV`
    ([#433](https://github.com/gap-system/gap/pull/433))

  - Fix nice monomorphism dispatch for `HallSubgroup` (e.g. fixes
    `HallSubgroup(GL(3,4), [2,3])`)
    ([#559](https://github.com/gap-system/gap/pull/559))

  - Check for permutations whose degree would exceed the internal limit,
    and document that limit
    ([#581](https://github.com/gap-system/gap/pull/581))

  - Fix segfault after quitting from the break loop in certain cases
    ([#709](https://github.com/gap-system/gap/pull/709) which fixes
    [#397](https://github.com/gap-system/gap/issues/397))

  - Fix rankings for `Socle` and `MinimalNormalSubgroups`
    ([#711](https://github.com/gap-system/gap/pull/711))

  - Make key and attribute values immutable
    ([#714](https://github.com/gap-system/gap/pull/714))

  - Make `OnTuples([-1], (1,2))` return an error
    ([#718](https://github.com/gap-system/gap/pull/718))

  - Fix bug in `NewmanInfinityCriterion` which could corrupt the
    `PCentralSeries` attribute
    ([#719](https://github.com/gap-system/gap/pull/719))

  - The length of the list returned by `OnSetsPerm` is now properly set
    ([#731](https://github.com/gap-system/gap/pull/731))

  - Fix `Remove` misbehaving when last member of
    list with gaps in it is removed
    ([#766](https://github.com/gap-system/gap/pull/766))

  - Fix bugs in various methods for Rees (0-)matrix semigroups:
    `IsFinite`, `IsOne`,
    `Enumerator`, `IsReesMatrixSemigroup` and `IsReesZeroMatrixSemigroup`
    ([#768](https://github.com/gap-system/gap/pull/768),
    [#1676](https://github.com/gap-system/gap/pull/1676))

  - Fix `IsFullTransformationSemigroup` to work correctly for the full
    transformation semigroup of degree 0
    ([#769](https://github.com/gap-system/gap/pull/769))

  - Fix printing very large (\> 2^28 points) permutations
    ([#782](https://github.com/gap-system/gap/pull/782))

  - Fix `Intersection([])`
    ([#854](https://github.com/gap-system/gap/pull/854))

  - Fix crash in `IsKernelFunction` for some inputs
    ([#876](https://github.com/gap-system/gap/pull/876))

  - Fix bug in `ShortestVectors` which
    could cause `OrthogonalEmbeddings`
    to enter a break loop
    ([#941](https://github.com/gap-system/gap/pull/941))

  - Fix crash in some methods involving partial perms
    ([#948](https://github.com/gap-system/gap/pull/948))

  - `FreeMonoid(0)` no longer satisfies `IsGroup`
    ([#950](https://github.com/gap-system/gap/pull/950))

  - Fix crash when invoking weak pointer functions on invalid arguments
    ([#1009](https://github.com/gap-system/gap/pull/1009))

  - Fix a bug parsing character constants
    ([#1015](https://github.com/gap-system/gap/pull/1015))

  - Fix several bugs and crashes in `Z(p,d)` for invalid arguments, e.g.
    `Z(4,5)`, `Z(6,3)`
    ([#1029](https://github.com/gap-system/gap/pull/1029),
    [#1059](https://github.com/gap-system/gap/pull/1059),
    [#1383](https://github.com/gap-system/gap/pull/1383),
    [#1573](https://github.com/gap-system/gap/pull/1573))

  - Fix starting GAP on systems with large inodes
    ([#1033](https://github.com/gap-system/gap/pull/1033))

  - Fix `NrFixedPoints` and `FixedPointsOfPartialPerm` for a partial
    perm and a partial perm semigroup (they used to return the
    moved points rather than the fixed points)
    ([#1034](https://github.com/gap-system/gap/pull/1034))

  - Fix `MeetOfPartialPerms` when given a collection of 1 or 0
    partial perms
    ([#1035](https://github.com/gap-system/gap/pull/1035))

  - The behaviour of `AsPartialPerm` for a transformation and a list
    is corrected
    ([#1036](https://github.com/gap-system/gap/pull/1036))

  - `IsomorphismReesZeroMatrixSemigroup` for a 0-simple semigroup is now
    defined on the zero of the source and range semigroups
    ([#1038](https://github.com/gap-system/gap/pull/1038))

  - Fix isomorphisms from finitely-presented monoids to
    finitely-presented semigroups, and allow isomorphisms from
    semigroups to fp-monoids
    ([#1039](https://github.com/gap-system/gap/pull/1039))

  - Fix `One` for a partial permutation semigroup
    without generators
    ([#1040](https://github.com/gap-system/gap/pull/1040))

  - Fix `MemoryUsage` for positional and
    component objects
    ([#1044](https://github.com/gap-system/gap/pull/1044))

  - Fix `PlainString` causing immutable strings to become mutable
    ([#1096](https://github.com/gap-system/gap/pull/1096))

  - Restore support for sparc64
    ([#1124](https://github.com/gap-system/gap/pull/1124))

  - Fix a problem with \`\<\` for transformations, which could give
    incorrect results
    ([#1130](https://github.com/gap-system/gap/pull/1130))

  - Fix crash when comparing recursive data structures such as `[~] =
    [~]` ([#1151](https://github.com/gap-system/gap/pull/1151))

  - Ensure output of `TrivialGroup(IsPermGroup)` has zero generators
    ([#1247](https://github.com/gap-system/gap/pull/1247))

  - Fix for applying the `InverseGeneralMapping` of an `IsomorphismFpSemigroup`
    ([#1259](https://github.com/gap-system/gap/pull/1259))

  - Collection of improvements and fixes:
    ([#1294](https://github.com/gap-system/gap/pull/1294))

      - A fix for quotient rings of rings by structure constants

      - Generic routine for transformation matrix to rational canonical
        form

      - Speed improvements to block homomorphisms

      - New routines for conjugates or subgroups with desired containment

      - Performance improvement for conjugacy classes in groups with a
        huge number of classes, giving significant improvements to
        `IntermediateSubgroups` (e.g. 7-Sylow subgroup in PSL(7,2)),
        ascending chain and thus in turn double coset calculations and
        further routines that rely on it

  - Fix `EqFloat` to return correct results, instead of always returning
    `false` ([#1370](https://github.com/gap-system/gap/pull/1370))

  - Various changes, including fixes for `CallFuncList`
    ([#1417](https://github.com/gap-system/gap/pull/1417))

  - Better define the result of `MappingPermListList`
    ([#1432](https://github.com/gap-system/gap/pull/1432))

  - Check the arguments to `IsInjectiveListTrans` to prevent crashes
    ([#1435](https://github.com/gap-system/gap/pull/1435))

  - Change `BlownUpMat` to return fail for certain invalid inputs
    ([#1488](https://github.com/gap-system/gap/pull/1488))

  - Fixes for creating Green's classes of semigroups
    ([#1492](https://github.com/gap-system/gap/pull/1492),
    [#1771](https://github.com/gap-system/gap/pull/1771))

  - Fix `DoImmutableMatrix` for finite fields
    ([#1504](https://github.com/gap-system/gap/pull/1504))

  - Make structural copy handle boolean lists properly
    ([#1514](https://github.com/gap-system/gap/pull/1514))

  - Minimal fix for algebraic extensions over finite fields of order \>
    256 ([#1569](https://github.com/gap-system/gap/pull/1569))

  - Fix for computing quotients of certain algebra modules
    ([#1669](https://github.com/gap-system/gap/pull/1669))

  - Fix an error in the default method for `PositionNot`
    ([#1672](https://github.com/gap-system/gap/pull/1672))

  - Improvements to Rees matrix semigroups code and new tests
    ([#1676](https://github.com/gap-system/gap/pull/1676))

  - Fix `CodePcGroup` for the trivial polycyclic group
    ([#1679](https://github.com/gap-system/gap/pull/1679))

  - Fix `FroidurePinExtendedAlg` for partial permutation monoids
    ([#1697](https://github.com/gap-system/gap/pull/1697))

  - Fix computing the radical of a zero dimensional associative algebra
    ([#1701](https://github.com/gap-system/gap/pull/1701))

  - Fix a bug in `RadicalOfAlgebra` which could cause a break loop for
    some associative algebras
    ([#1716](https://github.com/gap-system/gap/pull/1716))

  - Fix a recursion depth trap error when repeatedly calling `Test`
    ([#1753](https://github.com/gap-system/gap/pull/1753))

  - Fix bugs in `PrimePGroup` for direct products of p-groups
    ([#1754](https://github.com/gap-system/gap/pull/1754))

  - Fix `UpEnv` (available in break loops) when at the bottom of the
    backtrace ([#1780](https://github.com/gap-system/gap/pull/1780))

  - Fix `IsomorphismPartialPermSemigroup` and
    `IsomorphismPartialPermMonoid` for permutation groups with 0
    generators ([#1784](https://github.com/gap-system/gap/pull/1784))

  - Fix `DisplaySemigroup` for transformation semigroups
    ([#1785](https://github.com/gap-system/gap/pull/1785))

  - Fix "no method found" errors in `MagmaWithOne` and
    `MagmaWithInverses`
    ([#1798](https://github.com/gap-system/gap/pull/1798))

  - Fix an error computing kernel of group homomorphism from fp group
    into permutation group
    ([#1809](https://github.com/gap-system/gap/pull/1809))

  - Fix an error in MTC losing components when copying a new augmented
    coset table ([#1809](https://github.com/gap-system/gap/pull/1809))

  - Fix output of `Where` in a break loop, which pointed at the wrong
    code line in some cases
    ([#1814](https://github.com/gap-system/gap/pull/1814))

  - Fix the interaction of signals in GAP and the **IO** package
    ([#1851](https://github.com/gap-system/gap/pull/1851))

  - Make line editing resilient to `LineEditKeyHandler` failure (in
    particular, don't crash)
    ([#1856](https://github.com/gap-system/gap/pull/1856))

  - Omit non-characters from `PermChars` results
    ([#1867](https://github.com/gap-system/gap/pull/1867))

  - Fix `ExteriorPower` when exterior power is 0-dimensional (used to
    return a 1-dimensional result)
    ([#1872](https://github.com/gap-system/gap/pull/1872))

  - Fix recursion depth trap and other improvements for quotients of fp
    groups ([#1884](https://github.com/gap-system/gap/pull/1884))

  - Fix a bug in the computation of a permutation group isomorphic to a
    group of automorphisms
    ([#1907](https://github.com/gap-system/gap/pull/1907))

  - Fix bug in `InstallFlushableValueFromFunction`
    ([#1920](https://github.com/gap-system/gap/pull/1920))

  - Fix `ONanScottType` and introduce `RestrictedInverseGeneralMapping`
    ([#1937](https://github.com/gap-system/gap/pull/1937))

  - Fix `QuotientMod` documentation, and the integer implementation. This
    partially reverts changes made in version 4.7.8 in 2013. The
    documentation is now correct (resp. consistent again), and several
    corner cases, e.g. `QuotientMod(0,0,m)` now work correctly
    ([#1991](https://github.com/gap-system/gap/pull/1991))

  - Fix `PositionProperty` with from \< 1
    ([#2056](https://github.com/gap-system/gap/pull/2056))

  - Fix inefficiency when dealing with certain algebra modules
    ([#2058](https://github.com/gap-system/gap/pull/2058))

  - Restrict capacity of plain lists to 2^28 in 32-bit and 2^60 in 64-bit
    builds ([#2064](https://github.com/gap-system/gap/pull/2064))

  - Fix crashes with very large heaps (\> 2 GB) on 32 bit systems, and
    work around a bug in `memmove` in 32-bit glibc versions which could
    corrupt memory (affects most current Linux distributions)
    ([#2166](https://github.com/gap-system/gap/pull/2166)).

  - Fix name of the `reversed` option in documentation of
    `LoadAllPackages`
    ([#2167](https://github.com/gap-system/gap/pull/2167)).

  - Fix `TriangulizedMat([])` (see `TriangulizedMat` to return an empty
    list instead of producing an error
    ([#2260](https://github.com/gap-system/gap/pull/2260)).

  - Fix several potential (albeit rare) crashes related to garbage
    collection ([#2321](https://github.com/gap-system/gap/pull/2321),
    [#2313](https://github.com/gap-system/gap/pull/2313),
    [#2320](https://github.com/gap-system/gap/pull/2320)).

### Removed or obsolete functionality:

  - Make `SetUserPreferences` obsolete (use `SetUserPreference` instead)
    ([#512](https://github.com/gap-system/gap/pull/512))

  - Remove undocumented `NameIsomorphismClass`
    ([#597](https://github.com/gap-system/gap/pull/597))

  - Remove unused code for rational classes of permutation groups
    ([#886](https://github.com/gap-system/gap/pull/886))

  - Remove unused and undocumented `Randomizer` and `CheapRandomizer`
    ([#1113](https://github.com/gap-system/gap/pull/1113))

  - Remove `install-tools.sh` script and documentation mentioning it
    ([#1305](https://github.com/gap-system/gap/pull/1305))

  - Withdraw `CallWithTimeout` and `CallWithTimeoutList`
    ([#1324](https://github.com/gap-system/gap/pull/1324))

  - Make `RecFields` obsolete (use `RecNames`
    instead) ([#1331](https://github.com/gap-system/gap/pull/1331))

  - Remove undocumented `SuPeRfail` and `READ_COMMAND`
    ([#1374](https://github.com/gap-system/gap/pull/1374))

  - Remove unused `oldmatint.gi` (old methods for functions that compute
    Hermite and Smith normal forms of integer matrices)
    ([#1765](https://github.com/gap-system/gap/pull/1765))

  - Make `TRANSDEGREES` obsolete
    ([#1852](https://github.com/gap-system/gap/pull/1852))

### **HPC-GAP**

GAP includes experimental code to support multithreaded programming
in GAP, dubbed **HPC-GAP** (where HPC stands for "high performance
computing"). GAP and **HPC-GAP** codebases diverged during the
project, and we are currently working on unifying the codebases and
incorporating the **HPC-GAP** code back into the mainstream GAP
versions.

This is work in progress, and **HPC-GAP** as it is included with GAP
right now still suffers from various limitations and problems, which we
are actively working on to resolve. However, including it with GAP
(disabled by default) considerably simplifies development of
**HPC-GAP**. It also means that you can very easily get a (rough\!)
sneak peak of **HPC-GAP**. It comes together with the new manual book
called "**HPC-GAP** Reference Manual" and located in the \`doc/hpc\`
directory.

Users interested in experimenting with shared memory parallel programming
in GAP can build **HPC-GAP** by following the
[instructions](https://github.com/gap-system/gap/wiki/Building-HPC-GAP).
While it is possible to build **HPC-GAP** from a release version of GAP
you downloaded from the GAP website, due to the ongoing development of
**HPC-GAP**, we recommend that you instead build **HPC-GAP** from the
latest development version available in the GAP [repository at
GitHub](https://github.com/gap-system/gap).

### New and updated packages since GAP 4.8.10

There were 132 packages redistributed together with GAP 4.8.10. The
GAP 4.9.1 distribution includes 134 packages, including numerous
updates of previously redistributed packages, and some major changes
outlined below.

The libraries of small, primitive and transitive groups which previously
were an integral part of GAP were split into three separate packages
[PrimgGrp](http://gap-packages.github.io/primgrp/),
[SmallGrp](https://gap-packages.github.io/smallgrp/) and
[TransGrp](http://www.math.colostate.edu/~hulpke/transgrp/):

  - The **PrimGrp** package by Alexander Hulpke, Colva M. Roney-Dougal
    and Christopher Russell provides the library of primitive
    permutation groups which includes, up to permutation isomorphism
    (i.e., up to conjugacy in the corresponding symmetric group), all
    primitive permutation groups of degree \< 4096.

  - The **SmallGrp** package by Bettina Eick, Hans Ulrich Besche and
    Eamonn O’Brien provides the library of groups of certain "small"
    orders. The groups are sorted by their orders and they are listed up
    to isomorphism; that is, for each of the available orders a complete
    and irredundant list of isomorphism type representatives of groups
    is given.

  - The **TransGrp** package by Alexander Hulpke provides the library of
    transitive groups, with an optional download of the library of
    transitive groups of degree 32.

For backwards compatibility, these are required packages in GAP 4.9
(i.e., GAP will not start without them). We plan to change this for
GAP 4.10 (see
[#2434](https://github.com/gap-system/gap/pull/2434)), once all
packages which currently implicitly rely on these new packages had time
to add explicit dependencies on them
([#1650](https://github.com/gap-system/gap/pull/1650),
[#1714](https://github.com/gap-system/gap/pull/1714)).

The new **ZeroMQInterface** package by Markus Pfeiffer and Reimer
Behrends has been added for the redistribution. It provides both
low-level bindings as well as some higher level interfaces for the
[ZeroMQ](http://zeromq.org/) message passing library for GAP and
**HPC-GAP** enabling lightweight distributed computation.

The **HAPprime** package by Paul Smith is no longer redistributed with
GAP. Part of the code has been incorporated into the **HAP** package. Its
source code repository, containing the code of the last distributed
version, can still be found at <https://github.com/gap-packages/happrime>.

Also, the **ParGAP** package by Gene Cooperman is no longer
redistributed with GAP because it no longer can be compiled with GAP 4.9
(see [this announcement](https://mail.gap-system.org/pipermail/gap/2018-March/001082.html)).
Its source code repository, containing the code of the last distributed
version, plus some first fixes needed for compatibility for GAP 4.9, can
still be found at <https://github.com/gap-packages/pargap>. If somebody
is interested in repairing this package and taking over its maintenance,
so that it can be distributed again, please contact the GAP team.


## GAP 4.8.8 (August 2017)

### Fixed bugs that could lead to incorrect results:

  - Fixed a bug in `RepresentativeAction` producing incorrect answers for
    both symmetric and alternating groups, with both `OnTuples` and
    `OnSets`, by producing elements outside the group. (Reported by Mun
    See Chang)

### Fixed bugs that could lead to break loops:

  - Fixed a bug in `RepresentativeAction` for S_n and A_n acting on
    non-standard domains.

### Other fixed bugs:

  - Fixed a problem with checking the path to a file when using the
    default browser as a help viewer on Windows. (Reported by Jack
    Saunders)

### New and updated packages since GAP 4.8.7

This release contains updated versions of 29 packages from GAP 4.8.7
distribution. Additionally, the **Gpd** package (author: Chris Wensley)
has been renamed to **Groupoids**.


## GAP 4.8.7 (March 2017)

### Fixed bugs that could lead to incorrect results:

  - Fixed a regression from GAP 4.7.6 when reading compressed files after
    a workspace is loaded. Before the fix, if GAP is started with the
    `-L` option (load workspace), using `ReadLine` on the input stream
    for a compressed file returned by `InputTextFile` only returned the
    first character. (Reported by Bill Allombert)

### Other fixed bugs:

  - Fixed compiler warning occurring when GAP is compiled with gcc
    6.2.0. (Reported by Bill Allombert)

### New and updated packages since GAP 4.8.6

This release contains updated versions of 19 packages from GAP 4.8.6
distribution. Additionally, the following package has been added for the
redistribution with GAP:

  - **lpres** package (author: René Hartung, maintainer: Laurent
    Bartholdi) to work with L-presented groups, namely groups given by
    a finite generating set and a possibly infinite set of relations
    given as iterates of finitely many seed relations by a finite set
    of endomorphisms. The package implements nilpotent quotient,
    Todd-Coxeter and Reidemeister-Schreier algorithms for such groups.


## GAP 4.8.6 (November 2016)

### Fixed bugs that could lead to break loops:

  - Fixed regression in the GAP kernel code introduced in GAP
    4.8.5 and breaking `StringFile` ability to work with compressed
    files. (Reported by Bill Allombert)


## GAP 4.8.5 (September 2016)

### Improved and extended functionality:

  - The error messages produced when an unexpected `fail` is returned
    were made more clear by explicitly telling that the result should
    not be boolean or `fail` (before it only said "not a boolean").

  - For consistency, both `NrTransitiveGroups` and `TransitiveGroup` now
    disallow the transitive group of degree 1.

### Fixed bugs that could lead to incorrect results:

  - A bug in the code for algebraic field extensions over non-prime
    fields that may cause, for example, a list of all elements of the
    extension not being a duplicate-free. (Reported by Huta Gana)

  - So far, `FileString` only wrote files of sizes less than 2G and did
    not indicate an error in case of larger strings. Now strings of any
    length can be written, and in the case of a failure the
    corresponding system error is shown.

### Fixed bugs that could lead to break loops:

  - `NaturalHomomorphismByIdeal` was not reducing monomials before
    forming a quotient ring, causing a break loop on some inputs.
    (Reported by Dmytro Savchuk)

  - A bug in `DefaultInfoHandler` caused a break loop on startup with
    the setting `SetUserPreference( "InfoPackageLoadingLevel", 4
    )`\`. (Reported by Mathieu Dutour)

  - The `Iterator` for permutation groups was broken when the
    `StabChainMutable` of the group was not reduced, which can
    reasonably happen as the result of various algorithms.


## GAP 4.8.4 (June 2016)

### New features:

  - The GAP distribution now includes `bin/BuildPackages.sh`, a script
    which can be started from the `pkg` directory via
    `../bin/BuildPackages.sh` and will attempt to build as many
    packages as possible. It replaces the `InstPackages.sh` script
    which was not a part of the GAP distribution and had to be
    downloaded separately from the GAP website. The new script is more
    robust and simplifies adding new packages with binaries, as it
    requires no adjustments if the new package supports the standard
    `./configure; make` build procedure.

### Improved and extended functionality:

  - `SimpleGroup` now produces more informative error message in the case
    when `AtlasGroup` could not load the requested group.

  - An info message with the suggestion to use `InfoPackageLoading` will
    now be displayed when `LoadPackage` returns `fail` (unless GAP is
    started with `-b` option).

  - The build system will now enable C++ support in GMP only if a working
    C++ compiler is detected.

  - More checks were added when embedding coefficient rings or rational
    numbers into polynomial rings in order to forbid adding polynomials
    in different characteristic.

### Fixed bugs that could lead to crashes:

  - Fixed the crash in `--cover` mode when reading files with more than
    65,536 lines.

### Fixed bugs that could lead to incorrect results:

  - Fixed an error in the code for partial permutations that occurred on
    big-endian systems. (Reported by Bill Allombert)

  - Fixed the kernel method for `Remove` with one argument, which failed
    to reduce the length of a list to the position of the last bound
    entry. (Reported by Peter Schauenburg)

Fixed bugs that could lead to break loops:
### 
  - Fixed the break loop while using `Factorization` on permutation
    groups by removing some old code that relied on further caching in
    `Factorization`. (Reported by Grahame Erskine)

  - Fixed a problem with computation of maximal subgroups in an almost
    simple group. (Reported by Ramon Esteban Romero)

  - Added missing methods for `Intersection2` when one of the arguments
    is an empty list. (Reported by Wilf Wilson)

### Other fixed bugs:

  - Fixed several bugs in `RandomPrimitivePolynomial`. (Reported by Nusa
    Zidaric)

  - Fixed several problems with `Random` on long lists in 64-bit GAP
    installations.


## GAP 4.8.3 (March 2016)

### New features:

  - New function `TestPackage` to run standard tests (if available) for a
    single package in the current GAP session (also callable via `make
    testpackage PKGNAME=pkgname` to run package tests in the same
    settings that are used for testing GAP releases).

### Improved and extended functionality:

  - `TestDirectory` now prints a special status message to indicate the
    outcome of the test (this is convenient for automated testing). If
    necessary, this message may be suppressed by using the option
    `suppressStatusMessage`

  - Improved output of tracing methods (which may be invoked, for
    example, with `TraceAllMethods`) by displaying filename and line
    number in some more cases.

### Changed functionality:

  - Fixed some inconsistencies in the usage of `IsGeneratorsOfSemigroup`.

### Fixed bugs that could lead to incorrect results:

  - Fallback methods for conjugacy classes, that were never intended for
    infinite groups, now use `IsFinite` filter to prevent them being
    called for infinite groups. (Reported by Gabor Horvath)

### Fixed bugs that could lead to break loops:

  - Calculating stabiliser for the alternating group caused a break loop
    in the case when it defers to the corresponding symmetric group.

  - It was not possible to use `DotFileLatticeSubgroups` for a trivial
    group. (Reported by Sergio Siccha)

  - A break loop while computing `AutomorphismGroup` for
    `TransitiveGroup(12,269)`. (Reported by Ignat Soroko)

  - A break loop while computing conjugacy classes of `PSL(6,4)`.
    (Reported by Martin Macaj)

### Other fixed bugs:

  - Fix for using Firefox as a default help viewer with `SetHelpViewer`.
    (Reported by Tom McDonough)


## GAP 4.8.2 (February 2016)

This is the first public release of GAP 4.8.

The GAP development repository is now [hosted on
GitHub](https://github.com/gap-system/gap), and GAP 4.8 is the first major
GAP release made from this repository. The public issue tracker for the
core GAP system is located
[here](https://github.com/gap-system/gap/issues), and you may use
appropriate [milestones](https://github.com/gap-system/gap/milestones) to
see all changes that were introduced in corresponding GAP releases. An
overview of the most significant ones is provided below.

### New features:

  - Added support for profiling which tracks how much time in spent on
    each line of GAP code. This can be used to show where code is
    spending a long time and also check which lines of code are even
    executed. See the documentation for `ProfileLineByLine` and
    `CoverageLineByLine` for details on generating profiles, and the
    **Profiling** package for transforming these profiles into a
    human-readable form.

  - Added ability to install (in the library or packages) methods for
    accessing lists using multiple indices and indexing into lists
    using indices other than positive small integers. Such methods
    could allow, for example, to support expressions like

        m[1,2];
        m[1,2,3] := x;
        IsBound(m["a","b",Z(7)]);
        Unbind(m[1][2,3])

  - Added support for partially variadic functions to allow function
    expressions like

        function( a, b, c, x... ) ... end;

    which would require at least three arguments and assign the first
    three to a, b and c and then a list containing any remaining ones to
    x.

    The former special meaning of the argument arg is still supported
    and is now equivalent to `function( arg... )`, so no changes in the
    existing code are required.

  - Introduced `CallWithTimeout` and `CallWithTimeoutList` to call a
    function with a limit on the CPU time it can consume. This
    functionality may not be available on all systems and you should
    check `GAPInfo.TimeoutsSupported` before using this functionality.
    (These functions were withdrawn in GAP 4.9.)

  - GAP now displays the filename and line numbers of statements in
    backtraces when entering the break loop.

  - Introduced `TestDirectory` function to find (recursively) all `.tst`
    files from a given directory or a list of directories and run them
    using `Test`.

### Improved and extended functionality:

  - Method tracing shows the filename and line of function during
    tracing.

  - `TraceAllMethods` and `UntraceAllMethods` to turn on and off tracing
    all methods in GAP. Also, for the uniform approach
    `UntraceImmediateMethods` has been added as an equivalent of
    `TraceImmediateMethods(false)`.

  - The most common cases of `AddDictionary` on three arguments now
    bypass method selection, avoiding the cost of determining
    homogeneity for plain lists of mutable objects.

  - Improved methods for symmetric and alternating groups in the
    "natural" representations and removed some duplicated code.

  - Package authors may optionally specify the source code repository,
    issue tracker and support email address for their package using new
    components in the `PackageInfo.g` file, which will be used to
    create hyperlinks from the package overview page (see
    `PackageInfo.g` from the Example package which you may use as a
    template).

### Changed functionality:

  - As a preparation for the future developments to support
    multithreading, some language extensions from the **HPC-GAP**
    project were backported to the GAP library to help to unify the
    codebase of both GAP 4 and **HPC-GAP**. The only change which is
    not backwards compatible is that `atomic`, `readonly` and
    `readwrite` are now keywords, and thus are no longer valid
    identifiers. So if you have any variables or functions using that
    name, you will have to change it in GAP 4.8.

  - There was inconsistent use of the following properties of semigroups:
    `IsGroupAsSemigroup`, `IsMonoidAsSemigroup`, and
    `IsSemilatticeAsSemigroup`. `IsGroupAsSemigroup` was true for
    semigroups that mathematically defined a group, and for semigroups
    in the category `IsGroup`; `IsMonoidAsSemigroup` was only true for
    semigroups that mathematically defined monoids, but did not belong
    to the category `IsMonoid`; and `IsSemilatticeAsSemigroup` was
    simply a property of semigroups, as there is no category
    `IsSemilattice`.

    From version 4.8 onwards, `IsSemilatticeAsSemigroup` is renamed to
    `IsSemilattice`, and `IsMonoidAsSemigroup` returns true for semigroups
    in the category `IsMonoid`.

    This way all of the properties of the type `IsXAsSemigroup` are
    consistent. It should be noted that the only methods installed for
    `IsMonoidAsSemigroup` belong to the **Semigroups** and **Smallsemi**
    packages.

  - `ReadTest` became obsolete and for backwards compatibility is
    replaced by `Test` with the option to compare the output up to
    whitespaces.

  - The function `ErrorMayQuit`, which differs from `Error` by not
    allowing execution to continue, has been renamed to
    `ErrorNoReturn`.

### Fixed bugs:

  - A combination of two bugs could lead to a segfault. First off,
    `NullMat` (and various other GAP functions), when asked to produce
    matrix over a small field, called `ConvertToMatrixRep`. After this,
    if the user tried to change one of the entries to a value from a
    larger extension field, this resulted in an error. (This is now
    fixed).

    Unfortunately, the C code catching this error had a bug and allowed
    users to type "return" to continue while ignoring the conversion
    error. This was a bad idea, as the C code would be in an
    inconsistent state at this point, subsequently leading to a crash.

    This, too, has been fixed, by not allowing the user to ignore the
    error by entering "return".

  - The Fitting-free code and code inheriting PCGS is now using
    `IndicesEANormalSteps` instead of `IndicesNormalSteps`, as
    these indices are neither guaranteed, nor required to be
    maximally refined when restricting to subgroups.

  - A bug that caused a break loop in the computation of the Hall
    subgroup for groups having a trivial Fitting subgroup.

  - Including a `break` or `continue` statement in a function body
    but not in a loop now gives a syntax error instead of failing
    at run time.

  - `GroupGeneralMappingByImages` now verifies that that image of a
    mapping is contained in its range.

  - Fixed a bug in caching the degree of transformation that could
    lead to a non-identity transformation accidentally changing its
    value to the identity transformation.

  - Fixed the problem with using Windows default browser as a help
    viewer using `SetHelpViewer("browser");`.

### New and updated packages since GAP 4.7.8

At the time of the release of GAP 4.7.8 there were 119 packages
redistributed with GAP. New packages that have been added to the
redistribution since the release of GAP 4.7.8 are:

  - **CAP** (Categories, Algorithms, Programming) package by Sebastian
    Gutsche, Sebastian Posur and Øystein Skartsæterhagen, together with
    three associated packages **GeneralizedMorphismsForCAP**,
    **LinearAlgebraForCAP** and **ModulePresentationsForCAP** (all
    three - by Sebastian Gutsche and Sebastian Posur).

  - **Digraphs** package by Jan De Beule, Julius Jonušas, James Mitchell,
    Michael Torpey and Wilf Wilson, which provides functionality to
    work with graphs, digraphs, and multidigraphs.

  - **FinInG** package by John Bamberg, Anton Betten, Philippe Cara, Jan
    De Beule, Michel Lavrauw and Max Neunhöffer for computation in
    Finite Incidence Geometry.

  - **HeLP** package by Andreas Bächle and Leo Margolis, which computes
    constraints on partial augmentations of torsion units in integral
    group rings using a method developed by Luthar, Passi and Hertweck.
    The package can be employed to verify the Zassenhaus Conjecture and
    the Prime Graph Question for finite groups, once their characters
    are known. It uses an interface to the software package **4ti2** to
    solve integral linear inequalities.

  - **matgrp** package by Alexander Hulpke, which provides an interface
    to the solvable radical functionality for matrix groups, building
    on constructive recognition.

  - **NormalizInterface** package by Sebastian Gutsche, Max Horn and
    Christof Söger, which provides a GAP interface to **Normaliz**,
    enabling direct access to the complete functionality of
    **Normaliz**, such as computations in affine monoids, vector
    configurations, lattice polytopes, and rational cones.

  - **profiling** package by Christopher Jefferson for transforming
    profiles produced by `ProfileLineByLine` and `CoverageLineByLine`
    into a human-readable form.

  - **Utils** package by Sebastian Gutsche, Stefan Kohl and Christopher
    Wensley, which provides a collection of utility functions gleaned
    from many packages.

  - **XModAlg** package by Zekeriya Arvasi and Alper Odabas, which
    provides a collection of functions for computing with crossed
    modules and Cat1-algebras and morphisms of these structures.


## GAP 4.7.8 (June 2015)

### Fixed bugs which could lead to incorrect results:

  - Added two groups of degree 1575 which were missing in the library
    of first primitive groups. (Reported by Gordon Royle)

  - Fixed the error in the code for algebra module elements in packed
    representation caused by the use of `Objectify` with the type
    of the given object instead of `ObjByExtRep` as recommended in
    the reference manual. The problem was that after calculating
    `u+v` where one of the summands was known to be zero, this
    knowledge was wrongly passed to the sum via the type.
    (Reported by Istvan Szollosi)

  - Fixed a bug in `PowerMod` causing wrong results for univariate
    Laurent polynomials when the two polynomial arguments are
    stored with the same non-zero shift. (Reported by Max Horn)

### New Packages

  - **PatternClass** by Michael Albert, Ruth Hoffmann and Steve Linton,
    allowing to explore the permutation pattern classes build by token
    passing networks. Amongst other things, it can compute the basis of
    a permutation pattern class, create automata from token passing
    networks and check if the deterministic automaton is a possible
    representative of a token passing network.

  - **QPA** by Edward Green and Øyvind Solberg, providing data
    structures and algorithms for computations with finite dimensional
    quotients of path algebras, and with finitely generated modules over
    such algebras. It implements data structures for quivers, quotients
    of path algebras, and modules, homomorphisms and complexes of
    modules over quotients of path algebras.


## GAP 4.7.7 (February 2015)

### New features:

  - Introduced some arithmetic operations for infinity and negative
    infinity

  - Introduced new property `IsGeneratorsOfSemigroup` which reflects
    wheter the list or collection generates a semigroup.

### Fixed bugs which could lead to incorrect results:

  - Fixed a bug in `Union` (actually, in the internal library function
    `JoinRanges`) caused by downward running ranges. (Reported by Matt
    Fayers)

  - Fixed a bug where recursive records might be printed with the wrong
    component name, coming from component names being ordered
    differently in two different pieces of code. (Reported by Thomas
    Breuer)

  - The usage of `abs` in `src/gmpints.c` was replaced by `AbsInt`. The
    former is defined to operate on 32-bit integers even if GAP is
    compiled in 64-bit mode. That lead to truncating GAP integers and
    caused a crash in `RemInt`, reported by Willem De Graaf and Heiko
    Dietrich. Using `AbsInt` fixes the crash, and ensures the correct
    behaviour on 32-bit and 64-bit builds.

### Fixed bugs that could lead to break loops:

  - A problem with `ProbabilityShapes` not setting frequencies list for
    small degrees. (Reported by Daniel Błażewicz and independently by
    Mathieu Gagne)

  - An error when generating a free monoid of rank infinity. (Reported by
    Nick Loughlin)

  - Several bugs with the code for Rees matrix semigroups not handling
    trivial cases properly.

  - A bug in `IsomorphismTypeInfoFiniteSimpleGroup` affecting one
    particular group due to a misformatting in a routine that
    translates between the Chevalley type and the name used in the
    table (in this case, `"T"` was used instead of `["T"]`). (Reported
    by Petr Savicky)

### Other fixed bugs:

  - The `Basis` method for full homomorphism spaces of linear mappings
    did not set basis vectors which could be obtained by
    `GeneratorsOfLeftModule`.

  - A problem with `GaloisType` entering an infinite loop in the routine
    for approximating a root. (Reported by Daniel Błażewicz)

  - Fixed the crash when GAP is called when the environment variables
    `HOME` or `PATH` are unset. (Reported by Bill Allombert)

### New packages

  - **json** package by Christopher Jefferson, providing a mapping
    between the **JSON** markup language and GAP

  - **SglPPow** package by Bettina Eick and Michael Vaughan-Lee,
    providing the database of p-groups of order p^7 for p \> 11, and of
    order 3^8.


## GAP 4.7.6 (November 2014)

### Fixed bugs which could lead to incorrect results:

  - A bug that may cause `ShortestVectors` to return an incomplete list.
    (Reported by Florian Beye)

  - A bug that may lead to incorrect results and infinite loops when GAP
    is compiled without GMP support using gcc 4.9.

  - A bug that may cause `OrthogonalEmbeddings` to return an incomplete
    result. (Reported by Benjamin Sambale)

### Fixed bugs that could lead to break loops:

  - `ClosureGroup` should be used instead of `ClosureSubgroup` in case
    there is no parent group, otherwise some calculations such as e.g.
    `NormalSubgroups` may fail. (Reported by Dmitrii Pasechnik)

  - Fixed a line in the code that used a hard-coded identity permutation,
    not a generic identity element of a group. (Reported by Toshio
    Sumi)

  - Fixed a problem in the new code for calculating maximal subgroups
    that caused a break loop for some groups from the transitive groups
    library. (Reported by Petr Savicky)

  - Fixed a problem in `ClosureSubgroup` not accepting some groups
    without `Parent`. (Reported by Inneke van Gelder)

### Other fixed bugs:

  - Eliminated a number of compiler warnings detected with some newer
    versions of **C** compilers.

  - Some minor bugs in the transformation and partial permutation code
    and documentation were resolved.


## GAP 4.7.5 (May 2014)

### Fixed bugs which could lead to incorrect results:

  - `InstallValue` cannot handle immediate values, characters or booleans
    for technical reasons. A check for such values was introduced to
    trigger an error message and prevent incorrect results caused by
    this. (Reported by Sebastian Gutsche)

  - `KnowsDictionary` and `LookupDictionary` methods for
    `IsListLookupDictionary` were using `PositionFirstComponent`; the
    latter is only valid on sorted lists, but in
    `IsListLookupDictionary` the underlying list is NOT sorted in
    general, leading to bogus results.

### Other fixed bugs:

  - A bug in `DirectProductElementsFamily` which used
    `CanEasilyCompareElements` instead of `CanEasilySortElements`.

  - Fixed wrong `Infolevel` message that caused a break loop for some
    automorphism group computations.

  - Fixed an error that sometimes caused a break loop in `HallSubgroup`.
    (Reported by Benjamin Sambale)

  - Fixed a rare error in computation of conjugacy classes of a finite
    group by homomorphic images, providing fallback to a default
    algorithm.

  - Fixed an error in the calculation of Frattini subgroup in the case of
    the trivial radical.

  - Several minor bugs were fixed in the documentation, kernel, and
    library code for transformations.

  - Fixed errors in `NumberPerfectGroups` and
    `NumberPerfectLibraryGroups` not being aware that there are no
    perfect groups of odd order.

  - Restored the ability to build GAP on OS X 10.4 and 10.5 which was
    accidentally broken in the previous GAP release by using the build
    option not supported by these versions.

  - Fixed some problems for ia64 and sparc architectures. (Reported by
    Bill Allombert and Volker Braun)

### New packages

  - **permut** package by A.Ballester-Bolinches, E.Cosme-Llópez, and
    R.Esteban-Romero to deal with permutability in finite groups.


## GAP 4.7.4 (February 2014)

This release was prepared immediately after GAP 4.7.3 to revert the
fix of the error handling for the single quote at the end of an input
line, contained in GAP 4.7.3. It happened that (only on Windows) the
fix caused error messages in one of the packages.


## GAP 4.7.3 (February 2014)

### Fixed bugs which could lead to incorrect results:

  - Incorrect result returned by `AutomorphismGroup(PSp(4,2^n))`.
    (Reported by Anvita)

  - The `Order` method for group homomorphisms newly introduced in
    GAP 4.7 had a bug that caused it to sometimes return incorrect
    results. (Reported by Benjamin Sambale)

### Fixed bugs that could lead to break loops:

  - Several bugs were fixed and missing methods were introduced in the
    new code for transformations, partial permutations and semigroups
    that was first included in GAP 4.7. Some minor corrections were
    made in the documentation for transformations.

  - Break loop in `IsomorphismFpMonoid` when prefixes in generators names
    were longer than one letter. (Reported by Dmytro Savchuk and Yevgen
    Muntyan)

  - Break loop while displaying the result of
    `MagmaWithInversesByMultiplicationTable`. (Reported by Grahame
    Erskine)

### Improved functionality:

  - Better detection of UTF-8 terminal encoding on some systems.
    (Suggested by Andries Brouwer)


## GAP 4.7.2 (December 2013)

This is the first public release of GAP 4.7.

### Improved and extended functionality:

  - The methods for computing conjugacy classes of permutation groups
    have been rewritten from scratch to enable potential use for groups
    in different representations. As a byproduct the resulting code is
    (sometimes notably) faster. It also now is possible to calculate
    canonical conjugacy class representatives in permutation groups,
    which can be beneficial when calculating character tables.

  - The methods for determining (conjugacy classes of) subgroups in
    non-solvable groups have been substantially improved in speed and
    scope for groups with multiple nonabelian composition factors.

  - There is a new method for calculating the maximal subgroups of a
    permutation group (with chief factors of width less or equal 5)
    without calculating the whole subgroup lattice.

  - If available, information from the table of marks library is used to
    speed up subgroup calculations in almost simple factor groups.

  - The broader availability of maximal subgroups is used to improve the
    calculation of double cosets.

  - To illustrate the improvements listed above, one could try, for
    example

        g:=WreathProduct(MathieuGroup(11),Group((1,2)));
        Length(ConjugacyClassesSubgroups(g));

    and

        g:=SemidirectProduct(GL(3,5),GF(5)^3);
        g:=Image(IsomorphismPermGroup(g));
        MaximalSubgroupClassReps(g);

  - Computing the exponent of a finite group G could be extremely slow.
    This was due to a slow default method being used, which computed all
    conjugacy classes of elements in order to compute the exponent. We
    now instead compute Sylow subgroups P_1, ..., P_k of G and use the
    easily verified equality exp(G) = exp(P_1) x ... x exp(P_k). This
    is usually at least as fast and in many cases orders of magnitude
    faster.

        gap> G:=SmallGroup(2^7*9,33);;
        gap> H:=DirectProduct(G, ElementaryAbelianGroup(2^10));;
        gap> Exponent(H); # should take at most a few milliseconds
        72
        gap> K := PerfectGroup(2688,3);;
        gap> Exponent(K); # should take at most a few seconds
        168

  - The functionality in GAP for transformations and transformation
    semigroups has been rewritten and extended. Partial permutations and
    inverse semigroups have been newly implemented. The documentation
    for transformations and transformation semigroups has been improved.
    Transformations and partial permutations are implemented in the
    GAP kernel. Methods for calculating attributes of
    transformations and partial permutations, and taking products, and
    so are also implemented in the kernel. The new implementations are
    largely backwards compatible; some exceptions are given below.

    The degree of a transformation `f` is usually defined as the largest
    positive integer where `f` is defined. In previous versions of
    GAP, transformations were only defined on positive integers less
    than their degree, it was only possible to multiply transformations
    of equal degree, and a transformation did not act on any point
    exceeding its degree. Starting with GAP 4.7, transformations
    behave more like permutations, in that they fix unspecified points
    and it is possible to multiply arbitrary transformations.

      - in the display of a transformation, the trailing fixed points
        are no longer printed. More precisely, in the display of a
        transformation `f` if `n` is the largest value such that
        `n^f<>n` or `i^f=n` for some `i<>n`, then the values exceeding
        `n` are not printed.

      - the display for semigroups of transformations now includes more
        information, for example `<transformation semigroup on 10 pts
        with 10 generators>` and `<inverse partial perm semigroup on 10
        pts with 10 generators>`.

      - transformations which define a permutation can be inverted, and
        groups of transformations can be created.

    Further information regarding transformations and partial
    permutations, can be found in the relevant chapters of the reference
    manual.

    The code for Rees matrix semigroups has been completely rewritten to
    fix the numerous bugs in the previous versions. The display of a
    Rees matrix semigroup has also been improved to include the numbers
    of rows and columns, and the underlying semigroup. Again the new
    implementations should be backwards compatible with the exception
    that the display is different.

    The code for magmas with a zero adjoined has been improved so that
    it is possible to access more information about the original magma.
    The display has also been changed to indicate that the created magma
    is a magma with zero adjoined (incorporating the display of the
    underlying magma). Elements of a magma with zero are also printed so
    that it is clear that they belong to a magma with zero.

    If a semigroup is created by generators in the category
    IsMultiplicativeElementWithOneCollection and
    CanEasilyCompareElements, then it is now checked if the One of the
    generators is given as a generator. In this case, the semigroup is
    created as a monoid.

  - Added a new operation `GrowthFunctionOfGroup` that gives sizes of
    distance spheres in the Cayley graph of a group.

  - A new group constructor `FreeAbelianGroup` for free abelian
    groups has been added. By default, it creates suitable fp
    groups. Though free abelian groups groups do not offer much
    functionality right now, in the future other implementations
    may be provided, e.g. by the **Polycyclic** package.

  - The message about halving the pool size at startup is only shown
    when `-D` command line option is used. (Suggested by Volker
    Braun)

  - An info class called `InfoObsolete` with the default level 0 is
    introduced. Setting it to 1 will trigger warnings at runtime if
    an obsolete variable declared with `DeclareObsoleteSynonym` is
    used. This is recommended for testing GAP distribution and
    packages.

  - The GAP help system now recognises some common different spelling
    patterns (for example, -ise/-ize, -isation/-ization,
    solvable/soluble) and searches for all possible spelling
    options even when the synonyms are not declared.

  - Added new function `Cite` which produces citation samples for GAP
    and packages.

  - It is now possible to compile GAP with user-supplied `CFLAGS`
    which now will not be overwritten by GAP default settings.
    (Suggested by Jeroen Demeyer)

### Fixed bugs:

  - `Union` had O(n^3) behaviour when given many ranges (e.g. it could
    take 10 seconds to find a union of 1000 1-element sets). The new
    implementation reduces that to O(n log n) (and 4ms for the 10
    second example), at the cost of not merging ranges as well as
    before in some rare cases.

  - `IsLatticeOrderBinaryRelation` only checked the existence of upper
    bounds but not the uniqueness of the least upper bound (and dually
    for lower bounds), so in some cases it could return the wrong
    answer. (Reported by Attila Egri-Nagy)

  - `LowIndexSubgroupsFpGroup` triggered a break loop if the list of
    generators of the 2nd argument contained the identity element of
    the group. (Reported by Ignat Soroko)

  - Fixed regression in heuristics used by
    `NaturalHomomorphismByNormalSubgroup` that could produce a
    permutation representation of an unreasonably large degree.
    (Reported by Izumi Miyamoto)

  - Fixed inconsistent behaviour of `QuotientMod( Integers, r, s, m )` in
    the case where s and m are not coprime. This fix also corrects the
    division behaviour of `ZmodnZ` objects, see `QuotientMod` and
    `ZmodnZ`. (Reported by Mark Dickinson)

  - Fixed an oversight in the loading process causing `OnQuit` not
    resetting the options stack after exiting the break loop.

  - Empty strings were treated slightly differently than other strings
    in the GAP kernel, for historical reasons. This resulted in
    various inconsistencies. For example, `IsStringRep("")` returned
    true, but a method installed for arguments of type `IsStringRep`
    would NOT be invoked when called with an empty string.

    We remove this special case in the GAP kernel (which dates back
    the very early days of GAP 4 in 1996). This uncovered one issue
    in the kernel function `POSITION_SUBSTRING` (when calling it with an
    empty string as second argument), which was also fixed.

  - The parser for floating point numbers contained a bug that could
    cause GAP to crash or to get into a state where the only action
    left to the user was to exit GAP via Ctrl-D. For example,
    entering four dots with spaces between them on the GAP prompt
    and then pressing the return key caused GAP to exit.

    The reason was (ironically) an error check in the innards of the
    float parser code which invoked the GAP `Error()` function at a
    point where it should not have.

  - Removing the last character in a string was supposed to overwrite the
    old removed character in memory with a zero byte, but failed to do
    so due to an off-by-one error. For most GAP operations, this has no
    visible effect, except for those which directly operate on the
    underlying memory representation of strings. For example, when
    trying to use such a string to reference a record entry, a
    (strange) error could be triggered.

  - `ViewString` and `DisplayString` are now handling strings, characters
    and immediate FFEs in a consistent manner.

  - Multiple fixes to the build process for less common Debian platforms
    (arm, ia64, mips, sparc, GNU/Hurd). (Suggested by Bill Allombert)

  - Fixes for several regressions in the `gac` script. (Suggested by Bill
    Allombert)

### Changed functionality:

  - It is not possible now to call `WreathProduct` with 2nd argument H
    not being a permutation group, without using the 3rd argument
    specifying the permutation representation. This is an incompatible
    change but it will produce an error instead of a wrong result. The
    former behaviour of `WreathProduct` may now be achieved by using
    `StandardWreathProduct` which returns the wreath product for the
    (right regular) permutation action of H on its elements.

  - The function `ViewLength` to specify the maximal number of lines that
    are printed in `ViewObj` became obsolete, since there was already a
    user preference `ViewLength` to specify this. The value of this
    preference is also accessible in `GAPInfo.ViewLength`.

### New and updated packages since GAP 4.6.5

At the time of the release of GAP 4.6.5 there were 107 packages
redistributed with GAP. The first public release of GAP 4.7
contains 114 packages.

One of essential changes is that the **Citrus** package by J.Mitchell
has been renamed to **Semigroups**. The package has been completely
overhauled, the performance has been improved, and the code has been
generalized so that in the future the same code can be used to compute
with other types of semigroups.

Furthermore, new packages that have been added to the redistribution
since the release of GAP 4.6.5 are:

  - **4ti2interface** package by Sebastian Gutsche, providing an
    interface to [**4ti2**](http://www.4ti2.de), a software package
    for algebraic, geometric and combinatorial problems on linear
    spaces.

  - **CoReLG** by Heiko Dietrich, Paolo Faccin and Willem de Graaf for
    calculations in real semisimple Lie algebras.

  - **IntPic** package by Manuel Delgado, aimed at providing a simple
    way of getting a pictorial view of sets of integers. The main goal
    of the package is producing **Tikz** code for arrays of integers.
    The code produced is to be included in a LaTeX file, which can then
    be processed. Some of the integers are emphasized by using different
    colors for the cells containing them.

  - **LieRing** by Serena Cicalo and Willem de Graaf for constructing
    finitely-presented Lie rings and calculating the Lazard
    correspondence. The package also provides a database of small
    n-Engel Lie rings.

  - **LiePRing** package by Michael Vaughan-Lee and Bettina Eick,
    introducing a new datastructure for nilpotent Lie rings of
    prime-power order. This allows to define such Lie rings for specific
    primes as well as for symbolic primes and other symbolic parameters.
    The package also includes a database of nilpotent Lie rings of order
    at most p^7 for all primes p \> 3.

  - **ModIsom** by Bettina Eick, which contains various methods for
    computing with nilpotent associative algebras. In particular, it
    contains a method to determine the automorphism group and to test
    isomorphisms of such algebras over finite fields and of modular
    group algebras of finite p-groups. Further, it contains a nilpotent
    quotient algorithm for finitely presented associative algebras and a
    method to determine Kurosh algebras.

  - **SLA** by Willem de Graaf for computations with simple Lie
    algebras. The main topics of the package are nilpotent orbits,
    theta-groups and semisimple subalgebras.

Furthermore, some packages have been upgraded substantially since the
GAP 4.6.5 release:

  - **ANUPQ** package by Greg Gamble, Werner Nickel and Eamonn O'Brien
    has been updated after Max Horn joined it as a maintainer. As a
    result, it is now much easier to install and use it with the current
    GAP release.

  - **Wedderga** package by Osnel Broche Cristo, Allen Herman, Alexander
    Konovalov, Aurora Olivieri, Gabriela Olteanu, Ángel del Río and
    Inneke Van Gelder has been extended to include functions for
    calculating local and global Schur indices of ordinary irreducible
    characters of finite groups, cyclotomic algebras over abelian number
    fields, and rational quaternion algebras (contribution by Allen
    Herman).


## GAP 4.6.5 (July 2013)

### Improved functionality:

  - `TraceMethods` and `UntraceMethods` now better check their
    arguments and provide a sensible error message if being called
    without arguments. Also, both variants of calling them are now
    documented.

  - Library methods for `Sortex` are now replaced by faster ones
    using the kernel `SortParallel` functionality instead of making
    expensive zipped lists.

### Fixed bugs which could lead to incorrect results:

  - `IntHexString` wrongly produced a large integer when there were
    too many leading zeros. (Reported by Joe Bohanon)

### Fixed bugs that could lead to break loops:

  - A bug that may occur in some cases while calling
    `TransitiveIdentification`. (Reported by Izumi Miyamoto)

  - The new code for semidirect products of permutation groups,
    introduced in GAP 4.6, had a bug which was causing problems for
    `Projection`. (Reported by Graham Ellis)


## GAP 4.6.4 (April 2013)

### New functionality:

  - New command line option `-O` was introduced to disable loading
    obsolete variables. This option may be used, for example, to
    check that they are not used in a GAP package or one's own GAP
    code.

### Fixed bugs which could lead to incorrect results:

  - Fixed the bug in `NewmanInfinityCriterion` which may cause
    returning `true` instead of `false`. (Reported by Lev
    Glebsky)

### Fixed bugs which could lead to crashes:

  - Fixed the kernel method for `Remove` which did not raise an error
    in case of empty lists, but corrupted the object. The error
    message in a library method is also improved. (Reported by
    Roberto Ràdina)

### Fixed bugs that could lead to break loops:

  - Fixed requirements in a method to multiply a list and an
    algebraic element. (Reported by Sebastian Gutsche)

  - Fixed a bug in `NaturalCharacter` entering a break loop when
    being called on a homomorphism whose image is not a permutation
    group. (Reported by Sebastian Gutsche)

  - Fixed a bug in `ExponentsConjugateLayer` which occurred, for
    example, in some calls of `SubgroupsSolvableGroup` (Reported
    by Ramon Esteban-Romero)

  - Fixed a problem with displaying function fields, e.g.
    `Field(Indeterminate(Rationals,"x"))`. (Reported by Jan Willem
    Knopper)

  - Fixed two bugs in the code for `NaturalHomomorphismByIdeal` for
    polynomial rings. (Reported by Martin Leuner)

  - Added missing method for `String` for `-infinity`.

  - Fixed the bug with `ONanScottType` not recognising product action
    properly in some cases.

  - The method for `SlotUsagePattern` for straight line programs had
    a bug which triggered an error, if the straight line program
    contained unnecessary steps.


## GAP 4.6.3 (March 2013)

### Improved functionality:

  - Several changes were made to `IdentityMat` and `NullMat`. First off,
    the documentation was changed to properly state that these
    functions support arbitrary rings, and not just fields. Also, more
    usage examples were added to the manual.

    For `NullMat`, it is now also always possible to specify a ring element
    instead of a ring, and this is documented. This matches existing
    `IdentityMat` behavior, and partially worked before (undocumented), but
    in some cases could run into error or infinite recursion.

    In the other direction, if a finite field element, `IdentityMat` now
    really creates a matrix over the smallest field containing that element.
    Previously, a matrix over the prime field was created instead, contrary
    to the documentation.

    Furthermore, `IdentityMat` over small finite fields is now substantially
    faster when creating matrices of large dimension (say a thousand or so).

    Finally, `MutableIdentityMat` and `MutableNullMat` were explicitly
    declared obsolete (and may be removed in GAP 4.7). They actually were
    deprecated since GAP 4.1, and their use discouraged by the manual. Code
    using them should switch to `IdentityMat` respectively `NullMat`.

  - Two new `PerfectResiduum` methods were added for solvable and perfect
    groups, handling these cases optimally. Moreover, the existing
    generic method was improved by changing it to use
    `DerivedSeriesOfGroup`. Previously, it would always compute the
    derived series from scratch and then throw away the result.

  - A new `MinimalGeneratingSet` method for groups handled by a nice
    monomorphisms was added, similar to the existing
    `SmallGeneratingSet` method. This is useful if the nice
    monomorphism is already mapping into a pc or pcp group.

  - Added a special method for `DerivedSubgroup` if the group is known to
    be abelian.

### Fixed bugs:

  - Fixed a bug in `PowerModInt` computing r^e mod m in a special case
    when e=0 and m=0. (Reported by Ignat Soroko)

  - `CoefficientsQadic` now better checks its arguments to avoid an
    infinite loop when being asked for a q-adic representation for q=1.
    (Reported by Ignat Soroko)

  - Methods for `SylowSubgroupOp` (see `SylowSubgroup`) for symmetric and
    alternating group did not always set `IsPGroup` and `PrimePGroup`
    for the returned Sylow subgroup.

  - Display of matrices consisting of Conway field elements (which are
    displayed as polynomials) did not print constant 1 terms.

  - Added an extra check and a better error message in the method to
    access *natural* generators of domains using the `.` operator (see
    `GeneratorsOfDomain`).

  - Trying to solve the word problem in an fp group where one or more
    generators has a name of more than one alphabetic character led to
    a break loop.

  - Provided the default method for `AbsoluteIrreducibleModules` as a
    temporary workaround for the problem which may cause returning
    wrong results or producing an error when being called for a
    non-prime field.

  - A bug in the GAP kernel caused `RNamObj` to error out when called
    with a string that had the `IsSSortedList` property set (regardless
    of whether it was set to `true` or `false`). This in turn would
    lead to strange (and inappropriate) errors when using such a string
    to access entries of a record.

  - GAP can store vectors over small finite fields (size at most 256) in
    a special internal data representation where each entry of the
    vector uses exactly one byte. Due to an off-by-one bug, the case of
    a field with exactly 256 elements was not handled properly. As a
    result, GAP failed to convert a vector to the special data
    representation, which in some situations could lead to a crash. The
    off-by-one error was fixed and now vectors over GF(256) work as
    expected.

  - A bug in the code for accessing sublist via the `list{poss}` syntax
    could lead to GAP crashing. Specifically, if the list was a
    compressed vector over a finite field, and the sublist syntax was
    nested, as in `vec{poss1}{poss2}`. This now correctly triggers an
    error instead of crashing.

### New packages

  - **SpinSym** package by L. Maas, which contains Brauer tables of
    Schur covers of symmetric and alternating groups and provides some
    related functionalities.


## GAP 4.6.2 (February 2013)

This is the first public release of GAP 4.6.

### Improved and extended functionality:

  - It is now possible to declare a name as an operation with two or more
    arguments (possibly several times) and *THEN* declare it as an
    attribute. Previously this was only possible in the other order.
    This should make the system more independent of the order in which
    packages are loaded.

  - Words in fp groups are now printed in factorised form if possible and
    not too time-consuming, i.e. `a*b*a*b*a*b` will be printed as
    `(a*b)^3`.

  - Added methods to calculate Hall subgroups in nonsolvable groups.

  - Added a generic method for `IsPSolvable` and a better generic method
    for `IsPNilpotent` for groups.

  - Improvements to action homomorphisms: image of an element can use
    existing stabiliser chain of the image group (to reduce the number
    of images to compute), preimages under linear/projective action
    homomorphisms use linear algebra to avoid factorisation.

  - To improve efficiency, additional code was added to make sure that
    the `HomePcgs` of a permutation group is in `IsPcgsPermGroupRep`
    representation in more cases.

  - Added an operation `SortBy` with arguments being a function f of one
    argument and a list l to be sorted in such a way that `l(f[i]) <=
    l(f[i+1])`.

  - Added a kernel function `MEET_BLIST` which returns `true` if the two
    boolean lists have `true` in any common position and `false`
    otherwise. This is useful for representing subsets of a fixed set
    by boolean lists.

  - When assigning to a position in a compressed FFE vector GAP now
    checks to see if the value being assigned can be converted into an
    internal FFE element if it isn't one already. This uses new
    attribute `AsInternalFFE`, for which methods are installed for
    internal FFEs, Conway FFEs and ZmodpZ objects.

  - Replaced `ViewObj` method for fields by `ViewString` method to
    improve the way how polynomial rings over algebraic extenstions of
    fields are displayed.

  - Made the info string (optional 2nd argument to
    `InstallImmediateMethod`) behave similarly to the info string in
    `InstallMethod`. In particular, `TraceImmediateMethods` now always
    prints the name of the operation.

  - Syntax errors such as `Unbind(x,1)` had the unhelpful property that
    `x` got unbound before the syntax error was reported. A specific
    check was added to catch this and similar cases a little earlier.

  - Allow a `GAPARGS` parameter to the top-level GAP `Makefile` to pass
    extra arguments to the GAP used for manual building.

  - Added an attribute `UnderlyingRingElement` for Lie objects.

  - The function `PrimeDivisors` now became an attribute. (suggested by
    Mohamed Barakat)

  - Added an operation `DistancePerms` with a kernel method for internal
    permutations and a generic method.

  - Added a method for `Subfields` to support large finite fields.
    (reported by Inneke van Gelder)

### Fixed bugs which could lead to crashes:

  - The extremely old `DEBUG_DEADSONS_BAGS` compile-time option has not
    worked correctly for many years and indeed crashes GAP. The type of
    bug it is there to detect has not arisen in many years and we have
    certainly not used this option, so it has been removed. (Reported
    by Volker Braun)

### Other fixed bugs:

  - Scanning of floating point literals collided with iterated use of
    integers as record field elements in expressions like `r.1.2`.

  - Fixed two potential problems in `NorSerPermPcgs`, one corrupting some
    internal data and one possibly mixing up different pcgs.

  - Fixed a performance problem with `NiceMonomorphism`. (reported by
    John Bamberg)

  - Fixed a bug in `ReadCSV` that caused some `.csv` files being parsed
    incorrectly.

### No longer supported:

  - The file `lib/consistency.g`, which contained three undocumented
    auxiliary functions, has been removed from the library. In addition,
    the global record `Revision` is now deprecated, so there is no need
    to bind its components in GAP packages.

### New and updated packages since GAP 4.5.4

At the time of the release of GAP 4.5 there were 99 packages
redistributed with GAP. The first public release of GAP 4.6
contains 106 packages.

The new packages that have been added to the redistribution since the
release of GAP 4.5.4 are:

  - **AutoDoc** package by S. Gutsche, providing tools for automated
    generation of **GAPDoc** manuals.

  - **Congruence** package by A. Konovalov, which provides functions to
    construct various canonical congruence subgroups in SL_2(ℤ), and
    also intersections of a finite number of such subgroups, implements
    the algorithm for generating Farey symbols for congruence subgroups
    and uses it to produce a system of independent generators for these
    subgroups.

  - **Convex** package by S. Gutsche, which provides structures and
    algorithms for convex geometry.

  - **Float** package by L. Bartholdi, which extends GAP
    floating-point capabilities by providing new floating-point handlers
    for high-precision real, interval and complex arithmetic using MPFR,
    MPFI, MPC or CXSC external libraries. It also contains a very
    high-performance implementation of the LLL (Lenstra-Lenstra-Lovász)
    lattice reduction algorithm via the external library FPLLL.

  - **PolymakeInterface** package by T. Baechler and S. Gutsche,
    providing a link to the callable library of the
    [**polymake**](http://www.polymake.org) system.

  - **ToolsForHomalg** package by M. Barakat, S. Gutsche and M.
    Lange-Hegermann, which provides some auxiliary functionality for the
    [**homalg**](http://homalg.math.rwth-aachen.de/) project.

  - **ToricVarieties** package by S. Gutsche, which provides data
    structures to handle toric varieties by their commutative algebra
    structure and by their combinatorics.

Furthermore, some packages have been upgraded substantially since the
GAP 4.5.4 release:

  - Starting from 2.x.x, the functionality for iterated monodromy groups
    has been moved from the **FR** package by L. Bartholdi to a separate
    package IMG (currently undeposited, available at
    <https://github.com/laurentbartholdi/img>). This completely removes
    the dependency of **FR** on external library modules, and should
    make its installation much easier.


## GAP 4.5.7 (December 2012)

### Fixed bugs which could lead to crashes:

  - Closing with `LogInputTo` (or `LogOutputTo`) a logfile opened with
    `LogTo` left the data structures corrupted, resulting in a crash.

  - On 32-bit systems we can have long integers `n` such that
    `Log2Int(n)` is not an immediate integer. In such cases `Log2Int`
    gave wrong or corrupted results which in turn could crash GAP,
    e.g., in `ViewObj(n)`.

  - Some patterns of use of `UpEnv` and `DownEnv` were leading to a
    segfault.

### Other fixed bugs:

  - Viewing of long negative integers was broken, because it went into a
    break loop.

  - Division by zero in `ZmodnZ` (n not prime) produced invalid objects.
    (Reported by Mark Dickinson)

  - Fixed a bug in determining multiplicative inverse for a zero
    polynomial.

  - Fixed a bug causing infinite recursion in
    `NaturalHomomorphismByNormalSubgroup`.

  - A workaround was added to deal with a package method creating pcgs
    for permutation groups for which the entry `permpcgsNormalSteps` is
    missing.

  - For a semigroup of associative words that is not the full semigroup
    of all associative words, the methods for `Size` and `IsTrivial`
    called one another causing infinite recursion.

  - The 64-bit version of the `gac` script produced wrong (\>= 2^31) CRC
    values because of an integer conversion problem.

  - It was not possible to compile GAP on some systems where
    `HAVE_SELECT` detects as false.

  - Numbers in memory options on the command line exceeding 2^32 could
    not be parsed correctly, even on 64-bit systems. (Reported by
    Volker Braun)

### New packages added for the redistribution with GAP:

  - **Float** package by L. Bartholdi, which extends GAP
    floating-point capabilities by providing new floating-point handlers
    for high-precision real, interval and complex arithmetic using MPFR,
    MPFI, MPC or CXSC external libraries. It also contains a very
    high-performance implementation of the LLL (Lenstra-Lenstra-Lovász)
    lattice reduction algorithm via the external library FPLLL.

  - **ToricVarieties** package by S. Gutsche, which provides data
    structures to handle toric varieties by their commutative algebra
    structure and by their combinatorics.


## GAP 4.5.6 (September 2012)

### Improved functionality:

  - The argument of `SaveWorkspace` can now start with `~/` which is
    expanded to the users home directory.

  - Added the method for `Iterator` for `PositiveIntegers`. (Suggested by
    Attila Egri-Nagy).

  - Changed kernel tables such that list access functionality for
    `T_SINGULAR` objects can be installed by methods at the GAP level.

  - In case of saved history, "UP" arrow after starting GAP yields last
    stored line. The user preference `HistoryMaxLines` is now used when
    storing and saving history (see `SetUserPreference`).

### Fixed bugs which could lead to crashes:

  - A crash occuring during garbage collection following a call to
    `AClosVec` for a `GF(2)` code. (Reported by Volker Braun)

  - A crash when parsing certain syntactically invalid code. (Reported by
    multiple users)

  - Fixed and improved command line editing without readline support.
    Fixed a segfault which could be triggered by a combination of "UP"
    and "DOWN" arrows. (Reported by James Mitchell)

  - Fixed a bug in the kernel code for floats that caused a crash on
    SPARC Solaris in 32-bit mode. (Reported by Volker Braun)

### Other fixed bugs:

  - Very large (more than 1024 digit) integers were not being coded
    correctly in function bodies unless the integer limb size was 16
    bits. (Reported by Stefan Kohl)

  - An old variable was used in assertion, causing errors in a debugging
    compilation. (Reported by Volker Braun)

  - The environment variable `PAGER` is now correctly interpreted when it
    contains the full path to the pager program. Furthermore, if the
    external pager `less` is found from the environment it is made sure
    that the option `-r` is used (same for `more -f`). (Reported by
    Benjamin Lorenz)

  - Fixed a bug in `PermliftSeries`. (Reported by Aiichi Yamasaki)

  - Fixed discarder function in lattice computation to distinguish
    general and zuppo discarder. (Reported by Leonard Soicher)

  - The `GL` and `SL` constructors did not correctly handle
    `GL(filter,dim,ring)`.

  - The names of two primitive groups of degree 64 were incorrect.

  - The `\in` method for groups handled by a nice monomorphism sometimes
    could produce an error in situations where it should return false.
    This only happened when using `SeedFaithfulAction` to influence how
    `NiceMonomorphism` builds the nice monomorphims for a matrix
    groups.

  - Wrong `PrintObj` method was removed to fix delegations accordingly to
    the reference manual.

  - Fixed a method for `Coefficients` which, after Gaussian elimination,
    did not check that the coefficients actually lie in the
    left-acting-domain of the vector space. This could lead to a wrong
    answer in a vector space membership test. (Reported by Kevin
    Watkins)

### Improved documentation:

  - Removed outdated statements from the documentation of
    `StructureDescription` which now non-ambiguosly states that
    `StructureDescription` is not an isomorphism invariant:
    non-isomorphic groups can have the same string value, and two
    isomorphic groups in different representations can produce
    different strings.

  - GAP now allows overloading of a loaded help book by another one. In
    this case, only a warning is printed and no error is raised. This
    makes sense if a book of a not loaded package is loaded in a
    workspace and then GAP is started with a root path that contains a
    newer version. (Reported by Sebastian Gutsche)

  - Provided a better description of user preferences mechanism and a
    hint to familiarise with them using `WriteGapIniFile` function to
    create a file which contains descriptions of all known user
    preferences and also sets those user preferences which currently do
    not have their default value. One can then edit that file to
    customize (further) the user preferences for future GAP sessions.

### New packages

  - **AutoDoc** package by S. Gutsche, providing tools for automated
    generation of **GAPDoc** manuals.

  - **Convex** package by S. Gutsche, which provides structures and
    algorithms for convex geometry.

  - **PolymakeInterface** package by T. Baechler and S. Gutsche,
    providing a link to the callable library of the
    [**polymake**](http://www.polymake.org) system.

  - **ToolsForHomalg** package by M. Barakat, S. Gutsche and M.
    Lange-Hegermann, which provides some auxiliary functionality for
    the [**homalg**](http://homalg.math.rwth-aachen.de/) project.


## GAP 4.5.5 (July 2012)

### Fixed bugs which could lead to crashes:

  - For small primes (compact fields) `ZmodnZObj(r,p)` now returns the
    corresponding FFE to avoid crashes when compacting matrices.
    (Reported by Ignat Soroko)

### Other fixed bugs:

  - Fixed a bug in `CommutatorSubgroup` for fp groups causing infinite
    recursion, which could, for example, be triggered by computing
    automorphism groups.

  - Previously, the list of factors of a polynomial was mutable, and
    hence could be accidentally corrupted by callers. Now the list of
    irreducible factors is stored immutable. To deal with implicit
    reliance on old code, always a shallow copy is returned. (reported
    by Jakob Kroeker)

  - Computing high powers of matrices ran into an error for matrices in
    the format of the **cvec** package. Now the library function also
    works with these matrices. (reported by Klaus Lux)

  - The pseudo tty code which is responsible for spawning subprocesses
    has been partially rewritten to allow more than 128 subprocesses on
    certain systems. This mechanism is for example used by **ANUPQ**
    and **nq** packages to compute group quotients via an external
    program. Previously, on Mac OS X this could be done precisely 128
    times, and then an error would occur. That is, one could e.g.
    compute 128 nilpotent quotients, and then had to restart GAP to
    compute more. This also affected other systems, such as OpenBSD,
    where it now also works correctly.

  - On Mac OS X, using GAP compiled against GNU readline 6.2, pasting
    text into the terminal session would result in this text appearing
    very slowly, with a 0.1 sec delay between each "keystroke". This is
    not the case with versions 6.1 and older, and has been reported to
    the GNU readline team. In the meantime, we work around this issue
    in most situations by setting `rl_event_hook` only if
    `OnCharReadHookActive` is set.

  - `ShowUserPreferences` ran into a break loop in case of several
    undeclared user preferences. (Reported by James Mitchell)

  - GAP did not start correctly if the user preference
    `"InfoPackageLoadingLevel"` was set to a number \>= 3. The reason
    is that `PrintFormattedString` was called before it was installed.
    The current fix is a temporary solution.

  - The `"hints"` member of `TypOutputFile` used to contain 3\*100
    entries, yet `addLineBreakHint` would write entries with index up
    to and including 3\*99+3=300, leading to a buffer overflow. This
    would end up overwriting the `"stream"` member with -1. Fixed by
    incrementing the size of `"hints"` to 301. (Reported by Jakob
    Kroeker)

  - The function `IsDocumentedWord` tested the given word against strings
    obtained by splitting help matches at non-letter characters. This
    way, variable names containing underscores or digits were
    erroneously not regarded as documented, and certain substrings of
    these names were erroneously regarded as documented.

  - On Windows, an error occurred if one tried to use the default Windows
    browser as a help viewer (see `SetHelpViewer`). Now the browser
    opens the top of the correspoding manual chapter. The current fix
    is a temporary solution since the problem remains with the
    positioning at the required manual section.

### Improved functionality:

  - `WriteGapIniFile` on Windows now produces the `gap.ini` file with
    Windows style line breaks. Also, an info message is now printed if
    an existing `gap.ini` file was moved to a backup file
    `gap.ini.bak`.

  - The **CTblLib** and **TomLib** packages are removed from the list of
    suggested packages of the core part of GAP. Instead they are added
    to the default list of the user preference `"PackagesToLoad"`. This
    way it is possible to configure GAP to not load these packages via
    changing the default value of `"PackagesToLoad"`.

  - The conjugacy test in S_n for intransitive subgroups was improved.
    This deals with inefficiency issue in the case reported by Stefan
    Kohl.

  - Added `InstallAndCallPostRestore` to `lib/system.g` and call it in
    `lib/init.g` instead of `CallAndInstallPostRestore` for the
    function that reads the files listed in GAP command line. This
    fixes the problem reported by Yevgen Muntyan when `SaveWorkspace`
    was used in a file listed in GAP command line (before, according to
    the documentation, `SaveWorkspace` was only allowed at the main GAP
    prompt).

  - There is now a new user preference `PackagesToIgnore`, see
    `SetUserPreference`. It contains a list of names of packages that
    shall be regarded as not available at all in the current session,
    both for autoloading and for later calls of `LoadPackage`. This
    preference is useful for testing purposes if one wants to run some
    code without loading certain packages.


## GAP 4.5.4 (June 2012)

This is the first public release of GAP 4.5.

This chapter lists most important changes between GAP 4.4.12 and the
first public release of GAP 4.5. It also contains information about
subsequent update releases for GAP 4.5. It is not meant to serve as
a complete account on all improvements; instead, it should be viewed as
an introduction to GAP 4.5, accompanying its release announcement.

### Performance improvements:

  - The GAP kernel now uses [**GMP**](http://gmplib.org/) (GNU multiple
    precision arithmetic library) for faster large integer
    arithmetic.

  - Improved performance for records with large number of components.

  - Speedup of hash tables implementation at the GAP library level.

  - `MemoryUsage` is now much more efficient, in particular for large
    objects.

  - Speedups in the computation of low index subgroups, Tietze
    transformations, calculating high powers of matrices over finite
    fields, `Factorial`, etc.

### New and improved kernel functionality:

  - By default, the GAP kernel compiles with the **GMP** and **readline**
    libraries. The **GMP** library is supplied with GAP and we
    recommend that you use the version we supply. There are some
    problems with some other versions. It is also possible to compile
    the GAP kernel with the system **GMP** if your system has it. The
    **readline** library must be installed on your system in advance to
    be used with GAP.

  - Floating point literals are now supported in the GAP language, so
    that, floating point numbers can be entered in GAP expressions in a
    natural way. Support for floats is now properly documented. GAP has
    an interface using which packages may add new floating point
    implementations and integrate them with the parser. In particular,
    we expect that there will soon be a package that implements
    arbitrary precision floating point arithmetic.

  - The Mersenne twister random number generator has been made
    independent of endianness, so that random seeds can now be
    transferred between architectures.

  - Defaults for `-m` and `-o` options have been increased. Changes have
    been made to the way that GAP obtains memory from the Operating
    System, to make GAP more compatible with C libraries. A new `-s`
    option has been introduced to control or turn off the new
    behaviour.

  - The filename and lines from which a function was read can now be
    recovered using `FilenameFunc`, `StartlineFunc` and `EndlineFunc`.
    This allows you, for example, to implement a function such as
    `PageSource` to show the file containing the source code of a
    function or a method in a pager, see `Pager`.

  - `CallFuncList` was made into an operation so that it can be used to
    define behaviour of a non-function when called as a function.

  - Improvements to the cyclotomic number arithmetic for fields with
    large conductors.

  - Better and more flexible viewing of some large objects.

  - Opportunity to interrupt some long kernel computations, e.g.
    multiplication of compressed matrices, intercepting `Ctrl-C` in
    designated places in the kernel code by means of a special kernel
    function for that purpose.

  - `ELM_LIST` now allows you to install methods where the second
    argument is NOT a positive integer.

  - Kernel function `DirectoryContents` to get the list of names of files
    and subdirectories in a directory.

  - Kernel functions for Kronecker product of compressed matrices, see
    `KroneckerProduct`.

### New and improved library functionality:

  - Extensions of data libraries:

      - Functions and iterators are now available to create and
        enumerate simple groups by their order up to isomorphism:
        `SimpleGroup`, `SmallSimpleGroup`, `SimpleGroupsIterator` and
        `AllSmallNonabelianSimpleGroups`.

      - See also packages **CTblLib**, **IRREDSOL** and **Smallsemi**.

  - Many more methods are now available for the built-in floating point
    numbers.

  - The bound for the proper primality test in `IsPrimeInt` increased up
    to 10^18.

  - Improved code for determining transversal and double coset
    representatives in large groups.

  - Improvements in `Normalizer` for S_n.

  - Smith normal form of a matrix may be computed over arbitrary
    euclidean rings, see `NormalFormIntMat`.

  - Improved algorithms to determine the subgroup lattice of a group, as
    well as the function `DotFileLatticeSubgroups` to save the lattice
    structure in `.dot` file to view it e.g. with **GraphViz**.

  - Special teaching mode which simplifies some output and provides more
    basic functionality.

  - Functionality specific for use in undergraduate abstract algebra
    courses, e.g. checksums; string/integer list conversion; rings of
    small orders; the function `SetNameObject` to set display names for
    objects for more informative examples, e.g. constructing groups
    from "named" objects, such as, for example, `R90` for a 90-degree
    rotation).

  - Functions `DirectoryDesktop` and `DirectoryHome` which provide
    uniform access to default directories under Windows, Mac OS X and
    Unix.

  - Improved methods for hashing when computing orbits.

  - Functionality to call external binaries under Windows.

  - Symplectic groups over residue class rings, see `SymplecticGroup`.

  - Basic version of the simplex algorithm for matrices.

  - New functions, operations and attributes: `PrimeDivisors`, `Shuffle`
    for lists, `IteratorOfPartitions`, `IteratorOfCombinations`,
    `EnumeratorOfCombinations` and others.

  - The behaviour of `Info` statements can now be configured per info
    class, this applies to the way the arguments are printed and to the
    output stream.

  - New function `Test` which is a more flexible and informative
    substitute of `ReadTest` operation.

  - `ConnectGroupAndCharacterTable` is replaced by more robust function
    `CharacterTableWithStoredGroup`.

### Many problems in GAP have have been fixed, among them the following:

  - Polynomial factorisation over rationals could miss factors of degree
    greater than deg(f)/2 if they have very small coefficients, while
    the cofactor has large coefficients.

  - `IntermediateSubgroups` called on
    a group and a normal subgroup did not properly calculate maximal
    inclusion relationships.

  - `CentreOfCharacter` and `ClassPositionsOfCentre` called for a group
    character could return a perhaps too large result.

  - `Trace` called for an element of a finite field that was created
    with `AlgebraicExtension` ran into an error.

  - `IrreducibleRepresentationsDixon` did not accept a list with one
    character as a second argument.

  - Composing a homomorphism from a permutation group to a finitely
    presented group with another homomorphism could give wrong results.

  - For certain arguments, the function `EU` returned wrong results.

  - In the table of marks of cyclic groups, `NormalizersTom` value was
    wrong.

  - The function `PermChars` returned a perhaps wrong result when the
    second argument was a positive integer (not a record) and the
    trivial character of the character table given as the first
    argument was not the first in the list of irreducibles.

  - GAP crashed when the intersection of ranges became empty.

  - `IsPSL`, and in turn `StructureDescription`, erroneously recognised
    non-PSL groups of the right order as PSL.

  - The semidirect product method for pcgs computable groups sometimes
    tried to use finite presentations which were not polycyclic. This
    usually happened when the groups were not pc groups, and there was
    a very low risk of getting a wrong result.

  - The membership test for a group of finite field elements ran into an
    error if the zero element of the field was given as the first
    argument.

  - Constant polynomials were not recognised as univariate in any
    variable.

  - The kernel recursion depth counter was not reset properly when
    running into many break loops.

  - GAP did not behave well when printing of a (large) object was
    interrupted with `Ctrl-C`. Now the object is no longer corrupted
    and the indentation level is reset.

### Potentially incompatible changes:

  - The zero polynomial now has degree `-infinity`, see
    `DegreeOfLaurentPolynomial`.

  - Multiple unary `+` or `-` signs are no longer allowed (to avoid
    confusion with increment/decrement operators from other programming
    languages).

  - Due to changes to improve the performance of records with large
    number of components, the ordering of record components in `View`'ed
    records has changed.

  - Due to improvements for vectors over finite fields, certain objects
    have more limitations on changing their base field. For example, one
    cannot create a compressed matrix over GF(2) and then assign an
    element of GF(4) to one of its entries.

### No longer supported:

  - Completion files mechanism.

  - GAP 3 compatibility mode.

In addition, we no longer recommend using the GAP compiler `gac` to
compile GAP code to **C**, and may withdraw it in future releases.
Compiling GAP code only ever gave a substantial speedup for rather
specific types of calculation, and much more benefit can usually be
achieved quite easily by writing a small number of key functions in
**C** and loading them into the kernel as described in
`LoadDynamicModule`. The `gac` script
will remain available as a convenient way of compiling such kernel
modules from **C**.

Also, the following functions and operations were made obsolete:
`AffineOperation`, `AffineOperationLayer`, `FactorCosetOperation`,
`DisplayRevision`, `ProductPol`, `TeXObj`, `LaTeXObj`.

### Changes in distribution formats

The GAP 4.5 source distribution has the form of a single archive
containing the core system and the most recent "stable" versions of all
currently redistributed packages. There are no optional archives to
download: the **TomLib** package now contains all its tables of marks in
one archive; we do not provide separate versions of manuals for Internet
Explorer, and the former `tools` archive is now included as an archive
in the `etc` directory. To unpack and install the archive, user the
script `etc/install-tools.sh`.

We no longer distribute separate bugfix archives when the core GAP
system changes, or updated packages archives when a redistributed
package is updated. Instead, the single GAP source distribution
archive will be labelled by the version of the core GAP system and
also by a timestamp. This archive contains the core system and the
stable versions of the relevant packages on that date. To upgrade, you
simply replace the whole directory containing the GAP installation,
and rebuild binaries for the GAP kernel and packages. For new
versions of packages, we will also continue to redistribute individual
package archives so it will be possible to update a single package
without changing the rest of the GAP installation.

Furthermore, by default GAP will now automatically read a
user-specific GAP root directory (unless GAP is called with the
`-r` option). All user settings can be made in that directory, so there
will be no risk of them being lost during an update. Private
packages can also be installed in this directory for the same reason.

There are some changes in archive formats used for the distribution: we
continue to provide `.tar.gz`, `.tar.bz2` and `-win.zip` archives. We
have added `.zip`, and stopped providing `.zoo` archives. We no longer
provide GAP binaries for Mac OS 9 (Classic) any more. For installations
from source on Mac OS X one may follow the instructions for UNIX.

With the release of GAP 4.5, we also encourage more users to take
advantage of the increasingly mature binary distributions which are now
available. These include:

  - The binary [`rsync` distribution](http://www.math.rwth-aachen.de/~Frank.Luebeck/gap/rsync)
    for GAP on Linux PCs with i686 or x86_64 compatible processors provided by Frank Lübeck.

  - [**BOB**](http://www-groups.mcs.st-and.ac.uk/~neunhoef/Computer/Software/Gap/bob.html),
    a tool for Linux and Mac OS X to download and build GAP
    and its packages from source provided by M. Neunhöffer.

  - The [GAP installer for Windows](https://www.gap-system.org/ukrgap/wininst/),
    provided by Alexander Konovalov.

In the near future, we also hope to have a binary distribution for Mac
OS X.

Internally, we now have infrastructure to support more robust and
frequent releases, and an improved system to fetch and test new versions
of the increasingly large number of packages. The **Example** package
documents technical requirements for packages, many of which are checked
automatically by our systems. This will allow us to check the
compatibility of packages with the system and with other packages more
thoroughly before publishing them on the GAP website.

### Improvements to the user interface

By default, GAP now uses the **readline** library for command line
editing. It provides such advantages as working with unicode terminals,
nicer handling of long input lines, improved TAB-completion and flexible
configuration. For further details, see Reference: Editing using the
readline library.

We have extended facilities for user interface customisation. By default
GAP automatically scans a user specific GAP root directory
(unless GAP is called with the `-r` option). The name of this user
specific directory depends on the operating system and is contained in
`GAPInfo.UserGapRoot`. This directory can be used to tell GAP about
personal preferences, to load some additional code, to install
additional packages, or to overwrite some GAP files, see Reference:
GAP Root Directories. Instead of a single `.gaprc` file we now use more
flexible setup based on two files: `gap.ini` which is read early in the
startup process, and `gaprc` which is read after the startup process,
but before the first input file given on the command line. These files
may be located in the user specific GAP root directory
`GAPInfo.UserGapRoot` which by default is the first GAP root
directory, see Reference: The gap.ini and gaprc files. For
compatibility, the `.gaprc` file is still read if the directory
`GAPInfo.UserGapRoot` does not exist. See Reference: The former .gaprc
file for the instructions how to migrate your old setup.

Furthermore, there are functions to deal with user preferences, for
example, to specify how GAP's online help is shown or whether the
coloured prompt should be used. Calls to set user preferences may appear
in the user's `gap.ini` file, as explained in Reference: Configuring
User preferences.

In the Windows version, we include a new shell which uses the **mintty**
terminal in addition to the two previously used shells (Windows command
line and **RXVT**). The **mintty** shell is now recommended. It supports
Unicode encoding and has flexible configurations options. Also, GAP
under Windows now starts in the `%HOMEDRIVE%%HOMEPATH%` directory, which
is the user's home directory. Besides this, a larger workspace is now
permitted without a need to modify the Windows registry.

Other changes in the user interface include:

  - the command line history is now implemented at the GAP level, it
    can be stored on quitting a GAP session and reread when starting
    a new session, see Reference: The command line history.

  - `SetPrintFormattingStatus("stdout",false);` may be used to switch
    off the automatic line breaking in terminal output, see
    `SetPrintFormattingStatus`.

  - GAP supports terminals with up to 4096 columns (extendable at
    compile time).

  - Directories in `-l` command-line option can now be specified
    starting with `~/`.

  - Large integers are now displayed by a short string showing the first
    and last few digits, and the threshold to trigger this behaviour is
    user configurable (call `UserPreference("MaxBitsIntView")` to see
    the default value).

  - The GAP banner has been made more compact and informative.

  - `SetHelpViewer` now supports the Google
    Chrome browser.

  - Multiple matches in the GAP online help are displayed via a
    function from the **Browse** package, which is loaded in the default
    configuration. This feature can be replaced by the known pager using
    the command

    ``` normal

    SetUserPreference( "browse", "SelectHelpMatches", false );
    ```

### Better documentation

The main GAP manuals have been converted to the **GAPDoc** format
provided by the
[**GAPDoc**](http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc)
package by Frank Lübeck and Max Neunhöffer. This documentation format is
already used by many packages and is now recommended for all GAP
documentation.

Besides improvements to the documentation layout in all formats (text,
PDF and HTML), the new GAP manuals incorporate a large number of
corrections, clarifications, additions and updated examples.

We now provide two HTML versions of the manual, one of them with
[**MathJax**](http://www.mathjax.org) support for better display of
mathematical symbols. Also, there are two PDF versions of the manual - a
coloured and a monochrome one.

Several separate manuals now became parts of the GAP Reference
manual. Thus, now there are three main GAP manual books:

  - *GAP Tutorial*

  - *GAP Reference manual*

  - *GAP - Changes from Earlier Versions*

Note that there is no index file combining these three manuals. Instead
of that, please use the GAP help system which will search all of
these and about 100 package manuals.

### Packages in GAP 4.5

Here we list most important changes affecting packages and present new
or essentially changed packages.

### Interface between the core system and packages

The package loading mechanism has been improved. The most important new
feature is that all dependencies are evaluated in advance and then used
to determine the order in which package files are read. This allows GAP
to handle cyclic dependencies as well as situations where package A
requires package B to be loaded completely before any file of package A
is read. To avoid distortions of the order in which packages will be
loaded, package authors are strongly discouraged from calling
`LoadPackage` and `TestPackageAvailability` in a package code in order
to determine whether some other package will be loaded before or
together with the current package - instead, one should use
`IsPackageMarkedForLoading`. In addition, there is now a better error
management if package loading fails for packages that use the new
functionality to log package loading messages (see
`DisplayPackageLoadingLog` and the rest of the Chapter "Using and
Developing GAP Packages" in the reference manual which documents how to
*use* GAP packages), and package authors are very much encouraged to use
these logging facilities.

In GAP 4.4 certain packages were marked as *autoloaded* and would be
loaded, if present, when GAP started up. In GAP 4.5, this notion is
divided into three. Certain packages are recorded as *needed* by the GAP
system and others as *suggested*, in the same way that packages may
*need* or *suggest* other packages. If a needed package is not loadable,
GAP will not start. Currently only **GAPDoc** is needed. If a suggested
package is loadable, it will be loaded. Typically these are packages
which install better methods for Operations and Objects already present
in GAP. Finally, the user preferences mechanism can be used to specify
additional packages that should be loaded if possible. By default this
includes most packages that were autoloaded in GAP 4.4.12, see
`ShowUserPreferences`.

GAP packages may now use local *namespaces* to avoid name clashes for
global variables introduced in other packages or in the GAP library, see
Reference: Namespaces for GAP packages.

All guidance on how to *develop* a GAP package has been consolidated in
the **Example** package which also contains a checklist for upgrading a
GAP package to GAP 4.5 (the guidance has been transferred to Reference:
Using and Developing GAP Packages in GAP 4.9).

### New and updated packages since GAP 4.4.12

At the time of the release of GAP 4.4.12 there were 75 packages
redistributed with GAP (including the **TomLib** which was
distributed in the core GAP archive). The first public release of
GAP 4.5 contains precisely 99 packages.

The new packages that have been added to the redistribution since the
release of GAP 4.4.12 are:

  - **Citrus** package by J.D. Mitchell for computations with
    transformation semigroups and monoids (this package is a replacement
    of the **Monoid** package).

  - **cvec** package by M. Neunhöffer, providing an implementation of
    compact vectors over finite fields.

  - **fwtree** package by B. Eick and T. Rossmann for computing trees
    related to some pro-p-groups of finite width.

  - **GBNP** package by A.M. Cohen and J.W. Knopper, providing
    algorithms for computing Grobner bases of noncommutative polynomials
    over fields with respect to the "total degree first then
    lexicographical" ordering.

  - **genss** package by M. Neunhöffer and F. Noeske, implementing the
    randomised Schreier-Sims algorithm to compute a stabiliser chain and
    a base and a strong generating set for arbitrary finite groups.

  - **HAPprime** package by P. Smith, extending the **HAP** package with
    an implementation of memory-efficient algorithms for the calculation
    of resolutions of small prime-power groups.

  - **hecke** package by D. Traytel, providing functions for calculating
    decomposition matrices of Hecke algebras of the symmetric groups and
    q-Schur algebras (this package is a port of the GAP 3 package
    **Specht 2.4** to GAP 4).

  - [**Homalg**](http://homalg.math.rwth-aachen.de/) project by
    M. Barakat, S. Gutsche, M. Lange-Hegermann et
    al., containing the following packages for the homological algebra:
    **homalg**, **ExamplesForHomalg**, **Gauss**, **GaussForHomalg**,
    **GradedModules**, **GradedRingForHomalg**, **HomalgToCAS**,
    **IO_ForHomalg**, **LocalizeRingForHomalg**, **MatricesForHomalg**,
    **Modules**, **RingsForHomalg** and **SCO**.

  - **MapClass** package by A. James, K. Magaard and S. Shpectorov to
    calculate the mapping class group orbits for a given finite group.

  - **recogbase** package by M. Neunhöffer and A. Seress, providing a
    framework to implement group recognition methods in a generic way
    (suitable, in particular, for permutation groups, matrix groups,
    projective groups and black box groups).

  - **recog** package by M. Neunhöffer, A. Seress, N. Ankaralioglu, P.
    Brooksbank, F. Celler, S. Howe, M. Law, S. Linton, G. Malle, A.
    Niemeyer, E. O'Brien and C.M. Roney-Dougal, extending the
    **recogbase** package and provides a collection of methods for the
    constructive recognition of groups (mostly intended for permutation
    groups, matrix groups and projective groups).

  - **SCSCP** package by A. Konovalov and S. Linton, implementing the
    Symbolic Computation Software Composability Protocol
    [**SCSCP**](http://www.symbolic-computation.org/scscp) for GAP, which
    provides interfaces to link a GAP instance with another copy of GAP or
    other **SCSCP**-compliant system running locally or remotely.

  - **simpcomp** package by F. Effenberger and J. Spreer for working
    with simplicial complexes.

  - **Smallsemi** package by A. Distler and J.D. Mitchell, containing
    the data library of all semigroups with at most 8 elements as well
    as various information about them.

  - **SymbCompCC** package by D. Feichtenschlager for computations with
    parametrised presentations for finite p-groups of fixed coclass.

Furthermore, some packages have been upgraded substantially since the
GAP 4.4.12 release:

  - **Alnuth** package by B. Assmann, A. Distler and B. Eick uses an
    interface to PARI/GP system instead of the interface to KANT (thanks
    to B. Allombert for the GP code for the new interface and help with
    the transition) and now also works under Windows.

  - **CTblLib** package (the GAP Character Table Library) by T.
    Breuer has been extended by many new character tables, a few bugs
    have been fixed, and new features have been added, for example
    concerning the relation to GAP's group libraries, better search
    facilities, and interactive overviews. For details, see the package
    manual.

  - **DESIGN** package by L.H. Soicher:

      - The functions `PointBlockIncidenceMatrix`, `ConcurrenceMatrix`,
        and `InformationMatrix` compute matrices associated with block
        designs.

      - The function `BlockDesignEfficiency` computes certain
        statistical efficiency measures of a 1-(v,k,r) design, using
        exact algebraic computation.

  - **Example** package by W. Nickel, G. Gamble and A. Konovalov has a
    more detailed and up-to-date guidance on developing a GAP
    package.

  - **FR** package by L. Bartholdi now uses floating-point numbers to
    compute approximations of rational maps given by their
    group-theoretical description.

  - The **GAPDoc** package by F. Lübeck and M. Neunhöffer provides
    various improvements, for example:

      - The layout of the text version of the manuals can be configured
        quite freely, several standard "themes" are provided. The
        display is now adjusted to the current screen width.

      - Some details of the layout of the HTML version of the manuals
        can now be configured by the user. All manuals are available
        with and without MathJax support for display of mathematical
        formulae.

      - The text and HTML versions of manuals make more use of unicode
        characters (but the text version is also still reasonably good
        on terminals with latin1 or ASCII encoding).

      - The PDF version of the manuals uses better fonts.

      - Of course, there are various improvements for authors of manuals
        as well, for example new functions `ExtractExamples` and
        `RunExamples` for automatic testing and correcting of manual
        examples.

  - **Gpd** package by E.J. Moore and C.D. Wensley has been
    substantially rewritten. The main extensions provide functions for:

      - Subgroupoids of a direct product with complete graph groupoid,
        specified by a root group and choice of rays.

      - Automorphisms of finite groupoids - by object permutations; by
        root group automorphisms; and by ray images.

      - The automorphism group of a finite groupoid together with an
        isomorphism to a quotient of permutation groups.

      - Homogeneous groupoids (unions of isomorphic groupoids) and their
        morphisms, in particular homogeneous discrete groupoids: the
        latter are used in constructing crossed modules of groupoids in
        the **XMod** package.

  - **GRAPE** package by L.H. Soicher:

      - With much help from A. Hulpke, the interface between **GRAPE**
        and `dreadnaut` is now done entirely in GAP code.

      - A 32-bit `nauty/dreadnaut` binary for Windows (XP and later) is
        included with **GRAPE**, so now **GRAPE** provides full
        functionality under Windows, with no installation necessary.

      - Graphs with ordered partitions of their vertices into
        "colour-classes" are now handled by the graph automorphism group
        and isomorphism testing functions. An automorphism of a graph
        with colour-classes is an automorphism of the graph which
        additionally preserves the list of colour-classes (classwise),
        and an isomorphism from one graph with colour-classes to a
        second is a graph isomorphism from the first graph to the second
        which additionally maps the first list of colour-classes to the
        second (classwise).

      - The GAP code and old standalone programs for the
        undocumented functions `Enum` and `EnumColadj` have been removed
        as their functionality can now largely be handled by current
        documented GAP and **GRAPE** functions.

  - **IO** package by M. Neunhöffer:

      - New build system to allow for more flexibility regarding the use
        of compiler options and adjusting to GAP 4.5.

      - New functions to access time like `IO_gettimeofday`, `IO_gmtime`
        and `IO_localtime`.

      - Some parallel skeletons built on `fork` like: `ParListByFork`,
        `ParMapReduceByFork`, `ParTakeFirstResultByFork` and
        `ParWorkerFarmByFork`.

      - `IOHub` objects for automatic I/O multiplexing.

      - New functions `IO_gethostbyname` and `IO_getsockname`.

  - **IRREDSOL** package by B. Höfling now covers all irreducible
    soluble subgroups of GL(n,q) for q^n \< 1000000 and primitive
    soluble permutation groups of degree \< 1000000 (previously, the
    bound was 65536). It also has faster group recognition and adds a
    few omissions for GL(3,8) and GL(6,5).

  - **ParGAP** package by G. Cooperman is now compiled using a
    system-wide MPI implementation by default to facilitate running it
    on proper clusters. There is also an option to build it with the
    **MPINU** library which is still supplied with the package (thanks
    to P. Smith for upgrading **ParGAP** build process).

  - **OpenMath** package by M. Costantini, A. Konovalov, M. Nicosia and
    A. Solomon now supports much more OpenMath symbols to facilitate
    communication by the remote procedure call protocol implemented in
    the **SCSCP** package. Also, a third-party external library to
    support binary OpenMath encoding has been replaced by a proper
    implementation made entirely in GAP.

  - **Orb** package by J. Müller, M. Neunhöffer and F. Noeske:

    There have been numerous improvements to this package:

      - A new fast implementation of AVL trees (balanced binary trees)
        in C.

      - New interface to hash table functionality and implementation in
        C for speedup.

      - Some new hash functions for various object types like
        transformations.

      - New function `ORB_EstimateOrbitSize` using the birthday paradox.

      - Improved functionality for product replacer objects.

      - New "tree hash tables".

      - New functionality to compute weak and strong orbits for
        semigroups and monoids.

      - `OrbitGraph` for Orb orbits.

      - Fast C kernel methods for the following functions:

        `PermLeftQuoTransformationNC`, `MappingPermSetSet`,
        `MappingPermListList`, `ImageSetOfTransformation`, and
        `KernelOfTransformation`.

      - New build system to allow for more flexibility regarding the use
        of compiler options and to adjust to GAP 4.5.

  - **RCWA** package by S. Kohl among the new features and other
    improvements has the following:

      - A database of all 52394 groups generated by 3 class
        transpositions of ℤ which interchange residue classes with
        modulus less than or equal to 6. This database contains the
        orders and the moduli of all of these groups. Also it provides
        information on what is known about which of these groups are
        equal and how their finite and infinite orbits on ℤ look like.

      - More routines for investigating the action of an rcwa group on
        ℤ. Examples are a routine which attempts to find out whether a
        given rcwa group acts transitively on the set of nonnegative
        integers in its support and a routine which looks for finite
        orbits on the set of all residue classes of ℤ.

      - Ability to deal with rcwa permutations of ℤ^2.

      - Important methods have been made more efficient in terms of
        runtime and memory consumption.

      - The output has been improved. For example, rcwa permutations are
        now `Display`'ed in ASCII text resembling LaTeX output.

  - The **XGAP** package by F. Celler and M. Neunhöffer can now be used
    on 64-bit architectures (thanks to N. Eldredge and M. Horn for
    sending patches). Furthermore, there is now an export to XFig option
    (thanks to Russ Woodroofe for this patch). The help system in
    **XGAP** has been adjusted to GAP 4.5.

  - Additionally, some packages with kernel modules or external binaries
    are now available in Windows. The `-win.zip` archive and the GAP
    installer for Windows include working versions of the following
    packages: **Browse**, **cvec**, **EDIM**, **GRAPE**, **IO** and
    **orb**, which were previously unavailable for Windows users.

Finally, the following packages are withdrawn:

  - **IF** package by M. Costantini is unmaintained and no longer
    usable. More advanced functionality for interfaces to other computer
    algebra systems is now available in the **SCSCP** package by A.
    Konovalov and S. Linton.

  - **Monoid** package by J. Mitchell is superseded by the **Citrus**
    package by the same author.

  - **NQL** package by R. Hartung has been withdrawn by the author.


## GAP 4.4 Update 12 (December 2008)

### Fixed bugs which could lead to crashes:

  - A bug whereby leaving an incomplete statement on a line (for
    instance typing while and then return) when prompt colouring was in
    use could lead to GAP crashing.

### Other fixed bugs:

  - A bug which made the command-line editor unusable in a 64-bit version
    of GAP on Mac OS X.


## GAP 4.4 Update 11 (December 2008)

### Fixed bugs which could produce wrong results:

  - `MemoryUsage` on objects with no subobjects left them in the cache
    and thus reported 0 in subsequent calls to MemoryUsage for the same
    object. (Reported by Stefan Kohl)

  - `Irr` might be missing characters. (Reported by Angel del Rio)

  - Up to now, it was allowed to call the function
    `FullMatrixAlgebraCentralizer` with a field and a list of matrices
    such that the entries of the matrices were not contained in the
    field; in this situation, the result did not fit to the
    documentation. Now the entries of the matrices are required to lie
    in the field, if not then an error is signaled.

  - For those finite fields that are regarded as field extensions over
    non-prime fields (one can construct such fields with `AsField`),
    the function `DefiningPolynomial` erroneously returned a polynomial
    w.r.t. the extension of the prime field. (Reported by Stefan Kohl)

  - Since the release of GAP 4.4.10, the return values of the function
    `QuaternionAlgebra` were not consistent w.r.t. the attribute
    `GeneratorsOfAlgebra`; the returned list could have length four or
    five. Now always the list of elements of the canonical basis is
    returned.

  - `MonomialGrevlexOrdering` calculated a wrong ordering in certain
    cases. (Reported by Paul Smith)

  - The (GAP kernel) method for the operation `IntersectSet` for ranges
    had two bugs, which could yield a result range with either too few
    or too many elements. As a consequence, for example the
    `Intersection` results for ranges could be wrong. (Reported by
    Matthew Fayers)

  - Fixed a bug in the short-form display of elements of larger finite
    fields, a bug in some cross-field conversions and some
    inefficiencies and a missing method in the `LogFFE` code. (Reported
    by Jia Huang)

  - In rare cases `SmithNormalFormIntegerMatTransforms` returned a wrong
    normal form (the version without transforming matrices did not have
    this problem). This is fixed. (Reported by Alexander Hulpke)

  - The variant of the function `StraightLineProgram` that takes a string
    as its first argument returned wrong results if the last character
    of this string was a closing bracket.

  - The code for central series in a permutation group used too tight a
    bound and thus falsely return a nilpotent permutation group as
    non-nilpotent.

### Fixed bugs which could lead to crashes:

  - Under certain circumstances the kernel code for position in blists
    would access a memory location just after the end of the blist. If
    this location was not accessible, a crash could result. This was
    corrected and the code was cleaned up. (Reported by Alexander
    Hulpke)

### Other fixed bugs:

  - The function `IsomorphismTypeInfoFiniteSimpleGroup` can be called
    with a positive integer instead of a group, and then returns
    information about the simple group(s) of this order. (This feature
    is currently undocumented.) For the argument 1, however, it ran
    into an infinite loop.

  - A lookup in an empty dictionary entered a break loop. Now returns
    `fail`. (Reported by Laurent Bartholdi)

  - The c++ keyword `and` can no longer be used as a macro parameter in
    the kernel. (Reported by Paul Smith)

  - The operation `KernelOfMultiplicativeGeneralMapping` has methods
    designed to handle maps between permutation groups in a two-step
    approach, but did not reliably trigger the second step. This has
    now been fixed, preventing a slow infinite loop repeating the first
    step. This was normally only seen as part of a larger calculation.

  - There were two methods for the operation `Intersection2` which have
    implicitly assumed that finiteness of a collection can always be
    decided. Now, these methods check for `IsFinite` and
    `CanComputeSize` prior to calling `IsFinite`.

  - Made error message in case of corrupted help book information
    (manual.six file) shorter and more informative. (Reported by
    Alexander Hulpke)

  - GAP cannot call methods with more than six arguments. Now the
    functions `NewOperation`, `DeclareOperation`, and `InstallMethod`
    signal an error if one attempts to declare an operation or to
    install a method with more than six arguments.

  - Up to now, `IsOne` had a special method for general mappings, which
    was much worse than the generic method; this special method has now
    been removed.

  - When printing elements of an algebraic extension parentheses around
    coefficients were missing. (Reported by Maxim Hendriks)

### New or improved functionality:

  - Make dynamic loading of modules possible on CYGWIN using a DLL based
    approach. Also move to using autoconf version 2.61.

  - One can now call `Basis`, `Iterator` etc. with the return value of
    the function `AlgebraicExtension`.

  - The function `FrobeniusCharacterValue` returned `fail` for results
    that require a finite field with more than 65536 elements.
    Meanwhile GAP can handle larger finite fields, so this restriction
    was removed. (It is still possible that `FrobeniusCharacterValue`
    returns `fail`.)

  - Methods for testing membership in general linear groups and special
    linear groups over the integers have been added.

  - Methods for `String` and `ViewString` for full row modules have been
    added. Further, a default method for `IsRowModule` has been added,
    which returns `false` for objects which are not free left modules.

  - A `ViewString` method for objects with name has been added.

  - The method for `View` for polynomial rings has been improved, and
    methods for `String` and `ViewString` for polynomial rings have
    been added.

  - `Binomial` now works with huge `n`.

  - The function `InducedClassFunctionsByFusionMap` is now documented.

  - The return values of the function `QuaternionAlgebra` now store that
    they are division rings (if optional parameters are given then of
    course ths depends on these parameters).


## GAP 4.4 Update 10 (October 2007)

### New or improved functionality:

  - Files in the `cnf` directory of the GAP distribution are now
    archived as binary files. Now GAP can be installed with UNIX or
    with WINDOWS style line breaks on any system and should work without
    problems.

  - Since large finite fields are available, some restrictions in the
    code for computing irreducible modules over finite fields are no
    longer necessary. (They had been introduced in order to give better
    error messages.)

  - Made PositionSublist faster in case the search string does not
    contain repetitive patterns.

  - The function `MakeImmutable` now returns its argument.

  - Dynamically loaded modules now work on Mac OS X. As a consequence,
    this allows to work with the Browse, EDIM and IO packages on Mac OS
    X.

  - Introduced `ViewObj` and `PrintObj` methods for algebraic number
    fields. Made them applicable to `AlgebraicExtension` by adding the
    property `IsNumberField` in the infinite field case.

  - The function `CharacterTableRegular` is documented now.

  - The function `ScalarProduct` now accepts also Brauer characters
    as arguments.

  - The function `QuaternionAlgebra` now accepts also a list of field
    elements instead of a field. Also, now the comparison of return
    values (w.r.t. equality, containment) yields `true` if the
    parameters coincide and the ground fields fit.

  - The function `RemoveCharacters` is now documented.

  - Lists in GAP sometimes occupy memory for possible additional
    entries. Now plain lists and strings read by GAP and the lists
    returned by `List` only occupy the memory they really need. For
    more details see the documentation of the new function
    `EmptyPlist`.

  - There are some new Conway polynomials in characteristic 2 and 3
    provided by Kate Minola.

  - A new operation `MemoryUsage` determines the memory usage in bytes
    of an object and all its subobjects. It does not consider families
    and types but handles arbitrary self-referential structures of
    objects.

### Fixed bugs which could produce wrong results:

  - When forming the semidirect product of a matrix group with a vector
    space over a non-prime field the embedding of the vector space gave
    a wrong result. (Reported by anvita21)

  - DefaultRing failed for constant polynomials over nonprime fields.
    (Reported by Stefan Kohl)

  - The method in ffeconway.gi that gets coefficients WRT to the
    canonical basis of the field from the representation is only correct
    if the basis is over the prime field. Added a TryNextMethod if this
    is not the case. (Reported by Alla Detinko)

  - Creating a large (\>2^16) field over a non-prime subfield went
    completely wrong. (Reported by Jack Schmidt, from Alla Detinko)

  - A method for Coefficients for Conway polynomial FFEs didn't check
    that the basis provided was the canonical basis of the RIGHT field.
    (Reported by Bettina Eick)

  - An elementary abelian series was calculated wrongly. (Reported by
    N. Sieben)

  - Orbits on sets of transformations failed.

  - Wrong methods for `GeneratorsOfRing` and `GeneratorsOfRingWithOne`
    have been removed. These methods were based on the assumption that
    one can obtain a set of ring generators by taking the union of a
    known set of field generators, the set of the inverses of these
    field generators and {1}.

  - The name of a group of order 117600 and degree 50 was incorrect in
    the Primitive Permutation Groups library. In particular, a group was
    wrongly labelled as PGL(2, 49).

  - There was a possible error in `SubgroupsSolvableGroup` when
    computing subgroups within a subgroup.

  - An error in 2-Cohomology computation for pc groups was fixed.

  - `IsConjugate` used normality in a wrong supergroup

### Fixed bugs which could lead to crashes:

  - GAP crashed when the `PATH` environment variable was not set.
    (Reported by Robert F. Morse)

  - GAP could crash when started with option `-x 1`. Now the number
    of columns is initialized with at least 2. (Reported by Robert F.
    Morse)

  - After loading a saved workspace GAP crashed when one tried to
    slice a compressed vector over a field with 2 \< q \<= 256 elements,
    which had already existed in the saved workspace. (Reported by
    Laurent Bartholdi)

  - `FFECONWAY.WriteOverSmallestCommonField` tripped up when the common
    field is smaller than the field over which some of the vector
    elements are written, because it did a test based on the degree of
    the element, not the field it is written over. (Reported by Thomas
    Breuer)

  - Fixed the following error: When an FFE in the Conway polynomial
    representation actually lied in a field that is handled in the
    internal representation (eg GF(3)) and you tried to write it over a
    bigger field that is ALSO handled internally (eg GF(9)) you got an
    element written over the larger field, but in the Conway polynomial
    representation, which is forbidden. (Reported by Jack Schmidt)

  - Attempting to compress a vector containing elements of a small
    finite field represented as elements of a bigger (external) field
    caused a segfault. (Reported by Edmund Robertson)

  - GAP crashed when `BlistList` was called with a range and a list
    containing large integers or non-integers. (Reported by Laurent
    Bartholdi)

  - GAP no longer crashes when `OnTuples` is called with a list that
    contains holes. (Reported by Thomas Breuer)

### Other fixed bugs:

  - `Socle` for the trivial group could produce an error message.

  - `DirectoryContents` ran into an error for immutable strings without
    trailing slash as argument. (Reported by Thomas Breuer)

  - The functions `IsInjective` and `IsSingleValued` did not work for
    general linear mappings with trivial (pre)image. (Reported by Alper
    Odabas)

  - Creating an enumerator for a prime field with more than 65536
    elements ran into an infinite recursion. (Reported by Akos Seress)

  - The performance of `List`, `Filtered`, `Number`, `ForAll` and
    `ForAny` if applied to non-internally represented lists was
    improved. Also the performance of iterators for lists was slightly
    improved.

  - Finite field elements now know that they can be sorted easily which
    improves performance in certain lookups.

  - A method for `IsSubset` was missing for the case that exactly one
    argument is an inhomogeneous list. (Reported by Laurent Bartholdi)

  - Long integers in expressions are now printed (was not yet
    implemented). (Reported by Thomas Breuer)

  - Fixed kernel function for printing records.

  - New C library interfaces (e.g., to ncurses in the **Browse** package)
    need some more memory to be allocated with `malloc`. The default
    value of GAP `-a` option is now `2m>`.

  - Avoid warnings about pointer types by newer gcc compilers.

  - `IsBound(l[pos])` was failing for a large integer pos only when coded
    (e.g. in a loop or function body).

  - `ZmodpZObj` is now a synonym for `ZmodnZObj` such that from now on
    such objects print in a way that can be read back into GAP.

  - The outdated note that binary streams are not yet implemented has
    been removed.


## GAP 4.4 Update 9 (November 2006)

### Fixed bugs which could produce wrong results:

  - The methods of `ReadByte` for reading from files or terminals
    returned wrong results for characters in the range `[128..255]`.
    (Reported by Yevgen Muntyan)

### Other fixed bugs:

  - A method for the operation `PseudoRandom` did not succeed.

  - A fix for `Orbits` with a set of points as a seed.

  - Added a generic method such that `Positions` works with all types of
    lists.

  - Fixed a problem in choosing the prime in the Dixon-Schneider
    algorithm. (Reported by Toshio Sumi)

### New or improved functionality:

  - `ReducedOrdinary` was used in the manual, but was not documented,
    being a synonym for the documented `ReducedCharacters`. Changed
    manual examples to use the latter form. (Reported by Vahid
    Dabbaghian)


## GAP 4.4 Update 8 (September 2006)

### New or improved functionality:

  - A function `Positions` with underlying operation `PositionsOp`, which
    returns the list of all positions at which a given object appears
    in a given list.

  - `LogFFE` now returns `fail` when the element is not a power of the
    base.

  - It is now allowed to continue long integers, strings or identifiers
    by ending a line with a backslash or with a backslash and carriage
    return character. So, files with GAP code and DOS/Windows-style
    line breaks are now valid input on all architectures.

  - The command line for starting the session and the system environment
    are now available in `GAPInfo.SystemCommandLine` and
    `GAPInfo.SystemEnvironment`.

  - Names of all bound global variables and all component names are
    available on GAP level.

  - Added a few new Conway polynomials computed by Kate Minola and John
    Bray.

  - There is a new concept of *random sources*, see `IsRandomSource`,
    which provides random number generators which are independent of
    each other. There is kernel code for the Mersenne twister random
    number generator (based on the code by Makoto Matsumoto available
    [here](http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html)). It
    provides fast 32-bit pseudorandom integers with a period of length
    2^19937-1 and a 623-dimensional equidistribution. The library
    methods for random elements of lists and for random (long) integers
    are using the Mersenne twister now.

  - In line editing mode (usual input mode without -n option) in lines
    starting with `gap> `, `> ` or `brk> ` this beginning part is
    immediately removed. This is a convenient feature that allows one
    to cut and paste input lines from other sessions or from manual
    examples into the current session.

### Fixed bugs which could produce wrong results:

  - The function `Decomposition` returned coefficient vectors also in
    certain situations where in fact no decomposition exists. This
    happened only if the matrix entered as the first argument contained
    irrational values and a row in the matrix entered as the second
    argument did not respect the algebraic conjugacy relations between
    the columns of the first argument. So there was no problem for the
    usual cases that the two matrices are integral or that they are
    lists of Brauer characters. (Reported by Jürgen Müller)

  - PC group homomorphisms can claim a wrong kernel after composition.
    (Reported by Serge Bouc)

  - The return value of `OctaveAlgebra` had an inconsistent defining
    structure constants table for the case of coefficients fields not
    containing the integer zero. (Reported by Gábor Nagy)

  - The manual guarantees that a conjugator automorphism has a
    conjugating element in the group if possible. This was not
    guaranteed.

  - `StabChain` for symmetric groups gave a wrong result if fixed points
    were prescribed for base.

  - Contrary to what is documented the function `POW_OBJ_INT` returned an
    immutable result for `POW_OBJ_INT(m,1)` for a mutable object `m`.
    This is triggered by the code `m^1`.

  - `PseudoRandom` for a group had a problem if the group had lots of
    equal generators. The produced elements were extremely poorly
    distributed in that case. This is now fixed for the case that
    elements of the group can easily be sorted.

  - Fixed the bug that the type of a boolean list was computed wrongly:
    The type previously had `IS_PLIST_REP` instead of `IS_BLIST_REP` in
    its filter list.

  - `Orbits` did not respect a special `PositionCanonical` method for
    right transversals. (Reported by Steve Costenoble)

  - Wrong results for `GcdInt` for some arguments on 64 bit systems only.
    (Reported by Robert Morse)

  - When prescribing a subgroup to be included, the low index algorithm
    for fp groups sometimes returned subgroups which are in fact
    conjugate. (No subgroups are missing.) (Reported by Ignaz Soroko)

### Fixed bugs which could lead to crashes:

  - The command line option `-x` allowed arguments \> 256 which can then
    result in internal buffers overflowing. Now bigger numbers in the
    argument are equivalent to `-x 256`. (Reported by Michael Hartley)

### Other fixed bugs:

  - Two special methods for the operation `CompositionMapping2` were not
    correct, such that composing (and multiplying) certain group
    homomorphisms did not work. (Reported by Peter Mayr)

  - In the definition of `FrobeniusCharacterValue`, it had been stated
    erroneously that the value must lie in the field of p^n-th roots of
    unity; the correct condition is that the value must lie in the
    field of (p^n-1)-th roots of unity. (Reported by Jack Schmidt)

  - The function `DirectProduct` failed when one of the factors was known
    to be infinite.

  - For a linear action homomorphism `PreImageElm` was very slow because
    there was no good method to check for injectivity, which is needed
    for nearly all good methods for `PreImageElm`. This change adds
    such a new method for `IsInjective`. (Reported by Akos Seress)

  - Rare errors in the complement routine for permutation groups.

  - Blocks code now uses jellyfish-style random elements to avoid bad
    Schreier trees.

  - A method for `IsPolycyclicGroup` has been added. Such a method was
    missing so far.

  - Corrected `EpimorphismSchurCover` to handle the trivial group
    correctly. Added new methods that follow immediately from computing
    the Schur Cover of a group. The attribute `Epicentre`, the
    operations `NonabelianExteriorSquare` and
    `EpimorphismNonabelianExteriorSquare`, and the property
    `IsCentralFactor` are added to the library with documentation and
    references.

  - Display the correct expression in a call stack trace if an operation
    was called somewhere up due to the evaluation of a unary or binary
    operation.

  - Made `StripMemory` an operation rather than a global function. Added
    `ForgetMemory` operation.

  - Adjust things slightly to make later conversion to new
    vectors/matrices easier. Nothing of this should be visible.

  - Corrected some details in the documentation of the GAP language.
    (Reported by Alexander Konovalov)

  - Now `PositionSorted` is much faster on long mutable plain lists. (The
    former operation is substituted by a function and a new operation
    `PositionSortedOp`.) (Reported by Silviu Radu)

  - Now it is possible to switch repeated warnings off when working with
    iterative polynomial rings.


## GAP 4.4 Update 7 (March 2006)

### New or improved functionality:

  - The `Display` functionality for character tables has been extended by
    addition of an option to show power maps and centralizer orders in
    a format similar to that used in the ATLAS. Furthermore the options
    handling is now hierarchical, in order to admit more flexible
    overloading.

  - For the function `LowIndexSubgroupsFpGroup`, there is now an iterator
    variant `LowIndexSubgroupsFpGroupIterator`. (Suggested (and based
    on code contributed) by Michael Hartley)

  - Semigroup functionality in GAP has been improved and extended.
    Green's relations are now stored differently, making the system
    more amenable to new methods for computing these relations in
    special cases. It is now possible to calculate Green's classes etc.
    without computing the entire semigroup or necessarily loading the
    package **MONOID**. Furthermore, the Froidure-Pin algorithm has now
    been implemented in GAP.

  - Functionality for creating free products of any list of groups for
    which a finite presentation can be determined had been added. This
    function returns a finitely presented group. This functionality
    includes the `Embedding` operation. As an application of this new
    code a specialized direct product operation has been added for
    finitely presented groups which returns a finitely presented group.
    This application includes `Embedding` and `Projection`
    functionality.

  - Some new Straight Line Program (SLP) functionality has been added.
    The new functions take given SLPs and create new ones by
    restricting to a subset of the results, or to an intermediate
    result or by calculating the product of the results of two SLPs.

  - New code has been added to allow group elements with memory; that is,
    they store automatically how they were derived from some given set
    of generators. Note that there is not yet documentation for this
    functionality, but some packages already use it.

  - New code has been added to handle matrices and vectors in such a way
    that they do not change their representation in a generic manner.

  - The `Irr` method for p-solvable p-modular Brauer tables now keeps the
    order of the irreducibles in the ordinary table.

  - GAP can now handle any finite field for which the Conway polynomial
    is known or can be computed.

  - New Conway polynomials provided by John Bray and Kate Minola have
    been added.

  - The `ReadTest` methods for strings (filenames) and streams now
    automatically set the screen width (see `SizeScreen`) to 80 before
    the tests, and reset it afterwards.

  - Now a few more checks are done during the `configure` phase of
    compiling for future use of some I/O functions of the C-library in
    a package. Also the path to the GAP binaries for the GAP compiler
    is now handled via autoconf. Finally, now `autoconf` version 2.59
    is used.

### Fixed bugs which could produce wrong results:

  - Some technical errors in the functions for compressed vectors and
    matrices which could lead to corruption of internal data structures
    and so to crashes or conceivably to wrong results. (Reported by
    Roman Schmied)

  - A potential problem in the generic method for the undocumented
    operation `DirectFactorsOfGroup`: It was silently assumed that
    `NormalSubgroups` delivers the trivial
    subgroup as first and the whole group as last entry of the resulting
    list.

  - The code for sublists of compressed vectors created by `vec{range}`
    may write one byte beyond the space allocated for the new vector,
    overwriting part of the next object in the workspace. Thanks to Jack
    Schmidt for narrowing down the problem.

  - Given a class function object of value zero, an `Arithmetic Operations for Class Functions`
     method for a class function erroneously did not
    return `fail`. (Reported by Jack Schmidt)

  - The `Arithmetic Operations for Class Functions` method for a class
    function erroneously returned a finite number if one of the values
    was nonreal, not a cyclotomic integer, and had norm 1.

  - Two missing perfect groups were added, and the permutation degree
    lowered on the perfect groups with the largest degrees. (Reported
    by Jack Schmidt)

  - When a character table was displayed with `Display`, the centralizer
    order displayed for the first class shown was not correct if it did
    not involve all prime divisors of the group. (Reported by Jack
    Schmidt)

  - The first argument of the function `VectorSpace` must be a field.
    This is checked from now on. (Reported by Laurent Bartholdi)

  - Up to now, it was possible to create a group object from a semigroup
    of cyclotomics using `AsGroup`, although groups of cyclotomics are
    not admissible. (Reported by Alexander Konovalov)

  - The documentation of `CharacteristicPolynomial(F,mat)` was ambiguous
    if `FieldOfMatrix(mat) <= F < DefaultFieldOfMatrix(mat)`. In
    particular, the result was representation dependent. This was fixed
    by introducing a second field which specifies the vector space
    which mat acts upon. (Reported by Jack Schmidt)

  - `AssociatedReesMatrixSemigroupOfDClass` produced an incorrect
    sandwich matrix for the semigroup created. This matrix is an
    attribute set when creating the Rees matrix semigroup but is not
    used for creating the semigroup. The incorrect result was returned
    when `SandwichMatrix` was called. (Reported by Nelson Silva and
    Joao Araujo)

  - The literal `"compiled"` was given an incorrect length. The kernel
    was then unable to find compiled library code as the search path was
    incorrect. Also the documentation example had an error in the path
    used to invoke the `gac` compiler.

  - The twisting group in a generic wreath product might have had
    intransitive action. (Reported by Laurent Bartholdi)

  - There was an arithmetic bug in the polynomial reduction code.

### Fixed bugs which could lead to crashes:

  - Bug 1 in the list of fixed bugs which could lead to wrong results
    could also potentially lead to crashes.

### Other fixed bugs:

  - The matrices of invariant forms stored as values of the attributes
    `InvariantBilinearForm`, `InvariantQuadraticForm`, and
    `InvariantSesquilinearForm`, for matrix groups over finite fields,
    are now in the (compressed) format returned by `ImmutableMatrix`.

  - `String` now returns an immutable string, by making a copy before
    changing the argument.

  - `permutation^0` and `permutation^1` were not handled with special
    code in the kernel, hence were very slow for big permutations.
    (Reported by Max Neunhöffer)

  - Added code to cache the induced pcgs for an arbitrary parent pcgs.
    (This code was formerly part of the **CRISP** package.)

  - This fix consists of numerous changes to improve support for direct
    products, including: - new methods for
    `PcgsElementaryAbelianSeries`, `PcgsChiefSeries`,
    `ExponentsOfPcElement`, `DepthOfPcElement` for direct products -
    fixed `EnumeratorOfPcgs` to test for membership first - new methods
    for membership test in groups which have an induced pcgs - added
    `GroupOfPcgs` attribute to pcgs in various methods - fixed
    declarations of `PcgsElementaryAbelianSeries`, `PcgsChiefSeries`
    (the declared argument was a pcgs, not a group) (Reported by Roman
    Schmied)

  - Corrected a term ordering problem encountered by the basis
    construction code for finite dimensional vector spaces of
    multivariate rational functions. (Reported by Jan Draisma)

  - When the factor of a finite dimensional group ring by an ideal was
    formed, a method intended for free algebras modulo relations was
    used, and the returned factor algebra could be used for (almost)
    nothing. (Reported by Heiko Dietrich)

  - Up to now, `PowerMap` ran into an error when one asked for the n-th
    power map where n was not a small integer. This happened in some
    GAP library functions if the exponent of the character table in
    question was not a small integer.

  - Up to now, the test whether a finite field element was contained in a
    group of finite field elements ran into an error if the element was
    not in the field generated by the group elements. (Reported by
    Heiko Dietrich)

  - Conjugacy classes of natural (special) linear groups are now always
    returned with trivial class first.

  - Up to now, it could happen that `CheckFixedPoints` reduced an entry
    in its second argument to a list containing only one integer but
    did not replace the list by that integer; according to the
    conventions, this replacement should be done.

  - The functions `PrintTo` and `AppendTo` did not work correctly for
    streams. (Reported by Marco Costantini)

  - The function `Basis` did not return a value when it was called with
    the argument `Rationals`. (Reported by Klaus Lux)

  - For certain matrix groups, the function `StructureDescription` raised
    an error message. The reason for this was that a trivial method for
    `IsGeneralLinearGroup` for matrix groups in `lib/grpmat.gi` which
    is ranked higher than the nontrivial method for generic groups in
    `lib/grpnames.gi` called the operation `IsNaturalGL`, for which
    there was no nontrivial method available. (Reported by Nilo de
    Roock)

  - Action on sets of length 1 was not correctly handled. (Reported by
    Mathieu Dutour)

  - Now `WriteByte` admits writing zero characters to all streams.
    (Reported by Marco Costantini)

  - The conjugacy test for subgroups tests for elementary abelian regular
    normal subgroup (EARNS) conjugacy. The fix will catch this in the
    case that the second group has no EARNS. (Reported by Andrew
    Johnson)

  - So far, the UNIX installation didn't result in a correct gap.sh if
    the installation path contained space characters. Now it should
    handle this case correctly, as well as other unusual characters in
    path names (except for double quotes).


## GAP 4.4 Update 6 (September 2005)

Attribution of bugfixes and improved functionalities to those who
reported or provided these, respectively, is still fairly incomplete and
inconsistent with this update. We apologise for this fact and will
discuss until the next update how to improve this feature.

### Fixed bugs which could produce wrong results:

  - The perfect group library does not contain any information on the
    trivial group, so the trivial group must be handled specially.
    `PerfectGroup` and `NrPerfectLibraryGroups` were changed to
    indicate that the trivial group is not part of the library.

  - The descriptions of `PerfectGroup(734832,3)` and
    `PerfectGroup(864000,3)` were corrected in the library of perfect
    groups.

  - The functions `EpimorphismSchurCover` and
    `AbelianInvariantsMultiplier` may have produced wrong results
    without warning (Reported by Colin Ingalls). These problems are
    fixed. However, the methods currently used can be expected to be
    slower than the ones used before; we hope to fix this in the next
    version of GAP.

  - `DerivedSubgroup` and `CommutatorSubgroup` for permutation groups
    sometimes returned groups with an incorrect stabilizer chain due to
    a missing verification step after a random Schreier Sims.

  - `NaturalHomomorphismByNormalSubgroup` for FpGroups did
    unnecessary rewrites.

  - The alternating group A_3 incorrectly claimed to be not simple.

  - `ExponentSyllable` for straight line program elements gave a wrong
    result.

  - `PrimePGroup` is defined to return `fail` for trivial groups, but if
    the group was constructed as a factor or subgroup of a known
    p-group, the value of p was retained.

  - The functions `TestPackageAvailability` and `LoadPackage` did not
    work correctly when one asked for a particular version of the
    package, via a version number starting with the character `=`, in
    the sense that a version with a larger version number was loaded if
    it was available. (Reported by Burkhard Höfling)

  - The generator names constructed by `AlgebraByStructureConstants` were
    nonsense.

  - The undocumented function (but recently advertised on gap-dev)
    `COPY_LIST_ENTRIES` did not handle overlapping source and
    destination areas correctly in some cases.

  - The elements in a free magma ring have the filter
    `IsAssociativeElement` set whenever the elements in the underlying
    magma and in the coefficients ring have this filter set. (Reported
    by Randy Cone)

  - The function `InstallValue` must not be used for objects in the
    filter `IsFamily` because these objects are compared via
    `IsIdenticalObj`. (Reported by Max Neunhöffer)

### Fixed bugs which could lead to crashes:

  - Problem in composition series for permutation groups for
    non-Frobenius groups with regular point stabilizer.

  - After lots of computations with compressed GF(2) vectors GAP
    occasionally crashed. The reason were three missing `CHANGED_BAG`s
    in `SemiEchelonPListGF2Vecs`. They were missing, because a garbage
    collection could be triggered during the computation such that newly
    created bags could become "old". It is not possible to provide test
    code because the error condition cannot easily be reproduced.
    (Reported by Klaus Lux)

  - Minor bug that crashed GAP: The type of `IMPLICATIONS` could not
    be determined in a fresh session. (Reported by Marco Costantini)

  - `Assert` caused an infinite loop if called as
    the first line of a function called from another function.

### Other fixed bugs:

  - Wrong choice of prime in Dixon-Schneider if prime is bigger than
    group order (if group has large exponent).

  - Groebner basis code ran into problems when comparing monomial
    orderings.

  - When testing for conjugacy of a primitive group to an imprimitive
    group,GAP runs into an error in EARNS calculation. (Reported
    by John Jones)

  - The centre of a magma is commonly defined to be the set of
    elements that commute and associate with all elements. The
    previous definition left out "associate" and caused problems
    with extending the functionality to nonassociative loops.
    (Reported by Petr Vojtechovsky)

  - New kernel methods for taking the intersection and difference
    between sets of substantially different sizes give a big
    performance increase.

  - The commands `IsNaturalSymmetricGroup` and
    `IsNaturalAlternatingGroup` are faster and should run much less
    often into inefficient tests.

  - The perfect group library, see `Finite Perfect Groups`, is split into
    several files which are loaded and unloaded to keep memory usage
    down. The global variable `PERFSELECT` is a blist which indicates
    which orders are currently loaded. An off-by-one error wrongly
    added the last order of the previous file into the list of valid
    orders when a new file was loaded. A subsequent access to this
    order raises an error.

  - Up to now, the method installed for testing the membership of
    rationals in the field of rationals via `IsRat` was not called;
    instead a more general method was used that called `Conductor` and
    thus was much slower. Now the special method has been ranked up by
    changing the requirements in the method installation.

  - Fixed a bug in `APPEND_VEC8BIT`, which was triggered in the following
    situation: Let `e` be the number of field elements stored in one
    byte. If a compressed 8bit-vector `v` had length not divisible by
    `e` and another compressed 8-bit vector `w` was appended, such that
    the sum of the lengths became divisible by `e`, then one 0 byte too
    much was written, which destroyed the `TNUM` of the next GAP object
    in memory. (Reported by Klaus Lux)

  - `PermutationCycle` returned `fail` if the cycle was not a contiguous
    subset of the specified domain. (Reported by Luc Teirlinck)

  - Now `Inverse` correctly returns `fail` for zeros in finite fields
    (and does no longer enter a break loop).

  - Up to now, `CharacterDegrees` ignored the attribute `Irr` if the
    argument was a group that knew that it was solvable.

  - The function `Debug` now prints a meaningful message if the user
    tries to debug an operation. Also, the help file for `vi` is now
    available in the case of several GAP root directories.

  - It is no longer possible to create corrupt objects via ranges of
    length \>2^28, resp. \>2^60 (depending on the architecture). The
    limitation concerning the arguments of ranges is documented.
    (Reported by Stefan Kohl)

  - Now `IsElementaryAbelian` and
    `ClassPositionsOfMinimalNormalSubgroups` are available for ordinary
    character tables. Now the operation `CharacterTableIsoclinic` is an
    attribute, and there is another new attribute
    `SourceOfIsoclinicTable` that points back to the original table;
    this is used for computing the Brauer tables of those tables in the
    character table library that are computed using
    `CharacterTableIsoclinic`. Now `ClassPositionsOfDerivedSubgroup`
    avoids calling `Irr`, since `LinearCharacters` is sufficient. Now
    `ClassPositionsOfElementaryAbelianSeries` works also for the table
    of the trivial group. Restrictions of character objects know that
    they are characters.

    A few formulations in the documentation concerning character tables
        have been improved slightly.

  - Up to now, `IsPGroup` has rarely been set. Now many basic operations
    such as `SylowSubgroup` set this attribute on the returned result.

  - Computing an enumerator for a semigroup required too much time
    because it used all elements instead of the given generators.
    (Reported by Manuel Delgado)

  - Avoid potential error message when working with automorphism groups.

  - Fixed wrong page references in manual indices.

  - Make `MutableCopyMat` an operation and install the former function
    which does call `List` with `ShallowCopy` the default method for
    lists. Also use this in a few appropriate places.

  - An old DEC compiler doesn't like C preprocessor directives that are
    preceded by whitespace. Removed such whitespace. (Reported by Chris
    Wensley)

### New or improved functionality:

  - The primitive groups library has been extended to degree 2499.

  - New operation `Remove` and extended functionality of `Add` with an
    optional argument giving the position of the insertion. They are
    based on an efficient kernel function `COPY_LIST_ENTRIES`.

  - Added fast kernel implementation of Tarjan's algorithm for strongly
    connected components of a directed graph.

  - Now `IsProbablyPrimeInt` can be used with larger numbers. (Made
    internal function `TraceModQF` non-recursive.)

  - A new operation `PadicValuation` and a corresponding method for
    rationals.

  - A new operation `PartialFactorization` has been added, and a
    corresponding method for integers has been installed. This method
    allows one to specify the amount of work to be spent on looking for
    factors.

  - The generators of full s. c. algebras can now be accessed with the
    dot operator. (Reported by Marcus Bishop)

  - New Conway polynomials computed by Kate Minola, John Bray, Richard
    Parker.

  - A new attribute `EpimorphismFromFreeGroup`. The code has been written
    by Alexander Hulpke.

  - The functions `Lambda`, `Phi`, `Sigma`, and `Tau` have been turned
    into operations, to admit the installation of methods for arguments
    other than integers.

  - Up to now, one could assign only lists with `InstallFlushableValue`.
    Now also records are admitted.

  - `InstallMethod` now admits entering a list of strings instead of a
    list of required filters. Each such string must evaluate to a
    filter when used as the argument of `EvalString`. The advantage of
    this variant is that these strings are used to compose an info
    string (which is shown by `ApplicableMethod`) that reflects exactly
    the required filters.

  - In test files that are read with `ReadTest`, the assertion level is
    set to 2 between `START_TEST` and `STOP_TEST`. This may result in
    runtimes for the tests that are substantially longer than the usual
    runtimes with default assertion level 0. In particular this is the
    reason why some of the standard test files require more time in GAP
    4.4.6 than in GAP 4.4.5.

  - Some very basic functionality for floats.


## GAP 4.4 Update 5 (May 2005)

### Fixed bugs which could produce wrong results:

  - `GroupWithGenerators` returned a meaningless group object instead
    of signaling an error when it was called with an empty list of
    generators.

  - When computing preimages under an embedding into a direct product
    of permutation groups, if the element was not in the image of
    the embedding then a permutation had been returned instead of
    `fail`.

  - Two problems with `PowerMod` for polynomials. (Reported by Jack
    Schmidt)

  - Some methods for computing the sum of ideals returned the first
    summand instead of the sum. (Reported by Alexander Konovalov)

  - Wrong result in `Intersection` for pc groups.

  - The function `CompareVersionNumbers` erroneously ignored leading
    non-digit characters.

    A new feature in the corrected version is an optional third argument
    `"equal"`, which causes the function to return `true` only if the
    first two arguments describe equal version numbers; documentation is
    available in the ext-manual. This new feature is used in
    `LoadPackage`, now one can require a
    specific version of a package.

    The library code still contained parts of the handling of completion
    files for packages, which does not work and therefore had already
    been removed from the documentation. This code has now been removed.

    Now a new component `PreloadFile` is supported in `PackageInfo.g`
    files; if it is bound then the file in question is read
    immediately before the package or its documentation is
    loaded.

  - The result of `String` for strings not in `IsStringRep` that
    occur as list entries or record components was erroneously
    missing the double quotes around the strings.

  - A bug which caused `InducedPcgs` to return a pcgs which is not
    induced wrt. the parent pcgs of `pcgs`. This may cause
    unpredictable behaviour, e. g. when `SiftedPcElement` is used
    subsequently. (Reported by Alexander Konovalov)

  - Fixed a bug in `SmallGroupsInformation(512)`.

  - `PowerModCoeffs` with exponent 1 for compressed vectors did not
    reduce (a copy of) the input vector before returning it.
    (Reported by Frank Lübeck)

  - Sorting a mutable non-plain list (e.g., a compressed matrix over
    fields of order \< 257) could potentially destroy that object.
    (Reported by Alexander Hulpke)

  - Under rare circumstances computing the closure of a permutation
    group by a normalizing element could produce a corrupted
    stabilizer chain. (The underlying algorithm uses random
    elements, probability of failure was below 1 percent).
    (Reported by Thomas Breuer)

### Fixed bugs which could lead to crashes:

  - Some code and comments in the GAP kernel assumed that there is
    no garbage collection during the core printing function `Pr`, which
    is not correct. This could cause GAP in rare cases to crash
    during printing permutations, cyclotomics or strings with zero
    bytes. (Reported by Warwick Harvey)

### Other fixed bugs:

  - A rare problem with the choice of prime in the Dixon-Schneider
    algorithm for computing the character table of a group. (Reported
    by Jack Schmidt)

  - `DirectProduct` for trivial permutation groups returned a strange
    object.

  - A problem with `PolynomialReduction` running into an infinite loop.

  - Adding linear mappings with different image domains was not possible.
    (Reported by Pasha Zusmanovich)

  - Multiplying group ring elements with rationals was not possible.
    (Reported by Laurent Bartholdi)

  - `Random` now works for finite fields of size larger than 2^28.
    (Reported by Jack Schmidt)

  - Univariate polynomial creators did modify the coefficient list
    passed. (Reported by Jürgen Müller)

  - Fixed `IntHexString` to accept arguments not in `IsStringRep`; the
    argument is now first converted if necessary. (Reported by Kenn
    Heinrich)

  - The library code for stabilizer chains contained quite some explicit
    references to the identity `()`. This is unfortunate if one works
    with permutation groups, the elements of which are not plain
    permutations but objects which carry additional information like a
    memory, how they were obtained from the group generators. For such
    cases it is much cleaner to use the `One(...)` operation instead of
    `()`, such that the library code can be used for a richer class of
    group objects. This fix contains only rather trivial changes `()`
    to `One(...)` which were carefully checked by me. The tests for
    permutation groups all run without a problem. However, it is
    relatively difficult to provide test code for this particular
    change, since the "improvement" only shows up when one generates
    new group objects. This is for example done in the package
    **recog** which is in preparation. (Reported by Akos Seress and Max
    Neunhöffer)

  - Using `{}` to select elements of a known inhomogenous dense list
    produced a list that might falsely claim to be known inhomogenous,
    which could lead to a segfault if the list typing code tried to
    mark it homogenous, since the code intended to catch such errors
    also had a bug. (Reported by Steve Linton)

  - The record for the generic iterator construction of subspaces domains
    of non-row spaces was not complete.

  - When a workspace has been created without packages(`-A` option) and
    is loaded into a GAP session without packages (same option) then an
    error message is printed.

  - So far the functions `IsPrimeInt` and `IsProbablyPrimeInt` are
    essentially the same except that `IsPrimeInt` issues an additional
    warning when (non-proven) probable primes are considered as primes.

    These warnings now print the probable primes in question as well; if a
    probable prime is used several times then the warning is also printed
    several times; there is no longer a warning for some known large primes;
    the warnings can be switched off. See `IsPrimeInt` for more details.

    If we get a reasonable primality test in GAP we will change the
    definition of `IsPrimeInt` to do a proper test.

  - Corrected some names of primitive groups in degree 26. (Reported by
    Robert F. Bailey)

### New or improved functionality:

  - Several changes for `ConwayPolynomial`:

      - many new pre-computed polynomials

      - put data in several separate files (only read when needed)

      - added info on origins of pre-computed polynomials

      - improved performance of `ConwayPolynomial` and
      `IsPrimitivePolynomial` for p < 256

      - improved documentation of `ConwayPolynomial`

      - added and documented new functions `IsCheapConwayPolynomial` and
        `RandomPrimitivePolynomial`

  - Added method for `NormalBase` for extensions
    of finite fields.

  - Added more help viewers for the HTML version of the documentation
    (firefox, mozilla, konqueror, w3m, safari).

  - New function `ColorPrompt`. (Users of
    former versions of a `colorprompt.g` file: Now you just need a
    `ColorPrompt(true);` in your `.gaprc` file.)

  - Specialised kernel functions to support **GUAVA** 2.0. GAP will
    only load **GUAVA** in version at least 2.002 after this update.

  - Now there is a kernel function `CYC_LIST` for converting a list of
    rationals into a cyclotomic, without arithmetics overhead.

  - New functions `ContinuedFractionExpansionOfRoot` and
    `ContinuedFractionApproximationOfRoot` for computing continued
    fraction expansions and continued fraction approximations of real
    roots of polynomials with integer coefficients.

  - A method for computing structure descriptions for finite groups,
    available via `StructureDescription`.

  - This change contains the new, extended version of the
    **SmallGroups** package. For example, the groups of orders p^4, p^5,
    p^6 for arbitrary primes p, the groups of square-free order and the
    groups of cube-free order at most 50000 are included now. For more
    detailed information see the announcement of the extended package.

  - The function `ShowPackageVariables` gives an overview of the global
    variables in a package. It is thought as a utility for package
    authors and referees. (It uses the new function
    `IsDocumentedVariable`.)

  - The mechanisms for testing GAP has been improved:

      - The information whether a test file belongs to the list in
        `tst/testall.g` is now stored in the test file itself.

      - Some targets for testing have been added to the `Makefile` in
        the GAP root directory, the output of the tests goes to the
        new directory `dev/log`.

      - Utility functions for testing are in the new file
        `tst/testutil.g`. Now the loops over (some or all) files
        `tst/*.tst` can be performed with a function call, and the file
        `tst/testall.g` can be created automatically; the file
        `tst/testfull.g` is now obsolete. The remormalization of the
        scaling factors can now be done using a GAP function, so the
        file `tst/renorm.g` is obsolete.

      - Now the functions `START_TEST` and `STOP_TEST` use components in
        `GAPInfo` instead of own globals, and the random number
        generator is always reset in `START_TEST`.

      - `GAPInfo.SystemInformation` now takes two arguments, now one can
        use it easier in the tests.

  - `MultiplicationTable` is now an
    attribute, and the construction of a magma, monoid, etc. from
    multiplication tables has been unified.


## GAP 4.4 Bugfix 4 (December 2004)

### Fixed bugs which could produce wrong results:

  - An error in the `Order` method for matrices over cyclotomic fields
    which caused this method to return `infinity` for matrices of finite
    order in certain cases.

  - Representations computed by `IrreducibleRepresentations` in
    characteristic 0 erraneously claimed to be faithful.

  - A primitive representation of degree 574 for PSL(2,41) has been
    missing in the classification on which the GAP library was
    built.

  - A bug in `Append` for compressed vectors over GF(2): if the length
    of the result is 1 mod 32 (or 64) the last entry was forgotten to
    copy.

  - A problem with the Ree group Ree(3) of size 1512 claiming to be
    simple.

  - An error in the membership test for groups GU(n,q) and SU(n,q) for
    non-prime q.

  - An error in the kernel code for ranges which caused e.g. `-1 in
    [1..2]` to return `true`.

  - An error recording boolean lists in saved workspaces.

  - A problem in the selection function for primitive and transitive
    groups if no degree is given.

  - `ReducedConfluentRewritingSystem` returning a cached result that
    might not conform to the ordering specified.

### Other fixed bugs:

  - A problem with the function `SuggestUpdates` to check for the most
    recent version of packages available.

  - A problem that caused `MatrixOfAction` to produce an error when the
    algebra module was constructed as a direct sum.

  - Problems with computing n-th power maps of character tables, where n
    is negative and the table does not yet store its irreducible
    characters.

  - Element conjugacy in large-base permutation groups sometimes was
    unnecessarily inefficient.

  - A missing method for getting the letter representation of an
    associate word in straight line program representation.

  - A problem with the construction of vector space bases where the
    given list of basis vectors is itself an object that was returned by
    `Basis`.

  - A problem of `AbelianInvariantsMultiplier` insisting that a result
    of `IsomorphismFpGroup` is known to be surjective.

  - An error in the routine for `Resultant` if one of the polynomials
    has degree zero.


## GAP 4.4 Bugfix 3 (May 2004)

### Fixed bugs which could produce wrong results:

  - Incorrect setting of system variables (e.g., home directory and
    command line options) after loading a workspace.

  - Wrong handling of integer literals within functions or loops on
    64-bit architectures (only integers in the range from 2^28 to 2^60).

### Fixed bugs which could lead to crashes:

  - A problem in the installation of the multiplication routine for
    matrices that claimed to be applicable for more general list
    multiplications.

  - A problem when computing weight distributions of codes with weights
    > 2^28.

### Other fixed bugs:

  - Problems with the online help with some manual sections.

  - Problems of the online help on Windows systems.

  - A problem in `GQuotients` when mapping from a finitely presented
    group which has a free direct factor.

  - A bug in the function `DisplayRevision`.

  - The trivial finitely presented group on no generators was not
    recognized as finitely presented.

  - A problem with `Process`.

  - A problem when intersecting subgroups of finitely presented groups
    that are represented in "quotient representation" with the quotient
    not apermutation group.

  - A bug in the generic `Intersection2` method for vector spaces, in
    the case that both spaces are trivial.

  - Enable ReeGroup(q) for q = 3.


## GAP 4.4 Bugfix 2 (April 2004)

### Fixed bugs which could lead to crashes:

  - A crash when incorrect types of arguments are passed to
    `FileString`.

### Other fixed bugs:

  - A bug in `DerivedSubgroupTom` and `DerivedSubgroupsTom`.

  - An error in the inversion of certain `ZmodnZObj` elements.

  - A wrong display string of the numerator in rational functions
    returned by `MolienSeriesWithGivenDenominator` (in the case that the
    constant term of this numerator is zero).


## Changes between GAP 4.3 and GAP 4.4

This chapter contains an overview of most important changes introduced
in GAP 4.4. It also contains information about subsequent update
releases of GAP 4.4.

### Potentially Incompatible Changes

  - The mechanism for the loading of Packages has changed to allow
    easier updates independent of main GAP releases. Packages
    require a file `PackageInfo.g` now. The new `PackageInfo.g`
    files are available for all packages with the new version of
    GAP.

  - `IsSimpleGroup` returns false now for the trivial group.

  - `PrimeBlocks`: The output format has changed.

  - Division rings (see `IsDivisionRing`) are now implemented as
    `IsRingWithOne`.

  - `DirectSumOfAlgebras`: p-th power maps are compatible with the
    input now.

  - The print order for polynomials has been changed.

These changes are, in some respects, departures from our policy of
maintaining upward compatibility of documented functions between
releases. In the first case, we felt that the old behavior was
sufficiently inconsistent, illogical, and impossible to document that we
had no alternative but to change it. In the case of the package
interface, the change was necessary to introduce new functionality. The
planned and phased removal of a few unnecessary functions or synonyms is
needed to avoid becoming buried in "legacy" interfaces, but we remain
committed to our policy of maintaining upward compatibility whenever
sensibly possible.

  - Groebner Bases:

    Buchberger's algorithm to compute Groebner Bases has been
    implemented in GAP. (A. Hulpke)

  - For large scale Groebner Basis computations there also is an
    interface to the Singular system available in the
    [**Singular**](https://www.gap-system.org/Packages/singular.html)
    package. (M. Costantini and W. de Graaf)

  - New methods for factorizing polynomials over algebraic extensions of
    the rationals have been implemented in GAP. (A. Hulpke)

  - For more functionality to compute with algebraic number fields there
    is an interface to the Kant system available in the
    [**Alnuth**](https://www.gap-system.org/Packages/alnuth.html)
    package. (B. Assmann and B. Eick)

  - A new functionality to compute the minimal normal subgroups of a
    finite group, as well as its socle, has been installed. (B. Höfling)

  - A fast method for recognizing whether a permutation group is
    symmetric or alternating is available now (A. Seress)

  - A method for computing the Galois group of a rational polynomial is
    available again. (A. Hulpke)

  - The algorithm for `BrauerCharacterValue` has been extended to the
    case where the splitting field is not supported in GAP. (T. Breuer)

  - Brauer tables of direct products can now be constructed from the
    known Brauer tables of the direct factors. (T. Breuer)

  - Basic support for vector spaces of rational functions and of uea
    elements is available now in GAP. (T. Breuer and W. de Graaf)

  - Various new functions for computations with integer matrices are
    available, such as methods for computing normal forms of integer
    matrices as well as nullspaces or solutions systems of equations.
    (W. Nickel and F. Gähler)

### New Packages

The following new Packages have been accepted.

  - [**Alnuth**: Algebraic Number Theory and an interface to the Kant
    system.](https://www.gap-system.org/Packages/alnuth.html) By B.
    Assmann and B. Eick.

  - [**LAGUNA**: Computing with Lie Algebras and Units of Group
    Algebras.](https://www.gap-system.org/Packages/laguna.html) By V.
    Bovdi, A. Konovalov, R. Rossmanith, C. Schneider.

  - [**NQ**: The ANU Nilpotent Quotient
    Algorithm.](https://www.gap-system.org/Packages/nq.html) By W.
    Nickel.

  - [**KBMAG**: Knuth-Bendix for Monoids and
    Groups.](https://www.gap-system.org/Packages/kbmag.html) By D. Holt.

  - [**Polycyclic**: Computation with polycyclic
    groups.](https://www.gap-system.org/Packages/polycyclic.html) By B.
    Eick and W. Nickel.

  - [**QuaGroup**: Computing with Quantized Enveloping
    Algebras.](https://www.gap-system.org/Packages/quagroup.html) By W.
    de Graaf.

### Performance Enhancements

  - The computation of irreducible representations and irreducible
    characters using the Baum-Clausen algorithm and the
    implementation of the Dixon-Schneider algorithm have been
    speeded up.

  - The algorithm for `PossibleClassFusions` has been changed: the
    efficiency is improved and a new criterion is used. The
    algorithm for `PossibleFusionsCharTableTom` has been speeded
    up. The method for `PrimeBlocks` has been improved following a
    suggestion of H. Pahlings.

  - New improved methods for normalizer and subgroup conjugation in
    S_n have been installed and new improved methods for
    `IsNaturalSymmetricGroup` and `IsNaturalAlternatingGroup` have
    been implemented. These improve the available methods when
    groups of large degrees are given.

  - The partition split method used in the permutation backtrack is
    now in the kernel. Transversal computations in large
    permutation groups are improved. Homomorphisms from free groups
    into permutation groups now give substantially shorter words
    for preimages.

  - The membership test in `SP` and `SU` groups has been improved
    using the invariant forms underlying these groups.

  - An improvement for the cyclic extension method for the
    computation of subgroup lattices has been implemented.

  - A better method for `MinimalPolynomial` for finite field matrices
    has been implemented.

  - The display has changed and the arithmetic of multivariate
    polynomials has been improved.

  - The `LogMod` function now uses Pollard's rho method combined with
    the Pohlig/Hellmann approach.

  - Various functions for sets and lists have been improved following
    suggestions of L. Teirlinck. These include: `Sort`, `Sortex`,
    `SortParallel`, `SortingPerm`, `NrArrangements`.

  - The methods for `StructureConstantsTable` and `GapInputSCTable`
    have been improved in the case of a known (anti-) symmetry
    following a suggestion of M. Costantini.

The improvements listed in this Section have been implemented by T.
Breuer and A. Hulpke.

### New Programming and User Features

  - The 2GB limit for workspace size has been removed and version
    numbers for saved workspaces have been introduced. (S. Linton and B.
    Höfling)

  - The limit on the total number of types created in a session has been
    removed. (S. Linton)

  - There is a new mechanism for loading packages available. Packages
    need a file `PackageInfo.g` now. (T. Breuer and F. Lübeck).

Finally, as always, a number of bugs have been fixed. This release thus
incorporates the contents of all the bug fixes which were released for
GAP 4.3. It also fixes a number of bugs discovered since the last
bug fix.

Below we list changes in the main system (excluding packages) that have
been corrected or added in bugfixes and updates for GAP 4.4.


## GAP 4.3 Bugfix 5

### Fixed bugs which could lead to wrong results:

  - A wrong return format for `IsomorphicSubgroups` applied to cyclic
    groups.

  - A wrong `true` result of `IsSubset` for certain algebras.

  - A bug in the subgroup conjugation test for permutation groups that
    are not subgroups.

  - A strange behaviour of `Intersection` for the case that a strictly
    sorted list is the unique entry of the list that is given as the
    argument; in this situation, this entry itself was returned instead
    of a shallow copy.

  - Possibly wrong result of `Centre` for pc groups.

  - Possibly wrong result of `DirectSumDecomposition` for matrix Lie
    algebras.

### Fixed bugs which could lead to crashes:

  - Segmentation faults and other strange behaviour when assigning
    finite field elements of different characteristics into compressed
    vectors.

### Other fixed bugs:

  - A missing method for `BaseOrthogonalSpaceMat`.

  - A missing `Set` call in the construction of the global variable
    `AUTOLOAD_PACKAGES`.

  - A wrong display string of the numerator in rational functions
    returned by `MolienSeries` (in the case that the constant term
    of this numerator is zero).

  - An error in the basis of a product space of algebras.

  - An error in `LieNormalizer`, `LieCentralizer` for zero subspaces.

  - An error in the computation of matrices of adjoint modules.

  - A strange error message when constructing the simple Lie algebra
    of type B1.

  - An error in `ModuleByRestriction`.

  - An error in `IrrBaumClausen` for the trivial group.

  - An error with vector space bases of row spaces over fields which
    neither are prime fields nor contain all entries of the vectors.

  - An error with `IsMonomial`, when it uses the function
    `TestMonomialFromLattice` (i.e., in hard cases, likely for
    characters of nonsolvable groups).


## GAP 4.3 Bugfix 4

### Fixed bugs which could lead to wrong results:

  - A problem with composing a homomorphism from an fp group with
    another homomorphism (images may be wrong).

  - An error in the comparison routine for univariate rational functions.

  - A problem when calculating representations of a group in which class
    arrangement in group and character table are not identical.

  - Three missing primitive groups of degree 441 were addded.

### Other fixed bugs:

  - A problem with a homomorphism from a free group in the trivial
    permutation group.

  - A problem with the multiplication of rationals and elements in
    large prime fields.

  - A problem with attempting to create univariate polynomials of very
    high degree.

  - A problem with output going to errout incorrectly after a syntax error.

  - An error in the function ReducedSCTable.

  - An error in computing the Rees Matrix semigroup.

  - A compatibility problem with earlier versions of gap in semigroup
    and monoid rewriting systems.

  - The behaviour of `PQuotient` when an attempt is made to compute a
    p-quotient with more generators than the underlying data structure
    was initialised with.

  - A problem with computing `BasisVectors` for a basis of an algebraic
    field extension.

  - A problem with the definition of `IsRowVector` (which previously
    returned `true` also for matrices).

  - A problem with `BaumClausenInfo`.

  - A problem with `IsRowModule` for infinite dimensional vector spaces
    (which are not row spaces).

  - A problem with `Difference` with first argument a list that is not
    a set and second argument an empty list.

  - The failure of Elements() to compute the elements of a pc group with non-prime relative orders.

  - A wrong computation of single character values of Weyl groups of
    type B and character tables of Weyl groups of type D. Furthermore,
    a much more efficient function for computing all character values
    is provided.

  - Packages accidentally overwriting the setting of `InfoWarning`.

  - A missing method for `IsPolynomial` for univariate rational functions.

  - A problem in the on-line help which sometimes returned a blank entry
    for a topic even though the topic was documented.

  - A problem in the help system where a tilde in a filename was
    replaced by a blank.

  - A problem that prevented the documentation of some packages from
    autoloading.


## GAP 4.3 Bugfix 3

### Fixed bugs which could lead to wrong results:

  - An error in `IdGroup` that mistakenly was not corrected in Bugfix 2.

  - An inconsistent setting of `IndicesNormalSteps`.

  - A problem with the inversion routine for quaternions.


## GAP 4.3 Bugfix 2

### Fixed bugs which could lead to wrong results:

  - The result of `ProjectiveSymplecticGroup(n,q);`.

### Fixed bugs which could lead to crashes:

  - A segmentation fault when appending to a length 0 compressed vector
    over GF2.

### Other fixed bugs:

  - An error in the computation of inverses in quaternion algebras with
    non-standard parameters.

  - `GeneratorOfCyclicGroup` for a trivial pc group.

  - A problem in backtrack routines using `Suborbits` if the group has
    fixed points in the range `[1..max(Omega)]`.

  - A problem with `CharacterTableDirectProduct` if exactly one argument
    is a Brauer table.

  - Problems with `IntScalarProduct` and `NonnegIntScalarProducts` if
    the third argument is not a plain list (this situation does not
    occur in GAP library functions).

  - A problem with `GQuotient`.

  - A problem with the linear algebra methods for Lie algebra cohomology.

  - A Problem with requesting transitive groups of degree including 1.

  - A Problem with inverting lists of compressed vectors over fields of
    order greater than 2.

  - An error in computing whether an element is in a Green's D equivalence
    class or not.

  - A missing method for `MovedPoints(perm)`.

  - The method `IsGreensLessThanOrEqual` should work for Green's D classes
    for finite groups.

  - The method `GroupHClassOfGreensDClass` was not implemented and is
    required for the Rees Matrix methods.

  - The methods `AssociatedReesMatrixSemigroupOfDClass`, `IsZeroSimpleSemigroup`,
    `IsomorphismReesMatrixSemigroup`, and `SandwichMatrixOfReesZeroMatrixSemigroup`
    all create Greens classes using obsolete methods which for some
    semigroups leads to infinite recursion or causes GAP to stop with
    an error message.

  - A problem with `CentralizerModulo` for permutation groups.

  - A wrong name for PGL(2,49) in the primitive groups library of degree 50.

  - Missing `Representative` methods for certain trivial groups and
    trivial spaces.

  - A missing setting of `IndicesNormalSteps`.


## GAP 4.3 Bugfix 1

### Fixed bugs which could lead to crashes:

  - A segmentation fault when converting length 0 compressed vectors to
    larger fields.

### Other fixed bugs:

  - A bug in the handling of Processes with empty input or output streams.

  - An error in the function for computing quotients of algebra modules.

  - An error in computing the strongly connected components of a binary
    relation in which incorrect results can be returned.

  - A "no method found" error in OrbitStabilizerAlgorithm for infinite groups.

  - Calculation of iterated automorphism groups might stop with an error message.

  - The output of the internal pager (see `Pager`) is no longer copied to log files.

  - Some memory is not freed up as soon as it could be, resulting in
    over-use of memory and over-large saved workspaces.

  - Saving and loading a workspace using a kernel containing a statically
    loaded user module (most likely a compiled GAP file) did not work.

  - Problems with `EulerianFunction` for certain types of groups.


## Changes from Earlier Versions

The most important changes between GAP 4.2 and GAP 4.3 were:

  - The performance of several routines has been substantially improved.

  - The functionality in the areas of finitely presented groups, Schur
    covers and the calculation of representations has been extended.

  - The data libraries of transitive groups, finite integral matrix
    groups, character tables and tables of marks have been extended.

  - The Windows installation has been simplified for the case where you
    are installing GAP in its standard location.

  - Many bugs have been fixed.

The most important changes between GAP 4.1 and GAP 4.2 were:

  - A much extended and improved library of small groups as well as
    associated `IdGroup` routines.

  - The primitive groups library has been made more independent of the
    rest of GAP, some errors were corrected.

  - New (and often much faster) infrastructure for orbit computation,
    based on a general "dictionary" abstraction.

  - New functionality for dealing with representations of algebras, and
    in particular for semisimple Lie algebras.

  - New functionality for binary relations on arbitrary sets, magmas and
    semigroups.

  - Bidirectional streams, allowing an external process to be started
    and then controlled "interactively" by GAP

  - A prototype implementation of algorithms using general subgroup
    chains.

  - Changes in the behavior of vectors over small finite fields.

  - A fifth book "New features for Developers" has been added to the
    GAP manual.

  - Numerous bug fixes and performance improvements

The changes between the final release of GAP 3 (version 3.4.4) and
GAP 4 are wide-ranging. The general philosophy of the changes is
two-fold. Firstly, many assumptions in the design of GAP 3 revealed
its authors' primary interest in group theory, and indeed in finite
group theory. Although much of the GAP 4 library is concerned with
groups, the basic design now allows extension to other algebraic
structures, as witnessed by the inclusion of substantial bodies of
algorithms for computation with semigroups and Lie algebras. Secondly,
as the scale of the system, and the number of people using and
contributing to it has grown, some aspects of the underlying system have
proved to be restricting, and these have been improved as part of
comprehensive re-engineering of the system. This has included the new
method selection system, which underpins the library, and a new, much
more flexible, GAP package interface.

Details of these changes can be found in the document "Migrating to GAP
4" available at the GAP website, see
[here](https://www.gap-system.org/Gap3/migratedoc.pdf).

It is perhaps worth mentioning a few points here.

Firstly, much remains unchanged, from the perspective of the
mathematical user:

  - The syntax of that part of the GAP language that most users need
    for investigating mathematical problems.

  - The great majority of function names.

  - Data libraries and the access to them.

A number of visible aspects have changed:

  - Some function names that need finer specifications now that there
    are more structures available in GAP.

  - The access to information already obtained about a mathematical
    structure. In GAP 3 such information about a group could be
    looked up by directly inspecting the group record, whereas in
    GAP 4 functions must be used to access such information.

Behind the scenes, much has changed:

  - A new kernel, with improvements in memory management and in the
    language interpreter, as well as new features such as saving of
    workspaces and the possibility of compilation of GAP code into
    C.

  - A new structure to the library, based upon a new type and method
    selection system, which is able to support a broader range of
    algebraic computation and to make the structure of the library
    simpler and more modular.

  - New and faster algorithms in many mathematical areas.

  - Data structures and algorithms for new mathematical objects, such as
    algebras and semigroups.

  - A new and more flexible structure for the GAP installation and
    documentation, which means, for example, that a GAP package and
    its documentation can be installed and be fully usable without any
    changes to the GAP system.

Very few features of GAP 3 are not yet available in GAP 4.

  - Not all of the GAP 3 packages have yet been converted for use
    with GAP 4.

  - The library of crystallographic groups which was present in
    GAP 3 is now part of a GAP 4 package
    [**CrystCat**](https://www.gap-system.org/Packages/crystcat.html) by
    V. Felsch and F. Gähler.
