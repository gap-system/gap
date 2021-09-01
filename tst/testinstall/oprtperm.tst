#@local
gap> START_TEST("oprtperm.tst");

# Transitivity of permgroups of known size that happen to be natural Sn/An
# (Really we're testing performance)
gap> Transitivity(SymmetricGroup(1000));
1000
gap> Transitivity(AlternatingGroup(1002));
1000

# Check small cases with moved points [1..n]
gap> List([0 .. 10], n -> Transitivity(SymmetricGroup(n)));
[ 0, 0, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> List([0 .. 10], n -> Transitivity(AlternatingGroup(n)));
[ 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8 ]

# Check small cases with moved points different from [1..n]
gap> List([0 .. 10], n ->
>      Transitivity(SymmetricGroup(Shuffle(ShallowCopy(Primes)){[1 .. n]})));
[ 0, 0, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> List([0 .. 10], n ->
>      Transitivity(AlternatingGroup(Shuffle(ShallowCopy(Primes)){[1 .. n]})));
[ 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8 ]

#
gap> STOP_TEST("oprtperm.tst", 1);
