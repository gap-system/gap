#@local cond, subs, ct, irrB, ctm23, proj, max, ctu, d, pimsmax
#@local projectives, smallpro, basm, sb, 7sets, basicsets, A, c2, c3, V
#@local comps, ibr, V100, compsV100, ct1, psi, psiG, Psis, W, compsW, cand
#@local x, a, t, preg, perm, permbrau, f, odds, thetas, s, G, trans, g, H
#@local mats, m
######################################################################
gap> START_TEST( "example_4.5.5.tst" );

## This is code from Exercise 1.6.4.
gap> cond := function( H, n , g, q )
>  local condmat, orbs;
>  orbs := Orbits( H , [1..n] );
>  condmat := List( orbs, Oi -> List( orbs, Oj -> 1/(Size(Oi)*Z(q)^0) *
>                  Size( Intersection( List(Oi, x -> x^g), Oj) ) ) );
>  return condmat;
> end;;

## This is code from Exercise 4.5.3.
gap> subs := function( ct, basm, vec, irrB, p )
> local nullv, x, y, v, cands, psing, preg, rest, relations;
> cands := [];
> psing := Filtered( [1..Length(Irr(ct))],
>                   i->IsInt( OrdersClassRepresentatives(ct)[i]/p ) );
> preg := Difference( [1..Length(Irr(ct))], psing );
> nullv := List( [1..Length(psing)], x -> 0 );
> rest := Difference( irrB, basm );
> relations := List( rest, i -> SolutionMat( Irr(ct){basm}{preg},
>                   Irr(ct)[i]{preg} ) );;
> for x in Cartesian ( List( vec{List(basm, i -> Position(irrB,i) )} ,
>                               c -> [0..c] ) ) do
>   v:= [] ; v{List( basm, i -> Position(irrB,i) )} := x;
>   v{List( rest, i -> Position(irrB,i) )} := List([1..Length(rest)],
>                                                     i-> x*relations[i]);
>   y := v * Irr(ct){irrB};;
>   if ForAll( v, c -> c >= 0 ) and  y{psing} = nullv
>          and ForAll( [1..Length(v)] , i -> v[i] <= vec[i] ) and Sum(v) > 0
>          then Add( cands, v );
>   fi;
> od;
> return(cands);
> end;;

######################################################################
gap> ct := CharacterTable( "M22" );; irrB := [1..Length(Irr(ct))];;
gap> ctm23 := CharacterTable( "M23" );;
gap> proj := RestrictedClassFunctions( Irr(ctm23){[12,13]}, ct );;
gap> for max in Maxes(ct) do
>   ctu := CharacterTable( max ); d := DecompositionMatrix( ctu mod 2 );;
>   pimsmax := TransposedMat(d) * Irr(ctu);;
>   Append( proj, InducedClassFunctions( pimsmax, ct ) );
> od;
gap> projectives := Set( Tensored(Irr(ct), proj) );;
gap> SortParallel( List(projectives, Norm), projectives );
gap> smallpro := projectives{[1..10]};;
gap> basm := [ 1, 2, 3, 5, 6, 9, 10 ];; sb := Irr(ct){basm};;
gap> 7sets := Filtered( Combinations(smallpro), x -> Length(x) = 7  );;
gap> basicsets := Filtered( 7sets , x ->
>               Determinant( MatScalarProducts(ct,sb,x) ) in [-1,1] );;
gap> SortParallel( List( basicsets, s -> Sum(List(s,Norm)) ), basicsets );
gap> A := MatScalarProducts( ct, Irr(ct), basicsets[1] );;
gap> Sort(A); A := Reversed(A);; Display(A);
[ [  1,  1,  1,  1,  1,  1,  2,  4,  5,  5,  5,  7 ],
  [  0,  1,  1,  0,  1,  1,  2,  3,  1,  3,  3,  3 ],
  [  0,  1,  0,  1,  1,  1,  2,  3,  1,  3,  3,  3 ],
  [  0,  0,  1,  1,  1,  2,  3,  4,  4,  5,  5,  7 ],
  [  0,  0,  0,  0,  0,  1,  1,  1,  0,  1,  1,  1 ],
  [  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  0,  1 ],
  [  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  1,  1 ] ]
gap> List( A, y -> Length( subs(ct, basm, y, [1..Length(Irr(ct))],2) ) );
[ 391, 19, 19, 121, 1, 1, 1 ]

######################################################################
gap> c2 := Filtered( subs(ct,basm,A[2],irrB,2), y -> y[2]=1 );;
gap> c3 := Filtered( subs(ct,basm,A[3],irrB,2), y -> y[2]=1 );;
gap> Set( List( c2, x -> x{[1..5]}) );  Set( List( c3, x -> x{[1..5]}) );
[ [ 0, 1, 1, 0, 1 ] ]
[ [ 0, 1, 0, 1, 1 ] ]

######################################################################
gap> V := PermutationGModule( MathieuGroup(22), GF(4) );;
gap> comps := Set( MTX.CompositionFactors(V) );;
gap> ibr := List( comps, W -> W.dimension );
[ 1, 1, 10, 10 ]
gap> V100 :=  TensorProductGModule( comps[3] , comps[4] );;
gap> compsV100 :=  Set( MTX.CompositionFactors(V100) );;
gap> List( compsV100, W -> W.dimension );
[ 1, 98, 1 ]

######################################################################
gap> A{[2,3,4]} := [A[2]-A[5], A[3]-A[5], A[4] - 2*A[5]];; Display(A);
[ [  1,  1,  1,  1,  1,  1,  2,  4,  5,  5,  5,  7 ],
  [  0,  1,  1,  0,  1,  0,  1,  2,  1,  2,  2,  2 ],
  [  0,  1,  0,  1,  1,  0,  1,  2,  1,  2,  2,  2 ],
  [  0,  0,  1,  1,  1,  0,  1,  2,  4,  3,  3,  5 ],
  [  0,  0,  0,  0,  0,  1,  1,  1,  0,  1,  1,  1 ],
  [  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  0,  1 ],
  [  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  1,  1 ] ]

######################################################################
gap> ct1 := CharacterTable(Maxes(ct)[1]);;
gap> psi :=  InducedClassFunction( Irr(ct1 mod 2)[2], ct1 );;
gap> psiG := InducedClassFunction( psi, ct );;  Psis := A * Irr(ct);;
gap> MatScalarProducts(ct , Psis, [psiG] );
[ [ 4, 0, 0, 3, 0, 1, 1 ] ]

######################################################################
gap> W := TensorProductGModule( comps[3], compsV100[3] );;
gap> compsW := Set( MTX.CompositionFactors(W) );;
gap> ForAll( compsW , U -> MTX.IsAbsolutelyIrreducible(U) );
true
gap> Set( List( compsW , U -> U.dimension) );
[ 10 ]

######################################################################
gap> cand:= [];;
gap> for x in Cartesian([0,1,2], [0,1]) do
>      a := ShallowCopy(A);
>      a[1] := a[1] - x[1]*(a[6]+a[7]);  a[4] := a[4] - x[2]*(a[6]+a[7]);
>      Add(cand, a);
>    od;

######################################################################
gap> t := TableOfMarks( "M22" );;
gap> preg := Filtered( [1..Length(Irr(ct))],
>              i -> not IsInt( OrdersClassRepresentatives(ct)[i]/2 ) );;
gap> perm := PermCharsTom(ct,t);; permbrau := List(perm, y -> y{preg});;
gap> for A in cand do
>      ibr := TransposedMat( A{[1..7]}{basm} )^-1 * sb;;
>      ibr := List( ibr, y -> y{preg} );
>      x := List( permbrau, y -> SolutionMat( ibr, y ) );;
>      f := Filtered([1..Length(x)], i -> x[i][6] <>0 and x[i][7] <> 0);;
>      Print( f[Length(f)]," , ", x[f[Length(f)]], "\n" );
>    od;
149 , [ 10, 4, 4, 6, 1, 1, 1 ]
149 , [ 10, 4, 4, 4, 1, 1, 1 ]
149 , [ 8, 4, 4, 6, 1, 1, 1 ]
149 , [ 8, 4, 4, 4, 1, 1, 1 ]
149 , [ 6, 4, 4, 6, 1, 1, 1 ]
149 , [ 6, 4, 4, 4, 1, 1, 1 ]

######################################################################
gap> odds := Filtered([1..Length(perm)], i-> OrdersTom(t)[i] mod 2 <> 0);
[ 1, 3, 10, 13, 26, 28, 57, 94 ]
gap> thetas := perm{odds};;
gap> Filtered( [1..Length(odds)], i ->  ForAll(cand ,
>                  A -> SolutionMat(A *Irr(ct), thetas[i])[4] <> 0) );
[ 1, 2, 3, 4, 5, 6 ]
gap> Display( List( cand, A -> SolutionMat(A *Irr(ct), thetas[6]) ) );
[ [  1,  0,  0,  4,  8,  0,  0 ],
  [  1,  0,  0,  4,  8,  4,  4 ],
  [  1,  0,  0,  4,  8,  1,  1 ],
  [  1,  0,  0,  4,  8,  5,  5 ],
  [  1,  0,  0,  4,  8,  2,  2 ],
  [  1,  0,  0,  4,  8,  6,  6 ] ]

######################################################################
gap> s := RepresentativeTom( t, 149 );;
gap> G := UnderlyingGroup( t );;
gap> trans := RightTransversal( G, s );;
gap> g := Action( G, trans, OnRight );;

######################################################################
gap> H := RepresentativeTomByGenerators( t, 28, GeneratorsOfGroup(g) );;
gap> mats:= List( [g.1, g.2, g.1*g.2, g.1*g.2^2*g.1*g.2, g.2^2*g.1*g.2^2],
>                       g -> TransposedMat( cond( H, 462, g, 2 ) ) );;
gap> m := GModuleByMats( mats, GF(4) );;
gap> List( MTX.CollectedFactors( m ), x -> [x[1].dimension, x[2]] );
[ [ 1, 8 ], [ 4, 4 ], [ 5, 1 ], [ 5, 1 ], [ 8, 1 ] ]

######################################################################
gap> STOP_TEST( "example_4.5.5.tst" );
