#############################################################################
##
#W  ffe.tst                     GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("ffe.tst");

#
#
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
gap> DefiningPolynomial( f1 );
x_1^8+x_1^4+x_1^3+x_1^2+Z(2)^0
gap> DefiningPolynomial( f2 );
x_1^8+x_1^7+x_1^2+x_1+Z(2)^0
gap> DefiningPolynomial( f3 );
x_1^8+x_1^4+x_1^3+x_1^2+Z(2)^0
gap> RootOfDefiningPolynomial( f1 );
Z(2^8)
gap> RootOfDefiningPolynomial( f2 );
Z(2^8)^53
gap> RootOfDefiningPolynomial( f3 );
Z(2^8)
gap> Z(4) in GF(8);
false
gap> Z(4) in GF(16);
true
gap> Intersection( GF(2^2), GF(2^3) );
GF(2)
gap> Intersection( GF(2^4), GF(2^6) );
GF(2^2)
gap> Conjugates( GF(16), Z(4) );
[ Z(2^2), Z(2^2)^2, Z(2^2), Z(2^2)^2 ]
gap> Conjugates( AsField( GF(4), GF(16) ), Z(4) );
[ Z(2^2), Z(2^2) ]
gap> Conjugates( GF(4), GF(4), Z(4) );
[ Z(2^2) ]
gap> Conjugates( AsField( GF(4), GF(4) ), GF(2), Z(4) );
[ Z(2^2), Z(2^2)^2 ]
gap> Norm( GF(16), Z(4) );
Z(2)^0
gap> Norm( AsField( GF(4), GF(16) ), Z(4) );
Z(2^2)^2
gap> Norm( GF(8), GF(8), Z(8) );
Z(2^3)
gap> Norm( AsField( GF(8), GF(8) ), GF(2), Z(8) );
Z(2)^0
gap> Trace( GF(16), Z(4) );
0*Z(2)
gap> Trace( AsField( GF(4), GF(16) ), Z(4) );
0*Z(2)
gap> Trace( GF(4), GF(4), Z(4) );
Z(2^2)
gap> Trace( AsField( GF(4), GF(4) ), GF(2), Z(4) );
Z(2)^0
gap> List( AsSSortedList( GF(8) ), Order );
[ 0, 1, 7, 7, 7, 7, 7, 7 ]
gap> SquareRoots( GF(2), Z(2) );
[ Z(2)^0 ]
gap> SquareRoots( GF(4), Z(4) );
[ Z(2^2)^2 ]
gap> SquareRoots( GF(3), Z(3) );
[  ]
gap> SquareRoots( GF(9), Z(3) );
[ Z(3^2)^2, Z(3^2)^6 ]
gap> List( AsSSortedList( GF(7) ), Int );
[ 0, 1, 3, 2, 6, 4, 5 ]
gap> Print(List( AsSSortedList( GF(8) ), String ),"\n");
[ "0*Z(2)", "Z(2)^0", "Z(2^3)", "Z(2^3)^2", "Z(2^3)^3", "Z(2^3)^4", 
  "Z(2^3)^5", "Z(2^3)^6" ]
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
# test + and * with FFEs and rationals
#
gap> odds:=[5/3, 5, (5/3)^100, 5^100];;
gap> evens:=[4/3, 4, (4/3)^100, 4^100];;

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
gap> ForAll(odds, x -> x * Z(2) = Z(2));
true
gap> ForAll(odds, x -> Z(2) * x = Z(2));
true
gap> ForAll(evens, x -> x * Z(2) = 0*Z(2));
true
gap> ForAll(evens, x -> Z(2) * x = 0*Z(2));
true

#
gap> LargeGaloisField(4,1);
Error, LargeGaloisField: Characteristic must be prime
gap> p:=NextPrimeInt(2^60);
1152921504606847009
gap> LargeGaloisField(p);
GF(1152921504606847009)
gap> F:=LargeGaloisField(p,2);
GF(1152921504606847009^2)
gap> z:=PrimitiveElement(F);
z
gap> 5^100*z;
879649375121325624z
gap> z*5^100;
879649375121325624z
gap> 5^100 mod p;
879649375121325624
gap> (5^100 + 5^100*z)/5^100;
1+z

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
gap> STOP_TEST( "ffe.tst", 1);

#############################################################################
##
#E
