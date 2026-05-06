gap> START_TEST("SubdirectProducts.tst");
gap> G := SymmetricGroup(3);;
gap> H := SymmetricGroup(4);;
gap> A := CyclicGroup(6);;

#
gap> Set(SubdirectProducts(G, G), StructureDescription);
[ "(C3 x C3) : C2", "S3", "S3 x S3" ]
gap> Set(SubdirectProducts(H, H), StructureDescription);
[ "((C2 x C2 x C2 x C2) : C3) : C2", "(A4 x A4) : C2", "S4", "S4 x S4" ]
gap> Set(SubdirectProducts(A, A), StructureDescription);
[ "C6", "C6 x C2", "C6 x C3", "C6 x C6" ]

#
gap> Set(SubdirectProducts(G, H), StructureDescription);
[ "(C3 x A4) : C2", "S4", "S4 x S3" ]
gap> Set(SubdirectProducts(H, G), StructureDescription);
[ "(C3 x A4) : C2", "S3 x S4", "S4" ]

#
gap> Set(SubdirectProducts(G, A), StructureDescription);
[ "C3 x S3", "C6 x S3" ]
gap> Set(SubdirectProducts(A, G), StructureDescription);
[ "C3 x S3", "C6 x S3" ]

#
gap> Set(SubdirectProducts(H, A), StructureDescription);
[ "C3 x S4", "C6 x S4" ]
gap> Set(SubdirectProducts(A, H), StructureDescription);
[ "C3 x S4", "C6 x S4" ]

#
gap> STOP_TEST("SubdirectProducts.tst");
