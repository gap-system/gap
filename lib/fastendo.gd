#############################################################################
##
#W  fastendo.gd           GAP library                    Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  Contains the declarations for the transformation representation
##  of endomorphisms. Computing with EndoGeneralMappings as transformations
##  makes the arithmetic much faster.
##
Revision.fastendo_gd :=
    "@(#)$Id$";


############################################################################
##
#A  TransformationRepresentation(<obj>)
##
##  This is the transformation representation of the endo general mapping 
##  <obj>. Note, it is still a general mapping, not a transformation,
##  however, composition, equality and \< are all *much* faster.
##
##  Finding the TransformationRepresentation requires a call to 
##  EnumeratorSorted for the Source of the mapping (the set on which
##  it acts). This could be very expensive.
##
DeclareAttribute("TransformationRepresentation", IsEndoMapping);

############################################################################
##
#E

