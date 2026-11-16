#@local F, matobj, mat, q, M, v, r
gap> START_TEST( "arith.tst" );

# Multiplying non-list 'IsMatrixObj' with 'IsMatrix' and v. v. are not defined.
gap> F:= GF(2);;
gap> matobj:= Matrix( IsPlistMatrixRep, F, [ [ 1, 1 ], [ 0, 1 ] ] * One( F ) );;
gap> IsMatrixObj( matobj );  IsMatrix( matobj );
true
false
gap> mat:= IdentityMat( 2, F );;
gap> IsMatrixObj( mat );  IsMatrix( mat );
false
true
gap> matobj * mat;
Error, <matobj> * <mat> is not defined
gap> mat * matobj;
Error, <mat> * <matobj> is not defined

# Powering matrices works.
gap> mat:= Matrix( Integers, [ [ 1, 1 ], [ 0, 1 ] ] );;
gap> Unpack( mat^2 ) = Unpack( mat )^2;
true
gap> mat:= Matrix( Rationals, [ [ 1, 1 ], [ 0, 1 ] ] );;
gap> Unpack( mat^2 ) = Unpack( mat )^2;
true

# Matrix objects act on compressed vectors.
gap> for q in [ 2, 4 ] do
>      M:= Matrix( IsPlistMatrixRep, GF(q), Z(q)^0 * [ [ 1, 1 ], [ 0, 1 ] ] );
>      v:= ImmutableVector( GF(q), Z(q) * [ 1, 0 ] );
>      for r in [ v * M, M * v, v ^ M ] do
>        if not ( IsDataObjectRep( r ) and Length( r ) = 2 ) then
>          Error( "wrong result" );
>        fi;
>      od;
>      if v * M <> Unpack( v ) * Unpack( M ) or
>         M * v <> Unpack( M ) * Unpack( v ) then
>        Error( "wrong product" );
>      fi;
>    od;

#
gap> STOP_TEST( "arith.tst" );
