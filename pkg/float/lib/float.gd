#############################################################################
##
#W  float.gd                       GAP library              Laurent Bartholdi
##
#H  @(#)$Id: float.gd,v 1.10 2012/01/17 10:57:03 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with general float functions
##
Revision.float.float_gd :=
  "@(#)$Id: float.gd,v 1.10 2012/01/17 10:57:03 gap Exp $";

################################################################
DeclareCategory("IsFloatPseudoField", IsAlgebra);

# with precision
DeclareConstructor("NewFloat",[IsFloat,IsFloat,IsInt]);
DeclareOperation("MakeFloat",[IsFloat,IsFloat,IsInt]);

################################################################
# roots
################################################################
DeclareOperation("RootsFloatOp", [IsList,IsFloat]);
DeclareGlobalFunction("RootsFloat");
DeclareOperation("Value", [IsRationalFunction,IsFloat]);
DeclareOperation("ValueInterval", [IsRationalFunction,IsFloat]);
DeclareAttribute("FloatCoefficientsOfUnivariatePolynomial", IsUnivariatePolynomial);

#############################################################################
##
#C IsMPFRFloat
##
## <#GAPDoc Label="IsMPFRFloat">
## <ManSection>
##   <Filt Name="IsMPFRFloat"/>
##   <Var Name="TYPE_MPFR"/>
##   <Description>
##     The category of floating-point numbers.
##
##     <P/> Note that they are treated as commutative and scalar, but are
##     not necessarily associative.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
if IsBound(MPFR_INT) then
DeclareRepresentation("IsMPFRFloat", IsFloat and IsDataObjectRep, []);
BIND_GLOBAL("TYPE_MPFR", NewType(FloatsFamily, IsMPFRFloat));
DeclareGlobalVariable("MPFR");
fi;
#############################################################################

#############################################################################
##
#C IsMPFIFloat
##
## <#GAPDoc Label="IsMPFIFloat">
## <ManSection>
##   <Filt Name="IsMPFIFloat"/>
##   <Var Name="TYPE_MPFI"/>
##   <Description>
##     The category of intervals of floating-point numbers.
##
##     <P/> Note that they are treated as commutative and scalar, but are
##     not necessarily associative.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
if IsBound(MPFI_INT) then
DeclareRepresentation("IsMPFIFloat", IsFloatInterval and IsDataObjectRep, []);
BIND_GLOBAL("TYPE_MPFI", NewType(FloatsFamily, IsMPFIFloat));
DeclareGlobalVariable("MPFI");
fi;
#############################################################################

#############################################################################
##
#C IsMPCFloat
##
## <#GAPDoc Label="IsMPCFloat">
## <ManSection>
##   <Filt Name="IsMPCFloat"/>
##   <Var Name="TYPE_MPC"/>
##   <Description>
##     The category of intervals of floating-point numbers.
##
##     <P/> Note that they are treated as commutative and scalar, but are
##     not necessarily associative.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
if IsBound(MPC_INT) then
DeclareRepresentation("IsMPCFloat", IsComplexFloat and IsDataObjectRep, []);
BIND_GLOBAL("TYPE_MPC", NewType(FloatsFamily, IsMPCFloat));
DeclareGlobalVariable("MPC");

DeclareAttribute("SphereProject", IsMPCFloat);
fi;
#############################################################################

#############################################################################
##
#C IsCXSCFloat
##
## <#GAPDoc Label="IsCXSCFloat">
## <ManSection>
##   <Filt Name="IsCXSCReal"/>
##   <Filt Name="IsCXSCComplex"/>
##   <Filt Name="IsCXSCInterval"/>
##   <Filt Name="IsCXSCBox"/>
##   <Var Name="CXSCFloatsFamily"/>
##   <Var Name="TYPE_CXSC_RP"/>
##   <Var Name="TYPE_CXSC_CP"/>
##   <Var Name="TYPE_CXSC_RI"/>
##   <Var Name="TYPE_CXSC_CI"/>
##   <Description>
##     The category of floating-point numbers.
##
##     <P/> Note that they are treated as commutative and scalar, but are
##     not necessarily associative.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
if IsBound(CXSC_INT) then
DeclareCategory("IsCXSCFloat", IsFloat); # virtual class containing all below

DeclareRepresentation("IsCXSCFloatRep", IsCXSCFloat and IsDataObjectRep, []);

DeclareCategory("IsCXSCReal", IsFloat and IsCXSCFloatRep);
DeclareCategoryCollections("IsCXSCReal");
DeclareCategoryCollections("IsCXSCRealCollection");
DeclareCategory("IsCXSCComplex", IsComplexFloat and IsCXSCFloatRep);
DeclareCategoryCollections("IsCXSCComplex");
DeclareCategoryCollections("IsCXSCComplexCollection");
DeclareCategory("IsCXSCInterval", IsFloatInterval and IsCXSCFloatRep);
DeclareCategoryCollections("IsCXSCInterval");
DeclareCategoryCollections("IsCXSCIntervalCollection");
DeclareCategory("IsCXSCBox", IsComplexFloatInterval and IsCXSCFloatRep);
DeclareCategoryCollections("IsCXSCBox");
DeclareCategoryCollections("IsCXSCBoxCollection");

BindGlobal("TYPE_CXSC_RP", NewType(FloatsFamily, IsCXSCReal));
BindGlobal("TYPE_CXSC_CP", NewType(FloatsFamily, IsCXSCComplex));
BindGlobal("TYPE_CXSC_RI", NewType(FloatsFamily, IsCXSCInterval));
BindGlobal("TYPE_CXSC_CI", NewType(FloatsFamily, IsCXSCBox));

DeclareGlobalVariable("CXSC");
fi;
#############################################################################

#############################################################################
##
#C FPLLL
##
## <#GAPDoc Label="FPLLL">
## <ManSection>
##   <Oper Name="FPLLLReducedBasis" Arg="m"/>
##   <Returns>A matrix spanning the same lattice as <A>m</A>.</Returns>
##   <Description>
##     This function implements the LLL (Lenstra-Lenstra-Lovász) lattice
##     reduction algorithm via the external library <Package>fplll</Package>.
##
##     <P/> The result is guaranteed to be optimal up to 1%.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="FPLLLShortestVector" Arg="m"/>
##   <Returns>A short vector in the lattice spanned by <A>m</A>.</Returns>
##   <Description>
##     This function implements the LLL (Lenstra-Lenstra-Lovász) lattice
##     reduction algorithm via the external library <Package>fplll</Package>,
##     and then computes a short vector in this lattice.
##
##     <P/> The result is guaranteed to be optimal up to 1%.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
if IsBound(@FPLLL) then
DeclareOperation("FPLLLReducedBasis", [IsMatrix]);
DeclareOperation("FPLLLShortestVector", [IsMatrix]);
fi;
#############################################################################

#############################################################################
#E
