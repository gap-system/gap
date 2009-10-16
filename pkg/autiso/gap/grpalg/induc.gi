
InduceAutoToMult := function( C, def, mat )
    local F, n, m, d, z, new, img, i;

    # set up
    F := Field(C.cov[1][1][1]);
    m := Length(C.mul);
    n := Length(C.cov) - m;
    d := Length(Filtered( def, x -> x=0 ));
    z := List([1..m], x -> Zero(F));
    
    # start with new mat on [1..d]
    new := List([1..d], x -> Concatenation(mat[x], z));

    # enlarge to new mat on [d+1..n]
    for i in [d+1..n] do
        new[i] := MultBySC( C.cov, F, new[def[i][1]], new[def[i][2]] );
    od;

    # compute image on M
    img := [];
    for i in [1..m] do
        img[i] := MultBySC( C.cov, F, new[C.def[i][1]], new[C.def[i][2]] );
        if Length(C.def[i]) = 3 then 
            img[i] := img[i] - C.def[i][3] * new; 
        fi;
        if CHECK_AUT and not img[i]{[1..n]} = 0 * img[i]{[1..n]} then
            Error("aut does not induce");
        fi;
        img[i] := img[i]{[n+1..n+m]};
    od;
    img := C.inv * img;

    if CHECK_AUT and RankMat(img) < Length(C.mul) then 
        Error("induced auto is not invertible"); 
    fi;

    ConvertToMatrixRep(img, Size(F));
    return Immutable(img);
end;

InduceAutosToMult := function( G, C, R )
    local i, m;

    C.inv := C.mul^-1;

    for i in [1..Length(G.glAutos)] do
        m := InduceAutoToMult( C, R.dfR, G.glAutos[i] );
        G.glAutos[i] := Tuple( [G.glAutos[i], m] );
    od;

    for i in [1..Length(G.agAutos)] do
        m := InduceAutoToMult( C, R.dfR, G.agAutos[i] );
        G.agAutos[i] := Tuple( [G.agAutos[i], m] );
    od;

    G.one := Tuple( [G.one, C.mul^0] );

end;

AddCentralAutos := function( G, w )
    local s1, n1, s2, n2, new, i, j, mat;

    # catch info
    s1 := 1;
    n1 := Position(w,2)-1;
    s2 := Position(w,Maximum(w));
    n2 := Length(w);
    
    # create autos
    new := [];
    for i in [s1..n1] do
        for j in [s2..n2] do
            mat := StructuralCopy(G.one);
            mat[i][j] := One(G.field);
            ConvertToMatrixRep( mat, Size(G.field) );
            Add( new, Immutable(mat) );
        od;
    od;

    # add to G
    Append( G.agAutos, new );
end;

InduceAutoToQuot := function( R, mat )
    local F, r, n, new, i;

    # set up
    F := Field( R.tab[1][1][1] );
    r := Length( R.wgR );
    n := Length( mat[1] );

    # init
    new := MutableNullMat( r, r, F );

    # loop over defs
    for i in [1..r] do
        if R.dfR[i] = 0 then 
            new[i]{[1..n]} := mat[1][i];
        else
            new[i] := MultBySC(R.tab, F, new[R.dfR[i][1]], new[R.dfR[i][2]]);
        fi;
    od;

    # change to nice rep
    ConvertToMatrixRep( new, Size(F) );
    new := Immutable(new);

    # return
    return new;
end;

InduceAutosToQuot := function( G, R )
    local i;

    # extend gl-autos
    for i in [1..Length(G.glAutos)] do
        G.glAutos[i] := InduceAutoToQuot( R, G.glAutos[i] );
    od;
    
    # extend ag-autos
    for i in [1..Length(G.agAutos)] do
        G.agAutos[i] := InduceAutoToQuot( R, G.agAutos[i] );
    od;

    # add new identity
    G.one  := IdentityMat( Length( R.wgR ), G.field );

    # add central autos
    AddCentralAutos( G, R.wgR );

    # adjust size
    G.size := G.glOrder * Characteristic(G.field)^Length(G.agAutos);
end;

