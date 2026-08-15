# Several errors or wrong results were briefly produced by
# AutomorphismGroup respectively AutomorphismGroupSolvableGroup.
# See https://github.com/gap-system/gap/pull/6510
gap> START_TEST("2026-08-14-AutomorphismGroupSolvableGroup.tst");

#
gap> Size(AutomorphismGroup(SmallGroup(24,3)));
24
gap> Size(AutomorphismGroup(SmallGroup(147, 4)));
98784
gap> Size(AutomorphismGroup(SmallGroup(864,4675)));
10368

#
gap> Size(AutomorphismGroupSolvableGroup(SmallGroup(24,3)));
24
gap> Size(AutomorphismGroupSolvableGroup(SmallGroup(147, 4)));
98784
gap> Size(AutomorphismGroupSolvableGroup(SmallGroup(864,4675)));
10368

#
gap> STOP_TEST("2026-08-14-AutomorphismGroupSolvableGroup.tst");
