#############################################################################
##
#W  zmodnze.tst                  GAP library              Alexander Konovalov
##
gap> START_TEST("zmodnze.tst");
gap> R:=RingInt(CF(4)) mod 5;
(RingInt(CF(4)) mod 5)
gap> IsFinite(R);
true
gap> Size(R);
25
gap> IsFinite(R);
true
gap> AsList(R);
[ ( 0 mod 5 ), ( 1 mod 5 ), ( 2 mod 5 ), ( 3 mod 5 ), ( 4 mod 5 ), 
  ( E(4) mod 5 ), ( 2*E(4) mod 5 ), ( 3*E(4) mod 5 ), ( 4*E(4) mod 5 ), 
  ( 1+E(4) mod 5 ), ( 1+2*E(4) mod 5 ), ( 1+3*E(4) mod 5 ), 
  ( 1+4*E(4) mod 5 ), ( 2+E(4) mod 5 ), ( 2+2*E(4) mod 5 ), 
  ( 2+3*E(4) mod 5 ), ( 2+4*E(4) mod 5 ), ( 3+E(4) mod 5 ), 
  ( 3+2*E(4) mod 5 ), ( 3+3*E(4) mod 5 ), ( 3+4*E(4) mod 5 ), 
  ( 4+E(4) mod 5 ), ( 4+2*E(4) mod 5 ), ( 4+3*E(4) mod 5 ), 
  ( 4+4*E(4) mod 5 ) ]
gap> One(R);
( 1 mod 5 )
gap> IsUnit(One(R));
true
gap> Zero(R);
( 0 mod 5 )
gap> IsUnit(Zero(R));
false
gap> a:=E(4)*One(R);
( E(4) mod 5 )
gap> b:=-One(R);
( 4 mod 5 )
gap> c:=a+b;
( 4+E(4) mod 5 )
gap> d:=E(4)+c;
( 4+2*E(4) mod 5 )
gap> c+2;
( 1+E(4) mod 5 )
gap> d*E(4);
( 3+4*E(4) mod 5 )
gap> d*3;
( 2+E(4) mod 5 )
gap> ZmodnZObj(2,4)*d;
( 3+4*E(4) mod 5 )
gap> d*ZmodnZObj(2,4);
( 3+4*E(4) mod 5 )
gap> a*c;
( 4+4*E(4) mod 5 )
gap> IsUnit(a);
true
gap> Zero(a);
( 0 mod 5 )
gap> One(a);
( 1 mod 5 )
gap> Zero(a) in R;
true
gap> One(a) in R;
true
gap> Cyclotomic(d);
4+2*E(4)
gap> a*a^-1;
( 1 mod 5 )
gap> a*a^-1=One(R);
true
gap> d^-1;
fail
gap> Number(R,IsUnit);
16
gap> Number(R,x->IsUnit(R,x));
16
gap> RingInt(GF(2));
Error, RingOfIntegralCyclotomics : an argument is not cyclotomic field !
gap> STOP_TEST( "zmodnze.tst", 1);

#############################################################################
##
#E
