#############################################################################
##
#A  anupga.tst                ANUPQ package                     Werner Nickel
##
##  A test file for the GAP 4  interface  to  the  ANUPQ  p-group  generation
##  algorithm.
##  Execute this file with `ReadTest( "anupga.tst" );'.
##  The number of GAPstones returned at the end do not mean much as  they  do
##  not measure the time spent by the `pq' binary.
##  *Note:* `PqDescendants' now computes *all* descendants  by  default,  not
##  just the capable ones.
##

gap> START_TEST( "Testing ANUPQ p-group generation" );
gap> SetInfoLevel(InfoANUPQ, 1);
gap> F := FreeGroup(2);
<free group on the generators [ f1, f2 ]>
gap> G := PcGroupFpGroup( F / [ F.1^2, F.2^2, Comm(F.1,F.2) ] );
<pc group of size 4 with 2 generators>
gap> a1 := GroupHomomorphismByImages( G, G, [G.1, G.2], [G.2, G.1 * G.2] );
[ f1, f2 ] -> [ f2, f1*f2 ]
gap> a2 := GroupHomomorphismByImages( G, G, [G.1, G.2], [G.2, G.1] );
[ f1, f2 ] -> [ f2, f1 ]
gap> SetAutomorphismGroup( G, Group( a1, a2 ) );
gap> L := PqDescendants( G, "OrderBound", 4, "ClassBound", 4 );
[ <pc group of size 8 with 3 generators>, 
  <pc group of size 8 with 3 generators>, 
  <pc group of size 8 with 3 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators> ]
gap> List( L, P->Rules(ElementsFamily(FamilyObj(P))!.rewritingSystem) );
[ [ f1^2*f3^-1, f2^2, f3^2, f1^-1*f2*f1*f2^-1, f1^-1*f3*f1*f3^-1, 
      f2^-1*f3*f2*f3^-1 ], 
  [ f1^2, f2^2, f3^2, f1^-1*f2*f1*f3^-1*f2^-1, f1^-1*f3*f1*f3^-1, 
      f2^-1*f3*f2*f3^-1 ], 
  [ f1^2*f3^-1, f2^2*f3^-1, f3^2, f1^-1*f2*f1*f3^-1*f2^-1, f1^-1*f3*f1*f3^-1, 
      f2^-1*f3*f2*f3^-1 ], 
  [ f1^2*f3^-1, f2^2*f4^-1, f3^2, f4^2, f1^-1*f2*f1*f2^-1, f1^-1*f3*f1*f3^-1, 
      f2^-1*f3*f2*f3^-1, f1^-1*f4*f1*f4^-1, f2^-1*f4*f2*f4^-1, 
      f3^-1*f4*f3*f4^-1 ], 
  [ f1^2*f4^-1, f2^2, f3^2, f4^2, f1^-1*f2*f1*f3^-1*f2^-1, f1^-1*f3*f1*f3^-1, 
      f2^-1*f3*f2*f3^-1, f1^-1*f4*f1*f4^-1, f2^-1*f4*f2*f4^-1, 
      f3^-1*f4*f3*f4^-1 ], 
  [ f1^2*f4^-1, f2^2*f3^-1, f3^2, f4^2, f1^-1*f2*f1*f3^-1*f2^-1, 
      f1^-1*f3*f1*f3^-1, f2^-1*f3*f2*f3^-1, f1^-1*f4*f1*f4^-1, 
      f2^-1*f4*f2*f4^-1, f3^-1*f4*f3*f4^-1 ], 
  [ f1^2*f3^-1, f2^2, f3^2*f4^-1, f4^2, f1^-1*f2*f1*f2^-1, f1^-1*f3*f1*f3^-1, 
      f2^-1*f3*f2*f3^-1, f1^-1*f4*f1*f4^-1, f2^-1*f4*f2*f4^-1, 
      f3^-1*f4*f3*f4^-1 ], 
  [ f1^2*f3^-1, f2^2, f3^2*f4^-1, f4^2, f1^-1*f2*f1*f4^-1*f2^-1, 
      f1^-1*f3*f1*f3^-1, f2^-1*f3*f2*f3^-1, f1^-1*f4*f1*f4^-1, 
      f2^-1*f4*f2*f4^-1, f3^-1*f4*f3*f4^-1 ], 
  [ f1^2, f2^2, f3^2*f4^-1, f4^2, f1^-1*f2*f1*f3^-1*f2^-1, 
      f1^-1*f3*f1*f4^-1*f3^-1, f2^-1*f3*f2*f4^-1*f3^-1, f1^-1*f4*f1*f4^-1, 
      f2^-1*f4*f2*f4^-1, f3^-1*f4*f3*f4^-1 ], 
  [ f1^2*f4^-1, f2^2, f3^2*f4^-1, f4^2, f1^-1*f2*f1*f3^-1*f2^-1, 
      f1^-1*f3*f1*f4^-1*f3^-1, f2^-1*f3*f2*f4^-1*f3^-1, f1^-1*f4*f1*f4^-1, 
      f2^-1*f4*f2*f4^-1, f3^-1*f4*f3*f4^-1 ], 
  [ f1^2*f4^-1, f2^2*f4^-1, f3^2*f4^-1, f4^2, f1^-1*f2*f1*f3^-1*f2^-1, 
      f1^-1*f3*f1*f4^-1*f3^-1, f2^-1*f3*f2*f4^-1*f3^-1, f1^-1*f4*f1*f4^-1, 
      f2^-1*f4*f2*f4^-1, f3^-1*f4*f3*f4^-1 ] ]
gap> List( L, P->GeneratorsOfGroup(AutomorphismGroup(P)) );
[ [ Pcgs([ f1, f2, f3 ]) -> [ f1*f2, f2, f3 ], 
      Pcgs([ f1, f2, f3 ]) -> [ f1*f3, f2, f3 ], 
      Pcgs([ f1, f2, f3 ]) -> [ f1, f2*f3, f3 ] ], 
  [ Pcgs([ f1, f2, f3 ]) -> [ f2, f1, f3 ], 
      Pcgs([ f1, f2, f3 ]) -> [ f1*f3, f2, f3 ], 
      Pcgs([ f1, f2, f3 ]) -> [ f1, f2*f3, f3 ] ], 
  [ Pcgs([ f1, f2, f3 ]) -> [ f1*f2, f2, f3 ], 
      Pcgs([ f1, f2, f3 ]) -> [ f2, f1*f2, f3 ], 
      Pcgs([ f1, f2, f3 ]) -> [ f1*f3, f2, f3 ], 
      Pcgs([ f1, f2, f3 ]) -> [ f1, f2*f3, f3 ] ], 
  [ Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f2, f2, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f2, f1, f4, f3 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f3, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f3, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f4, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f4, f3, f4 ] ], 
  [ Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f2, f2, f3, f3*f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f3, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f3, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f4, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f4, f3, f4 ] ], 
  [ Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f2, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f3, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f3, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f4, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f4, f3, f4 ] ], 
  [ Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f2, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f3, f2, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f4, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f4, f3, f4 ] ], 
  [ Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f2, f2, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f3, f2, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f4, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f4, f3, f4 ] ], 
  [ Pcgs([ f1, f2, f3, f4 ]) -> [ f2, f1, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f3, f2, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f3, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f4, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f4, f3, f4 ] ], 
  [ Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f3, f2, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f3, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f4, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f4, f3, f4 ] ], 
  [ Pcgs([ f1, f2, f3, f4 ]) -> [ f2, f1, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f3, f2, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f3, f3*f4, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1*f4, f2, f3, f4 ], 
      Pcgs([ f1, f2, f3, f4 ]) -> [ f1, f2*f4, f3, f4 ] ] ]
gap> STOP_TEST( "anupga.tst", 1000000 );
