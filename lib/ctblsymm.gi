#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Götz Pfeiffer, Felix Noeske.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains  the  functions   needed  for a  direct computation of
##  the  character values of  wreath  products  of a  group  $G$  with $S_n$,
##  the   symmetric group  on   n points.
##


#############################################################################
##
#F  BetaSet( <alpha> )  . . . . . . . . . . . . . . . . . . . . . . beta set.
##
InstallGlobalFunction( BetaSet,
    alpha -> Reversed( alpha ) + [ 0 .. Length( alpha ) - 1 ] );


#############################################################################
##
#F  CentralizerWreath( <sub_cen>, <ptuple> )  . . . . centralizer in G wr Sn.
##
InstallGlobalFunction( CentralizerWreath, function(sub_cen, ptuple)

    local p, i, j, k, last, res;

    res:= 1;
    for i in [1..Length(ptuple)] do
       last:= 0; k:= 1;
       for p in ptuple[i] do
          res:= res * sub_cen[i] * p;
          if p = last then
             k:= k+1;
             res:= res * k;
          else
             k:= 1;
          fi;
          last:= p;
       od;
    od;

    return res;

end );


#############################################################################
##
#F  PowerWreath( <sub_pm>, <ptuple>, <p> )  . . . . . .  powermap in G wr Sn.
##
InstallGlobalFunction( PowerWreath, function(sub_pm, ptuple, p)

    local power, k, i, j;

    power:= List(ptuple, x-> []);
    for i in [1..Length(ptuple)] do
       for k in ptuple[i] do
          if k mod p = 0 then
             for j in [1..p] do
                Add(power[i], k/p);
             od;
          else
             Add(power[sub_pm[i]], k);
          fi;
       od;
    od;

    for k in power do
       Sort(k, function(a,b) return a>b; end);
    od;

    return power;

end );


#############################################################################
##
#F  InductionScheme( <n> )  . . . . . . . . . . . . . . . . removal of hooks.
##
InstallGlobalFunction( InductionScheme, function(n)

    local scheme, pm, i, beta, hooks;

    pm:= [];
    scheme:= [];

    #  how to encode all hooks.
    hooks:= function(beta, m)
       local i, j, l, gamma, hks, sign;

       hks:= [];
       for i in [1..m] do
          hks[i]:= [];
       od;

       for  i in  beta do

          sign:= 1;

          for j in [1..i]  do
             if i-j in beta then
                sign:= -sign;
             else
                if j = m then
                   Add(hks[m], sign);
                else
                   gamma:= Difference(beta, [i]);
                   AddSet(gamma, i-j);

                   #  remove leading zeros.
                   if i = j then
                      l:= 0;
                      while gamma[l+1] = l do
                         l:= l+1;
                      od;
                      gamma:= gamma{[l+1..Length(gamma)]} - l;
                   fi;

                   Add(hks[j], sign * Position(pm[m-j], gamma));
                fi;
             fi;
          od;

       od;
       return hks;
    end;

    #  collect hook encodings.
    for i in [1..n] do
       pm[i]:= List(Partitions(i), BetaSet);
       scheme[i]:= [];
       for beta in pm[i] do
          Add(scheme[i], hooks(beta, i));
       od;
    od;

    return scheme;

end );


#############################################################################
##
#F  MatCharsWreathSymmetric( <tbl>, <n> ) . . .  character matrix of G wr Sn.
##
InstallGlobalFunction( MatCharsWreathSymmetric, function( tbl, n)

    local tbl_irreducibles,
          i, j, k, m, r, s, t, pm, res, col, scheme, np, charCol, hooks,
          pts, partitions;

    r:= NrConjugacyClasses( tbl );
    tbl_irreducibles:= List( Irr( tbl ), ValuesOfClassFunction );

    #  encode partition tuples by positions of partitions.
    partitions:= List([1..n], Partitions);
    pts:= [];
    for i in [1..n] do
       pts[i]:= PartitionTuples(i, r);
       for j in [1..Length(pts[i])] do
         np:= [[], []];
         for t in pts[i][j] do
            s:= Sum( t, 0 );
            Add(np[1], s);
            if s = 0 then
               Add(np[2], 1);
            else
               Add(np[2], Position( partitions[s], t, 0 ));
            fi;
         od;
         pts[i][j]:= np;
       od;
    od;

    scheme:= InductionScheme(n);

    #  how to encode a hook.
    hooks:= function(np, n)
       local res, i, k, l, ni, pi, sign;

       res:= [];
       for i in [1..r] do
         res[i]:= List([1..n], x-> []);
       od;

       for i in [1..r] do
         ni:= np[1][i]; pi:= np[2][i];
         for k in [1..ni] do
            for l in scheme[ni][pi][k] do
               np[1][i]:= ni-k;
               if l < 0 then
                  np[2][i]:= -l;
                  sign:= -1;
               else
                  np[2][i]:= l;
                  sign:= 1;
               fi;
               if k = n then
                  Add(res[i][k], sign);
               else
                  Add(res[i][k], sign * Position(pts[n-k], np));
               fi;
            od;
         od;
         np[1][i]:= ni; np[2][i]:= pi;
       od;
       return res;
    end;

    #  collect hook encodings.
    res:= [];
    Info( InfoCharacterTable, 2, "Scheme:" );
    for i in [1..n] do
       Info( InfoCharacterTable, 2, i );
       res[i]:= [];
       for np in pts[i] do
         Add(res[i], hooks(np, i));
       od;
    od;
    scheme:= res;

    #  how to construct a new column.
    charCol:= function(n, t, k, p)
       local i, j, col, pi, val;

       col:= [];
       for pi in scheme[n] do
         val:= 0;
         for j in [1..r] do
            for i in pi[j][k] do
               if i < 0 then
                  val:= val - tbl_irreducibles[j][p] * t[-i];
               else
                  val:= val + tbl_irreducibles[j][p] * t[i];
               fi;
            od;
         od;
         Add(col, val);
       od;
       return col;
    end;

    #  construct the columns.
    pm:= List([1..n-1], x->[]);
    Info( InfoCharacterTable, 2, "Cycles:" );
    for m in [1..QuoInt(n,2)] do

       # the $m$-cycle in all possible places
       Info( InfoCharacterTable, 2, m );
       for i in [1..r] do
         s:= [1..n]*0+1;
         s[m]:= i;
         Add(pm[m], rec(col:= charCol(m, [1], m, i), pos:= s));
       od;

       # add the $m$-cycle to everything you know
       for k in [m+1..n-m] do
         for t in pm[k-m] do
            for i in [t.pos[m]..r] do
               s:= ShallowCopy(t.pos);
               s[m]:= i;
               Add(pm[k], rec(col:= charCol(k, t.col, m, i), pos:= s));
            od;
         od;
       od;
    od;

    #  collect and transpose.
    np:= Length(scheme[n]);
    res:= List([1..np], x-> []);
    Info( InfoCharacterTable, 2, "Tables:" );
    for k in [1..n-1] do
       Info( InfoCharacterTable, 2, k );
       for t in pm[n-k] do
         for i in [t.pos[k]..r] do
            col:= charCol(n, t.col, k, i);
            for j in [1..np] do
               Add(res[j], col[j]);
            od;
         od;
       od;
    od;

    for i in [1..r] do
       col:= charCol(n, [1], n, i);
       for j in [1..np] do
         Add(res[j], col[j]);
       od;
    od;

    return res;

end );


#############################################################################
##
#F  CharValueSymmetric( <n>, <beta>, <pi> ) . . . . . character value in S_n.
##
InstallGlobalFunction( CharValueSymmetric, function(n, beta, pi)

    local i, j, k, o, gamma, rho, val, sign;

    #  get length of longest cycle.
    k:= pi[1];

    #  determine offset.
    o:= 0;
    while beta[o+1] = o do
       o:= o+1;
    od;

    #  degree case.
    if  k = 1  then

       #  find all beads.
       val:= 1;
       for i in [o+1..Length(beta)] do
          val:= val * (beta[i] - o);

          #  find other free places.
          for j in [o+1..beta[i]-1] do
             if  not j in beta then
                val:= val * (beta[i]-j);
             fi;
          od;

       od;

       return Factorial(n)/val;
    fi;

    #  almost trivial case.
    if k = n then
       if  n + o in beta then
          return (-1)^(Size(beta)+o+1);
       else
          return 0;
       fi;
    fi;

    rho:= pi{[2..Length(pi)]};
    val:= 0;

    #  loop over the beta set.
    for i in beta do
       if  i >= k+o and not i-k in beta  then

          #  compute the leg parity.
          sign:= 1;
          for j in [i-k+1..i-1] do
             if j in beta then
                sign:= -sign;
             fi;
          od;

          #  compute new beta set.
          gamma:= Difference(beta, [i]);
          AddSet(gamma, i-k);

          #  enter recursion.
          val:= val + sign * CharValueSymmetric(n-k, gamma, rho);
       fi;
    od;

    #  return the result.
    return val;
end );


#############################################################################
##
#V  CharTableSymmetric  . . . .  generic character table of symmetric groups.
##
##  Note that this record is accessed in the `Irr' method for natural
##  symmetric groups.
##
BindGlobal( "CharTableSymmetric", Immutable( rec(
    isGenericTable:=
        true,
    identifier:=
        "Symmetric",
    size:=
        Factorial,
    specializedname:=
        ( n -> Concatenation( "Sym(", String(n), ")" ) ),
    text:=
        "generic character table for symmetric groups",
    classparam:=
        [ Partitions ],
    charparam:=
        [ Partitions ],
    centralizers:=
        [ function(n, pi)
            local k, last, p, res;
            res:= 1; last:= 0; k:= 1;
            for p in pi do
               res:= res * p;
               if p = last then
                  k:= k+1;
                  res:= res * k;
               else
                  k:= 1;
               fi;
               last:= p;
            od;
            return res;
          end ],
    orders:=
        [ function(n, lbl) return Lcm(lbl); end ],
    powermap:=
        [ function(n,k,pow) return [1,PowerPartition(k,pow)]; end ],
    irreducibles:=
        [ [ function(n, alpha, pi)
              return CharValueSymmetric(n, BetaSet(alpha), pi);
            end ] ],
    matrix:=
        function(n)
          local scheme, beta, pm, i, m, k, t, col, np, res, charCol;

          scheme:= InductionScheme(n);

          #  how to construct a new column.
          charCol:= function(m, t, k)
             local i, col, pi, val;

             col:= [];
             for pi in scheme[m] do
                val:= 0;
                for i in pi[k] do
                   if i < 0 then
                      val:= val - t[-i];
                   else
                      val:= val + t[i];
                   fi;
                od;
                Add(col, val);
             od;
             return col;
          end;

          #  construct the columns.
          pm:= List([1..n-1], x-> []);
          for m in [1..QuoInt(n,2)] do
             Add(pm[m], charCol(m, [1], m));

             for k in [m+1..n-m] do
                for t in pm[k-m] do
                   Add(pm[k], charCol(k, t, m));
                od;
             od;
          od;

          #  collect and transpose.
          np:= Length(scheme[n]);
          res:= List([1..np], x-> []);
          for k in [1..n-1] do
             for t in pm[n-k] do
                col:= charCol(n, t, k);
                for i in [1..np] do
                   Add(res[i], col[i]);
                od;
             od;
          od;

          col:= charCol(n, [1], n);
          for i in [1..np] do
             Add(res[i], col[i]);
          od;

          return res;
        end,
    domain:=
        IsPosInt
    ) ) );


#############################################################################
##
#V  CharTableAlternating  . .  generic character table of alternating groups.
##
BindGlobal( "CharTableAlternating", Immutable( rec(
    isGenericTable:=
        true,
    identifier:=
        "Alternating",
    size:=
        ( n -> Factorial(n)/2 ),
    specializedname:=
        ( n -> Concatenation( "Alt(", String(n), ")" ) ),
    text:=
        "generic character table for alternating groups",
    classparam:=
        [ function(n)
            local labels, pi, pdodd;

            pdodd:= function(pi)
               local i;
               if pi[1] mod 2 = 0 then
                  return false;
               fi;
               for i in [2..Length(pi)] do
                  if pi[i] = pi[i-1] or pi[i] mod 2 = 0 then
                     return false;
                  fi;
               od;
               return true;
            end;

            labels:= [];
            for pi in Partitions(n) do
               if SignPartition(pi) = 1 then
                  if pdodd(pi) then
                     Add(labels, [pi, '+']);
                     Add(labels, [pi, '-']);
                  else
                     Add(labels, pi);
                  fi;
               fi;
            od;

            return labels;
          end ],
    charparam:=
        [ function(n)
            local alpha, labels;

            labels:= [];
            for alpha in Partitions(n) do
               if alpha = AssociatedPartition(alpha) then
                  Add(labels, [alpha, '+']);
                  Add(labels, [alpha, '-']);
               elif alpha < AssociatedPartition(alpha) then
                  Add(labels, alpha);
               fi;
            od;

            return labels;
          end ],
    centralizers:=
        [ function(n, lbl)
            local cen;
            if Length(lbl) = 2 and not IsInt(lbl[2]) then
               return CharTableSymmetric!.centralizers[1](n, lbl[1]);
            else
               return CharTableSymmetric!.centralizers[1](n, lbl)/2;
            fi;
          end ],
    orders:=
        [ function(n, lbl)
            if Length(lbl) = 2 and not IsInt(lbl[2]) then
               lbl:= lbl[1];
            fi;
            return Lcm(lbl);
          end ],
    powermap:=
        [ function(n, lbl, prime)
            local val, prod;

            #  split case.
            if Length(lbl) = 2 and not IsInt(lbl[2])  then
               prod:= Product( lbl[1], 1 );

               #  coprime case needs complicated check.
               if prod mod prime <>  0 then
                  val:= EB(prod);
                  if val+1 = -GaloisCyc(val, prime) then
                     if lbl[2] = '+' then
                        return [1, [lbl[1], '-']];
                     else
                        return [1, [lbl[1], '+']];
                     fi;
                  else
                     return [1, lbl];
                  fi;
               else
                  return [1, PowerPartition(lbl[1], prime)];
               fi;
            fi;

            #  ordinary case.
            return [1, PowerPartition(lbl, prime)];
          end ],
    irreducibles:=
        [ [ function(n, alpha, pi)
              local val;

              if Length(alpha) = 2 and not IsInt(alpha[2]) then
                 if Length(pi) = 2 and not IsInt(pi[2]) then
                    val:= CharTableSymmetric!.irreducibles[1][1](n,
                              alpha[1], pi[1]);
                    if val in [-1, 1] then
                       if alpha[2] = pi[2] then
                          val:= -val * EB( Product( pi[1], 1 ) );
                       else
                          val:= val * (1 + EB( Product( pi[1], 1 ) ));
                       fi;
                    else
                       val:=  val/2;
                    fi;
                 else
                    val:= CharTableSymmetric!.irreducibles[1][1](n,
                              alpha[1], pi)/2;
                 fi;

              else
                 if Length(pi) = 2 and not IsInt(pi[2]) then
                    val:= CharTableSymmetric!.irreducibles[1][1](n,
                              alpha, pi[1]);
                 else
                    val:= CharTableSymmetric!.irreducibles[1][1](n,
                              alpha, pi);
                 fi;
              fi;

              return val;
            end ] ],
    wholetable := function( gtab, n )
        local pars, classparam, charparam, centralizers, orders, fus,
              classpars, charparsnr, nrpars, i, pi, ord, cen, ass, symvals,
              matrix, nrchars, char, j, val, pow, p, prod;

        pars:= GPartitions( n );
        classparam:= [];
        charparam:= [];
        centralizers:= [];
        orders:= [];
        fus:= [];
        classpars:= [];
        charparsnr:= [];
        nrpars:= Length( pars );

        # class parameters, cent. orders, element orders, char. parameters
        for i in [ 1 .. nrpars ] do
          pi:= pars[i];

          if SignPartition( pi ) = 1 then
            ord:= Lcm( pi );
            cen:= CharTableSymmetric.centralizers[1]( n, pi );
            if Length( Set( pi ) ) = Length( pi )
               and ForAll( pi, IsOddInt ) then
              Add( classparam, [pi, '+'] );
              Add( classparam, [pi, '-'] );
              Add( centralizers, cen );
              Add( centralizers, cen );
              Add( orders, ord );
              Add( fus, i );
            else
              Add( classparam, pi );
              Add( classpars, i );
              Add( centralizers, cen / 2 );
            fi;
            Add( orders, ord );
            Add( fus, i );
          fi;
          ass:= AssociatedPartition( pi );
          if pi = ass then
            Add( charparam, [pi, '+'] );
            Add( charparam, [pi, '-'] );
            Add( charparsnr,i );
            Add( charparsnr,i );
          elif pi < ass then
            Add( charparam, pi );
            Add( charparsnr, i );
          fi;
        od;

        # irreducibles
        symvals:= CharTableSymmetric.matrix( n );
        matrix:= [];
        nrchars:= Length( charparam );
        for i in [ 1 .. nrchars ] do
          char:= [];
          for j in [ 1 .. nrchars ] do
            if Length( charparam[i] ) = 2
               and not IsInt( charparam[i][2] ) then
              if Length( classparam[j] ) = 2
                 and not IsInt( classparam[j][2] ) then
                val:= symvals[ charparsnr[i] ][ fus[j] ];
                if val in [ -1, 1 ] then
                  if charparam[i][2] = classparam[j][2] then
                    val:= -val * EB( Product( classparam[j][1], 1 ) );
                  else
                    val:= val * ( 1 + EB( Product( classparam[j][1], 1 ) ) );
                  fi;
                else
                  val:= val / 2;
                fi;
              else
                val:= symvals[ charparsnr[i] ][ fus[j] ] / 2;
              fi;
            else
              val:= symvals[ charparsnr[i] ][ fus[j] ];
            fi;
            Add( char, val );
          od;
          Add( matrix, char );
        od;

        # power maps
        pow:= [];
        for p in Filtered( [ 2 .. n ], IsPrimeInt ) do
          pow[p]:= [ 1 .. nrchars ];
          for i in [ 1 .. nrchars ] do

            if Length( classparam[i] ) = 2
               and not IsInt( classparam[i][2] ) then
              prod:= Product( classparam[i][1] );
              if prod mod p <> 0 then
                val:= EB( prod );
                if val+1 = -GaloisCyc(val, p) then
                  if classparam[i][2] = '+' then
                    pow[p][i]:= i+1;
                  else
                    pow[p][i]:= i-1;
                  fi;
                else
                  pow[p][i]:= i;
                fi;
              else
                pow[p][i]:= Position( classparam,
                                PowerPartition( classparam[i][1], p ) );
              fi;
            else
              pow[p][i]:= Position( classparam,
                                    PowerPartition( classparam[i], p ) );
            fi;
          od;
        od;

        return rec( Identifier:= Concatenation( "Alt(", String( n ), ")" ),
                    InfoText :=
            "computed using generic character table for alternating groups",
                    UnderlyingCharacteristic:= 0,
                    ClassParameters:= List( classparam, pi -> [ 1, pi ] ),
                    CharacterParameters:= List( charparam, pi -> [ 1, pi ] ),
                    Size:= Factorial( n ) / 2,
                    NrConjugacyClasses:= nrchars,
                    SizesCentralizers:= centralizers,
                    ComputedPowerMaps:= pow,
                    OrdersClassRepresentatives:= orders,
                    Irr:= matrix,
                    ComputedClassFusions:= [ rec(
                        name := Concatenation( "Sym(", String( n ), ")" ),
                        map  := fus ) ] );
        end,
    domain:=
        ( n -> IsInt(n) and n > 1 )
    ) ) );


#############################################################################
##
#F  CharValueWeylB( <n>, <beta>, <pi> ) . . . . . character value in 2 wr Sn.
##
InstallGlobalFunction( CharValueWeylB, function(n, beta, pi)
    local i, j, k, lb, o, s, t, gamma, rho, sign, val;

    #  termination condition.
    if n = 0  then
       return 1;
    fi;

    #  negative cycles first.
    if pi[2] <> [] then
       t:= 2;
    else
       t:= 1;
    fi;

    #  get length of longest cycle.
    k:= pi[t][1];

    #  construct rho.
    rho:= ShallowCopy(pi);
    rho[t]:= pi[t]{[2..Length(pi[t])]};

    val:= 0;

    #  loop over the beta sets.
    for s in [1, 2] do

       #  determine offset.
       o:= 0;
       lb:= Length(beta[s]);
       while o < lb and beta[s][o+1] = o do
          o:= o+1;
       od;

       for i in beta[s] do
          if  i >= k+o and not i-k in beta[s]  then

             #  compute the leg parity.
             sign:= 1;
             for j in [i-k+1..i-1] do
                if j in beta[s] then
                    sign:= -sign;
                fi;
             od;

             #  consider character table of C2.
             if  s = 2 and t = 2  then
                sign:= -sign;
             fi;

             #  construct new beta set.
             gamma:= List(beta, ShallowCopy);
             SubtractSet(gamma[s], [i]);
             AddSet(gamma[s], i-k);

             #  enter recursion.
             val:= val + sign * CharValueWeylB(n-k, gamma, rho);
          fi;
       od;
    od;

    #  return the result.
    return val;

end );


#############################################################################
##
#V  CharTableWeylB  . . . . generic character table of Weyl groups of type B.
##
BindGlobal( "CharTableWeylB", Immutable( rec(
    isGenericTable:=
        true,
    identifier:=
        "WeylB",
    size:=
        ( n -> 2^n * Factorial(n) ),
    specializedname:=
        ( n -> Concatenation( "W(B", String(n), ")" ) ),
    text:=
        "generic character table for Weyl groups of type B",
    classparam:=
        [ ( n -> PartitionTuples(n, 2) ) ],
    charparam:=
        [ ( n -> PartitionTuples(n, 2) ) ],
    centralizers:=
        [ function(n, lbl) return CentralizerWreath([2, 2], lbl); end ],
    orders:=
        [ function(n, lbl)
            local ord;

            ord:= 1;
            if lbl[1] <> [] then
               ord:= Lcm(lbl[1]);
            fi;
            if lbl[2] <> [] then
               ord:= Lcm(ord, 2 * Lcm(lbl[2]));
            fi;

            return ord;
          end ],
    powermap:=
        [ function(n, lbl, pow)
            if pow = 2 then
               return [1, PowerWreath([1, 1], lbl, 2)];
            else
               return [1, PowerWreath([1, 2], lbl, pow)];
            fi;
          end ],
    irreducibles:=
        [ [ function(n, alpha, pi)
              return CharValueWeylB(n,
                         [BetaSet(alpha[1]), BetaSet(alpha[2])], pi);
            end ] ],
    matrix:=
        n -> MatCharsWreathSymmetric( CharacterTable( "Cyclic", 2 ), n),
    domain:=
        IsPosInt
    ) ) );


#############################################################################
##
#V  CharTableWeylD  . . . . generic character table of Weyl groups of type D.
##
BindGlobal( "CharTableWeylD", rec(
    isGenericTable:=
        true,
    identifier:=
        "WeylD",
    size:=
        ( n -> 2^(n-1) * Factorial(n) ),
    specializedname:=
        ( n -> Concatenation( "W(D", String(n), ")" ) ),
    text:=
        "generic character table for Weyl groups of type D",
    classparam:=
        [ function(n)
            local labels, pi;

            labels:= [];
            for pi in PartitionTuples(n, 2) do
               if Length(pi[2]) mod 2 = 0 then
                  if pi[2] = [] and ForAll(pi[1], x-> x mod 2 = 0) then
                     Add(labels, [pi[1], '+']);
                     Add(labels, [pi[1], '-']);
                  else
                     Add(labels, pi);
                  fi;
               fi;
            od;

            return labels;
          end ],
    charparam:=
        [ function(n)
            local alpha, labels;

            labels:= [];

            for alpha in PartitionTuples(n, 2) do
               if alpha[1] = alpha[2] then
                  Add(labels, [alpha[1], '+']);
                  Add(labels, [alpha[1], '-']);
               elif alpha[1] < alpha[2] then
                  Add(labels, alpha);
               fi;
            od;

            return labels;
          end ],
    centralizers:=
        [ function(n, lbl)
            if not IsList(lbl[2]) then
               return CentralizerWreath([2,2], [lbl[1], []]);
            else
               return CentralizerWreath([2,2], lbl) / 2;
            fi;
          end ],
    orders:=
        [ function(n, lbl)
            local ord;

            ord:= 1;
            if lbl[1] <> [] then
               ord:= Lcm(lbl[1]);
            fi;
            if lbl[2] <> [] and IsList(lbl[2]) then
               ord:= Lcm(ord, 2*Lcm(lbl[2]));
            fi;

            return ord;
          end ],
    powermap:=
        [ function(n, lbl, pow)
            local power;

            if not IsList(lbl[2]) then
               power:= PowerPartition(lbl[1], pow);
               if ForAll(power, x-> x mod 2 = 0) then
                  return [1, [power, lbl[2]]];   #  keep the sign.
               else
                  return [1, [power, []]];
               fi;
            else
               if pow = 2 then
                  return [1, PowerWreath([1, 1], lbl, 2)];
               else
                  return [1, PowerWreath([1, 2], lbl, pow)];
               fi;
            fi;
          end ],

    irreducibles:=
        [ [ function(n, alpha, pi)
              local delta, val;

              if not IsList(alpha[2]) then
                 delta:= [alpha[1], alpha[1]];
                 if not IsList(pi[2]) then
                    val:= CharTableWeylB!.irreducibles[1][1](n,
                              delta, [pi[1], []])/2;
                    if alpha[2] = pi[2] then
                       val:= val + 2^(Length(pi[1])-1) *
                         CharTableSymmetric!.irreducibles[1][1](n/2,
                             alpha[1], pi[1]/2);
                    else
                       val:= val - 2^(Length(pi[1])-1) *
                         CharTableSymmetric!.irreducibles[1][1](n/2,
                             alpha[1], pi[1]/2);
                    fi;
                 else
                    val:= CharTableWeylB!.irreducibles[1][1](n, delta, pi)/2;
                 fi;
              else
                 if not IsList(pi[2]) then
                    val:= CharTableWeylB!.irreducibles[1][1](n,
                              alpha, [pi[1], []]);
                 else
                    val:= CharTableWeylB!.irreducibles[1][1](n, alpha, pi);
                 fi;
              fi;

              return val;
            end ] ],
    domain:=
        ( n -> IsInt(n) and n > 1 )
    ) );
CharTableWeylD.matrix := function(n)
  local matB, matA, paramA, paramB, clp, chp, ctb, cta, val;
  matB := CharTableWeylB!.matrix(n);
  if n mod 2 = 0 then
    matA := CharTableSymmetric!.matrix(n/2);
    paramA := Partitions(n/2);
  fi;
  paramB := PartitionTuples(n, 2);
  clp := CharTableWeylD!.classparam[1](n);
  chp := CharTableWeylD!.charparam[1](n);
  ctb := function(alpha, pi)
    return matB[Position(paramB, alpha)][Position(paramB, pi)];
  end;
  cta := function(alpha, pi)
    return matA[Position(paramA, alpha)][Position(paramA, pi)];
  end;

  val := function(alpha, pi)
    local delta, val;
    if not IsList(alpha[2]) then
      delta := [alpha[1], alpha[1]];
      if not IsList(pi[2]) then
        val := ctb(delta, [pi[1], []])/2;
        if alpha[2] = pi[2] then
          val := val + 2^(Length(pi[1])-1) * cta(alpha[1], pi[1]/2);
        else
          val := val - 2^(Length(pi[1])-1) * cta(alpha[1], pi[1]/2);
        fi;
      else
        val := ctb(delta, pi)/2;
      fi;
    else
      if not IsList(pi[2]) then
        val := ctb(alpha, [pi[1], []]);
      else
        val := ctb(alpha, pi);
      fi;
    fi;
    return val;
  end;
  return List(chp, alpha-> List(clp, pi-> val(alpha, pi)));
end;
MakeImmutable(CharTableWeylD);


#############################################################################
##
#F  CharacterValueWreathSymmetric( <tbl>, <n>, <beta>, <pi> ) . .
#F                                        . . . .  character value in G wr Sn
##
InstallGlobalFunction( CharacterValueWreathSymmetric,
    function( sub, n, beta, pi )
    local i, j, k, lb, o, s, t, r, gamma, rho, sign, val, subirreds;

    #  termination condition.
    if n = 0  then
       return 1;
    fi;

    r:= Length(pi);

    #  negative cycles first.
    t:= r;
    while pi[t] = [] do
       t:= t-1;
    od;

    #  get length of longest cycle.
    k:= pi[t][1];

    #  construct rho.
    rho:= ShallowCopy(pi);
    rho[t]:= pi[t]{[2..Length(pi[t])]};

    val:= 0;

    subirreds:= List( Irr( sub ), ValuesOfClassFunction );

    #  loop over the beta sets.
    for s in [1..r] do

       #  determine offset.
       o:= 0;
       lb:= Length(beta[s]);
       while o < lb and beta[s][o+1] = o do
          o:= o+1;
       od;

       for i in beta[s] do
          if  i >= k+o and not i-k in beta[s]  then

             #  compute the leg parity.
             sign:= 1;
             for j in [i-k+1..i-1] do
                if j in beta[s] then
                    sign:= -sign;
                fi;
             od;

             #  consider character table <sub>.
             sign:= subirreds[s][t] * sign;

             #  construct new beta set.
             gamma:= ShallowCopy(beta);
             gamma[s]:= ShallowCopy( gamma[s] );
             RemoveSet( gamma[s], i );
             AddSet(gamma[s], i-k);

             #  enter recursion.
             val:= val +
                sign * CharacterValueWreathSymmetric( sub, n-k, gamma, rho );
          fi;
       od;
    od;

    #  return the result.
    return val;

end );


#############################################################################
##
#F  CharacterTableWreathSymmetric( <sub>, <n> )  . .  char. table of G wr Sn.
##
InstallGlobalFunction( CharacterTableWreathSymmetric, function( sub, n )
    local i, j,             # loop variables
          tbl,              # character table, result
          ident,            # identifier of 'tbl'
          nccs,             # no. of classes of 'sub'
          nccl,             # no. of classes of 'tbl'
          parts,            # partitions parametrizing classes and characters
          subcentralizers,  # centralizer orders of 'sub'
          suborders,        # representative orders of 'sub'
          orders,           # representative orders of 'tbl'
          powermap,         # power maps of 'tbl'
          prime,            # loop over prime divisors of the size of 'tbl'
          spm;              # one power map of 'sub'

    if not IsOrdinaryTable( sub ) then
      Error( "<sub> must be an ordinary character table" );
    fi;

    # Make a record, and set the values of `Size', `Identifier', \ldots
    ident:= Concatenation( Identifier( sub ), "wrS", String(n) );
    ConvertToStringRep( ident );

    tbl:= rec( UnderlyingCharacteristic := 0,
               Size                     := Size( sub )^n * Factorial( n ),
               Identifier               := ident );

    # \ldots, `ClassParameters', \ldots
    nccs:= NrConjugacyClasses( sub );
    parts:= Immutable( PartitionTuples(n, nccs) );
    nccl:= Length(parts);
    tbl.ClassParameters:= parts;

    # \ldots, `OrdersClassRepresentatives', \ldots
    subcentralizers:= SizesCentralizers( sub );
    suborders:= OrdersClassRepresentatives( sub );
    orders:= [];
    for i in [1..nccl] do
       orders[i]:= 1;
       for j in [1..nccs] do
         if parts[i][j] <> [] then
            orders[i]:= Lcm(orders[i], suborders[j]*Lcm(parts[i][j]));
         fi;
       od;
    od;
    tbl.OrdersClassRepresentatives:= orders;

    # \ldots, `SizesCentralizers', `CharacterParameters', \ldots
    tbl.SizesCentralizers:= List( parts,
        p -> CentralizerWreath( subcentralizers, p ) );
    tbl.CharacterParameters:= parts;

    # \ldots, `ComputedPowerMaps', \ldots
    tbl.ComputedPowerMaps:= [];
    powermap:= tbl.ComputedPowerMaps;
    for prime in PrimeDivisors( tbl.Size ) do
       spm:= PowerMap( sub, prime );
       powermap[prime]:= MakeImmutable( List( [ 1 .. nccl ],
           i -> Position(parts, PowerWreath(spm, parts[i], prime)) ) );
    od;

    # \ldots and `Irr'.
    tbl.Irr:= MatCharsWreathSymmetric( sub, n );

    # Return the table.
    ConvertToLibraryCharacterTableNC( tbl );
    return tbl;
end );


#############################################################################
##
#M  Irr( <Sn> )
##
##  Use `CharTableSymmetric' (see above) for computing the irreducibles;
##  use the class parameters (partitions) in order to make the table
##  compatible with the conjugacy classes of <Sn>.
##
##  Note that we do *not* call `CharacterTable( "Symmetric", <n> )' directly
##  because the character table library may be not installed.
##
InstallMethod( Irr,
    "ordinary characters for natural symmetric group",
    [ IsNaturalSymmetricGroup, IsZeroCyc ],
    function( G, zero )
    local gentbl, dom, deg, cG, cp, perm, i, irr, pow, fun, p;

    gentbl:= CharTableSymmetric;
    dom:= MovedPoints( G );
    deg:= Length( dom );
    if deg = 0 then
      dom:= [ 1 ];
      deg:= 1;
    fi;
    cG:= CharacterTable( G );

    # Compute the correspondence of classes.
    cp:= gentbl.classparam[1]( deg );
    perm:= [];
    for i in ConjugacyClasses( G ) do
      i:= List( Orbits( SubgroupNC( G, [ Representative(i) ] ), dom ),
                Length );
      Sort( i );
      Add( perm, Position( cp, Reversed( i ) ) );
    od;

    # Compute the irreducibles.
    irr:= List( gentbl.matrix( deg ), i -> Character( cG, i{ perm } ) );
    MakeImmutable( irr );
    SetIrr( cG, irr );

    # Store the class and character parameters.
    cp:= List( cp{ perm }, x -> [ 1, x ] );
    MakeImmutable( cp );
    SetClassParameters( cG, cp );
    SetCharacterParameters( cG, cp );

    # Compute and store the power maps.
    pow:= ComputedPowerMaps( cG );
    fun:= gentbl.powermap[1];
    for p in PrimeDivisors( Size( G ) ) do
      if not IsBound( pow[p] ) then
        pow[p]:= MakeImmutable(
                     List( cp, x -> Position( cp, fun( deg, x[2], p ) ) ) );
      fi;
    od;

    # Compute and store centralizer orders and representative orders.
    if not HasSizesCentralizers( cG ) then
      SetSizesCentralizers( cG,
          List( cp, x -> gentbl.centralizers[1]( deg, x[2] ) ) );
    fi;
    if not HasOrdersClassRepresentatives( cG ) then
      SetOrdersClassRepresentatives( cG,
          List( cp, x -> gentbl.orders[1]( deg, x[2] ) ) );
    fi;
    SetInfoText( cG, Concatenation( "computed using ", gentbl.text ) );

    # Return the irreducibles.
    return irr;
end );


#############################################################################
##
#F  DescendingListWithElementRemoved( <list>, <el> )
##
##  For a list <list> whose elements are descending and an element <el> of
##  <list>, `DescendingListWithElementRemoved' returns the descending list
##  obtained by removing <el>.
##
BindGlobal( "DescendingListWithElementRemoved", function( list, el )
    local pos, res;

    pos:= PositionSorted( list, el, function( a, b ) return \<( b, a ); end );
    res:= list{ [ 1 .. pos-1 ] };
    Append( res, list{ [ pos+1 .. Length( list ) ] } );
    return res;
    end );


#############################################################################
##
#F  MorrisRecursion( <lambda>, <pi> )
##
##  For a bar partition <lambda> of $n$, for some positive integer $n$,
##  and an odd parts partition <pi> of the same $n$ and different from
##  <lambda>, `MorrisRecursion' returns the value of the spin character
##  indexed by <lambda> on the class indexed by <pi>.
##  If the class of <pi> splits in the double cover of the symmetric group of
##  degree $n$ then the returned value is attained on the class containing
##  the Schur standard lift of <pi>.
##
DeclareGlobalFunction( "MorrisRecursion" );

InstallGlobalFunction( MorrisRecursion, function( lambda, pi )
    local n, sigma, k, P, i, j, rho, val, GT, sign, m, gamma, l;

    n:= Sum( lambda );
    sigma:= QuoInt( n - Length( lambda ), 2 );

    # base case
    if pi = [] then
      return 1;
    fi;

    # get largest part
    k:= pi[1];

    # degree case
    if k = 1 then
      # calc degree
      P:= 2^sigma * Factorial( n );
      for i in [ 1 .. Length( lambda ) ] do
        for j in [ i+1 .. Length( lambda ) ] do
          P:= ( lambda[i] - lambda[j] ) / ( lambda[i] + lambda[j] ) * P;
        od;
        P:= P / Factorial( lambda[i] );
      od;
      return P;
    fi;

    rho:= pi{ [ 2 .. Length( pi ) ] };
    val:= 0;

    GT:= function( a, b ) return LT( b, a ); end;

    for i in lambda do
      if i >= k and not i-k in lambda then

        # leg parity
        sign:= 1;
        for j in [ i-k+1 .. i-1 ] do
          if j in lambda then
            sign:= -sign;
          fi;
        od;

        # 2 power
        m:= 1;

        if i > k then
          if IsEvenInt( n - Length( lambda ) ) then
            m:= 2;
          fi;
        fi;

        # compute new lambda
        gamma:= DescendingListWithElementRemoved( lambda, i );
        if i > k then
          Add( gamma, i-k );
          Sort( gamma, GT );
        fi;

        val:= val + sign * m * MorrisRecursion( gamma, rho );
      fi;

      #I_- removal
      if i <= (k - 1) / 2 and k - i in lambda then

        # calc. leg parity by pos. of smaller bead plus no. of beads
        # between conj. beads
        sign:= (-1)^i;
        for l in [ i+1 .. k-1-i ] do
          if l in lambda then
            sign:= -sign;
          fi;
        od;


        # 2 power
        m:= 1;
        if IsEvenInt( n - Length( lambda ) ) then
          m:= 2;
        fi;

        # compute new lambda
        gamma:= DescendingListWithElementRemoved( lambda, i );
        gamma:= DescendingListWithElementRemoved( gamma, k-i );

        # enter recursion
        val:= val + sign * m * MorrisRecursion( gamma, rho );
      fi;

    od;

    # return the result
    return val;
    end );


#############################################################################
##
#F  CharValueDoubleCoverSymmetric( <n>, <lambda>, <pi> )
##
##  For a bar partition <lambda> and a partition <pi> of the positive integer
##  <n>, `CharValueDoubleCoverSymmetric' returns the value of the spin
##  character of the standard Schur double cover of the symmetric group of
##  degree <n> that is indexed by <lambda>, on the class that is indexed by
##  <pi>.
##
BindGlobal( "CharValueDoubleCoverSymmetric", function( n, lambda, pi )
    if IsEvenInt( n - Length( pi ) ) then  # pi is even
      if not ForAll( pi, IsOddInt ) then   # pi is not in O(n)
        return 0;
      else  # pi is in O(n)
        return MorrisRecursion( lambda, pi );
      fi;
    else  # pi is odd
      if Length( Set( pi ) ) <> Length( pi ) then
        return 0;
      else  # pi is bar partition
        if IsEvenInt( n - Length( lambda ) ) or lambda <> pi then
          return 0;
        else  # exceptional case
          return E(4)^( ( n - Length( lambda ) + 1 ) / 2 )
                 * ER( Product( lambda ) / 2 );
        fi;
      fi;
    fi;
    end );


##########################################################################
##
#F  BarPartitions( <n> )
##
##  For a non-negative integer <n>, `BarPartitions' returns the list of all
##  bar partitions of <n>.
##
BindGlobal( "BarPartitions", function( n )
    local B, j, k, l, p;
    B:= List( [ 1 .. n-2 ], x -> [] );
    for k in [ 1 .. QuoInt( n-1, 2 ) ] do
      j:= n-k-1;
      while j >= k+1 do
        for p in B[ j-k ] do
          l:= [ n-j ];
          Append( l, p );
          l[2]:= k;
          Add( B[j], l );
        od;
        j:= j - 1;
      od;
      Add( B[k], [ n-k, k ] );
    od;
    l:= Concatenation( B{ [ n-2, n-3 .. 1 ] } );
    Add( l, [ n ] );
    return l;
    end );


###########################################################################
##
#F  SpinInductionScheme( <n> )
##
##  For a non-negative integer <n>, `SpinInductionScheme' returns the spin
##  induction scheme for <n>.
##  The entry at position $[m][i][k]$ is the list of positions (with mult.)
##  of all bar partitions of $m-k$ that are obtained by removing a $k$ bar
##  from the $i$-th bar partition of $m$.
##
BindGlobal( "SpinInductionScheme", function( n )
    local GT, bpm, scheme, bars, i, lambda;

    GT:= function( a, b ) return LT( b, a ); end;
    bpm:= [];  # bar partitions of m
    scheme:= [];

    bars:= function( lambda )
      local m, brs, i, z, sign, max, j, gamma, l;

      m:= Sum( lambda );

      brs:= [];    # init bar list, for every possible bar length a list
      for i in [ 1 .. m ] do
        brs[i]:= [];
      od;

      z:= 1;
      if ( m - Length( lambda ) ) mod 2 = 0 then
        z:= 2;
      fi;

      for i in lambda do

        sign:= 1;
        for j in [ 1 .. i ] do
          if i-j in lambda then
            sign:= -sign;
          elif j mod 2 = 1 then
            if j = m then
              if i <> j then
                Add( brs[m], [ 1, sign * z ] );
              else
                Add( brs[m], [ 1, sign ] );  # case I_0, no 2
              fi;
            else
              gamma:= DescendingListWithElementRemoved( lambda, i );
              if i <> j then
                Add( gamma, i-j );
                Sort( gamma, GT );
                Add( brs[j], [ Position( bpm[m-j], gamma ), sign*z ] );
              else
                # case I_0, no 2
                Add( brs[j], [ Position( bpm[m-j], gamma ), sign ] );
              fi;
            fi;
          fi;
        od;
      od;

      #I- removal
      max:= m;
      if max mod 2 = 0 then
        max:= max-1;
      fi;
      for j in [ 3, 5 .. max ] do  #j-bar removal from partition lambda
        for i in [ 1 .. (j-1)/2 ] do
          if i in lambda and j-i in lambda then
            if j = m then
              sign:= (-1)^i;
              Add( brs[m], [ 1, sign*z ] );
            else
              # calc leg parity by pos. of smaller bead plus no. of beads
              # between conj. beads
              sign:= (-1)^i;
              for l in [ i+1 .. j-1-i ] do
                if l in lambda then
                sign:= -sign;
                fi;
              od;

              gamma:= DescendingListWithElementRemoved( lambda, i );
              gamma:= DescendingListWithElementRemoved( gamma, j-i );

              Add( brs[j], [ Position( bpm[ m-j ], gamma ), sign * z ] );
            fi;
          fi;

        od;
      od;

      return brs;
    end;

    for i in [ 1 .. n ] do
      bpm[i]:= BarPartitions( i );
      scheme[i]:= [];
      for lambda in bpm[i] do
        Add( scheme[i], bars( lambda ) );
      od;
    od;

    return scheme;
    end );


########################################################################
##
#F  OddSpinVals( <n> )
##
##  For a non-negative integer <n>, `OddSpinVals' returns a matrix that
##  contains the values of the spin characters of the standard double cover
##  of the symmetric group of degree <n>,
##  where it is assumed that the columns are indexed by odd part partitions.
##
BindGlobal( "OddSpinVals", function( n )
    local scheme, charCol, pm, m, k, t, np, res, col, i, max;

    scheme:= SpinInductionScheme( n );

    charCol:= function( m, t, k)  # t column of the char. table of S_{m-k}
      local i, col, pi, val;

      col:= [];
      for pi in scheme[m] do
        val:= 0;
        for i in pi[k] do
          val:= val + i[2] * t[ i[1] ];
        od;
        Add( col, val );
      od;
      return col;
    end;

    pm:= List( [ 1 .. n-1 ], x -> [] );
    max:= QuoInt( n, 2 );
    if max mod 2 = 0 then
      max:= max - 1;
    fi;
    for m in [ 1, 3 .. max ] do  # only odd parts can be removed
      Add( pm[m], charCol( m, [1], m ) );
      for k in [ m+1 .. n-m ] do
        for t in pm[ k-m ] do
          Add( pm[k], charCol( k, t, m ) );
        od;
      od;
    od;

    np:= Length( scheme[n] );
    res:= List( [ 1 .. np ], x -> [] );
    for k in [ 1 .. n-1 ] do
      if k mod 2 = 1 then
        for t in pm[ n-k ] do
          col:= charCol( n, t, k );
          for i in [ 1 .. np ] do
            Add( res[i], col[i] );
          od;
        od;
      fi;
    od;

    col:= charCol( n, [1], n );
    for i in [ 1 .. np ] do
      Add( res[i], col[i] );
    od;

    return res;
    end );


######################################################################
##
#F  MatrixSpinCharsSn( <n> )
##
##  For a non-negative integer <n>, `MatrixSpinCharsSn' returns the matrix
##  of spin characters of the standard Schur double cover of the symmetric
##  group of degree <n>.
##
BindGlobal( "MatrixSpinCharsSn", function( n )
    local matrix, pars, bars, oddvals, i, char, achar, counter, pi;

    matrix:= [];
    pars:= GPartitions( n );
    bars:= BarPartitions( n );
    oddvals:= OddSpinVals( n );

    for i in [ 1 .. Length( bars ) ] do

      char:= [];
      achar:= [];
      counter:= 1;

      for pi in pars do
        if ForAll( pi, IsOddInt ) then
          Add( char, oddvals[i][ counter ] );
          Add( char, -oddvals[i][ counter ] );
          Add( achar, oddvals[i][ counter ] );
          Add( achar, -oddvals[i][ counter ] );

          counter:= counter+1;

        elif IsOddInt( n - Length( bars[i] ) ) and bars[i] = pi then
          Add( char, E(4)^( ( n - Length( bars[i] ) + 1 ) / 2 )
                     * ER( Product( bars[i] ) / 2 ) );
          Add( char, -char[ Length( char ) ] );

          Add( achar, char[ Length( char ) ] );
          Add( achar, -achar[ Length( achar ) ] );

        else
          Add( char, 0 );
          Add( achar, 0 );
          if Length( Set( pi ) ) = Length( pi )
             and IsOddInt( n-Length(pi) ) then
            Add( char, 0 );
            Add( achar,0 );
          fi;

        fi;
      od;
      Add( matrix, char );
      if IsOddInt( n-Length(bars[i]) ) then
        Add( matrix, achar );
      fi;

    od;
    return matrix;
    end );


################################################################################
##
#F  OrderOfSchurLift( <pi> )
##
##  For a partition <pi>, `OrderOfSchurLift' returns the order of the Schur
##  standard lift of an element of cycle type <pi> in a symmetric group
##  to the standard double cover.
##
BindGlobal( "OrderOfSchurLift", function( pi )
    local ord, evencount, z, i;

    ord:= Lcm( pi );
    evencount:= 0;
    z:= 1;
    for i in pi do
      if i mod 2 = 1 then
        if QuoInt( i^2-1, 8 ) mod 2 = 1 and QuoInt( ord, i ) mod 2 = 1 then
          z:= -z;
        fi;
      else
        evencount:= evencount + 1;
        if ( QuoInt( i, 2 ) mod 4 = 1 or QuoInt( i, 2 ) mod 4 = 2 ) and
           QuoInt( ord, i ) mod 2 = 1 then
          z:= -z;
        fi;
      fi;
    od;

    if ( evencount mod 4 = 2 or evencount mod 4 = 3 ) and
       QuoInt( ord, 2 ) mod 2 = 1 then
      z:= -z;
    fi;

    if z = -1 then
      return 2*ord;
    else
      return ord;
    fi;
    end );


###########################################################################
##
#V  CharTableDoubleCoverSymmetric
##
BindGlobal( "CharTableDoubleCoverSymmetric", MakeImmutable ( rec(
    isGenericTable:=
        true,
    identifier:=
        "DoubleCoverSymmetric",
    size:=
        ( n -> 2 * Factorial( n ) ),
    specializedname:=
        ( n -> Concatenation( "2.Sym(", String(n), ")" ) ),
    text:=
        "generic character table for a double cover of symmetric groups",
    wholetable:=
        function( gtab, n )
        local parts,  nrparts,  dist,  distmin,  odd,  clpar,  chpar,
              fus,  ord,  cen,  i,  p,  m,  o,  c,  nrch,  nrcl,  invfus,
              chars,  pow,  j,  irr;

        parts:= GPartitions( n );
        nrparts:= Length( parts );
        dist:= [];        # BarPartitions
        distmin:= [];     # odd BarPartitions
        odd:= [];         # OddPartPartitions
        clpar:= [];       # ClassParameters
        chpar:= [];       # CharacterParameters
        fus:= [];
        ord:= [];         # OrdersClassRepresentatives
        cen:= [];         # SizesCentralizer

        for i in [ 1 .. nrparts ] do
          p:= parts[i];
          m:= Length( p );
          Add( clpar, [ 1, p ] );
          Add( fus, i );
          o:= OrderOfSchurLift( p );
          Add( ord, o );
          c:= CharTableSymmetric.centralizers[1]( n, p );

          if ForAll( p, IsOddInt ) then  # class splits
            Add( odd, i );
            Add( clpar, [ 2, p ] );
            Add( fus, i );
            if IsOddInt( o ) then
              Add( ord, 2 * o );
            else
              Add( ord, o / 2 );
            fi;
            c:= 2 * c;
            Add( cen, c );
          fi;

          if Length( Set( p ) ) = Length( p ) then
            Add( dist, i );
            Add( chpar, p );
            if IsOddInt( n-m ) then  # class splits
              Add( distmin, i );
              Add( chpar, p );
              Add( clpar, [ 2, p ] );
              Add( fus, i );
              Add( ord, o );
              c:= 2 * c;
              Add( cen, c );
            fi;
          fi;
          Add( cen, c );
        od;

        # spin characters
        nrch:= Length( chpar );
        nrcl:= Length( clpar );
        invfus:= InverseMap( fus );
        chars:= MatrixSpinCharsSn( n );

        # power maps
        pow:= [];
        for p in Filtered( [ 2 .. n ], IsPrimeInt ) do
          pow[p]:= [ 1 .. nrcl ] ;
          for i in [1 .. nrcl ] do
            j:= invfus[ Position( parts,
                                  PowerPartition( parts[ fus[i] ], p ) ) ];
            if IsInt( j ) then
              pow[p][i]:= j;
            else
              o:= ord[i];
              if ( o mod p = 0 ) then
                o:= o / p;
              fi;
              if ord[j[1]] <> o then
                pow[p][i]:= j[2];
              elif ord[j[2]] <> o then
                pow[p][i]:= j[1];
              else
                c:= Position( chpar, parts[ fus[i] ] );
                if GaloisCyc( chars[c][i], p ) = chars[c][ j[1] ] then
                  pow[p][i]:= j[1];
                else
                  pow[p][i]:= j[2];
                fi;
              fi;
            fi;
          od;
          MakeImmutable( pow[p] );
        od;

        # Make the character parameters unique.
        for i in [ 2 .. Length( chpar ) ] do
          if chpar[i] = chpar[i-1] then
            chpar[i-1] := [ chpar[i], '+' ];
            chpar[i]   := [ chpar[i], '-' ];
          fi;
        od;

        # the spin character table record
        return rec( Identifier := Concatenation( "2.Sym(", String(n), ")" ),
                    UnderlyingCharacteristic:= 0,
                    ClassParameters:= clpar,
                    CharacterParameters:= Concatenation(
                                            List( parts, x -> [ 1, x ] ),
                                            List( chpar, x -> [ 2, x ] ) ),
                    Size:= 2 * Factorial( n ),
                    NrConjugacyClasses:= nrcl,
                    SizesCentralizers:= cen,
                    ComputedPowerMaps:= pow,
                    OrdersClassRepresentatives:= ord,
                    ComputedClassFusions:=
                        [ rec( name:= Concatenation("Sym(",String(n),")"),
                               map:= MakeImmutable( fus ) ) ],
                    Irr:= MakeImmutable( Concatenation(
                              CharTableSymmetric.matrix( n )
                              { [ 1 .. nrparts ] }{ fus }, chars ) ) );
        end,
    domain:= IsPosInt ) ) );


#############################################################################
##
#V  CharTableDoubleCoverAlternating
##
BindGlobal( "CharTableDoubleCoverAlternating", MakeImmutable( rec(
    isGenericTable:=
        true,
    identifier:=
        "DoubleCoverAlternating",
    size:=
        Factorial,
    specializedname:=
        ( n -> Concatenation( "2.Alt(", String(n), ")" ) ),
    text:=
        "generic character table for the double cover of alternating groups",
    matrix:=
        function( n )
        local matrix, pars, bars, oddvals, evenpars, i, char1, char2,
              counter, pi, delta, alpha, beta;

        matrix:= [];
        pars:= GPartitions( n );
        bars:= BarPartitions( n );
        oddvals:= OddSpinVals( n );

        evenpars:= Filtered( pars, pi -> IsEvenInt( n - Length( pi ) ) );

        for i in [ 1 .. Length( bars ) ] do
          char1:= [];
          char2:= [];
          counter:=1;
          for pi in evenpars do

            if IsEvenInt( n - Length( bars[i] ) ) then  # 2 conj characters

              delta:=0;

              if ForAll( pi, IsOddInt ) then

                if bars[i] = pi then
                  delta:= E(4)^( QuoInt( n - Length( pi ), 2 ) mod 4 )
                          * ER( Product( pi ) );
                fi;

                alpha:= ( oddvals[i][counter] + delta ) / 2;
                beta:= ( oddvals[i][counter] - delta ) / 2;

                if Length( Set( pi ) ) = Length( pi ) then
                  Add( char1, alpha );    Add( char2, beta );
                  Add( char1, - alpha );  Add( char2, - beta );
                  Add( char1, beta );     Add( char2, alpha );
                  Add( char1, - beta );   Add( char2, - alpha );
                else
                  Add( char1, oddvals[i][counter] / 2 );
                  Add( char2, oddvals[i][counter] / 2 );
                  Add( char1, -oddvals[i][counter] / 2 );
                  Add( char2, -oddvals[i][counter] / 2 );
                fi;
                counter:= counter + 1;

              elif Length( Set( pi ) ) = Length( pi ) then

                if bars[i] = pi then
                  delta:= E(4)^( QuoInt( n - Length( pi ), 2 ) mod 4 )
                          * ER( Product( pi ) );
                fi;

                Add( char1, delta / 2 );
                Add( char1, - delta / 2 );
                Add( char2, - delta / 2 );
                Add( char2, delta / 2 );
              else
                Add( char1, 0 );
                Add( char2, 0 );
              fi;

            else  #one restricted character
              if ForAll( pi, IsOddInt ) then  ##Odd
                if Length( Set( pi ) ) = Length( pi ) then
                  Add( char1, oddvals[i][counter] );
                  Add( char1, -oddvals[i][counter] );
                  Add( char1, oddvals[i][counter] );
                  Add( char1, -oddvals[i][counter] );
                  counter:= counter+1;
                else
                  Add( char1, oddvals[i][counter] );
                  Add( char1, -oddvals[i][counter] );
                  counter:= counter+1;
                fi;
              elif Length( Set( pi ) ) = Length( pi ) then  ## D+ w/o O
                Add( char1, 0 );
                Add( char1, 0 );
              else
                Add( char1, 0 );
              fi;
            fi;
          od;

          Add( matrix, char1 );
          if IsEvenInt( n - Length( bars[i] ) ) then
            Add( matrix, char2 );
          fi;
        od;
        return matrix;
        end,
    wholetable:=
        function( gtab, n )
        local parts,  nrparts,  exp,  distpos,  dist,  odd,  clpar,
                chpar,  fus0,  fus1,  fus2,  ord,  cen,  altclpar,
                symclpar,  i,  p,  m,  mm,  o,  c,  j,  nrch,  nrcl,
                invfus0,  nullrow,  chars,  lambda,  compl,  val,  primes,
                pow,  k,  nr,  tbl,  irr,  altpar,  par;

        parts:= Partitions( n );
        nrparts:= Length( parts );
        distpos:= [];
        dist:= [];
        odd:= [];
        clpar:= [];
        chpar:= [];
        fus0:= [];
        fus1:= [];
        fus2:= [];
        ord:= [];
        cen:= [];
        altclpar:= [];
        symclpar:= [];
        for i in [ 1 .. nrparts ] do
          p:= parts[i];
          m:= Length( p );
          o:= OrderOfSchurLift( p );

          c:= CharTableSymmetric.centralizers[1]( n, p );

          if IsOddInt( n-m ) then  # - type, odd partition
            Add( symclpar, p );
            if Length( Set( p ) ) = Length( p ) then  # distinct
              Add( dist, i );
              Add( symclpar, p );
              Add( chpar, p );
            fi;
          else  # + type, even partition
            Add( altclpar, p );
            Add( symclpar, p );
            Add( clpar, p );
            Add( fus0, i );
            Add( fus1, Length( altclpar ) );
            Add( fus2, Length( symclpar ) );
            Add( ord,o);
            if ForAll( p, IsOddInt ) then
              Add( odd, i );
              Add( symclpar, p );
              Add( clpar, p );
              Add( fus0, i );
              Add( fus1, Length( altclpar ) );
              Add( fus2, Length( symclpar ) );
              if IsOddInt( o ) then
                Add( ord, 2 * o );
              else
                Add( ord, o / 2 );
              fi;
            fi;
            if Length( Set( p ) ) = Length( p ) then  # distpos
              Add( dist, i );
              Add( distpos, i );
              Add( chpar, p );
              Add( chpar, p );
              if ForAll( p, IsOddInt ) then  # distpos + odd
                Add( altclpar, p );
                Add( clpar, p );
                Add( fus0, i );
                Add( fus1, Length( altclpar ) );
                Add( fus2, Length( symclpar )-1 );
                Add( ord, o );
                Add( clpar, p );
                Add( fus0, i );
                Add( fus1, Length( altclpar ) );
                Add( fus2, Length( symclpar ) );
                if IsOddInt( o ) then
                  Add( ord, 2 * o );
                else
                  Add( ord, o / 2 );
                fi;
                c:= 2 * c;
                Add( cen, c );
                Add( cen, c );
                Add( cen, c );
              else  # distpos - odd
                Add( clpar, p );
                Add( fus0, i );
                Add( fus1, Length( altclpar ) );
                Add( fus2, Length( symclpar ) );
                Add( ord, o );
                Add( cen, c );
              fi;
            else  # pos - distpos
              if ForAll( p, IsOddInt ) then  # odd - distpos
                Add( cen, c );
              else  # pos - (distpos + odd)
                c:= QuoInt( c, 2 );
              fi;
            fi;
            Add( cen, c );
          fi;
        od;

        # spin characters
        nrch:= Length( chpar );
        nrcl:= Length( clpar );
        invfus0:= InverseMap( fus0 );
        chars:= CharTableDoubleCoverAlternating.matrix( n );

        # power maps
        pow:= [];
        for p in Filtered( [ 2 .. n ], IsPrimeInt ) do
          pow[p]:= [ 1 .. nrcl ];
          for i in [ 1 .. nrcl ] do
            j:= Position( parts, PowerPartition( parts[ fus0[i] ], p ) );
            k:= invfus0[j];
            if IsInt( k ) then
              pow[p][i]:= k;
            else
              o:= ord[i];
              if ( o mod p = 0 ) then
                o:= o / p;
              fi;
              if j in odd then
                if j in distpos then
                  if ord[ k[1] ] <> o then
                    k:= k{ [ 2, 4 ] };
                  else
                    k:= k{ [ 1, 3 ] };
                  fi;
                  c:= Position( chpar, parts[ fus0[i] ] );
                  val:= GaloisCyc( chars[c][i], p );
                  if IsCycInt( ( val-chars[c][ k[1] ] ) / p ) then
                    pow[p][i]:= k[1];
                  else
                    pow[p][i]:= k[2];
                  fi;
                else
                  if ord[ k[1] ] <> o then
                    pow[p][i]:= k[2];
                  else
                    pow[p][i]:= k[1];
                  fi;
                fi;
              else
                c:= Position( chpar, parts[ fus0[i] ] );
                if GaloisCyc( chars[c][i], p ) = chars[c][ k[1] ] then
                  pow[p][i]:= k[1];
                else
                  pow[p][i]:= k[2];
                fi;
              fi;
            fi;
          od;
          MakeImmutable( pow[p] );
        od;

        # add the characters of Alt_n
        tbl:= CharTableAlternating.wholetable( CharTableAlternating, n );

        # Make the class and character parameters unique.
        clpar:= tbl.ClassParameters{ fus1 };
        for i in [ 2 .. Length( clpar ) ] do
          if fus1[i] = fus1[i-1] then
            clpar[i]:= ShallowCopy( clpar[i] );
            clpar[i][1]:= 2;
          fi;
        od;
        for i in [ 2 .. Length( chpar ) ] do
          if chpar[i] = chpar[i-1] then
            chpar[i-1] := [ chpar[i], '+' ];
            chpar[i]   := [ chpar[i], '-' ];
          fi;
        od;

        # the spin character table record
        return rec( Identifier:= Concatenation( "2.Alt(", String( n ), ")" ),
                    UnderlyingCharacteristic:= 0,
                    ClassParameters:= clpar,
                    CharacterParameters:= Concatenation(
                                              tbl.CharacterParameters,
                                       List( chpar, pi -> [ 2, pi ] ) ),
                    Size:= Factorial( n ),
                    NrConjugacyClasses:= nrcl,
                    SizesCentralizers:= cen,
                    ComputedPowerMaps:= pow,
                    OrdersClassRepresentatives:= ord,
                    ComputedClassFusions:=
                        [ rec( name:= Concatenation( "Alt(", String( n ),
                                                     ")" ),
                               map:= MakeImmutable( fus1 ) ),
                          rec( name:= Concatenation( "2.Sym(", String( n ),
                                                     ")" ),
                               map:= MakeImmutable( fus2 ) ) ],
                    Irr:= MakeImmutable( Concatenation( tbl.Irr{
                            [ 1 .. Length( tbl.Irr ) ] }{ fus1 }, chars ) ) );
        end,
    domain:= IsPosInt ) ) );
