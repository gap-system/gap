#############################################################################
##
#W  ctblsymm.tst               GAP Library                      Thomas Breuer
##
##
#Y  Copyright (C)  2018,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST( "ctblsymm.tst" );

#
gap> c3:= CharacterTable( CyclicGroup( 3 ) );;
gap> n:= 3;;
gap> wr:= CharacterTableWreathSymmetric( c3, n );;
gap> irr:= Irr( wr );;
gap> for i in [ 1 .. Length( irr ) ] do
>      betas:= List( CharacterParameters( wr )[i], BetaSet );
>      if List( ClassParameters( wr ), 
>               c -> CharacterValueWreathSymmetric( c3, n, betas, c ) ) 
>         <> irr[i] then
>        Error( "wrong result!" );
>      fi;
>    od;

#
gap> STOP_TEST( "ctblsymm.tst" );

#############################################################################
##
#E

