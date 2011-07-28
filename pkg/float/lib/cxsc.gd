#############################################################################
##
#W  cxsc.gd                       GAP library               Laurent Bartholdi
##
#H  @(#)$Id: cxsc.gd,v 1.4 2011/04/08 13:58:40 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.cxsc_gd :=
  "@(#)$Id: cxsc.gd,v 1.4 2011/04/08 13:58:40 gap Exp $";

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
##   <Var Name="CXSCRealFamily"/>
##   <Var Name="CXSCComplexFamily"/>
##   <Var Name="CXSCIntervalFamily"/>
##   <Var Name="CXSCBoxFamily"/>
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
DeclareCategory("IsCXSCFloat", IsFloat); # virtual classes
DeclareCategory("IsCXSCComplexFloat", IsCXSCFloat);
DeclareCategory("IsCXSCIntervalFloat", IsCXSCFloat and IsDomain);

DeclareCategory("IsCXSCReal", IsCXSCFloat);
DeclareCategoryCollections("IsCXSCReal");
DeclareCategoryCollections("IsCXSCRealCollection");
DeclareCategory("IsCXSCComplex", IsCXSCComplexFloat);
DeclareCategoryCollections("IsCXSCComplex");
DeclareCategoryCollections("IsCXSCComplexCollection");
DeclareCategory("IsCXSCInterval", IsCXSCIntervalFloat);
DeclareCategoryCollections("IsCXSCInterval");
DeclareCategoryCollections("IsCXSCIntervalCollection");
DeclareCategory("IsCXSCBox", IsCXSCIntervalFloat and IsCXSCComplexFloat);
DeclareCategoryCollections("IsCXSCBox");
DeclareCategoryCollections("IsCXSCBoxCollection");

BindGlobal("CXSCRealFamily",
        NewFamily("CXSCRealFamily", IsCXSCReal));
BindGlobal("CXSCComplexFamily",
        NewFamily("CXSCComplexFamily", IsCXSCComplex));
BindGlobal("CXSCIntervalFamily",
        NewFamily("CXSCIntervalFamily", IsCXSCInterval));
BindGlobal("CXSCBoxFamily",
        NewFamily("CXSCBoxFamily", IsCXSCBox));

BindGlobal("TYPE_CXSC_RP", 
        NewType(CXSCRealFamily, IsCXSCReal and IsInternalRep));
BindGlobal("TYPE_CXSC_CP", 
        NewType(CXSCComplexFamily, IsCXSCComplex and IsInternalRep));
BindGlobal("TYPE_CXSC_RI", 
        NewType(CXSCIntervalFamily, IsCXSCInterval and IsInternalRep));
BindGlobal("TYPE_CXSC_CI", 
        NewType(CXSCBoxFamily, IsCXSCBox and IsInternalRep));

BindGlobal("CXSC_RP_FIELD",
        Objectify(NewType(CollectionsFamily(CXSCRealFamily),
                IsField and IsAttributeStoringRep),rec()));
SetCharacteristic(CXSC_RP_FIELD,0);
BindGlobal("CXSC_CP_FIELD",
        Objectify(NewType(CollectionsFamily(CXSCComplexFamily),
                IsField and IsAttributeStoringRep),rec()));
SetCharacteristic(CXSC_CP_FIELD,0);
BindGlobal("CXSC_RI_FIELD",
        Objectify(NewType(CollectionsFamily(CXSCIntervalFamily),
                IsField and IsAttributeStoringRep),rec()));
SetCharacteristic(CXSC_RI_FIELD,0);
BindGlobal("CXSC_CI_FIELD",
        Objectify(NewType(CollectionsFamily(CXSCBoxFamily),
                IsField and IsAttributeStoringRep),rec()));
SetCharacteristic(CXSC_CI_FIELD,0);
#############################################################################

#############################################################################
##
#V Constants
##
## <#GAPDoc Label="CXSC_PI">
## <ManSection>
##   <Var Name="MPFR_0"/>
##   <Var Name="MPFR_1"/>
##   <Var Name="MPFR_2"/>
##   <Var Name="MPFR_M0"/>
##   <Var Name="MPFR_M1"/>
##   <Var Name="MPFR_INFINITY"/>
##   <Var Name="MPFR_MINFINITY"/>
##   <Var Name="MPFR_NAN"/>
##   <Oper Name="MPFR_PI" Arg="precision"/>
##   <Oper Name="MPFR_2PI" Arg="precision"/>
##   <Oper Name="MPFR_EULER" Arg="precision"/>
##   <Oper Name="MPFR_CATALAN" Arg="precision"/>
##   <Oper Name="MPFR_LOG2" Arg="precision"/>
##   <Description>
##     These variables/functions store mathematical constants.
##
##     <P/> The argument <A>precision</A> specifies the desired precision
##     in bits.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalVariable("CXSC");
#############################################################################

#############################################################################
##
#O Constructor
##
DeclareOperation("CXSCFloat", [IsObject]);
DeclareOperation("CXSCFloat", [IsObject,IsObject]);
DeclareOperation("CXSCReal", [IsObject]);
DeclareOperation("CXSCComplex", [IsObject]);
DeclareOperation("CXSCComplex", [IsObject,IsObject]);
DeclareOperation("CXSCInterval", [IsObject]);
DeclareOperation("CXSCInterval", [IsObject,IsObject]);
DeclareOperation("CXSCBox", [IsObject]);
DeclareOperation("CXSCBox", [IsObject,IsObject]);
#############################################################################

#############################################################################
##
#O Operations
##
DeclareOperation("ComplexRootsOfUnivariatePolynomial", [IsList]);
DeclareOperation("BoxRootsOfUnivariatePolynomial", [IsList]);
DeclareOperation("ComplexRootsOfUnivariatePolynomial", [IsPolynomial]);
DeclareOperation("BoxRootsOfUnivariatePolynomial", [IsPolynomial]);
#############################################################################

#############################################################################
##
#E
