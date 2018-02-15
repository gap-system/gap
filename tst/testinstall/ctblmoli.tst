#############################################################################
##
#W  ctblmoli.tst               GAP Library                      Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("ctblmoli.tst");

#
gap> G:= AlternatingGroup( 5 );;
gap> psi:= First( Irr( G ), x -> Degree( x ) = 3 );;
gap> molser:= MolienSeries( psi );
( 1-z^2-z^3+z^6+z^7-z^9 ) / ( (1-z^5)*(1-z^3)*(1-z^2)^2 )
gap> List( [ 0 .. 20 ], i -> ValueMolienSeries( molser, i ) );
[ 1, 0, 1, 0, 1, 0, 2, 0, 2, 0, 3, 0, 4, 0, 4, 1, 5, 1, 6, 1, 7 ]
gap> m2:=MolienSeriesWithGivenDenominator( molser, [ 2, 6, 10 ] );
( 1+z^15 ) / ( (1-z^10)*(1-z^6)*(1-z^2) )
gap> ForAll( [ 0 .. 20 ], i -> ValueMolienSeries( molser, i ) = ValueMolienSeries( m2, i ) );
true
gap> molser = m2;
true

#
gap> y:= E(3);; x:= E(3)^2;;
gap> G:= Group(
>            [ [ 0, y, 0, 0, 0, 0 ],
>              [ x, 0, 0, 0, 0, 0 ],
>              [ 0, 0, 1, 0, 0, 0 ],
>              [ 0, 0, 0, 1, 0, 0 ],
>              [ 0, 0, 0, 0, 1, 0 ],
>              [ 0, 0, 0, 0, 0, 1 ] ],
>            PermutationMat( (1,2), 6, Rationals ),
>            PermutationMat( (2,3), 6, Rationals ),
>            PermutationMat( (3,4), 6, Rationals ),
>            PermutationMat( (4,5), 6, Rationals ) );;
gap> Size( G );
9720
gap> MolienSeries( NaturalCharacter( G ) );
( 1 ) / ( (1-z^12)*(1-z^9)*(1-z^6)*(1-z^5)*(1-z^3)*(1-z) )

##  bug 7 for fix 5
gap> tbl:= CharacterTable( SL(2,3) );;  irr:= Irr( tbl );;
gap> lin:= Filtered( LinearCharacters( tbl ), x -> Order(x) = 3 );;
gap> deg3:= First( irr, x -> DegreeOfCharacter( x ) = 3 );;
gap> MolienSeries( tbl, lin[1] + deg3, lin[2] );
( 2*z^2+z^3-z^4+z^6 ) / ( (1-z^3)^2*(1-z^2)^2 )

##  bug 4 for fix 6
gap> tbl:= CharacterTable( SL(2,3) );;  irr:= Irr( tbl );;
gap> lin := Filtered( LinearCharacters( tbl ), x -> Order(x) = 3 );;
gap> deg3 := First( irr, x -> DegreeOfCharacter( x ) = 3 );;
gap> ser := MolienSeries( tbl, lin[1] + deg3, lin[2] );;
gap> ser2 := MolienSeriesWithGivenDenominator( ser, [ 6,6,4,4 ] );
( 2*z^2+z^3+3*z^4+6*z^5+3*z^6+7*z^7+7*z^8+3*z^9+6*z^10+4*z^11+z^12+3*z^13+z^14\
+z^16 ) / ( (1-z^6)^2*(1-z^4)^2 )
gap> ForAll( [ 0 .. 20 ], i -> ValueMolienSeries( ser, i ) = ValueMolienSeries( ser2, i ) );
true
gap> ser = ser2;
true

#
# the following test comes from https://github.com/gap-system/gap/issues/300
# this used to give a wrong value for ValueMolienSeries(m,0) of 26/27 instead
# of the correct value 1
#
gap> g:=SymplecticGroup(6,3);;
gap> h:=Stabilizer(g,Z(3)*[1,0,0,0,0,0]);;
gap> t:=CharacterTable(h);;
gap> chi:=Irr(t)[7];;
gap> chi[1];
9
gap> m:=MolienSeries(t,chi);;
gap> List( [ 0 .. 20 ], i -> ValueMolienSeries( m, i ) );
[ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 5, 0, 0 ]
gap> List( [ 0,3 .. 48 ], i -> ValueMolienSeries( m, i ) );
[ 1, 0, 0, 0, 2, 0, 5, 0, 13, 3, 33, 15, 87, 58, 203, 178, 472 ]

#
gap> STOP_TEST( "ctblmoli.tst", 1);

#############################################################################
##
#E
