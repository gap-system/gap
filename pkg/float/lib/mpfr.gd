#############################################################################
##
#W  mpfr.gd                       GAP library               Laurent Bartholdi
##
#H  @(#)$Id: mpfr.gd,v 1.4 2011/04/11 13:17:21 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.mpfr_gd :=
  "@(#)$Id: mpfr.gd,v 1.4 2011/04/11 13:17:21 gap Exp $";

#############################################################################
##
#C IsMPFRFloat
##
## <#GAPDoc Label="IsMPFRFloat">
## <ManSection>
##   <Filt Name="IsMPFRFloat"/>
##   <Var Name="MPFRFloatsFamily"/>
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
DeclareRepresentation("IsMPFRFloat", IsFloat and IsDataObjectRep, []);

BIND_GLOBAL("TYPE_MPFR", NewType(FloatsFamily, IsMPFRFloat));
#############################################################################

#############################################################################
##
#V Constants
##
## <#GAPDoc Label="MPFR_PI">
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
DeclareGlobalVariable("MPFR");
#############################################################################

#############################################################################
##
#O Constructor
##
DeclareOperation("MPFRFloat", [IsObject]);
#############################################################################

#############################################################################
##
#E
