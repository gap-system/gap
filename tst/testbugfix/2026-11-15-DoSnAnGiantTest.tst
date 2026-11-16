# DoSnAnGiantTest missed giants with probability 8*10^-4, sending
# PermgpContainsAn into IsPrimitive. It now misses with probability below
# 10^-13 for these degrees, so 2000 calls at a fixed seed all succeed;
# with the old bound they fail with probability 0.96. On non-giants it
# fails deterministically, by Jordan's theorem.
gap> Reset(GlobalMersenneTwister, 1);;
gap> giant := G -> DoSnAnGiantTest(Group(GeneratorsOfGroup(G)), MovedPoints(G));;
gap> ForAll([1..2000], i -> giant(SymmetricGroup(100)) = true);
true
gap> ForAll([1..2000], i -> giant(AlternatingGroup(101)) = true);
true
gap> giant(MathieuGroup(24));
fail
gap> giant(WreathProduct(SymmetricGroup(10), SymmetricGroup(10)));
fail
