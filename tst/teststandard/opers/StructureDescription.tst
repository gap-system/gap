gap> START_TEST("StructureDescription.tst");
gap> G := Group([ (6,7,8,9,10), (8,9,10), (1,2)(6,7), (1,2,3,4,5)(6,7,8,9,10) ]);;
gap> StructureDescription(G);
"A5 : S5"
gap> for n in [1..100] do for i in [1..NumberSmallGroups(n)] do if n<>64 and n<>96 then G := SmallGroup(n,i); H := SmallGroup(n, i); if StructureDescription(G)<>StructureDescription(H:recompute) then Print(n, ", ", i, ", ", StructureDescription(H:recompute), "\n"); fi; fi; od; od;
gap> STOP_TEST("StructureDescription.tst", 10000);
