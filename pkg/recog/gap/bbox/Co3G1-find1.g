# Created by bbtogap.py from Co3G1-find1 from the Atlas web page
Co3G1find1 := 
function(arg)
    local vars,els,G;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);

    # Black box algorithm to find standard generators of Co3
    
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
        if not(vars.A in [1,2,3,4,5,6,7,8,9,10,11,12,14,15,18,20,21,22,
                          23,24,30]) then
            return fail;
        fi;
        
        if vars.F = 0 then
            if vars.A in [9,18,24,30] then
                vars.B := QuoInt(vars.A,3);
                els[2] := els[1]^vars.B;
                vars.F := 1;
            fi;
        fi;
        if vars.G = 0 then
            if vars.A = 20 then
                els[3] := els[1]^5;
                vars.G := 1;
            fi;
        fi;
        
        if vars.F = 0 then
            continue;    # was jmp to SEMISTD
        fi;
        if vars.G = 0 then
            continue;    # was jmp to SEMISTD
        fi;
        break;
    until false;
        
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
        if not(vars.D in [4,5,6,7,8,9,10,11,12,14,15,18,20,22,23,24]) then
            return fail;
        fi;
        if vars.D <> 14 then
            continue;    # was jmp to CONJUGATE
        fi;
        break;
    until false;
        
    return els{[2, 3]};
end;

