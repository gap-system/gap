#############################################################################
##
#W  stbc.gd                     GAP library                    Heiko Thei"sen
#W                                                               'Akos Seress
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.stbc_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  StabChain( <G>[, <options>] )
#F  StabChain( <G>, <base> )
#O  StabChainOp( <G>, <options> )
#A  StabChainMutable( <G> )
#A  StabChainMutable( <permhomom> )
#A  StabChainImmutable( <G> )
##
##  These commands compute a stabilizer chain for the permutation group <G>;
##  additionally, `StabChainMutable' is also an attribute for the group
##  homomorphism <permhomom> whose source is a permutation group.
##  
##  (The mathematical background of stabilizer chains is sketched
##  in~"Stabilizer Chains",
##  more information about the objects representing stabilizer chains
##  in {\GAP} can be found in~"Stabilizer Chain Records".)
##
##  `StabChainOp' is an operation with two arguments <G> and <options>,
##  the latter being a record which controls some aspects of the computation
##  of a stabilizer chain (see below);
##  `StabChainOp' returns a *mutable* stabilizer chain.
##  `StabChainMutable' is a *mutable* attribute for groups or homomorphisms,
##  its default method for groups is to call `StabChainOp' with empty
##  options record.
##  `StabChainImmutable' is an attribute with *immutable* values;
##  its default method dispatches to `StabChainMutable'.
##
##  `StabChain' is a function with first argument a permutation group <G>,
##  and optionally a record <options> as second argument.
##  If the value of `StabChainImmutable' for <G> is already known and if this
##  stabilizer chain matches the requirements of <options>,
##  `StabChain' simply returns this stored stabilizer chain.
##  Otherwise `StabChain' calls `StabChainOp' and returns an immutable copy
##  of the result; additionally, this chain is stored as `StabChainImmutable'
##  value for <G>.
##  If no <options> argument is given,
##  its components default to the global variable `DefaultStabChainOptions'
##  (see~"DefaultStabChainOptions").
##  If <base> is a list of positive integers,
##  the version `StabChain( <G>, <base> )' defaults to
##  `StabChain( <G>, rec( base:= <base> ) )'.
##
##  If given, <options> is a record whose components specify properties of
##  the desired stabilizer chain or which may help the algorithm.
##  Default values for all of them can be given in the global variable
##  `DefaultStabChainOptions' (see~"DefaultStabChainOptions").
##  The following options are supported.
##  \beginitems
##  `base' (default an empty list) &
##      A list of points, through which the resulting stabilizer chain
##      shall run.
##      For the base $B$ of the resulting stabilizer chain <S> this means
##      the following.
##      If the `reduced' component of <options> is `true' then those points
##      of `base' with nontrivial basic orbits form the initial segment
##      of $B$, if the `reduced' component is `false' then `base' itself
##      is the initial segment of $B$.
##      Repeated occurrences of points in `base' are ignored.
##      If a stabilizer chain for <G> is already known then the stabilizer
##      chain is computed via a base change.
##
##  `knownBase' (no default value) &
##      A list of points which is known to be a base for the group.
##      Such a known base makes it easier to test whether a permutation
##      given as a word in terms of a set of generators is the identity,
##      since it suffices to map the known base with each factor
##      consecutively, rather than multiplying the whole permutations
##      (which would mean to map every point).
##      This speeds up the Schreier-Sims algorithm which is used when a new
##      stabilizer chain is constructed;
##      it will not affect a base change, however.
##      The component `knownBase' bears no relation to the `base'
##      component, you may specify a known base `knownBase' and a desired
##      base `base' independently.
##
##  `reduced' (default `true') &
##      If this is `true' the resulting stabilizer chain <S> is reduced,
##      i.e., the case  $G^{(i)} = G^{(i+1)}$ does not occur.
##      Setting `reduced' to `false' makes sense only if the component
##      `base' (see above) is also set;
##      in this case all points of `base' will occur in the base $B$ of <S>,
##      even if they have trivial basic orbits.
##      Note that if `base' is just an initial segment of $B$,
##      the basic orbits of the points in $B \setminus `base'$ are always
##      nontrivial.
##
##  `tryPcgs' (default `true') &
##      If this is `true' and either the degree is at most 100 or the group
##      is known to be solvable, {\GAP} will first try to construct a pcgs
##      (see Chapter~"Polycyclic Groups") for <G> which will succeed and
##      implicitly construct a stabilizer chain if <G> is solvable.
##      If <G> turns out non-solvable, one of the other methods will be used.
##      This solvability check is comparatively fast, even if it fails,
##      and it can save a lot of time if <G> is solvable.
##
##  `random' (default `1000') &
##      If the value is less than~$1000$,
##      the resulting chain is correct with probability
##      at least~$`random'/1000$.
##      The `random' option is explained in more detail
##      in~"Randomized Methods for Permutation Groups".
##
##  `size' (default `Size( <G> )' if this is known,
##          i.e., if `HasSize( <G> )' is `true') &
##      If this component is present, its value is assumed to be the order
##      of the group <G>.
##      This information can be used to prove that a non-deterministically
##      constructed stabilizer chain is correct.
##      In this case, {\GAP} does a non-deterministic construction until the
##      size is correct.
##
##  `limit' (default `Size( Parent( <G> ) )' or
##           `StabChainOptions( Parent( <G> ) ).limit' if this is present) &
##      If this component is present, it must be greater than or equal to
##      the order of <G>.
##      The stabilizer chain construction stops if size `limit' is reached.
##  \enditems
##
DeclareGlobalFunction( "StabChain" );
DeclareOperation( "StabChainOp", [ IsGroup, IsRecord ] );
DeclareAttribute( "StabChainMutable", IsObject, "mutable" );
DeclareAttribute( "StabChainImmutable", IsObject );


#############################################################################
##
#A  StabChainOptions( <G> )
##
##  is a record that stores the options with which the stabilizer chain
##  stored in `StabChainImmutable' has been computed
##  (see~"StabChain" for the options that are supported).
##
DeclareAttribute( "StabChainOptions", IsPermGroup, "mutable" );


#############################################################################
##
#V  DefaultStabChainOptions
##
##  are the options for `StabChain' which are set as default.
##
DeclareGlobalVariable( "DefaultStabChainOptions",
    "default options for stabilizer chain calculations" );


#############################################################################
##
#F  StabChainBaseStrongGenerators( <base>, <sgs>, <one> )
##
##  If a base <base> for a permutation group $G$ and a strong generating set
##  <sgs> for $G$ with respect to <base> are given. <one> must be the
##  appropriate `One' (in most cases this will be `()').
##  This function constructs a stabilizer chain  without the need to find
##  Schreier generators;
##  so this is much faster than the other algorithms.
##
DeclareGlobalFunction( "StabChainBaseStrongGenerators" );


#############################################################################
##
#F  CopyStabChain( <S> )
##
##  This function returns a copy of the stabilizer chain <S>
##  that has no mutable object (list or record) in common with <S>.
##  The `labels'  components of the result are possibly shared by several
##  levels, but superfluous labels are removed.
##  (An entry in `labels' is superfluous if it does not occur among the
##  `genlabels' or `translabels' on any of the levels which share that
##  `labels' component.)
##
##  This is useful for  stabiliser sub-chains that  have been obtained as
##  the (iterated) `stabilizer' component of a bigger chain.
##
DeclareGlobalFunction( "CopyStabChain" );


#############################################################################
##
#F  CopyOptionsDefaults( <G>, <options> ) . . . . . . . copy options defaults
##
##  sets components in a stabilizer chain options record <options> according
##  to what is known about the group <G>. This can be used to obtain a new
##  stabilizer chain for <G> quickly.
##
DeclareGlobalFunction( "CopyOptionsDefaults" );


#############################################################################
##
#F  BaseStabChain( <S> )
##
##  returns the base belonging to the stabilizer chain <S>.
##
DeclareGlobalFunction( "BaseStabChain" );


#############################################################################
##
#A  BaseOfGroup( <G> )
##
##  returns a base of the permutation group <G>.
##  There is *no* guarantee that a stabilizer chain stored in <G>
##  corresponds to this base!
##
DeclareAttribute( "BaseOfGroup", IsPermGroup );


#############################################################################
##
#F  SizeStabChain( <S> )
##
##  returns the product of the orbit lengths in the stabilizer chain <S>,
##  that is, the order of the group described by <S>.
##
DeclareGlobalFunction( "SizeStabChain" );


#############################################################################
##
#F  StrongGeneratorsStabChain( <S> )
##
##  returns a strong generating set corresponding to the stabilizer chain <S>.
##
DeclareGlobalFunction( "StrongGeneratorsStabChain" );


#############################################################################
##
#F  GroupStabChain([<G>,] <S> )
##
##  constructs a permutation group with stabilizer chain <S>, i.e., a group
##  with  generators `Generators( <S>  )'   to  which <S> is assigned as
##  component  `stabChain'. If the  optional argument <G> is  given, the
##  result  will have the parent <G>.
##
DeclareGlobalFunction( "GroupStabChain" );


#############################################################################
##
#F  IndicesStabChain( <S> )
##
##   returns a list of the indices of the stabilizers in the stabilizer
##   chain <S>.
##
DeclareGlobalFunction( "IndicesStabChain" );


#############################################################################
##
#F  ListStabChain( <S> )
##
##  returns a list that contains at position $i$ the stabilizer of the first
##  $i-1$ base points in the stabilizer chain <S>.
##
DeclareGlobalFunction( "ListStabChain" );


#############################################################################
##
#F  OrbitStabChain( <S>, <pnt> )
##
##  returns the orbit of <pnt> under the group described by the stabilizer
##  chain <S>.
##
DeclareGlobalFunction( "OrbitStabChain" );


#############################################################################
##
#F  ElementsStabChain( <S> )
##
##  returns a list of all elements of the group described by the stabilizer
##  chain <S>.
##
DeclareGlobalFunction( "ElementsStabChain" );


#############################################################################
##
#A  MinimalStabChain(<G>)
##
##  returns the reduced stabilizer chain corresponding to the base
##  $[1,2,3,4,\ldots]$.
##
DeclareAttribute( "MinimalStabChain", IsPermGroup );


#############################################################################
##
#F  ChangeStabChain( <S>, <base>[, <reduced>] )
##
##  changes or reduces a stabilizer chain <S> to be adapted to the base
##  <base>.
##  The optional argument <reduced> is interpreted as follows.
##  \beginitems
##  `reduced = false' : &
##      change the stabilizer chain, do not reduce it,
##
##  `reduced = true' : &
##      change the stabilizer chain, reduce it.
##  \enditems
##
DeclareGlobalFunction( "ChangeStabChain" );


#############################################################################
##
#F  ExtendStabChain( <S>, <base> )
##
##  extends the stabilizer chain <S> so that it corresponds to base <base>.
##  The original base of <S> must be a subset of <base>.
##
DeclareGlobalFunction( "ExtendStabChain" );


#############################################################################
##
#F  ReduceStabChain( <S> )
##
##  changes the stabilizer chain <S> to a reduced stabilizer chain by
##  eliminating trivial steps.
##
DeclareGlobalFunction( "ReduceStabChain" );


#############################################################################
##
#F  EmptyStabChain( <labels>, <id>[, <pnt>] )
##
##  constructs  a   stabilizer  chain  for   the trivial   group with
##  `identity=<id>' and `labels=$\{id\}\cup  labels$'  (but of course with
##  `genlabels=[ ]' and `generators=[ ]'). If the optional third argument
##  <pnt>  is present, the only stabilizer   of the chain is initialized
##  with the  one-point basic orbit  `[ <pnt> ]' and with `translabels' and
##  `transversal' components.
##
DeclareGlobalFunction( "EmptyStabChain" );


#############################################################################
##
#F  ConjugateStabChain( <S>, <T>, <hom>, <map>[, <cond>] )
##
##  conjugates the stabilizer chain <S>.
##  If given, <cond> is a function that determines for a stabilizer record
##  whether the recursion should continue for this record.
##
DeclareGlobalFunction( "ConjugateStabChain" );


#############################################################################
##
#F  RemoveStabChain( <S> )
##
##  <S> must be a stabilizer record in a stabilizer chain. This chain then
##  is cut off at <S> by changing the entries in <S>. This can be used to
##  remove trailing trivial steps.
##
DeclareGlobalFunction( "RemoveStabChain" );

DeclareOperation( "MembershipTestKnownBase", [ IsRecord, IsList, IsList ] );


#############################################################################
##
#F  SiftedPermutation( <S>, <g> )
##
##  sifts the permutation <g> through the stabilizer chain <S> and returns
##  the result after the last step.
##
##  The element <g> is sifted as follows: <g> is replaced by
##  `<g> \* InverseRepresentative( <S>, <S>.orbit[1]^<g> )',
##  then <S> is replaced by `<S>.stabilizer' and this process is repeated
##  until <S> is trivial or `<S>.orbit[1]^<g>' is not in the basic orbit
##  `<S>.orbit'.
##  The remainder <g> is returned, it is the identity permutation if and
##  only if the original <g> is in the group $G$ described by
##  the original~<S>.
##
DeclareGlobalFunction( "SiftedPermutation" );


#############################################################################
##
#F  MinimalElementCosetStabChain( <S>, <g> )
##
##  Let $G$ be the group described by the stabilizer chain <S>.
##  This function returns a permutation $h$ such that $G <g> = G h$
##  (that is, $<g> / h \in G$) and with the additional property that
##  the list of images under $h$ of the base belonging to <S> is minimal
##  w.r.t.~lexicographical ordering.
##
DeclareGlobalFunction( "MinimalElementCosetStabChain" );


#############################################################################
##
#F  SCMinSmaGens(<G>,<S>,<emptyset>,<identity element>,<flag>)
##
##  This function computes a stabilizer chain for a minimal base image and 
##  a smallest generating set wrt. this base for a permutation
##  group.
##
##  <G> must be a permutation group and <S> a mutable stabilizer chain for
##  <G> that defines a base <bas>. Let <mbas> the smallest image (OnTuples)
##  of <G>. Then this operation changes <S> to a stabilizer chain wrt.
##  <mbas>.
##  The arguments <emptyset> and <identity element> are needed
##  only for the recursion.
##
##  The function returns a record whose component `gens' is a list whose
##  first element is the smallest element wrt. <bas>. (i.e. an element which
##  maps <bas> to <mbas>. If <flag> is `true', `gens' is  the smallest
##  generating set wrt. <bas>. (If <flag> is `false' this will not be
##  computed.)
##
DeclareGlobalFunction("SCMinSmaGens");


#############################################################################
##
#F  LargestElementStabChain( <S>, <id> )
##
##  Let $G$ be the group described by the stabilizer chain <S>.
##  This function returns the element $h \in G$ with the property that
##  the list of images under $h$ of the base belonging to <S> is maximal
##  w.r.t.~lexicographical ordering.
##  The second argument must be an identity element (used to start the
##  recursion)
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
##  adds the elements  in <new> to the list  of generators of <S> and at the
##  same time extends the  orbit and transversal. This is the only legal way
##  to extend  a  Schreier tree (because this involves careful handling of
##  the tree components).
##
DeclareGlobalFunction( "AddGeneratorsExtendSchreierTree" );

DeclareGlobalFunction( "ChooseNextBasePoint" );
DeclareGlobalFunction( "StabChainStrong" );
DeclareGlobalFunction( "StabChainForcePoint" );
DeclareGlobalFunction( "StabChainSwap" );
DeclareGlobalFunction( "InsertElmList" );
DeclareGlobalFunction( "RemoveElmList" );
DeclareGlobalFunction( "LabsLims" );


#############################################################################
##
#F  InsertTrivialStabilizer( <S>, <pnt> )
##
##  `InsertTrivialStabilizer' initializes the current stabilizer with <pnt>
##  as `EmptyStabChain' did,  but  assigns the original <S> to the  new
##  `<S>.stabilizer' component,  such that  a new level with trivial basic
##  orbit (but identical  `labels' and `ShallowCopy'ed `genlabels' and
##  `generators') is  inserted.
##  This function should be used only if <pnt> really is fixed by the generators
##  of <S>, because then new generators can be added and the orbit and
##  transversal at the same time extended with
##  `AddGeneratorsExtendSchreierTree'.
##
DeclareGlobalFunction( "InsertTrivialStabilizer" );

DeclareGlobalFunction( "InitializeSchreierTree" );

DeclareGlobalFunction( "BasePoint" );
DeclareGlobalFunction( "IsInBasicOrbit" );


#############################################################################
##
#F  IsFixedStabilizer( <S>, <pnt> )
##
## returns `true'  if <pnt> is fixed by   all generators of  <S> and `false'
## otherwise.
##
DeclareGlobalFunction( "IsFixedStabilizer" );


#############################################################################
##
#F  InverseRepresentative( <S>, <pnt> )
##
##  calculates the transversal element which  maps <pnt> back to  the base
##  point of  <S>. It just  runs back through the  Schreier tree from <pnt>
##  to the root and multiplies the labels along the way.
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


#############################################################################
##
#E

