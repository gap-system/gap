#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Götz Pfeiffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for those functions that are needed to
##  compute and test possible permutation characters.
##


#############################################################################
##
#F  TestPerm1( <tbl>, <char> ) . . . . . . . . . . . . . . . .  test permchar
##
InstallGlobalFunction( TestPerm1, function(tbl, char)

   local i, pm;

   # TEST 1:
   for i in char do
      if i < 0 then
        return 1;
      fi;
   od;

   # TEST 2:
   for pm in ComputedPowerMaps( tbl ) do
     for i in [2..Length(char)] do
       if char[i] > char[pm[i]] then return 2; fi;
     od;
   od;

   return 0;
end );


#############################################################################
##
#F  TestPerm2( <tbl>, <char> ) . . . . . . . . . . . . . . . .  test permchar
##
InstallGlobalFunction( TestPerm2, function(tbl, char)

   local i, j, nccl, subord, tbl_orders, subclass, tbl_classes, subfak,
         prime, sum;

   char:= ValuesOfClassFunction( char );
   subord:= Size( tbl ) / char[1];
   if not IsInt(subord) then
      Info( InfoCharacterTable, 2, "-" );
      return 1;
   fi;
   nccl:= Length(char);

   # TEST 3:
   tbl_orders:= OrdersClassRepresentatives( tbl );
   for i in [2..nccl] do
      if char[i] <> 0 and subord mod tbl_orders[i] <> 0 then
        Info( InfoCharacterTable, 2, "=" );
        return 3;
      fi;
   od;

   # TEST 4:
   subclass:= [1];
   tbl_classes:= SizesConjugacyClasses( tbl );
   for i in [2..nccl] do
      subclass[i]:= (char[i] * tbl_classes[i]) / char[1];
      if not IsInt(subclass[i]) then
        Info( InfoCharacterTable, 2, "#" );
        return 4;
      fi;
   od;

   # TEST 5:
   subfak:= PrimeDivisors(subord);
   for prime in subfak do
      if subord mod prime^2 <> 0 then

        # Compute the number of elements of order $p$ in the
        # (hypothetical) subgroup $H$.
        sum:= 0;
        for j in [2..nccl] do
          if tbl_orders[j] = prime then
            sum:= sum + subclass[j];
          fi;
        od;

        # Check that the number of Sylow $s$ subgroups is an integer
        # that is congruent to $1$ modulo $p$.
        if (sum - prime + 1) mod (prime * (prime - 1)) <> 0 then
          Info( InfoCharacterTable, 2, ":" );
          return 5;
        fi;

        # Check that the number of Sylow $p$ subgroups in $H$ divides $|H|$.
        if subord mod (sum / (prime - 1)) <> 0 then
          Info( InfoCharacterTable, 2, ";" );
          return 5;
        fi;
      fi;
   od;

   return 0;
end );


#############################################################################
##
#F  TestPerm3( <tbl>, <permch> ) . . . . . . . . . . . . . . .  test permchar
##
InstallGlobalFunction( TestPerm3, function( tbl, permch )

    local i, j, nccl, fb, corbs, lc, phii, pi, orders, classes, good;

    fb      := [];
    lc      := [];
    phii    := [];
    orders  := OrdersClassRepresentatives( tbl );
    classes := SizesConjugacyClasses( tbl );
    nccl    := Length( orders );

    # Compute the values $`phii[i]' = [ N_G(g_i) : C_G(g_i) ]$,
    # store them only for one representative of each Galois family.
    for i in [ 1 .. nccl ] do
      if not IsBound( lc[i] ) then
        corbs:= ClassOrbit( tbl, i );
        lc[i]:= Length( corbs );
        for j in corbs do
          lc[j]:= lc[i];
        od;
        phii[i]:= Phi( orders[i] ) / lc[i];
      fi;
    od;

    # Check condition (h) for all characters $\pi$ in `permch',
    # i.e., $\pi(1) |N_G(g)|$ divides $\pi(g) |G|$ for all $g \in G$.
    for pi in permch do
      good:= true;
      for j in [ 2 .. nccl ] do
        if     2 < orders[j] and IsBound( phii[j] )
           and ( pi[j] * classes[j] ) mod ( pi[1] * phii[j] ) <> 0 then
          good:= false;
          break;
        fi;
      od;
      if good then
        AddSet( fb, pi );
      fi;
    od;

    # Return the list of characters that satisfy condition (h).
    return fb;
end );


##############################################################################
##
##  TestPerm4( <tbl>, <chars> )
##
##  Check whether the projections of <chars> to $p$-blocks of <tbl> satisfy
##  $|\pi_B(g)| \leq \pi_B(g^n) \leq \pi(g^n)$, for all $g\in G$ and positive
##  integers $n$ such that $g^n$ is a $p$-element of $G$.
##
##  In the case of defect $1$, it is also tried to identify the projective
##  cover $1_G + \lambda_p$ of the trivial character;
##  in this case it is checked whether $\lambda_p$ is a constituent of the
##  candidate $\pi$.
##  We use that $\lambda_p$ is a sum of irreducibles in the principal block
##  that coincide on $p$-regular classes,
##  and that $\lambda$ has the properties $\lambda_p(1) \equiv -1 \pmod{p}$
##  and $\lambda_p(g) = -1$ for each $p$-singular element $g \in G$.
##  (If $\lambda_p$ is not uniquely determined by these conditions then it is
##  checked whether at least one character with these properties is a
##  constituent of $\pi$.
##
InstallGlobalFunction( TestPerm4, function( tbl, chars )

    local nccl,
          irr,
          len,
          good,
          size,
          orders,
          p,
          bl,
          B,
          except,
          lambda,
          i,
          exp,
          n,
          j, k,
          proj,
          image;

    nccl:= NrConjugacyClasses( tbl );
    irr:= Irr( tbl );
    len:= Length( chars );
    good:= BlistList( [ 1 .. len ], [ 1 .. len ] );
    size:= Size( tbl );
    orders:= OrdersClassRepresentatives( tbl );

    for p in PrimeDivisors( Size( tbl ) ) do

      # Compute the distribution of characters to blocks.
      bl:= PrimeBlocks( tbl, p );

      # Apply (T8).
      if size mod p^2 <> 0 then

        # Get the rational irreducible characters in the principal block.
        B:= bl.block[ Position( irr, TrivialCharacter( tbl ) ) ];
        B:= irr{ Filtered( [ 1 .. nccl ], j -> bl.block[j] = B ) };

        # Try to identify the character $\lambda_p$
        # with the property that $1_G + \lambda_p$ is projective.
        # First form the orbit sums from which lambda is to be chosen.
        # (There is at most one nontrivial orbit of exceptional characters.)
        except:= Filtered( B, chi -> Conductor( chi ) mod p = 0 );
        if not IsEmpty( except ) then
          B:= Difference( B, except );
          Add( B, Sum( except ) );
        fi;
        lambda:= Filtered( B, chi -> ( chi[1] + 1 ) mod p = 0 );
        if 1 < Length( lambda ) then
          lambda:= Filtered( lambda, chi ->
                            ForAll( [ 1 .. nccl ],
                                i -> orders[i] mod p <> 0 or chi[i] = -1 ) );
        fi;

        # Check whether $\lambda_p$ is a constituent.
        for i in [ 1 .. Length( chars ) ] do
          if     good[i]
             and chars[i][1] mod p = 0
             and ForAll( lambda,
                     chi -> ScalarProduct( tbl, chi, chars[i] ) = 0 ) then

            Info( InfoCharacterTable, 1,
                  "TestPerm4: degree ", chars[i][1],
                  " fails to have lambda_",p," as a constituent" );
            good[i]:= false;

          fi;
        od;

      fi;

      # Now apply (T9).

      # `exp[i]' is either `false' (for `p'-regular elements)
      # or the smallest number s.t. the `exp[i]'-th power of an element
      # in class `i' is a `p'-element.
      exp:= [];
      for i in [ 1 .. nccl ] do
        n:= orders[i];
        if n mod p <> 0 then
          exp[i]:= false;
        else
          while n mod p = 0 do
            n:= n/p;
          od;
          exp[i]:= n;
        fi;
      od;

      for k in [ 1 .. Length( bl.defect ) ] do

        # Compute the projections $\pi_B$.
        B:= irr{ Filtered( [ 1 .. nccl ], j -> bl.block[j] = k ) };
        proj:= MatScalarProducts( tbl, B, chars ) * B;

        for i in [ 1 .. Length( chars ) ] do

          if good[i] then

            for j in [ 1 .. nccl ] do
              if exp[j] <> false and good[i] then
                if exp[j] = 1 then
                  image:= j;
                else
                  image:= PowerMap( tbl, exp[j], j );
                fi;
                while image <> 1 and good[i] do

                  if    ( not IsInt( proj[i][ image ] ) )
                     or proj[i][ image ] < 0 then

                    # $\pi_B(g^n)$ must be a nonnegative integer.
                    Info( InfoCharacterTable, 1,
                          "TestPerm4: degree ", chars[i][1],
                          " violates integrality for p = ", p,
                          ", class ", j );
                    good[i]:= false;

                  elif proj[i][ image ] > chars[i][ image ] then

                    # $\pi_B(g^n) \leq \pi(g^n)$ must hold.
                    Info( InfoCharacterTable, 1,
                          "TestPerm4: degree ", chars[i][1],
                          " violates 2nd ineq. for p = ", p,
                          ", class ", j );
                    good[i]:= false;

                  elif     IsInt( proj[i][j] )
                       and AbsInt( proj[i][j] ) > proj[i][ image ] then

                    # $|\pi_B(g)| \leq \pi_B(g^n)$ must hold.
                    Info( InfoCharacterTable, 1,
                          "TestPerm4: degree ", chars[i][1],
                          " violates 1st ineq. for p = ", p,
                          ", class ", j );
                    good[i]:= false;

                  fi;

                  image:= PowerMap( tbl, p, image );
                od;
              fi;
            od;

          fi;

        od;

      od;

    od;

    # Return the characters that satisfy the condition.
    return ListBlist( chars, good );
end );


##############################################################################
##
##  TestPerm5( <tbl>, <chars>, <modtbl> )
##
##  Check whether characters of degree divisible by the $p$-part of
##  the order of <tbl> are linear combinations of the projective
##  indecomposables.
##
InstallGlobalFunction( TestPerm5, function( tbl, chars, modtbl )

    local size,
          p,
          nccl,
          cand,
          irr,
          bl,
          pims,
          k,
          B,
          sol;

    size:= Size( tbl );
    p:= UnderlyingCharacteristic( modtbl );

    cand:= Filtered( chars, pi -> ( size / pi[1] ) mod p <> 0 );
    if IsEmpty( cand ) then
      return chars;
    fi;

    nccl:= NrConjugacyClasses( tbl );
    irr:= Irr( tbl );

    bl:= PrimeBlocks( tbl, p );
    pims:= [];
    for k in [ 1 .. Length( bl.defect ) ] do
      B:= irr{ Filtered( [ 1 .. nccl ], j -> bl.block[j] = k ) };
      Append( pims, TransposedMat( DecompositionMatrix( modtbl, k ) ) * B );
    od;

    # Decompose the candidates.
    sol:= Decomposition( pims, cand, "nonnegative" );

    sol:= Filtered( [ 1 .. Length( sol ) ], i -> sol[i] = fail );
    if not IsEmpty( sol ) then
      Info( InfoCharacterTable, 1,
            "TestPerm5: ",
            Length( sol ), " character(s) not decomposable into PIMs (p = ",
            p, ")" );
      sol:= cand{ sol };
      chars:= Filtered( chars, pi -> not pi in sol );
    fi;

    return chars;
end );


#############################################################################
##
#M  Inequalities( <tbl>, <chars>[, <option>] ) . . .
#M                                           projected system of inequalities
##
##  Supported for <option>: `"small"'
##
InstallMethod( Inequalities,
    [ IsOrdinaryTable, IsList ],
    function( tbl, chars )
    return Inequalities( tbl, chars, "" );
    end );

InstallMethod( Inequalities,
    [ IsOrdinaryTable, IsList, IsObject ],
    function( tbl, chars, option )
   local i, j, h, o, dim, nccl, ncha, c, X, dir, root, ineq, tuete,
         Conditor, Kombinat, other, mini, con, conO, conU, pos,
         proform, project;

   # local functions
   proform:= function(tuete, s, dir)
      local i, lo, lu, conO, conU, komO, komU, res;

      conO:= []; conU:= [];
      res:= 0;
      for i in [1..Length(tuete)] do
        if tuete[i][dir] < 0 then
          Add(conO, Kombinat[i]);
        elif tuete[i][dir] > 0 then
          Add(conU, Kombinat[i]);
        else
          res:= res + 1;
        fi;
      od;

      lo:= Length(conO); lu:= Length(conU);

      if s = dim+1 then
        return res + lo * lu;
      fi;

      for komO in conO do
        if Length(komO) = 1 then
          res:= res + lu;
        else
          for komU in conU do
            if Length(Union(komO, komU)) <= dim+3 - s then
              res:= res + 1;
            fi;
          od;
        fi;
      od;

      return res;
   end;

   project:= function(tuete, dir)
      local i, C, sum, com, lo, lu, conO, conU,
            lineO, lineU, lc, kombi, res;

      Info( InfoCharacterTable, 2, "project(", dir, ")" );

      conO:= []; conU:= [];
      res:= []; kombi:= [];
      for i in [1..Length(tuete)] do
        if tuete[i][dir] < 0 then
          Add(conO, rec(con:= tuete[i], kom:= Kombinat[i]));
          Add(Conditor[dir], tuete[i]);
        elif tuete[i][dir] > 0 then
          Add(conU, rec(con:= tuete[i], kom:= Kombinat[i]));
          Add(Conditor[dir], tuete[i]);
        else
          Add(res, tuete[i]); Add(kombi, Kombinat[i]);
        fi;
      od;

      lo:= Length(conO); lu:= Length(conU);

      Info( InfoCharacterTable, 2, lo, " ", lu );

      for lineO in conO do
        for lineU in conU do
          com:= Union(lineO.kom, lineU.kom);
          lc:= Length(com);
          if lc <= dim+3 - dir then
            sum:= lineU.con[dir] * lineO.con - lineO.con[dir] * lineU.con;
            sum:= Gcd(sum)^-1 * sum;
            if lc - Length(lineO.kom) = 1 or lc - Length(lineU.kom) = 1 then
              Add(res, sum); Add(kombi, com);
            else
              C:= List( ineq{ com }, x -> x{ [ dir .. dim+1 ] } );
              if RankMat(C) = lc-1 then
                Add(res, sum); Add(kombi, com);
              fi;
            fi;
          fi;
        od;
      od;
      Kombinat:= kombi;
      return res;
   end;

   nccl:= NrConjugacyClasses( tbl );
   X:= RationalizedMat( List( chars, ValuesOfClassFunction ) );

   c:= TransposedMat(X);

   # determine power conditions
   # ie: for each class find a root and replace column by difference.

   root:= ClassRoots(tbl);
   ineq:= [];   other:= [];  pos:= [];
   for i in [2..nccl] do
      if not c[i] in ineq then
         AddSet(ineq, c[i]);  Add(pos, i);
      fi;
   od;
   ineq:= [];
   for i in pos do
      if root[i] = [] then
        AddSet(ineq, c[i]);
        AddSet(other, c[i]);
      else
        AddSet(ineq, c[i] - c[root[i][1]]);
        for j in root[i] do
          AddSet(other, c[i] - c[j]);
        od;
      fi;
   od;
   ineq:= List(ineq, x->Gcd(x)^-1*x);
   other:= List(other, x->Gcd(x)^-1*x);

   ncha:= Length(X);

   dim:= Length(ineq);
   if dim <> Length(ineq[1])-1 then
      Error("nonregular problem");
   fi;

   Conditor:= List([1..dim+1], x->[]);
   Kombinat:= List([1..dim+1], x->[x]);
   tuete:= ineq;

   for i in Reversed([2..dim+1]) do
      dir:= 0;

      if option = "small" then

         # find optimal direction
         for j in [2..i] do
           o:= proform(tuete, i, j);
           if dir = 0 or o <= mini then
             mini:= o; dir:= j;
           fi;
         od;

         # make it the current one
         if dir <> i then
           for j in [i..ncha] do
             for con in Conditor[j] do
               h:= con[dir]; con[dir]:= con[i]; con[i]:= h;
             od;
           od;
           for con in tuete do
             h:= con[dir]; con[dir]:= con[i]; con[i]:= h;
           od;
           for con in other do
             h:= con[dir]; con[dir]:= con[i]; con[i]:= h;
           od;

           h:= X[dir]; X[dir]:= X[i]; X[i]:= h;
         fi;
      fi;

      # perform projection
      tuete:= project(tuete, i);

      # if regular, reinstall reference
      if Length(tuete) = i-2 then
         ineq:= tuete;
         dim:= i-2;
         Kombinat:= List([1..i-1], x->[x]);
         Info( InfoCharacterTable, 2, "REGULAR !!!" );
      fi;

   od;

   # don't use too many inequalities
   for i in [2..ncha] do
    if Length(Conditor[i]) > 1 then
      conO:= Filtered(Conditor[i], x->x[i] < 0);
      conU:= Filtered(Conditor[i], x->x[i] > 0);
      if Length(conO) > i then
        conO:= conO{ [1..i] };
      fi;
      if Length(conU) > i then
        conU:= conU{ [1..i] };
      fi;
      Conditor[i]:= Union(conO, conU);
    fi;
   od;

   # but don't forget original conditions
   for con in other do
      i:= ncha;
      while con[i] = 0 do i:= i-1; od;
      AddSet(Conditor[i], con);
   od;

   return rec(obj:= X, Conditor:= Conditor);
    end );


#############################################################################
##
#F  Permut( <tbl>, <arec> )
##
##  The properties (g), (h), and (j) are checked explicitly for each
##  candidate that is produced,
##  the properties (a)--(e) are forced by the construction of the
##  candidates,
##  and the properties (f) and (i) are consequences of (b) and (e).
##
InstallGlobalFunction( Permut, function( tbl, arec )
    local tbl_size, permel, sortedchars,
          a, amin, amax, c, ncha, i, j, permch,
          Conditor, cond, X, minR, maxR,
          s,
          total, free, const, lowerBound, upperBound,
          solveKnot, nextLevel, insertValue, suche;

    # Check the arguments.
    if not IsOrdinaryTable( tbl ) then
       Error( "<tbl> must be complete character table" );
    fi;

    tbl_size:= Size( tbl );

    if IsBound(arec.ineq) then
      permel:= arec.ineq;
    else
      sortedchars:= SortedCharacters( tbl, Irr( tbl ), "degree" );
      permel:= Inequalities( tbl, sortedchars );
    fi;

    # local functions
    lowerBound:= function(cond, const, free, s)
       local j, unten;

       unten:= -const;
       for j in [2..s-1] do
         if free[j] then
           if cond[j] < 0 then
             unten:= unten - amin[j]*cond[j];
           elif cond[j] > 0 then
             unten:= unten - amax[j]*cond[j];
           fi;
         fi;
       od;
       if unten <= 0 then return 0;
       else return QuoInt(unten-1, cond[s])+1;
       fi;
    end;

    upperBound:= function(cond, const, free, s)
       local j, oben;
       oben:= const;
       for j in [2..s-1] do if free[j] then
           if cond[j] < 0 then
             oben:= oben + amin[j]*cond[j];
           elif cond[j] > 0 then
             oben:= oben + amax[j]*cond[j];
           fi;
       fi;od;
       if oben < 0 then return -1;
       else return QuoInt(oben, -cond[s]);
       fi;
    end;

    nextLevel:= function(const, free)
       local h, i, c, con, cond, unten, oben, maxu, mino,
             unique, first, mindeg, maxdeg;

       unique:= [];
       for h in [2..ncha] do
         cond:= Conditor[h];
         c:= const[h];
        if free[h] then
          # compute amin, amax
          if not IsBound(first) then
            first:= h;
          fi;
          maxu:= 0;
          mino:= tbl_size;
          for i in [1..Length(cond)] do
            if cond[i][h] > 0 then
              maxu:= Maximum(maxu, lowerBound(cond[i], const[h][i], free, h));
            else
              mino:= Minimum(mino, upperBound(cond[i], const[h][i], free, h));
            fi;
          od;

          amin[h]:= maxu;
          amax[h]:= mino;
          if mino < maxu then
            return h;
          fi;

          if mino = maxu then AddSet(unique, h); fi;
        else

          if IsBound(first) then
          # interpret inequalities for lower steps !
            for i in [1..Length(cond)] do
              con:= cond[i];
              s:= h-1;
              while s > 1  and (not free[s] or con[s] = 0) do
                s:= s-1;
              od;
              if s > 1 then
                if con[s] > 0 then
                  unten:= lowerBound(con, c[i], free, s);
                  amin[s]:= Maximum(amin[s], unten);
                else
                  oben:= upperBound(con, c[i], free, s);
                  amax[s]:= Minimum(amax[s], oben);
                fi;
                if amin[s] > amax[s] then return s;
                elif amin[s] = amax[s] then AddSet(unique, s);
                fi;
              fi;
            od;

          fi;
        fi;
       od;

       maxdeg:= 1;
       mindeg:= 1;
       for i in [2..ncha] do
          maxdeg:= maxdeg + amax[i] * X[i][1];
          mindeg:= mindeg + amin[i] * X[i][1];
       od;
       if minR > maxdeg or maxR < mindeg then
         return 0;
       fi;

       if unique <> [] then return unique;
       else return first; fi;

    end;

    insertValue:= function(const, s)
       local i, j, c;

       const:= List( const, ShallowCopy );

       for i in [s..ncha] do
          c:= const[i];
          for j in [1..Length(c)] do
            c[j]:= c[j] + a[s]*Conditor[i][j][s];
          od;
       od;

       return const;
    end;

    solveKnot:= function(const, free)
       local i, s, char;

       free:= ShallowCopy(free);
       if Set(free) = [false] then
         total:= total+1;
         char:= X[1];
         for j in [2..ncha] do
           char:= char + a[j] * X[j];
         od;
         if TestPerm2(tbl, char) = 0 then
           Add(permch, char);
           Info( InfoCharacterTable, 2, Length(permch), a, "\n", char );
         fi;
       else
         s:= nextLevel(const, free);
         if IsList(s) then
           for i in s do
             free[i]:= false;
             a[i]:= amin[i];
             const:= insertValue(const, i);
           od;
           solveKnot(const, free);
           elif s > 0 then
             for i in [amin[s]..amax[s]] do
               a[s]:= i;
               amin[s]:= i;
               amax[s]:= i;
               free[s]:= false;
               solveKnot(insertValue(const, s), free);
             od;
           fi;
       fi;
    end;

    total:= 0;
    X:= permel.obj;
    permch:= [];

    ncha:= Length(X);

    a:= [1];

    if IsBound(arec.degree) then

       minR:= Minimum(arec.degree); maxR:= Maximum(arec.degree);
       amax:= [1]; amin:= [1];
       Conditor:= permel.Conditor;
       free:= List(Conditor, ReturnTrue);
       free[1]:= false;
       const:= List(Conditor, x-> List(x, y->y[1]));
       solveKnot(const, free);

       # The result list may contain also some characters of degree
       # different from the desired ones.
       # We remove these characters.
       permch:= Filtered( permch, x -> x[1] in arec.degree );

    else

       suche:= function(s)
          local unten, oben, i, j, char,
                maxu, mino;

          unten:= [];
          oben:= [];

          maxu:= 0;

          for i in [1..Length(Conditor[s].u)] do
            unten:= 0;
            for j in [1..s-1] do
              unten:= unten - a[j]*Conditor[s].u[i][j];
            od;
            if unten <= 0 then
              unten:= 0;
            else
              unten:= QuoInt(unten-1, Conditor[s].u[i][s]) + 1;
            fi;

            maxu:= Maximum(maxu, unten);
          od;
          for i in [1..Length(Conditor[s].o)] do
            oben:= 0;
            for j in [1..s-1] do
              oben:= oben + a[j]*Conditor[s].o[i][j];
            od;
            if oben < 0 then
              oben:= -1;
            else
              oben:= QuoInt(oben, -Conditor[s].o[i][s]);
            fi;
            if not IsBound(mino) then
              mino:= oben;
            else
              mino:= Minimum(mino, oben);
            fi;
          od;

          for i in [maxu..mino] do
            a[s]:= i;
            if s < ncha then
              suche(s+1);
            else
              total:= total+1;
              char:= a * X;
              if TestPerm2(tbl, char) = 0 then
                Add(permch, char);
                Info( InfoCharacterTable, 2, Length(permch), a, "\n", char );
              fi;
            fi;
          od;
          a[s]:= 0;
       end;

       Conditor:= [];
       for i in [1..ncha] do
         Conditor[i]:= rec(o:= Filtered(permel.Conditor[i], x->x[i] < 0),
                           u:= Filtered(permel.Conditor[i], x->x[i] > 0));
       od;

       suche(2);

    fi;

    # Check condition (h).
    permch:= TestPerm3( tbl, permch );

    Info( InfoCharacterTable, 2,"Total number of tested Characters:", total );
    Info( InfoCharacterTable, 2,"Surviving:      ", Length(permch) );

    return List( permch, vals -> Character( tbl, vals ) );;
end );


#############################################################################
##
#F  PermBounds( <tbl>, <degree>[, <ratirr>] )  .  boundary points for simplex
##
InstallGlobalFunction( PermBounds, function( arg )
   local tbl, degree, X, irreds, i, j, dim, nccl, ncha, c, root,
         ineq, other, rho, pos, vec, deglist, point;

   tbl:= arg[1];
   degree:= arg[2];
   if IsBound( arg[3] ) then
     X:= arg[3];
   else
     # The trivial character is expected to be the first one.
     # So sort the irreducibles, if necessary.
     irreds:= List( Irr( tbl ), ValuesOfClassFunction );
     if not ForAll( irreds[1], x -> x = 1 ) then
       irreds:= SortedCharacters( tbl, irreds, "degree" );
     fi;
     X:= RationalizedMat( irreds );
   fi;

   nccl:= NrConjugacyClasses( tbl );
   c:= TransposedMat(X);

   # determine power conditions
   # i.e.: for each class find a root and replace column by difference.

   root:= ClassRoots(tbl);
   ineq:= [];   other:= [];  pos:= [];
   for i in [2..nccl] do
      if not c[i] in ineq then
         AddSet(ineq, c[i]);  Add(pos, i);
      fi;
   od;
   ineq:= [];
   for i in pos do
      if root[i] = [] then
        AddSet(ineq, c[i]);
        AddSet(other, c[i]);
      else
        AddSet(ineq, c[i] - c[root[i][1]]);
        for j in root[i] do
          AddSet(other, c[i] - c[j]);
        od;
      fi;
   od;
   ineq:= List(ineq, x->Gcd(x)^-1*x);
   other:= List(other, x->Gcd(x)^-1*x);

   ncha:= Length(X);

   dim:= Length(ineq);
   if dim <> Length(ineq[1])-1 then
      Error("nonregular problem");
   fi;

   # now correct inequalities ?
   vec:= List(ineq, x->-x[1]);
   ineq:= List(ineq, x-> x{ [2..dim+1] } );

   # determine boundary points
   deglist:= List( X{ [2..ncha] }, x->x[1]);
   Add(ineq, deglist);
   Add(vec, degree-1);

   point:= MutableTransposedMat(ineq);
   Add(point, -vec);

   point:= point^-1;

   dim:= Length(point[1]);

   rho:= point[dim][dim]^-1 * point[dim]{ [1..dim-1] };
   point:= List( point, x-> x[dim]^-1 * x{ [1..dim-1] } ){ [1..dim-1] };
#T ?

   return rec(obj:= X, point:= point, rho:= rho, other:= other);

end );


#############################################################################
##
#F  PermComb( <tbl>, <arec> ) . . . . . . . . . . . .  permutation characters
##
##  The properties (b), (d), (g), (h), and (j) are checked explicitly for
##  each candidate that is produced,
##  the properties (a), (c), and (e) are forced by the construction of the
##  candidates,
##  and the properties (f) and (i) are consequences of (b) and (e).
##
InstallGlobalFunction( PermComb, function( tbl, arec )

   local irreds,        # irreducible characters of `tbl'
         newirreds,     # shallow copy of `irreds'
         perm,          # permutation of constituents
         mindeg,        # list of minimal multiplicities of constituents
         maxdeg,        # list of maximal multiplicities of constituents
         lincom,        # local function, backtrack
         prep,
         X,             # possible constituents
         xdegrees,      # degrees of the characters in `X'
         point,
         rho,
         permch,
         Constituent,
         maxList,
         minList;

   # The trivial character is expected to be the first one.
   # So sort the irreducibles, if necessary.
   irreds:= List( Irr( tbl ), ValuesOfClassFunction );
   if not ForAll( irreds[1], x -> x = 1 ) then

     newirreds:= SortedCharacters( tbl, irreds, "degree" );
     perm:= Sortex( ShallowCopy( irreds ) )
            / Sortex( ShallowCopy( newirreds ) );
     irreds:= newirreds;
     if IsBound( arec.bounds ) and IsList( arec.bounds ) then
       arec:= ShallowCopy( arec );
       arec.bounds:= Permuted( arec.bounds, perm );
     fi;

   fi;

   maxList:= function(list)
      local i, col, max;
      max:= [];
      for i in [1..Length(list[1])] do
         col:= Maximum(List(list, x->x[i]));
         Add(max, Int(col));
      od;
      return max;
   end;

   minList:= function(list)
      local i, col, min;
      min:= [];
      for i in [1..Length(list[1])] do
         col:= Minimum(List(list, x->x[i]));
         if col <= 0 then
            Add(min, 0);
         elif IsInt(col) then
            Add(min, col);
         else
            Add(min, Int(col)+1);
         fi;
      od;
      return min;
   end;

   lincom:= function()
      local i, j, k, a, d, ncha, comb, mdeg, maxb, searching, char;

      ncha:= Length(xdegrees);
      mdeg:= List([1..ncha], x->0);
      comb:= List([1..ncha], x->0);
      maxb:= [];
      for i in [1..ncha-1] do
         maxb[i]:= 0;
         for j in [2..i] do
           maxb[i]:= maxb[i] + xdegrees[j] * maxdeg[j];
         od;
#T improve! (maxb[i]:= maxb[i-1] + xdegrees[j] * maxdeg[j];)
      od;
      d:= arec.degree - Constituent[1];
      k:= ncha - 1;
      searching:= true;

      while searching do
         for j in Reversed([1..k]) do
           a:= d - mdeg[j+1] - maxb[j];
           if a <= 0 then
             comb[j+1]:= 0;
           else
             comb[j+1]:= Minimum(QuoInt(a-1, xdegrees[j+1])+1, maxdeg[j+1]);
           fi;
           mdeg[j]:= mdeg[j+1] + comb[j+1] * xdegrees[j+1];
         od;

         if mdeg[1] = d then
           char:= Constituent + comb * X;
           if TestPerm1( tbl, char ) = 0 and TestPerm2( tbl, char ) = 0 then
             Add( permch, char );
             Info( InfoCharacterTable, 2, Length(permch), comb, "\n", char );
#T ??
           else
             Info( InfoCharacterTable, 2, "-" );
#T ??
           fi;
         fi;

         i:= 3;
         while i <= ncha and
           (comb[i] >= maxdeg[i] or mdeg[i-1]+ xdegrees[i] > d) do
           i:= i+1;
         od;
         if i <= ncha then
            mdeg[i-1]:= mdeg[i-1] + xdegrees[i];
            comb[i]:= comb[i] + 1;
            k:= i-2;
         else
           searching:= false;
#T just return, leave out `searching'!
         fi;
      od;
   end;

   if IsBound(arec.bounds) then
     prep:= arec.bounds;
     if prep = false then
       X:= RationalizedMat( irreds );
     else
       X:= prep.obj;
       rho:= Size( tbl ) ^-1 * (List(prep.point, x->prep.rho) - prep.point);
     fi;
   else
     X:= RationalizedMat( irreds );
     prep:= PermBounds( tbl, 0, X );
     rho:= Size( tbl ) ^-1 * (List(prep.point, x->prep.rho) - prep.point);
   fi;

   xdegrees:= List(X, x->x[1]);
   permch:= [];

   # Compute bounds for the multiplicities of the constituents.
   # (The trivial character *must* have multiplicity $1$.)
   if IsRecord( prep ) then

      # Compute minimal and maximal multiplicities from the info in `prep'.
      point:= prep.point + arec.degree * rho;
      maxdeg:= [1];
      Append(maxdeg, maxList(point));
      mindeg:= [1];
      Append(mindeg, minList(point));

   else

      # The maximal multiplicity of $\psi$ in $\pi$ is bounded
      # by $\psi(1)/[\psi,\psi]$ and by $(\pi(1)-1)/\psi(1)$.
      maxdeg:= List( [ 1 .. Length( xdegrees ) ],
                   i -> Minimum( xdegrees[i],
                                 QuoInt( arec.degree - 1, xdegrees[i] ) ) );
      maxdeg[1]:= 1;
      mindeg:= List( X, x -> 0 );
      mindeg[1]:= 1;

   fi;

   # Explicit upper bounds for the maximal multiplicities are prescribed.
   if IsBound( arec.maxmult ) then
      if Length( maxdeg ) <> Length( arec.maxmult ) then
        Error( "<arec>.maxmult corresponds to the rat. irred. characters" );
      fi;
      maxdeg:= List( [ 1 .. Length( maxdeg ) ],
                   i -> Minimum( maxdeg[i], arec.maxmult[i] ) );
   fi;

   # `mindeg' prescribes a constituent.
   Constituent:= mindeg * X;
   maxdeg:= maxdeg - mindeg;

   lincom();

   # Check condition (h).
   permch:= TestPerm3( tbl, permch );

   Sort( permch );
   return List( permch, values -> Character( tbl, values ) );
end );


#############################################################################
##
#F  PermCandidates( <tbl>, <characters>, <torso>, <all> )
##
##  The properties (a) and (j) are checked explicitly for each candidate that
##  is produced,
##  the properties (b), (c), (e), (g), (h), and (i) are forced by the
##  construction of the candidates,
##  the property (f) --as well as (i)-- is a consequence of (b) and (e),
#T  and property (d) could and should in principle be forced by construction,
#T  but is checked afterwards.
##
InstallGlobalFunction( PermCandidates,
    function( tbl, characters, torso, all )

    local tbl_classes,         # attribute of `tbl'
          tbl_size,            # attribute of `tbl'
          ratchars,            # list of all rational irreducible characters
          consider_candidate,  # function to check each candidate
          orders,              # list of representative orders of `tbl'
          tbl_centralizers,    # attribute of `tbl'
          i, chi, matrix, fusion, moduls, divs, normindex, candidate,
          classes, nonzerocol,
          possibilities,       # list of candidates already found
          rest, images, uniques,
          nccl, min_anzahl, min_class, erase_uniques, impossible,
          evaluate, first, localstep,
          remain, ncha, pos, fusionperm, newimages, oldrows, newmatrix,
          step, erster, descendclass, j, row;

    tbl_classes:= SizesConjugacyClasses( tbl );
    tbl_size:= Size( tbl );

    if all = true then
      ratchars:= List( characters, ValuesOfClassFunction );
    else
      ratchars:= RationalizedMat( List( Irr( tbl ), ValuesOfClassFunction ) );
    fi;

    # We know that `genchar' is a generalized character,
    # since it is in the span of `characters', modulo the generalized
    # characters that are nonzero on exactly one Galois family of classes.
    consider_candidate:= function( genchar )

      local i, chi, cand;

      # Check condition (a),
      # i.e., the scalar products with `ratchars' are nonnegative.
      cand:= [];
      for i in [ 1 .. Length( genchar ) ] do
        cand[i]:= genchar[i] * tbl_classes[i];
      od;
#T better: once multiply all in `ratchars' with the class lengths!
      for chi in ratchars do
        if cand * chi < 0 then
          return false;
        fi;
      od;

      # Check the properties (d) and (j) of possible permutation characters,
      # which are not guaranteed by the construction.
#T some others are guaranteed but are tested here again ...
      if TestPerm1( tbl, genchar ) = 0 and TestPerm2( tbl, genchar ) = 0 then
        Add( possibilities, genchar );
      fi;

    end;

    # step 1: check and improve input
    if not IsInt( torso[1] ) or torso[1] <= 0 then     # degree
      Error( "degree must be positive integer" );
    elif tbl_size mod torso[1] <> 0 then
      return [];
    fi;

    # Force property (g) of possible permutation characters.
    # ($\pi(g) = 0$ if the order of $g$ does not divide $|G|/\pi(1)$.)
    orders:= OrdersClassRepresentatives( tbl );
    for i in [ 1 .. Length( characters[1] ) ] do
      if ( tbl_size / torso[1] ) mod orders[i] <> 0 then
        if IsBound( torso[i] ) and IsInt( torso[i] ) and torso[i] <> 0 then
          Error( "value must be zero at class ", i );
        fi;
        torso[i]:= 0;
      fi;
    od;

    # In all cases except one,
    # only constituents of degree less than the desired degree are allowed.
    matrix:= [];
    for chi in characters do
      if chi[1] < torso[1] then
        AddSet( matrix, chi );
      fi;
    od;

    # (Of course the trivial character itself is the exception.)
    if IsEmpty( matrix ) then
      if ForAll( torso, x -> x = 1 ) then
        return [ TrivialCharacter( tbl ) ];
      else
        return [];
      fi;
    fi;

    # The computations in each column are done modulo the centralizer
    # order of this column.
    # More precisely, we may choose the largest centralizer order for
    # all those columns of the character table that correspond to the
    # given column of `matrix'.
    tbl_centralizers:= SizesCentralizers( tbl );
    matrix:= CollapsedMat( matrix, [ ] );
    fusion:= matrix.fusion;
    matrix:= matrix.mat;
    moduls:= [];
    for i in [ 1 .. Length( fusion ) ] do
      if IsBound( moduls[ fusion[i] ] ) then
        moduls[ fusion[i] ]:= Maximum( moduls[ fusion[i] ],
                                       tbl_centralizers[i] );
#T Would Lcm be allowed?
      else
        moduls[ fusion[i] ]:= tbl_centralizers[i];
      fi;
    od;

    # Force property (h) of possible permutation characters,
    # i.e., $\pi(1) |N_G(g)|$ divides $\pi(g) |G|$ for all $g \in G$.
    # (This is equivalent to the condition that
    # $\pi(1) / \gcd( \pi(1), [ G : N_G(g) ] )$ divides $\pi(g)$.)
    divs:= [ torso[1] ];
    for i in [ 2 .. Length( fusion ) ] do
      normindex:= ( tbl_classes[i] * Length( ClassOrbit( tbl, i ) ) )
                                                         / Phi( orders[i] );
      if IsBound( divs[ fusion[i] ] ) then
        divs[ fusion[i] ]:= Lcm( divs[ fusion[i] ],
                                 torso[1] / GcdInt( torso[1], normindex ) );
      else
        divs[ fusion[i] ]:= torso[1] / GcdInt( torso[1], normindex );
      fi;
    od;

    candidate:= [];
    nonzerocol:= [];
    classes:= [];
    for i in [ 1 .. Length( moduls ) ] do
      candidate[i]:= 0;
      nonzerocol[i]:= true;
      classes[i]:= 0;
    od;

    for i in [ 1 .. Length( fusion ) ] do
      classes[ fusion[i] ]:= classes[ fusion[i] ] + tbl_classes[i];
    od;

    # Initialize the global list of all possible permutation characters.
    possibilities:= [];

    # The scalar product of the trivial character with a transitive
    # permutation character is $1$,
    # this yields an upper bound on the values that are not yet known.
    # We subtract the known values from `Size( tbl )'.
    # (If there is a contradiction, we return an empty list.)
    rest:= tbl_size;
    images:= [];
    uniques:= [];
    for i in [ 1 .. Length( fusion ) ] do
      if IsBound( torso[i] ) and IsInt( torso[i] ) then
        if IsBound( images[ fusion[i] ] ) then
          if torso[i] <> images[ fusion[i] ] then

            # Different values are prescribed for identified columns.
            return [];

          fi;
        else
          images[ fusion[i] ]:= torso[i];
          AddSet( uniques, fusion[i] );
          rest:= rest - classes[ fusion[i] ] * torso[i];
          if rest < 0 then
            return [];
          fi;
        fi;
      fi;
    od;
    nccl:= Length( moduls );

    Info( InfoCharacterTable, 2, "PermCandidates: input checked" );

    # step 2: first elimination before backtrack:

    erase_uniques:= function( uniques, nonzerocol, candidate, rest )

    # eliminate all unique columns, adapt nonzerocol;
    # then look if other columns become unique or if a contradiction occurs;
    # also look at which column the least number of values is left

    local i, j, extracted, col, row, quot, val, ggt, a, b, k, u, anzahl,
          firstallowed, step, gencharacter, shrink;

    extracted:= [];
    while uniques <> [] do
      for col in uniques do
        if col < 0 then         # nonzero entries in `col' already eliminated
          col:= -col;
          candidate[ col ]:= ( candidate[ col ] + images[ col ] )
                             mod moduls[ col ];
          row:= fail;
        else                    # eliminate nonzero entries in `col'
          candidate[ col ]:= ( candidate[ col ] + images[ col ] )
                             mod moduls[ col ];
          row:= StepModGauss( matrix, moduls, nonzerocol, col );

          # delete zero rows:
          shrink:= [];
          for i in matrix do
            if PositionNonZero( i ) <= Length( i ) then
#T better call IsZero?
              Add( shrink, i );
            fi;
          od;
          matrix:= shrink;
        fi;
        if row <> fail then
          Add( extracted, row );
          quot:= candidate[ col ] / row[ col ];
          if not IsInt( quot ) then
            impossible:= true;
            return extracted;
          fi;
          for j in [ 1 .. nccl ] do
            if nonzerocol[j] then
              candidate[j]:= ( candidate[j] - quot * row[j] ) mod moduls[j];
            fi;
          od;
        elif candidate[col] <> 0 then
          impossible:= true;
          return extracted;
        fi;
        nonzerocol[col]:= false;
      od;
      min_anzahl:= infinity;
      uniques:= [];

      # compute the number of possible values `x' for each class `i'.
      # `x' must be smaller or equal `Minimum( rest / classes[i], torso[1] )',
      #             divisible by `divs[i]' and
      #             congruent `-candidate[i]' modulo the Gcd of column `i'.
      for i in [ 1 .. nccl ] do
        if nonzerocol[i] then
          val:= moduls[i];
          for j in matrix do val:= GcdInt( val, j[i]); od;  # the Gcd of `i'
          # zerocol iff val = moduls[i]
          first:= ( - candidate[i] ) mod val;  # the first possible value
                                                    # in the case `divs[i] = 1'
          if divs[i] = 1 then
            localstep:= val;          # all values are
                                      # `first, first + val, first + 2*val ..'
          else
            ggt:= Gcdex( divs[i], val );
            a:= ggt.coeff1;
            ggt:= ggt.gcd;
            if first mod ggt <> 0 then   # ggt divides `divs[i]' and hence `x';
                                         # since ggt divides `val', which must
                                         # divide `( x + candidate[i] )',
                                         # we must have ggt dividing `first'
              impossible:= true;
              return extracted;
            fi;
            localstep:= Lcm( divs[i], val );
            first:= ( first * a * divs[i] / ggt ) mod localstep;
                                         # satisfies the required congruences
                                         # (and that is enough here)
          fi;
          anzahl:= Int( ( Minimum( Int( rest[1] / classes[i] ), torso[1] )
                          - first + localstep ) / localstep );
          if anzahl <= 0 then       # contradiction
            impossible:= true;
            return extracted;
          elif anzahl = 1 then      # unique
            images[i]:= first;
            if val = moduls[i] then     # no elimination necessary
                                        # (the column consists of zeroes)
              Add( uniques, -i );
            else
              Add( uniques, i );
            fi;
            rest[1]:= rest[1] - classes[i] * images[i];
          elif anzahl < min_anzahl then
            min_anzahl:= anzahl;
            step:= localstep;
            firstallowed:= first;
            min_class:= i;
          fi;
        fi;
      od;
    od;
    if min_anzahl = infinity then
      if rest[1] = 0 then
        consider_candidate( images{ fusion } );
      fi;
      impossible:= true;
    else
      images[ min_class ]:= rec( firstallowed:= firstallowed, # first value
                                 step:= step,                 # step
                                 anzahl:= min_anzahl );       # no. of values
      impossible:= false;
    fi;
    return extracted;
    # impossible = true: calling function will return from backtrack
    # impossible = false: then min_class < infinity, and images[ min_class ]
    #           contains the information for descending at min_class
    end;

    rest:= [ rest ];
    erase_uniques( uniques, nonzerocol, candidate, rest );

    # Here we may forget the extracted rows,
    # later in the backtrack they must be appended after each return.

    rest:= rest[1];
    if impossible then
      return List( possibilities, vals -> Character( tbl, vals ) );
    fi;

    Info( InfoCharacterTable, 2,
          "PermCandidates: unique columns erased, there are ",
          Number( nonzerocol, x -> x ), " columns left,\n",
          "#I    the number of constituents is ", Length( matrix ), "." );

    # step 3: collapse

    remain:= Filtered( [ 1 .. nccl ], x -> nonzerocol[x] );
    for i in [ 1 .. Length( matrix ) ] do
      matrix[i]:= matrix[i]{ remain };
    od;
    candidate:=  candidate{ remain };
    divs:=       divs{ remain };
    nonzerocol:= nonzerocol{ remain };
    moduls:=     moduls{ remain };
    classes:=    classes{ remain };
    matrix:= ModGauss( matrix, moduls );
    ncha:= Length( matrix );
    pos:= 1;
    fusionperm:= [];
    newimages:= [];
    for i in remain do
      fusionperm[i]:= pos;
      if IsBound( images[i] ) then
        newimages[ pos ]:= images[i];
      fi;
      pos:= pos + 1;
    od;
    min_class:= fusionperm[ min_class ];
    for i in Difference( [ 1 .. nccl ], remain ) do
      fusionperm[i]:= pos;
      newimages[ pos ]:= images[i];
      pos:= pos + 1;
    od;
    images:= newimages;
    fusion:= CompositionMaps( fusionperm, fusion );
    nccl:= Length( nonzerocol );

    Info( InfoCharacterTable, 2,
          "PermCandidates: known columns physically deleted,\n",
          "#I    a backtrack search will be needed" );

    # step 4: backtrack

    evaluate:= function( candidate, rest, nonzerocol, uniques )
    local i, j, row, extracted, step, erster, descendclass;
    rest:= [ rest ];
    extracted:= erase_uniques( [ uniques ], nonzerocol, candidate, rest );
    rest:= rest[1];
    if impossible then
      return extracted;
    fi;
    descendclass:= min_class;
    step:= images[ descendclass ].step;    # spalten-ggt
    erster:= images[ descendclass ].firstallowed;
    rest:= rest + ( step - erster ) * classes[ descendclass ];
    for i in [ 1 .. min_anzahl ] do
      images[ descendclass ]:= erster + (i-1) * step;
      rest:= rest - step * classes[ descendclass ];
      oldrows:= evaluate( ShallowCopy( candidate ), rest,
                          ShallowCopy( nonzerocol ), descendclass );
      Append( matrix, oldrows );
      if Length( matrix ) > ( 3 * ncha ) / 2 then
        newmatrix:= [];         # matrix:= ModGauss( matrix, moduls );
        for j in [ 1 .. Length( matrix[1] ) ] do
          if nonzerocol[j] then
            row:= StepModGauss( matrix, moduls, nonzerocol, j );
            if row <> fail then Add( newmatrix, row ); fi;
          fi;
        od;
        matrix:= newmatrix;
      fi;
    od;
    return extracted;
    end;

    #

    step:= images[min_class].step;      # spalten-ggt
    erster:= images[min_class].firstallowed;
    descendclass:= min_class;
    rest:= rest + ( step - erster ) * classes[ descendclass ];
    for i in [ 1 .. min_anzahl ] do
      images[ descendclass ]:= erster + (i-1) * step;
      rest:= rest - step * classes[ descendclass ];
      oldrows:= evaluate( ShallowCopy( candidate ), rest,
                          ShallowCopy( nonzerocol ), descendclass );
      Append( matrix, oldrows );
      if Length( matrix ) > ( 3 * ncha ) / 2 then
        newmatrix:= [];          # matrix:= ModGauss( matrix, moduls );
        for j in [ 1 .. Length( matrix[1] ) ] do
          if nonzerocol[j] then
            row:= StepModGauss( matrix, moduls, nonzerocol, j );
            if row <> fail then Add( newmatrix, row ); fi;
          fi;
        od;
        matrix:= newmatrix;
      fi;
    od;

    return List( possibilities, values -> Character( tbl, values ) );
end );


#############################################################################
##
#F  PermCandidatesFaithful( <tbl>, <chars>, <norm\_subgrp>, <nonfaithful>,
#F                           <lower>, <upper>, <torso>[, <all>] )
##
# `PermCandidatesFaithful'\\
# `      ( tbl, chars, norm\_subgrp, nonfaithful, lower, upper, torso )'
#
# reference of variables\:
# \begin{itemize}
# \item `tbl'\:         a character table which must contain field `order'
# \item `chars'\:       *rational* characters of `tbl'
# \item `nonfaithful'\: $(1_{UN})^G$
# \item `lower'\:       lower bounds for $(1_U)^G$
#                       (may be unspecified, i.e. 0)
# \item `upper'\:       upper bounds for $(1_U)^G$
#                       (may be unspecified, i.e. 0)
# \item `torso'\:       $(1_U)^G$ (at known positions)
# \item `faithful'\:    `torso' - `nonfaithful'
# \item `divs'\:        `divs[i]' divides $(1_U)^G[i]$
# \end{itemize}
#
# The algorithm proceeds in 5 steps\:
#
# *step 1*\: Try to improve the input data
# \begin{enumerate}
# \item Check if `torso[1]' divides $\|G\|$, `nonfaithful[1]' divides
#       `torso[1]'.
# \item If `orders[i]' does not divide $U$
#       or if $'nonfaithful[i]' = 0$, `torso[i]' must be 0.
# \item Transfer `upper' and `lower' to upper bounds and lower bounds for
#       the values of `faithful' and try to improve them\:
# \begin{enumerate}
# \item \['lower[i]'\:= \max\{'lower[i]',0\} - `nonfaithful[i]';\]
#       If $UN$ has only one galois family of classes for a prime
#       representative order $p$, and $p$ divides $\|G\|/'torso[1]'$,
#       or if $g_i$ is a $p$-element and $p$ does not divide $[UN\:U]$,
#       then necessarily these elements lie in $U$, and we have
#       \['lower[i]'\:= \max\{'lower[i]',1\} - `nonfaithful[i]';\]
# \item \begin{eqnarray*}
#       `upper[i]' & \:= & \min\{'upper[i]','torso[1]',
#                                `tbl_centralizers[i]'-1,\\
#       & & `torso[1]' \cdot `nonfaithful[i]'/'nonfaithful[1]'\}
#       -'nonfaithful[i]'.
#       \end{eqnarray*}
# \end{enumerate}
# \item Compute divisors of the values of $(1_U)^G$\:
#       \['divs[i]'\:= `torso[1]'/\gcd\{'torso[1]',\|G\|/\|N_G[i]\|\}
#       \mbox{\rm \ divides} (1_U)^G[i].\]
#       ($\|N_G[i]\|$ denotes the normalizer order of $\langle g_i \rangle$.)
#
#       If $g_i$ generates a Sylow $p$ subgroup of $UN$ and $p$ does not
#       divide $[UN\:U]$ then $(1_{UN})^G(g_i)$ divides $(1_U)^G(g_i)$,
#       and we have \['divs[i]'\:= `Lcm( divs[i], nonfaithful[i] )'.\]
# \item Compute `roots' and `powers' for later improvements of local bounds\:
#       $j$ is in `roots[i]' iff there exists a prime $p$ with powermap
#       stored on `tbl' and $g_j^p = g_i$,
#       $j$ is in `powers[i]' iff there exists a prime $p$ with powermap
#       stored on `tbl' and $g_i^p = g_j$.
# \item Compute the list `matrix' of possible constituents of `faithful'\:
#       (If `torso[1]' = 1, we have none.)
#       Every constituent $\chi$ must have degree $\chi(1)$ lower than
#       $'torso[1]' - `nonfaithful[1]'$, and $N \not\subseteq \ker(\chi)$;
#       also, for all i, we must have
#       $\chi[i] \geq \chi[1] - `faithful[1]' - `nonfaithful[i]'$.
# \end{enumerate}
#
# *step 2*\: Collapse classes which are equal for all possible constituents
#
# (*Note*\: We only needed the fusion of classes, but we also have to make
#         a copy.)
#
# After that, `fusion' induces an equivalence relation of conjugacy classes,
# `matrix' is the new list of constituents. Let $C \:= \{i_1,\ldots,i_n\}$
# be an equivalence class; for further computation, we have to adjust the
# other information\:
#
# \begin{enumerate}
# \item Collapse `faithful'; the values that are not yet known later will be
#       filled in using the decomposability test (see "ContainedCharacters");
#       the equality
#       \['torso' = `nonfaithful' + `Indirection'('faithful','fusion')\]
#       holds, so later we have
#       \[(1_U)^G = (1_{UN})^G + `Indirection( faithful , fusion )'.\]
# \item Adjust the old structures\:
# \begin{enumerate}
# \item Define as new roots \[ `roots[C]'\:=
#       \bigcup_{1 \leq j \leq n} `set(Indirection(fusion,roots[i_j]))', \]
# \item as new powers \[ `powers[C]'\:=
#       \bigcup_{1 \leq j \leq n} `set(Indirection(fusion,powers[i_j]))',\]
# \item as new upper bound \['upper[C]'\:=
#       \min_{1 \leq j \leq n}('upper[i_j]'), \]
#       try to improve the bound using the fact that for each j in
#       `roots[C]' we have
#       \['nonfaithful[j]'+'faithful[j]' \leq
#       `nonfaithful[C]'+'faithful[C]',\]
# \item as new lower bound \['lower[C]'\:=
#       \max_{1 \leq j \leq n}('lower[i_j]'),\]
#        try to improve the bound using the fact that for each j in
#        `powers[C]' we have
#        \['nonfaithful[j]'+'faithful[j]' \geq
#        `nonfaithful[C]'+'faithful[C]',\]
# \item as new divisors \['divs[C]'\:=
#       `Lcm'( `divs'[i_1],\ldots, `divs'[i_n] ).\]
# \end{enumerate}
# \item Define some new structures\:
# \begin{enumerate}
# \item the moduls for the basechange \['moduls[C]'\:=
#          \max_{1 \leq j \leq n}('tbl_centralizers[i_j]'),\]
# \item new classes \['classes[C]'\:=
#          \sum_{1 \leq j \leq n} `tbl_classes[i_j]',\]
# \item \['nonfaithsum[C]'\:= \sum_{1 \leq j \leq n} `tbl_classes[i_j]'
#       \cdot `nonfaithful[i_j]',\]
# \item a variable `rest', preset with $\|G\|$\: We know that
#       $\sum_{g \in G} (1_U)^G(g) = \|G\|$.
#       Let the values of $(1_U)^G$ be known for a subset
#       $\tilde{G} \subseteq G$, and define
#       $'rest'\:= \sum_{g \in \tilde{G}} (1_U)^G(g)$;
#       then for $g \in G \setminus \tilde{G}$, we
#       have $(1_U)^G(g) \leq `rest'/\|Cl_G(g)\|$.
#       In our situation, this means
#       \[\sum_{1 \leq j \leq n} \|Cl_G(g_j)\| \cdot (1_U)^G(g_j)
#       \leq `rest',\]
#       or equivalently
#       $'nonfaithsum[C]' + `faithful[C]' \cdot `classes[C]' \leq `rest'$.
#       (*Note* that `faithful' necessarily is constant on `C'.).
#       So `rest' is used to update local upper bounds.
# \end{enumerate}
# \item (possible acceleration\: If we allow to collapse classes on which
#       `nonfaithful' takes different values, the situation is a little
#       more difficult. The new upper and lower bounds will be others,
#       and the new divisors will become moduls in a congruence relation
#       that has nothing to do with the values of torso or faithful.)
# \end{enumerate}
#
# *step 3*\: Eliminate classes for which the values of `faithful' are known
#
# The subroutine `erase' successively eliminates the columns of `matrix'
# listed up in `uniques'; at most one row remains with a nonzero entry `val'
# in that column `col', this is the gcd of the former column values.
# If we can eliminate `difference[ col ]', we proceed with the next column,
# else there is a contradiction (i.e. no generalized character exists that
# satisfies our conditions), and we set `impossible' true and then return
# all extracted rows which must be used at lower levels of a backtrack
# which may have called `erase'.
# Having erased all uniques without finding a contradiction, `erase' looks
# if other columns have become unique, i.e. the bounds and divisors allow
# just one value; those columns are erased, too.
# `erase' also updates the (local) upper and lower bounds using `roots',
# `powers' and `rest'.
# If no further elimination is possible, there can be two reasons\:
# If all columns are erased, `faithful' is complete, and if it is really a
# character, it will be appended to `possibilities'; then `impossible' is
# set true to indicate that this branch of the backtrack search tree has
# ended here.
# Otherwise `erase' looks for that column where the number of possible
# values is minimal, and puts a record with information about first
# possible value, step (of the arithmetic progression) and number of
# values into that column of `faithful';
# the number of the column is written to `min\_class',
# `impossible' is set false, and the extracted rows are returned.
#
# And this way `erase' computes the lists of possible values\:
#
# Let $d\:= `divs[ i ]', z\:= `val', c\:= `difference[ i ]',
# n\:= `nonfaithful[ i ]', low\:= `local\_lower[ i ]',
# upp\:= `local\_upper[ i ]', g\:= \gcd\{d,z\} = ad + bz$.
#
# Then the set of allowed values is
# \[ M\:= \{x; low \leq x \leq upp; x \equiv -c \pmod{z};
#              x \equiv -n \pmod{d} \}.\]
# If $g$ does not divide $c-n$, we have a contradiction, else
# $y\:= -n -ad \frac{c-n}{g}$ defines the correct arithmetic progression\:
# \[ M = \{x;low \leq x \leq upp; x \equiv y \pmod{'Lcm'(d,z)} \} \]
# The minimum of $M$ is then given by
# \[ L\:= low + (( y - low ) \bmod `Lcm'(d,z)).\]
#
# (*Note* that for the usual case $d=1$ we have $a=1, b=0, y=-c$.)
#
# Therefore the number of values is
# $'Int( `( upp - L ) ` / Lcm'(d,z) ` )' +1$.
#
# In step 3, `erase' is called with the list of known values of `faithful'
# as `uniques'.
# Afterwards, if `InfoCharTable2 = Print' and a backtrack search is necessary,
# a message about the found improvements and the expected expense
# for the backtrack search is printed.
# (*Note* that we are allowed to forget the rows which we have extracted in
# this first elimination.)
#
# *step 4*\: Delete eliminated columns physically before the backtrack search
#
# The eliminated columns (those with `nonzerocol[i] = false') of `matrix'
# are deleted, and the other objects are adjusted\:
# \begin{enumerate}
# \item In `differences', `divs', `nonzerocol', `moduls', `classes',
#       `nonfaithsum', `upper', `lower', the columns are simply deleted.
# \item For adjusting `fusion', first a permutation `fusionperm' is
#       constructed that maps the eliminated columns behind the remaining
#       columns; after `faithful\:= Indirection( faithful, fusionperm )' and
#       `fusion\:= Indirection( fusionperm, fusion )', we have again
#       \[ (1_U)^G = (1_{UN})^G + `Indirection( faithful, fusion )'. \]
# \item adjust `roots' and `powers'.
# \end{enumerate}
#
# *step 5*\: The backtrack search
#
# The subroutine `evaluate' is called with a column `unique'; this (and other
# uniques, if possible) is eliminated. If there was an inconsistence, the
# extracted rows are returned; otherwise the column `min\_class' subsequently
# will be set to all possible values and `evaluate' is called with
# `unique = min\_class'.
# After each return from `evaluate', the returned rows are appended to matrix
# again; if matrix becomes too long, a call of `ModGauss' will shrink it.
# Note that `erase' must be able to update the value of `rest', but any call
# of `evaluate' must not change `rest'; so `rest' is a parameter of
# `evaluate', but for `erase' it is global (realized as `[ rest ]').
##
InstallGlobalFunction( PermCandidatesFaithful,
    function( tbl, chars, norm_subgrp, nonfaithful, upper, lower, torso,
              arg... )
    local ratirr,
          tbl_classes,       # attribute of `tbl'
          tbl_size,          # attribute of `tbl'
          tbl_orders,        # attribute of `tbl'
          tbl_centralizers,  # attribute of `tbl'
          tbl_powermap,      # attribute of `tbl'
          i, x, N, nccl, faithful, families, j, primes, orbits, factors,
          pparts, cyclics, divs, roots, powers, matrix, fusion, inverse,
          moduls, classes, nonfaithsum, rest, uniques, collfaithful,
          orig_nonfaithful, difference, nonzerocol, possibilities,
          ischaracter, erase, min_number, impossible, remain,
          ncha, pos, fusionperm, shrink, ppart, myset, newfaithful,
          min_class, evaluate, step, first, descendclass, oldrows, newmatrix,
          row;

    chars:= List( chars, ValuesOfClassFunction );
    if Length( arg ) = 1 and arg[1] = true then
      # The given list contains all rational irreducible characters.
      ratirr:= chars;
    else
      # The given list is not known to be complete.
      ratirr:= RationalizedMat( List( Irr( tbl ), ValuesOfClassFunction ) );
    fi;

    #
    # step 1: Try to improve the input data
    #
    lower:= ShallowCopy( lower );
    upper:= ShallowCopy( upper );
    torso:= ShallowCopy( torso );

    # order of normal subgroup
    tbl_classes:= SizesConjugacyClasses( tbl );
    N := Sum( tbl_classes{ norm_subgrp } );
    nccl:= Length( nonfaithful );

    tbl_size:= Size( tbl );
    if not IsBound( torso[1] ) or not IsPosInt( torso[1] ) then
      Error( "degree must be positive integer" );
    elif tbl_size mod torso[1] <> 0 or torso[1] mod nonfaithful[1] <> 0
         or torso[1] = 1 then
      return [];
    fi;
    tbl_orders:= OrdersClassRepresentatives( tbl );
    for i in [ 1 .. nccl ] do
      if ( tbl_size / torso[1] ) mod tbl_orders[i] <> 0
         or nonfaithful[i] = 0 then
        if IsBound( torso[i] ) and IsInt( torso[i] ) and torso[i] <> 0 then
          return [];
        fi;
        torso[i]:= 0;
      fi;
    od;
    faithful:= [];
    for i in [ 1 .. Length( torso ) ] do
      if IsBound( torso[i] ) and IsInt( torso[i] ) then
        faithful[i]:= torso[i] - nonfaithful[i];
      fi;
    od;
    # compute a list of Galois families for `tbl':
    families:= [];
    for i in [ 1 .. nccl ] do
      if not IsBound( families[i] ) then
        families[i]:= ClassOrbit( tbl, i );
        for j in families[i] do
          families[j]:= families[i];
        od;
      fi;
    od;
    # `primes': prime divisors of $|U|$ for which there is only one $G$-family
    # of that element order in $UN$:
    factors:= Factors(Integers, tbl_size / torso[1] );
    primes:= Set( factors );
    orbits:= List( primes, p -> [] );
    for i in [ 1 .. nccl ] do
      if tbl_orders[i] in primes and nonfaithful[i] <> 0 then
        AddSet( orbits[ Position( primes, tbl_orders[i] ) ], families[i] );
      fi;
    od;
    for i in [ 1 .. Length( primes ) ] do
      if Length( orbits[i] ) <> 1 then
        Unbind( primes[i] );
      fi;
    od;
    primes:= Compacted( primes );

    # which Sylow subgroups of $UN$ are contained in $U$:

    pparts:= [];
    for i in Set( factors ) do
      if ( torso[1] / nonfaithful[1] ) mod i <> 0 then
        # i is a prime divisor of $\|U\|$ not dividing
        # $|UN|/|U| = `torso[1] / nonfaithful[1]'$:
        ppart:= 1;
        for j in factors do
          if j = i then ppart:= ppart * i; fi;
        od;
        Add( pparts, ppart );
      fi;
    od;
    cyclics:= [];           # cyclic Sylow subgroups
    for i in [ 1 .. nccl ] do
      if tbl_orders[i] in pparts and nonfaithful[i] <> 0 then
        Add( cyclics, i );
      fi;
    od;
    # transfer bounds:
    if lower = 0 then
      lower:= ListWithIdenticalEntries( nccl, 0 );
      lower[1]:= torso[1];
    fi;
    if upper = 0 then
      upper:= ListWithIdenticalEntries( nccl, torso[1] );
    fi;
    upper[1]:= upper[1] - nonfaithful[1];
    lower[1]:= lower[1] - nonfaithful[1];
    tbl_centralizers:= SizesCentralizers( tbl );
    for i in [ 2 .. nccl ] do
      if nonfaithful[i] <> 0 and
         ( tbl_orders[i] in primes
           or 0 in List( pparts, x -> x mod tbl_orders[i] ) ) then
        lower[i]:= Maximum( lower[i], 1 ) - nonfaithful[i];
      else
        lower[i]:= Maximum( lower[i], 0 ) - nonfaithful[i];
      fi;
      if i in norm_subgrp then
        upper[i]:= Minimum( upper[i], torso[1], tbl_centralizers[i] - 1,
                   Int( ( N * nonfaithful[1] - torso[1] ) / tbl_classes[i] ),
                        Int( torso[1] * nonfaithful[i] / nonfaithful[1] ) )
                   - nonfaithful[i];
      else
        upper[i]:= Minimum( upper[i], torso[1], tbl_centralizers[i] - 1,
                        Int( torso[1] * nonfaithful[i] / nonfaithful[1] ) )
                   - nonfaithful[i];
      fi;
    od;
    for i in [ 1 .. nccl ] do
      if IsBound( faithful[i] ) then
        if faithful[i] >= lower[i] then
          lower[i]:= faithful[i];
        else
          return [];
        fi;
        if faithful[i] <= upper[i] then
          upper[i]:= faithful[i];
        else
          return [];
        fi;
      elif lower[i] = upper[i] then
        faithful[i]:= lower[i];
      fi;
    od;
    # compute divs:
    divs:= [ torso[1] ];
    for i in [ 2 .. nccl ] do
      divs[i]:= torso[1] / GcdInt( torso[1],
                  tbl_classes[i] * Length( families[i] )
                                              / Phi( tbl_orders[i] ) );
      if i in cyclics then
        divs[i]:= Lcm( divs[i], nonfaithful[i] );
      fi;
    od;
    # compute roots and powers:
    roots:= [];
    powers:= [];
    for i in [ 1 .. Length( nonfaithful ) ] do
      roots[i]:= [];
      powers[i]:= [];
    od;
    tbl_powermap:= ComputedPowerMaps( tbl );
    for i in [ 2 .. Length( tbl_powermap ) ] do
      if IsBound( tbl_powermap[i] ) then
        for j in [ 1 .. Length( nonfaithful ) ] do
          if IsInt( tbl_powermap[i][j] ) then
            AddSet( powers[j], tbl_powermap[i][j] );
            AddSet( roots[ tbl_powermap[i][j] ], j );
          fi;
        od;
      fi;
    od;
    # matrix of constituents:
    matrix:= [];               # delete impossibles
    for i in chars do
      if i[1] <= faithful[1]
         and Difference( norm_subgrp, ClassPositionsOfKernel( i ) ) <> [] then
        j:= 1;
        while j <= Length( i )
              and i[j] >= i[1] - faithful[1] - nonfaithful[j] do
          j:= j + 1;
        od;
        if j > Length( i ) then Add( matrix, i ); fi;
      fi;
    od;
    if IsEmpty( matrix ) then
      return [];
    fi;

    Info( InfoCharacterTable, 2,
          "PermCandidatesFaithful: There are ",
          Length( matrix ), " possible constituents,\n",
          "#I    the number of unknown values is ",
          Number( [ 1 .. nccl ],
                  x -> not IsBound( faithful[x] ) ),
          ";\n",
          "#I    now trying to collapse the matrix" );

    #
    # step 2: Collapse classes which are equal for all possible constituents
    #
    matrix:= CollapsedMat( matrix, [ nonfaithful ] );
    fusion:= matrix.fusion;
    matrix:= matrix.mat;
    inverse:= [];
    for i in [ 1 .. Length( fusion ) ] do
      if IsBound( inverse[ fusion[i] ] ) then
        Add( inverse[ fusion[i] ], i );
      else
        inverse[ fusion[i] ]:= [ i ];
      fi;
    od;
    #
    myset:= function( obj )
    if IsInt( obj ) then return [ obj ]; else return obj; fi; end;
    #
    lower:= List( inverse, x -> Maximum( lower{ x } ) );
    upper:= List( inverse, x -> Minimum( upper{ x } ) );
    divs:=  List( inverse, x -> Lcm( divs{ x } ) );
    moduls:= List( inverse, x -> Maximum( tbl_centralizers{ x } ) );
    roots:= List( CompositionMaps( CompositionMaps( fusion, roots ),
                                                           inverse ), myset );
    powers:= List( CompositionMaps( CompositionMaps( fusion, powers ),
                                                           inverse ), myset );
    classes:= ListWithIdenticalEntries( Length( moduls ), 0 );
    for i in [ 1 .. Length( inverse ) ] do
      for j in inverse[i] do
        classes[i]:= classes[i] + tbl_classes[j];
      od;
    od;
    nonfaithsum:= ListWithIdenticalEntries( Length( moduls ), 0 );
    for i in [ 1 .. Length( inverse ) ] do
      for j in inverse[i] do
        nonfaithsum[i]:= nonfaithsum[i] + tbl_classes[j] * nonfaithful[j];
      od;
    od;
    rest:= tbl_size;
    nccl:= Length( moduls );
    uniques:= [];
    collfaithful:= [];
    for i in [ 1 .. Length( fusion ) ] do
      if IsBound( faithful[i] ) then
        if IsBound( collfaithful[ fusion[i] ] ) then
          if collfaithful[ fusion[i] ] <> faithful[i] then return []; fi;
        else
          collfaithful[ fusion[i] ]:= faithful[i];
          Add( uniques, fusion[i] );
          rest:= rest - classes[fusion[i]] * ( faithful[i] + nonfaithful[i] );
          if rest < 0 then return [];  fi;
        fi;
      fi;
    od;
    faithful:= collfaithful;
    orig_nonfaithful:= ShallowCopy( nonfaithful );
    nonfaithful:= CompositionMaps( nonfaithful, inverse );
    # improvement of bounds by use of roots and powers
    for i in [ 1 .. nccl ] do
      if IsBound( faithful[i] ) then
        for j in roots[i] do
          upper[j]:= Minimum( upper[j],
                              nonfaithful[i] + faithful[i] - nonfaithful[j] );
        od;
        for j in powers[i] do
          lower[j]:= Maximum( lower[j],
                              nonfaithful[i] + faithful[i] - nonfaithful[j] );
        od;
      fi;
    od;

    Info( InfoCharacterTable, 2,
          "PermCandidatesFaithful: There are ", nccl,
          " families of classes left,\n",
          "#I    the number of unknown values is ",
          nccl - Length( uniques ), ",\n",
          "#I    the numbers of possible values for each class are",
          " approximately\n",
          "#I    ",
          List( [ 1 .. nccl ],
          x -> Int( ( upper[x] - lower[x] ) / divs[x] )+1),
          ";\n#I    now eliminating known classes" );

    #
    # step 3: Eliminate classes for which the values of `faithful' are known
    #
    difference:= ListWithIdenticalEntries( Length( moduls ), 0 );
    nonzerocol:= ListWithIdenticalEntries( Length( moduls ), true );
    possibilities:= [];     # global list of permutation character candidates
    #
    # a little function:
    #
    ischaracter:= function( gencharacter )
      local cand;
      cand:= List( [ 1 .. Length( gencharacter ) ],
                   i -> gencharacter[i] * tbl_classes[i] );
      return ForAll( ratirr, chi -> 0 <= cand * chi );
    end;
    #
    # and a bigger function:
    #
    erase:= function( uniques, nonzerocol, difference, rest, locupp, loclow )
    # eliminate all unique columns, adapt nonzerocol;
    # then look if other columns become unique or if a contradiction occurs;
    # also look at which column the least number of values is left
    local i, j, extracted, col, row, quot, val, ggt, a, b, k, u, anzahl, elm,
          firstallowed, step, gencharacter, remain, update, newupdate,
          c, upp, low, g, st, y, L, number;
    extracted:= [];
    while uniques <> [] do
      for col in uniques do
        if col < 0 then       # col is zerocol, known from val = moduls[i]
          col:= -col;
          difference[ col ]:= ( difference[ col ] + faithful[ col ] )
                                                        mod moduls[ col ];
          if difference[ col ] <> 0 then
            impossible:= true;
            return extracted;
          fi;
        else
          difference[ col ]:=
                          ( difference[ col ] + faithful[ col ] )
                                                        mod moduls[ col ];
          row:= StepModGauss( matrix, moduls, nonzerocol, col );
          if row = fail then
            if difference[ col ] <> 0 then
              impossible:= true;
              return extracted;
            fi;
          else
            # delete zero rows:
            shrink:= [];
            for i in matrix do
               if PositionNonZero( i ) <= Length( i ) then
#T better call IsZero?
                 Add( shrink, i );
               fi;
            od;
            matrix:= shrink;
            #
            Add( extracted, row );
            if difference[col] mod row[col] <> 0 then
              impossible:= true;
              return extracted;
            fi;
            quot:= difference[col] / row[col];
            for j in [ 1 .. nccl ] do
              if nonzerocol[j] then
                difference[j]:= ( difference[j] - quot * row[j] )
                                                           mod moduls[j];
              fi;
            od;
          fi;
        fi;
        nonzerocol[col]:= false;
        locupp[ col ]:= faithful[ col ];
        loclow[ col ]:= faithful[ col ];
    #   update:= [ col ];
    #   while update <> [] do
    #     newupdate:= [];
    #     for k in update do
    #       for elm in roots[k] do
    #         if nonzerocol[ elm ] then
    #           if locupp[ elm ] >
    #              locupp[k] + nonfaithful[k] - nonfaithful[ elm ] then
    #             AddSet( newupdate, elm );
    #             locupp[ elm ]:= locupp[k] + nonfaithful[k]
    #                             - nonfaithful[ elm ];
    #           fi;
    #         fi;
    #       od;
    #     od;
    #     update:= newupdate;
    #   od;
    #   update:= [ col ];
    #   while update <> [] do
    #     newupdate:= [];
    #     for k in update do
    #       for elm in powers[k] do
    #         if nonzerocol[ elm ] then
    #           if loclow[ elm ] < loclow[k]
    #                          + nonfaithful[k] - nonfaithful[ elm ] then
    #             AddSet( newupdate, elm );
    #             loclow[ elm ]:= loclow[k] + nonfaithful[k]
    #                             - nonfaithful[ elm ];
    #           fi;
    #         fi;
    #       od;
    #     od;
    #     update:= newupdate;
    #   od;
      od;
    # now all yet known uniques have been erased, try to find new ones
      min_number:= infinity;
      uniques:= [];
      for i in [ 1 .. nccl ] do
        if nonzerocol[i] then
          val:= moduls[i];
          for j in matrix do val:= GcdInt( val, j[i] ); od;
                                             # zerocol iff val = moduls[i]
          c:= difference[i] mod val;         # now >= 0
          upp:= Minimum( locupp[i], ( rest[1] - nonfaithsum[i] )/classes[i] );
          low:= loclow[i];
          g:= Gcdex( divs[i], val );
          a:= g.coeff1;
          b:= g.coeff2;
          g:= g.gcd;
          if ( c - nonfaithful[i] ) mod g <> 0 then
            impossible:= true;
            return extracted;
          fi;
          st:= divs[i] * val / g;
          y:= - nonfaithful[i] - ( a * divs[i] * ( c - nonfaithful[i] ) ) / g;
          L:= low + ( ( y - low ) mod st);
          if upp < L then
            impossible:= true;
            return extracted;
          else
            number:= Int( ( upp - L ) / st ) + 1;
            if number = 1 then         # unique
              faithful[i]:= L;
              if val = moduls[i] then
                Add( uniques, -i );    # no StepModGauss necessary
              else
                Add( uniques, i );
              fi;
              rest[1]:= rest[1] - classes[i] * faithful[i] - nonfaithsum[i];
            elif number < min_number then
              min_number:= number;
              step:= st;
              firstallowed:= L;
              min_class:= i;
            fi;
          fi;
        fi;
      od;
    od;
    if min_number = infinity then
      if rest[1] = 0 then
        gencharacter:= faithful{ fusion } + orig_nonfaithful;
        if ischaracter( gencharacter ) and TestPerm1( tbl, gencharacter ) = 0
           and TestPerm2( tbl, gencharacter ) = 0 then
          Add( possibilities, gencharacter );
        fi;
      fi;
      impossible:= true;
    else
      faithful[ min_class ]:= rec( firstallowed:= firstallowed, # first value
                                   step:= step,                 # step
                                   number:= min_number );
      impossible:= false;
    fi;
    return extracted;
    # impossible = true: calling function will return from backtrack
    # impossible = false: then min_class < infinity, and faithful[ min_class ]
    #                 contains the information for descending at min_class
    end;

    #
    rest:= [ rest ];
    erase( uniques, nonzerocol, difference, rest, upper, lower );
    rest:= rest[1];
    if impossible then
      return List( possibilities, vals -> Character( tbl, vals ) );
    fi;

    Info( InfoCharacterTable, 2,
          "PermCandidatesFaithful: A backtrack search",
          " will be needed;\n",
          "#I    now physically deleting known classes" );

    #
    # step 4: Delete eliminated columns physically before the backtrack search
    #
    remain:= Filtered( [ 1 .. nccl ], x -> nonzerocol[x] );
    for i in [ 1 .. Length( matrix ) ] do
      matrix[i]:= matrix[i]{ remain };
    od;
    difference:=    difference{ remain };
    divs:=          divs{ remain };
    nonzerocol:=    nonzerocol{ remain };
    moduls:=        moduls{ remain };
    classes:=       classes{ remain };
    nonfaithsum:=   nonfaithsum{ remain };
    nonfaithful:=   nonfaithful{ remain };
    upper:=         upper{ remain };
    lower:=         lower{ remain };
    matrix:= ModGauss( matrix, moduls );
    ncha:= Length( matrix );
    pos:= 1;
    fusionperm:= [];
    for i in [ 1 .. nccl ] do
      if i in remain then
        fusionperm[i]:= pos;
        pos:= pos + 1;
      fi;
    od;
    for i in Difference( [ 1 .. nccl ], remain ) do
      fusionperm[i]:= pos;
      pos:= pos + 1;
    od;
    min_class:= fusionperm[ min_class ];
    newfaithful:= [];
    for i in [ 1 .. Length( faithful ) ] do
      if IsBound( faithful[i] ) then
        newfaithful[ fusionperm[i] ]:= faithful[i];
      fi;
    od;
    faithful:= newfaithful;
    fusion:= CompositionMaps( fusionperm, fusion );
    for i in remain do
      roots[ fusionperm[i] ]:= CompositionMaps( fusionperm,
                                     Intersection( roots[i], remain ) );
      powers[ fusionperm[i] ]:= CompositionMaps( fusionperm,
                                     Intersection( powers[i], remain ) );
    od;
    nccl:= Length( nonzerocol );

    Info( InfoCharacterTable, 2,
          "PermCandidatesFaithful:",
          " The number of unknown values is ", nccl, ";\n",
          "#I    the numbers of possible values for each class are",
          " approximately\n#I    ",
          List( [ 1 .. nccl ],
          x -> Int( ( upper[x] - lower[x] ) / divs[x]+1)),
          "\n#I    now beginning the backtrack search" );

    #
    # step 5: The backtrack search
    #
    evaluate:=
          function(difference,rest,nonzerocol,unique,local_upper,local_lower)
    local i, j, row, extracted, step, first, descendclass;
    rest:= [ rest ];
    extracted:= erase( [ unique ], nonzerocol, difference, rest, local_upper,
                       local_lower );
    rest:= rest[1];
    if impossible then
      return extracted;
    fi;
    descendclass:= min_class;
    step:= faithful[ descendclass ].step;
    first:= faithful[ descendclass ].firstallowed;
    rest:= rest + ( step - first ) * classes[ descendclass ]
                - nonfaithsum[ descendclass ];
    for i in [ 1 .. min_number ] do
      faithful[ descendclass ]:= first + (i-1) * step;
      rest:= rest - step * classes[ descendclass ];
      oldrows:= evaluate( ShallowCopy(difference), rest,
                          ShallowCopy( nonzerocol ),
                          descendclass,
                          ShallowCopy( local_upper ),
                          ShallowCopy( local_lower ) );
      Append( matrix, oldrows );
      if Length( matrix ) > ( 3 * ncha ) / 2 then
        newmatrix:= [];
        for j in [ 1 .. Length( matrix[1] ) ] do
          if nonzerocol[j] then
            row:= StepModGauss( matrix, moduls, nonzerocol, j );
            if row <> fail then Add( newmatrix, row ); fi;
          fi;
        od;
        matrix:= newmatrix;
      fi;
    od;
    return extracted;
    end;

    #

    step:= faithful[min_class].step;
    first:= faithful[min_class].firstallowed;
    descendclass:= min_class;
    rest:= rest + ( step - first ) * classes[ descendclass ]
                - nonfaithsum[ descendclass ];
    for i in [ 1 .. min_number ] do
      faithful[ descendclass ]:= first + (i-1) * step;
      rest:= rest - step * classes[ descendclass ];
      oldrows:= evaluate( ShallowCopy(difference), rest,
                          ShallowCopy( nonzerocol ),
                          descendclass,
                          ShallowCopy( upper ),
                          ShallowCopy( lower ) );
      Append( matrix, oldrows );
      if Length( matrix ) > ( 3 * ncha ) / 2 then
        newmatrix:= [];
        for j in [ 1 .. Length( matrix[1] ) ] do
          if nonzerocol[j] then
            row:= StepModGauss( matrix, moduls, nonzerocol, j );
            if row <> fail then
              Add( newmatrix, row );
            fi;
          fi;
        od;
        matrix:= newmatrix;
      fi;
    od;

    # Create class function objects from the candidates,
    # nad return the result list.
    return List( possibilities, vals -> Character( tbl, vals ) );
end );


#############################################################################
##
#F  PermChars( <tbl> )
#F  PermChars( <tbl>, <degree> )
#F  PermChars( <tbl>, <arec> )
##
InstallGlobalFunction( PermChars, function( arg )

   local tbl, arec, names, chars, upper, lower;

   if Length(arg) = 1 then
      tbl:= arg[1];
      arec:= rec();
   elif Length(arg) = 2 then
      tbl:= arg[1];
      if IsRecord( arg[2] ) then
        arec:= arg[2];
      else
        arec:= rec(degree:= arg[2]);
      fi;
   else

      Error( "usage: PermChars(<tbl>), PermChars(<tbl>, <degree>) or\n",
             "       PermChars(<tbl>, <arec>)" );

   fi;

   names:= RecNames( arec );

   if "degree" in names and IsInt( arec.degree ) then

      # Use the improved combinatorial approach.
      return PermComb( tbl, arec );

   elif IsSubset( names, [ "normalsubgroup", "nonfaithful", "torso" ] ) then

      # Search for faithful candidates only, using Gaussian elimination.
      if "chars" in names then
        chars:= arec.chars;
      else
        chars:= RationalizedMat( List( Irr( tbl ), ValuesOfClassFunction ) );
      fi;
      if IsBound( arec.upper ) then
        upper:= arec.upper;
      else
        upper:= 0;
      fi;
      if IsBound( arec.lower ) then
        lower:= arec.lower;
      else
        lower:= 0;
      fi;
      return PermCandidatesFaithful( tbl, chars, arec.normalsubgroup,
                 arec.nonfaithful, upper, lower, arec.torso,
                 not "chars" in names );

   elif "torso" in names then

      # Use Gaussian elimination.
      if "chars" in names then
        chars:= arec.chars;
      else
        chars:= RationalizedMat( List( Irr( tbl ), ValuesOfClassFunction ) );
      fi;
      return PermCandidates( tbl, chars, arec.torso, false );

   else

      # Solve the system of inequalities.
      return Permut( tbl, arec );

   fi;
end );


#############################################################################
##
#F  PermCharInfo( <tbl>, <permchars>[, \"LaTeX\" ] )
#F  PermCharInfo( <tbl>, <permchars>[, \"HTML\" ] )
##
InstallGlobalFunction( PermCharInfo, function( arg )
    local tbl,                # character table, first argument
          permchars,          # list of characters, second argument
          supopen,            # opening tag for exponentiation
          supclose,           # closing tag for exponentiation
          tbl_centralizers,   # attribute of `tbl'
          tbl_size,           # attribute of `tbl'
          tbl_irreducibles,   # attribute of `tbl'
          tbl_classes,        # attribute of `tbl'
          i, j, order, cont, bound, alp, degreeset, irreds, chi,
          ATLAS, ATL, error, scprs, cont1, bound1, char, chars;

    if   1 < Length( arg ) and Length( arg ) < 4
                           and IsNearlyCharacterTable( arg[1] )
                           and IsList( arg[2] ) then
      tbl:= arg[1];
      permchars:= arg[2];
      if IsBound( arg[3] ) and arg[3] = "HTML" then
        supopen  := "<sup>";
        supclose := "</sup>";
      else
        supopen  := "^{";
        supclose := "}";
      fi;
    else
      Error( "usage: PermCharInfo( <tbl>, <permchars>[, \"HTML\"] )" );
    fi;

    cont  := [];
    bound := [];
    ATL   := [];
    chars := [];

    tbl_centralizers:= SizesCentralizers( tbl );
    tbl_size:= Size( tbl );

    if not IsEmpty( permchars ) and not IsList( permchars[1] ) then
      permchars:= [ permchars ];
    fi;
    permchars:= List( permchars, ValuesOfClassFunction );

    for char in permchars do
      cont1  := [];
      bound1 := [];
      order  := tbl_size / char[1];
      for i in [ 1 .. Length( char ) ] do
        cont1[i]  := char[i] * order / tbl_centralizers[i];
        bound1[i] := order / GcdInt( order, tbl_centralizers[i] );
      od;
      Add( cont, cont1 );
      Add( bound, bound1 );
      Append( chars, [ char, cont1, bound1 ] );
    od;

    if HasIrr( tbl ) then

      tbl_irreducibles:= Irr( tbl );

      # compute the `ATLAS' component
      alp:= [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
              "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
              "w", "x", "y", "z" ];
      degreeset:= Set( tbl_irreducibles, DegreeOfCharacter );

      # `irreds[i]' contains all irreducibles of the `i'--th degree
      irreds:= List( degreeset, x -> [] );
      for chi in tbl_irreducibles do
        Add( irreds[ Position( degreeset, chi[1] ) ],
             ValuesOfClassFunction( chi ) );
      od;

      # extend the alphabet if necessary
      while Length( alp ) < Maximum( List( irreds, Length ) ) do
        alp:= Concatenation( alp,
               List( alp, x -> Concatenation( "(", x, "')" ) ) );
      od;

      ATLAS:= [];
      for char in permchars do

        ATL:= "";
        error:= false;
        for i in irreds do
          scprs:= List( i, x -> ScalarProduct( tbl, char, x ) );
          if ForAny( scprs, x -> x < 0 ) then
            scprs:= Filtered( [ 1 .. Length( scprs ) ], x -> scprs[x] <  0 );
            scprs:= List( scprs, x -> Position( tbl_irreducibles, i[x] ) );
            Print( "#E PermCharInfo: negative scalar product(s) with X",
                   scprs, "\n" );
            error:= true;
          elif ForAny( scprs, x -> x > 0 ) then
            if ATL <> "" then
              ATL:= Concatenation( ATL, "+" );
            fi;
            ATL:= Concatenation( ATL, String( i[1][1] ) );
            for j in [ 1 .. Length( scprs ) ] do
              if   scprs[j] = 1 then
                ATL:= Concatenation( ATL, alp[j] );
              elif scprs[j] = 2 then
                ATL:= Concatenation( ATL, alp[j], alp[j] );
              elif scprs[j] = 3 then
                ATL:= Concatenation( ATL, alp[j], alp[j], alp[j] );
              elif scprs[j] > 3 then
                ATL:= Concatenation( ATL, alp[j], supopen,
                                           String( scprs[j] ), supclose );
              fi;
            od;
          fi;
        od;
        if error then ATL:= "Error"; fi;
        ConvertToStringRep( ATL );
        Add( ATLAS, ATL );
      od;
    else
      ATLAS:= "error, no irreducibles bound";
    fi;

    tbl_classes:= SizesConjugacyClasses( tbl );

    return rec( contained:= cont, bound:= bound,
                display:= rec( classes:= Filtered([1..Length(tbl_classes)],
                                  x -> ForAny( permchars, y -> y[x]<>0 ) ),
                               chars:= chars,
                               letter:= "I"                               ),
                ATLAS:= ATLAS );
end );


#############################################################################
##
#F  PermCharInfoRelative( <tbl>, <tbl2>, <permchars> )
##
InstallGlobalFunction( PermCharInfoRelative, function( tbl, tbl2, permchars )
    local tblfustbl2,     # fusion of `tbl' in `tbl2'
          size2,          # order of `tbl2'
          cont,
          bound,
          ATL,
          chars,
          centralizers2,  # centralizer orders of `tbl2'
          char,           # loop over `permchars'
          cont1,
          bound1,
          order,          # order of the subgroup $U$
          i,              # loop variable
          irr,
          irr2,
          nccl2,
          alp,
          degreeset,
          irreds,
          chi,
          irreds2,
          irrnam2,
          rest,
          j,
          chi2,
          k,
          pos,
          ATLAS,
          error,
          scprs,
          ATL1,
          nam,
          mult;

    tblfustbl2:= GetFusionMap( tbl, tbl2 );
    size2:= Size( tbl2 );
    if tblfustbl2 = fail or size2 <> 2 * Size( tbl ) then
      Error( "<tbl> must be of index 2 in <tbl2>, with stored fusion" );
    fi;

    cont  := [];
    bound := [];
    ATL   := [];
    chars := [];

    centralizers2:= SizesCentralizers( tbl2 );

    if not IsEmpty( permchars ) and not IsList( permchars[1] ) then
      permchars:= [ permchars ];
    fi;
    permchars:= List( permchars, ValuesOfClassFunction );

    # Compute the info about the number of elements in the subgroup etc.
    for char in permchars do
      cont1  := [];
      bound1 := [];
      order  := size2 / char[1];
      for i in [ 1 .. Length( char ) ] do
        cont1[i]  := char[i] * order / centralizers2[i];
        bound1[i] := order / GcdInt( order, centralizers2[i] );
      od;
      Add( cont, cont1 );
      Add( bound, bound1 );
      Append( chars, [ char, cont1, bound1 ] );
    od;

    # The remaining code deals with the `ATLAS' component.
    if HasIrr( tbl ) and HasIrr( tbl2 ) then

      irr  := Irr( tbl );
      irr2 := Irr( tbl2 );
      nccl2:= Length( irr2 );

      alp:= [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
              "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
              "w", "x", "y", "z" ];

      # `irreds[i]' contains all irreducibles of `tbl' of the `i'--th degree.
      degreeset:= Set( irr, x -> x[1] );
      irreds:= List( degreeset, x -> [] );
      for chi in irr do
        Add( irreds[ Position( degreeset, chi[1] ) ],
             ValuesOfClassFunction( chi ) );
      od;

      # Extend the alphabet if necessary.
      while Length( alp ) < Maximum( List( irreds, Length ) ) do
        Append( alp,
                List( alp, x -> Concatenation( "(", x, "')" ) ) );
      od;

      # Construct relative names for the irreducibles of `tbl2'.
      irreds2:= [];
      irrnam2:= [];
      rest:= List( irr2, x -> x{ tblfustbl2 } );
      for i in [ 1 .. Length( irreds ) ] do

        irreds2[i]:= [];
        irrnam2[i]:= [];

        for j in [ 1 .. Length( irreds[i] ) ] do

          chi2:= [];
          for k in [ 1 .. nccl2 ] do
            if rest[k] = irreds[i][j] then
              Add( chi2, irr2[k] );
            fi;
          od;
          if Length( chi2 ) = 2 then

            # The `j'-th character of the `i'-th degree of `tbl' extends.
            Append( irreds2[i], chi2 );
            Add( irrnam2[i], Concatenation( alp[j], "^+" ) );
            Add( irrnam2[i], Concatenation( alp[j], "^-" ) );

          else

            # The `j'-th character of the `i'-th degree of `tbl' fuses
            # with another character of `tbl', of the same degree.
            for k in [ 1 .. nccl2 ] do
              if     rest[k][1] = 2 * irreds[i][j][1]
                 and ScalarProduct( tbl, rest[k], irreds[i][j] ) <> 0 then
                pos:= Position( irreds2[i], irr2[k] );
                if pos = fail then
                  Add( irreds2[i], irr2[k] );
                  Add( irrnam2[i], ShallowCopy( alp[j] ) );
                else
                  Append( irrnam2[i][ pos ], alp[j] );
                fi;
              fi;
            od;

          fi;

        od;

      od;

      ATLAS:= [];
      for char in permchars do

        ATL:= "";
        error:= false;
        for i in [ 1 .. Length( degreeset ) ] do

          scprs:= List( irreds2[i], x -> ScalarProduct( tbl2, char, x ) );

          if ForAny( scprs, x -> x < 0 ) then

            # The decomposition into irreducibles has negative coefficients.
            Info( InfoCharacterTable, 1,
                  "PermCharInfoRelative: negative scalar product(s) with X",
                  List( Filtered( [ 1 .. Length( scprs ) ],
                                  x -> scprs[x] < 0 ),
                        y -> Position( irr2, irreds2[i][y] ) ) );
            error:= true;

          elif ForAny( scprs, x -> x > 0 ) then

            # There are constituents of the `i'-th degree.
            if ATL <> "" then
              Add( ATL, '+' );
            fi;
            Append( ATL, String( degreeset[i] ) );
            ATL1:= [];
            for j in [ 1 .. Length( scprs ) ] do
              nam:= false;
              if scprs[j] <> 0 then

                # The `j'-th character of the `i'-th degree occurs.
                # If this is a `+' character then check whether also the
                # corresponding `-' character occurs, and if yes then
                # form constituents of the form `\pm'.
                if irrnam2[i][j][ Length( irrnam2[i][j] ) ] = '+' then
                  pos:= ShallowCopy( irrnam2[i][j] );
                  pos[ Length( pos ) ]:= '-';
                  pos:= Position( irrnam2[i], pos );
                  if   scprs[ pos ] <= scprs[j] and 0 < scprs[ pos ] then
                    mult:= scprs[ pos ];
                    scprs[j]:= scprs[j] - mult;
                    scprs[ pos ]:= 0;
                    nam:= Concatenation( irrnam2[i][ pos ]{ [
                          1 .. Length( irrnam2[i][ pos ] ) -1 ]}, "{\\pm}" );
                  elif scprs[j] < scprs[ pos ] then
                    mult:= scprs[j];
                    scprs[ pos ]:= scprs[ pos ] - mult;
                    scprs[j]:= 0;
                    nam:= Concatenation( irrnam2[i][j]{ [
                          1 .. Length( irrnam2[i][j] ) -1 ]}, "{\\pm}" );
                  fi;

                fi;

              fi;

              # Deal with the `\pm' constituents.
              if nam <> false then
                Add( ATL1, [ nam, mult ] );
              fi;

              # Deal with the ordinary constituents.
              if scprs[j] <> 0 then
                if Length( irrnam2[i][j] ) = 2 then
                  Add( ATL1, [ [ irrnam2[i][j][1] ], scprs[j] ] );
                  Add( ATL1, [ [ irrnam2[i][j][2] ], scprs[j] ] );
                else
                  Add( ATL1, [ irrnam2[i][j], scprs[j] ] );
                fi;
              fi;

            od;

            # It may happen that constituents "ad" and "bc" occur.
            # Here we want to write "abcd" not "adbc", that's why we sort.
            Sort( ATL1 );
            for j in ATL1 do
              if j[2] = 1 then
                Append( ATL, j[1] );
              else
                Add( ATL, '(' );
                Append( ATL, j[1] );
                Append( ATL, ")^{" );
                Append( ATL, String( j[2] ) );
                Add( ATL, '}' );
              fi;
            od;

          fi;

        od;

        if error then
          ATL:= "Error";
        fi;
        Add( ATLAS, ATL );

      od;

    else
      ATLAS:= "error, no irreducibles bound";
    fi;

    # Return the result.
    return rec( contained := cont,
                bound     := bound,
                display   := rec( classes:= Filtered( [ 1 .. nccl2 ],
                                  x -> ForAny( permchars, y -> y[x]<>0 ) ),
                                  chars:= chars,
                                  letter:= "I" ),
                ATLAS     := ATLAS );
    end );
