#############################################################################
##
#W  ctblmoli.tst               GAP Library                      Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");

gap> psi:= Irr( CharacterTable( "A5" ) )[3];;
gap> molser:= MolienSeries( psi );
( 1-z^2-z^3+z^6+z^7-z^9 ) / ( (1-z^5)*(1-z^3)*(1-z^2)^2 )
gap> List( [ 1 .. 10 ], i -> ValueMolienSeries( molser, i ) );
[ 0, 1, 0, 1, 0, 2, 0, 2, 0, 3 ]


gap> y:= E(3);; z:= E(3)^2;;
gap> G:= Group(
>            [ [ 0, y, 0, 0, 0, 0 ],
>              [ z, 0, 0, 0, 0, 0 ],
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


gap> STOP_TEST( "unknown.tst", 100000 );

#############################################################################
##
#E  ctblmoli.tst  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



