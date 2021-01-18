#@local G,p
gap> START_TEST("stbcbckt.tst");

# Intersection for perm groups with a single moved point in common
gap> G := Group(GeneratorsOfGroup(SymmetricGroup(100)));;
gap> p := PermList(Concatenation([100 .. 199], [1 .. 99]));;
gap> IsTrivial(Intersection(G, G ^ p));
true

#
gap> STOP_TEST("stbcbckt.tst", 1);
