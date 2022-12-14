#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen, Ákos Seress.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#F  StabChain( <G>[, <options>] )
#F  StabChain( <G>, <base> )
#O  StabChainOp( <G>, <options> )
#A  StabChainMutable( <G> )
#A  StabChainMutable( <permhomom> )
#A  StabChainImmutable( <G> )
##
##  <#GAPDoc Label="StabChain">
##  <ManSection>
##  <Func Name="StabChain" Arg='G[, options]'
##   Label="for a group (and a record)"/>
##  <Func Name="StabChain" Arg='G, base'
##   Label="for a group and a base"/>
##  <Oper Name="StabChainOp" Arg='G, options'/>
##  <Attr Name="StabChainMutable" Arg='G'
##   Label="for a group"/>
##  <Attr Name="StabChainMutable" Arg='permhomom'
##   Label="for a homomorphism"/>
##  <Attr Name="StabChainImmutable" Arg='G'/>
##
##  <Description>
##  These commands compute a stabilizer chain for the permutation group
##  <A>G</A>;
##  additionally, <Ref Attr="StabChainMutable" Label="for a homomorphism"/>
##  is also an attribute for the group homomorphism <A>permhomom</A>
##  whose source is a permutation group.
##  <P/>
##  (The mathematical background of stabilizer chains is sketched
##  in&nbsp;<Ref Sect="Stabilizer Chains"/>,
##  more information about the objects representing stabilizer chains
##  in &GAP; can be found in&nbsp;<Ref Sect="Stabilizer Chain Records"/>.)
##  <P/>
##  <Ref Oper="StabChainOp"/> is an operation with two arguments <A>G</A> and
##  <A>options</A>,
##  the latter being a record which controls some aspects of the computation
##  of a stabilizer chain (see below);
##  <Ref Oper="StabChainOp"/> returns a <E>mutable</E> stabilizer chain.
##  <Ref Attr="StabChainMutable" Label="for a group"/> is a <E>mutable</E>
##  attribute for groups or homomorphisms,
##  its default method for groups is to call <Ref Oper="StabChainOp"/> with
##  empty options record.
##  <Ref Attr="StabChainImmutable"/> is an attribute with <E>immutable</E>
##  values;
##  its default method dispatches to
##  <Ref Attr="StabChainMutable" Label="for a group"/>.
##  <P/>
##  <Ref Func="StabChain" Label="for a group (and a record)"/> is a function
##  with first argument a permutation group <A>G</A>,
##  and optionally a record <A>options</A> as second argument.
##  If the value of <Ref Attr="StabChainImmutable"/> for <A>G</A>
##  is already known and if this stabilizer chain matches the requirements
##  of <A>options</A>,
##  <Ref Func="StabChain" Label="for a group (and a record)"/> simply returns
##  this stored stabilizer chain.
##  Otherwise <Ref Func="StabChain" Label="for a group (and a record)"/>
##  calls <Ref Oper="StabChainOp"/> and returns an immutable copy of the
##  result;
##  additionally, this chain is stored as <Ref Attr="StabChainImmutable"/>
##  value for <A>G</A>.
##  If no <A>options</A> argument is given, its components default
##  to the global variable <Ref Var="DefaultStabChainOptions"/>.
##  If <A>base</A> is a list of positive integers,
##  the version <C>StabChain( <A>G</A>, <A>base</A> )</C> defaults to
##  <C>StabChain( <A>G</A>, rec( base:= <A>base</A> ) )</C>.
##  <P/>
##  If given, <A>options</A> is a record whose components specify properties
##  of the desired stabilizer chain or which may help the algorithm.
##  Default values for all of them can be given in the global variable
##  <Ref Var="DefaultStabChainOptions"/>.
##  The following options are supported.
##  <List>
##  <Mark><C>base</C> (default an empty list)</Mark>
##  <Item>
##      A list of points, through which the resulting stabilizer chain
##      shall run.
##      For the base <M>B</M> of the resulting stabilizer chain <A>S</A>
##      this means the following.
##      If the <C>reduced</C> component of <A>options</A> is <K>true</K> then
##      those points of <C>base</C> with nontrivial basic orbits form the
##      initial segment of <M>B</M>, if the <C>reduced</C> component is
##      <K>false</K> then <C>base</C> itself is the initial segment of
##      <M>B</M>.
##      Repeated occurrences of points in <C>base</C> are ignored.
##      If a stabilizer chain for <A>G</A> is already known then the
##      stabilizer chain is computed via a base change.
##  </Item>
##  <Mark><C>knownBase</C> (no default value)</Mark>
##  <Item>
##      A list of points which is known to be a base for the group.
##      Such a known base makes it easier to test whether a permutation
##      given as a word in terms of a set of generators is the identity,
##      since it suffices to map the known base with each factor
##      consecutively, rather than multiplying the whole permutations
##      (which would mean to map every point).
##      This speeds up the Schreier-Sims algorithm which is used when a new
##      stabilizer chain is constructed;
##      it will not affect a base change, however.
##      The component <C>knownBase</C> bears no relation to the <C>base</C>
##      component, you may specify a known base <C>knownBase</C> and a
##      desired base <C>base</C> independently.
##  </Item>
##  <Mark><C>reduced</C> (default <K>true</K>)</Mark>
##  <Item>
##      If this is <K>true</K> the resulting stabilizer chain <A>S</A> is
##      reduced, i.e., the case  <M>G^{(i)} = G^{(i+1)}</M> does not occur.
##      Setting <C>reduced</C> to <K>false</K> makes sense only if
##      the component <C>base</C> (see above) is also set;
##      in this case all points of <C>base</C> will occur in the base
##      <M>B</M> of <A>S</A>, even if they have trivial basic orbits.
##      Note that if <C>base</C> is just an initial segment of <M>B</M>,
##      the basic orbits of the points in <M>B \setminus </M><C>base</C>
##      are always nontrivial.
##  </Item>
##  <Mark><C>tryPcgs</C> (default <K>true</K>)</Mark>
##  <Item>
##      If this is <K>true</K> and either the degree is at most <M>100</M>
##      or the group is known to be solvable, &GAP; will first try to
##      construct a pcgs (see Chapter&nbsp;<Ref Chap="Polycyclic Groups"/>)
##      for <A>G</A> which will succeed and implicitly construct a
##      stabilizer chain if <A>G</A> is solvable.
##      If <A>G</A> turns out non-solvable, one of the other methods will be
##      used.
##      This solvability check is comparatively fast, even if it fails,
##      and it can save a lot of time if <A>G</A> is solvable.
##  </Item>
##  <Mark><C>random</C> (default <C>1000</C>)</Mark>
##  <Item>
##      If the value is less than&nbsp;<M>1000</M>,
##      the resulting chain is correct with probability
##      at least&nbsp;<C>random</C><M> / 1000</M>.
##      The <C>random</C> option is explained in more detail
##      in&nbsp;<Ref Sect="Randomized Methods for Permutation Groups"/>.
##  </Item>
##  <Mark><C>size</C> (default <C>Size(<A>G</A>)</C> if this is known,
##          i.e., if <C>HasSize(<A>G</A>)</C> is <K>true</K>)</Mark>
##  <Item>
##      If this component is present, its value is assumed to be the order
##      of the group <A>G</A>.
##      This information can be used to prove that a non-deterministically
##      constructed stabilizer chain is correct.
##      In this case, &GAP; does a non-deterministic construction until the
##      size is correct.
##  </Item>
##  <Mark><C>limit</C> (default <C>Size(Parent(<A>G</A>))</C> or
##           <C>StabChainOptions(Parent(<A>G</A>)).limit</C>
##           if it is present)</Mark>
##  <Item>
##      If this component is present, it must be greater than or equal to
##      the order of <A>G</A>.
##      The stabilizer chain construction stops if size <C>limit</C> is
##      reached.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StabChain" );
DeclareOperation( "StabChainOp", [ IsGroup, IsRecord ] );
DeclareAttribute( "StabChainMutable", IsObject, "mutable" );
DeclareAttribute( "StabChainImmutable", IsObject );


#############################################################################
##
#A  StabChainOptions( <G> )
##
##  <#GAPDoc Label="StabChainOptions">
##  <ManSection>
##  <Attr Name="StabChainOptions" Arg='G'/>
##
##  <Description>
##  is a record that stores the options with which the stabilizer chain
##  stored in <Ref Attr="StabChainImmutable"/> has been computed
##  (see&nbsp;<Ref Func="StabChain" Label="for a group (and a record)"/>
##  for the options that are supported).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "StabChainOptions", IsPermGroup, "mutable" );


#############################################################################
##
#V  DefaultStabChainOptions
##
##  <#GAPDoc Label="DefaultStabChainOptions">
##  <ManSection>
##  <Var Name="DefaultStabChainOptions"/>
##
##  <Description>
##  are the options for
##  <Ref Func="StabChain" Label="for a group (and a record)"/> which are set
##  as default.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalName( "DefaultStabChainOptions" );


#############################################################################
##
#F  StabChainBaseStrongGenerators( <base>, <sgs>[, <one>] )
##
##  <#GAPDoc Label="StabChainBaseStrongGenerators">
##  <ManSection>
##  <Func Name="StabChainBaseStrongGenerators" Arg='base, sgs[, one]'/>
##
##  <Description>
##  Let <A>base</A> be a base for a permutation group <M>G</M>, and let
##  <A>sgs</A> be a strong generating set for <M>G</M> with respect to
##  <A>base</A>; <A>one</A> must be the appropriate identity element of
##  <M>G</M> (see <Ref Attr="One"/>, in most cases this will be <C>()</C>).
##  This function constructs a stabilizer chain corresponding to the given
##  base and strong generating set without the need to find
##  Schreier generators;
##  so this is much faster than the other algorithms.
##  <P/>
##  If <A>sgs</A> is nonempty, then the argument <A>one</A> is optional;
##  if not given, then the <Ref Attr="One" Style="Text"/> of
##  <C><A>sgs</A>[1]</C> is taken as the identity element.
##  <Example><![CDATA[
##  gap> sc := StabChainBaseStrongGenerators([1,2], [(1,3,4), (2,3,4)], ());
##  <stabilizer chain record, Base [ 1, 2 ], Orbit length 4, Size: 12>
##  gap> GroupStabChain(sc) = AlternatingGroup(4);
##  true
##  gap> StabChainBaseStrongGenerators([1,3], [(1,2),(3,4)]);
##  <stabilizer chain record, Base [ 1, 3 ], Orbit length 2, Size: 4>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StabChainBaseStrongGenerators" );


#############################################################################
##
#F  CopyStabChain( <S> )
##
##  <#GAPDoc Label="CopyStabChain">
##  <ManSection>
##  <Func Name="CopyStabChain" Arg='S'/>
##
##  <Description>
##  This function returns a mutable copy of the stabilizer chain <A>S</A>
##  that has no mutable object (list or record) in common with <A>S</A>.
##  The <C>labels</C> components of the result are possibly shared by several
##  levels, but superfluous labels are removed.
##  (An entry in <C>labels</C> is superfluous if it does not occur among the
##  <C>genlabels</C> or <C>translabels</C> on any of the levels which share
##  that <C>labels</C> component.)
##  <P/>
##  This is useful for stabiliser sub-chains that have been obtained as
##  the (iterated) <C>stabilizer</C> component of a bigger chain.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CopyStabChain" );


#############################################################################
##
#F  CopyOptionsDefaults( <G>, <options> ) . . . . . . . copy options defaults
##
##  <#GAPDoc Label="CopyOptionsDefaults">
##  <ManSection>
##  <Func Name="CopyOptionsDefaults" Arg='G, options'/>
##
##  <Description>
##  sets components in a stabilizer chain options record <A>options</A>
##  according to what is known about the group <A>G</A>.
##  This can be used to obtain a new stabilizer chain for <A>G</A> quickly.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CopyOptionsDefaults" );


#############################################################################
##
#F  BaseStabChain( <S> )
##
##  <#GAPDoc Label="BaseStabChain">
##  <ManSection>
##  <Func Name="BaseStabChain" Arg='S'/>
##
##  <Description>
##  returns the base belonging to the stabilizer chain <A>S</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BaseStabChain" );


#############################################################################
##
#A  BaseOfGroup( <G> )
##
##  <#GAPDoc Label="BaseOfGroup">
##  <ManSection>
##  <Attr Name="BaseOfGroup" Arg='G'/>
##
##  <Description>
##  returns a base of the permutation group <A>G</A>.
##  There is <E>no</E> guarantee that a stabilizer chain stored in <A>G</A>
##  corresponds to this base!
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BaseOfGroup", IsPermGroup );


#############################################################################
##
#F  SizeStabChain( <S> )
##
##  <#GAPDoc Label="SizeStabChain">
##  <ManSection>
##  <Func Name="SizeStabChain" Arg='S'/>
##
##  <Description>
##  returns the product of the orbit lengths in the stabilizer chain
##  <A>S</A>, that is, the order of the group described by <A>S</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SizeStabChain" );


#############################################################################
##
#F  StrongGeneratorsStabChain( <S> )
##
##  <#GAPDoc Label="StrongGeneratorsStabChain">
##  <ManSection>
##  <Func Name="StrongGeneratorsStabChain" Arg='S'/>
##
##  <Description>
##  returns a strong generating set corresponding to the stabilizer chain
##  <A>S</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StrongGeneratorsStabChain" );


#############################################################################
##
#F  GroupStabChain([<G>,] <S> )
##
##  <#GAPDoc Label="GroupStabChain">
##  <ManSection>
##  <Func Name="GroupStabChain" Arg='[G,] S'/>
##
##  <Description>
##  constructs a permutation group with stabilizer chain <A>S</A>, i.e.,
##  a group with generators <C>Generators( <A>S</A>  )</C> to which <A>S</A>
##  is assigned as component <C>stabChain</C>.
##  If the  optional argument <A>G</A> is given, the result will have the
##  parent <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GroupStabChain" );


#############################################################################
##
#F  IndicesStabChain( <S> )
##
##  <#GAPDoc Label="IndicesStabChain">
##  <ManSection>
##  <Func Name="IndicesStabChain" Arg='S'/>
##
##  <Description>
##  returns a list of the indices of the stabilizers in the stabilizer
##  chain <A>S</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IndicesStabChain" );


#############################################################################
##
#F  ListStabChain( <S> )
##
##  <#GAPDoc Label="ListStabChain">
##  <ManSection>
##  <Func Name="ListStabChain" Arg='S'/>
##
##  <Description>
##  returns a list that contains at position <M>i</M> the stabilizer of the
##  first <M>i-1</M> base points in the stabilizer chain <A>S</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ListStabChain" );


#############################################################################
##
#F  OrbitStabChain( <S>, <pnt> )
##
##  <#GAPDoc Label="OrbitStabChain">
##  <ManSection>
##  <Func Name="OrbitStabChain" Arg='S, pnt'/>
##
##  <Description>
##  returns the orbit of <A>pnt</A> under the group described by the
##  stabilizer chain <A>S</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OrbitStabChain" );


#############################################################################
##
#F  ElementsStabChain( <S> )
##
##  <#GAPDoc Label="ElementsStabChain">
##  <ManSection>
##  <Func Name="ElementsStabChain" Arg='S'/>
##
##  <Description>
##  returns a list of all elements of the group described by the stabilizer
##  chain <A>S</A>. The list is duplicate free but may be unsorted.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ElementsStabChain" );

#############################################################################
##
#F  IteratorStabChain( <S> )
##
##  <#GAPDoc Label="IteratorStabChain">
##  <ManSection>
##  <Func Name="IteratorStabChain" Arg='S'/>
##
##  <Description>
##  returns an iterator for the elements of the group described by the
##  stabilizer chain <A>S</A>.
##
##  The elements of the group <A>G</A> are produced by iterating through
##  all base images in turn, and in the ordering induced by the base. For
##  more details see&nbsp;<Ref Sect="Stabilizer Chains"/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "NextIterator_StabChain" );
DeclareGlobalFunction( "IteratorStabChain" );

#############################################################################
##
#A  MinimalStabChain(<G>)
##
##  <#GAPDoc Label="MinimalStabChain">
##  <ManSection>
##  <Attr Name="MinimalStabChain" Arg='G'/>
##
##  <Description>
##  returns the reduced stabilizer chain corresponding to the base
##  <M>[ 1, 2, 3, 4, \ldots ]</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MinimalStabChain", IsPermGroup );


#############################################################################
##
#F  ChangeStabChain( <S>, <base>[, <reduced>] )
##
##  <#GAPDoc Label="ChangeStabChain">
##  <ManSection>
##  <Func Name="ChangeStabChain" Arg='S, base[, reduced]'/>
##
##  <Description>
##  changes or reduces a stabilizer chain <A>S</A> to be adapted to the base
##  <A>base</A>.
##  The optional argument <A>reduced</A> is interpreted as follows.
##  <List>
##  <Mark><C>reduced = </C><K>false</K> : </Mark>
##  <Item>
##      change the stabilizer chain, do not reduce it,
##  </Item>
##  <Mark><C>reduced = </C><K>true</K> : </Mark>
##  <Item>
##      change the stabilizer chain, reduce it.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ChangeStabChain" );


#############################################################################
##
#F  ExtendStabChain( <S>, <base> )
##
##  <#GAPDoc Label="ExtendStabChain">
##  <ManSection>
##  <Func Name="ExtendStabChain" Arg='S, base'/>
##
##  <Description>
##  extends the stabilizer chain <A>S</A> so that it corresponds to base
##  <A>base</A>.
##  The original base of <A>S</A> must be a subset of <A>base</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ExtendStabChain" );


#############################################################################
##
#F  ReduceStabChain( <S> )
##
##  <#GAPDoc Label="ReduceStabChain">
##  <ManSection>
##  <Func Name="ReduceStabChain" Arg='S'/>
##
##  <Description>
##  changes the stabilizer chain <A>S</A> to a reduced stabilizer chain by
##  eliminating trivial steps.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ReduceStabChain" );


#############################################################################
##
#F  EmptyStabChain( <labels>, <id>[, <pnt>] )
##
##  <#GAPDoc Label="EmptyStabChain">
##  <ManSection>
##  <Func Name="EmptyStabChain" Arg='labels, id[, pnt]'/>
##
##  <Description>
##  constructs a stabilizer chain for the trivial group with
##  <C>identity</C> value equal to<A>id</A> and
##  <C>labels = </C><M>\{ <A>id</A> \} \cup</M> <A>labels</A>
##  (but of course with <C>genlabels</C> and <C>generators</C> values an
##  empty list).
##  If the optional third argument <A>pnt</A> is present, the only stabilizer
##  of the chain is initialized with the one-point basic orbit
##  <C>[ <A>pnt</A> ]</C> and with <C>translabels</C> and <C>transversal</C>
##  components.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "EmptyStabChain" );


#############################################################################
##
#F  ConjugateStabChain( <S>, <T>, <hom>, <map>[, <cond>] )
##
##  <ManSection>
##  <Func Name="ConjugateStabChain" Arg='S, T, hom, map[, cond]'/>
##
##  <Description>
##  conjugates the stabilizer chain <A>S</A>.
##  If given, <A>cond</A> is a function that determines for a stabilizer
##  record whether the recursion should continue for this record.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ConjugateStabChain" );


#############################################################################
##
#F  RemoveStabChain( <S> )
##
##  <#GAPDoc Label="RemoveStabChain">
##  <ManSection>
##  <Func Name="RemoveStabChain" Arg='S'/>
##
##  <Description>
##  <A>S</A> must be a stabilizer record in a stabilizer chain.
##  This chain then is cut off at <A>S</A> by changing the entries in
##  <A>S</A>.  This can be used to remove trailing trivial steps.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RemoveStabChain" );

#############################################################################
##
#F  TrimStabChain( <S>, <n> )
##
##  <ManSection>
##  <Func Name="TrimStabChain" Arg='S, n'/>
##
##  <Description>
##  This function trims all permutations in the stabilizer chain <A>S</A> to
##  degree at most <A>n</A> (to save memory).
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "TrimStabChain" );

DeclareOperation( "MembershipTestKnownBase", [ IsRecord, IsList, IsList ] );


#############################################################################
##
#F  SiftedPermutation( <S>, <g> )
##
##  <#GAPDoc Label="SiftedPermutation">
##  <ManSection>
##  <Func Name="SiftedPermutation" Arg='S, g'/>
##
##  <Description>
##  sifts the permutation <A>g</A> through the stabilizer chain <A>S</A>
##  and returns the result after the last step.
##  <P/>
##  The element <A>g</A> is sifted as follows: <A>g</A> is replaced by
##  <C><A>g</A>
##  * InverseRepresentative( <A>S</A>, <A>S</A>.orbit[1]^<A>g</A> )</C>,
##  then <A>S</A> is replaced by <C><A>S</A>.stabilizer</C> and this process
##  is repeated until <A>S</A> is trivial
##  or <C><A>S</A>.orbit[1]^<A>g</A></C> is not in the basic orbit
##  <C><A>S</A>.orbit</C>.
##  The remainder <A>g</A> is returned, it is the identity permutation if and
##  only if the original <A>g</A> is in the group <M>G</M> described by
##  the original&nbsp;<A>S</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SiftedPermutation" );


#############################################################################
##
#F  MinimalElementCosetStabChain( <S>, <g> )
##
##  <#GAPDoc Label="MinimalElementCosetStabChain">
##  <ManSection>
##  <Func Name="MinimalElementCosetStabChain" Arg='S, g'/>
##
##  <Description>
##  Let <M>G</M> be the group described by the stabilizer chain <A>S</A>.
##  This function returns a permutation <M>h</M> such that
##  <M>G <A>g</A> = G h</M>
##  (that is, <M><A>g</A> / h \in G</M>) and with the additional property that
##  the list of images under <M>h</M> of the base belonging to <A>S</A> is
##  minimal w.r.t.&nbsp;lexicographical ordering.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MinimalElementCosetStabChain" );


#############################################################################
##
#F  SCMinSmaGens(<G>,<S>,<emptyset>,<identity element>,<flag>)
##
##  <ManSection>
##  <Func Name="SCMinSmaGens" Arg='G,S,emptyset,identity element,flag'/>
##
##  <Description>
##  This function computes a stabilizer chain for a minimal base image and
##  a smallest generating set w.r.t. this base for a permutation
##  group.
##  <P/>
##  <A>G</A> must be a permutation group and <A>S</A> a mutable stabilizer
##  chain for <A>G</A> that defines a base <A>bas</A>.
##  Let <A>mbas</A> the smallest image (OnTuples) of <A>G</A>.
##  Then this operation changes <A>S</A> to a stabilizer chain w.r.t.
##  <A>mbas</A>.
##  The arguments <A>emptyset</A> and <A>identity element</A> are needed
##  only for the recursion.
##  <P/>
##  The function returns a record whose component <C>gens</C> is a list whose
##  first element is the smallest element w.r.t. <A>bas</A>
##  (i.e. an element which maps <A>bas</A> to <A>mbas</A>).
##  If <A>flag</A> is <K>true</K>, <C>gens</C> is the smallest generating set
##  w.r.t. <A>bas</A>.
##  (If <A>flag</A> is <K>false</K> this will not be computed.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("SCMinSmaGens");


#############################################################################
##
#F  LargestElementStabChain( <S>, <id> )
##
##  <#GAPDoc Label="LargestElementStabChain">
##  <ManSection>
##  <Func Name="LargestElementStabChain" Arg='S, id'/>
##
##  <Description>
##  Let <M>G</M> be the group described by the stabilizer chain <A>S</A>.
##  This function returns the element <M>h \in G</M> with the property that
##  the list of images under <M>h</M> of the base belonging to <A>S</A> is
##  maximal w.r.t.&nbsp;lexicographical ordering.
##  The second argument must be an identity element (used to start the
##  recursion).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LargestElementStabChain" );


DeclareCategory( "IsPermOnEnumerator",
    IsMultiplicativeElementWithInverse and IsPerm );

DeclareOperation( "PermOnEnumerator", [ IsList, IsObject ] );

DeclareGlobalFunction( "DepthSchreierTrees" );


#############################################################################
##
#F  AddGeneratorsExtendSchreierTree( <S>, <new> )
##
##  <#GAPDoc Label="AddGeneratorsExtendSchreierTree">
##  <ManSection>
##  <Func Name="AddGeneratorsExtendSchreierTree" Arg='S, new'/>
##
##  <Description>
##  adds the elements in <A>new</A> to the list of generators of <A>S</A>
##  and at the same time extends the orbit and transversal.
##  This is the only legal way to extend a Schreier tree
##  (because this involves careful handling of the tree components).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AddGeneratorsExtendSchreierTree" );

DeclareGlobalFunction( "ChooseNextBasePoint" );
DeclareGlobalFunction( "StabChainStrong" );
DeclareGlobalFunction( "StabChainForcePoint" );
DeclareGlobalFunction( "StabChainSwap" );
DeclareGlobalFunction( "LabsLims" );


#############################################################################
##
#F  InsertTrivialStabilizer( <S>, <pnt> )
##
##  <#GAPDoc Label="InsertTrivialStabilizer">
##  <ManSection>
##  <Func Name="InsertTrivialStabilizer" Arg='S, pnt'/>
##
##  <Description>
##  <Ref Func="InsertTrivialStabilizer"/> initializes the current stabilizer
##  with <A>pnt</A> as <Ref Func="EmptyStabChain"/> did,
##  but assigns the original <A>S</A> to the new
##  <C><A>S</A>.stabilizer</C> component, such that  a new level with trivial
##  basic orbit (but identical <C>labels</C> and <C>ShallowCopy</C>ed
##  <C>genlabels</C> and <C>generators</C>) is inserted.
##  This function should be used only if <A>pnt</A> really is fixed by the
##  generators of <A>S</A>, because then new generators can be added and the
##  orbit and transversal at the same time extended with
##  <Ref Func="AddGeneratorsExtendSchreierTree"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InsertTrivialStabilizer" );

DeclareGlobalFunction( "InitializeSchreierTree" );

DeclareGlobalFunction( "BasePoint" );
DeclareGlobalFunction( "IsInBasicOrbit" );


#############################################################################
##
#F  IsFixedStabilizer( <S>, <pnt> )
##
##  <#GAPDoc Label="IsFixedStabilizer">
##  <ManSection>
##  <Func Name="IsFixedStabilizer" Arg='S, pnt'/>
##
##  <Description>
##  returns <K>true</K> if <A>pnt</A> is fixed by all generators of <A>S</A>
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsFixedStabilizer" );


#############################################################################
##
#F  InverseRepresentative( <S>, <pnt> )
##
##  <#GAPDoc Label="InverseRepresentative">
##  <ManSection>
##  <Func Name="InverseRepresentative" Arg='S, pnt'/>
##
##  <Description>
##  calculates the transversal element which maps <A>pnt</A> back to the base
##  point of <A>S</A>.  It just runs back through the Schreier tree from
##  <A>pnt</A> to the root and multiplies the labels along the way.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InverseRepresentative" );

DeclareGlobalFunction( "QuickInverseRepresentative" );
DeclareGlobalFunction( "InverseRepresentativeWord" );

DeclareGlobalFunction( "StabChainRandomPermGroup" );
DeclareGlobalFunction( "SCRMakeStabStrong" );
DeclareGlobalFunction( "SCRStrongGenTest" );
DeclareGlobalFunction( "SCRSift" );
DeclareGlobalFunction( "SCRStrongGenTest2" );
DeclareGlobalFunction( "SCRNotice" );
DeclareGlobalFunction( "SCRExtend" );
DeclareGlobalFunction( "SCRSchTree" );
DeclareGlobalFunction( "SCRRandomPerm" );
DeclareGlobalFunction( "SCRRandomString" );
DeclareGlobalFunction( "SCRRandomSubproduct" );
DeclareGlobalFunction( "SCRExtendRecord" );
DeclareGlobalFunction( "SCRRestoredRecord" );
DeclareGlobalFunction( "VerifyStabilizer" );
DeclareGlobalFunction( "VerifySGS" );
DeclareGlobalFunction( "ExtensionOnBlocks" );
DeclareGlobalFunction( "ClosureRandomPermGroup" );
#
