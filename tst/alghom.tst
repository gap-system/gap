#############################################################################
##
#W  alghom.tst                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");


# An example of a non-homomorphism.
gap> q:= QuaternionAlgebra( Rationals );
<algebra-with-one of dimension 4 over Rationals>
gap> f:= FullMatrixAlgebra( Rationals, 2 );
<algebra-with-one over Rationals, with 2 generators>
gap> gensq:= GeneratorsOfAlgebra( q );
[ e, i, j, k ]
gap> b:= Basis( f );
CanonicalBasis( <algebra-with-one over Rationals, with 2 generators> )
gap> map:= AlgebraGeneralMappingByImages( q, f, gensq, b );;
gap> ker:= KernelOfAdditiveGeneralMapping( map );
<algebra over Rationals, with 60 generators>
gap> Dimension( ker );
4
gap> coker:= CoKernelOfAdditiveGeneralMapping( map );
<algebra over Rationals, with 60 generators>
gap> Dimension( coker );
4


# An example of an algebra-with-one homomorphism.
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [1,1] );
gap> SetEntrySCTable( T, 2, 2, [1,2] );
gap> A:= AlgebraByStructureConstants( Rationals, T );;
gap> C:= CanonicalBasis( A );;
gap> A:= AsAlgebraWithOne( Rationals, A );;
gap> IsomorphismFpAlgebra( A );;
gap> m1:= MutableNullMat( 2, 2 );; m1[1][1]:= 1;;
gap> m2:= MutableNullMat( 2, 2 );; m2[2][2]:= 1;;
gap> B:= AlgebraByGenerators( Rationals, [ m1, m2 ] );;
gap> B:= AsAlgebraWithOne( Rationals, B );;
gap> f:= AlgebraWithOneHomomorphismByImages( A, B, [ C[2] ], [ m2 ] );
[ v.2, v.1+v.2 ] -> [ [ [ 0, 0 ], [ 0, 1 ] ], [ [ 1, 0 ], [ 0, 1 ] ] ]
gap> IsBijective( f );
true


gap> STOP_TEST( "alghom.tst", 33000000 );


#############################################################################
##
#E  alghom.tst  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
