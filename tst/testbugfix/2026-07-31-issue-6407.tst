# Regression test for https://github.com/gap-system/gap/issues/6407
# `FittingSubgroup' leaves a central series pcgs on `H' which is not an
# elementary abelian series; `AutomorphismGroup' used to turn that pcgs into
# the special pcgs, without being able to correct its stale series indices.
# `ElementaryAbelianSeries' then returned a series with a non-elementary
# abelian factor, and `ElementaryAbelianSeriesLargeSteps' looped forever.
gap> H := Group([(1,2)(3,4)(5,8,7,6)(9,12)(10,11),
>                (1,4,3,2)(5,7),
>                (2,4)(5,6,7,8)(9,10,11,12)]);;
gap> StabChain(H, [1, 5, 9]);;
gap> FittingSubgroup(H);;
gap> AutomorphismGroup(H);;
gap> e := ElementaryAbelianSeries(H);;
gap> ForAll([1..Length(e)-1],
>           i -> HasElementaryAbelianFactorGroup(e[i], e[i+1]));
true
gap> List(ElementaryAbelianSeriesLargeSteps(H), Size);
[ 64, 16, 2, 1 ]
