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
## 4444444444                             ## CHECK MANUALLY ##
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
## 5555555555                             ## CHECK MANUALLY ##
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



## ##########                             ## CHECK MANUALLY ##
## 7777777777                   ## (ONLY CERTAIN ARCHITECTURES/OS's ??) ##
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



## ##########                             ## CHECK MANUALLY ##
## 9999999999                    ## GASMAN OUTPUT APPEARS DURING TEST ##
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
## Date: Thu, 9 Dec 1999 12:14:56 GMT
## Subject: committed 'GAP/4.0/lib ratfun.gi'

gap> x:= Indeterminate( Rationals, "x" );;
gap> y:= Indeterminate( Rationals, "y" );;
gap> x/y + y/x;
(x^2+y^2)/x*y



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
## Date: Tue, 14 Dec 1999 13:22:07 +0100 (CET)
## Subject: Re: ConjugatorAutomorphism

gap> G := Group( [ (1,2,3,4) ] );
Group([ (1,2,3,4) ])
gap> phi := ConjugatorAutomorphism( G, (1,2) );
fail



## ##########
##  17 17 17 
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
##  18 18 18                              ## CHECK MANUALLY ##
## ##########
## Date: Wed, 22 Dec 1999 14:42:47 +0100 (CET)
## Subject: Re: whitespace in Help

##        IS THE WHITESPACE IN HELP TOPICS BEING TREATED CORRECTLY? ##
##
## gap>		?RequirePackage  ## SHOULD WORK, DESPITE TABS BEFORE  ## 
## gap> ?library  tables         ## SHOULD WORK, DESPITE DOUBLE-SPACE ##



## ##########
##  19 19 19 
## ##########
## Date: Thu, 6 Jan 2000 09:04:19 GMT
## Subject: committed 'GAP/4.0/lib morpheus.gi'

gap> InnerAutomorphismsAutomorphismGroup( AutomorphismGroup(
> SmallGroup( 6, 1 ) ) );
<group with 2 generators>



## ##########
##  20 20 20 
## ##########
## Date: Fri, 10 Dec 1999 14:35:41 -0500
## Subject: AutomorphismGroup fails in particular instances

gap> AutomorphismGroup(SimplexCode(4));
<permutation group of size 20160 with 9 generators>


## ##########
##  21 21 21 
## ##########
## Date: Wed, 19 Jan 2000 23:43:01 -0800 (PST)
## Subject: Trouble with "Order" function      = "STRANGE BUG"    !!!!!!

gap> MinimalPolynomial( Rationals, mat, 1 );
-1+x_1-x_1^5+x_1^6
gap> MinimalPolynomial( Rationals, mat, 1 );
-1+x_1-x_1^5+x_1^6



## ##########
##  22 22 22 
## ##########
## Date: Fri, 21 Jan 2000 18:10:07 +0100 (CET)
## Subject: Re: trivial-problems

gap> IsPcGroup( AbelianGroup( IsPcGroup, [1] ) );
true
gap> DerivedSeries( AbelianGroup( [1] ) );;
gap> ElementaryAbelianGroup( 1 );;



## ##########
##  23 23 23 
## ##########
## Date: 24 Jan 2000 12:58:48 +0100
## Subject: Possible bugs

gap> F:=SL(2,13);;
gap> AutomorphismGroup(F);;



## ##########
##  24 24 24 
## ##########
## Date: Fri, 21 Jan 2000 12:44:55 +0000
## Subject: Re: SmithNormalForm 

gap> a := [[13, 5, 7], [17, 31, 39]];;
gap> SmithNormalFormIntegerMat( a );
[ [ 1, 0, 0 ], [ 0, 2, 0 ] ]



## ##########
##  25 25 25 
## ##########
## Date: Tue, 25 Jan 2000 15:40:24 +0100 (CET)
## Subject: About "IrreducibleRepresentations"

gap> IrreducibleRepresentations( AlternatingGroup( 5 ), GF(2) );;


## ##########
##  26 26 26 
## ##########
## Date: Fri, 28 Jan 2000 13:40:20 +0000
## Subject: KM Briggs' question about GRAPE -- actually Library problem...

gap> g := SimplifiedFpGroup(Image(IsomorphismFpGroup(SmallGroup(29,1))));
<fp group on the generators [ F1 ]>
gap> h := Subgroup(g,[g.1]);
Group([ F1 ])
gap> AugmentedCosetTableMtc(g,h,1,"x");;



## ##########
##  27 27 27                              ## CHECK MANUALLY ##
## ##########
## Date: Fri, 21 Jan 2000 14:02:23 -0600 (CST)
## Subject: Bug in DefaultFieldOfMatrix

## gap> ReadTest("tst/algsc.tst");         ## readtest within readtest ## ????
## true

gap> q:= QuaternionAlgebra( FieldByGenerators( Rationals, [ ER(3) ] ) );
<algebra-with-one of dimension 4 over NF(12,[ 1, 11 ])>
gap> gens:= GeneratorsOfAlgebra( q );
[ e, i, j, k ]
gap> e:= gens[1];;
gap> DefaultFieldOfMatrix( [[e]] );;



## ##########
##  28 28 28 
## ##########
## Subject: Re: bug in MinimalPolynomial
## Date: Fri, 28 Jan 2000 18:18:59 -0500 (EST)

gap> A := [ [ Z(2)^0, Z(2)^0 ], [ 0*Z(2), Z(2)^0 ] ];
> [ [ Z(2)^0, Z(2)^0 ], [ 0*Z(2), Z(2)^0 ] ]
gap> MinimalPolynomial(GF(2),A);;



## ##########
##  29 29 29 
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
##  30 30 30 
## ##########
## Date: Sat, 29 Jan 2000 11:52:55 -0500 (EST)
## Subject: bug in GAP 8-bit matrix/vector representation

gap> m1:=Immutable([[Z(3^2)]]);;
gap> ConvertToMatrixRep(m1);;
gap> m2:=m1^4;;
gap> m3:=[m2[1]];;
gap> Order(m3);;



## ##########
##  31 31 31 
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



## ##########
##  32 32 32 
## ##########
## Date: Tue, 1 Feb 2000 14:41:57 +0100 (CET)
## Subject: Re: algebra

gap> G:=SymmetricGroup(2);;
gap> A:=GroupRing(GaussianRationals,G);;
gap> emb:=Embedding(G,A);;
gap> z:=Zero(A)*A;;
gap> a:=z*()^emb;;
gap> Dimension(z)=0;
true
gap> Dimension(a)=1;
true



## ##########
##  33 33 33 
## ##########
## Date: Wed, 19 Jan 2000 11:14:36 GMT
## Subject: Re: Bug report on Guava 1.4 for GAP4

gap> x := Indeterminate( GF(2), "x" );;  
gap> L := Elements( GF(8) );;   
gap> G := x^2+x+1;; 
gap> C := GoppaCode( G, L );;



## ##########
##  34 34 34 
## ##########
## Date: Mon, 7 Feb 2000 16:28:38 GMT
## Subject: lag and intersection

gap> G:= Group( (1,2));;
gap> FG:= GroupRing( GF(2), G );;
gap> L1:= LieAlgebra( FG );;
gap> B1:= Basis( L1 );;
gap> IsLieObjectsModuleRep:= IsLieObjectsModule;
<Operation "IsLieObjectsModule">
gap> RequirePackage("lag");
true
gap> FH:= GroupRing( GF(2), G );;
gap> L2:= LieAlgebra( FH );;
gap> B2:= Basis( L2 );;
gap> Intersection( B1, B2 );
[  ]



## ##########
##  35 35 35 
## ##########
## Date: Wed, 22 Dec 1999 15:03:00 +0100 (CET)
## Subject: Re: ElementaryAbelianGroup( 1 )

gap> G := ElementaryAbelianGroup( IsPermGroup, 6 );
Error <n> must be a prime power at
Error( "<n> must be a prime power" );
ElementaryAbelianGroupCons( arg[1], arg[2] ) called from
<function>( <arguments> ) called from read-eval-loop
Entering break read-eval-print loop, you can 'quit;' to quit to outer loop,
or you can return to continue
brk>



## ##########
##  36 36 36 
## ##########
## Date: Thu, 3 Feb 2000 13:49:21 -0500 (EST)
## Subject: Re: FactorGroup

gap> f:= FreeGroup(1);;
gap> x:=GeneratorsOfGroup(f)[1];;
gap> g:=Group(x^2);;
gap> IsNormal(f,g);;
gap> quo:=FactorGroup(f,g);;



## ##########
##  37 37 37 
## ##########
## Date: Mon, 07 Feb 2000 14:46:43 +0000
## Subject: IsIntegerMatrixGroup

gap> f := Group([ [ [ 0, 1 ], [ 1, 0 ] ], [ [ 11, 2 ], [ 8, 12 ] ],
> [ [ 11, 4 ], [ 7, 5 ] ] ]);;
gap> Order(f);;



## ##########
##  38 38 38                           ## CHECK MANUALLY ##
## ##########
## Date: Sun, 30 Jan 2000 15:34:52 +0100 (CET)
## Subject: Re: minor bug in GAP startup

## If .gaprc contains the error "Read:=3;", say, and the file tttt contains
## the following:

## Print( "1\n"); Print( "1a\n");
## Print( "2\n");
## Print( "3\n");
## Print( "4\n");
## Print( "5\n");

## This is what happens at startup:

## GAP banner, etc, displayed...
## brk>                  ## type CTRL-D here.
## gap> Read("tttt");
## 1                     ## and it executes only the first command from tttt.
## gap> 



## ##########
##  39 39 39 
## ##########
## Date: Wed, 26 Jan 2000 15:01:36 -0500 (EST)
## Subject: Re: p groups

gap> G := Group([ [ [ 0*Z(3), Z(3)^0 ], [ Z(3), 0*Z(3) ] ],
>   [ [ Z(3)^0, Z(3) ], [ Z(3), Z(3) ] ] ]);;
gap> IsNilpotent(G);;
gap> Size(G);;



## ##########
##  40 40 40 
## ##########
## Date: Mon, 07 Feb 2000 09:49:42 +0000
## Subject: One last bug in alltest

gap> RequirePackage("grpconst");
gap> ConstructAndTestAllGroups := function( size )
> local grps;
>     grps := ConstructAllGroups( size );
>    if Length( grps ) <> NumberSmallGroups( size ) then
>        Print( "wrong number of groups of size ", size, "\n" );
>    fi;
>    if Set( List( grps, IdGroup ) ) <>
>       List( [ 1 .. NumberSmallGroups( size ) ], x -> [ size, x ] ) then
>        Print( "wrong ids for the groups of size ", size, "\n" );
>    fi;
> end;
gap> ConstructAndTestAllGroups( 840 );;



## ##########
##  41 41 41 
## ##########
## Date: Mon, 7 Feb 2000 17:14:52 +0100 (CET)
## Subject: Re: One last bug in alltest

gap> g:= Group(());;
gap> f1:= NewFilter("f1");;  f2:= NewFilter("f2");;  f3:= f1 and f2;;
gap> SetFilterObj( g, f3 );
gap> f1(g);  f2(g);
true
true
gap> ResetFilterObj( g, f3 );
gap> f1(g);  f2(g);
false
false



## ##########
##  42 42 42 
## ##########
## Date: Thu, 27 Jan 2000 14:38:54 +0100 (CET)
## Subject: Re: p groups

gap> g:=FreeGroup(2);;
gap> f1:=GeneratorsOfGroup(g)[1];;
gap> f2:=GeneratorsOfGroup(g)[2];;
gap> r:=[ f1^-1*f2^-1*f1*f2, f1^2, f2^10 ];;
gap> g:=g/r;;
gap> HasIsFinite(g);
false
gap> IsFpGroup(g);
true
gap> IsPGroup(g);
false



## ##########
##  43 43 43 
## ##########
## Date: Tue, 1 Feb 2000 14:27:58 -0500 (EST)
## Subject: bug in group homomorphism?

gap> src := Group(
> [ [ [ Z(3)^0, Z(3), Z(3)^0, Z(3), 0*Z(3) ], 
>       [ 0*Z(3), Z(3)^0, Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], 
>      [ 0*Z(3), Z(3)^0, 0*Z(3), Z(3), Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, 0*Z(3), 0*Z(3), Z(3)^0, Z(3)^0 ], 
>       [ 0*Z(3), Z(3)^0, 0*Z(3), Z(3)^0, Z(3)^0 ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, 0*Z(3), 0*Z(3), Z(3), Z(3)^0 ], 
>       [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, Z(3), Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), Z(3)^0, Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, Z(3), 0*Z(3), Z(3), 0*Z(3) ], 
>       [ 0*Z(3), Z(3)^0, Z(3)^0, Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ] ]
> );;
gap> img := Group(
> [ [ [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, 0*Z(3), 0*Z(3), Z(3), Z(3) ], 
>       [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, 0*Z(3), 0*Z(3), Z(3)^0, Z(3)^0 ], 
>       [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
>   [ [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>       [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ] ]
> );;
gap> elt := [ [ Z(3)^0, Z(3), Z(3)^0, Z(3), 0*Z(3) ],
>   [ 0*Z(3), Z(3)^0, Z(3)^0, 0*Z(3), 0*Z(3) ], 
>   [ 0*Z(3), 0*Z(3), Z(3)^0, Z(3)^0, 0*Z(3) ], 
>   [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
>   [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ];;
gap> fun := h->Comm( h, elt );;
gap> hom := GroupHomomorphismByFunction( src, img, fun );;
gap> ker := Kernel(hom);;
gap> HasIsGroup(ker);
true



## ##########
##  44 44 44 
## ##########
## Date:           Fri, 04 Feb 2000 12:29:23 -0800
## Subject:        Problem with GQuotients

gap>  F := FreeGroup(["a","b"]);;  a := F.1;; b := F.2;;
gap>  G := F/[ a^3*b^3*a^3*b^-1*a^-1*b^-1*a^-1*b^-1, a*b^4*a^4*b^4*a*b*a*b ];;
gap>  GQuotients(G, AlternatingGroup(5));;



## ##########
##  45 45 45 
## ##########
## Date: Thu, 03 Feb 2000 14:13:23 +0000
## Subject: Testing

gap> SetModuleOfExtension;
<Operation "Setter(ModuleOfExtension)">



## ##########
##  46 46 46 
## ##########
## Date: Thu, 03 Feb 2000 14:13:23 +0000
## Subject: Testing

gap> v:= LeftModuleByGenerators( GF(9), [ [ Z(3), Z(3), Z(3) ] ] );;
gap> c:= VectorSpace( GF(9), [ [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] );;
gap> f:= v + c;;
gap> subsp:= SubspacesDim( f, 2 );
Subspaces( ( GF(3^2)^3 ), 2 )
gap> subsp:= SubspacesAll( f );
Subspaces( ( GF(3^2)^3 ), "all" )



######### ######### ######### ######### ######### ######### ######### #########

gap> STOP_TEST( "bugfixes test", 31560000 );

######### ######### ######### ######### ######### ######### ######### #########

gap> Print("\nTHE FOLLOWING BUGS MUST BE CHECKED MANUALLY:\n\n");
gap> Print("                                                4\n");
gap> Print("                                                5\n");
gap> Print("                                                7\n");
gap> Print("                                                9\n");
gap> Print("                                               18\n");
gap> Print("                                               27\n");
gap> Print("                                               38\n\n");

######### ######### ######### ######### ######### ######### ######### #########




