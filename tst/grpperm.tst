#############################################################################
##
#W  grpperm.tst                 GAP tests                    Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997
##
##

gap> START_TEST("$Id$");
gap> G1 := TrivialSubgroup (Group ((1,2)));;
gap> G2 := SymmetricGroup ([]);;
gap> G3:=Intersection (G1, G2);;
gap> Size(G3);
1
gap> Pcgs(G3);;

gap> g:=Group( (1,2,3), (2,3)(4,5) );;
gap> IsSolvable(g);
true
gap> RepresentativeOperation(g,(2,5,3), (2,3,4));
(2,3)(4,5)
gap> g:=Group(( 9,11,10), ( 2, 3, 4),  (14,17,15), (13,16)(15,17), 
gap> ( 8,12)(10,11), ( 5, 7)(10,11), (15,16,17), (10,11,12));;
gap> Sum(ConjugacyClasses(g),Size)=Size(g);
true

# that's all, folks
gap> STOP_TEST( "grpperm.tst", 463600 );

#############################################################################
##
#E  grpperm.tst . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
