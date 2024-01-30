#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Götz Pfeiffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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


#T when are two character tables equal? -> same identifier & same permutation?)


#############################################################################
##
#T  TODO:
##
#T  (about incomplete tables!)
#T
#T  For character tables that do *not* store an underlying group,
#T  there is no notion of generation, contrary to all &GAP; domains.
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
##
##  <#GAPDoc Label="[1]{ctbl}">
##  It seems to be necessary to state some basic facts
##  &ndash;and maybe warnings&ndash;
##  at the beginning of the character theory package.
##  This holds for people who are familiar with character theory because
##  there is no global reference on computational character theory,
##  although there are many papers on this topic,
##  such as&nbsp;<Cite Key="NPP84"/> or&nbsp;<Cite Key="LP91"/>.
##  It holds, however, also for people who are familiar with &GAP; because
##  the general concept of domains (see Chapter&nbsp;<Ref Sect="Domains"/>)
##  plays no important role here
##  &ndash;we will justify this later in this section.
##  <P/>
##  Intuitively, <E>characters</E> (or more generally,
##  <E>class functions</E>) of a finite group <M>G</M> can be thought of as
##  certain mappings defined on <M>G</M>,
##  with values in the complex number field;
##  the set of all characters of <M>G</M> forms a semiring, with both
##  addition and multiplication defined pointwise, which is naturally
##  embedded into the ring of <E>generalized</E> (or <E>virtual</E>)
##  <E>characters</E> in the natural way.
##  A <M>&ZZ;</M>-basis of this ring, and also a vector space basis of the
##  complex vector space of class functions of <M>G</M>,
##  is given by the irreducible characters of <M>G</M>.
##  <P/>
##  At this stage one could ask where there is a problem, since all these
##  algebraic structures are supported by &GAP;.
##  But in practice, these structures are of minor importance,
##  compared to individual characters and the <E>character tables</E>
##  themselves (which are not domains in the sense of &GAP;).
##  <P/>
##  For computations with characters of a finite group <M>G</M> with <M>n</M>
##  conjugacy classes, we fix an ordering of the classes, and then
##  identify each class with its position according to this ordering.
##  Each character of <M>G</M> can be represented by a list of length
##  <M>n</M> in which the character value for elements of the <M>i</M>-th
##  class is stored at the <M>i</M>-th position.
##  Note that we need not know the conjugacy classes of <M>G</M> physically,
##  even our knowledge of <M>G</M> may be implicit in the sense that, e.g.,
##  we know how many classes of involutions <M>G</M> has, and which length
##  these classes have, but we never have seen an element of <M>G</M>,
##  or a presentation or representation of <M>G</M>.
##  This allows us to work with the character tables of very large groups,
##  e.g., of the so-called monster, where &GAP; has (currently) no chance
##  to deal with the group.
##  <P/>
##  As a consequence, also other information involving characters is given
##  implicitly.  For example, we can talk about the kernel of a character not
##  as a group but as a list of classes (more exactly: a list of their
##  positions according to the chosen ordering of classes) forming this
##  kernel; we can deduce the group order, the contained cyclic subgroups
##  and so on, but we do not get the group itself.
##  <P/>
##  So typical calculations with characters involve loops over lists of
##  character values.
##  For  example, the scalar product of two characters <M>\chi</M>,
##  <M>\psi</M> of <M>G</M> given by
##  <Display Mode="M">
##  [ \chi, \psi ] =
##  \left( \sum_{{g \in G}} \chi(g) \psi(g^{{-1}}) \right) / |G|
##  </Display>
##  can be written as
##  <Listing><![CDATA[
##  Sum( [ 1 .. n ], i -> SizesConjugacyClasses( t )[i] * chi[i]
##                            * ComplexConjugate( psi[i] ) ) / Size( t );
##  ]]></Listing>
##  where <C>t</C> is the character table of <M>G</M>, and <C>chi</C>,
##  <C>psi</C> are the lists of values of <M>\chi</M>, <M>\psi</M>,
##  respectively.
##  <P/>
##  It is one of the advantages of character theory that after one has
##  translated a problem concerning groups into a problem concerning
##  only characters, the necessary calculations are mostly simple.
##  For example, one can often prove that a group is a Galois group over the
##  rationals using calculations with structure constants that can be
##  computed from the character table,
##  and information about (the character tables of) maximal subgroups.
##  When one deals with such questions,
##  the translation back to groups is just an interpretation by the user,
##  it does not take place in &GAP;.
##  <P/>
##  &GAP; uses character <E>tables</E> to store information such as class
##  lengths, element orders, the irreducible characters of <M>G</M>
##  etc.&nbsp;in a consistent way;
##  in the example above, we have seen that
##  <Ref Attr="SizesConjugacyClasses"/> returns
##  the list of class lengths of its argument.
##  Note that the values of these attributes rely on the chosen ordering
##  of conjugacy classes,
##  a character table is not determined by something similar to generators
##  of groups or rings in &GAP; where knowledge could in principle be
##  recovered from the generators but is stored mainly for the sake of
##  efficiency.
##  <P/>
##  Note that the character table of a group <M>G</M> in &GAP; must
##  <E>not</E> be mixed up with the list of complex irreducible characters
##  of <M>G</M>.
##  The irreducible characters are stored in a character table via the
##  attribute <Ref Attr="Irr" Label="for a group"/>.
##  <P/>
##  Two further important instances of information that depends on the
##  ordering of conjugacy classes are <E>power maps</E> and
##  <E>fusion maps</E>.
##  Both are represented as lists of integers in &GAP;.
##  The <M>k</M>-th power map maps each class to the class of <M>k</M>-th
##  powers of its elements, the corresponding list contains at each position
##  the position of the image.
##  A class fusion map between the classes of a subgroup <M>H</M> of <M>G</M>
##  and the classes of <M>G</M> maps each class <M>c</M> of <M>H</M> to that
##  class of <M>G</M> that contains <M>c</M>, the corresponding list contains
##  again the positions of image classes;
##  if we know only the character tables of <M>H</M> and <M>G</M> but not the
##  groups themselves,
##  this means with respect to a fixed embedding of <M>H</M> into <M>G</M>.
##  More about power maps and fusion maps can be found in
##  Chapter&nbsp;<Ref Chap="Maps Concerning Character Tables"/>.
##  <P/>
##  So class functions, power maps, and fusion maps are represented by lists
##  in &GAP;.
##  If they are plain lists then they are regarded as class functions
##  etc.&nbsp;of an appropriate character table when they are passed to &GAP;
##  functions that expect class functions etc.
##  For example, a list with all entries equal to 1 is regarded as the
##  trivial character if it is passed to a function that expects a character.
##  Note that this approach requires the character table as an argument for
##  such a function.
##  <P/>
##  One can construct class function objects that store their underlying
##  character table and other attribute values
##  (see Chapter&nbsp;<Ref Chap="Class Functions"/>).
##  This allows one to omit the character table argument in many functions,
##  and it allows one to use infix operations for tensoring or inducing
##  class functions.
##  <#/GAPDoc>
##


#############################################################################
##
##  2. Character Table Categories
##


#############################################################################
##
#V  InfoCharacterTable
##
##  <#GAPDoc Label="InfoCharacterTable">
##  <ManSection>
##  <InfoClass Name="InfoCharacterTable"/>
##
##  <Description>
##  is the info class (see&nbsp;<Ref Sect="Info Functions"/>) for
##  computations with character tables.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsNearlyCharacterTable">
##  <ManSection>
##  <Filt Name="IsNearlyCharacterTable" Arg='obj' Type='Category'/>
##  <Filt Name="IsCharacterTable" Arg='obj' Type='Category'/>
##  <Filt Name="IsOrdinaryTable" Arg='obj' Type='Category'/>
##  <Filt Name="IsBrauerTable" Arg='obj' Type='Category'/>
##  <Filt Name="IsCharacterTableInProgress" Arg='obj' Type='Category'/>
##
##  <Description>
##  Every <Q>character table like object</Q> in &GAP; lies in the category
##  <Ref Filt="IsNearlyCharacterTable"/>.
##  There are four important subcategories,
##  namely the <E>ordinary</E> tables in <Ref Filt="IsOrdinaryTable"/>,
##  the <E>Brauer</E> tables in <Ref Filt="IsBrauerTable"/>,
##  the union of these two in <Ref Filt="IsCharacterTable"/>,
##  and the <E>incomplete ordinary</E> tables in
##  <Ref Filt="IsCharacterTableInProgress"/>.
##  <P/>
##  We want to distinguish ordinary and Brauer tables because a Brauer table
##  may delegate tasks to the ordinary table of the same group,
##  for example the computation of power maps.
##  A Brauer table is constructed from an ordinary table and stores this
##  table upon construction
##  (see&nbsp;<Ref Attr="OrdinaryCharacterTable" Label="for a group"/>).
##  <P/>
##  Furthermore, <Ref Filt="IsOrdinaryTable"/> and
##  <Ref Filt="IsBrauerTable"/> denote character tables that provide enough
##  information to compute all power maps and irreducible characters (and in
##  the case of Brauer tables to get the ordinary table), for example because
##  the underlying group
##  (see&nbsp;<Ref Attr="UnderlyingGroup" Label="for character tables"/>) is
##  known or because the table is a library table
##  (see the manual of the &GAP; Character Table Library).
##  We want to distinguish these tables from partially known ordinary tables
##  that cannot be asked for all power maps or all irreducible characters.
##  <P/>
##  The character table objects in <Ref Filt="IsCharacterTable"/> are always
##  immutable (see&nbsp;<Ref Sect="Mutability and Copyability"/>).
##  This means mainly that the ordering of conjugacy classes used for the
##  various attributes of the character table cannot be changed;
##  see&nbsp;<Ref Sect="Sorted Character Tables"/> for how to compute a
##  character table with a different ordering of classes.
##  <P/>
##  The &GAP; objects in <Ref Filt="IsCharacterTableInProgress"/> represent
##  incomplete ordinary character tables.
##  This means that not all irreducible characters, not all power maps are
##  known, and perhaps even the number of classes and the centralizer orders
##  are known.
##  Such tables occur when the character table of a group <M>G</M> is
##  constructed using character tables of related groups and information
##  about <M>G</M> but for example without explicitly computing the conjugacy
##  classes of <M>G</M>.
##  An object in <Ref Filt="IsCharacterTableInProgress"/> is first of all
##  <E>mutable</E>,
##  so <E>nothing is stored automatically</E> on such a table,
##  since otherwise one has no control of side-effects when
##  a hypothesis is changed.
##  Operations for such tables may return more general values than for
##  other tables, for example class functions may contain unknowns
##  (see Chapter&nbsp;<Ref Chap="Unknowns"/>) or lists of possible values in
##  certain positions,
##  the same may happen also for power maps and class fusions
##  (see&nbsp;<Ref Sect="Parametrized Maps"/>).
##  <E>Incomplete tables in this sense are currently not supported and will be
##  described in a chapter of their own when they become available.</E>
##  Note that the term <Q>incomplete table</Q> shall express that &GAP; cannot
##  compute certain values such as irreducible characters or power maps.
##  A table with access to its group is therefore always complete,
##  also if its irreducible characters are not yet stored.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= SymmetricGroup( 4 );;
##  gap> tbl:= CharacterTable( g );  modtbl:= tbl mod 2;
##  CharacterTable( Sym( [ 1 .. 4 ] ) )
##  BrauerTable( Sym( [ 1 .. 4 ] ), 2 )
##  gap> IsCharacterTable( tbl );  IsCharacterTable( modtbl );
##  true
##  true
##  gap> IsBrauerTable( modtbl );  IsBrauerTable( tbl );
##  true
##  false
##  gap> IsOrdinaryTable( tbl );  IsOrdinaryTable( modtbl );
##  true
##  false
##  gap> IsCharacterTable( g );  IsCharacterTable( Irr( g ) );
##  false
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsNearlyCharacterTable", IsObject, 20 );
DeclareCategory( "IsCharacterTable", IsNearlyCharacterTable );
DeclareCategory( "IsOrdinaryTable", IsCharacterTable );
DeclareCategory( "IsBrauerTable", IsCharacterTable );
DeclareCategory( "IsCharacterTableInProgress", IsNearlyCharacterTable );


#############################################################################
##
#V  NearlyCharacterTablesFamily
##
##  <#GAPDoc Label="NearlyCharacterTablesFamily">
##  <ManSection>
##  <Fam Name="NearlyCharacterTablesFamily"/>
##
##  <Description>
##  Every character table like object lies in this family
##  (see&nbsp;<Ref Sect="Families"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "NearlyCharacterTablesFamily",
    NewFamily( "NearlyCharacterTablesFamily", IsNearlyCharacterTable ) );


#############################################################################
##
#V  SupportedCharacterTableInfo
##
##  <#GAPDoc Label="SupportedCharacterTableInfo">
##  <ManSection>
##  <Var Name="SupportedCharacterTableInfo"/>
##
##  <Description>
##  <Ref Var="SupportedCharacterTableInfo"/> is a list that contains
##  at position <M>3i-2</M> an attribute getter function,
##  at position <M>3i-1</M> the name of this attribute,
##  and at position <M>3i</M> a list containing a subset of
##  <C>[ "character", "class", "mutable" ]</C>,
##  depending on whether the attribute value relies on the ordering of
##  characters or classes, or whether the attribute value is a mutable
##  list or record.
##  <P/>
##  When (ordinary or Brauer) character table objects are created from
##  records, using <Ref Func="ConvertToCharacterTable"/>,
##  <Ref Var="SupportedCharacterTableInfo"/> specifies those
##  record components that shall be used as attribute values;
##  other record components are <E>not</E> be regarded as attribute
##  values in the conversion process.
##  <P/>
##  New attributes and properties can be notified to
##  <Ref Var="SupportedCharacterTableInfo"/> by creating them with
##  <C>DeclareAttributeSuppCT</C> and <C>DeclarePropertySuppCT</C> instead of
##  <Ref Func="DeclareAttribute"/> and
##  <Ref Func="DeclareProperty"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "SupportedCharacterTableInfo", [] );


#############################################################################
##
#F  DeclareAttributeSuppCT( <name>, <filter>[, "mutable"], <depend> )
#F  DeclarePropertySuppCT( <name>, <filter> )
##
##  <ManSection>
##  <Func Name="DeclareAttributeSuppCT"
##   Arg='name, filter[, "mutable"], depend'/>
##  <Func Name="DeclarePropertySuppCT" Arg='name, filter'/>
##
##  <Description>
##  do the same as <Ref Func="DeclareAttribute"/> and
##  <Ref Func="DeclareProperty"/>,
##  except that the list <Ref Var="SupportedOrdinaryTableInfo"/> is extended
##  by an entry corresponding to the attribute.
##  </Description>
##  </ManSection>
##
BindGlobal( "DeclareAttributeSuppCT", function( name, filter, arg... )
    local mutflag, depend;

    # Check the arguments.
    if not ( IsString( name ) and IsFilter( filter ) ) then
      Error( "<name> must be a string, <filter> must be a filter" );
    elif Length( arg ) = 1 and IsList( arg[1] ) then
      mutflag:= false;
      depend:= arg[1];
    elif Length( arg ) = 2 and arg[1] = "mutable" and IsList( arg[2] ) then
      mutflag:= true;
      depend:= arg[2];
    else
      Error( "usage: DeclareAttributeSuppCT( <name>,\n",
             " <filter>[, \"mutable\"], <depend> )" );
    fi;
    if not ForAll( depend, str -> str in [ "class", "character" ] ) then
      Error( "<depend> must contain only \"class\", \"character\"" );
    fi;

    # Create/change the attribute as `DeclareAttribute' does.
    if mutflag then
      DeclareAttribute( name, filter, "mutable" );
      depend:= Concatenation( depend, [ "mutable" ] );
    else
      DeclareAttribute( name, filter );
    fi;

    # Do the additional magic.
    Append( SupportedCharacterTableInfo,
            [ ValueGlobal( name ), name, depend ] );
end );

BindGlobal( "DeclarePropertySuppCT", function( name, filter )
    # Check the arguments.
    if not ( IsString( name ) and IsFilter( filter ) ) then
      Error( "<name> must be a string, <filter> must be a filter" );
    fi;

    # Create/change the property as `DeclareProperty' does.
    DeclareProperty( name, filter );

    # Do the additional magic.
    Append( SupportedCharacterTableInfo, [ ValueGlobal( name ), name, [] ] );
end );


#############################################################################
##
##  3. The Interface between Character Tables and Groups
##
##  <#GAPDoc Label="[2]{ctbl}">
##  For a character table with underlying group
##  (see&nbsp;<Ref Attr="UnderlyingGroup" Label="for character tables"/>),
##  the interface between table and group consists of three attribute values,
##  namely the <E>group</E>, the <E>conjugacy classes</E> stored in the table
##  (see <Ref Attr="ConjugacyClasses" Label="for character tables"/> below)
##  and the <E>identification</E> of the conjugacy classes of table and group
##  (see&nbsp;<Ref Attr="IdentificationOfConjugacyClasses"/> below).
##  <P/>
##  Character tables constructed from groups know these values upon
##  construction,
##  and for character tables constructed without groups, these values are
##  usually not known and cannot be computed from the table.
##  <P/>
##  However, given a group <M>G</M> and a character table of a group
##  isomorphic to <M>G</M> (for example a character table from the
##  &GAP; table library),
##  one can tell &GAP; to compute a new instance of the given table and to
##  use it as the character table of <M>G</M>
##  (see&nbsp;<Ref Func="CharacterTableWithStoredGroup"/>).
##  <P/>
##  Tasks may be delegated from a group to its character table or vice versa
##  only if these three attribute values are stored in the character table.
##  <#/GAPDoc>
##


#############################################################################
##
#A  UnderlyingGroup( <ordtbl> )
##
##  <#GAPDoc Label="UnderlyingGroup:ctbl">
##  <ManSection>
##  <Attr Name="UnderlyingGroup" Arg='ordtbl' Label="for character tables"/>
##
##  <Description>
##  For an ordinary character table <A>ordtbl</A> of a finite group,
##  the group can be stored as value of
##  <Ref Attr="UnderlyingGroup" Label="for character tables"/>.
##  <P/>
##  Brauer tables do not store the underlying group,
##  they access it via the ordinary table
##  (see&nbsp;<Ref Attr="OrdinaryCharacterTable" Label="for a character table"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "UnderlyingGroup", IsOrdinaryTable, [] );


#############################################################################
##
#A  ConjugacyClasses( <tbl> )
##
##  <#GAPDoc Label="ConjugacyClasses:ctbl">
##  <ManSection>
##  <Attr Name="ConjugacyClasses" Arg='tbl' Label="for character tables"/>
##
##  <Description>
##  For a character table <A>tbl</A> with known underlying group <M>G</M>,
##  the <Ref Attr="ConjugacyClasses" Label="for character tables"/> value of
##  <A>tbl</A> is a list of conjugacy classes of <M>G</M>.
##  All those lists stored in the table that are related to the ordering
##  of conjugacy classes (such as sizes of centralizers and conjugacy
##  classes, orders of representatives, power maps, and all class functions)
##  refer to the ordering of this list.
##  <P/>
##  This ordering need <E>not</E> coincide with the ordering of conjugacy
##  classes as stored in the underlying group of the table
##  (see&nbsp;<Ref Sect="Sorted Character Tables"/>).
##  One reason for this is that otherwise we would not be allowed to
##  use a library table as the character table of a group for which the
##  conjugacy classes are stored already.
##  (Another, less important reason is that we can use the same group as
##  underlying group of character tables that differ only w.r.t.&nbsp;the
##  ordering of classes.)
##  <P/>
##  The class of the identity element must be the first class
##  (see&nbsp;<Ref Sect="Conventions for Character Tables"/>).
##  <P/>
##  If <A>tbl</A> was constructed from <M>G</M> then the conjugacy classes
##  have been stored at the same time when <M>G</M> was stored.
##  If <M>G</M> and <A>tbl</A> have been connected later than in the
##  construction of <A>tbl</A>, the recommended way to do this is via
##  <Ref Func="CharacterTableWithStoredGroup"/>.
##  So there is no method for
##  <Ref Attr="ConjugacyClasses" Label="for character tables"/> that computes
##  the value for <A>tbl</A> if it is not yet stored.
##  <P/>
##  Brauer tables do not store the (<M>p</M>-regular) conjugacy classes,
##  they access them via the ordinary table
##  (see&nbsp;<Ref Attr="OrdinaryCharacterTable" Label="for a character table"/>)
##  if necessary.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "ConjugacyClasses", IsOrdinaryTable, [ "class" ] );


#############################################################################
##
#A  IdentificationOfConjugacyClasses( <tbl> )
##
##  <#GAPDoc Label="IdentificationOfConjugacyClasses">
##  <ManSection>
##  <Attr Name="IdentificationOfConjugacyClasses" Arg='tbl'/>
##
##  <Description>
##  For an ordinary character table <A>tbl</A> with known underlying group
##  <M>G</M>, <Ref Attr="IdentificationOfConjugacyClasses"/> returns a list
##  of positive integers that contains at position <M>i</M> the position of
##  the <M>i</M>-th conjugacy class of <A>tbl</A> in the
##  <Ref Attr="ConjugacyClasses" Label="for character tables"/> value of
##  <M>G</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= SymmetricGroup( 4 );;
##  gap> repres:= [ (1,2), (1,2,3), (1,2,3,4), (1,2)(3,4), () ];;
##  gap> ccl:= List( repres, x -> ConjugacyClass( g, x ) );;
##  gap> SetConjugacyClasses( g, ccl );
##  gap> tbl:= CharacterTable( g );;   # the table stores already the values
##  gap> HasConjugacyClasses( tbl );  HasUnderlyingGroup( tbl );
##  true
##  true
##  gap> UnderlyingGroup( tbl ) = g;
##  true
##  gap> HasIdentificationOfConjugacyClasses( tbl );
##  true
##  gap> IdentificationOfConjugacyClasses( tbl );
##  [ 5, 1, 2, 3, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "IdentificationOfConjugacyClasses", IsOrdinaryTable,
    [ "class" ] );


#############################################################################
##
#F  CharacterTableWithStoredGroup( <G>, <tbl>[, <info>] )
##
##  <#GAPDoc Label="CharacterTableWithStoredGroup">
##  <ManSection>
##  <Func Name="CharacterTableWithStoredGroup" Arg='G, tbl[, info]'/>
##
##  <Description>
##  Let <A>G</A> be a group and <A>tbl</A> a character table of (a group
##  isomorphic to) <A>G</A>, such that <A>G</A> does not store its
##  <Ref Attr="OrdinaryCharacterTable" Label="for a group"/> value.
##  <Ref Func="CharacterTableWithStoredGroup"/> calls
##  <Ref Oper="CompatibleConjugacyClasses"/>,
##  trying to identify the classes of <A>G</A> with the columns of
##  <A>tbl</A>.
##  <P/>
##  If this identification is unique up to automorphisms of <A>tbl</A>
##  (see&nbsp;<Ref Attr="AutomorphismsOfTable"/>) then <A>tbl</A> is stored
##  as <Ref Oper="CharacterTable" Label="for a group"/> value of <A>G</A>,
##  and a new character table is returned that is equivalent to <A>tbl</A>,
##  is sorted in the same way as <A>tbl</A>, and has the values of
##  <Ref Attr="UnderlyingGroup" Label="for character tables"/>,
##  <Ref Attr="ConjugacyClasses" Label="for character tables"/>, and
##  <Ref Attr="IdentificationOfConjugacyClasses"/> set.
##  <P/>
##  Otherwise, i.e., if &GAP; cannot identify the classes of <A>G</A> up to
##  automorphisms of <A>tbl</A>, <K>fail</K> is returned.
##  <P/>
##  If a record is present as the third argument <A>info</A>,
##  its meaning is the same as the optional argument <A>arec</A> for
##  <Ref Oper="CompatibleConjugacyClasses"/>.
##  <P/>
##  If a list is entered as third argument <A>info</A>
##  it is used as value of <Ref Attr="IdentificationOfConjugacyClasses"/>,
##  relative to the
##  <Ref Attr="ConjugacyClasses" Label="for character tables"/>
##  value of <A>G</A>, without further checking,
##  and the corresponding character table is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CharacterTableWithStoredGroup" );


#############################################################################
##
#O  CompatibleConjugacyClasses( [<G>, <ccl>, ]<tbl>[, <arec>] )
##
##  <#GAPDoc Label="CompatibleConjugacyClasses">
##  <ManSection>
##  <Oper Name="CompatibleConjugacyClasses" Arg='[G, ccl, ]tbl[, arec]'/>
##
##  <Description>
##  If the arguments <A>G</A> and <A>ccl</A> are present then <A>ccl</A> must
##  be a list of the conjugacy classes of the group <A>G</A>,
##  and <A>tbl</A> the ordinary character table of <A>G</A>.
##  Then <Ref Oper="CompatibleConjugacyClasses"/> returns a list <M>l</M> of
##  positive integers that describes an identification of the columns of
##  <A>tbl</A> with the conjugacy classes <A>ccl</A> in the sense that
##  <M>l[i]</M> is the position in <A>ccl</A> of the class corresponding to
##  the <M>i</M>-th column of <A>tbl</A>, if this identification is unique up
##  to automorphisms of <A>tbl</A>
##  (see&nbsp;<Ref Attr="AutomorphismsOfTable"/>);
##  if &GAP; cannot identify the classes, <K>fail</K> is returned.
##  <P/>
##  If <A>tbl</A> is the first argument then it must be an ordinary character
##  table, and <Ref Oper="CompatibleConjugacyClasses"/> checks whether the
##  columns of <A>tbl</A> can be identified with the conjugacy classes of
##  a group isomorphic to that for which <A>tbl</A> is the character table;
##  the return value is a list of all those sets of class positions for which
##  the columns of <A>tbl</A> cannot be distinguished with the invariants
##  used, up to automorphisms of <A>tbl</A>.
##  So the identification is unique if and only if the returned list is
##  empty.
##  <P/>
##  The usual approach is that one first calls
##  <Ref Oper="CompatibleConjugacyClasses"/>
##  in the second form for checking quickly whether the first form will be
##  successful, and only if this is the case the more time consuming
##  calculations with both group and character table are done.
##  <P/>
##  The following invariants are used.
##  <Enum>
##  <Item>
##   element orders (see&nbsp;<Ref Attr="OrdersClassRepresentatives"/>),
##  </Item>
##  <Item>
##   class lengths (see&nbsp;<Ref Attr="SizesConjugacyClasses"/>),
##  </Item>
##  <Item>
##   power maps (see&nbsp;<Ref Oper="PowerMap"/>,
##   <Ref Attr="ComputedPowerMaps"/>),
##  </Item>
##  <Item>
##   symmetries of the table (see&nbsp;<Ref Attr="AutomorphismsOfTable"/>).
##  </Item>
##  </Enum>
##  <P/>
##  If the optional argument <A>arec</A> is present then it must be a record
##  whose components describe additional information for the class
##  identification.
##  The following components are supported.
##  <List>
##  <Mark><C>natchar</C> </Mark>
##  <Item>
##    if <M>G</M> is a permutation group or matrix group then the value of
##    this component is regarded as the list of values of the natural
##    character (see&nbsp;<Ref Attr="NaturalCharacter" Label="for a group"/>)
##    of <A>G</A>, w.r.t.&nbsp;the ordering of classes in <A>tbl</A>,
##  </Item>
##  <Mark><C>bijection</C> </Mark>
##  <Item>
##    a list describing a partial bijection; the <M>i</M>-th entry, if bound,
##    is the position of the <M>i</M>-th conjugacy class of <A>tbl</A> in the
##    list <A>ccl</A>.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> g:= AlternatingGroup( 5 );
##  Alt( [ 1 .. 5 ] )
##  gap> tbl:= CharacterTable( "A5" );
##  CharacterTable( "A5" )
##  gap> HasUnderlyingGroup( tbl );  HasOrdinaryCharacterTable( g );
##  false
##  false
##  gap> CompatibleConjugacyClasses( tbl );   # unique identification
##  [  ]
##  gap> new:= CharacterTableWithStoredGroup( g, tbl );
##  CharacterTable( Alt( [ 1 .. 5 ] ) )
##  gap> Irr( new ) = Irr( tbl );
##  true
##  gap> HasConjugacyClasses( new );  HasUnderlyingGroup( new );
##  true
##  true
##  gap> IdentificationOfConjugacyClasses( new );
##  [ 1, 2, 3, 4, 5 ]
##  gap> # Here is an example where the identification is not unique.
##  gap> CompatibleConjugacyClasses( CharacterTable( "J2" ) );
##  [ [ 17, 18 ], [ 9, 10 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <ManSection>
##  <Func Name="CompatibleConjugacyClassesDefault" Arg='G, ccl, tbl, arec'/>
##  <Func Name="CompatibleConjugacyClassesDefault"
##   Arg='false, false, tbl, arec'/>
##
##  <Description>
##  This is installed as a method for
##  <Ref Func="CompatibleConjugacyClasses"/>.
##  It uses the following invariants.
##  Element orders, class lengths, cosets of the derived subgroup,
##  power maps of prime divisors of the group order, automorphisms of
##  <A>tbl</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CompatibleConjugacyClassesDefault" );


#############################################################################
##
##  4. Operators for Character Tables
##
##  <#GAPDoc Label="[3]{ctbl}">
##  <Index Key="*" Subkey="for character tables"><C>*</C></Index>
##  <Index Key="/" Subkey="for character tables"><C>/</C></Index>
##  <Index Key="mod" Subkey="for character tables"><K>mod</K></Index>
##  <Index Subkey="infix operators">character tables</Index>
##  The following infix operators are defined for character tables.
##  <List>
##  <Mark><C><A>tbl1</A> * <A>tbl2</A></C></Mark>
##  <Item>
##      the direct product of two character tables
##      (see&nbsp;<Ref Oper="CharacterTableDirectProduct"/>),
##  </Item>
##  <Mark><C><A>tbl</A> / <A>list</A></C></Mark>
##  <Item>
##      the table of the factor group modulo the normal subgroup spanned by
##      the classes in the list <A>list</A>
##      (see&nbsp;<Ref Oper="CharacterTableFactorGroup"/>),
##  </Item>
##  <Mark><C><A>tbl</A> mod <A>p</A></C></Mark>
##  <Item>
##      the <A>p</A>-modular Brauer character table corresponding to
##      the ordinary character table <A>tbl</A>
##      (see&nbsp;<Ref Oper="BrauerTable"
##  Label="for a character table, and a prime integer"/>),
##  </Item>
##  <Mark><C><A>tbl</A>.<A>name</A></C></Mark>
##  <Item>
##      the position of the class with name <A>name</A> in <A>tbl</A>
##      (see&nbsp;<Ref Attr="ClassNames"/>).
##  </Item>
##  </List>
##  <#/GAPDoc>
##


#############################################################################
##
##  5. Attributes and Properties for Groups as well as for Character Tables
##
##  <#GAPDoc Label="[4]{ctbl}">
##  Several <E>attributes for groups</E> are valid also for character tables.
##  <P/>
##  These are first those that have the same meaning for both
##  the group and its character table,
##  and whose values can be read off or computed, respectively,
##  from the character table,
##  such as <Ref Attr="Size" Label="for a character table"/>,
##  <Ref Prop="IsAbelian" Label="for a character table"/>,
##  or <Ref Prop="IsSolvable" Label="for a character table"/>.
##  <P/>
##  Second, there are attributes whose meaning for character
##  tables is different from the meaning for groups, such as
##  <Ref Attr="ConjugacyClasses" Label="for character tables"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#A  CharacterDegrees( <G>[, <p>] )
#A  CharacterDegrees( <tbl> )
##
##  <#GAPDoc Label="CharacterDegrees">
##  <ManSection>
##  <Heading>CharacterDegrees</Heading>
##  <Attr Name="CharacterDegrees" Arg='G[, p]' Label="for a group"/>
##  <Attr Name="CharacterDegrees" Arg='tbl' Label="for a character table"/>
##
##  <Description>
##  In the first form, <Ref Attr="CharacterDegrees" Label="for a group"/>
##  returns a collected list of the degrees of the absolutely irreducible
##  characters of the group <A>G</A>;
##  the optional second argument <A>p</A> must be either zero or a prime
##  integer denoting the characteristic, the default value is zero.
##  In the second form, <A>tbl</A> must be an (ordinary or Brauer) character
##  table, and <Ref Attr="CharacterDegrees" Label="for a character table"/>
##  returns a collected list of the degrees of the absolutely irreducible
##  characters of <A>tbl</A>.
##  <P/>
##  (The default method for the call with only argument a group is to call
##  the operation with second argument <C>0</C>.)
##  <P/>
##  For solvable groups,
##  the default method is based on&nbsp;<Cite Key="Con90b"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> CharacterDegrees( SymmetricGroup( 4 ) );
##  [ [ 1, 2 ], [ 2, 1 ], [ 3, 2 ] ]
##  gap> CharacterDegrees( SymmetricGroup( 4 ), 2 );
##  [ [ 1, 1 ], [ 2, 1 ] ]
##  gap> CharacterDegrees( CharacterTable( "A5" ) );
##  [ [ 1, 1 ], [ 3, 2 ], [ 4, 1 ], [ 5, 1 ] ]
##  gap> CharacterDegrees( CharacterTable( "A5" ) mod 2 );
##  [ [ 1, 1 ], [ 2, 2 ], [ 4, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CharacterDegrees", IsGroup );
DeclareOperation( "CharacterDegrees", [ IsGroup, IsInt ] );
DeclareAttributeSuppCT( "CharacterDegrees", IsNearlyCharacterTable, [] );

InstallIsomorphismMaintenance( CharacterDegrees,
    IsGroup and HasCharacterDegrees, IsGroup );


#############################################################################
##
#A  Irr( <G>[, <p>] )
#A  Irr( <tbl> )
##
##  <#GAPDoc Label="Irr">
##  <ManSection>
##  <Heading>Irr</Heading>
##  <Attr Name="Irr" Arg='G[, p]' Label="for a group"/>
##  <Attr Name="Irr" Arg='tbl' Label="for a character table"/>
##
##  <Description>
##  Called with a group <A>G</A>, <Ref Attr="Irr" Label="for a group"/>
##  returns the irreducible characters of the ordinary character table of
##  <A>G</A>.
##  Called with a group <A>G</A> and a prime integer <A>p</A>,
##  <Ref Attr="Irr" Label="for a group"/> returns the irreducible characters
##  of the <A>p</A>-modular Brauer table of <A>G</A>.
##  Called with an (ordinary or Brauer) character table <A>tbl</A>,
##  <Ref Attr="Irr" Label="for a group"/> returns the list of all
##  complex absolutely irreducible characters of <A>tbl</A>.
##  <P/>
##  For a character table <A>tbl</A> with underlying group,
##  <Ref Attr="Irr" Label="for a character table"/> may delegate to the group.
##  For a group <A>G</A>, <Ref Attr="Irr" Label="for a group"/> may delegate
##  to its character table only if the irreducibles are already stored there.
##  <P/>
##  (If <A>G</A> is <A>p</A>-solvable (see&nbsp;<Ref Oper="IsPSolvable"/>)
##  then the <A>p</A>-modular irreducible characters can be computed by the
##  Fong-Swan Theorem; in all other cases, there may be no method.)
##  <P/>
##  Note that the ordering of columns in the
##  <Ref Attr="Irr" Label="for a group"/> matrix of the
##  group <A>G</A> refers to the ordering of conjugacy classes in the
##  <Ref Oper="CharacterTable" Label="for a group"/> value of <A>G</A>,
##  which may differ from the ordering of conjugacy classes in <A>G</A>
##  (see <Ref Sect="The Interface between Character Tables and Groups"/>).
##  As an extreme example, for a character table obtained from sorting the
##  classes of the <Ref Oper="CharacterTable" Label="for a group"/>
##  value of <A>G</A>,
##  the ordering of columns in the <Ref Attr="Irr" Label="for a group"/>
##  matrix respects the
##  sorting of classes (see&nbsp;<Ref Sect="Sorted Character Tables"/>),
##  so the irreducibles of such a table will in general not coincide with
##  the irreducibles stored as the <Ref Attr="Irr" Label="for a group"/>
##  value of <A>G</A> although also the sorted table stores the group
##  <A>G</A>.
##  <P/>
##  The ordering of the entries in the attribute
##  <Ref Attr="Irr" Label="for a group"/> of a group
##  need <E>not</E> coincide with the ordering of its
##  <Ref Attr="IrreducibleRepresentations"/> value.
##  <P/>
##  <Example><![CDATA[
##  gap> Irr( SymmetricGroup( 4 ) );
##  [ Character( CharacterTable( Sym( [ 1 .. 4 ] ) ), [ 1, -1, 1, 1, -1
##       ] ), Character( CharacterTable( Sym( [ 1 .. 4 ] ) ),
##      [ 3, -1, -1, 0, 1 ] ),
##    Character( CharacterTable( Sym( [ 1 .. 4 ] ) ), [ 2, 0, 2, -1, 0 ] )
##      , Character( CharacterTable( Sym( [ 1 .. 4 ] ) ),
##      [ 3, 1, -1, 0, -1 ] ),
##    Character( CharacterTable( Sym( [ 1 .. 4 ] ) ), [ 1, 1, 1, 1, 1 ] )
##   ]
##  gap> Irr( SymmetricGroup( 4 ), 2 );
##  [ Character( BrauerTable( Sym( [ 1 .. 4 ] ), 2 ), [ 1, 1 ] ),
##    Character( BrauerTable( Sym( [ 1 .. 4 ] ), 2 ), [ 2, -1 ] ) ]
##  gap> Irr( CharacterTable( "A5" ) );
##  [ Character( CharacterTable( "A5" ), [ 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( "A5" ),
##      [ 3, -1, 0, -E(5)-E(5)^4, -E(5)^2-E(5)^3 ] ),
##    Character( CharacterTable( "A5" ),
##      [ 3, -1, 0, -E(5)^2-E(5)^3, -E(5)-E(5)^4 ] ),
##    Character( CharacterTable( "A5" ), [ 4, 0, 1, -1, -1 ] ),
##    Character( CharacterTable( "A5" ), [ 5, 1, -1, 0, 0 ] ) ]
##  gap> Irr( CharacterTable( "A5" ) mod 2 );
##  [ Character( BrauerTable( "A5", 2 ), [ 1, 1, 1, 1 ] ),
##    Character( BrauerTable( "A5", 2 ),
##      [ 2, -1, E(5)+E(5)^4, E(5)^2+E(5)^3 ] ),
##    Character( BrauerTable( "A5", 2 ),
##      [ 2, -1, E(5)^2+E(5)^3, E(5)+E(5)^4 ] ),
##    Character( BrauerTable( "A5", 2 ), [ 4, 1, -1, -1 ] ) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Irr", IsGroup );
DeclareOperation( "Irr", [ IsGroup, IsInt ] );
DeclareAttributeSuppCT( "Irr", IsNearlyCharacterTable,
    [ "character", "class" ] );


#############################################################################
##
#A  LinearCharacters( <G>[, <p>] )
#A  LinearCharacters( <tbl> )
##
##  <#GAPDoc Label="LinearCharacters">
##  <ManSection>
##  <Heading>LinearCharacters</Heading>
##  <Attr Name="LinearCharacters" Arg='G[, p]' Label="for a group"/>
##  <Attr Name="LinearCharacters" Arg='tbl' Label="for a character table"/>
##
##  <Description>
##  <Ref Attr="LinearCharacters" Label="for a group"/> returns the linear
##  (i.e., degree <M>1</M>) characters in the
##  <Ref Attr="Irr" Label="for a group"/> list of the group
##  <A>G</A> or the character table <A>tbl</A>, respectively.
##  In the second form,
##  <Ref Attr="LinearCharacters" Label="for a character table"/> returns the
##  <A>p</A>-modular linear characters of the group <A>G</A>.
##  <P/>
##  For a character table <A>tbl</A> with underlying group,
##  <Ref Attr="LinearCharacters" Label="for a character table"/> may delegate
##  to the group.
##  For a group <A>G</A>, <Ref Attr="LinearCharacters" Label="for a group"/>
##  may delegate to its character table only if the irreducibles
##  are already stored there.
##  <P/>
##  The ordering of linear characters in <A>tbl</A> need not coincide with the
##  ordering of linear characters in the irreducibles of <A>tbl</A>
##  (see&nbsp;<Ref Attr="Irr" Label="for a character table"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> LinearCharacters( SymmetricGroup( 4 ) );
##  [ Character( CharacterTable( Sym( [ 1 .. 4 ] ) ), [ 1, 1, 1, 1, 1 ] ),
##    Character( CharacterTable( Sym( [ 1 .. 4 ] ) ), [ 1, -1, 1, 1, -1
##       ] ) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <ManSection>
##  <Heading>IBr</Heading>
##  <Attr Name="IBr" Arg='modtbl' Label="for a character table"/>
##  <Oper Name="IBr" Arg='G, p' Label="for a group, and a prime integer"/>
##
##  <Description>
##  For a Brauer table <A>modtbl</A> or a group <A>G</A> and a prime integer
##  <A>p</A>, <Ref Oper="IBr" Label="for a character table"/> delegates to
##  <Ref Attr="Irr" Label="for a character table"/>.
##  <!-- This may become interesting as soon as blocks are GAP objects of
##       their own, and one can ask for the ordinary and modular irreducibles
##       in a block.-->
##  </Description>
##  </ManSection>
##
DeclareAttribute( "IBr", IsBrauerTable );
DeclareOperation( "IBr", [ IsGroup, IsPosInt ] );


#############################################################################
##
#A  OrdinaryCharacterTable( <G> ) . . . . . . . . . . . . . . . . for a group
#A  OrdinaryCharacterTable( <modtbl> )  . . . .  for a Brauer character table
##
##  <#GAPDoc Label="OrdinaryCharacterTable">
##  <ManSection>
##  <Heading>OrdinaryCharacterTable</Heading>
##  <Attr Name="OrdinaryCharacterTable" Arg='G' Label="for a group"/>
##  <Attr Name="OrdinaryCharacterTable" Arg='modtbl'
##        Label="for a character table"/>
##
##  <Description>
##  <Ref Attr="OrdinaryCharacterTable" Label="for a group"/> returns the
##  ordinary character table of the group <A>G</A>
##  or the Brauer character table <A>modtbl</A>, respectively.
##  <P/>
##  Since Brauer character tables are constructed from ordinary tables,
##  the attribute value for <A>modtbl</A> is already stored
##  (cf.&nbsp;<Ref Sect="Character Table Categories"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> OrdinaryCharacterTable( SymmetricGroup( 4 ) );
##  CharacterTable( Sym( [ 1 .. 4 ] ) )
##  gap> tbl:= CharacterTable( "A5" );;  modtbl:= tbl mod 2;
##  BrauerTable( "A5", 2 )
##  gap> OrdinaryCharacterTable( modtbl ) = tbl;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "OrdinaryCharacterTable", IsGroup, [] );


#############################################################################
##
#A  AbelianInvariants( <tbl> )
#A  CommutatorLength( <tbl> )
#A  Exponent( <tbl> )
#P  IsAbelian( <tbl> )
#P  IsAlmostSimple( <tbl> )
#P  IsCyclic( <tbl> )
#P  IsElementaryAbelian( <tbl> )
#P  IsFinite( <tbl> )
#P  IsMonomial( <tbl> )
#P  IsNilpotent( <tbl> )
#P  IsPerfect( <tbl> )
#P  IsQuasisimple( <tbl> )
#P  IsSimple( <tbl> )
#P  IsSporadicSimple( <tbl> )
#P  IsSupersolvable( <tbl> )
#A  IsomorphismTypeInfoFiniteSimpleGroup( <tbl> )
#A  NrConjugacyClasses( <tbl> )
#A  Size( <tbl> )
##
##  <#GAPDoc Label="[5]{ctbl}">
##  <ManSection>
##  <Heading>Group Operations Applicable to Character Tables</Heading>
##  <Attr Name="AbelianInvariants" Arg='tbl' Label="for a character table"/>
##  <Attr Name="CommutatorLength" Arg='tbl' Label="for a character table"/>
##  <Attr Name="Exponent" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsAbelian" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsAlmostSimple" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsCyclic" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsElementaryAbelian" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsFinite" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsMonomial" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsNilpotent" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsPerfect" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsQuasisimple" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsSimple" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsSolvable" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsSporadicSimple" Arg='tbl' Label="for a character table"/>
##  <Prop Name="IsSupersolvable" Arg='tbl' Label="for a character table"/>
##  <Attr Name="IsomorphismTypeInfoFiniteSimpleGroup" Arg='tbl'
##   Label="for a character table"/>
##  <Attr Name="NrConjugacyClasses" Arg='tbl' Label="for a character table"/>
##  <Attr Name="Size" Arg='tbl' Label="for a character table"/>
##
##  <Description>
##  These operations for groups are applicable to character tables
##  and mean the same for a character table as for its underlying group;
##  see Chapter <Ref Chap="Groups"/> for the definitions.
##  The operations are mainly useful for selecting character tables with
##  certain properties, also for character tables without access to a group.
##  <P/>
##  <Example><![CDATA[
##  gap> tables:= [ CharacterTable( CyclicGroup( 3 ) ),
##  >               CharacterTable( SymmetricGroup( 4 ) ),
##  >               CharacterTable( AlternatingGroup( 5 ) ),
##  >               CharacterTable( SL( 2, 5 ) ) ];;
##  gap> List( tables, AbelianInvariants );
##  [ [ 3 ], [ 2 ], [  ], [  ] ]
##  gap> List( tables, CommutatorLength );
##  [ 1, 1, 1, 1 ]
##  gap> List( tables, Exponent );
##  [ 3, 12, 30, 60 ]
##  gap> List( tables, IsAbelian );
##  [ true, false, false, false ]
##  gap> List( tables, IsAlmostSimple );
##  [ false, false, true, false ]
##  gap> List( tables, IsCyclic );
##  [ true, false, false, false ]
##  gap> List( tables, IsFinite );
##  [ true, true, true, true ]
##  gap> List( tables, IsMonomial );
##  [ true, true, false, false ]
##  gap> List( tables, IsNilpotent );
##  [ true, false, false, false ]
##  gap> List( tables, IsPerfect );
##  [ false, false, true, true ]
##  gap> List( tables, IsQuasisimple );
##  [ false, false, true, true ]
##  gap> List( tables, IsSimple );
##  [ true, false, true, false ]
##  gap> List( tables, IsSolvable );
##  [ true, true, false, false ]
##  gap> List( tables, IsSupersolvable );
##  [ true, false, false, false ]
##  gap> List( tables, NrConjugacyClasses );
##  [ 3, 5, 5, 9 ]
##  gap> List( tables, Size );
##  [ 3, 24, 60, 120 ]
##  gap> IsomorphismTypeInfoFiniteSimpleGroup( CharacterTable( "C5" ) );
##  rec( name := "Z(5)", parameter := 5, series := "Z", shortname := "C5"
##   )
##  gap> IsomorphismTypeInfoFiniteSimpleGroup( CharacterTable( "S3" ) );
##  fail
##  gap> IsomorphismTypeInfoFiniteSimpleGroup( CharacterTable( "S6(3)" ) );
##  rec( name := "C(3,3) = S(6,3)", parameter := [ 3, 3 ], series := "C",
##    shortname := "S6(3)" )
##  gap> IsomorphismTypeInfoFiniteSimpleGroup( CharacterTable( "O7(3)" ) );
##  rec( name := "B(3,3) = O(7,3)", parameter := [ 3, 3 ], series := "B",
##    shortname := "O7(3)" )
##  gap> IsomorphismTypeInfoFiniteSimpleGroup( CharacterTable( "A8" ) );
##  rec( name := "A(8) ~ A(3,2) = L(4,2) ~ D(3,2) = O+(6,2)",
##    parameter := 8, series := "A", shortname := "A8" )
##  gap> IsomorphismTypeInfoFiniteSimpleGroup( CharacterTable( "L3(4)" ) );
##  rec( name := "A(2,4) = L(3,4)", parameter := [ 3, 4 ], series := "L",
##    shortname := "L3(4)" )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "AbelianInvariants", IsNearlyCharacterTable, [] );
DeclareAttributeSuppCT( "CommutatorLength", IsNearlyCharacterTable, [] );
DeclareAttributeSuppCT( "Exponent", IsNearlyCharacterTable, [] );
DeclarePropertySuppCT( "IsAbelian", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsCyclic", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsElementaryAbelian", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsFinite", IsNearlyCharacterTable );
DeclareAttributeSuppCT( "IsomorphismTypeInfoFiniteSimpleGroup",
    IsNearlyCharacterTable, [] );
DeclareAttributeSuppCT( "NrConjugacyClasses", IsNearlyCharacterTable, [] );
DeclareAttributeSuppCT( "Size", IsNearlyCharacterTable, [] );


#############################################################################
##
#P  IsAlmostSimpleCharacterTable( <tbl> )
#P  IsMonomialCharacterTable( <tbl> )
#P  IsNilpotentCharacterTable( <tbl> )
#P  IsPerfectCharacterTable( <tbl> )
#P  IsQuasisimpleCharacterTable( <tbl> )
#P  IsSimpleCharacterTable( <tbl> )
#P  IsSolvableCharacterTable( <tbl> )
#P  IsSporadicSimpleCharacterTable( <tbl> )
#P  IsSupersolvableCharacterTable( <tbl> )
##
##  <ManSection>
##  <Heading>Properties for Character Tables</Heading>
##  <Prop Name="IsAlmostSimpleCharacterTable" Arg='tbl'/>
##  <Prop Name="IsMonomialCharacterTable" Arg='tbl'/>
##  <Prop Name="IsNilpotentCharacterTable" Arg='tbl'/>
##  <Prop Name="IsPerfectCharacterTable" Arg='tbl'/>
##  <Prop Name="IsQuasisimpleCharacterTable" Arg='tbl'/>
##  <Prop Name="IsSimpleCharacterTable" Arg='tbl'/>
##  <Prop Name="IsSolvableCharacterTable" Arg='tbl'/>
##  <Prop Name="IsSolubleCharacterTable" Arg='tbl'/>
##  <Prop Name="IsSporadicSimpleCharacterTable" Arg='tbl'/>
##  <Prop Name="IsSupersolvableCharacterTable" Arg='tbl'/>
##  <Prop Name="IsSupersolubleCharacterTable" Arg='tbl'/>
##
##  <Description>
##  These properties belong to the <Q>overloaded</Q> operations,
##  methods for the unqualified properties with argument an ordinary
##  character table are installed in <F>lib/overload.g</F>.
##  </Description>
##  </ManSection>
##
DeclarePropertySuppCT( "IsAlmostSimpleCharacterTable",
    IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsMonomialCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsNilpotentCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsPerfectCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsQuasisimpleCharacterTable",
    IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsSimpleCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsSolvableCharacterTable", IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsSporadicSimpleCharacterTable",
    IsNearlyCharacterTable );
DeclarePropertySuppCT( "IsSupersolvableCharacterTable",
    IsNearlyCharacterTable );

DeclareSynonymAttr( "IsSolubleCharacterTable", IsSolvableCharacterTable );
DeclareSynonymAttr( "IsSupersolubleCharacterTable",
    IsSupersolvableCharacterTable );

InstallTrueMethod( IsAbelian, IsOrdinaryTable and IsCyclic );
InstallTrueMethod( IsAbelian, IsOrdinaryTable and IsElementaryAbelian );
InstallTrueMethod( IsMonomialCharacterTable,
    IsOrdinaryTable and IsSupersolvableCharacterTable and IsFinite );
InstallTrueMethod( IsNilpotentCharacterTable,
    IsOrdinaryTable and IsAbelian );
InstallTrueMethod( IsPerfectCharacterTable,
    IsOrdinaryTable and IsQuasisimpleCharacterTable );
InstallTrueMethod( IsSimpleCharacterTable,
    IsOrdinaryTable and IsSporadicSimpleCharacterTable );
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
##  <ManSection>
##  <Func Name="CharacterTable_IsNilpotentFactor" Arg='tbl, N'/>
##
##  <Description>
##  returns whether the factor group by the normal subgroup described by the
##  classes at positions in the list <A>N</A> is nilpotent.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CharacterTable_IsNilpotentFactor" );


#############################################################################
##
#F  CharacterTable_IsNilpotentNormalSubgroup( <tbl>, <N> )
##
##  <ManSection>
##  <Func Name="CharacterTable_IsNilpotentNormalSubgroup" Arg='tbl, N'/>
##
##  <Description>
##  returns whether the normal subgroup described by the classes at positions
##  in the list <A>N</A> is nilpotent.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CharacterTable_IsNilpotentNormalSubgroup" );


#############################################################################
##
##  6. Attributes and Properties only for Character Tables
##
##  <#GAPDoc Label="[6]{ctbl}">
##  The following three <E>attributes for character tables</E>
##  &ndash;<Ref Attr="OrdersClassRepresentatives"/>,
##  <Ref Attr="SizesCentralizers"/>, and
##  <Ref Attr="SizesConjugacyClasses"/>&ndash; would make sense
##  also for groups but are in fact <E>not</E> used for groups.
##  This is because the values depend on the ordering of conjugacy classes
##  stored as the value of
##  <Ref Attr="ConjugacyClasses" Label="for character tables"/>,
##  and this value may differ for a group and its character table
##  (see <Ref Sect="The Interface between Character Tables and Groups"/>).
##  Note that for character tables, the consistency of attribute values must
##  be guaranteed,
##  whereas for groups, there is no need to impose such a consistency rule.
##  <P/>
##  The other attributes introduced in this section apply only to character
##  tables, not to groups.
##  <#/GAPDoc>
##


#############################################################################
##
#A  OrdersClassRepresentatives( <tbl> )
##
##  <#GAPDoc Label="OrdersClassRepresentatives">
##  <ManSection>
##  <Attr Name="OrdersClassRepresentatives" Arg='tbl'/>
##
##  <Description>
##  is a list of orders of representatives of conjugacy classes of the
##  character table <A>tbl</A>,
##  in the same ordering as the conjugacy classes of <A>tbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "A5" );;
##  gap> OrdersClassRepresentatives( tbl );
##  [ 1, 2, 3, 5, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "OrdersClassRepresentatives",
    IsNearlyCharacterTable, [ "class" ] );


#############################################################################
##
#A  SizesCentralizers( <tbl> )
##
##  <#GAPDoc Label="SizesCentralizers">
##  <ManSection>
##  <Attr Name="SizesCentralizers" Arg='tbl'/>
##  <Attr Name="SizesCentralisers" Arg='tbl'/>
##
##  <Description>
##  is a list that stores at position <M>i</M> the size of the centralizer of
##  any element in the <M>i</M>-th conjugacy class of the character table
##  <A>tbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "A5" );;
##  gap> SizesCentralizers( tbl );
##  [ 60, 4, 3, 5, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "SizesCentralizers", IsNearlyCharacterTable,
    [ "class" ] );

DeclareSynonymAttr( "SizesCentralisers", SizesCentralizers );


#############################################################################
##
#A  SizesConjugacyClasses( <tbl> )
##
##  <#GAPDoc Label="SizesConjugacyClasses">
##  <ManSection>
##  <Attr Name="SizesConjugacyClasses" Arg='tbl'/>
##
##  <Description>
##  is a list that stores at position <M>i</M> the size of the <M>i</M>-th
##  conjugacy class of the character table <A>tbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "A5" );;
##  gap> SizesConjugacyClasses( tbl );
##  [ 1, 15, 20, 12, 12 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "SizesConjugacyClasses", IsNearlyCharacterTable,
    [ "class" ] );


#############################################################################
##
#A  AutomorphismsOfTable( <tbl> )
##
##  <#GAPDoc Label="AutomorphismsOfTable">
##  <ManSection>
##  <Attr Name="AutomorphismsOfTable" Arg='tbl'/>
##
##  <Description>
##  is the permutation group of all column permutations of the character
##  table <A>tbl</A> that leave the set of irreducibles and each power map of
##  <A>tbl</A> invariant (see also&nbsp;<Ref Oper="TableAutomorphisms"/>).
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "Dihedral", 8 );;
##  gap> AutomorphismsOfTable( tbl );
##  Group([ (4,5) ])
##  gap> OrdersClassRepresentatives( tbl );
##  [ 1, 4, 2, 2, 2 ]
##  gap> SizesConjugacyClasses( tbl );
##  [ 1, 2, 1, 2, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "AutomorphismsOfTable", IsNearlyCharacterTable,
    [ "class" ] );
#T AutomorphismGroup( <tbl> ) ??


#############################################################################
##
#A  UnderlyingCharacteristic( <tbl> )
#A  UnderlyingCharacteristic( <psi> )
##
##  <#GAPDoc Label="UnderlyingCharacteristic">
##  <ManSection>
##  <Heading>UnderlyingCharacteristic</Heading>
##  <Attr Name="UnderlyingCharacteristic" Arg='tbl'
##   Label="for a character table"/>
##  <Attr Name="UnderlyingCharacteristic" Arg='psi' Label="for a character"/>
##
##  <Description>
##  For an ordinary character table <A>tbl</A>, the result is <C>0</C>,
##  for a <M>p</M>-modular Brauer table <A>tbl</A>, it is <M>p</M>.
##  The underlying characteristic of a class function <A>psi</A> is equal to
##  that of its underlying character table.
##  <P/>
##  The underlying characteristic must be stored when the table is
##  constructed, there is no method to compute it.
##  <P/>
##  We cannot use the attribute <Ref Attr="Characteristic"/>
##  to denote this, since of course each Brauer character is an element
##  of characteristic zero in the sense of &GAP;
##  (see Chapter&nbsp;<Ref Chap="Class Functions"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "A5" );;
##  gap> UnderlyingCharacteristic( tbl );
##  0
##  gap> UnderlyingCharacteristic( tbl mod 17 );
##  17
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "UnderlyingCharacteristic",
    IsNearlyCharacterTable, [] );


#############################################################################
##
#A  ClassNames( <tbl>[, "ATLAS"] )
#A  CharacterNames( <tbl> )
##
##  <#GAPDoc Label="ClassNames">
##  <ManSection>
##  <Heading>Class Names and Character Names</Heading>
##  <Attr Name="ClassNames" Arg='tbl[, "ATLAS"]'/>
##  <Attr Name="CharacterNames" Arg='tbl'/>
##
##  <Description>
##  <Ref Attr="ClassNames"/> and <Ref Attr="CharacterNames"/> return lists of
##  strings, one for each conjugacy class or irreducible character,
##  respectively, of the character table <A>tbl</A>.
##  These names are used when <A>tbl</A> is displayed.
##  <P/>
##  The default method for <Ref Attr="ClassNames"/> computes class names
##  consisting of the order of an element in the class and at least one
##  distinguishing letter.
##  <P/>
##  The default method for <Ref Attr="CharacterNames"/> returns the list
##  <C>[ "X.1", "X.2", ... ]</C>, whose length is the number of
##  irreducible characters of <A>tbl</A>.
##  <P/>
##  The position of the class with name <A>name</A> in <A>tbl</A> can be
##  accessed as <C><A>tbl</A>.<A>name</A></C>.
##  <P/>
##  When <Ref Attr="ClassNames"/> is called with two arguments, the second
##  being the string <C>"ATLAS"</C>, the class names returned obey the
##  convention used in the &ATLAS; of Finite Groups
##  <Cite Key="CCN85" Where="Chapter 7, Section 5"/>.
##  If one is interested in <Q>relative</Q> class names of almost simple
##  &ATLAS; groups, one can use the function
##  <Ref Func="AtlasClassNames" BookName="atlasrep"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "A5" );;
##  gap> ClassNames( tbl );
##  [ "1a", "2a", "3a", "5a", "5b" ]
##  gap> tbl.2a;
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "ClassNames", IsNearlyCharacterTable,
    [ "class" ] );

DeclareOperation( "ClassNames", [ IsNearlyCharacterTable, IsString ] );

DeclareAttributeSuppCT( "CharacterNames", IsNearlyCharacterTable,
    [ "character" ] );

#############################################################################
##
#F  ColumnCharacterTable( <tbl>,<nr> )
##
##  <ManSection>
##  <Func Name="ColumnCharacterTable" Arg='tbl, nr'/>
##  <Description>
##  returns a column vector that is the <A>nr</A>-th column of the character
##  table <A>tbl</A>.
##  </Description>
##  </ManSection>
DeclareGlobalFunction("ColumnCharacterTable");

#############################################################################
##
#A  ClassParameters( <tbl> )
#A  CharacterParameters( <tbl> )
##
##  <#GAPDoc Label="ClassParameters">
##  <ManSection>
##  <Heading>Class Parameters and Character Parameters</Heading>
##  <Attr Name="ClassParameters" Arg='tbl'/>
##  <Attr Name="CharacterParameters" Arg='tbl'/>
##
##  <Description>
##  The values of these attributes are lists containing a parameter for each
##  conjugacy class or irreducible character, respectively,
##  of the character table <A>tbl</A>.
##  <P/>
##  It depends on <A>tbl</A> what these parameters are,
##  so there is no default to compute class and character parameters.
##  <P/>
##  For example, the classes of symmetric groups can be parametrized by
##  partitions, corresponding to the cycle structures of permutations.
##  Character tables constructed from generic character tables
##  (see the manual of the &GAP; Character Table Library)
##  usually have class and character parameters stored.
##  <P/>
##  If <A>tbl</A> is a <M>p</M>-modular Brauer table such that class
##  parameters are stored in the underlying ordinary table
##  (see&nbsp;<Ref Attr="OrdinaryCharacterTable" Label="for a character table"/>)
##  of <A>tbl</A> then <Ref Attr="ClassParameters"/> returns the sublist of
##  class parameters of the ordinary table, for <M>p</M>-regular classes.
##  <!--
##  <P/>
##  A kind of partial character parameters for finite groups of Lie type
##  is given by the Deligne-Lusztig names of unipotent characters,
##  see&nbsp;<Ref Sect="sec:unipot" BookName="ctbllib"/>.
##  -->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "ClassParameters", IsNearlyCharacterTable,
    [ "class" ] );

DeclareAttributeSuppCT( "CharacterParameters", IsNearlyCharacterTable,
    [ "character" ] );


#############################################################################
##
#A  Identifier( <tbl> )
##
##  <#GAPDoc Label="Identifier:ctbl">
##  <ManSection>
##  <Attr Name="Identifier" Arg='tbl' Label="for character tables"/>
##
##  <Description>
##  is a string that identifies the character table <A>tbl</A> in the current
##  &GAP; session.
##  It is used mainly for class fusions into <A>tbl</A> that are stored on
##  other character tables.
##  For character tables without group,
##  the identifier is also used to print the table;
##  this is the case for library tables,
##  but also for tables that are constructed as direct products, factors
##  etc.&nbsp;involving tables that may or may not store their groups.
##  <P/>
##  The default method for ordinary tables constructs strings of the form
##  <C>"CT<A>n</A>"</C>, where <A>n</A> is a positive integer.
##  <C>LARGEST_IDENTIFIER_NUMBER</C> is a list containing the largest integer
##  <A>n</A> used in the current &GAP; session.
##  <P/>
##  The default method for Brauer tables returns the concatenation of the
##  identifier of the ordinary table, the string <C>"mod"</C>,
##  and the (string of the) underlying characteristic.
##  <P/>
##  <Example><![CDATA[
##  gap> Identifier( CharacterTable( "A5" ) );
##  "A5"
##  gap> tbl:= CharacterTable( Group( () ) );;
##  gap> Identifier( tbl );  Identifier( tbl mod 2 );
##  "CT9"
##  "CT9mod2"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "Identifier", IsNearlyCharacterTable, [] );


#############################################################################
##
#V  LARGEST_IDENTIFIER_NUMBER
##
##  <ManSection>
##  <Var Name="LARGEST_IDENTIFIER_NUMBER"/>
##
##  <Description>
##  list containing the largest identifier of an ordinary character table in
##  the current session.
##  <!--  We have to use a list in order to admit
##    <C>DeclareGlobalVariable</C> and
##    <C>InstallFlushableValue</C>.
##    Note that one must be very careful when reading
##    character tables from files!!
##    (signal warnings then?) -->
##  </Description>
##  </ManSection>
##
BindGlobal( "LARGEST_IDENTIFIER_NUMBER", FixedAtomicList([ 0 ]) );

#############################################################################
##
#M  InfoText( <tbl> )
##
##  <#GAPDoc Label="InfoText_ctbl">
##  <ManSection>
##  <Meth Name="InfoText" Arg='tbl' Label="for character tables"/>
##
##  <Description>
##  is a mutable string with information about the character table
##  <A>tbl</A>.
##  There is no default method to create an info text.
##  <P/>
##  This attribute is used mainly for library tables (see the manual of the
##  &GAP; Character Table Library).
##  Usual parts of the information are the origin of the table,
##  tests it has passed (<C>1.o.r.</C> for the test of orthogonality,
##  <C>pow[<A>p</A>]</C> for the construction of the <A>p</A>-th power map,
##  <C>DEC</C> for the decomposition of ordinary into Brauer characters,
##  <C>TENS</C> for the decomposition of tensor products of irreducibles),
##  and choices made without loss of generality.
##  <P/>
##  <Example><![CDATA[
##  gap> Print( InfoText( CharacterTable( "A5" ) ), "\n" );
##  origin: ATLAS of finite groups, tests: 1.o.r., pow[2,3,5]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Do not call 'DeclareAttributeSuppCT',
##  since the attribute has already been declared for arbitrary GAP objects.
##  A second declaration with requirement 'IsNearlyCharacterTable' would
##  make the installation of a method with 'InstallMethod' impossible.
##
##  We want, however, to add 'InfoText' to the list
##  'SupportedCharacterTableInfo'.
##
Append( SupportedCharacterTableInfo,
    [ InfoText, "InfoText", [ "mutable" ] ] );


#############################################################################
##
#A  InverseClasses( <tbl> )
##
##  <#GAPDoc Label="InverseClasses">
##  <ManSection>
##  <Attr Name="InverseClasses" Arg='tbl'/>
##
##  <Description>
##  For a character table <A>tbl</A>,
##  <Ref Attr="InverseClasses"/> returns the list mapping
##  each conjugacy class to its inverse class.
##  This list can be regarded as <M>(-1)</M>-st power map of <A>tbl</A>
##  (see&nbsp;<Ref Oper="PowerMap"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> InverseClasses( CharacterTable( "A5" ) );
##  [ 1, 2, 3, 4, 5 ]
##  gap> InverseClasses( CharacterTable( "Cyclic", 3 ) );
##  [ 1, 3, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InverseClasses", IsNearlyCharacterTable );


#############################################################################
##
#A  RealClasses( <tbl> ) . . . . . . real-valued classes of a character table
##
##  <#GAPDoc Label="RealClasses">
##  <ManSection>
##  <Attr Name="RealClasses" Arg='tbl'/>
##
##  <Description>
##  <Index Subkey="real">classes</Index>
##  For a character table <A>tbl</A>,
##  <Ref Attr="RealClasses"/> returns the strictly sorted
##  list of positions of classes in <A>tbl</A> that consist of real elements.
##  <P/>
##  An element <M>x</M> is <E>real</E> iff it is conjugate to its inverse
##  <M>x^{{-1}} = x^{{o(x)-1}}</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> RealClasses( CharacterTable( "A5" ) );
##  [ 1, 2, 3, 4, 5 ]
##  gap> RealClasses( CharacterTable( "Cyclic", 3 ) );
##  [ 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "RealClasses", IsNearlyCharacterTable, [ "class" ] );


#############################################################################
##
#O  ClassOrbit( <tbl>, <cc> ) . . . . . . . . .  classes of a cyclic subgroup
##
##  <#GAPDoc Label="ClassOrbit">
##  <ManSection>
##  <Oper Name="ClassOrbit" Arg='tbl, cc'/>
##
##  <Description>
##  is the list of positions of those conjugacy classes
##  of the character table <A>tbl</A> that are Galois conjugate to the
##  <A>cc</A>-th class.
##  That is, exactly the classes at positions given by the list returned by
##  <Ref Oper="ClassOrbit"/> contain generators of the cyclic group generated
##  by an element in the <A>cc</A>-th class.
##  <P/>
##  This information is computed from the power maps of <A>tbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> ClassOrbit( CharacterTable( "A5" ), 4 );
##  [ 4, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ClassOrbit", [ IsNearlyCharacterTable, IsPosInt ] );


#############################################################################
##
#A  ClassRoots( <tbl> ) . . . . . . . . . . . .  nontrivial roots of elements
##
##  <#GAPDoc Label="ClassRoots">
##  <ManSection>
##  <Attr Name="ClassRoots" Arg='tbl'/>
##
##  <Description>
##  For a character table <A>tbl</A>,
##  <Ref Attr="ClassRoots"/> returns a list containing at position <M>i</M>
##  the list of positions of the classes of all nontrivial <M>p</M>-th roots,
##  where <M>p</M> runs over the prime divisors of the
##  <Ref Attr="Size" Label="for a character table"/> value of <A>tbl</A>.
##  <P/>
##  This information is computed from the power maps of <A>tbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> ClassRoots( CharacterTable( "A5" ) );
##  [ [ 2, 3, 4, 5 ], [  ], [  ], [  ], [  ] ]
##  gap> ClassRoots( CharacterTable( "Cyclic", 6 ) );
##  [ [ 3, 4, 5 ], [  ], [ 2 ], [ 2, 6 ], [ 6 ], [  ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassRoots", IsCharacterTable );


#############################################################################
##
##  <#GAPDoc Label="[8]{ctbl}">
##  The following attributes for a character table <A>tbl</A> correspond to
##  attributes for the group <M>G</M> of <A>tbl</A>.
##  But instead of a normal subgroup (or a list of normal subgroups) of
##  <M>G</M>, they return a strictly sorted list of positive integers (or a
##  list of such lists) which are the positions
##  &ndash;relative to the
##  <Ref Attr="ConjugacyClasses" Label="for character tables"/>
##  value of <A>tbl</A>&ndash;
##  of those classes forming the normal subgroup in question.
##  <#/GAPDoc>
##


#############################################################################
##
#A  ClassPositionsOfNormalSubgroups( <ordtbl> )
#A  ClassPositionsOfMaximalNormalSubgroups( <ordtbl> )
#A  ClassPositionsOfMinimalNormalSubgroups( <ordtbl> )
##
##  <#GAPDoc Label="ClassPositionsOfNormalSubgroups">
##  <ManSection>
##  <Attr Name="ClassPositionsOfNormalSubgroups" Arg='ordtbl'/>
##  <Attr Name="ClassPositionsOfMaximalNormalSubgroups" Arg='ordtbl'/>
##  <Attr Name="ClassPositionsOfMinimalNormalSubgroups" Arg='ordtbl'/>
##
##  <Description>
##  correspond to <Ref Attr="NormalSubgroups"/>,
##  <Ref Attr="MaximalNormalSubgroups"/>,
##  <Ref Attr="MinimalNormalSubgroups"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  The entries of the result lists are sorted according to increasing
##  length.
##  (So this total order respects the partial order of normal subgroups
##  given by inclusion.)
##  <P/>
##  <Example><![CDATA[
##  gap> tbls4:= CharacterTable( "Symmetric", 4 );;
##  gap> ClassPositionsOfNormalSubgroups( tbls4 );
##  [ [ 1 ], [ 1, 3 ], [ 1, 3, 4 ], [ 1 .. 5 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassPositionsOfNormalSubgroups", IsOrdinaryTable );

DeclareAttribute( "ClassPositionsOfMaximalNormalSubgroups",
    IsOrdinaryTable );

DeclareAttribute( "ClassPositionsOfMinimalNormalSubgroups",
    IsOrdinaryTable );


#############################################################################
##
#O  ClassPositionsOfAgemo( <ordtbl>, <p> )
##
##  <#GAPDoc Label="ClassPositionsOfAgemo">
##  <ManSection>
##  <Oper Name="ClassPositionsOfAgemo" Arg='ordtbl, p'/>
##
##  <Description>
##  corresponds to <Ref Func="Agemo"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbls4:= CharacterTable( "Symmetric", 4 );;
##  gap> ClassPositionsOfAgemo( tbls4, 2 );
##  [ 1, 3, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ClassPositionsOfAgemo", [ IsOrdinaryTable, IsPosInt ] );


#############################################################################
##
#A  ClassPositionsOfCentre( <ordtbl> )
##
##  <#GAPDoc Label="ClassPositionsOfCentre:ctbl">
##  <ManSection>
##  <Attr Name="ClassPositionsOfCentre" Arg='ordtbl'
##  Label="for a character table"/>
##  <Attr Name="ClassPositionsOfCenter" Arg='ordtbl'
##  Label="for a character table"/>
##
##  <Description>
##  corresponds to <Ref Attr="Centre"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbld8:= CharacterTable( "Dihedral", 8 );;
##  gap> ClassPositionsOfCentre( tbld8 );
##  [ 1, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassPositionsOfCentre", IsOrdinaryTable );

DeclareSynonymAttr( "ClassPositionsOfCenter", ClassPositionsOfCentre );


#############################################################################
##
#A  ClassPositionsOfDirectProductDecompositions( <tbl>[, <nclasses>] )
##
##  <#GAPDoc Label="ClassPositionsOfDirectProductDecompositions">
##  <ManSection>
##  <Attr Name="ClassPositionsOfDirectProductDecompositions"
##        Arg='tbl[, nclasses]'/>
##
##  <Description>
##  Let <A>tbl</A> be the ordinary character table of the group <M>G</M>,
##  say.
##  Called with the only argument <A>tbl</A>,
##  <Ref Attr="ClassPositionsOfDirectProductDecompositions"/> returns
##  the list of all those pairs <M>[ l_1, l_2 ]</M> where <M>l_1</M> and
##  <M>l_2</M> are lists of class positions of normal subgroups <M>N_1</M>,
##  <M>N_2</M> of <M>G</M> such that <M>G</M> is their direct product and
##  <M>|N_1| \leq |N_2|</M> holds.
##  Called with second argument a list <A>nclasses</A> of class positions of
##  a normal subgroup <M>N</M> of <M>G</M>,
##  <Ref Attr="ClassPositionsOfDirectProductDecompositions"/> returns
##  the list of pairs describing the decomposition of <M>N</M> as a direct
##  product of two normal subgroups of <M>G</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "ClassPositionsOfDirectProductDecompositions",
    IsOrdinaryTable, [ "class" ] );

DeclareOperation( "ClassPositionsOfDirectProductDecompositions",
    [ IsOrdinaryTable, IsList ] );


#############################################################################
##
#A  ClassPositionsOfDerivedSubgroup( <ordtbl> )
##
##  <#GAPDoc Label="ClassPositionsOfDerivedSubgroup">
##  <ManSection>
##  <Attr Name="ClassPositionsOfDerivedSubgroup" Arg='ordtbl'/>
##
##  <Description>
##  corresponds to <Ref Attr="DerivedSubgroup"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbld8:= CharacterTable( "Dihedral", 8 );;
##  gap> ClassPositionsOfDerivedSubgroup( tbld8 );
##  [ 1, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassPositionsOfDerivedSubgroup", IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfElementaryAbelianSeries( <ordtbl> )
##
##  <#GAPDoc Label="ClassPositionsOfElementaryAbelianSeries">
##  <ManSection>
##  <Attr Name="ClassPositionsOfElementaryAbelianSeries" Arg='ordtbl'/>
##
##  <Description>
##  corresponds to <Ref Attr="ElementaryAbelianSeries" Label="for a group"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbls4:= CharacterTable( "Symmetric", 4 );;
##  gap> tbla5:= CharacterTable( "A5" );;
##  gap> ClassPositionsOfElementaryAbelianSeries( tbls4 );
##  [ [ 1 .. 5 ], [ 1, 3, 4 ], [ 1, 3 ], [ 1 ] ]
##  gap> ClassPositionsOfElementaryAbelianSeries( tbla5 );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassPositionsOfElementaryAbelianSeries",
    IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfFittingSubgroup( <ordtbl> )
##
##  <#GAPDoc Label="ClassPositionsOfFittingSubgroup">
##  <ManSection>
##  <Attr Name="ClassPositionsOfFittingSubgroup" Arg='ordtbl'/>
##
##  <Description>
##  corresponds to <Ref Attr="FittingSubgroup"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbls4:= CharacterTable( "Symmetric", 4 );;
##  gap> ClassPositionsOfFittingSubgroup( tbls4 );
##  [ 1, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassPositionsOfFittingSubgroup", IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfSolvableRadical( <ordtbl> )
##
##  <#GAPDoc Label="ClassPositionsOfSolvableRadical">
##  <ManSection>
##  <Attr Name="ClassPositionsOfSolvableRadical" Arg='ordtbl'/>
##
##  <Description>
##  corresponds to <Ref Attr="SolvableRadical"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> ClassPositionsOfSolvableRadical( CharacterTable( "2.A5" ) );
##  [ 1, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassPositionsOfSolvableRadical",
    IsOrdinaryTable );


#############################################################################
##
#F  CharacterTable_UpperCentralSeriesFactor( <tbl>, <N> )
##
##  <ManSection>
##  <Func Name="CharacterTable_UpperCentralSeriesFactor" Arg='tbl, N'/>
##
##  <Description>
##  Let <A>tbl</A> the character table of the group <M>G</M>, and <A>N</A>
##  the list of classes contained in the normal subgroup <M>N</M> of
##  <M>G</M>.
##  The upper central series <M>[ Z_1, Z_2, \ldots, Z_n ]</M> of <M>G/N</M>
##  is defined by <M>Z_1 = Z(G/N)</M>,
##  and <M>Z_{i+1} / Z_i = Z( G / Z_i )</M>.
##  <Ref Func="UpperCentralSeriesFactor"/> returns a list
##  <M>[ C_1, C_2, \ldots, C_n ]</M> where <M>C_i</M> is the set of positions
##  of <M>G</M>-conjugacy classes contained in <M>Z_i</M>.
##  <P/>
##  A simpleminded version of the algorithm can be stated as follows.
##  <P/>
##  <M>M_0:= Irr(G);</M>
##  <M>Z_1:= Z(G);</M>
##  <M>i:= 0;</M>
##  repeat
##    <M>i:= i+1;</M>
##    <M>M_i:= { \chi\in M_{i-1} ; Z_i \leq \ker(\chi) };</M>
##    <M>Z_{i+1}:= \bigcap_{\chi\in M_i}} Z(\chi);</M>
##  until <M>Z_i = Z_{i+1};</M>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CharacterTable_UpperCentralSeriesFactor" );


#############################################################################
##
#A  ClassPositionsOfLowerCentralSeries( <tbl> )
##
##  <#GAPDoc Label="ClassPositionsOfLowerCentralSeries">
##  <ManSection>
##  <Attr Name="ClassPositionsOfLowerCentralSeries" Arg='tbl'/>
##
##  <Description>
##  corresponds to <Ref Attr="LowerCentralSeriesOfGroup"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbls4:= CharacterTable( "Symmetric", 4 );;
##  gap> tbld8:= CharacterTable( "Dihedral", 8 );;
##  gap> ClassPositionsOfLowerCentralSeries( tbls4 );
##  [ [ 1 .. 5 ], [ 1, 3, 4 ] ]
##  gap> ClassPositionsOfLowerCentralSeries( tbld8 );
##  [ [ 1 .. 5 ], [ 1, 3 ], [ 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassPositionsOfLowerCentralSeries", IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfUpperCentralSeries( <ordtbl> )
##
##  <#GAPDoc Label="ClassPositionsOfUpperCentralSeries">
##  <ManSection>
##  <Attr Name="ClassPositionsOfUpperCentralSeries" Arg='ordtbl'/>
##
##  <Description>
##  corresponds to <Ref Attr="UpperCentralSeriesOfGroup"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbls4:= CharacterTable( "Symmetric", 4 );;
##  gap> tbld8:= CharacterTable( "Dihedral", 8 );;
##  gap> ClassPositionsOfUpperCentralSeries( tbls4 );
##  [ [ 1 ] ]
##  gap> ClassPositionsOfUpperCentralSeries( tbld8 );
##  [ [ 1, 3 ], [ 1, 2, 3, 4, 5 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassPositionsOfUpperCentralSeries", IsOrdinaryTable );


#############################################################################
##
#A  ClassPositionsOfSolvableResiduum( <ordtbl> )
##
##  <ManSection>
##  <Attr Name="ClassPositionsOfSolvableResiduum" Arg='ordtbl'/>
##  <Attr Name="ClassPositionsOfSolubleResiduum" Arg='ordtbl'/>
##
##  <Description>
##  corresponds to&nbsp;<Ref Attr="SolvableResiduum"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "ClassPositionsOfSolvableResiduum", IsOrdinaryTable );

DeclareSynonymAttr( "ClassPositionsOfSolubleResiduum",
    ClassPositionsOfSolvableResiduum );


#############################################################################
##
#A  ClassPositionsOfSupersolvableResiduum( <ordtbl> )
##
##  <#GAPDoc Label="ClassPositionsOfSupersolvableResiduum">
##  <ManSection>
##  <Attr Name="ClassPositionsOfSupersolvableResiduum" Arg='ordtbl'/>
##
##  <Description>
##  corresponds to <Ref Attr="SupersolvableResiduum"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbls4:= CharacterTable( "Symmetric", 4 );;
##  gap> ClassPositionsOfSupersolvableResiduum( tbls4 );
##  [ 1, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassPositionsOfSupersolvableResiduum", IsOrdinaryTable );


#############################################################################
##
#O  ClassPositionsOfPCore( <ordtbl>, <p> )
##
##  <#GAPDoc Label="ClassPositionsOfPCore">
##  <ManSection>
##  <Oper Name="ClassPositionsOfPCore" Arg='ordtbl, p'/>
##
##  <Description>
##  corresponds to <Ref Oper="PCore"/>
##  for the group of the ordinary character table <A>ordtbl</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbls4:= CharacterTable( "Symmetric", 4 );;
##  gap> ClassPositionsOfPCore( tbls4, 2 );
##  [ 1, 3 ]
##  gap> ClassPositionsOfPCore( tbls4, 3 );
##  [ 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ClassPositionsOfPCore", [ IsOrdinaryTable, IsPosInt ] );


#############################################################################
##
#O  ClassPositionsOfNormalClosure( <ordtbl>, <classes> )
##
##  <#GAPDoc Label="ClassPositionsOfNormalClosure">
##  <ManSection>
##  <Oper Name="ClassPositionsOfNormalClosure" Arg='ordtbl, classes'/>
##
##  <Description>
##  is the sorted list of the positions of all conjugacy classes of the
##  ordinary character table <A>ordtbl</A> that form the normal closure
##  (see&nbsp;<Ref Oper="NormalClosure"/>) of the conjugacy classes at
##  positions in the list <A>classes</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbls4:= CharacterTable( "Symmetric", 4 );;
##  gap> ClassPositionsOfNormalClosure( tbls4, [ 1, 4 ] );
##  [ 1, 3, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="PrimeBlocks">
##  <ManSection>
##  <Oper Name="PrimeBlocks" Arg='ordtbl, p'/>
##  <Oper Name="PrimeBlocksOp" Arg='ordtbl, p'/>
##  <Attr Name="ComputedPrimeBlockss" Arg='tbl'/>
##
##  <Description>
##  For an ordinary character table <A>ordtbl</A> and a prime integer
##  <A>p</A>,
##  <Ref Oper="PrimeBlocks"/> returns a record with the following components.
##  <List>
##  <Mark><C>block</C></Mark>
##  <Item>
##    a list, the value <M>j</M> at position <M>i</M> means that the
##    <M>i</M>-th irreducible character of <A>ordtbl</A> lies in the
##    <M>j</M>-th <A>p</A>-block of <A>ordtbl</A>,
##  </Item>
##  <Mark><C>defect</C></Mark>
##  <Item>
##    a list containing at position <M>i</M> the defect of the <M>i</M>-th
##    block,
##  </Item>
##  <Mark><C>height</C></Mark>
##  <Item>
##    a list containing at position <M>i</M> the height of the <M>i</M>-th
##    irreducible character of <A>ordtbl</A> in its block,
##  </Item>
##  <Mark><C>relevant</C></Mark>
##  <Item>
##    a list of class positions such that only the restriction to these
##    classes need be checked for deciding whether two characters lie
##    in the same block, and
##  </Item>
##  <Mark><C>centralcharacter</C></Mark>
##  <Item>
##    a list containing at position <M>i</M> a list whose values at the
##    positions stored in the component <C>relevant</C> are the values of
##    a central character in the <M>i</M>-th block.
##  </Item>
##  </List>
##  <P/>
##  The components <C>relevant</C> and <C>centralcharacters</C> are
##  used by <Ref Func="SameBlock"/>.
##  <P/>
##  If <Ref InfoClass="InfoCharacterTable"/> has level at least 2,
##  the defects of the blocks and the heights of the characters are printed.
##  <P/>
##  The default method uses the attribute
##  <Ref Attr="ComputedPrimeBlockss"/> for storing the computed value at
##  position <A>p</A>, and calls the operation <Ref Oper="PrimeBlocksOp"/>
##  for computing values that are not yet known.
##  <P/>
##  Two ordinary irreducible characters <M>\chi, \psi</M> of a group <M>G</M>
##  are said to lie in the same <M>p</M>-<E>block</E> if the images of their
##  central characters <M>\omega_{\chi}, \omega_{\psi}</M>
##  (see&nbsp;<Ref Attr="CentralCharacter"/>) under the
##  natural ring epimorphism <M>R \rightarrow R / M</M> are equal,
##  where <M>R</M> denotes the ring of algebraic integers in the complex
##  number field, and <M>M</M> is a maximal ideal in <M>R</M> with
##  <M>pR \subseteq M</M>.
##  (The distribution to <M>p</M>-blocks is in fact independent of the choice
##  of <M>M</M>, see&nbsp;<Cite Key="Isa76"/>.)
##  <P/>
##  For <M>|G| = p^a m</M> where <M>p</M> does not divide <M>m</M>,
##  the <E>defect</E> of a block is the integer <M>d</M> such that
##  <M>p^{{a-d}}</M> is the largest power of <M>p</M> that divides the degrees
##  of all characters in the block.
##  <P/>
##  The <E>height</E> of a character <M>\chi</M> in the block is defined as
##  the largest exponent <M>h</M> for which <M>p^h</M> divides
##  <M>\chi(1) / p^{{a-d}}</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "L3(2)" );;
##  gap> pbl:= PrimeBlocks( tbl, 2 );
##  rec( block := [ 1, 1, 1, 1, 1, 2 ],
##    centralcharacter := [ [ ,, 56,, 24 ], [ ,, -7,, 3 ] ],
##    defect := [ 3, 0 ], height := [ 0, 0, 0, 1, 0, 0 ],
##    relevant := [ 3, 5 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
#F  SameBlock( <p>, <omega1>, <omega2>, <relevant> )
##
##  <#GAPDoc Label="SameBlock">
##  <ManSection>
##  <Func Name="SameBlock" Arg='p, omega1, omega2, relevant'/>
##
##  <Description>
##  Let <A>p</A> be a prime integer, <A>omega1</A> and <A>omega2</A> be two
##  central characters (or their values lists) of a character table,
##  and <A>relevant</A> be a list of positions as is stored in the component
##  <C>relevant</C> of a record returned by <Ref Oper="PrimeBlocks"/>.
##  <P/>
##  <Ref Func="SameBlock"/> returns <K>true</K> if <A>omega1</A> and
##  <A>omega2</A> are equal modulo any maximal ideal in the ring of complex
##  algebraic integers containing the ideal spanned by <A>p</A>,
##  and <K>false</K> otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> omega:= List( Irr( tbl ), CentralCharacter );;
##  gap> SameBlock( 2, omega[1], omega[2], pbl.relevant );
##  true
##  gap> SameBlock( 2, omega[1], omega[6], pbl.relevant );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SameBlock" );


#############################################################################
##
#A  BlocksInfo( <modtbl> )
##
##  <#GAPDoc Label="BlocksInfo">
##  <ManSection>
##  <Attr Name="BlocksInfo" Arg='modtbl'/>
##
##  <Description>
##  For a Brauer character table <A>modtbl</A>, the value of
##  <Ref Attr="BlocksInfo"/> is a list of (mutable) records,
##  the <M>i</M>-th entry containing information about the <M>i</M>-th block.
##  Each record has the following components.
##  <List>
##  <Mark><C>defect</C></Mark>
##  <Item>
##    the defect of the block,
##  </Item>
##  <Mark><C>ordchars</C></Mark>
##  <Item>
##    the list of positions of the ordinary characters that belong to the
##    block, relative to
##    <C>Irr( OrdinaryCharacterTable( <A>modtbl</A> ) )</C>,
##  </Item>
##  <Mark><C>modchars</C></Mark>
##  <Item>
##    the list of positions of the Brauer characters that belong to the
##    block, relative to <C>IBr( <A>modtbl</A> )</C>.
##  </Item>
##  </List>
##  Optional components are
##  <List>
##  <Mark><C>basicset</C></Mark>
##  <Item>
##    a list of positions of ordinary characters in the block whose
##    restriction to <A>modtbl</A> is maximally linearly independent,
##    relative to <C>Irr( OrdinaryCharacterTable( <A>modtbl</A> ) )</C>,
##  </Item>
##  <Mark><C>decmat</C></Mark>
##  <Item>
##    the decomposition matrix of the block,
##    it is stored automatically when <Ref Oper="DecompositionMatrix"/>
##    is called for the block,
##  </Item>
##  <Mark><C>decinv</C></Mark>
##  <Item>
##    inverse of the decomposition matrix of the block, restricted to the
##    ordinary characters described by <C>basicset</C>,
##  </Item>
##  <Mark><C>brauertree</C></Mark>
##  <Item>
##    a list that describes the Brauer tree of the block,
##    in the case that the block is of defect <M>1</M>.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> BlocksInfo( CharacterTable( "L3(2)" ) mod 2 );
##  [ rec( basicset := [ 1, 2, 3 ],
##        decinv := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ],
##        defect := 3, modchars := [ 1, 2, 3 ],
##        ordchars := [ 1, 2, 3, 4, 5 ] ),
##    rec( basicset := [ 6 ], decinv := [ [ 1 ] ], defect := 0,
##        modchars := [ 4 ], ordchars := [ 6 ] ) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "BlocksInfo", IsNearlyCharacterTable, "mutable",
    [ "character" ] );


#############################################################################
##
#O  DecompositionMatrix( <modtbl>[, <blocknr>] )
##
##  <#GAPDoc Label="DecompositionMatrix">
##  <ManSection>
##  <Oper Name="DecompositionMatrix" Arg='modtbl[, blocknr]'/>
##
##  <Description>
##  Let <A>modtbl</A> be a Brauer character table.
##  <P/>
##  Called with one argument, <Ref Oper="DecompositionMatrix"/> returns the
##  decomposition matrix of <A>modtbl</A>, where the rows and columns are
##  indexed by the irreducible characters of the ordinary character table of
##  <A>modtbl</A> and the irreducible characters of <A>modtbl</A>,
##  respectively,
##  <P/>
##  Called with two arguments, <Ref Oper="DecompositionMatrix"/> returns the
##  decomposition matrix of the block of <A>modtbl</A> with number
##  <A>blocknr</A>;
##  the matrix is stored as value of the <C>decmat</C> component of the
##  <A>blocknr</A>-th entry of the <Ref Attr="BlocksInfo"/> list of
##  <A>modtbl</A>.
##  <P/>
##  An ordinary irreducible character is in block <M>i</M> if and only if all
##  characters before the first character of the same block lie in <M>i-1</M>
##  different blocks.
##  An irreducible Brauer character is in block <M>i</M> if it has nonzero
##  scalar product with an ordinary irreducible character in block <M>i</M>.
##  <P/>
##  <Ref Oper="DecompositionMatrix"/> is based on the more general function
##  <Ref Oper="Decomposition"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> modtbl:= CharacterTable( "L3(2)" ) mod 2;
##  BrauerTable( "L3(2)", 2 )
##  gap> DecompositionMatrix( modtbl );
##  [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 1, 1, 0 ],
##    [ 1, 1, 1, 0 ], [ 0, 0, 0, 1 ] ]
##  gap> DecompositionMatrix( modtbl, 1 );
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ], [ 0, 1, 1 ], [ 1, 1, 1 ] ]
##  gap> DecompositionMatrix( modtbl, 2 );
##  [ [ 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DecompositionMatrix", IsBrauerTable );
DeclareOperation( "DecompositionMatrix", [ IsBrauerTable, IsPosInt ] );


#############################################################################
##
#F  LaTeXStringDecompositionMatrix( <modtbl>[, <blocknr>][, <options>] )
##
##  <#GAPDoc Label="LaTeXStringDecompositionMatrix">
##  <Index Subkey="for a decomposition matrix">LaTeX</Index>
##  <ManSection>
##  <Func Name="LaTeXStringDecompositionMatrix"
##   Arg='modtbl[, blocknr][, options]'/>
##
##  <Description>
##  is a string that contains La&TeX; code to print a decomposition matrix
##  (see&nbsp;<Ref Oper="DecompositionMatrix"/>) nicely.
##  <P/>
##  The optional argument <A>options</A>, if present, must be a record with
##  components
##  <C>phi</C>, <C>chi</C> (strings used in each label for columns and rows),
##  <C>collabels</C>, <C>rowlabels</C> (subscripts for the labels).
##  The defaults for <C>phi</C> and <C>chi</C> are
##  <C>"{\\tt Y}"</C> and <C>"{\\tt X}"</C>,
##  the defaults for <C>collabels</C> and <C>rowlabels</C> are the lists of
##  positions of the Brauer characters and ordinary characters in the
##  respective lists of irreducibles in the character tables.
##  <P/>
##  The optional components <C>nrows</C> and <C>ncols</C> denote the maximal
##  number of rows and columns per array;
##  if they are present then each portion of <C>nrows</C> rows and
##  <C>ncols</C> columns forms an array of its own which is enclosed in
##  <C>\[</C>, <C>\]</C>.
##  <P/>
##  If the component <C>decmat</C> is bound in <A>options</A> then it must be
##  the decomposition matrix in question, in this case the matrix is not
##  computed from the information in <A>modtbl</A>.
##  <P/>
##  For those character tables from the &GAP; table library that belong to
##  the &ATLAS; of Finite Groups&nbsp;<Cite Key="CCN85"/>,
##  <Ref Func="AtlasLabelsOfIrreducibles" BookName="ctbllib"/> constructs
##  character labels that are compatible with those used in the &ATLAS;
##  (see&nbsp;<Ref Sect="ATLAS Tables" BookName="ctbllib"/>
##  in the manual of the &GAP; Character Table Library).
##  <P/>
##  <Example><![CDATA[
##  gap> modtbl:= CharacterTable( "L3(2)" ) mod 2;;
##  gap> Print( LaTeXStringDecompositionMatrix( modtbl, 1 ) );
##  \[
##  \begin{array}{r|rrr} \hline
##   & {\tt Y}_{1}
##   & {\tt Y}_{2}
##   & {\tt Y}_{3}
##   \rule[-7pt]{0pt}{20pt} \\ \hline
##  {\tt X}_{1} & 1 & . & . \rule[0pt]{0pt}{13pt} \\
##  {\tt X}_{2} & . & 1 & . \\
##  {\tt X}_{3} & . & . & 1 \\
##  {\tt X}_{4} & . & 1 & 1 \\
##  {\tt X}_{5} & 1 & 1 & 1 \rule[-7pt]{0pt}{5pt} \\
##  \hline
##  \end{array}
##  \]
##  gap> options:= rec( phi:= "\\varphi", chi:= "\\chi" );;
##  gap> Print( LaTeXStringDecompositionMatrix( modtbl, 1, options ) );
##  \[
##  \begin{array}{r|rrr} \hline
##   & \varphi_{1}
##   & \varphi_{2}
##   & \varphi_{3}
##   \rule[-7pt]{0pt}{20pt} \\ \hline
##  \chi_{1} & 1 & . & . \rule[0pt]{0pt}{13pt} \\
##  \chi_{2} & . & 1 & . \\
##  \chi_{3} & . & . & 1 \\
##  \chi_{4} & . & 1 & 1 \\
##  \chi_{5} & 1 & 1 & 1 \rule[-7pt]{0pt}{5pt} \\
##  \hline
##  \end{array}
##  \]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LaTeXStringDecompositionMatrix" );


#############################################################################
##
##  7. Other Operations for Character Tables
##
##  <#GAPDoc Label="[9]{ctbl}">
##  In the following, we list operations for character tables that are not
##  attributes.
##  <#/GAPDoc>
##


#############################################################################
##
#O  Index( <tbl>, <subtbl> )
#O  IndexOp( <tbl>, <subtbl> )
#O  IndexNC( <tbl>, <subtbl> )
##
##  <#GAPDoc Label="Index!for_character_tables">
##  <ManSection>
##  <Oper Name="Index" Arg='tbl, subtbl' Label="for two character tables"/>
##
##  <Description>
##  For two character tables <A>tbl</A> and <A>subtbl</A>,
##  <Ref Oper="Index" Label="for two character tables"/> returns the
##  quotient of the <Ref Attr="Size" Label="for a character table"/> values
##  of <A>tbl</A> and <A>subtbl</A>.
##  The containment of the underlying groups of <A>subtbl</A> and <A>tbl</A>
##  is <E>not</E> checked;
##  so the distinction between
##  <Ref Oper="Index" Label="for a group and its subgroup"/>
##  and <Ref Oper="IndexNC" Label="for a group and its subgroup"/>
##  is not made for character tables.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Index",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );
DeclareOperation( "IndexOp",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );
DeclareOperation( "IndexNC",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );


#############################################################################
##
#O  IsPSolvableCharacterTable( <tbl>, <p> )
#O  IsPSolvableCharacterTableOp( <tbl>, <p> )
#A  ComputedIsPSolvableCharacterTables( <tbl> )
##
##  <#GAPDoc Label="IsPSolvableCharacterTable">
##  <ManSection>
##  <Oper Name="IsPSolvableCharacterTable" Arg='tbl, p'/>
##  <Oper Name="IsPSolubleCharacterTable" Arg='tbl, p'/>
##  <Oper Name="IsPSolvableCharacterTableOp" Arg='tbl, p'/>
##  <Oper Name="IsPSolubleCharacterTableOp" Arg='tbl, p'/>
##  <Attr Name="ComputedIsPSolvableCharacterTables" Arg='tbl'/>
##  <Attr Name="ComputedIsPSolubleCharacterTables" Arg='tbl'/>
##
##  <Description>
##  <Ref Oper="IsPSolvableCharacterTable"/> for the ordinary character table
##  <A>tbl</A> corresponds to <Ref Oper="IsPSolvable"/> for the group of
##  <A>tbl</A>, <A>p</A> must be either a prime integer or <C>0</C>.
##  <P/>
##  The default method uses the attribute
##  <Ref Attr="ComputedIsPSolvableCharacterTables"/> for storing the computed
##  value at position <A>p</A>, and calls the operation
##  <Ref Oper="IsPSolvableCharacterTableOp"/>
##  for computing values that are not yet known.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "Sz(8)" );;
##  gap> IsPSolvableCharacterTable( tbl, 2 );
##  false
##  gap> IsPSolvableCharacterTable( tbl, 3 );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsPSolvableCharacterTable", [ IsOrdinaryTable, IsInt ] );
DeclareOperation( "IsPSolvableCharacterTableOp",
    [ IsOrdinaryTable, IsInt ] );
DeclareAttributeSuppCT( "ComputedIsPSolvableCharacterTables",
    IsOrdinaryTable, "mutable", [] );

DeclareSynonym( "IsPSolubleCharacterTable", IsPSolvableCharacterTable );
DeclareSynonym( "IsPSolubleCharacterTableOp", IsPSolvableCharacterTableOp );
DeclareSynonym( "ComputedIsPSolubleCharacterTables",
    ComputedIsPSolvableCharacterTables );


#############################################################################
##
#F  IsClassFusionOfNormalSubgroup( <subtbl>, <fus>, <tbl> )
##
##  <#GAPDoc Label="IsClassFusionOfNormalSubgroup">
##  <ManSection>
##  <Func Name="IsClassFusionOfNormalSubgroup" Arg='subtbl, fus, tbl'/>
##
##  <Description>
##  For two ordinary character tables <A>tbl</A> and <A>subtbl</A> of a group
##  <M>G</M> and its subgroup <M>U</M>
##  and a list <A>fus</A> of positive integers that describes the class
##  fusion of <M>U</M> into <M>G</M>,
##  <Ref Func="IsClassFusionOfNormalSubgroup"/> returns <K>true</K>
##  if <M>U</M> is a normal subgroup of <M>G</M>, and <K>false</K> otherwise.
##  <P/>
##  <Example><![CDATA[
##  gap> tblc2:= CharacterTable( "Cyclic", 2 );;
##  gap> tbld8:= CharacterTable( "Dihedral", 8 );;
##  gap> fus:= PossibleClassFusions( tblc2, tbld8 );
##  [ [ 1, 3 ], [ 1, 4 ], [ 1, 5 ] ]
##  gap> List(fus, map -> IsClassFusionOfNormalSubgroup(tblc2, map, tbld8));
##  [ true, false, false ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsClassFusionOfNormalSubgroup" );


#############################################################################
##
#O  Indicator( <tbl>[, <characters>], <n> )
#O  IndicatorOp( <tbl>, <characters>, <n> )
#A  ComputedIndicators( <tbl> )
##
##  <#GAPDoc Label="Indicator">
##  <ManSection>
##  <Oper Name="Indicator" Arg='tbl[, characters], n'/>
##  <Oper Name="IndicatorOp" Arg='tbl, characters, n'/>
##  <Attr Name="ComputedIndicators" Arg='tbl'/>
##
##  <Description>
##  If <A>tbl</A> is an ordinary character table then <Ref Oper="Indicator"/>
##  returns the list of <A>n</A>-th Frobenius-Schur indicators of the
##  characters in the list <A>characters</A>;
##  the default of <A>characters</A> is <C>Irr( <A>tbl</A> )</C>.
##  <P/>
##  The <M>n</M>-th Frobenius-Schur indicator <M>\nu_n(\chi)</M> of an
##  ordinary character <M>\chi</M> of the group <M>G</M> is given by
##  <M>\nu_n(\chi) = ( \sum_{{g \in G}} \chi(g^n) ) / |G|</M>.
##  <P/>
##  If <A>tbl</A> is a Brauer table in characteristic <M> \neq 2</M> and
##  <M><A>n</A> = 2</M> then <Ref Oper="Indicator"/> returns the second
##  indicator.
##  <P/>
##  The default method uses the attribute
##  <Ref Attr="ComputedIndicators"/> for storing the computed value at
##  position <A>n</A>, and calls the operation <Ref Oper="IndicatorOp"/> for
##  computing values that are not yet known.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "L3(2)" );;
##  gap> Indicator( tbl, 2 );
##  [ 1, 0, 0, 1, 1, 1 ]
##  ]]></Example>
##  <P/>
##  In nonzero characteristic <M>p</M>, the Frobenius-Schur indicator is
##  defined only for irreducible characters.
##  For odd <M>p</M>, the indicator is computed using the Thompson-Willems
##  Theorem <Cite Key="Tho86" Where="theorem on p. 227"/>.
##  For <M>p = 2</M>, in general the indicator cannot be computed from the
##  given character tables, here the following necessary conditions are used.
##  <P/>
##  <List>
##  <Item>
##    The trivial character has indicator <M>1</M>.
##  </Item>
##  <Item>
##    The indicator is <M>0</M> if and only if the character is not
##    real-valued.
##  </Item>
##  <Item>
##    Real characters outside the principal block (the <M>2</M>-block that
##    contains the trivial character, see <Ref Oper="PrimeBlocks"/>)
##    have indicator <M>1</M>.
##  </Item>
##  <Item>
##    By <Cite Key="GW95" Where="Lemma 1.2"/>, any real constituent with odd
##    multiplicity in the <M>2</M>-modular restriction of an ordinary
##    irreducible character with indicator <M>1</M> has indicator <M>1</M>,
##    provided that the trivial character is not a constituent of the
##    restriction.
##  </Item>
##  </List>
##  <P/>
##  For each <M>2</M>-modular Brauer characters where these conditions are
##  not sufficient to determine the indicator, an unknown value
##  (see <Ref Oper="Unknown"/>) is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="NrPolyhedralSubgroups">
##  <ManSection>
##  <Func Name="NrPolyhedralSubgroups" Arg='tbl, c1, c2, c3'/>
##
##  <Description>
##  <Index Subkey="polyhedral">subgroups</Index>
##  returns the number and isomorphism type of polyhedral subgroups of the
##  group with ordinary character table <A>tbl</A> which are generated by an
##  element <M>g</M> of class <A>c1</A> and an element <M>h</M> of class
##  <A>c2</A> with the property that the product <M>gh</M> lies in class
##  <A>c3</A>.
##  <P/>
##  According to <Cite Key="NPP84" Where="p. 233"/>, the number of
##  polyhedral subgroups of isomorphism type <M>V_4</M>, <M>D_{2n}</M>,
##  <M>A_4</M>, <M>S_4</M>, and <M>A_5</M> can be derived from the class
##  multiplication coefficient
##  (see&nbsp;<Ref Oper="ClassMultiplicationCoefficient"
##  Label="for character tables"/>)
##  and the number of Galois
##  conjugates of a class (see&nbsp;<Ref Oper="ClassOrbit"/>).
##  <P/>
##  The classes <A>c1</A>, <A>c2</A> and <A>c3</A> in the parameter list must
##  be ordered according to the order of the elements in these classes.
##  If elements in class <A>c1</A> and <A>c2</A> do not generate a
##  polyhedral group then <K>fail</K> is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> NrPolyhedralSubgroups( tbl, 2, 2, 4 );
##  rec( number := 21, type := "D8" )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NrPolyhedralSubgroups" );


#############################################################################
##
#O  ClassMultiplicationCoefficient( <tbl>, <i>, <j>, <k> )
##
##  <#GAPDoc Label="ClassMultiplicationCoefficient:ctbl">
##  <ManSection>
##  <Oper Name="ClassMultiplicationCoefficient" Arg='tbl, i, j, k'
##   Label="for character tables"/>
##
##  <Description>
##  <Index Subkey="for character tables" Key="ClassMultiplicationCoefficient">
##  <C>ClassMultiplicationCoefficient</C></Index>
##  <Index>class multiplication coefficient</Index>
##  <Index>structure constant</Index>
##  returns the class multiplication coefficient of the classes <A>i</A>,
##  <A>j</A>, and <A>k</A> of the group <M>G</M> with ordinary character
##  table <A>tbl</A>.
##  <P/>
##  The class multiplication coefficient <M>c_{{i,j,k}}</M> of the classes
##  <A>i</A>, <A>j</A>, <A>k</A> equals the number of pairs <M>(x,y)</M> of
##  elements <M>x, y \in G</M> such that <M>x</M> lies in class <A>i</A>,
##  <M>y</M> lies in class <A>j</A>,
##  and their product <M>xy</M> is a fixed element of class <A>k</A>.
##  <P/>
##  In the center of the group algebra of <M>G</M>, these numbers are found
##  as coefficients of the decomposition of the product of two class sums
##  <M>K_i</M> and <M>K_j</M> into class sums:
##  <Display Mode="M">
##  K_i K_j = \sum_k c_{ijk} K_k .
##  </Display>
##  Given the character table of a finite group <M>G</M>,
##  whose classes  are <M>C_1, \ldots, C_r</M> with representatives
##  <M>g_i \in C_i</M>,
##  the class multiplication coefficient <M>c_{ijk}</M> can be computed
##  with the following formula:
##  <Display Mode="M">
##  c_{ijk} = |C_i| \cdot |C_j| / |G| \cdot
##  \sum_{{\chi \in Irr(G)}}
##  \chi(g_i) \chi(g_j) \chi(g_k^{{-1}}) / \chi(1).
##  </Display>
##  <P/>
##  On the other hand the knowledge of the class multiplication coefficients
##  admits the computation of the irreducible characters of <M>G</M>,
##  see&nbsp;<Ref Attr="IrrDixonSchneider"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ClassMultiplicationCoefficient",
    [ IsOrdinaryTable, IsPosInt, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  MatClassMultCoeffsCharTable( <tbl>, <i> )
##
##  <#GAPDoc Label="MatClassMultCoeffsCharTable">
##  <ManSection>
##  <Func Name="MatClassMultCoeffsCharTable" Arg='tbl, i'/>
##
##  <Description>
##  <Index>structure constant</Index>
##  <Index>class multiplication coefficient</Index>
##  <P/>
##  For an ordinary character table <A>tbl</A> and a class position <A>i</A>,
##  <C>MatClassMultCoeffsCharTable</C> returns the matrix
##  <M>[ a_{ijk} ]_{{j,k}}</M> of structure constants
##  (see&nbsp;<Ref Oper="ClassMultiplicationCoefficient"
##  Label="for character tables"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "L3(2)" );;
##  gap> ClassMultiplicationCoefficient( tbl, 2, 2, 4 );
##  4
##  gap> ClassStructureCharTable( tbl, [ 2, 2, 4 ] );
##  168
##  gap> ClassStructureCharTable( tbl, [ 2, 2, 2, 4 ] );
##  1848
##  gap> MatClassMultCoeffsCharTable( tbl, 2 );
##  [ [ 0, 1, 0, 0, 0, 0 ], [ 21, 4, 3, 4, 0, 0 ], [ 0, 8, 6, 8, 7, 7 ],
##    [ 0, 8, 6, 1, 7, 7 ], [ 0, 0, 3, 4, 0, 7 ], [ 0, 0, 3, 4, 7, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MatClassMultCoeffsCharTable" );


#############################################################################
##
#F  ClassStructureCharTable( <tbl>, <classes> ) . . gener. class mult. coeff.
##
##  <#GAPDoc Label="ClassStructureCharTable">
##  <ManSection>
##  <Func Name="ClassStructureCharTable" Arg='tbl, classes'/>
##
##  <Description>
##  <Index>class multiplication coefficient</Index>
##  <Index>structure constant</Index>
##  <P/>
##  returns the so-called class structure of the classes in the list
##  <A>classes</A>, for the character table <A>tbl</A> of the group <M>G</M>.
##  The length of <A>classes</A> must be at least 2.
##  <P/>
##  Let <M>C = (C_1, C_2, \ldots, C_n)</M> denote the <M>n</M>-tuple
##  of conjugacy classes of <M>G</M> that are indexed by <A>classes</A>.
##  The class structure <M>n(C)</M> equals
##  the number of <M>n</M>-tuples <M>(g_1, g_2, \ldots, g_n)</M> of elements
##  <M>g_i \in C_i</M> with <M>g_1 g_2 \cdots g_n = 1</M>.
##  Note the difference to the definition of the class multiplication
##  coefficients in
##  <Ref Oper="ClassMultiplicationCoefficient"
##  Label="for character tables"/>.
##  <P/>
##  <M>n(C_1, C_2, \ldots, C_n)</M> is computed using the formula
##  <Display Mode="M">
##  n(C_1, C_2, \ldots, C_n) =
##  |C_1| |C_2| \cdots |C_n| / |G| \cdot
##  \sum_{{\chi \in Irr(G)}}
##  \chi(g_1) \chi(g_2) \cdots \chi(g_n) / \chi(1)^{{n-2}} .
##  </Display>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ClassStructureCharTable" );


#############################################################################
##
##  8. Creating Character Tables
##
##  <#GAPDoc Label="[10]{ctbl}">
##  <Index>tables</Index>
##  <Index>character tables</Index>
##  <Index>library tables</Index>
##  <Index Subkey="access to">character tables</Index>
##  <Index Subkey="calculate">character tables</Index>
##  <Index Subkey="of groups">character tables</Index>
##  There are in general five different ways to get a character table in
##  &GAP;.
##  You can
##  <P/>
##  <Enum>
##  <Item>
##    compute the table from a group,
##  </Item>
##  <Item>
##    read a file that contains the table data,
##  </Item>
##  <Item>
##    construct the table using generic formulae,
##  </Item>
##  <Item>
##    derive it from known character tables, or
##  </Item>
##  <Item>
##    combine partial information about conjugacy classes, power maps
##    of the group in question, and about (character tables of) some
##    subgroups and supergroups.
##  </Item>
##  </Enum>
##  <P/>
##  In 1., the computation of the irreducible characters is the hardest part;
##  the different algorithms available for this are described
##  in&nbsp;<Ref Sect="Computing the Irreducible Characters of a Group"/>.
##  Possibility 2.&nbsp;is used for the character tables in the
##  &GAP; Character  Table Library, see the manual of this library.
##  Generic character tables &ndash;as addressed by 3.&ndash; are described
##  in&nbsp;<Ref Chap="Generic Character Tables" BookName="ctbllib"/>.
##  Several occurrences of 4.&nbsp;are described
##  in&nbsp;<Ref Sect="Constructing Character Tables from Others"/>.
##  The last of the above possibilities
##  <E>is currently not supported and will be described in a chapter of its
##  own when it becomes available</E>.
##  <P/>
##  The operation <Ref Oper="CharacterTable" Label="for a group"/>
##  can be used for the cases 1. to 3.
##  <#/GAPDoc>
##


#############################################################################
##
#O  CharacterTable( <G> ) . . . . . . . . . . ordinary char. table of a group
#O  CharacterTable( <G>, <p> )  . . . . . characteristic <p> table of a group
#O  CharacterTable( <ordtbl>, <p> )
#O  CharacterTable( <name>[, <param>] ) . . . . library table with given name
##
##  <#GAPDoc Label="CharacterTable">
##  <ManSection>
##  <Heading>CharacterTable</Heading>
##  <Oper Name="CharacterTable" Arg='G[, p]' Label="for a group"/>
##  <Oper Name="CharacterTable" Arg='ordtbl, p'
##        Label="for an ordinary character table"/>
##  <Oper Name="CharacterTable" Arg='name[, param]' Label="for a string"/>
##
##  <Description>
##  Called with a group <A>G</A>,
##  <Ref Oper="CharacterTable" Label="for a group"/> calls the
##  attribute <Ref Attr="OrdinaryCharacterTable" Label="for a group"/>.
##  Called with first argument a group <A>G</A> or an ordinary character
##  table <A>ordtbl</A>, and second argument a prime <A>p</A>,
##  <Ref Oper="CharacterTable" Label="for a group"/> calls the operation
##  <Ref Oper="BrauerTable" Label="for a group, and a prime integer"/>.
##  <P/>
##  Called with a string <A>name</A> and perhaps optional parameters
##  <A>param</A>, <Ref Oper="CharacterTable" Label="for a string"/>
##  tries to access a character table from the &GAP; Character Table Library.
##  See the manual of the &GAP; package <Package>CTblLib</Package> for an
##  overview of admissible arguments.
##  An error is signalled if this &GAP; package is not loaded in this case.
##  <P/>
##  Probably the most interesting information about the character table is
##  its list of irreducibles, which can be accessed as the value of the
##  attribute <Ref Attr="Irr" Label="for a character table"/>.
##  If the argument of <Ref Oper="CharacterTable" Label="for a string"/> is a
##  string <A>name</A> then the irreducibles are just read from the library
##  file, therefore the returned table stores them already.
##  However, if <Ref Oper="CharacterTable" Label="for a group"/> is called
##  with a group <A>G</A> or with an ordinary character table <A>ordtbl</A>,
##  the irreducible characters are <E>not</E> computed by
##  <Ref Oper="CharacterTable" Label="for a group"/>.
##  They are only computed when the
##  <Ref Attr="Irr" Label="for a character table"/> value is accessed for
##  the first time, for example when <Ref Oper="Display"/> is called for the
##  table (see&nbsp;<Ref Sect="Printing Character Tables"/>).
##  This means for example that
##  <Ref Oper="CharacterTable" Label="for a group"/> returns its
##  result very quickly, and the first call of <Ref Oper="Display"/> for this
##  table may take some time because the irreducible characters must be
##  computed at that time before they can be displayed together with other
##  information stored on the character table.
##  The value of the filter <C>HasIrr</C> indicates whether the irreducible
##  characters have been computed already.
##  <P/>
##  The reason why <Ref Oper="CharacterTable" Label="for a group"/> does not
##  compute the irreducible characters is that there are situations where one
##  only needs the <Q>table head</Q>, that is, the information about
##  class lengths, power maps etc., but not the irreducibles.
##  For example, if one wants to inspect permutation characters of a group
##  then all one has to do is to induce the trivial characters of subgroups
##  one is interested in; for that, only class lengths and the class fusion
##  are needed.
##  Or if one wants to compute the Molien series
##  (see&nbsp;<Ref Func="MolienSeries"/>) for a given complex matrix group,
##  the irreducible characters of this group are in general of no interest.
##  <P/>
##  For details about different algorithms to compute the irreducible
##  characters,
##  see&nbsp;<Ref Sect="Computing the Irreducible Characters of a Group"/>.
##  <P/>
##  If the group <A>G</A> is given as an argument,
##  <Ref Oper="CharacterTable" Label="for a group"/> accesses the conjugacy
##  classes of <A>G</A> and therefore causes that these classes are
##  computed if they were not yet stored
##  (see <Ref Sect="The Interface between Character Tables and Groups"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="BrauerTable">
##  <ManSection>
##  <Heading>BrauerTable</Heading>
##  <Oper Name="BrauerTable" Arg='ordtbl, p'
##        Label="for a character table, and a prime integer"/>
##  <Oper Name="BrauerTable" Arg='G, p'
##        Label="for a group, and a prime integer"/>
##  <Oper Name="BrauerTableOp" Arg='ordtbl, p'/>
##  <Attr Name="ComputedBrauerTables" Arg='ordtbl'/>
##
##  <Description>
##  Called with an ordinary character table <A>ordtbl</A> or a
##  group <A>G</A>,
##  <Ref Oper="BrauerTable" Label="for a group, and a prime integer"/>
##  returns its <A>p</A>-modular
##  character table if &GAP; can compute this table, and <K>fail</K>
##  otherwise.
##  <P/>
##  The <A>p</A>-modular table can be computed in the following cases.
##  <P/>
##  <List>
##  <Item>
##    The group is <A>p</A>-solvable (see <Ref Oper="IsPSolvable"/>,
##    apply the Fong-Swan Theorem);
##  </Item>
##  <Item>
##    the Sylow <A>p</A>-subgroup of <A>G</A> is cyclic,
##    and all <A>p</A>-modular Brauer characters of <A>G</A>
##    lift to ordinary characters
##    (note that this situation can be detected from the ordinary
##    character table of <A>G</A>);
##  </Item>
##  <Item>
##    the table <A>ordtbl</A> stores information how it was constructed from
##    other tables (as a direct product or as an isoclinic variant,
##    for example),
##    and the Brauer tables of the source tables can be computed;
##  </Item>
##  <Item>
##    <A>ordtbl</A> is a table from the &GAP; character table library
##    for which also the <A>p</A>-modular table is contained in the table
##    library.
##  </Item>
##  </List>
##  <P/>
##  The default method for a group and a prime delegates to
##  <Ref Oper="BrauerTable" Label="for a group, and a prime integer"/>
##  for the ordinary character table of this group.
##  The default method for <A>ordtbl</A> uses the attribute
##  <Ref Attr="ComputedBrauerTables"/> for storing the computed Brauer table
##  at position <A>p</A>, and calls the operation <Ref Oper="BrauerTableOp"/>
##  for computing values that are not yet known.
##  <P/>
##  So if one wants to install a new method for computing Brauer tables
##  then it is sufficient to install it for <Ref Oper="BrauerTableOp"/>.
##  <P/>
##  The <K>mod</K> operator for a character table and a prime
##  (see&nbsp;<Ref Sect="Operators for Character Tables"/>) delegates to
##  <Ref Oper="BrauerTable" Label="for a group, and a prime integer"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "BrauerTable", [ IsOrdinaryTable, IsPosInt ] );
DeclareOperation( "BrauerTable", [ IsGroup, IsPosInt ] );

DeclareOperation( "BrauerTableOp", [ IsOrdinaryTable, IsPosInt ] );

DeclareAttribute( "ComputedBrauerTables", IsOrdinaryTable, "mutable" );


#############################################################################
##
#F  CharacterTableRegular( <tbl>, <p> ) .  table consist. of <p>-reg. classes
##
##  <#GAPDoc Label="CharacterTableRegular">
##  <ManSection>
##  <Func Name="CharacterTableRegular" Arg='tbl, p'/>
##
##  <Description>
##  For an ordinary character table <A>tbl</A> and a prime integer <A>p</A>,
##  <Ref Func="CharacterTableRegular"/> returns the <Q>table head</Q> of the
##  <A>p</A>-modular Brauer character table of <A>tbl</A>.
##  This is the restriction of <A>tbl</A> to its <A>p</A>-regular classes,
##  like the return value of <Ref Oper="BrauerTable"
##  Label="for a character table, and a prime integer"/>,
##  but without the irreducible Brauer characters.
##  (In general, these characters are hard to compute,
##  and <Ref Oper="BrauerTable"
##  Label="for a character table, and a prime integer"/>
##  may return <K>fail</K> for the given arguments,
##  for example if <A>tbl</A> is a table from the &GAP; character table
##  library.)
##  <P/>
##  The returned table head can be used to create <A>p</A>-modular Brauer
##  characters, by restricting ordinary characters, for example when one
##  is interested in approximations of the (unknown) irreducible Brauer
##  characters.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= SymmetricGroup( 4 );
##  Sym( [ 1 .. 4 ] )
##  gap> tbl:= CharacterTable( g );;  HasIrr( tbl );
##  false
##  gap> tblmod2:= CharacterTable( tbl, 2 );
##  BrauerTable( Sym( [ 1 .. 4 ] ), 2 )
##  gap> tblmod2 = CharacterTable( tbl, 2 );
##  true
##  gap> tblmod2 = BrauerTable( tbl, 2 );
##  true
##  gap> tblmod2 = BrauerTable( g, 2 );
##  true
##  gap> libtbl:= CharacterTable( "M" );
##  CharacterTable( "M" )
##  gap> CharacterTableRegular( libtbl, 2 );
##  BrauerTable( "M", 2 )
##  gap> BrauerTable( libtbl, 2 );
##  fail
##  gap> CharacterTable( "Symmetric", 4 );
##  CharacterTable( "Sym(4)" )
##  gap> ComputedBrauerTables( tbl );
##  [ , BrauerTable( Sym( [ 1 .. 4 ] ), 2 ) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CharacterTableRegular" );


#############################################################################
##
#F  ConvertToCharacterTable( <record> ) . . . . create character table object
#F  ConvertToCharacterTableNC( <record> ) . . . create character table object
##
##  <#GAPDoc Label="ConvertToCharacterTable">
##  <ManSection>
##  <Func Name="ConvertToCharacterTable" Arg='record'/>
##  <Func Name="ConvertToCharacterTableNC" Arg='record'/>
##
##  <Description>
##  Let <A>record</A> be a record.
##  <Ref Func="ConvertToCharacterTable"/> converts <A>record</A> into a
##  component object
##  (see&nbsp;<Ref Sect="Component Objects"/>)
##  representing a character table.
##  The values of those components of <A>record</A> whose names occur in
##  <Ref Var="SupportedCharacterTableInfo"/>
##  correspond to attribute values of the returned character table.
##  All other components of the record simply become components of the
##  character table object.
##  <P/>
##  If inconsistencies in <A>record</A> are detected,
##  <K>fail</K> is returned.
##  <A>record</A> must have the component <C>UnderlyingCharacteristic</C>
##  bound
##  (cf.&nbsp;<Ref Attr="UnderlyingCharacteristic" Label="for a character table"/>),
##  since this decides about whether the returned character table lies in
##  <Ref Filt="IsOrdinaryTable"/> or in <Ref Filt="IsBrauerTable"/>.
##  <P/>
##  <Ref Func="ConvertToCharacterTableNC"/> does the same except that all
##  checks of <A>record</A> are omitted.
##  <P/>
##  An example of a conversion from a record to a character table object
##  can be found in Section&nbsp;<Ref Func="PrintCharacterTable"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConvertToCharacterTable" );

DeclareGlobalFunction( "ConvertToCharacterTableNC" );


#############################################################################
##
#F  ConvertToLibraryCharacterTableNC( <record> )
##
##  <ManSection>
##  <Func Name="ConvertToLibraryCharacterTableNC" Arg='record'/>
##
##  <Description>
##  For a record <A>record</A> that shall be converted into an ordinary or
##  Brauer character table that knows to belong to the &GAP; character table
##  library, <Ref Func="ConvertToLibraryCharacterTableNC"/> does the same as
##  <Ref Func="ConvertToOrdinaryTableNC"/>, except that additionally the
##  filter <Ref Filt="IsLibraryCharacterTableRep"/> is set
##  (see the manual of the &GAP; Character Table Library).
##  <P/>
##  But if <A>record</A> has the component <C>isGenericTable</C>,
##  with value <K>true</K>, then no attribute values are set.
##  <P/>
##  (The handling of generic character tables may change in the future.
##  Currently they are used just for specialization,
##  see&nbsp;<Ref Chap="Generic Character Tables" BookName="ctbllib"/>.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ConvertToLibraryCharacterTableNC" );


#############################################################################
##
##  9. Printing Character Tables
##
##  <#GAPDoc Label="[11]{ctbl}">
##  <ManSection>
##  <Meth Name="ViewObj" Arg='tbl' Label="for a character table"/>
##
##  <Description>
##  The default <Ref Oper="ViewObj"/> method for ordinary character
##  tables prints the string <C>"CharacterTable"</C>,
##  followed by the identifier
##  (see&nbsp;<Ref Attr="Identifier" Label="for character tables"/>) or,
##  if known, the group of the character table enclosed in brackets.
##  <Ref Oper="ViewObj"/> for Brauer tables does the same, except that the
##  first string is replaced by <C>"BrauerTable"</C>,
##  and that the characteristic is also shown.
##  </Description>
##  </ManSection>
##
##  <ManSection>
##  <Meth Name="PrintObj" Arg='tbl' Label="for a character table"/>
##
##  <Description>
##  The default <Ref Oper="PrintObj"/> method for character tables
##  does the same as <Ref Oper="ViewObj"/>,
##  except that <Ref Oper="PrintObj"/> is used for the group instead of
##  <Ref Oper="ViewObj"/>.
##  </Description>
##  </ManSection>
##
##  <ManSection>
##  <Meth Name="Display" Arg='tbl' Label="for a character table"/>
##
##  <Description>
##  There are various ways to customize the <Ref Oper="Display"/> output
##  for character tables.
##  First we describe the default behaviour,
##  alternatives are then described below.
##  <P/>
##  The default <Ref Oper="Display"/> method prepares the data in <A>tbl</A>
##  for a columnwise output.
##  The number of columns printed at one time depends on the actual
##  line length, which can be accessed and changed by the function
##  <Ref Func="SizeScreen"/>.
##  <P/>
##  An interesting variant of <Ref Oper="Display"/> is the function
##  <Ref Func="PageDisplay" BookName="gapdoc"/>.
##  Convenient ways to print the <Ref Oper="Display"/> format to a file
##  are given by the function <Ref Func="PrintTo1" BookName="gapdoc"/>
##  or by using <Ref Func="PageDisplay" BookName="gapdoc"/> and the
##  facilities of the pager used, cf.&nbsp;<Ref Func="Pager"/>.
##  <P/>
##  An interactive variant of <Ref Oper="Display"/> is the
##  <Ref Oper="Browse" BookName="browse"/> method for character tables
##  that is provided by the &GAP; package <Package>Browse</Package>,
##  see <Ref Meth="Browse" Label="for character tables"
##  BookName="browse"/>.
##  <P/>
##  <Ref Oper="Display"/> shows certain characters (by default all
##  irreducible characters) of <A>tbl</A>, together with the orders of the
##  centralizers in factorized form and the available power maps
##  (see&nbsp;<Ref Attr="ComputedPowerMaps"/>).
##  The <A>n</A>-th displayed character is given the name <C>X.<A>n</A></C>.
##  <P/>
##  The first lines of the output describe the order of the centralizer
##  of an element of the class factorized into its prime divisors.
##  <P/>
##  The next line gives the name of each class.
##  If no class names are stored on <A>tbl</A>,
##  <Ref Attr="ClassNames"/> is called.
##  <P/>
##  Preceded by a name <C>P<A>n</A></C>, the next lines show the <A>n</A>th
##  power maps of <A>tbl</A> in terms of the former shown class names.
##  <P/>
##  Every ambiguous or unknown (see Chapter&nbsp;<Ref Chap="Unknowns"/>)
##  value of the table is displayed as a question mark <C>?</C>.
##  <P/>
##  Irrational character values are not printed explicitly because the
##  lengths of their printed representation might disturb the layout.
##  Instead of that every irrational value is indicated by a name,
##  which is a string of at least one capital letter.
##  <P/>
##  Once a name for an irrational value is found, it is used all over the
##  printed table.
##  Moreover the complex conjugate (see&nbsp;<Ref Attr="ComplexConjugate"/>,
##  <Ref Oper="GaloisCyc" Label="for a cyclotomic"/>)
##  and the star of an irrationality (see&nbsp;<Ref Func="StarCyc"/>) are
##  represented by that very name preceded by a <C>/</C> and a <C>*</C>,
##  respectively.
##  <P/>
##  The printed character table is then followed by a legend,
##  a list identifying the occurring symbols with their actual values.
##  Occasionally this identification is supplemented by a quadratic
##  representation of the irrationality (see&nbsp;<Ref Func="Quadratic"/>)
##  together with the corresponding &ATLAS; notation
##  (see&nbsp;<Cite Key="CCN85"/>).
##  <P/>
##  This default style can be changed by prescribing a record <A>arec</A> of
##  options, which can be given
##  <P/>
##  <Enum>
##  <Item>
##    as an optional argument in the call to <Ref Oper="Display"/>,
##  </Item>
##  <Item>
##    as the value of the attribute <Ref Attr="DisplayOptions"/>
##    if this value is stored in the table,
##  </Item>
##  <Item>
##    as the value of the global variable
##    <C>CharacterTableDisplayDefaults.User</C>, or
##  </Item>
##  <Item>
##    as the value of the global variable
##    <C>CharacterTableDisplayDefaults.Global</C>
##  </Item>
##  </Enum>
##  <P/>
##  (in this order of precedence).
##  <P/>
##  The following components of <A>arec</A> are supported.
##  <P/>
##  <List>
##  <Mark><C>centralizers</C></Mark>
##  <Item>
##    <K>false</K> to suppress the printing of the orders of the centralizers,
##    or the string <C>"ATLAS"</C> to force the printing of non-factorized
##    centralizer orders in a style similar to that used in the
##    &ATLAS; of Finite Groups&nbsp;<Cite Key="CCN85"/>,
##  </Item>
##  <Mark><C>characterField</C></Mark>
##  <Item>
##    <K>true</K> to show the degrees of the character fields over the prime
##    field, in a column with header <C>d</C>,
##  </Item>
##  <Mark><C>chars</C></Mark>
##  <Item>
##    an integer or a list of integers to select a sublist of the
##    irreducible characters of <A>tbl</A>,
##    or a list of characters of <A>tbl</A>
##    (in the latter case, the default letter <C>"X"</C> in the character
##    names is replaced by <C>"Y"</C>),
##  </Item>
##  <Mark><C>charnames</C></Mark>
##  <Item>
##    a list of strings of length equal to the number of characters
##    that shall be shown; they are used as labels for the characters,
##  </Item>
##  <Mark><C>classes</C></Mark>
##  <Item>
##    an integer or a list of integers to select a sublist of the
##    classes of <A>tbl</A>,
##  </Item>
##  <Mark><C>classnames</C></Mark>
##  <Item>
##    a list of strings of length equal to the number of classes
##    that shall be shown; they are used as labels for the classes,
##  </Item>
##  <Mark><C>indicator</C></Mark>
##  <Item>
##    <K>true</K> enables the printing of the second Frobenius Schur
##    indicator, a list of integers enables the printing of the corresponding
##    indicators (see&nbsp;<Ref Oper="Indicator"/>),
##  </Item>
##  <Mark><C>letter</C></Mark>
##  <Item>
##    a single capital letter (e.&nbsp;g.&nbsp;<C>"P"</C> for permutation
##    characters) to replace the default <C>"X"</C> in character names,
##  </Item>
##  <Mark><C>powermap</C></Mark>
##  <Item>
##    an integer or a list of integers to select a subset of the
##    available power maps,
##    <K>false</K> to suppress the printing of power maps,
##    or the string <C>"ATLAS"</C> to force a printing of class names and
##    power maps in a style similar to that used in the
##    &ATLAS; of Finite Groups&nbsp;<Cite Key="CCN85"/>
##    (the <C>"ATLAS"</C> variant works only if the function
##    <Ref Func="CambridgeMaps" BookName="ctbllib"/> is available,
##    which belongs to the <Package>CTblLib</Package> package),
##  </Item>
##  <Mark><C>Display</C></Mark>
##  <Item>
##    the function that is actually called in order to display the table;
##    the arguments are the table and the optional record, whose components
##    can be used inside the <C>Display</C> function,
##  </Item>
##  <Mark><C>StringEntry</C></Mark>
##  <Item>
##    a function that takes either a character value or a character value
##    and the return value of <C>StringEntryData</C> (see below),
##    and returns the string that is actually displayed;
##    it is called for all character values to be displayed,
##    and also for the displayed indicator values (see above),
##  </Item>
##  <Mark><C>StringEntryData</C></Mark>
##  <Item>
##    a unary function that is called once with argument <A>tbl</A> before
##    the character values are displayed;
##    it returns an object that is used as second argument of the function
##    <C>StringEntry</C>,
##  </Item>
##  <Mark><C>Legend</C></Mark>
##  <Item>
##    a function that takes the result of the <C>StringEntryData</C> call as
##    its only argument, after the character table has been displayed;
##    the return value is a string that describes the symbols used in the
##    displayed table in a formatted way,
##    it is printed below the displayed table.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#A  DisplayOptions( <tbl> )
##
##  <#GAPDoc Label="DisplayOptions">
##  <ManSection>
##  <Attr Name="DisplayOptions" Arg='tbl'/>
##
##  <Description>
##  <!-- is a more general attribute?-->
##  There is no default method to compute a value,
##  one can set a value with <C>SetDisplayOptions</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "A5" );;
##  gap> Display( tbl );
##  A5
##
##       2  2  2  .  .  .
##       3  1  .  1  .  .
##       5  1  .  .  1  1
##
##         1a 2a 3a 5a 5b
##      2P 1a 1a 3a 5b 5a
##      3P 1a 2a 1a 5b 5a
##      5P 1a 2a 3a 1a 1a
##
##  X.1     1  1  1  1  1
##  X.2     3 -1  .  A *A
##  X.3     3 -1  . *A  A
##  X.4     4  .  1 -1 -1
##  X.5     5  1 -1  .  .
##
##  A = -E(5)-E(5)^4
##    = (1-Sqrt(5))/2 = -b5
##  gap> CharacterTableDisplayDefaults.User:= rec(
##  >        powermap:= "ATLAS", centralizers:= "ATLAS", chars:= false );;
##  gap> Display( CharacterTable( "A5" ) );
##  A5
##
##      60  4  3  5  5
##
##   p      A  A  A  A
##   p'     A  A  A  A
##      1A 2A 3A 5A B*
##
##  gap> options:= rec( chars:= 4, classes:= [ tbl.3a .. tbl.5a ],
##  >                   centralizers:= false, indicator:= true,
##  >                   powermap:= [ 2 ] );;
##  gap> Display( tbl, options );
##  A5
##
##            3a 5a
##         2P 3a 5b
##         2
##  X.4    +   1 -1
##  gap> SetDisplayOptions( tbl, options );  Display( tbl );
##  A5
##
##            3a 5a
##         2P 3a 5b
##         2
##  X.4    +   1 -1
##  gap> Unbind( CharacterTableDisplayDefaults.User );
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DisplayOptions", IsNearlyCharacterTable );


#############################################################################
##
#V  CharacterTableDisplayDefaults
##
##  <ManSection>
##  <Var Name="CharacterTableDisplayDefaults"/>
##
##  <Description>
##  This is a record with at least the component <C>Global</C>, which is used
##  as the default value for the second argument of <Ref Oper="Display"/> for
##  character tables.
##  <P/>
##  If also the component <C>User</C> is bound then this value is taken
##  instead.
##  So one can customize the default behaviour of <Ref Oper="Display"/> by
##  adding this component, and return to the previous behaviour by unbinding
##  it.
##  </Description>
##  </ManSection>
##
DeclareGlobalName( "CharacterTableDisplayDefaults" );


#############################################################################
##
#F  PrintCharacterTable( <tbl>, <varname> )
##
##  <#GAPDoc Label="PrintCharacterTable">
##  <ManSection>
##  <Func Name="PrintCharacterTable" Arg='tbl, varname'/>
##
##  <Description>
##  Let <A>tbl</A> be a nearly character table, and <A>varname</A> a string.
##  <Ref Func="PrintCharacterTable"/> prints those values of the supported
##  attributes (see&nbsp;<Ref Var="SupportedCharacterTableInfo"/>) that are
##  known for <A>tbl</A>.
##  <!--  If <A>tbl</A> is a library table then also the known values of
##        supported components
##        (see&nbsp;<Ref Var="SupportedLibraryTableComponents"/>)
##        are printed.-->
##  <P/>
##  The output of <Ref Func="PrintCharacterTable"/> is &GAP; readable;
##  actually reading it into &GAP; will bind the variable with name
##  <A>varname</A> to a character table that coincides with <A>tbl</A> for
##  all printed components.
##  <P/>
##  This is used mainly for saving character tables to files.
##  A more human readable form is produced by <Ref Oper="Display"/>.
##  <!-- Note that a table with group can be read back only if the group
##       elements can be read back;
##       so this works for permutation groups but not for PC groups!
##       (what about the efficiency?) -->
##  <!-- Is there a problem of consistency,
##       if the group is stored but classes are not, and later the classes
##       are automatically constructed? (This should be safe.) -->
##  <P/>
##  <Example><![CDATA[
##  gap> PrintCharacterTable( CharacterTable( "Cyclic", 2 ), "tbl" );
##  tbl:= function()
##  local tbl, i;
##  tbl:=rec();
##  tbl.Irr:=
##  [ [ 1, 1 ], [ 1, -1 ] ];
##  tbl.IsFinite:=
##  true;
##  tbl.NrConjugacyClasses:=
##  2;
##  tbl.Size:=
##  2;
##  tbl.OrdersClassRepresentatives:=
##  [ 1, 2 ];
##  tbl.SizesCentralizers:=
##  [ 2, 2 ];
##  tbl.UnderlyingCharacteristic:=
##  0;
##  tbl.ClassParameters:=
##  [ [ 1, 0 ], [ 1, 1 ] ];
##  tbl.CharacterParameters:=
##  [ [ 1, 0 ], [ 1, 1 ] ];
##  tbl.Identifier:=
##  "C2";
##  tbl.InfoText:=
##  "computed using generic character table for cyclic groups";
##  tbl.ComputedPowerMaps:=
##  [ , [ 1, 1 ] ];
##  ConvertToLibraryCharacterTableNC(tbl);
##  return tbl;
##  end;
##  tbl:= tbl();
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PrintCharacterTable" );


#############################################################################
##
##  10. Constructing Character Tables from Others
##
##  <#GAPDoc Label="[12]{ctbl}">
##  The following operations take one or more character table arguments,
##  and return a character table.
##  This holds also for <Ref Oper="BrauerTable"
##  Label="for a character table, and a prime integer"/>.
##  Note that the return value of <Ref Oper="BrauerTable"
##  Label="for a character table, and a prime integer"/>
##  will in general not know the irreducible Brauer characters,
##  and &GAP; might be unable to compute these characters.
##  <P/>
##  <E>Note</E> that whenever fusions between input and output tables occur
##  in these operations,
##  they are stored on the concerned tables,
##  and the <Ref Attr="NamesOfFusionSources"/> values are updated.
##  <P/>
##  (The interactive construction of character tables using character
##  theoretic methods and incomplete tables is not described here.)
##  <E>Currently it is not supported and will be described in a chapter of its
##  own when it becomes available</E>.
##  <#/GAPDoc>
##


#############################################################################
##
#O  CharacterTableDirectProduct( <tbl1>, <tbl2> )
##
##  <#GAPDoc Label="CharacterTableDirectProduct">
##  <ManSection>
##  <Oper Name="CharacterTableDirectProduct" Arg='tbl1, tbl2'/>
##
##  <Description>
##  is the table of the direct product of the character tables <A>tbl1</A>
##  and <A>tbl2</A>.
##  <P/>
##  The matrix of irreducibles of this table is the Kronecker product
##  (see&nbsp;<Ref Oper="KroneckerProduct"/>) of the irreducibles of
##  <A>tbl1</A> and <A>tbl2</A>.
##  <P/>
##  Products of ordinary and Brauer character tables are supported.
##  <P/>
##  In general, the result will not know an underlying group,
##  so missing power maps (for prime divisors of the result)
##  and irreducibles of the input tables may be computed in order to
##  construct the table of the direct product.
##  <P/>
##  The embeddings of the input tables into the direct product are stored,
##  they can be fetched with <Ref Func="GetFusionMap"/>;
##  if <A>tbl1</A> is equal to <A>tbl2</A> then the two embeddings are
##  distinguished by their <C>specification</C> components <C>"1"</C> and
##  <C>"2"</C>, respectively.
##  <P/>
##  Analogously, the projections from the direct product onto the input
##  tables are stored, and can be distinguished by the <C>specification</C>
##  components.
##  <!-- generalize this to arbitrarily many arguments!-->
##  <P/>
##  The attribute <Ref Attr="FactorsOfDirectProduct"/>
##  is set to the lists of arguments.
##  <P/>
##  The <C>*</C> operator for two character tables
##  (see&nbsp;<Ref Sect="Operators for Character Tables"/>) delegates to
##  <Ref Oper="CharacterTableDirectProduct"/>.
##  <Example><![CDATA[
##  gap> c2:= CharacterTable( "Cyclic", 2 );;
##  gap> s3:= CharacterTable( "Symmetric", 3 );;
##  gap> Display( CharacterTableDirectProduct( c2, s3 ) );
##  C2xSym(3)
##
##       2  2  2  1  2  2  1
##       3  1  .  1  1  .  1
##
##         1a 2a 3a 2b 2c 6a
##      2P 1a 1a 3a 1a 1a 3a
##      3P 1a 2a 1a 2b 2c 2b
##
##  X.1     1 -1  1  1 -1  1
##  X.2     2  . -1  2  . -1
##  X.3     1  1  1  1  1  1
##  X.4     1 -1  1 -1  1 -1
##  X.5     2  . -1 -2  .  1
##  X.6     1  1  1 -1 -1 -1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CharacterTableDirectProduct",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ] );


#############################################################################
##
#A  FactorsOfDirectProduct( <tbl> )
##
##  <#GAPDoc Label="FactorsOfDirectProduct">
##  <ManSection>
##  <Attr Name="FactorsOfDirectProduct" Arg='tbl'/>
##
##  <Description>
##  For an ordinary character table that has been constructed via
##  <Ref Oper="CharacterTableDirectProduct"/>,
##  the value of <Ref Attr="FactorsOfDirectProduct"/> is the list of
##  arguments in the <Ref Oper="CharacterTableDirectProduct"/> call.
##  <P/>
##  Note that there is no default method for <E>computing</E> the value of
##  <Ref Attr="FactorsOfDirectProduct"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "FactorsOfDirectProduct", IsNearlyCharacterTable,
    [] );


#############################################################################
##
#F  CharacterTableHeadOfFactorGroupByFusion( <tbl>, <factorfusion> )
##
##  <ManSection>
##  <Func Name="CharacterTableHeadOfFactorGroupByFusion"
##   Arg='tbl, factorfusion'/>
##
##  <Description>
##  is the character table of the factor group of the ordinary character
##  table <A>tbl</A> defined by the list <A>factorfusion</A> that describes
##  the factor fusion.
##  The irreducible characters of the factor group are <E>not</E> computed.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CharacterTableHeadOfFactorGroupByFusion" );


#############################################################################
##
#O  CharacterTableFactorGroup( <tbl>, <classes> )
##
##  <#GAPDoc Label="CharacterTableFactorGroup">
##  <ManSection>
##  <Oper Name="CharacterTableFactorGroup" Arg='tbl, classes'/>
##
##  <Description>
##  is the character table of the factor group of the ordinary character
##  table <A>tbl</A> by the normal closure of the classes whose positions are
##  contained in the list <A>classes</A>.
##  <P/>
##  The <C>/</C> operator for a character table and a list of class positions
##  (see&nbsp;<Ref Sect="Operators for Character Tables"/>) delegates to
##  <Ref Oper="CharacterTableFactorGroup"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> s4:= CharacterTable( "Symmetric", 4 );;
##  gap> ClassPositionsOfNormalSubgroups( s4 );
##  [ [ 1 ], [ 1, 3 ], [ 1, 3, 4 ], [ 1 .. 5 ] ]
##  gap> f:= CharacterTableFactorGroup( s4, [ 3 ] );
##  CharacterTable( "Sym(4)/[ 1, 3 ]" )
##  gap> Display( f );
##  Sym(4)/[ 1, 3 ]
##
##       2  1  1  .
##       3  1  .  1
##
##         1a 2a 3a
##      2P 1a 1a 3a
##      3P 1a 2a 1a
##
##  X.1     1 -1  1
##  X.2     2  . -1
##  X.3     1  1  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CharacterTableFactorGroup",
    [ IsNearlyCharacterTable, IsHomogeneousList ] );


#############################################################################
##
#A  CharacterTableIsoclinic( <tbl> )
#O  CharacterTableIsoclinic( <tbl>, <arec> )
#O  CharacterTableIsoclinic( <modtbl>, <ordiso> )
#O  CharacterTableIsoclinic( <tbl>[, <classes>][, <centre>] )
#A  SourceOfIsoclinicTable( <tbl> )
##
##  <#GAPDoc Label="CharacterTableIsoclinic">
##  <ManSection>
##  <Oper Name="CharacterTableIsoclinic" Arg='tbl[, arec]'/>
##  <Oper Name="CharacterTableIsoclinic" Arg='tbl[, classes][, centre]'
##   Label="for a character table and one or two lists"/>
##  <Oper Name="CharacterTableIsoclinic" Arg='modtbl, ordiso'
##   Label="for a Brauer table and an ordinary table"/>
##  <Attr Name="SourceOfIsoclinicTable" Arg='tbl'/>
##
##  <Description>
##  Let <A>tbl</A> be the (ordinary or modular) character table of a group
##  <M>H</M> with the structure <M>p.G.p</M> for some prime <M>p</M>,
##  that is, <M>H/Z</M> has a normal subgroup <M>N</M> of index <M>p</M>
##  and a central subgroup <M>Z</M> of order <M>p</M> contained in <M>N</M>.
##  <P/>
##  Then <Ref Oper="CharacterTableIsoclinic"/> returns
##  the table of an isoclinic group in the sense of the
##  &ATLAS; of Finite Groups
##  <Cite Key="CCN85" Where="Chapter 6, Section 7"/>.
##  <P/>
##  If <M>p = 2</M> then also the case <M>H = 4.G.2</M> is supported,
##  that is, <M>Z</M> has order four and <M>N</M> has index two in <M>H</M>.
##  <P/>
##  The optional arguments are needed if <A>tbl</A> does not determine
##  the class positions of <M>N</M> or <M>Z</M> uniquely,
##  and in the case <M>p > 2</M> if one wants to specify a
##  <Q>variant number</Q> for the result.
##  <P/>
##  <List>
##  <Item>
##    In general, the values can be specified via a record <A>arec</A>.
##    If <M>N</M> is not uniquely determined then the positions of the
##    classes forming <M>N</M> must be entered as the value of the component
##    <C>normalSubgroup</C>.
##    If <M>Z</M> is not unique inside <M>N</M> then the class position of
##    a generator of <M>Z</M> must be entered as the value of the
##    component <C>centralElement</C>.
##  </Item>
##  <Item>
##    If <M>p = 2</M> then one may specify the positions of the classes
##    forming <M>N</M> via a list <A>classes</A>,
##    and the positions of the classes in <M>Z</M> as a list <A>centre</A>;
##    if <M>Z</M> has order <M>2</M> then <A>centre</A> can be also the
##    position of the involution in <M>Z</M>.
##  </Item>
##  </List>
##  <P/>
##  Note that also if <A>tbl</A> is a Brauer table then <C>normalSubgroup</C>
##  and <C>centralElement</C>, resp.&nbsp; <A>classes</A> and <A>centre</A>,
##  denote class numbers w.r.t.&nbsp;the <E>ordinary</E> character table.
##  <P/>
##  If <M>p</M> is odd then the &ATLAS; construction describes <M>p</M>
##  isoclinic variants that arise from <M>p.G.p</M>.
##  (These groups need not be pairwise nonisomorphic.)
##  Entering an integer <M>k \in \{ 1, 2, \ldots, p-1 \}</M> as the value of
##  the component <C>k</C> of <A>arec</A> yields the <M>k</M>-th of the
##  corresponding character tables; the default for <C>k</C> is <M>1</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> d8:= CharacterTable( "Dihedral", 8 );
##  CharacterTable( "Dihedral(8)" )
##  gap> nsg:= ClassPositionsOfNormalSubgroups( d8 );
##  [ [ 1 ], [ 1, 3 ], [ 1 .. 3 ], [ 1, 3, 4 ], [ 1, 3 .. 5 ], [ 1 .. 5 ]
##   ]
##  gap> isod8:= CharacterTableIsoclinic( d8, nsg[3] );;
##  gap> Display( isod8 );
##  Isoclinic(Dihedral(8))
##
##       2  3  2  3  2  2
##
##         1a 4a 2a 4b 4c
##      2P 1a 2a 1a 2a 2a
##
##  X.1     1  1  1  1  1
##  X.2     1  1  1 -1 -1
##  X.3     1 -1  1  1 -1
##  X.4     1 -1  1 -1  1
##  X.5     2  . -2  .  .
##  gap> t1:= CharacterTable( SmallGroup( 27, 3 ) );;
##  gap> t2:= CharacterTable( SmallGroup( 27, 4 ) );;
##  gap> nsg:= ClassPositionsOfNormalSubgroups( t1 );
##  [ [ 1 ], [ 1, 4, 8 ], [ 1, 2, 4, 5, 8 ], [ 1, 3, 4, 7, 8 ],
##    [ 1, 4, 6, 8, 11 ], [ 1, 4, 8, 9, 10 ], [ 1 .. 11 ] ]
##  gap> iso1:= CharacterTableIsoclinic( t1, rec( k:= 1,
##  >               normalSubgroup:= nsg[3] ) );;
##  gap> iso2:= CharacterTableIsoclinic( t1, rec( k:= 2,
##  >               normalSubgroup:= nsg[3] ) );;
##  gap> TransformingPermutationsCharacterTables( iso1, t1 ) <> fail;
##  false
##  gap> TransformingPermutationsCharacterTables( iso1, t2 ) <> fail;
##  true
##  gap> TransformingPermutationsCharacterTables( iso2, t2 ) <> fail;
##  true
##  ]]></Example>
##  <P/>
##  For an ordinary character table that has been constructed via
##  <Ref Oper="CharacterTableIsoclinic"/>,
##  the value of <Ref Attr="SourceOfIsoclinicTable"/> encodes this
##  construction, and is defined as follows.
##  If <M>p = 2</M> then the value is the list with entries <A>tbl</A>,
##  <A>classes</A>, the list of class positions of the nonidentity
##  elements in <M>Z</M>, and the class position of a generator of <M>Z</M>.
##  If <M>p</M> is an odd prime then the value is a record with the
##  following components.
##  <P/>
##  <List>
##  <Mark><C>table</C></Mark>
##  <Item>
##    the character table <A>tbl</A>,
##  </Item>
##  <Mark><C>p</C></Mark>
##  <Item>
##    the prime <M>p</M>,
##  </Item>
##  <Mark><C>k</C></Mark>
##  <Item>
##    the variant number <M>k</M>,
##  </Item>
##  <Mark><C>outerClasses</C></Mark>
##  <Item>
##    the list of length <M>p-1</M> that contains at position <M>i</M>
##    the sorted list of class positions of the <M>i</M>-th coset of the
##    normal subgroup <M>N</M>
##  </Item>
##  <Mark><C>centralElement</C></Mark>
##  <Item>
##    the class position of a generator of the central subgroup <M>Z</M>.
##  </Item>
##  </List>
##  <P/>
##  There is no default method for <E>computing</E> the value of
##  <Ref Attr="SourceOfIsoclinicTable"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> SourceOfIsoclinicTable( isod8 );
##  [ CharacterTable( "Dihedral(8)" ), [ 1 .. 3 ], [ 3 ], 3 ]
##  gap> SourceOfIsoclinicTable( iso1 );
##  rec( centralElement := 4, k := 1,
##    outerClasses := [ [ 3, 6, 9 ], [ 7, 10, 11 ] ], p := 3,
##    table := CharacterTable( <pc group of size 27 with 3 generators> ) )
##  ]]></Example>
##  <P/>
##  If the arguments of <Ref Oper="CharacterTableIsoclinic"/> are
##  a Brauer table <A>modtbl</A> and an ordinary table <A>ordiso</A>
##  then the <Ref Attr="SourceOfIsoclinicTable"/> value of <A>ordiso</A>
##  is assumed to be identical with the
##  <Ref Attr="OrdinaryCharacterTable" Label="for a character table"/>
##  value of <A>modtbl</A>,
##  and the specified isoclinic table of <A>modtbl</A> is returned.
##  This variant is useful if one has already constructed <A>ordiso</A>
##  in advance.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= GL(2,3);;
##  gap> t:= CharacterTable( g );;
##  gap> iso:= CharacterTableIsoclinic( t );;
##  gap> t3:= t mod 3;;
##  gap> iso3:= CharacterTableIsoclinic( t3, iso );;
##  gap> TransformingPermutationsCharacterTables( iso3,
##  >        CharacterTableIsoclinic( t3 ) ) <> fail;
##  true
##  ]]></Example>
##  <P/>
##  <E>Theoretical background:</E>
##  Consider the central product <M>K</M> of <M>H</M> with a cyclic group
##  <M>C</M> of order <M>p^2</M>.
##  That is, <M>K = H C</M>, <M>C \leq Z(K)</M>, and the central subgroup
##  <M>Z</M> of order <M>p</M> in <M>H</M> lies in <M>C</M>.
##  There are <M>p+1</M> subgroups of <M>K</M> that contain
##  the normal subgroup <M>N</M> of index <M>p</M> in <M>H</M>.
##  One of them is the central product of <M>C</M> with <M>N</M>,
##  the others are <M>H_0 = H</M> and its isoclinic variants
##  <M>H_1, H_2, \ldots, H_{{p-1}}</M>.
##  We fix <M>g \in H \setminus N</M> and a generator <M>z</M> of <M>C</M>,
##  and get <M>H = N \cup N g \cup N g^2 \cup \cdots \cup N g^{{p-1}}</M>.
##  Then <M>H_k</M>, <M>0 \leq k \leq p-1</M>, is given by
##  <M>N \cup N gz^k \cup N (gz^k)^2 \cup \cdots \cup N (gz^k)^{{p-1}}</M>.
##  The conjugacy classes of all <M>H_k</M> are in bijection via multiplying
##  the elements with suitable powers of <M>z</M>,
##  and the irreducible characters of all <M>H_k</M> extend to <M>K</M> and
##  are in bijection via multiplying the character values with suitable
##  <M>p^2</M>-th roots of unity.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeSuppCT( "SourceOfIsoclinicTable", IsNearlyCharacterTable,
    [] );

DeclareAttribute( "CharacterTableIsoclinic", IsNearlyCharacterTable );

DeclareOperation( "CharacterTableIsoclinic",
    [ IsNearlyCharacterTable, IsRecord ] );
DeclareOperation( "CharacterTableIsoclinic",
    [ IsNearlyCharacterTable, IsList and IsCyclotomicCollection ] );
DeclareOperation( "CharacterTableIsoclinic",
    [ IsBrauerTable, IsOrdinaryTable and HasSourceOfIsoclinicTable ] );

DeclareOperation( "CharacterTableIsoclinic",
    [ IsNearlyCharacterTable, IsPosInt ] );
DeclareOperation( "CharacterTableIsoclinic",
    [ IsNearlyCharacterTable, IsList and IsCyclotomicCollection, IsPosInt ]);
DeclareOperation( "CharacterTableIsoclinic",
    [ IsNearlyCharacterTable, IsList and IsCyclotomicCollection,
      IsList and IsCyclotomicCollection ] );


#############################################################################
##
#F  CharacterTableOfNormalSubgroup( <ordtbl>, <classes> )
##
##  <#GAPDoc Label="CharacterTableOfNormalSubgroup">
##  <ManSection>
##  <Func Name="CharacterTableOfNormalSubgroup" Arg='ordtbl, classes'/>
##
##  <Description>
##  Let <A>ordtbl</A> be the ordinary character table of a group <M>G</M>,
##  say, and <A>classes</A> be a list of class positions for this table.
##  If the classes given by <A>classes</A> form a normal subgroup <M>N</M>,
##  say, of <M>G</M> and if these classes are conjugacy classes of <M>N</M>
##  then this function returns the character table of <M>N</M>.
##  In all other cases, the function returns <K>fail</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> t:= CharacterTable( "Symmetric", 4 );
##  CharacterTable( "Sym(4)" )
##  gap> nsg:= ClassPositionsOfNormalSubgroups( t );
##  [ [ 1 ], [ 1, 3 ], [ 1, 3, 4 ], [ 1 .. 5 ] ]
##  gap> rest:= List( nsg, c -> CharacterTableOfNormalSubgroup( t, c ) );
##  [ CharacterTable( "Rest(Sym(4),[ 1 ])" ), fail, fail,
##    CharacterTable( "Rest(Sym(4),[ 1 .. 5 ])" ) ]
##  ]]></Example>
##  <P/>
##  Here is a nontrivial example.
##  We use <Ref Func="CharacterTableOfNormalSubgroup"/> for computing the
##  two isoclinic variants of <M>2.A_5.2</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= SchurCoverOfSymmetricGroup( 5, 3, 1 );;
##  gap> c:= CyclicGroup( 4 );;
##  gap> dp:= DirectProduct( g, c );;
##  gap> diag:= First( Elements( Centre( dp ) ),
##  >                  x -> Order( x ) = 2 and
##  >                       not x in Image( Embedding( dp, 1 ) ) and
##  >                       not x in Image( Embedding( dp, 2 ) ) );;
##  gap> fact:= Image( NaturalHomomorphismByNormalSubgroup( dp,
##  >                      Subgroup( dp, [ diag ] ) ));;
##  gap> t:= CharacterTable( fact );;
##  gap> Size( t );
##  480
##  gap> nsg:= ClassPositionsOfNormalSubgroups( t );;
##  gap> rest:= List( nsg, c -> CharacterTableOfNormalSubgroup( t, c ) );;
##  gap> index2:= Filtered( rest, x -> x <> fail and Size( x ) = 240 );;
##  gap> Length( index2 );
##  2
##  gap> tg:= CharacterTable( g );;
##  gap> SortedList(List(index2,x->IsRecord(
##  >       TransformingPermutationsCharacterTables(x,tg))));
##  [ true, false ]
##  ]]></Example>
##  <P/>
##  Alternatively, we could construct the character table of the central
##  product with character theoretic methods.
##  Or we could use <Ref Oper="CharacterTableIsoclinic"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CharacterTableOfNormalSubgroup" );


#############################################################################
##
##  11. Sorted Character Tables
##


#############################################################################
##
#F  PermutationToSortCharacters( <tbl>, <chars>, <degree>, <norm>, <galois> )
##
##  <ManSection>
##  <Func Name="PermutationToSortCharacters"
##   Arg='tbl, chars, degree, norm, galois'/>
##
##  <Description>
##  returns a permutation <M>\pi</M> that can be applied to the list
##  <A>chars</A> of characters of the character table <A>tbl</A> in order to
##  sort this list w.r.t.&nbsp;increasing degree, norm, or both.
##  The arguments <A>degree</A>, <A>norm</A>, and <A>galois</A> must be
##  Booleans.
##  If <A>norm</A> is <K>true</K> then characters of smaller norm precede
##  characters of larger norm after permuting with <M>\pi</M>.
##  If both <A>degree</A> and <A>norm</A> are <K>true</K> then additionally
##  characters of same norm are sorted w.r.t.&nbsp;increasing degree after
##  permuting with <M>\pi</M>.
##  If only <A>degree</A> is <K>true</K> then characters of smaller degree
##  precede characters of larger degree after permuting with <M>\pi</M>.
##  If <A>galois</A> is <K>true</K> then each family of algebraic conjugate
##  characters in <A>chars</A> is consecutive after permuting with
##  <M>\pi</M>.
##  <P/>
##  Rational characters in the permuted list precede characters with
##  irrationalities of same norm and/or degree, and the trivial character
##  will be sorted to position <M>1</M> if it occurs in <A>chars</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PermutationToSortCharacters" );


#############################################################################
##
#O  CharacterTableWithSortedCharacters( <tbl>[, <perm>] )
##
##  <#GAPDoc Label="CharacterTableWithSortedCharacters">
##  <ManSection>
##  <Oper Name="CharacterTableWithSortedCharacters" Arg='tbl[, perm]'/>
##
##  <Description>
##  is a character table that differs from <A>tbl</A> only by the succession
##  of its irreducible characters.
##  This affects the values of the attributes
##  <Ref Attr="Irr" Label="for a character table"/> and
##  <Ref Attr="CharacterParameters"/>.
##  Namely, these lists are permuted by the permutation <A>perm</A>.
##  <P/>
##  If no second argument is given then a permutation is used that yields
##  irreducible characters of increasing degree for the result.
##  For the succession of characters in the result,
##  see&nbsp;<Ref Oper="SortedCharacters"/>.
##  <P/>
##  The result has all those attributes and properties of <A>tbl</A> that are
##  stored in <Ref Var="SupportedCharacterTableInfo"/> and do not depend
##  on the ordering of characters.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CharacterTableWithSortedCharacters",
    [ IsNearlyCharacterTable ] );
DeclareOperation( "CharacterTableWithSortedCharacters",
    [ IsNearlyCharacterTable, IsPerm ] );


#############################################################################
##
#O  SortedCharacters( <tbl>, <chars> )
#O  SortedCharacters( <tbl>, <chars>, "norm" )
#O  SortedCharacters( <tbl>, <chars>, "degree" )
##
##  <#GAPDoc Label="SortedCharacters">
##  <ManSection>
##  <Oper Name="SortedCharacters" Arg='tbl, chars[, flag]'/>
##
##  <Description>
##  is a list containing the characters <A>chars</A>, ordered as specified
##  by the other arguments.
##  <P/>
##  There are three possibilities to sort characters:
##  They can be sorted according to ascending norms
##  (<A>flag</A> is the string <C>"norm"</C>),
##  to ascending degree (<A>flag</A> is the string <C>"degree"</C>),
##  or both (no third argument is given),
##  i.e., characters with same norm are sorted according to ascending degree,
##  and characters with smaller norm precede those with bigger norm.
##  <P/>
##  Rational characters in the result precede other ones with same norm
##  and/or same degree.
##  <P/>
##  The trivial character, if contained in <A>chars</A>, will always be
##  sorted to the first position.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SortedCharacters",
    [ IsNearlyCharacterTable, IsHomogeneousList ] );
DeclareOperation( "SortedCharacters",
    [ IsNearlyCharacterTable, IsHomogeneousList, IsString ] );


#############################################################################
##
#F  PermutationToSortClasses( <tbl>, <classes>, <orders>, <galois> )
##
##  <ManSection>
##  <Func Name="PermutationToSortClasses"
##   Arg='tbl, classes, orders, galois'/>
##
##  <Description>
##  returns a permutation <M>\pi</M> that can be applied to the columns
##  in the character table <A>tbl</A> in order to sort this table
##  w.r.t.&nbsp;increasing class length, element order, or both.
##  <A>classes</A> and <A>orders</A> must be Booleans.
##  If <A>orders</A> is <K>true</K> then classes of element of smaller order
##  precede classes of elements of larger order after peruting with
##  <M>\pi</M>.
##  If both <A>classes</A> and <A>orders</A> are <K>true</K> then
##  additionally classes of elements of the same order are sorted
##  w.r.t.&nbsp;increasing length after permuting with <M>\pi</M>.
##  If <A>classes</A> is <K>true</K> but <A>orders</A> is <K>false</K> then
##  smaller classes precede larger ones after permuting with <M>\pi</M>.
##  If <A>galois</A> is <K>true</K> then each family of algebraic conjugate
##  classes in <A>tbl</A> is consecutive after permuting with <M>\pi</M>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PermutationToSortClasses" );


#############################################################################
##
#O  CharacterTableWithSortedClasses( <tbl> )
#O  CharacterTableWithSortedClasses( <tbl>, "centralizers" )
#O  CharacterTableWithSortedClasses( <tbl>, "representatives" )
#O  CharacterTableWithSortedClasses( <tbl>, <permutation> )
##
##  <#GAPDoc Label="CharacterTableWithSortedClasses">
##  <ManSection>
##  <Oper Name="CharacterTableWithSortedClasses" Arg='tbl[, flag]'/>
##
##  <Description>
##  is a character table obtained by permutation of the classes of
##  <A>tbl</A>.
##  If the second argument <A>flag</A> is the string <C>"centralizers"</C>
##  then the classes of the result are sorted according to descending
##  centralizer orders.
##  If the second argument is the string <C>"representatives"</C> then the
##  classes of the result are sorted according to ascending representative
##  orders.
##  If no second argument is given then the classes of the result are sorted
##  according to ascending representative orders,
##  and classes with equal representative orders are sorted according to
##  descending centralizer orders.
##  <P/>
##  If the second argument is a permutation then the classes of the
##  result are sorted by application of this permutation.
##  <P/>
##  The result has all those attributes and properties of <A>tbl</A> that are
##  stored in <Ref Var="SupportedCharacterTableInfo"/> and do not depend
##  on the ordering of classes.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="SortedCharacterTable">
##  <ManSection>
##  <Func Name="SortedCharacterTable" Arg='tbl, kernel'
##   Label="w.r.t. a normal subgroup"/>
##  <Func Name="SortedCharacterTable" Arg='tbl, normalseries'
##   Label="w.r.t. a series of normal subgroups"/>
##  <Func Name="SortedCharacterTable" Arg='tbl, facttbl, kernel'
##   Label="relative to the table of a factor group"/>
##
##  <Description>
##  is a character table obtained on permutation of the classes and the
##  irreducibles characters of <A>tbl</A>.
##  <P/>
##  The first form sorts the classes at positions contained in the list
##  <A>kernel</A> to the beginning, and sorts all characters in
##  <C>Irr( <A>tbl</A> )</C> such that the first characters are those that
##  contain <A>kernel</A> in their kernel.
##  <P/>
##  The second form does the same successively for all kernels <M>k_i</M> in
##  the list <M><A>normalseries</A> = [ k_1, k_2, \ldots, k_n ]</M> where
##  <M>k_i</M> must be a sublist of <M>k_{{i+1}}</M> for
##  <M>1 \leq i \leq n-1</M>.
##  <P/>
##  The third form computes the table <M>F</M> of the factor group of
##  <A>tbl</A> modulo the normal subgroup formed by the classes whose
##  positions are contained in the list <A>kernel</A>;
##  <M>F</M> must be permutation equivalent to the table <A>facttbl</A>,
##  in the sense of <Ref Oper="TransformingPermutationsCharacterTables"/>,
##  otherwise <K>fail</K> is returned.
##  The classes of <A>tbl</A> are sorted such that the preimages
##  of a class of <M>F</M> are consecutive,
##  and that the succession of preimages is that of <A>facttbl</A>.
##  The <Ref Attr="Irr" Label="for a character table"/> value of <A>tbl</A>
##  is sorted as with <C>SortCharTable( <A>tbl</A>, <A>kernel</A> )</C>.
##  <P/>
##  (<E>Note</E> that the transformation is only unique up to table
##  automorphisms of <M>F</M>, and this need not be unique up to table
##  automorphisms of <A>tbl</A>.)
##  <P/>
##  All rearrangements of classes and characters are stable,
##  i.e., the relative positions of classes and characters that are not
##  distinguished by any relevant property is not changed.
##  <P/>
##  The result has all those attributes and properties of <A>tbl</A> that are
##  stored in <Ref Var="SupportedCharacterTableInfo"/> and do not depend on
##  the ordering of classes and characters.
##  <P/>
##  The <Ref Attr="ClassPermutation"/> value of <A>tbl</A> is changed if
##  necessary, see&nbsp;<Ref Sect="Conventions for Character Tables"/>.
##  <P/>
##  <Ref Func="SortedCharacterTable" Label="w.r.t. a normal subgroup"/>
##  uses <Ref Oper="CharacterTableWithSortedClasses"/> and
##  <Ref Oper="CharacterTableWithSortedCharacters"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SortedCharacterTable" );


#############################################################################
##
#A  ClassPermutation( <tbl> )
##
##  <#GAPDoc Label="ClassPermutation">
##  <ManSection>
##  <Attr Name="ClassPermutation" Arg='tbl'/>
##
##  <Description>
##  is a permutation <M>\pi</M> of classes of the character table <A>tbl</A>.
##  If it is stored then class fusions into <A>tbl</A> that are stored on
##  other tables must be followed by <M>\pi</M> in order to describe the
##  correct fusion.
##  <P/>
##  This attribute value is bound only if <A>tbl</A> was obtained from another
##  table by permuting the classes,
##  using <Ref Oper="CharacterTableWithSortedClasses"/>
##  or <Ref Func="SortedCharacterTable" Label="w.r.t. a normal subgroup"/>.
##  <P/>
##  It is necessary because the original table and the sorted table have the
##  same identifier (and the same group if known),
##  and hence the same fusions are valid for the two tables.
##  <P/>
##  <Example><![CDATA[
##  gap> tbl:= CharacterTable( "Symmetric", 4 );
##  CharacterTable( "Sym(4)" )
##  gap> Display( tbl );
##  Sym(4)
##
##       2  3  2  3  .  2
##       3  1  .  .  1  .
##
##         1a 2a 2b 3a 4a
##      2P 1a 1a 1a 3a 2b
##      3P 1a 2a 2b 1a 4a
##
##  X.1     1 -1  1  1 -1
##  X.2     3 -1 -1  .  1
##  X.3     2  .  2 -1  .
##  X.4     3  1 -1  . -1
##  X.5     1  1  1  1  1
##  gap> srt1:= CharacterTableWithSortedCharacters( tbl );
##  CharacterTable( "Sym(4)" )
##  gap> List( Irr( srt1 ), Degree );
##  [ 1, 1, 2, 3, 3 ]
##  gap> srt2:= CharacterTableWithSortedClasses( tbl );
##  CharacterTable( "Sym(4)" )
##  gap> SizesCentralizers( tbl );
##  [ 24, 4, 8, 3, 4 ]
##  gap> SizesCentralizers( srt2 );
##  [ 24, 8, 4, 3, 4 ]
##  gap> nsg:= ClassPositionsOfNormalSubgroups( tbl );
##  [ [ 1 ], [ 1, 3 ], [ 1, 3, 4 ], [ 1 .. 5 ] ]
##  gap> srt3:= SortedCharacterTable( tbl, nsg );
##  CharacterTable( "Sym(4)" )
##  gap> nsg:= ClassPositionsOfNormalSubgroups( srt3 );
##  [ [ 1 ], [ 1, 2 ], [ 1 .. 3 ], [ 1 .. 5 ] ]
##  gap> Display( srt3 );
##  Sym(4)
##
##       2  3  3  .  2  2
##       3  1  .  1  .  .
##
##         1a 2a 3a 2b 4a
##      2P 1a 1a 3a 1a 2a
##      3P 1a 2a 1a 2b 4a
##
##  X.1     1  1  1  1  1
##  X.2     1  1  1 -1 -1
##  X.3     2  2 -1  .  .
##  X.4     3 -1  . -1  1
##  X.5     3 -1  .  1 -1
##  gap> ClassPermutation( srt3 );
##  (2,4,3)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="NormalSubgroupClassesInfo">
##  <ManSection>
##  <Attr Name="NormalSubgroupClassesInfo" Arg='tbl'/>
##
##  <Description>
##  Let <A>tbl</A> be the ordinary character table of the group <M>G</M>.
##  Many computations for group characters of <M>G</M> involve computations
##  in normal subgroups or factor groups of <M>G</M>.
##  <P/>
##  In some cases the character table <A>tbl</A> is sufficient;
##  for example questions about a normal subgroup <M>N</M> of <M>G</M> can be
##  answered if one knows the conjugacy classes that form <M>N</M>,
##  e.g., the question whether a character of <M>G</M> restricts
##  irreducibly to <M>N</M>.
##  But other questions require the computation of <M>N</M> or
##  even more information, like the character table of <M>N</M>.
##  <P/>
##  In order to do these computations only once, one stores in the group a
##  record with components to store normal subgroups, the corresponding lists
##  of conjugacy classes, and (if necessary) the factor groups, namely
##  <P/>
##  <List>
##  <Mark><C>nsg</C></Mark>
##  <Item>
##    list of normal subgroups of <M>G</M>, may be incomplete,
##  </Item>
##  <Mark><C>nsgclasses</C></Mark>
##  <Item>
##    at position <M>i</M>, the list of positions of conjugacy
##    classes of <A>tbl</A> forming the <M>i</M>-th entry of the <C>nsg</C>
##    component,
##  </Item>
##  <Mark><C>nsgfactors</C></Mark>
##  <Item>
##    at position <M>i</M>, if bound, the factor group
##    modulo the <M>i</M>-th entry of the <C>nsg</C> component.
##  </Item>
##  </List>
##  <P/>
##  <Ref Func="NormalSubgroupClasses"/>,
##  <Ref Func="FactorGroupNormalSubgroupClasses"/>, and
##  <Ref Func="ClassPositionsOfNormalSubgroup"/>
##  each use these components, and they are the only functions to do so.
##  <P/>
##  So if you need information about a normal subgroup for that you know the
##  conjugacy classes, you should get it using
##  <Ref Func="NormalSubgroupClasses"/>.
##  If the normal subgroup was already used it is just returned, with all the
##  knowledge it contains.  Otherwise the normal subgroup is added to the
##  lists, and will be available for the next call.
##  <P/>
##  For example, if you are dealing with kernels of characters using the
##  <Ref Attr="KernelOfCharacter"/> function you make use of this feature
##  because <Ref Attr="KernelOfCharacter"/> calls
##  <Ref Func="NormalSubgroupClasses"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NormalSubgroupClassesInfo", IsOrdinaryTable, "mutable" );


##############################################################################
##
#F  ClassPositionsOfNormalSubgroup( <tbl>, <N> )
##
##  <#GAPDoc Label="ClassPositionsOfNormalSubgroup">
##  <ManSection>
##  <Func Name="ClassPositionsOfNormalSubgroup" Arg='tbl, N'/>
##
##  <Description>
##  is the list of positions of conjugacy classes of the character table
##  <A>tbl</A> that are contained in the normal subgroup <A>N</A>
##  of the underlying group of <A>tbl</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ClassPositionsOfNormalSubgroup" );


##############################################################################
##
#F  NormalSubgroupClasses( <tbl>, <classes> )
##
##  <#GAPDoc Label="NormalSubgroupClasses">
##  <ManSection>
##  <Func Name="NormalSubgroupClasses" Arg='tbl, classes'/>
##
##  <Description>
##  returns the normal subgroup of the underlying group <M>G</M> of the
##  ordinary character table <A>tbl</A>
##  that consists of those conjugacy classes of <A>tbl</A> whose positions
##  are in the list <A>classes</A>.
##  <P/>
##  If <C>NormalSubgroupClassesInfo( <A>tbl</A> ).nsg</C> does not yet
##  contain the required normal subgroup,
##  and if <C>NormalSubgroupClassesInfo( <A>tbl</A> ).normalSubgroups</C> is
##  bound then the result will be identical to the group in
##  <C>NormalSubgroupClassesInfo( <A>tbl</A> ).normalSubgroups</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NormalSubgroupClasses" );


##############################################################################
##
#F  FactorGroupNormalSubgroupClasses( <tbl>, <classes> )
##
##  <#GAPDoc Label="FactorGroupNormalSubgroupClasses">
##  <ManSection>
##  <Func Name="FactorGroupNormalSubgroupClasses" Arg='tbl, classes'/>
##
##  <Description>
##  is the factor group of the underlying group <M>G</M> of the ordinary
##  character table <A>tbl</A> modulo the normal subgroup of <M>G</M> that
##  consists of those conjugacy classes of <A>tbl</A> whose positions are in
##  the list <A>classes</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= SymmetricGroup( 4 );
##  Sym( [ 1 .. 4 ] )
##  gap> SetName( g, "S4" );
##  gap> tbl:= CharacterTable( g );
##  CharacterTable( S4 )
##  gap> irr:= Irr( g );
##  [ Character( CharacterTable( S4 ), [ 1, -1, 1, 1, -1 ] ),
##    Character( CharacterTable( S4 ), [ 3, -1, -1, 0, 1 ] ),
##    Character( CharacterTable( S4 ), [ 2, 0, 2, -1, 0 ] ),
##    Character( CharacterTable( S4 ), [ 3, 1, -1, 0, -1 ] ),
##    Character( CharacterTable( S4 ), [ 1, 1, 1, 1, 1 ] ) ]
##  gap> kernel:= KernelOfCharacter( irr[3] );;
##  gap> AsSet(kernel);
##  [ (), (1,2)(3,4), (1,3)(2,4), (1,4)(2,3) ]
##  gap> SetName(kernel,"V4");
##  gap> HasNormalSubgroupClassesInfo( tbl );
##  true
##  gap> NormalSubgroupClassesInfo( tbl );
##  rec( nsg := [ V4 ], nsgclasses := [ [ 1, 3 ] ], nsgfactors := [  ] )
##  gap> ClassPositionsOfNormalSubgroup( tbl, kernel );
##  [ 1, 3 ]
##  gap> G := FactorGroupNormalSubgroupClasses( tbl, [ 1, 3 ] );;
##  gap> NormalSubgroupClassesInfo( tbl ).nsgfactors[1] = G;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <ManSection>
##  <Var Name="SupportedLibraryTableComponents"/>
##  <Filt Name="IsLibraryCharacterTableRep" Arg='tbl' Type='Representation'/>
##
##  <Description>
##  Modular library tables may have some components that are meaningless for
##  character tables that know their underlying group.
##  These components do not justify the introduction of operations to fetch
##  them.
##  <P/>
##  Library tables are always complete character tables.
##  Note that in spite of the name, <C>IsLibraryCharacterTableRep</C> is used
##  <E>not</E> only for library tables; for example, the direct product of
##  two tables with underlying groups or a factor table of a character table
##  with underlying group may be in <C>IsLibraryCharacterTableRep</C>.
##  </Description>
##  </ManSection>
##
BindGlobal( "SupportedLibraryTableComponents", [
      # These are used only for Brauer tables, they are set only by `MBT'.
     "basicset",
     "brauertree",
     "decinv",
     "defect",
     "factorblocks",
     "indicator",
    ] );

DeclareRepresentation( "IsLibraryCharacterTableRep", IsAttributeStoringRep,
    SupportedLibraryTableComponents );


#############################################################################
##
#R  IsGenericCharacterTableRep( <tbl> )
##
##  <ManSection>
##  <Filt Name="IsGenericCharacterTableRep" Arg='tbl' Type='Representation'/>
##
##  <Description>
##  generic character tables are a special representation of objects since
##  they provide just some record components.
##  It might be useful to treat them similar to character table like objects,
##  for example to display them.
##  So they belong to the category of nearly character tables.
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsGenericCharacterTableRep",
     IsNearlyCharacterTable and IsComponentObjectRep,
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
#F  CharacterTableFromLibrary( <name>, <param1>, ... )
##
##  The `CharacterTable' methods for a string and optional parameters call
##  `CharacterTableFromLibrary'.
##  We bind this to a dummy function that signals an error.
##
##  (If the package CTblLib is already loaded, for example because the
##  current file is reread, we do not replace the working function.)
##
if not IsBound( CharacterTableFromLibrary ) then
  BindGlobal( "CharacterTableFromLibrary", function( arg )
      Error( "sorry, the GAP Character Table Library is not loaded,\n",
             "call `LoadPackage( \"CTblLib\" )' if you want to use it" );
      end );
fi;
