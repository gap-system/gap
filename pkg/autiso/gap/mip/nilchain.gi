
SiftInSEB := function( base, vec )
    local new, d;

    # set up
    new := ShallowCopy(vec);

    # sift entries
    d := PositionNonZero(new);
    while d <= Length(base) and not IsBool(base[d]) do
        new := new - new[d] * base[d];
        d := PositionNonZero(new);
    od;

    # add result
    if d <= Length(base) then 
        base[d] := new / new[d]; 
        return base[d];
    else
        return false;
    fi;
end;

EchelonisedSEB := function(base)
    local i, j;
 
    # clear out above diagonal
    for i in [2..Length(base)] do
        if not IsBool(base[i]) then
            for j in [1..i-1] do
                if not IsBool(base[j]) then
                    base[j] := base[j] - base[j][i] * base[i];
                fi;
            od;
        fi;
    od;

    # get rid of redundant entries
    return Filtered( base, x -> not IsBool(x) );
end;

AddGensToIdeal := function( A, gens1, gens2 )
    local B, vecs, base, g, todo, c, b, a;

    # check for trivial ideal
    if Length(gens1)=0 and Length(gens2)=0 then return []; fi;

    # check gens - it consists of vectors or of elements of A
    if Length(gens1) > 0 and gens1[1] in A then
        gens1 := List(gens1, x -> Coefficients( Basis(A), x ));
    fi;
    if Length(gens2) > 0 and gens2[1] in A then
        gens2 := List(gens2, x -> Coefficients( Basis(A), x ));
    fi;

    # set up
    B := Basis(A);

    # sift in generators
    base := List( B, x -> false ); 
    todo := [];

    # just add gens of ideal
    for g in gens2 do 
        SiftInSEB( base, g );
    od;

    # sift in additional gens
    for g in gens1 do
        a := SiftInSEB( base, g );
        if not IsBool(a) and not a in todo then Add( todo, a ); fi;
    od;

    # another simple check
    if ForAll(base, x -> x = false) then return []; fi;

    # close under action of A
    while Length( todo ) > 0 do

        # take one
        c := todo[Length(todo)];
        Unbind(todo[Length(todo)]);

        # close under action of A
        for b in GeneratorsOfAlgebra(A) do
            a := SiftInSEB( base, Coefficients(B, b*(c*B)));
            if not IsBool(a) and not a in todo then Add( todo, a ); fi;
        od;
    od;

    #that's it
    return EchelonisedSEB( base );
end;

AddIdealToIdeal := function( A, base1, base2 )
    local base, tmp, b;

    # swap so that base1 is not smaller than base2
    if Length(base1) < Length(base2) then
        tmp := base2;
        base2 := base1;
        base1 := tmp;
    fi;

    # some simple checks
    if Length(base2) = 0 then return base1; fi;
    if Length(base1) = Length(Basis(A)) then return base1; fi;

    # set up
    base := List( Basis(A), x -> false );

    # sift in base1
    for b in base1 do
        base[PositionNonZero(b)] := b;
    od;

    # sift in base2
    for b in base2 do
        SiftInSEB( base, b );
    od;

    # that's it
    return EchelonisedSEB( base );
end;

SEBByIdeal := function( A, I )
    local gens, base, b;

    # set up
    base := List(Basis(A), x -> false);

    if not IsList(I) then
        gens := List(Basis(I), x -> Coefficients(Basis(A),x));
    else
        gens := I;
    fi;

    # add in elements
    for b in gens do SiftInSEB( base, b ); od;

    # echelonise and return
    return EchelonisedSEB( base );
end;


CoeffBasis := function(A, I)
    if IsBound( I!.coeffbasis ) then return I!.coeffbasis; fi;
    I!.coeffbasis := List(Basis(I), x -> Coefficients(Basis(A), x));
    return I!.coeffbasis;
end;

IdealSum := function( A, I, J )
    local bI, bJ, bK, K;

    # some trivial checks
    if Dimension(I) = 0 then return J; fi;
    if Dimension(I) = Dimension(A) then return I; fi;
    if Dimension(J) = 0 then return I; fi;
    if Dimension(J) = Dimension(A) then return J; fi;

    # otherwise compute
    bI := CoeffBasis(A,I);
    bJ := CoeffBasis(A,J);

    # use matrix arithmetic
    bK := SumMat(bI, bJ);

    # and return ideals
    K := IdealNC( A, bK*Basis(A), "basis" );
    K!.coeffbasis := bK;
    return K;
end;

IdealSumAndInt := function( A, I, J )
    local bI, bJ, b, H, K;

    # some trivial checks
    if Dimension(I) = 0 then 
        return rec( sum := J, int := I );
    elif Dimension(I) = Dimension(A) then 
        return rec( sum := I, int := J );
    fi;
    if Dimension(J) = 0 then 
        return rec( sum := I, int := J );
    elif Dimension(J) = Dimension(A) then 
        return rec( sum := J, int := I );
    fi;

    # otherwise compute
    bI := CoeffBasis(A, I);
    bJ := CoeffBasis(A, J);

    # use matrix arithmetic
    b := SumIntersectionMat(bI, bJ);

    # and return ideals
    if Length(b[1]) > 0 then 
        H := IdealNC( A, b[1]*Basis(A), "basis");
    else
        H := IdealNC( A, [] );
    fi;
    H!.coeffbasis := b[1];
    if Length(b[2]) > 0 then 
        K := IdealNC( A, b[2]*Basis(A), "basis");
    else
        K := IdealNC( A, [] );
    fi;
    K!.coeffbasis := b[2];
    return rec( sum := H, int := K );
end;

RefineSeriesByIdeal := function( A, ser, I )
    local i, J;
    ser := ShallowCopy(ser);
    for i in [1..Length(ser)-1] do
        J := IdealSum( A, I, ser[i+1] );
        if Dimension(J) > Dimension( ser[i+1] ) then 
            J := IdealSumAndInt( A, J, ser[i] ).int;
            if Dimension(J) < Dimension(ser[i]) and
               Dimension(J) > Dimension(ser[i+1]) then
                ser[i] := [ser[i], J];
            fi;
        fi;
    od;
    return Flat(ser);
end;

RefineIdealBySeries := function( A, ser, I )
    local top, bot, i, J;

    # check
    if Dimension(I) = Dimension(A) or Dimension(I) = 0 then return ser; fi;

    # set up
    top := [];
    bot := [];

    # split series
    for i in [1..Length(ser)] do
        J := IdealSumAndInt(A, ser[i], I);
        if i = 1 then 
            Add( top, J.sum );
        elif Dimension(J.sum) < Dimension(top[Length(top)]) then
            Add( top, J.sum );
        fi;
        if i = 1 then 
            Add( bot, J.int );
        elif Dimension(J.int) < Dimension(bot[Length(bot)]) then
            Add( bot, J.int );
        fi;
    od;
    if Dimension(top[Length(top)]) = Dimension(bot[1]) then 
        return Concatenation( top, bot{[2..Length(bot)]} );
    else
        return Concatenation( top, bot );
    fi;
end;

CommutatorOfAlgebra := function( A )
    local G, elms, gens, i, j, x, y, C;
    G := UnderlyingMagma(A);
    elms := AsList(G);
    gens := [];
    for i in [1..Length(elms)] do
        for j in [1..i] do
            x := (elms[i]*elms[j])*One(A);
            y := (elms[j]*elms[i])*One(A);
            AddSet( gens, x-y );
        od;
    od;
    C := LeftIdealNC(A, gens);
    Dimension(C);
    return C;
end;

CommutatorOfIdeal := function( A, I )
    local bI, gens, b, c, C;
    bI := Basis(I);
    gens := [];
    for b in bI do
        for c in bI do
            AddSet( gens, b*c - c*b );
        od;
    od;
    C := LeftIdealNC(A, gens);
    C!.coeffbasis := List(Basis(C), x -> Coefficients(Basis(A),x));
    return C;
end;

CentralizerOfIdeal := function( A, J, I )
    local bA, bI, bJ, gens, b, c, C;
    bI := Basis(I);
    bJ := Basis(J);
    gens := [];
    for b in bI do
        for c in bJ do
            AddSet( gens, b*c );
        od;
    od;
    C := TwoSidedIdealNC(A, gens);
    C!.coeffbasis := List(Basis(C), x -> Coefficients(Basis(A),x));
    return C;
end;

RefineWeightedSeriesByIdeal := function( A, ser, wgs, I, i )
    local J, j;
    ser := ShallowCopy(ser);
    wgs := ShallowCopy(wgs);

    # insert first step
    J := IdealSum( A, I, ser[i+1] );
    if Dimension(J) < Dimension(ser[i]) then 
        if Dimension(J) > Dimension(ser[i+1]) then
            ser[i] := [ser[i], J];
            wgs[i] := [-wgs[i], wgs[i]];
        else
            wgs[i] := -wgs[i];
        fi;
    fi;

    # insert all the rest
    for j in [i+1..Length(ser)-1] do

        # check if we are done
        if IsSubset(I, ser[j]) then
            return rec( ser := Flat(ser), wgs := Flat(wgs) );
        fi;

        # otherwise compute
        J := IdealSum( A, I, ser[j+1] );
        if Dimension(J) > Dimension( ser[j+1] ) then 
            J := IdealSumAndInt( A, J, ser[j] ).int;
            if Dimension(J) < Dimension(ser[j]) and
               Dimension(J) > Dimension(ser[j+1]) then
                ser[j] := [ser[j], J];
                wgs[j] := [wgs[j], wgs[j]];
            fi;
        fi;
    od;
    return rec( ser := Flat(ser), wgs := Flat(wgs) );
end;

SpecialNilChain := function( A )
    local ser, wgs, new, I, i;

    # initiate by augmentation and its powers
    Print("determine augmentation power series \n");
    ser := AugmentationIdealPowerSeries( A );
    wgs := [1..Length(ser)];
    Print(FactorDimensions(ser),"\n");

    # refine series
    i := 1;
    while i < Length(ser) do

        # get ideal
        Print("determine ",i,"th centralizer \n");
        I := CentralizerOfIdeal( A, ser[1], ser[i] );

#        # catch a special case
#        if Dimension(I) = 0 then 
#            wgs{[i..Length(wgs)]} := - wgs{[i..Length(wgs)]}; 
#            return rec( ser := ser, wgs := wgs );
#        fi;

        # add in ideal
        Print("  add centralizer to series \n");
        new := RefineWeightedSeriesByIdeal( A, ser, wgs, I, i );
        ser := new.ser;
        wgs := new.wgs;
        Print("  got factors ",FactorDimensions(ser),"\n");
        Print("  and weights ",wgs,"\n");
    
        # set up for next layer
        i := i+1;
    od;
        
    return rec( ser := ser, wgs := wgs );
end;
    
FactorDimensions := function( ser )
    local res, i;
    res := [];
    for i in [1..Length(ser)-1] do
        res[i] := Dimension(ser[i]) - Dimension(ser[i+1]);
    od;
    return res;
end; 

            
NilChain := function( A, l )
    local ser, new, I, com, i;

    # initiate by augmentation and its powers
    Print("determine augmentation power series \n");
    ser := AugmentationIdealPowerSeries( A );
    Print(FactorDimensions(ser),"\n");
    if l <= 0 then return ser; fi;

    # refine by commutator ideal
    Print("determine commutator \n");
    I := CommutatorOfAlgebra( A );
    Print("  add commutator of dimension ",Dimension(I),"\n");
    ser := RefineIdealBySeries( A, ser, I );
    Print(FactorDimensions(ser),"\n");
    if l = 1 then return ser; fi;

    # refine by further commutators 
    Print("determine and add commutator series \n");
    com := []; com[1] := I; 
    new := ShallowCopy(ser);
    for i in [2..Length(ser)-1] do
        if Dimension(com[i-1]) > 0 then 
            Print("  doing ",i," of ",Length(ser),"\n");
            com[i] := CommutatorOfIdeal(A, ser[i]);
            if Dimension(com[i]) < Dimension(com[i-1]) then 
                new := RefineIdealBySeries( A, new, com[i] );
            fi;
        else
            com[i] := com[i-1];
        fi;
    od;
    ser := new;
    Print(FactorDimensions(ser),"\n");
    if l = 2 then return ser; fi;
 
    # refine by centralizers
    Print("determine and add centralizer series \n");
    com := []; com[1] := I;
    new := ShallowCopy(ser);
    for i in [2..Length(ser)-1] do
        if Dimension(com[i-1]) > 0 then 
            Print("  doing ",i," of ",Length(ser),"\n");
            com[i] := CentralizerOfIdeal(A, ser[i]);
            if Dimension(com[i]) < Dimension(com[i-1]) then 
                new := RefineIdealBySeries( A, new, com[i] );
            fi;
        else
            com[i] := com[i-1];
        fi;
    od;
    ser := new;
    Print(FactorDimensions(ser),"\n");
    if l = 3 then return ser; fi;
 
    return ser;
end;
    
FactorDimensions := function( ser )
    local res, i;
    res := [];
    for i in [1..Length(ser)-1] do
        res[i] := Dimension(ser[i]) - Dimension(ser[i+1]);
    od;
    return res;
end; 

            
