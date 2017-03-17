gap> START_TEST("small_groups2.tst");
gap> bad := [];;
gap> for n in [1..Length(NAMES_OF_SMALL_GROUPS)] do
>   if not IsBound(NAMES_OF_SMALL_GROUPS[n]) then continue; fi;
>   for i in [1..NrSmallGroups(n)] do
>     G := SmallGroup(n, i);
>     descA := NAMES_OF_SMALL_GROUPS[n][i];
>     G := Subgroup(G, GeneratorsOfGroup(G));
>     descB := StructureDescription(G : recompute := true, nice := true);
>     if descA <> descB then
>       Print([n,i], ": bad description ", descB, ", should be ", descA, "\n");
>       AddSet(bad, [n,i]);
>     fi;
>     if IdGroup(G) <> [n,i] then
>       Print([n,i], ": bad id ",IdGroup(G), "\n");
>       AddSet(bad, [n,i]);
>     fi;
>   od;
> od;
gap> bad;
[  ]
gap> STOP_TEST( "small_groups2.tst", 1);
