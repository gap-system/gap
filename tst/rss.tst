#############################################################################
##
#W  rss.tst                   GAP library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");

gap> G := GL(4,2);
SL(4,2)
gap> RandomSchreierSims(G);
SL(4,2)
gap> HasChainSubgroup(G);
true
gap> G := MathieuGroup(22);;
gap> RandomSchreierSims(G);;
gap> HasChainSubgroup(G);
true
gap> G := GL(7,2);
SL(7,2)
gap> RandomSchreierSims(G);
SL(7,2)
gap> HasChainSubgroup(G);  
true

gap> STOP_TEST( "rss.tst", 123000000 );


#############################################################################
##
#E  
##
