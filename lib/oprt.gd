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

DeclareInfoClass( "InfoOperation" );

#############################################################################
##
#A  MovedPoints( <G> ). . . . . . . . . . . . . . . .  of a permutation group
##
##  returns a list of the points moved by the permutation group <G>.
DeclareAttribute( "MovedPoints", IsPermGroup );

#############################################################################
##
#C  IsExternalSet(<obj>)
##
##  An *external set*  specifies an operation <opr>:  <D> x <G> --> <D>  of a
##  group <G> on a domain <D>. The external set knows the group, the
##  domain and the actual operation function.
##  Mathematically,  an external set  is the set~<D>,  which is endowed with
##  the group operation <opr>, and for this reason {\GAP} treats external sets
##  as a domain whose elements are the  elements of <D>. An external set is
##  always a union of orbits.
##  Currently the domain~<D> must always be finite.
##  If <D> is not a list, an enumerator for <D> is automatically chosen.
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
#R  IsExternalSubset . . . . . . . . . . . representation of external subsets
##
##  An external subset is the restriction  of an external  set to a subset of
##  the domain. It is again an external set.
##
DeclareRepresentation( "IsExternalSubset",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "start" ] );                            

#############################################################################
##
#R  IsExternalOrbit  . . . . . . . . . . .  representation of external orbits
##
##  An external orbit is an external subset consisting of one orbit.
##
DeclareRepresentation( "IsExternalOrbit",
    IsExternalSubset, [ "start" ] );
DeclareCategory( "IsExternalSetByPcgs", IsExternalSet );

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
##  via <gens> and <oprs> (`IsExternalSetByOperatorsRep').
##
DeclareRepresentation( "IsExternalSetDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [  ] );
DeclareRepresentation( "IsExternalSetByOperatorsRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "generators", "operators", "funcOperation" ] );

#############################################################################
##
#A  ActingDomain( <xset> )  . . . . . . . . . . . . . . . . . . the group <G>
##
##  This attributs returns the group with which the external set <xset> was
##  defined.
DeclareAttribute( "ActingDomain", IsExternalSet );

#############################################################################
##
#A  HomeEnumerator( <xset> )  . . . . . . .  the enumerator of the domain <D>
##
##  returns an enumerator of the domain <D> with which <xset> was defined.
##  For external   subsets, this is  different  from `Enumerator(  <xset> )',
##  which enumerates the union of orbits.
##
DeclareAttribute( "HomeEnumerator", IsExternalSet );



DeclareRepresentation( "IsOperationHomomorphism",
    IsGroupHomomorphism and
    IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
    IsAttributeStoringRep, [  ] );

DeclareRepresentation( "IsOperationHomomorphismDirectly",
      IsOperationHomomorphism,
      [  ] );
DeclareRepresentation( "IsOperationHomomorphismByOperators",
      IsOperationHomomorphism,
      [  ] );
DeclareRepresentation( "IsOperationHomomorphismSubset",
      IsOperationHomomorphism,
      [  ] );

#############################################################################
##
#R  IsOperationHomomorphismByBase(<obj>)
##
##  This is chosen if `HasBaseOfGroup( <xset> )'.
##
DeclareRepresentation( 
  "IsOperationHomomorphismByBase",
      IsOperationHomomorphism, [  ] );

#############################################################################
##
#R  IsConstituentHomomorphism(<obj>)
##
DeclareRepresentation( "IsConstituentHomomorphism",
    IsOperationHomomorphismDirectly, [ "conperm" ] );

DeclareRepresentation( "IsBlocksHomomorphism",
    IsOperationHomomorphismDirectly, [ "reps" ] );

#############################################################################
##
#R  IsLinearOperationHomomorphism . . . . . . for operations of matrix groups
##
##  This   representation is chosen  for  operation homomorphisms from matrix
##  groups acting naturally on a set of vectors including the standard base.
##
DeclareRepresentation( "IsLinearOperationHomomorphism",
      IsOperationHomomorphismDirectly,
      [  ] );

#############################################################################
##
#A  FunctionOperation( <xset> )
##
##  the operation function <opr> of <xset>
DeclareAttribute( "FunctionOperation", IsExternalSet );

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
#A  CanonicalRepresentativeOfExternalSet( <xset> )  . . . . . . . . . . . . .
##
##  The canonical representative of an  external set may  only depend on <G>,
##  <D>, <opr> and (in the case of  external subsets) `Enumerator( <xset> )'.
##  It must not depend, e.g., on the representative of an external orbit.
##  {\GAP} does not know methods for every external set to compute a
##  canonical representative. See
##  `CanonicalRepresentativeDeterminatorOfExternalSet'.
##
DeclareAttribute( "CanonicalRepresentativeOfExternalSet", IsExternalSet );


#############################################################################
##
#A  CanonicalRepresentativeDeterminatorOfExternalSet( <xset> )
##
##  a CanonicalRepresentativeDeterminatorOfExternalSet is a function that
##  takes as arguments the acting group and the point. It returns a list
##  of length 3: [<canonrep>, <stabilizercanonrep>, <conjugatingelm>]. 
##  (List components 2 and 3 are optional and do not need to be bound.)
##  An external set is only guaranteed to be able to compute a canonical
##  representative if it has a
##  `CanonicalRepresentativeDeterminatorOfExternalSet'.
DeclareAttribute( "CanonicalRepresentativeDeterminatorOfExternalSet",
    IsExternalSet );

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
DeclareAttribute( "OperatorOfExternalSet",
                                 IsExternalSet );


#############################################################################
##
#F  OrbitsishFOA( <name>, <reqs>, <usetype>, <AorP> ) . orbits-like operation
##
##  is used to create operations like `Orbits'.
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
    local str, nname, propop, propat, func;

    # Create the operation.
    str:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( str, "Op" );
    propop := NewOperation( str, reqs );
    BIND_GLOBAL( str, propop );

    # Create the  attribute or property.
    str := SHALLOW_COPY_OBJ( name );
    if NewAorP = NewAttribute  then  APPEND_LIST_INTR( str, "Attr" );
                               else  APPEND_LIST_INTR( str, "Prop" );  fi;
    propat := NewAorP( str, IsExternalSet );
    BIND_GLOBAL( str, propat );
    nname:= "Set"; APPEND_LIST_INTR( nname, str );
    BIND_GLOBAL( nname, SETTER_FILTER( propat ) );
    nname:= "Has"; APPEND_LIST_INTR( nname, str );
    BIND_GLOBAL( nname, TESTER_FILTER( propat ) );

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
          if CanEasilyComputePcgs( G ) then
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

          if CanEasilyComputePcgs( G ) then
            gens:= Pcgs( G );
          else
            gens:= GeneratorsOfGroup( G );
          fi;
          oprs:= gens;

        fi;

        # Call the operation.
        return propop( G, D, gens, oprs, opr );
    end;
    BIND_GLOBAL( name, func );
end;


#############################################################################
##
#F  OrbitishFO( <name>, <reqs>, <famrel>, <usetype> ) .  orbit-like operation
##
##  is used to create operations like `Orbit'.
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

    local str, nname, orbish, func;
    
    # Create the operation.
    str:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( str, "Op" );
    orbish := NewOperation( str, reqs );
    BIND_GLOBAL( str, orbish );
    
    # Create the wrapper function.
    func := function( arg )
    local   G,  D,  pnt,  gens,  oprs,  opr,  xset,  p,  attrG,  result,le;
      
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
	  le:=Length(arg);
	  G := arg[ 1 ];
	  if IsFunction( arg[ le ] )  then
	      opr := arg[ le ];
	      le:=le-1;
	  else
	      opr := OnPoints;
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
	  pnt := arg[ p ];
	  if Length( arg ) > p + 1  then
	      gens := arg[ p + 1 ];
	      oprs := arg[ p + 2 ];
	  fi;
      else
	Error( "usage: ", name, "(<xset>,<pnt>)\n",
	      "or ", name, "(<G>[,<D>],<pnt>[,<gens>,<oprs>][,<opr>])" );
      fi;
      
      if not IsBound( gens )  then
	  if CanEasilyComputePcgs( G )  then  
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
  BIND_GLOBAL( name, func );
end;



#############################################################################
##
#O  OperationHomomorphism( <G>, <D> [,<opr>] [,"surjective"] )
#A  OperationHomomorphism( <xset> [,"surjective"] )
#A  OperationHomomorphism( <oprt> )
##
##  computes an homomorphism from <G> into the symmetric group on
##  `HomeEnumerator(<D>)' that gives the permutation action of <G> on <D>.
##  The third version (which is supported only for {\GAP}3 compatibility)
##  returns the operation homomorphism that belongs to a image
##  obtained via `Operation' (see "Operation").
##
##  The homomorphism returned by `OperationHomomorphism' usually is not
##  surjective (its `Range' is the full
##  symmetric group) to avoid unnecessary computation of the image. If the
##  optional string argument `"surjective"' is given a surjective
##  homomorphism is created.
DeclareGlobalFunction( "OperationHomomorphism" );
DeclareAttribute( "OperationHomomorphismAttr", IsExternalSet );
DeclareGlobalFunction( "OperationHomomorphismConstructor" );

#############################################################################
##
#A  SurjectiveOperationHomomorphismAttr( <xset> )
##
##  returns an operation homomorphism for <xset> which is surjective.
##  (As the `Image' has to be computed this may take substantially longer
##  than `OperationHomomorphism'.)
DeclareAttribute( "SurjectiveOperationHomomorphismAttr", IsExternalSet );

#############################################################################
##
#A  UnderlyingExternalSet( <ohom> ) . . . . . . . . . underlying external set
##
##  The underlying set of an operation homomorphism is the external set on
##  which it was defined.
DeclareAttribute( "UnderlyingExternalSet", IsOperationHomomorphism );

#############################################################################
##
#O  SparseOperationHomomorphism( <G>, <D>, <start> [,<gens>,<oprs>] [,<opr>] )
##
##  Computes the
##  `OperationHomomorphism(<G>,<dom>[,<gens>,<oprs>][,<opr>])', where <dom>
##  is the union of the orbits `Orbit(<G>,<pnt>[,<gens>,<oprs>][,<opr>])'
##  for all points <pnt> from <start>.
##
OrbitishFO( "SparseOperationHomomorphism", OrbitishReq,
               IsIdenticalObj, false );

DeclareGlobalFunction(
    "OperationHomomorphismSubsetAsGroupGeneralMappingByImages" );


#############################################################################
##
#O  Operation( <G>, <D> [,<opr>] )
#A  Operation( <xset> )
##
##  returns the image of `OperationHomomorphism' called with the same
##  parameters.
DeclareGlobalFunction( "Operation" );

#############################################################################
##
#O  ExternalSet( <G>, <D> [,<gens>,<oprs>] [,<opr>] )  construct external set
##
##  creates the external set for the operation <opr> of <G> on <D>.
##  <D> can
##  be either a proper set  or a domain which is represented as
##  described in "Domains" and "Collections". 
##
OrbitsishFOA( "ExternalSet", OrbitsishReq, false, NewAttribute );

DeclareGlobalFunction( "ExternalSetByFilterConstructor" );
DeclareGlobalFunction( "ExternalSetByTypeConstructor" );


#############################################################################
##
#O  ExternalSubset(<G>,<xset>,<start>,[<gens>,<oprs>,]<opr>)
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
#O  ExternalOrbit( <G>, <D>, <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . . .
##
##  constructs the external subset on the orbit of <pnt>. The
##  `Representative' of this external set is <pnt>.
##
OrbitishFO( "ExternalOrbit", OrbitishReq, IsCollsElms, true );


#############################################################################
##
#O  Orbit( <G>[,<D>], <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . .
##
##  The orbit of the point <pnt> is the list of all images of <pnt> under
##  the operation.
##
OrbitishFO( "Orbit", OrbitishReq, IsCollsElms, false );


#############################################################################
##
#O  Orbits( <G>, <D> [,<gens>,<oprs>] [,<opr>] )  . . . . . . . . . . . . . . .
#A  Orbits( <xset> )
##
##  returns a list of the orbits (given as lists) under the operation.
##
OrbitsishFOA( "Orbits", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  OrbitLength( <G>, <D>, <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . . . .
##
##  computes the length of the orbit of <pnt>.
##
OrbitishFO( "OrbitLength", OrbitishReq, IsCollsElms, false );


#############################################################################
##
#O  OrbitLengths( <G>, <D>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . .
#A  OrbitLengths( <xset> )
##
##  computes the lengths of the orbits.
##
OrbitsishFOA( "OrbitLengths", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  OrbitStabilizer( <G>, [<D>,] <pnt>, [<gens>,<oprs>,] <opr> )
##
##  computes the orbit and the stabilizer of <pnt> in one Orbit-Stabilizer
##  algorithm.
##  The stabilizer must have <G> as its parent.
##
OrbitishFO( "OrbitStabilizer", OrbitishReq, IsCollsElms, false );


#############################################################################
##
#O  ExternalOrbits( <G>, <D>, [<gens>,<oprs>,] <opr> )
#A  ExternalOrbits( <xset> )
##
##  computes a list of `ExternalOrbit's that give the orbits of <G>.
##
OrbitsishFOA( "ExternalOrbits", OrbitsishReq, true, NewAttribute );


#############################################################################
##
#O  ExternalOrbitsStabilizers( <G>, <D>, [<gens>,<oprs>,] <opr> ) . . . . . .
#A  ExternalOrbitsStabilizers( <xset> )
##
##  In addition to `ExternalOrbits' also computes the stabilizers of the
##  representatives of the external orbits.
##
OrbitsishFOA( "ExternalOrbitsStabilizers", OrbitsishReq,
               true, NewAttribute );


#############################################################################
##
#O  Transitivity( <G>, <D>, [<gens>,<oprs>,] <opr> )  . . . . . . . . . . . .
#A  Transitivity( <xset> )
##
##  An operation is $k$-transitive if every $k$-tuple of points can be
##  mapped simultaneously to every other $k$-tuple.
##
OrbitsishFOA( "Transitivity", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#O  Blocks( <G>, <D> [,<seed>] [,<gens>,<oprs>] [,<opr>] )
#A  Blocks( <xset> [,<seed>] )
##
##  computes a block system (system of imprimitivity) for the operation. If
##  <seed> is not given an the operation is imprimitive, a minimal nontrivial
##  block system will be found.
##  If <seed> is given a block system in which <seed>
##  is the subset of one block is computed.
##  The operation must be transitive.
##
DeclareAttribute( "BlocksAttr", IsExternalSet );

OrbitishFO( "Blocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, BlocksAttr );


#############################################################################
##
#O  MaximalBlocks( <G>, <D> [,<seed>] [,<gens>,<oprs>] [,<opr>] )
#A  MaximalBlocks( <xset> [,<seed>] )
##
##  computes a list of block representatives for all maximal (i.e blocks are
##  maximal with respect to inclusion) nontrivial block systems for the
##  operation. If <seed> is given, only block systems in which one block
##  contains <seed> are determined.
##
DeclareAttribute( "MaximalBlocksAttr", IsExternalSet );

OrbitishFO( "MaximalBlocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, MaximalBlocksAttr );


#############################################################################
##
#O  MinimalBlocks( <G>, <D> [,<seed>] [,<gens>,<oprs>] [,<opr>] )
#A  MinimalBlocks( <xset> [,<seed>] )
##
##  computes a list of block representatives for all minimal (i.e blocks are
##  minimal with respect to inclusion) nontrivial block systems for the
##  operation. If <seed> is given, only block systems in which one block
##  contains <seed> are determined.
##
DeclareAttribute( "MinimalBlocksAttr", IsExternalSet );

OrbitishFO( "MinimalBlocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ], IsIdenticalObj, MinimalBlocksAttr );


#############################################################################
##
#A  Earns( <G>, <D>, [<gens>,<oprs>,] <opr> )
##
OrbitsishFOA( "Earns", OrbitsishReq, false, NewAttribute );


#############################################################################
##
#P  IsTransitive( <G>, <D> [,<gens>,<oprs>] [,<opr>] )
##
##  An operation is transive if the whole domain forms one orbit.
##
OrbitsishFOA( "IsTransitive", OrbitsishReq, false, NewProperty );


#############################################################################
##
#P  IsPrimitive( <G>, <D>, [<gens>,<oprs>,] <opr> )
##
##  An operation is primitive  if it is transitive and no nontrivial block
##  systems are permissible.
##
OrbitsishFOA( "IsPrimitive", OrbitsishReq, false, NewProperty );


#############################################################################
##
#P  IsPrimitiveAffine( <G>, <D>, [<gens>,<oprs>,] <opr> )
##
OrbitsishFOA( "IsPrimitiveAffine", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  IsSemiRegular( <G>, <D> [,<gens>,<oprs>] [,<opr>] )
#P  IsSemiRegular( <xset> )
##
##  An operation is semiregular is the stabilizer of each point is the
##  identity.
##
OrbitsishFOA( "IsSemiRegular", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  IsRegular( <G>, <D> [,<gens>,<oprs>] [,<opr>] )
#P  IsRegular( <xset> )
##
##  An operation is regular if it is semiregular (see `IsSemiRegular') and
##  transitive. In this case every point <pnt> of <D> defines a one to one
##  correspondence between <G> and <D>.
##
OrbitsishFOA( "IsRegular", OrbitsishReq, false, NewProperty );


#############################################################################
##
#O  Permutation( <g>, <D> [,<gens>,<oprs>] [,<opr>] )
#A  Permutation( <g>, <xset> )
##
##  computes a permutation that corresponds to the action of <g> on the
##  domain (respectively the `UnderlyingDomain' of the external set).
##
DeclareGlobalFunction( "Permutation" );

DeclareOperation( "PermutationOp",
    [ IsObject, IsList, IsFunction ] );

#############################################################################
##
#O  PermutationCycle( <g>, <D>, <pnt> [,<opr>] ) . . . . . . .
##
##  computes the permutation that represents the cycle of <pnt> under the
##  action of the elemnt <g>
##
DeclareGlobalFunction( "PermutationCycle" );

DeclareOperation( "PermutationCycleOp",
    [ IsObject, IsList, IsObject, IsFunction ] );


#############################################################################
##
#O  Cycle( <g>, <D>, <pnt> [,<opr>] ) . . . . . . .
##
##  returns a list of the points in the cycle of <pnt> under the action of the
##  element <g>.
##
DeclareGlobalFunction( "Cycle" );

DeclareOperation( "CycleOp",
    [ IsObject, IsList, IsObject, IsFunction ] );


#############################################################################
##
#O  Cycles( <g>, <D> [,<opr>] )  . . . . . . . . . . . . . . .
##
##  returns a list of the cycles (as lists of points) of the action of the
##  element <g>.
##
DeclareGlobalFunction( "Cycles" );

DeclareOperation( "CyclesOp",
    [ IsObject, IsList, IsFunction ] );


#############################################################################
##
#O  CycleLength( <g>, <D>, <pnt> [,<opr>] ) . . . . . . .
##
##  returns the length of the cycle of <pnt> under the action of the element
##  <g>.
##
DeclareGlobalFunction( "CycleLength" );

DeclareOperation( "CycleLengthOp",
    [ IsObject, IsList, IsObject, IsFunction ] );


#############################################################################
##
#O  CycleLengths( <g>, <D>, [,<opr>] ) . . . . . . .
##
##  returns the lengths of the cycles under the action of the element
##  <g> on <D>.
##
DeclareGlobalFunction( "CycleLengths" );

DeclareOperation( "CycleLengthsOp",
    [ IsObject, IsList, IsFunction ] );


#############################################################################
##
#O  RepresentativeOperation( <G> [,<D>], <d>, <e> [,<gens>,<oprs>] [,<opr>] )
##
##  computes an element of <G> that maps <d> to <e> under the given
##  operation and returns `fail' if no such element exists.
##
DeclareGlobalFunction( "RepresentativeOperation" );

DeclareOperation( "RepresentativeOperationOp",
    [ IsGroup, IsList, IsObject, IsObject, IsFunction ] );


#############################################################################
##
#O  Stabilizer( <G> [,<D>] <pnt> [,<gens>,<oprs>] [,<opr>] ) . . . . . . . . . .
##
##  computes the stabilizer in <G> of the point <pnt>, that is the subgroup
##  of those elements of <G> that fix <pnt>.
##  The stabilizer will have <G> as its parent.
##
DeclareGlobalFunction( "Stabilizer" );

OrbitishFO( "StabilizerFunc", OrbitishReq, IsCollsElms, false );
BindGlobal( "StabilizerOp", StabilizerFuncOp );

#T DeclareGlobalFunction( "OperationOrbit" );
#T up to now no  function is installed

DeclareGlobalFunction( "OrbitByPosOp" );

DeclareGlobalFunction( "OrbitStabilizerByGenerators" );

DeclareGlobalFunction( "OrbitStabilizerListByGenerators" );

DeclareGlobalFunction( "SetCanonicalRepresentativeOfExternalOrbitByPcgs" );

DeclareGlobalFunction( "StabilizerOfBlockNC" );

#############################################################################
##
#O  OnPoints(<pnt>,<g>)
##
##  returns <pnt>`^'<g>. This is for example the action of a permutation group
##  on points, a matrix group on vectors or a group on its elements via
##  conjugation.

# DeclareGlobalFunction("OnPoints");

#############################################################################
##
#O  OnRight(<pnt>,<g>)
##
##  returns <pnt>`\*'<g>. This is for example the action of a group on its
##  elements via right multiplication or the action of a group on the cosets
##  of a subgroup.

# DeclareGlobalFunction("OnRight");

#############################################################################
##
#O  OnLeftInverse(<pnt>,<g>)
##
##  returns $<g>^{-1}$`\*'<pnt>. The inverse is necessary to make this a
##  proper opeartion as in {\GAP} groups always operate from the right.
##  This operation is used in the representation of a `RightCoset' as an
##  external set.

# DeclareGlobalFunction("OnLeftInverse");

#############################################################################
##
#O  OnSets(<set>,<g>)
##
##  <set> must be a set. This action returns the set formed by the images
##  `OnPoints(<pnt>,<g>)' for all points <pnt> of <set>. In contrast to
##  OnTuples the images are arranged in a set.

# DeclareGlobalFunction("OnSets");

#############################################################################
##
#O  OnTuples(<tup>,<g>)
##
##  <tup> must be a list. This action returns the list obtained by
##  `OnPoints(<pnt>,<g>)' for all points <pnt> of <tup>. In contrast to
##  OnSets the arrangement of the images is kept.

# DeclareGlobalFunction("OnTuples");


#############################################################################
##
#O  OnPairs(<tup>,<g>)
##
##  Is a special case of `OnTuples' for lists <tup> of length 2.

# DeclareGlobalFunction("OnPairs");

#############################################################################
##
#O  OnLines(<vec>,<g>)
##
##  <vec> must be a normed (that is its first nonzero entry is normed to one
##  of the relevant ring) row vector . This action returns the normed vector
##  <w> obtained from `OnRight(<vec>,<g>)'. This action corresponds to the
##  projective action of a matrix group on subspaces of dimension 1.
DeclareGlobalFunction("OnLines");

#############################################################################
##
#O  OnSetsSets(<set>,<g>)
##
##  Operation on sets of sets (sometimes called partitions).
DeclareGlobalFunction("OnSetsSets");

#############################################################################
##
#O  OnSetsTuples(<set>,<g>)
##
##  Operation on sets of tuples.
DeclareGlobalFunction("OnSetsTuples");

#############################################################################
##
#O  OnTuplesSets(<set>,<g>)
##
##  Operation on tuples of sets.
DeclareGlobalFunction("OnTuplesSets");

#############################################################################
##
#O  OnTuplesTuples(<set>,<g>)
##
##  Operation on tuples of tuples
DeclareGlobalFunction("OnTuplesTuples");


#############################################################################
##
#E  oprt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
