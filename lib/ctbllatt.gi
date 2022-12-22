#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Ansgar Kaup.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains functions that mainly deal with lattices in the
##  context of character tables.
##


#############################################################################
##
#F  LLL( <tbl>, <characters>[, <y>][, \"sort\"][, \"linearcomb\"] )
##
InstallGlobalFunction( LLL, function( arg )

    local tbl,         # character table, first argument
          characters,  # list of virtual characters, second argument
          sorted,      # characters sorted by degree
          L,           # lattice gen. by the virtual characters
          i,           # loop variable
          lllrb,       # result of `LLLReducedBasis'
          lll,         # result
          v,           # loop over the LLL reduced basis
          perm,        # permutation arising from sorting characters
          y,           # optional argument <y>
          scpr;        # scalar product

    # 1. Check the arguments.
    if   Length( arg ) < 2 or Length( arg ) > 5
       or not IsNearlyCharacterTable( arg[1] ) then
      Error( "usage: ",
             "LLL( <tbl>, <chars> [,<y>][,\"sort\"][,\"linearcomb\"] )" );
    fi;

    # 2. Get the arguments.
    tbl:= arg[1];
    characters:= arg[2];
    if "sort" in arg then
      sorted:= SortedCharacters( tbl, characters, "degree" );
      perm:= Sortex( ShallowCopy( sorted ) )
             / Sortex( ShallowCopy( characters ) );
      characters:= sorted;
    fi;
    if IsBound( arg[3] ) and IsRat( arg[3] ) then
      y:= arg[3];
    else
      y:= 3/4;
    fi;

    # 3. Call the LLL algorithm.
    L:= AlgebraByGenerators( Rationals, [ TrivialCharacter( tbl ) ] );
    if "linearcomb" in arg then
      lllrb:= LLLReducedBasis( L, characters, y, "linearcomb" );
    else
      lllrb:= LLLReducedBasis( L, characters, y );
    fi;

    # 4. Make a new result record.
    lll:= rec( irreducibles := [],
               remainders   := [],
               norms        := [] );

    # 5. Sort the relations and transformation if necessary.
    if IsBound( lllrb.relations ) then
      lll.relations      := lllrb.relations;
      lll.transformation := lllrb.transformation;
      if IsBound( perm ) then
        lll.relations      := List( lll.relations,
                                    x -> Permuted( x, perm ) );
        lll.transformation := List( lll.transformation,
                                    x -> Permuted( x, perm ) );
      fi;
    fi;

    # 6. Add the components used by the character table functions.
    lll.irreducibles  := [];
    lll.remainders    := [];
    lll.norms         := [];
    if IsBound( lllrb.transformation ) then
      lll.irreddecomp := [];
      lll.reddecomp   := [];
    fi;

    for i in [ 1 .. Length( lllrb.basis ) ] do

      v:= lllrb.basis[i];
      if v[1] < 0 then
        v:= AdditiveInverse( v );
        if IsBound( lllrb.transformation ) then
          lll.transformation[i]:= AdditiveInverse( lll.transformation[i] );
        fi;
      fi;
      scpr:= ScalarProduct( tbl, v, v );
      if scpr = 1 then
        Add( lll.irreducibles, Character( tbl, v ) );
        if IsBound( lllrb.transformation ) then
          Add( lll.irreddecomp, lll.transformation[i] );
        fi;
      else
        Add( lll.remainders, VirtualCharacter( tbl, v ) );
        Add( lll.norms, scpr );
        if IsBound( lllrb.transformation ) then
          Add( lll.reddecomp,   lll.transformation[i] );
        fi;
      fi;

    od;

    if not IsEmpty( lll.irreducibles ) then
      Info( InfoCharacterTable, 2,
            "LLL: ", Length( lll.irreducibles ), " irreducibles found" );
    fi;

    # 7. Sort `remainders' and `reddecomp' components if necessary.
    if "sort" in arg then
      sorted:= SortedCharacters( tbl, lll.remainders, "degree" );
      perm:= Sortex( ShallowCopy( lll.remainders ) )
             / Sortex( ShallowCopy( sorted ) );
      lll.norms:= Permuted( lll.norms, perm );
      lll.remainders:= sorted;
      if "linearcomb" in arg then
        lll.reddecomp:= Permuted( lll.reddecomp, perm );
      fi;
    fi;

    # 7. Unbind components not used for characters.
    Unbind( lll.transformation );

    # 8. Return the result.
    return lll;
end );


#############################################################################
##
#F  Extract( <tbl>, <reducibles>, <gram-matrix> [, <missing> ] )
##
InstallGlobalFunction( Extract, function( arg )

    local

    # indices
          i, j, k, l, n,
    # input arrays
          tbl, y, gram, missing,
    # booleans
          deeper, iszero, used, nullbegin, nonmissing,
          maxnorm, minnorm, normbound, maxsum, solmat,
          f, squares, sfind, choicecollect, sequence,
          dependies, solcollect, sum, solcount, max, sumac, kmax,
          solution,
    # functions
          next, zeroset, possiblies, update, correctnorm,
          maxsquare, square, ident, begin;

    # choosing next vector for combination
    next := function( lines, solumat, acidx )
    local i, j, solmat, testvec, idxback;

    while acidx <= n and k + n - acidx >= kmax do
       solmat := List( solumat, ShallowCopy );
       if k = 0 then
          i := acidx;
          while i <= n and not begin( sequence[i] ) do
             i := i + 1;
          od;
          if i > n then
             nullbegin := true;
          else
             nullbegin := false;
             if i > acidx then
                idxback := sequence[i];
                for j in [acidx + 1..1] do
                   sequence[j] := sequence[j -1];
                od;
                sequence[acidx] := idxback;
             fi;
          fi;
       fi;
       k := k + 1;
       f[k] := sequence[acidx];
       testvec := [];
       for i in [1..k] do
          testvec[i] := gram[f[k]][f[i]];
       od;
       zeroset( solmat, testvec, lines );
       acidx := acidx + 1;
       possiblies( 1, solmat, testvec, acidx, lines );
       k := k - 1;
    od;
    end;

    # filling zero in places that fill already the conditions
    zeroset := function( solmat, testvec, lines )
    local i, j;

    for i in [1..k-1] do
       if testvec[i] = 0 then
          for j in [1..lines] do
             if solmat[j][i] <> 0 and not IsBound( solmat[j][k] ) then
                solmat[j][k] := 0;
             fi;
          od;
       fi;
    od;
    end;

    # try and error for the chosen vector
    possiblies := function( start, solmat, testvect, acidx, lines )
    local i, j, toogreat, equal, solmatback, testvec;

    testvec := ShallowCopy( testvect );
    toogreat := false;
    equal := true;
    if k > 1 then
       for i in [1..k-1] do
          if testvec[i] < 0 then
             toogreat := true;
          fi;
          if testvec[i] <> 0 then
             equal := false;
          fi;
       od;
       if testvec[k] < 0 then
          toogreat := true;
       fi;
    else
       if not nullbegin then
          while start <= gram[f[k]][f[k]] and start < missing do
             solmat[start][k] := 1;
             start := start + 1;
          od;
          testvec[k] := 0;
          if gram[f[k]][f[k]] > lines then
             lines := gram[f[k]][f[k]];
          fi;
       else
          lines := 0;
       fi;
    fi;
    if not equal and not toogreat then
       while start < lines and IsBound( solmat[start][k] ) do
          start := start + 1;
       od;
       if start <= lines and not IsBound( solmat[start][k] ) then
          solmat[start][k] := 0;
          while not toogreat and not equal do
             solmat[start][k] := solmat[start][k] + 1;
             testvec := update( -1, testvec, start, solmat );
             equal := true;
             for i in [1..k-1] do
                if testvec[i] < 0 then
                   toogreat := true;
                fi;
                if testvec[i] <> 0 then
                   equal := false;
                fi;
             od;
             if testvec[k] < 0 then
                toogreat := true;
             fi;
          od;
       fi;
    fi;
    if equal and not toogreat then
       solmatback := List( solmat, ShallowCopy );
       for i in [1..missing] do
          if not IsBound( solmat[i][k] ) then
             solmat[i][k] := 0;
          fi;
       od;
       correctnorm( testvec[k], solmat, lines + 1, testvec[k], acidx, lines );
       solmat := solmatback;
#T here was a 'Copy' call. WHY?
    fi;
    if k > 1 then
       while start <= lines and solmat[start][k] > 0 do
          solmat[start][k] := solmat[start][k] - 1;
          testvec := update( 1, testvec, start, solmat );
          solmatback := List( solmat, ShallowCopy );
          zeroset( solmat, testvec, lines );
          deeper := false;
          for i in [1..k-1] do
             if solmat[start][i] <> 0 then
                deeper := false;
                if testvec[i] = 0 then
                   deeper := true;
                else
                   for j in [1..missing] do
                      if solmat[j][i] <> 0 and not IsBound(solmat[j][k]) then
                        deeper := true;
                      fi;
                   od;
                fi;
             fi;
          od;
          if deeper then
             possiblies( start + 1, solmat, testvec, acidx, lines );
          fi;
          solmat := solmatback;
#T here was a 'Copy' call. WHY?
       od;
    fi;
    end;

    # update the remaining conditions to fill
    update := function( x, testvec, start, solmat )
    local i;
    for i in [1..k-1] do
       if solmat[start][i] <> 0 then
          testvec[i] := testvec[i] + solmat[start][i] * x;
       fi;
    od;
    testvec[k] := testvec[k] - square( solmat[start][k] )
                             + square( solmat[start][k] + x );
    return testvec;
    end;

    # correct the norm if all other conditions are filled
    correctnorm := function( remainder, solmat, pos, max, acidx, lines )
    local i, newsol, ret;
    if remainder = 0 and pos <= missing + 1 then
       newsol := true;
       for i in [1..solcount[k]] do
          if ident( solcollect[k][i], solmat ) = missing then
             newsol := false;
          fi;
       od;
       if newsol then
          if k > kmax then
             kmax := k;
          fi;
          solcount[k] := solcount[k] + 1;
          solcollect[k][solcount[k]] := [];
          choicecollect[k][solcount[k]] := ShallowCopy( f );
          for i in [1..Length( solmat )] do
             solcollect[k][solcount[k]][i] := ShallowCopy( solmat[i] );
          od;
          if k = n and pos = missing + 1 then
             ret := 0;
          else
             ret := max;
             if k <> n then
                next( lines, solmat, acidx );
             fi;
          fi;
       else
          ret := max;
       fi;
    else
       if pos <= missing then
          i := maxsquare( remainder, max );
          while i > 0 do
             solmat[pos][k] := i;
             i := correctnorm( remainder-square( i ),
                               solmat, pos+1, i, acidx, lines + 1);
             i := i - 1;
          od;
          if i < 0 then
             ret := 0;
          else
             ret := max;
          fi;
       else
          ret := 0;
       fi;
    fi;
    return ret;
    end;

    # compute the maximum squarenumber lower then given integer
    maxsquare := function( value, max )
    local i;

    i := 1;
    while square( i ) <= value and i <= max do
          i := i + 1;
    od;
    return i-1;
    end;

    square := function( i )
    if i = 0 then
       return( 0 );
    else
       if not IsBound( squares[i] ) then
          squares[i] := i * i;
       fi;
       return squares[i];
    fi;
    end;

    ident := function( a, b )
    # lists the identities of the two given sequences and counts them
    local i, j, k, zi, zz, la, lb;
    la := Length( a );
    lb := Length( b );
    zi := [];
    zz := 0;
    for i in [1..la] do
       j := 1;
       repeat
          if a[i] = b[j] then
             k :=1;
             while k <= zz and j <> zi[k] do
                k := k + 1;
             od;
             if k > zz then
                zz := k;
                zi[zz] := j;
                j := lb;
             fi;
          fi;
          j := j + 1;
       until j > lb;
    od;
    return( zz );
    end;

    # looking for character that can stand at the beginning
    begin := function( i )
    local ind;
    if y = [] or gram[i][i] < 4 then
       return true;
    else
       if IsBound( ComputedPowerMaps( tbl )[2] ) then
          if ForAll( ComputedPowerMaps( tbl )[2], IsInt ) then
#T ??
             ind := AbsInt( Indicator( tbl, [y[i]], 2 )[1]);
             if gram[i][i] - 1 <= ind
             or ( gram[i][i] = 4 and ind = 1 ) then
                return true;
             fi;
          fi;
       fi;
    fi;
    return false;
    end;

    # check input parameters
    if IsNearlyCharacterTable( arg[1] ) then
       tbl := arg[1];
    else
       Error( "first argument must be character table\n \
    usage: Extract( <tbl>, <reducibles>, <gram-matrix> [, <missing>] )" );
    fi;
    if IsBound( arg[2] ) and IsList( arg[2] ) and IsList( arg[2][1] ) then
       y := List( arg[2], ShallowCopy );
    else
       Error( "second argument must be list of reducible characters\n \
    usage: Extract( <tbl>, <reducibles>, <gram-matrix> [, <missing>] )" );
    fi;
    if IsBound( arg[2] ) and IsList( arg[3] ) and IsList( arg[3][1] ) then
       gram := List( arg[3], ShallowCopy );
    else
       Error( "third argument must be gram-matrix of reducible characters\n \
    usage: Extract( <tbl>, <reducibles>, <gram-matrix> [, <missing>] )" );
    fi;
    n := Length( gram );
    if IsBound( arg[4] ) and IsInt( arg[4] ) then
       missing := arg[4];
    else
       missing := n;
       nonmissing := true;
    fi;

    # main program
    maxnorm := 0;
    minnorm := gram[1][1];
    normbound := [];
    maxsum := [];
    solcollect := [];
    choicecollect := [];
    sum := [];
    solmat := [];
    used := [];
    solcount := [];
    sfind := [];
    f := [];
    squares := [];
    kmax := 0;
    for i in [1..missing] do
       solmat[i] := [];
    od;
    for i in [1..n] do
       solcount[i] := 0;
       used[i] := false;
       solcollect[i] := [];
       choicecollect[i] := [];
    od;
    for i in [1..n] do
       if gram[i][i] > maxnorm then
          maxnorm := gram[i][i];
       else
          if gram[i][i] < minnorm then
             minnorm := gram[i][i];
          fi;
       fi;
    od;
    j := 0;
    for i in [minnorm..maxnorm] do
       k := 1;
       while k <= n and gram[k][k] <> i do
          k := k + 1;
       od;
       if k <= n then
           j := j + 1;
           normbound[j] := rec( norm:=i, first:=k, last:=0 );
           if k = n then
              normbound[j].last := k;
           else
              k := n;
              while gram[k][k] <> i and k > 0 do
                 k := k - 1;
              od;
              if k > 0 then
                 normbound[j].last := k;
              fi;
           fi;
       fi;
    od;
    for j in [1..Length( normbound )] do
       maxsum[j] := 0;
       for i in [normbound[j].first..normbound[j].last] do
          if gram[i][i] = normbound[j].norm then
             sum[i] := 0;
             for k in [1..n] do
                sum[i] := sum[i] + gram[i][k];
             od;
             if sum[i] > maxsum[j] then
                maxsum[j] := sum[i];
             fi;
          fi;
       od;
    od;
    k := 1;
    sequence := [];
    i:= 1;
    while i <= Length( normbound ) do
       max := maxsum[i];
       sumac := 0;
       for j in [normbound[i].first..normbound[i].last] do
          if gram[j][j] = normbound[i].norm and sum[j] > sumac
          and sum[j] <= max and not used[j] then
             sequence[k] := j;
             sumac := sum[j];
          fi;
       od;
       if IsBound( sequence[k] ) then
          max := sumac;
          used[sequence[k]] := true;
          k := k + 1;
       else
          i := i + 1;
       fi;
    od;
    k := 0;
    next( 1, solmat, 1 );
    solution := rec( solution := [], choice := choicecollect[kmax] );
    for i in [1..solcount[kmax]] do
       solution.solution[i] := [];
       l := 0;
       for j in [1..missing] do
          iszero := true;
          for k in [1..kmax] do
             if solcollect[kmax][i][j][k] <> 0 then
                iszero := false;
             fi;
          od;
          if not iszero then
             l := l + 1;
             solution.solution[i][l] := solcollect[kmax][i][j];
          fi;
       od;
    od;
    return( solution );
end );


#############################################################################
##
#F  Decreased( <tbl>, <chars>, <decompmat>, [ <choice> ] )
##
InstallGlobalFunction( Decreased, function( arg )
    local
        # indices
          m, n, n1, i, i1, i2, i3, i4, j, jj, j1, j2, j3,
        # booleans
          ende1, ende2, ok, change, delline, delcolumn,
        # help fields
          deleted, kgv, l1, l2, l3, dim, ident,
        # matrices
          invmat, remmat, remmat2, solmat, nonzero,
        # double-indices
          columnidx, lineidx, system, components, compo2,
        # output-fields
          sol, red, redcount, irred,
        # help fields
          IRS, SFI, lc, nc, char, char1, entries,
        # input fields
          tbl, y, choice,
        # functions
          Idxset, Identset, Invadd, Invmult, Nonzeroset;

    Idxset := function()
    # update indices
    local i1, j1, m1;
    i1 := 0;
    for i in [1..m] do
       if not delline[i] then
          i1 := i1 + 1;
          lineidx[i1] := i;
       fi;
    od;
    m1 := i1;
    j1 := 0;
    for j in [1..n] do
       if not delcolumn[j] then
          j1 := j1 + 1;
          columnidx[j1] := j;
       fi;
    od;
    n1 := j1;
    end;

    Identset := function( veca, vecb )
#T just one place where this is called ...
    # count identities of veca and vecb and store "non-identities"
    local la, lb, i, j, n, nonid, nic, r;
    n := 0;
    la := Length( veca );
    lb := Length( vecb );
    j := 1;
    nonid := [];
    nic := 0;
    for i in [1..la] do
       while j <= lb and veca[i] > vecb[j] do
          nic := nic + 1;
          nonid[nic] := vecb[j];
          j := j + 1;
       od;
       if j <= lb and veca[i] = vecb[j] then
          n := n + 1;
          j := j + 1;
       fi;
    od;
    while j <= lb do
       nic := nic + 1;
       nonid[nic] := vecb[j];
       j := j + 1;
    od;
    r := rec( nonid := nonid, id := n  );
    return( r );
    end;

    Invadd := function( j1, j2, l )
    # addition of two lines of invmat
    local i;
    for i in [1..n] do
       if invmat[i][j2] <> 0 then
          invmat[i][j1] := invmat[i][j1] - l * invmat[i][j2];
       fi;
    od;
    end;

    Invmult := function( j1, l )
    # multiply line of invmat
    local i;
    if l <> 1 then
       for i in [1..n] do
          if invmat[i][j1] <> 0 then
             invmat[i][j1] := invmat[i][j1] * l;
          fi;
       od;
    fi;
    end;

    Nonzeroset := function( j )
    # entries <> 0 in j-th column of 'solmat'

    local i, j1;
    nonzero[j] := [];
    j1 := 0;
    for i in [1..m] do
       if solmat[i][j] <> 0 then
          j1 := j1 + 1;
          nonzero[j][j1] := i;
       fi;
    od;
    entries[j] := j1;
    end;

    # check input parameters
    if Length( arg ) < 3 or Length( arg ) > 4 then
      Error( "usage: Decreased( <tbl>, <list of char>,\n",
             "<decomposition matrix>, [<choice>] )" );
    fi;

    if IsNearlyCharacterTable( arg[1] ) then
       tbl := arg[1];
    else
       Error( "first argument must be a nearly character table\n",
              "usage: Decreased( <tbl>, <list of char>,\n",
              "<decomposition matrix>, [<choice>] )" );
    fi;
    if IsList( arg[2] ) and IsList( arg[2][1] ) then
       y := arg[2];
    else
       Error( "second argument must be list of characters\n",
              "usage: Decreased( <tbl>, <list of char>,\n",
              "<decomposition matrix>, [<choice>] )" );
    fi;
    if IsList( arg[3] ) and IsList( arg[3][1] ) then
       solmat := List( arg[3], ShallowCopy );
    else
       Error( "third argument must be decomposition matrix\n",
              "usage: Decreased( <tbl>, <list of char>,\n",
              "<decomposition-matrix>, [<choice>] )" );
    fi;
    if not IsBound( arg[4] ) then
       choice := [ 1 .. Length( y ) ];
    elif IsList( arg[4] ) then
       choice := arg[4];
    else
       Error( "forth argument contains choice of characters\n",
           "usage: Decreased( <tbl>, <list of char>,\n",
           "<decomposition-matrix>, [<choice>] )" );
    fi;

    # initialisations
    lc := Length( y[1] );
    nc := [];
    for i in [1..lc] do
       nc[i] := 0;
    od;
    columnidx := [];
    lineidx   := [];
    nonzero   := [];
    entries   := [];
    delline   := [];
    delcolumn := [];

    # number of lines
    m := Length( solmat );

    # number of columns
    n := Length( solmat[1] );
    invmat := IdentityMat( n );
    for i in [1..m] do
       delline[i] := false;
    od;
    for j in [1..n] do
       delcolumn[j] := false;
    od;
    i := 1;

    # check lines for information
    while i <= m do
       if not delline[i] then
          entries[i] := 0;
          for j in [1..n] do
             if solmat[i][j] <> 0 and not delcolumn[j] then
                entries[i] := entries[i] + 1;
                if entries[i] = 1 then
                   nonzero[i] := j;
                fi;
             fi;
          od;
          if entries[i] = 1 then
             delcolumn[nonzero[i]] := true;
             delline[i] := true;
             j := 1;
             while j < i and solmat[j][nonzero[i]] = 0 do
                j := j + 1;
             od;
             if j < i then
                i := j;
             else
                i := i + 1;
             fi;
          else
             if entries[i] = 0 then
                delline[i] := true;
             fi;
             i := i + 1;
          fi;
       else
          i := i + 1;
       fi;
    od;
    Idxset();

    deleted := m - Length(lineidx);
    for j in [1..n] do
       Nonzeroset( j );
    od;
    ende1 := false;
    while not ende1 and deleted < m do
       j := 1;

    # check solo-entry-columns
       while j <= n do
          if entries[j] = 1 then
             change := false;
             for jj in [1..n] do
                if (delcolumn[j] and delcolumn[jj])
                or not delcolumn[j] then
                   if solmat[nonzero[j][1]][jj] <> 0 and jj <> j then
                      change := true;
                      kgv := Lcm( solmat[nonzero[j][1]][j],
                              solmat[nonzero[j][1]][jj] );
                      l1 := kgv / solmat[nonzero[j][1]][jj];
                      Invmult( jj, l1 );
                      for i1 in [1..Length( nonzero[jj] )] do
                         solmat[nonzero[jj][i1]][jj]
                               := solmat[nonzero[jj][i1]][jj] * l1;
                      od;
                      Invadd( jj, j, kgv/solmat[nonzero[j][1]][j] );
                      solmat[nonzero[j][1]][jj] := 0;
                      Nonzeroset( jj );
                   fi;
                fi;
             od;
             if not delline[nonzero[j][1]] then
                delline[nonzero[j][1]] := true;
                delcolumn[j] := true;
                deleted := deleted + 1;
                Idxset();
             fi;
             if change then
                j := 1;
             else
                j := j + 1;
             fi;
          else
             j := j + 1;
          fi;
       od;

    # search for Equality-System
    # system :     chosen columns
    # components : entries <> 0 in the chosen columns
       dim := 2;
       change := false;
       ende2 := false;
       while dim <= n1 and not ende2 do
          j3 := 1;
          while j3 <= n1 and not ende2 do
             j2 := j3;
             j1 := 0;
             system := [];
             components := [];
             while j2 <= n1 do
                while j2 <= n1 and entries[columnidx[j2]] > dim do
                   j2 := j2 + 1;
                od;
                if j2 <= n1 then
                   if j1 = 0 then
                      j1 := 1;
                      system[j1] := columnidx[j2];
                      components := ShallowCopy( nonzero[columnidx[j2]] );
                   else
                      ident := Identset( components, nonzero[columnidx[j2]] );
                      if dim - Length( components ) >= entries[columnidx[j2]]
                             - ident.id then
                         j1 := j1 + 1;
                         system[j1] := columnidx[j2];
                         if ident.id < entries[columnidx[j2]] then
                            compo2 := ShallowCopy( components );
                            components := [];
                            i1 := 1;
                            i2 := 1;
                            i3 := 1;

    # append new entries to "components"
                            while i1 <= Length( ident.nonid )
                               or i2 <= Length( compo2 ) do
                               if i1 <= Length( ident.nonid ) then
                                  if i2 <= Length( compo2 ) then
                                     if ident.nonid[i1] < compo2[i2] then
                                        components[i3] := ident.nonid[i1];
                                        i1 := i1 + 1;
                                     else
                                        components[i3] := compo2[i2];
                                        i2 := i2 + 1;
                                     fi;
                                  else
                                     components[i3] := ident.nonid[i1];
                                     i1 := i1 + 1;
                                  fi;
                               else
                                  if i2 <= Length( compo2 ) then
                                     components[i3] := compo2[i2];
                                     i2 := i2 + 1;
                                  fi;
                               fi;
                               i3 := i3 + 1;
                            od;
                         fi;
                      fi;
                   fi;
                   j2 := j2 + 1;
                fi;
             od;

    # try to solve system with Gauss
             if  Length( system ) > 1 then
                for i1 in [1..Length( components )] do
                   i2 := 1;
                   repeat
                      ok := true;
                      if solmat[components[i1]][system[i2]] = 0 then
                         ok := false;
                      else
                         for i3 in [1..i1-1] do
                            if solmat[components[i3]][system[i2]] <> 0 then
                               ok := false;
                            fi;
                         od;
                      fi;
                      if not ok then
                         i2 := i2 + 1;
                      fi;
                   until ok or i2 > Length( system );
                   if ok then
                      for i3 in [1..Length( system )] do
                         if i3 <> i2
                            and solmat[components[i1]][system[i3]] <> 0 then
                            change := true;
                            kgv := Lcm( solmat[components[i1]][system[i3]],
                                       solmat[components[i1]][system[i2]] );
                            l2 := kgv / solmat[components[i1]][system[i2]];
                            l3 := kgv / solmat[components[i1]][system[i3]];
                            for i4 in [1..Length( nonzero[system[i3]] )] do
                               solmat[nonzero[system[i3]][i4]][system[i3]]
                            := solmat[nonzero[system[i3]][i4]][system[i3]]*l3;
                            od;
                            Invmult( system[i3], l3 );
                            for i4 in [1..Length( nonzero[system[i2]] )] do
                               solmat[nonzero[system[i2]][i4]][system[i3]]
                               := solmat[nonzero[system[i2]][i4]][system[i3]]
                            -  solmat[nonzero[system[i2]][i4]][system[i2]]*l2;
                            od;
                            Invadd( system[i3], system[i2], l2 );
                            Nonzeroset( system[i3] );
                            if entries[system[i3]] = 0 then
                               delcolumn[system[i3]] := true;
                               Idxset();
                            fi;
                         fi;
                      od;
                   fi;
                od;

   # check for columns with only one entry <> 0
                for i1 in [1..Length( system )] do
                   if entries[system[i1]] = 1 then
                      ende2 := true;
                   fi;
                od;
                if not ende2 then
                   j3 := j3 + 1;
                fi;
             else
                j3 := j3 + 1;
             fi;
          od;
          dim := dim + 1;
       od;
       if dim > n1 and not change and j3 > n1 then
          ende1 := true;
       fi;
    od;

    # check, if
    #    the transformation of solmat allows computation of new irreducibles
    remmat := [];
    for i in [1..m] do
       remmat[i] := [];
       delline[i] := true;
    od;
    redcount := 0;
    red := [];
    irred := [];
    j := 1;
    sol := true;
    while j <= n and sol do

    # computation of character
       char := ShallowCopy( nc );
       for i in [1..n] do
          if invmat[i][j] <> 0 then
             char := char + invmat[i][j] * y[choice[i]];
          fi;
       od;

    # probably irreducible ==> has to pass tests
       if entries[j] = 1 then
          if solmat[nonzero[j][1]][j] <> 1 then
             char1 := char/solmat[nonzero[j][1]][j];
          else
             char1 := char;
          fi;
          if char1[1] < 0 then
             char1 := - char1;
          fi;

    # is 'char1' real?
          IRS := ForAll( char1, x -> GaloisCyc(x,-1) = x );

   # Frobenius Schur indicator
          if IsBound( ComputedPowerMaps( tbl )[2] )
             and ForAll( ComputedPowerMaps( tbl )[2], IsInt ) then
#T ??
            SFI:= Indicator( tbl, [ char1 ], 2 )[1];
          else
            SFI:= Unknown();
            Info( InfoCharacterTable, 2,
                  "Decreased: 2nd power map not available or not unique,\n",
                  "#I  no test with 'Indicator'" );
          fi;

   # test if 'char1' can be an irreducible character
          if    char1[1] = 0
             or ForAny( char1, x -> not IsCycInt(x) )
             or ScalarProduct( tbl, char1, char1 ) <> 1
             or ( IsCyc( SFI ) and ( ( IRS and AbsInt( SFI ) <> 1 ) or
                                     ( not IRS and SFI <> 0 ) ) )   then
            Info( InfoCharacterTable, 2,
                  "Decreased : computation of ",
                  Ordinal( Length( irred ) + 1 ), " character failed" );
            return fail;
          else

    # irreducible character found
            Add( irred, Character( tbl, char1 ) );
          fi;
       else

    # what a pity (!), some reducible character remaining
          if char[1] < 0 then
             char := - char;
          fi;
          if char <> nc then
             redcount := redcount + 1;
             red[redcount] := ClassFunction( tbl, char );
             for i in [1..m] do
                remmat[i][redcount] := solmat[i][j];
                if solmat[i][j] <> 0 then
                   delline[i] := false;
                fi;
             od;
          fi;
       fi;
       j := j+1;
    od;
    i1 := 0;
    remmat2 := [];
    for i in [1..m] do
       if not delline[i] then
          i1 := i1 + 1;
          remmat2[i1] := remmat[i];
       fi;
    od;
    return rec( irreducibles := irred,
                remainders   := red,
                matrix       := remmat2 );
end );


#############################################################################
##
#F  OrthogonalEmbeddingsSpecialDimension( <tbl>, <reducibles>, <grammat>,
#F                                        [, \"positive\"], <dim> )
##
InstallGlobalFunction( OrthogonalEmbeddingsSpecialDimension, function ( arg )
    local  red, dim, reducibles, tbl, emb, dec, i, s, irred;
    # check input
    if Length( arg ) < 4 then
       Error( "please specify desired dimension\n",
              "usage : OrthogonalE...( <tbl>, <reducibles>,\n",
              "<gram-matrix>[, \"positive\" ], <dim> )" );
    fi;
    if IsInt( arg[4] ) then
       dim := arg[4];
    else
       if IsBound( arg[5] ) then
          if IsInt( arg[5] ) then
             dim := arg[5];
          else
       Error( "please specify desired dimension\n",
              "usage : Orthog...( <tbl>, < reducibles >,\n",
              "< gram-matrix >, [, <\"positive\"> ], < integer > )" );
          fi;
       fi;
    fi;
    tbl := arg[1];
    reducibles := arg[2];
    if Length( arg ) = 4 then
       emb := OrthogonalEmbeddings( arg[3], arg[4] );
    else
       emb := OrthogonalEmbeddings( arg[3], arg[4], arg[5] );
    fi;
    s := [];
    for i in [1..Length(emb.solutions)] do
       if Length( emb.solutions[i] ) = dim then
          Add( s, emb.vectors{ emb.solutions[i] } );
       fi;
    od;
    dec:= List( s, x -> Decreased( tbl, reducibles, x ) );
    dec:= Filtered( dec, x -> x <> fail );
    if dec = [] then
      Info( InfoCharacterTable, 2,
            "OrthogonalE...: no embedding corresp. to characters" );
      return rec( irreducibles:= [], remainders:= reducibles );
    fi;
    irred:= Set( dec[1].irreducibles );
    for i in [2..Length(dec)] do
       IntersectSet( irred, dec[i].irreducibles );
    od;
    red:= ReducedClassFunctions( tbl, irred, reducibles );
    Append( irred, red.irreducibles );
    return rec( irreducibles:= irred, remainders:= red.remainders );
end );


#############################################################################
##
#F  DnLattice( <tbl>, <g1>, <y1> )
##
InstallGlobalFunction( DnLattice, function( tbl, g1, y1 )
    local
    # indices
      i, i1, j, j1, k, k1, l, next,
    # booleans
      empty, change, used, addable, SFIbool,
    # dimensions
      n,
    # help fields
      found, foundpos,
      z, nullcount, nullgenerate,
      maxentry, max, ind, irred, irredcount, red,
      blockcount, blocks, perm, addtest, preirred,
    # Gram matrix
      g, gblock,
    # characters
      y, y2,
    # variables for recursion
      root, rootcount, solution, ligants, ligantscount, begin,
      depth, choice, ende, sol,
    # functions
      callreduced, nullset, maxset, Search, Add, DnSearch, test;

    # counts zeroes in given line
    nullset := function( g, i )
    local j;

    nullcount[ i ] := 0;
    for j in [ 1..n ] do
       if g[ j ] = 0 then
          nullcount[ i ] := nullcount[ i ] + 1;
       fi;
    od;
    end;

    # searches line with most non-zero-entries
    maxset := function( )
    local i;

    maxentry := 1;
    max := n;
    for i in [ 1..n ] do
       if nullcount[ i ] < max then
          max := nullcount[ i ];
          maxentry := i;
       fi;
    od;
    end;

    # searches lines to add in order to produce zeroes
    Search := function( j )

    nullgenerate := 0;
    if g[ j ][ maxentry ] > 0 then
       for k in [ 1..n ] do
          if k <> maxentry and k <> j then
             if g[ maxentry ][ k ] <> 0 then
                if g[ j ][ k ] = g[ maxentry ][ k ] then
                   nullgenerate := nullgenerate + 1;
                else
                   nullgenerate := nullgenerate - 1;
                fi;
             fi;
          fi;
       od;
    else
       if g[ j ][ maxentry ] < 0 then
          for k in [ 1..n ] do
             if k <> maxentry and k <> j then
                if g[ maxentry ][ k ] <> 0 then
                   if g[ j ][ k ] = -g[ maxentry ][ k ] then
                      nullgenerate := nullgenerate + 1;
                   else
                      nullgenerate := nullgenerate - 1;
                   fi;
                fi;
             fi;
          od;
       fi;
    fi;
    if nullgenerate > 0 then
       change := true;
       Add( j, maxentry );
       j := j + 1;
    fi;
    end;

    # adds two lines/columns
    Add := function( i, j )
    local k;

       y[ i ] := y[ i ] - g[ i ][ j ] * y[ j ];
       g[ i ] := g[ i ] - g[ i ][ j ] * g[ j ];
       for k in [ 1..i-1 ] do
          g[ k ][ i ] := g[ i ][ k ];
       od;
       g[ i ][ i ] := 2;
       for k in [ i+1..n ] do
          g[ k ][ i ] := g[ i ][ k ];
       od;
    end;

    # backtrack-search for dn-lattice
    DnSearch := function( begin, depth, oldchoice )
    local connections, connect, i1, j1, choice, found;

    choice := ShallowCopy( oldchoice );
    if depth = 3 then
       # d4-lattice found !!!
       solution := 1;
       ende := true;
       if n > 4 then
          i1 := 0;
          found := false;
          while not found and i1 < n do
             i1 := i1 + 1;
             if i1 <> root[ j ] and i1 <> choice[ 1 ]
             and i1 <> choice[ 2 ] and i1 <> choice[ 3 ] then
                connections := 0;
                for j1 in [1..3] do
                   if gblock[ i1 ][ choice[ j1 ] ] <> 0 then
                      connections := connections + 1;
                      connect := choice[ j1 ];
                   fi;
                od;
                if connections = 1 then
                   found := true;
                   choice[ 4 ] := connect;
                   solution := solution + 1;
                fi;
             fi;
             i1 := i1 + 1;
          od;
       fi;
       sol := choice;
    else
       i1 := begin;
       while not ende and i1 <= ligantscount do
          found := true;
          for j1 in [1..depth] do
             if gblock[ ligants[ i1 ] ][ choice[ j1 ] ] <> 0 then
                found := false;
             fi;
          od;
          if found then
             depth := depth + 1;
             choice[ depth ] := ligants[ i1 ];
             DnSearch( i1 + 1, depth, choice );
             depth := depth - 1;
          else
             i1 := i1 + 1;
          fi;
          if ligantscount - i1 + 1 + depth < 3 then
             ende := true;
          fi;
       od;
    fi;
    end;

    test := function(z)
    # some tests for the found characters
    local result, IRS, SFI, i1, y1, ind, testchar;
    testchar := z/2;
    result := true;
    IRS := ForAll( testchar, x -> GaloisCyc(x,-1) = x );
    if IsBound( ComputedPowerMaps( tbl )[2] ) then
       if ForAll( ComputedPowerMaps( tbl )[2], IsInt ) then
          SFI := Indicator( tbl, [testchar], 2 )[1];
          SFIbool := true;
       else
          Info( InfoCharacterTable, 2,
                "DnLattice: 2nd power map not available or not unique,\n",
                "#I            cannot test with Indicator" );
          SFIbool := false;
       fi;
    else
      Info( InfoCharacterTable, 2,
            "DnLattice: 2nd power map not available\n",
            "#I            cannot test with Indicator" );
      SFIbool := false;
    fi;
    if SFIbool then
       if ForAny( testchar, x -> IsRat(x) and not IsInt(x) )
          or ScalarProduct( tbl, testchar, testchar ) <> 1
          or testchar[1] = 0
          or ( IRS and AbsInt( SFI ) <> 1 )
          or ( not IRS and SFI <> 0 ) then
         result := false;
       fi;
    else
       if ForAny( testchar, x -> IsRat(x) and not IsInt(x) )
          or ScalarProduct( tbl, testchar, testchar ) <> 1
          or testchar[1] = 0 then
         result := false;
       fi;
    fi;
    return result;
    end;

    # reduce whole lattice with the found irreducible
    callreduced := function()
    z[ 1 ] := z[ 1 ]/ 2 ;
    if ScalarProduct( tbl, z[ 1 ], z[ 1 ] ) = 1 then
       irredcount := irredcount + 1;
       if z[ 1 ][ 1 ] > 0 then
          irred[ irredcount ] := Character( tbl, z[ 1 ] );
       else
          irred[ irredcount ] := Character( tbl, -z[ 1 ] );
       fi;
       y1 := y{ [ blocks.begin[i] .. blocks.ende[i] ] };
       red := ReducedClassFunctions( tbl, z, y1 );
       Append( irred, List( red.irreducibles, x -> Character( tbl, x ) ) );
       irredcount := Length( irred );
       y2 := Concatenation( y2, red.remainders );
    fi;
    end;

    # check input parameters
    if not IsNearlyCharacterTable( tbl ) then
       Error( "first argument must be a nearly character table\n",
              "usage: DnLattice( <tbl>, <gram-matrix>, <reducibles> )" );
    fi;
    empty := false;
    if not IsEmpty( g1 ) then
      if IsList( g1 ) and IsBound( g1[1] ) and IsList( g1[1] ) then
        g := List( g1, ShallowCopy );
      else
        Error( "second argument must be Gram matrix of characters\n",
               "usage: DnLattice( <tbl>, <gram-matrix>, <reducibles> )" );
      fi;
    else
      empty := true;
    fi;
    if not IsEmpty( y1 ) then
      if IsList( y1 ) and IsBound( y1[1] ) and IsList( y1[1] ) then
        y := List( y1, ShallowCopy );
      else
        Error( "third argument must be list of reducible characters\n",
               "usage: DnLattice( <tbl>, <gram-matrix>, <reducibles> )" );
      fi;
    else
      empty := true;
    fi;
    y2        := [  ];
    irred     := [  ];

    if not empty then

    n := Length( y );
    for i in [1..n] do
       if g[i][i] <> 2 then
          Error( "reducible characters don't have norm 2\n",
                "usage: DnLattice( <tbl>, <gram-matrix>, <reducibles> )" );
       fi;
    od;
    # initialisations
    z         := [  ];
    used      := [  ];
    next      := [  ];
    nullcount := [  ];
    for i in [1..n] do
       used[i] := false;
    od;
    blocks := rec( begin := [ ], ende := [ ] );
    blockcount   := 0;
    irredcount   := 0;
    change       := true;
    while change do
       change := false;
       for i in [ 1..n ] do
          nullset( g[ i ], i );
       od;
       maxset( );
       while max < n-2 and not change do
          while maxentry <= n and not change do
             if nullcount[ maxentry ] <> max then
                maxentry := maxentry + 1;
             else
                j := 1;
                while j < maxentry and not change do
                   Search( j );
                   j := j + 1;
                od;
                j := maxentry + 1;
                while j <= n and not change do
                   Search( j );
                   j := j + 1;
                od;
                if not change then
                   maxentry := maxentry + 1;
                fi;
             fi;
          od;
          if not change then
             max := max + 1;
             maxentry := 1;
          fi;
       od;

    # 2 step-search in order to produce zeroes
    # 2_0_Box-Method
       change := false;
       i := 1;
       while i <= n and not change do
          while i <= n and nullcount[ i ] > n-3 do
             i := i + 1;
          od;
          if i <= n then
             j := 1;
             while j <= n and not change do
                while j <= n and g[ i ][ j ] <> 0 do
                   j := j + 1;
                od;
                if j <= n then
                   i1 := 1;
                   while i1 <= n and not change do
                      while i1 <= n
                      and ( i1 = i or i1 = j or g[ i1 ][ j ] = 0 ) do
                         i1 := i1 + 1;
                      od;
                      if i1 <= n then
                         addtest := g[ i ] - g[ i ][ i1 ] * g[ i1 ];
                         nullgenerate := 0;
                         addable := true;
                         for k in [ 1..n ] do
                            if addtest[ k ] = 0 then
                               nullgenerate := nullgenerate + 1;
                            else
                               if AbsInt( addtest[ k ] ) > 1 then
                                  addable := false;
                               fi;
                            fi;
                         od;
                         if addable then
                            nullgenerate := nullgenerate - nullcount[ i ];
                            for k in [ 1..n ] do
                               if k <> i and k <> j then
                                  if addtest[ k ]
                                     = addtest[ j ] * g[ j ][ k ] then
                                     if g[ j ][ k ] <> 0 then
                                        nullgenerate := nullgenerate + 1;
                                     fi;
                                  else
                                     if addtest[ k ] <> 0 then
                                        if g[ j ][ k ] = 0 then
                                           nullgenerate := nullgenerate - 1;
                                        else
                                           addable := false;
                                        fi;
                                     fi;
                                  fi;
                               fi;
                            od;
                            if nullgenerate > 0 and addable then
                               Add( i, i1 );
                               Add( j, i );
                               change := true;
                            fi;
                         fi;
                         i1 := i1 + 1;
                      fi;
                   od;
                   j := j + 1;
                fi;
             od;
             i := i + 1;
          fi;
       od;
    od;
    i := 1;
    j := 0;
    next[ 1 ] := 1;
    while j < n do
       blockcount := blockcount + 1;
       blocks.begin[ blockcount ] := i;
       l := 0;
       used[ next [ i ] ] := true;
       j := j + 1;
       y2[ j ] := y[ next [ i ] ];
       while l >= 0 do
          for k in [ 1..n ] do
             if g[ next[ i ] ][ k ] <> 0 and not used[ k ] then
                l := l + 1;
                next[ i + l ] := k;
                j := j + 1;
                y2[ j ] := y[ k ];
                used[ k ] := true;
             fi;
          od;
          i := i + 1;
          l := l - 1;
       od;
       blocks.ende[ blockcount ] := i - 1;
       k := 1;
       while k <= n and used[ k ] do
          k := k + 1;
       od;
       if k <= n then
          next[i] := k;
       fi;
    od;
    perm := PermList( next )^-1;
    for i in [1..n] do
       g[i] := Permuted( g[i], perm );
    od;
    g := Permuted( g, perm );
    y := y2;
    y2 := [  ];

    # search for d4/d5 - lattice
    for i in [1..blockcount] do
       n := blocks.ende[ i ] - blocks.begin[ i ] + 1;
       solution := 0;
       if n >= 4 then
          gblock := [  ];
          j1 := 0;
          for j in [ blocks.begin[ i ]..blocks.ende[ i ] ] do
             j1 := j1 + 1;
             gblock[ j1 ] := [  ];
             k1 := 0;
             for k in [ blocks.begin[ i ]..blocks.ende[ i ] ] do
                k1 := k1 + 1;
                gblock[ j1 ][ k1 ] := g[ j ][ k ];
             od;
          od;
          root      := [  ];
          rootcount := 0;
          for j in [1..n] do
             nullset( gblock[ j ], j );
             if nullcount[ j ] < n - 3 then
                rootcount := rootcount + 1;
                root[ rootcount ] := j;
             fi;
          od;
          j := 1;
          while solution = 0 and j <= rootcount do
             ligants := [  ];
             ligantscount := 0;
             for k in [1..n] do
                if k <> root[ j ] and gblock[ root[ j ] ][ k ] <> 0 then
                   ligantscount := ligantscount + 1;
                   ligants[ ligantscount ] := k;
                fi;
             od;
             begin := 1;
             depth := 0;
             choice := [  ];
             ende := false;
             DnSearch( begin, depth, choice );
             if solution > 0 then
                choice := sol;
             fi;
             j := j + 1;
          od;
       fi;

    # test of the found irreducibles
       if solution = 1 then
          # treatment of D4-lattice
          found := 0;
          preirred := y{ [ blocks.begin[i] .. blocks.ende[i] ] };
          z[1] := preirred[choice[1]] + preirred[choice[2]];
          if test(z[1]) then
             red := ReducedClassFunctions( tbl, preirred, [ z[1] ] );
             if ForAll( red.irreducibles, test ) then
                found := found + 1;
                foundpos := 1;
             fi;
          fi;
          z[2] := preirred[choice[1]] + preirred[choice[3]];
          if test(z[2]) then
             red := ReducedClassFunctions( tbl, preirred, [ z[2] ] );
             if ForAll( red.irreducibles, test ) then
                found := found + 1;
                foundpos := 2;
             fi;
          fi;
          z[3] := preirred[choice[2]] + preirred[choice[3]];
          if test(z[3]) then
             red := ReducedClassFunctions( tbl, preirred, [ z[3] ] );
             if ForAll( red.irreducibles, test ) then
                found := found + 1;
                foundpos := 3;
             fi;
          fi;
          if found = 1 then
             z := [z[foundpos]];
             callreduced();
          fi;

       else
          # treatment of D5-lattice
          if solution = 2 then
             if choice [ 1 ] <> choice [ 4 ] then
                z[ 1 ] := y[ blocks.begin[ i ] + choice[ 1 ] - 1 ];
                if choice [ 2 ] <> choice [ 4 ] then
                   z[ 1 ]
                        := z[ 1 ] + y[ blocks.begin[ i ] + choice[ 2 ] - 1 ];
                else
                   z[ 1 ]
                        := z[ 1 ] + y[ blocks.begin[ i ] + choice[ 3 ] - 1 ];
                fi;
             else
                z[ 1 ] := y[ blocks.begin[ i ] + choice[ 2 ] - 1 ]
                        + y[ blocks.begin[ i ] + choice[ 3 ] - 1 ];
             fi;
             found := 0;
             if test(z[1]) then
                callreduced();
             fi;
          else
            Append( y2, y{ [ blocks.begin[i] .. blocks.ende[i] ] } );
          fi;
       fi;
    od;

    if irredcount > 0 then
       g := MatScalarProducts( tbl, y2, y2 );
    fi;
    else
       # input was empty i.e. empty=true
       g := [];
    fi;
    return rec( gram:=g, remainders:=y2, irreducibles:=irred );
end );


#############################################################################
##
#F  DnLatticeIterative( <tbl>, <red> )
##
InstallGlobalFunction( DnLatticeIterative, function( tbl, red )
    local dnlat, red1, norms, i, reduc, irred, norm2, g;

    # check input parameters
    if not IsNearlyCharacterTable( tbl ) then
       Error( "first argument must be a nearly character table\n",
              "usage: DnLatticeIterative( <tbl>, <record or list> )" );
    fi;
    if not IsRecord( red ) and not IsList( red ) then
       Error( "second argument must be record or list\n",
              "usage: DnLatticeIterative( <tbl>, <record or list> )" );
    fi;
    if IsRecord( red ) and not IsBound( red.remainders ) then
       Error( "second record must contain a field 'remainders'\n",
              "usage: DnLatticeIterative( <tbl>, <record or list> )" );
    fi;
    if not IsRecord( red ) then
       red := rec( remainders:=red );
    fi;
    if not IsBound( red.norms ) then
       norms := List( red.remainders, x -> ScalarProduct( tbl, x, x ) );
    else
       norms := ShallowCopy( red.norms );
    fi;
    reduc := List( red.remainders, ShallowCopy );
    irred := [];
    repeat
       norm2 := [];
       for i in [1..Length( reduc )] do
          if norms[i] = 2 then
             Add( norm2, reduc[i] );
          fi;
       od;
       g := MatScalarProducts( tbl, norm2, norm2 );
       dnlat := DnLattice( tbl, g, norm2 );
       Append( irred, dnlat.irreducibles );
       red1:= ReducedClassFunctions( tbl, dnlat.irreducibles, reduc );
       reduc := red1.remainders;
       Append( irred, red1.irreducibles );
       norms:= List( reduc, x -> ScalarProduct( tbl, x, x ) );
    until dnlat.irreducibles=[] and red1.irreducibles=[];
    return rec( irreducibles:=irred, remainders:=reduc , norms := norms );
end );
