#############################################################################
##
#W  grpfp.gd                    GAP library                    Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##
Revision.grpfp_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  InfoFpGroup
##
InfoFpGroup := NewInfoClass( "InfoFpGroup" );


#############################################################################
##
#C  IsFpGroup
##
IsFpGroup := NewCategory( "IsFpGroup", IsGroup );


#############################################################################
##
#C  IsElementOfFpGroup
##
IsElementOfFpGroup := NewCategory( "IsElementOfFpGroup",
    IsMultiplicativeElementWithInverse and IsAssociativeElement );


#############################################################################
##
#C  IsFamilyOfFpGroupElements
##
IsFamilyOfFpGroupElements := CategoryFamily( "IsFamilyOfFpGroupElements",
    IsElementOfFpGroup );


#############################################################################
##
#O  ElementOfFpGroup( <Fam>, <word> )
##
ElementOfFpGroup := NewConstructor( "ElementOfFpGroup",
    [ IsFamilyOfFpGroupElements, IsAssocWordWithInverse ] );


#############################################################################
##
#E  grpfp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



