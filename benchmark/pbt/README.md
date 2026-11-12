# Benchmarks for the partition backtrack

Timings of what GAP computes by the partition backtrack in
`lib/stbcbckt.gi`: normalizers and conjugacy of subgroups, centralizers and
conjugacy of elements, set stabilizers and intersections in permutation
groups. A change to that code easily makes one input 20 times faster and
another 20 times slower, so measure it on all of these, before and after.

## Usage

In a GAP checkout that has been built:

    benchmark/pbt/run.py -o before.json
    # change the code
    benchmark/pbt/run.py -o after.json
    benchmark/pbt/compare.py before.json after.json

`run.py` prints a line for each case, with its time in milliseconds and its
result. `compare.py` lists the cases whose time changed by more than a
factor of 1.5 and by more than 20 ms, or whose result or status changed,
and sums up each family of cases. Options of `run.py`:

- `--list` prints the names of the cases.
- `--filter REGEX` runs only the cases whose name matches, for example
  `--filter ^wreath/`.
- `--seeds N` runs each case with N different random seeds; `compare.py`
  takes the fastest run.
- `--timeout SECONDS` is the time limit for each run, 120 by default.
- `--jobs N` runs N cases at once.
- `--gaproot DIR --gap EXE` times the library of the GAP root `DIR` with
  the executable `EXE`. That root need neither be built nor contain these
  files, so one built checkout can time others whose kernel is the same.

## What is timed

`cases.g` defines all cases, with a section for each family below. A case
is called `<family>/<input>.<computation>`, or `<family>/<input>` if the
family has one computation only.

In the first six families the input is a permutation group G. Let S be the
symmetric group on the points of G, and let E be G and F be G^x for a
random x in S, both given by random generators. There are four cases:

| case                    | computation                       |
|-------------------------|-----------------------------------|
| `.Normalizer`           | `Normalizer( S, E )`              |
| `.RepresentativeAction` | `RepresentativeAction( S, E, F )` |
| `.NormalizerPermGroup`  | `NormalizerPermGroup( S, E )`     |
| `.ConjugatorPermGroup`  | `ConjugatorPermGroup( S, E, F )`  |

The first two are what a user calls. In a symmetric group their methods in
`lib/gpprmsya.gi` first try to reduce or settle the problem by other means.
The last two start the backtrack search right away.

| family         | groups                                                    |
|----------------|-----------------------------------------------------------|
| `issue3718`    | the pairs E, F of degrees 31 and 1125 from issue #3718, as given there, and the second pair acting on its 375 blocks |
| `primitive`    | PSL(n,q), Sz(8) and Mathieu groups in their natural actions |
| `intransitive` | direct products, PSU(3,3) on 28 + 63 points, S_7 on points and pairs |
| `coset`        | simple and symmetric groups on the cosets of a Sylow subgroup |
| `wreath`       | wreath products in their imprimitive actions              |
| `transitive`   | imprimitive groups of degrees 20 to 46 from the library of transitive groups, picked because GAP or a proposed change to it was slow on them |

The other families:

| family         | computation                                               |
|----------------|-----------------------------------------------------------|
| `nonconjugate` | `RepresentativeAction( S, E, F )` for subgroups E, F of the same order that are not conjugate in S |
| `element`      | the centralizer of a random element, and an element conjugating one random element or pair of elements to another, in S_500 and in S_10 wr S_10 |
| `setstab`      | `Stabilizer( G, A, OnSets )` and `RepresentativeAction( G, A, B, OnSets )` for random sets A, B of points |
| `intersection` | `Intersection( G, H )` for a random conjugate H of a second group |
| `batch`        | many small normalizers, conjugacy tests or centralizers in one case, to show the overhead per call |

## How a case is run

`run.py` starts a new GAP for every case and seed:

    gap -q -A --quitonbreak \
        -c 'PBT_CASE := "<name>";; PBT_SEED := <seed>;;' runcase.g

So no case profits from what another computed, and one that exceeds the
time limit is stopped and reported as `timeout`. `runcase.g` builds the
input of the case, which is not timed, resets the random sources to the
seed and times the computation with `Runtime`. The input is the same for
every seed. The seed changes the random choices made during the search, on
which its time can depend a lot.

Every case returns a result that would change if the answer were wrong: the
order of the group found, or whether the element found does what it should.
`compare.py` reports results that differ, so the cases are a regression
test as well.

## Adding a case

In `cases.g`, call `PBT_SubgroupCases( name, group )` with a function
returning a permutation group to get the four cases above, or
`PBT_AddCase( name, setup, run )` for anything else. The comments there
say more.

## fuzz.g

`fuzz.g` is not a benchmark but a randomized correctness test of the same
code. It checks the answers for random subgroups, elements and sets in
symmetric groups of small degree against brute force:

    gap -q -A benchmark/pbt/fuzz.g
