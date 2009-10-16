#############################################################################
##
#W  freegens.gi               Polycyclic Pakage                  Bettina Eick
##
##  Compute minimal generating sets for abelian mat groups in various 
##  situations.
##

#############################################################################
##
#F FreeGensByRelationMat( gens, mat ) . . . . . . . . . use smith normal form
##
FreeGensByRelationMat := function( gens, mat )
    local S, H, Q, I, pos, i;

    # first try to simplify mat
    mat := ShallowCopy( mat );
    Sort( mat, function( a, b ) return DepthOfVec(a)<DepthOfVec(b); end);

    # fill up mat
    if Length(mat) < Length(mat[1]) then
        for i in [Length(mat)+1..Length(mat[1])] do
            Add( mat, mat[1] * 0 );
        od;
    fi; 

    # solve it
    S := NormalFormIntMat( mat, 9 );
    H := S.normal;
    Q := S.coltrans;
    I := Q^-1;
    pos := Filtered( [1..Length(gens)], x -> H[x][x] <> 1 );
    return rec( gens := List( pos, x -> MappedVector( I[x], gens ) ),
                rels := List( pos, x -> H[x][x] ),
                imgs := I{pos},
                prei := Q{[1..Length(gens)]}{pos} );
end;

#############################################################################
##
#F FreeGensByRelsAndOrders( gens, mat, ords ) . . . . . additional rel orders
##
FreeGensByRelsAndOrders := function( gens, mat, ords )
    local idm, i;

    # append orders to relation mat
    mat := ShallowCopy( mat );
    idm := IdentityMat( Length(gens) );
    for i in [1..Length(ords)] do
        Add( mat, ords[i] * idm[i] );
    od;

    # return 
    return FreeGensByRelationMat( gens, mat );
end;

#############################################################################
##
#F FreeGensByBasePcgs( pcgs )
##
FreeGensByBasePcgs := function( pcgs )
    local pcss, rels, n, mat, i, e;

    # set up
    pcgs.revs := Reversed( pcgs.pcref );
    pcss := PcSequenceBasePcgs( pcgs );
    rels := RelativeOrdersBasePcgs( pcgs );
    n    := Length( pcss );
    if n = 0 then return rec( gens := [], rels := [] ); fi;

    # get relation matrix
    mat := [];
    for i in [1..n] do
        e := ExponentsByBasePcgs( pcgs, pcss[i]^rels[i] );
        e[i] := e[i] - rels[i];
        Add( mat, e );
    od;

    # return
    return FreeGensByRelationMat( pcss, mat );
end;
