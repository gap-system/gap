#############################################################################
##
#A  oldmatint.gi                   GAP library                 Robert Wainwright
##
##
#Y  Copyright (C)  1997,  St Andrews
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file is preserved to keep the old routines available. It is not
##  read in by default.
## 
##  This file contains old methods for functions that compute Hermite and
##  Smith normal forms of integer matrices, with or without the HNF/SNF
##  expressed as the linear combination of the input.  The code is based
##  on (and in parts identical to) code written by Bohdan Majewski.

##


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
#F  LcNormHnf( <array> [,< Bool/Rat >] )  . the HNF and the transforming matrix
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
#F  LcLLLHnf( <array> [, <rat>] ) .. the Hermite NF and the transforming matrix
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

   # sort rows according the position of the leading nonzero
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
#F  HNFChouCollins(<mat>[,<trans>[,<reduction>]])
#F  HNFLLLDriven(<mat>[,<trans>[,<reduction>]])
##
##  These operations have been superceded for most purposes by
##  `NormalFormIntMat' (see~"NormalFormIntMat")
##  which should in most cases be faster than any
##  of them, and produce smaller transforming matrix entries.
##
##  These operations compute the Hermite normal form of a matrix with
##  integer entries, using the strategy specified in the name. If no optional 
##  argument <trans> is given <mat> must be a  mutable matrix which will 
##  be changed by the algorithm.
##
##  If the optional integer argument <trans> is given, it determines which
##  transformation matrices will be computed. It is interpreted binary as
##  for the Smith normal form (see "SNFNormDriven") but note that only 
##  row operations are performed. The function then returns a  record with 
##  components as specified for the Smith normal form.
##
##  If the further optional argument <reduction> (a rational in the range
##  `[0..1]')
##  is given, it specifies which representatives
##  are used for entries modulo $c$ when cleaning column entries to the top. 
##  Off-diagonal entries are reduced to the range
##  \quad$\lfloor c(r-1)\rfloor\ldots \lfloor cr\rfloor$,
##  where $r$ is the value of <reduction>.
##  If <reduction> is not given, a value of 1 is assumed.
##  Note, if <trans> is given the operation does not change <mat>.
##
##  gap> m:=[ [ 14, 20 ], [ 6, 9 ] ];;
##  gap> HNFNormDriven(m);
##  [ [ 2, 2 ], [ 0, 3 ] ]
##  gap> m;
##  [ [ 2, 2 ], [ 0, 3 ] ]
##
##  gap> m:=[[14,20],[6,9]];; 
##  gap> HNFNormDriven(m,1);
##  rec( normal := [ [ 2, 2 ], [ 0, 3 ] ], rowtrans := [ [ 1, -2 ], [ -3, 7 ] ] )
##  gap> m;
##  [ [ 14, 20 ], [ 6, 9 ] ]
##  gap> last2.rowtrans*m;
##  [ [ 2, 2 ], [ 0, 3 ] ]
##
BindGlobal("HNFNormDriven", function(arg)

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
BindGlobal("HNFChouCollins", function(arg)
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
BindGlobal("HNFLLLDriven", function(arg)
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


#############################################################################
##
#O  SNFNormDriven(<mat>[,<trans>])
#O  SNFChouCollins(<mat>[,<trans>])
##
##  These operations have been superceded for most purposes by
##  `NormalFormIntMat' (see~"NormalFormIntMat") which should in most cases
##  be faster than any
##  of them, and produce smaller transforming matrix entries.
##
##  These operations compute the Smith normal form of a matrix with
##  integer entries, using the strategy specified in the name. If no optional 
##  argument <trans> is given <mat> must be a mutable matrix which will 
##  be changed by the algorithm.
##
##  If the optional integer argument <trans> is given, it determines which
##  transformation matrices will be computed. It is interpreted binary as:
##  \beginlist
##  \item{1} Row transformations.
##
##  \item{2} Inverse row transformations.
##
##  \item{4} Column transformations.
##
##  \item{8} Inverse column transformations.
##  \endlist
##
##  The operation then returns a record with the component `normal' containing 
##   the  computed normal form and optional components `rowtrans', `rowinverse',
##  `coltrans', and `invcoltrans' which hold the computed transformation
##  matrices. Note, if <trans> is given the operation does not change <mat>.
##
##  This functionality is still to be fully implemented for SNF with transforms.
##   However, `NormalFormIntMat' performs this calculation.
##
BindGlobal("SNFNormDriven", function(arg)
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
BindGlobal("SNFChouCollins", function(arg)
if Flat(arg[1])=[]  and ForAll(arg[1],x->Length(x)=Length(arg[1][1])) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2]),IsBound(arg[2])]); fi;

if not IsMatrix(arg[1]) then 
  PrintTo("*errout*", "matrix required as argument\n");
   return fail;
fi;

if ForAll( Flat(arg[1]) , x -> x = 0 ) then return CallFuncList(IdTransReturn,[arg[1],IsBound(arg[2]),IsBound(arg[2])]); fi;
 if Length(arg)=1 then  return CallFuncList(CaCSnf,[arg[1]]);fi;
if Length(arg)=2 then return LcCaCSnf(arg);fi;
end);

