#############################################################################
##
#W  oprtpcgs.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.16  1997/01/28 12:50:24  htheisse
#H  avoided setting of `HomePcgs'
#H
#H  Revision 4.15  1997/01/27 11:21:06  htheisse
#H  removed some of Juergen Mnich's code
#H
#H  Revision 4.14  1997/01/21 15:07:33  htheisse
#H  introduced `PositionCanonical'
#H
#H  Revision 4.13  1997/01/20 16:51:11  htheisse
#H  replaced `HomePcgs' by `ParentPcgs'
#H
#H  Revision 4.12  1997/01/15 15:59:55  htheisse
#H  gave stabilizers an induced pcgs
#H
#H  Revision 4.11  1997/01/09 17:57:37  htheisse
#H  used enumerator to make representative canonical
#H
#H  Revision 4.10  1996/12/19 09:41:51  htheisse
#H  changed some names (in connection with oprt.gi change)
#H
#H  Revision 4.9  1996/11/29 16:29:43  htheisse
#H  corrected solvable orbit algorithm
#H
#H  Revision 4.8  1996/11/21 09:55:08  beick
#H  added stuff for pc groups
#H
#H  Revision 4.7  1996/11/19  13:22:37  htheisse
#H  changed method for `Stabilizer' in `oprtpcgs.gi'
#H  cleaned up the code
#H
#H  Revision 4.6  1996/11/13 15:24:09  htheisse
#H  added `OrbitStabilizer'
#H  encouraged use of pcgs for soluble groups
#H  cleaned up the code
#H
#H  Revision 4.5  1996/11/07 12:31:18  htheisse
#H  introduced `ExternalSubset'
#H  added `SetBase' for external sets
#H  renamed `Parent' to `HomeEnumerator' for external sets
#H  tidied up a bit
#H
#H  Revision 4.4  1996/10/31 12:19:46  htheisse
#H  replaced `RelativeOrderPcgs( pcgs, i )' by `RelativeOrders( pcgs )[ i ]'
#H
#H  Revision 4.3  1996/10/14 12:56:42  fceller
#H  'Position', 'PositionBound', and 'PositionProperty' return 'fail'
#H  instead of 'false'
#H
#H  Revision 4.2  1996/10/08 11:27:40  htheisse
#H  changed the operation functions, introduced ``external sets''
#H
#H  Revision 4.1  1996/10/01 14:50:10  htheisse
#H  added methods for operations of soluble groups, which use a pcgs
#H
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
#    local   orb,  bit,  # orbit, as list and bit-list
#            len,        # lengths of orbit before each extension
#            stab,  S,   # stabilizer and induced pcgs
#            img,  pos,  # image of <pnt> and its position in <D> (or <orb>)
#            stb,        # stabilizing element, a word in <pcgs>
#            i, ii, j, k;# loop variables
#
#    orb := [ pnt ];
#    len := 0 * [ 0 .. Length( pcgs ) ];  len[ Length( len ) ] := 1;
#    bit := BlistList( [ 1 .. Length( D ) ], [ PositionCanonical( D, pnt ) ] );
#    S := [  ];
#    for i  in Reversed( [ 1 .. Length( pcgs ) ] )  do
#        img := opr( pnt, oprs[ i ] );
#        pos := PositionCanonical( D, img );
#        if not bit[ pos ]  then
#            
#            # The current generator moves the orbit as a block.
#            Add( orb, img );  bit[ pos ] := true;
#            for j  in [ 2 .. len[ i + 1 ] ]  do
#                img := opr( orb[ j ], oprs[ i ] );
#                pos := PositionCanonical( D, img );
#                Add( orb, img );  bit[ pos ] := true;
#            od;
#            for k  in [ 3 .. RelativeOrders( pcgs )[ i ] ]  do
#                for j  in Length( orb ) + [ 1 - len[ i + 1 ] .. 0 ]  do
#                    img := opr( orb[ j ], oprs[ i ] );
#                    pos := PositionCanonical( D, img );
#                    Add( orb, img );  bit[ pos ] := true;
#                od;
#            od;
#            
#        else
#          
#            # The current generator leaves the orbit invariant.
#            pos := Position( orb, img );
#            stb := 0 * [ 1 .. Length( pcgs ) ];  stb[ i ] := 1;
#            ii := i + 1;
#            while pos <> 1  do
#                while len[ ii ] >= pos  do
#                    ii := ii + 1;
#                od;
#                pos := pos - 1;
#                stb[ ii - 1 ] := -QuoInt( pos, len[ ii ] );
#                pos := pos mod len[ ii ] + 1;
#            od;
#            Add( S, PcElementByExponents( pcgs, stb ) );
#            
#        fi;
#        len[ i ] := Length( orb );
#    od;
#
#    # <S> is a reversed IGS.
#    stab := SubgroupNC( G, S );
#    SetPcgs( stab, InducedPcgsByPcSequenceNC( pcgs, Reversed( S ) ) );
#    
#    return Immutable( rec( orbit := orb, stabilizer := stab ) );
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
    len := 0 * [ 0 .. Length( pcgs ) ];  len[ Length( len ) ] := 1;
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
            stb := 0 * [ 1 .. Length( pcgs ) ];  stb[ i ] := 1;
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
    SetPcgs( stab, InducedPcgsByPcSequenceNC( pcgs, Reversed( S ) ) );

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
    pcgs := xset!.generators;
    oprs := xset!.operators;
    opr  := xset!.funcOperation;
    
    orb := [ pnt ];
    len := 0 * [ 0 .. Length( pcgs ) ];  len[ Length( len ) ] := 1;
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
            stb := 0 * [ 1 .. Length( pcgs ) ];  stb[ i ] := 1;
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
    if not HasEnumerator( xset )  then
        SetEnumerator( xset, orb );
    fi;

    # Construct the operator for the minimal point at <mpos>.
    oper := 0 * [ 1 .. Length( pcgs ) ];
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
    SetOperatorOfExternalSet( xset,
            PcElementByExponents( pcgs, oper ) ^ -1 );
            
    # <S> is a reversed IGS.
    stab := SubgroupNC( G, S );
    SetPcgs( stab, InducedPcgsByPcSequenceNC( pcgs, Reversed( S ) ) );
    SetStabilizerOfExternalSet( xset, stab );
    
end;

#############################################################################
##
#M  Enumerator( <xorb> )  . . . . . . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( Enumerator, "<xorb by pcgs>", true,
        [ IsExternalOrbit and IsExternalSetByPcgsRep ], 0,
    function( xorb )
    local   orbstab;
    
    orbstab := OrbitStabilizer( xorb, Representative( xorb ) );
    if not HasStabilizerOfExternalSet( xorb )  then
        SetStabilizerOfExternalSet( xorb, orbstab.stabilizer );
    fi;
    return orbstab.orbit;
end );

#############################################################################
##
#M  CanonicalRepresentativeOfExternalSet( <xorb> )  . . . . . . . . . . . . .
##
InstallMethod( CanonicalRepresentativeOfExternalSet, true,
        [ IsExternalOrbit and IsExternalSetByPcgsRep ], 0,
    function( xorb )
    SetCanonicalRepresentativeOfExternalOrbitByPcgs( xorb );
    return CanonicalRepresentativeOfExternalSet( xorb );
end );

#############################################################################
##
#M  OperatorOfExternalSet( <xorb> ) . . . . . . . . . . . . . . . . . . . . .
##
InstallMethod( OperatorOfExternalSet, true,
        [ IsExternalOrbit and IsExternalSetByPcgsRep ], 0,
    function( xorb )
    SetCanonicalRepresentativeOfExternalOrbitByPcgs( xorb );
    return OperatorOfExternalSet( xorb );
end );

#############################################################################
##
#M  StabilizerOfExternalSet( <xorb> ) . . . . .  stabilizer of representative
##
InstallMethod( StabilizerOfExternalSet, true,
        [ IsExternalOrbit and IsExternalSetByPcgsRep ], 0,
    function( xorb )
    local   orbstab;

    orbstab := OrbitStabilizer( xorb, Representative( xorb ) );
    if not HasEnumerator( xorb )  then
        SetEnumerator( xorb, orbstab.orbit );
    fi;
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
InstallOtherMethod( StabilizerOp,
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

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
