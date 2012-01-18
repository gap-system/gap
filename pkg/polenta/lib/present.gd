#############################################################################
##
#W present.gd              POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## pcp-presentations for matrix groups
##
#H  @(#)$Id: present.gd,v 1.4 2011/09/23 14:40:24 gap Exp $
##
#Y 2003
##

#############################################################################
##
#O PcpGroupByMatGroup( G )
##
DeclareOperation( "PcpGroupByMatGroup", [ IsMatrixGroup ] );

DeclareProperty( "IsIsomorphismByFinitePolycyclicMatrixGroup",
                  IsMapping);
DeclareProperty( "IsIsomorphismByPolycyclicMatrixGroup",
                  IsMapping);

#############################################################################
##
#E
