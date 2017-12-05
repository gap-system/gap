#############################################################################
##
#W  zmodnz.tst                  GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("zmodnz.tst");

#
# ZmodnZ constructor
#
gap> ZmodnZ(4);
(Integers mod 4)
gap> ZmodnZ(-4);
(Integers mod 4)
gap> ZmodnZ(1);
(Integers mod 1)
gap> ZmodnZ(2);
GF(2)
gap> ZmodnZ(0);
Integers
gap> ZmodnZ(-1/2);
Error, <n> must be an integer

#
# ZmodpZ constructor
#
gap> ZmodpZ(2);
GF(2)
gap> ZmodpZ(-3);
GF(3)
gap> ZmodpZ(4);
Error, <p> must be a prime

#
# small prime field
#
gap> Fam7:= ElementsFamily( FamilyObj( Integers mod 7 ) );;
gap> z0:= ZmodnZObj( Fam7, 0 );
ZmodpZObj( 0, 7 )
gap> z1:= ZmodnZObj( Fam7, -3 );
ZmodpZObj( 4, 7 )
gap> z2:= ZmodnZObj( Fam7,  1 );
ZmodpZObj( 1, 7 )
gap> z3:= ZmodnZObj( Fam7, 10 );
ZmodpZObj( 3, 7 )
gap> z1 = z2; z2 = z3;
false
false
gap> z1 < z2; z1 < z3; z2 < z3; z2 < z1; z3 < z1; z3 < z2;
false
false
true
true
true
false
gap> z1 = Zero( GF(7) ); z2 = Z(7); Zero( GF(7) ) = z1; Z(7) = z2;
false
false
false
false
gap> z2 < Z(7); Z(7) < z2;
true
false
gap> z0 < z1; z1 < z0;  z0 = Zero( GF(7) ); 
true
false
true
gap> Print(SSortedList( [ Z(7)^3, Z(7)^2, z1, z2, z3, Z(7)^5 ] ),"\n");
[ ZmodpZObj( 1, 7 ), ZmodpZObj( 3, 7 ), Z(7)^2, Z(7)^3, ZmodpZObj( 4, 7 ), 
  Z(7)^5 ]
gap> z1 + z2; z1 + z3; z2 + z3; z1 + 1; 2 + z2; z1 + Z(7); Z(7)^2 + z2;
ZmodpZObj( 5, 7 )
ZmodpZObj( 0, 7 )
ZmodpZObj( 4, 7 )
ZmodpZObj( 5, 7 )
ZmodpZObj( 3, 7 )
0*Z(7)
Z(7)
gap> z1 - z2; z1 - z3; z2 - z3; z1 - 1; 2 - z2; z1 - Z(7); Z(7)^2 - z2;
ZmodpZObj( 3, 7 )
ZmodpZObj( 1, 7 )
ZmodpZObj( 5, 7 )
ZmodpZObj( 3, 7 )
ZmodpZObj( 1, 7 )
Z(7)^0
Z(7)^0
gap> z1 * z2; z1 * z3; z2 * z3; z1 * 1; 2 * z2; z1 * Z(7); Z(7)^2 * z2;
ZmodpZObj( 4, 7 )
ZmodpZObj( 5, 7 )
ZmodpZObj( 3, 7 )
ZmodpZObj( 4, 7 )
ZmodpZObj( 2, 7 )
Z(7)^5
Z(7)^2
gap> z1 / z2; z1 / z3; z2 / z3; z1 / 1; 2 / z2; z1 / Z(7); Z(7)^2 / z2;
ZmodpZObj( 4, 7 )
ZmodpZObj( 6, 7 )
ZmodpZObj( 5, 7 )
ZmodpZObj( 4, 7 )
ZmodpZObj( 2, 7 )
Z(7)^3
Z(7)^2
gap> z2^3; z2^(-2); z2^0;
ZmodpZObj( 1, 7 )
ZmodpZObj( 1, 7 )
ZmodpZObj( 1, 7 )
gap> DegreeFFE( z1 ); DegreeFFE( z2 ); DegreeFFE( z3 );
1
1
1
gap> Int( z1 ); Int( z2 ); Int( z3 ); Int( z2 ) = Int( Z(7)^6 );
4
1
3
true
gap> SquareRoots( GF(7), z1 );
[ ZmodpZObj( 2, 7 ), ZmodpZObj( 5, 7 ) ]
gap> SquareRoots( GF(7), z2 );
[ ZmodpZObj( 1, 7 ), ZmodpZObj( 6, 7 ) ]
gap> SquareRoots( GF(7), z3 );
[  ]
gap> LogFFE(z1,z2); LogFFE(z1,z3);
fail
4
gap> LogFFE(z2,z1); LogFFE(z3,z1);
0
fail
gap> RootFFE(z1, 2); RootFFE(z1, 3);
ZmodpZObj( 2, 7 )
fail
gap> RootFFE(5, z1, 2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `LogFFE' on 2 arguments
gap> ModulusOfZmodnZObj( z1 ); ModulusOfZmodnZObj( Z(7) ); ModulusOfZmodnZObj( Z(7^2) );
7
7
fail
gap> DefaultRingByGenerators( [ z1 ] );
GF(7)

#
# large prime field
#
gap> p:= NextPrimeInt( MAXSIZE_GF_INTERNAL );
65537
gap> Famp:= ElementsFamily( FamilyObj( Integers mod p ) );;
gap> z1:= ZmodnZObj( Famp, -3 );
ZmodpZObj( 65534, 65537 )
gap> z2:= ZmodnZObj( Famp,  1 );
ZmodpZObj( 1, 65537 )
gap> z3:= ZmodnZObj( Famp, 10 );
ZmodpZObj( 10, 65537 )
gap> z1 = z2; z2 = z3;
false
false
gap> z1 < z2; z1 < z3; z2 < z3; z2 < z1; z3 < z1; z3 < z2;
false
false
true
true
true
false
gap> z1 = Zero( GF(p) ); Zero( GF(p) ) = z1;
false
false
gap> z1 + z2; z1 + z3; z2 + z3; z1 + 1; 2 + z2;
ZmodpZObj( 65535, 65537 )
ZmodpZObj( 7, 65537 )
ZmodpZObj( 11, 65537 )
ZmodpZObj( 65535, 65537 )
ZmodpZObj( 3, 65537 )
gap> z1 - z2; z1 - z3; z2 - z3; z1 - 1; 2 - z2;
ZmodpZObj( 65533, 65537 )
ZmodpZObj( 65524, 65537 )
ZmodpZObj( 65528, 65537 )
ZmodpZObj( 65533, 65537 )
ZmodpZObj( 1, 65537 )
gap> z1 * z2; z1 * z3; z2 * z3; z1 * 1; 2 * z2;
ZmodpZObj( 65534, 65537 )
ZmodpZObj( 65507, 65537 )
ZmodpZObj( 10, 65537 )
ZmodpZObj( 65534, 65537 )
ZmodpZObj( 2, 65537 )
gap> z1 / z2; z1 / z3; z2 / z3; z1 / 1; 2 / z2;
ZmodpZObj( 65534, 65537 )
ZmodpZObj( 58983, 65537 )
ZmodpZObj( 45876, 65537 )
ZmodpZObj( 65534, 65537 )
ZmodpZObj( 2, 65537 )
gap> z2^3; z2^(-2); z2^0;
ZmodpZObj( 1, 65537 )
ZmodpZObj( 1, 65537 )
ZmodpZObj( 1, 65537 )
gap> DegreeFFE( z1 ); DegreeFFE( z2 ); DegreeFFE( z3 );
1
1
1
gap> Int( z1 ); Int( z2 ); Int( z3 );
65534
1
10
gap> SquareRoots( GF(p), z1 );
[  ]
gap> SquareRoots( GF(p), z2 );
[ ZmodpZObj( 1, 65537 ), ZmodpZObj( 65536, 65537 ) ]
gap> SquareRoots( GF(p), z3 );
[  ]
gap> ModulusOfZmodnZObj( z1 );
65537
gap> DefaultRingByGenerators( [ z1 ] );
GF(65537)

#
# ring that is not a field
#
gap> Fam8:= ElementsFamily( FamilyObj( Integers mod 8 ) );;
gap> z1:= ObjByExtRep( Fam8, -3 ); ExtRepOfObj( z1 );
ZmodnZObj( 5, 8 )
5
gap> z2:= ObjByExtRep( Fam8,  1 ); ExtRepOfObj( z2 );
ZmodnZObj( 1, 8 )
1
gap> z3:= ObjByExtRep( Fam8,  3 ); ExtRepOfObj( z3 );
ZmodnZObj( 3, 8 )
3
gap> z1 = z2; z2 = z3;
false
false
gap> z1 < z2; z1 < z3; z2 < z3; z2 < z1; z3 < z1; z3 < z2;
false
false
true
true
true
false
gap> z1 + z2; z1 + z3; z2 + z3; z1 + 1; 2 + z2;
ZmodnZObj( 6, 8 )
ZmodnZObj( 0, 8 )
ZmodnZObj( 4, 8 )
ZmodnZObj( 6, 8 )
ZmodnZObj( 3, 8 )
gap> z1 - z2; z1 - z3; z2 - z3; z1 - 1; 2 - z2;
ZmodnZObj( 4, 8 )
ZmodnZObj( 2, 8 )
ZmodnZObj( 6, 8 )
ZmodnZObj( 4, 8 )
ZmodnZObj( 1, 8 )
gap> z1 * z2; z1 * z3; z2 * z3; z1 * 1; 2 * z2;
ZmodnZObj( 5, 8 )
ZmodnZObj( 7, 8 )
ZmodnZObj( 3, 8 )
ZmodnZObj( 5, 8 )
ZmodnZObj( 2, 8 )
gap> z1 / z2; z1 / z3; z2 / z3; z1 / 1; 2 / z2;
ZmodnZObj( 5, 8 )
ZmodnZObj( 7, 8 )
ZmodnZObj( 3, 8 )
ZmodnZObj( 5, 8 )
ZmodnZObj( 2, 8 )
gap> 1/2 + z1; z1 + 1/2; 1/3 + z1; z1 + 1/3;
fail
fail
ZmodnZObj( 0, 8 )
ZmodnZObj( 0, 8 )
gap> 1/2 - z1; z1 - 1/2; 1/3 - z1; z1 - 1/3;
fail
fail
ZmodnZObj( 6, 8 )
ZmodnZObj( 2, 8 )
gap> 1/2 * z1; z1 * (1/2); 1/3 * z1; z1 * (1/3);
fail
fail
ZmodnZObj( 7, 8 )
ZmodnZObj( 7, 8 )
gap> 1/2 / z1; z1 / (1/2); 1/3 / z1; z1 / (1/3);
fail
ZmodnZObj( 2, 8 )
ZmodnZObj( 7, 8 )
ZmodnZObj( 7, 8 )
gap> z2^3; z2^(-2); z2^0;
ZmodnZObj( 1, 8 )
ZmodnZObj( 1, 8 )
ZmodnZObj( 1, 8 )
gap> Int( z1 ); Int( z2 ); Int( z3 );
5
1
3
gap> IntFFESymm( z1 ); IntFFESymm( z2 ); IntFFESymm( z3 );
-3
1
3
gap> Order( z1 ); Order( z2 ); Order(z3);
2
1
2
gap> Order( z1 + z1 );
Error, <obj> is not invertible
gap> IsUnit(z1); IsUnit(2 * z1);
true
false
gap> ModulusOfZmodnZObj( z1 );
8
gap> DefaultRingByGenerators( [ z1 ] );
(Integers mod 8)

#
# enumerator
#
gap> enum:= Enumerator( Integers mod 9 );
<enumerator of (Integers mod 9)>
gap> len:= Length( enum );
9
gap> l:= [];;
gap> for i in [ 1 .. len ] do
>      l[i]:= enum[i];
>    od;
gap> Print(l,"\n");
[ ZmodnZObj( 0, 9 ), ZmodnZObj( 1, 9 ), ZmodnZObj( 2, 9 ), ZmodnZObj( 3, 9 ), 
  ZmodnZObj( 4, 9 ), ZmodnZObj( 5, 9 ), ZmodnZObj( 6, 9 ), ZmodnZObj( 7, 9 ), 
  ZmodnZObj( 8, 9 ) ]
gap> ForAll( [ 1 .. len ], i -> i = Position( enum, enum[i], 0 ) );
true
gap> Print(String(l), "\n");
[ ZmodnZObj(0,9), ZmodnZObj(1,9), ZmodnZObj(2,9), ZmodnZObj(3,9), ZmodnZObj(4,\
9), ZmodnZObj(5,9), ZmodnZObj(6,9), ZmodnZObj(7,9), ZmodnZObj(8,9) ]
gap> enum[10];
Error, <enum>[10] must have an assigned value
gap> enum[10];
Error, <enum>[10] must have an assigned value

#
# work with domains
#
gap> rings:= List( [ 2, 3, 4, 6, 8, 9 ], i -> Integers mod i );
[ GF(2), GF(3), (Integers mod 4), (Integers mod 6), (Integers mod 8), 
  (Integers mod 9) ]
gap> Print(List( rings, AsList ),"\n");
[ [ 0*Z(2), Z(2)^0 ], [ 0*Z(3), Z(3)^0, Z(3) ], 
  [ ZmodnZObj( 0, 4 ), ZmodnZObj( 1, 4 ), ZmodnZObj( 2, 4 ), 
      ZmodnZObj( 3, 4 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ), ZmodnZObj( 2, 6 ), 
      ZmodnZObj( 3, 6 ), ZmodnZObj( 4, 6 ), ZmodnZObj( 5, 6 ) ], 
  [ ZmodnZObj( 0, 8 ), ZmodnZObj( 1, 8 ), ZmodnZObj( 2, 8 ), 
      ZmodnZObj( 3, 8 ), ZmodnZObj( 4, 8 ), ZmodnZObj( 5, 8 ), 
      ZmodnZObj( 6, 8 ), ZmodnZObj( 7, 8 ) ], 
  [ ZmodnZObj( 0, 9 ), ZmodnZObj( 1, 9 ), ZmodnZObj( 2, 9 ), 
      ZmodnZObj( 3, 9 ), ZmodnZObj( 4, 9 ), ZmodnZObj( 5, 9 ), 
      ZmodnZObj( 6, 9 ), ZmodnZObj( 7, 9 ), ZmodnZObj( 8, 9 ) ] ]
gap> Print(List( rings, AsSSortedList ),"\n");
[ [ 0*Z(2), Z(2)^0 ], [ 0*Z(3), Z(3)^0, Z(3) ], 
  [ ZmodnZObj( 0, 4 ), ZmodnZObj( 1, 4 ), ZmodnZObj( 2, 4 ), 
      ZmodnZObj( 3, 4 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ), ZmodnZObj( 2, 6 ), 
      ZmodnZObj( 3, 6 ), ZmodnZObj( 4, 6 ), ZmodnZObj( 5, 6 ) ], 
  [ ZmodnZObj( 0, 8 ), ZmodnZObj( 1, 8 ), ZmodnZObj( 2, 8 ), 
      ZmodnZObj( 3, 8 ), ZmodnZObj( 4, 8 ), ZmodnZObj( 5, 8 ), 
      ZmodnZObj( 6, 8 ), ZmodnZObj( 7, 8 ) ], 
  [ ZmodnZObj( 0, 9 ), ZmodnZObj( 1, 9 ), ZmodnZObj( 2, 9 ), 
      ZmodnZObj( 3, 9 ), ZmodnZObj( 4, 9 ), ZmodnZObj( 5, 9 ), 
      ZmodnZObj( 6, 9 ), ZmodnZObj( 7, 9 ), ZmodnZObj( 8, 9 ) ] ]
gap> List( [ 1 .. Length( rings ) ], i -> Random( rings[i] ) in rings[i] );
[ true, true, true, true, true, true ]
gap> List( rings, Size );
[ 2, 3, 4, 6, 8, 9 ]
gap> Print(List( rings, Units ),"\n");
[ Group( [ Z(2)^0 ] ), Group( [ Z(3) ] ), Group( [ ZmodnZObj( 3, 4 ) ] ), 
  Group( [ ZmodnZObj( 5, 6 ) ] ), 
  Group( [ ZmodnZObj( 7, 8 ), ZmodnZObj( 5, 8 ) ] ), 
  Group( [ ZmodnZObj( 2, 9 ) ] ) ]
gap> List(rings, r -> One(r) in Units(r));
[ true, true, true, true, true, true ]
gap> List(rings, r -> 2*One(r) in Units(r));
[ false, true, false, false, false, true ]
gap> List(rings, r -> 3*One(r) in Units(r));
[ true, false, true, false, true, false ]

# arithmetic operations with matrices over residue class rings
# (From time to time, solved problems come up again because clever methods
# for matrices assume too much about the domains of their entries ...)
gap> R:= Integers mod 6;
(Integers mod 6)
gap> Print(R, "\n");
(Integers mod 6)
gap> A:= MatrixAlgebra( R, 2 );;
gap> one:= One( A );
[ [ ZmodnZObj( 1, 6 ), ZmodnZObj( 0, 6 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ) ] ]
gap> G:= GroupWithGenerators( [ one ] );;
gap> One( G );
[ [ ZmodnZObj( 1, 6 ), ZmodnZObj( 0, 6 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ) ] ]
gap> m:=[[4,1],[1,5]] * ZmodnZObj(1,6);;
gap> m in A; m in G;
true
false
gap> m2 := Inverse(m);
[ [ ZmodnZObj( 5, 6 ), ZmodnZObj( 5, 6 ) ], 
  [ ZmodnZObj( 5, 6 ), ZmodnZObj( 4, 6 ) ] ]
gap> IsOne( m * m2 ); IsOne( m2 * m );
true
true
gap> m3 := InverseSM(m); IsMutable(m3);
[ [ ZmodnZObj( 5, 6 ), ZmodnZObj( 5, 6 ) ], 
  [ ZmodnZObj( 5, 6 ), ZmodnZObj( 4, 6 ) ] ]
true
gap> m4 := InverseSM(Immutable(m)); IsMutable(m4);
[ [ ZmodnZObj( 5, 6 ), ZmodnZObj( 5, 6 ) ], 
  [ ZmodnZObj( 5, 6 ), ZmodnZObj( 4, 6 ) ] ]
false

#
gap> R:=Integers mod (2^127-1);
GF(170141183460469231731687303715884105727)
gap> x:=One(R)*3^67;
ZmodpZObj( 92709463147897837085761925410587, 
170141183460469231731687303715884105727 )
gap> Display([[x,x],[x,x]]);
ZmodnZ matrix:
[ [  92709463147897837085761925410587,  92709463147897837085761925410587 ],
  [  92709463147897837085761925410587,  92709463147897837085761925410587 ] ]
modulo 170141183460469231731687303715884105727
gap> R:=Integers mod 2^127;
(Integers mod 170141183460469231731687303715884105728)
gap> x:=One(R)*3^67;
ZmodnZObj( 92709463147897837085761925410587, 
170141183460469231731687303715884105728 )
gap> Display([[x,x],[x,x]]);
matrix over Integers mod 170141183460469231731687303715884105728:
[ [  92709463147897837085761925410587,  92709463147897837085761925410587 ],
  [  92709463147897837085761925410587,  92709463147897837085761925410587 ] ]

# test the methods for Random
gap> R := Integers mod 10;;
gap> Random(R);
ZmodnZObj( 4, 10 )
gap> Random(GlobalRandomSource, R);
ZmodnZObj( 9, 10 )

# test some additional quotients
gap> a:=ZmodnZObj(2, 6);; b:=ZmodnZObj(4, 6);;
gap> b/a;
ZmodnZObj( 2, 6 )
gap> a/b;
ZmodnZObj( 2, 6 )

#
gap> x := ZmodnZObj(2,10);
ZmodnZObj( 2, 10 )
gap> y := ZmodnZObj(0,10);
ZmodnZObj( 0, 10 )
gap> x/y;
fail
gap> y/x;
ZmodnZObj( 0, 10 )
gap> 0/x;
ZmodnZObj( 0, 10 )
gap> x/0;
fail
gap> x/3;
ZmodnZObj( 4, 10 )
gap> 3/x;
fail
gap> y/3;
ZmodnZObj( 0, 10 )
gap> 3/y;
fail

#
gap> STOP_TEST( "zmodnz.tst", 1);

#############################################################################
##
#E
