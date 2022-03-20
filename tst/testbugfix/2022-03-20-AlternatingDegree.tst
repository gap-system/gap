# Very fix for infinite recursion in AlternatingDegree and SymmetricDegree,
# see https://github.com/gap-system/gap/issues/4826
gap> TweakGroup:=function(G)
>   local H;
>   H := Action(G,Orbit(G,[1,2],OnTuples),OnTuples);
>   SetIsAlternatingGroup(H,IsAlternatingGroup(G));
>   SetIsSymmetricGroup(H,IsSymmetricGroup(G));
>   return H;
> end;;

#
gap> List([1..6], n -> AlternatingDegree(TweakGroup(AlternatingGroup(n))));
[ 0, 0, 3, 4, 5, 6 ]
gap> List([1..6], n -> SymmetricDegree(TweakGroup(SymmetricGroup(n))));
[ 0, 2, 3, 4, 5, 6 ]
