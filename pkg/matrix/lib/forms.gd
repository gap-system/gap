# known preserved forms. Values are `false' if there are no forms.
DeclareRCAttribute("PreservedSesquilinearForm");
DeclareRCAttribute("PreservedBilinearForm");
DeclareRCAttribute("PreservedQuadraticForm");

# the type of the form
DeclareRCAttribute("FormType");

# scalars on form
DeclareRCAttribute("RC_Scalars");

# compute possible qq+1-th root of scalar for sesquilinear form.
# returns [i0,lambda] where (lambda*u)^(qq+1) (u a i0-th root of
# unity) are the possible scalars.
# returns `false' if the element admits no scalars. (I.e. no sesquilinear
# form possible)
DeclareGlobalFunction("ClassicalForms_ScalarMultipleFrobenius");

#############################################################################
##
#F  ClassicalForms_GeneratorsWithoutScalarsFrobenius(<module>)
##
DeclareGlobalFunction("ClassicalForms_GeneratorsWithoutScalarsFrobenius");

# compute possible 2nd root of scalar for sesquilinear form.
# returns [i0,lambda] where (lambda*u)^2 (u a i0-th root of
# unity) are the possible scalars.
# returns `false' if the element admits no scalars. (I.e. no bilinear
# form possible)
DeclareGlobalFunction("ClassicalForms_ScalarMultipleDual");

#############################################################################
##
#F  ClassicalForms_GeneratorsWithoutScalarsDual(<module>)
##
DeclareGlobalFunction("ClassicalForms_GeneratorsWithoutScalarsDual");

#############################################################################
##
#F  ClassicalForms_Signum2(<field>, <form>, <quad>)
##
DeclareGlobalFunction("ClassicalForms_Signum2");

#############################################################################
##
#F  ClassicalForms_Signum(<field>, <form>, <quad>)
##
DeclareGlobalFunction("ClassicalForms_Signum");

#############################################################################
##
#F  ClassicalForms_QuadraticForm2(<field>, <form>, <gens>, <scalars>)
##
DeclareGlobalFunction("ClassicalForms_QuadraticForm2");

#############################################################################
##
#F  ClassicalForms_QuadraticForm(<field>, <form>)
##
DeclareGlobalFunction("ClassicalForms_QuadraticForm");

#############################################################################
##
#F  ClassicalForms_InvariantFormDual(<module>, <dmodule>)
##
DeclareGlobalFunction("ClassicalForms_InvariantFormDual");

#############################################################################
##
#F  ClassicalForms_InvariantFormFrobenius(<module>, <fmodule>)
##
DeclareGlobalFunction("TransposedFrobeniusMat");

DeclareGlobalFunction("DualFrobeniusGModule");

DeclareGlobalFunction("ClassicalForms_InvariantFormFrobenius");

#############################################################################
##
#F  ClassicalForms(<grp>)
##
DeclareGlobalFunction("DoClassicalForms");
