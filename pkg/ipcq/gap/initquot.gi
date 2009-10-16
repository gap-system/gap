#############################################################################
##
#W  initquot.gi                   ipcq package                   Bettina Eick
##

#############################################################################
##
#F AbelianPcpGroupByMat( mat )
##
AbelianPcpGroupByMat := function( mat )
    local n, o, l, coll, i, j, w;

    # set up
    n := Length(mat);
    o := Filtered( [1..n], x -> mat[x][x] <> 1 );
    l := Length(o);

    # check a special case and initiate collector
    if l = 0 then return Subgroup(AbelianPcpGroup(1,[0]), []); fi;
    coll := FromTheLeftCollector( l );

    # add power rels
    for i in [1..l] do
        j := o[i];
        if mat[j][j] <> 0 then
            SetRelativeOrder( coll, i, mat[j][j] );
            w := -StructuralCopy(mat[j]); w[j] := 0;
            if w <> 0 * w then
                SetPower( coll, i, ObjByExponents( coll, w{o} ) );
            fi;
        fi;
    od;

    # return
    return PcpGroupByCollector(coll);
end;

#############################################################################
##
#F InitQSystem( G ) . . . . . . . . . . . . . . . . . . . . .G is an fp group
##
InstallGlobalFunction( InitQSystem, function( G )
    local Q, r, n, A, S, H, i, j, w, pos;
    
    # set up Q-system and add fp group 
    Q := rec( );
    Q.fpgroup := G;
    Q.fprels := Set( List( RelatorsOfFpGroup( G ), ExtRepOfObj ) );
    Sort( Q.fprels, function( a, b ) return Length(a)<Length(b); end );
    r := Length( Q.fprels );
    n := Length( GeneratorsOfGroup( G ) );

    # create the relation matrix
    A := NullMat( Maximum( r, n ), n );
    for i in [1..r] do
        w := Q.fprels[i];
        for j in [1, 3 .. Length(w)-1] do
            A[i][w[j]] := A[i][w[j]] + w[j+1];
        od;
    od;

    # translate to pcp relations 
    S := NormalFormIntMat( A, 2 ).normal;
    H := NullMat( n, n );
    for i in [1..Length(S)] do
        j := DepthVector( S[i] );
        if j <= n then H[j] := S[i]; fi;
    od;
    
    # create a pcp group - filter non-trivial entries in H
    Q.pcgroup := AbelianPcpGroupByMat( H );
    Q.pcgens := Pcp( Q.pcgroup );
    Q.pcords := RelativeOrdersOfPcp( Q.pcgens );
    Q.pcone := One( Q.pcgroup );
    Q.steps := [ Q.pcords ];
    AddPcRelators( Q );

    # add definitions
    Q.pcdefs := [];
    Q.fpdefs := Filtered( [1..n], x -> H[x][x] <> 1 );

    # add images
    Q.imgs := List( [1..n], x -> Q.pcone );
    for i in [1..n] do
        j := Position( Q.fpdefs, i );
        if not IsBool(j) then 
            Q.imgs[i] := Q.pcgens[j];
        else
            w := -StructuralCopy(H[i]); w[i] := 0;
            if w <> 0 * w then
                Q.imgs[i] := MappedVector( w{Q.fpdefs}, Q.pcgens );
            fi;
        fi;
    od;

    Info( InfoIPCQ, 1, "init step yields orders : ", Q.steps[1] );

    # do a check if required
    if CHECKIPCQ and not CheckQSystem(Q) then Error("wrong init"); fi;

    # return 
    return Q;
end );

