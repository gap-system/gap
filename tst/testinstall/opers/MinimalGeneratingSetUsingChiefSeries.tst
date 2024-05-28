gap> START_TEST("MinimalGeneratingSetUsingChiefSeries.tst");
gap> CrossVerifyMinimalGeneratingSetUsingChiefSeries := function(startsize,endsize)
>     local G,size,gens1,gens2,G1,G2,i;
>     for size in [startsize..endsize] do
>         i := 0;
>         for G in AllSmallGroups(size) do
>             i := i + 1;
>             gens1:= MinimalGeneratingSet(G);
>             gens2:= MinimalGeneratingSetUsingChiefSeries(G);
>             if Length(gens1) = 0 then
>                 if IsTrivial(G) then
>                     if Length(gens2) > 0 then
>                         return Concatenation("FAILED on AllSmallGroups(",String(size),")[",String(i),"]");
>                     else
>                         continue;
>                     fi;
>                 else
>                     return Concatenation("MinimalGeneratingSet is failing on AllSmallGroups(",String(size),")[",String(i),"]");
>                 fi;
>             fi;
>             G1 := GroupByGenerators(gens1);
>             if not G = G1 then
>                 return Concatenation("MinimalGeneratingSet is failing on AllSmallGroups(",String(size),")[",String(i),"]");
>             fi;
>             G2 := GroupByGenerators(gens2);
>             if (not G = G2) or Length(gens1) < Length(gens2) then
>                 return Concatenation("FAILED on AllSmallGroups(",String(size),")[",String(i),"]");
>             fi;
>         od;
>     od;
>     return "PASSED";
> end;
function( startsize, endsize ) ... end
gap> CrossVerifyMinimalGeneratingSetUsingChiefSeries(1,60);
"PASSED"
gap> CrossVerifyMinimalGeneratingSetUsingChiefSeries(115,125);
"PASSED"
gap> G := AlternatingGroup(5);
Alt( [ 1 .. 5 ] )
gap> G := DirectProduct(G,G);;
gap> mu := MinimalGeneratingSetUsingChiefSeries(G);;
gap> G = GroupByGenerators(mu);
true
gap> Length(mu);
2
