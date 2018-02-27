gap> START_TEST("random.tst");
gap> ReadGapRoot( "tst/testrandom.g" );

# Test RandomList
gap> randomTest([1,2,3], RandomList);
gap> randomTest([1..100], RandomList);
gap> randomTest("abcdef", RandomList);
gap> randomTest(BlistList([1..100],[1,3..99]), RandomList);
gap> randomTest([1], RandomList);

#
# fields and rings
#

# cyclotomics
gap> randomTest(Integers, Random);
gap> randomTest(Rationals, Random);
gap> randomTest(GaussianIntegers, Random);
gap> randomTest(GaussianRationals, Random);

# finite fields
gap> randomTest(GF(2), Random);
gap> randomTest(GF(3), Random);
gap> randomTest(GF(4), Random);
gap> randomTest(GF(257), Random);
gap> randomTest(GF(65537), Random);
gap> randomTest(GF(257^2), Random);
gap> randomTest(GF(2^20), Random);

# ZmodnZ
gap> randomTest(Integers mod 1, Random);
gap> randomTest(Integers mod 4, Random);
gap> randomTest(Integers mod 100, Random);

# ZmodnZe
gap> randomTest(RingInt(CF(4)) mod 5, Random);

#
# magmas, monoids, ...
#

#
gap> randomTest(FreeMagma(1), Random);
gap> randomTest(FreeMagma(2), Random);

#
gap> randomTest(FreeMonoid(0), Random);
gap> randomTest(FreeMonoid(1), Random);
gap> randomTest(FreeMonoid(2), Random);

#
# permutation groups
#
gap> randomTest(TrivialGroup(IsPermGroup), Random);

#
gap> randomTest(SymmetricGroup(2), Random);
gap> randomTest(SymmetricGroup(3), Random);
gap> randomTest(SymmetricGroup(4), Random);
gap> randomTest(AlternatingGroup(3), Random);
gap> randomTest(AlternatingGroup(4), Random);
gap> randomTest(AlternatingGroup(5), Random);

#
gap> randomTest(Group((1,2),(3,4)), Random);
gap> randomTest(PrimitiveGroup(5,2), Random);
gap> randomTest(PrimitiveGroup(5,3), Random);
gap> randomTest(Group((1,2),(3,4))*(1,2,3), Random);
gap> randomTest(PrimitiveGroup(5,2)*(1,2,6), Random);
gap> randomTest(PrimitiveGroup(5,3)*(1,4,6), Random);

#
# pc groups
#
gap> randomTest(TrivialGroup(IsPcGroup), Random);
gap> randomTest(AbelianGroup(IsPcGroup, [2]), Random);
gap> randomTest(AbelianGroup(IsPcGroup, [2,3,4,5]), Random);

#
# fp groups
#
gap> randomTest(TrivialGroup(IsFpGroup), Random);
gap> randomTest(FreeGroup(0), Random);
gap> randomTest(FreeGroup(1), Random);
gap> randomTest(FreeGroup(2), Random);
gap> randomTest(FreeGroup(infinity), Random);
gap> randomTest(DihedralGroup(IsFpGroup, 6), Random);

#
# matrix groups
#
gap> randomTest(CyclicGroup(IsMatrixGroup, GF(2), 1), Random);
gap> randomTest(CyclicGroup(IsMatrixGroup, GF(9), 1), Random);
gap> randomTest(CyclicGroup(IsMatrixGroup, Rationals, 1), Random);

#
gap> randomTest(CyclicGroup(IsMatrixGroup, GF(2), 3), Random);
gap> randomTest(CyclicGroup(IsMatrixGroup, GF(3), 3), Random);

#
gap> randomTest(SL(2,2), Random);
gap> randomTest(SL(3,3), Random);

#
gap> randomTest(GL(2,2), Random);
gap> randomTest(GL(3,3), Random);

#
# other stuff
#

#
gap> randomTest(DoubleCoset(Group((1,2),(3,4)), (1,2,3,4,5,6), Group((1,2,3)) ), Random);
gap> randomTest(DoubleCoset(Group(()), (1,2), Group((1,2,3)) ), Random);
gap> randomTest(DoubleCoset(Group((1,2),(3,4)), (), Group((1,2,3)) ), Random);

#
gap> randomTest([1], Random);
gap> randomTest([1..10], Random);
gap> randomTest([1..2], Random);
gap> randomTest([0, 10..1000], Random);
gap> randomTest("cheese", Random);
gap> randomTest([1,-6,"cheese", Group(())], Random);

#
gap> randomTest(PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1]), Random, function(x,y) return IsPadicExtensionNumber(x); end);
gap> randomTest(PurePadicNumberFamily(2,20), Random, function(x,y) return IsPurePadicNumber(x); end);

#
gap> STOP_TEST("random.tst", 1);
