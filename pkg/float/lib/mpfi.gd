#############################################################################
##
#W  mpfi.gd                       GAP library               Laurent Bartholdi
##
#H  @(#)$Id: mpfi.gd,v 1.4 2011/04/11 13:17:21 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.mpfi_gd :=
  "@(#)$Id: mpfi.gd,v 1.4 2011/04/11 13:17:21 gap Exp $";

#############################################################################
##
#C IsMPFIFloat
##
## <#GAPDoc Label="IsMPFIFloat">
## <ManSection>
##   <Filt Name="IsMPFIFloat"/>
##   <Var Name="MPFIFloatsFamily"/>
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
DeclareRepresentation("IsMPFIFloat", IsFloat and IsDataObjectRep, []);

BIND_GLOBAL("TYPE_MPFI", NewType(FloatsFamily, IsMPFIFloat));
#############################################################################

#############################################################################
##
#V Constants
##
## <#GAPDoc Label="MPFI_PI">
## <ManSection>
##   <Var Name="MPFI_0"/>
##   <Var Name="MPFI_1"/>
##   <Var Name="MPFI_2"/>
##   <Var Name="MPFI_M0"/>
##   <Var Name="MPFI_M1"/>
##   <Var Name="MPFI_INFINITY"/>
##   <Var Name="MPFI_MINFINITY"/>
##   <Var Name="MPFI_NAN"/>
##   <Oper Name="MPFI_PI" Arg="precision"/>
##   <Oper Name="MPFI_2PI" Arg="precision"/>
##   <Oper Name="MPFI_EULER" Arg="precision"/>
##   <Oper Name="MPFI_CATALAN" Arg="precision"/>
##   <Oper Name="MPFI_LOG2" Arg="precision"/>
##   <Description>
##     These variables/functions store mathematical constants.
##
##     <P/> The argument <A>precision</A> specifies the desired precision
##     in bits.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalVariable("MPFI");
#############################################################################

#############################################################################
##
#O Constructor
##
DeclareOperation("MPFIFloat", [IsObject]);
#############################################################################

#############################################################################
##
#E
