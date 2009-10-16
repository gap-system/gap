#############################################################################
##
#W  transemi.gd           GAP library                    Robert Arthur
##
#H  @(#)$Id: transemi.gd,v 1.8 2002/09/09 11:38:32 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations specific to transformation monoids.
##  For information regarding the algorithms used here, refer to
##

Revision.transemi :=
    "@(#)$Id: transemi.gd,v 1.8 2002/09/09 11:38:32 gap Exp $";

DeclareOperation("GreensHClasses", 
    [IsGreensRClass and IsTransformationCollection]);
DeclareOperation("GreensHClasses", 
    [IsGreensLClass and IsTransformationCollection]);
DeclareOperation("GreensHClasses", 
    [IsGreensDClass and IsTransformationCollection]);

DeclareOperation("GreensRClasses",
    [IsGreensDClass and IsTransformationCollection]);

DeclareOperation("GreensLClasses",
    [IsGreensDClass and IsTransformationCollection]);

#############################################################################
##
#A  ImagesTrans( <semigroup> )
#A  ImagePosTransSemi( <semigroup> )
#A  KernelsTransSemi( <semigroup> )
#A  RCRepsTransSemi( <semigroup> )
#A  LTransTransSemi( <semigroup> )
#A  OrbitClassesTransSemi( <semigroup> )
##
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
DeclareAttribute("GenSchutzenbergerGroup", IsGreensRClass and
    IsTransformationCollection);
DeclareAttribute("GenSchutzenbergerGroup", IsGreensLClass and
    IsTransformationCollection);
DeclareAttribute("GenSchutzenbergerGroup", IsGreensHClass and
    IsTransformationCollection);
DeclareAttribute("GenSchutzenbergerGroup", IsGreensDClass and
    IsTransformationCollection);

#############################################################################
##
#A  SchutzImages( <R> )
##
##	Given an R class <R> of a transformation semigroup, this attribute stores 
##  a list of all image sets of elements of <R>.
##  
##
DeclareAttribute("SchutzImages", IsGreensRClass 
	and IsTransformationCollection);

#############################################################################
##
#A  SchutzRMults( <R> )
##
##	Given an R class <R> of a transformation semigorup, with representative 
##  <x>, this stores a list of transformations, such that 
##  `x * SchutzRMults( R )[i]' has image set `SchutzImages( R )[i]'.
##
DeclareAttribute("SchutzRMults", IsGreensRClass and 
	IsTransformationCollection);

#############################################################################
##
#A  SchutzKernels( <L> )
##
##	Given an L class <L> of a transformation semigroup, this attribute stores
##  a list of all kernels of elements of <L>
##
DeclareAttribute("SchutzKernels", IsGreensLClass and 
	IsTransformationCollection);

#############################################################################
##
#A  SchutzLMults( <L> )
##
##	Given an L class <L> of a transformation semigroup, with representative
##  <x>, this stores a list of transformations, such that
##  `SchutzLMults( L )[i] * x' kas kernel `SchutzKernels( L )[i]'.
##
DeclareAttribute("SchutzLMults", IsGreensLClass and 
	IsTransformationCollection);

#############################################################################
##
#A  SchutzRCosets( <D> )
##
##  Given a D class <D> of a transformation semigroup, this attribute stores
##  a (right) traversal of the Schutzenberger group in the generalised
##  right schutzenberger group.
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

#############################################################################
##
#O  DisplayTransformationSemigroup( <S> )
##
##  Produces a convenient display of a transformation semigroup's DClass
##  structure.   Let <S> have degree $n$.   Then for each $r\leq n$, we
##  show all D classes of rank $n$.   
##
##  A regular D class with a single H class of size 120 appears as
##  \beginexample
##  *[H size = 120, 1 L classes, 1 R classes] 
##  \endexample
##  (the \* denoting regularity).
##
##  A non regular D class with singleton H classes, 15 L classes and 
##  1 R class appears as:
##  \beginexample
##  [H size = 1, 15 L classes (3 image types), 1 R classes (1 kernel types)]
##  \endexample
##  The \"(3 image types)\" means that each element of the D class has
##  one of 3 different image sets and for each of the three image sets, 
##  there are 5 L classes with that image set.
##  
##
DeclareOperation("DisplayTransformationSemigroup", 
    [IsTransformationSemigroup]);


#############################################################################
##
#E




