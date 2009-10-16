#############################################################################
##
#W  pcpgrps.gd                   Polycyc                         Bettina Eick
##

#############################################################################
##
## Declare pcp groups as groups of pcp elements.
##
DeclareSynonym( "IsPcpGroup", IsGroup and IsPcpElementCollection );
InstallTrueMethod( IsPolycyclicGroup, IsPcpGroup );

#############################################################################
##
## An igs/ngs/cgs is an attribute of a pcp group.
##
DeclareAttribute( "Igs", IsPcpGroup );
DeclareAttribute( "Ngs", IsPcpGroup );
DeclareAttribute( "Cgs", IsPcpGroup );

#############################################################################
##
## Some global functions
##
DeclareGlobalFunction( "PcpGroupByCollectorNC" );
DeclareGlobalFunction( "PcpGroupByCollector" );
DeclareGlobalFunction( "LinearActionOnPcp" );

DeclareGlobalFunction( "SubgroupByIgs" );
