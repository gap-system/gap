#@local F, matobj, mat
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

# The same for IsPackedMatrixRep.
gap> F:= GF(2);;  mat:= IdentityMat( 2, F );;
gap> matobj:= Matrix( IsPackedMatrixRep, F, [ [ 1, 1 ], [ 0, 1 ] ] * One( F ) );;
gap> matobj * mat;
Error, <matobj> * <mat> is not defined
gap> mat * matobj;
Error, <mat> * <matobj> is not defined
gap> for F in [ GF(2), GF(7), GF(257), Integers mod 6 ] do
>      matobj := Matrix( IsPackedMatrixRep, F, [ [ 1, 1 ], [ 0, 1 ] ] * One( F ) );
>      Print( Unpack( matobj^2 ) = Unpack( matobj )^2, " ",
>             Unpack( matobj^5 ) = Unpack( matobj )^5, " ",
>             IsOne( matobj^0 ), "\n" );
>    od;
true true true
true true true
true true true
true true true

#
gap> STOP_TEST( "arith.tst" );
