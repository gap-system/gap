#############################################################################
##
#W  grpramat.gd                 GAP Library                     Franz G"ahler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for matrix groups over the rationals
##
Revision.grpramat_gd :=
    "@(#)$Id$";

#############################################################################
##
#P  IsCyclotomicMatrixGroup( <G> )
##
IsCyclotomicMatrixGroup := IsCyclotomicCollCollColl and IsMatrixGroup;

#############################################################################
##
#P  IsRationalMatrixGroup( <G> )
##
##  tests whether all matrices in <G> have rational entries.
DeclareProperty("IsRationalMatrixGroup", IsCyclotomicMatrixGroup);

#############################################################################
##
#P  IsIntegralMatrixGroup( <G> )
##
##  tests whether all matrices in <G> have integer entries.
DeclareProperty("IsIntegralMatrixGroup", IsCyclotomicMatrixGroup);

#############################################################################
##
#A  InvariantLattice( G )
##
##  returns a Z-lattice that is invariant under the rational matrix group
##  <G>. It returns `fail' if the group is not unimodular.
DeclareAttribute( "InvariantLattice", IsCyclotomicMatrixGroup );



#############################################################################
##
#E  grpramat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
