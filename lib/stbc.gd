#############################################################################
##
#W  stbc.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.stbc_gd :=
    "@(#)$Id$";

#############################################################################
##
#F  StabChain(<G>[,<options>])
#F  StabChain(<G>,<base>)
#O  StabChainOp(<G>,<options>)
#A  StabChainMutable(<G>)
#A  StabChainMutable(<permhomom>)
#A  StabChainImmutable(<G>)
##
##  These commands compute a stabilizer chain for the permutation group <G>
##  or a permutation group homomorphism <permhomom>.
##  `StabChainOp' is an operation with  two arguments <G> and <options>, the
##  latter being a record which performs the actual work of computing a
##  stabilizer chain. It returns a *mutable* stabilizer chain.
##  `StabChainMutable' is an attribute for groups or homomorphisms.
##  Its default method for groups is to  call `StabChainOp' with empty
##  record.
##  `StabChainImmutable' is an attribute with *immutable* values, which
##  dispatches to `StabChainMutable'. Whenever a stabilizer chain is
##  computed for a group which does not yet posess one, an immutable copy is
##  stored in the attribute `StabChainImmutable'.
## 
##  `StabChain' is a function which takes one or two arguments and
##  dispatches to `StabChainImmutable' (if available and the options permit
##  this) or `Immutable( StabChainOp( ... ) )', hence it also returns an
##  *immutable* result.  If the record argument <option> is not given, its
##  components default to the global variable `DefaultStabChainOptions'.
##  If <base> is a list of positive integers, the version
##  `StabChain(<G>,<base>)' defaults to `StabChain(<G>,rec(base:=<base>))'.
##
##  If given, <options> is a record whose components specify properties of
##  the stabilizer chain or may help the algorithm. Default values for all
##  of them can be given in the global variable `DefaultStabchainOptions'.
##  The available options are:
##  \beginitems
##  `base' &
##  A list of  points, through which the resulting stabilizer   chain
##  will run. This  means  that the sequence  of base points will start
##  off with `base' if the chain is not  reduced (if it is  reduced,
##  however, points  from `base' that would lead to duplicate
##  stabilizers will be skipped). Repeated occurrences  of  points in
##  `base'  are  ignored.  If a stabilizer chain for <G> is already
##  known no new stabilizer chain is computed, but a base change is
##  performed instead.
##
##  `knownBase' &
##  A list of points which is known to be a base for the group.  A  known
##  base makes it easier  to test whether a   product   of certain
##  permutations (namely,    a Schreier generator) is the identity, because
##  it is enough to map the known base  with   each  factor consecutively,
##  rather    than multiplying the   whole permutations (which means
##  mapping every point).  This will speed up the Schreier-Sims algorithm if
##  a new  stabilizer chain has to  be constructed (it  will not affect the
##  base change, however). The component bears no relation to the  `base'
##  component, you  may specify a known base `knownBase' and a desired base
##  `base' independently.
##
##  `reduced' (default `true') &
##  If this  is `true' the  resulting stabilizer chain   will  be reduced,
##  i.e., the case  $G^{(i)} = G^{(i+1)}$  will  not occur. To set
##  `reduced'  to `false' makes sense only  if  `base' is also  set;  in
##  this case  all points of `base' will occur  in the base,  even if they
##  have  trivial basic orbits.  However, if `base' is  not a complete base
##  but has to be prolonged, the prolongation will be reduced.
##
##  `tryPcgs' (default `true') &
##  If this is `true' and the degree is at most 100 or the group is known to
##  be solvable, {\GAP} will first try to  construct a pcgs for <G> which
##  will succeed and implicitly construct a stabilizer chain if <G> is
##  solvable.  If <G> turns out non-solvable, one of the other methods will
##  be used. This solvability  check is comparatively fast, even if it
##  fails, and it  can save a lot of time if <G> is solvable.
##
##  `random' (default `1000') &
##  If this  is  less than~1000,  the  computation of the  stabilizer
##  chain  will  be   done  non-deterministically, as  described   in
##  \cite{Seress98}. The  probability  that the  resulting  chain  is
##  correct will be at least~$`random'/1000$.
##
##  `size' (default `Size(<G>)' if this is known, i.e., if `HasSize(<G>)')&
##  If this is present, it is assumed to be the size of the group <G>
##  This      information    can  be    used    to   prove    that  a
##  non-deterministically constructed stabilizer chain is correct. In
##  this case, {\GAP} does a non-deterministic construction until the
##  size is correct.
##
##  `limit' (default `Size(Parent(<G>))' or `StabChainOptions(Parent(
##  <G>)).limit' if this is present) &
##  If this is present, it must be greater than or  equal to the size
##  of~<G>. The stabilizer chain construction stops, if size `limit' is reached.
##  \enditems
DeclareGlobalFunction( "StabChain" );
DeclareOperation( "StabChainOp", [ IsGroup, IsRecord ] );
DeclareAttribute( "StabChainMutable", IsObject, "mutable" );
DeclareAttribute( "StabChainImmutable", IsObject );

#############################################################################
##
#A  StabChainOptions(<G>)
##
##  is a record that stores the options with which the stabilizer chain
##  stored in `StabChainImmutable' has been computed.
##
DeclareAttribute( "StabChainOptions",
    IsPermGroup, "mutable" );

#############################################################################
##
#V  DefaultStabChainOptions
##
##  are the options for `StabChain' which are set as default.
DeclareGlobalVariable( "DefaultStabChainOptions",
 "default options for stabilizer chain calculations" );

#############################################################################
##
#A  BaseOfGroup(<G>)
##
##  returns a base to <G>. There is *no* guarantee that a stabilizer chain
##  stored in the group corresponds to this base!
##
DeclareAttribute( "BaseOfGroup", IsPermGroup );

#############################################################################
##
#F  StabChainBaseStrongGenerators(<base>,<sgs>)
##
##  If a base <base> for a group and a strong generating  set <sgs> with
##  respect to <base> are given, this function constructs a stabilizer chain
##  without the need to find Schreier  generators; so this  is much faster
##  than the other algorithms.
DeclareGlobalFunction(
    "StabChainBaseStrongGenerators" );

#############################################################################
##
#F  CopyStabChain( <C> )
##
##  This function produces a memory-disjoint copy of a stabilizer chain <C>,
##  with `labels'  components   possibly   shared by  several  levels,   but
##  with superfluous labels  removed. An entry  in  `labels' is superfluous
##  if it does not occur among  the  `genlabels' or `translabels'   on any
##  of  the levels which share that `labels' component.
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
DeclareGlobalFunction( "CopyOptionsDefaults" );

#############################################################################
##
#F  BaseStabChain( <S> )
##
##  returns the base belonging to the stabilizer chain <S>.
DeclareGlobalFunction( "BaseStabChain" );

#############################################################################
##
#F  SizeStabChain( <S> )
##
##  returns the product of the orbit lengths in the stabilizer chain <S>.
##  (That is the size of the group described by <S>.)
DeclareGlobalFunction( "SizeStabChain" );

#############################################################################
##
#F  StrongGeneratorsStabChain( <S> )
##
##  returns a strong generating set corresponding to the stabilizer chain <S>.
DeclareGlobalFunction( "StrongGeneratorsStabChain" );

#############################################################################
##
#F  GroupStabChain([<G>,] <C> )
##
##  creates a group (subgroup of <G>) form the stabilizer chain <C>.
DeclareGlobalFunction( "GroupStabChain" );

#############################################################################
##
#F  IndicesStabChain( <S> )
##
##   returns a list of the indices of the stabilizers in the stabilizer
##   chain <S>.
DeclareGlobalFunction( "IndicesStabChain" );

#############################################################################
##
#F  ListStabChain( <S> )
##
##  returns a list that contains the stabilizers in the chain <S> in
##  descending order.
DeclareGlobalFunction( "ListStabChain" );

#############################################################################
##
#F  OrbitStabChain( <S>, <pnt> )
##
##  returns the orbit of <pnt> under the group described by the stabilizer
##  chain <S>.
DeclareGlobalFunction( "OrbitStabChain" );

#############################################################################
##
#A  MinimalStabChain(<G>)
##
##  returns the reduced stabilizer chain corresponding to the base
##  $[1,2,3,4,\ldots]$.
DeclareAttribute("MinimalStabChain",IsPermGroup);

#############################################################################
##
#F  ChangeStabChain(<C>,<base>[,<reduced>])
##
##  changes or reduces a stabilizer chain <C> to be adapted to base <base>.
##  The optional argument <reduced> is interpreted as:
##
##  reduced = -1    : extend stabilizer chain
##
##  reduced = false : change stabilizer chain, do not reduce it
##
##  reduced = true  : change stabilizer chain, reduce it
##
DeclareGlobalFunction( "ChangeStabChain" );

#############################################################################
##
#F  ExtendStabChain( <C>, <base> )
##
##  extends the stabilizer chain <C> to be adapted to <base>. This function
##  just calls 'ChangeStabChain'
DeclareGlobalFunction( "ExtendStabChain" );

#############################################################################
##
#F  ReduceStabChain( <C> )
##
##  changes the stabilizer chain <C> to a reduced stabilizer chain by
##  eliminating trivial steps.
DeclareGlobalFunction( "ReduceStabChain" );

#############################################################################
##
#F  EmptyStabChain( <labels>,<id>[,<limgs>,<idimg>][,<pnt>] )
##
##  constructs an empty stabilizer chain.
##
DeclareGlobalFunction( "EmptyStabChain" );

#############################################################################
##
#F  ConjugateStabChain( <S>, <T>, <hom>, <map> [,<cond>] )
##
##  conjugates a stabilizer chain.
##  If given, <cond> is a function that determines for a stabilizer record
##  whether the recursion should continue for this record.
##
DeclareGlobalFunction( "ConjugateStabChain" );

#############################################################################
##
#F  RemoveStabChain( <S> )
##
##  <S> must be a stabilizer record in a stabilizer chain. This chain thes
##  is cut off at <S> by changing the entries in <S>. This cane be used to
##  remove trailing trivial steps.
DeclareGlobalFunction( "RemoveStabChain" );

DeclareOperation( "MembershipTestKnownBase",
                                   [ IsRecord, IsList, IsList ] );

#############################################################################
##
#F  SiftedPermutation( <S>, <g> )
##
##  sifts the permutation <g> through the stabilizer chain <S> and returns
##  the result after the last step. This is the identity if <g> is in the
##  group described by <S> and is a result only dependent on <S> and the coset
##  $\langle<S>\rangle g$ (but not on the representative <g>) otherwise.
DeclareGlobalFunction( "SiftedPermutation" );

#############################################################################
##
#F  MinimalElementCosetStabChain( <S>, <g> )
##
##  Let <G> be the group described by <S>. This function returns an element
##  <h> such that $<G><g>=<G><h>$ (that is $<g>/<h>\in<G>$) with the
##  additional property that <h> maps the base belonging to <S> in a minimal
##  possible way.
DeclareGlobalFunction(
    "MinimalElementCosetStabChain" );

DeclareCategory( "IsPermOnEnumerator",
    IsMultiplicativeElementWithInverse and IsPerm );

DeclareOperation( "PermOnEnumerator",
    [ IsEnumerator, IsObject ] );


DeclareGlobalFunction( "DepthSchreierTrees" );
DeclareGlobalFunction(
    "AddGeneratorsExtendSchreierTree" );
DeclareGlobalFunction( "ChooseNextBasePoint" );
DeclareGlobalFunction( "StabChainStrong" );
DeclareGlobalFunction( "StabChainForcePoint" );
DeclareGlobalFunction( "StabChainSwap" );
DeclareGlobalFunction( "InsertElmList" );
DeclareGlobalFunction( "RemoveElmList" );
DeclareGlobalFunction( "LabsLims" );

DeclareGlobalFunction( "InitializeSchreierTree" );
DeclareGlobalFunction( "InsertTrivialStabilizer" );
DeclareGlobalFunction( "BasePoint" );
DeclareGlobalFunction( "IsInBasicOrbit" );
DeclareGlobalFunction( "IsFixedStabilizer" );
DeclareGlobalFunction( "InverseRepresentative" );
DeclareGlobalFunction(
    "QuickInverseRepresentative" );
DeclareGlobalFunction(
    "InverseRepresentativeWord" );

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
#E  stbc.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

