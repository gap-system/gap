#@local e, v, w, M, v2, z, en, q, l
gap> START_TEST( "matobjplist.tst" );

#
gap> e:= MakeIsPlistVectorRep( Integers, [], true );;
gap> MakeIsPlistVectorRep( Integers, [ 1 .. 4 ], true );;
Error, <list> must be in 'IsPlistRep'
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
gap> MakeIsPlistMatrixRep( Integers, [], 2, [], true );;
Error, <emptyvector> must be in 'IsPlistVectorRep'
gap> M:= MakeIsPlistMatrixRep( Integers, e, 2, [], true );;
gap> MakeIsPlistMatrixRep( Rationals, e, 2, [], true );;
Error, <emptyvector> must have the given base domain
gap> MakeIsPlistMatrixRep( Integers, e, 1, [ v ], true );;
gap> MakeIsPlistMatrixRep( Integers, e, 2, [ v ], true );;
Error, the entries of <list> must have length <ncols>
gap> MakeIsPlistMatrixRep( Integers, e, 2, [ [ 1, 2 ] ], true );;
Error, the entries of <list> must be in 'IsPlistVectorRep'
gap> MakeIsPlistMatrixRep( Integers, e, 1, [ w ], true );;
Error, the entries of <list> must have the given base domain

#
gap> NewVector( IsPlistVectorRep, Integers, [] );;
gap> v2:= NewVector( IsPlistVectorRep, Integers, [ 1, 0 ] );;
gap> IsMutable( v2 );
true
gap> NewVector( IsPlistVectorRep, Integers, [ 1/2 ] );;
Error, the elements in <list> must lie in <basedomain>

#
gap> NewZeroVector( IsPlistVectorRep, Integers, 0 );
<plist vector over Integers of length 0>

#
gap> NewMatrix( IsPlistMatrixRep, Integers, 2, [] );;
gap> NewMatrix( IsPlistMatrixRep, Integers, 2, [ 1 ] );;
Error, NewMatrix: Length of <list> is not a multiple of <ncols>
gap> NewMatrix( IsPlistMatrixRep, Integers, 2, [ [ 1 ] ] );;
Error, the entries of <list> must have length <ncols>
gap> NewMatrix( IsPlistMatrixRep, Integers, 2, [ [ 1, 2 ] ] );;
gap> NewMatrix( IsPlistMatrixRep, Integers, 2, [ v ] );;
Error, the entries of <list> must have length <ncols>
gap> M:= NewMatrix( IsPlistMatrixRep, Integers, 2, [ v2, v2 ] );;
gap> IsMutable( M ) and ForAll( [ 1 .. Length( M ) ], i -> IsMutable( M[i] ) );
true

#
gap> NewZeroMatrix( IsPlistMatrixRep, Integers, 0, 0 );
<0x0-matrix over Integers>
gap> NewZeroMatrix( IsPlistMatrixRep, Integers, 2, 0 );
<2x0-matrix over Integers>
gap> NewZeroMatrix( IsPlistMatrixRep, Integers, 0, 3 );
<0x3-matrix over Integers>
gap> M:= NewZeroMatrix( IsPlistMatrixRep, Integers, 2, 3 );
<2x3-matrix over Integers>
gap> IsMutable( M ) and ForAll( [ 1 .. Length( M ) ], i -> IsMutable( M[i] ) );
true

#
gap> NewIdentityMatrix( IsPlistMatrixRep, Integers, 0 );
<0x0-matrix over Integers>
gap> M:= NewIdentityMatrix( IsPlistMatrixRep, Integers, 2 );
<2x2-matrix over Integers>
gap> IsMutable( M ) and ForAll( [ 1 .. Length( M ) ], i -> IsMutable( M[i] ) );
true

#
# special filters and families
#
gap> v:= NewVector( IsPlistVectorRep, Integers, [ 1, 2, 0 ] );
<plist vector over Integers of length 3>
gap> IsMutable( v );
true
gap> IsIntVector( v );
true
gap> IsFFEVector( v );
false
gap> IsCyclotomicCollection( v );
true
gap> IsFFECollection( v );
false

#
gap> v:= NewVector( IsPlistVectorRep, GF(257), Z(257)^0 * [ 1, 2, 0 ] );
<plist vector over GF(257) of length 3>
gap> IsMutable( v );
true
gap> IsIntVector( v );
false
gap> IsFFEVector( v );
true
gap> IsCyclotomicCollection( v );
false
gap> IsFFECollection( v );
true

#
gap> M:= NewZeroMatrix( IsPlistMatrixRep, Integers, 2, 3 );
<2x3-matrix over Integers>
gap> IsMutable( M );
true
gap> IsCyclotomicCollColl( M );
true
gap> IsFFECollColl( M );
false

#
gap> M:= NewZeroMatrix( IsPlistMatrixRep, GF(257), 2, 3 );
<2x3-matrix over GF(257)>
gap> IsMutable( M );
true
gap> IsCyclotomicCollColl( M );
false
gap> IsFFECollColl( M );
true

#
# ImmutableMatrix compresses rows that are vector objects
#
gap> for q in [ 2, 9, 257 ] do
>      l:= [ NewVector( IsPlistVectorRep, GF(q), [ Z(q), 0*Z(q) ] ),
>            NewVector( IsPlistVectorRep, GF(q), [ 0*Z(q), Z(q)^0 ] ) ];
>      for M in [ ImmutableMatrix( GF(q), l ),
>                 ImmutableMatrix( GF(q), List( l, Immutable ) ) ] do
>        if M <> ImmutableMatrix( GF(q), List( l, Unpack ) ) or IsMutable( M )
>           or ( q < 257 and not ( IsGF2MatrixRep( M ) or Is8BitMatrixRep( M ) ) )
>        then
>          Print( "wrong result for q = ", q, "\n" );
>        fi;
>      od;
>    od;

#
# positions in the enumerator of a full row space over a finite field
#
gap> en:= Enumerator( GF(9)^3 );;
gap> v:= NewVector( IsPlistVectorRep, GF(9), [ Z(9), 0*Z(9), Z(9)^0 ] );;
gap> PositionCanonical( en, v ) = PositionCanonical( en, Unpack( v ) );
true
gap> en[ PositionCanonical( en, v ) ] = Unpack( v );
true

#
gap> STOP_TEST( "matobjplist.tst" );
