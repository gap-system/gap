#############################################################################
##
#W  mpfr.gd                       GAP library               Laurent Bartholdi
##
#H  @(#)$Id: mpfr.gd,v 1.1 2008/06/14 15:45:40 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.mpfr_gd :=
  "@(#)$Id: mpfr.gd,v 1.1 2008/06/14 15:45:40 gap Exp $";

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
DeclareCategory("IsMPFRFloat", IsFloat);

BIND_GLOBAL("MPFRFloatsFamily", 
        NewFamily("MPFRFloatsFamily", IsMPFRFloat));

BIND_GLOBAL("TYPE_MPFR", 
        NewType(MPFRFloatsFamily, IsMPFRFloat and IsInternalRep));
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
