#############################################################################
##
#W  algliess.gi                 GAP library                   Willem de Graaf
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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

      cfs:= ShallowCopy( T[i][j][2] );
      cfs[pos]:= cfs[pos]+val;
      T[i][j]:= [T[i][j][1], cfs];
      cfs:= ShallowCopy( T[j][i][2] );
      cfs[pos]:= cfs[pos]-val;
      T[j][i]:= [T[j][i][1], cfs];

    fi;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeA( <n>, <F> )
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
SimpleLieAlgebraTypeA := function( n, F )

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
    T:= EmptySCTable( n^2+2*n, Zero( F ), "antisymmetric" );

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
                    T[ind1][ind2]:= [ lst, List(lst,x->One(F)) ];
                  else
                    lst:= [ n^2+n+j .. n^2+n+i-1 ];
                    T[ind1][ind2]:= [ lst, List(lst,x->-One(F)) ];
                  fi;
                else
                  if j = k and i <> l then
                    if i < l then
                      jnd:= (i-1)*n + l-1;
                    else
                      jnd:= (i-1)*n + l;
                    fi;
                    SetEntrySCTable( T, ind1, ind2, [ One(F), jnd ] );
                  fi;
                  if j <> k and i = l then
                    if k < j then
                      jnd:= (k-1)*n + j-1;
                    else
                      jnd:= (k-1)*n + j;
                    fi;
                    SetEntrySCTable( T, ind1, ind2, [ -One(F), jnd ] );
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
                val:= 2*One(F);
              else
                val:= One(F);
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
                val:= -2*One(F);
              else
                val:= -One(F);
              fi;
              SetEntrySCTable( T, n^2+n+i, ind1, [ val, jnd ] );
            fi;

            if k = i+1 and i <> l then
              if i+1 < l then
                SetEntrySCTable( T, n^2+n+i, ind1, [ -One(F), i*n + l - 1 ] );
              else
                SetEntrySCTable( T, n^2+n+i, ind1, [ -One(F), i*n + l ] );
              fi;
            fi;

            if l = i+1 and i <> k then
              if k < i+1 then
                SetEntrySCTable( T, n^2+n+i, ind1, [ One(F), (k-1)*n + i ] );
              else
                SetEntrySCTable( T, n^2+n+i, ind1,
                                      [ One(F), (k-1)*n + i + 1 ] );
              fi;
            fi;

          fi;
        od;
      od;
    od;

    L:= LieAlgebraByStructureConstants( F, T );

    CSA:= [ n^2+n+1 .. n^2+2*n ];
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
    SetIsRestrictedLieAlgebra( L, Characteristic( F ) > 0 );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeC( <n>, <F> )
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
SimpleLieAlgebraTypeC := function( n, F )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,l,         # Loop variables.
          ind1,ind2,jnd,   # Indices.
          L,               # Lie algebra, result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    # Initialize the s.c. table
    T:= EmptySCTable( 2*n^2+n, Zero(F), "antisymmetric" );

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
                AddendumSCTable(T,ind1,ind2,jnd,One(F));
              fi;

              if i=2*n+1-l then
                jnd:=(k-1)*n+j-n;
                AddendumSCTable(T,ind1,ind2,jnd,-One(F));
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
              AddendumSCTable(T,ind1,ind2,jnd,One(F));
            fi;
            if j=2*n+1-l then
              jnd:=(i-1)*n+k-n;
              AddendumSCTable(T,ind1,ind2,jnd,One(F));
            fi;
            if i=2*n+1-k then
              jnd:=(j-1)*n+l-n;
              AddendumSCTable(T,ind1,ind2,jnd,One(F));
            fi;
            if i=2*n+1-l then
              jnd:=(j-1)*n+k-n;
              AddendumSCTable(T,ind1,ind2,jnd,One(F));
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
              AddendumSCTable(T,ind1,ind2,jnd,-One(F));
            fi;
            if i=2*n+1-l then
              if k>=j then jnd:=n^2+(j-1)*(n+1-j/2)+k-j+1;
                      else jnd:=n^2+(k-1)*(n+1-k/2)+j-k+1;
              fi;
              AddendumSCTable(T,ind1,ind2,jnd,-One(F));
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
              AddendumSCTable(T,ind1,ind2,jnd,One(F));
            fi;
            if i=2*n+1-k then
              if l>=j then jnd:=(3*n^2+n)/2+(j-n-1)*(n+1-(j-n)/2)+l-j+1;
                      else jnd:=(3*n^2+n)/2+(l-n-1)*(n+1-(l-n)/2)+j-l+1;
              fi;
              AddendumSCTable(T,ind1,ind2,jnd,One(F));
            fi;

          od;
        od;
      od;
    od;

    L:= LieAlgebraByStructureConstants( F, T );

    # A Cartan subalgebra is spanned by $A_{i,2n+1-i}$ for $i = 1, ..., n$.
    CSA:= [ n, 2*n-1 .. n^2-n+1 ];
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
    SetIsRestrictedLieAlgebra( L, Characteristic( F ) > 0 );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeB( <n>, <F> )
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
SimpleLieAlgebraTypeB := function( n, F )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,l,         # Loop variables.
          ind1,ind2,jnd,   # Indices.
          L,               # Lie algebra, result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    # Initialize the s.c. table
    T:= EmptySCTable( 2*n^2+n, Zero(F), "antisymmetric" );

    # $[ A_i, A_j ]$

    for i in [2..2*n+1] do
      for j in [i+1..2*n+1] do
        jnd:=2*n+(i-2)*(2*n-(i-1)/2)+j-i;
        AddendumSCTable(T,i-1,j-1,jnd,-One(F));
      od;
    od;

    # $[ A_i, B_{kl} ]$

    for i in [2..2*n+1] do
      for k in [2..2*n+1] do
        for l in [k+1..2*n+1] do
          ind2:=2*n+(k-2)*(2*n-(k-1)/2)+l-k;
          if i=2*n+3-k then
            AddendumSCTable(T,i-1,ind2,l-1,One(F));
          fi;
          if i=2*n+3-l then
            AddendumSCTable(T,i-1,ind2,k-1,-One(F));
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
                  AddendumSCTable(T,ind1,ind2,jnd,One(F));
                else
                  jnd:=2*n+(l-2)*(2*n-(l-1)/2)+i-l;
                  AddendumSCTable(T,ind1,ind2,jnd,-One(F));
                fi;
              fi;

              if j=2*n+3-l and i<>k then
                if k>i then
                  jnd:=2*n+(i-2)*(2*n-(i-1)/2)+k-i;
                  AddendumSCTable(T,ind1,ind2,jnd,-One(F));
                else
                  jnd:=2*n+(k-2)*(2*n-(k-1)/2)+i-k;
                  AddendumSCTable(T,ind1,ind2,jnd,One(F));
                fi;
              fi;

              if i=2*n+3-k and j<>l then
                if l>j then
                  jnd:=2*n+(j-2)*(2*n-(j-1)/2)+l-j;
                  AddendumSCTable(T,ind1,ind2,jnd,-One(F));
                else
                  jnd:=2*n+(l-2)*(2*n-(l-1)/2)+j-l;
                  AddendumSCTable(T,ind1,ind2,jnd,One(F));
                fi;
              fi;

              if i=2*n+3-l and j<>k then
                if k>j then
                  jnd:=2*n+(j-2)*(2*n-(j-1)/2)+k-j;
                  AddendumSCTable(T,ind1,ind2,jnd,One(F));
                else
                  jnd:=2*n+(k-2)*(2*n-(k-1)/2)+j-k;
                  AddendumSCTable(T,ind1,ind2,jnd,-One(F));
                fi;
              fi;

            fi;
          od;
        od;
      od;
    od;

    L:= LieAlgebraByStructureConstants( F, T );

    # A Cartan subalgebra is spanned by B_{i,2n+3-i} for i=2,...n+1.
    CSA:= List( [2..n+1], x -> 2*n + (x-2)*(2*n-(x-1)/2)+2*n+3-2*x );
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
    SetIsRestrictedLieAlgebra( L, Characteristic( F ) > 0 );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeD( <n>, <F> )
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
SimpleLieAlgebraTypeD := function( n, F )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,l,         # Loop variables.
          ind1,ind2,jnd,   # Indices.
          L,               # Lie algebra, result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    # Initialize the s.c. table
    T:= EmptySCTable( 2*n^2-n, Zero( F ), "antisymmetric" );

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
                  AddendumSCTable(T,ind1,ind2,jnd, One( F ));
                else
                  jnd:=(l-1)*(2*n-l/2)+i-l;
                  AddendumSCTable(T,ind1,ind2,jnd,-One( F ));
                fi;
              fi;

              if j=2*n+1-l and i<>k then
                if k>i then
                  jnd:=(i-1)*(2*n-i/2)+k-i;
                  AddendumSCTable(T,ind1,ind2,jnd,-One( F ));
                else
                  jnd:=(k-1)*(2*n-k/2)+i-k;
                  AddendumSCTable(T,ind1,ind2,jnd,One( F ));
                fi;
              fi;

              if i=2*n+1-k and j<>l then
                if l>j then
                  jnd:=(j-1)*(2*n-j/2)+l-j;
                  AddendumSCTable(T,ind1,ind2,jnd,-One( F ));
                else
                  jnd:=(l-1)*(2*n-l/2)+j-l;
                  AddendumSCTable(T,ind1,ind2,jnd,One( F ));
                fi;
              fi;

              if i=2*n+1-l and j<>k then
                if k>j then
                  jnd:=(j-1)*(2*n-j/2)+k-j;
                  AddendumSCTable(T,ind1,ind2,jnd,One( F ));
                else
                  jnd:=(k-1)*(2*n-k/2)+j-k;
                  AddendumSCTable(T,ind1,ind2,jnd,-One( F ));
                fi;
              fi;

            fi;
          od;
        od;
      od;
    od;

    L:= LieAlgebraByStructureConstants( F, T );

    # A Cartan subalgebra is spanned by A_{i,2n+1-i} for i=1,...,n.
    CSA:= List( [1..n], x -> (x-1)*(2*n-x/2)+2*n+1-2*x );
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
    SetIsRestrictedLieAlgebra( L, Characteristic( F )>0 );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeE( <n>, <F> )
##
##  For this case we use the construction described in V. G. Kac, "Infinite
##  Dimensional Lie Algebras", Cambridge U.P., 1990, par. 7.8.
##
##  'R' will be the set of roots of $E_n$, and 'C' will be the Cartan matrix.
##  We start with the root system of $E_8$, and if 'n < 8' we select the
##  appropiate subsystem.
##
SimpleLieAlgebraTypeE := function( n, F )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,           # Loop variables.
          lst,             # A list.
          R,               # The positive roots of E_8 (or E_6 or E_7)
          cc,              # List of coefficients.
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
    T:= EmptySCTable( dim, Zero(F), "antisymmetric" );

    lst:= [ 1 .. Length( C ) ] + 2 * lenR;

    for i in [1..lenR] do
      for j in [1..lenR] do
        Rij:= R[i]+R[j];
        if Rij in R then
          k:= Position(R,Rij);
          SetEntrySCTable( T, i, j, [ eps(R[i],R[j],epsmat)*One(F), k ] );
          SetEntrySCTable( T, i+lenR, j+lenR,
                              [ eps(R[i],R[j],epsmat)*One(F), k+lenR ] );
        fi;
        if i = j then
          T[i][j+lenR]:= [ lst, -One(F)*R[i] ];
          T[i+lenR][j]:= [ lst,  One(F)*R[i] ];
        fi;
        Rij:= R[i]-R[j];
        if Rij in R then
          k:= Position(R,Rij);
          T[i][j+lenR]:= [[k],[One(F)*eps(R[i],-R[j],epsmat)]];
          T[j+lenR][i]:= [[k],[-One(F)*eps(R[i],-R[j],epsmat)]];
        elif -Rij in R then
          k:= Position(R,-Rij);
          T[i][j+lenR]:= [[k+lenR],[One(F)*eps(R[i],-R[j],epsmat)]];
          T[j+lenR][i]:= [[k+lenR],[-One(F)*eps(R[i],-R[j],epsmat)]];
        fi;
      od;
      for j in [1..Length(C)] do
        cc:=R[j]*C*R[i];
        T[2*lenR+j][i]:=[[i],[One(F)*cc]];
        T[i][2*lenR+j]:=[[i],[-One(F)*cc]];
        T[2*lenR+j][i+lenR]:=[[i+lenR],[-One(F)*cc]];
        T[i+lenR][2*lenR+j]:=[[i+lenR],[One(F)*cc]];
      od;
    od;

    L:= LieAlgebraByStructureConstants( F, T );

    # A Cartan subalgebra is spanned by the last 'n' basis elements.
    CSA:= [ dim-n+1 .. dim ];
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
    SetIsRestrictedLieAlgebra( L, Characteristic( F ) > 0 );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeF4( <F> )
##
##  $F_4$ is constructed as subalgebra of $E_6$.
##
SimpleLieAlgebraTypeF4 := function( F )

    local T,               # The table of the Lie algebra constructed.
          L,               # Lie algebra.
          v,               # basis vectors of 'L'
          K,               # Lie algebra isomorphic to the result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    L:= SimpleLieAlgebraTypeE( 6, F );
    v:= BasisVectors( CanonicalBasis( L ) );

K:= Subalgebra( L,
                [ v[2], v[4], v[1]+v[6], v[3]+v[5], v[38], v[40], v[37]+v[42],
                  v[39]+v[41], v[8], v[74], v[9]-v[10], v[76], v[7]-v[11],
                  v[73]+v[78], v[75]+v[77], v[44], v[45]-v[46], v[43]-v[47],
                  v[13]-v[14], v[12]+v[16], v[15], v[49]-v[50], v[48]+v[52],
                  v[51], v[17]+v[20], v[19], v[18]-v[21], v[53]+v[56], v[55],
                  v[54]-v[57], v[22]-v[25], v[24], v[23], v[58]-v[61],
                  v[60], v[59], v[26]-v[28], v[27], v[62]-v[64], v[63],
                  v[30], v[29]+v[31], v[66], v[65]+v[67], v[32]-v[33],
                  v[68]-v[69], v[34], v[70], v[35], v[71], v[36], v[72] ],
             "basis" );

    T:= StructureConstantsTable( BasisOfDomain( K ) );

    L:= LieAlgebraByStructureConstants( F, T );

    CSA:= [ 10, 12, 14, 15 ];
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
    SetIsRestrictedLieAlgebra( L, Characteristic( F ) > 0 );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeG2( <F> )
##
##  $G_2$ is constructed as subalgebra of $D_4$.
##
SimpleLieAlgebraTypeG2 := function( F )

    local T,               # The table of the Lie algebra constructed.
          L,               # Lie algebra.
          v,               # basis vectors of 'L'
          K,               # Lie algebra isomorphic to the result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA;             # List of indices of the basis vectors of a Cartan
                           # subalgebra.

    L:= SimpleLieAlgebraTypeD( 4, F );
    v:= BasisVectors( CanonicalBasis( L ) );

    K:= Subalgebra( L,
                [ v[6]+v[14]+v[15], v[11], v[13]+v[20]+v[23], v[17],
                  v[5]-v[9]-v[10], v[7]-v[12]+(2)*v[16],
                  v[12]-v[16], v[18]-v[21]-v[24],
                  v[3]+v[4]+v[8], v[22]+v[25]+v[26], v[2], v[27], v[1],
                  v[28] ],
             "basis" );
    T:= StructureConstantsTable( BasisOfDomain( K ) );

    L:= LieAlgebraByStructureConstants( F, T );

    CSA:= [ 6, 7 ];
    vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
    SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
    SetIsRestrictedLieAlgebra( L, Characteristic( F ) > 0 );

    return L;
end;


##############################################################################
##
#F  SimpleLieAlgebraTypeW( <n>, <F> )
##
##  The Witt Lie algebra is constructed.
##
##  The Witt algebra can be constructed as a subalgebra of the derivation
##  algebra of a certain polynomial algebra.
##  (see e.g. R. Farnsteiner and H. Strade,
##  Modular Lie Algebras and Their Representations, Dekker, New York, 1988.)
##  It is determined by a prime p and list of integers
##  n=(n_1...n_m). It is spanned by the elements
##
##                     x^{\alpha}D_j
##
##  where \alpha=(i_1..i_m) is a multi index such that 0 <= i_k < p^{n_k}-1
##  and 1 <= j <=m. The Lie multiplication is given by
##
##  [x^{\alpha}D_i,x^{\beta}D_j]={(\alpha+\beta-\epsilon_i)\choose (\alpha)}*
##  x^{\alpha+\beta-\epsilon_i}D_j-{(\alpha+\beta-\epsilon_j)\choose(\beta)}*
##  x^{\alpha+\beta-\epsilon_j}D_i.
##
##  (We refer to the above mentioned book for the notation.)
##
SimpleLieAlgebraTypeW := function( n, F )

    local p,          # The characteristic of 'F'.
          pn,
          dim,        # The dimension of the resulting Lie algebra.
          eltlist,    # A list of basis elements of the Lie algebra.
          i,j,k,      # Loop variables.
          u,noa,      # Integers.
          a,          # A list of integers.
          T,          # Multiplication table.
          x1,x2,      # Elements from 'eltlist'.
          ex,         # Multi index.
          no,         # Integer (position in a list).
          cf,         # Coefficient (element from 'F').
          L;          # The Lie algebra.

    if not IsList( n ) then
      Error( "<n> must be a list of nonnegative integers" );
    fi;

    p:= Characteristic( F );

    if p = 0 then
      Error( "<F> must be a field of nonzero characteristic" );
    fi;

    pn:=p^Sum( n );
    dim:= Length( n )*pn;
    eltlist:=[];

# First we construct a list of basis elements. A basis element is given by
# a multi index and an integer u such that 1 <= u <=m.

    for i in [0..dim-1] do

# calculate the multi-index a and the derivation D_u belonging to i

      u:= EuclideanQuotient( i, pn )+1;
      noa:= i mod pn;

# Now we calculate the multi index belonging to noa.
# The relation between multi index and number is given as follows:
# if (i_1...i_m) is the multi index then to that index belongs a number
# noa given by
#
#     noa = i_1 + p^n[1]( i_2 + p^n[2]( i_3 + .......))
#

      a:=[];
      for k in [1..Length( n )-1] do
        a[k]:= noa mod p^n[k];
        noa:= (noa-a[k])/(p^n[k]);
      od;
      Add( a, noa );
      eltlist[i+1]:=[a,u];
    od;

# Initialising the table.

    T:=EmptySCTable( dim, Zero( F ), "antisymmetric" );

# Filling the table.

    for i in [1..dim] do
      for j in [i+1..dim] do

# We calculate [x_i,x_j]. This product is a sum of two elements.

        x1:= eltlist[i];
        x2:= eltlist[j];

        if x2[1][x1[2]] > 0 then
          ex:=x1[1]+x2[1];
          ex[x1[2]]:=ex[x1[2]]-1;
          cf:=One(F);
          for k in [1..Length( n )] do
            cf:= Binomial( ex[k], x1[1][k] ) * cf;
          od;
          if cf<>Zero(F) then
            no:=Position(eltlist,[ex,x2[2]]);
            AddendumSCTable( T, i, j, no, cf );
          fi;
        fi;
        if x1[1][x2[2]] > 0 then
          ex:=x1[1]+x2[1];
          ex[x2[2]]:=ex[x2[2]]-1;
          cf:=One(F);
          for k in [1..Length( n )] do
            cf:= Binomial( ex[k], x2[1][k] ) * cf;
          od;
          if cf<>Zero(F) then
            no:=Position(eltlist,[ex,x1[2]]);
            AddendumSCTable( T, i, j, no, -cf );
          fi;
        fi;

      od;
    od;

    L:= LieAlgebraByStructureConstants( F, T );
    SetIsRestrictedLieAlgebra( L, ForAll( n, x -> x=1 ) );

# We also return the list of basis elements of 'L', because this is needed
# in the functions for the Lie algebras of type 'S' and 'H'.

    return [ L, eltlist ];

end;


##############################################################################
##
#F  SimpleLieAlgebraTypeS( <n>, <F> )
##
##  The "special" Lie algebra is constructed as a subalgebra of the
##  Witt Lie algebra. It is spanned by all elements x\in W such that
##  div(x)=0, where W is the Witt algebra.
##  We refer to the book cited in the comments to the function
##  'SimpleLieAlgebraTypeW' for the details.
##
SimpleLieAlgebraTypeS:= function( n, F )

    local dim,       # The dimension of the Witt algebra.
          i,j,       # Loop variables.
          WW,        # The output of 'SimpleLieAlgebraTypeW'.
          eqs,       # The equation system for a basis of the Lie algebra.
          divlist,   # A list of elements of the Witt algebra.
          x,         # Element from 'divlist'.
          dones,     # A list of the elements of 'divlist' that have already
                     # been processed.
          eq,        # An equation (to be added to 'eqs').
          bas,       # Basis vectors of the solution space.
          L;         # The Lie algebra.

    WW:=SimpleLieAlgebraTypeW( n, F );
    dim:= Dimension( WW[1] );
    divlist:= WW[2];
    for i in [1..dim] do

      #Apply the operator "div" to the elements of divlist.

      divlist[i][1][divlist[i][2]]:=divlist[i][1][divlist[i][2]]-1;
    od;

# At some positions of 'divlist' there will be the same element. An equation
# will then be a vector of 1's and 0's such that a 1 appears at every
# position where there is a copy of a particular element. After this we
# do not need to consider this element again, so we add it to 'dones'.

    eqs:=[]; dones:=[]; i:=1;
    while i <= dim do
      eq:=List([1..dim],x->Zero(F));
      x:=divlist[i];
      if not x in dones then
        Add(dones,x);
        if x[1][x[2]]>=0 then
          eq[i]:= One( F );
          for j in [i+1..dim] do
            if divlist[j][1]=x[1] then
              eq[j]:=One( F );
            fi;
          od;
          Add(eqs,eq);
        fi;
      fi;
      i:=i+1;
    od;

    bas:= NullspaceMat( TransposedMat( eqs ) );
    bas:= List( bas, v -> LinearCombination( Basis( WW[1] ), v ) );

    L:= DerivedSubalgebra( Subalgebra( WW[1], bas, "basis" ) );
    SetIsRestrictedLieAlgebra( L, ForAll( n, x -> x=1 ) );
    return L;

end;


##############################################################################
##
#F  SimpleLieAlgebraTypeH( <n>, <F> )
##
##  Just like the special algebra, the Hamiltonian algebra is constructed as
##  a subalgebra of the Witt Lie algebra. It is spanned by the image of
##  a linear map D_H which maps a special kind of polynomial algebra into
##  the Witt algebra. Again we refer to the book cited in the notes to
##  'SimpleLieAlgebraTypeW' for the details.
##
SimpleLieAlgebraTypeH := function( n, F )

    local p,      # Chracteristic of 'F'.
          m,      # The length of 'n'.
          i,j,    # Loop variables.
          noa,    # Integer.
          a,      # List of integers "belonging" to 'noa'.
          x1,x2,  # Multi indices.
          mons,   # List of multi indices (or monomials).
          WW,     # The output of 'SimpleLieAlgebraTypeW'.
          cf,     # List of coefficients of an element of the Witt algebra.
          pos,    # Position in a list.
          sp,     # Vector space.
          bas,    # Basis vectors of the Lie algebra.
          L;      # The Lie algebra.

    p:= Characteristic( F );

    if p = 0 then
      Error( "<F> must be a field of nonzero characteristic" );
    fi;

    if not IsList( n ) then
      Error( "<n> must be a list of nonnegative integers" );
    fi;

    m:= Length( n );
    if m mod 2 <> 0 then
      Error( "<n> must be a list of even length" );
    fi;

# 'mons' will be a list of multi indices [i1...1m] such that
# ik < p^n[k] for 1 <= k <= m. The encoding is the same as in
# 'SimpleLieAlgebraTypeW'. The last (or "maximal") element is not taken
# in the list. 'mons' will correspond to the monomials that span the
# algebra which is mapped into the Witt algebra by the map D_H.

    mons:= [];
    for i in [0..p^Sum( n ) - 2 ] do
      a:= [ ];
      noa:= i;
      for j in [1..m-1] do
        a[j]:= noa mod p^n[j];
        noa:= (noa-a[j])/(p^n[j]);
      od;
      a[m]:= noa;
      Add(mons,a);
    od;

    WW:= SimpleLieAlgebraTypeW( n, F );

    for i in [1..Length(mons)] do

# The map D_H is applied to the element 'mons[i]'.

      x1:= mons[i];
      cf:= List( WW[2], e -> Zero(F) );
      for j in [1..m/2] do
        if x1[j] > 0 then
          x2:= ShallowCopy( x1 );
          x2[j]:= x2[j] - 1;
          pos:= Position( WW[2], [x2,j+m/2] );
          cf[pos]:= One( F );
        fi;
        if x1[j+m/2] > 0 then
          x2:= ShallowCopy( x1 );
          x2[j+m/2]:= x2[j+m/2] - 1;
          pos:= Position( WW[2], [x2,j] );
          cf[pos]:= -One( F );
        fi;
      od;
      if cf <> Zero( F )*cf then
        if IsBound( sp ) then
          if not IsContainedInSpan( sp, cf ) then
            CloseMutableBasis( sp, cf );
          fi;
        else
          sp:= MutableBasisByGenerators( F, [ cf ] );
        fi;
      fi;
    od;

    bas:= BasisVectors( sp );
    bas:= List( bas, x -> LinearCombination( Basis(WW[1]), x ) );
    L:= Subalgebra( WW[1], bas, "basis" );
    SetIsRestrictedLieAlgebra( L, ForAll( n, x -> x=1 ) );
    return L;

end;


##############################################################################
##
#F  SimpleLieAlgebraTypeK( <n>, <F> )
##
##  The kontact algebra has the same underlying vector space as a
##  particular kind of polynomial algebra. On this space a Lie bracket
##  is defined. We refer to the book cited in the comments to the function
##  'SimpleLieAlgebraTypeW' for the details.
##
SimpleLieAlgebraTypeK := function( n, F )

    local p,              # The characteristic of 'F'.
          m,              # The length of 'n'.
          pn,             # The dimension of the resulting Lie algebra.
          eltlist,        # List of basis elements of the Lie algebra.
          i,j,k,          # Loop variables.
          noa,            # Integer.
          a,              # The multi index "belonging" to 'noa'.
          T,S,            # Tables of structure constants.
          x1,x2,y1,y2,    # Elements from 'eltlist'.
          r,              # Integer.
          pos,            # Position in a list.
          coef,           # Function calculating a product of binomials.
          v,              # A value.
          vals,           # A list of values.
          ii,             # List of indices.
          cc,             # List of coefficients.
          L;              # The Lie algebra.

    coef:= function( a, b, F )

# Here 'a' and 'b' are two multi indices. This function calculates
# the product of the binomial coefficients 'a[i] \choose b[i]'.

      local cf,i;

      cf:= One( F );
      for i in [1..Length(a)] do
        cf:= Binomial( a[i], b[i] ) * cf;
      od;
      return cf;
    end;


    p:= Characteristic( F );

    if p = 0 then
      Error( "<F> must be a field of nonzero characteristic" );
    fi;

    if not IsList( n ) then
      Error( "<n> must be a list of nonnegative integers" );
    fi;

    m:= Length( n );
    if m mod 2 <> 1 or m = 1 then
      Error( "<n> must be a list of odd length >= 3" );
    fi;

    pn:= p^Sum( n );

    r:= ( m - 1 )/2;

    eltlist:=[];

# First we construct a list of basis elements.

    for i in [0..pn-1] do
      noa:= i;
      a:=[];
      for k in [1..m-1] do
        a[k]:= noa mod p^n[k];
        noa:= (noa-a[k])/(p^n[k]);
      od;
      a[m]:= noa;
      eltlist[i+1]:=a;
    od;

# Initialising the table.

    T:= EmptySCTable( pn, Zero(F), "antisymmetric" );

    for i in [1..pn] do
      for j in [i+1..pn] do

# We calculate [x_i,x_j]. The coefficients of this element w.r.t. the basis
# contained in 'eltlist' will be stored in the vector 'vals'.
# The formula for the commutator is quite complicated, and this leads to
# many if-statements. (These if-statements are largely due to the fact that
# D_i(x^a)=0 if a[i]=0, so that we have to check that this element is not 0.)

        x1:= eltlist[i];
        x2:= eltlist[j];
        vals:= List([1..pn],i->Zero( F ) );

        for k in [1..r] do
          if x1[k] > 0 then

            if x2[k+r] > 0 then
              y1:= ShallowCopy(x1); y2:= ShallowCopy(x2);
              y1[k]:=y1[k]-1; y2[k+r]:=y2[k+r]-1;
              v:=coef( y1+y2, y1, F );
              if v<>Zero(F) then
                pos:= Position( eltlist, y1+y2 );
                vals[pos]:= vals[pos] + v;
              fi;
            fi;

            if x2[ m ] > 0 then
              y1:= ShallowCopy(x1); y2:= ShallowCopy(x2);
              y1[k]:=y1[k]-1; y2[ m ]:=y2[ m ]-1;
              v:=coef(x1+y2,y1,F)*(x2[k]+1);
              if v<>Zero(F) then
                pos:= Position( eltlist, x1+y2 );
                vals[pos]:= vals[pos]-v;
              fi;
            fi;

          fi;

          if x1[ m ] > 0 then

            if x2[k+r] > 0 then
              y1:= ShallowCopy(x1); y2:= ShallowCopy(x2);
              y1[m]:=y1[m]-1; y2[k+r]:=y2[k+r]-1;
              v:=coef( y1+x2, y2, F )*(x1[k+r]+1);
              if v<>Zero( F ) then
                pos:= Position( eltlist, y1+x2 );
                vals[pos]:= vals[pos] + v;
              fi;
            fi;

            if x2[ m ] > 0 then
              y1:= ShallowCopy(x1); y2:= ShallowCopy(x2);
              y1[m]:=y1[m]-1; y2[ m ]:=y2[ m ]-1;
              y1[k+r]:=y1[k+r]+1; y2[k]:=y2[k]+1;
              v:=coef(y1+y2,y1,F)*y1[k+r]*y2[k];
              if v<>Zero(F) then
                pos:= Position( eltlist, y1+y2 );
                vals[pos]:= vals[pos]-v;
              fi;

              y1:= ShallowCopy(x1); y2:= ShallowCopy(x2);
              y1[m]:=y1[m]-1; y2[ m ]:=y2[ m ]-1;
              y1[k]:=y1[k]+1; y2[k+r]:=y2[k+r]+1;
              v:=coef(y1+y2,y1,F)*y1[k]*y2[k+r];
              if v<>Zero(F) then
                pos:= Position( eltlist, y1+y2 );
                vals[pos]:= vals[pos]+v;
              fi;
            fi;

            if x2[k] > 0 then
              y1:= ShallowCopy(x1); y2:= ShallowCopy(x2);
              y1[m]:=y1[m]-1; y2[k]:=y2[k]-1;
              v:=coef( y1+x2, y2, F )*(x1[k]+1);
              if v <> Zero(F) then
                pos:= Position( eltlist, y1+x2 );
                vals[pos]:= vals[pos] + v;
              fi;
            fi;

          fi;

          if x1[k+r] > 0 then

            if x2[k] > 0 then
              y1:= ShallowCopy(x1); y2:= ShallowCopy(x2);
              y1[k+r]:=y1[k+r]-1; y2[k]:=y2[k]-1;
              v:=coef( y1+y2, y1, F );
              if v<>Zero(F) then
                pos:= Position( eltlist, y1+y2 );
                vals[pos]:= vals[pos] - v;
              fi;
            fi;

            if x2[ m ] > 0 then
              y1:= ShallowCopy(x1); y2:= ShallowCopy(x2);
              y1[k+r]:=y1[k+r]-1; y2[ m ]:=y2[ m ]-1;
              v:=coef(x1+y2,y1,F)*(x2[k+r]+1);
              if v<>Zero(F) then
                pos:= Position( eltlist, x1+y2 );
                vals[pos]:= vals[pos]-v;
              fi;
            fi;

          fi;

          if x1[m]>0 then
            y1:= ShallowCopy(x1);
            y1[m]:=y1[m]-1;
            v:=coef(y1+x2,x2,F);
            if v<>Zero(F) then
              pos:= Position( eltlist, y1+x2 );
              vals[pos]:= vals[pos]-2*v;
            fi;
          fi;

          if x2[m]>0 then
            y2:= ShallowCopy(x2);
            y2[m]:=y2[m]-1;
            v:= coef(x1+y2,x1,F);
            if v<>Zero(F) then
              pos:= Position( eltlist, x1+y2 );
              vals[pos]:= vals[pos]+2*v;
            fi;
          fi;

        od;

# We convert 'vals' to multiplication table format.

        ii:=[]; cc:=[];
        for k in [1..Length(vals)] do
          if vals[k] <> Zero( F ) then
            Add(ii,k); Add(cc,vals[k]);
          fi;
        od;

        T[i][j]:=[ii,cc];
        T[j][i]:=[ii,-cc];

      od;
    od;

    if (m + 3) mod p = 0 then

# In this case the kontact algebra is somewhat smaller.

      S:= EmptySCTable( pn-1, Zero(F), "antisymmetric" );
      for i in [1..pn-1] do
        for j in [1..pn-1] do
          S[i][j]:=T[i][j];
        od;
      od;
      T:=S;
    fi;

    L:= LieAlgebraByStructureConstants( F, T );
    SetIsRestrictedLieAlgebra( L, ForAll( n, x -> x=1 ) );
    return L;

end;


##############################################################################
##
#F  SimpleLieAlgebra( <type>, <n>, <F> )
##

SimpleLieAlgebra := function( type, n, F )

    # Check the arguments.
    if not ( IsString( type ) and IsInt( n ) and IsRing( F ) ) then
      Error( "<type> must be a string, <n> an integer, <F> a ring" );
    fi;

    if type = "A" then
      return SimpleLieAlgebraTypeA( n, F );
    elif type = "B" then
      return SimpleLieAlgebraTypeB( n, F );
    elif type = "C" then
      return SimpleLieAlgebraTypeC( n, F );
    elif type = "D" then
      return SimpleLieAlgebraTypeD( n, F );
    elif type = "E" then
      return SimpleLieAlgebraTypeE( n, F );
    elif type = "F" and n = 4 then
      return SimpleLieAlgebraTypeF4( F );
    elif type = "G" and n = 2 then
      return SimpleLieAlgebraTypeG2( F );
    elif type = "W" then
      return SimpleLieAlgebraTypeW( n, F )[1];
    elif type = "S" then
      return SimpleLieAlgebraTypeS( n, F );
    elif type = "H" then
      return SimpleLieAlgebraTypeH( n, F );
    elif type = "K" then
      return SimpleLieAlgebraTypeK( n, F );
    else
      Error( "<type> must be one of \"A\", \"B\", \"C\", \"D\", \"E\", ",
             "\"F\", \"G\", \"H\", \"K\", \"S\", \"W\" " );
    fi;
end;


#############################################################################
##
#E  algliess.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



