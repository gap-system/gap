#@local F
gap> START_TEST("smgrpfre.tst");

# FreeSemigroup
gap> FreeSemigroup(fail);
Error, usage: FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
              FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
              FreeSemigroup( [<wfilt>, ]<names> )
              FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeSemigroup: rank 0
gap> FreeSemigroup();
#I  FreeSemigroup cannot make an object with no generators
Error, usage: FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
              FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
              FreeSemigroup( [<wfilt>, ]<names> )
              FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )
gap> FreeSemigroup([]);
#I  FreeSemigroup cannot make an object with no generators
Error, usage: FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
              FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
              FreeSemigroup( [<wfilt>, ]<names> )
              FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )
gap> FreeSemigroup("");
#I  FreeSemigroup cannot make an object with no generators
Error, usage: FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
              FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
              FreeSemigroup( [<wfilt>, ]<names> )
              FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )
gap> FreeSemigroup(0);
#I  FreeSemigroup cannot make an object with no generators
Error, usage: FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
              FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
              FreeSemigroup( [<wfilt>, ]<names> )
              FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )
gap> FreeSemigroup(0, "name");
#I  FreeSemigroup cannot make an object with no generators
Error, usage: FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
              FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
              FreeSemigroup( [<wfilt>, ]<names> )
              FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeSemigroup(infinity[, name[, init]])
gap> FreeSemigroup(infinity);
<free semigroup on the generators [ s1, s2, ... ]>
gap> FreeSemigroup(infinity, fail);
Error, FreeSemigroup( infinity, <name> ): <name> must be a string
gap> FreeSemigroup(infinity, []);
<free semigroup on the generators [ 1, 2, ... ]>
gap> FreeSemigroup(infinity, "");
<free semigroup on the generators [ 1, 2, ... ]>
gap> FreeSemigroup(infinity, "nicename");
<free semigroup on the generators [ nicename1, nicename2, ... ]>
gap> FreeSemigroup(infinity, fail, fail);
Error, FreeSemigroup( infinity, <name>, <init> ): <name> must be a string
gap> FreeSemigroup(infinity, "nicename", fail);
Error, FreeSemigroup( infinity, <name>, <init> ): <init> must be a finite list
gap> FreeSemigroup(infinity, "gen", []);
<free semigroup on the generators [ gen1, gen2, ... ]>
gap> FreeSemigroup(infinity, "gen", [""]);
Error, FreeSemigroup( infinity, <name>, <init> ): <init> must consist of nonem\
pty strings
gap> FreeSemigroup(infinity, "gen", ["starter"]);
<free semigroup on the generators [ starter, gen2, ... ]>
gap> FreeSemigroup(infinity, "gen", ["starter", ""]);
Error, FreeSemigroup( infinity, <name>, <init> ): <init> must consist of nonem\
pty strings
gap> F := FreeSemigroup(infinity, "gen", ["starter", "second", "third"]);
<free semigroup on the generators [ starter, second, ... ]>
gap> GeneratorsOfSemigroup(F){[1 .. 4]};
[ starter, second, third, gen4 ]
gap> FreeSemigroup(infinity, "gen", ["starter"], fail);
Error, usage: FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
              FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
              FreeSemigroup( [<wfilt>, ]<names> )
              FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeSemigroup(rank[, name])
gap> F := FreeSemigroup(1);
<free semigroup on the generators [ s1 ]>
gap> HasIsCommutative(F) and IsCommutative(F);
true
gap> F := FreeSemigroup(2);
<free semigroup on the generators [ s1, s2 ]>
gap> HasIsCommutative(F) and not IsCommutative(F);
true
gap> F := FreeSemigroup(10);
<free semigroup on the generators [ s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 ]>
gap> F := FreeSemigroup(3, fail);
Error, FreeSemigroup( <rank>, <name> ): <name> must be a string
gap> F := FreeSemigroup(4, "");
<free semigroup on the generators [ 1, 2, 3, 4 ]>
gap> F := FreeSemigroup(5, []);
<free semigroup on the generators [ 1, 2, 3, 4, 5 ]>
gap> F := FreeSemigroup(4, "cheese");
<free semigroup on the generators [ cheese1, cheese2, cheese3, cheese4 ]>
gap> FreeSemigroup(3, "car", fail);
Error, usage: FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
              FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
              FreeSemigroup( [<wfilt>, ]<names> )
              FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )

# FreeSemigroup( <name1>, <name2>, ... )
gap> FreeSemigroup("", "second");
Error, FreeSemigroup( <name1>, <name2>, ... ): the names must be nonempty stri\
ngs
gap> FreeSemigroup("first", "");
Error, FreeSemigroup( <name1>, <name2>, ... ): the names must be nonempty stri\
ngs
gap> FreeSemigroup("first", []);
Error, FreeSemigroup( <name1>, <name2>, ... ): the names must be nonempty stri\
ngs
gap> FreeSemigroup([], []);
Error, FreeSemigroup( <name1>, <name2>, ... ): the names must be nonempty stri\
ngs
gap> FreeSemigroup("bacon", "eggs", "beans");
<free semigroup on the generators [ bacon, eggs, beans ]>
gap> FreeSemigroup("shed");
<free semigroup on the generators [ shed ]>

# FreeSemigroup( [ <name1>, <name2>, ... ] )
gap> FreeSemigroup(InfiniteListOfNames("a"));
Error, FreeSemigroup( [<name1>, <name2>, ...] ): there must be only finitely m\
any names
gap> FreeSemigroup(["", "second"]);
Error, FreeSemigroup( [<name1>, <name2>, ...] ): the names must be nonempty st\
rings
gap> FreeSemigroup(["first", ""]);
Error, FreeSemigroup( [<name1>, <name2>, ...] ): the names must be nonempty st\
rings
gap> FreeSemigroup(["first", []]);
Error, FreeSemigroup( [<name1>, <name2>, ...] ): the names must be nonempty st\
rings
gap> FreeSemigroup([[], []]);
Error, FreeSemigroup( [<name1>, <name2>, ...] ): the names must be nonempty st\
rings
gap> FreeSemigroup(["bacon", "eggs", "beans"]);
<free semigroup on the generators [ bacon, eggs, beans ]>
gap> FreeSemigroup(["grid"]);
<free semigroup on the generators [ grid ]>
gap> FreeSemigroup(["grid"], fail);
Error, usage: FreeSemigroup( [<wfilt>, ]<rank>[, <name>] )
              FreeSemigroup( [<wfilt>, ]<name1>[, <name2>[, ...]] )
              FreeSemigroup( [<wfilt>, ]<names> )
              FreeSemigroup( [<wfilt>, ]infinity[, <name>][, <init>] )

# generatorNames
gap> FreeSemigroup(5 : generatorNames := false);
Error, Cannot process the `generatorNames` option: the value must be either a \
single string, or a list of sufficiently many nonempty strings (at least 5, in\
 this case)
gap> PushOptions( rec( generatorNames := fail ) );
gap> FreeSemigroup(3 : generatorNames := "");
<free semigroup on the generators [ 1, 2, 3 ]>
gap> FreeSemigroup(2 : generatorNames := "cool");
<free semigroup on the generators [ cool1, cool2 ]>
gap> FreeSemigroup(2 : generatorNames := ["red"]);
Error, Cannot process the `generatorNames` option: the value must be either a \
single string, or a list of sufficiently many nonempty strings (at least 2, in\
 this case)
gap> PushOptions( rec( generatorNames := fail ) );
gap> FreeSemigroup(2 : generatorNames := ["red", "yellow"]);
<free semigroup on the generators [ red, yellow ]>
gap> FreeSemigroup(2 : generatorNames := ["red", "yellow", "green"]);
<free semigroup on the generators [ red, yellow ]>
gap> FreeSemigroup(2 : generatorNames := ["red", "yellow", "green", fail]);
<free semigroup on the generators [ red, yellow ]>
gap> FreeSemigroup("gen" : generatorNames := false);
<free semigroup on the generators [ gen ]>
gap> FreeSemigroup("gen" : generatorNames := "string");
<free semigroup on the generators [ gen ]>

#
gap> STOP_TEST( "smgrpfre.tst", 1);
