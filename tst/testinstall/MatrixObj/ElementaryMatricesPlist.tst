#@local v, M, N
gap> START_TEST( "ElementaryMatricesPlist.tst" );

#
# elementary operations
#
gap> M:= NewMatrix( IsPlistMatrixRep, GF(9), 2, Z(9) * [ [ 1, 0 ], [ 1, 1 ] ] );;
gap> v:= M[1];;
gap> AddMatrixRowsLeft( M, 1, 2, Z(9) );;
gap> AddMatrixRowsRight( M, 2, 1, 2 );;
gap> MultMatrixRowLeft( M, 2, Z(9)^3 );;
gap> MultMatrixRowRight( M, 1, -1 );;
gap> AddMatrixColumnsLeft( M, 2, 1, Z(9) );;
gap> AddMatrixColumnsRight( M, 1, 2, 1 );;
gap> MultMatrixColumnLeft( M, 2, Z(3) );;
gap> MultMatrixColumnRight( M, 1, Z(9)^2 );;
gap> SwapMatrixRows( M, 1, 2 );;
gap> SwapMatrixColumns( M, 2, 1 );;
gap> Unpack( M );
[ [ Z(3^2), 0*Z(3) ], [ Z(3^2), Z(3^2)^6 ] ]
gap> IsIdenticalObj( v, M[2] );
true

#
gap> MultMatrixRowLeft( M, 1, Z(27) );
Error, <scalar> must lie in the base domain of <M>
gap> MultMatrixColumnRight( M, 1, Z(27) );
Error, <scalar> must lie in the base domain of <M>
gap> AddMatrixRowsLeft( M, 1, 2, Z(27) );
Error, <scalar> must lie in the base domain of <M>
gap> AddMatrixColumnsRight( M, 1, 2, Z(27) );
Error, <scalar> must lie in the base domain of <M>
gap> N:= MutableCopyMatrix( M );;
gap> MultMatrixRowLeft( N, 1, Z(27) : check:= false );;
gap> N[1,1] = Z(27) * M[1,1];
true

#
gap> AddMatrixRowsLeft( M, 1, 3, Z(9) );
Error, List Element: <list>[3] must have an assigned value
gap> MultMatrixColumnLeft( M, 3, Z(9) );
Error, List Element: <list>[3] must have an assigned value
gap> SwapMatrixRows( M, 3, 1 );
Error, List Element: <list>[3] must have an assigned value
gap> SwapMatrixColumns( M, 1, 3 );
Error, List Element: <list>[3] must have an assigned value
gap> MakeImmutable( M );;
gap> MultMatrixRowLeft( M, 1, Z(9) );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `MultMatrixRowLeft' on 3 arguments

#
gap> M:= NewZeroMatrix( IsPlistMatrixRep, Integers, 2, 0 );;
gap> AddMatrixRowsLeft( M, 1, 2, 1 );;
gap> AddMatrixRowsRight( M, 2, 1, 1 );;
gap> MultMatrixRowLeft( M, 1, 2 );;
gap> SwapMatrixRows( M, 1, 2 );;
gap> Unpack( M );
[ [  ], [  ] ]

#
gap> STOP_TEST( "ElementaryMatricesPlist.tst" );
