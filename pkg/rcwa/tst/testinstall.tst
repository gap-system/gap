#############################################################################
##
#W  testinstall.tst              GAP4 Package `RCWA'              Stefan Kohl
##
##  This file does a nontrivial computation to check whether an installation
##  of RCWA appears to work. If everything is o.k., no differences should be
##  shown. For a more thorough test, see testall.g.
##
#############################################################################

gap> START_TEST( "testinstall.tst" );
gap> RCWADoThingsToBeDoneBeforeTest();
gap> Product(Factorization(mKnot(3))) = mKnot(3);
true
gap> RCWADoThingsToBeDoneAfterTest();
gap> STOP_TEST( "testinstall.tst", 250000000 );

#############################################################################
##
#E  perlist.tst . . . . . . . . . . . . . . . . . . . . . . . . . . ends here