#############################################################################
##
#W  ctblsymm.gi                 GAP library                    Götz Pfeiffer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
InstallValue( CharTableSymmetric, Immutable( rec(
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
InstallValue( CharTableAlternating, Immutable( rec(
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
InstallValue( CharTableWeylB, Immutable( rec(
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
InstallValue( CharTableWeylD, rec(
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
  local matB, matA, paramA, paramB, clp, chp, res, ctb, cta, val;
  matB := CharTableWeylB!.matrix(n);
  if n mod 2 = 0 then
    matA := CharTableSymmetric!.matrix(n/2);
    paramA := Partitions(n/2);
  fi;
  paramB := PartitionTuples(n, 2);
  clp := CharTableWeylD!.classparam[1](n);
  chp := CharTableWeylD!.charparam[1](n);
  res := NullMat(Length(chp), Length(clp));
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
#F  CharValueWreathSymmetric( <sub>, <n>, <beta>, <pi> ) . .
#F                                        . . . . character value in G wr Sn.
##
InstallGlobalFunction( CharValueWreathSymmetric, function(sub, n, beta, pi)
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
             SubtractSet(gamma[s], [i]);
             AddSet(gamma[s], i-k);

             #  enter recursion.
             val:= val + sign*CharValueWreathSymmetric(sub, n-k, gamma, rho);
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
       powermap[prime]:= List( [ 1 .. nccl ],
           i -> Position(parts, PowerWreath(spm, parts[i], prime)) );
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
        pow[p]:= List( cp, x -> Position( cp, fun( deg, x[2], p ) ) );
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
#E

