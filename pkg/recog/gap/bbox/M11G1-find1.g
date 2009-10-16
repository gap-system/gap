# Created by bbtogap.py from M11G1-find1 from the Atlas page
M11finder :=
function(arg)
    local vars,els,G;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);
    # Black box algorithm to find standard generators
    # of M11
    
    vars.V := 0;
    
    repeat    # label START
        els[1] := PseudoRandom(G);
        vars.A := Order(els[1]);
        vars.V := vars.V + 1;
        if vars.V > 1000 then
            return fail;  # a timeout
        fi;
        if not(vars.A in [1, 2, 3, 4, 5, 6, 8, 11]) then
            return fail;
        fi;
    until vars.A in [4, 8]);

    vars.B := QuoInt(vars.A,2);
    els[2] := els[1]^vars.B;
    
    vars.C := QuoInt(vars.A,4);
    els[3] := els[1]^vars.C;
    
    # The elements 2 and 3 are now in the correct conjugacy classes.
    
    vars.X := 0;
    
    repeat    # label CONJ
        vars.X := vars.X + 1;
        if vars.X > 1000 then
            return fail;  # a timeout
        fi;
        els[4] := PseudoRandom(G);
        els[3] := els[3]^els[4];
        els[5] := els[2]*els[3];
        vars.D := Order(els[5]);
        
        if not(vars.D in [2, 3, 4, 5, 6, 8, 11]) then
            return fail;
        fi;
    until vars.D = 11;
        
    els[6] := els[5]*els[3];
    els[7] := els[6]*els[3];
    els[8] := els[5]*els[6];
    els[9] := els[8]*els[7];
    
    vars.E := Order(els[9]);
    
    if vars.E = 3 then
        els[10] := els[3]^-1;
        els[3] := els[10];
    fi;
    
    return els{[2, 3]};
end;

