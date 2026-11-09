# EmbedAutomorphisms could return a group that was not a subgroup of
# Aut(T): if the permutation representation of T had a nontrivial
# centralizer in the symmetric group, the closure with the conjugating
# elements could be C2 x A6.2 instead of Aut(A6), but have the same order.
# As a consequence, MaximalSubgroupClassReps missed the diagonal (type 3a)
# maximal subgroups for some random seeds.
gap> res:=[];;
gap> for seed in [13,19,22] do
>   G:=PrimitiveGroup(360,3);;
>   Reset(GlobalMersenneTwister,seed);;
>   Reset(GlobalRandomSource,seed);;
>   Add(res,SortedList(List(MaximalSubgroupClassReps(G),Size)));
> od;
gap> ForAll(res,x->x=[720,720,720,720,5760,5760,7200,7200,25920,25920,129600]);
true
