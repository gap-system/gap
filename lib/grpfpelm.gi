#############################################################################
##
#W  grpfpelm.gi                 GAP Library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the generic methods for elements of finitely presented
##  groups.
##
Revision.grpfpelm_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  ElementOfFpGroup( <fam>, <elm> )
##
InstallMethod( ElementOfFpGroup,
    true,
    [ IsFamilyOfFpGroupElements, IsAssocWordWithInverse ],
    0,
    function( fam, elm )
    return Objectify( fam!.defaultKind, [ Immutable( elm ) ] );
    end );


#############################################################################
##
#M  PrintObj( <elm> ) . . . . . . . for packed word in default representation
##
InstallMethod( PrintObj,
    true,
    [ IsPackedWordDefaultRep ],
    0,
    function( obj )
    Print( obj![1] );
    end );


#############################################################################
##
#M  UnderlyingElement( <elm> )  . . . . . . . . . . for element of f.p. group
##
InstallMethod( UnderlyingElement,
    true,
    [ IsElementOfFpGroup and IsPackedWordDefaultRep ],
    0,
    obj -> obj![1] );


#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( ExtRepOfObj,
    true,
    [ IsElementOfFpGroup and IsPackedWordDefaultRep ],
    0,
    obj -> ExtRepOfObj( obj![1] ) );


#############################################################################
##
#M  Inverse( <elm> )  . . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( Inverse,
    true,
    [ IsElementOfFpGroup ],
    0,
    obj -> ElementOfFpGroup( FamilyObj( obj ),
                             Inverse( UnderlyingElement( obj ) ) ) );


#############################################################################
##
#M  One( <fam> )  . . . . . . . . . . . . . for family of f.p. group elements
##
InstallOtherMethod( One,
    true,
    [ IsFamilyOfFpGroupElements ],
    0,
    fam -> ElementOfFpGroup( fam, One( fam!.freeGroup ) ) );


#############################################################################
##
#M  One( <elm> )  . . . . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( One,
    true,
    [ IsElementOfFpGroup ],
    0,
    obj -> One( FamilyObj( obj ) ) );


#############################################################################
##
#M  \*( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \*,
    IsIdentical,
    [ IsElementOfFpGroup,
      IsElementOfFpGroup ],
    0,
    function( left, right )
    local fam;
    fam:= FamilyObj( left );
    return ElementOfFpGroup( fam,
               UnderlyingElement( left ) * UnderlyingElement( right ) );
    end );


#############################################################################
##
#M  \=( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \=,
    IsIdentical,
    [ IsElementOfFpGroup,
      IsElementOfFpGroup ],
    0,
    function( left, right )
    Error( "not yet implemented" );
    end );


#############################################################################
##
#M  \<( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \<,
    IsIdentical,
    [ IsElementOfFpGroup,
      IsElementOfFpGroup ],
    0,
    function( left, right )
    Error( "not yet implemented" );
    end );


#############################################################################
##
#M  GeneratorsOfGroup( <F> )  . . . . . . . . . . . . . . .  for a f.p. group
##
InstallMethod( GeneratorsOfGroup,
    "method for whole family f.p. group",
    true,
    [ IsFpGroup and IsWholeFamily ],
    0,
    function( F )
    local Fam;
    Fam:= ElementsFamily( FamilyObj( F ) );
    return List( GeneratorsOfGroup( Fam!.freeGroup ),
                 g -> ElementOfFpGroup( Fam, g ) );
    end );


#############################################################################
##
#E  grpfpelm.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



