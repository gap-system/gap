#############################################################################
##
#W  cyclotom.tst                GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file is being maintained by Thomas Breuer.
##  Please do not make any changes without consulting him.
##  (This holds also for minor changes such as the removal of whitespace or
##  the correction of typos.)
##
#@local a,cyc,gm,i,l1,l2,l3,mat,n,r,x,y,z,sets
gap> START_TEST("cyclotom.tst");

# Check basic arithmetic operations.
gap> cyc:= E(5) + E(7);
-E(35)^2-2*E(35)^12-E(35)^17-E(35)^19-E(35)^22-E(35)^26-E(35)^27-E(35)^32
 -E(35)^33
gap> Int( 2/3 * cyc );
-E(35)^12
gap> RoundCyc( 2/3 * cyc );
-E(35)^2-E(35)^12-E(35)^17-E(35)^19-E(35)^22-E(35)^26-E(35)^27-E(35)^32
 -E(35)^33
gap> String( cyc );
"-E(35)^2-2*E(35)^12-E(35)^17-E(35)^19-E(35)^22-E(35)^26-E(35)^27-E(35)^32-E(3\
5)^33"
gap> l1:= CoeffsCyc( cyc,   3 * Conductor( cyc ) );;
gap> Print(l1,"\n");
[ 0, 2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 
  0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 
  0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 
  0, 1, 0, 0, 0 ]
gap> l2:= CoeffsCyc( cyc,   2 * Conductor( cyc ) );;
gap> Print(l2,"\n");
[ 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 0, 0, -1, 0, 0, 0, 
  0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0 ]
gap> l3:= CoeffsCyc( cyc, 1/2 * Conductor( cyc ) );
fail
gap> CycList( l1 ) = cyc;
true
gap> CycList( l2 ) = cyc;
true

# Check atomic irrationalities.
gap> EB(5); EB(7); EB(9); EB(11);
E(5)+E(5)^4
E(7)+E(7)^2+E(7)^4
1
E(11)+E(11)^3+E(11)^4+E(11)^5+E(11)^9
gap> EC(13); EC(19); EC(37); EC(43);
E(13)+E(13)^5+E(13)^8+E(13)^12
E(19)+E(19)^7+E(19)^8+E(19)^11+E(19)^12+E(19)^18
E(37)+E(37)^6+E(37)^8+E(37)^10+E(37)^11+E(37)^14+E(37)^23+E(37)^26+E(37)^27
 +E(37)^29+E(37)^31+E(37)^36
E(43)+E(43)^2+E(43)^4+E(43)^8+E(43)^11+E(43)^16+E(43)^21+E(43)^22+E(43)^27
 +E(43)^32+E(43)^35+E(43)^39+E(43)^41+E(43)^42
gap> ED(13); ED(17);
E(13)+E(13)^3+E(13)^9
E(17)+E(17)^4+E(17)^13+E(17)^16
gap> EE(31);
E(31)+E(31)^5+E(31)^6+E(31)^25+E(31)^26+E(31)^30
gap> EF(31); EF(37);
E(31)+E(31)^2+E(31)^4+E(31)^8+E(31)^16
E(37)+E(37)^10+E(37)^11+E(37)^26+E(37)^27+E(37)^36
gap> EG(29);
E(29)+E(29)^12+E(29)^17+E(29)^28
gap> EH(257);
E(257)+E(257)^2+E(257)^4+E(257)^8+E(257)^15+E(257)^16+E(257)^17+E(257)^30
 +E(257)^32+E(257)^34+E(257)^60+E(257)^64+E(257)^68+E(257)^120+E(257)^121
 +E(257)^128+E(257)^129+E(257)^136+E(257)^137+E(257)^189+E(257)^193+E(257)^197
 +E(257)^223+E(257)^225+E(257)^227+E(257)^240+E(257)^241+E(257)^242+E(257)^249
 +E(257)^253+E(257)^255+E(257)^256
gap> EY(24); EY(44); EY(16,1); EY(24,1); EY(189,1); EY(40,2); EY(63,2);
E(24)-E(24)^11
-E(44)^23+E(44)^43
E(16)+E(16)^7
E(24)-E(24)^17
-E(189)^64-E(189)^118-E(189)^127-E(189)^181
-E(40)^21+E(40)^31
E(63)+E(63)^55
gap> EX(19); EX(31); EX(171); EX(43);
E(19)+E(19)^7+E(19)^11
E(31)+E(31)^5+E(31)^25
E(171)^7+E(171)^49-E(171)^58-E(171)^115
E(43)+E(43)^6+E(43)^36
gap> EX(333,1);
-E(333)^112+E(333)^121-E(333)^223+E(333)^322
gap> EW(25); EW(40); EW(41); EW(80);
-E(25)^4-E(25)^6+E(25)^7-E(25)^9-E(25)^11-E(25)^14-E(25)^16+E(25)^18-E(25)^19
 -E(25)^21
-E(40)^7-E(40)^21-E(40)^23-E(40)^29
E(41)+E(41)^9+E(41)^32+E(41)^40
E(80)^3+E(80)^9-E(80)^41-E(80)^67
gap> EV(71); EV(41,3);
E(71)+E(71)^5+E(71)^25+E(71)^54+E(71)^57
E(41)+E(41)^10+E(41)^16+E(41)^18+E(41)^37
gap> EU(56); EU(56,1);
-E(56)^29-E(56)^31-E(56)^37-E(56)^47-E(56)^53-E(56)^55
0
gap> ET(29,1);
E(29)+E(29)^7+E(29)^16+E(29)^20+E(29)^23+E(29)^24+E(29)^25
gap> ES(32,3);
0
gap> EM(16); EM(40,1);
E(16)+E(16)^7
-E(40)^21+E(40)^29
gap> EL(50,1); EL(91,2);
E(25)^9-E(25)^12-E(25)^13+E(25)^16
E(91)-E(91)^34+E(91)^64-E(91)^83
gap> EK(31);
E(31)+E(31)^5-E(31)^6+E(31)^25-E(31)^26-E(31)^30
gap> EJ(17,3);
E(17)-E(17)^2+E(17)^4-E(17)^8-E(17)^9+E(17)^13-E(17)^15+E(17)^16
gap> r:= Sqrt(2); r^2 = 2;
E(8)-E(8)^3
true
gap> r:= Sqrt(-6); r^2 = -6;
E(24)+E(24)^11-E(24)^17-E(24)^19
true
gap> r:= Sqrt(75); r^2 = 75;
-5*E(12)^7+5*E(12)^11
true
gap> r:= Sqrt(13); r^2 = 13;
E(13)-E(13)^2+E(13)^3+E(13)^4-E(13)^5-E(13)^6-E(13)^7-E(13)^8+E(13)^9+E(13)^10
 -E(13)^11+E(13)^12
true
gap> r:= Sqrt(80); r^2 = 80;
4*E(5)-4*E(5)^2-4*E(5)^3+4*E(5)^4
true
gap> EI(17); EI(16); EI(23);
E(68)-E(68)^5+E(68)^9+E(68)^13+E(68)^21+E(68)^25-E(68)^29+E(68)^33-E(68)^37
 -E(68)^41-E(68)^45+E(68)^49+E(68)^53-E(68)^57-E(68)^61-E(68)^65
4*E(4)
E(23)+E(23)^2+E(23)^3+E(23)^4-E(23)^5+E(23)^6-E(23)^7+E(23)^8+E(23)^9-E(23)^10
 -E(23)^11+E(23)^12+E(23)^13-E(23)^14-E(23)^15+E(23)^16-E(23)^17+E(23)^18
 -E(23)^19-E(23)^20-E(23)^21-E(23)^22

# Check general Atlas irrationalities.
gap> AtlasIrrationality( "b7*" );
E(7)^3+E(7)^5+E(7)^6
gap> AtlasIrrationality( "b7*3" );
E(7)^3+E(7)^5+E(7)^6
gap> AtlasIrrationality( "y'''24" );
E(24)-E(24)^19
gap> AtlasIrrationality( "-y'''24" );
-E(24)+E(24)^19
gap> AtlasIrrationality( "-y'''24*13" );
E(24)-E(24)^19
gap> AtlasIrrationality( "-3y'''24*13" );
3*E(24)-3*E(24)^19
gap> AtlasIrrationality( "-3y'''24*13&5" );
3*E(8)-3*E(8)^3
gap> AtlasIrrationality( "3y'''24*13-2&5" );
-3*E(24)-2*E(24)^11+2*E(24)^17+3*E(24)^19
gap> AtlasIrrationality( "3y'''24*13-&5" );
-3*E(24)-E(24)^11+E(24)^17+3*E(24)^19
gap> AtlasIrrationality( "3y'''24*13-4&5&7" );
-7*E(24)-4*E(24)^11+4*E(24)^17+7*E(24)^19
gap> AtlasIrrationality( "3y'''24&7" );
6*E(24)-6*E(24)^19
gap> StarCyc( EB(7) );
E(7)^3+E(7)^5+E(7)^6
gap> StarCyc( Sqrt(13) );
-E(13)+E(13)^2-E(13)^3-E(13)^4+E(13)^5+E(13)^6+E(13)^7+E(13)^8-E(13)^9
 -E(13)^10+E(13)^11-E(13)^12
gap> Quadratic( 4 );
rec( ATLAS := "4", a := 4, b := 0, d := 1, display := "4", root := 1 )
gap> Quadratic( EB(7) );
rec( ATLAS := "b7", a := -1, b := 1, d := 2, display := "(-1+Sqrt(-7))/2", 
  root := -7 )
gap> Quadratic( E(4) );
rec( ATLAS := "i", a := 0, b := 1, d := 1, display := "Sqrt(-1)", root := -1 )
gap> Quadratic( E(3) );
rec( ATLAS := "b3", a := -1, b := 1, d := 2, display := "(-1+Sqrt(-3))/2", 
  root := -3 )
gap> Quadratic( Sqrt(12) );
rec( ATLAS := "2r3", a := 0, b := 2, d := 1, display := "2*Sqrt(3)", 
  root := 3 )
gap> Quadratic( StarCyc( EB(5) ) );
rec( ATLAS := "-1-b5", a := -1, b := -1, d := 2, display := "(-1-Sqrt(5))/2", 
  root := 5 )
gap> GeneratorsPrimeResidues( 7^4 );
rec( exponents := [ 4 ], generators := [ 3 ], primes := [ 7 ] )
gap> GeneratorsPrimeResidues( 27*125 );
rec( exponents := [ 3, 3 ], generators := [ 1001, 2377 ], primes := [ 3, 5 ] )
gap> GeneratorsPrimeResidues( 2*9*5 );
rec( exponents := [ 1, 2, 1 ], generators := [ 1, 11, 37 ], 
  primes := [ 2, 3, 5 ] )
gap> GeneratorsPrimeResidues( 4*3*25 );
rec( exponents := [ 2, 1, 2 ], generators := [ 151, 101, 277 ], 
  primes := [ 2, 3, 5 ] )
gap> GeneratorsPrimeResidues( 8*49*11 );
rec( exponents := [ 3, 2, 1 ], generators := [ [ 1079, 2157 ], 3433, 3137 ], 
  primes := [ 2, 7, 11 ] )
gap> GeneratorsPrimeResidues( 16*13*29 );
rec( exponents := [ 4, 1, 1 ], generators := [ [ 5279, 1509 ], 1393, 1249 ], 
  primes := [ 2, 13, 29 ] )
gap> mat:= [ [       1333, EB(7),          -1,         0,      0 ],
>            [  259775040,     0,           0, 2*Sqrt(3),      0 ],
>            [  885257856,     0, 2*Sqrt(5)-1,         0,      0 ],
>            [ 1445942610,     0,           0,         0, EC(43) ] ];;
gap> gm:= GaloisMat( mat );
rec( galoisfams := [ [ [ 1, 5 ], [ 1, 10321 ] ], [ [ 2, 6 ], [ 1, 9031 ] ], 
      [ [ 3, 7 ], [ 1, 10837 ] ], [ [ 4, 8, 9 ], [ 1, 7141, 10501 ] ], 0, 0, 
      0, 0, 0 ], generators := [ (4,8,9), (3,7), (2,6), (1,5) ], 
  mat := [ [ 1333, E(7)+E(7)^2+E(7)^4, -1, 0, 0 ], 
      [ 259775040, 0, 0, -2*E(12)^7+2*E(12)^11, 0 ], 
      [ 885257856, 0, 3*E(5)-E(5)^2-E(5)^3+3*E(5)^4, 0, 0 ], 
      [ 1445942610, 0, 0, 0, 
          E(43)+E(43)^2+E(43)^4+E(43)^8+E(43)^11+E(43)^16+E(43)^21+E(43)^22
             +E(43)^27+E(43)^32+E(43)^35+E(43)^39+E(43)^41+E(43)^42 ], 
      [ 1333, E(7)^3+E(7)^5+E(7)^6, -1, 0, 0 ], 
      [ 259775040, 0, 0, 2*E(12)^7-2*E(12)^11, 0 ], 
      [ 885257856, 0, -E(5)+3*E(5)^2+3*E(5)^3-E(5)^4, 0, 0 ], 
      [ 1445942610, 0, 0, 0, 
          E(43)^3+E(43)^5+E(43)^6+E(43)^10+E(43)^12+E(43)^19+E(43)^20+E(43)^23
             +E(43)^24+E(43)^31+E(43)^33+E(43)^37+E(43)^38+E(43)^40 ], 
      [ 1445942610, 0, 0, 0, 
          E(43)^7+E(43)^9+E(43)^13+E(43)^14+E(43)^15+E(43)^17+E(43)^18
             +E(43)^25+E(43)^26+E(43)^28+E(43)^29+E(43)^30+E(43)^34+E(43)^36 
         ] ] )
gap> Print(RationalizedMat( gm.mat ),"\n");
[ [ 2666, -1, -2, 0, 0 ], [ 519550080, 0, 0, 0, 0 ], 
  [ 1770515712, 0, -2, 0, 0 ], [ 4337827830, 0, 0, 0, -1 ] ]
gap> GaloisMat( [ [ E(3) ], [ E(3) ] ] );;
#I  GaloisMat: row 1 is equal to row 2
gap> a := -E(4)*2^(8*GAPInfo.BytesPerVariable-4);;
gap> TNUM_OBJ(COEFFS_CYC(-a)[2]) = T_INTPOS;
true

#
# IsIntegralCyclotomic
#
gap> IsIntegralCyclotomic(1);
true
gap> IsIntegralCyclotomic(1/2);
false
gap> IsIntegralCyclotomic(E(4));
true
gap> IsIntegralCyclotomic(E(4)/2);
false
gap> IsIntegralCyclotomic(false);
false

#
# PowCyc
#
gap> E(1234)^1234;
1
gap> E(1234)^-1234;
1
gap> for n in [120,122,125,127,128] do
>     x:=E(n);
>     y:=1;
>     z:=1;
>     for i in [1..260] do
>         y:=y*x; z:=z/x;
>         Assert(0, x^i = y);
>         Assert(0, x^-i = z);
>     od;
> od;
gap> for n in [120,122,125,127,128] do
>     x:=E(n);
>     E(100);   # ensure special case in PowCyc does not trigger
>     y:=1;
>     z:=1;
>     for i in [1..260] do
>         y:=y*x; z:=z/x;
>         Assert(0, x^i = y);
>         Assert(0, x^-i = z);
>     od;
> od;

#
# CyclotomicsLimit
#
gap> GetCyclotomicsLimit();
1000000
gap> SetCyclotomicsLimit(1/2);
Error, Cyclotomic Field size limit must be a small integer, not a rational 
gap> SetCyclotomicsLimit(0);
Error, Cyclotomic Field size limit must be positive
gap> SetCyclotomicsLimit(100);
Error, Cyclotomic Field size limit must not be less than old limit of 1000000
gap> SetCyclotomicsLimit(1000000);

#
# test handling of invalid inputs
#

#
gap> E(0);
Error, E: <n> must be a positive small integer (not the integer 0)

#
gap> IS_CYC('a');
false

#
gap> IS_CYC_INT('a');
false

#
gap> CONDUCTOR(fail);
Error, Conductor: <cyc> must be a cyclotomic or a small list (not a boolean or\
 fail)
gap> CONDUCTOR([1,fail]);
Error, Conductor: <list>[2] must be a cyclotomic (not a boolean or fail)

#
gap> COEFFS_CYC(false);
Error, COEFFSCYC: <cyc> must be a cyclotomic (not a boolean or fail)

#
gap> CycList([1,fail]);
Error, CycList: each entry must be a rational (not a boolean or fail)

#
# Some tests for some operations on certain pre-defined infinite collections
# of cyclotomics, which are implemented using CompareCyclotomicCollectionHelper.
# For the tests, we exploit that the supported collections can be grouped into
# two totally ordered chains.
#
gap> sets:=[ PositiveIntegers, NonnegativeIntegers, Integers, Rationals, GaussianRationals, Cyclotomics ];;
gap> r:=[1..Length(sets)];;
gap> SetX(r, r, {i,j} -> Intersection(sets[i],sets[j]) = sets[Minimum(i,j)]);
[ true ]
gap> SetX(r, r, {i,j} -> Union(sets[i],sets[j]) = sets[Maximum(i,j)]);
[ true ]
gap> SetX(r, r, {i,j} -> IsSubset(sets[i],sets[j]) = (i>=j));
[ true ]
gap> SetX(r, r, {i,j} -> (sets[i]=sets[j]) = (i=j));
[ true ]

#
gap> sets:=[ PositiveIntegers, NonnegativeIntegers, Integers, GaussianIntegers, GaussianRationals, Cyclotomics ];;
gap> r:=[1..Length(sets)];;
gap> SetX(r, r, {i,j} -> Intersection(sets[i],sets[j]) = sets[Minimum(i,j)]);
[ true ]
gap> SetX(r, r, {i,j} -> Union(sets[i],sets[j]) = sets[Maximum(i,j)]);
[ true ]
gap> SetX(r, r, {i,j} -> IsSubset(sets[i],sets[j]) = (i>=j));
[ true ]
gap> SetX(r, r, {i,j} -> (sets[i]=sets[j]) = (i=j));
[ true ]

#
gap> STOP_TEST( "cyclotom.tst", 1);

#############################################################################
##
#E
