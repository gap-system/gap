#############################################################################
##
#W  modpres.gi                   ipcq package                    Bettina Eick
##

#############################################################################
##
#F CollectedPair( Q, M, u, v )
##
#F u is a exponent-tail word and v is a glist-tail word.
#F tail can be a list of words or a list of matrices.
##
CollectedPair := function( Q, M, u, v )
    local n, rels, word, tail, wstack, tstack, 
          p, c, l, g, e, h, s, t, r, i, j, m;

    # set up and push u into result
    n    := Length( Q.pcgens );
    rels := Q.pcords;
    word := StructuralCopy( u.word );
    tail := StructuralCopy( u.tail );

    # catch a trivial case
    if Length( v.word ) = 0 then 
        AddTails( tail, v.tail, M.word );
        return rec( word := word, tail := tail );
    fi;

    # create stacks and put v onto stack
    wstack := [StructuralCopy( v.word )];
    tstack := [StructuralCopy( v.tail )];
    p := [1];                 
    c := [1];

    # run until stacks are empty
    l := 1;
    while l > 0 do

        # take a generator and its exponent
        g := wstack[l][p[l]][1];
        e := wstack[l][p[l]][2];

        # take operation generator or its inverse
        if e > 0 then 
            h := M.gens[g];
        else
            h := M.invs[g];
        fi;

        # push g through module tail
        MultTail( M, tail, h );

        # correct the stacks
        c[l] := c[l] + 1;
        if AbsInt(e) < c[l] then                # exponent overflow
            c[l] := 1;
            p[l] := p[l] + 1;
            if Length(wstack[l]) < p[l]  then   # word overflow - add tail
                AddTails( tail, tstack[l], M.word );
                tstack[l] := 0;
                l := l - 1;
            fi;
        fi;

        # push g through word 
        for i  in [ n, n-1 .. g+1 ]  do

            if word[i] <> 0 then

                # get relator and tail
                if e > 0 then 
                    s := Position( Q.pcenum, [i, g] );
                    r := PowerGlist( Q.pcrels[i][g], word[i] );
                    m := Q.pchand[i][g];
                elif e < 0 then 
                    s := Position( Q.pcenum, [i, i+g] );
                    r := PowerGlist( Q.pcrels[i][i+g], word[i] );
                    m := Q.pchand[i][i+g];
                fi;

                # add derivation to tail
                j := PositionSet( M.used, s );
                if not IsBool(j) then
                    AddDerivationTail( M, tail, j, m, word[i] );
                fi;

                # add to stacks
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
            r := Q.pcrels[g][g];
            s := Position( Q.pcenum, [g, g] );
            for i  in [1..Length(r)] do
                word[r[i][1]] := r[i][2];
            od;
            j := PositionSet( M.used, s );
            if not IsBool( j ) then 
                t := AddDerivationTail( M, tail, j, Q.pcone, 1 );
            fi;

        # insert power relators if exponent is negative
        elif rels[g] > 0 and word[g] < 0 then 
            word[g] := rels[g] + word[g];
            r := InvertGlist( Q.pcrels[g][g] );
            s := Position( Q.pcenum, [g, g] );
            j := PositionSet( M.used, s );
            if not IsBool( j ) then 
                t := AddDerivationTail( M, tail, j, Q.pchand[g][g], -1 );
            fi;

            if Length( Q.pcrels[g][g]) <= 1 then
                for i  in [1..Length(r)] do
                    word[r[i][1]] := r[i][2];
                od;
            else
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
end;

#############################################################################
##
#F ConsistencyEvaluation( Q, M )
##
ConsistencyEvaluation := function( Q, M )
    local n, e, id, gn, gp, gi, eq, pairs, i, j, k, h, l, w1, w2, t;

    # set up 
    n := Length( Q.pcgens );
    e := Q.pcords;
    id := IdentityMat(n);
    gn := List( id, x -> rec( word := x, tail := [] ) );

    # precompute (ij) for i > j
    pairs := List( [1..n], x -> [] );
    for i  in [1..n]  do
        if e[i] > 0 then
            h := rec( word := (e[i] - 1) * id[i], tail := [] );
            pairs[i][i] := CollectedPair( Q, M, h, Glist( gn[i] ) );
        fi;
        for j  in [1..i-1]  do
            pairs[i][j] := CollectedPair( Q, M, gn[i], Glist( gn[j] ) );
        od;
    od;

    # consistency 1:  k(ji) = (kj)i
    Info( InfoIPCQ, 3, "    consistency 1");
    for i  in [ n, n-1 .. 1 ]  do
        for j  in [ n, n-1 .. i+1 ]  do
            for k  in [ n, n-1 .. j+1 ]  do
                w1 := CollectedPair( Q, M, gn[k], Glist( pairs[j][i] ));
                w2 := CollectedPair( Q, M, pairs[k][j], Glist( gn[i] ));
                if w1.word <> w2.word  then
                    Error( "k(ji) <> (kj)i" );
                else
                    t := AddTailPair( M, w1.tail, w2.tail );
                    #if t then Info( InfoIPCQ, 3, "    ",k," ", j," ", i); fi;
                fi;
            od;
        od;
    od;

    # consistency 2: j^(p-1) (ji) = j^p i
    Info( InfoIPCQ, 3, "    consistency 2");
    for i  in [n,n-1..1]  do
        for j  in [n,n-1..i+1]  do
            if e[j] > 0 then
                h := rec( word := (e[j] - 1) * id[j], tail := [] );
                w1 := CollectedPair( Q, M, h, Glist( pairs[j][i] ) );
                w2 := CollectedPair( Q, M, pairs[j][j], Glist( gn[i] ));
                if w1.word <> w2.word  then
                    Error( "j^(p-1) (ji) <> j^p i" );
                else
                    t := AddTailPair( M, w1.tail, w2.tail );
                    #if t then Info( InfoIPCQ, 3,"    ",j,"^",e[j]," ",i); fi;
                fi;
            fi;
        od;
    od;

    # consistency 3: k (i i^(p-1)) = (ki) i^p-1
    Info( InfoIPCQ, 3,"    consistency 3");
    for i  in [n,n-1..1]  do
        if e[i] > 0 then
            h := rec( word := (e[i] - 1) * id[i], tail := [] );
            l := CollectedPair( Q, M, gn[i], Glist( h ) );
            for k  in [n,n-1..i+1]  do
                w1 := CollectedPair( Q, M, gn[k], Glist( l ) );
                w2 := CollectedPair( Q, M, pairs[k][i], Glist( h ) );
                if w1.word <> w2.word  then
                    Error( "k i^p <> (ki) i^(p-1)" );
                else
                    t := AddTailPair( M, w1.tail, w2.tail );
                    #if t then Info( InfoIPCQ, 3,"    ",k," ",i,"^",e[i]); fi;
                fi;
            od;
        fi;
    od;

    # consistency 4: (i i^(p-1)) i = i (i^(p-1) i)
    Info( InfoIPCQ, 3,"    consistency 4");
    for i  in [ n, n-1 .. 1 ]  do
        if e[i] > 0 then
            h := rec( word := (e[i] - 1) * id[i], tail := [] );
            l := CollectedPair( Q, M, gn[i], Glist( h ) );
            w1 := CollectedPair( Q, M, l, Glist( gn[i] ) );
            w2 := CollectedPair( Q, M, gn[i], Glist( pairs[i][i] ) );
            if w1.word <> w2.word  then
                Error( "i i^p-1 <> i^p" );
            else
                t := AddTailPair( M, w1.tail, w2.tail );
                #if t then Info( InfoIPCQ, 3,"    ", i,"^", e[i]+1); fi;
            fi;
         fi;
    od;

    # consistency 5: j = (j -i) i   
    Info( InfoIPCQ, 3,"    consistency 5");
    gi := List( id, x -> rec( word := -x, tail := [] ) );
    for i  in [n,n-1..1]  do
        for j  in [n,n-1..i+1]  do
            #if e[i] = 0 then
                w1 := CollectedPair( Q, M, gn[j], Glist( gi[i] ) );
                w2 := CollectedPair( Q, M, w1, Glist( gn[i] ) );
                if w2.word <> id[j] then
                    Error( "j <> (j -i) i" );
                else
                    t := AddTailPair( M, w2.tail, [] );
                    #if t then Info( InfoIPCQ, 3,"    ", j," ", -i," ",i); fi;
                fi;
            #fi;
        od;
    od;
            
end;

#############################################################################
##
#F LookAhead( Q, rel, i )
##

LookAhead := function( Q, rel, i )
    if i < 5 then return false; fi;
    if rel[i+1] <> 1 or rel[i-3] <> -1 then return false; fi;
    if rel[i-1] > 1 or rel[i-1] < -1 then return false; fi;
    if rel[i] <> rel[i-4] then return false; fi;
    if rel[i] > rel[i-2] then return false; fi;
    return true;
end;

InvertedElement := function( Q, M, w )
    local v, i, u;
    v := StructuralCopy( w );
    v.word := 0 * v.word;
    for i in [1..Length(v.tail)] do
        if IsBound( v.tail[i] ) then
            v.tail[i] := List( v.tail[i], x -> [- x[1], x[2]] );
        fi;
    od;
    u := StructuralCopy( w );
    u.word := InvertGlist( GlistOfVector( u.word ) );
    u.tail := [];
    return CollectedPair( Q, M, v, u );
end;
  
CollectedCommutator := function( Q, M, b, a )
    local w, v;
    w := InvertedElement( Q, M, a );
    v := StructuralCopy( b );
    v.word := GlistOfVector( v.word );
    w := CollectedPair( Q, M, w, v );
    v := StructuralCopy( a );
    v.word := GlistOfVector( v.word );
    w := CollectedPair( Q, M, w, v );
    v := InvertedElement( Q, M, b );
    w.word := GlistOfVector( w.word );
    w := CollectedPair( Q, M, v, w );
    return w;
end;

#############################################################################
##
#F RelatorsEvaluation( Q, M )
##
RelatorsEvaluation := function( Q, M )
    local hn, hi, zr, rel, s, w, i, r, e, j, l, u, k, rs, cn, t; 

    # precompute generators and inverses
    if not M.split then
        zr := rec( word := List( Q.pcgens, x -> 0 ), tail := [] );
        hn := List( Q.imgs, x -> ShallowCopy( Exponents( x ) ) );
        hn := List( hn, x -> rec( word := x, tail := [] ) );
        hi := List( hn, x -> InvertGlist( GlistOfVector( x.word ) ) );
        hi := List( hi, x -> rec( word := x, tail := [] ) );
        hi := List( hi, x -> CollectedPair( Q, M, zr, x ) );
    fi;

    for k in [1..Length(Q.fprels)] do
        rel := Q.fprels[k];
        Info( InfoIPCQ, 3,"    starting relator ", k);

        # get fox derivative
        s := [];
        for i in [1, 3 .. Length(rel)-1] do
            r := rel[i];
            e := rel[i+1]; 
            l := M.nrpct + r;
            MultTail( M, s, Q.imgs[r]^e );
            j := PositionSet( M.used, l );
            if not IsBool( j ) then 
                u := AddDerivationTail( M, s, j, Q.imgs[r], e );
            fi;
        od;

        # compute tails
        if not M.split then
            w := StructuralCopy( zr );
            i := Length(rel) - 1;
            while 1 <= i do
                if LookAhead( Q, rel, i ) then 
                    r := rel[i];
                    t := rel[i-2];
                    if rel[i-1] = 1 then 
                        rs := StructuralCopy( hn[t] );
                        rs.word := GlistOfVector( rs.word );
                    else
                        rs := StructuralCopy( hi[t] );
                        rs.word := GlistOfVector( rs.word );
                    fi;
                    cn := CollectedPair( Q, M, hi[r], rs );
                    rs := StructuralCopy( hn[r] );
                    rs.word := GlistOfVector( rs.word );
                    cn := CollectedPair( Q, M, cn, rs );
                    w.word := GlistOfVector( w.word );
                    w := CollectedPair( Q, M, cn, w );
                    i := i - 4;
                else
                    r := rel[i];
                    e := rel[i+1]; 
                    if e > 0 then
                        for j in [1..e] do
                            w.word := GlistOfVector( w.word );
                            w := CollectedPair( Q, M, hn[r], w );
                        od;
                    else
                        for j in [1..-e] do
                            w.word := GlistOfVector( w.word );
                            w := CollectedPair( Q, M, hi[r], w );
                        od;
                    fi;
                fi;
                i := i - 2;
            od;
            AddTails( s, w.tail, M.word );
        fi;

        # add to system
        AddTailPair( M, s, [] );
    od;
end;

#############################################################################
##
#F a little helpers
##
DeleteColumn := function( mat, j )
    local k;
    k := Concatenation( [1..j-1], [j+1..Length(mat[1])] );
    return mat{[1..Length(mat)]}{k};
end;

#############################################################################
##
#F AddModulePresentation( Q, M )
##
AddModulePresentation := function( Q, M )
    local mat, don, len, i, j, k;
 
    # evaluate consistency - non-split case only
    if not M.split then
        Info( InfoIPCQ, 3,"  evaluate consistency ");
        ConsistencyEvaluation( Q, M );
    fi;

    # evaluate relators in any case
    Info( InfoIPCQ, 3, "  evaluate relators of fp group ");
    RelatorsEvaluation( Q, M );

    # set up for reduction
    mat := MutableTransposedMat( M.tails );
    len := List( mat, x -> List( x, Length ) );
    don := false;

    # reduce presentation
    while not don do
        don := true;

        # find trivial entries
        for i in [1..Length(mat)] do
            if Sum(len[i]) = 1 then
               j := Position( len[i], 1 );
               if AbsInt(mat[i][j][1][1]) = 1 then
                   mat := DeleteColumn( mat, j );
                   don := false;
                   len := List( mat, x -> List( x, Length ) );
                   Add( M.avoid, M.used[j] );
                   M.used := Filtered( M.used, x -> x <> M.used[j] );
               fi;
            fi;
        od;

        # clear 0 rows
        if not don then
            for i in [1..Length(mat)] do
                if Sum(len[i]) = 0 then mat[i] := false; fi;
            od;
            mat := Filtered( mat, x -> not IsBool(x) );
            len := List( mat, x -> List( x, Length ) );
        fi;
    od;

    # finally sort and transpose back
    SortParallel( List(len, PositionNonZero), mat );
    M.tails := MutableTransposedMat( Reversed(mat) );
    M.rows := Length(M.tails);
    if M.rows>0 then M.cols := Length(M.tails[1]); fi;
    M.first := First([1..Length(M.used)], x -> M.used[x] > M.nrpct );
    if IsBool( M.first ) then M.first := Length( M.used ) + 1; fi;

    # return the presentation
    return M;
end;
