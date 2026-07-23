# The simple direct factors of a fitting-free socle need not be normal in the
# whole group.  In this wreath product, the top group interchanges the two
# factors.  Check that the rewriting path constructs a valid presentation.

gap> START_TEST("2026-07-20-IsomorphismFpGroupByChiefSeriesFactor.tst");
gap> G := WreathProduct(AlternatingGroup(5), Group((1,2)));;
gap> factors := DirectFactorsFittingFreeSocle(G);;
gap> List(factors, factor -> IsNormal(G, factor));
[ false, false ]
gap> oldlevel := InfoLevel(InfoPerformance);;
gap> SetInfoLevel(InfoPerformance, 0);
gap> iso := IsomorphismFpGroupByChiefSeriesFactor(
> G, "x", TrivialSubgroup(G) : rewrite := true);;
gap> SetInfoLevel(InfoPerformance, oldlevel);
gap> IsBijective(iso) and Size(Image(iso)) = Size(G);
true
gap> STOP_TEST("2026-07-20-IsomorphismFpGroupByChiefSeriesFactor.tst");
