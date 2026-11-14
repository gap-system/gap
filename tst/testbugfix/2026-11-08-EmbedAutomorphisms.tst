# EmbedAutomorphisms could return a group that was not a subgroup of
# Aut(T): if the permutation representation of T had a nontrivial
# centralizer in the symmetric group, the closure with the conjugating
# elements could be C2 x A6.2 instead of Aut(A6), but have the same order.
# As a consequence, MaximalSubgroupClassReps missed the diagonal (type 3a)
# maximal subgroups for some random seeds.
gap> res:=[];;
gap> for seed in [11..19] do
>   G:=PrimitiveGroup(360,3);;
>   Reset(GlobalMersenneTwister,seed);;
>   Reset(GlobalRandomSource,seed);;
>   Add(res,SortedList(List(MaximalSubgroupClassReps(G),Size)));
> od;
gap> ForAll(res,x->x=[720,720,720,720,5760,5760,7200,7200,25920,25920,129600]);
true

# G is PGL(2,9) on 20 points; its socle has a centralizer of order 2 in
# S20, so conjugators inducing automorphisms of the socle are determined
# only up to that centralizer. EmbedAutomorphisms must still return a
# group acting faithfully on the socle, or MaximalSubgroupClassReps misses
# diagonal maximals, e.g. of PrimitiveGroup(360,3).
# See https://github.com/gap-system/gap/issues/6807
gap> START_TEST("2026-11-08-EmbedAutomorphisms.tst");
gap> G:=Group(( 1, 6)( 2, 7)( 4,10)( 5, 8)(11,17)(12,20)(14,16)(15,19),
>   ( 1,11, 9,20, 4,15, 5,16, 3,17)( 2,19, 7,18,10,12, 6,14, 8,13));;
gap> H:=PGL(2,9);;
gap> r:=EmbedAutomorphisms(G,H,DerivedSubgroup(G),DerivedSubgroup(H));;
gap> IsTrivial(Centralizer(r[1],Image(r[2],DerivedSubgroup(G))));
true
