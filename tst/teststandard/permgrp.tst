#############################################################################
##
#W  permgrp.tst                GAP Library                     
##
##
##
##  Some tests for permutation groups and friends(takes a few seconds to run)
##
gap> START_TEST("permgrp.tst");
gap> Size(Normalizer(SymmetricGroup(100),PrimitiveGroup(100,1)));
1209600
gap> g:=Image(RegularActionHomomorphism(AbelianGroup([4,5,5])));;
gap> Size(Normalizer(SymmetricGroup(100),g));       
96000
gap> STOP_TEST( "permgrp.tst", 1);

#############################################################################
##
#E
