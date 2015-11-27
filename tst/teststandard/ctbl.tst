#############################################################################
##
#W  ctbl.tst                   GAP Library                      Thomas Breuer
##
##
#Y  Copyright (C)  1998,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  Exclude from testinstall.g: why?
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
gap> LoadPackage("ctbllib", "1", false);; 

# `CharacterTableDirectProduct' in all four combinations.
gap> t1:= CharacterTable( "Cyclic", 2 );
CharacterTable( "C2" )
gap> t2:= CharacterTable( "Cyclic", 3 );
CharacterTable( "C3" )
gap> t1 * t1;
CharacterTable( "C2xC2" )
gap> ( t1 mod 2 ) * ( t1 mod 2 );
BrauerTable( "C2xC2", 2 )
gap> ( t1 mod 2 ) * t2;
BrauerTable( "C2xC3", 2 )
gap> t2 * ( t1 mod 2 );
BrauerTable( "C3xC2", 2 )
gap> STOP_TEST( "ctbl.tst", 2970000);

#############################################################################
##
#E
