# Embryonic test for DirectProductElement objects, could be expanded.
gap> START_TEST("DirectProductElement.tst");

#
# empty DPEs
#
gap> dpe:=DirectProductElement([]);
DirectProductElement( [  ] )
gap> DirectProductElement(FamilyObj(dpe), []);
DirectProductElement( [  ] )

#
# arithmetic on DPEs
#
gap> numdpe1 := DirectProductElement([1,2]);
DirectProductElement( [ 1, 2 ] )
gap> numdpe2 := DirectProductElement([3,4]);
DirectProductElement( [ 3, 4 ] )

#
gap> numdpe1 + numdpe2;
DirectProductElement( [ 4, 6 ] )

#
gap> numdpe1 + 1;
DirectProductElement( [ 2, 3 ] )
gap> 1 + numdpe1;
DirectProductElement( [ 2, 3 ] )

#
gap> numdpe1 * 3;
DirectProductElement( [ 3, 6 ] )
gap> 3 * numdpe1;
DirectProductElement( [ 3, 6 ] )
gap> numdpe1 / 3;
DirectProductElement( [ 1/3, 2/3 ] )

#
gap> numdpe1 * [2, 3];
[ DirectProductElement( [ 2, 4 ] ), DirectProductElement( [ 3, 6 ] ) ]
gap> [2, 3] * numdpe1;
[ DirectProductElement( [ 2, 4 ] ), DirectProductElement( [ 3, 6 ] ) ]

#
gap> numdpe1 + [numdpe1, numdpe2];
[ DirectProductElement( [ 2, 4 ] ), DirectProductElement( [ 4, 6 ] ) ]
gap> [numdpe1, numdpe2] + numdpe1;
[ DirectProductElement( [ 2, 4 ] ), DirectProductElement( [ 4, 6 ] ) ]

# Using SymmetricGroup below specifically because its String() and
# PrintString() are different.
gap> adpe := DirectProductElement([SymmetricGroup(3), 1]);;
gap> String(adpe);
"DirectProductElement( [ SymmetricGroup( [ 1 .. 3 ] ), 1 ] )"
gap> PrintString(adpe);
"DirectProductElement( [ Group( \>[ (1,2,3), (1,2) ]\<\> )\<,\<\> 1 ] )"
gap> Display(adpe);
DirectProductElement( [ Group( [ (1,2,3), (1,2) ] ), 1 ] )

# verify bug #1824 (2) is fixed
gap> elt := DirectProductElement([1,1]);;
gap> IsFinite(elt);
true

#
# Test CanEasilyCompareElements for DPEs
#
gap> CanEasilyCompareElements(DirectProductElement([]));
true

#
gap> G:=SymmetricGroup(5);
Sym( [ 1 .. 5 ] )
gap> CanEasilyCompareElements(G);
true
gap> CanEasilyCompareElements(G.1);
true
gap> D := DirectProduct(G, G);;
gap> CanEasilyCompareElements(D);
true
gap> CanEasilyCompareElements(D.1);
true

#
gap> H:=Image(IsomorphismFpGroup(G));;
gap> CanEasilyCompareElements(H);
false
gap> CanEasilyCompareElements(H.1);
false
gap> D2 := DirectProduct(H, H);;
gap> CanEasilyCompareElements(D2);
false
gap> CanEasilyCompareElements(D2.1);
false

#
# component access
#
gap> dpe := DirectProductElement([(1,2), (3,4)]);
DirectProductElement( [ (1,2), (3,4) ] )
gap> dpe[1];
(1,2)
gap> dpe[2];
(3,4)
gap> dpe[3];
Error, <index> too large for <dpelm>, you may return another index

#
# IsGeneratorsOfMagmaWithInverses for DPEs
#
gap> coll:=[dpe];;
gap> IsDirectProductElementCollection(coll);
true
gap> IsGeneratorsOfMagmaWithInverses( [ dpe ] );
true
gap> IsGeneratorsOfMagmaWithInverses( [ numdpe1 ] );
#I  no groups of cyclotomics allowed because of incompatible ^
false

#
# AdditiveInverseOp, ZeroOp
#
gap> numdpe := DirectProductElement([1,2]);
DirectProductElement( [ 1, 2 ] )
gap> -numdpe;
DirectProductElement( [ -1, -2 ] )
gap> Zero(numdpe);
DirectProductElement( [ 0, 0 ] )

#
gap> STOP_TEST("DirectProductElement.tst");
