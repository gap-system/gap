#############################################################################
##
#W  ctbl.gd                     GAP library                     Thomas Breuer
#W                                                           & Goetz Pfeiffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the definition of categories of character table like
##  objects, and their properties, attributes, operations, and functions.
##
Revision.ctbl_gd :=
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
#V  SupportedOrdinaryTableInfo
#V  SupportedBrauerTableInfo
##
##  are used to create ordinary or Brauer character tables from records.
##  The most important applications are the construction of library tables
##  and the construction of derived tables (direct products, factors etc.)
##  by library functions.
##
##  'SupportedOrdinaryTableInfo' is a list that contains at position $2i-1$
##  an attribute getter function, and at position $2i$ the name of this
##  attribute.
##  This allows to set components with these names as attribute values.
##
##  Supported attributes must be created using 'NewAttributeSuppCT'.
##
SupportedOrdinaryTableInfo := [
    IsSimpleGroup,                "IsSimpleGroup",
    OrdersClassRepresentatives,   "OrdersClassRepresentatives",
    SizesCentralizers,            "SizesCentralizers",
    SizesConjugacyClasses,        "SizesConjugacyClasses",
    ];
#T what about classtext?

SupportedBrauerTableInfo := ShallowCopy( SupportedOrdinaryTableInfo );


#############################################################################
##
#F  NewAttributeSuppCT( <name>, <filter> )
#F  NewAttributeSuppCT( <name>, <filter>, "mutable" )
##
NewAttributeSuppCT := function( arg )
    if Length( arg ) = 2 then
      attr:= NewAttribute( arg[1], arg[2] );
    else
      attr:= NewAttribute( arg[1], arg[2], arg[3] );
    fi;
    Append( SupportedOrdinaryTableInfo, [ attr, arg[1] ] );
    Append( SupportedBrauerTableInfo, [ attr, arg[1] ] );
    return attr;
end;


#############################################################################
##
##  2. operations for groups that concern characters and character tables
##

#############################################################################
##
#F  CharacterDegrees( <G>, <p> )
#F  CharacterDegrees( <G> )
#F  CharacterDegrees( <tbl> )
##
##  In the first two forms, 'CharacterDegrees' returns a collected list of
##  the degrees of the absolutely irreducible characters of the group <G>,
##  in characteristic <p> resp. zero.
##
##  In the third form, 'CharacterDegrees' returns a collected list of the
##  degrees of the absolutely irreducible characters of the (ordinary or
##  Brauer) character table <tbl>.
##
#A  CharacterDegreesAttr( <G> )
#A  CharacterDegreesAttr( <tbl> )
##
##  is the attribute for storing the character degrees computed by
##  'CharacterDegrees'.
##
#O  CharacterDegreesOp( <G>, <char> )
##
##  is the operation called by 'CharacterDegrees' for that methods can be
##  installed.
##  (For the tables, one can call the attribute directly.)
##
CharacterDegrees := NewOperationArgs( "CharacterDegrees" );

CharacterDegreesAttr := NewAttribute( "CharacterDegreesAttr", IsGroup );
SetCharacterDegreesAttr := Setter( CharacterDegreesAttr );
HasCharacterDegreesAttr := Tester( CharacterDegreesAttr );

InstallIsomorphismMaintainedMethod( CharacterDegreesAttr,
    IsGroup and HasCharacterDegreesAttr, IsGroup );

CharacterDegreesOp := NewOperation( "CharacterDegreesOp",
    [ IsGroup, IsInt ] );


#############################################################################
##
#O  CharacterTable( <G>, <p> )  . . . . . characteristic <p> table of a group
#O  CharacterTable( <ordtbl>, <p> )
#O  CharacterTable( <G> ) . . . . . . . . . . ordinary char. table of a group
#O  CharacterTable( <name> )  . . . . . . . . . library table with given name
##
##  This dispatches to 'OrdinaryCharacterTable', 'BrauerCharacterTable',
##  or 'CharacterTableFromLibrary'.
##
CharacterTable := NewOperation( "CharacterTable", [ IsGroup, IsInt ] );


#############################################################################
##
#A  OrdinaryCharacterTable( <G> ) . . . . . . . . . . . . . . . . for a group
#A  OrdinaryCharacterTable( <modtbl> )  . . . .  for a Brauer character table
##
##  For Brauer character tables without underlying group, the value of this
##  attribute must be stored.
##
OrdinaryCharacterTable := NewAttribute(
    "OrdinaryCharacterTable", IsGroup );
SetOrdinaryCharacterTable := Setter( OrdinaryCharacterTable );
HasOrdinaryCharacterTable := Tester( OrdinaryCharacterTable );

Append( SupportedBrauerTableInfo, [
    OrdinaryCharacterTable, "OrdinaryCharacterTable",
    ] );


#############################################################################
##
#F  BrauerCharacterTable( <ordtbl>, <p> )
#O  BrauerCharacterTableOp( <ordtbl>, <p> )
#A  ComputedBrauerCharacterTables( <ordtbl> ) . . . . . . known Brauer tables
##
#O  BrauerCharacterTable( <G>, <p> )
##
##  'BrauerCharacterTable' returns the <p>-modular character table of the
##  ordinary character table <ordtbl>.
##  If the first argument is a group <G>, 'BrauerCharacterTable' delegates
##  to the ordinary character table of <G>.
##
##  The Brauer tables that were computed already by 'BrauerCharacterTable'
##  are stored as value of the attribute 'ComputedBrauerCharacterTables'
##  (at position $p$ for characteristic $p$).
##  Methods for the computation of Brauer tables can be installed for
##  the operation 'BrauerCharacterTableOp'.
##
BrauerCharacterTable := NewOperationArgs( "BrauerCharacterTable" );

BrauerCharacterTableOp := NewOperation( "BrauerCharacterTableOp",
    [ IsOrdinaryTable, IsInt and IsPosRat ] );

ComputedBrauerCharacterTables := NewAttribute(
    "ComputedBrauerCharacterTables", IsOrdinaryTable, "mutable" );


#############################################################################
##
#A  Irr( <G> )
#A  Irr( <ordtbl> )
#A  Irr( <modtbl> )
##
##  In the first two forms, 'Irr' returns the list of all complex ordinary
##  absolutely irreducible characters of the finite group <G> resp.
##  of the ordinary character table <ordtbl>.
##
##  In the third form, 'Irr' returns the absolutely irreducible Brauer
##  characters of the Brauer character table <modtbl>.
##  (Note that 'IBr' is just a function that is defined for two arguments,
##  a group and a prime;
##  Called with a Brauer table, 'IBr' calls 'Irr'.)
##
##  ('Irr' may delegate back to the group <G>.)
##
Irr := NewAttributeSuppCT( "Irr", IsGroup );
SetIrr := Setter( Irr );
HasIrr := Tester( Irr );


#############################################################################
##
#F  IBr( <G>, <p> )
#F  IBr( <modtbl> )
##
##  'IBr' returns the list of <p>-modular absolutely irreducible Brauer
##  characters of the group <G>.
##  (This is done by delegation to 'Irr' for the Brauer table in question.)
##
##  If the only argument is a Brauer character table <modtbl>,
##  'IBr' calls 'Irr( <modtbl> )'.
##  ('Irr' may delegate back to <G>.)
##
IBr := NewOperationArgs( "IBr" );


#############################################################################
##
##  3. ...
##


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
UnderlyingCharacteristic := NewAttributeSuppCT( "UnderlyingCharacteristic",
    IsNearlyCharacterTable );
SetUnderlyingCharacteristic := Setter( UnderlyingCharacteristic );
HasUnderlyingCharacteristic := Tester( UnderlyingCharacteristic );


#############################################################################
##
#A  BlocksInfo( <tbl> )
##
##  If <tbl> is a Brauer character table then the value of 'BlocksInfo'
##  is a list of records, the $i$-th entry containing information about
##  the $i$-th block.
##
##  If <tbl> is an ordinary character table then ...
##
BlocksInfo := NewAttributeSuppCT( "BlocksInfo", IsNearlyCharacterTable );
SetBlocksInfo := Setter( BlocksInfo );
HasBlocksInfo := Tester( BlocksInfo );


#############################################################################
##
#A  ClassPositionsOfNormalSubgroups( <ordtbl> )
##
##  Every normal subgroup of the group $G$ for that <ordtbl> is the ordinary
##  character table is a union of conjugacy classes.
##  `ClassPositionsOfNormalSubgroups' is the list of all positions lists of
##  the normal subgroups of $G$.
##
##  The entries of the list are sorted according to increasing length.
##
ClassPositionsOfNormalSubgroups := NewAttribute(
    "ClassPositionsOfNormalSubgroups", IsOrdinaryTable );
SetClassPositionsOfNormalSubgroups := Setter(
    ClassPositionsOfNormalSubgroups );
HasClassPositionsOfNormalSubgroups := Tester(
    ClassPositionsOfNormalSubgroups );


#############################################################################
##
#A  IrredInfo( <tbl> )
##
##  a list of records, the $i$-th entry belonging to the $i$-th irreducible
##  character.
##
##  Usual entries are 
##  'classparam'
##
#T remove this, better store the info in the irred. characters themselves
#T ('IrredInfo' is used in 'Display' and '\*' methods)
##
IrredInfo := NewAttributeSuppCT( "IrredInfo",
    IsNearlyCharacterTable, "mutable" );
SetIrredInfo := Setter( IrredInfo );
HasIrredInfo := Tester( IrredInfo );


#############################################################################
##
#A  ClassParameters( <tbl> )
##
ClassParameters := NewAttributeSuppCT( "ClassParameters",
    IsNearlyCharacterTable );
SetClassParameters := Setter( ClassParameters );
HasClassParameters := Tester( ClassParameters );


#############################################################################
##
#A  ClassPermutation( <tbl> )
##
##  is a permutation $\pi$ of classes of <tbl>.
##  Its meaning is that class fusions into <tbl> that are stored on other
##  tables must be followed by $\pi$ in order to describe the correct
##  fusion.
##
##  This attribute is bound only if <tbl> was obtained from another table
##  by permuting the classes (commands 'CharacterTableWithSortedClasses' or
##  'SortedCharacterTable').
##  It is necessary because the original table and the sorted table have the
##  same identifier, and hence the same fusions are valid for the two tables.
##
ClassPermutation := NewAttributeSuppCT( "ClassPermutation",
    IsNearlyCharacterTable );
SetClassPermutation := Setter( ClassPermutation );
HasClassPermutation := Tester( ClassPermutation );


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
##  to the character table <tbl> shall be described.
##
##  For library tables, the identifier is equal to one of the names with
##  that the table can be fetched.
##  For tables constructed from groups, an identifier is constructed.
#T only valid for the current session!
#T if one would take the group itself as identifier,
#T one would have to compare identifiers only via 'IsIdentical',
#T and this is the wrong approach for strings!
##
Identifier := NewAttributeSuppCT( "Identifier", IsNearlyCharacterTable );
SetIdentifier := Setter( Identifier );
HasIdentifier := Tester( Identifier );


#############################################################################
##
#A  InfoText( <tbl> )
##
##  is a string with information about <tbl>.
##
InfoText := NewAttributeSuppCT( "InfoText", IsNearlyCharacterTable );
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
#A  Maxes( <tbl> )
##
##  is a list of identifiers of the tables of all maximal subgroups of <tbl>.
##  This is known usually only for library tables.
#T meaningful also for tables with group?
##
Maxes := NewAttributeSuppCT( "Maxes", IsNearlyCharacterTable );
SetMaxes := Setter( Maxes );
HasMaxes := Tester( Maxes );


#############################################################################
##
#A  NamesOfFusionSources( <tbl> )
##
##  is the list of identifiers of all those tables that are known to have
##  fusions into <tbl> stored.
##
NamesOfFusionSources := NewAttributeSuppCT( "NamesOfFusionSources",
    IsNearlyCharacterTable, "mutable" );
SetNamesOfFusionSources := Setter( NamesOfFusionSources );
HasNamesOfFusionSources := Tester( NamesOfFusionSources );


#############################################################################
##
#A  AutomorphismsOfTable( <tbl> )
##
AutomorphismsOfTable := NewAttributeSuppCT( "AutomorphismsOfTable",
    IsNearlyCharacterTable );
SetAutomorphismsOfTable := Setter( AutomorphismsOfTable );
HasAutomorphismsOfTable := Tester( AutomorphismsOfTable );
#T use 'GlobalPartitionClasses' in 'TableAutomorphisms' ?
#T AutomorphismGroup( <tbl> ) ??


#############################################################################
##
#O  Indicator( <tbl>, <n> )
#O  Indicator( <tbl>, <characters>, <n> )
#O  Indicator( <modtbl>, 2 )
##
##  If <tbl> is an ordinary character table then 'Indicator' returns the
##  list of <n>-th Frobenius-Schur indicators of <characters>
##  or 'Irr( <tbl> )'.
##
##  If <tbl> is a Brauer table in characteristic $\not= 2$, and $<n> = 2$
##  then 'Indicator' returns the second indicator.
##
Indicator := NewOperation( "Indicator",
    [ IsNearlyCharacterTable, IsInt and IsPosRat ] );


#############################################################################
##
#O  InducedCyclic( <tbl> )
#O  InducedCyclic( <tbl>, \"all\" )
#O  InducedCyclic( <tbl>, <classes> )
#O  InducedCyclic( <tbl>, <classes>, \"all\" )
##
##  'InducedCyclic' calculates characters induced up from cyclic subgroups
##  of the character table <tbl> to <tbl>.
##
##  If `"all"` is specified, all irreducible characters of those subgroups
##  are induced, otherwise only the permutation characters are calculated.
##
##  If a list <classes> is specified, only those cyclic subgroups generated
##  by these classes are considered, otherwise all classes of <tbl> are
##  considered.
##
##  'InducedCyclic' returns a set of characters.
##
InducedCyclic := NewOperation( "InducedCyclic", [ IsNearlyCharacterTable ] );


#############################################################################
##
#A  UnderlyingGroup( <ordtbl> )
##
##  Note that only the ordinary character table stores the underlying group,
##  the class functions can notify knowledge of the group via the
##  category 'IsClassFunctionWithGroup'.
##
UnderlyingGroup := NewAttributeSuppCT( "UnderlyingGroup", IsOrdinaryTable );
SetUnderlyingGroup := Setter( UnderlyingGroup );
HasUnderlyingGroup := Tester( UnderlyingGroup );


#############################################################################
##
#O  CharacterTableDirectProduct( <tbl1>, <tbl2> )
##
##  is the table of the direct product of the character tables <tbl1>
##  and <tbl2>.
##
##  We allow products of ordinary and Brauer character tables.
##
##  In general, the result will not know an underlying group,
##  so the power maps and irreducibles of <tbl1> and <tbl2> may be computed
##  in order to construct the direct product.
##
CharacterTableDirectProduct := NewOperation( "CharacterTableDirectProduct",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );


#############################################################################
##
#O  CharacterTableFactorGroup( <tbl>, <classes> )
##
##  is the table of the factor group of <tbl> by the intersection of kernels
##  of those irreducible characters of <tbl> that contain <classes> in their
##  kernel.
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
#O  CharacterTableOfNormalSubgroup( <ordtbl>, <classes> )
##
##  returns the restriction of the ordinary character table <ordtbl>
##  to the classes in the list <classes>.
##
##  In most cases, this table is only an approximation of the character table
##  of this normal subgroup, and some classes of the normal subgroup must be
##  split, see "CharTableSplitClasses".
##  The result is only a table in progress then.
##
##  If the classes in <classes> need not to be split then the result is a
##  proper character table.
##
CharacterTableOfNormalSubgroup := NewOperationArgs(
    "CharacterTableOfNormalSubgroup" );


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
##  returns the list of all possible class fusions from <subtbl> into <tbl>.
##  
##  The optional record <options> may have the following components\:
##  
##  'chars':\\
##       a list of characters of <tbl> which will be restricted to <subtbl>,
##       (see "FusionsAllowedByRestrictions");
##       the default is '<tbl>.irreducibles'
##  
##  'subchars':\\
##       a list of characters of <subtbl> which are constituents of the
##       retrictions of 'chars', the default is '<subtbl>.irreducibles'
##  
##  'fusionmap':\\
##       a (parametrized) map which is an approximation of the desired map
##  
##  'decompose':\\
##       a boolean; if 'true', the restrictions of 'chars' must have all
##       constituents in 'subchars', that will be used in the algorithm;
##       if 'subchars' is not bound and '<subtbl>.irreducibles' is complete,
##       the default value of 'decompose' is 'true', otherwise 'false'
##  
##  'permchar':\\
##       a permutaion character; only those fusions are computed which
##       afford that permutation character
##  
##  'quick':\\
##       a boolean; if 'true', the subroutines are called with the option
##       '\"quick\"'; especially, a unique map will be returned immediately
##       without checking all symmetrisations; the default value is 'false'
##  
##  'parameters':\\
##       a record with fields 'maxamb', 'minamb' and 'maxlen' which control
##       the subroutine 'FusionsAllowedByRestrictions'\:
##       It only uses characters with actual indeterminateness up to
##       'maxamb', tests decomposability only for characters with actual
##       indeterminateness at least 'minamb' and admits a branch only
##       according to a character if there is one with at most 'maxlen'
##       possible restrictions.
##
PossibleClassFusions := NewOperation( "PossibleClassFusions",
    [ IsOrdinaryTable, IsOrdinaryTable, IsRecord ] );

SubgroupFusions := PossibleClassFusions;


#############################################################################
##
#O  PossiblePowerMaps( <tbl>, <prime> )
#O  PossiblePowerMaps( <tbl>, <prime>, <options> )
##
##  is a list of possibilities for the <prime>-th power map of the
##  character table <tbl>.
##  If <tbl> is a Brauer table, the map is computed from the power map
##  of the ordinary table.
##  
##  The optional record <options> may have the following components\:
##  
##  'chars':\\
##       a list of characters which are used for the check of kernels
##       (see "ConsiderKernels"), the test of congruences (see "Congruences")
##       and the test of scalar products of symmetrisations
##       (see "PowerMapsAllowedBySymmetrisations");
##       the default is '<tbl>.irreducibles'
##  
##  'powermap':\\
##       a (parametrized) map which is an approximation of the desired map
##  
##  'decompose':\\
##       a boolean; if 'true', the symmetrisations of 'chars' must have all
##       constituents in 'chars', that will be used in the algorithm;
##       if 'chars' is not bound and 'Irr( <tbl> )' is known,
##       the default value of 'decompose' is 'true', otherwise 'false'
##  
##  'quick':\\
##       a boolean; if 'true', the subroutines are called with the option
##       '\"quick\"'; especially, a unique map will be returned immediately
##       without checking all symmetrisations; the default value is 'false'
##  
##  'parameters':\\
##       a record with fields 'maxamb', 'minamb' and 'maxlen' which control
##       the subroutine 'PowerMapsAllowedBySymmetrisations'\:
##       It only uses characters with actual indeterminateness up to
##       'maxamb', tests decomposability only for characters with actual
##       indeterminateness at least 'minamb' and admits a branch only
##       according to a character if there is one with at most 'maxlen'
##       possible minus-characters.
##
PossiblePowerMaps := NewOperation( "PossiblePowerMaps",
    [ IsCharacterTable, IsInt, IsRecord ] );

Powermap := PossiblePowerMaps;


#############################################################################
##
#F  FusionConjugacyClasses( <tbl1>, <tbl2> )
#F  FusionConjugacyClasses( <H>, <G> )
#O  FusionConjugacyClassesOp( <H>, <G> )
#A  ComputedClassFusions( <tbl> )
##
##  In the first form, 'FusionConjugacyClasses' returns the fusion of
##  conjugacy classes between the character tables <tbl1> and <tbl2>.
##  (If one of the tables is a Brauer table, it may delegate to its
##  ordinary table.)
##
##  In the second form, 'FusionConjugacyClasses' returns the fusion of
##  conjugacy classes between the group <h> and its supergroup <G>;
##  this is done by delegating to the ordinary character tables of <H> and
##  <G>.
##  (Note that we store the fusions only on character tables, that's why
##  the groups delegate to the tables; of course the method for tables
##  with group will be allowed to use the groups.)
##
##  If no class fusion exists, 'fail' is returned.
##  If the class fusion is not uniquely determined then an error is
##  signalled.
##
##  The class fusions that were computed already by 'FusionConjugacyClasses'
##  are stored as value of the attribute 'ComputedClassFusions'
##  (a list of class fusions)
#T records or fusion objects?
##
##  Methods for the computation of class fusions can be installed for
##  the operation 'FusionConjugacyClassesOp'.
##
##  (see also 'GetFusionMap', 'StoreFusion')
##
FusionConjugacyClasses := NewOperationArgs( "FusionConjugacyClasses" );

FusionConjugacyClassesOp := NewOperation( "FusionConjugacyClassesOp",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );

ComputedClassFusions := NewAttributeSuppCT( "ComputedClassFusions",
    IsNearlyCharacterTable, "mutable" );
SetComputedClassFusions := Setter( ComputedClassFusions );
HasComputedClassFusions := Tester( ComputedClassFusions );


#############################################################################
##
#F  GetFusionMap( <source>, <destination> )
#F  GetFusionMap( <source>, <destination>, <specification> )
##
##  For ordinary character tables <source> and <destination>,
##  'GetFusionMap( <source>, <destination> )' returns the 'map' component of
##  the fusion stored on the table <source> that has the 'name' component
##  <destination>,
##  and 'GetFusionMap( <source>, <destination>, <specification> )' fetches
##  that fusion that additionally has the 'specification' component
##  <specification>.
##
##  If <source> and <destination> are Brauer tables,
##  'GetFusionMap' looks whether a fusion map between the ordinary tables
##  is stored; if so then the fusion map between <source> and <destination>
##  is stored on <source>, and then returned.
##
##  If no appropriate fusion is found, 'fail' is returned.
##
##  (For the computation of class fusions, see 'FusionConjugacyClasses'.)
##
##  Note that the stored fusion map may differ from the entered map if the
##  table <destination> has a 'ClassPermutation'.
##  So one should not fetch fusion maps directly via access to
##  'ComputedFusionMaps'.
##
GetFusionMap := NewOperationArgs( "GetFusionMap" );


#############################################################################
##
#F  StoreFusion( <source>, <fusion>, <destination> )
#F  StoreFusion( <source>, <fusionmap>, <destination> )
##
##  The record <fusion> is stored on <source> if no ambiguity arises.
##  'Identifier( <source> )' is added to 'NamesFusionSource( <destination> )'.
##
##  If a list <fusionmap> is entered, the same holds for
##  '<fusion> = rec( map:= <fusionmap> )'.
##
##  Note that the stored fusion map may differ from the entered map if the
##  table <destination> has a 'ClassPermutation'.
##  So one should not fetch fusion maps directly via access to
##  'ComputedFusionMaps'.
##
StoreFusion := NewOperationArgs( "StoreFusion" );


#############################################################################
##
#F  PowerMapByComposition( <tbl>, <n> ) . .  for char. table and pos. integer
##
##  <n> must be a positive integer, and <tbl> a nearly character table.
##  If the power maps for all prime divisors of <n> are stored in
##  'ComputedPowerMaps' of <tbl> then 'PowerMapByComposition' returns the
##  <n>-th power map of <tbl>.
##  Otherwise 'fail' is returned.
##  
PowerMapByComposition := NewOperationArgs( "PowerMapByComposition" );


#############################################################################
##
#F  PowerMap( <tbl>, <n> )
#F  PowerMap( <G>, <n> )
#F  PowerMap( <tbl>, <n>, <class> )
#F  PowerMap( <G>, <n>, <class> )
#O  PowerMapOp( <tbl>, <n> )
#O  PowerMapOp( <tbl>, <n>, <class> )
#A  ComputedPowerMaps( <tbl> )
##
##  In the first form, 'PowerMap' returns the <n>-th power map of the
##  character table <tbl>.
##  In the second form, 'PowerMap' returns the <n>-th power map of the
##  group <G>; this is done by delegating to the ordinary character table
##  of <G>.
##
##  The power maps that were computed already by 'PowerMap'
##  are stored as value of the attribute 'ComputedPowerMaps'
##  (the $n$-th power map at position $n$).
##  Methods for the computation of power maps can be installed for
##  the operation 'PowerMapOp'.
##
PowerMap := NewOperationArgs( "PowerMap" );

PowerMapOp := NewOperation( "PowerMapOp",
    [ IsNearlyCharacterTable, IsInt ] );

ComputedPowerMaps := NewAttributeSuppCT( "ComputedPowerMaps",
    IsNearlyCharacterTable, "mutable" );
SetComputedPowerMaps := Setter( ComputedPowerMaps );
HasComputedPowerMaps := Tester( ComputedPowerMaps );


#############################################################################
##
#F  InverseMap( <paramap> ) . . . . . . . . . . inverse of a parametrized map
##
##  'InverseMap( <paramap> )[i]' is the unique preimage or the set of all
##  preimages of 'i' under <paramap>, if there are any;
##  otherwise it is unbound.
##
##  We have 'CompositionMaps( <paramap>, InverseMap( <paramap> ) )'
##  the identity map.
##
InverseMap := NewOperationArgs( "InverseMap" );


#############################################################################
##
#F  NrPolyhedralSubgroups( <tbl>, <c1>, <c2>, <c3>)  . # polyhedral subgroups
##
NrPolyhedralSubgroups := NewOperationArgs( "NrPolyhedralSubgroups" );


#############################################################################
##
#F  ConvertToOrdinaryTable( <record> )  . . . . create character table object
#F  ConvertToOrdinaryTableNC( <record> )  . . . create character table object
##
##  The components listed in 'SupportedOrdinaryTableInfo' are used to set
##  properties and attributes.
##  All other components will simply become components of the record object.
##  
ConvertToOrdinaryTable := NewOperationArgs( "ConvertToOrdinaryTable" );

ConvertToOrdinaryTableNC := NewOperationArgs( "ConvertToOrdinaryTableNC" );


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
#F  PrintCharacterTable( <tbl>, <varname> )
##
##  prints the supported information about the character table <tbl>,
##  as assignment to the variable with name <varname>.
##
PrintCharacterTable := NewOperationArgs( "PrintCharacterTable" );


#############################################################################
##
#F  TableAutomorphisms( <name> )
##
TableAutomorphisms := NewOperationArgs( "TableAutomorphisms" );


#############################################################################
##
#F  TransformingPermutationsCharacterTables( <name> )
##
TransformingPermutationsCharacterTables := NewOperationArgs(
    "TransformingPermutationsCharacterTables" );


#############################################################################
##
#F  ClassStructureCharTable(<tbl>,<classes>)  . gener. class mult. coefficent
##
ClassStructureCharTable := NewOperationArgs( "ClassStructureCharTable" );


#############################################################################
##
#F  MatClassMultCoeffsCharTable( <tbl>, <class> )
#F                                     . . . matrix of class mult coefficents
##
##  is a matrix <M> of structure constants where
##  '<M>[j][k] = ClassMultiplicationCoefficient( <tbl>, <class>, j, k )'
##
MatClassMultCoeffsCharTable := NewOperationArgs(
    "MatClassMultCoeffsCharTable" );


#############################################################################
##
#F  RealClassesCharTable( <tbl> ) . . . .  the real-valued classes of a table
##
##  An element $x$ is real iff it is conjugate to its inverse
##  $x^-1 = x^{o(x)-1}$.
##
RealClassesCharTable := NewOperationArgs( "RealClassesCharTable" );


#############################################################################
##
#O  CharacterTableWithSortedCharacters( <tbl> )
#O  CharacterTableWithSortedCharacters( <tbl>, <perm> )
##
##  is a character table that differs from <tbl> only by the succession of
##  its irreducible characters.
##  This affects at most the value of the attributes `Irr' and `IrredInfo',
##  namely these lists are permuted by the permutation <perm>.
##
##  If no second argument is given then a permutation is used that yields
##  irreducible characters of increasing degree for the result.
##  For the succession of characters in the result, see "SortedCharacters".
##
##  The result has all those attributes and properties of <tbl> that are
##  stored in 'SupportedOrdinaryTableInfo'.
##
##  The result will *not* be a library table, even if <tbl> is,
##  and it will *not* have an underlying group.
##
CharacterTableWithSortedCharacters := NewOperation(
    "CharacterTableWithSortedCharacters", [ IsNearlyCharacterTable ] );


#############################################################################
##
#O  SortedCharacters( <tbl>, <chars> )\\
#O  SortedCharacters( <tbl>, <chars>, \"norm\" )\\
#O  SortedCharacters( <tbl>, <chars>, \"degree\" )
##
##  is a list containing the characters <chars>, in a succession specified
##  by the other arguments.
##
##  There are three possibilities to sort characters\:\ 
##  They can be sorted according to ascending norms (parameter '\"norm\"'),
##  to ascending degree (parameter '\"degree\"'),
##  or both (no third parameter),
##  i.e., characters with same norm are sorted according to ascending degree,
##  and characters with smaller norm precede those with bigger norm.
##
##  Rational characters always will precede other ones with same norm resp.\ 
##  same degree afterwards.
##  The trivial character, if contained in <chars>, will always be sorted to
##  the first position.
##
SortedCharacters := NewOperation(
    "SortedCharacters", [ IsNearlyCharacterTable, IsHomogeneousList ] );


#############################################################################
##
#O  CharacterTableWithSortedClasses( <tbl> )
#O  CharacterTableWithSortedClasses( <tbl>, \"centralizers\" )
#O  CharacterTableWithSortedClasses( <tbl>, \"representatives\" )
#O  CharacterTableWithSortedClasses( <tbl>, <permutation> )
##
##  is a character table obtained on permutation of the classes of <tbl>.
##  If the second argument is the string `"centralizers"' then the classes
##  of the result are sorted according to descending centralizer orders.
##  If the second argument is the string `"representatives"' then the classes
##  of the result are sorted according to ascending representative orders.
##  If no second argument is given, then the classes
##  of the result are sorted according to ascending representative orders,
##  and classes with equal representative orders are sorted according to
##  descending centralizer orders.
##
##  If the second argument is a permutation then the classes of the
##  result are sorted by application of this permutation.
##
##  The result has all those attributes and properties of <tbl> that are
##  stored in 'SupportedOrdinaryTableInfo'.
##
##  The result will *not* be a library table, even if <tbl> is,
##  and it will *not* have an underlying group.
##
CharacterTableWithSortedClasses := NewOperation(
    "CharacterTableWithSortedClasses", [ IsNearlyCharacterTable ] );


#############################################################################
##
#F  SortedCharacterTable( <tbl>, <kernel> )
#F  SortedCharacterTable( <tbl>, <normalseries> )
#F  SortedCharacterTable( <tbl>, <facttbl>, <kernel> )
##
##  is a character table obtained on permutation of the classes and the
##  irreducibles characters of <tbl>.
##
##  The first form sorts the classes at positions contained in the list
##  <kernel> to the beginning, and sorts all characters in
##  'Irr( <tbl> )' such that the first characters are those that contain
##  <kernel> in their kernel.
##
##  The second form does the same successively for all kernels $k_i$ in
##  the list $'normalseries' = [ k_1, k_2, \ldots, k_n ]$ where
##  $k_i$ must be a sublist of $k_{i+1}$ for $1 \leq i \leq n-1$.
##
##  The third form computes the table <F> of the factor group of <tbl>
##  modulo the normal subgroup formed by the classes whose positions are
##  contained in the list <kernel>;
##  <F> must be permutation equivalent to the table <facttbl> (in the
##  sense of "TransformingPermutationsCharacterTables"), otherwise 'fail' is
##  returned.  The classes of <tbl> are sorted such that the preimages
##  of a class of <F> are consecutive, and that the succession of
##  preimages is that of <facttbl>.
##  'Irr( <tbl> )' is sorted as by 'SortCharTable( <tbl>, <kernel> )'.
##
##  (*Note* that the transformation is only unique up to table automorphisms
##  of <F>, and this need not be unique up to table automorphisms of <tbl>.)
##
##  All rearrangements of classes and characters are stable, i.e., the
##  relative positions of classes and characters that are not distinguished
##  by any relevant property is not changed.
##
##  The result has at most those attributes and properties of <tbl> that are
##  stored in 'SupportedOrdinaryTableInfo'.
##  If <tbl> is a library table then the components of <tbl> that are stored
##  in 'SupportedLibraryTableComponents' are components of <tbl>.
##
##  The 'ClassPermutation' value of <tbl> is changed if necessary,
##  see "Conventions for Character Tables".
##
SortedCharacterTable := NewOperationArgs( "SortedCharacterTable" );


#############################################################################
##
#F  CASString( <tbl> )
##
##  is a string that encodes the CAS library format of the character table
##  <tbl>.
##  The used line length is 'SizeScreen()[1]'.
##
CASString := NewOperationArgs( "CASString" );


#############################################################################
##
#F  IrrConlon( <G> )
##
##  compute the irreducible characters of a supersolvable group using
##  Conlon's algorithm.
##  The monomiality information (attribute 'TestMonomial') for each
##  irreducible character is known.
##
IrrConlon := NewOperationArgs( "IrrConlon" );


#############################################################################
##
#E  ctbl.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



