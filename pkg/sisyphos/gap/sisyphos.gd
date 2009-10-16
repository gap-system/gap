#############################################################################
##
#W  sisyphos.gd              GAP Share Library               Martin Wursthorn
##
#H  @(#)$Id: sisyphos.gd,v 1.1 2000/10/23 17:05:01 gap Exp $
##
#Y  Copyright 1994-1995,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of the user interface
##  between {\SISYPHOS} and {\GAP}~4.
##
Revision.sisyphos_gd :=
    "@(#)$Id: sisyphos.gd,v 1.1 2000/10/23 17:05:01 gap Exp $";


#############################################################################
#1
##  The following functions all return a record with the following
##  components.
##  \beginitems
##  `sizeOutG': &
##      the size of the group of outer automorphisms of <P>,
##
##  `sizeInnG': &
##      the size of the group of inner automorphisms of <P>,
##  
##  `sizeAutG': &
##      the size of the full automorphism group of <P>,
##  
##  `generators': &
##      a list of group automorphisms that
##                    generate the group of all, outer,
##                    normalized or normalized outer automorphisms of the
##                    polycyclically presented $p$-group <P>, respectively.
##                    In the case of outer or normalized outer automorphisms,
##                    this list consists of preimages in $Aut($<P>$)$ of a
##                    generating set for $Aut($<P>$)/Inn($<P>$)$ or
##                    $Aut_n($<P>$)/Inn($<P>$)$, respectively.
##  \enditems
##


#############################################################################
##
#F  SisyphosAutomorphisms( <P>, <flags> ) . . . automorphism group of p-group
##
##  general interface to SISYPHOS's 'automorphisms' function
##
##  *Note*\:\ If the component '<P>.isCompatiblePCentralSeries' is not bound
##  it is computed.
##
DeclareGlobalFunction( "SisyphosAutomorphisms" );


##############################################################################
##
#F  SAutomorphisms( <P> )  . . . . . . . .  full automorphism group of p-group
#F  OuterAutomorphisms( <P> )  . . . . . . outer automorphism group of p-group
#F  NormalizedAutomorphisms( <P> ) . . . . normalized automorphisms of p-group
#F  NormalizedOuterAutomorphisms(<P>)  .  norm. outer automorphisms of p-group
##
DeclareGlobalFunction( "SAutomorphisms" );
DeclareGlobalFunction( "OuterAutomorphisms" );
DeclareGlobalFunction( "NormalizedAutomorphisms" );
DeclareGlobalFunction( "NormalizedOuterAutomorphisms" );


##############################################################################
##
#F  PresentationAutomorphisms( <P>, <flag> ) . . automorphism group of p-group
##
##  returns a polycyclicly presented group isomorphic to the normalized
##  automorphisms of the polycyclicly presented $p$-group <P>.
##  `flag' may have the values `\"all\"' or `\"outer\"'; in the latter case
##  only the group of normalized outer automorphisms is returned.
##
##  The group has a component `SISAuts' whose generators correspond to the
##  generators of the returned group.
##
##  *Note*:  If the component `<P>.isCompatiblePCentralSeries' is not bound
##  it is computed.
##
DeclareGlobalFunction( "PresentationAutomorphisms" );


##############################################################################
##
#F  PcNormalizedAutomorphisms( <P> ) . . . . . . . normalized automorphisms of
#F                                                      p-group <P> as PcGroup
#F  PcNormalizedOuterAutomorphisms( <P> )  . normalized outer automorphisms of
#F                                                      p-group <P> as PcGroup
##
##  returns a polycyclicly presented group isomorphic to the group of
##  all normalized (outer) automorphisms of the polycyclicly presented
##  $p$-group <P>.
##
DeclareGlobalFunction( "PcNormalizedAutomorphisms" );
DeclareGlobalFunction( "PcNormalizedOuterAutomorphisms" );


##############################################################################
##
#F  IsIsomorphic( <P1>, <P2> ) . . . . . . . .  isomorphism check for p-groups
##
##  Let <P1> be a freely or polycyclicly presented $p$-group,
##  and <P2> be a polycyclicly presented $p$-group.
##  `IsIsomorphic' returns `true' if the <P1> and <P2> are isomorphic,
##  and `false' otherwise.
##
##  (The function `Isomorphisms' returns isomorphisms in case the groups are
##  isomorphic.)
#T why not delegate to this function?
#T efficiency reasons?
##
DeclareGlobalFunction( "IsIsomorphic" );


##############################################################################
##
#F  Isomorphisms( <P1>, <P2> ) . . . . . . . . . isomorphisms between p-groups
##
##  Let <P1> and <P2> be polycyclicly presented $p$-groups.
##  If <P1> and <P2> are not isomorphic, `Isomorphisms' returns `false'.
##  Otherwise a record is returned that encodes the isomorphisms from <P1> to
##  <P2>; its components are
##  \beginitems
##  `epimorphism': &
##      a list of images of `GeneratorsOfGroup( <P1> )' that defines an
##      isomorphism from <P1> to <P2>,
##
##  `generators': &
##      a list of automorphisms that together with the inner automorphisms
##      generate the full automorphism group of <P2>,
##
##  `sizeOutG': &
##      order of the group of outer automorphisms of <P2>,
##
##  `sizeInnG': &
##      order of the group of inner automorphisms of <P2>, and
##
##  `sizeAutG': &
##      order of the full automorphism group of <P2>.
##  \endexample
##
##  (The function `IsIsomorphic' tests for isomorphism of $p$-groups.)
##
##  *Note*\:\ If the component '<P2>.isCompatiblePCentralSeries' is not bound
##  it is computed.
##
DeclareGlobalFunction( "Isomorphisms" );


##############################################################################
##
#F  CorrespondingAutomorphism( <A>, <w> ) . .  automorphism corresp. to agword
##
##  If <A> is a polycyclicly presented group of automorphisms of a group $P$
##  (as returned by "AgNormalizedAutomorphisms" `AgNormalizedAutomorphisms' or
##  "AgNormalizedOuterAutomorphisms" `AgNormalizedOuterAutomorphisms'),
##  and <w> is an element of <A> then `CorrespondingAutomorphism( <A>, <w> )'
##  returns the automorphism of $P$ corresponding to <w>.
##
##  *Note*\:\ If the component '$P$.isCompatiblePCentralSeries' is not bound
##  it is computed.
##
DeclareGlobalFunction( "CorrespondingAutomorphism" );


##############################################################################
##
#F  AutomorphismGroupElements( <A> ) . . .  element list of automorphism group
##
##  <A> must be an automorphism record as returned by one of the automorphism
##  routines or a list consisting of automorphisms of a $p$-group $P$.
##  
##  In the first case a list of all elements of $Aut(P)$ or $Aut_n(P)$ is
##  returned, if <A> has been created by `Automorphisms'
##  or `NormalizedAutomorphisms' (see~"Automorphisms"),
##  respectively, or a list of coset representatives of $Aut(P)$ or $Aut_n(P)$
##  modulo $Inn(P)$, if <A> has been created by `OuterAutomorphisms'
##  or `NormalizedOuterAutomorphisms' (see~"Automorphisms"), respectively.
##
##  In the second case the list of all elements of the subgroup of $Aut(P)$
##  generated by <A> is returned.
##
##  *Note*\:\ If the component '$P$.isCompatiblePCentralSeries' is not bound
##  it is computed.
##
DeclareGlobalFunction( "AutomorphismGroupElements" );


#############################################################################
##
#A  NormalizedUnitsGroupRing( <P> )
#O  NormalizedUnitsGroupRing( <P>, <n> )
##
##  When called with a polycyclicly presented $p$-group <P>, the group
##  of normalized units of the group ring $F<P>$ of <P> over the field $F$
##  with $p$ elements is returned.
##
##  If a second argument <n> is given, the group of normalized units of
#T positive or nonnegative integer?
##  $F<P> / I^n$ is returned, where $I$ denotes the augmentation ideal of
##  $F<P>$.
##
##  The group returned is represented as polycyclicly presented group.
##
DeclareAttribute( "NormalizedUnitsGroupRing", IsGroup );
DeclareOperation( "NormalizedUnitsGroupRing", [ IsGroup, IsInt ] );


#############################################################################
##
#E

