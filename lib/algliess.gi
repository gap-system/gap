#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Willem de Graaf.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains functions to construct semisimple Lie algebras of type
##  $A_n$, $B_n$, $C_n$, $D_n$, $E_6$, $E_7$, $E_8$, $F_4$, $G_2$,
##  as s.c. algebras. Also there are the restricted Lie algebras
##  of types W,H,K,S.
##
##  The algorithm used for types $A-G$ is the one described in
##  Kac, Infinite Dimensional Lie Algebras, and de Graaf, Lie Algebras:
##  Theory and Algorithms.
##
##


##############################################################################
##
#F  AddendumSCTable( <T>, <i>, <j>, <k>, <val> )
##
##  This function adds the structure constant c_{ij}^k to the table 'T'.
##  If 'T[i][j]' contains already some constants, then 'k' and 'val' have
##  to be inserted at the right position.
##
BindGlobal( "AddendumSCTable", function( T, i, j, k, val )

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
end );



BindGlobal( "SimpleLieAlgebraTypeA_G", function( type, n, F )

    local T,               # The table of the Lie algebra constructed.
          i,j,k,l,         # Loop variables.
          lst,             # A list.
          R,               # Positive roots
          cc,              # List of coefficients.
          lenR,            # length of 'R'
          Rij,             # The sum of two roots from 'R'.
          eps,             # The so-called "epsilon"-function.
          epsmat,          # A matrix used to calculate the eps-function.
          dim,             # The dimension of the Lie algebra.
          C,               # Cartan matrix
          L,               # Lie algebra, result
          vectors,         # vectors spanning a Cartan subalgebra
          CSA,             # List of indices of the basis vectors of a Cartan
                           # subalgebra.
          e,
          inds,            # List of indices.
          r,r1,r2,         # Roots.
          roots,           # List of roots.
          primes,          # List of lists of corresponding roots.
          B,               # Basis of a vector space.
          cfs,             # List of coefficient lists.
          d,               # Order of the diagram automorphism.
          found,           # Boolean.
          a,
          q,
          perm,            # Permutation representing the diagram automorphism.
          shorts,
          posR,            # Positive roots.
          CartanMatrixToPositiveRoots; # Function for determining the
                                       # positive roots.


    CartanMatrixToPositiveRoots:= function( C )

        local   rank,  posr,  ready,  ind,  le,  i,  a,  j,  ej,  r,  b,
                q;

        rank:= Length( C );

        # `posr' will be a list of the positive roots. We start with the
        # simple roots, which are simply unit vectors.

        posr:= IdentityMat( rank );

        ready:= false;
        ind:= 1;
        le:= rank;
        while ind <= le  do

            # We loop over those elements of `posR' that have been found in
            # the previous round, i.e., those at positions ranging from
            # `ind' to `le'.

            le:= Length( posr );
            for i in [ind..le] do
                a:= posr[i];

                # We determine whether a+ej is a root (where ej is the j-th
                # simple root.
                for j in [1..rank] do
                    ej:= posr[j];

                    # We determine the maximum number `r' such that a-r*ej is
                    # a root.
                    r:= -1;
                    b:= ShallowCopy( a );
                    while b in posr do
                        b:= b-ej;
                        r:=r+1;
                    od;
                    q:= r-LinearCombination( TransposedMat( C )[j], a );
                    if q>0 and (not a+ej in posr ) then
                        Add( posr, a+ej );
                    fi;
                od;
            od;
            ind:= le+1;
            le:= Length( posr );
        od;

        return posr;
    end;


    # The following function is the so-called epsilon function.
    eps:= function( a, b, epm )
        local rk;

        rk:= Length( epm );
        return Product( [1..rk],i ->
                       Product( [1..rk], j ->
                               epm[i][j] ^ ( a[i]*b[j] ) ) );
    end;

    if type in [ "A", "D", "E" ] then

        # We are in the simply-laced case. Here we construct the root
        # system and the matrix of the epsilon function. Then we can
        # fill the multiplication table directly.

        C:= 2*IdentityMat( n );
        if type = "A" then
            for i in [1..n-1] do
                C[i][i+1]:= -1;
                C[i+1][i]:= -1;
            od;
        elif type = "D" then
            if n < 4 then
                Error("<n> must be >= 4");
            fi;
            for i in [1..n-2] do
                C[i][i+1]:= -1;
                C[i+1][i]:= -1;
            od;
            C[n-2][n]:=-1;
            C[n][n-2]:= -1;
        else

            C:= [
                 [ 2, 0, -1, 0, 0, 0, 0, 0 ], [ 0, 2, 0, -1, 0, 0, 0, 0 ],
                 [ -1, 0, 2, -1, 0, 0, 0, 0 ], [ 0, -1, -1, 2, -1, 0, 0, 0 ],
                 [ 0, 0, 0, -1, 2, -1, 0, 0 ], [ 0, 0, 0, 0, -1, 2, -1, 0 ],
                 [ 0, 0, 0, 0, 0, -1, 2, -1 ], [ 0, 0, 0, 0, 0, 0, -1, 2 ] ];

            if n = 6 then
                C:= C{ [ 1 .. 6 ] }{ [ 1 .. 6 ] };
            elif n = 7 then
                C:= C{ [ 1 .. 7 ] }{ [ 1 .. 7 ] };
            elif n < 6 or 8 < n then
                Error( "<n> must be one of 6, 7, 8" );
            fi;
        fi;
        R:= CartanMatrixToPositiveRoots( C );


        # We conctruct `epsmat', which satisfies
        #                  /
        #                 |-1 if i=j,
        #  epsmat[i][j] = |-1 if i and j are connected, and i>j
        #                 | 1 if i and j are not connected or i<j.
        #                  \
        # (where `connected' means connected in the Dynkin diagram.

        epsmat:= [];
        for i in [ 1 .. n ] do
            epsmat[i]:= [];
            for j in [ 1 .. i-1 ] do
                epsmat[i][j]:= 1;
            od;
            epsmat[i][i]:= -1;
            for j in [ i+1 .. n ] do
                epsmat[i][j]:= (-1)^C[i][j];
            od;
        od;

        lenR:= Length( R );
        dim:= 2*lenR + n;

        posR:= List( R, r -> Zero(F)*r );

        # Initialize the s.c. table
        T:= EmptySCTable( dim, Zero(F), "antisymmetric" );

        lst:= [ 1 .. n ] + 2 * lenR;

        for i in [1..lenR] do
            for j in [i..lenR] do
                Rij:= R[i]+R[j];
                if Rij in R then
                    k:= Position(R,Rij);
                    e:= eps(R[i],R[j],epsmat)*One(F);
                    SetEntrySCTable( T, i, j, [ e, k ] );
                    SetEntrySCTable( T, i+lenR, j+lenR, [ -e, k+lenR ] );
                fi;
                if i = j and T[i][j+lenR] = [[],[]] then
                    # We form the product x_{\alpha_i}*x_{-\alpha_i}, which
                    # will be an element of the Cartan subalgebra.

                    inds:= Filtered( [1..n], x -> R[i][x] <> 0 );
                    T[i][j+lenR]:= [ lst{inds}, R[i]{inds}*One(F) ];
                    T[j+lenR][i]:= [ lst{inds}, -R[i]{inds}*One(F) ];
                fi;
            od;
        od;
        for i in [1..lenR] do
            for j in [1..lenR] do
                Rij:= R[i]-R[j];
                if Rij in R then
                    k:= Position(R,Rij);
                    SetEntrySCTable( T, i, j+lenR,
                            [-One(F)*eps(R[i],-R[j],epsmat),k] );
                elif -Rij in R then
                    k:= Position(R,-Rij);
                    SetEntrySCTable( T, i, j+lenR,
                            [One(F)*eps(R[i],-R[j],epsmat),k+lenR] );
                fi;
            od;
            for j in [1..n] do

                # We take care of the comutation relations of the form
                # [h_j,x_{\beta_i}]= < \beta_i, \alpha_j > x_{\beta_i}.
                cc:= LinearCombination( R[i], C[j] );
                if cc <> 0*cc then

                    posR[i][j]:= One(F)*cc;

                    T[2*lenR+j][i]:=[[i],[One(F)*cc]];
                    T[i][2*lenR+j]:=[[i],[-One(F)*cc]];
                    T[2*lenR+j][i+lenR]:=[[i+lenR],[-One(F)*cc]];
                    T[i+lenR][2*lenR+j]:=[[i+lenR],[One(F)*cc]];
                fi;
            od;
        od;

        L:= LieAlgebraByStructureConstants( F, T );

        # A Cartan subalgebra is spanned by the last 'n' basis elements.
        CSA:= [ dim-n+1 .. dim ];
        vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
        SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
        SetIsRestrictedLieAlgebra( L, Characteristic( F ) > 0 );

    elif type in [ "B", "C", "F", "G" ] then

        # Now we are in the non simply laced case. In each case we construct
        # a simply laced root system, which has a diagram automorphism.
        # We take an epsilon function which is invariant under the diagram
        # automorphism. Furthermore, the permutation `perm' will represent
        # the diagram aotomorphism as acting on the roots (so that
        # Permuted( r, perm ) is the result of applying the diagram
        # automorphism to the root r).

        if type = "B" then

            # In this case we construct D_{n+1}.
            if n <= 1 then
                Error( "<n> must be >= 2");
            fi;
            C:= 2*IdentityMat( n+1 );
            for i in [1..n-1] do
                C[i][i+1]:= -1;
                C[i+1][i]:= -1;
            od;
            C[n-1][n+1]:=-1;
            C[n+1][n-1]:= -1;
            R:= CartanMatrixToPositiveRoots( C );

            epsmat:= NullMat( n+1, n+1 ) + 1;
            for i in [ 1 .. n-1 ] do
                epsmat[i+1][i]:= -1;
                epsmat[i][i]:= -1;
            od;
            epsmat[n+1][n-1]:= -1;
            epsmat[n][n]:= -1;
            epsmat[n+1][n+1]:= -1;

            perm:= (n,n+1);
            d:= 2;

        elif type = "C" then

            # In this case we construct A_{2n-1}.
            if n < 2 then
                Error( "<n> must be >= 3");
            fi;
            C:= 2*IdentityMat( 2*n-1 );
            for i in [1..2*n-2] do
                C[i][i+1]:= -1;
                C[i+1][i]:= -1;
            od;
            R:= CartanMatrixToPositiveRoots( C );

            epsmat:= NullMat( 2*n-1, 2*n-1 ) + 1;
            for i in [ 1 .. n-1 ] do
                epsmat[i][i+1]:= -1;
                epsmat[i][i]:= -1;
            od;
            for i in [n..2*n-2] do
                epsmat[i+1][i]:= -1;
                epsmat[i][i]:= -1;
            od;
            epsmat[2*n-1][2*n-1]:= -1;

            perm:= ();
            for i in [1..n-1] do
                perm:= perm*(i,2*n-i);
            od;
            d:= 2;

        elif type = "F" then

            # In this case we construct E_6.
            if n <> 4 then
                Error( "<n> must be equal to 4");
            fi;

            C:= IdentityMat( 6 );
            C[1][3]:=-1; C[2][4]:=-1; C[3][4]:=-1; C[4][5]:=-1; C[5][6]:=-1;
            C:= C+TransposedMat( C );
            R:= CartanMatrixToPositiveRoots( C );

            epsmat:= NullMat( 6, 6 ) + 1;
            for i in [1..6] do epsmat[i][i]:= -1; od;
            epsmat[1][3]:=-1; epsmat[3][4]:=-1; epsmat[5][4]:=-1;
            epsmat[6][5]:=-1; epsmat[2][4]:=-1;

            perm:= (1,6)*(3,5);
            d:= 2;

        elif type = "G" then

            # In this case we conctruct D_4.
            if n <> 2 then
                Error( "<n> must be equal to 2");
            fi;

            C:= IdentityMat( 4 );
            C[1][2]:=-1; C[2][3]:=-1; C[2][4]:=-1;
            C:= C+TransposedMat( C );
            R:= CartanMatrixToPositiveRoots( C );

            epsmat:= NullMat( 4, 4 ) + 1;
            for i in [1..4] do epsmat[i][i]:= -1; od;
            epsmat[1][2]:=-1; epsmat[4][2]:=-1; epsmat[3][2]:=-1;

            perm:= (1,3,4);
            d:= 3;

        fi;

        # Now `roots' will be the list of positive roots of the resulting Lie
        # algebra. They are formed from the roots in `R' by applying the
        # diagram automorphism. If a r\in R is invariant under the
        # automorphism, then it is added to `roots' (and its prime is
        # the root itself). Otherwise we add \frac{1}{d}(r+\phi(r)+\cdots
        # + \phi^{d-1}(r)), where \phi is the diagram automorphism.
        # In this case the prime of the root are all \phi^i(r).

        if d = 2 then

            roots:= [ ];
            primes:= [ ];
            for r in R do
                r1:= Permuted( r, perm );
                if r = r1 then
                    Add( roots, r );
                    Add( primes, [ r ] );
                else
                    if not (r+r1)/2 in roots then
                        Add( roots, (r+r1)/2 );
                        Add( primes, [ r, r1 ] );
                    fi;
                fi;
            od;

            B:= Basis( VectorSpace( Rationals, roots{[1..n]} ),roots{[1..n]});
            cfs:= List( roots, x -> Coefficients( B, x ) );

        elif d = 3 then
            roots:= [ ];
            primes:= [ ];
            for r in R do
                r1:= Permuted( r, perm );
                if r = r1 then
                    Add( roots, r );
                    Add( primes, [ r ] );
                else
                    r2:= (r+r1+Permuted(r1,perm))/3;
                    if not r2 in roots then
                        Add( roots, r2 );
                        Add( primes, [ r, r1, Permuted( r1, perm ) ] );
                    fi;
                fi;
            od;

            B:= Basis( VectorSpace( Rationals, roots{[1..n]} ),roots{[1..n]});
            cfs:= List( roots, x -> Coefficients( B, x ) );
        fi;

        # `shorts' will be a list of indices indicating where the
        # short simple roots are. The coefficients on those places
        # in `cfs' need to be divided by `d'.

        shorts:= Filtered( [1..n], ii -> Length( primes[ii] ) > 1 );
        for i in [1..Length(cfs)] do
            for j in shorts do
                cfs[i][j]:= cfs[i][j]/d;
            od;
        od;

        Append( R, -R );
        lenR:= Length( roots );
        dim:= 2*lenR + n;

        posR:= List( [1..lenR], ii -> List( [1..n], jj -> Zero( F ) ) );

        # Initialize the s.c. table
        T:= EmptySCTable( dim, Zero(F), "antisymmetric" );

        lst:= [ 1 .. n ] + 2 * lenR;

        for i in [1..lenR] do
            for j in [i..lenR] do
                Rij:= roots[i]+roots[j];
                if Rij in roots then

                    # We look for `r' in `primes[i]' and `r1' in `primes[j]'
                    # such that `r+r1' lies in `R'.
                    found:= false;
                    for k in [1..Length(primes[i])] do
                        if found then break; fi;
                        r:= primes[i][k];
                        for l in [1..Length(primes[j])] do
                            r1:= primes[j][l];
                            if r+r1 in R then
                                found := true; break;
                            fi;
                        od;
                    od;

                    # `q' will be the maximal integer such that `roots[i]-
                    # roots[j]' is a root.

                    k:= Position( roots, Rij );
                    q:=0; a:= roots[i] - roots[j];
                    while a in roots or -a in roots do
                        q:=q+1;
                        a:= a-roots[j];
                    od;

                    e:= eps(r,r1,epsmat)*(q+1)*One(F);
                    SetEntrySCTable( T, i, j, [ e, k ] );
                    SetEntrySCTable( T, i+lenR, j+lenR, [ -e, k+lenR ] );
                fi;
                if i = j and T[i][j+lenR] = [[],[]] then
                    # We form the product x_{\alpha_i}*x_{-\alpha_i}, which
                    # will be an element of the Cartan subalgebra.

                    inds:= Filtered( [1..n], x -> cfs[i][x] <> 0 );
                    if Length( primes[i] ) = 1 then
                        T[i][j+lenR]:= [ lst{inds}, cfs[i]{inds}*One(F) ];
                        T[j+lenR][i]:= [ lst{inds}, -cfs[i]{inds}*One(F) ];
                    else
                        T[i][j+lenR]:= [ lst{inds}, cfs[i]{inds}*d*One(F) ];
                        T[j+lenR][i]:= [ lst{inds}, -cfs[i]{inds}*d*One(F) ];
                    fi;
                fi;
            od;
        od;
        for i in [1..lenR] do
            for j in [1..lenR] do
                Rij:= roots[i]-roots[j];
                if Rij in roots then

                    found:= false;
                    for k in [1..Length(primes[i])] do
                        if found then break; fi;
                        r:= primes[i][k];
                        for l in [1..Length(primes[j])] do
                            r1:= primes[j][l];
                            if r-r1 in R then
                                found := true; break;
                            fi;
                        od;
                    od;

                    k:= Position( roots, Rij );
                    q:=0; a:= roots[i] + roots[j];
                    while a in roots or -a in roots do
                        q:=q+1;
                        a:= a+roots[j];
                    od;

                    SetEntrySCTable( T, i, j+lenR,
                            [-One(F)*(q+1)*eps(r,-r1,epsmat),k] );

                elif -Rij in roots then

                    found:= false;
                    for k in [1..Length(primes[i])] do
                        if found then break; fi;
                        r:= primes[i][k];
                        for l in [1..Length(primes[j])] do
                            r1:= primes[j][l];
                            if r-r1 in R then
                                found := true; break;
                            fi;
                        od;
                    od;

                    k:= Position( roots, -Rij );
                    q:=0; a:= roots[i] + roots[j];
                    while a in roots or -a in roots do
                        q:=q+1;
                        a:= a+roots[j];
                    od;
                    SetEntrySCTable( T, i, j+lenR,
                            [One(F)*(q+1)*eps(r,-r1,epsmat),k+lenR] );
                fi;
            od;
            for j in [1..n] do

                # Now we take care of the relations [h,x_{\beta}]....

                cc:= LinearCombination( roots[i], C[j] );
                if Length( primes[j] ) > 1 then
                    # i.e., `roots[j]' is "short".
                    cc:= d*cc;
                fi;

                if cc <> 0*cc then

                    posR[i][j]:= One(F)*cc;

                    T[2*lenR+j][i]:=[[i],[One(F)*cc]];
                    T[i][2*lenR+j]:=[[i],[-One(F)*cc]];
                    T[2*lenR+j][i+lenR]:=[[i+lenR],[-One(F)*cc]];
                    T[i+lenR][2*lenR+j]:=[[i+lenR],[One(F)*cc]];
                fi;
            od;
        od;

        L:= LieAlgebraByStructureConstants( F, T );

        # A Cartan subalgebra is spanned by the last 'n' basis elements.
        CSA:= [ dim-n+1 .. dim ];
        vectors:= BasisVectors( CanonicalBasis( L ) ){ CSA };
        SetCartanSubalgebra( L, SubalgebraNC( L, vectors, "basis" ) );
        SetIsRestrictedLieAlgebra( L, Characteristic( F ) > 0 );

    fi;

    R:= Objectify( NewType( NewFamily( "RootSystemFam", IsObject ),
                IsAttributeStoringRep and IsRootSystemFromLieAlgebra ),
                rec() );
    SetUnderlyingLieAlgebra( R, L );
    SetPositiveRoots( R, posR );
    SetNegativeRoots( R, -posR );
    SetSimpleSystem( R, posR{[1..n]} );
    SetCanonicalGenerators( R, [ CanonicalBasis( L ){[1..n]},
                                 CanonicalBasis( L ){[lenR+1..lenR+n]},
                                 vectors ] );
    SetPositiveRootVectors( R, CanonicalBasis(L){[1..lenR]} );
    SetNegativeRootVectors( R, CanonicalBasis(L){[lenR+1..2*lenR]} );
    SetChevalleyBasis( L, [ PositiveRootVectors( R ),
                            NegativeRootVectors( R ),
                            vectors ] );

    if not ( Characteristic( F ) in [ 2, 3 ] ) then

        C:= 2*IdentityMat( n );
        for i in [1..n] do
            for j in [1..n] do
                if i <> j then
                    q:= 0;
                    r:= posR[i]+posR[j];
                    while r in posR do
                        q:=q+1;
                        r:= r+posR[j];
                    od;
                    C[i][j]:= -q;
                fi;
            od;
        od;

        SetCartanMatrix( R, C );

        SetSemiSimpleType( L, Concatenation( type, String( n ) ) );
    fi;

    SetRootSystem( L, R );

    if Characteristic( F ) = 0 then
       SetIsSimpleAlgebra( L, true );
    fi;

    return L;


end );


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
BindGlobal( "SimpleLieAlgebraTypeW", function( n, F )

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
          ex:= ShallowCopy( x1[1]+x2[1] );
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
          ex:= ShallowCopy( x1[1]+x2[1] );
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

end );


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
BindGlobal( "SimpleLieAlgebraTypeS", function( n, F )

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

    L:= LieDerivedSubalgebra( Subalgebra( WW[1], bas, "basis" ) );
    SetIsRestrictedLieAlgebra( L, ForAll( n, x -> x=1 ) );
    return L;

end );


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
BindGlobal( "SimpleLieAlgebraTypeH", function( n, F )

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
          sp:= MutableBasis( F, [ cf ] );
        fi;
      fi;
    od;

    bas:= BasisVectors( sp );
    bas:= List( bas, x -> LinearCombination( Basis(WW[1]), x ) );
    L:= Subalgebra( WW[1], bas, "basis" );
    SetIsRestrictedLieAlgebra( L, ForAll( n, x -> x=1 ) );
    return L;

end );


##############################################################################
##
#F  SimpleLieAlgebraTypeK( <n>, <F> )
##
##  The kontact algebra has the same underlying vector space as a
##  particular kind of polynomial algebra. On this space a Lie bracket
##  is defined. We refer to the book cited in the comments to the function
##  'SimpleLieAlgebraTypeW' for the details.
##
BindGlobal( "SimpleLieAlgebraTypeK", function( n, F )

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

end );



##############################################################################
##
#F  SimpleLieAlgebraTypeM( <n>, <F> )
##
##  The Melikyan Lie algebra is constructed.
##
##  The code is due to Erik Postma.
##
##  The Melikyan Lie algebra is most conveniently constructed by
##  viewing it as the direct sum of a Witt type Lie algebra and two
##  of its modules. This is the presentation described by
##  M.I. Kuznetsov, The Melikyan algebras as Lie algebras of the
##  type G2, Comm. Algebra 19 (1991).
##
##  The Melikyan Lie algebra is parametrized by two positive
##  integers, n1 and n2, and can only be defined over fields of
##  characteristic 5. It can be decomposed into a 2*5^(n1 + n2)-dimensional
##  subalgebra isomorphic to W(n1, n2), having a basis of monomials
##  X1^i1 X2^i2 dXk where 0 <= i1 < 5^n1, 0 <= i2 < 5^n2, k in {1, 2}; a
##  5^(n1 + n2)-dimensional module of this subalgebra which we call O,
##  having a basis of elements we call X1^i1 X2^i2 (where i1 and i2 are
##  within the same boundaries); and a 2*5^(n1 + n2)-dimensional
##  module which we call Wtilde, having a basis of elements we
##  call X1^i1 X2^i2 dXk^tilde (again with i1 and i2 within the same
##  boundaries, and with k in {1, 2}).
##
##  The multiplication is described in the above paper and in the code
##  below. We use lists of symbolic descriptions for the basis
##  elements: [i1, i2] for X1^i1 X2^i2 and [[i1, i2], k] for either
##  X1^i1 X2^i2 dXk or X1^i1 X2^i2 dXk^tilde. All valid such
##  symbolic descriptions can be found in two lists, OBasis and
##  WBasis, respectively. In the basis of the full algebra, we first
##  put the elements of W as ordered in WBasis, then the elements of O
##  as ordered in OBasis, and finally the elements of Wtilde, again as
##  ordered in WBasis. Throughout the function below, we describe
##  basis elements using either these symbolic descriptions, or the
##  positions in this basis.

BindGlobal( "SimpleLieAlgebraTypeM", function (n, F)
    local   n1,  n2,     # The parameters.
            one, zero,   # Shortcuts to the field elements.
            dimO,  dimW, # Dimensions of the O and W spaces.
            OBasis,      # A representation of a basis for O.
            posO,        # Function to find the position of a given
                         #   OBasis element in the basis.
            OProduct,    # The regular product of two elements of OBasis.
            WBasis,      # A representation of a basis for W.
            div,         # The divergence function for elements of WBasis.
            posW,        # Function to find the position of a WBasis
                         #   element in the basis.
            WOProduct,   # The action of W on O.
            WProduct,    # The regular product of two elements of WBasis.
            WBracket,    # The commutator of two elements of WBasis
                         #   w.r.t. WProduct.
            degrees,     # The list of degrees of different components.
            GradingFunction, # The function giving the grading components.
            tildify, clean, # Utility functions.
            table,  i,  w1,  j,  w2, result,  term,  prod,  x2,  x1, d;
                         # Temporary results and counters.
    if not (IsList (n) and Length (n) = 2 and n [1] > 0 and n [2] > 0)
       then
        Error ("<n> must be a list of two positive integers");
    fi;

    if Characteristic (F) <> 5 then
        Error ("<F> must be a field of characteristic 5");
    fi;

    n1 := n [1];
    n2 := n [2];
    dimO := 5^(n1 + n2);
    dimW := 2*dimO;

    one := One (F);
    zero := Zero (F);

    # The element [a, b] of OBasis represents the element
    #    X1^a X2^b / (a! b!)
    # of the truncated polynomial ring.
    OBasis := Cartesian ([0 .. 5^n1 - 1], [0 .. 5^n2 - 1]);

    # The position of an OBasis element in the basis.
    posO := function (o)
        return o [2] + 5^n2 * o [1] + 1;
    end;

    # Given two OBasis elements x1 and x2, returns a list with a
    # coefficient coeff and the position pos of a basis element, such
    # that
    #    x1 * x2 = coeff * OBasis [pos]
    OProduct := function (x1, x2)
        local pow;
        pow := ShallowCopy (x1 + x2);
        if pow [1] < 5^n1 and pow [2] < 5^n2 then
            return [Binomial (pow [1], x1 [1]) *
                    (Binomial (pow [2], x1 [2]) * one),
                    posO (pow)];
        else
            return [zero, 1];
        fi;
    end;

    # The element [[a, b], c] of WBasis represents the element
    #    O dXc
    # where O is the element of OBasis represented by [a, b].
    WBasis := Cartesian (OBasis, [1, 2]);

    # The divergence: f dX1 + g dX2 -> dX1 (f) + dX2 (g), maps WBasis
    # elements to OBasis elements. Note: if the result is 0, we return
    # that instead of the OBasis element.
    div := function (abc)
        local ab, pos;
        if abc [1] [abc [2]] = 0 then
            return 0;
        fi;
        pos := abc [2];
        ab := ShallowCopy (abc [1]);
        ab [pos] := ab [pos] - 1;
        return ab;
    end;

    # The position of the WBasis element [OBasis (o), c] in the basis,
    # where o is the number of an OBasis element.
    posW := function (o, c)
        return 2 * o + c - 2;
    end;

    # Given a WBasis element [[a1, b1], c1] and an OBasis element [a2,
    # b2], representing the usual monomials, this function computes
    #    p = X1^a1 X2^a2 (dXc1 X1^a2 X2^b2),
    # and returns a list [pos, coeff] with the position in OBasis of
    # the basis element this is a multiple of, and its coefficient; so
    # that
    #    p = coeff * OBasis [pos].
    WOProduct := function (w1, x2)
        local pow;
        if x2 [w1 [2]] > 0 then
            pow := ShallowCopy (x2);
            pow [w1 [2]] := pow [w1 [2]] - 1;
            return OProduct (w1 [1], pow);
        else
            return [zero, 1];
        fi;
    end;

    # Given two WBasis elements [[a1, b1], c1] and [[a2, b2], c2],
    # representing the usual monomials, this
    # function computes
    #    p = X1^a1 X2^a2 (dXc1 (X1^a2 X2^b2)) dXc2,
    # and returns a list [pos, coeff] with the position in WBasis of
    # the basis element this is a multiple of, and its coefficient; so
    # that
    #    p = coeff * WBasis [pos].
    WProduct := function (x1, x2)
        local prod;
        prod := WOProduct (x1, x2 [1]);
        if prod [1] <> zero then
            return [prod [1], posW (prod [2], x2 [2])];
        else
            return [zero, 1];
        fi;
    end;

    # The bracket on W is defined as mapping x1, x2 to their
    # commutator, where the multiplication is as above. This function
    # returns a list ls of, alternatingly, coefficients and positions,
    # such that the bracket of x1 and x2 is equal to
    #   ls [1] * WBasis [ls [2]] + ls [3] * WBasis [ls [4]].
    # However, if any coefficient is 0, the corresponding list
    # elements are omitted. So the list returned has length 4, 2 or 0.
    WBracket := function (x1, x2)
        local result, prod;
        prod := WProduct (x1, x2);
        if prod [1] <> zero then
            result := prod;
        else
            result := [];
        fi;
        prod := WProduct (x2, x1);
        if prod [1] <> zero then
            Append (result, [- prod [1], prod [2]]);
        fi;
        return result;
    end;

    # The order of the basis elements is: first the basis elements of
    # W, then of O, then of Wtilde. Definitions of W, Wtilde and O can
    # be found in H. Strade, Simple Lie Algebras over Fields of
    # Positive Characteristic, Walter de Gruyter - Berlin/New York 2004.
    # This is the realization found in M.I. Kuznetsov, The Melikian
    # algebras as Lie algebras of the type G2, Comm. Algebra 19
    # (1991), 1281-1312.

    # tildify adds cst to each even position in ls. It is useful for
    # mapping a result of WBracket from W to Wtilde, or an OBasis
    # element to the correct position in the full basis.
    tildify := function (ls, cst)
        local i;
        i := 2;
        while IsBound (ls [i]) do
            ls [i] := ls [i] + cst;
            i := i + 2;
        od;
    end;

    # clean is a function that 'cleans' a list before submission to
    # SetEntrySCTable. That is, if any positions are the same, the
    # coefficients are added.
    clean := function (ls)
        local ps, i;
        ps := rec ();
        i := 2;
        while IsBound (ls [i]) do
            if IsBound (ps.(ls [i])) then
                ls [ps.(ls [i]) - 1] := ls [ps.(ls [i]) - 1] + ls [i - 1];
                Unbind (ls [i - 1]);
                Unbind (ls [i]);
            else
                ps.(ls [i]) := i;
            fi;
            i := i + 2;
        od;
        return Compacted (ls);
    end;

    table := EmptySCTable (dimO + 2 * dimW, Zero (F), "antisymmetric");

    for i in [1 .. dimW] do
        w1 := WBasis [i];
        for j in [1 .. dimW] do
            w2 := WBasis [j];

            if i < j then
                # Compute the product for w1 and w2 in W.
                # This is simply [w1, w2].
                SetEntrySCTable (table, i, j, clean (WBracket (w1, w2)));


                # Compute the product for w1 and w2 in WTilde.
                # This is f1g2 - f2g1 if w1 = f1d1 + f2d2, w2 = g1d1 +
                # g2d2.
                if w1 [2] <> w2 [2] then
                    prod := OProduct (w1 [1], w2 [1]);
                    if prod [1] <> zero then
                        SetEntrySCTable (table, i + dimW + dimO,
                                j + dimW + dimO,
                                [(3 - 2 * w1 [2]) * # This is the coefficient
                                                    # plus or minus one.
                                 prod [1], prod [2] + dimW]);
                    fi;
                fi;
            fi;

            # Compute the product for w1 in W, w2 in WTilde.
            # This is defined as [w1, w2]^tilde + 2 div(w1) w2^tilde
            # [w1, w2]^tilde:
            result := WBracket (w1, w2);
            tildify (result, dimW + dimO);
            # 2 div(w1) w2^tilde:
            d := div (w1);
            if d <> 0 then
                term := OProduct (d, w2 [1]);
                if term [1] <> zero then
                    Append (result, [2 * term [1],
                            posW (term [2], w2 [2]) + dimW + dimO]);
                fi;
            fi;
            SetEntrySCTable (table, i, j + dimW + dimO, clean (result));
        od;

        for j in [1 .. dimO] do
            x2 := OBasis [j];

            # Compute the product for w1 in W, x2 in O.
            # This is w1 (x2) - 2 div (w1) x2.
            # w1 (x2):
            result := WOProduct (w1, x2);
            # - 2 div (w1) x2:
            d := div (w1);
            if d <> 0 then
                term := OProduct (d, x2);
                if term [1] <> zero then
                    Append (result, [-2 * term [1], term [2]]);
                fi;
            fi;
            tildify (result, dimW);
            SetEntrySCTable (table, i, j + dimW, clean (result));

            # Compute the product for w1 in Wtilde, x2 in O.
            # This is - x2 w1^un-tilde.
            # We put it in the table as the product of x2 and w1, so
            # that we don't have to bother with the minus sign.
            result := OProduct (x2, w1 [1]);
            SetEntrySCTable (table, j + dimW, i + dimW + dimO,
                    [result [1], posW (result [2], w1 [2])]);
        od;
    od;

    for i in [1 .. dimO] do
        x1 := OBasis [i];
        for j in [i + 1 .. dimO] do
            x2 := OBasis [j];
            # Compute the product for x1 and x2 in O.
            # This is 2 (x2 dX2(x1) - x1 dX2(x2))dX1^tilde + 2 (x1
            # dX1(x2) - x2 dX1(x1)) dX2^tilde.
            # 2 x2 dX2(x1) dX1:
            result := WProduct ([x2, 2], [x1, 1]);
            result [1] := 2 * result [1];
            # - 2 x1 dX2(x2) dX1:
            term := WProduct ([x1, 2], [x2, 1]);
            Append (result, [- 2 * term [1], term [2]]);
            # 2 x1 dX1(x2) dX2:
            term := WProduct ([x1, 1], [x2, 2]);
            Append (result, [2 * term [1], term [2]]);
            # - 2 x2 dX1(x1) dX2:
            term := WProduct ([x2, 1], [x1, 2]);
            Append (result, [- 2 * term [1], term [2]]);

            tildify (result, dimW + dimO);

            SetEntrySCTable (table, i + dimW, j + dimW,
                    clean (result));
        od;
    od;

    result := LieAlgebraByStructureConstants (F, table);

    SetIsRestrictedLieAlgebra (result, n1 = 1 and n2 = 1);

    degrees := Concatenation (List (WBasis, lst ->
                       lst [1] * [[2, 1], [1, 2]] +
                       \[\]([[-2, -1], [-1, -2]], lst [2])),
                       List (OBasis, lst ->
                             lst * [[2, 1], [1, 2]] + [-1, -1]),
                       List (WBasis, lst ->
                             lst [1] * [[2, 1], [1, 2]] +
                             \[\]([[-1, 0], [0, -1]], lst [2])));
    GradingFunction := d -> Subspace (result,
                               Basis(result) {Positions (degrees, d)});
    SetGrading (result, rec(
            source :=
            FreeLeftModule(Integers, [[1, 0], [0, 1]], "basis"),
            hom_components := GradingFunction,
            non_zero_hom_components := Set (degrees)));

#    GradingFunction := function (d)
#        local degsum, r, oposns;
#        r := d[1] + d[2] mod 3;
#        if r = 0 then
#
#        degsum := (d [1] + d [2] - r) / 3 + 1;
#        oposns := List ([Maximum (0, degsum - 5^n2 + 1) ..
#                         Minimum (degsum, 5^n1 - 1)],
#                        i -> posO ([i, degsum - i]));
#        if r = 0 then
#            return SubspaceNC (result,
#                           Basis (result) {Concatenation (
#                                   List (oposns, p -> posW (p, 1)),
#                                   List (oposns, p -> posW (p, 2)))},
#                           "basis");
#        elif r = 1 then
#            return SubspaceNC (result,
#                           Basis (result) {oposns + dimW},
#                           "basis");
#        else # r = 2
#            return SubspaceNC (result,
#                           Basis (result) {3 * dimO + Concatenation (
#                                   List (oposns, p -> posW (p, 1)),
#                                   List (oposns, p -> posW (p, 2)))},
#                           "basis");
#        fi;
#    end;
#    SetGrading (result,
#            rec (min_degree := -3,
#                max_degree := 3 * (5^n1 + 5^n2) - 7,
#                source := Integers,
#                 hom_components := GradingFunction));

    return result;
end );



##############################################################################
##
#F  SimpleLieAlgebra( <type>, <n>, <F> )
##

InstallGlobalFunction( SimpleLieAlgebra, function( type, n, F )
    local A;

    # Check the arguments.
    if not ( IsString( type ) and ( IsInt( n ) or IsList( n ) ) and
      IsRing( F ) ) then
      Error( "<type> must be a string, <n> an integer, <F> a ring" );
    fi;

    if type in [ "A","B","C","D","E","F","G" ] then
      A := SimpleLieAlgebraTypeA_G( type, n, F );
    elif type = "W" then
      A := SimpleLieAlgebraTypeW( n, F )[1];
    elif type = "S" then
      A := SimpleLieAlgebraTypeS( n, F );
    elif type = "H" then
      A := SimpleLieAlgebraTypeH( n, F );
    elif type = "K" then
      A := SimpleLieAlgebraTypeK( n, F );
    elif type = "M" then
      A := SimpleLieAlgebraTypeM( n, F );
    else
       Error( "<type> must be one of \"A\", \"B\", \"C\", \"D\", \"E\", ",
             "\"F\", \"G\", \"H\", \"K\", \"M\", \"S\", \"W\" " );
    fi;

    # store the pth power images in the family (LB)
    if IsRestrictedLieAlgebra(A) then
        FamilyObj(Representative(A))!.pMapping := PthPowerImages(Basis(A));
    fi;
    return A;
end );
