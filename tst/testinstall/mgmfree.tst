#@local M
gap> START_TEST("mgmfree.tst");

# FreeMagma
gap> FreeMagma(fail);
Error, usage: FreeMagma( <rank>[, <name>] )
              FreeMagma( <name1>[, <name2>[, ...]] )
              FreeMagma( <names> )
              FreeMagma( infinity[, <name>][, <init>] )

# FreeMagma: rank 0
gap> FreeMagma();
#I  FreeMagma cannot make an object with no generators
Error, usage: FreeMagma( <rank>[, <name>] )
              FreeMagma( <name1>[, <name2>[, ...]] )
              FreeMagma( <names> )
              FreeMagma( infinity[, <name>][, <init>] )
gap> FreeMagma([]);
#I  FreeMagma cannot make an object with no generators
Error, usage: FreeMagma( <rank>[, <name>] )
              FreeMagma( <name1>[, <name2>[, ...]] )
              FreeMagma( <names> )
              FreeMagma( infinity[, <name>][, <init>] )
gap> FreeMagma("");
#I  FreeMagma cannot make an object with no generators
Error, usage: FreeMagma( <rank>[, <name>] )
              FreeMagma( <name1>[, <name2>[, ...]] )
              FreeMagma( <names> )
              FreeMagma( infinity[, <name>][, <init>] )
gap> FreeMagma(0);
#I  FreeMagma cannot make an object with no generators
Error, usage: FreeMagma( <rank>[, <name>] )
              FreeMagma( <name1>[, <name2>[, ...]] )
              FreeMagma( <names> )
              FreeMagma( infinity[, <name>][, <init>] )
gap> FreeMagma(0, "name");
#I  FreeMagma cannot make an object with no generators
Error, usage: FreeMagma( <rank>[, <name>] )
              FreeMagma( <name1>[, <name2>[, ...]] )
              FreeMagma( <names> )
              FreeMagma( infinity[, <name>][, <init>] )

# FreeMagma(infinity[, name[, init]])
gap> FreeMagma(infinity);
<free magma with infinity generators>
gap> FreeMagma(infinity, fail);
Error, FreeMagma( infinity, <name> ): <name> must be a string
gap> FreeMagma(infinity, []);
<free magma with infinity generators>
gap> FreeMagma(infinity, "");
<free magma with infinity generators>
gap> FreeMagma(infinity, "nicename");
<free magma with infinity generators>
gap> FreeMagma(infinity, fail, fail);
Error, FreeMagma( infinity, <name>, <init> ): <name> must be a string
gap> FreeMagma(infinity, "nicename", fail);
Error, FreeMagma( infinity, <name>, <init> ): <init> must be a finite list
gap> FreeMagma(infinity, "gen", []);
<free magma with infinity generators>
gap> FreeMagma(infinity, "gen", [""]);
Error, FreeMagma( infinity, <name>, <init> ): <init> must consist of nonempty \
strings
gap> FreeMagma(infinity, "gen", ["starter"]);
<free magma with infinity generators>
gap> FreeMagma(infinity, "gen", ["starter", ""]);
Error, FreeMagma( infinity, <name>, <init> ): <init> must consist of nonempty \
strings
gap> M := FreeMagma(infinity, "gen", ["starter", "second", "third"]);
<free magma with infinity generators>
gap> GeneratorsOfMagma(M){[1 .. 4]};
[ starter, second, third, gen4 ]
gap> FreeMagma(infinity, "gen", ["starter"], fail);
Error, usage: FreeMagma( <rank>[, <name>] )
              FreeMagma( <name1>[, <name2>[, ...]] )
              FreeMagma( <names> )
              FreeMagma( infinity[, <name>][, <init>] )

# FreeMagma(rank[, name])
gap> M := FreeMagma(1);
<free magma on the generators [ x1 ]>
gap> HasIsTrivial(M) and not IsTrivial(M);
true
gap> M := FreeMagma(2);
<free magma on the generators [ x1, x2 ]>
gap> HasIsTrivial(M) and not IsTrivial(M);
true
gap> M := FreeMagma(10);
<free magma on the generators [ x1, x2, x3, x4, x5, x6, x7, x8, x9, x10 ]>
gap> M := FreeMagma(3, fail);
Error, FreeMagma( <rank>, <name> ): <name> must be a string
gap> M := FreeMagma(4, "");
<free magma on the generators [ 1, 2, 3, 4 ]>
gap> M := FreeMagma(5, []);
<free magma on the generators [ 1, 2, 3, 4, 5 ]>
gap> M := FreeMagma(4, "cheese");
<free magma on the generators [ cheese1, cheese2, cheese3, cheese4 ]>
gap> FreeMagma(3, "car", fail);
Error, usage: FreeMagma( <rank>[, <name>] )
              FreeMagma( <name1>[, <name2>[, ...]] )
              FreeMagma( <names> )
              FreeMagma( infinity[, <name>][, <init>] )

# FreeMagma( <name1>[, <name2>, ...] )
gap> FreeMagma("", "second");
Error, FreeMagma( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeMagma("first", "");
Error, FreeMagma( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeMagma("first", []);
Error, FreeMagma( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeMagma([], []);
Error, FreeMagma( <name1>, <name2>, ... ): the names must be nonempty strings
gap> FreeMagma("bacon", "eggs", "beans");
<free magma on the generators [ bacon, eggs, beans ]>
gap> FreeMagma("shed");
<free magma on the generators [ shed ]>

# FreeMagma( [ <name1>[, <name2>, ...] ] )
gap> FreeMagma(InfiniteListOfNames("a"));
Error, FreeMagma( [<name1>, <name2>, ...] ): there must be only finitely many \
names
gap> FreeMagma(["", "second"]);
Error, FreeMagma( [<name1>, <name2>, ...] ): the names must be nonempty string\
s
gap> FreeMagma(["first", ""]);
Error, FreeMagma( [<name1>, <name2>, ...] ): the names must be nonempty string\
s
gap> FreeMagma(["first", []]);
Error, FreeMagma( [<name1>, <name2>, ...] ): the names must be nonempty string\
s
gap> FreeMagma([[], []]);
Error, FreeMagma( [<name1>, <name2>, ...] ): the names must be nonempty string\
s
gap> FreeMagma(["bacon", "eggs", "beans"]);
<free magma on the generators [ bacon, eggs, beans ]>
gap> FreeMagma(["grid"]);
<free magma on the generators [ grid ]>
gap> FreeMagma(["grid"], fail);
Error, usage: FreeMagma( <rank>[, <name>] )
              FreeMagma( <name1>[, <name2>[, ...]] )
              FreeMagma( <names> )
              FreeMagma( infinity[, <name>][, <init>] )

# FreeMagmaWithOne
gap> FreeMagmaWithOne(fail);
Error, usage: FreeMagmaWithOne( <rank>[, <name>] )
              FreeMagmaWithOne( [<name1>[, <name2>[, ...]]] )
              FreeMagmaWithOne( <names> )
              FreeMagmaWithOne( infinity[, <name>][, <init>] )

# FreeMagmaWithOne: rank 0
gap> FreeMagmaWithOne();
<free group of rank zero>
gap> FreeMagmaWithOne([]);
<free group of rank zero>
gap> FreeMagmaWithOne("");
<free group of rank zero>
gap> FreeMagmaWithOne(0);
<free group of rank zero>
gap> FreeMagmaWithOne(0, "name");
<free group of rank zero>

# FreeMagmaWithOne(infinity[, name[, init]])
gap> FreeMagmaWithOne(infinity);
<free magma-with-one with infinity generators>
gap> FreeMagmaWithOne(infinity, fail);
Error, FreeMagmaWithOne( infinity, <name> ): <name> must be a string
gap> FreeMagmaWithOne(infinity, []);
<free magma-with-one with infinity generators>
gap> FreeMagmaWithOne(infinity, "");
<free magma-with-one with infinity generators>
gap> FreeMagmaWithOne(infinity, "nicename");
<free magma-with-one with infinity generators>
gap> FreeMagmaWithOne(infinity, fail, fail);
Error, FreeMagmaWithOne( infinity, <name>, <init> ): <name> must be a string
gap> FreeMagmaWithOne(infinity, "nicename", fail);
Error, FreeMagmaWithOne( infinity, <name>, <init> ): <init> must be a finite l\
ist
gap> FreeMagmaWithOne(infinity, "gen", []);
<free magma-with-one with infinity generators>
gap> FreeMagmaWithOne(infinity, "gen", [""]);
Error, FreeMagmaWithOne( infinity, <name>, <init> ): <init> must consist of no\
nempty strings
gap> FreeMagmaWithOne(infinity, "gen", ["starter"]);
<free magma-with-one with infinity generators>
gap> FreeMagmaWithOne(infinity, "gen", ["starter", ""]);
Error, FreeMagmaWithOne( infinity, <name>, <init> ): <init> must consist of no\
nempty strings
gap> M := FreeMagmaWithOne(infinity, "gen", ["starter", "second", "third"]);
<free magma-with-one with infinity generators>
gap> GeneratorsOfMagmaWithOne(M){[1 .. 4]};
[ starter, second, third, gen4 ]
gap> FreeMagmaWithOne(infinity, "gen", ["starter"], fail);
Error, usage: FreeMagmaWithOne( <rank>[, <name>] )
              FreeMagmaWithOne( [<name1>[, <name2>[, ...]]] )
              FreeMagmaWithOne( <names> )
              FreeMagmaWithOne( infinity[, <name>][, <init>] )

# FreeMagmaWithOne(rank[, name])
gap> M := FreeMagmaWithOne(1);
<free magma-with-one on the generators [ x1 ]>
gap> HasIsTrivial(M) and not IsTrivial(M);
true
gap> M := FreeMagmaWithOne(2);
<free magma-with-one on the generators [ x1, x2 ]>
gap> HasIsTrivial(M) and not IsTrivial(M);
true
gap> M := FreeMagmaWithOne(10);
<free magma-with-one on the generators [ x1, x2, x3, x4, x5, x6, x7, x8, x9, 
  x10 ]>
gap> M := FreeMagmaWithOne(3, fail);
Error, FreeMagmaWithOne( <rank>, <name> ): <name> must be a string
gap> M := FreeMagmaWithOne(4, "");
<free magma-with-one on the generators [ 1, 2, 3, 4 ]>
gap> M := FreeMagmaWithOne(5, []);
<free magma-with-one on the generators [ 1, 2, 3, 4, 5 ]>
gap> M := FreeMagmaWithOne(4, "cheese");
<free magma-with-one on the generators [ cheese1, cheese2, cheese3, cheese4 ]>
gap> FreeMagmaWithOne(3, "car", fail);
Error, usage: FreeMagmaWithOne( <rank>[, <name>] )
              FreeMagmaWithOne( [<name1>[, <name2>[, ...]]] )
              FreeMagmaWithOne( <names> )
              FreeMagmaWithOne( infinity[, <name>][, <init>] )

# FreeMagmaWithOne( <name1>[, <name2>, ...] )
gap> FreeMagmaWithOne("", "second");
Error, FreeMagmaWithOne( <name1>, <name2>, ... ): the names must be nonempty s\
trings
gap> FreeMagmaWithOne("first", "");
Error, FreeMagmaWithOne( <name1>, <name2>, ... ): the names must be nonempty s\
trings
gap> FreeMagmaWithOne("first", []);
Error, FreeMagmaWithOne( <name1>, <name2>, ... ): the names must be nonempty s\
trings
gap> FreeMagmaWithOne([], []);
Error, FreeMagmaWithOne( <name1>, <name2>, ... ): the names must be nonempty s\
trings
gap> FreeMagmaWithOne("bacon", "eggs", "beans");
<free magma-with-one on the generators [ bacon, eggs, beans ]>
gap> FreeMagmaWithOne("shed");
<free magma-with-one on the generators [ shed ]>

# FreeMagmaWithOne( [ <name1>[, <name2>, ...] ] )
gap> FreeMagmaWithOne(InfiniteListOfNames("a"));
Error, FreeMagmaWithOne( [<name1>, <name2>, ...] ): there must be only finitel\
y many names
gap> FreeMagmaWithOne(["", "second"]);
Error, FreeMagmaWithOne( [<name1>, <name2>, ...] ): the names must be nonempty\
 strings
gap> FreeMagmaWithOne(["first", ""]);
Error, FreeMagmaWithOne( [<name1>, <name2>, ...] ): the names must be nonempty\
 strings
gap> FreeMagmaWithOne(["first", []]);
Error, FreeMagmaWithOne( [<name1>, <name2>, ...] ): the names must be nonempty\
 strings
gap> FreeMagmaWithOne([[], []]);
Error, FreeMagmaWithOne( [<name1>, <name2>, ...] ): the names must be nonempty\
 strings
gap> FreeMagmaWithOne(["bacon", "eggs", "beans"]);
<free magma-with-one on the generators [ bacon, eggs, beans ]>
gap> FreeMagmaWithOne(["grid"]);
<free magma-with-one on the generators [ grid ]>
gap> FreeMagmaWithOne(["grid"], fail);
Error, usage: FreeMagmaWithOne( <rank>[, <name>] )
              FreeMagmaWithOne( [<name1>[, <name2>[, ...]]] )
              FreeMagmaWithOne( <names> )
              FreeMagmaWithOne( infinity[, <name>][, <init>] )

# wfilt
gap> FreeMagma(IsSyllableWordsFamily, 4);
Error, the first argument must not be a filter
gap> FreeMagmaWithOne(IsLetterWordsFamily, 3);
Error, the first argument must not be a filter

#
gap> STOP_TEST( "mgmfree.tst", 1);
