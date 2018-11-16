# Reported in github PR 2990
# Needs a GAP compiled with --enable-valgrind, then run as
# valgrind ./gap, to detect the problem which was fixed.
gap> h:= Group([ (1,17,2,18,6,13)(3,20)(4,11,10,16,5,12,8,15,9,19,7,14), 
> (1,19)(2,18,5,16,6,13,7,15)(3,11)(4,17,9,20,10,14,8,12) ]);;
gap> Size(h);
1036800
gap> Size(ConjugacyClasses(h));
44
