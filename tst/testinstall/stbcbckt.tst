#@local G,p,S,T,x,y,c,H,r,N,set
gap> START_TEST("stbcbckt.tst");

# Intersection for perm groups with a single moved point in common
gap> G := Group(GeneratorsOfGroup(SymmetricGroup(100)));;
gap> p := PermList(Concatenation([100 .. 199], [1 .. 99]));;
gap> IsTrivial(Intersection(G, G ^ p));
true

# partition backtrack in a full symmetric group
gap> S := SymmetricGroup(7);;
gap> T := TrivialSubgroup(S);;
gap> G := Group((1,2,3,4,5,6,7), (2,3,5)(4,7,6));;
gap> c := (1,6,4)(2,7);;
gap> H := G^c;;
gap> r := ConjugatorPermGroup(S, G, H);;
gap> G^r = H;
true
gap> ConjugatorPermGroup(S, G, Group((1,2,3,4,5,6,7), (2,3)(4,7))) = fail;
true
gap> N := NormalizerPermGroup(S, G);;
gap> Size(N);
42
gap> x := (1,2,3)(4,5);; y := (1,4)(2,6,7);;
gap> Size(RepOpElmTuplesPermGroup(false, S, [x], [x], T, T));
12
gap> r := RepOpElmTuplesPermGroup(true, S, [x, y], [x^c, y^c], T, T);;
gap> x^r = x^c and y^r = y^c;
true
gap> RepOpElmTuplesPermGroup(true, S, [x, y], [x^c, (x*y)^c], T, T);
fail
gap> set := [1, 3, 4];;
gap> Size(SubgroupProperty(S, g -> OnSets(set, g) = set));
144
gap> r := ElementProperty(S, g -> x^g = x^c);;
gap> x^r = x^c;
true

# the initial partition is already discrete, so the R-base is empty
gap> S := SymmetricGroup(3);;
gap> T := TrivialSubgroup(S);;
gap> RepOpElmTuplesPermGroup(true, S, [(1,2), (2,3)], [(2,3), (1,3)], T, T);
(1,2,3)

#
gap> STOP_TEST("stbcbckt.tst");
