#############################################################################
##
#W  grpfp.gd                    GAP library                    Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##
Revision.grpfp_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  CosetTableDefaultLimit
##
##  is the default number of cosets with which any coset table is
##  initialized before doing a coset enumeration.
##
##  The function performing this coset enumeration will automatically extend
##  the table whenever necessary (as long as the number of cosets does not
##  exceed the value of `CosetTableDefaultMaxLimit'), but this is an
##  expensive operation. Thus, if you change the value of
##  `CosetTableDefaultLimit', you should set it to a number of cosets
##  that you expect to be sufficient for your subsequent coset enumerations.
##  On the other hand, if you make it too large, your job will unnecessarily
##  waste a lot of space.
##
##  The default value of `CosetTableDefaultLimit' is 1000.
##
CosetTableDefaultLimit := 1000;


#############################################################################
##
#V  CosetTableDefaultMaxLimit
##
##  is the default limit for the number of cosets allowed in a coset
##  enumeration.
##
##  A coset enumeration will not finish if the subgroup does not have finite
##  index, and even if it has it may take many more intermediate cosets than
##  the actual index of the subgroup is. To avoid a coset enumeration
##  ``running away'' therefore {\GAP} has a ``safety stop'' built in. This
##  is controlled by the global variable `CosetTableDefaultMaxLimit'.
##
##  If this number of cosets is reached, {\GAP} will issue an error message
##  and prompt the user to either continue the calculation or to stop it.
##  The default value is 256000.
##
##  See also the description of the options to `CosetTableFromGensAndRels'.
##
CosetTableDefaultMaxLimit := 256000;


#############################################################################
##
#V  CosetTableStandard
##
##  specifies the definiton of a *standard coset table*. It is used
##  whenever coset tables or augmented coset tables are created. Its value
##  may be `"lenlex"' or `"semilenlex"'. If it is `"lenlex"' coset tables
##  will be standardized using all their columns as defined in Charles Sims'
##  book (this is the new default standard of {\GAP}). If it is `"semilenlex"'
##  they will be standardized using only their generator columns (this was
##  the original {\GAP} standard). The default value of `CosetTableStandard' is
##  `"lenlex"'.
##
CosetTableStandard := "lenlex";


#############################################################################
##
#V  InfoFpGroup
##
##  The info class for functions dealing with finitely presented groups is
##  `InfoFpGroup'.
DeclareInfoClass( "InfoFpGroup" );


#############################################################################
##
#C  IsSubgroupFgGroup( <H> )
##
##  This category (intended for future extensions) represents (subgroups of)
##  a finitely generated group, whose elements are represented as words in
##  the generators. However we do not necessarily have a set or relators.
##
DeclareCategory( "IsSubgroupFgGroup", IsGroup );

#############################################################################
##
#C  IsSubgroupFpGroup( <H> )
##
##  returns `true' if <H> is a finitely presented group or a subgroup of a
##  finitely presented group.
##
DeclareCategory( "IsSubgroupFpGroup", IsSubgroupFgGroup );

# implications for the full family
InstallTrueMethod(CanEasilyTestMembership, IsSubgroupFgGroup and IsWholeFamily);

#############################################################################
##
#F  IsFpGroup(<G>)
##
##  is a synonym for `IsSubgroupFpGroup(<G>)' and `IsGroupOfFamily(<G>)'.
##
DeclareSynonym( "IsFpGroup", IsSubgroupFpGroup and IsGroupOfFamily );

#############################################################################
##
#C  IsElementOfFpGroup
##
DeclareCategory( "IsElementOfFpGroup",
    IsMultiplicativeElementWithInverse and IsAssociativeElement );

#############################################################################
##
#C  IsElementOfFpGroupCollection
##
DeclareCategoryCollections( "IsElementOfFpGroup" );


#############################################################################
##
#m  IsSubgroupFpGroup
##
InstallTrueMethod(IsSubgroupFpGroup,IsGroup and IsElementOfFpGroupCollection);

##  free groups also are to be fp
InstallTrueMethod(IsSubgroupFpGroup,IsGroup and IsAssocWordCollection);


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <fpelmscoll> )
##
InstallTrueMethod( IsGeneratorsOfMagmaWithInverses,
    IsElementOfFpGroupCollection );


#############################################################################
##
#C  IsElementOfFpGroupFamily
##
DeclareCategoryFamily( "IsElementOfFpGroup" );


#############################################################################
##
#A  FpElmEqualityMethod(<fam>)
##
##  If <fam> is the elements family of a finitely presented group this
##  attribute returns a function `equal(<left>, <right>)' that will be
##  used to compare elements in <fam>.
##
DeclareAttribute( "FpElmEqualityMethod",IsElementOfFpGroupFamily);

#############################################################################
##
#A  FpElmComparisonMethod(<fam>)
##
##  If <fam> is the elements family of a finitely presented group this
##  attribute returns a function `smaller(<left>, <right>)' that will be
##  used to compare elements in <fam>.
##
DeclareAttribute( "FpElmComparisonMethod",IsElementOfFpGroupFamily);

#############################################################################
##
#F  SetReducedMultiplication(<f>)
#F  SetReducedMultiplication(<e>)
#F  SetReducedMultiplication(<fam>)
##
##  for an fp group <f>, an element <e> of it or the family <fam> of its
##  elements
##  this function will force immediate reduction when multiplying, keeping
##  words short at extra cost per multiplication.
##
DeclareGlobalFunction("SetReducedMultiplication");

#############################################################################
##
#A  FpElmKBRWS(<fam>)
##
##  If <fam> is the elements family of a finitely presented group this
##  attribute returns a list [<iso>,<k>,<id>] where <iso> is a isomorphism to an
##  fp monoid, <k> a confluent rewriting system for the image of <iso> and
##  <id> the element in the free monoid corresponding to the image of the
##  identity element under <iso>.
##
DeclareAttribute( "FpElmKBRWS",IsElementOfFpGroupFamily);


#############################################################################
##
#O  ElementOfFpGroup( <fam>, <word> )
##
##  If <fam> is the elements family of a finitely presented group and <word>
##  is a word in the free generators underlying this finitely presented
##  group, this operation creates the element with the representative <word>
##  in the free group.
##
DeclareOperation( "ElementOfFpGroup",
    [ IsElementOfFpGroupFamily, IsAssocWordWithInverse ] );


#############################################################################
##
#V  TCENUM
#V  GAPTCENUM
##
##  TCENUM is a global record variable whose components contain functions
##  used for coset enumeration. By default `TCENUM' is assigned to
##  `GAPTCENUM', which contains the coset enumeration functions provided by
##  the GAP library.
BindGlobal("GAPTCENUM",rec(name:="GAP Felsch-type enumerator"));
TCENUM:=GAPTCENUM;

#############################################################################
##
#F  CosetTableFromGensAndRels( <fgens>, <grels>, <fsgens> )
##
##  is an internal function which is called by the functions `CosetTable',
##  `CosetTableInWholeGroup' and others. It is, in fact, the proper working
##  horse that performs a Todd-Coxeter coset
##  enumeration. <fgens> must be a set of free generators and <grels> a set
##  of relators in these generators. <fsgens> are subgroup generators
##  expressed as words in these generators. The function returns a coset
##  table with respect to <fgens>.
##
##  `CosetTableFromGensAndRels' will call
##  `TCENUM.CosetTableFromGensAndRels'. This makes it possible to replace
##  the built-in coset enumerator with another one by assigning `TCENUM' to
##  another record.
## 
##  The library version which is used by default performs a standard Felsch
##  strategy coset enumeration. You can call this function explicitly as
##  `GAPTCENUM.CosetTableFromGensAndRels' even if other coset enumerators
##  are installed.
##
##  The expected parameters are
##  \beginitems
##    <fgens>  & generators of the free group <F>
##
##    <grels>  & relators as words in <F>
##
##    <fsgens> & subgroup generators as words in <F>.
##  \enditems
##
##  `CosetTableFromGensAndRels' processes two options (see
##  chapter~"Options Stack"): 
##  \beginitems
##    `max' & The limit of the number of cosets to be defined. If the
##    enumeration does not finish with this number of cosets, an error is
##    raised and the user is asked whether she wants to continue. The
##    default value is the value given in the variable
##    `CosetTableDefaultMaxLimit'. (Due to the algorithm the actual
##    limit used can be a bit higher than the number given.)
##
##    `silent'  & if set to `true' the algorithm will not raise the error
##    mentioned under option `max' but silently return `fail'. This can be
##    useful if an enumeration is only wanted unless it becomes too big.
##  \enditems
DeclareGlobalFunction("CosetTableFromGensAndRels");

#############################################################################
##
#F  IndexCosetTab( <table> )
##
##  this function returns `Length(table[1])', but the table might be empty
##  for a no-generator group, in which case 1 is returned.
DeclareGlobalFunction("IndexCosetTab");

#############################################################################
##
#F  StandardizeTable( <table>, <standard> )
##
##  standardizes the given coset table <table>. The second argument is
##  optional. It defines the standard to be used, its values may be
##  `"lenlex"' or `"semilenlex"' specifying the new or the old convention,
##  respectively. If no value for the parameter <standard> is provided the
##  function will use the global variable `CosetTableStandard' instead. Note
##  that the function alters the given table, it does not create a copy.
##
DeclareGlobalFunction("StandardizeTable");

#############################################################################
##
#F  StandardizeTable2( <table>, <table2>, <standard> )
##
##  standardizes the augmented coset table given by <table> and <table2>.
##  The third argument is optional. It defines the standard to be used, its
##  values may be `"lenlex"' or `"semilenlex"' specifying the new or the old
##  convention, respectively. If no value for the parameter <standard> is
##  provided the function will use the global variable `CosetTableStandard'
##  instead. Note that the function alters the given table, it does not
##  create a copy.
##
##  Warning: The function alters just the two tables. Any further lists
##  involved in the object *augmented coset table* which refer to these two
##  tables will not be updated.
##
DeclareGlobalFunction("StandardizeTable2");


#############################################################################
##
#A  CosetTableInWholeGroup(< H >)
#O  TryCosetTableInWholeGroup(< H >)
##
##  is equivalent to `CosetTable(<G>,<H>)' where <G> is the (unique) 
##  finitely presented group such that <H> is a subgroup of <G>. It
##  overrides a `silent' option (see~"CosetTableFromGensAndRels") with
##  `false'.
##
##  The variant `TryCosetTableInWholeGroup' does not override the `silent'
##  option with `false'  in case a coset table is only wanted if not too
##  expensive. It will store a result that is not `fail' in the attribute
##  `CosetTableInWholeGroup'.
##
DeclareAttribute( "CosetTableInWholeGroup", IsGroup );
DeclareOperation( "TryCosetTableInWholeGroup", [IsGroup] );

InstallTrueMethod(CanEasilyTestMembership, 
  IsSubgroupFpGroup and HasCosetTableInWholeGroup);


#############################################################################
##
#A  CosetTableNormalClosureInWholeGroup(< H >)
##
##  is equivalent to `CosetTableNormalClosure(<G>,<H>)' where <G> is the
##  (unique) finitely presented group such that <H> is a subgroup of <G>.
##  It overrides a `silent' option (see~"CosetTableFromGensAndRels") with
##  `false'.
##
DeclareAttribute( "CosetTableNormalClosureInWholeGroup", IsGroup );


#############################################################################
##
#F  TracedCosetFpGroup(<tab>,<word>,<pt>)
##
##  Traces the coset number <pt> under the word <word> through the coset
##  table <tab>. (Note: <word> must be in the free group, use
##  `UnderlyingElement' if in doubt.)
##
DeclareGlobalFunction("TracedCosetFpGroup");

#############################################################################
##
#F  SubgroupOfWholeGroupByCosetTable(<fpfam>,<tab>)
##
##  takes a family of an fp group and a coset table <tab> and returns
##  the subgroup of fam!.wholeGroup defined by this coset table.
##
DeclareGlobalFunction("SubgroupOfWholeGroupByCosetTable");


#############################################################################
##
#F  SubgroupOfWholeGroupByQuotientSubgroup(<fpfam>,<Q>,<U>)
##
##  takes a fp group family <fpfam>, a finitely generated group <Q> such that
##  the fp generators of <fam> can be mapped by an epimorphism <phi> onto
##  `GeneratorsOfGroup(<Q>)' and a subgroup <U> of <Q>.
##  It returns the subgroup of `<fam>!.wholeGroup' which is the full
##  preimage of <U> under <phi>.
DeclareGlobalFunction("SubgroupOfWholeGroupByQuotientSubgroup");

#############################################################################
##
#R  IsSubgroupOfWholeGroupByQuotientRep(<G>)
##
##  is the representation for subgroups of an fp group, given by a quotient
##  subgroup. The components `<G>!.quot' and `<G>!.sub' hold quotient,
##  respectively subgroup.
DeclareRepresentation("IsSubgroupOfWholeGroupByQuotientRep",
  IsSubgroupFpGroup,["quot","sub"]);

#############################################################################
##
#F  DefiningQuotientHomomorphism(<U>)
##
##  if <U> is a subgroup in quotient representation
##  (`IsSubgroupOfWholeGroupByQuotientRep'), this function returns the
##  defining homomorphism from the whole group to `<U>!.quot'.
DeclareGlobalFunction("DefiningQuotientHomomorphism");

#############################################################################
##
#A  AsSubgroupOfWholeGroupByQuotient(<U>)
##
##  returns the same subgroup in the representation
##  `AsSubgroupOfWholeGroupByQuotient'.
DeclareAttribute("AsSubgroupOfWholeGroupByQuotient", IsSubgroupFpGroup);


############################################################################
##
#O  LowIndexSubgroupsFpGroupIterator( <G>[, <H>], <index>[, <excluded>] )
#O  LowIndexSubgroupsFpGroup( <G>[, <H>], <index>[, <excluded>] )
##
##  These functions compute representatives of the conjugacy classes of
##  subgroups of the finitely presented group <G> that contain the subgroup
##  <H> of <G> and that have index less than or equal to <index>.
##
##  `LowIndexSubgroupsFpGroupIterator' returns an iterator (see~"Iterators")
##  that can be used to run over these subgroups,
##  and `LowIndexSubgroupsFpGroup' returns the list of these subgroups.
##  If one is interested only in one or a few subgroups up to a given index
##  then preferably the iterator should be used.
##
##  If the optional argument <excluded> has been specified, then it is
##  expected to be a list of words in the free generators of the underlying
##  free group of <G>, and `LowIndexSubgroupsFpGroup' returns only those
##  subgroups of index at most <index> that contain <H>, but do not contain
##  any conjugate of any of the group elements defined by these words.
##
##  If not given, <H> defaults to the trivial subgroup.
##
##  The algorithm used finds the requested subgroups
##  by systematically running through a tree of all potential coset tables
##  of <G> of length at most <index> (where it skips all branches of that
##  tree for which it knows in advance that they cannot provide new classes
##  of such subgroups). The time required to do this depends, of course, on
##  the presentation of <G>, but in general it will grow exponentially with
##  the value of <index>. So you should be careful with the choice of
##  <index>.
##
DeclareOperation( "LowIndexSubgroupsFpGroupIterator",
    [ IsSubgroupFpGroup, IsPosInt ] );
DeclareOperation( "LowIndexSubgroupsFpGroupIterator",
    [ IsSubgroupFpGroup, IsSubgroupFpGroup, IsPosInt ] );
DeclareOperation( "LowIndexSubgroupsFpGroupIterator",
    [ IsSubgroupFpGroup and IsWholeFamily, IsPosInt, IsList ] );
DeclareOperation( "LowIndexSubgroupsFpGroupIterator",
    [ IsSubgroupFpGroup and IsWholeFamily, IsSubgroupFpGroup, IsPosInt,
      IsList ] );

DeclareOperation("LowIndexSubgroupsFpGroup",
  [IsSubgroupFpGroup,IsSubgroupFpGroup,IsPosInt]);


############################################################################
##
#F  MostFrequentGeneratorFpGroup( <G> )
##
##  is an internal function which is used in some applications of coset
##  table methods. It returns the first of those generators of the given
##  finitely presented group <G> which occur most frequently in the
##  relators.
##
DeclareGlobalFunction("MostFrequentGeneratorFpGroup");


#############################################################################
##
#A  FreeGeneratorsOfFpGroup( <G> )
#O  FreeGeneratorsOfWholeGroup( <U> )
##
##  `FreeGeneratorsOfFpGroup' returns the underlying free generators
##  corresponding to the generators of the finitely presented group <G>
##  which must be a full fp group.
##
##  `FreeGeneratorsOfWholeGroup' also works for subgroups of an fp group and
##  returns the free generators of the full group that defines the family.
DeclareAttribute( "FreeGeneratorsOfFpGroup",
     IsSubgroupFpGroup and IsGroupOfFamily  );
DeclareOperation( "FreeGeneratorsOfWholeGroup",
     [IsSubgroupFpGroup]  );

############################################################################
##
#A  RelatorsOfFpGroup(<G>)
##
##  returns the relators of the finitely presented group <G> as words in the
##  free generators provided by `FreeGeneratorsOfFpGroup(<G>)'.
##
DeclareAttribute("RelatorsOfFpGroup",IsSubgroupFpGroup and IsGroupOfFamily);

#############################################################################
##
#A  FreeGroupOfFpGroup(<G>)
##
##  returns the underlying free group for the finitely presented group <G>.
##  This is the group generated by the free generators provided by
##  `FreeGeneratorsOfFpGroup(<G>)'.
##
DeclareAttribute("FreeGroupOfFpGroup",IsSubgroupFpGroup and IsGroupOfFamily);

#############################################################################
##
#A  IndicesInvolutaryGenerators( <G> )
##
##  returns the indices of those generators of the finitely presented group
##  <G> which are known to be involutions. This knowledge is used by
##  internal functions to improve the performance of coset enumerations.
##
DeclareAttribute("IndicesInvolutaryGenerators",
  IsSubgroupFpGroup and IsGroupOfFamily);

############################################################################
##
#F  RelatorRepresentatives(<rels>)
##
##  returns a set of  relators,  that  contains for each relator in the list
##  <rels> its minimal cyclical  permutation (which is automatically
##  cyclically reduced).
DeclareGlobalFunction("RelatorRepresentatives");


#############################################################################
##
#F  RelsSortedByStartGen( <gens>, <rels>, <table> )
##
##  is a  subroutine of the  Felsch Todd-Coxeter and the  Reduced
##  Reidemeister-Schreier  routines. It returns a list which for each
##  generator or  inverse generator in <gens> contains a list  of all
##  cyclically reduced relators,  starting  with that element,  which can be
##  obtained by conjugating or inverting the given relators <rels>.  The
##  relators are represented as lists of the coset table columns from the
##  table <table> corresponding to the generators and, in addition, as lists
##  of the respective column numbers.
##
DeclareGlobalFunction("RelsSortedByStartGen");

#############################################################################
##
#A  IsomorphismPermGroupOrFailFpGroup( <G> [,<max>] )
##
##  returns an isomorphism $\varphi$ from the fp group <G> onto
##  a permutation group <P> which is isomorphic to <G>, if one can be found
##  with reasonable effort and of reasonable degree. The function
##  returns `fail' otherwise.
##
##  The optional argument `max' can be used to override the default maximal
##  size of a coset table used (and thus the maximal degree of the resulting
##  permutation).
##
DeclareGlobalFunction("IsomorphismPermGroupOrFailFpGroup");


#############################################################################
##
#F  SubgroupGeneratorsCosetTable(<freegens>,<fprels>,<table>)
##
##  determinates subgroup generators for the subgroup given by the coset
##  table <table> from the free generators <freegens>,
##  the  relators <fprels> (as words in <freegens>).
##  It returns words in <freegens>.
##
DeclareGlobalFunction( "SubgroupGeneratorsCosetTable" );

#############################################################################
##
#F  FactorGroupFpGroupByRels( <G>, <elts> )
##
##  returns the factor group <G>/<N> of <G> by the normal closure N of
##  <elts> where <elts> is expected to be a list of elements of <G>.
DeclareGlobalFunction( "FactorGroupFpGroupByRels" );


#############################################################################
##
#F  ExcludedOrders( <fpgrp>[,<ords>] )
#A  StoredExcludedOrders( <fpgrp> )
##
##  for a (full) finitely presented group <fpgrp> this attribute returns
##  a list of orders, corresponding to `GeneratorsOfGroup', for which the
##  presentation collapes. (That is, the group becomes trivial when a
##  relator $g_i^o$ is added.) If given, the list <ords> contains a set of
##  orders corresponding to the generators which are explicitly to be
##  tested. (The mutable attribute `StoredExcludedOrders' is used to store
##  results.)
##  
DeclareGlobalFunction("ExcludedOrders");
DeclareAttribute( "StoredExcludedOrders",IsSubgroupFpGroup,"mutable");

#############################################################################
##
#F  NewmanInfinityCriterion(<G>,<p>)
##
##  Let <G> be a finitely presented group and <p> a prime that divides the
##  order of $<G>/<G>'$. This function applies an infinity
##  criterion due to M.F.~Newman \cite{New90} to <G>. (See chapter~16 
##  of~\cite{Joh97} for a more explicit description.)
##  It returns `true'
##  if the criterion succeeds in proving that <G> is infinite and `fail'
##  otherwise.
##  
##  Note that the criterion uses the number of generators and
##  relations in the presentation of <G>. Reduction of the persentation via
##  Tietze transformations (`IsomorphismSimplifiedFpGroup') therefore might
##  produce an isomorphic group, for which the criterion will work better.
##
DeclareGlobalFunction("NewmanInfinityCriterion");

#############################################################################
##
#F  FibonacciGroup(<r>,<n>)
#F  FibonacciGroup(<n>)
##
##  This function returns the *Fibonacci group* with parameters <r>, <n>.
##  This is a finitely presented group with <n> generators $x_i$ and <n>
##  relators $x_i\cdot\cdots\cdot x_{r+i-1}/x_{r+i}$ (with indices reduced
##  modulo <n>).
##
##  If <r> is ommitted, it defaults to 2.
DeclareGlobalFunction("FibonacciGroup");

#############################################################################
##
#E

