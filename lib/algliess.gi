#############################################################################
##
#W  algliess.gi                 GAP library                   Willem de Graaf
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions to construct semisimple Lie algebras of type
##  $A_n$, $B_n$, $C_n$, $D_n$, $E_6$, $E_7$, $E_8$, $G_2$, $F_4$,
##  as s.c. algebras over the rationals.
##
##  The Lie algebras of type $B_n$, $C_n$, and $D_n$ are formed by taking
##  a matrix $M$ and setting $L_M = \{ A \in M_k(Q) | A^T M = -M A \}$.
##
##  Prior to the part of the program where we construct the Lie algebra
##  we state the matrix $M$ used and the basis of the resulting Lie algebra.
##  Furthermore we describe the structure constants of the Lie algebra
##  relative to this basis.
##  The resulting Lie algebra will have a basis consiting of root vectors,
##  however they are not ordered.
##
Revision.algliess_gi :=
    "@(#)$Id$";


##############################################################################
##
#F  AddendumSCTable( <T>, <i>, <j>, <k>, <val> )
##
##  This function adds the structure constant c_{ij}^k to the table 'T'.
##  If 'T[i][j]' contains already some constants, then 'k' and 'val' have
##  to be inserted at the right position.
##
AddendumSCTable := function( T, i, j, k, val )

    local pos,m,r,inds,cfs;

    pos:= Position( T[i][j][1], k );
    if pos = fail then
      if T[i][j][1] = [] then

        SetEntrySCTable( T, i, j, [ val, k ] );

      else

        m:=T[i][j][1][1];
        r:=1;
        inds:=[];
        cfs:=[];
        while m<k do
          Add(inds,m);
          Add(cfs,T[i][j][2][r]);
          r:=r+1;
          if r > Length(T[i][j][1]) then
            m:= k;
          else
            m:= T[i][j][1][r];
          fi;
        od;
        Add(inds,k);
        Add(cfs,val);
        while r <= Length(T[i][j][1]) do
          Add(inds,T[i][j][1][r]);
          Add(cfs,T[i][j][2][r]);
          r:=r+1;
        od;
        T[i][j]:= [inds,cfs];
        T[j][i]:= [inds,-cfs];

      fi;

    else

      T[i][j][2][pos]:= T[i][j][2][pos]+val;
      T[j][i][2][pos]:= T[j][i][2][pos]-val;

    fi;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeA( <n> )
##
##  is the simple Lie algebra of type $A_n$.
##
##  The Lie algebras of type $A_n$ are formed by taking the regular basis of
##  $sl_{n+1}$.
##
##  The Lie algebra $sl_{n+1}$ has basis
##
##     $E_{ij}  1 <= i<>j <= n+1$,
##
##     $A_i = E_{ii} - E_{i+1,i+1}$.
##
##  The Lie multiplication with respect to this basis is described by
##
##     $[ A_i, E_{kl} ] = d_{ik} E_{il} - d_{i+1,k} E_{i+1,l} -
##                    d_{li} E_{ki} + d_{l,i+1} E_{k,i+1}$
##     $[ A_i, A_j ] = 0$
##     $[ E_{ij}, E_{kl} ] = d_{jk} E_{il} - d_{li} E_{kj}$.
##
##  This last elements sometimes is a sum of $A_i$'s.
##  We use the indexing
##
##     $E_{ij}$ ---> (i-1)*n + j-1   if j>i
##              ---> (i-1)*n + j     otherwise
##     $A_i$  ---> n^2+n + i.
##
##  (Here we use the notation $d_{ij}$ for the number which is 1 if $i = j$,
##  and 0 otherwise.)
##
SimpleLieAlgebraTypeA := function( n )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,l,         # Loop variables.
          ind1,ind2,jnd,   # Indices.
          lst,             # A list.
          val,
          L,               # Lie algebra, result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    # Initialize the s.c. table
    T:= EmptySCTable( n^2+2*n, 0, "antisymmetric" );

    # $[ E_{ij}, E_{kl} ]$
    for i in [1..n+1] do
      for j in [1..n+1] do
        if i <> j then

          if i < j then
            ind1:= (i-1)*n + j-1;
          else
            ind1:= (i-1)*n + j;
          fi;

          for k in [ 1 .. n+1 ] do
            for l in [ 1 .. n+1 ] do
              if k <> l then

                if k < l then
                  ind2:= (k-1)*n + l-1;
                else
                  ind2:= (k-1)*n + l;
                fi;

                if i = l and j = k then
                  if i < j then
                    lst:= [ n^2+n+i .. n^2+n+j-1 ];
                    T[ind1][ind2]:= [ lst, List(lst,x->1) ];
                  else
                    lst:= [ n^2+n+j .. n^2+n+i-1 ];
                    T[ind1][ind2]:= [ lst, List(lst,x->-1) ];
                  fi;
                else
                  if j = k and i <> l then
                    if i < l then
                      jnd:= (i-1)*n + l-1;
                    else
                      jnd:= (i-1)*n + l;
                    fi;
                    SetEntrySCTable( T, ind1, ind2, [ 1, jnd ] );
                  fi;
                  if j <> k and i = l then
                    if k < j then
                      jnd:= (k-1)*n + j-1;
                    else
                      jnd:= (k-1)*n + j;
                    fi;
                    SetEntrySCTable( T, ind1, ind2, [ -1, jnd ] );
                  fi;
                fi;

              fi;
            od;
          od;
        fi;
      od;
    od;

    # [A_i,E_{kl}]

    for i in [1..n] do
      for k in [1..n+1] do
        for l in [1..n+1] do
          if k<>l then

            if k < l then
              ind1:= (k-1)*n + l-1;
            else
              ind1:= (k-1)*n + l;
            fi;

            if i = k then
              if i < l then
                jnd:= (i-1)*n + l-1;
              else
                jnd:= (i-1)*n + l;
              fi;
              if i+1 = l then
                val:= 2;
              else
                val:= 1;
              fi;
              SetEntrySCTable( T, n^2+n+i, ind1, [ val, jnd ] );
            fi;

            if i = l then
              if k < i then
                jnd:=(k-1)*n + i-1;
              else
                jnd:=(k-1)*n + i;
              fi;
              if i+1 = k then
                val:= -2;
              else
                val:= -1;
              fi;
              SetEntrySCTable( T, n^2+n+i, ind1, [ val, jnd ] );
            fi;

            if k = i+1 and i <> l then
              if i+1 < l then
                SetEntrySCTable( T, n^2+n+i, ind1, [ -1, i*n + l - 1 ] );
              else
                SetEntrySCTable( T, n^2+n+i, ind1, [ -1, i*n + l ] );
              fi;
            fi;

            if l = i+1 and i <> k then
              if k < i+1 then
                SetEntrySCTable( T, n^2+n+i, ind1, [ 1, (k-1)*n + i ] );
              else
                SetEntrySCTable( T, n^2+n+i, ind1, [ 1, (k-1)*n + i + 1 ] );
              fi;
            fi;

          fi;
        od;
      od;
    od;

    L:= LieAlgebraByStructureConstants( Rationals, T );

    CSA:= [ n^2+n+1 .. n^2+2*n ];
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeC( <n> )
##
##  For the Lie algebra of type $C_n$ we take the $2n \times 2n$ matrix
##
##               $M = \sum_{i=1}^n E_{i,2n+1-i} - E_{n+i,n+1-i}$.
##
##  The Lie algebra has basis
##
##     $A_{ij} = E_{2n+1-i,j} - E_{2n+1-j,i}$   $i = 1...n, j = n+1...2n$
##
##     $B_{ij} = E_{2n+1-i,j} + E_{2n+1-j,i}$   $i = 1...n, j = i...n$
##
##     $C_{ij} = E_{2n+1-i,j} + E_{2n+1-j,i}$   $i = n+1...2n, j = i...2n$.
##
##  The Lie multiplication is described by
##  (we use the notation $d_{ij} = 1$ if $i = j$, $0$ otherwise)
##
##     [A_{ij},A_{kl}] = d_{j,2n+1-k} A_{il} - d_{i,2n+1-l} A_{kj}
##     [B_{ij},B_{kl}] = [C_{ij},C_{kl}] = 0
##     [B_{ij},C_{kl}] = d_{j,2n+1-k} A_{il} + d_{j,2n+1-l} A_{ik} +
##                       d_{i,2n+1-k} A_{jl} + d_{i,2n+1-l} A_{jk}
##     [B_{ij},A_{kl}] = -d_{j,2n+1-l} B_{ik} - d_{i,2n+1-l} B_{jk}
##     [C_{ij},A_{kl}] = d_{j,2n+1-k} C_{il} + d_{i,2n+1-k} C_{jl}.
##
##  The basis elements are numbered from 1 to 2n^2+n, as follows:
##
##     A_{ij} ----> (i-1)n + j-n
##     B_{ij} ----> n^2 + (i-1)(n+1-i/2) + j-i+1
##     C_{ij} ----> (3n^2+n)/2 + (i-n-1)(n+1-(i-n)/2) + j-i+1.
##
##  Furthermore we use the ralations B_{ji} = B_{ij} and C_{ji} = C_{ij}.
##
SimpleLieAlgebraTypeC := function( n )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,l,         # Loop variables.
          ind1,ind2,jnd,   # Indices.
          L,               # Lie algebra, result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    # Initialize the s.c. table
    T:= EmptySCTable( 2*n^2+n, 0, "antisymmetric" );

    # [A_{ij},A_{kl}]

    for i in [1..n] do
      for j in [n+1..2*n] do
        ind1:=(i-1)*n+j-n;
        for k in [1..n] do
          for l in [n+1..2*n] do
            ind2:=(k-1)*n+l-n;

            if ind2 > ind1 then

              if j=2*n+1-k then
                jnd:=(i-1)*n+l-n;
                AddendumSCTable(T,ind1,ind2,jnd,1);
              fi;

              if i=2*n+1-l then
                jnd:=(k-1)*n+j-n;
                AddendumSCTable(T,ind1,ind2,jnd,-1);
              fi;

            fi;
          od;
        od;
      od;
    od;

    # [B_{ij},C_{kl}]

    for i in [1..n] do
      for j in [i..n] do
        ind1:=n^2+(i-1)*(n+1-i/2) +j-i+1;
        for k in [n+1..2*n] do
          for l in [k..2*n] do
            ind2:=(1/2)*(3*n^2+n) + (k-n-1)*(n+1-(k-n)/2) +l-k+1;

            if j=2*n+1-k then
              jnd:=(i-1)*n+l-n;
              AddendumSCTable(T,ind1,ind2,jnd,1);
            fi;
            if j=2*n+1-l then
              jnd:=(i-1)*n+k-n;
              AddendumSCTable(T,ind1,ind2,jnd,1);
            fi;
            if i=2*n+1-k then
              jnd:=(j-1)*n+l-n;
              AddendumSCTable(T,ind1,ind2,jnd,1);
            fi;
            if i=2*n+1-l then
              jnd:=(j-1)*n+k-n;
              AddendumSCTable(T,ind1,ind2,jnd,1);
            fi;

          od;
        od;
      od;
    od;

    # [B_{ij},A_{kl}]

    for i in [1..n] do
      for j in [i..n] do
        ind1:=n^2+(i-1)*(n+1-i/2) +j-i+1;
        for k in [1..n] do
          for l in [n+1..2*n] do
            ind2:=(k-1)*n+l-n;

            if j=2*n+1-l then
              if k>=i then jnd:=n^2+(i-1)*(n+1-i/2)+ k-i+1;
                      else jnd:=n^2+(k-1)*(n+1-k/2)+ i-k+1;
              fi;
              AddendumSCTable(T,ind1,ind2,jnd,-1);
            fi;
            if i=2*n+1-l then
              if k>=j then jnd:=n^2+(j-1)*(n+1-j/2)+k-j+1;
                      else jnd:=n^2+(k-1)*(n+1-k/2)+j-k+1;
              fi;
              AddendumSCTable(T,ind1,ind2,jnd,-1);
            fi;

          od;
        od;
      od;
    od;

    # [C_{ij},A_{kl}]

    for i in [n+1..2*n] do
      for j in [i..2*n] do
        ind1:=(3*n^2+n)/2+(i-n-1)*(n+1-(i-n)/2) +j-i+1;
        for k in [1..n] do
          for l in [n+1..2*n] do
            ind2:=(k-1)*n+l-n;

            if j=2*n+1-k then
              if l>=i then jnd:=(3*n^2+n)/2+(i-n-1)*(n+1-(i-n)/2)+l-i+1;
                      else jnd:=(3*n^2+n)/2+(l-n-1)*(n+1-(l-n)/2)+i-l+1;
              fi;
              AddendumSCTable(T,ind1,ind2,jnd,1);
            fi;
            if i=2*n+1-k then
              if l>=j then jnd:=(3*n^2+n)/2+(j-n-1)*(n+1-(j-n)/2)+l-j+1;
                      else jnd:=(3*n^2+n)/2+(l-n-1)*(n+1-(l-n)/2)+j-l+1;
              fi;
              AddendumSCTable(T,ind1,ind2,jnd,1);
            fi;

          od;
        od;
      od;
    od;

    L:= LieAlgebraByStructureConstants( Rationals, T );

    # A Cartan subalgebra is spanned by $A_{i,2n+1-i}$ for $i = 1, ..., n$.
    CSA:= [ n, 2*n-1 .. n^2-n+1 ];
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeB( <n> )
##
##  For the Lie algebra of type $B_n$ we use the $(2n+1)x(2n+1)$ matrix
##
##                       $M = E_{11} + \sum_{i=1}^{2n} E_{i+1,2n+2-i}$
##
##  The resulting basis is the following
##
##        $A_i = E_{2n+3-i,1} - E_{1i}$            $i = 2, ..., 2n+1$
##
##        $B_{ij} = E_{2n+3-i,j} - E_{2n+3-j,i}$   $i = 2, ..., 2n+1$,
##                                                 $j = i+1, ..., 2n+1$.
##
##  The Lie multiplication is described by
##
##        $[A_i,A_j] = -B_{ij}$
##        $[B_{ij},B_{kl}] = d_{j,2n+3-k} B_{il} - d_{j,2n+3-l} B_{ik} -
##                          d_{i,2n+3-k} B_{jl} + d_{i,2n+3-l} B_{jk}$
##        $[A_i,B_{kl}] = d_{i,2n+3-k} A_l - d_{i,2n+3-l} A_k$.
##
##  We use the following numbering:
##
##        $A_i$ ---> $i-1$
##        $B_{ij}$ ---> $2n + (i-2)(2n-(i-1)/2) + j-i$,
##
##  and the relation $B_{ji} = -B_{ij}$.
##
SimpleLieAlgebraTypeB := function( n )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,l,         # Loop variables.
          ind1,ind2,jnd,   # Indices.
          L,               # Lie algebra, result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    # Initialize the s.c. table
    T:= EmptySCTable( 2*n^2+n, 0, "antisymmetric" );

    # $[ A_i, A_j ]$

    for i in [2..2*n+1] do
      for j in [i+1..2*n+1] do
        jnd:=2*n+(i-2)*(2*n-(i-1)/2)+j-i;
        AddendumSCTable(T,i-1,j-1,jnd,-1);
      od;
    od;

    # $[ A_i, B_{kl} ]$

    for i in [2..2*n+1] do
      for k in [2..2*n+1] do
        for l in [k+1..2*n+1] do
          ind2:=2*n+(k-2)*(2*n-(k-1)/2)+l-k;
          if i=2*n+3-k then
            AddendumSCTable(T,i-1,ind2,l-1,1);
          fi;
          if i=2*n+3-l then
            AddendumSCTable(T,i-1,ind2,k-1,-1);
          fi;
        od;
      od;
    od;

    # $[ B_{ij}, B_{kl} ]$

    for i in [2..2*n+1] do
      for j in [i+1..2*n+1] do
        ind1:=2*n+(i-2)*(2*n-(i-1)/2)+j-i;
        for k in [2..2*n+1] do
          for l in [k+1..2*n+1] do
            ind2:=2*n+(k-2)*(2*n-(k-1)/2)+l-k;
            if ind2>ind1 then

              if j=2*n+3-k and i<>l then
                if l>i then
                  jnd:=2*n+(i-2)*(2*n-(i-1)/2)+l-i;
                  AddendumSCTable(T,ind1,ind2,jnd,1);
                else
                  jnd:=2*n+(l-2)*(2*n-(l-1)/2)+i-l;
                  AddendumSCTable(T,ind1,ind2,jnd,-1);
                fi;
              fi;

              if j=2*n+3-l and i<>k then
                if k>i then
                  jnd:=2*n+(i-2)*(2*n-(i-1)/2)+k-i;
                  AddendumSCTable(T,ind1,ind2,jnd,-1);
                else
                  jnd:=2*n+(k-2)*(2*n-(k-1)/2)+i-k;
                  AddendumSCTable(T,ind1,ind2,jnd,1);
                fi;
              fi;

              if i=2*n+3-k and j<>l then
                if l>j then
                  jnd:=2*n+(j-2)*(2*n-(j-1)/2)+l-j;
                  AddendumSCTable(T,ind1,ind2,jnd,-1);
                else
                  jnd:=2*n+(l-2)*(2*n-(l-1)/2)+j-l;
                  AddendumSCTable(T,ind1,ind2,jnd,1);
                fi;
              fi;

              if i=2*n+3-l and j<>k then
                if k>j then
                  jnd:=2*n+(j-2)*(2*n-(j-1)/2)+k-j;
                  AddendumSCTable(T,ind1,ind2,jnd,1);
                else
                  jnd:=2*n+(k-2)*(2*n-(k-1)/2)+j-k;
                  AddendumSCTable(T,ind1,ind2,jnd,-1);
                fi;
              fi;

            fi;
          od;
        od;
      od;
    od;

    L:= LieAlgebraByStructureConstants( Rationals, T );

    # A Cartan subalgebra is spanned by B_{i,2n+3-i} for i=2,...n+1.
    CSA:= List( [2..n+1], x -> 2*n + (x-2)*(2*n-(x-1)/2)+2*n+3-2*x );
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeD( <n> )
##
##  For the Lie algebra of type $D_n$ we use the $2n \times 2n$ matrix
##
##                     $M = \sum_{i=1}^2n E_{i,2n+1-i}$.
##
##  The resulting basis is
##
##        $A_{ij} = E_{2n+1-i,j} - E_{2n+1-j,i}$  $i = 1...2n$, $j = i+1...2n$.
##
##  The Lie multiplication is described by
##
##        $[ A_{ij}, A_{kl} ] = d_{j,2n+1-k} A_{il} - d_{j,2n+1-l} A_{ik} -
##                          d_{i,2n+1-k} A_{jl} + d_{i,2n+1-l} A_{jk}$.
##
##  We use the numbering
##
##        $A_{ij}$ ---> $(i-1)(2n-i/2) + j-i$
##
##  and the relation $A_{ji} = -A_{ij}$.
##
SimpleLieAlgebraTypeD := function( n )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,l,         # Loop variables.
          ind1,ind2,jnd,   # Indices.
          L,               # Lie algebra, result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    # Initialize the s.c. table
    T:= EmptySCTable( 2*n^2-n, 0, "antisymmetric" );

    # $[ A_{ij}, A_{kl} ]$

    for i in [1..2*n] do
      for j in [i+1..2*n] do
        ind1:=(i-1)*(2*n-i/2)+j-i;
        for k in [1..2*n] do
          for l in [k+1..2*n] do
            ind2:=(k-1)*(2*n-k/2)+l-k;
            if ind2>ind1 then

              if j=2*n+1-k and i<>l then
                if l>i then
                  jnd:=(i-1)*(2*n-i/2)+l-i;
                  AddendumSCTable(T,ind1,ind2,jnd,1);
                else
                  jnd:=(l-1)*(2*n-l/2)+i-l;
                  AddendumSCTable(T,ind1,ind2,jnd,-1);
                fi;
              fi;

              if j=2*n+1-l and i<>k then
                if k>i then
                  jnd:=(i-1)*(2*n-i/2)+k-i;
                  AddendumSCTable(T,ind1,ind2,jnd,-1);
                else
                  jnd:=(k-1)*(2*n-k/2)+i-k;
                  AddendumSCTable(T,ind1,ind2,jnd,1);
                fi;
              fi;

              if i=2*n+1-k and j<>l then
                if l>j then
                  jnd:=(j-1)*(2*n-j/2)+l-j;
                  AddendumSCTable(T,ind1,ind2,jnd,-1);
                else
                  jnd:=(l-1)*(2*n-l/2)+j-l;
                  AddendumSCTable(T,ind1,ind2,jnd,1);
                fi;
              fi;

              if i=2*n+1-l and j<>k then
                if k>j then
                  jnd:=(j-1)*(2*n-j/2)+k-j;
                  AddendumSCTable(T,ind1,ind2,jnd,1);
                else
                  jnd:=(k-1)*(2*n-k/2)+j-k;
                  AddendumSCTable(T,ind1,ind2,jnd,-1);
                fi;
              fi;

            fi;
          od;
        od;
      od;
    od;

    L:= LieAlgebraByStructureConstants( Rationals, T );

    # A Cartan subalgebra is spanned by A_{i,2n+1-i} for i=1,...,n.
    CSA:= List( [1..n], x -> (x-1)*(2*n-x/2)+2*n+1-2*x );
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeE( <n> )
##
##  For this case we use the construction described in V. G. Kac, "Infinite
##  Dimensional Lie Algebras", Cambridge U.P., 1990, par. 7.8.
##
##  'R' will be the set of roots of $E_n$, and 'C' will be the Cartan matrix.
##  We start with the root system of $E_8$, and if 'n < 8' we select the
##  appropiate subsystem.
##
SimpleLieAlgebraTypeE := function( n )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,l,         # Loop variables.
          lst,             # A list.
          R,               # The positive roots of E_8 (or E_6 or E_7)
          lenR,            # length of 'R'
          Rij,             # The sum of two roots from 'R'.
          eps,             # The so-called "epsilon"-function.
          epsmat,          # A matrix used to calculate the eps-function.
          dim,             # The dimension of the Lie algebra.
          C,               # The Cartan matrix of $E_n$
          L,               # Lie algebra, result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    R:= [
      [ 1, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0, 0, 0 ],
      [ 0, 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0, 0 ],
      [ 0, 0, 0, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0, 0 ],
      [ 0, 0, 0, 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 1 ],
      [ 1, 0, 1, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 1, 0, 0, 0, 0 ],
      [ 0, 0, 1, 1, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 1, 0, 0, 0 ],
      [ 0, 0, 0, 0, 1, 1, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 1, 0 ],
      [ 0, 0, 0, 0, 0, 0, 1, 1 ], [ 1, 0, 1, 1, 0, 0, 0, 0 ],
      [ 0, 1, 1, 1, 0, 0, 0, 0 ], [ 0, 1, 0, 1, 1, 0, 0, 0 ],
      [ 0, 0, 1, 1, 1, 0, 0, 0 ], [ 0, 0, 0, 1, 1, 1, 0, 0 ],
      [ 0, 0, 0, 0, 1, 1, 1, 0 ], [ 0, 0, 0, 0, 0, 1, 1, 1 ],
      [ 1, 1, 1, 1, 0, 0, 0, 0 ], [ 1, 0, 1, 1, 1, 0, 0, 0 ],
      [ 0, 1, 1, 1, 1, 0, 0, 0 ], [ 0, 1, 0, 1, 1, 1, 0, 0 ],
      [ 0, 0, 1, 1, 1, 1, 0, 0 ], [ 0, 0, 0, 1, 1, 1, 1, 0 ],
      [ 0, 0, 0, 0, 1, 1, 1, 1 ], [ 1, 1, 1, 1, 1, 0, 0, 0 ],
      [ 1, 0, 1, 1, 1, 1, 0, 0 ], [ 0, 1, 1, 2, 1, 0, 0, 0 ],
      [ 0, 1, 1, 1, 1, 1, 0, 0 ], [ 0, 1, 0, 1, 1, 1, 1, 0 ],
      [ 0, 0, 1, 1, 1, 1, 1, 0 ], [ 0, 0, 0, 1, 1, 1, 1, 1 ],
      [ 1, 1, 1, 2, 1, 0, 0, 0 ], [ 1, 1, 1, 1, 1, 1, 0, 0 ],
      [ 1, 0, 1, 1, 1, 1, 1, 0 ], [ 0, 1, 1, 2, 1, 1, 0, 0 ],
      [ 0, 1, 1, 1, 1, 1, 1, 0 ], [ 0, 1, 0, 1, 1, 1, 1, 1 ],
      [ 0, 0, 1, 1, 1, 1, 1, 1 ], [ 1, 1, 2, 2, 1, 0, 0, 0 ],
      [ 1, 1, 1, 2, 1, 1, 0, 0 ], [ 1, 1, 1, 1, 1, 1, 1, 0 ],
      [ 1, 0, 1, 1, 1, 1, 1, 1 ], [ 0, 1, 1, 2, 2, 1, 0, 0 ],
      [ 0, 1, 1, 2, 1, 1, 1, 0 ], [ 0, 1, 1, 1, 1, 1, 1, 1 ],
      [ 1, 1, 2, 2, 1, 1, 0, 0 ], [ 1, 1, 1, 2, 2, 1, 0, 0 ],
      [ 1, 1, 1, 2, 1, 1, 1, 0 ], [ 1, 1, 1, 1, 1, 1, 1, 1 ],
      [ 0, 1, 1, 2, 2, 1, 1, 0 ], [ 0, 1, 1, 2, 1, 1, 1, 1 ],
      [ 1, 1, 2, 2, 2, 1, 0, 0 ], [ 1, 1, 2, 2, 1, 1, 1, 0 ],
      [ 1, 1, 1, 2, 2, 1, 1, 0 ], [ 1, 1, 1, 2, 1, 1, 1, 1 ],
      [ 0, 1, 1, 2, 2, 2, 1, 0 ], [ 0, 1, 1, 2, 2, 1, 1, 1 ],
      [ 1, 1, 2, 3, 2, 1, 0, 0 ], [ 1, 1, 2, 2, 2, 1, 1, 0 ],
      [ 1, 1, 2, 2, 1, 1, 1, 1 ], [ 1, 1, 1, 2, 2, 2, 1, 0 ],
      [ 1, 1, 1, 2, 2, 1, 1, 1 ], [ 0, 1, 1, 2, 2, 2, 1, 1 ],
      [ 1, 2, 2, 3, 2, 1, 0, 0 ], [ 1, 1, 2, 3, 2, 1, 1, 0 ],
      [ 1, 1, 2, 2, 2, 2, 1, 0 ], [ 1, 1, 2, 2, 2, 1, 1, 1 ],
      [ 1, 1, 1, 2, 2, 2, 1, 1 ], [ 0, 1, 1, 2, 2, 2, 2, 1 ],
      [ 1, 2, 2, 3, 2, 1, 1, 0 ], [ 1, 1, 2, 3, 2, 2, 1, 0 ],
      [ 1, 1, 2, 3, 2, 1, 1, 1 ], [ 1, 1, 2, 2, 2, 2, 1, 1 ],
      [ 1, 1, 1, 2, 2, 2, 2, 1 ], [ 1, 2, 2, 3, 2, 2, 1, 0 ],
      [ 1, 2, 2, 3, 2, 1, 1, 1 ], [ 1, 1, 2, 3, 3, 2, 1, 0 ],
      [ 1, 1, 2, 3, 2, 2, 1, 1 ], [ 1, 1, 2, 2, 2, 2, 2, 1 ],
      [ 1, 2, 2, 3, 3, 2, 1, 0 ], [ 1, 2, 2, 3, 2, 2, 1, 1 ],
      [ 1, 1, 2, 3, 3, 2, 1, 1 ], [ 1, 1, 2, 3, 2, 2, 2, 1 ],
      [ 1, 2, 2, 4, 3, 2, 1, 0 ], [ 1, 2, 2, 3, 3, 2, 1, 1 ],
      [ 1, 2, 2, 3, 2, 2, 2, 1 ], [ 1, 1, 2, 3, 3, 2, 2, 1 ],
      [ 1, 2, 3, 4, 3, 2, 1, 0 ], [ 1, 2, 2, 4, 3, 2, 1, 1 ],
      [ 1, 2, 2, 3, 3, 2, 2, 1 ], [ 1, 1, 2, 3, 3, 3, 2, 1 ],
      [ 2, 2, 3, 4, 3, 2, 1, 0 ], [ 1, 2, 3, 4, 3, 2, 1, 1 ],
      [ 1, 2, 2, 4, 3, 2, 2, 1 ], [ 1, 2, 2, 3, 3, 3, 2, 1 ],
      [ 2, 2, 3, 4, 3, 2, 1, 1 ], [ 1, 2, 3, 4, 3, 2, 2, 1 ],
      [ 1, 2, 2, 4, 3, 3, 2, 1 ], [ 2, 2, 3, 4, 3, 2, 2, 1 ],
      [ 1, 2, 3, 4, 3, 3, 2, 1 ], [ 1, 2, 2, 4, 4, 3, 2, 1 ],
      [ 2, 2, 3, 4, 3, 3, 2, 1 ], [ 1, 2, 3, 4, 4, 3, 2, 1 ],
      [ 2, 2, 3, 4, 4, 3, 2, 1 ], [ 1, 2, 3, 5, 4, 3, 2, 1 ],
      [ 2, 2, 3, 5, 4, 3, 2, 1 ], [ 1, 3, 3, 5, 4, 3, 2, 1 ],
      [ 2, 3, 3, 5, 4, 3, 2, 1 ], [ 2, 2, 4, 5, 4, 3, 2, 1 ],
      [ 2, 3, 4, 5, 4, 3, 2, 1 ], [ 2, 3, 4, 6, 4, 3, 2, 1 ],
      [ 2, 3, 4, 6, 5, 3, 2, 1 ], [ 2, 3, 4, 6, 5, 4, 2, 1 ],
      [ 2, 3, 4, 6, 5, 4, 3, 1 ], [ 2, 3, 4, 6, 5, 4, 3, 2 ] ];

    C:= [
      [ 2, 0, -1, 0, 0, 0, 0, 0 ], [ 0, 2, 0, -1, 0, 0, 0, 0 ],
      [ -1, 0, 2, -1, 0, 0, 0, 0 ], [ 0, -1, -1, 2, -1, 0, 0, 0 ],
      [ 0, 0, 0, -1, 2, -1, 0, 0 ], [ 0, 0, 0, 0, -1, 2, -1, 0 ],
      [ 0, 0, 0, 0, 0, -1, 2, -1 ], [ 0, 0, 0, 0, 0, 0, -1, 2 ] ];

    if n = 6 then
      R:= Filtered( R, v -> (v[7]=0 and v[8]=0) );
      R:= List( R, v -> v{ [ 1 .. 6 ] } );
      C:= C{ [ 1 .. 6 ] }{ [ 1 .. 6 ] };
    elif n = 7 then
      R:= Filtered( R, v -> v[8]=0 );
      R:= List( R, v -> v{ [ 1 .. 7 ] } );
      C:= C{ [ 1 .. 7 ] }{ [ 1 .. 7 ] };
    elif n < 6 or 8 < n then
      Error( "<n> must be one of 6, 7, 8" );
    fi;

    # The following function is the so-called epsilon function.
    eps:= function( a, b, epm )
         return Product( [1..Length(C)],i ->
                             Product( [1..Length(C)], j ->
                               epm[i][j] ^ ( a[i]*b[j] ) ) );
    end;

    epsmat:= [];
    for i in [ 1 .. Length(C) ] do
      epsmat[i]:= [];
      for j in [ 1 .. i-1 ] do
        epsmat[i][j]:= 1;
      od;
      epsmat[i][i]:= -1;
      for j in [ i+1 .. Length(C) ] do
        epsmat[i][j]:= (-1)^C[i][j];
      od;
    od;

    lenR:= Length( R );
    dim:= 2*lenR + Length(C);

    # Initialize the s.c. table
    T:= EmptySCTable( dim, 0, "antisymmetric" );

    lst:= [ 1 .. Length( C ) ] + 2 * lenR;

    for i in [1..lenR] do
      for j in [1..lenR] do
        Rij:= R[i]+R[j];
        if Rij in R then
          k:= Position(R,Rij);
          SetEntrySCTable( T, i, j, [ eps(R[i],R[j],epsmat), k ] );
          SetEntrySCTable( T, i+lenR, j+lenR,
                              [ eps(R[i],R[j],epsmat), k+lenR ] );
        fi;
        if i = j then
          T[i][j+lenR]:= [ lst, -R[i] ];
          T[i+lenR][j]:= [ lst,  R[i] ];
        fi;
        Rij:= R[i]-R[j];
        if Rij in R then
          k:= Position(R,Rij);
          T[i][j+lenR]:= [[k],[eps(R[i],-R[j],epsmat)]];
          T[j+lenR][i]:= [[k],-[eps(R[i],-R[j],epsmat)]];
        elif -Rij in R then
          k:= Position(R,-Rij);
          T[i][j+lenR]:= [[k+lenR],[eps(R[i],-R[j],epsmat)]];
          T[j+lenR][i]:= [[k+lenR],-[eps(R[i],-R[j],epsmat)]];
        fi;
      od;
      for j in [1..Length(C)] do
        T[2*lenR+j][i]:=[[i],[R[j]*C*R[i]]];
        T[i][2*lenR+j]:=[[i],-[R[j]*C*R[i]]];
        T[2*lenR+j][i+lenR]:=[[i+lenR],[-R[j]*C*R[i]]];
        T[i+lenR][2*lenR+j]:=[[i+lenR],[R[j]*C*R[i]]];
      od;
    od;

    L:= LieAlgebraByStructureConstants( Rationals, T );

    # A Cartan subalgebra is spanned by the last 'n' basis elements.
    CSA:= [ dim-n+1 .. dim ];
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeF4()
##
##  $F_4$ is constructed as subalgebra of $E_6$.
##
SimpleLieAlgebraTypeF4 := function()

    local T,               # The table of the Lie algebra constructed.
          L,               # Lie algebra.
          v,               # basis vectors of 'L'
          K,               # Lie algebra isomorphic to the result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    L:= SimpleLieAlgebraTypeE( 6 );
    v:= BasisVectors( CanonicalBasis( L ) );
    v:= [ v[2], v[4], v[1]+v[6], v[3]+v[5], v[38], v[40], v[37]+v[42],
          v[39]+v[41] ];
    K:= SubalgebraNC( L, v );
#T better prescribe a basis!
    T:= StructureConstantsTable( BasisOfDomain( K ) );

    L:= LieAlgebraByStructureConstants( Rationals, T );

#T      CSA:= [ 10, 12, 14, 15 ];
#T      vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
#T      SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
#T  w.r.t. what basis is 'CSA' to be understood ?

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeG2()
##
##  $G_2$ is constructed as subalgebra of $D_4$.
##
SimpleLieAlgebraTypeG2 := function()

    local T,               # The table of the Lie algebra constructed.
          L,               # Lie algebra.
          v,               # basis vectors of 'L'
          K,               # Lie algebra isomorphic to the result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    L:= SimpleLieAlgebraTypeD( 4 );
    v:= BasisVectors( CanonicalBasis( L ) );
    v:= [ v[6]+v[14]+v[15],v[11],v[13]+v[23]+v[20],v[17] ];

    K:= Subalgebra( L, v );
#T better prescribe a basis!
    T:= StructureConstantsTable( BasisOfDomain( K ) );

    L:= LieAlgebraByStructureConstants( Rationals, T );

#T      CSA:= [ 6, 7 ];
#T      vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
#T      SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
#T  w.r.t. what basis is 'CSA' to be understood ?

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebra( <type>, <n> )
##
SimpleLieAlgebra := function( type, n )

    if type = "A" then
      return SimpleLieAlgebraTypeA( n );
    elif type = "B" then
      return SimpleLieAlgebraTypeB( n );
    elif type = "C" then
      return SimpleLieAlgebraTypeC( n );
    elif type = "D" then
      return SimpleLieAlgebraTypeD( n );
    elif type = "E" then
      return SimpleLieAlgebraTypeE( n );
    elif type = "F" and n = 4 then
      return SimpleLieAlgebraTypeF4();
    elif type = "G" and n = 2 then
      return SimpleLieAlgebraTypeG2();
    else
      Error( "<type> must be one of \"A\", \"B\", \"C\", \"D\", \"E\", ",
             "\"F\", \"G\"" );
    fi;
end;


#############################################################################
##
#E  algliess.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



