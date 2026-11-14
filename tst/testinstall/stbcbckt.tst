#@local G,p,S,T,x,y,c,H,r,N,set,M
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

# issue #3718: PSL(3,5) on 31 points, only refined by suborbits of the
# stabilizers of further R-base points
gap> G := Group([ (2,5,4,3)(6,11,16,21)(7,15,19,23)(8,12,20,24)(9,13,17,25)
>   (10,14,18,22)(27,29)(28,30), (1,26,4,6,9,23,8,17,13,28,5,21,14,12,10,15,
>   18,25,30,2,16,19,29,31)(3,11,24,20,7,27) ]);;
gap> H := Group([ (1,4,29,2)(3,30,18,20)(5,19,26,10)(6,13)(7,8,27,31)(9,28,24,
>   16)(12,22)(14,21,17,23), (1,16,12,31,26,19,5,18,2,23,9,13,8,20,14,10,30,29,
>   28,22,15,25,11,27)(3,21,24,6,7,17) ]);;
gap> r := ConjugatorPermGroup(SymmetricGroup(31), G, H);;
gap> G^r = H;
true

# R-base points moved by the stabilizer of the earlier ones
gap> M := MathieuGroup(24);;
gap> N := NormalizerPermGroup(SymmetricGroup(24), M);;
gap> N = M;
true

# once the fixpoints contain a base, images of elements are determined
gap> G := PSL(2,11);;
gap> c := PermList(Concatenation([13..24], [1..12]));;
gap> G := Group(Concatenation(List(GeneratorsOfGroup(G), g -> g * g^c), [c]));;
gap> Size(NormalizerPermGroup(SymmetricGroup(24), G));
2640
gap> H := G^(1,5,7)(2,24)(3,13,9,20);;
gap> r := ConjugatorPermGroup(SymmetricGroup(24), G, H);;
gap> G^r = H;
true

# the normalizer of the action on blocks restricts the images of the blocks
gap> G := Group((1,2,3,4,5,6,7,8,9,10,11,12,13),
>              (2,3,5,9,4,7,13,12,10,6,11,8));;
gap> G := WreathProduct(Group((1,2)), G);;
gap> Size(NormalizerPermGroup(SymmetricGroup(26), G)) = Size(G);
true
gap> H := G^(1,3,7)(2,25)(5,20,11,9);;
gap> r := ConjugatorPermGroup(SymmetricGroup(26), G, H);;
gap> G^r = H;
true

#
gap> STOP_TEST("stbcbckt.tst");
