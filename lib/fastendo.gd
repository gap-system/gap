#############################################################################
##
#W  fastendo.gd           GAP library                    Andrew Solomon
##
#H  @(#)$Id: fastendo.gd,v 4.2 2002/04/15 10:04:39 sal Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  Contains the declarations for the transformation representation
##  of endomorphisms. Computing with EndoGeneralMappings as transformations
##  makes the arithmetic much faster.
##
Revision.fastendo_gd :=
    "@(#)$Id: fastendo.gd,v 4.2 2002/04/15 10:04:39 sal Exp $";


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

