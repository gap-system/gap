#############################################################################
##
#W  qsystem.gi                 ipcq package                      Bettina Eick
##
#W  A qsystem describes an epimorphism G -> P from a finitely presented
#W  group G onto a polycyclically presented group P. It is a record 
#W  consisting of :
#W
#W    .fpgroup
#W    .fprels
#W
#W    .pcgroup
#W    .pcgens
#W    .pcords
#W    .pcone
#W    .pcrels / pcenum / pchand
#W
#W    .pcdefs / fpdefs
#W
#W    .imgs
#W    .prei ?
#W

#############################################################################
##
#F AddPcRelators( Q )
##
AddPcRelators := function( Q )
    local pcp, rel, n, r, c, e, i, j, a;

    # add relators
    pcp := Q.pcgens;
    rel := Q.pcords;
    n   := Length( pcp );

    r := [];
    c := [];
    e := [];
    for i in [1..n] do
        r[i] := [];
        e[i] := [];
        if rel[i] > 0 then
            a := pcp[i]^rel[i];
            e[i][i] := a;
            r[i][i] := ExponentsByPcp( pcp, a );
            r[i][i] := GlistOfVector( r[i][i] );
            Add( c, [i,i] );
        fi;
        for j in [1..i-1] do
            a := pcp[i] ^ pcp[j];
            e[i][j] := a;
            r[i][j] := ExponentsByPcp( pcp, a );
            r[i][j] := GlistOfVector( r[i][j] );
            Add( c, [i,j] );

            a := pcp[i] ^ (pcp[j]^-1);
            e[i][i+j] := a;
            r[i][i+j] := ExponentsByPcp( pcp, a );
            r[i][i+j] := GlistOfVector( r[i][i+j] );
            Add( c, [i, i+j] );
        od;
    od;
    Q.pcenum := c;
    Q.pcrels := r;
    Q.pchand := e;
end;

#############################################################################
##
#F ExtendDefinitions( Q, M, defs )
##
ExtendDefinitions := function( Q, M, defs )
    local m, i;
    m := Length( M.gens );
    for i in [1..Length(defs)] do
        if IsInt( defs[i] ) then
            if defs[i] <= M.nrpct then
                Add( Q.pcdefs, defs[i] );
            else
                Add( Q.fpdefs, defs[i]-M.nrpct );
            fi;
        else
            defs[i][1] := m+defs[i][1]; 
            Add( Q.pcdefs, Position( Q.pcenum, defs[i] ) );
        fi;
    od;
end;

#############################################################################
##
#F ExtendImages( Q, M, N )
##
ExtendImages := function( Q, M, N )
    local i, j;
    for i in [1..Length(Q.imgs)] do
        Q.imgs[i] := ShallowCopy( Exponents( Q.imgs[i] ) );
        j := Position( M.used, i + M.nrpct );
        if IsInt( j ) then
            Append( Q.imgs[i], N.tails[j] );
        else
            Append( Q.imgs[i], 0*N.tails[1] );
        fi;
        Q.imgs[i] := MappedVector( Q.imgs[i], Q.pcgens );
    od;
end;

#############################################################################
##
#F QSystem( G, P, imgs )
##
QSystem := function( G, P, imgs )
    local Q;

    Q := rec( );

    # add the fp-group
    Q.fpgroup := G;
    Q.fprels  := List( RelatorsOfFpGroup( G ), ExtRepOfObj );

    # add pc group
    Q.pcgroup := P;
    Q.pcgens := Pcp(P);
    Q.pcords := RelativeOrdersOfPcp( Q.pcgens );
    Q.pcone := One( P );
    AddPcRelators( Q );

    # add images
    Q.imgs := imgs;
 
    # return
    return Q;
end;

#############################################################################
##
#F ReduceMod( tail, relos )
##
ReducedMod := function( tail, relos )
    local i;
    for i in [1..Length(tail)] do
        if relos[i] > 0 then
            tail[i] := tail[i] mod relos[i];
        fi;
    od;
    return tail;
end;

#############################################################################
##
#F PcpExtensionQSystem( Q, M, N ) . . . . . . . . . . . . . .create extension
##
## Q is a quotient system, M a module presentation and N a matrix repr for M.
##
PcpExtensionQSystem := function( Q, M, N )
    local n, d, coll, i, j, g, e, r, o, x, k, v, G, rels, invs;

    # get dimensions
    n := Length( N.opers );
    d := Length( N.tails[1] );

    # in case c is ffe
    if Length( N.tails ) > 0 and IsFFE( N.tails[1] ) then
        N.tails := List( N.tails, IntVecFFE );
    fi;

    # reduce order and tails mod
    N.relos := List( N.relos, AbsInt );
    N.tails := List( N.tails, x -> ReducedMod( x, N.relos ) );

    # the free group
    coll := FromTheLeftCollector( n+d );

    # the relators of G
    for i in [1..Length(Q.pcenum)] do

        # get relator in G
        e := Q.pcenum[i];
        r := VectorOfGlist( Q.pcrels[e[1]][e[2]], n );

        # extend by tail if not avoided
        if i in M.used then
            Append( r, N.tails[Position(M.used, i)] );
        fi;

        # shift into collector
        o := ObjByExponents( coll, r );
        if e[1] = e[2] then
            SetRelativeOrder( coll, e[1], Q.pcords[e[1]] );
            SetPower( coll, e[1], o );
        elif e[1] > e[2] then
            SetConjugate( coll, e[1], e[2], o );
        else
            SetConjugate( coll, e[1], -e[2]+e[1], o );
        fi;
    od;

    # power relators of A
    for i in [1..d] do
        if N.relos[i] <> 0 then
            SetRelativeOrder( coll, n+i, N.relos[i] );
        fi;
    od;

    # conjugate relators - G acts on A
    invs := List( N.opers, x -> x^-1 );
    for i in [1..n] do
        for j in [n+1..n+d] do
            x := List( [1..n], x -> 0 );
            Append( x, ReducedMod( N.opers[i][j-n], N.relos ) );
            SetConjugate( coll, j, i, ObjByExponents( coll, x ) );
        od;
    od;

    return PcpGroupByCollector( coll );
end;

#############################################################################
##
#F ExtendQSystem( Q, M, N )
##
ExtendQSystem := function( Q, M, N )
    local d, SNF, i, j, pos;

    # catch a special case
    d := Length( N.opers[1] );
    if d = 0 then Add( Q.steps, [] ); return; fi;

    # do a base change to exhibit torsion
    if Length( N.order ) > 0 then
        SNF := NormalFormIntMat( N.order, 9 );
        N.tails := N.tails * SNF.coltrans;
        N.opers := List( N.opers, x -> x ^ SNF.coltrans );
        N.order := Filtered( SNF.normal, x -> x <> 0 * x );
    fi;

    # get relative orders
    N.relos := List( [1..d], x -> 0 );
    for i in [1..Length(N.order)] do N.relos[i] := N.order[i][i]; od;
    while ForAny( N.relos, x -> x = 1 ) do
        j := Position( N.relos, 1 );
        pos := Concatenation( [1..j-1], [j+1..Length(N.relos)] );
        N.tails := List( N.tails, x -> x{pos} );
        N.relos := N.relos{pos};
        N.opers := List( N.opers, x -> x{pos}{pos} );
    od;
    Add( Q.steps, N.relos );

    # reset Q
    Q.pcgroup := PcpExtensionQSystem( Q, M, N );
    Q.pcgens := Pcp( Q.pcgroup );
    Q.pcords := List( Q.pcgens, RelativeOrderPcp );
    Q.pcone := One( Q.pcgroup );
    AddPcRelators( Q );
    ExtendDefinitions( Q, M, GetDefinitions( M, N ) );
    ExtendImages( Q, M, N );
end;


