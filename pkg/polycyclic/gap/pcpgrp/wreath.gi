#############################################################################
##
#W  wreath.gi                 Package Polycyclic                 Bettina Eick
##
##  Computing a wreath product of pcp groups.
##

#############################################################################
##
#F WreathProductPcp( G, H, act )
##
InstallOtherMethod( WreathProduct, true, 
[IsPcpGroup, IsPcpGroup, IsMapping], 0,
        function( G, H, act )
    return WreathProduct( G, H, act, 
                   Maximum( 1, LargestMovedPoint( Image( act ))));
end);

InstallOtherMethod( WreathProduct, true,         
        [IsPcpGroup, IsPcpGroup, IsMapping, IsPosInt], 0,
function( G, H, act, l )
    local pcpG, relG, pcpH, relH, n, m, coll, i, k, c, e, o, j, W, a, h,
          ShiftedObject;
    
#############################################################################
##
#F ShiftedObject( exp, shift )
##
    ShiftedObject := function( exp, c )
        local obj, i;
        obj := [];
        for i in [1..Length(exp)] do
            if exp[i] <> 0 then Append( obj, [c+i, exp[i]] ); fi;
        od;
        return obj;
    end;
    
    pcpG := Pcp(G);
    relG := RelativeOrdersOfPcp( pcpG );
    pcpH := Pcp(H);
    relH := RelativeOrdersOfPcp( pcpH );
    n := Length( pcpG );
    m := Length( pcpH );

    coll := FromTheLeftCollector( m + n*l );

    # relations of G
    for i in [1..n] do

        if relG[i] > 0 then
            e := ExponentsByPcp( pcpG, pcpG[i]^relG[i] );
            for k in [1..l] do
                c := m + (k-1)*n;
                o := ShiftedObject( e, c );
                SetRelativeOrder( coll, c+i, relG[i] );
                SetPower( coll, c+i, o );
            od;
        fi;

        for j in [1..i-1] do
            e := ExponentsByPcp( pcpG, pcpG[i]^pcpG[j] );
            for k in [1..l] do
                c := m + (k-1)*n;
                o := ShiftedObject( e, c );
                SetConjugate( coll, c+i, c+j, o );
            od;

            e := ExponentsByPcp( pcpG, pcpG[i]^(pcpG[j]^-1) );
            for k in [1..l] do
                c := m + (k-1)*n;
                o := ShiftedObject( e, c );
                SetConjugate( coll, c+i, -(c+j), o );
            od;
        od;
    od;

    # relations of H
    for i in [1..m] do

        if relH[i] > 0 then
            e := ExponentsByPcp( pcpH, pcpH[i]^relH[i] );
            o := ShiftedObject( e, 0 );
            SetRelativeOrder( coll, i, relH[i] );
            SetPower( coll, i, o );
        fi;

        for j in [1..i-1] do

            e := ExponentsByPcp( pcpH, pcpH[i]^pcpH[j] );
            o := ShiftedObject( e, 0 );
            SetConjugate( coll, i, j, o );

            e := ExponentsByPcp( pcpH, pcpH[i]^(pcpH[j]^-1) );
            o := ShiftedObject( e, 0 );
            SetConjugate( coll, i, -j, o );

        od;
    od;

    # action of H
    for j in [1..m] do
        a := Image( act, pcpH[j] );
        for k in [1..l] do
            h := k^a;
            for i in [1..n] do
                o := [m + (h-1)*n + i, 1];
                SetConjugate( coll, m + (k-1)*n + i, j, o );
            od;
            h := k^(a^-1);
            for i in [1..n] do
                o := [m + (h-1)*n + i, 1];
                SetConjugate( coll, m + (k-1)*n + i, -j, o );
            od;
        od;
    od;

    UpdatePolycyclicCollector( coll );
    W := PcpGroupByCollectorNC( coll );

    SetWreathProductInfo( W, rec(l := l, m := m, n := n,
        G := G, pcpG := pcpG, genG := GeneratorsOfGroup(G),
        H := H, pcpH := pcpH, genH := GeneratorsOfGroup(H),
        coll := coll,
        embeddings := []) );
    return W;
end );

InstallMethod(Embedding,"pcp wreath product",
        [IsPcpGroup and HasWreathProductInfo, IsPosInt],
        function(W,i)
    local info, FilledIn;
    
    FilledIn := function( exp, shift, len )
        local s;
        s := List([1..len], i->0);
        s{shift+[1..Length(exp)]} := exp;
        return s;
    end;
      
    info := WreathProductInfo(W);
    if not IsBound(info.embeddings[i]) then
        if i<=info.l then
            info.embeddings[i] := GroupHomomorphismByImagesNC(info.G,W,
                info.genG, List(info.genG, x->PcpElementByExponents(info.coll,
                    FilledIn(ExponentsByPcp(info.pcpG,x),info.m+(i-1)*info.n,info.m+info.l*info.n))));
        elif i=info.l+1 then
            info.embeddings[i] := GroupHomomorphismByImagesNC(info.H,W,
                info.genH, List(info.genH, x->PcpElementByExponents(info.coll,
                    FilledIn(ExponentsByPcp(info.pcpH,x),0,info.m+info.l*info.n))));
        else
            return fail;
        fi;
        SetIsInjective(info.embeddings[i],true);
    fi;
    return info.embeddings[i];
end);
