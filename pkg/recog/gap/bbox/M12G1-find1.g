# Created by bbtogap.py from M12G1-find1 from the Atlas web page
M12G1find1 := 
function(arg)
    local vars,els,G;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);

    # Black box algorithm to find standard generators of M12
    # (Second listed algorithm)
    
    vars.F := 0;
    vars.G := 0;
    vars.V := 0;
    repeat    # label SEMISTD
        els[1] := PseudoRandom(G);
        vars.A := Order(els[1]);
        vars.V := vars.V + 1;
        if vars.V > 1000 then
            return fail;  # a timeout
        fi;
        if not(vars.A in [1, 2, 3, 4, 5, 6, 8, 10, 11]) then
            return fail;
        fi;
        if vars.F = 0 then
            if vars.A in [4, 8] then
                vars.B := QuoInt(vars.A,2);
                els[2] := els[1]^vars.B;
                vars.F := 1;
            fi;
        fi;
        if vars.G = 0 then
            if vars.A = 10 then
                els[3] := els[1]^5;
                vars.G := 1;
            fi;
        fi;
    until vars.F <> 0 and vars.G <> 0;        
    vars.X := 0;
    repeat    # label ELTORDER3
        vars.X := vars.X + 1;
        if vars.X > 1000 then
            return fail;  # a timeout
        fi;
        els[4] := PseudoRandom(G);
        els[5] := els[3]^els[4];
        els[6] := els[3]*els[5];
        vars.D := Order(els[6]);
        if not(vars.D in [1, 2, 3, 4, 5, 6]) then
            return fail;
        fi;
    until vars.D in [3,6];
    vars.E := QuoInt(vars.D,3);
    els[7] := els[6]^vars.E;
    
    vars.X := 0;
    repeat    # label CONJUGATE
        vars.X := vars.X + 1;
        if vars.X > 1000 then
            return fail;  # a timeout
        fi;
        els[8] := PseudoRandom(G);
        els[7] := els[7]^els[8];
        els[9] := els[2]*els[7];
        vars.F := Order(els[9]);
        
        if not(vars.F in [2, 3, 5, 6, 8, 10, 11]) then
            return fail;
        fi;
    until vars.F = 11;
    return els{[2, 7]};
end;

