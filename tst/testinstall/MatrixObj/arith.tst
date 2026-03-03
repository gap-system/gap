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

#
gap> STOP_TEST( "arith.tst" );
