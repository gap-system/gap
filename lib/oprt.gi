#############################################################################
##
#W  oprt.gi                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.oprt_gi :=
    "@(#)$Id$";

#############################################################################
##
#R  IsSubsetEnumerator  . . . . . . . . . . . . . . .  enumerator for subsets
##
IsSubsetEnumerator := NewRepresentation( "IsSubsetEnumerator",
    IsEnumerator and IsAttributeStoringRep,
    [ "homeEnumerator", "sublist" ] );

#############################################################################
##
#M  Length( <senum> ) . . . . . . . . . . . . . . . . .  for such enumerators
##
InstallMethod( Length, true, [ IsSubsetEnumerator ], 0,
    senum -> SizeBlist( senum!.sublist ) );

#############################################################################
##
#M  <senum>[ <num> ]  . . . . . . . . . . . . . . . . .  for such enumerators
##
InstallMethod( \[\], true, [ IsSubsetEnumerator, IsPosRat and IsInt ], 0,
    function( senum, num )
    num := PositionNthTrueBlist( senum!.sublist, num );
    if num = fail  then  return fail;
                   else  return senum!.homeEnumerator[ num ];  fi;
end );

#############################################################################
##
#M  PositionCanonical( <senum>, <elm> ) . . . . . . . .  for such enumerators
##
InstallMethod( PositionCanonical, true, [ IsSubsetEnumerator, IsObject ], 0,
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
InstallMethod( AsList, true, [ IsSubsetEnumerator ], 0,
    senum -> senum!.homeEnumerator{ ListBlist
            ( [ 1 .. Length( senum!.homeEnumerator ) ], senum!.sublist ) } );

#############################################################################
##

#F  ExternalSet( <arg> )  . . . . . . . . . . . . .  external set constructor
##
InstallMethod( ExternalSetOp,
        "G, D, gens, oprs, opr", true,
        OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return ExternalSetByFilterConstructor( IsExternalSet,
                   G, D, gens, oprs, opr );
end );

ExternalSetByFilterConstructor := function( filter, G, D, gens, oprs, opr )
    local   xset;

    xset := rec(  );
    if IsPcgs( gens )  then
        filter := filter and IsExternalSetByPcgs;
    fi;
    if not IsIdentical( gens, oprs )  then
        filter := filter and IsExternalSetByOperatorsRep;
        xset.generators    := gens;
        xset.operators     := oprs;
        xset.funcOperation := opr;
    else
        filter := filter and IsExternalSetDefaultRep;
    fi;
    Objectify( NewType( FamilyObj( D ), filter ), xset );
    SetActingDomain  ( xset, G );
    SetHomeEnumerator( xset, D );
    if not IsExternalSetByOperatorsRep( xset )  then
        SetFunctionOperation( xset, opr );
    fi;
    return xset;
end;

# The following function expects the type as first argument,  to avoid a call
# of `NewType'. It is called by `ExternalSubsetOp' and `ExternalOrbitOp' when
# they are called with an external set (which has already stored this type).
#
ExternalSetByTypeConstructor := function( type, G, D, gens, oprs, opr )
    local   xset;
    
    xset := Objectify( type, rec(  ) );
    if not IsIdentical( gens, oprs )  then
        xset!.generators    := gens;
        xset!.operators     := oprs;
        xset!.funcOperation := opr;
    fi;
    xset!.ActingDomain   := G;
    xset!.HomeEnumerator := D;
    if not IsExternalSetByOperatorsRep( xset )  then
        xset!.FunctionOperation := opr;
    fi;
    return xset;
end;

#############################################################################
##
#M  Enumerator( <xset> )  . . . . . . . . . . . . . . . .  the underlying set
##
InstallMethod( Enumerator, true, [ IsExternalSet ], 0,
    HomeEnumerator );

#############################################################################
##
#M  FunctionOperation( <p>, <g> ) . . . . . . . . . . . .  operation function
##
InstallMethod( FunctionOperation, true, [ IsExternalSetByOperatorsRep ], 0,
    xset -> function( p, g )
    local   D;
        D := Enumerator( xset );
        return D[ PositionCanonical( D, p ) ^
                  ( g ^ OperationHomomorphismAttr( xset ) ) ];
    end );
    
#############################################################################
##
#M  PrintObj( <xset> )  . . . . . . . . . . . . . . . . print an external set
##
InstallMethod( PrintObj, true, [ IsExternalSet ], 0,
    function( xset )
    Print( HomeEnumerator( xset ) );
end );

#############################################################################
##
#M  Representative( <xset> )  . . . . . . . . . . first element in enumerator
##
InstallMethod( Representative, true, [ IsExternalSet ], 0,
    xset -> Enumerator( xset )[ 1 ] );

#############################################################################
##
#F  ExternalSubset( <arg> ) . . . . . . . . . . . . .  external set on subset
##
InstallMethod( ExternalSubsetOp,
        "G, D, start, gens, oprs, opr", true,
        [ IsGroup, IsList, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, start, gens, oprs, opr )
    local   xset;
    
    xset := ExternalSetByFilterConstructor( IsExternalSubset,
                    G, D, gens, oprs, opr );
    xset!.start := Immutable( start );
    return xset;
end );

InstallOtherMethod( ExternalSubsetOp,
        "G, xset, start, gens, oprs, opr", true,
        [ IsGroup, IsExternalSet, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, xset, start, gens, oprs, opr )
    local   type,  xsset;

    type := TypeObj( xset );

    # The type of an external set can store the type of its external subsets,
    # to avoid repeated calls of `NewType'.
    if not IsBound( type![XSET_XSSETTYPE] )  then
        xsset := ExternalSetByFilterConstructor( IsExternalSubset,
                         G, HomeEnumerator( xset ), gens, oprs, opr );
        type![XSET_XSSETTYPE] := TypeObj( xsset );
    else
        xsset := ExternalSetByTypeConstructor( type![XSET_XSSETTYPE],
                         G, HomeEnumerator( xset ), gens, oprs, opr );
    fi;
    
    xsset!.start := Immutable( start );
    return xsset;
end );

InstallOtherMethod( ExternalSubsetOp,
        "G, start, gens, oprs, opr", true,
        [ IsGroup, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, start, gens, oprs, opr )
    return ExternalSubsetOp( G,
                   Concatenation( Orbits( G, start, gens, oprs, opr ) ),
                   start, gens, oprs, opr );
end );

InstallMethod( PrintObj, true, [ IsExternalSubset ], 0,
    function( xset )
    Print( xset!.start, "^G < ", HomeEnumerator( xset ) );
end );

#############################################################################
##
#M  Enumerator( <xset> )  . . . . . . . . . . . . . . .  for external subsets
##
InstallMethod( Enumerator, true, [ IsExternalSubset ], 0,
    function( xset )
    local   G,  henum,  gens,  oprs,  opr,  sublist,  pnt,  pos;
    
    G := ActingDomain( xset );
    henum := HomeEnumerator( xset );
    if IsExternalSetByOperatorsRep( xset )  then
        gens := xset!.generators;
        oprs := xset!.operators;
        opr  := xset!.funcOperation;
    else
        gens := GeneratorsOfGroup( G );
        oprs := gens;
        opr  := FunctionOperation( xset );
    fi;
    sublist := BlistList( [ 1 .. Length( henum ) ], [  ] );
    for pnt  in xset!.start  do
        pos := PositionCanonical( henum, pnt );
        if not sublist[ pos ]  then
            OrbitByPosOp( G, henum, sublist, pos, pnt, gens, oprs, opr );
        fi;
    od;
    return Objectify( NewType( FamilyObj( henum ), IsSubsetEnumerator ),
        rec( homeEnumerator := henum,
                    sublist := sublist ) );
end );

#############################################################################
##
#F  ExternalOrbit( <arg> )  . . . . . . . . . . . . . . external set on orbit
##
InstallMethod( ExternalOrbitOp,
        "G, D, pnt, gens, oprs, opr", true,
        OrbitishReq, 0,
    function( G, D, pnt, gens, oprs, opr )
    local   xorb;
    
    xorb := ExternalSetByFilterConstructor( IsExternalOrbit,
                    G, D, gens, oprs, opr );
    SetRepresentative( xorb, pnt );
    xorb!.start := Immutable( [ pnt ] );
    return xorb;
end );

InstallOtherMethod( ExternalOrbitOp,
        "G, xset, pnt, gens, oprs, opr", true,
        [ IsGroup, IsExternalSet, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, xset, pnt, gens, oprs, opr )
    local   type,  xorb;

    type := TypeObj( xset );
    
    # The type of  an external set  can store the type  of external orbits of
    # its points, to avoid repeated calls of `NewType'.
    if not IsBound( type![XSET_XORBTYPE] )  then
        xorb := ExternalSetByFilterConstructor( IsExternalOrbit,
                        G, HomeEnumerator( xset ), gens, oprs, opr );
        type![XSET_XORBTYPE] := TypeObj( xorb );
    else
        xorb := ExternalSetByTypeConstructor( type![XSET_XORBTYPE],
                        G, HomeEnumerator( xset ), gens, oprs, opr );
    fi;
    
    SetRepresentative( xorb, pnt );
    xorb!.start := Immutable( [ pnt ] );
    return xorb;
end );

InstallOtherMethod( ExternalOrbitOp,
        "G, pnt, gens, oprs, opr", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, oprs, opr )
    return ExternalOrbitOp( G, OrbitOp( G, pnt, gens, oprs, opr ),
                   gens, oprs, opr );
end );

InstallMethod( PrintObj, true, [ IsExternalOrbit ], 0,
    function( xorb )
    Print( Representative( xorb ), "^G < ", HomeEnumerator( xorb ) );
end );

#############################################################################
##
#M  AsList( <xorb> )  . . . . . . . . . . . . . . . . . .  by orbit algorithm
##
InstallMethod( AsList, true, [ IsExternalOrbit ], 0,
    xorb -> Orbit( xorb, Representative( xorb ) ) );

#############################################################################
##
#M  <xorb> = <yorb> . . . . . . . . . . . . . . . . . . by ``conjugacy'' test
##
InstallMethod( \=, IsIdentical, [ IsExternalOrbit, IsExternalOrbit ], 0,
    function( xorb, yorb )
    if not IsIdentical( ActingDomain     ( xorb ), ActingDomain     ( yorb ) )
    or not IsIdentical( FunctionOperation( xorb ), FunctionOperation( yorb ) )
       then
        TryNextMethod();
    fi;
    return RepresentativeOperation( xorb, Representative( xorb ),
                   Representative( yorb ) ) <> fail;
end );

InstallMethod( \=, IsIdentical,
        [ IsExternalOrbit and HasCanonicalRepresentativeOfExternalSet,
          IsExternalOrbit and HasCanonicalRepresentativeOfExternalSet ],
        SUM_FLAGS,
    function( xorb, yorb )
    if not IsIdentical( ActingDomain     ( xorb ), ActingDomain     ( yorb ) )
    or not IsIdentical( FunctionOperation( xorb ), FunctionOperation( yorb ) )
       then
        TryNextMethod();
    fi;
    return CanonicalRepresentativeOfExternalSet( xorb ) =
           CanonicalRepresentativeOfExternalSet( yorb );
end );

#############################################################################
##
#M  <xorb> < <yorb> . . . . . . . . . . . . . . . . .  by ``canon. rep'' test
##
InstallMethod( \<, IsIdentical,
        [ IsExternalOrbit and HasCanonicalRepresentativeOfExternalSet,
          IsExternalOrbit and HasCanonicalRepresentativeOfExternalSet ],
        SUM_FLAGS,
    function( xorb, yorb )
    if not IsIdentical( ActingDomain     ( xorb ), ActingDomain     ( yorb ) )
    or not IsIdentical( FunctionOperation( xorb ), FunctionOperation( yorb ) )
       then
        TryNextMethod();
    fi;
    return CanonicalRepresentativeOfExternalSet( xorb ) <
           CanonicalRepresentativeOfExternalSet( yorb );
end );

#############################################################################
##
#M  <pnt> in <xorb> . . . . . . . . . . . . . . . . . . by ``conjugacy'' test
##
InstallMethod( \in, IsElmsColls, [ IsObject, IsExternalOrbit ], 0,
    function( pnt, xorb )
    return RepresentativeOperation( xorb, Representative( xorb ),
                   pnt ) <> fail;
end );

InstallMethod( \in, IsElmsColls, [ IsObject,
        IsExternalOrbit and HasEnumerator ], 0,
    function( pnt, xorb )
    local   enum;
    
    enum := Enumerator( xorb );
    if IsConstantTimeAccessList( enum )  then  return pnt in enum;
                                         else  TryNextMethod();     fi;
end );

InstallMethod( \in, IsElmsColls, [ IsObject,
        IsExternalOrbit and HasCanonicalRepresentativeOfExternalSet ], 0,
    function( pnt, xorb )
    if CanonicalRepresentativeOfExternalSet( xorb ) = pnt  then
        return true;
    else
        TryNextMethod();
    fi;
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

#M  OperationHomomorphism( <xset> ) . . . . . . . . .  operation homomorphism
##
OperationHomomorphism := function( arg )
    local   attr,  xset,  p;
    
    if arg[ Length( arg ) ] = "surjective"  then
        attr := SurjectiveOperationHomomorphismAttr;
        Unbind( arg[ Length( arg ) ] );
    else
        attr := OperationHomomorphismAttr;
    fi;
    if Length( arg ) = 1  then
        xset := arg[ 1 ];
    elif     Length( arg ) = 2
         and IsComponentObjectRep( arg[ 2 ] )
         and IsBound( arg[ 2 ]!.operationHomomorphism )
         and IsOperationHomomorphism( arg[ 2 ]!.operationHomomorphism )
         and Source( arg[ 2 ]!.operationHomomorphism ) = arg[ 1 ]  then
        return arg[ 2 ]!.operationHomomorphism;  # GAP-3 compatability
    else
        if IsFunction( arg[ Length( arg ) ] )  then  p := 1;
                                               else  p := 0;  fi;
        if Length( arg ) mod 2 = p  then
            xset := CallFuncList( ExternalSet, arg );
        elif IsIdentical( FamilyObj( arg[ 2 ] ),
                          FamilyObj( arg[ 3 ] ) )  then
            xset := CallFuncList( ExternalSubset, arg );
        else
            xset := CallFuncList( ExternalOrbit, arg );
        fi;
    fi;
    return attr( xset );
end;

OperationHomomorphismConstructor := function( xset, surj )
    local   G,  D,  opr,  fam,  filter,  hom,  i;
    
    G := ActingDomain( xset );
    D := HomeEnumerator( xset );
    opr := FunctionOperation( xset );
    fam := GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                  PermutationsFamily );
    if IsExternalSubset( xset )  then
        filter := IsOperationHomomorphismSubset;
    else
        filter := IsOperationHomomorphism;
    fi;
    if surj  then
        filter := filter and IsSurjective;
    fi;
    hom := rec(  );
    if IsExternalSetByOperatorsRep( xset )  then
        filter := filter and IsOperationHomomorphismByOperators;
    elif     IsMatrixGroup( G )
         and not IsOneDimSubspacesTransversal( D )
         and IsScalarList( D[ 1 ] )
         and opr in [ OnPoints, OnRight ]  then
        if     not IsExternalSubset( xset )
           and IsDomainEnumerator( D )
           and IsFreeLeftModule( UnderlyingCollection( D ) )
           and IsFullRowModule( UnderlyingCollection( D ) )
           and IsLeftActedOnByDivisionRing( UnderlyingCollection( D ) )  then
            filter := filter and IsLinearOperationHomomorphism;
        else
            if IsExternalSubset( xset )  then
                if HasEnumerator( xset )  then  D := Enumerator( xset );
                                          else  D := xset!.start;         fi;
            fi;
            if IsSubset( D, IdentityMat
                       ( Length( D[ 1 ] ), One( D[ 1 ][ 1 ] ) ) )  then
                filter := filter and IsLinearOperationHomomorphism;
            fi;
        fi;
    elif not IsExternalSubset( xset )
         and IsPermGroup( G )
         and IsList( D ) and IsCyclotomicsCollection( D )
         and opr = OnPoints  then
        filter := IsConstituentHomomorphism;
        hom.conperm := MappingPermListList( D, [ 1 .. Length( D ) ] );
    elif not IsExternalSubset( xset )
         and IsPermGroup( G )
         and IsList( D )
         and ForAll( D, IsList and IsSSortedList )
         and Sum( D, Length ) = Length( Union( D ) )
         and opr = OnSets  then
        filter := IsBlocksHomomorphism;
        hom.reps := [  ];
        for i  in [ 1 .. Length( D ) ]  do
            hom.reps{ D[ i ] } := i + 0 * D[ i ];
        od;
    elif not ( IsPermGroup( G )  or  IsPcGroup( G ) )  then
        filter := filter and IsOperationHomomorphismDirectly;
    fi;
    if HasBase( xset )  then
        filter := filter and IsOperationHomomorphismByBase;
    fi;
    Objectify( NewType( fam, filter ), hom );
    SetUnderlyingExternalSet( hom, xset );
    return hom;
end;

InstallMethod( OperationHomomorphismAttr, true, [ IsExternalSet ], 0,
    xset -> OperationHomomorphismConstructor( xset, false ) );

#############################################################################
##
#M  SurjectiveOperationHomomorphism( <xset> ) .  surj. operation homomorphism
##
InstallMethod( SurjectiveOperationHomomorphismAttr, true, [ IsExternalSet ],
        0, xset -> OperationHomomorphismConstructor( xset, true ) );

#############################################################################
##
#M  PrintObj( <hom> ) . . . . . . . . . . . . print an operation homomorphism
##
InstallMethod( PrintObj, true, [ IsOperationHomomorphism ], 0,
    function( hom )
    Print( "<operation homomorphism>" );
end );

#############################################################################
##
#M  Source( <hom> ) . . . . . . . . . . . .  source of operation homomorphism
##
InstallMethod( Source, true, [ IsOperationHomomorphism ], 0,
        hom -> ActingDomain( UnderlyingExternalSet( hom ) ) );

#############################################################################
##
#M  Range( <hom> )  . . . . . . . . . . . . . range of operation homomorphism
##
InstallMethod( Range, true, [ IsOperationHomomorphism ], 0, hom ->
    SymmetricGroup( Length( HomeEnumerator(UnderlyingExternalSet(hom)) ) ) );

InstallMethod( Range, true, [ IsOperationHomomorphism and IsSurjective ], 0,
    hom -> GroupByGenerators( List( GeneratorsOfGroup( Source( hom ) ),
            gen -> ImagesRepresentative( hom, gen ) ) ) );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . .  for operation homomorphism
##
InstallMethod( AsGroupGeneralMappingByImages, true,
        [ IsOperationHomomorphism ], 0,
    function( hom )
    local   xset,  G,  D,  opr,  gens,  imgs;
    
    xset := UnderlyingExternalSet( hom );
    G := ActingDomain( xset );
    D := HomeEnumerator( xset );
    opr := FunctionOperation( xset );
    gens := GeneratorsOfGroup( G );
    imgs := List( gens, o -> Permutation( o, D, opr ) );
    return GroupHomomorphismByImages( G,
                   SymmetricGroup( Length( D ) ), gens, imgs );
end );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . . . . . if given by operators
##
InstallMethod( AsGroupGeneralMappingByImages, true,
        [ IsOperationHomomorphismByOperators ], 0,
    function( hom )
    local   xset,  G,  D,  opr,  gens,  oprs,  imgs;
    
    xset := UnderlyingExternalSet( hom );
    G := ActingDomain( xset );
    D := HomeEnumerator( xset );
    gens := xset!.generators;
    oprs := xset!.operators;
    opr  := xset!.funcOperation;
    imgs := List( oprs, o -> Permutation( o, D, opr ) );
    return GroupHomomorphismByImages( G,
                   SymmetricGroup( Length( D ) ), gens, imgs );
end );

#############################################################################
##
#F  OperationHomomorphismSubsetAsGroupGeneralMappingByImages( ... ) . . local
##
OperationHomomorphismSubsetAsGroupGeneralMappingByImages := function
    ( G, D, start, gens, oprs, opr )
    local   list,  ps,  poss,  blist,  p,  i,  gen,  img,  pos,  imgs,  hom;
    
    list := [ 1 .. Length( D ) ];
    poss := BlistList( list, List( start, b -> PositionCanonical( D, b ) ) );
    blist := StructuralCopy( poss );
    list := List( gens, gen -> ShallowCopy( list ) );
    ps := Position( poss, true );
    while ps <> fail  do
        poss[ ps ] := false;
        p := D[ ps ];
        for i  in [ 1 .. Length( gens ) ]  do
            gen := oprs[ i ];
            img := opr( p, gen );
            pos := PositionCanonical( D, img );
            list[ i ][ ps ] := pos;
            if not blist[ pos ]  then
                poss[ pos ] := true;
                blist[ pos ] := true;
            fi;
        od;
        ps := Position( poss, true );
    od;
    imgs := List( list, PermList );
    hom := GroupHomomorphismByImages( G, SymmetricGroup( Length( D ) ),
                   gens, imgs );
    return hom;
end;

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . . . . . . . . . . . . as GHBI
##
InstallMethod( AsGroupGeneralMappingByImages, true,
        [ IsOperationHomomorphismSubset ], 0,
    function( hom )
    local   xset,  G,  gens;
    
    xset := UnderlyingExternalSet( hom );
    G := ActingDomain( xset );
    gens := GeneratorsOfGroup( G );
    return OperationHomomorphismSubsetAsGroupGeneralMappingByImages( G,
           HomeEnumerator( xset ), xset!.start,
           gens, gens, FunctionOperation( xset ) );
end );

InstallMethod( AsGroupGeneralMappingByImages, true,
        [ IsOperationHomomorphismSubset
      and IsOperationHomomorphismByOperators ], 0,
    function( hom )
    local   xset;

    xset := UnderlyingExternalSet( hom );
    return OperationHomomorphismSubsetAsGroupGeneralMappingByImages(
           ActingDomain( xset ), HomeEnumerator( xset ), xset!.start,
           xset!.generators, xset!.operators, xset!.funcOperation );
end );

#############################################################################
##

#F  Operation( <arg> )  . . . . . . . . . . . . . . . . . . . operation group
##
Operation := function( arg )
    local   hom,  O;
    
    hom := CallFuncList( OperationHomomorphism, arg );
    O := ImagesSource( hom );
    O!.operationHomomorphism := hom;
    return O;
end;

#############################################################################
##
#F  Orbit( <arg> )  . . . . . . . . . . . . . . . . . . . . . . . . . . orbit
##
InstallMethod( OrbitOp,
        "G, D, pnt, [ 1gen ], [ 1opr ], opr", true,
        OrbitishReq, SUM_FLAGS,
    function( G, D, pnt, gens, oprs, opr )
    if Length( oprs ) <> 1  then  TryNextMethod();
                            else  return CycleOp( oprs[ 1 ], D, pnt, opr );
    fi;
end );

InstallMethod( OrbitOp,
        "G, D, pnt, gens, oprs, opr", true,
        OrbitishReq, 0,
    function( G, D, pnt, gens, oprs, opr )
    return OrbitByPosOp( G, D, BlistList( [ 1 .. Length( D ) ], [  ] ),
                   PositionCanonical( D, pnt ), pnt, gens, oprs, opr );
end );

OrbitByPosOp := function( G, D, blist, pos, pnt, gens, oprs, opr )
    local   orb,  p,  gen,  img;
    
    blist[ pos ] := true;
    orb := [ pnt ];
    for p  in orb  do
        for gen  in oprs  do
            img := opr( p, gen );
            pos := PositionCanonical( D, img );
            if not blist[ pos ]  then
                blist[ pos ] := true;
                Add( orb, img );
            fi;
        od;
    od;
    return Immutable( orb );
end;

InstallOtherMethod( OrbitOp,
        "G, pnt, [ 1gen ], [ 1opr ], opr", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], SUM_FLAGS,
    function( G, pnt, gens, oprs, opr )
    if Length( oprs ) <> 1  then  TryNextMethod();
                            else  return CycleOp( oprs[ 1 ], pnt, opr );  fi;
end );

InstallOtherMethod( OrbitOp,
        "G, pnt, gens, oprs, opr", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, oprs, opr )
    local   orb,  p,  i,  gen;

    orb := [ pnt ];
    for p  in orb  do
        for gen  in oprs  do
            i := opr( p, gen );
            if not i in orb  then
                Add( orb, i );
            fi;
        od;
    od;
    return Immutable( orb );
end );

#############################################################################
##
#F  OrbitStabilizer( <arg> )  . . . . . . . . . . . . .  orbit and stabilizer
##
InstallMethod( OrbitStabilizerOp,
        "G, D, pnt, gens, oprs, opr", true,
        OrbitishReq, 0,
    function( G, D, pnt, gens, oprs, opr )
    return OrbitStabilizerOp( G, pnt, gens, oprs, opr );
end );
    
InstallOtherMethod( OrbitStabilizerOp,
        "G, pnt, gens, oprs, opr", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, oprs, opr )
    local   orbstab;
    
    orbstab := OrbitStabilizerByGenerators( gens, oprs, pnt, opr );
    orbstab.stabilizer := SubgroupNC( G, orbstab.stabilizer );
    if HasSize( G )  then
        SetSize( orbstab.stabilizer, Size( G ) / Length( orbstab.orbit ) );
    fi;
    return Immutable( orbstab );
end );

#############################################################################
##
#F  OrbitStabilizerByGenerators( <gens>, <oprs>, <d>, <opr> )  Schreier's th.
##
OrbitStabilizerByGenerators := function( gens, oprs, d, opr )
    local   orb,  stb,  rep,  p,  q,  img,  sch,  i;

    orb := [ d ];
    stb := [  ];
    if not IsEmpty( oprs )  then
        rep := [ One( gens[ 1 ] ) ];
        p := 1;
        while p <= Length( orb )  do
            for i  in [ 1 .. Length( gens ) ]  do
                img := opr( orb[ p ], oprs[ i ] );
                q := Position( orb, img );
                if q = fail  then
                    Add( orb, img );
                    Add( rep, rep[ p ] * gens[ i ] );
                else
                    sch := rep[ p ] * gens[ i ] / rep[ q ];
                    if not sch in stb  then
                        Add( stb, sch );
                    fi;
                fi;
            od;
            p := p + 1;
        od;
    fi;
    return rec( orbit := orb, stabilizer := stb );
end;

OrbitStabilizerListByGenerators := function( gens, oprs, d, eq, opr )
    local   iden,  orb,  stb,  s,  rep,  r,  p,  q,  img,  sch,  i,  j;
    
    iden := Length( gens ) = 1  and  IsIdentical( gens[ 1 ], oprs );
    if iden  then
        gens := [  ];
    fi;
    orb := [ d ];
    stb := List( gens, x -> [  ] );  Add( stb, [  ] );
    s := stb[ Length( stb ) ];
    if not IsEmpty( oprs )  then
        rep := List( gens, x -> [One(x[1])] );  Add( rep, [One(oprs[1])] );
        r := rep[ Length( rep ) ];
        p := 1;
        while p <= Length( orb )  do
            for i  in [ 1 .. Length( oprs ) ]  do
                img := opr( orb[ p ], oprs[ i ] );
                q := PositionProperty( orb, o -> eq( o, img ) );
                if q = fail  then
                    Add( orb, img );
                    for j  in [ 1 .. Length( gens ) ]  do
                        Add( rep[ j ], rep[ j ][ p ] * gens[ j ][ i ] );
                    od;
                    Add( r, r[ p ] * oprs[ i ] );
                else
                    sch := r[ p ] * oprs[ i ] / r[ q ];
                    if not sch in s  then
                        Add( s, sch );
                        for j  in [ 1 .. Length( gens ) ]  do
                            Add( stb[ j ], rep[ j ][ p ] * gens[ j ][ i ] /
                                 rep[ j ][ q ] );
                        od;
                    fi;
                fi;
            od;
            p := p + 1;
        od;
    fi;
    if iden  then
        Add( stb, stb[ 1 ] );
    fi;
    return rec( orbit := orb, stabilizers := stb );
end;

#############################################################################
##
#F  Orbits( <arg> ) . . . . . . . . . . . . . . . . . . . . . . . . .  orbits
##
InstallMethod( OrbitsOp,
        "G, D, gens, oprs, opr", true,
        OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   blist,  orbs,  next,  pnt,  pos,  orb;
    
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        orb := OrbitOp( G, D[ next ], gens, oprs, opr );
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

InstallMethod( OrbitsOp,
        "G, [  ], gens, oprs, opr", true,
        [ IsGroup, IsList and IsEmpty,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, gens, oprs, opr )
    return Immutable( [  ] );
end );

#############################################################################
##
#F  SparseOperationHomomorphism( <arg> )   operation homomorphism on `[1..n]'
##
InstallMethod( SparseOperationHomomorphismOp,
        "G, D, start, gens, oprs, opr", true,
        [ IsGroup, IsList, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, start, gens, oprs, opr )
    local   list,  ps,  p,  i,  gen,  img,  pos,  imgs,  hom;

    start := List( start, p -> PositionCanonical( D, p ) );
    list := List( gens, gen -> [  ] );
    ps := 1;
    while ps <= Length( start )  do
        p := D[ start[ ps ] ];
        for i  in [ 1 .. Length( gens ) ]  do
            gen := oprs[ i ];
            img := PositionCanonical( D, opr( p, gen ) );
            pos := Position( start, img );
            if pos = fail  then
                Add( start, img );
                pos := Length( start );
            fi;
            list[ i ][ ps ] := pos;
        od;
        ps := ps + 1;
    od;
    imgs := List( list, PermList );
    hom := OperationHomomorphism( G, start, gens, oprs, opr );
    SetAsGroupGeneralMappingByImages( hom, GroupHomomorphismByImages
            ( G, SymmetricGroup( Length( start ) ), gens, imgs ) );
    return hom;
end );

InstallOtherMethod( SparseOperationHomomorphismOp,
        "G, start, gens, oprs, opr", true,
        [ IsGroup, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, start, gens, oprs, opr )
    local   list,  ps,  p,  i,  gen,  img,  pos,  imgs,  hom;

    start := ShallowCopy( start );
    list := List( gens, gen -> [  ] );
    ps := 1;
    while ps <= Length( start )  do
        p := start[ ps ];
        for i  in [ 1 .. Length( gens ) ]  do
            gen := oprs[ i ];
            img := opr( p, gen );
            pos := Position( start, img );
            if pos = fail  then
                Add( start, img );
                pos := Length( start );
            fi;
            list[ i ][ ps ] := pos;
        od;
        ps := ps + 1;
    od;
    imgs := List( list, PermList );
    hom := OperationHomomorphism( G, start, gens, oprs, opr );
    SetAsGroupGeneralMappingByImages( hom, GroupHomomorphismByImages
            ( G, SymmetricGroup( Length( start ) ), gens, imgs ) );
    return hom;
end );

#############################################################################
##
#F  ExternalOrbits( <arg> ) . . . . . . . . . . . .  list of transitive xsets
##
InstallMethod( ExternalOrbitsOp,
        "G, D, gens, oprs, opr", true,
        OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   blist,  orbs,  next,  pnt,  orb;

    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, D, pnt, gens, oprs, opr );
        SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        SetEnumerator( orb, OrbitByPosOp( G, D, blist, next, pnt,
                gens, oprs, opr ) );
        Add( orbs, orb );
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

InstallOtherMethod( ExternalOrbitsOp,
        "G, xset, gens, oprs, opr", true,
        [ IsGroup, IsExternalSet,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, xset, gens, oprs, opr )
    local   D,  blist,  orbs,  next,  pnt,  orb;

    D := Enumerator( xset );
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, xset, pnt, gens, oprs, opr );
        SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        SetEnumerator( orb, OrbitByPosOp( G, D, blist, next, pnt,
                gens, oprs, opr ) );
        Add( orbs, orb );
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

#############################################################################
##
#F  ExternalOrbitsStabilizers( <arg> )  . . . . . .  list of transitive xsets
##
InstallMethod( ExternalOrbitsStabilizersOp,
        "G, D, gens, oprs, opr", true,
        OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   blist,  orbs,  next,  pnt,  orb,  orbstab,  p;

    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, D, pnt, gens, oprs, opr );
        orbstab := OrbitStabilizer( G, D, pnt, gens, oprs, opr );
        SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        SetEnumerator( orb, orbstab.orbit );
        SetStabilizerOfExternalSet( orb, orbstab.stabilizer );
        Add( orbs, orb );
        for p  in orb  do
            blist[ PositionCanonical( D, p ) ] := true;
        od;
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

InstallOtherMethod( ExternalOrbitsStabilizersOp,
        "G, xset, gens, oprs, opr", true,
        [ IsGroup, IsExternalSet,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, xset, gens, oprs, opr )
    local   D,  blist,  orbs,  next,  pnt,  orb,  orbstab,  p;

    D := Enumerator( xset );
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, xset, pnt, gens, oprs, opr );
        orbstab := OrbitStabilizer( G, D, pnt, gens, oprs, opr );
        SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        SetEnumerator( orb, orbstab.orbit );
        SetStabilizerOfExternalSet( orb, orbstab.stabilizer );
        Add( orbs, orb );
        for p  in orb  do
            blist[ PositionCanonical( D, p ) ] := true;
        od;
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

#############################################################################
##
#F  Permutation( <arg> )  . . . . . . . . . . . . . . . . . . . . permutation
##
Permutation := function( arg )
    local   g,  D,  gens,  oprs,  opr,  xset,  hom;

    # Get the arguments.
    g := arg[ 1 ];
    if Length( arg ) = 2  and  IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        D := Enumerator( xset );
        if IsExternalSetByOperatorsRep( xset )  then
            gens := xset!.generators;
            oprs := xset!.operators;
            opr  := xset!.funcOperation;
        else
            opr := FunctionOperation( xset );
        fi;
    else
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
        fi;
    fi;
    
    if IsBound( gens )  and  not IsIdentical( gens, oprs )  then
        hom := OperationHomomorphismAttr( ExternalSetByFilterConstructor
                       ( IsExternalSet,
                         GroupByGenerators( gens ), D, gens, oprs, opr ) );
        return ImagesRepresentative( hom, g );
    else
        return PermutationOp( g, D, opr );
    fi;
end;
                                
InstallMethod( PermutationOp, true, [ IsObject, IsList, IsFunction ], 0,
    function( g, D, opr )
    local   list,  blist,  fst,  old,  new,  pnt;
    
    list := [  ];
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    fst := Position( blist, false );
    while fst <> fail  do
        pnt := D[ fst ];
        new := fst;
        repeat
            old := new;
            pnt := opr( pnt, g );
            new := PositionCanonical( D, pnt );
            if new = fail  then
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
PermutationCycle := function( arg )
    local   g,  D,  pnt,  gens,  oprs,  opr,  xset,  hom;

    # Get the arguments.
    g := arg[ 1 ];
    if Length( arg ) = 3  and  IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        pnt  := arg[ 3 ];
        D := Enumerator( xset );
        if IsExternalSetByOperatorsRep( xset )  then
            gens := xset!.generators;
            oprs := xset!.operators;
            opr  := xset!.funcOperation;
        else
            opr := FunctionOperation( xset );
        fi;
    else
        D := arg[ 2 ];
        if IsDomain( D )  then
            D := Enumerator( D );
        fi;
        pnt := arg[ 3 ];
        if IsFunction( arg[ Length( arg ) ] )  then
            opr := arg[ Length( arg ) ];
        else
            opr := OnPoints;
        fi;
        if Length( arg ) > 4  then
            gens := arg[ 4 ];
            oprs := arg[ 5 ];
        fi;
    fi;
    
    if IsBound( gens )  and  not IsIdentical( gens, oprs )  then
        hom := OperationHomomorphismAttr( ExternalSetByFilterConstructor
                       ( IsExternalSet,
                         GroupByGenerators( gens ), D, gens, oprs, opr ) );
        g := ImagesRepresentative( hom, g );
        return PermutationOp( g, CycleOp( g, PositionCanonical( D, pnt ),
                       OnPoints ), OnPoints );
    else
        return PermutationCycleOp( g, D, pnt, opr );
    fi;
end;
                                
InstallMethod( PermutationCycleOp, true,
        [ IsObject, IsList, IsObject, IsFunction ], 0,
    function( g, D, pnt, opr )
    local   list,  old,  new,  fst;
    
    list := [  ];
    fst := PositionCanonical( D, pnt );
    if fst = fail  then
        return ();
    fi;
    new := fst;
    repeat
        old := new;
        pnt := opr( pnt, g );
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
Cycle := function( arg )
    local   g,  D,  pnt,  gens,  oprs,  opr,  xset,  hom,  p;
    
    # Get the arguments.
    g := arg[ 1 ];
    if Length( arg ) = 3  and  IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        pnt  := arg[ 3 ];
        D := Enumerator( xset );
        if IsExternalSetByOperatorsRep( xset )  then
            gens := xset!.generators;
            oprs := xset!.operators;
            opr  := xset!.funcOperation;
        else
            opr := FunctionOperation( xset );
        fi;
    else
        if Length( arg ) > 2  and
           IsIdentical( FamilyObj( arg[ 2 ] ),
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
            opr := arg[ Length( arg ) ];
        else
            opr := OnPoints;
        fi;
        if Length( arg ) > p + 1  then
            gens := arg[ p + 1 ];
            oprs := arg[ p + 2 ];
        fi;
    fi;
    
    if IsBound( gens )  and  not IsIdentical( gens, oprs )  then
        hom := OperationHomomorphismAttr( ExternalOrbitOp
               ( GroupByGenerators( gens ), D, pnt, gens, oprs, opr ) );
        return D{ CycleOp( ImagesRepresentative( hom, g ),
                       PositionCanonical( D, pnt ), OnPoints ) };
    elif IsBound( D )  then
        return CycleOp( g, D, pnt, opr );
    else
        return CycleOp( g, pnt, opr );
    fi;
end;

InstallMethod( CycleOp, true,
        [ IsObject, IsList, IsObject, IsFunction ], 0,
    function( g, D, pnt, opr )
    return CycleOp( g, pnt, opr );
end );

CycleByPosOp := function( g, D, blist, fst, pnt, opr )
    local   cyc,  new;
    
    cyc := [  ];
    new := fst;
    repeat
        Add( cyc, pnt );
        pnt := opr( pnt, g );
        new := PositionCanonical( D, pnt );
        blist[ new ] := true;
    until new = fst;
    return Immutable( cyc );
end;

InstallOtherMethod( CycleOp, true, [ IsObject, IsObject, IsFunction ], 0,
    function( g, pnt, opr )
    local   orb,  img;
    
    orb := [ pnt ];
    img := opr( pnt, g );
    while img <> pnt  do
        Add( orb, img );
        img := opr( img, g );
    od;
    return Immutable( orb );
end );

#############################################################################
##
#F  Cycles( <arg> ) . . . . . . . . . . . . . . . . . . . . . . . . .  cycles
##
Cycles := function( arg )
    local   g,  D,  gens,  oprs,  opr,  xset,  hom;
    
    # Get the arguments.
    g := arg[ 1 ];
    if Length( arg ) = 2  and  IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        D := Enumerator( xset );
        if IsExternalSetByOperatorsRep( xset )  then
            gens := xset!.generators;
            oprs := xset!.operators;
            opr  := xset!.funcOperation;
        else
            opr := FunctionOperation( xset );
        fi;
        D := Enumerator( xset );
    else
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
        fi;
    fi;
    
    if IsBound( gens )  and  not IsIdentical( gens, oprs )  then
        hom := OperationHomomorphismAttr( ExternalSetByFilterConstructor
                       ( IsExternalSet,
                         GroupByGenerators( gens ), D, gens, oprs, opr ) );
        return List( CyclesOp( ImagesRepresentative( hom, g ),
                       [ 1 .. Length( D ) ], OnPoints ), cyc -> D{ cyc } );
    else
        return CyclesOp( g, D, opr );
    fi;
end;

InstallMethod( CyclesOp, true, [ IsObject, IsList, IsFunction ], 1,
    function( g, D, opr )
    local   blist,  orbs,  next,  pnt,  pos,  orb;
    
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail do
        pnt := D[ next ];
        orb := CycleOp( g, D[ next ], opr );
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
        "G, D, gens, oprs, opr", true,
        [ IsGroup, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, gens, oprs, opr )
    return BlocksOp( G, D, [  ], gens, oprs, opr );
end );

InstallMethod( BlocksOp,
        "G, D, seed, gens, oprs, opr", true,
        [ IsGroup, IsList, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, seed, gens, oprs, opr )
    local   hom,  B;
    
    hom := OperationHomomorphism( G, D, gens, oprs, opr );
    B := Blocks( ImagesSource( hom ), [ 1 .. Length( D ) ] );
    return List( B, b -> D{ b } );
end );

InstallMethod( BlocksOp,
        "G, [  ], seed, gens, oprs, opr", true,
        [ IsGroup, IsList and IsEmpty, IsList,
          IsList,
          IsList,
          IsFunction ], SUM_FLAGS,
    function( G, D, seed, gens, oprs, opr )
    return Immutable( [  ] );
end );

#############################################################################
##
#F  MaximalBlocks( <arg> )  . . . . . . . . . . . . . . . . .  maximal blocks
##
InstallOtherMethod( MaximalBlocksOp,
        "G, D, gens, oprs, opr", true,
        [ IsGroup, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, gens, oprs, opr )
    return MaximalBlocksOp( G, D, [  ], gens, oprs, opr );
end );

InstallMethod( MaximalBlocksOp,
        "G, D, seed, gens, oprs, opr", true,
        [ IsGroup, IsList, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function ( G, D, seed, gens, oprs, opr )
    local   blks,       # blocks, result
            H,          # image of <G>
            blksH,      # blocks of <H>
            i;          # loop variable

    blks := BlocksOp( G, D, seed, gens, oprs, opr );

    # iterate until the operation becomes primitive
    H := G;
    blksH := blks;
    while Length( blksH ) <> 1  do
        H     := Operation( H, blksH, OnSets );
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
InstallMethod( OrbitLengthOp, true, OrbitishReq, 0,
    function( G, D, pnt, gens, oprs, opr )
    return Length( OrbitOp( G, D, pnt, gens, oprs, opr ) );
end );

InstallOtherMethod( OrbitLengthOp, true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, oprs, opr )
    return Length( OrbitOp( G, pnt, gens, oprs, opr ) );
end );

#############################################################################
##
#F  OrbitLengths( <arg> ) . . . . . . . . . . . . . . . . . . . orbit lengths
##
InstallMethod( OrbitLengthsOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return Immutable( List( Orbits( G, D, gens, oprs, opr ), Length ) );
end );

#############################################################################
##
#F  CycleLength( <arg> )  . . . . . . . . . . . . . . . . . . .  cycle length
##
CycleLength := function( arg )
    local   g,  D,  pnt,  gens,  oprs,  opr,  xset,  hom,  p;
    
    # Get the arguments.
    g := arg[ 1 ];
    if IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        pnt := arg[ 3 ];
        if HasHomeEnumerator( xset )  then
            D := HomeEnumerator( xset );
        fi;
        opr := FunctionOperation( xset );
        hom := OperationHomomorphismAttr( xset );
    else
        if Length( arg ) > 2  and
           IsIdentical( FamilyObj( arg[ 2 ] ),
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
            opr := arg[ Length( arg ) ];
        else
            opr := OnPoints;
        fi;
        if Length( arg ) > p + 1  then
            gens := arg[ p + 1 ];
            oprs := arg[ p + 2 ];
            if not IsIdentical( gens, oprs )  then
                hom := OperationHomomorphismAttr( ExternalOrbitOp
                    ( GroupByGenerators( gens ), D, pnt, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  and  IsOperationHomomorphismByOperators( hom )  then
        return CycleLengthOp( ImagesRepresentative( hom, g ),
                       PositionCanonical( D, pnt ), OnPoints );
    elif IsBound( D )  then
        return CycleLengthOp( g, D, pnt, opr );
    else
        return CycleLengthOp( g, pnt, opr );
    fi;
end;

InstallMethod( CycleLengthOp, true,
        [ IsObject, IsList, IsObject, IsFunction ], 0,
    function( g, D, pnt, opr )
    return Length( CycleOp( g, D, pnt, opr ) );
end );

InstallOtherMethod( CycleLengthOp, true,
        [ IsObject, IsObject, IsFunction ], 0,
    function( g, pnt, opr )
    return Length( CycleOp( g, pnt, opr ) );
end );

#############################################################################
##
#F  CycleLengths( <arg> ) . . . . . . . . . . . . . . . . . . . cycle lengths
##
CycleLengths := function( arg )
    local   g,  D,  gens,  oprs,  opr,  xset,  hom;
    
    # Get the arguments.
    g := arg[ 1 ];
    if IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        D := Enumerator( xset );
        opr := FunctionOperation( xset );
        hom := OperationHomomorphismAttr( xset );
    else
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
            if not IsIdentical( gens, oprs )  then
                hom := OperationHomomorphismAttr
                       ( ExternalSetByFilterConstructor( IsExternalSet,
                         GroupByGenerators( gens ), D, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  and  IsOperationHomomorphismByOperators( hom )  then
        return CycleLengthsOp( ImagesRepresentative( hom, g ),
                       [ 1 .. Length( D ) ], OnPoints );
    else
        return CycleLengthsOp( g, D, opr );
    fi;
end;

InstallMethod( CycleLengthsOp, true, [ IsObject, IsList, IsFunction ], 0,
    function( g, D, opr )
    return Immutable( List( CyclesOp( g, D, opr ), Length ) );
end );

#############################################################################
##

#F  IsTransitive( <G>, <D>, <gens>, <oprs>, <opr> ) . . . . transitivity test
##
InstallMethod( IsTransitiveOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return IsSubset( OrbitOp( G, D[ 1 ], gens, oprs, opr ), D );
end );

#############################################################################
##
#F  Transitivity( <arg> ) . . . . . . . . . . . . . . . . transitivity degree
##
InstallMethod( TransitivityOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   hom;
    
    hom := OperationHomomorphism( G, D, gens, oprs, opr );
    return Transitivity( ImagesSource( hom ), [ 1 .. Length( D ) ] );
end );

InstallMethod( TransitivityOp,
        "G, [  ], gens, perms, opr", true,
        [ IsGroup, IsList and IsEmpty,
          IsList,
          IsList,
          IsFunction ], SUM_FLAGS,
    function( G, D, gens, oprs, opr )
    return 0;
end );

#############################################################################
##
#F  IsPrimitive( <G>, <D>, <gens>, <oprs>, <opr> )  . . . .  primitivity test
##
InstallMethod( IsPrimitiveOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return     IsTransitive( G, D, gens, oprs, opr )
           and Length( Blocks( G, D, gens, oprs, opr ) ) = 1;
end );

#############################################################################
##
#F  Earns( <arg> ) . . . . . . . . elementary abelian regular normal subgroup
##
InstallMethod( EarnsOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    Error( "`Earns' only implemented for primitive permutation groups" );
end );

#############################################################################
##
#M  Setter( EarnsAttr )( <G>, fail )  . . . . . . . . . . .  never set `fail'
##
InstallOtherMethod( Setter( EarnsAttr ), true, [ IsGroup, IsBool ],
        SUM_FLAGS,
    function( G, fail )
    Setter( IsPrimitiveAffineProp )( G, false );
end );

#############################################################################
##
#F  IsPrimitiveAffine( <arg> )  . . . . . . . . . . . .  is operation affine?
##
InstallMethod( IsPrimitiveAffineOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return     IsPrimitive( G, D, gens, oprs, opr )
           and Earns( G, D, gens, oprs, opr ) <> fail;
end );

#############################################################################
##
#F  IsSemiRegular( <arg> )  . . . . . . . . . . . . . . . semiregularity test
##
InstallMethod( IsSemiRegularOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   hom;
    
    hom := OperationHomomorphism( G, D, gens, oprs, opr );
    return IsSemiRegular( ImagesSource( hom ), [ 1 .. Length( D ) ] );
end );

InstallMethod( IsSemiRegularOp,
        "G, [  ], gens, perms, opr", true,
        [ IsGroup, IsList and IsEmpty,
          IsList,
          IsList,
          IsFunction ], SUM_FLAGS,
    function( G, D, gens, oprs, opr )
    return true;
end );

InstallMethod( IsSemiRegularOp,
        "G, D, gens, [  ], opr", true,
        [ IsGroup, IsList,
          IsList,
          IsList and IsEmpty,
          IsFunction ], SUM_FLAGS,
    function( G, D, gens, oprs, opr )
    return IsTrivial( G );
end );

#############################################################################
##
#F  IsRegular( <arg> )  . . . . . . . . . . . . . . . . . . . regularity test
##
InstallMethod( IsRegularOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return     IsTransitive( G, D, gens, oprs, opr )
           and IsSemiRegular( G, D, gens, oprs, opr );
end );

#############################################################################
##
#F  RepresentativeOperation( <arg> )  . . . . . . . .  representative element
##
RepresentativeOperation := function( arg )
    local   G,  D,  d,  e,  gens,  oprs,  opr,  xset,  hom,  p,  rep;
    
    if IsExternalSet( arg[ 1 ] )  then
        xset := arg[ 1 ];
        d := arg[ 2 ];
        e := arg[ 3 ];
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
        hom := OperationHomomorphismAttr( xset );
    else
        G := arg[ 1 ];
        if Length( arg ) > 2  and
           IsIdentical( FamilyObj( arg[ 2 ] ),
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
        if IsFunction( arg[ Length( arg ) ] )  then
            opr := arg[ Length( arg ) ];
        else
            opr := OnPoints;
        fi;
        if Length( arg ) > p + 2  then
            gens := arg[ p + 2 ];
            oprs := arg[ p + 3 ];
            if not IsPcgs( gens )  and  not IsIdentical( gens, oprs )  then
                if not IsBound( D )  then
                    D := OrbitOp( G, d, gens, oprs, opr );
                fi;
                hom := OperationHomomorphismAttr( ExternalOrbitOp
                       ( G, D, d, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  and  IsOperationHomomorphismByOperators( hom )  then
        d := PositionCanonical( D, d );  e := PositionCanonical( D, e );
        rep := RepresentativeOperationOp( ImagesSource( hom ), d, e,
                       OnPoints );
        if rep <> fail  then
            rep := PreImagesRepresentative( hom, rep );
        fi;
        return rep;
    elif IsBound( D )  then
        if IsBound( gens )  and  IsPcgs( gens )  then
            return RepresentativeOperation( G, D, d, e, gens, oprs, opr );
        else
            return RepresentativeOperationOp( G, D, d, e, opr );
        fi;
    else
        return RepresentativeOperationOp( G, d, e, opr );
    fi;
end;

InstallMethod( RepresentativeOperationOp, true,
        [ IsGroup, IsList, IsObject, IsObject, IsFunction ], 0,
    function( G, D, d, e, opr )        
    return RepresentativeOperationOp( G, d, e, opr );
end );

InstallOtherMethod( RepresentativeOperationOp, true,
        [ IsGroup, IsObject, IsObject, IsFunction ], 0,
    function( G, d, e, opr )
    local   rep,        # representative, result
            orb,        # orbit
            set,        # orbit <orb> as set for faster membership test
            gen,        # generator of the group <G>
            pnt,        # point in the orbit <orb>
            img,        # image of the point <pnt> under the generator <gen>
            by,         # <by>[<pnt>] is a gen taking <frm>[<pnt>] to <pnt>
            frm;        # where <frm>[<pnt>] lies earlier in <orb> than <pnt>

    # standard operation
    if   opr = OnPoints  then
        if d = e  then return One( G );  fi;
        orb := [ d ];
        set := [ d ];
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
                    AddSet( set, img );
                    Add( frm, pnt );
                    Add( by,  gen );
                fi;
            od;
        od;
        return fail;

    # special case for operation on pairs
    elif opr = OnPairs  then
        if d = e  then return One( G );  fi;
        orb := [ d ];
        set := [ d ];
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
                    AddSet( set, img );
                    Add( frm, pnt );
                    Add( by,  gen );
                fi;
            od;
        od;
        return fail;

    # other operation
    else
        if d = e  then return One( G );  fi;
        orb := [ d ];
        set := [ d ];
        by  := [ One( G ) ];
        frm := [ 1 ];
        for pnt  in orb  do
            for gen  in GeneratorsOfGroup( G )  do
                img := opr( pnt, gen );
                if img = e  then
                    rep := gen;
                    while pnt <> d  do
                        rep := by[ Position(orb,pnt) ] * rep;
                        pnt := frm[ Position(orb,pnt) ];
                    od;
                    return rep;
                elif not img in set  then
                    Add( orb, img );
                    AddSet( set, img );
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
Stabilizer := function( arg )
    if Length( arg ) = 1  then
        return StabilizerOfExternalSet( arg[ 1 ] );
    else
        return CallFuncList( StabilizerFunc, arg );
    fi;
end;

InstallMethod( StabilizerOp,
        "G, D, pnt, gens, oprs, opr", true,
        OrbitishReq, 0,
    function( G, D, d, gens, oprs, opr )
    local   hom;
    
    if not IsIdentical( gens, oprs )  then
        hom := OperationHomomorphismAttr( ExternalOrbitOp
                       ( G, D, d, gens, oprs, opr ) );
        d := PositionCanonical( D[ d ] );
        return PreImages( hom, StabilizerOp
                       ( ImagesSource( hom ), d, OnPoints ) );
    else
        return StabilizerOp( G, d, gens, oprs, opr );
    fi;
end );

InstallOtherMethod( StabilizerOp,
        "G, pnt, gens, oprs, opr", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, d, gens, oprs, opr )
    local   stb,  p,  orbstab;
    
    if     IsIdentical( gens, oprs )
       and opr = OnTuples  or  opr = OnPairs  then
        stb := G;
        for p  in d  do
            stb := StabilizerOp( stb, p, GeneratorsOfGroup( stb ),
                           GeneratorsOfGroup( stb ), OnPoints );
        od;
    else
        orbstab := OrbitStabilizerByGenerators( gens, oprs, d, opr );
        stb := SubgroupNC( G, orbstab.stabilizer );
        if HasSize( G )  then
            SetSize( stb, Size( G ) / Length( orbstab.orbit ) );
        fi;
    fi;
    return stb;
end );

#############################################################################
##
#M  CanonicalRepresentativeOfExternalSet( <xset> )  . . . . . . . . . . . . .
##
InstallMethod( CanonicalRepresentativeOfExternalSet, true,
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
      2*SUM_FLAGS+1,
function( xset )
local func,can;

  if IsBound(xset!.CanonicalRepresentativeOfExternalSet) then
    return xset!.CanonicalRepresentativeOfExternalSet;
  fi;
  func:=CanonicalRepresentativeDeterminatorOfExternalSet(xset);
  can:=func(ActingDomain(xset),Representative(xset));
  # note the stabilizer we got for free
  if not HasStabilizerOfExternalSet(xset) and IsBound(can[2]) then
    SetStabilizerOfExternalSet(xset,can[2]^(can[3]^-1));
  fi;
  SetCanonicalRepresentativeOfExternalSet(xset,can[1]);
  return can[1];
end ) ;

#############################################################################
##
#M  OperatorOfExternalSet( <xset> ) . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( OperatorOfExternalSet, true, [ IsExternalSet ], 0,
    xset -> RepresentativeOperation( xset, Representative( xset ),
            CanonicalRepresentativeOfExternalSet( xset ) ) );

#############################################################################
##
#M  StabilizerOfExternalSet( <xset> ) . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( StabilizerOfExternalSet, true, [ IsExternalSet ], 0,
        xset -> Stabilizer( xset, Representative( xset ) ) );

#############################################################################
##

#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . for operation hom
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsOperationHomomorphismDirectly,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   xset;
    
    xset := UnderlyingExternalSet( hom );
    return Permutation( elm, HomeEnumerator( xset ),
                   FunctionOperation( xset ) );
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . .  if a base is known
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsOperationHomomorphismDirectly and
          IsOperationHomomorphismByBase and HasImagesSource,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   xset,  D,  opr,  imgs;

    xset := UnderlyingExternalSet( hom );
    D := HomeEnumerator( xset );
    opr := FunctionOperation( xset );
    if not IsBound( xset!.basePermImage )  then
        xset!.basePermImage := List( Base( xset ),
                                    b -> PositionCanonical( D, b ) );
    fi;
    imgs := List( Base( xset ), b -> PositionCanonical( D, opr( b, elm ) ) );
    return RepresentativeOperationOp( ImagesSource( hom ),
                   xset!.basePermImage, imgs, OnTuples );
end );

#############################################################################
##
#M  ImagesSource( <hom> ) . . . . . . . . . . . . . . . . . set base in image
##
InstallMethod( ImagesSource, true,
        [ IsOperationHomomorphismByBase ], 0,
    function( hom )
    local   xset,  img,  D;
    
    xset := UnderlyingExternalSet( hom );
    img := ImagesSet( hom, Source( hom ) );
    if not HasStabChain( img )  and  not HasBase( img )  then
        if not IsBound( xset!.basePermImage )  then
            D := HomeEnumerator( xset );
            xset!.basePermImage := List( Base( xset ),
                                        b -> PositionCanonical( D, b ) );
        fi;
        SetBase( img, xset!.basePermImage );
    fi;
    return img;
end );
    
#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . .  restricted `Permutation'
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsOperationHomomorphismSubset and IsOperationHomomorphismDirectly,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   xset;
    
    xset := UnderlyingExternalSet( hom );
    return RestrictedPerm( Permutation( elm, HomeEnumerator( xset ),
        FunctionOperation( xset ) ),
        MovedPoints( ImagesSource( AsGroupGeneralMappingByImages( hom ) ) ) );
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . .  build matrix
##
InstallMethod( PreImagesRepresentative, true,
        [ IsLinearOperationHomomorphism, IsPerm ], 0,
    function( hom, elm )
    local   V,  base,  mat,  b;
    
    if not elm in Image( hom )  then
        return fail;
    fi;
    V := HomeEnumerator( UnderlyingExternalSet( hom ) );
    base := One( Source( hom ) );
    mat := [  ];
    for b  in base  do
        Add( mat, V[ PositionCanonical( V, b ) ^ elm ] );
    od;
    return mat;
end );

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
