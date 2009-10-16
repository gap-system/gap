# Created by bbtogap.py
f := function(arg)
    local vars,els,G;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);

    # Black box algorithm to find standard generators of Ly
    
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
        if not(vars.A in [1,2,3,4,5,6,7,8,9,10,11,12,14,15,
                 18,20,21,22,24,25,28,30,31,33,37,40,42,67]) then
            return fail;
        fi;
        if vars.F = 0 then
            if vars.A in [2,4,6,8,10,12,14,18,20,22,24,28,30,40,42] then
                vars.B := QuoInt(vars.A,2);
                els[2] := els[1]^vars.B;
                vars.F := 1;
            fi;
        fi;
        if vars.G = 0 then
            if vars.A in [20,25,40] then
                vars.C := QuoInt(vars.A,5);
                els[3] := els[1]^vars.C;
                vars.G := 1;
            fi;
        fi;
    until vars.F <> 0 and vars.G <> 0;
        
    vars.X := 0;
    repeat    # label CONJUGATE
        vars.X := vars.X + 1;
        if vars.X > 3000 then
            return fail;  # a timeout
        fi;
        els[4] := PseudoRandom(G);
        els[3] := els[3]^els[4];
        els[5] := els[2]*els[3];
        vars.D := Order(els[5]);
        if not(vars.D in [2,6,7,8,9,10,11,12,14,15,18,20,
                      21,22,24,25,28,30,31,33,37,40,42,67]) then
            return fail;
        fi;
        if vars.D <> 14 then
            continue;    # was jmp to CONJUGATE
        fi;
        
        els[6] := els[5]*els[3];
        els[7] := els[5]*els[5];
        els[8] := els[7]*els[6];
        vars.E := Order(els[8]);
        if vars.E <> 67 then
            continue;    # was jmp to CONJUGATE
        fi;
        break;
    until false;    
    return els{[2,3]};
end;

