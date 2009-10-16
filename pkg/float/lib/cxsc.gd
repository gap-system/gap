#############################################################################
##
#W  cxsc.gd                       GAP library               Laurent Bartholdi
##
#H  @(#)$Id: cxsc.gd,v 1.1 2008/06/14 15:45:40 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.cxsc_gd :=
  "@(#)$Id: cxsc.gd,v 1.1 2008/06/14 15:45:40 gap Exp $";

#############################################################################
##
#C IsCXSCFloat
##
## <#GAPDoc Label="IsCXSCFloat">
## <ManSection>
##   <Filt Name="IsCXSCReal"/>
##   <Filt Name="IsCXSCComplex"/>
##   <Filt Name="IsCXSCInterval"/>
##   <Filt Name="IsCXSCCInterval"/>
##   <Var Name="CXSCRealFamily"/>
##   <Var Name="CXSCComplexFamily"/>
##   <Var Name="CXSCIntervalFamily"/>
##   <Var Name="CXSCCIntervalFamily"/>
##   <Var Name="TYPE_CXSC_REAL"/>
##   <Var Name="TYPE_CXSC_COMPLEX"/>
##   <Var Name="TYPE_CXSC_INTERVAL"/>
##   <Var Name="TYPE_CXSC_CINTERVAL"/>
##   <Description>
##     The category of floating-point numbers.
##
##     <P/> Note that they are treated as commutative and scalar, but are
##     not necessarily associative.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareCategory("IsCXSCFloat", IsFloat);
DeclareCategoryCollections("IsCXSCFloat");
DeclareCategoryCollections("IsCXSCFloatCollection");
DeclareCategory("IsCXSCReal", IsCXSCFloat);
DeclareCategoryCollections("IsCXSCReal");
DeclareCategoryCollections("IsCXSCRealCollection");
DeclareCategory("IsCXSCComplex", IsCXSCFloat);
DeclareCategoryCollections("IsCXSCComplex");
DeclareCategoryCollections("IsCXSCComplexCollection");
DeclareCategory("IsCXSCInterval", IsCXSCFloat and IsDomain);
DeclareCategoryCollections("IsCXSCInterval");
DeclareCategoryCollections("IsCXSCIntervalCollection");
DeclareCategory("IsCXSCCInterval", IsCXSCFloat and IsDomain);
DeclareCategoryCollections("IsCXSCCInterval");
DeclareCategoryCollections("IsCXSCCIntervalCollection");

BindGlobal("CXSCRealFamily",
        NewFamily("CXSCRealFamily", IsCXSCReal));
BindGlobal("CXSCComplexFamily",
        NewFamily("CXSCComplexFamily", IsCXSCComplex));
BindGlobal("CXSCIntervalFamily",
        NewFamily("CXSCIntervalFamily", IsCXSCInterval));
BindGlobal("CXSCCIntervalFamily",
        NewFamily("CXSCCIntervalFamily", IsCXSCCInterval));

BindGlobal("TYPE_CXSC_REAL", 
        NewType(CXSCRealFamily, IsCXSCReal and IsInternalRep));
BindGlobal("TYPE_CXSC_COMPLEX", 
        NewType(CXSCComplexFamily, IsCXSCComplex and IsInternalRep));
BindGlobal("TYPE_CXSC_INTERVAL", 
        NewType(CXSCIntervalFamily, IsCXSCInterval and IsInternalRep));
BindGlobal("TYPE_CXSC_CINTERVAL", 
        NewType(CXSCCIntervalFamily, IsCXSCCInterval and IsInternalRep));

BindGlobal("TYPE_CXSC_REAL0", 
        NewType(CXSCRealFamily, IsCXSCReal and IsInternalRep and IsZero));
BindGlobal("TYPE_CXSC_COMPLEX0", 
        NewType(CXSCComplexFamily, IsCXSCComplex and IsInternalRep and IsZero));
BindGlobal("TYPE_CXSC_INTERVAL0", 
        NewType(CXSCIntervalFamily, IsCXSCInterval and IsInternalRep and IsZero));
BindGlobal("TYPE_CXSC_CINTERVAL0", 
        NewType(CXSCCIntervalFamily, IsCXSCCInterval and IsInternalRep and IsZero));

BindGlobal("CXSC_REAL_FIELD",
        Objectify(NewType(CollectionsFamily(CXSCRealFamily),
                IsField and IsAttributeStoringRep),rec()));
SetCharacteristic(CXSC_REAL_FIELD,0);
BindGlobal("CXSC_COMPLEX_FIELD",
        Objectify(NewType(CollectionsFamily(CXSCComplexFamily),
                IsField and IsAttributeStoringRep),rec()));
SetCharacteristic(CXSC_COMPLEX_FIELD,0);
BindGlobal("CXSC_INTERVAL_FIELD",
        Objectify(NewType(CollectionsFamily(CXSCIntervalFamily),
                IsField and IsAttributeStoringRep),rec()));
SetCharacteristic(CXSC_INTERVAL_FIELD,0);
BindGlobal("CXSC_CINTERVAL_FIELD",
        Objectify(NewType(CollectionsFamily(CXSCCIntervalFamily),
                IsField and IsAttributeStoringRep),rec()));
SetCharacteristic(CXSC_CINTERVAL_FIELD,0);
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
DeclareOperation("CXSCCInterval", [IsObject]);
DeclareOperation("CXSCCInterval", [IsObject,IsObject]);
#############################################################################

#############################################################################
##
#O Operations
##
DeclareOperation("Sup", [IsObject]);
DeclareOperation("Inf", [IsObject]);
DeclareOperation("Mid", [IsObject]);
DeclareOperation("Overlaps", [IsCXSCFloat,IsCXSCFloat]);
DeclareOperation("IsDisjoint", [IsCXSCFloat,IsCXSCFloat]);

DeclareOperation("ComplexRootsOfUnivariatePolynomial", [IsList]);
DeclareOperation("CIntervalRootsOfUnivariatePolynomial", [IsList]);
DeclareOperation("ComplexRootsOfUnivariatePolynomial", [IsPolynomial]);
DeclareOperation("CIntervalRootsOfUnivariatePolynomial", [IsPolynomial]);
#############################################################################

#############################################################################
##
#E
