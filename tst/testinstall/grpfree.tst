#@local a,b,enum,F,H,first50,firstfifty,g,gens,iter,rho,i,G
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

# FreeGroup
gap> FreeGroup(fail);
Error, usage: FreeGroup( [<wfilt>, ]<rank>[, <name>] )
              FreeGroup( [<wfilt>, ][<name1>[, <name2>[, ...]]] )
              FreeGroup( [<wfilt>, ]<names> )
              FreeGroup( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeGroup: rank 0
gap> FreeGroup();
<free group of rank zero>
gap> FreeGroup([]);
<free group of rank zero>
gap> FreeGroup("");
<free group of rank zero>
gap> FreeGroup(0);
<free group of rank zero>
gap> FreeGroup(0, "name");
<free group of rank zero>

# FreeGroup(infinity[, name[, init]])
gap> FreeGroup(infinity);
<free group with infinity generators>
gap> FreeGroup(infinity, fail);
Error, FreeGroup( infinity, <name> ): <name> must be a string
gap> FreeGroup(infinity, []);
<free group with infinity generators>
gap> FreeGroup(infinity, "");
<free group with infinity generators>
gap> FreeGroup(infinity, "nicename");
<free group with infinity generators>
gap> FreeGroup(infinity, fail, fail);
Error, FreeGroup( infinity, <name>, <init> ): <name> must be a string
gap> FreeGroup(infinity, "nicename", fail);
Error, FreeGroup( infinity, <name>, <init> ): <init> must be a finite list
gap> FreeGroup(infinity, "gen", []);
<free group with infinity generators>
gap> FreeGroup(infinity, "gen", [""]);
Error, FreeGroup( infinity, <name>, <init> ): <init> must consist of nonempty \
strings
gap> FreeGroup(infinity, "gen", ["starter"]);
<free group with infinity generators>
gap> FreeGroup(infinity, "gen", ["starter", ""]);
Error, FreeGroup( infinity, <name>, <init> ): <init> must consist of nonempty \
strings
gap> F := FreeGroup(infinity, "gen", ["starter", "second", "third"]);
<free group with infinity generators>
gap> GeneratorsOfGroup(F){[1 .. 4]};
[ starter, second, third, gen4 ]
gap> FreeGroup(infinity, "gen", ["starter"], fail);
Error, usage: FreeGroup( [<wfilt>, ]<rank>[, <name>] )
              FreeGroup( [<wfilt>, ][<name1>[, <name2>[, ...]]] )
              FreeGroup( [<wfilt>, ]<names> )
              FreeGroup( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeGroup(rank[, name])
gap> F := FreeGroup(1);
<free group on the generators [ f1 ]>
gap> HasIsCommutative(F) and IsCommutative(F);
true
gap> F := FreeGroup(2);
<free group on the generators [ f1, f2 ]>
gap> HasIsCommutative(F) and not IsCommutative(F);
true
gap> F := FreeGroup(10);
<free group on the generators [ f1, f2, f3, f4, f5, f6, f7, f8, f9, f10 ]>
gap> F := FreeGroup(3, fail);
Error, FreeGroup( <rank>, <name> ): <name> must be a string
gap> F := FreeGroup(4, "");
<free group on the generators [ 1, 2, 3, 4 ]>
gap> F := FreeGroup(5, []);
<free group on the generators [ 1, 2, 3, 4, 5 ]>
gap> F := FreeGroup(4, "cheese");
<free group on the generators [ cheese1, cheese2, cheese3, cheese4 ]>
gap> FreeGroup(3, "car", fail);
Error, usage: FreeGroup( [<wfilt>, ]<rank>[, <name>] )
              FreeGroup( [<wfilt>, ][<name1>[, <name2>[, ...]]] )
              FreeGroup( [<wfilt>, ]<names> )
              FreeGroup( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeGroup( <name1>, <name2>, ... )
gap> FreeGroup("", "second");
Error, FreeGroup( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeGroup("first", "");
Error, FreeGroup( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeGroup("first", []);
Error, FreeGroup( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeGroup([], []);
Error, FreeGroup( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeGroup("bacon", "eggs", "beans");
<free group on the generators [ bacon, eggs, beans ]>
gap> FreeGroup("shed");
<free group on the generators [ shed ]>

# FreeGroup( [ <name1>, <name2>, ... ] )
gap> FreeGroup(InfiniteListOfNames("a"));
Error, FreeGroup( [<name1>, <name2>, ...] ): there must be only finitely many \
names
gap> FreeGroup(["", "second"]);
Error, FreeGroup( [<name1>, <name2>, ...] ): the names must be nonempty string\
s
gap> FreeGroup(["first", ""]);
Error, FreeGroup( [<name1>, <name2>, ...] ): the names must be nonempty string\
s
gap> FreeGroup(["first", []]);
Error, FreeGroup( [<name1>, <name2>, ...] ): the names must be nonempty string\
s
gap> FreeGroup([[], []]);
Error, FreeGroup( [<name1>, <name2>, ...] ): the names must be nonempty string\
s
gap> FreeGroup(["bacon", "eggs", "beans"]);
<free group on the generators [ bacon, eggs, beans ]>
gap> FreeGroup(["grid"]);
<free group on the generators [ grid ]>
gap> FreeGroup(["grid"], fail);
Error, usage: FreeGroup( [<wfilt>, ]<rank>[, <name>] )
              FreeGroup( [<wfilt>, ][<name1>[, <name2>[, ...]]] )
              FreeGroup( [<wfilt>, ]<names> )
              FreeGroup( [<wfilt>, ]infinity[, <name>][, <init>] )

# wfilt
gap> F := FreeGroup(4 : FreeGroupFamilyType := "syllable");
<free group on the generators [ f1, f2, f3, f4 ]>
gap> "IsSyllableWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> F := FreeGroup(4 : FreeGroupFamilyType := "something else");;
gap> "IsSyllableWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
false
gap> F := FreeGroup(IsSyllableWordsFamily, 6);;
gap> "IsSyllableWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> F := FreeGroup(IsSyllableWordsFamily, 136);;
gap> "IsSyllableWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> FreeGroup(IsGroup, 3);
Error, the optional first argument <wfilt> must be one of IsSyllableWordsFamil\
y, IsLetterWordsFamily, IsWLetterWordsFamily, and IsBLetterWordsFamily
gap> F := FreeGroup(IsLetterWordsFamily, 200);
<free group with 200 generators>
gap> "IsLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsWLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsBLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
false
gap> F := FreeGroup(IsLetterWordsFamily, 100);
<free group with 100 generators>
gap> "IsLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsWLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
false
gap> "IsBLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> F := FreeGroup(IsBLetterWordsFamily, 200);
<free group with 200 generators>
gap> "IsLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsWLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsBLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
false
gap> F := FreeGroup(IsBLetterWordsFamily, 100);
<free group with 100 generators>
gap> "IsLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsWLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
false
gap> "IsBLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> F := FreeGroup(IsWLetterWordsFamily, 200);
<free group with 200 generators>
gap> "IsLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsWLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsBLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
false
gap> F := FreeGroup(IsWLetterWordsFamily, 100);
<free group with 100 generators>
gap> "IsLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsWLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
true
gap> "IsBLetterWordsFamily" in CategoriesOfObject(FamilyObj(F.1));
false

#
gap> F := FreeGroup(2);;
gap> Group(F.1 ^ 100);
Group(<1 generator>)

#
gap> STOP_TEST( "grpfree.tst", 1);
