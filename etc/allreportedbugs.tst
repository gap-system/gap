######### ######### ######### ######### ######### ######### ######### #########
## This is the test file, with sparse detail. See the file 
## "allreported_bugs.details" also in this directory, for 
## full details / copies of original bug messages.
##
## John McDermott Nov 99 ....
######### ######### ######### ######### ######### ######### ######### #########

gap> START_TEST("bugfixes test");

######### ######### ######### ######### ######### ######### ######### #########


## ##########
## 1111111111
## ##########
## Date: Fri, 22 Oct 1999 10:51:03 +0100
## Subject: Primitive Groups Library

gap> PrimitiveGroup(81,114); 
3^4:GL(2,9):2 < GL(4,3)_4
gap> Orbits(last,[1..81]);
[ [ 1, 28, 78, 7, 55, 37, 73, 6, 22, 54, 42, 33, 35, 24, 52, 61, 60, 5, 34, 
      44, 4, 30, 9, 64, 56, 19, 51, 50, 8, 58, 79, 36, 13, 67, 27, 49, 45, 
      59, 72, 81, 77, 46, 62, 69, 17, 47, 80, 26, 15, 70, 25, 68, 14, 63, 41, 
      53, 38, 32, 48, 57, 43, 16, 71, 31, 3, 39, 75, 23, 10, 2, 29, 74, 40, 
      65, 76, 18, 12, 66, 11, 20, 21 ] ]



## ##########
## 2222222222
## ##########
## Date: Sun, 24 Oct 1999 15:04:35 +0100
## Subject: trivial PC group detected!

gap> ct := Irr(SymmetricGroup(5));;



## ##########
## 3333333333
## ##########
## Date: Thu, 28 Oct 1999 12:05:53 +0800 (WST))
## Subject: Re: Polynomials

gap> x := Indeterminate( GF(5),"x" );
x
gap> f := x^4 - 3*x^3 + 2*x^2 +4*x - 1;
-Z(5)^0-x+Z(5)*x^2+Z(5)*x^3+x^4
gap> Factors(f);
[ Z(5)^0-x+x^2, -Z(5)^0+Z(5)^3*x+x^2 ]
gap> x := Indeterminate( GF(5),1 );  
x
gap> f := x^4 - 3*x^3 + 2*x^2 +4*x - 1;
-Z(5)^0-x+Z(5)*x^2+Z(5)*x^3+x^4
gap> Factors(f);
[ Z(5)^0-x+x^2, -Z(5)^0+Z(5)^3*x+x^2 ]



## ##########
## 4444444444
## ##########
## Date: Thu, 28 Oct 1999 17:42:25 +0200
## Subject: some minor bugs

gap> v := [Z(3)];;
gap> ConvertToVectorRep (v);;
gap> v{[]}+v{[]};;

## 1)  gap> g := SL(2,3);;                ### To check on these. 
##     gap> IsSolvable (g);;              ### Are they OK?
##     gap> SpecialPcgs (g);;             ### Were they just manual probs.?

## 2)  gap> IsPcgsCentralSeries (SpecialPcgs (SymmetricGroup (4)));
##     true



## ##########
## 5555555555
## ##########
## Date: Fri, 05 Nov 1999 11:14:14 -0500
## Subject: guava test questions

##                         WHAT WE DON'T WANT:
##

gap> RequirePackage("guava");

   ____                          |
  /            \           /   --+--  Version 1.4
 /      |    | |\\        //|    |
|    _  |    | | \\      // |     Jasper Cramwinckel
|     \ |    | |--\\    //--|     Erik Roijackers
 \     ||    | |   \\  //   |     Reinald Baart
  \___/  \___/ |    \\//    |     Eric Minkes
                                  Lea Ruscio
true
gap>  C1:=BinaryGolayCode();;
gap>  H1:=CheckMat(C1);
## [ [ Z(2)^0, Z(2)^0, Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2), Z(2)^0,
## 0*Z(2), 
##       0*Z(2), Z(2)^0, 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2),
## 0*Z(2), 
##       0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ], 
##   <an immutable GF2 vector of length 23>, <an immutable GF2 vector of
## length 
##     23>, <an immutable GF2 vector of length 23>, 
##   <an immutable GF2 vector of length 23>, <an immutable GF2 vector of
## length 
##     23>, <an immutable GF2 vector of length 23>, 
##   <an immutable GF2 vector of length 23>, <an immutable GF2 vector of
## length 
##     23>, <an immutable GF2 vector of length 23>, 
##   <an immutable GF2 vector of length 23> ]



## ##########
## 6666666666
## ##########
## Date: Mon, 8 Nov 1999 12:59:10 +0100 (MET)
## Subject: Intransitive primitive groups ...

gap> g:=PrimitiveGroup(25,20);
5^2:GL(2,5)_1
gap> Size(g);
3000
gap> IsTransitive(g,[1..25]);
true



## ##########
## 7777777777            ## ONLY CERTAIN ARCHITECTURES/OS's ?? ##
## ##########
## Date: Thu, 11 Nov 1999 19:43:50 +0100
## Subject: Re: bug in FuncNUMBER_VEC8BIT?

gap> zero := fail;; i:= 0;;
gap> iterations := 1;;
gap> dims:= [ 1,4,27,28,29,31,32,33,63,64,65,92,127,128,129,384 ];;
gap> smallprimes := Filtered (Primes, q -> q < 256);;
gap> fill := List ([1..Length(smallprimes)*Length (dims)*iterations],
>         x -> (1,10));;
gap> p := fail;;
gap> for p in smallprimes do
>       for i in dims do
>          field := GF(p);
>          f := field^i;
>          B := CanonicalBasis( f ) ;
>          ApplicableMethod (BasisVectors, [B]);
>          zero := Zero (field);
>          one := One (field);
>          id := [  ];
>          for j in [1..i] do
>             id[j] := List( [1..i], k -> zero );
>             id[j][j] := one;
>          od;
>          Unbind (fill[Length(fill)]);
>          for j in [1..i] do
>             b := p^(i-j);
>             a := p^(i-j);
>             pow := [];
>             c := 0;
>             for k in [1..i] do
>                c := c*p;
>                if k = j then
>                   c := c +1;
>                else
>                   c := c + 0;
>                fi;
>                pow[k] := c;
>             od;
>             if a <> b or b <> c then
>                Error ("incoherent results");
>             fi;
>          od;
>       od;
>    od;
gap> 



## ##########
## 8888888888
## ##########
## Date: Fri, 12 Nov 1999 01:31:19 +0100
## Subject: Index(g,g) for g a subgroup of an fp group

gap> f := FreeGroup("a","b");;
gap> g := Group(f.1);;
gap> Index(g,g);
1



## ##########
## 9999999999
## ##########
## Date: Fri, 12 Nov 1999 20:57:48 +0100 (CET)
## Subject: strange losses of storage

gap> GASMAN("message");
gap> for i in [ 1 .. 100 ] do
> LatticeSubgroups( SmallGroup( 24, 12 ) );
> Print( i, " \c" );
> GASMAN( "collect" ); od;
gap> GASMAN("message");
gap> GASMAN("message");



## ##########
##  10 10 10 
## ##########
## Date: Mon Nov 15 21:39:49 GMT 1999
## Subject: /gap/CVS/GAP/4.0/lib/oprt.gi (SparseActionHomomorphism)

gap> G:=Group((1,2),(3,4));   
Group([ (1,2), (3,4) ])
gap> N:=Group((3,4));
Group([ (3,4) ])
gap> R:=RightCosets(G,N);
[ RightCoset(Group( [ (3,4) ] ),()), RightCoset(Group( [ (3,4) ] ),(1,2)) ]
gap> h:=SparseActionHomomorphism(G,R,[RightCoset(N,())],OnRight);
<action homomorphism>
gap> ImagesSource(h);;



## ##########
##  11 11 11 
## ##########
## Date: Fri, 19 Nov 1999 10:43:04 -0600 (CST)
## Subject: Fix to semicong.gi Gap4r1 (fwd)

gap> f := FreeGroup(1);;
gap> c := SemigroupCongruenceByGeneratingPairs(f,[[f.1,f.1]]);;
gap> EquivalenceRelationPartition(c);;



## ##########
##  12 12 12 
## ##########
## Date: Tue, 23 Nov 1999 16:09:48 +0000
## Subject: Elements

gap> G:=GL(2,9);;
gap> SG:=Group([ [ [ 0*Z(3), Z(3)^0 ], [ Z(3)^0, 0*Z(3) ] ] ]);;
gap> IsSubgroup(G,SG);;
gap> Elements(ConjugacyClassSubgroups(G, SG));;



## ##########
##  13 13 13 
## ##########
## Date: Wed, 24 Nov 1999 16:30:33 +0100 (CET)
## Subject: mutability problem

gap> RequirePackage("crystcat");;
gap> G:=SpaceGroupOnRightBBNWZ( 4, 6, 3, 1, 2 );;
gap> r:=rec( translation := [ 0, 1/2, 0, 0 ],
> basis := [  ], spaceGroup := G );;
gap> IsMutable(r);
true
gap> Orbit( G, r, ImageAffineSubspaceLattice );;
gap> IsMutable(r);
true



## ##########
##  14 14 14 
## ##########
## Subject: Re: mutability problem
## Date: Wed, 24 Nov 1999 10:42:08 -0500 (EST)

## > In the current development version, the following mutability problem
## > occurs. Suppose G is a group, r a record, and f a function defining
## > an action of G on r. Then, the call Orbit( G, r, f );  makes the
## > mutable record r immutable, even though f does not change its
## > arguments. This is a rather undesirable side effect. GAP 4.1 fix 7,
## > on the other hand, works as it should.



## ##########
##  15 15 15 
## ##########
## Date: Thu, 09 Dec 1999 13:19:07 +0000
## Subject: Re: Bug in ConvertToMatrixRep 

gap> l := [];;
gap> AddSet(l,729);;
gap> AddSet(l,true);;
gap> AddSet(l,3);;
gap >true in l;
true



## ########## 
##  16 16 16 
## ##########
## Date: Thu, 9 Dec 1999 12:14:56 GMT
## Subject: committed 'GAP/4.0/lib ratfun.gi'

gap> x:= Indeterminate( Rationals, "x" );;
gap> y:= Indeterminate( Rationals, "y" );;
gap> x/y + y/x;
(x^2+y^2)/x*y



## ##########
##  17 17 17 
## ##########
## Date: Tue, 14 Dec 1999 13:22:07 +0100 (CET)
## Subject: Re: ConjugatorAutomorphism

gap> G := Group( [ (1,2,3,4) ] );
Group([ (1,2,3,4) ])
gap> phi := ConjugatorAutomorphism( G, (1,2) );
fail



## ##########
##  18 18 18 
## ##########
## Date: Thu, 16 Dec 1999 08:03:16 -0500 (EST)
## Subject: Re: Subgroup Lattice question

gap> List(c,Size);
[ 1, 3, 3, 3, 9, 18, 2, 6, 6 ]
gap> MaximalSubgroupsLattice(l);
[ [  ], [ [ 1, 1 ] ], [ [ 1, 1 ] ], [ [ 1, 1 ] ],
  [ [ 4, 1 ], [ 4, 2 ], [ 3, 1 ], [ 2, 1 ] ], [ [ 5, 1 ] ], [ [ 1, 1 ]
],
  [ [ 7, 1 ], [ 7, 2 ], [ 7, 3 ], [ 2, 1 ] ], [ [ 8, 1 ], [ 6, 1 ] ] ]



## ##########
##  19 19 19 
## ##########
## Date: Wed, 22 Dec 1999 14:42:47 +0100 (CET)
## Subject: Re: whitespace in Help

##        IS THE WHITESPACE IN HELP TOPICS BEING TREATED CORRECTLY? ##
##
## gap>		?RequirePackage  ## SHOULD WORK, DESPITE TABS BEFORE  ## 
## gap> ?library  tables         ## SHOULD WORK, DESPITE DOUBLE-SPACE ##



## ##########
##  20 20 20 
## ##########
## Date: Thu, 6 Jan 2000 09:04:19 GMT
## Subject: committed 'GAP/4.0/lib morpheus.gi'

gap> InnerAutomorphismsAutomorphismGroup( AutomorphismGroup(
> SmallGroup( 6, 1 ) ) );
<group with 2 generators>



## ##########
##  21 21 21 
## ##########
## Date: Fri, 10 Dec 1999 14:35:41 -0500
## Subject: AutomorphismGroup fails in particular instances

gap> AutomorphismGroup(SimplexCode(4));
<permutation group of size 20160 with 9 generators>


## ##########
##  22 22 22 
## ##########
## Date: Wed, 19 Jan 2000 23:43:01 -0800 (PST)
## Subject: Trouble with "Order" function      = "STRANGE BUG"    !!!!!!

gap> MinimalPolynomial( Rationals, mat, 1 );
-1+x_1-x_1^5+x_1^6
gap> MinimalPolynomial( Rationals, mat, 1 );
-1+x_1-x_1^5+x_1^6



## ##########
##  23 23 23 
## ##########
## Date: Fri, 21 Jan 2000 18:10:07 +0100 (CET)
## Subject: Re: trivial-problems

gap> IsPcGroup( AbelianGroup( IsPcGroup, [1] ) );
true
gap> DerivedSeries( AbelianGroup( [1] ) );;
gap> ElementaryAbelianGroup( 1 );;



## ##########
##  24 24 24 
## ##########
## Date: 24 Jan 2000 12:58:48 +0100
## Subject: Possible bugs

gap> F:=SL(2,13);;
gap> AutomorphismGroup(F);;



## ##########
##  25 25 25 
## ##########
## Date: Fri, 21 Jan 2000 12:44:55 +0000
## Subject: Re: SmithNormalForm 

gap> a := [[13, 5, 7], [17, 31, 39]];;
gap> SmithNormalFormIntegerMat( a );
[ [ 1, 0, 0 ], [ 0, 2, 0 ] ]



## ##########
##  26 26 26 
## ##########
## Date: Tue, 25 Jan 2000 15:40:24 +0100 (CET)
## Subject: About "IrreducibleRepresentations"

gap> IrreducibleRepresentations( AlternatingGroup( 5 ), GF(2) );;


## ##########
##  27 27 27 
## ##########
## Date: Fri, 28 Jan 2000 13:40:20 +0000
## Subject: KM Briggs question about GRAPE -- actually Library problem...

gap> g := SimplifiedFpGroup(Image(IsomorphismFpGroup(SmallGroup(29,1))));
<fp group on the generators [ F1 ]>
gap> h := Subgroup(g,[g.1]);
Group([ F1 ])
gap> AugmentedCosetTableMtc(g,h,1,"x");;



## ##########
##  28 28 28 
## ##########
## Date: Fri, 21 Jan 2000 14:02:23 -0600 (CST)
## Subject: Bug in DefaultFieldOfMatrix

gap> ReadTest("tst/algsc.tst");
true

gap> q:= QuaternionAlgebra( FieldByGenerators( Rationals, [ ER(3) ] ) );
<algebra-with-one of dimension 4 over NF(12,[ 1, 11 ])>
gap> gens:= GeneratorsOfAlgebra( q );
[ e, i, j, k ]
gap> e:= gens[1];;
gap> DefaultFieldOfMatrix( [[e]] );;



## ##########
##  29 29 29 
## ##########
## Subject: Re: bug in MinimalPolynomial
## Date: Fri, 28 Jan 2000 18:18:59 -0500 (EST)

gap> A := [ [ Z(2)^0, Z(2)^0 ], [ 0*Z(2), Z(2)^0 ] ];
> [ [ Z(2)^0, Z(2)^0 ], [ 0*Z(2), Z(2)^0 ] ]
gap> MinimalPolynomial(GF(2),A);;



## ##########
##  30 30 30 
## ##########
## Date:           Fri, 28 Jan 2000 22:02:00 +0200
## Subject:        Lie nilpotent group rings

gap> G:=DihedralGroup(128);;
gap> F:=GF(2);;
gap> FG:=GroupRing(F,G);;
gap> L:=LieAlgebra(FG);;
gap> IsLieNilpotent(L);
true



## ##########
##  31 31 31                                      ## DEV ONLY ??
## ##########
## Date: Sat, 29 Jan 2000 11:52:55 -0500 (EST)
## Subject: bug in GAP 8-bit matrix/vector representation

gap> m1:=Immutable([[Z(3^2)]]);;
gap> ConvertToMatrixRep(m1);;
gap> m2:=m1^4;;
gap> m3:=[m2[1]];;
gap> Order(m3);;



## ##########
##  32 32 32 
## ##########
## Subject: Re: [Fwd: committed 'GAP/4.0/lib pquot.gi']
## Date: Mon, 31 Jan 2000 14:46:13 +0100 (CET)

gap> C := CyclicGroup( 2 );;
gap> G := WreathProduct( C, C );;
gap> G := WreathProduct( G, C );;
gap> H := Image( IsomorphismFpGroup( G ) );;
gap> qs := PQuotient( H, 2, 10 );;
gap> Size( GroupByQuotientSystem( qs ) ) = 128;
true



######### ######### ######### ######### ######### ######### ######### #########

gap> STOP_TEST( "bugfixes test", 31560000 );

######### ######### ######### ######### ######### ######### ######### #########

gap> Print("\nTHE FOLLOWING BUGS MUST BE CHECKED MANUALLY:\n\n");
gap> Print("                                                4\n");
gap> Print("                                                5\n");
gap> Print("                                                7\n");
gap> Print("                                               14\n");
gap> Print("                                               19\n\n");

######### ######### ######### ######### ######### ######### ######### #########




