#############################################################################
##
#A  matint.gi                   GAP library                 Robert Wainwright
##
#H  $Id$
##
#Y  Copyright (C)  1997,  St. Andrews
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains functions that compute Hermite and Smith normal forms 
##  of integer matrices, with or without the HNF/SNF  expressed as the linear 
##  combination of the input.  The code is based on (and in parts identical
##  to) code written by Bohdan Majewski.
##
Revision.matint_gi :=
    "$Id$";


##############################################################################
##
#F  MatInt_BestRow( <rec>, <row>, <index>)  ......... an auxiliary function for NormHnf
##
BindGlobal("MatInt_BestRow", function( A, i, h ) 

local j, # row index; goes between i and the last row A.m
      r, # index of the row with the minimum norm so far
     cn, # (c)urrent (n)orm; norm of the current vector
     mn; # (m)inimum (n)orm; minimum so far, naturally

   r := 0; mn := 0;
   for j in [i .. A.m] do
      if A.T[j][h] <> 0 then
	 if r = 0 then
	    mn := A.T[j]*A.T[j];
	    r  := j;
	 else
	    cn := A.T[j]*A.T[j];
	    if cn < mn then
	       mn := cn;
	       r  := j;
	    fi;
	 fi;
      fi;
   od;
Info(InfoMatInt,4,"MatInt_BestRow returning ",r);

   return r;
end);

##############################################################################
##
#F  NormHnf( <array> [, <bool/rat>]) ... the Hermite NF of the first parameter
##
BindGlobal("NormHnf", function( arg )

local  A, # a record (number or rows, no of columns, int matrix)
       h, # head (first nonzero) of the pivot row
 i, j, k, # local indexes
 r, t, q,qq, # auxiliary variables
enf_flag, # set to true if the user wishes Echelon form only
frac; # off-diagonal reduction coefficient


    if not IsMatrix(arg[1]) then
       PrintTo("*errout*", "use: NormHnf( <array> [, <bool/ frac> ]);\n");
       return fail;
    fi;

    frac:=1;			
    enf_flag := false;
    if Length(arg) = 2 then
       if arg[2] = true then
	  enf_flag := true;
       elif IsRat(arg[2]) then 
	  frac:=arg[2];
       fi;
    fi;

    A := rec( T :=arg[1], m := Length(arg[1]), n := Length(arg[1][1]) );

    i := 1;
    while i <= A.m do
Info(InfoMatInt,2,"NormHnf - i:= ",i);
       h := A.n;
       j := i;
       while j <= A.m and h > i do
         t := PositionNot(A.T[j],0);
	 if t < h then
	    h := t;
	 fi;
	 j := j + 1;
       od;

       k := MatInt_BestRow(A, i, h);

       repeat
          if k <> i then # swap row i and k
             t      := A.T[i];
             A.T[i] := A.T[k];
             A.T[k] := t;
          fi;
          
          t := A.T[i][h]; # the pivot

          for j in [i+1 .. A.m] do 
	     q := RoundCycDown(A.T[j][h]/t);
	
             if q <> 0 then
	       AddRowVector(A.T[j],A.T[i],-q);
             fi;
          od;

          # place empty rows of A at the end
	  j := i + 1;
          while j <= A.m do
	     if PositionNot(A.T[j],0) <= A.n then
		j := j + 1;
	     else
                t        := A.T[j];     # swap out an empty row
                A.T[j]   := A.T[A.m];
                A.T[A.m] := t;
                A.m      := A.m - 1;
             fi;
          od;

          k := MatInt_BestRow(A, i + 1, h);
       until k = 0;
       i := i + 1;
   od;
   for i in [1 .. A.m] do
      j := PositionNot(A.T[i],0);
      if A.T[i][j] < 0 then
	 A.T[i] := -A.T[i];
      fi;
   od;

   if not enf_flag then
      for i in [A.m, A.m-1 .. 1] do
	 for j in [i+1 .. A.m] do
	    h := PositionNot(A.T[j],0);
	    t := A.T[i][h];
	    r := A.T[j][h];
	    qq:=t mod r;
	    q := (t - qq)/r;
            if qq>frac*r then q:=q+1;	fi;
	AddRowVector(A.T[i],A.T[j],-q);
	 od;
      od;
   fi;
   return A.T;      
#return same size as orig.  If only want non-zero rows return A.T{[1 .. A.m]};
end);

##############################################################################
##
#F  CaCHnf( <array> ) .................. the Hermite NF of the first parameter
##
BindGlobal("CaCHnf",function( H )

local h, i, j, k, l, m, n, q, t, v, A;

   A:=MutableCopyMat(H);
   m := Length(A);
   n := Length(A[1]);

   # skip initial all zero rows
   i := 1;
   while i <= m and PositionNot(A[i],0) > n do
      i := i + 1;
   od;

   # if i > m there is nothing left; return a null vector
   if i > m then
      return [];
   fi;
for t in [1..m] do
  if t<>i then 
   Unbind(H[t]);
  fi;
od;

#   H := [ A[i] ];
   k := 1;

   while i <= m do
      # add row i of A to H
      v := MutableCopyMat(A[i]);

      h := PositionNot(v,0);
      for j in [1 .. k] do
         if PositionNot(H[j],0) = h then
            repeat
               q := RoundCycDown(v[h]/H[j][h]);
               if q <> 0 then
	AddRowVector(v,H[j],-q);
               fi;

               if v[h] <> 0 then
                  q := RoundCycDown(H[j][h]/v[h]);
	AddRowVector(H[j],v,-q);
                  if H[j][h] = 0 then 
                     if v[h] < 0 
                        then t := -v;
                        else t :=  v;
                     fi;
                     v := H[j];
                     H[j] := t;
                  fi;
               fi;
            until v[h] = 0;
            h := PositionNot(v,0);
         elif PositionNot(H[j],0) > h then
            if v[h] < 0
               then t := -v;
               else t :=  v;
            fi;
            v := H[j];
            H[j] := t;
            h := PositionNot(v,0);
         fi;
      od;

      if h <= n then
         k := k + 1;
         if v[h] < 0 
            then H[k] := -v;
            else H[k] :=  v;
         fi;
      fi;

      if H[k][PositionNot(H[k],0)] < 0 then
         H[k] := -H[k];
      fi;
      for j in [k-1,k-2 .. 1] do
         if H[j][PositionNot(H[j],0)] < 0 then
            H[j] := -H[j];
         fi;
         for l in [j+1 .. k] do
            h := PositionNot(H[l],0);
            q := H[j][h]/H[l][h];
            if not IsInt(q) and H[j][h] < 0 then
               q := q - SignInt(H[l][h]);
            fi;
            q := Int(q);	
            AddRowVector(H[j],H[l],-q);
         od;
      od;
      i := i + 1;
   od;
for i in [Length(H)+1..m] do
  Add(H,List([1..n],x->0));
od;
   return H;
end);

#############################################################################
##
#F  LcNormHnf( <array> [,< Bool/Rat >] )  . the HNF and the tranforming matrix
##
BindGlobal("LcNormHnf" , function( arg )

local  A, # a record (number or rows, no of columns, int matrix)
       P, # unimodular matrix, such that A.T = P*arg[1]
       h, # head (first nonzero) of the pivot row
 i, j, k, # local indexes
 r, t, q,qq, # auxiliary variables
enf_flag, # set to true if the user wishes Echelon form only
frac;

    if not IsMatrix(arg[1]) then
       PrintTo("*errout*", "use: NormHnf( <array> [, <Bool/Rat>]);\n");
       return fail;
    fi;

    frac:=1;
    enf_flag := false;
    if Length(arg) = 2 then
       if arg[2] = true then
	  enf_flag := true;
       elif IsRat(arg[2]) then
          frac:=arg[2];      
       fi;
    fi;

    A := rec( T := MutableCopyMat(arg[1]), m := Length(arg[1]), n := Length(arg[1][1]) );
    P := IdentityMat(A.m);

    i := 1;
    while i <= A.m do
Info(InfoMatInt,2,"LcNormHnf - i:= ",i);
       h := A.n;
       j := i;
       while j <= A.m and h > i do
         t := PositionNot(A.T[j],0);
	 if t < h then
	    h := t;
	 fi;
	 j := j + 1;
       od;

       k := MatInt_BestRow(A, i, h);

       repeat
          if k <> i then # swap row i and k
             t      := A.T[i];
             A.T[i] := A.T[k];
             A.T[k] := t;
             t := P[i]; P[i] := P[k]; P[k] := t;
          fi;
          
          t := A.T[i][h]; # the pivot

          for j in [i+1 .. A.m] do 
	     q := RoundCycDown(A.T[j][h]/t);
	
             if q <> 0 then
	AddRowVector(A.T[j],A.T[i],-q);
	AddRowVector(P[j],P[i],-q);
             fi;
          od;

          # place empty rows of A at the end
	  j := i + 1;
          while j <= A.m do
	     if PositionNot(A.T[j],0) <= A.n then
		j := j + 1;
	     else
                t        := A.T[j];     # swap out an empty row
                A.T[j]   := A.T[A.m];
                A.T[A.m] := t;
                t        := P[j];
                P[j]     := P[A.m];
                P[A.m]   := t;
                A.m      := A.m - 1;
             fi;
          od;

          k := MatInt_BestRow(A, i + 1, h);
       until k = 0;
       i := i + 1;
   od;
   for i in [1 .. A.m] do
      j := PositionNot(A.T[i],0);
      if A.T[i][j] < 0 then
	 A.T[i] := -A.T[i];
         P[i]   := -P[i];
      fi;
   od;

   if not enf_flag then
      for i in [A.m, A.m-1 .. 1] do
	 for j in [i+1 .. A.m] do
	    h := PositionNot(A.T[j],0);
	    t := A.T[i][h];
	    r := A.T[j][h];
            qq:=t mod r;
	    q := (t - qq)/r;
            if qq>frac*r then q:=q+1;fi;
	AddRowVector(A.T[i],A.T[j],-q);
	AddRowVector(P[i],P[j],-q);
	 od;
      od;
   fi;
   return rec( normal := A.T, rowtrans := P );
end);

#############################################################################
#F LcCaCHnf implements Chou & Collins strategy for computing the
## hermite normal form of an integer matrix with transforming matrix
##
BindGlobal("LcCaCHnf",  function( mat )

local A,h, i, j, k, l, m, n, q, t, v, H, P;

   A:=MutableCopyMat(mat);
   m := Length(A);
   n := Length(A[1]);
   P := IdentityMat(m);

   # skip initial all zero rows
   i := 1;
   while i <= m and PositionNot(A[i],0) > n do
      i := i + 1;
   od;

   # if i > m there is nothing left; return a null vector
   if i > m then
      return rec(normal := [], rowtrans := P);
   fi;

   if A[i][PositionNot(A[i],0)] < 0 
      then H := [ -A[i] ]; t := -P[i];
      else H := [  A[i] ]; t :=  P[i];
   fi;
   P[i] := P[1];
   P[1] := t;
   k := 1;
   i := i + 1;

   while i <= m do
      # add row i of A to H
      v := MutableCopyMat(A[i]);
      h := PositionNot(v,0);
      for j in [1 .. k] do
         if PositionNot(H[j],0) = h then
            repeat
               q := RoundCycDown(v[h]/H[j][h]);

               if q <> 0 then
	AddRowVector(v,H[j],-q);
	AddRowVector(P[i],P[j],-q);
               fi;

               if v[h] <> 0 then
                  q := RoundCycDown(H[j][h]/v[h]);
	AddRowVector(H[j],v,-q);
	AddRowVector(P[j],P[i],-q);
                   if H[j][h] = 0 then 
                     if v[h] < 0 then 
                        t := -v; v := H[j]; H[j] := t;
                        t := -P[i]; P[i] := P[j]; P[j] := t;
                     else 
                        t :=  v; v := H[j]; H[j] := t;
                        t := P[i]; P[i] := P[j]; P[j] := t;
                     fi;
                  fi;
               fi;

            until v[h] = 0;
            h := PositionNot(v,0);
         elif PositionNot(H[j],0) > h then
            if v[h] < 0 then 
               t := -v; v := H[j]; H[j] := t;
               t := -P[i]; P[i] := P[j]; P[j] := t;
            else
               t := v; v := H[j]; H[j] := t;
               t := P[i]; P[i] := P[j]; P[j] := t;
            fi;
            h := PositionNot(v,0);
         fi;
      od;

      if h <= n then
         k := k + 1;
         if v[h] < 0 then
            v    := -v;
            P[i] := -P[i];
         fi;
         if k < i then
            t := P[i]; P[i] := P[k]; P[k] := t;
         fi;
         H[k] := v;
      fi;

      if H[k][PositionNot(H[k],0)] < 0 then
         H[k] := -H[k];
         P[k] := -P[k];
      fi;
      for j in [k-1,k-2 .. 1] do
         if H[j][PositionNot(H[j],0)] < 0 then
            H[j] := -H[j];
            P[j] := -P[j];
         fi;
         for l in [j+1 .. k] do
            h := PositionNot(H[l],0);
            q := H[j][h]/H[l][h];
            if not IsInt(q) and H[j][h] < 0 then
               q := q - SignInt(H[l][h]);
            fi;
            q := Int(q);
            AddRowVector(P[j],P[l],-q);
            AddRowVector(H[j],H[l],-q);
         od;
      od;
      i := i + 1;
   od;

for i in [Length(H)+1..m] do
  Add(H,List([1..n],x->0));
od;
   return rec(normal := H, rowtrans := P);
end);


##############################################################################
##
#F  LcLLLHnf( <array> [, <rat>] ) .. the Hermite NF and the tranforming matrix
##
BindGlobal("LcLLLHnf", function(arg)

local alpha, # LLL's sensitivity; 1/4 <= alpha <= 1
          c, # current column
       i, j, # indicies
    k, kmax, # indicies of current row, and the last row with GS coeff's
       m, n, # the number of rows and columns in the matrix
       q, t, # temporary variables
          s, # counts the rows of the quotient space
    BB, mmu, # temporary variables for mu's and B's
   b, mu, B, # matrix being reduced, GS coefficients and the length vec
        RED, # reduction procedure
          P; # final matrix and the transforming matrix E = P*A

   RED := function( l )
      if b[l][c] <> 0 then
         q := RoundCycDown(b[k][c]/b[l][c]);
      else
         q := RoundCycDown(mu[k][l]);
      fi;

      if q <> 0 then # \ldots and subtract $q b_l$ from $b_k$;

        AddRowVector(b[k],b[l],-q);
        AddRowVector(P[k],P[l],-q);

         # adjust 'mu', \ldots
         mu[k][l] := mu[k][l] - q;
         for i in [1 .. l-1 ] do  
            if mu[l][i] <> 0 then
               mu[k][i] := mu[k][i] - q * mu[l][i];
            fi;
         od;
      fi;
   end;

   if Length(arg) < 1 or Length(arg) > 2 then
      PrintTo("*errout*", "use: LLLHnf(<array> [, <sensitivity> ]);\n");
   fi;

   b := MutableCopyMat( arg[1] );
   m := Length(b);
   n := Length(b[1]);
   P := IdentityMat(m);

   if IsBound(arg[2]) and IsRat(arg[2]) then
      alpha := arg[2];
      if alpha < 1/4 or alpha > 1 then
         PrintTo("*errout*", "Sensitivity error. Using the default\n");
         alpha := 3/4;
      fi;
   else
      alpha := 3/4;
   fi;

   # sort rows according the the position of the leading nonzero
   SortParallel(b, P, function(x, y) return PositionNot(x,0) > PositionNot(y,0); end);

   s := 0; # counts the rows of quotient space

   # skip all rows that are already in the echelon normal form
   while PositionNot(b[m-s],0) < PositionNot(b[m-s-1],0) do
      s := s + 1;
   od;

   c    := PositionNot(b[m-s],0);
   kmax := 1;
   B    := [ b[1]*b[1] + P[1]*P[1] ];
   mu   := [ [ ] ];

   while c <= n do
      # step 1, initialize
  

      k := 2;
      while k <= m - s do
         # step 2, incremental Gram-Schmidt
         if k > kmax then
            kmax  := k;
            mu[k] := [];
            for j in [1 .. k-1] do
               mmu := b[k]*b[j] + P[k]*P[j];
               for i in [1 .. j-1] do
                  mmu := mmu - mu[j][i]*mu[k][i];
               od;
               mu[k][j] := mmu;
            od;
            for j in [1 .. k-1] do
               mu[k][j] := mu[k][j]/B[j];
            od;

            B[k] := b[k]*b[k] + P[k]*P[k];
            for j in [1 .. k-1] do
               B[k] := B[k] - mu[k][j]^2*B[j];
            od;
         fi;

         # step 3, test LLL condition

         # substep 3.1, RED(k, k-1)
         RED(k-1);

         while (AbsInt(b[k-1][c]) > AbsInt(b[k][c])) or (b[k-1][c] = b[k][c] and B[k] < (alpha - mu[k][k-1]^2 ) * B[k-1]) do
            # algorithm SWAP(k)
            t := b[k]; b[k] := b[k-1]; b[k-1] := t;
            t := P[k]; P[k] := P[k-1]; P[k-1] := t;
            for j in [1 .. k-2] do
               t := mu[k][j]; mu[k][j] := mu[k-1][j]; mu[k-1][j] := t;
            od;

            mmu        := mu[k][k-1];
            BB         := B[k] + mmu*mmu*B[k-1];
            q          := B[k-1]/BB;

            mu[k][k-1] :=  mmu * q;
            B[k]       := B[k] * q;
            B[k-1]     := BB;

            for i in [k+1 .. kmax] do
               t          := mu[i][k];
               mu[i][k]   := mu[i][k-1] - mmu*t;
               mu[i][k-1] := t + mu[k][k-1]*mu[i][k];
            od;

            # k := max(2, k-1)
            if k > 2 then
               k := k - 1;
            fi;

            # execute subalgorithm RED(k, k-1)
            RED(k-1);
         od;

         # execute subalgorithm RED for i = k-2, k-3, ...1
         for i in [k-2, k-3 .. 1] do
            RED(i);
         od;

         k := k + 1;
         # step 4, Finished?
      od;
     

      s    := s + 1;
      kmax := kmax - 1;

      c := n+1; 
      for i in [1 .. m - s] do
         c := Minimum(c, PositionNot(b[i],0));
      od;
   od;

   s := m - s + 1;
   # rows s .. m form the quotient space
   # rows 1 .. s - 1 for the null space

   # use the remaining rows to create the Hermite normal form of b
   if b[s][PositionNot(b[s],0)] < 0 then
      b[s] := -b[s];
      P[s] := -P[s];
   fi;
   for i in [s + 1 .. m] do
      if b[i][PositionNot(b[i],0)] < 0 then
         b[i] := -b[i];
         P[i] := -P[i];
      fi;
      for j in [i-1, i-2 .. s] do
         k := PositionNot(b[j],0);
         q := b[i][k]/b[j][k];
         if not IsInt(q) then
            if b[i][k] < 0 
               then q := Int(q) - SignInt(b[j][k]);
               else q := Int(q);
            fi;
         fi;
       AddRowVector(b[i],b[j],-q);
       AddRowVector(P[i],P[j],-q);
      od;
   od;

   # use the null space to reduce the quotient space
   # for each vector in the quotient space compute its Gram-Schmidt
   # orthogonalization and use procedure Proper (B.Vallee) to bring
   # it closer to the shortest vector

   for k in [s .. m] do
      # Gram Schmidt for the k-th vector
      mu[k] := [ ];
      for j in [1 .. s-1] do
         mmu := P[k]*P[j];
         for i in [1 .. j-1] do
            mmu := mmu - mu[j][i]*mu[k][i];
         od;
         mu[k][j] := mmu;
      od;
      for j in [1 .. s-1] do
         mu[k][j] := mu[k][j]/B[j];
      od;

      for j in [s-1, s-2 .. 1] do
         # RED(j), however we want to avoid testing column c
         q := RoundCycDown(mu[k][j]);
         if q <> 0 then       

        AddRowVector(P[k],P[j],-q);
            for i in [1 .. j-1] do
               if mu[j][i] <> 0 then
                  mu[k][i] := mu[k][i] - q*mu[j][i];
               fi;
            od;
         fi;
      od;
   od;
b:=Reversed(b{[s .. m]});
for k in [Length(b)+1..m] do
  Add(b,List([1..n],x->0));
od;

 return rec( normal := b, rowtrans := Reversed(P));

 #  return rec( normal := Reversed(b{[s .. m]}), rowtrans := Reversed(P));
end);

#############################################################################
##
##  start of smith normal form  code     
##

#############################################################################
##
#F  MatMax ( <array> )  . . . . . returns the value of the element with the
##                                largest absolute value in matrix A
BindGlobal("MatMax", function(A, f)

local i, j, e, x;

   x := 0;
   for i in [f .. Length(A)] do
      for e in A[i] do
	 if e < 0 then e := -1*e; fi;
	 if e > x then x := e;    fi;
      od;
   od;
   return x;
end);


##############################################################################
##
#F  NormDiagonalize( <array> )  . . . .  a norm driven integer matrix diagonalization  algorithm
##
BindGlobal("NormDiagonalize", function( S )

local t, # a temporary variable, for row swaps and such
    RNm, # row norms
    CNm, # column norms
   m, n, # the number or rows and columns of S
  i,j,k, # indices
      d, # the index of the current diagonal entry
      q, # quotient of two entries, most of the time
    RId, # index of the "best" row
    CId, # index of the "best" column
    CMn, # smallest so far column norm
    RMn, # smallest so far row norm
   done; # flag, set to true if the d-th diagonal element is computed

   m   := Length(S);
   n   := Length(S[1]);

   RNm := List(S, x -> x*x);
   CNm := [ ];
   for k in [1 .. n] do
      CNm[k] := S{[1 .. m]}[k]*S{[1 .. m]}[k];
   od;
   d := 1;

   repeat
      # pivot selection
      # first we sort rows d .. m. Zero rows are the heaviest
      # for other rows the standard Euclidean Length is used
      # this is a simple implementation that uses Insertion Sort
      for j in [d+1 .. m] do
         if RNm[j] <> 0 then
            t := S[j]; q := RNm[j]; k := j - 1;
            while k >= d and (RNm[k] = 0 or q < RNm[k]) do
               RNm[k+1] := RNm[k];
               S[k+1]   := S[k];
               k        := k-1;
            od;
            RNm[k+1] := q;
           S[k+1]   := t;
         fi;
      od;
  
      # eliminate all zero rows, by decreasing m suitably
      while RNm[m] = 0 do
         m := m - 1;
      od;
   
      if d = m then
         S[d][d] := Gcd(S[d]{[d .. n]});
         # clean out the last row.
         S[d]{[d+1..n]} := [d+1..n] * 0;
         return;
      elif d > m then
         return;
      fi;

      j := d; k := d;
      while S[j][k] = 0 do
         j := j + 1;
         if j > m then
            j := d;
            k := k + 1;
         fi;
      od;

      CMn := RNm[j]*CNm[k];
      CId := k; RId := j;
      k   := k + 1;
      while k <= n do
         j := d;
         while j <= m and S[j][k] = 0 do
            j := j + 1;
         od;
         if j <= m then
            RMn := RNm[j]*CNm[k];
            if RMn < CMn then
               CId := k; RId := j; CMn := RMn;
            fi;
         fi;
         k := k + 1;
      od;

      # swap rows and columns so that pivot becomes the d-th,d-th element
      t := S[d]; S[d] := S[RId]; S[RId] := t;
      if CId <> d then
         for k in [d .. m] do
            t := S[k][d]; S[k][d] := S[k][CId]; S[k][CId] := t;
         od;
      fi;

      # pivot in place; proceed to zero the d-th row and column
Info(InfoMatInt,3,"NormDiagonalize - working on column ",d);
      done := false;
      repeat
         # row operations first 
         for k in [d+1 .. m] do
            q := RoundCycDown(S[k][d]/S[d][d]);
            if q <> 0 then
	AddRowVector(S[k],S[d],-q);
            fi;
         od;

         # column operations follow
         
         for k in [d+1 .. n] do
            q := RoundCycDown(S[d][k]/S[d][d]);
            if q <> 0 then 
              # subtract column d from column k, q times
              for j in [d .. m] do
                S[j][k] := S[j][k] - q*S[j][d];
              od;
            fi;
         od;

         # recompute norms, as we need to choose another pivot
         RNm{[d .. m]} := List(S{[d .. m]}, x -> x*x);
         for k in [d .. n] do
            CNm[k] := S{[d .. m]}[k]*S{[d .. m]}[k];
         od;

         # find the best pivot in the d-th row
         CMn := 0;
         for k in [d+1 .. n] do
            if S[d][k] <> 0 then
               if CMn = 0 or CNm[k] < CMn then
                  CId := k; CMn := CNm[k];
               fi;
             fi;
         od;
         # find the best pivot in the d-th column
         RMn := 0;
         for k in [d+1 .. m] do
            if S[k][d] <> 0 then
               if RMn = 0 or RNm[k] < RMn then
                  RId := k; RMn := RNm[k];
               fi;
            fi;
         od;
   
         if CMn = 0 then
            if RMn = 0 then
               done := true;
            else # swap row RId and d
               t := S[d]; S[d] := S[RId]; S[RId] := t;
            fi;
         else
            if RMn = 0 then # swap column CId and d
               for k in [d .. m] do
                  t := S[k][d]; S[k][d] := S[k][CId]; S[k][CId] := t;
               od;
            else
               if RNm[d]*CMn < CNm[d]*RMn then
                  for k in [d .. m] do
                     t := S[k][d]; S[k][d] := S[k][CId]; S[k][CId] := t;
                  od;
               else
                  t := S[d]; S[d] := S[RId]; S[RId] := t;
               fi;
            fi;
         fi;
      until done;
      if S[d][d] < 0 then
         S[d][d] := -S[d][d];
      fi;
      
      d := d + 1;
   until d > m;
end);

##############################################################################
##
#F  DiagToSNF( <array> )  . . . .  collects diagonal entries and ensures their
##                                divisibility cond for the diagonal matrix S
BindGlobal("DiagToSNF", function( S )

local g, i, L, n,z;

   L := [ ];z:=0;
   for i in [1 .. Minimum(Length(S), Length(S[1])) ] do
     if S[i][i] <> 0 then
        Add(L, AbsInt(S[i][i]));
   else z:=z+1;
     fi;
   od;
   n := Length(L);
   i := 2;
   while i <= n do
      g := L[i];
      while i > 1 and g < L[i-1] do
         L[i] := L[i-1];
         i    := i - 1;
      od;
      L[i] := g;
      Info(InfoMatInt,3,"DiagToSNF: ",i);
      Info(InfoMatInt,4,"DiagToSNF: ",L);
      if i = 1 then i := 2; fi;
      if L[i] mod L[i-1] <> 0 then
         g      := Gcd(L[i], L[i-1]);
         L[i]   := L[i]*L[i-1]/g;
         i      := i - 1;
         while i > 1 and g < L[i-1] do
            L[i] := L[i-1];
            i    := i - 1;
         od;
         L[i] := g;
      Info(InfoMatInt,3,"DiagToSNF: ",i);
      Info(InfoMatInt,4,"DiagToSNF: ",L);
      fi;
      if i = 1 or L[i] mod L[i-1] = 0 then
          i := i + 1;
      fi;
   od;
L{[n+1..n+z]}:=List([1..z],x->0);
   return L;
end);

##############################################################################
##
#F  NormSnf( <array> )  . . . . . . Computes the Smith Normal form of matrix A
##
BindGlobal("NormSnf", function( S )

    local  M,  # temp matrix
           n,  # length of leading diagonal
           m;  # counter
    
   if not IsMatrix(S) then
      PrintTo("*errout*", "Use: NormSnf( <matrix> );\n");
      return fail;
  fi;
  
  n := Minimum(Length(S), Length(S[1]));
 
   M:=NullMat(Length(S),Length(S[1]));
   NormDiagonalize( S );
   M:=DiagToSNF(S);
   for m in [1..Length(M)] do
     S[m][m]:=M[m];
   od;
   for m in [Length(M)+1..n] do
     S[m][m]:=0;
   od;  
   return  S;
end);

##############################################################################
##
#F  CaCDiagonalize( <array> )  . . . . . diagonalizes a matrix using Chou & Collins
##
BindGlobal("CaCDiagonalize", function( S )

local h, # point to the first nonzero in the current row
      H, # heads of vectors, i.e., indices of the leading nonzeros
  i,j,k, # as usually, indices
   m, n, # the number of rows and columns in S
      q, # usually quotient for row operations
      t, # a temporary variable for all sorts of things
  modfd, # indicates whether the column phase is necessary
  dirty; # indicates whether any upward row operations took place

   m := Length(S);
   n := Length(S[1]);

   # it is generally recommended to sort matrix S before
   # executing Chou and Collins' algorithm. It is commented
   # out, as the sorting has rather bad effect if S is already
   # in partial hermite normal form (sorting jumbles things up)
   # however in general, if S hasn't been touched before, it
   # is highly beneficial to sort the matrix. (Maybe one could
   # sort it so that it resembles HNF as much as possible, and
   # only rows that have leading nonzeros in the same column
   # would be sorted according to their Euclidean length

   # Sort(S, function(x, y) return x*x < y*y; end);

   dirty := false;
   repeat
      H := [ ]; # clear Heads array
      # get rid of initial empty rows
      i := 1;
      while ForAll(S[i], e -> e = 0) do
         i := i + 1;

      od;
      if i > 1 then
         S := S{[i .. m]};
         m := m - i + 1;
      fi;

      dirty := not dirty;
      i := 1;
      Add(H, PositionNot(S[1],0));

      while i < m do
         i := i + 1;
         # introduce the i-th row of S to the partial SNF(S)

         h := PositionNot(S[i],0);
         modfd := false; # set to true if columns require modifications
         for j in [1 .. i-1] do
            if H[j] = h then
               repeat
                  q := RoundCycDown(S[i][h]/S[j][h]);
                  if q <> 0 then
	AddRowVector(S[i],S[j],-q);
                  fi;

                  if S[i][h] <> 0 then
                     modfd := true;
                     q := RoundCycDown(S[j][h]/S[i][h]);
	   AddRowVector(S[j],S[i],-q);
                     if S[j][h] = 0 then 
                        if S[i][h] < 0 
                           then t := -S[i];
                           else t :=  S[i];
                        fi;
                        S[i] := S[j];
                        S[j] := t;
                     fi;
                  fi;
               until S[i][h] = 0;
               h := PositionNot(S[i],0);
            elif PositionNot(S[j],0) > h then
               if S[i][h] < 0
                  then t := -S[i];
                  else t :=  S[i];
               fi;
               S[i] := S[j];
               S[j] := t;
               t    := H[j];
               H[j] := h;
               h    := t;
               modfd:= true;
            fi;
         od;

         dirty := dirty or modfd;
         if h <= n then
            Add(H, h);
            modfd := true;
         else
            S{[i .. m-1]} := S{[i+1 .. m]};
            Unbind(S[m]);
            m := m - 1;
            i := i - 1;
         fi;

         if modfd then
            if S[i][H[i]] < 0 then
               S[i] := -S[i];
            fi;
            for j in [i-1,i-2 .. 1] do
               if S[j][H[j]] < 0 then
                  S[j] := -S[j];
               fi;
               for k in [j+1 .. i] do
                  h := H[k];
                  q := S[j][h]/S[k][h];
                  if not IsInt(q) and S[j][h] < 0 then
                     q := q - SignInt(S[k][h]);
                  fi;
                  q := Int(q);
                  if q <> 0 then
	AddRowVector(S[j],S[k],-q);
                     dirty := true;
                  fi;
               od;
            od;
         fi;
        
      od;
      # transpose S and swap m and n
      S := MutableTransposedMat(S);
      t := m; m := n; n := t;
   until not dirty;
   return S;
end);

##############################################################################
##
#F  CaCSnf( <array> )  . . . . . . . Computes the Smith Normal form of matrix A
##
BindGlobal("CaCSnf", function( S )

local  m,M,N;# temporary variable
  
   if not IsMatrix(S) then
      PrintTo("*errout*", "Use: CaCSnf( <matrix> );\n");
      return fail;
   fi;

   N:=NullMat(Length(S),Length(S[1]));

   CaCDiagonalize(S);
   M:=DiagToSNF(S);
  
   for m in [1..Length(M)] do
     N[m][m]:=M[m];
      S[m]:=N[m];
  od;
   return  S ;
end);

########################################################
##
##  	auxiliary + main code for all in one function
##
##  split 
##  rgcd
##  mgcdex
##  bezout
##  SNFofREF
##
##  NormalFormIntMat
##
##

########################################################
#
# split(<N>,<a>) - returns product of prime factors of N which are not factors of a.
#
BindGlobal("split",function(N,a)

local x,t;

x:=a;
t:=N;

while x<>1 do
  x:=GcdInt(x,t);
  t:=QuoInt(t,x);
od;

return t;

end);

################################################
#
#   rgcd(<N>,<a>) - Returns smallest nonnegative c such that
#		   gcd(N,a+c) = 1
#
BindGlobal("rgcd",function(N,a)

local k,r,d,i,c,g,q;

if N=1 then return 0; fi;
k := 1;
r:=[(a-1) mod N];
d:=[N];
c:=0;
while true do
  for i in [1..k] do r[i]:=(r[i]+1) mod d[i]; od;
  i:=PositionProperty(r,x->x<=0);
  if i=fail then
    g:=1;i:=0; 
    while g=1 and i<k do
       i:=i+1;
       g:=GcdInt(r[i],d[i]);
    od;
    if g=1 then return c; fi;
    q:=split(QuoInt(d[i],g),g);
    if q>1 then
      k:=k+1;
      r[k]:=r[i] mod q;
      d[k]:=q;
    fi;
    r[i]:=0;
    d[i]:=g;    
  fi;
  c:=c+1;
od;

end);

#######################################################
# 
#  mgcdex(<N>,<a>,<v>) - Returns c[1],c[2],...c[k] such that
#
#   gcd(N,a+c[1]*b[1]+...+c[n]*b[k]) = gcd(N,a,b[1],b[2],...,b[k])
#
BindGlobal("mgcdex", function(N,a,v)

local h,g,M,c,i,d,b,l;

l:=Length(v);
c:=[]; M:=[];
h := N;
for i in [1..l] do
  g := h;
  h:=GcdInt(g,v[i]);  
  M[i]:=QuoInt(g,h);
od;
h:=GcdInt(a,h);
g:=QuoInt(a,h);

for i in [l,l-1..1] do
  b:=QuoInt(v[i],h);
  d:=split(M[i],b);
  if d=1 then
    c[i]:=0;
  else
    c[i]:=rgcd(d,g/b mod d);
    g:=g+c[i]*b;
  fi;
od;

return c;

end);




#####################################################
#
#  bezout(a,b,c,d) - returns row transform , P, to transform, A, to hnf :
#
#  PA=H;
#
#  [ s  t ] [ a  b ]   [ e  f ] 
#  [      ] [      ] = [       ]   
#  [ u  v ] [ c  d ]   [    g ]
#
BindGlobal("bezout", function(a,b,c,d)
   local e,f,g,q;

   e := Gcdex(a,c);
   f := e.coeff1*b+e.coeff2*d;
   g := e.coeff3*b+e.coeff4*d;
   if g<0 then
      e.coeff3 := -e.coeff3;
      e.coeff4 := -e.coeff4;
      g := -g; 
   fi;
   if g>0 then
      q := QuoInt(f-(f mod g),g);
      e.coeff1 := e.coeff1-q*e.coeff3;
      e.coeff2 := e.coeff2-q*e.coeff4;
   fi;
   return e;

end);

#####################################################
##
## SNFofREF - fast SNF of REF matrix
##
##
InstallGlobalFunction(SNFofREF , function(R)
local k,g,b,ii,m1,m2,t,tt,si,n,m,i,j,r,jj,piv,d,gt,tmp,A,T,TT,kk;

Info(InfoMatInt,1,"SNFofREF - initializing work matrix");
n := Length(R);
m := Length(R[1]);

piv := List(R,x->PositionProperty(x,y->y<>0));
r := PositionProperty(piv,x->x=fail);
if r=fail then
   r := Length(piv);
else
   r := r-1;  
   piv := piv{[1..r]}; 
fi;
Append(piv,Difference([1..m],piv));

T := NullMat(n,m);
for j in [1..m] do
  for i in [1..Minimum(r,j)] do T[i][j]:=R[i][piv[j]]; od;
od;

si := 1;
A := [];
d := 2;
for k in [1..m] do
Info(InfoMatInt,2,"SNFofREF - working on column ",k);
   if k<=r then
      d := d*AbsInt(T[k][k]);
      Apply(T[k],x->x mod (2*d));
   fi;

   t := Minimum(k,r);
   for i in [t-1,t-2..si] do
      t := mgcdex(A[i],T[i][k],[T[i+1][k]])[1];
      if t<>0 then
         AddRowVector(T[i],T[i+1],t); 
         Apply(T[i],x->x mod A[i]); 
      fi;
   od;

   for i in [si..Minimum(k-1,r)] do
      g := Gcdex(A[i],T[i][k]);
      T[i][k] := 0;
      if g.gcd<>A[i] then
         b := QuoInt(A[i],g.gcd);
         A[i] := g.gcd;
         for ii in [i+1..Minimum(k-1,r)] do
            AddRowVector(T[ii],T[i],-g.coeff2*QuoInt(T[ii][k],A[i]) mod A[ii]);
            T[ii][k] := b*T[ii][k];

            Apply(T[ii],x->x mod A[ii]);
         od;
         if k<=r then 
            t := g.coeff2*QuoInt(T[k][k],g.gcd);
            AddRowVector(T[k],T[i],-t);
            T[k][k]:=b*T[k][k];
         fi;
         Apply(T[i],x->x mod A[i]);
         if A[i]=1 then si := i+1; fi;
      fi;
   od;

   if k<=r then 
      A[k] := AbsInt(T[k][k]);
      Apply(T[k],x->x mod A[k]);
   fi;

od;

for i in [1..r] do T[i][i] := A[i]; od;

return T;

end);

###########################################################
#
# NFIM(<mat>,<options>)
#
# Options bit values:
#
# 1  - Triangular / Smith
# 2  - No / Yes  Reduce off diag entries
# 4  - No / Yes  Row Transforms 
# 8  - No / Yes  Col Transforms
#
# Compute a Triangular, Hermite or Smith form of the n x m 
# integer input matrix A.  Optionally, compute n x n / m x m
# unimodular transforming matrices which satisfy Q C A = H 
# or  Q C A B P = S.
#
# Triangular / Hermite :
#
# Let I be the min(r+1,n) x min(r+1,n) identity matrix with r = rank(A).
# Then Q and C can be written using a block decomposition as
#
#             [ Q1 |   ]  [ C1 | C2 ]
#             [----+---]  [----+----]  A  =  H.
#             [ Q2 | I ]  [    | I  ]
#
# Smith :
#
#  [ Q1 |   ]  [ C1 | C2 ]     [ B1 |   ]  [ P1 | P2 ]
#  [----+---]  [----+----]  A  [----+---]  [----+----] = S.
#  [ Q2 | I ]  [    | I  ]     [ B2 | I ]  [ *  | I  ]
#
# * - possible non-zero entry in upper right corner...
#				
#
BindGlobal("NFIM", function(arg)
local c,i,j,n,m,r,c1,c2,t,g,gg,s,a,b,q,tmp,gt,inc,A,Q,C,B,P,flag,R,rp,opt,k,t1,t2,N,L,sig;

if not Length(arg)=2 or not IsMatrix(arg[1]) or not IsInt(arg[2]) then 
  Error("syntax is NFIM(<matrix>,<options>)"); 
fi;

#Parse options
opt := List(CoefficientsQadic(arg[2],2),x->x=1);
if Length(opt)<4 then 
  opt{[Length(opt)+1..4]} := List([Length(opt)+1..4],x->false);
fi;

sig:=1;

#Embed arg[1] in 2 larger "id" matrix
n := Length(arg[1])+2;
m := Length(arg[1][1])+2;
A := [List([1..m],x->0)];
for i in [2..n-1] do
  A[i] := [0];
  Append(A[i],arg[1][i-1]);
  A[i][m] := 0;
od;
A[n] := List([1..m],x->0);
A[1][1] := 1;
A[n][m] := 1;

if opt[3] then 
  C := IdentityMat(n); 
  Q := NullMat(n,n);
  Q[1][1] := 1; 
fi;

if opt[1] and opt[4] then 
  B := IdentityMat(m);
  P := IdentityMat(m);
fi;

r := 0;
c2 := 1;
rp := [];
while m>c2 do
  Info(InfoMatInt,2,"NFIM - reached column ",c2," of ",m);
  r := r+1;
  c1 := c2;
  rp[r] := c1;
  if opt[3] then Q[r+1][r+1] := 1; fi;

  j := c1+1;
  while j<=m do
    k := r+1;
    while k<=n and A[r][c1]*A[k][j]=A[k][c1]*A[r][j] do k := k+1; od;
    if k<=n then c2 := j; j := m; fi;
    j := j+1;
  od;
  #Smith with some transforms..
  if opt[1] and (opt[4] or opt[3]) and c2<m then
    N := Gcd(Flat(A{[r..n]}[c2]));
    L := [c1+1..c2-1];
    Append(L,[c2+1..m-1]);
    Add(L,c2);
    for j in L do
      if j=c2 then
         b:=A[r][c2];a:=A[r][c1];
         for i in [r+1..n] do
           if b<>1 then
             g:=Gcdex(b,A[i][c2]);
             b:=g.gcd;
             a:=g.coeff1*a+g.coeff2*A[i][c1];
           fi; 
         od;
         N:=0;
         for i in [r..n] do  
          if N<>1 then N:=GcdInt(N,A[i][c1]-QuoInt(A[i][c2],b)*a);fi;
         od;
      else
        c := mgcdex(N,A[r][j],A{[r+1..n]}[j]);
        b := A[r][j]+c*A{[r+1..n]}[j];
        a := A[r][c1]+c*A{[r+1..n]}[c1];
      fi;
      t := mgcdex(N,a,[b])[1];
      tmp := A[r][c1]+t*A[r][j];
      if tmp=0 or tmp*A[k][c2]=(A[k][c1]+t*A[k][j])*A[r][c2] then
        t := t+1+mgcdex(N,a+t*b+b,[b])[1];
      fi;
      if t>0 then
        for i in [1..n] do A[i][c1] := A[i][c1]+t*A[i][j]; od;
        if opt[4] then B[j][c1] := B[j][c1]+t; fi;
      fi;
    od;
    if A[r][c1]*A[k][c1+1]=A[k][c1]*A[r][c1+1] then
      for i in [1..n] do A[i][c1+1] := A[i][c1+1]+A[i][c2]; od;
      if opt[4] then B[c2][c1+1] := 1; fi; 
    fi;
    c2 := c1+1;
  fi;

  c := mgcdex(AbsInt(A[r][c1]),A[r+1][c1],A{[r+2..n]}[c1]);
  for i in [r+2..n] do 
    if c[i-r-1]<>0 then
      AddRowVector(A[r+1],A[i],c[i-r-1]);
      if opt[3] then 
        C[r+1][i] := c[i-r-1];  
        AddRowVector(Q[r+1],Q[i],c[i-r-1]); 
      fi;
    fi;
  od;

  i := r+1;
  while A[r][c1]*A[i][c2]=A[i][c1]*A[r][c2] do i := i+1; od;
  if i>r+1 then
     c := mgcdex(AbsInt(A[r][c1]),A[r+1][c1]+A[i][c1],[A[i][c1]])[1]+1;;
     AddRowVector(A[r+1],A[i],c);
     if opt[3] then 
       C[r+1][i] := C[r+1][i]+c; 
       AddRowVector(Q[r+1],Q[i],c); 
     fi;
  fi;
  
  g := bezout(A[r][c1],A[r][c2],A[r+1][c1],A[r+1][c2]);
  sig:=sig*SignInt(A[r][c1]*A[r+1][c2]-A[r][c2]*A[r+1][c1]);
  A{[r,r+1]} := [[g.coeff1,g.coeff2],[g.coeff3,g.coeff4]]*A{[r,r+1]};
  if opt[3] then 
    Q{[r,r+1]} := [[g.coeff1,g.coeff2],[g.coeff3,g.coeff4]]*Q{[r,r+1]};
  fi;

  for i in [r+2..n] do
    q := QuoInt(A[i][c1],A[r][c1]);
    AddRowVector(A[i],A[r],-q);
    if opt[3] then AddRowVector(Q[i],Q[r],-q); fi;
    q := QuoInt(A[i][c2],A[r+1][c2]);
    AddRowVector(A[i],A[r+1],-q);
    if opt[3] then AddRowVector(Q[i],Q[r+1],-q); fi;
  od;

od; 
rp[r+1] := m;
Info(InfoMatInt,2,"NFIM - r,m,n=",r,m,n);
if n=m and r+1<n then sig:=0;fi;

#smith w/ NO transforms - farm the work out...
if opt[1] and not (opt[3] or opt[4]) then
  R:=rec(normal:=SNFofREF(A{[2..n-1]}{[2..m-1]}),rank:=r-1);
   if n=m then R. signdet:=sig;fi;
   return R;
fi;

# hermite or (smith w/ column transforms)
if (not opt[1] and opt[2]) or (opt[1] and opt[4]) then
  for i in [r, r-1 .. 1] do
    Info(InfoMatInt,2,"NFIM - reducing row ",i);
    for j in [i+1 .. r+1] do
      q := QuoInt(A[i][rp[j]]-(A[i][rp[j]] mod A[j][rp[j]]),A[j][rp[j]]);
      AddRowVector(A[i],A[j],-q);
      if opt[3] then AddRowVector(Q[i],Q[j],-q); fi;
    od;
    if opt[1] and i<r then
      for j in [i+1..m] do 
        q := QuoInt(A[i][j],A[i][i]);
        for k in [1..i] do A[k][j] := A[k][j]-q*A[k][i]; od;
        if opt[4] then P[i][j] := -q; fi;      
      od;
    fi;
  od;
fi;

#Smith w/ row but not col transforms
if opt[1] and opt[3] and not opt[4] then
  for i in [1..r-1] do
    t := A[i][i];
    A[i] := List([1..m],x->0);
    A[i][i] := t;
  od;
  for j in [r+1..m-1] do
    A[r][r] := GcdInt(A[r][r],A[r][j]);
    A[r][j] := 0;
  od;
fi;

#smith w/ col transforms
if opt[1] and opt[4] and r<m-1 then
  c := mgcdex(A[r][r],A[r][r+1],A[r]{[r+2..m-1]});
  for j in [r+2..m-1] do
    A[r][r+1] := A[r][r+1]+c[j-r-1]*A[r][j];
    B[j][r+1] := c[j-r-1];
    for i in [1..r] do P[i][r+1] := P[i][r+1]+c[j-r-1]*P[i][j]; od;
  od;
  P[r+1] := List([1..m],x->0);
  P[r+1][r+1] := 1;
  g := Gcdex(A[r][r],A[r][r+1]);
  A[r][r] := g.gcd;
  A[r][r+1] := 0;
  for i in [1..r+1] do
    t := P[i][r];
    P[i][r] := P[i][r]*g.coeff1+P[i][r+1]*g.coeff2;
    P[i][r+1] := t*g.coeff3+P[i][r+1]*g.coeff4;
  od;
  for j in [r+2..m-1] do  
    q := QuoInt(A[r][j],A[r][r]);
    for i in [1..r+1] do P[i][j] := P[i][j]-q*P[i][r]; od;
    A[r][j] := 0;
  od;
  for i in [r+2..m-1] do
    P[i] := List([1..m],x->0);
    P[i][i] := 1;
  od;
fi;

#row transforms finisher
if opt[3] then for i in [r+2..n] do Q[i][i]:= 1; od; fi;

R:=rec(normal:=A{[2..n-1]}{[2..m-1]});

if opt[3] then 
  R.rowC:=C{[2..n-1]}{[2..n-1]}; 
  R.rowQ:=Q{[2..n-1]}{[2..n-1]}; 
fi;

if opt[1] and opt[4] then
  R.colC:=B{[2..m-1]}{[2..m-1]}; 
  R.colQ:=P{[2..m-1]}{[2..m-1]}; 
fi;

R.rank:=r-1;
if n=m then R.signdet:=sig;fi;
return R;

end);


#############################################################################
##
#F  NYI(arg)  . . . . . . . . . . . .  dummy not yet implemented yet function
##
NYI:=function(arg)

   PrintTo("*errout*", "This function is not yet fully implemented. Sorry.\n");
   return fail;
end;


#############################################################################
##
#F  IdTransReturn(mat)  . . . . . . . return relevant identity record for mat
##
IdTransReturn:=function(arg)

local n,r;

if Length(arg[1])>0 and IsList(arg[1][1]) then n:=Length(arg[1][1]);else n:=0;fi;

r:=arg[1];

if (IsBound(arg[2]) and arg[2]) or (IsBound(arg[3]) and arg[3]) then
r:=         rec(
	normal:=arg[1]
	);

  if arg[2] then 
      r.rowtrans:=IdentityMat(Length(arg[1]));
  fi;


  if IsBound(arg[3]) and arg[3] then
     r.coltrans:=IdentityMat(n);
  fi;

fi;
return r;

end;

##############################################################################
##
#F  LcNormSnf( <array> )  . . . . . Computes the Smith Normal form of matrix A
##
LcNormSnf := function( arg )
   PrintTo("*errout*", "This function (LcNormSnf) is yet to be implemented. Sorry.\n");
   return fail;
end;

##############################################################################
##
#F  LcCaCSnf( <array> )  . . . . . Computes the Smith Normal form of matrix A
##
LcCaCSnf := function( arg )
   PrintTo("*errout*", "This function (LcCaCSnf) is yet to be implemented. Sorry.\n");
   return fail;
end;

##############################################################################
##
#F  LcLLLSnf( <array> )  . . . . . Computes the Smith Normal form of matrix A
##
LcLLLSnf := function( arg )
   PrintTo("*errout*", "This function (LcLLLSnf) is yet to be implemented. Sorry.\n");
   return fail;
end;


#############################################################################
##
#F  HNFNormDriven(<mat>[,<trans>[,<reduction>]])
##
InstallGlobalFunction( HNFNormDriven, function(arg)

if Flat(arg[1])=[]  and ForAll(arg[1],x->Length(x)=Length(arg[1][1])) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2])]); fi;

if not IsMatrix(arg[1]) then 
  PrintTo("*errout*", "matrix required as argument\n");
   return fail;
fi;

if ForAll( Flat(arg[1]) , x -> x = 0 ) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2])]); fi;

if Length(arg)=1 then  return CallFuncList(NormHnf,arg);fi;
if Length(arg)=2 then 
if arg[2]=1 then return CallFuncList(LcNormHnf,arg) ;
  else 
  PrintTo("*errout*", "Transformation matrix routine only  implemented for trans=1 for this routine at present. Sorry.\n");
   return fail;
  fi;
fi;

if Length(arg)>2 then
  if arg[2]=1 then return LcNormHnf(arg[1],arg[3]);
  elif arg[2]=0 then return NormHnf(arg[1],arg[3]);
  else
  PrintTo("*errout*", "Transformation matrix routine only  implemented for trans=1 for this routine at present. Sorry.\n");
   return fail;
  fi;
fi;
end);

#############################################################################
##
#F  HNFChouCollins(<mat>[,<trans>[,<reduction>]])
##
InstallGlobalFunction( HNFChouCollins, function(arg)
if Flat(arg[1])=[]  and ForAll(arg[1],x->Length(x)=Length(arg[1][1])) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2])]); fi;

if not IsMatrix(arg[1]) then 
  PrintTo("*errout*", "matrix required as argument\n");
   return fail;
fi;

if ForAll( Flat(arg[1]) , x -> x = 0 ) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2])]); fi;
if Length(arg)=1 then  return CaCHnf(arg[1]);fi;
if Length(arg)=2 then 
  if arg[2]=1 then return LcCaCHnf(arg[1]);
  elif arg[2]=0 then return CaCHnf(arg[1]);
  else 
  PrintTo("*errout*", "Transformation matrix routine only  implemented for trans=1 for this routine at present. Sorry.\n");
   return fail;
  fi;
fi;

if Length(arg)>2 then
PrintTo("*errout*", "Different Reduction routines  not yet implemented for this routine. Try the Norm driven routine.\n");
   return fail;fi;
end);

#############################################################################
##
#F  HNFLLLDriven(<mat>[,<trans>[,<reduction>]])
##
InstallGlobalFunction( HNFLLLDriven, function(arg)
local i,t;
if Flat(arg[1])=[]   and ForAll(arg[1],x->Length(x)=Length(arg[1][1])) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2])]); fi;
if not IsMatrix(arg[1]) then 
  PrintTo("*errout*", "matrix required as argument\n");
   return fail;
fi;

if ForAll( Flat(arg[1]) , x -> x = 0 ) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2])]); fi;
if Length(arg)=1 then  
t:= LcLLLHnf(arg[1]).normal;
for i in [1..Length(arg[1])] do
arg[1][i]:=t[i];
od;
return t; fi;

if Length(arg)=2 then
  if arg[2]=1 then return LcLLLHnf(arg[1]); 
  else 
  PrintTo("*errout*", "Transformation matrix routine only  implemented for trans=1 for this routine at present. Sorry.\n");
   return fail;
  fi;
fi;

if Length(arg)>2 then
PrintTo("*errout*", "Different Reduction routines  not yet  implemented for this routine.  Try the Norm driven routine. Sorry.\n");
   return fail;
fi;
end);


############################################################################
##
#F  SNFNormDriven(<mat>[,<trans>])
##
InstallGlobalFunction( SNFNormDriven, function(arg)
if Flat(arg[1])=[]  and ForAll(arg[1],x->Length(x)=Length(arg[1][1])) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2]),IsBound(arg[2])]); fi;

if not IsMatrix(arg[1]) then 
  PrintTo("*errout*", "matrix required as argument\n");
   return fail;
fi;

if  ForAll( Flat(arg[1]) , x -> x = 0 ) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2]),IsBound(arg[2])]); fi;
if Length(arg)=1 then  return NormSnf(arg[1]);fi;
if Length(arg)=2 then return LcNormSnf(arg);fi;
end);

#############################################################################
##
#F  SNFChouCollins(<mat>[,<trans>])
##
InstallGlobalFunction( SNFChouCollins, function(arg)
if Flat(arg[1])=[]  and ForAll(arg[1],x->Length(x)=Length(arg[1][1])) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2]),IsBound(arg[2])]); fi;

if not IsMatrix(arg[1]) then 
  PrintTo("*errout*", "matrix required as argument\n");
   return fail;
fi;

if ForAll( Flat(arg[1]) , x -> x = 0 ) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2]),IsBound(arg[2])]); fi;
 if Length(arg)=1 then  return CallFuncList(CaCSnf,[arg[1]]);fi;
if Length(arg)=2 then return LcCaCSnf(arg);fi;
end);

#############################################################################
##
#F  SNFLLLDriven(<mat>[,<trans>])
##
InstallGlobalFunction( SNFLLLDriven, function(arg)
if Flat(arg[1])=[]   and ForAll(arg[1],x->Length(x)=Length(arg[1][1])) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2]),IsBound(arg[2])]); fi;

if not IsMatrix(arg[1]) then 
  PrintTo("*errout*", "matrix required as argument\n");
   return fail;
fi;

if ForAll( Flat(arg[1]) , x -> x = 0 ) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2]),IsBound(arg[2])]); fi;
#if Length(arg)=1 then  return LcLLLSnf(arg[1]).normal;fi;
#if Length(arg)=2 then return LcLLLSnf(arg);fi;
return NYI(arg);
end);


#############################################################################
##
#F  TriangulizeIntegerMat(<mat>[,<trans>])
##
InstallGlobalFunction(TriangulizeIntegerMat, function(arg)
if Flat(arg[1])=[]  and ForAll(arg[1],x->Length(x)=Length(arg[1][1])) then return  CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2])]); fi;

if not IsMatrix(arg[1]) then 
  PrintTo("*errout*", "matrix required as argument\n");
   return fail;
fi;

if ForAll( Flat(arg[1]) , x -> x = 0 ) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2])]); fi;
if Length(arg)=1 then return NormHnf(arg[1],true);fi;
if Length(arg)=2 and arg[2]=1 then  return LcNormHnf(arg[1],true);fi;

PrintTo("*errout*", " TriangulizeIntegerMat(<mat>[,<trans>]) is yet to be implemented for trans > 1. Sorry.\n");
   return fail;

end);

#############################################################################
##
#F  NormalFormIntMat(<mat>,<options>)
##
InstallGlobalFunction(NormalFormIntMat,
 
  function(mat,options)
  local r,opt;
  r:=NFIM(mat,options);
  opt := List(CoefficientsQadic(options,2),x->x=1);
  if Length(opt)<4 then 
    opt{[Length(opt)+1..4]} := List([Length(opt)+1..4],x->false);
  fi;

  if opt[3] then
    r.rowtrans:=r.rowQ*r.rowC;
    Unbind(r.rowQ);
    Unbind(r.rowC);
  fi;

  if opt[1] and opt[4] then  
    r.coltrans:=r.colC*r.colQ;
   Unbind(r.colQ);
   Unbind(r.colC);
  fi;
   return r;
end);

#############################################################################
##
#F  DeterminantIntMat(<mat>)
##
InstallGlobalFunction(DeterminantIntMat,

function(mat)

local c,i,j,n,m,r,c1,c2,t,g,s,a,b,q,A,k,t1,t2,sig;

sig:=1;

#Embed mat in 2 larger "id" matrix
n := Length(mat)+2;
# Crossover point roughly 20x20 matrices, so farm the work if smaller..
if n<22 then return DeterminantMat(mat);fi;
m := Length(mat[1])+2;
 
if not n=m then Error( "DeterminantIntMat: <mat> must be a square matrix" );fi;

A := [List([1..m],x->0)];
for i in [2..n-1] do
  A[i] := [0];
  Append(A[i],mat[i-1]);
  A[i][m] := 0;
od;
A[n] := List([1..m],x->0);
A[1][1] := 1;      A[n][m] := 1;

r := 0;    c2 := 1;
while m>c2 do
  Info(InfoMatInt,2,"DeterminantIntMat - reached column ",c2," of ",m);
  r := r+1;
  c1 := c2;

  j := c1+1;
  while j<=m do
    k := r+1;
    while k<=n and A[r][c1]*A[k][j]=A[k][c1]*A[r][j] do k := k+1; od;
    if k<=n then c2 := j; j := m; fi;
    j := j+1;
  od;

  c := mgcdex(AbsInt(A[r][c1]),A[r+1][c1],A{[r+2..n]}[c1]);
  for i in [r+2..n] do 
    if c[i-r-1]<>0 then
      AddRowVector(A[r+1],A[i],c[i-r-1]);
    fi;
  od;

  i := r+1;
  while A[r][c1]*A[i][c2]=A[i][c1]*A[r][c2] do 
   i := i+1; 
  od;

  if i>r+1 then
     c := mgcdex(AbsInt(A[r][c1]),A[r+1][c1]+A[i][c1],[A[i][c1]])[1]+1;;
     AddRowVector(A[r+1],A[i],c);
  fi;
  
  g := bezout(A[r][c1],A[r][c2],A[r+1][c1],A[r+1][c2]);
  sig:=sig*SignInt(A[r][c1]*A[r+1][c2]-A[r][c2]*A[r+1][c1]);
  if sig=0 then return 0;fi;
 A{[r,r+1]} := [[g.coeff1,g.coeff2],[g.coeff3,g.coeff4]]*A{[r,r+1]};

  for i in [r+2..n] do
    q := QuoInt(A[i][c1],A[r][c1]);
    AddRowVector(A[i],A[r],-q);
    q := QuoInt(A[i][c2],A[r+1][c2]);
    AddRowVector(A[i],A[r+1],-q);
  od;
od; 

for i in [2..r+1] do
  sig:=sig*A[i][i];
od;

return sig;

end);

#############################################################################
##
#O  SmithNormalFormIntegerMat(<mat>)
##
InstallMethod(SmithNormalFormIntegerMat,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
return(Immutable(SNFNormDriven(MutableCopyMat(mat))));
end);

InstallOtherMethod(SmithNormalFormIntegerMat,"basic norm driven algorithm",true,[IsList],0,
function(mat)
return(Immutable(SNFNormDriven(MutableCopyMat(mat))));
end);

#############################################################################
##
#O  SmithNormalFormIntegerMatTransforms(<mat>)
##
InstallMethod(SmithNormalFormIntegerMatTransforms,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
return(SNFNormDriven(mat,5));
#return NYI(1);
end);

InstallOtherMethod(SmithNormalFormIntegerMatTransforms,"basic norm driven algorithm",true,[IsList],0,
function(mat)
return(SNFNormDriven(mat,5));
#return NYI(1);
end);

#############################################################################
##
#O  SmithNormalFormIntegerMatInverseTransforms(<mat>)
##
InstallMethod(SmithNormalFormIntegerMatInverseTransforms,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
return(SNFNormDriven(mat,10));
#return NYI(1);
end);

InstallOtherMethod(SmithNormalFormIntegerMatInverseTransforms,"basic norm driven algorithm",true,[IsList],0,
function(mat)
return(SNFNormDriven(mat,10));
#return NYI(1);
end);
#############################################################################
##
#O  HermiteNormalFormIntegerMat(<mat>[,<reduction>])
##
InstallMethod(HermiteNormalFormIntegerMat,"basic norm driven algorithm",
              true,[IsMatrix],0,
function(arg)
  return(Immutable(HNFNormDriven(MutableCopyMat(arg[1]))));
end);

InstallOtherMethod(HermiteNormalFormIntegerMat,
  "basic norm driven algorithm with reduction",true,[IsMatrix,IsRat],0,
function(arg)
  return(Immutable(HNFNormDriven(MutableCopyMat(arg[1]), 0, arg[2])));
end);

InstallOtherMethod(HermiteNormalFormIntegerMat,"basic norm driven algorithm",
              true,[IsList],0,
function(arg)
  return(Immutable(HNFNormDriven(ShallowCopy(arg[1]))));
end);

InstallOtherMethod(HermiteNormalFormIntegerMat,"basic norm driven algorithm",
              true,[IsList,IsRat],0,
function(arg)
  return(Immutable(HNFNormDriven(ShallowCopy(arg[1]),0,arg[2])));
end);

#############################################################################
##
#O  HermiteNormalFormIntegerMatTransforms(<mat>[,<reduction>])
##
InstallMethod(HermiteNormalFormIntegerMatTransforms,"basic norm driven algorithm",true,[IsMatrix],0,
function(arg)
  return(Immutable(HNFNormDriven(MutableCopyMat(arg[1]),1)));
end);

InstallOtherMethod(HermiteNormalFormIntegerMatTransforms,"basic norm driven algorithm",true,[IsMatrix,IsRat],0,
function(arg)
  return(Immutable(HNFNormDriven(MutableCopyMat(arg[1]),1,arg[2])));
end);

InstallOtherMethod(HermiteNormalFormIntegerMatTransforms,"basic norm driven algorithm", true,[IsList],0,
function(arg)
  return(Immutable(HNFNormDriven(ShallowCopy(arg[1]),true)));
end);

InstallOtherMethod(HermiteNormalFormIntegerMatTransforms,"basic norm driven algorithm", true,[IsList,IsRat],0,
function(arg)
  return(Immutable(HNFNormDriven(ShallowCopy(arg[1]),true)));
end);

#############################################################################
##
#O  HermiteNormalFormIntegerMatInverseTransforms(<mat>[,<reduction>])
##
InstallMethod(HermiteNormalFormIntegerMatInverseTransforms,"basic norm driven algorithm",true,[IsMatrix],0,
function(arg)
#  return(HNFNormDriven(arg[1],4));
return NYI(1);
end);

InstallOtherMethod(HermiteNormalFormIntegerMatInverseTransforms,"basic norm driven algorithm",true,[IsMatrix,IsRat],0,
function(arg)
#  return(HNFNormDriven(arg[1],4,arg[2]));
return NYI(1);
end);

InstallOtherMethod(HermiteNormalFormIntegerMatInverseTransforms,"basic norm driven algorithm",true,[IsList],0,
function(arg)
#  return(HNFNormDriven(arg[1],4));
return NYI(1);
end);

InstallOtherMethod(HermiteNormalFormIntegerMatInverseTransforms,"basic norm driven algorithm",true,[IsList,IsRat],0,
function(arg)
#  return(HNFNormDriven(arg[1],4));
return NYI(1);
end);


#############################################################################
##
#O  TriangulizedIntegerMat(<mat>)
##
InstallMethod(TriangulizedIntegerMat,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
return(Immutable(TriangulizeIntegerMat(MutableCopyMat(mat))));
end);

InstallOtherMethod(TriangulizedIntegerMat,"basic norm driven algorithm",true,[IsList],0,
function(mat)
return(Immutable(TriangulizeIntegerMat(ShallowCopy(mat))));
end);


#############################################################################
##
#O  TriangulizedIntegerMatTransforms(<mat>)
##
InstallMethod(TriangulizedIntegerMatTransforms,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
return(Immutable(TriangulizeIntegerMat(MutableCopyMat(mat),1)));
end);

InstallOtherMethod(TriangulizedIntegerMatTransforms,"basic norm driven algorithm",true,[IsList],0,
function(mat)
return(Immutable(TriangulizeIntegerMat(ShallowCopy(mat),1)));
end);


#############################################################################
##
#O  TriangulizedIntegerMatInverseTransforms(<mat>)
##
InstallMethod(TriangulizedIntegerMatInverseTransforms,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
#return(TriangulizeIntegerMat(mat,2));
return NYI(1);
end);

InstallOtherMethod(TriangulizedIntegerMatInverseTransforms,"basic norm driven algorithm",true,[IsList],0,
function(mat)
#return(TriangulizeIntegerMat(mat,2));
return NYI(1);
end);
