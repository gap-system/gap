#############################################################################
##
#A  anupq1eg.tst              ANUPQ package                       Greg Gamble
##
##  Tests one of the ANUPQ examples. This is  done  on  its  own  because  it
##  outputs timing data which varies from machine to machine.
##  Execute this file with `ReadTest( "anupq1eg.tst" );'.
##  The number of GAPstones returned at the end do not mean much as  they  do
##  not measure the time spent by the `pq' binary.
##

gap> START_TEST( "Testing one ANUPQ example" );
gap> SetInfoLevel(InfoANUPQ, 1);
gap> ##Example: "EpimorphismStandardPresentation-i" . . based on manual example
gap> ##(demonstrates interactive `EpimorphismStandardPresentation' usage)
gap> F := FreeGroup(6, "F");
<free group on the generators [ F1, F2, F3, F4, F5, F6 ]>
gap> # For printing GAP uses the symbols F1, ... for the generators of F
gap> x := F.1; y := F.2; z := F.3; w := F.4; a := F.5; b := F.6;
F1
F2
F3
F4
F5
F6
gap> R := [x^3 / w, y^3 / w * a^2 * b^2, w^3 / b,
>          Comm (y, x) / z, Comm (z, x), Comm (z, y) / a, z^3 ];
[ F1^3*F4^-1, F2^3*F4^-1*F5^2*F6^2, F4^3*F6^-1, F2^-1*F1^-1*F2*F1*F3^-1, 
  F3^-1*F1^-1*F3*F1, F3^-1*F2^-1*F3*F2*F5^-1, F3^3 ]
gap> Q := F / R;
<fp group on the generators [ F1, F2, F3, F4, F5, F6 ]>
gap> procId := PqStart( Q );
1
gap> G := Pq( procId : Prime := 3, ClassBound := 3 );
<pc group of size 729 with 6 generators>
gap> lev := InfoLevel(InfoANUPQ); # Save current InfoANUPQ level
1
gap> SetInfoLevel(InfoANUPQ, 2); # To see computation time data
gap> # It is not necessary to pass the `Prime' option to
gap> # `EpimorphismStandardPresentation' since it was previously
gap> # passed to `Pq':
gap> phi := EpimorphismStandardPresentation( procId : ClassBound := 3 );
#I  Class 1 3-quotient and its 3-covering group computed in 0.00 seconds
#I  Order of GL subgroup is 48
#I  No. of soluble autos is 0
#I    dim U = 1  dim N = 3  dim M = 3
#I    nice stabilizer with perm rep
#I  Computing standard presentation for class 2 took 0.00 seconds
#I  Computing standard presentation for class 3 took 0.01 seconds
[ F1, F2, F3, F4, F5, F6 ] -> [ f1*f2^2*f3*f4^2*f5^2, f1*f2*f3*f5, f3^2, 
  f4*f6^2, f5, f6 ]
gap> # Image of phi should be isomorphic to G ...
gap> # let's check the order is correct:
gap> Size( Image(phi) );
729
gap> # `StandardPresentation' and `EpimorphismStandardPresentation'
gap> # behave like attributes, so no computation is done when
gap> # either is called again for the same process ...
gap> StandardPresentation( procId : ClassBound := 3 );
<fp group of size 729 on the generators [ f1, f2, f3, f4, f5, f6 ]>
gap> # No timing data was Info-ed since no computation was done
gap> SetInfoLevel(InfoANUPQ, lev); # Restore previous InfoANUPQ level
gap> PqQuit(procId);
gap> STOP_TEST( "anupq1eg.tst", 1000000 );
