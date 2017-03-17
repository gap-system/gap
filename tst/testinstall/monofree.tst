#############################################################################
##
#W  monofree.tst
##
gap> START_TEST("monofree.tst");
gap> M := FreeMonoid(0);
<free monoid on the generators [  ]>
gap> IsFreeMonoid(M); IsTrivial(M); IsWholeFamily(M);
true
true
true
gap> M2 := M / [];  
<fp monoid on the generators [  ]>
gap> F := FreeMonoid(2);
<free monoid on the generators [ m1, m2 ]>
gap> IsWholeFamily( F );
true
gap> IsFinite( F );
false
gap> Size( F );
infinity
gap> One(F);
<identity ...>
gap> gens := GeneratorsOfMonoid(F);
[ m1, m2 ]
gap> a := gens[1];; b := gens[2];;
gap> firstfifty:=[];;
gap> iter:= Iterator(F);;
gap> for i in [ 1 .. 50 ] do
>   Add( firstfifty, NextIterator( iter ) );
> od;
gap> Collected(List(firstfifty,Length));
[ [ 0, 1 ], [ 1, 2 ], [ 2, 4 ], [ 3, 8 ], [ 4, 16 ], [ 5, 19 ] ]
gap> IsDoneIterator( iter );
false
gap> enum:= Enumerator(F);;
gap> first50:=List( [ 1 .. 50 ], x -> enum[x] );;
gap> List( first50, x -> Position( enum, x ) ) = [ 1 .. 50 ];
true

#
gap> ForAll([0,1,2,3,infinity], n -> (n < infinity) = IsFinitelyGeneratedMonoid(FreeMonoid(n)));
true
gap> ForAll([0,1,2,3,infinity], n -> (n < 2) = IsCommutative(FreeMonoid(n)));
true

#
gap> STOP_TEST( "grpfree.tst", 1);

#############################################################################
##
#E
