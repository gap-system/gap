gap> START_TEST("StructureDescription.tst");
gap> G := Group([ (6,7,8,9,10), (8,9,10), (1,2)(6,7), (1,2,3,4,5)(6,7,8,9,10) ]);;
gap> StructureDescription(G);
"A5 : S5"
gap> STOP_TEST("StructureDescription.tst", 1);
