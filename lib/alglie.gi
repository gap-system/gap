#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, and Willem de Graaf.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for Lie algebras.
##


#############################################################################
##
#M  LieUpperCentralSeries( <L> )  . . . . . . . . . . for a Lie algebra
##
InstallMethod( LieUpperCentralSeries,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local   S,          # upper central series of <L>, result
            C,          # Lie centre
            hom;        # homomorphisms of <L> to `<L>/<C>'

    S := [ TrivialSubalgebra( L ) ];
    C := LieCentre( L );
    while C <> S[ Length(S) ]  do

      # Replace `L' by `L / C', compute its centre, and get the preimage
      # under the natural homomorphism.
      Add( S, C );
      hom:= NaturalHomomorphismByIdeal( L, C );
      C:= PreImages( hom, LieCentre( Range( hom ) ) );
#T we would like to get ideals!
#T is it possible to teach the hom. that the preimage of an ideal is an ideal?

    od;

    # Return the series when it becomes stable.
    return Reversed( S );
    end );


#############################################################################
##
#M  LieLowerCentralSeries( <L> )  . . . . . . . . . . for a Lie algebra
##
InstallMethod( LieLowerCentralSeries,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local   S,          # lower central series of <L>, result
            C;          # commutator subalgebras

    # Compute the series by repeated calling of `ProductSpace'.
    S := [ L ];
    C := LieDerivedSubalgebra( L );
    while C <> S[ Length(S) ]  do
      Add( S, C );
      C:= ProductSpace( L, C );
    od;

    # Return the series when it becomes stable.
    return S;
    end );



#############################################################################
##
#M  LieDerivedSubalgebra( <L> )
##
##  is the (Lie) derived subalgebra of the Lie algebra <L>.
##  This is the ideal/algebra/subspace (equivalent in this case)
##  generated/spanned by all products $uv$
##  where $u$ and $v$ range over a basis of <L>.
##
InstallMethod( LieDerivedSubalgebra,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    L -> ProductSpace( L, L ) );


#############################################################################
##
#M  LieDerivedSeries( <L> )
##
InstallMethod( LieDerivedSeries,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function ( L )

    local   S,          # (Lie) derived series of <L>, result
            D;          # (Lie) derived subalgebras

    # Compute the series by repeated calling of `LieDerivedSubalgebra'.
    S := [ L ];
    D := LieDerivedSubalgebra( L );
    while D <> S[ Length(S) ]  do
      Add( S, D );
      D:= LieDerivedSubalgebra( D );
    od;

    # Return the series when it becomes stable.
    return S;
    end );


#############################################################################
##
#M  IsLieSolvable( <L> )  . . . . . . . . . . . . . . . for a Lie algebra
##
InstallMethod( IsLieSolvable,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local D;

    D:= LieDerivedSeries( L );
    return Dimension( D[ Length( D ) ] ) = 0;
    end );

InstallTrueMethod( IsLieSolvable, IsLieNilpotent );


#############################################################################
##
#M  IsLieNilpotent( <L> ) . . . . . . . . . . . . . . . for a Lie algebra
##
InstallMethod( IsLieNilpotent,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local D;

    D:= LieLowerCentralSeries( L );
    return Dimension( D[ Length( D ) ] ) = 0;
    end );


InstallTrueMethod( IsLieNilpotent, IsLieAbelian );


#############################################################################
##
#M  IsLieAbelian( <L> )  . . . . . . . . . . . . . . for a Lie algebra
##
##  It is of course sufficient to check products of algebra generators,
##  no basis and structure constants of <L> are needed.
##  But if we have already a structure constants table we use it.
##
InstallMethod( IsLieAbelian,
    "for a Lie algebra with known basis",
    true,
    [ IsAlgebra and IsLieAlgebra and HasBasis ], 0,
    function( L )

    local B,      # basis of `L'
          T,      # structure constants table w.r.t. `B'
          i,      # loop variable
          j;      # loop variable

    B:= Basis( L );
    if not HasStructureConstantsTable( B ) then
      TryNextMethod();
    fi;

    T:= StructureConstantsTable( B );
    for i in T{ [ 1 .. Length( T ) - 2 ] } do
      for j in i do
        if not IsEmpty( j[1] ) then
          return false;
        fi;
      od;
    od;
    return true;
    end );

InstallMethod( IsLieAbelian,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local i,      # loop variable
          j,      # loop variable
          zero,   # zero of `L'
          gens;   # algebra generators of `L'

    zero:= Zero( L );
    gens:= GeneratorsOfAlgebra( L );
    for i in [ 1 .. Length( gens ) ] do
      for j in [ 1 .. i-1 ] do
        if gens[i] * gens[j] <> zero then
          return false;
        fi;
      od;
    od;

    # The algebra multiplication is trivial, and the algebra does
    # not know about a basis.
    # Here we know at least that the algebra generators are space
    # generators.
    if not HasGeneratorsOfLeftModule( L ) then
      SetGeneratorsOfLeftModule( L, gens );
    fi;

    # Return the result.
    return true;
    end );

InstallTrueMethod( IsLieAbelian, IsAlgebra and IsZeroMultiplicationRing );


##############################################################################
##
#M  LieCentre( <L> )  . . . . . . . . . . . . . . . . . . .  for a Lie algebra
##
##  We solve the system
##  $\sum_{i=1}^n a_i c_{ijk} = 0$ for $1 \leq j, k \leq n$
##  (instead of $\sum_{i=1}^n a_i ( c_{ijk} - c_{jik} ) = 0$).
##
##  Additionally we know that the centre of a Lie algebra is an ideal.
##
InstallMethod( LieCentre,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( A )

    local   R,          # left acting domain of `A'
            C,          # Lie centre of `A', result
            B,          # a basis of `A'
            T,          # structure constants table w.r. to `B'
            n,          # dimension of `A'
            M,          # matrix of the equation system
            zerovector, #
            i, j,       # loop over ...
            row;        # one row of `M'

    R:= LeftActingDomain( A );

    if Characteristic( R ) <> 2 and HasCentre( A ) then

      C:= Centre( A );
#T change it to an ideal!

    else

      # Catch the trivial case.
      n:= Dimension( A );
      if n = 0 then
        return A;
      fi;

      # Construct the equation system.
      B:= Basis( A );
      T:= StructureConstantsTable( B );
      M:= [];
      zerovector:= [ 1 .. n*n ] * Zero( R );
      for i in [ 1 .. n ] do
        row:= ShallowCopy( zerovector );
        for j in [ 1 .. n ] do
          if IsBound( T[i][j] ) then
            row{ (j-1)*n + T[i][j][1] }:= T[i][j][2];
          fi;
        od;
        M[i]:= row;
      od;

      # Solve the equation system.
      M:= NullspaceMat( M );

      # Get the generators from the coefficient vectors.
      M:= List( M, x -> LinearCombination( B, x ) );

      # Construct the Lie centre.
      C:= IdealNC( A, M, "basis" );

    fi;

    # Return the Lie centre.
    return C;
    end );


##############################################################################
##
#M  LieCentralizer( <A>, <S> )  . . . . . for a Lie algebra and a vector space
##
##  Let $(b_1, \ldots, b_n)$ be a basis of <A>, and $(s_1, \ldots, s_m)$
##  be a basis of <S>, with $s_j = \sum_{l=1}^m v_{jl} b_l$.
##  The structure constants of <A> are $c_{ijk}$ with
##  $b_i b_j = \sum_{k=1}^n c_{ijk} b_k$.
##  Then we compute a basis of the solution space of the system
##  $\sum_{i=1}^n a_i \sum_{l=1}^m v_{jl} c_{ilk} = 0$ for
##  $1 \leq j \leq m$ and $1 \leq k \leq n$.
##
##  (left null space of an $n \times (nm)$ matrix)
##
InstallMethod( LieCentralizer,
    "for an abelian Lie algebra and a vector space",
    IsIdenticalObj,
    [ IsAlgebra and IsLieAlgebra and IsLieAbelian,
      IsVectorSpace ], 0,
    function( A, S )

    if IsSubset( A, S ) then
      return A;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( LieCentralizer,
    "for a Lie algebra and a vector space",
    IsIdenticalObj,
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ], 0,
    function( A, S )

    local R,           # left acting domain of `A'
          B,           # basis of `A'
          T,           # structure constants table w. r. to `B'
          n,           # dimension of `A'
          m,           # dimension of `S'
          M,           # matrix of the equation system
          v,           # coefficients of basis vectors of `S' w.r. to `B'
          zerovector,  # initialize one row of `M'
          row,         # one row of `M'
          i, j, k, l,  # loop variables
          cil,         #
          offset,
          vjl,
          pos;

    # catch trivial case
    if Dimension(S) = 0 then
       return A;
    fi;

    R:= LeftActingDomain( A );
    B:= Basis( A );
    T:= StructureConstantsTable( B );
    n:= Dimension( A );
    m:= Dimension( S );
    M:= [];
    v:= List( BasisVectors( Basis( S ) ),
                            x -> Coefficients( B, x ) );

    zerovector:= [ 1 .. n*m ] * Zero( R );

    # Column $(j-1)*n + k$ contains in row $i$ the value
    # $\sum_{l=1}^m v_{jl} c_{ilk}$

    for i in [ 1 .. n ] do
      row:= ShallowCopy( zerovector );
      for l in [ 1 .. n ] do
        cil:= T[i][l];
        for j in [ 1 .. m ] do
          offset := (j-1)*n;
          vjl    := v[j][l];
          for k in [ 1 .. Length( cil[1] ) ] do
            pos:= cil[1][k] + offset;
            row[ pos ]:= row[ pos ] + vjl * cil[2][k];
          od;
        od;
      od;
      Add( M, row );
    od;

    # Solve the equation system.
    M:= NullspaceMat( M );

    # Construct the generators from the coefficient vectors.
    M:= List( M, x -> LinearCombination( B, x ) );

    # Return the subalgebra.

    return SubalgebraNC( A, M, "basis" );

    end );


##############################################################################
##
#M  LieNormalizer( <L>, <U> ) . . . . . . for a Lie algebra and a vector space
##
##  If $(x_1, \ldots, x_n)$ is a basis of $L$ and $(u_1, \ldots, u_s)$ is
##  a basis of $U$, then $x = \sum_{i=1}^n a_i x_i$ is an element of $N_L(U)$
##  iff $[x,u_j] = \sum_{k=1}^s b_{j,k} u_k$ for $j = 1, \ldots, s$.
##  This leads to a set of $n s$ equations for the $n + s^2$ unknowns $a_i$
##  and $b_{jk}$.
##  If $u_k= \sum_{l=1}^n v_{kl} x_l$, then these equations can be written as
##  $\sum_{i=1}^n (\sum_{j=1}^n v_{lj} c_{ijk} a_i -
##   \sum_{i=1}^s v_{ik} b_{li} = 0$,
##  for $1 \leq k \leq n$ and $1 \leq j \leq s$,
##  where the $c_{ilp}$ are the structure constants of $L$.
##  From the solution we only need the "normalizer part" (i.e.,
##  the $a_i$ part).
##
InstallMethod( LieNormalizer,
    "for a Lie algebra and a vector space",
    IsIdenticalObj,
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ], 0,
    function( L, U )

    local R,          # left acting domain of `L'
          B,          # a basis of `L'
          T,          # the structure constants table of `L' w.r.t. `B'
          n,          # the dimension of `L'
          s,          # the dimension of `U'
          A,          # the matrix of the equation system
          i, j, k, l, # loop variables
          v,          # the coefficients of the basis of `U' wrt `B'
          cij,
          bas,
          b,
          pos;

    # catch trivial case
    if Dimension(U) = 0 then
       return L;
    fi;

    # We need not work if `U' knows to be an ideal in its parent `L'.
    if HasParent( U ) and IsIdenticalObj( L, Parent( U ) )
       and HasIsLeftIdealInParent( U ) and IsLeftIdealInParent( U ) then
      return L;
    fi;

    R:= LeftActingDomain( L );
    B:= Basis( L );
    T:= StructureConstantsTable( B );
    n:= Dimension( L );
    s:= Dimension( U );

    if s = 0 or n = 0 then
      return L;
    fi;

    v:= List( BasisVectors( Basis( U ) ),
              x -> Coefficients( B, x ) );

    # The equations.
    # First the normalizer part, \ldots

    A:= NullMat( n + s*s, n*s, R );
    for i in [ 1..n ] do
      for j in [ 1..n ] do
        cij:= T[i][j];
        for l in [ 1..s ] do
          for k in [ 1..Length( cij[1] ) ] do
            pos:= (l-1)*n+cij[1][k];
            A[i][pos]:= A[i][pos]+v[l][j]*cij[2][k];
          od;
        od;
      od;
    od;

    # \ldots and then the "superfluous" part.

    for k in [1..n] do
      for l in [1..s] do
        for i in [1..s] do
          A[ n+(l-1)*s+i ][ (l-1)*n+k ]:= -v[i][k];
        od;
      od;
    od;

    # Solve the equation system.
    b:= NullspaceMat(A);

    # Extract the `normalizer part' of the solution.
    l:= Length(b);
    bas:= NullMat( l, n, R );
    for i in [ 1..l ] do
      for j in [ 1..n ] do
        bas[i][j]:= b[i][j];
      od;
    od;

    # Construct the generators from the coefficients list.
    bas:= List( bas, x -> LinearCombination( B, x ) );

    # Return the subalgebra.
    return SubalgebraNC( L, bas, "basis" );
    end );


##############################################################################
##
#M  KappaPerp( <L>, <U> ) . . . . . . . . for a Lie algebra and a vector space
##
#T  Should this better be `OrthogonalSpace( <F>, <U> )' where <F> is a
#T  bilinear form?
#T  How to represent forms in GAP?
#T  (Clearly the form must know about the space <L>.)
##
##  If $(x_1,\ldots, x_n)$ is a basis of $L$ and $(u_1,\ldots, u_s)$ is a
##  basis of $U$ such that $u_k = \sum_{j=1}^n v_{kj} x_j$ then an element
##  $x = \sum_{i=1}^n a_i x_i$ is an element of $U^{\perp}$ iff the $a_i$
##  satisfy the equations
##  $\sum_{i=1}^n ( \sum_{j=1}^n v_{kj} \kappa(x_i,x_j) ) a_i = 0$ for
##  $k = 1, \ldots, s$.
##
InstallMethod( KappaPerp,
    "for a Lie algebra and a vector space",
    IsIdenticalObj,
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ], 0,
    function( L, U )

    local R,          # left acting domain of `L'
          B,     # a basis of L
          kap,   # the matrix of the Killing form w.r.t. `B'
          A,     # the matrix of the equation system
          n,     # the dimension of L
          s,     # the dimension of U
          v,     # coefficient list of the basis of U w.r.t. the basis of L
          i,j,k, # loop variables
          bas;   # the basis of the solution space

    R:= LeftActingDomain( L );
    B:= Basis( L );
    n:= Dimension( L );
    s:= Dimension( U );

    if s = 0 or n = 0 then
      return L;
    fi;

    v:= List( BasisVectors( Basis( U ) ),
              x -> Coefficients( B, x ) );
    A:= NullMat( n, s, R );
    kap:= KillingMatrix( B );

    # Compute the equations that define the subspace.
    for k in [ 1..s ] do
      for i in [ 1..n ] do
        for j in [ 1..n ] do
          A[i][k]:= A[i][k] + v[k][j] * kap[i][j];
        od;
      od;
    od;

    # Solve the equation system.
    bas:= NullspaceMat( A );

    # Extract the generators.
    bas:= List( bas, x -> LinearCombination( B, x ) );

    return SubspaceNC( L, bas, "basis" );

    end );


#############################################################################
##
#M  AdjointMatrix( <B>, <x> )
##
##  If the basis vectors are $(b-1, b_2, \ldots, b_n)$, and
##  $x = \sum_{i=1}^n x_i b_i$ then $b_j$ is mapped to
##  $[ x, b_j ] = \sum_{i=1}^n x_i [ b_i b_j ]
##              = \sum_{k=1}^n ( \sum_{i=1}^n x_i c_{ijk} ) b_k$,
##  so the entry in the $k$-th row and the $j$-th column of the adjoint
##  matrix is $\sum_{i=1}^n x_i c_{ijk}$.
##
##  Note that $ad_x$ is a left multiplication, so also the action of the
##  adjoint matrix is from the left (i.e., on column vectors).
##
InstallMethod( AdjointMatrix,
    "for a basis of a Lie algebra, and an element",
    IsCollsElms,
    [ IsBasis, IsRingElement ], 0,
    function( B, x )

    local n,            # dimension of the algebra
          T,            # structure constants table w.r. to `B'
          zerovector,   # zero of the field
          M,            # adjoint matrix, result
          j, i, l,      # loop variables
          cij,          # structure constants vector
          k,            # one position in structure constants vector
          row;          # one row of `M'

    x:= Coefficients( B, x );
    n:= Length( BasisVectors( B ) );
    T:= StructureConstantsTable( B );
    zerovector:= [ 1 .. n ] * T[ Length( T ) ];
    M:= [];
    for j in [ 1 .. n ] do
      row:= ShallowCopy( zerovector );
      for i in [ 1 .. n ] do
        cij:= T[i][j];
        for l in [ 1 .. Length( cij[1] ) ] do
          k:= cij[1][l];
          row[k]:= row[k] + x[i] * cij[2][l];
        od;
      od;
      M[j]:= row;
    od;

    return TransposedMat( M );
    end );

#T general function for arbitrary algebras? (right/left multiplication)
#T RegularRepresentation: right multiplication satisfies M_{xy} = M_x M_y
#T is just the negative of the adjoint ...


#############################################################################
##
#M  RightDerivations( <B> )
##
##  Let $n$ be the dimension of $A$.
##  We start with $n^2$ indeterminates $D = [ d_{i,j} ]_{i,j}$ which
##  means that $D$ maps $b_i$ to $\sum_{j=1}^n d_{ij} b_j$.
##
##  (Note that this is row convention.)
##
##  This leads to the following linear equation system in the $d_{ij}$.
##  $\sum_{k=1}^n ( c_{ijk} d_{km} - c_{kjm} d_{ik} - c_{ikm} d_{jk} ) = 0$
##  for all $1 \leq i, j, m \leq n$.
##  The solution of this system gives us a vector space basis of the
##  algebra of derivations.
##
InstallMethod( RightDerivations,
    "method for a basis of an algebra",
    true,
    [ IsBasis ], 0,
    function( B )

    local T,           # structure constants table w.r. to 'B'
          L,           # underlying Lie algebra
          R,           # left acting domain of 'L'
          n,           # dimension of 'L'
          eqno,offset,
          A,
          i, j, k, m,
          M;             # the Lie algebra of derivations

    if not IsAlgebra( UnderlyingLeftModule( B ) ) then
      Error( "<B> must be a basis of an algebra" );
    fi;

    if IsLieAlgebra( UnderlyingLeftModule( B ) ) then
      offset:= 1;
    else
      offset:= 0;
    fi;

    T:= StructureConstantsTable( B );
    L:= UnderlyingLeftModule( B );
    R:= LeftActingDomain( L );
    n:= Dimension( L );

    if n = 0 then
      return NullAlgebra( R );
    fi;

    # The rows in the matrix of the equation system are indexed
    # by the $d_{ij}$; the $((i-1) n + j)$-th row belongs to $d_{ij}$.

    # Construct the equation system.
    if offset = 1 then
      A:= NullMat( n^2, (n-1)*n*n/2, R );
    else
      A:= NullMat( n^2, n^3, R );
    fi;
    eqno:= 0;
    for i in [ 1 .. n ] do
      for j in [ offset*i+1 .. n ] do
        for m in [ 1 .. n ] do
          eqno:= eqno+1;
          for k in [ 1 .. n ] do
            A[ (k-1)*n+m ][eqno]:= A[ (k-1)*n+m ][eqno] +
                                        SCTableEntry( T,i,j,k );
            A[ (i-1)*n+k ][eqno]:= A[ (i-1)*n+k ][eqno] -
                                        SCTableEntry( T,k,j,m );
            A[ (j-1)*n+k ][eqno]:= A[ (j-1)*n+k ][eqno] -
                                        SCTableEntry( T,i,k,m );
          od;
        od;
      od;
    od;

    # Solve the equation system.
    # Note that if `L' is a Lie algebra and $n = 1$ the matrix is empty.

    if n = 1 and offset = 1 then
      A:= [ [ One( R ) ] ];
    else
      A:= NullspaceMatDestructive( A );
    fi;

    # Construct the generating matrices from the vectors.
    A:= List( A, v -> List( [ 1 .. n ],
                            i -> v{ [ (i-1)*n + 1 .. i*n ] } ) );

    # Construct the Lie algebra.
    if IsEmpty( A ) then
      M:= AlgebraByGenerators( R, [],
              LieObject( Immutable( NullMat( n, n, R ) ) ) );
    else
      A:= List( A, LieObject );
      M:= AlgebraByGenerators( R, A );
      UseBasis( M, A );
    fi;

    # Return the derivations.
    return M;
end );


#############################################################################
##
#M  LeftDerivations( <B> )
##
##  Let $n$ be the dimension of $A$.
##  We start with $n^2$ indeterminates $D = [ d_{i,j} ]_{i,j}$ which
##  means that $D$ maps $b_i$ to $\sum_{j=1}^n d_{ji} b_j$.
##
##  (Note that this is column convention.)
##
InstallMethod( LeftDerivations,
    "method for a basis of an algebra",
    true,
    [ IsBasis ], 0,
    function( B )

    local T,           # structure constants table w.r. to 'B'
          L,           # underlying Lie algebra
          R,           # left acting domain of 'L'
          n,           # dimension of 'L'
          eqno,offset,
          A,
          i, j, k, m,
          M;             # the Lie algebra of derivations

    if not IsAlgebra( UnderlyingLeftModule( B ) ) then
      Error( "<B> must be a basis of an algebra" );
    fi;

    if IsLieAlgebra( UnderlyingLeftModule( B ) ) then
      offset:= 1;
    else
      offset:= 0;
    fi;

    T:= StructureConstantsTable( B );
    L:= UnderlyingLeftModule( B );
    R:= LeftActingDomain( L );
    n:= Dimension( L );

    if n = 0 then
      return NullAlgebra( R );
    fi;

    # The rows in the matrix of the equation system are indexed
    # by the $d_{ij}$; the $((i-1) n + j)$-th row belongs to $d_{ij}$.

    # Construct the equation system.
    if offset = 1 then
      A:= NullMat( n^2, (n-1)*n*n/2, R );
    else
      A:= NullMat( n^2, n^3, R );
    fi;
    eqno:= 0;
    for i in [ 1 .. n ] do
      for j in [ offset*i+1 .. n ] do
        for m in [ 1 .. n ] do
          eqno:= eqno+1;
          for k in [ 1 .. n ] do
            A[ (m-1)*n+k ][eqno]:= A[ (m-1)*n+k ][eqno] +
                                        SCTableEntry( T,i,j,k );
            A[ (k-1)*n+i ][eqno]:= A[ (k-1)*n+i ][eqno] -
                                        SCTableEntry( T,k,j,m );
            A[ (k-1)*n+j ][eqno]:= A[ (k-1)*n+j ][eqno] -
                                        SCTableEntry( T,i,k,m );
          od;
        od;
      od;
    od;

    # Solve the equation system.
    # Note that if `L' is a Lie algebra and $n = 1$ the matrix is empty.

    if n = 1 and offset = 1 then
      A:= [ [ One( R ) ] ];
    else
      A:= NullspaceMatDestructive( A );
    fi;

    # Construct the generating matrices from the vectors.
    A:= List( A, v -> List( [ 1 .. n ],
                            i -> v{ [ (i-1)*n + 1 .. i*n ] } ) );

    # Construct the Lie algebra.
    if IsEmpty( A ) then
      M:= AlgebraByGenerators( R, [],
              LieObject( Immutable( NullMat( n, n, R ) ) ) );
    else
      A:= List( A, LieObject );
      M:= AlgebraByGenerators( R, A );
      UseBasis( M, A );
    fi;

    # Return the derivations.
    return M;
end );



#############################################################################
##
#M  KillingMatrix( <B> )
##
##  We have $\kappa_{i,j} = \sum_{k,l=1}^n c_{jkl} c_{ilk}$ if $c_{ijk}$
##  are the structure constants w.r. to <B>.
##
##  (The matrix is symmetric, no matter whether the multiplication is
##  (anti-)symmetric.)
##
InstallMethod( KillingMatrix,
    "for a basis of a Lie algebra",
    true,
    [ IsBasis ], 0,
    function( B )

    local T,           # s.c. table w.r. to `B'
          L,           # the underlying algebra
          R,           # left acting domain of `L'
          kappa,       # the matrix of the killing form, result
          n,           # dimension of `L'
          zero,        # the zero of `R'
          i, j, k, t,  # loop variables
          row,         # one row of `kappa'
          val,         # one entry of `kappa'
          cjk;         # `T[j][k]'

    T:= StructureConstantsTable( B );
    L:= UnderlyingLeftModule( B );
    R:= LeftActingDomain( L );
    n:= Dimension( L );
    kappa:= [];
    zero:= Zero( R );

    for i in [ 1 .. n ] do
      row:= [];
      for j in [ 1 .. i ] do

        val:= zero;
        for k in [ 1 .. n ] do
          cjk:= T[j][k];
          for t in [ 1 .. Length( cjk[1] ) ] do
            val:= val + cjk[2][t] * SCTableEntry( T, i, cjk[1][t], k );
          od;
        od;
        row[j]:= val;
        if i <> j then
          kappa[j][i]:= val;
        fi;

      od;
      kappa[i]:= row;

    od;

    # Return the result.
    return kappa;
    end );


##############################################################################
##
#M  AdjointBasis( <B> )
##
##  The input is a basis of a (Lie) algebra $L$.
##  This function returns a particular basis $C$ of the matrix space generated
##  by $ad L$, namely a basis consisting of elements of the form $ad x_i$
##  where $x_i$ is a basis element of <B>.
##  An extra component `indices' is added to this space.
##  This is a list of integers such that `ad <B>.basisVectors[ indices[i] ]'
##  is the `i'-th basis vector of <C>, for i in [1..Length(indices)].
##  (This list is added in order to be able to identify the basis element of
##  <B> with the property that its adjoint matrix is equal to a given basis
##  vector of <C>.)
##
InstallMethod( AdjointBasis,
    "for a basis of a Lie algebra",
    true,
    [ IsBasis ], 0,
    function( B )

    local bb,     # the basis vectors of `B'
          n,      # the dimension of `B'
          F,      # the field over which the algebra is defined
          adL,    # a list of matrices that form a basis of adLsp
          adLsp,  # the matrix space spanned by ad L
          inds,   # the list of indices
          i,      # loop variable
          adi,    # the adjoint matrix of the i-th basis vector of `B'
          adLbas; # the basis of `adLsp' compatible with `adL'

    bb:= BasisVectors( B );
    n:= Length( bb );
    F:= LeftActingDomain( UnderlyingLeftModule( B ) );
    adL:= [];
    adLsp:= MutableBasis( F, [ NullMat(n,n,F) ] );
#T better declare the zero ?
    inds:= [];
    for i in [1..n] do
      adi:= AdjointMatrix( B, bb[i] );
      if not IsContainedInSpan( adLsp, adi ) then
        Add( adL, adi );
        Add( inds, i );
        CloseMutableBasis( adLsp, adi );
      fi;
    od;

    if adL = [ ] then
       adLbas:= Basis( VectorSpace( F, [ ], NullMat( n, n, F ) ) );
    else
       adLbas:= Basis( VectorSpace( F, adL ), adL );
    fi;

    SetIndicesOfAdjointBasis( adLbas, inds );

    return adLbas;
    end );


##############################################################################
##
#M  IsRestrictedLieAlgebra( <L> ) . . . . . . . . . . . . .  for a Lie algebra
##
##  A Lie algebra <L> is defined to be {\em restricted} when it is defined
##  over a field of characteristic $p \neq 0$, and for every basis element
##  $x$ of <L> there exists $y\in <L>$ such that $(ad x)^p = ad y$
##  (see Jacobson, p. 190).
##
InstallMethod( IsRestrictedLieAlgebra,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local F,        # the field over which L is defined
          B,        # the basis of L
          p,        # the characteristic of F
          adL,      # basis for the (matrix) vector space generated by ad L
          v;        # loop over basis vectors of adL

    F:= LeftActingDomain( L );
    p:= Characteristic( F );
    if p = 0 then
      return false;
    fi;

    B:= Basis( L );

    adL:= AdjointBasis( B );

    # Check if ad(L) is closed under the p-th power operation.
    for v in BasisVectors( adL ) do
      if not v^p in UnderlyingLeftModule( adL ) then
        return false;
      fi;
    od;

    return true;
    end );


#############################################################################
##
#F  PowerSi( <F>, <i> )
##
InstallGlobalFunction( PowerSi, function( F, i )

    local si,    # a function of two arguments: seqs, a list of sequences,
                 # and l, a list containing the two arguments of the
                 # function s_i. The list seqs contains
                 # all possible sequences of i-1 1's and p-2-i+1 2's
                 # This function returns the value of s_i(l[1],l[2])
          j,k,   # loop variables
          p,     # the characteristic of F
          combs, # the list of all i-1 element subsets of {1,2,\ldots, p-2}
                 # it serves to make the list seqs
          v,     # a vector of 1's and 2's
          seqs;  # the list of all sequences of 1's and 2's of length p-2,
                 # with i-1 1's and p-2 2's serving as input for si
                 # for example, the sequence [1,1,2] means the element
                 #  [[[[x,y],x],x],y] (the first element [x,y] is present
                 #           1  1  2   in all terms of the sum s_i(x,y)).

    si:= function( seqs, l )

          local x,
                j,k,
                sum;

          for j in [1..Length(seqs)] do
            x:= l[1]*l[2];
            for k in seqs[j] do
              x:= x*l[k];
            od;
            if j=1 then
              sum:= x;
            else
              sum:= sum+x;
            fi;
          od;
          return ( i * One( F ) )^(-1)*sum;
        end;

    p:= Characteristic( F );
    combs:= Combinations( [1..p-2], i-1 );

    # Now all sequences of 1's and 2's of length p and containing i-1 1's
    # are constructed the 1's in the jth sequence are put at the positions
    # contained in combs[j].
    seqs:=[];
    for j in [1..Length( combs )] do
      v:= List( [1..p-2], x -> 2);
      for k in combs[j] do
        v[k]:= 1;
      od;
      Add( seqs, v );
    od;
    return arg -> si( seqs, arg );
end );


#############################################################################
##
#F  PowerS( <L> )
##
InstallMethod( PowerS,
    "for a Lie algebra",
    true,
    [ IsLieAlgebra ], 0,
    function( L )

    local F,    # the coefficients domain
          p;    # the characteristic of `F'

    F:= LeftActingDomain( L );
    p:= Characteristic( F );
    return List( [ 1 .. p-1 ], i -> PowerSi( F , i ) );
    end );


##############################################################################
##
#F  PthPowerImage( <B>, <x> )
##
BindGlobal("PTHPOWERIMAGE_PPI_VEC", function(L,zero,p,bv,pmap,cf,x)
    local
          n,     # the dimension of L
          s,     # the list of s_i functions
          im,    # the image of x under the p-th power map
          i,j;   # loop variables

      n:= Dimension( L );
      s:= PowerS( L );
      im:= Zero( L );

      # First the sum of all $\alpha_i^p x_i^{[p]}$ is calculated.
      for i in [1..n] do
        im:= im + cf[i]^p * pmap[i];
      od;

      # To this the double sum of all
      # $s_i(\alpha_j x_j, \sum_{k=j+1}^n \alpha_k x_k)$
      # is added.
      for j in [1..n-1] do
        if cf[j] <> zero then
          x:= x - cf[j] * bv[j];
          for i in [1..p-1] do
            im:= im + s[i]( [cf[j]*bv[j],x] );
          od;
        fi;
      od;

      return im;
end);

InstallMethod( PthPowerImage,
    "for a basis of an algebra, and a ring element",
    IsCollsElms,
    [ IsBasis, IsRingElement ], 0,
    function( B, x )

    local L,     # the Lie algebra of which B is a basis
          F,     # the coefficients domain of `L'
          n,     # the dimension of L
          p,     # the characteristic of the ground field
          s,     # the list of s_i functions
          pmap,  # the list containing x_i^{[p]}
          cf,    # the coefficients of x wrt the basis of L
          im,    # the image of x under the p-th power map
          i,j,   # loop variables
          zero,  # zero of `F'
          bv,    # basis vectors of `B'
          adx,   # adjoint matrix of x
          adL;   # a basis of the matrix space ad L

    L:= UnderlyingLeftModule( B );
    if not IsLieAlgebra( L ) then
      TryNextMethod();
    fi;

    F:= LeftActingDomain( L );
    p:= Characteristic( F );

    if Dimension( LieCentre( L ) ) = 0 then

      # We calculate the inverse image $ad^{-1} ((ad x)^p)$.
      adx:= AdjointMatrix( B, x );
      adL:= AdjointBasis( B );
      adx:= adx^p;
      cf:= Coefficients( adL, adx );
      return LinearCombination( B, cf );

    else
      return PTHPOWERIMAGE_PPI_VEC(L,Zero(F),p,BasisVectors(B),PthPowerImages(B),Coefficients(B,x),x);
    fi;
    end );

InstallMethod( PthPowerImage, "for an element of a restricted Lie algebra",
    [ IsJacobianElement ], # weaker filter, we maybe only discovered later
                           # that the algebra is restricted
    function(x)
    local fam;
    fam := FamilyObj(x);
    if not IsBound(fam!.pMapping) then TryNextMethod(); fi;
    return PTHPOWERIMAGE_PPI_VEC(fam!.fullSCAlgebra,fam!.zerocoeff,Characteristic(fam),fam!.basisVectors,fam!.pMapping,ExtRepOfObj(x),x);
end);

InstallMethod( PthPowerImage, "for an element of a restricted Lie algebra and an integer",
    [ IsJacobianElement, IsInt ],
    function(x,n)
    local fam;
    fam := FamilyObj(x);
    if not IsBound(fam!.pMapping) then TryNextMethod(); fi;
    while n>0 do
        x := PTHPOWERIMAGE_PPI_VEC(fam!.fullSCAlgebra,fam!.zerocoeff,Characteristic(fam),fam!.basisVectors,fam!.pMapping,ExtRepOfObj(x),x);
        n := n-1;
    od;
    return x;
end);

InstallMethod( PClosureSubalgebra, "for a subalgebra of restricted jacobian elements",
    [ IsLieAlgebra and IsJacobianElementCollection ],
    function(A)
    local i, oldA;

    repeat
        oldA := A;
        for i in Basis(oldA) do
            A := ClosureLeftModule(A,PthPowerImage(i));
        od;
    until A=oldA;
    return A;
end);

#############################################################################
##
#M  PthPowerImages( <B> ) . . . . . . . . . . .  for a basis of a Lie algebra
##
InstallMethod( PthPowerImages,
    "for a basis of a Lie algebra",
    true,
    [ IsBasis ], 0,
    function( B )

    local L,          # the underlying algebra
          p,          # the characteristic of `L'
          adL,        # a basis of the matrix space spanned by ad L
          basL;       # the list of basis vectors `b' of `B' such that
                      # `ad b' is a basis vector of `adL'

    L:= UnderlyingLeftModule( B );
    if not IsRestrictedLieAlgebra( L ) then
      Error( "<L> must be a restricted Lie algebra" );
    fi;

    p:= Characteristic( LeftActingDomain( L ) );

    adL:= AdjointBasis( B );

    if  Dimension( UnderlyingLeftModule( adL ) ) = 0 then

      # The algebra is abelian.
      return List( BasisVectors( B ), x -> Zero( L ) );

    fi;

    # Now `IndicesOfAdjointBasis( adL )' is a list of indices with `i'-th
    # entry the position of the basis vector of `B'
    # whose adjoint matrix is the `i'-th basis vector of `adL'.
    basL:= BasisVectors( B ){ IndicesOfAdjointBasis( adL ) };

    # We calculate the coefficients of $x_i^{[p]}$ wrt the basis basL.
    return List( BasisVectors( B ),
                x -> Coefficients( adL, AdjointMatrix( B, x ) ^ p ) * basL );
#T And why do you compute the adjoint matrices again?
#T Aren't they stored as basis vectors in adL ?
    end );


############################################################################
##
#M  CartanSubalgebra( <L> )
##
##  A Cartan subalgebra of the Lie algebra <L> is by definition a nilpotent
##  subalgebra equal to its own normalizer in <L>.
##
##  By definition, an Engel subalgebra of <L> is the generalized eigenspace
##  of a non nilpotent element, corresponding to the eigenvalue 0.
##  In a restricted Lie algebra of characteristic p we have that every Cartan
##  subalgebra of an Engel subalgebra of <L> is a Cartan subalgebra of <L>.
##  Hence in this case we construct a decreasing series of Engel subalgebras.
##  When it becomes stable we have found a Cartan subalgebra.
##  On the other hand, when <L> is not restricted and is defined over a field
##  $F$ of cardinality greater than the dimension of <L> we can proceed as
##  follows.
##  Let $a$ be a non nilpotent element of <L> and $K$ the corresponding
##  Engel subalgebra.  Furthermore, let $b$ be a non nilpotent element of $K$.
##  Then there is an element $c \in F$ such that $a + c ( b - a )$ has an
##  Engel subalgebra strictly contained in $K$
##  (see Humphreys, proof of Lemma A, p 79).
##
InstallMethod( CartanSubalgebra,
    "for a Lie algebra",
    true,
    [ IsLieAlgebra ], 0,
    function( L )

    local n,            # the dimension of L
          F,            # coefficients domain of `L'
          root,         # prim. root of `F' if `F' is finite
          K,            # a subalgebra of L (on termination a Cartan subalg.)
          a,b,          # (non nilpotent) elements of L
          A,            # matrix of the equation system (ad a)^n(x)=0
          bas,          # basis of the solution space of Ax=0
          sp,           # the subspace of L generated by bas
          found,ready,  # boolean variables
          c,            # an element of `F'
          newelt,       # an element of L of the form a+c*(b-a)
          i;            # loop variable

    n:= Dimension(L);
    F:= LeftActingDomain( L );

    if IsRestrictedLieAlgebra( L ) then

      K:= L;
      while true do

        a:= NonNilpotentElement( K );

        if a = fail then
          # `K' is a nilpotent Engel subalgebra, hence a Cartan subalgebra.
          return K;
        fi;

        # `a' is a non nilpotent element of `K'.
        # We construct the generalized eigenspace of this element w.r.t.
        # the eigenvalue 0.  This is a subalgebra of `K' and of `L'.
        A:= TransposedMat( AdjointMatrix( Basis( K ), a));
        A:= A ^ Dimension( K );
        bas:= NullspaceMat( A );
        bas:= List( bas, x -> LinearCombination( Basis( K ), x ) );
        K:= SubalgebraNC( L, bas, "basis");

      od;

    elif n < Size( F ) then

      # We start with an Engel subalgebra. If it is nilpotent
      # then it is a Cartan subalgebra and we are done.
      # Otherwise we make it smaller.

      a:= NonNilpotentElement( L );

      if a = fail then
        # `L' is nilpotent.
        return L;
      fi;

      # `K' will be the Engel subalgebra corresponding to `a'.

      A:= TransposedMat( AdjointMatrix( Basis( L ), a ) );
      A:= A^n;
      bas:= NullspaceMat( A );
      bas:= List( bas, x -> LinearCombination( Basis( L ), x ) );
      K:= SubalgebraNC( L, bas, "basis");

      # We locate a nonnilpotent element in this Engel subalgebra.

      b:= NonNilpotentElement( K );

      # If `b = fail' then `K' is nilpotent and we are done.
      ready:= ( b = fail );

      while not ready do

        # We locate an element $a + c*(b-a)$ such that the Engel subalgebra
        # belonging to this element is smaller than the Engel subalgebra
        # belonging to `a'.
        # We do this by checking a few values of `c'
        # (At most `n' values of `c' will not yield a smaller subalgebra.)

        sp:= VectorSpace( F, BasisVectors( Basis(K) ), "basis");
        found:= false;
        if Characteristic( F ) = 0 then
          c:= 0;
        else
          root:= PrimitiveRoot( F );
          c:= root;
        fi;
        while not found do

          if Characteristic( F ) = 0 then
            c:= c+1;
          else
            c:= c*root;
          fi;
          newelt:= a+c*(b-a);

          # Calculate the Engel subalgebra belonging to `newelt'.
          A:= TransposedMat( AdjointMatrix( Basis( K ), newelt ) );
          A:= A^Dimension( K );
          bas:= NullspaceMat( A );
          bas:= List( bas, x -> LinearCombination( Basis( K ), x ) );

          # We have found a smaller subalgebra if the dimension is smaller
          # and new basis elements are contained in the old space.

          found:= Length( bas ) < Dimension( K );
          i:= 1;
          while i <= Length( bas ) and found do
            if not bas[i] in sp then
              found:= false;
            fi;
            i:= i+1;
          od;
        od;

        a:= newelt;
        K:= SubalgebraNC( L, bas, "basis");
        b:= NonNilpotentElement( K );

        # If `b = fail' then `K' is nilpotent and we are done.
        ready:= b = fail;

      od;

      return K;

    else

      # the field over which <L> is defined is too small
      TryNextMethod();

    fi;
    end );


##############################################################################
##
#M  AdjointAssociativeAlgebra( <L>, <K> )
##
##  This function calculates a basis of the associative matrix algebra
##  generated by ad_L K, where <K> is a subalgebra of <L>.
##  If {x_1,\ldots ,x_n} is a basis of K, then this algebra is spanned
##  by all words
##                          ad x_{i_1}\cdots ad x_{i_t}
##  where t>0.
##  The degree of such a word is t.
##  The algorithm first calculates a maximal linearly independent set
##  of words of degree 1, then of degree 2 and so on.
##  Since ad x ad y -ady ad x = ad [x,y], we have that we only have
##  to consider words where i_1\leq i_2\leq \cdots \leq i_t.
##
InstallMethod( AdjointAssociativeAlgebra,
    "for a Lie algebra and a subalgebra",
    true,
    [ IsAlgebra and IsLieAlgebra, IsAlgebra and IsLieAlgebra ], 0,
    function( L, K )

    local n,         # the dimension of L
          F,         # the field of L
          asbas,     # a list containing the basis elts. of the assoc. alg.
          highdeg,   # a list of the elements of the highest degree computed
                     # so far
          degree1,   # a list of elements of degree 1 (i.e. ad x_i)
          lowinds,   # a list of indices such that lowinds[i] is the smallest
                     # index in the word highdeg[i]
          hdeg,      # the new highdeg constructed each step
          linds,     # the new lowinds constructed each step
          i,j,k,     # loop variables
          ind,       # an index
          m,         # a matrix
          posits,    # a list of positions in matrices:
                     # posits[i] is a list of the form [p,q] such that
                     # the matrix asbas[i] has a nonzero entry at position
                     # [p][q] and furthermore the matrices asbas[j] with j>i
                     # will have a zero at that position (so the basis
                     # constructed will be in `upper triangular form')
          l1,l2,     # loop variables
          found;     # a boolean

    F:= LeftActingDomain( L );

    if Dimension( K ) = 0 then
      return Algebra( F, [ [ [ Zero(F) ] ] ] );
    elif IsLieAbelian( L ) then
      return Algebra( F, [ AdjointMatrix( Basis( L ),
                                          GeneratorsOfAlgebra( K )[1] ) ] );
    fi;

    n:= Dimension( L );

    # Initialisations that ensure that the first step of the loop will select
    # a maximal linearly independent set of matrices of degree 1.

    degree1:= List( BasisVectors( Basis(K) ),
                        x -> AdjointMatrix( Basis(L), x ) );
    posits  := [ [ 1, 1 ] ];
    highdeg := [ IdentityMat( n, F ) ];
    asbas   := [ Immutable( highdeg[1] ) ];
    lowinds := [ Dimension( K ) ];

    # If after some steps all words of degree t (say) can be reduced modulo
    # lower degree, then all words of degree >t can be reduced to linear
    # combinations of words of lower degree.
    # Hence in that case we are done.

    while not IsEmpty( highdeg ) do

      hdeg:= [];
      linds:= [];

      for i in [1..Length(highdeg)] do

        # Now we multiply all elements `highdeg[i]' with all possible
        # elements of degree 1 (i.e. elements having an index <= the lowest
        # index of the word `highdeg[i]')

        ind:= lowinds[i];
        for j in [1..ind] do

          m:= degree1[j]*highdeg[i];

          # Now we first reduce `m' on the basis computed so far
          # and then add it to the basis.

          for k in [1..Length(posits)] do
            l1:= posits[k][1];
            l2:= posits[k][2];
            m:= m-(m[l1][l2]/asbas[k][l1][l2])*asbas[k];
          od;

          if not IsZero( m ) then

            #'m' is not an element of the span of `asbas'

            Add( hdeg, m );
            Add( linds, j );
            Add( asbas, m);

            # Now we look for a nonzero entry in `m'
            # and add the position of that entry to `posits'.

            found:= false;
            l1:= 1; l2:= 1;
            while not found do
              if m[l1][l2] <> Zero( F ) then
                Add( posits, [l1,l2] );
                found:= true;
              else
                if l2 = n then
                  l1:= l1+1;
                  l2:= 1;
                else
                  l2:= l2+1;
                fi;
              fi;
            od;

         fi;

        od;

      od;

      if lowinds = [Dimension(K)] then

        # We are in the first step and hence `degree1' must be made
        # equal to the linearly independent set that we have just calculated.

        degree1:= ShallowCopy( hdeg );
        linds:= [1..Length(degree1)];

      fi;

      highdeg:= ShallowCopy( hdeg );
      lowinds:= ShallowCopy( linds );

    od;

    return Algebra( F, asbas, "basis" );
    end );


##############################################################################
##
#M  LieNilRadical( <L> )
##
##  Let $p$ be the characteristic of the coefficients field of <L>.
##  If $p=0$ the we use the following characterisation of the LieNilRadical:
##  Let $S$ be the solvable radical of <L>. And let $H$ be a Cartan subalgebra
##  of $S$. Decompose $S$ as $S = H \oplus S_1(H)$, where $S_1(H)$ is the
##  Fitting 1-component of the adjoint action of $H$ on $S$. Let $H*$ be the
##  associative algebra generated by $ad H$, then $S_1(H)$ is the intersection
##  of the spaces $H*^i( S )$ for $i>0$. Let $R$ be the radical of the
##  algebra $H*$. Then the LieNilRadical of <L> consists of $S_1(H)$ together
##  with all elements $x$ in $H$ such that $ad x\in R$. This last space
##  is also characterised as the space of all elements $x$ such that
##  $ad x$ lies in the vector space spanned by all nilpotent parts of all
##  $ad h$ for $h\in H$.
##
##  In the case where $p>0$ we calculate the radical of the associative
##  matrix algebra $A$ generated by $ad `L'$.
##  The nil radical is then equal to $\{ x\in L \mid ad x \in A \}$.
##
InstallMethod( LieNilRadical,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local F,           # the coefficients domain of `L'
          p,           # the characteristic of `F'
          bv,          # basis vectors of a basis of `L'
          S,           # the solvable radical of `L'
          H,           # Cartan subalgebra of `S'
          HS,          # Fitting 1-component of `S' wrt `H'
          adH,         # list of ad x for x in a basis of `H'
          n,           # dimension of `L'
          t,           # the dimension of an ideal
          eqs,         # equation set
          I,           # basis vectors of an ideal of `L'
          i,j,k,       # loop variables
          sol,         # solution set
          adL,         # list of matrices ad x where x runs through a basis of
                       # `L'
          A,           # an associative algebra
          R,           # the radical of this algebra
          B;           # list of basis vectors of R

    F:= LeftActingDomain( L );
    p:= Characteristic( F );

    if p = 0 then

      # The LieNilRadical of <L> is equal to
      # the LieNilRadical of its solvable radical.

      S:= LieSolvableRadical( L );
      n:= Dimension( S );

      if n in [ 0, 1 ] then return S; fi;

      H:= CartanSubalgebra(S);

      if Dimension(H) = n then return S; fi;

# We calculate the Fitting 1-component $S_1(H)$.

      HS:= ProductSpace( H, S );
      while Dimension( HS ) + Dimension( H ) <> n do
        HS:= ProductSpace( H, HS );
      od;

      if Dimension( H ) = 1 then
         return IdealNC( L, BasisVectors(Basis(HS)), "basis" );
      fi;

# Now we compute the intersection of `R' and `<ad H>'.

      adH:= List( BasisVectors(Basis(H)), x -> AdjointMatrix(Basis(S),x));
      R:= RadicalOfAlgebra( AdjointAssociativeAlgebra( S, H ) );
      B:= BasisVectors( Basis( R ) );

      eqs:= NullMat(Dimension(H)+Dimension(R),n^2,F);
      for i in [1..n] do
        for j in [1..n] do
          for k in [1..Dimension(H)] do
            eqs[k][j+(i-1)*n]:= adH[k][i][j];
          od;
          for k in [1..Dimension(R)] do
            eqs[Dimension(H)+k][j+(i-1)*n]:= B[k][i][j];
          od;
        od;
      od;
      sol:= NullspaceMat( eqs );
      I:= List( sol, x-> LinearCombination( Basis(H), x{[1..Dimension(H)]} ) );

      Append( I, BasisVectors( Basis( HS ) ) );

      return IdealNC( L, I, "basis" );

    else

      n:= Dimension( L );
      bv:= BasisVectors( Basis(L) );
      adL:= List( bv, x -> AdjointMatrix(Basis(L),x) );
      A:= AdjointAssociativeAlgebra( L, L );
      R:= RadicalOfAlgebra( A );

      if Dimension( R ) = 0 then

        # In this case the intersection of `ad L' and `R' is the centre of L.
        return LieCentre( L );

      fi;

      B:= BasisVectors( Basis( R ) );
      t:= Dimension( R );

      # Now we compute the intersection of `R' and `<ad L>'.

      eqs:= NullMat(n+t,n*n,F);
      for i in [1..n] do
        for j in [1..n] do
          for k in [1..n] do
            eqs[k][j+(i-1)*n]:= adL[k][i][j];
          od;
          for k in [1..t] do
            eqs[n+k][j+(i-1)*n]:= -B[k][i][j];
          od;
        od;
      od;
      sol:= NullspaceMat( eqs );
      I:= List( sol, x-> LinearCombination( bv, x{[1..n]} ) );
      return SubalgebraNC( L, I, "basis" );

    fi;

    end );


##############################################################################
##
#M  LieSolvableRadical( <L> )
##
##  In characteristic zero, the solvable radical of the Lie algebra <L> is
##  just the orthogonal complement of $[ <L> <L> ]$ w.r.t. the Killing form.
##
##  In characteristic $p > 0$, the following fact is used:
##  $R( <L> / NR( <L> ) ) = R( <L> ) / NR( <L> )$ where
##  $R( <L> )$ denotes the solvable radical of $L$ and $NR( <L> )$ its
##  nil radical).
##
InstallMethod( LieSolvableRadical,
    "for a Lie algebra",
    true,
    [ IsLieAlgebra ], 0,
    function( L )

    local LL,    # the derived algebra of L
          n,     # the nil radical of L
          B,     # a basis of the solvable radical of L
          quo,   # the quotient L/n
          r1,    # the solvable radical of L/n
          hom;   # the canonical map L -> L/n

    if Characteristic( LeftActingDomain( L ) ) = 0 then

      LL:= LieDerivedSubalgebra( L );
      B:= BasisVectors( Basis( KappaPerp( L, LL ) ) );

    else

      n:= LieNilRadical( L );

      if Dimension( n ) = 0 or Dimension( n ) = Dimension( L ) then
        return n;
      fi;

      hom:= NaturalHomomorphismByIdeal( L, n );
      quo:= ImagesSource( hom );
      r1:= LieSolvableRadical( quo );
      B:= BasisVectors( Basis( r1 ) );
      B:= List( B, x -> PreImagesRepresentative( hom, x ) );
      Append( B, BasisVectors( Basis( n ) ) );

    fi;

    SetIsLieSolvable( L, Length( B ) = Dimension( L ) );

    return IdealNC( L, B, "basis");

    end );


##############################################################################
##
#M  DirectSumDecomposition( <L> )
##
##  This function calculates a list of ideals of `L' such that `L' is equal
##  to the direct sum of them.
##  The existence of a decomposition of `L' is equivalent to the existence
##  of a nontrivial idempotent in the centralizer of `ad L' in the full
##  matrix algebra `M_n(F)'. In the general case we try to find such
##  idempotents.
##  In the case where the Killing form of `L' is nondegenerate we can use
##  a more elegant method. In this case the action of the Cartan subalgebra
##  will `identify' the direct summands.
##
InstallMethod( DirectSumDecomposition,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local F,                # The field of `L'.
          BL,               # basis of `L'
          bvl,              # basis vectors of `BL'
          n,                # The dimension of `L'.
          m,                # An integer.
          set,              # A list of integers.
          C,                # The centre of `L'.
          bvc,              # basis vectors of a basis of `C'
          D,                # The derived subalgebra of `L'.
          CD,               # The intersection of `C' and `D'.
          H,                # A Cartan subalgebra of `L'.
          BH,               # basis of `H'
          B,                # A list of bases of subspaces of `L'.
          cf,               # Coefficient list.
          comlist,          # List of commutators.
          ideals,           # List of ideals.
          bb,               # List of basis vectors.
          B1,B2,            # Bases of the ideals.
          sp,               # A vector space.
          x,                # An element of `sp'.
          b,                # A list of basis vectors.
          bas,res,          # Bases of associative algebras.
          i,j,k,l,          # Loop variables.
          centralizer,      # The centralizer of `adL' in the matrix algebra.
          Rad,              # The radical of `centralizer'.
          M,mat,            # Matrices.
          facs,             # A list of factors of a polynomial.
          f,                # Polynomial.
          contained,        # Boolean variable.
          adL,              # A basis of the matrix space `ad L'.
          Q,                # The factor algebra `centralizer/Rad'
          q,                # Number of elements of the field of `L'.
          ei,ni,E,        # Elements from `centralizer'
          hom,              # A homomorphism.
          id,               # A list of idempotents.
          vv;               # A list of vectors.


    F:= LeftActingDomain( L );
    n:= Dimension( L );
    if n=0 then
        return [ L ];
    fi;

    if RankMat( KillingMatrix( Basis( L ) ) ) = n then

      # The algorithm works as follows.
      # Let `H' be a Cartan subalgebra of `L'.
      # First we decompose `L' into a direct sum of subspaces `B[i]'
      # such that the minimum polynomial of the adjoint action of an element
      # of `H' restricted to `B[i]' is irreducible.
      # If `L' is a direct sum of ideals, then each of these subspaces
      # will be contained in precisely one ideal.
      # If the field `F' is big enough then we can look for a splitting
      # element in `H'.
      # This is an element `h' such that the minimum polynomial of `ad h'
      # has degree `dim L - dim H + 1'.
      # If the size of the field is bigger than `2*m' then there is a
      # powerful randomised algorithm (Las Vegas type) for finding such an
      # element. We just take a random element from `H' and with probability
      # > 1/2 this will be a splitting element.
      # If the field is small, then we use decomposable elements instead.

      H:= CartanSubalgebra( L );
      BH:= Basis( H );
      BL:= Basis( L );

      m:= (( n - Dimension(H) ) * ( n - Dimension(H) + 2 )) / 8;

      if 2*m < Size(F) and ( not Characteristic( F ) in [2,3] ) then

        set:= [ -m .. m ];

        repeat
          cf:= List([ 1 .. Dimension( H ) ], x -> Random( set ) );
          x:= LinearCombination( BH, cf );
          M:= AdjointMatrix( BL, x );
          f:= CharacteristicPolynomial( F, F, M );
          f:= f/Gcd( f, Derivative( f ) );
        until DegreeOfLaurentPolynomial( f )
                  = Dimension( L ) - Dimension( H ) + 1;

      # We decompose the action of the splitting element:

        facs:= Factors( PolynomialRing( F ), f );
        B:= [];
        for i in facs do
          Add( B, List( NullspaceMat( TransposedMat( Value( i, M ) ) ),
                            x -> LinearCombination( BL, x ) ) );
        od;

        B:= Filtered( B, x -> not ( x[1] in H ) );

      else

       # Here `L' is a semisimple Lie algebra over a small field or a field
       # of characteristic 2 or 3. This means that
       # the existence of splitting elements is not assured. So we work
       # with decomposable elements rather than with splitting ones.
       # A decomposable element is an element from the associative
       # algebra `T' generated by `ad H' that has a reducible minimum
       # polynomial. Let `V' be a stable subspace (under the action of `H')
       # computed in the process. Then we proceed as follows.
       # We choose a random element from `T' and restrict it to `V'. If this
       # element has an irreducible minimum polynomial of degree equal to
       # the dimension of the associative algebra `T' restricted to `V',
       # then `V' is irreducible. On the other hand,
       # if this polynomial is reducible, then we decompose `V'.

       # `bas' will be a basis of the associative algebra generated by
       # `ad H'. The computation of this basis is facilitated by the fact
       # that we know the dimension of this algebra.

        bas:= List( BH, x -> AdjointMatrix( Basis( L ), x ) );
        sp:= MutableBasis( F, bas );

        k:=1; l:=1;
        while k<=Length(bas) do
          if Length(bas)=Dimension(L)-Dimension(H) then break; fi;
          M:= bas[ k ]*bas[ l ];
          if not IsContainedInSpan( sp, M ) then
            CloseMutableBasis( sp, M );
            Add( bas, M );
          fi;
          if l < Length(bas) then l:=l+1;
                             else k:=k+1; l:=1;
          fi;
        od;
        Add( bas, Immutable( IdentityMat( Dimension( L ), F ) ) );

       # Now `B' will be a list of subspaces of `L' stable under `H'.
       # We stop once every element from `B' is irreducible.

        cf:= AsList( F );
        B:= [ ProductSpace( H, L ) ];
        k:= 1;

        while k <= Length( B ) do
          if Dimension( B[k] ) = 1 then
            k:=k+1;
          else
            b:= BasisVectors( Basis( B[k] ) );
            M:= LinearCombination( bas, List( bas, x -> Random( cf ) ) );

           # Now we restrict `M' to the space `B[k]'.

            mat:= [ ];
            for i in [1..Length(b)] do
              x:= LinearCombination( BL, M*Coefficients( BL, b[i] ) );
              Add( mat, Coefficients( Basis( B[k], b ), x ) );
            od;
            M:= TransposedMat( mat );

            f:= MinimalPolynomial( F, M );
            facs:= Factors( PolynomialRing( F ), f );

            if Length(facs)=1 then

           # We restrict the basis `bas' to the space `B[k]'. If the length
           # of the result is equal to the degree of `f' then `B[k]' is
           # irreducible.

              sp:= MutableBasis( F,
                     [ Immutable( IdentityMat( Dimension(B[k]), F ) ) ]  );
              for j in [1..Length(bas)] do
                mat:= [ ];
                for i in [1..Length(b)] do
                  x:= LinearCombination( BL, bas[j]*Coefficients( BL, b[i] ) );
                  Add( mat, Coefficients( Basis( B[k], b ), x ) );
                od;
                mat:= TransposedMat( mat );

                if not IsContainedInSpan( sp, mat ) then
                  CloseMutableBasis( sp, mat );
                fi;

              od;
              res:= BasisVectors( sp );

              if Length( res ) = DegreeOfLaurentPolynomial( f ) then

                # The space is irreducible.

                k:=k+1;

              fi;
            else

              # We decompose.

              for i in facs do
                vv:= List( NullspaceMat( TransposedMat( Value( i, M ) ) ),
                                 x -> LinearCombination( b, x ) );
                sp:= VectorSpace( F, vv );
                if not sp in B then Add( B, sp ); fi;
              od;

              # We remove the old space from the list;

              B:= Filtered( B, x -> (x <> B[k]) );

            fi;
           fi;

        od;

        B:= List( B, x -> BasisVectors( Basis( x ) ) );
      fi;

      # Now the pieces in `B' are grouped together.

      ideals:=[];

      while B <> [ ] do

        # Check whether `B[1]' is contained in any of
        # the ideals obtained so far.

        contained := false;
        i:=1;
        while not contained and i <= Length(ideals) do
          if B[1][1] in ideals[i] then
            contained:= true;
          fi;
          i:=i+1;
        od;

        if contained then     # we do not need B[1] any more

          B:= Filtered( B, x -> x<> B[1] );

        else

          # `B[1]' generates a new ideal.
          # We form this ideal by taking `B[1]' together with
          # all pieces from `B' that do not commute with `B[1]'.
          # At the end of this process, `bb' will be a list of elements
          # commuting with all elements of `B'.
          # From this it follows that `bb' will generate
          # a subalgebra that is a simple ideal. (No remaining piece of `B'
          # can be in this ideal because in that case this piece would
          # generate a smaller ideal inside this one.)

          bb:= ShallowCopy( B[1] );
          B:= Filtered( B, x -> x<> B[1] );
          i:=1;
          while i<= Length( B ) do

            comlist:= [ ];
            for j in [1..Length(bb)] do
                Append( comlist, List( B[i], y -> bb[j]*y ) );
            od;

            if not ForAll( comlist, x -> x = Zero(L) ) then
              Append( bb, B[i] );
              B:= Filtered( B, x -> x <> B[i] );
              i:= 1;
            else
              i:=i+1;
            fi;

          od;

          Add( ideals, SubalgebraNC( L, bb ) );

        fi;

      od;

      return List( ideals,
          I -> IdealNC( L, BasisVectors( Basis( I ) ), "basis" ));

    else

      # First we try to find a central component, i.e., a decomposition
      # `L=I_1 \oplus I_2' such that `I_1' is contained in the center of `L'.
      # Such a decomposition exists if and only if the center of `L' is not
      # contained in the derived subalgebra of `L'.

      C:= LieCentre( L );
      bvc:= BasisVectors( Basis( C ) );

      if Dimension( C ) = Dimension( L ) then

        #Now `L' is abelian; hence `L' is the direct sum of `dim L' ideals.

        return List( bvc, v -> IdealNC( L, [ v ], "basis" ) );

      fi;

      BL:= Basis( L );
      bvl:= BasisVectors( BL );

      if 0 < Dimension( C ) then

        D:= LieDerivedSubalgebra( L );
        CD:= Intersection2( C, D );

        if Dimension( CD ) < Dimension( C ) then

          # The central component is the complement of `C \cap D' in `C'.

          B1:=[];
          k:=1;
          sp:= MutableBasis( F,
                   BasisVectors( Basis( CD ) ), Zero( CD ) );
          while Length( B1 ) + Dimension( CD ) <> Dimension( C ) do
            x:= bvc[k];
            if not IsContainedInSpan( sp, x ) then
              Add( B1, x );
              CloseMutableBasis( sp, x );
            fi;
            k:=k+1;
          od;

          # The second ideal is a complement of the central component
          # in `L' containing `D'.
#W next statement modified:
          B2:= ShallowCopy( BasisVectors( Basis( D ) ) );
          k:= 1;
          b:= ShallowCopy( B1 );
          Append( b, B2 );
          sp:= MutableBasis( F, b );
          while Length( B2 )+Length( B1 ) <> n do
            x:= bvl[k];
            if not IsContainedInSpan( sp, x ) then
              Add( B2, x );
              CloseMutableBasis( sp, x );
            fi;
            k:= k+1;
          od;

          ideals:= Flat([
                        DirectSumDecomposition(IdealNC( L, B1, "basis" )),
                        DirectSumDecomposition(IdealNC( L, B2, "basis" ))
                       ]);
          return ideals;

        fi;

      fi;

      # Now we assume that `L' does not have a central component
      # and compute the centralizer of `ad L' in `M_n(F)'.

      adL:= List( bvl, x -> AdjointMatrix( BL, x ) );
      centralizer:= FullMatrixAlgebraCentralizer( F, adL );
      Rad:= RadicalOfAlgebra( centralizer );
      if Dimension( centralizer ) - Dimension( Rad ) = 1 then
        return [ L ];
      fi;

      # We calculate a complete set of orthogonal primitive idempotents
      # in the Abelian algebra `centralizer/Rad'.

      hom:= NaturalHomomorphismByIdeal( centralizer, Rad );
      Q:= ImagesSource( hom );
      SetCentre( Q, Q );
      SetRadicalOfAlgebra( Q, Subalgebra( Q, [ Zero( Q ) ] ) );

      id:= List( CentralIdempotentsOfAlgebra( Q ),
                                x->PreImagesRepresentative(hom,x));

      # Now we lift the idempotents to the big algebra `A'. The
      # first idempotent is lifted as follows:
      # We have that `id[1]^2-id[1]' is an element of `Rad'.
      # We construct the sequences e_{i+1} = e_i + n_i - 2e_in_i,
      # and n_{i+1}=e_{i+1}^2-e_{i+1}, starting with e_0=id[1].
      # It can be proved by induction that e_q is an idempotent in `A'
      # because n_0^{2^q}=0.
      # Now `E' will be the sum of all idempotents lifted so far.
      # Then the next lifted idempotent is obtained by setting
      # `ei:=id[i]-E*id[i]-id[i]*E+E*id[i]*E;'
      # and lifting as above. It can be proved that in this manner we
      # get an orthogonal system of primitive idempotents.

      E:= Zero( F )*id[1];

      for i in [1..Length(id)] do
        ei:= id[i]-E*id[i]-id[i]*E+E*id[i]*E;
        q:= 0;
        while 2^q <= Dimension( Rad ) do
          q:= q+1;
        od;
        ni:= ei*ei-ei;
        for j in [1..q] do
          ei:= ei+ni-2*ei*ni;
          ni:= ei*ei-ei;
        od;
        id[i]:= ei;
        E:= E+ei;
      od;

      # For every idempotent of `centralizer' we calculate
      # a direct summand of `L'.

      ideals:= List( id, e -> List( TransposedMat( e ), v ->
                    LinearCombination( BL, v ) ) );
      ideals:= List( ideals, ii -> BasisVectors(
                        Basis( VectorSpace( F, ii ) ) ) );

      return List( ideals, ii ->
                     IdealNC( L, ii, "basis" ) );

    fi;

    end );



##############################################################################
##
#M  IsSimpleAlgebra( <L> )  . . . . . . . . . . . . . . . .  for a Lie algebra
##
##  A test whether <L> is simple.
##  It works only over fields of characteristic 0.
##
InstallMethod( IsSimpleAlgebra,
    "for a Lie algebra in characteristic zero",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )
    if Characteristic( LeftActingDomain( L ) ) <> 0 then
      TryNextMethod();
    elif DeterminantMat( KillingMatrix( Basis( L ) ) ) = 0 then
      return false;
    else
      return Length( DirectSumDecomposition( L ) ) = 1;
    fi;
    end );


##############################################################################
##
#F  FindSl2( <L>, <x> )
##
InstallGlobalFunction( FindSl2, function( L, x )

   local n,         # the dimension of `L'
         F,         # the field of `L'
         B,         # basis of `L'
         T,         # the table of structure constants of `L'
         xc,        # coefficient vector
         eqs,       # a system of equations
         i,j,k,l,   # loop variables
         cij,       # the element `T[i][j]'
         b,         # the right hand side of the equation system
         v,         # solution of the equations
         z,         # element of `L'
         h,         # element of `L'
         R,         # centralizer of `x' in `L'
         BR,        # basis of `R'
         Rvecs,     # basis vectors of `R'
         H,         # the matrix of `ad H' restricted to `R'
         e0,        # coefficient vector
         e1,        # coefficient vector
         y;         # element of `L'

    if not IsNilpotentElement( L, x ) then
      Error( "<x> must be a nilpotent element of the Lie algebra <L>" );
    fi;

    n:= Dimension( L );
    F:= LeftActingDomain( L );
    B:= Basis( L );
    T:= StructureConstantsTable( B );

    xc:= Coefficients( B, x );
    eqs:= NullMat( 2*n, 2*n, F );

    # First we try to find elements `z' and `h' such that `[x,z]=h'
    # and `[h,x]=2x' (i.e., such that two of the three defining equations
    # of sl_2 are satisfied).
    # This results in a system of `2n' equations for `2n' variables.

    for i in [1..n] do
      for j in [1..n] do
        cij:= T[i][j];
        for k in [1..Length(cij[1])] do
          l:= cij[1][k];
          eqs[i][l] := eqs[i][l] + xc[j]*cij[2][k];
          eqs[n+i][n+l]:= eqs[n+i][n+l] + xc[j]*cij[2][k];
        od;
      od;
      eqs[n+i][i]:= One( F );
    od;

    b:= [];
    for i in [1..n] do
      b[i]:= Zero( F );
      b[n+i]:= 2*One( F )*xc[i];
    od;

    v:= SolutionMat( eqs, b );

    if v = fail then
      # There is no sl_2 containing <x>.
      return fail;
    fi;

    z:= LinearCombination( B, v{ [   1 ..   n ] } );
    h:= LinearCombination( B, v{ [ n+1 .. 2*n ] } );

    R:= LieCentralizer( L, SubalgebraNC( L, [ x ] ) );
    BR:= Basis( R );
    Rvecs:= BasisVectors( BR );

    # `ad h' maps `R' into `R'. `H' will be the matrix of that map.

    H:= List( Rvecs, v -> Coefficients( BR, h * v ) );

    # By the proof of the lemma of Jacobson-Morozov (see Jacobson,
    # Lie Algebras, p. 98) there is an element `e1' in `R' such that
    # `(H+2)e1=e0' where `e0=[h,z]+2z'.
    # If we set `y=z-e1' then `x,h,y' will span a subalgebra of `L'
    # isomorphic to sl_2.

    H:= H+2*IdentityMat( Dimension( R ), F );
#T cheaper!

    e0:= Coefficients( BR, h * z + 2*z );
    e1:= SolutionMat( H, e0 );

    if e1 = fail then
      # There is no sl_2 containing <x>.
      return fail;
    fi;

    y:= z-LinearCombination(Rvecs,e1);

    return SubalgebraNC( L, [x,h,y], "basis" );
end );


#############################################################################
##
#M  SemiSimpleType( <L> )
##
##  This function works for Lie algebras over a field of characteristic not
##  2 or 3, having a nondegenerate Killing form. Such Lie algebras are
##  semisimple. They are characterized as direct sums of simple Lie algebras,
##  and these have been classified: a simple Lie algebra is either an element
##  of the "great" classes of simple Lie algebas (A_n, B_n, C_n, D_n), or
##  an exceptional algebra (E_6, E_7, E_8, F_4, G_2). This function finds
##  the type of the semisimple Lie algebra `L'. Since for the calculations
##  eigenvalues and eigenvectors of the action of a Cartan subalgebra are
##  needed, we reduce the Lie algebra mod p (if it is of characteristic 0).
##  The p may not divide the determinant of the matrix of the Killing form,
##  nor may it divide the last nonzero coefficient of a minimum polynomial
##  of an element of the basis of the Cartan subalgebra.
##
InstallMethod( SemiSimpleType,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local CartanInteger, # Function that computes the Cartan integer.
          bvl,           # basis vectors of a basis of `L'
          a,             # Element of `L'.
          T,S,S1,        # Structure constants tables.
          den,           # Denominator of a structure constant.
          denoms,        # List of denominators.
          i,j,k,         # Loop variables.
          scal,          # A scalar.
          K,             # A Lie algebra.
          BK,            # basis of `K'
          d,             # The determinant of the Killing form of `K'.
          p,             # A prime.
          H,             # Cartan subalgebra.
          s,             # An integer.
          mp,            # List of minimum polynomials.
          F,             # Field.
          bas,           # List of basis vectors.
          simples,       # List of simple subalgebras.
          types,         # List of the types of the elements of simples.
          I,             # An element of simples.
          BI,            # basis of `I'
          bvi,           # basis vectors of `BI'
          HI,            # Cartan subalgebra of `I'.
          rk,            # The rank of `I'.
          adH,           # List of adjoint matrices.
          R,             # Root system.
          basR,          # Basis of `R'.
          posR,          # List of the positive roots.
          fundR,         # A fundamental system.
          r,r1,r2,rt,    # Roots.
          Rvecs,         # List of root vectors.
          basH,          # List of basis vectors of a Cartan subalg. of `I'
          sp,            # Vector space.
          h,             # Element of a Cartan subalgebra of `I'.
          cf,            # Coefficient.
          issum,         # Boolean.
          CM,            # Cartan Matrix.
          endpts;        # The endpoints of the Dynkin diagram of `I'.

    if Characteristic( LeftActingDomain( L ) ) in [ 2, 3 ] then
       Info( InfoAlgebra, 1,
             "The field of <L> must not have characteristic 2 or 3." );
       return fail;
    fi;

    # The following function computes the Cartan integer of two roots
    # `r1' and `r2'.
    # If `s' and `t' are the largest integers such that `r1 - s*r2' and
    # `r1 + t*r2' are elements of the root system `R',
    # then the Cartan integer of `r1' and `r2' is `s-t'.

    CartanInteger := function( R, r1, r2 )

        local R1,s,t,rt;

        R1:= ShallowCopy( R );
        Add( R1, R[1]-R[1] );
        s:= 0;
        t:= 0;
        rt:= r1-r2;
        while rt in R1 do
          rt:= rt-r2;
          s:= s+1;
        od;

        rt:= r1+r2;
        while rt in R1 do
          rt:= rt+r2;
          t:= t+1;
        od;
        return s-t;
    end;

    # We test whether the Killing form of `L' is nondegenerate.

    d:= DeterminantMat( KillingMatrix( Basis( L ) ) );
    if IsZero( d ) then
      Info( InfoAlgebra, 1,
            "The Killing form of <L> is degenerate." );
      return fail;
    fi;

    # First we produce a basis of `L' such that the first basis elements
    # form a basis of a Cartan subalgebra of `L'. Then if `L' is defined
    # over a field of characteristic 0 we do the following. We
    # multiply by an integer in order to ensure that the structure
    # constants are integers.
    # Finally we reduce modulo an appropriate prime `p'.

    H:= CartanSubalgebra( L );
    rk:= Dimension( H );
    bas:= ShallowCopy( BasisVectors( Basis( H ) ) );
    sp:= MutableBasis( LeftActingDomain( L ), bas );
    k:= 1;
    bvl:= BasisVectors( Basis( L ) );
    while Length( bas ) < Dimension( L ) do
      a:= bvl[k];
      if not IsContainedInSpan( sp, a ) then
        Add( bas, a );
        CloseMutableBasis( sp, a );
      fi;
      k:= k+1;
    od;
    T:= StructureConstantsTable( BasisNC( L, bas ) );

    p:= Characteristic( LeftActingDomain( L ) );

    if p = 0 then

      denoms:=[];
      for i in [1..Dimension(L)] do
        for j in [1..Dimension(L)] do
          for k in [1..Length(T[i][j][2])] do
             den:= DenominatorRat( T[i][j][2][k] );
             if (den <> 1) and (not den in denoms) then
               Add( denoms, den );
             fi;
          od;
        od;
      od;

      if denoms <> [] then
        S:= EmptySCTable( Dimension( L ), 0, "antisymmetric" );
        scal:= Lcm( denoms );
        for i in [1..Dimension(L)] do
          for j in [1..Dimension(L)] do
            S[i][j]:= [T[i][j][1],scal*T[i][j][2]];
          od;
        od;
      else
        S:=T;
      fi;

      K:= LieAlgebraByStructureConstants( LeftActingDomain( L ), S );

      BK:= Basis( K );
      d:= DeterminantMat( KillingMatrix( BK ) );
      F:= LeftActingDomain( L );

# `mp' will be a list of minimum polynomials of basis elements of the
# Cartan subalgebra.

      mp:= List( BasisVectors( BK ){[1..rk]},
                 x -> CharacteristicPolynomial( F, F, AdjointMatrix( BK, x ) ) );
      mp:= List( mp, x -> x/Gcd( Derivative( x ), x ) );
      d:= d * Product( List( mp, p ->
                   CoefficientsOfLaurentPolynomial(p)[1][1] ) );
      p:= 5;
      s:=7;

      # We determine a prime `p>5' not dividing `d' and an integer `s'
      # such that the minimum polynomials of the basis elements
      # of the Cartan subalgebra will split into linear factors
      # over the field of `p^s' elements,
      # and such that `p^s<=2^16'
      # (the maximum size of a finite field in GAP).

      while p^s > 65536 do

        while d mod p = 0 do
          p:= NextPrimeInt( p );
        od;

        F:= GF( p );

        S1:= EmptySCTable( Dimension( K ), Zero( F ), "antisymmetric" );
        for i in [1..Dimension(K)] do
          for j in [1..Dimension(K)] do
            S1[i][j]:= [S[i][j][1], One( F )*List( S[i][j][2], x -> x mod p)];
          od;
        od;

        K:= LieAlgebraByStructureConstants( F, S1 );
        BK:= Basis( K );
        mp:= List( BasisVectors( BK ){[1..rk]},
                 x -> CharacteristicPolynomial( F, F, AdjointMatrix( BK, x ) ) );
        s:= Lcm( Flat( List( mp, p -> List( Factors( p ),
                           DegreeOfLaurentPolynomial ) )));

        if p=65521 then p:= 1; fi;

      od;

      if p = 1 then
        Info( InfoAlgebra, 1,
                "We cannot find a small modular splitting field for <L>" );

        return fail;
      fi;

    else

      # Here `L' is defined over a field of characteristic p>0. We determine
      # an integer `s' such that the Cartan subalgebra splits over
      # `GF( p^s )'.

      F:= LeftActingDomain( L );
      K:= LieAlgebraByStructureConstants( F, T );
      BK:= Basis( K );
      mp:= List( BasisVectors( BK ){[1..rk]},
               x -> CharacteristicPolynomial( F, F, AdjointMatrix( BK, x ) ) );
      s:= Lcm( Flat( List( mp, p -> List( Factors( p ),
                         DegreeOfLaurentPolynomial ) )));
      s:= s*Dimension( LeftActingDomain( L ) );
      if p^s > 2^16 then
        Info( InfoAlgebra, 1,
              "We cannot find a small modular splitting field for <L>" );

        return fail;
      fi;
      S1:= T;
    fi;

    F:= GF( p^s );
    K:= LieAlgebraByStructureConstants( F, S1 );

    # We already know a Cartan subalgebra of `K'.

    BK:= Basis( K );
    H:= SubalgebraNC( K, BasisVectors( BK ){ [ 1 .. rk ] }, "basis" );
    SetCartanSubalgebra( K, H );

    simples:= DirectSumDecomposition( K );

    types:= "";

    # Now for every simple Lie algebra in simples we have to determine
    # its type.
    # For Lie algebras not equal to B_l, C_l or E_6,
    # this is determined by the dimension and the rank.
    # In the other cases we have to examine the root system.

    for I in simples do

      if not IsEmpty( types ) then
        Append( types, " " );
      fi;

      HI:= Intersection2( H, I );
      rk:= Dimension( HI );

      if Dimension( I ) = 133 and rk = 7 then
        Append( types, "E7" );
      elif Dimension( I ) = 248 and rk = 8 then
        Append( types, "E8" );
      elif Dimension( I ) = 52 and rk = 4 then
        Append( types, "F4" );
      elif Dimension( I ) = 14 and rk = 2 then
        Append( types, "G2" );
      else
        if Dimension( I ) = rk^2 + 2*rk then
          Append( types, "A" ); Append( types, String( rk ) );
        elif Dimension( I ) = 2*rk^2-rk then
          Append( types, "D" ); Append( types, String( rk ) );
        elif Dimension( I ) = 10 then
          Append( types, "B2" );
        else

          # We now determine the list of roots and the corresponding
          # root vectors.
          # Since the minimum polynomials of the elements of the
          # Cartan subalgebra split completely,
          # after the call of DirectSumDecomposition,
          # the root vectors are contained in the basis of `I'.

          BI:= Basis( I );
          bvi:= BasisVectors( BI );
          adH:= List( BasisVectors(Basis(HI)), x->AdjointMatrix(BI,x));
#T  better!
          R:=[];
          Rvecs:=[];
          for i in [ 1 .. Dimension( I ) ] do
            rt:= List( adH, x -> x[i][i] );
            if not IsZero( rt ) then
              Add( R, rt );
              Add( Rvecs, bvi[i] );
            fi;
          od;

          # A set of roots `basR' is determined such that the set
          # { [x_r,x_{-r}] | r\in basR } is a basis of `HI'.

          basH:= [ ];
          basR:= [ ];
          sp:= MutableBasis( F, [], Zero(I) );
          i:= 1;
          while Length( basH ) < Dimension( HI ) do
            r:= R[i];
            k:= Position( R, -r );
            h:= Rvecs[i] * Rvecs[k];
            if not IsContainedInSpan( sp, h ) then
              Add( basH, h );
              CloseMutableBasis( sp, h );
              Add( basR, r );
            fi;
            i:= i+1;
          od;

          # `posR' will be the set of positive roots.
          # A root `r' is called positive if in the list
          # [ < r, basR[i] >, i=1...Length(basR) ] the first nonzero
          # coefficient is positive
          # (< r_1, r_2 > is the Cartan integer of r_1 and r_2).

          posR:= [ ];
          for r in R do
            if (not r in posR) and (not -r in posR) then
              cf:= 0;
              i:= 0;
              while cf = 0 do
                i:= i+1;
                cf:= CartanInteger( R, r, basR[i] );
              od;
              if 0 < cf then
                Add( posR, r );
              else
                Add( posR, -r );
              fi;
            fi;
          od;

          # A positive root is a fundamental root if it is not
          # the sum of two other positive roots.

          fundR:= [ ];
          for r in posR do
            issum:= false;
            for r1 in posR do
              for r2 in posR do
                if r = r1+r2 then
                  issum:= true;
                  break;
                fi;
              od;
              if issum then break; fi;
            od;
            if not issum then
              Add( fundR, r );
            fi;
          od;

          # `CM' will be the matrix of Cartan integers
          # of the fundamental roots.

          CM:= List( fundR,
                     ri -> List( fundR, rj -> CartanInteger( R, ri, rj ) ) );

          # Finally the properties of the endpoints determine
          # the type of the root system.

          endpts:= [ ];
          for i in [ 1 .. Length(CM) ] do
            if Number( CM[i], x -> x <> 0 ) = 2 then
              Add( endpts, i );
            fi;
          od;

          if Length( endpts ) = 3 then
            Append( types, "E6" );
          elif Sum( CM[ endpts[1] ] ) = 0 or Sum( CM[ endpts[2] ] ) = 0 then
            Append( types, "C" ); Append( types, String( rk ) );
          else
            Append( types, "B" ); Append( types, String( rk ) );
          fi;

        fi;
      fi;
    od;

    return types;
    end );


##############################################################################
##
#M  NonNilpotentElement( <L> )
##
InstallMethod( NonNilpotentElement,
    "for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local n,     # the dimension of `L'
          F,     # the field over which `L' is defined
          bvecs, # a list of the basisvectors of `L'
          D,     # a list of elements of `L', forming a basis of a nilpotent
                 # subspace
          sp,    # the space spanned by `D'
          r,     # the dimension of `sp'
          found, # a Boolean variable
          i, j,  # loop variables
          b, c,  # elements of `L'
          elm;   #

    # First rule out some trivial cases.
    n:= Dimension( L );
    if n = 1 or n = 0 then
      return fail;
    fi;

    F:= LeftActingDomain( L );
    bvecs:= BasisVectors( Basis( L ) );

    if Characteristic( F ) <> 0 then

      # `D' will be a basis of a nilpotent subalgebra of L.
      if IsNilpotentElement( L, bvecs[1] ) then
        D:= [ bvecs[1] ];
      else
        return bvecs[1];
      fi;

      # `r' will be the dimension of the span of `D'.
      # If `r = n' then `L' is nilpotent and hence does not contain
      # non nilpotent elements.
      r:= 1;

      while r < n do

        sp:= VectorSpace( F, D, "basis" );

        # We first find an element `b' of `L' that does not lie in `sp'.
        found:= false;
        i:= 2;
        while not found do
          b:= bvecs[i];
          if b in sp then
            i:= i+1;
          else
            found:= true;
          fi;
        od;

        # We now replace `b' by `b * D[i]' if
        # `b * D[i]' lies outside `sp' in order to ensure that
        # `[b,sp] \subset sp'.
        # Because `sp' is a nilpotent subalgebra we only need
        # a finite number of replacement steps.

        i:= 1;
        while i <= r do
          c:= b*D[i];
          if c in sp then
            i:= i+1;
          else
            b:= c;
            i:= 1;
          fi;
        od;

        if IsNilpotentElement( L, b ) then
          Add( D, b );
          r:= r+1;
        else
          return b;
        fi;

      od;

    else

      # Now `char F =0'.
      # In this case either `L' is nilpotent or one of the
      # elements $L.1, \ldots , L.n, L.i + L.j; 1 \leq i < j$
      # is non nilpotent.

      for i in [ 1 .. n ] do
        if not IsNilpotentElement( L, bvecs[i] ) then
          return bvecs[i];
        fi;
      od;

      for i in [ 1 .. n ] do
        for j in [ i+1 .. n ] do
          elm:= bvecs[i] + bvecs[j];
          if not IsNilpotentElement( L, elm ) then
            return elm;
          fi;
        od;
      od;

    fi;

    # A non nilpotent element has not been found,
    # hence `L' is nilpotent.
    return fail;

    end );

############################################################################
##
#M  PrintObj( <R> ) . . . . . . . . . . . . . . . . . . for a root system
##
InstallMethod( PrintObj,
        "for a root system",
        true, [ IsRootSystem ], 0,
        function( R )

        if HasCartanMatrix( R ) then
            Print("<root system of rank ",Length(SimpleSystem(R)),">");
        else
            Print("<root system>");
        fi;

end );


############################################################################
##
#M  \.( <R>, <name> ) . . . . . . . record component access for a root system
##
InstallMethod( \.,
        "for a root system and a record component",
        true, [ IsRootSystem, IsObject ], 0,
        function( R, name )

    name:= NameRNam( name );
    if name = "roots" then
        return Concatenation( PositiveRoots(R), NegativeRoots(R) );
    elif name = "rootvecs" then
        return Concatenation( PositiveRootVectors(R),
                       NegativeRootVectors(R) );
    elif name = "fundroots" then
        return SimpleSystem( R );
    elif name = "cartanmat" then
        return CartanMatrix(R);
    else
        TryNextMethod();
    fi;
end );


##############################################################################
##
#M  RootSystem( <L> ) . . . . . . . . . . . . . . . . . . .  for a Lie algebra
##
InstallMethod( RootSystem,
    "for a (semisimple) Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local F,          # coefficients domain of `L'
          BL,         # basis of `L'
          H,          # A Cartan subalgebra of `L'
          basH,       # A basis of `H'
          sp,         # A vector space
          B,          # A list of bases of subspaces of `L' whose direct sum
                      # is equal to `L'
          newB,       # A new version of `B' being constructed
          i,j,l,      # Loop variables
          facs,       # List of the factors of `p'
          V,          # A basis of a subspace of `L'
          M,          # A matrix
          cf,         # A scalar
          a,          # A root vector
          ind,        # An index
          basR,       # A basis of the root system
          h,          # An element of `H'
          posR,       # A list of the positive roots
          fundR,      # A list of the fundamental roots
          issum,      # A boolean
          CartInt,    # The function that calculates the Cartan integer of
                      # two roots
          C,          # The Cartan matrix
          S,          # A list of the root vectors
          zero,       # zero of `F'
          hts,        # A list of the heights of the root vectors
          sorh,       # The set `Set( hts )'
          sorR,       # The soreted set of roots
          R,          # The root system.
          Rvecs,      # The root vectors.
          x,y,        # Canonical generators.
          noPosR;     # Number of positive roots.

    # Let `a' and `b' be two roots of the rootsystem `R'.
    # Let `s' and `t' be the largest integers such that `a-s*b' and `a+t*b'
    # are roots.
    # Then the Cartan integer of `a' and `b' is `s-t'.
    CartInt := function( R, a, b )
       local s,t,rt;
       s:=0; t:=0;
       rt:=a-b;
       while (rt in R) or (rt=0*R[1]) do
         rt:=rt-b;
         s:=s+1;
       od;
       rt:=a+b;
       while (rt in R) or (rt=0*R[1]) do
         rt:=rt+b;
         t:=t+1;
       od;
       return s-t;
    end;

    F:= LeftActingDomain( L );

    if DeterminantMat( KillingMatrix( Basis( L ) ) ) = Zero( F ) then
      Info( InfoAlgebra, 1, "the Killing form of <L> is degenerate" );
      return fail;
    fi;


    # First we compute the common eigenvectors of the adjoint action of a
    # Cartan subalgebra `H'. Here `B' will be a list of bases of subspaces
    # of `L' such that `H' maps each element of `B' into itself.
    # Furthermore, `B' has maximal length w.r.t. this property.

    H:= CartanSubalgebra( L );
    BL:= Basis( L );
    B:= [ ShallowCopy( BasisVectors( BL ) ) ];
    basH:= BasisVectors( Basis( H ) );

    for i in basH do

      newB:= [ ];
      for j in B do

        V:= Basis( VectorSpace( F, j, "basis" ), j );
        M:= List( j, x -> Coefficients( V, i*x ) );
        facs:= Factors( PolynomialRing( F ), MinimalPolynomial( F, M ) );

        for l in facs do
          V:= NullspaceMat( Value( l, M ) );
          Add( newB, List( V, x -> LinearCombination( j, x ) ) );
        od;

      od;
      B:= newB;

    od;

    # Now we throw away the subspace `H'.

    B:= Filtered( B, x -> ( not x[1] in H ) );

    # If an element of `B' is not one dimensional then `H' does not split
    # completely, and hence we cannot compute the root system.

    for i in [ 1 .. Length(B) ] do
      if Length( B[i] ) <> 1 then
        Info( InfoAlgebra, 1, "the Cartan subalgebra of <L> in not split" );
        return fail;
      fi;
    od;

    # Now we compute the set of roots `S'.
    # A root is just the list of eigenvalues of the basis elements of `H'
    # on an element of `B'.

    S:= [];
    zero:= Zero( F );
    for i in [ 1 .. Length(B) ] do
      a:= [ ];
      ind:= 0;
      cf:= zero;
      while cf = zero do
        ind:= ind+1;
        cf:= Coefficients( BL, B[i][1] )[ ind ];
      od;
      for j in [1..Length(basH)] do
        Add( a, Coefficients( BL, basH[j]*B[i][1] )[ind] / cf );
      od;
      Add( S, a );
    od;

    Rvecs:= List( B, x -> x[1] );

    # A set of roots `basR' is calculated such that the set
    # { [ x_r, x_{-r} ] | r\in R } is a basis of `H'.

    basH:= [ ];
    basR:= [ ];
    sp:= MutableBasis( F, [], Zero(L) );
    i:=1;
    while Length( basH ) < Dimension( H ) do
      a:= S[i];
      j:= Position( S, -a );
      h:= B[i][1]*B[j][1];
      if not IsContainedInSpan( sp, h ) then
        CloseMutableBasis( sp, h );
        Add( basR, a );
        Add( basH, h );
      fi;
      i:=i+1;
    od;

    # A root `a' is said to be positive if the first nonzero element of
    # `[ CartInt( S, a, basR[j] ) ]' is positive.
    # We calculate the set of positive roots.

    posR:= [ ];
    i:=1;
    while Length( posR ) < Length( S )/2 do
      a:= S[i];
      if (not a in posR) and (not -a in posR) then
        cf:= zero;
        j:= 0;
        while cf = zero do
          j:= j+1;
          cf:= CartInt( S, a, basR[j] );
        od;
        if 0 < cf then
          Add( posR, a );
        else
          Add( posR, -a );
        fi;
      fi;
      i:=i+1;
    od;

    # A positive root is called simple if it is not the sum of two other
    # positive roots.
    # We calculate the set of simple roots `fundR'.

    fundR:= [ ];
    for a in posR do
      issum:= false;
      for i in [1..Length(posR)] do
        for j in [i+1..Length(posR)] do
          if a = posR[i]+posR[j] then
            issum:=true;
          fi;
        od;
      od;
      if not issum then
        Add( fundR, a );
      fi;
    od;

    # Now we calculate the Cartan matrix `C' of the root system.

    C:= List( fundR, i -> List( fundR, j -> CartInt( S, i, j ) ) );

    # Every root can be written as a sum of the simple roots.
    # The height of a root is the sum of the coefficients appearing
    # in that expression.
    # We order the roots according to increasing height.

    V:= BasisNC( VectorSpace( F, fundR ), fundR );
    hts:= List( posR, r -> Sum( Coefficients( V, r ) ) );
    sorh:= Set( hts );

    sorR:= [ ];
    for i in [1..Length(sorh)] do
      Append( sorR, Filtered( posR, r -> hts[Position(posR,r)] = sorh[i] ) );
    od;
    Append( sorR, -1*sorR );
    Rvecs:= List( sorR, r -> Rvecs[ Position(S,r) ] );

    # We calculate a set of canonical generators of `L'. Those are elements
    # x_i, y_i, h_i such that h_i=x_i*y_i, h_i*x_j = c_{ij} x_j,
    # h_i*y_j = -c_{ij} y_j for i \in {1..rank}

    x:= Rvecs{[1..Length(C)]};
    noPosR:= Length( Rvecs )/2;
    y:= Rvecs{[1+noPosR..Length(C)+noPosR]};
    for i in [1..Length(x)] do
        V:= VectorSpace( LeftActingDomain(L), [ x[i] ] );
        B:= Basis( V, [x[i]] );
        y[i]:= y[i]*2/Coefficients( B, (x[i]*y[i])*x[i] )[1];
    od;

    h:= List([1..Length(C)], j -> x[j]*y[j] );

    # Now we construct the root system, and install as many attributes
    # as possible. The roots are represented as lists [ \alpha(h_1),....
    # ,\alpha(h_l)], where the h_i form the `Cartan' part of the canonical
    # generators.

    R:= Objectify( NewType( NewFamily( "RootSystemFam", IsObject ),
                IsAttributeStoringRep and IsRootSystemFromLieAlgebra ),
                rec() );
    SetCanonicalGenerators( R, [ x, y, h ] );
    SetUnderlyingLieAlgebra( R, L );
    SetPositiveRootVectors( R, Rvecs{[1..noPosR]});
    SetNegativeRootVectors( R, Rvecs{[noPosR+1..2*noPosR]} );
    SetCartanMatrix( R, C );

    posR:= [ ];
    for i in [1..noPosR] do
        B:= Basis( VectorSpace( F, [ Rvecs[i] ] ), [ Rvecs[i] ] );
        posR[i]:= List( h, hj ->  Coefficients( B, hj*Rvecs[i] )[1] );
    od;

    SetPositiveRoots( R, posR );
    SetNegativeRoots( R, -posR );
    SetSimpleSystem( R, posR{[1..Length(C)]} );

    return R;

    end );


##############################################################################
##
#M  CanonicalGenerators( <R> ) . . . . for a root system from a Lie algebra
##
InstallMethod( CanonicalGenerators,
    "for a root system from a (semisimple) Lie algebra",
    true,
    [ IsRootSystemFromLieAlgebra ], 0,
    function( R )

    local   L, rank,  x,  y,  i,  V,  b,  c;

    L:= UnderlyingLieAlgebra( R );
    rank:= Length( CartanMatrix( R ) );
    x:= PositiveRootVectors( R ){[1..rank]};
    y:= NegativeRootVectors( R ){[1..rank]};
    for i in [1..Length(x)] do
        V:= VectorSpace( LeftActingDomain(L), [ x[i] ] );
        b:= Basis( V, [x[i]] );
        c:= Coefficients( b, (x[i]*y[i])*x[i] )[1];
        y[i]:= y[i]*2/c;
    od;

    return [ x, y, List([1..rank], j -> x[j]*y[j] ) ];

end );

#############################################################################
##
#M  ChevalleyBasis( <L> ) . . . . . . for a semisimple Lie algebra
##
InstallMethod( ChevalleyBasis,
        "for a semisimple Lie algebra with a split Cartan subalgebra",
        true, [ IsLieAlgebra ], 0,
        function( L )

    local   R,  n,  cg,  b1p,  b1m,  b2p,  b2m,  k,  r,  i,  r1,  pos,
            b1,  b2,  f,  cfs,  bHa,  posRV,  negRV,  x,  y,  ha,  cf,
            F,  T,  K,  B, BK;

    # We first calculate an automorphism `f' of `L' such that
    # F(L_{\alpha}) = L_{-\alpha}, and f(H)=H, and f acts as multiplication
    # by -1 on H. For this we take the canonical generators of `L',
    # map its `x'-part onto its `y' part (and vice versa), and map
    # the `h'-part on minus itself. The automorphism is determined by this.

    R:= RootSystem( L );
    n:= Length( PositiveRoots( R ) );
    cg:= CanonicalGenerators( R );

    b1p:= ShallowCopy( cg[1] ); b1m:= ShallowCopy( cg[2] );
    b2p:= ShallowCopy( cg[2] ); b2m:= ShallowCopy( cg[1] );

    k:= 1;
    while k <= n do
        r:= PositiveRoots( R )[k];
        for i in [1..Length( CartanMatrix( R ) )] do
            r1:= r + SimpleSystem( R )[i];
            pos:= Position( PositiveRoots( R ), r1 );
            if pos<>fail and not IsBound( b1p[pos] ) then

                b1p[pos]:= cg[1][i]*b1p[k];
                b1m[pos]:= cg[2][i]*b1m[k];
                b2p[pos]:= cg[2][i]*b2p[k];
                b2m[pos]:= cg[1][i]*b2m[k];
            fi;
        od;
        k:= k+1;
    od;

    b1:= b1p; Append( b1, b1m ); Append( b1, cg[3] );
    b2:= b2p; Append( b2, b2m ); Append( b2, -cg[3] );
    f:= LeftModuleHomomorphismByImages( L, L, b1, b2 );

    # Now for every positive root vector `x' we set `y= -Image( f, x )'.
    # We compute a scalar `cf' such that `[x,y]=h', where `h' is the
    # canonical Cartan element corresponding to the root (unquely determined).
    # Then we have to multiply `x' and `y' by Sqrt( 2/cf ), in order to get
    # elements of a Chevalley basis.

    cfs:= [ ];
    bHa:= [ ];
    posRV:= [ ];
    negRV:= [ ];
    for i in [1..n] do
        x:= PositiveRootVectors( R )[i];
        y:= -Image( f, x );
        ha:= x*y;
        cf:= Coefficients( Basis( VectorSpace( LeftActingDomain(L),
                     [x] ), [x] ), ha*x )[1];
        if i <= Length( CartanMatrix( R ) ) then Add( bHa, (2/cf)*ha ); fi;
        Add( cfs, Sqrt( 2/cf ) );
        posRV[i]:= x; negRV[i]:= y;
    od;

    # In general the `cfs' will lie in a field extension of the ground field.
    # We construct the Lie algebra over that field with the same structure
    # constants as `L'. Then we map the Chevalley basis elements into
    # this new Lie algebra. Then we take the structure constants table of
    # this new Lie algebra with respect to the Chevalley basis, and
    # form a new Lie algebra over the same field as `L' with this table.

    F:= DefaultField( cfs );
    T:= StructureConstantsTable( Basis( L ) );
    K:= LieAlgebraByStructureConstants( F, T );
    BK:= CanonicalBasis( K );
    B:= [ ];
    for i in [1..n] do
        B[i]:= LinearCombination( BK, cfs[i]*Coefficients( Basis(L),
                                                         posRV[i] ) );
        B[n+i]:= LinearCombination( BK, cfs[i]*Coefficients( Basis(L),
                                                         negRV[i] ) );
    od;
    for i in [1..Length(bHa)] do
        B[2*n+i]:= LinearCombination( BK, Coefficients( Basis(L),
                                                         bHa[i] ) );
    od;

    T:= StructureConstantsTable( Basis( K, B ) );
    K:= LieAlgebraByStructureConstants( LeftActingDomain(L), T );
    B:= BasisVectors( CanonicalBasis( K ) );

    # Now the basis elements of `K' form a Chevalley basis. Furthermore,
    # `K' is isomorphic to `L'. We construct the isomorphism, and map
    # the basis elements of `K' into `L', thus getting a Chevalley basis
    # in `L'.

    b1p:= B{[1..Length(CartanMatrix(R))]};
    b1m:= B{[n+1..n+Length(CartanMatrix(R))]};
    b2p:= ShallowCopy( cg[1] ); b2m:= ShallowCopy( cg[2] );

    k:= 1;
    while k <= n do
        r:= PositiveRoots( R )[k];
        for i in [1..Length( CartanMatrix( R ) )] do
            r1:= r + SimpleSystem( R )[i];
            pos:= Position( PositiveRoots( R ), r1 );
            if pos<>fail and not IsBound( b1p[pos] ) then

                b1p[pos]:= b1p[i]*b1p[k];
                b1m[pos]:= b1m[i]*b1m[k];
                b2p[pos]:= b2p[i]*b2p[k];
                b2m[pos]:= b2m[i]*b2m[k];
            fi;
        od;
        k:= k+1;
    od;

    b1:= b1p; Append( b1, b1m ); Append( b1, B{[2*n+1..Length(B)]} );
    b2:= b2p; Append( b2, b2m ); Append( b2, cg[3] );
    f:= LeftModuleHomomorphismByImages( K, L, b1, b2 );

    return [ List( B{[1..n]}, x -> Image( f, x ) ),
             List( B{[n+1..2*n]}, y -> Image( f, y ) ),
             cg[3] ];


    end);



#############################################################################
##
#F  DescriptionOfNormalizedUEAElement( <T>, <listofpairs> )
##
InstallGlobalFunction( DescriptionOfNormalizedUEAElement,
    function( T, listofpairs )

    local normalized,        # ordered list of normalized coeff./monom. pairs
          indices,           # list that stores at position $i$ up to what
                             # position the $i$-th monomial is known to be
                             # normalized
          s, i, j, k, l,     # loop variables
          2i,                # `2*i'
          scalar,            # coefficient of the monomial under work
          mon,               # monomial under work
          len,               # length of the monomial under work
          head,              # initial part of the monomial under work
          middle,            # middle part of the monomial under work
          tail,              # trailing part of the monomial under work
          index,             # new value of `indices[i]'
          Tcoeffs,           # one entry in `T'
          lennorm,           # length of `normalized' at the moment
          zero;              # zero coefficient

    normalized := [];

    while not IsEmpty( listofpairs ) do

      listofpairs:= Compacted( listofpairs );

      # `indices' is a list of positive integers $[ j_1, j_2, \ldots, j_m ]$
      # s.t. the initial part $x_{i_1}^{e_1} \cdots x_{i_{j_k}}^{e_{j_k}}$
      # of the $k$-th monomial is known to be normalized,
      # i.e., $i_1 < i_2 < \cdots < i_{j_k}$.
      # (So $j_k = 1$ for all $k$ will always be correct.)
      indices:= ListWithIdenticalEntries( Length( listofpairs )/2, 1 );

      # Loop over the monomials that shall be normalized.
      for i in [ 1, 2 .. Length( indices ) ] do

        # If the `i'-th monomial is already normalized,
        # put it into `normalized'.
        # Otherwise swap the first non-ordered generators.
        2i:= 2*i;
        scalar:= listofpairs[ 2i ];
        mon:= listofpairs[ 2i-1 ];
        len:= Length( mon );
        j:= 2 * indices[i] - 1;
        while j < len - 2 do

          if mon[j] < mon[ j+2 ] then

            # `mon' is better normalized than `indices' tells.
            j:= j+2;
            indices[i]:= indices[i] + 1;

          elif mon[j] = mon[ j+2 ] then

            # absorption
            mon[ j+1 ]:= mon[ j+1 ] + mon[ j+3 ];
            for k in [ j+2 .. len-2 ] do
              mon[k]:= mon[ k+2 ];
            od;
            Unbind( mon[  len  ] );
            Unbind( mon[ len-1 ] );
            len:= len - 2;

          else

            # We must swap two generators.
            # First construct head and tail of the arising monomials.
            head:= mon{ [ 1 .. j-1 ] };

            middle:= [ mon[ j+2 ], mon[j+3], mon[j], mon[j+1] ];

            tail:= mon{ [ j+4 .. len ] };

            # Adjust `indices[i]'.
            index:= indices[i] - 1;
            if index = 0 then
              index:= 1;
            fi;

            indices[i]:= index;

            # Replace the monomial by the swapped one.
            listofpairs[ 2i-1 ]:= Concatenation( head, middle, tail );

            # Add the coeffs/monomials that are given by the commutator.
            # The part between `head' and `tail' of these listofpairs is
            # $a_{ji}=\sum_{k=1}^d c_{ijk} x_d$.
            # Here we use the following formula (which is easily proved
            # by induction):
            #
            #  x_j^m x_i^n = x_i^n x_j^m + \sum_{l=0}^{m-1} \sum_{k=0}^{n-1}
            #                      x_j^l x_i^k a_{ji} x_i^{n-1-k} x_j^{m-1-l}
            #
            #
            # where x_jx_i = x_ix_j + a_{ji}
            #
            Tcoeffs:= T[ mon[j] ][ mon[ j+2 ] ];
            for s in [ 1 .. Length( Tcoeffs[1] ) ] do
                for l in [ 0 .. mon[j+1] - 1 ] do
                    for k in [ 0 .. mon[j+3] - 1 ] do

                        middle:= [ ];

                        if l > 0 then
                            middle:= [ mon[j], l ];
                        fi;
                        if k > 0 then
                            Append( middle, [ mon[j+2], k ] );
                        fi;
                        Append( middle, [ Tcoeffs[1][s], 1 ] );
                        if mon[j+3]-1-k > 0 then
                            Append( middle, [ mon[j+2], mon[j+3]-1-k ] );
                        fi;
                        if mon[j+1]-1-l > 0 then
                            Append( middle, [ mon[j], mon[j+1]-1-l ] );
                        fi;

                        Append( listofpairs,
                                [ Concatenation( head, middle, tail ),
                                  scalar * Tcoeffs[2][s] ] );
                        Add( indices, index );
                    od;
                od;
            od;

            break;

          fi;

        od;

        # If the monomial is normalized then move it to `normalized'.
        if len - 2 <= j then

          # Find the correct position in `normalized',
          # and insert the monomial.
          lennorm:= Length( normalized );
          k:= 2;
          while k <= lennorm do
            if listofpairs[ 2i-1 ] < normalized[ k-1 ] then
              for l in [ lennorm, lennorm-1 .. k-1 ] do
                normalized[l+2]:= normalized[l];
              od;
              normalized[ k-1 ]:= listofpairs[ 2i-1 ];
              normalized[  k  ]:= scalar;
              break;
            elif listofpairs[ 2i-1 ] = normalized[ k-1 ] then
              normalized[k]:= normalized[k] + scalar;
              break;
            fi;
            k:= k+2;
          od;
          if lennorm < k then
            normalized[ lennorm+1 ]:= listofpairs[ 2i-1 ];
            normalized[ lennorm+2 ]:= scalar;
          fi;

          # Remove the monomial from `listofpairs'.
          Unbind( listofpairs[ 2i-1 ] );
          Unbind( listofpairs[  2i  ] );

        fi;

      od;

    od;

    # Remove monomials with multiplicity zero;
    if not IsEmpty( normalized ) then
      zero:= Zero( normalized[2] );
      for i in [ 2, 4 .. Length( normalized ) ] do
        if normalized[i] = zero then
          Unbind( normalized[ i-1 ] );
          Unbind( normalized[  i  ] );
        fi;
      od;
      normalized:= Compacted( normalized );
    fi;

    # Return the normal form.
    return normalized;
end );


#############################################################################
##
#M  UniversalEnvelopingAlgebra( <L> ) . . . . . . . . . . . for a Lie algebra
##
InstallOtherMethod( UniversalEnvelopingAlgebra,
    "for a finite dimensional Lie algebra and a basis of it",
    true,
    [ IsLieAlgebra, IsBasis ], 0,
    function( L, B )

    local F,          # free associative algebra
          U,          # universal enveloping algebra, result
          gen,        # loop over algebra generators of `U'
          Fam,        # elements family of `U'
          T,          # s.c. table of a basis of `L'
          FamMon,     # family of monomials
          FamFree;    # elements family of `F'

    # Check the argument.
    if not IsFiniteDimensional( L ) then
      Error( "<L> must be finite dimensional" );
    fi;

    # Construct the universal enveloping algebra.
    F:= FreeAssociativeAlgebraWithOne( LeftActingDomain( L ),
            Dimension( L ), "x" );
    U:= FactorFreeAlgebraByRelators( F, [ Zero( F ) ] );
#T do not cheat here!

    # Enter knowledge about `U'.
    SetDimension( U, infinity );
    for gen in GeneratorsOfLeftOperatorRingWithOne( U ) do
      SetIsNormalForm( gen, true );
    od;
    SetIsNormalForm( Zero( U ), true );

    # Enter data to handle elements.
    Fam:= ElementsFamily( FamilyObj( U ) );
    Fam!.normalizedType:= NewType( Fam,
                                       IsElementOfFpAlgebra
                                   and IsPackedElementDefaultRep
                                   and IsNormalForm );

    T:= StructureConstantsTable( B );
    FamMon:= ElementsFamily( FamilyObj( UnderlyingMagma( F ) ) );
    FamFree:= ElementsFamily( FamilyObj( F ) );

    SetNiceNormalFormByExtRepFunction( Fam,
        function( Fam, extrep )
        local zero, i;
        zero:= extrep[1];
        extrep:= DescriptionOfNormalizedUEAElement( T, extrep[2] );
        for i in [ 1, 3 .. Length( extrep ) - 1 ] do
          extrep[i]:= ObjByExtRep( FamMon, extrep[i] );
        od;
        return Objectify( Fam!.normalizedType,
                   [ Objectify( FamFree!.defaultType, [ zero, extrep ] ) ] );
        end );

    SetOne( U, ElementOfFpAlgebra( Fam, One( F ) ) );

    # Enter `L'; it is used to set up the embedding (as a vector space).
    Fam!.liealgebra:= L;
#T is not allowed ...

    # Return the universal enveloping algebra.
    return U;
    end );

#T missing: embedding of the Lie algebra (as vector space)
#T missing: relators (only compute them if they are explicitly wanted)
#T          (attribute `Relators'?)

InstallMethod( UniversalEnvelopingAlgebra,
    "for a finite dimensional Lie algebra",
    true,
    [ IsLieAlgebra ], 0,
    function( L )

    return UniversalEnvelopingAlgebra( L, Basis(L) );
end );


#############################################################################
##
#F  IsSpaceOfUEAElements( <V> )
##
##  If <V> is a space of elements of a universal enveloping algebra,
##  then the `NiceFreeLeftModuleInfo' value of <V> is a record with the
##  following components.
##  \beginitems
##  `family' &
##     the elements family of <V>,
##
##  `monomials' &
##     a list of monomials occurring in the generators of <V>,
##
##
##  `zerocoeff' &
##     the zero coefficient of elements in <V>,
##
##  `zerovector' &
##     the zero row vector in the nice free left module,
##
##  `characteristic' &
##     the characteristic of the ground field.
##  \enditems
##  The `NiceVector' value of $v \in <V>$ is defined as the row vector of
##  coefficients of $v$ w.r.t. the list `monomials'.
##
##
DeclareHandlingByNiceBasis( "IsSpaceOfUEAElements",
    "for free left modules of elements of a universal enveloping algebra" );


#############################################################################
##
#M  NiceFreeLeftModuleInfo( <V> )
#M  NiceVector( <V>, <v> )
#M  UglyVector( <V>, <r> )
##
InstallHandlingByNiceBasis( "IsSpaceOfUEAElements", rec(
    detect := function( F, gens, V, zero )
      return IsElementOfFpAlgebraCollection( V );
      end,

    NiceFreeLeftModuleInfo := function( V )
      local gens,
            monomials,
            gen,
            list,
            zero,
            info;

      gens:= GeneratorsOfLeftModule( V );

      monomials:= [];

      for gen in gens do
        list:= ExtRepOfObj( gen )[2];
        UniteSet( monomials, list{ [ 1, 3 .. Length( list ) - 1 ] } );
      od;

      zero:= Zero( LeftActingDomain( V ) );
      info:= rec( monomials := monomials,
                  zerocoeff := zero,
                  characteristic:= Characteristic( LeftActingDomain( V ) ),
                  family    := ElementsFamily( FamilyObj( V ) ) );

      # For the zero row vector, catch the case of empty `monomials' list.
      if IsEmpty( monomials ) then
        info.zerovector := MakeImmutable([ zero ]);
      else
        info.zerovector := MakeImmutable(ListWithIdenticalEntries( Length( monomials ),
                                                             zero ) );
      fi;

      return info;
      end,

    NiceVector := function( V, v )
      local info, c, monomials, i, pos;
      info:= NiceFreeLeftModuleInfo( V );
      c:= ShallowCopy( info.zerovector );
      v:= ExtRepOfObj( v )[2];
      monomials:= info.monomials;
      for i in [ 2, 4 .. Length( v ) ] do
        pos:= Position( monomials, v[ i-1 ] );
        if pos = fail then
          return fail;
        fi;
        c[ pos ]:= v[i];
      od;
      return c;
      end,

    UglyVector := function( V, r )
      local info, list, i;
      info:= NiceFreeLeftModuleInfo( V );
      if Length( r ) <> Length( info.zerovector ) then
        return fail;
      elif IsEmpty( info.monomials ) then
        if IsZero( r ) then
          return Zero( V );
        else
          return fail;
        fi;
      fi;
      list:= [];
      for i in [ 1 .. Length( r ) ] do
        if r[i] <> info.zerocoeff then
          Add( list, info.monomials[i] );
          Add( list, r[i] );
        fi;
      od;
      return ObjByExtRep( info.family, [ info.characteristic, list ] );
      end ) );





#############################################################################
##
#F  FreeLieAlgebra( <R>, <rank> )
#F  FreeLieAlgebra( <R>, <rank>, <name> )
#F  FreeLieAlgebra( <R>, <name1>, <name2>, ... )
##
InstallGlobalFunction( FreeLieAlgebra, function( arg )

    local R,          # coefficients ring
          names,      # names of the algebra generators
          M,          # free magma
          F,          # family of magma ring elements
          one,        # identity of `R'
          zero,       # zero of `R'
          L;          # free Lie algebra, result


    # Check the argument list.
    if Length( arg ) = 0 or not IsRing( arg[1] ) then
      Error( "first argument must be a ring" );
    fi;

    R:= arg[1];

    # Construct names of generators.
    if   Length( arg ) = 2 and IsInt( arg[2] ) then
      names:= List( [ 1 .. arg[2] ],
                    i -> Concatenation( "x", String(i) ) );
      MakeImmutable( names );
    elif     Length( arg ) = 2
         and IsList( arg[2] )
         and ForAll( arg[2], IsString ) then
      names:= arg[2];
    elif Length( arg ) = 3 and IsInt( arg[2] ) and IsString( arg[3] ) then
      names:= List( [ 1 .. arg[2] ],
                    x -> Concatenation( arg[3], String(x) ) );
      MakeImmutable( names );
    elif ForAll( arg{ [ 2 .. Length( arg ) ] }, IsString ) then
      names:= arg{ [ 2 .. Length( arg ) ] };
    else
      Error( "usage: FreeLieAlgebra( <R>, <rank> )\n",
                 "or FreeLieAlgebra( <R>, <name1>, ... )" );
    fi;

    # Construct the algebra as magma algebra modulo relations
    # over a free magma.
    M:= FreeMagma( names );

    # Construct the family of elements of our ring.
    F:= NewFamily( "FreeLieAlgebraObjFamily",
                   IsElementOfMagmaRingModuloRelations,
                   IsJacobianElement and IsZeroSquaredElement );
    SetFilterObj( F, IsFamilyElementOfFreeLieAlgebra );

    one:= One( R );
    zero:= Zero( R );

    F!.defaultType := NewType( F, IsMagmaRingObjDefaultRep );
    F!.familyRing  := FamilyObj( R );
    F!.familyMagma := FamilyObj( M );
    F!.zeroRing    := zero;
#T no !!
    F!.names       := names;

    # Set the characteristic.
    if HasCharacteristic( R ) or HasCharacteristic( FamilyObj( R ) ) then
      SetCharacteristic( F, Characteristic( R ) );
    fi;


    # Make the magma ring object.
    L:= Objectify( NewType( CollectionsFamily( F ),
                                IsMagmaRingModuloRelations
                            and IsAttributeStoringRep ),
                   rec() );

    # Set the necessary attributes.
    SetLeftActingDomain( L, R );
    SetUnderlyingMagma(  L, M );

    # Deduce useful information.
    SetIsFiniteDimensional( L, false );
    if HasIsWholeFamily( R ) and HasIsWholeFamily( M ) then
      SetIsWholeFamily( L, IsWholeFamily( R ) and IsWholeFamily( M ) );
    fi;

    # Construct the generators.
    SetGeneratorsOfLeftOperatorRing( L,
        List( GeneratorsOfMagma( M ),
              x -> ElementOfMagmaRing( F, zero, [ one ], [ x ] ) ) );

    # Install grading
    SetGrading( L, rec( min_degree := 1,
                                      max_degree := infinity,
                                      source := Integers,
                                      hom_components := function(degree)
        local B, d, i, x, y, z;
        B := GeneratorsOfMagma(M);
        B := [List([1..Length(B)],i->[[i],fail,B[i]])];
        for d in [2..degree] do
            Add(B,[]);
            for i in [1..d-1] do
                for x in B[i] do for y in B[d-i] do
                    z := Concatenation(x[1],y[1]);
                    if z<y[1] and x[1]<y[1] and (x[2]=fail or x[2]>=y[1]) then
                        Add(B[d],[z,y[1],x[3]*y[3]]);

                    fi;
                od; od;
            od;
        od;
        if degree<1 then B := []; else B := B[degree]; fi;
        return FreeLeftModule( R, List( B,
                p->ElementOfMagmaRing( F, zero, [ one ], [ p[3] ] )), Zero(L));
    end) );
    # Return the ring.
    return L;
end );


#############################################################################
##
#M  NormalizedElementOfMagmaRingModuloRelations( <Fam>, <descr> )
##
##  <descr> is a list of the form `[ <z>, <list> ]', <z> being the zero
##  coefficient of the ring, and <list> being the list of monomials and
##  their coefficients.
##  This function returns the element described in <descr> expanded on
##  the Lyndon basis of the free Lie algebra. In order to do this we do not
##  need to know this basis; we only need a test whether something is a
##  Lyndon element (this is done in the function `IsLyndonT').
##  For the algorithm we refer to C. Reutenauer, Free Lie Algebras, Clarendon
##  Press, Oxford, 1993.
##
DeclareGlobalName( "IsLyndonT" );

BindGlobal( "IsLyndonT",
function( t )

    # This function tests whether the bracketed expression `t' is
    # a Lyndon tree.

    local w,w1,w2,b,y;

    if not IsList( t ) then return true; fi;

    w:= Flat( t );
    if IsList( t[1] ) then
        w1:= Flat( t[1] );
        b:= false;
    else
        w1:= [ t[1] ];
        b:=true;
    fi;
    if IsList( t[2] ) then
        w2:= Flat( t[2] );
    else
        w2:= [ t[2] ];
    fi;

    if w<w2 and w1<w2 then
        if not b then
            y:= Flat( [ t[1][2] ] );
            if y  < w2 then return false; fi;
        fi;
    else
        return false;
    fi;

    return IsLyndonT(t[1]) and IsLyndonT(t[2]);
end);

InstallMethod( NormalizedElementOfMagmaRingModuloRelations,
     "for family of free Lie algebra elements, and list",
     true,
     [ IsFamilyElementOfFreeLieAlgebra, IsList ], 0,
     function( Fam, descr )

         local todo,            #The list of elements that are to be expanded
               k,i,             #Loop variables
               z,s,u,v,x,y,w,   #Bracketed expressions (or `trees')
               cf,              #Coefficient
               found,           #Boolean
               ll,              #List
               zero,            #The zero element of the field
               tlist,           #List of elements of the free Lie algebra
               Dcopy;           #Two functions

         Dcopy:=function( l )

           if not IsList(l) then return ShallowCopy( l ); fi;
           return List( l, Dcopy );
         end;

         zero:= descr[1];
         todo:= [ ];
         i:= 1;

# Every element in `todo' has the following format: [ bool, cf, br ],
# where bool is a boolean; it is true if the br is a Lyndon tree.
# cf is the coefficient (number) and br is a bracketed expression.
# The reason for `tagging' everything is that almost anywhere in the
# list cancellations may occur. This tagging provides an efficient way
# of remembering which trees were dealt with before.

         while i+1 <= Length(descr[2]) do
           Add( todo, [ false, descr[2][i+1], ExtRepOfObj( descr[2][i] ) ] );
           i:= i+2;
         od;

         k:= 1;
         while k<=Length(todo) do

           s:= todo[k][3];
           cf:= todo[k][2];
           if not IsList( s ) then
             # `s' is a Lyndon tree
             todo[k][1]:= true;
             k:= k+1;
           elif cf = zero or s[1]=s[2] then
             # `s' is zero
             ll:=Filtered([1..Length(todo)], x -> x<> k);
             todo:= todo{ll};
           elif todo[k][1] then
             # we already dealt with `s'
             k:=k+1;
           elif IsLyndonT( s ) then
             # we do not need to expand `s'
             todo[k][1]:=true;
             k:=k+1;
           else
             #we expand `s'
             found:= false; u:=s;
             z:= Dcopy( s );
             v:= z;

             # we look for a subtree `u' such that is not a Lyndon tree
             # such that its left and right subtrees are Lyndon trees.

             while not found do
               if IsLyndonT(u[1]) then
                 if IsLyndonT(u[2]) then
                   found:=true;
                 else
                   u:= u[2]; v:=v[2];
                 fi;
               else
                 u:= u[1]; v:=v[1];
               fi;
             od;

             if u[1]=u[2] then
               # the whole expression `s' reduces to zero.
               ll:= Filtered([1..Length(todo)], x->x<>k);
               todo:= todo{ll};
             else
               if Flat([u[1]]) > Flat([u[2]]) then
                 # interchange u[1] and u[2]; this introduces a -.
                 w:=u[1];
                 u[1]:=u[2];
                 u[2]:=w;
                 i:= 1;
                 found:= false;
                 while i<= Length( todo ) and not found do
                   if todo[i][3] = s and k<>i then
                     todo[i][2]:= todo[i][2]-cf;
                     if todo[i][2] = zero then
                       ll:=Filtered([1..Length(todo)],x->(x<>k and x<>i ));
                     else
                       ll:=Filtered([1..Length(todo)],x->x<>k);
                     fi;
                     todo:= todo{ll};
                     found:= true;
                   fi;
                   i:=i+1;
                 od;
                 if not found then todo[k][2]:=-todo[k][2]; fi;
               else
                 #use the Jacobi identity.
                 x:=u[1][1];
                 y:=u[1][2];
                 w:= u[2];
                 u[1]:=[x,w];
                 u[2]:=y;

                 i:= 1;
                 found:= false;
                 while i<= Length( todo ) and not found do
                   if todo[i][3] = s and k<>i then
                     todo[i][2]:= todo[i][2]+cf;
                     if todo[i][2] = zero then
                       ll:=Filtered([1..Length(todo)],x->(x<>k and x<>i ));
                     else
                       ll:=Filtered([1..Length(todo)],x->x<>k);
                     fi;
                     todo:= todo{ll};
                     found:= true;
                   fi;
                   i:=i+1;
                 od;

                 x:=v[1][1];
                 y:=v[1][2];
                 w:=v[2];
                 v[1]:=x;
                 v[2]:=[y,w];

                 i:= 1;
                 found:= false;
                 while i<= Length( todo ) and not found do
                   if todo[i][3] = z then
                     todo[i][2]:= todo[i][2]+cf;
                     found:= true;
                   fi;
                   i:= i+1;
                 od;
                 if not found then
                   Add( todo, [false,cf,z] );
                 fi;
               fi;
               k:=1;
             fi;
           fi;
         od;

# wrap the list `todo' into an element of the free Lie algebra.

         todo:= List( todo, x -> [x[3],x[2]] );
         Sort( todo );
         tlist:= [];
         for i in [1..Length(todo)] do
           Append( tlist, todo[i] );
         od;

         return ObjByExtRep( Fam, [ zero, tlist ] );

     end );


##############################################################################
##
#M  ImageElm( <h>, <x> )
#M  ImagesRepresentative( <h>, <x> )
##
##  A special method for calculating the (unique) image of an element <x>
##  under an FptoSCAMorphism <h>. The fact that <h> knows the images of the
##  generators together with the fact that <h> is an algebra morphism is used
##  (rather than the linearity of <h>).
##
BindGlobal( "FptoSCAMorphismImageElm", function( h, x )
       local EvalProduct,imgs,im,e,k;

       EvalProduct:= function( prod, ims )

          if not IsList(prod) then
            return ims[prod];
          else
            return EvalProduct( prod[1], ims )*EvalProduct( prod[2], ims );
          fi;
       end;

       e:=MappingGeneratorsImages(h);
       imgs:= e[2];
       e:= ExtRepOfObj(x)[2];
       im:= 0*imgs[1];
       k:= 1;
       while k <= Length(e) do
         im:= im + e[k+1]*EvalProduct( e[k], imgs );
         k:= k+2;
       od;
       return im;
end );

InstallMethod( ImageElm,
    "for Fp to SCA mapping, and element",
    FamSourceEqFamElm,
    [ IsFptoSCAMorphism, IsElementOfFpAlgebra ], 0,
    FptoSCAMorphismImageElm );

InstallMethod( ImagesRepresentative,
    "for Fp to SCA mapping, and element",
    FamSourceEqFamElm,
    [ IsFptoSCAMorphism, IsElementOfFpAlgebra ], 0,
        FptoSCAMorphismImageElm );

###########################################################################
##
#M   PreImagesRepresentative( f, x )
##
InstallMethod( PreImagesRepresentative,
    "for Fp to SCA mapping, and element",
    FamRangeEqFamElm,
    [ IsFptoSCAMorphism, IsSCAlgebraObj ], 0,

    function( f, x )

    local   dim,  e,  gens,  imgs,  b1,  b2,  levs,
            brackets,  sp,  deg,  newlev,  newbracks,  d,  br1,  br2,
            i,  j,  a,  b,  c,  z,  imz,  cf;

    if not IsBound( f!.bases ) then

        # We find bases of the source and the range that are mapped to
        # each other.

        dim:= Dimension( Range(f) );
        e:=MappingGeneratorsImages(f);
        gens:= e[1];
        imgs:= e[2];
        b1:= ShallowCopy( gens );
        b2:= ShallowCopy( imgs );
        levs:= [ gens ];
        brackets:= [ [1..Length(gens)] ];
        sp:= MutableBasis( LeftActingDomain(Range(f)), b2 );
        deg:= 1;
        while Length( b1 ) <> dim do
            deg:= deg+1;
            newlev:= [ ];
            newbracks:= [ ];
            # get all Lyndon elements of degree deg:
            for d in [1..Length(brackets)] do
                if Length( b1 ) = dim then break; fi;
                br1:= brackets[d];
                br2:= brackets[deg-d];
                for i in [1..Length(br1)] do
                    if Length( b1 ) = dim then break; fi;
                    for j in [1..Length(br2)] do
                        if Length( b1 ) = dim then break; fi;
                        a:= br1[i]; b:= br2[j];
                        if IsLyndonT( [a,b] ) then
                            c:= [a,b];
                            z:= levs[d][i]*levs[deg-d][j];
                        elif IsLyndonT( [b,a] ) then
                            c:= [b,a];
                            z:= levs[deg-d][j]*levs[d][i];
                        else
                            c:= [ ];
                        fi;

                        if c <> [] then

                            imz:= Image( f, z );
                            if not IsContainedInSpan( sp, imz ) then
                                CloseMutableBasis( sp, imz );
                                Add( b1, z );
                                Add( newlev, z );
                                Add( newbracks, c );
                                Add( b2, imz );
                            fi;
                        fi;

                    od;
                od;
            od;
            Add( levs, newlev );
            Add( brackets, newbracks );
        od;

        f!.bases:= [ b1, Basis( Range(f), b2 ) ];
    fi;

    cf:= Coefficients( f!.bases[2], x );
    return cf*f!.bases[1];

end);

#############################################################################
##
#M  Dimension( <FpL> )
##
##  A method for the dimension of a finitely-presented Lie algebra.
##
InstallMethod( Dimension,
    "for a f.p. Lie algebra",
    true,
    [ IsLieAlgebra and IsSubalgebraFpAlgebra], 0,
    function( L )
      local h;
      h:= NiceAlgebraMonomorphism( L );
      if h <> fail then
        return Dimension( Range( h ) );
      else
        TryNextMethod();
      fi;
end);


##############################################################################
##
#M  IsFiniteDimensional( <FpL> )
##
##  For finitely-presented Lie algebras.
##
InstallMethod( IsFiniteDimensional,
    "for a f.p. Lie algebra",
    true,
    [ IsLieAlgebra and IsSubalgebraFpAlgebra], 0,
    function( L )
      local h;
      h:= NiceAlgebraMonomorphism( L );
      if h <> fail then
        return Dimension( Range( h ) ) < infinity;
      else
        TryNextMethod();
      fi;
end);

##############################################################################
##
##     FpLieAlgebraEnumeration( <arg> )                   Juergen Wisliceny
##                                                        Willem de Graaf
##
## This function calculates a homomorphism of a finitely presented
## Lie algebra onto a structure constants algebra.
## The algorithm is guaranteed to terminate when the algebra is finite
## dimensional. In full length the list <arg> contains `FpL', a
## finitely presented Lie algebra, `MAX_WEIGHT', a bound on the length
## of the monomials (used for nilpotent quotients), `weights' (a list
## of weights of the variables) and finally a boolean indicating
## whether the relations are homogeneous (if so then the nilpotent
## quotient will be graded, the grading is set as an attribute of the
## range of the homomorphism).
##
## By a straightforward application of the Jacobi identity (see also the
## comments to the sub-function `LeftNormalization'), it can be seen that
## the space of all commutators of degree `n' is spanned by all left
## normed commutators (i.e., commutators of the form [[[[a,b],c],d]...]).
## By antisymmetry we have that a and b can be chosen such that a > b.
## This is the format for elements of the free Lie algebra used in the
## program. A left-normed commutator is represented by a list
## `[a,b,c,d,..]', meaning `[[[[a,b],c],d]...]'. A monomial is such a list
## together with a coefficient, e.g., `[ [a,b,c,d..], -2/3 ]'. Finally, a
## polynomial is a list of monomials.

InstallGlobalFunction( FpLieAlgebraEnumeration,

     function( arg )

local ReductionModuloTable,   #
      LeftNormalization,      #
      SubsVarInRels,          #
      CollectPolynomial,      #    Sub-functions.
      UpdateTable,            #
      RemoveComm,             #
      RemoveEntry,            #
      SubstituteVariable,     #
      Dcopy,                  #
      gradorder,              #
      grado,                  #

      vg,                     # List of pairs (newly defined commutators)
      i,j,k,l,s,              # Loop variables.
      end_reached,            #
      table_init,             #    Booleans
      relation_found,         #
      u,v,rr,                 # Lists of relations.
      r,u1,r1,r2,k1,k2,k11,   # Polynomials, monomials etc.
      S,_T,                   # Structure constants tables.
      rowS,                   # A row of the multiplication table.
      sij,tij,                # Entries of the multiplication table.
      inds,                   # Indices (list of integers).
      tab_pols,               # List of polynomials of degree two.
      intrel,                 # Initial relations (after first conversion).
      pp,                     # Ext rep of a polynomial.
      cf,                     # Coefficient.
      t1,t2,                  # Indices.
      max,                    # Maximum.
      R,                      # Lists of commtators that have been defined.
      Rw1,                    # A new roe of `R'.
      one,                    # One of the field.
      zero,                   # Zero of the field.
      d,                      # maximum of the list of (pseudo-)generators
      e,                      # Flat(e) is the list of (pseudo-)generators
      w,ww,                   # Weights.
      temp,
      defs,                   # Definitions of generators in terms of other
                              # generators.
      FL,                     # The free Lie algebra.
      rels,                   # Relators.
      bound,                  # Bound for `w'.
      gens,                   # Generators of `FpL'.
      imgs,                   # Images.
      map,                    # The map that is constructed.
      im,                     # An image.
      Fam,                    # Elements family of `FpL'.
      K,                      # Structure constants algebra.
      FpL,wts,wght,pos,fle,weight,MAX_WEIGHT,genweights,comp_grad,is_hom,
      bas,gradcomps,degs,bgc;

   FpL:= arg[1];
   if Length( arg ) >= 2 then
     MAX_WEIGHT:= arg[2];
   else
     MAX_WEIGHT:= infinity;
   fi;

   Fam:= ElementsFamily( FamilyObj( FpL ) );
   FL:= Fam!.freeAlgebra;
   rels:= Fam!.relators;

   if Length( arg ) >= 3 then
     genweights:= arg[3];
   else
     genweights:= List( GeneratorsOfAlgebra( FL ), x -> 1 );
   fi;

   if Length( arg ) = 4 then
     is_hom:= arg[4];
   else
     is_hom:= false;
   fi;

   bound:= infinity;

   _T:=[];
   one:= One( LeftActingDomain( FL ) );
   zero:= Zero( LeftActingDomain( FL ) );

# Some small functions.....

   Dcopy:= function( l )

     # Deep copying, also copying the holes...

     local m,i;

     if not IsList(l) then return ShallowCopy(l); fi;
     m:=[];
     for i in [1..Length(l)] do
       if IsBound(l[i]) then m[i]:= Dcopy(l[i]); fi;
     od;
     return m;
   end;


##############################################################
##############################################################
# v, w are associative monomials. is v>w?
##
##  v > w if and only if 1) Length(v)>Length(w) or
##                       2) Length(v)=Length(w) and Length(v) > 1 and
##                          v[2] > w[2] or
##                       3) Length(v)=Length(w) and v[2]=w[2] and
##                          v>w alphabetically.
##

   gradorder:=function(v,w)
     local k,l;

     k:=Length(v[1]); l:=Length(w[1]);
     if k<>l then return k>l;
     elif k>1 and v[1][2]<>w[1][2] then return v[1][2]>w[1][2];
     else return v>w;
     fi;

   end;

   grado:= function( v, w )
   # tries to mimic gradorder for monomials of deg 2.

     if v[2]<>w[2] then return v[2]>w[2];
                   else return v>w;
     fi;
   end;



########################################################################

   CollectPolynomial:= function( r )

     # A function that collects equal things together, and gets rid of
     # things in the polynomial r that are zero.

     local i,n,t;

     if r <> [ ] then

       # first regularize...
       for i in r do
         if Length(i[1])>1 and i[1][1]<i[1][2] then
           t:=i[1][2]; i[1][2]:=i[1][1]; i[1][1]:=t;
           i[2]:=-i[2];
         fi;
       od;

       Sort( r, gradorder );
       n:= Length( r );

       for i in [1..n-1] do
         if r[i][2]=0*r[i][2] or
                    (Length(r[i][1])>1 and r[i][1][1]=r[i][1][2]) then

           #the thing is zero; get rid of it.

           Unbind(r[i]);
         elif r[i][1] = r[i+1][1] then

           #the monomials are equal; collect them together.

           r[i+1][2]:=r[i][2]+r[i+1][2];
           Unbind(r[i]);
         fi;
       od;
       if r[n][2]=0*r[n][2] or
               (Length(r[n][1])>1 and r[n][1][1]=r[n][1][2]) then

          #the thing is zero; get rid of it.

          Unbind(r[n]);
       fi;
       r:= Compacted( r );

     fi;

     return r;

   end;


   ReductionModuloTable := function( k )

     # In this function a Lie polynomial `k' in standard form is
     # reduced by one step modulo the commutators already known by the
     # table. So if [x_i,x_j]= c*z is a relation in the table, and `k'
     # contains a monomial of the form [ [i,j,k,....], cf ] then this
     # monomial is replaced by [ [z,k,...], -c*cf ]

     local i,j,k1,l,m,tst,t,s,cf,p,q,a;

     a:= Dcopy( k );
     for i in [1..Length(a)] do
       l:=Length(a[i][1]);
       if l>1 then
         s:= a[i][1][1]; t:=a[i][1][2];
         if s < t then
           p:= t; q:= s;
         else
           p:=s; q:=t;
         fi;
         if IsBound( _T[p] ) and IsBound( _T[p][q] ) then
           k1:= [ ];
           tst:= _T[p][q];
           if s <> p then cf:= -1;
                     else cf:= 1;
           fi;
           for j in [1..Length(tst[1])] do
             Add( k1, [[tst[1][j]], cf*a[i][2]*tst[2][j]] );
           od;
           if l>2 then
             m:=a[i][1]{[3..l]};
             for j in [1..Length(k1)] do
               Append(k1[j][1],m);
             od;
           fi;
           Unbind(a[i]);
           Append(a,k1);
         fi;
       fi;
     od;
     a:=Compacted(a);
     a:= CollectPolynomial( a );

     if a = [ ] or a[1][2] = one then
       return a;

     else
       cf:= 1/a[1][2];
       return List( a, x -> [x[1],x[2]*cf] );
     fi;
   end;

   LeftNormalization:= function( rel )

     # a left-normed monomial is of the form
     #
     #      [a,b,c,d,e,...], meaning [[[[[a,b],c],d],e],...]
     #
     # Using the Jacobi identity every commutator can be represented
     # as a linear combination of left-normed commutators.
     #
     # In this function a polynomial `rel' is left normed.
     # The Jacobi identity is applied successively to achieve this.
     # This means that an expression of the form
     #
     #    [a,b,c,[d,e],f] (where a,b,c are generators (this part is already
     #     `done') and [d,e] is any bracketed expression having d and e as
     #     left and right subtrees,
     #
     # to a sum
     #
     #     [a,b,c,d,e,f] - [a,b,c,e,d,f].
     #
     # Justification:
     #
     #     [a,b,c,[d,e]]=[[[a,b],c],[d,e]] = [X,[d,e]] (with X=[[a,b],c])
     #                  =-[d,[e,X]]-[e,[X,d]]
     #                  =[[e,X],d]+[[X,d],e]
     #                  =-[[X,e],d]+[[X,d],e].
     #


     local i,j,s,s1,s2,t,step_occurred;

     step_occurred:= true;
     while step_occurred do

       # if there no longer occur any Jacobi steps, then we stop.

       i:=0;
       step_occurred:= false;
       while i < Length( rel ) do
         i:=i+1; j:=0;
         while j<Length(rel[i][1]) and not step_occurred do
           j:=j+1;
           if IsList(rel[i][1][j]) and Length(rel[i][1][j])=2 then
             step_occurred:= true;
             s:=rel[i][1]{[1..j-1]}; #i.e., the part already done (the X)
             s1:=Concatenation(s,rel[i][1][j]);
             s2:=Concatenation(s,[rel[i][1][j][2],rel[i][1][j][1]]);
             t:=rel[i][1]{[j+1..Length(rel[i][1])]};
             Append(s1,t); Append(s2,t);
             rel[i][1]:=Dcopy(s1);

             # If j=1 (so if the tree starts with [x,y], then we didn't do
             # much other than changing the notation ([[x,y],b] -> [x,y,b]).

             if j>1 then Add(rel,[s2,-rel[i][2]]); fi;
           fi;
         od;
       od;
     od;
     return rel;
   end;

   SubsVarInRels:= function( rels, rs )

     # Here `rs' is a relation of the form `var = othervars', and `rels' is
     # a list of Lie polynomials. This function substitutes `var'
     # everywhere in the polynomials `rels'.

     local i,j,p,s,s1,s2,result,rel,cf;

     result:= [ ];

     for rel in rels do

       i:= 1;
       while i <= Length(rel) do

         p:= Position( rel[i][1], rs[1][1][1] );
         if p <> fail then

           # s will be the polynomial that is gotten from r by substituting
           # `the rest of rs' for the variable rs[1][1][1] on the position p
           # in r.

           s:= Dcopy( rs{[2..Length(rs)]} );
           s1:= rel[i][1]{[1..p-1]};
           s2:= rel[i][1]{[p+1..Length(rel[i][1])]};
           for j in [1..Length(s)] do
             s[j][1]:=Concatenation(s1,s[j][1],s2);
           od;
           s:= List( s, x -> [ x[1], -rel[i][2]*x[2] ] );
           Append( rel, s );
           Unbind( rel[i] );
           rel:= Compacted( rel );

         else
           i:= i+1;
         fi;

       od;

       #collect the result...

       rel:= CollectPolynomial( rel );
       if rel <> [ ] and rel[1][2] <> one then
         cf:= 1/rel[1][2];
         rel:= List( rel, x -> [x[1],cf*x[2]] );
       fi;
       if rel <> [ ] then AddSet( result, rel ); fi;

     od;
     return result;
   end;

   UpdateTable:= function( i, j, p )

     # Sets the commutator [xi,xj] in the table equal to the polynomial `p'.

     local inds,cfs,k,s,t;

     inds:=[];
     cfs:=[];
     for k in [1..Length(p)] do
       inds[k]:= p[k][1][1];
       cfs[k]:=  p[k][2];
    od;
     if i < j then
       s:= j; t:= i;
     else
       s:=i; t:= j;
     fi;

     if s = i then cfs:= -cfs; fi;
     if not IsBound(_T[s]) then _T[s]:=[]; fi;
      _T[s][t]:= [inds,cfs];

   end;

   RemoveEntry:= function( k )

     # Removes all occurrences of the variable xk in the commutators
     # of the table.

     local i;

     Unbind(_T[k]);
     for i in [1..Length(_T)] do
       if IsBound( _T[i] ) then Unbind(_T[i][k]); fi;
     od;
   end;

   RemoveComm:= function( k, l )

     # Removes the commutator [xk,xl] from the table.

      local s,t;
      s:= Maximum( k, l ); t:= Minimum( k, l );
      if IsBound(_T[s][t]) then Unbind(_T[s][t]); fi;
   end;

   SubstituteVariable:= function( coms, rel )

     # Here `rel' is a polynomial of the form `var = othervars'; this
     # function substitutes `var' for `othervar' in the commutators of
     # the table prescribed by `coms'.

     local var,inds,i,cfs,c,Tij,pos,cf,ii,cc,ind,s,t;

     var := rel[1][1][1];
     inds:= [ ]; cfs:= [ ];
     for i in [2..Length(rel)] do
       Add( inds, rel[i][1][1] );
       Add( cfs, -rel[i][2] );
     od;
     cfs:= cfs/rel[1][2];

     for c in coms do

       s:= Maximum( c ); t:= Minimum( c );
       Tij:= _T[s][t];
       pos:= Position( Tij[1], var );
       if pos <> fail then
         Remove( Tij[1], pos );
         cf:= Tij[2][pos];
         if s <> c[1] then cf:= -cf; fi;
         Remove( Tij[2], pos );
         Append( Tij[1], inds );
         Append( Tij[2],  cf*cfs );
         ii:= [ ]; cc:= [ ];
         if Tij[1] <> [ ] then
           SortParallel( Tij[1], Tij[2] );
           ind:= Tij[1][1]; cf:= Tij[2][1];
           ii:= [ ]; cc:= [ ];
           for i in [2..Length(Tij[1])] do
             if Tij[1][i] = ind then
               cf:= Tij[2][i] + cf;
             else
               Add( ii, ind );
               Add( cc, cf );
               ind:= Tij[1][i];
               cf:= Tij[2][i];
             fi;
           od;
           Add( ii, ind ); Add( cc, cf );
         fi;
         _T[s][t]:= [ ii, cc ];
       fi;

     od;

   end;

   wght:= function( e, wts, var )

      local p,q;

      p:= PositionProperty( e, x -> var in x );
      q:= Position( e[p], var );

      return wts[p][q];
   end;

##############################################################################
#
# The program starts. First the relations are transformed into internal format.
# That is: represented as lists of lists etc., and left-normalized.
#

   # `intrel' will be the set of relations, but represented in
   # `internal form'; meaning [ [ [[1,2],3], 1 ], [[4],-1] ], instead
   # of (x1*x2)*x3-x4 etc.

   intrel:= [ ];
   for r in rels  do
     pp:= Dcopy( ExtRepOfObj( r )[2] );
     Add( intrel, List( [1,3..Length(pp)-1], x -> [ pp[x], pp[x+1] ] ) );
   od;

#############################################################################
   # now we left normalize the relations, using `LeftNormalization', i.e.,
   # the relations are written as [ [ [1,2,5], -1], [.....], [......],.... ]
   # furthermore, all relations of degree at most two will go into `pr'
   # (those will be used to initialize the table). All the others go into
   # `u'.

   tab_pols:= [ ]; u:= [ ];

   for r in intrel do
     max:= 0;
     for j in [1..Length(r)] do
       if not IsList(r[j][1]) then  #transform [ i, cst ] into [ [i], cst ]
         r[j][1]:= [ r[j][1] ];
       fi;
       if Length(Flat(r[j][1])) >= 2 and r[j][1][1]=r[j][1][2] then
         Unbind(r[j]);
       else
         max:= Maximum( max, Length( Flat(r[j][1]) ) );
       fi;
     od;
     r:= Compacted( r );
     r:= LeftNormalization( r );
     r:= CollectPolynomial( r );
     if not max = 0 then
       if max <= 2 then
         cf:= 1/r[1][2];
         r:= List( r, x -> [x[1],cf*x[2]] );
         Add( tab_pols, r);             # So if the relation only
                                        # involves monomials of deg
                                        # at most two, then this relation
                                        # goes into the 'tab_pols'.
       else
         Add( u, r );
       fi;
     fi;
   od;

   e:= [ List( [1..Length( GeneratorsOfAlgebra( FL ) )], x -> x ), [ ] ];
   if MAX_WEIGHT < infinity then
     wts:= [ genweights, [] ];
     comp_grad:= true;
   else
     wts:= [ ];
     comp_grad:= false;
   fi;

   if e[1] = [ ] then
     K:= LieAlgebraByStructureConstants( LeftActingDomain( FL ),
                  EmptySCTable( 0, zero, "antisymmetric" ) );
     gens:= GeneratorsOfAlgebra( FpL );
     imgs:= List( gens, x -> Zero( K ) );
     map:= Objectify( TypeOfDefaultGeneralMapping( FpL, K,
                               IsSPGeneralMapping
                           and IsAlgebraGeneralMapping
                           and IsFptoSCAMorphism
                           and IsAlgebraGeneralMappingByImagesDefaultRep ),
                       rec(
                            generators := gens,
                            genimages  := imgs
                           ) );
     SetMappingGeneratorsImages(map,[Immutable(gens),Immutable(imgs)]);
     return map;
   fi;

   # `v' will be a history of relations, i.e., `v[w]' will be the relations
   # as they were when the program was dealing with weight `w'. This is
   # used to reset the relations if a collision among variables is found.

   v:= [ Dcopy( u ) ];
   d:= Maximum( e[1] );
   R:= [ [], [] ];
   end_reached:= false;
   w:= 0;
   defs:= [ ];

   while w < bound do

     table_init:= false;

     while not table_init do

#######################################################################
# Initialize the table....
# Meaning: fill in all possible commutators of generators using the
# relations, make definitions for the commutators that cannot be decided
# upon by using the relations. If this leads to a relation among the variables,
# then that relation is substituted first, and the process is started all
# over again.

       relation_found:= false;

       for r in tab_pols do

         r1:= ReductionModuloTable( r );
         if r1<>[] then

           if Length(r1[1][1])=1 then
             relation_found:= true;
             break;
           else
             for k in [2..Length(r1)] do
               if Length(r1[k][1])=2 then
                 d:=d+1;
                 Add(e[2],d);
                 if comp_grad then
                   Add(wts[2],wght(e,wts,r1[k][1][1])+
                                               wght(e,wts,r1[k][1][2]) );
                 fi;
                 UpdateTable( r1[k][1][1], r1[k][1][2], [ [[d],-one] ] );
                 Add(R[2],r1[k][1]);
                 r1[k][1]:=[d];
               fi;
             od;
             UpdateTable( r1[1][1][1], r1[1][1][2], r1{[2..Length(r1)]} );
           fi;
           Add(R[2],r1[1][1]);

         fi;
       od;

       if not relation_found then

         # i.e., the previous loop has been executed without breaking
         # caused by finding a relation among the generators.

         vg:=Difference( List( Combinations(e[1],2), Reversed ), R[2] );
         Append( R[2], vg  );
         for i in [1..Length(vg)] do
           d:=d+1;
           Add(e[2],d);
           if comp_grad then
             Add(wts[2],wght(e,wts,vg[i][1])+wght(e,wts,vg[i][2]));
           fi;
           UpdateTable( vg[i][1], vg[i][2], [ [[d],-one] ] );
         od;

         rr:= [ ];
         for i in [1..Length(u)] do
           r:= Dcopy( u[i] );
           while true do
             r1:= ReductionModuloTable( r );
             if r1 = r then break;
                       else r:= r1;
             fi;
           od;
           if r <> [ ] then
             if Length(r[1][1]) = 1 and r[1][1][1] in e[1] then
               relation_found:= true;
               break;
             else
               Add( rr, r );
             fi;
           fi;
         od;
       fi;

       if relation_found then

         # i.e., a relation among the variables has been found in the
         # previous piece of code.

         w:= Position( List( e, x -> r1[1][1][1] in x ), true );
         if w = 1 then
           if comp_grad then
             pos:= Position( e[1], r1[1][1][1] );
             Remove( wts[1], pos );
             Remove( e[1], pos);
         else
             RemoveSet( e[1], r1[1][1][1] );
         fi;

           Add( defs, r1 );
           if e[1] = [ ] then
             K:= LieAlgebraByStructureConstants( LeftActingDomain( FL ),
                      EmptySCTable( 0, zero, "antisymmetric" ) );
             gens:= GeneratorsOfAlgebra( FpL );
             imgs:= List( gens, x -> Zero( K ) );
             map:= Objectify( TypeOfDefaultGeneralMapping( FpL, K,
                                  IsSPGeneralMapping
                              and IsAlgebraGeneralMapping
                              and IsFptoSCAMorphism
                              and IsAlgebraGeneralMappingByImagesDefaultRep ),
                          rec(
                              generators := gens,
                              genimages  := imgs
                             ) );
             SetMappingGeneratorsImages(map,[Immutable(gens),Immutable(imgs)]);
             return map;
           fi;
           e[2]:= [ ];
           if comp_grad then
             wts[2]:= [ ];
           fi;
           tab_pols:= SubsVarInRels( tab_pols, r1 );
           u:= SubsVarInRels( u, r1 );
           _T:= [ ];
           R:= [ [], [] ];
         else
           if comp_grad then
             pos:= Position( e[w], r1[1][1][1] );
             Remove( wts[w], pos );
             Remove( e[w], pos);
         else
             RemoveSet( e[w], r1[1][1][1]);
         fi;

           u:= SubsVarInRels( v[w-1], r1 );
           SubstituteVariable( R[w], r1 );
         fi;

       else
         u:= rr;
         table_init:= true;
       fi;

     od;


##########################################################################
#
#  The table has been initialized, and the commutators of weight 2
#  have been defined. Now the process of increasing the weight starts.
#

     w:=1;
     while w < bound do

       w:=w+1;
       Sort( R[w], grado );

       if comp_grad then
         fle:= Flat(e);
         for i in [1..Length(fle)] do
           for j in [i+1..Length(fle)] do
             if wght(e,wts,fle[i])+wght(e,wts,fle[j])>MAX_WEIGHT then
               UpdateTable( fle[i], fle[j], [] );
             fi;
           od;
         od;
       fi;

#############################################################################
# reduction modulo relations and Jacobi identity....
#
# In this function also _T is changed; but if the function
# exits with a relation among the vars, then we change `_T' back to its
# old value (the copy `S').
#

       S:= Dcopy( _T );
       rr:= Dcopy( u );
       Rw1:= [ ];
       e[w+1]:= [ ];
       if comp_grad then
         wts[w+1]:= [ ];
       fi;
       d:= Maximum( Flat( e ) );
       relation_found:= false;

       for r in R[w] do

         t1:=r[1]; t2:=r[2];
         if t1 > t2 then
           tij:= _T[t1][t2];
         else
           tij:= ShallowCopy( _T[t2][t1] );
           tij[2]:= -ShallowCopy( tij[2] );
         fi;
         r1:= List( [1..Length(tij[1])], k -> [ [tij[1][k]], tij[2][k] ] );

         for j in e[1] do

          # The Jacobi identity that will be inspected reads as
          # [ [ t1, t2 ], j ] - [ [ t1, j ], t2 ] + [ [ t2, j ], t1 ] = 0
          # This relation can be evaluated (using the partial table) to a
          # polynomial of degree <=2. This will lead to new definitions
          # (in the case of deg. = 2), or collisions (in the case of
          # deg. = 1).

           if t2 > j then

             if t1 > j then
               tij:= _T[t1][j];
             else
               tij:= ShallowCopy( _T[j][t1] );
               tij[2]:= -ShallowCopy( tij[2] );
             fi;
             k1:= List( [1..Length(tij[1])], i->[ [tij[1][i],t2],-tij[2][i] ]);
             if t2 > j then
               tij:= _T[t2][j];
             else
               tij:= ShallowCopy( _T[j][t2] );
               tij[2]:= -ShallowCopy( tij[2] );
             fi;
             k2:= List( [1..Length(tij[1])], i->[ [tij[1][i],t1],tij[2][i] ]);

             r2:= Dcopy(r1);
             for i in r2 do Add( i[1], j ); od;

             k:= Concatenation( k1, k2, r2 );
             k:= CollectPolynomial( k );
             k:= ReductionModuloTable( k );

             if k <> [ ] then

               # Produce a relation of the form a = c1*var1+c2*var2...
               # by making new definitions. (Where a is either a commutator
               # or a variable).

               i:= 2;
               while i <= Length( k ) do

                 if Length(k[i][1]) = 2 then
                   if comp_grad then
                     weight:= wght(e,wts,k[i][1][1])+ wght(e,wts,k[i][1][2]);
                   else
                     weight:= 0;
                   fi;

                   if weight <= MAX_WEIGHT then
                     if comp_grad then
                       Add( wts[w+1], weight );
                     fi;
                     d:= d+1;
                     Add( e[w+1], d );
                     UpdateTable( k[i][1][1], k[i][1][2], [ [[d],-one] ] );
                     Add( Rw1, k[i][1] );
                     k[i][1]:= [ d ];
                   else
                     Remove( k, i );
                   fi;
                 fi;
                 i:= i+1;
               od;
               k11:= k[1][1];

               if Length(k11) = 2 then

                # The `a' in the comment above is a commutator; hence a new
                # entry for the table has been found.

                 UpdateTable( k11[1], k11[2], k{[2..Length(k)]} );
                 Add( Rw1, k11 );
               elif Length(k11) = 1 then

                 ww:= 0;
                 for i in [1..Length(e)] do
                   if k11[1] in e[i] then ww:=i; break; fi;
                 od;

                 if ww = w+1 then

                # A collision (among the new basis elements) has been found.

                   if comp_grad then
                     pos:= Position( e[w+1], k11[1] );
                     Remove( wts[w+1], pos );
                   fi;
                   RemoveSet( e[w+1], k11[1] );
                   RemoveEntry( k11[1] );
                   SubstituteVariable( Rw1, k );
                   rr:= SubsVarInRels( rr, k );
                 elif ww > 0 then
                   _T:=S;
                   relation_found:= true;
                   r1:= [ ww, k ];
                   break;
                 fi;
               fi;

               i:= 0;
               while i < Length(rr) do

                 i:= i+1;
                 # Reduce the relations modulo the table and process them.

                 while true do
                   u1:= ReductionModuloTable( rr[i] );
                   if u1 = rr[i] then break;
                                 else rr[i]:=u1;
                   fi;
                 od;

                 if rr[i]=[] then
                   Unbind( rr[i] );
                 elif Length(rr[i][1][1])=1 then

                   ww:= 0;
                   temp:= rr[i][1][1][1];
                   for l in [1..Length(e)] do
                     if temp in e[l] then ww:=l; break; fi;
                   od;

                   if ww = w+1 then
                     if comp_grad then
                       pos:= Position( e[w+1],rr[i][1][1][1] );
                       Remove( wts[w+1], pos );
                     fi;
                     RemoveSet(e[w+1],rr[i][1][1][1]);
                     RemoveEntry(rr[i][1][1][1]);
                     SubstituteVariable( Rw1, rr[i] );
                     temp:= rr[i];
                     Remove( rr, i );
                     rr:= SubsVarInRels( rr, temp );
                     i:= i-1;  # (last call removed holes...).
                   elif ww > 0 then
                     _T:=S;
                     relation_found:= true;
                     r1:= [ww,rr[i]];
                     break;
                   fi;
                 elif Length(rr[i][1][1])=2 then
                   max := 0;
                   for s in rr[i] do
                     ww:= 0;
                     for l in [1..Length(e)] do
                       if s[1][1] in e[l] then ww:=l; break; fi;
                     od;
                     if Length(s[1]) = 1 then
                       max:= Maximum(max,ww);
                     else
                       # We calculate the weight of `s[1][1]' + the weight
                       # of `s[1][2]' i.e., the weight of `[s[1][1], s[1][2]]'

                       for l in [1..Length(e)] do
                         if s[1][2] in e[l] then ww:=ww+l; break; fi;
                       od;
                       max:= Maximum(max,ww);
                     fi;
                   od;

                   if max = w+1 then
                     s:= 2;
                     while s <= Length( rr[i] ) do
                       if Length(rr[i][s][1]) = 2 then
                         if wts <> [ ] then
                           weight:= wght(e,wts,rr[i][s][1][1])+
                                              wght(e,wts,rr[i][s][1][2] );
                         else
                           weight:= 0;
                         fi;
                         if weight <= MAX_WEIGHT then
                           d:= d+1;
                           Add( e[w+1], d );
                           if wts <> [ ] then
                             Add( wts[w+1], weight );
                           fi;
                           UpdateTable( rr[i][s][1][1], rr[i][s][1][2],
                                                            [ [[d], -one] ] );
                           Add(Rw1,rr[i][s][1]);
                           rr[i][s][1]:= [ d ];
                         else
                           Remove( rr[i], s );
                         fi;
                       fi;
                       s:= s+1;
                     od;
                     Add(Rw1,rr[i][1][1]);
                     UpdateTable( rr[i][1][1][1], rr[i][1][1][2],
                                                    rr[i]{[2..Length(rr[i])]});
                     Unbind(rr[i]);
                   fi;
                 fi;

               od;
               if relation_found then break; fi;
               rr:=Compacted(rr);
             fi;

           fi;
         od;
       if relation_found then break; fi;
       od;

##########################################################################

       if relation_found then

         # Here `r1[2]' is a relation among basis elements.
         # `r1[1]' is the weight of the homogeneous component containing
         # the first variable (variable of highest weight).

         w:= r1[1];

         if w = 1 then

           # A relation among the variables of weight 1 has been found.
           # We reset everything and return to the point where the table
           # is initialized.

           if comp_grad then
             pos:= Position( e[1], r1[2][1][1][1] );
             Remove( wts[1], pos );
           fi;
           RemoveSet( e[1], r1[2][1][1][1] );
           Add( defs, r1[2] );
           if e[1]=[] then
             K:= LieAlgebraByStructureConstants( LeftActingDomain( FL ),
                      EmptySCTable( 0, zero, "antisymmetric" ) );
             gens:= GeneratorsOfAlgebra( FpL );
             imgs:= List( gens, x -> Zero( K ) );
             map:= Objectify( TypeOfDefaultGeneralMapping( FpL, K,
                                  IsSPGeneralMapping
                              and IsAlgebraGeneralMapping
                              and IsFptoSCAMorphism
                              and IsAlgebraGeneralMappingByImagesDefaultRep ),
                          rec(
                              generators := gens,
                              genimages  := imgs
                             ) );
             SetMappingGeneratorsImages(map,[Immutable(gens),Immutable(imgs)]);
             return map;
           fi;
           e:=[ e[1], [] ];
           if comp_grad then
             wts:= [ wts[1], [] ];
           fi;
           u:= SubsVarInRels( v[1], r1[2] );
           tab_pols:= SubsVarInRels( tab_pols, r1[2] );
           _T:=[];
           R:=[ [ ], List( tab_pols, x -> x[1][1] ) ];
           v[1]:= Dcopy( u );

           # We break to the principal loop.
           break;
         else

# here `r1[2]' is of the form `var=something' where `var' is of weight
# `w', and `w>1'. This means that `var' was introduced somewhere; namely
# on level `w'. Hence the definition was [x_i,x_j]=var, where w(x_i)+
# w(x_j)=w. Hence `var' only appears in tails (right hand sides) of commutators
# of weight `>= w'. Now `var' is substituted in all products of weight `w',
# and the program starts again on that level.

           if comp_grad then
             pos:= Position( e[w], r1[2][1][1][1] );
             Remove( wts[w], pos );
           fi;
           RemoveSet(e[w], r1[2][1][1][1]);
           u:= SubsVarInRels( v[w-1], r1[2]);
           v[w-1]:=u;
           w:= w-1;
           SubstituteVariable( R[w+1], r1[2] );
           for i in [w+2..Length(e)] do e[i]:=[]; od;
           for i in [w+2..Length(R)] do
             for j in [1..Length(R[i])] do
               RemoveComm( R[i][j][1], R[i][j][2] );
             od;
             R[i]:= [ ];
           od;

         fi;

       else

        # Here Jacobi identities have been applied
        # without finding collisions between variables.

         if e[w] = [ ] and not end_reached then
           bound:= 2*w; end_reached:= true;
         elif w = bound and not end_reached then
           return fail;
         fi;

         R[w+1]:= Rw1; v[w]:= rr; u:= rr;

         if Flat( e ) = [ ] then
             K:= LieAlgebraByStructureConstants( LeftActingDomain( FL ),
                      EmptySCTable( 0, zero, "antisymmetric" ) );
             gens:= GeneratorsOfAlgebra( FpL );
             imgs:= List( gens, x -> Zero( K ) );
             map:= Objectify( TypeOfDefaultGeneralMapping( FpL, K,
                                  IsSPGeneralMapping
                              and IsAlgebraGeneralMapping
                              and IsFptoSCAMorphism
                              and IsAlgebraGeneralMappingByImagesDefaultRep ),
                          rec(
                              generators := gens,
                              genimages  := imgs
                             ) );
             SetMappingGeneratorsImages(map,[Immutable(gens),Immutable(imgs)]);
             return map;
         fi;

         d:= Maximum( Flat( e ) );
         vg:= [ ];
         for i in e[w] do
           for j in e[1] do
             if i>j then AddSet( vg, [i,j] ); fi;
           od;
         od;
         vg:= Difference( vg, R[w+1] );
         Append( R[w+1], vg );

         for i in [1..Length(vg)] do
           if comp_grad then
             weight:= wght(e,wts,vg[i][1])+wght(e,wts,vg[i][2]);
           else
             weight:= 0;
           fi;
           if weight <= MAX_WEIGHT then
             d:= d+1;
             Add( e[w+1], d );
             if comp_grad then
               Add( wts[w+1], weight );
             fi;
             Add( R[w+1], vg[i] );
             UpdateTable( vg[i][1], vg[i][2], [ [[d],-1*one] ]);
           else
             UpdateTable( vg[i][1], vg[i][2], [ ] );
           fi;
         od;

       fi;

     od; # end of the loop in which `w' is successively increased.
   od;   # end of the main loop,

   # Now we construct a table of structure constants from `_T'.

   e:=Filtered(e,x->x<>[]);
   inds:=Flat(e);

   S:=[];
   for i in inds do
     rowS:= [ ];
     for j in inds do
       if i=j then
         Add( rowS, [ [], [] ] );
       else
         if i < j then
           tij:= ShallowCopy( _T[j][i] );
           tij[2]:= -ShallowCopy( tij[2] );
         else
           tij:= _T[i][j];
         fi;
         sij:=[[],[]];
         for k in [1..Length(tij[1])] do
           sij[1][k]:= Position( inds, tij[1][k] );
           sij[2][k]:= tij[2][k];
         od;
         Add( rowS, sij );
       fi;
     od;
     Add( S, rowS );
   od;
   Add( S, -1 ); Add( S, zero );

   K:= LieAlgebraByStructureConstants( LeftActingDomain( FL ), S );
   if is_hom then
     wts:= Flat( wts );
     bas:= [1..Dimension(K)];
     SortParallel( wts, bas );

     gradcomps:= [ ];
     degs:= [ ];
     k:= 1;
     while k <= Length(wts) do
       bgc:= [ Basis( K )[bas[k]] ];
       Add( degs, wts[k] );
       while k < Length( wts ) and wts[k]=wts[k+1] do
         k:= k+1;
         Add( bgc, Basis(K)[bas[k]] );
       od;
       Add( gradcomps, VectorSpace( LeftActingDomain( K ), bgc ) );
       k:= k+1;
     od;

     Add( gradcomps, Subspace( K, [ ] ) );

     SetGrading( K, rec( min_degree:= Minimum( wts ),
                    max_degree:= Maximum( wts ),
                    source:= Integers,
                    hom_components:= function( d )
                                      if d in degs then
                                        return gradcomps[Position(degs,d)];
                                      else
                                        return gradcomps[Length(gradcomps)];
                                      fi;
                                     end
                  ) );

   fi;


   gens:= GeneratorsOfAlgebra( FpL );

   if Dimension( K ) = 0 then #trivial case
     imgs:= List( gens, x -> Zero(K) );
   else
     # We process the definitions, (of generators as linear combinations
     # of other generators).
     i:= Length( defs );
     while i > 1 do
       for j in [1..i-1] do
         for k in [1..Length(defs[j])] do
           if defs[j][k][1] = defs[i][1][1] then
             Append( defs[j], List( defs[i]{[2..Length(defs[i])]}, x ->
                                [ x[1], -defs[j][k][2]*x[2] ] )
                   );
             Unbind( defs[j][k] );
           fi;
         od;
         defs[j]:= Compacted( defs[j] );
       od;
       i:= i-1;
     od;

     imgs:= [ ];

     #For every generator of the Fp Lie algebra we calculate an image...

     for i in [1..Length(gens)] do
       if i in e[1] then
         Add( imgs, Basis( K )[Position( inds, i )] );
       else
         for j in [1..Length(defs)] do
           if defs[j][1][1][1] = i then break; fi;
         od;
         im:= Zero( K );
         for k in [2..Length(defs[j])] do
           im:= im + -defs[j][k][2]*Basis( K )[defs[j][k][1][1]];
         od;
         Add (imgs, im );
       fi;
     od;
   fi;

# Construct the map...

   map:= Objectify( TypeOfDefaultGeneralMapping( FpL, K,
                               IsSPGeneralMapping
                           and IsAlgebraGeneralMapping
                           and IsFptoSCAMorphism
                           and IsAlgebraGeneralMappingByImagesDefaultRep ),
                       rec(
                            generators := gens,
                            genimages  := imgs
                           ) );
   SetMappingGeneratorsImages(map,[Immutable(gens),Immutable(imgs)]);

   return map;

end );


InstallMethod( NiceAlgebraMonomorphism,
    "for a f.p. Lie algebra",
    true,
    [ IsLieAlgebra and IsSubalgebraFpAlgebra], 0,

    function( FpL )

      return FpLieAlgebraEnumeration( FpL );

end );


InstallGlobalFunction( NilpotentQuotientOfFpLieAlgebra,

    function( arg )

      local FpL,L,weights,is_homogeneous,rels,weight,w,r,k,j,er,fol,maxw,N;


    # unwrapping the arguments...

      if Length( arg ) = 2 then
        FpL:= arg[1]; maxw:= arg[2];
        L:= ElementsFamily( FamilyObj( FpL ) )!.freeAlgebra;
        weights:= List( GeneratorsOfAlgebra( L ), x -> 1 );
      elif Length( arg ) = 3 then
        FpL:= arg[1]; maxw:= arg[2]; weights:= arg[3];
      else
        Error("Number of arguments must be two or three");
      fi;

    # checking whether the relations are homogeneous; if so then
    # the resulting structure constants Lie algebra will have a
    # natural grading.

      is_homogeneous:= true;
      rels:= ElementsFamily( FamilyObj( FpL ) )!.relators;

      for r in rels do

        weight:= infinity;
        er:= ExtRepOfObj( r )[2];
        for k in [1,3..Length(er)-1] do
          fol:= Flat( [ er[k] ] );
          w:= 0;
          for j in fol do
            w:= w+weights[j];
          od;
          if weight = infinity then
            weight:= w;
          elif weight <> w then
            is_homogeneous:= false;
            break;
          fi;
        od;
        if not is_homogeneous then break; fi;
      od;

      N:= FpLieAlgebraEnumeration( FpL, maxw, weights, is_homogeneous );
      SetIsLieNilpotent( Range(N), true );
      return N;

end );



##############################################################################
##
#F  FpLieAlgebraByCartanMatrix( <C> )
##
##
InstallGlobalFunction( FpLieAlgebraByCartanMatrix, function( C )

  local i,j,k,    # Loop variables.
        l,        # The rank.
        L,        # The free Lie algebra.
        g,        # Generators of `L'.
        x,h,y,    # Lists of generators of `L'.
        rels,     # List of relations.
        rx,ry;    # Relations.

  l:= Length( C );
  L:= FreeLieAlgebra( Rationals, 3*l );
  g:= GeneratorsOfAlgebra( L );
  x:= g{[1..l]};
  h:= g{[l+1..2*l]};
  y:= g{[2*l+1..3*l]};

  rels:= [ ];
  for i in [1..l] do
    for j in [i+1..l] do
      Add( rels, h[i]*h[j] );
    od;
  od;

  for i in [1..l] do
    for j in [1..l] do
      if i=j then
        Add( rels, x[i]*y[j]-h[i] );
      else
        Add( rels, x[i]*y[j] );
      fi;
    od;
  od;

  for i in [1..l] do
    for j in [1..l] do
      Add( rels, h[i]*x[j]-C[j][i]*x[j] );
      Add( rels, h[i]*y[j]+C[j][i]*y[j] );
    od;
  od;

  for i in [1..l] do
    for j in [1..l] do
      if i <> j then
        rx:= x[j]; ry:= y[j];
        for k in [1..1-C[j][i]] do
          rx:= x[i]*rx; ry:= y[i]*ry;
        od;
        Add( rels, rx ); Add( rels, ry );
      fi;
    od;
  od;

  return L/rels;

end );

#############################################################################
##
#M  JenningsLieAlgebra( <G> )
##
##  The Jennings Lie algebra of the p-group G.
##
##

InstallMethod( JenningsLieAlgebra,
                "for a p-group",
                 true,
                 [IsGroup], 0,

 function ( G )

    local J,         # Jennings series of G
          Homs,      # Homomorphisms of J[i] onto the quotient J[i]/J[i+1]
          grades,    # List of the full images of the maps in Homs
          gens,      # List of the generators of the quotients J[i]/J[i+1],
                     # i.e., a basis of the Lie algebra.
          pos,       # list of positions: if pos[j] = p, then the element
                     # gens[j] belongs to grades[p]
          i,j,k,     # loop variables
          tempgens,
          t,         # integer
          T,         # multiplication table of the Lie algebra
          dim,       # dimension of the Lie algebra
          a,b,c,f,   # group elements
          e,         # ext rep of a group element
          co,        # entry of the multiplication table
          p,         # the prime of G
          F,         # ground field
          L,         # the Lie algebra to be constructed
          pimgs,     # pth-power images
          B,         # Basis of L
          vv, x,     # elements of L
          comp,      # homogeneous component
          grading,   # list of homogeneous components
          pcgps,     # list of pc groups, isom to the elts of `grades'.
          hom_pcg,   # list of isomomorphisms of `grades[i]' to `pcgps[i]'.
          enum_gens, # List of numbers of elts of `gens' in extrep.
          pp,        # Position in a list.
          hm;

    # We do not know the characteristic if `G' is trivial.
    if IsTrivial( G ) then
      Error( "<G> must be a nontrivial p-group" );
    fi;

    # Construct the homogeneous components of `L':

    J:=JenningsSeries ( G );
    Homs:= List ( [1..Length(J)-1] , x ->
                  NaturalHomomorphismByNormalSubgroupNC( J[x], J[x+1] ));
    grades := List ( Homs , Range );
    hom_pcg:= List( grades, IsomorphismSpecialPcGroup );
    pcgps:= List( hom_pcg, Range );
    gens := [];
    enum_gens:= [ ];
    pos := [];
    for i in [1.. Length(grades)] do
        tempgens:= GeneratorsOfGroup( pcgps[i] );
        Append ( gens , tempgens);

        # Record the number that each generator has in extrep.
        Add( enum_gens, List( tempgens, x -> ExtRepOfObj( x )[1] ) );
        Append ( pos , List ( tempgens , x-> i ) );
    od;

    # Construct the field and the multiplication table:

    dim:= Length(gens);
    p:= PrimePGroup( G );
    F:= GF( p );
    T:= EmptySCTable( dim , Zero(F) , "antisymmetric" );
    pimgs := [];
    for i in [1..dim] do
        a:= PreImagesRepresentative( Homs[pos[i]] ,
                    PreImagesRepresentative( hom_pcg[pos[i]], gens[i] ) );

        # calculate the p-th power image of `a':

        if pos[i]*p <= Length(Homs) then
            Add( pimgs, Image( hom_pcg[pos[i]*p],
                    Image( Homs[pos[i]*p], a^p) ) );
        else
            Add( pimgs, "zero" );
        fi;

        for j in [i+1.. dim] do
            if pos[i]+pos[j] <= Length( Homs ) then

               # Calculate the commutator [a,b], and map the result into
               # the correct homogeneous component.

                b:= PreImagesRepresentative( Homs[pos[j]],
                         PreImagesRepresentative( hom_pcg[pos[j]], gens[j] ));
                c:= Image( hom_pcg[pos[i] + pos[j]],
                           Image(Homs[pos[i] + pos[j]], a^-1*b^-1*a*b) );
                e:= ExtRepOfObj(c);
                co:=[];
                for k in [1,3..Length(e)-1] do
                    pp:= Position( enum_gens[pos[i]+pos[j]], e[k] );
                    t:= Sum( enum_gens{[1..pos[i]+pos[j]-1]}, Length )+pp;
                    Add( co, One( F )*e[k+1] );
                    Add( co, t );
                od;
                SetEntrySCTable( T, i, j, co );
            fi;

        od;
    od;

    L:= LieAlgebraByStructureConstants( F, T );

    B:= Basis( L );

    # Now we compute the natural grading of `L'.
    grading:= [ ];
    k:= 1;
    for i in [1..Length(enum_gens)] do
        comp:= [ ];
        for j in [1..Length(enum_gens[i])] do
            Add( comp, B[k] );
            k:= k+1;
        od;
        Add( grading, Subspace( L, comp ) );
    od;

    Add( grading, Subspace( L, [ ] ) );

    SetGrading( L, rec( min_degree:= 1,
                        max_degree:= Length( grading ) - 1,
                        source:= Integers,
                        hom_components:= function( d )
                                            if d in [1..Length(grading)] then
                                              return grading[d];
                                            else
                                              return grading[Length(grading)];
                                            fi;
                                         end
                      )
              );

    vv:= BasisVectors( B );

    # Set the pth-power images of the basis elements of `B':

    for i in [1..Length(pimgs)] do
        if pimgs[i] = "zero" then
            pimgs[i]:= Zero( L );
        else
            e:= ExtRepOfObj( pimgs[i] );
            x:= Zero( L );
            for k in [1,3..Length(e)-1] do
                pp:= Position( enum_gens[pos[i]*p], e[k] );
                t:= Sum( enum_gens{[1..pos[i]*p-1]}, Length )+pp;
                x:= x+ One( F )*e[k+1]*vv[t];
            od;
            pimgs[i]:= x;
        fi;
    od;
    SetPthPowerImages( B, pimgs );
    SetIsRestrictedLieAlgebra( L, true );
    FamilyObj(Representative(L))!.pMapping := pimgs;
    SetIsLieNilpotent( L, true );

       hm:= function( g, i )

             local h, e, x, k, pp, f, t;

             if not g in J[i] then
                Error("<g> is not an element of the i-th term of the series used to define <L>");
             fi;

             h:= Image( hom_pcg[i], Image(Homs[i], g ));
             e:= ExtRepOfObj(h);
             x:= Zero(L);
             for k in [1,3..Length(e)-1] do
                 pp:= Position( enum_gens[i], e[k] );
                 f:= GeneratorsOfGroup( pcgps[i] )[pp];
                 t:= Position( gens, f );
                 x:= x + e[k+1]*Basis(L)[t];
             od;
             return x;
        end ;

    SetNaturalHomomorphismOfLieAlgebraFromNilpotentGroup( L, hm );


    return L;

end );



#############################################################################
##
#M  PCentralLieAlgebra( <G> )
##
##  The p-central Lie algebra of the p-group G.
##
##
InstallMethod( PCentralLieAlgebra,
                "for a p-group",
                 true,
                 [IsGroup], 0,

 function ( G )

    local J,         # p-central series of G
          Homs,      # Homomorphisms of J[i] onto the quotient J[i]/J[i+1]
          grades,    # List of the full images of the maps in Homs
          gens,      # List of the generators of the quotients J[i]/J[i+1],
                     # i.e., a basis of the Lie algebra.
          pos,       # list of positions: if pos[j] = p, then the element
                     # gens[j] belongs to grades[p]
          i,j,k,     # loop variables
          tempgens,
          t,         # integer
          T,         # multiplication table of the Lie algebra
          dim,       # dimension of the Lie algebra
          a,b,c,f,   # group elements
          e,         # ext rep of a group element
          co,        # entry of the multiplication table
          p,         # the prime of G
          F,         # ground field
          L,         # the Lie algebra to be constructed
          B,         # Basis of L
          vv, x,     # elements of L
          comp,      # homogeneous component
          grading,   # list of homogeneous components
          pcgps,     # list of pc groups, isom to the elts of `grades'.
          hom_pcg,   # list of isomomorphisms of `grades[i]' to `pcgps[i]'.
          enum_gens, # List of numbers of elts of `gens' in extrep.
          pp,        # Position in a list.
          pimgs,     # pth power images
          hm;


    # We do not know the characteristic if `G' is trivial.
    if IsTrivial( G ) then
      Error( "<G> must be a nontrivial p-group" );
    fi;

    # Construct the homogeneous components of `L':

    p:= PrimePGroup( G );
    J:= PCentralSeries( G, p );
    Homs:= List ( [1..Length(J)-1] , x ->
                  NaturalHomomorphismByNormalSubgroupNC( J[x], J[x+1] ));
    grades := List ( Homs , Range );
    hom_pcg:= List( grades, IsomorphismSpecialPcGroup );
    pcgps:= List( hom_pcg, Range );
    gens := [];
    enum_gens:= [ ];
    pos := [];
    for i in [1.. Length(grades)] do
        tempgens:= GeneratorsOfGroup( pcgps[i] );
        Append ( gens , tempgens);

        # Record the number that each generator has in extrep.
        Add( enum_gens, List( tempgens, x -> ExtRepOfObj( x )[1] ) );
        Append ( pos , List ( tempgens , x-> i ) );
    od;

    # Construct the field and the multiplication table:

    dim:= Length(gens);
    F:= GF( p );
    T:= EmptySCTable( dim , Zero(F) , "antisymmetric" );
    pimgs := [];
    for i in [1..dim] do
        a:= PreImagesRepresentative( Homs[pos[i]] ,
                    PreImagesRepresentative( hom_pcg[pos[i]], gens[i] ) );


        # calculate the p-th power image of `a':

        if pos[i]+1 <= Length(Homs) then
            Add( pimgs, Image( hom_pcg[pos[i]+1],
                    Image( Homs[pos[i]+1], a^p) ) );
        else
            Add( pimgs, "zero" );
        fi;

        for j in [i+1.. dim] do
            if pos[i]+pos[j] <= Length( Homs ) then

               # Calculate the commutator [a,b], and map the result into
               # the correct homogeneous component.

                b:= PreImagesRepresentative( Homs[pos[j]],
                         PreImagesRepresentative( hom_pcg[pos[j]], gens[j] ));
                c:= Image( hom_pcg[pos[i] + pos[j]],
                           Image(Homs[pos[i] + pos[j]], a^-1*b^-1*a*b) );
                e:= ExtRepOfObj(c);
                co:=[];
                for k in [1,3..Length(e)-1] do
                    pp:= Position( enum_gens[pos[i]+pos[j]], e[k] );
                    t:= Sum( enum_gens{[1..pos[i]+pos[j]-1]}, Length )+pp;
                    Add( co, One( F )*e[k+1] );
                    Add( co, t );
                od;
                SetEntrySCTable( T, i, j, co );
            fi;

        od;
    od;

    L:= LieAlgebraByStructureConstants( F, T );

    B:= Basis( L );

    # Now we compute the natural grading of `L'.

    grading:= [ ];
    k:= 1;

    for i in [1..Length(enum_gens)] do
        comp:= [ ];
        for j in [1..Length(enum_gens[i])] do
            Add( comp, B[k] );
            k:= k+1;
        od;
        Add( grading, Subspace( L, comp ) );
    od;

    Add( grading, Subspace( L, [ ] ) );

    SetGrading( L, rec( min_degree:= 1,
                        max_degree:= Length( grading ) - 1,
                        source:= Integers,
                        hom_components:= function( d )
                                            if d in [1..Length(grading)] then
                                              return grading[d];
                                            else
                                              return grading[Length(grading)];
                                            fi;
                                         end
                      )
              );

    vv:= BasisVectors( B );

    # Set the pth-power images of the basis elements of `B':

    for i in [1..Length(pimgs)] do
        if pimgs[i] = "zero" then
            pimgs[i]:= Zero( L );
        else
            e:= ExtRepOfObj( pimgs[i] );
            x:= Zero( L );
            for k in [1,3..Length(e)-1] do
                pp:= Position( enum_gens[pos[i]+1], e[k] );
                t:= Sum( enum_gens{[1..pos[i]]}, Length )+pp;
                x:= x+ One( F )*e[k+1]*vv[t];
            od;
            pimgs[i]:= x;
        fi;
    od;
    SetPthPowerImages( B, pimgs );
    SetIsRestrictedLieAlgebra( L, true );
    SetIsLieNilpotent( L, true );

        hm:= function( g, i )

             local h, e, x, k, pp, f, t;

             if not g in J[i] then
                Error("<g> is not an element of the i-th term of the series used to define <L>");
             fi;

             h:= Image( hom_pcg[i], Image(Homs[i], g ));
             e:= ExtRepOfObj(h);
             x:= Zero(L);
             for k in [1,3..Length(e)-1] do
                 pp:= Position( enum_gens[i], e[k] );
                 f:= GeneratorsOfGroup( pcgps[i] )[pp];
                 t:= Position( gens, f );
                 x:= x + e[k+1]*Basis(L)[t];
             od;
             return x;
        end ;

    SetNaturalHomomorphismOfLieAlgebraFromNilpotentGroup( L, hm );

    return L;

end );
