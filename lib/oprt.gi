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
#F  AttributeOperation( <arg> ) . . . . . . . . . .  attribute for operations
##
##  `AttributeOperation(  op, attr,  usekind,   args  )' calls an   operation
##  function with   the arguments <args>: If  <args>  specify an external set
##  <xset> or a group <G>  operating `OnPoints' on  its `MovedPoints', and if
##  <xset> resp. <G>  has  the  attribute <attr>,   its  value  is  returned.
##  Otherwise, <args> are parsed  and converted into  the form `( G, D, gens,
##  oprs, opr )' and the operation <op> is called with this argument list. If
##  <xset>  or <G>  was specified   as above, the   result  is stored as  the
##  attribute <attr>  in <hom>  resp. <G>. If  <usekind> is  true and  <xset>
##  present, it is passed instead of <D>, to allow usage of `KindObj(xset)'.
##
AttributeOperation := function( propop, propat, usekind, args )
    local   G,  D,  gens,  oprs,  opr,  xset,  result,  attrG;
    
    # Get the arguments.
    if IsExternalSet( args[ 1 ] )  then
        xset := args[ 1 ];
        
        # In the case of an external set, look at the attribute.
        if Tester( propat )( xset )  then
            return propat( xset );
        fi;
        
        G := ActingDomain( xset );
        D := Enumerator( xset );
        if IsExternalSetByOperatorsRep( xset )  then
            gens := xset!.generators;
            oprs := xset!.operators;
            opr  := xset!.funcOperation;
        else
            opr := FunctionOperation( xset );
        fi;
        
    else
        G := args[ 1 ];
        D := args[ 2 ];
        if IsDomain( D )  then
            D := Enumerator( D );
        fi;
        if Length( args ) > 3  then
            gens := args[ 3 ];
            oprs := args[ 4 ];
        fi;
        if IsFunction( args[ Length( args ) ] )  then
            opr := args[ Length( args ) ];
        else
            opr := OnPoints;
        fi;
    fi;
    
    if not IsBound( gens )  then
        if IsPcgsComputable( G )  then  gens := Pcgs( G );
                                  else  gens := GeneratorsOfGroup( G );  fi;
        oprs := gens;
    fi;
    
    # In the case of a permutation group $G$ acting on  its moved points, use
    # an attribute for $G$.
    attrG := IsIdentical( gens, oprs )
         and opr = OnPoints
         and HasMovedPoints( G )
         and IsIdentical( MovedPoints( G ), D );
    if attrG  and  Tester( propat )( G )  then
        result := propat( G );
    elif     usekind
         and IsBound( xset )  then
        result := propop( G, xset, gens, oprs, opr );
    else
        result := propop( G, D, gens, oprs, opr );
    fi;

    # Store the result in the case of an attribute.
    if   IsBound( xset )  then  Setter( propat )( xset, result );
    elif attrG            then  Setter( propat )( G,    result );  fi;
    
    return result;
end;

#############################################################################
##
#F  OrbitishOperation( <arg> )  . . . . . . . . . . . .  orbit-like operation
##
OrbitishOperation := function( orbish, famrel, usekind, args )
    local   G,  D,  pnt,  gens,  oprs,  opr,  xset,  p;
    
    # Get the arguments.
    if IsExternalSet( args[ 1 ] )  then
        xset := args[ 1 ];
        pnt := args[ 2 ];
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
    else
        G := args[ 1 ];
        if     Length( args ) > 2
           and famrel( FamilyObj( args[ 2 ] ), FamilyObj( args[ 3 ] ) )  then
            D := args[ 2 ];
            if IsDomain( D )  then
                D := Enumerator( D );
            fi;
            p := 3;
        else
            p := 2;
        fi;
        pnt := args[ p ];
        if Length( args ) > p + 1  then
            gens := args[ p + 1 ];
            oprs := args[ p + 2 ];
        fi;
        if IsFunction( args[ Length( args ) ] )  then
            opr := args[ Length( args ) ];
        else
            opr := OnPoints;
        fi;
    fi;
    
    if not IsBound( gens )  then
        if IsPcgsComputable( G )  then  gens := Pcgs( G );
                                  else  gens := GeneratorsOfGroup( G );  fi;
        oprs := gens;
    fi;
    if     usekind
       and IsBound( xset )  then
        return orbish( G, xset, pnt, gens, oprs, opr );
    elif IsBound( D )  then
        return orbish( G, D, pnt, gens, oprs, opr );
    else
        return orbish( G, pnt, gens, oprs, opr );
    fi;
end;

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
ExternalSet := function( arg )
    return AttributeOperation( ExternalSetOp, ExternalSetAttr, false, arg );
end;

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
    Objectify( NewKind( FamilyObj( D ), filter ), xset );
    SetActingDomain  ( xset, G );
    SetHomeEnumerator( xset, D );
    if not IsExternalSetByOperatorsRep( xset )  then
        SetFunctionOperation( xset, opr );
    fi;
    return xset;
end;

ExternalSetByKindConstructor := function( kind, G, D, gens, oprs, opr )
    local   xset;
    
    xset := Objectify( kind, rec(  ) );
    if not IsIdentical( gens, oprs )  then
        xset!.generators    := gens;
        xset!.operators     := oprs;
        xset!.funcOperation := opr;
    fi;
    SetActingDomain  ( xset, G );
    SetHomeEnumerator( xset, D );
    if not IsExternalSetByOperatorsRep( xset )  then
        SetFunctionOperation( xset, opr );
    fi;
    return xset;
end;

#############################################################################
##
#M  Size( <xset> )  . . . . . . . . . . . . . . . . . . . . .  via enumerator
##
InstallMethod( Size, true, [ IsExternalSet ], 0,
    xset -> Length( Enumerator( xset ) ) );

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
ExternalSubset := function( arg )
    return OrbitishOperation( ExternalSubsetOp, IsIdentical, true, arg );
end;

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
    local   kind,  xsset;

    kind := KindObj( xset );
    if not IsBound( kind![XSET_XSSETKIND] )  then
        xsset := ExternalSetByFilterConstructor( IsExternalSubset,
                         G, HomeEnumerator( xset ), gens, oprs, opr );
        kind![XSET_XSSETKIND] := KindObj( xsset );
    else
        xsset := ExternalSetByKindConstructor( kind![XSET_XSSETKIND],
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
    local   henum,  sublist,  pnt;
    
    henum := HomeEnumerator( xset );
    sublist := BlistList( [ 1 .. Length( henum ) ],
                       MovedPoints( ImagesSource
                               ( OperationHomomorphismAttr( xset ) ) ) );
    for pnt  in xset!.start  do
        sublist[ PositionCanonical( henum, pnt ) ] := true;
    od;
    return Objectify( NewKind( FamilyObj( henum ), IsSubsetEnumerator ),
        rec( homeEnumerator := henum,
                    sublist := sublist ) );
end );

#############################################################################
##
#F  ExternalOrbit( <arg> )  . . . . . . . . . . . . . . external set on orbit
##
ExternalOrbit := function( arg )
    return OrbitishOperation( ExternalOrbitOp, IsCollsElms, true, arg );
end;
    
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
    local   kind,  xorb;

    kind := KindObj( xset );
    if not IsBound( kind![XSET_XORBKIND] )  then
        xorb := ExternalSetByFilterConstructor( IsExternalOrbit,
                        G, HomeEnumerator( xset ), gens, oprs, opr );
        kind![XSET_XORBKIND] := KindObj( xorb );
    else
        xorb := ExternalSetByKindConstructor( kind![XSET_XORBKIND],
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
    if IsConstantTimeAccessListRep( enum )  then  return pnt in enum;
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
    local   xset,  p;
    
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
    return OperationHomomorphismAttr( xset );
end;

InstallMethod( OperationHomomorphismAttr, true, [ IsExternalSet ], 0,
    function( xset )
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
    hom := rec( externalSet := xset );
    if IsExternalSetByOperatorsRep( xset )  then
        filter := filter and IsOperationHomomorphismByOperators;
    elif     IsDomainEnumerator( D )
         and IsFreeLeftModule( UnderlyingCollection( D ) )
         and IsFullRowModule( UnderlyingCollection( D ) )
         and IsLeftActedOnByDivisionRing( UnderlyingCollection( D ) )
         and opr in [ OnPoints, OnRight ]  then
        filter := filter and IsGeneralLinearOperationHomomorphism;
    else
        if IsExternalSubset( xset )  then
            D := Enumerator( xset );
        fi;
        if       IsPermGroup( G )
             and IsList( D ) and IsCyclotomicsCollection( D )
             and opr = OnPoints  then
            filter := IsConstituentHomomorphism;
            hom.conperm := MappingPermListList( D, [ 1 .. Length( D ) ] );
        elif     IsPermGroup( G )
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
    fi;
    if HasBase( xset )  then
        filter := filter and IsOperationHomomorphismByBase;
    fi;
    return Objectify( NewKind( fam, filter ), hom );
end );

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
        hom -> ActingDomain( hom!.externalSet ) );

#############################################################################
##
#M  Range( <hom> )  . . . . . . . . . . . . . range of operation homomorphism
##
InstallMethod( Range, true, [ IsOperationHomomorphism ], 0,
    hom -> SymmetricGroup( Length( HomeEnumerator( hom!.externalSet ) ) ) );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . .  for operation homomorphism
##
InstallMethod( AsGroupGeneralMappingByImages, true,
        [ IsOperationHomomorphism ], 0,
    function( hom )
    local   xset,  G,  D,  opr,  gens,  imgs;
    
    xset := hom!.externalSet;
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
    
    xset := hom!.externalSet;
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
    blist := DeepCopy( poss );
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
    
    xset := hom!.externalSet;
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

    xset := hom!.externalSet;
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
Orbit := function( arg )
    return OrbitishOperation( OrbitOp, IsCollsElms, false, arg );
end;

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
OrbitStabilizer := function( arg )
    return OrbitishOperation( OrbitStabilizerOp, IsCollsElms, false, arg );
end;

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
    local   orb,  stb,  rep,  pnt,  img,  sch,  i;

    orb := [ d ];
    stb := [  ];
    if not IsEmpty( gens )  then
        rep := [ One( gens[ 1 ] ) ];
        for pnt  in orb  do
            for i  in [ 1 .. Length( gens ) ]  do
                img := opr( pnt, oprs[ i ] );
                if not img in orb  then
                    Add( orb, img );
                    Add( rep, rep[Position(orb,pnt)]*gens[ i ] );
                else
                    sch := rep[Position(orb,pnt)]*gens[ i ]
                           / rep[Position(orb,img)];
                    if not sch in stb  then
                        Add( stb, sch );
                    fi;
                fi;
            od;
        od;
    fi;
    return rec( orbit := orb, stabilizer := stb );
end;

#############################################################################
##
#F  Orbits( <arg> ) . . . . . . . . . . . . . . . . . . . . . . . . .  orbits
##
Orbits := function( arg )
    return AttributeOperation( OrbitsOp, OrbitsAttr, false, arg );
end;

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
SparseOperationHomomorphism := function( arg )
    return OrbitishOperation( SparseOperationHomomorphismOp, IsIdentical,
                   false, arg );
end;

InstallMethod( SparseOperationHomomorphismOp,
        "G, D, start, gens, oprs, opr", true,
        [ IsGroup, IsList, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, start, gens, oprs, opr )
    local   list,  ps,  p,  i,  gen,  img,  pos,  imgs;

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
    return GroupHomomorphismByImages
           ( G, SymmetricGroup( Length( start ) ), gens, imgs );
end );

InstallOtherMethod( SparseOperationHomomorphismOp,
        "G, start, gens, oprs, opr", true,
        [ IsGroup, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, start, gens, oprs, opr )
    local   list,  ps,  p,  i,  gen,  img,  pos,  imgs;

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
    return GroupHomomorphismByImages
           ( G, SymmetricGroup( Length( start ) ), gens, imgs );
end );

#############################################################################
##
#F  ExternalOrbits( <arg> ) . . . . . . . . . . . .  list of transitive xsets
##
ExternalOrbits := function( arg )
    return AttributeOperation( ExternalOrbitsOp, ExternalOrbitsAttr,
                   true, arg );
end;

InstallMethod( ExternalOrbitsOp,
        "G, D, gens, oprs, opr", true,
        OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   blist,  orbs,  next,  pnt,  orb,  p;
    
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, D, pnt, gens, oprs, opr );
        SetCanonicalRepresentativeOfExternalSet( orb, pnt );
        Add( orbs, orb );
        for p  in orb  do
            blist[ PositionCanonical( D, p ) ] := true;
        od;
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
    local   D,  blist,  orbs,  next,  pnt,  orb,  p;

    D := Enumerator( xset );
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, xset, pnt, gens, oprs, opr );
        SetCanonicalRepresentativeOfExternalSet( orb, pnt );
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
    new := fst;
    repeat
        old := new;
        pnt := opr( pnt, g );
        new := PositionCanonical( D, pnt );
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
Blocks := function( arg )
    return OrbitishOperation( BlocksOp, IsIdentical, true, arg );
end;
    
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

#############################################################################
##
#F  MaximalBlocks( <arg> )  . . . . . . . . . . . . . . . . .  maximal blocks
##
MaximalBlocks := function( arg )
    return OrbitishOperation( MaximalBlocksOp, IsIdentical, true, arg );
end;

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
OrbitLength := function( arg )
    return OrbitishOperation( OrbitLengthOp, IsCollsElms, false, arg );
end;

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
OrbitLengths := function( arg )
    return AttributeOperation( OrbitLengthsOp, OrbitLengthsAttr, false, arg );
end;

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
IsTransitive := function( arg )
    return AttributeOperation( IsTransitiveOp, IsTransitiveProp, false, arg );
end;

InstallMethod( IsTransitiveOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return IsSubset( OrbitOp( G, D[ 1 ], gens, oprs, opr ), D );
end );

#############################################################################
##
#F  Transitivity( <arg> ) . . . . . . . . . . . . . . . . transitivity degree
##
Transitivity := function( arg )
    return AttributeOperation( TransitivityOp, TransitivityAttr, false, arg );
end;

InstallMethod( TransitivityOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   hom;
    
    hom := OperationHomomorphism( G, D, gens, oprs, opr );
    return Transitivity( ImagesSource( hom ), [ 1 .. Length( D ) ] );
end );

#############################################################################
##
#F  IsPrimitive( <G>, <D>, <gens>, <oprs>, <opr> )  . . . .  primitivity test
##
IsPrimitive := function( arg )
    return AttributeOperation( IsPrimitiveOp, IsPrimitiveProp, false, arg );
end;

InstallMethod( IsPrimitiveOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return     IsTransitive( G, D, gens, oprs, opr )
           and Length( Blocks( G, D, gens, oprs, opr ) ) = 1;
end );

#############################################################################
##
#F  Earns( <arg> ) . . . . . . . . elementary abelian regular normal subgroup
##
Earns := function( arg )
    return AttributeOperation( EarnsOp, EarnsAttr, false, arg );
end;

InstallMethod( EarnsOp, "fail if non-affine", true,
        [ IsGroup and Tester( IsPrimitiveAffineProp ), IsList,
          IsList,
          IsList,
          IsFunction ], SUM_FLAGS,
    function( G, D, gens, oprs, opr )
    if not IsPrimitiveAffineProp( G )  then  return fail;
                                       else  TryNextMethod();  fi;
end );

InstallMethod( EarnsOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    Error( "sorry, I am too lazy to compute the earns" );
end );

#############################################################################
##
#M  Setter( EarnsAttr )( <G>, fail )  . . . . . . . . . . .  never set `fail'
##
InstallMethod( Setter( EarnsAttr ), true, [ IsGroup, IsBool ], SUM_FLAGS,
    function( G, fail )
    Setter( IsPrimitiveAffineProp )( G, false );
end );

#############################################################################
##
#F  IsPrimitiveAffine( <arg> )  . . . . . . . . . . . .  is operation affine?
##
IsPrimitiveAffine := function( arg )
    return AttributeOperation( IsPrimitiveAffineOp, IsPrimitiveAffineProp,
                   false, arg );
end;

InstallMethod( IsPrimitiveAffineOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return     IsPrimitive( G, D, gens, oprs, opr )
           and Earns( G, D, gens, oprs, opr ) <> fail;
end );

#############################################################################
##
#F  IsSemiRegular( <arg> )  . . . . . . . . . . . . . . . semiregularity test
##
IsSemiRegular := function( arg )
    return AttributeOperation( IsSemiRegularOp, IsSemiRegularProp,
                   false, arg );
end;

InstallMethod( IsSemiRegularOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   hom;
    
    hom := OperationHomomorphism( G, D, gens, oprs, opr );
    return IsSemiRegular( ImagesSource( hom ), [ 1 .. Length( D ) ] );
end );

#############################################################################
##
#F  IsRegular( <arg> )  . . . . . . . . . . . . . . . . . . . regularity test
##
IsRegular := function( arg )
    return AttributeOperation( IsRegularOp, IsRegularProp, false, arg );
end;

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
        return OrbitishOperation( StabilizerOp, IsCollsElms, false, arg );
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
        return StabilizerOp( G, d, opr );
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
    
    if IsIdentical( gens, oprs )  then
        if opr = OnTuples  or  opr = OnPairs  then
            stb := G;
            for p  in d  do
                stb := StabilizerOp( stb, p, OnPoints );
            od;
        else
            stb := StabilizerOp( G, d, opr );
        fi;
    else
        orbstab := OrbitStabilizerByGenerators( gens, oprs, d, opr );
        stb := SubgroupNC( G, orbstab.stabilizer );
        if HasSize( G )  then
            SetSize( stb, Size( G ) / Length( orbstab.orbit ) );
        fi;
    fi;
    return stb;
end );

InstallOtherMethod( StabilizerOp,
        "G, pnt, opr", true,
        [ IsGroup, IsObject, IsFunction ], 0,
    function( G, d, opr )
    local   orbstab,  stb;
    
    orbstab := OrbitStabilizerByGenerators( GeneratorsOfGroup( G ),
                       GeneratorsOfGroup( G ), d, opr );
    stb := SubgroupNC( G, orbstab.stabilizer );
    if HasSize( G )  then
        SetSize( stb, Size( G ) / Length( orbstab.orbit ) );
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
    
    xset := hom!.externalSet;
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

    xset := hom!.externalSet;
    D := HomeEnumerator( xset );
    opr := FunctionOperation( xset );
    if not IsBound( xset!.base )  then
        xset!.base := List( Base( xset ), b -> PositionCanonical( D, b ) );
    fi;
    imgs := List( Base( xset ), b -> PositionCanonical( D, opr( b, elm ) ) );
    return RepresentativeOperationOp( ImagesSource( hom ),
                   xset!.base, imgs, OnTuples );
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
    
    xset := hom!.externalSet;
    return RestrictedPerm( Permutation( elm, HomeEnumerator( xset ),
        FunctionOperation( xset ) ),
        MovedPoints( ImagesSource( AsGroupGeneralMappingByImages( hom ) ) ) );
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . .  build matrix
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsGeneralLinearOperationHomomorphism,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   V,  base,  mat,  b;

    V := HomeEnumerator( hom!.externalSet );
    base := One( Source( hom ) );
    mat := [  ];
    for b  in base  do
        Add( mat, V[ PositionCanonical( V, b ) ^ elm ] );
    od;
    if    IsGeneralLinearGroup( Source( hom ) )
       or mat in Source( hom )  then  return mat;
                                else  return fail;  fi;
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
