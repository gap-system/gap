#############################################################################
##
#W solvalble.gi           POLENTA package                     Bjoern Assmann
##
## Methods for testing if a matrix group 
## is solvable or polycyclic
##
#H  @(#)$Id: solvable.gd,v 1.4 2006/01/15 18:09:21 gap Exp $
##
#Y 2003
##

#############################################################################
##
#M IsPolycyclicMatGroup( G )
##
## G is a matrix group over the Rationals or a finite field. 
##
DeclareOperation( "IsPolycyclicMatGroup", [IsMatrixGroup] );

#############################################################################
##
#M IsTriangularizableMatGroup( G )
##
## G is a matrix group over the Rationals. 
##
DeclareOperation( "IsTriangularizableMatGroup", [ IsMatrixGroup ] ); 
     
#############################################################################
##
#E


