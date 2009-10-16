#############################################################################
##
##  blackbox.gi          recog package                    Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  A collection of find homomorphism methods for black box groups.
##
##  $Id: blackbox.gi,v 1.5 2005/10/15 20:46:34 gap Exp $
##
#############################################################################

BBStdGenFinder := rec();
BBStdGenFinder.HS := 
# Created by bbtogap.py from HSG1-find1 from the ATLAS page
function(arg)
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

# Created by bbtogap.py from M11G1-find1 from the Atlas page
BBStdGenFinder.M11 :=
function(arg)
    local vars,els,G;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);
    # Black box algorithm to find standard generators of M11
    
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
    until vars.A in [4, 8];

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

# Created by bbtogap.py from M12G1-find1 from the Atlas web page
BBStdGenFinder.M12 :=
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

# Created by bbtogap.py from M22G1-find1 from the Atlas web page
BBStdGenFinder.M22 :=
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

# Created by bbtogap.py from J2G1-find1 from the Atlas web page
BBStdGenFinder.J2 :=
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

# Created by bbtogap.py from Co3G1-find1 from the Atlas web page
BBStdGenFinder.Co3 := 
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

# Created by bbtogap.py from Co2G1-find1 from the Atlas web page
BBStdGenFinder.Co2 := 
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

# Created by bbtogap.py
BBStdGenFinder.Ly := 
function(arg)
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

SLPForElementGenSift := function(ri,x)
  local s,y;
  repeat
      y := GeneralizedSift(ri!.siftrec,x^-1,1/100);
  until y[Length(y)] <> fail;
  s := MakeCompleteSLP(ri!.siftrec,y);
  # Do a security check: ==> not necessary, because the gensift does
  # detect a wrong result!
  #if ResultOfStraightLineProgram(s,nicegens(ri)) <> x then
  #    return fail;
  #else
  #fi;
  return s;
end;

InstallGlobalFunction( "SporadicsWorkerGenSift", function(name,size,ri,G)
  local Gm,r,siftrec,stdgens;
  Gm := GeneratorsWithMemory(GeneratorsOfGroup(G));
  repeat
      stdgens := BBStdGenFinder.(name)(Gm);
  until stdgens <> fail;
  Setslptonice(ri,SLPOfElms(stdgens));
  stdgens := StripMemory(stdgens);
  ri!.siftrec := PrepareSiftRecords(PreSift.(name),
                                    GroupWithGenerators(stdgens));
  Setslpforelement(ri,SLPForElementGenSift);
  SetFilterObj(ri,IsLeaf);
  SetSize(ri,size);
  return true;
end);

