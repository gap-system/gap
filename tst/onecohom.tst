#############################################################################
##
#W  onecohom.tst                GAP tests                    Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  tests the automorphism routines
##

gap> START_TEST("$Id$");
gap> g:=PerfectGroup(IsPermGroup,120,1);;
gap> n:=Filtered(NormalSubgroups(g),i->IsElementaryAbelian(i) and Size(i)>1)[1];;
gap> ocr:=OneCocycles(g,n);;
gap> ocr.isSplitExtension;
false
gap> Size(ocr.oneCoboundaries);
1
gap> Size(ocr.oneCocycles);
1
gap> g:=PerfectGroup(IsPermGroup,960,1);;
gap> n:=Filtered(NormalSubgroups(g),i->IsElementaryAbelian(i) and Size(i)>1)[1];;
gap> ocr:=OneCocycles(g,n);;
gap> ocr.isSplitExtension;
true
gap> Size(ocr.complement);
60
gap> Size(Intersection(ocr.complement,n));
1
gap> Size(ocr.oneCoboundaries);
16
gap> Size(ocr.oneCocycles);
64
gap> b:=BaseSteinitzVectors(BasisVectors(Basis(ocr.oneCocycles)),BasisVectors(Basis(ocr.oneCoboundaries)));;
gap> b:=AsList(VectorSpace(GF(2),b.factorspace));;
gap> com:=List(b,ocr.cocycleToComplement);;
gap> List(com,Size);
[ 60, 60, 60, 60 ]
gap> List(com,i->Number(com,j->RepresentativeOperation(g,i,j)<>fail));
[ 1, 1, 1, 1 ]

# that's all, folks
gap> STOP_TEST( "onecohom.tst", 118948251 );

#############################################################################
##
#E  onecohom.tst  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
