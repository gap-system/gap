#############################################################################
##
#W solvalble.gi           POLENTA package                     Bjoern Assmann
##
## Methods for testing if a matrix group 
## is solvable or polycyclic
##
#H  @(#)$Id: solvable.gd,v 1.5 2011/05/31 13:10:58 gap Exp $
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
