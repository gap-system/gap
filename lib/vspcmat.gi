#############################################################################
##
#W  vspcmat.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for matrix spaces.
##  A matrix space is a vector space whose elements are matrices.
##
##  The coefficients field need *not* contain all entries of the matrices.
##  If it does then the space is a *Gaussian matrix space*,
##  with better methods to deal with bases.
##  If it does not then the bases use the mechanism of associated bases.
##
##  All matrix spaces have the component 'vectordim', a list of length 2,
##  the first entry being the number of rows and the second being the number
##  of columns.
##
##  Note that we must distinguish spaces of Lie matrices and spaces of
##  ordinary matrices because of the different family relations.
##
##  (See the file 'vspcrow.gi' for methods for row spaces.)
##
##  1. Domain constructors for matrix spaces
##  2. Methods for bases of non-Gaussian matrix spaces
##  3. Methods for semi-echelonized bases of Gaussian matrix spaces
##  4. Methods for matrix spaces
##  5. Methods for full matrix spaces
##  7. Methods for mutable bases of Gaussian matrix spaces
##
Revision.vspcmat_gi :=
    "@(#)$Id$";


#############################################################################
##
#R  IsMatrixSpace( <V> )
##
IsMatrixSpace := IsMatrixModuleRep and IsVectorSpace;


#############################################################################
##
#R  IsGaussianMatrixSpaceRep( <V> )
##
##  A matrix space is Gaussian if the left acting domain contains all
##  scalars that occur in the vectors.
##  Thus one can use Gaussian elimination in the calculations.
##
##  (Otherwise the space is non-Gaussian.
##  We will need a flag for this to write down methods that delegate from
##  non-Gaussian spaces to Gaussian ones.)
##
IsGaussianMatrixSpaceRep :=     IsGaussianSpace
                            and IsMatrixModuleRep
                            and IsAttributeStoringRep;


#############################################################################
##
#R  IsNonGaussianMatrixSpaceRep( <V> )
##
##  A non-Gaussian matrix space <V> is a special representation of a space
##  that is handled by an associated basis.
##
##  The nice vector of a matrix is defined by concatenating its rows.
##  So the associated nice space is a (not nec. Gaussian) row space.
##
IsNonGaussianMatrixSpaceRep := NewRepresentation(
    "IsNonGaussianMatrixSpaceRep",
    IsAttributeStoringRep and IsMatrixModuleRep and IsHandledByNiceBasis,
    [] );


#############################################################################
##
##  1. Domain constructors for matrix spaces
##

#############################################################################
##
#M  LeftModuleByGenerators( <F>, <mats> ) . . . . . . . for ordinary matrices
##
InstallMethod( LeftModuleByGenerators,
    "method for division ring and list of ordinary matrices over it",
    IsElmsCollColls,
    [ IsDivisionRing, IsCollection and IsList ], 0,
    function( F, mats )
    local dims, V;

    # Check that all entries in 'mats' are matrices of the same shape.
    if not IsMatrix( mats[1] ) then
      TryNextMethod();
    fi;
    dims:= DimensionsMat( mats[1] );
    if not ForAll( mats, mat ->     IsMatrix( mat )
                                and DimensionsMat( mat ) = dims ) then
      TryNextMethod();
    fi;

    if ForAll( mats, mat -> ForAll( mat, row -> IsSubset( F, row ) ) ) then
      V:= Objectify( NewType( FamilyObj( mats ),
                                  IsGaussianSpace
                              and IsGaussianMatrixSpaceRep ),
                     rec() );
    else
      V:= Objectify( NewType( FamilyObj( mats ),
                                  IsVectorSpace
                              and IsNonGaussianMatrixSpaceRep ),
                     rec() );
    fi;

    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( mats ) );
    V!.vectordim:= dims;

    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <empty>, <zeromat> ) . for ordinary matrices
##
InstallOtherMethod( LeftModuleByGenerators,
    "method for division ring, empty list, and matrix",
    true,
    [ IsDivisionRing, IsList and IsEmpty, IsMatrix ], 0,
    function( F, empty, zero )
    local V;

    # Check whether this method is the right one.
    if not IsElmsColls( FamilyObj( F ), FamilyObj( zero ) ) then
      TryNextMethod();
    fi;
#T explicit 2nd argument above!

    V:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                IsGaussianSpace
                            and IsGaussianMatrixSpaceRep ),
                   rec() );
    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, empty );
    SetZero( V, zero );
    V!.vectordim:= DimensionsMat( zero );

    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <mats>, <zeromat> )  . for ordinary matrices
##
InstallOtherMethod( LeftModuleByGenerators,
    "method for division ring, list of matrices over it, and matrix",
    true,
    [ IsDivisionRing, IsCollection and IsList, IsMatrix ], 0,
    function( F, mats, zero )
    local dims, V;

    # Check whether this method is the right one.
    if not IsElmsCollColls( FamilyObj( F ), FamilyObj( mats ) ) then
      TryNextMethod();
    fi;
#T explicit 2nd argument above!

    # Check that all entries in 'mats' are matrices of the same shape.
    if not IsMatrix( mats[1] ) then
      TryNextMethod();
    fi;
    dims:= DimensionsMat( mats[1] );
    if not ForAll( mats, mat ->     IsMatrix( mat )
                                and DimensionsMat( mat ) = dims ) then
      TryNextMethod();
    fi;

    if ForAll( mats, mat -> ForAll( mat, row -> IsSubset( F, row ) ) ) then
      V:= Objectify( NewType( FamilyObj( mats ),
                                  IsGaussianSpace
                              and IsGaussianMatrixSpaceRep ),
                     rec() );
    else
      V:= Objectify( NewType( FamilyObj( mats ),
                                  IsVectorSpace
                              and IsNonGaussianMatrixSpaceRep ),
                     rec() );
    fi;

    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( mats ) );
    SetZero( V, zero );
    V!.vectordim:= dims;

    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <mats> ) . . . . . . . . .  for Lie matrices
##
InstallMethod( LeftModuleByGenerators,
    "method for division ring and list of Lie matrices over it",
    IsElmsCollLieColls,
    [ IsDivisionRing, IsLieObjectCollection and IsList ], 0,
    function( F, mats )
    local dims, V;

    # Check that all entries in 'mats' are Lie matrices of the same shape.
    if not IsMatrix( mats[1] ) then
      TryNextMethod();
    fi;
    dims:= DimensionsMat( mats[1] );
    if not ForAll( mats, mat ->     IsMatrix( mat )
                                and DimensionsMat( mat ) = dims ) then
      TryNextMethod();
    fi;

    if ForAll( mats, mat -> ForAll( mat, row -> IsSubset( F, row ) ) ) then
      V:= Objectify( NewType( FamilyObj( mats ),
                                  IsGaussianSpace
                              and IsGaussianMatrixSpaceRep ),
                     rec() );
    else
      V:= Objectify( NewType( FamilyObj( mats ),
                                  IsVectorSpace
                              and IsNonGaussianMatrixSpaceRep ),
                     rec() );
    fi;

    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( mats ) );
    V!.vectordim:= dims;

    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <empty>, <zeromat> ) . . .  for Lie matrices
##
InstallOtherMethod( LeftModuleByGenerators,
    "method for division ring, empty list, and Lie matrix",
    true,
    [ IsDivisionRing, IsList and IsEmpty, IsMatrix and IsLieObject ], 0,
    function( F, empty, zero )
    local V;

    # Check whether this method is the right one.
    if not IsElmsLieColls( FamilyObj( F ), FamilyObj( zero ) ) then
      TryNextMethod();
    fi;
#T explicit 2nd argument above!

    V:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                IsGaussianSpace
                            and IsGaussianMatrixSpaceRep ),
                   rec() );
    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, empty );
    SetZero( V, zero );
    V!.vectordim:= DimensionsMat( zero );

    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <mats>, <zeromat> )  . . .  for Lie matrices
##
InstallOtherMethod( LeftModuleByGenerators,
    "method for division ring, list of Lie matrices over it, and Lie matrix",
    true,
    [ IsDivisionRing,
      IsLieObjectCollection and IsList,
      IsMatrix and IsLieObject ], 0,
    function( F, mats, zero )
    local dims, V;

    # Check whether this method is the right one.
    if not IsElmsCollLieColls( FamilyObj( F ), FamilyObj( mats ) ) then
      TryNextMethod();
    fi;
#T explicit 2nd argument above!

    # Check that all entries in 'mats' are Lie matrices of the same shape.
    if not IsMatrix( mats[1] ) then
      TryNextMethod();
    fi;
    dims:= DimensionsMat( mats[1] );
    if not ForAll( mats, mat ->     IsMatrix( mat )
                                and DimensionsMat( mat ) = dims ) then
      TryNextMethod();
    fi;

    if ForAll( mats, mat -> ForAll( mat, row -> IsSubset( F, row ) ) ) then
      V:= Objectify( NewType( FamilyObj( mats ),
                                  IsGaussianSpace
                              and IsGaussianMatrixSpaceRep ),
                     rec() );
    else
      V:= Objectify( NewType( FamilyObj( mats ),
                                  IsVectorSpace
                              and IsNonGaussianMatrixSpaceRep ),
                     rec() );
    fi;

    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( mats ) );
    SetZero( V, zero );
    V!.vectordim:= dims;

    return V;
    end );


#############################################################################
##
##  2. Methods for bases of non-Gaussian matrix spaces
##

#############################################################################
##
#M  PrepareNiceFreeLeftModule( <matspace> )
##
##  Nothing is to do \ldots
##
InstallMethod( PrepareNiceFreeLeftModule,
    "method for non-Gaussian matrix space",
    true,
    [ IsVectorSpace and IsNonGaussianMatrixSpaceRep ], 0,
    Ignore );


#############################################################################
##
#M  NiceVector( <V>, <mat> )
##
InstallMethod( NiceVector,
    "method for non-Gaussian matrix space and matrix",
    IsCollsElms,
    [ IsVectorSpace and IsNonGaussianMatrixSpaceRep, IsMatrix ], 0,
    function( V, mat )
    if DimensionsMat( mat ) <> V!.vectordim then
      return fail;
    else
      return Concatenation( mat );
    fi;
    end );


#############################################################################
##
#M  UglyVector( <V>, <row> )  . . .  for ordinary matrix space and row vector
##
InstallMethod( UglyVector,
    "method for non-Gaussian ordinary matrix space and row vector",
    IsCollCollsElms,
    [ IsVectorSpace and IsNonGaussianMatrixSpaceRep, IsRowVector ], 0,
    function( V, row )

    local mat,   # the matrix, result
          dim,   # dimensions of the matrix
          i;     # loop over the rows

    dim:= V!.vectordim;
    if Length( row ) <> dim[1] * dim[2] then
      return fail;
    fi;
    mat:= [];
    for i in [ 1 .. dim[1] ] do
      mat[i]:= row{ [ (i-1) * dim[2] + 1 .. i * dim[2] ] };
    od;

    return mat;
    end );


#############################################################################
##
#M  UglyVector( <V>, <row> )  . . . . . . for Lie matrix space and row vector
##
InstallMethod( UglyVector,
    "method for non-Gaussian Lie matrix space and row vector",
    IsCollLieCollsElms,
    [ IsVectorSpace and IsNonGaussianMatrixSpaceRep, IsRowVector ], 0,
    function( V, row )

    local mat,   # the matrix, result
          dim,   # dimensions of the matrix
          i;     # loop over the rows

    dim:= V!.vectordim;
    if Length( row ) <> dim[1] * dim[2] then
      return fail;
    fi;
    mat:= [];
    for i in [ 1 .. dim[1] ] do
      mat[i]:= row{ [ (i-1) * dim[2] + 1 .. i * dim[2] ] };
    od;

    return LieObject( mat );
    end );


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
##  (So there is no need for 'IsBasisGaussianMatrixSpace').
##
##  If basis vectors are known then the component 'heads' is bound.
##
IsSemiEchelonBasisOfGaussianMatrixSpaceRep := NewRepresentation(
    "IsSemiEchelonBasisOfGaussianMatrixSpaceRep",
    IsAttributeStoringRep,
    [ "heads" ] );


#############################################################################
##
#M  Coefficients( <B>, <v> )  .  method for semi-ech. basis of Gaussian space
##
InstallMethod( Coefficients,
    "method for semi-ech. basis of a Gaussian matrix space, and a matrix",
    IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianMatrixSpaceRep, IsMatrix ], 0,
    function( B, v )

    local coeff,   # coefficients list, result
          vectors, # basis vectors of 'B'
          zero,    # zero of the field
          m,       # number of rows
          n,       # number of columns
          i, j,    # loop over rows and columns
          val,     # one coefficient
          bvec,    # one basis vector
          k;       # loop over rows

    # Preset the coefficients list with zeroes.
    zero    := Zero( v[1][1] );
    vectors := BasisVectors( B );
    coeff   := [];
    for i in [ 1 .. Length( vectors ) ] do
      coeff[i]:= zero;
    od;

    # Compute the coefficients of the basis vectors.
    m:= Length( v );
    n:= Length( v[1] );
    v:= List( v, ShallowCopy );
    for i in [ 1 .. Length( B!.heads ) ] do
      j:= PositionNot( v[i], zero );
      while j <= n do

        val:= v[i][j];
        if B!.heads[i][j] = 0 or val = zero then
          return fail;
        else

          coeff[ B!.heads[i][j] ]:= val;

          # Subtract 'v[i][j]' times the 'B!.heads[i][j]'-th basis vector.
          bvec:= vectors[ B!.heads[i][j] ];
          for k in [ 1 .. m ] do
            AddRowVector( v[k], bvec[k], -val );
          od;

        fi;
        j:= PositionNot( v[i], zero );

      od;
    od;

    # Return the coefficients.
    return coeff;
    end );


#############################################################################
##
#M  SiftedVector( <B>, <v> )
##
##  If '<B>!.heads[<i>][<j>]' is nonzero this means that the entry in the
##  <i>-th row and <j>-th column is leading entry of the
##  '<B>!.heads[<i>][<j>]'-th vector in the basis.
##
InstallMethod( SiftedVector,
    "method for semi-ech. basis of Gaussian matrix space, and matrix",
    IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianMatrixSpaceRep, IsMatrix ], 0,
    function( B, v )

    local F,        # field of scalars
          zero,     # zero of the field
          m,        # number of rows
          vectors,  # basis vectors of 'B'
          i, j, k,  # loop over rows and columns
          scalar,   # one field element
          bvec;     # one basis vector

    F:= LeftActingDomain( UnderlyingLeftModule( B ) );
    if not ForAll( v, row -> IsSubset( F, row ) ) then
      return fail;
    fi;

    v:= List( v, ShallowCopy );
    zero:= Zero( v[1][1] );
    vectors:= BasisVectors( B );
    m:= Length( B!.heads );

    # Compute the coefficients of the 'B' vectors.
    for i in [ 1 .. m ] do
      for j in [ 1 .. Length( B!.heads[i] ) ] do
        if B!.heads[i][j] <> 0 and v[i][j] <> zero then

          # Subtract 'v[i][j]' times the 'B!.heads[i][j]'-th basis vector.
          scalar:= -v[i][j];
          bvec:= vectors[ B!.heads[i][j] ];
          for k in [ 1 .. m ] do
            AddRowVector( v[k], bvec[k], scalar );
          od;

        fi;
      od;
    od;

    if IsLieObjectCollection( B ) then
      v:= LieObject( v );
    fi;

    # Return the remainder.
    return v;
    end );


#############################################################################
##
#F  HeadsInfoOfSemiEchelonizedMats( <mats>, <dims> )
##
##  is the 'heads' information of the list of matrices <mats> of dimensions
##  <dims> if <mats> can be viewed as a semi-echelonized basis
##  of a Gaussian matrix space, and 'fail' otherwise.
##
HeadsInfoOfSemiEchelonizedMats := function( mats, dims )

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
        j:= PositionNot( mats[i][row], zero );
        while dimcol < j and row < dimrow do
          row:= row + 1;
          j:= PositionNot( mats[i][row], zero );
        od;

        if dimrow < row or mats[i][ row ][j] <> one then

          # No nonzero entry in the whole matrix, or pivot is not 'one'.
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
end;


#############################################################################
##
#M  IsSemiEchelonized( <B> )
##
##  A basis of a Gaussian matrix space is in semi-echelon form
##  if the concatenations of the basis vectors form a semi-echelonized
##  row space basis.
##
InstallMethod( IsSemiEchelonized,
    "method for basis of a Gaussian matrix space",
    true,
    [ IsBasis ], 0,
    function( B )
    local V;
    V:= UnderlyingLeftModule( B );
    if not IsGaussianMatrixSpaceRep( V ) then
#T The basis does not know whether it is a basis of a matrix space at all.
      TryNextMethod();
    else
      return HeadsInfoOfSemiEchelonizedMats( BasisVectors( B ),
                                             V!.vectordim ) <> fail;
#T change the basis from relative to seb ?
    fi;
    end );


#############################################################################
##
##  4. Methods for matrix spaces
##


#############################################################################
##
#M  \in( <mat>, <V> ) . . . . . . . . .  for matrix and Gaussian matrix space
##
InstallMethod( \in,
    "method for matrix and Gaussian matrix space",
    IsElmsColls,
    [ IsMatrix, IsGaussianSpace and IsGaussianMatrixSpaceRep ], 0,
    function( mat, V )
    local zero, ncols;
    if IsEmpty( mat ) then
      return V!.vectordim[1] = 0;
#T ??
    elif V!.vectordim <> DimensionsMat( mat ) then
      return false;
    else
      zero:= Zero( mat[1][1] );
      ncols:= V!.vectordim[2];
      mat:= SiftedVector( BasisOfDomain( V ), mat );
      return mat <> fail and ForAll( mat,
                     row -> ncols < PositionNot( row, zero ) );
    fi;
    end );


#############################################################################
##
#M  BasisOfDomain( <V> )  . . . . . . . . . . . . . for Gaussian matrix space
#M  BasisByGenerators( <V>, <vectors> ) . . . . . . for Gaussian matrix space
#M  BasisByGeneratorsNC( <V>, <vectors> ) . . . . . for Gaussian matrix space
##
##  Distinguish the cases whether the space <V> is a Gaussian matrix vector
##  space or not.
##
##  If the coefficients field is big enough then either a semi-echelonized or
##  a relative basis is constructed.
##
##  Otherwise the mechanism of associated bases is used.
##  In this case the default methods have been installed by
##  'NewRepresentationBasisByNiceBasis'.
#T ?
##
InstallMethod( BasisOfDomain,
    "method for Gaussian matrix space (construct a semi-echelonized basis)",
    true,
    [ IsGaussianSpace and IsGaussianMatrixSpaceRep ], 0,
    SemiEchelonBasisOfDomain );

InstallMethod( BasisByGenerators,
    "method for Gaussian matrix space and list of matrices (try semi-ech.)",
    IsIdentical,
    [ IsGaussianSpace and IsGaussianMatrixSpaceRep, IsHomogeneousList ], 0,
    function( V, gens )

    local dims,
          heads,
          B,
          v;

    # Check whether the entries of 'gens' are matrices of the right shape.
    dims:= V!.vectordim;
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
                                IsBasis
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

InstallMethod( BasisByGeneratorsNC,
    "method for Gaussian matrix space and list of matrices (try semi-ech.)",
    IsIdentical,
    [ IsGaussianSpace and IsGaussianMatrixSpaceRep, IsHomogeneousList ], 0,
    function( V, gens )

    local B, heads;

    # Test whether the vectors form a semi-echelonized basis.
    # (If not then give up.)
    heads:= HeadsInfoOfSemiEchelonizedMats( gens, V!.vectordim );
    if heads = fail then
      TryNextMethod();
    fi;

    # Construct a semi-echelonized basis.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsBasis
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
#M  SemiEchelonBasisOfDomain( <V> )
#M  SemiEchelonBasisByGenerators( <V>, <vectors> )
#M  SemiEchelonBasisByGeneratorsNC( <V>, <vectors> )
##
InstallImmediateMethod( SemiEchelonBasisOfDomain,
    IsGaussianSpace and IsGaussianMatrixSpaceRep and HasCanonicalBasis, 20,
    CanonicalBasis );

InstallMethod( SemiEchelonBasisOfDomain,
    "method for Gaussian matrix space",
    true,
    [ IsGaussianSpace and IsGaussianMatrixSpaceRep ], 0,
    function( V )
    local B;
    B:= Objectify( NewType( FamilyObj( V ),
                                IsBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
    end );

InstallMethod( SemiEchelonBasisByGenerators,
    "method for Gaussian matrix space and list of matrices",
    IsIdentical,
    [ IsGaussianSpace and IsGaussianMatrixSpaceRep, IsHomogeneousList ], 0,
    function( V, gens )

    local heads,   # heads info for the basis
          B,       # the basis, result
          v;       # loop over vector space generators

    # Check that the vectors form a semi-echelonized basis.
    heads:= HeadsInfoOfSemiEchelonizedMats( gens, V!.vectordim );
    if heads = fail then
      return fail;
    fi;

    # Construct the basis.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsBasis
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

InstallMethod( SemiEchelonBasisByGeneratorsNC,
    "method for Gaussian matrix space and list of matrices",
    IsIdentical,
    [ IsGaussianSpace and IsGaussianMatrixSpaceRep, IsHomogeneousList ], 0,
    function( V, gens )

    local B,  # the basis, result
          v;  # loop over vector space generators

    B:= Objectify( NewType( FamilyObj( gens ),
                                IsBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );
    SetIsEmpty( B, IsEmpty( gens ) );

    # Provide the 'heads' information.
    B!.heads:= HeadsInfoOfSemiEchelonizedMats( gens, V!.vectordim );

    # Return the basis.
    return B;
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . .  for semi-ech. basis of Gaussian matrix space
##
InstallMethod( BasisVectors,
    "method for semi-ech. basis of a Gaussian matrix space",
    true,
    [ IsBasis and IsSemiEchelonBasisOfGaussianMatrixSpaceRep ], 0,
    function( B )
    local V, gens, zero, vectors;

    V:= UnderlyingLeftModule( B );

    # Note that we must not ask for the dimension here \ldots
    gens:= GeneratorsOfLeftModule( V );

    if IsEmpty( gens ) then

      SetIsEmpty( B, true );
      zero:= Zero( [ 1 .. V!.vectordim[2] ] );
      B!.heads:= List( [ 1 .. V!.vectordim[1] ], x -> zero );
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
#M  Zero( <V> )
##
InstallOtherMethod( Zero,
    "method for a matrix space",
    true,
    [ IsMatrixSpace ], 0,
    function( V )
    local zero;
    zero:= NullMat( V!.vectordim[1], V!.vectordim[2],
                    LeftActingDomain( V ) );
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
    "method for Gaussian matrix space",
    true,
    [ IsGaussianSpace and IsGaussianMatrixSpaceRep ], 0,
    function( V )

    local B,        # semi-echelonized basis
          vectors,  # basis vectors of 'B'
          base,     # vectors of the canonical basis
          newheads, # 'heads' component of the canonical basis
          m, n,     # dimensions of the matrices
          i, j,     # loop over rows and columns
          k, l,     # loop over rows and columns
          v,        # one basis vector
          C;        # canonical basis record, result

    # Compute a semi-echelonized basis.
    B:= SemiEchelonBasisOfDomain( V );
    vectors:= BasisVectors( B );

    # Sort the vectors such that the sequence of pivot positions
    # is increasing.
    base:= [];
    newheads:= List( B!.heads, ShallowCopy );

    if not IsEmpty( vectors ) then

      # Get the matrix dimensions.
      m:= V!.vectordim[1];
      n:= V!.vectordim[2];

      for i in [ 1 .. m ] do
        for j in [ 1 .. n ] do
          
          if B!.heads[i][j] <> 0 then
  
            # Reduce every vector with all those that
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
                if B!.heads[k][l] <> 0 and newheads[k][j] < newheads[i][l] then
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

    if IsLieObjectCollection( V ) then
      base:= List( base, LieObject );
    fi;

    # Make the basis.
    B:= Objectify( NewType( FamilyObj( V ),
                                IsBasis
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
    "method for Gaussian matrix space",
    true,
    [ IsGaussianSpace and IsGaussianMatrixSpaceRep ], 0,
    V -> Dimension( V ) = V!.vectordim[1] * V!.vectordim[2] );
     
InstallMethod( IsFullMatrixModule,
    "method for non-Gaussian matrix space",
    true,
    [ IsVectorSpace and IsNonGaussianMatrixSpaceRep ], 0,
    ReturnFalse );
     
InstallOtherMethod( IsFullMatrixModule,
    "method for arbitrary free left module",
    true,
    [ IsLeftModule ], 0,
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
    "method for full matrix space",
    true,
    [ IsGaussianSpace and IsGaussianMatrixSpaceRep and IsFullMatrixModule ],
    0,
    function( V )
    local B, m, n;
    B:= Objectify( NewType( FamilyObj( V ),
                                IsBasis
                            and IsCanonicalBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianMatrixSpaceRep
                            and IsCanonicalBasisFullMatrixModule ),
                   rec() );
    SetUnderlyingLeftModule( B, V );

    m:= V!.vectordim[1];
    n:= V!.vectordim[2];
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
##  'IsMutableBasisByImmutableBasisRep' if the mutable basis is closed by a
##  vector that makes the space non-Gaussian.
#T better switch to mutable basis by nice mutable basis !
##
##  Note that the 'basisVectors' component consists of ordinary matrices
##  also if the defining matrices are Lie matrices.
##
IsMutableBasisOfGaussianMatrixSpaceRep := NewRepresentation(
    "IsMutableBasisOfGaussianMatrixSpaceRep",
    IsComponentObjectRep and IsMutable,
    [ "heads", "basisVectors", "leftActingDomain", "zero" ] );


#############################################################################
##
#M  MutableBasisByGenerators( <R>, <mats> ) . . . . . . for matrices over <R>
##
InstallMethod( MutableBasisByGenerators,
    "method to construct mutable bases of Gaussian matrix spaces",
    IsElmsCollColls,
    [ IsRing, IsCollection ], 0,
    function( R, mats )
    local newmats, B;

    if ForAny( mats, mat -> ForAny( mat, v -> not IsSubset( R, v ) ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that uses a nice mutable basis.
      B:= MutableBasisViaNiceMutableBasisMethod2( R, mats );

    else

      # Note that 'mats' is not empty.
      newmats:= SemiEchelonMats( mats );

      B:= Objectify( NewType( FamilyObj( mats ),
                                  IsMutableBasis
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
#M  MutableBasisByGenerators( <R>, <mats> ) . . . . . . . .  for Lie matrices
##
InstallMethod( MutableBasisByGenerators,
    "method to construct a mutable basis of a Lie matrix space",
    IsElmsCollLieColls,
    [ IsDivisionRing, IsLieObjectCollection ], 0,
    function( R, mats )
    local B, newmats;

    if ForAny( mats, mat -> ForAny( mat, v -> not IsSubset( R, v ) ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that uses a nice mutable basis.
      B:= MutableBasisViaNiceMutableBasisMethod2( R, mats );

    else

      # Note that 'mats' is not empty.
      newmats:= SemiEchelonMats( mats );

      B:= Objectify( NewType( FamilyObj( mats ),
                                  IsMutableBasis
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
#M  MutableBasisByGenerators( <R>, <mats>, <zero> ) . . for matrices over <R>
##
InstallOtherMethod( MutableBasisByGenerators,
    "method to construct mutable bases of matrix spaces",
    true,
    [ IsRing, IsHomogeneousList, IsMatrix ], 0,
    function( R, mats, zero )
    local B, z;

    # Check whether this method is the right one.
    if not (    IsElmsColls( FamilyObj( R ), FamilyObj( zero ) )
             or IsElmsLieColls( FamilyObj( R ), FamilyObj( zero ) ) ) then
      TryNextMethod();
    fi;

    if ForAny( mats, mat -> ForAny( mat, v -> not IsSubset( R, v ) ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that uses a nice mutable basis.
      B:= MutableBasisViaNiceMutableBasisMethod3( R, mats, zero );

    else

      B:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                  IsMutableBasis
                              and IsMutableBasisOfGaussianMatrixSpaceRep ),
                     rec(
                          zero:= zero,
                          leftActingDomain := R
                          ) );

      if IsEmpty( mats ) then

        B!.basisVectors:= [];
        z:= ListWithIdenticalEntries( Length( zero[1] ), 0 );
        B!.heads:= List( zero, i -> ShallowCopy( z ) );

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
#M  PrintObj( <MB> )  . . . .  print mutable basis of a Gaussian matrix space
##
InstallMethod( PrintObj,
    "method for a mutable basis of a Gaussian matrix space",
    true,
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep ], 0,
    function( MB )
    Print( "<mutable basis over ", MB!.leftActingDomain, ", ",
           Length( MB!.basisVectors ), " vectors>" );
    end );


#############################################################################
##
#M  BasisVectors( <MB> )  . . .  for mutable basis of a Gaussian matrix space
##
InstallOtherMethod( BasisVectors,
    "method for a mutable basis of a Gaussian matrix space",
    true,
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep ], 0,
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
    "method for a mut. basis of a Gaussian matrix space, and a matrix",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep,
      IsMatrix ], 0,
    function( MB, v )
    local V,              # corresponding free left module
          m,              # number of rows
          n,              # number of columns
          heads,          # heads info of the basis
          zero,           # zero coefficient
          basisvectors,   # list of basis vectors of 'MB'
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

      MB!.immutableBasis:= BasisOfDomain( V );

    else

      m:= Length( v    );
      n:= Length( v[1] );
      heads:= MB!.heads;
      zero:= Zero( v[1][1] );
      basisvectors:= MB!.basisVectors;

      # Reduce 'v' with the known basis vectors.
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

      # If necessary add the sifted vector, and update the basis info.
      for i in [ 1 .. m ] do
        j := PositionNot( v[i], zero );
        if j <= n then
          scalar:= Inverse( v[i][j] );
          for k in [ 1 .. m ] do
            MultRowVector( v[k], scalar );
          od;
          Add( basisvectors, v );
          heads[i][j]:= Length( basisvectors );
          return;
        fi;
      od;

    fi;
    end );


#############################################################################
##
#M  IsContainedInSpan( <MB>, <v> )  . for mut. basis of Gaussian matrix space
##
InstallMethod( IsContainedInSpan,
    "method for a mut. basis of a Gaussian matrix space, and a matrix",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep,
      IsMatrix ], 0,
    function( MB, v )
    local V,              # corresponding free left module
          m,              # number of rows
          n,              # number of columns
          heads,          # heads info of the basis
          zero,           # zero coefficient
          basisvectors,   # list of basis vectors of 'MB'
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
      zero:= Zero( v[1][1] );
      basisvectors:= MB!.basisVectors;

      # Reduce 'v' with the known basis vectors.
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
#M  ImmutableBasis( <MB> )  . .  for mutable basis of a Gaussian matrix space
##
InstallMethod( ImmutableBasis,
    "method for a mutable basis of a Gaussian matrix space",
    true,
    [ IsMutableBasis and IsMutableBasisOfGaussianMatrixSpaceRep ], 0,
    function( MB )
    local V;
    V:= FreeLeftModule( MB!.leftActingDomain,
                        BasisVectors( MB ),
                        MB!.zero );
    MB:= SemiEchelonBasisByGeneratorsNC( V, BasisVectors( MB ) );
#T use known 'heads' info !!
    UseBasis( V, MB );
    return MB;
    end );


#T mutable bases for Gaussian row and matrix spaces should allow 'SiftedVector'!
#T mutable bases for Gaussian row and matrix spaces are always semi-ech.
#T (note that we construct a mutable basis only if we want to do successive
#T closures)


#############################################################################
##
#E  vspcmat.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



