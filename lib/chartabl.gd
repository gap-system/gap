#############################################################################
##
#W  chartabl.gd                 GAP library                     Thomas Breuer
#W                                                           & Goetz Pfeiffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the definition of categories of character table like
##  objects, and their properties, attributes, operations, and functions.
##
Revision.chartabl_gd :=
    "@(#)$Id$";


#############################################################################
##
#T TODO:
##
#T introduce fusion objects!

#T 'CharTable' produces HUGE amounts of garbage
#T (e.g., for 'SolvableGroup( "Q8+Q8" )' compute all tables for normal
#T subgroups; it is a big difference with what initial workspace GAP was
#T started ...)

#T 'PermutationCharacter' should return a proper character, not a list!

#T disallow 'Sort', change to 'SortedCharacterTable'!

#T remove irredinfo, store in irreds. themselves


#############################################################################
##
#V  InfoCharacterTable
##
InfoCharacterTable := NewInfoClass( "InfoCharacterTable" );


#############################################################################
##
##  1. categories and families of character tables
##

#############################################################################
##
#C  IsNearlyCharacterTable( <obj> )
#C  IsCharacterTable( <obj> )
#C  IsOrdinaryTable( <obj> )
#C  IsBrauerTable( <obj> )
#C  IsCharacterTableInProgress( <obj> )
##
##  Every character table like object lies in the category
##  'IsNearlyCharacterTable'.
##  There are four important subcategories,
##  namely the *ordinary* tables in 'IsOrdinaryTable',
##  the *Brauer* tables in 'IsBrauerTable',
##  the union of these two, in 'IsCharacterTable',
##  and the *incomplete ordinary* tables in 'IsCharacterTableInProgress'.
##
##  We want to distinguish ordinary and Brauer tables because Brauer tables
##  may delegate tasks to the underlying ordinary table, for example the
##  computation of power maps.
##
##  Furthermore, 'IsOrdinaryTable' and 'IsBrauerTable' denote
##  tables that provide enough information to compute all power maps
##  and irreducible characters (and in the case of Brauer tables to get the
##  ordinary table), for example because the underlying group is known
##  or because the table is a library table.
##  We want to distinguish these tables from those of partially known
##  ordinary tables that cannot be asked for all power maps or all
##  irreducible characters.
##
##  The latter ``table like objects'' are in 'IsCharacterTableInProgress'.
##  These are first of all *mutable* objects.
##  So *nothing is stored automatically* on such a table,
##  since otherwise one has no control of side-effects when
##  a hypothesis is changed.
##  Operations for such tables may return more general values than for
##  other tables, for example a power map may be a multi-valued mapping.
##
##  Several attributes for groups are valid also for their character tables.
##  These are on one hand those that have the same meaning and can be
##  read off resp. computed from the character table (think of tables or
##  incomplete tables that have no access to a group), such as 'Size',
##  'Irr', 'IsAbelian'.
##  On the other hand, there are attributes such as 'SizesCentralizers',
##  'SizesConjugacyClasses', 'OrdersClassRepresentatives' that coincide
##  with the attributes for groups in the case of ordinary tables but refer
##  to the $p$-regular conjugacy classes in the case of Brauer tables in
##  characteristic $p$.
##
##  Attributes and properties that are *defined* for groups but are valid
##  also for tables:
##
##  For an ordinary character table with underlying group, the group has
##  priority over the table, i.e., if the table is asked for 'Irr( <tbl> )',
##  say, it may delegate this task to the group, but if the group is asked
##  for 'Irr( <G> )', it must not ask its table.
##  Only if a group knows its ordinary table and if this table knows the
##  value of an attribute then the group may fetch this value from its
##  ordinary character table.
##
##  The same principle holds for the data that refer to each other in the
##  group and in the table.
##  For example, a Brauer table may delegate the task to compute its
##  irreducible characters (one of its attributes) to the group (for which
##  the desired characters belong to the attribute 'ComputedIBrs'),
##  but the group must not ask the Brauer table.
##  Only if the group knows already the Brauer table (in the attribute
##  'ComputedBrauerTables') and if this knows already its irreducibles
##  then the group may fetch them.
##
#T problem:
#T if the table knows already class lengths etc.,
#T the group may fetch them;
#T but if the conjugacy classes of the group are not yet computed,
#T how do we guarantee that the classes are in the right succession
#T when they are computed later???
#T Note that the classes computation may take advantage of the known
#T distribution of orders, power maps etc.
#T (Or shall such a notification of a known table for a group be handled
#T more restrictive, e.g., only via explicit assignments?)
##
##  Conversely, if an attribute is defined for character tables but is valid
##  also for groups (for example 'TrivialCharacter'), the group may ask the
##  table but the table must not ask the group.
##  The same holds also for operations, e.g., 'InducedClassFunction'.
##
IsNearlyCharacterTable := NewCategory( "IsNearlyCharacterTable", IsObject );

IsCharacterTable := NewCategory( "IsCharacterTable",
    IsNearlyCharacterTable );

IsOrdinaryTable := NewCategory( "IsOrdinaryTable",
    IsCharacterTable );

IsBrauerTable := NewCategory( "IsBrauerTable",
    IsCharacterTable );

IsCharacterTableInProgress := NewCategory( "IsCharacterTableInProgress",
    IsNearlyCharacterTable and IsMutable );


#############################################################################
##
#V  NearlyCharacterTablesFamily
##
##  All character table like objects belong to the same family.
##
NearlyCharacterTablesFamily := NewFamily( "NearlyCharacterTablesFamily",
    IsNearlyCharacterTable );


#############################################################################
##
##  2. operations for groups that concern characters and character tables
##

#############################################################################
##
#A  CharacterDegrees( <G> )
#A  CharacterDegrees( <tbl> )
##
##  is a collected list of the degrees of the irreducible characters of
##  the group <G>.
##
CharacterDegrees := NewAttribute( "CharacterDegrees", IsGroup );
SetCharacterDegrees := Setter( CharacterDegrees );
HasCharacterDegrees := Tester( CharacterDegrees );


#############################################################################
##
#O  CharacterTable( <G>, <p> )  . . . . . characteristic <p> table of a group
#O  CharacterTable( <G> ) . . . . . . . . . . ordinary char. table of a group
#O  CharacterTable( <name> )  . . . . . . . . . library table with given name
##
CharacterTable := NewOperation( "CharacterTable", [ IsGroup, IsInt ] );


#############################################################################
##
#A  OrdinaryCharacterTable( <G> )
##
OrdinaryCharacterTable := NewAttribute(
    "OrdinaryCharacterTable", IsGroup );
SetOrdinaryCharacterTable := Setter( OrdinaryCharacterTable );
HasOrdinaryCharacterTable := Tester( OrdinaryCharacterTable );


#############################################################################
##
#A  ComputedBrauerTables( <G> )
##
##  is the list of Brauer tables computed already,
##  at position $p$ for characteristic $p$.
##  
ComputedBrauerTables := NewAttribute(
    "ComputedBrauerTables", IsGroup, "mutable" );
SetComputedBrauerTables := Setter( ComputedBrauerTables );
HasComputedBrauerTables := Tester( ComputedBrauerTables );


#############################################################################
##
#A  Irr( <G> )
#A  Irr( <ordtbl> )
##
##  is the list of all complex ordinary irreducible characters of the finite
##  group <G> resp. the ordinary character table <tbl>.
##
Irr := NewAttribute( "Irr", IsGroup );
SetIrr := Setter( Irr );
HasIrr := Tester( Irr );


#############################################################################
##
#O  IBr( <G>, <p> )
#O  IBr( <tbl> )
##
##  is the list of all complex irreducible Brauer characters in
##  characteristic <p> of the finite group <G>.
##
##  (Computed lists of irreducible Brauer characters are stored in the list
##  'ComputedIBrs( <G> )'.)
##
IBr := NewOperation( "IBr", [ IsGroup, IsPosRat and IsInt ] );


#############################################################################
##
#A  ComputedIBrs( <G> )
##
##  is the list where position <p> is reserved for 'IBr( <G>, <p> )'.
##
ComputedIBrs := NewAttribute( "ComputedIBrs", IsGroup, "mutable" );
SetComputedIBrs := Setter( ComputedIBrs );
HasComputedIBrs := Tester( ComputedIBrs );


#############################################################################
##
#A  ComputedBrauerTables( <tbl> )
##
ComputedBrauerTables := NewAttribute( "ComputedBrauerTables",
    IsOrdinaryTable, "mutable" );
SetComputedBrauerTables := Setter( ComputedBrauerTables );
HasComputedBrauerTables := Tester( ComputedBrauerTables );


#############################################################################
##
##  3. ...
##

#############################################################################
##
#A  IBrTable( <tbl> )
##
##  is the list of irreducible Brauer characters of the Brauer table <tbl>.
##  Note that 'IBr' is defined for two arguments, namely a group and a prime,
##  and the attribute 'ComputedIBrs' for groups is of course not what we want
##  here.
##
##  (There is a method for 'IBr' and Brauer tables that simply calls
##  'IBrTable' in order to allow the call 'IBr( <tbl> )'.)
##  
IBrTable := NewAttribute( "IBrTable", IsBrauerTable );
SetIBrTable := Setter( IBrTable );
HasIBrTable := Tester( IBrTable );


#############################################################################
##
#A  UnderlyingCharacteristic( <tbl> )
#A  UnderlyingCharacteristic( <psi> )
##
##  For a character table or Brauer table <tbl>, ...
##
##  For a class function <psi>, this belongs to the defining data, and is
##  stored in the family of class functions.
##  (We cannot use the attribute 'Characteristic' to denote this, since
##  of course each Brauer character is an element of characteristic zero
##  in the sense of {\GAP}.)
##
UnderlyingCharacteristic := NewAttribute( "UnderlyingCharacteristic",
    IsNearlyCharacterTable );
SetUnderlyingCharacteristic := Setter( UnderlyingCharacteristic );
HasUnderlyingCharacteristic := Tester( UnderlyingCharacteristic );


#############################################################################
##
#A  BlocksInfo( <tbl> )
##
##  is ...
##
BlocksInfo := NewAttribute( "BlocksInfo", IsNearlyCharacterTable );
SetBlocksInfo := Setter( BlocksInfo );
HasBlocksInfo := Tester( BlocksInfo );


#############################################################################
##
#A  ClassFusions( <tbl> )
##
##  is a list of class fusions from <tbl> into other character table objects.
##
ClassFusions := NewAttribute( "ClassFusions", IsNearlyCharacterTable );
SetClassFusions := Setter( ClassFusions );
HasClassFusions := Tester( ClassFusions );


#############################################################################
##
#A  ClassParameters( <tbl> )
##
ClassParameters := NewAttribute( "ClassParameters", IsNearlyCharacterTable );
SetClassParameters := Setter( ClassParameters );
HasClassParameters := Tester( ClassParameters );


#############################################################################
##
#A  ClassNames( <tbl> )
##
#T allow class names (optional) such as in the ATLAS ?
##
ClassNames := NewAttribute( "ClassNames", IsNearlyCharacterTable );
SetClassNames := Setter( ClassNames );
HasClassNames := Tester( ClassNames );


#############################################################################
##
#A  DisplayOptions( <tbl> )
##
#T is a more general attribute?
##
DisplayOptions := NewAttribute( "DisplayOptions", IsNearlyCharacterTable );
SetDisplayOptions := Setter( DisplayOptions );
HasDisplayOptions := Tester( DisplayOptions );


#############################################################################
##
#A  Identifier( <tbl> )
##
##  is a string that is used to identify the table <tbl> when it is not
##  possible to use the object <tbl> itself, for example when a class fusion
##  to the library table <tbl> shall be described.
##
Identifier := NewAttribute( "Identifier", IsNearlyCharacterTable );
SetIdentifier := Setter( Identifier );
HasIdentifier := Tester( Identifier );


#############################################################################
##
#A  InfoText( <tbl> )
##
##  is a string with information about <tbl>.
##
InfoText := NewAttribute( "InfoText", IsNearlyCharacterTable );
SetInfoText := Setter( InfoText );
HasInfoText := Tester( InfoText );


#############################################################################
##
#A  InverseClasses( <tbl> )
##
InverseClasses := NewAttribute( "InverseClasses", IsNearlyCharacterTable );
SetInverseClasses := Setter( InverseClasses );
HasInverseClasses := Tester( InverseClasses );


#############################################################################
##
#A  NamesOfFusionSources( <tbl> )
##
##  is the list of identifiers of all those tables that have fusions into
##  <tbl> stored.
##
NamesOfFusionSources := NewAttribute( "NamesOfFusionSources",
    IsNearlyCharacterTable );
SetNamesOfFusionSources := Setter( NamesOfFusionSources );
HasNamesOfFusionSources := Tester( NamesOfFusionSources );


#############################################################################
##
#A  OrdinaryTable( <tbl> )
##
##  is the ordinary character table corresponding to the Brauer table <tbl>.
##
OrdinaryTable := NewAttribute( "OrdinaryTable", IsBrauerTable );
SetOrdinaryTable := Setter( OrdinaryTable );
HasOrdinaryTable := Tester( OrdinaryTable );


#############################################################################
##
#A  ComputedPowerMaps( <tbl> )
##
##  is a list that stores at position $p$ the $p$-th power map of the table
##  <tbl>.
##
ComputedPowerMaps := NewAttribute( "ComputedPowerMaps",
    IsNearlyCharacterTable, "mutable" );
SetComputedPowerMaps := Setter( ComputedPowerMaps );
HasComputedPowerMaps := Tester( ComputedPowerMaps );


#############################################################################
##
#A  AutomorphismsOfTable( <tbl> )
##
AutomorphismsOfTable := NewAttribute( "AutomorphismsOfTable",
    IsNearlyCharacterTable );
SetAutomorphismsOfTable := Setter( AutomorphismsOfTable );
HasAutomorphismsOfTable := Tester( AutomorphismsOfTable );
#T use 'GlobalPartitionClasses' in 'TableAutomorphisms' ?
#T AutomorphismGroup( <tbl> ) ??


#############################################################################
##
#A  UnderlyingGroup( <tbl> )
##
##  Note that only the character table stores the underlying group,
##  the class functions can notify knowledge of the group via the
##  category 'IsClassFunctionWithGroup'.
##
UnderlyingGroup := NewAttribute( "UnderlyingGroup", IsNearlyCharacterTable );
SetUnderlyingGroup := Setter( UnderlyingGroup );
HasUnderlyingGroup := Tester( UnderlyingGroup );


#############################################################################
##
#O  CharacterTableDirectProduct( <tbl1>, <tbl2> )
##
##  is the table of the direct product of the character tables <tbl1>
##  and <tbl2>.
##
##  All power maps for primes dividing the size of the result will be
##  computed for the factors.
##
CharacterTableDirectProduct := NewOperation( "CharacterTableDirectProduct",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );


#############################################################################
##
#O  CharacterTableFactorGroup( <tbl>, <classes> )
##
CharacterTableFactorGroup := NewOperation( "CharacterTableFactorGroup",
    [ IsNearlyCharacterTable, IsHomogeneousList ] );


#############################################################################
##
#O  CharacterTableIsoclinic( <tbl> )
#O  CharacterTableIsoclinic( <tbl>, <classes_of_normal_subgroup> )
##
##  for table of groups $2.G.2$, the character table of the isoclinic group
##  (see ATLAS, Chapter 6, Section 7)
##
CharacterTableIsoclinic := NewOperation( "CharacterTableIsoclinic",
    [ IsNearlyCharacterTable ] );


#############################################################################
##
#F  CharacterTableQuaternionic( <4n> )
##
##  is the character table of the quaternionic group of order <4n>
##
CharacterTableQuaternionic := NewOperationArgs(
    "CharacterTableQuaternionic" );


#############################################################################
##
#O  CharacterTableRegular( <tbl>, <p> ) .  table consist. of <p>-reg. classes
##
##  is the table of the Brauer table in characteristic <p> corresp. to
##  the ordinary table <tbl>.
##
CharacterTableRegular := NewOperation( "CharacterTableRegular",
    [ IsNearlyCharacterTable, IsInt and IsPosRat ] );


#############################################################################
##
#O  CharacterTableSpecialized( <tbl>, <q> )
##
CharacterTableSpecialized := NewOperation( "CharacterTableSpecialized",
    [ IsCharacterTable, IsInt and IsPosRat ] );
#T is a generic table in 'IsCharacterTable' ?


#############################################################################
##
#O  PossibleClassFusions( <subtbl>, <tbl> )
#O  PossibleClassFusions( <subtbl>, <tbl>, <options> )
##
PossibleClassFusions := NewOperationArgs( "PossibleClassFusions" );


#############################################################################
##
#O  PossiblePowerMaps( <tbl>, <p> )
#O  PossiblePowerMaps( <tbl>, <p>, <options> )
##
PossiblePowerMaps := NewOperationArgs( "PossiblePowerMaps" );


#############################################################################
##
#O  PowerMap( <tbl>, <p> )
#O  PowerMap( <tbl>, <p>, <class> )
##
##  is the <p>-th power map of the table <tbl>.
##
PowerMap := NewOperation( "PowerMap", [ IsNearlyCharacterTable, IsInt ] );


#############################################################################
##
#V  SupportedOrdinaryTableInfo
#V  SupportedBrauerTableInfo
##
##  are used to create ordinary or Brauer character tables from records.
##  The most important applications are the construction of library tables
##  and the construction of derived tables (direct products, factors etc.)
##  by library functions.
##
SupportedOrdinaryTableInfo := [
    SetAutomorphismsOfTable,         "automorphismsOfTable",
    SetBlocksInfo,                   "blocksInfo",
    SetClassFusions,                 "classFusions",
    SetClassParameters,              "classParameters",
    SetComputedPowerMaps,            "computedPowerMaps",
    SetIdentifier,                   "identifier",
    SetInfoText,                     "infoText",
    SetIrr,                          "irr",
    SetIsSimpleGroup,                "isSimpleGroup",
    SetNamesOfFusionSources,         "namesOfFusionSources",
    SetOrdersClassRepresentatives,   "ordersClassRepresentatives",
    SetSizesCentralizers,            "sizesCentralizers",
    SetSizesConjugacyClasses,        "sizesConjugacyClasses",
    SetUnderlyingCharacteristic,     "underlyingCharacteristic",
    SetUnderlyingGroup,              "underlyingGroup",
    ];
#T what about classtext?

SupportedBrauerTableInfo := [
    SetAutomorphismsOfTable,         "automorphismsOfTable",
    SetBlocksInfo,                   "blocksInfo",
    SetClassFusions,                 "classFusions",
    SetClassParameters,              "classParameters",
    SetComputedPowerMaps,            "computedPowerMaps",
    SetIdentifier,                   "identifier",
    SetInfoText,                     "infoText",
    SetIBrTable,                     "iBrTable",
    SetNamesOfFusionSources,         "namesOfFusionSources",
    SetOrdersClassRepresentatives,   "ordersClassRepresentatives",
    SetOrdinaryCharacterTable,       "ordinaryCharacterTable",
    SetSizesCentralizers,            "sizesCentralizers",
    SetSizesConjugacyClasses,        "sizesConjugacyClasses",
    SetUnderlyingCharacteristic,     "underlyingCharacteristic",
    SetUnderlyingGroup,              "underlyingGroup",
    ];


#############################################################################
##
#F  ConvertToCharacterTable( <record> ) . . . . create character table object
#F  ConvertToCharacterTableNC( <record> ) . . . create character table object
##
##  The components listed in 'SupportedOrdinaryTableInfo' are used to set
##  properties and attributes.
##  All other components will simply become components of the record object.
##  
ConvertToCharacterTable := NewOperationArgs( "ConvertToCharacterTable" );

ConvertToCharacterTableNC := NewOperationArgs( "ConvertToCharacterTableNC" );


#############################################################################
##
#F  ConvertToBrauerTable( <record> ) . . . . . . . create Brauer table object
#F  ConvertToBrauerTableNC( <record> ) . . . . . . create Brauer table object
##
##  The components listed in 'SupportedBrauerTableInfo' are used to set
##  properties and attributes.
##  All other components will simply become components of the record object.
##  
ConvertToBrauerTable := NewOperationArgs( "ConvertToBrauerTable" );

ConvertToBrauerTableNC := NewOperationArgs( "ConvertToBrauerTableNC" );


#T ConvertToTableInProgress ???

#############################################################################
##
#E  chartabl.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



