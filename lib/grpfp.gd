#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Volkmar Felsch.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##


#############################################################################
##
#V  CosetTableDefaultLimit
##
##  <#GAPDoc Label="CosetTableDefaultLimit">
##  <ManSection>
##  <Var Name="CosetTableDefaultLimit"/>
##
##  <Description>
##  is the default number of cosets with which any coset table is
##  initialized before doing a coset enumeration.
##  <P/>
##  The function performing this coset enumeration will automatically extend
##  the table whenever necessary (as long as the number of cosets does not
##  exceed the value of <Ref Var="CosetTableDefaultMaxLimit"/>),
##  but this is an expensive operation. Thus, if you change the value of
##  <Ref Var="CosetTableDefaultLimit"/>, you should set it to a number of
##  cosets that you expect to be sufficient for your subsequent
##  coset enumerations.
##  On the other hand, if you make it too large, your job will unnecessarily
##  waste a lot of space.
##  <P/>
##  The default value of <Ref Var="CosetTableDefaultLimit"/> is <M>1000</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
CosetTableDefaultLimit := 1000;
if IsHPCGAP then
    MakeThreadLocal("CosetTableDefaultLimit");
fi;


#############################################################################
##
#V  CosetTableDefaultMaxLimit
##
##  <#GAPDoc Label="CosetTableDefaultMaxLimit">
##  <ManSection>
##  <Var Name="CosetTableDefaultMaxLimit"/>
##
##  <Description>
##  is the default limit for the number of cosets allowed in a coset
##  enumeration.
##  <P/>
##  A coset enumeration will not finish if the subgroup does not have finite
##  index, and even if it has it may take many more intermediate cosets than
##  the actual index of the subgroup is. To avoid a coset enumeration
##  <Q>running away</Q> therefore &GAP; has a <Q>safety stop</Q> built in.
##  This is controlled by the global variable
##  <Ref Var="CosetTableDefaultMaxLimit"/>.
##  <P/>
##  If this number of cosets is reached, &GAP; will issue an error message
##  and prompt the user to either continue the calculation or to stop it.
##  The default value is <M>4096000</M>.
##  <P/>
##  See also the description of the options to
##  <Ref Func="CosetTableFromGensAndRels"/>.
##  <P/>
##  <Log><![CDATA[
##  gap> f := FreeGroup( "a", "b" );;
##  gap> u := Subgroup( f, [ f.2 ] );
##  Group([ b ])
##  gap> Index( f, u );
##  Error, the coset enumeration has defined more than 4096000 cosets
##   called from
##  TCENUM.CosetTableFromGensAndRels( fgens, grels, fsgens ) called from
##  CosetTableFromGensAndRels( fgens, grels, fsgens ) called from
##  TryCosetTableInWholeGroup( H ) called from
##  CosetTableInWholeGroup( H ) called from
##  IndexInWholeGroup( H ) called from
##  ...
##  Entering break read-eval-print loop ...
##  type 'return;' if you want to continue with a new limit of 8192000 cosets,
##  type 'quit;' if you want to quit the coset enumeration,
##  type 'maxlimit := 0; return;' in order to continue without a limit
##  brk> quit;
##  ]]></Log>
##  <P/>
##  At this point, a <K>break</K>-loop
##  (see Section&nbsp;<Ref Sect="Break Loops"/>) has been entered.
##  The line beginning <C>Error</C> tells you why this occurred.
##  The next seven lines occur if <Ref Func="OnBreak"/> has its default value
##  <Ref Func="Where"/>.
##  They explain, in this case,
##  how &GAP; came to be doing a coset enumeration.
##  Then you are given a number of options of how to escape the
##  <K>break</K>-loop:
##  you can either continue the calculation with a larger
##  number of permitted cosets, stop the calculation if you don't
##  expect the enumeration to finish (like in the example above), or continue
##  without a limit on the number of cosets. (Choosing the first option will,
##  of course, land you back in a <K>break</K>-loop. Try it!)
##  <P/>
##  Setting <Ref Var="CosetTableDefaultMaxLimit"/>
##  (or the <C>max</C> option value, for any function that invokes a coset
##  enumeration) to <Ref Var="infinity"/> (or to <M>0</M>) will force all
##  coset enumerations to continue until
##  they either get a result or exhaust the whole available space.
##  For example, each of the following two inputs
##  <P/>
##  <Listing><![CDATA[
##  gap> CosetTableDefaultMaxLimit := 0;;
##  gap> Index( f, u );
##  ]]></Listing>
##  <P/>
##  or
##  <P/>
##  <Listing><![CDATA[
##  gap> Index( f, u : max := 0 );
##  ]]></Listing>
##  <P/>
##  have essentially the same effect as choosing the third option
##  (typing: <C>maxlimit := 0; return;</C>) at the <C>brk></C> prompt above
##  (instead of <C>quit;</C>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
CosetTableDefaultMaxLimit := 2^12*1000;
if IsHPCGAP then
    MakeThreadLocal("CosetTableDefaultMaxLimit");
fi;


#############################################################################
##
#V  CosetTableStandard
##
##  <#GAPDoc Label="CosetTableStandard">
##  <ManSection>
##  <Var Name="CosetTableStandard"/>
##
##  <Description>
##  specifies the definition of a <E>standard coset table</E>. It is used
##  whenever coset tables or augmented coset tables are created. Its value
##  may be <C>"lenlex"</C> or <C>"semilenlex"</C>.
##  If it is <C>"lenlex"</C> coset tables will be standardized using
##  all their columns as defined in Charles Sims' book
##  (this is the new default standard of &GAP;). If it is <C>"semilenlex"</C>
##  they will be standardized using only their generator columns (this was
##  the original &GAP; standard).
##  The default value of <Ref Var="CosetTableStandard"/> is <C>"lenlex"</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
if IsHPCGAP then
    MakeThreadLocal("CosetTableStandard");
    BindThreadLocal("CosetTableStandard", MakeImmutable("lenlex"));
else
    CosetTableStandard := MakeImmutable("lenlex");
fi;


#############################################################################
##
#V  InfoFpGroup
##
##  <#GAPDoc Label="InfoFpGroup">
##  <ManSection>
##  <InfoClass Name="InfoFpGroup"/>
##
##  <Description>
##  The info class for functions dealing with finitely presented groups is
##  <Ref InfoClass="InfoFpGroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoFpGroup" );


#############################################################################
##
#C  IsSubgroupFgGroup( <H> )
##
##  <ManSection>
##  <Filt Name="IsSubgroupFgGroup" Arg='H' Type='Category'/>
##
##  <Description>
##  This category (intended for future extensions) represents (subgroups of)
##  a finitely generated group, whose elements are represented as words in
##  the generators. However we do not necessarily have a set or relators.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsSubgroupFgGroup", IsGroup );

#############################################################################
##
#C  IsSubgroupFpGroup( <H> )
##
##  <#GAPDoc Label="IsSubgroupFpGroup">
##  <ManSection>
##  <Filt Name="IsSubgroupFpGroup" Arg='H' Type='Category'/>
##
##  <Description>
##  is the category for finitely presented groups
##  or subgroups of a finitely presented group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsSubgroupFpGroup", IsSubgroupFgGroup );

# implications for the full family
InstallTrueMethod(CanEasilyTestMembership, IsSubgroupFgGroup and IsWholeFamily);

#############################################################################
##
#F  IsFpGroup(<G>)
##
##  <#GAPDoc Label="IsFpGroup">
##  <ManSection>
##  <Filt Name="IsFpGroup" Arg='G'/>
##
##  <Description>
##  is a synonym for
##  <C>IsSubgroupFpGroup(<A>G</A>) and IsGroupOfFamily(<A>G</A>)</C>.
##  <P/>
##  Free groups are a special case of finitely presented groups,
##  namely finitely presented groups with no relators.
##
##  <P/>
##  Note that <C>FreeGroup(infinity)</C> (which exists e.g. for purposes of
##  rewriting presentations with further generators) satisfies this filter,
##  though of course it is not finitely generated (and thus not finitely
##  presented). <C>IsFpGroup</C> thus is not a proper property test and
##  slightly misnamed for the sake of its most prominent uses.
##  <P/>
##  Another special case are groups given by polycyclic presentations.
##  &GAP; uses a special representation for these groups which is created
##  in a different way.
##  See chapter <Ref Chap="Pc Groups"/> for details.
##  <Example><![CDATA[
##  gap> g:=FreeGroup(2);
##  <free group on the generators [ f1, f2 ]>
##  gap> IsFpGroup(g);
##  true
##  gap> h:=CyclicGroup(2);
##  <pc group of size 2 with 1 generator>
##  gap> IsFpGroup(h);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsFpGroup", IsSubgroupFpGroup and IsGroupOfFamily );

#############################################################################
##
#C  IsElementOfFpGroup
##
##  <ManSection>
##  <Filt Name="IsElementOfFpGroup" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsElementOfFpGroup",
    IsMultiplicativeElementWithInverse and IsAssociativeElement );

#############################################################################
##
#C  IsElementOfFpGroupCollection
##
##  <ManSection>
##  <Filt Name="IsElementOfFpGroupCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Filt Name="IsElementOfFpGroupFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryFamily( "IsElementOfFpGroup" );


#############################################################################
##
#A  FpElmEqualityMethod(<fam>)
##
##  <ManSection>
##  <Attr Name="FpElmEqualityMethod" Arg='fam'/>
##
##  <Description>
##  If <A>fam</A> is the elements family of a finitely presented group this
##  attribute returns a function <C>equal(<A>left</A>, <A>right</A>)</C> that will be
##  used to compare elements in <A>fam</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "FpElmEqualityMethod",IsElementOfFpGroupFamily);

#############################################################################
##
#A  FpElmComparisonMethod(<fam>)
##
##  <#GAPDoc Label="FpElmComparisonMethod">
##  <ManSection>
##  <Attr Name="FpElmComparisonMethod" Arg='fam'/>
##
##  <Description>
##  If <A>fam</A> is the elements family of a finitely presented group this
##  attribute returns a function <C>smaller(<A>left</A>, <A>right</A>)</C>
##  that will be used to compare elements in <A>fam</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FpElmComparisonMethod",IsElementOfFpGroupFamily);

#############################################################################
##
#F  SetReducedMultiplication(<f>)
#F  SetReducedMultiplication(<e>)
#F  SetReducedMultiplication(<fam>)
##
##  <#GAPDoc Label="SetReducedMultiplication">
##  <ManSection>
##  <Func Name="SetReducedMultiplication" Arg='obj'/>
##
##  <Description>
##  For an FpGroup <A>obj</A>, an element <A>obj</A> of it or the family
##  <A>obj</A> of its elements,
##  this function will force immediate reduction when multiplying, keeping
##  words short at extra cost per multiplication.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SetReducedMultiplication");

#############################################################################
##
#A  FpElementNFFunction(<fam>)
##
##  <ManSection>
##  <Attr Name="FpElementNFFunction" Arg='fam'/>
##
##  <Description>
##  If <A>fam</A> is the elements family of a finitely presented group this
##  attribute returns a function <A>f</A>, which, when applied to the
##  <b>underlying element</b> of an element of <A>fam</A> returns a <b>normal
##  form</b> (whose format is not defined and will differ on the method used).
##  This normal form can be used (and is used by
##  <Ref Func="SetReducedMultiplication"/>) to
##  compare elements or to reduce long products.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "FpElementNFFunction",IsElementOfFpGroupFamily);

# #############################################################################
# ##
# #A  FpElmKBRWS(<fam>)
# ##
# ##  <ManSection>
# ##  <Attr Name="FpElmKBRWS" Arg='fam'/>
# ##
# ##  <Description>
# ##  If <A>fam</A> is the elements family of a finitely presented group this
# ##  attribute returns a list [<A>iso</A>,<A>k</A>,<A>id</A>] where <A>iso</A> is a isomorphism to an
# ##  fp monoid, <A>k</A> a confluent rewriting system for the image of <A>iso</A> and
# ##  <A>id</A> the element in the free monoid corresponding to the image of the
# ##  identity element under <A>iso</A>.
# ##  </Description>
# ##  </ManSection>
# ##
#DeclareAttribute( "FpElmKBRWS",IsElementOfFpGroupFamily);


#############################################################################
##
#O  ElementOfFpGroup( <fam>, <word> )
##
##  <#GAPDoc Label="ElementOfFpGroup">
##  <ManSection>
##  <Oper Name="ElementOfFpGroup" Arg='fam, word'/>
##
##  <Description>
##  If <A>fam</A> is the elements family of a finitely presented group
##  and <A>word</A> is a word in the free generators underlying this
##  finitely presented group, this operation creates the element with the
##  representative <A>word</A> in the free group.
##  <Example><![CDATA[
##  gap> ge := ElementOfFpGroup( FamilyObj( g.1 ), f.1*f.2 );
##  a*b
##  gap> ge in f;
##  false
##  gap> ge in g;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ElementOfFpGroup",
    [ IsElementOfFpGroupFamily, IsAssocWordWithInverse ] );


#############################################################################
##
#V  TCENUM
#V  GAPTCENUM
##
##  <ManSection>
##  <Var Name="TCENUM"/>
##  <Var Name="GAPTCENUM"/>
##
##  <Description>
##  TCENUM is a global record variable whose components contain functions
##  used for coset enumeration. By default <C>TCENUM</C> is assigned to
##  <C>GAPTCENUM</C>, which contains the coset enumeration functions provided by
##  the GAP library.
##  </Description>
##  </ManSection>
##
BindGlobal("GAPTCENUM",rec(name:="GAP Felsch-type enumerator"));
TCENUM:=GAPTCENUM;

#############################################################################
##
#F  CosetTableFromGensAndRels( <fgens>, <grels>, <fsgens> )
##
##  <#GAPDoc Label="CosetTableFromGensAndRels">
##  <ManSection>
##  <Func Name="CosetTableFromGensAndRels" Arg='fgens, grels, fsgens'/>
##
##  <Description>
##  <Index Key="TCENUM"><C>TCENUM</C></Index>
##  <Index Key="GAPTCENUM"><C>GAPTCENUM</C></Index>
##  is an internal function which is called by the functions
##  <Ref Oper="CosetTable"/>, <Ref Attr="CosetTableInWholeGroup"/>
##  and others.
##  It is, in fact, the workhorse that performs a Todd-Coxeter
##  coset enumeration.
##  <A>fgens</A> must be a set of free generators and <A>grels</A> a set
##  of relators in these generators. <A>fsgens</A> are subgroup generators
##  expressed as words in these generators. The function returns a coset
##  table with respect to <A>fgens</A>.
##  <P/>
##  <Ref Func="CosetTableFromGensAndRels"/> will call
##  <C>TCENUM.CosetTableFromGensAndRels</C>.
##  This makes it possible to replace the built-in coset enumerator with
##  another one by assigning <C>TCENUM</C> to another record.
##  <P/>
##  The library version which is used by default performs a standard Felsch
##  strategy coset enumeration. You can call this function explicitly as
##  <C>GAPTCENUM.CosetTableFromGensAndRels</C> even if other coset enumerators
##  are installed.
##  <P/>
##  The expected parameters are
##  <List>
##  <Mark><A>fgens</A></Mark>
##  <Item>
##  generators of the free group <A>F</A>
##  </Item>
##  <Mark><A>grels</A></Mark>
##  <Item>
##  relators as words in <A>F</A>
##  </Item>
##  <Mark><A>fsgens</A></Mark>
##  <Item>
##  subgroup generators as words in <A>F</A>.
##  </Item>
##  </List>
##  <P/>
##  <Ref Func="CosetTableFromGensAndRels"/> processes two options (see
##  chapter&nbsp;<Ref Chap="Options Stack"/>):
##  <List>
##  <Mark><C>max</C></Mark>
##  <Item>
##    The limit of the number of cosets to be defined. If the
##    enumeration does not finish with this number of cosets, an error is
##    raised and the user is asked whether she wants to continue. The
##    default value is the value given in the variable
##    <C>CosetTableDefaultMaxLimit</C>. (Due to the algorithm the actual
##    limit used can be a bit higher than the number given.)
##  </Item>
##  <Mark><C>silent</C></Mark>
##  <Item>
##    If set to <K>true</K> the algorithm will not raise the error
##    mentioned under option <C>max</C> but silently return <K>fail</K>.
##    This can be useful if an enumeration is only wanted unless it becomes
##    too big.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("CosetTableFromGensAndRels");


#############################################################################
##
#F  IndexCosetTab( <table> )
##
##  <ManSection>
##  <Func Name="IndexCosetTab" Arg='table'/>
##
##  <Description>
##  this function returns <C>Length(table[1])</C>, but the table might be empty
##  for a no-generator group, in which case 1 is returned.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("IndexCosetTab");

#############################################################################
##
#F  StandardizeTable( <table>, <standard> )
##
##  <#GAPDoc Label="StandardizeTable">
##  <ManSection>
##  <Func Name="StandardizeTable" Arg='table, standard'/>
##
##  <Description>
##  standardizes the given coset table <A>table</A>. The second argument is
##  optional. It defines the standard to be used, its values may be
##  <C>"lenlex"</C> or <C>"semilenlex"</C> specifying the new or the old
##  convention, respectively.
##  If no value for the parameter <A>standard</A> is provided the
##  function will use the global variable <Ref Var="CosetTableStandard"/>
##  instead.
##  Note that the function alters the given table, it does not create a copy.
##  <Example><![CDATA[
##  gap> StandardizeTable( tab, "semilenlex" );
##  gap> PrintArray( TransposedMat( tab ) );
##  [ [  1,  1,  2,  4 ],
##    [  3,  3,  4,  1 ],
##    [  2,  2,  3,  3 ],
##    [  5,  5,  1,  2 ],
##    [  4,  4,  5,  5 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("StandardizeTable");

#############################################################################
##
#F  StandardizeTable2( <table>, <table2>, <standard> )
##
##  <ManSection>
##  <Func Name="StandardizeTable2" Arg='table, table2, standard'/>
##
##  <Description>
##  standardizes the augmented coset table given by <A>table</A> and <A>table2</A>.
##  The third argument is optional. It defines the standard to be used, its
##  values may be <C>"lenlex"</C> or <C>"semilenlex"</C> specifying the new or the old
##  convention, respectively. If no value for the parameter <A>standard</A> is
##  provided the function will use the global variable <C>CosetTableStandard</C>
##  instead. Note that the function alters the given table, it does not
##  create a copy.
##  <P/>
##  Warning: The function alters just the two tables. Any further lists
##  involved in the object <E>augmented coset table</E> which refer to these two
##  tables will not be updated.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("StandardizeTable2");


#############################################################################
##
#A  CosetTableInWholeGroup(< H >)
#O  TryCosetTableInWholeGroup(< H >)
##
##  <#GAPDoc Label="CosetTableInWholeGroup">
##  <ManSection>
##  <Attr Name="CosetTableInWholeGroup" Arg='H'/>
##  <Oper Name="TryCosetTableInWholeGroup" Arg='H'/>
##
##  <Description>
##  is equivalent to <C>CosetTable(<A>G</A>,<A>H</A>)</C> where <A>G</A> is
##  the (unique)  finitely presented group such that <A>H</A> is a subgroup
##  of <A>G</A>.
##  It overrides a <C>silent</C> option
##  (see&nbsp;<Ref Func="CosetTableFromGensAndRels"/>) with <K>false</K>.
##  <P/>
##  The variant <Ref Oper="TryCosetTableInWholeGroup"/> does not override the
##  <C>silent</C> option with <K>false</K> in case a coset table is only
##  wanted if not too expensive.
##  It will store a result that is not <K>fail</K> in the attribute
##  <Ref Attr="CosetTableInWholeGroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CosetTableInWholeGroup", IsGroup );
DeclareOperation( "TryCosetTableInWholeGroup", [IsGroup] );

InstallTrueMethod(CanEasilyTestMembership,
  IsSubgroupFpGroup and HasCosetTableInWholeGroup);


#############################################################################
##
#A  CosetTableNormalClosureInWholeGroup(< H >)
##
##  <ManSection>
##  <Attr Name="CosetTableNormalClosureInWholeGroup" Arg='H'/>
##
##  <Description>
##  is equivalent to <C>CosetTableNormalClosure(<A>G</A>,<A>H</A>)</C> where <A>G</A> is the
##  (unique) finitely presented group such that <A>H</A> is a subgroup of <A>G</A>.
##  It overrides a <C>silent</C> option (see&nbsp;<Ref Func="CosetTableFromGensAndRels"/>) with
##  <K>false</K>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "CosetTableNormalClosureInWholeGroup", IsGroup );


#############################################################################
##
#F  TracedCosetFpGroup( <tab>, <word>, <pt> )
##
##  <#GAPDoc Label="TracedCosetFpGroup">
##  <ManSection>
##  <Func Name="TracedCosetFpGroup" Arg='tab, word, pt'/>
##
##  <Description>
##  Traces the coset number <A>pt</A> under the word <A>word</A> through the
##  coset table <A>tab</A>.
##  (Note: <A>word</A> must be in the free group, use
##  <Ref Oper="UnderlyingElement" Label="fp group elements"/> if in doubt.)
##  <Example><![CDATA[
##  gap> TracedCosetFpGroup(tab,UnderlyingElement(g.1),2);
##  4
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TracedCosetFpGroup");


#############################################################################
##
#F  SubgroupOfWholeGroupByCosetTable( <fpfam>, <tab> )
##
##  <#GAPDoc Label="SubgroupOfWholeGroupByCosetTable">
##  <ManSection>
##  <Func Name="SubgroupOfWholeGroupByCosetTable" Arg='fpfam, tab'/>
##
##  <Description>
##  takes a family <A>fpfam</A> of an FpGroup and a standardized coset
##  table <A>tab</A>
##  and returns the subgroup of <A>fpfam</A><C>!.wholeGroup</C> defined by
##  this coset table. The function will not check whether the coset table is
##  standardized.
##  See also&nbsp;<Ref Oper="CosetTableBySubgroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SubgroupOfWholeGroupByCosetTable");


#############################################################################
##
#F  SubgroupOfWholeGroupByQuotientSubgroup( <fpfam>, <Q>, <U> )
##
##  <#GAPDoc Label="SubgroupOfWholeGroupByQuotientSubgroup">
##  <ManSection>
##  <Func Name="SubgroupOfWholeGroupByQuotientSubgroup" Arg='fpfam, Q, U'/>
##
##  <Description>
##  takes a FpGroup family <A>fpfam</A>, a finitely generated group <A>Q</A>
##  such that the fp generators of <A>fpfam</A> can be mapped by an
##  epimorphism <M>phi</M> onto the <Ref Attr="GeneratorsOfGroup"/> value
##  of <A>Q</A>, and a subgroup <A>U</A> of <A>Q</A>.
##  It returns the subgroup of <A>fpfam</A><C>!.wholeGroup</C> which is
##  the full preimage of <A>U</A> under <M>phi</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SubgroupOfWholeGroupByQuotientSubgroup");

#############################################################################
##
#R  IsSubgroupOfWholeGroupByQuotientRep(<G>)
##
##  <#GAPDoc Label="IsSubgroupOfWholeGroupByQuotientRep">
##  <ManSection>
##  <Filt Name="IsSubgroupOfWholeGroupByQuotientRep" Arg='G'
##   Type='Representation'/>
##
##  <Description>
##  is the representation for subgroups of an FpGroup, given by a quotient
##  subgroup. The components <A>G</A><C>!.quot</C> and <A>G</A><C>!.sub</C>
##  hold quotient, respectively subgroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation("IsSubgroupOfWholeGroupByQuotientRep",
  IsSubgroupFpGroup and IsComponentObjectRep,["quot","sub"]);

#############################################################################
##
#F  DefiningQuotientHomomorphism(<U>)
##
##  <#GAPDoc Label="DefiningQuotientHomomorphism">
##  <ManSection>
##  <Func Name="DefiningQuotientHomomorphism" Arg='U'/>
##
##  <Description>
##  if <A>U</A> is a subgroup in quotient representation
##  (<Ref Filt="IsSubgroupOfWholeGroupByQuotientRep"/>),
##  this function returns the
##  defining homomorphism from the whole group to <A>U</A><C>!.quot</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DefiningQuotientHomomorphism");

#############################################################################
##
#A  AsSubgroupOfWholeGroupByQuotient(<U>)
##
##  <#GAPDoc Label="AsSubgroupOfWholeGroupByQuotient">
##  <ManSection>
##  <Attr Name="AsSubgroupOfWholeGroupByQuotient" Arg='U'/>
##
##  <Description>
##  returns the same subgroup in the representation
##  <Ref Attr="AsSubgroupOfWholeGroupByQuotient"/>.
##  <P/>
##  See also <Ref Func="SubgroupOfWholeGroupByCosetTable"/>
##  and <Ref Oper="CosetTableBySubgroup"/>.
##  <P/>
##  This technique is used by &GAP; for example to represent the derived
##  subgroup, which is obtained from the quotient <M>G/G'</M>.
##  <Example><![CDATA[
##  gap> f:=FreeGroup(2);;g:=f/[f.1^6,f.2^6,(f.1*f.2)^6];;
##  gap> d:=DerivedSubgroup(g);
##  Group(<fp, no generators known>)
##  gap> Index(g,d);
##  36
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("AsSubgroupOfWholeGroupByQuotient", IsSubgroupFpGroup);


############################################################################
##
#O  LowIndexSubgroupsFpGroupIterator( <G>[, <H>], <index>[, <excluded>] )
#O  LowIndexSubgroupsFpGroup( <G>[, <H>], <index>[, <excluded>] )
##
##  <#GAPDoc Label="LowIndexSubgroupsFpGroupIterator">
##  <ManSection>
##  <Oper Name="LowIndexSubgroupsFpGroupIterator"
##   Arg='G[, H], index[, excluded]'/>
##  <Oper Name="LowIndexSubgroupsFpGroup" Arg='G[, H], index[, excluded]'/>
##
##  <Description>
##  <Index Subkey="for low index subgroups">iterator</Index>
##  These functions compute representatives of the conjugacy classes of
##  subgroups of the finitely presented group <A>G</A> that contain the
##  subgroup <A>H</A> of <A>G</A> and that have index less than or equal to
##  <A>index</A>.
##  <P/>
##  <Ref Oper="LowIndexSubgroupsFpGroupIterator"/> returns an iterator
##  (see&nbsp;<Ref Sect="Iterators"/>)
##  that can be used to run over these subgroups,
##  and <Ref Oper="LowIndexSubgroupsFpGroup"/> returns the list of these
##  subgroups.
##  If one is interested only in one or a few subgroups up to a given index
##  then preferably the iterator should be used.
##  <P/>
##  If the optional argument <A>excluded</A> has been specified, then it is
##  expected to be a list of words in the free generators of the underlying
##  free group of <A>G</A>, and <Ref Oper="LowIndexSubgroupsFpGroup"/>
##  returns only those subgroups of index at most <A>index</A> that contain
##  <A>H</A>, but do not contain any conjugate of any of the group elements
##  defined by these words.
##  <P/>
##  If not given, <A>H</A> defaults to the trivial subgroup.
##  <P/>
##  The algorithm used finds the requested subgroups
##  by systematically running through a tree of all potential coset tables
##  of <A>G</A> of length at most <A>index</A> (where it skips all branches
##  of that tree for which it knows in advance that they cannot provide new
##  classes of such subgroups).
##  The time required to do this depends, of course, on the presentation of
##  <A>G</A>, but in general it will grow exponentially with
##  the value of <A>index</A>. So you should be careful with the choice of
##  <A>index</A>.
##  <Example><![CDATA[
##  gap> li:=LowIndexSubgroupsFpGroup( g, TrivialSubgroup( g ), 10 );
##  [ Group(<fp, no generators known>), Group(<fp, no generators known>),
##    Group(<fp, no generators known>), Group(<fp, no generators known>) ]
##  ]]></Example>
##  <P/>
##  By default, the algorithm computes no generating sets for the subgroups.
##  This can be enforced with <Ref Attr="GeneratorsOfGroup"/>:
##  <Example><![CDATA[
##  gap> GeneratorsOfGroup(li[2]);
##  [ a, b*a*b^-1 ]
##  ]]></Example>
##  <P/>
##  If we are interested just in one (proper) subgroup of index at most
##  <M>10</M>, we can use the function that returns an iterator.
##  The first subgroup found is the group itself,
##  except if a list of excluded elements is entered (see below),
##  so we look at the second subgroup.
##  <P/>
##  <Example><![CDATA[
##  gap> iter:= LowIndexSubgroupsFpGroupIterator( g, 10 );;
##  gap> s1:= NextIterator( iter );;  Index( g, s1 );
##  1
##  gap> IsDoneIterator( iter );
##  false
##  gap> s2:= NextIterator( iter );;  s2 = li[2];
##  true
##  ]]></Example>
##  <P/>
##  As an example for an application of the optional parameter
##  <A>excluded</A>, we
##  compute all conjugacy classes of torsion free subgroups of index at most
##  <M>24</M> in the group <M>G =
##  \langle x,y,z \mid x^2, y^4, z^3, (xy)^3, (yz)^2, (xz)^3 \rangle</M>.
##  It is know from theory that each torsion element of this
##  group is conjugate to a power of <M>x</M>, <M>y</M>, <M>z</M>, <M>xy</M>,
##  <M>xz</M>, or <M>yz</M>.
##  (Note that this includes conjugates of <M>y^2</M>.)
##  <P/>
##  <Example><![CDATA[
##  gap> F := FreeGroup( "x", "y", "z" );;
##  gap> x := F.1;; y := F.2;; z := F.3;;
##  gap> G := F / [ x^2, y^4, z^3, (x*y)^3, (y*z)^2, (x*z)^3 ];;
##  gap> torsion := [ x, y, y^2, z, x*y, x*z, y*z ];;
##  gap> SetInfoLevel( InfoFpGroup, 2 );
##  gap> lis := LowIndexSubgroupsFpGroup(G, TrivialSubgroup(G), 24, torsion);;
##  #I  LowIndexSubgroupsFpGroup called
##  #I   class 1 of index 24 and length 8
##  #I   class 2 of index 24 and length 24
##  #I   class 3 of index 24 and length 24
##  #I   class 4 of index 24 and length 24
##  #I   class 5 of index 24 and length 24
##  #I  LowIndexSubgroupsFpGroup done. Found 5 classes
##  gap> SetInfoLevel( InfoFpGroup, 0 );
##  ]]></Example>
##  <P/>
##  If a particular image group is desired, the operation
##  <Ref Oper="GQuotients"/>
##  (see&nbsp;<Ref Sect="Quotient Methods"/>) can be useful as well.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="MostFrequentGeneratorFpGroup">
##  <ManSection>
##  <Func Name="MostFrequentGeneratorFpGroup" Arg='G'/>
##
##  <Description>
##  is an internal function which is used in some applications of coset
##  table methods. It returns the first of those generators of the given
##  finitely presented group <A>G</A> which occur most frequently in the
##  relators.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("MostFrequentGeneratorFpGroup");


#############################################################################
##
#A  FreeGeneratorsOfFpGroup( <G> )
#O  FreeGeneratorsOfWholeGroup( <U> )
##
##  <#GAPDoc Label="FreeGeneratorsOfFpGroup">
##  <ManSection>
##  <Attr Name="FreeGeneratorsOfFpGroup" Arg='G'/>
##  <Oper Name="FreeGeneratorsOfWholeGroup" Arg='U'/>
##
##  <Description>
##  <Ref Attr="FreeGeneratorsOfFpGroup"/> returns the underlying free
##  generators corresponding to the generators of the finitely presented
##  group <A>G</A> which must be a full FpGroup.
##  <P/>
##  <Ref Oper="FreeGeneratorsOfWholeGroup"/> also works for subgroups of an
##  FpGroup and returns the free generators of the full group that defines
##  the family.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FreeGeneratorsOfFpGroup",
     IsSubgroupFpGroup and IsGroupOfFamily  );
DeclareOperation( "FreeGeneratorsOfWholeGroup",
     [IsSubgroupFpGroup]  );

############################################################################
##
#A  RelatorsOfFpGroup(<G>)
##
##  <#GAPDoc Label="RelatorsOfFpGroup">
##  <ManSection>
##  <Attr Name="RelatorsOfFpGroup" Arg='G'/>
##
##  <Description>
##  returns the relators of the finitely presented group <A>G</A> as words
##  in the free generators provided by the
##  <Ref Attr="FreeGeneratorsOfFpGroup"/> value of <A>G</A>.
##  <Example><![CDATA[
##  gap> f := FreeGroup( "a", "b" );;
##  gap> g := f / [ f.1^5, f.2^2, f.1^f.2*f.1 ];
##  <fp group on the generators [ a, b ]>
##  gap> Size( g );
##  10
##  gap> FreeGroupOfFpGroup( g ) = f;
##  true
##  gap> FreeGeneratorsOfFpGroup( g );
##  [ a, b ]
##  gap> RelatorsOfFpGroup( g );
##  [ a^5, b^2, b^-1*a*b*a ]
##  ]]></Example>
##  <P/>
##  Note that these attributes are only available for the <E>full</E>
##  finitely presented group.
##  It is possible (for example by using <Ref Func="Subgroup"/>) to
##  construct a subgroup of index <M>1</M> which is not identical to the
##  whole group.
##  The latter one can be obtained in this situation via
##  <Ref Func="Parent"/>.
##  <P/>
##  Elements of a finitely presented group are not words, but are represented
##  using a word from the free group as representative. The following two
##  commands obtain this representative, respectively create an element in the
##  finitely presented group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("RelatorsOfFpGroup",IsSubgroupFpGroup and IsGroupOfFamily);

#############################################################################
##
#A  FreeGroupOfFpGroup(<G>)
##
##  <#GAPDoc Label="FreeGroupOfFpGroup">
##  <ManSection>
##  <Attr Name="FreeGroupOfFpGroup" Arg='G'/>
##
##  <Description>
##  returns the underlying free group for the finitely presented group
##  <A>G</A>.
##  This is the group generated by the free generators provided by the
##  <Ref Attr="FreeGeneratorsOfFpGroup"/> value of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("FreeGroupOfFpGroup",IsSubgroupFpGroup and IsGroupOfFamily);

#############################################################################
##
#A  IndicesInvolutaryGenerators( <G> )
##
##  <#GAPDoc Label="IndicesInvolutaryGenerators">
##  <ManSection>
##  <Attr Name="IndicesInvolutaryGenerators" Arg='G'/>
##
##  <Description>
##  returns the indices of those generators of the finitely presented group
##  <A>G</A> which are known to be involutions. This knowledge is used by
##  internal functions to improve the performance of coset enumerations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("IndicesInvolutaryGenerators",
  IsSubgroupFpGroup and IsGroupOfFamily);

############################################################################
##
#F  RelatorRepresentatives(<rels>)
##
##  <ManSection>
##  <Func Name="RelatorRepresentatives" Arg='rels'/>
##
##  <Description>
##  returns a set of  relators,  that  contains for each relator in the list
##  <A>rels</A> its minimal cyclical  permutation (which is automatically
##  cyclically reduced).
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RelatorRepresentatives");


#############################################################################
##
#F  RelsSortedByStartGen( <gens>, <rels>, <table> )
##
##  <ManSection>
##  <Func Name="RelsSortedByStartGen" Arg='gens, rels, table'/>
##
##  <Description>
##  is a  subroutine of the  Felsch Todd-Coxeter and the  Reduced
##  Reidemeister-Schreier  routines. It returns a list which for each
##  generator or  inverse generator in <A>gens</A> contains a list  of all
##  cyclically reduced relators,  starting  with that element,  which can be
##  obtained by conjugating or inverting the given relators <A>rels</A>.  The
##  relators are represented as lists of the coset table columns from the
##  table <A>table</A> corresponding to the generators and, in addition, as lists
##  of the respective column numbers.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RelsSortedByStartGen");

#############################################################################
##
#A  IsomorphismPermGroupOrFailFpGroup( <G> [,<max>] )
##
##  <ManSection>
##  <Attr Name="IsomorphismPermGroupOrFailFpGroup" Arg='G [,max]'/>
##
##  <Description>
##  returns an isomorphism <M>\varphi</M> from the fp group <A>G</A> onto
##  a permutation group <A>P</A> which is isomorphic to <A>G</A>, if one can be found
##  with reasonable effort and of reasonable degree. The function
##  returns <K>fail</K> otherwise.
##  <P/>
##  The optional argument <C>max</C> can be used to override the default maximal
##  size of a coset table used (and thus the maximal degree of the resulting
##  permutation).
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("IsomorphismPermGroupOrFailFpGroup");


#############################################################################
##
#F  SubgroupGeneratorsCosetTable(<freegens>,<fprels>,<table>)
##
##  <ManSection>
##  <Func Name="SubgroupGeneratorsCosetTable" Arg='freegens,fprels,table'/>
##
##  <Description>
##  determinates subgroup generators for the subgroup given by the coset
##  table <A>table</A> from the free generators <A>freegens</A>,
##  the  relators <A>fprels</A> (as words in <A>freegens</A>).
##  It returns words in <A>freegens</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SubgroupGeneratorsCosetTable" );

#############################################################################
##
#F  LiftFactorFpHom(<hom>,<G>,<N>,<dec>)
##
##  <ManSection>
##  <Func Name="LiftFactorFpHom" Arg='hom,G,N,dec'/>
##
##  <Description>
##  Let <A>hom</A> be an epimorphism from a group <A>G</A> to a finitely presented
##  group <A>F</A> with kernel <A>M</A> and <M>M/N</M> a chief factor.
##  If <M>M/N</M> is abelian, then <A>dec</A> is a modulo pcgs. Otherwise <A>dec</A> is a
##  homomorphism from <A>M</A> onto a finitely presented group, with kernel <A>N</A>.
##  This function
##  constructs a new fp group <A>F2</A> isomorphic to <M>G/N</M> and returns an
##  epimorphism from <A>G</A> onto <A>F2</A>.
##  <P/>
##  No test of the arguments is performed.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "LiftFactorFpHom" );

DeclareGlobalFunction( "IsomorphismFpGroupByChiefSeriesFactor" );

#############################################################################
##
#F  ComplementFactorFpHom(<hom>,<M>,<N>,<C>,<Ggens>,<Cgens>)
##
##  <ManSection>
##  <Func Name="ComplementFactorFpHom" Arg='hom,M,N,C,Ggens,Cgens'/>
##
##  <Description>
##  Let <A>hom</A> be an epimorphism from a group <C>G</C> to a finitely presented
##  group <A>F</A> with kernel <A>M</A> and <M>M/N</M> be elementary abelian and <M>C/N</M> a
##  complement to <A>M</A> in <M>G/N</M>. The set <A>Cgens</A> is a set of generators of
##  <A>C</A> modulo <A>N</A>, <A>Ggens</A> are corresponding representatives in <C>G</C>.
##  This function constructs a new epimorphism from <A>C</A> onto <A>F</A>.
##  <P/>
##  No test of the arguments is performed.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ComplementFactorFpHom" );

#############################################################################
##
#F  FactorGroupFpGroupByRels( <G>, <elts> )
##
##  <#GAPDoc Label="FactorGroupFpGroupByRels">
##  <ManSection>
##  <Func Name="FactorGroupFpGroupByRels" Arg='G, elts'/>
##
##  <Description>
##  returns the factor group <A>G</A>/<M>N</M> of <A>G</A> by
##  the normal closure <M>N</M> of <A>elts</A>
##  where <A>elts</A> is expected to be a list of elements of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FactorGroupFpGroupByRels" );


#############################################################################
##
#F  ExcludedOrders( <fpgrp>[,<ords>] )
#A  StoredExcludedOrders( <fpgrp> )
##
##  <ManSection>
##  <Func Name="ExcludedOrders" Arg='fpgrp[,ords]'/>
##  <Attr Name="StoredExcludedOrders" Arg='fpgrp'/>
##
##  <Description>
##  for a (full) finitely presented group <A>fpgrp</A> this attribute returns
##  a list of orders, corresponding to <Ref Func="GeneratorsOfGroup"/>,
##  for which the presentation collapses.
##  (That is, the group becomes trivial when a relator <M>g_i^o</M> is
##  added.) If given, the list <A>ords</A> contains a set of
##  orders corresponding to the generators which are explicitly to be
##  tested.
##  (The mutable attribute <Ref Func="StoredExcludedOrders"/> is used to
##  store results.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("ExcludedOrders");
DeclareAttribute( "StoredExcludedOrders",IsSubgroupFpGroup,"mutable");


#############################################################################
##
#F  NewmanInfinityCriterion(<G>,<p>)
##
##  <#GAPDoc Label="NewmanInfinityCriterion">
##  <ManSection>
##  <Func Name="NewmanInfinityCriterion" Arg='G, p'/>
##
##  <Description>
##  Let <A>G</A> be a finitely presented group and <A>p</A> a prime that
##  divides the order of the commutator factor group of <A>G</A>.
##  This function applies an infinity criterion due to M. F.&nbsp;Newman
##  <Cite Key="New90"/> to <A>G</A>.
##  (See <Cite Key="Joh97" Where="chapter 16"/> for a more explicit
##  description.)
##  It returns <K>true</K>
##  if the criterion succeeds in proving that <A>G</A> is infinite and
##  <K>fail</K> otherwise.
##  <P/>
##  Note that the criterion uses the number of generators and
##  relations in the presentation of <A>G</A>.
##  Reduction of the presentation via Tietze transformations
##  (<Ref Attr="IsomorphismSimplifiedFpGroup"/>) therefore might
##  produce an isomorphic group, for which the criterion will work better.
##  <Example><![CDATA[
##  gap> g:=FibonacciGroup(2,9);
##  <fp group on the generators [ f1, f2, f3, f4, f5, f6, f7, f8, f9 ]>
##  gap> hom:=EpimorphismNilpotentQuotient(g,2);;
##  gap> k:=Kernel(hom);;
##  gap> Index(g,k);
##  152
##  gap> AbelianInvariants(k);
##  [ 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 ]
##  gap> NewmanInfinityCriterion(Kernel(hom),5);
##  true
##  ]]></Example>
##  <P/>
##  This proves that the subgroup <C>k</C>
##  (and thus the whole group <C>g</C>) is infinite.
##  (This is the original example from&nbsp;<Cite Key="New90"/>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NewmanInfinityCriterion");

#############################################################################
##
#F  FibonacciGroup(<r>,<n>)
#F  FibonacciGroup(<n>)
##
##  <ManSection>
##  <Func Name="FibonacciGroup" Arg='r,n'/>
##  <Func Name="FibonacciGroup" Arg='n'/>
##
##  <Description>
##  This function returns the <E>Fibonacci group</E> with parameters <A>r</A>, <A>n</A>.
##  This is a finitely presented group with <A>n</A> generators <M>x_i</M> and <A>n</A>
##  relators <M>x_i\cdot\cdots\cdot x_{r+i-1}/x_{r+i}</M> (with indices reduced
##  modulo <A>n</A>).
##  <P/>
##  If <A>r</A> is omitted, it defaults to 2.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("FibonacciGroup");

#############################################################################
##
#A  FPFaithHom(<fam>)
##
##  <ManSection>
##  <Attr Name="FPFaithHom" Arg='fam'/>
##
##  <Description>
##  For the elements family <A>fam</A> of a finite fp group <A>G</A> this returns an
##  isomorphism to a permutation
##  or a pc group isomorphic to <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute("FPFaithHom",IsFamily);

#############################################################################
##
#F  ParseRelators(<gens>,<rels>)
##
##  <#GAPDoc Label="ParseRelators">
##  <ManSection>
##  <Func Name="ParseRelators" Arg='gens, rels'/>
##
##  <Description>
##  Will translate a list of relations as given in print, e.g.
##  <M>x y^2 = (x y^3 x)^2 xy = yzx</M> into relators.
##  <A>gens</A> must be a list of generators of a free group,
##  each being displayed by a single letter.
##  <A>rels</A> is a string that lists a sequence of equalities.
##  These must be written in the letters which are the names of
##  the generators in <A>gens</A>.
##  Change of upper/lower case is interpreted to indicate inverses.
##  <P/>
##  <Example><![CDATA[
##  gap> f:=FreeGroup("x","y","z");;
##  gap> AssignGeneratorVariables(f);
##  #I  Assigned the global variables [ x, y, z ]
##  gap> r:=ParseRelators([x,y,z],
##  > "x^2 = y^5 = z^3 = (xyxyxy^4)^2 = (xz)^2 = (y^2z)^2 = 1");
##  [ x^2, y^5, z^3, (x*z)^2, (y^2*z)^2, ((x*y)^3*y^3)^2 ]
##  gap> g:=f/r;
##  <fp group on the generators [ x, y, z ]>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ParseRelators");

#############################################################################
##
#F  StringFactorizationWord(<w>)
##
##  <#GAPDoc Label="StringFactorizationWord">
##  <ManSection>
##  <Func Name="StringFactorizationWord" Arg='w'/>
##
##  <Description>
##  returns a string that expresses a given word <A>w</A> in compact form
##  written as a string. Inverses are expressed by changing the upper/lower
##  case of the generators, recurring expressions are written as products.
##  <Example><![CDATA[
##  gap> StringFactorizationWord(z^-1*x*y*y*y*x*x*y*y*y*x*y^-1*x);
##  "Z(xy3x)2Yx"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("StringFactorizationWord");

# used to test whether abeliniazation can be mapped in GQuotients
DeclareGlobalFunction("CanMapFiniteAbelianInvariants");

# map fpgrp->fpmon creator
DeclareGlobalFunction("MakeFpGroupToMonoidHomType1");

# used in homomorphisms
DeclareGlobalName("TRIVIAL_FP_GROUP");

DeclareAttribute("CyclicSubgroupFpGroup", IsFpGroup);
