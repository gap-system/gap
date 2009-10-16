
InstallNonConstructiveRecognizer( function(g)
    local   ds,  g0,  inf,  name;
    if not IsSimpleGroup(g) then
        ds := DerivedSeriesOfGroup(g);
        g0 := ds[Length(ds)];
        if not IsSimpleGroup(g0) then
            g0 := g0/Centre(g0);
            if not IsSimpleGroup(g0) then
                return false;
            fi;
        fi;
    else
        g0 := g;
    fi;
    inf := IsomorphismTypeInfoFiniteSimpleGroup(g0);
    if inf.series = "L" then
        name := Concatenation("L_",String(inf.parameter[1]),"(",String(inf.parameter[2]),")");
    elif inf.series = "2A" then
        name := Concatenation("U_",String(inf.parameter[1]+1),"(",String(inf.parameter[2]),")");
    elif inf.series = "B" then
        name := Concatenation("O_",String(2*inf.parameter[1]+1),"(",String(inf.parameter[2]),")");
    elif inf.series = "2B" then
        name := Concatenation("2B_2(",String(inf.parameter),")");
    elif inf.series = "C" then
        name := Concatenation("S_",String(2*inf.parameter[1]),"(",String(inf.parameter[2]),")");
    elif inf.series = "D" then
        name := Concatenation("O^+_",String(2*inf.parameter[1]),"(",String(inf.parameter[2]),")");
    elif inf.series = "2D" then
        name := Concatenation("O^-_",String(2*inf.parameter[1]),"(",String(inf.parameter[2]),")");
    elif inf.series = "3D" then
        name := Concatenation("3D_4(",String(inf.parameter),")");
    elif inf.series = "E" then
        name := Concatenation("E_",String(inf.parameter[1]),"(",String(inf.parameter[2]),")");
    elif inf.series = "2E" then
        name := Concatenation("2E_6(",String(inf.parameter),")");
    elif inf.series = "F" then
        name := Concatenation("F_4(",String(inf.parameter),")");
    elif inf.series = "2F" then
        name := Concatenation("2F_4(",String(inf.parameter),")");
    elif inf.series = "G" then
        name := Concatenation("G_2(",String(inf.parameter),")");
    elif inf.series = "2G" then
        name := Concatenation("2G_2(",String(inf.parameter),")");
    elif inf.series = "A" then
        name := Concatenation("A_",String(inf.parameter));
    elif inf.series = "Spor"then
        name := inf.name;
    elif inf.series = "Z" then
        Info(InfoRecog+InfoWarning,1,"Seeking name for soluble group");
        return RO_CONTRADICTION;
    else
        Info(InfoRecog+InfoWarning,1,
             "Unrecognized result from IsomorphismTypeInfoFiniteSimpleGroup",
             inf);
        return RO_CONTRADICTION;
    fi;
    Info(InfoRecog,2,"Obtained name ",name," from IsomorphismTypeInfoFiniteSimpleGroup");
    RecognitionInfo(g).Name := name;
    return name;
end,"Call IsomorphismTypeInfoFiniteSimpleGroup");
    
        
InstallFactorizer(function(g,gens,x)
    local   f,  hom,  w,  s;
    f := FreeGroup(Length(gens));
    hom := GroupHomomorphismByImagesNC(f,g,GeneratorsOfGroup(f),gens);
    w := PreImagesRepresentative(hom,x);
    s := StraightLineProgram([ExtRepOfObj(w)]);
    return s;
end,
  "Use homomorphism from the free group");
        
        
    
