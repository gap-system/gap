#@local isinspan, subs, ct, bl, irrB, basm, rest, sb, def0, proj
#@local max, ctu, d, pimsmax, tens, otherblocks, projectives, smallpro
#@local 5sets, basicsets, A, li, sp, A1, ss, c1, cand, x1, a, x2, y2
#@local x3, y3, x4, y4, x5, u, u1, m, mat
gap> START_TEST( "example_4.5.4.tst" );

## This is code from Exercise 4.5.1.
gap> isinspan := function( v , lv )
> return( v in List (Cartesian(List(lv, x-> [0..Maximum(v)])),x -> x*lv) );
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
gap> ct := CharacterTable( "J1" );; bl := PrimeBlocks( ct, 2 );;
gap> irrB := Positions( bl.block, 1 );
[ 1, 6, 7, 8, 12, 13, 14, 15 ]

######################################################################
gap> basm:=[1,6,7,8,12];;rest := Difference([1..Length(Irr(ct))],basm);;
gap> sb := Irr(ct){basm};;
gap> def0 := List( Positions(bl.defect,0), i -> Position(bl.block,i) );
[ 2, 3, 9, 10, 11 ]
gap> proj := Irr(ct){ def0 };; Add( proj , Sum( Irr(ct){[4,5]} ) );

######################################################################
gap> Maxes(ct);
[ "L2(11)", "2^3.7.3", "2xA5", "19:6", "11:10", "D6xD10", "7:6" ]
gap> for max in Maxes(ct) do
> ctu := CharacterTable( max) ; d := DecompositionMatrix(ctu mod 2);;
> pimsmax := TransposedMat(d)*Irr(ctu);;
> Append( proj, InducedClassFunctions( pimsmax, ct ) );
> od;
gap> proj := Set(proj);; Length(proj);
30

######################################################################
gap> tens := Tensored( Irr(ct), proj );;
gap> otherblocks := Difference( [1..Length(Irr(ct))] , irrB );
[ 2, 3, 4, 5, 9, 10, 11 ]
gap> projectives := Reduced( ct,Irr(ct){otherblocks}, tens ).remainders;;
gap> Length( projectives );
198

######################################################################
gap> SortParallel( List(projectives, Norm), projectives );
gap> smallpro := projectives{[1..9]};;
gap> 5sets := Filtered( Combinations(smallpro), x -> Length(x) = 5 );;
gap> basicsets := Filtered( 5sets , x ->
>                   Determinant(MatScalarProducts(ct,sb,x)) in [-1,1] );;
gap> Length( basicsets );
17

######################################################################
gap> SortParallel( List( basicsets,s -> Sum(List(s,Norm)) ), basicsets );
gap>  A := MatScalarProducts( ct, Irr(ct){irrB}, basicsets[1] );;

######################################################################
gap> li := [];;
gap> for sp in basicsets do
>       A1 := MatScalarProducts( ct, Irr(ct){irrB}, sp );
>       A1 := Filtered( A1 , x -> x[1] > 0);
>       ss := Intersection( List(A1 , y ->  subs(ct,basm,y,irrB,2)) );;
>       ss := Filtered( ss, y -> y[1] = 1 );  Add( li, ss );
>     od;
gap>  c1 := Intersection(li);
[ [ 1, 0, 0, 0, 1, 1, 1, 0 ], [ 1, 0, 0, 1, 1, 1, 0, 0 ], 
  [ 1, 0, 1, 0, 1, 0, 1, 0 ], [ 1, 0, 1, 1, 1, 0, 0, 0 ], 
  [ 1, 1, 0, 0, 0, 1, 1, 0 ], [ 1, 1, 0, 1, 0, 1, 0, 0 ], 
  [ 1, 1, 1, 0, 0, 0, 1, 0 ], [ 1, 1, 1, 1, 0, 0, 0, 0 ], 
  [ 1, 1, 1, 1, 1, 1, 1, 1 ] ]

######################################################################
gap> cand := [];;
gap> for x1 in c1 do
>    a := ShallowCopy(A);   a{[1,2,3]}:= [ a[1]-x1, a[2]-x1, a[3]-x1 ];
>    for x2 in Filtered( subs(ct,basm,a[1],irrB,2), x -> x[2] > 0 ) do
>      y2 := First( a, x -> not isinspan( x, [x2]) );
>      for x3 in subs( ct,basm,y2,irrB,2 ) do
>        y3 := First( a ,  x -> not isinspan( x, [x2,x3] ) );
>        for x4 in subs( ct,basm,y3,irrB,2 ) do
>          y4 := First( a ,  x -> not isinspan(x, [x2,x3,x4]) );
>          for x5 in subs( ct,basm,y4,irrB,2 ) do
>            u := [ x1, x2, x3, x4, x5 ]; u1 := TransposedMat(u){[1..5]};
>            if Rank(u) = 5 and Determinant(u1) in [1,-1] then
>              m := MatScalarProducts( ct, u1^-1 * sb, smallpro );
>              if ForAll( m, y -> ForAll(y, x-> x >=0 and IsInt(x) ))
>                  then Add( cand, u );
>              fi;
>            fi;
>          od;
>        od;
>      od;
>    od;
>  od;
gap> for mat in cand do Sort(mat); od;
gap> cand:= Set( cand );; cand := List(cand, Reversed);; Length( cand );
5

######################################################################
gap> STOP_TEST( "example_4.5.4.tst" );
