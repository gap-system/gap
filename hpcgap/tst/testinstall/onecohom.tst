#############################################################################
##
#W  onecohom.tst                GAP tests                    Alexander Hulpke
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This  file  tests the automorphism routines
##
##  To be listed in testinstall.g
##
gap> START_TEST("onecohom.tst");
gap> g:=Group((16,18,17),(14,15)(17,18),(17,18),(13,14,15),
> (11,12)(13,15)(16,18,17),
> (10,12)(13,14),(8,9)(10,12),(7,8)(14,15)(16,18,17),
> (5,6)(7,9,8)(10,11,12)(13,15)(16,18,17),
> (4,6)(7,9,8)(10,12,11)(14,15)(16,17,18),
> (2,3)(4,5,6)(7,9,8)(11,12)(13,15)(16,18),
> (1,2,3)(10,12,11)(13,15,14),(1,9,4,18,12)(2,8,5,17,10)
> (3,7,6,16,11),(1,16,2,18)(3,17)(4,6)(7,8)(10,14,12,13,11,15));;
gap> n:=Group((10,12)(14,15),(10,11)(13,15),(10,12,11),(11,12),
> (11,12)(13,15,14)(16,18),(11,12)(13,15)(16,17,18),(5,6)(11,12),
> (4,5,6),(7,9),(4,6)(7,8)(10,12)(13,14)(17,18),(1,2),
> (1,3,2)(4,5,6)(8,9)(10,11)(14,15),(1,3)(4,5,6)(7,9,8)(13,15,14),
> (1,3)(7,8)(11,12)(13,15)(16,18,17),
> (1,3)(4,6,5)(8,9)(10,11)(17,18),(4,6,5)(7,8,9)(14,15)(17,18),
> (1,3)(7,8)(10,12)(13,15,14)(16,17));;
gap> Length(ComplementClassesRepresentatives(g,n));
2
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
gap> List(com,i->Number(com,j->RepresentativeAction(g,i,j)<>fail));
[ 1, 1, 1, 1 ]

# that's all, folks
gap> STOP_TEST( "onecohom.tst", 1);

#############################################################################
##
#E
