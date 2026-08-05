gap> START_TEST("maxsub.tst");

#
gap> G := GL(2,3);;
gap> msc := MaximalSubgroupClassReps(G);;
gap> ForAll(msc, H -> Parent(H) = G);
true
gap> SortedList(List(msc, IndexInParent));
[ 2, 3, 4 ]

#
#@if IsPackageMarkedForLoading( "primgrp", "" )
gap> G := GL(2,4);;
gap> msc:=MaximalSubgroupClassReps(G);;
gap> ForAll(msc, H -> Parent(H) = G);
true
gap> SortedList(List(msc, IndexInParent));
[ 3, 5, 6, 10 ]
#@fi

#@if IsPackageMarkedForLoading( "perfgrp", "" )
gap> G := GL(2,5);;
gap> msc := MaximalSubgroupClassReps(G);;
gap> ForAll(msc, H -> Parent(H) = G);
true
gap> SortedList(List(msc, IndexInParent));
[ 2, 5, 6, 10 ]
#@fi

#
#@if IsPackageMarkedForLoading( "primgrp", "" )
gap> G := AlternatingGroup(5);;
gap> msc := MaximalSubgroupClassReps(G);;
gap> SortedList(List(msc, H -> Index(G, H)));
[ 5, 6, 10 ]
#@fi

# used to run into an infinite recursion without the primitive groups library
gap> oldlevel := InfoLevel(InfoPerformance);;
gap> SetInfoLevel(InfoPerformance, 0);
gap> G := AlternatingGroup(6);;
gap> msc := MaximalSubgroupClassReps(G);;
gap> SetInfoLevel(InfoPerformance, oldlevel);
gap> SortedList(List(msc, H -> Index(G, H)));
[ 6, 6, 10, 15, 15 ]

#
gap> STOP_TEST("maxsub.tst");
