#############################################################################
##
#W  kind.g                      GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file defines the format of families and kinds.
##
Revision.kind_g :=
    "@(#)$Id$";


#############################################################################
##

#F  NewCategory( <name>, <super> )
##
NewCategory := function ( name, super )
    local   cat;
    cat := NEW_FILTER( name );
    ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
    FILTERS[ FLAG1_FILTER( cat ) ]:= cat;
    InstallTrueMethod( super, cat );
    return cat;
end;

NewCategoryKernel := function ( name, super, cat )
    if not IS_IDENTICAL_OBJ( cat, IS_OBJECT ) then
        ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
        FILTERS[ FLAG1_FILTER( cat ) ]:= cat;
        InstallTrueMethod( super, cat );
    fi;
    return cat;
end;


#############################################################################
##
#F  NewRepresentation( <name>, <super>, <slots> [,<req>] )
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
    FILTERS[ FLAG1_FILTER( rep ) ]:= rep;
    InstallTrueMethod( arg[2], rep );
    return rep;
end;

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
    FILTERS[ FLAG1_FILTER( rep ) ]:= rep;
    InstallTrueMethod( arg[2], rep );
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
##  create the family of all families and the family of all kinds
##
EMPTY_FLAGS             := FLAGS_FILTER( IS_OBJECT );

IsFamily                := NewCategory( "IsFamily"          , IS_OBJECT );
IsKind                  := NewCategory( "IsKind"            , IS_OBJECT );
IsFamilyOfFamilies      := NewCategory( "IsFamilyOfFamilies", IsFamily );
IsFamilyOfKinds         := NewCategory( "IsFamilyOfKinds"   , IsFamily );

IsFamilyDefaultRep      := NewRepresentation( "IsFamilyDefaultRep",
                            IsComponentObjectRep,
                            "NAME,REQ_FLAGS,IMP_FLAGS,KINDS,KINDS_LIST_FAM",
                            IsFamily );

IsKindDefaultRep        := NewRepresentation( "IsKindDefaultRep",
                            IsPositionalObjectRep,
                            "", IsKind );

FamilyOfFamilies        := rec();

KindOfFamilies          := [
    FamilyOfFamilies,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamily and IsFamilyDefaultRep ) ),
    false ];

FamilyOfFamilies!.NAME          := "FamilyOfFamilies";
FamilyOfFamilies!.REQ_FLAGS     := FLAGS_FILTER( IsFamily );
FamilyOfFamilies!.IMP_FLAGS     := EMPTY_FLAGS;
FamilyOfFamilies!.KINDS         := [];
FamilyOfFamilies!.KINDS_LIST_FAM:= [,,,,,,,,,,,,false]; # list with 12 holes

KindOfFamilyOfFamilies  := [
      FamilyOfFamilies,
      WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfFamilies and IsFamilyDefaultRep 
                                   and IsAttributeStoringRep
                                    ) ),
    false ];

FamilyOfKinds           := rec();

KindOfKinds := [
    FamilyOfKinds,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsKind and IsKindDefaultRep ) ),
    false ];

FamilyOfKinds!.NAME             := "FamilyOfKinds";
FamilyOfKinds!.REQ_FLAGS        := FLAGS_FILTER( IsKind   );
FamilyOfKinds!.IMP_FLAGS        := EMPTY_FLAGS;
FamilyOfKinds!.KINDS            := [];
FamilyOfKinds!.KINDS_LIST_FAM   := [,,,,,,,,,,,,false]; # list with 12 holes

KindOfFamilyOfKinds     := [
    FamilyOfFamilies,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfKinds and IsKindDefaultRep ) ),
    false ];

SET_KIND_COMOBJ( FamilyOfFamilies, KindOfFamilyOfFamilies );
SET_KIND_POSOBJ( KindOfFamilies,   KindOfKinds            );

SET_KIND_COMOBJ( FamilyOfKinds,    KindOfFamilyOfKinds    );
SET_KIND_POSOBJ( KindOfKinds,      KindOfKinds            );


#############################################################################
##

#O  CategoryFamily( <name>, <elms_filter> ) . .  category of certain families
##
CATEGORIES_FAMILY := [];

CategoryFamily  := function ( name, elms_filter )
    local    pair, fam_filter, super, flags;

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
Subkind := "defined below";


NEW_FAMILY := function ( kindOfFamilies, name, req_filter, imp_filter )
    local   kind, pair, family;

    # Look whether the category of the desired family can be improved
    # using the categories defined by 'CategoryFamily'.
    imp_filter := WITH_IMPS_FLAGS( AND_FLAGS( imp_filter, req_filter ) );
    kind := Subkind( kindOfFamilies, IsAttributeStoringRep );
    for pair in CATEGORIES_FAMILY do
        if IS_SUBSET_FLAGS( imp_filter, pair[1] ) then
            kind:= Subkind( kind, pair[2] );
        fi;
    od;

    # cannot use 'Objectify', because 'IsList' may not be defined yet
    family := rec();
    SET_KIND_COMOBJ( family, kind );
    family!.NAME            := name;
    family!.REQ_FLAGS       := req_filter;
    family!.IMP_FLAGS       := imp_filter;
    family!.KINDS           := [];
    family!.KINDS_LIST_FAM  := [,,,,,,,,,,,,false]; # list with 12 holes
    return family;
end;


NewFamily2 := function ( kindOfFamilies, name )
    return NEW_FAMILY( kindOfFamilies,
                       name,
                       EMPTY_FLAGS,
                       EMPTY_FLAGS );
end;


NewFamily3 := function ( kindOfFamilies, name, req )
    return NEW_FAMILY( kindOfFamilies,
                       name,
                       FLAGS_FILTER( req ),
                       EMPTY_FLAGS );
end;


NewFamily4 := function ( kindOfFamilies, name, req, imp )
    return NEW_FAMILY( kindOfFamilies,
                       name,
                       FLAGS_FILTER( req ),
                       FLAGS_FILTER( imp ) );
end;


NewFamily5 := function ( kindOfFamilies, name, req, imp, filter )
    return NEW_FAMILY( Subkind( kindOfFamilies, filter ),
                       name,
                       FLAGS_FILTER( req ),
                       FLAGS_FILTER( imp ) );
end;


NewFamily := function ( arg )

    # NewFamily( <name> )
    if LEN_LIST(arg) = 1  then
        return NewFamily2( KindOfFamilies, arg[1] );

    # NewFamily( <name>, <req-filter> )
    elif LEN_LIST(arg) = 2 then
        return NewFamily3( KindOfFamilies, arg[1], arg[2] );

    # NewFamily( <name>, <req-filter>, <imp-filter> )
    elif LEN_LIST(arg) = 3  then
        return NewFamily4( KindOfFamilies, arg[1], arg[2], arg[3] );

    # NewFamily( <name>, <req-filter>, <imp-filter>, <family-filter> )
    elif LEN_LIST(arg) = 4  then
        return NewFamily5( KindOfFamilies, arg[1], arg[2], arg[3], arg[4] );

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
#F  NewKind( <family>, <filter> [,<data>] )
##
NEW_KIND_CACHE_MISS  := 0;
NEW_KIND_CACHE_HIT   := 0;

NEW_KIND := function ( kindOfKinds, family, flags, data )
    local   hash,  cache,  cached,  kind;

    # maybe it is in the kind cache
    hash  := HASH_FLAGS(flags) mod 3001 + 1;
    cache := family!.KINDS;
    if IsBound( cache[hash] )  then
        cached := cache[hash];
        if IS_EQUAL_FLAGS( flags, cached![2] )  then
            if    IS_IDENTICAL_OBJ(  data,  cached![3] )
              and IS_IDENTICAL_OBJ(  kindOfKinds, KIND_OBJ(cached) )
            then
                NEW_KIND_CACHE_HIT := NEW_KIND_CACHE_HIT + 1;
                return cached;
            else
                flags := cached![2];
            fi;
        fi;
        NEW_KIND_CACHE_MISS := NEW_KIND_CACHE_MISS + 1;
    fi;

    # make the new kind
    # cannot use 'Objectify', because 'IsList' may not be defined yet
    kind := [ family, flags, data ];
    SET_KIND_POSOBJ( kind, kindOfKinds );
    cache[hash] := kind;

    # return the kind
    return kind;
end;


NewKind2 := function ( kindOfKinds, family )
    return NEW_KIND( kindOfKinds,
                     family,
                     family!.IMP_FLAGS,
                     false );
end;


NewKind3 := function ( kindOfKinds, family, filter )
    return NEW_KIND( kindOfKinds,
                     family,
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        family!.IMP_FLAGS,
                        FLAGS_FILTER(filter) ) ),
                     false );
end;


NewKind4 := function ( kindOfKinds, family, filter, data )
    return NEW_KIND( kindOfKinds,
                     family,
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        family!.IMP_FLAGS,
                        FLAGS_FILTER(filter) ) ),
                     data );
end;


NewKind5 := function ( kindOfKinds, family, filter, data, stuff )
    local   kind;
    kind := NEW_KIND( kindOfKinds,
                      family,
                      WITH_IMPS_FLAGS( AND_FLAGS(
                         family!.IMP_FLAGS,
                         FLAGS_FILTER(filter) ) ),
                      data );
    kind![4] := stuff;
    return kind;
end;


NewKind := function ( arg )
    local   kind;

    # check the argument
    if not IsFamily( arg[1] )  then
        Error("<family> must be a family");
    fi;

    # only one argument (why would you want that?)
    if LEN_LIST(arg) = 1  then
        kind := NewKind2( KindOfKinds, arg[1] );

    # NewKind( <family>, <filter> )
    elif LEN_LIST(arg) = 2  then
        kind := NewKind3( KindOfKinds, arg[1], arg[2] );

    # NewKind( <family>, <filter>, <data> )
    elif LEN_LIST(arg) = 3  then
        kind := NewKind4( KindOfKinds, arg[1], arg[2], arg[3] );

    # NewKind( <family>, <filter>, <data>, <stuff> )
    elif LEN_LIST(arg) = 4  then
        kind := NewKind5( KindOfKinds, arg[1], arg[2], arg[3], arg[4] );

    # otherwise signal an error
    else
        Error("usage: NewKind( <family> [, <filter> [, <data> ]] )");

    fi;

    # return the new kind
    return kind;
end;


#############################################################################
##
#M  PrintObj( <kind> )
##
InstallOtherMethod( PRINT_OBJ,
    true,
    [ IsKind ],
    0,

function ( kind )
    local  family, flags, data;

    family := kind![1];
    flags  := kind![2];
    data   := kind![3];
    Print( "NewKind( ", family );
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
#F  Subkind( <kind>, <filter> )
##
Subkind2 := function ( kind, filter )
    local   new, i;
    new := NEW_KIND( KindOfKinds,
                     kind![1],
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        kind![2],
                        FLAGS_FILTER( filter ) ) ),
                     kind![3] );
    for i in [4..LEN_POSOBJ(kind)] do
        if IsBound( kind![i] ) then
            new![i] := kind![i];
        fi;
    od;
    return new;
end;


Subkind3 := function ( kind, filter, data )
    local   new, i;
    new := NEW_KIND( KindOfKinds,
                     kind![1],
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        kind![2],
                        FLAGS_FILTER( filter ) ) ),
                     data );
    for i in [4..LEN_POSOBJ(kind)] do
        if IsBound( kind![i] ) then
            new![i] := kind![i];
        fi;
    od;
    return new;
end;


Subkind := function ( arg )

    # check argument
    if not IsKind( arg[1] )  then
        Error("<kind> must be a kind");
    fi;

    # delegate
    if LEN_LIST(arg) = 2  then
        return Subkind2( arg[1], arg[2] );
    else
        return Subkind3( arg[1], arg[2], arg[3] );
    fi;

end;


#############################################################################
##
#F  SupKind( <kind>, <filter> )
##
SupKind2 := function ( kind, filter )
    local   new, i;
    new := NEW_KIND( KindOfKinds,
                     kind![1],
                     SUB_FLAGS(
                        kind![2],
                        FLAGS_FILTER( filter ) ),
                     kind![3] );
    for i in [4..LEN_POSOBJ(kind)] do
        if IsBound( kind![i] ) then
            new![i] := kind![i];
        fi;
    od;
    return new;
end;


SupKind3 := function ( kind, filter, data )
    local   new, i;
    new := NEW_KIND( KindOfKinds,
                     kind![1],
                     SUB_FLAGS(
                        kind![2],
                        FLAGS_FILTER( filter ) ),
                     data );
    for i in [4..LEN_POSOBJ(kind)] do
        if IsBound( kind![i] ) then
            new![i] := kind![i];
        fi;
    od;
    return new;
end;


SupKind := function ( arg )

    # check argument
    if not IsKind( arg[1] )  then
        Error("<kind> must be a kind");
    fi;

    # delegate
    if LEN_LIST(arg) = 2  then
        return SupKind2( arg[1], arg[2] );
    else
        return SupKind3( arg[1], arg[2], arg[3] );
    fi;

end;


#############################################################################
##
#F  FamilyKind( <K> ) . . . . . . . . . . . . family of objects with kind <K>
##
FamilyKind := function ( K )
    return K![1];
end;


#############################################################################
##
#F  FlagsKind( <K> )  . . . . . . . . . . . .  flags of objects with kind <K>
##
FlagsKind := function ( K )
    return K![2];
end;


#############################################################################
##
#F  DataKind( <K> ) . . . . . . . . . . . . . . defining data of the kind <K>
##
DataKind := function ( K )
    return K![3];
end;


#############################################################################
##
#F  SharedKind( <K> ) . . . . . . . . . . . . . . shared data of the kind <K>
##
SharedKind := function ( K )
    return K![3];
end;


#############################################################################
##
#F  KindObj( <obj> )  . . . . . . . . . . . . . . . . . . . kind of an object
##
KindObj := KIND_OBJ;


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
    return FlagsKind( KindObj( obj ) );
end;


#############################################################################
##
#F  DataObj( <obj> )  . . . . . . . . . . . . . .  defining data of an object
##
DataObj := function ( obj )
    return DataKind( KindObj( obj ) );
end;


#############################################################################
##
#F  SharedObj( <obj> )  . . . . . . . . . . . . . .  shared data of an object
##
SharedObj := function ( obj )
    return SharedKind( KindObj( obj ) );
end;


#############################################################################
##
#F  SetKindObj( <kind>, <obj> )
##
SetKindObj := function ( kind, obj )
    if not IsKind( kind )  then
        Error("<kind> must be a kind");
    fi;
    if IS_LIST( obj )  then
        SET_KIND_POSOBJ( obj, kind );
    elif IS_REC( obj )  then
        SET_KIND_COMOBJ( obj, kind );
    fi;
    RunImmediateMethods( obj, kind![2] );
    return obj;
end;

Objectify := SetKindObj;


#############################################################################
##
#F  ChangeKindObj( <kind>, <obj> )
##
ChangeKindObj := function ( kind, obj )
    if not IsKind( kind )  then
        Error("<kind> must be a kind");
    fi;
    if IS_POSOBJ( obj )  then
        SET_KIND_POSOBJ( obj, kind );
    elif IS_COMOBJ( obj )  then
        SET_KIND_COMOBJ( obj, kind );
    elif IS_DATOBJ( obj )  then
        SET_KIND_DATOBJ( obj, kind );
    fi;
    RunImmediateMethods( obj, kind![2] );
    return obj;
end;

ReObjectify := ChangeKindObj;


#############################################################################
##
#F  SetFilterObj( <obj>, <filter>, <val> )
##
SetFilterObj := function ( obj, filter )
    if IS_POSOBJ( obj ) then
        SET_KIND_POSOBJ( obj, Subkind2( KIND_OBJ(obj), filter ) );
        RunImmediateMethods( obj, FLAGS_FILTER( filter ) );
    elif IS_COMOBJ( obj ) then
        SET_KIND_COMOBJ( obj, Subkind2( KIND_OBJ(obj), filter ) );
        RunImmediateMethods( obj, FLAGS_FILTER( filter ) );
    elif IS_DATOBJ( obj ) then
        SET_KIND_DATOBJ( obj, Subkind2( KIND_OBJ(obj), filter ) );
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
        SET_KIND_POSOBJ( obj, SupKind2( KIND_OBJ(obj), filter ) );
    elif IS_COMOBJ( obj ) then
        SET_KIND_COMOBJ( obj, SupKind2( KIND_OBJ(obj), filter ) );
    elif IS_DATOBJ( obj ) then
        SET_KIND_DATOBJ( obj, SupKind2( KIND_OBJ(obj), filter ) );
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

#C  IsFunction( <obj> )
##
IsFunction := NewCategoryKernel(
    "IsFunction",
    IS_OBJECT,
    IS_FUNCTION );


#############################################################################
##

#F  RunMethodsFunction2( <list> )
##
RunMethodsFunction2 := function( list )

    return
        function( sup, sub )
            local   done,  fsup,  fsub,  i,  tmp;

            done := [];
            fsup := KindObj(sup)![2];
            fsub := KindObj(sub)![2];

            i := 1;
            while i <= LEN_LIST(list)  do
                if not i in done  then
                    if IS_SUBSET_FLAGS( fsup, list[i][1] )  then
                        if IS_SUBSET_FLAGS( fsub, list[i][2] )  then
                            ADD_SET( done, i );
                            list[i][3]( sup, sub );
                            tmp := KindObj(sub)![2];
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

#E  kind.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
