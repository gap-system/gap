# Created by bbtogap.py from J2G1-find1 from the Atlas web page
J2G1find1 := 
function(arg)
    local vars,els,G;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);

    # Black box algorithm to find standard generators of J2
    
    vars.F := 0;
    vars.G := 0;
    vars.H := 0;
    vars.V := 0;
    vars.X := 0;
    repeat    # label SEMISTD
        els[1] := PseudoRandom(G);
        vars.A := Order(els[1]);
        vars.V := vars.V + 1;
        if vars.V > 1000 then
            return fail;  # a timeout
        fi;
        if not(vars.A in [1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 15]) then
            return fail;
        fi;
        if vars.F = 0 then
            if vars.A in [2, 6, 10] then
                vars.B := QuoInt(vars.A,2);
                els[2] := els[1]^vars.B;
                vars.F := 1;
            fi;
        fi;
        if vars.G = 0 then
            if vars.A in [3, 6] then
                vars.C := QuoInt(vars.A,3);
                els[3] := els[1]^vars.C;
                vars.G := 1;
            fi;
        fi;
        
        # As well as finding elements of order 2 and 3 (for the
        # generators), we find a 2A-element. This allows us
        # to prove that the elements we have are in the right classes
        # before starting the random conjugating.
        if vars.H = 0 then
            if vars.A in [4, 8, 12] then
                vars.D := QuoInt(vars.A,2);
                els[4] := els[1]^vars.D;
                vars.H := 1;
            fi;
        fi;
        
        if vars.F = 0 then
            continue;    # was jmp to SEMISTD
        fi;
        if vars.G = 0 then
            continue;    # was jmp to SEMISTD
        fi;
        if vars.H = 0 then
            continue;    # was jmp to SEMISTD
        fi;
        
        els[5] := els[2]*els[4];
        vars.D := Order(els[5]);
        if vars.D in [1, 2, 3, 4, 5] then
            # Probably a 2A element
            vars.F := 0;
            continue;    # was jmp to SEMISTD
        fi;
        
        els[6] := els[3]*els[4];
        vars.E := Order(els[6]);
        if vars.E in [6, 12] then
            # Probably a 3A element
            vars.G := 0;
            continue;    # was jmp to SEMISTD
        fi;
        break;
    until false;
        
    # The elements are definitely in classes 2B and 3B now.
    
    repeat    # label CONJUGATE
        vars.X := vars.X + 1;
        if vars.X > 1000 then
            return fail;  # a timeout
        fi;
        els[7] := PseudoRandom(G);
        els[3] := els[3]^els[7];
        els[8] := els[2]*els[3];
        vars.D := Order(els[8]);
        if not(vars.D in [2, 3, 5, 6, 7, 8, 10, 12, 15]) then
            return fail;
        fi;
        
        if vars.D <> 7 then
            continue;    # was jmp to CONJUGATE
        fi;
        
        els[9] := els[8]*els[3];
        els[10] := els[8]*els[9];
        
        vars.E := Order(els[10]);
        
        if not(vars.E in [10, 12, 15]) then
            return fail;
        fi;
        if vars.E <> 12 then
            continue;    # was jmp to CONJUGATE
        fi;
        break;
    until false;
        
    return els{[2, 3]};
end;

