#############################################################################
##
#W  oprt.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.oprt_gd :=
    "@(#)$Id$";

InfoOperation := NewInfoClass( "InfoOperation" );

#############################################################################
##
#A  MovedPoints( <G> ). . . . . . . . . . . . . . . .  of a permutation group
##
##  returns a list of the points moved by the permutation group <G>.
MovedPoints := NewAttribute( "MovedPoints", IsPermGroup );
SetMovedPoints := Setter( MovedPoints );
HasMovedPoints := Tester( MovedPoints );

#############################################################################
##
#C  IsExternalSet . . . . . . . . . . . . . . . . . category of external sets
##
##  An *external set*  specifies an operation <opr>:  <D>  x <G>  --> <D>  of a
##  group <G> on a domain <D>. The external set knows the group, the
##  domain and the actual operation function.
##  Mathematically,  an external set  is the set~<D>,  which is endowed with
##  the group operation <opr>, and for this reason {\GAP} treats external sets
##  as a domain whose elements are the  elements of <D>. An external set is
##  always a union of orbits.
##  Currently the domain~<D> must always be finite.
##  If <D> is not a list, an enumerator for <D> is automatically chosen.
##
IsExternalSet := NewCategory( "IsExternalSet", IsDomain );

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
#R  IsExternalSubset . . . . . . . . . . . representation of external subsets
##
##  An external subset is the restriction  of an external  set to a subset of
##  the domain. It is again an external set.
##
IsExternalSubset := NewRepresentation( "IsExternalSubset",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "start" ] );                            

#############################################################################
##
#R  IsExternalOrbit  . . . . . . . . . . .  representation of external orbits
##
##  An external orbit is an external subset consisting of one orbit.
##
IsExternalOrbit := NewRepresentation( "IsExternalOrbit",
    IsExternalSubset, [ "start" ] );
IsExternalSetByPcgs := NewCategory( "IsExternalSetByPcgs", IsExternalSet );

# The following two integer variables give position in which the `Type' of an
# external set can  store the `Type' of its  external subsets resp.  external
# orbits (to avoid repeated calls of `NewType').
XSET_XSSETTYPE := 4;
XSET_XORBTYPE  := 5;

#############################################################################
##
#R  IsExternalSetDefaultRep . . . . . . . . . representation of external sets
#R  IsExternalSetByOperatorsRep . . . . . . . representation of external sets
##
##  External sets  can be specified  directly (`IsExternalSetDefaultRep'), or
##  via <gens> and <oprs> (`IsExternalSetByOperatorsRep') (see ref. manual).
##
IsExternalSetDefaultRep := NewRepresentation( "IsExternalSetDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [  ] );
IsExternalSetByOperatorsRep := NewRepresentation
  ( "IsExternalSetByOperatorsRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "generators", "operators", "funcOperation" ] );

#############################################################################
##
#A  ActingDomain( <xset> )  . . . . . . . . . . . . . . . . . . the group <G>
##
##  This attributs returns the group with which the external set <xset> was
##  defined.
ActingDomain := NewAttribute( "ActingDomain", IsExternalSet );
SetActingDomain := Setter( ActingDomain );
HasActingDomain := Tester( ActingDomain );

#############################################################################
##
#A  HomeEnumerator( <xset> )  . . . . . . .  the enumerator of the domain <D>
##
##  For external   subsets, this is  different  from `Enumerator(  <xset> )',
##  which enumerates the union of orbits.
##
HomeEnumerator := NewAttribute( "HomeEnumerator", IsExternalSet );
SetHomeEnumerator := Setter( HomeEnumerator );
HasHomeEnumerator := Tester( HomeEnumerator );



IsOperationHomomorphism := NewRepresentation( "IsOperationHomomorphism",
    IsGroupHomomorphism and
    IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
    IsAttributeStoringRep, [  ] );

IsOperationHomomorphismDirectly := NewRepresentation
    ( "IsOperationHomomorphismDirectly",
      IsOperationHomomorphism,
      [  ] );
IsOperationHomomorphismByOperators := NewRepresentation
    ( "IsOperationHomomorphismByOperators",
      IsOperationHomomorphism,
      [  ] );
IsOperationHomomorphismSubset := NewRepresentation
    ( "IsOperationHomomorphismSubset",
      IsOperationHomomorphism,
      [  ] );

#############################################################################
##
#R  IsOperationHomomorphismByBase() . .  if a base for the operation is known
##
##  This is chosen if `HasBase( <xset> )'.
##
IsOperationHomomorphismByBase := NewRepresentation
    ( "IsOperationHomomorphismByBase",
      IsOperationHomomorphism,
      [  ] );

IsConstituentHomomorphism := NewRepresentation( "IsConstituentHomomorphism",
    IsOperationHomomorphismDirectly, [ "conperm" ] );

IsBlocksHomomorphism := NewRepresentation( "IsBlocksHomomorphism",
    IsOperationHomomorphismDirectly, [ "reps" ] );

#############################################################################
##
#R  IsLinearOperationHomomorphism . . . . . . for operations of matrix groups
##
##  This   representation is chosen  for  operation homomorphisms from matrix
##  groups acting naturally on a set of vectors including the standard base.
##
IsLinearOperationHomomorphism := NewRepresentation
    ( "IsLinearOperationHomomorphism",
      IsOperationHomomorphismDirectly,
      [  ] );

#############################################################################
##
#A  FunctionOperation( <xset> ) . . . . . . . . . . . . .  the function <opr>
##
FunctionOperation := NewAttribute( "FunctionOperation", IsExternalSet );
SetFunctionOperation := Setter( FunctionOperation );
HasFunctionOperation := Tester( FunctionOperation );

#############################################################################
##
#A  StabilizerOfExternalSet( <xset> ) .  stabilizer of `Representative(xset)'
##
##  The stabilizer must have <G> as its parent.
##
StabilizerOfExternalSet := NewAttribute( "StabilizerOfExternalSet",
                                   IsExternalSet );
SetStabilizerOfExternalSet := Setter( StabilizerOfExternalSet );
HasStabilizerOfExternalSet := Tester( StabilizerOfExternalSet );

#############################################################################
##
#A  CanonicalRepresentativeOfExternalSet( <xset> )  . . . . . . . . . . . . .
##
##  The canonical representative of an  external set may  only depend on <G>,
##  <D>, <opr> and (in the case of  external subsets) `Enumerator( <xset> )'.
##  It must not depend, e.g., on the representative of an external orbit.
##
CanonicalRepresentativeOfExternalSet := NewAttribute
    ( "CanonicalRepresentativeOfExternalSet", IsExternalSet );
SetCanonicalRepresentativeOfExternalSet :=
  Setter( CanonicalRepresentativeOfExternalSet );
HasCanonicalRepresentativeOfExternalSet :=
  Tester( CanonicalRepresentativeOfExternalSet );

# a CanonicalRepresentativeDeterminatorOfExternalSet is a function that
# takes as arguments the acting group and the point. It returns a list
# of length 3: [CanonRep, NormalizerCanonRep, ConjugatingElm]. 
# list components 2 and 3 do not need to be bound.

CanonicalRepresentativeDeterminatorOfExternalSet := NewAttribute
    ( "CanonicalRepresentativeDeterminatorOfExternalSet", IsExternalSet );
SetCanonicalRepresentativeDeterminatorOfExternalSet :=
  Setter( CanonicalRepresentativeDeterminatorOfExternalSet );
HasCanonicalRepresentativeDeterminatorOfExternalSet :=
  Tester( CanonicalRepresentativeDeterminatorOfExternalSet );

# Xsets that know how to get a canonical representative should claim they
# have one for purposes of method selection
InstallTrueMethod(HasCanonicalRepresentativeOfExternalSet,
  HasCanonicalRepresentativeDeterminatorOfExternalSet);

#############################################################################
##
#A  OperatorOfExternalSet( <xset> ) . . . . . . . . . . . . . . . . . . . . .
##
##  an     element     mapping      `Representative(     <xset>    )'      to
##  `CanonicalRepresentativeOfExternalSet( <xset> ' under the given operation
##
OperatorOfExternalSet := NewAttribute( "OperatorOfExternalSet",
                                 IsExternalSet );
SetOperatorOfExternalSet := Setter( OperatorOfExternalSet );
HasOperatorOfExternalSet := Tester( OperatorOfExternalSet );


#############################################################################
##

#F  OrbitsishFOA( <name>, <reqs>, <usetype>, <AorP> ) . orbits-like operation
##
##  This function returns a list containing a wrapper function, an operation,
##  and an attribute resp. property.
##
##  The wrapper function, e.g., `Orbits( <arg>  )', can be called either as
##  `Orbits( <xset> )' for an external set <xset>, or as
##  `Orbits( <G>, <D>[, <gens>, <oprs>][, <opr>] )', with a group <G>, a
##  domain or list <D>, generators <gens> of <G>, and corresponding elements
##  <oprs> that act on <D> via <opr>;
##  the default of <gens> and <oprs> is te list of group generators of <G>,
##  the default of <opr> is `OnPoints'.
##
##  The operation has name `<name>Op', and its arguments are required to have
##  the filters in the list <reqs>.
##
##  The attribute resp. property has name `<name>Attr' resp. `<name>Prop',
##  it is used to store the result of the wrapper function when this is
##  called for an external set.
##
##  When the wrapper function is called, it computes the arguments for the
##  operation if necessary, and returns the return value of the operation.
##  If the Boolean <usetype> is `true' then the external set is used as an
##  argument instead of <D>, in order to enable the installation of methods
##  that use the type of external sets.
##
##  (It is also possible to call the wrapper function with only argument a
##  permutation group <G>, which is then interpreted as acting on its set
##  of moved points via `OnPoints'.
##  Also in this case, the attribute is used to store the result.)
##
OrbitsishFOA := function( name, reqs, usetype, NewAorP )
    local   str,  propop,  propat,  func;

    # Create the operation.
    str:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( str, "Op" );
    propop := NewOperation( str, reqs );

    # Create the  attribute or property.
    str := SHALLOW_COPY_OBJ( name );
    if NewAorP = NewAttribute  then  APPEND_LIST_INTR( str, "Attr" );
                               else  APPEND_LIST_INTR( str, "Prop" );  fi;
    propat := NewAorP( str, IsExternalSet );

    # Install a method for the attribute when called with an external set.
    InstallMethod( propat,
        "method for an external set",
        true,
        [ IsExternalSet ], 0,
        function( xset )
        local G, gens, oprs, opr;
        G := ActingDomain( xset );
        if IsExternalSetByOperatorsRep( xset )  then
          gens := xset!.generators;
          oprs := xset!.operators;
          opr  := xset!.funcOperation;
        else
          if IsPcgsComputable( G ) then
            gens := Pcgs( G );
          else
            gens := GeneratorsOfGroup( G );
          fi;
          oprs := gens;
          opr  := FunctionOperation( xset );
        fi;
        if usetype then
          return propop( G, xset, gens, oprs, opr );
        else
          return propop( G, Enumerator( xset ), gens, oprs, opr );
        fi;
        end );

    # Install a method for the attribute when called with a
    # permutation group.
    InstallOtherMethod( propat,
        "method for a permutation group",
        true,
        [ IsPermGroup ], 0,
        function( G )
        local gens;
        gens:= GeneratorsOfGroup( G );
        return propop( G, MovedPoints( G ), gens, gens, OnPoints );
        end );

    # Create the wrapper function.
    func := function( arg )

        local   G,  D,  opr,  gens,  oprs;

        # If there is only one argument, call the attribute.
        if Length( arg ) = 1 then
          return propat( arg[1] );
        elif 5 < Length( arg ) then
          Error( "usage: ", name, "(<xset>)\n",
                 "or ", name, "(<<G>,<D>[,<gens>,<oprs>][,<opr>])" );
        fi;

        # Get the arguments.
        G := arg[ 1 ];
        D := arg[ 2 ];
        if IsDomain( D )  then
          D := Enumerator( D );
        fi;
        if IsFunction( arg[ Length( arg ) ] )  then
          opr := arg[ Length( arg ) ];
        else
          opr := OnPoints;
        fi;
        if Length( arg ) > 3  then
          gens := arg[ 3 ];
          oprs := arg[ 4 ];
        else

          # In the case of a permutation group acting on its moved points,
          # use the attribute.
          if     IsPermGroup( G )
             and opr = OnPoints
             and HasMovedPoints( G )
             and D = MovedPoints( G ) then
            return propat( G );
          fi;

          if IsPcgsComputable( G ) then
            gens:= Pcgs( G );
          else
            gens:= GeneratorsOfGroup( G );
          fi;
          oprs:= gens;

        fi;

        # Call the operation.
        return propop( G, D, gens, oprs, opr );
    end;

    # Return the triple.
    return [ func, propop, propat ];
end;


#############################################################################
##
#F  OrbitishFO( <name>, <reqs>, <famrel>, <usetype> ) .  orbit-like operation
##
##  This function is analogous to `OrbitsishFOA', but for operations <orbish>
##  like `Orbit( <G>, <D>, <pnt> )'.
##  Since the return values of these operations depend on the  additional
##  argument <pnt>, there is no associated attribute.
##  The family relation <famrel> is required for the families of the 2nd and
##  3rd argument (e.g., `IsCollsElms' for `Orbit').
##
##  <usetype> can also be an attribute (`BlocksAttr' or `MaximalBlocksAttr').
##  In this case, if only one of the two arguments <D> and <pnt> is given,
##  blocks with no seed are computed, they are stored as attribute values
##  according to the rules of `OrbitsishFOA'.
##
OrbitishFO := function( name, reqs, famrel, usetype )

    local str, orbish, func;
    
    # Create the operation.
    str:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( str, "Op" );
    orbish := NewOperation( str, reqs );
    
    # Create the wrapper function.
    func := function( arg )
    local   G,  D,  pnt,  gens,  oprs,  opr,  xset,  p,  attrG,  result;
    
    # Get the arguments.
    if Length( arg ) = 2 and IsExternalSet( arg[ 1 ] )  then
        xset := arg[ 1 ];
        pnt := arg[ 2 ];
        G := ActingDomain( xset );
        if HasHomeEnumerator( xset )  then
            D := HomeEnumerator( xset );
        fi;
        if IsExternalSetByOperatorsRep( xset )  then
            gens := xset!.generators;
            oprs := xset!.operators;
            opr  := xset!.funcOperation;
        else
            opr := FunctionOperation( xset );
        fi;
    elif 2 <= Length( arg ) then
        G := arg[ 1 ];
        if     Length( arg ) > 2
           and famrel( FamilyObj( arg[ 2 ] ), FamilyObj( arg[ 3 ] ) )  then
            D := arg[ 2 ];
            if IsDomain( D )  then
                D := Enumerator( D );
            fi;
            p := 3;
        else
            p := 2;
        fi;
        pnt := arg[ p ];
        if Length( arg ) > p + 1  then
            gens := arg[ p + 1 ];
            oprs := arg[ p + 2 ];
        fi;
        if IsFunction( arg[ Length( arg ) ] )  then
            opr := arg[ Length( arg ) ];
        else
            opr := OnPoints;
        fi;
    else
      Error( "usage: ", name, "(<xset>,<pnt>)\n",
             "or ", name, "(<G>[,<D>],<pnt>[,<gens>,<oprs>][,<opr>])" );
    fi;
    
    if not IsBound( gens )  then
        if IsPcgsComputable( G )  then  
	  gens := Pcgs( G );
	else  
	  gens := GeneratorsOfGroup( G ); 
	fi;
        oprs := gens;
    fi;
    
    # In  the  case of `[Maximal]Blocks',  where  $G$  is a permutation group
    # acting on its moved points, use an attribute for $G$.
    attrG := IsOperation( usetype )
         and gens = oprs
         and opr = OnPoints
         and not IsBound( D )
         and HasMovedPoints( G )
         and pnt = MovedPoints( G );
    if attrG  and  IsBound( xset )  and  Tester( usetype )( xset )  then
        result := usetype( xset );
    elif attrG  and  Tester( usetype )( G )  then
        result := usetype( G );
    elif usetype = true  and  IsBound( xset )  then
        result := orbish( G, xset, pnt, gens, oprs, opr );
    elif IsBound( D )  then
        result := orbish( G, D, pnt, gens, oprs, opr );
    else
        
        # The following line is also executed  when `Blocks(<G>, <D>, <opr>)'
        # is called to compute blocks with no  seed, but then <pnt> is really
        # <D>, i.e., the operation domain!
        result := orbish( G, pnt, gens, oprs, opr );
        
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

    # Return the pair.
    return [ func, orbish ];
end;




#############################################################################
##
#A  OperationHomomorphism( <xset> ) . homomorphism into S_{HomeEnumerator(D)}
#O  OperationHomomorphism( <G>, <D> [,<opr>] )
##
##  From an external set <xset> (for group <G> and domain <D>),
##  the function call 
##  `OperationHomomorphism( <xset> )' constructs
##  the permutation representation $<G> \to S_{|<D>|}$ of <G> by acting on
##  the external set <xset>. The mapping functions
##  for operation homomorphisms are described in section "Homomorphisms!for
##  groups". The version `OperationHomomorphism( <G>, <D>, <opr>)' serves as
##  shortcut for `OperationHomomorphism( ExternalSet( <G>, <D>, <opr> ) )'.

OperationHomomorphism := NewOperationArgs( "OperationHomomorphism" );
OperationHomomorphismAttr := NewAttribute( "OperationHomomorphism",
                                 IsExternalSet );
OperationHomomorphismConstructor := NewOperationArgs
                                    ( "OperationHomomorphismConstructor" );

#############################################################################
##
#A  SurjectiveOperationHomomorphism( <xset> ) .  surj. operation homomorphism
##
SurjectiveOperationHomomorphismAttr := NewAttribute
    ( "SurjectiveOperationHomomorphism", IsExternalSet );

#############################################################################
##
#A  UnderlyingExternalSet( <ohom> ) . . . . . . . . . underlying external set
##
##  The underlying set of an operation homomorphism is the external set on
##  which it was defined.
UnderlyingExternalSet := NewAttribute( "UnderlyingExternalSet",
                                 IsOperationHomomorphism );
SetUnderlyingExternalSet := Setter( UnderlyingExternalSet );
HasUnderlyingExternalSet := Tester( UnderlyingExternalSet );

#############################################################################
##
#O  SparseOperationHomomorphism( <G>, <D>, <start>, [<gens>,<oprs>,] <opr> )
##
tmp := OrbitishFO( "SparseOperationHomomorphism", OrbitishReq,
               IsIdentical, false );
SparseOperationHomomorphism   := tmp[1];
SparseOperationHomomorphismOp := tmp[2];

#############################################################################
##
#O  ExternalSet( <G>, <D> [,<gens>,<oprs>] [,<opr>] ) .  construct external set
##
##  creates the external set for the operation <opr> of <G> on <D>.
##  <D> can
##  be either a proper set (see "Sets") or a domain which is represented as
##  described in "Domains and Collections". <G> can be an arbitrary group,
##  and <opr> must be a {\GAP} function that takes two arguments (the first
##  from <D>, the second from <G>) and returns the an element of~<D>, namely
##  the image of the first argument under the second. This last argument
##  <opr> is always optional in operation functions, if it is not present,
##  the operation `OnPoints', which is defined as
##  `<opr>( <pnt>, <g> ) = <pnt> ^ <g>' is the default. 
##  If <gens> and  <oprs> are specified, <gens>  must be a generating set for
##  <G>, and the operation is $(d,gens[i]) -> opr(d,oprs[i])$. This can be
##  useful if a representation, in which the operation is easier describable
##  (for example a matrix representation) can be given for the generators, but
##  there is no easy way to decompose arbitrary elements in the generators.
##
tmp := OrbitsishFOA( "ExternalSet", OrbitsishReq, false, NewAttribute );
ExternalSet     := tmp[1];
ExternalSetOp   := tmp[2];
ExternalSetAttr := tmp[3];
ExternalSetByFilterConstructor := NewOperationArgs
                                  ( "ExternalSetByFilterConstructor" );
ExternalSetByTypeConstructor := NewOperationArgs
                                ( "ExternalSetByTypeConstructor" );

#############################################################################
##
#O  ExternalSubset( <G>, <xset>, <start>, [<gens>,<oprs>,] <opr> ) . . . . . . .
##
#T there must be a shorter syntax here!
##  constructs the external subset of <xset> on the union of orbits of <start>.
##
tmp := OrbitishFO( "ExternalSubset", 
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdentical, true );
ExternalSubset   := tmp[1];
ExternalSubsetOp := tmp[2];

#############################################################################
##
#O  ExternalOrbit( <G>, <D>, <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . . .
##
##  constructs the external subset on the orbit of <pnt>.
##
tmp := OrbitishFO( "ExternalOrbit", OrbitishReq, IsCollsElms, true );
ExternalOrbit   := tmp[1];
ExternalOrbitOp := tmp[2];

#############################################################################
##

#O  Orbit( <G>, <D>, <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . .
##
tmp := OrbitishFO( "Orbit", OrbitishReq, IsCollsElms, false );
Orbit   := tmp[1];
OrbitOp := tmp[2];

#############################################################################
##
#A  Orbits( <G>, <D>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . . . . .
##
tmp := OrbitsishFOA( "Orbits", OrbitsishReq, false, NewAttribute );
Orbits     := tmp[1];
OrbitsOp   := tmp[2];
OrbitsAttr := tmp[3];

#############################################################################
##
#O  OrbitLength( <G>, <D>, <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . . . .
##
tmp := OrbitishFO( "OrbitLength", OrbitishReq, IsCollsElms, false );
OrbitLength   := tmp[1];
OrbitLengthOp := tmp[2];

#############################################################################
##
#O  OrbitLengths( <G>, <D>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . .
##
tmp := OrbitsishFOA( "OrbitLengths", OrbitsishReq, false, NewAttribute );
OrbitLengths     := tmp[1];
OrbitLengthsOp   := tmp[2];
OrbitLengthsAttr := tmp[3];

#############################################################################
##
#O  OrbitStabilizer( <G>, <D>, <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . .
##
##  The stabilizer must have <G> as its parent.
##
tmp := OrbitishFO( "OrbitStabilizer", OrbitishReq, IsCollsElms, false );
OrbitStabilizer   := tmp[1];
OrbitStabilizerOp := tmp[2];

#############################################################################
##
#A  ExternalOrbits( <G>, <D>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . .
##
tmp := OrbitsishFOA( "ExternalOrbits", OrbitsishReq, true, NewAttribute );
ExternalOrbits     := tmp[1];
ExternalOrbitsOp   := tmp[2];
ExternalOrbitsAttr := tmp[3];

#############################################################################
##
#A  ExternalOrbitsStabilizers( <G>, <D>, [<gens>,<oprs>,] <opr> ) . . . . . .
##
tmp := OrbitsishFOA( "ExternalOrbitsStabilizers", OrbitsishReq,
               true, NewAttribute );
ExternalOrbitsStabilizers     := tmp[1];
ExternalOrbitsStabilizersOp   := tmp[2];
ExternalOrbitsStabilizersAttr := tmp[3];

#############################################################################
##
#A  Transitivity( <G>, <D>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . .
##
tmp := OrbitsishFOA( "Transitivity", OrbitsishReq, false, NewAttribute );
Transitivity     := tmp[1];
TransitivityOp   := tmp[2];
TransitivityAttr := tmp[3];

#############################################################################
##
#A  Blocks( <G>, <D>, <seed>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . .
##
BlocksAttr := NewAttribute( "BlocksAttr", IsExternalSet );
tmp := OrbitishFO( "Blocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdentical, BlocksAttr );
Blocks   := tmp[1];
BlocksOp := tmp[2];

#############################################################################
##
#A  MaximalBlocks( <G>, <D>, <seed>, [<gens>,<oprs>,] <opr> ) . . . . . . . .
##
MaximalBlocksAttr := NewAttribute( "MaximalBlocksAttr", IsExternalSet );
tmp := OrbitishFO( "MaximalBlocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdentical, MaximalBlocksAttr );
MaximalBlocks   := tmp[1];
MaximalBlocksOp := tmp[2];

#############################################################################
##
#A  MinimalBlocks( <G>, <D>, <seed>, [<gens>,<oprs>,] <opr> ) . . . . . . . .
##
MinimalBlocksAttr := NewAttribute( "MinimalBlocksAttr", IsExternalSet );
tmp := OrbitishFO( "MinimalBlocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdentical, MinimalBlocksAttr );
MinimalBlocks   := tmp[1];
MinimalBlocksOp := tmp[2];

#############################################################################
##
#A  Earns( <G>, <D>, [<gens>,<oprs>,] <opr> ) . . . . . . . . . . . . . . . .
##
tmp := OrbitsishFOA( "Earns", OrbitsishReq, false, NewAttribute );
Earns     := tmp[1];
EarnsOp   := tmp[2];
EarnsAttr := tmp[3];

#############################################################################
##

#P  IsTransitive( <G>, <D>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . .
##
tmp := OrbitsishFOA( "IsTransitive", OrbitsishReq, false, NewProperty );
IsTransitive     := tmp[1];
IsTransitiveOp   := tmp[2];
IsTransitiveProp := tmp[3];

#############################################################################
##
#P  IsPrimitive( <G>, <D>, [<gens>,<oprs>,] <opr> ) . . . . . . . . . . . . .
##
tmp := OrbitsishFOA( "IsPrimitive", OrbitsishReq, false, NewProperty );
IsPrimitive     := tmp[1];
IsPrimitiveOp   := tmp[2];
IsPrimitiveProp := tmp[3];

#############################################################################
##
#P  IsPrimitiveAffine( <G>, <D>, [<gens>,<oprs>,] <opr> ) . . . . . . . . . .
##
tmp := OrbitsishFOA( "IsPrimitiveAffine", OrbitsishReq, false, NewProperty );
IsPrimitiveAffine     := tmp[1];
IsPrimitiveAffineOp   := tmp[2];
IsPrimitiveAffineProp := tmp[3];

#############################################################################
##
#P  IsSemiRegular( <G>, <D>, [<gens>,<oprs>,] <opr> ) . . . . . . . . . . . .
##
tmp := OrbitsishFOA( "IsSemiRegular", OrbitsishReq, false, NewProperty );
IsSemiRegular     := tmp[1];
IsSemiRegularOp   := tmp[2];
IsSemiRegularProp := tmp[3];

#############################################################################
##
#P  IsRegular( <G>, <D>, [<gens>,<oprs>,] <opr> ) . . . . . . . . . . . . . .
##
tmp := OrbitsishFOA( "IsRegular", OrbitsishReq, false, NewProperty );
IsRegular     := tmp[1];
IsRegularOp   := tmp[2];
IsRegularProp := tmp[3];

#############################################################################
##

#O  Permutation( <g>, <D>, [<gens>,<oprs>,] <opr> ) . . . . . . . . . . . . .
##
Permutation := NewOperationArgs( "Permutation" );
PermutationOp := NewOperation( "Permutation",
    [ IsObject, IsList, IsFunction ] );

#############################################################################
##
#O  PermutationCycle( <g>, <D>, <pnt>, [<gens>,<oprs>,] <opr> ) . . . . . . .
##
PermutationCycle := NewOperationArgs( "PermutationCycle" );
PermutationCycleOp := NewOperation( "PermutationCycle",
    [ IsObject, IsList, IsObject, IsFunction ] );

#############################################################################
##
#O  Cycle( <g>, <D>, <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . .
##
Cycle := NewOperationArgs( "Cycle" );
CycleOp := NewOperation( "Cycle",
    [ IsObject, IsList, IsObject, IsFunction ] );

#############################################################################
##
#O  Cycles( <g>, <D>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . . . . .
##
Cycles := NewOperationArgs( "Cycles" );
CyclesOp := NewOperation( "Cycles",
    [ IsObject, IsList, IsFunction ] );

#############################################################################
##
#O  CycleLength( <g>, <D>, <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . . . .
##
CycleLength := NewOperationArgs( "CycleLength" );
CycleLengthOp := NewOperation( "CycleLength",
    [ IsObject, IsList, IsObject, IsFunction ] );

#############################################################################
##
#O  CycleLengths( <G>, <D>, <seed>, [<gens>,<oprs>,] <opr> )  . . . . . . . .
##
CycleLengths := NewOperationArgs( "CycleLengths" );
CycleLengthsOp := NewOperation( "CycleLengths",
    [ IsObject, IsList, IsFunction ] );

#############################################################################
##

#O  RepresentativeOperation( <G>, <D>, <d>, <e>, [<gens>,<oprs>,] <opr> ) . .
##
RepresentativeOperation := NewOperationArgs( "RepresentativeOperation" );
RepresentativeOperationOp := NewOperation( "RepresentativeOperation",
    [ IsGroup, IsList, IsObject, IsObject, IsFunction ] );

#############################################################################
##
#O  Stabilizer( <G>, <D>, <pnt>, [<gens>,<oprs>,] <opr> ) . . . . . . . . . .
##
##  The stabilizer must have <G> as its parent.
##
Stabilizer := NewOperationArgs( "Stabilizer" );
tmp := OrbitishFO( "StabilizerFunc", OrbitishReq, IsCollsElms, false );
StabilizerFunc := tmp[1];
StabilizerOp   := tmp[2];

OperationHomomorphismSubsetAsGroupGeneralMappingByImages := NewOperationArgs
    ( "OperationHomomorphismSubsetAsGroupGeneralMappingByImages" );
Operation := NewOperationArgs( "Operation" );
OperationOrbit := NewOperationArgs( "OperationOrbit" );
OrbitByPosOp := NewOperationArgs( "OrbitByPosOp" );
OrbitStabilizerByGenerators := NewOperationArgs
                               ( "OrbitStabilizerByGenerators" );
OrbitStabilizerListByGenerators := NewOperationArgs
                               ( "OrbitStabilizerListByGenerators" );
SetCanonicalRepresentativeOfExternalOrbitByPcgs :=
  NewOperationArgs( "SetCanonicalRepresentativeOfExternalOrbitByPcgs" );
StabilizerOfBlockNC := NewOperationArgs( "StabilizerOfBlockNC" );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##

#E  oprt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
