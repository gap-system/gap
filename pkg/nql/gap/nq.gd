############################################################################
##
#W nq.gd			NQL				René Hartung
##
#H   @(#)$Id: nq.gd,v 1.6 2009/05/06 12:54:47 gap Exp $
##
Revision.("nql/gap/nq_gd"):=
  "@(#)$Id: nq.gd,v 1.6 2009/05/06 12:54:47 gap Exp $";


############################################################################
##
#I InfoClass
##
DeclareInfoClass( "InfoNQL" );

############################################################################
##
#O  NilpotentQuotient( <LpGroup>, <c> )
##
DeclareOperation( "NilpotentQuotient", [ IsLpGroup, IsPosInt ] );
#InstallImmediateMethod( NilpotentQuotient, [IsLpGroup,IsZero],
#  G-> PcpGroupByCollectorNC(FromTheLeftCollector(0)));

############################################################################
##
#O  NqEpimorphismNilpotentQuotient( <LpGroup>, <c> )
##
DeclareOperation( "NqEpimorphismNilpotentQuotient", [ IsLpGroup, IsPosInt ] );

############################################################################
##
#A  NilpotentQuotientSystem ( <LpGroup> )
##
## The largest nilpotent quotient system of an invariant LpGroup that has 
## been computed by InitQuotientSystem and ExtendQuotientSystem.
##
DeclareAttribute( "NilpotentQuotientSystem", IsLpGroup and
		  HasIsInvariantLPresentation and IsInvariantLPresentation);

############################################################################
##
#A  NilpotentQuotients( <LpGroup>)
##
## stores the nilpotent quotients known from the NilpotentQuotient- or from
## the NqEpimorphismNilpotentQuotient-method. The quotients are stored as
## epimorphisms from <LpGroup> onto the corresponding quotient.
##
DeclareAttribute( "NilpotentQuotients", IsLpGroup );

############################################################################
##
#F  NQL_LCS( <QS> )
##
## computes the lower central series of the nilpotent quotient represented
## by the weighted nilpotent quotient system <QS>.
##
DeclareGlobalFunction( "NQL_LCS" );

############################################################################
##
#A  LargestNilpotentQuotient( <LpGroup> )
##
## computes (and stores) the largest nilpotent quotient of the group 
## <LpGroup>. Note that this method will only terminate if <LpGroup> 
## has a largest nilpotent quotient.
##
DeclareAttribute( "LargestNilpotentQuotient", IsLpGroup );
