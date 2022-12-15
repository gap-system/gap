#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

DeclareInfoClass( "InfoAction" );
DeclareSynonym( "InfoOperation",InfoAction );


#############################################################################
##
#C  IsExternalSet(<obj>)
##
##  <#GAPDoc Label="IsExternalSet">
##  <ManSection>
##  <Filt Name="IsExternalSet" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>external set</E> specifies a group action
##  <M>\mu: \Omega \times G \mapsto \Omega</M> of a group <M>G</M>
##  on a domain <M>\Omega</M>. The external set knows the group,
##  the domain and the actual acting function.
##  Mathematically, an external set is the set&nbsp;<M>\Omega</M>,
##  which is endowed with the action of a group <M>G</M> via the group action
##  <M>\mu</M>.
##  For this reason &GAP; treats an external set as a domain whose elements
##  are the  elements of <M>\Omega</M>.
##  An external set is always a union of orbits.
##  Currently the domain&nbsp;<M>\Omega</M> must always be finite.
##  If <M>\Omega</M> is not a list,
##  an enumerator for <M>\Omega</M> is automatically chosen,
##  see <Ref Attr="Enumerator"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsExternalSet", IsDomain );

OrbitishReq  := [ IsGroup, IsListOrCollection, IsObject,
                  IsList,
                  IsList,
                  IsFunction ];
MakeImmutable(OrbitishReq);

OrbitsishReq := [ IsGroup, IsListOrCollection,
                  IsList,
                  IsList,
                  IsFunction ];
MakeImmutable(OrbitsishReq);

#############################################################################
##
#R  IsExternalSubset(<obj>)
##
##  <#GAPDoc Label="IsExternalSubset">
##  <ManSection>
##  <Filt Name="IsExternalSubset" Arg='obj' Type='Representation'/>
##
##  <Description>
##  An external subset is the restriction  of an external  set to a subset
##  of the domain (which must be invariant under the action). It is again an
##  external set.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsExternalSubset",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "start" ] );


#############################################################################
##
#R  IsExternalOrbit(<obj>)
##
##  <#GAPDoc Label="IsExternalOrbit">
##  <ManSection>
##  <Filt Name="IsExternalOrbit" Arg='obj' Type='Representation'/>
##
##  <Description>
##  An external orbit is an external subset consisting of one orbit.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsExternalOrbit",
    IsExternalSubset, [ "start" ] );
DeclareCategory( "IsExternalSetByPcgs", IsExternalSet );



#############################################################################
##
#R  IsExternalSetDefaultRep(<obj>)
#R  IsExternalSetByActorsRep(<obj>)
##
##  <ManSection>
##  <Filt Name="IsExternalSetDefaultRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsExternalSetByActorsRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  External sets  can be specified  directly (<C>IsExternalSetDefaultRep</C>), or
##  via <A>gens</A> and <A>acts</A> (<C>IsExternalSetByActorsRep</C>).
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsExternalSetDefaultRep",
    IsAttributeStoringRep and IsExternalSet,
    [  ] );
DeclareRepresentation( "IsExternalSetByActorsRep",
    IsAttributeStoringRep and IsExternalSet,
    [ "generators", "operators", "funcOperation" ] );
DeclareSynonym( "IsExternalSetByOperatorsRep",IsExternalSetByActorsRep);

#############################################################################
##
#A  ActingDomain( <xset> )
##
##  <#GAPDoc Label="ActingDomain">
##  <ManSection>
##  <Attr Name="ActingDomain" Arg='xset'/>
##
##  <Description>
##  This attribute returns the group with which the external set <A>xset</A> was
##  defined.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ActingDomain", IsExternalSet );

#############################################################################
##
#A  HomeEnumerator( <xset> )
##
##  <#GAPDoc Label="HomeEnumerator">
##  <ManSection>
##  <Attr Name="HomeEnumerator" Arg='xset'/>
##
##  <Description>
##  returns an enumerator of the action domain with which the external set
##  <A>xset</A> was defined.
##  For external subsets, this is in general different from the
##  <Ref Attr="Enumerator"/> value of <A>xset</A>,
##  which enumerates only the subset.
##  <Example><![CDATA[
##  gap> ActingDomain(e);
##  Group([ (1,2,3), (2,3,4) ])
##  gap> FunctionAction(e)=OnRight;
##  true
##  gap> HomeEnumerator(e);
##  [ (), (2,3,4), (2,4,3), (1,2)(3,4), (1,2,3), (1,2,4), (1,3,2),
##    (1,3,4), (1,3)(2,4), (1,4,2), (1,4,3), (1,4)(2,3) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "HomeEnumerator", IsExternalSet );

DeclareRepresentation( "IsActionHomomorphism",
    IsGroupHomomorphism and IsAttributeStoringRep and
    IsPreimagesByAsGroupGeneralMappingByImages, [  ] );

DeclareRepresentation( "IsActionHomomorphismByActors",
      IsActionHomomorphism, [  ] );

DeclareRepresentation("IsActionHomomorphismSubset",IsActionHomomorphism,[]);

#############################################################################
##
#A  ActionKernelExternalSet( <xset> )
##
##  <ManSection>
##  <Attr Name="ActionKernelExternalSet" Arg='xset'/>
##
##  <Description>
##  This attribute gives the kernel of the <C>ActionHomomorphism</C> for <A>xset</A>.
##  <P/>
##  <!--  At the moment no methods exist, the attribute is solely used to transfer-->
##  <!--  information. -->
##  </Description>
##  </ManSection>
##
DeclareAttribute( "ActionKernelExternalSet", IsExternalSet );

#############################################################################
##
#R  IsActionHomomorphismByBase(<obj>)
##
##  <ManSection>
##  <Filt Name="IsActionHomomorphismByBase" Arg='obj' Type='Representation'/>
##
##  <Description>
##  This is chosen if <C>HasBaseOfGroup( <A>xset</A> )</C>.
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsActionHomomorphismByBase",
      IsActionHomomorphism, [  ] );

#############################################################################
##
#R  IsConstituentHomomorphism(<obj>)
##
##  <ManSection>
##  <Filt Name="IsConstituentHomomorphism" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsConstituentHomomorphism",
    IsActionHomomorphism, [ "conperm" ] );

DeclareRepresentation( "IsBlocksHomomorphism",
    IsActionHomomorphism, [ "reps" ] );

#############################################################################
##
#R  IsLinearActionHomomorphism(<hom>)
##
##  <ManSection>
##  <Filt Name="IsLinearActionHomomorphism" Arg='hom' Type='Representation'/>
##
##  <Description>
##  This   representation is chosen  for  action homomorphisms from matrix
##  groups acting naturally on a set of vectors.
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsLinearActionHomomorphism",
      IsActionHomomorphism, [  ] );

#############################################################################
##
#R  IsProjectiveActionHomomorphism(<hom>)
##
##  <ManSection>
##  <Filt Name="IsProjectiveActionHomomorphism" Arg='hom' Type='Representation'/>
##
##  <Description>
##  This   representation is chosen  for  action homomorphisms from matrix
##  groups acting projectively on a set of normed vectors.
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsProjectiveActionHomomorphism",
      IsActionHomomorphism, [  ] );

#############################################################################
##
#A  LinearActionBasis(<hom>)
##
##  <ManSection>
##  <Attr Name="LinearActionBasis" Arg='hom'/>
##
##  <Description>
##  for action homomorphisms in the representation
##  <C>IsLinearActionHomomorphism</C> or
##  <C>IsProjectiveActionHomomorphism</C>,
##  this attribute contains a vector space
##  basis as subset of the domain or <K>fail</K> if the domain does not span the
##  vector space that the group acts on.
##  groups acting naturally on a set of vectors.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "LinearActionBasis",IsLinearActionHomomorphism);

#############################################################################
##
#A  FunctionAction( <xset> )
##
##  <#GAPDoc Label="FunctionAction">
##  <ManSection>
##  <Attr Name="FunctionAction" Arg='xset'/>
##
##  <Description>
##  is the acting function with which the external set <A>xset</A> was
##  defined.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FunctionAction", IsExternalSet );

#############################################################################
##
#A  StabilizerOfExternalSet( <xset> ) .  stabilizer of `Representative(xset)'
##
##  <#GAPDoc Label="StabilizerOfExternalSet">
##  <ManSection>
##  <Attr Name="StabilizerOfExternalSet" Arg='xset'/>
##
##  <Description>
##  computes the stabilizer of the <Ref Attr="Representative"/> value of
##  the external set <A>xset</A>.
##  The stabilizer will have the acting group of <A>xset</A> as its parent.
##  <Example><![CDATA[
##  gap> Representative(e);
##  (1,2,3)
##  gap> StabilizerOfExternalSet(e);
##  Group([ (1,2,3) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "StabilizerOfExternalSet", IsExternalSet );

#############################################################################
##
#A  CanonicalRepresentativeOfExternalSet( <xset> )
##
##  <#GAPDoc Label="CanonicalRepresentativeOfExternalSet">
##  <ManSection>
##  <Attr Name="CanonicalRepresentativeOfExternalSet" Arg='xset'/>
##
##  <Description>
##  The canonical representative of an external set <A>xset</A> may only
##  depend on the defining attributes <A>G</A>, <A>Omega</A>, <A>act</A>
##  of <A>xset</A> and (in the case of external subsets)
##  <C>Enumerator( <A>xset</A> )</C>.
##  It must <E>not</E> depend, e.g., on the representative of an external
##  orbit.
##  &GAP; does not know methods for arbitrary external sets to compute a
##  canonical representative,
##  see <Ref Attr="CanonicalRepresentativeDeterminatorOfExternalSet"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CanonicalRepresentativeOfExternalSet", IsExternalSet );


#############################################################################
##
#A  CanonicalRepresentativeDeterminatorOfExternalSet( <xset> )
##
##  <#GAPDoc Label="CanonicalRepresentativeDeterminatorOfExternalSet">
##  <ManSection>
##  <Attr Name="CanonicalRepresentativeDeterminatorOfExternalSet" Arg='xset'/>
##
##  <Description>
##  returns a function that takes as its arguments the acting group and a
##  point.
##  This function returns a list of length 1 or 3,
##  the first entry being the canonical representative and the other entries
##  (if bound) being the stabilizer of the canonical representative and a
##  conjugating element, respectively.
##  An external set is only guaranteed to be able to compute a canonical
##  representative if it has a
##  <Ref Attr="CanonicalRepresentativeDeterminatorOfExternalSet"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CanonicalRepresentativeDeterminatorOfExternalSet",
    IsExternalSet );

#############################################################################
##
#P  CanEasilyDetermineCanonicalRepresentativeExternalSet( <xset> )
##
##  <ManSection>
##  <Prop Name="CanEasilyDetermineCanonicalRepresentativeExternalSet" Arg='xset'/>
##
##  <Description>
##  This property indicates whether an external set knows or has a
##  possibility to determine a canonical representative
##  </Description>
##  </ManSection>
##
DeclareProperty( "CanEasilyDetermineCanonicalRepresentativeExternalSet",
    IsExternalSet );

InstallTrueMethod(CanEasilyDetermineCanonicalRepresentativeExternalSet,
  HasCanonicalRepresentativeDeterminatorOfExternalSet);
InstallTrueMethod(CanEasilyDetermineCanonicalRepresentativeExternalSet,
  HasCanonicalRepresentativeOfExternalSet);

#############################################################################
##
#A  ActorOfExternalSet( <xset> )
##
##  <#GAPDoc Label="ActorOfExternalSet">
##  <ManSection>
##  <Attr Name="ActorOfExternalSet" Arg='xset'/>
##
##  <Description>
##  returns an element mapping <C>Representative(<A>xset</A>)</C> to
##  <C>CanonicalRepresentativeOfExternalSet(<A>xset</A>)</C> under the given
##  action.
##  <Example><![CDATA[
##  gap> u:=Subgroup(g,[(1,2,3)]);;
##  gap> e:=RightCoset(u,(1,2)(3,4));;
##  gap> CanonicalRepresentativeOfExternalSet(e);
##  (2,4,3)
##  gap> ActorOfExternalSet(e);
##  (1,3,2)
##  gap> FunctionAction(e)((1,2)(3,4),last);
##  (2,4,3)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ActorOfExternalSet", IsExternalSet );
DeclareSynonymAttr( "OperatorOfExternalSet", ActorOfExternalSet );


#############################################################################
##
#F  TestIdentityAction(acts,pnt,act)
##
##  <ManSection>
##  <Func Name="TestIdentityAction" Arg='acts,pnt,act'/>
##
##  <Description>
##  tests whether the identity element fixes <A>pnt</A>
##  &ndash;if not the action is
##  not well-defined. If the global option <C>NoTestAction</C> is set to <K>true</K>
##  this test is skipped. (This is essentially a hack.)
##  </Description>
##  </ManSection>
##
BindGlobal("TestIdentityAction",function(acts,pnt,act)
local id,img;
  if ValueOption("NoTestAction")<>true and Length(acts)>0 then
    id:=One(acts[1]);
    img:=act(pnt,id);
    if img<>pnt then
      Error("Action not well-defined. See the manual section\n",
      "``Action on canonical representatives''.");
    fi;
    pnt:=img;
  fi;
  return pnt;
end);

#############################################################################
##
#F  OrbitsishOperation( <name>, <reqs>, <usetype>, <AorP> ) . orbits-like op.
##
##  <#GAPDoc Label="OrbitsishOperation">
##  <ManSection>
##  <Func Name="OrbitsishOperation" Arg='name, reqs, usetype, AorP'/>
##
##  <Description>
##  declares an attribute <C>op</C>, with name <A>name</A>.
##  The second argument <A>reqs</A> specifies the list of required filters
##  for the usual (five-argument) methods that do the real work.
##  <P/>
##  If the third argument <A>usetype</A> is <K>true</K>,
##  the function call <C>op( xset )</C> will
##  &ndash;if the value of <C>op</C> for <C>xset</C> is not yet known&ndash;
##  delegate to the five-argument call of <C>op</C> with second argument
##  <C>xset</C> rather than with <C>D</C>.
##  This allows certain methods for <C>op</C> to make use of the type of
##  <C>xset</C>, in which the types of the external subsets of <C>xset</C>
##  and of the external orbits in <C>xset</C> are stored.
##  (This is used to avoid repeated calls of
##  <Ref Func="NewType"/> in functions like
##  <C>ExternalOrbits( xset )</C>,
##  which call <C>ExternalOrbit( xset, pnt )</C> for several values of
##  <C>pnt</C>.)
##  <P/>
##  For property testing functions such as
##  <Ref Oper="IsTransitive" Label="for a group, an action domain, etc."/>,
##  the fourth argument <A>AorP</A> must be
##  <Ref Func="NewProperty"/>,
##  otherwise it must be <Ref Func="NewAttribute"/>;
##  in the former case, a property is returned, in the latter case an
##  attribute that is not a property.
##  <P/>
##  For example, to set up the operation <Ref Oper="Orbits" Label="operation"/>,
##  the declaration file <F>lib/oprt.gd</F> contains the following line of
##  code:
##  <Log><![CDATA[
##  OrbitsishOperation( "Orbits", OrbitsishReq, false, NewAttribute );
##  ]]></Log>
##  The global variable <C>OrbitsishReq</C> contains the standard
##  requirements
##  <Log><![CDATA[
##  OrbitsishReq := [ IsGroup, IsList,
##                    IsList,
##                    IsList,
##                    IsFunction ];
##  ]]></Log>
##  which are usually entered in calls to <Ref Func="OrbitsishOperation"/>.
##  <P/>
##  The new operation, e.g., <Ref Oper="Orbits" Label="operation"/>,
##  can be called either as <C>Orbits( <A>xset</A> )</C> for an external set
##  <A>xset</A>, or as <C>Orbits( <A>G</A> )</C> for a permutation group
##  <A>G</A>, meaning the orbits on the moved
##  points of <A>G</A> via <Ref Func="OnPoints"/>,
##  or as
##  <P/>
##  <C>Orbits( <A>G</A>, <A>Omega</A>[, <A>gens</A>, <A>acts</A>][,
##  <A>act</A>] )</C>,
##  <P/>
##  with a group <A>G</A>, a domain or list <A>Omega</A>,
##  generators <A>gens</A> of <A>G</A>, and corresponding elements
##  <A>acts</A> that act on <A>Omega</A> via the function <A>act</A>;
##  the default of <A>gens</A> and <A>acts</A> is a list of group generators
##  of <A>G</A>,
##  the default of <A>act</A> is <Ref Func="OnPoints"/>.
##  <P/>
##  Only methods for the five-argument version need to be installed for
##  doing the real work.
##  (And of course methods for one argument in case one wants to define
##  a new meaning of the attribute.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "OrbitsishOperation", function( name, reqs, usetype, NewAorP )
    local op;

    # Create the attribute or property.
    op:= NewAorP( name, IsExternalSet );
    BIND_GLOBAL( name, op );
    BIND_SETTER_TESTER( name, SETTER_FILTER( op ), TESTER_FILTER( op ) );

    # Make a declaration for non-default methods.
    DeclareOperation( name, reqs );

    # Install the default methods.

    # 1. `op( <xset> )'
    # (The `usetype' value concerns only the `return' statement.)
    if usetype then

      InstallMethod( op,
          "for an external set",
          true,
          [ IsExternalSet ], 0,
          function( xset )
          local G, gens, acts, act;
          G := ActingDomain( xset );
          if IsExternalSetByActorsRep( xset )  then
            gens := xset!.generators;
            acts := xset!.operators;
            act  := xset!.funcOperation;
          else
            if CanEasilyComputePcgs( G ) then
              gens := Pcgs( G );
            else
              gens := GeneratorsOfGroup( G );
            fi;
            acts := gens;
            act  := FunctionAction( xset );
          fi;
          return op( G, xset, gens, acts, act );
          end );

    else

      InstallMethod( op,
          "for an external set",
          true,
          [ IsExternalSet ], 0,
          function( xset )
          local G, gens, acts, act;
          G := ActingDomain( xset );
          if IsExternalSetByActorsRep( xset )  then
            gens := xset!.generators;
            acts := xset!.operators;
            act  := xset!.funcOperation;
          else
            if CanEasilyComputePcgs( G ) then
              gens := Pcgs( G );
            else
              gens := GeneratorsOfGroup( G );
            fi;
            acts := gens;
            act  := FunctionAction( xset );
          fi;
          return op( G, Enumerator( xset ), gens, acts, act );
          end );

    fi;

    # 2. `op( <permgrp> )'
    InstallOtherMethod( op,
        "for a permutation group",
        true,
        [ IsPermGroup ], 0,
        function( G )
        local gens;
        gens:= GeneratorsOfGroup( G );
        return op( G, MovedPoints( G ), gens, gens, OnPoints );
        end );

    # 3. `op( <G>, <Omega> )' with group <G> and domain or list <Omega>
    #    (add group generators and `OnPoints' as default arguments)
    InstallOtherMethod( op,
        "for a group and a domain or list",
        true,
        [ IsGroup, IsObject ], 0,
        function( G, D )
        local gens;
        if CanEasilyComputePcgs( G ) then
          gens:= Pcgs( G );
        else
          gens:= GeneratorsOfGroup( G );
        fi;
        if IsDomain( D ) then
          if IsFinite( D ) then D:= AsSSortedList( D ); else D:= Enumerator( D ); fi;
        fi;
        return op( G, D, gens, gens, OnPoints );
        end );

    # 4. `op( <G>, <Omega> )' with permutation group <G> and domain or list
    # <Omega>
    #    of integers
    #    (if <Omega> equals the moved points of <G> then call `op( <G> )')
    InstallOtherMethod( op,
        "for a permutation group and a domain or list of integers",
        true,
        [ IsPermGroup, IsListOrCollection ], 0,
        function( G, D )
        if D = MovedPoints( G ) then
          return op( G );
        else
          TryNextMethod();
        fi;
        end );

    # 5. `op( <G>, <Omega>, <act> )' with group <G>, domain or list <Omega>,
    #    and function <act>
    #    (add group generators as default arguments)
    InstallOtherMethod( op,
        "for a group, a domain or list, and a function",
        true,
        [ IsGroup, IsObject, IsFunction ], 0,
        function( G, D, act )
        local gens;
        if CanEasilyComputePcgs( G ) then
          gens:= Pcgs( G );
        else
          gens:= GeneratorsOfGroup( G );
        fi;
        if IsDomain( D ) then
          if IsFinite( D ) then D:= AsSSortedList( D ); else D:= Enumerator( D ); fi;
        fi;
        return op( G, D, gens, gens, act );
        end );

    # 6. `op( <G>, <Omega>, <act> )' with permutation group <G>,
    #    domain or list <Omega> of integers, and function <act>
    #    (if <Omega> equals the moved points of <G> and <act> equals `OnPoints'
    #    then call `op( <G> )')
    InstallOtherMethod( op,
        "for permutation group, domain or list of integers, and function",
        true,
        [ IsPermGroup, IsListOrCollection, IsFunction ], 0,
        function( G, D, act )
        if D = MovedPoints( G ) and IsIdenticalObj( act, OnPoints ) then
          return op( G );
        else
          TryNextMethod();
        fi;
        end );

    # 7. `op( <G>, <Omega>, <gens>, <acts> )' with group <G>,
    #    domain or list <Omega>, and two lists <gens>, <acts>
    #    (add default value `OnPoints')
    InstallOtherMethod( op,
        "for a group, a domain or list, and two lists",
        true,
        [ IsGroup, IsObject, IsList, IsList ], 0,
        function( G, D, gens, acts )
        if IsDomain( D ) then
          if IsFinite( D ) then D:= AsSSortedList( D ); else D:= Enumerator( D ); fi;
        fi;
        return op( G, D, gens, acts, OnPoints );
        end );

    # 8. `op( <G>, <Omega>, <gens>, <acts>, <act> )' with group <G>,
    #    domain <Omega>, two lists <gens>, <acts>, and function <act>
    #    (delegate to a (non-default!) method with <Omega> a list)
    InstallOtherMethod( op,
        "for a group, a domain, two lists, and a function",
        true,
        [ IsGroup, IsDomain, IsList, IsList, IsFunction ], 0,
        function( G, D, gens, acts, act )
        return op( G, Enumerator( D ), gens, acts, act );
        end );
end );


#############################################################################
##
#F  OrbitishFO( <name>, <reqs>, <famrel>, <usetype>, <realenum> )
##
##  <#GAPDoc Label="OrbitishFO">
##  <ManSection>
##  <Func Name="OrbitishFO" Arg='name, reqs, famrel, usetype, realenum'/>
##
##  <Description>
##  is used to create operations like <Ref Oper="Orbit"/>.
##  This function is analogous to <Ref Func="OrbitsishOperation"/>,
##  but for operations <A>orbish</A> like
##  <C>Orbit( <A>G</A>, <A>Omega</A>, <A>pnt</A> )</C>.
##  Since the return values of these operations depend on the additional
##  argument <A>pnt</A>, there is no associated attribute.
##  <P/>
##  The call of <Ref Func="OrbitishFO"/> declares a wrapper function and its
##  operation, with names <A>name</A> and <A>name</A><C>Op</C>.
##  <P/>
##  The second argument <A>reqs</A> specifies the list of required filters
##  for the operation <A>name</A><C>Op</C>.
##  <P/>
##  The third argument <A>famrel</A> is used to test the family relation
##  between the second and third argument of
##  <C><A>name</A>( <A>G</A>, <A>D</A>, <A>pnt</A> )</C>.
##  For example, <A>famrel</A> is <C>IsCollsElms</C> in the case of
##  <Ref Oper="Orbit"/> because <A>pnt</A> must be an element
##  of <A>D</A>.
##  Similarly, in the call <C>Blocks( <A>G</A>, <A>D</A>, <A>seed</A> )</C>,
##  <A>seed</A> must be a subset of <A>D</A>,
##  and the family relation must be
##  <Ref Func="IsIdenticalObj"/>.
##  <P/>
##  The fourth argument <A>usetype</A> serves the same purpose as in the case
##  of <Ref Func="OrbitsishOperation"/>.
##  <A>usetype</A> can also be an attribute, such as
##  <C>BlocksAttr</C> or <C>MaximalBlocksAttr</C>.
##  In this case, if only one of the two arguments <A>Omega</A> and
##  <A>pnt</A> is given,
##  blocks with no seed are computed, they are stored as attribute values
##  according to the rules of <Ref Func="OrbitsishOperation"/>.
##  <P/>
##  If the 5th argument is set to <K>true</K>, the action for an external set
##  should use the enumerator, otherwise it uses the
##  <Ref Attr="HomeEnumerator"/> value. This will
##  make a difference for external orbits as part of a larger domain.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "OrbitishFO", function( name, reqs, famrel, usetype,realenum )
local str, orbish, func,isnotest;

    # Create the operation.
    str:= SHALLOW_COPY_OBJ( name );
    isnotest:=Length(name)>5 and name{[Length(name)-5..Length(name)]}="Blocks";
    isnotest:=isnotest or name="ExternalSubset";
    APPEND_LIST_INTR( str, "Op" );
    orbish := NewOperation( str, reqs );
    BIND_GLOBAL( str, orbish );

    # Create the wrapper function.
    func := function( arg )
    local   G,  D,  pnt,  gens,  acts,  act,  xset,  p,  attrG,  result,le;

      # Get the arguments.
      if Length( arg ) <= 2 and IsExternalSet( arg[ 1 ] )  then
          xset := arg[ 1 ];
          if Length(arg)>1 then
            # force immutability
            pnt := Immutable(arg[ 2 ]);
          else
              # `Blocks' like operations
              pnt:=[];
          fi;

          G := ActingDomain( xset );
          if realenum then
            D:=Enumerator(xset);
          else
            if HasHomeEnumerator( xset )  then
                D := HomeEnumerator( xset );
            fi;
          fi;
          if IsExternalSetByActorsRep( xset )  then
              gens := xset!.generators;
              acts := xset!.operators;
              act  := xset!.funcOperation;
          else
              act := FunctionAction( xset );
          fi;
      elif 2 <= Length( arg ) then
          le:=Length(arg);
          G := arg[ 1 ];
          if IsFunction( arg[ le ] )  then
              act := arg[ le ];
              le:=le-1;
          else
              act := OnPoints;
          fi;
          if     Length( arg ) > 2
            and famrel( FamilyObj( arg[ 2 ] ), FamilyObj( arg[ 3 ] ) )
            # for blocks on the groups elements
            and not (IsOperation(usetype) and le=4)
            then
              D := arg[ 2 ];
              if IsDomain( D )  then
           if IsFinite( D ) then D:= AsSSortedList( D ); else D:= Enumerator( D ); fi;
              fi;
              p := 3;
          else
              p := 2;
          fi;
          pnt := Immutable(arg[ p ]);
          if Length( arg ) > p + 1  then
              gens := arg[ p + 1 ];
              acts := arg[ p + 2 ];
          fi;
      else
        Error( "usage: ", name, "(<xset>,<pnt>)\n",
              "or ", name, "(<G>[,<Omega>],<pnt>[,<gens>,<acts>][,<act>])" );
      fi;

      if not IsBound( gens )  then
          if (not IsPermGroup(G)) and CanEasilyComputePcgs( G )  then
            gens := Pcgs( G );
          else
            gens := GeneratorsOfGroup( G );
          fi;
          acts := gens;
      fi;

      if not isnotest then
        # `Blocks' has <pnt> a list of points
        pnt:=TestIdentityAction(acts,pnt,act);
      fi;

      # In  the  case of `[Maximal]Blocks',  where  $G$  is a permutation group
      # acting on its moved points, use an attribute for $G$.
      attrG := IsOperation( usetype )
          and gens = acts
          and act = OnPoints
          and not IsBound( D )
          and HasMovedPoints( G )
          and pnt = MovedPoints( G );
      if attrG  and  IsBound( xset )  and  Tester( usetype )( xset )  then
          result := usetype( xset );
      elif attrG  and  Tester( usetype )( G )  then
          result := usetype( G );
      elif usetype = true  and  IsBound( xset )  then
          result := orbish( G, xset, pnt, gens, acts, act );
      elif IsBound( D )  then
          result := orbish( G, D, pnt, gens, acts, act );
      else

          # The following line is also executed  when `Blocks(<G>, <Omega>, <act>)'
          # is called to compute blocks with no  seed, but then <pnt> is really
          # <Omega>, i.e., the operation domain!
          result := orbish( G, pnt, gens, acts, act );

      fi;

      # Store the result in the case of an attribute `[Maximal]BlocksAttr'.
      if attrG  then
          if IsBound( xset )  then
              Setter( usetype )( xset, result );
          fi;
          Setter( usetype )( G, result );
      fi;

      return result;
  end;
  BIND_GLOBAL( name, func );
end );


#############################################################################
##
#O  ActionHomomorphism(<G>,<Omega> [,<gens>,<acts>] [,<act>] [,"surjective"])
#A  ActionHomomorphism( <xset> [,"surjective"] )
#A  ActionHomomorphism( <action> )
##
##  <#GAPDoc Label="ActionHomomorphism">
##  <ManSection>
##  <Heading>ActionHomomorphism</Heading>
##  <Func Name="ActionHomomorphism"
##   Arg='G, Omega[, gens, acts][, act][, "surjective"]'
##   Label="for a group, an action domain, etc."/>
##  <Func Name="ActionHomomorphism" Arg='xset[, "surjective"]'
##   Label="for an external set"/>
##  <Func Name="ActionHomomorphism" Arg='action'
##   Label="for an action image"/>
##
##  <Description>
##  computes a homomorphism from <A>G</A> into the symmetric group on
##  <M>|<A>Omega</A>|</M> points that gives the permutation action of
##  <A>G</A> on <A>Omega</A>. (In particular, this homomorphism is a
##  permutation equivalence, that is the permutation image of a group element
##  is given by the positions of points in <A>Omega</A>.)
##  <P/>
##  The result is undefined if <A>G</A> does not act on <A>Omega</A>.
##  <P/>
##  By default the homomorphism returned by
##  <Ref Func="ActionHomomorphism" Label="for a group, an action domain, etc."/>
##  is not necessarily surjective (its
##  <Ref Attr="Range" Label="of a general mapping"/> value is the full
##  symmetric group) to avoid unnecessary computation of the image.
##  If the optional string argument <C>"surjective"</C> is given,
##  a surjective homomorphism is created.
##  <P/>
##  The third version (which is supported only for &GAP;3 compatibility)
##  returns the action homomorphism that belongs to the image obtained via
##  <Ref Func="Action" Label="for a group, an action domain, etc."/>.
##  <P/>
##  (See Section&nbsp;<Ref Sect="Basic Actions"/>
##  for information about specific actions.)
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3),(1,2));;
##  gap> hom:=ActionHomomorphism(g,Arrangements([1..4],3),OnTuples);
##  <action homomorphism>
##  gap> Image(hom);
##  Group(
##  [ (1,9,13)(2,10,14)(3,7,15)(4,8,16)(5,12,17)(6,11,18)(19,22,23)(20,21,
##      24), (1,7)(2,8)(3,9)(4,10)(5,11)(6,12)(13,15)(14,16)(17,18)(19,
##      21)(20,22)(23,24) ])
##  gap> Size(Range(hom));Size(Image(hom));
##  620448401733239439360000
##  6
##  gap> hom:=ActionHomomorphism(g,Arrangements([1..4],3),OnTuples,
##  > "surjective");;
##  gap> Size(Range(hom));
##  6
##  ]]></Example>
##  <P/>
##  When acting on a domain, the operation <Ref Oper="PositionCanonical"/>
##  is used to determine the position of elements in the domain.
##  This can be used to act on a domain given by a list of representatives
##  for which <Ref Oper="PositionCanonical"/> is implemented,
##  for example the return value of <Ref Oper="RightTransversal"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ActionHomomorphism" );
DeclareAttribute( "ActionHomomorphismAttr", IsExternalSet );
DeclareGlobalFunction( "ActionHomomorphismConstructor" );


#############################################################################
##
#A  SurjectiveActionHomomorphismAttr( <xset> )
##
##  <#GAPDoc Label="SurjectiveActionHomomorphismAttr">
##  <ManSection>
##  <Attr Name="SurjectiveActionHomomorphismAttr" Arg='xset'/>
##
##  <Description>
##  returns an action homomorphism for the external set <A>xset</A>
##  which is surjective.
##  (As the <Ref Func="Image" Label="set of images of the source of a general mapping"/>
##  value of this homomorphism has to be computed
##  to obtain the range, this may take substantially longer
##  than <Ref Func="ActionHomomorphism" Label="for an external set"/>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SurjectiveActionHomomorphismAttr", IsExternalSet );

#############################################################################
##
#A  UnderlyingExternalSet( <acthom> )
##
##  <#GAPDoc Label="UnderlyingExternalSet">
##  <ManSection>
##  <Attr Name="UnderlyingExternalSet" Arg='acthom'/>
##
##  <Description>
##  The underlying set of an action homomorphism <A>acthom</A> is
##  the external set on which it was defined.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3),(1,2));;
##  gap> hom:=ActionHomomorphism(g,Arrangements([1..4],3),OnTuples);;
##  gap> s:=UnderlyingExternalSet(hom);
##  <xset:[[ 1, 2, 3 ],[ 1, 2, 4 ],[ 1, 3, 2 ],[ 1, 3, 4 ],[ 1, 4, 2 ],
##  [ 1, 4, 3 ],[ 2, 1, 3 ],[ 2, 1, 4 ],[ 2, 3, 1 ],[ 2, 3, 4 ],
##  [ 2, 4, 1 ],[ 2, 4, 3 ],[ 3, 1, 2 ],[ 3, 1, 4 ],[ 3, 2, 1 ], ...]>
##  gap> Print(s,"\n");
##  [ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 2 ], [ 1, 3, 4 ], [ 1, 4, 2 ],
##    [ 1, 4, 3 ], [ 2, 1, 3 ], [ 2, 1, 4 ], [ 2, 3, 1 ], [ 2, 3, 4 ],
##    [ 2, 4, 1 ], [ 2, 4, 3 ], [ 3, 1, 2 ], [ 3, 1, 4 ], [ 3, 2, 1 ],
##    [ 3, 2, 4 ], [ 3, 4, 1 ], [ 3, 4, 2 ], [ 4, 1, 2 ], [ 4, 1, 3 ],
##    [ 4, 2, 1 ], [ 4, 2, 3 ], [ 4, 3, 1 ], [ 4, 3, 2 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "UnderlyingExternalSet", IsActionHomomorphism );

#############################################################################
##
#F  DoSparseActionHomomorphism(<G>,<start>,<gens>,<acts>,<act>,<phash>,<sort>)
##
##  <ManSection>
##  <Func Name="DoSparseActionHomomorphism"
##   Arg='G, start, gens, acts, act, phash, sort'/>
##
##  <Description>
##  is the function implementing the sparse action homomorphisms and syntax
##  is as for these.
##  <A>phash</A> must be an injective (&GAP;)-function, for
##  example a perfect hash, element comparisons are done in its range.
##  Unless a fast enumeration is known, <C>IdFunc</C> should be used.
##  If <A>sort</A> is true, the action domain for the resulting homomorphism
##  will be sorted.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("DoSparseActionHomomorphism");

DeclareGlobalFunction("MultiActionsHomomorphism");

#############################################################################
##
#O  SparseActionHomomorphism( <G>, <start> [,<gens>,<acts>] [,<act>] )
#O  SortedSparseActionHomomorphism(<G>,<start>[,<gens>,<acts>] [,<act>])
##
##  <#GAPDoc Label="SparseActionHomomorphism">
##  <ManSection>
##  <Oper Name="SparseActionHomomorphism"
##   Arg='G, start[, gens, acts][, act]'/>
##  <Oper Name="SortedSparseActionHomomorphism"
##   Arg='G, start[, gens, acts][, act]'/>
##
##  <Description>
##  <Ref Oper="SparseActionHomomorphism"/> computes the action homomorphism
##  (see <Ref Func="ActionHomomorphism" Label="for a group, an action domain, etc."/>)
##  with arguments <A>G</A>, <M>D</M>, and the optional arguments given,
##  where <M>D</M> is the union of the <A>G</A>-orbits of all points in
##  <A>start</A>.
##  In the <Ref Oper="Orbit"/> calls that are used to create <M>D</M>,
##  again the optional arguments given are entered.)
##  <P/>
##  If <A>G</A> acts on a very large domain not surjectively
##  this may yield a permutation image of
##  substantially smaller degree than by action on the whole domain.
##  <P/>
##  The operation <Ref Oper="SparseActionHomomorphism"/> will only use
##  <Ref Oper="\="/> comparisons of points in the orbit.
##  Therefore it can be used even if no good <Ref Oper="\&lt;"/>
##  comparison method for these points is available.
##  However the image group will depend on the
##  generators <A>gens</A> of <A>G</A>.
##  <P/>
##  The operation <Ref Oper="SortedSparseActionHomomorphism"/> in contrast
##  will sort the orbit and thus produce an image group which does not
##  depend on these generators.
##  <P/>
##  <Example><![CDATA[
##  gap> h:=Group(Z(3)*[[[1,1],[0,1]]]);
##  Group([ [ [ Z(3), Z(3) ], [ 0*Z(3), Z(3) ] ] ])
##  gap> hom:=ActionHomomorphism(h,GF(3)^2,OnRight);;
##  gap> Image(hom);
##  Group([ (2,3)(4,9,6,7,5,8) ])
##  gap> hom:=SparseActionHomomorphism(h,[Z(3)*[1,0]],OnRight);;
##  gap> Image(hom);
##  Group([ (1,2,3,4,5,6) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

BindGlobal( "SparseActHomFO", function( name, reqs, famrel )
local str, orbish, func;

    # Create the operation.
    str:= SHALLOW_COPY_OBJ( name );

    APPEND_LIST_INTR( str, "Op" );
    orbish := NewOperation( str, reqs );
    BIND_GLOBAL( str, orbish );

    # Create the wrapper function.
    func := function( arg )
    local   G,  D,  pnt,  gens,  acts,  act,   p,  result,le;

      # Get the arguments.
      if 2 <= Length( arg ) then
          le:=Length(arg);
          G := arg[ 1 ];
          if IsFunction( arg[ le ] )  then
              act := arg[ le ];
          else
              act := OnPoints;
          fi;
          if     Length( arg ) > 2
            and famrel( FamilyObj( arg[ 2 ] ), FamilyObj( arg[ 3 ] ) )
            then
              D := arg[ 2 ];
              if IsDomain( D )  then
           if IsFinite( D ) then D:= AsSSortedList( D ); else D:= Enumerator( D ); fi;
              fi;
              p := 3;
          else
              p := 2;
          fi;
          pnt := Immutable(arg[ p ]);
          if Length( arg ) > p + 1  then
              gens := arg[ p + 1 ];
              acts := arg[ p + 2 ];
          fi;
      else
        Error( "usage: ", name, "(<G>[,<Omega>],<pnts>[,<gens>,<acts>][,<act>])" );
      fi;

      if not IsBound( gens )  then
          if (not IsPermGroup(G)) and CanEasilyComputePcgs( G )  then
            gens := Pcgs( G );
          else
            gens := GeneratorsOfGroup( G );
          fi;
          acts := gens;
      fi;

      for p in pnt do
        TestIdentityAction(acts,p,act);
      od;

      if IsBound( D )  then
          result := orbish( G, D, pnt, gens, acts, act );
      else
          result := orbish( G, pnt, gens, acts, act );
      fi;

      return result;
  end;
  BIND_GLOBAL( name, func );
end );

SparseActHomFO( "SparseActionHomomorphism", OrbitishReq, IsIdenticalObj );
SparseActHomFO( "SortedSparseActionHomomorphism", OrbitishReq, IsIdenticalObj );

#############################################################################
##
#O  ImageElmActionHomomorphism( <op>,<elm> )
##
##  <ManSection>
##  <Oper Name="ImageElmActionHomomorphism" Arg='op,elm'/>
##
##  <Description>
##  computes the image of <A>elm</A> under the action homomorphism <A>op</A> and is
##  guaranteed to use the action (and not the <C>AsGHBI</C>, this is required
##  in some methods to bootstrap the range).
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ImageElmActionHomomorphism" );

#############################################################################
##
#O  Action( <G>, <Omega> [<gens>,<acts>] [,<act>] )
#A  Action( <xset> )
##
##  <#GAPDoc Label="Action">
##  <ManSection>
##  <Func Name="Action" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Func Name="Action" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  returns the image group of
##  <Ref Func="ActionHomomorphism" Label="for a group, an action domain, etc."/>
##  called with the same parameters.
##  <P/>
##  Note that (for compatibility reasons to be able to get the
##  action homomorphism) this image group internally stores the action
##  homomorphism.
##  If <A>G</A> or <A>Omega</A> are extremely big, this can cause memory
##  problems. In this case compute only generator images and form the image
##  group yourself.
##  <P/>
##  (See Section&nbsp;<Ref Sect="Basic Actions"/>
##  for information about specific actions.)
##  <P/>
##  <Index>regular action</Index>
##  The following code shows for example how to create the regular action of a
##  group.
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3),(1,2));;
##  gap> Action(g,AsList(g),OnRight);
##  Group([ (1,5,3)(2,6,4), (1,6)(2,5)(3,4) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Action" );


#############################################################################
##
#O  ExternalSet( <G>, <Omega>[, <gens>, <acts>][, <act>] )
##
##  <#GAPDoc Label="ExternalSet">
##  <ManSection>
##  <Oper Name="ExternalSet" Arg='G, Omega[, gens, acts][, act]'/>
##
##  <Description>
##  creates the external set for the action <A>act</A> of <A>G</A> on <A>Omega</A>.
##  <A>Omega</A> can be either a proper set, or a domain which is represented as
##  described in <Ref Sect="Domains"/> and <Ref Chap="Collections"/>, or (to use
##  less memory but with a slower performance) an enumerator
##  (see <Ref Attr="Enumerator"/> ) of this domain.
##  <P/>
##  The result is undefined if <A>G</A> does not act on <A>Omega</A>.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3),(2,3,4));;
##  gap> e:=ExternalSet(g,[1..4]);
##  <xset:[ 1, 2, 3, 4 ]>
##  gap> e:=ExternalSet(g,g,OnRight);
##  <xset:[ (), (2,3,4), (2,4,3), (1,2)(3,4), (1,2,3), (1,2,4), (1,3,2),
##    (1,3,4), (1,3)(2,4), (1,4,2), (1,4,3), (1,4)(2,3) ]>
##  gap> Orbits(e);
##  [ [ (), (1,2)(3,4), (1,3)(2,4), (1,4)(2,3), (2,4,3), (1,4,2),
##        (1,2,3), (1,3,4), (2,3,4), (1,3,2), (1,4,3), (1,2,4) ] ]
##  ]]></Example>
##
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "ExternalSet", OrbitsishReq, false, NewAttribute );

DeclareGlobalFunction( "ExternalSetByFilterConstructor" );
DeclareGlobalFunction( "ExternalSetByTypeConstructor" );

#############################################################################
##
#O  RestrictedExternalSet( <xset>, <U> )
##
##  <ManSection>
##  <Oper Name="RestrictedExternalSet" Arg='xset, U'/>
##
##  <Description>
##  If <A>U</A> is a subgroup of the <C>ActingDomain</C> of <A>xset</A> this operation
##  returns an external set for the same action which has the
##  <C>ActingDomain</C> <A>U</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation("RestrictedExternalSet",[IsExternalSet,IsGroup]);

#############################################################################
##
#O  ExternalSubset(<G>,<Omega>,<start>,[<gens>,<acts>,]<act>)
##
##  <#GAPDoc Label="ExternalSubset">
##  <ManSection>
##  <Oper Name="ExternalSubset" Arg='G,Omega,start,[gens,acts,]act'/>
##
##  <Description>
##  constructs the external subset of <A>Omega</A> on the union of orbits of
##  the points in <A>start</A>.
##  <P/>
##  The result is undefined if <A>G</A> does not act on <A>Omega</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitishFO( "ExternalSubset",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, true, false );


#############################################################################
##
#O  ExternalOrbit( <G>, <Omega>, <pnt>, [<gens>,<acts>,] <act> )
##
##  <#GAPDoc Label="ExternalOrbit">
##  <ManSection>
##  <Oper Name="ExternalOrbit" Arg='G, Omega, pnt, [gens,acts,] act'/>
##
##  <Description>
##  constructs the external subset on the orbit of <A>pnt</A>. The
##  <Ref Attr="Representative"/> value of this external set is <A>pnt</A>.
##  <P/>
##  The result is undefined if <A>G</A> does not act on <A>Omega</A>.
##  <Example><![CDATA[
##  gap> e:=ExternalOrbit(g,g,(1,2,3));
##  (1,2,3)^G
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitishFO( "ExternalOrbit", OrbitishReq, IsCollsElms, true, false );


#############################################################################
##
#O  Orbit( <G>[, <Omega>], <pnt>[, <gens>, <acts>][, <act>] )
##
##  <#GAPDoc Label="Orbit">
##  <ManSection>
##  <Oper Name="Orbit" Arg='G[, Omega], pnt[, gens, acts][, act]'/>
##
##  <Description>
##  The orbit of the point <A>pnt</A> is the list of all images of <A>pnt</A>
##  under the action of the group <A>G</A> w.r.t. the action function
##  <A>act</A> or <Ref Func="OnPoints"/> if no action function is given.
##  <P/>
##  (Note that the arrangement of points in this list is not defined by the
##  operation.)
##  <P/>
##  The orbit of <A>pnt</A> will always contain one element that is
##  <E>equal</E> to <A>pnt</A>, however for performance reasons
##  this element is not necessarily <E>identical</E> to <A>pnt</A>,
##  in particular if <A>pnt</A> is mutable.
##  <Example><![CDATA[
##  gap> g:=Group((1,3,2),(2,4,3));;
##  gap> Orbit(g,1);
##  [ 1, 3, 2, 4 ]
##  gap> Orbit(g,[1,2],OnSets);
##  [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 3, 4 ], [ 2, 4 ] ]
##  ]]></Example>
##  <P/>
##  (See Section&nbsp;<Ref Sect="Basic Actions"/>
##  for information about specific actions.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitishFO( "Orbit", OrbitishReq, IsCollsElms, false, false );


#############################################################################
##
#O  Orbits( <G>, <seeds>[, <gens>, <acts>][, <act>] )
#A  Orbits( <G> )
#A  Orbits( <xset> )
##
##  <#GAPDoc Label="Orbits">
##  <ManSection>
##  <Oper Name="Orbits" Arg='G, seeds[, gens, acts][, act]' Label="operation"/>
##  <Attr Name="Orbits" Arg='G'
##   Label="for a permutation group"/>
##  <Attr Name="Orbits" Arg='xset' Label="attribute"/>
##
##  <Description>
##  returns a duplicate-free list of the orbits of the elements in
##  <A>seeds</A> under the action <A>act</A> of <A>G</A> or under
##  <Ref Func="OnPoints"/> if no action function is given.
##  <P/>
##  For a permutation group <A>G</A>, one may also invoke this as
##  <C>Orbits(<A>G</A>)</C>, which returns all the orbits of its natural
##  action on the set of points moved by it.
##  For example the group <M>\langle (1,2,3), (4,5) \rangle</M>
##  has the orbits <M>\{1,2,3\}</M> and <M>\{4,5\}</M>.
##  <P/>
##  (Note that the arrangement of orbits or of points within one orbit is
##  not defined by the operation.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "Orbits", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  OrbitsDomain( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  OrbitsDomain( <G> )
#A  OrbitsDomain( <xset> )
##
##  <#GAPDoc Label="OrbitsDomain">
##  <ManSection>
##  <Heading>OrbitsDomain</Heading>
##  <Oper Name="OrbitsDomain" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group and an action domain"/>
##  <Attr Name="OrbitsDomain" Arg='G'
##   Label="for a permutation group"/>
##  <Attr Name="OrbitsDomain" Arg='xset'
##   Label="of an external set"/>
##
##  <Description>
##  returns a list of the orbits of <A>G</A> on the domain <A>Omega</A>
##  (given as lists) under the action <A>act</A> or under
##  <Ref Func="OnPoints"/> if no action function is given.
##  <P/>
##  This operation is often faster than
##  <Ref Oper="Orbits" Label="operation"/>.
##  The domain <A>Omega</A> must be closed under the action of <A>G</A>,
##  otherwise an error can occur.
##  <P/>
##  For a permutation group <A>G</A>, one may also invoke this as
##  <C>OrbitsDomain(<A>G</A>)</C>, which returns all the orbits of its natural
##  action on the set of points moved by it.
##  <P/>
##  (Note that the arrangement of orbits or of points within one orbit is
##  not defined by the operation.)
##  <Example><![CDATA[
##  gap> g:=Group((1,3,2),(2,4,3));;
##  gap> Orbits(g,[1..5]);
##  [ [ 1, 3, 2, 4 ], [ 5 ] ]
##  gap> OrbitsDomain(g,Arrangements([1..4],3),OnTuples);
##  [ [ [ 1, 2, 3 ], [ 3, 1, 2 ], [ 1, 4, 2 ], [ 2, 3, 1 ], [ 2, 1, 4 ],
##        [ 3, 4, 1 ], [ 1, 3, 4 ], [ 4, 2, 1 ], [ 4, 1, 3 ],
##        [ 2, 4, 3 ], [ 3, 2, 4 ], [ 4, 3, 2 ] ],
##    [ [ 1, 2, 4 ], [ 3, 1, 4 ], [ 1, 4, 3 ], [ 2, 3, 4 ], [ 2, 1, 3 ],
##        [ 3, 4, 2 ], [ 1, 3, 2 ], [ 4, 2, 3 ], [ 4, 1, 2 ],
##        [ 2, 4, 1 ], [ 3, 2, 1 ], [ 4, 3, 1 ] ] ]
##  gap> OrbitsDomain(g,GF(2)^2,[(1,2,3),(1,4)(2,3)],
##  > [[[Z(2)^0,Z(2)^0],[Z(2)^0,0*Z(2)]],[[Z(2)^0,0*Z(2)],[0*Z(2),Z(2)^0]]]);
##  [ [ <an immutable GF2 vector of length 2> ],
##    [ <an immutable GF2 vector of length 2>,
##        <an immutable GF2 vector of length 2>,
##        <an immutable GF2 vector of length 2> ] ]
##  ]]></Example>
##  <P/>
##  (See Section&nbsp;<Ref Sect="Basic Actions"/>
##  for information about specific actions.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "OrbitsDomain", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  OrbitLength( <G>[, <Omega>], <pnt> [, <gens>, <acts>][, <act>] )
##
##  <#GAPDoc Label="OrbitLength">
##  <ManSection>
##  <Oper Name="OrbitLength" Arg='G[, Omega], pnt[, gens, acts][, act]'/>
##
##  <Description>
##  computes the length of the orbit of <A>pnt</A> under
##  the action function <A>act</A> or <Ref Func="OnPoints"/>
##  if no action function is given.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitishFO( "OrbitLength", OrbitishReq, IsCollsElms, false, false );


#############################################################################
##
#O  OrbitLengths( <G>, <seeds>[, <gens>, <acts>][, <act>] )
#A  OrbitLengths( <G> )
#A  OrbitLengths( <xset> )
##
##  <#GAPDoc Label="OrbitLengths">
##  <ManSection>
##  <Heading>OrbitLengths</Heading>
##  <Oper Name="OrbitLengths" Arg='G, seeds[, gens, acts][, act]'
##   Label="for a group, a set of seeds, etc."/>
##  <Attr Name="OrbitLengths" Arg='G' Label="for a permutation group"/>
##  <Attr Name="OrbitLengths" Arg='xset' Label="for an external set"/>
##
##  <Description>
##  computes the lengths of all the orbits of the elements in <A>seeds</A>
##  under the action <A>act</A> of <A>G</A>.
##  <P/>
##  For a permutation group <A>G</A>, one may also invoke this as
##  <C>OrbitLengths(<A>G</A>)</C>, which returns the lengths of all the
##  orbits of its natural action on the set of points moved by it.
##  For example the group <M>\langle (1,2,3), (5,6) \rangle</M>
##  has the orbit lengths 2 and 3.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "OrbitLengths", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  OrbitLengthsDomain( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  OrbitLengthsDomain( <G> )
#A  OrbitLengthsDomain( <xset> )
##
##  <#GAPDoc Label="OrbitLengthsDomain">
##  <ManSection>
##  <Heading>OrbitLengthsDomain</Heading>
##  <Oper Name="OrbitLengthsDomain" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group and a set of seeds"/>
##  <Attr Name="OrbitLengthsDomain" Arg='G'
##   Label="for a permutation group"/>
##  <Attr Name="OrbitLengthsDomain" Arg='xset' Label="of an external set"/>
##
##  <Description>
##  computes the lengths of all the orbits of <A>G</A> on <A>Omega</A>.
##  <P/>
##  This operation is often faster than
##  <Ref Oper="OrbitLengths" Label="for a group, a set of seeds, etc."/>.
##  The domain <A>Omega</A> must be closed under the action of <A>G</A>,
##  otherwise an error can occur.
##  <P/>
##  For a permutation group <A>G</A>, one may also invoke this as
##  <C>OrbitLengthsDomain(<A>G</A>)</C>, which returns the length of all
##  the orbits of its natural action on the set of points moved by it.
##  <Example><![CDATA[
##  gap> g:=Group((1,3,2),(2,4,3));;
##  gap> OrbitLength(g,[1,2,3,4],OnTuples);
##  12
##  gap> OrbitLengths(g,Arrangements([1..4],4),OnTuples);
##  [ 12, 12 ]
##  gap> g:=Group((1,2,3),(5,6,7));;
##  gap> OrbitLengthsDomain(g,[1,2,3]);
##  [ 3 ]
##  gap> OrbitLengthsDomain(g);
##  [ 3, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "OrbitLengthsDomain", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  OrbitStabilizer( <G>[, <Omega>], <pnt>[, <gens>,<acts>][, <act>] )
##
##  <#GAPDoc Label="OrbitStabilizer">
##  <ManSection>
##  <Oper Name="OrbitStabilizer" Arg='G[, Omega], pnt[, gens, acts][, act]'/>
##
##  <Description>
##  computes the orbit and the stabilizer of <A>pnt</A> simultaneously in a
##  single orbit-stabilizer algorithm.
##  <P/>
##  The stabilizer will have <A>G</A> as its parent.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitishFO( "OrbitStabilizer", OrbitishReq, IsCollsElms, false,false );


#############################################################################
##
#O  ExternalOrbits( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  ExternalOrbits( <xset> )
##
##  <#GAPDoc Label="ExternalOrbits">
##  <ManSection>
##  <Heading>ExternalOrbits</Heading>
##  <Oper Name="ExternalOrbits" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Attr Name="ExternalOrbits" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  computes a list of external orbits that give the orbits of <A>G</A>.
##  <Example><![CDATA[
##  gap> ExternalOrbits(g,AsList(g));
##  [ ()^G, (2,3,4)^G, (2,4,3)^G, (1,2)(3,4)^G ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "ExternalOrbits", OrbitsishReq, true, NewAttribute );


#############################################################################
##
#O  ExternalOrbitsStabilizers( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  ExternalOrbitsStabilizers( <xset> )
##
##  <#GAPDoc Label="ExternalOrbitsStabilizers">
##  <ManSection>
##  <Heading>ExternalOrbitsStabilizers</Heading>
##  <Oper Name="ExternalOrbitsStabilizers"
##   Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Attr Name="ExternalOrbitsStabilizers" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  In addition to
##  <Ref Oper="ExternalOrbits" Label="for a group, an action domain, etc."/>,
##  this operation also computes the stabilizers of the representatives of
##  the external orbits at the same time.
##  (This can be quicker than computing the
##  <Ref Oper="ExternalOrbits" Label="for a group, an action domain, etc."/>
##  value first and the stabilizers afterwards.)
##  <Example><![CDATA[
##  gap> e:=ExternalOrbitsStabilizers(g,AsList(g));
##  [ ()^G, (2,3,4)^G, (2,4,3)^G, (1,2)(3,4)^G ]
##  gap> HasStabilizerOfExternalSet(e[3]);
##  true
##  gap> StabilizerOfExternalSet(e[3]);
##  Group([ (2,4,3) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "ExternalOrbitsStabilizers", OrbitsishReq,
    true, NewAttribute );


#############################################################################
##
#O  Transitivity( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  Transitivity( <G> )
#A  Transitivity( <xset> )
##
##  <#GAPDoc Label="Transitivity:oprt">
##  <ManSection>
##  <Heading>Transitivity</Heading>
##  <Oper Name="Transitivity" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group and an action domain"/>
##  <Attr Name="Transitivity" Arg='G'
##   Label="for a permutation group"/>
##  <Attr Name="Transitivity" Arg='xset' Label="for an external set"/>
##
##  <Description>
##  returns the degree <M>k</M> (a non-negative integer) of transitivity of
##  the action implied by the arguments,
##  i.e. the largest integer <M>k</M> such that the action is
##  <M>k</M>-transitive.
##  If the action is not transitive <C>0</C> is returned.
##  <P/>
##  An action is <E><M>k</M>-transitive</E> if every <M>k</M>-tuple of points
##  can be mapped simultaneously to every other <M>k</M>-tuple.
##  <P/>
##  For a permutation group <A>G</A>, one may also invoke this as
##  <C>Transitivity(<A>G</A>)</C>, which returns the degree of transitivity
##  of the group with respect to its natural action on the set of points
##  moved by it.
##  For example the group <M>\langle (2,3,4),(2,3) \rangle</M>
##  is 3-transitive on the set <M>\{2, 3, 4\}</M>.
##  <Example><![CDATA[
##  gap> g:=Group((1,3,2),(2,4,3));;
##  gap> IsTransitive(g,[1..5]);
##  false
##  gap> Transitivity(g,[1..4]);
##  2
##  gap> Transitivity(g);
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "Transitivity", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  Blocks( <G>, <Omega>[, <seed>][, <gens>, <acts>][, <act>] )
#A  Blocks( <xset>[, <seed>] )
##
##  <#GAPDoc Label="Blocks">
##  <ManSection>
##  <Heading>Blocks</Heading>
##  <Oper Name="Blocks" Arg='G, Omega[, seed][, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Attr Name="Blocks" Arg='xset[, seed]'
##   Label="for an external set"/>
##
##  <Description>
##  computes a block system for the transitive (see
##  <Ref Oper="IsTransitive" Label="for a group, an action domain, etc."/>)
##  action of <A>G</A> on <A>Omega</A>.
##  If <A>seed</A> is not given and the action is imprimitive,
##  a minimal nontrivial block system will be found.
##  If <A>seed</A> is given, a block system in which <A>seed</A>
##  is the subset of one block is computed.
##  <P/>
##  The result is undefined if the action is not transitive.
##  <Example><![CDATA[
##  gap> g:=TransitiveGroup(8,3);
##  E(8)=2[x]2[x]2
##  gap> Blocks(g,[1..8]);
##  [ [ 1, 8 ], [ 2, 3 ], [ 4, 5 ], [ 6, 7 ] ]
##  gap> Blocks(g,[1..8],[1,4]);
##  [ [ 1, 4 ], [ 2, 7 ], [ 3, 6 ], [ 5, 8 ] ]
##  ]]></Example>
##  <P/>
##  (See Section&nbsp;<Ref Sect="Basic Actions"/>
##  for information about specific actions.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BlocksAttr", IsExternalSet );

OrbitishFO( "Blocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, BlocksAttr, true );


#############################################################################
##
#O  MaximalBlocks( <G>, <Omega>[, <seed>][, <gens>, <acts>][, <act>] )
#A  MaximalBlocks( <xset>[, <seed>] )
##
##  <#GAPDoc Label="MaximalBlocks">
##  <ManSection>
##  <Heading>MaximalBlocks</Heading>
##  <Oper Name="MaximalBlocks" Arg='G, Omega[, seed][, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Attr Name="MaximalBlocks" Arg='xset[, seed]'
##   Label="for an external set"/>
##
##  <Description>
##  returns a block system that is maximal (i.e., blocks are maximal with
##  respect to inclusion) for the transitive (see
##  <Ref Oper="IsTransitive" Label="for a group, an action domain, etc."/>)
##  action of <A>G</A> on <A>Omega</A>.
##  If <A>seed</A> is given, a block system is computed in which <A>seed</A>
##  is a subset of one block.
##  <P/>
##  The result is undefined if the action is not transitive.
##  <Example><![CDATA[
##  gap> MaximalBlocks(g,[1..8]);
##  [ [ 1, 2, 3, 8 ], [ 4 .. 7 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MaximalBlocksAttr", IsExternalSet );

OrbitishFO( "MaximalBlocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, MaximalBlocksAttr,true );

#T  the following syntax would be nice for consistency as well:
##  RepresentativesMinimalBlocks(<G>,<Omega>[,<seed>][,<gens>,<acts>][,<act>])
##  RepresentativesMinimalBlocks( <xset>, <seed> )

#############################################################################
##
#O  RepresentativesMinimalBlocks(<G>,<Omega>[,<gens>,<acts>][,<act>])
#A  RepresentativesMinimalBlocks( <xset> )
##
##  <#GAPDoc Label="RepresentativesMinimalBlocks">
##  <ManSection>
##  <Heading>RepresentativesMinimalBlocks</Heading>
##  <Oper Name="RepresentativesMinimalBlocks"
##   Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Attr Name="RepresentativesMinimalBlocks" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  computes a list of block representatives for all minimal (i.e blocks are
##  minimal with respect to inclusion) nontrivial block systems for the
##  transitive (see
##  <Ref Oper="IsTransitive" Label="for a group, an action domain, etc."/>)
##  action of <A>G</A> on <A>Omega</A>.
##  <P/>
##  The result is undefined if the action is not transitive.
##  <Example><![CDATA[
##  gap> RepresentativesMinimalBlocks(g,[1..8]);
##  [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ], [ 1, 6 ], [ 1, 7 ],
##    [ 1, 8 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RepresentativesMinimalBlocksAttr", IsExternalSet );

OrbitishFO( "RepresentativesMinimalBlocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, RepresentativesMinimalBlocksAttr,true );


#############################################################################
##
#O  Earns( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  Earns( <xset> )
##
##  <#GAPDoc Label="Earns">
##  <ManSection>
##  <Heading>Earns</Heading>
##  <Oper Name="Earns" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Attr Name="Earns" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  returns a list of the elementary abelian regular
##  (when acting on <A>Omega</A>) normal subgroups of <A>G</A>.
##  <P/>
##  At the moment only methods for a primitive group <A>G</A> are implemented.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "Earns", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  IsTransitive( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsTransitive( <permgroup> )
#P  IsTransitive( <xset> )
##
##  <#GAPDoc Label="IsTransitive:oprt">
##  <ManSection>
##  <Heading>IsTransitive</Heading>
##  <Oper Name="IsTransitive" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Prop Name="IsTransitive" Arg='G'
##   Label="for a permutation group"/>
##  <Prop Name="IsTransitive" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  returns <K>true</K> if the action implied by the arguments is transitive,
##  or <K>false</K> otherwise.
##  <P/>
##  <Index>transitive</Index>
##  We say that a  group <A>G</A> acts <E>transitively</E> on a domain
##  <M>D</M> if and only if <A>G</A> acts on <M>D</M> and for every pair of
##  points <M>d, e \in D</M>
##  there is an element <M>g</M> in <A>G</A> such that <M>d^g = e</M>.
##  <P/>
##  For a permutation group <A>G</A>, one may also invoke this as
##  <C>IsTransitive(<A>G</A>)</C>, which tests whether the group is
##  transitive with respect to its natural action on the set of points
##  moved by it.
##  For example the group <M>\langle (2,3,4),(2,3) \rangle</M>
##  is transitive on the set <M>\{2, 3, 4\}</M>.
##  <Example><![CDATA[
##  gap> G:= Group( (2,3,4), (2,3) );;
##  gap> IsTransitive( G, [ 2 .. 4 ] );
##  true
##  gap> IsTransitive( G, [ 2, 3 ] );   # G does not act on [ 2, 3 ]
##  false
##  gap> IsTransitive( G, [ 1 .. 4 ] );  # G has two orbits on [ 1 .. 4 ]
##  false
##  gap> IsTransitive( G );  # G is transitive on [ 2 .. 4 ]
##  true
##  gap> IsTransitive( SL(2, 3), NormedRowVectors( GF(3)^2 ) );
##  false
##  gap> IsTransitive( SL(2, 3), NormedRowVectors( GF(3)^2 ), OnLines );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "IsTransitive", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  IsPrimitive( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsPrimitive( <G> )
#P  IsPrimitive( <xset> )
##
##  <#GAPDoc Label="IsPrimitive">
##  <ManSection>
##  <Heading>IsPrimitive</Heading>
##  <Oper Name="IsPrimitive" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Prop Name="IsPrimitive" Arg='G'
##   Label="for a permutation group"/>
##  <Prop Name="IsPrimitive" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  returns <K>true</K> if the action implied by the arguments is primitive,
##  or <K>false</K> otherwise.
##  <P/>
##  <Index>primitive</Index>
##  An action is <E>primitive</E> if it is transitive (see
##  <Ref Oper="IsTransitive" Label="for a group, an action domain, etc."/>)
##  and the action admits
##  no nontrivial block systems. See&nbsp;<Ref Sect="Block Systems"/> for
##  the definition of block systems.
##  <P/>
##  For a permutation group <A>G</A>, one may also invoke this as
##  <C>IsPrimitive(<A>G</A>)</C>, which tests whether the group is
##  primitive with respect to its natural action on the set of points
##  moved by it.
##  For example the group <M>\langle (2,3,4),(2,3) \rangle</M>
##  is primitive on the set <M>\{2, 3, 4\}</M>.
##  <P/>
##  For an explanation of the meaning of all the inputs, please refer to
##  &nbsp;<Ref Sect="About Group Actions"/>.
##  <P/>
##  <E>Note:</E> This operation does not tell whether a matrix group is
##  primitive in the sense of preserving a direct sum of vector spaces.
##  To do this use <C>IsPrimitiveMatrixGroup</C> or
##  <C>IsPrimitive</C> from the package <Package>IRREDSOL</Package>.
##
##  <Example><![CDATA[
##  gap> IsPrimitive(g,Orbit(g,(1,2)(3,4)));
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "IsPrimitive", OrbitsishReq, false, NewProperty );

InstallTrueMethod( IsPrimitive, IsNaturalSymmetricGroup );
InstallTrueMethod( IsPrimitive, IsNaturalAlternatingGroup );
InstallTrueMethod( IsTransitive, IsPrimitive and IsPermGroup );


#############################################################################
##
#O  IsPrimitiveAffine( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsPrimitiveAffine( <xset> )
##
##  <ManSection>
##  <Oper Name="IsPrimitiveAffine" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Prop Name="IsPrimitiveAffine" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
OrbitsishOperation( "IsPrimitiveAffine", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  IsSemiRegular( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsSemiRegular( <G> )
#P  IsSemiRegular( <xset> )
##
##  <#GAPDoc Label="IsSemiRegular">
##  <ManSection>
##  <Heading>IsSemiRegular</Heading>
##  <Oper Name="IsSemiRegular" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Prop Name="IsSemiRegular" Arg='G'
##   Label="for a permutation group"/>
##  <Prop Name="IsSemiRegular" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  returns <K>true</K> if the action implied by the arguments is
##  semiregular, or <K>false</K> otherwise.
##  <P/>
##  <Index>semiregular</Index>
##  An action is <E>semiregular</E> if the stabilizer of each point is the
##  identity.
##  <P/>
##  For a permutation group <A>G</A>, one may also invoke this as
##  <C>IsSemiRegular(<A>G</A>)</C>, which tests whether the group is
##  semiregular with respect to its natural action on the set of points
##  moved by it.
##  For example the group <M>\langle (2,3,4) (5,6,7) \rangle</M>
##  is semiregular on the set <M>\{2, 3, 4, 5, 6, 7\}</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "IsSemiRegular", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  IsRegular( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsRegular( <G> )
#P  IsRegular( <xset> )
##
##  <#GAPDoc Label="IsRegular">
##  <ManSection>
##  <Heading>IsRegular</Heading>
##  <Oper Name="IsRegular" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Prop Name="IsRegular" Arg='G'
##   Label="for a permutation group"/>
##  <Prop Name="IsRegular" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  returns <K>true</K> if the action implied by the arguments is regular, or
##  <K>false</K> otherwise.
##  <P/>
##  <Index>regular</Index>
##  An action is <E>regular</E> if it is both semiregular
##  (see&nbsp;<Ref Oper="IsSemiRegular" Label="for a group, an action domain, etc."/>)
##  and transitive
##  (see&nbsp;<Ref Oper="IsTransitive" Label="for a group, an action domain, etc."/>).
##  In this case every point <A>pnt</A> of <A>Omega</A> defines a one-to-one
##  correspondence between <A>G</A> and <A>Omega</A>.
##  <P/>
##  For a permutation group <A>G</A>, one may also invoke this as
##  <C>IsRegular(<A>G</A>)</C>, which tests whether the group is
##  regular with respect to its natural action on the set of points moved by it.
##  For example the group <M>\langle (2,3,4) \rangle</M>
##  is regular on the set <M>\{2, 3, 4\}</M>.
##
##  <Example><![CDATA[
##  gap> IsSemiRegular(g,Arrangements([1..4],3),OnTuples);
##  true
##  gap> IsRegular(g,Arrangements([1..4],3),OnTuples);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "IsRegular", OrbitsishReq, false, NewProperty );

InstallTrueMethod( IsRegular, IsTransitive and IsSemiRegular );


#############################################################################
##
#O  RankAction( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  RankAction( <xset> )
##
##  <#GAPDoc Label="RankAction">
##  <ManSection>
##  <Heading>RankAction</Heading>
##  <Oper Name="RankAction" Arg='G, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Attr Name="RankAction" Arg='xset'
##   Label="for an external set"/>
##
##  <Description>
##  returns the rank of the transitive (see
##  <Ref Oper="IsTransitive" Label="for a group, an action domain, etc."/>)
##  action of <A>G</A> on <A>Omega</A>, i. e., the number of orbits of
##  any point stabilizer.
##  <Example><![CDATA[
##  gap> RankAction(g,Combinations([1..4],2),OnSets);
##  4
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
OrbitsishOperation( "RankAction", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#F  Permutation( <g>, <Omega>[, <gens>, <acts>][, <act>] )
#F  Permutation( <g>, <xset> )
##
##  <#GAPDoc Label="Permutation">
##  <ManSection>
##  <Heading>Permutation</Heading>
##  <Func Name="Permutation" Arg='g, Omega[, gens, acts][, act]'
##   Label="for a group, an action domain, etc."/>
##  <Func Name="Permutation" Arg='g, xset' Label="for an external set"/>
##
##  <Description>
##  computes the permutation that corresponds to the action of <A>g</A> on
##  the permutation domain <A>Omega</A>
##  (a list of objects that are permuted).
##  If an external set <A>xset</A> is given,
##  the permutation domain is the <Ref Attr="HomeEnumerator"/> value
##  of this external set (see Section&nbsp;<Ref Sect="External Sets"/>).
##  Note that the points of the returned permutation refer to the positions
##  in <A>Omega</A>, even if <A>Omega</A> itself consists of integers.
##  <P/>
##  If <A>g</A> does not leave the domain invariant, or does not map the
##  domain injectively then <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Permutation" );

DeclareOperation( "PermutationOp", [ IsObject, IsList, IsFunction ] );


#############################################################################
##
#O  PermutationCycle( <g>, <Omega>, <pnt>[, <act>] )
##
##  <#GAPDoc Label="PermutationCycle">
##  <ManSection>
##  <Func Name="PermutationCycle" Arg='g, Omega, pnt[, act]'/>
##
##  <Description>
##  computes the permutation that represents the cycle of <A>pnt</A> under
##  the action of the element <A>g</A>.
##  <Example><![CDATA[
##  gap> Permutation([[Z(3),-Z(3)],[Z(3),0*Z(3)]],AsList(GF(3)^2));
##  (2,7,6)(3,4,8)
##  gap> Permutation((1,2,3)(4,5)(6,7),[4..7]);
##  (1,2)(3,4)
##  gap> PermutationCycle((1,2,3)(4,5)(6,7),[4..7],4);
##  (1,2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PermutationCycle" );

DeclareOperation( "PermutationCycleOp",
    [ IsObject, IsList, IsObject, IsFunction ] );


#############################################################################
##
#O  Cycle( <g>, <Omega>, <pnt> [,<act>] )
##
##  <#GAPDoc Label="Cycle">
##  <ManSection>
##  <Func Name="Cycle" Arg='g, Omega, pnt[, act]'/>
##
##  <Description>
##  returns a list of the points in the cycle of <A>pnt</A> under the action
##  of the element <A>g</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Cycle" );

DeclareOperation( "CycleOp", [ IsObject, IsList, IsObject, IsFunction ] );


#############################################################################
##
#O  Cycles( <g>, <Omega> [,<act>] )
##
##  <#GAPDoc Label="Cycles">
##  <ManSection>
##  <Func Name="Cycles" Arg='g, Omega[, act]'/>
##
##  <Description>
##  returns a list of the cycles (as lists of points) of the action of the
##  element <A>g</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Cycles" );

DeclareOperation( "CyclesOp", [ IsObject, IsList, IsFunction ] );


#############################################################################
##
#O  CycleLength( <g>, <Omega>, <pnt> [,<act>] )
##
##  <#GAPDoc Label="CycleLength">
##  <ManSection>
##  <Func Name="CycleLength" Arg='g, Omega, pnt[, act]'/>
##
##  <Description>
##  returns the length of the cycle of <A>pnt</A> under the action of the element
##  <A>g</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CycleLength" );

DeclareOperation( "CycleLengthOp",
    [ IsObject, IsList, IsObject, IsFunction ] );


#############################################################################
##
#O  CycleLengths( <g>, <Omega>[, <act>] )
##
##  <#GAPDoc Label="CycleLengths">
##  <ManSection>
##  <Oper Name="CycleLengths" Arg='g, Omega[, act]'/>
##
##  <Description>
##  returns the lengths of all the cycles under the action of the element
##  <A>g</A> on <A>Omega</A>.
##  <Example><![CDATA[
##  gap> Cycle((1,2,3)(4,5)(6,7),[4..7],4);
##  [ 4, 5 ]
##  gap> CycleLength((1,2,3)(4,5)(6,7),[4..7],4);
##  2
##  gap> Cycles((1,2,3)(4,5)(6,7),[4..7]);
##  [ [ 4, 5 ], [ 6, 7 ] ]
##  gap> CycleLengths((1,2,3)(4,5)(6,7),[4..7]);
##  [ 2, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CycleLengths" );

DeclareOperation( "CycleLengthsOp",
    [ IsObject, IsList, IsFunction ] );


#############################################################################
##
#F  CycleIndex( <g>, <Omega>[, <act>] )
#F  CycleIndex( <G>, <Omega>[, <act>] )
##
##  <#GAPDoc Label="CycleIndex">
##  <ManSection>
##  <Heading>CycleIndex</Heading>
##  <Func Name="CycleIndex" Arg='g, Omega[, act]'
##   Label="for a permutation and an action domain"/>
##  <Func Name="CycleIndex" Arg='G, Omega[, act]'
##   Label="for a permutation group and an action domain"/>
##
##  <Description>
##  The <E>cycle index</E> of a permutation <A>g</A> acting on <A>Omega</A>
##  is defined as
##  <Display Mode="M">
##  z(<A>g</A>) = s_1^{{c_1}} s_2^{{c_2}} \cdots s_n^{{c_n}}
##  </Display>
##  where <M>c_k</M> is the number of <M>k</M>-cycles in the cycle
##  decomposition of <A>g</A> and the <M>s_i</M> are indeterminates.
##  <P/>
##  The <E>cycle index</E> of a group <A>G</A> is defined as
##  <Display Mode="M">
##  Z(<A>G</A>) = \left( \sum_{{g \in <A>G</A>}} z(g) \right) / |<A>G</A>| .
##  </Display>
##  <P/>
##  The indeterminates used by
##  <Ref Func="CycleIndex" Label="for a permutation and an action domain"/>
##  are the indeterminates <M>1</M> to <M>n</M> over the rationals
##  (see&nbsp;<Ref Oper="Indeterminate" Label="for a ring (and a number)"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> g:=TransitiveGroup(6,8);
##  S_4(6c) = 1/2[2^3]S(3)
##  gap> CycleIndex(g);
##  1/24*x_1^6+1/8*x_1^2*x_2^2+1/4*x_1^2*x_4+1/4*x_2^3+1/3*x_3^2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CycleIndex" );

DeclareOperation( "CycleIndexOp",
    [ IsObject, IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  RepresentativeAction( <G> [,<Omega>], <d>, <e> [,<gens>,<acts>] [,<act>] )
##
##  <#GAPDoc Label="RepresentativeAction">
##  <ManSection>
##  <Func Name="RepresentativeAction"
##   Arg='G[, Omega], d, e[, gens, acts][, act]'/>
##
##  <Description>
##  computes an element of <A>G</A> that maps <A>d</A> to <A>e</A> under the
##  given action and returns <K>fail</K> if no such element exists.
##  <Example><![CDATA[
##  gap> g:=Group((1,3,2),(2,4,3));;
##  gap> RepresentativeAction(g,1,3);
##  (1,3)(2,4)
##  gap> RepresentativeAction(g,1,3,OnPoints);
##  (1,3)(2,4)
##  gap> RepresentativeAction(g,(1,2,3),(2,4,3));
##  (1,2,4)
##  gap> RepresentativeAction(g,(1,2,3),(2,3,4));
##  fail
##  gap> RepresentativeAction(g,Group((1,2,3)),Group((2,3,4)));
##  (1,2,4)
##  gap>  RepresentativeAction(g,[1,2,3],[1,2,4],OnSets);
##  (2,4,3)
##  gap>  RepresentativeAction(g,[1,2,3],[1,2,4],OnTuples);
##  fail
##  ]]></Example>
##  <P/>
##  (See Section&nbsp;<Ref Sect="Basic Actions"/>
##  for information about specific actions.)
##  <P/>
##  Again the standard method for <Ref Func="RepresentativeAction"/> is
##  an orbit-stabilizer algorithm,
##  for permutation groups and standard actions a backtrack algorithm is used.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RepresentativeAction" );
DeclareOperation( "RepresentativeActionOp",
    [ IsGroup, IsList, IsObject, IsObject, IsFunction ] );


#############################################################################
##
#F  Stabilizer( <G> [,<Omega>], <pnt> [,<gens>,<acts>] [,<act>] )
##
##  <#GAPDoc Label="Stabilizer">
##  <ManSection>
##  <Func Name="Stabilizer" Arg='G[, Omega], pnt[, gens, acts][, act]'/>
##
##  <Description>
##  computes the stabilizer in <A>G</A> of the point <A>pnt</A>,
##  that is the subgroup of those elements of <A>G</A> that fix <A>pnt</A>.
##  The stabilizer will have <A>G</A> as its parent.
##  <Example><![CDATA[
##  gap> g:=Group((1,3,2),(2,4,3));;
##  gap> stab:=Stabilizer(g,4);
##  Group([ (1,3,2) ])
##  gap> Parent(stab);
##  Group([ (1,3,2), (2,4,3) ])
##  ]]></Example>
##  <P/>
##  The stabilizer of a set or tuple of points can be computed by specifying
##  an action of sets or tuples of points.
##  <Example><![CDATA[
##  gap> Stabilizer(g,[1,2],OnSets);
##  Group([ (1,2)(3,4) ])
##  gap> Stabilizer(g,[1,2],OnTuples);
##  Group(())
##  gap> orbstab:=OrbitStabilizer(g,[1,2],OnSets);
##  rec(
##    orbit := [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 3, 4 ],
##        [ 2, 4 ] ], stabilizer := Group([ (1,2)(3,4) ]) )
##  gap> Parent(orbstab.stabilizer);
##  Group([ (1,3,2), (2,4,3) ])
##  ]]></Example>
##  <P/>
##  (See Section&nbsp;<Ref Sect="Basic Actions"/>
##  for information about specific actions.)
##  <P/>
##  The standard methods for all these actions are an orbit-stabilizer
##  algorithm. For permutation groups backtrack algorithms are used. For
##  solvable groups an orbit-stabilizer algorithm for solvable groups, which
##  uses the fact that the orbits of a normal subgroup form a block system
##  (see <Cite Key="SOGOS"/>) is used.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Stabilizer" );

OrbitishFO( "StabilizerFunc", OrbitishReq, IsCollsElms, false,false );
BindGlobal( "StabilizerOp", StabilizerFuncOp );


#############################################################################
##
#F  StabilizerPcgs( <pcgs>, <pnt> [,<acts>] [,<act>] )
##
##  <#GAPDoc Label="StabilizerPcgs">
##  <ManSection>
##  <Func Name="StabilizerPcgs" Arg='pcgs, pnt[, acts][, act]'/>
##
##  <Description>
##  computes the stabilizer in the group generated by <A>pcgs</A> of the
##  point <A>pnt</A>.
##  If given, <A>acts</A> are elements by which <A>pcgs</A> acts,
##  <A>act</A> is the acting function.
##  This function returns a pcgs for the stabilizer which is induced by the
##  <C>ParentPcgs</C> of <A>pcgs</A>, that is it is compatible
##  with <A>pcgs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StabilizerPcgs" );

#############################################################################
##
#F  OrbitStabilizerAlgorithm( <G>, <Omega>, <blist>, <gens>,<acts>, <pntact> )
##
##  <#GAPDoc Label="OrbitStabilizerAlgorithm">
##  <ManSection>
##  <Oper Name="OrbitStabilizerAlgorithm"
##   Arg='G, Omega, blist, gens, acts, pntact'/>
##
##  <Description>
##  This operation should not be called by a user. It is documented however
##  for purposes to extend or maintain the group actions package
##  (the word <Q>package</Q> here refers to the &GAP; functionality for
##  group actions, not to a &GAP; package).
##  <P/>
##  <Ref Oper="OrbitStabilizerAlgorithm"/> performs an orbit stabilizer
##  algorithm for the group <A>G</A> acting with the generators <A>gens</A>
##  via the generator images <A>gens</A> and the group action <A>act</A> on
##  the element <A>pnt</A>.
##  (For technical reasons <A>pnt</A> and <A>act</A> are put in one record
##  with components <C>pnt</C> and <C>act</C> respectively.)
##  <P/>
##  The <A>pntact</A> record may carry a component <A>stabsub</A>.
##  If given, this must be a subgroup stabilizing <E>all</E> points in the
##  domain and can be used to abbreviate stabilizer calculations.
##  <P/>
##  The <A>pntact</A> component also may contain the boolean entry <C>onlystab</C> set
##  to <K>true</K>. In this case the <C>orbit</C> component may be omitted from the
##  result.
##  <P/>
##  The argument <A>Omega</A> (which may be replaced by <K>false</K> to be ignored) is
##  the set within which the orbit is computed (once the orbit is the full
##  domain, the orbit calculation may stop).  If <A>blist</A> is given it must be
##  a bit list corresponding to <A>Omega</A> in which elements which have been found
##  already will be <Q>ticked off</Q> with <K>true</K>. (In particular, the entries
##  for the orbit of <A>pnt</A> still must be all set to <K>false</K>). Again the
##  remaining action domain (the bits set initially to <K>false</K>) can be
##  used to stop if the orbit cannot grow any longer.
##  Another use of the bit list is if <A>Omega</A> is an enumerator which can
##  determine <Ref Oper="PositionCanonical"/> values very quickly.
##  In this situation it can be
##  worth to search images not in the orbit found so far, but via their
##  position in <A>Omega</A> and use a the bit list to keep track whether the
##  element is in the orbit found so far.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "OrbitStabilizerAlgorithm",
  [IsGroup,IsObject,IsObject,IsList,IsList,IsRecord] );

DeclareGlobalFunction( "OrbitByPosOp" );


# AH, 5-feb-99 This function is neither documented not used.
#DeclareGlobalFunction( "OrbitStabilizerListByGenerators" );

DeclareGlobalFunction( "SetCanonicalRepresentativeOfExternalOrbitByPcgs" );

DeclareGlobalFunction( "StabilizerOfBlockNC" );

#############################################################################
##
#O  AbelianSubfactorAction(<G>,<M>,<N>)
##
##  <#GAPDoc Label="AbelianSubfactorAction">
##  <ManSection>
##  <Oper Name="AbelianSubfactorAction" Arg='G, M, N'/>
##
##  <Description>
##  Let <A>G</A> be a group and <M><A>M</A> \geq <A>N</A></M> be subgroups
##  of a common parent that are normal under <A>G</A>, such that
##  the subfactor <M><A>M</A>/<A>N</A></M> is elementary abelian.
##  The operation <Ref Oper="AbelianSubfactorAction"/> returns a list
##  <C>[ <A>phi</A>, <A>alpha</A>, <A>bas</A> ]</C> where
##  <A>bas</A> is a list of elements of <A>M</A> which are representatives
##  for a basis of <M><A>M</A>/<A>N</A></M>,
##  <A>alpha</A> is a map from <A>M</A> into a <M>n</M>-dimensional row space
##  over <M>GF(p)</M> where <M>[<A>M</A>:<A>N</A>] = p^n</M> that is the
##  natural homomorphism of <A>M</A> by <A>N</A> with the quotient
##  represented as an additive group.
##  Finally <A>phi</A> is a homomorphism from <A>G</A>
##  into <M>GL_n(p)</M> that represents the action of <A>G</A> on the factor
##  <M><A>M</A>/<A>N</A></M>.
##  <P/>
##  Note: If only matrices for the action are needed,
##  <Ref Func="LinearActionLayer"/> might be faster.
##  <Example><![CDATA[
##  gap> g:=Group((1,8,10,7,3,5)(2,4,12,9,11,6),
##  >             (1,9,5,6,3,10)(2,11,12,8,4,7));;
##  gap> c:=ChiefSeries(g);;List(c,Size);
##  [ 96, 48, 16, 4, 1 ]
##  gap> HasElementaryAbelianFactorGroup(c[3],c[4]);
##  true
##  gap> SetName(c[3],"my_group");;
##  gap> a:=AbelianSubfactorAction(g,c[3],c[4]);
##  [ [ (1,8,10,7,3,5)(2,4,12,9,11,6), (1,9,5,6,3,10)(2,11,12,8,4,7) ] ->
##      [ <an immutable 2x2 matrix over GF2>,
##        <an immutable 2x2 matrix over GF2> ],
##    MappingByFunction( my_group, ( GF(2)^
##      2 ), function( e ) ... end, function( r ) ... end ),
##    Pcgs([ (2,9,3,8)(4,11,5,10), (1,6,12,7)(4,10,5,11) ]) ]
##  gap> mat:=Image(a[1],g);
##  Group([ <an immutable 2x2 matrix over GF2>,
##    <an immutable 2x2 matrix over GF2> ])
##  gap> Size(mat);
##  3
##  gap> e:=PreImagesRepresentative(a[2],[Z(2),0*Z(2)]);
##  (2,9,3,8)(4,11,5,10)
##  gap> e in c[3];e in c[4];
##  true
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AbelianSubfactorAction",[IsGroup,IsGroup,IsGroup] );

#############################################################################
##
#F  OnPoints( <pnt>, <g> )
##
##  <#GAPDoc Label="OnPoints">
##  <ManSection>
##  <Func Name="OnPoints" Arg='pnt, g'/>
##
##  <Description>
##  <Index>conjugation</Index>
##  <Index Subkey="by conjugation">action</Index>
##  returns <C><A>pnt</A> ^ <A>g</A></C>.
##  This is for example the action of a permutation group on points,
##  or the action of a group on its elements via conjugation,
##  that is, if both <A>pnt</A> and <A>g</A> are elements from a common group
##  then <C><A>pnt</A> ^ <A>g</A></C> is equal to
##  <A>g</A><M>^{{-1}}</M><C>*</C><A>pnt</A><C>*</C><A>g</A>.
##  The action of a matrix group on vectors from the right is described by
##  both <Ref Func="OnPoints"/> and <Ref Func="OnRight"/>.
##  <Example><![CDATA[
##  gap> OnPoints( 1, (1,2,3) );
##  2
##  gap> OnPoints( (1,2), (1,2,3) );
##  (2,3)
##  gap> g:= Group( (1,2,3), (2,3,4) );;
##  gap> Orbit( g, 1, OnPoints );
##  [ 1, 2, 3, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  OnRight( <pnt>, <g> )
##
##  <#GAPDoc Label="OnRight">
##  <ManSection>
##  <Func Name="OnRight" Arg='pnt, g'/>
##
##  <Description>
##  returns <C><A>pnt</A> * <A>g</A></C>.
##  This is for example the action of a group on its elements via right
##  multiplication,
##  or the action of a group on the cosets of a subgroup.
##  The action of a matrix group on vectors from the right is described by
##  both <Ref Func="OnPoints"/> and <Ref Func="OnRight"/>.
##  <Example><![CDATA[
##  gap> OnRight( [ 1, 2 ], [ [ 1, 2 ], [ 3, 4 ] ] );
##  [ 7, 10 ]
##  gap> OnRight( (1,2,3), (2,3,4) );
##  (1,3)(2,4)
##  gap> g:= Group( (1,2,3), (2,3,4) );;
##  gap> Orbit( g, (), OnRight );
##  [ (), (1,2,3), (2,3,4), (1,3,2), (1,3)(2,4), (1,2)(3,4), (2,4,3),
##    (1,4,2), (1,4,3), (1,3,4), (1,2,4), (1,4)(2,3) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  OnLeftInverse( <pnt>, <g> )
##
##  <#GAPDoc Label="OnLeftInverse">
##  <ManSection>
##  <Func Name="OnLeftInverse" Arg='pnt, g'/>
##
##  <Description>
##  returns <M><A>g</A>^{{-1}}</M> <C>* <A>pnt</A></C>.
##  Forming the inverse is necessary to make this a proper action,
##  as in &GAP; groups always act from the right.
##  <P/>
##  <Ref Func="OnLeftInverse"/> is used for example in the representation
##  of a right coset as an external set
##  (see&nbsp;<Ref Sect="External Sets"/>),
##  that is, a right coset <M>Ug</M> is an external set for the group
##  <M>U</M> acting on it via <Ref Func="OnLeftInverse"/>.)
##  <Example><![CDATA[
##  gap> OnLeftInverse( [ 1, 2 ], [ [ 1, 2 ], [ 3, 4 ] ] );
##  [ 0, 1/2 ]
##  gap> OnLeftInverse( (1,2,3), (2,3,4) );
##  (1,2,4)
##  gap> g:= Group( (1,2,3), (2,3,4) );;
##  gap> Orbit( g, (), OnLeftInverse );
##  [ (), (1,3,2), (2,4,3), (1,2,3), (1,3)(2,4), (1,2)(3,4), (2,3,4),
##    (1,2,4), (1,3,4), (1,4,3), (1,4,2), (1,4)(2,3) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  OnSets( <set>, <g> )
##
##  <#GAPDoc Label="OnSets">
##  <ManSection>
##  <Func Name="OnSets" Arg='set, g'/>
##
##  <Description>
##  <Index Subkey="on sets">action</Index>
##  <Index Subkey="on blocks">action</Index>
##  Let <A>set</A> be a proper set
##  (see&nbsp;<Ref Sect="Sorted Lists and Sets"/>).
##  <Ref Func="OnSets"/> returns the proper set formed by the images
##  of all points <M>x</M> of <A>set</A> via the action function
##  <Ref Func="OnPoints"/>, applied to <M>x</M> and <A>g</A>.
##  <P/>
##  <Ref Func="OnSets"/> is for example used to compute the action of
##  a permutation group on blocks.
##  <P/>
##  (<Ref Func="OnTuples"/> is an action on lists that preserves the ordering
##  of entries.)
##  <Example><![CDATA[
##  gap> OnSets( [ 1, 3 ], (1,2,3) );
##  [ 1, 2 ]
##  gap> OnSets( [ (2,3), (1,2) ], (1,2,3) );
##  [ (2,3), (1,3) ]
##  gap> g:= Group( (1,2,3), (2,3,4) );;
##  gap> Orbit( g, [ 1, 2 ], OnSets );
##  [ [ 1, 2 ], [ 2, 3 ], [ 1, 3 ], [ 3, 4 ], [ 1, 4 ], [ 2, 4 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  OnTuples( <tup>, <g> )
##
##  <#GAPDoc Label="OnTuples">
##  <ManSection>
##  <Func Name="OnTuples" Arg='tup, g'/>
##
##  <Description>
##  Let <A>tup</A> be a list.
##  <Ref Func="OnTuples"/> returns the list formed by the images
##  of all points <M>x</M> of <A>tup</A> via the action function
##  <Ref Func="OnPoints"/>, applied to <M>x</M> and <A>g</A>.
##  <P/>
##  (<Ref Func="OnSets"/> is an action on lists that additionally sorts
##  the entries of the result.)
##  <Example><![CDATA[
##  gap> OnTuples( [ 1, 3 ], (1,2,3) );
##  [ 2, 1 ]
##  gap> OnTuples( [ (2,3), (1,2) ], (1,2,3) );
##  [ (1,3), (2,3) ]
##  gap> g:= Group( (1,2,3), (2,3,4) );;
##  gap> Orbit( g, [ 1, 2 ], OnTuples );
##  [ [ 1, 2 ], [ 2, 3 ], [ 1, 3 ], [ 3, 1 ], [ 3, 4 ], [ 2, 1 ],
##    [ 1, 4 ], [ 4, 1 ], [ 4, 2 ], [ 3, 2 ], [ 2, 4 ], [ 4, 3 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  OnPairs( <tup>, <g> )
##
##  <#GAPDoc Label="OnPairs">
##  <ManSection>
##  <Func Name="OnPairs" Arg='tup, g'/>
##
##  <Description>
##  is a special case of <Ref Func="OnTuples"/> for lists <A>tup</A>
##  of length 2.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  OnLines( <vec>, <g> )
##
##  <#GAPDoc Label="OnLines">
##  <ManSection>
##  <Func Name="OnLines" Arg='vec, g'/>
##
##  <Description>
##  Let <A>vec</A> be a <E>normed</E> row vector, that is,
##  its first nonzero entry is normed to the identity of the relevant field,
##  see <Ref Attr="NormedRowVector"/>.
##  The function <Ref Func="OnLines"/> returns the row vector obtained from
##  first multiplying <A>vec</A> from the right with <A>g</A>
##  (via <Ref Func="OnRight"/>) and then normalizing the resulting row vector
##  by scalar multiplication from the left.
##  <P/>
##  This action corresponds to the projective action of a matrix group
##  on one-dimensional subspaces.
##  <P/>
##  If <A>vec</A> is a zero vector or is not normed then
##  an error is triggered
##  (see&nbsp;<Ref Sect="Action on canonical representatives"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> OnLines( [ 1, 2 ], [ [ 1, 2 ], [ 3, 4 ] ] );
##  [ 1, 10/7 ]
##  gap> gl:=GL(2,5);;v:=[1,0]*Z(5)^0;
##  [ Z(5)^0, 0*Z(5) ]
##  gap> h:=Action(gl,Orbit(gl,v,OnLines),OnLines);
##  Group([ (2,3,5,6), (1,2,4)(3,6,5) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OnLines");


#############################################################################
##
#F  OnSetsSets( <set>, <g> )
##
##  <#GAPDoc Label="OnSetsSets">
##  <ManSection>
##  <Func Name="OnSetsSets" Arg='set, g'/>
##
##  <Description>
##  implements the action on sets of sets.
##  For the special case that the sets are pairwise disjoint,
##  it is possible to use <Ref Func="OnSetsDisjointSets"/>.
##  <A>set</A> must be a sorted list whose entries are again sorted lists,
##  otherwise an error is triggered
##  (see&nbsp;<Ref Sect="Action on canonical representatives"/>).
##  <Example><![CDATA[
##  gap> OnSetsSets( [ [ 1, 2 ], [ 3, 4 ] ], (1,2,3) );
##  [ [ 1, 4 ], [ 2, 3 ] ]
##  gap> g:= Group( (1,2,3), (2,3,4) );;
##  gap> Orbit( g, [ [ 1, 2 ], [ 3, 4 ] ], OnSetsSets );
##  [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 1, 4 ], [ 2, 3 ] ],
##    [ [ 1, 3 ], [ 2, 4 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OnSetsSets" );


#############################################################################
##
#F  OnSetsDisjointSets( <set>, <g> )
##
##  <#GAPDoc Label="OnSetsDisjointSets">
##  <ManSection>
##  <Func Name="OnSetsDisjointSets" Arg='set, g'/>
##
##  <Description>
##  implements the action on sets of pairwise disjoint sets
##  (see also&nbsp;<Ref Func="OnSetsSets"/>).
##  <A>set</A> must be a sorted list whose entries are again sorted lists,
##  otherwise an error is triggered
##  (see&nbsp;<Ref Sect="Action on canonical representatives"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OnSetsDisjointSets" );


#############################################################################
##
#F  OnSetsTuples( <set>, <g> )
##
##  <#GAPDoc Label="OnSetsTuples">
##  <ManSection>
##  <Func Name="OnSetsTuples" Arg='set, g'/>
##
##  <Description>
##  implements the action on sets of tuples.
##  <A>set</A> must be a sorted list,
##  otherwise an error is triggered
##  (see&nbsp;<Ref Sect="Action on canonical representatives"/>).
##  <Example><![CDATA[
##  gap> OnSetsTuples( [ [ 1, 2 ], [ 3, 4 ] ], (1,2,3) );
##  [ [ 1, 4 ], [ 2, 3 ] ]
##  gap> g:= Group( (1,2,3), (2,3,4) );;
##  gap> Orbit( g, [ [ 1, 2 ], [ 3, 4 ] ], OnSetsTuples );
##  [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 1, 4 ], [ 2, 3 ] ],
##    [ [ 1, 3 ], [ 4, 2 ] ], [ [ 2, 4 ], [ 3, 1 ] ],
##    [ [ 2, 1 ], [ 4, 3 ] ], [ [ 3, 2 ], [ 4, 1 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OnSetsTuples");


#############################################################################
##
#F  OnTuplesSets( <set>, <g> )
##
##  <#GAPDoc Label="OnTuplesSets">
##  <ManSection>
##  <Func Name="OnTuplesSets" Arg='set, g'/>
##
##  <Description>
##  implements the action on tuples of sets.
##  <A>set</A> must be a list whose entries are again sorted lists,
##  otherwise an error is triggered
##  (see&nbsp;<Ref Sect="Action on canonical representatives"/>).
##  <Example><![CDATA[
##  gap> OnTuplesSets( [ [ 2, 3 ], [ 3, 4 ] ], (1,2,3) );
##  [ [ 1, 3 ], [ 1, 4 ] ]
##  gap> g:= Group( (1,2,3), (2,3,4) );;
##  gap> Orbit( g, [ [ 1, 2 ], [ 3, 4 ] ], OnTuplesSets );
##  [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 2, 3 ], [ 1, 4 ] ],
##    [ [ 1, 3 ], [ 2, 4 ] ], [ [ 3, 4 ], [ 1, 2 ] ],
##    [ [ 1, 4 ], [ 2, 3 ] ], [ [ 2, 4 ], [ 1, 3 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OnTuplesSets");


#############################################################################
##
#F  OnTuplesTuples( <set>, <g> )
##
##  <#GAPDoc Label="OnTuplesTuples">
##  <ManSection>
##  <Func Name="OnTuplesTuples" Arg='set, g'/>
##
##  <Description>
##  implements the action on tuples of tuples.
##  <Example><![CDATA[
##  gap> OnTuplesTuples( [ [ 2, 3 ], [ 3, 4 ] ], (1,2,3) );
##  [ [ 3, 1 ], [ 1, 4 ] ]
##  gap> g:=Group((1,2,3),(2,3,4));;
##  gap> Orbit(g,[[1,2],[3,4]],OnTuplesTuples);
##  [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 2, 3 ], [ 1, 4 ] ],
##    [ [ 1, 3 ], [ 4, 2 ] ], [ [ 3, 1 ], [ 2, 4 ] ],
##    [ [ 3, 4 ], [ 1, 2 ] ], [ [ 2, 1 ], [ 4, 3 ] ],
##    [ [ 1, 4 ], [ 2, 3 ] ], [ [ 4, 1 ], [ 3, 2 ] ],
##    [ [ 4, 2 ], [ 1, 3 ] ], [ [ 3, 2 ], [ 4, 1 ] ],
##    [ [ 2, 4 ], [ 3, 1 ] ], [ [ 4, 3 ], [ 2, 1 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OnTuplesTuples");

#############################################################################
##
#O  DomainForAction( <pnt>, <acts>, <act> )
##
##  <ManSection>
##  <Oper Name="DomainForAction" Arg='pnt, acts, act'/>
##
##  <Description>
##  returns a domain which will contain the orbit of <A>pnt</A> under the action
##  <A>act</A>  of the group
##  generated by <A>acts</A>. (Such a domain can be helpful for obtaining
##  a dictionary.)
##  The default method returns <K>fail</K> to indicate that no special domain is
##  defined, a special method exists for matrix groups over finite fields.
##  </Description>
##  </ManSection>
##
DeclareOperation("DomainForAction",[IsObject,IsListOrCollection,IsFunction]);
