#############################################################################
##
#W  grpffmat.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for matrix groups over finite field.
##
Revision.grpffmat_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsFFEMatrixGroup
##
DeclareSynonym( "IsFFEMatrixGroup", IsFFECollCollColl and IsMatrixGroup );

#############################################################################
##
#M  IsFinite( <ffe-mat-grp> )
##
##  NOTE:    The following implication    only  holds  if  there no  infinite
##  dimensional matrices.
##
InstallTrueMethod( IsFinite,
    IsFFEMatrixGroup and IsFinitelyGeneratedGroup );

DeclareGlobalFunction( "NicomorphismOfFFEMatrixGroup" );

#############################################################################
##
#F  ProjectiveActionOnFullSpace(<G>,<f>,<n>)
##
##  returns the image of the projective acion of <G> on $<f>^<n>$, which
##  must be finite.
##
DeclareGlobalFunction("ProjectiveActionOnFullSpace");

#############################################################################
##
#F  ConjugacyClassesOfNaturalGroup 
##
DeclareGlobalFunction( "ConjugacyClassesOfNaturalGroup" );

#############################################################################
##
#E  grpffmat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
