#############################################################################
##
#W  gprd.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.gprd_gd :=
    "@(#)$Id$";

#############################################################################
##
#F  DirectProduct(<G> {,<H> })
##
##  constructs the direct product of the groups given as arguments.
DeclareGlobalFunction( "DirectProduct" );

#############################################################################
##
#F  SubdirectProduct(<G> ,<H>, <Ghom>, <Hhom> )
##
##  constructs the subdirect product of <G> and <H> with respect to the
##  epimorphisms <Ghom> from <G> onto a group <A> and <Hhom> from <H> onto
##  the same group <H>.
DeclareOperation( "SubdirectProduct",
    [ IsGroup, IsGroup, IsGroupHomomorphism, IsGroupHomomorphism ] );

#############################################################################
##
#F  SemidirectProduct(<G>, <alpha>, <N> )
##
##  constructs the semidirect product of <N> with <G> acting via <alpha>.
DeclareOperation( "SemidirectProduct",
    [ IsGroup, IsGroupHomomorphism, IsGroup ] );


#############################################################################
##
#F  WreathProduct(<G>, <P> )
#F  WreathProduct(<G>, <H> [,<hom>] )
##
##  constructs the wreath product of <G> with the permutation group <P>
##  (acting on its `MovedPoints'). The
##  second usage constructs the wreath product of <G> with the image of <H>
##  under <hom> where <hom> must be a homomorphism from <H> into a
##  permutation group. If <hom> is not given, the regular representation of
##  <H> is taken.
## * Currently only the first usage is supported !*
DeclareOperation( "WreathProduct", [ IsObject, IsObject ] );

#############################################################################
##
#F  WreathProductProductAction(<G>, <H> )
##
##  for two permutation groups <G> and <H> this function constructs the
##  wreath product in product action.
DeclareGlobalFunction( "WreathProductProductAction" );

DeclareGlobalFunction( "DirectProductOfPermGroups" );
DeclareGlobalFunction( "DirectProductOfPcGroups" );
DeclareGlobalFunction( "DirectProductOfGroups" );
DeclareGlobalFunction( "InnerSubdirectProducts" );
DeclareGlobalFunction( "InnerSubdirectProducts2" );
DeclareGlobalFunction( "SubdirectProducts" );

#############################################################################
##
#A  DirectProductInfo( <G> )
##
DeclareAttribute( "DirectProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  SubdirectProductInfo( <G> )
##
DeclareAttribute( "SubdirectProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  SemidirectProductInfo( <G> )
##
DeclareAttribute( "SemidirectProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  WreathProductInfo( <G> )
##
DeclareAttribute( "WreathProductInfo", IsGroup, "mutable" );

#############################################################################
##
#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
