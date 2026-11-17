# SubgroupConditionAboveAux could process a class before the class of a
# power of its elements, and then ran into an error or missed elements.
# Pc groups skip the SubgroupProperty phase and reach the class search.
gap> G:=DirectProduct(CyclicGroup(IsPcGroup,9),ElementaryAbelianGroup(IsPcGroup,16));;
gap> U:=Image(Embedding(G,1));;
gap> SubgroupConditionAboveAux(G,x->x in U,TrivialSubgroup(G),TrivialSubgroup(G))=U;
true

# Classes of equal size (here: all of them, as the groups are
# abelian) could come in an order with the class of an element before the
# class of its prime power. This produced an error (unassigned entry in
# `worked`), or a subgroup that was too small. The relabellings below were
# found to trigger the error.
gap> cyc:=function(n,off)
>   return PermList(Concatenation([1..off],off+[2..n],[off+1]));
> end;;
gap> check:=function(gens,seed)
> local rs,p,G,x,T;
>   rs:=RandomSource(IsMersenneTwister,seed);
>   p:=Random(rs,SymmetricGroup(LargestMovedPoint(gens)));
>   G:=Group(List(gens,g->g^p));
>   repeat x:=Random(rs,G); until Order(x)=9;
>   T:=Group(x);
>   return SubgroupConditionAboveAux(G,y->y in T,
>     TrivialSubgroup(G),TrivialSubgroup(G))=T;
> end;;

# C9 x C9 x C3 x C3
gap> gens:=[cyc(9,0),cyc(9,9),cyc(3,18),cyc(3,21)];;
gap> ForAll([153,228,250,638,830,891,916,941,943,1150],s->check(gens,s));
true
