gap> START_TEST("SubdirectProducts.tst");
gap> G := SymmetricGroup(3);;
gap> H := SymmetricGroup(4);;
gap> A := CyclicGroup(6);;

#
gap> Set(SubdirectProducts(G, G), IdGroup);
[ [ 6, 1 ], [ 18, 4 ], [ 36, 10 ] ]
gap> Set(SubdirectProducts(H, H), IdGroup);
[ [ 24, 12 ], [ 96, 227 ], [ 288, 1026 ], [ 576, 8653 ] ]
gap> Set(SubdirectProducts(A, A), IdGroup);
[ [ 6, 2 ], [ 12, 5 ], [ 18, 5 ], [ 36, 14 ] ]

#
gap> Set(SubdirectProducts(G, H), IdGroup);
[ [ 24, 12 ], [ 72, 43 ], [ 144, 183 ] ]
gap> Set(SubdirectProducts(H, G), IdGroup);
[ [ 24, 12 ], [ 72, 43 ], [ 144, 183 ] ]

#
gap> Set(SubdirectProducts(G, A), IdGroup);
[ [ 18, 3 ], [ 36, 12 ] ]
gap> Set(SubdirectProducts(A, G), IdGroup);
[ [ 18, 3 ], [ 36, 12 ] ]

#
gap> Set(SubdirectProducts(H, A), IdGroup);
[ [ 72, 42 ], [ 144, 188 ] ]
gap> Set(SubdirectProducts(A, H), IdGroup);
[ [ 72, 42 ], [ 144, 188 ] ]

#
gap> STOP_TEST("SubdirectProducts.tst", 10000);
