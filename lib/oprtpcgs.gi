#############################################################################
##
#W  oprtpcgs.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
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
        "<G>, <D>, <pnt>, <pcgs>, <oprs>, <opr>", true,
        [ IsGroup, IsList, IsObject, IsPcgs,
          IsList,
          IsFunction ], 0,
    function( G, D, pnt, pcgs, oprs, opr )
    local   orb,        # orbit
            new,  n,    # transversal information for orbit, one info piece
            stab,  S,   # stabilizer and induced pcgs
            fst,        # position of <pnt> in <D>
            img,  pos,  # image of <pnt> and its position in <D>
            stb,        # stabilizing element, a word in <pcgs>
            p,          # exponent occuring in this word
            len,        # length of orbit before extension
            i,  j,  k;  # loop variables
    
    return OrbitStabilizerOp( G, pnt, pcgs, oprs, opr );
    
    fst := PositionCanonical( D, pnt );
    orb := [ pnt ];  new := [  ];  new[ fst ] := 0;
    S := [  ];
    for i  in Reversed( [ 1 .. Length( pcgs ) ] )  do
        img := opr( pnt, oprs[ i ] );
        pos := PositionCanonical( D, img );
        if IsBound( new[ pos ] )  then
            
            # The current generator leaves the orbit invariant.
            stb := pcgs[ i ];
            while pos <> fst  do
                j := new[ pos ][ 1 ];
                p := new[ pos ][ 2 ];
                stb := stb * pcgs[ j ] ^ -p;
                img := opr( img, oprs[ j ] ^ -p );
                pos := PositionCanonical( D, img );
            od;
            Add( S, stb );
            
        else
            
            # The current generator moves the orbit as a block.
            len := Length( orb );
            n := [ i, 1 ];
            Add( orb, img );  new[ pos ] := n;
            for j  in [ 2 .. len ]  do
                img := opr( orb[ j ], oprs[ i ] );
                pos := PositionCanonical( D, img );
                Add( orb, img );  new[ pos ] := n;
            od;
            for k  in [ 3 .. RelativeOrders( pcgs )[ i ] ]  do
                n := [ i, k - 1 ];
                for j  in [ Length( orb ) - len + 1 .. Length( orb ) ]  do
                    img := opr( orb[ j ], oprs[ i ] );
                    pos := PositionCanonical( D, img );
                    Add( orb, img );  new[ pos ] := n;
                od;
            od;
            
        fi;
    od;
                
    # <S> is a reversed IGS.
    stab := SubgroupNC( G, S );
    SetHomePcgs( stab, pcgs );
    SetInducedPcgsWrtHomePcgs( stab,
            InducedPcgsByPcSequenceNC( stab, Reversed( S ) ) );
    return Immutable( rec( orbit := orb, stabilizer := stab ) );
end );

InstallOtherMethod( OrbitStabilizerOp,
        "<G>, <pnt>, <pcgs>, <oprs>, <opr>", true,
        [ IsGroup, IsObject, IsPcgs,
          IsList,
          IsFunction ], 0,
    function( G, p, U, V, opr )
    local   O,          # complete Orbit
            prod,       # Auxiliary Variable to compute agword rep
            n,          # Auxiliary Variable to compute agword rep
            stab,  S,   # Agword stabilizer
            i, j, k,    # Loop
            len,
    	    l1, l2,
            o,          # relative order of next generators
            mi,
            np,         # New point
            r,          # Temp
            e;          # Temp

    # Initialize all.
    O    := [ p ];
    prod := [ 1 ];
    n    := [ ];
    S    := [ ];

    # Start constructing orbit.
    for i  in Reversed( [ 1 .. Length( V ) ] )  do
        mi := V[ i ];
        np := opr( p, mi );

        # Is <np> really a new point or is it in <O>.
        j := PositionCanonical( O, np );

        # Let's see if it is new (j = fail).
        if j = fail  then
            o := RelativeOrders( U )[ i ];
            Add( prod, prod[ Length( prod ) ] * o );
            Add( n, i );
            len := Length( O );
            l1 := 0;
            O[ o * len ] := true;
            for k  in [ 1 .. o - 1 ]  do
                l2 := l1 + len;
                for j  in [ 1 .. len ]  do
                    O[ j + l2 ] := opr( O[ j + l1 ], mi );
                od;
                l1 := l2;
            od;
        elif j = 1 then
            Add( S, U[i] );
        else
            r := OneOfPcgs( U );
            j := j - 1;
    	    len := Length( prod );
            for k  in [ 1 .. len - 1 ]  do
                e := QuoInt( j, prod[ len - k ] );
                r := U[ n[ len - k ] ] ^ e * r;
                j := j mod prod[ len - k ];
            od;
            Add( S, U[i] * r ^ -1 );
        fi;
    od;

    # <S> is a reversed IGS.
    stab := SubgroupNC( G, S );
    SetHomePcgs( stab, U );
    SetInducedPcgsWrtHomePcgs( stab,
            InducedPcgsByPcSequenceNC( U, Reversed( S ) ) );
    return Immutable( rec( orbit := O, stabilizer := stab ) );
end );

#############################################################################
##
#F  SetCanonicalRepresentativeOfExternalOrbitByPcgs( <xset> ) . . . . . . . .
##
SetCanonicalRepresentativeOfExternalOrbitByPcgs := function( xset )
    local   group, vs, vec, pcgs, mats, opr,
            orbit, torbit, stab, gen, orbpos, operator, pv, gn, S,
            mvec, mnum, num, p, z, i, j, k;

    group := ActingDomain( xset );
    vs    := HomeEnumerator( xset );
    vec   := Representative( xset );
    pcgs  := xset!.generators;
    mats  := xset!.operators;
    opr   := xset!.funcOperation;
    
    orbit := [ vec ];
    stab  := [];
    pv    := [ 1 ];
    gn    := [];

    for i  in Reversed( [ 1 .. Length( pcgs ) ] )  do
        gen    := pcgs[ i ];
        orbpos := Position( orbit, opr( vec, mats[i] ) );
        if orbpos = fail  then
            p := RelativeOrders( pcgs )[ i ];
            Add( pv, pv[Length( pv )] * p );
            Add( gn, i );
            torbit := ShallowCopy( orbit );
            for j in [1..p-1] do
                for k in [1..Length( torbit )] do
                    torbit[k] := opr( torbit[k], mats[i] );
                od;
                Append( orbit, torbit );
            od;
        elif orbpos = 1  then
            Add( stab, gen );
        else
            operator := One( group );
            orbpos   := orbpos - 1;
            j        := Length( pv ) - 1;
            while orbpos > 0 and j > 0 do
                operator := pcgs[gn[j]] ^ QuoInt( orbpos, pv[j] ) * operator;
                orbpos   := orbpos mod pv[j];
                j        := j - 1;
            od;
            Add( stab, gen / operator );
        fi;
    od;

    mvec := vec;
    mnum := PositionCanonical( vs, vec );

    orbpos := 1;
    j      := Length( orbit );
    while j > 1 and mnum > 1 do
        num := PositionCanonical( vs, orbit[j] );
        if num < mnum then
            mnum   := num;
            mvec   := orbit[j];
            orbpos := j;
        fi;
        j := j - 1;
    od;
    operator := One( group );
    orbpos   := orbpos - 1;
    j        := Length( pv ) - 1;
    while orbpos > 0 and j > 0 do
        operator := pcgs[gn[j]] ^ QuoInt( orbpos, pv[j] ) * operator;
        orbpos   := orbpos mod pv[j];
        j        := j - 1;
    od;

    S := SubgroupNC( group, stab );
    SetHomePcgs( S, pcgs );
    SetInducedPcgsWrtHomePcgs( S,
            InducedPcgsByPcSequenceNC( pcgs, Reversed( stab ) ) );
    if not HasEnumerator( xset )  then
        SetEnumerator( xset, orbit );
    fi;
    SetCanonicalRepresentativeOfExternalSet( xset, vs[ mnum ] );
    SetOperatorOfExternalSet( xset, operator );
    SetStabilizerOfExternalSet( xset, S );
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
        "<G>, <D>, <pnt>, <pcgs>, <oprs>, <opr>", true,
        OrbitishReq, 0,
    function( G, D, pnt, pcgs, oprs, opr )
    return OrbitOp( G, pnt, pcgs, oprs, opr );
end );

InstallOtherMethod( OrbitOp,
        "<G>, <pnt>, <pcgs>, <oprs>, <opr>", true,
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
        "<G>, <D>, <pnt>, <pcgs>, <oprs>, <opr>", true,
        [ IsGroup, IsList, IsObject, IsPcgs,
          IsList,
          IsFunction ], 0,
    function( G, D, pt, U, V, op )
    return OrbitStabilizerOp( G, pt, U, V, op ).stabilizer;
end );

InstallOtherMethod( StabilizerOp,
        "<G>, <pnt>, <pcgs>, <oprs>, <opr>", true,
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
