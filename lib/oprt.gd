#############################################################################
##
#W  oprt.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.oprt_gd :=
    "@(#)$Id$";

DeclareInfoClass( "InfoAction" );
DeclareSynonym( "InfoOperation",InfoAction );


#############################################################################
##
#C  IsExternalSet(<obj>)
##
##  An *external set*  specifies an action <act>:  $<Omega> \times <G> \to
##  <Omega>$  of a group <G> on a domain <Omega>. The external set knows the group,
##  the domain and the actual acting function.
##  Mathematically,  an external set  is the set~<Omega>, which is endowed with
##  the action of a group <G> via the group action <act>. For this reason
##  {\GAP} treats external sets as a domain whose elements are the  elements
##  of <Omega>. An external set is always a union of orbits.
##  Currently the domain~<Omega> must always be finite.
##  If <Omega> is not a list, an enumerator for <Omega> is automatically chosen.
##
DeclareCategory( "IsExternalSet", IsDomain );

OrbitishReq  := [ IsGroup, IsList, IsObject,
                  IsList,
                  IsList,
                  IsFunction ];
OrbitsishReq := [ IsGroup, IsList,
                  IsList,
                  IsList,
                  IsFunction ];

#############################################################################
##
#R  IsExternalSubset(<obj>)
##
##  An external subset is the restriction  of an external  set to a subset
##  of the domain (which must be invariant under the action). It is again an
##  external set.
##
DeclareRepresentation( "IsExternalSubset",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "start" ] );


#############################################################################
##
#R  IsExternalOrbit(<obj>)
##
##  An external orbit is an external subset consisting of one orbit.
##
DeclareRepresentation( "IsExternalOrbit",
    IsExternalSubset, [ "start" ] );
DeclareCategory( "IsExternalSetByPcgs", IsExternalSet );

# The following two integer variables give position in which the `Type' of an
# external set can  store the `Type' of its  external subsets resp.  external
# orbits (to avoid repeated calls of `NewType').
BindGlobal( "XSET_XSSETTYPE", 4 );
BindGlobal( "XSET_XORBTYPE", 5 );


#############################################################################
##
#R  IsExternalSetDefaultRep(<obj>)
#R  IsExternalSetByActorsRep(<obj>)
##
##  External sets  can be specified  directly (`IsExternalSetDefaultRep'), or
##  via <gens> and <acts> (`IsExternalSetByActorsRep').
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
##  This attribute returns the group with which the external set <xset> was
##  defined.
DeclareAttribute( "ActingDomain", IsExternalSet );

#############################################################################
##
#A  HomeEnumerator( <xset> )
##
##  returns an enumerator of the domain <Omega> with which <xset> was defined.
##  For external subsets, this is  different  from `Enumerator(  <xset> )',
##  which enumerates only the subset.
##
DeclareAttribute( "HomeEnumerator", IsExternalSet );

DeclareRepresentation( "IsActionHomomorphism",
    IsGroupHomomorphism and IsAttributeStoringRep and
    IsPreimagesByAsGroupGeneralMappingByImages, [  ] );
DeclareSynonym( "IsOperationHomomorphism",IsActionHomomorphism);

DeclareRepresentation( "IsActionHomomorphismByActors",
      IsActionHomomorphism, [  ] );
DeclareSynonym( "IsOperationHomomorphismByOperators",
  IsActionHomomorphismByActors);

DeclareRepresentation("IsActionHomomorphismSubset",IsActionHomomorphism,[]);
DeclareSynonym( "IsOperationHomomorphismSubset",
  IsActionHomomorphismSubset);

#############################################################################
##
#R  IsActionHomomorphismByBase(<obj>)
##
##  This is chosen if `HasBaseOfGroup( <xset> )'.
##
DeclareRepresentation( "IsActionHomomorphismByBase",
      IsActionHomomorphism, [  ] );
DeclareSynonym( "IsOperationHomomorphismByBase",
  IsActionHomomorphismByBase);

#############################################################################
##
#R  IsConstituentHomomorphism(<obj>)
##
DeclareRepresentation( "IsConstituentHomomorphism",
    IsActionHomomorphism, [ "conperm" ] );

DeclareRepresentation( "IsBlocksHomomorphism",
    IsActionHomomorphism, [ "reps" ] );

#############################################################################
##
#R  IsLinearActionHomomorphism(<hom>)
##
##  This   representation is chosen  for  action homomorphisms from matrix
##  groups acting naturally on a set of vectors.
##
DeclareRepresentation( "IsLinearActionHomomorphism",
      IsActionHomomorphism,
      [  ] );
DeclareSynonym( "IsLinearOperationHomomorphism",
  IsLinearActionHomomorphism);

#############################################################################
##
#A  LinearActionBasis(<hom>)
##
##  for action homomorphisms in the representation
##  `IsLinearActionHomomorphism', this attribute contains a vector space
##  basis as subset of the domain or `fail' if the domain does not span the
##  vector space that the group acts on.
##  groups acting naturally on a set of vectors.
##
DeclareAttribute( "LinearActionBasis",IsLinearActionHomomorphism);

#############################################################################
##
#A  FunctionAction( <xset> )
##
##  the acting function <act> of <xset>
DeclareAttribute( "FunctionAction", IsExternalSet );
DeclareSynonymAttr( "FunctionOperation", FunctionAction );

#############################################################################
##
#A  StabilizerOfExternalSet( <xset> ) .  stabilizer of `Representative(xset)'
##
##  computes the stabilizer of `Representative(<xset>)'
##  The stabilizer must have the acting group <G> of <xset> as its parent.
##
DeclareAttribute( "StabilizerOfExternalSet", IsExternalSet );

#############################################################################
##
#A  CanonicalRepresentativeOfExternalSet( <xset> )
##
##  The canonical representative of an  external set may  only depend on <G>,
##  <Omega>, <act> and (in the case of  external subsets) `Enumerator( <xset> )'.
##  It must not depend, e.g., on the representative of an external orbit.
##  {\GAP} does not know methods for every external set to compute a
##  canonical representative . See
##  "CanonicalRepresentativeDeterminatorOfExternalSet".
##
DeclareAttribute( "CanonicalRepresentativeOfExternalSet", IsExternalSet );


#############################################################################
##
#A  CanonicalRepresentativeDeterminatorOfExternalSet( <xset> )
##
##  returns a function that
##  takes as arguments the acting group and the point. It returns a list
##  of length 3: [<canonrep>, <stabilizercanonrep>, <conjugatingelm>].
##  (List components 2 and 3 are optional and do not need to be bound.)
##  An external set is only guaranteed to be able to compute a canonical
##  representative if it has a
##  `CanonicalRepresentativeDeterminatorOfExternalSet'.
DeclareAttribute( "CanonicalRepresentativeDeterminatorOfExternalSet",
    IsExternalSet );

#############################################################################
##
#A  ActorOfExternalSet( <xset> )
##
##  returns an element mapping `Representative(<xset>)' to
##  `CanonicalRepresentativeOfExternalSet(<xset>)' under the given
##  action.
##
DeclareAttribute( "ActorOfExternalSet", IsExternalSet );
DeclareSynonymAttr( "OperatorOfExternalSet", ActorOfExternalSet );


#############################################################################
##
#F  OrbitsishOperation( <name>, <reqs>, <usetype>, <AorP> ) . orbits-like op.
##
##  is used to create operations like `Orbits'.
##  This function creates an attribute or a property, respectively,
##  and installs several default methods.
##
##  The new operation, e.g., `Orbits', can be called either as
##  `Orbits( <xset> )' for an external set <xset>, or as
##  `Orbits( <G> )' for a permutation group, meaning the orbits on the moved
##  points of <G> via `OnPoints', or as
##  `Orbits( <G>, <Omega>[, <gens>, <acts>][, <act>] )', with a group <G>, a
##  domain or list <Omega>, generators <gens> of <G>, and corresponding elements
##  <acts> that act on <Omega> via the function <act>;
##  the default of <gens> and <acts> is a list of group generators of <G>,
##  the default of <act> is `OnPoints'.
##
##  Only methods for the five-argument version need to be installed for
##  doing the real work.
##  (And of course methods for one argument in case one wants to define
##  a new meaning of the attribute.)
##
##  The operation has name <name>, and its arguments are required to have
##  the filters in the list <reqs>.
##
##  If the Boolean <usetype> is `true' then the external set itself is used
##  as an argument of the five-argument version instead of <Omega>,
##  in order to enable the installation of methods that use the type of
##  the external set.
##
BindGlobal( "OrbitsishOperation", function( name, reqs, usetype, NewAorP )

    local nname, op,oldname;

    # Create the attribute or property.
    op:= NewAorP( name, IsExternalSet );
    BIND_GLOBAL( name, op );
    nname:= "Set"; APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, SETTER_FILTER( op ) );
    nname:= "Has"; APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, TESTER_FILTER( op ) );

    oldname:=ReplacedString(name,"Action","Operation");
    if oldname<>name then
      DeclareSynonymAttr(oldname,op);
    fi;

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
          D:= Enumerator( D );
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
          D:= Enumerator( D );
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
          D:= Enumerator( D );
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
#F  OrbitishFO( <name>, <reqs>, <famrel>, <usetype> ) .  orbit-like operation
##
##  is used to create operations like `Orbit'.
##  This function is analogous to `OrbitsishOperation',
##  but for operations <orbish> like `Orbit( <G>, <Omega>, <pnt> )'.
##  Since the return values of these operations depend on the  additional
##  argument <pnt>, there is no associated attribute.
##  The family relation <famrel> is required for the families of the 2nd and
##  3rd argument (e.g., `IsCollsElms' for `Orbit').
##
##  <usetype> can also be an attribute (`BlocksAttr' or `MaximalBlocksAttr').
##  In this case, if only one of the two arguments <Omega> and <pnt> is given,
##  blocks with no seed are computed, they are stored as attribute values
##  according to the rules of `OrbitsishOperation'.
##
BindGlobal( "OrbitishFO", function( name, reqs, famrel, usetype )

    local str, nname, orbish, func,oldname;

    # Create the operation.
    str:= SHALLOW_COPY_OBJ( name );
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
	  if HasHomeEnumerator( xset )  then
	      D := HomeEnumerator( xset );
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
		  D := Enumerator( D );
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
	  if CanEasilyComputePcgs( G )  then
	    gens := Pcgs( G );
	  else
	    gens := GeneratorsOfGroup( G );
	  fi;
	  acts := gens;
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

  oldname:=ReplacedString(name,"Action","Operation");
  if oldname<>name then
    DeclareSynonym(oldname,func);
    oldname:=ReplacedString(str,"Action","Operation");
    DeclareSynonym(oldname,orbish);
  fi;

end );


#############################################################################
##
#O  ActionHomomorphism(<G>,<Omega> [,<gens>,<acts>] [,<act>] [,"surjective"])
#A  ActionHomomorphism( <xset> [,"surjective"] )
#A  ActionHomomorphism( <action> )
##
##  computes a homomorphism from <G> into the symmetric group on $|<Omega>|$
##  points that gives the permutation action of <G> on <Omega>.
##
##  By default the homomorphism returned by `ActionHomomorphism' is not
##  necessarily surjective (its `Range' is the full symmetric group) to
##  avoid unnecessary computation of the image. If the optional string
##  argument `"surjective"' is given, a surjective homomorphism is created.
##
##  The third version (which is supported only for {\GAP}3 compatibility)
##  returns the action homomorphism that belongs to the image
##  obtained via `Action' (see "Action").
##
DeclareGlobalFunction( "ActionHomomorphism" );
DeclareAttribute( "ActionHomomorphismAttr", IsExternalSet );
DeclareGlobalFunction( "ActionHomomorphismConstructor" );
DeclareSynonym( "OperationHomomorphism",ActionHomomorphism );
DeclareSynonymAttr( "OperationHomomorphismAttr",ActionHomomorphismAttr );
DeclareSynonym("OperationHomomorphismConstructor",
               ActionHomomorphismConstructor);


#############################################################################
##
#A  SurjectiveActionHomomorphismAttr( <xset> )
##
##  returns an action homomorphism for <xset> which is surjective.
##  (As the `Image' of this homomorphism has to be computed to obtain the
##  range, this may take substantially longer
##  than `ActionHomomorphism'.)
DeclareAttribute( "SurjectiveActionHomomorphismAttr", IsExternalSet );
DeclareSynonymAttr( "SurjectiveOperationHomomorphismAttr",
  SurjectiveActionHomomorphismAttr );

#############################################################################
##
#A  UnderlyingExternalSet( <ohom> )
##
##  The underlying set of an action homomorphism is the external set on
##  which it was defined.
DeclareAttribute( "UnderlyingExternalSet", IsActionHomomorphism );

#############################################################################
##
#F  DoSparseActionHomomorphism(<G>,<start>,<gens>,<acts>,<act>,<phash>,<sort>)
##
##  is the function implementing the sparse action homomorphisms and syntax is
##  as for these. <phash> must be an injective ({\GAP})-function, for
##  example a perfect hash, element comparisons are done in its range.
##  Unless a fast enumeration is known, `IdFunc' should be used. If <sort>
##  is true, the action domain for the resulting homomorphism will be
##  sorted.
DeclareGlobalFunction("DoSparseActionHomomorphism");

#############################################################################
##
#O  SparseActionHomomorphism( <G>, <Omega>, <start> [,<gens>,<acts>] [,<act>] )
#O  SortedSparseActionHomomorphism(<G>,<Omega>,<start>[,<gens>,<acts>] [,<act>])
##
##  `SparseActionHomomorphism' computes the
##  `ActionHomomorphism(<G>,<dom>[,<gens>,<acts>][,<act>])', where <dom>
##  is the union of the orbits `Orbit(<G>,<pnt>[,<gens>,<acts>][,<act>])'
##  for all points <pnt> from <start>. If <G> acts on a very large domain
##  <Omega> not surjectively this may yield a permutation image of
##  substantially smarre degree than by action on <Omega>.
##
##  The operation `SparseActionHomomorphism' will only use `=' comparisons
##  of points in the orbit. Therefore it can be used even if no good `\<'
##  comparison method exists. However the image group will depend on the
##  generators <gens> of <G>.
##
##  The operation `SortedSparseActionHomomorphism' in contrast
##  will sort the orbit and thus produce an image group which is not
##  dependent on these generators.
##
OrbitishFO( "SparseActionHomomorphism", OrbitishReq,
               IsIdenticalObj, false );
OrbitishFO( "SortedSparseActionHomomorphism", OrbitishReq,
               IsIdenticalObj, false );

#############################################################################
##
#O  ImageElmActionHomomorphism( <op>,<elm> )
##
##  computes the image of <elm> under the action homomorphism <op> and is
##  guaranteed to use the action (and not the `AsGHBI', this is required
##  in some methods to bootstrap the range).
DeclareGlobalFunction( "ImageElmActionHomomorphism" );
DeclareSynonym( "ImageElmOperationHomomorphism",ImageElmActionHomomorphism );

#############################################################################
##
#O  Action( <G>, <Omega> [<gens>,<acts>] [,<act>] )
#A  Action( <xset> )
##
##  returns the `Image' group of `ActionHomomorphism' called with the same
##  parameters.
DeclareGlobalFunction( "Action" );
DeclareSynonym( "Operation",Action );

#############################################################################
##
#O  ExternalSet( <G>, <Omega>[, <gens>, <acts>][, <act>] )
##
##  creates the external set for the action <act> of <G> on <Omega>.
##  <Omega> can be either a proper set  or a domain which is represented as
##  described in "Domains" and "Collections".
##
OrbitsishOperation( "ExternalSet", OrbitsishReq, false, NewAttribute );

DeclareGlobalFunction( "ExternalSetByFilterConstructor" );
DeclareGlobalFunction( "ExternalSetByTypeConstructor" );

#############################################################################
##
#O  RestrictedExternalSet( <xset>, <U> )
##
##  If <U> is a subgroup of the `ActingDomain' of <xset> this operation
##  returns an external set for the same action which has the
##  `ActingDomain' <U>.
##
DeclareOperation("RestrictedExternalSet",[IsExternalSet,IsGroup]);

#############################################################################
##
#O  ExternalSubset(<G>,<xset>,<start>,[<gens>,<acts>,]<act>)
##
##  constructs the external subset of <xset> on the union of orbits of the
##  points in <start>.
##
OrbitishFO( "ExternalSubset",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, true );


#############################################################################
##
#O  ExternalOrbit( <G>, <Omega>, <pnt>, [<gens>,<acts>,] <act> )
##
##  constructs the external subset on the orbit of <pnt>. The
##  `Representative' of this external set is <pnt>.
##
OrbitishFO( "ExternalOrbit", OrbitishReq, IsCollsElms, true );


#############################################################################
##
#O  Orbit( <G>[,<Omega>], <pnt>, [<gens>,<acts>,] <act> )
##
##  The orbit of the point <pnt> is the list of all images of <pnt> under
##  the action.
##
##  (Note that the arrangement of points in this list is not defined by the
##  operation.)
##
##  The orbit of <pnt> will always contain one element that is *equal* to
##  <pnt>, however for performance reasons this element is not necessarily
##  *identical* to <pnt>, in particulr if <pnt> is mutable.
##
OrbitishFO( "Orbit", OrbitishReq, IsCollsElms, false );


#############################################################################
##
#O  Orbits( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  Orbits( <xset> )
##
##  returns a list of the orbits (given as lists) under the action.
##
##  (Note that the arrangement of orbits or of points within one orbit is
##  not defined by the operation.)
##
OrbitsishOperation( "Orbits", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  OrbitLength( <G>, <Omega>, <pnt>, [<gens>,<acts>,] <act> )
##
##  computes the length of the orbit of <pnt>.
##
OrbitishFO( "OrbitLength", OrbitishReq, IsCollsElms, false );


#############################################################################
##
#O  OrbitLengths( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  OrbitLengths( <xset> )
##
##  computes the lengths of all the orbits of <G> on <Omega>.
##
OrbitsishOperation( "OrbitLengths", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  OrbitStabilizer( <G>, [<Omega>,] <pnt>, [<gens>,<acts>,] <act> )
##
##  computes the orbit and the stabilizer of <pnt> simultaneously in a
##  single Orbit-Stabilizer algorithm.
##
##  The stabilizer must have <G> as its parent.
##
OrbitishFO( "OrbitStabilizer", OrbitishReq, IsCollsElms, false );


#############################################################################
##
#O  ExternalOrbits( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  ExternalOrbits( <xset> )
##
##  computes a list of `ExternalOrbit's that give the orbits of <G>.
##
OrbitsishOperation( "ExternalOrbits", OrbitsishReq, true, NewAttribute );


#############################################################################
##
#O  ExternalOrbitsStabilizers( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  ExternalOrbitsStabilizers( <xset> )
##
##  In addition to `ExternalOrbits', this operation also computes the
##  stabilizers of the representatives of the external orbits at the same
##  time. (This can be quicker than computing the `ExternalOrbits' first and
##  the stabilizers afterwards.)
##
OrbitsishOperation( "ExternalOrbitsStabilizers", OrbitsishReq,
    true, NewAttribute );


#############################################################################
##
#O  Transitivity( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  Transitivity( <xset> )
##
##  An action is $k$-transitive if every $k$-tuple of points can be
##  mapped simultaneously to every other $k$-tuple.
##
OrbitsishOperation( "Transitivity", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  Blocks( <G>, <Omega>[, <seed>][, <gens>, <acts>][, <act>] )
#A  Blocks( <xset>[, <seed>] )
##
##  computes a block system for the action. If
##  <seed> is not given and the action is imprimitive, a minimal nontrivial
##  block system will be found.
##  If <seed> is given, a block system in which <seed>
##  is the subset of one block is computed.
##  The action must be transitive.
##
DeclareAttribute( "BlocksAttr", IsExternalSet );

OrbitishFO( "Blocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, BlocksAttr );


#############################################################################
##
#O  MaximalBlocks( <G>, <Omega> [,<seed>] [,<gens>,<acts>] [,<act>] )
#A  MaximalBlocks( <xset> [,<seed>] )
##
##  returns a block system that is maximal with respect to inclusion.
##  maximal with respect to inclusion) for the action of <G> on <Omega>.
##  If <seed> is given, a block system in which <seed>
##  is the subset of one block is computed.
##
DeclareAttribute( "MaximalBlocksAttr", IsExternalSet );

OrbitishFO( "MaximalBlocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, MaximalBlocksAttr );

#T  the following syntax would be nice for consistency as well:
##  RepresentativesMinimalBlocks(<G>,<Omega>[,<seed>][,<gens>,<acts>][,<act>])
##  RepresentativesMinimalBlocks( <xset>, <seed> )

#############################################################################
##
#O  RepresentativesMinimalBlocks(<G>,<Omega>[,<gens>,<acts>][,<act>])
#A  RepresentativesMinimalBlocks( <xset> )
##
##  computes a list of block representatives for all minimal (i.e blocks are
##  minimal with respect to inclusion) nontrivial block systems for the
##  action. 
##
DeclareAttribute( "RepresentativesMinimalBlocksAttr", IsExternalSet );

OrbitishFO( "RepresentativesMinimalBlocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, RepresentativesMinimalBlocksAttr );


#############################################################################
##
#O  Earns( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  Earns( <xset> )
##
##  returns a list of the elementary abelian regular (when acting on <Omega>)
##  normal subgroups of <G>.
##
OrbitsishOperation( "Earns", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  IsTransitive( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsTransitive( <xset> )
##
##  An action is transitive if the whole domain forms one orbit.
##
OrbitsishOperation( "IsTransitive", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  IsPrimitive( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsPrimitive( <xset> )
##
##  An action is primitive  if it is transitive and no nontrivial block
##  systems are permissible. See~"Block Systems".
##
OrbitsishOperation( "IsPrimitive", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  IsPrimitiveAffine( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsPrimitiveAffine( <xset> )
##
OrbitsishOperation( "IsPrimitiveAffine", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  IsSemiRegular( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsSemiRegular( <xset> )
##
##  An action is semiregular is the stabilizer of each point is the
##  identity.
##
OrbitsishOperation( "IsSemiRegular", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  IsRegular( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#P  IsRegular( <xset> )
##
##  An action is regular if it is semiregular (see `IsSemiRegular') and
##  transitive. In this case every point <pnt> of <Omega> defines a one to one
##  correspondence between <G> and <Omega>.
##
OrbitsishOperation( "IsRegular", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  RankAction( <G>, <Omega>[, <gens>, <acts>][, <act>] )
#A  RankAction( <xset> )
##
##  The rank of a transitive action is the number of orbits of
##  the point stabilizer.
##
OrbitsishOperation( "RankAction", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#F  Permutation( <g>, <Omega>[, <gens>, <acts>][, <act>] )
#F  Permutation( <g>, <xset> )
##
##  computes the permutation that corresponds to the action of <g> on the
##  domain <Omega> or the `UnderlyingDomain' value of the external set
##  <xset>, respectively.
##  If <g> does not leave the domain invariant, or does not map injectively,
##  `fail' is returned.
##
DeclareGlobalFunction( "Permutation" );

DeclareOperation( "PermutationOp", [ IsObject, IsList, IsFunction ] );


#############################################################################
##
#O  PermutationCycle( <g>, <Omega>, <pnt> [,<act>] )
##
##  computes the permutation that represents the cycle of <pnt> under the
##  action of the elemnt <g>
##
DeclareGlobalFunction( "PermutationCycle" );

DeclareOperation( "PermutationCycleOp",
    [ IsObject, IsList, IsObject, IsFunction ] );


#############################################################################
##
#O  Cycle( <g>, <Omega>, <pnt> [,<act>] )
##
##  returns a list of the points in the cycle of <pnt> under the action of the
##  element <g>.
##
DeclareGlobalFunction( "Cycle" );

DeclareOperation( "CycleOp", [ IsObject, IsList, IsObject, IsFunction ] );


#############################################################################
##
#O  Cycles( <g>, <Omega> [,<act>] )
##
##  returns a list of the cycles (as lists of points) of the action of the
##  element <g>.
##
DeclareGlobalFunction( "Cycles" );

DeclareOperation( "CyclesOp", [ IsObject, IsList, IsFunction ] );


#############################################################################
##
#O  CycleLength( <g>, <Omega>, <pnt> [,<act>] )
##
##  returns the length of the cycle of <pnt> under the action of the element
##  <g>.
##
DeclareGlobalFunction( "CycleLength" );

DeclareOperation( "CycleLengthOp",
    [ IsObject, IsList, IsObject, IsFunction ] );


#############################################################################
##
#O  CycleLengths( <g>, <Omega>, [,<act>] )
##
##  returns the lengths of all the cycles under the action of the element
##  <g> on <Omega>.
##
DeclareGlobalFunction( "CycleLengths" );

DeclareOperation( "CycleLengthsOp",
    [ IsObject, IsList, IsFunction ] );


#############################################################################
##
#O  RepresentativeAction( <G> [,<Omega>], <d>, <e> [,<gens>,<acts>] [,<act>] )
##
##  computes an element of <G> that maps <d> to <e> under the given
##  action and returns `fail' if no such element exists.
##
DeclareGlobalFunction( "RepresentativeAction" );
DeclareOperation( "RepresentativeActionOp",
    [ IsGroup, IsList, IsObject, IsObject, IsFunction ] );
DeclareSynonym( "RepresentativeOperation",RepresentativeAction );
DeclareSynonym( "RepresentativeOperationOp",RepresentativeActionOp);


#############################################################################
##
#F  Stabilizer( <G> [,<Omega>], <pnt> [,<gens>,<acts>] [,<act>] )
##
##  computes the stabilizer in <G> of the point <pnt>, that is the subgroup
##  of those elements of <G> that fix <pnt>.
##  The stabilizer will have <G> as its parent.
##
DeclareGlobalFunction( "Stabilizer" );

OrbitishFO( "StabilizerFunc", OrbitishReq, IsCollsElms, false );
BindGlobal( "StabilizerOp", StabilizerFuncOp );


#############################################################################
##
#F  StabilizerPcgs( <pcgs>, <pnt> [,<acts>] [,<act>] )
##
##  computes the stabilizer in the group generated by <pcgs> of the point
##  <pnt>. If given, <acts> are elements by which <pcgs> acts, <act> is
##  the acting function. This function returns a pcgs for the stabilizer
##  which is induced by the `ParentPcgs' of <pcgs>, that is it is compatible
##  with <pcgs>.
##
DeclareGlobalFunction( "StabilizerPcgs" );

#############################################################################
##
#F  OrbitStabilizerAlgorithm( <G>, <Omega>, <blist>, <gens>,<acts>, <pntact> )
##
##  This operation should not be called by a user. It is documented however
##  for purposes to extend or maintain the group actions package.
##
##  `OrbitStabilizerAlgorithm' performs an orbit stabilizer algorithm for
##  the group <G> acting with the generators <gens> via the generator images
##  <gens> and the group action <act> on the element <pnt>. (For
##  technical reasons <pnt> and <act> are put in one record with components
##  `pnt' and `act' respectively.)
##
##  The argument <Omega> (which may be replaced by `false' to be ignored) is
##  the set within which the orbit is computed (once the orbit is the full
##  domain, the orbit calculation may stop).  If <blist> is given it must be
##  a bit list corresponding to <Omega> in which elements which have been found
##  already will be ``ticked off'' with `true'. (In particular, the entries
##  for the orbit of <pnt> still must be all set to `false'). Again the
##  remaining action domain (the bits set initially to `false') can be
##  used to stop if the orbit cannot grow any longer.
##  Another use of the bit list is if <Omega> is an enumerator which can
##  determine `PositionCanonical's very quickly. In this situation it can be
##  worth to search images not in the orbit found so far, but via their
##  position in <Omega> and use a the bit list to keep track whether the
##  element is in the orbit found so far.
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
#F  OnPoints( <pnt>, <g> )
##
##  \index{conjugation}\index{action!by conjugation}
##  returns `<pnt> ^ <g>'.
##  This is for example the action of a permutation group on points,
##  or the action of a group on its elements via conjugation.
##  The action of a matrix group on vectors from the right is described by
##  both `OnPoints' and `OnRight' (see~"OnRight").

# DeclareGlobalFunction("OnPoints");

#############################################################################
##
#F  OnRight( <pnt>, <g> )
##
##  returns `<pnt> \* <g>'.
##  This is for example the action of a group on its elements via right
##  multiplication,
##  or the action of a group on the cosets of a subgroup.
##  The action of a matrix group on vectors from the right is described by
##  both `OnPoints' (see~"OnPoints") and `OnRight'.

# DeclareGlobalFunction("OnRight");

#############################################################################
##
#F  OnLeftInverse( <pnt>, <g> )
##
##  returns $<g>^{-1}$ `\* <pnt>'.
##  Forming the inverse is necessary to make this a proper action,
##  as in {\GAP} groups always act from the right.
##
##  (`OnLeftInverse' is used for example in the representation of a right
##  coset as an external set (see~"External Sets"), that is a right coset
##  $Ug$ is an external set for the group $U$ acting on it via
##  `OnLeftInverse'.)

# DeclareGlobalFunction("OnLeftInverse");

#############################################################################
##
#F  OnSets( <set>, <g> )
##
##  \index{action!on sets}\index{action!on blocks}
##  Let <set> be a proper set (see~"Sorted Lists and Sets").
##  `OnSets' returns the proper set formed by the images
##  `OnPoints( <pnt>, <g> )' of all points <pnt> of <set>.
##
##  `OnSets' is for example used to compute the action of a permutation group
##  on blocks.
##
##  (`OnTuples' is an action on lists that preserves the ordering of entries,
##  see~"OnTuples".)

# DeclareGlobalFunction("OnSets");

#############################################################################
##
#F  OnTuples( <tup>, <g> )
##
##  Let <tup> be a list.
##  `OnTuples' returns the list formed by the images
##  `OnPoints( <pnt>, <g> )' for all points <pnt> of <tup>.
##
##  (`OnSets' is an action on lists that additionally sorts the entries of
##  the result, see~"OnSets".)

# DeclareGlobalFunction("OnTuples");


#############################################################################
##
#F  OnPairs( <tup>, <g> )
##
##  is a special case of `OnTuples' (see~"OnTuples") for lists <tup>
##  of length 2.

# DeclareGlobalFunction("OnPairs");


#############################################################################
##
#F  OnLines( <vec>, <g> )
##
##  Let <vec> be a *normed* row vector, that is,
##  its first nonzero entry is normed to the identity of the relevant field,
##  `OnLines' returns the row vector obtained from normalizing
##  `OnRight( <vec>, <g> )' by scalar multiplication from the left.
##  This action corresponds to the projective action of a matrix group
##  on 1-dimensional subspaces.
##
DeclareGlobalFunction("OnLines");


#############################################################################
##
#F  OnSetsSets( <set>, <g> )
##
##  Action on sets of sets;
##  for the special case that the sets are pairwise disjoint,
##  it is possible to use `OnSetsDisjointSets' (see~"OnSetsDisjointSets").
##
DeclareGlobalFunction( "OnSetsSets" );


#############################################################################
##
#F  OnSetsDisjointSets( <set>, <g> )
##
##  Action on sets of pairwise disjoint sets (see also~"OnSetsSets").
##
DeclareGlobalFunction( "OnSetsDisjointSets" );


#############################################################################
##
#F  OnSetsTuples( <set>, <g> )
##
##  Action on sets of tuples.
##
DeclareGlobalFunction("OnSetsTuples");


#############################################################################
##
#F  OnTuplesSets( <set>, <g> )
##
##  Action on tuples of sets.
##
DeclareGlobalFunction("OnTuplesSets");


#############################################################################
##
#F  OnTuplesTuples( <set>, <g> )
##
##  Action on tuples of tuples
##
DeclareGlobalFunction("OnTuplesTuples");

#############################################################################
##
#O  DomainForAction( <pnt>, <acts> )
##
##  returns a domain which will contain the orbit of <pnt> under the group
##  generated by <acts>. (Such a domain can be helpful for obtaining 
##  a dictionary.)
##  The default method returns `fail' to indicate that no special domain is
##  defined, a special method exists for matrix groups over finite fields.
##
DeclareOperation("DomainForAction",[IsObject,IsListOrCollection]);


#############################################################################
##
#E

