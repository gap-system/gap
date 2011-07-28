############################################################################
##
#W  res.gi 			The NQL-package			 René Hartung
##
##   @(#)$Id: res.tst,v 1.2 2010/04/01 11:42:56 gap Exp $
##

gap> START_TEST("Checking some self-similar groups");

gap> IL:=InfoLevel(InfoNQL);;
gap> SetInfoLevel(InfoNQL,1);
gap> G:=ExamplesOfLPresentations(1);
#I  The Grigorchuk group on 4 generators from [Lys85]
<invariant LpGroup of size infinity on the generators [ a, b, c, d ]>
gap> H:=NilpotentQuotient(G,20);;
#I  Class 1: 3 generators with relative orders: [ 2, 2, 2 ]
#I  Class 2: 2 generators with relative orders: [ 2, 2 ]
#I  Class 3: 2 generators with relative orders: [ 2, 2 ]
#I  Class 4: 1 generators with relative orders: [ 2 ]
#I  Class 5: 2 generators with relative orders: [ 2, 2 ]
#I  Class 6: 2 generators with relative orders: [ 2, 2 ]
#I  Class 7: 1 generators with relative orders: [ 2 ]
#I  Class 8: 1 generators with relative orders: [ 2 ]
#I  Class 9: 2 generators with relative orders: [ 2, 2 ]
#I  Class 10: 2 generators with relative orders: [ 2, 2 ]
#I  Class 11: 2 generators with relative orders: [ 2, 2 ]
#I  Class 12: 2 generators with relative orders: [ 2, 2 ]
#I  Class 13: 1 generators with relative orders: [ 2 ]
#I  Class 14: 1 generators with relative orders: [ 2 ]
#I  Class 15: 1 generators with relative orders: [ 2 ]
#I  Class 16: 1 generators with relative orders: [ 2 ]
#I  Class 17: 2 generators with relative orders: [ 2, 2 ]
#I  Class 18: 2 generators with relative orders: [ 2, 2 ]
#I  Class 19: 2 generators with relative orders: [ 2, 2 ]
#I  Class 20: 2 generators with relative orders: [ 2, 2 ]
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> RankPGroup(lcs[i]/lcs[i+1]) );
[ 3, 2, 2, 1, 2, 2, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 2, 2, 2, 2 ]
gap> G:= ExamplesOfLPresentations(3);
#I  The lamplighter group on two lamp states
<LpGroup of size infinity on the generators [ a, t, u ]>
gap> H:=NilpotentQuotient(G,7);;
#I  Class InvLpGroup 1: 3 generators with relative orders: [ 2, 0, 0 ]
#I  Class InvLpGroup 2: 2 generators with relative orders: [ 2, 0 ]
#I  Class InvLpGroup 3: 4 generators with relative orders: [ 2, 2, 0, 0 ]
#I  Class InvLpGroup 4: 6 generators with relative orders: [ 2, 2, 2, 0, 0, 0 
 ]
#I  Class InvLpGroup 5: 11 generators
#I  Class InvLpGroup 6: 16 generators
#I  Class InvLpGroup 7: 29 generators
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> AbelianInvariants( lcs[i]/lcs[i+1] ) );
[ [ 2, 0 ], [ 2 ], [ 2 ], [ 2 ], [ 2 ], [ 2 ], [ 2 ] ]

gap> G:=ExamplesOfLPresentations(4);
#I  The Brunner-Sidki-Vieira group
<invariant LpGroup of size infinity on the generators [ a, b ]>
gap> H:=NilpotentQuotient(G,15);;
#I  Class 1: 2 generators with relative orders: [ 0, 0 ]
#I  Class 2: 1 generators with relative orders: [ 0 ]
#I  Class 3: 1 generators with relative orders: [ 8 ]
#I  Class 4: 1 generators with relative orders: [ 8 ]
#I  Class 5: 2 generators with relative orders: [ 4, 8 ]
#I  Class 6: 2 generators with relative orders: [ 2, 8 ]
#I  Class 7: 3 generators with relative orders: [ 2, 2, 8 ]
#I  Class 8: 3 generators with relative orders: [ 2, 2, 8 ]
#I  Class 9: 4 generators with relative orders: [ 4, 2, 2, 8 ]
#I  Class 10: 4 generators with relative orders: [ 4, 2, 2, 8 ]
#I  Class 11: 4 generators with relative orders: [ 2, 2, 2, 8 ]
#I  Class 12: 4 generators with relative orders: [ 2, 2, 2, 8 ]
#I  Class 13: 5 generators with relative orders: [ 2, 2, 2, 2, 8 ]
#I  Class 14: 5 generators with relative orders: [ 2, 2, 2, 2, 8 ]
#I  Class 15: 5 generators with relative orders: [ 2, 2, 2, 2, 8 ]
gap> H:=NilpotentQuotient(G,15);;
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> AbelianInvariants( lcs[i]/lcs[i+1] ) );
[ [ 0, 0 ], [ 0 ], [ 8 ], [ 8 ], [ 4, 8 ], [ 2, 8 ], [ 2, 2, 8 ],
  [ 2, 2, 8 ], [ 2, 2, 4, 8 ], [ 2, 2, 4, 8 ], [ 2, 2, 2, 8 ],
  [ 2, 2, 2, 8 ], [ 2, 2, 2, 2, 8 ], [ 2, 2, 2, 2, 8 ], [ 2, 2, 2, 2, 8 ] ]

gap> G:=ExamplesOfLPresentations(5);
#I  The Grigorchuk supergroup
<invariant LpGroup of size infinity on the generators [ a, b, c, d ]>
gap> H:=NilpotentQuotient(G,15);;
#I  Class 1: 4 generators with relative orders: [ 2, 2, 2, 2 ]
#I  Class 2: 3 generators with relative orders: [ 2, 2, 2 ]
#I  Class 3: 3 generators with relative orders: [ 2, 2, 2 ]
#I  Class 4: 2 generators with relative orders: [ 2, 2 ]
#I  Class 5: 3 generators with relative orders: [ 2, 2, 2 ]
#I  Class 6: 3 generators with relative orders: [ 2, 2, 2 ]
#I  Class 7: 2 generators with relative orders: [ 2, 2 ]
#I  Class 8: 2 generators with relative orders: [ 2, 2 ]
#I  Class 9: 3 generators with relative orders: [ 2, 2, 2 ]
#I  Class 10: 3 generators with relative orders: [ 2, 2, 2 ]
#I  Class 11: 3 generators with relative orders: [ 2, 2, 2 ]
#I  Class 12: 3 generators with relative orders: [ 2, 2, 2 ]
#I  Class 13: 2 generators with relative orders: [ 2, 2 ]
#I  Class 14: 2 generators with relative orders: [ 2, 2 ]
#I  Class 15: 2 generators with relative orders: [ 2, 2 ]
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> RankPGroup( lcs[i]/lcs[i+1] ) );
[ 4, 3, 3, 2, 3, 3, 2, 2, 3, 3, 3, 3, 2, 2, 2 ]

gap> G:=ExamplesOfLPresentations( 6 );
#I  The Fabrykowski-Gupta group
<invariant LpGroup of size infinity on the generators [ a, r ]>
gap> H:=NilpotentQuotient(G,20);;
#I  Class 1: 2 generators with relative orders: [ 3, 3 ]
#I  Class 2: 1 generators with relative orders: [ 3 ]
#I  Class 3: 2 generators with relative orders: [ 3, 3 ]
#I  Class 4: 1 generators with relative orders: [ 3 ]
#I  Class 5: 2 generators with relative orders: [ 3, 3 ]
#I  Class 6: 2 generators with relative orders: [ 3, 3 ]
#I  Class 7: 2 generators with relative orders: [ 3, 3 ]
#I  Class 8: 1 generators with relative orders: [ 3 ]
#I  Class 9: 1 generators with relative orders: [ 3 ]
#I  Class 10: 1 generators with relative orders: [ 3 ]
#I  Class 11: 2 generators with relative orders: [ 3, 3 ]
#I  Class 12: 2 generators with relative orders: [ 3, 3 ]
#I  Class 13: 2 generators with relative orders: [ 3, 3 ]
#I  Class 14: 2 generators with relative orders: [ 3, 3 ]
#I  Class 15: 2 generators with relative orders: [ 3, 3 ]
#I  Class 16: 2 generators with relative orders: [ 3, 3 ]
#I  Class 17: 2 generators with relative orders: [ 3, 3 ]
#I  Class 18: 2 generators with relative orders: [ 3, 3 ]
#I  Class 19: 2 generators with relative orders: [ 3, 3 ]
#I  Class 20: 1 generators with relative orders: [ 3 ]
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> RankPGroup( lcs[i]/lcs[i+1] ) );
[ 2, 1, 2, 1, 2, 2, 2, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1 ]

gap> G:=ExamplesOfLPresentations( 7 );
#I  The Gupta-Sidki group
<LpGroup of size infinity on the generators [ a, t, u, v ]>
gap> H:=NilpotentQuotient(G,4);;
#I  Class InvLpGroup 1: 4 generators with relative orders: [ 3, 3, 3, 3 ]
#I  Class InvLpGroup 2: 6 generators with relative orders: [ 3, 3, 3, 3, 3, 3 
 ]
#I  Class InvLpGroup 3: 18 generators
#I  Class InvLpGroup 4: 42 generators
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> RankPGroup( lcs[i]/lcs[i+1] ) );
[ 2, 1, 2, 1 ]

gap> G:=ExamplesOfLPresentations( 8 );
#I  An index-3 subgroup of the Gupta-Sidki group
<invariant LpGroup of size infinity on the generators [ t, u, v ]>
gap> H:=NilpotentQuotient(G,10);;
#I  Class 1: 3 generators with relative orders: [ 3, 3, 3 ]
#I  Class 2: 3 generators with relative orders: [ 3, 3, 3 ]
#I  Class 3: 6 generators with relative orders: [ 3, 3, 3, 3, 3, 3 ]
#I  Class 4: 3 generators with relative orders: [ 3, 3, 3 ]
#I  Class 5: 6 generators with relative orders: [ 3, 3, 3, 3, 3, 3 ]
#I  Class 6: 6 generators with relative orders: [ 3, 3, 3, 3, 3, 3 ]
#I  Class 7: 6 generators with relative orders: [ 3, 3, 3, 3, 3, 3 ]
#I  Class 8: 6 generators with relative orders: [ 3, 3, 3, 3, 3, 3 ]
#I  Class 9: 3 generators with relative orders: [ 3, 3, 3 ]
#I  Class 10: 6 generators with relative orders: [ 3, 3, 3, 3, 3, 3 ]
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> RankPGroup( lcs[i]/lcs[i+1] ) );
[ 3, 3, 6, 3, 6, 6, 6, 6, 3, 6 ]

gap> G:=ExamplesOfLPresentations( 9 );
#I  The Basilica group
<invariant LpGroup of size infinity on the generators [ a, b ]>
gap> H:=NilpotentQuotient(G,15);;
#I  Class 1: 2 generators with relative orders: [ 0, 0 ]
#I  Class 2: 1 generators with relative orders: [ 0 ]
#I  Class 3: 1 generators with relative orders: [ 4 ]
#I  Class 4: 1 generators with relative orders: [ 4 ]
#I  Class 5: 2 generators with relative orders: [ 4, 4 ]
#I  Class 6: 2 generators with relative orders: [ 2, 4 ]
#I  Class 7: 3 generators with relative orders: [ 2, 2, 4 ]
#I  Class 8: 3 generators with relative orders: [ 2, 2, 4 ]
#I  Class 9: 4 generators with relative orders: [ 2, 2, 2, 4 ]
#I  Class 10: 5 generators with relative orders: [ 2, 2, 2, 2, 4 ]
#I  Class 11: 5 generators with relative orders: [ 2, 2, 2, 2, 4 ]
#I  Class 12: 4 generators with relative orders: [ 2, 2, 2, 4 ]
#I  Class 13: 5 generators with relative orders: [ 2, 2, 2, 2, 4 ]
#I  Class 14: 5 generators with relative orders: [ 2, 2, 2, 2, 4 ]
#I  Class 15: 5 generators with relative orders: [ 2, 2, 2, 2, 4 ]
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> AbelianInvariants( lcs[i]/lcs[i+1] ));
[ [ 0, 0 ], [ 0 ], [ 4 ], [ 4 ], [ 4, 4 ], [ 2, 4 ], [ 2, 2, 4 ],
  [ 2, 2, 4 ], [ 2, 2, 2, 4 ], [ 2, 2, 2, 2, 4 ], [ 2, 2, 2, 2, 4 ],
  [ 2, 2, 2, 4 ], [ 2, 2, 2, 2, 4 ], [ 2, 2, 2, 2, 4 ], [ 2, 2, 2, 2, 4 ] ]

gap> G:=ExamplesOfLPresentations( 10 );
#I  Baumslag's group
<non-invariant LpGroup of size infinity on the generators [ a, b, t, u ]>
gap> H:=NilpotentQuotient(G,6);;
#I  Class InvLpGroup 1: 3 generators with relative orders: [ 3, 0, 0 ]
#I  Class InvLpGroup 2: 2 generators with relative orders: [ 3, 0 ]
#I  Class InvLpGroup 3: 3 generators with relative orders: [ 3, 0, 0 ]
#I  Class InvLpGroup 4: 4 generators with relative orders: [ 3, 0, 0, 0 ]
#I  Class InvLpGroup 5: 7 generators with relative orders:
[ 3, 0, 0, 0, 0, 0, 0 ]
#I  Class InvLpGroup 6: 10 generators with relative orders:
[ 3, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> AbelianInvariants( lcs[i]/lcs[i+1] ));
[ [ 3, 0 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ] ]

gap> G:=ExamplesOfLPresentations( 10 );
#I  Baumslag's group
<non-invariant LpGroup of size infinity on the generators [ a, b, t, u ]>
gap> ResetFilterObj( G, IsInvariantLPresentation );
gap> SetIsInvariantLPresentation(G,true);
gap> H:=NilpotentQuotient(G,20);;
#I  Class 1: 2 generators with relative orders: [ 3, 0 ]
#I  Class 2: 1 generators with relative orders: [ 3 ]
#I  Class 3: 1 generators with relative orders: [ 3 ]
#I  Class 4: 1 generators with relative orders: [ 3 ]
#I  Class 5: 1 generators with relative orders: [ 3 ]
#I  Class 6: 1 generators with relative orders: [ 3 ]
#I  Class 7: 1 generators with relative orders: [ 3 ]
#I  Class 8: 1 generators with relative orders: [ 3 ]
#I  Class 9: 1 generators with relative orders: [ 3 ]
#I  Class 10: 1 generators with relative orders: [ 3 ]
#I  Class 11: 1 generators with relative orders: [ 3 ]
#I  Class 12: 1 generators with relative orders: [ 3 ]
#I  Class 13: 1 generators with relative orders: [ 3 ]
#I  Class 14: 1 generators with relative orders: [ 3 ]
#I  Class 15: 1 generators with relative orders: [ 3 ]
#I  Class 16: 1 generators with relative orders: [ 3 ]
#I  Class 17: 1 generators with relative orders: [ 3 ]
#I  Class 18: 1 generators with relative orders: [ 3 ]
#I  Class 19: 1 generators with relative orders: [ 3 ]
#I  Class 20: 1 generators with relative orders: [ 3 ]
gap> lcs:=LowerCentralSeriesOfGroup(H);;
gap> List([1..Length(lcs)-1], i -> AbelianInvariants( lcs[i]/lcs[i+1] ));
[ [ 3, 0 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ],
  [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ], [ 3 ] ]

# reset the info level InfoNQL
gap> SetInfoLevel(InfoNQL,IL);
gap> STOP_TEST( "res.tst", 100000 );
