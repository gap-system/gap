#############################################################################
##
#W  utils.tst             GAP 4 package `genus'                 Thomas Breuer
##
#H  @(#)$Id: utils.tst,v 1.2 2001/09/21 16:16:31 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id: utils.tst,v 1.2 2001/09/21 16:16:31 gap Exp $");


# Load the package if necessary.
gap> RequirePackage( "genus" );
true


#T missing: IsPairwiseCoprimeList

#T missing: IsCompatibleAbelianInvariants


gap> SizesSimpleGroupsInfo( [ 1 .. 600 ] );
[ [ 60, "A5" ], [ 168, "L2(7)" ], [ 360, "A6" ], [ 504, "L2(8)" ] ]
gap> SizesSimpleGroupsInfo( 660, "divides" );
[ [ 60, "A5" ], [ 660, "L2(11)" ] ]
gap> info:= SizesSimpleGroupsInfo( [ 1 .. 30000 ] );
[ [ 60, "A5" ], [ 168, "L2(7)" ], [ 360, "A6" ], [ 504, "L2(8)" ], 
  [ 660, "L2(11)" ], [ 1092, "L2(13)" ], [ 2448, "L2(17)" ], [ 2520, "A7" ], 
  [ 3420, "L2(19)" ], [ 4080, "L2(16)" ], [ 5616, "L3(3)" ], 
  [ 6048, "U3(3)" ], [ 6072, "L2(23)" ], [ 7800, "L2(25)" ], [ 7920, "M11" ], 
  [ 9828, "L2(27)" ], [ 12180, "L2(29)" ], [ 14880, "L2(31)" ], 
  [ 20160, "A8" ], [ 20160, "L3(4)" ], [ 25308, "L2(37)" ], 
  [ 25920, "S4(3)" ], [ 29120, "Sz(8)" ] ]
gap> info = SizesSimpleGroupsInfo(  30000  );
true
gap> names:= AllCharacterTableNames( IsSimple, true );;
gap> orders:= List( names, x -> Size( CharacterTable( x ) ) );;
gap> info:= List( orders, x -> SizesSimpleGroupsInfo( [ x ] ) );;
gap> uni:= Filtered( [ 1 .. Length( info ) ], i -> Length( info[i] ) = 1 );;
gap> amb:= Difference( [ 1 .. Length( info ) ], uni );;
gap> diff:= Filtered( uni, i -> names[i] <> info[i][1][2] );;
gap> names{ diff };
[ "R(27)", "L3(2)", "U4(2)" ]
gap> List( info{ diff }, x -> x[1][2] );
[ "2G2(27)", "L2(7)", "S4(3)" ]
gap> names{ amb };
[ "A8", "L3(4)", "O7(3)", "S6(3)", "S6(5)" ]
gap> info{ amb };
[ [ [ 20160, "A8" ], [ 20160, "L3(4)" ] ], 
  [ [ 20160, "A8" ], [ 20160, "L3(4)" ] ], 
  [ [ 4585351680, "O7(3))" ], [ 4585351680, "S6(3))" ] ], 
  [ [ 4585351680, "O7(3))" ], [ 4585351680, "S6(3))" ] ], 
  [ [ 228501000000000, "O7(5))" ], [ 228501000000000, "S6(5))" ] ] ]

gap> Filtered( [ 1 .. 600 ], x -> not IsSolvableNumber( x ) );
[ 60, 120, 168, 180, 240, 300, 336, 360, 420, 480, 504, 540, 600 ]

gap> grps:= AllSmallGroups( Size, [ 1 .. 100 ], IsDihedralGroup, true );;
gap> List( grps, Size ) = [ 2, 4 .. 100 ];
true

gap> STOP_TEST( "utils.tst", 10000000 );


#############################################################################
##
#E

