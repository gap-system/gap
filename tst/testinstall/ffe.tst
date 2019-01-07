#@local Rochambeau,e,F,f1,f2,f3,p,pol,qs,r,x,bigPrime,z,odds,evens
#@local r1,r2,r3,sf1,sf2,sf3,q,q2
gap> START_TEST("ffe.tst");

#
# setup
#
gap> bigPrime:=NextPrimeInt(2^60);
1152921504606847009

#
# Z, ZOp: constructing FFE elements
#
gap> List([2,3,4,5,7,8,9,25,37^3], Z);
[ Z(2)^0, Z(3), Z(2^2), Z(5), Z(7), Z(2^3), Z(3^2), Z(5^2), Z(37^3) ]

# input validation
gap> Z(fail);
Error, Z: <q> must be a positive prime power (not the value 'fail')
gap> Z(0);
Error, Z: <q> must be a positive prime power (not the integer 0)
gap> Z(1);
Error, Z: <q> must be a positive prime power (not the integer 1)
gap> Z(-2);
Error, Z: <q> must be a positive prime power (not the integer -2)
gap> Z(6);
Error, Z: <q> must be a positive prime power (not the integer 6)

# variant with two arguments
gap> Z(0,1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ZOp' on 2 arguments
gap> Z(1,0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ZOp' on 2 arguments
gap> Z(2,0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ZOp' on 2 arguments
gap> Z(2,1);
Z(2)^0

#
gap> Z(65521,1);
Z(65521)
gap> Z(65521,2);
z
gap> Z(2^16);
Z(2^16)
gap> Z(2,16);
Z(2^16)
gap> Z(bigPrime);
ZmodpZObj( 13, 1152921504606847009 )
gap> Z(bigPrime^2);
z
gap> Z(bigPrime) = Z(bigPrime,1);
true
gap> Z(bigPrime^2) = Z(bigPrime,2);
true

# verify some edge cases which previously were accepted (incorrectly)
gap> Z(6,3);
Error, Z: <p> must be a prime (not the integer 6)
gap> Z(9,1);
Error, Z: <p> must be a prime (not the integer 9)
gap> Z(9,2);
Error, Z: <p> must be a prime (not the integer 9)
gap> Z(2^16,1);
Error, Z: <p> must be a prime
gap> Z(2^16,2);
Error, Z: <p> must be a prime
gap> Z(2^17,1);
Error, Z: <p> must be a prime
gap> Z(2^17,2);
Error, Z: <p> must be a prime

# Invoking Z(p,d) with p not a prime used to crash gap, which we fixed.
# However, invocations like `Z(4,5)` still would erroneously trigger the
# creation of a type object for fields of size p^d (in the example: 1024),
# with the non-prime value p set as characteristic. This could then corrupt
# subsequent computations.
gap> Z(4,5);
Error, Z: <p> must be a prime (not the integer 4)
gap> FieldByGenerators(GF(2), [ Z(1024) ]);
GF(2^10)
gap> Characteristic(Z(1024));
2
gap> Characteristic(FamilyObj(Z(1024)));
2

#
# Constructing finite fields and their subfields
#
gap> GaloisField( 13 );
GF(13)
gap> GaloisField( 5^3 );
GF(5^3)
gap> GaloisField( 7, 2 );
GF(7^2)
gap> GaloisField( GF(4), 2 );
AsField( GF(2^2), GF(2^4) )
gap> x:= Indeterminate( GF(13) );; pol:= x^2 - x - 1;;
gap> GaloisField( 13, pol );
GF(13^2)
gap> GaloisField( GF(13), pol );
GF(13^2)
gap> p:= NextPrimeInt( 3^17 );
129140197
gap> GaloisField( p, 1 );
GF(129140197)
gap> GaloisField( p );
GF(129140197)
gap> AsField( GF(4), GF(16) );
AsField( GF(2^2), GF(2^4) )
gap> x:= Indeterminate( GF(2) );; pol:= x^2 + x + 1;;
gap> FieldExtension( GF(2), pol );
GF(2^2)
gap> FieldExtension( GF(2^3), pol );
AsField( GF(2^3), GF(2^6) )
gap> f1:= GF( 256 );
GF(2^8)
gap> f2:= GF( 2, Z(2) * [1,1,1,0,0,0,0,1,1] );
GF(2^8)
gap> f3:= GF( 2, Z(2) * [1,0,1,1,1,0,0,0,1] );
GF(2^8)

#
gap> GF(1,2,3);
Error, usage: GF( <subfield>, <extension> )
gap> GF(1,2);
Error, <subfield> must be a prime or a finite field

#
gap> FieldByGenerators( GF(2), [ Z(4), Z(8) ] );
GF(2^6)
gap> FieldByGenerators( GF(4), [ Z(4), Z(8) ] );
AsField( GF(2^2), GF(2^6) )
gap> DefaultFieldByGenerators( GF(2), [ Z(4), Z(8) ] );
GF(2^6)
gap> DefaultFieldByGenerators( GF(4), [ Z(4), Z(8) ] );
AsField( GF(2^2), GF(2^12) )
gap> RingByGenerators( [ Z(4), Z(8) ] );
GF(2^6)
gap> RingByGenerators( [ Z(4), Z(8) ] );
GF(2^6)
gap> DefaultRingByGenerators( [ Z(4), Z(8) ] );
GF(2^6)
gap> DefaultRingByGenerators( [ Z(4), Z(8) ] );
GF(2^6)
gap> Subfields( GF(81) );
[ GF(3), GF(3^2), GF(3^4) ]
gap> Subfields( GF(2^6) );
[ GF(2), GF(2^2), GF(2^3), GF(2^6) ]

#
gap> LargeGaloisField(4,1);
Error, LargeGaloisField: Characteristic must be prime
gap> LargeGaloisField(bigPrime);
GF(1152921504606847009)
gap> F:=LargeGaloisField(bigPrime,2);
GF(1152921504606847009^2)
gap> Z(bigPrime,2) = PrimitiveElement(F);
true

#
# comparing FFEs
#
gap> Z(2) < Z(2); Z(2) < Z(2); Z(2) = Z(2);
false
false
true
gap> Z(2) < 0*Z(2); 0*Z(2) < Z(2); 0*Z(2) = Z(2);
false
true
false
gap> Z(2) < Z(3); Z(3) < Z(2); Z(3) = Z(2); # cross characteristic
true
false
false

#
# test arithmetic
#

# ... in small prime fields
gap> Z(3) * Z(3);
Z(3)^0
gap> Z(3) / Z(3);
Z(3)^0
gap> Z(3) + Z(3);
Z(3)^0
gap> Z(3) - Z(3);
0*Z(3)
gap> Z(3) ^ Z(3);
Z(3)
gap> Z(3)^-1;
Z(3)
gap> (0*Z(3))^-1;
Error, FFE operations: <divisor> must not be zero

# ... in cross characteristic (results in error)
gap> Z(3) * Z(2);
Error, <x> and <y> have different characteristic
gap> Z(3) / Z(2);
Error, <x> and <y> have different characteristic
gap> Z(3) + Z(2);
Error, <x> and <y> have different characteristic
gap> Z(3) - Z(2);
Error, <x> and <y> have different characteristic
gap> Z(3) ^ Z(2);
Error, <x> and <y> have different characteristic

# ... in small non-prime fields
gap> Z(9) * Z(9);
Z(3^2)^2
gap> Z(9) / Z(9);
Z(3)^0
gap> Z(9) + Z(9);
Z(3^2)^5
gap> Z(9) - Z(9);
0*Z(3)
gap> Z(9) ^ Z(9);
Z(3^2)
gap> Z(9)^-1;
Z(3^2)^7
gap> (0*Z(9))^-1;
Error, FFE operations: <divisor> must not be zero

# ... in large prime fields
# TODO

# ... in large non-prime fields over small prime
# TODO

# ... in large non-prime fields over large prime
gap> z:=Z(bigPrime,2);
z
gap> 5^100*z;
879649375121325624z
gap> z*5^100;
879649375121325624z
gap> 5^100 mod bigPrime;
879649375121325624
gap> (5^100 + 5^100*z)/5^100;
1+z

#
# arithmetic between FFEs and rationals
#
gap> odds:=[1, 5/3, 5, (5/3)^100, 5^100];;
gap> evens:=[0, 4/3, 4, (4/3)^100, 4^100];;

#
gap> ForAll(odds, x -> x + Z(2) = 0*Z(2));
true
gap> ForAll(odds, x -> Z(2) + x = 0*Z(2));
true
gap> ForAll(evens, x -> x + Z(2) = Z(2));
true
gap> ForAll(evens, x -> Z(2) + x = Z(2));
true

#
gap> ForAll(odds, x -> x - Z(2) = 0*Z(2));
true
gap> ForAll(odds, x -> Z(2) - x = 0*Z(2));
true
gap> ForAll(evens, x -> x - Z(2) = Z(2));
true
gap> ForAll(evens, x -> Z(2) - x = Z(2));
true

#
gap> ForAll(odds, x -> x * Z(2) = Z(2));
true
gap> ForAll(odds, x -> Z(2) * x = Z(2));
true
gap> ForAll(evens, x -> x * Z(2) = 0*Z(2));
true
gap> ForAll(evens, x -> Z(2) * x = 0*Z(2));
true

#
gap> ForAll(odds, x -> x / Z(2) = Z(2));
true
gap> ForAll(odds, x -> Z(2) / x = Z(2));
true
gap> ForAll(evens, x -> x / Z(2) = 0*Z(2));
true
gap> Z(2) / 0;
Error, FFE operations: <divisor> must not be zero
gap> Z(2) / 2;
Error, FFE operations: <divisor> must not be zero

#
#
#
gap> DefiningPolynomial( f1 );
x_1^8+x_1^4+x_1^3+x_1^2+Z(2)^0
gap> DefiningPolynomial( f2 );
x_1^8+x_1^7+x_1^2+x_1+Z(2)^0
gap> DefiningPolynomial( f3 );
x_1^8+x_1^4+x_1^3+x_1^2+Z(2)^0

#
gap> r1 := RootOfDefiningPolynomial( f1 );
Z(2^8)
gap> r2 := RootOfDefiningPolynomial( f2 );
Z(2^8)^53
gap> r3 := RootOfDefiningPolynomial( f3 );
Z(2^8)
gap> sf1:=Subfield(f1, [r1]);;
gap> SetDefiningPolynomial(sf1, DefiningPolynomial( f1 ));
gap> RootOfDefiningPolynomial(sf1) = r1;
true
gap> sf2:=Subfield(f2, [r2]);;
gap> SetDefiningPolynomial(sf2, DefiningPolynomial( f2 ));
gap> RootOfDefiningPolynomial(sf2) = r2;
true
gap> sf3:=Subfield(f3, [r3]);;
gap> SetDefiningPolynomial(sf3, DefiningPolynomial( f3 ));
gap> RootOfDefiningPolynomial(sf3) = r3;
true

#
gap> Z(4) in GF(8);
false
gap> Z(4) in GF(16);
true

#
gap> Intersection( GF(2^2), GF(2^3) );
GF(2)
gap> Intersection( GF(2^4), GF(2^6) );
GF(2^2)

#
gap> Conjugates( GF(16), Z(4) );
[ Z(2^2), Z(2^2)^2, Z(2^2), Z(2^2)^2 ]
gap> Conjugates( AsField( GF(4), GF(16) ), Z(4) );
[ Z(2^2), Z(2^2) ]
gap> Conjugates( GF(4), GF(4), Z(4) );
[ Z(2^2) ]
gap> Conjugates( AsField( GF(4), GF(4) ), GF(2), Z(4) );
[ Z(2^2), Z(2^2)^2 ]
gap> Conjugates( GF(16), Z(8) );
Error, <z> must lie in <L>

#
gap> Norm( GF(16), Z(4) );
Z(2)^0
gap> Norm( AsField( GF(4), GF(16) ), Z(4) );
Z(2^2)^2
gap> Norm( GF(8), GF(8), Z(8) );
Z(2^3)
gap> Norm( AsField( GF(8), GF(8) ), GF(2), Z(8) );
Z(2)^0
gap> Norm( GF(16), Z(8) );
Error, <z> must lie in <L>

#
gap> Trace( GF(16), Z(4) );
0*Z(2)
gap> Trace( AsField( GF(4), GF(16) ), Z(4) );
0*Z(2)
gap> Trace( GF(4), GF(4), Z(4) );
Z(2^2)
gap> Trace( AsField( GF(4), GF(4) ), GF(2), Z(4) );
Z(2)^0
gap> Trace( GF(16), Z(8) );
Error, <z> must lie in <L>

#
gap> List( AsSSortedList( GF(8) ), Order );
[ 0, 1, 7, 7, 7, 7, 7, 7 ]
gap> Order(Z(bigPrime)) = bigPrime-1;
true
gap> Order(Z(bigPrime,1)) = bigPrime-1;
true
gap> Order(Z(bigPrime,2)) = bigPrime^2-1;
true

#
gap> SquareRoots( GF(2), Z(2) );
[ Z(2)^0 ]
gap> SquareRoots( GF(4), Z(4) );
[ Z(2^2)^2 ]
gap> SquareRoots( GF(3), Z(3) );
[  ]
gap> SquareRoots( GF(3), 0*Z(3) );
[ 0*Z(3) ]
gap> SquareRoots( GF(9), Z(3) );
[ Z(3^2)^2, Z(3^2)^6 ]

#
gap> List( AsSSortedList( GF(7) ), Int );
[ 0, 1, 3, 2, 6, 4, 5 ]
gap> List( AsSSortedList( GF(7) ), IntFFE );
[ 0, 1, 3, 2, 6, 4, 5 ]
gap> List( AsSSortedList( GF(7) ), IntFFESymm );
[ 0, 1, 3, 2, -1, -3, -2 ]
gap> Print(List( AsSSortedList( GF(8) ), String ),"\n");
[ "0*Z(2)", "Z(2)^0", "Z(2^3)", "Z(2^3)^2", "Z(2^3)^3", "Z(2^3)^4", 
  "Z(2^3)^5", "Z(2^3)^6" ]
gap> Int(Z(4));
Error, IntFFE: <z> must lie in prime field
gap> IntFFE(Z(4));
Error, IntFFE: <z> must lie in prime field
gap> IntFFESymm(Z(4));
Error, IntFFE: <z> must lie in prime field

#
gap> DegreeFFE( [Z(2), Z(4)]);
2
gap> DegreeFFE( [[Z(2),Z(8)],[Z(2), Z(4)]]);
6

#
# LogFFE
#
gap> q:=25;; r:=Z(q)^7;; ForAll([0..q-2], i -> LogFFE(r^i,r)=i);
true

# test cases were the elements are (internally) defined in two
# fields, neither of which contains the other (this requires some
# extra work by the kernel to compute a common field)
gap> LogFFE( Z(2^3), Z(2^2) );
fail
gap> LogFFE( Z(2^3)^7, Z(2^2) );
0
gap> q:=2^6;; q2:=2^2;; r:=Z(q2);;
gap> Filtered([0..q-1], i->Z(q)^i in GF(q2))
>  = Filtered([0..q-1], i->LogFFE(Z(q)^i, r) <> fail);
true
gap> q:=5^6;; q2:=5^3;; r:=Z(q2)^11;;
gap> Filtered([0..q-1], i->Z(q)^i in GF(q2))
>  = Filtered([0..q-1], i->LogFFE(Z(q)^i, r) <> fail);
true

# test an issue reported by MN on 2009/10/06, added by AK on 2011/01/16
gap> q:=2^16;; r:=Z(q)^2;; ForAll([0..q-2], i -> LogFFE(r^i,r)=i);
true

# test an edge case on 32 bit systems, where a kernel value could overflow
# (see https://github.com/gap-system/gap/issues/2687)
gap> q:=37^3;; r:=Z(q)^1055;; ForAll([0..q-2], i -> LogFFE(r^i,r)=i);
true

# error handling
gap> LogFFE(0*Z(2), Z(2));
Error, LogFFE: <z> must be a nonzero finite field element
gap> LogFFE(Z(2), 0*Z(2));
Error, LogFFE: <r> must be a nonzero finite field element

#
# RootFFE
#
gap> Rochambeau:=function(F)
> local e,i,p,a,r;
>  e:=Elements(F);
>  for i in [1..2*Size(F)] do
>    p:=Set(List(e,x->x^i));
>    for a in e do
>      r:=RootFFE(F,a,i);
>      if a in p and r=fail then Error("-1"); return -1;fi;
>      if r<>fail and a<>r^i then Error("1");return 1;fi;
>    od;
>  od;
>  return 0;
> end;;
gap> qs:=[2,3,4,5,7,8,9,11,13,16,17,19,25,27,32,64,81,125,128,243,256];;
gap> ForAll(qs,x->Rochambeau(GF(x))=0);
true

#
gap> STOP_TEST( "ffe.tst", 1);
