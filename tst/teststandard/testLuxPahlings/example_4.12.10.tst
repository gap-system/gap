#@local syl, degblock, s, m, degs, d, dd, t, ind, ll, red, ct, perm
#@local b19, gg, t11, pf, ind1, ind2
######################################################################
gap> START_TEST( "example_4.12.10.tst" );

## This is code from Exercise 2.10.1.
gap> syl := function(n,p)
>  local divs, lpd, S;
>  divs := Factors(n); lpd := divs[Length(divs)]; divs := Combinations(divs);
>  Add(divs[1],1); divs := List( divs, Product );
>  S := Filtered( divs, x-> x mod p = 1 and x > lpd );
>  S := Filtered( S, x -> Gcd( n/x, p-1 ) <> 1 );
>  return( S );
> end;;

## This is code from Exercise 4.12.2.
gap> degblock := function( n, degne, dege, e, p )
>  local dd, d1, d2, de, tup, x;
>  dd:= []; d1:= ShallowCopy( degne ); d2 := ShallowCopy( dege );
>  for x in [2..Length(d1)] do
>    if d1[x] mod p <> d1[1] mod p then d1[x]:=-d1[x]; fi;
>  od;
>  for x in [2..Length(d2)] do
>    if d2[x] mod p <> e  then d2[x]:= -d2[x]; fi;
>  od;
>  tup := UnorderedTuples(d1, e);;
>  for x in tup do
>    if Sum(x) in d2 then Add( dd , [x, Sum(x)] ); fi;
>  od;
>  for x in dd do Sort( x[1] ); od; dd:=Set(dd); Sort(dd);
>  dd:=Filtered(dd, x -> Sum(List(x[1], a -> a^2)) + ((p-1)/e)*x[2]^2 < n);
>  dd:=Filtered(dd, x -> Length(Positions(x,1)) = 1);
>  return(dd);
> end;;

######################################################################
gap> Filtered( syl( 175560, 5 ), x-> x mod 19 <> 0 and x mod 7 = 0 );
[ 21, 231 ]

######################################################################
gap> s := Filtered( syl(175560, 3), x-> x mod 19 <> 0 and x mod 5 = 0 );;
gap> for m in s do Print("19 * ",175560/(m*19)," ,   "); od; Print( "\n" );
19 * 6 ,   19 * 42 ,   19 * 132 ,   19 * 24 ,   19 * 168 ,   

######################################################################
gap> degs := Filtered( [1..419], x ->  IsInt(175560/x) and x <>2 );;
gap> List([1,2] , i -> Filtered( degs, x -> x mod 19 in [i,19-i] ));
[ [ 1, 20, 56, 77, 132, 210 ], [ 21, 40, 55, 154, 264 ] ]

######################################################################
gap> d := List([1,3], i -> Filtered( degs, x -> x mod 19 in [i,19-i] ));;
gap> d[2]:= Filtered(d[2], x->6*x^2 < 175560 and x mod 7 in [0,2,5]);; d;
[ [ 1, 20, 56, 77, 132, 210 ], [ 35, 168 ] ]
gap> dd := degblock( 175560, d[1], d[2], 3, 19 );
[  ]

######################################################################
gap> List(Filtered( syl(175560,5), x -> x mod (7*19) = 0 ), x-> 175560/x);
[ 10, 110, 60, 660 ]

######################################################################
gap> degs := Filtered( degs, x-> x mod 19 in [0,1,6,13,18] and x <> 20);;
gap> d := List( [1,2,3], i-> Filtered(degs, x -> x mod 7 in [i,7-i]) );
[ [ 1, 6, 57, 76, 120, 132, 190, 209 ], [ 19, 44, 114, 152, 285, 380, 418 ], 
  [ 38, 95, 165, 228 ] ]
gap> Print(degblock(175560,d[1],d[2],2,7),degblock(175560,d[1],d[3],3,7), "\n");
[  ][  ]

######################################################################
gap> degs := Filtered(degs, x -> x mod 7 in [0,1,6]);;
gap> d := List( [1,6] ,  i-> Filtered(degs, x -> x mod 19 in [i,19-i]) );
[ [ 1, 56, 77, 132, 210 ], [ 6, 70, 120 ] ]
gap> degblock( 175560, d[1], d[2], 6, 19 );
[  ]

######################################################################
gap> Filtered( degs, x-> x mod 19 = 0 and x mod 11 in [1,10] );
[ 76, 133 ]

######################################################################
gap> List( [3,5], p -> Filtered( List( syl(175560, p), x -> 175560/x ), 
>                      y -> IsInt( 120/y ) ) );
[ [ 6, 60, 24 ], [ 10, 60 ] ]

######################################################################
gap> t := CharacterTable("J1");;
gap> ind := InducedCyclic( t, "all" );; ll := LLL( t, ind );;
gap> List( ll.irreducibles, y -> y[1] );
[ 56, 56, 120, 120, 120, 76, 76 ]
gap> red := ReducedClassFunctions( t, [List([1..15],x->1)],ll.remainders);;
gap> List( red.irreducibles, y -> y[1] );
[ 77, 77, 77, 133, 133, 133, 209 ]

######################################################################
gap> ct := CharacterTable("J1");; perm := PermChars(ct, 7*11*19);;
gap> b19 := Filtered([1..15], i -> Irr(ct)[i][15] <> 0);;
gap> MatScalarProducts( Irr(ct){b19}, perm );
[ [ 1, 1, 1, 2, 0, 0, 1, 1, 1 ] ]

######################################################################
gap> gg := AllSmallGroups(110);;
gap> gg := Filtered(gg,g-> Size(Centralizer(g,SylowSubgroup(g,11)))=11);;
gap> t11 := CharacterTable(gg[1]);; pf:=PossibleClassFusions(t11,ct);
[ [ 1, 2, 4, 10, 8, 5, 9, 5, 9, 4, 8 ], [ 1, 2, 5, 10, 9, 4, 8, 4, 8, 5, 9 ] ]
gap> ind1 := InducedClassFunctionsByFusionMap(t11, ct, Irr(t11), pf[1]);;
gap> ind2 := InducedClassFunctionsByFusionMap(t11, ct, Irr(t11), pf[2]);;
gap> Set(ind1) = Set(ind2);
true
gap> MatScalarProducts(Irr(ct){b19},ind1{[1..8]});
[ [ 1, 1, 1, 2, 0, 0, 1, 1, 1 ], [ 0, 1, 1, 1, 1, 1, 1, 1, 1 ], 
  [ 0, 0, 1, 0, 1, 1, 1, 1, 1 ], [ 0, 1, 0, 0, 1, 1, 1, 1, 1 ], 
  [ 0, 1, 0, 0, 1, 1, 1, 1, 1 ], [ 0, 0, 1, 0, 1, 1, 1, 1, 1 ], 
  [ 0, 0, 1, 1, 1, 0, 1, 1, 1 ], [ 0, 1, 0, 1, 0, 1, 1, 1, 1 ] ]

######################################################################
gap> STOP_TEST( "example_4.12.10.tst" );
