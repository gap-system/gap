gap> START_TEST("ElementaryMatrices.tst");

#
gap> ReadGapRoot("tst/testinstall/MatrixObj/testmatobj.g");

#
gap> TestElementaryTransforms( [[2,4,5],[7,11,-4],[-3,20,0]], -1 );
gap> TestElementaryTransforms( Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]), -1 );

#
gap> F := GF(2);;
gap> mat := RandomInvertibleMat(4, F);; # list of compressed vectors
gap> TestElementaryTransforms( mat, PrimitiveRoot(F) );
gap> ConvertToMatrixRep(mat);;  # proper matrix obj
gap> TestElementaryTransforms( mat, PrimitiveRoot(F) );

#
gap> F := GF(3);;
gap> mat := RandomInvertibleMat(4, F);; # list of compressed vectors
gap> TestElementaryTransforms( mat, PrimitiveRoot(F) );
gap> ConvertToMatrixRep(mat);;  # proper matrix obj
gap> TestElementaryTransforms( mat, PrimitiveRoot(F) );

#
gap> F := GF(4);;
gap> mat := RandomInvertibleMat(4, F);; # list of compressed vectors
gap> TestElementaryTransforms( mat, PrimitiveRoot(F) );
gap> ConvertToMatrixRep(mat);;  # proper matrix obj
gap> TestElementaryTransforms( mat, PrimitiveRoot(F) );

#
gap> F := GF(5);;
gap> mat := RandomInvertibleMat(4, F);; # list of compressed vectors
gap> TestElementaryTransforms( mat, PrimitiveRoot(F) );
gap> ConvertToMatrixRep(mat);;  # proper matrix obj
gap> TestElementaryTransforms( mat, PrimitiveRoot(F) );

##########
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

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> MultMatrixRow(mat,2,-4);
gap> mat= Matrix( [ [2,4,5], [ -28, -44, 16 ], [-3,20,0]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> MultMatrixRowLeft(mat,2,5);
gap> mat= Matrix( [ [2,4,5], [ 35, 55, -20 ], [-3,20,0]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> MultMatrixRowRight(mat,3,-1);
gap> mat= Matrix( [ [2,4,5], [7,11,-4], [3,-20,0]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> MultMatrixColumn(mat,3,2);
gap> mat= Matrix( [ [2,4,10], [7,11,-8], [-3,20,0]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> MultMatrixColumnRight(mat,1,-3);
gap> mat= Matrix( [ [-6,4,5], [-21,11,-4], [9,20,0]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> MultMatrixColumnLeft(mat,2,4);
gap> mat= Matrix( [ [2,16,5], [7,44,-4], [-3,80,0]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> AddMatrixRows(mat,2,1,-3);
gap> mat= Matrix( [ [2,4,5], [1,-1,-19], [-3,20,0]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> AddMatrixRowsLeft(mat,3,2,2);
gap> mat= Matrix( [ [2,4,5], [7,11,-4], [11,42,-8]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> AddMatrixRowsRight(mat,1,3,-3);
gap> mat= Matrix( [ [11,-56,5], [7,11,-4], [-3,20,0]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> AddMatrixColumns(mat,2,1,-3);
gap> mat= Matrix( [ [2,-2,5], [7,-10,-4], [-3,29,0]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> AddMatrixColumnsRight(mat,3,2,2);
gap> mat= Matrix( [ [2,4,13], [7,11,18], [-3,20,40]]);
true

#
gap> mat := Matrix( [[2,4,5],[7,11,-4],[-3,20,0]]);;
gap> AddMatrixColumnsLeft(mat,1,3,-3);
gap> mat= Matrix( [ [-13,4,5], [19,11,-4], [-3,20,0]]);
true
gap> STOP_TEST("ElementaryMatrices.tst",1);
