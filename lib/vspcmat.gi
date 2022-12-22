#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for matrix spaces.
##  A matrix space is a vector space whose elements are matrices.
##
##  The coefficients field need *not* contain all entries of the matrices.
##  If it does then the space is a *Gaussian matrix space*,
##  with better methods to deal with bases.
##  If it does not then the bases use the mechanism of associated bases.
##
##  For all matrix spaces, the value of the attribute `DimensionOfVectors' is
##  a list of length 2,
##  the first entry being the number of rows and the second being the number
##  of columns.
##
##  Note that we must distinguish spaces of Lie matrices and spaces of
##  ordinary matrices because of the different family relations.
##
##  (See the file `vspcrow.gi' for methods for row spaces.)
##
##  2. Methods for bases of non-Gaussian matrix spaces
##  3. Methods for semi-echelonized bases of Gaussian matrix spaces
##  4. Methods for matrix spaces
##  5. Methods for full matrix spaces
##  7. Methods for mutable bases of Gaussian matrix spaces
##


#############################################################################
##
##  2. Methods for bases of non-Gaussian matrix spaces
##

#############################################################################
##
#M  NiceFreeLeftModuleInfo( <matspace> )
#M  NiceVector( <V>, <mat> )
#M  UglyVector( <V>, <row> )  . . . . . . . . for matrix space and row vector
##
##  The purpose of the check is twofold.
##
##  First, we check whether <V> is a non-Gaussian matrix space.
##  If yes then it gets the filter `IsNonGaussianMatrixSpace' that indicates
##  that it is handled via the mechanism of nice bases;
##  this holds also if the matrices are Lie matrices, since thus one
##  indirection (``unpacking'' the Lie matrix) is avoided.
##
##  Second, we set the filter `IsMatrixModule' if <V> consists of matrices.
##  If additionally <V> turns out to be Gaussian then we set also the filter
##  `IsGaussianSpace';
##  also this holds for both ordinary and Lie matrices.
##
InstallHandlingByNiceBasis( "IsNonGaussianMatrixSpace", rec(
    detect := function( F, mats, V, zero )
      local dims;

      # Check that all entries in `mats' are matrices of the same shape.
      if IsEmpty( mats ) then
        if IsMatrix( zero ) then
          SetFilterObj( V, IsMatrixModule );
          SetFilterObj( V, IsGaussianSpace );
          return fail;
        fi;
        return false;
      elif not IsMatrix( mats[1] ) then
        return false;
      fi;
      dims:= DimensionsMat( mats[1] );
      if not ForAll( mats, mat ->     IsMatrix( mat )
                                  and DimensionsMat( mat ) = dims ) then
        return false;
      fi;
      SetFilterObj( V, IsMatrixModule );
      SetDimensionOfVectors( V, dims );
      if ForAll( mats, mat -> ForAll( mat, row -> IsSubset( F, row ) ) ) then

        # If <V> is an ideal in a matrix algebra, and <mats> is a list of
        # ideal generators then we have to look also at algebra generators
        # of the acting ring(s).
        if     HasLeftActingRingOfIdeal( V )
           and not ForAll( GeneratorsOfFLMLOR( LeftActingRingOfIdeal( V ) ),
                       mat -> ForAll( mat, row -> IsSubset( F, row ) ) ) then
          return true;
        fi;
        if     HasRightActingRingOfIdeal( V )
           and not ForAll( GeneratorsOfFLMLOR( RightActingRingOfIdeal( V ) ),
                       mat -> ForAll( mat, row -> IsSubset( F, row ) ) ) then
          return true;
        fi;

        if IsDivisionRing( F ) then
          SetFilterObj( V, IsGaussianMatrixSpace );
          return fail;
        fi;
        return false;
      fi;
      return true;
      end,

    NiceFreeLeftModuleInfo := ReturnFalse,

    NiceVector := function( V, mat )
      if DimensionsMat( mat ) <> DimensionOfVectors( V )then
        return fail;
      else
        return Concatenation( mat );
      fi;
      end,

    UglyVector := function( V, row )
      local mat,   # the matrix, result
            dim,   # dimensions of the matrix
            i;     # loop over the rows

      dim:= DimensionOfVectors( V );
      if Length( row ) <> dim[1] * dim[2] then
        return fail;
      fi;
      mat:= [];
      for i in [ 1 .. dim[1] ] do
        mat[i]:= row{ [ (i-1) * dim[2] + 1 .. i * dim[2] ] };
      od;

      if IsLieObjectCollection( V ) then
        mat:= LieObject( mat );
      fi;

      return mat;
      end ) );


#############################################################################
##
##  3. Methods for semi-echelonized bases of Gaussian matrix spaces
##

#############################################################################
##
#R  IsSemiEchelonBasisOfGaussianMatrixSpaceRep( <B> )
##
##  A basis of a Gaussian matrix space is either semi-echelonized or it is a
##  relative basis.
##  (So there is no need for `IsBasisGaussianMatrixSpace').
##
##  If basis vectors are known and if the space is nontrivial
##  then the component `heads' is bound.
##
DeclareRepresentation( "IsSemiEchelonBasisOfGaussianMatrixSpaceRep",
    IsAttributeStoringRep,
    [ "heads" ] );

InstallTrueMethod( IsSmallList,
    IsList and IsSemiEchelonBasisOfGaussianMatrixSpaceRep );


#############################################################################
##
#M  Coefficients( <B>, <v> )  .  method for semi-ech. basis of Gaussian space
##
InstallMethod( Coefficients,
    "for semi-ech. basis of a Gaussian matrix space, and a matrix",
    IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianMatrixSpaceRep, IsMatrix ],
    function( B, v )
    local vectors, # basis vectors of `B'
          heads,   # heads info of `B'
          coeff,   # coefficients list, result
          zero,    # zero of the field
          m,       # number of rows
          n,       # number of columns
          i, j,    # loop over rows and columns
          val,     # one coefficient
          bvec,    # one basis vector
          k;       # loop over rows

    # Check whether the matrix has the right dimensions.
    # (The heads info is not available before the basis vectors are known.)
    vectors := BasisVectors( B );
    heads:= B!.heads;
    if DimensionsMat( v ) <> DimensionsMat( heads ) then
      return fail;
    fi;

    # Preset the coefficients list with zeroes.
    zero:= Zero( v[1][1] );
    coeff:= ListWithIdenticalEntries( Length( vectors ), zero );

    # Compute the coefficients of the basis vectors.
    m:= Length( v );
    n:= Length( v[1] );
    v:= List( v, ShallowCopy );
    for i in [ 1 .. Length( heads ) ] do
      j:= PositionNonZero( v[i] );
      while j <= n do

        val:= v[i][j];
        if heads[i][j] = 0 or val = zero then
          return fail;
        else

          coeff[ heads[i][j] ]:= val;

          # Subtract `v[i][j]' times the `heads[i][j]'-th basis vector.
          bvec:= vectors[ heads[i][j] ];
          for k in [ 1 .. m ] do
            AddRowVector( v[k], bvec[k], -val );
          od;

        fi;
        j:= PositionNonZero( v[i] );

      od;
    od;

    # Check whether the coefficients lie in the left acting domain.
    if not IsSubset( LeftActingDomain( UnderlyingLeftModule( B ) ), coeff ) then
      return fail;
    fi;

    # Return the coefficients.
    return coeff;
    end );


#############################################################################
##
#F  SiftedVectorForGaussianMatrixSpace( <F>, <vectors>, <heads>, <v> )
##
##  is the remainder of the matrix <v> after sifting through the (mutable)
##  <F>-basis with basis vectors <vectors> and heads information <heads>.
##
BindGlobal( "SiftedVectorForGaussianMatrixSpace",
    function( F, vectors, heads, v )
    local zero,     # zero of `F'
          m,        # number of rows
          i, j, k,  # loop over rows and columns
          scalar,   # one field element
          bvec;     # one basis vector

    if    DimensionsMat( v ) <> DimensionsMat( heads )
       or not ForAll( v, row -> IsSubset( F, row ) ) then
      return fail;
    fi;

    v:= List( v, ShallowCopy );
    zero:= Zero( v[1][1] );
    m:= Length( heads );

    # Compute the coefficients of the basis vectors.
    for i in [ 1 .. m ] do
      for j in [ 1 .. Length( heads[i] ) ] do
        if heads[i][j] <> 0 and v[i][j] <> zero then

          # Subtract `v[i][j]' times the `heads[i][j]'-th basis vector.
          scalar:= -v[i][j];
          bvec:= vectors[ heads[i][j] ];
          for k in [ 1 .. m ] do
            AddRowVector( v[k], bvec[k], scalar );
          od;

        fi;
      od;
    od;

    if IsLieObjectCollection( vectors ) then
      v:= LieObject( v );
    fi;

    # Return the remainder.
    return v;
end );


#############################################################################
##
#M  SiftedVector( <B>, <v> )
##
##  If `<B>!.heads[<i>][<j>]' is nonzero this means that the entry in the
##  <i>-th row and <j>-th column is leading entry of the
##  `<B>!.heads[<i>][<j>]'-th vector in the basis.
##
InstallMethod( SiftedVector,
    "for semi-ech. basis of Gaussian matrix space, and matrix",
    IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianMatrixSpaceRep, IsMatrix ],
    function( B, v )
    return SiftedVectorForGaussianMatrixSpace(
               LeftActingDomain( UnderlyingLeftModule( B ) ),
               BasisVectors( B ), B!.heads, v );
    end );


#############################################################################
##
#F  HeadsInfoOfSemiEchelonizedMats( <mats>, <dims> )
##
##  is the `heads' information of the list of matrices <mats> of dimensions
##  <dims> if <mats> can be viewed as a semi-echelonized basis
##  of a Gaussian matrix space, and `fail' otherwise.
#T move to `matrix.gi'?
##
BindGlobal( "HeadsInfoOfSemiEchelonizedMats", function( mats, dims )
    local zero,     # zero of the field
          one,      # one of the field
          nmats,    # number of basis vectors
          dimrow,   # no. of rows in the matrices
          dimcol,   # no. of columns in the matrices
          heads,    # list of pivot rows
          i,        # loop over rows
          j,        # pivot column
          k,        # loop over lower rows
          row;      #

    nmats  := Length( mats );
    dimrow := dims[1];
    dimcol := dims[2];

    heads:= ListWithIdenticalEntries( dimcol, 0 );
    heads:= List( [ 1 .. dimrow ], x -> ShallowCopy( heads ) );

    if 0 < nmats then

      zero := Zero( mats[1][1][1] );
      one  := One( zero );

      # Loop over the columns.
      for i in [ 1 .. nmats ] do

        # Get the pivot.
        row:= 1;
        j:= PositionNonZero( mats[i][row] );
        while dimcol < j and row < dimrow do
          row:= row + 1;
          j:= PositionNonZero( mats[i][row] );
        od;

        if dimrow < row or mats[i][ row ][j] <> one then

          # No nonzero entry in the whole matrix, or pivot is not `one'.
          return fail;
        fi;

        for k in [ i+1 .. nmats ] do
          if mats[k][ row ][j] <> zero then
            return fail;
          fi;
        od;
        heads[ row ][j]  := i;

      od;

    fi;

    return heads;
end );


#############################################################################
##
#M  IsSemiEchelonized( <B> )
##
##  A basis of a Gaussian matrix space is in semi-echelon form
##  if the concatenations of the basis vectors form a semi-echelonized
##  row space basis.
##
InstallMethod( IsSemiEchelonized,
    "for basis (of a Gaussian matrix space)",
    [ IsBasis ],
    function( B )
    local V;
    V:= UnderlyingLeftModule( B );
    if not ( IsMatrixModule( V ) and IsGaussianMatrixSpace( V ) ) then
#T The basis does not know whether it is a basis of a matrix space at all.
      TryNextMethod();
    else
      return HeadsInfoOfSemiEchelonizedMats( BasisVectors( B ),
                                         DimensionOfVectors( V ) ) <> fail;

#T change the basis from relative to seb ?
    fi;
    end );


#############################################################################
##
##  4. Methods for matrix spaces
##


#############################################################################
##
#M  Basis( <V> )  . . . . . . . . . . . . . . . . . for Gaussian matrix space
#M  Basis( <V>, <vectors> ) . . . . . . . . . . . . for Gaussian matrix space
#M  BasisNC( <V>, <vectors> ) . . . . . . . . . . . for Gaussian matrix space
##
##  Distinguish the cases whether the space <V> is a *Gaussian* matrix vector
##  space or not.
##
##  If the coefficients field is big enough then either a semi-echelonized or
##  a relative basis is constructed.
##
##  Otherwise the mechanism of associated nice bases is used.
##  In this case the default methods have been installed by
##  `InstallHandlingByNiceBasis'.
##
InstallMethod( Basis,
    "for Gaussian matrix space (construct a semi-echelonized basis)",
    [ IsGaussianMatrixSpace ],
    SemiEchelonBasis );

InstallMethod( Basis,
    "for Gaussian matrix space and list of matrices (try semi-ech.)",
    IsIdenticalObj,
    [ IsGaussianMatrixSpace, IsHomogeneousList ],
    function( V, gens )
    local dims,
          heads,
          B,
          v;

    # Check whether the entries of `gens' are matrices of the right shape.
    dims:= DimensionOfVectors( V );
    if not ForAll( gens, entry ->     IsMatrix( entry )
                                  and DimensionsMat( entry ) = dims ) then
      return fail;
    fi;

    # Test whether the vectors form a semi-echelonized basis.
    # (If not then give up.)
    heads:= HeadsInfoOfSemiEchelonizedMats( gens, dims );
    if heads = fail then
      TryNextMethod();
    fi;

    # Construct a semi-echelonized basis.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );
    SetIsEmpty( B, IsEmpty( gens ) );

    B!.heads:= heads;

    # The basis vectors are linearly independent since they form
    # a semi-echelonized matrix.
    # Hence it is sufficient to check whether they generate the space.
    for v in GeneratorsOfLeftModule( V ) do
      if Coefficients( B, v ) = fail then
        return fail;
      fi;
    od;

    # Return the basis.
    return B;
    end );

InstallMethod( BasisNC,
    "for Gaussian matrix space and list of matrices (try semi-ech.)",
    IsIdenticalObj,
    [ IsGaussianMatrixSpace, IsHomogeneousList ],
    function( V, gens )

    local B, heads;

    # Test whether the vectors form a semi-echelonized basis.
    # (If not then give up.)
    heads:= HeadsInfoOfSemiEchelonizedMats( gens, DimensionOfVectors( V ) );
    if heads = fail then
      TryNextMethod();
    fi;

    # Construct a semi-echelonized basis.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );
    SetIsEmpty( B, IsEmpty( gens ) );

    B!.heads:= heads;

    # Return the basis.
    return B;
    end );


#############################################################################
##
#M  SemiEchelonBasis( <V> )
#M  SemiEchelonBasis( <V>, <vectors> )
#M  SemiEchelonBasisNC( <V>, <vectors> )
##
InstallImmediateMethod( SemiEchelonBasis,
    IsGaussianMatrixSpace and HasCanonicalBasis
                    and IsAttributeStoringRep, 20,
    CanonicalBasis );

InstallMethod( SemiEchelonBasis,
    "for Gaussian matrix space",
    [ IsGaussianMatrixSpace ],
    function( V )
    local B;
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
    end );

InstallMethod( SemiEchelonBasis,
    "for Gaussian matrix space and list of matrices",
    IsIdenticalObj,
    [ IsGaussianMatrixSpace, IsHomogeneousList ],
    function( V, gens )

    local heads,   # heads info for the basis
          B,       # the basis, result
          v;       # loop over vector space generators

    # Check that the vectors form a semi-echelonized basis.
    heads:= HeadsInfoOfSemiEchelonizedMats( gens, DimensionOfVectors( V ) );
    if heads = fail then
      return fail;
    fi;

    # Construct the basis.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );
    SetIsEmpty( B, IsEmpty( gens ) );

    B!.heads:= heads;

    # The basis vectors are linearly independent since they form
    # a semi-echelonized list of matrices.
    # Hence it is sufficient to check whether they generate the space.
    for v in GeneratorsOfLeftModule( V ) do
      if Coefficients( B, v ) = fail then
        return fail;
      fi;
    od;

    return B;
    end );

InstallMethod( SemiEchelonBasisNC,
    "for Gaussian matrix space and list of matrices",
    IsIdenticalObj,
    [ IsGaussianMatrixSpace, IsHomogeneousList ],
    function( V, gens )

    local B;  # the basis, result

    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );
    SetIsEmpty( B, IsEmpty( gens ) );

    # Provide the `heads' information.
    B!.heads:= HeadsInfoOfSemiEchelonizedMats( gens, DimensionOfVectors(V) );

    # Return the basis.
    return B;
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . .  for semi-ech. basis of Gaussian matrix space
##
InstallMethod( BasisVectors,
    "for semi-ech. basis of a Gaussian matrix space",
    [ IsBasis and IsSemiEchelonBasisOfGaussianMatrixSpaceRep ],
    function( B )
    local V, gens, zero, vectors;

    V:= UnderlyingLeftModule( B );

    # Note that we must not ask for the dimension here \ldots
    gens:= GeneratorsOfLeftModule( V );

    if IsEmpty( gens ) then

      SetIsEmpty( B, true );
      zero:= Zero( [ 1 ..  DimensionOfVectors( V )[2] ] );
      B!.heads:= ListWithIdenticalEntries( DimensionOfVectors(V)[1], zero );
      vectors:= [];

    else

      gens:= SemiEchelonMats( gens );
      B!.heads:= gens.heads;
      vectors:= gens.vectors;

      if IsLieObjectCollection( B ) then
        vectors:= List( vectors, LieObject );
      fi;

    fi;
    return vectors;
    end );


#############################################################################
##
#M  Zero( <V> ) . . . . . . . . . . . . . . . . . . . . . .  for matrix space
##
InstallOtherMethod( Zero,
    "for a matrix space",
    [ IsMatrixSpace ],
    function( V )
    local zero;
    zero:= DimensionOfVectors( V );
    zero:= NullMat( zero[1], zero[2], LeftActingDomain( V ) );
    if IsLieObjectCollection( V ) then
      zero:= LieObject( zero );
    fi;
    return zero;
    end );


#############################################################################
##
#M  CanonicalBasis( <V> ) . . . . . . . . . . . . . for Gaussian matrix space
##
##  The canonical basis of a Gaussian matrix space is defined by applying
##  a full Gauss algorithm to the generators of the space.
##
InstallMethod( CanonicalBasis,
    "for Gaussian matrix space",
    [ IsGaussianMatrixSpace ],
    function( V )
    local B,        # semi-echelonized basis
          vectors,  # basis vectors of `B'
          base,     # vectors of the canonical basis
          newheads, # `heads' component of the canonical basis
          m, n,     # dimensions of the matrices
          i, j,     # loop over rows and columns
          k, l,     # loop over rows and columns
          v;        # one basis vector

    # Compute a semi-echelonized basis.
    B:= SemiEchelonBasis( V );
    vectors:= BasisVectors( B );

    # Sort the vectors such that the sequence of pivot positions
    # is increasing.
    base:= [];
    newheads:= List( B!.heads, ShallowCopy );

    if not IsEmpty( vectors ) then

      # Get the matrix dimensions.
      m:= DimensionOfVectors( V )[1];
      n:= DimensionOfVectors( V )[2];

      for i in [ 1 .. m ] do
        for j in [ 1 .. n ] do

          if B!.heads[i][j] <> 0 then

            # Reduce each vector with all those that
            # have bigger pivot positions and are stored later.
            v:= vectors[ newheads[i][j] ];
            for l in [ j+1 .. n ] do
              if B!.heads[i][l] <> 0 and newheads[i][j] < newheads[i][l] then
#T use AddRowVector (make copy!)
                v:= v - v[i][l] * vectors[ B!.heads[i][l] ];
              fi;
            od;
            for k in [ i+1 .. m ] do
              for l in [ 1 .. n ] do
                if B!.heads[k][l] <> 0 and newheads[i][j] < newheads[k][l] then
                  v:= v - v[k][l] * vectors[ B!.heads[k][l] ];
#T use AddRowVector (make copy!)
                fi;
              od;
            od;

            Add( base, v );
            newheads[i][j]:= Length( base );

          fi;

        od;
      od;

    fi;

    # Make the basis.
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep
                            and IsCanonicalBasis ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, base );
    SetIsEmpty( B, IsEmpty( base ) );

    B!.heads:= newheads;

    # Return the basis.
    return B;
    end );


#############################################################################
##
##  5. Methods for full matrix spaces
##

#############################################################################
##
#M  IsFullMatrixModule( V )
##
InstallMethod( IsFullMatrixModule,
    "for Gaussian matrix space",
    [ IsGaussianMatrixSpace ],
    V -> Dimension( V ) = Product( DimensionOfVectors( V ) ) );

InstallMethod( IsFullMatrixModule,
    "for non-Gaussian matrix space",
    [ IsVectorSpace and IsNonGaussianMatrixSpace ],
    ReturnFalse );

InstallOtherMethod( IsFullMatrixModule,
    "for arbitrary free left module",
    [ IsLeftModule ],
    function( V )
    local gens, R;

    # A full matrix module is a free left module.
    if not IsFreeLeftModule( V ) then
      return false;
    fi;

    # The elements of a full matrix module are matrices over the
    # left acting domain,
    # and the dimension equals the number of entries of the matrices.
    gens:= GeneratorsOfLeftModule( V );
    if IsEmpty( gens ) then
      gens:= [ Zero( V ) ];
    fi;
    R:= LeftActingDomain( V );
    return     ForAll( gens,
                       mat ->     IsMatrix( mat )
                              and ForAll( mat, row -> IsSubset( R, row ) ) )
           and Dimension( V ) = Product( DimensionsMat( gens[1] ) );
    end );


#############################################################################
##
#M  CanonicalBasis( <V> )
##
InstallMethod( CanonicalBasis,
    "for full matrix space",
    [ IsFullMatrixModule ],
    function( V )
    local B, dims, m, n;
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep
                            and IsCanonicalBasisFullMatrixModule ),
                   rec() );
    SetUnderlyingLeftModule( B, V );

    dims:= DimensionOfVectors( V );
    m:= dims[1];
    n:= dims[2];
    B!.heads:= List( [ 0 .. m-1 ], i -> i * n + [ 1 .. n ] );

    return B;
    end );


#############################################################################
##
##  7. Methods for mutable bases of Gaussian matrix spaces
##

#############################################################################
##
#R  IsMutableBasisOfGaussianMatrixSpaceRep( <B> )
##
##  The default mutable bases of Gaussian matrix spaces are semi-echelonized.
##  Note that we switch to a mutable basis of representation
##  `IsMutableBasisByImmutableBasisRep' if the mutable basis is closed by a
##  vector that makes the space non-Gaussian.
#T better switch to mutable basis by nice mutable basis !
##
##  Note that the `basisVectors' component consists of ordinary matrices
##  also if the defining matrices are Lie matrices.
##
DeclareRepresentation( "IsMutableBasisOfGaussianMatrixSpaceRep",
    IsComponentObjectRep,
    [ "heads", "basisVectors", "leftActingDomain", "zero" ] );


#############################################################################
##
#M  MutableBasis( <R>, <mats> ) . . . . . . . . . . . . for matrices over <R>
##
InstallMethod( MutableBasis,
    "to construct mutable bases of Gaussian matrix spaces",
    IsElmsCollColls,
    [ IsRing, IsCollection ],
    function( R, mats )
    local newmats, B;

    if ForAny( mats, mat -> ForAny( mat, v -> not IsSubset( R, v ) ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that uses a nice mutable basis.
      B:= MutableBasisViaNiceMutableBasisMethod2( R, mats );

    else

      # Note that `mats' is not empty.
      newmats:= SemiEchelonMats( mats );

      B:= Objectify( NewType( FamilyObj( mats ),
                                  IsMutableBasis
                              and IsMutable
                              and IsMutableBasisOfGaussianMatrixSpaceRep ),
                     rec(
                          basisVectors     := ShallowCopy( newmats.vectors ),
                          heads            := ShallowCopy( newmats.heads ),
                          zero             := Zero( mats[1] ),
                          leftActingDomain := R
                          ) );

    fi;

    return B;
    end );


#############################################################################
##
#M  MutableBasis( <R>, <mats> ) . . . . . . . . . . . . . .  for Lie matrices
##
InstallMethod( MutableBasis,
    "to construct a mutable basis of a Lie matrix space",
    IsElmsCollLieColls,
    [ IsDivisionRing, IsLieObjectCollection ],
    function( R, mats )
    local B, newmats;

    if ForAny( mats, mat -> ForAny( mat, v -> not IsSubset( R, v ) ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that uses a nice mutable basis.
      B:= MutableBasisViaNiceMutableBasisMethod2( R, mats );

    else

      # Note that `mats' is not empty.
      newmats:= SemiEchelonMats( mats );

      B:= Objectify( NewType( FamilyObj( mats ),
                                  IsMutableBasis
                              and IsMutable
                              and IsMutableBasisOfGaussianMatrixSpaceRep ),
                     rec(
                          basisVectors     := ShallowCopy( newmats.vectors ),
                          heads            := newmats.heads,
                          zero             := Zero( mats[1] ),
                          leftActingDomain := R
                        ) );

    fi;

    return B;
    end );


#############################################################################
##
#M  MutableBasis( <R>, <mats>, <zero> ) . . . . . . . . for matrices over <R>
##
InstallOtherMethod( MutableBasis,
    "to construct mutable bases of matrix spaces",
    function( FamR, Fammats, Famzero )
        return    IsElmsColls( FamR, Famzero )
               or IsElmsLieColls( FamR, Famzero );
    end,
    [ IsRing, IsHomogeneousList, IsMatrix ],
    function( R, mats, zero )
    local B, z;

    if ForAny( mats, mat -> ForAny( mat, v -> not IsSubset( R, v ) ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that uses a nice mutable basis.
      B:= MutableBasisViaNiceMutableBasisMethod3( R, mats, zero );

    else

      B:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                  IsMutableBasis
                              and IsMutable
                              and IsMutableBasisOfGaussianMatrixSpaceRep ),
                     rec(
                          zero:= zero,
                          leftActingDomain := R
                          ) );

      if IsEmpty( mats ) then

        B!.basisVectors:= [];
        z:= ListWithIdenticalEntries( Length( zero[1] ), 0 );
        B!.heads:= List( zero, i -> ShallowCopy( z ) );
#T problem for `NullAlgebra' !!

      else

        mats:= SemiEchelonMats( mats );
        B!.basisVectors:= ShallowCopy( mats.vectors );
        B!.heads:= mats.heads;

      fi;

    fi;

    return B;
    end );


#############################################################################
##
#M  ViewObj( <MB> ) . . . . . . view mutable basis of a Gaussian matrix space
##
InstallMethod( ViewObj,
    "for a mutable basis of a Gaussian matrix space",
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep ],
    function( MB )
    Print( "<mutable basis over ", MB!.leftActingDomain, ", ",
           Pluralize( Length( MB!.basisVectors ), "vector" ), ">" );
    end );


#############################################################################
##
#M  PrintObj( <MB> )  . . . .  print mutable basis of a Gaussian matrix space
##
InstallMethod( PrintObj,
    "for a mutable basis of a Gaussian matrix space",
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep ],
    function( MB )
    Print( "MutableBasis( ", MB!.leftActingDomain, ", " );
    if NrBasisVectors( MB ) = 0 then
      Print( "[], ", Zero( MB!.leftActingDomain ), " )" );
    else
      Print( MB!.basisVectors, " )" );
    fi;
    end );


#############################################################################
##
#M  BasisVectors( <MB> )  . . .  for mutable basis of a Gaussian matrix space
##
InstallOtherMethod( BasisVectors,
    "for a mutable basis of a Gaussian matrix space",
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep ],
    function( MB )
    if IsLieObjectCollection( MB ) then
      return Immutable( List( MB!.basisVectors, LieObject ) );
    else
      return Immutable( MB!.basisVectors );
    fi;
    end );


#############################################################################
##
#M  CloseMutableBasis( <MB>, <v> )  . for mut. basis of Gaussian matrix space
##
InstallMethod( CloseMutableBasis,
    "for a mut. basis of a Gaussian matrix space, and a matrix",
    IsCollsElms,
    [ IsMutableBasis and IsMutable
                     and IsMutableBasisOfGaussianMatrixSpaceRep,
      IsMatrix ],
    function( MB, v )
    local V,              # corresponding free left module
          m,              # number of rows
          n,              # number of columns
          heads,          # heads info of the basis
          zero,           # zero coefficient
          basisvectors,   # list of basis vectors of `MB'
          i, j, k,        # loop variables
          scalar,         # one coefficient
          bv;             # one basis vector

    # Check whether the mutable basis belongs to a Gaussian matrix space
    # after the closure.
    v:= List( v, ShallowCopy );

    if not ForAll( v, row -> IsSubset( MB!.leftActingDomain, row ) ) then

      # Change the representation to a mutable basis by immutable basis.
#T better mechanism!
#T change to m.b. via nice m.b. !!
      basisvectors:= Concatenation( MB!.basisVectors, [ v ] );

      if IsLieObjectCollection( MB ) then
        basisvectors:= List( basisvectors, LieObject );
      fi;

      V:= LeftModuleByGenerators( MB!.leftActingDomain, basisvectors );
      UseBasis( V, basisvectors );

      SetFilterObj( MB, IsMutableBasisByImmutableBasisRep );
      ResetFilterObj( MB, IsMutableBasisOfGaussianMatrixSpaceRep );

      MB!.immutableBasis:= Basis( V );
      return true;

    else

      m:= Length( v    );
      n:= Length( v[1] );
      heads:= MB!.heads;
      zero:= Zero( v[1][1] );
      basisvectors:= MB!.basisVectors;

      # Reduce `v' with the known basis vectors.
      for i in [ 1 .. m ] do
        for j in [ 1 .. n ] do
          if zero <> v[i][j] and heads[i][j] <> 0 then
            scalar:= - v[i][j];
            bv:= basisvectors[ heads[i][j] ];
            for k in [ 1 .. m ] do
              AddRowVector( v[k], bv[k], scalar );
            od;
          fi;
        od;
      od;

      # If necessary add the sifted vector, and update the basis info.
      for i in [ 1 .. m ] do
        j := PositionNonZero( v[i] );
        if j <= n then
          scalar:= Inverse( v[i][j] );
          for k in [ 1 .. m ] do
            MultVector( v[k], scalar );
          od;
          Add( basisvectors, v );
          heads[i][j]:= Length( basisvectors );
          return true;
        fi;
      od;

      # The basis was not extended.
      return false;
    fi;
    end );


#############################################################################
##
#M  IsContainedInSpan( <MB>, <v> )  . for mut. basis of Gaussian matrix space
##
InstallMethod( IsContainedInSpan,
    "for a mut. basis of a Gaussian matrix space, and a matrix",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep,
      IsMatrix ],
    function( MB, v )
    local m,              # number of rows
          n,              # number of columns
          heads,          # heads info of the basis
          basisvectors,   # list of basis vectors of `MB'
          i, j, k,        # loop variables
          scalar,         # one coefficient
          bv;             # one basis vector

    if not ForAll( v, row -> IsSubset( MB!.leftActingDomain, row ) ) then

      return false;

    else

      v:= List( v, ShallowCopy );
      m:= Length( v    );
      n:= Length( v[1] );
      heads:= MB!.heads;
      basisvectors:= MB!.basisVectors;

      # Reduce `v' with the known basis vectors.
      for i in [ 1 .. m ] do
        for j in [ 1 .. n ] do
          if heads[i][j] <> 0 then
            scalar:= - v[i][j];
            bv:= basisvectors[ heads[i][j] ];
            for k in [ 1 .. m ] do
              AddRowVector( v[k], bv[k], scalar );
            od;
          fi;
        od;
      od;

      # Check whether the sifted vector is zero.
      return IsZero( v );

    fi;
    end );


#############################################################################
##
#M  SiftedVector( <MB>, <v> )
##
##  If `<MB>!.heads[<i>][<j>]' is nonzero this means that the entry in the
##  <i>-th row and <j>-th column is leading entry of the
##  `<MB>!.heads[<i>][<j>]'-th vector in the basis.
##
InstallOtherMethod( SiftedVector,
    "for mutable basis of Gaussian matrix space, and matrix",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep,
      IsMatrix ],
    function( MB, v )
    return SiftedVectorForGaussianMatrixSpace( MB!.leftActingDomain,
               MB!.basisVectors, MB!.heads, v );
    end );


#############################################################################
##
#M  ImmutableBasis( <MB> )  . .  for mutable basis of a Gaussian matrix space
##
InstallMethod( ImmutableBasis,
    "for a mutable basis of a Gaussian matrix space",
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep ],
    function( MB )
    local V;
    V:= FreeLeftModule( MB!.leftActingDomain,
                        BasisVectors( MB ),
                        MB!.zero );
    MB:= SemiEchelonBasisNC( V, BasisVectors( MB ) );
#T use known `heads' info !!
    UseBasis( V, MB );
    return MB;
    end );


#T mutable bases for Gaussian row and matrix spaces are always semi-ech.
#T (note that we construct a mutable basis only if we want to do successive
#T closures)
