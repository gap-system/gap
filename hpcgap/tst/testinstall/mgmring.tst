#############################################################################
##
#W  mgmring.tst                 GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  To be listed in testinstall.g
##
gap> START_TEST("mgmring.tst");
gap> r:= GF(3);;
gap> m:= Group( (1,2,3), (1,2) );;
gap> rm:= FreeMagmaRing( r, m );
<algebra-with-one over GF(3), with 2 generators>
gap> ElementOfMagmaRing( ElementsFamily( FamilyObj( rm ) ), 0*Z(3),
>    [ 0, 1, 1, 1, -1, 1, -1 ]*Z(3)^0,
>    [ (), (2,3), (1,2,3), (2,3), (1,2), (1,2), (1,3,2) ] );
(Z(3))*(2,3)+(Z(3)^0)*(1,2,3)+(Z(3))*(1,3,2)
gap> IsGroupRing( rm );
true
gap> centre:= Centre( rm );
<algebra-with-one of dimension 3 over GF(3)>
gap> GeneratorsOfAlgebra( centre );
[ (Z(3)^0)*(), (Z(3)^0)*(), (Z(3)^0)*(2,3)+(Z(3)^0)*(1,2)+(Z(3)^0)*(1,3), 
  (Z(3)^0)*(1,2,3)+(Z(3)^0)*(1,3,2) ]
gap> membrm:= Embedding( m, rm );;
gap> img:= Image( membrm, (1,2) );
(Z(3)^0)*(1,2)
gap> PreImagesRepresentative( membrm, img );
(1,2)
gap> rembrm:= Embedding( r, rm );;
gap> img:= Image( rembrm, Z(3) );
(Z(3))*()
gap> PreImagesRepresentative( rembrm, img );
Z(3)
gap> STOP_TEST( "mgmring.tst", 390000);

#############################################################################
##
#E
