#############################################################################
##
#W solvalble.gi           POLENTA package                     Bjoern Assmann
##
## Methods for testing if a matrix group
## is solvable or polycyclic
##
#H  @(#)$Id: solvable.gd,v 1.8 2011/09/23 13:36:33 gap Exp $
##
#Y 2003
##

#############################################################################
##
#M IsPolycyclicMatGroup( G )
##
## G is a matrix group, test whether it is polycyclic.
##
## TODO: Mark this as deprecated and eventually remove it; code using it
## should be changed to use IsPolycyclicGroup.
##
DeclareOperation( "IsPolycyclicMatGroup", [ IsMatrixGroup ] );

#############################################################################
##
#M IsTriangularizableMatGroup( G )
##
## G is a matrix group over the Rationals.
##
DeclareProperty( "IsTriangularizableMatGroup", IsMatrixGroup );

#############################################################################
##
#E
