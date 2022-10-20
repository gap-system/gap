# IsPlistMatrixRep
gap> NewMatrix(IsPlistMatrixRep, Integers, 3, [ ] ); Display(last);
<0x3-matrix over Integers>
<0x3-matrix over Integers: [
]>
gap> NewMatrix(IsPlistMatrixRep, Integers, 3, [ 1, 2, 3 ] ); Display(last);
<1x3-matrix over Integers>
<1x3-matrix over Integers: [
 [ 1, 2, 3 ]
]>
gap> NewMatrix(IsPlistMatrixRep, Integers, 3, [ 1, 2, 3, 4, 5, 6 ] ); Display(last);
<2x3-matrix over Integers>
<2x3-matrix over Integers: [
 [ 1, 2, 3 ]
 [ 4, 5, 6 ]
]>
gap> NewMatrix(IsPlistMatrixRep, Integers, 3, [ [1, 2, 3], [4, 5, 6] ] ); Display(last);
<2x3-matrix over Integers>
<2x3-matrix over Integers: [
 [ 1, 2, 3 ]
 [ 4, 5, 6 ]
]>

# IsPlistMatrixRep errors
gap> NewMatrix(IsPlistMatrixRep, Integers, 3, [ 1 ] );
Error, NewMatrix: Length of <l> is not a multiple of <ncols>
gap> NewMatrix(IsPlistMatrixRep, Integers, 3, [ 1, 2 ] );
Error, NewMatrix: Length of <l> is not a multiple of <ncols>
gap> NewMatrix(IsPlistMatrixRep, Integers, 3, [ 1, 2, 3, 4 ] );
Error, NewMatrix: Length of <l> is not a multiple of <ncols>
