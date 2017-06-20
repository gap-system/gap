#############################################################################
##
#W  bugfix.tst
##
##
##  Exclude from testinstall.g: why?
##
gap> START_TEST("bugfixes test");
gap> DeclareGlobalVariable("foo73");
gap> InstallValue(foo73,true);
Error, InstallValue: value cannot be immediate, boolean or character

##  Check if ConvertToMatrixRepNC works properly. BH
##
gap> mat := [[1,0,1,1],[0,1,1,1]]*One(GF(2));
[ [ Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0 ], [ 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0 ] ]
gap> ConvertToMatrixRepNC( mat, GF(2) );
2
gap> DimensionsMat(mat);
[ 2, 4 ]
gap> mat := [[1,0,1,1],[0,1,1,1]]*One(GF(3));
[ [ Z(3)^0, 0*Z(3), Z(3)^0, Z(3)^0 ], [ 0*Z(3), Z(3)^0, Z(3)^0, Z(3)^0 ] ]
gap> ConvertToMatrixRepNC( mat, GF(3) );
3
gap> DimensionsMat(mat);
[ 2, 4 ]

##  Check that a new SpecialPcgs is created for which 
##    LGWeights can be set properly
##    see my mail of 2011/02/22 to gap-dev for details. BH
##
gap> G := PcGroupCode(640919430184532635765016241891519311\
> 98104010779278323886032740084599, 192200);;
gap> ind := InducedPcgsByPcSequence(FamilyPcgs (G), 
> [ G.1*G.2*G.3*G.4^2*G.5^2, G.4^2*G.5^3, G.6, G.7 ]);;
gap> H := GroupOfPcgs (ind);;
gap> pcgs := SpecialPcgs (H);;
gap> syl31 := SylowSystem( H )[3];;
gap> w := LGWeights( SpecialPcgs( syl31 ) );
[ [ 1, 1, 31 ], [ 1, 1, 31 ] ]

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

## GQuotients
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
gap> ForAll(dc, c->Transformation([1,1,3,4]) in c);
false

## Testing if Green's D classes can be compared for finite semigroups
gap> s := Transformation([1,1,3,4,5]);;
gap> c := Transformation([2,3,4,5,1]);;
gap> op5 := Semigroup(s,c);;
gap> dcl := GreensDClasses(op5);;
gap> ForAny(Cartesian(dcl,dcl), x->IsGreensLessThanOrEqual(x[1],x[2]));
true

## Testing that GroupHClassOfGreensDClass is implemented
gap> h := GroupHClassOfGreensDClass(dcl[4]);;

## Testing AssociatedReesMatrixSemigroupOfDClass.
##         IsZeroSimpleSemigroup, IsomorphismReesMatrixSemigroup,
##         and MatrixOfReesZeroMatrixSemigroup
##         create Greens D classes correctly.
gap> rms := AssociatedReesMatrixSemigroupOfDClass(dcl[5]);;
gap> s := Transformation([1,1,2]);;
gap> c := Transformation([2,3,1]);;
gap> op3 := Semigroup(s,c);;
gap> IsRegularSemigroup(op3);;
gap> dcl := GreensDClasses(op3);;
gap> dcl := SortedList(ShallowCopy(dcl));;
gap> d2 := dcl[2];; d1:= dcl[1];;
gap> i2 := SemigroupIdealByGenerators(op3,[Representative(d2)]);;
gap> GeneratorsOfSemigroup(i2);;
gap> i1 := SemigroupIdealByGenerators(i2,[Representative(d1)]);;
gap> GeneratorsOfSemigroup(i1);;
gap> c1 := ReesCongruenceOfSemigroupIdeal(i1);;
gap> q := i2/c1;;
gap> IsZeroSimpleSemigroup(q);;
gap> irms := IsomorphismReesZeroMatrixSemigroup(q);;
gap> MatrixOfReesZeroMatrixSemigroup(Range(irms));;
gap> g := Group( (1,2),(1,2,3) );;
gap> i := TrivialSubgroup( g );;
gap> CentralizerModulo( g, i, (1,2) );
Group([ (1,2) ])

##  bugs 2, 3, 6, 7, 20 for fix 2.
gap> x:= Sum( GeneratorsOfAlgebra( QuaternionAlgebra( Rationals, -2, -2 ) ) );;
gap> x * Inverse( x ) = One( x );
true
gap> LargestMovedPoint(ProjectiveSymplecticGroup(6,2)) = 63;
true
gap> t1:= CharacterTable( CyclicGroup( 2 ) );;  SetIdentifier( t1, "C2" );
gap> t2:= CharacterTable( CyclicGroup( 3 ) );;  SetIdentifier( t2, "C3" );
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
gap> Length(Elements(g));
16
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

##  bug 7 for fix 5
gap> tbl:= CharacterTable( SL(2,3) );;  irr:= Irr( tbl );;
gap> lin:= Filtered( LinearCharacters( tbl ), x -> Order(x) = 3 );;
gap> deg3:= First( irr, x -> DegreeOfCharacter( x ) = 3 );;
gap> MolienSeries( tbl, lin[1] + deg3, lin[2] );
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

##  bug 3 for fix 6
gap> Order( ZmodnZObj( 2, 7 ) );;  Inverse( ZmodnZObj( 2, 7 ) );;

##  bug 4 for fix 6
gap> tbl:= CharacterTable( SL(2,3) );;  irr:= Irr( tbl );;
gap> z := Indeterminate( Rationals : old );
x_1
gap> lin := Filtered( LinearCharacters( tbl ), x -> Order(x) = 3 );;
gap> deg3 := First( irr, x -> DegreeOfCharacter( x ) = 3 );;
gap> ser := MolienSeries( tbl, lin[1] + deg3, lin[2] );;
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
gap> AllPrimitiveGroups(Size,60,NrMovedPoints,[2..2499]);
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
# 2006/03/13 (JJM) - removed this duplicate of 'bug 7 for fix 5' test
#gap> a:= GroupRing( GF(2), Group( (1,2) ) );;
#gap> 1/3 * a.1;;  a.1 * (1/3);;

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
>   [1,g4*g6],
>   [3,g4],
>   [5,g6*g8^2],
>   [7,g8],
> ];;
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

# 2005/05/09 (Colva, FL (for 4R4))
gap> L:=AllPrimitiveGroups(NrMovedPoints,26,Size,[1..2^28-1]);
[ PSL(2, 25), PGL(2, 25), PSigmaL(2, 25), PSL(2, 25).2_3, PGammaL(2, 25) ]

# For new features:

# 2005/04/13 (FL)
gap> IsCheapConwayPolynomial(5,96);
false

# 2005/04/21 (FL)
gap> NormalBase( GF(3^6) );
[ Z(3^6)^2, Z(3^6)^6, Z(3^6)^18, Z(3^6)^54, Z(3^6)^162, Z(3^6)^486 ]
gap>  NormalBase( GF( GF(8), 2 ) );
[ Z(2^6), Z(2^6)^8 ]

# 2005/04/26 (SL, FL)
gap> AClosestVectorCombinationsMatFFEVecFFECoords;
<Operation "AClosestVectorCombinationsMatFFEVecFFECoords">
gap> ConstituentsPolynomial;
function( p ) ... end

# 2005/04/27 (TB)
gap> IsBound( CycList );
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

#############################################################################
##
##  for changes 4.4.5 -> 4.4.6  (extracted from corresponding dev/Update)

# For fixes:

# 2005/05/17 (AH)
gap> IsConjugate(TransitiveGroup(9,19),Group([ (2,8,9,3)(4,6,7,5),
> (2,9)(3,8)(4,7)(5 ,6), (1,2,9)(3,4,5)(6,7,8), (1,4,7)(2,5,8)(3,6,9) ]),
> Group([ (3,7)(4,8)(5,6), (2,9)(3,8)(4,7)(5,6),(1,7,4)(2,8,5)(3,9,6),
> (1,6,5)(2,7,3)(4,9,8) ]));;

# 2005/05/18 (TB)
gap> t:= Runtime();;
gap> CayleyGraphSemigroup( Monoid( Transformation([2,3,4,5,6,1,7]),
>      Transformation([6,5,4,3,2,1,7]), Transformation([1,2,3,4,6,7,7]) ) );;
gap> if Runtime() - t > 5000 then
>      Print( "#E  efficiency problem with enumerators of semigroups!\n" );
> fi;

# 2005/06/06 (AH)
gap> Irr(SmallGroup(516,11));;

# 2005/06/13 (AH)
gap> IsSimple(AlternatingGroup(3));
true

# 2005/06/17 (SL)
gap> l := [1,2,3,4];
[ 1, 2, 3, 4 ]
gap> COPY_LIST_ENTRIES(l,2,1,l,3,1,3);
gap> l;
[ 1, 2, 2, 3, 4 ]

# 2005/07/09 (AH)
gap> CompositionSeries(PerfectGroup(IsPermGroup,262440,1));;

# 2005/07/13 (JS)
gap> PerfectGroup(7800,1);; # load perf2.grp
gap> PerfectGroup(7680,1);; # should load perf1.grp, gives error in 4.4.5

# 2005/07/13 (JS)
gap> NrPerfectLibraryGroups(1);
0

# 2005/07/18 (FL)
gap> TypeObj(IMPLICATIONS);;

# 2005/07/20 (TB)
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [ 1/2, 1, 2/3, 2 ] );
gap> A:= AlgebraByStructureConstants( Rationals, T, "A." );;
gap> GeneratorsOfAlgebra( A );
[ A.1, A.2 ]

# 2005/07/20 (TB)
gap> F:= FreeAssociativeAlgebra( Rationals, 2 );;
gap> IsAssociativeElement( F.1 );
true
gap> F:= FreeAlgebra( Rationals, 2 );;
gap> IsAssociativeElement( F.1 );
false

# 2005/07/21 (JS)
gap> G:=PerfectGroup(IsPermGroup,734832,1);;
gap> H:=PerfectGroup(IsPermGroup,734832,2);;
gap> K:=PerfectGroup(IsPermGroup,734832,3);;
gap> Assert(0,H<>K); # Fails in 4.4.5
gap> Assert(0,Size(G)=734832 and IsPerfectGroup(G)); # Sanity check
gap> Assert(0,Size(H)=734832 and IsPerfectGroup(H)); # Sanity check
gap> Assert(0,Size(K)=734832 and IsPerfectGroup(K)); # Sanity check
gap> Assert(0,Size(ComplementClassesRepresentatives(G,SylowSubgroup(FittingSubgroup(G),3)))=1); # Iso check
gap> Assert(0,Size(ComplementClassesRepresentatives(H,SylowSubgroup(FittingSubgroup(H),3)))=3); # Iso check
gap> Assert(0,Size(ComplementClassesRepresentatives(K,SylowSubgroup(FittingSubgroup(K),3)))=0); # Iso check

# 2005/08/10 (TB)
gap> ApplicableMethod( \in, [ 1, Rationals ] );
function( x, Rationals ) ... end

# 2005/08/11 (JS)
gap> List([1,2,3],k->IdGroup(SylowSubgroup(PerfectGroup(IsPermGroup,864000,k),2)));
[ [ 256, 55700 ], [ 256, 55970 ], [ 256, 56028 ] ]

# 2005/08/11 (TB)
# gap> fam:= NewFamily( "fam" );;
# gap> DeclareGlobalVariable( "TestFam" );
# gap> InstallValue( TestFam, CollectionsFamily( fam ) );
# #I  please use `BindGlobal' for the family object CollectionsFamily(...), not \
# `InstallValue'
# gap> IsIdenticalObj( TestFam, CollectionsFamily( fam ) );
# false
# gap> MakeReadWriteGlobal( "TestFam" );  UnbindGlobal( "TestFam" );

# 2005/08/15 (AH)
gap> Centre( MagmaByMultiplicationTable( [ [ 2, 2 ], [ 2, 1 ] ] ) );
[  ]

# 2005/08/17 (Max)
# Test code is not possible to provide because the error condition
# cannot be tested in a platform independent way.

# 2005/08/19 (JS)
gap> PermutationCycle((1,2,3,4,5,6)^2,[1..6],1); # returns fail in 4.4.5
(1,3,5)

# 2005/08/19 (JS)
gap> f:=function() Assert(0,false); end;; g:=function() f(); end;;
gap> ##  The following should just trigger a normal error, but in 4.4.5
gap> ##  it will send a few hundred lines before crashing:
gap> # g();

# 2005/08/19 (JS)
gap> g:= SmallGroup( 48, 30 );;
gap> AbelianInvariantsMultiplier( g ); # returned [ 2, 2 ] in 4.4.5
[ 2 ]

# 2005/08/19 (SL)
gap> Inverse(0*Z(2));
fail
gap> Inverse(0*Z(3));
fail

# 2005/08/22 (JS+AH)
gap> ##  The mailing lists contain more specific test code that is longer.
gap> ##  The following should never terminate, but does in 4.4.5
gap> # repeat G:=PerfectGroup(IsPermGroup,79200,3); P:=SylowSubgroup(G,11);
gap> # N:=Normalizer(G,P); Q:=N/P; until Size(DerivedSubgroup(Q)) <> 120;

# 2005/08/23 (TB)
gap> g:= SymmetricGroup( 4 );; IsSolvable( g );; Irr( g );;
gap> meth:= ApplicableMethod( CharacterDegrees, [ g, 0 ] );;
gap> meth( g, 0 );
"TRY_NEXT_METHOD"

# 2005/08/23 (TB)
gap> RereadLib( "debug.g" );
gap> Debug( Size );
Usage: Debug( <func>[, <name>] );
       where <func> is a function but not an operation,
       and   <name> is a string.

# 2005/08/23 (FL)
# commented out the test and the error message,
# since a different message is printed on 32 bit systems and 64 bit systems
gap> a := 2^(8*GAPInfo.BytesPerVariable-4)-1;;
gap> Unbind( x );
gap> # x := [-a..a];;

# Range: the length of a range must be less than 2^28
gap> IsBound(x);
false

# 2005/08/25 (JS)
gap> G := Group((1,2));; PrimePGroup(G);
2
gap> PrimePGroup(Subgroup(G,[])); # returns 2 in 4.4.5
fail

# 2005/08/25 (JS)
gap> HasIsPGroup( SylowSubgroup( SymmetricGroup( 5 ), 5 ) ); # false in 4.4.5
true

# 2005/08/26 (Max)
gap> IsOperation(MutableCopyMat);
true

# For new features:

# 2005/06/08 (SL)
gap> gamma := [[2,5],[3],[4,5],[1],[]];
[ [ 2, 5 ], [ 3 ], [ 4, 5 ], [ 1 ], [  ] ]
gap> STRONGLY_CONNECTED_COMPONENTS_DIGRAPH(gamma);
[ [ 5 ], [ 1, 2, 3, 4 ] ]

# 2005/07/18 (FL)
# takes too long in repeatedly running  tests
# IsProbablyPrimeInt(2^9689-1);

# 2005/07/20 (SK), 2009/09/28 (AK)
gap> Float("355")/Float("113");
3.14159
gap> Rat(last);
355/113
gap> 1/4*last2;
0.785398

# 2005/07/20 (SK)
gap> PadicValuation(288/17,2);
5

# 2005/07/20 (TB)
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [ 1/2, 1, 2/3, 2 ] );
gap> A:= AlgebraByStructureConstants( Rationals, T );;  A.1;
v.1

# 2005/07/21 (FL)
gap> IsCheapConwayPolynomial(5, 55);
true
gap> IsCheapConwayPolynomial(2, 108);
true

# 2005/07/22 (SK)
gap> EpimorphismFromFreeGroup(SymmetricGroup(4));
[ x1, x2 ] -> [ (1,2,3,4), (1,2) ]

# 2005/07/22 (SK)
gap> ForAll([Lambda,Phi,Sigma,Tau],IsOperation);
true

# 2005/08/08 (CMRD)
gap> AllPrimitiveGroups( Size, 60 );;

#W  AllPrimitiveGroups: Degree restricted to [ 1 .. 2499 ]

# 2005/08/11 (TB)
gap> DeclareGlobalVariable( "TestVariable" );
gap> InstallFlushableValue( TestVariable, rec() );
gap> MakeReadWriteGlobal( "TestVariable" );  UnbindGlobal( "TestVariable" );

# 2005/08/11 (TB)
gap> DeclareOperation( "TestOperation", [ IsGroup, IsGroup ] );
gap> InstallMethod( TestOperation, [ "IsGroup and IsAbelian", "IsGroup" ],
>        function( G, H ) return true; end );
gap> MakeReadWriteGlobal( "TestOperation" );  UnbindGlobal( "TestOperation" );

# 2005/08/15 (SK)
gap> List([0..5],i->PartialFactorization(7^64-1,i));
[ [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 
      1868505648951954197516197706132003401892793036353 ], 
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353, 
      5293217135841230021292344776577913319809612001 ], 
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353, 134818753, 47072139617, 
      531968664833, 1567903802863297 ], 
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353, 1201, 169553, 7699649, 
      134818753, 47072139617, 531968664833 ], 
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353, 1201, 169553, 7699649, 
      134818753, 47072139617, 531968664833 ], 
  [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 5, 17, 353, 1201, 169553, 7699649, 
      134818753, 47072139617, 531968664833 ] ]

# 2005/08/24 (SL, FL)
gap> l:=[1,2];;
gap> Remove(l,1); l;
1
[ 2 ]
gap> Add(l, 100, 1); l;
[ 100, 2 ]

#############################################################################
##
##  for changes 4.4.6 -> 4.4.7  (extracted from corresponding dev/Update)

# For fixes:

# 2005/09/07 (TB)
gap> Is8BitMatrixRep( InvariantQuadraticForm( SO( 7, 3 ) ).matrix );
true
gap> Is8BitMatrixRep( InvariantBilinearForm( Sp( 4, 4 ) ).matrix );
true
gap> Is8BitMatrixRep( InvariantSesquilinearForm( SU( 4, 2 ) ).matrix );
true

# 2005/09/13 (AH)
gap> r:=PolynomialRing(Rationals,3);; eo:=EliminationOrdering([2],[3,1]);;

# 2005/09/20 (SK)
gap> # None as the library methods for `NormalSubgroups' apparently obey
gap> # the `rule' that the trivial subgroup appears in the first and the
gap> # whole group appears in the last position.

# 2005/10/05 (SL and MN)
gap> p := PermList(Concatenation([2..10000],[1]));;
gap> for i in [1..1000000] do a := p^0; od; time1 := time;;
gap> for i in [1..1000000] do a := OneOp(p); od; time2 := time;;
gap> if time1 <= 3 * time2 then Print("Fix worked\n"); fi;
Fix worked

# 2005/10/14 (BH)
gap> IsBoundGlobal ("ComputedInducedPcgses");
true

# 2005/10/26 (JS)
gap> PolynomialByExtRep(FamilyObj(X(Rationals)),[[1,1],1,[2,1],1]); # x_2+x_1 in 4.4.6
x_1+x_2

# 2005/10/28 (TB)
gap> fail in List( Irr( SymmetricGroup( 3 ) ), Inverse );
true

# 2005/10/28 (TB)
gap> Order( ClassFunction( CyclicGroup( 1 ), [ (1-EI(5))/ER(6) ] ) );
infinity

# 2005/10/28 (TB)
gap> rg:= GroupRing( GF(2), SymmetricGroup( 3 ) );;
gap> i:= Ideal( rg, [ Sum( GeneratorsOfAlgebra( rg ){ [ 1, 2 ] } ) ] );;
gap> Dimension( rg / i );;

# 2005/11/22 (TB)
gap> Z(4) in Group( Z(2) );;

# 2005/11/25 (JS)
gap> NrPerfectLibraryGroups(450000);
3
gap> NrPerfectLibraryGroups(962280);
1
gap> NrMovedPoints(PerfectGroup(IsPermGroup,129024,2));
288
gap> NrMovedPoints(PerfectGroup(IsPermGroup,258048,2));
576
gap> NrMovedPoints(PerfectGroup(IsPermGroup,516096,1));
400

# 2005/11/28 (FL)
gap> ConjugacyClasses(SL(2,3))[1];
[ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ]^G

# 2005/11/28 (TB)
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> SetIdentifier( t, "Sym(4)" );
gap> Display( t, rec( classes:= [ 4 ] ) );
Sym(4)

     2  .
     3  1

       3a
    2P 3a
    3P 1a

X.1     1
X.2     .
X.3    -1
X.4     .
X.5     1

# 2005/11/29 (TB)
gap> l:= [ [ 1, 2 ] ];;  CheckFixedPoints( [ 1 ], l, [ 1, 1 ] );;  l;
[ 1 ]

# 2005/11/29 (TB)
gap> IsIdenticalObj( VectorSpace, FreeLeftModule );
false

# 2005/11/29 (TB)
gap> AsGroup( [ 1, -1 ] );
#I  no groups of cyclotomics allowed because of incompatible ^
fail

# 2005/12/21 (BH)
gap> ApplicableMethod (CharacteristicPolynomial, [GF(2), GF(4), [[Z(2)]], 1])=fail;
false

# 2005/12/22 (Robert F. Morse)
# 2011/09/13 (Updated by AK as suggested by JM)
# 2013/09/04 (Updated by JM)
gap> t:=Transformation([1,2,3,3]);;
gap> s:=FullTransformationSemigroup(4);;
gap> ld:=GreensDClassOfElement(FullTransformationSemigroup(4),
> Transformation([1,2,3,3]));;
gap> rs:=AssociatedReesMatrixSemigroupOfDClass(ld);;
gap> mat:=MatrixOfReesZeroMatrixSemigroup(rs);;
gap> Length(mat);
4
gap> t:=UnderlyingSemigroupOfReesMatrixSemigroup(rs);;
gap> List(mat, x-> [Size(x), Number(x, y-> y=0)]);
[ [ 6, 3 ], [ 6, 3 ], [ 6, 3 ], [ 6, 3 ] ]
gap> Size(UnderlyingSemigroupOfReesZeroMatrixSemigroup(rs));
6

# 2006/01/11 (MC)
gap> d := DirectoryCurrent();;
gap> f := Filename(DirectoriesSystemPrograms(), "rev");;
gap> if f <> fail then
>      s := InputOutputLocalProcess(d,f,[]);;
>      if PrintFormattingStatus(s) <> false then
>        Print( "unexpected PrintFormattingStatus value\n" );
>      fi;
>      SetPrintFormattingStatus(s,false);
>      AppendTo(s,"The cat sat on the mat\n");
>      if ReadLine(s) <> "tam eht no tas tac ehT\n" then
>        Print( "There is a problem concerning a cat on a mat.\n" );
>      fi;
>      CloseStream(s);
>    fi;

# 2006/01/18 (AH)
gap> G:=WreathProduct(CyclicGroup(3),Group((1,2,3),(4,5,6)));;
gap> Assert(0,Size(Group(GeneratorsOfGroup(G)))=6561);

# 2006/01/25 (TB)
gap> Basis( Rationals );;

# 2006/02/14 (SK)
gap> testG :=
>    function ( a, b )
>      local  M1;
>       M1 := [ [ [      0, -E(a)^-1 ], [ -E(a),       0 ] ],
>               [ [      0,       -1 ], [     1,       0 ] ],
>               [ [ E(4*b),        0 ], [     0, -E(4*b) ] ],
>               [ [     -1,        0 ], [     0,      -1 ] ]];
>       return (Group(M1));
>    end;;
gap> StructureDescription(testG(8,2));
"(C8 x C4) : C2"
gap> StructureDescription(testG(8,3));
"C3 x QD16"
gap> StructureDescription(testG(8,4));
"(C16 x C4) : C2"

# 2006/02/27 (AH)
gap> RepresentativeAction(Group(()), [1], [2], OnSets);;

# 2006/03/02 (AH)
gap> x_1:=X(Rationals,"x_1":old);;
gap> x_2:=X(Rationals,"x_2":old);;
gap> x_3:=X(Rationals,"x_3":old);;
gap> x_4:=X(Rationals,"x_4":old);;
gap> x_5:=X(Rationals,"x_5":old);;
gap> L:=[(x_3+x_4)*x_5-x_1,(x_3+x_4)*x_4-x_2,x_5^2+x_4^2-1];;
gap> ReducedGroebnerBasis(L,MonomialLexOrdering([x_1,x_2,x_3,x_4,x_5]));
[ x_4^2+x_5^2-1, -x_3*x_4+x_5^2+x_2-1, -x_3*x_5-x_4*x_5+x_1 ]
gap> ReducedGroebnerBasis(L,MonomialLexOrdering([x_4,x_5,x_1,x_2,x_3]));
[ x_1^4+2*x_1^2*x_2^2-x_1^2*x_3^2+x_2^4-x_2^2*x_3^2-2*x_1^2*x_2-2*x_2^3+x_2^2,
  -x_1^3-x_1*x_2^2+x_1*x_3^2+x_2*x_3*x_5+x_1*x_2, 
  x_1^2*x_2+x_1*x_3*x_5+x_2^3-x_2*x_3^2-x_1^2-2*x_2^2+x_2, 
  x_1^2*x_5+x_2^2*x_5-x_1*x_3-x_2*x_5, -x_1^2-x_2^2+x_3^2+x_5^2+2*x_2-1, 
  -x_1^2-x_2^2+x_3^2+x_3*x_4+x_2, x_1*x_5+x_2*x_4-x_3-x_4, x_1*x_4-x_2*x_5, 
  x_3*x_5+x_4*x_5-x_1, x_1^2+x_2^2-x_3^2+x_4^2-2*x_2 ]

# 2006/03/03 (FL)
gap> s := "";; str := OutputTextString(s, false);;
gap> for i in [0..255] do WriteByte(str, i); od;
gap> CloseStream(str);
gap> s = List([0..255], CHAR_INT);
true

# 2006/2/20 (AH)
gap> group1 := Group([ (1,3)(2,5)(4,7)(6,8), (1,4)(2,6)(3,7)(5,8),
> (1,5)(2,3)(4,8)(6,7), (2,3,4,5,7,8,6), (3,4,7)(5,6,8) ]);;
gap> group2 := Group([ (1,3,4,7,2,6,8), (1,8,7,5,3,6,2) ]);;
gap> group3 := SymmetricGroup([1..8]);;
gap> RepresentativeAction(group3,group1,group2);
fail

# 2006/03/08 (SL)
gap> Z(3,30);
z

# For new features:

# 2005/12/08 (TB, Michael Hartley (implementation of a prototype))
gap> LowIndexSubgroupsFpGroupIterator;;

# 2005/12/22 (Robert F. Morse)
gap> g := Image(IsomorphismFpGroup(SmallGroup(8,3)));;
gap> h := Image(IsomorphismFpGroup(SmallGroup(120,5)));;
gap> fp := FreeProduct(g,h);;
gap> IsFpGroup(fp);
true
gap> emb := Embedding(fp,1);;
gap> IsMapping(emb);
true
gap> dp := DirectProduct(g,h);;
gap> IsFpGroup(dp);
true
gap> IdGroup(dp);
[ 960, 5746 ]
gap> IdGroup(Image(Projection(dp,2)));
[ 120, 5 ]
gap> IdGroup(Image(Embedding(dp,1)));
[ 8, 3 ]

# 2005/12/28 (FL)
gap> IsCheapConwayPolynomial(2,114);
true

#############################################################################
##
##  for changes 4.4.7 -> 4.4.8  (extracted from corresponding dev/Update)

# For fixes:

# 2006/04/07 (TB)
gap> G:= SymmetricGroup(3);;
gap> m:= InnerAutomorphism( G, (1,2) );;
gap> n:= TransformationRepresentation( InnerAutomorphism( G, (1,2,3) ) );;
gap> m * n;;  n * m;;

# 2006/04/18 (SK)
gap> gp := FreeGroup(1);; Size(gp);;
gap> DirectProduct(gp,gp);
<fp group of size infinity on the generators [ f1, f2 ]>

# 2006/04/18 (TB)
gap> Decomposition( [ [1,1], [E(3),E(3)^2] ], [ [1,-1] ], 1 );
[ fail ]

# 2006/05/12 (TB)
gap> Center( OctaveAlgebra( GF(13) ) );;

# 2006/07/25 (AH)
gap> g:=TransitiveGroup(10,8);;
gap> ConjugatorOfConjugatorIsomorphism(ConjugatorAutomorphism(g,(4,9)));
(1,6)(2,7)(3,8)(5,10)

# 2006/07/27 (SK)
gap> IsPolycyclicGroup(SymmetricGroup(4));
true
gap> IsPolycyclicGroup(SymmetricGroup(5));
false
gap> IsPolycyclicGroup(Group([[1,1],[0,1]]));
true

## 2006/09/20 (JJM)
## comment out this test, since it will not complete without Polenta.
#gap> IsPolycyclicGroup(Group([[1,1],[0,1]],[[0,1],[1,0]]));
#false

# 2006/07/28 (RFM)
gap> g := CyclicGroup(1);;
gap> SchurCover(g);;
gap> sc := SchurCover(g);;
gap> IdGroup(sc);
[ 1, 1 ]
gap> epi := EpimorphismSchurCover(g);;
gap> Image(epi)=g;
true
gap> IdGroup(Source(epi));
[ 1, 1 ]
gap> G := SmallGroup(27,3);;
gap> IsCentralFactor(G);
true
gap> AbelianInvariantsMultiplier(G);
[ 3, 3 ]
gap> AbelianInvariants(Kernel(EpimorphismNonabelianExteriorSquare(G)));
[ 3, 3 ]
gap> ec := Epicentre(DirectProduct(CyclicGroup(25),CyclicGroup(5)));;
gap> IsTrivial(ec);
false
gap> ec := Epicentre(DirectProduct(CyclicGroup(3),CyclicGroup(3)));;
gap> IsTrivial(ec);
true

# 2006/08/19 (Max)
gap> m := [[1]];;
gap> IsMutable(m^1);
true

# 2006/08/19 (Max)
gap> IsOperation(StripMemory);
true

# 2006/08/22 (Max)
gap> "IsBlistRep" in NamesFilter(TypeObj(BlistList([1,2],[2]))![2]);
true

# 2006/08/28 (FL)
gap> time1 := 0;;
gap> for j in [1..10] do
> l:=List([1..100000],i->[i]);
> t1:=Runtime(); for i in [1..100000] do a := PositionSorted(l,[i]); od; t2:=Runtime();
> time1 := time1 + (t2-t1);
> od;
gap> time2 := 0;;
gap> for j in [1..10] do
> l := Immutable( List([1..100000],i->[i]) );
> t1:=Runtime(); for i in [1..100000] do a := PositionSorted(l,[i]); od; t2:=Runtime();
> time2 := time2 + (t2-t1);
> od;
gap> if time1 >= 2*time2 then
> Print("Bad timings for bugfix 2006/08/28 (FL): ", time1, " >= 2*", time2, "\n"); 
> fi; # time1 and time2 should be about the same

# 2006/08/29 (FL (and AH))
gap> IsBound(ITER_POLY_WARN);
true

# 2006/08/28 (SL)
gap> a := -70170876888665790351719387465587751111897440176;;
gap> b := -24507694029460834590427275534096897425026491796;;
gap> GcdInt(a,b);
4

# 2006/04/02 (AH)
gap> F:=FreeGroup("x","y","z");;
gap> x:=F.1;;y:=F.2;;z:=F.3;;
gap> rels:=[x^2,y^2,z^4,Comm(z^-2,x),(z*x)^4,Comm(z^-1,y)^2,
> (y*x)^4,(Comm(z,y)*x)^2,(Comm(y,z^-1)*x)^2,(y*z)^6,
> z^-1*y*z^-1*x*z*y*z^-1*x*z*y*z^-1*x*z*y*z*x,y*z*x*z*y*x*y*z^-1*x*y*z^-1*x*y*z*x*y*z^-1*x];;
gap> G:=F/rels;;
gap> x:=G.1;;y:=G.2;;z:=G.3;;
gap> s3:=Subgroup(G,[ z*y*z*y^-1, z^-1*y*z^-1*y^-1, y*z*x*z^-1*y^-1*x^-1,
> z*x*y*z*x^-1*y^-1 ]);;
gap> L:=LowIndexSubgroupsFpGroup(G,s3,4);;
gap> Assert(0,Length(L)=27);

# For new features:

# 2006/06/19 (SK)
gap> Positions([1,2,1,2,3,2,2],2);
[ 2, 4, 6, 7 ]
gap> Positions([1,2,1,2,3,2,2],4);
[  ]

# 2006/07/06 (SL)
gap> z := Z(3,10);;
gap> LogFFE(z,z^2);
fail
gap> z := Z(3,11);;
gap> LogFFE(z,z^2);
fail

# 2006/08/16 (FL)
gap> EvalString("1234\\\r\n567");
1234567

# 2006/08/16 (FL)
gap> IsBound(GAPInfo.SystemEnvironment);
true

# 2006/08/28 (FL)
gap> Length(IDENTS_BOUND_GVARS());;
gap> Length(ALL_RNAMES());;

# 2006/08/28 (FL)
gap> IsCheapConwayPolynomial(2,100);
true

# 2006/08/28 (FL)
gap> Random(GlobalMersenneTwister,[1..6]);;

#############################################################################
##
##  for changes 4.4.8 -> 4.4.9  (extracted from corresponding dev/Update)

# 2006/10/04 (TB)
gap> PseudoRandom( AutomorphismGroup( AlternatingGroup( 5 ) ) );;

# 2006/10/23 (FL)
gap> s := "";; for i in [0..255] do Add(s, CHAR_INT(i)); od;
gap> fnam := Filename(DirectoryTemporary(), "guck");;
gap> FileString(fnam, s);;
gap> f := InputTextFile(fnam);;
gap> a := [0..255];; if ARCH_IS_WINDOWS() then a[14]:=10; fi;
gap> List([0..255], i-> ReadByte(f)) = a;
true
gap> RemoveFile(fnam);
true

# 2006/10/31 (FL)
gap> Positions("abcdeca", 'c');
[ 3, 6 ]

# 2006/10/4 (AH)
gap> g:=SmallGroup(1800,646);;c:=CharacterTable(g);;Irr(c);;

#############################################################################
##
##  for changes 4.4.9 -> 4.4.10  (extracted from corresponding dev/Update)

# For fixes:

# 2006/11/13 (AH)
gap> Socle (Group ([[1]]));;

# 2006/11/14 (FL)
gap> DirectoryContents( Filename( DirectoriesLibrary( "" ), "lib" ) );;

# 2007/01/17 (AH)
gap> R := PolynomialRing(GF(4),1);; x := Z(4) * One(R);;
gap> x in DefaultRing(x);
true

# 2007/01/22 (SL)
gap> F := GF(7,3);;
gap> F1 := GF(F,2);;
gap> a := PrimitiveRoot(F1);;
gap> B := Basis(F1);;
gap> Coefficients(B,a^0);
[ z0, 0z ]

# 2007/02/14 (SL)
gap> m:= [ [ Z(2,18)^0, 0*Z(2,18) ], 
>     [ Z(2)^0+Z(2,18)+Z(2,18)^2+Z(2,18)^7+Z(2,18)^8+Z(2,18)^10+Z(2,18)^12
>       +Z(2,18)^14+Z(2,18)^15, Z(2,18)^0 ] ];;
gap> KroneckerProduct( [[Z(2)]], m );  
[ <a GF2 vector of length 2>, [ 1+z+z2+z7+z8+z10+z12+z14+z15, z0 ] ]

# 2007/02/21 (TB)
gap> v:= GF(2)^2;;  bv:= BasisVectors( Basis( v ) );;
gap> IsInjective( LeftModuleGeneralMappingByImages( v, v, bv, 0 * bv ) );
false
gap> map:= LeftModuleGeneralMappingByImages( v, v, 0 * bv, bv );;
gap> Print( ImagesRepresentative( map, Zero( v ) ), "\n" );
[ 0*Z(2), 0*Z(2) ]

# 2007/02/23 (Max)
gap> Enumerator(GF(74761));
<enumerator of GF(74761)>

# 2007/03/12 (SL)
gap> z := Z(3,12)-Z(3,12);
0z
gap> DegreeFFE(z);
1
gap> FFECONWAY.TryToWriteInSmallerField(z,2);
0*Z(3)

# 2007/03/19 (SL)
gap> GF(GF(7^3),2);
AsField( GF(7^3), GF(7^6) )

# 2007/03/20 (SL)
gap> x := Z(2,18)^((2^18-1)/511);;
gap> b := Basis(GF(512));;
gap> Coefficients(b,x);
[ 0z, z0, 0z, 0z, 0z, 0z, 0z, 0z, 0z ]

# 2007/03/26 (AH)
gap> s:=ConjugacyClassSubgroups(
> Group([
>  (2,3)(6,7)(10,11)(14,15),
>  (5,9)(6,10)(7,11)(8,12),
>  (3,5)(4,6)(11,13)(12,14),
>  (1,2)(3,4)(5,6)(7,8)(9,10)(11,12)(13,14)(15,16),
>  (17,18)
> ]),
> Group([
>  (1,16)(2,15)(3,14)(4,13)(5,12)(6,11)(7,10)(8,9),
>  (1,13,16,4)(2,5,15,12)(3,9,14,8)(6,7,11,10)(17,18),
>  (5,9)(6,10)(7,11)(8,12),
>  (2,3)(5,9)(6,11)(7,10)(8,12)(14,15)
> ]))[1];;
gap> IdGroup(s);;
gap> ConjugacyClassesSubgroups(s);;

# 2007/03/30 (TB)
gap> IsSubset( [ [], [1] ], [ [] ] );
true

# 2007/04/02 (FL)
gap> Print(x -> 100000000000, "\n");
function ( x )
    return 100000000000;
end

# 2007/06/14 (FL)
gap> BlistList([1..10],[4234623462462464234242]);
[ false, false, false, false, false, false, false, false, false, false ]

# 2007/07/02 (SK)
gap> GeneratorsOfRing(Rationals);
Error, cannot compute elements list of infinite domain <V>
gap> GeneratorsOfRingWithOne(Rationals);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `GeneratorsOfRingWithOne' on 1 arguments

# 2007/07/06 (JS)
gap> PrimitiveGroup(50,4);
PGL(2, 49)
gap> Name(PrimitiveGroup(50,6)) = "PGL(2, 49)";
false

# 2007/07/07 (FL)
gap> OnTuples([,1],());
Error, OnTuples for perm: list must not contain holes

# 2007/07/27 (AH)
gap> H:=GroupByPcgs(Pcgs(AbelianGroup([6,6])));;
gap> K:=SmallGroup(IdGroup(H));;
gap> 1H:=TrivialGModule(H,GF(3));;
gap> 1K:=TrivialGModule(K,GF(3));;
gap> Assert(1,Rank(TwoCohomologySQ(CollectorSQ(H,1H,true),H,1H))=
> Rank(TwoCohomologySQ(CollectorSQ(K,1K,true),K,1K)));

# 2007/08/08 (SL)
gap> l := [1,2,3];;
gap> for i in [2] do Print(IsBound(l[10^20]),"\n"); od;
false

# 2007/08/15 (MN)
gap> Print(ZmodpZObj(2,65537),"\n");
ZmodpZObj( 2, 65537 )

# For new features:

# 2007/03/21 (TB)
gap> IrreducibleModules( DihedralGroup(38), GF(2), 0 );;

# 2007/06/14 (FL)
gap> PositionSublist([1,2,3,4,5,6,7],[4,5,6]);
4

# 2007/08/15 (MN)
gap> l := [1,2,3];
[ 1, 2, 3 ]
gap> MakeImmutable(l);
[ 1, 2, 3 ]

# 2007/08/22 (AD)
gap> f := UnivariatePolynomial( Rationals, [-4,0,0,1] );;
gap> L := AlgebraicExtension( Rationals, f );
<algebraic extension over the Rationals of degree 3>

# 2007/08/29 (TB)
gap> x:= TrivialCharacter( CharacterTable( SymmetricGroup(4) ) mod 2 );;
gap> ScalarProduct( x, x );;

# 2007/08/29 (TB)
gap> a:= QuaternionAlgebra( [ EB(5) ] );
<algebra-with-one of dimension 4 over NF(5,[ 1, 4 ])>
gap> IsSubset( a, QuaternionAlgebra( Rationals ) );
true

# 2007/08/31 (FL)
gap> # Quotient to yield the same on 32- and 64-bit systems
gap> SHALLOW_SIZE([1])/GAPInfo.BytesPerVariable;
2
gap> SHALLOW_SIZE(List([1..160],i->i^2))/GAPInfo.BytesPerVariable;
161
gap> [ShrinkAllocationPlist, ShrinkAllocationString];;
gap> [EmptyPlist, EmptyString];;                                               

# 2007/08/31 (FL)
gap> IsCheapConwayPolynomial(2,150);
true
gap> IsCheapConwayPolynomial(3,52); 
true

#############################################################################
##
##  for changes 4.4.10 -> 4.4.11  (extracted from corresponding dev/Update)

# For fixes:

# 2007/10/10 (TB)
gap> IsomorphismTypeInfoFiniteSimpleGroup( 1 );;

# 2007/10/15 (FL)
gap> d:=NewDictionary(3213,true);;
gap> LookupDictionary(d,4);
fail

# 2007/12/14 (MN)
gap> a := [1..100];;
gap> MemoryUsage(a)=MemoryUsage(a);
true

# 2008/01/02 (AH)
gap> G:=SmallGroup(1308,1);
<pc group of size 1308 with 4 generators>
gap> Length(Irr(G));
48

# 2008/02/13 (TB)

# 2008/03/19 (TB)
gap> DefiningPolynomial( AsField( GF(9), GF(3^6) ) );
x_1^3+Z(3^2)^6*x_1^2+Z(3^2)*x_1+Z(3^2)^5

# 2008/04/03 (JS), updated on 2010/10/01 (AK)
gap> g:=Group( (1,33)(2,12)(3,96)(4,37)(5,95)(6,11)(7,51)(8,42)(9,32)(10,80)
> (13,17)(14,59)(15,62)(16,85)(18,22)(19,29)(20,24)(21,90)(23,72)(25,26)
> (27,30)(28,70)(31,92)(34,100)(35,75)(36,82)(38,86)(39,77)(40,46)(41,44)
> (43,61)(45,52)(47,78)(48,88)(49,57)(50,55)(53,97)(54,67)(56,91)(58,81)
> (60,93)(63,71)(64,73)(65,89)(66,79)(68,98)(69,83)(74,87)(76,99)(84,94), 
> (1,10)(2,7,52,98)(3,68,75,12)(4,51,49,27)(5,18,29,91)(6,41,54,72)
> (8,78,25,99)(9,95,67,55)(11,86,39,38)(13,17)(14,61,82,79)(15,97,28,46)
> (16,56,74,83)(20,94,90,47)(21,65,66,58)(22,50,87,71)(23,93,31,85)(24,53)
> (26,76,36,73)(30,37,44,69)(32,34)(33,70)(40,43)(42,88,64,80)(45,60,92,57)
> (48,81)(59,62,84,89)(77,96) );;
gap> c:=ConjugacyClassesMaximalSubgroups( g );;
gap> Collected(List(c,x->[Size(Representative(x)),Size(x)]));
[ [ [ 120, 336 ], 1 ], [ [ 144, 280 ], 1 ], [ [ 336, 120 ], 3 ], 
  [ [ 384, 105 ], 1 ], [ [ 720, 56 ], 3 ], [ [ 20160, 1 ], 1 ] ]

# 2008/04/23 (TB)
gap> GeneratorsOfAlgebra( QuaternionAlgebra( GF(17) ) );
[ e, i, j, k ]
gap> GeneratorsOfAlgebra( QuaternionAlgebra( GF(17) ) );
[ e, i, j, k ]

# 2008/06/24 (FL)
# none, we hope that the changed code is never needed!

# 2008/07/20 (Laurent Bartholdi)
gap> Intersection( [ -1 .. 1 ], [ -1 .. 1 ] ); # previously was empty
[ -1 .. 1 ]
gap> Intersection( [ 2, 4 .. 10 ], [ 3 .. 5 ] ); # previously was [ 4, 6 ]
[ 4 ]

# 2008/08/13 (SL)
gap> Z(3,20) + Z(3,20)^0;
1+z
gap> AA := Z(3^10)^30683;
Z(3^10)^30683
gap> BB := Z(3)^0+Z(3^15)^3+Z(3^15)^4+2*Z(3^15)^5+2*Z(3^15)^8+2*Z(3^15)^10+2*Z(3^15)^11+Z(3^15)^13;
1+z3+z4+2z5+2z8+2z10+2z11+z13
gap> AA=BB;
false
gap> RT := Z(3^6);
Z(3^6)
gap> DD := Z(3^12)+Z(3^12)^2+2*Z(3^12)^3+2*Z(3^12)^4+Z(3^12)^5+Z(3^12)^6+Z(3^12)^7+Z(3^12)^8+2*Z(3^12)^9;
z+z2+2z3+2z4+z5+z6+z7+z8+2z9
gap> LogFFE(DD,RT);            
340

# 2008/09/02 (FL)
gap> SmithNormalFormIntegerMatTransforms(
> [ [ 2, 0, 0, 0, 0 ], [ 2, 2, 0, -2, 0 ], [ 0, -2, -2, -2, 0 ],
>   [ 3, 1, -1, 0, -1 ], [ 4, -2, 0, 2, 0 ], [ 3, -1, -1, 2, -1 ],
>   [ 0, 4, -2, 0, 2 ], [ 2, 2, 0, 2, 2 ], [ 0, 0, 0, 0, 0 ],
>   [ 2, 0, -4, -2, 0 ], [ 0, -2, 4, 2, -2 ], [ 2, -2, 0, -2, -1 ],
>   [ 3, -3, -1, 1, 0 ] ]).normal;
[ [ 1, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 0 ], [ 0, 0, 0, 2, 0 ], 
  [ 0, 0, 0, 0, 2 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0 ] ]

# 2008/09/10 (TB)
gap> g:= AlternatingGroup( 10 );;                                   
gap> gens:= GeneratorsOfGroup( g );;                                 
gap> hom:= GroupHomomorphismByImagesNC( g, g, gens, gens );;         
gap> IsOne( hom ); # This took (almost) forever before the change ...
true

# 2008/09/10 (TB)
gap> Display( StraightLineProgram( "a(ab)", [ "a", "b" ] ) );
# input:
r:= [ g1, g2 ];
# program:
r[3]:= r[1];
r[4]:= r[1]*r[2];
r[5]:= r[3]*r[4];
# return value:
r[5]

# 2008/09/11 (AH)
gap> x:=Indeterminate(CF(7));;
gap> K:=AlgebraicExtension(CF(7),x^2-3);;
gap> a:=GeneratorsOfField(K)[1];;
gap> x2 := E(7)+a*(E(7)^2+E(7)^3);
(E(7)^2+E(7)^3)*a+E(7)

# 2008/09/18 (AH)
gap> g:=Group((14,15)(16,17), (12,13), (9,10,11), (4,8)(16,17),
> (1,8)(2,3)(4,5)(6,7)(16,17), (1,3)(2,8)(4,6)(5,7)(16,17));;
gap> IsNilpotent(g);
true

# For new features:

# 2008/02/29 (TB)
gap> f:= GF(2);; x:= Indeterminate( f );; p:= x^2+x+1;;
gap> e:= AlgebraicExtension( f, p );;
gap> GeneratorsOfLeftModule( e );;  Basis( e );;  Iterator( e );;

# 2008/03/26 (TB)
gap> FrobeniusCharacterValue( E(55), 2 );
z+z2+z3+z4+z5+z6+z8+z10+z12+z13+z14+z16+z17+z19

# 2008/04/14 (SK)
gap> [[4,5],[5,6]] in GL(2,Integers);
true
gap> [[4,5],[5,6]] in SL(2,Integers);
false

# 2008/04/14 (SK)
gap> String(Integers^3);
"( Integers^3 )"
gap> ViewString(GF(16)^3);
"( GF(2^4)^3 )"
gap> IsRowModule(1);
false

# 2008/04/14 (SK)
gap> G := Group((1,2));;
gap> SetName(G,"C2");
gap> ViewString(G);
"C2"

# 2008/04/15 (SK)
gap> PolynomialRing(GF(2),1);
GF(2)[x_1]
gap> String(PolynomialRing(GF(8),4));
"PolynomialRing( GF(2^3), [ x_1, x_2, x_3, x_4 ] )"
gap> ViewString(PolynomialRing(GF(2),1));
"GF(2)[x_1]"

# 2008/06/05 (FL)
gap> Binomial(2^80,3);
294474510796397388263882186039667753853121547637256443485296081974067200

# 2008/10/01 (TB)
gap> QuaternionAlgebra( Field( [ EB(5) ] ) );;
gap> IsDivisionRing( QuaternionAlgebra( Field( [ EB(5) ] ) ) );
true

# 2008/11/16 (TB)
gap> t:= [ [ 1, 2, 3, 4, 5 ], [ 2, 1, 4, 5, 3 ], [ 3, 5, 1, 2, 4 ],
>          [ 4, 3, 5, 1, 2 ], [ 5, 4, 2, 3, 1 ] ];;
gap> m:= MagmaByMultiplicationTable( t );;
gap> IsAssociative( m );
false
gap> AsGroup( m );
fail

# 2008/11/16 (TB)
gap> att:= NewAttribute( "att", IsObject );
<Attribute "att">
gap> prop1:= NewProperty( "prop1", IsObject );
<Property "prop1">
gap> prop2:= NewProperty( "prop2", IsObject );
<Property "prop2">
gap> InstallTrueMethod( prop2, prop1 );
gap> InstallImmediateMethod( att, Tester( prop2 ), 0, G -> 1 );
gap> # The intended behaviour is that `prop1' implies `prop2',
gap> # and that a known value of `prop2' triggers a method call
gap> # that yields the value for the attribute `att'.
gap> g:= Group( (1,2,3,4), (1,2) );;
gap> Tester( att )( g ); Tester( prop1 )( g ); Tester( prop2 )( g );
false
false
false
gap> Setter( prop1 )( g, true );
gap> # Now `prop1' is `true',
gap> # the logical implication sets also `prop2' to `true',
gap> # thus the condition for the immediate method is satisfied.
gap> Tester( prop1 )( g ); Tester( prop2 )( g );
true
true
gap> Tester( att )( g );  # Here we got `false' before the fix.
true

#############################################################################
##
## Changes 4.4.12 -> 4.5.4

# 2008/12/15 (TB)
gap> 0*Z(5) in Group( Z(5) );
false

# 2009/02/04 (FL)
gap> Intersection([1..3],[4..5],[6,7]);
[  ]

# 2009/02/23 (AH)
gap> chi:=Irr(CyclicGroup(3))[2];;
gap> IrreducibleRepresentationsDixon(UnderlyingGroup(chi),[chi]);;

# 2009/02/25 (TB)
gap> IndexNC( GL(30,17), SL(30,17) );
16

# 2009/03/13 (FL)
gap> b:=BlistList([1..4],[1,2]);
[ true, true, false, false ]
gap> b{[1,2]} := [false,false];
[ false, false ]
gap> IsBlistRep(b);
true

# 2009/05/28 (BH)
gap> G:=AlternatingGroup(4);;
gap> N:=Subgroup(G,[(1,2)(3,4),(1,3)(2,4)]);;
gap> H:=DirectProduct(CyclicGroup(2),CyclicGroup(2));;
gap> A:=AutomorphismGroup(H);;
gap> P:=SylowSubgroup(A,3);;
gap> epi:=NaturalHomomorphismByNormalSubgroup(G,N);;
gap> iso:=IsomorphismGroups(FactorGroup(G,N),P);;
gap> f:=CompositionMapping(IsomorphismGroups(FactorGroup(G,N),P),epi);;
gap> SemidirectProduct(G,f,H);
<pc group of size 48 with 5 generators>

# 2009/09/23 (AH)
gap> g:=DirectProduct(DihedralGroup(14),SmallGroup(1440,120));;
gap> PositionSublist(StructureDescription(g),"PSL");
fail

# 2009/09/25 (TB)
gap> lin:= LinearCharacters( CyclicGroup( 3 ) );;
gap> lin[2] ^ One( GaloisGroup( CF(3) ) );;

# 2009/09/30 (TB)
gap> v:= GF(2)^1;;
gap> Subspace( v, [] ) < Subspace( v, [] );
false
gap> v:= GF(2)^[1,1];;
gap> Subspace( v, [] ) < Subspace( v, [] );
false

# 2010/09/06 (TB)
gap> G:= SL( 2, 3 );;
gap> x:= [ [ Z(9), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ];;
gap> y:= [ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(9) ] ];;
gap> IsConjugate( G, x, y );
true

# Reported by Sohail Iqbal on 2008/10/15, added by AK on 2010/10/03
gap> f:=FreeGroup("s","t");; s:=f.1;; t:=f.2;;
gap> g:=f/[s^4,t^4,(s*t)^2,(s*t^3)^2];;
gap> CharacterTable(g);
CharacterTable( <fp group of size 16 on the generators [ s, t ]> )
gap> Length(Irr(g));
10

# 2010/10/06 (TB)
gap> EU(7,2);
-1

# Reported by Laurent Bartholdi on 2008/11/14, added by AK on 2010/10/15
gap> f := FreeGroup(0);; g := FreeGroup(1);;
gap> phi := GroupHomomorphismByImages(f,g,[],[]);;
gap> One(f)^phi = One(g);
true
gap> One(f)^phi=One(f);
false

# 2010/10/20 (TB)
gap> NormalizersTom( TableOfMarks( CyclicGroup( 3 ) ) );
[ 2, 2 ]

# 2010/10/27 (TB)
gap> PermChars( CharacterTable( SymmetricGroup( 3 ) ), 3 );
[ Character( CharacterTable( Sym( [ 1 .. 3 ] ) ), [ 3, 1, 0 ] ) ]

# 2010/11/11 (AH)
gap> x:=X(Rationals);;IsIrreducible(x^3-7381125*x^2-5*x+36905625);
false

# Reported by FL on 2010/05/05, added by AK on 2011/01/16
gap> Size(Set(List([1..10],i->Random(1,2^60-1))))=10;
true
gap> Size(Set(List([1..10],i->Random(1,2^60))))=10;  
true

# Reported by MN on 2009/10/06, added by AK on 2011/01/16
gap> (Z(65536)^2)^LogFFE(Z(65536)^16386,Z(65536)^2) = Z(65536)^16386;
true

# Reported by TB on 2009/11/09, added by AK on 2011/01/20
# Log2Int(2^60) bug (a 64bit/GMP issue)
gap> Log2Int( 2^60 );
60

# Reported by Chris Jefferson on 20151008 in github issue #282
gap> Log2Int( -2^60 );
60

# Reported by WDeMeo on 2011/02/19, added by JS on 2011/03/09
# IntermediateSubgroups(G,normal) included non-maximal inclusions
gap> g:=CyclicGroup(2^6);; IntermediateSubgroups( g, TrivialSubgroup(g) ).inclusions;
[ [ 0, 1 ], [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5, 6 ] ]

# Problem with printing when GAP is compiled with GMP 5.0.1 under Mac OS X 
# in 32-bit mode. Does not occur with GMP 4.3.2 or in 64-bit mode.
# Reported by BH on 2011/02/06, added by AK on 2011/03/24
gap> 2*10^201*10;
200000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
00000000000000000000000000000000000000000000000

# 2011/04/29 (TB)
gap> t:= CharacterTable( SmallGroup( 72, 26 ) );;
gap> Set( List( Irr( t ), x -> Size( CentreOfCharacter( x ) ) ) );
[ 6, 12, 18, 72 ]

# 2011/06/01 (TB)
gap> F2:= GF( 2 );;
gap> x:= Indeterminate( F2 );;
gap> F:= AlgebraicExtension( F2, x^2+x+1 );;
gap> Trace( RootOfDefiningPolynomial( F ) );
Z(2)^0

# Reported by Radoslav Kirov on 2011/06/11, added by MH on 2011/09/29
gap> H := [
> [ Z(5)^3, Z(5)^0, Z(5)^0, 0*Z(5), 0*Z(5), 0*Z(5) ],
> [ Z(5)^0, Z(5)^0, 0*Z(5), Z(5)^0, 0*Z(5), 0*Z(5) ],
> [ Z(5)^2, Z(5), 0*Z(5), 0*Z(5), Z(5)^0, 0*Z(5) ],
> [ Z(5)^3, Z(5), 0*Z(5), 0*Z(5), 0*Z(5), Z(5)^0 ]] ;;
gap> cl:=CosetLeadersMatFFE(H, GF(5));; Size(cl);
625
gap> [0,0,3,0,0,2]*Z(5)^0 in cl;
true
gap> [4,0,1,1,4,0]*Z(5)^0 in cl;
false

# 2011/09/29 (FL)
gap> List([1,,3],x->x^2);
[ 1,, 9 ]

# Reported by Izumi Miyamoto on 2011/12/17, added by MH on 2011/12/18
# Computing normalizers inside the trivial group could error out.
gap> Normalizer(Group(()),Group((1,2,3)));
Group(())
gap> Normalizer(Group(()),TransitiveGroup(3,1));
Group(())

# Reported by Ilko Brauch on 2011/12/16, added by MH on 2011/12/18
gap> G := CyclicGroup(IsFpGroup,3);
<fp group of size 3 on the generators [ a ]>
gap> Elements(G);
[ <identity ...>, a, a^2 ]

# 2011/12/20 (FL)
gap> 2^1000000;
<integer 990...376 (301030 digits)>

# Reported by Burkhard Hoefling on 2012/3/14, added by SL on 2012/3/16
# SHIFT_LEFT_VEC8BIT can fail to clean space to its right, which can then
# be picked up by a subsequent add to a longer vector
gap> v := [0*Z(4), 0*Z(4), 0*Z(4), 0*Z(4), Z(4)];
[ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2^2) ]
gap> ConvertToVectorRep (v, 4);
4
gap> SHIFT_VEC8BIT_LEFT(v,1);
gap> w := [0*Z(4), 0*Z(4), 0*Z(4), 0*Z(4),0*Z(4), 0*Z(4), Z(4)];
[ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2^2) ]
gap> ConvertToVectorRep (w, 4);
4
gap> v+w; 
[ 0*Z(2), 0*Z(2), 0*Z(2), Z(2^2), 0*Z(2), 0*Z(2), Z(2^2) ]

# Reported by Burkhard Hoefling on 2012/3/17, added by SL on 2012/3/17
# Converting a compressed vector of length 0 to a bigger field failed.
gap> v := [0*Z(3)];
[ 0*Z(3) ]
gap> ConvertToVectorRep(v);
3
gap> Unbind(v[1]);
gap> ConvertToVectorRep(v,9);
9

# Bug with non-square matrices in ElementaryDivisorsMat, added by MH on 2012/4/3.
# Since ElementaryDivisorsMat just calls SmithNormalFormIntegerMat when
# the base ring R equals Integers, we use GaussianIntegers instead to
# ensure the generic ElementaryDivisorsMat method is tested.
gap> ElementaryDivisorsMat(GaussianIntegers, [ [ 20, -25, 5 ] ]);
[ 5, 0, 0 ]

# 2012/04/13 (MN)
gap> Characteristic(Z(2));
2
gap> Characteristic(0*Z(2));
2
gap> Characteristic(0*Z(5));
5
gap> Characteristic(Z(5));
5
gap> Characteristic(Z(257));
257
gap> Characteristic(Z(2^60));
2
gap> Characteristic(Z(3^20));
3
gap> Characteristic(0);
0
gap> Characteristic(12);
0
gap> Characteristic(12123123123);
0
gap> Characteristic(E(4));
0
gap> Characteristic([Z(2),Z(4)]);
2
gap> v := [Z(2),Z(4)];
[ Z(2)^0, Z(2^2) ]
gap> ConvertToVectorRep(v,4);
4
gap> Characteristic(v);
2
gap> Characteristic([Z(257),Z(257)^47]);
257
gap> Characteristic([[Z(257),Z(257)^47]]);
257
gap> Characteristic(ZmodnZObj(2,6));
6
gap> Characteristic(ZmodnZObj(2,5));
5
gap> Characteristic(ZmodnZObj(2,5123123123));
5123123123
gap> Characteristic(ZmodnZObj(0,5123123123));
5123123123
gap> Characteristic(GF(2,3));
2
gap> Characteristic(GF(2));
2
gap> Characteristic(GF(3,7));
3
gap> Characteristic(GF(1031));
1031
gap> Characteristic(Cyclotomics);
0
gap> Characteristic(Integers);
0
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [ 1/2, 1, 2/3, 2 ] );
gap> a := AlgebraByStructureConstants(Rationals,T);
<algebra of dimension 2 over Rationals>
gap> Characteristic(a);
0
gap> a := AlgebraByStructureConstants(Cyclotomics,T);
<algebra of dimension 2 over Cyclotomics>
gap> Characteristic(a);
0
gap> a := AlgebraByStructureConstants(GF(7),T);
<algebra of dimension 2 over GF(7)>
gap> Characteristic(a);
7
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [ 1, 1, 2, 2 ] );
gap> r := RingByStructureConstants([7,7],T);
<ring with 2 generators>
gap> Characteristic(r);
7
gap> r := RingByStructureConstants([7,5],T);
<ring with 2 generators>
gap> Characteristic(r);
35

#############################################################################
##
## Changes 4.5.4 -> 4.5.5

# Bug with commutator subgroups of fp groups, was causing infinite recursion,
# also when computing automorphism groups
# Fix and test case added by MH on 2012-06-05.
gap> F:=FreeGroup(3);;
gap> G:=F/[F.1^2,F.2^2,F.3^2,(F.1*F.2)^3, (F.2*F.3)^3, (F.1*F.3)^2];;
gap> U:=Subgroup(G, [G.3*G.1*G.3*G.2*G.1*G.3*G.2*G.3*G.1*G.3*G.1*G.3]);;
gap> StructureDescription(CommutatorSubgroup(G, U));
"C2 x C2"
gap> StructureDescription(AutomorphismGroup(G));
"S4"

# 2012/06/15 (AH)
gap> gens:=[[[1,1],[0,1]], [[1,0],[1,1]]] * ZmodnZObj(1,7);
[ [ [ Z(7)^0, Z(7)^0 ], [ 0*Z(7), Z(7)^0 ] ], 
  [ [ Z(7)^0, 0*Z(7) ], [ Z(7)^0, Z(7)^0 ] ] ]
gap> gens:=List(Immutable(gens),i->ImmutableMatrix(GF(7),i));;

# 2012/06/15 (AH)
gap> rng := PolynomialRing(Rationals,2);
Rationals[x_1,x_2]
gap> ind := IndeterminatesOfPolynomialRing(rng);
[ x_1, x_2 ]
gap> x := ind[1];
x_1
gap> y := ind[2];
x_2
gap> pol:=5*(x_1+1)^2;
5*x_1^2+10*x_1+5
gap> factors := Factors(pol);
[ 5*x_1+5, x_1+1 ]
gap> factors[2] := x_2;
x_2
gap> factors[1] := [];
[  ]
gap> Factors( pol );
[ 5*x_1+5, x_1+1 ]

# 2012/07/13 (TB)
gap> IsDocumentedWord( "d" );
false
gap> # "d_N" is documented

#############################################################################
##
## Changes 4.5.5 -> 4.5.6

## For bugfixes

# The GL and SL constructors did not correctly handle GL(filter,dim,ring).
# Reported and fixed by JS on 2012-06-24
gap> GL(IsMatrixGroup,3,GF(2));;
gap> SL(IsMatrixGroup,3,GF(2));;

# The names of two primitive groups of degree 64 were incorrect.
# Reported and fixed by JS on 2012-08-12
gap> PrimitiveGroup(64,53);
2^6:(S3 x GL(3, 2))
gap> PrimitiveGroup(64,64);
2^6:PGL(2, 7)
gap> 

# Fix of very large (more than 1024 digit) integers not being coded 
# correctly in function bodies unless the integer limb size was 16 bits. 
# Reported by Stefan Kohl, fixed by SL on 2012-08-12
gap> f := function() return
> 100000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 000000000000000000000000000000000000000000000000000000000000000000000000000000\
> 00000000; end;
function(  ) ... end
gap> f();
100000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
000000000000000000000000000000000000000000000000000000000000000000000000000000\
00000000

# Fix of Crash in garbage collection following call to AClosVec for a GF(2) code
# Reported by Volker Brown, fixed by SL on 2012-08-31
gap> x:=
> [ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 
>     Z(2)^0, 0*Z(2), Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0 ], 
>   [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 
>     Z(2)^0, Z(2)^0, Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), Z(2)^0 ], 
>   [ 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 
>     Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), Z(2)^0, 0*Z(2), Z(2)^0 ], 
>   [ 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 
>     Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0 ], 
>   [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 
>     Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2) ], 
>   [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 
>     0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2) ], 
>   [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 
>     0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0 ], 
>   [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 
>     Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2) ], 
>   [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 
>     0*Z(2), Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2) ], 
>   [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 
>     0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0, Z(2)^0 ], 
>   [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 
>     Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0, 0*Z(2) ], 
>   [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 
>     0*Z(2), Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0 ] ];;
gap> P:=AClosestVectorDriver(x, GF(2), Z(2)*[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],11,0, true);; 
gap> GASMAN("collect");;

# Crash when reading certain pieces of syntactically invalid code
# Fix and test case added by MH on 2012-09-06.
gap> str := Concatenation("function()\n",
> "local e, v;\n",
> "for e in [] do\n",
> "    v := rec(a := [];);\n",
> "od;\n"
> );
"function()\nlocal e, v;\nfor e in [] do\n    v := rec(a := [];);\nod;\n"
gap> s:=InputTextString(str);
InputTextString(0,66)
gap> Read(s);
Syntax error: ) expected in stream line 4
    v := rec(a := [];);
                    ^
Syntax error: end expected in stream line 5
od;
 ^

# Check that \in method works for groups handled by a nice monomorphism
# created with a custom SeedFaithfulAction.
# Fix and test case added by MH on 2012-09-07.
gap> m1:=PermutationMat( (1,2), 5, GF(5) );;
gap> m2:=PermutationMat( (3,4), 5, GF(5) );;
gap> n:=PermutationMat( (1,4,5), 5, GF(5) );;
gap> G:=Group(m1, m2);;
gap> SetSeedFaithfulAction(G,rec(points:=[m1[1],m1[3]], ops:=[OnPoints,OnPoints]));
gap> n in G;
false

# Check that overloading of a loaded help book by another one works. This 
# makes sense if a book of a not loaded package is loaded in a workspace 
# and GAP is started with a root path that contains a newer version. 
# Reported by Sebastian Gutsche, fixed by FL on 2012-09-11
gap> old := ShallowCopy(HELP_KNOWN_BOOKS[2][1]);;
gap> HELP_KNOWN_BOOKS[2][1][3] := 
> Concatenation(HELP_KNOWN_BOOKS[2][1][3], "blabla");;
gap> CallFuncList(HELP_ADD_BOOK, old);
#I  Overwriting already installed help book 'tutorial'.

# Check of the membership test after fixing a method for coefficients 
# to check after Gaussian elimination that the coefficients actually 
# lie in the left-acting-domain of the vector space. 
# Reported by Kevin Watkins, fixed by TB (via AK) on 2012-09-13
gap> Sqrt(5)*IdentityMat(2) in VectorSpace(Rationals,[IdentityMat(2)]);
false

# Check that removing wrong PrintObj method fixes delegations accordingly
# to documented behaviour for PrintObj/ViewObj/Display.
# Reported by TB, fixed by MN on 2012-08-20.
gap> if IsBound(IsXYZ) then MakeReadWriteGlobal("IsXYZ"); Unbind(IsXYZ); fi;
gap> fam := NewFamily("XYZsFamily");;
gap> DeclareCategory("IsXYZ",IsObject);
gap> type := NewType(fam,IsXYZ and IsPositionalObjectRep);;
gap> o := Objectify(type,[]);;
gap> InstallMethod(String,[IsXYZ],function(o) return "XYZ"; end);
gap> o;
XYZ
gap> Print(o,"\n");
XYZ
gap> String(o);
"XYZ"

## For new features

# 2012/08/13 (AK)
gap> First(PositiveIntegers,IsPrime);
2

#############################################################################
##
## Changes 4.5.6 -> 4.5.7

## For bugfixes

# 2012/11/02 (FL)
# Fix a crash on 32-bit systems when Log2Int(n) is not an immediate integer. 
gap> a:=(2^(2^15))^(2^14);;
gap> Log2Int(a);
536870912

# 2012/09/26 (AH)
gap> p:=7;;
gap> F:=FreeGroup("a","b","c","d","e","f");;
gap> G:=F/[ F.1^p, F.2^p, F.3^p, F.4^p, F.5^p, F.6^p,
> Comm(F.2,F.1)*F.3^-1, Comm(F.3,F.1)*F.4^-1,
> Comm(F.4,F.1)*F.5^-1, Comm(F.4,F.2)*F.6^-1,
> Comm(F.5,F.2)*F.6^-1, Comm(F.4,F.3)*F.6,
> Comm(F.1,F.5), Comm(F.1,F.6), Comm(F.2,F.3),
> Comm(F.2,F.6), Comm(F.3,F.5), Comm(F.3,F.6),
> Comm(F.4,F.5), Comm(F.4,F.6), Comm(F.5,F.6)];;
gap> G:=Image(IsomorphismPermGroup(G));;
gap> DerivedSubgroup(G)=FrattiniSubgroup(G);
true
gap> sd1:=StructureDescription(DerivedSubgroup(G));;
gap> sd2:=StructureDescription(FrattiniSubgroup(G));;
gap> sd1=sd2;
true

# 2012/10/05 (AH)
gap> G:=DirectProduct(CyclicGroup(2),PSL(3,4));; 
gap> NaturalHomomorphismByNormalSubgroup(G,TrivialSubgroup(G));;

# 2012/10/26 (SL) 
# Fix a crash when a logfile opened with LogTo() is closed with LogInputTo()  
gap> LogTo( Filename( DirectoryTemporary(), "foo" ) );
gap> LogInputTo();
Error, InputLogTo: can not close the logfile
gap> LogTo();

# 2012/11/15 (SL)
gap> x := ZmodnZObj(2,10);
ZmodnZObj( 2, 10 )
gap> y := ZmodnZObj(0,10);
ZmodnZObj( 0, 10 )
gap> x/y;
fail
gap> y/x;
fail
gap> x/0;
fail
gap> 3/y;
fail

# 2012/11/21 (SL)
gap> s := FreeSemigroup("a","b");
<free semigroup on the generators [ a, b ]>
gap> t := Subsemigroup(s,[s.1]);
<infinite commutative semigroup with 1 generator>
gap> t := Subsemigroup(s,[s.1]);
<infinite commutative semigroup with 1 generator>
gap> HasSize(t);
true
gap> Size(t);
infinity
gap> t := Subsemigroup(s, []);
<semigroup of size 0, with 0 generators>
gap> HasSize(t);
true
gap> Size(t);
0

# 2012/11/25 (AK)
# Fix of a bug that was reproducible in GAP 4.5.6 with FGA 1.1.1
gap> f := FreeGroup(2);
<free group on the generators [ f1, f2 ]>
gap> iso:=GroupHomomorphismByImagesNC(f,f,[f.1*f.2,f.1*f.2^2],[f.2^2*f.1,f.2*f.1]); 
[ f1*f2, f1*f2^2 ] -> [ f2^2*f1, f2*f1 ]
gap> SetIsSurjective(iso,true);
gap> Image(iso,PreImagesRepresentative(iso,f.1));
f1

# 2012/11/26 (MN)
gap> 10^20000+12345;
<integer 100...345 (20001 digits)>
gap> -(10^20000+12345);
<integer -100...345 (20001 digits)>

# 2012/12/06 (AK)
gap> x := Indeterminate(Rationals);
x_1
gap> InverseSM(Zero(x));
fail
gap> Inverse(Zero(x));
fail
gap> InverseOp(Zero(x));
fail

#############################################################################
##
## Changes 4.5.7 -> 4.6.2

## For bugfixes

# 2012/10/26 (SL)
gap> r := rec(1 := rec(x := true));;
gap> r.1.x;
true

# 2012/11/01 (SL)
gap> m := IdentityMat(10,GF(7));;
gap> m[3][3] := 0*Z(7,6);;
gap> Display(m);
 1 . . . . . . . . .
 . 1 . . . . . . . .
 . . . . . . . . . .
 . . . 1 . . . . . .
 . . . . 1 . . . . .
 . . . . . 1 . . . .
 . . . . . . 1 . . .
 . . . . . . . 1 . .
 . . . . . . . . 1 .
 . . . . . . . . . 1

# 2012/12/17 (SL)
gap> l := [1,2,3];;
gap> Unbind(l,1);
Syntax error: 'Unbind': argument should be followed by ')' in stream line 1
Unbind(l,1);
        ^
gap> l;
[ 1, 2, 3 ]

# 2013/01/07 (MH)
gap> m:=IdentityMat(8,GF(3));;
gap> m2:=m + List([1..8],i->List([1..8], j->Zero(GF(3))));;
gap> DefaultScalarDomainOfMatrixList([m,m2]);
GF(3)
gap> DefaultScalarDomainOfMatrixList([m2,m]);
GF(3)

## For new features

# 2012/08/14 (AK)
gap> R:=PolynomialRing(GF(5),"mu");;
gap> mu:=Indeterminate(GF(5));;
gap> T:=AlgebraicExtension(GF(5),mu^5-mu+1);;
gap> A:=PolynomialRing(T,"x");
<field of size 3125>[x]

# 2012/09/14 (SL)
gap> a := BlistList([1,2,3],[1]);;
gap> b := BlistList([1,2,3],[2]);;
gap> c := BlistList([1,2,3],[2,3]);;
gap> MEET_BLIST(a,b);
false
gap> MEET_BLIST(a,c); 
false
gap> MEET_BLIST(b,c);
true
gap> MEET_BLIST(a,a);
true

# 2012/11/10 (SL)
gap> l :=  [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6, 11 ];;
gap> SortBy(l,AINV);
gap> l;
[ 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]

# 2012/11/20 (BH)
gap> G := WreathProduct (CyclicGroup (IsPermGroup, 7), SymmetricGroup (5));
<permutation group of size 2016840 with 7 generators>
gap> IsPSolvable (G, 2);
false
gap> IsPSolvable (G, 3);
false
gap> IsPSolvable (G, 5);
false
gap> IsPSolvable (G, 7);
true
gap> IsPNilpotent(GL(3,2),2);
false

# 2012/12/17 (SL)
gap> DeclareOperation("MyOp",[IsObject, IsObject]);
gap> DeclareAttribute("MyOp",IsObject);

# 2013/01/17 (AK)
gap> lo:= LieObject( [ [ 1, 0 ], [ 0, 1 ] ] );
LieObject( [ [ 1, 0 ], [ 0, 1 ] ] )
gap> m:=UnderlyingRingElement(lo);
[ [ 1, 0 ], [ 0, 1 ] ]
gap> lo*lo;
LieObject( [ [ 0, 0 ], [ 0, 0 ] ] )
gap> m*m;
[ [ 1, 0 ], [ 0, 1 ] ]

# 2013/01/20 (SL)
gap> DistancePerms((1,2,3,4,5,6),(1,2,3));
4

#############################################################################
##
## Changes 4.6.2 -> 4.6.3

## For bugfixes

# 2013/02/07 (AK)
gap> PowerModInt(3,0,1);
0

# 2013/02/27 (SL)
gap>  m:= [[Z(3^16),0],[1,Z(3)]] * One( Z(3) );
[ [ z, 0*Z(3) ], [ Z(3)^0, Z(3) ] ]
gap> Display(m);
z = Z( 3, 16); z2 = z^2, etc.
z . 
1 2 
gap> m[1][1]:= m[1][1] + 1;
1+z
gap> Display( m );
z = Z( 3, 16); z2 = z^2, etc.
1+z .   
1   2   

# 2013/02/27 (AK)
gap> G:=SymmetricGroup(8);
Sym( [ 1 .. 8 ] )
gap> H:=SylowSubgroup(G,3);;
gap> HasIsPGroup(H);
true
gap> HasPrimePGroup(H);
true

# 2013/02/28 (BH). More tests added by AK
gap> Length( AbsolutIrreducibleModules( AlternatingGroup(5), GF(4), 120) );
2
gap> Length( IrreducibleRepresentations( DihedralGroup(10), GF(2^2) ) );
3
gap> Length( AbsoluteIrreducibleModules( CyclicGroup(3), GF(4), 1) );
2
gap> G:=DihedralGroup(20);; b:=G.1*G.2;; Order(b);
2
gap> ForAll( IrreducibleRepresentations(G,GF(8)), phi -> IsOne(Image(phi,b)^2));
true

# 2013/03/06 (MH)
gap> PermutationMat((1,2),2,GF(3^6));
[ [ 0*Z(3), Z(3)^0 ], [ Z(3)^0, 0*Z(3) ] ]

# 2013/03/07 (MH)
gap> s:="cba";
"cba"
gap> IsSSortedList(s);
false
gap> IsInt(RNamObj(s));
true
gap> r:=rec(cba := 1);;
gap> IsBound(r.(s));
true

# 2013/03/08 (MH)
gap> v:=[ Z(2^4)^3, Z(2^4)^6, Z(2)^0 ];
[ Z(2^4)^3, Z(2^4)^6, Z(2)^0 ]
gap> ConvertToVectorRepNC(v,256);
256
gap> RepresentationsOfObject(v);
[ "IsDataObjectRep", "Is8BitVectorRep" ]
gap> R:=PolynomialRing( GF(2^8) );
GF(2^8)[x_1]
gap> x := Indeterminate(GF(2^8));
x_1
gap> f := x^2+Z(2^4)^6*x+Z(2^4)^3;
x_1^2+Z(2^4)^6*x_1+Z(2^4)^3
gap> Length( FactorsSquarefree( R, f, rec() ) );
2

# 2013/03/12 (MH)
gap> v:=IdentityMat(28,GF(2))[1];
<a GF2 vector of length 28>
gap> v{[1..Length(v)]}{[1..5]};
Error, List Elements: <lists> must be a list (not a object (data))

## For new features

# 2013/02/27 (AK)
gap> F := FreeGroup("a","b");;
gap> G := F/[F.1*F.2*F.1*F.2*F.1];;
gap> IsAbelian(G);
true
gap> DerivedSubgroup(G);
Group([  ])

# 2013/02/28 (MH)
gap> NullMat(2,1,ZmodnZObj(1,15));
[ [ ZmodnZObj( 0, 15 ) ], [ ZmodnZObj( 0, 15 ) ] ]
gap> IdentityMat(10,Z(4));
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2),
       0*Z(2) ], 
  [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2),
       0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2),
       0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2),
       0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2),
       0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2),
       0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2),
       0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2),
       0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0,
       0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2),
       Z(2)^0 ] ]

#############################################################################
##
## Changes 4.6.3 -> 4.6.4

## For bugfixes

# 2013/03/27 (AK)
gap> im := [ [ [E(3)^2,0], [0,E(3)] ], [ [0,E(3)], [E(3)^2,0] ] ];;
gap> hom := GroupHomomorphismByImages( SymmetricGroup(3), Group(im), im );;
gap> NaturalCharacter(hom);
Character( CharacterTable( Sym( [ 1 .. 3 ] ) ), [ 2, 0, -1 ] )

# 2013/04/01 (MN)
gap> slp := StraightLineProgram(
> [ [ 1, -1 ], [ 2, -1 ], [ 3, -1 ], [ 4, -1 ], [ 5, -1 ], [ 4, 1, 10, 1 ], 
> [ 11, -1 ], [ 1, 0 ], [ 1, 0 ], [ 1, 0 ], [ 1, 0 ], [ 1, 0 ], [ 1, 0 ], 
> [ 1, 0 ], [ 1, 0 ], [ 1, 0 ], [ 8, 0, 10, 1, 8, 0, 5, 1 ], 
> [ 22, 1, 1, 1, 7, 1, 6, 1, 22, -1 ], [ 1, 0 ], [ 1, 0 ], [ 1, 0 ], 
> [ 23, 1 ], [ 27, 4 ], [ 28, 1, 13, 1 ], [ 27, 1 ] ],5);;
gap> SlotUsagePattern(slp);;

#############################################################################
##
## Changes 4.6.4 -> 4.6.5

## For bugfixes

# 2013/05/02 (BH)
gap> a := IntHexString("0000000000000000000000");
0
gap> a = 0;
true
gap> IsSmallIntRep(a);
true
gap> a := IntHexString("0000000000000000000001");
1
gap> a = 1;
true
gap> IsSmallIntRep(a);
true

# 2013/05/16 (AH)
gap>  TransitiveIdentification(TransitiveGroup(30,4064)^(1,4,5,2)
> (6,20,15,21,7,16,12,24)(8,18,14,22,10,17,13,23,9,19,11,25)(26,30,29,28));
4064

#############################################################################
##
## Changes 4.6.5 -> 4.7.1

## For bugfixes

# 2013/02/20 (AK)
gap> QuotientMod(4, 2, 6);
fail
gap> QuotientMod(2, 4, 6);
fail
gap> a := ZmodnZObj(2, 6);; b := ZmodnZObj(4, 6);;
gap> a/b;
fail
gap> b/a;
fail

# 2013/08/20 (MH)
gap> G:=SmallGroup(2^7*9,33);;
gap> H:=DirectProduct(G, ElementaryAbelianGroup(2^10));;
gap> Exponent(H); # should take at most a few milliseconds
72
gap> K := PerfectGroup(2688,3);;
gap> Exponent(K); # should take at most a few seconds
168

# 2013/08/21 (MH)
gap> IsStringRep("");
true
gap> RepresentationsOfObject("");
[ "IsStringRep", "IsInternalRep" ]
gap> DeclareOperation("TestOp",[IsStringRep]);
gap> InstallMethod(TestOp,[IsStringRep], function(x) Print("Your string: '",x,"'\n"); end);
gap> TestOp("");
Your string: ''
gap> PositionSublist("xyz", "");
1

# 2013/08/21 (MH)
gap> . . . .
Syntax error: Badly formed number, need a digit before or after the decimal po\
int in stream line 1
. . . .
^

# 2013/08/29 (MH)
gap> record := rec( foo := "bar" );
rec( foo := "bar" )
gap> fooo := "fooo";
"fooo"
gap> Unbind( fooo[4] );
gap> record.(fooo);
"bar"

# 2013/09/25 (AK, CJ)
gap> L := List(Shuffle([1..1000]), x -> Set([x]));;

# 2013/11/02 (AH)
gap> f:=FreeGroup(2);; id:=Group(Identity(f));; Id:=TrivialSubgroup(f);;
gap> LowIndexSubgroupsFpGroup(f,Id,2)=LowIndexSubgroupsFpGroup(f,id,2);
true

# 2013/11/19 (AK)
gap> rel := BinaryRelationOnPoints([[2,3],[4,5],[4,5],[6],[6],[]]);
Binary Relation on 6 points
gap> rel := ReflexiveClosureBinaryRelation(TransitiveClosureBinaryRelation(rel));
Binary Relation on 6 points
gap> IsLatticeOrderBinaryRelation(rel);
false
gap> rel := BinaryRelationOnPoints([[2,3],[4,5],[4],[6],[6],[]]);
Binary Relation on 6 points
gap> rel := ReflexiveClosureBinaryRelation(TransitiveClosureBinaryRelation(rel));
Binary Relation on 6 points
gap> IsLatticeOrderBinaryRelation(rel);
true

## For new features

# 2013/06/14 (AK, MH)
gap> foo:=function() return 42; end;
function(  ) ... end
gap> DeclareObsoleteSynonym("bar","foo","4.8");
gap> SetInfoLevel(InfoObsolete,1);
gap> bar();
#I  'bar' is obsolete.
#I  It may be removed in the future release of GAP 4.8
#I  Use foo instead.
42
gap> SetInfoLevel(InfoObsolete,0);

# 2013/08/08 (AH)
gap> free:=FreeGroup("a","b");
<free group on the generators [ a, b ]>
gap> product:=free/ParseRelators(free,"a2,b3");;
gap> SetIsFinite(product,false);
gap> GrowthFunctionOfGroup(product,12);
[ 1, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128 ]
gap> GrowthFunctionOfGroup(MathieuGroup(12));
[ 1, 5, 19, 70, 255, 903, 3134, 9870, 25511, 38532, 16358, 382 ]

# 2013/08/11 (MH)
gap> F:=FreeAbelianGroup(3);
<fp group on the generators [ f1, f2, f3 ]>
gap> IsAbelian(F);
true
gap> Size(F);
infinity

#############################################################################
##
## Changes 4.7.5 -> 4.7.6

## For bugfixes

# 2014/08/11 (AH)
gap> eij:=function(i,j)
> local I;
> I:=Z(2)*IdentityMat(5);
> I[i][j]:=Z(2);
> return I;
> end;;
gap> G2:=Group([eij(1,2),eij(2,3),eij(3,4),eij(4,5),eij(2,1),eij(4,3)]);;
gap> Length(NormalSubgroups(G2));
16

# 2014/08/13 (TB, AK). A bug that may cause ShortestVectors 
# to return an incomplete list (reported by Florian Beye).
gap> M:=[[4,-1,-2,1,2,-1,0,0,0,0,1,-1,2,-2,0,0,0,-2,2,-3,3,0],
> [-1,4,1,0,-1,2,0,3,3,-1,1,1,1,1,-1,1,3,1,-3,2,1,0],
> [-2,1,4,-1,-2,1,0,1,1,0,1,0,0,2,0,0,0,2,-2,4,-2,0],
> [1,0,-1,2,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
> [2,-1,-2,-1,6,-2,0,0,0,1,0,0,2,-2,0,0,0,-3,4,-4,4,-1],
> [-1,2,1,0,-2,4,0,2,2,0,0,0,1,2,-1,2,4,0,-1,2,-2,1],
> [0,0,0,0,0,0,2,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0],
> [0,3,1,0,0,2,0,6,4,-1,2,0,3,1,-1,2,4,0,-2,2,2,-1],
> [0,3,1,0,0,2,-1,4,6,-1,2,0,3,1,-1,2,4,0,-2,2,2,-1],
> [0,-1,0,0,1,0,0,-1,-1,2,-1,0,1,0,0,0,0,-1,3,0,-1,0],
> [1,1,1,0,0,0,0,2,2,-1,4,-1,1,1,0,0,0,1,-2,2,2,-1],
> [-1,1,0,0,0,0,0,0,0,0,-1,2,-1,0,0,0,0,0,0,0,0,0],
> [2,1,0,0,2,1,0,3,3,1,1,-1,6,-1,-1,2,4,-2,2,0,2,-1],
> [-2,1,2,0,-2,2,0,1,1,0,1,0,-1,4,0,0,0,2,-2,4,-2,0],
> [0,-1,0,0,0,-1,0,-1,-1,0,0,0,-1,0,2,-1,-2,0,0,0,0,0],
> [0,1,0,0,0,2,0,2,2,0,0,0,2,0,-1,4,4,-2,0,0,0,0],
> [0,3,0,0,0,4,0,4,4,0,0,0,4,0,-2,4,8,-2,0,0,0,0],
> [-2,1,2,0,-3,0,0,0,0,-1,1,0,-2,2,0,-2,-2,4,-4,4,-2,0],
> [2,-3,-2,0,4,-1,0,-2,-2,3,-2,0,2,-2,0,0,0,-4,8,-4,0,0],
> [-3,2,4,0,-4,2,0,2,2,0,2,0,0,4,0,0,0,4,-4,8,-4,0],
> [3,1,-2,0,4,-2,0,2,2,-1,2,0,2,-2,0,0,0,-2,0,-4,8,-2],
> [0,0,0,0,-1,1,0,-1,-1,0,-1,0,-1,0,0,0,0,0,0,0,-2,2]];;
gap> IsZero(M - TransposedMat(M));
true
gap> sv := ShortestVectors(M, 2).vectors;;
gap> s2 := Set(Concatenation(sv, -sv));;
gap> v := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,2,1,0,1,1];;
gap> v * M * v - 2 = 0;
true
gap> v in s2;
true

# 2014/08/21 (AK, CJ)
gap> (13*10^18) + (-3*10^18) = (10^19);
true

# 2014/09/05 (TB, reported by Benjamin Sambale)
gap> OrthogonalEmbeddings([[4]]);
rec( norms := [ 1, 1/4 ], solutions := [ [ 1 ], [ 2, 2, 2, 2 ] ], 
  vectors := [ [ 2 ], [ 1 ] ] )

# 2014/10/22 (CJ)
gap> Stabilizer(SymmetricGroup(5), [1,2,1,2,1], OnTuples) = Group([(3,5),(4,5)]);
true

#############################################################################
##
## Changes 4.7.6 -> 4.7.7

## For bugfixes
# 2014/12/05 (CJ, reported by Matt Fayers; see also tst/union.tst)
gap> Union([2],[3],[5,1..1]);
[ 1, 2, 3, 5 ]

# 2014/12/31 (AH, reported by Daniel Błażewicz)
gap> x := Indeterminate( Rationals, "x" );;
gap> ProbabilityShapes(x^5+5*x^2+3);
[ 2 ]
gap> GaloisType(x^12+63*x-450); # this was causing an infinite loop
301

# 2015/01/11 (CJ, reported by TB)
gap> x:= rec( qq:= "unused", r:= rec() );;
gap> y:= x.r;;
gap> y.entries:= rec( parent:= y );;
gap> x;
rec( qq := "unused", r := rec( entries := rec( parent := ~.r ) ) )

# 2015/01/08 (JM, reported by Nick Loughlin)
gap> FreeMonoid( infinity, "m", [  ] );
<free monoid with infinity generators>

# 2015/02/01 (MP, reported by WdG and HD )
gap> a:= 1494186269970473680896;
1494186269970473680896
gap> b:= 72057594037927936;
72057594037927936
gap> RemInt(a,b);
0

# 2015/02/02 (AH, reported by Petr Savicky)
gap> it := SimpleGroupsIterator(17971200);
<iterator>
gap> G := NextIterator(it); # 2F(4,2)'
2F(4,2)'
gap> ClassicalIsomorphismTypeFiniteSimpleGroup(G);
rec( parameter := [ "T" ], series := "Spor" )

# 2015/02/16 (CJ, Reported by TB)
gap> a:= rec();; a.( "" ):= 1;; a; Print( a,"\n" );
rec( ("") := 1 )
rec(
  ("") := 1 )

#2015/02/16 (CJ, reported by TB)
gap> f1:= function( x, l ) return ( not x ) in l; end;;
gap> f2:= function( x, l ) return not ( x in l ); end;;
gap> f3:= function( x, l ) return not x in l;     end;;
gap> [f1(true,[]), f2(true,[]), f3(true,[])];
[ false, true, true ]
gap> Print([f1,f2,f3],"\n");
[ function ( x, l )
        return (not x) in l;
    end, function ( x, l )
        return not x in l;
    end, function ( x, l )
        return not x in l;
    end ]

#############################################################################
##
## Changes 4.7.7 -> 4.7.8

#2015/05/12 (WdG, reported by Istvan Szollosi)
gap> L:= SimpleLieAlgebra("A",1,Rationals);
<Lie algebra of dimension 3 over Rationals>
gap> V:= HighestWeightModule(L,[2]);
<3-dimensional left-module over <Lie algebra of dimension 3 over Rationals>>
gap> v:= Basis(V)[1];
1*v0
gap> z:= Zero(V);
0*v0
gap> IsZero(z);
true
gap> w:= z+v;
1*v0
gap> -w+w;
0*v0

#############################################################################
#
#  Changes 4.7.8 -> 4.7.9

#2015/10/20 (Chris Jefferson)
gap> extS := ExternalSet(SymmetricGroup(4), [1..4],
>                   GeneratorsOfGroup(SymmetricGroup(4)),
>                   GeneratorsOfGroup(SymmetricGroup(4)),
>                   OnRight);
<xset:[ 1 .. 4 ]>
gap> ExternalSubset(extS);
[  ]^G

#############################################################################
#
#  Changes 4.8.3 -> 4.8.4

#2016/04/14 (Chris Jefferson)
gap> a := "abc";
"abc"
gap> b := "def";
"def"
gap> IsSortedList(a);
true
gap> IsSortedList(b);
true
gap> c := Concatenation(b,a);
"defabc"
gap> HasIsSortedList(c);
false
gap> IsSortedList(c);
false

# These functions all worked incorrectly when given symmetric or alternating groups
# Which were not not defined on a domain of the form [1..n]
gap> RepresentativeAction(SymmetricGroup([5,7,11,15]),[7,11],[5,15],OnTuples);
(5,7)(11,15)
gap> RepresentativeAction(AlternatingGroup([5,7,11,15]),[7,11],[5,15],OnTuples);
(5,7)(11,15)
gap> RepresentativeAction(SymmetricGroup([5,7,11,15]),[7,11],[5,15],OnSets);
(5,7)(11,15)
gap> RepresentativeAction(AlternatingGroup([5,7,11,15]),[7,11],[5,15],OnSets);
(5,7)(11,15)

#############################################################################
#
# Tests requiring loading some packages must be performed at the end.
# Do not put tests that do not need any packages below this line.
#
#############################################################################
#
# Tests requiring TomLib

##  bug 2 for fix 6
gap> if LoadPackage("tomlib", false) <> fail then
>      DerivedSubgroupsTom( TableOfMarks( "A10" ) );
>    fi;

#############################################################################
#
# Tests requiring CTblLib

# 2005/08/29 (TB)
gap> LoadPackage("ctbllib", "=0.0",false);
fail

##  Bug 18 for fix 4
gap> if LoadPackage("ctbllib", false) <> fail then
>      if Irr( CharacterTable( "WeylD", 4 ) )[1] <>
>           [ 3, -1, 3, -1, 1, -1, 3, -1, -1, 0, 0, -1, 1 ] then
>        Print( "problem with Irr( CharacterTable( \"WeylD\", 4 ) )[1]\n" );
>      fi;
>    fi;

# 2005/08/23 (TB)
gap> tbl:= CharacterTable( ElementaryAbelianGroup( 4 ) );;
gap> IsElementaryAbelian( tbl );
true
gap> ClassPositionsOfMinimalNormalSubgroups( tbl );
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ] ]
gap> if LoadPackage("ctbllib", false) <> fail then
>      tbl:= CharacterTableIsoclinic( CharacterTable( "2.A5.2" ) );
>      if tbl mod 3 = fail then
>        Error( CharacterTable( "Isoclinic(2.A5.2)" ), " mod 3" );
>      fi;
>      SourceOfIsoclinicTable( tbl );
>    fi;
gap> tbl:= CharacterTable( Group( () ) );;
gap> ClassPositionsOfElementaryAbelianSeries( tbl );;

# 2005/10/29 (TB)
gap> if LoadPackage("ctbllib", false) <> fail then
>      t:= CharacterTable( "S12(2)" );  p:= PrevPrimeInt( Exponent( t ) );
>      if not IsSmallIntRep( p ) then
>        PowerMap( t, p );
>      fi;
>    fi;

# 2005/12/08 (TB)
gap> if LoadPackage("ctbllib", false) <> fail then
>      if List( Filtered( Irr( CharacterTable( "Sz(8).3" ) mod 3 ),
>                         x -> x[1] = 14 ), ValuesOfClassFunction )
>         <> [ [ 14, -2, 2*E(4), -2*E(4), -1, 0, 1 ],
>              [ 14, -2, -2*E(4), 2*E(4), -1, 0, 1 ] ] then
>        Print( "ordering problem in table of Sz(8).3 mod 3\n" );
>      fi;
>    fi;

# 2005/12/08 (TB)
gap> LoadPackage("ctbllib", false);;
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> SetIdentifier( t, "Sym(4)" );  Display( t,
>     rec( powermap:= "ATLAS", centralizers:= "ATLAS", chars:= false ) );
Sym(4)

    24  4  8  3  4

 p      A  A  A  B
 p'     A  A  A  A
    1A 2A 2B 3A 4A


#############################################################################
#
# Tests requiring Crisp 

# 2005/05/03 (BH)
gap> if LoadPackage("crisp", false) <> fail then
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

# 2005/06/23 (AH)
gap> if LoadPackage("crisp", false) <> fail then
>     h:=Source(EpimorphismSchurCover(SmallGroup(64,150)));
>     NormalSubgroups( Centre( h ) );
>     fi;

# 2005/10/14 (BH)
gap> if LoadPackage("crisp", "1.2.1", false) <> fail then
>     G := DirectProduct(CyclicGroup(2), CyclicGroup(3), SymmetricGroup(4));
>     AllInvariantSubgroupsWithQProperty (G, G, ReturnTrue, ReturnTrue, rec());
>     if ( (1, 5) in EnumeratorByPcgs ( Pcgs( SymmetricGroup (4) ) ) ) then
>      Print( "problem with crisp (7)\n" );
>     fi;
>    fi;

# 2012/06/18 (FL)
gap> if LoadPackage("cvec",false) <> fail then mat := [[Z(2)]]; 
> ConvertToMatrixRep(mat,2); cmat := CMat(mat); cmat := cmat^1000; fi;

# 2012/06/18 (MH)
gap> if LoadPackage("anupq",false) <> fail then
> for i in [1..192] do Q:=Pq( FreeGroup(2) : Prime:=3, ClassBound:=1 ); od; fi;

# 2015/04/01 (SL)
gap> p := 227;; x := X(GF(p), "x");; f := x^(7^2) - x;;
gap> PowerMod(x, p, f);
x^35

#2016/2/4 (AH)
gap> N := AlternatingGroup(6);; H := AutomorphismGroup(N);;
gap> G := SemidirectProduct(H, N);;
gap> Size(Image(Embedding(G, 1)))=Size(H);
true

#2016/3/1 (AH)
gap> g:=PSL(6,4);;
gap> Sum(ConjugacyClasses(g),Size)=Size(g);
true
gap> Size(AutomorphismGroup(TransitiveGroup(12,269)));
14400

#2016/3/3 (AH, reported by DFH)
gap> G:=Group([[[0,1,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,0,0],[0,0,0,1,0,0,0,0,0],
> [0,0,1,0,0,0,0,0,0],[0,0,0,0,0,1,0,0,0],[0,0,0,0,1,0,0,0,0],
> [0,0,0,0,0,0,0,1,0],[0,0,0,0,0,0,1,0,0],
> [1,1,Z(4)^2,Z(4)^2,Z(4)^2,Z(4)^2,0,0,1]],
> [[0,0,1,0,0,0,0,0,0],[Z(4)^2,Z(4),Z(4),0,0,0,0,0,0],
> [Z(4),Z(4)^2,Z(4),0,0,0,0,0,0],[0,0,0,0,1,0,0,0,0],
> [Z(4),Z(4),Z(4),1,1,0,0,0,0],[0,0,0,0,0,0,1,0,0],[1,1,1,0,0,1,1,0,0],
> [0,0,0,0,0,0,0,0,1],[Z(4),Z(4),Z(4),0,0,0,0,1,1]]]*Z(4)^0);;
gap> pa:=ProjectiveActionHomomorphismMatrixGroup(G);;  
gap> r:=PseudoRandom(G);;                                       
gap> a:=PreImagesRepresentative(pa,ImagesRepresentative(pa,r));; 
gap> Order(r/a) in [1,3];
true
gap> H:=Image(pa);;Size(H);
50232960

#2016/3/11 (AH, reported by CJ)
gap> g := Group([ (1,2,3), (2,3,4) ]);;
gap> IsAlternatingGroup(g);
true
gap> Size(Stabilizer(g, [ [1,2], [3,4] ], OnSetsSets));
4

#2016/3/16 (AH, issue #675)
gap> G:=Group((1,2,3,4));;Factorization(G,Elements(G)[1]);
<identity ...>

#2016/5/2 (MP)
gap> S := FullTransformationMonoid(2);;
gap> D := GreensDClassOfElement(S, IdentityTransformation);;
gap> Intersection(D, []);
[  ]
gap> Intersection([], D);
[  ]

#2016/04/29 (FL, bug reported on support list)
gap> Collected(List([1..200], i-> RandomPrimitivePolynomial(2,2)));
[ [ x_1^2+x_1+Z(2)^0, 200 ] ]

#another bug, detected when fixing the previous one (FL)
gap> RandomPrimitivePolynomial(2,2,100);
x_100^2+x_100+Z(2)^0

#and a third bug (FL)
gap> RandomPrimitivePolynomial(2,1);
x_1+Z(2)^0
gap> RandomPrimitivePolynomial(2,1,13);
x_13+Z(2)^0

#2016/04/27 (FL, bug reported on support list)
gap> l := [1,,,5];;
gap> Remove(l);
5
gap> [l, Length(l)];
[ [ 1 ], 1 ]
gap> l := [,,,"x"];;
gap> Remove(l);
"x"
gap> [l, Length(l)];
[ [  ], 0 ]
gap> l := [1,2,,[],"x"];;
gap> Remove(l);
"x"
gap> [l, Length(l)];
[ [ 1, 2,, [  ] ], 4 ]

#2016/8/1 (#869)
gap> x:=X(GF(4));;e:=AlgebraicExtension(GF(4),x^3+x+1);;
gap> Length(Elements(e));
64
gap> Length(Set(Elements(e)));
64

#2016/8/4 (AH, Reported by D. Savchuk)
gap> r1:=PolynomialRing(GF(2),3);
GF(2)[x_1,x_2,x_3]
gap> x_1:=r1.1;;x_2:=r1.2;;x_3:=r1.3;;
gap> I:=Ideal(r1,[x_1^2-x_2,x_2^2-x_1,x_1*x_2-x_3]);;
gap> Size(r1/I);
16
gap> r1:=PolynomialRing(GF(2),4);;
gap> x_1:=r1.1;;x_2:=r1.2;;x_3:=r1.3;;x_4:=r1.4;;
gap> rels:=[x_1^2+x_2,x_1*x_2+x_3,x_1*x_3+x_4, x_1*x_4+x_1,x_2^2+x_4,
>   x_2*x_3+x_1,x_2*x_4+x_2,x_3^2+x_2,x_3*x_4+x_3,x_4^2+x_4];;
gap> Size(r1/Ideal(r1,rels));
32

# 2016/8/22 (AH)
gap> g:=Group((1,2,4,3)(5,7,6,8)(9,11,10,13)(12,16,14,15)(17,19,18,20)       
> (21,23,22,24)(25,31,36,39,35,27)(26,30,37,38,33,28)(29,32,34)
> (40,41,42,43,44),
> (1,3,6)(2,5,4)(7,9,12)(8,10,14)(11,15,17)(13,16,18)(19,21,24)
> (20,22,23)(25,28,34)(26,33,37)(29,35,38)(30,32,36)(45,46,47,48,49));;
gap> Size(FrattiniSubgroup(g));
2

#############################################################################
gap> STOP_TEST( "bugfix.tst", 831990000);

#############################################################################
##
#E
