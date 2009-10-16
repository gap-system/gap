#############################################################################
##
#W  zxz.tst                  GAP4 Package `RCWA'                  Stefan Kohl
##
#H  @(#)$Id: zxz.tst,v 1.22 2008/02/26 16:19:47 stefan Exp $
##
##  This file contains automated tests of RCWA's functionality for
##  rcwa mappings of and rcwa groups over Z^2.
##
gap> START_TEST("$Id: zxz.tst,v 1.22 2008/02/26 16:19:47 stefan Exp $");
gap> RCWADoThingsToBeDoneBeforeTest();
gap> L1 := [ [ 2, 1 ], [ -1, 2 ] ];;
gap> L2 := [ [ 6, 2 ], [ 0, 6 ] ];;
gap> R := DefaultRing(L1,L2);
( Integers^[ 2, 2 ] )
gap> DefaultRing([[1,2,3],[4,5,6],[7,8,9]]);
( Integers^[ 3, 3 ] )
gap> Lcm(L1,L2);
[ [ 6, 8 ], [ 0, 30 ] ]
gap> Lcm(R,L1,L2);
[ [ 6, 8 ], [ 0, 30 ] ]
gap> Lcm(L1,L1);
[ [ 1, 3 ], [ 0, 5 ] ]
gap> SigmaT := RcwaMapping( Integers^2, [[1,0],[0,6]],
>                           [[[0,0],[[[2,0],[0,1]],[0,0],2]],
>                            [[0,1],[[[4,0],[0,3]],[0,1],2]],
>                            [[0,2],[[[2,0],[0,1]],[0,0],2]],
>                            [[0,3],[[[4,0],[0,3]],[0,1],2]],
>                            [[0,4],[[[4,0],[0,1]],[2,0],2]],
>                            [[0,5],[[[4,0],[0,3]],[0,1],2]]] );
<rcwa mapping of Z^2 with modulus (1,0)Z+(0,6)Z>
gap> Mod(SigmaT);
[ [ 1, 0 ], [ 0, 6 ] ]
gap> Mult(SigmaT);
[ [ 4, 0 ], [ 0, 3 ] ]
gap> Div(SigmaT);
2
gap> IsBalanced(SigmaT);
false
gap> Lcm(Mult(SigmaT),Mod(SigmaT));
[ [ 4, 0 ], [ 0, 6 ] ]
gap> inc := IncreasingOn(SigmaT);
(0,1)+(1,0)Z+(0,2)Z
gap> Density(inc);
1/2
gap> dec := DecreasingOn(SigmaT);
(0,0)+(1,0)Z+(0,6)Z U (0,2)+(1,0)Z+(0,6)Z
gap> Density(dec);
1/3
gap> Intersection(inc,dec);
[  ]
gap> R := Integers^2;
( Integers^2 )
gap> Source(SigmaT);
( Integers^2 )
gap> Union(inc,dec);
Z^2 \ (0,4)+(1,0)Z+(0,6)Z
gap> S := last;;
gap> Difference(R,S);
(0,4)+(1,0)Z+(0,6)Z
gap> IsClassWiseOrderPreserving(SigmaT);
true
gap> ClassWiseOrderPreservingOn(SigmaT);
( Integers^2 )
gap> ClassWiseOrderReversingOn(SigmaT);
[  ]
gap> ClassWiseConstantOn(SigmaT);
[  ]
gap> ClassWiseOrderPreservingOn(One(SigmaT));
( Integers^2 )
gap> ClassWiseConstantOn(One(SigmaT));
[  ]
gap> ClassWiseConstantOn(Zero(SigmaT));
( Integers^2 )
gap> PrimeSet(SigmaT);
[ 2, 3 ]
gap> IsOne(SigmaT);
false
gap> IsZero(SigmaT);
false
gap> l := LargestSourcesOfAffineMappings(SigmaT);
[ (0,1)+(1,0)Z+(0,2)Z, (0,0)+(1,0)Z+(0,6)Z U (0,2)+(1,0)Z+(0,6)Z, 
  (0,4)+(1,0)Z+(0,6)Z ]
gap> Union(l);
( Integers^2 )
gap> List(l,Density);
[ 1/2, 1/3, 1/6 ]
gap> ImageDensity(SigmaT);
1
gap> Multpk(SigmaT,2,1);
[  ]
gap> Multpk(SigmaT,2,0);
Z^2 \ (0,0)+(1,0)Z+(0,6)Z U (0,2)+(1,0)Z+(0,6)Z
gap> Multpk(SigmaT,2,-1);
(0,0)+(1,0)Z+(0,6)Z U (0,2)+(1,0)Z+(0,6)Z
gap> Multpk(SigmaT,3,0);
(0,0)+(1,0)Z+(0,2)Z
gap> Multpk(SigmaT,3,1);
(0,1)+(1,0)Z+(0,2)Z
gap> Union(last,last2);
( Integers^2 )
gap> Multpk(SigmaT,3,-1);
[  ]
gap> Multpk(SigmaT,3,2);
[  ]
gap> Image(SigmaT);
( Integers^2 )
gap> IsBijective(SigmaT);
true
gap> Display(SigmaT);

Bijective rcwa mapping of Z^2 with modulus (1,0)Z+(0,6)Z

    [m,n] mod (1,0)Z+(0,6)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0] [0,2]                   | [m,n/2]
 [0,1] [0,3] [0,5]             | [2m,(3n+1)/2]
 [0,4]                         | [2m+1,n/2]

gap> Display(SigmaT:VarNames:="v");

Bijective rcwa mapping of Z^2 with modulus (1,0)Z+(0,6)Z

      v mod (1,0)Z+(0,6)Z      |                 Image of v
-------------------------------+----------------------------------------------
 [0,0] [0,2]                   | v * [[2,0],[0,1]]/2
 [0,1] [0,3] [0,5]             | (v * [[4,0],[0,3]] + [0,1])/2
 [0,4]                         | (v * [[4,0],[0,1]] + [2,0])/2

gap> Display(SigmaT^-1);

Bijective rcwa mapping of Z^2 with modulus (2,0)Z+(0,3)Z

    [m,n] mod (2,0)Z+(0,3)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0] [0,1] [1,0] [1,1]       | [m,2n]
 [0,2]                         | [m/2,(2n-1)/3]
 [1,2]                         | [(m-1)/2,2n]

gap> Display(SigmaT^-1:VarNames:="v");

Bijective rcwa mapping of Z^2 with modulus (2,0)Z+(0,3)Z

      v mod (2,0)Z+(0,3)Z      |                 Image of v
-------------------------------+----------------------------------------------
 [0,0] [0,1] [1,0] [1,1]       | v * [[1,0],[0,2]]
 [0,2]                         | (v * [[3,0],[0,4]] + [0,-2])/6
 [1,2]                         | (v * [[1,0],[0,4]] + [-1,0])/2

gap> Display(SigmaT^2);

Bijective rcwa mapping of Z^2 with modulus (1,0)Z+(0,12)Z

   [m,n] mod (1,0)Z+(0,12)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0]                         | [m,n/4]
 [0,1]  [0,5]  [0,9]           | [2m,(3n+1)/4]
 [0,2]  [0,6]                  | [2m,(3n+2)/4]
 [0,3]  [0,7]  [0,11]          | [4m,(9n+5)/4]
 [0,4]  [0,8]                  | [2m+1,n/4]
 [0,10]                        | [4m+2,(3n+2)/4]

gap> SigmaT*SigmaT^-1;
IdentityMapping( ( Integers^2 ) )
gap> SigmaT^2*SigmaT^-1;
<bijective rcwa mapping of Z^2 with modulus (1,0)Z+(0,6)Z>
gap> last=SigmaT;
true
gap> SigmaT^-1*SigmaT^2 = SigmaT;
true
gap> SigmaT^-1*SigmaT^2*SigmaT^-1;
IdentityMapping( ( Integers^2 ) )
gap> [4,27]^SigmaT;
[ 8, 41 ]
gap> [[4,27],[8,41]]^SigmaT;
[ [ 8, 41 ], [ 16, 62 ] ]
gap> Cartesian([-2..2],[-2..2])^SigmaT;
[ [ -4, -1 ], [ -4, 2 ], [ -3, -1 ], [ -2, -1 ], [ -2, 0 ], [ -2, 1 ],
  [ -2, 2 ], [ -1, -1 ], [ -1, 0 ], [ -1, 1 ], [ 0, -1 ], [ 0, 0 ], [ 0, 1 ],
  [ 0, 2 ], [ 1, -1 ], [ 1, 0 ], [ 1, 1 ], [ 2, -1 ], [ 2, 0 ], [ 2, 1 ],
  [ 2, 2 ], [ 3, -1 ], [ 4, -1 ], [ 4, 2 ], [ 5, -1 ] ]
gap> l^SigmaT;
[ (0,2)+(2,0)Z+(0,3)Z, Z^2 \ (0,2)+(1,0)Z+(0,3)Z, (1,2)+(2,0)Z+(0,3)Z ]
gap> List(last,Density);
[ 1/6, 2/3, 1/6 ]
gap> Union(last2);
( Integers^2 )
gap> cls := AllResidueClassesModulo(R,L1);
[ (0,0)+(1,3)Z+(0,5)Z, (0,1)+(1,3)Z+(0,5)Z, (0,2)+(1,3)Z+(0,5)Z,
  (0,3)+(1,3)Z+(0,5)Z, (0,4)+(1,3)Z+(0,5)Z ]
gap> imgs := cls^SigmaT;
[ <union of 30 residue classes (mod (10,0)Z+(0,15)Z)>,
  <union of 30 residue classes (mod (10,0)Z+(0,15)Z)>,
  <union of 30 residue classes (mod (10,0)Z+(0,15)Z)>,
  <union of 30 residue classes (mod (10,0)Z+(0,15)Z)>,
  <union of 30 residue classes (mod (10,0)Z+(0,15)Z)> ]
gap> Union(imgs);
( Integers^2 )
gap> List(imgs,AsUnionOfFewClasses);
[ [ (0,0)+(1,9)Z+(0,15)Z, (0,10)+(1,9)Z+(0,15)Z, (0,8)+(2,12)Z+(0,15)Z,
      (1,5)+(2,9)Z+(0,15)Z ],
  [ (0,3)+(1,9)Z+(0,15)Z, (0,13)+(1,9)Z+(0,15)Z, (0,2)+(2,12)Z+(0,15)Z,
      (1,8)+(2,9)Z+(0,15)Z ],
  [ (0,1)+(1,9)Z+(0,15)Z, (0,6)+(1,9)Z+(0,15)Z, (0,11)+(2,12)Z+(0,15)Z,
      (1,11)+(2,9)Z+(0,15)Z ],
  [ (0,4)+(1,9)Z+(0,15)Z, (0,9)+(1,9)Z+(0,15)Z, (0,5)+(2,12)Z+(0,15)Z,
      (1,14)+(2,9)Z+(0,15)Z ],
  [ (0,7)+(1,9)Z+(0,15)Z, (0,12)+(1,9)Z+(0,15)Z, (0,14)+(2,12)Z+(0,15)Z,
      (1,2)+(2,9)Z+(0,15)Z ] ]
gap> twice := RcwaMapping(R,[[1,0],[0,1]],[[[0,0],[[[2,0],[0,2]],[0,0],1]]]);
Rcwa mapping of Z^2: [m,n] -> [2m,2n]
gap> IsSurjective(twice);
false
gap> IsInjective(twice);
true
gap> Image(twice);
(0,0)+(2,0)Z+(0,2)Z
gap> ImageDensity(twice);
1/4
gap> twice;
Injective rcwa mapping of Z^2: [m,n] -> [2m,2n]
gap> Support(twice);
Z^2 \ [ [ 0, 0 ] ]
gap> g := RcwaMapping(ClassTransposition(0,2,1,2),ClassShift(0,3));
<rcwa mapping of Z^2 with modulus (2,0)Z+(0,3)Z>
gap> Display(g);

Rcwa mapping of Z^2 with modulus (2,0)Z+(0,3)Z

    [m,n] mod (2,0)Z+(0,3)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0]                         | [m+1,n+3]
 [0,1] [0,2]                   | [m+1,n]
 [1,0]                         | [m-1,n+3]
 [1,1] [1,2]                   | [m-1,n]

gap> Projections(g);
[ <rcwa mapping of Z with modulus 2>, <rcwa mapping of Z with modulus 3> ]
gap> List(last,Factorization);
[ [ ClassTransposition(0,2,1,2) ], [ ClassShift(0,3) ] ]
gap> transvection := RcwaMapping(R,[[1,0],[0,1]],[[[[1,1],[1,0]],[0,0],1]]);
Rcwa mapping of Z^2: [m,n] -> [m+n,m]
gap> g := transvection*SigmaT;
<rcwa mapping of Z^2 with modulus (6,0)Z+(0,1)Z>
gap> Display(g);

Rcwa mapping of Z^2 with modulus (6,0)Z+(0,1)Z

    [m,n] mod (6,0)Z+(0,1)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0] [2,0]                   | [m+n,m/2]
 [1,0] [3,0] [5,0]             | [2m+2n,(3m+1)/2]
 [4,0]                         | [2m+2n+1,m/2]

gap> IsBijective(g);
true
gap> ct := ClassTransposition(0,2,1,2);
ClassTransposition(0,2,1,2)
gap> g := RcwaMapping(ct,One(ct));
ClassTransposition((0,0)+(2,0)Z+(0,1)Z,(1,0)+(2,0)Z+(0,1)Z)
gap> elm1 := SigmaT*g;
<rcwa mapping of Z^2 with modulus (2,0)Z+(0,6)Z>
gap> elm2 := g*SigmaT^-1;
<rcwa mapping of Z^2 with modulus (2,0)Z+(0,3)Z>
gap> elm1*elm2;
IdentityMapping( ( Integers^2 ) )
gap> elm2*elm1;
IdentityMapping( ( Integers^2 ) )
gap> P1 := SplittedClass(R,[2,2]);
[ (0,0)+(2,0)Z+(0,2)Z, (0,1)+(2,0)Z+(0,2)Z, (1,0)+(2,0)Z+(0,2)Z, 
  (1,1)+(2,0)Z+(0,2)Z ]
gap> P1[2] := SplittedClass(P1[2],[2,3]);;
gap> P1 := Flat(P1);
[ (0,0)+(2,0)Z+(0,2)Z, (0,1)+(4,0)Z+(0,6)Z, (0,3)+(4,0)Z+(0,6)Z, 
  (0,5)+(4,0)Z+(0,6)Z, (2,1)+(4,0)Z+(0,6)Z, (2,3)+(4,0)Z+(0,6)Z, 
  (2,5)+(4,0)Z+(0,6)Z, (1,0)+(2,0)Z+(0,2)Z, (1,1)+(2,0)Z+(0,2)Z ]
gap> P2 := Set(P1);;
gap> g := RcwaMapping(P1,P2);
<bijective rcwa mapping of Z^2 with modulus (4,0)Z+(0,6)Z>
gap> P1^g;
[ (0,0)+(2,0)Z+(0,2)Z, (1,0)+(2,0)Z+(0,2)Z, (1,1)+(2,0)Z+(0,2)Z, 
  (0,1)+(4,0)Z+(0,6)Z, (0,3)+(4,0)Z+(0,6)Z, (0,5)+(4,0)Z+(0,6)Z, 
  (2,1)+(4,0)Z+(0,6)Z, (2,3)+(4,0)Z+(0,6)Z, (2,5)+(4,0)Z+(0,6)Z ]
gap> last=P2;
true
gap> Union(P1);
( Integers^2 )
gap> Union(P2);
( Integers^2 )
gap> List(P1,Density);
[ 1/4, 1/24, 1/24, 1/24, 1/24, 1/24, 1/24, 1/4, 1/4 ]
gap> List(P2,Density);
[ 1/4, 1/4, 1/4, 1/24, 1/24, 1/24, 1/24, 1/24, 1/24 ]
gap> Display(g);

Bijective rcwa mapping of Z^2 with modulus (4,0)Z+(0,6)Z

    [m,n] mod (4,0)Z+(0,6)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0] [0,2] [0,4] [2,0]       | 
 [2,2] [2,4]                   | [m,n]
 [0,1]                         | [(m+2)/2,(n-1)/3]
 [0,3]                         | [(m+2)/2,n/3]
 [0,5] [2,5]                   | [m,n-4]
 [1,0] [1,2] [1,4] [3,0]       | 
 [3,2] [3,4]                   | [2m,3n+3]
 [1,1] [1,3] [1,5] [3,1]       | 
 [3,3] [3,5]                   | [2m,3n+2]
 [2,1] [2,3]                   | [m-2,n+2]

gap> ct := ClassTransposition(P1[1],P1[2]);
ClassTransposition((0,0)+(2,0)Z+(0,2)Z,(0,1)+(4,0)Z+(0,6)Z)
gap> Display(ct);

Bijective rcwa mapping of Z^2 with modulus (4,0)Z+(0,6)Z, of order 2

    [m,n] mod (4,0)Z+(0,6)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0] [0,2] [0,4] [2,0]       | 
 [2,2] [2,4]                   | [2m,3n+1]
 [0,1]                         | [m/2,(n-1)/3]
 [0,3] [0,5] [1,0] [1,1]       | 
 [1,2] [1,3] [1,4] [1,5]       | 
 [2,1] [2,3] [2,5] [3,0]       | 
 [3,1] [3,2] [3,3] [3,4]       | 
 [3,5]                         | [m,n]

gap> ct*ct;
IdentityMapping( ( Integers^2 ) )
gap> G := SL(2,Integers);;
gap> phi := IsomorphismRcwaGroup(G,cls[2]);
[ [ [ 0, 1 ], [ -1, 0 ] ], [ [ 1, 1 ], [ 0, 1 ] ] ] ->
[ ClassRotation((0,1)+(1,3)Z+(0,5)Z,[[0,1],[-1,0]]),
  ClassRotation((0,1)+(1,3)Z+(0,5)Z,[[1,1],[0,1]]) ]
gap> G := GL(2,Integers);;
gap> phi := IsomorphismRcwaGroup(G,cls[3]);
[ [ [ 0, 1 ], [ 1, 0 ] ], [ [ -1, 0 ], [ 0, 1 ] ], [ [ 1, 1 ], [ 0, 1 ] ]
 ] -> [ ClassRotation((0,2)+(1,3)Z+(0,5)Z,[[0,1],[1,0]]),
  ClassRotation((0,2)+(1,3)Z+(0,5)Z,[[-1,0],[0,1]]),
  ClassRotation((0,2)+(1,3)Z+(0,5)Z,[[1,1],[0,1]]) ]
gap> mat := [[12,7],[5,3]];;
gap> mat^phi;
ClassRotation((0,2)+(1,3)Z+(0,5)Z,[[12,7],[5,3]])
gap> Display(last);

Tame bijective rcwa mapping of Z^2 with modulus (1,3)Z+(0,5)Z, of order infini\
ty

    [m,n] mod (1,3)Z+(0,5)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0] [0,1] [0,3] [0,4]       | [m,n]
 [0,2]                         | [9m+n-2,53m+6n-10]

gap> (mat^2)^phi = (mat^phi)^2;
true
gap> (mat^-1)^phi = (mat^phi)^-1;
true
gap> r := Restriction(SigmaT,IdentityRcwaMappingOfZxZ*[[2,0],[0,1]]+[1,0]);
<bijective rcwa mapping of Z^2 with modulus (2,0)Z+(0,6)Z>
gap> Display(r);

Bijective rcwa mapping of Z^2 with modulus (2,0)Z+(0,6)Z

    [m,n] mod (2,0)Z+(0,6)Z    |               Image of [m,n]
-------------------------------+----------------------------------------------
 [0,0] [0,1] [0,2] [0,3]       |
 [0,4] [0,5]                   | [m,n]
 [1,0] [1,2]                   | [m,n/2]
 [1,1] [1,3] [1,5]             | [2m-1,(3n+1)/2]
 [1,4]                         | [2m+1,n/2]

gap> Induction(r,IdentityRcwaMappingOfZxZ*[[2,0],[0,1]]+[1,0]);
<bijective rcwa mapping of Z^2 with modulus (1,0)Z+(0,6)Z>
gap> last=SigmaT;
true
gap> IsClassWiseTranslating(SigmaT);
false
gap> IsClassWiseTranslating(IdentityRcwaMappingOfZxZ);
true
gap> IsClassWiseTranslating(ClassShift([0,0],[[2,0],[0,2]],1));
true
gap> RCWADoThingsToBeDoneAfterTest();
gap> STOP_TEST( "zxz.tst", 2000000000 );

#############################################################################
##
#E  zxz.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here