#############################################################################
##
#F BlockCanonicalForm( G, U )
##
BlockCanonicalForm := function( G, U )
    local F, C, P, Q, V, W, orbit, trans, ptran, trivl, nonst, stabl, pstab,
          i, j, k, g, o, s, t, p, a;

    # set up
    F := G.field;
    o := G.one[2];
    p := Characteristic(F);

    # precompute canonical form 
    C := SubspaceCanonicalForm( G.agAutos, G.one, U, F );

    # set up orbit and transversal 
    orbit := [ C.cano ];
    trans := [ G.one ];
    ptran := [ () ]; 

    # catch a trivial case
    if G.glOrder = 1 then 
        a := Length(G.agAutos)-Length(C.stab);
        Print("   got p-orbit ",p,"^",a," and gl-orbit ",1,"\n");
        G.glAutos := [];
        G.glOrder := 1;
        G.glPerms := [];
        G.agAutos := C.stab;
        G.size    := p^Length(G.agAutos);
        return rec( cano := C.cano, tran := C.tran );
    fi;

    # set up stabilizer
    stabl := [];
    pstab := [];
    P := Group( () );

    # loop
    k := 1;
    while k <= Length( orbit ) do
        for i in [1..Length(G.glAutos)] do

            # compute image 
            V := MyBaseMat( orbit[k] * G.glAutos[i][2] );
            W := SubspaceCanonicalForm( G.agAutos, G.one, V, F );
            j := Position( orbit, W.cano );

            # add to orbit or stabilizer
            if IsBool( j ) then
                Add( orbit, W.cano );
                Add( trans, trans[k] * G.glAutos[i] * W.tran );
                Add( ptran, ptran[k] * G.glPerms[i] );
            else
                g := ptran[k] * G.glPerms[i] * ptran[j]^-1;
                Q := ClosureGroup(P,g);
                if Size(Q) > Size(P) then 
                    Add( stabl, trans[k]*G.glAutos[i]*W.tran*trans[j]^-1 );
                    Add( pstab, g );
                    P := Q;
                fi;
            fi;

            # pull out if orbit gets too long
            if Length(orbit) > MIP_GLLIMIT then 
                return Length(orbit); 
            fi;

            # if this is it
            if Size(P) * Length(orbit) = G.glOrder then 

                # find cano form
                j := Position( orbit, Minimum( orbit ) );
                t := trans[j];
                s := trans[j]^-1;

                # report
                a := Length(G.agAutos)-Length(C.stab);
                Print("   got p-orbit ",p,"^",a);
                Print(" and gl-orbit ",Length(orbit),"\n");
 
                # adjust G in place
                G.glAutos := List( stabl, x -> s * x * t );
                G.glOrder := Size(P);
                G.glPerms := pstab;
                G.agAutos := List( C.stab, x -> s * x * t );
                G.size    := G.glOrder * p^Length(G.agAutos);
                
                # return canonical form and transversal element
                return rec( cano := orbit[j], tran := C.tran * trans[j] );
            fi;
        od;
        k := k + 1;
    od;

    Error("block cano form yields no result");
end;

#############################################################################
##
#F BlockCanonicalFormBySeries( G, U, ser )
##
BlockCanonicalFormBySeries := function(G, U, ser)
    local pt, tv, i, k, j, S, W, T, h, m, cf;

    # set up for loop
    pt := U;
    tv := G.one;

    # loop
    for i in [1..Length(ser)-1] do
        for k in [i+1..Length(ser)] do

            # get layer
            S := SumIntersectionMat(SumMat(pt,ser[k-1]),ser[k-i])[2];
            W := SumIntersectionMat(SumMat(pt,ser[k]),ser[k-i])[2];
            T := SumIntersectionMat(SumMat(pt,ser[k]),ser[k-i+1])[2];

            if Length(T) < Length(W) and Length(W) < Length(S) then

                # get factor
                S := VectorSpace( G.field, S, "basis" );
                T := SubspaceNC( S, T, "basis" );
                h := NaturalHomomorphismBySubspaceOntoFullRowSpace( S, T );

                # get point
                W := MyBaseMat(List(W, x -> Image( h, x )));

                # add action on layer
                for j in [1..Length(G.glAutos)] do
                    m := IndMatrix( h, G.glAutos[j][2] );
                    G.glAutos[j] := Tuple([G.glAutos[j], m]);
                od;
                for j in [1..Length(G.agAutos)] do
                    m := IndMatrix( h, G.agAutos[j][2] );
                    G.agAutos[j] := Tuple([G.agAutos[j], m]);
                od;
                G.one := Tuple( [G.one, IndMatrix(h, G.one[2])]);

                # stabilize in layer
                cf := BlockCanonicalForm( G, W );
                if IsInt(cf) then return cf; fi;

                # adjust canonical form
                tv := tv * cf.tran[1];
                pt := MyBaseMat( U * tv[2] );

                # cut off action on layer
                for j in [1..Length(G.glAutos)] do
                    G.glAutos[j] := G.glAutos[j][1];
                od;
                for j in [1..Length(G.agAutos)] do
                    G.agAutos[j] := G.agAutos[j][1];
                od;
                G.one := G.one[1];
            fi;
        od;
    od;

    # return canonical form
    return rec( cano := pt, tran := tv );
end;

#############################################################################
##
#F HybridMatrixCanoForm( G, U )
##
HybridMatrixCanoForm := function( G, U )
    local b, c, i, W, V, C, B, g, s;

    # some trivial cases
    if Length(U) = 0 or Length(U) = Length(U[1]) then 
        return rec( cf := U, tv := G.one, ti := G.one );
    fi;

    # get suitable basis
    B := BasisSocleSeries(G);
    b := B.basis;
    c := b^-1;

    # adjust action in 2. component
    for i in [1..Length(G.glAutos)] do
        G.glAutos[i] := Tuple([G.glAutos[i][1], b*G.glAutos[i][2]*c]);
    od;
    for i in [1..Length(G.agAutos)] do
        G.agAutos[i] := Tuple([G.agAutos[i][1], b*G.agAutos[i][2]*c]);
    od;

    # adjust point
    W := MyBaseMat( U*c );

    # compute stabilizer
    if (Length(G.agAutos) = 0 and G.glOrder > MIP_GLLIMIT) or USE_MSERS then 
        s := SeriesByWeights( B.weights, G.field );
        V := BlockCanonicalFormBySeries( G, W, s );
    else
        V := BlockCanonicalForm( G, W );
    fi;
    if IsInt(V) then return V; fi;

    # set up result - translate to old basis
    C := rec();
    C.cf := MyBaseMat( V.cano*b );
    C.tv := Tuple([V.tran[1], c*V.tran[2]*b]);
    C.ti := C.tv^-1;

    # check if required
    if CHECK_STB then 
        for g in G.glAutos do
            if not IsInvariant(C.cf, [c*g[2]*b]) then Error("no gl-stab"); fi;
        od;
        for g in G.agAutos do
            if not IsInvariant(C.cf, [c*g[2]*b]) then Error("no ag-stab"); fi;
        od;
        if not MyBaseMat(U*C.tv[2]) = C.cf then Error("no trans"); fi;
    fi;

    # return canonical form 
    return C;
end;

