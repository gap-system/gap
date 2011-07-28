#############################################################################
##
#W present.gd              POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of 
## pcp-presentations for matrix groups
##
#H  @(#)$Id: present.gd,v 1.2 2011/05/31 13:10:57 gap Exp $
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

DeclareGlobalFunction( "POL_IsMatGroupOverFiniteField" );
          
#############################################################################
##
#E
