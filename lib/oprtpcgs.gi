#############################################################################
##
#W  oprtpcgs.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.oprtpcgs_gi :=
    "@(#)$Id$";

#############################################################################
##
#M  OrbitStabilizerOp( <G>, <D>, <pnt>, <pcgs>, <oprs>, <opr> ) . . . by pcgs
##
InstallMethod( OrbitStabilizerOp,
        "G, D, pnt, pcgs, oprs, opr", true,
        [ IsGroup, IsList, IsObject, IsPcgs, IsList, IsFunction ], 0,
    function( G, D, pnt, pcgs, oprs, opr )
    return OrbitStabilizerOp( G, pnt, pcgs, oprs, opr );
end );

InstallOtherMethod( OrbitStabilizerOp,
        "G, pnt, pcgs, oprs, opr", true,
        [ IsGroup, IsObject, IsPcgs, IsList, IsFunction ], 0,
    function( G, pnt, pcgs, oprs, opr )
    local   orb,        # orbit
            len,        # lengths of orbit before each extension
            stab,  S,   # stabilizer and induced pcgs
            img,  pos,  # image of <pnt> and its position in <orb>
            stb,        # stabilizing element, a word in <pcgs>
            i, ii, j, k;# loop variables

    orb := [ pnt ];
    len := ListWithIdenticalEntries( Length( pcgs ) + 1, 0 );
    len[ Length( len ) ] := 1;
    S := [  ];
    for i  in Reversed( [ 1 .. Length( pcgs ) ] )  do
        img := opr( pnt, oprs[ i ] );
        pos := Position( orb, img );
        if pos = fail  then
            
            # The current generator moves the orbit as a block.
            Add( orb, img );
            for j  in [ 2 .. len[ i + 1 ] ]  do
                img := opr( orb[ j ], oprs[ i ] );
                Add( orb, img );
            od;
            for k  in [ 3 .. RelativeOrders( pcgs )[ i ] ]  do
                for j  in Length( orb ) + [ 1 - len[ i + 1 ] .. 0 ]  do
                    img := opr( orb[ j ], oprs[ i ] );
                    Add( orb, img );
                od;
            od;
            
        else
          
            # The current generator leaves the orbit invariant.
            stb := ListWithIdenticalEntries( Length( pcgs ), 0 );
            stb[ i ] := 1;
            ii := i + 2;
            while pos <> 1  do
                while len[ ii ] >= pos  do
                    ii := ii + 1;
                od;
                stb[ ii - 1 ] := -QuoInt( pos - 1, len[ ii ] );
                pos := ( pos - 1 ) mod len[ ii ] + 1;
            od;
            Add( S, PcElementByExponents( pcgs, stb ) );
            
        fi;
        len[ i ] := Length( orb );
    od;
        
    # <S> is a reversed IGS.
    stab := SubgroupNC( G, S );
    SetInducedPcgsWrtHomePcgs( stab,
            InducedPcgsByPcSequenceNC( ParentPcgs( pcgs ), Reversed( S ) ) );

    return Immutable( rec( orbit := orb, stabilizer := stab ) );
end );

#############################################################################
##
#F  SetCanonicalRepresentativeOfExternalOrbitByPcgs( <xset> ) . . . . . . . .
##
SetCanonicalRepresentativeOfExternalOrbitByPcgs := function( xset )
    local   G,  D,  pnt,  pcgs,  oprs,  opr,
            orb,  bit,  # orbit, as list and bit-list
            len,        # lengths of orbit before each extension
            stab,  S,   # stabilizer and induced pcgs
            img,  pos,  # image of <pnt> and its position in <D> (or <orb>)
            min,  mpos, # minimal value of <pos>, position in <orb>
            stb,        # stabilizing element, a word in <pcgs>
            oper,       # operating element, a word in <pcgs>
            i, ii, j, k;# loop variables

    G    := ActingDomain( xset );
    D    := HomeEnumerator( xset );
    pnt  := Representative( xset );
    if IsExternalSetDefaultRep( xset )  then
        pcgs := Pcgs( G );
        oprs := pcgs;
        opr  := FunctionOperation( xset );
    else
        pcgs := xset!.generators;
        oprs := xset!.operators;
        opr  := xset!.funcOperation;
    fi;
    
    orb := [ pnt ];
    len := ListWithIdenticalEntries( Length( pcgs ) + 1, 0 );
    len[ Length( len ) ] := 1;
    min := Position( D, pnt );  mpos := 1;
    bit := BlistList( [ 1 .. Length( D ) ], [ min ] );
    S := [  ];
    for i  in Reversed( [ 1 .. Length( pcgs ) ] )  do
        img := opr( pnt, oprs[ i ] );
        pos := PositionCanonical( D, img );
        if not bit[ pos ]  then
            
            # The current generator moves the orbit as a block.
            Add( orb, img );  bit[ pos ] := true;
            if pos < min  then
                min := pos;  mpos := Length( orb );
            fi;
            for j  in [ 2 .. len[ i + 1 ] ]  do
                img := opr( orb[ j ], oprs[ i ] );
                pos := PositionCanonical( D, img );
                Add( orb, img );  bit[ pos ] := true;
                if pos < min  then
                    min := pos;  mpos := Length( orb );
                fi;
            od;
            for k  in [ 3 .. RelativeOrders( pcgs )[ i ] ]  do
                for j  in Length( orb ) + [ 1 - len[ i + 1 ] .. 0 ]  do
                    img := opr( orb[ j ], oprs[ i ] );
                    pos := PositionCanonical( D, img );
                    Add( orb, img );  bit[ pos ] := true;
                    if pos < min  then
                        min := pos;  mpos := Length( orb );
                    fi;
                od;
            od;
            
        else
          
            # The current generator leaves the orbit invariant.
            pos := Position( orb, img );
            stb := ListWithIdenticalEntries( Length( pcgs ), 0 );
            stb[ i ] := 1;
            ii := i + 2;
            while pos <> 1  do
                while len[ ii ] >= pos  do
                    ii := ii + 1;
                od;
                stb[ ii - 1 ] := -QuoInt( pos - 1, len[ ii ] );
                pos := ( pos - 1 ) mod len[ ii ] + 1;
            od;
            Add( S, PcElementByExponents( pcgs, stb ) );
            
        fi;
        len[ i ] := Length( orb );
    od;
    SetEnumerator( xset, orb );

    # Construct the operator for the minimal point at <mpos>.
    oper := ListWithIdenticalEntries( Length( pcgs ), 0 );
    ii := 2;
    while mpos <> 1  do
        while len[ ii ] >= mpos  do
            ii := ii + 1;
        od;
        mpos := mpos - 1;
        oper[ ii - 1 ] := -QuoInt( mpos, len[ ii ] );
        mpos := mpos mod len[ ii ] + 1;
    od;
    SetCanonicalRepresentativeOfExternalSet( xset, D[ min ] );
    if not HasOperatorOfExternalSet( xset )  then
        SetOperatorOfExternalSet( xset,
                PcElementByExponents( pcgs, oper ) ^ -1 );
    fi;
            
    # <S> is a reversed IGS.
    if not HasStabilizerOfExternalSet( xset )  then
        stab := SubgroupNC( G, S );
        SetInducedPcgsWrtHomePcgs( stab,
            InducedPcgsByPcSequenceNC( ParentPcgs( pcgs ), Reversed( S ) ) );
        SetStabilizerOfExternalSet( xset, stab );
    fi;
    
end;

#############################################################################
##
#M  Enumerator( <xorb> )  . . . . . . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( Enumerator, "<xorb by pcgs>", true,
        [ IsExternalOrbit and IsExternalSetByPcgs ], 0,
    function( xorb )
    local   orbstab;
    
    orbstab := OrbitStabilizer( xorb, Representative( xorb ) );
    SetStabilizerOfExternalSet( xorb, orbstab.stabilizer );
    return orbstab.orbit;
end );

#############################################################################
##
#M  CanonicalRepresentativeOfExternalSet( <xorb> )  . . . . . . . . . . . . .
##
InstallMethod( CanonicalRepresentativeOfExternalSet,
        "via `OperatorOfExternalSet'", true,
        [ IsExternalOrbit and IsExternalSetByPcgs ], 0,
    function( xorb )
    local   oper;
    
    oper := OperatorOfExternalSet( xorb );
    if HasCanonicalRepresentativeOfExternalSet( xorb )  then
        return CanonicalRepresentativeOfExternalSet( xorb );
    else
        return FunctionOperation( xorb )( Representative( xorb ), oper );
    fi;
end );

#############################################################################
##
#M  OperatorOfExternalSet( <xorb> ) . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( OperatorOfExternalSet, true,
        [ IsExternalOrbit and IsExternalSetByPcgs ], 0,
    function( xorb )
    SetCanonicalRepresentativeOfExternalOrbitByPcgs( xorb );
    return OperatorOfExternalSet( xorb );
end );

#############################################################################
##
#M  StabilizerOfExternalSet( <xorb> ) . . . . .  stabilizer of representative
##
InstallMethod( StabilizerOfExternalSet, true,
        [ IsExternalOrbit and IsExternalSetByPcgs ], 0,
    function( xorb )
    local   orbstab;

    orbstab := OrbitStabilizer( xorb, Representative( xorb ) );
    SetEnumerator( xorb, orbstab.orbit );
    return orbstab.stabilizer;
end );

#############################################################################
##

#M  OrbitOp( <G>, <D>, <pnt>, <pcgs>, <oprs>, <opr> ) . . . . . based on pcgs
##
InstallMethod( OrbitOp,
        "G, D, pnt, pcgs, oprs, opr", true,
        [ IsGroup, IsList, IsObject, IsPcgs, IsList, IsFunction ], 0,
    function( G, D, pnt, pcgs, oprs, opr )
    return OrbitOp( G, pnt, pcgs, oprs, opr );
end );

InstallOtherMethod( OrbitOp,
        "G, pnt, pcgs, oprs, opr", true,
        [ IsGroup, IsObject, IsPcgs, IsList, IsFunction ], 0,
    function( G, pt, U, V, op )
    local   orb,  v,  img,  len,  i,  j,  k;
    
    orb := [ pt ];
    for i  in Reversed( [ 1 .. Length( V ) ] )  do
        v := V[ i ];
        img := op( pt, v );
        if not img in orb  then
            len := Length( orb );
            Add( orb, img );
            for j  in [ 2 .. len ]  do
                Add( orb, op( orb[ j ], v ) );
            od;
            for k  in [ 3 .. RelativeOrders( V )[ i ] ]  do
                for j  in [ Length( orb ) - len + 1 .. Length( orb ) ]  do
                    Add( orb, op( orb[ j ], v ) );
                od;
            od;
        fi;
    od;
    return Immutable( orb );
end );
        
#############################################################################
##
#M  RepresentativeOperationOp( <G>, <D>, <d>, <e>, <pcgs>, <oprs>, <opr> )  .
##
InstallOtherMethod( RepresentativeOperationOp, true,
    [ IsGroup, IsList, IsObject, IsObject, IsPcgs, IsList, IsFunction ], 0,
    function( G, D, d, e, pcgs, oprs, opr )
    local   dset,  eset;
    
    dset := ExternalOrbit( G, D, d, pcgs, oprs, opr );
    eset := ExternalOrbit( G, D, e, pcgs, oprs, opr );
    return OperatorOfExternalSet( dset ) /
           OperatorOfExternalSet( eset );
end );

#############################################################################
##
#M  StabilizerOp( <G>, <D>, <pt>, <U>, <V>, <op> )  . . . . . . based on pcgs
##
InstallMethod( StabilizerOp,
        "G, D, pnt, pcgs, oprs, opr", true,
        [ IsGroup, IsList, IsObject, IsPcgs,
          IsList,
          IsFunction ], 0,
    function( G, D, pt, U, V, op )
    return OrbitStabilizerOp( G, pt, U, V, op ).stabilizer;
end );

InstallOtherMethod( StabilizerOp,
        "G, pnt, pcgs, oprs, opr", true,
        [ IsGroup, IsObject, IsPcgs,
          IsList,
          IsFunction ], 0,
    function( G, pt, U, V, op )
    return OrbitStabilizerOp( G, pt, U, V, op ).stabilizer;
end );

InstallOtherMethod( StabilizerOp,
        "G (solv.), pnt, gens, gens, opr", true,
        [ IsGroup and IsPcgsComputable, IsObject,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pt, gens, oprs, op )
    if gens = oprs  then
        return OrbitStabilizerOp( G, pt, Pcgs(G), Pcgs(G), op ).stabilizer;
    else
        TryNextMethod();
    fi;
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
