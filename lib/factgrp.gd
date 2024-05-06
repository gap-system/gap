#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations of operations for factor group maps
##

##
##  To implement new factor group methods, one does not need to deal with
##  most of the following operations (which are only used to cache known
##  homomorphisms and extend them to subdirect factors). Instead only methods
##  for the following three operations might need to be supplied:
##  If a suitable homomorphism cannot be found from the cached homomorphisms
##  pool, `NaturalHomomorphismByNormalSubgroupOp(<G>,<N>)' is called to
##  construct one.
##  The default method for `NaturalHomomorphismByNormalSubgroupOp' then uses
##  two other operations: `DoCheapActionImages' computes actions that come
##  naturally from a groups representation (for example permutation action
##  on orbits and blocks) and can be computed quickly. This is intended
##  as a first test to avoid hard work for homomorphisms that are easy to
##  get.
##  If this fails, `FindActionKernel' is called which will try to find some
##  action which will give a suitable homomorphism. (This can be very time
##  consuming.)
##  The existing methods seem to work reasonably well for permutation groups
##  and pc groups, for other kinds of groups it might be necessary to
##  implement completely new methods.
##

#############################################################################
##
#O  DoCheapActionImages(<G>)
##
##  <ManSection>
##  <Oper Name="DoCheapActionImages" Arg='G'/>
##
##  <Description>
##  computes natural actions for <A>G</A> and stores the resulting
##  <C>NaturalHomomorphismByNormalSubgroup</C>. The type of the natural actions
##  varies with the representation of <A>G</A>, for permutation groups it are for
##  example constituent and block homomorphisms.
##  A method for <C>DoCheapActionImages</C> must register all found actions with
##  <C>AddNaturalHomomorphismsPool</C> so they become available.
##  </Description>
##  </ManSection>
##
DeclareOperation("DoCheapActionImages",[IsGroup]);
DeclareSynonym("DoCheapOperationImages",DoCheapActionImages);


#############################################################################
##
#O  FindActionKernel( <G>, <N> )  . . . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="FindActionKernel" Arg='G, N'/>
##
##  <Description>
##  This operation tries to find a suitable action for the group <A>G</A> such
##  that its kernel is <A>N</A>. This is used to construct faithful permutation
##  representations for the factor group.
##  </Description>
##  </ManSection>
##
DeclareOperation( "FindActionKernel",[IsGroup,IsGroup]);
DeclareSynonym( "FindOperationKernel",FindActionKernel);

#############################################################################
##
#V  InfoFactor
##
##  <ManSection>
##  <InfoClass Name="InfoFactor"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareInfoClass("InfoFactor");

#############################################################################
##
#A  NaturalHomomorphismsPool(<G>)
##
##  <ManSection>
##  <Attr Name="NaturalHomomorphismsPool" Arg='G'/>
##
##  <Description>
##  The <C>NaturalHomomorphismsPool</C> is a record which contains the following
##  components:
##    <C>group</C> is the corresponding group.
##    <C>ker</C> is a list of normal subgroups, which defines the arrangements.
##          It is sorted.
##    <C>ops</C> is a list which gives the best know actions for each normal
##          subgroup. Its entries are either Homomorphisms from G or
##  generator lists (G.generators images) or lists of integers. In the
##  latter case the factor is subdirect product of the factors with
##  the given numbers.
##    <C>cost</C> gives the difficulty for each actions (degree of permgroup). It
##           is used to check whether a new actions is better.
##    <C>lock</C> is a bitlist, which indicates whether certain actions are
##  locked. If this happens, a better new actions is not entered.
##  This allows a computation to access the pool several times and to
##  be guaranteed to be returned the same object. Usually a routine
##  initially locks and finally unlocks.
##  <!-- #AH probably one even would like to have a lock counter ? -->
##    <C>GopDone</C> indicates whether all <C>obvious</C> actions have been tried
##              already
##    <C>intersects</C> is a list of all intersections that have already been
##              formed.
##    <C>blocksdone</C> indicates if the actions already has been improved
##         using blocks
##    <C>in_code</C> can be set by the code to avoid addition of new actions
##              (and thus resorting)
##  </Description>
##  </ManSection>
##
DeclareAttribute("NaturalHomomorphismsPool",IsGroup,
                                         "mutable");

#############################################################################
##
#O  FactorCosetAction( <G>, <U>[, <N>] )  action on the right cosets Ug
##
##  <#GAPDoc Label="FactorCosetAction">
##  <ManSection>
##  <Oper Name="FactorCosetAction" Arg='G, U[, N]'
##    Label="for a group and subgroup"/>
##  <Oper Name="FactorCosetAction" Arg='G, L'
##    Label="for a group and list of subgroups"/>
##
##  <Description>
##  This command computes the action of the group <A>G</A> on the
##  right cosets of the subgroup <A>U</A>.
##  If a normal subgroup <A>N</A> of <A>G</A> is given,
##  it is stored as kernel of this action.
##  When calling <C>FactorCosetAction</C> with a list of subgroups as the
##  second argument, an action with image isomorphic to the subdirect
##  product of the coset actions of all subgroups is computed. (However a
##  degree reduction may take place if some of the actions are redundant, i.e.
##  there is no guarantee that every subgroup in the list is represented by an
##  orbit.)
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4,5),(1,2));;u:=SylowSubgroup(g,2);;Index(g,u);
##  15
##  gap> FactorCosetAction(g,u);
##  [ (1,2,3,4,5), (1,2) ] -> [ (1,4,7,10,13)(2,5,8,11,14)(3,6,9,12,15),\
##    (1,4)(2,6)(3,5)(7,8)(10,12)(13,14) ]
##  gap> StructureDescription(Range(last));
##  "S5"
##  gap> FactorCosetAction(g,[u,SylowSubgroup(g,3)]);;
##  gap> Size(Image(last));
##  120
##  ]]></Example>
##  The correspondence of points with cosets will, for performance reasons,
##  depend on the method used. It is not guaranteed that it will be the same
##  as used by <C>RightTransversal</C> or <C>RightCosets</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FactorCosetAction", [IsGroup,IsGroup] );

#############################################################################
##
#F  ImproveActionDegreeByBlocks( <G>, <N> , <hom> [,forceblocks] )
#F  ImproveActionDegreeByBlocks( <G>, <N> , <U> [,forceblocks] )
##
##  <ManSection>
##  <Func Name="ImproveActionDegreeByBlocks" Arg='G, N , hom [,forceblocks]'/>
##  <Func Name="ImproveActionDegreeByBlocks" Arg='G, N , U [,forceblocks]'/>
##
##  <Description>
##  In the first usage, <A>N</A> is a normal subgroup of <A>G</A> and <A>hom</A> a
##  homomorphism from <A>G</A> to a permutation group with kernel <A>N</A>. In the second
##  usage, <A>hom</A> is taken to be the action of <A>G</A> on the cosets of <A>U</A> by right
##  multiplication.
##  The function tries to find another homomorphism with the same kernel but
##  image group of smaller degree by looking for block systems of the image
##  group. An improved result is stored in the <C>NaturalHomomorphismsPool</C>, the
##  function returns the degree of this image (or the degree of the original
##  image).
##  If the image degree is larger than 500, only one block system is tested by
##  standard. A test of all block systems is enforced by the optional boolean
##  parameter <A>forceblocks</A>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ImproveActionDegreeByBlocks" );
DeclareSynonym( "ImproveOperationDegreeByBlocks",
                        ImproveActionDegreeByBlocks );

#############################################################################
##
#F  SmallerDegreePermutationRepresentation( <G> )
##
##  <#GAPDoc Label="SmallerDegreePermutationRepresentation">
##  <ManSection>
##  <Func Name="SmallerDegreePermutationRepresentation" Arg='G'/>
##
##  <Description>
##  Let <A>G</A> be a permutation group.
##  <Ref Func="SmallerDegreePermutationRepresentation"/> tries to find a
##  faithful permutation representation of smaller degree.
##  The result is a group homomorphism onto a permutation group,
##  in the worst case this is the identity mapping on <A>G</A>.
##  <P/>
##  If the <C>cheap</C> option is given, the function only tries to reduce
##  to orbits or actions on blocks, otherwise also actions on cosets of
##  random subgroups are tried.
##  <P/>
##  Note that the result is not guaranteed to be a faithful permutation
##  representation of smallest degree,
##  or of smallest degree among the transitive permutation representations
##  of <A>G</A>.
##  Using &GAP; interactively, one might be able to choose subgroups
##  of small index for which the cores intersect trivially;
##  in this case, the actions on the cosets of these subgroups give rise to
##  an intransitive permutation representation
##  the degree of which may be smaller than the original degree.
##  <P/>
##  The methods used might involve the use of random elements and the
##  permutation representation (or even the degree of the representation) is
##  not guaranteed to be the same for different calls of
##  <Ref Func="SmallerDegreePermutationRepresentation"/>.
##  <P/>
##  If the option cheap is given less work is spent on trying to get a small
##  degree representation, if the value of this option is set to the string
##  "skip" the identity mapping is returned. (This is useful if a function
##  called internally might try a degree reduction.)
##  <P/>
##  <Example><![CDATA[
##  gap> iso:=RegularActionHomomorphism(SymmetricGroup(4));;
##  gap> image:= Image( iso );;  NrMovedPoints( image );
##  24
##  gap> small:= SmallerDegreePermutationRepresentation( image );;
##  gap> Image( small );
##  Group([ (2,5,4,3), (1,4)(2,6)(3,5) ])
##  gap> g:=Image(IsomorphismPermGroup(GL(4,5)));;
##  gap> sm:=SmallerDegreePermutationRepresentation(g:cheap);;
##  gap> NrMovedPoints(Range(sm));
##  624
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SmallerDegreePermutationRepresentation" );


#############################################################################
##
#F  AddNaturalHomomorphismsPool(G,N,op[,cost[,blocksdone]])
##
##  <ManSection>
##  <Func Name="AddNaturalHomomorphismsPool" Arg='G,N,op[,cost[,blocksdone]]'/>
##
##  <Description>
##  This function stores a computed action of <A>G</A> with kernel <A>N</A> in the
##  <C>NaturalHomomorphismsPool</C> of <A>G</A>, unless a <Q>better</Q> action is already
##  known. <A>op</A> usually is a homomorphism of <A>G</A> with kernel <A>N</A>. It may also
##  be a subgroup of <A>G</A>, in which case the action of <A>G</A> on its cosets is
##  taken.
##  If the optional parameter <A>cost</A> is not given, <A>cost</A> is taken to be the
##  degree of the image representation (or 1 if the image is a pc group). This
##  <A>cost</A> is stored with the action to determine later whether another
##  action is <Q>better</Q>.
##  The optional boolean parameter <A>blocksdone</A> indicates if set to true, that
##  all block systems of the image of <A>op</A> have already been computed and the
##  resulting (lower degree, but not necessarily faithful for <M>G/N</M>) actions
##  have been already considered. (Otherwise such a test may be done later by
##  <C>DoCheapActionImages</C>.)
##  The function internally re-sorts the list of normal subgroups to permit
##  binary search among them. If a new action is returns the re-sorting
##  permutation applied there. If returns <K>false</K> if a <Q>better</Q> action was
##  already known, it returns <Q>fail</Q> if this factor is locked.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("AddNaturalHomomorphismsPool");


#############################################################################
##
#F  LockNaturalHomomorphismsPool(<G>,<N>)  . .  store flag to prohibit changes
##
##  <ManSection>
##  <Func Name="LockNaturalHomomorphismsPool" Arg='G,N'/>
##
##  <Description>
##  Calling this function stores a flag in the <C>NaturalHomomorphismsPool</C> of
##  <A>G</A> to prohibit it to store new (even better) faithful actions for <M>G/N</M>.
##  This can be used in algorithms to ensure that
##  <C>NaturalHomomorphismByNormalSubgroup(<A>G</A>,<A>N</A>)</C> will always return the same
##  mapping, even if in the meantime other homomorphisms are computed anew,
##  which &ndash;as a side effect&ndash; obtained a better action for <M>G/N</M> which &GAP;
##  normally would store.
##  The locking can be reverted by <C>UnlockNaturalHomomorphismsPool(<A>G</A>,<A>N</A>)</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("LockNaturalHomomorphismsPool");

#############################################################################
##
#F  UnlockNaturalHomomorphismsPool(<G>,<N>) .  clear flag to allow changes of
##
##  <ManSection>
##  <Func Name="UnlockNaturalHomomorphismsPool" Arg='G,N'/>
##
##  <Description>
##  clears the flag set by <C>LockNaturalHomomorphismsPool(<A>G</A>,<A>N</A>)</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("UnlockNaturalHomomorphismsPool");

#############################################################################
##
#F  KnownNaturalHomomorphismsPool(<G>,<N>) . . .  check whether Hom is stored
##
##  <ManSection>
##  <Func Name="KnownNaturalHomomorphismsPool" Arg='G,N'/>
##
##  <Description>
##  This function tests whether an homomorphism for
##  <C>NaturalHomomorphismByNormalSubgroup(<A>G</A>,<A>N</A>)</C> is already known (or
##  computed trivially for <M>G=N</M> or <M>N=\langle1\rangle</M>).
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("KnownNaturalHomomorphismsPool");

#############################################################################
##
#F  GetNaturalHomomorphismsPool(<G>,<N>) . . . get action for G/N if known
##
##  <ManSection>
##  <Func Name="GetNaturalHomomorphismsPool" Arg='G,N'/>
##
##  <Description>
##  returns a <C>NaturalHomomorphismByNormalSubgroup(<A>G</A>,<A>N</A>)</C> if one is
##  stored already in the <C>NaturalHomomorphismsPool</C> of <A>G</A>.
##  (As the homomorphism may be stored by a <Q>recipe</Q> this command can
##  still take some time when called the first time.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("GetNaturalHomomorphismsPool");

#############################################################################
##
#F  DegreeNaturalHomomorphismsPool(<G>,<N>) degree for action for G/N
##
##  <ManSection>
##  <Func Name="DegreeNaturalHomomorphismsPool" Arg='G,N'/>
##
##  <Description>
##  returns the cost (see <Ref Func="AddNaturalHomomorphismsPool"/>) of a stored action
##  for <M>G/N</M> and fail if no such action is stored.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("DegreeNaturalHomomorphismsPool");


#############################################################################
##
#F  CloseNaturalHomomorphismsPool(<G>[,<N>]) . . calc intersections of known
##
##  <ManSection>
##  <Func Name="CloseNaturalHomomorphismsPool" Arg='G[,N]'/>
##
##  <Description>
##  This command tries to build actions for (new) factor groups from the
##  already known actions in the <C>NaturalHomomorphismsPool(<A>G</A>)</C> by considering
##  intransitive representations for subdirect products. Any new or better
##  homomorphism obtained this way is stored (see
##  <Ref Func="AddNaturalHomomorphismsPool"/>).
##  If the optional parameter <A>N</A> is given, only actions which have <A>N</A> in their
##  kernel are considered.
##  The function keeps track of already considered subdirect products, thus
##  there is no overhead in calling it several times.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CloseNaturalHomomorphismsPool");

#############################################################################
##
#F  PullBackNaturalHomomorphismsPool(<hom>) . . transfer nathoms of image
##
##  <ManSection>
##  <Func Name="PullBackNaturalHomomorphismsPool" Arg='hom'/>
##
##  <Description>
##  If <A>hom</a> is a homomorphism, this command transfers the natural
##  homomorphisms of the image of <A>hom</A> to the source of <A>hom</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("PullBackNaturalHomomorphismsPool");

#############################################################################
##
#F  TryQuotientsFromFactorSubgroups(<hom>,<ker>,<bound>)
##
##  <ManSection>
##  <Func Name="TryQuotientsFromFactorSubgroups" Arg='hom,ker,bound'/>
##
##  <Description>
##  For a homomorphism <A>hom</A>, this command iterates through subgroups
##  of the image, up to index <A>bound</A>,
##  trying to find derived subgroups that expose more of the
##  factor modulo <A>ker</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TryQuotientsFromFactorSubgroups");

#############################################################################
##
#F  EraseNaturalHomomorphismsPool(<G>)
##
##  <ManSection>
##  <Func Name="EraseNaturalHomomorphismsPool" Arg='G'/>
##
##  <Description>
##  This command erases all stored natural homomorphisms associated to the
##  group <A>G</A>. It is used to recover memory.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("EraseNaturalHomomorphismsPool");
