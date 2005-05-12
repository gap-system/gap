#############################################################################
##
#W  type1.g                     GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains some functions moved from type.g to a place
##  where they will be compiled by default
##
Revision.type1_g :=
    "@(#)$Id$";

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
        GETTER_FLAGS,
        GETTER_FUNCTION(name) );
    end );

LENGTH_SETTER_METHODS_2 := LENGTH_SETTER_METHODS_2 + 6;

InstallAttributeFunction(
    function ( name, filter, getter, setter, tester, mutflag )
    if mutflag then
        InstallOtherMethod( setter,
            "system mutable setter",
            true,
            [ IsAttributeStoringRep,
              IS_OBJECT ],
            0,
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
            0,
            SETTER_FUNCTION( name, tester ) );
    fi;
    end );

#############################################################################
##
#F  NewFamily( <name>, ... )
##
Subtype := "defined below";


BIND_GLOBAL( "NEW_FAMILY",
    function ( typeOfFamilies, name, req_filter, imp_filter )
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
    family!.nTYPES          := 0;
    family!.HASH_SIZE       := 32;
    # for chaching types of homogeneous lists (see TYPE_LIST_HOM in list.g), 
    # assigned in kernel when needed 
    family!.TYPES_LIST_FAM  := [];
    # for efficiency
    family!.TYPES_LIST_FAM[27] := 0;
    return family;
end );


BIND_GLOBAL( "NewFamily2", function ( typeOfFamilies, name )
    return NEW_FAMILY( typeOfFamilies,
                       name,
                       EMPTY_FLAGS,
                       EMPTY_FLAGS );
end );


BIND_GLOBAL( "NewFamily3", function ( typeOfFamilies, name, req )
    return NEW_FAMILY( typeOfFamilies,
                       name,
                       FLAGS_FILTER( req ),
                       EMPTY_FLAGS );
end );


BIND_GLOBAL( "NewFamily4", function ( typeOfFamilies, name, req, imp )
    return NEW_FAMILY( typeOfFamilies,
                       name,
                       FLAGS_FILTER( req ),
                       FLAGS_FILTER( imp ) );
end );


BIND_GLOBAL( "NewFamily5",
    function ( typeOfFamilies, name, req, imp, filter )
    return NEW_FAMILY( Subtype( typeOfFamilies, filter ),
                       name,
                       FLAGS_FILTER( req ),
                       FLAGS_FILTER( imp ) );
end );


BIND_GLOBAL( "NewFamily", function ( arg )

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

end );

#############################################################################
##
#F  NewType( <family>, <filter> [,<data>] )
##
NEW_TYPE_CACHE_MISS  := 0;
NEW_TYPE_CACHE_HIT   := 0;

BIND_GLOBAL( "NEW_TYPE", function ( typeOfTypes, family, flags, data )
    local   hash,  cache,  cached,  type, ncache, ncl, t;

    # maybe it is in the type cache
    cache := family!.TYPES;
    hash  := HASH_FLAGS(flags) mod family!.HASH_SIZE + 1;
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
    if NEW_TYPE_NEXT_ID >= NEW_TYPE_ID_LIMIT then
        GASMAN("collect");
        FLUSH_ALL_METHOD_CACHES();
        NEW_TYPE_NEXT_ID := COMPACT_TYPE_IDS();
        #Print("#I Compacting type IDs: ",NEW_TYPE_NEXT_ID+2^28," in use\n");
    fi;

    # make the new type
    # cannot use 'Objectify', because 'IsList' may not be defined yet
    type := [ family, flags ];
    type[POS_DATA_TYPE] := data;
    type[POS_NUMB_TYPE] := NEW_TYPE_NEXT_ID;

    SET_TYPE_POSOBJ( type, typeOfTypes );
    
    # check the size of the cache before storing this type
    if 3*family!.nTYPES > family!.HASH_SIZE then
        ncache := [];
        ncl := 3*family!.HASH_SIZE+1;
        for t in cache do
            ncache[ HASH_FLAGS(t![2]) mod ncl + 1] := t;
        od;
        family!.HASH_SIZE := ncl;
        family!.TYPES := ncache;
        ncache[HASH_FLAGS(flags) mod ncl + 1] := type;
    else
        cache[hash] := type;
    fi;
    family!.nTYPES := family!.nTYPES + 1;

    # return the type
    return type;
end );



BIND_GLOBAL( "NewType2", function ( typeOfTypes, family )
    return NEW_TYPE( typeOfTypes,
                     family,
                     family!.IMP_FLAGS,
                     false );
end );


BIND_GLOBAL( "NewType3", function ( typeOfTypes, family, filter )
    return NEW_TYPE( typeOfTypes,
                     family,
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        family!.IMP_FLAGS,
                        FLAGS_FILTER(filter) ) ),
                     false );
end );


BIND_GLOBAL( "NewType4", function ( typeOfTypes, family, filter, data )
    return NEW_TYPE( typeOfTypes,
                     family,
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        family!.IMP_FLAGS,
                        FLAGS_FILTER(filter) ) ),
                     data );
end );


BIND_GLOBAL( "NewType5",
    function ( typeOfTypes, family, filter, data, stuff )
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
end );


BIND_GLOBAL( "NewType", function ( arg )
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
end );

#############################################################################
##
#F  Subtype( <type>, <filter> )
##
BIND_GLOBAL( "Subtype2", function ( type, filter )
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
end );


BIND_GLOBAL( "Subtype3", function ( type, filter, data )
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
end );


Unbind( Subtype );
BIND_GLOBAL( "Subtype", function ( arg )

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

end );


#############################################################################
##
#F  SupType( <type>, <filter> )
##
BIND_GLOBAL( "SupType2", function ( type, filter )
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
end );


BIND_GLOBAL( "SupType3", function ( type, filter, data )
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
end );


BIND_GLOBAL( "SupType", function ( arg )

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

end );


#############################################################################
##
#F  FamilyType( <K> ) . . . . . . . . . . . . family of objects with type <K>
##
BIND_GLOBAL( "FamilyType", K -> K![1] );


#############################################################################
##
#F  FlagsType( <K> )  . . . . . . . . . . . .  flags of objects with type <K>
##
BIND_GLOBAL( "FlagsType", K -> K![2] );


#############################################################################
##
#F  DataType( <K> ) . . . . . . . . . . . . . . defining data of the type <K>
#F  SetDataType( <K>, <data> )  . . . . . . set defining data of the type <K>
##
BIND_GLOBAL( "DataType", K -> K![ POS_DATA_TYPE ] );

BIND_GLOBAL( "SetDataType", function ( K, data )
    K![ POS_DATA_TYPE ]:= data;
end );


#############################################################################
##
#F  SharedType( <K> ) . . . . . . . . . . . . . . shared data of the type <K>
##
BIND_GLOBAL( "SharedType", K -> K![ POS_DATA_TYPE ] );


#############################################################################
##
#F  TypeObj( <obj> )  . . . . . . . . . . . . . . . . . . . type of an object
##
##  returns the type of the object <obj>. 
BIND_GLOBAL( "TypeObj", TYPE_OBJ );


#############################################################################
##
#F  FamilyObj( <obj> )  . . . . . . . . . . . . . . . . . family of an object
##
##  returns the family of the object <obj>.
BIND_GLOBAL( "FamilyObj", FAMILY_OBJ );


#############################################################################
##
#F  FlagsObj( <obj> ) . . . . . . . . . . . . . . . . . .  flags of an object
##
BIND_GLOBAL( "FlagsObj", obj -> FlagsType( TypeObj( obj ) ) );


#############################################################################
##
#F  DataObj( <obj> )  . . . . . . . . . . . . . .  defining data of an object
##
BIND_GLOBAL( "DataObj", obj -> DataType( TypeObj( obj ) ) );


#############################################################################
##
#F  SharedObj( <obj> )  . . . . . . . . . . . . . .  shared data of an object
##
BIND_GLOBAL( "SharedObj", obj -> SharedType( TypeObj( obj ) ) );


#############################################################################
##
#F  SetTypeObj( <type>, <obj> )
##
BIND_GLOBAL( "SetTypeObj", function ( type, obj )
    if not IsType( type )  then
        Error("<type> must be a type");
    fi;
    if IS_LIST( obj )  then
        SET_TYPE_POSOBJ( obj, type );
    elif IS_REC( obj )  then
        SET_TYPE_COMOBJ( obj, type );
    fi;
    if not IsNoImmediateMethodsObject(obj) then
      RunImmediateMethods( obj, type![2] );
    fi;
    return obj;
end );

BIND_GLOBAL( "Objectify", SetTypeObj );


#############################################################################
##
#F  ChangeTypeObj( <type>, <obj> )
##
BIND_GLOBAL( "ChangeTypeObj", function ( type, obj )
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
    if not IsNoImmediateMethodsObject(obj) then
      RunImmediateMethods( obj, type![2] );
    fi;
    return obj;
end );

BIND_GLOBAL( "ReObjectify", ChangeTypeObj );


#############################################################################
##
#F  SetFilterObj( <obj>, <filter> )
##
Unbind( SetFilterObj );
BIND_GLOBAL( "SetFilterObj", function ( obj, filter )
    if IS_POSOBJ( obj ) then
      SET_TYPE_POSOBJ( obj, Subtype2( TYPE_OBJ(obj), filter ) );
      if not IsNoImmediateMethodsObject(obj) then
	RunImmediateMethods( obj, FLAGS_FILTER( filter ) );
      fi;
    elif IS_COMOBJ( obj ) then
      SET_TYPE_COMOBJ( obj, Subtype2( TYPE_OBJ(obj), filter ) );
      if not IsNoImmediateMethodsObject(obj) then
	RunImmediateMethods( obj, FLAGS_FILTER( filter ) );
      fi;
    elif IS_DATOBJ( obj ) then
      SET_TYPE_DATOBJ( obj, Subtype2( TYPE_OBJ(obj), filter ) );
      if not IsNoImmediateMethodsObject(obj) then
	RunImmediateMethods( obj, FLAGS_FILTER( filter ) );
      fi;
    elif IS_PLIST_REP( obj )  then
        SET_FILTER_LIST( obj, filter );
    elif IS_STRING_REP( obj )  then
        SET_FILTER_LIST( obj, filter );
    elif IS_BLIST( obj )  then
        SET_FILTER_LIST( obj, filter );
    elif IS_RANGE( obj )  then
        SET_FILTER_LIST( obj, filter );
    else
        Error("cannot set filter for internal object");
    fi;
end );

BIND_GLOBAL( "SET_FILTER_OBJ", SetFilterObj );




#############################################################################
##
#F  ResetFilterObj( <obj>, <filter> )
##

BIND_GLOBAL( "ResetFilterObj", function ( obj, filter )
    
    if IS_AND_FILTER( filter ) then
        Error("You can't reset an \"and-filter\". Reset components individually.");
              fi;
    if IS_POSOBJ( obj ) then
        SET_TYPE_POSOBJ( obj, SupType2( TYPE_OBJ(obj), filter ) );
    elif IS_COMOBJ( obj ) then
        SET_TYPE_COMOBJ( obj, SupType2( TYPE_OBJ(obj), filter ) );
    elif IS_DATOBJ( obj ) then
        SET_TYPE_DATOBJ( obj, SupType2( TYPE_OBJ(obj), filter ) );
    elif IS_PLIST_REP( obj )  then
        RESET_FILTER_LIST( obj, filter );
    elif IS_STRING_REP( obj )  then
        RESET_FILTER_LIST( obj, filter );
    elif IS_BLIST( obj )  then
        RESET_FILTER_LIST( obj, filter );
    elif IS_RANGE( obj )  then
        RESET_FILTER_LIST( obj, filter );
    else
        Error("cannot reset filter for internal object");
    fi;
end );

BIND_GLOBAL( "RESET_FILTER_OBJ", ResetFilterObj );


#############################################################################
##
#F  SetFeatureObj( <obj>, <filter>, <val> )
##
BIND_GLOBAL( "SetFeatureObj", function ( obj, filter, val )
    if val then
        SetFilterObj( obj, filter );
    else
        ResetFilterObj( obj, filter );
    fi;
end );


#############################################################################
##
#F  SetMultipleAttributes( <obj>, <attr1>, <val1>, <attr2>, <val2> ... )
##
##  This function should have the same net effect as 
##
##  Setter( <attr1> )( <obj>, <val1> )
##  Setter( <attr2> )( <obj>, <val2> )
##   . . .
##
## but hopefully be faster, by amalgamating all the type changes
##
BIND_GLOBAL( "SetMultipleAttributes", function (arg)
    local obj, type, flags, attr, val, i, extra, nfilt, nflags;
    obj := arg[1];
    if IsAttributeStoringRep(obj) then
        extra := [];
        type := TypeObj(obj);
        flags := FlagsType( type);
        nfilt := IS_OBJECT;
        for i in [2,4..LEN_LIST(arg)-1] do
            attr := arg[i];
            val := arg[i+1];
            if 0 <> FLAG1_FILTER(attr) then

                # `attr' is a property.
                if val then
                  nfilt:= nfilt and attr;  # (implies the property tester)
                else
                  nfilt:= nfilt and Tester( attr );
                fi;

            elif LEN_LIST(METHODS_OPERATION( Setter(attr) , 2)) <> 12 then

                # There are special setter methods for `attr',
                # we have to call the setter explicitly.
                ADD_LIST(extra, attr);
                ADD_LIST(extra, val);

            else

                # We set the attribute value.
                obj!.(NAME_FUNC(attr)) := IMMUTABLE_COPY_OBJ(val);
                nfilt := nfilt and Tester(attr);

            fi;
        od;
        nflags := FLAGS_FILTER(nfilt);
        if not IS_SUBSET_FLAGS(flags, nflags) then
            flags := WITH_IMPS_FLAGS(AND_FLAGS(flags, nflags));
            ChangeTypeObj(NEW_TYPE(TypeOfTypes, 
                    FamilyType(type), 
                    flags , 
                    DataType(type)),obj);
        fi;
        for i in [2,4..LEN_LIST(extra)] do
            Setter(extra[i-1])(obj,extra[i]);
        od;
    else
        extra := arg;
        for i in [2,4..LEN_LIST(extra)] do
            Setter(extra[i])(obj,extra[i+1]);
        od;
    fi;
end);

#############################################################################
##
#F  ObjectifyWithAttributes(<obj>,<type>,<attr1>,<val1>,<attr2>,<val2>... )
##
##  This function should have almost the same net effect as 
##
##  Objectify(  <type>, <obj> )
##  Setter( <attr1> )( <obj>, <val1> )
##  Setter( <attr2> )( <obj>, <val2> )
##   . . .
##
## but hopefully be faster, by amalgamating all the type changes
##
##  The difference, is that type may already include the testers for
##  the attributes passesd (if any of them are properties then the type
## may also include their values). In this case, no new type will
## be created at all.
##
BIND_GLOBAL( "IsAttributeStoringRepFlags",
    FLAGS_FILTER( IsAttributeStoringRep ) );

BIND_GLOBAL( "INFO_OWA", Ignore );
MAKE_READ_WRITE_GLOBAL( "INFO_OWA" );

BIND_GLOBAL( "ObjectifyWithAttributes", function (arg)
    local obj, type, flags, attr, val, i, extra,  nflags;
    obj := arg[1];
    type := arg[2];
    flags := FlagsType( type);
    extra := [];
    
    if not IS_SUBSET_FLAGS(
               flags,
               IsAttributeStoringRepFlags
               ) then
        extra := arg{[3..LEN_LIST(arg)]};
        INFO_OWA( "#W ObjectifyWithAttributes called ",
                  "for non-attribute storing rep\n" );
        Objectify(type, obj);
    else
        nflags := EMPTY_FLAGS;
        for i in [3,5..LEN_LIST(arg)-1] do
            attr := arg[i];
            val := arg[i+1];
            
            # This first case is the case of a property
            if 0 <> FLAG1_FILTER(attr) then
              if val then
                nflags := AND_FLAGS(nflags, FLAGS_FILTER(attr));
              else
                nflags := AND_FLAGS(nflags, FLAGS_FILTER(Tester(attr)));
              fi;
                
            # Now we have to check that no one has installed non-standard
            # setter methods
            elif LEN_LIST( METHODS_OPERATION( Setter( attr ), 2) )
                 <> LENGTH_SETTER_METHODS_2 then
                ADD_LIST(extra, attr);
                ADD_LIST(extra, val);
                
            # Otherwise we are dealing with a normal stored attribute
            # so store it in the record and set the tester
            else
                obj.( NAME_FUNC(attr) ) := IMMUTABLE_COPY_OBJ(val);
                nflags := AND_FLAGS(nflags, FLAGS_FILTER(Tester(attr)));
            fi;
        od;
        if not IS_SUBSET_FLAGS(flags,nflags) then 
            flags := WITH_IMPS_FLAGS(AND_FLAGS(flags, nflags));
            Objectify( NEW_TYPE(TypeOfTypes, 
                    FamilyType(type), 
                    flags , 
                    DataType(type)), obj);
        else
            Objectify( type, obj);
        fi;
    fi;
    for i in [1,3..LEN_LIST(extra)-1] do
        if (Tester(extra[i])(obj)) then
	  INFO_OWA( "#W  Supplied type has tester of ",NAME_FUNC(extra[i]),
		    "with non-standard setter\n" );
	  ResetFilterObj(obj, Tester(extra[i]));
#T If there is an immediate method relying on an attribute
#T whose tester is set to `true' in `type'
#T and that has a special setter
#T then already the `Objectify' call above may cause problems?
        fi;
        Setter(extra[i])(obj,extra[i+1]);
    od;
end );

#############################################################################
##
#E
