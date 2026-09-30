#@local R, m, s
gap> START_TEST( "ElementaryMatricesZmodnZ.tst" );

# elementary operations reduce the entries and check only the scalar
gap> R:= Integers mod 6;;
gap> m:= Matrix( IsZmodnZMatrixRep, R, [ [ 1, 2, 3 ], [ 4, 5, 0 ] ] );;
gap> AddMatrixRowsLeft( m, 1, 2, 5 * One( R ) );
gap> AddMatrixRowsRight( m, 2, 1, 7 );
gap> MultMatrixRowLeft( m, 1, 5 * One( R ) );
gap> MultMatrixRowRight( m, 2, -1 );
gap> AddMatrixColumnsLeft( m, 3, 1, 4 * One( R ) );
gap> AddMatrixColumnsRight( m, 1, 2, -2 );
gap> MultMatrixColumnLeft( m, 2, 5 );
gap> MultMatrixColumnRight( m, 3, 5 * One( R ) );
gap> SwapMatrixRows( m, 1, 2 );
gap> SwapMatrixColumns( m, 1, 3 );
gap> m = Matrix( IsZmodnZMatrixRep, R, [ [ 1, 2, 3 ], [ 3, 3, 3 ] ] );
true
gap> s:= ZmodnZObj( 5, 12 );;
gap> MultMatrixRowLeft( m, 1, s );
Error, <s> must be an integer or in the base domain of <m>
gap> AddMatrixColumnsRight( m, 1, 2, 1/2 );
Error, <s> must be an integer or in the base domain of <m>
gap> MultMatrixRowLeft( m, 1, s : check := false );
gap> m = Matrix( IsZmodnZMatrixRep, R, [ [ 5, 4, 3 ], [ 3, 3, 3 ] ] );
true
gap> AddMatrixRowsLeft( m, 1, 3, 1 );
Error, List Element: <list>[3] must have an assigned value
gap> SwapMatrixColumns( m, 4, 1 );
Error, List Element: <list>[4] must have an assigned value
gap> MultMatrixRowLeft( MakeImmutable( m ), 1, 1 );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `MultMatrixRowLeft' on 3 arguments

# a row whose entry list is a range
gap> R:= Integers mod 8;;
gap> m:= Matrix( [ NewVector( IsZmodnZVectorRep, R, [ 0 .. 2 ] ),
>                  NewVector( IsZmodnZVectorRep, R, [ 4, 5, 6 ] ) ], 3,
>                ZeroMatrix( IsZmodnZMatrixRep, R, 1, 3 ) );;
gap> AddMatrixRowsLeft( m, 2, 1, 3 );
gap> AddMatrixRowsLeft( m, 1, 2, 3 );
gap> MultMatrixRowLeft( m, 1, 2 );
gap> m = Matrix( IsZmodnZMatrixRep, R, [ [ 0, 2, 4 ], [ 4, 0, 4 ] ] );
true

#
gap> STOP_TEST( "ElementaryMatricesZmodnZ.tst" );
