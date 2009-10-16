#############################################################################
##
#W  monotran.gd           GAP library                    Robert Arthur
##
#H  @(#)$Id: monotran.gd,v 1.2 1999/04/23 17:34:20 roberta Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations specific to transformation monoids.
##  For information regarding the algorithms used here, refer to
##

Revision.monotran_gd :=
    "@(#)$Id: monotran.gd,v 1.2 1999/04/23 17:34:20 roberta Exp $";

#############################################################################
##
#A  ImagesTrans( <semigroup> )
#A	ImagePosTransSemi( <semigroup> )
#A	KernelsTransSemi( <semigroup> )
#A	RCRepsTransSemi( <semigroup> )
#A	LTransTransSemi( <semigroup> )
#A  OrbitClassesTransSemi( <semigroup> )
##
##	Some book-keeping information used by the transformation semigroup
##  algorithms
##	
DeclareAttribute("ImagesTransSemi", IsTransformationSemigroup);
DeclareAttribute("ImagePosTransSemi",IsTransformationSemigroup);
DeclareAttribute("KernelsTransSemi", IsTransformationSemigroup);
DeclareAttribute("RCRepsTransSemi", IsTransformationSemigroup);
DeclareAttribute("LTransTransSemi", IsTransformationSemigroup);
DeclareAttribute("OrbitClassesTransSemi", IsTransformationSemigroup);

#############################################################################
##
#A  GenSchutzenbergerGroup( <G> ) 
##
##  This function unfolds the greens class <G>.   It determines (and returns)
##  the generalised Schutzenberger group of the representative of <G>.
##
DeclareAttribute("GenSchutzenbergerGroup", IsGreensClass and 
											IsTransformationCollection);

#############################################################################
##
#A  SchutzImages( <rclass> )
##
##	Attainable images for an R class.
##
DeclareAttribute("SchutzImages", IsGreensRClass and IsTransformationCollection);

#############################################################################
##
#A  SchutzRMults( <rclass> )
##
##	Right multipliers.
##
DeclareAttribute("SchutzRMults", IsGreensRClass and 
	IsTransformationCollection);

#############################################################################
##
#A	SchutzKernels( <lclass> )
##
##	Attainable kernels for an L class
##
DeclareAttribute("SchutzKernels", IsGreensLClass and 
	IsTransformationCollection);

#############################################################################
##
#A	SchutzLMults( <lclass> )
##
##	Left multipliers
##
DeclareAttribute("SchutzLMults", IsGreensLClass and 
	IsTransformationCollection);

#############################################################################
##
#A  SchutzRCosets( <dclass> )
##
##  The right cosets of <dclass> in a transformation monoid
##
DeclareAttribute("SchutzRCosets", IsGreensDClass and 
	IsTransformationCollection);

#############################################################################
##
#A  SchutzRClassInDClass( <dclass> )
#A  SchutzLClassInDClass( <dclass> )
##
##  Stores one R (resp L) class of a D class to avoid repetition of 
##  calculation.
##
DeclareAttribute("SchutzRClassInDClass", IsGreensDClass 
    and IsTransformationCollection);
DeclareAttribute("SchutzLClassInDClass", IsGreensDClass 
    and IsTransformationCollection);
