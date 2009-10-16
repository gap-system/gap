#############################################################################
##
#W  mpc.gd                       GAP library                Laurent Bartholdi
##
#H  @(#)$Id: mpc.gd,v 1.1 2008/06/14 15:45:40 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with floats
##
Revision.mpc_gd :=
  "@(#)$Id: mpc.gd,v 1.1 2008/06/14 15:45:40 gap Exp $";

#############################################################################
##
#C IsMPCFloat
##
## <#GAPDoc Label="IsMPCFloat">
## <ManSection>
##   <Filt Name="IsMPCFloat"/>
##   <Var Name="MPCFloatsFamily"/>
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
DeclareCategory("IsMPCFloat", IsFloat);

BIND_GLOBAL("MPCFloatsFamily", 
        NewFamily("MPCFloatsFamily", IsMPCFloat));

BIND_GLOBAL("TYPE_MPC", 
        NewType(MPCFloatsFamily, IsMPCFloat and IsInternalRep));
#############################################################################

#############################################################################
##
#V Constants
##
## <#GAPDoc Label="MPC_PI">
## <ManSection>
##   <Var Name="MPC_0"/>
##   <Var Name="MPC_1"/>
##   <Var Name="MPC_2"/>
##   <Var Name="MPC_M0"/>
##   <Var Name="MPC_M1"/>
##   <Var Name="MPC_INFINITY"/>
##   <Var Name="MPC_MINFINITY"/>
##   <Var Name="MPC_NAN"/>
##   <Oper Name="MPC_PI" Arg="precision"/>
##   <Oper Name="MPC_2PI" Arg="precision"/>
##   <Oper Name="MPC_EULER" Arg="precision"/>
##   <Oper Name="MPC_CATALAN" Arg="precision"/>
##   <Oper Name="MPC_LOG2" Arg="precision"/>
##   <Description>
##     These variables/functions store mathematical constants.
##
##     <P/> The argument <A>precision</A> specifies the desired precision
##     in bits.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalVariable("MPC");
#############################################################################

#############################################################################
##
#O Constructor
##
DeclareOperation("MPCFloat", [IsObject]);
DeclareOperation("MPCFloat", [IsObject,IsObject]);
#############################################################################

#############################################################################
##
#E
