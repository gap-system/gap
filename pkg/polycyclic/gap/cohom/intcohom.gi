#############################################################################
##
#W  intcohom.gi                  Polycyc                         Bettina Eick
##

#############################################################################
##
## IntKernelCR( A, sys, lat, bat )
##
IntKernelCR := function( A, sys, lat, bat )
    local l, n, d, mat, null;

    # get sizes
    l := Length(sys.base)/sys.dim;
    n := sys.len;
    d := sys.dim;

    # catch two trivial cases
    if n = 0 or l = 0 then return IdentityMat(d*n); fi;

    # transpose and blow up system
    mat := MutableTransposedMat( sys.base );
    Append( mat, DirectSumMat( List( [1..l], x -> lat ) ) ); 

    # compute kernel
    # Print("  solve system ",Length(mat)," by ",Length(mat[1]),"\n");
    null := PcpNullspaceIntMat( mat );

    # cut and add
    null := List( null, x -> x{[1..d*n]} );
    null := Concatenation( null, bat );

    # find basis
    # Print("  reduce system ",Length(null)," by ",Length(null[1]),"\n");
    return BaseIntMat( null );
end;

#############################################################################
##
#F IntTwoCocycleSystemCR( A )
##
IntTwoCocycleSystemCR := function( A )
    local C, n, e, id, l, gn, gp, gi, eq, pairs, i, j, k, w1, w2, d, sys, h;

    # set up system of length d
    n := Length( A.mats );
    e := RelativeOrdersOfPcp( A.factor );
    l := Length( A.enumrels );
    d := A.dim;
    sys := CRSystem( d, l, A.char );
    sys.full := true;

    # check
    if not A.char = 0 then return fail; fi;

    # set up for equations 
    id := IdentityMat(n);
    gn := List( id, x -> rec( word := x, tail := [] ) );

    # precompute (ij) for i > j
    #Print("  precompute \n");
    pairs := List( [1..n], x -> [] );
    for i  in [1..n]  do
        if e[i] > 0 then
            h := rec( word := (e[i] - 1) * id[i], tail := [] );
            pairs[i][i] := CollectedTwoCR( A, h, gn[i] ); 
        fi;
        for j  in [1..i-1]  do
            pairs[i][j] := CollectedTwoCR( A, gn[i], gn[j] );
        od;
    od;

    # consistency 1:  k(ji) = (kj)i
    #Print("  consistency 1 \n");
    for i  in [ n, n-1 .. 1 ]  do
        for j  in [ n, n-1 .. i+1 ]  do
            for k  in [ n, n-1 .. j+1 ]  do
                w1 := CollectedTwoCR( A, gn[k], pairs[j][i] );
                w2 := CollectedTwoCR( A, pairs[k][j], gn[i] );
                if w1.word <> w2.word  then
                    Error( "k(ji) <> (kj)i" );
                else
                    AddEquationsCR( sys, w1.tail, w2.tail, true );
                fi;
            od;
        od;
    od;

    # consistency 2: j^(p-1) (ji) = j^p i
    #Print("  consistency 2 \n");
    for i  in [n,n-1..1]  do
        for j  in [n,n-1..i+1]  do
            if e[j] > 0 then
                h := rec( word := (e[j] - 1) * id[j], tail := [] );
                w1 := CollectedTwoCR( A, h, pairs[j][i]);
                w2 := CollectedTwoCR( A, pairs[j][j], gn[i]);
                if w1.word <> w2.word  then
                    Error( "j^(p-1) (ji) <> j^p i" );
                else
                    AddEquationsCR( sys, w1.tail, w2.tail, true );
                fi;
            fi;
        od;
    od;

    # consistency 3: k (i i^(p-1)) = (ki) i^p-1
    #Print("  consistency 3 \n");
    for i  in [n,n-1..1]  do
        if e[i] > 0 then
            h := rec( word := (e[i] - 1) * id[i], tail := [] );
            l := CollectedTwoCR( A, gn[i], h );
            for k  in [n,n-1..i+1]  do
                w1 := CollectedTwoCR( A, gn[k], l );
                w2 := CollectedTwoCR( A, pairs[k][i], h );
                if w1.word <> w2.word  then
                    Error( "k i^p <> (ki) i^(p-1)" );
                else
                    AddEquationsCR( sys, w1.tail, w2.tail, true );
                fi;
            od;
        fi;
    od;

    # consistency 4: (i i^(p-1)) i = i (i^(p-1) i)
    #Print("  consistency 4 \n");
    for i  in [ n, n-1 .. 1 ]  do
        if e[i] > 0 then
            h := rec( word := (e[i] - 1) * id[i], tail := [] );
            l := CollectedTwoCR( A, gn[i], h );
            w1 := CollectedTwoCR( A, l, gn[i] );
            w2 := CollectedTwoCR( A, gn[i], pairs[i][i] );
            if w1.word <> w2.word  then
                Error( "i i^p-1 <> i^p" );
            else
                AddEquationsCR( sys, w1.tail, w2.tail, true );
            fi;
         fi;
    od;

    # consistency 5: j = (j -i) i   
    #Print("  consistency 5 \n");
    gi := List( id, x -> rec( word := -x, tail := [] ) );
    for i  in [n,n-1..1]  do
        for j  in [n,n-1..i+1]  do
            if e[i] = 0 then
                w1 := CollectedTwoCR( A, gn[j], gi[i] );
                w2 := CollectedTwoCR( A, w1, gn[i] );
                if w2.word <> id[j] then
                    Error( "j <> (j -i) i" );
                else
                    AddEquationsCR( sys, w2.tail, [], true );
                fi;
            fi;
        od;
    od;
            
    # consistency 6: i = -j (j i)   
    #Print("  consistency 6 \n");
    for i  in [n,n-1..1]  do
        for j  in [n,n-1..i+1]  do
            if e[j] = 0 then
                w1 := CollectedTwoCR( A, gi[j], pairs[j][i] );
                if w1.word <> id[i] then
                    Error( "i <> -j (j i)" );
                else
                    AddEquationsCR( sys, w1.tail, [], true );
                fi;
            fi;
        od;
    od;

    # consistency 7: -i = -j (j -i) 
    #Print("  consistency 7 \n");
    for i  in [n,n-1..1]  do
        for j  in [n,n-1..i+1]  do
            if e[i] = 0 and e[j] = 0 then
                w1 := CollectedTwoCR( A, gn[j], gi[i] );
                w1 := CollectedTwoCR( A, gi[j], w1 );
                if w1.word <> -id[i] then
                    Error( "-i <> -j (j -i)" );
                else
                    AddEquationsCR( sys, w1.tail, [], true );
                fi;
            fi;
        od;
    od;

    # add a check ((j ^ i) ^-i ) = j 
    #Print("  consistency 8 \n");
    for i in [1..n] do
        for j in [1..i-1] do
            w1 := CollectedTwoCR( A, gi[j], pairs[i][j] );
            w1 := CollectedTwoCR( A, gn[j], w1 );
            w1 := CollectedTwoCR( A, w1, gi[j] );
            if w1.word <> id[i] then
                Error("in rel check ");
            elif not IsZeroTail( w2.tail ) then 
               # Error("relations bug");
                AddEquationsCR( sys, w1.tail, [], true );
            fi;
        od;
    od;

    # return system
    return sys;
end;

#############################################################################
##
#F TwoCohomologyModCR( A, lat )
##
# FIXME: This function is documented and should be turned into a GlobalFunction
TwoCohomologyModCR := function( A, lat )
    local cb, cc, bat;

    if A.char <> 0 then return fail; fi;
    
    # two cobounds
    cb := TwoCoboundariesCR( A );

    # two cocycle system
    cc := IntTwoCocycleSystemCR( A );
    
    # big lattice
    bat := DirectSumMat( List( [1..cc.len], y -> lat ) );

    # add lattice to cb and cc
    cb := BaseIntMat( Concatenation( cb, bat ) );
    cc := IntKernelCR( A, cc, lat, bat );

    return rec( gcc := cc, gcb := cb, 
                factor := AdditiveFactorPcp( cc, cb, 0 ) );
end;

