# Created by bbtogap.py from M22G1-find1 from the Atlas web page
M22G1find1 := 
function(arg)
    local vars,els,G;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);

    # Black box algorithm to find standard generators
    # of M22
    
    vars.V := 0;
    
    repeat    # label START
        els[1] := PseudoRandom(G);
        vars.A := Order(els[1]);
        vars.V := vars.V + 1;
        if vars.V > 1000 then
            return fail;  # a timeout
        fi;
        if not(vars.A in [1, 2, 3, 4, 5, 6, 7, 8, 11]) then
            return fail;
        fi;
    until vars.A = 8;

    els[3] := els[1]*els[1];
    els[2] := els[3]*els[3];
    
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
        if not(vars.D in [2, 3, 4, 5, 6, 7, 8, 11]) then
            return fail;
        fi;
        if vars.D <> 11 then
            continue;    # was jmp to CONJ
        fi;
        
        els[6] := els[5]*els[3];
        els[7] := els[5]*els[6];
        vars.E := Order(els[7]);
        
        if vars.E <> 11 then
            continue;    # was jmp to CONJ
        fi;
        break;  # this is a success
    until false;
        
    return els{[2, 3]};
end;

