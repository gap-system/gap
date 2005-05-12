#############################################################################
##
#W  mgmhom.gd                    GAP library                  Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains declarations for magma homomorphisms.
##
Revision.mgmhom_gd:=
    "@(#)$Id$";

#############################################################################
##
#P  IsMagmaHomomorphism( <mapp> )
##
##  A `MagmaHomomorphism' is a total single valued mapping which respects 
##  multiplication.
## 
DeclareSynonymAttr( "IsMagmaHomomorphism",
	IsMapping and RespectsMultiplication );


#############################################################################
##
#F  MagmaHomomorphismByFunctionNC( <G>, <H>, <fn> ) 
##
##  Creates the homomorphism from G to H without checking
##  that <fn> is a homomorphism.
##
DeclareGlobalFunction( "MagmaHomomorphismByFunctionNC");

#############################################################################
##
#F  MagmaIsomorphismByFunctionsNC( <G>, <H>, <fn>, <inv> ) 
##
##  Creates the isomorphism from G to H without checking
##  that <fn> or <inv> are a homomorphisms or bijective or inverse.
##
DeclareGlobalFunction( "MagmaIsomorphismByFunctionsNC");


############################################################################
##
#O  NaturalHomomorphismByGenerators( <f>, <s> )
##
##  returns a mapping from the magma <f> with <n> generators to the
##  magma <s> with <n> generators, which maps the ith generator of <f> to the 
##  ith generator of <s>.
##
DeclareOperation("NaturalHomomorphismByGenerators",[IsMagma, IsMagma]);


#############################################################################
##
#E


