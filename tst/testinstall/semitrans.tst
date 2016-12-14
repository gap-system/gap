#############################################################################
##
#W  semitrans.tst
#Y  James D. Mitchell
##
#############################################################################
##

#
gap> START_TEST("trans.tst");
gap> display := UserPreference("TransformationDisplayLimit");;
gap> notation := UserPreference("NotationForTransformations");;
gap> SetUserPreference("TransformationDisplayLimit", 100);;
gap> SetUserPreference("NotationForTransformations", "input");;

# Test IsFullTransformationSemigroup in trivial cases
gap> IsFullTransformationSemigroup(Semigroup(Transformation([1])));
true
gap> IsFullTransformationSemigroup(Semigroup(Transformation([1, 1])));
false

#
gap> SetUserPreference("TransformationDisplayLimit", display);;
gap> SetUserPreference("NotationForTransformations", notation);;

#
gap> STOP_TEST("trans.tst", 74170000);
