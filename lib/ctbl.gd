#############################################################################
##
#W  ctbl.gd                     GAP library                     Thomas Breuer
#W                                                           & Goetz Pfeiffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the definition of categories of character table like
##  objects, and their properties, attributes, operations, and functions.
##
##  1. Some Remarks about Character Theory in GAP
##  2. Character Table Categories
##  3. The Interface between Character Tables and Groups
##  4. Operators for Character Tables
##  5. Attributes and Properties for Groups as well as for Character Tables
##  6. Attributes and Properties only for Character Tables
##  x. Operations Concerning Blocks
##  7. Other Operations for Character Tables
##  8. Creating Character Tables
##  9. Printing Character Tables
##  10. Constructing Character Tables from Others
##  11. Sorted Character Tables
##  12. Storing Normal Subgroup Information
##  13. Auxiliary Stuff
##
Revision.ctbl_gd :=
    "@(#)$Id$";


#T when are two character tables equal? -> same identifier & same permutation?)


#############################################################################
##
#T  TODO:
##
#T  (about incomplete tables!)
#T
#T  For character tables that do *not* store an underlying group,
#T  there is no notion of generation, contrary to all {\GAP} domains.
#T  Consequently, the correctness or even the consistency of such a character
#T  table is hard to decide.
#T  Nevertheless, one may want to work with incomplete character tables or
#T  hypothetical tables which are, strictly speaking, not character tables
#T  but shall be handled like character tables.
#T  In such cases, one often has to set attribute values by hand;
#T  no need to say that one must be very careful then.
##
#T  introduce fusion objects?
##
#T  improve `CompatibleConjugacyClasses',
#T  unify it with `TransformingPermutationsCharacterTables'!
##


#############################################################################
##
##  1. Some Remarks about Character Theory in GAP
#1
##  It seems to be necessary to state some basic facts --and maybe warnings--
##  at the beginning of the character theory package.
##  This holds for people who are familiar with character theory because
##  there is no global reference on computational character theory,
##  although there are many papers on this topic,
##  such as~\cite{NPP84} or~\cite{LP91}.
##  It holds, however, also for people who are familiar with {\GAP} because
##  the general concept of domains (see Chapter~"Domains") plays no important
##  role here --we  will justify this later in this section.
##
##  Intuitively, *characters* (or more generally, *class functions*) of a
##  finite group $G$ can be thought of as certain mappings defined on $G$,
##  with values in the complex number field;
##  the set of all characters of $G$ forms a semiring, with both addition
##  and multiplication defined pointwise, which is naturally embedded into
##  the ring of *generalized* (or *virtual*) *characters* in the natural way.
##  A ${\Z}$--basis of this ring, and also a vector space basis of the
##  complex vector space of class functions of $G$,
##  is given by the irreducible characters of $G$.
##
##  At this stage one could ask where there is a problem, since all these
##  algebraic structures are supported by {\GAP}.
##  But in practice, these structures are of minor importance,
##  compared to individual characters and the *character tables* themselves
##  (which are not domains in the sense of {\GAP}).
##
##  For computations with characters of a finite group $G$ with $n$ conjugacy
##  classes, say, we fix an ordering of the classes, and then identify each
##  class with its position according to this ordering.
##  Each character of $G$ can be represented by a list of length $n$ in which
##  the character value for elements of the $i$--th class is stored at
##  the $i$--th position.
##  Note that we need not know the conjugacy classes of $G$ physically,
##  even our knowledge of $G$ may be implicit in the sense that, e.g.,
##  we know how many classes of involutions $G$ has, and which length these
##  classes have, but we never have seen an element of $G$, or a presentation
##  or representation of $G$.
##  This allows us to work with the character tables of very large groups,
##  e.g., of the so--called monster, where {\GAP} has (currently) no chance
##  to deal with the group.
##
##  As a consequence, also other information involving characters is given
##  implicitly.  For example, we can talk about the kernel of a character not
##  as a group but as a list of classes (more exactly: a list of their
##  positions according to the chosen ordering of classes) forming this
##  kernel; we can deduce the group order, the contained cyclic subgroups
##  and so on, but we do not get the group itself.
##
##  So typical calculations with characters involve loops over lists of
##  character values.
##  For  example, the scalar product of two characters $\chi$, $\psi$ of $G$
##  given by
##  $$
##  [\chi,\psi] = \frac{1}{|G|} \sum_{g\in G} \chi(g) \psi(g^{-1})
##  $$
##  can be written as
##  \begintt
##  Sum( [ 1 .. n ], i -> SizesConjugacyClasses( t )[i] * chi[i]
##                            * ComplexConjugate( psi[i] ) );
##  \endtt
##  where `t' is the character table of $G$, and `chi', `psi' are the lists
##  of values of $\chi$, $\psi$, respectively.
##
##  It is one of the advantages of character theory that after one has
##  translated a problem concerning groups into a problem concerning
##  only characters, the necessary calculations are mostly simple.
##  For example, one can often prove that a group is a Galois group over the
##  rationals using calculations with structure constants that can be
##  computed from the character table,
##  and information about (the character tables of) maximal subgroups.
##  When one deals with such questions,
##  the translation back to groups is just an interpretation by the user,
##  it does not take place in {\GAP}.
##
##  {\GAP} uses character *tables* to store information such as class
##  lengths, element orders, the irreducible characters of $G$ etc.~in a
##  consistent way;
##  in the example above, we have seen that `SizesConjugacyClasses( t )' is
##  the list of class lengths of the character table `t'.
##  Note that the values of these attributes rely on the chosen ordering
##  of conjugacy classes,
##  a character table is not determined by something similar to generators
##  of groups or rings in {\GAP} where knowledge could in principle be
##  recovered from the generators but is stored mainly for the sake of
##  efficiency.
##
##  Note that the character table of a group $G$ in {\GAP} must *not* be
##  mixed up with the list of complex irreducible characters of $G$.
##  The irreducible characters are stored in a character table via the
##  attribute `Irr' (see~"Irr").
##
##  Two further important instances of information that depends on the
##  ordering of conjugacy classes are *power maps* and *fusion maps*.
##  Both are represented as lists of integers in {\GAP}.
##  The $k$--th power map maps each class to the class of $k$--th powers
##  of its elements, the corresponding list contains at each position the
##  position of the image.
##  A class fusion map between the classes of a subgroup $H$ of $G$ and
##  the classes of $G$ maps each class $c$ of $H$ to that class of $G$ that
##  contains $c$, the corresponding list contains again the positions of
##  image classes;
##  if we know only the character tables of $H$ and $G$ but not the groups
##  themselves,
##  this means with respect to a fixed embedding of $H$ into $G$.
##  More about power maps and fusion maps can be found in
##  Chapter~"Maps Concerning Character Tables".
##
##  So class functions, power maps, and fusion maps are represented by lists
##  in {\GAP}.
##  If they are plain lists then they are regarded as class functions etc.~of
##  an appropriate character table when they are passed to {\GAP} functions
##  that expect class functions etc.
##  For example, a list with all entries equal to 1 is regarded as the
##  trivial character if it is passed to a function that expects a character.
##  Note that this approach requires the character table as an argument for
##  such a function.
##
##  One can construct class function objects that store their underlying
##  character table and other attribute values
##  (see Chapter~"Class Functions").
##  This allows one to omit the character table argument in many functions,
##  and it allows one to use infix operations for tensoring or inducing
##  class functions.
##


#############################################################################
##
##  2. Character Table Categories
##


#############################################################################
##
#V  InfoCharacterTable
##
##  is the info class (see~"Info Functions") for computations with
##  character tables.
##
DeclareInfoClass( "InfoCharacterTable" );


#############################################################################
##
#C  IsNearlyCharacterTable( <obj> )
#C  IsCharacterTable( <obj> )
#C  IsOrdinaryTable( <obj> )
#C  IsBrauerTable( <obj> )
#C  IsCharacterTableInProgress( <obj> )
##
##  Every ``character table like object'' in {\GAP} lies in the category
##  `IsNearlyCharacterTable'.
##  There are four important subcategories,
##  namely the *ordinary* tables in `IsOrdinaryTable',
##  the *Brauer* tables in `IsBrauerTable',
##  the union of these two in `IsCharacterTable',
##  and the *incomplete ordinary* tables in `IsCharacterTableInProgress'.
##
##  We want to distinguish ordinary and Brauer tables because a Brauer table
##  may delegate tasks to the ordinary table of the same group,
##  for example the computation of power maps.
##  A Brauer table is constructed from an ordinary table and stores this
##  table upon construction (see~"OrdinaryCharacterTable").
##
##  Furthermore,  `IsOrdinaryTable'  and  `IsBrauerTable'  denote   character
##  tables that provide enough information to  compute  all  power  maps  and
##  irreducible characters (and in the case  of  Brauer  tables  to  get  the
##  ordinary   table),   for   example   because   the    underlying    group
##  (see~"UnderlyingGroup!for character tables")  is  known  or  because  the
##  table is a library table
##  (see the manual of the {\GAP} Character Table Library).
##  We want to distinguish these tables from partially known ordinary tables
##  that cannot be asked for all power maps or all irreducible characters.
##
##  The character table objects in `IsCharacterTable' are always immutable
##  (see~"Mutability and Copyability").
##  This means mainly that the ordering of conjugacy classes used for the
##  various attributes of the character table cannot be changed;
##  see~"Sorted Character Tables" for how to compute a character table with a
##  different ordering of classes.
##
##  The {\GAP} objects in `IsCharacterTableInProgress' represent incomplete
##  ordinary character tables.
##  This means that not all irreducible characters, not all power maps are
##  known, and perhaps even the number of classes and the centralizer orders
##  are known.
##  Such tables occur when the character table of a group $G$ is constructed
##  using character tables of related groups and information about $G$ but
##  for example without explicitly computing the conjugacy classes of $G$.
##  An object in `IsCharacterTableInProgress' is first of all *mutable*,
##  so *nothing is stored automatically* on such a table,
##  since otherwise one has no control of side-effects when
##  a hypothesis is changed.
##  Operations for such tables may return more general values than for
##  other tables, for example class functions may contain unknowns
##  (see Chapter~"Unknowns") or lists of possible values in certain
##  positions,
##  the same may happen also for power maps and class fusions
##  (see~"Parametrized Maps").
##  *@Incomplete tables in this sense are currently not supported and will be
##  described in a chapter of their own when they become available.@*
##  Note that the term ``incomplete table'' shall express that {\GAP} cannot
##  compute certain values such as irreducible characters or power maps.
##  A table with access to its group is therefore always complete,
##  also if its irreducible characters are not yet stored.
##
DeclareCategory( "IsNearlyCharacterTable", IsObject );
DeclareCategory( "IsCharacterTable", IsNearlyCharacterTable );
DeclareCategory( "IsOrdinaryTable", IsCharacterTable );
DeclareCategory( "IsBrauerTable", IsCharacterTable );
DeclareCategory( "IsCharacterTableInProgress", IsNearlyCharacterTable );


#############################################################################
##
#V  NearlyCharacterTablesFamily
##
##  Every character table like object lies in this family (see~"Families").
##
DeclareGlobalVariable( "NearlyCharacterTablesFamily" );


#############################################################################
##
#V  SupportedCharacterTableInfo
##
##  `SupportedCharacterTableInfo' is a list that contains at position $3i-2$
##  an attribute getter function, at position $3i-1$ the name of this
##  attribute, and at position $3i$ a list containing one or two of the
##  strings `\"class\"', `\"character\"',
##  depending on whether the attribute value relies on the ordering of
##  classes or characters.
##  This allows one to set exactly the components with these names in the
##  record that is later converted to the new table,
##  in order to use the values as attribute values.
##  So the record components that shall *not* be regarded as attribute values
##  can be ignored.
##  Also other attributes of the old table are ignored.
##
##  `SupportedCharacterTableInfo' is used when (ordinary or Brauer) character
##  table objects are created from records, using `ConvertToCharacterTable'
##  (see~"ConvertToCharacterTable").
##
##  New attributes and properties can be notified to
##  `SupportedCharacterTableInfo' by creating them with
##  `DeclareAttributeSuppCT' and `DeclarePropertySuppCT' instead of
##  `DeclareAttribute' and `DeclareProperty'.
##
BindGlobal( "SupportedCharacterTableInfo", [] );


#############################################################################
##
#F  DeclareAttributeSuppCT( <name>, <filter>[, "mutable"], <depend> )
#F  DeclarePropertySuppCT( <name>, <filter>[, "mutable"] )
##
##  do the same as `DeclareAttribute' and `DeclareProperty',
##  except that the list `SupportedOrdinaryTableInfo' is extended
##  by an entry corresponding to the attribute.
##
BindGlobal( "DeclareAttributeSuppCT", function( arg )
    local attr;

    # Check the arguments.
    if not ( Length( arg ) in [ 3, 4 ] and IsString( arg[1] ) and
             IsFilter( arg[2] ) and ( IsHomogeneousList( arg[3] ) or
             ( arg[3] = "mutable" and IsHomogeneousList( arg[4] ) ) ) ) then
      Error( "usage: DeclareAttributeSuppCT( <name>,\n",
             " <filter>[, \"mutable\"], <depend> )" );
    elif not ForAll( arg[ Length( arg ) ],
                     str -> str in [ "class", "character" ] ) then
      Error( "<depend> must contain only \"class\", \"character\"" );
    fi;

    # Create/change the attribute as `DeclareAttribute' does.
    CallFuncList( DeclareAttribute, arg{ [ 1 .. Length( arg )-1 ] } );

    # Do the additional magic.
    attr:= ValueGlobal( arg[1] );
    Append( SupportedCharacterTableInfo,
            [ attr, arg[1], arg[ Length( arg ) ] ] );
end );

BindGlobal( "DeclarePropertySuppCT", function( arg )
    local prop;

    # Check the arguments.
    if not ( Length( arg ) in [ 2, 3 ] and IsString( arg[1] ) and
             IsFilter( arg[2] ) and ( Length( arg ) = 2 or
             arg[3] = "mutable" ) ) then
      Error( "usage: DeclarePropertySuppCT( <name>,\n",
             " <filter>[, \"mutable\"] )" );
    fi;

    # Create/change the property as `DeclareProperty' does.
    CallFuncList( DeclareProperty, arg );

    # Do the additional magic.
    prop:= ValueGlobal( arg[1] );
    Append( SupportedCharacterTableInfo, [ prop, arg[1], [] ] );
end );


#############################################################################
##
##  3. The Interface between Character Tables and Groups
#2
##  For a character table  with  underlying  group  (see~"UnderlyingGroup!for
##  character tables"), the interface between table  and  group  consists  of
##  three attribute values,  namely  the  *group*,  the  *conjugacy  classes*
##  stored  in   the   table   (see   `ConjugacyClasses'   below)   and   the
##  *identification*  of  the  conjugacy   classes   of   table   and   group
##  (see~`IdentificationOfConjugacyClasses' below).
##
##  Character tables constructed from groups know these values upon
##  construction,
##  and for character tables constructed without groups, these values are
##  usually not known and cannot be computed from the table.
##
##  However, given a group $G$ and a character table of a group isomorphic to
##  $G$ (for example a character table from the {\GAP} table library),
##  one can tell {\GAP} to use the given table as the character table of $G$
##  (see~"ConnectGroupAndCharacterTable").
##
##  Tasks may be delegated from a group to its character table or vice versa
##  only if these three attribute values are stored in the character table.
##


#############################################################################
##
#A  UnderlyingGroup( <ordtbl> )
##
##  For an ordinary character table <ordtbl> of a finite group,
##  the group can be stored as value of `UnderlyingGroup'.
##
##  Brauer tables do not store the underlying group,
##  they access it via the ordinary table (see~"OrdinaryCharacterTable").
##
DeclareAttributeSuppCT( "UnderlyingGroup", IsOrdinaryTable, [] );


#############################################################################
##
#A  ConjugacyClasses( <tbl> )
##
##  For a character table <tbl> with known underlying group $G$,
##  the `ConjugacyClasses' value of <tbl> is a list of conjugacy classes of
##  $G$.
##  All those lists stored in the table that are related to the orderering
##  of conjugacy classes (such as sizes of centralizers and conjugacy
##  classes, orders of representatives, power maps, and all class functions)
##  refer to the ordering of this list.
##
##  This ordering need *not* coincide with the ordering of conjugacy classes
##  as stored in the underlying group of the table
##  (see~"Sorted Character Tables").
##  One reason for this is that otherwise we would not be allowed to
##  use a library table as the character table of a group for which the
##  conjugacy classes are stored already.
##  (Another, less important reason is that we can use the same group as
##  underlying group of character tables that differ only w.r.t.~the ordering
##  of classes.)
##
##  The class of the identity element must be the first class
##  (see~"Conventions for Character Tables").
##
##  If <tbl> was constructed from $G$ then the conjugacy classes have been
##  stored at the same time when $G$ was stored.
##  If $G$ and <tbl> were connected later than in the construction of <tbl>,
##  the recommended way to do this is via `ConnectGroupAndCharacterTable'
##  (see~"ConnectGroupAndCharacterTable").
##  So there is no method for `ConjugacyClasses' that computes the value for
##  <tbl> if it is not yet stored.
##
##  Brauer tables do not store the ($p$-regular) conjugacy classes,
##  they access them via the ordinary table (see~"OrdinaryCharacterTable")
##  if necessary.
##
DeclareAttributeSuppCT( "ConjugacyClasses", IsOrdinaryTable, [ "class" ] );


#############################################################################
##
#A  IdentificationOfConjugacyClasses( <tbl> )
##
##  For an ordinary character table <tbl> with known underlying group $G$,
##  `IdentificationOfConjugacyClasses' returns a list of positive integers
##  that contains at position $i$ the position of the $i$-th conjugacy class
##  of <tbl> in the list $`ConjugacyClasses'( G )$.
##
DeclareAttributeSuppCT( "IdentificationOfConjugacyClasses", IsOrdinaryTable,
    [ "class" ] );


#############################################################################
##
#F  ConnectGroupAndCharacterTable( <G>, <tbl>[, <arec>] )
#F  ConnectGroupAndCharacterTable( <G>, <tbl>, <bijection> )
##
##  Let <G> be a group and <tbl> a character table of (a group isomorphic to)
##  <G>, such that <G> does not store its `OrdinaryCharacterTable' value
##  and <tbl> does not store its `UnderlyingGroup' value.
##  `ConnectGroupAndCharacterTable' calls `CompatibleConjugacyClasses',
##  trying to identify the classes of <G> with the columns of <tbl>.
##
##  If this identification is unique up to automorphisms of <tbl>
##  (see~"AutomorphismsOfTable") then <tbl> is stored as `CharacterTable'
##  value of <G>,
##  in <tbl> the values of `UnderlyingGroup', `ConjugacyClasses', and
##  `IdentificationOfConjugacyClasses' are set,
##  and `true' is returned.
##
##  Otherwise, i.e., if {\GAP} cannot identify the classes of <G> up to
##  automorphisms of <G>, `false' is returned.
##
##  If a record <arec> is present as third argument, its meaning is the
##  same as for `CompatibleConjugacyClasses'
##  (see~"CompatibleConjugacyClasses").
##
##  If a list <bijection> is entered as third argument,
##  it is used as value of `IdentificationOfConjugacyClasses',
##  relative to `ConjugacyClasses( <G> )',
##  without further checking, and `true' is returned.
##
DeclareGlobalFunction( "ConnectGroupAndCharacterTable" );


#############################################################################
##
#O  CompatibleConjugacyClasses( <G>, <ccl>, <tbl>[, <arec>] )
#O  CompatibleConjugacyClasses( <tbl>[, <arec>] )
##
##  In the first form, <ccl> must be a list of the conjugacy classes of the
##  group <G>, and <tbl> the ordinary character table of <G>.
##  Then `CompatibleConjugacyClasses' returns a list $l$ of positive integers
##  that describes an identification of the columns of <tbl> with the
##  conjugacy classes <ccl> in the sense that $l[i]$ is the position in <ccl>
##  of the class corresponding to the $i$-th column of <tbl>,
##  if this identification is unique up to automorphisms of <tbl>
##  (see~"AutomorphismsOfTable");
##  if {\GAP} cannot identify the classes, `fail' is returned.
##
##  In the second form, <tbl> must be an ordinary character table, and
##  `CompatibleConjugacyClasses' checks whether the columns of <tbl> can be
##  identified with the conjugacy classes of a group isomorphic to that for
##  which <tbl> is the character table;
##  the return value is a list of all those sets of class positions for which
##  the columns of <tbl> cannot be distinguished with the invariants used,
##  up to automorphisms of <tbl>.
##  So the identification is unique if and only if the returned list is
##  empty.
##
##  The usual approach is that one first calls `CompatibleConjugacyClasses'
##  in the second form for checking quickly whether the first form will be
##  successful, and only if this is the case the more time consuming
##  calculations with both group and character table are done.
##
##  The following invariants are used.
##  \beginlist
##  \item{1.} element orders (see~"OrdersClassRepresentatives"),
##  \item{2.} class lengths (see~"SizesConjugacyClasses"),
##  \item{3.} power maps (see~"PowerMap", "ComputedPowerMaps"),
##  \item{4.} symmetries of the table (see~"AutomorphismsOfTable").
##  \endlist
##
##  If the optional argument <arec> is present then it must be a record
##  whose components describe additional information for the class
##  identification.
##  The following components are supported.
##  \beginitems
##  `natchar' &
##      if $G$ is a permutation group or matrix group then the value of this
##      component is regarded as the list of values of the natural character
##      (see~"NaturalCharacter") of <G>,
##      w.r.t.~the ordering of classes in <tbl>,
##
##  `bijection' &
##      a list describing a partial bijection; the $i$-th entry, if bound,
##      is the position of the $i$-th conjugacy class of <tbl> in the list
##      <ccl>.
##  \enditems
##
DeclareOperation( "CompatibleConjugacyClasses",
    [ IsGroup, IsList, IsOrdinaryTable ] );
DeclareOperation( "CompatibleConjugacyClasses",
    [ IsGroup, IsList, IsOrdinaryTable, IsRecord ] );
DeclareOperation( "CompatibleConjugacyClasses", [ IsOrdinaryTable ] );
DeclareOperation( "CompatibleConjugacyClasses",
    [ IsOrdinaryTable, IsRecord ] );


#############################################################################
##
#F  CompatibleConjugacyClassesDefault( <G>, <ccl>, <tbl>, <arec> )
#F  CompatibleConjugacyClassesDefault( false, false, <tbl>, <arec> )
##
##  This is installed as a method for `CompatibleConjugacyClasses'.
##  It uses the following invariants.
##  Element orders, class lengths, cosets of the derived subgroup,
##  power maps of prime divisors of the group order, automorphisms of <tbl>.
##
DeclareGlobalFunction( "CompatibleConjugacyClassesDefault" );


#############################################################################
##
##  4. Operators for Character Tables
#3
##  \indextt{\*!for character tables}
##  \indextt{/!for character tables}
##  \indextt{mod!for character tables}
##  \index{character tables!infix operators}
##
##  The following infix operators are defined for character tables.
##  \beginitems
##  `<tbl1> \* <tbl2>' &
##      the direct product of two character tables
##      (see~"CharacterTableDirectProduct"),
##
##  `<tbl> / <list>' &
##      the table of the factor group modulo the normal subgroup spanned by
##      the classes in the list <list> (see~"CharacterTableFactorGroup"),
##
##  `<tbl> mod <p>' &
##      the <p>-modular Brauer character table corresponding to the ordinary
##      character table <tbl> (see~"CharacterTable"),
##
##  `<tbl>.<name>' &
##      the position of the class with name <name> in <tbl>
##      (see~"ClassNames").
##  \enditems
##


#############################################################################
##
##  5. Attributes and Properties for Groups as well as for Character Tables
#4
##  Several *attributes for groups* are valid also for character tables.
##  These are on one hand those that have the same meaning for both group and
##  character table, and whose values can be read off or computed,
##  respectively, from the character table,
##  such as `Size', `IsAbelian', or `IsSolvable'.
##  On the other hand, there are attributes whose meaning for character
##  tables is different from the meaning for groups, such as
##  `ConjugacyClasses'.
##


#############################################################################
##
#A  CharacterDegrees( <G> )
#O  CharacterDegrees( <G>, <p> )
#A  CharacterDegrees( <tbl> )
##
##  In the first two forms, `CharacterDegrees' returns a collected list of
##  the degrees of the absolutely irreducible characters of the group <G>;
##  the optional second argument <p> must be either zero or a prime integer
##  denoting the characteristic, the default value is zero.
##  In the third form, <tbl> must be an (ordinary or Brauer) character
##  table, and `CharacterDegrees' returns a collected list of the degrees of
##  the absolutely irreducible characters of <tbl>.
##
##  (The default method for the call with only argument a group is to call
##  the operation with second argument `0'.)
##
##  For solvable groups, the default method is based on~\cite{Con90b}.
##
DeclareAttribute( "CharacterDegrees", IsGroup );
DeclareOperation( "CharacterDegrees", [ IsGroup, IsInt ] );
DeclareAttributeSuppCT( "CharacterDegrees", IsNearlyCharacterTable, [] );

InstallIsomorphismMaintenance( CharacterDegrees,
    IsGroup and HasCharacterDegrees, IsGroup );


#############################################################################
##
#A  Irr( <G> )
#O  Irr( <G>, <p> )
#A  Irr( <tbl> )
##
##  Called with a group <G>, `Irr' returns the irreducible characters of the
##  ordinary character table of <G>.
##  Called with a group <G> and a prime integer <p>, `Irr' returns the
##  irreducible characters of the <p>-modular Brauer table of <G>.
##  Called with an (ordinary or Brauer) character table <tbl>,
##  `Irr' returns the list of all complex absolutely irreducible characters
##  of <tbl>.
##
##  For a character table <tbl> with underlying group,
##  `Irr' may delegate to the group.
##  For a group <G>, `Irr' may delegate to its character table only if the
##  irreducibles are already stored there.
##
##  (If <G> is <p>-solvable (see~"IsPSolvable") then the <p>-modular
##  irreducible characters can be computed by the Fong-Swan Theorem;
##  in all other cases, there may be no method.)
##
##  Note that the ordering of columns in the `Irr' matrix of the group <G>
##  refers to the ordering of conjugacy classes in `CharacterTable( <G> )',
##  which may differ from the ordering of conjugacy classes in <G>
##  (see~"The Interface between Character Tables and Groups").
##  As an extreme example, for a character table obtained from sorting the
##  classes of `CharacterTable( <G> )',
##  the ordering of columns in the `Irr' matrix respects the sorting of
##  classes (see~"Sorted Character Tables"),
##  so the irreducibles of such a table will in general not coincide with
##  the irreducibles stored as `Irr( <G> )' although also the sorted table
##  stores the group <G>.
##
DeclareAttribute( "Irr", IsGroup );
DeclareOperation( "Irr", [ IsGroup, IsInt ] );
DeclareAttributeSuppCT( "Irr", IsNearlyCharacterTable,
    [ "class", "character" ] );


#############################################################################
##
#A  LinearCharacters( <G> )
#O  LinearCharacters( <G>, <p> )
#A  LinearCharacters( <tbl> )
##
##  `LinearCharacters' returns the linear (i.e., degree $1$) characters in
##  the `Irr' (see~"Irr") list of the group <G> or the character table <tbl>,
##  respectively.
##  In the second form, `LinearCharacters' returns the <p>-modular linear
##  characters of the group <G>.
##
##  For a character table <tbl> with underlying group,
##  `LinearCharacters' may delegate to the group.
##  For a group <G>, `LinearCharacters' may delegate to its character table
##  only if the irreducibles are already stored there.
##
##  The ordering of linear characters in <tbl> need not coincide with the
##  ordering of linear characters in the irreducibles of <tbl> (see~"Irr").
##
DeclareAttribute( "LinearCharacters", IsGroup );
DeclareOperation( "LinearCharacters", [ IsGroup, IsInt ] );
DeclareAttributeSuppCT( "LinearCharacters", IsNearlyCharacterTable,
    [ "class" ] );


#############################################################################
##
#A  IBr( <modtbl> )
#O  IBr( <G>, <p> )
##
##  For a Brauer table <modtbl> or a group <G> and a prime integer <p>,
##  `IBr' delegates to `Irr'.
#T This may become interesting as soon as blocks are GAP objects of their own,
#T and one can ask for the ordinary and modular irreducibles in a block.
##
DeclareAttribute( "IBr", IsBrauerTable );
DeclareOperation( "IBr", [ IsGroup, IsPosInt ] );


#############################################################################
##
#A  OrdinaryCharacterTable( <G> ) . . . . . . . . . . . . . . . . for a group
#A  OrdinaryCharacterTable( <modtbl> )  . . . .  for a Brauer character table
##
##  `OrdinaryCharacterTable' returns the ordinary character table of the
##  group <G> or the Brauer character table <modtbl>, respectively.
##
##  Since Brauer character tables are constructed from ordinary tables,
##  the attribute value for <modtbl> is already stored
##  (cf.~"Character Table Categories").
##
DeclareAttributeSuppCT( "OrdinaryCharacterTable", IsGroup, [] );


#############################################################################
##
#5
##  The following operations for groups are applicable to character tables
##  and mean the same for a character table as for the group;
##  see the chapter about groups for the definition.
##  \beginlist
##  \indextt{AbelianInvariants!for character tables}
##  \item{}
##      `AbelianInvariants'
##  \indextt{CommutatorLength!for character tables}
##  \item{}
##      `CommutatorLength'
##  \indextt{Exponent!for character tables}
##  \item{}
##      `Exponent'
##  \indextt{IsAbelian!for character tables}
##  \item{}
##      `IsAbelian'
##  \indextt{IsCyclic!for character tables}
##  \item{}
##      `IsCyclic'
##  \indextt{IsFinite!for character tables}
##  \item{}
##      `IsFinite'
##  \indextt{IsMonomial!for character tables}
##  \item{}
##      `IsMonomial'
##  \indextt{IsNilpotent!for character tables}
##  \item{}
##      `IsNilpotent'
##  \indextt{IsPerfect!for character tables}
##  \item{}
##      `IsPerfect'
##  \indextt{IsSimple!for character tables}
##  \item{}
##      `IsSimple'
##  \indextt{IsSolvable!for character tables}
##  \item{}
##      `IsSolvable'
##  \indextt{IsSupersolvable!for character tables}
##  \item{}
##      `IsSupersolvable'
##  \indextt{NrConjugacyClasses!for character tables}
##  \item{}
##      `NrConjugacyClasses'
##  \indextt{Size!for character tables}
##  \item{}
##      `Size'
##  \endlist
##  These operations are mainly useful for selecting character tables with
##  certain properties, also for character tables without access to a group.
##


#############################################################################
##
#A  AbelianInvariants( <tbl> )
#A  CommutatorLength( <tbl> )
#A  Exponent( <tbl> )
#P  IsAbelian( <tbl> )
#P  IsCyclic( <tbl> )
#P  IsFinite( <tbl> )
#A  NrConjugacyClasses( <tbl> )
#A  Size( <tbl> )
##
DeclareAttributeSuppCT( "AbelianInvariants", IsNearlyCharacterTable, [] );
DeclareAttributeSuppCT( "CommutatorLength", IsNearlyCharacterTable, [] );
DeclareAttributeSuppCT( "Exponent", IsNearlyCharacterTable, [] );
DeclarePropertySuppCT( "IsAbelian", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsCyclic", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsFinite", IsNearlyCharacterTable );
DeclareAttributeSuppCT( "NrConjugacyClasses", IsNearlyCharacterTable, [] );
DeclareAttributeSuppCT( "Size", IsNearlyCharacterTable, [] );


#############################################################################
##
#P  IsMonomialCharacterTable( <tbl> )
#P  IsNilpotentCharacterTable( <tbl> )
#P  IsPerfectCharacterTable( <tbl> )
#P  IsSimpleCharacterTable( <tbl> )
#P  IsSolvableCharacterTable( <tbl> )
#P  IsSupersolvableCharacterTable( <tbl> )
##
##  These six properties belong to the ``overloaded'' operations,
##  methods for the unqualified properties with argument an ordinary
##  character table are installed in `overload.g'.
##
DeclarePropertySuppCT( "IsMonomialCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsNilpotentCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsPerfectCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsSimpleCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsSolvableCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsSupersolvableCharacterTable",
    IsNearlyCharacterTable );


InstallTrueMethod( IsAbelian, IsOrdinaryTable and IsCyclic );
InstallTrueMethod( IsMonomialCharacterTable,
    IsOrdinaryTable and IsSupersolvableCharacterTable and IsFinite );
InstallTrueMethod( IsNilpotentCharacterTable,
    IsOrdinaryTable and IsAbelian );
InstallTrueMethod( IsPerfectCharacterTable,
    IsOrdinaryTable and IsSimpleCharacterTable );
InstallTrueMethod( IsSolvableCharacterTable,
    IsOrdinaryTable and IsSupersolvableCharacterTable );
InstallTrueMethod( IsSolvableCharacterTable,
    IsOrdinaryTable and IsMonomialCharacterTable );
InstallTrueMethod( IsSupersolvableCharacterTable,
    IsOrdinaryTable and IsNilpotentCharacterTable );


#############################################################################
##
#F  CharacterTable_IsNilpotentFactor( <tbl>, <N> )
##
##  returns whether the factor group by the normal subgroup described by the
##  classes at positions in the list <N> is nilpotent.
##
DeclareGlobalFunction( "CharacterTable_IsNilpotentFactor" );


#############################################################################
##
#F  CharacterTable_IsNilpotentNormalSubgroup( <tbl>, <N> )
##
##  returns whether the normal subgroup described by the classes at positions
##  in the list <N> is nilpotent.
##
DeclareGlobalFunction( "CharacterTable_IsNilpotentNormalSubgroup" );


#############################################################################
##
##  6. Attributes and Properties only for Character Tables
#6
##  The following three *attributes for character tables* would make sense
##  also for groups but are in fact *not* used for groups.
##  This is because the values depend on the ordering of conjugacy classes
##  stored as value of `ConjugacyClasses', and this value may differ for a
##  group and its character table
##  (see~"The Interface between Character Tables and Groups").
##  Note that for character tables, the consistency of attribute values must
##  be guaranteed,
##  whereas for groups, there is no need to impose such a consistency rule.
##


#############################################################################
##
#A  OrdersClassRepresentatives( <tbl> )
##
##  is a list of orders of representatives of conjugacy classes of the
##  character table <tbl>,
##  in the same ordering as the conjugacy classes of <tbl>.
##
DeclareAttributeSuppCT( "OrdersClassRepresentatives",
    IsNearlyCharacterTable, [ "class" ] );


#############################################################################
##
#A  SizesCentralizers( <tbl> )
##
##  is a list that stores at position $i$ the size of the centralizer of any
##  element in the $i$-th conjugacy class of the character table <tbl>.
##
DeclareAttributeSuppCT( "SizesCentralizers", IsNearlyCharacterTable,
    [ "class" ] );


#############################################################################
##
#A  SizesConjugacyClasses( <tbl> )
##
##  is a list that stores at position $i$ the size of the $i$-th conjugacy
##  class of the character table <tbl>.
##
DeclareAttributeSuppCT( "SizesConjugacyClasses", IsNearlyCharacterTable,
    [ "class" ] );


#############################################################################
##
#7
##  The following attributes apply only to character tables, not to groups.
##

#############################################################################
##
#A  AutomorphismsOfTable( <tbl> )
##
##  is the permutation group of all column permutations of the character
##  table <tbl> that leave the set of irreducibles and each power map of
##  <tbl> invariant (see also~"TableAutomorphisms").
##
DeclareAttributeSuppCT( "AutomorphismsOfTable", IsNearlyCharacterTable,
    [ "class" ] );
#T AutomorphismGroup( <tbl> ) ??


#############################################################################
##
#A  UnderlyingCharacteristic( <tbl> )
#A  UnderlyingCharacteristic( <psi> )
##
##  For an ordinary character table <tbl>, the result is `0',
##  for a $p$-modular Brauer table <tbl>, it is $p$.
##  The underlying characteristic of a class function <psi> is equal to
##  that of its underlying character table.
##
##  The underlying characteristic must be stored when the table is
##  constructed, there is no method to compute it.
##
##  We cannot use the attribute `Characteristic' (see~"Characteristic")
##  to denote this, since of course each Brauer character is an element
##  of characteristic zero in the sense of {\GAP}
##  (see Chapter~"Class Functions").
##
DeclareAttributeSuppCT( "UnderlyingCharacteristic",
    IsNearlyCharacterTable, [] );


#############################################################################
##
#A  ClassNames( <tbl> )
#O  ClassNames( <tbl>, \"ATLAS\" )
#A  CharacterNames( <tbl> )
##
##  `ClassNames' and `CharacterNames' return lists of strings,
##  one for each conjugacy class or irreducible character, respectively,
##  of the character table <tbl>.
##  These names are used when <tbl> is displayed.
##
##  The default method for `ClassNames' computes class names consisting of
##  the order of an element in the class and at least one distinguishing
##  letter.
##  The default method for `CharacterNames' returns the list
##  $[ `\"X.1\"', `\"X.2\"', \ldots ]$, whose length is the number of
##  irreducible characters of <tbl>.
##
##  The position of the class with name <name> in <tbl> can be accessed as
##  `<tbl>.<name>'.
##
##  When `ClassNames' is called with two arguments, the second being the
##  string `\"ATLAS\"', the class names returned obey the convention used in
##  Chapter~7, Section~5 of the {\ATLAS} of Finite Groups~\cite{CCN85}.
##
DeclareAttributeSuppCT( "ClassNames", IsNearlyCharacterTable,
    [ "class" ] );

DeclareOperation( "ClassNames", [ IsNearlyCharacterTable, IsString ] );

DeclareAttributeSuppCT( "CharacterNames", IsNearlyCharacterTable,
    [ "character" ] );


#############################################################################
##
##  The following declaration is made here because several library functions
##  have to be aware of the attribute values when constructing new tables,
##  for example `CharacterTableDirectProduct'.
##  The documentation, however, is referenced from the {\GAP} Character Table
##  Library, hence the explicit reference in the text.
##


#############################################################################
##
#A  ClassParameters( <tbl> )
#A  CharacterParameters( <tbl> )
##
##  are lists containing a parameter for each conjugacy class or irreducible
##  character, respectively, of the character table <tbl>.
##
##  It depends on <tbl> what these parameters are,
##  so there is no default to compute class and character parameters.
##
##  For example, the classes of symmetric groups can be parametrized by
##  partitions, corresponding to the cycle structures of permutations.
##  Character tables constructed from generic character tables
##  (see~"Generic Character Tables") usually have class and character
##  parameters stored.
##
##  If <tbl> is a $p$-modular Brauer table such that class parameters are
##  stored in the underlying ordinary table
##  (see~"ref:OrdinaryCharacterTable" in the {\GAP} Reference Manual)
##  of <tbl> then `ClassParameters' returns the sublist of class parameters
##  of the ordinary table, for $p$-regular classes.
##
DeclareAttributeSuppCT( "ClassParameters", IsNearlyCharacterTable,
    [ "class" ] );

DeclareAttributeSuppCT( "CharacterParameters", IsNearlyCharacterTable,
    [ "character" ] );


#############################################################################
##
#A  Identifier( <tbl> )
##
##  is a string that identifies the character table <tbl> in the current
##  {\GAP} session.
##  It is used mainly for class fusions into <tbl> that are stored on other
##  character tables.
##  For character tables without group,
##  the identifier is also used to print the table;
##  this is the case for library tables,
##  but also for tables that are constructed as direct products, factors
##  etc.~involving tables that may or may not store their groups.
##
##  The default method for ordinary tables constructs strings of the form
##  `\"CT<n>\"', where <n> is a positive integer.
##  `LARGEST_IDENTIFIER_NUMBER' is a list containing the largest integer <n>
##  used in the current {\GAP} session.
##
##  The default method for Brauer tables returns the concatenation of the
##  identifier of the ordinary table, the string `\"mod\"',
##  and the (string of the) underlying characteristic.
##
DeclareAttributeSuppCT( "Identifier", IsNearlyCharacterTable, [] );


#############################################################################
##
#V  LARGEST_IDENTIFIER_NUMBER
##
#T  We have to use a list in order to admit `DeclareGlobalVariable' and
#T  `InstallFlushableValue' ...
##
#T  Note that one must be very careful when reading
#T  character tables from files!!
#T  (signal warnings then?)
##
DeclareGlobalVariable( "LARGEST_IDENTIFIER_NUMBER",
    "list containing the largest identifier of an ordinary character table\
 in the current session" );
InstallFlushableValue( LARGEST_IDENTIFIER_NUMBER, [ 0 ] );


#############################################################################
##
#A  InfoText( <tbl> )
##
##  is a mutable string with information about the character table <tbl>.
##  There is no default method to create an info text.
##
##  This attribute is used mainly for library tables (see the manual of the
##  {\GAP} Character Table Library).
##  Usual parts of the information are the origin of the table,
##  tests it has passed (`1.o.r.' for the test of orthogonality,
##  `pow[<p>]' for the construction of the <p>-th power map,
##  `DEC' for the decomposition of ordinary into Brauer characters,
##  `TENS' for the decomposition of tensor products of irreducibles),
##  and choices made without loss of generality.
##
DeclareAttributeSuppCT( "InfoText", IsNearlyCharacterTable, "mutable", [] );


#############################################################################
##
#A  InverseClasses( <tbl> )
##
##  For a character table <tbl>, `InverseClasses' returns the list mapping
##  each conjugacy class to its inverse class.
##  This list can be regarded as $(-1)$-st power map of <tbl>
##  (see~"PowerMap").
##
DeclareAttribute( "InverseClasses", IsNearlyCharacterTable );


#############################################################################
##
#A  RealClasses( <tbl> ) . . . . . . real-valued classes of a character table
##
##  \index{classes!real}
##
##  For a character table <tbl>, `RealClasses' returns the strictly sorted
##  list of positions of classes in <tbl> that consist of real elements.
##
##  An element $x$ is *real* iff it is conjugate to its inverse
##  $x^{-1} = x^{o(x)-1}$.
##
DeclareAttributeSuppCT( "RealClasses", IsNearlyCharacterTable, [ "class" ] );


#############################################################################
##
#O  ClassOrbit( <tbl>, <cc> ) . . . . . . . . .  classes of a cyclic subgroup
##
##  is the list of positions of those conjugacy classes
##  of the character table <tbl> that are Galois conjugate to the <cc>-th
##  class.
##  That is, exactly the classes at positions given by the list returned by
##  `ClassOrbit' contain generators of the cyclic group generated
##  by an element in the <cc>-th class.
##
##  This information is computed from the power maps of <tbl>.
##
DeclareOperation( "ClassOrbit", [ IsNearlyCharacterTable, IsPosInt ] );


#############################################################################
##
#A  ClassRoots( <tbl> ) . . . . . . . . . . . .  nontrivial roots of elements
##
##  For a character table <tbl>, `ClassRoots' returns a list
##  containing at position $i$ the list of positions of the classes
##  of all nontrivial $p$-th roots, where $p$ runs over the prime divisors
##  of `Size( <tbl> )'.
##
##  This information is computed from the power maps of <tbl>.
##
DeclareAttribute( "ClassRoots", IsCharacterTable );


#############################################################################
##
#8
##  The following attributes for a character table <tbl> correspond to
##  attributes for the group $G$ of <tbl>.
##  But instead of a normal subgroup (or a list of normal subgroups) of $G$,
##  they return a strictly sorted list of positive integers (or a list of
##  such lists) which are the positions
##  --relative to `ConjugacyClasses( <tbl> )'--
##  of those classes forming the normal subgroup in question.
##


#############################################################################
##
#A  ClassPositionsOfNormalSubgroups( <ordtbl> )
#A  ClassPositionsOfMaximalNormalSubgroups( <ordtbl> )
##
##  correspond to `NormalSubgroups' and `MaximalNormalSubgroups'
##  for the group of the ordinary character table <ordtbl>
##  (see~"NormalSubgroups", "MaximalNormalSubgroups").
##
##  The entries of the result lists are sorted according to increasing
##  length.
##  (So this total order respects the partial order of normal subgroups
##  given by inclusion.)
##
DeclareAttribute( "ClassPositionsOfNormalSubgroups", IsOrdinaryTable );

DeclareAttribute( "ClassPositionsOfMaximalNormalSubgroups",
    IsOrdinaryTable );


#############################################################################
##
#O  ClassPositionsOfAgemo( <ordtbl>, <p> )
##
##  corresponds to `Agemo' (see~"Agemo")
##  for the group of the ordinary character table <ordtbl>.
##
DeclareOperation( "ClassPositionsOfAgemo", [ IsOrdinaryTable, IsPosInt ] );


#############################################################################
##
#A  ClassPositionsOfCentre( <ordtbl> )
##
##  corresponds to `Centre' (see~"Centre")
##  for the group of the ordinary character table <ordtbl>.
##
DeclareAttribute( "ClassPositionsOfCentre", IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfDirectProductDecompositions( <tbl> )
#O  ClassPositionsOfDirectProductDecompositions( <tbl>, <nclasses> )
##
##  Let <tbl> be the ordinary character table of the group $G$, say.
##  Called with the only argument <tbl>,
##  `ClassPositionsOfDirectProductDecompositions' returns the list of all
##  those pairs $[ l_1, l_2 ]$ where $l_1$ and $l_2$ are lists of
##  class positions of normal subgroups $N_1$, $N_2$ of $G$
##  such that $G$ is their direct product and $|N_1| \leq |N_2|$ holds.
##  Called with second argument a list <nclasses> of class positions of a
##  normal subgroup $N$ of $G$,
##  `ClassPositionsOfDirectProductDecompositions' returns the list of pairs
##  describing the decomposition of $N$ as a direct product of two
##  normal subgroups of $G$.
##
DeclareAttributeSuppCT( "ClassPositionsOfDirectProductDecompositions",
    IsOrdinaryTable, [ "class" ] );

DeclareOperation( "ClassPositionsOfDirectProductDecompositions",
    [ IsOrdinaryTable, IsList ] );


#############################################################################
##
#A  ClassPositionsOfDerivedSubgroup( <ordtbl> )
##
##  corresponds to `DerivedSubgroup' (see~"DerivedSubgroup")
##  for the group of the ordinary character table <ordtbl>.
##
DeclareAttribute( "ClassPositionsOfDerivedSubgroup", IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfElementaryAbelianSeries( <ordtbl> )
##
##  corresponds to `ElementaryAbelianSeries' (see~"ElementaryAbelianSeries")
##  for the group of the ordinary character table <ordtbl>.
##
DeclareAttribute( "ClassPositionsOfElementaryAbelianSeries",
    IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfFittingSubgroup( <ordtbl> )
##
##  corresponds to `FittingSubgroup' (see~"FittingSubgroup")
##  for the group of the ordinary character table <ordtbl>.
##
DeclareAttribute( "ClassPositionsOfFittingSubgroup", IsOrdinaryTable );


#############################################################################
##
#F  CharacterTable_UpperCentralSeriesFactor( <tbl>, <N> )
##
##  Let <tbl> the character table of the group $G$, and <N> the list of
##  classes contained in the normal subgroup $N$ of $G$.
##  The upper central series $[ Z_1, Z_2, \ldots, Z_n ]$ of $G/N$ is defined
##  by $Z_1 = Z(G/N)$, and $Z_{i+1} / Z_i = Z( G / Z_i )$.
##  'UpperCentralSeriesFactor( <tbl>, <N> )' is a list
##  $[ C_1, C_2, \ldots, C_n ]$ where $C_i$ is the set of positions of
##  $G$-conjugacy classes contained in $Z_i$.
##
##  A simpleminded version of the algorithm can be stated as follows.
##
##  $M_0:= Irr(G);$
##  $Z_1:= Z(G);$
##  $i:= 0;$
##  repeat
##    $i:= i+1;$
##    $M_i:= \{ \chi\in M_{i-1} ; Z_i \leq \ker(\chi) \};$
##    $Z_{i+1}:= \bigcap_{\chi\in M_i}} Z(\chi);$
##  until $Z_i = Z_{i+1};$
##
DeclareGlobalFunction( "CharacterTable_UpperCentralSeriesFactor" );


#############################################################################
##
#A  ClassPositionsOfLowerCentralSeries( <tbl> )
##
##  corresponds to `LowerCentralSeries' (see~"LowerCentralSeriesOfGroup")
##  for the group of the ordinary character table <ordtbl>.
##
DeclareAttribute( "ClassPositionsOfLowerCentralSeries", IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfUpperCentralSeries( <ordtbl> )
##
##  corresponds to `UpperCentralSeries' (see~"UpperCentralSeriesOfGroup")
##  for the group of the ordinary character table <ordtbl>.
##
DeclareAttribute( "ClassPositionsOfUpperCentralSeries", IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfSolvableResiduum( <ordtbl> )
##
##  corresponds to `SolvableResiduum' (see~"SolvableResiduum")
##  for the group of the ordinary character table <ordtbl>.
##
DeclareAttribute( "ClassPositionsOfSolvableResiduum", IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfSupersolvableResiduum( <ordtbl> )
##
##  corresponds to `SupersolvableResiduum' (see~"SupersolvableResiduum")
##  for the group of the ordinary character table <ordtbl>.
##
DeclareAttribute( "ClassPositionsOfSupersolvableResiduum", IsOrdinaryTable );


#############################################################################
##
#O  ClassPositionsOfNormalClosure( <ordtbl>, <classes> )
##
##  is the sorted list of the positions of all conjugacy classes of the
##  ordinary character table <ordtbl> that form the normal closure
##  (see~"NormalClosure") of the conjugacy classes at positions in the
##  list <classes>.
##
DeclareOperation( "ClassPositionsOfNormalClosure",
    [ IsOrdinaryTable, IsHomogeneousList and IsCyclotomicCollection ] );


#############################################################################
##
##  x. Operations Concerning Blocks
##


#############################################################################
##
#O  PrimeBlocks( <ordtbl>, <p> )
#O  PrimeBlocksOp( <ordtbl>, <p> )
#A  ComputedPrimeBlockss( <tbl> )
##
##  For an ordinary character table <ordtbl> and a prime integer <p>,
##  `PrimeBlocks' returns a record with the following components.
##  \beginitems
##  `block' &
##      a list, the value $j$ at position $i$ means that the $i$--th
##      irreducible character of <ordtbl> lies in the $j$--th <p>-block
##      of <ordtbl>,
##
##  `defect' &
##      a list containing at position $i$ the defect of the $i$-th block,
##
##  `height' &
##      a list containing at position $i$ the height of the $i$-th
##      irreducible character of <ordtbl> in its block,
##
##  `relevant' &
##      a list of class positions such that only the restriction to these
##      classes need be checked for deciding whether two characters lie
##      in the same block,
##
##  `exponents' &
##      a list containing at the positions in the component `relevant'
##      an integer $n$ such that the $n$-th power of a difference of
##      characters is divisible by <p> if the two characters lie in the same
##      block, and
##
##  `centralcharacter' &
##      a list containing at position $i$ a list whose values at the
##      positions stored in the component `relevant' are the values of
##      a central character in the $i$-th block.
##  \enditems
##
##  The components `relevant', `exponents', and `centralcharacters' are
##  used by `SameBlock' (see~"SameBlock").
##
##  If `InfoCharacterTable' has level at least 2,
##  the defects of the blocks and the heights of the characters are printed.
##
##  The default method uses the attribute
##  `ComputedPrimeBlockss' for storing the computed value at
##  position <p>, and calls the operation `PrimeBlocksOp' for
##  computing values that are not yet known.
##
##  Two ordinary irreducible characters $\chi, \psi$ of a group $G$ are said
##  to lie in the same $p$-*block* if the images of their central characters
##  $\omega_{\chi}, \omega_{\psi}$ (see~"CentralCharacter") under the
##  ring homomorphism $\ast \colon R \rightarrow R / M$ are equal,
##  where $R$ denotes the ring of algebraic integers in the complex number
##  field, and $M$ is a maximal ideal in $R$ with $pR \subseteq M$.
##  (The distribution to $p$-blocks is in fact independent of the choice of
##  $M$, see~\cite{Isa76}.)
##
##  For $|G| = p^a m$ where $p$ does not divide $m$, the *defect* of a block
##  is the integer $d$ such that $p^{a-d}$ is the largest power of $p$ that
##  divides the degrees of all characters in the block.
##
##  The *height* of a character $\chi$ in the block is defined as the largest
##  exponent $h$ for which $p^h$ divides $\chi(1) / p^{a-d}$.
##
DeclareOperation( "PrimeBlocks", [ IsOrdinaryTable, IsPosInt ] );

DeclareOperation( "PrimeBlocksOp", [ IsOrdinaryTable, IsPosInt ] );

DeclareAttributeSuppCT( "ComputedPrimeBlockss", IsOrdinaryTable, "mutable",
    [ "character" ] );

#T Admit a list of characters as optional argument,
#T and compute the distribution into blocks.
#T The question is how to determine the defects of the blocks;
#T this should be possible if defect classes can be computed without
#T problems (cf. Isaacs, Thm. 15.31).


#############################################################################
##
#F  SameBlock( <tbl>, <p>, <omega1>, <omega2>, <relevant>, <exponents> )
##
##  Let <tbl> be an ordinary character table, <p> a prime integer,
##  <omega1> and <omega2> two central characters (or their values lists)
##  of <tbl>.
##  The remaining arguments <relevant> and <exponents> are lists as stored
##  in the components `relevantclasses' and `exponents' of a record
##  returned by `PrimeBlocks' (see~"PrimeBlocks").
##
##  `SameBlock' returns `true' if <omega1> and <omega2> are equal modulo any
##  maximal ideal in the ring of complex algebraic integers containing the
##  ideal spanned by <p>, and `false' otherwise.
##
DeclareGlobalFunction( "SameBlock" );


#############################################################################
##
#A  BlocksInfo( <modtbl> )
##
##  For a Brauer character table <modtbl>, the value of `BlocksInfo'
##  is a list of (mutable) records, the $i$-th entry containing information
##  about the $i$-th block.
##  Each record has the following components.
##  \beginitems
##  `defect' &
##       the defect of the block,
##
##  `ordchars' &
##       the list of positions of the ordinary characters that belong to the
##       block, relative to `Irr( OrdinaryCharacterTable( <modtbl> ) )',
##
##  `modchars' &
##       the list of positions of the Brauer characters that belong to the
##       block, relative to `IBr( <modtbl> )'.
##  \enditems
##  Optional components are
##  \beginitems
##  `basicset' &
##       a list of positions of ordinary characters in the block whose
##       restriction to <modtbl> is maximally linearly independent,
##       relative to `Irr( OrdinaryCharacterTable( <modtbl> ) )',
##
##  `decmat' &
##       the decomposition matrix of the block,
##       it is stored automatically when `DecompositionMatrix' is called for
##       the block (see~"DecompositionMatrix"),
##
##  `decinv' &
##       inverse of the decomposition matrix of the block, restricted to the
##       ordinary characters described by `basicset',
##
##  `brauertree' &
##       a list that describes the Brauer tree of the block,
##       in the case that the block is of defect $1$.
##  \enditems
##
DeclareAttributeSuppCT( "BlocksInfo", IsNearlyCharacterTable, "mutable",
    [ "character" ] );


#############################################################################
##
#A  DecompositionMatrix( <modtbl> )
#O  DecompositionMatrix( <modtbl>, <blocknr> )
##
##  Let <modtbl> be a Brauer character table.
##
##  In the first version `DecompositionMatrix' returns the decomposition
##  matrix of <modtbl>, where the rows and columns are indexed by the
##  irreducible characters of the ordinary character table of <modtbl>
##  and the irreducible characters of <modtbl>, respectively,
##
##  In the second version `DecompositionMatrix' returns the decomposition
##  matrix of the block of <modtbl> with number <blocknr>;
##  the matrix is stored as value of the `decmat' component of the
##  <blocknr>-th entry of the `BlocksInfo' list (see~"BlocksInfo") of
##  <modtbl>.
##
##  An ordinary irreducible character is in block $i$ if and only if all
##  characters before the first character of the same block lie in $i-1$
##  different blocks.
##  An irreducible Brauer character is in block $i$ if it has nonzero scalar
##  product with an ordinary irreducible character in block $i$.
##
##  `DecompositionMatrix' is based on the more general function
##  `Decomposition' (see~"Decomposition").
##
DeclareAttribute( "DecompositionMatrix", IsBrauerTable );
DeclareOperation( "DecompositionMatrix", [ IsBrauerTable, IsPosInt ] );


#############################################################################
##
#F  LaTeXStringDecompositionMatrix( <modtbl>[, <blocknr>][, <options>] )
##
##  is a string that contains La{\TeX} code to print a decomposition matrix
##  (see~"DecompositionMatrix") nicely.
##
##  The optional argument <options>, if present, must be a record with
##  components
##  `phi', `chi' (strings used in each label for columns and rows),
##  `collabels', `rowlabels' (subscripts for the labels).
##  The defaults for `phi' and `chi' are `\"{\\tt Y}\"' and `\"{\\tt X}\"',
##  the defaults for `collabels' and `rowlabels' are the lists of positions
##  of the Brauer characters and ordinary characters in the respective lists
##  of irreducibles in the character tables.
##
##  The optional components `nrows' and `ncols' denote the maximal number of
##  rows and columns per array;
##  if they are present then each portion of `nrows' rows and `ncols' columns
##  forms an array of its own which is enclosed in `\\[', `\\]'.
##
##  If the component `decmat' is bound in <options> then it must be the
##  decomposition matrix in question, in this case the matrix is not computed
##  from the information in <modtbl>.
##
##  For those character tables from the {\GAP} table library that belong to
##  the {\ATLAS} of Finite Groups~\cite{CCN85},
##  `AtlasLabelsOfIrreducibles' constructs character labels that are
##  compatible with those used in the {\ATLAS}
##  (see~"ctbllib:ATLAS Tables" and ~"ctbllib:AtlasLabelsOfIrreducibles"
##  in the manual of the {\GAP} Character Table Library).
##
DeclareGlobalFunction( "LaTeXStringDecompositionMatrix" );


#############################################################################
##
##  7. Other Operations for Character Tables
#9
##  In the following, we list operations for character tables that are not
##  attributes.
##
##  \>IsInternallyConsistent( <tbl> )!{for character tables} O
##
##  For an *ordinary* character table <tbl>, `IsInternallyConsistent'
##  checks the consistency of the following attribute values (if stored).
##  \beginlist
##  \item{-}
##      `Size', `SizesCentralizers', and `SizesConjugacyClasses'.
##  \item{-}
##      `SizesCentralizers' and `OrdersClassRepresentatives'.
##  \item{-}
##      `ComputedPowerMaps' and `OrdersClassRepresentatives'.
##  \item{-}
##      `SizesCentralizers' and `Irr'.
##  \item{-}
##      `Irr' (first orthogonality relation).
##  \endlist
##
##  For a *Brauer* table <tbl>, `IsInternallyConsistent'
##  checks the consistency of the following attribute values (if stored).
##  \beginlist
##  \item{-}
##      `Size', `SizesCentralizers', and `SizesConjugacyClasses'.
##  \item{-}
##      `SizesCentralizers' and `OrdersClassRepresentatives'.
##  \item{-}
##      `ComputedPowerMaps' and `OrdersClassRepresentatives'.
##  \item{-}
##      `Irr' (closure under complex conjugation and Frobenius map).
##  \endlist
##
##  If no inconsistency occurs, `true' is returned,
##  otherwise each inconsistency is printed to the screen if the level of
##  `InfoWarning' is at least $1$ (see~"Info Functions"),
##  and `false' is returned at the end.
##


#############################################################################
##
#O  IsPSolvableCharacterTable( <tbl>, <p> )
#O  IsPSolvableCharacterTableOp( <tbl>, <p> )
#A  ComputedIsPSolvableCharacterTables( <tbl> )
##
##  `IsPSolvableCharacterTable' for the ordinary character table <tbl>
##  corresponds to `IsPSolvable' for the group of <tbl> (see~"IsPSolvable").
##  <p> must be either a prime integer or `0'.
##
##  The default method uses the attribute
##  `ComputedIsPSolvableCharacterTables' for storing the computed value at
##  position <p>, and calls the operation `IsPSolvableCharacterTableOp' for
##  computing values that are not yet known.
##
DeclareOperation( "IsPSolvableCharacterTable", [ IsOrdinaryTable, IsInt ] );
DeclareOperation( "IsPSolvableCharacterTableOp",
    [ IsOrdinaryTable, IsInt ] );
DeclareAttributeSuppCT( "ComputedIsPSolvableCharacterTables",
    IsOrdinaryTable, "mutable", [] );


#############################################################################
##
#F  IsClassFusionOfNormalSubgroup( <subtbl>, <fus>, <tbl> )
##
##  For two ordinary character tables <tbl> and <subtbl> of a group $G$ and
##  its subgroup $U$, say,
##  and a list <fus> of positive integers that describes the class fusion of
##  $U$ into $G$,
##  `IsClassFusionOfNormalSubgroup' returns `true'
##  if $U$ is a normal subgroup of $G$, and `false' otherwise.
##
DeclareGlobalFunction( "IsClassFusionOfNormalSubgroup" );


#############################################################################
##
#O  Indicator( <tbl>, <n> )
#O  Indicator( <tbl>[, <characters>], <n> )
#O  Indicator( <modtbl>, 2 )
#O  IndicatorOp( <tbl>, <characters>, <n> )
#A  ComputedIndicators( <tbl> )
##
##  If <tbl> is an ordinary character table then `Indicator' returns the
##  list of <n>-th Frobenius-Schur indicators of the characters in the list
##  <characters>; the default of <characters> is `Irr( <tbl> )'.
##
##  The $n$-th Frobenius-Schur indicator $\nu_n(\chi)$ of an ordinary
##  character $\chi$ of the group $G$ is given by
##  $\nu_n(\chi) = \frac{1}{|G|} \sum_{g \in G} \chi(g^n)$.
##
##  If <tbl> is a Brauer table in characteristic $\not= 2$ and $<n> = 2$
##  then `Indicator' returns the second indicator.
##
##  The default method uses the attribute
##  `ComputedIndicators' for storing the computed value at
##  position <n>, and calls the operation `IndicatorOp' for
##  computing values that are not yet known.
##
DeclareOperation( "Indicator", [ IsNearlyCharacterTable, IsPosInt ] );
DeclareOperation( "Indicator",
    [ IsNearlyCharacterTable, IsList, IsPosInt ] );

DeclareOperation( "IndicatorOp",
    [ IsNearlyCharacterTable, IsList, IsPosInt ] );

DeclareAttributeSuppCT( "ComputedIndicators", IsCharacterTable, "mutable",
    [ "character" ] );


#############################################################################
##
#F  NrPolyhedralSubgroups( <tbl>, <c1>, <c2>, <c3>)  . # polyhedral subgroups
##
##  \index{subgroups!polyhedral}
##
##  returns the number and isomorphism type of polyhedral subgroups of the
##  group with ordinary character table <tbl> which are generated by an
##  element $g$ of class <c1> and an element $h$ of class <c2> with the
##  property that the product $gh$ lies in class <c3>.
##
##  According to p.~233 in~\cite{NPP84}, the number of polyhedral subgroups
##  of isomorphism type $V_4$, $D_{2n}$, $A_4$, $S_4$, and $A_5$
##  can be derived from the class multiplication coefficient
##  (see~"ClassMultiplicationCoefficient!for character tables")
##  and the number of Galois
##  conjugates of a class (see~"ClassOrbit").
##
##  The classes <c1>, <c2> and <c3> in the parameter list must be ordered
##  according to the order of the elements in these classes.
#
DeclareGlobalFunction( "NrPolyhedralSubgroups" );


#############################################################################
##
#O  ClassMultiplicationCoefficient( <tbl>, <i>, <j>, <k> )
##
##  \index{class multiplication coefficient}
##  \index{structure constant}
##
##  returns the class multiplication coefficient of the classes <i>, <j>,
##  and <k> of the group $G$ with ordinary character table <tbl>.
##
##  The class multiplication coefficient $c_{i,j,k}$ of the classes <i>,
##  <j>, <k> equals the number of pairs $(x,y)$ of elements $x, y \in G$
##  such that $x$ lies in class <i>, $y$ lies in class <j>,
##  and their product $xy$ is a fixed element of class <k>.
##
##  In the center of the group algebra of $G$, these numbers are found as
##  coefficients of the decomposition of the product of two class sums $K_i$
##  and $K_j$ into class sums,
##  $$
##  K_i K_j = \sum_k c_{ijk} K_k\.
##  $$
##  Given the character table of a finite group $G$,
##  whose classes  are $C_1, \dots, C_r$ with representatives $g_i \in C_i$,
##  the class multiplication coefficient $c_{ijk}$ can be computed
##  by the following formula.
##  $$
##  c_{ijk} = \frac{\|C_i\|\|C_j\|}{\|G\|}
##            \sum_{\chi \in Irr(G)}
##            \frac{\chi(g_i) \chi(g_j) \overline{\chi(g_k)}}{\chi(1)}\.
##  $$
##  On the other hand the knowledge of the class multiplication coefficients
##  admits the computation of the irreducible characters of $G$.
##  (see~"IrrDixonSchneider").
##
DeclareOperation( "ClassMultiplicationCoefficient",
    [ IsOrdinaryTable, IsPosInt, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  MatClassMultCoeffsCharTable( <tbl>, <i> )
##
##  \index{structure constant}
##  \index{class multiplication coefficient}
##
##  For an ordinary character table <tbl> and a class position <i>,
##  `MatClassMultCoeffsCharTable' returns the matrix
##  $[ a_{ijk} ]_{j,k}$ of structure constants
##  (see~"ClassMultiplicationCoefficient!for character tables").
##
DeclareGlobalFunction( "MatClassMultCoeffsCharTable" );


#############################################################################
##
#F  ClassStructureCharTable( <tbl>, <classes> ) . . gener. class mult. coeff.
##
##  \index{class multiplication coefficient}
##  \index{structure constant}
##
##  returns the so-called class structure of the classes in the list
##  <classes>, for the character table <tbl> of the group $G$.
##  The length of <classes> must be at least 2.
##
##  Let $C = (C_1, C_2, \dots, C_n)$ denote the $n$--tuple of conjugacy
##  classes of $G$ that are indexed by <classes>.
##  The class structure $n(C)$ equals
##  the number of $n$--tuples $(g_1, g_2, \ldots, g_n)$ of elements
##  $g_i\in C_i$ with $g_1 g_2 \cdots g_n = 1$.
##  Note the difference to the definition of the class multiplication
##  coefficients in `ClassMultiplicationCoefficient'
##  (see~"ClassMultiplicationCoefficient!for character tables").
##
##  $n(C_1, C_2, \ldots, C_n)$ is computed using the formula
##  $$
##  n(C_1, C_2, \ldots, C_n) 
##         = \frac{\|C_1\|\|C_2\|\cdots\|C_n\|}{\|G\|}
##           \sum_{\chi \in Irr(G)}
##           \frac{\chi(g_1)\chi(g_2)\cdots\chi(g_n)}{\chi(1)^{n-2}}.
##  $$
##
DeclareGlobalFunction( "ClassStructureCharTable" );


#############################################################################
##
##  8. Creating Character Tables
#10
##  There are in general five different ways to get a character table in
##  {\GAP}.
##  You can
##  \beginlist
##  \item{1.}
##      compute the table from a group,
##  \item{2.}
##      read a file that contains the table data,
##  \item{3.}
##      construct the table using generic formulae,
##  \item{4.}
##      derive it from known character tables, or
##  \item{5.}
##      combine partial information about conjugacy classes, power maps
##      of the group in question, and about (character tables of) some
##      subgroups and supergroups.
##  \endlist
##
##  In 1., the computation of the irreducible characters is the hardest part;
##  the different algorithms available for this are described
##  in~"Computing the Irreducible Characters of a Group".
##  Possibility 2.~is used for the character tables in the {\GAP} Character 
##  Table Library, see the manual of this library.
##  Generic character tables --as addressed by 3.-- are described
##  in~"ctbllib:Generic Character Tables" in the manual of the {\GAP}
##  Character Table Library.
##  Several occurrencies of 4.~are described
##  in~"Constructing Character Tables from Others".
##  The last of the above possibilities
##  *@is currently not supported and will be described in a chapter of its
##  own when it becomes available@*.
##
##  The operation `CharacterTable' (see~"CharacterTable") can be used for the
##  cases 1.--3.
##


#############################################################################
##
#O  CharacterTable( <G> ) . . . . . . . . . . ordinary char. table of a group
#O  CharacterTable( <G>, <p> )  . . . . . characteristic <p> table of a group
#O  CharacterTable( <ordtbl>, <p> )
#O  CharacterTable( <name>[, <param>] ) . . . . library table with given name
##
##  Called with a group <G>, `CharacterTable' calls the attribute
##  `OrdinaryCharacterTable' (see~"OrdinaryCharacterTable").
##  Called with first argument a group <G> or an ordinary character table
##  <ordtbl>, and second argument a prime <p>, `CharacterTable' calls
##  the operation `BrauerTable' (see~"BrauerTable").
##  Called with a string <name> and perhaps optional parameters <param>,
##  `CharacterTable' delegates to `CharacterTableFromLibrary', which
##  tries to access the {\GAP} Character Table Library (see the manual of
##  this library for an overview of admissible strings <name>).
##
##  Probably the most interesting information about the character table is
##  its list of irreducibles, which can be accessed as the value of the
##  attribute `Irr' (see~"Irr").
##  If the argument of `CharacterTable' is a string <name> then the
##  irreducibles are just read from the library file,
##  therefore the returned table stores them already.
##  However, if `CharacterTable' is called with a group <G> or with an
##  ordinary character table <ordtbl>, the irreducible characters are *not*
##  computed by `CharacterTable'.
##  They are only computed when the `Irr' value is accessed for the first
##  time, for example when `Display' is called for the table
##  (see~"Printing Character Tables").
##  This means for example that `CharacterTable' returns its result very
##  quickly, and the first call of `Display' for this table may take some
##  time because the irreducible characters must be computed at that time
##  before they can be displayed together with other information stored on
##  the character table.
##  The value of the filter `HasIrr' indicates whether the irreducible
##  characters have been computed already.
##
##  The reason why `CharacterTable' does not compute the irreducible
##  characters is that there are situations where one only needs the
##  ``table head'', that is, the information about class lengths, power maps
##  etc., but not the irreducibles.
##  For example, if one wants to inspect permutation characters of a group
##  then all one has to do is to induce the trivial characters of subgroups
##  one is interested in; for that, only class lengths and the class fusion
##  are needed.
##  Or if one wants to compute the Molien series (see~"MolienSeries") for a
##  given complex matrix group, the irreducible characters of this group are
##  in general of no interest.
##
##  For details about different algorithms to compute the irreducible
##  characters, see~"Computing the Irreducible Characters of a Group".
##
##  If the group <G> is given as an argument, `CharacterTable' accesses the
##  conjugacy classes of <G> and therefore causes that these classes are
##  computed if they were not yet stored
##  (see~"The Interface between Character Tables and Groups").
##
DeclareOperation( "CharacterTable", [ IsGroup ] );
DeclareOperation( "CharacterTable", [ IsGroup, IsInt ] );
DeclareOperation( "CharacterTable", [ IsOrdinaryTable, IsInt ] );
DeclareOperation( "CharacterTable", [ IsString ] );


#############################################################################
##
#O  BrauerTable( <ordtbl>, <p> )
#O  BrauerTable( <G>, <p> )
#O  BrauerTableOp( <ordtbl>, <p> )
#A  ComputedBrauerTables( <ordtbl> )  . . . . . . . . . . known Brauer tables
##
##  Called with an ordinary character table <ordtbl> or a group <G>,
##  `BrauerTable' returns its <p>-modular character table
##  if {\GAP} can compute this table, and `fail' otherwise.
##  The <p>-modular table can be computed for <p>-solvable groups
##  (using the Fong-Swan Theorem) and in the case that <ordtbl> is a table
##  from the {\GAP} character table library for which also the <p>-modular
##  table is contained in the table library.
##
##  The default method for a group and a prime delegates to `BrauerTable' for
##  the ordinary character table of this group.
##  The default method for <ordtbl> uses the attribute
##  `ComputedBrauerTables' for storing the computed Brauer table
##  at position <p>, and calls the operation `BrauerTableOp' for
##  computing values that are not yet known.
##
##  So if one wants to install a new method for computing Brauer tables
##  then it is sufficient to install it for `BrauerTableOp'.
##
##  The `\\mod' operator for a character table and a prime
##  (see~"Operators for Character Tables") delegates to
##  `BrauerTable'.
##
DeclareOperation( "BrauerTable", [ IsOrdinaryTable, IsPosInt ] );
DeclareOperation( "BrauerTable", [ IsGroup, IsPosInt ] );

DeclareOperation( "BrauerTableOp", [ IsOrdinaryTable, IsPosInt ] );

DeclareAttribute( "ComputedBrauerTables", IsOrdinaryTable, "mutable" );


#############################################################################
##
#F  CharacterTableRegular( <tbl>, <p> ) .  table consist. of <p>-reg. classes
##
##  preconstructor for the <p>-modular Brauer table of the ordinary character
##  table <tbl>,
##  used by the operation `BrauerTableOp' that should be called by
##  the user.
##
DeclareGlobalFunction( "CharacterTableRegular" );


#############################################################################
##
#F  ConvertToCharacterTable( <record> ) . . . . create character table object
#F  ConvertToCharacterTableNC( <record> ) . . . create character table object
##
##  Let <record> be a record.
##  `ConvertToCharacterTable' converts <record> into a component object
##  (see~"prg:Component Objects" in ``Programming in {\GAP}'')
##  representing a character table.
##  The values of those components of <record> whose names occur in
##  `SupportedCharacterTableInfo' (see~"SupportedCharacterTableInfo")
##  correspond to attribute values of the returned character table.
##  All other components of the record simply become components of the
##  character table object.
##
##  If inconsistencies in <record> are detected, `fail' is returned.
##  <record> must have the component `UnderlyingCharacteristic' bound
##  (see~"UnderlyingCharacteristic"),
##  since this decides about whether the returned character table lies in
##  `IsOrdinaryTable' or in `IsBrauerTable'
##  (see~"IsOrdinaryTable", "IsBrauerTable").
##
##  `ConvertToCharacterTableNC' does the same except that all checks of
##  <record> are omitted.
##
##  An example of a conversion from a record to a character table object
##  can be found in Section~"PrintCharacterTable".
##
DeclareGlobalFunction( "ConvertToCharacterTable" );

DeclareGlobalFunction( "ConvertToCharacterTableNC" );


#############################################################################
##
#F  ConvertToLibraryCharacterTableNC( <record> )
##
##  For a record <record> that shall be converted into an ordinary or Brauer
##  character table that knows to belong to the {\GAP} character table
##  library, `ConvertToLibraryCharacterTableNC' does the same as
##  `ConvertToOrdinaryTableNC', except that additionally the filter
##  `IsLibraryCharacterTableRep' is set
##  (see the manual of the {\GAP} Character Table Library).
##
##  But if <record> has the component `isGenericTable', with value `true',
##  then no attribute values are set.
##
##  (The handling of generic character tables may change in the future.
##  Currently they are used just just for specialization,
##  see~"ctbllib:Generic Character Tables" in the manual of the {\GAP}
##  Character Table Library.)
##
DeclareGlobalFunction( "ConvertToLibraryCharacterTableNC" );


#############################################################################
##
##  9. Printing Character Tables
#11
##  \indextt{ViewObj!for character tables}
##  The default  `ViewObj'  (see~"ViewObj")  method  for  ordinary  character
##  tables prints the string `\"CharacterTable\"', followed by the identifier
##  (see~"Identifier!for character tables") or, if known, the  group  of  the
##  character table enclosed in brackets. `ViewObj' for  Brauer  tables  does
##  the same, except that the first string is replaced by  `\"BrauerTable\"',
##  and that the characteristic is also shown.
##
##  \indextt{PrintObj!for character tables}
##  The default `PrintObj' (see~"PrintObj") method for character tables
##  does the same as `ViewObj',
##  except that the group is is `Print'-ed instead of `View'-ed.
##
##  \indextt{Display!for character tables}
##  The default `Display' (see~"Display") method for a character table <tbl>
##  prepares the data contained in <tbl> for a pretty columnwise output.
##  The number of columns printed at one time depends on the actual
##  line length, which can be accessed and changed by the function
##  `SizeScreen' (see~"SizeScreen").
##
##  `Display' shows certain characters (by default all irreducible
##  characters) of <tbl>, together with the orders of the centralizers in
##  factorized form and the available power maps (see~"ComputedPowerMaps").
##  Each displayed character is given a name `X.<n>'.
##
##  The first lines of the output describe the order of the centralizer
##  of an element of the class factorized into its prime divisors.
##
##  The next line gives the name of each class.
##  If no class names are stored on <tbl>, `ClassNames' is called
##  (see~"ClassNames").
##
##  Preceded by a name `P<n>', the next lines show the <n>th power maps
##  of <tbl> in terms of the former shown class names.
##
##  Every ambiguous or unknown (see Chapter~"Unknowns") value of the table
##  is displayed as a question mark `?'.
##
##  Irrational character values are not printed explicitly because the
##  lengths of their printed representation might disturb the layout.
##  Instead of that every irrational value is indicated by a name,
##  which is a string of at least one capital letter.
##
##  Once a name for an irrational value is found, it is used all over the
##  printed table.
##  Moreover the complex conjugate (see~"ComplexConjugate", "GaloisCyc")
##  and the star of an irrationality (see~"StarCyc") are represented by
##  that very name preceded by a `/' and a `\*', respectively.
##
##  The printed character table is then followed by a legend,
##  a list identifying the occurring symbols with their actual values.
##  Occasionally this identification is supplemented by a quadratic
##  representation of the irrationality together with the corresponding
##  {\ATLAS}--notation (see~\cite{CCN85}).
##
##  The optional second argument <arec> of `Display' can be used to change
##  the default style (mentioned above) for displaying a character.
##  <arec> must be a record, its relevant components are the following.
##
##  \beginitems
##  `chars' &
##      an integer or a list of integers to select a sublist of the
##      irreducible characters of <tbl>,
##      or a list of characters of <tbl>
##      (in this case the letter `\"X\"' is replaced by `\"Y\"'),
##
##  `classes' &
##      an integer or a list of integers to select a sublist of the
##      classes of <tbl>,
##
##  `centralizers' &
##      suppresses the printing of the orders of the centralizers
##      if `false',
##
##  `powermap' &
##      an integer or a list of integers to select a subset of the
##      available power maps, or `false' to suppress the printing of
##      power maps,
##
##  `letter' &
##      a single capital letter (e.~g.~`\"P\"' for permutation characters)
##      to replace `\"X\"',
##
##  `indicator' &
##      `true' enables the printing of the second Frobenius Schur indicator,
##      a list of integers enables the printing of the corresponding
##      indicators (see~"Indicator"),
##
##  `StringEntry' &
##      a function that takes either a character value or a character value
##      and the return value of `StringEntryData' (see below),
##      and returns the string that is actually displayed;
##      it is called for all character values to be displayed,
##      and also for the displayed indicator values (see above);
##      the default `StringEntry' function is 
##      `CharacterTableDisplayStringEntryDefault',
##
##  `StringEntryData' &
##      a unary function that is called once with argument <tbl> before the
##      character values are displayed;
##      it returns an object that is used as second argument of the function
##      `StringEntry';
##      the default `StringEntryData' function is
##      `CharacterTableDisplayStringEntryDataDefault',
##
##  `PrintLegend' &
##      a function that is called with the result of the `StringEntryData'
##      call after the character table has been displayed;
##      the default `PrintLegend' function is
##      `CharacterTableDisplayPrintLegendDefault'.
##  \enditems
##  If the value of `DisplayOptions' (see~"DisplayOptions") is stored on
##  <tbl>, it is used as default value for <arec> in the one argument call of
##  `Display'.
##


#############################################################################
##
#A  DisplayOptions( <tbl> )
##
#T is a more general attribute?
##  There is no default method to compute a value,
##  one can set a value with `SetDisplayOptions'.
##
DeclareAttribute( "DisplayOptions", IsNearlyCharacterTable );


#############################################################################
##
#F  CharacterTableDisplayStringEntryDefault( <entry>, <data> )
#F  CharacterTableDisplayStringEntryDataDefault( <tbl> )
#F  CharacterTableDisplayPrintLegendDefault( <data> )
##
DeclareGlobalFunction( "CharacterTableDisplayStringEntryDefault" );
DeclareGlobalFunction( "CharacterTableDisplayStringEntryDataDefault" );
DeclareGlobalFunction( "CharacterTableDisplayPrintLegendDefault" );


#############################################################################
##
#F  PrintCharacterTable( <tbl>, <varname> )
##
##  Let <tbl> be a nearly character table, and <varname> a string.
##  `PrintCharacterTable' prints those values of the supported attributes
##  (see~"SupportedCharacterTableInfo") that are known for <tbl>;
#T  If <tbl> is a library table then also the known values of supported
#T  components (see~"SupportedLibraryTableComponents") are printed.
##
##  The output of `PrintCharacterTable' is {\GAP} readable;
##  actually reading it into {\GAP} will bind the variable with name
##  <varname> to a character table that coincides with <tbl> for all
##  printed components.
##
##  This is used mainly for saving character tables to files.
##  A more human readable form is produced by `Display'.
##
#T note that a table with group can be read back only if the group elements
#T can be read back;
#T so this works for permutation groups but not for PC groups!
#T (what about the efficiency?)
##
#T Is there a problem of consistency,
#T if the group is stored but classes are not, and later the classes
#T are automatically constructed? (This should be safe.)
##
DeclareGlobalFunction( "PrintCharacterTable" );


#############################################################################
##
##  10. Constructing Character Tables from Others
#12
##
##  The following operations take one or more character table arguments,
##  and return a character table.
##  This holds also for `BrauerTable' (see~"BrauerTable");
##  note that the return value of `BrauerTable' will in general not
##  know the irreducible Brauer characters,
##  and {\GAP} might be unable to compute these characters.
##
##  *Note* that whenever fusions between input and output tables occur in
##  these operations,
##  they are stored on the concerned tables,
##  and the `NamesOfFusionSources' values are updated.
##
##  (The interactive construction of character tables using character
##  theoretic methods and incomplete tables is not described here.)
##  *@Currently it is not supported and will be described in a chapter of its
##  own when it becomes available@*.
##


#############################################################################
##
#O  CharacterTableDirectProduct( <tbl1>, <tbl2> )
##
##  is the table of the direct product of the character tables <tbl1>
##  and <tbl2>.
##
##  The matrix of irreducibles of this table is the Kronecker product
##  (see~"KroneckerProduct") of the irreducibles of <tbl1> and <tbl2>.
##
##  Products of ordinary and Brauer character tables are supported.
##
##  In general, the result will not know an underlying group,
##  so missing power maps (for prime divisors of the result)
##  and irreducibles of <tbl1> and <tbl2> may be computed in order to
##  construct the direct product.
##
##  The embeddings of <tbl1> and <tbl2> into the direct product are stored,
##  they can be fetched with `GetFusionMap' (see~"GetFusionMap");
##  if <tbl1> is equal to <tbl2> then the two embeddings are distinguished
##  by their `specification' components `"1"' and `"2"', respectively.
##
##  Analogously, the projections from the direct product onto <tbl1> and
##  <tbl2> are stored, and can be distinguished by the `specification'
##  compoenents.
##
#T generalize this to arbitrarily many arguments!
##
##  The `\*' operator for two character tables
##  (see~"Operators for Character Tables") delegates to
##  `CharacterTableDirectProduct'.
##
DeclareOperation( "CharacterTableDirectProduct",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );


#############################################################################
##
#F  CharacterTableHeadOfFactorGroupByFusion( <tbl>, <factorfusion> )
##
##  is the character table of the factor group of the ordinary character
##  table <tbl> defined by the list <factorfusion> that describes the
##  factor fusion.
##  The irreducible characters of the factor group are *not* computed.
##
DeclareGlobalFunction( "CharacterTableHeadOfFactorGroupByFusion" );


#############################################################################
##
#O  CharacterTableFactorGroup( <tbl>, <classes> )
##
##  is the character table of the factor group of the ordinary character
##  table <tbl> by the normal closure of the classes whose positions are
##  contained in the list <clases>.
##
##  The `\/' operator for a character table and a list of class positions
##  (see~"Operators for Character Tables") delegates to
##  `CharacterTableFactorGroup'.
##
DeclareOperation( "CharacterTableFactorGroup",
    [ IsNearlyCharacterTable, IsHomogeneousList ] );


#############################################################################
##
#O  CharacterTableIsoclinic( <tbl> )
#O  CharacterTableIsoclinic( <tbl>, <classes> )
#O  CharacterTableIsoclinic( <tbl>, <classes>, <centre> )
##
##  If <tbl> is the character table of a group with structure $2\.G\.2$
##  with a central subgroup $Z$ of order $2$ and a normal subgroup $N$ of
##  index $2$ that contains $Z$ then `CharacterTableIsoclinic' returns
##  the character table of the isoclinic group in the sense of the {\ATLAS}
##  of Finite Groups~\cite{CCN85}, Chapter~6, Section~7.
##  If $N$ is not uniquely determined then the positions of the classes
##  forming $N$ must be entered as list <classes>.
##  If $Z$ is not unique in $N$ then the position of the class consisting
##  of the involution in $Z$ must be entered as <centre>.
##
#T table arises  from mult. char. values in the outer corner with `E(4)';
#T generalized in order to admit 4.HS.2 (< HN.2) --> works?
##
DeclareOperation( "CharacterTableIsoclinic", [ IsNearlyCharacterTable ] );
DeclareOperation( "CharacterTableIsoclinic",
    [ IsNearlyCharacterTable, IsList and IsCyclotomicCollection ] );
DeclareOperation( "CharacterTableIsoclinic",
    [ IsNearlyCharacterTable, IsList and IsCyclotomicCollection, IsPosInt ]);


#############################################################################
##
#F  CharacterTableOfNormalSubgroup( <ordtbl>, <classes> )
##
##  returns the restriction of the ordinary character table <ordtbl>
##  to the classes in the list <classes>.
##
##  In most cases, this table is only an approximation of the character table
##  of this normal subgroup, and some classes of the normal subgroup must be
##  split (see~"CharacterTableSplitClasses") in order to get a character
##  table.
##  The result is only a table in progress then
##  (see~"Character Table Categories").
##
##  If the classes in <classes> need not to be split then the result is a
##  proper character table.
##
DeclareGlobalFunction( "CharacterTableOfNormalSubgroup" );


#############################################################################
##
#F  CharacterTableOfTypeGS3( <tbl>, <tbl2>, <tbl3>, <aut>, <identifier> )
##
##  Let $H$ be a group with a normal subgroup $G$ such that $H/G \equiv S_3$,
##  the symmetric group of degree $3$,
##  and let $G\.2$ and $G\.3$ be preimages of subgroups of order $2$ and $3$,
##  respectively, under the natural projection onto this factor group.
##
##  Let <tbl>, <tbl2>, and <tbl3> be the ordinary character tables of the
##  groups $G$, $G\.2$, and $G\.3$, respectively,
##  and <aut> the permutation of classes of <tbl3> induced by the action
##  of $H$ on $G\.3$.
##  Furthermore, let the class fusions from <tbl> to <tbl2> and <tbl3> be
##  stored on <tbl> (see~"StoreFusion").
##
##  `CharacterTableOfTypeGS3' returns a record with the following components.
##  \beginitems
##  `table' &
##      the ordinary character table of $H$,
##
##  `tbl2fustbls3' &
##      the fusion map from <tbl2> into the table of $H$, and
##
##  `tbl3fustbls3' &
##      the fusion map from <tbl3> into the table of $H$.
##  \enditems
##
##  The returned table of $H$ has the `Identifier' value <identifier>.
##  The classes of the table of $H$ are sorted as follows.
##  First come the classes contained in $G\.3$, sorted compatibly with the
##  classes in <tbl3>, then the classes in $H \setminus G\.3$ follow,
##  in the same ordering as the classes of $G\.2 \setminus G$.
##
DeclareGlobalFunction( "CharacterTableOfTypeGS3" );


#############################################################################
##
#F  PossibleActionsForTypeGS3( <tbl>, <tbl2>, <tbl3> )
##
##  Let the arguments be as described for `CharacterTableOfTypeGS3'
##  (see~"CharacterTableOfTypeGS3").
##  `PossibleActionsForTypeGS3' returns the set of those table automorphisms
##  (see~"AutomorphismsOfTable") of <tbl3> that may be induced by the action
##  of $H$ on $G\.3$.
##
##  The progress is reported if the level of `InfoCharacterTable' is at least
##  $1$ (see~"SetInfoLevel").
##
DeclareGlobalFunction( "PossibleActionsForTypeGS3" );


#############################################################################
##
#F  CharacterTableOfTypeMGA( <tblMG>, <tblG>, <tblGA>, <aut>, <identifier> )
##
##  Let $H$ be a group with normal subgroups $N$ and $M$ such that
##  $H/N$ is cyclic, $M \leq N$ holds,
##  and such that each irreducible character of $N$
##  that does not contain $M$ in its kernel has inertia group $N$ in $H$.
##  (This is satisfied for example if $N$ has prime index in $H$
##  and $M$ is central in $N$ but not in $H$.)
#T equivalent to the fact that $H$ acts fixed point freely on $M$?
#T note that I need this for transferring the element orders!
#T (namely, for $g \in H \setminus N$,
#T if $gM$ has order $n$ in $H/M$ then $g$ has order $n$ in $H$
#T because $g^n = m \in M$ implies $g^{-1} m g = m$ and thus $m = 1$.)
##  Let $G = N/M$ and $A = H/N$, so $H$ has the structure $M\.G\.A$.
##
##  Let <tblMG>, <tblG>, <tblGA> be the ordinary character tables of the
##  groups $M\.G$, $G$, and $G\.A$, respectively,
##  and <aut> the permutation of classes of <tblMG> induced by the action
##  of $H$ on $M\.G$.
##  Furthermore, let the class fusions from <tblMG> to <tblG> and from <tblG>
##  to <tblGA> be stored on <tblMG> and <tblG>, respectively
##  (see~"StoreFusion").
##
##  `CharacterTableOfTypeMGA' returns a record with the following components.
##  \beginitems
##  `table' &
##      the ordinary character table of $H$, and
##
##  `MGfusMGA' &
##      the fusion map from <tblMG> into the table of $H$.
##  \enditems
##
##  The returned table of $H$ has the `Identifier' value <identifier>.
##  The classes of the table of $H$ are sorted as follows.
##  First come the classes contained in $M\.G$, sorted compatibly with the
##  classes in <tblMG>, then the classes in $H \setminus M\.G$ follow,
##  in the same ordering as the classes of $G\.A \setminus G$.
##
DeclareGlobalFunction( "CharacterTableOfTypeMGA" );


#############################################################################
##
#F  PossibleActionsForTypeMGA( <tblMG>, <tblG>, <tblGA> )
##
##  Let the arguments be as described for `CharacterTableOfTypeMGA'
##  (see~"CharacterTableOfTypeMGA").
##  `PossibleActionsForTypeMGA' returns the set of those table automorphisms
##  (see~"AutomorphismsOfTable") of <tblMG> that may be induced by the action
##  of $H$ on $M\.G$.
##
##  The progress is reported if the level of `InfoCharacterTable' is at least
##  $1$ (see~"SetInfoLevel").
##
DeclareGlobalFunction( "PossibleActionsForTypeMGA" );


#############################################################################
##
##  11. Sorted Character Tables
##


#############################################################################
##
#F  PermutationToSortCharacters( <tbl>, <chars>, <degree>, <norm> )
##
##  returns a permutation that applied to the list <chars> of characters of
##  the character table <tbl> will cause the characters to be sorted
##  w.r.t.~increasing degree, norm, or both.
##  <degree> and <norm> must be booleans.
##  If <norm> is `true' then characters of smaller norm precede characters
##  of larger norm.
##  If both <degree> and <norm> are `true' then additionally characters of
##  same norm are sorted w.r.t.~increasing degree.
##  If only <degree> is `true' then characters of smaller degree precede
##  characters of larger degree.
##
##  Rational characters precede characters with irrationalities of same norm
##  and/or degree, and the trivial character will be sorted to position $1$
##  if it occurs in <chars>.
##
DeclareGlobalFunction( "PermutationToSortCharacters" );


#############################################################################
##
#O  CharacterTableWithSortedCharacters( <tbl> )
#O  CharacterTableWithSortedCharacters( <tbl>, <perm> )
##
##  is a character table that differs from <tbl> only by the succession of
##  its irreducible characters.
##  This affects the values of the attributes `Irr' (see~"Irr") and
##  `CharacterParameters' (see~"ctbllib:CharacterParameters" in the manual
##  for the {\GAP} Character Table Library).
##  Namely, these lists are permuted by the permutation <perm>.
##
##  If no second argument is given then a permutation is used that yields
##  irreducible characters of increasing degree for the result.
##  For the succession of characters in the result, see~"SortedCharacters".
##
##  The result has all those attributes and properties of <tbl> that are
##  stored in `SupportedCharacterTableInfo' and do not depend on the
##  ordering of characters (see~"SupportedCharacterTableInfo").
##
DeclareOperation( "CharacterTableWithSortedCharacters",
    [ IsNearlyCharacterTable ] );
DeclareOperation( "CharacterTableWithSortedCharacters",
    [ IsNearlyCharacterTable, IsPerm ] );


#############################################################################
##
#O  SortedCharacters( <tbl>, <chars> )
#O  SortedCharacters( <tbl>, <chars>, \"norm\" )
#O  SortedCharacters( <tbl>, <chars>, \"degree\" )
##
##  is a list containing the characters <chars>, ordered as specified
##  by the other arguments.
##
##  There are three possibilities to sort characters:
##  They can be sorted according to ascending norms (parameter `\"norm\"'),
##  to ascending degree (parameter `\"degree\"'),
##  or both (no third parameter),
##  i.e., characters with same norm are sorted according to ascending degree,
##  and characters with smaller norm precede those with bigger norm.
##
##  Rational characters in the result precede other ones with same norm
##  and/or same degree.
##
##  The trivial character, if contained in <chars>, will always be sorted to
##  the first position.
##
DeclareOperation( "SortedCharacters",
    [ IsNearlyCharacterTable, IsHomogeneousList ] );
DeclareOperation( "SortedCharacters",
    [ IsNearlyCharacterTable, IsHomogeneousList, IsString ] );


#############################################################################
##
#F  PermutationToSortClasses( <tbl>, <classes>, <orders> )
##
##  returns a permutation that applied to the columns in the character table
##  <tbl> will cause the classes to be sorted w.r.t.~increasing class length,
##  element order, or both.
##  <classes> and <orders> must be booleans.
##  If <orders> is `true' then classes of element of smaller order precede
##  classes of elements of larger order.
##  If both <classes> and <orders> are `true' then additionally classes of
##  elements of the same order are sorted w.r.t.~increasing length.
##  If only <classes> is `true' then smaller classes precede larger ones.
##
DeclareGlobalFunction( "PermutationToSortClasses" );


#############################################################################
##
#O  CharacterTableWithSortedClasses( <tbl> )
#O  CharacterTableWithSortedClasses( <tbl>, \"centralizers\" )
#O  CharacterTableWithSortedClasses( <tbl>, \"representatives\" )
#O  CharacterTableWithSortedClasses( <tbl>, <permutation> )
##
##  is a character table obtained by permutation of the classes of <tbl>.
##  If the second argument is the string `\"centralizers\"' then the classes
##  of the result are sorted according to descending centralizer orders.
##  If the second argument is the string `\"representatives\"' then the
##  classes of the result are sorted according to ascending representative
##  orders.
##  If no second argument is given then the classes of the result are sorted
##  according to ascending representative orders,
##  and classes with equal representative orders are sorted according to
##  descending centralizer orders.
##
##  If the second argument is a permutation <perm> then the classes of the
##  result are sorted by application of this permutation.
##
##  The result has all those attributes and properties of <tbl> that are
##  stored in `SupportedCharacterTableInfo' and do not depend on the
##  ordering of classes (see~"SupportedCharacterTableInfo").
##
DeclareOperation( "CharacterTableWithSortedClasses",
    [ IsNearlyCharacterTable ] );
DeclareOperation( "CharacterTableWithSortedClasses",
    [ IsNearlyCharacterTable, IsString ] );
DeclareOperation( "CharacterTableWithSortedClasses",
    [ IsNearlyCharacterTable, IsPerm ] );


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
##  `Irr( <tbl> )' such that the first characters are those that contain
##  <kernel> in their kernel.
##
##  The second form does the same successively for all kernels $k_i$ in
##  the list $<normalseries> = [ k_1, k_2, \ldots, k_n ]$ where
##  $k_i$ must be a sublist of $k_{i+1}$ for $1 \leq i \leq n-1$.
##
##  The third form computes the table $F$ of the factor group of <tbl>
##  modulo the normal subgroup formed by the classes whose positions are
##  contained in the list <kernel>;
##  $F$ must be permutation equivalent to the table <facttbl>,
##  in the sense of `TransformingPermutationsCharacterTables'
##  (see~"TransformingPermutationsCharacterTables"),
##  otherwise `fail' is returned.
##  The classes of <tbl> are sorted such that the preimages
##  of a class of $F$ are consecutive,
##  and that the succession of preimages is that of <facttbl>.
##  `Irr( <tbl> )' is sorted as with `SortCharTable( <tbl>, <kernel> )'.
##
##  (*Note* that the transformation is only unique up to table automorphisms
##  of $F$, and this need not be unique up to table automorphisms of <tbl>.)
##
##  All rearrangements of classes and characters are stable,
##  i.e., the relative positions of classes and characters that are not
##  distinguished by any relevant property is not changed.
##
##  The result has all those attributes and properties of <tbl> that are
##  stored in `SupportedCharacterTableInfo' and do not depend on the
##  ordering of classes and characters (see~"SupportedCharacterTableInfo").
##
##  The `ClassPermutation' value of <tbl> is changed if necessary,
##  see~"Conventions for Character Tables".
##
##  `SortedCharacterTable' uses `CharacterTableWithSortedClasses' and
##  `CharacterTableWithSortedCharacters'
##  (see~"CharacterTableWithSortedClasses",
##  "CharacterTableWithSortedCharacters").
##
DeclareGlobalFunction( "SortedCharacterTable" );


#############################################################################
##
#A  ClassPermutation( <tbl> )
##
##  is a permutation $\pi$ of classes of the character table <tbl>.
##  If it is stored then class fusions into <tbl> that are stored on other
##  tables must be followed by $\pi$ in order to describe the correct
##  fusion.
##
##  This attribute value is bound only if <tbl> was obtained from another
##  table by permuting the classes, using
##  `CharacterTableWithSortedClasses' or `SortedCharacterTable',
##  (see~"CharacterTableWithSortedClasses", "SortedCharacterTable").
##
##  It is necessary because the original table and the sorted table have the
##  same identifier (and the same group if known),
##  and hence the same fusions are valid for the two tables.
##
DeclareAttributeSuppCT( "ClassPermutation", IsNearlyCharacterTable,
    [ "class" ] );


#############################################################################
##
##  12. Storing Normal Subgroup Information
##


##############################################################################
##
#A  NormalSubgroupClassesInfo( <tbl> )
##
##  Let <tbl> be the ordinary character table of the group $G$.
##  Many computations for group characters of $G$ involve computations
##  in normal subgroups or factor groups of $G$.
##
##  In some cases the character table <tbl> is sufficient;
##  for example questions about a normal subgroup $N$ of $G$ can be answered
##  if one knows the conjugacy classes that form $N$,
##  e.g., the question whether a character of $G$ restricts
##  irreducibly to $N$.
##  But other questions require the computation of $N$ or
##  even more information, like the character table of $N$.
##
##  In order to do these computations only once, one stores in the group a
##  record with components to store normal subgroups, the corresponding lists
##  of conjugacy classes, and (if necessary) the factor groups, namely
##
##  \beginitems
##  `nsg': &
##      list of normal subgroups of $G$, may be incomplete,
##
##  `nsgclasses': &
##      at position $i$, the list of positions of conjugacy
##      classes of <tbl> forming the $i$-th entry of the `nsg' component,
##
##  `nsgfactors': &
##      at position $i$, if bound, the factor group
##      modulo the $i$-th entry of the `nsg' component.
##  \enditems
##
##  The functions
##  `NormalSubgroupClasses',
##  `FactorGroupNormalSubgroupClasses', and
##  `ClassPositionsOfNormalSubgroup'
##  use these components, and they are the only functions that do this.
##
##  So if you need information about a normal subgroup for that you know the
##  conjugacy classes, you should get it using `NormalSubgroupClasses'.  If
##  the normal subgroup was already used it is just returned, with all the
##  knowledge it contains.  Otherwise the normal subgroup is added to the
##  lists, and will be available for the next call.
##
##  For example, if you are dealing with kernels of characters using the
##  `KernelOfCharacter' function you make use of this feature
##  because `KernelOfCharacter' calls `NormalSubgroupClasses'.
##
DeclareAttribute( "NormalSubgroupClassesInfo", IsOrdinaryTable, "mutable" );


##############################################################################
##
#F  ClassPositionsOfNormalSubgroup( <tbl>, <N> )
##
##  is the list of positions of conjugacy classes of the character table
##  <tbl> that are contained in the normal subgroup <N>
##  of the underlying group of <tbl>.
##
DeclareGlobalFunction( "ClassPositionsOfNormalSubgroup" );


##############################################################################
##
#F  NormalSubgroupClasses( <tbl>, <classes> )
##
##  returns the normal subgroup of the underlying group $G$ of the ordinary
##  character table <tbl>
##  that consists of those conjugacy classes of <tbl> whose positions are in
##  the list <classes>.
##
##  If `NormalSubgroupClassesInfo( <tbl> ).nsg' does not yet contain
##  the required normal subgroup,
##  and if `NormalSubgroupClassesInfo( <tbl> ).normalSubgroups' is bound then
##  the result will be identical to the group in
##  `NormalSubgroupClassesInfo( <tbl> ).normalSubgroups'.
##
DeclareGlobalFunction( "NormalSubgroupClasses" );


##############################################################################
##
#F  FactorGroupNormalSubgroupClasses( <tbl>, <classes> )
##
##  is the factor group of the underlying group $G$ of the ordinary character
##  table <tbl> modulo the normal subgroup of $G$ that consists of those
##  conjugacy classes of <tbl> whose positions are in the list <classes>.
##
DeclareGlobalFunction( "FactorGroupNormalSubgroupClasses" );


#############################################################################
##
##  13. Auxiliary Stuff
##

#############################################################################
##
##  The following representation is used for the character table library.
##  As the library refers to it, it has to be declared in a library file
##  not to enforce installing the character tables library.
##


#############################################################################
##
#V  SupportedLibraryTableComponents
#R  IsLibraryCharacterTableRep( <tbl> )
##
##  Ordinary library tables may have some components that are meaningless for
##  character tables that know their underlying group.
##  These components do not justify the introduction of operations to fetch
##  them.
##
##  Library tables are always complete character tables.
##  Note that in spite of the name, `IsLibraryCharacterTableRep' is used
##  *not* only for library tables; for example, the direct product of two
##  tables with underlying groups or a factor table of a character table with
##  underlying group may be in `IsLibraryCharacterTableRep'.
##
##  (The unorthodox ordering of the component names below is due to the
##  ordering used in the data files.)
##
BindGlobal( "SupportedLibraryTableComponents", [
      # These are used only for Brauer tables, they are set only by `MBT'.
     "basicset",
     "brauertree",
     "decinv",
     "defect",
     "factorblocks",
     "indicator",
     # These are used only for ordinary tables.
     "cliffordTable",
     "construction",    # does not occur in data files, is set in `MOT'
     "projectives",
     "isSimple",
     "extInfo",
     "factors",
     "tomfusion",
     "tomidentifier",
    ] );

DeclareRepresentation( "IsLibraryCharacterTableRep", IsAttributeStoringRep,
    SupportedLibraryTableComponents );


#############################################################################
##
#R  IsGenericCharacterTableRep( <tbl> )
##
##  generic character tables are a special representation of objects since
##  they provide just some record components.
##  It might be useful to treat them similar to character table like objects,
##  for example to display them.
##  So they belong to the category of nearly character tables.
##
DeclareRepresentation( "IsGenericCharacterTableRep", IsNearlyCharacterTable,
     [
     "domain",
     "wholetable",
     "classparam",
     "charparam",
     "specializedname",
     "size",
     "centralizers",
     "orders",
     "powermap",
     "classtext",
     "matrix",
     "irreducibles",
     "text",
     ] );


#############################################################################
##
#E

