#############################################################################
##
#F CollectedTwoCR( A, u, v )
##
InstallGlobalFunction( CollectedTwoCR, function( A, u, v )
    local n, word, tail, rels, wstack, tstack, p, c, l, g, e, mat, s, t, r, i;

    # set up and push u into result
    n    := Length( A.mats );
    word := ShallowCopy( u.word );
    tail := ShallowCopy( u.tail );
    rels := RelativeOrdersOfPcp( A.factor );

    # catch a trivial case
    if v.word = 0 * v.word then
        AddTailVectorsCR( tail, v.tail );
        return rec( word := word, tail := tail );
    fi;

    # create stacks and put v onto stack
    wstack := [WordOfVectorCR( v.word )];
    tstack := [v.tail];
    p := [1];                 
    c := [1];

    # run until stacks are empty
    l := 1;
    while l > 0 do

        # take a generator and its exponent
        g := wstack[l][p[l]][1];
        e := wstack[l][p[l]][2];

        # take operation mat
        if e < 0 then
            mat := A.invs[g];
        else
            mat := A.mats[g];
        fi;

        # push g through module tail
        for i in [1..Length(tail)] do
            if IsBound( tail[i] ) then
                tail[i] := tail[i] * mat;
            fi;
        od;

        # correct the stacks
        c[l] := c[l] + 1;
        if AbsInt(e) < c[l] then                # exponent overflow
            c[l] := 1;
            p[l] := p[l] + 1;
            if Length(wstack[l]) < p[l]  then   # word overflow - add tail
                AddTailVectorsCR( tail, tstack[l] );
                tstack[l] := 0;
                l := l - 1;
            fi;
        fi;

        # push g through word 
        for i  in [ n, n-1 .. g+1 ]  do

            if word[i] <> 0 then

                # get relator and tail
                t := [];
                if e > 0 then 
                    s := Position( A.enumrels, [i, g] );
                    r := PowerWord( A, A.relators[i][g], word[i] );
                    t[s] := PowerTail( A, A.relators[i][g], word[i] );
                elif e < 0 then 
                    s := Position( A.enumrels, [i, i+g] );
                    r := PowerWord( A, A.relators[i][i+g], word[i] );
                    t[s] := PowerTail( A, A.relators[i][i+g], word[i] );
                fi;
 
                # add to stacks
                AddTailVectorsCR( tail, t );
                l := l+1;
                wstack[l] := r;
                tstack[l] := tail;
                tail := [];
                c[l] := 1;
                p[l] := 1;
            fi;

            # reset
            word[i] := 0;
        od;

        # increase exponent
        if e < 0 then
            word[g] := word[g] - 1;
        else
            word[g] := word[g] + 1;
        fi;

        # insert power relators if exponent has reached rel order
        if rels[g] > 0 and word[g] = rels[g]  then
            word[g] := 0;
            r := A.relators[g][g];
            s := Position( A.enumrels, [g, g] );
            for i  in [1..Length(r)] do
                word[r[i][1]] := r[i][2];
            od;
            t := []; t[s] := A.one;
            AddTailVectorsCR( tail, t );

        # insert power relators if exponent is negative
        elif rels[g] > 0 and word[g] < 0 then 
            word[g] := rels[g] + word[g];
            if Length(A.relators[g][g]) <= 1 then
                r := A.relators[g][g];
                for i  in [1..Length(r)] do
                    word[r[i][1]] := -r[i][2];
                od;
                s := Position( A.enumrels, [g, g] );
                t := []; t[s] := - MappedWordCR( r, A.mats, A.invs );
                AddTailVectorsCR( tail, t );

            else
                r := InvertWord( A.relators[g][g] );
                s := Position( A.enumrels, [g, g] );
                t := []; t[s] := - MappedWordCR( r, A.mats, A.invs );
                AddTailVectorsCR( tail, t );
                l := l+1;
                wstack[l] := r;
                tstack[l] := tail;
                tail := [];
                c[l] := 1;
                p[l] := 1;
            fi;
        fi;
    od;

    return rec( word := word,  tail := tail );
end );

#############################################################################
##
#F TwoCocyclesCR( A )
##
InstallGlobalFunction( TwoCocyclesCR, function( A )
    local C, n, e, id, l, gn, gp, gi, eq, pairs, i, j, k, w1, w2, d, sys, h;

    # set up system of length d
    n := Length( A.mats );
    e := RelativeOrdersOfPcp( A.factor );
    l := Length( A.enumrels );
    d := A.dim;
    sys := CRSystem( d, l, A.char );

    # set up for equations 
    id := IdentityMat(n);
    gn := List( id, x -> rec( word := x, tail := [] ) );

    # precompute (ij) for i > j
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

    # and return solution
    return KernelCR( A, sys ).basis;
end );

#############################################################################
##
#F TwoCoboundariesCR( A )
##
InstallGlobalFunction( TwoCoboundariesCR, function( A )
    local n, c, sys, R, i, j, tail, z, k, v, mat, l;

    # set up system of length d
    n   := Length( A.mats );
    l   := Length( A.enumrels );
    sys := CRSystem( A.dim, l, A.char );

    # loop over relators
    R := [];
    for c in A.enumrels do 
        tail := CollectedRelatorCR( A, c[1], c[2] );
        SubtractTailVectors( tail[1], tail[2] );
        Add( R, tail[1] );
    od;

    # shift into system
    z := sys.zero;
    for i in [1..n] do
        mat := [];
        for k in [1..A.dim] do
            v := [];
            for j in [1..l] do
                if IsBound( R[j][i] ) then 
                    Append( v, R[j][i][k] );
                else
                    Append( v, z );
                fi;
            od;
            Add( mat, v );
        od;
        AddToCRSystem( sys, mat );
    od;

    # return
    return ImageCR( A, sys ).basis;
end );

#############################################################################
##
#F TwoCohomologyCR( A ) 
##
InstallGlobalFunction( TwoCohomologyCR, function( A )
    local cc, cb;
    cc := TwoCocyclesCR( A );
    cb := TwoCoboundariesCR( A );
    return rec( gcc := cc, gcb := cb, 
                factor := AdditiveFactorPcp( cc, cb, A.char ));
end );

#############################################################################
##
#F TwoCohomologyTrivialModule( G, d[, p] )
##
TwoCohomologyTrivialModule := function(arg)
    local G, d, m, C, c;

    # catch arguments
    G := arg[1];
    d := arg[2];
    if Length(arg)=2 then
        m := List(Igs(G), x -> IdentityMat(d));
    elif Length(arg)=3 then
        m := List(Igs(G), x -> IdentityMat(d,arg[3]));
    fi;

    # construct H^2
    C := CRRecordByMats(G, m);
    c := TwoCohomologyCR(C);

    return c.factor.rels;   
end;

#############################################################################
##
#F CheckTrivialCohom( G )
##
CheckTrivialCohom := function(G)
    local mats, C, cb, cc, c, E;

    # compute cohom
    Print("compute cohomology \n");
    mats := List( Pcp(G), x -> IdentityMat( 1 ) );
    C := CRRecordByMats( G, mats );
    cb := TwoCoboundariesCR( C );
    Print("cb has length ", Length(cb)," \n");
    cc := TwoCocyclesCR( C );
    Print("cc has length ", Length(cc)," \n");

    # first check
    Print("check cb in cc \n");
    c  := First( cb, x -> IsBool( SolutionMat( cc,x ) ) );
    if not IsBool( c ) then 
        Print("  coboundary is not contained in cc \n");
        return c; 
    fi;

    # second check
    Print("check cc \n");
    for c in cc do
        E := ExtensionCR( C, c );
    od;
end;

