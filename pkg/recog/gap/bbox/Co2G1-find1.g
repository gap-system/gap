# Created by bbtogap.py from Co2G1-find1 from the Atlas web page
Co2G1find1 := 
function(arg)
    local vars,els,G,toSEMISTD;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);

    # Black box algorithm to find standard generators of Co2
    
    vars.F := 0;
    vars.G := 0;
    vars.V := 0;
    vars.X := 0;
    
    repeat    # label SEMISTD
        els[1] := PseudoRandom(G);
        vars.A := Order(els[1]);
        vars.V := vars.V + 1;
        if vars.V > 1000 then
            return fail;  # a timeout
        fi;
        if not(vars.A in [1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,18,20,23,24,
                          28,30]) then
            return fail;
        fi;
        if vars.F = 0 then
            if vars.A in [16,18,28] then
                vars.B := QuoInt(vars.A,2);
                els[2] := els[1]^vars.B;
                vars.F := 1;
            fi;
        fi;
        if vars.G = 0 then
            if vars.A in [15,30] then
                vars.C := QuoInt(vars.A,5);
                els[3] := els[1]^vars.C;
                vars.G := 1;
            fi;
        fi;
        
        if vars.F = 0 then
            continue;    # was jmp to SEMISTD
        fi;
        if vars.G = 0 then
            continue;    # was jmp to SEMISTD
        fi;
        
        vars.Y := 0;
        vars.Z := 0;
        vars.U := 0;
        repeat    # label CONJUGATE
            vars.X := vars.X + 1;
            if vars.X > 1000 then
                return fail;  # a timeout
            fi;
            vars.Y := vars.Y + 1;
            els[4] := PseudoRandom(G);
            els[3] := els[3]^els[4];
            els[5] := els[2]*els[3];
            vars.D := Order(els[5]);
            if not(vars.D in [4,5,6,7,8,9,10,11,12,14,15,16,18,20,23,24,
                              28,30]) then
                return fail;
            fi;
            
            if vars.D = 7 then
                vars.Z := 1;
            fi;
            
            if vars.Z = 0 then
                if vars.Y > 35 then
                    vars.G := 0;
                    toSEMISTD := true;
                    break;    # was jmp to SEMISTD
                fi;
                
                # Certain product orders are much more likely to
                # occur with 5B elements (and vice versa)
                if vars.D in [6,12,14,24,30] then
                    vars.U := vars.U + 1;
                fi;
                if vars.D in [9,11,15,23] then
                    vars.U := vars.U + 1;
                fi;
                
                if vars.U = 3 then
                    # Probably a 5B element.
                    vars.G := 0;
                    toSEMISTD := true;
                    break;    # was jmp to SEMISTD
                fi;
            fi;
            
            if vars.D <> 28 then
                continue;    # was jmp to CONJUGATE
            fi;
            
            # Once we've got y s.t. o(xy) = 28, we need to check
            # o(xyy) = 9 if we don't yet know that y is in the right
            # class.
            if vars.Z = 0 then
                els[6] := els[5]*els[3];
                
                vars.E := Order(els[6]);
                
                if not(vars.E in [9, 15]) then
                    return fail;
                fi;
                if vars.E = 15 then
                    vars.G := 0;
                    toSEMISTD := true;
                    break;    # was jmp to SEMISTD
                fi;
            fi;
            toSEMISTD := false;
            break;
        until false;
        if not(toSEMISTD) then break; fi;
    until false;
            
    return els{[2,3]};
end;

