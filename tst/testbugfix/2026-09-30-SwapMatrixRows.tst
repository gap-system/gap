# SwapMatrixRows on a plain list matrix checked the second row index
# against the first, and swapped rows of immutable matrices
gap> m:= [ [ 1, 2 ], [ 3, 4 ] ];;
gap> SwapMatrixRows( m, 1, 3 );
Error, Matrix Element: <mat>[3] must have an assigned value
gap> SwapMatrixRows( m, 3, 1 );
Error, Matrix Element: <mat>[3] must have an assigned value
gap> m;
[ [ 1, 2 ], [ 3, 4 ] ]
gap> SwapMatrixRows( m, 2, 1 );
gap> m;
[ [ 3, 4 ], [ 1, 2 ] ]
gap> m:= Immutable( [ [ 1, 2 ], [ 3, 4 ] ] );;
gap> SwapMatrixRows( m, 1, 2 );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SwapMatrixRows' on 3 arguments
gap> m;
[ [ 1, 2 ], [ 3, 4 ] ]
