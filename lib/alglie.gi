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
      hom:= NaturalHomomorphism( L, L / C );
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


#T #############################################################################
#T ##
#T #F  AsLieAlgebra( <F>, <D> )  view a domain as Lie algebra over the field <F>
#T #F  AsLieAlgebra( <D> )
#T ##
#T AsLieAlgebra := function( arg )
#T     local   A;
#T 
#T     if     Length( arg ) = 1
#T        and IsDomain( arg[1] )
#T        and IsBound( arg[1].field ) then
#T 
#T       # Convert a domain into an algebra.
#T       A:= arg[1].operations.AsLieAlgebra( arg[1].field, arg[1] );
#T 
#T     elif   Length( arg ) = 2
#T        and IsField( arg[1] )
#T        and IsDomain( arg[2] ) then
#T 
#T       # Convert a domain into an algebra.
#T       A:= arg[2].operations.AsLieAlgebra( arg[1], arg[2] );
#T 
#T     elif   Length( arg ) = 2
#T        and IsField( arg[1] )
#T        and IsList( arg[2] ) then
#T 
#T       # Convert a list into an algebra.
#T       A:= Domain( arg[2] ).operations.AsLieAlgebra( arg[1], arg[2] );
#T 
#T     else
#T       Error( "usage: AsLieAlgebra([<F>,] <D>) for domain or list <D>" );
#T     fi;
#T 
#T     # Return the algebra.
#T     return A;
#T     end;
#T 
#T #############################################################################
#T ##
#T #F  LieAlgebraOps.AsAlgebra( <F>, <D> )
#T ##
#T ##  returns a Lie algebra over <F> that is equal (as set) to <D>.
#T ##  For that, perhaps the field of <D> has to be changed before
#T ##  getting the correct list of generators.
#T ##
#T LieAlgebraOps.AsAlgebra := function( F, D )
#T 
#T     local L, A;
#T 
#T     if   D.field = F then
#T 
#T       D:= ShallowCopy( D );
#T 
#T     elif   Length( AlgebraGenerators( D ) ) = 0 then
#T 
#T       # We need the zero.
#T       D:= LieAlgebra( F, D.algebraGenerators, Zero( D ) );
#T 
#T     elif IsSubset( D.field, F ) then
#T 
#T       # Make sure that the field change does not change the elements.
#T       L:= BasisVectors( BasisOfDomain( FieldExtension( D.field, F ) ) );
#T       L:= Concatenation( List( L, x -> List( D.algebraGenerators,
#T                                              y -> x * y ) ) );
#T       D:= LieAlgebra( F, L );
#T 
#T     elif IsSubset( F, D.field ) then
#T 
#T       # Make sure that the field change does not change the elements.
#T       L:= BasisVectors( BasisOfDomain( FieldExtension( F, D.field ) ) );
#T       if ForAny( L, x -> ForAny( D.algebraGenerators,
#T                                  y -> not x * y in D ) ) then
#T         Error( "field change leads out of the algebra" );
#T       fi;
#T       D:= LieAlgebra( F, D.algebraGenerators );
#T 
#T     else
#T       Error( "fields are incompatible" );
#T     fi;
#T 
#T     # Return the algebra.
#T     return D;
#T     end;
#T 
#T #############################################################################
#T ##
#T #F  LieAlgebraOps.AsLieAlgebra( <F>, <D> )
#T ##
#T LieAlgebraOps.AsLieAlgebra := LieAlgebraOps.AsAlgebra;
#T 
#T #############################################################################
#T ##
#T #F  LieAlgebraOps.Algebra( <F>, <D> )  . convert a subalgebra into an algebra
#T ##
#T LieAlgebraOps.Algebra := function( F, D )
#T     local   A,          # algebra for the domain <D>, result
#T             name;       # component name in the algebra record
#T 
#T     # If necessary change the field.
#T     if F <> D.field then
#T       D:= AsLieAlgebra( F, D );
#T     fi;
#T 
#T     # Make the algebra.
#T     if Length( AlgebraGenerators( D ) ) = 0 then
#T       A:= LieAlgebra( F, D.algebraGenerators, Zero( D ) );
#T     else
#T       A:= LieAlgebra( F, D.algebraGenerators );
#T     fi;
#T 
#T     # Copy information.
#T     for name in Intersection( RecFields( D ), MaintainedAlgebraInfo ) do
#T       A.(name):= D.(name);
#T     od;
#T 
#T     # Return the algebra.
#T     return A;
#T     end;


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
      C:= IdealByGenerators( A, M, "basis" );

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
      return IdealByGenerators( A, M, "basis" );
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
      M:= LieAlgebra( R, [ NullMat( n, n, R ) ] );
    else
      M:= LieAlgebra( R, A );
    fi;
#T shall "basis" be allowed in calls to 'Algebra' like functions?

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

    L:= B.structure;
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


#############################################################################
##
#E  alglie.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



