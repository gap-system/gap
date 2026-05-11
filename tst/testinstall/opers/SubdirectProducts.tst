gap> START_TEST("SubdirectProducts.tst");
gap> G := SymmetricGroup(3);;
gap> H := SymmetricGroup(4);;
gap> A := CyclicGroup(6);;

#
gap> SortedList(List(SubdirectProducts(G, G), StructureDescription));
[ "(C3 x C3) : C2", "S3", "S3 x S3" ]
gap> SortedList(List(SubdirectProducts(A, A), StructureDescription));
[ "C6", "C6", "C6 x C2", "C6 x C2", "C6 x C3", "C6 x C6" ]

# for the next couple tests, StructureDescription gives different outputs
# depending on which packages are loaded; e.g. for SubdirectProducts(H, H):
# [ "((C2 x C2 x C2 x C2) : C3) : C2", "(A4 x A4) : C2", "S4", "S4 x S4" ]
# [ "(C2 x C2) : ((C3 x A4) : C2)", "(C2 x C2) : S4", "S4", "S4 x S4" ]
# thus we use IdGroup if available, and else fall back to a weaker size test.
#@if IsPackageMarkedForLoading( "smallgrp", "" )
gap> SortedList(List(SubdirectProducts(H, H), IdGroup));
[ [ 24, 12 ], [ 96, 227 ], [ 288, 1026 ], [ 576, 8653 ] ]
gap> SortedList(List(SubdirectProducts(G, H), IdGroup));
[ [ 24, 12 ], [ 72, 43 ], [ 144, 183 ] ]
gap> SortedList(List(SubdirectProducts(H, G), IdGroup));
[ [ 24, 12 ], [ 72, 43 ], [ 144, 183 ] ]
#@else
gap> SortedList(List(SubdirectProducts(H, H), Size));
[ 24, 96, 288, 576 ]
gap> SortedList(List(SubdirectProducts(G, H), Size));
[ 24, 72, 144 ]
gap> SortedList(List(SubdirectProducts(H, G), Size));
[ 24, 72, 144 ]
#@fi

#
gap> SortedList(List(SubdirectProducts(G, A), StructureDescription));
[ "C3 x S3", "C6 x S3" ]
gap> SortedList(List(SubdirectProducts(A, G), StructureDescription));
[ "C3 x S3", "C6 x S3" ]

#
gap> SortedList(List(SubdirectProducts(H, A), StructureDescription));
[ "C3 x S4", "C6 x S4" ]
gap> SortedList(List(SubdirectProducts(A, H), StructureDescription));
[ "C3 x S4", "C6 x S4" ]

#
gap> STOP_TEST("SubdirectProducts.tst");
