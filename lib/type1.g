#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains some functions moved from type.g to a place
##  where they will be compiled by default
##

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

LENGTH_SETTER_METHODS_2 := LENGTH_SETTER_METHODS_2 + (BASE_SIZE_METHODS_OPER_ENTRY+2);

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
##  <#GAPDoc Label="NewFamily">
##  <ManSection>
##  <Func Name="NewFamily" Arg='name[, req[, imp[, famfilter]]]'/>
##
##  <Description>
##  <Ref Func="NewFamily"/> returns a new family <A>fam</A> with name
##  <A>name</A>.
##  The argument <A>req</A>, if present, is a filter of which <A>fam</A>
##  shall be a subset.
##  If one tries to create an object in <A>fam</A> that does not lie in the
##  filter <A>req</A>, an error message is printed.
##  Also the argument <A>imp</A>, if present,
##  is a filter of which <A>fam</A> shall be a subset.
##  Any object that is created in the family <A>fam</A> will lie
##  automatically in the filter <A>imp</A>.
##  <P/>
##  The filter <A>famfilter</A>, if given, specifies a filter that will hold
##  for the family <A>fam</A> (not for objects in <A>fam</A>).
##  <P/>
##  Families are always represented as component objects
##  (see&nbsp;<Ref Sect="Component Objects"/>).
##  This means that components can be used to store and access
##  useful information about the family.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
Subtype := "defined below";
if IsHPCGAP then
    DS_TYPE_CACHE := ShareSpecialObj([]);
fi;

BIND_GLOBAL( "NEW_FAMILY",
    function ( typeOfFamilies, name, req_filter, imp_filter )
    local   lock, type, pair, family;

    # Look whether the category of the desired family can be improved
    # using the categories defined by 'CategoryFamily'.
    imp_filter := WITH_IMPS_FLAGS( AND_FLAGS( imp_filter, req_filter ) );
    type := Subtype( typeOfFamilies, IsAttributeStoringRep );
    if IsHPCGAP then
        # TODO: once the GAP compiler supports 'atomic', use that
        # to replace the explicit locking and unlocking here.
        lock := READ_LOCK(CATEGORIES_FAMILY);
    fi;
    for pair in CATEGORIES_FAMILY do
        if IS_SUBSET_FLAGS( imp_filter, pair[1] ) then
            type:= Subtype( type, pair[2] );
        fi;
    od;
    if IsHPCGAP then
        UNLOCK(lock);
    fi;

    # cannot use 'Objectify', because 'IsList' may not be defined yet
    if IsHPCGAP then
        family := AtomicRecord();
    else
        family := rec();
    fi;
    SET_TYPE_COMOBJ( family, type );
    family!.NAME            := IMMUTABLE_COPY_OBJ(name);
    family!.REQ_FLAGS       := req_filter;
    family!.IMP_FLAGS       := imp_filter;
    family!.nTYPES          := 0;
    family!.HASH_SIZE       := 32;
    if IsHPCGAP then
        # TODO: once the GAP compiler supports 'atomic', use that
        # to replace the explicit locking and unlocking here.
        lock := WRITE_LOCK(DS_TYPE_CACHE);
        family!.TYPES           := MIGRATE_RAW([], DS_TYPE_CACHE);
        UNLOCK(lock);
        # for caching types of homogeneous lists (see TYPE_LIST_HOM in list.g),
        # assigned in kernel when needed
        family!.TYPES_LIST_FAM  := MakeWriteOnceAtomic(AtomicList(27));
    else
        family!.TYPES           := [];
        # for caching types of homogeneous lists (see TYPE_LIST_HOM in list.g),
        # assigned in kernel when needed
        family!.TYPES_LIST_FAM  := [];
        # for efficiency
        family!.TYPES_LIST_FAM[27] := 0;
    fi;
    return family;
end );


BIND_GLOBAL( "NewFamily", function ( arg )
    local typeOfFamilies, name, req, imp;

    if not LEN_LIST(arg) in [1..4] then
        Error( "usage: NewFamily( <name> [, <req> [, <imp> [, <famfilter> ] ] ] )" );
    fi;

    name := arg[1];

    if LEN_LIST(arg) >= 2 then
        req := FLAGS_FILTER( arg[2] );
    else
        req := EMPTY_FLAGS;
    fi;

    if LEN_LIST(arg) >= 3  then
        imp := FLAGS_FILTER( arg[3] );
    else
        imp := EMPTY_FLAGS;
    fi;

    if LEN_LIST(arg) = 4  then
        typeOfFamilies := Subtype( TypeOfFamilies, arg[4] );
    else
        typeOfFamilies := TypeOfFamilies;
    fi;

    return NEW_FAMILY( typeOfFamilies, name, req, imp );

end );

#############################################################################
##
#F  NewType( <family>, <filter> [,<data>] )
##
##  <#GAPDoc Label="NewType">
##  <ManSection>
##  <Func Name="NewType" Arg='family, filter[, data]'/>
##
##  <Description>
##  <Ref Func="NewType"/> returns the type given by the family <A>family</A>
##  and the filter <A>filter</A>.
##  The optional third argument <A>data</A> is any object that denotes
##  defining data of the desired type.
##  <P/>
##  For examples where <Ref Func="NewType"/> is used,
##  see&nbsp;<Ref Sect="Component Objects"/>,
##  <Ref Sect="Positional Objects"/>,
##  and the example in Chapter
##  <Ref Chap="An Example -- Residue Class Rings"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
NEW_TYPE_CACHE_MISS  := 0;
NEW_TYPE_CACHE_HIT   := 0;

BIND_GLOBAL( "NEW_TYPE", function ( family, flags, data, parent )
    local   lock, hash,  cache,  cached,  type, ncache, ncl, t, i, match;

    # maybe it is in the type cache
    if IsHPCGAP then
        # TODO: once the GAP compiler supports 'atomic', use that
        # to replace the explicit locking and unlocking here.
        lock := WRITE_LOCK(DS_TYPE_CACHE);
    fi;
    cache := family!.TYPES;
    hash  := HASH_FLAGS(flags) mod family!.HASH_SIZE + 1;
    if IsBound( cache[hash] ) then
        cached := cache[hash];
        if IS_EQUAL_FLAGS( flags, cached![POS_FLAGS_TYPE] )  then
            flags := cached![POS_FLAGS_TYPE];
            if    IS_IDENTICAL_OBJ(  data,  cached![ POS_DATA_TYPE ] )
              and IS_IDENTICAL_OBJ(  TypeOfTypes, TYPE_OBJ(cached) )
            then
                # if there is no parent type, ensure that all non-standard entries
                # of <cached> are not set; this is necessary because lots of types
                # have LEN_POSOBJ(<type>) = 6, but entries 5 and 6 are unbound.
                if IS_IDENTICAL_OBJ(parent, fail) then
                    match := true;
                    for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( cached ) ] do
                        if IsBound( cached![i] ) then
                            match := false;
                            break;
                        fi;
                    od;
                    if match then
                        NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1;
                        if IsHPCGAP then
                            UNLOCK(lock);
                        fi;
                        return cached;
                    fi;
                fi;
                # if there is a parent type, make sure that any extra data in it
                # matches what is in the cache
                if LEN_POSOBJ( parent ) = LEN_POSOBJ( cached ) then
                    match := true;
                    for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( parent ) ] do
                        if IsBound( parent![i] ) <> IsBound( cached![i] ) then
                            match := false;
                            break;
                        fi;
                        if    IsBound( parent![i] ) and IsBound( cached![i] )
                          and not IS_IDENTICAL_OBJ( parent![i], cached![i] ) then
                            match := false;
                            break;
                        fi;
                    od;
                    if match then
                        NEW_TYPE_CACHE_HIT := NEW_TYPE_CACHE_HIT + 1;
                        if IsHPCGAP then
                            UNLOCK(lock);
                        fi;
                        return cached;
                    fi;
                fi;
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
    if IsHPCGAP then
        data := MakeReadOnlyObj(data);
    fi;
    type[POS_DATA_TYPE] := data;
    type[POS_NUMB_TYPE] := NEW_TYPE_NEXT_ID;

    if not IS_IDENTICAL_OBJ(parent, fail) then
        for i in [ POS_FIRST_FREE_TYPE .. LEN_POSOBJ( parent ) ] do
            if IsBound( parent![i] ) and not IsBound( type[i] ) then
                type[i] := parent![i];
            fi;
        od;
    fi;

    SET_TYPE_POSOBJ( type, TypeOfTypes );

    # check the size of the cache before storing this type
    if 3*family!.nTYPES > family!.HASH_SIZE then
        ncache := [];
        if IsHPCGAP then
            MIGRATE_RAW(ncache, DS_TYPE_CACHE);
        fi;
        ncl := 3*family!.HASH_SIZE+1;
        for t in cache do
            ncache[ HASH_FLAGS(t![POS_FLAGS_TYPE]) mod ncl + 1] := t;
        od;
        family!.HASH_SIZE := ncl;
        family!.TYPES := ncache;
        ncache[HASH_FLAGS(flags) mod ncl + 1] := type;
    else
        cache[hash] := type;
    fi;
    family!.nTYPES := family!.nTYPES + 1;
    if IsHPCGAP then
        MakeReadOnlySingleObj(type);
        UNLOCK(lock);
    fi;

    # return the type
    return type;
end );


BIND_GLOBAL( "NewType", function ( family, filter, data... )

    # check the argument
    if not IsFamily( family )  then
        Error("<family> must be a family");
    fi;

    # NewType( <family>, <filter> )
    if LEN_LIST(data) = 0  then
        data := fail;

    # NewType( <family>, <filter>, <data> )
    elif LEN_LIST(data) = 1  then
        data := data[1];

    # otherwise signal an error
    else
        Error("usage: NewType( <family>, <filter> [, <data> ] )");

    fi;

    # create and return the new type
    return NEW_TYPE( family,
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        family!.IMP_FLAGS,
                        FLAGS_FILTER(filter) ) ),
                     data, fail );
end );

#############################################################################
##
#F  Subtype( <type>, <filter> )
##
##  <ManSection>
##  <Func Name="Subtype" Arg='type, filter'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
Unbind( Subtype );
BIND_GLOBAL( "Subtype", function ( type, filter )

    # check argument
    if not IsType( type )  then
        Error("<type> must be a type");
    fi;

    return NEW_TYPE( type![POS_FAMILY_TYPE],
                     WITH_IMPS_FLAGS( AND_FLAGS(
                        type![POS_FLAGS_TYPE],
                        FLAGS_FILTER( filter ) ) ),
                     type![ POS_DATA_TYPE ], type );

end );


#############################################################################
##
#F  SupType( <type>, <filter> )
##
##  <ManSection>
##  <Func Name="SupType" Arg='type, filter'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "SupType", function ( type, filter )

    # check argument
    if not IsType( type )  then
        Error("<type> must be a type");
    fi;

    return NEW_TYPE( type![POS_FAMILY_TYPE],
                     SUB_FLAGS(
                        type![POS_FLAGS_TYPE],
                        FLAGS_FILTER( filter ) ),
                     type![ POS_DATA_TYPE ], type );

end );


#############################################################################
##
#F  FamilyType( <K> ) . . . . . . . . . . . . family of objects with type <K>
##
##  <ManSection>
##  <Func Name="FamilyType" Arg='K'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "FamilyType", K -> K![POS_FAMILY_TYPE] );


#############################################################################
##
#F  FlagsType( <K> )  . . . . . . . . . . . .  flags of objects with type <K>
##
##  <ManSection>
##  <Func Name="FlagsType" Arg='K'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "FlagsType", K -> K![POS_FLAGS_TYPE] );


#############################################################################
##
#F  DataType( <K> ) . . . . . . . . . . . . . . defining data of the type <K>
#F  SetDataType( <K>, <data> )  . . . . . . set defining data of the type <K>
##
##  <ManSection>
##  <Func Name="DataType" Arg='K'/>
##  <Func Name="SetDataType" Arg='K, data'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "DataType", K -> K![ POS_DATA_TYPE ] );

BIND_GLOBAL( "SetDataType", function ( K, data )
    if IsHPCGAP then
        StrictBindOnce(K, POS_DATA_TYPE, MakeImmutable(data));
    else
        K![ POS_DATA_TYPE ]:= data;
    fi;
end );


#############################################################################
##
#F  TypeObj( <obj> )  . . . . . . . . . . . . . . . . . . . type of an object
##
##  <#GAPDoc Label="TypeObj">
##  <ManSection>
##  <Func Name="TypeObj" Arg='obj'/>
##
##  <Description>
##  returns the type of the object <A>obj</A>.
##  <P/>
##  The type of an object is itself an object.
##  <P/>
##  Two types are equal if and only if the two families are identical,
##  the filters are equal, and, if present, also the defining data of the
##  types are equal.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "TypeObj", TYPE_OBJ );


#############################################################################
##
#F  FamilyObj( <obj> )  . . . . . . . . . . . . . . . . . family of an object
##
##  <#GAPDoc Label="FamilyObj">
##  <ManSection>
##  <Func Name="FamilyObj" Arg='obj'/>
##
##  <Description>
##  returns the family of the object <A>obj</A>.
##  <P/>
##  The family of the object <A>obj</A> is itself an object,
##  its family is <C>FamilyOfFamilies</C>.
##  <P/>
##  It should be emphasized that families may be created when they are
##  needed.  For example, the family of elements of a finitely presented
##  group is created only after the presentation has been constructed.
##  Thus families are the dynamic part of the type system, that is, the
##  part that is not fixed after the initialisation of &GAP;.
##  <P/>
##  Families can be parametrized.  For example, the elements of each
##  finitely presented group form a family of their own.  Here the family
##  of elements and the finitely presented group coincide when viewed as
##  sets.  Note that elements in different finitely presented groups lie
##  in different families.  This distinction allows &GAP; to forbid
##  multiplications of elements in different finitely presented groups.
##  <P/>
##  As a special case, families can be parametrized by other families.  An
##  important example is the family of <E>collections</E> that can be formed
##  for each family.  A collection consists of objects that lie in the
##  same family, it is either a nonempty dense list of objects from the
##  same family or a domain.
##  <P/>
##  Note that every domain is a collection, that is, it is not possible to
##  construct domains whose elements lie in different families.  For
##  example, a polynomial ring over the rationals cannot contain the
##  integer <C>0</C> because the family that contains the integers does not
##  contain polynomials.  So one has to distinguish the integer zero from
##  each zero polynomial.
##  <P/>
##  Let us look at this example from a different viewpoint.  A polynomial
##  ring and its coefficients ring lie in different families, hence the
##  coefficients ring cannot be embedded <Q>naturally</Q> into the polynomial
##  ring in the sense that it is a subset.  But it is possible to allow,
##  e.g., the multiplication of an integer and a polynomial over the
##  integers.  The relation between the arguments, namely that one is a
##  coefficient and the other a polynomial, can be detected from the
##  relation of their families.  Moreover, this analysis is easier than in
##  a situation where the rationals would lie in one family together with
##  all polynomials over the rationals, because then the relation of
##  families would not distinguish the multiplication of two polynomials,
##  the multiplication of two coefficients, and the multiplication of a
##  coefficient with a polynomial.  So the wish to describe relations
##  between elements can be taken as a motivation for the introduction of
##  families.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "FamilyObj", FAMILY_OBJ );


#############################################################################
##
#F  FlagsObj( <obj> ) . . . . . . . . . . . . . . . . . .  flags of an object
##
##  <ManSection>
##  <Func Name="FlagsObj" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "FlagsObj", obj -> FlagsType( TypeObj( obj ) ) );


#############################################################################
##
#F  DataObj( <obj> )  . . . . . . . . . . . . . .  defining data of an object
##
##  <ManSection>
##  <Func Name="DataObj" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "DataObj", obj -> DataType( TypeObj( obj ) ) );


BIND_GLOBAL( "IsNonAtomicComponentObjectRepFlags",
        FLAGS_FILTER(IsNonAtomicComponentObjectRep));
BIND_GLOBAL( "IsAtomicPositionalObjectRepFlags",
        FLAGS_FILTER(IsAtomicPositionalObjectRep));
BIND_GLOBAL( "IsReadOnlyPositionalObjectRepFlags",
        FLAGS_FILTER(IsReadOnlyPositionalObjectRep));

#############################################################################
##
#F  Objectify( <type>, <obj> )
##
##  <ManSection>
##  <Func Name="Objectify" Arg='type, obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "Objectify", function ( type, obj )
    local flags;
    if not IsType( type )  then
        Error("<type> must be a type");
    fi;
    if IsHPCGAP then
        flags := FlagsType(type);
        if IS_LIST( obj )  then
            if IS_SUBSET_FLAGS(flags, IsAtomicPositionalObjectRepFlags) then
                FORCE_SWITCH_OBJ( obj, FixedAtomicList(obj) );
            fi;
        elif IS_REC( obj )  then
            if IS_ATOMIC_RECORD(obj) then
                if IS_SUBSET_FLAGS(flags, IsNonAtomicComponentObjectRepFlags) then
                    FORCE_SWITCH_OBJ( obj, FromAtomicRecord(obj) );
                fi;
            elif not IS_SUBSET_FLAGS(flags, IsNonAtomicComponentObjectRepFlags) then
                FORCE_SWITCH_OBJ( obj, AtomicRecord(obj) );
            fi;
        fi;
    fi;
    if IS_LIST( obj )  then
        SET_TYPE_POSOBJ( obj, type );
    elif IS_REC( obj )  then
        SET_TYPE_COMOBJ( obj, type );
    fi;
    if not ( IGNORE_IMMEDIATE_METHODS
             or IsNoImmediateMethodsObject(obj) ) then
      RunImmediateMethods( obj, type![POS_FLAGS_TYPE] );
    fi;
    if IsHPCGAP then
      if IsReadOnlyPositionalObjectRep(obj) then
        MakeReadOnlySingleObj(obj);
      fi;
    fi;
    return obj;
end );


#############################################################################
##
#F  SetFilterObj( <obj>, <filter> )
##
##  <#GAPDoc Label="SetFilterObj">
##  <ManSection>
##  <Func Name="SetFilterObj" Arg='obj, filter'/>
##
##  <Description>
##  <Ref Func="SetFilterObj"/> sets the value of <A>filter</A>
##  (and of all filters implied by <A>filter</A>) for <A>obj</A> to
##  <K>true</K>.
##  <P/>
##  This may trigger immediate methods.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
Unbind( SetFilterObj );
BIND_GLOBAL( "SetFilterObj", function ( obj, filter )
local type, newtype;

    type:= TYPE_OBJ( obj );
    newtype:= Subtype( type, filter );
    if IS_POSOBJ( obj ) then
      SET_TYPE_POSOBJ( obj, newtype );
    elif IS_COMOBJ( obj ) then
      SET_TYPE_COMOBJ( obj, newtype );
    elif IS_DATOBJ( obj ) then
      SET_TYPE_DATOBJ( obj, newtype );
    else
        ErrorNoReturn("cannot set filter for internal object");
    fi;

    # run immediate methods
    if not ( IGNORE_IMMEDIATE_METHODS
             or IsNoImmediateMethodsObject(obj) ) then
      RunImmediateMethods( obj, SUB_FLAGS( newtype![POS_FLAGS_TYPE], type![POS_FLAGS_TYPE] ) );
    fi;
end );


#############################################################################
##
#F  ResetFilterObj( <obj>, <filter> )
##
##  <#GAPDoc Label="ResetFilterObj">
##  <ManSection>
##  <Func Name="ResetFilterObj" Arg='obj, filter'/>
##
##  <Description>
##  <Ref Func="ResetFilterObj"/> sets the value of <A>filter</A> for
##  <A>obj</A> to <K>false</K>.
##  (Implied filters of <A>filt</A> are not touched.
##  This might create inconsistent situations if applied carelessly).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ResetFilterObj", function ( obj, filter )
    local type, newtype;

    if IS_AND_FILTER( filter ) then
        Error("You can't reset an \"and-filter\". Reset components individually.");
    fi;

    type:= TYPE_OBJ( obj );
    newtype:= SupType( type, filter );
    if IS_POSOBJ( obj ) then
        SET_TYPE_POSOBJ( obj, newtype );
    elif IS_COMOBJ( obj ) then
        SET_TYPE_COMOBJ( obj, newtype );
    elif IS_DATOBJ( obj ) then
        SET_TYPE_DATOBJ( obj, newtype );
    else
        Error("cannot reset filter for internal object");
    fi;
end );


#############################################################################
##
#F  ObjectifyWithAttributes(<obj>,<type>,<attr1>,<val1>,<attr2>,<val2>... )
##
##  <#GAPDoc Label="ObjectifyWithAttributes">
##  <ManSection>
##  <Func Name="ObjectifyWithAttributes"
##   Arg='obj, type, attr1, val1, attr2, val2, ...'/>
##
##  <Description>
##  Attribute assignments will change the type of an object.
##  If you create many objects, code of the form
##  <P/>
##  <Log><![CDATA[
##  o:=Objectify(type,rec());
##  SetMyAttribute(o,value);
##  ]]></Log>
##  <P/>
##  will take a lot of time for type changes.
##  You can avoid this  by  setting the attributes immediately while the
##  object is created, as follows.
##  <Ref Func="ObjectifyWithAttributes"/> takes a plain list or record
##  <A>obj</A> and turns it an object just like <Ref Func="Objectify"/>
##  and sets attribute <A>attr1</A> to <A>val1</A>,
##  sets attribute <A>attr2</A> to <A>val2</A> and so forth.
##  <P/>
##  If the filter list of <A>type</A> includes that these attributes are set
##  (and the properties also include values of the properties)
##  and if no special setter methods are installed for any of the involved
##  attributes then they are set simultaneously without type changes.
##  This can produce a substantial speedup.
##  <P/>
##  If the conditions of the last sentence are not fulfilled, an ordinary
##  <Ref Func="Objectify"/> with subsequent setter calls for the attributes
##  is performed instead.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "IsAttributeStoringRepFlags",
    FLAGS_FILTER( IsAttributeStoringRep ) );

BIND_GLOBAL( "INFO_OWA", Ignore );
MAKE_READ_WRITE_GLOBAL( "INFO_OWA" );

BIND_GLOBAL( "ObjectifyWithAttributes", function (arg)
    local obj, type, flags, attr, val, i, extra,  nflags;
    obj := arg[1];
    type := arg[2];
    flags := FlagsType(type);
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
            type := NEW_TYPE( FamilyType(type), flags, DataType(type), fail );
        fi;
        Objectify( type, obj );
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
    return obj;
end );
