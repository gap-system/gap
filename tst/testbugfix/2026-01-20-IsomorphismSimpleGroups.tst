# Fix #6200 IsomorphismSimpleGroups
#@local G, x, H
gap> START_TEST("IsomorphismSimpleGroups.tst");

# The runtime depends very much on random choices in the code,
# it can vary from a few milliseconds (rare) to several minutes.
gap> Reset( GlobalMersenneTwister, 2^19 );;
gap> G:= AlternatingGroup( 20 );;
gap> x:= ();;
gap> H:= ConjugateGroup( G, x );;
gap> IsomorphismSimpleGroups( G, H : cheap:= true ) <> fail;
true

# 
gap> STOP_TEST("IsomorphismSimpleGroups.tst");
