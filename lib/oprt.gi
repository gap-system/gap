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
      local pos,actor;
      pos:=Position(xset!.generators,g);
      if pos<>fail then
        actor:=xset!.operators[pos];
      else
        pos:=Position(xset!.generators,g^-1);
        if pos<>fail then
          actor:=xset!.operators[pos]^-1;
        else
          Error("need to factor -- not yet implemented");
        fi;
      fi;
      return xset!.funcOperation(p,actor);
#    local   D;
#        D := Enumerator( xset );
#        return D[ PositionCanonical( D, p ) ^
#                  ( g ^ ActionHomomorphismAttr( xset ) ) ];
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
    local   xsset;

    xsset := ExternalSetByFilterConstructor( IsExternalSubset,
                     G, HomeEnumerator( xset ), gens, acts, act );

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
InstallMethod( Enumerator, "for external subset with home enumerator",
    [ IsExternalSubset and HasHomeEnumerator],
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
    return EnumeratorOfSubset( henum, sublist );
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

InstallMethodWithRandomSource( Random,
        "for a random source and for an external orbit: via acting domain", true,
  [ IsRandomSource, IsExternalOrbit ], 0,
function( rs, xset )
  if HasHomeEnumerator(xset) and not IsPlistRep(HomeEnumerator(xset)) then
    TryNextMethod(); # can't do orbit because the home enumerator might
    # imply a different `PositionCanonical' (and thus equivalence of objects)
    # method.
  fi;
  return FunctionAction(xset)(Representative(xset),Random(rs, ActingDomain(xset)));
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
    local  xorb;

    xorb := ExternalSetByFilterConstructor( IsExternalOrbit,
                    G, HomeEnumerator( xset ), gens, acts, act );

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
  if (Size(xorb)>10  and not HasAsList(yorb))
  or not IsIdenticalObj(ActingDomain     (xorb),ActingDomain     (yorb))
  or not IsIdenticalObj(FunctionAction(xorb),FunctionAction(yorb))
      then
      TryNextMethod();
  fi;
  return Representative( xorb ) in AsList(yorb);
end );

InstallMethod( \=, "xorbs with canonicalRepresentativeDeterminator",
  IsIdenticalObj,
  [IsExternalOrbit and CanEasilyDetermineCanonicalRepresentativeExternalSet,
   IsExternalOrbit and CanEasilyDetermineCanonicalRepresentativeExternalSet],
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

    if arg[ Length( arg ) ] = "surjective"  or
       arg[ Length( arg ) ] = "onto"  then
        attr := SurjectiveActionHomomorphismAttr;
        Remove( arg );
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
        return arg[ 2 ]!.actionHomomorphism;  # GAP-3 compatibility
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
InstallGlobalFunction( ActionHomomorphismConstructor, function(arg)
local   xset,surj,G,  D,  act,  fam,  filter,  hom,  i,blockacttest;

    xset:=arg[1];surj:=arg[2];
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
    if IsPermGroup( G )  then
        filter := filter and IsPermGroupGeneralMapping;
    fi;

    blockacttest:=function()
        #
        # Test if D is a block system for G
        #
        local  x, l1, i, b, y, a, p, g;
        D:=List(D,Immutable);
        if Length(D) = 0 then
            return false;
        fi;
        #
        # x will map from points to blocks
        #
        x := [];
        l1 := Length(D[1]);
        if l1 = 0 then
            return false;
        fi;
        for i in [1..Length(D)] do
            b := D[i];
            if not IsSSortedList(b) or Length(b) <> l1 then
                # putative blocks not sets or not all the same size
                return false;
            fi;
            for y in b do
                if not IsPosInt(y) or IsBound(x[y]) then
                    # bad block entry or blocks overlap
                    return false;
                fi;
                x[y] := i;
            od;
        od;
        for b in D do
            for g in GeneratorsOfGroup(G) do
                a:=b[1]^g;
                p:=x[a];
                if OnSets(b,g)<>D[p] then
                    # blocks not preserved by group action
                    return false;
                fi;
            od;
        od;
        return true;
    end;

    hom := rec(  );
    if Length(arg)>2 then
      filter:=arg[3];
    elif IsExternalSetByActorsRep( xset )  then
        filter := filter and IsActionHomomorphismByActors;
    elif     IsMatrixGroup( G )
         and IsScalarList( D[ 1 ] ) then
      if  act in [ OnPoints, OnRight ]  then
        # we act linearly. This might be used to compute preimages by linear
        # algebra
        # note that we do not test whether the domain actually contains a
        # vector space base. This will be done the first time,
        # `LinearActionBasis' is called (i.e. in the preimages routine).
        filter := filter and IsLinearActionHomomorphism;
      elif act=OnLines then
        filter := filter and IsProjectiveActionHomomorphism;
      fi;

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
#           Error("hier");
#            if IsSubset( D, IdentityMat
#                       ( Length( D[ 1 ] ), One( D[ 1 ][ 1 ] ) ) )  then
#            fi;
#        fi;
    # test for constituent homomorphism
    elif not IsExternalSubset( xset )
         and IsPermGroup( G )
         and IsList( D ) and IsCyclotomicCollection( D )
         and act = OnPoints  then


        filter := IsConstituentHomomorphism;
        hom.conperm := MappingPermListList( D, [ 1 .. Length( D ) ] );

        # if MappingPermListList took a family/group as an
        # argument then we could patch it instead
        #if IsHomCosetToPerm(One(G)) then
        #    hom.conperm := HomCosetWithImage( Homomorphism(G.1),
        #                   One(Source(G)), hom.conperm );
        #fi;


    # test for action on disjoint sets of numbers, preserved by group -> blocks homomorphism

    elif not IsExternalSubset( xset )
         and IsPermGroup( G )
         and IsList( D )
         and act = OnSets
         # preserved test
         and blockacttest()
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
    # action of fp group
    elif IsSubgroupFpGroup(G) then
      filter:=filter and IsFromFpGroupHomomorphism;
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

BindGlobal( "VPActionHom", function( hom )
local name;
  name:="homo";
  if HasIsInjective(hom) and IsInjective(hom) then
    name:="mono";
    if HasIsSurjective(hom) and IsSurjective(hom) then
      name:="iso";
    fi;
  elif HasIsSurjective(hom) and IsSurjective(hom) then
    name:="epi";
  fi;
  Print( "<action ",name,"morphism>" );
end );


#############################################################################
##
#F  MultiActionsHomomorphism(G,pnts,ops)
##
InstallGlobalFunction(MultiActionsHomomorphism,function(G,pnts,ops)
  local gens,homs,trans,n,d,i,j,mgi,ran,hom,imgs,c;
  gens:=GeneratorsOfGroup(G);
  homs:=[];
  trans:=[];
  n:=1;

  if Length(pnts)=1 then
    return DoSparseActionHomomorphism(G,[pnts[1]],gens,gens,ops[1],false);
  fi;

  imgs:=List(gens,x->());
  c:=0;
  for i in [1..Length(pnts)] do
    if ForAny(homs,x->FunctionAction(UnderlyingExternalSet(x))=ops[i] and
                   pnts[i] in HomeEnumerator(UnderlyingExternalSet(x))) then
      Info(InfoGroup,1,"point ",i," already covered");
    else
      hom:=DoSparseActionHomomorphism(G,[pnts[i]],gens,gens,ops[i],false);
      d:=NrMovedPoints(Range(hom));
      if d>0 then
        c:=c+1;
        homs[c]:=hom;
        trans[c]:=MappingPermListList([1..d],[n..n+d-1]);
        mgi:=MappingGeneratorsImages(hom)[2];
        for j in [1..Length(gens)] do
          imgs[j]:=imgs[j]*mgi[j]^trans[c];
        od;
        n:=n+d;
      fi;
    fi;
  od;
  ran:=Group(imgs,());
  hom:=GroupHomomorphismByFunction(G,ran,
        function(elm)
        local i,p,q;
          p:=();
          for i in [1..Length(homs)] do
            q:=ImagesRepresentative(homs[i],elm);
            if q = fail and ValueOption("actioncanfail")=true then
              return fail;
            fi;
            p:=p*(q^trans[i]);
          od;
          return p;
        end);

  SetImagesSource(hom,ran);
  SetMappingGeneratorsImages(hom,[gens,imgs]);
  SetAsGroupGeneralMappingByImages( hom, GroupHomomorphismByImagesNC
            ( G, ran, gens, imgs ) );

  return hom;
end);



#############################################################################
##
#M  ViewObj( <hom> )  . . . . . . . . . . . .  view an action homomorphism
##
InstallMethod( ViewObj, "for action homomorphism", true,
    [ IsActionHomomorphism ], 0, VPActionHom);

#############################################################################
##
#M  PrintObj( <hom> ) . . . . . . . . . . . . print an action homomorphism
##
InstallMethod( PrintObj, "for action homomorphism", true,
    [ IsActionHomomorphism ], 0, VPActionHom);
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

InstallMethod( Range, "surjective action homomorphism",
  [ IsActionHomomorphism and IsSurjective ],
function(hom)
local gens, imgs, ran, i, a, xset,opt;
  gens:=GeneratorsOfGroup( Source( hom ) );
  if false and HasSize(Source(hom)) and Length(gens)>0 then
    imgs:=[ImageElmActionHomomorphism(hom,gens[1])];
    opt:=rec(limit:=Size(Source(hom)));
    if IsBound(hom!.basepos) then
      opt!.knownBase:=hom!.basepos;
    fi;
    ran:=Group(imgs[1]);
    i:=2;
    while i<=Length(gens) and Size(ran)<Size(Source(hom)) do
      a:=ImageElmActionHomomorphism( hom, gens[i]);
      Add(imgs,a);
      ran:=DoClosurePrmGp(ran,[a],opt);
      i:=i+1;
    od;
  else
    imgs:=List(gens,gen->ImageElmActionHomomorphism( hom, gen ) );
    if Length(imgs)=0 then
      ran:= GroupByGenerators( imgs,
                ImageElmActionHomomorphism( hom, One( Source( hom ) ) ) );
    else
      ran:= GroupByGenerators(imgs,One(imgs[1]));
    fi;
  fi;
  # remember a known base
  if HasBaseOfGroup(UnderlyingExternalSet(hom)) then
    xset:=UnderlyingExternalSet(hom);
    if not IsBound( xset!.basePermImage )  then
        xset!.basePermImage:=List(BaseOfGroup( xset ),
                                  b->PositionCanonical(Enumerator(xset),b));
    fi;
    SetBaseOfGroup(ran,xset!.basePermImage);
  fi;
  SetMappingGeneratorsImages(hom,[gens{[1..Length(imgs)]},imgs]);
  if HasSize(Source(hom)) then
    StabChainOptions(ran).limit:=Size(Source(hom));
  fi;
  if HasIsInjective(hom) and HasSource(hom) and IsInjective(hom) then
    UseIsomorphismRelation( Source(hom), ran );
  fi;
  return ran;
end);

#############################################################################
##
#M  RestrictedMapping(<ophom>,<U>)
##
InstallMethod(RestrictedMapping,"action homomorphism",
  CollFamSourceEqFamElms,[IsActionHomomorphism,IsGroup],0,
function(hom,U)
local xset,rest;

  xset:=RestrictedExternalSet(UnderlyingExternalSet(hom),U);
  if ValueOption("surjective")=true or (HasIsSurjective(hom) and
    IsSurjective(hom)) then
    rest:=SurjectiveActionHomomorphismAttr( xset );
  else
    rest:=ActionHomomorphismAttr( xset );
  fi;

  if HasIsInjective(hom) and IsInjective(hom) then
    SetIsInjective(rest,true);
  fi;
  if HasIsTotal(hom) and IsTotal(hom) then
    SetIsTotal(rest,true);
  fi;

  return rest;
end);

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
    PushOptions(rec(onlyimage:=true)); # we don't want `ActionHom' to build
                                       # a stabilizer chain.
    hom := CallFuncList( ActionHomomorphism, arg );
    PopOptions();
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
local orb,d,gen,i,p,permrec,perms;
  # is there an option indicating a wish to calculate permutations?
  permrec:=ValueOption("permutations");
  if permrec<>fail then
    if not IsRecord(permrec) then
      Error("asks for permutations, but no record given");
    fi;
    perms:=List(gens,x->[]);
    permrec.generators:=gens;
    permrec.permutations:=perms;
  fi;

  pnt:=Immutable(pnt);
  orb := [ pnt ];
  if permrec=fail then
    d:=NewDictionary(pnt,false,D);
    AddDictionary(d,pnt);
  fi;
  for p in orb do
    for gen in acts do
      i:=act(p,gen);
      MakeImmutable(i);
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
local orb,d,gen,i,p,D,perms,permrec,gp,op,l;
  # is there an option indicating a wish to calculate permutations?
  permrec:=ValueOption("permutations");
  if permrec<>fail then
    if not IsRecord(permrec) then
      Error("asks for permutations, but no record given");
    fi;
    perms:=List(gens,x->[]);
    permrec.generators:=gens;
    permrec.permutations:=perms;
  fi;

  # try to find a domain
  D:=DomainForAction(pnt,acts,act);
  pnt:=Immutable(pnt);
  orb := [ pnt ];
  if permrec=fail then
    d:=NewDictionary(pnt,false,D);
    AddDictionary(d,pnt);
  else
    d:=NewDictionary(pnt,true,D);
    AddDictionary(d,pnt,1);
  fi;
  op:=0;
  for p in orb do
    op:=op+1;
    gp:=0;
    for gen in acts do
      gp:=gp+1;
      i:=act(p,gen);
      MakeImmutable(i);
      if permrec=fail then
        if not KnowsDictionary(d,i) then
          Add( orb, i );
          AddDictionary(d,i);
        fi;
      else
        l:=LookupDictionary(d,i);
        if l=fail then
          Add( orb, i );
          AddDictionary(d,i,Length(orb));
          perms[gp][op]:=Length(orb);
        else
          perms[gp][op]:=l;
        fi;
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
    local   orb,  p,  gen,  img,pofu;

    if IsInternalRep(D) then
      pofu:=Position; # avoids one redirection, epsilon faster
    else
      pofu:=PositionCanonical;
    fi;
    blist[ pos ] := true;
    orb := [ pnt ];
    for p  in orb  do
        for gen  in acts  do
            img := act( p, gen );
            pos := pofu( D, img );
            if not blist[ pos ]  then
              blist[ pos ] := true;
              #Add( orb, img );
              Add( orb, D[pos] ); # this way we do not store the new element
              # but the already existing old one in D. This saves memory.
            fi;
        od;
    od;
    return Immutable( orb );
end );

#############################################################################
##
#M  \^( <p>, <G> ) . . . . . . . orbit of a point under the action of a group
##
##  Returns the orbit of the point <A>p</A> under the action of the group
##  <A>G</A>, with respect to the action <C>OnPoints</C>.
##
InstallOtherMethod( \^, "orbit of a point under the action of a group",
                    ReturnTrue, [ IsObject, IsGroup ], 0,

  function ( p, G )
    return Orbit(G,p,OnPoints);
  end );

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

#############################################################################
##
#M OrbitStabilizerAlgorithm
##
BindGlobal("DoOrbitStabilizerAlgorithmStabsize",
function( G,D,blist,gens,acts, dopr )
local   orb,  stb,  rep,  p,  q,  img,  sch,  i,d,act,r,
        onlystab, # do we only care about stabilizer?
        getrep, # function to get representative
        actsinv,# inverses of acts
        stopat, # index at which increasal stopped
        notinc, # nr of steps in whiuch we did not increase
        stabsub,# stabilizer seed
        doml,   # maximal orbit length
        dict,   # dictionary
        blico,  # copy of initial blist (to find out the true domain)
        ind,    # stabilizer index
        indh,   # 1/2 stabilizer index
        increp, # do we still want to increase the rep list?
        incstb; # do we still want to increase the stabilizer?

  stopat:=fail; # to trigger error if wrong generators
  d:=Immutable(dopr.pnt);
  if IsBound(dopr.act) then
    act:=dopr.act;
  else
    act:=dopr.opr;
  fi;

  onlystab:=IsBound(dopr.onlystab) and dopr.onlystab=true;

  # try to find a domain
  if IsBool(D) then
    D:=DomainForAction(d,acts,act);
  fi;
  dict:=NewDictionary(d,true,D);

  if IsBound(dopr.stabsub) then
    stabsub:=AsSubgroup(Parent(G),dopr.stabsub);
  else
    stabsub:=TrivialSubgroup(G);
  fi;
  # NC is safe
  stabsub:=ClosureSubgroupNC(stabsub,gens{Filtered([1..Length(acts)],
            i->act(d,acts[i])=d)});

  if IsBool(D) or IsRecord(D) then
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

  incstb:=Index(G,stabsub)>1; # do we still include stabilizer elements. If
  # it is `false' the index `ind' must be equal to the orbit size.
  orb := [ d ];

  if incstb=false then
    # do we still need to tick off the orbit in `blist' to
    # please the caller? (see below as well)
    if blist<>false then
      q:=PositionCanonical(D,d);
      blist[q]:=true;
    fi;
    r:=rec( orbit := orb, stabilizer := G );
    return r;
  fi;

#  # test for small domains whether the orbit has length 1
#  if doml<10 then
#    if doml=1 or ForAll(acts,i->act( d, i )=d) then
#
#      # do we still need to tick off the orbit in `blist' to
#      # please the caller? (see below as well)
#      if blist<>false then
#       q:=PositionCanonical(D,d);
#       blist[q]:=true;
#      fi;
#
#      return rec( orbit := orb, stabilizer := G );
#    fi;
#
#  fi;

  AddDictionary(dict,d,1);

  stb := stabsub; # stabilizer seed
  ind:=Size(G);
  indh:=QuoInt(Size(G),2);
  if not IsEmpty( acts )  then

    # using only a factorized transversal can be expensive, in particular if
    # the action is more complicated. We therefore store a certain number of
    # representatives fixed.
    actsinv:=false;

    getrep:=function(pos)
    local a,r;
      a:=rep[pos];
      if not IsInt(a) then
        return a;
      else
        r:=fail;
        while pos>1 and IsInt(a) do
          if r=fail then
            r:=gens[a];
          else
            r:=gens[a]*r;
          fi;
          pos:=LookupDictionary(dict,act(orb[pos],actsinv[a]));
          a:=rep[pos];
        od;
        if pos>1 then
          r:=a*r;
        fi;
        return r;
      fi;
    end;
    notinc:=0;
    increp:=true;

    rep := [ One( gens[ 1 ] ) ];
    p := 1;
    while p <= Length( orb )  do
      for i  in [ 1 .. Length( gens ) ]  do

        img := act( orb[ p ], acts[ i ] );
        MakeImmutable(img);
        q:=LookupDictionary(dict,img);

        if q = fail  then
          Add( orb, img );
          AddDictionary(dict,img,Length(orb));

          if increp then
            if actsinv=false then
              Add( rep, rep[ p ] * gens[ i ] );
            else
              Add( rep, i );
            fi;
            if indh<Length(orb) then
              # the stabilizer cannot grow any more
              if not (IsBound(dopr.returnReps) and dopr.returnReps) then
                increp:=false;
              fi;
              incstb:=false;
            fi;
          fi;

        elif incstb then
          #sch := rep[ p ] * gens[ i ] / rep[ q ];
          sch := getrep( p ) * gens[ i ] / getrep( q );
          if not sch in stb  then
            notinc:=0;

            # NC is safe
            stb:=ClosureSubgroupNC(stb,sch);
            ind:=Index(G,stb);
            indh:=QuoInt(ind,2);
            if indh<Length(orb) then
              # the stabilizer cannot grow any more
              if not (IsBound(dopr.returnReps) and dopr.returnReps) then
                increp:=false;
              fi;
              incstb:=false;
            fi;
          else
            notinc:=notinc+1;
            if notinc*50>indh and notinc>1000 then
              # we have failed often enough -- assume for the moment we have
              # the right stabilizer
              #Error("stop stabilizer increase");
              stopat:=p;
              incstb:=false; # do not increase the stabilizer, but keep
                             # representatives
              actsinv:=List(acts,Inverse);
            fi;
          fi;
        fi;

        if increp=false then #we know the stabilizer
          if onlystab then
            r:=rec(stabilizer:=stb);
            if IsBound(dopr.returnReps) and dopr.returnReps then
              r.rep:=rep;r.getrep:=getrep;r.actsinv:=actsinv;
              r.dictionary:=dict;
            fi;
            return r;
          # must the orbit contain the whole domain => extend?
        elif ind=doml and (not IsBool(D)) and Length(orb)<doml then
            if blist=false then
              orb:=D;
            else
              orb:=D{Filtered([1..Length(blico)],i->blico[i]=false)};
              # we need to tick off the rest
              UniteBlist(blist,
                BlistList([1..Length(blist)],[1..Length(blist)]));
            fi;
            r:=rec( orbit := orb, stabilizer := stb );
            if IsBound(dopr.returnReps) and dopr.returnReps then
              r.rep:=rep;r.getrep:=getrep;r.actsinv:=actsinv;
              r.dictionary:=dict;
            fi;
            return r;
          elif  ind=Length(orb) then
            # we have reached the full orbit. No further tests
            # necessary

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

            r:= rec( orbit := orb, stabilizer := stb );
            if IsBound(dopr.returnReps) and dopr.returnReps then
              r.rep:=rep;r.getrep:=getrep;r.actsinv:=actsinv;
              r.dictionary:=dict;
            fi;
            return r;
          fi;
        fi;
      od;
      p := p + 1;
    od;

    if Size(G)/Size(stb)>Length(orb) then
      if stopat=fail then
        Error("generators do not match group");
      fi;
      p:=stopat;
      while p<=Length(orb) do
        i:=1;
        while i<=Length(gens) do
          img := act( orb[ p ], acts[ i ] );
          MakeImmutable(img);
          q:=LookupDictionary(dict,img);
          sch := getrep( p ) * gens[ i ] / getrep( q );
          if not sch in stb then
            stb:=ClosureSubgroupNC(stb,sch);
            if Size(G)/Size(stb)=Length(orb) then
              p:=Length(orb);i:=Length(gens); #done
            fi;
          fi;
          i:=i+1;
        od;
        p:=p+1;
      od;
      #Error("after");
    fi;
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

  r:=rec( orbit := orb, stabilizer := stb );
  if IsBound(dopr.returnReps) and dopr.returnReps then
    r.rep:=rep;r.getrep:=getrep;r.actsinv:=actsinv;
    r.dictionary:=dict;
  fi;
  return r;
end );

InstallMethod( OrbitStabilizerAlgorithm,"use stabilizer size",true,
  [IsGroup and IsFinite and CanComputeSizeAnySubgroup,IsObject,IsObject,
   IsList,IsList,IsRecord],0,
function( G,D,blist,gens,acts, dopr )
local pr,hom,pgens,pacts,pdopr,erg,cs,i,dict,orb,stb,rep,getrep,q,img,gen,
  gena,j,k,e,l,orbl,pcgs;
  if HasSize(G) and Size(G)>10^5
    # not yet implemented for blist case
    and blist=false then

    pr:=PerfectResiduum(G);
    if IndexNC(G,pr)>3 then
      hom:=GroupHomomorphismByImagesNC(G,Group(acts),gens,acts);;
      pgens:=ShallowCopy(SmallGeneratingSet(pr));
      pacts:=List(pgens,x->ImagesRepresentative(hom,x));
      pdopr:=ShallowCopy(dopr);
      pdopr.returnReps:=true;
      pdopr.onlystab:=false;
      erg:=DoOrbitStabilizerAlgorithmStabsize(pr,D,blist,pgens,pacts,pdopr);
      if not IsBound(erg.dictionary) then
        # degenerate case, routine did not set up everything
        return DoOrbitStabilizerAlgorithmStabsize(G,D,blist,gens,acts,dopr);
      fi;
      dict:=erg.dictionary; orb:=erg.orbit; stb:=erg.stabilizer;
      rep:=erg.rep; getrep:=erg.getrep;
      orbl:=Length(orb);
      if IsBound(dopr.onlystab) and dopr.onlystab=true
        and 10*IndexNC(G,pr)<Length(orb) then
        # it is cheaper to just find the right cosets than to (potentially)
        # map the whole orbit
        for i in RightTransversal(G,pr) do
          gena:=ImagesRepresentative(hom,i);
          img:=dopr.act(orb[1],gena);
          q:=LookupDictionary(dict,img);
          if IsInt(q) then
            img:=i/getrep(q);
            stb:=ClosureGroup(stb,img);
          fi;
        od;
        return rec(stabilizer := stb);

      else
        cs:=CompositionSeriesThrough(G,[pr]);
        cs:=Reversed(Filtered(cs,x->Size(x)>=Size(pr)));
        pcgs:=[];
        # step over the cyclic factors
        for i in [2..Length(cs)] do
          gen:=First(GeneratorsOfGroup(cs[i]),x->not x in cs[i-1]);
          gena:=ImagesRepresentative(hom,gen);
          img:=dopr.act(orb[1],gena);
          q:=LookupDictionary(dict,img);
          if q=fail then
            # orbit grows
            e:=First([1..Order(gen)],x->gen^x in cs[i-1]); # local order
            Add(pcgs,[e,gen,gena]);
            l:=Length(orb);
            for j in [1..e-1] do
              for k in [1..l] do
                q:=(j-1)*l+k;
                img:=dopr.act(orb[q],gena);
                Add(orb,img);
                AddDictionary(dict,img,Length(orb));
              od;
            od;
          else
            #Print(q,":",QuoInt(q-1,orbl),"\n");
            if Length(pcgs)>0 then
              # find correct position of orbit block
              j:=Reversed(CoefficientsMultiadic(List(Reversed(pcgs),x->x[1]),
                QuoInt(q-1,orbl)));
              k:=Product([1..Length(pcgs)],x->pcgs[x][3]^j[x]);
              img:=dopr.act(img,k^-1);
              q:=LookupDictionary(dict,img);
              k:=Product([1..Length(pcgs)],x->pcgs[x][2]^j[x]);
            else
              k:=One(G);
            fi;
            stb:=ClosureGroup(stb,gen/k/getrep(q));
          fi;
        od;
        if IsBound(dopr.onlystab) and dopr.onlystab=true then
          return rec(stabilizer := stb);
        else
          return rec( orbit := orb, stabilizer := stb );
        fi;

      fi;
    fi;
  fi;
  return DoOrbitStabilizerAlgorithmStabsize(G,D,blist,gens,acts,dopr);
end);


InstallMethod( OrbitStabilizerAlgorithm,"collect stabilizer generators",true,
  [IsGroup,IsObject,IsObject, IsList,IsList,IsRecord],0,
function( G,D,blist,gens, acts, dopr )
local   orb,  stb,  rep,  p,  q,  img,  sch,  i,d,act,
        stabsub,        # stabilizer seed
        dict;           # dictionary

  d:=Immutable(dopr.pnt);
  if IsBound(dopr.act) then
    act:=dopr.act;
  else
    act:=dopr.opr;
  fi;

  # try to find a domain
  if IsBool(D) then
    D:=DomainForAction(d,acts,act);
  fi;

  if IsBound(dopr.stabsub) then
    stabsub:=AsSubgroup(Parent(G),dopr.stabsub);
  else
    stabsub:=TrivialSubgroup(G);
  fi;

  dict:=NewDictionary(d,true,D);

  # `false' the index `ind' must be equal to the orbit size.
  orb := [ d ];
  AddDictionary(dict,d,1);

  stb := stabsub; # stabilizer seed
  if not IsEmpty( acts )  then
    rep := [ One( gens[ 1 ] ) ];
    p := 1;
    while p <= Length( orb )  do
      for i  in [ 1 .. Length( gens ) ]  do

        img := act( orb[ p ], acts[ i ] );
        MakeImmutable(img);

        q:=LookupDictionary(dict,img);

        if q = fail  then
          Add( orb, img );
          AddDictionary(dict,img,Length(orb));
          Add( rep, rep[ p ] * gens[ i ] );
        else
          sch := rep[ p ] * gens[ i ] / rep[ q ];
          # NC is safe
          stb:=ClosureSubgroupNC(stb,sch);
        fi;

      od;
      p := p + 1;
    od;

  fi;

  # can we compute the index from the orbit length?
  if HasSize(G) then
    if IsFinite(G) then
      SetSize(stb,Size(G)/Length(orb));
    else
      SetSize(stb,infinity);
    fi;
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

#############################################################################
##
#F  Orbits( <arg> ) . . . . . . . . . . . . . . . . . . . . . . . . .  orbits
##

BindGlobal("OrbitsByPosOp",function( G, D, gens, acts, act )
    local   blist,  orbs,  next,  orb;

    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    for next in [1..Length(D)] do
      if blist[next]=false then
        # by calling `OrbitByPosOp' we avoid testing for positions twice.
        orb:=OrbitByPosOp(G,D,blist,next,D[next],gens,acts,act);
        Add( orbs, orb );
      fi;
    od;
    return Immutable( orbs );
end );

InstallMethod( OrbitsDomain, "for quick position domains", true,
  [ IsGroup, IsList and IsQuickPositionList, IsList, IsList, IsFunction ], 0,
  OrbitsByPosOp);

InstallMethod( OrbitsDomain, "for arbitrary domains", true,
    OrbitsishReq, 0,
function( G, D, gens, acts, act )
local   orbs, orb,sort,plist,pos,use,o,i,p;

  if Length(D)>0 and not IsMutable(D) and HasIsSSortedList(D) and IsSSortedList(D)
    and CanEasilySortElements(D[1]) then
    return OrbitsByPosOp( G, D, gens, acts, act );
  fi;
  sort:=Length(D)>0 and CanEasilySortElements(D[1]);
  plist:=IsPlistRep(D);
  if plist and Length(D)>0 and IsHomogeneousList(D) and CanEasilySortElements(D[1]) then
    plist:=false;
    D:=AsSortedList(D);
  fi;
  if not plist then
    use:=BlistList([1..Length(D)],[]);
  fi;
  orbs := [  ];
  pos:=1;
  while Length(D)>0  and pos<=Length(D) do

    orb := OrbitOp( G,D, D[pos], gens, acts, act );
    if plist then
      orb:=ShallowCopy(orb);
      use:=[1..Length(D)];
      for i in [1..Length(orb)] do
        p:=Position(D,orb[i]);
        if p<>fail then # catch if domain is not closed
          orb[i]:=D[p];
          RemoveSet(use,p);
        fi;
      od;
      D:=D{use};
      if sort then
        MakeImmutable(D); # to remember sortedness
        IsSSortedList(D);
      fi;
    else
      for o in orb do
        use[PositionCanonical(D,o)]:=true;
      od;
      # not plist -- do not take difference as there may be special
      # `PositionCanonical' method.
      while pos<=Length(D) and use[pos] do
        pos:=pos+1;
      od;
    fi;
    Add( orbs, orb );
  od;
  return Immutable( orbs );
end );

InstallMethod( OrbitsDomain, "empty domain", true,
    [ IsGroup, IsList and IsEmpty, IsList, IsList, IsFunction ], 0,
function( G, D, gens, acts, act )
    return Immutable( [  ] );
end );

InstallOtherMethod(OrbitsDomain,"group without domain",true,[ IsGroup ], 0,
function( G )
  Error("You must give a domain on which the group acts");
end );

InstallMethod( Orbits, "for arbitrary domains", true, OrbitsishReq, 0,
function( G, D, gens, acts, act )
local   orbs, orb,sort,plist,pos,use,o,nc,ld,ld1,pc;

  sort:=Length(D)>0 and CanEasilySortElements(D[1]);
  plist:=IsPlistRep(D);
  if not plist then
    use:=BlistList([1..Length(D)],[]);
  fi;
  nc:=true;
  ld1:=Length(D);
  orbs := [  ];
  pos:=1;
  while Length(D)>0  and pos<=Length(D) do
    orb := OrbitOp( G,D[pos], gens, acts, act );
    Add( orbs, orb );
    if plist then
      ld:=Length(D);
      if sort then
        D:=Difference(D,orb);
        MakeImmutable(D); # to remember sortedness
      else
        D:=Filtered(D,i-> not i in orb);
      fi;
      if Length(D)+Length(orb)>ld then
        nc:=false; # there are elements in `orb' not in D
      fi;
    else
      for o in orb do
        pc:=PositionCanonical(D,o);
        if pc <> fail then
          use[pc]:=true;
        fi;
      od;
      # not plist -- do not take difference as there may be special
      # `PositionCanonical' method.
      while pos<=Length(D) and use[pos] do
        pos:=pos+1;
      od;
    fi;
  od;
  if nc and ld1>10000 then
    Info(InfoPerformance,1,
    "You are calculating `Orbits' with a large set of seeds.\n",
      "#I  If you gave a domain and not seeds consider `OrbitsDomain' instead.");
  fi;
  return Immutable( orbs );
end );

InstallMethod( OrbitsDomain, "empty domain", true,
    [ IsGroup, IsList and IsEmpty, IsList, IsList, IsFunction ], 0,
function( G, D, gens, acts, act )
    return Immutable( [  ] );
end );

InstallOtherMethod( Orbits, "group without domain", true, [ IsGroup ], 0,
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
    ran:= Group( imgs, () );  # `imgs' has been created with `PermList'
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

  if IsMatrix(start) and Length(start)>0 and Length(start)=Length(start[1]) then
    # if we have matrices, we need to give a domain as well, to ensure the
    # right field
    D:=DomainForAction(start[1],acts,act);
  else # just base on the start values
    D:=fail;
  fi;
  dict:=NewDictionary(start[1],true,D);

  orb:=List(start,x->x); # do force list rep.
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

  imgs:=permimg;
  ran:= Group( imgs, () );  # `imgs' has been created with `PermList'

  xset := ExternalSet( G, orb, gens, acts, act);
  if IsMatrix(start) and (act=OnPoints or act=OnRight) then
    # act on vectors -- if we have a basis we have a base for ordinary
    # action
    p:=RankMat(start);
    if p=Length(start[1]) then
      SetBaseOfGroup( xset, start );
    elif RankMat(orb{[1..Minimum(Length(orb),200)]})=Length(start[1]) then
      start:=ShallowCopy(start);
      i:=0;
      # we know we will be successful
      while p<Length(start[1]) do
        i:=i+1;
        if RankMat(Concatenation(start,[orb[i]]))>p then
          Add(start,orb[i]);
          p:=p+1;
        fi;
      od;
      SetBaseOfGroup( xset, start );
    fi;
  elif IsMatrix(start) and act=OnLines then
    # projective action also needs all-1 vector.
    img:=1+Zero(start);

    if img in orb then
      start:=ShallowCopy(start);
      p:=RankMat(start);
      Add(start,img);
      if p=Length(start[1]) then
        SetBaseOfGroup( xset, start );
      elif RankMat(orb{[1..Minimum(Length(orb),200)]})=Length(start[1]) then
        i:=0;
        # we know we will be successful
        while p<Length(start[1]) do
          i:=i+1;
          if RankMat(Concatenation(start,[orb[i]]))>p then
            Add(start,orb[i]);
            p:=p+1;
          fi;
        od;
        SetBaseOfGroup( xset, start );
      fi;
    fi;
  fi;

  p:=RUN_IN_GGMBI; # no niceomorphism translation here
  RUN_IN_GGMBI:=true;
  hom := ActionHomomorphism( xset,"surjective" );
  SetRange(hom,ran);
  SetImagesSource(hom,ran);
  SetMappingGeneratorsImages(hom,[gens,imgs]);
  SetAsGroupGeneralMappingByImages( hom, GroupHomomorphismByImagesNC
            ( G, ran, gens, imgs ) );

  if HasBaseOfGroup(xset) then
    SetFilterObj( hom, IsActionHomomorphismByBase );
  fi;
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
    for next in [1..Length(D)] do
      if blist[next]=false then
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, D, pnt, gens, acts, act );
        #SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        SetEnumerator( orb, OrbitByPosOp( G, D, blist, next, pnt,
                gens, acts, act ) );
        Add( orbs, orb );
      fi;
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
    for next in [1..Length(D)] do
      if blist[next]=false then
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, xset, pnt, gens, acts, act );
        #SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        SetEnumerator( orb, OrbitByPosOp( G, D, blist, next, pnt,
                gens, acts, act ) );
        Add( orbs, orb );
      fi;
    od;
    return Immutable( orbs );
end );

#############################################################################
##
#F  ExternalOrbitsStabilizers( <arg> )  . . . . . .  list of transitive xsets
##
BindGlobal("ExtOrbStabDom",function( G, xsetD,D, gens, acts, act )
local   blist,  orbs,  next,  pnt,  orb,  orbstab,actrec;

    orbs := [  ];
    if IsEmpty( D ) then
      return Immutable( orbs );
    else
      blist:= BlistList( [ 1 .. Length( D ) ], [  ] );
    fi;
    for next in [1..Length(D)] do
      if blist[next]=false then
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, xsetD, pnt, gens, acts, act );
        # was orbstab := OrbitStabilizer( G, D, pnt, gens, acts, act );
        actrec:=rec(pnt:=pnt, act:=act );
        # Does the external set give a kernel? Use it!
        if IsExternalSet(xsetD) and HasActionKernelExternalSet(xsetD) then
          actrec.stabsub:=ActionKernelExternalSet(xsetD);
        fi;
        orbstab := OrbitStabilizerAlgorithm( G, D, blist, gens, acts, actrec);
        #SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        if IsSSortedList(orbstab.orbit) then
          SetAsSSortedList( orb, orbstab.orbit );
        else
          SetAsList( orb, orbstab.orbit );
        fi;
        SetEnumerator( orb, orbstab.orbit );
        SetStabilizerOfExternalSet( orb, orbstab.stabilizer );
        Add( orbs, orb );
      fi;
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
    local   list,  blist,  fst,  old,  new,  pnt,perm;

    perm:=();
    if IsPlistRep(D) and Length(D)>2
       and CanEasilySortElements(D[1]) then
      if not IsSSortedList(D) then
        D:=ShallowCopy(D);
        perm:=Sortex(D);
        D:=Immutable(D);
        SetIsSSortedList(D,true); # ought to be unnecessary, just be safe
      fi;
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
            if new=fail then
              Info(InfoWarning,2,"PermutationOp: mapping does not leave the domain invariant");
              return fail;
            elif blist[new] then
              Info(InfoWarning,2,"PermutationOp: mapping is not injective");
              return fail;
            fi;
            blist[ new ] := true;
            list[ old ] := new;
            # Map the "original" points not the images under `act'.
            # We assume that they are at least as nice as the images.
            # In the case of automorphisms acting on elements of a f. p. group,
            # the images are represented by words which are usually longer
            # than the words in `D'.
            pnt := D[ new ];
        until new = fst;
        fst := Position( blist, false, fst );
    od;
    new:=PermList( list );
    if not IsOne(perm) then
      perm:=perm^-1;
      new:=new^perm;
    fi;
    return new;
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

    list := [1..Size(D)];
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

BindGlobal( "CycleByPosOp", function( g, D, blist, fst, pnt, act )
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
end );

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
    next := 0;
    while true do
        next := Position( blist, false, next );
        if next = fail then
            return Immutable( orbs );
        fi;
        pnt := D[ next ];
        orb := CycleOp( g, D[ next ], act );
        Add( orbs, orb );
        for pnt  in orb  do
            pos := PositionCanonical( D, pnt );
            if pos <> fail  then
                blist[ pos ] := true;
            fi;
        od;
    od;
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
        "via action homomorphism", true,
        [ IsGroup, IsList, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, seed, gens, acts, act )
    local   hom,  B;

    if Length(D)=1 then return Immutable([D]);fi;
    hom := ActionHomomorphism( G, D, gens, acts, act );
    B := Blocks( ImagesSource( hom ), [ 1 .. Length( D ) ],
      Set(seed,x->Position(D,x)) );
    B:=List( B, b -> D{ b } );
    # force sortedness
    if Length(B[1])>0 and CanEasilySortElements(B[1][1]) then
      B:=AsSSortedList(List(B,i->Immutable(Set(i))));
      IsSSortedList(B);
    fi;
    return B;
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
            blksH,      # blocks of <H>
            onsetact;   # induces set action

    blks := BlocksOp( G, D, seed, gens, acts, act );

    # iterate until the action becomes primitive
    H := G;
    blksH := blks;
    onsetact:=function(l,g)
      return Set(l,i->act(i,g));
    end;

    while Length( blksH ) <> 1  do
        H     := Action( H, blksH, onsetact );
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
#F  OrbitLengths( <arg> )
##
InstallMethod( OrbitLengths,"compute orbits", true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    return Immutable( List( Orbits( G, D, gens, acts, act ), Length ) );
end );

#############################################################################
##
#F  OrbitLengthsDomain( <arg> )
##
InstallMethod( OrbitLengthsDomain,"compute orbits", true,
    OrbitsishReq, 0,
    function( G, D, gens, acts, act )
    return Immutable( List( OrbitsDomain( G, D, gens, acts, act ), Length ) );
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
#F  CycleIndex( <arg> ) . . . . . . . . . . . . . . . . . . . cycle lengths
##
InstallGlobalFunction( CycleIndex, function( arg )
local cs, g, dom, op;

  # get/test arguments
  cs:=Length(arg)>0
        and (IsMultiplicativeElementWithInverse(arg[1]) or IsGroup(arg[1]));
  if cs then
    g:=arg[1];
    if Length(arg)<2 then
      cs:= IsPerm(g) or IsPermGroup(g);
      if cs then
        dom:=MovedPoints(g);
      fi;
    else
      dom:=arg[2];
    fi;

    if Length(arg)<3 then
      op:=OnPoints;
    else
      op:=arg[3];
      cs:=cs and IsFunction(op);
    fi;
  fi;
  if not cs then
    Error("usage: CycleIndex(<g>,<Omega>[,<act>])");
  fi;
  return CycleIndexOp( g, dom, op );
end );

InstallOtherMethod(CycleIndexOp,"element",true,
  [IsMultiplicativeElementWithInverse,IsListOrCollection,IsFunction ],0,
function( g, dom, act )
local c, i;
  c:=Indeterminate(Rationals,1)^0;
  for i in CycleLengthsOp(g,dom,act) do
    c:=c*Indeterminate(Rationals,i);
  od;
  return c;
end);

InstallMethod(CycleIndexOp,"finite group",true,
  [IsGroup and IsFinite,IsListOrCollection,IsFunction ],0,
function( g, dom, act )
  return 1/Size(g)*
  Sum(ConjugacyClasses(g),i->Size(i)*CycleIndexOp(Representative(i),dom,act));
end);

#############################################################################
##
#F  IsTransitive( <G>, <D>, <gens>, <acts>, <act> ) . . . . transitivity test
##
##  We cannot assume that <G> acts on <D>.
##  Thus it is in general not sufficient to check whether <D> is a subset of
##  the <G>-orbit of a point in <D>, or whether <D> and this orbit have the
##  same size.
##
InstallMethod( IsTransitive,
    "compare with orbit of element",
    OrbitsishReq,
function( G, D, gens, acts, act )
    return Length(D)=0 or IsEqualSet( OrbitOp( G, D[1], gens, acts, act ), D );
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
           and Length( Blocks( G, D, gens, acts, act ) ) <= 1;
end );


#############################################################################
##
#M  SetEarns( <G>, fail ) . . . . . . . . . . . . . . . . .  never set `fail'
##
# the following is the system setter for `Earns'.
SET_EARNS := SETTER_FUNCTION(
    "Earns", HasEarns );

InstallOtherMethod( SetEarns,"deduce not primitive affine",
    true, [ IsGroup, IsList and IsEmpty ], 0,
function( G, emptylist )
    Setter( IsPrimitiveAffine )( G, false );
    SET_EARNS(G,emptylist);
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
           and Earns( G, D, gens, acts, act ) <> [];
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
      ReturnTrue);

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
              # don't make it a subset!
              xset:=ExternalSet(G,D,gens,acts,act);
            else
              D := OrbitOp( G, D,d, gens, acts, act );
              # don't make it a subset!
              xset:=ExternalSet(G,D,gens,acts,act);
              #xset:=ExternalOrbitOp( G, D, d, gens, acts, act );
            fi;
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
            gen,        # generator of the group <G>
            pnt,        # point in the orbit <orb>
            img,        # image of the point <pnt> under the generator <gen>
            by,         # <by>[<pnt>] is a gen taking <frm>[<pnt>] to <pnt>
            dict,       # dictionary
            pos,        # position
            frm;        # where <frm>[<pnt>] lies earlier in <orb> than <pnt>

    d:=Immutable(d);
    e:=Immutable(e);
    dict:=NewDictionary(d,true);
    orb := [ d ];
    AddDictionary(dict,d,1);

    if act=OnPairs or act=OnTuples and CanComputeSizeAnySubgroup(G) then

      if Length( d ) <> Length( e ) then
        return fail;
      fi;

      # a well-behaving group acts on tuples. We compute the representative
      # iteratively, by mapping element for element
      rep:=One(G);
      d:=ShallowCopy(d);
      for pnt in [1..Length(d)] do
        img:=RepresentativeAction(G,d[pnt],e[pnt],OnPoints);
        if img=fail then
          return fail;
        fi;
        rep:=rep*img;
        for pos in [pnt+1..Length(d)] do
          d[pos]:=OnPoints(d[pos],img);
        od;
        G:=Stabilizer(G,e[pnt],OnPoints);
      od;
      return rep;
    else
      # standard action. If act is OnPoints, it should be as fast as pnt^gen.
      # So there should be no reason to split cases.
      if d = e  then return One( G );  fi;
      by  := [ One( G ) ];
      frm := [ 1 ];
      for pnt  in orb  do
          for gen  in GeneratorsOfGroup( G )  do
              img := act(pnt,gen);
              MakeImmutable(img);
              if img = e  then
                  rep := gen;
                  while pnt <> d  do
                    pos:=LookupDictionary(dict,pnt);
                    rep := by[ pos ] * rep;
                    pnt := frm[ pos ];
                  od;
                  Assert(2,act(d,rep)=e);
                  return rep;
              elif not KnowsDictionary(dict,img) then
                  Add( orb, img );
                  AddDictionary( dict, img, Length(orb) );
                  Add( frm, pnt );
                  Add( by,  gen );
              fi;
          od;
      od;
      return fail;
    fi;

#    # other action
#    else
#        if d = e  then return One( G );  fi;
#        by  := [ One( G ) ];
#        frm := [ 1 ];
#        for pnt  in orb  do
#            for gen  in GeneratorsOfGroup( G )  do
#                img := act( pnt, gen );
#                if img = e  then
#                    rep := gen;
#                    while pnt <> d  do
#                        rep := by[ Position(orb,pnt) ] * rep;
#                        pnt := frm[ Position(orb,pnt) ];
#                    od;
#                    return rep;
#                elif not img in set  then
#                    Add( orb, img );
#                   if cansort then
#                     AddSet( set, img );
#                   fi;
#                    Add( frm, pnt );
#                    Add( by,  gen );
#                fi;
#            od;
#        od;
#        return fail;
#
#    fi;
#
#    # special case for action on pairs
#    elif act = OnPairs  then
#        if d = e  then return One( G );  fi;
#        by  := [ One( G ) ];
#        frm := [ 1 ];
#        for pnt  in orb  do
#            for gen  in GeneratorsOfGroup( G )  do
#                img := [ pnt[1]^gen, pnt[2]^gen ];
#                if img = e  then
#                    rep := gen;
#                    while pnt <> d  do
#                        rep := by[ Position(orb,pnt) ] * rep;
#                        pnt := frm[ Position(orb,pnt) ];
#                    od;
#                    return rep;
#                elif not img in set  then
#                    Add( orb, img );
#                   if cansort then
#                     AddSet( set, img );
#                   fi;
#                    Add( frm, pnt );
#                    Add( by,  gen );
#                fi;
#            od;
#        od;
#        return fail;
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

InstallOtherMethod( StabilizerOp,
        "`OrbitStabilizerAlgorithm' with domain",true,
        [ IsGroup , IsObject,
          IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
function( G, D, d, gens, acts, act )
local   orbstab;

  orbstab:=OrbitStabilizerAlgorithm(G,D,false,gens,acts,
              rec(pnt:=d,act:=act,onlystab:=true));
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
                                      rec(pnt:=d,act:=act,onlystab:=true));
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
    if NrMovedPoints(Image(hom))<>Length(D) then
      Error("RankAction: action must be transitive");
    fi;
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
    local S,olen;
    if    act <> OnPoints
       or not IsIdenticalObj( gens, acts )  then
        TryNextMethod();
    fi;

    if IsFinite(G) then
      S:=Stabilizer( G, D, D[ 1 ], act);
      olen:=IndexNC(G,S);
    else
      S:=OrbitStabilizer(G,D,D[1],gens,acts,act);
      olen:=Length(S.orbit);
      S:=S.stabilizer;
    fi;
    if olen<>Length(D) then
      Error("RankAction: action must be transitive");
    fi;
    return Length( OrbitsDomain( S, D, act ) );
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
local   xset,he,gp,p,canfail,bas,fun;
  canfail:=ValueOption("actioncanfail")=true;
  xset := UnderlyingExternalSet( hom );
  he:=HomeEnumerator(xset);
  fun:=FunctionAction(xset);
  # can we compute the image cheaper using stabilizer chain methods?
  if not canfail and HasImagesSource(hom) then
    gp:=ImagesSource(hom);
    if HasStabChainMutable(gp) or HasStabChainImmutable(gp) then
      bas:=BaseStabChain(StabChain(gp));
      if Length(bas)*50<Length(he) then
        p:=RepresentativeActionOp(gp,bas,
            List(bas,x->PositionCanonical(he,fun(he[x],elm))),
            OnTuples);
        return p;
      fi;
    fi;
  fi;

  p:=Permutation(elm,he,fun);
  if p=fail then
    if canfail then
      return fail;
    fi;
    Error("Action not well-defined. See the manual section\n",
          "``Action on canonical representatives''.");
  fi;
  return p;
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
#M  MappingGeneratorsImages( <map> )  . . . . .  for group homomorphism
##
InstallMethod( MappingGeneratorsImages, "for action hom that is `ByAsGroup'",
    true, [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
            IsActionHomomorphism ], 0,
function( map )
local gens;
  gens:= GeneratorsOfGroup( PreImagesRange( map ) );
  return [gens, List( gens, g -> ImageElmActionHomomorphism( map, g ) ) ];
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <ophom>, <elm> )
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
  "for action homomorphism", true, [ IsActionHomomorphism ], 0,
function( hom )
local map,mapi;
  if HasIsSurjective(hom) and IsSurjective(hom) then
    return KernelOfMultiplicativeGeneralMapping(
            AsGroupGeneralMappingByImages( hom ) );
  else
    Range( hom );
    mapi := MappingGeneratorsImages( hom );
    map := GroupHomomorphismByImagesNC( Source( hom ), ImagesSource( hom ),
              mapi[1], mapi[2] );
    CopyMappingAttributes( hom,map );
    return KernelOfMultiplicativeGeneralMapping(map);
  fi;
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
    return RestrictedPermNC( Permutation( elm, HomeEnumerator( xset ),
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
  local   V, xset,lab,f;

  # is this method applicable? Test whether the domain contains a vector
  # space basis (respectively just get this basis).
  lab:=LinearActionBasis(hom);
  if lab=fail then
    TryNextMethod();
  fi;

  # PreImagesRepresentative does not test membership
  #if not elm in Image( hom )  then return fail; fi;
  xset:=UnderlyingExternalSet(hom);
  V := HomeEnumerator(xset);
  f:=DefaultFieldOfMatrixGroup(Source(hom));

  if not IsBound(hom!.linActBasisPositions) then
    hom!.linActBasisPositions:=List(lab,i->PositionCanonical(V,i));
  fi;
  if not IsBound(hom!.linActInverse) then
    lab:=ImmutableMatrix(f,lab);
    hom!.linActInverse:=Inverse(lab);
  fi;

  elm:=OnTuples(hom!.linActBasisPositions,elm); # image points
  elm:=V{elm}; # the corresponding vectors
  f:=DefaultFieldOfMatrixGroup(Source(hom));
  elm:=ImmutableMatrix(f,elm);

  return hom!.linActInverse*elm;
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . .  build matrix
##
InstallMethod( PreImagesRepresentative,"IsProjectiveActionHomomorphism",
  FamRangeEqFamElm, [ IsProjectiveActionHomomorphism, IsPerm ], 0,
function( hom, elm )
  local   V,  mat, xset,lab,f,dim,sol,i;

  # is this method applicable? Test whether field
  # finite, that the domain contains a vector
  # space basis (respectively just get this basis).
  if not IsFFECollection(DefaultFieldOfMatrixGroup(ActingDomain(UnderlyingExternalSet(hom)))) then
    TryNextMethod();
  fi;
  lab:=LinearActionBasis(hom);
  if lab=fail then
    TryNextMethod();
  fi;

  # PreImagesRepresentative does not test membership
  #if not elm in Image( hom )  then return fail; fi;
  xset:=UnderlyingExternalSet(hom);
  V := HomeEnumerator(xset);
  f:=DefaultFieldOfMatrixGroup(Source(hom));
  dim:=DimensionOfMatrixGroup(Source(hom));

  elm:=OnTuples(hom!.projActBasisPositions,elm); # image points
  elm:=V{elm}; # the corresponding vectors

  mat:=elm{[1..dim]};
  sol:=SolutionMat(mat,elm[dim+1]);
  for i in [1..dim] do
    mat[i]:=sol[i]*mat[i];
  od;
  mat:=hom!.projActInverse*ImmutableMatrix(f,mat);

  # correct scalar using determinant if needed
  if hom!.correctionFactors[1]<>fail then
    V:=DeterminantMat(mat);
    if not IsOne(V) then
      mat:=mat*hom!.correctionFactors[2][
              PositionSorted(hom!.correctionFactors[1],V)];
    fi;
  fi;

  return mat;
end);

#############################################################################
##
#A  LinearActionBasis(<hom>)
##
InstallMethod(LinearActionBasis,"find basis in domain",true,
  [IsLinearActionHomomorphism],0,
function(hom)
local xset,D,b,t,i,r,pos;
  xset:=UnderlyingExternalSet(hom);
  if Size(xset)=0 then
    return fail;
  fi;
  pos:=[];
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
      Add(pos,i);
      Add(t,ShallowCopy(D[i]));
      TriangulizeMat(t); # for faster rank tests
    fi;
    i:=i+1;
  od;
  if Length(b)=r then
    # this implies injectivity
    hom!.linActBasisPositions:=pos;
    SetIsInjective(hom,true);
    return b;
  else
    return fail; # does not span
  fi;
end);

#############################################################################
##
#A  LinearActionBasis(<hom>)
##
InstallOtherMethod(LinearActionBasis,"projective with extra vector",true,
  [IsProjectiveActionHomomorphism],0,
function(hom)
local xset,D,b,t,i,r,binv,pos,kero,dets,roots,dim,f;
  xset:=UnderlyingExternalSet(hom);
  if Size(xset)=0 then
    return fail;
  fi;

  # will the determinants suffice to get suitable scalars?
  dim:=DimensionOfMatrixGroup(Source(hom));
  f:=DefaultFieldOfMatrixGroup(Source(hom));

  roots:=Set(RootsOfUPol(f,X(f)^dim-1));

  D:=List(GeneratorsOfGroup(Source(hom)),DeterminantMat);
  D:=AsSSortedList(Group(D));

  if Length(roots)<=1 then
    # 1 will always be root
    kero:=[One(f)];
  elif HasIsNaturalGL(Source(hom)) and IsNaturalGL(Source(hom)) then
    # the full GL clearly will contain the kernel
    kero:=roots; # to skip test
  elif not IsSubset(D,roots) then
    # even the kernel determinants are not reached, so clearly kernel not in
    return fail;
  else
    kero:=List(AsSSortedList(KernelOfMultiplicativeGeneralMapping(hom)),x->x[1][1]^dim);
  fi;

  if not IsSubset(kero,roots) then
    # we cannot fix the scalar with the determinant
    return fail;
  fi;

  dets:=[];
  roots:=[];
  for i in Filtered(AsSSortedList(f),x->not IsZero(x)) do
    b:=i^dim;
    if not b in dets then
      Add(dets,b);
      Add(roots,i^-1); # the factor by which we must correct
    fi;
  od;
  SortParallel(dets,roots);

  if IsSubset(D,dets) then
    dets:=fail; # not that we do not need to correct with determinant as all
                # values are fine
  fi;

  # find a basis from the domain.
  D:=HomeEnumerator(xset);
  b:=[];
  t:=[];
  r:=Length(D[1]);
  i:=1;
  pos:=[];
  while Length(b)<r and i<=Length(D) do
    if RankMat(Concatenation(t,[D[i]]))>Length(t) then
      # new indep. vector
      Add(b,D[i]);
      Add(pos,i);
      Add(t,ShallowCopy(D[i]));
      TriangulizeMat(t); # for faster rank tests
    fi;
    i:=i+1;
  od;
  if Length(b)<r then
    return fail;
  fi;

  # try to find a vector that has nonzero coefficients for all b
  binv:=Inverse(ImmutableMatrix(f,b));
  while i<=Length(D) do
    if ForAll(D[i]*binv,x->not IsZero(x)) then
      Add(b,D[i]);
      Add(pos,i);
      hom!.projActBasisPositions:=pos;
      hom!.projActInverse:=ImmutableMatrix(f,binv*Inverse(DiagonalMat(D[i]*binv)));
      hom!.correctionFactors:=[dets,roots];
      return ImmutableMatrix(f,b);
    fi;
    i:=i+1;
  od;

  return fail; # no extra vector found
end);

#############################################################################
##
#M  DomainForAction( <pnt>, <acts>,<act> )
##
InstallMethod(DomainForAction,"permutations on lists of integers",true,
  [IsList,IsListOrCollection and IsPermCollection,IsFunction],0,
function(pnt,acts,act)
  local m;
  if not (Length(pnt)>0 and ForAll(pnt,IsPosInt) and
    ForAll(acts,IsPerm) and
    (act=OnSets or act=OnPoints or act=OnRight or act=\^)) then
    TryNextMethod();
  fi;
  m:=Maximum(Maximum(pnt),LargestMovedPoint(acts));
  # workaround to avoid creating formal objects of bounded tuples
  return ["BoundedTuples",[1..m],Length(pnt)];
end);

#############################################################################
##
#M  DomainForAction( <pnt>, <acts>,<act> )
##
InstallMethod(DomainForAction,"default: fail",true,
  [IsObject,IsListOrCollection,IsFunction],0,
ReturnFail);

#############################################################################
##
#M  AbelianSubfactorAction(<G>,<M>,<N>)
##
InstallMethod(AbelianSubfactorAction,"generic:use modulo pcgs",true,
  [IsGroup,IsGroup,IsGroup],0,
function(G,M,N)
local p,n,f,o,v,ran,exp,H,phi,alpha;
  p:=ModuloPcgs(M,N);
  n:=Length(p);
  f:=GF(RelativeOrders(p)[1]);
  o:=One(f);
  v:=f^n;
  ran:=[1..n];
  exp:=ListWithIdenticalEntries(n,0);
  f:=Size(f);
  phi:=LinearActionLayer(G,p);
  H:=Group(phi);
  UseFactorRelation(G,fail,H);
  phi:=GroupHomomorphismByImagesNC(G,H,GeneratorsOfGroup(G),phi);

  alpha:=GroupToAdditiveGroupHomomorphismByFunction(M,v,function(e)
    e:=ExponentsOfPcElement(p,e)*o;
    return ImmutableVector(f,e,true);
  end,
  function(r)
  local i,l;
    l:=exp;
    for i in ran do
      l[i]:=Int(r[i]);
    od;
    return PcElementByExponentsNC(p,l);
  end);
  return [phi,alpha,p];
end);


#############################################################################
##
#M  IsInjective( <acthom> )
##
##  This is triggered by a fallback method of PreImageElm if it is not
##  yet known whether the action homomorphism is injective or not.
##  If there exists a LinearActionBasis, then the hom is injective
##  and the better method for PreImageElm is taken.
##
InstallMethod( IsInjective, "for a linear action homomorphism",
  [IsLinearActionHomomorphism],
  function( a )
    local b;
    b := LinearActionBasis(a);
    if b = fail then
        TryNextMethod();
    fi;
    return true;
  end );
