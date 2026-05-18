gap> START_TEST("MinimalFaithfulPermutationDegreeOfFittingFreeGroup.tst");
gap> CheckInList := function(L,Mus)
>     local i,stop,mu,mu2,G,g;
>     for i in [1..Length(L)] do
>         G := L[i];
>         if IsList(Mus) then mu := Mus[i];
>         else
>             mu := DoMinimalFaithfulPermutationDegree(G,false);
>         fi;
>         mu2 := MinimalFaithfulPermutationDegreeOfFittingFreeGroup(G);
>         if mu2 = mu then
>         else
>             return Concatenation("F.A.I.L on",String(G));
>         fi;
>     od;
>     return "pass";
> end;;
gap> 
gap> TestCases := Filtered(List(SimpleGroupsIterator(2,50000)),
>     G->IsPSL(G) or (Size(G) < 1000 and not IsAbelian(G)));;
gap> Degs := List(TestCases,MinimalFaithfulPermutationDegree);;
gap> l := Length(TestCases);;
gap> for i in [1..l] do
>     for j in [1..i] do
>         G := DirectProduct(TestCases[i],TestCases[j]);
>         Add(TestCases,G);
>         Add(Degs,Degs[i] + Degs[j]);
>     od;
> od;
gap> 
gap> SemiSimpleGroupsTillSize1000 := [
>     SmallGroup(60,5),
>     SmallGroup(120,34),
>     SmallGroup(168,42),
>     SmallGroup(336,208),
>     SmallGroup(360,118),
>     SmallGroup(504,156),
>     SmallGroup(660,13),
>     SmallGroup(720,763),
>     SmallGroup(720,764),
>     SmallGroup(720,765),
>     #sizes 512 and 768 skipped
> ];;
gap> 
gap> 
gap> # Semi Simple Groups below size 1000
gap> CheckInList(SemiSimpleGroupsTillSize1000,-1);
"pass"
gap> 
gap> # Products of Simple Groups
gap> ind := List([1..30],x->Random([1..Length(TestCases)]));;
gap> CheckInList(List(ind,n->TestCases[n]),List(ind,n->Degs[n]));
"pass"
gap> STOP_TEST( "MinimalFaithfulPermutationDegreeOfFittingFreeGroup.tst", 1);