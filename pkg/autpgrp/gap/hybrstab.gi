#############################################################################
##
#W  hybridst.gi              AutPGrp package                     Bettina Eick
##
#H  @(#)$Id: hybrstab.gi,v 1.10 2009/03/09 07:26:55 gap Exp $
##
Revision.("autpgrp/gap/hybridst_gi") :=
    "@(#)$Id: hybrstab.gi,v 1.10 2009/03/09 07:26:55 gap Exp $";

#############################################################################
##
#F CollectToWord( list )
##
CollectToWord := function( list )
    local coll, t, i;
    coll := [];
    t := [list[1], 1];
    for i in [2..Length(list)] do
        if t[1] <> list[i] then
            Add( coll, t );
            t := [list[i], 1];
        else
            t[2] := t[2] + 1;
        fi;
    od; 
    Add( coll, t );
    return coll;
end;

#############################################################################
##
#F TransformPG( get, list, id )  . . . . . . . . . . . .convert get to element
##
TransformPG := function( get, list, id )
    local coll, res, i;

    # catch the special case
    if Length( get ) = 0 then return id; fi;

    # otherwise compute
    coll := CollectToWord( get );

    if coll[1][1] > 0 then 
        res := [PGPower( coll[1][2],list[coll[1][1]] )];
    else
        res := [PGPower( coll[1][2], PGInverse(list[-coll[1][1]]))];
    fi;
    for i in [2..Length(coll)] do
        if coll[i][1] > 0 then 
            Add( res, PGPower(coll[i][2],list[coll[i][1]] ) );
        else
            Add( res, PGPower(coll[i][2], PGInverse(list[-coll[i][1]]) ) );
        fi;
    od;
    return PGMultList( res );
end;

#############################################################################
##
#F Transform( get, list, id ) . . . . . . . . . . . . .convert get to element
##
Transform := function( get, list, id )
    local res, i;
    if Length( get ) = 0 then return id; fi;
    if get[1] > 0 then res := list[get[1]];
    else res := list[-get[1]]^-1;
    fi;
    for i in [2..Length( get )] do
        if get[i] > 0 then res := res * list[get[i]];
        else res := res * list[-get[i]]^-1;
        fi;
    od;
    return res;
end;

#############################################################################
##
#F ReduceGet( ords, get ) . . . . . . . . . . . . . . .reduce get with orders
##
ReduceGet := function( ords, get )
    local found, i, j, o;

    found := true;
    while found do

        # first reduce by inverses
        i := 1;
        found := false;
        while i <= Length( get ) - 1 do
            if not IsBool( get[i+1] ) and get[i] = - get[i+1] then
                get[i] := false;
                get[i+1] := false;
                found := true;
                i := i + 1;
            fi;
            i := i + 1;
        od;

        # now reduce by orders
        i := 1;
        while i <= Length( get ) do
            if not IsBool( get[i] ) then
                if get[i] > 0 then
                    o := ords[ get[i] ];
                else
                    o := ords[ -get[i] ];
                fi;
                if i+o-1 <= Length( get ) and 
                   ForAll( get{[i..i+o-1]}, x -> x = get[i] ) then
                    for j in [i..i+o-1] do
                        get[j] := false;
                    od;
                    found := true;
                    i := i + o - 1;
                fi;
            fi;
            i := i + 1;
        od;
    od;
    return Filtered( get, x -> not IsBool( x ) );
end;

#############################################################################
##
#F OSTransversalInverse( j, trans, trels, id )
##
OSTransversalInverse := function( j, trans, trels, id )
    local l, g, s, p, t;
    if j = 1 then return id; fi;
    l := Product( trels );
    j := j - 1;
    g := id;
    for s in Reversed( [1..Length( trans )] ) do
        p := trels[s];
        l := l/p;
        t := QuoInt( j, l );
        j := RemInt( j, l );
        if t > 0 then
           g := PGMult( g, PGInverse(trans[s])^t );
        fi;
    od;
    return g;
end;

#############################################################################
##
#F PcgsOrbitStabilizer( A, oper, pt, fpt, info ) 
##
PcgsOrbitStabilizer := function( A, oper, pt, fpt, info )
    local pcgs, rels, stabl, srels, trans, trels, orbit, i, y, j, p, l, s, 
          k, t, h, g;

    pcgs := A.agAutos;
    rels := A.agOrder;

    # catch trivial case
    if Length( pcgs ) = 0 then
        return rec( stabl := pcgs,
                    srels := rels,
                    orbit := [pt],
                    trans := [],
                    trels := [] );
    fi; 

    # initialise orbit, stabiliser and transversal
    stabl := [];
    srels := [];
    trans := [];
    trels := [];
    orbit := [pt];

    # Start constructing orbit.
    i := Length( pcgs );
    while i >= 1 do
        if oper[i] = 1 then
            Add( stabl, pcgs[i] );
            Add( srels, rels[i] );
        else
            y := fpt( pt, oper[i], info );
            j := Position( orbit, y );
            if IsBool( j ) then
    
                # enlarge transversal
                Add( trans, pcgs[i] );
                Add( trels, rels[i] );
    
                # enlarge orbit
                p := rels[i];
                l := Length( orbit );
                orbit[p*l] := true;
                s := 0;
                for k  in [ 1 .. p - 1 ]  do
                    t := s + l;
                    for h  in [ 1 .. l ]  do
                        orbit[h + t] := fpt( orbit[h + s], oper[i], info );
                    od;
           	        s := t;
                od;
            else

                # enlarge stabilizer
                if j > 1 then
                    g := OSTransversalInverse(j, trans, trels, A.one);
                    Add( stabl, PGMult( pcgs[i], g ) );
                else
                    Add( stabl, pcgs[i] );
                fi;
                Add( srels, rels[i] );
            fi;
        fi;
        i := i - 1;
    od;
   
    return rec( stabl := Reversed( stabl ),
                srels := Reversed( srels ),
                orbit := orbit,
                trans := trans,
                trels := trels );
end;

#############################################################################
##
#F BlockPosition( orbit, pt )
##
BlockPosition := function( orbit, pt )
    local h, j;
    for j in [1..Length(orbit)] do
        h := Position( orbit[j], pt );
        if not IsBool( h ) then return [j, h]; fi;
    od;
    return false;
end;

#############################################################################
##
#F BlockOrbitStabilizer( B, oper, os, fpt, info )
##
BlockOrbitStabilizer := function( B, oper, os, fpt, info )
    local bl, l, li, orbit, trans, stabl, pstab, mats, auts, ords, pers,
          k, pt, i, y, j, new, get, aut, g, per, s;

    # the block and limit for orbit length
    bl := os.orbit;
    l  := Length( bl );
    li := B.glOrder / Factors( B.glOrder )[1];

    # set up orbit, transversal and stab
    orbit := [ bl ];
    trans := [ [] ];
    stabl := [];
    pstab := [];

    # get acting elements
    auts := B.glAutos;
    ords := List( auts, Order );
    if IsBound( B.glOper ) then pers := B.glOper; fi;

    # loop
    k := 1;
    while k <= Length( orbit ) do
        pt := orbit[k][1];
        for i in [ 1..Length(oper) ] do

            # compute the image of a point
            y := fpt( pt, oper[i], info );
            j := BlockPosition( orbit, y );
            if IsBool( j ) then

                # enlarge orbit and transversal
                new := List( [1..l], x -> true );
                for s in [1..l] do
                    new[s] := fpt( orbit[k][s], oper[i], info );
                od;
                Add( orbit, new );
                get := Concatenation( trans[k], [i] );
                Add( trans, get );
            else

                # enlarge stabilizer
                get := Concatenation(trans[k], [i], Reversed(-trans[j[1]])); 
                get := ReduceGet( ords, get );
                aut := TransformPG( get, auts, B.one );

                # reduce from block-stab to point-stab
                if j[2] > 1 then
                    g := OSTransversalInverse(j[2], os.trans, os.trels, B.one);
                    aut := PGMult( aut, g );
                fi;
                Add( stabl, aut );

                # add permutations if known
                if IsBound( B.glOper ) then
                    Add( pstab, Transform( get, pers, () ) );
                fi;
            fi;
        od;
        if Length( orbit ) > li then
            return rec( stabl := [], pstab := [], length := B.glOrder );
        else
            k := k + 1;
        fi;
    od;

    return rec( stabl := stabl, pstab := pstab, 
                length := Length(orbit), trans := trans );
end;

#############################################################################
##
#F PGHybridOrbitStabilizer( A, glMats, agMats, pt, oper, info )
##
PGHybridOrbitStabilizer := function( A, glMats, agMats, pt, oper, info )
    local os, OS, B;

    # compute ag orbit stabilizier
    if Length( glMats ) = 0 and Length( agMats ) = 0 then return; fi;
    os := PcgsOrbitStabilizer( A, agMats, pt, oper, info );
    Info( InfoAutGrp, 4, "    ag-orbit -- length ",Length(os.orbit));

    # add info to A
    A.agAutos := os.stabl;
    A.agOrder := os.srels;

    # compute block orbit and stabiliser
    if Length( glMats ) = 0 then return; fi;
    OS := BlockOrbitStabilizer( A, glMats, os, oper, info );
    Info( InfoAutGrp, 4, "    gl-orbit -- length ", OS.length, 
                         " -- gens ",Length(OS.stabl));
  
    # set up new aut grp
    A.glAutos := OS.stabl;
    A.glOrder := A.glOrder / OS.length;
    Assert(1,IsInt(A.glOrder));
    if IsBound( A.glOper ) then A.glOper := OS.pstab; fi;

    # nice the glAutos if necessary
    if NICE_STAB and OS.length > 1 then NiceHybridGroup( A ); fi;
end;

