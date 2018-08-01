#############################################################################
##
#W  ctbl.tst                   GAP Library                      Thomas Breuer
##
##
#Y  Copyright (C)  1998,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("ctbl.tst");

# `ClassPositionsOf...' for the trivial group (which usually causes trouble)
gap> g:= TrivialGroup( IsPermGroup );;
gap> t:= CharacterTable( g );;
gap> ClassPositionsOfAgemo( t, 2 );
[ 1 ]
gap> ClassPositionsOfCentre( t );
[ 1 ]
gap> ClassPositionsOfDerivedSubgroup( t );
[ 1 ]
gap> ClassPositionsOfDirectProductDecompositions( t );
[  ]
gap> ClassPositionsOfElementaryAbelianSeries( t );
[ [ 1 ] ]
gap> ClassPositionsOfFittingSubgroup( t );
[ 1 ]
gap> ClassPositionsOfLowerCentralSeries( t );
[ [ 1 ] ]
gap> ClassPositionsOfMaximalNormalSubgroups( t );
[  ]
gap> ClassPositionsOfNormalClosure( t, [ 1 ] );
[ 1 ]
gap> ClassPositionsOfNormalSubgroups( t );
[ [ 1 ] ]
gap> ClassPositionsOfUpperCentralSeries( t );
[ [ 1 ] ]
gap> ClassPositionsOfSolvableResiduum( t );
[ 1 ]
gap> ClassPositionsOfSupersolvableResiduum( t );
[ 1 ]
gap> ClassPositionsOfCentre( TrivialCharacter( t ) );
[ 1 ]
gap> ClassPositionsOfKernel( TrivialCharacter( t ) );
[ 1 ]

# viewing and printing of character tables with stored groups
gap> t:= CharacterTable( DihedralGroup( 8 ) );;
gap> View( t ); Print( "\n" );
CharacterTable( <pc group of size 8 with 3 generators> )
gap> Print( t, "\n" );
CharacterTable( Group( [ f1, f2, f3 ] ) )
gap> ViewString( t );
"CharacterTable( <pc group of size 8 with 3 generators> )"
gap> PrintString( t );
"CharacterTable( \"Group( \>[ f1, f2, f3 ]\<\> )\< )"
gap> t:= CharacterTable( SymmetricGroup( 5 ) );;
gap> View( t ); Print( "\n" );
CharacterTable( Sym( [ 1 .. 5 ] ) )
gap> Print( t, "\n" );
CharacterTable( SymmetricGroup( [ 1 .. 5 ] ) )
gap> ViewString( t );
"CharacterTable( Sym( [ 1 .. 5 ] ) )"
gap> PrintString( t );
"CharacterTable( \"Group( \>[ (1,2,3,4,5), (1,2) ]\<\> )\< )"

##
gap> STOP_TEST( "ctbl.tst", 1);

#############################################################################
##
#E

