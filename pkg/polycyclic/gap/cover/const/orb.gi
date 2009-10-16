AgOrbitCover := function( A, pt, act )
    local pcgs, rels, orbit, i, y, j, p, l, s, k, t, h;

    pcgs := A.agAutos;
    rels := A.agOrder;

    # initialise orbit
    orbit := [pt];

    # Start constructing orbit.
    i := Length( pcgs );
    while i >= 1 do
        y := act( pt, pcgs[i] );
        j := Position( orbit, y );
        if IsBool( j ) then
            p := rels[i];
            l := Length( orbit );
            orbit[p*l] := true;
            s := 0;
            for k  in [1 .. p-1]  do
                t := s + l;
                for h  in [1..l]  do
                    orbit[h+t] := act( orbit[h+s], pcgs[i] );
                od;
                s := t;
            od;
        fi;
        i := i-1;
    od;

    return orbit;
end;

HybridOrbitCover := function( A, pt, act )
    local block, orbit, new, k, i, j, y;

    # get block
    block := AgOrbitCover( A, pt, act );
    
    # set up orbit
    orbit := [block];

    # loop
    k := 1;
    while k <= Length( orbit ) do
        for i in [ 1..Length( A.glAutos ) ] do
            y := act( orbit[k][1], A.glAutos[i] );
            j := BlockPosition( orbit, y );
            if IsBool( j ) then
                new := List( orbit[k], x -> act(x, A.glAutos[i]) );
                Add( orbit, new );
            fi;
        od;
        k := k + 1;
        #Print("    OS: sub length ",Length(block)," * ",Length(orbit),"\n");
    od;
    
    return Concatenation( orbit );
end;

MyOrbits := function( A, len, act )
    local todo, reps, i, c, a, o, j;

    Print("  OS: compute orbits \n");

    # set up boolean list of length len
    todo := []; todo[len] := true; for i in [1..len] do todo[i] := true; od;

    # c is the number of entries true, 
    # a+1 is the position of the first true
    c := len; a := 1;

    # set up orbit reps
    reps := [];

    # determine orbits
    while IsInt(a) do

        # store
        Add(reps, a-1);

        # get orbit
        o := HybridOrbitCover( A, a-1, act );

        # cancel in todo-list
        for j in o do
            if j < len then 
                if todo[j+1] = false then Error("orb problem"); fi;
                todo[j+1] := false;
                c := c-1; 
            fi;
        od;

        a := Position(todo, true, a);

        Print("  OS: orbit length ",Length(o), " -- ",c," to go \n");
    od;

    return reps;
end;

