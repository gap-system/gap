gap> START_TEST("ElementaryMatrices.tst");

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> SwapMatrixRows(mat,1,3);
gap> mat= Matrix( [ [ -3, 20, 0 ], [ 7, 11, -4 ], [ 2, 4, 5 ] ]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> SwapMatrixColumns(mat,1,3);
gap> mat= Matrix( [ [ 5, 4, 2 ], [ -4, 11, 7 ], [ 0, 20, -3 ] ]);
true
gap> STOP_TEST("ElementaryMatrices.tst",1);