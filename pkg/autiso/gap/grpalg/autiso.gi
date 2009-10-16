
InstallMethod( CanoFormWithAutGroup,
               "for group rings",
               [IsGroupRing],
function( A )
    local F, B, G, R, S, T, C, M, U, W, Q, w, d, l, i, s, n;

    # catch some arguments
    F := LeftActingDomain(A);
    B := CoeffsPowerBasis(A);
    T := TablePowerBasis(A); 
    w := B.weights;
    l := Length(Set(w));
    d := Length( Filtered( w, x -> x = 1 ) );

    # do the first step I/I^2
    Print("layer 1 has dimension ",d,"\n");
    G := InitAutomGroup( A );
    R := rec( tab := List( [1..d], x -> NullMat(d,d,F) ),
              dfR := List( [1..d], x -> 0 ),
              iso := G.basis,
              wgR := w{[1..d]} );
    Unbind(G.basis);

    # loop over other steps I/I^i
    for i in [2..l] do
 
        # catch the layer
        d := Length( Filtered( w, x -> x <= i ) );
        S := T{[1..d]}{[1..d]}{[1..d]};

        # report on current state
        Print("induce to layer ",i," of dim ",d);
        Print(" using aut group of order ",G.glOrder, " * ");
        Print(Characteristic(F),"^",Length(G.agAutos),"\n");

        # compute cover and allowable subspace
        C := CoveringTable( R );
        AddDefsAndIsom( C, R, S );
        if CHECK_COV and not CheckCoverEpimorphism(C, S) then 
            Error("wrong cover-epi");
        fi;
        U := AllowableSubspace( C );

        # report result
        Print("   got dim(M) = ",Length(C.mul), 
                " and dim(U) = ",Length(U),"\n");  

        # lift autos
        InduceAutosToMult( G, C, R );

        # stabilize and pull out at too long orbit
        W := HybridMatrixCanoForm( G, U );
        if IsInt(W) then return fail; fi;

        # extend quotient
        Q := QuotientTable( C, R, W, w{[1..d]} );
        AddIsomQuotientTable( Q, S, C, W );

        # induce autos
        InduceAutosToQuot( G, Q );

        # check
        if CHECK_AUT then 
            if not CheckGroupByTable( G, Q.tab ) then 
                Error("autos wrong");
            elif not CheckIsomByTables( Q.tab, S, Q.iso ) then 
                Error("isom wrong");
            fi;
            Print("   checked \n");
        fi;
        
        # reset
        R := Q;
    od;

    # finally add result to group
    G.cano := Q.tab;
    G.isom := Q.iso;
    G.wgts := w;
    return G; 
end );

CanonicalFormOfGroupRing := function( A )
    return CanoFormWithAutGroup(A).cano;
end;

AutomorphismGroupOfGroupRing := function( A )
    local G, H, i, aut, B, b, c, inv;

    # compute cano form
    G := CanoFormWithAutGroup(A);

    # get base change
    B := CoeffsPowerBasis(A);
    b := Concatenation([Coefficients(Basis(A),One(A))], B.basis);
    c := b^-1;

    # get inverse of isom
    inv := G.isom^-1;

    # set up aut group
    H := rec( glAutos := [], 
              glOrder := G.glOrder,
              agAutos := [],
              size    := G.size,
              one     := G.one,
              field   := G.field );

    # fill in autos
    Print("translate autos \n");
    for i in [1..Length(G.glAutos)] do
        aut := inv * G.glAutos[i] * G.isom;
        aut := MatPlus( aut, G.field );
        aut := b * aut * c;
        H.glAutos[i] := aut;
    od;
    for i in [1..Length(G.agAutos)] do
        aut := inv * G.agAutos[i] * G.isom;
        aut := MatPlus( aut, G.field );
        aut := b * aut * c;
        H.agAutos[i] := aut;
    od;

    # that's it
    return H;
end;



