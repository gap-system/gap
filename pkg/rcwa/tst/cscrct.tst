#############################################################################
##
#W  cscrct.tst                GAP4 Package `RCWA'                 Stefan Kohl
##
##  This file contains automated tests related to series of rcwa permutations
##  like class shifts, -reflections, -rotations and -transpositions.
##
#############################################################################

gap> START_TEST( "cscrct.tst" );
gap> RCWADoThingsToBeDoneBeforeTest();
gap> x := Indeterminate(GF(4),1);; SetName(x,"x");
gap> R1 := PolynomialRing(GF(4),1);
GF(2^2)[x]
gap> y := Indeterminate(GF(25),1);; SetName(y,"y");
gap> R2 := PolynomialRing(GF(25),1);
GF(5^2)[y]
gap> ClassShift(Integers,1,2);
ClassShift(1,2)
gap> ClassShift([Integers,1,2]);
ClassShift(1,2)
gap> last^2;
ClassShift(1,2)^2
gap> LaTeXString(last);
"\\nu_{1(2)}^{2}"
gap> last2^3;
ClassShift(1,2)^6
gap> LaTeXString(last);
"\\nu_{1(2)}^{6}"
gap> last2^-1;
ClassShift(1,2)^-6
gap> LaTeXString(last);
"\\nu_{1(2)}^{-6}"
gap> last2^-2;
ClassShift(1,2)^12
gap> LaTeXString(last);
"\\nu_{1(2)}^{12}"
gap> l := [ ClassShift(0,1), ClassReflection(0,1), ClassRotation(0,1,-1),
>           ClassTransposition(0,2,1,2) ];;
gap> for g in l do SetName(g,"a"); od; l;
[ a, a, a, a ]
gap> ClassShift(Z_pi(2),0,4);
ClassShift(0,4)
gap> ClassShift(0,3);
ClassShift(0,3)
gap> ClassShift(R1,Zero(R1),x);
ClassShift(0*Z(2),x)
gap> Source(last);
GF(2^2)[x]
gap> ClassShift(Zero(R1),x);
ClassShift(0*Z(2),x)
gap> Display(last);

Bijective rcwa mapping of GF(2)[x] with modulus x, of order 2

         P mod x          |                    Image of P
--------------------------+---------------------------------------------------
 0*Z(2)                   | P + x
 Z(2)^0                   | P

gap> ClassShift([Zero(R1),x]);
ClassShift(0*Z(2),x)
gap> Source(last);
GF(2)[x]
gap> ClassShift(Integers,ResidueClass(2,3));
ClassShift(2,3)
gap> ClassShift(ResidueClass(2,3));
ClassShift(2,3)
gap> ClassShift(R1,ResidueClass(R1,x,Zero(x)));
ClassShift(0*Z(2),x)
gap> Display(last);

Bijective rcwa mapping of GF(2^2)[x] with modulus x, of order 2

         P mod x          |                    Image of P
--------------------------+---------------------------------------------------
 0*Z(2)                   | P + x
 Z(2)^0   Z(2^2)          |
 Z(2^2)^2                 | P

gap> ClassShift(ResidueClass(R1,x,Zero(x)));
ClassShift(0*Z(2),x)
gap> Source(last);
GF(2^2)[x]
gap> ClassShift(Integers);
ClassShift(0,1)
gap> ClassShift(Z_pi([2,3]));
ClassShift(0,1)
gap> ClassShift([Z_pi([2,3])]);
ClassShift(0,1)
gap> ClassShift(R1);
ClassShift(0*Z(2),Z(2)^0)
gap> Display(last);
Bijective rcwa mapping of GF(2^2)[x]: P -> P + Z(2)^0
gap> ClassReflection(Integers,1,2);
ClassReflection(1,2)
gap> ClassReflection([Integers,1,2]);
ClassReflection(1,2)
gap> ClassReflection(Z_pi(2),0,4);
ClassReflection(0,4)
gap> ClassReflection(0,3);
ClassReflection(0,3)
gap> ClassReflection(R1,Zero(R1),x);
IdentityMapping( GF(2^2)[x] )
gap> IsRcwaMapping(last);
true
gap> ClassReflection(R2,Zero(R2),y);
ClassReflection(0*Z(5),y)
gap> last^2;
IdentityMapping( GF(5^2)[y] )
gap> ClassReflection(Zero(R2),y);
ClassReflection(0*Z(5),y)
gap> ClassReflection([Zero(R2),y]);
ClassReflection(0*Z(5),y)
gap> Source(last);
GF(5)[y]
gap> ClassReflection(Integers,ResidueClass(2,3));
ClassReflection(2,3)
gap> ClassReflection(ResidueClass(2,3));
ClassReflection(2,3)
gap> ClassReflection(R2,ResidueClass(R2,y,Zero(y)));
ClassReflection(0*Z(5),y)
gap> Source(last);
GF(5^2)[y]
gap> ClassReflection(ResidueClass(R2,y,Zero(y)));
ClassReflection(0*Z(5),y)
gap> Source(last);
GF(5^2)[y]
gap> ClassReflection(Integers);
ClassReflection(0,1)
gap> ClassReflection(Z_pi([2,3]));
ClassReflection(0,1)
gap> ClassReflection([Z_pi([2,3])]);
ClassReflection(0,1)
gap> Display(last);
Bijective rcwa mapping of Z_( 2, 3 ): n -> -n
gap> ClassReflection(R2);
ClassReflection(0*Z(5),Z(5)^0)
gap> Display(last);
Bijective rcwa mapping of GF(5^2)[y]: P -> -P
gap> ClassRotation(Integers,-1);
ClassReflection(0,1)
gap> ClassRotation(Integers,1);
IdentityMapping( Integers )
gap> ClassRotation(Z_pi(2),-1);
ClassReflection(0,1)
gap> ClassRotation(Z_pi(2),1);
IdentityMapping( Z_( 2 ) )
gap> ClassRotation(Z_pi(2),1/3);
ClassRotation(0,1,1/3)
gap> ClassRotation(Z_pi(2),-1/3);
ClassRotation(0,1,-1/3)
gap> ClassRotation(Z_pi(2),1/3);
ClassRotation(0,1,1/3)
gap> Display(last);
Tame bijective rcwa mapping of Z_( 2 ): n -> 1/3 n
gap> ClassRotation(Z_pi(2),ResidueClass(Z_pi(2),2,1),3/5);
ClassRotation(1,2,3/5)
gap> Display(last);

Tame bijective rcwa mapping of Z_( 2 ) with modulus 2, of order infinity

                n mod 2                |             Image of n
---------------------------------------+--------------------------------------
  0                                    | n
  1                                    | 3/5 n + 2/5

gap> ClassRotation(ResidueClass(Z_pi(2),2,1),3/5);
ClassRotation(1,2,3/5)
gap> ClassRotation([ResidueClass(Z_pi(2),2,1),3/5]);
ClassRotation(1,2,3/5)
gap> ClassRotation(R1,ResidueClass(R1,x,Zero(R1)),Z(4)*One(R1));
ClassRotation(0*Z(2),x,Z(2^2))
gap> Display(last);

Bijective rcwa mapping of GF(2^2)[x] with modulus x, of order 3

         P mod x          |                    Image of P
--------------------------+---------------------------------------------------
 0*Z(2)                   | Z(2^2)*P
 Z(2)^0   Z(2^2)          |
 Z(2^2)^2                 | P

gap> last^-1;
ClassRotation(0*Z(2),x,Z(2^2))^2
gap> ClassRotation(R1,Z(4)*One(R1));
ClassRotation(0*Z(2),Z(2)^0,Z(2^2))
gap> Display(last);
Bijective rcwa mapping of GF(2^2)[x]: P -> Z(2^2)*P
gap> last^2;
ClassRotation(0*Z(2),Z(2)^0,Z(2^2))^2
gap> Display(last);
Bijective rcwa mapping of GF(2^2)[x]: P -> Z(2^2)^2*P
gap> ClassRotation(R2,ResidueClass(R2,y^2,y+1),Z(25)*One(R2));
ClassRotation(y+Z(5)^0,y^2,Z(5^2))
gap> last^2;
ClassRotation(y+Z(5)^0,y^2,Z(5^2))^2
gap> last^5;
ClassRotation(y+Z(5)^0,y^2,Z(5^2))^10
gap> last^12;
IdentityMapping( GF(5^2)[y] )
gap> ClassTransposition(0,2,1,2);
ClassTransposition(0,2,1,2)
gap> ClassTransposition(Integers,0,2,1,2);
ClassTransposition(0,2,1,2)
gap> ClassTransposition(Z_pi(2),0,2,1,2);
ClassTransposition(0,2,1,2)
gap> Display(last);

Bijective rcwa mapping of Z_( 2 ) with modulus 2, of order 2

                n mod 2                |             Image of n
---------------------------------------+--------------------------------------
  0                                    | n + 1
  1                                    | n - 1

gap> LaTeXString(last);
"\\tau_{0(2),1(2)}"
gap> ClassTransposition(Z_pi(2),0,2,1,4);
ClassTransposition(0,2,1,4)
gap> Support(last);
Z_( 2 ) \ 3(4)
gap> ClassTransposition(ResidueClass(0,3),ResidueClass(1,3));
ClassTransposition(0,3,1,3)
gap> Support(last);
Z \ 2(3)
gap> ClassTransposition(Integers,ResidueClass(0,3),ResidueClass(1,3));
ClassTransposition(0,3,1,3)
gap> ClassTransposition(ResidueClass(Z_pi([2,3]),3,0),
>                       ResidueClass(Z_pi([2,3]),3,1));
ClassTransposition(0,3,1,3)
gap> Support(last);
Z_( 2, 3 ) \ 2(3)
gap> Display(last2);

Bijective rcwa mapping of Z_( 2, 3 ) with modulus 3, of order 2

                n mod 3                |             Image of n
---------------------------------------+--------------------------------------
  0                                    | n + 1
  1                                    | n - 1
  2                                    | n

gap> ClassTransposition(Z_pi([2,3]),
>                       ResidueClass(Z_pi([2,3]),3,0),
>                       ResidueClass(Z_pi([2,3]),3,1));
ClassTransposition(0,3,1,3)
gap> TransposedClasses(last);
[ 0(3), 1(3) ]
gap> IsClassTransposition(last2);
true
gap> ClassTransposition(R1,ResidueClass(R1,x,Zero(R1)),
>                          ResidueClass(R1,x^2,x+1));
ClassTransposition(0*Z(2),x,x+Z(2)^0,x^2)
gap> TransposedClasses(last);
[ 0*Z(2)(mod x), x+Z(2)^0(mod x^2) ]
gap> Support(last2);
0*Z(2)(mod x) U x+Z(2)^0(mod x^2)
gap> Source(last3);
GF(2^2)[x]
gap> ClassTransposition(ResidueClass(R1,x,Zero(R1)),
>                       ResidueClass(R1,x^2,x+1));
ClassTransposition(0*Z(2),x,x+Z(2)^0,x^2)
gap> Display(last);

Bijective rcwa mapping of GF(2^2)[x] with modulus x^2, of order 2

        P mod x^2         |                    Image of P
--------------------------+---------------------------------------------------
 0*Z(2)                   |
 x                        |
 Z(2^2)*x                 |
 Z(2^2)^2*x               | x*P + x+Z(2)^0
 Z(2)^0                   |
 Z(2^2)                   |
 Z(2^2)^2                 |
 x+Z(2^2)                 |
 x+Z(2^2)^2               |
 Z(2^2)*x+Z(2)^0          |
 Z(2^2)*x+Z(2^2)          |
 Z(2^2)*x+Z(2^2)^2        |
 Z(2^2)^2*x+Z(2)^0        |
 Z(2^2)^2*x+Z(2^2)        |
 Z(2^2)^2*x+Z(2^2)^2      | P
 x+Z(2)^0                 | (P + x+Z(2)^0)/x

gap> last^2;
IdentityMapping( GF(2^2)[x] )
gap> IsRcwaMapping(last);
true
gap> ct := ClassTransposition(-100,2,141,20);
GeneralizedClassTransposition(-100,2,141,20)
gap> IsGeneralizedClassTransposition(ct);
true
gap> IsClassTransposition(ct);
false
gap> Sign(ct);
1
gap> Factorization(ct);
[ ClassShift(1,20)^-57, ClassShift(0,2)^57, ClassTransposition(0,2,1,20) ]
gap> Product(last)/ct;
IdentityMapping( Integers )
gap> TransposedClasses(ct);
[ [-100/2], [141/20] ]
gap> ct = ClassTransposition(last);
true
gap> R := Integers^2;
( Integers^2 )
gap> L := [ [ 2, 1 ], [ -1, 2 ] ];;
gap> cls := AllResidueClassesModulo(R,L);
[ (0,0)+(1,3)Z+(0,5)Z, (0,1)+(1,3)Z+(0,5)Z, (0,2)+(1,3)Z+(0,5)Z,
  (0,3)+(1,3)Z+(0,5)Z, (0,4)+(1,3)Z+(0,5)Z ]
gap> cls[2] := SplittedClass(cls[2],[2,3]);
[ (0,1)+(2,6)Z+(0,15)Z, (0,6)+(2,6)Z+(0,15)Z, (0,11)+(2,6)Z+(0,15)Z,
  (1,4)+(2,6)Z+(0,15)Z, (1,9)+(2,6)Z+(0,15)Z, (1,14)+(2,6)Z+(0,15)Z ]
gap> cls := Flat(cls);
[ (0,0)+(1,3)Z+(0,5)Z, (0,1)+(2,6)Z+(0,15)Z, (0,6)+(2,6)Z+(0,15)Z,
  (0,11)+(2,6)Z+(0,15)Z, (1,4)+(2,6)Z+(0,15)Z, (1,9)+(2,6)Z+(0,15)Z,
  (1,14)+(2,6)Z+(0,15)Z, (0,2)+(1,3)Z+(0,5)Z, (0,3)+(1,3)Z+(0,5)Z,
  (0,4)+(1,3)Z+(0,5)Z ]
gap> Union(cls);
( Integers^2 )
gap> Sum(List(cls,Density));
1
gap> ct := ClassTransposition(cls[1],cls[3]);
ClassTransposition((0,0)+(1,3)Z+(0,5)Z,(0,6)+(2,6)Z+(0,15)Z)
gap> ct = ClassTransposition(R,cls[1],cls[3]);
true
gap> ct = ClassTransposition([0,0],[[1,3],[0,5]],[0,6],[[2,6],[0,15]]);
true
gap> ct = ClassTransposition(R,[0,0],[[1,3],[0,5]],[0,6],[[2,6],[0,15]]);
true
gap> ct = ClassTransposition([R,[0,0],[[1,3],[0,5]],[0,6],[[2,6],[0,15]]]);
true
gap> ImageDensity(ct);
1
gap> ct*ct;
IdentityMapping( ( Integers^2 ) )
gap> Display(ct);

Bijective rcwa mapping of Z^2 with modulus (2,6)Z+(0,15)Z, of order 2

   [m,n] mod (2,6)Z+(0,15)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0]  [0,5]  [0,10] [1,3]    |
 [1,8]  [1,13]                 | [2m,-3m+3n+6]
 [0,1]  [0,2]  [0,3]  [0,4]    |
 [0,7]  [0,8]  [0,9]  [0,11]   |
 [0,12] [0,13] [0,14] [1,0]    |
 [1,1]  [1,2]  [1,4]  [1,5]    |
 [1,6]  [1,7]  [1,9]  [1,10]   |
 [1,11] [1,12] [1,14]          | [m,n]
 [0,6]                         | [m/2,(3m+2n-12)/6]

gap> Cycle(ct,[1,8]);
[ [ 1, 8 ], [ 2, 27 ] ]
gap> Support(ct);
(0,0)+(1,3)Z+(0,5)Z U (0,6)+(2,6)Z+(0,15)Z
gap> String(ct);
"ClassTransposition((Integers^2),[0,0],[[1,3],[0,5]],[0,6],[[2,6],[0,15]])"
gap> ViewString(ct);
"ClassTransposition((0,0)+(1,3)Z+(0,5)Z,(0,6)+(2,6)Z+(0,15)Z)"
gap> Print(ct,"\n");
ClassTransposition((Integers^2),[0,0],[[1,3],[0,5]],[0,6],[[2,6],[0,15]])
gap> cs1 := ClassShift(R,1);
ClassShift((Integers^2),1)
gap> cs2 := ClassShift(R,2);
ClassShift((Integers^2),2)
gap> Order(cs1);
infinity
gap> String(cs1);
"ClassShift((Integers^2),[0,0],[[1,0],[0,1]],1)"
gap> ViewString(cs1);
"ClassShift((Integers^2),1)"
gap> Print(cs1,"\n");
ClassShift((Integers^2),[0,0],[[1,0],[0,1]],1)
gap> cs1 = ClassShift(R,1);
true
gap> cs1 = ClassShift(R,[0,0],[[1,0],[0,1]],1);
true
gap> cs1 = ClassShift([0,0],[[1,0],[0,1]],1);
true
gap> cs1 = ClassShift([[0,0],[[1,0],[0,1]],1]);
true
gap> cs1 = cs2;
false
gap> Display(cs1);
Tame bijective rcwa mapping of Z^2: [m,n] -> [m+1,n]
gap> Display(cs2);
Tame bijective rcwa mapping of Z^2: [m,n] -> [m,n+1]
gap> Display(cs1*cs2);
Bijective rcwa mapping of Z^2: [m,n] -> [m+1,n+1]
gap> Comm(cs1,cs2);
IdentityMapping( ( Integers^2 ) )
gap> cs := ClassShift(cls[4],1);
ClassShift((0,11)+(2,6)Z+(0,15)Z,1)
gap> cs = ClassShift([0,11],[[2,6],[0,15]],1);
true
gap> cs = ClassShift(R,[0,11],[[2,6],[0,15]],1);
true
gap> cs = ClassShift([R,[0,11],[[2,6],[0,15]],1]);
true
gap> Order(cs);
infinity
gap> cls[4]^cs = cls[4];
true
gap> Support(cs);
(0,11)+(2,6)Z+(0,15)Z
gap> Display(cs);

Tame bijective rcwa mapping of Z^2 with modulus (2,6)Z+(0,15)Z, of order infin\
ity

   [m,n] mod (2,6)Z+(0,15)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0]  [0,1]  [0,2]  [0,3]    |
 [0,4]  [0,5]  [0,6]  [0,7]    |
 [0,8]  [0,9]  [0,10] [0,12]   |
 [0,13] [0,14] [1,0]  [1,1]    |
 [1,2]  [1,3]  [1,4]  [1,5]    |
 [1,6]  [1,7]  [1,8]  [1,9]    |
 [1,10] [1,11] [1,12] [1,13]   |
 [1,14]                        | [m,n]
 [0,11]                        | [m+2,n+6]

gap> String(cs);
"ClassShift((Integers^2),[0,11],[[2,6],[0,15]],1)"
gap> ViewString(cs);
"ClassShift((0,11)+(2,6)Z+(0,15)Z,1)"
gap> Print(cs,"\n");
ClassShift((Integers^2),[0,11],[[2,6],[0,15]],1)
gap> cr := ClassReflection(R);
ClassReflection((0,0)+(1,0)Z+(0,1)Z)
gap> Order(cr);
2
gap> Support(cr);
Z^2 \ [ [ 0, 0 ] ]
gap> Display(cr);
Bijective rcwa mapping of Z^2: [m,n] -> [-m,-n]
gap> cr*cr;
IdentityMapping( ( Integers^2 ) )
gap> cr := ClassReflection(cls[1]);
ClassReflection((0,0)+(1,3)Z+(0,5)Z)
gap> cr = ClassReflection(R,cls[1]);
true
gap> cr = ClassReflection(R,[0,0],[[1,3],[0,5]]);
true
gap> cr = ClassReflection([R,[0,0],[[1,3],[0,5]]]);
true
gap> Order(cr);
2
gap> Support(cr);
(0,0)+(1,3)Z+(0,5)Z \ [ [ 0, 0 ] ]
gap> Display(cr);

Bijective rcwa mapping of Z^2 with modulus (1,3)Z+(0,5)Z, of order 2

    [m,n] mod (1,3)Z+(0,5)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0]                         | [-m,-n]
 [0,1] [0,2] [0,3] [0,4]       | [m,n]

gap> String(cr);
"ClassReflection((Integers^2),[0,0],[[1,3],[0,5]])"
gap> ViewString(cr);
"ClassReflection((0,0)+(1,3)Z+(0,5)Z)"
gap> Print(cr,"\n");
ClassReflection((Integers^2),[0,0],[[1,3],[0,5]])
gap> cr := ClassRotation(cls[7],[[1,1],[0,1]]);
ClassRotation((1,14)+(2,6)Z+(0,15)Z,[[1,1],[0,1]])
gap> cr = ClassRotation(R,cls[7],[[1,1],[0,1]]);
true
gap> cr = ClassRotation([R,cls[7],[[1,1],[0,1]]]);
true
gap> cr = ClassRotation([R,[1,14],[[2,6],[0,15]],[[1,1],[0,1]]]);
true
gap> Order(cr);
infinity
gap> Support(cr);
(1,14)+(2,6)Z+(0,15)Z
gap> last^cr;
(1,14)+(2,6)Z+(0,15)Z
gap> Display(cr);

Tame bijective rcwa mapping of Z^2 with modulus (2,6)Z+(0,15)Z, of order infin\
ity

   [m,n] mod (2,6)Z+(0,15)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0]  [0,1]  [0,2]  [0,3]    |
 [0,4]  [0,5]  [0,6]  [0,7]    |
 [0,8]  [0,9]  [0,10] [0,11]   |
 [0,12] [0,13] [0,14] [1,0]    |
 [1,1]  [1,2]  [1,3]  [1,4]    |
 [1,5]  [1,6]  [1,7]  [1,8]    |
 [1,9]  [1,10] [1,11] [1,12]   |
 [1,13]                        | [m,n]
 [1,14]                        | [m,(15m+2n-15)/2]

gap> String(cr);
"ClassRotation((Integers^2),[1,14],[[2,6],[0,15]],[[1,1],[0,1]])"
gap> ViewString(cr);
"ClassRotation((1,14)+(2,6)Z+(0,15)Z,[[1,1],[0,1]])"
gap> Print(cr,"\n");
ClassRotation((Integers^2),[1,14],[[2,6],[0,15]],[[1,1],[0,1]])
gap> RCWADoThingsToBeDoneAfterTest();
gap> STOP_TEST( "cscrct.tst", 1700000000 );

#############################################################################
##
#E  cscrct.tst . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here