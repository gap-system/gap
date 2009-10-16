
InitCanoForm := function( A )
    local F, B, w, d, G, R;

    # set up
    F := LeftActingDomain(A);
    B := CoeffsPowerBasis(A);
    w := B.weights;
    d := Length( Filtered( w, x -> x = 1 ) );
    Print("Layer ",1," of dimension ",d,"\n");

    # adjust global variable
    if d = 2 and Size(F) <= 4 then 
        USE_PARTI := false; 
    else
        USE_PARTI := true;
    fi;

    # init aut group
    G := InitAutomGroup( A );

    # init cano form
    R := rec( tab := List( [1..d], x -> NullMat(d,d,F) ),
              dfR := List( [1..d], x -> 0 ),
              iso := G.basis,
              wgR := w{[1..d]} );

    # add info and return
    G.cano := R;
    return G;
end;

ExtendCanoForm := function( A, G, i )
    local F, B, T, w, d, R, C, S, U, W, Q;

    # catch some arguments from  A
    F := LeftActingDomain(A);
    B := CoeffsPowerBasis(A);
    T := TablePowerBasis(A);
    w := B.weights;
    d := Length( Filtered( w, x -> x <= i ) );
    Print("Layer ",i," of dimension ",d,"\n");

    # catch some arguments from G
    R := G.cano;

    # compute cover of T
    S := T{[1..d]}{[1..d]}{[1..d]};
    C := CoveringTable( R );
    AddDefsAndIsom( C, R, S );
    U := AllowableSubspace( C );

    # report status
    Print("   got dim(M) = ",Length(C.mul),
                " dim(N) = ",C.nuc,
                " dim(U) = ",Length(U),"\n");  

    # lift autos
    InduceAutosToMult( G, C, R );

    # stabilize
    W := HybridMatrixCanoForm( G, U );
    if IsInt(W) then return W; fi;

    # extend quotient
    Q := QuotientTable( C, R, W, w{[1..d]} );
    AddIsomQuotientTable( Q, S, C, W );

    # induce autos
    InduceAutosToQuot( G, Q );

    # report
    Print("   got group of size ",G.glOrder," * ");
    Print(Characteristic(G.field),"^",Length(G.agAutos),"\n");   

    # add info and return
    G.cano := Q;
    return G; 
end;

#############################################################################
##
#F CheckBins/CheckBin . . . . . . . . . . . . . . . . . . .use canonical form
##
FilterBins := function( p, n, d, bins )
    return Filtered(bins, x -> RankPGroup(SmallGroup(p^n,x[1]))=d);
end;

CheckBin := function(p, n, bin)
    local grps, algs, w, d, l, m, cano, i, j;

    # set up
    grps := List(bin, x -> SmallGroup(p^n, x));
    algs := List(grps, x -> GroupRing(GF(p),x));

    # check
    w := Set(List( algs, x -> CoeffsPowerBasis(x).weights ));
    if Length(w) > 1 then Error("different weights in CheckBin"); fi;
    w := w[1];
  
    # get some parameters
    d := Length(w);
    l := w[d];
    m := Length(grps);

    # start up
    cano := List( algs, x -> InitCanoForm(x) );
    if USE_PARTI and Length(Set(List(cano, x -> x.partition))) = m then 
        return [1, l, Length(cano[1].cano.tab)]; 
    fi;

    # loop over weights
    for i in [2..l] do
        for j in [1..m] do
            cano[j] := ExtendCanoForm( algs[j], cano[j], i );
            if IsInt(cano[j]) then return cano[j]; fi;
        od;
        if Length(Set(List(cano, x -> x.cano))) = m then 
            return [i, l, Length(cano[1].cano.tab)]; 
        fi;
    od;

    return rec( cano := List( cano, x -> x.cano ),
                auts := List( cano, x -> x.size ) );
end;

CheckBins := function(p, n, bins, file)
    local res, bin, chk, rem, iso;
    if not IsBool(file) then PrintTo(file," start bins \n"); fi;
    rem := [];
    iso := [];
    for bin in bins do
        chk := CheckBin(p,n,bin);
        if not IsBool(file) and IsList(chk) and Length(chk) = 3 then 
            AppendTo(file, " bin ",bin," splitted at layer ",chk[1]);
            AppendTo(file, " of ",chk[2]," with dim ",chk[3],"\n");
        elif not IsBool(file) and IsInt(chk) then 
            AppendTo(file, " bin ",bin," not splitted as ");
            AppendTo(file, " gl-orbit of length ",chk," too long \n");
            Add( rem, bin );
        elif not IsBool(file) and IsRecord(chk) then 
            AppendTo(file, " bin ",bin," yields isom \n");
            Add( iso, bin );
        fi;
    od;
    if not IsBool(file) then 
        AppendTo(file,"\n");
        AppendTo(file, "iso: ",iso,"\n");
        AppendTo(file, "rem: ",rem,"\n");
    fi;
end;


