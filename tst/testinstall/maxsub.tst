gap> START_TEST("maxsub.tst");

#
gap> G := GL(2,3);;
gap> msc := MaximalSubgroupClassReps(G);;
gap> ForAll(msc, H -> Parent(H) = G);
true
gap> SortedList(List(msc, IndexInParent));
[ 2, 3, 4 ]

#
gap> G := GL(2,4);;
gap> msc:=MaximalSubgroupClassReps(G);;
gap> ForAll(msc, H -> Parent(H) = G);
true
gap> SortedList(List(msc, IndexInParent));
[ 3, 5, 6, 10 ]

#
gap> G := GL(2,5);;
gap> msc := MaximalSubgroupClassReps(G);;
gap> ForAll(msc, H -> Parent(H) = G);
true
gap> SortedList(List(msc, IndexInParent));
[ 2, 5, 6, 10 ]

#
gap> G := AlternatingGroup(5);;
gap> msc := MaximalSubgroupClassReps(G);;
gap> SortedList(List(msc, H -> Index(G, H)));
[ 5, 6, 10 ]

#
gap> STOP_TEST("maxsub.tst", 1);
