#############################################################################
##
#W  type.g                      GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file defines the format of families and types. Some functions 
##  are moved to type1.g, which is compiled
##
Revision.type_g :=
    "@(#)$Id$";


#############################################################################
##
#V  POS_DATA_TYPE . . . . . . . . position where the data of a type is stored
#V  POS_NUMB_TYPE . . . . . . . position where the number of a type is stored
#V  POS_FIRST_FREE_TYPE . . . . .  first position that has no overall meaning
##
##  Note that the family and the flags list are stored at positions 1 and 2,
##  respectively.
##
BIND_GLOBAL( "POS_DATA_TYPE", 3 );
BIND_GLOBAL( "POS_NUMB_TYPE", 4 );
BIND_GLOBAL( "POS_FIRST_FREE_TYPE", 5 );


#############################################################################
##
#F  NEW_TYPE_NEXT_ID  . . . . . . . . . . . . GAP integer numbering the types
##
NEW_TYPE_NEXT_ID := -(2^28);


#############################################################################
##

#F  DeclareCategoryKernel( <name>, <super>, <filter> )  create a new category
##
BIND_GLOBAL( "DeclareCategoryKernel", function ( name, super, cat )
    if not IS_IDENTICAL_OBJ( cat, IS_OBJECT ) then
        ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
        FILTERS[ FLAG1_FILTER( cat ) ] := cat;
        IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( cat ) );
        INFO_FILTERS[ FLAG1_FILTER( cat ) ] := 1;
        RANK_FILTERS[ FLAG1_FILTER( cat ) ] := 1;
        InstallTrueMethod( super, cat );
    fi;
    BIND_GLOBAL( name, cat );
end );


#############################################################################
##
#F  NewCategory( <name>, <super> )  . . . . . . . . . . create a new category
##
BIND_GLOBAL( "NewCategory", function ( name, super )
    local   cat;

    # Create the filter.
    cat := NEW_FILTER( name );
    InstallTrueMethodNewFilter( super, cat );

    # Do some administrational work.
    ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
    FILTERS[ FLAG1_FILTER( cat ) ] := cat;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( cat ) );
    RANK_FILTERS[ FLAG1_FILTER( cat ) ] := 1;
    INFO_FILTERS[ FLAG1_FILTER( cat ) ] := 2;

    # Return the filter.
    return cat;
end );


#############################################################################
##
#F  DeclareCategory( <name>, <super> )  . . . . . . . . create a new category
##
BIND_GLOBAL( "DeclareCategory", function ( name, super )
    BIND_GLOBAL( name, NewCategory( name, super ) );
end );


#############################################################################
##
#F  DeclareRepresentationKernel( <name>, <super>, <slots> [,<req>], <filt> )
##
BIND_GLOBAL( "DeclareRepresentationKernel", function ( arg )
    local   rep, filt;
    if REREADING then
        for filt in CATS_AND_REPS do
            if NAME_FUNC(FILTERS[filt]) = arg[1] then
                Print("#W DeclareRepresentationKernel \"",arg[1],"\" in Reread. ");
                Print("Change of Super-rep not handled\n");
                return FILTERS[filt];
            fi;
        od;
    fi;
    if LEN_LIST(arg) = 4  then
        rep := arg[4];
    elif LEN_LIST(arg) = 5  then
        rep := arg[5];
    else
        Error("usage:DeclareRepresentation(<name>,<super>,<slots>[,<req>])");
    fi;
    ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) );
    FILTERS[ FLAG1_FILTER( rep ) ]       := rep;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( rep ) );
    RANK_FILTERS[ FLAG1_FILTER( rep ) ] := 1;
    INFO_FILTERS[ FLAG1_FILTER( rep ) ] := 3;
    InstallTrueMethod( arg[2], rep );
    BIND_GLOBAL( arg[1], rep );
end );



#############################################################################
##
#F  NewRepresentation( <name>, <super>, <slots> [,<req>] )  .  representation
##
BIND_GLOBAL( "NewRepresentation", function ( arg )
    local   rep, filt;

    # Do *not* create a new representation when the file is reread.
    if REREADING then
        for filt in CATS_AND_REPS do
            if NAME_FUNC(FILTERS[filt]) = arg[1] then
                Print("#W NewRepresentation \"",arg[1],"\" in Reread. ");
                Print("Change of Super-rep not handled\n");
                return FILTERS[filt];
            fi;
        od;
    fi;

    # Create the filter.
    if LEN_LIST(arg) = 3  then
        rep := NEW_FILTER( arg[1] );
    elif LEN_LIST(arg) = 4  then
        rep := NEW_FILTER( arg[1] );
    else
        Error("usage:NewRepresentation(<name>,<super>,<slots>[,<req>])");
    fi;
    InstallTrueMethodNewFilter( arg[2], rep );

    # Do some administrational work.
    ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) );
    FILTERS[ FLAG1_FILTER( rep ) ] := rep;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( rep ) );
    RANK_FILTERS[ FLAG1_FILTER( rep ) ] := 1;
    INFO_FILTERS[ FLAG1_FILTER( rep ) ] := 4;

    # Return the filter.
    return rep;
end );


#############################################################################
##
#F  DeclareRepresentation( <name>, <super>, <slots> [,<req>] )
##
BIND_GLOBAL( "DeclareRepresentation", function ( arg )
    BIND_GLOBAL( arg[1], CALL_FUNC_LIST( NewRepresentation, arg ) );
end );



#############################################################################
##
#R  IsInternalRep
#R  IsPositionalObjectRep
#R  IsComponentObjectRep
#R  IsDataObjectRep
##
##  the four basic representations in {\GAP}
##
DeclareRepresentation( "IsInternalRep", IS_OBJECT, [], IS_OBJECT );
DeclareRepresentation( "IsPositionalObjectRep", IS_OBJECT, [], IS_OBJECT );
DeclareRepresentation( "IsComponentObjectRep", IS_OBJECT, [], IS_OBJECT );
DeclareRepresentation( "IsDataObjectRep", IS_OBJECT, [], IS_OBJECT );


#############################################################################
##
#R  IsAttributeStoringRep
##
##  Objects in this representation have default  methods to get the values of
##  stored  attributes  and -if they  are immutable-  to store the  values of
##  attributes after their computation.
##
##  The name of the  component that holds  the value of  an attribute is  the
##  name of the attribute, with the first letter turned to lower case.
#T This will be changed eventually, in order to avoid conflicts between
#T ordinary components and components corresponding to attributes.
##
DeclareRepresentation( "IsAttributeStoringRep",
    IsComponentObjectRep, [], IS_OBJECT );


#############################################################################
##
##  create the family of all families and the family of all types
##
BIND_GLOBAL( "EMPTY_FLAGS", FLAGS_FILTER( IS_OBJECT ) );

DeclareCategory( "IsFamily"          , IS_OBJECT );
DeclareCategory( "IsType"            , IS_OBJECT );
DeclareCategory( "IsFamilyOfFamilies", IsFamily );
DeclareCategory( "IsFamilyOfTypes"   , IsFamily );

DeclareRepresentation( "IsFamilyDefaultRep",
                            IsComponentObjectRep,
#T why not `IsAttributeStoringRep' ?
                            "NAME,REQ_FLAGS,IMP_FLAGS,TYPES,TYPES_LIST_FAM",
#T add nTypes, HASH_SIZE
                            IsFamily );

DeclareRepresentation( "IsTypeDefaultRep",
                            IsPositionalObjectRep,
                            "", IsType );

BIND_GLOBAL( "FamilyOfFamilies", rec() );

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
BIND_GLOBAL( "TypeOfFamilies", [
    FamilyOfFamilies,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamily and IsFamilyDefaultRep ) ),
    false,
    NEW_TYPE_NEXT_ID ] );

FamilyOfFamilies!.NAME          := "FamilyOfFamilies";
FamilyOfFamilies!.REQ_FLAGS     := FLAGS_FILTER( IsFamily );
FamilyOfFamilies!.IMP_FLAGS     := EMPTY_FLAGS;
FamilyOfFamilies!.TYPES         := [];
FamilyOfFamilies!.nTYPES          := 0;
FamilyOfFamilies!.HASH_SIZE       := 100;
FamilyOfFamilies!.TYPES_LIST_FAM:= [,,,,,,,,,,,,,,,,,,,,,,,,,,false]; # list with 26 holes

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
BIND_GLOBAL( "TypeOfFamilyOfFamilies", [
      FamilyOfFamilies,
      WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfFamilies and IsFamilyDefaultRep
                                   and IsAttributeStoringRep
                                    ) ),
    false,
    NEW_TYPE_NEXT_ID ] );

BIND_GLOBAL( "FamilyOfTypes", rec() );

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
BIND_GLOBAL( "TypeOfTypes", [
    FamilyOfTypes,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsType and IsTypeDefaultRep ) ),
    false,
    NEW_TYPE_NEXT_ID ] );

FamilyOfTypes!.NAME             := "FamilyOfTypes";
FamilyOfTypes!.REQ_FLAGS        := FLAGS_FILTER( IsType   );
FamilyOfTypes!.IMP_FLAGS        := EMPTY_FLAGS;
FamilyOfTypes!.TYPES            := [];
FamilyOfTypes!.nTYPES          := 0;
FamilyOfTypes!.HASH_SIZE       := 100;
FamilyOfTypes!.TYPES_LIST_FAM   :=
  [,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,false]; # list with 26 holes

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
TypeOfFamilyOfTypes     := [
    FamilyOfFamilies,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfTypes and IsTypeDefaultRep ) ),
    false,
    NEW_TYPE_NEXT_ID ];

SET_TYPE_COMOBJ( FamilyOfFamilies, TypeOfFamilyOfFamilies );
SET_TYPE_POSOBJ( TypeOfFamilies,   TypeOfTypes            );

SET_TYPE_COMOBJ( FamilyOfTypes,    TypeOfFamilyOfTypes    );
SET_TYPE_POSOBJ( TypeOfTypes,      TypeOfTypes            );


#############################################################################
##

#O  CategoryFamily( <elms_filter> ) . . . . . .  category of certain families
##
BIND_GLOBAL( "CATEGORIES_FAMILY", [] );

BIND_GLOBAL( "CategoryFamily", function ( elms_filter )
    local    pair, fam_filter, super, flags, name;

    name:= "CategoryFamily(";
    APPEND_LIST_INTR( name, SHALLOW_COPY_OBJ( NAME_FUNC( elms_filter ) ) );
    APPEND_LIST_INTR( name, ")" );
    CONV_STRING( name );

    elms_filter:= FLAGS_FILTER( elms_filter );

    # Check whether the desired family category is already defined.
    for pair in CATEGORIES_FAMILY do
      if pair[1] = elms_filter then
        return pair[2];
      fi;
    od;

    # Find the super category among the known family categories.
    super := IsFamily;
    flags := WITH_IMPS_FLAGS( elms_filter );
    for pair in CATEGORIES_FAMILY do
      if IS_SUBSET_FLAGS( flags, pair[1] ) then
        super := super and pair[2];
      fi;
    od;

    # Construct the family category.
    fam_filter:= NewCategory( name, super );
    ADD_LIST( CATEGORIES_FAMILY, [ elms_filter, fam_filter ] );
    return fam_filter;
end );


#############################################################################
##
#F  DeclareCategoryFamily( <name> )
##
##  creates the family category of the category that is bound to the global
##  variable with name <name>,
##  and binds it to the global variable with name `<name>Family'.
##
BIND_GLOBAL( "DeclareCategoryFamily", function( name )
    local nname;
    nname:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( nname, "Family" );
    BIND_GLOBAL( nname, CategoryFamily( VALUE_GLOBAL( name ) ) );
end );



#############################################################################
##
#M  PrintObj( <fam> )
##
InstallOtherMethod( PRINT_OBJ,
    "for a family",
    true,
    [ IsFamily ],
    0,

function ( family )
    local   req_flags, imp_flags;

    Print( "NewFamily( " );
    Print( "\"", family!.NAME, "\"" );
    req_flags := family!.REQ_FLAGS;
    Print( ", ", TRUES_FLAGS( req_flags ) );
    imp_flags := family!.IMP_FLAGS;
    if imp_flags <> []  then
        Print( ", ", TRUES_FLAGS( imp_flags ) );
    fi;
    Print( " )" );
end );



#############################################################################
##
#M  PrintObj( <type> )
##
InstallOtherMethod( PRINT_OBJ,
    "for a type",
    true,
    [ IsType ],
    0,

function ( type )
    local  family, flags, data;

    family := type![1];
    flags  := type![2];
    data   := type![ POS_DATA_TYPE ];
    Print( "NewType( ", family );
    if flags <> [] or data <> false then
        Print( ", " );
        Print( TRUES_FLAGS( flags ) );
        if data <> false then
            Print( ", " );
            Print( data );
        fi;
    fi;
    Print( " )" );
end );




#############################################################################
##
#E

