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

# Display for the table of the trivial group
gap> Display( CharacterTable( CyclicGroup( 1 ) ) );
CT1


       1a

X.1     1

# viewing and printing of character tables with stored groups
gap> t:= CharacterTable( DihedralGroup( 8 ) );;
gap> View( t ); Print( "\n" );
CharacterTable( <pc group of size 8 with 3 generators> )
gap> Print( t, "\n" );
CharacterTable( Group( [ f1, f2, f3 ] ) )
gap> ViewString( t );
"CharacterTable( <group of size 8 with 3 generators> )"
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

# entries of mutable attributes are immutable
gap> t:= CharacterTable( SymmetricGroup( 5 ) );
CharacterTable( Sym( [ 1 .. 5 ] ) )
gap> PowerMap( t, 2 );;  PowerMap( t, 3 );;
gap> Length( ComputedPowerMaps( t ) );
3
gap> IsMutable( ComputedPowerMaps( t ) );
true
gap> ForAny( ComputedPowerMaps( t ), IsMutable );
false
gap> Indicator( t, 2 );;
gap> Length( ComputedIndicators( t ) );
2
gap> IsMutable( ComputedIndicators( t ) );
true
gap> ForAny( ComputedIndicators( t ), IsMutable );
false
gap> PrimeBlocks( t, 2 );;
gap> Length( ComputedPrimeBlockss( t ) );
2
gap> IsMutable( ComputedPrimeBlockss( t ) );
true
gap> ForAny( ComputedPrimeBlockss( t ), IsMutable );
false

# test a bugfix
gap> g:= SmallGroup( 96, 3 );;
gap> t:= CharacterTable( g );;
gap> ClassPositionsOfLowerCentralSeries( t );
[ [ 1 .. 12 ], [ 1, 3, 4, 5, 6, 9, 10, 11 ] ]
gap> g:= SmallGroup( 3^5, 22 );;
gap> t:= CharacterTable( g );;
gap> ClassPositionsOfLowerCentralSeries( t );
[ [ 1 .. 35 ], [ 1, 4, 6, 12, 15 ], [ 1, 6, 15 ], [ 1 ] ]
gap> g:= SmallGroup( 96, 66 );;
gap> t:= CharacterTable( g );;
gap> ClassPositionsOfSupersolvableResiduum( t );
[ 1, 5, 6 ]

##
gap> STOP_TEST( "ctbl.tst" );

#############################################################################
##
#E
