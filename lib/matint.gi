#############################################################################
##
#A  matint.gi                   GAP library                 Robert Wainwright
##
#H  $Id$
##
#Y  Copyright 1990-1992,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions that compute Hermite and Smith normal forms 
##  of integer matrices, with or without the HNF/SNF  expressed as the linear 
##  combination of the input.  The code is based on (and in parts identical
##  to) code written by Bohdan Majewski.
##
Revision.matint_gi :=
    "$Id$";

#############################################################################
##
#F  CopyMat ( <array> ) . . . . . .  returns a fully mutable copy of a matrix
##
CopyMat:=function(A)

return List(A,ShallowCopy);

end;


#############################################################################
##
#F  Round( <Rational> ) . . . . the nearest integer to the rational parameter
##
Round := function( r )
   if IsInt(r) then
      return r;
   fi;
   if DenominatorRat(r) = 2 then
      return Int(r);
   fi;
   if r < 0 
      then return Int(r - 1/2);
      else return Int(r + 1/2);
   fi;
end;

##############################################################################
##
#F  rBest( <rec>, <row>, <index>)  ......... an auxiliary function for NormHnf
##
rBest := function( A, i, h ) 

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

   return r;
end;

##############################################################################
##
#F  NormHnf( <array> [, <bool/rat>]) ... the Hermite NF of the first parameter
##
NormHnf := function( arg )

local  A, # a record (number or rows, no of columns, int matrix)
       h, # head (first nonzero) of the pivot row
 i, j, k, # local indexes
 r, t, q,qq, # auxiliary variables
enf_flag, # set to true if the user wishes Echelon form only
frac;
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

    A := rec( T := CopyMat(arg[1]), m := Length(arg[1]), n := Length(arg[1][1]) );

    i := 1;
    while i <= A.m do
       h := A.n;
       j := i;
       while j <= A.m and h > i do
         t := PositionNot(A.T[j],0);
	 if t < h then
	    h := t;
	 fi;
	 j := j + 1;
       od;

       k := rBest(A, i, h);

       repeat
          if k <> i then # swap row i and k
             t      := A.T[i];
             A.T[i] := A.T[k];
             A.T[k] := t;
          fi;
          
          t := A.T[i][h]; # the pivot

          for j in [i+1 .. A.m] do 
	     q := Round(A.T[j][h]/t);
	
             if q <> 0 then
                A.T[j] := A.T[j] - A.T[i]*q;
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

          k := rBest(A, i + 1, h);
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
	    A.T[i] := A.T[i] - q*A.T[j];
	 od;
      od;
   fi;
   return A.T{[1 .. A.m]};
end;

##############################################################################
##
#F  CaCHnf( <array> ) .................. the Hermite NF of the first parameter
##
CaCHnf := function( A )

local h, i, j, k, l, m, n, q, t, v, H;


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

   H := [ A[i] ];
   k := 1;

   while i <= m do
      # add row i of A to H
      v := CopyMat(A[i]);

      h := PositionNot(v,0);
      for j in [1 .. k] do
         if PositionNot(H[j],0) = h then
            repeat
               q := Round(v[h]/H[j][h]);
               if q <> 0 then
                  v := v - q*H[j];
               fi;

               if v[h] <> 0 then
                  q := Round(H[j][h]/v[h]);
                  H[j] := H[j] - q*v;
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
            H[j] := H[j] - q*H[l];
         od;
      od;
      i := i + 1;
   od;
   return H;
end;

#############################################################################
##
#F  LcNormHnf( <array> [,< Bool/Rat >] )  . the HNF and the tranforming matrix
##
LcNormHnf := function( arg )

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

    A := rec( T := CopyMat(arg[1]), m := Length(arg[1]), n := Length(arg[1][1]) );
    P := CopyMat(IdentityMat(A.m));

    i := 1;
    while i <= A.m do
       h := A.n;
       j := i;
       while j <= A.m and h > i do
         t := PositionNot(A.T[j],0);
	 if t < h then
	    h := t;
	 fi;
	 j := j + 1;
       od;

       k := rBest(A, i, h);

       repeat
          if k <> i then # swap row i and k
             t      := A.T[i];
             A.T[i] := A.T[k];
             A.T[k] := t;
             t := P[i]; P[i] := P[k]; P[k] := t;
          fi;
          
          t := A.T[i][h]; # the pivot

          for j in [i+1 .. A.m] do 
	     q := Round(A.T[j][h]/t);
	
             if q <> 0 then
                A.T[j] := A.T[j] - A.T[i]*q;
                P[j] := P[j] - q*P[i];
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

          k := rBest(A, i + 1, h);
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
	    A.T[i] := A.T[i] - q*A.T[j];
            P[i]   := P[i] - q*P[j];
	 od;
      od;
   fi;
   return rec( hermite := A.T{[1 .. A.m]}, transformer := P );
end;

#############################################################################
#F LcCaCHnf implements Chou & Collins strategy for computing the
## hermite normal form of an integer matrix with transforming matrix
##
LcCaCHnf := function( A )

local h, i, j, k, l, m, n, q, t, v, H, P;

   m := Length(A);
   n := Length(A[1]);
   P := CopyMat(IdentityMat(m));

   # skip initial all zero rows
   i := 1;
   while i <= m and PositionNot(A[i],0) > n do
      i := i + 1;
   od;

   # if i > m there is nothing left; return a null vector
   if i > m then
      return rec(hermite := [], transformer := P);
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
      v := CopyMat(A[i]);
      # Error("Break point 1");

      h := PositionNot(v,0);
      for j in [1 .. k] do
         if PositionNot(H[j],0) = h then
            repeat
               q := Round(v[h]/H[j][h]);
               if q <> 0 then
                  # Error("break point 1.5");
                  v := v - q*H[j];
                  # Error("break point 1.7");
                  P[i] := P[i] - q*P[j];
                  # Error("break point 2");
               fi;

               if v[h] <> 0 then
                  q := Round(H[j][h]/v[h]);
                  H[j] := H[j] - q*v;
                  P[j] := P[j] - q*P[i];
                  # Error("break point 3");
                  if H[j][h] = 0 then 
                     # Error("break point 4");
                     if v[h] < 0 then 
                        t := -v; v := H[j]; H[j] := t;
                        t := -P[i]; P[i] := P[j]; P[j] := t;
                     else 
                        t :=  v; v := H[j]; H[j] := t;
                        t := P[i]; P[i] := P[j]; P[j] := t;
                     fi;
                     # Error("Break point 5");
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
         # Error("break point 6");
         if v[h] < 0 then
            v    := -v;
            P[i] := -P[i];
         fi;
         if k < i then
            t := P[i]; P[i] := P[k]; P[k] := t;
         fi;
         H[k] := v;
         # Error("break point 7");
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
            P[j] := P[j] - q*P[l];
            H[j] := H[j] - q*H[l];
         od;
      od;
      i := i + 1;
   od;
   return rec(hermite := H, transformer := P);
end;


##############################################################################
##
#F  LcLLLHnfPrint1( <array> [, <rat>] ) .......... debuging print-out routine 
##
if not IsBound(LcLLLHnfPrint1) then LcLLLHnfPrint1 := Ignore; fi;

##############################################################################
##
#F  LcLLLHnf( <array> [, <rat>] ) .. the Hermite NF and the tranforming matrix
##
LcLLLHnf := function(arg)

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
         q := Round(b[k][c]/b[l][c]);
      else
         q := Round(mu[k][l]);
      fi;

      if q <> 0 then # \ldots and subtract $q b_l$ from $b_k$;
         b[k] := b[k] - q * b[l];
         P[k] := P[k] - q * P[l];

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

   b := CopyMat( arg[1] );
   m := Length(b);
   n := Length(b[1]);
   P := CopyMat(IdentityMat(m));

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
      LcLLLHnfPrint1("Starting column ", c, " ...");

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
      LcLLLHnfPrint1(" done\n");

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
         b[i] := b[i] - q*b[j];
         P[i] := P[i] - q*P[j];
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
         q := Round(mu[k][j]);
         if q <> 0 then
            P[k] := P[k] - q*P[j];
            for i in [1 .. j-1] do
               if mu[j][i] <> 0 then
                  mu[k][i] := mu[k][i] - q*mu[j][i];
               fi;
            od;
         fi;
      od;
   od;

   return rec( hermite := Reversed(b{[s .. m]}), transformer := Reversed(P));
end;

#############################################################################
##
##  start of smith normal form  code     
##

#############################################################################
##
#F  MatMax ( <array> )  . . . . . returns the value of the element with the
##                                largest absolute value in matrix A
MatMax := function(A, f)

local i, j, e, x;

   x := 0;
   for i in [f .. Length(A)] do
      for e in A[i] do
	 if e < 0 then e := -1*e; fi;
	 if e > x then x := e;    fi;
      od;
   od;
   return x;
end;

#############################################################################
##
#F  CaCReducePrint1     . . debuging function for Chou & Collins SNF method
##
if not IsBound(CaCReducePrint1)  then  CaCReducePrint1 := Ignore; fi;

#############################################################################
##
#F  NormReducePrint1    . . debuging function for the norm driven SNF method
##
if not IsBound(NormReducePrint1) then NormReducePrint1 := Ignore; fi;

##############################################################################
##
#F  ApproxRootRat( <Rational> [, <Rational>] )  . . . . . . . Approximate Square root of a rational
##
ApproxRootRat := function( arg )

local x, a, b, c, eps;

   if Length(arg) < 1 or not IsRat(arg[1]) or arg[1] < 0 then
      PrintTo("*errout*", "Use: ApproxRootRat( <rational> );\n");
      return 0;
   fi;

if arg[1]<1 then return 0;fi;

   if IsBound(arg[2]) and IsRat(arg[2]) 
      then eps := arg[2];
      else eps := 1/5;
   fi;
   x := arg[1];
   a := 0;
   b := x;
   c := (a + b)/2;
   while AbsInt(c^2 - x) > eps do
      if c^2 > x 
         then b := c;
         else a := c;
      fi;

   c := (a + b)/2;

   od;
   return c;
end;

##############################################################################
##
#F  DebugML3(  )  . . . . .  a debuging (printing) function for the local MLLL
##
if not IsBound(DebugML3) then DebugML3 := Ignore; fi;

##############################################################################
##
#F  ML3( <array> [, <rational>] )  . . a local variant of the MLLL algorithm
##
ML3 := function( arg )

local mmu,       # buffer $\mu$
      alpha,     # sensitivity $alpha$ (default $alpha = \frac{3}{4}$)
      kmax,      # $k_{max}$
      b,         # list $b$ of vectors
      mu,        # matrix $\mu$ of scalar products
      B,         # list $B$ of norms of $b^{\ast}$
      BB,        # buffer $B$
      q,         # buffer $q$ for function 'RED'
      i,         # loop variable $i$
      j,         # loop variable $j$
      k,         # loop variable $k$
      l,         # loop variable $l$
      n,         # number of vectors in $b$
      RED,       # reduction subprocedure; 'RED( l )'
                 # means 'RED( k, l )' in Cohen's book
      r;         # number of zero vectors found up to now

   RED := function( l )

      q := Round(mu[k][l]);
      if q <> 0 then
         DebugML3("sub(", k, ", ", l, ", ", q, ");\n");
         b[k] := b[k] - q * b[l];

         # adjust mu's
         mu[k][l] := mu[k][l] - q;
         for i in [ r+1 .. l-1 ] do  
            if mu[l][i] <> 0 then
               mu[k][i] := mu[k][i] - q * mu[l][i];
            fi;
         od;
      fi;
   end;
    

   if Length(arg) < 1 or Length(arg) > 2 or not IsMatrix(arg[1]) then
      PrintTo("*errout*", "use: ML3(<array> [, <sensitivity> ]);\n");
   fi;
   b := CopyMat(arg[1]);
   if IsBound(arg[2]) and IsRat(arg[2]) then
      alpha := arg[2];
      if alpha < 1/4 or alpha > 1 then
         PrintTo("*errout*", "Badly specified sensitivity. Using the default\n");
         alpha := 3/4;
      fi;
   else
      alpha := 3/4;
   fi;

   # step 1 (Initialize \ldots
   n    := Length( b );
   k    := 2;
   kmax := 1;
   mu   := [];
   r    := 0;

   # do some clever pre-processing. Right now, just sort b, lengthwise
   b := CopyMat( b );
   Sort(b, function(x, y) return x*x < y*y; end);

   # and handle the case of leading zero vectors in the input.)
   i := 1;
   while i <= n and ForAll( b[i], x -> x = 0 ) do
      i := i+1;
   od;

   # remove zero vectors, so that we don't need to swap them later
   if i > n then
      r := n;
      k := n+1;
   elif i > 1 then
      for j in [i .. n] do
         b[j-i+1] := b[j];
      od;
      for j in [n-i+2 .. n] do
         Unbind( b[j] );
      od;
      n := n - i + 1;
   fi;

   B  := [ b[1] * b[1] ];

   while k <= n do
      # step 2 (Incremental Gram-Schmidt)
      if k > kmax then
         kmax  := k;
         mu[k] := [];
         for j in [ r+1 .. k-1 ] do
            mmu := b[k] * b[j];
            for i in [ r+1 .. j-1 ] do
              mmu := mmu - mu[j][i] * mu[k][i];
            od;
            mu[k][j] := mmu;
         od;
         for j in [ r+1 .. k-1 ] do
            if B[j] = 0 
               then mu[k][j] := 0;
               else mu[k][j] := mu[k][j] / B[j];
            fi;
         od;

         B[k] := b[k] * b[k];
         for j in [ r+1 .. k-1 ] do
            B[k] := B[k] - mu[k][j]^2 * B[j];
         od;
         DebugML3("B[", k, "] = ", B[k], "\n");
      fi;

      # step 3 (Test LLL condition)
      RED( k-1 );
      while B[k] < ( alpha - mu[k][k-1] * mu[k][k-1] ) * B[k-1] do
         # Execute Sub-algorithm SWAPG( k ):
         DebugML3("swap(", k, ", ", k-1, ");\n");
         q      := b[k];
         b[k]   := b[k-1];
         b[k-1] := q;

         # and if k > 2, for all j such that 1 <= j <= k-2
         # exchange mu[k,j] with mu[k-1,j].
         for j in [ r+1 .. k-2 ] do
            q          := mu[k][j];
            mu[k][j]   := mu[k-1][j];
            mu[k-1][j] := q;
         od;

         mmu := mu[k][k-1];
         BB  := B[k] + mmu^2 * B[k-1];

         # Now, in the case B = 0 (i.e. B_k = 0 and  mu = 0),
         if BB = 0 then
            # exchange $B_k$ and $B_{k-1}$
            B[k]   := B[k-1];
            B[k-1] := 0;

            # and for i = k+1, k+2, \ldots, k_{max}
            # exchange mu_{i,k} and mu_{i,k-1}.
            for i in [ k+1 .. kmax ] do
               q          := mu[i][k];
               mu[i][k]   := mu[i][k-1];
               mu[i][k-1] := q;
            od;

         # In the case B_k = 0 and mu <> 0,
         elif B[k] = 0 and mmu <> 0 then
            B[k-1]     := BB;
            mu[k][k-1] := 1 / mmu;

            # and for i = k+1, k+2, \ldots, k_{max}
            # set mu_{i,k-1} :=  mu_{i,k-1} / mu.
            for i in [ k+1 .. kmax ] do
               mu[i][k-1] := mu[i][k-1] / mmu; 
            od;

         # Finally, in the case $B_k \not= 0$,
         else
            q          := B[k-1] / BB;
            mu[k][k-1] := mmu * q;
            B[k]       := B[k] * q;
            B[k-1]     := BB;

            for i in [ k+1 .. kmax ] do
               q          := mu[i][k];
               mu[i][k]   := mu[i][k-1] - mmu * q;
               mu[i][k-1] := q + mu[k][k-1] * mu[i][k];
            od;
         fi;

         # Decrease, if possible, k

         if k > 2 then 
            k := k-1; 
            DebugML3("backtrack(", k, ");\n");
         fi;

         RED( k-1 );
      od;

      if B[ r+1 ] = 0 then
         r := r+1;
         DebugML3("remove(", r, ");\n");
         # Unbind( b[r] );
      fi;

      for l in [ k-2, k-3 .. r+1 ] do
        RED( l );
      od;

      k := k+1;

      DebugML3("forward(", k, ");\n");
   od;

   while r < n and ForAll( b[ r+1 ], x -> x = 0 ) do
      r := r+1;
   od;

   return b{ [ r+1 .. n ] };
end;

##############################################################################
##
#F  NormReduce( <array> )  . . . .  a norm driven Smith normal form algorithm
##
NormReduce := function( S )

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
       #Error(" break point 1");

      # pivot in place; proceed to zero the d-th row and column
      done := false;
      repeat
         # row operations first 
         for k in [d+1 .. m] do
            q := Round(S[k][d]/S[d][d]);
            if q <> 0 then
               S[k] := CopyMat(S[k] - q*S[d]);
            fi;
         od;
#Error("1");
         # column operations follow
         
         for k in [d+1 .. n] do
            q := Round(S[d][k]/S[d][d]);
            if q <> 0 then # subtract column d from column k, q times
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
          #Error("break point 2");

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
         #Error("break point 3");
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
      NormReducePrint1("Divisor no. ", d, " is ", S[d][d], "\n");
      d := d + 1;
       #Error("break point 4");
   until d > m;
   #Error("break point 5");
end;

##############################################################################
##
#F  Diagonal( <array> )  . . . .  collects diagonal entries and ensures their
##                                divisibility cond for the diagonal matrix S
Diagonal := function( S )

local g, i, L, n;

   L := [ ];
   for i in [1 .. Minimum(Length(S), Length(S[1])) ] do
     if S[i][i] <> 0 then
        Add(L, AbsInt(S[i][i]));
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
      fi;
      i := i + 1;
   od;
   return L;
end;

##############################################################################
##
#F  NormSnf( <array> )  . . . . . . Computes the Smith Normal form of matrix A
##
NormSnf := function( A )

local S, # integer matrix
	  M, # temp matrix
	m;  # counter

   if not IsMatrix(A) then
      PrintTo("*errout*", "Use: NormSnf( <matrix> );\n");
      return fail;
   fi;
 
  M:=MutableNullMat(Length(A),Length(A[1]));
   S := CopyMat(A);
   NormReduce( S );
   S:=Diagonal(S);
   for m in [1..Length(S)] do
     M[m][m]:=S[m];
  od;
   return  M ;
end;

##############################################################################
##
#F  CaCReduce( <array> )  . . . . . diagonalizes a matrix using Chou & Collins
##
CaCReduce := function( S )

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
                  q := Round(S[i][h]/S[j][h]);
                  if q <> 0 then
                     S[i] := S[i] - q*S[j];
                  fi;

                  if S[i][h] <> 0 then
                     modfd := true;
                     q := Round(S[j][h]/S[i][h]);
                     S[j] := S[j] - q*S[i];
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
                     S[j] := S[j] - q*S[k];
                     dirty := true;
                  fi;
               od;
            od;
         fi;
         CaCReducePrint1("Done:", i, "\n");
      od;
      # transpose S and swap m and n
      S := TransposedMat(S);
      t := m; m := n; n := t;
   until not dirty;
   return S;
end;

##############################################################################
##
#F  CaCSnf( <array> )  . . . . . . . Computes the Smith Normal form of matrix A
##
CaCSnf := function( A )

local S, # integer matrix
	 m,M; # temporary variables

   if not IsMatrix(A) then
      PrintTo("*errout*", "Use: NormSnf( <matrix> );\n");
      return fail;
   fi;
   S := CopyMat(A);
  S:=Diagonal(S);

  M:=MutableNullMat(Length(A),Length(A[1])); 
   for m in [1..Length(S)] do
     M[m][m]:=S[m];
  od;
   return CaCReduce( S );
end;

##############################################################################
##
#F  LcNormSnf( <array> )  . . . . . Computes the Smith Normal form of matrix A
##
LcNormSnf := function( arg )
   PrintTo("*errout*", "LcNormSnf() is yet to be implemented. Sorry.\n");
   return fail;
end;
##############################################################################
##
#F  LcCaCSnf( <array> )  . . . . . Computes the Smith Normal form of matrix A
##
LcCaCSnf := function( arg )
   PrintTo("*errout*", "LcCaCSnf() is yet to be implemented. Sorry.\n");
   return fail;
end;

##############################################################################
##
#F  LcLLLSnf( <array> )  . . . . . Computes the Smith Normal form of matrix A
##
LcLLLSnf := function( arg )
   PrintTo("*errout*", "LcLLLSnf() is yet to be implemented. Sorry.\n");
   return fail;
end;


#############################################################################
##
#F  HNFNormDriven(<mat>[,<trans>[,<reduction>]])
##
InstallGlobalFunction( HNFNormDriven, function(arg)
if Length(arg)=1 then  return CallFuncList(NormHnf,arg);fi;
if Length(arg)=2 then return CallFuncList(LcNormHnf,arg) ;fi;
if Length(arg)>2 then
  if arg[2] then return LcNormHnf(arg[1],arg[3]);
  else return NormHnf(arg[1],arg[3]);
  fi;
fi;
end);

#############################################################################
##
#F  HNFChouCollins(<mat>[,<trans>[,<reduction>]])
##
InstallGlobalFunction( HNFChouCollins, function(arg)
if Length(arg)=1 then  return CaCHnf(arg[1]);fi;
if Length(arg)=2 then return LcCaCHnf(arg[1],arg[2]);fi;
if Length(arg)>2 then
PrintTo("*errout*", "Different Reduction routines  not yet implemented. Sorry.\n");
   return fail;fi;
end);

#############################################################################
##
#F  HNFLLLDriven(<mat>[,<trans>[,<reduction>]])
##
InstallGlobalFunction( HNFLLLDriven, function(arg)
if Length(arg)=1 then  return LcLLLHnf(arg[1]).hermite;fi;
if Length(arg)=2 then return LcLLLHnf(arg[1]);fi;
if Length(arg)>2 then
PrintTo("*errout*", "Different Reduction routines  not yet  implemented. Sorry.\n");
   return fail;fi;
end);


############################################################################
##
#F  SNFNormDriven(<mat>[,<trans>[,<reduction>]])
##
InstallGlobalFunction( SNFNormDriven, function(arg)
if Length(arg)=1 then  return NormSnf(arg[1]);fi;
if Length(arg)=2 then return LcNormSnf(arg[1],arg[2]);fi;
end);

#############################################################################
##
#F  SNFChouCollins(<mat>[,<trans>[,<reduction>]])
##
InstallGlobalFunction( SNFChouCollins, function(arg)
if Length(arg)=1 then  return CaCSnf(arg);fi;
if Length(arg)=2 then return LcCaCSnf(arg);fi;
end);

#############################################################################
##
#F  SNFLLLDriven(<mat>[,<trans>[,<reduction>]])
##
InstallGlobalFunction( SNFLLLDriven, function(arg)
if Length(arg)=1 then  return LcLLLSnf(arg[1]).hermite;fi;
if Length(arg)=2 then return LcLLLSnf(arg[1]);fi;
end);


#############################################################################
##
#O  TriangulizeIntegerMat(<mat>[,<trans>])
##
InstallGlobalFunction(TriangulizeIntegerMat, function(arg)
if Length(arg)=1 then return NormHnf(arg[1],true);fi;
if Length(arg)=2 then return LcNormHnf(arg[1],arg[2]);fi;
end);


#############################################################################
##
#O  SmithNormalFormIntegerMat(<mat>)
##
InstallMethod(SmithNormalFormIntegerMat,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
return(SNFNormDriven(mat));
end);

#############################################################################
##
#O  SmithNormalFormIntegerMatTransforms(<mat>)
##
InstallMethod(SmithNormalFormIntegerMatTransforms,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
return(SNFNormDriven(mat,true));
end);

#############################################################################
##
#O  HermiteNormalFormIntegerMat(<mat>[,<reduction>])
##
InstallMethod(HermiteNormalFormIntegerMat,"basic norm driven algorithm",true,[IsMatrix],0,
function(arg)
  return(HNFNormDriven(arg[1]));
end);

InstallOtherMethod(HermiteNormalFormIntegerMat,"basic norm driven algorithm with reduction",true,[IsMatrix,IsRat],0,
function(arg)
  return(HNFNormDriven(arg[1], false, arg[2]));
end);


#############################################################################
##
#O  HermiteNormalFormIntegerMatTransforms(<mat>[,<reduction>])
##
InstallMethod(HermiteNormalFormIntegerMatTransforms,"basic norm driven algorithm",true,[IsMatrix],0,
function(arg)
  return(HNFNormDriven(arg[1],false));

end);

InstallOtherMethod(HermiteNormalFormIntegerMatTransforms,"basic norm driven algorithm",true,[IsMatrix,IsRat],0,
function(arg)
  return(HNFNormDriven(arg[1],true,arg[2]));
end);


#############################################################################
##
#O  TriangulizedIntegerMat(<mat>)
##
InstallMethod(TriangulizedIntegerMat,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
return(TriangulizeIntegerMat(mat));
end);

#############################################################################
##
#O  TriangulizedIntegerMatTransforms(<mat>)
##
InstallMethod(TriangulizedIntegerMatTransforms,"basic norm driven algorithm",true,[IsMatrix],0,
function(mat)
return(TriangulizeIntegerMat(mat,true));
end);

