#@local F,M,M2,a,b,enum,first50,firstfifty,gens,iter,i
gap> START_TEST("monofree.tst");
gap> M := FreeMonoid(0);
<free monoid of rank zero>
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

# FreeMonoid
gap> FreeMonoid(fail);
Error, usage: FreeMonoid( [<wfilt>, ]<rank>[, <name>] )
              FreeMonoid( [<wfilt>, ][<name1>[, <name2>[, ...]]] )
              FreeMonoid( [<wfilt>, ]<names> )
              FreeMonoid( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeMonoid: rank 0
gap> FreeMonoid();
<free monoid of rank zero>
gap> FreeMonoid([]);
<free monoid of rank zero>
gap> FreeMonoid("");
<free monoid of rank zero>
gap> FreeMonoid(0);
<free monoid of rank zero>
gap> FreeMonoid(0, "name");
<free monoid of rank zero>

# FreeMonoid(infinity[, name[, init]])
gap> FreeMonoid(infinity);
<free monoid with infinity generators>
gap> FreeMonoid(infinity, fail);
Error, FreeMonoid( infinity, <name> ): <name> must be a string
gap> FreeMonoid(infinity, []);
<free monoid with infinity generators>
gap> FreeMonoid(infinity, "");
<free monoid with infinity generators>
gap> FreeMonoid(infinity, "nicename");
<free monoid with infinity generators>
gap> FreeMonoid(infinity, fail, fail);
Error, FreeMonoid( infinity, <name>, <init> ): <name> must be a string
gap> FreeMonoid(infinity, "nicename", fail);
Error, FreeMonoid( infinity, <name>, <init> ): <init> must be a finite list
gap> FreeMonoid(infinity, "gen", []);
<free monoid with infinity generators>
gap> FreeMonoid(infinity, "gen", [""]);
Error, FreeMonoid( infinity, <name>, <init> ): <init> must consist of nonempty\
 strings
gap> FreeMonoid(infinity, "gen", ["starter"]);
<free monoid with infinity generators>
gap> FreeMonoid(infinity, "gen", ["starter", ""]);
Error, FreeMonoid( infinity, <name>, <init> ): <init> must consist of nonempty\
 strings
gap> F := FreeMonoid(infinity, "gen", ["starter", "second", "third"]);
<free monoid with infinity generators>
gap> GeneratorsOfMonoid(F){[1 .. 4]};
[ starter, second, third, gen4 ]
gap> FreeMonoid(infinity, "gen", ["starter"], fail);
Error, usage: FreeMonoid( [<wfilt>, ]<rank>[, <name>] )
              FreeMonoid( [<wfilt>, ][<name1>[, <name2>[, ...]]] )
              FreeMonoid( [<wfilt>, ]<names> )
              FreeMonoid( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeMonoid(rank[, name])
gap> F := FreeMonoid(1);
<free monoid on the generators [ m1 ]>
gap> HasIsCommutative(F) and IsCommutative(F);
true
gap> F := FreeMonoid(2);
<free monoid on the generators [ m1, m2 ]>
gap> HasIsCommutative(F) and not IsCommutative(F);
true
gap> F := FreeMonoid(10);
<free monoid on the generators [ m1, m2, m3, m4, m5, m6, m7, m8, m9, m10 ]>
gap> F := FreeMonoid(3, fail);
Error, FreeMonoid( <rank>, <name> ): <name> must be a string
gap> F := FreeMonoid(4, "");
<free monoid on the generators [ 1, 2, 3, 4 ]>
gap> F := FreeMonoid(5, []);
<free monoid on the generators [ 1, 2, 3, 4, 5 ]>
gap> F := FreeMonoid(4, "cheese");
<free monoid on the generators [ cheese1, cheese2, cheese3, cheese4 ]>
gap> FreeMonoid(3, "car", fail);
Error, usage: FreeMonoid( [<wfilt>, ]<rank>[, <name>] )
              FreeMonoid( [<wfilt>, ][<name1>[, <name2>[, ...]]] )
              FreeMonoid( [<wfilt>, ]<names> )
              FreeMonoid( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeMonoid( <name1>, <name2>, ... )
gap> FreeMonoid("", "second");
Error, FreeMonoid( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeMonoid("first", "");
Error, FreeMonoid( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeMonoid("first", []);
Error, FreeMonoid( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeMonoid([], []);
Error, FreeMonoid( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeMonoid("bacon", "eggs", "beans");
<free monoid on the generators [ bacon, eggs, beans ]>
gap> FreeMonoid("shed");
<free monoid on the generators [ shed ]>

# FreeMonoid( [ <name1>, <name2>, ... ] )
gap> FreeMonoid(InfiniteListOfNames("a"));
Error, FreeMonoid( [<name1>, <name2>, ...] ): there must be only finitely many\
 names
gap> FreeMonoid(["", "second"]);
Error, FreeMonoid( [<name1>, <name2>, ...] ): the names must be nonempty strin\
gs
gap> FreeMonoid(["first", ""]);
Error, FreeMonoid( [<name1>, <name2>, ...] ): the names must be nonempty strin\
gs
gap> FreeMonoid(["first", []]);
Error, FreeMonoid( [<name1>, <name2>, ...] ): the names must be nonempty strin\
gs
gap> FreeMonoid([[], []]);
Error, FreeMonoid( [<name1>, <name2>, ...] ): the names must be nonempty strin\
gs
gap> FreeMonoid(["bacon", "eggs", "beans"]);
<free monoid on the generators [ bacon, eggs, beans ]>
gap> FreeMonoid(["grid"]);
<free monoid on the generators [ grid ]>
gap> FreeMonoid(["grid"], fail);
Error, usage: FreeMonoid( [<wfilt>, ]<rank>[, <name>] )
              FreeMonoid( [<wfilt>, ][<name1>[, <name2>[, ...]]] )
              FreeMonoid( [<wfilt>, ]<names> )
              FreeMonoid( [<wfilt>, ]infinity[, <name>][, <init>] )

#
gap> STOP_TEST( "grpfree.tst", 1);
