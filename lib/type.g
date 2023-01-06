#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file defines the format of families and types. Some functions
##  are moved to type1.g, which is compiled
##


#############################################################################
##
#F  NEW_TYPE_NEXT_ID  . . . . . . . . . . . . GAP integer numbering the types
##
##  <ManSection>
##  <Func Name="NEW_TYPE_NEXT_ID" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
NEW_TYPE_NEXT_ID := INTOBJ_MIN;
NEW_TYPE_ID_LIMIT := INTOBJ_MAX;


#############################################################################
##
#F  DeclareCategoryKernel( <name>, <super>, <filter> )  create a new category
##
BIND_GLOBAL( "DeclareCategoryKernel", function ( name, super, cat )
    if not IS_IDENTICAL_OBJ( cat, IS_OBJECT ) then
        atomic readwrite CATS_AND_REPS, FILTER_REGION do
            ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
            REGISTER_FILTER( cat, FLAG1_FILTER( cat ), 1, FNUM_CAT_KERN );
        od;
        InstallTrueMethod( super, cat );
    fi;
    BIND_GLOBAL( name, cat );
    SET_NAME_FUNC( cat, name );
end );


#############################################################################
##
#F  NewCategory( <name>, <super>[, <rank>] )  . . . . . create a new category
##
##  <#GAPDoc Label="NewCategory">
##  <ManSection>
##  <Func Name="NewCategory" Arg='name, super[, rank]'/>
##
##  <Description>
##  <Ref Func="NewCategory"/> returns a new category <A>cat</A> that has the
##  name <A>name</A> and is contained in the filter <A>super</A>,
##  see&nbsp;<Ref Sect="Filters"/>.
##  This means that every object in <A>cat</A> lies automatically also in
##  <A>super</A>.
##  We say also that <A>super</A> is an implied filter of <A>cat</A>.
##  <P/>
##  For example, if one wants to create a category of group elements
##  then <A>super</A> should be
##  <Ref Filt="IsMultiplicativeElementWithInverse"/>
##  or a subcategory of it.
##  If no specific supercategory of <A>cat</A> is known,
##  <A>super</A> may be <Ref Filt="IsObject"/>.
##  <P/>
##  The optional third argument <A>rank</A> denotes the incremental rank
##  (see&nbsp;<Ref Sect="Filters"/>) of <A>cat</A>,
##  the default value is 1.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NewCategory", function ( arg )
    local cat, rank;

    # Create the filter.
    cat:= NEW_FILTER( arg[1] );
    if LEN_LIST( arg ) >= 3 and IS_INT( arg[3] ) then
        rank := arg[3];
    else
        rank := 1;
    fi;

    # Do some administrational work.
    atomic readwrite CATS_AND_REPS, FILTER_REGION do
        ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
        REGISTER_FILTER( cat, FLAG1_FILTER( cat ), rank, FNUM_CAT );
    od;

    # Do not call this before adding 'cat' to 'FILTERS'.
    InstallTrueMethodNewFilter( arg[2], cat );

    # Return the filter.
    return cat;
end );


#############################################################################
##
#F  DeclareCategory( <name>, <super>[, <rank>] )  . . . create a new category
##
##  <#GAPDoc Label="DeclareCategory">
##  <ManSection>
##  <Func Name="DeclareCategory" Arg='name, super[, rank]'/>
##
##  <Description>
##  does the same as <Ref Func="NewCategory"/> and then binds
##  the result to the global variable <A>name</A>. The variable
##  must previously be writable, and is made read-only by this function.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DeclareCategory", function( arg )
    BIND_GLOBAL( arg[1], CALL_FUNC_LIST( NewCategory, arg ) );
end );


#############################################################################
##
#F  DeclareRepresentationKernel( <name>, <super>, <filt> )
##
##  <ManSection>
##  <Func Name="DeclareRepresentationKernel" Arg='name, super, filt'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "DeclareRepresentationKernel", function ( name, super, rep )
    local   filt;
    atomic readwrite CATS_AND_REPS, FILTER_REGION do
        if REREADING then
            for filt in CATS_AND_REPS do
                if NAME_FUNC(FILTERS[filt]) = name then
                    Print("#W DeclareRepresentationKernel \"",name,"\" in Reread. ");
                    Print("Change of Super-rep not handled\n");
                    return FILTERS[filt];
                fi;
            od;
        fi;
        atomic readwrite CATS_AND_REPS, FILTER_REGION do
            ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) );
            REGISTER_FILTER( rep, FLAG1_FILTER( rep ), 1, FNUM_REP_KERN );
        od;

    od;

    # Calling 'InstallTrueMethod' for two representations is not allowed.
    InstallTrueMethodNewFilter( super, rep );
    BIND_GLOBAL( name, rep );
    SET_NAME_FUNC( rep, name );
end );



#############################################################################
##
#F  NewRepresentation( <name>, <super>[, <slots>[, <req>]] )  .  representation
##
##  <#GAPDoc Label="NewRepresentation">
##  <ManSection>
##  <Func Name="NewRepresentation" Arg='name, super[, slots[, req]]'/>
##
##  <Description>
##  <Ref Func="NewRepresentation"/> returns a new representation <A>rep</A>
##  that has the name <A>name</A> and is a subrepresentation of the
##  representation <A>super</A>.
##  This means that every object in <A>rep</A> lies automatically also in
##  <A>super</A>.
##  We say also that <A>super</A> is an implied filter of <A>rep</A>.
##  <P/>
##  Each representation in &GAP; is a subrepresentation of exactly one
##  of the four representations <Ref Filt="IsInternalRep"/>,
##  <Ref Filt="IsDataObjectRep"/>,
##  <Ref Filt="IsComponentObjectRep"/>, <Ref Filt="IsPositionalObjectRep"/>.
##  The data describing objects in the former two can be accessed only via
##  &GAP; kernel functions, the data describing objects in the latter two
##  is accessible also in library functions,
##  see&nbsp;<Ref Sect="Component Objects"/>
##  and&nbsp;<Ref Sect="Positional Objects"/> for the details.
##  <P/>
##  The optional third and fourth arguments <A>slots</A> and <A>req</A> are
##  (and always were) unused and are only provided for backwards
##  compatibility. Note that <A>slots</A> was required (but still unused)
##  before GAP 4.12.
##  <P/>
##  The incremental rank (see&nbsp;<Ref Sect="Filters"/>)
##  of <A>rep</A> is 1.
##  <P/>
##  Examples for the use of <Ref Func="NewRepresentation"/> can be found
##  in&nbsp;<Ref Sect="Component Objects"/>,
##  <Ref Sect="Positional Objects"/>, and also in
##  <Ref Sect="A Second Attempt to Implement Elements of Residue Class Rings"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NewRepresentation", function ( name, super, arg... )
    local   rep, filt;

    # Do *not* create a new representation when the file is reread.
    if REREADING then
        atomic readonly CATS_AND_REPS, readwrite FILTER_REGION do
            for filt in CATS_AND_REPS do
                if NAME_FUNC(FILTERS[filt]) = name then
                    Print("#W NewRepresentation \"",name,"\" in Reread. ");
                    Print("Change of Super-rep not handled\n");
                    return FILTERS[filt];
                fi;
            od;
        od;
    fi;

    # Create the filter.
    if LEN_LIST(arg) > 2 then
        Error("usage: NewRepresentation( <name>, <super>[, <slots> [, <req> ]] )");
    elif LEN_LIST(arg) > 0 then
        INFO_OBSOLETE(3, "starting with GAP 4.12, the third argument <slots> is unused",
            " in ", INPUT_FILENAME(), ":", STRING_INT(INPUT_LINENUMBER()));
        if LEN_LIST(arg) = 2 then
            INFO_OBSOLETE(2, "the fourth argument <req> is unused",
                " in ", INPUT_FILENAME(), ":", STRING_INT(INPUT_LINENUMBER()));
        fi;
    fi;
    rep := NEW_FILTER( name );

    # Do some administrational work.
    atomic readwrite CATS_AND_REPS, FILTER_REGION do
        ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) );
        REGISTER_FILTER( rep, FLAG1_FILTER( rep ), 1, FNUM_REP );
    od;

    # Do not call this before adding 'rep' to 'FILTERS'.
    InstallTrueMethodNewFilter( super, rep );

    # Return the filter.
    return rep;
end );


#############################################################################
##
#F  DeclareRepresentation( <name>, <super>[, <slots>[, <req>]] )
##
##  <#GAPDoc Label="DeclareRepresentation">
##  <ManSection>
##  <Func Name="DeclareRepresentation" Arg='name, super[, slots[, req]]'/>
##
##  <Description>
##  does the same as <Ref Func="NewRepresentation"/> and then binds
##  the result to the global variable <A>name</A>. The variable
##  must previously be writable, and is made read-only by this function.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="BasicRepresentations">
##  <ManSection>
##  <Heading>Basic Representations of Objects</Heading>
##  <Filt Name="IsInternalRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsDataObjectRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsPositionalObjectRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsComponentObjectRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  &GAP; distinguishes four essentially different ways to represent
##  objects.
##  First there are the representations <Ref Filt="IsInternalRep"/> for
##  internal objects such as integers and permutations,
##  and <Ref Filt="IsDataObjectRep"/> for other objects that are created
##  and whose data are accessible only by kernel functions.
##  The data structures underlying such objects cannot be manipulated
##  at the &GAP; level.
##  <P/>
##  All other objects are either in the representation
##  <Ref Filt="IsComponentObjectRep"/> or in the representation
##  <Ref Filt="IsPositionalObjectRep"/>,
##  see&nbsp;<Ref Sect="Component Objects"/>
##  and&nbsp;<Ref Sect="Positional Objects"/>.
##  <P/>
##  An object can belong to several representations in the sense that it
##  lies in several subrepresentations of <Ref Filt="IsComponentObjectRep"/>
##  or of <Ref Filt="IsPositionalObjectRep"/>.
##  The representations to which an object belongs should form a chain
##  and either two representations are disjoint
##  or one is contained in the other.
##  So the subrepresentations of <Ref Filt="IsComponentObjectRep"/> and
##  <Ref Filt="IsPositionalObjectRep"/> each form trees.
##  In the language of Object Oriented Programming,
##  we support only single inheritance for representations.
##  <P/>
##  These trees are typically rather shallow, since for one representation
##  to be contained in another implies that all the components of the data
##  structure implied by the containing representation, are present in,
##  and have the same meaning in, the smaller representation (whose data
##  structure presumably contains some additional components).
##  <P/>
##  Objects may change their representation, for example a mutable list
##  of characters can be converted into a string.
##  <P/>
##  All representations in the library are created during initialization,
##  in particular they are not created dynamically at runtime.
##  <P/>
##  Examples of subrepresentations of <Ref Filt="IsPositionalObjectRep"/> are
##  <C>IsModulusRep</C>, which is used for residue classes in the ring of
##  integers, and <C>IsDenseCoeffVectorRep</C>, which is used for elements of
##  algebras that are defined by structure constants.
##  <P/>
##  An important subrepresentation of <Ref Filt="IsComponentObjectRep"/> is
##  <Ref Filt="IsAttributeStoringRep"/>,
##  which is used for many domains and some other objects.
##  It provides automatic storing of all attribute values
##  (see Section <Ref Sect="Attributes"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsInternalRep", IS_OBJECT );
DeclareRepresentation( "IsPositionalObjectRep", IS_OBJECT );
DeclareRepresentation( "IsComponentObjectRep", IS_OBJECT );
DeclareRepresentation( "IsDataObjectRep", IS_OBJECT );

# the following are for HPC-GAP, but we also provide them in plain GAP, to
# make it easier to write code which works in both.
DeclareRepresentation( "IsNonAtomicComponentObjectRep",
        IsComponentObjectRep );
DeclareRepresentation( "IsReadOnlyPositionalObjectRep",
        IsPositionalObjectRep );
DeclareRepresentation( "IsAtomicPositionalObjectRep",
        IsPositionalObjectRep );

#############################################################################
##
#R  IsAttributeStoringRep
##
##  <#GAPDoc Label="IsAttributeStoringRep">
##  <ManSection>
##  <Filt Name="IsAttributeStoringRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  Objects in this representation have default methods to get stored values
##  of attributes and &ndash;if they are immutable&ndash; to store attribute
##  values automatically once they have been computed.
##  <Index>system getter</Index>
##  <Index>system setter</Index>
##  (These methods are called the <Q>system getter</Q> and the
##  <Q>system setter</Q> of the attribute, respectively.)
##  <P/>
##  As a consequence,
##  for immutable objects in <Ref Filt="IsAttributeStoringRep"/>,
##  subsequent calls to an attribute will return the <E>same</E> object.
##  <P/>
##  <E>Mutable</E> objects in <Ref Filt="IsAttributeStoringRep"/>
##  are allowed, but attribute values are not stored automatically in them.
##  Such objects are useful because they may later be made immutable using
##  <Ref Func="MakeImmutable"/>, at which point they will start storing
##  all attribute values.
##  <P/>
##  Note that one can force an attribute value to be stored in a mutable
##  object in <Ref Filt="IsAttributeStoringRep"/>,
##  by explicitly calling the attribute setter.
##  This feature should be used with care.
##  For example, think of a mutable matrix whose rank or trace gets stored,
##  and the values later become wrong when somebody changes the matrix
##  entries.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= Group( (1,2)(3,4), (1,3)(2,4) );;
##  gap> IsAttributeStoringRep( g );
##  true
##  gap> HasSize( g );  Size( g );  HasSize( g );
##  false
##  4
##  true
##  gap> r:= 7/4;;
##  gap> IsAttributeStoringRep( r );
##  false
##  gap> Int( r );  HasInt( r );
##  1
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Note that we do not promise anything about
##  the component names used for storing attribute values.
##  (In earlier versions of GAP, a rule had been stated in a code file,
##  but this rule was not part of the manuals.)
##
DeclareRepresentation( "IsAttributeStoringRep", IsComponentObjectRep );


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
                            IsComponentObjectRep );
#T why not `IsAttributeStoringRep' ?

DeclareRepresentation( "IsTypeDefaultRep",
                            IsPositionalObjectRep );

if IsHPCGAP then
    BIND_GLOBAL( "FamilyOfFamilies", AtomicRecord( rec() ) );
else
    BIND_GLOBAL( "FamilyOfFamilies", rec() );
fi;

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

# for caching types of homogeneous lists, assigned in kernel when needed
if IsHPCGAP then
    FamilyOfFamilies!.TYPES_LIST_FAM  := MakeWriteOnceAtomic(AtomicList(27));
else
    FamilyOfFamilies!.TYPES_LIST_FAM  := [];
    # for efficiency
    FamilyOfFamilies!.TYPES_LIST_FAM[27] := 0;
fi;

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
BIND_GLOBAL( "TypeOfFamilyOfFamilies", [
      FamilyOfFamilies,
      WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfFamilies and IsFamilyDefaultRep
                                   and IsAttributeStoringRep
                                    ) ),
    false,
    NEW_TYPE_NEXT_ID ] );

if IsHPCGAP then
    BIND_GLOBAL( "FamilyOfTypes", AtomicRecord( rec() ) );
else
    BIND_GLOBAL( "FamilyOfTypes", rec() );
fi;

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

# for caching types of homogeneous lists, assigned in kernel when needed
if IsHPCGAP then
    FamilyOfTypes!.TYPES_LIST_FAM  := MakeWriteOnceAtomic(AtomicList(27));
else
    FamilyOfTypes!.TYPES_LIST_FAM  := [];
    # for efficiency
    FamilyOfTypes!.TYPES_LIST_FAM[27] := 0;
fi;

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
BIND_GLOBAL( "TypeOfFamilyOfTypes",  [
    FamilyOfFamilies,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfTypes and IsTypeDefaultRep ) ),
    false,
    NEW_TYPE_NEXT_ID ] );

SET_TYPE_POSOBJ( TypeOfTypes,            TypeOfTypes );
SET_TYPE_POSOBJ( TypeOfFamilies,         TypeOfTypes );
SET_TYPE_POSOBJ( TypeOfFamilyOfTypes,    TypeOfTypes );
SET_TYPE_POSOBJ( TypeOfFamilyOfFamilies, TypeOfTypes );

SET_TYPE_COMOBJ( FamilyOfFamilies, TypeOfFamilyOfFamilies );
SET_TYPE_COMOBJ( FamilyOfTypes,    TypeOfFamilyOfTypes    );

if IsHPCGAP then
    MakeReadOnlyObj(TypeOfFamilyOfFamilies);
    MakeReadOnlyObj(TypeOfFamilyOfTypes);
    MakeReadOnlyObj(TypeOfFamilies);
    MakeReadOnlyObj(TypeOfTypes);
fi;

#############################################################################
##
#O  CategoryFamily( <elms_filter> ) . . . . . .  category of certain families
##
##  <#GAPDoc Label="CategoryFamily">
##  <ManSection>
##  <Func Name="CategoryFamily" Arg='cat'/>
##
##  <Description>
##  For a category <A>cat</A>,
##  <Ref Func="CategoryFamily"/> returns the <E>family category</E>
##  of <A>cat</A>.
##  This is a category in which all families lie that know from their
##  creation that all their elements are in the category <A>cat</A>,
##  see&nbsp;<Ref Sect="Families"/>.
##  <P/>
##  For example, a family of associative words is in the category
##  <C>CategoryFamily( IsAssocWord )</C>,
##  and one can distinguish such a family from others by this category.
##  So it is possible to install methods for operations that require one
##  argument to be a family of associative words.
##  <P/>
##  <Ref Func="CategoryFamily"/> is quite technical,
##  and in fact of minor importance.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "CATEGORIES_FAMILY", [] );
if IsHPCGAP then
    ShareSpecialObj(CATEGORIES_FAMILY);
fi;

BIND_GLOBAL( "CategoryFamily", function ( elms_filter )
    local    pair, fam_filter, super, flags, name;

    name:= "CategoryFamily(";
    APPEND_LIST_INTR( name, SHALLOW_COPY_OBJ( NAME_FUNC( elms_filter ) ) );
    APPEND_LIST_INTR( name, ")" );
    CONV_STRING( name );

    elms_filter:= FLAGS_FILTER( elms_filter );

    atomic readwrite CATEGORIES_FAMILY do
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
        ADD_LIST( CATEGORIES_FAMILY, MakeImmutable( [ elms_filter, fam_filter ] ) );
        return fam_filter;
    od;
end );


#############################################################################
##
#F  DeclareCategoryFamily( <name> )
##
##  <ManSection>
##  <Func Name="DeclareCategoryFamily" Arg='name'/>
##
##  <Description>
##  creates the family category of the category that is bound to the global
##  variable with name <A>name</A>,
##  and binds it to the global variable with name <C><A>name</A>Family</C>.
##  </Description>
##  </ManSection>
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

    family := type![ POS_FAMILY_TYPE ];
    flags  := type![ POS_FLAGS_TYPE ];
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
