#############################################################################
##
#W  grpfree.tst                GAP-4 library                    Thomas Breuer
##
##
#Y  Copyright 1997,    Lehrstuhl D für Mathematik,   RWTH Aachen,    Germany
##
gap> START_TEST("grpfree.tst");
gap> g:= FreeGroup( "a", "b" );
<free group on the generators [ a, b ]>
gap> IsWholeFamily( g );
true
gap> IsFinite( g );
false
gap> Size( g );
infinity
gap> Order( g.1 );
infinity
gap> Order( One(g) );
1
gap> gens:= GeneratorsOfGroup( g );
[ a, b ]
gap> a:= gens[1];; b:= gens[2];;
gap> firstfifty:=[];;
gap> iter:= Iterator( g );;
gap> for i in [ 1 .. 50 ] do
>   Add( firstfifty, NextIterator( iter ) );
> od;
gap> Collected(List(firstfifty,Length));
[ [ 0, 1 ], [ 1, 4 ], [ 2, 12 ], [ 3, 33 ] ]
gap> IsDoneIterator( iter );
false
gap> enum:= Enumerator( g );;
gap> first50:=List( [ 1 .. 50 ], x -> enum[x] );;
gap> Print(first50,"\n");
[ <identity ...>, a, a^-1, b, b^-1, a^2, a^-2, b*a, b^-1*a, a*b, a^-1*b, 
  b*a^-1, b^-1*a^-1, a*b^-1, a^-1*b^-1, b^2, b^-2, a^3, a^-3, b*a^2, 
  b^-1*a^2, a*b*a, a^-1*b*a, b*a^-2, b^-1*a^-2, a*b^-1*a, a^-1*b^-1*a, b^2*a, 
  b^-2*a, a^2*b, a^-2*b, b*a*b, b^-1*a*b, a*b*a^-1, a^-1*b*a^-1, b*a^-1*b, 
  b^-1*a^-1*b, a*b^-1*a^-1, a^-1*b^-1*a^-1, b^2*a^-1, b^-2*a^-1, a^2*b^-1, 
  a^-2*b^-1, b*a*b^-1, b^-1*a*b^-1, a*b^2, a^-1*b^2, b*a^-1*b^-1, 
  b^-1*a^-1*b^-1, a*b^-2 ]
gap> List( first50, x -> Position( enum, x ) ) = [ 1 .. 50 ];
true

#
gap> ForAll([0,1,2,3,infinity], n -> (n < infinity) = IsFinitelyGeneratedGroup(FreeGroup(n)));
true
gap> ForAll([0,1,2,3], n -> (n < 2) = IsFinitelyGeneratedGroup(DerivedSubgroup(FreeGroup(n))));
true
gap> ForAll([0,1,2,3,infinity], n -> (n < 2) = IsAbelian(FreeGroup(n)));
true
gap> ForAll([0,1,2,3,infinity], n -> (n < 2) = IsSolvableGroup(FreeGroup(n)));
true
gap> ForAll([0,1,2,3], n -> (n < 2) = IsAbelian(DerivedSubgroup(FreeGroup(n))));
true
gap> ForAll([0,1,2,3], n -> (n < 2) = IsSolvableGroup(DerivedSubgroup(FreeGroup(n))));
true

#
gap> F := FreeGroup(2);;
gap> G := F / [ [ F.1^2, F.2^2 ] ];
<fp group of size infinity on the generators [ f1, f2 ]>
gap> H := G / [ G.1 ];
<fp group on the generators [ f1, f2 ]>
gap> rho := SemigroupCongruenceByGeneratingPairs(F, [[F.1, F.2]]);;
gap> IsSemigroupCongruence(rho);
true
gap> Length(GeneratingPairsOfSemigroupCongruence(rho));
1
gap> G := F / rho;;
gap> IsQuotientSemigroup(G);
true
gap> H / rho;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `FactorSemigroup' on 2 arguments

#
gap> STOP_TEST( "grpfree.tst", 1);

#############################################################################
##
#E
