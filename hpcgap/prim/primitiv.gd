#############################################################################
##
#W  primitiv.gd              GAP group library               Heiko Theißen
#W                                                           Alexander Hulpke
#W                                                          Colva Roney-Dougal
##
##
##
##


##  <#GAPDoc Label="[1]{primitiv}">
##  &GAP; contains a library of primitive permutation groups which includes,
##  up to permutation isomorphism (i.e., up to conjugacy in the corresponding
##  symmetric group),
##  all  primitive  permutation groups of  degree <M>&lt;&nbsp;2500</M>,
##  calculated in <Cite Key="RoneyDougal05"/>,
##  in particular,
##  <List>
##  <Item>
##    the primitive permutation groups up to degree&nbsp;50,
##    calculated by C.&nbsp;Sims,
##  </Item>
##  <Item>
##    the primitive groups with insoluble socles of degree
##    <M>&lt;&nbsp;1000</M> as calculated in <Cite Key="DixonMortimer88"/>,
##  </Item>
##  <Item>
##    the solvable (hence affine) primitive permutation groups of degree
##    <M>&lt;&nbsp;256</M> as calculated by M.&nbsp;Short <Cite Key="Sho92"/>,
##  </Item>
##  <Item>
##    some insolvable affine primitive permutation groups of degree
##    <M>&lt;&nbsp;256</M> as calculated in <Cite Key="Theissen97"/>.
##  </Item>
##  <Item>
##    The solvable primitive groups of degree up to <M>999</M> as calculated
##    in <Cite Key="EickHoefling02"/>.
##  </Item>
##  <Item>
##    The primitive groups of affine type of degree up to <M>999</M> as
##    calculated in <Cite Key="RoneyDougal02"/>.
##  </Item>
##  </List>
##  <P/>
##  Not all groups are named, those which do have names use ATLAS notation.
##  Not all names are necessary unique!
##  <P/>
##  The list given in <Cite Key="RoneyDougal05"/> is believed to be complete,
##  correcting various omissions in <Cite Key="DixonMortimer88"/>,
##  <Cite Key="Sho92"/> and <Cite Key="Theissen97"/>.
##  <P/>
##  In detail, we guarantee the following properties for this and further
##  versions (but <E>not</E> versions which came before &GAP;&nbsp;4.2)
##  of the library:
##  <P/>
##  <List>
##  <Item>
##    All groups in the library are primitive permutation groups
##    of the indicated degree.
##  </Item>
##  <Item>
##    The positions of the groups in the library are stable.
##    That is <C>PrimitiveGroup(<A>n</A>,<A>nr</A>)</C> will always give you
##    a permutation isomorphic group.
##    Note however that we do not guarantee to keep the chosen
##    <M>S_n</M>-representative, the generating set or the name for eternity.
##  </Item>
##  <Item>
##    Different groups in the library are not conjugate in <M>S_n</M>.
##  </Item>
##  <Item>
##    If a group in the library has a primitive subgroup with the same socle,
##    this group is in the library as well.
##  </Item>
##  </List>
##  <P/>
##  (Note that the arrangement of groups is not guaranteed to be in
##  increasing size, though it holds for many degrees.)
##  <#/GAPDoc>


#############################################################################
##
## tell GAP about the component
##
DeclareComponent("prim","2.1");


#############################################################################
##
#F  PrimitiveGroup(<deg>,<nr>)
##
##  <#GAPDoc Label="PrimitiveGroup">
##  <ManSection>
##  <Func Name="PrimitiveGroup" Arg='deg,nr'/>
##
##  <Description>
##  returns the primitive permutation  group of degree <A>deg</A> with number <A>nr</A>
##  from the list. 
##  <P/>
##  The arrangement of the groups differs from the arrangement of primitive
##  groups in the list of C.&nbsp;Sims, which was used in &GAP;&nbsp;3. See
##  <Ref Func="SimsNo"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
UnbindGlobal("PrimitiveGroup");
DeclareGlobalFunction( "PrimitiveGroup" );


#############################################################################
##
#F  NrPrimitiveGroups(<deg>)
##
##  <#GAPDoc Label="NrPrimitiveGroups">
##  <ManSection>
##  <Func Name="NrPrimitiveGroups" Arg='deg'/>
##
##  <Description>
##  returns the number of primitive permutation groups of degree <A>deg</A> in the
##  library.
##  <Example><![CDATA[
##  gap> NrPrimitiveGroups(25);
##  28
##  gap> PrimitiveGroup(25,19);
##  5^2:((Q(8):3)'4)
##  gap> PrimitiveGroup(25,20);
##  ASL(2, 5)
##  gap> PrimitiveGroup(25,22);
##  AGL(2, 5)
##  gap> PrimitiveGroup(25,23);
##  (A(5) x A(5)):2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NrPrimitiveGroups" );


##  <#GAPDoc Label="[2]{primitiv}">
##  The selection functions (see&nbsp;<Ref Sect="Selection Functions"/>) for
##  the primitive groups library are <C>AllPrimitiveGroups</C> and
##  <C>OnePrimitiveGroup</C>.
##  They obtain the following properties from the database without having to
##  compute them anew: 
##  <P/>
##  <Ref Attr="NrMovedPoints" Label="for a list or collection of permutations"/>,
##  <Ref Attr="Size"/>,
##  <Ref Attr="Transitivity" Label="for a group and an action domain"/>,
##  <Ref Attr="ONanScottType"/>,
##  <Ref Prop="IsSimpleGroup"/>,
##  <Ref Prop="IsSolvableGroup"/>,
##  and <Ref Attr="SocleTypePrimitiveGroup"/>.
##  <P/>
##  (Note, that for groups of degree up to 2499, O'Nan-Scott types 4a, 4b and
##  5 cannot occur.)
##  <#/GAPDoc>


#############################################################################
##
#F  PrimitiveGroupsIterator(<attr1>,<val1>,<attr2>,<val2>,...)
##
##  <#GAPDoc Label="PrimitiveGroupsIterator">
##  <ManSection>
##  <Func Name="PrimitiveGroupsIterator" Arg='attr1,val1,attr2,val2,...'/>
##
##  <Description>
##  returns an iterator through
##  <C>AllPrimitiveGroups(<A>attr1</A>,<A>val1</A>,<A>attr2</A>,<A>val2</A>,...)</C> without creating
##  all these groups at the same time.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PrimitiveGroupsIterator" );

#############################################################################
##
#F  AllPrimitiveGroups(<attr1>,<val1>,<attr2>,<val2>,...)
##
##  <ManSection>
##  <Func Name="AllPrimitiveGroups" Arg='attr1,val1,attr2,val2,...'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AllPrimitiveGroups" );

#############################################################################
##
#F  OnePrimitiveGroup(<attr1>,<val1>,<attr2>,<val2>,...)
##
##  <ManSection>
##  <Func Name="OnePrimitiveGroup" Arg='attr1,val1,attr2,val2,...'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "OnePrimitiveGroup" );


#############################################################################
##
#A  SimsNo(<G>)
##
##  <#GAPDoc Label="SimsNo">
##  <ManSection>
##  <Attr Name="SimsNo" Arg='G'/>
##
##  <Description>
##  If <A>G</A> is a primitive group obtained by <Ref Func="PrimitiveGroup"/>
##  (respectively one of the selection functions) this attribute contains the
##  number of the isomorphic group in the original list of C.&nbsp;Sims.
##  (This is the arrangement as it was used in &GAP;&nbsp;3.)
##  <P/>
##  <Example><![CDATA[
##  gap> g:=PrimitiveGroup(25,2);
##  5^2:S(3)
##  gap> SimsNo(g);
##  3
##  ]]></Example>
##  <P/>
##  As mentioned in the previous section, the index numbers of primitive
##  groups in &GAP; are guaranteed to remain stable. (Thus, missing groups
##  will be added to the library at the end of each degree.)
##  In particular, it is safe to refer to a primitive group of type
##  <A>deg</A>, <A>nr</A> in the &GAP; library.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SimsNo", IsPermGroup );

#############################################################################
##
#V  PrimitiveIndexIrreducibleSolvableGroup
##
##  <#GAPDoc Label="PrimitiveIndexIrreducibleSolvableGroup">
##  <ManSection>
##  <Var Name="PrimitiveIndexIrreducibleSolvableGroup"/>
##
##  <Description>
##  This variable provides a way to get from irreducible solvable groups to
##  primitive groups and vice versa. For the group
##  <M>G</M> = <C>IrreducibleSolvableGroup( <A>n</A>, <A>p</A>, <A>k</A> )</C>
##  and <M>d = p^n</M>, the entry
##  <C>PrimitiveIndexIrreducibleSolvableGroup[d][i]</C> gives the index
##  number of the semidirect product <M>p^n:G</M> in the library of primitive
##  groups.
##  <P/>
##  Searching for an index in this list with <Ref Func="Position"/> gives the
##  translation in the other direction.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalVariable("PrimitiveIndexIrreducibleSolvableGroup");

#############################################################################
##
#F  MaximalSubgroupsSymmAlt( <grp> [,<onlyprimitive>] )
##
##  <ManSection>
##  <Func Name="MaximalSubgroupsSymmAlt" Arg='grp [,onlyprimitive]'/>
##
##  <Description>
##  For a symmetric or alternating group <A>grp</A>, this function returns
##  representatives of the classes of maximal subgroups.
##  <P/>
##  If the parameter <A>onlyprimitive</A> is given and set to <K>true</K> only the
##  primitive maximal subgroups are computed.
##  <P/>
##  No parameter test is performed. (The function relies on the primitive
##  groups library for its functionality.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("MaximalSubgroupsSymmAlt");


#############################################################################
##
#E

