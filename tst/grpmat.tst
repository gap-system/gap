#############################################################################
##
#W  grpmat.tst                  GAP tests                   Heiko Thei{\ss}en
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");

gap> i := E(4);; G := Group([[i,0],[0,-i]],[[0,1],[-1,0]]);;
gap> gens := GeneratorsOfGroup( G );; IsSSortedList( gens );
false
gap> TypeObj( ShallowCopy( gens ) ) = false;
false
gap> SetName( G, "Q8" );
gap> One( TrivialSubgroup( G ) );
[ [ 1, 0 ], [ 0, 1 ] ]
gap> Size( G );
8
gap> IsHandledByNiceMonomorphism( G );
true
gap> NiceObject( G );
Group( [ (1,3,5,8)(2,4,7,6), (1,2,5,7)(3,6,8,4) ], ... )
gap> pcgs := Pcgs( G );
Pcgs([ [ [ 0, 1 ], [ -1, 0 ] ], [ [ E(4), 0 ], [ 0, -E(4) ] ], 
  [ [ -1, 0 ], [ 0, -1 ] ] ])
gap> cl := ConjugacyClasses( G );
[ ConjugacyClass( Q8, [ [ 1, 0 ], [ 0, 1 ] ] ), 
  ConjugacyClass( Q8, [ [ -1, 0 ], [ 0, -1 ] ] ), 
  ConjugacyClass( Q8, [ [ E(4), 0 ], [ 0, -E(4) ] ] ), 
  ConjugacyClass( Q8, [ [ 0, 1 ], [ -1, 0 ] ] ), 
  ConjugacyClass( Q8, [ [ 0, -E(4) ], [ -E(4), 0 ] ] ) ]
gap> List( cl, c -> ExponentsOfPcElement( pcgs, Representative( c ) ) );
[ [ 0, 0, 0 ], [ 0, 0, 1 ], [ 0, 1, 0 ], [ 1, 0, 0 ], [ 1, 1, 0 ] ]
gap> Size( AutomorphismGroup( G ) );
24

gap> STOP_TEST( "grpmat.tst", 199830000 );

#############################################################################
##
#E  grpmat.tst  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
