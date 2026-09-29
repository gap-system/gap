# Regression test for issue #6465:
# https://github.com/gap-system/gap/issues/6465
#
# ConjugacyClassesFittingFreeGroup could call `NrMovedPoints' on the image
# of `NaturalHomomorphismByNormalSubgroupNC', but that image need not be a
# permutation group (e.g. it can be a pc group), which raised
# "no 1st choice method found for `NrMovedPoints'".
gap> gens:= [ (1,2,5,4,3)(6,7)(9,10)(12,13),
>             (1,5)(2,3)(6,11,7,12,8,13,9,14)(10,15) ];;
gap> G:= Group( gens );;
gap> Length( ConjugacyClasses( G ) );
175
