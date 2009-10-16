#############################################################################
##
#A  aceds.tst                 ACE package                         Greg Gamble
#A                                                             Volkmar Felsch
##
##  A nice example provided by Volkmar Felsch that tests the stability of the
##  ACE interface when bad input is fed to the ACE binary.
##

gap> START_TEST( "Testing ACEDeleteSubgroupGenerators with bad input" );
gap> G := PerfectGroup( 2^5*60, 2 );                 
A5 2^4 E N 2^1                      
gap> F := FreeGroupOfFpGroup( G );
<free group on the generators [ a, b, s, t, u, v, d ]>
gap> a:=F.1;; b:=F.2;; s:=F.3;; t:=F.4;; u:=F.5;; v:=F.6;; d:=F.7;;
gap> fgens := FreeGeneratorsOfFpGroup( G );;                       
gap> rels := RelatorsOfFpGroup( G );        
[ a^2*d^-1, b^3, a*b*a*b*a*b*a*b*a*b, s^2, t^2, u^2, v^2, d^2, s^-1*t^-1*s*t,
  u^-1*v^-1*u*v, s^-1*u^-1*s*u, s^-1*v^-1*s*v, t^-1*u^-1*t*u, t^-1*v^-1*t*v, 
  a^-1*s*a*u^-1, a^-1*t*a*v^-1, a^-1*u*a*s^-1, a^-1*v*a*t^-1,               
  b^-1*s*b*d^-1*v^-1*t^-1, b^-1*t*b*v^-1*u^-1*t^-1*s^-1, b^-1*u*b*v^-1*u^-1,
  b^-1*v*b*u^-1, d^-1*a^-1*d*a, d^-1*b^-1*d*b, d^-1*s^-1*d*s, d^-1*t^-1*d*t,
  d^-1*u^-1*d*u, d^-1*v^-1*d*v ]                                            
gap> i := ACEStart( fgens, rels, [ b, t ] );
1                                           
gap> ACEStats( i );
rec( index := 80, cputime := 1, cputimeUnits := "10^-2 seconds",
  activecosets := 80, maxcosets := 123, totcosets := 187 )      
gap> ACEDeleteSubgroupGenerators( i, [ t ] );             
[ b ]                                        
gap> ACEDeleteSubgroupGenerators( i, [ 2 ] );
#I  ** ERROR (continuing with next line)     
#I     first argument out of range
[ b ]
gap> STOP_TEST( "aceds.tst", 1000000 );
