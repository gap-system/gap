#############################################################################
##
#W  type.g                      GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file defines the format of families and types.
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
POS_DATA_TYPE := 3;
POS_NUMB_TYPE := 4;
POS_FIRST_FREE_TYPE := 5;


#############################################################################
##
#F  NEW_TYPE_NEXT_ID  . . . . . . . . . . . . GAP integer numbering the types
##
NEW_TYPE_NEXT_ID := -(2^28);


#############################################################################
##

#F  NewCategoryKernel( <name>, <super>, <filter> )  . . create a new category
##
NewCategoryKernel := function ( name, super, cat )
    if not IS_IDENTICAL_OBJ( cat, IS_OBJECT ) then
        ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
        FILTERS[ FLAG1_FILTER( cat ) ] := cat;
        INFO_FILTERS[ FLAG1_FILTER( cat ) ] := 1;
        RANK_FILTERS[ FLAG1_FILTER( cat ) ] := 1;
        InstallTrueMethod( super, cat );
    fi;
    return cat;
end;


#############################################################################
##
#F  NewCategory( <name>, <super> )  . . . . . . . . . . create a new category
##
NewCategory := function ( name, super )
    local   cat;
    cat := NEW_FILTER( name );
    ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
    FILTERS[ FLAG1_FILTER( cat ) ] := cat;
    RANK_FILTERS[ FLAG1_FILTER( cat ) ] := 1;
    INFO_FILTERS[ FLAG1_FILTER( cat ) ] := 2;
    InstallTrueMethodNewFilter( super, cat );
    return cat;
end;


#############################################################################
##
#F  NewRepresentationKernel( <name>, <super>, <slots> [,<req>], <filter> )
##
NewRepresentationKernel := function ( arg )
    local   rep;
    if LEN_LIST(arg) = 4  then
        rep := arg[4];
    elif LEN_LIST(arg) = 5  then
        rep := arg[5];
    else
        Error("usage: NewRepresentation(<name>,<super>,<slots>[,<req>])");
    fi;
    ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) );
    FILTERS[ FLAG1_FILTER( rep ) ]       := rep;
    RANK_FILTERS[ FLAG1_FILTER( rep ) ] := 1;
    INFO_FILTERS[ FLAG1_FILTER( rep ) ] := 3;
    InstallTrueMethod( arg[2], rep );
    return rep;
end;


#############################################################################
##
#F  NewRepresentation( <name>, <super>, <slots> [,<req>] )  .  representation
##
NewRepresentation := function ( arg )
    local   rep;

    if LEN_LIST(arg) = 3  then
        rep := NEW_FILTER( arg[1] );
    elif LEN_LIST(arg) = 4  then
        rep := NEW_FILTER( arg[1] );
    else
        Error("usage: NewRepresentation(<name>,<super>,<slots>[,<req>])");
    fi;
    ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) );
    FILTERS[ FLAG1_FILTER( rep ) ] := rep;
    RANK_FILTERS[ FLAG1_FILTER( rep ) ] := 1;
    INFO_FILTERS[ FLAG1_FILTER( rep ) ] := 4;
    InstallTrueMethodNewFilter( arg[2], rep );
    return rep;
end;

#############################################################################
##

#R  IsInternalRep
##
IsInternalRep := NewRepresentation(
    "IsInternalRep",
    IS_OBJECT, [], IS_OBJECT );


#############################################################################
##
#R  IsPositionalObjectRep
##
IsPositionalObjectRep := NewRepresentation(
    "IsPositionalObjectRep",
    IS_OBJECT, [], IS_OBJECT );


#############################################################################
##
#R  IsComponentObjectRep
##
IsComponentObjectRep := NewRepresentation(
    "IsComponentObjectRep",
    IS_OBJECT, [], IS_OBJECT );


#############################################################################
##
#R  IsDataObjectRep
##
IsDataObjectRep := NewRepresentation(
    "IsDataObjectRep",
    IS_OBJECT, [], IS_OBJECT );


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
IsAttributeStoringRep := NewRepresentation(
    "IsAttributeStoringRep",
    IsComponentObjectRep, [], IS_OBJECT );


#############################################################################
##
##  attribute getter and setter methods for attribute storing rep
##
InstallAttributeFunction(
    function ( name, filter, getter, setter, tester, mutflag )
    InstallOtherMethod( getter,
        "system getter",
        true,
        [ IsAttributeStoringRep and tester ],
        2 * SUM_FLAGS,
        GETTER_FUNCTION(name) );
    end );

InstallAttributeFunction(
    function ( name, filter, getter, setter, tester, mutflag )
    if mutflag then
        InstallOtherMethod( setter,
            "system mutable setter",
            true,
            [ IsAttributeStoringRep,
              IS_OBJECT ],
            SUM_FLAGS,
            function ( obj, val )
                obj!.(name) := val;
                SetFilterObj( obj, tester );
            end );
    else
        InstallOtherMethod( setter,
            "system setter",
            true,
            [ IsAttributeStoringRep,
              IS_OBJECT ],
            SUM_FLAGS,
            SETTER_FUNCTION( name, tester ) );
    fi;
    end );


#############################################################################
##
##  create the family of all families and the family of all types
##
EMPTY_FLAGS             := FLAGS_FILTER( IS_OBJECT );

IsFamily                := NewCategory( "IsFamily"          , IS_OBJECT );
IsType                  := NewCategory( "IsType"            , IS_OBJECT );
IsFamilyOfFamilies      := NewCategory( "IsFamilyOfFamilies", IsFamily );
IsFamilyOfTypes         := NewCategory( "IsFamilyOfTypes"   , IsFamily );

IsFamilyDefaultRep      := NewRepresentation( "IsFamilyDefaultRep",
                            IsComponentObjectRep,
#T why not `IsAttributeStoringRep' ?
                            "NAME,REQ_FLAGS,IMP_FLAGS,TYPES,TYPES_LIST_FAM",
                            IsFamily );

IsTypeDefaultRep        := NewRepresentation( "IsTypeDefaultRep",
                            IsPositionalObjectRep,
                            "", IsType );

FamilyOfFamilies        := rec();

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
TypeOfFamilies          := [
    FamilyOfFamilies,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamily and IsFamilyDefaultRep ) ),
    false,
    NEW_TYPE_NEXT_ID ];

FamilyOfFamilies!.NAME          := "FamilyOfFamilies";
FamilyOfFamilies!.REQ_FLAGS     := FLAGS_FILTER( IsFamily );
FamilyOfFamilies!.IMP_FLAGS     := EMPTY_FLAGS;
FamilyOfFamilies!.TYPES         := [];
FamilyOfFamilies!.TYPES_LIST_FAM:= [,,,,,,,,,,,,false]; # list with 12 holes

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
TypeOfFamilyOfFamilies  := [
      FamilyOfFamilies,
      WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfFamilies and IsFamilyDefaultRep 
                                   and IsAttributeStoringRep
                                    ) ),
    false,
    NEW_TYPE_NEXT_ID ];

FamilyOfTypes           := rec();

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
TypeOfTypes := [
    FamilyOfTypes,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsType and IsTypeDefaultRep ) ),
    false,
    NEW_TYPE_NEXT_ID ];

FamilyOfTypes!.NAME             := "FamilyOfTypes";
FamilyOfTypes!.REQ_FLAGS        := FLAGS_FILTER( IsType   );
FamilyOfTypes!.IMP_FLAGS        := EMPTY_FLAGS;
FamilyOfTypes!.TYPES            := [];
FamilyOfTypes!.TYPES_LIST_FAM   := [,,,,,,,,,,,,false]; # list with 12 holes

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
CATEGORIES_FAMILY := [];

CategoryFamily  := function ( elms_filter )
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
    fam_filter := NewCategory( name, super );
    ADD_LIST( CATEGORIES_FAMILY, [ elms_filter, fam_filter ] );
    return fam_filter;
end;


#############################################################################
##
#F  NewFamily( <name>, ... )
##
Subtype := "defined below";


NEW_FAMILY := function ( typeOfFamilies, name, req_filter, imp_filter )
    local   type, pair, family;

    # Look whether the category of the desired family can be improved
    # using the categories defined by 'CategoryFamily'.
    imp_filter := WITH_IMPS_FLAGS( AND_FLAGS( imp_filter, req_filter ) );
    type := Subtype( typeOfFamilies, IsAttributeStoringRep );
    for pair in CATEGORIES_FAMILY do
        if IS_SUBSET_FLAGS( imp_filter, pair[1] ) then
            type:= Subtype( type, pair[2] );
        fi;
    od;

    # cannot use 'Objectify', because 'IsList' may not be defined yet
    family := rec();
    SET_TYPE_COMOBJ( family, type );
    family!.NAME            := name;
    family!.REQ_FLAGS       := req_filter;
    family!.IMP_FLAGS       := imp_filter;
    family!.TYPES           := [];
    family!.TYPES_LIST_FAM  := [,,,,,,,,,,,,false]; # list with 12 holes
    return family;
end;


NewFamily2 := function ( typeOfFamilies, name )
    return NEW_FAMILY( typeOfFamilies,
                       name,
                       EMPTY_FLAGS,
                       EMPTY_FLAGS );
end;


NewFamily3 := function ( typeOfFamilies, name, req )
    return NEW_FAMILY( typeOfFamilies,
                       name,
                       FLAGS_FILTER( req ),
                       EMPTY_FLAGS );
end;


NewFamily4 := function ( typeOfFamilies, name, req, imp )
    return NEW_FAMILY( typeOfFamilies,
                       name,
                       FLAGS_FILTER( req ),
                       FLAGS_FILTER( imp ) );
end;


NewFamily5 := function ( typeOfFamilies, name, req, imp, filter )
    return NEW_FAMILY( Subtype( typeOfFamilies, filter ),
                       name,
                       FLAGS_FILTER( req ),
                       FLAGS_FILTER( imp ) );
end;


NewFamily := function ( arg )

    # NewFamily( <name> )
    if LEN_LIST(arg) = 1  then
        return NewFamily2( TypeOfFamilies, arg[1] );

    # NewFamily( <name>, <req-filter> )
    elif LEN_LIST(arg) = 2 then
        return NewFamily3( TypeOfFamilies, arg[1], arg[2] );

    # NewFamily( <name>, <req-filter>, <imp-filter> )
    elif LEN_LIST(arg) = 3  then
        return NewFamily4( TypeOfFamilies, arg[1], arg[2], arg[3] );

    # NewFamily( <name>, <req-filter>, <imp-filter>, <family-filter> )
    elif LEN_LIST(arg) = 4  then
        return NewFamily5( TypeOfFamilies, arg[1], arg[2], arg[3], arg[4] );

    # signal error
    else
        Error( "usage: NewFamily( <name>, [ <req> [, <imp> ]] )" );
    fi;

end;


#############################################################################
##
#M  PrintObj( <fam> )
##
InstallOtherMethod( PRINT_OBJ,
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
#F  NewType( <family>, <filter> [,<data>] )
##
NEW_TYPE_CACHE_MISS  := 0;
NEW_TYPE_CACHE_HIT   := 0;

NEW_TYPE := function ( typeOfTypes, family, flags, data )
    local   hash,  cache,  cached,  type;

    # maybe it is in the type cache
    hash  := HASH_FLAGS(flags) mod 3001 + 1;
    cache := family!.TYPES;
    if IsBound( cache[hash] )  then
        cached := cache[hash];
        if IS_EQUAL_FLAGS( flags, cached![2] )  then
            if    IS_IDENTICAL_OBJ(  data,  cached![ POS_DATA_TYPE ] )
              and IS_IDENTICAL_OBJ(  typeOfTypes, TYPE_OBJ(cached) )
            then
                NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1;
                return cached;
            else
                flags := cached![2];
            fi;
        fi;
        NEW_TYPE_CACHE_MISS := NEW_TYPE_CACHE_MISS + 1;
    fi;

    # get next type id
    NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID + 1;
    if TNUM_OBJ(NEW_TYPE_NEXT_ID)[1] <> 0  then
        Error( "too many types" );
    fi;

    # make the new type
    # cannot use 'Objectify', because 'IsList' may not be defined yet
    type := [ family, flags ];
    type[POS_DATA_TYPE] := data;
    type[POS_NUMB_TYPE] := NEW_TYPE_NEXT_ID;

    SET_TYPE_POSOBJ( type, typeOfTypes );
    cache[hash] := type;

    # return the type
    return type;
end;


NewType2 := function ( typeOfTypes, family )
    return NEW_TYPE( typeOfTypes,
                     family,
                     family!.IMP_FLAGS,
                     false );
end;


NewType3 := function ( typeOfTypes, family, filter )
    return NEW_TYPE( typeOfTypes,
                     family,
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        family!.IMP_FLAGS,
                        FLAGS_FILTER(filter) ) ),
                     false );
end;


NewType4 := function ( typeOfTypes, family, filter, data )
    return NEW_TYPE( typeOfTypes,
                     family,
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        family!.IMP_FLAGS,
                        FLAGS_FILTER(filter) ) ),
                     data );
end;


NewType5 := function ( typeOfTypes, family, filter, data, stuff )
    local   type;
    type := NEW_TYPE( typeOfTypes,
                      family,
                      WITH_IMPS_FLAGS( AND_FLAGS(
                         family!.IMP_FLAGS,
                         FLAGS_FILTER(filter) ) ),
                      data );
    type![ POS_FIRST_FREE_TYPE ] := stuff;
#T really ??
    return type;
end;


NewType := function ( arg )
    local   type;

    # check the argument
    if not IsFamily( arg[1] )  then
        Error("<family> must be a family");
    fi;

    # only one argument (why would you want that?)
    if LEN_LIST(arg) = 1  then
        type := NewType2( TypeOfTypes, arg[1] );

    # NewType( <family>, <filter> )
    elif LEN_LIST(arg) = 2  then
        type := NewType3( TypeOfTypes, arg[1], arg[2] );

    # NewType( <family>, <filter>, <data> )
    elif LEN_LIST(arg) = 3  then
        type := NewType4( TypeOfTypes, arg[1], arg[2], arg[3] );

    # NewType( <family>, <filter>, <data>, <stuff> )
    elif LEN_LIST(arg) = 4  then
        type := NewType5( TypeOfTypes, arg[1], arg[2], arg[3], arg[4] );

    # otherwise signal an error
    else
        Error("usage: NewType( <family> [, <filter> [, <data> ]] )");

    fi;

    # return the new type
    return type;
end;


#############################################################################
##
#M  PrintObj( <type> )
##
InstallOtherMethod( PRINT_OBJ,
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
#F  Subtype( <type>, <filter> )
##
Subtype2 := function ( type, filter )
    local   new, i;
    new := NEW_TYPE( TypeOfTypes,
                     type![1],
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        type![2],
                        FLAGS_FILTER( filter ) ) ),
                     type![ POS_DATA_TYPE ] );
    for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do
        if IsBound( type![i] ) then
            new![i] := type![i];
        fi;
    od;
    return new;
end;


Subtype3 := function ( type, filter, data )
    local   new, i;
    new := NEW_TYPE( TypeOfTypes,
                     type![1],
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        type![2],
                        FLAGS_FILTER( filter ) ) ),
                     data );
    for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do
        if IsBound( type![i] ) then
            new![i] := type![i];
        fi;
    od;
    return new;
end;


Subtype := function ( arg )

    # check argument
    if not IsType( arg[1] )  then
        Error("<type> must be a type");
    fi;

    # delegate
    if LEN_LIST(arg) = 2  then
        return Subtype2( arg[1], arg[2] );
    else
        return Subtype3( arg[1], arg[2], arg[3] );
    fi;

end;


#############################################################################
##
#F  SupType( <type>, <filter> )
##
SupType2 := function ( type, filter )
    local   new, i;
    new := NEW_TYPE( TypeOfTypes,
                     type![1],
                     SUB_FLAGS(
                        type![2],
                        FLAGS_FILTER( filter ) ),
                     type![ POS_DATA_TYPE ] );
    for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do
        if IsBound( type![i] ) then
            new![i] := type![i];
        fi;
    od;
    return new;
end;


SupType3 := function ( type, filter, data )
    local   new, i;
    new := NEW_TYPE( TypeOfTypes,
                     type![1],
                     SUB_FLAGS(
                        type![2],
                        FLAGS_FILTER( filter ) ),
                     data );
    for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( type ) ] do
        if IsBound( type![i] ) then
            new![i] := type![i];
        fi;
    od;
    return new;
end;


SupType := function ( arg )

    # check argument
    if not IsType( arg[1] )  then
        Error("<type> must be a type");
    fi;

    # delegate
    if LEN_LIST(arg) = 2  then
        return SupType2( arg[1], arg[2] );
    else
        return SupType3( arg[1], arg[2], arg[3] );
    fi;

end;


#############################################################################
##
#F  FamilyType( <K> ) . . . . . . . . . . . . family of objects with type <K>
##
FamilyType := function ( K )
    return K![1];
end;


#############################################################################
##
#F  FlagsType( <K> )  . . . . . . . . . . . .  flags of objects with type <K>
##
FlagsType := function ( K )
    return K![2];
end;


#############################################################################
##
#F  DataType( <K> ) . . . . . . . . . . . . . . defining data of the type <K>
#F  SetDataType( <K>, <data> )  . . . . . . set defining data of the type <K>
##
DataType := function ( K )
    return K![ POS_DATA_TYPE ];
end;

SetDataType := function ( K, data )
    K![ POS_DATA_TYPE ]:= data;
end;


#############################################################################
##
#F  SharedType( <K> ) . . . . . . . . . . . . . . shared data of the type <K>
##
SharedType := function ( K )
    return K![ POS_DATA_TYPE ];
end;


#############################################################################
##
#F  TypeObj( <obj> )  . . . . . . . . . . . . . . . . . . . type of an object
##
TypeObj := TYPE_OBJ;


#############################################################################
##
#F  FamilyObj( <obj> )  . . . . . . . . . . . . . . . . . family of an object
##
FamilyObj := FAMILY_OBJ;


#############################################################################
##
#F  FlagsObj( <obj> ) . . . . . . . . . . . . . . . . . .  flags of an object
##
FlagsObj := function ( obj )
    return FlagsType( TypeObj( obj ) );
end;


#############################################################################
##
#F  DataObj( <obj> )  . . . . . . . . . . . . . .  defining data of an object
##
DataObj := function ( obj )
    return DataType( TypeObj( obj ) );
end;


#############################################################################
##
#F  SharedObj( <obj> )  . . . . . . . . . . . . . .  shared data of an object
##
SharedObj := function ( obj )
    return SharedType( TypeObj( obj ) );
end;


#############################################################################
##
#F  SetTypeObj( <type>, <obj> )
##
SetTypeObj := function ( type, obj )
    if not IsType( type )  then
        Error("<type> must be a type");
    fi;
    if IS_LIST( obj )  then
        SET_TYPE_POSOBJ( obj, type );
    elif IS_REC( obj )  then
        SET_TYPE_COMOBJ( obj, type );
    fi;
    RunImmediateMethods( obj, type![2] );
    return obj;
end;

Objectify := SetTypeObj;


#############################################################################
##
#F  ChangeTypeObj( <type>, <obj> )
##
ChangeTypeObj := function ( type, obj )
    if not IsType( type )  then
        Error("<type> must be a type");
    fi;
    if IS_POSOBJ( obj )  then
        SET_TYPE_POSOBJ( obj, type );
    elif IS_COMOBJ( obj )  then
        SET_TYPE_COMOBJ( obj, type );
    elif IS_DATOBJ( obj )  then
        SET_TYPE_DATOBJ( obj, type );
    fi;
    RunImmediateMethods( obj, type![2] );
    return obj;
end;

ReObjectify := ChangeTypeObj;


#############################################################################
##
#F  SetFilterObj( <obj>, <filter>, <val> )
##
SetFilterObj := function ( obj, filter )
    if IS_POSOBJ( obj ) then
        SET_TYPE_POSOBJ( obj, Subtype2( TYPE_OBJ(obj), filter ) );
        RunImmediateMethods( obj, FLAGS_FILTER( filter ) );
    elif IS_COMOBJ( obj ) then
        SET_TYPE_COMOBJ( obj, Subtype2( TYPE_OBJ(obj), filter ) );
        RunImmediateMethods( obj, FLAGS_FILTER( filter ) );
    elif IS_DATOBJ( obj ) then
        SET_TYPE_DATOBJ( obj, Subtype2( TYPE_OBJ(obj), filter ) );
        RunImmediateMethods( obj, FLAGS_FILTER( filter ) );
    else
        Error("cannot set filter for internal object");
    fi;
end;

SET_FILTER_OBJ := SetFilterObj;


#############################################################################
##
#F  ResetFilterObj( <obj>, <filter> )
##
ResetFilterObj := function ( obj, filter )
    if IS_POSOBJ( obj ) then
        SET_TYPE_POSOBJ( obj, SupType2( TYPE_OBJ(obj), filter ) );
    elif IS_COMOBJ( obj ) then
        SET_TYPE_COMOBJ( obj, SupType2( TYPE_OBJ(obj), filter ) );
    elif IS_DATOBJ( obj ) then
        SET_TYPE_DATOBJ( obj, SupType2( TYPE_OBJ(obj), filter ) );
    else
        Error("cannot reset filter for internal object");
    fi;
end;

RESET_FILTER_OBJ := ResetFilterObj;


#############################################################################
##
#F  SetFeatureObj( <obj>, <filter>, <val> )
##
SetFeatureObj := function ( obj, filter, val )
    if val then
        SetFilterObj( obj, filter );
    else
        ResetFilterObj( obj, filter );
    fi;
end;


#############################################################################
##
#F  InstallMethodsFunction2( <list> ) . . . . . . function to install methods
##
InstallMethodsFunction2 := function( list )
    return
        function( to, from, func )
            ADD_LIST( list, [ FLAGS_FILTER(to), FLAGS_FILTER(from), func ] );
        end;
end;


#############################################################################
##
#F  RunMethodsFunction2( <list> ) . . . . func to run through install methods
##
RunMethodsFunction2 := function( list )

    return
        function( sup, sub )
            local   done,  fsup,  fsub,  i,  tmp;

            done := [];
            fsup := TypeObj(sup)![2];
            fsub := TypeObj(sub)![2];

            i := 1;
            while i <= LEN_LIST(list)  do
                if not i in done  then
                    if IS_SUBSET_FLAGS( fsup, list[i][1] )  then
                        if IS_SUBSET_FLAGS( fsub, list[i][2] )  then
                            ADD_SET( done, i );
                            list[i][3]( sup, sub );
                            tmp := TypeObj(sub)![2];
                            if tmp = fsub  then
                                i := i + 1;
                            else
                                i := 1;
                            fi;
                        else
                            i := i + 1;
                        fi;
                    else
                        ADD_SET( done, i );
                        i := i + 1;
                    fi;
                else
                    i := i + 1;
                fi;
            od;
        end;
end;


#############################################################################
##

#E  type.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
