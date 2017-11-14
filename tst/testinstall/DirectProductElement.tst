# Embryonic test for DirectProductElement objects, could be expanded.
gap> START_TEST("DirectProductElement.tst");

#
gap> numdpe1 := DirectProductElement([1,2]);
DirectProductElement( [ 1, 2 ] )
gap> numdpe2 := DirectProductElement([3,4]);
DirectProductElement( [ 3, 4 ] )
gap> numdpe1 + numdpe2;
DirectProductElement( [ 4, 6 ] )
gap> numdpe1 / 3;
DirectProductElement( [ 1/3, 2/3 ] )
gap> numdpe1 * [2, 3];
[ DirectProductElement( [ 2, 4 ] ), DirectProductElement( [ 3, 6 ] ) ]
gap> numdpe1 + [numdpe1, numdpe2];
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
gap> STOP_TEST("DirectProductElement.tst");
