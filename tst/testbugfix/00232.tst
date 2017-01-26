# Reported by WDeMeo on 2011/02/19, added by JS on 2011/03/09
# IntermediateSubgroups(G,normal) included non-maximal inclusions
gap> g:=CyclicGroup(2^6);; IntermediateSubgroups( g, TrivialSubgroup(g) ).inclusions;
[ [ 0, 1 ], [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5, 6 ] ]
