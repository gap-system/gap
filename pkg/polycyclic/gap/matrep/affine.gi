
AdjustPresentation := function( G )
    G := G / TorsionSubgroup(G);
    return PcpGroupBySeries( UpperCentralSeries(G), "snf" );
end;

if not IsBound( FULL ) then FULL := false; fi;

ExtendAffine := function( mats, coc )
    local d, l, r, c;
    d := Length( mats[1] );
    l := Length( mats );
    mats := StructuralCopy( mats );
    coc := List( [1..l], x -> coc{[(x-1)*d+1..x*d]} );
    for r in [1..l] do
        for c in [1..d] do Add( mats[r][c], 0 ); od;
        Add( coc[r], 1 ); Add( mats[r], coc[r] );
    od;
    return mats;
end;

NextStepRepresentation := function( G, i, mats )
    local pcp, N, hom, F, C, cc, rc, co, j, coc, news, d, z;

    Print("starting level ",i,"\n");
    pcp := Pcp(G);
    N := SubgroupByIgs( G, pcp{[i+1..Length(pcp)]} );
    hom := NaturalHomomorphism( G, N );
    F := Image( hom, G );
    Add( mats, mats[1]^0 );

    # determine cohomology
    C := CRRecordByMats( F, mats );
    cc := OneCohomologyCR( C );
    Print("  got cohomology with orders ", cc.factor.rels, "\n");
    
    # choose a cocycle
    rc := List( cc.gcc, Reversed );
    rc := NormalFormIntMat( rc, 2 ).normal;
    rc := Filtered( rc, x -> DepthOfVec(x) <= Length(mats[1]) );
    if Length(rc) = 0 then return false; fi;
    co := Reversed( rc[Length(rc)] );

    for j in [1..Length(cc.factor.prei)] do
        if co = cc.factor.prei[j] then 
            coc := co;
        else
            coc := co + cc.factor.prei[j];
        fi;
        news := ExtendAffine( mats, coc );
        if not IsMatrixRepresentation( F, news ) then 
            Error("no mat rep");
        fi;
        news := NextStepRepresentation( G, i+1, news );
        if not IsBool( news ) then return news; fi;
   od;
   return false;
end;
         
AffineRepresentation := function( G )
    local mats, news;
    mats := [[[1,0],[1,1]]];
    news := NextStepRepresentation( G, 2, mats );
    if IsBool( news ) then return fail; fi;
    if not IsMatrixRepresentation( G, news ) then
        Error("no representation ");
    fi;
    return news;
end;         
