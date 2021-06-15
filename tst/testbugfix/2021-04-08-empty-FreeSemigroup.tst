# See https://github.com/gap-system/gap/issues/1385
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
