#@local ordtbl, modtbl, irr, chi, const, ibr, phi
gap> START_TEST( "ctblfuns.tst" );

#
gap> ordtbl:= CharacterTable( GL(2,3) );;
gap> modtbl:= ordtbl mod 2;;
gap> irr:= Irr( ordtbl );;
gap> chi:= irr[5] * irr[5];;
gap> const:= ConstituentsOfCharacter( chi );;
gap> List( const, ValuesOfClassFunction );
[ [ 1, 1, 1, 1, 1, -1, -1, -1 ], [ 3, 0, 3, 0, -1, -1, -1, 1 ] ]
gap> const:= ConstituentsOfCharacter( -chi );;
gap> List( const, ValuesOfClassFunction );
[ [ 1, 1, 1, 1, 1, -1, -1, -1 ], [ 3, 0, 3, 0, -1, -1, -1, 1 ] ]
gap> const:= ConstituentsOfCharacter( ordtbl, chi );;
gap> List( const, ValuesOfClassFunction );
[ [ 1, 1, 1, 1, 1, -1, -1, -1 ], [ 3, 0, 3, 0, -1, -1, -1, 1 ] ]
gap> const:= ConstituentsOfCharacter( ordtbl, ValuesOfClassFunction( chi ) );;
gap> List( const, ValuesOfClassFunction );
[ [ 1, 1, 1, 1, 1, -1, -1, -1 ], [ 3, 0, 3, 0, -1, -1, -1, 1 ] ]
gap> ibr:= Irr( modtbl );;
gap> phi:= ibr[2] * ibr[2];;
gap> const:= ConstituentsOfCharacter( phi );;
gap> List( const, ValuesOfClassFunction );
[ [ 1, 1 ], [ 2, -1 ] ]
gap> const:= ConstituentsOfCharacter( -phi );;
gap> List( const, ValuesOfClassFunction );
[ [ 1, 1 ], [ 2, -1 ] ]
gap> const:= ConstituentsOfCharacter( modtbl, phi );;
gap> List( const, ValuesOfClassFunction );
[ [ 1, 1 ], [ 2, -1 ] ]
gap> const:= ConstituentsOfCharacter( modtbl, ValuesOfClassFunction( phi ) );;
gap> List( const, ValuesOfClassFunction );
[ [ 1, 1 ], [ 2, -1 ] ]

#
gap> STOP_TEST( "ctblfuns.tst" );
