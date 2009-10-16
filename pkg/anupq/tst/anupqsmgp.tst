#############################################################################
##
#A  anupqsmgp.tst             ANUPQ package                       Greg Gamble
##
##  Tests the ANUPQ with some groups from the SmallGroups library.
##  Execute this file with `ReadTest( "anupqsmgp.tst" );'.
##  The number of GAPstones returned at the end do not mean much as  they  do
##  not measure the time spent by the `pq' binary.
##  The tests made are based on some examples provided by Bettina Eick.
##

gap> START_TEST( "Testing ANUPQ with some SmallGroup groups" );
gap> SetInfoLevel(InfoANUPQ, 1);
gap> G := SmallGroup(8, 3);
<pc group of size 8 with 3 generators>
gap> PqDescendants( G : OrderBound := 16 );
[ <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators> ]
gap> H := StandardPresentation(G : Prime := 2);
<fp group on the generators [ f1, f2, f3 ]>
gap> MultiplicatorRank(H);
3
gap> NuclearRank(H);
1
gap> G := SmallGroup(4, 2);
<pc group of size 4 with 2 generators>
gap> PqDescendants( G );
[ <pc group of size 8 with 3 generators>, 
  <pc group of size 8 with 3 generators>, 
  <pc group of size 8 with 3 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 16 with 4 generators>, 
  <pc group of size 32 with 5 generators> ]
gap> G := SmallGroup(8, 4);
<pc group of size 8 with 3 generators>
gap> PqDescendants(G);
[  ]
gap> G := SmallGroup(64, 8);
<pc group of size 64 with 6 generators>
gap> PqPCover(G);
<pc group of size 1024 with 10 generators>
gap> PqDescendants(G);
[ <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators> ]
gap> id := PqStart(G);;
gap> PqPCover(id);
<pc group of size 1024 with 10 generators>
gap> PqDescendants(id);
[ <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 128 with 7 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators>, 
  <pc group of size 256 with 8 generators> ]
gap> MultiplicatorRank(G);
4
gap> NuclearRank(G);
2
gap> G := SmallGroup(4, 2);
<pc group of size 4 with 2 generators>
gap> d := PqDescendants( G ){[1..3]};
[ <pc group of size 8 with 3 generators>, 
  <pc group of size 8 with 3 generators>, 
  <pc group of size 8 with 3 generators> ]
gap> List(d, MultiplicatorRank);
[ 3, 3, 2 ]
gap> List(d, NuclearRank);
[ 1, 1, 0 ]
gap> G := SmallGroup(8, 4);
<pc group of size 8 with 3 generators>
gap> H := StandardPresentation( G );
<fp group on the generators [ f1, f2, f3 ]>
gap> STOP_TEST( "anupqsmgp.tst", 1000000 );
