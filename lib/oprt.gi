#############################################################################
##
#W  oprt.gi                     GAP library                              HThe
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.25  1996/12/19 09:40:54  htheisse
#H  reduced number of calls of `NewKind'
#H
#H  Revision 4.24  1996/12/13 12:31:05  htheisse
#H  patched `Transitivity' into working
#H
#H  Revision 4.23  1996/12/13 12:17:49  htheisse
#H  patched `Transitivity' into working
#H
#H  Revision 4.22  1996/11/27 15:32:53  htheisse
#H  replaced `Copy' by `DeepCopy'
#H
#H  Revision 4.21  1996/11/26 16:08:40  sam
#H  replaced 'IsEmptyList' by 'IsList and IsEmpty' (in installations)
#H      resp. 'IsEmpty' (in calls)
#H
#H  Revision 4.20  1996/11/21 16:04:54  htheisse
#H  changed treatment of operation homs and `AsGroupGeneralMappingByImages'
#H
#H  Revision 4.19  1996/11/19 13:22:34  htheisse
#H  changed method for `Stabilizer' in `oprtpcgs.gi'
#H  cleaned up the code
#H
#H  Revision 4.18  1996/11/13 15:24:06  htheisse
#H  added `OrbitStabilizer'
#H  encouraged use of pcgs for soluble groups
#H  cleaned up the code
#H
#H  Revision 4.17  1996/11/12 15:32:09  htheisse
#H  orbits etc. are now always immutable
#H
#H  Revision 4.16  1996/11/07 15:14:59  htheisse
#H  changed method for `IsInjective' and `Kernel' of operation homomorphisms
#H
#H  Revision 4.15  1996/11/07 12:31:15  htheisse
#H  introduced `ExternalSubset'
#H  added `SetBase' for external sets
#H  renamed `Parent' to `HomeEnumerator' for external sets
#H  tidied up a bit
#H
#H  Revision 4.14  1996/10/31 12:21:54  htheisse
#H  replaced `false' by `fail'
#H
#H  Revision 4.13  1996/10/21 11:13:36  htheisse
#H  enlarged `Range' of operation homomorphisms
#H  extended use of `AsGroupGeneralMappingByImages' and added a new kind of
#H      general mappings based on this
#H  modified (simplified) `CompositionMapping2' according to this
#H
#H  Revision 4.12  1996/10/14 12:56:40  fceller
#H  'Position', 'PositionBound', and 'PositionProperty' return 'fail'
#H  instead of 'false'
#H
#H  Revision 4.11  1996/10/11 07:00:08  htheisse
#H  fixed a problem with blists
#H
#H  Revision 4.10  1996/10/10 12:31:15  htheisse
#H  fixed a bug in `Cycle'
#H
#H  Revision 4.9  1996/10/09 13:42:22  htheisse
#H  forgot to compare operation functions in external orbit comparison
#H
#H  Revision 4.8  1996/10/09 13:30:42  htheisse
#H  added generic membership test for external orbits
#H
#H  Revision 4.7  1996/10/09 11:28:26  htheisse
#H  added generic comparison method for external orbits
#H
#H  Revision 4.6  1996/10/09 07:58:36  htheisse
#H  added {Orbit,Cycle}ByPosOp, removed dangerous use of `D!.blist'
#H
#H  Revision 4.5  1996/10/08 11:27:38  htheisse
#H  changed the operation functions, introduced ``external sets''
#H
#H  Revision 4.4  1996/10/01 15:41:37  htheisse
#H  corrected an error in `OrbitsStabilizers'
#H
#H  Revision 4.3  1996/10/01 14:50:07  htheisse
#H  added methods for operations of soluble groups, which use a pcgs
#H
#H  Revision 4.2  1996/09/26 14:02:53  htheisse
#H  added natural homomorphisms from perm groups onto pc groups
#H
#H  Revision 4.1  1996/09/23 16:47:33  htheisse
#H  added files for permutation groups (incl. backtracking)
#H                  stabiliser chains
#H                  group homomorphisms (of permutation groups)
#H                  operation homomorphisms
#H                  polycyclic generating systems of soluble permutation groups
#H                     (general concept tentatively)
#H
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
        if HasPcgs( G )  and  Pcgs( G ) <> fail  then
            gens := Pcgs( G );
        else
            gens := GeneratorsOfGroup( G );
        fi;
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
         and IsBound( xset )
         and IsExternalSetDefaultRep( xset )  then
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
        if HasPcgs( G )  and  Pcgs( G ) <> fail  then
            gens := Pcgs( G );
        else
            gens := GeneratorsOfGroup( G );
        fi;
        oprs := gens;
    fi;
    if     usekind
       and IsBound( xset )
       and IsExternalSetDefaultRep( xset )  then
        return orbish( G, xset, pnt, gens, oprs, opr );
    elif IsBound( D )  then
        return orbish( G, D, pnt, gens, oprs, opr );
    else
        return orbish( G, pnt, gens, oprs, opr );
    fi;
end;

#############################################################################
##

#F  ExternalSet( <arg> )  . . . . . . . . . . . . .  external set constructor
##
ExternalSet := function( arg )
    return AttributeOperation( ExternalSetOp, ExternalSetAttr, false, arg );
end;

InstallMethod( ExternalSetOp,
        "<G>, <D>, <gens>, <oprs>, <opr>", true,
        OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    return ExternalSetByFilterConstructor( IsExternalSetDefaultRep,
                   G, D, gens, oprs, opr );
end );

ExternalSetByFilterConstructor := function( filter, G, D, gens, oprs, opr )
    local   xset,  kind;

    xset := rec(  );
    if IsPcgs( gens )  or  not IsIdentical( gens, oprs )  then
        if IsPcgs( gens )  then
            kind := NewKind( FamilyObj( D ), IsExternalSetByPcgsRep );
        else
            kind := NewKind( FamilyObj( D ), IsExternalSetByOperatorsRep );
        fi;
        xset.generators    := gens;
        xset.operators     := oprs;
        xset.funcOperation := opr;
    else
        kind := NewKind( FamilyObj( D ), IsExternalSetDefaultRep );
    fi;
    Objectify( kind, xset );
    SetFilterObj( xset, filter );
    SetActingDomain  ( xset, G );
    SetHomeEnumerator( xset, D );
    if not IS_SUBSET_FLAGS( kind![2],
               FLAGS_FILTER( IsExternalSetByOperatorsRep ) )  then
        SetFunctionOperation( xset, opr );
    fi;
    return xset;
end;

ExternalSetByKindConstructor := function( kind, G, D, gens, oprs, opr )
    local   xset;
    
    xset := Objectify( kind, rec(  ) );
    if IsPcgs( gens )  or  not IsIdentical( gens, oprs )  then
        xset!.generators    := gens;
        xset!.operators     := oprs;
        xset!.funcOperation := opr;
    fi;
    SetActingDomain  ( xset, G );
    SetHomeEnumerator( xset, D );
    if not IS_SUBSET_FLAGS( kind![2],
               FLAGS_FILTER( IsExternalSetByOperatorsRep ) )  then
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
InstallMethod( Enumerator, true, [ IsExternalSetDefaultRep ], 0,
    HomeEnumerator );

#############################################################################
##
#M  FunctionOperation( <p>, <g> ) . . . . . . . . . . . .  operation function
##
InstallMethod( FunctionOperation, true, [ IsExternalSetByOperatorsRep ], 0,
    xset -> function( p, g )
    local   D;
        D := Enumerator( xset );
        return D[ Position( D, p ) ^ ( g ^ OperationHomomorphism( xset ) ) ];
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
        "<G>, <D>, <start>, <gens>, <oprs>, <opr>", true,
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
        "<G>, <xset>, <start>, <gens>, <oprs>, <opr>", true,
        [ IsGroup, IsExternalSetDefaultRep, IsList,
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
        "<G>, <start>, <gens>, <oprs>, <opr>", true,
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
    local   G,  gens;
    
    G := ActingDomain( xset );
    gens := GeneratorsOfGroup( G );
    return Concatenation( Orbits( G, xset!.start, gens, gens,
                   FunctionOperation( xset ) ) );
end );

InstallMethod( Enumerator, true,
        [ IsExternalSubset and IsExternalSetByOperatorsRep ], 0,
    xset -> Concatenation( Orbits( ActingDomain( xset ), xset!.start,
            xset!.generators, xset!.operators, xset!.funcOperation ) ) );

#############################################################################
##
#F  ExternalOrbit( <arg> )  . . . . . . . . . . . . . . external set on orbit
##
ExternalOrbit := function( arg )
    return OrbitishOperation( ExternalOrbitOp, IsCollsElms, true, arg );
end;
    
InstallMethod( ExternalOrbitOp,
        "<G>, <D>, <pnt>, <gens>, <oprs>, <opr>", true,
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
        "<G>, <xset>, <pnt>, <gens>, <oprs>, <opr>", true,
        [ IsGroup, IsExternalSetDefaultRep, IsObject,
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
        "<G>, <pnt>, <gens>, <oprs>, <opr>", true,
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
#M  <pnt> in <xorb> . . . . . . . . . . . . . . . . . . by ``conjugacy'' test
##
InstallMethod( \in, IsElmsColls, [ IsObject, IsExternalOrbit ], 0,
    function( pnt, xorb )
    return RepresentativeOperation( xorb, Representative( xorb ),
                   pnt ) <> fail;
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

InstallMethod( OperationHomomorphismAttr, true, [ IsExternalSetDefaultRep ], 0,
    function( xset )
    local   G,  D,  opr,  fam,  kind,  hom,  i;
    
    G := ActingDomain( xset );
    fam := GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                  PermutationsFamily );
    hom := rec( externalSet := xset );
    if IsExternalSetByOperatorsRep( xset )  then
        kind := NewKind( fam, IsOperationHomomorphismByOperators );
    else
        D := Enumerator( xset );
        opr := FunctionOperation( xset );
        if       IsPermGroup( G )
             and IsList( D ) and IsCyclotomicsCollection( D )
             and opr = OnPoints  then
            kind := NewKind( fam, IsConstituentHomomorphism );
            hom.conperm := MappingPermListList( D, [ 1 .. Length( D ) ] );
        elif     IsPermGroup( G )
             and IsList( D )
             and ForAll( D, IsSSortedList )
             and Sum( D, Length ) = Length( Union( D ) )
             and opr = OnSets  then
            kind := NewKind( fam, IsBlocksHomomorphism );
            hom.reps := [  ];
            for i  in [ 1 .. Length( D ) ]  do
                hom.reps{ D[ i ] } := i + 0 * D[ i ];
            od;
        elif IsPermGroup( G )  or  IsPcGroup( G )  then
            kind := NewKind( fam, IsOperationHomomorphismDefaultRep and
                    IsGroupGeneralMappingByAsGroupGeneralMappingByImages );
        elif HasBase( xset )  then
            kind := NewKind( fam, IsOperationHomomorphismByBase );
        else
            kind := NewKind( fam, IsOperationHomomorphismDefaultRep );
        fi;
    fi;
    return Objectify( kind, hom );
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
        [ IsOperationHomomorphismDefaultRep ], 0,
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
#M  OperationHomomorphism( <xset> ) . . . .  operation homomorphism on subset
##
InstallMethod( OperationHomomorphismAttr, true, [ IsExternalSubset ], 0,
    function( xset )
    local   G,  fam,  kind,  hom;
    
    G := ActingDomain( xset );
    fam := GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                  PermutationsFamily );
    hom := rec( externalSet := xset );
    if IsExternalSetByOperatorsRep( xset )  then
        kind := NewKind( fam, IsOperationHomomorphismSubset
                          and IsOperationHomomorphismByOperators );
    elif HasBase( xset )  then
        kind := NewKind( fam, IsOperationHomomorphismSubset
                          and IsOperationHomomorphismByBase );
    else
        kind := NewKind( fam, IsOperationHomomorphismSubset
                          and IsOperationHomomorphismDefaultRep );
    fi;
    return Objectify( kind, hom );
end );

#############################################################################
##
#F  OperationHomomorphismSubsetAsGroupGeneralMappingByImages( ... ) . . local
##
OperationHomomorphismSubsetAsGroupGeneralMappingByImages := function
    ( G, D, start, gens, oprs, opr )
    local   list,  ps,  poss,  blist,  p,  i,  gen,  img,  pos,  imgs,  hom;
    
    list := [ 1 .. Length( D ) ];
    poss := BlistList( list, List( start, b -> Position( D, b ) ) );
    blist := DeepCopy( poss );
    list := List( gens, gen -> ShallowCopy( list ) );
    ps := Position( poss, true );
    while ps <> fail  do
        poss[ ps ] := false;
        p := D[ ps ];
        for i  in [ 1 .. Length( gens ) ]  do
            gen := oprs[ i ];
            img := opr( p, gen );
            pos := Position( D, img );
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
        "<G>, <D>, <pnt>, [ <1gen> ], [ <1opr> ], <opr>", true,
        OrbitishReq, SUM_FLAGS,
    function( G, D, pnt, gens, oprs, opr )
    if Length( oprs ) <> 1  then  TryNextMethod();
                            else  return CycleOp( oprs[ 1 ], D, pnt, opr );
    fi;
end );

InstallMethod( OrbitOp,
        "<G>, <D>, <pnt>, <gens>, <oprs>, <opr>", true,
        OrbitishReq, 0,
    function( G, D, pnt, gens, oprs, opr )
    return OrbitByPosOp( G, D, BlistList( [ 1 .. Length( D ) ], [  ] ),
                   Position( D, pnt ), pnt, gens, oprs, opr );
end );

OrbitByPosOp := function( G, D, blist, pos, pnt, gens, oprs, opr )
    local   orb,  p,  gen,  img;
    
    blist[ pos ] := true;
    orb := [ pnt ];
    for p  in orb  do
        for gen  in oprs  do
            img := opr( p, gen );
            pos := Position( D, img );
            if not blist[ pos ]  then
                blist[ pos ] := true;
                Add( orb, img );
            fi;
        od;
    od;
    return Immutable( orb );
end;

InstallOtherMethod( OrbitOp,
        "<G>, <pnt>, [ <1gen> ], [ <1opr> ], <opr>", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], SUM_FLAGS,
    function( G, pnt, gens, oprs, opr )
    if Length( oprs ) <> 1  then  TryNextMethod();
                            else  return CycleOp( oprs[ 1 ], pnt, opr );  fi;
end );

InstallOtherMethod( OrbitOp,
        "<G>, <pnt>, <gens>, <oprs>, <opr>", true,
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
        "<G>, <D>, <pnt>, <gens>, <oprs>, <opr>", true,
        OrbitishReq, 0,
    function( G, D, pnt, gens, oprs, opr )
    return rec( orbit := OrbitOp( G, D, pnt, gens, oprs, opr ),
           stabilizer := StabilizerOp( G, D, pnt, gens, oprs, opr ) );
end );
    
InstallOtherMethod( OrbitStabilizerOp,
        "<G>, <pnt>, <gens>, <oprs>, <opr>", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, oprs, opr )
    return Immutable( rec
                   ( orbit := OrbitOp( G, pnt, gens, oprs, opr ),
                stabilizer := StabilizerOp( G, pnt, gens, oprs, opr ) ) );
end );
    
#############################################################################
##
#F  Orbits( <arg> ) . . . . . . . . . . . . . . . . . . . . . . . . .  orbits
##
Orbits := function( arg )
    return AttributeOperation( OrbitsOp, OrbitsAttr, false, arg );
end;

InstallMethod( OrbitsOp,
        "<G>, <D>, <gens>, <oprs>, <opr>", true,
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
            pos := Position( D, pnt );
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
#F  ExternalOrbits( <arg> ) . . . . . . . . . . . .  list of transitive xsets
##
ExternalOrbits := function( arg )
    return AttributeOperation( ExternalOrbitsOp, ExternalOrbitsAttr,
                   true, arg );
end;

InstallMethod( ExternalOrbitsOp,
        "<G>, <D>, <gens>, <oprs>, <opr>", true,
        OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   blist,  orbs,  next,  pnt,  orb,  p;
    
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[ next ];
        orb := ExternalOrbitOp( G, D, pnt, gens, oprs, opr );
        Add( orbs, orb );
        for p  in orb  do
            blist[ Position( D, p ) ] := true;
        od;
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end );

InstallOtherMethod( ExternalOrbitsOp,
        "<G>, <xset>, <gens>, <oprs>, <opr>", true,
        [ IsGroup, IsExternalSetDefaultRep,
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
        Add( orbs, orb );
        for p  in orb  do
            blist[ Position( D, p ) ] := true;
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
    local   g,  D,  gens,  oprs,  opr,  hom;

    # Get the arguments.
    g := arg[ 1 ];
    if IsExternalSet( arg[ 2 ] )  then
        hom := OperationHomomorphism( arg[ 2 ] );
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
                hom := OperationHomomorphism( ExternalSetByFilterConstructor
                       ( IsExternalSetDefaultRep,
                         GroupByGenerators( gens ), D, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  then  return g ^ hom;
                       else  return PermutationOp( g, D, opr );  fi;
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
            new := Position( D, pnt );
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
    if IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        pnt := arg[ 3 ];
        D := HomeEnumerator( xset );
        opr := FunctionOperation( xset );
        hom := OperationHomomorphism( xset );
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
            if not IsIdentical( gens, oprs )  then
                hom := OperationHomomorphism( ExternalOrbitOp
                    ( GroupByGenerators( gens ), D, pnt, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  and  IsOperationHomomorphismByOperators( hom )  then
        g := g ^ hom;
        return PermutationOp( g, CycleOp( g, Position( D, pnt ), OnPoints ),
                       OnPoints );
    else
        return PermutationCycleOp( g, D, pnt, opr );
    fi;
end;
                                
InstallMethod( PermutationCycleOp, true,
        [ IsObject, IsList, IsObject, IsFunction ], 0,
    function( g, D, pnt, opr )
    local   list,  old,  new,  fst;
    
    list := [  ];
    fst := Position( D, pnt );
    new := fst;
    repeat
        old := new;
        pnt := opr( pnt, g );
        new := Position( D, pnt );
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
    if IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        pnt := arg[ 3 ];
        if HasHomeEnumerator( xset )  then
            D := HomeEnumerator( xset );
        fi;
        opr := FunctionOperation( xset );
        hom := OperationHomomorphism( xset );
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
                hom := OperationHomomorphism( ExternalOrbitOp
                    ( GroupByGenerators( gens ), D, pnt, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  and  IsOperationHomomorphismByOperators( hom )  then
        return D{ CycleOp( g ^ hom, Position( D, pnt ), OnPoints ) };
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
        new := Position( D, pnt );
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
    if IsExternalSet( arg[ 2 ] )  then
        xset := arg[ 2 ];
        D := Enumerator( xset );
        opr := FunctionOperation( xset );
        hom := OperationHomomorphism( xset );
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
                hom := OperationHomomorphism( ExternalSetByFilterConstructor
                       ( IsExternalSetDefaultRep,
                         GroupByGenerators( gens ), D, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  and  IsOperationHomomorphismByOperators( hom )  then
        return List( CyclesOp( g ^ hom, [ 1 .. Length( D ) ], OnPoints ),
                     cyc -> D{ cyc } );
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
            pos := Position( D, pnt );
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
    local   G,  D,  seed,  gens,  oprs,  opr,  xset,  p;
    
    # Get the arguments.
    if IsExternalSet( arg[ 1 ] )  then
        xset := arg[ 1 ];
        if Length( arg ) > 1  then  seed := arg[ 2 ];
                              else  seed := [  ];      fi;
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
        G := arg[ 1 ];
        D := arg[ 2 ];
        if IsDomain( D )  then
            D := Enumerator( D );
        fi;
        if IsFunction( arg[ Length( arg ) ] )  then
            opr := arg[ Length( arg ) ];
            p := 0;
        else
            opr := OnPoints;
            p := 1;
        fi;
        if Length( arg ) mod 2 = p  then  seed := arg[ 3 ];  p := 4;
                                    else  seed := [  ];      p := 3;  fi;
        if Length( arg ) > p  then
            gens := arg[ p     ];
            oprs := arg[ p + 1 ];
        fi;
    fi;
    
    if not IsBound( gens )  then
        gens := GeneratorsOfGroup( G );
        oprs := gens;
    fi;
    return BlocksOp( G, D, seed, gens, oprs, opr );
end;
    
#############################################################################
##
#F  MaximalBlocks( <arg> )  . . . . . . . . . . . . . . . . .  maximal blocks
##
MaximalBlocks := function( arg )
    local   G,  D,  seed,  gens,  oprs,  opr,  xset,  p;
    
    # Get the arguments.
    if IsExternalSet( arg[ 1 ] )  then
        xset := arg[ 1 ];
        if Length( arg ) > 1  then  seed := arg[ 2 ];
                              else  seed := false;     fi;
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
        G := arg[ 1 ];
        D := arg[ 2 ];
        if IsDomain( D )  then
            D := Enumerator( D );
        fi;
        if IsFunction( arg[ Length( arg ) ] )  then
            opr := arg[ Length( arg ) ];
            p := 0;
        else
            opr := OnPoints;
            p := 1;
        fi;
        if Length( arg ) mod 2 = p  then  seed := arg[ 3 ];  p := 4;
                                    else  seed := false;     p := 3;  fi;
        if Length( arg ) > p  then
            gens := arg[ p     ];
            oprs := arg[ p + 1 ];
        fi;
    fi;
    
    if not IsBound( gens )  then
        gens := GeneratorsOfGroup( G );
        oprs := gens;
    fi;
    return MaximalBlocksOp( G, D, seed, gens, oprs, opr );
end;

#############################################################################
##

#F  Earns( <arg> ) . . . . . . . . elementary abelian regular normal subgroup
##
Earns := function( arg )
    return AttributeOperation( EarnsOp, EarnsAttr, false, arg );
end;

InstallMethod( EarnsOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    Error( "sorry, I am too lazy to compute the earns" );
end );

#############################################################################
##

#F  OrbitLength( <arg> )  . . . . . . . . . . . . . . . . . . .  orbit length
##
OrbitLength := function( arg )
    local   G,  D,  pnt,  gens,  oprs,  opr,  xset,  p;
    
    # Get the arguments.
    if IsExternalSet( arg[ 1 ] )  then
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
    fi;
    
    if not IsBound( gens )  then
        gens := GeneratorsOfGroup( G );
        oprs := gens;
    fi;
    if IsBound( D )  then
        return OrbitLengthOp( G, D, pnt, gens, oprs, opr );
    else
        return OrbitLengthOp( G, pnt, gens, oprs, opr );
    fi;
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
        hom := OperationHomomorphism( xset );
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
                hom := OperationHomomorphism( ExternalOrbitOp
                    ( GroupByGenerators( gens ), D, pnt, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  and  IsOperationHomomorphismByOperators( hom )  then
        return CycleLengthOp( g ^ hom, Position( D, pnt ), OnPoints );
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
        hom := OperationHomomorphism( xset );
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
                hom := OperationHomomorphism( ExternalSetByFilterConstructor
                       ( IsExternalSetDefaultRep,
                         GroupByGenerators( gens ), D, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( hom )  and  IsOperationHomomorphismByOperators( hom )  then
        return CycleLengthsOp( g ^ hom, [ 1 .. Length( D ) ], OnPoints );
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
InstallMethod( IsTransitiveOp, true,
        [ IsGroup, IsList and IsEmpty,
          IsList,
          IsList,
          IsFunction ], 0, ReturnTrue );

#############################################################################
##
#F  Transitivity( <arg> ) . . . . . . . . . . . . . . . . transitivity degree
##
Transitivity := function( arg )
    return AttributeOperation( TransitivityOp, TransitivityAttr, false, arg );
end;
InstallMethod( TransitivityOp,
        "<G>, [  ], <gens>, <perms>, <opr>", true,
        [ IsGroup, IsList and IsEmpty,
          IsList,
          IsList,
          IsFunction ], SUM_FLAGS,
    function( G, D, gens, oprs, opr )
    return 0;
end );

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
        hom := OperationHomomorphism( xset );
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
            if     not IsPcgs( gens )
               and not (     IsIdentical( GeneratorsOfGroup( G ), gens )
                         and IsIdentical( gens, oprs ) )  then
                if not IsBound( D )  then
                    D := OrbitOp( G, d, gens, oprs, opr );
                fi;
                hom := OperationHomomorphism( ExternalOrbitOp
                       ( G, D, d, gens, oprs, opr ) );
            fi;
        fi;
    fi;
    
    if IsBound( gens )  and  IsPcgs( gens )  then
        return RepresentativeOperation( G, D, d, e, gens, oprs, opr );
    elif IsBound( hom )  and  IsOperationHomomorphismByOperators( hom )  then
        d := Position( D[ d ] );  e := Position( D[ e ] );
        rep := RepresentativeOperationOp( ImagesSource( hom ), d, e,
                       OnPoints );
        if rep <> fail  then
            rep := PreImagesRepresentative( hom, rep );
        fi;
        return rep;
    elif IsBound( D )  then
        return RepresentativeOperationOp( G, D, d, e, opr );
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

InstallOtherMethod( StabilizerOp,
        "<G>, <D>, <pnt>, <gens>, <oprs>, <opr>", true,
        OrbitishReq, 0,
    function( G, D, d, gens, oprs, opr )
    local   hom;
    
    if not IsIdentical( gens, oprs )  then
        hom := OperationHomomorphism( ExternalOrbitOp
                       ( G, D, d, gens, oprs, opr ) );
        d := Position( D[ d ] );
        return PreImage( hom, StabilizerOp
                       ( ImagesSource( hom ), d, OnPoints ) );
    else
        return StabilizerOp( G, D, d, opr );
    fi;
end );

InstallOtherMethod( StabilizerOp,
        "<G>, <pnt>, <gens>, <oprs>, <opr>", true,
        [ IsGroup, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, d, gens, oprs, opr )
    if not IsIdentical( gens, oprs )  then
        return StabilizerOp( G, OrbitOp( G, d, gens, oprs, opr ), d,
                       gens, oprs, opr );
    else
        return StabilizerOp( G, d, opr );
    fi;
end );

InstallMethod( StabilizerOp,
        "<G>, <D>, <pnt>, <opr>", true,
        [ IsGroup, IsList, IsObject, IsFunction ], 0,
    function( G, D, d, opr )
    return StabilizerOp( G, d, opr );
end );

InstallOtherMethod( StabilizerOp,
        "<G>, <pnt>, <opr>", true,
        [ IsGroup, IsObject, IsFunction ], 0,
    function( G, d, opr )
    local   stb,        # stabilizer, result
            orb,        # orbit
            rep,        # representatives for the points in the orbit <orb>
            set,        # orbit <orb> as set for faster membership test
            gen,        # generator of the group <G>
            pnt,        # point in the orbit <orb>
            img,        # image of the point <pnt> under the generator <gen>
            sch;        # schreier generator of the stabilizer

    # standard operation
    if   opr = OnPoints  then
        orb := [ d ];
        set := [ d ];
        rep := [ One( G ) ];
        stb := TrivialSubgroup( G );
        for pnt  in orb  do
            for gen  in GeneratorsOfGroup( G )  do
                img := pnt ^ gen;
                if not img in set  then
                    Add( orb, img );
                    AddSet( set, img );
                    Add( rep, rep[Position(orb,pnt)]*gen );
                else
                    sch := rep[Position(orb,pnt)]*gen
                           / rep[Position(orb,img)];
                    if not sch in stb  then
                        stb := ClosureGroup( stb, sch );
                    fi;
                fi;
            od;
        od;

    # compute iterated stabilizers for the operation on pairs or on tuples
    elif opr = OnPairs  or opr = OnTuples  then
        stb := G;
        for pnt in d  do
            stb := StabilizerOp( stb, pnt, OnPoints );
        od;

    # other operation
    else
        orb := [ d ];
        set := [ d ];
        rep := [ One( G ) ];
        stb := TrivialSubgroup( G );
        for pnt  in orb  do
            for gen  in GeneratorsOfGroup( G )  do
                img := opr( pnt, gen );
                if not img in set  then
                    Add( orb, img );
                    AddSet( set, img );
                    Add( rep, rep[Position(orb,pnt)]*gen );
                else
                    sch := rep[Position(orb,pnt)]*gen
                           / rep[Position(orb,img)];
                    if not sch in stb  then
                        stb := ClosureGroup( stb, sch );
                    fi;
                fi;
            od;
        od;

    fi;

    # return the stabilizer <stb>
    return stb;
end );

#############################################################################
##
#M  CanonicalRepresentativeOfExternalSet( <xset> )  . . . . . . . . . . . . .
##
InstallMethod( CanonicalRepresentativeOfExternalSet, true,
        [ IsExternalSet ], 0,
    xset -> First( HomeEnumerator( xset ), p -> p in xset ) );

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
        xset -> StabilizerOp( ActingDomain( xset ),
                Representative( xset ), FunctionOperation( xset ) ) );

InstallMethod( StabilizerOfExternalSet, true,
        [ IsExternalSet and HasHomeEnumerator ], 0,
    xset -> StabilizerOp( ActingDomain( xset ), HomeEnumerator( xset ),
            Representative( xset ), FunctionOperation( xset ) ) );

#############################################################################
##

#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . for operation hom
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsOperationHomomorphismDefaultRep,
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
        [ IsOperationHomomorphismByBase and HasImagesSource,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   xset,  D,  opr,  base,  imgs;

    xset := hom!.externalSet;
    D := HomeEnumerator( xset );
    opr := FunctionOperation( xset );
    base := List( Base( xset ), b -> Position( D, b ) );
    imgs := List( Base( xset ), b -> Position( D, opr( b, elm ) ) );
    return RepresentativeOperationOp( ImagesSource( hom ),
                   base, imgs, OnTuples );
end );
                    
#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . for operation hom
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsOperationHomomorphismDefaultRep,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    return PreImagesRepresentative( AsGroupGeneralMappingByImages( hom ),
                   elm );
end );

#############################################################################
##
#M  Kernel( <hom> ) . . . . . . . . . . . . . . . . . . . . for operation hom
##
InstallMethod( Kernel, true, [ IsOperationHomomorphismDefaultRep ], 0,
    hom -> Kernel( AsGroupGeneralMappingByImages( hom ) ) );

#############################################################################
##
#M  IsInjective( <hom> )  . . . . . . . . . . . . . . . . . for operation hom
##
InstallMethod( IsInjective, true, [ IsOperationHomomorphismDefaultRep ], 0,
    hom -> IsInjective( AsGroupGeneralMappingByImages( hom ) ) );

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
