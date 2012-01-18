#############################################################################
##
#W  mindeg.gd            GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2007,   Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file contains declarations for dealing with information about
##  permutation and matrix representations of minimal degree
##  for selected groups.
##


#############################################################################
##
##  <#GAPDoc Label="subsect:minimality-criteria">
##  <Subsection Label="subsect:minimality-criteria">
##  <Heading>Criteria Used to Compute Minimality Information</Heading>
##
##  The information about the minimal degree of a faithful <E>matrix
##  representation</E> of <M>G</M> in a given characteristic or over a given
##  field in positive characteristic is derived from the relevant (ordinary
##  or modular) character table of <M>G</M>,
##  except in a few cases where this table itself is not known but enough
##  information about the degrees is available in <Cite Key="HL89"/> and
##  <Cite Key="Jan05"/>.
##  <P/>
##  The following criteria are used for deriving the minimal degree of a
##  faithful <E>permutation representation</E> of <M>G</M>
##  from the information in the &GAP; libraries of character tables and of
##  tables of marks.
##  <P/>
##  <List>
##  <Item>
##    If the name of <M>G</M> has the form <C>"A</C><M>n</M><C>"</C> or
##    <C>"A</C><M>n</M><C>.2"</C>
##    (denoting alternating and symmetric groups, respectively)
##    then the minimal degree is <M>n</M>, except if <M>n</M> is smaller than
##    <M>3</M> or <M>2</M>, respectively.
##  </Item>
##  <Item>
##    If the name of <M>G</M> has the form <C>"L2(</C><M>q</M><C>)"</C>
##    (denoting projective special linear groups in dimension two)
##    then the minimal degree is <M>q + 1</M>,
##    except if <M>q \in \{ 2, 3, 5, 7, 9, 11 \}</M>,
##    see&nbsp;<Cite Key="Hup67" Where="Satz II.8.28"/>.
##  </Item>
##  <Item>
##    If the largest maximal subgroup of <M>G</M> is core-free
##    then the index of this subgroup is the minimal degree.
##    (This is used when the two character tables in question and the class
##    fusion are available in &GAP;'s Character Table Library
##    (<Cite Key="CTblLib1.1.3"/>);
##    this happens for many character tables of simple groups.)
##  </Item>
##  <Item>
##    If <M>G</M> has a unique minimal normal subgroup then each minimal
##    faithful permutation representation is transitive.
##    <P/>
##    In this case, the minimal degree can be computed directly from the
##    information in the table of marks of <M>G</M> if this is available in
##    &GAP;'s Library of Tables of Marks (<Cite Key="TomLib"/>).
##    <P/>
##    Suppose that the largest maximal subgroup of <M>G</M> is not core-free
##    but simple and normal in <M>G</M>, and that the other maximal subgroups
##    of <M>G</M> are core-free.
##    In this case, we take the minimum of the indices of the core-free
##    maximal subgroups and of the product of index and minimal degree of
##    the normal maximal subgroup.
##    (This suffices since no core-free subgroup of the whole group can
##    contain a nontrivial normal subgroup of a normal maximal subgroup.)
##    <P/>
##    Let <M>N</M> be the unique minimal normal subgroup of <M>G</M>,
##    and assume that <M>G/N</M> is simple and has minimal degree <M>n</M>,
##    say.
##    If there is a subgroup <M>U</M> of index <M>n \cdot |N|</M> in <M>G</M>
##    that intersects <M>N</M> trivially
##    then the minimal degree of <M>G</M> is <M>n \cdot |N|</M>.
##    (This is used for the case that <M>N</M> is central in <M>G</M>
##    and <M>N \times U</M> occurs as a subgroup of <M>G</M>.)
##  </Item>
##  <Item>
##    If we know a subgroup of <M>G</M> whose minimal degree is <M>n</M>,
##    say, and if we know either (a class fusion from) a core-free subgroup
##    of index <M>n</M> in <M>G</M> or a faithful permutation representation
##    of degree <M>n</M> for <M>G</M>
##    then <M>n</M> is the minimal degree for <M>G</M>.
##    (This happens often for tables of almost simple groups.)
##  </Item>
##  </List>
##  </Subsection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  MinimalPermutationRepresentationInfo( <grpname> )
##
DeclareGlobalFunction( "MinimalPermutationRepresentationInfo" );


#############################################################################
##
#F  MinimalRepresentationInfo( <grpname>, NrMovedPoints[, <mode>] )
#F  MinimalRepresentationInfo( <grpname>, Characteristic, <p>[, <mode>] )
#F  MinimalRepresentationInfo( <grpname>, Size, <q>[, <mode>] )
##
##  <#GAPDoc Label="MinimalRepresentationInfo">
##  <ManSection>
##  <Func Name="MinimalRepresentationInfo" Arg='grpname, conditions'/>
##
##  <Returns>
##  a record with the components <C>value</C> and <C>source</C>,
##  or <K>fail</K>
##  </Returns>
##  <Description>
##  Let <A>grpname</A> be the &GAP; name of a group <M>G</M>, say.
##  If the information described by <A>conditions</A> about minimal
##  representations of this group can be computed or is stored
##  then <Ref Func="MinimalRepresentationInfo"/> returns a record with the
##  components <C>value</C> and <C>source</C>,
##  otherwise <K>fail</K> is returned.
##  <P/>
##  The following values for <A>conditions</A> are supported.
##  <P/>
##  <List>
##  <Item>
##    If <A>conditions</A> is <Ref Attr="NrMovedPoints" BookName="ref"/>
##    then <C>value</C>, if known, is the degree of a minimal faithful
##    (not necessarily transitive) permutation representation for <M>G</M>.
##  </Item>
##  <Item>
##    If <A>conditions</A> consists of
##    <Ref Attr="Characteristic" BookName="ref"/> and a prime integer
##    <A>p</A> then <C>value</C>, if known, is the dimension of a minimal
##    faithful (not necessarily irreducible) matrix representation
##    in characteristic <A>p</A> for <M>G</M>.
##  </Item>
##  <Item>
##    If <A>conditions</A> consists of <Ref Attr="Size" BookName="ref"/> and
##    a prime power <A>q</A> then <C>value</C>, if known, is the dimension
##    of a minimal faithful (not necessarily irreducible)
##    matrix representation over the field of size <A>q</A> for <M>G</M>.
##  </Item>
##  </List>
##  <P/>
##  In all cases, the value of the component <C>source</C> is a list of
##  strings that describe sources of the information,
##  which can be the ordinary or modular character table of <M>G</M>
##  (see <Cite Key="CCN85"/>, <Cite Key="JLPW95"/>, <Cite Key="HL89"/>),
##  the table of marks of <M>G</M>, or <Cite Key="Jan05"/>.
##  For an overview of minimal degrees of faithful matrix representations for
##  sporadic simple groups and their covering groups, see also
##  <P/>
##  <URL>http://www.math.rwth-aachen.de/~MOC/mindeg/</URL>.
##  <P/>
##  Note that <Ref Func="MinimalRepresentationInfo"/> cannot provide any
##  information about minimal representations over prescribed fields in
##  characteristic zero.
##  <P/>
##  Information about groups that occur in the <Package>AtlasRep</Package>
##  package is precomputed in <Ref Var="MinimalRepresentationInfoData"/>,
##  so the packages <Package>CTblLib</Package> and <Package>TomLib</Package>
##  are not needed when <Ref Func="MinimalRepresentationInfo"/> is called for
##  these groups.
##  (The only case that is not covered by this list is that one asks for the
##  minimal degree of matrix representations over a prescribed field in
##  characteristic coprime to the group order.)
##  <P/>
##  One of the following strings can be given as an additional last argument.
##  <P/>
##  <List>
##  <Mark><C>"cache"</C></Mark>
##  <Item>
##    means that the function tries to compute (and then store) values that
##    are not stored in <Ref Var="MinimalRepresentationInfoData"/>,
##    but stored values are preferred; this is also the default.
##  </Item>
##  <Mark><C>"lookup"</C></Mark>
##  <Item>
##    means that stored values are returned but the function
##    does not attempt to compute values that are not stored in
##    <Ref Var="MinimalRepresentationInfoData"/>.
##  </Item>
##  <Mark><C>"recompute"</C></Mark>
##  <Item>
##    means that the function always tries to compute the
##    desired value, and checks the result against stored values.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> MinimalRepresentationInfo( "A5", NrMovedPoints );
##  rec( source := [ "computed (alternating group)", "computed (char. table)",
##        "computed (subgroup tables)",
##        "computed (subgroup tables, known repres.)",
##        "computed (table of marks)" ], value := 5 )
##  gap> MinimalRepresentationInfo( "A5", Characteristic, 2 );
##  rec( source := [ "computed (char. table)" ], value := 2 )
##  gap> MinimalRepresentationInfo( "A5", Size, 2 );
##  rec( source := [ "computed (char. table)" ], value := 4 )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MinimalRepresentationInfo" );


#############################################################################
##
#V  MinimalRepresentationInfoData
##
##  <#GAPDoc Label="MinimalRepresentationInfoData">
##  <ManSection>
##  <Var Name="MinimalRepresentationInfoData"/>
##
##  <Description>
##  This is a record whose components are &GAP; names of groups for which
##  information about minimal permutation and matrix representations were
##  known in advance or have been computed in the current &GAP; session.
##  The value for the group <M>G</M>, say,
##  is a record with the following components.
##  <P/>
##  <List>
##  <Mark><C>NrMovedPoints</C></Mark>
##  <Item>
##    a record with the components <C>value</C> (the degree of a smallest
##    faithful permutation representation of <M>G</M>)
##    and <C>source</C> (a string describing the source of this information).
##  </Item>
##  <Mark><C>Characteristic</C></Mark>
##  <Item>
##    a record whose components are at most <C>0</C> and strings
##    corresponding to prime integers, each bound to a record with the
##    components <C>value</C> (the degree of a smallest faithful matrix
##    representation of <M>G</M> in this characteristic)
##    and <C>source</C> (a string describing the source of this information).
##  </Item>
##  <Mark><C>CharacteristicAndSize</C></Mark>
##  <Item>
##    a record whose components are strings corresponding
##    to prime integers <A>p</A>, each bound to a record with the components
##    <C>sizes</C> (a list of powers <A>q</A> of <A>p</A>),
##    <C>dimensions</C> (the corresponding list of minimal dimensions of
##    faithful matrix representations of <M>G</M> over a field of size
##    <A>q</A>),
##    <C>sources</C> (the corresponding list of strings describing the source
##    of this information), and
##    <C>complete</C> (a record with the components <C>val</C>
##    (<K>true</K> if the minimal dimension over <E>any</E> finite field in
##    characteristic <A>p</A> can be derived from the values in the record,
##    and <K>false</K> otherwise) and <C>source</C> (a string describing the
##    source of this information)).
##  </Item>
##  </List>
##  <P/>
##  The values are set by <Ref Func="SetMinimalRepresentationInfo"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We want to delay reading the data until they are actually accessed.
##
DeclareAutoreadableVariables( "atlasrep", "gap/mindeg.g",
    [ "MinimalRepresentationInfoData" ] );


#############################################################################
##
#F  SetMinimalRepresentationInfo( <grpname>, <op>, <value>, <source> )
##
##  <#GAPDoc Label="SetMinimalRepresentationInfo">
##  <ManSection>
##  <Func Name="SetMinimalRepresentationInfo"
##   Arg='grpname, op, value, source'/>
##
##  <Returns>
##  <K>true</K> if the values were successfully set,
##  <K>false</K> if stored values contradict the given ones.
##  </Returns>
##  <Description>
##  This function sets an entry in <Ref Var="MinimalRepresentationInfoData"/>
##  for the group <M>G</M>, say, with &GAP; name <A>grpname</A>.
##  <P/>
##  Supported values for <A>op</A> are
##  <P/>
##  <List>
##  <Item>
##    <C>"NrMovedPoints"</C>
##    (see <Ref Attr="NrMovedPoints" BookName="ref"/>),
##    which means that <A>value</A> is the degree of minimal faithful
##    (not necessarily transitive) permutation representations of <M>G</M>,
##  </Item>
##  <Item>
##    a list of length two with first entry
##    <C>"Characteristic"</C>
##    (see <Ref Attr="Characteristic" BookName="ref"/>)
##    and second entry <A>char</A> either zero or a prime integer,
##    which means that <A>value</A> is the dimension of minimal faithful
##    (not necessarily irreducible) matrix representations of <M>G</M>
##    in characteristic <A>char</A>,
##  </Item>
##  <Item>
##    a list of length two with first entry
##    <C>"Size"</C>
##    (see <Ref Attr="Size" BookName="ref"/>)
##    and second entry a prime power <A>q</A>,
##    which means that <A>value</A> is the dimension of minimal faithful
##    (not necessarily irreducible) matrix representations of <M>G</M>
##    over the field with <A>q</A> elements, and
##  </Item>
##  <Item>
##    a list of length three with first entry
##    <C>"Characteristic"</C>
##    (see <Ref Attr="Characteristic" BookName="ref"/>),
##    second entry a prime integer <A>p</A>,
##    and third entry the string <C>"complete"</C>,
##    which means that the information stored for characteristic <A>p</A>
##    is complete in the sense that for any given power <M>q</M> of <A>p</A>,
##    the minimal faithful degree over the field with <M>q</M> elements
##    equals that for the largest stored field size of which <M>q</M> is a
##    power.
##  </Item>
##  </List>
##  <P/>
##  In each case,
##  <A>source</A> is a string describing the source of the data;
##  <E>computed</E> values are detected from the prefix <C>"comp"</C>
##  of <A>source</A>.
##  <P/>
##  If the intended value is already stored and differs from <A>value</A>
##  then an error message is printed.
##  <P/>
##  <Example><![CDATA[
##  gap> SetMinimalRepresentationInfo( "A5", "NrMovedPoints", 5,
##  >      "computed (alternating group)" );
##  true
##  gap> SetMinimalRepresentationInfo( "A5", [ "Characteristic", 0 ], 3,
##  >      "computed (char. table)" );
##  true
##  gap> SetMinimalRepresentationInfo( "A5", [ "Characteristic", 2 ], 2,
##  >      "computed (char. table)" );
##  true
##  gap> SetMinimalRepresentationInfo( "A5", [ "Size", 2 ], 4,
##  >      "computed (char. table)" );
##  true
##  gap> SetMinimalRepresentationInfo( "A5", [ "Size", 4 ], 2,
##  >      "computed (char. table)" );
##  true
##  gap> SetMinimalRepresentationInfo( "A5", [ "Characteristic", 3 ], 3,
##  >      "computed (char. table)" );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SetMinimalRepresentationInfo" );


#############################################################################
##
#F  ComputedMinimalRepresentationInfo()
##
##  <ManSection>
##  <Func Name="ComputedMinimalRepresentationInfo" Arg=''/>
##
##  <Returns>
##  a records in the format of
##  <Ref Var="AtlasOfGroupRepresentationsInfoData"/>.
##  </Returns>
##  <Description>
##  For the groups listed in the <C>GAPnames</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfoData"/>,
##  <Ref Func="MinimalRepresentationInfo"/> is called with the last argument
##  <C>"recompute"</C>, and with the relevant conditions.
##  The completeness info is set for a characteristic if the Brauer table
##  of the group proves that all relevant values are known.
##  <P/>
##  A record with the recomputed values is returned,
##  the variable <Ref Var="MinimalRepresentationInfoData"/> itself is not
##  changed.
##  <P/>
##  Information is printed about differences between the stored and the
##  computed value.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ComputedMinimalRepresentationInfo" );


#############################################################################
##
#F  StringOfMinimalRepresentationInfoData( <record> )
##
##  <ManSection>
##  <Func Name="StringOfMinimalRepresentationInfoData" Arg='record'/>
##
##  <Returns>
##  a string that describes the contents of <A>record</A>.
##  </Returns>
##  <Description>
##  Let <A>record</A> be a record in the format of
##  <Ref Var="MinimalRepresentationInfoData"/>.
##  This function returns a string that contains the assignments of values
##  with <Ref Func="SetMinimalRepresentationInfo"/>,
##  as given in the package's file <F>gap/mindeg.g</F>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "StringOfMinimalRepresentationInfoData" );


#############################################################################
##
#E

