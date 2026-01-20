# Fix #6200 IsomorphismSimpleGroups
#@local F, G, hom, gens, gens8, i, H, gens4, gens5, K, res;
gap> START_TEST("IsomorphismSimpleGroups.tst");

# 
gap> F:= GF(2);;
gap> G:= GL(9, F);;
gap> hom:= IsomorphismPermGroup( G );;
gap> gens:= List( [ 1 .. 3 ], i -> IdentityMat( 9, F ) );;
gap> gens8:= GeneratorsOfGroup( SO(1, 8, 2) );;
gap> for i in [ 1 .. 3 ] do
>   gens[i]{ [ 1 .. 8 ] }{ [ 1 .. 8 ] }:= gens8[i];
> od;
gap> H:= Group( gens );;
gap> gens:= List( [ 1 .. 5 ], i -> IdentityMat( 9, F ) );;
gap> gens4:= GeneratorsOfGroup( GL(4, F) );;
gap> gens5:= GeneratorsOfGroup( GL(5, F) );;
gap> for i in [ 1, 2 ] do
>   gens[i]{ [ 1 .. 4 ] }{ [ 1 .. 4 ] }:= gens4[i];
>   gens[i+2]{ [ 5 .. 9 ] }{ [ 5 .. 9 ] }:= gens5[i];
> od;
gap> gens[5][5][1]:= One(F);;
gap> K:= Group( gens );;
gap> G:= Image( hom, G );;
gap> H:= Image( hom, H );;
gap> K:= Image( hom, K );;
gap> res:= DoubleCosetRepsAndSizes( G, H, K : cheap:= true );;
gap> Length( res );
28

# 
gap> STOP_TEST("IsomorphismSimpleGroups.tst");
