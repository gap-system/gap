#@local ordtbl, modtbl, irr, chi, const, const2, ibr, phi
gap> START_TEST( "ctblfuns.tst" );

#
gap> ordtbl:= CharacterTable( GL(2,3) );;
gap> modtbl:= ordtbl mod 2;;
gap> irr:= Irr( ordtbl );;
gap> chi:= First( irr, x -> x[1] = 2 and not ForAll( x, IsInt ) );;
gap> chi:= chi * chi;;
gap> const:= ConstituentsOfCharacter( chi );;
gap> SortedList( List( const, Degree ) );
[ 1, 3 ]
gap> const2:= ConstituentsOfCharacter( -chi );;
gap> const = const2;
true
gap> const2:= ConstituentsOfCharacter( ordtbl, chi );;
gap> const = const2;
true
gap> const2:= ConstituentsOfCharacter( ordtbl, ValuesOfClassFunction( chi ) );;
gap> const = const2;
true
gap> ibr:= Irr( modtbl );;
gap> phi:= First( ibr, x -> x[1] = 2 );;
gap> phi:= phi * phi;;
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
gap> FrobeniusCharacterValue( E(7), 7 );
fail
gap> FrobeniusCharacterValue( 1/7, 7 );
fail
gap> FrobeniusCharacterValue( 1, 7 );
Z(7)^0
gap> FrobeniusCharacterValue( 7*E(5), 7 );
0*Z(7)
gap> FrobeniusCharacterValue( E(23), 2 );
Z(2^11)^89
gap> FrobeniusCharacterValue( E(19), 97 );
#I  the Conway polynomial of degree 18 for p = 97 is not known
fail
gap> FrobeniusCharacterValue( 82*E(16)+E(16)^5, 269 );
0*Z(269)
gap> FrobeniusCharacterValue( E(16), 269 );
162+256z+143z2+219z3

# Dixon-Schneider test that also exercises MatrixObjects over Z/nZ
gap> Irr(MathieuGroup(24));;

#
gap> STOP_TEST( "ctblfuns.tst" );
