#############################################################################
##
#W  alglie.gi                   GAP library                     Thomas Breuer
#W                                                        and Willem de Graaf
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for Lie algebras.
##
Revision.alglie_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  UpperCentralSeriesOfAlgebra( <L> )  . . . . . . . . . . for a Lie algebra
##
InstallMethod( UpperCentralSeriesOfAlgebra,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local   S,          # upper central series of <L>, result
            C,          # Lie centre
            hom;        # homomorphisms of <L> to '<L>/<C>'

    S := [ TrivialSubalgebra( L ) ];
    C := LieCentre( L );
    while C <> S[ Length(S) ]  do

      # Replace 'L' by 'L / C', compute its centre, and get the preimage
      # under the natural homomorphism.
      Add( S, C );
      hom:= NaturalHomomorphismByIdeal( L, C );
      C:= PreImage( hom, LieCentre( Range( hom ) ) );

    od;

    # Return the series when it becomes stable.
    return Reversed( S );
    end );


#############################################################################
##
#M  LowerCentralSeriesOfAlgebra( <L> )  . . . . . . . . . . for a Lie algebra
##
InstallMethod( LowerCentralSeriesOfAlgebra,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local   S,          # lower central series of <L>, result
            C;          # commutator subalgebras

    # Compute the series by repeated calling of 'ProductSpace'.
    S := [ L ];
    C := DerivedSubalgebra( L );
    while C <> S[ Length(S) ]  do
      Add( S, C );
      C:= ProductSpace( L, C );
    od;

    # Return the series when it becomes stable.
    return S;
    end );


#############################################################################
##
#M  IsSolvableAlgebra( <L> )  . . . . . . . . . . . . . . . for a Lie algebra
##
InstallMethod( IsSolvableAlgebra,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local D;

    D:= DerivedSeriesOfAlgebra( L );
    return Dimension( D[ Length( D ) ] ) = 0;
    end );


#############################################################################
##
#M  IsNilpotentAlgebra( <L> ) . . . . . . . . . . . . . . . for a Lie algebra
##
InstallMethod( IsNilpotentAlgebra,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local D;

    D:= LowerCentralSeriesOfAlgebra( L );
    return Dimension( D[ Length( D ) ] ) = 0;
    end );


#############################################################################
##
#M  IsAbelianLieAlgebra( <L> )  . . . . . . . . . . . . . . for a Lie algebra
##
##  It is of course sufficient to check products of algebra generators,
##  no basis and structure constants of <L> are needed.
##  But if we have already a structure constants table we use it.
##
InstallMethod( IsAbelianLieAlgebra,
    "method for a Lie algebra with known basis",
    true,
    [ IsAlgebra and IsLieAlgebra and HasBasisOfDomain ], 0,
    function( L )

    local B,      # basis of 'L'
          T,      # structure constants table w.r.t. 'B'
          i,      # loop variable
          j;      # loop variable

    B:= BasisOfDomain( L );
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

InstallMethod( IsAbelianLieAlgebra,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local T,      # structure constants table of a basis of 'L'
          i,      # loop variable
          j,      # loop variable
          zero,   # zero of 'L'
          gens;   # algebra generators of 'L'

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
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( A )

    local   R,          # left acting domain of 'A'
            C,          # Lie centre of 'A', result
            B,          # a basis of 'A'
            T,          # structure constants table w.r. to 'B'
            n,          # dimension of 'A'
            M,          # matrix of the equation system
            zerovector, #
            i, j,       # loop over ...
            row;        # one row of 'M'

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
      B:= BasisOfDomain( A );
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
    "method for an abelian Lie algebra and a vector space",
    IsIdentical,
    [ IsAlgebra and IsLieAlgebra and IsAbelianLieAlgebra,
      IsVectorSpace ], 0,
    function( A, S )

    if IsSubset( A, S ) then
      return A;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( LieCentralizer,
    "method for a Lie algebra and a vector space",
    IsIdentical,
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ], 0,
    function( A, S )

    local R,           # left acting domain of 'A'
          B,           # basis of 'A'
          T,           # structure constants table w. r. to 'B'
          n,           # dimension of 'A'
          m,           # dimension of 'S'
          M,           # matrix of the equation system
          v,           # coefficients of basis vectors of 'S' w.r. to 'B'
          zerovector,  # initialize one row of 'M'
          row,         # one row of 'M'
          i, j, k, l,  # loop variables
          cil,         #
          offset,
          vjl,
          pos;

    R:= LeftActingDomain( A );
    B:= BasisOfDomain( A );
    T:= StructureConstantsTable( B );
    n:= Dimension( A );
    m:= Dimension( S );
    M:= [];
    v:= List( BasisVectors( BasisOfDomain( S ) ),
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
    if IsIdeal( A, S ) then
#T really check this?
      return IdealNC( A, M, "basis" );
    else
      return SubalgebraNC( A, M, "basis" );
    fi;
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
    "method for a Lie algebra and a vector space",
    IsIdentical,
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ], 0,
    function( L, U )

    local R,          # left acting domain of 'L'
          B,          # a basis of 'L'
          T,          # the structure constants table of 'L' w.r.t. 'B'
          n,          # the dimension of 'L'
          s,          # the dimension of 'U'
          A,          # the matrix of the equation system
          i, j, k, l, # loop variables
          v,          # the coefficients of the basis of 'U' wrt 'B'
          cij,
          bas,
          b,
          pos;

#T     if IsBound( U.isIdeal ) and U.isIdeal then
#T       return L;
#T     fi;
#T how to do this?

    R:= LeftActingDomain( L );
    B:= BasisOfDomain( L );
    T:= StructureConstantsTable( B );
    n:= Dimension( L );
    s:= Dimension( U );

    if s = 0 or n = 0 then
      return L;
    fi;

    v:= List( BasisVectors( BasisOfDomain( U ) ),
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

    # Extract the 'normalizer part' of the solution.
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
#T  Should this better be 'OrthogonalSpace( <F>, <U> )' where <F> is a
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
    "method for a Lie algebra and a vector space",
    IsIdentical,
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ], 0,
    function( L, U )

    local R,          # left acting domain of 'L'
          B,     # a basis of L
          kap,   # the matrix of the Killing form w.r.t. 'B'	
          A,     # the matrix of the equation system
          n,     # the dimension of L
          s,     # the dimension of U
          v,     # coefficient list of the basis of U w.r.t. the basis of L
          i,j,k, # loop variables
          bas;   # the basis of the solution space

    R:= LeftActingDomain( L );
    B:= BasisOfDomain( L );
    n:= Dimension( L );
    s:= Dimension( U );

    if s = 0 or n = 0 then
      return L;
    fi;

    v:= List( BasisVectors( BasisOfDomain( U ) ),
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

    if IsIdeal( L, U ) then
      return SubalgebraNC( L, bas, "basis" );
#T or always return just a space?
    else
      return SubspaceNC( L, bas, "basis" );
    fi;
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
    "method for a basis of a Lie algebra, and an element",
    IsCollsElms,
    [ IsBasis, IsRingElement ], 0,
    function( B, x )

    local n,            # dimension of the algebra
          T,            # structure constants table w.r. to 'B'
          zerovector,   # zero of the field
          M,            # adjoint matrix, result
          j, i, l,      # loop variables
          cij,          # structure constants vector
          k,            # one position in structure constants vector
          row;          # one row of 'M'

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
#M  Derivations( <B> )
##
##  Let $n$ be the dimension of $A$.
##  We start with $n^2$ indeterminates $D = [ d_{i,j} ]_{i,j}$ which
##  means that $D$ maps $b_i$ to $\sum_{i=1}^n d_{ij} b_j$.
##
##  (Note that this is column convention.)
##
##  This leads to the following linear equation system in the $d_{ij}$.
##  $\sum_{k=1}^n ( c_{ijk} d_{km} - c_{kjm} d_{ik} - c_{ikm} d_{jk} ) = 0$
##  for all $1 \leq i, j, m \leq n$.
##  The solution of this system gives us a vector space basis of the
##  algebra of derivations.
##
InstallMethod( Derivations,
    "method for a basis of a Lie algebra",
    true,
    [ IsBasis ], 0,
    function( B )

    local T,           # structure constants table w.r. to 'B'
          L,           # underlying Lie algebra
          R,           # left acting domain of 'L'
          n,           # dimension of 'L'
          zerovector,  # zero vector of length 'n^2'
          lower,
          A,
          i, j, k, m,
          row,
          M;             # the Lie algebra of derivations

    if not IsLieAlgebra( UnderlyingLeftModule( B ) ) then
      Error( "<B> must be a basis of a Lie algebra" );
    fi;

    T:= StructureConstantsTable( B );
    L:= UnderlyingLeftModule( B );
    R:= LeftActingDomain( L );
    n:= Dimension( L );

    if n = 0 then
      return NullAlgebra( R );
    fi;

    zerovector:= [ 1 .. n*n ] * Zero( R );

    # The columns in the matrix of the equation system are indexed
    # by the $d_{ij}$; the $((i-1) n + j)$-th column belongs to $d_{ij}$.
#T until we have 'RightNullspaceMat' we first construct the matrix,
#T then transpose, and then compute a base of the (left) nullspace.

    # In characteristic different from 2
    # we only need the equations for $i > j$.
    if Characteristic( R ) = 2 then
      lower:= 0;
    else
      lower:= 1;
    fi;

    # Construct the equation system.
    A:= [];
    for i in [ 1 .. n ] do
      for j in [ lower*i+1 .. n ] do
        for m in [ 1 .. n ] do
          row:= ShallowCopy( zerovector );
          for k in [ 1 .. n ] do
            row[ (k-1)*n+m ]:= row[ (k-1)*n+m ] + SCTableEntry( T,i,j,k );
            row[ (i-1)*n+k ]:= row[ (i-1)*n+k ] + SCTableEntry( T,k,j,m );
            row[ (j-1)*n+k ]:= row[ (j-1)*n+k ] + SCTableEntry( T,i,k,m );
          od;
          Add( A, row );
        od;
      od;
    od;

    # Solve the equation system.
    # Note that for $n = 1$ the matrix may be empty.
    if IsEmpty( A ) then
      A:= [ [ One( R ) ] ];
    else
      A:= NullspaceMat( TransposedMat( A ) );
    fi;

    # Construct the generating matrices from the vectors.
    A:= List( A, v -> List( [ 1 .. n ],
                            i -> v{ [ (i-1)*n + 1 .. i*n ] } ) );

    # Construct the Lie algebra.
    if IsEmpty( A ) then
      M:= AlgebraByGenerators( R, [], LieObject( NullMat( n, n, R ) ) );
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
    "method for a basis of a Lie algebra",
    true,
    [ IsBasis ], 0,
    function( B )

    local T,           # s.c. table w.r. to 'B'
          L,           # the underlying algebra
          R,           # left acting domain of 'L'
          kappa,       # the matrix of the killing form, result
          n,           # dimension of 'L'
          zero,        # the zero of 'R'
          i, j, k, t,  # loop variables
          row,         # one row of 'kappa'
          val,         # one entry of 'kappa'
          cjk;         # 'T[j][k]'

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


#############################################################################
##
#M  IsNilpotentElement( <L>, <x> )  . . . .  for a Lie algebra and an element
##
##  <x> is nilpotent if its adjoint matrix $A$ (w.r. to an arbitrary basis)
##  is nilpotent.
##  To check this, we only need to check whether $A^n$ (or a smaller power)
##  is zero, where $n$ denotes the dimension of <L>.
##
InstallMethod( IsNilpotentElement,
    "method for a Lie algebra, and an element",
    IsCollsElms,
    [ IsAlgebra and IsLieAlgebra, IsRingElement ], 0,
    function( L, x )

    local B,     # a basis of 'L'
          A,     # adjoint matrix of 'x w.r. to 'B'
          n,     # dimension of 'L'
          i,     # loop variable
          zero;  # zero coefficient

    B := BasisOfDomain( L );
    A := AdjointMatrix( B, x );
    n := Dimension( L );
    i := 1;
    zero:= Zero( A[1][1] );

    if ForAll( A, x -> n < PositionNot( x, zero ) ) then
      return true;
    fi;

    while i < n do
      i:= 2 * i;
      A:= A * A;
      if ForAll( A, x -> n < PositionNot( x, zero ) ) then
        return true;
      fi;
    od;

    return false;
    end );


##############################################################################
##
#M  AdjointBasis( <B> )
##
##  The input is a basis of a (Lie) algebra $L$.
##  This function returns a particular basis $C$ of the matrix space generated
##  by $ad L$, namely a basis consisting of elements of the form $ad x_i$
##  where $x_i$ is a basis element of <B>.
##  An extra component 'indices' is added to this space.
##  This is a list of integers such that 'ad <B>.basisVectors[ indices[i] ]'
##  is the 'i'-th basis vector of <C>, for i in [1..Length(indices)].
##  (This list is added in order to be able to identify the basis element of
##  <B> with the property that its adjoint matrix is equal to a given basis
##  vector of <C>.)
##
InstallMethod( AdjointBasis,
    "method for a basis of a Lie algebra",
    true,
    [ IsBasis ], 0,
    function( B )

    local bb,     # the basis vectors of 'B'
          n,      # the dimension of 'B'
          F,      # the field over which the algebra is defined
          adL,    # a list of matrices that form a basis of adLsp
          adLsp,  # the matrix space spanned by ad L
          inds,   # the list of indices
          i,      # loop variable
          adi,    # the adjoint matrix of the i-th basis vector of 'B'
          adLbas; # the basis of 'adLsp' compatible with 'adL'

    bb:= BasisVectors( B );
    n:= Length( bb );
    F:= LeftActingDomain( UnderlyingLeftModule( B ) );
    adL:= [];
    adLsp:= LeftModuleByGenerators( F, NullMat(n,n,F) );
#T better declare the zero ?
    inds:= [];
    for i in [1..n] do
      adi:= AdjointMatrix( B, bb[i] );
      if not ( adi in adLsp ) then
        Add( adL, adi );
        Add( inds, i );
        adLsp:= LeftModuleByGenerators( F, adL );
      fi;
    od;
    adLbas:= BasisByGenerators( adLsp, adL );
#T better use mutable basis!

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
    "method for a Lie algebra",
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

    B:= BasisOfDomain( L );

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
PowerSi := function( F, i )

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
          arg,   # the argument of the returned function
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
end;


#############################################################################
##
#F  PowerS( <L> )
##
InstallMethod( PowerS,
    "method for a Lie algebra",
    true,
    [ IsLieAlgebra ], 0,
    function( L )

    local F,    # the coefficients domain
          p;    # the characteristic of 'F'

    F:= LeftActingDomain( L );
    p:= Characteristic( F );
    return List( [ 1 .. p-1 ], i -> PowerSi( F , i ) );
    end );


##############################################################################
##
#F  PthPowerImage( <B>, <x> )
##
InstallMethod( PthPowerImage,
    "method for a basis of an algebra, and a ring element",
    IsCollsElms,
    [ IsBasis, IsRingElement ], 0,
    function( B, x )

    local L,     # the Lie algebra of which B is a basis
          F,     # the coefficients domain of 'L'
          n,     # the dimension of L
          p,     # the characteristic of the ground field
          s,     # the list of s_i functions
          pmap,  # the list containing x_i^{[p]}
          cf,    # the coefficients of x wrt the basis of L
          im,    # the image of x under the p-th power map
          i,j,   # loop variables
          zero,  # zero of 'F'
          bv,    # basis vectors of 'B'
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

      n:= Dimension( L );
      s:= PowerS( L );
      pmap:= PthPowerImages( B );
      cf:= Coefficients( B, x );
      im:= Zero( L );

      # First the sum of all $\alpha_i^p x_i^{[p]}$ is calculated.
      for i in [1..n] do
        im:= im + cf[i]^p * pmap[i];
      od;

      # To this the double sum of all
      # $s_i(\alpha_j x_j, \sum_{k=j+1}^n \alpha_k x_k)$
      # is added.
      zero:= Zero( F );
      bv:= BasisVectors( B );
      for j in [1..n-1] do
        if cf[j] <> zero then
          x:= x - cf[j] * bv[j];
          for i in [1..p-1] do
            im:= im + s[i]( [cf[j]*bv[j],x] );
          od;
        fi;
      od;

      return im;
    fi;
    end );


#############################################################################
##
#M  PthPowerImages( <B> ) . . . . . . . . . . .  for a basis of a Lie algebra
##
InstallMethod( PthPowerImages,
    "method for a basis of a Lie algebra",
    true,
    [ IsBasis ], 0,
    function( B )

    local L,          # the underlying algebra
          p,          # the characteristic of 'L'
          adL,        # a basis of the matrix space spanned by ad L
          basL;       # the list of basis vectors 'b' of 'B' such that
                      # 'ad b' is a basis vector of 'adL'

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

    # Now 'IndicesOfAdjointBasis( adL )' is a list of indices with 'i'-th
    # entry the position of the basis vector of 'B'
    # whose adjoint matrix is the 'i'-th basis vector of 'adL'.
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
##  By defintion, an Engel subalgebra of <L> is the generalized eigenspace
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
    "method for a Lie algebra",
    true,
    [ IsLieAlgebra ], 0,
    function( L )

    local n,            # the dimension of L
          F,            # coefficients domain of 'L'
          root,         # prim. root of 'F' if 'F' is finite
          K,            # a subalgebra of L (on termination a Cartan subalg.)
          a,b,          # (non nilpotent) elements of L
          A,            # matrix of the equation system (ad a)^n(x)=0
          bas,          # basis of the solution space of Ax=0
          sp,           # the subspace of L generated by bas
          found,ready,  # boolean variables
          c,            # an element of 'F'
          newelt,       # an element of L of the form a+c*(b-a)
          i;            # loop variable

    n:= Dimension(L);
    F:= LeftActingDomain( L );

    if IsRestrictedLieAlgebra( L ) then

      K:= L;
      while true do

        a:= NonNilpotentElement( K );

        if a = fail then
          # 'K' is a nilpotent Engel subalgebra, hence a Cartan subalgebra.
          return K;
        fi;

        # 'a' is a non nilpotent element of 'K'.
        # We construct the generalized eigenspace of this element w.r.t.
        # the eigenvalue 0.  This is a subalgebra of 'K' and of 'L'.
        A:= TransposedMat( AdjointMatrix( BasisOfDomain( K ), a));
        A:= A ^ Dimension( K );
        bas:= NullspaceMat( A );
        bas:= List( bas, x -> LinearCombination( BasisOfDomain( K ), x ) );
        K:= SubalgebraNC( L, bas, "basis");

      od;

    elif n < Size( F ) then

      # We start with an Engel subalgebra. If it is nilpotent
      # then it is a Cartan subalgebra and we are done.
      # Otherwise we make it smaller.

      a:= NonNilpotentElement( L );

      if a = fail then
        # 'L' is nilpotent.
        return L;
      fi;

      # 'K' will be the Engel subalgebra corresponding to 'a'.

      A:= TransposedMat( AdjointMatrix( BasisOfDomain( L ), a ) );
      A:= A^n;
      bas:= NullspaceMat( A );
      bas:= List( bas, x -> LinearCombination( BasisOfDomain( L ), x ) );
      K:= SubalgebraNC( L, bas, "basis");

      # We locate a nonnilpotent element in this Engel subalgebra.

      b:= NonNilpotentElement( K );

      # If 'b = fail' then 'K' is nilpotent and we are done.
      ready:= ( b = fail );

      while not ready do

        # We locate an element $a + c*(b-a)$ such that the Engel subalgebra
        # belonging to this element is smaller than the Engel subalgebra
        # belonging to 'a'.
        # We do this by checking a few values of 'c'
        # (At most 'n' values of 'c' will not yield a smaller subalgebra.)

        sp:= VectorSpace( F, BasisVectors( BasisOfDomain(K) ), "basis");
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

          # Calculate the Engel subalgebra belonging to 'newelt'.
          A:= TransposedMat( AdjointMatrix( BasisOfDomain( K ), newelt ) );
          A:= A^Dimension( K );
          bas:= NullspaceMat( A );
          bas:= List( bas, x -> LinearCombination( BasisOfDomain( K ), x ) );

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

        # If 'b = fail' then 'K' is nilpotent and we are done.
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
#M  AdjointAssociativeAlgebra( <L> )
##
##  This function calculates a basis of the associative matrix algebra
##  generated by ad L. If {x_1,\ldots ,x_n} is a basis of L, then this algebra
##  is spanned by all words
##                          ad x_{i_1}\cdots ad x_{i_t}
##  where t>0. The degree of such a word is t. The algorithm first calculates
##  a maximal linearly independent set of words of degree 1, then of degree
##  2 and so on. Since ad x ad y -ady ad x = ad [x,y], we have that we only have
##  to consider words where i_1\leq i_2\leq \cdots \leq i_t.
##
#T  The only improvement relative to the usual case is that the indices of
#T  words are non-decreasing.
#T  So maybe the usual mechanism should be adapted?
##
InstallMethod( AdjointAssociativeAlgebra,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local n,         #the dimension of L
          F,         #the field of L
          asbas,     #a list containing the basis elements of the assoc. alg.
          highdeg,   #a list of the elements of the highest degree computed
                     #so far
          degree1,   #a list of elements of degree 1 (i.e. ad x_i)
          lowinds,   #a list of indices such that lowinds[i] is the smallest
                     #index in the word highdeg[i]
          hdeg,      #the new highdeg constructed each step
          linds,     #the new lowinds constructed each step
          i,j,k,     #loop variables
          ind,       #an index
          m,         #a matrix
          posits,    #a list of positions in matrices: posits[i]
                     #is a list of the form [p,q] such that the matrix asbas[i]
                     #has a nonzero entry at position [p][q] and furthermore
                     #the matrices asbas[j] with j>i will have a zero
                     #at that position (so the basis constructed will be in
                     #'upper triangular form'
          l1,l2,     #loop variables
          found;     #a boolean

    if not IsLieAlgebra( L ) then
      Error( "<L> must be a Lie algebra" );
    elif IsAbelianLieAlgebra( L ) then
      return Algebra( F, [ AdjointMatrix( BasisOfDomain(L),
                                          GeneratorsOfAlgebra( L )[1] ) ] );
    fi;

    F:= LeftActingDomain( L );
    n:= Dimension( L );

    # Initialisations that ensure that the first step of the loop will select
    # a maximal linearly independent set of matrices of degree 1.

    degree1:= List( BasisVectors( BasisOfDomain(L) ),
                        x -> AdjointMatrix( BasisOfDomain(L), x ) );
    posits  := [ [ 1, 1 ] ];
    asbas   := [ IdentityMat( n, F ) ];
    highdeg := [ asbas[1] ];
    lowinds := [ n ];

    # If after some steps all words of degree t (say) can be reduced modulo
    # lower degree, then all words of degree >t can be reduced to linear
    # combinations of words of lower degree.
    # Hence in that case we are done.

    while highdeg <> [] do

      hdeg:= [];
      linds:= [];

      for i in [1..Length(highdeg)] do

        # Now we multiply all elements 'highdeg[i]' with all posible elements
        # of degree 1 (i.e. elements having an index <= the lowest index
        # of the word 'highdeg[i]')

        ind:= lowinds[i];
        for j in [1..ind] do

          m:= degree1[j]*highdeg[i];

          # Now we first reduce 'm' on the basis computed so far
          # and then add it to the basis.

          for k in [1..Length(posits)] do
            l1:= posits[k][1];
            l2:= posits[k][2];
            m:= m-(m[l1][l2]/asbas[k][l1][l2])*asbas[k];
          od;

          if not IsZero( m ) then

            #'m' is not an element of the span of 'asbas'

            Add( hdeg, m );
            Add( linds, j );
            Add( asbas, m);

            # Now we look for a nonzero entry in 'm'
            # and add the position of that entry to 'posits'.

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

      if lowinds = [n] then

        # We are in the first step and hence 'degree1' must be made
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
#M  NilRadical( <L> )
##
##  Let $p$ be the characteristic of the coefficients field of <L>.
##  If $p = 0$ or then we calculate a sequence of ideals
##  $I_k = \{ x\in I_{k-1} \mid Tr(ad y_{i_1} \cdots ad y_{i_k} ad x) = 0
##                              \forall i_1\leq i_2\leq \cdots \leq i_k \}$
##  where $\{ y_1, \ldots, y_n \}$ is a basis of <L>.
##  It can be proved that $I_{n-2}$ is equal to the nil radical.
##  However, in most cases $I_k$ will equal the nil radical for $k$ much
##  smaller than $n-2$. The calculation of the (increasing) 'words'
##
##               ad y_{i_1} \cdots ad y_{i_k}
##
##  is similar to the calculation of the basis in 'AdjointAssociativeAlgebra'.
##  For technical reasons we first calculate the solvable radical of <L>
##  (then the test whether an ideal is nilpotent is much easier).
##
##  In the case where $p>0$ we calculate the radical of the associative
##  matrix algebra $A$ generated by $ad 'L'$.
##  The nil radical is then equal to $\{ x\in L \mid ad x \in A \}$.
##
InstallMethod( NilRadical,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local F,           # the coefficients domain of 'L'
          p,           # the characteristic of 'F'
          bv,          # basis vectors of a basis of 'L'
          S,           # the solvable radical of 'L'
          adS,         # the list of matrices ad x_i where x_i runs through a
                       # basis of 'S'
          n,           # dimension of 'S'
          t,           # the dimension of an ideal
          eq,          # an equation
          eqs,         # equation set
          bb,          # list of coefficients of basis vectors
          I,           # basis vectors of an ideal of 'L'
          adI,         # list of the matrices ad x where x in 'I'
          cfs,         # coefficient vector
          i,j,k,l1,l2, # loop variables
          nilpotent,   # boolean
          elts,        # a list of elements computed in the preceding round
          hdeg,        # a list of the highest degrees of the elements of
                       # 'elts'
          newelts,     # the new list of elements
          newhdeg,     # the new list of highest degrees
          basis,       # a basis of the subspace of the enveloping algebra
                       # computed so far
          posits,      # a list of positions corresponding to 'basis'
          X,           # a matrix
          sol,         # solution set
          adL,         # list of matrices ad x where x runs through a basis of
                       # 'L'
          A,           # the algebra generated by ad L
          R,           # the radical of this algebra
          B,           # list of basis vectors of R
          x;           # element of L

    F:= LeftActingDomain( L );
    p:= Characteristic( F );

    if p = 0 then

      # The nilradical of <L> is equal to
      # the nilradical of its solvable radical.

      S:= SolvableRadical( L );
      adS:= List( BasisVectors( BasisOfDomain( S ) ),
                  x -> AdjointMatrix( BasisOfDomain( S ),x ) );
      n:= Dimension( S );

      # First we calculate $I_0$, the ideal of elements <x> of <S> such that
      # the trace of ad<x> is zero.

      eqs:= [ List( adS, x -> TraceMat(x) ) ];
      sol:= NullspaceMat( TransposedMat( eqs ) );
      I:= List( sol, x -> BasisVectors( BasisOfDomain(S) )*x );

      cfs:= List( I, x -> Coefficients( BasisOfDomain(S), x ) );
      adI:= List( cfs, x -> x*adS );

      # We check whether the ideal <I> is nilpotent
      # (this is precisely the case when all matrices ad<x> are nilpotent
      # where <x> is a basis element of <I>).

      nilpotent:= true;
      i:=1;
      while nilpotent and i < Length( I ) do
        nilpotent:= IsZero( adI[ i ]^n );
        i:= i+1;
      od;

      # At the beginning of the loop, the list of elements of highest degree
      # consists only of the identity matrix.
      # The list of basis elements of the adjoint associative algebra
      # calculated so far consists also only of the identity element.
      # It follows that the list of positions is '[1,1]]'
      # and the list of highest degree elements is '[1]'.

      elts:= [ IdentityMat(n,F) ];
      basis:= [ IdentityMat(n,F) ];
      posits:= [ [1,1] ];
      hdeg:= [ 1 ];

      while not nilpotent do

        newelts:= [ ];
        newhdeg:= [ ];
        eqs:= [ ];

        for i in [1..Length(elts)] do

          # We multiply an element of 'elts' by all basis elements

          for j in [hdeg[i]..n] do
            X:= elts[ i ]*adS[ j ];

            # Reduce 'X' w.r.t. the basis calculated so far.

            for k in [1..Length(basis)] do
              l1:= posits[k][1];
              l2:= posits[k][2];
              X:= X-(X[l1][l2]/basis[k][l1][l2])*basis[k];
            od;

            # If the reduced 'X' is nonzero, then we add it to the basis
            # and we calculate a new equation.

            if not IsZero( X ) then
              Add( newelts, X );
              Add( basis, X );

              # Find a nonzero entry in 'X'.

              l1:=1; l2:=1;
              while X[l1][l2]=0 do
                if l2 < n then
                  l2:= l2+1;
                else
                  l1:= l1+1;
                  l2:= 1;
                fi;
              od;
              Add( posits, [l1,l2] );
              Add( newhdeg, j );

              eq:= [ ];
              for k in [1..Length( I )] do
                Add( eq, TraceMat( X*adI[k] ) );
              od;
              Add( eqs, eq );

            fi;
          od;
        od;

        # Solve the equations.

        bb:= NullspaceMat( TransposedMat(eqs) );
        I:= List( bb, x -> x*I );

        # Update the list 'elts' of highest degree elements
        # and the corresponding list 'hdeg'.

        elts:= ShallowCopy( newelts );
        hdeg:= ShallowCopy( newhdeg );
        cfs:=List( I, x -> Coefficients( BasisOfDomain(S), x ) );
        adI:=List( cfs, x -> x*adS );

        # Nilpotency test.

        i:=1;
        nilpotent:= true;
        while nilpotent and i < Length( I ) do
          nilpotent:= IsZero( adI[i]^n );
          i:=i+1;
        od;

      od;

      return IdealNC( L, I, "basis" );

    else

      n:= Dimension( L );
      bv:= BasisVectors( BasisOfDomain(L) );
      adL:= List( bv, x -> AdjointMatrix(BasisOfDomain(L),x) );
      A:= AdjointAssociativeAlgebra( L );
      R:= RadicalOfAlgebra( A );

      if Dimension( R ) = 0 then

        # In this case the intersection of 'ad L' and 'R' is the centre of L.
        return LieCentre( L );

      fi;

      B:= BasisVectors( BasisOfDomain( R ) );
      t:= Dimension( R );

      # Now we compute the intersection of 'R' and '<ad L>'.

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
      I:= [];
      for i in [1..Length(sol)] do
        x:= Zero( L );
        for j in [1..n] do
          x:= x+sol[i][j]*bv[j];
        od;
        Add( I, x );
      od;
      return SubalgebraNC( L, I, "basis" );

    fi;

    end );


##############################################################################
##
#M  SolvableRadical( <L> )
##
##  In characteristic zero, the solvable radical of the Lie algebra <L> is
##  just the orthogonal complement of $[ <L> <L> ]$ w.r.t. the Killing form.
##
##  In characteristic $p > 0$, the following fact is used:
##  $R( <L> / NR( <L> ) ) = R( <L> ) / NR( <L> )$ where
##  $R( <L> )$ denotes the solvable radical of $L$ and $NR( <L> )$ its
##  nil radical).
##
InstallMethod( SolvableRadical,
    "method for a Lie algebra",
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

      LL:= DerivedSubalgebra( L );
      B:= BasisVectors( BasisOfDomain( KappaPerp( L, LL ) ) );

    else

      n:= NilRadical( L );

      if Dimension( n ) = 0 or Dimension( n ) = Dimension( L ) then
        return n;
      fi;

      hom:= NaturalHomomorphismByIdeal( L, n );
      quo:= ImagesSource( hom );
      r1:= SolvableRadical( quo );
      B:= BasisVectors( BasisOfDomain( r1 ) );
      B:= List( B, x -> PreImagesRepresentative( hom, x ) );
      Append( B, BasisVectors( BasisOfDomain( n ) ) );

    fi;

    SetIsSolvableAlgebra( L, Length( B ) = Dimension( L ) );

    return IdealNC( L, B, "basis");

    end );


###############################################################################
##
#M  LeviDecomposition( <L> )
##
##  A Levi subalgebra of 'L' is a semisimple subalgebra complementary to
##  the solvable radical 'R'. We find a Levi subalgebra of 'L' by first
##  computing a complementary subspace to 'R'. This subspace is a Levi
##  subalgebra modulo 'R'. Then we change the basis vectors such that they
##  form a basis of a Levi subalgebra modulo the second term of the derived
##  series of 'R' after that we consider the third term of the derived series,
##  and so on.
##
InstallMethod( LeviDecomposition,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local R,             # The solvable radical of 'L'.
          s,             # The dimension of the Levi subalgebra.
          F,             # coefficients domain of 'L'
          bas,bb,        # Lists of basiselements.
          sp,            # A vector space.
          a,i,j,k,l,m,   # Loop variables.
          x,             # Element of 'L'.
          ser,           # The derived series of 'R'.
          p,             # The length of the derived series.
          Rbas,          # A special basis of 'R'.
          levi,          # Basis of a Levi complement.
          T,             # Structure constants table of 'L', w.r.t. a
                         # particular basis.
          cf,cf1,cf2,    # Coefficient vectors.
          klist,         # List of integers.
          comp,          # List of basis vectors of a complement.
          dim,           # The length of 'comp'.
          B,             # A basis.
          cij,           # Entry of the table of structure constants.
          eqs,           # Matrix of equation set.
          rl,            # Right hand side of the equation system.
          eqno,          # Number of the equation.
          sol,           # Solution set to the equations.
          r;             # Integer.

    R:= SolvableRadical( L );
    if Dimension( R ) = 0 then
      return [ L, R ];
    fi;

    s:= Dimension( L ) - Dimension( R );

    # 'bb' will be a basis of a complement to 'R' in 'L'.

    bas:= ShallowCopy( BasisVectors( BasisOfDomain( R ) ) );
    F:= LeftActingDomain( L );
    sp:= MutableBasisByGenerators( F, bas );
    bb:= [ ];
    for k in BasisVectors( BasisOfDomain( L ) ) do
      if Length( bb ) = s then
        break;
      elif not IsContainedInSpan( sp, k ) then
        Add( bb, k );
        CloseMutableBasis( sp, k );
      fi;
    od;

    ser:= DerivedSeriesOfAlgebra( R );

    # We now calculate a basis of 'R' such that the first k1 elements
    # form a basis of the last nonzero term of the derived series 'ser',
    # the first k2 ( k2>k1 ) elements form a basis of the next to last
    # element of the derived series, and so on.

    p:= Length( ser );
    i:= p-1;
    Rbas:= ShallowCopy( BasisVectors( BasisOfDomain( ser[p-1] ) ) );
    sp:= MutableBasisByGenerators( F, Rbas );
    while Length(Rbas) < Dimension(R) do
      if Length(Rbas) = Dimension(ser[i]) then
        i:= i-1;
        k:= 1;
      else
        x:= BasisVectors( BasisOfDomain( ser[i] ) )[k];
        if not IsContainedInSpan( sp, x ) then
          Add( Rbas, x );
          CloseMutableBasis( sp, x );
        fi;
        k:= k+1;
      fi;
    od;

    levi:= ShallowCopy( bb );
    Append(bb,Rbas);

    # So now 'bb' is a list of basis vectors of 'L' such that
    # the first elements form a basis of a complement to 'R'
    # and the remaining elements are a basis for 'R' of the form
    # described above.
    # We now calculate a structure constants table of 'L' w.r.t. this basis.

    sp:= VectorSpace( F, bb );
    B:= BasisByGeneratorsNC( sp, bb );
    T:= List([1..s],x->[]);
    for i in [1..s] do
      for j in [i+1..s] do
        cf:= Coefficients( B, levi[i]*levi[j] ){[1..s]};
        klist:= Filtered([1..s],i->cf[i]<>0);
        cf:= Filtered(cf,x->x<>0);
        T[i][j]:= [klist,cf];
      od;
    od;

    # Now 'levi' is a Levi subalgebra modulo 'R'.
    # The loop modifies this modulo statement.
    # After the first round 'levi' will be a Levi subalgebra modulo
    # the second element of the derived series.
    # After the second step 'levi' will be a Levi subalgebra modulo
    # the third element of the derived series.
    # And so on.

    for a in [1..p-1] do

      # 'comp' will be a basis of the complement of the 'a+1'-th element
      # of the derived series in the 'a'-th element of the derived series.
      # 'B' will be a basis of the 'a'-th term of the derived series,
      # such that the basis elements of the complement come first.
      # So if we have an element v of the 'a'-th term of the derived series,
      # then by taking the coefficients w.r.t. 'B', we can easily find
      # the part that belongs to 'comp'.
      # The equations we have are vector equations in the space 'comp',
      # i.e., in the quotient of two elements of the derived series.
      # But we do not want to work with this quotient directly.

      comp:= Rbas{ [ Dimension(ser[a+1])+1 .. Dimension(ser[a]) ] };
      dim:= Length(comp);
      bb:= ShallowCopy( comp );
      for i in [1..Dimension(ser[a+1])] do
        Add(bb,Rbas[i]);
      od;
      sp:= VectorSpace( F, bb );
      B:= BasisByGeneratorsNC( sp, bb );

      cf:= List( comp, x -> Coefficients( B, x ){[1..dim]} );
      eqs:= NullMat( s*dim, dim*s*(s-1)/2, F );
      rl:= [];
      for i in [1..s] do
        for j in [i+1..s] do
          cij:= T[i][j];
          for k in [1..dim] do

            cf1:= Coefficients(B,levi[i]*comp[k]){[1..dim]};
            cf2:= Coefficients(B,comp[k]*levi[j]){[1..dim]};

            for l in [1..dim] do
              eqno:=(i-1)*(2*s-i)*dim/2+(j-i-1)*dim+l;

              eqs[(j-1)*dim+k][eqno]:= eqs[(j-1)*dim+k][eqno]+cf1[l];
              eqs[(i-1)*dim+k][eqno]:= eqs[(i-1)*dim+k][eqno]+cf2[l];

              for m in [1..Length(cij[1])] do
                r:=cij[1][m];
                if r <= s then
                  eqs[(r-1)*dim+k][eqno]:= eqs[(r-1)*dim+k][eqno]-
                                           cij[2][m]*cf[k][l];
                fi;
              od;
            od;
          od;

          x:= Zero(L);
          for m in [1..Length(cij[1])] do
            if cij[1][m] <= s then
              x:= x+cij[2][m]*levi[cij[1][m]];
            fi;
          od;
          x:= x-levi[i]*levi[j];
          Append(rl,Coefficients(B,x){[1..dim]});

        od;
      od;

      sol:= SolutionMat( eqs, rl );

      for i in [1..s] do
        for j in [1..dim] do
          levi[i]:=levi[i]+sol[(i-1)*dim+j]*comp[j];
        od;
      od;
    od;

    return [ SubalgebraNC( L, levi, "basis" ), R ];
    end );


##############################################################################
##
#M  DirectSumDecomposition( <L> )
##
##  This function calculates a list of ideals of 'L' such that 'L' is equal
##  to the direct sum of them.
##  The existence of a decomposition of 'L' is equivalent to the existence
##  of a nontrivial idempotent in the centralizer of 'ad L' in the full
##  matrix algebra 'M_n(F)'. In the general case we try to find such
##  idempotents.
##  In the case where the characteristic of the field of 'L' is not 2 or 3
##  and the Killing form of 'L' is nondegenerate we can use a more
##  elegant method. In this case the action of the Cartan subalgebra will
##  'identify' the direct summands.
##
InstallMethod( DirectSumDecomposition,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local F,                # The field of 'L'.
          BL,               # basis of 'L'
          bvl,              # basis vectors of 'BL'
          n,                # The dimension of 'L'.
          m,                # An integer.
          set,              # A list of integers.
          ready,            # A boolean.
          C,                # The centre of 'L'.
          bvc,              # basis vectors of a basis of 'C'
          D,                # The derived subalgebra of 'L'.
          CD,               # The intersection of 'C' and 'D'.
          H,                # A Cartan subalgebra of 'L'.
          BH,               # basis of 'H'
          basH,             # List of basis vectors of 'H'.
          B,                # A List of direct summands (subspaces) of 'L'.
          BBj,              # basis for 'B[j]'
          newB,             # The new 'B' that is being constructed.
          V,                # List of vectors.
          cf,cfs,           # Coefficient list.
          comlist,          # List of commutators.
          ideals,           # List of ideals.
          bb,               # List of basis vectors.
          B1,B2,            # Bases of the ideals.
          sp,               # A vector space.
          x,                # An element of 'sp'.
          b,                # A list of basis vectors.
          u,i,j,k,          # Loop variables.
          centralizer,      # The centralizer of 'adL' in the matrix algebra.
          Bc,               # basis of 'centralizer'
          Rad,              # The radical of 'centralizer'.
          c,                # The dimension of 'centralizer'.
          r,                # The dimension of 'Rad'.
          M,                # A matrix.
          facs,             # A list of factors of a polynomial.
          hlist,            #
          f,p,g,gcd,        # Polynomials.
          contained,        # Boolean variable.
          adL,              # A basis of the matrix space 'ad L'.
          Q,                # The factor algebra 'centralizer/Rad'
          bQ,               # A basis of 'Q'.
          q,                # Number of elements of the field of 'L'.
          ei,ni,e,          # Elements from 'centralizer'
          hom,              # A homomorphism.
          id,               # A list of idempotents.
          vv;               # A list of vectors.

    F:= LeftActingDomain( L );
    n:= Dimension( L );

    if ( not Characteristic( F ) in [2,3] ) and
       ( DeterminantMat( KillingMatrix( BasisOfDomain( L ) ) ) <> Zero(F) )
    then

      # The algorithm works as follows.
      # Let 'H' be a Cartan subalgebra of 'L'.
      # First we decompose 'L' into a direct sum of subspaces 'B[i]'
      # such that the minimum polynomial of the adjoint action of an element
      # of 'H' restricted to 'B[i]' is irreducible.
      # If 'L' is a direct sum of ideals, then each of these subspaces
      # will be contained in precisely one ideal.
      # If the field 'F' is big enough then we can look for a splitting
      # element in 'H'.
      # This is an element 'h' such that the minimum polynomial of 'ad h'
      # has degree 'dim L - dim H + 1'.
      # There is a powerful randomised algorithm for finding such an element.

      H:= CartanSubalgebra( L );
      BH:= BasisOfDomain( H );
      m:= ( n - Dimension(H) ) * ( n - Dimension(H) + 1 ) / 4;

      if 2*m < Size(F) then

        set:= [ -m .. m ];
        repeat
          cf:= List([ 1 .. Dimension( H ) ], x -> Random( set ) );
          x:= LinearCombination( BH, cf );
          M:= AdjointMatrix( BL, x );
          f:= MinimalPolynomial( F, M );
        until DegreeOfUnivariateLaurentPolynomial( f )
                  = Dimension( L ) - Dimension( H ) + 1;

        facs:= Factors( f );
        B:= [];
        for i in facs do
          Add( B, List( NullspaceMat( TransposedMat( Value( i, M ) ) ),
                            x -> LinearCombination( BL, x ) ) );
        od;

      else

        B:= [ ShallowCopy( BasisVectors( BL ) ) ];
        basH:= ShallowCopy( BasisVectors( BH ) );

        for i in [1..Length(basH)] do

          # We try to split every component in 'B' into subspaces
          # stable under ad basH[i] and such that the minimum polynomial
          # of this operator restriced to each new component is irreducible.

          newB:= [ ];

          for j in [1..Length(B)] do

            BBj:= BasisOfDomain( VectorSpace( F, B[j], "basis" ) );
            M:= List( B[j], x -> Coefficients( BBj, basH[i]*x ) );
            f:= MinimalPolynomial( F, M );
            facs:= Factors( f );

            for k in [1..Length(facs)] do
              V:= NullspaceMat( Value( facs[k], M ) );
              Add( newB, List( V, x -> LinearCombination( B[j], x ) ) );
            od;
          od;

          B:= newB;

        od;

      fi;

      B:= Filtered( B, x -> not ( x[1] in H ) );

      # Now the pieces in 'B' are grouped together.

      ideals:=[];

      while B <> [ ] do

        # Check whether 'B[1]' is contained in any of
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

          # 'B[1]' generates a new ideal.
          # We form this ideal by taking 'B[1]' together with
          # all pieces from 'B' that do not commute with 'B[1]'.

          bb:= B[1];
          B:= Filtered( B, x -> x<> B[1] );
          i:=1;
          while i<= Length( B ) do

            comlist:= List( bb, x -> List( B[i], y -> x*y ) );
            comlist:= Filtered( Flat( comlist ), x -> x <> Zero( L ) );
            if comlist <> [] then
              Append( bb, B[i] );
              B:= Filtered( B, x -> x <> B[i] );
            else
              i:=i+1;
            fi;

          od;

          Add( ideals, SubalgebraNC( L, bb ) );
#T is this a basis ??
#T (if yes then use this!!)

        fi;

      od;

      return List( ideals,
          I -> IdealNC( L, BasisVectors( BasisOfDomain( I ) ), "basis" ));
#T why to construct them again?

    else

      # First we try to find a central component, i.e., a decomposition
      # 'L=I_1 \oplus I_2' such that 'I_1' is contained in the center of 'L'.
      # Such a decomposition exists if and only if the center of 'L' is not
      # contained in the derived subalgebra of 'L'.

      C:= LieCentre( L );
      bvc:= BasisVectors( BasisOfDomain( C ) );
      BL:= BasisOfDomain( L );
      bvl:= BasisVectors( BL );

      if 0 < Dimension( C ) then

        D:= DerivedSubalgebra( L );
        CD:= Intersection2( C, D );

        if Dimension( CD ) < Dimension( C ) then

          # The central component is the complement of 'C \cap D' in 'C'.

          B1:=[];
          k:=1;
          sp:= MutableBasisByGenerators( F,
                   BasisVectors( BasisOfDomain( CD ) ), Zero( CD ) );
          while Length( B1 ) + Dimension( CD ) <> Dimension( C ) do
            x:= bvc[k];
            if not IsContainedInSpan( sp, x ) then
              Add( B1, x );
              CloseMutableBasis( sp, x );
            fi;
            k:=k+1;
          od;

          # The second ideal is a complement of the central component
          # in 'L' containing 'D'.

          B2:= BasisVectors( BasisOfDomain( D ) );
          k:= 1;
          b:= ShallowCopy( B1 );
          Append( b, B2 );
          sp:= MutableBasisByGenerators( F, b );
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
          return List( ideals, I ->
              IdealNC( L, BasisVectors( BasisOfDomain(I) ), "basis" ) );
#T why to construct them again?

        fi;

      fi;

      # Now we assume that 'L' does not have a central component
      # and compute the centralizer of 'ad L' in 'M_n(F)'.

      adL:= List( bvl, x -> AdjointMatrix( BL, x ) );

      centralizer:= FullMatrixAlgebraCentralizer( F, adL );
      Bc:= BasisOfDomain( centralizer );

      Rad:= RadicalOfAlgebra( centralizer );

      if Dimension( centralizer ) - Dimension( Rad ) = 1 then
        return [ L ];
      fi;

      # Let 'Q' be the semisimple commutative associative algebra
      # 'centralizer/Rad'.
      # We calculate a complete set of orthogonal idempotents in 'Q'
      # and then lift them to 'centralizer'.

      hom:= NaturalHomomorphismByIdeal( centralizer, Rad );
      Q:= ImagesSource( hom );
      bQ:= BasisVectors( BasisOfDomain( Q ) );

      repeat

        # We try to find an element of 'Q' that generates it.
        # If we take the coefficients of such an element randomly
        # from a set of '2*Dimension(Q)^2' elements,
        # then this element generates 'Q' with probability 1/2
        # (see W. Eberly, Decomposition of algebras over finite fields
        # and number fields, Comp. Complex. 1, 179--206 (1991)).
        # If 'A' is defined over a finite field then we can just take
        # the set of its elements.

        if Characteristic( F ) = 0 then
          cfs:= [ -Dimension(Q)^2 .. Dimension(Q)^2 ];
        else
          cfs:= Filtered( AsList(F), x -> not IsZero( x ) );
        fi;

        cf:= List( [ 1 .. Length(bQ) ], x -> Random( cfs ) );
        e:= LinearCombination( bQ, cf );

        # Now we calculate the minimum polynomial of 'e'.

        sp:= MutableBasisByGenerators( F, [ One( Q ) ] );
        vv:= [ One( Q ) ];
        x:= e;
        while not IsContainedInSpan( sp, x ) do
          Add( vv, x );
          CloseMutableBasis( sp, x );
          x:= x*e;
        od;
        sp:= UnderlyingLeftModule( ImmutableBasis( sp ) );
        cf:= - Coefficients( BasisByGeneratorsNC( sp, vv ), x );
        Add( cf, 1 );
        f:= ElementsFamily( FamilyObj( F ) );
        f:= UnivariateLaurentPolynomialByCoefficients( f, cf, 1 );

      until DegreeOfUnivariateLaurentPolynomial( f ) = Dimension( Q );

      facs:= Factors( f );

      # Now we find elements h1,...,hs such that 'hi = 1 mod facs[i]' and
      # 'hi = 0 mod facs[j]' if 'i<>j'.
      # This is possible due to the Chinese remainder theorem.

      hlist:= [ ];
      for i in [1..Length( facs )] do
        cf:= List( [ 1..Length( facs ) ], x -> 0 );
        cf[i]:= 1;
        j:= 1;
        c:= cf[1];
        p:= facs[1];
        while j < Length(facs) do
          j:= j + 1;
          g:= GcdRepresentation( p, facs[j] );
          gcd:= g[1]*p+g[2]*facs[j];
          c:= p * (( g[1]*(cf[j]-c) / gcd  ) mod facs[j]) + c;
          p:= p*facs[j] / gcd;
        od;

        Add( hlist, c mod p );

      od;

      # Now a complete set of orthogonal idempotents is given by 'hi(e)'.
      # Finally we lift the idempotents to 'centralzer'.

      id:= List( hlist, h -> Value( h, e ) );
      id:= List( id, e -> PreImagesRepresentative( hom, e ) );

      # We have that 'id[i]^2-id[i]' is an element of 'Rad'.
      # We construct the sequences e_{i+1} = e_i + n_i - 2e_in_i,
      # and n_{i+1}=e_{i+1}^2-e_{i+1}, starting with e_0=id[i].
      # It can be proved by induction that e_q is an idempotent in 'A'
      # because n_0^{2^q}=0.

      q:= 0;
      while 2^q <= Dimension( Rad ) do
        q:= q+1;
      od;
      for i in [ 1 .. Length(id) ] do
        ei:= id[i];
        ni:= ei*ei-ei;
        for j in [1..q] do
          ei:= ei+ni-2*ei*ni;
          ni:= ei*ei-ei;
        od;
        id[i]:= ei;
      od;

      # For every idempotent of 'centralizer' we calculate
      # a direct summand of 'L'.

      ideals:= List( id, e -> List( TransposedMat( e ), v ->
                    LinearCombination( BL, v ) ) );
      ideals:= List( ideals, ii -> BasisVectors(
                        BasisOfDomain( VectorSpace( F, ii ) ) ) );

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
    "method for a Lie algebra in characteristic zero",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )
    if Characteristic( LeftActingDomain( L ) ) <> 0 then
      TryNextMethod();
    elif DeterminantMat( KillingMatrix( BasisOfDomain( L ) ) ) = 0 then
      return false;
    else
      return Length( DirectSumDecomposition( L ) ) = 1;
    fi;
    end );


##############################################################################
##
#F  FindSl2( <L>, <x> )
##
FindSl2 := function( L, x )

   local n,         # the dimension of 'L'
         F,         # the field of 'L'
         B,         # basis of 'L'
         T,         # the table of structure constants of 'L'
         xc,        # coefficient vector
         eqs,       # a system of equations
         i,j,k,l,   # loop variables
         cij,       # the element 'T[i][j]'
         b,         # the right hand side of the equation system
         v,         # solution of the equations
         z,         # element of 'L'
         h,         # element of 'L'
         R,         # centralizer of 'x' in 'L'
         BR,        # basis of 'R'
         Rvecs,     # basis vectors of 'R'
         H,         # the matrix of 'ad H' restricted to 'R'
         e0,        # coefficient vector
         e1,        # coefficient vector
         y;         # element of 'L'

    if not IsNilpotentElement( L, x ) then
      Error( "<x> must be a nilpotent element of the Lie algebra <L>" );
    fi;

    n:= Dimension( L );
    F:= LeftActingDomain( L );
    B:= BasisOfDomain( L );
    T:= StructureConstantsTable( B );

    xc:= Coefficients( B, x );
    eqs:= NullMat( 2*n, 2*n, F );

    # First we try to find elements 'z' and 'h' such that '[x,z]=h'
    # and '[h,x]=2x' (i.e., such that two of the three defining equations
    # of sl_2 are satisfied).
    # This results in a system of '2n' equations for '2n' variables.

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

    if v = false then
      # There is no sl_2 containing <x>.
      return false;
    fi;

    z:= v{ [   1 ..   n ] } * BasisVectors( B );
    h:= v{ [ n+1 .. 2*n ] } * BasisVectors( B );

    R:= LieCentralizer( L, SubalgebraNC( L, [ x ] ) );
    BR:= BasisOfDomain( R );
    Rvecs:= BasisVectors( BR );

    # 'ad h' maps 'R' into 'R'. 'H' will be the matrix of that map.

    H:= List( Rvecs, v -> Coefficients( BR, h * v ) );

    # By the proof of the lemma of Jacobson-Morozov (see Jacobson,
    # Lie Algebras, p. 98) there is an element 'e1' in 'R' such that
    # '(H+2)e1=e0' where 'e0=[h,z]+2z'.
    # If we set 'y=z-e1' then 'x,h,y' will span a subalgebra of 'L'
    # isomorphic to sl_2.

    H:= H+2*IdentityMat( Dimension( R ), F );

    e0:= Coefficients( BR, h * z + 2*z );
    e1:= SolutionMat( H, e0 );

    if e1 = fail then
      # There is no sl_2 containing <x>.
      return fail;
    fi;

    y:= z-e1*Rvecs;

    return SubalgebraNC( L, [x,h,y], "basis" );
end;


#############################################################################
##
#M  SemiSimpleType( <L> )
##
##  This function works for Lie algebras over a field of characteristic not
##  2 or 3, having a nondegenerate Killing form. Such Lie algebras are
##  semsimple. They are characterized as direct sums of simple Lie algebras,
##  and these have been classified: a simple Lie algebra is either an element 
##  of the "great" classes of simple Lie algebas (A_n, B_n, C_n, D_n), or
##  an exceptional algebra (E_6, E_7, E_8, F_4, G_2). This function finds
##  the type of the semisimple Lie algebra 'L'. Since for the calculations
##  eigenvalues and eigenvectors of the action of a Cartan subalgebra are
##  needed, we reduce the Lie algebra mod p (if it is of characteristic 0).
##  The p may not divide the determinant of the matrix of the Killing form,
##  nor may it divide the last nonzero coefficient of a minimum polynomial
##  of an element of the basis of the Cartan subalgebra.
##
InstallMethod( SemiSimpleType,
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local CartanInteger, # Function that computes the Cartan integer.
          a,             # Element of 'L'.
          T,S,S1,        # Structure constants tables.
          den,           # Denominator of a structure constant.
          denom,         # Common denominator.
          i,j,k,         # Loop variables.
          K,             # A Lie algebra.
          BK,            # basis of 'K'
          d,             # The determinant of the Killing form of 'K'.
          p,             # A prime.
          H,             # Cartan subalgebra.
          s,             # An integer.
          mp,            # List of minimum polynomials.
          F,             # Field.
          bas,           # List of basis vectors.
          simples,       # List of simple subalgebras.
          types,         # List of the types of the elements of simples.
          I,             # An element of simples.
          HI,            # Cartan subalgebra of 'I'.
          BI,            # basis of 'I'
          rk,            # The rank of 'I'.
          adH,           # List of adjoint matrices.
          R,             # Root system.
          basR,          # Basis of 'R'.
          posR,          # List of the positive roots.
          fundR,         # A fundamental system.
          r,r1,r2,rt,    # Roots.
          Rvecs,         # List of root vectors.
          basH,          # List of basis vectors of a Cartan subalgebra of 'I'.
          sp,            # Vector space.
          h,             # Element of a Cartan subalgebra of 'I'.
          cf,            # Coefficient.
          issum,         # Boolean.
          CM,            # Cartan Matrix.
          endpts;        # The endpoints of the Dynkin diagram of 'I'.

    # The following function computes the Cartan integer of two roots
    # 'r1' and 'r2'.
    # If 's' and 't' are the largest integers such that 'r1 - s*r2' and 
    # 'r1 + t*r2' are elements of the root system 'R',
    # then the Cartan integer of 'r1' and 'r2' is 's-t'.

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

    # First we produce a basis of 'L' such that the first basis elements
    # form a basis of a Cartan subalgebra of 'L'.
    # Then we multiply by an integer in order to ensure that
    # the structure constants are integers.
    # Finally we reduce modulo an appropriate prime 'p'.

    F:= LeftActingDomain( L );
    H:= CartanSubalgebra( L ); 
    rk:= Dimension( H );
    bas:= BasisVectors( Basis( H ) );
    sp:= MutableBasisByGenerators( F, bas );
    k:= 1;
    for a in BasisVectors( BasisOfDomain( L ) ) do
      if Length( bas ) = Dimension( L ) then
        break;
      elif not IsContainedInSpan( sp, a ) then
        Add( bas, a );
        CloseMutableBasis( sp, a );
      fi;
    od;

    T:= StructureConstantsTable( BasisByGeneratorsNC( L, bas ) );
    denom:= 1;
    for i in [1..Dimension(L)] do
      for j in [1..Dimension(L)] do
        for k in [1..Length(T[i][j][2])] do
           den:= DenominatorRat( T[i][j][2][k] );
           if den <> 1 then
             denom:= LcmInt( denom, den );
           fi; 
        od;
      od;
    od;

    if denom <> 1 then
      S:= List( T, row -> List( row, ShallowCopy ) );
      for i in [ 1 .. Dimension(L) ] do
        for j in [1..Dimension(L)] do
          S[i][j][2]:= denom * T[i][j][2];
        od;
      od;
    else 
      S:= T;
    fi;

    K:= LieAlgebraByStructureConstants( F, S );

    BK:= CanonicalBasis( K );
    mp:= List( [ 1 .. rk ],
               x -> MinimalPolynomial( F, AdjointMatrix( BK, BK[x] ) ) );
    d:= DeterminantMat( KillingMatrix( BK ) );
    d:= d * Product( List( mp, p -> Value( p, 0 ) ) );
#T    d:= d * Product( List( mp, p -> p.coefficients[1] ) );
#T    what does 'p.coefficients[1]' mean?
#T    coefficient of x^0 or first nonzero coefficient (or both in this case)?
    p:= 5;
    s:= 7;
    
    # We determine a prime 'p>5' not dividing 'd' and an integer 's'
    # such that the minimum polynomials of the basis elements of the Cartan
    # subalgebra will split into linear factors over the field of 'p^s'
    # elements, and such that 'p^s<=2^16'
    # (the maximum size of a finite field in GAP).

    while p^s > 65536 do

      while d mod p = 0 do
        p:= NextPrimeInt( p );
      od;

      F:= GF( p );

      S1:= List( S, row -> List( row, ShallowCopy ) );
      for i in [1..Dimension(K)] do
        for j in [1..Dimension(K)] do
          S1[i][j][2]:= List( S[i][j][2], x -> ( x mod p ) * One( F ) );
        od;
      od;
      S1[ Length(S) ]:= Zero( F );

      K:= LieAlgebraByStructureConstants( F, S1 );

      # We do already know a Cartan subalgebra of 'K'.
      H:= SubalgebraNC( K, BasisVectors( CanonicalBasis(K) ){ [ 1 .. rk ] },
                        "basis" );
      SetCartanSubalgebra( K, H );    

      mp:= List( BasisVectors( CanonicalBasis( H ) ), v -> 
               MinimalPolynomial( AdjointMatrix( CanonicalBasis(K), v ) ) );
      s:= Lcm( Flat( List( mp, p -> List( Factors( p ),
                                DegreeOfUnivariateLaurentPolynomial ) ) ) );

      if p=65521 then p:=1; fi;
#T ?
      
    od;

    if p = 1 then
      Info( InfoAlgebra, 1,
            "can't find modular splitting field of order < 2^16 for <L>" );
      return fail;
    fi;

    K:= LieAlgebraByStructureConstants( GF( p^s ), S1 );
    H:= SubalgebraNC( K, BasisVectors( CanonicalBasis( K ) ){ [ 1 .. rk ] },
                      "basis" );
    SetCartanSubalgebra( K, H );

    simples:= DirectSumDecomposition( K ); 

    types:= "";

    # Now for every simple Lie algebra in simples we have to determine
    # its type.
    # For Lie algebras not equal to B_l, C_l or E_6,
    # this is determined by the dimension and the rank.
    # In the other cases we have to examine the root system.

    for I in simples do

      if IsEmpty( types ) then
        Add( types, ' ' );
      fi;

      F  := LeftActingDomain( I );
      BI := BasisOfDomain( I );
      HI := Intersection( H, I );
      rk := Dimension( HI );
      
      if   Dimension( I ) = 133 and rk = 7 then
        Append( types, "E7" );
      elif Dimension( I ) = 248 and rk = 8 then
        Append( types, "E8" );
      elif Dimension( I ) =  52 and rk = 4 then
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
          # the root vectors are contained in the basis of 'I'.

          adH:= List( BasisVectors( BasisOfDomain( HI ) ),
                      x -> AdjointMatrix( BI, x ) );
          R:= [];
          Rvecs:= [];
          for i in [ 1 .. Dimension( I ) ] do
            rt:= List( adH, x -> x[i][i] );
            if not IsZero( rt ) then 
              Add( R, rt ); 
              Add( Rvecs, BasisVectors( BI )[i] );
            fi;
          od;

          # A set of roots 'basR' is determined such that the set 
          # { [x_r,x_{-r}] | r\in basR } is a basis of 'HI'.

          basH:= [ ];
          basR:= [ ];
          sp:= MutableBasisByGenerators( F, [], Zero(I) );
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
            i:=i+1;
          od;

          # 'posR' will be the set of positive roots.
          # A root 'r' is called positive if in the list
          # [ < r, basR[i] >, i=1...Length(basR) ] the first nonzero
          # coefficient is positive
          # (< r_1, r_2 > is the Cartan integer of r_1 and r_2).
            
          posR:= [ ];
          for r in R do
            if (not r in posR) and (not -r in posR) then
              cf:= Zero( F );
              i:= 0;
              while cf = Zero( F ) do
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
                fi;
              od;
            od;
            if not issum then
              Add( fundR, r );
            fi;
          od;

          # 'CM' will be the matrix of Cartan integers
          # of the fundamental roots.

          CM:= List( fundR, i -> List( fundR,
                      j -> CartanInteger( R, i, j ) ) );

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
    "method for a Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local n,     # the dimension of 'L'
          F,     # the field over which 'L' is defined
          bvecs, # a list of the basisvectors of 'L'
          D,     # a list of elements of 'L', forming a basis of a nilpotent
                 # subspace
          sp,    # the space spanned by 'D'
          r,     # the dimension of 'sp'
          found, # a Boolean variable
          i, j,  # loop variables
          b, c,  # elements of 'L'
          elm;   #

    # First rule out some trivial cases.
    n:= Dimension( L );
    if n = 1 or n = 0 then
      return fail;
    fi;

    F:= LeftActingDomain( L );
    bvecs:= BasisVectors( BasisOfDomain( L ) );

    if Characteristic( F ) <> 0 then

      # 'D' will be a basis of a nilpotent subalgebra of L.
      if IsNilpotentElement( L, bvecs[1] ) then
        D:= [ bvecs[1] ];
      else
        return bvecs[1];
      fi;

      # 'r' will be the dimension of the span of 'D'.
      # If 'r = n' then 'L' is nilpotent and hence does not contain
      # non nilpotent elements.
      r:= 1;

      while r < n do

        sp:= VectorSpace( F, D, "basis" );

        # We first find an element 'b' of 'L' that does not lie in 'sp'.
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

        # We now replace 'b' by 'b * D[i]' if
        # 'b * D[i]' lies outside 'sp' in order to ensure that
        # '[b,sp] \subset sp'.
        # Because 'sp' is a nilpotent subalgebra we only need
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

      # Now 'char F =0'.
      # In this case either 'L' is nilpotent or one of the
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
    # hence 'L' is nilpotent.
    return fail;

    end );


##############################################################################
##
#M  RootSystem( <L> )
##
InstallMethod( RootSystem,
    "method for a (semisimple) Lie algebra",
    true,
    [ IsAlgebra and IsLieAlgebra ], 0,
    function( L )

    local F,          # coefficients domain of 'L'
          BL,         # basis of 'L'
          H,          # A Cartan subalgebra of 'L'
          basH,       # A basis of 'H'
          sp,         # A vector space
          B,          # A list of bases of subspaces of 'L' whose direct sum
                      # is equal to 'L'
          newB,       # A new version of 'B' being constructed
          i,j,k,l,    # Loop variables
          p,          # A polynomial
          facs,       # List of the factors of 'p'
          V,          # A basis of a subspace of 'L'
          M,          # A matrix
          cf,         # A scalar
          a,          # A root vector
          ind,        # An index
          basR,       # A basis of the root system
          h,          # An element of 'H'
          posR,       # A list of the positive roots
          fundR,      # A list of the fundamental roots
          issum,      # A boolean
          CartInt,    # The function that calculates the Cartan integer of
                      # two roots
          C,          # The Cartan matrix
          S,          # A list of the root vectors
          zero,       # zero of 'F'
          hts,        # A list of the heights of the root vectors
          sorh,       # The set 'Set( hts )'
          sorR,       # The soreted set of roots
          Rvecs;      # The root vectors.


    # Let 'a' and 'b' be two roots of the rootsystem 'R'.
    # Let 's' and 't' be the largest integers such that 'a-s*b' and 'a+t*b'
    # are roots.
    # Then the Cartan integer of 'a' and 'b' is 's-t'.
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

    if DeterminantMat( KillingMatrix( BasisOfDomain( L ) ) ) = Zero( F ) then
      Info( InfoAlgebra, 1, "the Killing form of <L> is degenerate" );
      return fail;
    fi;


    # First we compute the common eigenvectors of the adjoint action of a
    # Cartan subalgebra 'H'. Here 'B' will be a list of bases of subspaces
    # of 'L' such that 'H' maps each element of 'B' into itself.
    # Furthermore, 'B' has maximal length w.r.t. this property.

    H:= CartanSubalgebra( L );
    BL:= BasisOfDomain( L );
    B:= [ ShallowCopy( BasisVectors( BL ) ) ];
    basH:= BasisVectors( Basis( H ) );

    for i in basH do

      newB:= [ ];
      for j in B do

        V:= BasisOfDomain( VectorSpace( F, j, "basis" ) );
        M:= List( j, x -> Coefficients( V, i*x ) );
        facs:= Factors( MinimalPolynomial( F, M ) );

        for l in facs do
          V:= NullspaceMat( Value( l, M ) );
          Add( newB, List( V, x -> LinearCombination( j, x ) ) );
        od;

      od;
      B:= newB;

    od;

    # Now we throw away the subspace 'H'.

    B:= Filtered( B, x -> ( not x[1] in H ) );

    # If an element of 'B' is not one dimensional then 'H' does not split
    # completely, and hence we cannot compute the root system.

    for i in [ 1 .. Length(B) ] do
      if Length( B[i] ) <> 1 then
        Info( InfoAlgebra, 1, "the Cartan subalgebra of <L> in not split" );
        return fail;
      fi;
    od;

    # Now we compute the set of roots 'S'.
    # A root is just the list of eigenvalues of the basis elements of 'H'
    # on an element of 'B'.

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

    Rvecs:= Flat( B );

    # A set of roots 'basR' is calculated such that the set
    # { [ x_r, x_{-r} ] | r\in R } is a basis of 'H'.

    basH:= [ ];
    basR:= [ ];
    sp:= MutableBasisByGenerators( F, [], Zero(L) );
    i:=1;
    while Length( basH ) < Dimension( H ) do
      a:= S[i];
      j:= Position( S, -a );
      h:= B[i][1]*B[j][1];
      if not IsContainedInSpan( sp, h ) then
        CloseMutableBasis( sp, basH );
        Add( basR, a );
      fi;
      i:=i+1;
    od;

    # A root 'a' is said to be positive if the first nonzero element of
    # '[ CartInt( S, a, basR[j] ) ]' is positive.
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

    # A positive root is called fundamental if it is not the sum of two other
    # positive roots.
    # We calculate the set of fundamental roots.

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

    # Now we calculate the Cartan matrix 'C' of the root system.

    C:= List( fundR, i -> List( fundR, j -> CartInt( S, i, j ) ) );

    # Every root can be written as a sum of the fundamental roots.
    # The height of a root is the sum of the coefficients appearing
    # in that expression.
    # We order the roots according to increasing height.

    V:= BasisByGeneratorsNC( VectorSpace( F, fundR ), fundR );
    hts:= List( posR, r -> Sum( Coefficients( V, r ) ) );
    sorh:= Set( hts );

    sorR:= [ ];
    for i in [1..Length(sorh)] do
      Append( sorR, Filtered( posR, r -> hts[Position(posR,r)] = sorh[i] ) );
    od;
    Append( sorR, -1*sorR );

    return rec(
                roots     := sorR,
                rootvecs  := List( sorR, r -> Rvecs[ Position(S,r) ] ),
                fundroots := fundR,
                cartanmat := C
                );
    end );


#############################################################################
##
#E  alglie.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



