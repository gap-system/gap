# Created by bbtogap.py
HSfinder := function(arg)
    local vars,els,G;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);

    # Black box algorithm to find standard generators of HS
    
    vars.V := 0;
    repeat    # label SEMISTD
        els[1] := PseudoRandom(G);
        vars.A := Order(els[1]);
        vars.V := vars.V + 1;
        if vars.V > 1000 then
            return fail;  # a timeout
        fi;
        if not(vars.A in [1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 15, 20]) then
            return fail;
        fi;
    until vars.A = 20;

    els[2] := els[1]^10;
    els[3] := els[1]^4;
    
    vars.X := 0;
    repeat    # label CONJUGATE
        vars.X := vars.X + 1;
        if vars.X > 1000 then
            return fail;  # a timeout
        fi;
        els[4] := PseudoRandom(G);
        els[3] := els[3]^els[4];
        els[5] := els[2]*els[3];
        vars.D := Order(els[5]);
        if not(vars.D in [5, 6, 8, 10, 11, 15, 20]) then
            return fail;
        fi;
    until vars.D = 11;
    return els{[2, 3]};
end;

