#############################################################################
##
#W  oprt.gi                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.oprt_gi :=
    "@(#)$Id$";

#############################################################################
##
#R  IsSubsetEnumerator  . . . . . . . . . . . . . . .  enumerator for subsets
##
DeclareRepresentation( "IsSubsetEnumerator",
    IsList and IsAttributeStoringRep,
    [ "homeEnumerator", "sublist" ] );

#############################################################################
##
#M  Length( <senum> ) . . . . . . . . . . . . . . . . .  for such enumerators
##
InstallMethod( Length,"subset enumerator", true, [ IsSubsetEnumerator ], 0,
    senum -> SizeBlist( senum!.sublist ) );

#############################################################################
##
#M  <senum>[ <num> ]  . . . . . . . . . . . . . . . . .  for such enumerators
##
InstallMethod( \[\],"subset enumerator", true, [ IsSubsetEnumerator, IsPosInt ], 0,
    function( senum, num )
    num := PositionNthTrueBlist( senum!.sublist, num );
    if num = fail  then  return fail;
                   else  return senum!.homeEnumerator[ num ];  fi;
end );

#############################################################################
##
#M  PositionCanonical( <senum>, <elm> ) . . . . . . . .  for such enumerators
##
InstallMethod( PositionCanonical,"subset enumerator", true,
  [ IsSubsetEnumerator, IsObject ], 0,
    function( senum, elm )
    local   pos;
    
    pos := PositionCanonical( senum!.homeEnumerator, elm );
    if pos = fail  or  not senum!.sublist[ pos ]  then
        return fail;
    else
        return SizeBlist( senum!.sublist{ [ 1 .. pos ] } );
    fi;
end );

#############################################################################
##
#M  AsList( <senum> ) . . . . . . . . . . . . . . . . .  for such enumerators
##
InstallMethod( AsList,"subset enumerator", true, [ IsSubsetEnumerator ], 0,
    senum -> senum!.homeEnumerator{ ListBlist
            ( [ 1 .. Length( senum!.homeEnumerator ) ], senum!.sublist ) } );

#############################################################################
##
#F  ExternalSet( <arg> )  . . . . . . . . . . . . .  external set constructor
##
InstallMethod( ExternalSet, "G, D, gens, acts, act", true, OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    return ExternalSetByFilterConstructor( IsExternalSet,
                   G, D, gens, acts, act );
end );


#############################################################################
##
#F  ExternalSetByFilterConstructor(<filter>,<G>,<D>,<gens>,<acts>,<act>)
##
InstallGlobalFunction( ExternalSetByFilterConstructor,
    function( filter, G, D, gens, acts, act )
    local   xset;

    xset := rec(  );
    if IsPcgs( gens )  then
        filter := filter and IsExternalSetByPcgs;
    fi;
    if not IsIdenticalObj( gens, acts )  then
        filter := filter and IsExternalSetByActorsRep;
        xset.generators    := gens;
        xset.operators     := acts;
        xset.funcOperation := act;
    else
        filter := filter and IsExternalSetDefaultRep;
    fi;

    # Catch the case that 'D' is an empty list.
    # (Note that an external set shall be a collection and not a list.)
    if IsList( D ) and IsEmpty( D ) then
      D:= EmptyRowVector( CyclotomicsFamily );
    fi;

    Objectify( NewType( FamilyObj( D ), filter ), xset );
    SetActingDomain  ( xset, G );
    SetHomeEnumerator( xset, D );
    if not IsExternalSetByActorsRep( xset )  then
        SetFunctionAction( xset, act );
    fi;
    return xset;
end );


#############################################################################
##
#F  ExternalSetByTypeConstructor(<type>,<G>,<D>,<gens>,<acts>,<act>)
##
# The following function expects the type as first argument,  to avoid a call
# of `NewType'. It is called by `ExternalSubsetOp' and `ExternalOrbitOp' when
# they are called with an external set (which has already stored this type).
#
InstallGlobalFunction( ExternalSetByTypeConstructor,
    function( type, G, D, gens, acts, act )
    local   xset;
    
    xset := Objectify( type, rec(  ) );
    if not IsIdenticalObj( gens, acts )  then
        xset!.generators    := gens;
        xset!.operators     := acts;
        xset!.funcOperation := act;
    fi;
    xset!.ActingDomain   := G;
    xset!.HomeEnumerator := D;
    if not IsExternalSetByActorsRep( xset )  then
        xset!.FunctionAction := act;
    fi;
    return xset;
end );

#############################################################################
##
#M  RestrictedExternalSet
##
InstallMethod(RestrictedExternalSet,"restrict the acting domain",
  true,[IsExternalSet,IsGroup],0,
function(xset,U)
local A,newx;
  A:=ActingDomain(xset);
  if IsSubset(U,A) then
    return xset; # no restriction happens
  fi;
  if IsBound(xset!.gens) then
    # we would have to decompose into generators
    TryNextMethod();
  fi;
  newx:=ExternalSet(U,HomeEnumerator(xset),FunctionAction(xset));
  return newx;
end);

#############################################################################
##
#M  Enumerator( <xset> )  . . . . . . . . . . . . . . . .  the underlying set
##
InstallMethod( Enumerator,"external set -> HomeEnumerator", true,
  [ IsExternalSet ], 0, HomeEnumerator );

#############################################################################
##
#M  FunctionAction( <p>, <g> ) . . . . . . . . . . . .  acting function
##
InstallMethod( FunctionAction,"ExternalSetByActorsRep", true,
  [ IsExternalSetByActorsRep ], 0,
    xset -> function( p, g )
    local   D;
        D := Enumerator( xset );
        return D[ PositionCanonical( D, p ) ^
                  ( g ^ ActionHomomorphismAttr( xset ) ) ];
    end );

#############################################################################
##
#M  PrintObj( <xset> )  . . . . . . . . . . . . . . . . print an external set
##
InstallMethod( PrintObj,"External Set", true, [ IsExternalSet ], 0,
    function( xset )
    Print(HomeEnumerator( xset ));
end );

#############################################################################
##
#M  ViewObj( <xset> )  . . . . . . . . . . . . . . . . print an external set
##
InstallMethod( ViewObj,"External Set", true, [ IsExternalSet ], 0,
function( xset )
local he,i;
  if not HasHomeEnumerator(xset) then
    TryNextMethod();
  fi;
  Print("<xset:");
  he:=HomeEnumerator(xset);
  if Length(he)<15 then
    View(he);
  else
    Print("[");
    for i in [1..15] do
      View(he[i]);
      Print(",");
    od;
    Print(" ...]");
  fi;
  Print(">");
end );

#############################################################################
##
#M  Representative( <xset> )  . . . . . . . . . . first element in enumerator
##
InstallMethod( Representative,"External Set", true, [ IsExternalSet ], 0,
    xset -> Enumerator( xset )[ 1 ] );

#############################################################################
##
#F  ExternalSubset( <arg> ) . . . . . . . . . . . . .  external set on subset
##
InstallMethod( ExternalSubsetOp, "G, D, start, gens, acts, act", true,
        [ IsGroup, IsList, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, start, gens, acts, act )
    local   xset;
    
    xset := ExternalSetByFilterConstructor( IsExternalSubset,
                    G, D, gens, acts, act );
    xset!.start := Immutable( start );
    return xset;
end );

InstallOtherMethod( ExternalSubsetOp,
        "G, xset, start, gens, acts, act", true,
        [ IsGroup, IsExternalSet, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, xset, start, gens, acts, act )
    local   type,  xsset;

    type := TypeObj( xset );

    # The type of an external set can store the type of its external subsets,
    # to avoid repeated calls of `NewType'.
    if not IsBound( type![XSET_XSSETTYPE] )  then
        xsset := ExternalSetByFilterConstructor( IsExternalSubset,
                         G, HomeEnumerator( xset ), gens, acts, act );
        type![XSET_XSSETTYPE] := TypeObj( xsset );
    else
        xsset := ExternalSetByTypeConstructor( type![XSET_XSSETTYPE],
                         G, HomeEnumerator( xset ), gens, acts, act );
    fi;
    
    xsset!.start := Immutable( start );
    return xsset;
end );

InstallOtherMethod( ExternalSubsetOp,
        "G, start, gens, acts, act", true,
        [ IsGroup, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, start, gens, acts, act )
    return ExternalSubsetOp( G,
                   Concatenation( Orbits( G, start, gens, acts, act ) ),
                   start, gens, acts, act );
end );


#############################################################################
##
#M  ViewObj( <xset> ) . . . . . . . . . . . . . . . . .  for external subsets
##
InstallMethod( ViewObj, "for external subset", true,
    [ IsExternalSubset ], 0,
    function( xset )
    Print( xset!.start, "^G");
end );


#############################################################################
##
#M  PrintObj( <xset> )  . . . . . . . . . . . . . . . .  for external subsets
##
InstallMethod( PrintObj, "for external subset", true,
    [ IsExternalSubset ], 0,
    function( xset )
    Print( xset!.start, "^G < ", HomeEnumerator( xset ) );
end );
#T It seems to be necessary to distinguish representations
#T for a correct treatment of `PrintObj'.


#############################################################################
##
#M  Enumerator( <xset> )  . . . . . . . . . . . . . . .  for external subsets
##
InstallMethod( Enumerator,"for external subset with home enumerator", true,
  [ IsExternalSubset and HasHomeEnumerator], 0,
    function( xset )
    local   G,  henum,  gens,  acts,  act,  sublist,  pnt,  pos;
    
    henum := HomeEnumerator( xset );
    if IsPlistRep(henum) and not IsSSortedList(henum) then
      TryNextMethod(); # there is no reason to use the home enumerator
    fi;

    G := ActingDomain( xset );
    if IsExternalSetByActorsRep( xset )  then
        gens := xset!.generators;
        acts := xset!.operators;
        act  := xset!.funcOperation;
    else
        gens := GeneratorsOfGroup( G );
        acts := gens;
        act  := FunctionAction( xset );
    fi;
    sublist := BlistList( [ 1 .. Length( henum ) ], [  ] );
    for pnt  in xset!.start  do
        pos := PositionCanonical( henum, pnt );
        if not sublist[ pos ]  then
            OrbitByPosOp( G, henum, sublist, pos, pnt, gens, acts, act );
        fi;
    od;
    return Objectify( NewType( FamilyObj( henum ), IsSubsetEnumerator ),
        rec( homeEnumerator := henum,
                    sublist := sublist ) );
end );

InstallMethod( Enumerator,"for external orbit: compute orbit", true,
  [ IsExternalOrbit ], 0,
function( xset )
  if HasHomeEnumerator(xset) and not IsPlistRep(HomeEnumerator(xset)) then
    TryNextMethod(); # can't do orbit because the home enumerator might
    # imply a different `PositionCanonical' (and thus equivalence of objects)
    # method.
  fi;
  return Orbit(xset,Representative(xset));
end);

#############################################################################
##
#F  ExternalOrbit( <arg> )  . . . . . . . . . . . . . . external set on orbit
##
InstallMethod( ExternalOrbitOp, "G, D, pnt, gens, acts, act", true,
        OrbitishReq, 0,
    function( G, D, pnt, gens, acts, act )
    local   xorb;
    
    xorb := ExternalSetByFilterConstructor( IsExternalOrbit,
                    G, D, gens, acts, act );
    SetRepresentative( xorb, pnt );
    xorb!.start := Immutable( [ pnt ] );
    return xorb;
end );

InstallOtherMethod( ExternalOrbitOp,
        "G, xset, pnt, gens, acts, act", true,
        [ IsGroup, IsExternalSet, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, xset, pnt, gens, acts, act )
    local   type,  xorb;

    type := TypeObj( xset );
    
    # The type of  an external set  can store the type  of external orbits of
    # its points, to avoid repeated calls of `NewType'.
    if not IsBound( type![XSET_XORBTYPE] )  then
        xorb := ExternalSetByFilterConstructor( IsExternalOrbit,
                        G, HomeEnumerator( xset ), gens, acts, act );
        type![XSET_XORBTYPE] := TypeObj( xorb );
    else
        xorb := ExternalSetByTypeConstructor( type![XSET_XORBTYPE],
                        G, HomeEnumerator( xset ), gens, acts, act );
    fi;
    
    SetRepresentative( xorb, pnt );
    xorb!.start := Immutable( [ pnt ] );
    return xorb;
end );

InstallOtherMethod( ExternalOrbitOp,
        "G, pnt, gens, acts, act", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, acts, act )
    return ExternalOrbitOp( G, OrbitOp( G, pnt, gens, acts, act ),
                   gens, acts, act );
end );


#############################################################################
##
#M  ViewObj( <xorb> ) . . . . . . . . . . . . . . . . . .  for external orbit
##
InstallMethod( ViewObj, "for external orbit", true,
    [ IsExternalOrbit ], 0,
    function( xorb )
    Print( Representative( xorb ), "^G");
end );


#############################################################################
##
#M  PrintObj( <xorb> )  . . . . . . . . . . . . . . . . .  for external orbit
##
InstallMethod( PrintObj, "for external orbit", true,
    [ IsExternalOrbit ], 0,
    function( xorb )
    Print( Representative( xorb ), "^G < ", HomeEnumerator( xorb ) );
end );
#T It seems to be necessary to distinguish representations
#T for a correct treatment of `PrintObj'.


#############################################################################
##
#M  AsList( <xorb> )  . . . . . . . . . . . . . . . . . .  by orbit algorithm
##
InstallMethod( AsList,"external orbit", true, [ IsExternalOrbit ], 0,
    xorb -> Orbit( xorb, Representative( xorb ) ) );

#############################################################################
##
#M  AsSSortedList( <xorb> )
##
InstallMethod( AsSSortedList,"external orbit", true, [ IsExternalOrbit ], 0,
    xorb -> Set(Orbit( xorb, Representative( xorb ) )) );

#############################################################################
##
#M  <xorb> = <yorb> . . . . . . . . . . . . . . . . . . by ``conjugacy'' test
##
InstallMethod( \=, "xorbs",IsIdenticalObj,
  [ IsExternalOrbit, IsExternalOrbit ], 0,
function( xorb, yorb )
  if not IsIdenticalObj(ActingDomain     (xorb),ActingDomain     (yorb))
  or not IsIdenticalObj(FunctionAction(xorb),FunctionAction(yorb))
      then
      TryNextMethod();
  fi;
  return RepresentativeAction( xorb, Representative( xorb ),
		  Representative( yorb ) ) <> fail;
end );

#############################################################################
##
#M  <xorb> < <yorb>
##
InstallMethod( \<, "xorbs, via AsSSortedList",IsIdenticalObj,
  [ IsExternalOrbit, IsExternalOrbit ], 0,
function( xorb, yorb )
  if not IsIdenticalObj(ActingDomain     (xorb),ActingDomain     (yorb))
  or not IsIdenticalObj(FunctionAction(xorb),FunctionAction(yorb))
      then
      TryNextMethod();
  fi;
  return AsSSortedList(xorb)<AsSSortedList(yorb);
end );

InstallMethod( \=, "xorbs which know their size", IsIdenticalObj,
  [ IsExternalOrbit and HasSize, IsExternalOrbit  and HasSize], 0,
function( xorb, yorb )
  if Size(xorb)<>Size(yorb) then
    return false;
  fi;
  if Size(xorb)>10 
  or not IsIdenticalObj(ActingDomain     (xorb),ActingDomain     (yorb))
  or not IsIdenticalObj(FunctionAction(xorb),FunctionAction(yorb))
      then
      TryNextMethod();
  fi;
  return Representative( xorb ) in AsList(yorb);
end );

InstallMethod( \=, "xorbs with canonicalRepresentativeDeterminator",
  IsIdenticalObj,
    [ IsExternalOrbit and HasCanonicalRepresentativeDeterminatorOfExternalSet,
      IsExternalOrbit and HasCanonicalRepresentativeDeterminatorOfExternalSet ],
        0,
    function( xorb, yorb )
    if not IsIdenticalObj(ActingDomain     (xorb),ActingDomain     (yorb))
    or not IsIdenticalObj(FunctionAction(xorb),FunctionAction(yorb))
       then
        TryNextMethod();
    fi;
    return CanonicalRepresentativeOfExternalSet( xorb ) =
           CanonicalRepresentativeOfExternalSet( yorb );
end );

# as this is not necessarily compatible with the global ordering, this
# method is disabled.
# #############################################################################
# ##
# #M  <xorb> < <yorb> . . . . . . . . . . . . . . . . .  by ``canon. rep'' test
# ##
# InstallMethod( \<,"xorbs with canonicalRepresentativeDeterminator",
#   IsIdenticalObj,
#     [ IsExternalOrbit and HasCanonicalRepresentativeDeterminatorOfExternalSet,
#       IsExternalOrbit and HasCanonicalRepresentativeDeterminatorOfExternalSet ],
#         0,
#     function( xorb, yorb )
#     if not IsIdenticalObj(ActingDomain     (xorb),ActingDomain     (yorb))
#     or not IsIdenticalObj(FunctionAction(xorb),FunctionAction(yorb))
#        then
#         TryNextMethod();
#     fi;
#     return CanonicalRepresentativeOfExternalSet( xorb ) <
#            CanonicalRepresentativeOfExternalSet( yorb );
# end );

#############################################################################
##
#M  <pnt> in <xorb> . . . . . . . . . . . . . . . . . . by ``conjugacy'' test
##
InstallMethod( \in,"very small xorbs: test in AsList", IsElmsColls,
  [ IsObject, IsExternalOrbit and HasSize], 0,
function( pnt, xorb )
  if Size(xorb)>10 then
    TryNextMethod();
  fi;
  return pnt in AsList(xorb);
end );

InstallMethod( \in,"xorb: RepresentativeAction", IsElmsColls,
  [ IsObject, IsExternalOrbit ], 0,
function( pnt, xorb )
  return RepresentativeAction( xorb, Representative( xorb ),
                   pnt ) <> fail;
end );

# if we keep a list we will often test the representative
InstallMethod( \in,"xset: Test representative equal", IsElmsColls, [ IsObject,
      IsExternalSet and HasRepresentative ], 
      10, #override even tests in element lists
function( pnt, xset )
  if Representative( xset ) = pnt  then
    return true;
  else
    TryNextMethod();
  fi;
end );

InstallMethod( \in, "xorb: HasEnumerator",IsElmsColls,
  [ IsObject, IsExternalOrbit and HasEnumerator ], 0,
function( pnt, xorb )
local   enum;
    enum := Enumerator( xorb );
    if IsConstantTimeAccessList( enum )  then  return pnt in enum;
                                         else  TryNextMethod();     fi;
end );

InstallMethod(\in,"xorb HasAsList",IsElmsColls,
  [ IsObject,IsExternalOrbit and HasAsList],
  1, # AsList should override Enumerator
function( pnt, xorb )
local  l;
  l := AsList( xorb );
  if IsConstantTimeAccessList( l )  then  return pnt in l;
					else  TryNextMethod();     fi;
end );

InstallMethod(\in,"xorb HasAsSSortedList",IsElmsColls,
  [ IsObject,IsExternalOrbit and HasAsSSortedList],
  2, # AsSSorrtedList should override AsList
function( pnt, xorb )
local  l;
  l := AsSSortedList( xorb );
  if IsConstantTimeAccessList( l )  then  return pnt in l;
					else  TryNextMethod();     fi;
end );

# this method should have a higher priority than the previous to avoid
# searches in vain.
InstallMethod( \in, "by CanonicalRepresentativeDeterminator", 
  IsElmsColls, [ IsObject,
        IsExternalOrbit and
	HasCanonicalRepresentativeDeterminatorOfExternalSet ], 1,
function( pnt, xorb )
local func;
  func:=CanonicalRepresentativeDeterminatorOfExternalSet(xorb);
  return CanonicalRepresentativeOfExternalSet( xorb ) = 
    func(ActingDomain(xorb),pnt)[1];
end );

#############################################################################
##
#M  ActionHomomorphism( <xset> ) . . . . . . . . .  action homomorphism
##
InstallGlobalFunction( ActionHomomorphism, function( arg )
    local   attr,  xset,  p;
    
    if arg[ Length( arg ) ] = "surjective"  then
        attr := SurjectiveActionHomomorphismAttr;
        Unbind( arg[ Length( arg ) ] );
    else
        attr := ActionHomomorphismAttr;
    fi;
    if Length( arg ) = 1  then
        xset := arg[ 1 ];
    elif     Length( arg ) = 2
         and IsComponentObjectRep( arg[ 2 ] )
         and IsBound( arg[ 2 ]!.actionHomomorphism )
         and IsActionHomomorphism( arg[ 2 ]!.actionHomomorphism )
         and Source( arg[ 2 ]!.actionHomomorphism ) = arg[ 1 ]  then
        return arg[ 2 ]!.actionHomomorphism;  # GAP-3 compatability
    else
        if IsFunction( arg[ Length( arg ) ] )  then  p := 1;
                                               else  p := 0;  fi;
        if Length( arg ) mod 2 = p  then
            xset := CallFuncList( ExternalSet, arg );
        elif IsIdenticalObj( FamilyObj( arg[ 2 ] ),
                          FamilyObj( arg[ 3 ] ) )  then
            xset := CallFuncList( ExternalSubset, arg );
        else
            xset := CallFuncList( ExternalOrbit, arg );
        fi;
    fi;
    return attr( xset );
end );


#############################################################################
##
#M  ActionHomomorphismConstructor( <xset>, <surj> )
##
InstallGlobalFunction( ActionHomomorphismConstructor,
    function( xset, surj )
    local   G,  D,  act,  fam,  filter,  hom,  i;
    
    G := ActingDomain( xset );
    D := HomeEnumerator( xset );
    act := FunctionAction( xset );
    fam := GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                  PermutationsFamily );
    if IsExternalSubset( xset )  then
        filter := IsActionHomomorphismSubset;
    else
        filter := IsActionHomomorphism;
    fi;

    hom := rec(  );
    if IsExternalSetByActorsRep( xset )  then
        filter := filter and IsActionHomomorphismByActors;
    elif     IsMatrixGroup( G )
         and not IsOneDimSubspacesTransversalRep( D )
         and IsScalarList( D[ 1 ] )
         and act in [ OnPoints, OnRight ]  then
      # we act linearly. This might be used to compute preimages by linear
      # algebra
      # note that we do not test whether the domain actually contains a
      # vector space base. This will be done the first time,
      # `LinearActionBasis' is called (i.e. in the preimages routine).
      filter := filter and IsLinearActionHomomorphism;

#        if     not IsExternalSubset( xset )
#           and IsDomainEnumerator( D )
#           and IsFreeLeftModule( UnderlyingCollection( D ) )
#           and IsFullRowModule( UnderlyingCollection( D ) )
#           and IsLeftActedOnByDivisionRing( UnderlyingCollection( D ) )  then
#            filter := filter and IsLinearActionHomomorphism;
#        else
#            if IsExternalSubset( xset )  then
#                if HasEnumerator( xset )  then  D := Enumerator( xset );
#                                          else  D := xset!.start;         fi;
#            fi;
#	    Error("hier");
#            if IsSubset( D, IdentityMat
#                       ( Length( D[ 1 ] ), One( D[ 1 ][ 1 ] ) ) )  then
#            fi;
#        fi;
    elif not IsExternalSubset( xset )
         and IsPermGroup( G )
         and IsList( D ) and IsCyclotomicCollection( D )
         and act = OnPoints  then
        filter := IsConstituentHomomorphism;
        hom.conperm := MappingPermListList( D, [ 1 .. Length( D ) ] );
    elif not IsExternalSubset( xset )
         and IsPermGroup( G )
         and IsList( D )
         and ForAll( D, IsList and IsSSortedList )
         and act = OnSets 
         and Sum( D, Length ) = Length( Union( D ) )
	 then
        filter := IsBlocksHomomorphism;
        hom.reps := [  ];
        for i  in [ 1 .. Length( D ) ]  do
            hom.reps{ D[ i ] } := i + 0 * D[ i ];
        od;

    # try to find under which circumstances we want to avoid computing
    # images by the action but always use the AsGHBI
    elif 
     # we can decompose into generators 
     (IsPermGroup( G )  or  IsPcGroup( G )) and
     # the action is not harmless
     not (act=OnPoints or act=OnSets or act=OnTuples)

     then
        filter := filter and
	  IsGroupGeneralMappingByAsGroupGeneralMappingByImages;
    fi;
    if HasBaseOfGroup( xset )  then
        filter := filter and IsActionHomomorphismByBase;
    fi;
    if surj  then
        filter := filter and IsSurjective;
    fi;
    Objectify( NewType( fam, filter ), hom );
    SetUnderlyingExternalSet( hom, xset );
    return hom;
end );

InstallMethod( ActionHomomorphismAttr,"call OpHomConstructor", true,
  [ IsExternalSet ], 0,
    xset -> ActionHomomorphismConstructor( xset, false ) );

#############################################################################
##
#M  SurjectiveActionHomomorphism( <xset> ) .  surj. action homomorphism
##
InstallMethod( SurjectiveActionHomomorphismAttr,
  "call Ac.Hom.Constructor", true, [ IsExternalSet ], 0,
   xset -> ActionHomomorphismConstructor( xset, true ) );


#############################################################################
##
#M  ViewObj( <hom> )  . . . . . . . . . . . .  view an action homomorphism
##
InstallMethod( ViewObj, "for action homomorphism", true,
    [ IsActionHomomorphism ], 0,
    function( hom )
    Print( "<action homomorphism>" );
end );


#############################################################################
##
#M  PrintObj( <hom> ) . . . . . . . . . . . . print an action homomorphism
##
InstallMethod( PrintObj, "for action homomorphism", true,
    [ IsActionHomomorphism ], 0,
    function( hom )
    Print( "<action homomorphism>" );
end );
#T It seems to be difficult to find out what I can use
#T for a correct treatment of `PrintObj'.


#############################################################################
##
#M  Source( <hom> ) . . . . . . . . . . . .  source of action homomorphism
##
InstallMethod( Source, "action homomorphism",true,
  [ IsActionHomomorphism ], 0,
        hom -> ActingDomain( UnderlyingExternalSet( hom ) ) );

#############################################################################
##
#M  Range( <hom> )  . . . . . . . . . . . . . range of action homomorphism
##
InstallMethod( Range,"ophom: S(domain)", true,
  [ IsActionHomomorphism ], 0, hom ->
    SymmetricGroup( Length( HomeEnumerator(UnderlyingExternalSet(hom)) ) ) );

InstallMethod( Range, "surjective action homomorphism",true,
  [ IsActionHomomorphism and IsSurjective ], 0,
    hom -> GroupByGenerators( List( GeneratorsOfGroup( Source( hom ) ),
            gen -> ImageElmActionHomomorphism( hom, gen ) ), () ) );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . .  for action homomorphism
##
InstallMethod( AsGroupGeneralMappingByImages, "IsActionHomomorphism",
  true, [ IsActionHomomorphism ], 0,
    function( hom )
    local   xset,  G,  D,  act,  gens,  imgs;
    
    xset := UnderlyingExternalSet( hom );
    G := ActingDomain( xset );
    D := HomeEnumerator( xset );
    act := FunctionAction( xset );
    gens := GeneratorsOfGroup( G );
    imgs := List( gens, o -> Permutation( o, D, act ) );
    return GroupHomomorphismByImagesNC( G, Range(hom), gens, imgs );
end );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . . . . . if given by operators
##
InstallMethod( AsGroupGeneralMappingByImages,
  "IsActionHomomorphismByActors",true,
        [ IsActionHomomorphismByActors ], 0,
    function( hom )
    local   xset,  G,  D,  act,  gens,  acts,  imgs;
    
    xset := UnderlyingExternalSet( hom );
    G := ActingDomain( xset );
    D := HomeEnumerator( xset );
    gens := xset!.generators;
    acts := xset!.operators;
    act  := xset!.funcOperation;
    imgs := List( acts, o -> Permutation( o, D, act ) );
    return GroupHomomorphismByImagesNC( G,
                   Range(hom), gens, imgs );
end );

#############################################################################
##
#M  RestrictedMapping(<ophom>,<U>)
##
InstallMethod(RestrictedMapping,"action homomorphism",
  CollFamSourceEqFamElms,[IsActionHomomorphism,IsGroup],0,
function(hom,U)
local xset,rest;

  xset:=RestrictedExternalSet(UnderlyingExternalSet(hom),U);
  rest:=ActionHomomorphismAttr( xset );

  if HasIsInjective(hom) and IsInjective(hom) then
    SetIsInjective(rest,true);
  fi;
  if HasIsTotal(hom) and IsTotal(hom) then
    SetIsTotal(rest,true);
  fi;

  return rest;
end);

##############################################################################
###
##F  ActionHomomorphismSubsetAsGroupGeneralMappingByImages( ... ) . . local
###
#InstallGlobalFunction( ActionHomomorphismSubsetAsGroupGeneralMappingByImages,
#    function
#    ( G, D, start, gens, acts, act )
#    local   list,  ps,  poss,  blist,  p,  i,  gen,  img,  pos,  imgs,  hom;
#    
#    list := [ 1 .. Length( D ) ];
#    poss := BlistList( list, List( start, b -> PositionCanonical( D, b ) ) );
#    blist := StructuralCopy( poss );
#    list := List( gens, gen -> ShallowCopy( list ) );
#    ps := Position( poss, true );
#    while ps <> fail  do
#        poss[ ps ] := false;
#        p := D[ ps ];
#        for i  in [ 1 .. Length( gens ) ]  do
#            gen := acts[ i ];
#            img := act( p, gen );
#            pos := PositionCanonical( D, img );
#            list[ i ][ ps ] := pos;
#            if not blist[ pos ]  then
#                poss[ pos ] := true;
#                blist[ pos ] := true;
#            fi;
#        od;
#        ps := Position( poss, true );
#    od;
#    imgs := List( list, PermList );
#    hom := GroupHomomorphismByImagesNC( G, Group( imgs,()),
#                   gens, imgs );
#    return hom;
#end );
#
##############################################################################
###
##M  AsGroupGeneralMappingByImages( <hom> )  . . . . . . . . . . . . . as GHBI
###
#InstallMethod(AsGroupGeneralMappingByImages,"IsActionHomomorphismSubset",
#  true,[ IsActionHomomorphismSubset ], 0,
#function( hom )
#local   xset,  G,  gens,ah;
#    
#    xset := UnderlyingExternalSet( hom );
#    G := ActingDomain( xset );
#    gens := GeneratorsOfGroup( G );
#    ah:=ActionHomomorphismSubsetAsGroupGeneralMappingByImages( G,
#           HomeEnumerator( xset ), xset!.start,
#           gens, gens, FunctionAction( xset ) );
#if Range(hom)<>Range(ah) or Source(hom)<>Source(ah) then
#  Error("ranges");
#fi;
#    return ah;
#end );
#
#InstallMethod( AsGroupGeneralMappingByImages,
#  "IsActionHomomorphismSubset and ByActors",true,
#        [ IsActionHomomorphismSubset
#      and IsActionHomomorphismByActors ], 0,
#    function( hom )
#    local   xset;
#
#    xset := UnderlyingExternalSet( hom );
#    return ActionHomomorphismSubsetAsGroupGeneralMappingByImages(
#           ActingDomain( xset ), HomeEnumerator( xset ), xset!.start,
#           xset!.generators, xset!.operators, xset!.funcOperation );
#end );

#############################################################################
##
#F  Action( <arg> )
##
InstallGlobalFunction( Action, function( arg )
    local   hom,  O;
    
    if not IsString(arg[Length(arg)]) then
      Add(arg,"surjective"); # enforce surjective action homomorphism -- we
                             # anyhow compute the image
    fi;
    hom := CallFuncList( ActionHomomorphism, arg );
    O := ImagesSource( hom );
    O!.actionHomomorphism := hom;
    return O;
end );

#############################################################################
##
#F  Orbit( <arg> )  . . . . . . . . . . . . . . . . . . . . . . . . . . orbit
##
InstallMethod( OrbitOp,
        "G, D, pnt, [ 1gen ], [ 1act ], act", true,
        OrbitishReq, 
	20, # we claim this method is very good
    function( G, D, pnt, gens, acts, act )
    if Length( acts ) <> 1  then  TryNextMethod();
                            else  return CycleOp( acts[ 1 ], D, pnt, act );
    fi;
end );

InstallOtherMethod( OrbitOp,
        "G, pnt, [ 1gen ], [ 1act ], act", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 
	  20, # we claim this method is very good
    function( G, pnt, gens, acts, act )
    if Length( acts ) <> 1  then  TryNextMethod();
                            else  return CycleOp( acts[ 1 ], pnt, act );  fi;
end );

InstallMethod( OrbitOp, "with domain", true, OrbitishReq,0,
function( G, D, pnt, gens, acts, act )
local orb,d,gen,i,p;
  d:=NewDictionary(pnt,false,D);
  orb := [ pnt ];
  AddDictionary(d,pnt);
  for p in orb do
    for gen in acts do
      i:=act(p,gen);
      if not KnowsDictionary(d,i) then
	Add( orb, i );
	AddDictionary(d,i);
      fi;
    od;
  od;
  return Immutable(orb);
end );


InstallOtherMethod( OrbitOp, "standard orbit algorithm:list", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
function( G, pnt, gens, acts, act )
local orb,d,gen,i,p,D;
  D:=DomainForAction(pnt,acts);
  d:=NewDictionary(pnt,false,D);
  orb := [ pnt ];
  AddDictionary(d,pnt);
  for p in orb do
    for gen in acts do
      i:=act(p,gen);
      if not KnowsDictionary(d,i) then
	Add( orb, i );
	AddDictionary(d,i);
      fi;
    od;
  od;
  return Immutable(orb);
end );

# all other orbit methods now become obsolete -- the dictionaries do the
# magic.

# InstallMethod( OrbitOp, "with quick position domain", true, [IsGroup,
#   IsList and IsQuickPositionList,IsObject,IsList,IsList,IsFunction],0,
# function( G, D, pnt, gens, acts, act )
#     return OrbitByPosOp( G, D, BlistList( [ 1 .. Length( D ) ], [  ] ),
#                    PositionCanonical( D, pnt ), pnt, gens, acts, act );
# end );

InstallGlobalFunction( OrbitByPosOp,
    function( G, D, blist, pos, pnt, gens, acts, act )
    local   orb,  p,  gen,  img;
    
    blist[ pos ] := true;
    orb := [ pnt ];
    for p  in orb  do
        for gen  in acts  do
            img := act( p, gen );
            pos := PositionCanonical( D, img );
            if not blist[ pos ]  then
                blist[ pos ] := true;
                Add( orb, img );
            fi;
        od;
    od;
    return Immutable( orb );
end );

#InstallOtherMethod( OrbitOp, "standard orbit algorithm:set", true,
#        [ IsGroup, IsObject,
#          IsList,
#          IsList,
#          IsFunction ],
#	  1,# we want this to be better than the following method
#function( G, pnt, gens, acts, act )
#local   orb,  p,  i,  gen,orbset,cansort;
#
#    #T this should be cleaner, probably by a filter whether comparison is
#    #T doable.
#
#    # catch cases in which we do not want to do a set of the elements
#    # because ordering is impossible or very expensive
#    if IsElementOfFpGroupCollection(pnt) # subgroups of fp group
#     then
#      TryNextMethod();
#    fi;
#
#    cansort:=CanEasilySortElements(pnt);
#    orb := [ pnt ];
#    if cansort then
#      orbset:=[pnt];
#    else
#      orbset:=orb;
#    fi;
#    for p  in orb  do
#        for gen  in acts  do
#            i := act( p, gen );
#            if not i in orbset  then
#                Add( orb, i );
#		if cansort then
#		  AddSet(orbset,i);
#		fi;
#            fi;
#        od;
#    od;
#    return Immutable( orbset );
#end );
#
#InstallOtherMethod( OrbitOp, "standard orbit algorithm:list", true,
#        [ IsGroup, IsObject,
#          IsList,
#          IsList,
#          IsFunction ], 0,
#function( G, pnt, gens, acts, act )
#local   orb,  p,  i,  gen;
#
#    orb := [ pnt ];
#    for p  in orb  do
#        for gen  in acts  do
#            i := act( p, gen );
#            if not i in orb  then
#                Add( orb, i );
#            fi;
#        od;
#    od;
#    return Immutable(orb);
#end );

#############################################################################
##
#F  OrbitStabilizer( <arg> )  . . . . . . . . . . . . .  orbit and stabilizer
##
InstallMethod( OrbitStabilizerOp, "`OrbitStabilizerAlgorithm' with domain",
        true, OrbitishReq, 0,
function( G, D, pnt, gens, acts, act )
local   orbstab;
  orbstab:=OrbitStabilizerAlgorithm(G,D,false,gens,acts,
                                    rec(pnt:=pnt,act:=act));
  return Immutable( orbstab );
end );
    
InstallOtherMethod( OrbitStabilizerOp, 
        "`OrbitStabilizerAlgorithm' without domain",true,
        [ IsGroup, IsObject, IsList, IsList, IsFunction ], 0,
function( G, pnt, gens, acts, act )
local   orbstab;
  orbstab:=OrbitStabilizerAlgorithm(G,false,false,gens,acts,
                                    rec(pnt:=pnt,act:=act));
  return Immutable( orbstab );
end );

InstallOtherMethod( OrbitStabilizerOp, 
  "`OrbitStabilizerAlgorithm' without domain, for FFE vectors and matrix list",
  true,[ IsGroup, IsFFECollection, IsList, IsFFECollCollColl, IsFunction ], 0,
function( G, pnt, gens, acts, act )
local   orbstab;
  if CollectionsFamily(CollectionsFamily(FamilyObj(pnt)))<>FamilyObj(acts) or
    (act<>OnPoints and act<>OnLines and act<>OnRight) then
    TryNextMethod(); # strange operation, might extend the domain
  fi;
  orbstab:=OrbitStabilizerAlgorithm(G,NaturalActedSpace(G,acts,[pnt]),false,
    gens,acts,rec(pnt:=pnt,act:=act));
  return Immutable( orbstab );
end );

#############################################################################
##
#M OrbitStabilizerAlgorithm
##
InstallMethod( OrbitStabilizerAlgorithm,"use stabilizer size",true,
  [IsGroup and IsFinite and CanComputeSizeAnySubgroup,IsObject,IsObject,
   IsList,IsList,IsRecord],0,
function( G,D,blist,gens,acts, dopr )
local   orb,  stb,  rep,  p,  q,  img,  sch,  i,d,act,
	doml,	# maximal orbit length
	dict,	# dictionary
	blico,	# copy of initial blist (to find out the true domain)
	blif,	# flag on whether a blist is given
	useblist,# flag on whether we use blists to find the index of elements
	crossind,	# index D (via blist) -> orbit position
	ind,	# stabilizer index
	indh,	# 1/2 stabilizer index
	incstb;	# do we still want to increase the stabilizer?

  d:=dopr.pnt;
  if IsBound(dopr.act) then
    act:=dopr.act;
  else
    act:=dopr.opr;
  fi;

  if D=false then
    doml:=Size(G);
  else
    if blist<>false then
      doml:=Size(D)-SizeBlist(blist);
      blico:=ShallowCopy(blist); # the original indices, needed to see what
                                 # a full orbit is
    else
      doml:=Size(D);
    fi;
  fi;

  incstb:=true; # do we still include stabilizer elements. If it is
  # `false' the index `ind' must be equal to the orbit size.
  orb := [ d ];

  # test for small domains whether the orbit has length 1
  if doml<10 then
    if doml=1 or ForAll(acts,i->act( d, i )=d) then

      # do we still need to tick off the orbit in `blist' to
      # please the caller? (see below as well)
      if blist<>false then
	q:=PositionCanonical(D,d);
	blist[q]:=true;
      fi;

      return rec( orbit := orb, stabilizer := G );
    fi;
    
  fi;

  dict:=NewDictionary(d,true,D);
  AddDictionary(dict,d,1);

  stb := TrivialSubgroup(G);
  ind:=Size(G);
  indh:=QuoInt(Size(G),2);
  if not IsEmpty( acts )  then
      rep := [ One( gens[ 1 ] ) ];
      p := 1;
      while p <= Length( orb )  do
	  for i  in [ 1 .. Length( gens ) ]  do

	    img := act( orb[ p ], acts[ i ] );
	    q:=LookupDictionary(dict,img);

	    if q = fail  then
	      Add( orb, img );
	      AddDictionary(dict,img,Length(orb));

	      if incstb then
		Add( rep, rep[ p ] * gens[ i ] );
		if indh<Length(orb) then
		  # the stabilizer cannot grow any more
		  incstb:=false;
		fi;
	      fi;

	    elif incstb then
	      sch := rep[ p ] * gens[ i ] / rep[ q ];
	      if not sch in stb  then
		ind:=stb;
		stb:=ClosureSubgroupNC(stb,sch);
		ind:=Index(G,stb);
		indh:=QuoInt(ind,2);
		if indh<Length(orb) then
		  # the stabilizer cannot grow any more
		  incstb:=false;
		fi;
	      fi;
	    fi;

	    if incstb=false then

	      # must the orbit contain the whole domain => extend?
	      if ind=doml and D<>false and Length(orb)<doml then
		if blist=false then
		  orb:=D;
		else
		  orb:=D{Filtered([1..Length(blico)],i->blico[i]=false)};
		  # we need to tick off the rest
		  UniteBlist(blist,
		    BlistList([1..Length(blist)],[1..Length(blist)]));
		fi;
		return rec( orbit := orb, stabilizer := stb );
	      elif  ind=Length(orb) then
		# we have reached the full orbit. No further tests
		# neccessary

		# do we still need to tick off the orbit in `blist' to
		# please the caller?
		if blist<>false then
		  # we decided not to use blists for the orbit calculation
		  # but a blist was given in which we have to tick off the
		  # orbit
		  if IsPositionDictionary(dict) then
		    UniteBlist(blist,dict!.blist);
		  else
		    for img in orb do
		      blist[PositionCanonical(D,img)]:=true;
		    od;
		  fi;
		fi;

		return rec( orbit := orb, stabilizer := stb );
	      fi;
	    fi;

	  od;
	  p := p + 1;
      od;
  fi;

  if blist<>false then
    # we decided not to use blists for the orbit calculation
    # but a blist was given in which we have to tick off the
    # orbit
    if IsPositionDictionary(dict) then
      UniteBlist(blist,dict!.blist);
    else
      for img in orb do
	blist[PositionCanonical(D,img)]:=true;
      od;
    fi;
  fi;

  return rec( orbit := orb, stabilizer := stb );
end );

InstallMethod( OrbitStabilizerAlgorithm,"collect stabilizer generators",true,
  [IsGroup,IsObject,IsObject, IsList,IsList,IsRecord],0,
function( G,D,blist,gens, acts, dopr )
local   orb,  stb,  rep,  p,  q,  img,  sch,  i,d,act,
	dict,  		# dictionary
	crossind;	# index D (via blist) -> orbit position

  d:=dopr.pnt;
  if IsBound(dopr.act) then
    act:=dopr.act;
  else
    act:=dopr.opr;
  fi;

  dict:=NewDictionary(d,true,D);

  # `false' the index `ind' must be equal to the orbit size.
  orb := [ d ];
  AddDictionary(dict,d,1);

  stb := TrivialSubgroup(G);
  if not IsEmpty( acts )  then
    rep := [ One( gens[ 1 ] ) ];
    p := 1;
    while p <= Length( orb )  do
      for i  in [ 1 .. Length( gens ) ]  do

	img := act( orb[ p ], acts[ i ] );

	q:=LookupDictionary(dict,img);

	if q = fail  then
	  Add( orb, img );
	  AddDictionary(dict,img,Length(orb));
	  Add( rep, rep[ p ] * gens[ i ] );
	else
	  sch := rep[ p ] * gens[ i ] / rep[ q ];
	  stb:=ClosureSubgroupNC(stb,sch);
	fi;

      od;
      p := p + 1;
    od;

  fi;

  # can we compute the index from the orbit length?
  if HasSize(G) then
    SetSize(stb,Size(G)/Length(orb));
  fi;

  # do we care about a blist?
  if blist<>false then
    if IsPositionDictionary(dict) then
      # just copy over
      UniteBlist(blist,dict!.blist);
    else
      # tick off by hand
      for i in orb do
        blist[PositionCanonical(D,i)]:=true;
      od;
    fi;
  fi;

  return rec( orbit := orb, stabilizer := stb );
end );

# AH, 5-feb-99 This function is neither documented not used.
#InstallGlobalFunction( OrbitStabilizerListByGenerators,
#    function( gens, acts, d, eq, act )
#    local   iden,  orb,  stb,  s,  rep,  r,  p,  q,  img,  sch,  i,  j;
#    
#    iden := Length( gens ) = 1  and  IsIdenticalObj( gens[ 1 ], acts );
#    if iden  then
#        gens := [  ];
#    fi;
#    orb := [ d ];
#    stb := List( gens, x -> [  ] );  Add( stb, [  ] );
#    s := stb[ Length( stb ) ];
#    if not IsEmpty( acts )  then
#        rep := List( gens, x -> [One(x[1])] );  Add( rep, [One(acts[1])] );
#        r := rep[ Length( rep ) ];
#        p := 1;
#        while p <= Length( orb )  do
#            for i  in [ 1 .. Length( acts ) ]  do
#                img := act( orb[ p ], acts[ i ] );
#                q := PositionProperty( orb, o -> eq( o, img ) );
#                if q = fail  then
#                    Add( orb, img );
#                    for j  in [ 1 .. Length( gens ) ]  do
#                        Add( rep[ j ], rep[ j ][ p ] * gens[ j ][ i ] );
#                    od;
#                    Add( r, r[ p ] * acts[ i ] );
#                else
#                    sch := r[ p ] * acts[ i ] / r[ q ];
#                    if not sch in s  then
#                        Add( s, sch );
#                        for j  in [ 1 .. Length( gens ) ]  do
#                            Add( stb[ j ], rep[ j ][ p ] * gens[ j ][ i ] /
#                                 rep[ j ][ q ] );
#                        od;
#                    fi;
#                fi;
#            od;
#            p := p + 1;
#        od;
#    fi;
#    if iden  then
#        Add( stb, stb[ 1 ] );
#    fi;
#    return rec( orbit := orb, stabilizers := stb );
#end );

#############################################################################
##
#F  Orbits( <arg> ) . . . . . . . . . . . . . . . . . . . . . . . . .  orbits
##
InstallMethod( Orbits, "for quick position domains", true,
  [ IsGroup, IsList and IsQuickPositionList, IsList, IsList, IsFunction ], 0,
    function( G, D, gens, acts, act )
    local   blist,  orbs,  next,  orb;
    
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
	# by calling `OrbitByPosOp' we avoid testing for positions twice.
	orb:=OrbitByPosOp(G,D,blist,next,D[next],gens,acts,act);
        # was: orb := OrbitOp( G, D[ next ], gens, acts, act );
        Add( orbs, orb );
        # for pnt  in orb  do
        #     pos := PositionCanonical( D, pnt );
        #     if pos <> fail  then
        #         blist[ pos ] := true;
        #     fi;
        # od;
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

InstallMethod( Orbits, "for arbitrary domains", true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    local   orbs, orb;
    
    orbs := [  ];
    while Length(D)>0  do
        orb := OrbitOp( G,D, D[1], gens, acts, act );
        Add( orbs, orb );
	D:=Difference(D,orb);
    od;
    return Immutable( orbs );
end );

InstallMethod( Orbits, "empty domain", true,
    [ IsGroup, IsList and IsEmpty, IsList, IsList, IsFunction ], 0,
function( G, D, gens, acts, act )
    return Immutable( [  ] );
end );

InstallOtherMethod( Orbits, "group without domain", true,
    [ IsGroup ], 0,
function( G )
  Error("You must give a domain on which the group acts");
end );

#############################################################################
##
#F  SparseActionHomomorphism( <arg> )   action homomorphism on `[1..n]'
##
InstallMethod( SparseActionHomomorphismOp,
        "domain given", true,
        [ IsGroup, IsList, IsList, IsList, IsList, IsFunction ], 0,
function( G, D, start, gens, acts, act )
local   list,  ps,  p,  i,  gen,  img,  pos,  imgs,  hom,orb,ran,xset;

  orb := List( start, p -> PositionCanonical( D, p ) );
  list := List( gens, gen -> [  ] );
  ps := 1;
  while ps <= Length( orb )  do
      p := D[ orb[ ps ] ];
      for i  in [ 1 .. Length( gens ) ]  do
	  gen := acts[ i ];
	  img := PositionCanonical( D, act( p, gen ) );
	  pos := Position( orb, img );
	  if pos = fail  then
	      Add( orb, img );
	      pos := Length( orb );
	  fi;
	  list[ i ][ ps ] := pos;
      od;
      ps := ps + 1;
  od;
  imgs := List( list, PermList );
  xset := ExternalSet( G, D{orb}, gens, acts, act);
  SetBaseOfGroup( xset, start );
  p:=RUN_IN_GGMBI; # no niceomorphism translation here
  RUN_IN_GGMBI:=true;
  hom := ActionHomomorphism(xset,"surjective" );
  ran:=Group(imgs,());
  SetRange(hom,ran);
  SetImagesSource(hom,ran);
  SetAsGroupGeneralMappingByImages( hom, GroupHomomorphismByImagesNC
	  ( G, ran, gens, imgs ) );

  # We know that the points corresponding to `start' give a base. We can use
  # this to get images quickly, using a stabilizer chain in the permutation
  # group
  SetFilterObj( hom, IsActionHomomorphismByBase );
  RUN_IN_GGMBI:=p;
  return hom;
end );

#############################################################################
##
#F  DoSparseActionHomomorphism( <arg> )
##
InstallGlobalFunction(DoSparseActionHomomorphism,
function(G,start,gens,acts,act,sort)
local dict,p,i,img,imgs,hom,permimg,orb,imgn,ran,D,xset;

  # get a dictionary

  if IsMatrix(start) and Length(start)>0 then
    # if we have matrices, we need to give a domain as well, to ensure the
    # right field
    D:=DomainForAction(start[1],acts);
  else # just base on the start values
    D:=fail;
  fi;
  dict:=NewDictionary(start[1],true,D);

  orb:=ShallowCopy(start);
  for i in [1..Length(orb)] do
    AddDictionary(dict,orb[i],i);
  od;

  permimg:=List(acts,i->[]);

  # orbit algorithm with image keeper
  p:=1;
  while p<=Length(orb) do
    for i in [1..Length(gens)] do
      img := act(orb[p],acts[i]);
      imgn:=LookupDictionary(dict,img);
      if imgn=fail then
	Add(orb,img);
	AddDictionary(dict,img,Length(orb));
	permimg[i][p]:=Length(orb);
      else
	permimg[i][p]:=imgn;
      fi;
    od;
    p:=p+1;
  od;

  # any asymptotic argument is pointless here: In practice sorting is much
  # quicker than image computation.
  if sort then
    imgs:=Sortex(orb); # permutation we must apply to the points to be sorted.
    # was: permimg:=List(permimg,i->OnTuples(Permuted(i,imgs),imgs));
    # run in loop to save memory
    for i in [1..Length(permimg)] do
      permimg[i]:=Permuted(permimg[i],imgs);
      permimg[i]:=OnTuples(permimg[i],imgs);
    od;
  fi;
  
  for i in [1..Length(permimg)] do
    permimg[i]:=PermList(permimg[i]);
  od;

  # We know that the points corresponding to `start' give a base. We can use
  # this to get images quickly, using a stabilizer chain in the permutation
  # group
  if fail in permimg then
    Error("not permutations");
  fi;

  xset := ExternalSet( G, orb, gens, acts, act);
  SetBaseOfGroup( xset, start );

  p:=RUN_IN_GGMBI; # no niceomorphism translation here
  RUN_IN_GGMBI:=true;
  hom := ActionHomomorphism( xset,"surjective" );
  imgs:=permimg;
  ran:=Group(imgs,());
  SetRange(hom,ran);
  SetImagesSource(hom,ran);
  SetAsGroupGeneralMappingByImages( hom, GroupHomomorphismByImagesNC
            ( G, ran, gens, imgs ) );

  SetFilterObj( hom, IsActionHomomorphismByBase );
  RUN_IN_GGMBI:=p;

  return hom;
end);

#############################################################################
##
#M  SparseActionHomomorphism( <arg> )
##
InstallOtherMethod( SparseActionHomomorphismOp,
  "no domain given", true,
  [ IsGroup, IsList, IsList, IsList, IsFunction ], 0,
function( G, start, gens, acts, act )
  return DoSparseActionHomomorphism(G,start,gens,acts,act,false);
end); 

#############################################################################
##
#M  SortedSparseActionHomomorphism( <arg> )
##
InstallOtherMethod( SortedSparseActionHomomorphismOp,
  "no domain given", true,
  [ IsGroup, IsList, IsList, IsList, IsFunction ], 0,
function( G, start, gens, acts, act )
  return DoSparseActionHomomorphism(G,start,gens,acts,act,true);
end );

#############################################################################
##
#F  ExternalOrbits( <arg> ) . . . . . . . . . . . .  list of transitive xsets
##
InstallMethod( ExternalOrbits,
    "G, D, gens, acts, act",
    true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    local   blist,  orbs,  next,  pnt,  orb;

    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, D, pnt, gens, acts, act );
        #SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        SetEnumerator( orb, OrbitByPosOp( G, D, blist, next, pnt,
                gens, acts, act ) );
        Add( orbs, orb );
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

InstallOtherMethod( ExternalOrbits,
    "G, xset, gens, acts, act",
    true,
    [ IsGroup, IsExternalSet,
      IsList,
      IsList,
      IsFunction ], 0,
    function( G, xset, gens, acts, act )
    local   D,  blist,  orbs,  next,  pnt,  orb;

    D := Enumerator( xset );
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, xset, pnt, gens, acts, act );
        #SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        SetEnumerator( orb, OrbitByPosOp( G, D, blist, next, pnt,
                gens, acts, act ) );
        Add( orbs, orb );
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

#############################################################################
##
#F  ExternalOrbitsStabilizers( <arg> )  . . . . . .  list of transitive xsets
##
BindGlobal("ExtOrbStabDom",function( G, xsetD,D, gens, acts, act )
local   blist,  orbs,  next,  pnt,  orb,  orbstab;

    orbs := [  ];
    if IsEmpty( D ) then
      next:= fail;
    else
      next:= 1;
      blist:= BlistList( [ 1 .. Length( D ) ], [  ] );
    fi;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, xsetD, pnt, gens, acts, act );
        # was orbstab := OrbitStabilizer( G, D, pnt, gens, acts, act );
	orbstab := OrbitStabilizerAlgorithm( G, D, blist,
	              gens, acts, rec(pnt:=pnt, act:=act ));
        #SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        SetEnumerator( orb, orbstab.orbit );
        SetStabilizerOfExternalSet( orb, orbstab.stabilizer );
        Add( orbs, orb );
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

InstallMethod( ExternalOrbitsStabilizers,
    "arbitrary domain",
    true,
    OrbitsishReq, 0,
function( G, D, gens, acts, act )
  return ExtOrbStabDom(G,D,D,gens,acts,act);
end );

InstallOtherMethod( ExternalOrbitsStabilizers,
    "external set",
    true,
    [ IsGroup, IsExternalSet, IsList, IsList, IsFunction ], 0,
function( G, xset, gens, acts, act )
  return ExtOrbStabDom(G,xset,Enumerator(xset),gens,acts,act);
end );

#############################################################################
##
#F  Permutation( <arg> )  . . . . . . . . . . . . . . . . . . . . permutation
##
InstallGlobalFunction( Permutation, function( arg )
    local   g,  D,  gens,  acts,  act,  xset,  hom;

    # Get the arguments.
    g := arg[ 1 ];
    if Length( arg ) = 2  and  IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        D := Enumerator( xset );
        if IsExternalSetByActorsRep( xset )  then
            gens := xset!.generators;
            acts := xset!.operators;
            act  := xset!.funcOperation;
        else
            act := FunctionAction( xset );
        fi;
    else
        D := arg[ 2 ];
        if IsDomain( D )  then
            D := Enumerator( D );
        fi;
        if IsFunction( arg[ Length( arg ) ] )  then
            act := arg[ Length( arg ) ];
        else
            act := OnPoints;
        fi;
        if Length( arg ) > 3  then
            gens := arg[ 3 ];
            acts := arg[ 4 ];
        fi;
    fi;
    
    if IsBound( gens )  and  not IsIdenticalObj( gens, acts )  then
        hom := ActionHomomorphismAttr( ExternalSetByFilterConstructor
                       ( IsExternalSet,
                         GroupByGenerators( gens ), D, gens, acts, act ) );
        return ImagesRepresentative( hom, g );
    else
        return PermutationOp( g, D, act );
    fi;
end );
                                
InstallMethod( PermutationOp, "object on list", true,
  [ IsObject, IsList, IsFunction ], 0,
    function( g, D, act )
    local   list,  blist,  fst,  old,  new,  pnt;
    
    if Length(D)>2 and CanEasilySortElements(FamilyObj(D)) then
      IsSSortedList(D);
    fi;
    list := [  ];
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    fst := Position( blist, false );
    while fst <> fail  do
        pnt := D[ fst ];
        new := fst;
        repeat
            old := new;
            pnt := act( pnt, g );
            new := PositionCanonical( D, pnt );
            if new = fail  then
                return fail;
            fi;
	    if blist[new] then
	      Info(InfoWarning,1,"PermutationOp: mapping is not a permutation");
	      return fail;
	    fi;
            blist[ new ] := true;
            list[ old ] := new;
        until new = fst;
        fst := Position( blist, false, fst );
    od;
    return PermList( list );
end );

#############################################################################
##
#F  PermutationCycle( <arg> ) . . . . . . . . . . . . . . . cycle permutation
##
InstallGlobalFunction( PermutationCycle, function( arg )
    local   g,  D,  pnt,  gens,  acts,  act,  xset,  hom;

    # Get the arguments.
    g := arg[ 1 ];
    if Length( arg ) = 3  and  IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        pnt  := arg[ 3 ];
        D := Enumerator( xset );
        if IsExternalSetByActorsRep( xset )  then
            gens := xset!.generators;
            acts := xset!.operators;
            act  := xset!.funcOperation;
        else
            act := FunctionAction( xset );
        fi;
    else
        D := arg[ 2 ];
        if IsDomain( D )  then
            D := Enumerator( D );
        fi;
        pnt := arg[ 3 ];
        if IsFunction( arg[ Length( arg ) ] )  then
            act := arg[ Length( arg ) ];
        else
            act := OnPoints;
        fi;
        if Length( arg ) > 4  then
            gens := arg[ 4 ];
            acts := arg[ 5 ];
        fi;
    fi;
    
    if IsBound( gens )  and  not IsIdenticalObj( gens, acts )  then
        hom := ActionHomomorphismAttr( ExternalSetByFilterConstructor
                       ( IsExternalSet,
                         GroupByGenerators( gens ), D, gens, acts, act ) );
        g := ImagesRepresentative( hom, g );
        return PermutationOp( g, CycleOp( g, PositionCanonical( D, pnt ),
                       OnPoints ), OnPoints );
    else
        return PermutationCycleOp( g, D, pnt, act );
    fi;
end );
                                
InstallMethod( PermutationCycleOp,"of object in list", true,
        [ IsObject, IsList, IsObject, IsFunction ], 0,
    function( g, D, pnt, act )
    local   list,  old,  new,  fst;
    
    list := [  ];
    fst := PositionCanonical( D, pnt );
    if fst = fail  then
        return ();
    fi;
    new := fst;
    repeat
        old := new;
        pnt := act( pnt, g );
        new := PositionCanonical( D, pnt );
        if new = fail  then
            return fail;
        fi;
        list[ old ] := new;
    until new = fst;
    return PermList( list );
end );

#############################################################################
##
#F  Cycle( <arg> )  . . . . . . . . . . . . . . . . . . . . . . . . . . cycle
##
InstallGlobalFunction( Cycle, function( arg )
    local   g,  D,  pnt,  gens,  acts,  act,  xset,  hom,  p;
    
    # Get the arguments.
    g := arg[ 1 ];
    if Length( arg ) = 3  and  IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        pnt  := arg[ 3 ];
        D := Enumerator( xset );
        if IsExternalSetByActorsRep( xset )  then
            gens := xset!.generators;
            acts := xset!.operators;
            act  := xset!.funcOperation;
        else
            act := FunctionAction( xset );
        fi;
    else
        if Length( arg ) > 2  and
           IsIdenticalObj( FamilyObj( arg[ 2 ] ),
                        CollectionsFamily( FamilyObj( arg[ 3 ] ) ) )  then
            D := arg[ 2 ];
            if IsDomain( D )  then
                D := Enumerator( D );
            fi;
            p := 3;
        else
            p := 2;
        fi;
        pnt := arg[ p ];
        if IsFunction( arg[ Length( arg ) ] )  then
            act := arg[ Length( arg ) ];
        else
            act := OnPoints;
        fi;
        if Length( arg ) > p + 1  then
            gens := arg[ p + 1 ];
            acts := arg[ p + 2 ];
        fi;
    fi;
    
    if IsBound( gens )  and  not IsIdenticalObj( gens, acts )  then
        hom := ActionHomomorphismAttr( ExternalOrbitOp
               ( GroupByGenerators( gens ), D, pnt, gens, acts, act ) );
        return D{ CycleOp( ImagesRepresentative( hom, g ),
                       PositionCanonical( D, pnt ), OnPoints ) };
    elif IsBound( D )  then
        return CycleOp( g, D, pnt, act );
    else
        return CycleOp( g, pnt, act );
    fi;
end );

InstallMethod( CycleOp,"of object in list", true,
        [ IsObject, IsList, IsObject, IsFunction ], 0,
    function( g, D, pnt, act )
    return CycleOp( g, pnt, act );
end );

CycleByPosOp := function( g, D, blist, fst, pnt, act )
    local   cyc,  new;
    
    cyc := [  ];
    new := fst;
    repeat
        Add( cyc, pnt );
        pnt := act( pnt, g );
        new := PositionCanonical( D, pnt );
        blist[ new ] := true;
    until new = fst;
    return Immutable( cyc );
end;

InstallOtherMethod( CycleOp, true, [ IsObject, IsObject, IsFunction ], 0,
    function( g, pnt, act )
    local   orb,  img;
    
    orb := [ pnt ];
    img := act( pnt, g );
    while img <> pnt  do
        Add( orb, img );
        img := act( img, g );
    od;
    return Immutable( orb );
end );

#############################################################################
##
#F  Cycles( <arg> ) . . . . . . . . . . . . . . . . . . . . . . . . .  cycles
##
InstallGlobalFunction( Cycles, function( arg )
    local   g,  D,  gens,  acts,  act,  xset,  hom;
    
    # Get the arguments.
    g := arg[ 1 ];
    if Length( arg ) = 2  and  IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        D := Enumerator( xset );
        if IsExternalSetByActorsRep( xset )  then
            gens := xset!.generators;
            acts := xset!.operators;
            act  := xset!.funcOperation;
        else
            act := FunctionAction( xset );
        fi;
        D := Enumerator( xset );
    else
        D := arg[ 2 ];
        if IsDomain( D )  then
            D := Enumerator( D );
        fi;
        if IsFunction( arg[ Length( arg ) ] )  then
            act := arg[ Length( arg ) ];
        else
            act := OnPoints;
        fi;
        if Length( arg ) > 3  then
            gens := arg[ 3 ];
            acts := arg[ 4 ];
        fi;
    fi;
    
    if IsBound( gens )  and  not IsIdenticalObj( gens, acts )  then
        hom := ActionHomomorphismAttr( ExternalSetByFilterConstructor
                       ( IsExternalSet,
                         GroupByGenerators( gens ), D, gens, acts, act ) );
        return List( CyclesOp( ImagesRepresentative( hom, g ),
                       [ 1 .. Length( D ) ], OnPoints ), cyc -> D{ cyc } );
    else
        return CyclesOp( g, D, act );
    fi;
end );

InstallMethod( CyclesOp, true, [ IsObject, IsList, IsFunction ], 1,
    function( g, D, act )
    local   blist,  orbs,  next,  pnt,  pos,  orb;
    
    IsSSortedList(D);
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail do
        pnt := D[ next ];
        orb := CycleOp( g, D[ next ], act );
        Add( orbs, orb );
        for pnt  in orb  do
            pos := PositionCanonical( D, pnt );
            if pos <> fail  then
                blist[ pos ] := true;
            fi;
        od;
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

#############################################################################
##
#F  Blocks( <arg> ) . . . . . . . . . . . . . . . . . . . . . . . . .  blocks
##
InstallOtherMethod( BlocksOp,
        "G, D, gens, acts, act", true,
        [ IsGroup, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, gens, acts, act )
    return BlocksOp( G, D, [  ], gens, acts, act );
end );

InstallMethod( BlocksOp,
        "G, D, seed, gens, acts, act", true,
        [ IsGroup, IsList, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, seed, gens, acts, act )
    local   hom,  B;
    
    hom := ActionHomomorphism( G, D, gens, acts, act );
    B := Blocks( ImagesSource( hom ), [ 1 .. Length( D ) ] );
    return List( B, b -> D{ b } );
end );

InstallMethod( BlocksOp,
        "G, [  ], seed, gens, acts, act", true,
        [ IsGroup, IsList and IsEmpty, IsList,
          IsList,
          IsList,
          IsFunction ], 
	  20, # we claim this method is very good
    function( G, D, seed, gens, acts, act )
    return Immutable( [  ] );
end );

#############################################################################
##
#F  MaximalBlocks( <arg> )  . . . . . . . . . . . . . . . . .  maximal blocks
##
InstallOtherMethod( MaximalBlocksOp,
        "G, D, gens, acts, act", true,
        [ IsGroup, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, gens, acts, act )
    return MaximalBlocksOp( G, D, [  ], gens, acts, act );
end );

InstallMethod( MaximalBlocksOp,
        "G, D, seed, gens, acts, act", true,
        [ IsGroup, IsList, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function ( G, D, seed, gens, acts, act )
    local   blks,       # blocks, result
            H,          # image of <G>
            blksH;      # blocks of <H>

    blks := BlocksOp( G, D, seed, gens, acts, act );

    # iterate until the action becomes primitive
    H := G;
    blksH := blks;
    while Length( blksH ) <> 1  do
        H     := Action( H, blksH, OnSets );
        blksH := Blocks( H, [1..Length(blksH)] );
        if Length( blksH ) <> 1  then
            blks := List( blksH, bl -> Union( blks{ bl } ) );
        fi;
    od;

    # return the blocks <blks>
    return Immutable( blks );
end );

#############################################################################
##

#F  OrbitLength( <arg> )  . . . . . . . . . . . . . . . . . . .  orbit length
##
InstallMethod( OrbitLengthOp,"compute orbit", true, OrbitishReq, 0,
    function( G, D, pnt, gens, acts, act )
    return Length( OrbitOp( G, D, pnt, gens, acts, act ) );
end );

InstallOtherMethod( OrbitLengthOp,"compute orbit", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, acts, act )
    return Length( OrbitOp( G, pnt, gens, acts, act ) );
end );


#############################################################################
##
#F  OrbitLengths( <arg> ) . . . . . . . . . . . . . . . . . . . orbit lengths
##
InstallMethod( OrbitLengths,"compute orbits",
    true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    return Immutable( List( Orbits( G, D, gens, acts, act ), Length ) );
end );


#############################################################################
##
#F  CycleLength( <arg> )  . . . . . . . . . . . . . . . . . . .  cycle length
##
InstallGlobalFunction( CycleLength, function( arg )
    local   g,  D,  pnt,  gens,  acts,  act,  xset,  hom,  p;
    
    # test arguments
    if Length(arg)<2 or not IsMultiplicativeElementWithInverse(arg[1]) then
      Error("usage: CycleLength(<g>,<D>,<pnt>[,<act>])");
    fi;

    # Get the arguments.
    g := arg[ 1 ];
    if IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        pnt := arg[ 3 ];
        if HasHomeEnumerator( xset )  then
            D := HomeEnumerator( xset );
        fi;
        act := FunctionAction( xset );
    else
      if Length( arg ) > 2  and
	  IsIdenticalObj( FamilyObj( arg[ 2 ] ),
		      CollectionsFamily( FamilyObj( arg[ 3 ] ) ) )  then
	  D := arg[ 2 ];
	  if IsDomain( D )  then
	      D := Enumerator( D );
	  fi;
	  p := 3;
      else
	  p := 2;
      fi;
      pnt := arg[ p ];
      if IsFunction( arg[ Length( arg ) ] )  then
	  act := arg[ Length( arg ) ];
      else
	  act := OnPoints;
      fi;
      if Length( arg ) > p + 1  then
	gens := arg[ p + 1 ];
	acts := arg[ p + 2 ];
	if not IsIdenticalObj( gens, acts )  then
	  xset:=ExternalOrbitOp(GroupByGenerators(gens),D,pnt,gens,acts,act);
	fi;
      fi;
    fi;
    
    if IsBound(xset) and IsExternalSetByActorsRep(xset) then
      # in all other cases the homomorphism was ignored anyhow
      hom := ActionHomomorphismAttr(xset);
      return CycleLengthOp( ImagesRepresentative( hom, g ),
		      PositionCanonical( D, pnt ), OnPoints );
    elif IsBound( D )  then
      return CycleLengthOp( g, D, pnt, act );
    else
      return CycleLengthOp( g, pnt, act );
    fi;
end );

InstallMethod( CycleLengthOp, true,
        [ IsObject, IsList, IsObject, IsFunction ], 0,
    function( g, D, pnt, act )
    return Length( CycleOp( g, D, pnt, act ) );
end );

InstallOtherMethod( CycleLengthOp, true,
        [ IsObject, IsObject, IsFunction ], 0,
    function( g, pnt, act )
    return Length( CycleOp( g, pnt, act ) );
end );

#############################################################################
##
#F  CycleLengths( <arg> ) . . . . . . . . . . . . . . . . . . . cycle lengths
##
InstallGlobalFunction( CycleLengths, function( arg )
    local   g,  D,  gens,  acts,  act,  xset,  hom;
    
    # test arguments
    if Length(arg)<2 or not IsMultiplicativeElementWithInverse(arg[1]) then
      Error("usage: CycleLengths(<g>,<D>[,<act>])");
    fi;
    
    # Get the arguments.
    g := arg[ 1 ];
    if IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        D := Enumerator( xset );
        act := FunctionAction( xset );
        hom := ActionHomomorphismAttr( xset );
    else
        D := arg[ 2 ];
        if IsDomain( D )  then
            D := Enumerator( D );
        fi;
        if IsFunction( arg[ Length( arg ) ] )  then
            act := arg[ Length( arg ) ];
        else
            act := OnPoints;
        fi;
        if Length( arg ) > 3  then
            gens := arg[ 3 ];
            acts := arg[ 4 ];
            if not IsIdenticalObj( gens, acts )  then
                hom := ActionHomomorphismAttr
                       ( ExternalSetByFilterConstructor( IsExternalSet,
                         GroupByGenerators( gens ), D, gens, acts, act ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  and  IsActionHomomorphismByActors( hom )  then
        return CycleLengthsOp( ImagesRepresentative( hom, g ),
                       [ 1 .. Length( D ) ], OnPoints );
    else
        return CycleLengthsOp( g, D, act );
    fi;
end );

InstallMethod( CycleLengthsOp, true, [ IsObject, IsList, IsFunction ], 0,
    function( g, D, act )
    return Immutable( List( CyclesOp( g, D, act ), Length ) );
end );


#############################################################################
##
#F  IsTransitive( <G>, <D>, <gens>, <acts>, <act> ) . . . . transitivity test
##
InstallMethod( IsTransitive,
    "compare with orbit of element",
    true,
    OrbitsishReq, 0,
function( G, D, gens, acts, act )
    return Length(D)=0 or IsSubset( OrbitOp( G, D[ 1 ], gens, acts, act ), D );
end );


#############################################################################
##
#F  Transitivity( <arg> ) . . . . . . . . . . . . . . . . transitivity degree
##
InstallMethod( Transitivity,"of the image of an ophom",
    true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    local   hom;
    
    hom := ActionHomomorphism( G, D, gens, acts, act );
    return Transitivity( ImagesSource( hom ), [ 1 .. Length( D ) ] );
end );

InstallMethod( Transitivity,
    "G, [  ], gens, perms, act",
    true,
    [ IsGroup, IsList and IsEmpty,
      IsList,
      IsList,
      IsFunction ], 
      20, # we claim this method is very good
    function( G, D, gens, acts, act )
    return 0;
end );


#############################################################################
##
#F  IsPrimitive( <G>, <D>, <gens>, <acts>, <act> )  . . . .  primitivity test
##
InstallMethod( IsPrimitive,"transitive and no blocks",
    true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    return     IsTransitive( G, D, gens, acts, act )
           and Length( Blocks( G, D, gens, acts, act ) ) = 1;
end );


#############################################################################
##
#F  Earns( <arg> ) . . . . . . . . elementary abelian regular normal subgroup
##
InstallMethod( Earns,
    true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    Error( "`Earns' only implemented for primitive permutation groups" );
end );


#############################################################################
##
#M  SetEarns( <G>, fail ) . . . . . . . . . . . . . . . . .  never set `fail'
##
InstallOtherMethod( SetEarns,"never set fail",
    true, [ IsGroup, IsBool ], 0,
function( G, failval )
    Setter( IsPrimitiveAffine )( G, false );
end );


#############################################################################
##
#F  IsPrimitiveAffine( <arg> )
##
InstallMethod( IsPrimitiveAffine,"primitive and earns",
    true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    return     IsPrimitive( G, D, gens, acts, act )
           and Earns( G, D, gens, acts, act ) <> fail;
end );


#############################################################################
##
#F  IsSemiRegular( <arg> )  . . . . . . . . . . . . . . . semiregularity test
##
InstallMethod( IsSemiRegular,"via ophom",
    true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    local   hom;
    
    hom := ActionHomomorphism( G, D, gens, acts, act );
    return IsSemiRegular( ImagesSource( hom ), [ 1 .. Length( D ) ] );
end );

InstallMethod( IsSemiRegular,
    "G, [  ], gens, perms, act",
    true,
    [ IsGroup, IsList and IsEmpty,
      IsList,
      IsList,
      IsFunction ], 
      20, # we claim this method is very good
    function( G, D, gens, acts, act )
    return true;
end );

InstallMethod( IsSemiRegular,
    "G, D, gens, [  ], act",
    true,
    [ IsGroup, IsList,
      IsList,
      IsList and IsEmpty,
      IsFunction ], 
      20, # we claim this method is very good
    function( G, D, gens, acts, act )
    return IsTrivial( G );
end );


#############################################################################
##
#F  IsRegular( <arg> )  . . . . . . . . . . . . . . . . . . . regularity test
##
InstallMethod( IsRegular,"transitive and semiregular",
    true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    return     IsTransitive( G, D, gens, acts, act )
           and IsSemiRegular( G, D, gens, acts, act );
end );


#############################################################################
##
#F  RepresentativeAction( <arg> )  . . . . . . . .  representative element
##
InstallGlobalFunction( RepresentativeAction, function( arg )
local   G,  D,  d,  e,  gens,  acts,  act,  xset,  hom,  p,  rep;
    
    if IsExternalSet( arg[ 1 ] )  then
        xset := arg[ 1 ];
        d := arg[ 2 ];
        e := arg[ 3 ];
        G := ActingDomain( xset );

	# catch a trivial case (that is called from some operations often)
	if d=e then
	  return One(G);
	fi;

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
    else
        G := arg[ 1 ];
        if Length( arg ) > 2  and
	  IsIdenticalObj( FamilyObj( arg[ 2 ] ),
		      CollectionsFamily( FamilyObj( arg[ 3 ] ) ) )  then
	  D := arg[ 2 ];
	  if IsDomain( D )  then
	      D := Enumerator( D );
	  fi;
	  p := 3;
	else
	  p := 2;
        fi;
        d := arg[ p     ];
        e := arg[ p + 1 ];

	# catch a trivial case (that is called from some operations often)
	if d=e then
	  return One(G);
	fi;

        if IsFunction( arg[ Length( arg ) ] )  then
            act := arg[ Length( arg ) ];
        else
            act := OnPoints;
        fi;
        if Length( arg ) > p + 2  then
	  gens := arg[ p + 2 ];
	  acts := arg[ p + 3 ];
	  if not IsPcgs( gens )  and  not IsIdenticalObj( gens, acts )  then
	    if not IsBound( D )  then
		D := OrbitOp( G, d, gens, acts, act );
	    fi;
	    xset:=ExternalOrbitOp( G, D, d, gens, acts, act );
	  fi;
        fi;
    fi;
    
    if IsBound(xset) and IsExternalSetByActorsRep(xset) then
      # in all other cases the homomorphism was ignored anyhow
      hom := ActionHomomorphismAttr(xset);

      d := PositionCanonical( D, d );  e := PositionCanonical( D, e );
      rep := RepresentativeActionOp( ImagesSource( hom ), d, e,
		      OnPoints );
      if rep <> fail  then
	rep := PreImagesRepresentative( hom, rep );
      fi;
      return rep;
    elif IsBound( D )  then
      if IsBound( gens )  and  IsPcgs( gens )  then
	return RepresentativeAction( G, D, d, e, gens, acts, act );
      else
	return RepresentativeActionOp( G, D, d, e, act );
      fi;
    else
        return RepresentativeActionOp( G, d, e, act );
    fi;
end );

InstallMethod( RepresentativeActionOp,"ignore domain",
    true,
    [ IsGroup, IsList, IsObject, IsObject, IsFunction ], 0,
    function( G, D, d, e, act )        
    return RepresentativeActionOp( G, d, e, act );
end );

InstallOtherMethod( RepresentativeActionOp,
  "orbit algorithm: trace transversal", true,
        [ IsGroup, IsObject, IsObject, IsFunction ], 0,
    function( G, d, e, act )
    local   rep,        # representative, result
            orb,        # orbit
            set,        # orbit <orb> as set for faster membership test
	    cansort,	# may we form sets?
            gen,        # generator of the group <G>
            pnt,        # point in the orbit <orb>
            img,        # image of the point <pnt> under the generator <gen>
            by,         # <by>[<pnt>] is a gen taking <frm>[<pnt>] to <pnt>
            frm;        # where <frm>[<pnt>] lies earlier in <orb> than <pnt>

    cansort:=CanEasilySortElements(d);
    orb := [ d ];
    if cansort then
      set := [ d ];
    else
      set:=orb;
    fi;

    # standard action
    if   act = OnPoints  then
        if d = e  then return One( G );  fi;
        by  := [ One( G ) ];
        frm := [ 1 ];
        for pnt  in orb  do
            for gen  in GeneratorsOfGroup( G )  do
                img := pnt ^ gen;
                if img = e  then
                    rep := gen;
                    while pnt <> d  do
                        rep := by[ Position(orb,pnt) ] * rep;
                        pnt := frm[ Position(orb,pnt) ];
                    od;
                    return rep;
                elif not img in set  then
                    Add( orb, img );
		    if cansort then
		      AddSet( set, img );
		    fi;
                    Add( frm, pnt );
                    Add( by,  gen );
                fi;
            od;
        od;
        return fail;

    # special case for action on pairs
    elif act = OnPairs  then
        if d = e  then return One( G );  fi;
        by  := [ One( G ) ];
        frm := [ 1 ];
        for pnt  in orb  do
            for gen  in GeneratorsOfGroup( G )  do
                img := [ pnt[1]^gen, pnt[2]^gen ];
                if img = e  then
                    rep := gen;
                    while pnt <> d  do
                        rep := by[ Position(orb,pnt) ] * rep;
                        pnt := frm[ Position(orb,pnt) ];
                    od;
                    return rep;
                elif not img in set  then
                    Add( orb, img );
		    if cansort then
		      AddSet( set, img );
		    fi;
                    Add( frm, pnt );
                    Add( by,  gen );
                fi;
            od;
        od;
        return fail;

    # other action
    else
        if d = e  then return One( G );  fi;
        by  := [ One( G ) ];
        frm := [ 1 ];
        for pnt  in orb  do
            for gen  in GeneratorsOfGroup( G )  do
                img := act( pnt, gen );
                if img = e  then
                    rep := gen;
                    while pnt <> d  do
                        rep := by[ Position(orb,pnt) ] * rep;
                        pnt := frm[ Position(orb,pnt) ];
                    od;
                    return rep;
                elif not img in set  then
                    Add( orb, img );
		    if cansort then
		      AddSet( set, img );
		    fi;
                    Add( frm, pnt );
                    Add( by,  gen );
                fi;
            od;
        od;
        return fail;

    fi;

end );

#############################################################################
##
#F  Stabilizer( <arg> ) . . . . . . . . . . . . . . . . . . . . .  stabilizer
##
InstallGlobalFunction( Stabilizer, function( arg )
    if Length( arg ) = 1  then
        return StabilizerOfExternalSet( arg[ 1 ] );
    else
        return CallFuncList( StabilizerFunc, arg );
    fi;
end );

InstallMethod( StabilizerOp,
        "`OrbitStabilizerAlgorithm' with domain",true,
        OrbitishReq, 0,
function( G, D, d, gens, acts, act )
local   orbstab;
  
  orbstab:=OrbitStabilizerAlgorithm(G,D,false,gens,acts,rec(pnt:=d,act:=act));
  return orbstab.stabilizer;

end );

InstallOtherMethod( StabilizerOp,
        "`OrbitStabilizerAlgorithm' without domain",true,
        [ IsGroup, IsObject, IsList, IsList, IsFunction ], 0,
function( G, d, gens, acts, act )
local   stb,  p,  orbstab;
  
  if     IsIdenticalObj( gens, acts )
    and act = OnTuples  or  act = OnPairs  then
    # for tuples compute the stabilizer iteratively
    stb := G;
    for p  in d  do
	stb := StabilizerOp( stb, p, GeneratorsOfGroup( stb ),
			GeneratorsOfGroup( stb ), OnPoints );
    od;
  else
    orbstab:=OrbitStabilizerAlgorithm(G,false,false,gens,acts,
                                      rec(pnt:=d,act:=act));
    stb := orbstab.stabilizer;
  fi;
  return stb;
end );

#############################################################################
##
#F  RankAction( <arg> ) . . . . . . . . . . . . . . . number of suborbits
##
InstallMethod( RankAction,"via ophom",
    true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    local   hom;

    hom := ActionHomomorphism( G, D, gens, acts, act );
    return RankAction( Image( hom ), [ 1 .. Length( D ) ] );
end );

InstallMethod( RankAction,
    "G, ints, gens, perms, act",
    true,
    [ IsGroup, IsList and IsCyclotomicCollection,
      IsList,
      IsList,
      IsFunction ], 0,
    function( G, D, gens, acts, act )
    if    act <> OnPoints
       or not IsIdenticalObj( gens, acts )  then
        TryNextMethod();
    fi;
    return Length( Orbits( Stabilizer( G, D, D[ 1 ], act ),
                   D, act ) );
end );

InstallMethod( RankAction,
    "G, [  ], gens, perms, act",
    true,
    [ IsGroup, IsList and IsEmpty,
      IsList,
      IsList,
      IsFunction ], 
      20, # we claim this method is very good
    function( G, D, gens, acts, act )
    return 0;
end );


#############################################################################
##
#M  CanonicalRepresentativeOfExternalSet( <xset> )  . . . . . . . . . . . . .
##
InstallMethod( CanonicalRepresentativeOfExternalSet,"smallest element", true,
        [ IsExternalSet ], 0,
    function( xset )
    local   aslist;
    
    aslist := AsList( xset );
    return First( HomeEnumerator( xset ), p -> p in aslist );
end );

# for external sets that know how to get the canonical representative
InstallMethod( CanonicalRepresentativeOfExternalSet, 
      "by CanonicalRepresentativeDeterminator",
      true,
      [ IsExternalSet
        and HasCanonicalRepresentativeDeterminatorOfExternalSet ],
      0,
function( xset )
local func,can;

  func:=CanonicalRepresentativeDeterminatorOfExternalSet(xset);
  can:=func(ActingDomain(xset),Representative(xset));
  # note the stabilizer we got for free
  if not HasStabilizerOfExternalSet(xset) and IsBound(can[2]) then
    SetStabilizerOfExternalSet(xset,can[2]^(can[3]^-1));
  fi;
  return can[1];
end ) ;

#############################################################################
##
#M  ActorOfExternalSet( <xset> ) . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( ActorOfExternalSet, true, [ IsExternalSet ], 0,
    xset -> RepresentativeAction( xset, Representative( xset ),
            CanonicalRepresentativeOfExternalSet( xset ) ) );

#############################################################################
##
#M  StabilizerOfExternalSet( <xset> ) . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( StabilizerOfExternalSet,"stabilizer of the represenattive",
  true, [ IsExternalSet ], 0,
        xset -> Stabilizer( xset, Representative( xset ) ) );

#############################################################################
##
#M  ImageElmActionHomomorphism( <hom>, <elm> )
##
InstallGlobalFunction(ImageElmActionHomomorphism,function( hom, elm )
    local   xset;
    xset := UnderlyingExternalSet( hom );
    return Permutation(elm,HomeEnumerator(xset),FunctionAction(xset));
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . for action hom
##
InstallMethod( ImagesRepresentative,"for action hom", FamSourceEqFamElm,
        [ IsActionHomomorphism, IsMultiplicativeElementWithInverse ], 0,
  ImageElmActionHomomorphism);

InstallMethod( ImagesRepresentative, "for action hom that is `ByAsGroup'",
  FamSourceEqFamElm,
  [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages 
    and IsActionHomomorphism, IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
  return ImagesRepresentative( AsGroupGeneralMappingByImages( hom ), elm );
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <ophom>, <elm> )
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
  "for action homomorphism", true, [ IsActionHomomorphism ], 0,
function( hom )
  return KernelOfMultiplicativeGeneralMapping(
           AsGroupGeneralMappingByImages( hom ) );
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . .  if a base is known
##
InstallMethod( ImagesRepresentative, "using `RepresentativeAction'",
  FamSourceEqFamElm, [ IsActionHomomorphismByBase and HasImagesSource,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   xset,  D,  act,  imgs;

    xset := UnderlyingExternalSet( hom );
    D := HomeEnumerator( xset );
    act := FunctionAction( xset );
    if not IsBound( xset!.basePermImage )  then
        xset!.basePermImage := List( BaseOfGroup( xset ),
                                    b -> PositionCanonical( D, b ) );
    fi;
    imgs:=List(BaseOfGroup(xset),b->PositionCanonical(D,act(b,elm)));
    return RepresentativeActionOp( ImagesSource( hom ),
                   xset!.basePermImage, imgs, OnTuples );
end );

#############################################################################
##
#M  ImagesSource( <hom> ) . . . . . . . . . . . . . . . . . set base in image
##
InstallMethod( ImagesSource,"actionHomomorphismByBase", true,
        [ IsActionHomomorphismByBase ], 0,
    function( hom )
    local   xset,  img,  D;
    
    xset := UnderlyingExternalSet( hom );
    img := ImagesSet( hom, Source( hom ) );
    if not HasStabChainMutable( img )  and  not HasBaseOfGroup( img )  then
        if not IsBound( xset!.basePermImage )  then
            D := HomeEnumerator( xset );
            xset!.basePermImage := List( BaseOfGroup( xset ),
                                        b -> PositionCanonical( D, b ) );
        fi;
        SetBaseOfGroup( img, xset!.basePermImage );
    fi;
    return img;
end );
    
#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . .  restricted `Permutation'
##
InstallMethod( ImagesRepresentative,"restricted perm", FamSourceEqFamElm,
        [ IsActionHomomorphismSubset,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   xset;
    
    xset := UnderlyingExternalSet( hom );
    return RestrictedPerm( Permutation( elm, HomeEnumerator( xset ),
        FunctionAction( xset ) ),
        MovedPoints( ImagesSource( AsGroupGeneralMappingByImages( hom ) ) ) );
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . .  build matrix
##
InstallMethod( PreImagesRepresentative,"IsLinearActionHomomorphism",
  FamRangeEqFamElm, [ IsLinearActionHomomorphism, IsPerm ], 0,
function( hom, elm )
  local   V,  base,  mat,  b,xset,lab;
  
  # is this method applicable? Test whether the domain contains a vector
  # space basis (respectively just get this basis).
  lab:=LinearActionBasis(hom);
  if lab=fail then
    TryNextMethod();
  fi;

  if not elm in Image( hom )  then
      return fail;
  fi;
  xset:=UnderlyingExternalSet(hom);
  V := HomeEnumerator(xset);
  if not IsBound(hom!.linActBasisPositions) then
    hom!.linActBasisPositions:=List(lab,i->PositionCanonical(V,i));
  fi;
  elm:=OnTuples(hom!.linActBasisPositions,elm); # image points
  elm:=V{elm}; # the corresponding vectors
  if not IsBound(hom!.linActInverse) then
    hom!.linActInverse:=Inverse(lab);
  fi;

  return hom!.linActInverse*elm;
end );

#############################################################################
##
#A  LinearActionBasis(<hom>)
##
InstallMethod(LinearActionBasis,"find basis in domain",true,
  [IsLinearActionHomomorphism],0,
function(hom)
local xset,dom,D,b,t,i,r;
  xset:=UnderlyingExternalSet(hom);
  if Size(xset)=0 then
    return fail;
  fi;
  # if there is a base, check whether it's full rank, if yes, take it
  if HasBaseOfGroup(xset) 
     and RankMat(BaseOfGroup(xset))=Length(BaseOfGroup(xset)[1]) then
    # this implies injectivity
    SetIsInjective(hom,true);
    return BaseOfGroup(xset);
  fi;
  # otherwise we've to find a basis from the domain.
  D:=HomeEnumerator(xset);
  b:=[];
  t:=[];
  r:=Length(D[1]);
  i:=1;
  while Length(b)<r and i<=Length(D) do
    if RankMat(Concatenation(t,[D[i]]))>Length(t) then
      # new indep. vector
      Add(b,D[i]);
      Add(t,ShallowCopy(D[i]));
      TriangulizeMat(t); # for faster rank tests
    fi;
    i:=i+1;
  od;
  if Length(b)=r then
    # this implies injectivity
    SetIsInjective(hom,true);
    return b;
  else
    return fail; # does not span
  fi;
end);

#############################################################################
##
#M  DomainForAction( <pnt>, <acts> )
##
InstallMethod(DomainForAction,"default: fail",true,
  [IsObject,IsListOrCollection],0,
function(pnt,acts)
  return fail;
end);

