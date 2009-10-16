#############################################################################
##
#W  Autom.gi                FGA package                    Christian Sievers
##
##  Methods to create and compute with inverse automata
##
#H  @(#)$Id: Autom.gi,v 1.4 2003/09/17 16:14:34 gap Exp $
##
#Y  2003
##
Revision.("fga/lib/Autom_gi") :=
    "@(#)$Id: Autom.gi,v 1.4 2003/09/17 16:14:34 gap Exp $";


DeclareRepresentation( "IsSimpleInvAutomatonRep", 
    IsComponentObjectRep and IsInvAutomatonCategory and
      IsAttributeStoringRep and IsCollection,
#    [ "initial", "terminal", "states", "group" ] );
    [ "states", "group" ] );

InstallMethod( TrivialInvAutomaton,
    [ IsFreeGroup ],
    function(G)
    local state;
    state := FGA_newstate();
    return Objectify( NewType( FamilyObj( G ),
                               IsSimpleInvAutomatonRep and IsMutable),
                      rec(initial:=state, terminal:=state, group:=G) );
    end );

InstallMethod( InvAutomatonInsertGenerator,
    IsCollsElms,
    [ IsSimpleInvAutomatonRep and IsMutable, IsElementOfFreeGroup ],
    function(A,gen)
        FGA_AutomInsertGeneratorLetterRep( A, LetterRepAssocWord( gen ) );
    end );

InstallMethod( \in,
    "for a simple inverse automaton",
    IsElmsColls,
    [ IsElementOfFreeGroup, IsSimpleInvAutomatonRep ],
    function(g,A)
        return IsIdenticalObj(FGA_deltas( A!.initial,
                                          LetterRepAssocWord(g)),
                              A!.terminal);
    end );

InstallMethod( PrintObj,
   [ IsSimpleInvAutomatonRep ],
   function(A)
       Print("<simple inverse automaton representation>");
   end );

InstallMethod( AsGroup,
    "for a simple inverse Automaton",
    [ IsSimpleInvAutomatonRep ],
    function(A)
    local G;

    if IsMutable(A) then
        TryNextMethod();
    fi;

    G := rec ();
    ObjectifyWithAttributes( G,
        NewType( FamilyObj( A ),
                 IsFreeGroup and IsAttributeStoringRep and
                     HasOneImmutable and HasFreeGroupAutomaton ),
        OneImmutable, One( A!.group ),
        FreeGroupAutomaton, A );
    return G;
    end );

InstallGlobalFunction( FGA_newstate,
    function()
    return (rec (delta:=[], deltainv:=[]));
    end );

InstallGlobalFunction( FGA_connectpos,
    function(s1, s2, g)
    s1.delta[g] := s2;
    s2.deltainv[g] := s1;
    end );

InstallGlobalFunction( FGA_connect,
    function(s1, s2, g)
    if g>0 then
        FGA_connectpos(s1, s2, g);
    else
        FGA_connectpos(s2, s1, -g);
    fi;
    end );


InstallGlobalFunction( FGA_define,
    function(state, gen)
    local nstate;
    nstate := FGA_newstate();
    FGA_connect(state, nstate, gen);
    return nstate;  # !!!
    end );

# "active"
InstallGlobalFunction( FGA_find,
    function(s)
    while IsBound(s.isnow) do
        s := s.isnow;
    od;
    return s;
# todo: path compression
    end );

InstallGlobalFunction( FGA_merge,
    function(s1, s2, Q)
    s1 := FGA_find(s1);
    s2 := FGA_find(s2);
    if IsNotIdenticalObj(s1,s2) then
        s2.isnow := s1;
        Add(Q,s2);
    fi;
    end );

InstallGlobalFunction( FGA_coincidence,
    function(s1,s2)
    local Q, s, g, s0, s01, delta, deltainv;
    Q := [];
    FGA_merge(s1, s2, Q);
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
            s0 := FGA_find(s);
            s01 := FGA_find(delta[g]);
            if IsBound(s0.delta[g]) then
                FGA_merge(s01, s0.delta[g], Q);
            elif IsBound(s01.deltainv[g]) then
                FGA_merge(s0, s01.deltainv[g], Q);
            else
                FGA_connectpos(s0, s01, g);
            fi;
        od;
        for g in BoundPositions(deltainv) do
            s0 := FGA_find(s);
            s01 := FGA_find(deltainv[g]);
            if IsBound(s0.deltainv[g]) then
                FGA_merge(s01, s0.deltainv[g], Q);
            elif IsBound(s01.delta[g]) then
                FGA_merge(s0, s01.delta[g], Q);
            else
                FGA_connectpos(s01, s0, g);
            fi;
        od;
    od;
    end );


InstallGlobalFunction( FGA_delta,
    function(state, gen)
    if gen>0 then
        return ATf(state.delta, gen);
    else
        return ATf(state.deltainv, -gen);
    fi;
    end );

InstallGlobalFunction( FGA_deltas,
    function(state, genlist)
    return IteratedF(genlist, FGA_delta, state);
    end );

InstallGlobalFunction( FGA_TmpState,
    function(state, genlist)
    local undo, oldstate, i;
    i := 1;
    while state <> fail and i <= Size(genlist) do
       oldstate := state;
       state := FGA_delta( oldstate, genlist[i] );
       i := i+1;
    od;
    if state = fail then
       i := i-1;
       if genlist[i] > 0 then
           undo := function() Unbind(oldstate.delta[genlist[i]]); end;
       else
           undo := function() Unbind(oldstate.deltainv[-genlist[i]]); end;
       fi;
       state := Iterated( genlist{[i..Size(genlist)]}, FGA_define, oldstate );
    else
       undo := ReturnTrue;
    fi;
    return rec( state:=state, undo:=undo);
    end );

InstallGlobalFunction( FGA_trace,
    function(s,w)
    local i, s1;
    s1 := s;
    i := 1;
    while i <= Length(w) and s1 <> fail do
        s := s1;
        s1 := FGA_delta(s, w[i]);
        i := i+1;
    od;
    if s1 = fail then
        return rec(state:=s, index:=i-1);
    else
        return rec(state:=s1, index:=i);
    fi;
    end );

InstallGlobalFunction( FGA_backtrace,
    function(s,w,j)
    local i, s1;
    s1 := s;
    i := Length(w);
    while i >= j and s1 <> fail do
        s := s1;
        s1 := FGA_delta(s, -w[i]);
        i := i-1;
    od;
    if s1 = fail then
        return rec(state:=s, index:=i+1);
    else
        return rec(state:=s1, index:=i);
    fi;
    end );

InstallGlobalFunction( FGA_InsertGenerator,
    function(s, gen)
    return FGA_InsertGeneratorLetterRep(s, LetterRepAssocWord(gen));
    end );

InstallGlobalFunction( FGA_AutomInsertGeneratorLetterRep,
    function(A, w)
    A!.initial := FGA_InsertGeneratorLetterRep( A!.initial, w);
    A!.terminal := A!.initial;
    end );

InstallGlobalFunction( FGA_InsertGeneratorLetterRep,
    function(s, w)
    local i, t, bt, s1, s2;
    t := FGA_trace(s, w);
    bt := FGA_backtrace(s, w, t.index);
    s1 := t.state;
    s2 := bt.state;
    if t.index > bt.index then  # trace complete
        FGA_coincidence(s1, s2);
    else
        if IsIdenticalObj(s1, s2) then
            while w[t.index] = -w[bt.index] do
                s1 := FGA_define(s1, w[t.index]);
                t.index  := t.index  + 1;
                bt.index := bt.index - 1;
            od;
            s2 := s1;
        fi;
        for i in [t.index .. bt.index-1] do
            s1 := FGA_define(s1, w[i]);
        od;
        FGA_connect(s1, s2, w[bt.index]);
    fi;
    return FGA_find(s);
    end );

InstallGlobalFunction( FGA_FromGroupWithGenerators,
#    gens -> Iterated(gens, FGA_InsertGenerator, FGA_newstate()) );
    function(G)
    local s;
    s := Iterated(GeneratorsOfGroup(G), FGA_InsertGenerator, FGA_newstate());
    return Objectify( NewType( FamilyObj( G ),IsSimpleInvAutomatonRep),
                      rec(initial:=s, terminal:=s, group:=G) );
    end );

InstallGlobalFunction( FGA_FromGeneratorsLetterRep,
    function(gens,G)
    local s;
    s := Iterated(gens, FGA_InsertGeneratorLetterRep, FGA_newstate());
    return Objectify( NewType( FamilyObj( G ),
                      IsSimpleInvAutomatonRep and IsMutable),
                      rec(initial:=s, terminal:=s, group:=G) );
    end );

   
InstallGlobalFunction( FGA_Check,
    function(s, w)
    return IsIdenticalObj(FGA_deltas(s, w), s);
   end );

InstallGlobalFunction( FGA_FindGeneratorsAndStates,
    function(A)
    local Q, Gens, nq, q, i, nr, freegens;
    q := A!.initial;
    nr := 0;
    Gens := [];
    q.repr := [];
    Q := [q];
    for nq in Q do
        freegens := [];
        nr := nr + 1;
        nq.nr := nr;
        for i in BoundPositions(nq.delta) do
            q := nq.delta[i];
            if IsBound(q.repr) then
                if nq.repr = [] or nq.repr[Length(nq.repr)] <> -i then
                    Add(Gens, Concatenation(nq.repr, [i], -Reversed(q.repr)));
                    freegens[i] := Length(Gens);
                fi;
            else
                q.repr := ShallowCopy(nq.repr);
                Add(q.repr, i);
                Add(Q, q);
            fi;
        od;
        for i in BoundPositions(nq.deltainv) do
            q := nq.deltainv[i];
            if not(IsBound(q.repr)) then
                q.repr := ShallowCopy(nq.repr);
                Add(q.repr, -i);
                Add(Q, q);
            fi;
        od;
        if freegens <> [] then
            nq.freegens := freegens;
        fi;
    od;
    ###
    SetFGA_States(A, Q);
    SetFGA_GeneratorsLetterRep(A, Gens);
    end );

InstallGlobalFunction( FGA_initial,
    A -> A!.initial );

InstallGlobalFunction( FGA_repr,
    state -> state.repr );

InstallMethod( FGA_GeneratorsLetterRep,
    "for simple inverse Automata",
    [ IsSimpleInvAutomatonRep ],
    function(A)
    FGA_FindGeneratorsAndStates(A);
    return FGA_GeneratorsLetterRep(A);
    end );

InstallMethod( FGA_States,
    "for simple inverse Automata",
    [ IsSimpleInvAutomatonRep ],
    function(A)
    FGA_FindGeneratorsAndStates(A);
    return FGA_States(A);
    end );
 
InstallGlobalFunction( FGA_reducedPos,
    function(A)
    local i, states, n;
    i := 0;
    states := FGA_States(A);
    repeat
        i := i+1;
        n := Size(BoundPositions(states[i].delta)) +
             Size(BoundPositions(states[i].deltainv));
    until n > 2 or ( n=2 and i=1);
    return i;
    end );

InstallGlobalFunction( FGA_Index,
    function(A)
    local states, r;
    states := FGA_States(A);
    r := Size(FreeGeneratorsOfWholeGroup(A!.group));
    if ForAny( List( states, s -> s.delta),
               delta -> not IsDenseList(delta) or Size(delta) <> r ) then
        return infinity;
    fi;
    return Size(states);
    end );

InstallGlobalFunction( FGA_AsWordLetterRepInFreeGenerators,
    function(g,A)
    local s,x,f,w;
    FGA_States(A); # do work in the automaton if needed
    w := [];
    s := A!.initial;
    for x in g do
        if x > 0 then
            if IsBound(s.freegens) and IsBound(s.freegens[x]) then
                Add(w, s.freegens[x]);
            fi;
            s := ATf(s.delta, x);
            if s = fail then
                return fail;
            fi;
        else
            s := ATf(s.deltainv, -x);
            if s=fail then
                return fail;
            fi;
            if IsBound(s.freegens) and IsBound(s.freegens[-x]) then
                Add(w, -s.freegens[-x]);
            fi;
        fi;
    od;

    if IsNotIdenticalObj( s, A!.terminal ) then
        return fail;
    fi;

    return w;
    end );


#############################################################################
##
#E
