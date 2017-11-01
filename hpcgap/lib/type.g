#############################################################################
##
#W  type.g                      GAP library                  Martin Schönert
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file defines the format of families and types. Some functions 
##  are moved to type1.g, which is compiled
##


#############################################################################
##
#V  POS_DATA_TYPE . . . . . . . . position where the data of a type is stored
#V  POS_NUMB_TYPE . . . . . . . position where the number of a type is stored
#V  POS_FIRST_FREE_TYPE . . . . .  first position that has no overall meaning
##
##  <ManSection>
##  <Var Name="POS_DATA_TYPE"/>
##  <Var Name="POS_NUMB_TYPE"/>
##  <Var Name="POS_FIRST_FREE_TYPE"/>
##
##  <Description>
##  Note that the family and the flags list are stored at positions 1 and 2,
##  respectively.
##  </Description>
##  </ManSection>
##
BIND_CONSTANT( "POS_DATA_TYPE", 3 );
BIND_CONSTANT( "POS_NUMB_TYPE", 4 );
BIND_CONSTANT( "POS_FIRST_FREE_TYPE", 5 );


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
if TNUM_OBJ(2^30) = 0 then
    NEW_TYPE_NEXT_ID := -(2^60);
    NEW_TYPE_ID_LIMIT := 2^60-1;
else
    NEW_TYPE_NEXT_ID := -(2^28);
    NEW_TYPE_ID_LIMIT := 2^28-1;
fi;


#############################################################################
##
#F  DeclareCategoryKernel( <name>, <super>, <filter> )  create a new category
##
BIND_GLOBAL( "DeclareCategoryKernel", function ( name, super, cat )
    if not IS_IDENTICAL_OBJ( cat, IS_OBJECT ) then
        atomic readwrite FILTER_REGION, CATS_AND_REPS do
        ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
        FILTERS[ FLAG1_FILTER( cat ) ] := cat;
        IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( cat ) );
        INFO_FILTERS[ FLAG1_FILTER( cat ) ] := 1;
        RANK_FILTERS[ FLAG1_FILTER( cat ) ] := 1;
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
##  <Ref Func="IsMultiplicativeElementWithInverse"/>
##  or a subcategory of it.
##  If no specific supercategory of <A>cat</A> is known,
##  <A>super</A> may be <Ref Func="IsObject"/>.
##  <P/>
##  The optional third argument <A>rank</A> denotes the incremental rank
##  (see&nbsp;<Ref Sect="Filters"/>) of <A>cat</A>,
##  the default value is 1.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NewCategory", function ( arg )
    local   cat;

    # Create the filter.
    cat:= NEW_FILTER( arg[1] );
    InstallTrueMethodNewFilter( arg[2], cat );

    # Do some administrational work.
    atomic readwrite CATS_AND_REPS do
    ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( cat ) );
    od;
    atomic FILTER_REGION do
    FILTERS[ FLAG1_FILTER( cat ) ] := cat;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( cat ) );

    if LEN_LIST( arg ) = 3 and IS_INT( arg[3] ) then
      RANK_FILTERS[ FLAG1_FILTER( cat ) ]:= arg[3];
    else
      RANK_FILTERS[ FLAG1_FILTER( cat ) ]:= 1;
    fi;
    INFO_FILTERS[ FLAG1_FILTER( cat ) ] := 2;
    od;

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
##  does the same as <Ref Func="NewCategory"/>
##  and additionally makes the variable <A>name</A> read-only.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DeclareCategory", function( arg )
    BIND_GLOBAL( arg[1], CALL_FUNC_LIST( NewCategory, arg ) );
end );


#############################################################################
##
#F  DeclareRepresentationKernel( <name>, <super>, <slots> [,<req>], <filt> )
##
##  <ManSection>
##  <Func Name="DeclareRepresentationKernel" Arg='name, super, slots [,req], filt'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "DeclareRepresentationKernel", function ( arg )
    local   rep, filt;
    if REREADING then
        atomic readonly CATS_AND_REPS, FILTER_REGION do
        for filt in CATS_AND_REPS do
            if NAME_FUNC(FILTERS[filt]) = arg[1] then
                Print("#W DeclareRepresentationKernel \"",arg[1],"\" in Reread. ");
                Print("Change of Super-rep not handled\n");
                return FILTERS[filt];
            fi;
        od;
        od;
    fi;
    atomic readwrite CATS_AND_REPS, FILTER_REGION do
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
    od;
    InstallTrueMethod( arg[2], rep );
    BIND_GLOBAL( arg[1], rep );
    SET_NAME_FUNC( rep, arg[1] );
end );



#############################################################################
##
#F  NewRepresentation( <name>, <super>, <slots>[, <req>] )  .  representation
##
##  <#GAPDoc Label="NewRepresentation">
##  <ManSection>
##  <Func Name="NewRepresentation" Arg='name, super, slots[, req]'/>
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
##  of the four representations <C>IsInternalRep</C>, <C>IsDataObjectRep</C>,
##  <C>IsComponentObjectRep</C>, <C>IsPositionalObjectRep</C>.
##  The data describing objects in the former two can be accessed only via
##  &GAP; kernel functions, the data describing objects in the latter two
##  is accessible also in library functions,
##  see&nbsp;<Ref Sect="Component Objects"/>
##  and&nbsp;<Ref Sect="Positional Objects"/> for the details.
##  <P/>
##  The third argument <A>slots</A> is a list either of integers or of
##  strings.
##  In the former case, <A>rep</A> must be <C>IsPositionalObjectRep</C> or a
##  subrepresentation of it, and <A>slots</A> tells what positions of the
##  objects in the representation <A>rep</A> may be bound.
##  In the latter case, <A>rep</A> must be <C>IsComponentObjectRep</C> or a
##  subrepresentation of, and <A>slots</A> lists the admissible names of
##  components that objects in the representation <A>rep</A> may have.
##  The admissible positions resp. component names of <A>super</A> need not
##  be be listed in <A>slots</A>.
##  <P/>
##  The incremental rank (see&nbsp;<Ref Sect="Filters"/>)
##  of <A>rep</A> is 1.
##  <P/>
##  Note that for objects in the representation <A>rep</A>,
##  of course some of the component names and positions reserved via
##  <A>slots</A> may be unbound.
##  <P/>
##  Examples for the use of <Ref Func="NewRepresentation"/> can be found
##  in&nbsp;<Ref Sect="Component Objects"/>,
##  <Ref Sect="Positional Objects"/>, and also in
##  <Ref Sect="A Second Attempt to Implement Elements of Residue Class Rings"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NewRepresentation", function ( arg )
    local   rep, filt;

    # Do *not* create a new representation when the file is reread.
    if REREADING then
        atomic readonly CATS_AND_REPS, readwrite FILTER_REGION do
        for filt in CATS_AND_REPS do
            if NAME_FUNC(FILTERS[filt]) = arg[1] then
                Print("#W NewRepresentation \"",arg[1],"\" in Reread. ");
                Print("Change of Super-rep not handled\n");
                return FILTERS[filt];
            fi;
        od;
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
    atomic readwrite CATS_AND_REPS, FILTER_REGION do
    ADD_LIST( CATS_AND_REPS, FLAG1_FILTER( rep ) );
    FILTERS[ FLAG1_FILTER( rep ) ] := rep;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( rep ) );
    RANK_FILTERS[ FLAG1_FILTER( rep ) ] := 1;
    INFO_FILTERS[ FLAG1_FILTER( rep ) ] := 4;
    od;

    # Return the filter.
    return rep;
end );


#############################################################################
##
#F  DeclareRepresentation( <name>, <super>, <slots> [,<req>] )
##
##  <#GAPDoc Label="DeclareRepresentation">
##  <ManSection>
##  <Func Name="DeclareRepresentation" Arg='name, super, slots [,req]'/>
##
##  <Description>
##  does the same as <Ref Func="NewRepresentation"/>
##  and additionally makes the variable <A>name</A> read-only.
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
##  <ManSection>
##  <Filt Name="IsInternalRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsPositionalObjectRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsComponentObjectRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsDataObjectRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  the four basic representations in &GAP;
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsInternalRep", IS_OBJECT, [], IS_OBJECT );
DeclareRepresentation( "IsPositionalObjectRep", IS_OBJECT, [], IS_OBJECT );
DeclareRepresentation( "IsComponentObjectRep", IS_OBJECT, [], IS_OBJECT );
DeclareRepresentation( "IsDataObjectRep", IS_OBJECT, [], IS_OBJECT );

DeclareRepresentation( "IsNonAtomicComponentObjectRep",
        IsComponentObjectRep, [], IS_OBJECT); 
DeclareRepresentation( "IsReadOnlyPositionalObjectRep",
        IsPositionalObjectRep, [], IS_OBJECT); 
DeclareRepresentation( "IsAtomicPositionalObjectRep",
        IsPositionalObjectRep, [], IS_OBJECT); 

#############################################################################
##
#R  IsAttributeStoringRep
##
##  <#GAPDoc Label="IsAttributeStoringRep">
##  <ManSection>
##  <Filt Name="IsAttributeStoringRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  Objects in this representation have default  methods to get the values of
##  stored  attributes  and -if they  are immutable-  to store the  values of
##  attributes after their computation.
##  <P/>
##  The name of the  component that holds  the value of  an attribute is  the
##  name of the attribute, with the first letter turned to lower case.
##  <!-- This will be changed eventually, in order to avoid conflicts between-->
##  <!-- ordinary components and components corresponding to attributes.-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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

BIND_GLOBAL( "FamilyOfFamilies", AtomicRecord( rec() ) );

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

# for chaching types of homogeneous lists, assigned in kernel when needed 
FamilyOfFamilies!.TYPES_LIST_FAM  := MakeWriteOnceAtomic(AtomicList(27));
# for efficiency
FamilyOfFamilies!.TYPES_LIST_FAM[27] := 0;

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
BIND_GLOBAL( "TypeOfFamilyOfFamilies", [
      FamilyOfFamilies,
      WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfFamilies and IsFamilyDefaultRep
                                   and IsAttributeStoringRep
                                    ) ),
    false,
    NEW_TYPE_NEXT_ID ] );
MakeReadOnly(TypeOfFamilyOfFamilies);

BIND_GLOBAL( "FamilyOfTypes", AtomicRecord( rec() ) );

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

# for chaching types of homogeneous lists, assigned in kernel when needed 
FamilyOfTypes!.TYPES_LIST_FAM  := MakeWriteOnceAtomic(AtomicList(27));
# for efficiency
FamilyOfTypes!.TYPES_LIST_FAM[27] := 0;

NEW_TYPE_NEXT_ID := NEW_TYPE_NEXT_ID+1;
BIND_GLOBAL( "TypeOfFamilyOfTypes",  [
    FamilyOfFamilies,
    WITH_IMPS_FLAGS( FLAGS_FILTER( IsFamilyOfTypes and IsTypeDefaultRep ) ),
    false,
    NEW_TYPE_NEXT_ID ] );
MakeReadOnly(TypeOfFamilyOfTypes);

SET_TYPE_COMOBJ( FamilyOfFamilies, TypeOfFamilyOfFamilies );
SET_TYPE_POSOBJ( TypeOfFamilies,   TypeOfTypes            );
MakeReadOnly(TypeOfFamilies);

SET_TYPE_COMOBJ( FamilyOfTypes,    TypeOfFamilyOfTypes    );
SET_TYPE_POSOBJ( TypeOfTypes,      TypeOfTypes            );
MakeReadOnly(TypeOfTypes);


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
##  see&nbsp;<Ref Sect="Creating Families"/>.
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
ShareSpecialObj(CATEGORIES_FAMILY);

BIND_GLOBAL( "CategoryFamily", function ( elms_filter )
    local    pair, fam_filter, super, flags, name;

    name:= "CategoryFamily(";
    APPEND_LIST_INTR( name, SHALLOW_COPY_OBJ( NAME_FUNC( elms_filter ) ) );
    APPEND_LIST_INTR( name, ")" );
    CONV_STRING( name );

    elms_filter:= FLAGS_FILTER( elms_filter );

    # Check whether the desired family category is already defined.
    atomic readonly CATEGORIES_FAMILY do
    for pair in CATEGORIES_FAMILY do
      if pair[1] = elms_filter then
        return pair[2];
      fi;
    od;
    od;
    
    atomic readwrite CATEGORIES_FAMILY do
    # Check again whether category is already defined (necessary
    # since we released and re-acquired locks)
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
    ADD_LIST( CATEGORIES_FAMILY, 
            MIGRATE_RAW([ elms_filter, fam_filter ], CATEGORIES_FAMILY) );
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
