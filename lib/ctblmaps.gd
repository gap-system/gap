#############################################################################
##
#W  ctblmaps.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration of those functions that are used
##  to construct maps (mostly fusion maps and power maps).
##
##  1. Maps Concerning Character Tables
##  2. Power Maps
##  3. Class Fusions between Character Tables
##  4. Utilities for Parametrized Maps
##  5. Subroutines for the Construction of Power Maps
##  6. Subroutines for the Construction of Class Fusions
##
Revision.ctblmaps_gd :=
    "@(#)$Id$";


#############################################################################
##
##  1. Maps Concerning Character Tables
#1
##  Besides the characters, *power maps* (see~"Power Maps") are an important
##  part of a character table.
##  Often their computation is not easy, and if the table has no access to
##  the underlying group then in general they cannot be obtained from the
##  matrix of irreducible characters;
##  so it is useful to store them on the table.
##
##  If not only a single table is considered but different tables of a group
##  and a subgroup or of a group and a factor group are used,
##  also *class fusion maps* (see~"Class Fusions between Character Tables")
##  must be known to get information about the embedding or simply to induce
##  or restrict characters (see~"Restricted and Induced Class Functions").
##
##  These are examples of functions from conjugacy classes which will be
##  called *maps* in the following.
##  (This should not be confused with the term mapping, see~"Mappings".)
##  In {\GAP}, maps are represented by lists.
##  Also each character, each list of element orders, centralizer orders,
##  or class lengths are maps,
##  and for a permutation <perm> of classes, `ListPerm( <perm> )' is a map.
##
##  When maps are constructed without access to a group, often one only knows
##  that the image of a given class is contained in a set of possible images,
##  e.g., that the image of a class under a subgroup fusion is in the set of
##  all classes with the same element order.
##  Using further information, such as centralizer orders, power maps and the
##  restriction of characters, the sets of possible images can be restricted
##  further.
##  In many cases, at the end the images are uniquely determined.
##
##  Because of this approach, many functions in this chapter work not only
##  with maps but with *parametrized maps* (or paramaps for short).
##  More about parametrized maps can be found in Section~"Parametrized Maps".
##
##  The implementation follows~\cite{Bre91},
##  a description of the main ideas together with several examples
##  can be found in~\cite{Bre99}.
##


#############################################################################
##
##  2. Power Maps
#2
##  The $n$-th power map of a character table is represented by a list that
##  stores at position $i$ the position of the class containing the $n$-th
##  powers of the elements in the $i$-th class.
##  The $n$-th power map can be composed from the power maps of the prime
##  divisors $p$ of $n$,
##  so usually only power maps for primes $p$ are actually stored in the
##  character table.
##
##  For an ordinary character table <tbl> with access to its underlying group
##  $G$,
##  the $p$-th power map of <tbl> can be computed using the identification of
##  the conjugacy classes of $G$ with the classes of <tbl>.
##  For an ordinary character table without access to a group,
##  in general the $p$-th power maps (and hence also the element orders) for
##  prime divisors $p$ of the group order are not uniquely determined
##  by the matrix of irreducible characters.
##  So only necessary conditions can be checked in this case,
##  which in general yields only a list of several possibilities for the
##  desired power map.
##  Character tables of the {\GAP} character table library store all $p$-th
##  power maps for prime divisors $p$ of the group order.
##
##  Power maps of Brauer tables can be derived from the power maps of the
##  underlying ordinary tables.
##
##  For (computing and) accessing the $n$-th power map of a character table,
##  `PowerMap' (see~"PowerMap") can be used;
##  if the $n$-th power map cannot be uniquely determined then `PowerMap'
##  returns `fail'.
##
##  The list of all possible $p$-th power maps of a table in the sense that
##  certain necessary conditions are satisfied can be computed with
##  `PossiblePowerMaps' (see~"PossiblePowerMaps").
##  This provides a default strategy, the subroutines are listed in
##  Section~"Subroutines for the Construction of Power Maps".
##


#############################################################################
##
#O  PowerMap( <tbl>, <n>[, <class>] )
#O  PowerMapOp( <tbl>, <n>[, <class>] )
#A  ComputedPowerMaps( <tbl> )
##
##  Called with first argument a character table <tbl> and second argument an
##  integer <n>,
##  `PowerMap' returns the <n>-th power map of <tbl>.
##  This is a list containing at position $i$ the position of the class of
##  <n>-th powers of the elements in the $i$-th class of <tbl>.
##
##  If the additional third argument <class> is present then the position of
##  <n>-th powers of the <class>-th class is returned.
##
##  If the <n>-th power map is not uniquely determined by <tbl> then `fail'
##  is returned.
##  This can happen only if <tbl> has no access to its underlying group.
##
##  The power maps of <tbl> that were computed already by `PowerMap'
##  are stored in <tbl> as value of the attribute `ComputedPowerMaps',
##  the $n$-th power map at position $n$.
##  `PowerMap' checks whether the desired power map is already stored,
##  computes it using the operation `PowerMapOp' if it is not yet known,
##  and stores it.
##  So methods for the computation of power maps can be installed for
##  the operation `PowerMapOp'.
##
##  % For power maps of groups, see~"PowerMapOfGroup".
##
DeclareOperation( "PowerMap", [ IsNearlyCharacterTable, IsInt ] );
DeclareOperation( "PowerMap", [ IsNearlyCharacterTable, IsInt, IsInt ] );

DeclareOperation( "PowerMapOp", [ IsNearlyCharacterTable, IsInt ] );
DeclareOperation( "PowerMapOp", [ IsNearlyCharacterTable, IsInt, IsInt ] );

DeclareAttributeSuppCT( "ComputedPowerMaps",
    IsNearlyCharacterTable, "mutable", [ "class" ] );


#############################################################################
##
#O  PossiblePowerMaps( <tbl>, <p>[, <options>] )
##
##  For the ordinary character table <tbl> of the group $G$, say,
##  and a prime integer <p>,
##  `PossiblePowerMaps' returns the list of all maps that have the following
##  properties of the $p$-th power map of <tbl>.
##  (Representative orders are used only if the `OrdersClassRepresentatives'
##  value of <tbl> is known, see~"OrdersClassRepresentatives".)
##  \beginlist
##  \item{1.}
##       For class $i$, the centralizer order of the image is a multiple of
##       the $i$-th centralizer order;
##       if the elements in the $i$-th class have order coprime to $p$
##       then the centralizer orders of class $i$ and its image are equal.
##  \item{2.}
##       Let $n$ be the order of elements in class $i$.
##       If <prime> divides $n$ then the images have order $n/p$;
##       otherwise the images have order $n$.
##       These criteria are checked in `InitPowerMap' (see~"InitPowerMap").
##  \item{3.}
##       For each character $\chi$ of $G$ and each element $g$ in $G$,
##       the values $\chi(g^p)$ and $`GaloisCyc'( \chi(g), p )$ are
##       algebraic integers that are congruent modulo $p$;
##       if $p$ does not divide the element order of $g$ then the two values
##       are equal.
##       This congruence is checked for the characters specified below in
##       the discussion of the <options> argument;
##       For linear characters $\lambda$ among these characters,
##       the condition $\chi(g)^p = \chi(g^p)$ is checked.
##       The corresponding function is `Congruences' 
##       (see~"Congruences!for character tables").
##  \item{4.}
##       For each character $\chi$ of $G$, the kernel is a normal subgroup
##       $N$, and $g^p \in N$ for all $g \in N$;
##       moreover, if $N$ has index $p$ in $G$ then $g^p \in N$ for all
##       $g \in G$, and if the index of $N$ in $G$ is coprime to $p$ then
##       $g^p \not\in N$ for each $g \not\in N$.
##       These conditions are checked for the kernels of all characters
##       $\chi$ specified below,
##       the corresponding function is `ConsiderKernels'
##       (see~"ConsiderKernels").
##  \item{5.}
##       If $p$ is larger than the order $m$ of an element $g \in G$ then
##       the class of $g^p$ is determined by the power maps for primes
##       dividing the residue of $p$ modulo $m$.
##       If these power maps are stored in the `ComputedPowerMaps' value
##       (see~"ComputedPowerMaps") of <tbl> then this information is used.
##       This criterion is checked in `ConsiderSmallerPowerMaps'
##       (see~"ConsiderSmallerPowerMaps").
##  \item{6.}
##       For each character $\chi$ of $G$, the symmetrization $\psi$
##       defined by $\psi(g) = (\chi(g)^p - \chi(g^p))/p$ is a character.
##       This condition is checked for the kernels of all characters
##       $\chi$ specified below,
##       the corresponding function is `PowerMapsAllowedBySymmetrizations'
##       (see~"PowerMapsAllowedBySymmetrizations").
##  \endlist
##
##  If <tbl> is a Brauer table, the possibilities are computed from those for
##  the underlying ordinary table.
##
##  The optional argument <options> must be a record that may have the
##  following components:
##  \beginitems
##  `chars': &
##       a list of characters which are used for the check of the criteria
##       3., 4., and 6.;
##       the default is `Irr( <tbl> )',
##
##  `powermap': &
##       a parametrized map which is an approximation of the desired map
##
##  `decompose': &
##       a boolean;
##       a `true' value indicates that all constituents of the
##       symmetrizations of `chars' computed for criterion 6. lie in `chars',
##       so the symmetrizations can be decomposed into elements of `chars';
##       the default value of `decompose' is `true' if `chars' is not bound
##       and `Irr( <tbl> )' is known, otherwise `false',
##
##  `quick': &
##       a boolean;
##       if `true' then the subroutines are called with value `true' for
##       the argument <quick>;
##       especially, as soon as only one possibility remains
##       this possibility is returned immediately;
##       the default value is `false',
##
##  `parameters': &
##       a record with components `maxamb', `minamb' and `maxlen' which
##       control the subroutine `PowerMapsAllowedBySymmetrizations';
##       it only uses characters with current indeterminateness up to
##       `maxamb',
##       tests decomposability only for characters with current
##       indeterminateness at least `minamb',
##       and admits a branch according to a character only if there is one
##       with at most `maxlen' possible symmetrizations.
##  \enditems
##
DeclareOperation( "PossiblePowerMaps", [ IsCharacterTable, IsInt ] );
DeclareOperation( "PossiblePowerMaps", [ IsCharacterTable, IsInt,
    IsRecord ] );


#############################################################################
##
#F  ElementOrdersPowerMap( <powermap> )
##
##  Let <powermap> be a nonempty list containing at position $p$, if bound,
##  the $p$-th power map of a character table or group.
##  `ElementOrdersPowerMap' returns a list of the same length as each entry
##  in <powermap>, with entry at position $i$ equal to the order of elements
##  in class $i$ if this order is uniquely determined by <powermap>,
##  and equal to an unknown (see Chapter~"Unknowns") otherwise.
##
DeclareGlobalFunction( "ElementOrdersPowerMap" );


#############################################################################
##
#F  PowerMapByComposition( <tbl>, <n> ) . .  for char. table and pos. integer
##
##  <tbl> must be a nearly character table, and <n> a positive integer.
##  If the power maps for all prime divisors of <n> are stored in the
##  `ComputedPowerMaps' list of <tbl> then `PowerMapByComposition' returns
##  the <n>-th power map of <tbl>.
##  Otherwise `fail' is returned.
##
DeclareGlobalFunction( "PowerMapByComposition" );


#############################################################################
##
#3
##  The permutation group of matrix automorphisms (see~"MatrixAutomorphisms")
##  acts on the possible power maps returned by `PossiblePowerMaps'
##  (see~"PossiblePowerMaps")
##  by permuting a list via `Permuted' (see~"Permuted")
##  and then mapping the images via `OnPoints' (see~"OnPoints").
##  Note that by definition, the group of table automorphisms acts trivially.
##


#############################################################################
##
#F  OrbitPowerMaps( <map>, <permgrp> )
##
##  returns the orbit of the power map <map> under the action of the
##  permutation group <permgrp>
##  via a combination of `Permuted' (see~"Permuted") and `OnPoints'
##  (see~"OnPoints").
##
DeclareGlobalFunction( "OrbitPowerMaps" );


#############################################################################
##
#F  RepresentativesPowerMaps( <listofmaps>, <permgrp> )
##
##  returns a list of orbit representatives of the power maps in the list
##  <listofmaps> under the action of the permutation group <permgrp>
##  via a combination of `Permuted' (see~"Permuted") and `OnPoints'
##  (see~"OnPoints").
##
DeclareGlobalFunction( "RepresentativesPowerMaps" );


#############################################################################
##
##  3. Class Fusions between Character Tables
#4
##  For a group $G$ and a subgroup $H$ of $G$,
##  the fusion map between the character table of $H$ and the character table
##  of $G$ is represented by a list that stores at position $i$ the position
##  of the $i$-th class of the table of $H$ in the classes list of the table
##  of $G$.
##
##  For ordinary character tables <tbl1> and <tbl2> of $H$ and $G$,
##  with access to the groups $H$ and $G$,
##  the class fusion between <tbl1> and <tbl2> can be computed using the
##  identifications of the conjugacy classes of $H$ with the classes of
##  <tbl1> and the conjugacy classes of $G$ with the classes of <tbl2>.
##  For two ordinary character tables without access to its underlying group,
##  or in the situation that the group stored in <tbl1> is not physically a
##  subgroup of the group stored in <tbl2> but an isomorphic copy,
##  in general the class fusion is not uniquely determined by the information
##  stored on the tables such as irreducible characters and power maps.
##  So only necessary conditions can be checked in this case,
##  which in general yields only a list of several possibilities for the
##  desired class fusion.
##  Character tables of the {\GAP} character table library store various
##  class fusions that are regarded as important,
##  for example fusions from maximal subgroups (see~"ComputedClassFusions"
##  and "ctbllib:Maxes" in the manual for the {\GAP} Character Table Library).
##
##  Class fusions between Brauer tables can be derived from the class fusions
##  between the underlying ordinary tables.
##  The class fusion from a Brauer table to the underlying ordinary table is
##  stored when the Brauer table is constructed from the ordinary table,
##  so no method is needed to compute such a fusion.
##
##  For (computing and) accessing the class fusion between two character
##  tables,
##  `FusionConjugacyClasses' (see~"FusionConjugacyClasses") can be used;
##  if the class fusion cannot be uniquely determined then
##  `FusionConjugacyClasses' returns `fail'.
##
##  The list of all possible class fusion between two tables in the sense
##  that certain necessary conditions are satisfied can be computed with
##  `PossibleClassFusions' (see~"PossibleClassFusions").
##  This provides a default strategy, the subroutines are listed in
##  Section~"Subroutines for the Construction of Class Fusions".
##
##  It should be noted that all the following functions except
##  `FusionConjugacyClasses' (see~"FusionConjugacyClasses")
##  deal only with the situation of class fusions from subgroups.
##  The computation of *factor fusions* from a character table to the table
##  of a factor group is not dealt with here.
##  Since the ordinary character table of a group $G$ determines the
##  character tables of all factor groups of $G$, the factor fusion to a
##  given character table of a factor group of $G$ is determined up to table
##  automorphisms (see~"AutomorphismsOfTable") once the class positions of
##  the kernel of the natural epimorphism have been fixed.
##


#############################################################################
##
#O  FusionConjugacyClasses( <tbl1>, <tbl2> )
#O  FusionConjugacyClasses( <H>, <G> )
#O  FusionConjugacyClasses( <hom>[, <tbl1>, <tbl2>] )
#O  FusionConjugacyClassesOp( <tbl1>, <tbl2> )
#A  FusionConjugacyClassesOp( <hom> )
##
##  Called with two character tables <tbl1> and <tbl2>,
##  `FusionConjugacyClasses' returns the fusion of conjugacy classes between
##  <tbl1> and <tbl2>.
##  (If one of the tables is a Brauer table,
##  it will delegate this task to the underlying ordinary table.)
##
##  Called with two groups <H> and <G> where <H> is a subgroup of <G>,
##  `FusionConjugacyClasses' returns the fusion of conjugacy classes between
##  <H> and <G>.
##  This is done by delegating to the ordinary character tables of <H> and
##  <G>,
##  since class fusions are stored only for character tables and not for
##  groups.
##
##  Note that the returned class fusion refers to the ordering of conjugacy
##  classes in the character tables if the arguments are character tables
##  and to the ordering of conjugacy classes in the groups if the arguments
##  are groups (see~"ConjugacyClasses!for character tables").
##
##  Called with a group homomorphism <hom>,
##  `FusionConjugacyClasses' returns the fusion of conjugacy classes between
##  the preimage and the image of <hom>;
##  contrary to the two cases above,
##  also factor fusions can be handled by this variant.
##  If <hom> is the only argument then the class fusion refers to the
##  ordering of conjugacy classes in the groups.
##  If the character tables of preimage and image are given as <tbl1> and
##  <tbl2>, respectively (each table with its group stored),
##  then the fusion refers to the ordering of classes in these tables.
##
##  If no class fusion exists or if the class fusion is not uniquely
##  determined, `fail' is returned;
##  this may happen when `FusionConjugacyClasses' is called with two
##  character tables that do not know compatible underlying groups.
##
##  Methods for the computation of class fusions can be installed for
##  the operation `FusionConjugacyClassesOp'.
##
DeclareOperation( "FusionConjugacyClasses",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );
DeclareOperation( "FusionConjugacyClasses", [ IsGroup, IsGroup ] );
DeclareOperation( "FusionConjugacyClasses", [ IsGeneralMapping ] );
DeclareOperation( "FusionConjugacyClasses",
    [ IsGeneralMapping, IsNearlyCharacterTable, IsNearlyCharacterTable ] );

DeclareAttribute( "FusionConjugacyClassesOp", IsGeneralMapping );

DeclareOperation( "FusionConjugacyClassesOp",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );
DeclareOperation( "FusionConjugacyClassesOp",
    [ IsGeneralMapping, IsNearlyCharacterTable, IsNearlyCharacterTable ] );


#############################################################################
##
#A  ComputedClassFusions( <tbl> )
##
##  The class fusions from the character table <tbl> that have been computed
##  already by `FusionConjugacyClasses' (see~"FusionConjugacyClasses") or
##  explicitly stored by `StoreFusion' (see~"StoreFusion")
##  are stored in the `ComputedClassFusions' list of <tbl1>.
##  Each entry of this list is a record with the following components.
##  \beginitems
##  `name' &
##      the `Identifier' value of the character table to which the fusion
##      maps,
##
##  `map' &
##      the list of positions of image classes,
##
##  `text' (optional) &
##      a string giving additional information about the fusion map,
##      for example whether the map is uniquely determined by the character
##      tables,
##
##  `specification' (optional, rarely used) &
##      a value that distinguishes different fusions between the same tables.
##  \enditems
##
##  Note that stored fusion maps may differ from the maps returned by
##  `GetFusionMap' and the maps entered by `StoreFusion' if the table
##  <destination> has a nonidentity `ClassPermutation' value.
##  So if one fetches a fusion map from a table <tbl1> to a table <tbl2>
##  via access to the data in the `ComputedFusionMaps' list <tbl1> then the
##  stored value must be composed with the `ClassPermutation' value of <tbl2>
##  in order to obtain the correct class fusion.
##  (If one handles fusions only via `GetFusionMap' and `StoreFusion'
##  (see~"GetFusionMap", "StoreFusion") then this adjustment is made
##  automatically.)
##
##  Fusions are identified via the `Identifier' value of the destination
##  table and not by this table itself because many fusions between
##  character tables in the {\GAP} character table library are stored on
##  library tables, and it is not desirable to load together with a library
##  table also all those character tables that occur as destinations of
##  fusions from this table.
##
##  For storing fusions and accessing stored fusions,
##  see also~"GetFusionMap", "StoreFusion".
##  For accessing the identifiers of tables that store a fusion into a
##  given character table, see~"NamesOfFusionSources".
##
DeclareAttributeSuppCT( "ComputedClassFusions",
    IsNearlyCharacterTable, "mutable", [ "class" ] );


#############################################################################
##
#F  GetFusionMap( <source>, <destination> )
#F  GetFusionMap( <source>, <destination>, <specification> )
##
##  For two ordinary character tables <source> and <destination>,
##  `GetFusionMap' checks whether the `ComputedClassFusion' list of <source>
##  (see~"ComputedClassFusions") contains a record with `name' component
##  `Identifier( <destination> )', and returns returns the `map' component
##  of the first such record.
##  `GetFusionMap( <source>, <destination>, <specification> )' fetches
##  that fusion map for which the record additionally has the `specification'
##  component <specification>.
##
##  If both <source> and <destination> are Brauer tables,
##  first the same is done, and if no fusion map was found then
##  `GetFusionMap' looks whether a fusion map between the ordinary tables
##  is stored; if so then the fusion map between <source> and <destination>
##  is stored on <source>, and then returned.
##
##  If no appropriate fusion is found, `GetFusionMap' returns `fail'.
##  For the computation of class fusions, see~"FusionConjugacyClasses".
##
DeclareGlobalFunction( "GetFusionMap" );


#############################################################################
##
#F  StoreFusion( <source>, <fusion>, <destination> )
##
##  For two character tables <source> and <destination>,
##  `StoreFusion' stores the fusion <fusion> from <source> to <destination>
##  in the `ComputedClassFusions' list (see~"ComputedClassFusions")
##  of <source>,
##  and adds the `Identifier' string of <destination> to the
##  `NamesOfFusionSources' list (see~`NamesOfFusionSources')
##  of <destination>.
##
##  <fusion> can either be a fusion map (that is, the list of positions of
##  the image classes) or a record as described in~"ComputedClassFusions".
##
##  If fusions to <destination> are already stored on <source> then
##  another fusion can be stored only if it has a record component
##  `specification' that distinguishes it from the stored fusions.
##  In the case of such an ambiguity, `StoreFusion' raises an error.
##
DeclareGlobalFunction( "StoreFusion" );


#############################################################################
##
#A  NamesOfFusionSources( <tbl> )
##
##  For a character table <tbl>, `NamesOfFusionSources' returns the list of
##  identifiers of all those character tables that are known to have fusions
##  to <tbl> stored.
##  The `NamesOfFusionSources' value is updated whenever a fusion to <tbl>
##  is stored using `StoreFusion' (see~"StoreFusion").
##
DeclareAttributeSuppCT( "NamesOfFusionSources",
    IsNearlyCharacterTable, "mutable", [] );


#############################################################################
##
#O  PossibleClassFusions( <subtbl>, <tbl>[, <options>] )
##
##  For two ordinary character tables <subtbl> and <tbl> of the groups $H$
##  and $G$, say,
##  `PossibleClassFusions' returns the list of all maps that have the
##  following properties of class fusions from <subtbl> to <tbl>.
##  \beginlist
##  \item{1.}
##      For class $i$, the centralizer order of the image in $G$ is a
##      multiple of the $i$-th centralizer order in $H$,
##      and the element orders in the $i$-th class and its image are equal.
##      These criteria are checked in `InitFusion' (see~"InitFusion").
##  \item{2.}
##      The class fusion commutes with power maps.
##      This is checked using `TestConsistencyMaps'
##      (see~"TestConsistencyMaps").
##  \item{3.}
##      If the permutation character of $G$ corresponding to the action of
##      $G$ on the cosets of $H$ is specified (see the discussion of the
##      <options> argument below) then it prescribes for each class $C$ of
##      $G$ the number of elements of $H$ fusing into $C$.
##      The corresponding function is `CheckPermChar'
##      (see~"CheckPermChar").
##  \item{4.}
##      The table automorphisms of <tbl> (see~"AutomorphismsOfTable") are
##      used in order to compute only orbit representatives.
##      (But note that the list returned by `PossibleClassFusions' contains
##      the full orbits.)
##  \item{5.}
##      For each character $\chi$ of $G$, the restriction to $H$ via the
##      class fusion is a character of $H$.
##      This condition is checked for all characters specified below,
##      the corresponding function is `FusionsAllowedByRestrictions'
##      (see~"FusionsAllowedByRestrictions").
##  \endlist
##
##  If <subtbl> and <tbl> are Brauer tables then the possibilities are
##  computed from those for the underlying ordinary tables.
##
##  The optional argument <options> must be a record that may have the
##  following components:
##  \beginitems
##  `chars' &
##       a list of characters of <tbl> which are used for the check of~5.;
##       the default is `Irr( <tbl> )',
##
##  `subchars' &
##       a list of characters of <subtbl> which are constituents of the
##       retrictions of `chars', the default is `Irr( <subtbl> )',
##
##  `fusionmap' &
##       a parametrized map which is an approximation of the desired map,
##
##  `decompose' &
##       a boolean;
##       a `true' value indicates that all constituents of the restrictions
##       of `chars' computed for criterion 5. lie in `subchars',
##       so the restrictions can be decomposed into elements of `subchars';
##       the default value of `decompose' is `true' if `subchars' is not
##       bound and `Irr( <subtbl> )' is known, otherwise `false',
##
##  `permchar' &
##       (a values list of) a permutation character; only those fusions
##       affording that permutation character are computed,
##
##  `quick' &
##       a boolean;
##       if `true' then the subroutines are called with value `true' for
##       the argument <quick>;
##       especially, as soon as only one possibility remains
##       this possibility is returned immediately;
##       the default value is `false'
##
##  `parameters' &
##       a record with components `maxamb', `minamb' and `maxlen'
##       which control the subroutine `FusionsAllowedByRestrictions';
##       it only uses characters with current indeterminateness up to
##       `maxamb',
##       tests decomposability only for characters with current
##       indeterminateness at least `minamb',
##       and admits a branch according to a character only if there is one
##       with at most `maxlen' possible restrictions.
##  \enditems
##
DeclareOperation( "PossibleClassFusions",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );
DeclareOperation( "PossibleClassFusions",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable, IsRecord ] );


#############################################################################
##
#5
##  The permutation groups of table automorphisms
##  (see~"AutomorphismsOfTable")
##  of the subgroup table <subtbl> and the supergroup table <tbl> act on the
##  possible class fusions returned by `PossibleClassFusions'
##  (see~"PossibleClassFusions"),
##  the former by permuting a list via `Permuted' (see~"Permuted"),
##  the latter by mapping the images via `OnPoints' (see~"OnPoints").
##
##  If the set of possible fusions with certain properties was computed
##  that are not invariant under the full groups of table automorphisms
##  then only a smaller group acts.
##  This may happen for example if a permutation character or if an explicit
##  approximation of the fusion map is prescribed in the call of
##  `PossibleClassFusions'.
##


#############################################################################
##
#F  OrbitFusions( <subtblautomorphisms>, <fusionmap>, <tblautomorphisms> )
##
##  returns the orbit of the class fusion map <fusionmap> under the
##  actions of the permutation groups <subtblautomorphisms> and
##  <tblautomorphisms> of automorphisms of the character table of the
##  subgroup and the supergroup, respectively.
##
DeclareGlobalFunction( "OrbitFusions" );


#############################################################################
##
#F  RepresentativesFusions( <subtblautomorphisms>, <listofmaps>,
#F                          <tblautomorphisms> )
#F  RepresentativesFusions( <subtbl>, <listofmaps>, <tbl> )
##
##  returns a list of orbit representatives of class fusion maps in the list
##  <listofmaps> under the action of maximal admissible subgroups
##  of the table automorphisms <subtblautomorphisms> of the subgroup table
##  and <tblautomorphisms> of the supergroup table.
##  Both groups of table automorphisms must be permutation groups.
##
##  Instead of the groups of table automorphisms, also the character tables
##  <subtbl> and <tbl> may be entered.
##  In this case, the `AutomorphismsOfTable' values of the tables are used.
##
DeclareGlobalFunction( "RepresentativesFusions" );


#############################################################################
##
##  4. Utilities for Parametrized Maps
#6
##  A *parametrized map* is a list whose $i$-th entry is either unbound
##  (which means that nothing is known about the image(s) of the $i$-th
##  class) or the image of the $i$-th class
##  (i.e., an integer for fusion maps, power maps, element orders etc.,
##  and a cyclotomic for characters),
##  or a list of possible images of the $i$-th class.
##  In this sense, maps are special parametrized maps.
##  We often identify a parametrized map <paramap> with the set of all maps
##  <map> with the property that either `<map>[i] = <paramap>[i]' or
##  `<map>[i]' is contained in the list `<paramap>[i]';
##  we say then that <map> is contained in <paramap>.
##
##  This definition implies that parametrized maps cannot be used to describe
##  sets of maps where lists are possible images.
##  An exception are strings which naturally arise as images when class names
##  are considered.
##  So strings and lists of strings are allowed in parametrized maps,
##  and character constants (see Chapter~"Strings and Characters")
##  are not allowed in maps.
##


#############################################################################
##
#F  CompositionMaps( <paramap2>, <paramap1>[, <class>] )
##
##  The composition of two parametrized maps <paramap1>, <paramap2> is
##  defined as the parametrized map <comp> that contains
##  all compositions $f_2 \circ f_1$ of elements $f_1$ of <paramap1> and
##  $f_2$ of <paramap2>.
##  For example, the composition of a character $\chi$ of a group $G$ by a
##  parametrized class fusion map from a subgroup $H$ to $G$ is the
##  parametrized map that contains all restrictions of $\chi$ by elements of
##  the parametrized fusion map.
##
##  `CompositionMaps( <paramap2>, <paramap1> )' is a parametrized map with
##  entry `CompositionMaps( <paramap2>, <paramap1>, <class> )' at position
##  <class>.
##  If `<paramap1>[<class>]' is an integer then
##  `CompositionMaps( <paramap2>, <paramap1>, <class> )' is equal to
##  `<paramap2>[ <paramap1>[ <class> ] ]'.
##  Otherwise it is the union of `<paramap2>[i]' for `i' in
##  `<paramap1>[ <class> ]'.
##
DeclareGlobalFunction( "CompositionMaps" );


#############################################################################
##
#F  InverseMap( <paramap> ) . . . . . . . . . . inverse of a parametrized map
##
##  For a parametrized map <paramap>,
##  `InverseMap' returns a mutable parametrized map whose $i$-th entry is
##  unbound if $i$ is not in the image of <paramap>,
##  equal to $j$ if $i$ is (in) the image of `<paramap>[<j>]' exactly for
##  $j$, and equal to the set of all preimages of $i$ under <paramap>
##  otherwise.
##
##  We have `CompositionMaps( <paramap>, InverseMap( <paramap> ) )'
##  the identity map.
##
DeclareGlobalFunction( "InverseMap" );


#############################################################################
##
#F  ProjectionMap( <fusionmap> ) . . . .  projection corresp. to a fusion map
##
##  For a map <fusionmap>, `ProjectionMap' returns a parametrized map
##  whose $i$-th entry is unbound if $i$ is not in the image of <fusionmap>,
##  and equal to $j$ if $j$ is the smallest position such that $i$ is
##  the image of `<fusionmap>[<j>]'.
##
##  We have `CompositionMaps( <fusionmap>, ProjectionMap( <fusionmap> ) )'
##  the identity map, i.e., first projecting and then fusing yields the
##  identity.
##  Note that <fusionmap> must *not* be a parametrized map.
##
DeclareGlobalFunction( "ProjectionMap" );


#############################################################################
##
#F  Indirected( <character>, <paramap> )
##
##  For a map <character> and a parametrized map <paramap>, `Indirected'
##  returns a parametrized map whose entry at position $i$ is
##  `<character>[ <paramap>[<i>] ]' if `<paramap>[<i>]' is an integer,
##  and an unknown (see Chapter~"Unknowns") otherwise.
##
DeclareGlobalFunction( "Indirected" );


#############################################################################
##
#F  Parametrized( <list> )
##
##  For a list <list> of (parametrized) maps of the same length,
##  `Parametrized' returns the smallest parametrized map containing all
##  elements of <list>.
##
##  `Parametrized' is the inverse function to `ContainedMaps'
##  (see~"ContainedMaps").
##
DeclareGlobalFunction( "Parametrized" );


#############################################################################
##
#F  ContainedMaps( <paramap> )
##
##  For a parametrized map <paramap>, `ContainedMaps' returns the set of all
##  maps contained in <paramap>.
##
##  `ContainedMaps' is the inverse function to `Parametrized'
##  (see~"Parametrized") in the sense that
##  `Parametrized( ContainedMaps( <paramap> ) )' is equal to <paramap>.
##
DeclareGlobalFunction( "ContainedMaps" );


#############################################################################
##
#F  UpdateMap( <character>, <paramap>, <indirected> )
##
##  Let <character> be a map, <paramap> a parametrized map, and <indirected>
##  a parametrized map that is contained in
##  `CompositionMaps( <character>, <paramap> )'.
##
##  Then `UpdateMap' changes <paramap> to the parametrized map containing
##  exactly the maps whose composition with <character> is equal to
##  <indirected>.
##
##  If a contradiction is detected then `false' is returned immediately,
##  otherwise `true'.
##
DeclareGlobalFunction( "UpdateMap" );


#############################################################################
##
#F  MeetMaps( <paramap1>, <paramap2> )
##
##  For two parametrized maps <paramap1> and <paramap2>, `MeetMaps' changes
##  <paramap1> such that the image of class $i$ is the intersection of
##  `<paramap1>[<i>]' and `<paramap2>[<i>]'.
##
##  If this implies that no images remain for a class, the position of such a
##  class is returned.
##  If no such inconsistency occurs, `MeetMaps' returns `true'.
##
DeclareGlobalFunction( "MeetMaps" );


#############################################################################
##
#F  ImproveMaps( <map2>, <map1>, <composition>, <class> )
##
##  `ImproveMaps' is a utility for `CommutativeDiagram' and
##  `TestConsistencyMaps'.
##
##  <composition> must be a set that is known to be an upper bound for the
##  composition $( <map2> \circ <map1> )[ <class> ]$.
##  If $`<map1>[ <class> ]' = x$ is unique then $<map2>[ x ]$ must be a set,
##  it will be replaced by its intersection with <composition>;
##  if <map1>[ <class> ] is a set then all elements `x' with empty
##  `Intersection( <map2>[ x ], <composition> )' are excluded.
##
##  `ImproveMaps' returns
##  \beginlist
##  \item{0}
##      if no improvement was found,
##  \item{-1}
##      if <map1>[ <class> ] was improved,
##  \item{<x>}
##      if <map2>[ <x> ] was improved.
##  \endlist
##
DeclareGlobalFunction( "ImproveMaps" );


#############################################################################
##
#F  CommutativeDiagram( <paramap1>, <paramap2>, <paramap3>, <paramap4>[,
#F                      <improvements>] )
##
##  Let <paramap1>, <paramap2>, <paramap3>, <paramap4> be parametrized maps
##  covering parametrized maps $f_1$, $f_2$, $f_3$, $f_4$ with the property
##  that $`CompositionMaps'( f_2, f_1 )$ is equal to
##  $`CompositionMaps'( f_4, f_3 )$.
##
##  `CommutativeDiagram' checks this consistency, and changes the arguments
##  such that all possible images are removed that cannot occur in the
##  parametrized maps $f_i$.
##
##  The return value is `fail' if an inconsistency was found.
##  Otherwise a record with the components `imp1', `imp2', `imp3', `imp4'
##  is returned, each bound to the list of positions where the corresponding
##  parametrized map was changed,
##
##  The optional argument <improvements> must be a record with components
##  `imp1', `imp2', `imp3', `imp4'.
##  If such a record is specified then only diagrams are considered where
##  entries of the $i$-th component occur as preimages of the $i$-th
##  parametrized map.
##
##  When an inconsistency is deteted,
##  `CommutativeDiagram' immediately returns `fail'.
##  Otherwise a record is returned that contains four lists `imp1', $\ldots$,
##  `imp4':
##  `imp<i>' is the list of classes where <paramap_i> was changed.
##
DeclareGlobalFunction( "CommutativeDiagram" );


#############################################################################
##
#F  CheckFixedPoints( <inside1>, <between>, <inside2> )
##
##  Let <inside1>, <between>, <inside2> be parametrized maps,
##  where <between> is assumed to map each fixed point of <inside1>
##  (that is, `<inside1>[<i>] = <i>') to a fixed point of <inside2>
##  (that is, <between>[<i>] is either an integer that is fixed by <inside2>
##  or a list that has nonempty intersection with the union of its images
##  under <inside2>).
##  `CheckFixedPoints' changes <between> and <inside2> by removing all those
##  entries violate this condition.
##
##  When an inconsistency is detected,
##  `CheckFixedPoints' immediately returns `fail'.
##  Otherwise the list of positions is returned where changes occurred.
##
DeclareGlobalFunction( "CheckFixedPoints" );


#############################################################################
##
#F  TransferDiagram( <inside1>, <between>, <inside2>[, <improvements>] )
##
##  Let <inside1>, <between>, <inside2> be parametrized maps
##  covering parametrized maps $m_1$, $f$, $m_2$ with the property
##  that $`CompositionMaps'( m_2, f )$ is equal to
##  $`CompositionMaps'( f, m_1 )$.
##
##  `TransferDiagram' checks this consistency, and changes the arguments
##  such that all possible images are removed that cannot occur in the
##  parametrized maps $m_i$ and $f$.
##
##  So `TransferDiagram' is similar to `CommutativeDiagram'
##  (see~"CommutativeDiagram"),
##  but <between> occurs twice in each diagram checked.
##
##  If a record <improvements> with fields `impinside1', `impbetween' and
##  `impinside2' is specified, only those diagrams with elements of
##  `impinside1' as preimages of <inside1>, elements of `impbetween' as
##  preimages of <between> or elements of `impinside2' as preimages of
##  <inside2> are considered.
##
##  When an inconsistency is detected,
##  `TransferDiagram' immediately returns `fail'.
##  Otherwise a record is returned that contains three lists `impinside1',
##  `impbetween', and `impinside2' of positions where the arguments were
##  changed.
##
DeclareGlobalFunction( "TransferDiagram" );


#############################################################################
##
#F  TestConsistencyMaps( <powermap1>, <fusionmap>, <powermap2>[, <fus_imp>] )
##
##  Let <powermap1> and <powermap2> be lists of parametrized maps,
##  and <fusionmap> a parametrized map,
##  such that for each $i$, the $i$-th entry in <powermap1>, <fusionmap>,
##  and the $i$-th entry in <powermap2> (if bound) are valid arguments for
##  `TransferDiagram' (see~"TransferDiagram").
##  So a typical situation for applying `TestConsistencyMaps' is that
##  <fusionmap> is an approximation of a class fusion, and <powermap1>,
##  <powermap2> are the lists of power maps of the subgroup and the group.
##
##  `TestConsistencyMaps' repeatedly applies `TransferDiagram' to these
##  arguments for all $i$ until no more changes occur.
##
##  If a list <fus_imp> is specified then only those diagrams with
##  elements of <fus_imp> as preimages of <fusionmap> are considered.
##
##  When an inconsistency is detected,
##  `TestConsistencyMaps' immediately returns `false'.
##  Otherwise `true' is returned.
##
DeclareGlobalFunction( "TestConsistencyMaps" );


#############################################################################
##
#F  Indeterminateness( <paramap> ) . . . . the indeterminateness of a paramap
##
##  For a parametrized map <paramap>, `Indeterminateness' returns the number
##  of maps contained in <paramap>, that is, the product of lengths of lists
##  in <paramap> denoting lists of several images.
##
DeclareGlobalFunction( "Indeterminateness" );


#############################################################################
##
#F  IndeterminatenessInfo( <paramap> )
##
DeclareGlobalFunction( "IndeterminatenessInfo" );


#############################################################################
##
#F  PrintAmbiguity( <list>, <paramap> ) . . . .  ambiguity of characters with
##                                                       respect to a paramap
##
##  For each map in the list <list>, `PrintAmbiguity' prints its position in
##  <list>,
##  the indeterminateness (see~"Indeterminateness") of the composition with
##  the parametrized map <paramap>,
##  and the list of positions where a list of images occurs in this
##  composition.
##
DeclareGlobalFunction( "PrintAmbiguity" );


#############################################################################
##
#F  ContainedSpecialVectors( <tbl>, <chars>, <paracharacter>, <func> )
#F  IntScalarProducts( <tbl>, <chars>, <candidate> )
#F  NonnegIntScalarProducts( <tbl>, <chars>, <candidate> )
#F  ContainedPossibleVirtualCharacters( <tbl>, <chars>, <paracharacter> )
#F  ContainedPossibleCharacters( <tbl>, <chars>, <paracharacter> )
##
##  Let <tbl> be an ordinary character table,
##  <chars> a list of class functions (or values lists),
##  <paracharacter> a parametrized class function of <tbl>,
##  and <func> a function that expects the three arguments <tbl>, <chars>,
##  and a values list of a class function, and that returns either `true' or
##  `false'.
##
##  `ContainedSpecialVectors' returns
##  the list of all those elements <vec> of <paracharacter> that
##  have integral norm,
##  have integral scalar product with the principal character of <tbl>,
##  and that satisfy `<func>( <tbl>, <chars>, <vec> ) = true',
##
##  \indextt{IntScalarProducts}\indextt{NonnegIntScalarProducts}
##  \indextt{ContainedPossibleVirtualCharacters}
##  \indextt{ContainedPossibleCharacters}\indextt{ContainedSpecialVectors}
##  Two special cases of <func> are the check whether the scalar products in
##  <tbl> between the vector <vec> and all lists in <chars> are integers or
##  nonnegative integers, respectively.
##  These functions are accessible as global variables `IntScalarProducts'
##  and `NonnegIntScalarProducts',
##  and `ContainedPossibleVirtualCharacters' and
##  `ContainedPossibleCharacters' provide access to these special cases of
##  `ContainedSpecialVectors'.

DeclareGlobalFunction( "ContainedSpecialVectors" );
DeclareGlobalFunction( "IntScalarProducts" );
DeclareGlobalFunction( "NonnegIntScalarProducts" );
DeclareGlobalFunction( "ContainedPossibleVirtualCharacters" );
DeclareGlobalFunction( "ContainedPossibleCharacters" );


#############################################################################
##
#F  ContainedDecomposables( <constituents>, <moduls>, <parachar>, <func> )
#F  ContainedCharacters( <tbl>, <constituents>, <parachar> )
##
##  Let <constituents> be a list of *rational* class functions,
##  <moduls> a list of positive integers,
##  <parachar> a parametrized rational class function,
##  and <func> a function that returns either `true' or `false' when called
##  with (a values list of) a class function.
##
##  `ContainedDecomposables' returns the set of all elements $\chi$ of
##  <parachar> that satisfy $<func>( \chi ) = `true'$
##  and that lie in the $\Z$-lattice spanned by <constituents>,
##  modulo <moduls>.
##  The latter means they lie in the $\Z$-lattice spanned by <constituents>
##  and the set
##  $$
##  \{ <moduls>[i] . e_i; 1 \leq i \leq n \},
##  $$
##  where $n$ is the length of <parachar> and  $e_i$ is the $i$-th standard
##  basis vector.
##
##  One application of `ContainedDecomposables' is the following.
##  <constituents> is a list of (values lists of) rational characters of an
##  ordinary character table <tbl>,
##  <moduls> is the list of centralizer orders of <tbl>
##  (see~"SizesCentralizers"),
##  and <func> checks whether a vector in the lattice mentioned above has
##  nonnegative integral scalar product in <tbl> with all entries of
##  <constituents>.
##  This situation is handled by `ContainedCharacters'.
##  Note that the entries of the result list are *not* necessary linear
##  combinations of <constituents>,
##  and they are *not* necessarily characters of <tbl>.
##
DeclareGlobalFunction( "ContainedDecomposables" );
DeclareGlobalFunction( "ContainedCharacters" );


#############################################################################
##
##  5. Subroutines for the Construction of Power Maps
##


#############################################################################
##
#F  InitPowerMap( <tbl>, <prime> )
##
##  For an ordinary character table <tbl> and a prime <prime>,
##  `InitPowerMap' returns a parametrized map that is a first approximation
##  of the <prime>-th powermap of <tbl>,
##  using the conditions 1.~and 2.~listed in the description of
##  `PossiblePowerMaps' (see~"PossiblePowerMaps").
##
##  If there are classes for which no images are possible, according to these
##  criteria, then `fail' is returned.
##
DeclareGlobalFunction( "InitPowerMap" );


#############################################################################
##
#7
##  In the argument lists of the functions `Congruences', `ConsiderKernels',
##  and `ConsiderSmallerPowerMaps',
##  <tbl> is an ordinary character table,
##  <chars> a list of (values lists of) characters of <tbl>,
##  <prime> a prime integer,
##  <approxmap> a parametrized map that is an approximation for the
##  <prime>-th power map of <tbl>
##  (e.g., a list returned by `InitPowerMap', see~"InitPowerMap"),
##  and <quick> a boolean.
##
##  The <quick> value `true' means that only those classes are considered
##  for which <approxmap> lists more than one possible image.
##


#############################################################################
##
#F  Congruences( <tbl>, <chars>, <approxmap>, <prime>, <quick> )
##
##  `Congruences' replaces the entries of <approxmap> by improved values,
##  according to condition 3.~listed in the description of
##  `PossiblePowerMaps' (see~"PossiblePowerMaps").
##
##  For each class for which no images are possible according to the tests,
##  the new value of <approxmap> is an empty list.
##  `Congruences' returns `true' if no such inconsistencies occur,
##  and `false' otherwise.
##
DeclareGlobalFunction( "Congruences" );


#############################################################################
##
#F  ConsiderKernels( <tbl>, <chars>, <approxmap>, <prime>, <quick> )
##
##  `ConsiderKernels' replaces the entries of <approxmap> by improved values,
##  according to condition 4.~listed in the description of
##  `PossiblePowerMaps' (see~"PossiblePowerMaps").
##
##  `Congruences' returns `true' if the orders of the kernels of all
##  characters in <chars> divide the order of the group of <tbl>,
##  and `false' otherwise.
##
DeclareGlobalFunction( "ConsiderKernels" );


#############################################################################
##
#F  ConsiderSmallerPowerMaps( <tbl>, <approxmap>, <prime>, <quick> )
##
##  `ConsiderSmallerPowerMaps' replaces the entries of <approxmap>
##  by improved values,
##  according to condition 5.~listed in the description of
##  `PossiblePowerMaps' (see~"PossiblePowerMaps").
##
##  `ConsiderSmallerPowerMaps' returns `true' if each class admits at least
##  one image after the checks, otherwise `false' is returned.
##  If no element orders of <tbl> are stored
##  (see~"OrdersClassRepresentatives") then `true' is returned without any
##  tests.
##
DeclareGlobalFunction( "ConsiderSmallerPowerMaps" );


#############################################################################
##
#F  MinusCharacter( <character>, <prime_powermap>, <prime> )
##
##  Let <character> be (the list of values of) a class function $\chi$,
##  <prime> a prime integer $p$, and <prime_powermap> a parametrized map
##  that is an approximation of the $p$-th power map for the character table
##  of $\chi$.
##  `MinusCharacter' returns the parametrized map of values of $\chi^{p-}$,
##  which is defined by $\chi^{p-}(g) = ( \chi(g)^p - \chi(g^p) ) / p$.
##
DeclareGlobalFunction( "MinusCharacter" );


#############################################################################
##
#F  PowerMapsAllowedBySymmetrizations( <tbl>, <subchars>, <chars>,
#F                                     <approxmap>, <prime>, <parameters> )
##
##  Let <tbl> be an ordinary character table,
##  <prime> a prime integer,
##  <approxmap> a parametrized map that is an approximation of the <prime>-th
##  power map of <tbl>
##  (e.g., a list returned by `InitPowerMap', see~"InitPowerMap"),
##  <chars> and <subchars> two lists of (values lists of) characters of
##  <tbl>,
##  and <parameters> a record with components
##  `maxlen', `minamb', `maxamb' (three integers),
##  `quick' (a boolean),
##  and `contained' (a function).
##  Usual values of `contained' are `ContainedCharacters' or
##  `ContainedPossibleCharacters'.
##
##  `PowerMapsAllowedBySymmetrizations' replaces the entries of <approxmap>
##  by improved values,
##  according to condition 6.~listed in the description of
##  `PossiblePowerMaps' (see~"PossiblePowerMaps").
##
##  More precisely, the strategy used is as follows.
##
##  First, for each $\chi \in <chars>$,
##  let `minus:= MinusCharacter( $\chi$, <approxmap>, <prime> )'.
##  \beginlist
##  \item{-}
##      If $`Indeterminateness( minus )' = 1$ and
##      `<parameters>.quick = false' then the scalar products of `minus' with
##      <subchars> are checked;
##      if not all scalar products are nonnegative integers then
##      an empty list is returned,
##      otherwise $\chi$ is deleted from the list of characters to inspect.
##  \item{-}
##      Otherwise if `Indeterminateness( minus )' is smaller than
##      `<parameters>.minamb' then $\chi$ is deleted from the list of
##      characters.
##  \item{-}
##      If `<parameters>.minamb' $\leq$ `Indeterminateness( minus )' $\leq$
##      `<parameters>.maxamb' then
##      construct the list of contained class functions
##      `poss:= <parameters>.contained( <tbl>, <subchars>, minus )'
##      and `Parametrized( poss )',
##      and improve the approximation of the power map using `UpdateMap'.
##  \endlist
##
##  If this yields no further immediate improvements then we branch.
##  If there is a character from <chars> left with less or equal
##  `<parameters>.maxlen' possible symmetrizations,
##  compute the union of power maps allowed by these possibilities.
##  Otherwise we choose a class $C$ such that the possible symmetrizations of
##  a character in <chars> differ at $C$,
##  and compute recursively the union of all allowed power maps with image
##  at $C$ fixed in the set given by the current approximation of the power
##  map.
##
DeclareGlobalFunction( "PowerMapsAllowedBySymmetrizations" );
DeclareSynonym( "PowerMapsAllowedBySymmetrisations",
    PowerMapsAllowedBySymmetrizations );


#############################################################################
##
##  6. Subroutines for the Construction of Class Fusions
##


#############################################################################
##
#F  InitFusion( <subtbl>, <tbl> )
##
##  For two ordinary character tables <subtbl> and <tbl>,
##  `InitFusion' returns a parametrized map that is a first approximation
##  of the class fusion from <subtbl> to <tbl>,
##  using condition~1.~listed in the description of `PossibleClassFusions'
##  (see~"PossibleClassFusions").
##
##  If there are classes for which no images are possible, according to this
##  criterion, then `fail' is returned.
##
DeclareGlobalFunction( "InitFusion" );


#############################################################################
##
#F  CheckPermChar( <subtbl>, <tbl>, <approxmap>, <permchar> )
##
##  `CheckPermChar' replaces the entries of the parametrized map <approxmap>
##  by improved values,
##  according to condition~3.~listed in the description of
##  `PossibleClassFusions' (see~"PossibleClassFusions").
##
##  `CheckPermChar' returns `true' if no inconsistency occurred, and `false'
##  otherwise.
##
DeclareGlobalFunction( "CheckPermChar" );


#############################################################################
##
#F  ConsiderTableAutomorphisms( <approxmap>, <grp> )
##
##  `ConsiderTableAutomorphisms' replaces the entries of the parametrized map
##  <approxmap> by improved values, according to condition~4.~listed in the
##  description of `PossibleClassFusions' (see~"PossibleClassFusions").
##
##  Afterwards exactly one representative of fusion maps (contained in
##  <approxmap>) in each orbit under the action of the permutation group
##  <grp> is contained in the modified parametrized map.
##
##  `ConsiderTableAutomorphisms' returns the list of positions where
##  <approxmap> was changed.
##
DeclareGlobalFunction( "ConsiderTableAutomorphisms" );


#############################################################################
##
#F  FusionsAllowedByRestrictions( <subtbl>, <tbl>, <subchars>, <chars>,
#F                                <approxmap>, <parameters> )
##
##  Let <subtbl> and <tbl> be ordinary character tables,
##  <subchars> and <chars> two lists of (values lists of) characters of
##  <subtbl> and <tbl>, respectively,
##  <approxmap> a parametrized map that is an approximation of the class
##  fusion of <subtbl> in <tbl>,
##  and <parameters> a record with components
##  `maxlen', `minamb', `maxamb' (three integers),
##  <quick> (a boolean),
##  and `contained' (a function).
##  Usual values of `contained' are `ContainedCharacters' or
##  `ContainedPossibleCharacters'.
##
##  `FusionsAllowedByResrictions' replaces the entries of <approxmap>
##  by improved values,
##  according to condition 5.~listed in the description of
##  `PossibleClassFusions' (see~"PossibleClassFusions").
##
##  More precisely, the strategy used is as follows.
##
##  First, for each $\chi \in <chars>$,
##  let `restricted:= CompositionMaps( $\chi$, <approxmap> )'.
##  \beginlist
##  \item{-}
##      If $`Indeterminateness( restricted )' = 1$ and
##      `<parameters>.quick = false' then the scalar products of `restricted'
##      with <subchars> are checked;
##      if not all scalar products are nonnegative integers then
##      an empty list is returned,
##      otherwise $\chi$ is deleted from the list of characters to inspect.
##  \item{-}
##      Otherwise if `Indeterminateness( minus )' is smaller than
##      `<parameters>.minamb' then $\chi$ is deleted from the list of
##      characters.
##  \item{-}
##      If `<parameters>.minamb' $\leq$ `Indeterminateness( restricted )'
##      $\leq$ `<parameters>.maxamb' then construct
##      `poss:= <parameters>.contained( <subtbl>, <subchars>, restricted )'
##      and `Parametrized( poss )',
##      and improve the approximation of the fusion map using `UpdateMap'.
##  \endlist
#T Would it help to exploit that the restriction of a *linear* character
#T is again a linear character (not only a linear combination of linear
#T characters?
#T Branching in these cases would yield a short list of possibilities,
#T so it should be recommended ...
##
##  If this yields no further immediate improvements then we branch.
##  If there is a character from <chars> left with less or equal
##  `<parameters>.maxlen' possible restrictions,
##  compute the union of fusion maps allowed by these possibilities.
##  Otherwise we choose a class $C$ such that the possible restrictions of a
##  character in <chars> differ at $C$,
##  and compute recursively the union of all allowed fusion maps with image
##  at $C$ fixed in the set given by the current approximation of the fusion
##  map.
##
DeclareGlobalFunction( "FusionsAllowedByRestrictions" );


#############################################################################
##
#E

