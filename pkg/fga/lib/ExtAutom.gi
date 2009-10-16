#############################################################################
##
#W  ExtAutom.gi             FGA package                    Christian Sievers
##
##  Methods to create and compute with extended inverse automata
##
#H  @(#)$Id: ExtAutom.gi,v 1.3 2003/08/14 16:00:21 gap Exp $
##
#Y  2003
##
Revision.("fga/lib/ExtAutom_gi") :=
    "@(#)$Id: ExtAutom.gi,v 1.3 2003/08/14 16:00:21 gap Exp $";


InstallValue( FGA_FreeGroupForGenerators, FreeGroup(infinity) );

InstallValue( FGA_One, One(FGA_FreeGroupForGenerators) );

InstallGlobalFunction( FGA_newstateX,
    function()
    return (rec (delta:=[], deltainv:=[], sndsig:=[], sndsiginv:=[]));
    end );

InstallGlobalFunction( FGA_connectposX,
    function(s1, s2, g, sndsig, sndsiginv)
    s1.delta[g] := s2;
    s2.deltainv[g] := s1;
    s1.sndsig[g] := sndsig;
    s2.sndsiginv[g] := sndsiginv;
    end );

InstallGlobalFunction( FGA_connectX,
    function(s1, s2, g, sndsig)
    if g>0 then
        FGA_connectposX(s1, s2, g, sndsig, sndsig^-1);
    else
        FGA_connectposX(s2, s1, -g, sndsig^-1, sndsig);
    fi;
    end );

InstallGlobalFunction( FGA_defineX,
    function(state, gen)
    local nstate;
    nstate := FGA_newstateX();
    FGA_connectX(state, nstate, gen, FGA_One);
    # nstate.W := state.W * gen
    return nstate;
    end );

# active
InstallGlobalFunction( FGA_findX,
    function(s)
    local sndsig;
    sndsig := FGA_One;
    while IsBound(s.isnow) do
        sndsig := sndsig * s.sndcoinc;
        s := s.isnow;
    od;
    return rec(state:=s, sndcoinc:=sndsig);
# todo: path compression
    end );

InstallGlobalFunction( FGA_mergeX,
    function(s1, A, s2, B, Q)
    local s, C;
    s1 := FGA_findX(s1);
    s2 := FGA_findX(s2);

    if IsBound(s2.state.isinitial) then
    # don't mess with the initial state
        s := s1; s1 := s2; s2 := s;
        C := A;   A := B;   B := C;
    fi;

    if IsNotIdenticalObj(s1.state,s2.state) then
        s2.state.isnow := s1.state;
        s2.state.sndcoinc := (B*s2.sndcoinc)^-1*A*s1.sndcoinc;
        Add(Q,s2.state);
    fi;
    end );

InstallGlobalFunction( FGA_coincidenceX,
    function(s1, A, s2, B)
    local Q, s, g, s0, s01, delta, deltainv;
    Q := [];
    FGA_mergeX(s1, A, s2, B, Q);
    for s in Q do
        delta := ShallowCopy(s.delta);
        for g in BoundPositions(delta) do
            Unbind(delta[g].deltainv[g]);
        od;
        deltainv := ShallowCopy(s.deltainv);
        for g in BoundPositions(deltainv) do
            Unbind(deltainv[g].delta[g]);
        od;
        for g in BoundPositions(delta) do
            s0  := FGA_findX(s);
            s01 := FGA_findX(delta[g]);
            if IsBound(s0.state.delta[g]) then
                FGA_mergeX(s01.state, s.sndsig[g]*s01.sndcoinc,
                       s0.state.delta[g], s0.sndcoinc*s0.state.sndsig[g], Q);
            elif IsBound(s01.state.deltainv[g]) then
                FGA_mergeX(s0.state, s.sndsig[g]^-1*s0.sndcoinc,
                          s01.state.deltainv[g],
                          s01.sndcoinc*s01.state.sndsiginv[g], Q);
            else
                FGA_connectX(s0.state, s01.state, g,
                        s0.sndcoinc^-1*s.sndsig[g]*s01.sndcoinc);
            fi;
        od;
        for g in BoundPositions(deltainv) do
            s0  := FGA_findX(s);
            s01 := FGA_findX(deltainv[g]);
            if IsBound(s0.state.deltainv[g]) then
                FGA_mergeX(s01.state, s.sndsiginv[g]*s01.sndcoinc,
                   s0.state.deltainv[g], s0.sndcoinc*s0.state.sndsiginv[g], Q);
            elif IsBound(s01.state.delta[g]) then
                FGA_mergeX(s0.state, s.sndsiginv[g]^-1*s0.sndcoinc,
                  s01.state.delta[g], s01.sndcoinc*s01.state.sndsig[g], Q);
            else
                FGA_connectX(s01.state, s0.state, g,
                     s01.sndcoinc^-1*s.sndsiginv[g]^-1*s0.sndcoinc);
            fi;
        od;
    od;
    end );

InstallGlobalFunction( FGA_atfX,
    function(l, lx, p)
    if IsBound(l[p]) then
        return rec(state:=l[p], sndsig:=lx[p]);
    else
        return fail;
    fi;
    end );

InstallGlobalFunction( FGA_deltaX,
    function(state, gen)
    if gen>0 then
        return FGA_atfX(state.delta, state.sndsig, gen);
    else
        return FGA_atfX(state.deltainv, state.sndsiginv, -gen);
    fi;
    end );

InstallGlobalFunction( FGA_stepX,
    function(r, gen)
    local res;
    res := FGA_deltaX(r.state, gen);
    if res <> fail then 
        res.sndsig := r.sndsig * res.sndsig;
    fi;
    return res;
    end );

InstallGlobalFunction( FGA_deltasX,
    function(state, genlist)
    return IteratedF(genlist, FGA_stepX, rec(state:=state, sndsig:=FGA_One));
    end );

InstallGlobalFunction( FGA_traceX,
    function(s,w)
    local i, s1;
    s := rec(state := s, sndsig := FGA_One);
    s1 := s;
    i := 1;
    while i <= Length(w) and s1 <> fail do
        s := s1;
        s1 := FGA_stepX(s, w[i]);
        i := i+1;
    od;
    if s1 = fail then
        return rec(state:=s.state, index:=i-1, sndsig:=s.sndsig);
    else
        return rec(state:=s1.state, index:=i, sndsig:=s1.sndsig);
    fi;
    end );

InstallGlobalFunction( FGA_backtraceX,
    function(s,w,j)
    local i, s1;
    s := rec(state:=s, sndsig := FGA_One);
    s1 := s;
    i := Length(w);
    while i >= j and s1 <> fail do
        s := s1;
        s1 := FGA_stepX(s, -w[i]);
        i := i-1;
    od;
    if s1 = fail then
        return rec(state:=s.state, index:=i+1, sndsig:=s.sndsig );
    else
        return rec(state:=s1.state, index:=i, sndsig:=s1.sndsig);
    fi;
    end );

InstallGlobalFunction( FGA_insertgeneratorX,
    function(s, g, sndgen)
    local i, t, bt, s1, s2;
    t  := FGA_traceX(s, g);
    bt := FGA_backtraceX(s, g, t.index);
    s1 := t.state;
    s2 := bt.state;
    if t.index > bt.index then  # trace complete
        FGA_coincidenceX(s1, sndgen^-1*t.sndsig, s2, bt.sndsig);
    else
        if IsIdenticalObj(s1, s2) then
            while g[t.index] = -g[bt.index] do
                s1 := FGA_defineX(s1, g[t.index]);
                t.index := t.index+1;
                bt.index := bt.index - 1;
            od;
            s2 := s1;
        fi;
        for i in [t.index .. bt.index-1] do
            s1 := FGA_defineX(s1, g[i]);
        od;
        FGA_connectX(s1, s2, g[bt.index], t.sndsig^-1*sndgen*bt.sndsig);
    fi;
    return FGA_find(s);
    end );

InstallGlobalFunction( FGA_fromgeneratorsX,
    function(gens)
    local gen, i, autom;
    i := 1;
    autom := FGA_newstateX();
    autom.isinitial := true;
    for gen in gens do
        autom := FGA_insertgeneratorX(autom, gen,
                                      FGA_FreeGroupForGenerators.(i) );
        i := i+1;
    od;
    return autom;
    end );

InstallGlobalFunction( FGA_FromGroupWithGeneratorsX,
    function( G )
    return FGA_fromgeneratorsX( List ( GeneratorsOfGroup ( G ),
                                       LetterRepAssocWord ));
    end );

InstallGlobalFunction( FGA_AsWordLetterRepInGenerators,
    function( w, A)
    local res;
    res := FGA_deltasX( A, w );
    if res = fail or IsNotIdenticalObj( res.state, A ) then
        return fail;
    else
        return LetterRepAssocWord( res.sndsig );
    fi;
    end );


#############################################################################
##
#E
