#############################################################################
##
#W  alghom.tst                  GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1998,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("alghom.tst");

# An example of a non-homomorphism which is total but not single-valued.
gap> q:= QuaternionAlgebra( Rationals );
<algebra-with-one of dimension 4 over Rationals>
gap> gensq:= GeneratorsOfAlgebra( q );
[ e, i, j, k ]
gap> f:= FullMatrixAlgebra( Rationals, 2 );
( Rationals^[ 2, 2 ] )
gap> b:= Basis( f );
CanonicalBasis( ( Rationals^[ 2, 2 ] ) )
gap> map:= AlgebraGeneralMappingByImages( q, f, gensq, b );;
gap> ker:= KernelOfAdditiveGeneralMapping( map );;
gap> Dimension( ker );
4
gap> coker:= CoKernelOfAdditiveGeneralMapping( map );;
gap> Dimension( coker );
4
gap> IsTotal(map);
true
gap> IsSingleValued(map);
false

# A non-homomorphism which is single-valued but not total
gap> map:= AlgebraGeneralMappingByImages( q, f, gensq{[1]}, b{[1]} );;
gap> ker:= KernelOfAdditiveGeneralMapping( map );;
gap> Dimension( ker );
0
gap> coker:= CoKernelOfAdditiveGeneralMapping( map );;
gap> Dimension( coker );
0
gap> IsTotal(map);
false
gap> IsSingleValued(map);
true

# A non-homomorphism which is neither single-valued nor total
gap> map:= AlgebraGeneralMappingByImages( q, f, gensq{[1,2]}, b{[1,2]} );;
gap> ker:= KernelOfAdditiveGeneralMapping( map );;
gap> Dimension( ker );
2
gap> coker:= CoKernelOfAdditiveGeneralMapping( map );;
gap> Dimension( coker );
2
gap> IsTotal(map);
false
gap> IsSingleValued(map);
false

# An example of an algebra-with-one homomorphism.
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [1,1] );
gap> SetEntrySCTable( T, 2, 2, [1,2] );
gap> A:= AlgebraByStructureConstants( Rationals, T );;
gap> C:= CanonicalBasis( A );;
gap> A:= AsAlgebraWithOne( Rationals, A );;
gap> IsomorphismFpAlgebra( A );;
gap> m1:= NullMat( 2, 2 );; m1[1][1]:= 1;;
gap> m2:= NullMat( 2, 2 );; m2[2][2]:= 1;;
gap> B:= AlgebraByGenerators( Rationals, [ m1, m2 ] );;
gap> B:= AsAlgebraWithOne( Rationals, B );;
gap> f:= AlgebraWithOneHomomorphismByImages( A, B, [ C[2] ], [ m2 ] );
[ v.2, v.1+v.2 ] -> [ [ [ 0, 0 ], [ 0, 1 ] ], [ [ 1, 0 ], [ 0, 1 ] ] ]
gap> IsBijective( f );
true
gap> P := PolynomialRing(Rationals, 3);;
gap> x:=P.1;;y:=P.2;;z:=P.3;;
gap> pols:=[ x^3-3*x-1, x^2+x*y+y^2-3, x+y+z ];;
gap> I := Ideal(P, pols);;
gap> pr := NaturalHomomorphismByIdeal(P, I);;
gap> IsZero(Image(pr,x));
false
gap> STOP_TEST( "alghom.tst", 660000);

#############################################################################
##
#E
