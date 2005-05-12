#############################################################################
##
#W  bugfix.tst
##
#H  $Id$
##
##  Exclude from testall.g: why?
##

gap> START_TEST("bugfixes test");

##  Bug 18 for fix 4
##
gap> if LoadPackage( "ctbllib" ) <> fail then
>      if Irr( CharacterTable( "WeylD", 4 ) )[1] <>
>           [ 3, -1, 3, -1, 1, -1, 3, -1, -1, 0, 0, -1, 1 ] then
>        Print( "problem with Irr( CharacterTable( \"WeylD\", 4 ) )[1]\n" );
>      fi;
>    fi;

##  Check to see if the strongly connected component (Error 3) fix has been 
##     installed  
##
gap> M := Monoid([Transformation( [ 2, 3, 4, 5, 5 ] ),
> Transformation( [ 3, 1, 4, 5, 5 ] ),
> Transformation( [ 2, 1, 4, 3, 5 ] ) ]);;
gap> Size(GreensLClasses(M)[2])=2;
true

##  Check the fix in OrbitStabilizerAlgorithm (Error 4) for infinite groups. 
##
gap> N:=GroupByGenerators(
>   [ [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ], 
>     [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ -1, 0, 0, 0 ], [ 0, -1, 0, 0 ] ], 
>     [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ -1, 0, 1, 0 ], [ 0, -1, 0, 1 ] ], 
>     [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ -1, 0, 0, -1 ], [ 0, -1, 1, 0 ] ], 
>     [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ], 
>     [ [ 0, 1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, 1 ], [ 0, 0, 1, 0 ] ] ] );
<matrix group with 6 generators>
gap> IsFinite(N);
false
gap> G:=GroupByGenerators( [ [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ], 
>   [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ] ] );
Group([ [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ] 
 ])
gap> Centralizer(N,G);
<matrix group of size infinity with 6 generators>

## iterated autgp (5)
gap> g:=Group((1,2,3),(4,5,6),(2,3)(5,6));;
gap> aut:=AutomorphismGroup(g);;
gap> ccu:=ConjugacyClasses(aut);;
gap> aut2:=AutomorphismGroup(aut);;


## field conversion (6)
gap> v := [];;
gap> ConvertToVectorRep(v,3);;
gap> ConvertToVectorRep(v,9);;


## EulerianFunction (10)
gap> EulerianFunction( DihedralGroup(8), 2);
24
gap> EulerianFunction( CyclicGroup(6), 1 );
2
gap> EulerianFunction( CyclicGroup(5), 1 );
4

gap> g:=SmallGroup(1,1);;
gap> ConjugacyClassesSubgroups(g);;

gap> g:=Group([ (3,5), (1,3,5) ]);;
gap> MaximalSubgroups(g);;

##GQuotients
gap> s := SymmetricGroup(4);;
gap> g := SmallGroup(48,1);;
gap> GQuotients(g,s);
[  ]

## Costantini bug, in inverting lists of compressed vectors
gap> p := 3;; e := 16;;
gap> g := ElementaryAbelianGroup(p^e);;
gap> l := PCentralLieAlgebra(g);;
gap> b := Basis(l);;
gap> b2 := b;;
gap> RelativeBasis(b,b2);;

## Testing if an element is in a Green's D equivalence class (fix 2 no. 12)
gap> s := Semigroup(Transformation([1,1,3,4]),Transformation([1,2,2,4]));;
gap> dc := GreensDClasses(s);;
gap> Transformation([1,1,3,4]) in dc[1];
false

## Testing if Green's D classes can be compared for finite semigroups
gap> s := Transformation([1,1,3,4,5]);;
gap> c := Transformation([2,3,4,5,1]);;
gap> op5 := Semigroup(s,c);;
gap> dcl := GreensDClasses(op5);;
gap> IsGreensLessThanOrEqual(dcl[4],dcl[5]);
false

## Testing that GroupHClassOfGreensDClass is implemented
gap> h := GroupHClassOfGreensDClass(dcl[4]);;

## Testing AssociatedReesMatrixSemigroupOfDClass.
##         IsZeroSimpleSemigroup, IsomorphismReesMatrixSemigroup,
##         and SandwichMatrixOfReesZeroMatrixSemigroup
##         create Greens D classes correctly.
gap> rms := AssociatedReesMatrixSemigroupOfDClass(dcl[5]);;
gap> s := Transformation([1,1,2]);;
gap> c := Transformation([2,3,1]);;
gap> op3 := Semigroup(s,c);;
gap> IsRegularSemigroup(op3);;
gap> dcl := GreensDClasses(op3);;
gap> d2 := dcl[2];; d1:= dcl[1];;
gap> i2 := SemigroupIdealByGenerators(op3,[Representative(d2)]);;
gap> GeneratorsOfSemigroup(i2);;
gap> i1 := SemigroupIdealByGenerators(i2,[Representative(d1)]);;
gap> GeneratorsOfSemigroup(i1);;
gap> c1 := ReesCongruenceOfSemigroupIdeal(i1);;
gap> q := i2/c1;;
gap> IsZeroSimpleSemigroup(q);;
gap> irms := IsomorphismReesMatrixSemigroup(q);;
gap> SandwichMatrixOfReesZeroMatrixSemigroup(Source(irms));;

gap> g := Group( (1,2),(1,2,3) );;
gap> i := TrivialSubgroup( g );;
gap> CentralizerModulo( g, i, (1,2) );
Group([ (1,2) ])

gap> x:= Sum( GeneratorsOfAlgebra( QuaternionAlgebra( Rationals, -2, -2 ) ) );;
gap> x * Inverse( x ) = One( x );
true
gap> LargestMovedPoint(ProjectiveSymplecticGroup(6,2)) = 63;
true
gap> t1:= CharacterTable( "Cyclic", 2 );;
gap> t2:= CharacterTable( "Cyclic", 3 );;
gap> t1 * t1;  ( t1 mod 2 ) * ( t1 mod 2 );
CharacterTable( "C2xC2" )
BrauerTable( "C2xC2", 2 )
gap> ( t1 mod 2 ) * t2;  t2 * ( t1 mod 2 );
BrauerTable( "C2xC3", 2 )
BrauerTable( "C3xC2", 2 )
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> chi:= TrivialCharacter( t );;
gap> IntScalarProducts( t, [ chi ], chi );
true
gap> NonnegIntScalarProducts( t, [ chi ], chi );
true
gap> Representative( TrivialSubgroup( Group( (1,2) ) ) );
()
gap> Representative( TrivialSubspace( GF(2)^2 ) );
[ 0*Z(2), 0*Z(2) ]

gap> g:=SmallGroup(70,3);;
gap> g:=GroupByPcgs(Pcgs(g));;
gap> IdGroup(g);
[ 70, 3 ]

##  bugs 2, 3, 6, 7, 20 for fix 2.
gap> x:= Sum( GeneratorsOfAlgebra( QuaternionAlgebra( Rationals, -2, -2 ) ) );;
gap> x * Inverse( x ) = One( x );
true
gap> LargestMovedPoint(ProjectiveSymplecticGroup(6,2)) = 63;
true
gap> t1:= CharacterTable( "Cyclic", 2 );;
gap> t2:= CharacterTable( "Cyclic", 3 );;
gap> t1 * t1;  ( t1 mod 2 ) * ( t1 mod 2 );
CharacterTable( "C2xC2" )
BrauerTable( "C2xC2", 2 )
gap> ( t1 mod 2 ) * t2;  t2 * ( t1 mod 2 );
BrauerTable( "C2xC3", 2 )
BrauerTable( "C3xC2", 2 )
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> chi:= TrivialCharacter( t );;
gap> IntScalarProducts( t, [ chi ], chi );
true
gap> NonnegIntScalarProducts( t, [ chi ], chi );
true
gap> Representative( TrivialSubgroup( Group( (1,2) ) ) );
()
gap> Representative( TrivialSubspace( GF(2)^2 ) );
[ 0*Z(2), 0*Z(2) ]

gap> G := Group(());;F := FreeGroup( 1, "f" );;
gap> hom := GroupHomomorphismByImages(F,G,GeneratorsOfGroup(F),
> GeneratorsOfGroup(G));;
gap> PreImagesRepresentative(hom,());
<identity ...>

##  bug 2 for fix 4.
gap> 1 * One( Integers mod NextPrimeInt( 2^16 ) );
ZmodpZObj( 1, 65537 )

gap> f:=FreeGroup("a","b");;g:=f/[Comm(f.1,f.2),f.1^5,f.2^7];;Pcgs(g);;
gap> n:=Subgroup(g,[g.2]);; m:=ModuloPcgs(g,n);;
gap> ExponentsOfPcElement(m,m[1]);
[ 1 ]

##  bug 11 for fix 4.
gap> x:= Indeterminate( Rationals );;
gap> f:= x^4 + 3*x^2 + 1;;
gap> F:= AlgebraicExtension( Rationals, f );;
gap> Basis( F )[1];;

# bug in ReducedSCTable:
gap> T:= EmptySCTable( 1, 0, "antisymmetric" );
[ [ [ [  ], [  ] ] ], -1, 0 ]
gap> ReducedSCTable( T, Z(3)^0 );
[ [ [ [  ], [  ] ] ], -1, 0*Z(3) ]

## Rees Matrix bug fix 4
gap> s := Semigroup(Transformation([2,3,1]));;
gap> IsSimpleSemigroup(s);;
gap> irms := IsomorphismReesMatrixSemigroup(s);;
gap> Size(Source(irms));
3

## Semigroup/Monoid rewriting system bug for fix 4
gap> f := FreeSemigroup("a","b");;
gap> a := f.1;; b := f.2;;
gap> s := f/[[a*b,b],[b*a,a]];;
gap> rws := KnuthBendixRewritingSystem(s);
Knuth Bendix Rewriting System for Semigroup( [ a, b ] ) with rules 
[ [ a*b, b ], [ b*a, a ] ]
gap> MakeConfluent(rws);
gap> rws;
Knuth Bendix Rewriting System for Semigroup( [ a, b ] ) with rules 
[ [ a*b, b ], [ b*a, a ], [ a^2, a ], [ b^2, b ] ]
gap> HasReducedConfluentRewritingSystem(s);
true

gap> x:= Indeterminate( Rationals );;
gap> a:= 1/(1+x);;
gap> b:= 1/(x+x^2);;
gap> a=b;
false

##  bugs 12 and 14 for fix 4
gap> IsRowVector( [ [ 1 ] ] );
false
gap> IsRowModule( TrivialSubmodule( GF(2)^[2,2] ) );
false

gap> g:=SL(2,5);;c:=Irr(g)[6];;
gap> hom:=IrreducibleRepresentationsDixon(g,c);;
gap> Size(Image(hom));
60

##  bug 16 for fix 4
gap> Difference( [ 1, 1 ], [] );
[ 1 ]

## bug 17 for fix 4
gap> f := FreeGroup( 2 );;
gap> g := f/[f.1^4,f.2^4,Comm(f.1,f.2)];;
gap> Elements(g);
[ <identity ...>, f1, f1^3, f2, f2^3, f1^2, f1*f2, f1*f2^3, f1^3*f2, 
  f1^3*f2^3, f2^2, f1^2*f2, f1^2*f2^3, f1*f2^2, f1^3*f2^2, f1^2*f2^2 ]

gap> NrPrimitiveGroups(441);
24

##  bug 2 for fix 5
gap> IsSubset( GF(2)^[2,2], GF(4)^[2,2] );
false

gap> G:=Group((8,12)(10,14),(8,10)(12,14),(4,6)(12,14),(2,4)(10,12),
> (4,8)(6,10), (9,13)(11,15),(9,11)(13,15),(5,7)(13,15),(3,5)(11,13),
> (5,9)(7,11));;
gap> x:=Group((1,8)(2,7)(3,6)(4,5)(9,16)(10,15)(11,14)(12,13),
> (1,9)(2,10)(3,11)(4,12)(5,13)(6,14)(7,15)(8,16),
> (1,4)(2,3)(5,8)(6,7)(9,12)(10,11)(13,16)(14,15),
> (1,10)(2,9)(3,12)(4,11)(5,14)(6,13)(7,16)(8,15));;
gap> y:=Group((1,8)(2,7)(3,6)(4,5)(9,14)(10,13)(11,16)(12,15),
> (1,11)(2,10)(3,9)(4,12)(5,15)(6,14)(7,13)(8,16),
> (1,4)(2,3)(5,8)(6,7)(9,10)(11,12)(13,14)(15,16),
> (1,10)(2,11)(3,12)(4,9)(5,14)(6,15)(7,16)(8,13));;
gap> RepresentativeAction(G,x,y)<>fail;
true

##  bug 5 for fix 5
gap> BaseOrthogonalSpaceMat( [ [ 1, 0 ] ] );
[ [ 0, 1 ] ]

##  bug 6 for fix 5
gap> IsSet( AUTOLOAD_PACKAGES );
true

##  bug 7 for fix 5
gap> tbl:= CharacterTable( "2.L2(3)" );;
gap> MolienSeries( tbl, Sum( Irr( tbl ){ [3,4] } ), Irr( tbl )[2] );
( 2*z^2+z^3-z^4+z^6 ) / ( (1-z^3)^2*(1-z^2)^2 )

##  bug 8 for fix 5
gap> l:= [ 1, 2 ];;  i:= Intersection( [ l ] );;
gap> IsIdenticalObj( l, i );
false

## bug 9 for fix 5
gap> A:=FullMatrixLieAlgebra(Rationals,2);
<Lie algebra over Rationals, with 3 generators>
gap> B:=LieDerivedSubalgebra(A);
<Lie algebra of dimension 3 over Rationals>
gap> D:=Derivations(Basis(B));
<Lie algebra of dimension 3 over Rationals>

##  bug 10 for fix 5
gap> k:=AbelianGroup([5,5,5]);
<pc group of size 125 with 3 generators>
gap> h:=SylowSubgroup(AutomorphismGroup(k),2);
<group>
gap> g:=SemidirectProduct(h,k);
<pc group with 10 generators>
gap> Centre(g);
Group([  ]) 

## bug 11 for fix 5
gap> m1:=[[0,1],[0,0]];;
gap> m2:=[[0,0],[1,0]];;
gap> m3:=[[1,0],[0,-1]];;
gap> M1:=MatrixByBlockMatrix(BlockMatrix([[1,1,m1]],2,2));;
gap> M2:=MatrixByBlockMatrix(BlockMatrix([[1,1,m2]],2,2));;
gap> M3:=MatrixByBlockMatrix(BlockMatrix([[1,1,m3]],2,2));;
gap> M4:=MatrixByBlockMatrix(BlockMatrix([[2,2,m1]],2,2));;
gap> M5:=MatrixByBlockMatrix(BlockMatrix([[2,2,m2]],2,2));;
gap> M6:=MatrixByBlockMatrix(BlockMatrix([[2,2,m3]],2,2));;
gap> L:=LieAlgebra(Rationals,[M1,M2,M3,M4,M5,M6]);
<Lie algebra over Rationals, with 6 generators>
gap> DirectSumDecomposition(L);
[ <two-sided ideal in <Lie algebra of dimension 6 over Rationals>, 
      (dimension 3)>, 
  <two-sided ideal in <Lie algebra of dimension 6 over Rationals>, 
      (dimension 3)> ]

##  bug 16 for fix 5
gap> IrrBaumClausen( Group(()));;

##  bug 17 for fix 5 (example taken from `vspcmat.tst')
gap> w:= LeftModuleByGenerators( GF(9),
> [ [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ],
> [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ],
> [ [ 0*Z(3), Z(3) ], [ Z(3), Z(3) ] ] ] );;
gap> w = AsVectorSpace( GF(3), w );
true

##  bug 18 for fix 5
gap> List( Irr( AlternatingGroup( 5 ) ), TestMonomial );;

##  bug 2 for fix 6
gap> if LoadPackage( "tomlib" ) <> fail then
>      DerivedSubgroupsTom( TableOfMarks( "A10" ) );
>    fi;

##  bug 3 for fix 6
gap> Order( ZmodnZObj( 2, 7 ) );;  Inverse( ZmodnZObj( 2, 7 ) );;

##  bug 4 for fix 6
gap> tbl:= CharacterTable( "2.L2(3)" );;
gap> z:= Indeterminate( Rationals );
x_1
gap> ser:= MolienSeries( tbl, Sum( Irr( tbl ){ [3,4] } ), Irr( tbl )[2] );;
gap> MolienSeriesWithGivenDenominator( ser, [ 6,6,4,4 ] );
( 2*z^2+z^3+3*z^4+6*z^5+3*z^6+7*z^7+7*z^8+3*z^9+6*z^10+4*z^11+z^12+3*z^13+z^14\
+z^16 ) / ( (1-z^6)^2*(1-z^4)^2 )


#############################################################################
##
##  Fixes for GAP 4.4
##

##  bug 8 for fix 1
gap> q:= QuaternionAlgebra( Rationals );;
gap> t:= TrivialSubspace( q );;
gap> tt:= Subspace( q, [] );;
gap> Intersection2( t, tt );;


gap> g:=SmallGroup(6,2);;
gap> f:=FreeGroup(3);;
gap> f:=f/[f.2*f.3];;
gap> q:=GQuotients(f,g);;
gap> k:=List(q,Kernel);;
gap> k:=Intersection(k);;
gap> hom:=IsomorphismFpGroup(TrivialSubgroup(g));;
gap> IsFpGroup(Range(hom));
true

## bug 3 for fix 2
gap> Order([[-E(7),0,0,0],[0,-E(7)^6,0,0],[0,0,E(21),0],[0,0,0,E(21)^20]]);
42
gap> Order(-E(7)*IdentityMat(14));
14

## bug 5 for fix 2
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> PowerMap( t, -1 );;  PowerMap( t, -1, 2 );;
gap> m:= t mod 2;;
gap> PowerMap( m, -1 );;  PowerMap( m, -1, 2 );;

## bug 9 for fix 2
gap> IsSimple(Ree(3));
false

## bug 10 for fix 2
gap> g:= GU(3,4);;  g.1 in g;
true
gap> ForAll( GeneratorsOfGroup( Sp(4,4) ), x -> x in SP(4,2) );
false

## bug 12 for fix 2
gap> IsMatrix( Basis( VectorSpace( GF(2), Basis( GF(2)^2 ) ) ) );
true

## bug 13 for fix 2
gap> -1 in [1..2];
false

## bug 16-18 for fix 4
gap> AbelianInvariantsMultiplier(SL(3,2));            
[ 2 ]
gap> AllPrimitiveGroups(Size,60);
#W  AllPrimitiveGroups: Degree restricted to [ 1 .. 999 ]
[ A(5), PSL(2,5), A(5) ]
gap> ix18:=X(GF(5),1);;f:=ix18^5-1;;
gap> Discriminant(f);
0*Z(5)

## bug 3 for fix 5
gap> One( DirectProduct( Group( [], () ), Group( [], () ) ) );;

## bug 4 for fix 5
gap> emb:= Embedding( DirectProduct( Group( (1,2) ), Group( (1,2) ) ), 1 );;
gap> PreImagesRepresentative( emb, (1,2)(3,4) );
fail

## bug 6 for fix 5
gap> v:= VectorSpace( Rationals, [ [ 1 ] ] );;
gap> x:= LeftModuleHomomorphismByImages( v, v, Basis( v ), Basis( v ) );;
gap> x + 0*x;;

## bug 7 for fix 5
gap> a:= GroupRing( GF(2), Group( (1,2) ) );;
gap> 1/3 * a.1;;  a.1 * (1/3);;

## bug 10 for fix 5
gap> R:= Integers mod 6;;
gap> Size( Ideal( R, [ Zero( R ) ] ) + Ideal( R, [ 2 * One( R ) ] ) );
3

## for changes 4.4.4 -> 4.4.5  (extracted from corresponding dev/Update)


# For fixes:


# 2005/01/06 (TB)
gap> One( DirectProduct( Group( [], () ), Group( [], () ) ) );;


# 2005/01/06 (TB)
gap> emb:= Embedding( DirectProduct( Group( (1,2) ), Group( (1,2) ) ), 1 );;
gap> PreImagesRepresentative( emb, (1,2)(3,4) );
fail


# 2005/02/21 (TB)
gap> v:= VectorSpace( Rationals, [ [ 1 ] ] );;
gap> x:= LeftModuleHomomorphismByImages( v, v, Basis( v ), Basis( v ) );;
gap> x + 0*x;;


# 2005/02/21 (TB)
gap> a:= GroupRing( GF(2), Group( (1,2) ) );;
gap> 1/3 * a.1;;  a.1 * (1/3);;


# 2005/02/26 (AH)
gap> Random(GF(26831423036065352611));;


# 2005/03/05 (AH)
gap> x:=X(Rationals);;
gap> PowerMod(x,3,x^2);
0
gap> PowerMod(x,1,x);
0


# 2005/03/08 (AH)
gap> p:=[0,1];
[ 0, 1 ]
gap> UnivariatePolynomial(Rationals,p);
x_1
gap> p;
[ 0, 1 ]


# 2005/03/31 (TB)
gap> R:= Integers mod 6;;
gap> Size( Ideal( R, [ Zero( R ) ] ) + Ideal( R, [ 2 * One( R ) ] ) );
3


# 2005/04/12 (FL (includes a fix in dev-version by Burkhard))
## the less memory GAP has, the earlier the following crashed GAP  
#out := OutputTextFile("/dev/null",false);
#g := SymmetricGroup(1000000);
#for i in [1..100] do  
#    Print(i, " \c");
#    r := PseudoRandom(g);
#    PrintTo(out, "Coset representative is ", r, "\n");
#od;


# 2005/04/12 (FL)
gap> IntHexString(['a','1']);
161


# 2005/04/12 (AH)
gap> f:=FreeGroup(IsSyllableWordsFamily,8);;
gap> g:=GeneratorsOfGroup(f);;
gap> g1:=g[1];;
gap> g2:=g[2];;
gap> g3:=g[3];;
gap> g4:=g[4];;
gap> g5:=g[5];;
gap> g6:=g[6];;
gap> g7:=g[7];;
gap> g8:=g[8];;
gap> rws:=SingleCollector(f,[ 2, 3, 2, 3, 2, 3, 2, 3 ]);;
gap> r:=[
gap>   [1,g4*g6],
gap>   [3,g4],
gap>   [5,g6*g8^2],
gap>   [7,g8],
gap> ];;
gap> for x in r do SetPower(rws,x[1],x[2]);od;
gap> G:= GroupByRwsNC(rws);;
gap> f1:=G.1;;
gap> f2:=G.2;;
gap> f3:=G.3;;
gap> f4:=G.4;;
gap> f5:=G.5;;
gap> f6:=G.6;;
gap> f7:=G.7;;
gap> f8:=G.8;;
gap> a:=Subgroup(G,[f3*f6*f8^2, f5*f6*f8^2, f7*f8, f4*f6^2*f8 ]);;
gap> b:=Subgroup(G,[f2^2*f4^2*f6*f7*f8^2, f2*f4*f6^2*f8^2, f5*f6^2*f8,
>                   f2^2*f6^2*f8, f2*f3*f4, f2^2]);;
gap> Size(Intersection(a,b))=Number(a,i->i in b);
true


# 2005/04/15 (TB)
gap> CompareVersionNumbers( "1.0", ">=9.9" );
false


# 2005/04/26 (SL)

# too complicated to construct



# 2005/04/27 (TB)
gap> Iterator( Subspaces( VectorSpace( GF(2), [ X( GF(2) ) ] ) ) );;


# 2005/04/27 (TB)
gap> String( [ [ '1' ] ] );  String( rec( a:= [ '1' ] ) );
"[ \"1\" ]"
"rec( a := \"1\" )"


# 2005/05/03 (BH)
gap> if LoadPackage ("crisp") <> fail then
>      F:=FreeGroup("a","b","c");;
>      a:=F.1;;b:=F.2;;c:=F.3;;
>      G:=F/[a^12,b^2*a^6,c^2*a^6,b^-1*a*b*a,c^-1*a*c*a^-7,c^-1*b*c*a^-9*b^-1];;
>      pcgs := PcgsElementaryAbelianSeries (G);;
>      ser := ChiefSeries (G);;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgs (pcgs, H))
>                           <> ParentPcgs (pcgs)) then
>        Print( "problem with crisp (1)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <>  ParentPcgs(HomePcgs (H))) then
>        Print( "problem with crisp (2)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <> HomePcgs (H)) then
>        Print( "problem with crisp (3)\n" );
>      fi;
>      G2:=Image(IsomorphismPermGroup(G));
>      pcgs := PcgsElementaryAbelianSeries (G2);
>      ser := ChiefSeries (G2);
>      if ForAny (ser, H -> ParentPcgs (InducedPcgs (pcgs, H))
>                           <> pcgs) then
>        Print( "problem with crisp (4)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H)) 
>                           <> ParentPcgs(HomePcgs (H))) then
>        Print( "problem with crisp (5)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <> HomePcgs (H)) then
>        Print( "problem with crisp (6)\n" );
>      fi;
>    fi;


# 2005/05/03 (BE)
gap> SmallGroupsInformation(512);

  There are 10494213 groups of order 512.
     1 is cyclic. 
     2 - 10 have rank 2 and p-class 3.
     11 - 386 have rank 2 and p-class 4.
     387 - 1698 have rank 2 and p-class 5.
     1699 - 2008 have rank 2 and p-class 6.
     2009 - 2039 have rank 2 and p-class 7.
     2040 - 2044 have rank 2 and p-class 8.
     2045 has rank 3 and p-class 2.
     2046 - 29398 have rank 3 and p-class 3.
     29399 - 30617 have rank 3 and p-class 4.
     30618 - 31239 have rank 3 and p-class 3.
     31240 - 56685 have rank 3 and p-class 4.
     56686 - 60615 have rank 3 and p-class 5.
     60616 - 60894 have rank 3 and p-class 6.
     60895 - 60903 have rank 3 and p-class 7.
     60904 - 67612 have rank 4 and p-class 2.
     67613 - 387088 have rank 4 and p-class 3.
     387089 - 419734 have rank 4 and p-class 4.
     419735 - 420500 have rank 4 and p-class 5.
     420501 - 420514 have rank 4 and p-class 6.
     420515 - 6249623 have rank 5 and p-class 2.
     6249624 - 7529606 have rank 5 and p-class 3.
     7529607 - 7532374 have rank 5 and p-class 4.
     7532375 - 7532392 have rank 5 and p-class 5.
     7532393 - 10481221 have rank 6 and p-class 2.
     10481222 - 10493038 have rank 6 and p-class 3.
     10493039 - 10493061 have rank 6 and p-class 4.
     10493062 - 10494173 have rank 7 and p-class 2.
     10494174 - 10494200 have rank 7 and p-class 3.
     10494201 - 10494212 have rank 8 and p-class 2.
     10494213 is elementary abelian.

  This size belongs to layer 7 of the SmallGroups library. 
  IdSmallGroup is not available for this size. 
 


# 2005/05/04 (SL)
gap> c := [1,1,0,1]*Z(2);
[ Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0 ]
gap> m := [1,1]*Z(2);
[ Z(2)^0, Z(2)^0 ]
gap> PowerModCoeffs(c, 1, m);
[ Z(2)^0 ]
gap> ConvertToVectorRep(c, 2);
2
gap> ConvertToVectorRep(m, 2);
2
gap> Print(PowerModCoeffs(c, 1, m), "\n");
[ Z(2)^0 ]



# 2005/05/06 (SL)
gap> A:=[[Z(2)]];; ConvertToMatrixRep(A,2);;
gap> Sort(A); A;
<a 1x1 matrix over GF2>


# 2005/05/09 (TB)
# call: gap -A
# gap> SaveWorkspace( "wsp" );;
# call: gap -A -L wsp


# 2005/05/09 (FL)
gap> NextPrimeInt(23482648263482364926498249);
#I  IsPrimeInt: probably prime, but not proven: 23482648263482364926498251
23482648263482364926498251


# 2005/05/09 (Colva, FL (for 4R4))
gap> L:=AllPrimitiveGroups(NrMovedPoints,26,Size,[1..2^28-1]);
[ PSL(2,25), PGL(2,25), PZL(2,25), PSL(2,25).2, PYL(2,25) ]
# For new features:


# 2005/04/13 (FL)
gap> IsCheapConwayPolynomial(5,96);
false


# 2005/04/21 (FL)
gap> NormalBase( GF(3^6) );
[ Z(3^6)^2, Z(3^6)^6, Z(3^6)^18, Z(3^6)^54, Z(3^6)^162, Z(3^6)^486 ]
gap>  NormalBase( GF( GF(8), 2 ) );
[ Z(2^6), Z(2^6)^8 ]


# 2005/04/21 (FL)
gap> IsBound(HELP_VIEWER_INFO.firefox);
true


# 2005/04/26 (SL, FL)
gap> AClosestVectorCombinationsMatFFEVecFFECoords;
<Operation "AClosestVectorCombinationsMatFFEVecFFECoords">
gap> ConstituentsPolynomial;
function( p ) ... end


# 2005/04/27 (TB)
gap> IsBound( CYC_LIST );
true


# 2005/05/03 (SK)
gap> x := Indeterminate(Integers);;
gap> ContinuedFractionExpansionOfRoot(x^2-7,20);
[ 2, 1, 1, 1, 4, 1, 1, 1, 4, 1, 1, 1, 4, 1, 1, 1, 4, 1, 1, 1 ]
gap> ContinuedFractionExpansionOfRoot(x^2-7,0);
[ 2, 1, 1, 1, 4 ]
gap> ContinuedFractionExpansionOfRoot(x^3-2,20);
[ 1, 3, 1, 5, 1, 1, 4, 1, 1, 8, 1, 14, 1, 10, 2, 1, 4, 12, 2, 3 ]
gap> ContinuedFractionExpansionOfRoot(x^5-x-1,50);
[ 1, 5, 1, 42, 1, 3, 24, 2, 2, 1, 16, 1, 11, 1, 1, 2, 31, 1, 12, 5, 1, 7, 11, 
  1, 4, 1, 4, 2, 2, 3, 4, 2, 1, 1, 11, 1, 41, 12, 1, 8, 1, 1, 1, 1, 1, 9, 2, 
  1, 5, 4 ]
gap> ContinuedFractionApproximationOfRoot(x^2-2,10);
3363/2378
gap> 3363^2-2*2378^2;
1
gap> z := ContinuedFractionApproximationOfRoot(x^5-x-1,20);
499898783527/428250732317
gap> z^5-z-1;
486192462527432755459620441970617283/
14404247382319842421697357558805709031116987826242631261357


# 2005/05/03 (SK)
gap> l := AllSmallGroups(12);;
gap> List(l,StructureDescription);; l;
[ C3 : C4, C12, A4, D12, C6 x C2 ]
gap> List(AllSmallGroups(40),G->StructureDescription(G:short));
[ "5:8", "40", "5:8", "5:Q8", "4xD10", "D40", "2x(5:4)", "(10x2):2", "20x2",
  "5xD8", "5xQ8", "2x(5:4)", "2^2xD10", "10x2^2" ]
gap> List(AllTransitiveGroups(DegreeAction,6),G->StructureDescription(G:short));
[ "6", "S3", "D12", "A4", "3xS3", "2xA4", "S4", "S4", "S3xS3", "(3^2):4",
  "2xS4", "A5", "(S3xS3):2", "S5", "A6", "S6" ]
gap> StructureDescription(PSL(4,2));
"A8"


# 2005/05/03 (BE)
gap> NumberSmallGroups(5^6);
684
gap> NumberSmallGroups(5*7*9*11*13);
22


# 2005/05/05 (TB)
gap> IsBound( ShowPackageVariables );
true


# 2005/05/05 (TB)
gap> IsReadableFile( Filename( DirectoriesLibrary( "tst" ), "testutil.g" ) );
true


# 2005/05/06 (TB)
gap> IsBound( HasMultiplicationTable );
true

gap> STOP_TEST( "bugfix.tst", 5416900000 );


#############################################################################
##
#E

