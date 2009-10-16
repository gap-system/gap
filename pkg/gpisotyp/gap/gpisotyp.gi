#############################################################################
##
#W  gpisotyp.gi          GAP 4 package `gpisotyp'               Thomas Breuer
##
#H  @(#)$Id: gpisotyp.gi,v 1.2 2002/05/13 15:43:29 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementations concerning isomorphism types of
##  groups.
##
##  1. General Isomomorphism Types
##  2. Equality and Comparison of Isomorphism Type Objects
##
Revision.( "gpisotyp/gap/gpisotyp_gi" ) :=
    "@(#)$Id: gpisotyp.gi,v 1.2 2002/05/13 15:43:29 gap Exp $";


#############################################################################
##  
##  1. General Isomomorphism Types
##


#############################################################################
##
#V  IsomorphismTypesFamily
##
InstallGlobalVariable( "IsomorphismTypesFamily",
    NewFamily( "IsomorphismTypesFamily", IsIsomorphismType ) );


#############################################################################
##  
##  2. Equality and Comparison of Isomorphism Type Objects
##
default method to compare isotypes with representatives for equality:

1. test invariants
2. if equal and IdGroup is available (*how to check this?*)
   for the groups of given order (and order is available?),
   call IdGroup
3. if equal, finally try IsomorphismGroups
...



#############################################################################
##
#V  AttributesOfIsomorphismTypeOfGroup
##
##  We initialize the list with all those names of operations for which
##  group isomorphism maintenances are installed via
##  `InstallIsomorphismMaintenance' (see~"InstallIsomorphismMaintenance").
##
InstallValue( AttributesOfIsomorphismTypeOfGroup,
    List( Filtered( ISOMORPHISM_MAINTAINED_INFO,
                    list -> IS_SUBSET_FLAGS( FLAGS_FILTER( list[1] ),
                                             FLAGS_FILTER( IsGroup ) ) ),
          list -> NAME_FUNC( list[3] ) ) );


#############################################################################
##
#V  AbstractIsomorphismTypesOfGroups
##
##
##
InstallValue( AbstractIsomorphismTypesOfGroups, [] );




#############################################################################
##
#F  DeclareAbstractIsomorphismType( <name>, <record> )
##
InstallGlobalFunction( "DeclareAbstractIsomorphismType",
    function( name, record )

    if not IsString( name ) or not IsRecord( record ) then
      Error( "<name> must be a string, <record> must be a record" );
    fi;

    isotype:= ShallowCopy( record );
    Objectify( NewType( IsomorphismTypesFamily,
                            IsIsomorphismTypeOfGroup
                            IsAbstractIsomorphismType
                        and IsAttributeStoringRep ),
               isotype );

    # Check that `record' is a record with either a representative
    # or at least one definition.
....

    # Set the attributes.
    SetIdentifier( isotype, name );
    for name in RecNames( record ) do
      if name in AttributesOfIsomorphismTypeOfGroup[1] then
better list only the names!
        Setter( ValueGlobal( name ) )( isotype, record.( name ) );
      fi;
    od;
    end );


#############################################################################
##
##  x. Print, View, String for Isomorphism Types
##

#############################################################################
##
#M  String( <isotype> )
##
InstallMethod( String,
    "for an abstract isomorphism type of a group",
    [ IsIsomorphismTypeOfGroup and IsAbstractIsomorphismType and HasIdentifier ],
    isotype -> Concatenation( [ "IsomorphismType( \"", Identifier( isotype ),
                                "\" )" ] ) );

#############################################################################
##
#M  PrintObj( <isotype> )
##
InstallMethod( PrintObj,
    "for an abstract isomorphism type of a group",
    [ IsIsomorphismTypeOfGroup and IsAbstractIsomorphismType and HasIdentifier ],
    function( isotype )
    Print( "IsomorphismType( \"", Identifier( isotype ), "\" )" );
    end );

InstallMethod( PrintObj,
    "for an isomorphism type with representative",
    [ IsIsomorphismType and HasRepresentative ],
    function( isotype )
    Print( "IsomorphismType( ", Representative( isotype ), " )" );
    end );


#############################################################################
##
#M  ViewObj( <isotype> )
##
InstallMethod( ViewObj,
    "for an isomorphism type of a group",
    [ IsIsomorphismTypeOfGroup ],
    function( isotype )
    Print( "<isomorphism type of a group>" );
    end );


#############################################################################
##
#A  IsomorphismType( <G> )
#A  IsomorphismType( <string> )
#A  IsomorphismType( <tbl> )
#A  IsomorphismType( <tom> )
##
InstallMethod( IsomorphismType,
    "for a group",
    [ IsGroup ],
    function( G )
    return Objectify( NewType( IsomorphismTypesFamily,
                                   IsIsomorphismTypeOfGroup
                               and IsAttributeStoringRep ),
                      rec() );
    end );


#############################################################################
##  
#M  KnownDefinitionsOfIsomorphismType( <isotype> )
##
InstallMethod( KnownDefinitionsOfIsomorphismType,
    [ IsIsomorphismType ],
    isotype -> [] );


#############################################################################
##
#A  StandardGeneratorsInfo( <isotype> )
##


#############################################################################
##
#E


#############################################################################
##
#V  DefiningConditionsOfIsomorphismTypes
##
...
##
InstallValue( DefiningConditionsOfIsomorphismTypes, [] );

Append( DefiningConditionsOfIsomorphismTypes,
    [ IsGroup, rec(
      IsPerfect:= IsPerfectGroup,
      IsSimple:= IsSimpleGroup,
      IsSolvable:= IsSolvableGroup,
      NrConjugacyClasses:= NrConjugacyClasses,
      Size:= Size,
      SizeOfCentre:= G -> Size( Centre( G ) )
      ) ] );

Append( DefiningConditionsOfIsomorphismTypes,
    [ IsCharacterTable, rec(
      IsPerfect:= IsPerfectCharacterTable,
      IsSimple:= IsSimpleCharacterTable,
      IsSolvable:= IsSolvableCharacterTable,
      NrConjugacyClasses:= NrConjugacyClasses,
      Size:= Size,
      SizeOfCentre:= tbl -> Length( ClassPositionsOfCentre( tbl ) )
      ) ] );

IsSimpleCentralFactorGroup

IsSimpleDerivedSubgroup

tables of marks!!


#############################################################################
##
##  For {\GAP} data libraries,
##  isomorphism types of *almost simple groups* are of great importance.
##  (The following declarations can be checked using the classification of finite
have been?
##  simple groups, via the function `SizesSimpleGroups'.
##
DeclareAbstractIsomorphismType("A5",
    rec(KnownDefinitionsOfIsomorphismType:=[["IsSimple",true,"Size",60]]));

how to distinguish A8 and L3(4)?

how to define S6, M10, J2.2, 2.A5?

["IsPerfect",true,"Size",120]

in calls to DeclareAbstractIsomorphismType,
reject if strings are used that are not defined at least for groups!

