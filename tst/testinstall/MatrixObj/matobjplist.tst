#@local e, v, w, M, v2, z
gap> START_TEST( "matobjplist.tst" );

#
gap> e:= MakeIsPlistVectorRep( Integers, [], true );;
gap> v:= MakeIsPlistVectorRep( Integers, [ 1 ], true );;
gap> MakeIsPlistVectorRep( Integers, [ 1/2 ], true );;
Error, the elements in <list> must lie in <basedomain>
gap> w:= MakeIsPlistVectorRep( Rationals, [ 1 ], true );;
gap> MakeIsPlistVectorRep( Rationals, [ Z(2) ], true );;
Error, the elements in <list> must lie in <basedomain>
gap> MakeIsPlistVectorRep( GF(2), [ Z(2) ], true );;
gap> MakeIsPlistVectorRep( GF(2), [ Z(4) ], true );;
Error, the elements in <list> must lie in <basedomain>
gap> MakeIsPlistVectorRep( GF(4), [ Z(2) ], true );;

#
gap> MakeIsRowPlistMatrixRep( Integers, [], 2, [], true );;
Error, <emptyvector> must be in 'IsPlistVectorRep'
gap> M:= MakeIsRowPlistMatrixRep( Integers, e, 2, [], true );;
gap> MakeIsRowPlistMatrixRep( Rationals, e, 2, [], true );;
Error, <emptyvector> must have the given base domain
gap> MakeIsRowPlistMatrixRep( Integers, e, 1, [ v ], true );;
gap> MakeIsRowPlistMatrixRep( Integers, e, 2, [ v ], true );;
Error, the entries of <list> must have length <ncols>
gap> MakeIsRowPlistMatrixRep( Integers, e, 2, [ [ 1, 2 ] ], true );;
Error, the entries of <list> must be in 'IsPlistVectorRep'
gap> MakeIsRowPlistMatrixRep( Integers, e, 1, [ w ], true );;
Error, the entries of <list> must have the given base domain

#
gap> NewVector( IsPlistVectorRep, Integers, [] );;
gap> v2:= NewVector( IsPlistVectorRep, Integers, [ 1, 0 ] );;
gap> IsMutable( v2 );
true
gap> NewVector( IsPlistVectorRep, Integers, [ 1/2 ] );;
Error, the elements in <list> must lie in <basedomain>

#
gap> NewZeroVector( IsPlistVectorRep, Integers, 0 );;
gap> z:= NewZeroVector( IsPlistVectorRep, Integers, 1 );;
gap> IsMutable( z );
true

#
gap> NewMatrix( IsRowPlistMatrixRep, Integers, 2, [] );;
gap> NewMatrix( IsRowPlistMatrixRep, Integers, 2, [ 1 ] );;
Error, NewMatrix: Length of <list> is not a multiple of <ncols>
gap> NewMatrix( IsRowPlistMatrixRep, Integers, 2, [ [ 1 ] ] );;
Error, the entries of <list> must have length <ncols>
gap> NewMatrix( IsRowPlistMatrixRep, Integers, 2, [ [ 1, 2 ] ] );;
gap> NewMatrix( IsRowPlistMatrixRep, Integers, 2, [ v ] );;
Error, the entries of <list> must have length <ncols>
gap> M:= NewMatrix( IsRowPlistMatrixRep, Integers, 2, [ v2, v2 ] );;
gap> IsMutable( M ) and ForAll( [ 1 .. Length( M ) ], i -> IsMutable( M[i] ) );
true

#
gap> NewZeroMatrix( IsRowPlistMatrixRep, Integers, 0, 0 );;
gap> NewZeroMatrix( IsRowPlistMatrixRep, Integers, 2, 0 );;
gap> NewZeroMatrix( IsRowPlistMatrixRep, Integers, 0, 3 );;
gap> M:= NewZeroMatrix( IsRowPlistMatrixRep, Integers, 2, 3 );;
gap> IsMutable( M ) and ForAll( [ 1 .. Length( M ) ], i -> IsMutable( M[i] ) );
true

#
gap> NewIdentityMatrix( IsRowPlistMatrixRep, Integers, 0 );;
gap> M:= NewIdentityMatrix( IsRowPlistMatrixRep, Integers, 2 );;
gap> IsMutable( M ) and ForAll( [ 1 .. Length( M ) ], i -> IsMutable( M[i] ) );
true

#
gap> STOP_TEST( "matobjplist.tst" );
