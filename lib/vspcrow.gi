#############################################################################
##
#W  vspcrow.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for row spaces.
##  A row space is a vector space whose elements are row vectors.
##
##  The coefficients field need *not* contain all entries of the row vectors.
##  If it does then the space is a *Gaussian row space*,
##  with better methods to deal with bases.
##  If it does not then the bases use the mechanism of associated bases.
##
##  (See the file 'vspcmat.gi' for methods for matrix spaces.)
##
##  All row spaces have the component 'vectordim'.
##
##  1. Domain constructors for row spaces
##  2. Methods for bases of non-Gaussian row spaces
##  3. Methods for semi-echelonized bases of Gaussian row spaces
##  4. Methods for row spaces
##  5. Methods for full row spaces
##  6. Methods for collections of subspaces of full row spaces
##  7. Methods for mutable bases of Gaussian row spaces
##
Revision.vspcrow_gi :=
    "@(#)$Id$";


#############################################################################
##
#R  IsRowSpace( <V> )
##
IsRowSpace := IsRowModuleRep and IsVectorSpace;


#############################################################################
##
#R  IsGaussianRowSpaceRep( <V> )
##
##  A row space is Gaussian if the left acting domain contains all
##  scalars that occur in the vectors.
##  Thus one can use Gaussian elimination in the calculations.
##
##  (Otherwise the space is non-Gaussian.
##  We will need a flag for this to write down methods that delegate from
##  non-Gaussian spaces to Gaussian ones.)
##
IsGaussianRowSpaceRep :=     IsGaussianSpace
                         and IsRowModuleRep
                         and IsAttributeStoringRep;


#############################################################################
##
#R  IsNonGaussianRowSpaceRep( <V> )
##
##  A non-Gaussian row space <V> is a special representation of a space
##  that is handled by an associated basis.
##
##  <V> may have the additional component
##  'basisFieldExtension' : \\
##        basis $C$ of $K / ( K \cap F )$,
##        where $F$ denotes the coefficients field of 'V',
##        and $K$ the field spanned by the entries of all vectors in 'V'.
##
##  The associated row vector is defined by replacing every vector entry
##  by its $C$-coefficients, and then forming the concatenation.
##  So the associated nice space is a Gaussian row space.
##
IsNonGaussianRowSpaceRep := NewRepresentation( "IsNonGaussianRowSpaceRep",
    IsAttributeStoringRep and IsRowModuleRep and IsHandledByNiceBasis,
    [ "basisFieldExtension" ] );


#############################################################################
##
##  1. Domain constructors for row spaces
##

#############################################################################
##
#M  LeftModuleByGenerators( <F>, <mat> )
##
#T The only reason for this method is that we get a space and not only
#T a module if <F> is a division ring.
##
InstallMethod( LeftModuleByGenerators,
    "method for division ring and matrix over it",
    IsElmsColls,
    [ IsDivisionRing, IsMatrix ], 0,
    function( F, mat )
    local V;

    if ForAll( mat, row -> IsSubset( F, row ) ) then
      V:= Objectify( NewKind( FamilyObj( mat ),
                                  IsGaussianSpace
                              and IsGaussianRowSpaceRep ),
                     rec() );
    else
      V:= Objectify( NewKind( FamilyObj( mat ),
                                  IsVectorSpace
                              and IsNonGaussianRowSpaceRep ),
                     rec() );
    fi;

    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( mat ) );
    V!.vectordim:= Length( mat[1] );

    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <F>, <mat>, <zerorow> )
##
#T The only reason for this method is that we get a space and not only
#T a module if <F> is a division ring.
##
InstallOtherMethod( LeftModuleByGenerators,
    "method for division ring, empty list, and row vector",
    true,
    [ IsDivisionRing, IsList and IsEmpty, IsRowVector ], 0,
    function( F, empty, zero )
    local V;

    # Check whether this method is the right one.
    if not IsIdentical( FamilyObj( F ), FamilyObj( zero ) ) then
      TryNextMethod();
    fi;
#T explicit 2nd argument above!

    V:= Objectify( NewKind( CollectionsFamily( FamilyObj( F ) ),
                                IsGaussianSpace
                            and IsGaussianRowSpaceRep ),
                   rec() );
    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, empty );
    SetZero( V, zero );
    V!.vectordim:= Length( zero );

    return V;
    end );

InstallOtherMethod( LeftModuleByGenerators,
    "method for division ring, matrix over it, and row vector",
    true,
    [ IsDivisionRing, IsMatrix, IsRowVector ], 0,
    function( F, mat, zero )
    local V;

    # Check whether this method is the right one.
    if not IsElmsColls( FamilyObj( F ), FamilyObj( mat ) ) then
      TryNextMethod();
    fi;
#T explicit 2nd argument above!

    if ForAll( mat, row -> IsSubset( F, row ) ) then
      V:= Objectify( NewKind( FamilyObj( mat ),
                                  IsGaussianSpace
                              and IsGaussianRowSpaceRep ),
                     rec() );
    else
      V:= Objectify( NewKind( FamilyObj( mat ),
                                  IsVectorSpace
                              and IsNonGaussianRowSpaceRep ),
                     rec() );
    fi;

    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( mat ) );
    SetZero( V, zero );
    V!.vectordim:= Length( mat[1] );

    return V;
    end );


#############################################################################
##
##  2. Methods for bases of non-Gaussian row spaces
##

#############################################################################
##
#M  PrepareNiceFreeLeftModule( <V> )
##
InstallMethod( PrepareNiceFreeLeftModule,
    "method for non-Gaussian row space",
    true,
    [ IsVectorSpace and IsNonGaussianRowSpaceRep ], 0,
    function( V )

    local vgens,  # vector space generators of 'V'
          K;      # field generated by entries in elements of 'V'

    vgens:= GeneratorsOfLeftModule( V );
    if not IsEmpty( vgens ) then
      K:= FieldByGenerators( Concatenation( vgens ) );
#T cheaper way?
      V!.basisFieldExtension:=
            Basis( AsField( Intersection( K, LeftActingDomain( V ) ), K ) );
    fi;
    end );


#############################################################################
##
#M  NiceVector( <V>, <v> )
##
InstallMethod( NiceVector,
    "method for non-Gaussian row space and row vector",
    IsCollsElms,
    [ IsVectorSpace and IsNonGaussianRowSpaceRep, IsRowVector ], 0,
    function( V, v )
    local list, entry, new;
    list:= [];
    for entry in v do
      new:= Coefficients( V!.basisFieldExtension, entry );
      if new = fail then
        return fail;
      fi;
      Append( list, new );
    od;
    return list;
    end );


#############################################################################
##
#M  UglyVector( <V>, <v> )
##
InstallMethod( UglyVector,
    "method for non-Gaussian row space and row vector",
    IsCollsElms,
    [ IsVectorSpace and IsNonGaussianRowSpaceRep, IsRowVector ], 0,
    function( V, v )

    local FB,  # basis vectors of the basis of the field extension
          n,   # degree of the field extension
          w,   # associated vector, result
          i;   # loop variable

    FB:= BasisVectors( V!.basisFieldExtension );
    n:= Length( FB );
    w:= [];
    for i in [ 1 .. Length( v ) / n ] do
      w[i]:= v{ [ n*(i-1)+1 .. n*i ] } * FB;
    od;
    return w;
    end );


#############################################################################
##
##  3. Methods for semi-echelonized bases of Gaussian row spaces
##

#############################################################################
##
#R  IsSemiEchelonBasisOfGaussianRowSpaceRep( <B> )
##
##  A basis of a Gaussian row space is either semi-echelonized or it is a
##  relative basis.
##  (So there is no need for 'IsBasisGaussianRowSpace').
##
##  If basis vectors are known then the component 'heads' is bound.
##
IsSemiEchelonBasisOfGaussianRowSpaceRep := NewRepresentation(
    "IsSemiEchelonBasisOfGaussianRowSpaceRep",
    IsAttributeStoringRep,
    [ "heads" ] );


#############################################################################
##
#M  LinearCombination( <B>, <coeff> )
##
InstallMethod( LinearCombination, IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianRowSpaceRep, IsRowVector ], 0,
    function( B, coeff )
    return coeff * BasisVectors( B );
    end );


#############################################################################
##
#M  Coefficients( <B>, <v> )  .  method for semi-ech. basis of Gaussian space
##
InstallMethod( Coefficients,
    "method for semi-ech. basis of a Gaussian row space, and a row vector",
    IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianRowSpaceRep, IsRowVector ], 0,
    function( B, v )

    local coeff,     # coefficients list, result
          zero,      # zero of the field
          vectors,   # basis vectors of 'B'
          len,       # length of 'v'
          i,         # loop over 'v'
          pos;       # heads position

    # Preset the coefficients list with zeroes.
    zero:= Zero( v[1] );
    vectors:= BasisVectors( B );
    coeff:= List( vectors, x -> zero );
#T store zero vector in the basis ?

    # Compute the coefficients of the base vectors.
    v:= ShallowCopy( v );
    len:= Length( v );
    i:= PositionNot( v, zero );
    while i <= len do
      pos:= B!.heads[i];
      if pos <> 0 then
        coeff[ pos ]:= v[i];
        AddRowVector( v, vectors[ pos ], - v[i] );
      else
        return fail;
      fi;
      i:= PositionNot( v, zero );
    od;

    # Return the coefficients.
    return coeff;
    end );


#############################################################################
##
#M  SiftedVector( <B>, <v> )
##
##  If '<B>!.heads[<i>]' is nonzero this means that the <i>-th column is
##  leading column of the row '<B>!.heads[<i>]'.
##
InstallMethod( SiftedVector,
    "method for semi-ech. basis of Gaussian row space, and row vector",
    IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianRowSpaceRep, IsRowVector ], 0,
    function( B, v )

    local zero,    # zero of the field
          vectors, # basis vectors of <B>
          i;       # loop over basis vectors

    zero:= 0 * v[1];

    # Compute the coefficients of the 'B' vectors.
    v:= ShallowCopy( v );
    vectors:= BasisVectors( B );
    for i in [ 1 .. Length( B!.heads ) ] do
      if B!.heads[i] <> 0 and v[i] <> zero then
        AddRowVector( v, vectors[ B!.heads[i] ], - v[i] );
      fi;
    od;

    # Return the remainder.
    return v;
    end );


#############################################################################
##
#F  HeadsInfoOfSemiEchelonizedMat( <mat>, <dim> )
##
##  is the 'heads' information of the matrix <mat> with <dim> columns
##  if <mat> can be viewed as a semi-echelonized basis
##  of a Gaussian row space, and 'fail' otherwise.
##
HeadsInfoOfSemiEchelonizedMat := function( mat, dim )

    local zero,     # zero of the field
          one,      # one of the field
          nrows,    # number of rows
          heads,    # list of pivot rows
          i,        # loop over rows
          j,        # pivot column
          k;        # loop over lower rows

    nrows:= Length( mat );
    heads:= Zero( [ 1 .. dim ] );

    if 0 < nrows then

      zero := Zero( mat[1][1] );
      one  := One( zero );

      # Loop over the columns.
      for i in [ 1 .. nrows ] do

        j:= PositionNot( mat[i], zero );
        if dim < j or mat[i][j] <> one then
          return fail;
        fi;
        for k in [ i+1 .. nrows ] do
          if mat[k][j] <> zero then
            return fail;
          fi;
        od;
        heads[j]:= i;

      od;

    fi;

    return heads;
end;


#############################################################################
##
#M  IsSemiEchelonized( <B> )
##
##  A basis of a Gaussian row space over a division ring with identity
##  element $e$ is in semi-echelon form if the leading entry of every row is
##  equal to $e$, and all entries exactly below that position are zero.
##
##  (This form is obtained on application of 'SemiEchelonMat' to a matrix.)
##
InstallMethod( IsSemiEchelonized,
    "method for basis of a Gaussian row space",
    true,
    [ IsBasis ], 0,
    function( B )
    local V;
    V:= UnderlyingLeftModule( B );
    if not IsGaussianRowSpaceRep( V ) then
#T The basis does not know whether it is a basis of a row space at all.
      TryNextMethod();
    else
      return HeadsInfoOfSemiEchelonizedMat( BasisVectors( B ),
                                            V!.vectordim ) <> fail;
#T change the basis from relative to seb ?
    fi;
    end );


#############################################################################
##
##  4. Methods for row spaces
##


#############################################################################
##
#M  \*( <V>, <mat> ) . . . . . . . . . . . . . action of matrix on row spaces
#M  \^( <V>, <mat> ) . . . . . . . . . . . . . action of matrix on row spaces
##
InstallOtherMethod( \*, IsIdentical, [ IsRowSpace, IsMatrix ], 0,
    function( V, mat )
    return LeftModuleByGenerators( LeftActingDomain( V ),
                            List( GeneratorsOfLeftModule( V ),
                                  v -> v * mat ) );
    end );

InstallOtherMethod( \^, IsIdentical, [ IsRowSpace, IsMatrix ], 0,
    function( V, mat )
    return LeftModuleByGenerators( LeftActingDomain( V ),
                            List( GeneratorsOfLeftModule( V ),
                                  v -> v * mat ) );
    end );


#############################################################################
##
#M  \in( <v>, <V> ) . . . . . . . . . . for row vector and Gaussian row space
##
InstallMethod( \in,
    "method for row vector and Gaussian row space",
    IsElmsColls,
    [ IsRowVector, IsGaussianSpace and IsGaussianRowSpaceRep ], 0,
    function( v, V )
    if IsEmpty( v ) then
      return V!.vectordim = 0;
    else
      return     V!.vectordim = Length( v )
             and V!.vectordim <
                  PositionNot( SiftedVector( Basis( V ), v ), Zero( v[1] ) );
    fi;
    end );


#############################################################################
##
#M  BasisOfDomain( <V> )  . . . . . . . . . . . . . .  for Gaussian row space
#M  BasisByGenerators( <V>, <vectors> ) . . . . . . .  for Gaussian row space
#M  BasisByGeneratorsNC( <V>, <vectors> ) . . . . . .  for Gaussian row space
##
##  Distinguish the cases whether the space <V> is a Gaussian row vector
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
    "method for Gaussian row space (construct a semi-echelonized basis)",
    true,
    [ IsGaussianSpace and IsGaussianRowSpaceRep ], 0,
    SemiEchelonBasisOfDomain );

InstallMethod( BasisByGenerators,
    "method for Gaussian row space and matrix (try semi-echelonized)",
    IsIdentical,
    [ IsGaussianSpace and IsGaussianRowSpaceRep, IsMatrix ], 0,
    function( V, gens )

    local heads,
          B,
          v;

    # Test whether the vectors form a semi-echelonized basis.
    # (If not then give up.)
    heads:= HeadsInfoOfSemiEchelonizedMat( gens, V!.vectordim );
    if heads = fail then
      TryNextMethod();
    fi;

    # Construct the basis.
    B:= Objectify( NewKind( FamilyObj( gens ),
                                IsBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
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

InstallMethod( BasisByGeneratorsNC, IsIdentical,
    [ IsGaussianSpace and IsGaussianRowSpaceRep, IsMatrix ], 0,
    function( V, gens )

    local heads, B;

    # Test whether the vectors form a semi-echelonized basis.
    # (If not then give up.)
    heads:= HeadsInfoOfSemiEchelonizedMat( gens, V!.vectordim );
    if heads = fail then
      TryNextMethod();
    fi;

    # Construct the basis.
    B:= Objectify( NewKind( FamilyObj( gens ),
                                IsBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
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
    IsGaussianSpace and IsGaussianRowSpaceRep and HasCanonicalBasis, 20,
    CanonicalBasis );

InstallMethod( SemiEchelonBasisOfDomain,
    "method for Gaussian row space",
    true,
    [ IsGaussianSpace and IsGaussianRowSpaceRep ], 0,
    function( V )
    local B;
    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
    end );

InstallMethod( SemiEchelonBasisByGenerators,
    "method for Gaussian row space and matrix",
    IsIdentical,
    [ IsGaussianSpace and IsGaussianRowSpaceRep, IsMatrix ], 0,
    function( V, gens )

    local heads,   # heads info for the basis
          B,       # the basis, result
          v;       # loop over vector space generators

    # Check that the vectors form a semi-echelonized basis.
    heads:= HeadsInfoOfSemiEchelonizedMat( gens, V!.vectordim );
    if heads = fail then
      return fail;
    fi;

    # Construct the basis.
    B:= Objectify( NewKind( FamilyObj( gens ),
                                IsBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
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
    "method for Gaussian row space and matrix",
    IsIdentical,
    [ IsGaussianSpace and IsGaussianRowSpaceRep, IsMatrix ], 0,
    function( V, gens )

    local B,  # the basis, result
          v;  # loop over vector space generators

    B:= Objectify( NewKind( FamilyObj( gens ),
                                IsBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );
    SetIsEmpty( B, IsEmpty( gens ) );

    # Provide the 'heads' information.
    B!.heads:= HeadsInfoOfSemiEchelonizedMat( gens, V!.vectordim );

    # Return the basis.
    return B;
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . . . . for semi-ech. basis of Gaussian row space
##
InstallMethod( BasisVectors,
    "method for semi-ech. basis of a Gaussian row space",
    true,
    [ IsBasis and IsSemiEchelonBasisOfGaussianRowSpaceRep ], 0,
    function( B )
    local V, gens, vectors;

    V:= UnderlyingLeftModule( B );

    # Note that we must not ask for the dimension here \ldots
    gens:= GeneratorsOfLeftModule( V );

    if IsEmpty( gens ) then

      B!.heads:= List( [ 1 .. V!.vectordim ], x -> 0 );
      SetIsEmpty( B, true );
      vectors:= [];

    else

      gens:= SemiEchelonMat( gens );
      B!.heads:= gens.heads;
      vectors:= gens.vectors;

    fi;
    return vectors;
    end );


#############################################################################
##
#M  Zero( <V> )
##
InstallOtherMethod( Zero, true, [ IsRowSpace ], 0,
    V -> Zero( LeftActingDomain( V ) ) * [ 1 .. V!.vectordim ] );


#############################################################################
##
#M  IsZero( <v> )
##
InstallMethod( IsZero,
    "method for row vector",
    true,
    [ IsRowVector ],
    0,
    function( v )
    if IsEmpty( v ) then
      return true;
    else
      return Length( v ) < PositionNot( v, Zero( v[1] ) );
    fi;
    end );


#############################################################################
##
#M  AsLeftModule( <F>, <rows> ) . . . . . . . .  for division ring and matrix
##
InstallOtherMethod( AsLeftModule,
    "method for division ring and matrix",
    IsElmsColls,
    [ IsDivisionRing, IsMatrix ], 0,
    function( F, vectors )

    local m;

    if not IsPrimePowerInt( Length( vectors ) ) then
      Error( "<vectors> cannot be a vector space" );
    elif ForAll( vectors, v -> IsSubset( F, v ) ) then
#T other check!

      # All vector entries lie in 'F'.
      # (We work destructively.)
      m:= SemiEchelonMat( List( vectors, ShallowCopy ) ).vectors;
      if IsEmpty( m ) then
        m:= LeftModuleByGenerators( F, [], vectors[1] );
      else
        m:= LeftModuleByGenerators( F, m, "basis" );
      fi;

    else

      # We have at most a non-Gaussian row space.
      m:= LeftModuleByGenerators( F, vectors );

    fi;

    # Check that the space equals the list of vectors.
    if Size( m ) <> Length( vectors ) then
      Error( "<vectors> is not an <F>-space" );
    fi;

    # Return the space.
    return m;
    end );


#############################################################################
##
#M  \+( <U1>, <U2> )  . . . . . . . . . . . .  sum of two Gaussian row spaces
##
InstallOtherMethod( \+,
    "method for two Gaussian row spaces",
    IsIdentical,
    [ IsGaussianSpace and IsGaussianRowSpaceRep,
      IsGaussianSpace and IsGaussianRowSpaceRep ], 0,
    function( V, W )

    local S,          # sum of <V> and <W>, result
          mat;        # basis vectors of the sum

    if   V!.vectordim <> W!.vectordim then
      Error( "vectors in <V> and <W> have different dimension" );
    elif Dimension( V ) = 0 then
      S:= W;
    elif Dimension( W ) = 0 then
      S:= V;
    elif LeftActingDomain( V ) <> LeftActingDomain( W ) then
      S:= Intersection2( LeftActingDomain( V ), LeftActingDomain( W ) );
      S:= \+( AsVectorSpace( S, V ), AsVectorSpace( S, W ) );
    else
      mat:= SumIntersectionMat( GeneratorsOfLeftModule( V ),
                                GeneratorsOfLeftModule( W ) )[1];
      if IsEmpty( mat ) then
        S:= TrivialSubspace( V );
      else
        S:= LeftModuleByGenerators( LeftActingDomain( V ), mat );
        UseBasis( S, mat );
      fi;
    fi;

    return S;
    end );


#############################################################################
##
#M  Intersection2( <V>, <W> ) . . . . intersection of two Gaussian row spaces
##
InstallMethod( Intersection2,
    "method for two Gaussian row spaces",
    IsIdentical,
    [ IsGaussianSpace and IsGaussianRowSpaceRep,
      IsGaussianSpace and IsGaussianRowSpaceRep ], 0,
    function( V, W )

    local S,          # intersection of 'V' and 'W', result
          mat;        # basis vectors of the intersection

    if   V!.vectordim <> W!.vectordim then
      S:= [];
    elif Dimension( V ) = 0 then
      S:= V;
    elif Dimension( W ) = 0 then
      S:= W;
    elif LeftActingDomain( V ) <> LeftActingDomain( W ) then
      S:= Intersection2( LeftActingDomain( V ), LeftActingDomain( W ) );
      S:= \+( AsVectorSpace( S, V ), AsVectorSpace( S, W ) );
    else

      # Compute the intersection of two spaces over the same field.
      mat:= SumIntersectionMat( GeneratorsOfLeftModule( V ),
                                GeneratorsOfLeftModule( W ) )[2];
      if IsEmpty( mat ) then
        S:= TrivialSubspace( V );
      else
        S:= LeftModuleByGenerators( LeftActingDomain( V ), mat );
        UseBasis( S, mat );
      fi;

    fi;

    return S;
    end );


#############################################################################
##
#M  NormedVectors( <V> )
##
InstallMethod( NormedVectors,
    "method for Gaussian row space",
    true,
    [ IsGaussianSpace and IsGaussianRowSpaceRep ], 0,
    function ( V )

    local base,       # basis vectors
          elms,       # element list, result
          j,          # loop over 'base'
          elms2,      # intermediate element list
          fieldelms,  # elements of 'LeftActingDomain(V)' (other succession)
          new,        # intermediate element list
          pos,        # position in 'new' to store the next element
          len,        # actual length of 'elms2'
          range,      # range to loop over
          i,          # loop over field elements
          k,          # loop over 'elms2'
          toadd;      # vector to add to known vectors

    if not IsFinite( V ) then
      Error( "sorry, cannot compute normed vectors of infinite domain <V>" );
    fi;

    base:= Reversed( BasisVectors( CanonicalBasis( V ) ) );
    if Length( base ) = 0 then
      return [];
    fi;

    elms      := [ base[1] ];
    elms2     := [ base[1] ];
    fieldelms := List( AsListSorted( LeftActingDomain( V ) ), x -> x - 1 );

    for j in [ 1 .. Length( base ) - 1 ] do

      # Here 'elms2' has the form
      # $b_i + M = b_i + \langle b_{i+1}, \ldots, b_n \rangle$.
      # Compute $b_{i-1} + \bigcup_{\lambda\in F} \lambda b_i + ( b_i + M )$.
      new:= [];
      pos:= 0;
      len:= Length( elms2 );
      range:= [ 1 .. len ];
      for i in fieldelms do
        toadd:= base[j+1] + i * base[j];
        for k in range do
          new[ pos + k ]:= elms2[k] + toadd;
        od;
        pos:= pos + len;
      od;
      elms2:= new;

      # 'elms2' is a set here.
      Append( elms, elms2 );

    od;
    return elms;
    end );


#############################################################################
##
#M  CanonicalBasis( <V> ) . . . . . . . . . . . . . .  for Gaussian row space
##
##  The canonical basis of a Gaussian row space is defined by applying
##  a full Gauss algorithm to the generators of the space.
##
InstallMethod( CanonicalBasis,
    "method for Gaussian row space with known semi-ech. basis",
    true,
    [     IsGaussianSpace and IsGaussianRowSpaceRep
      and HasSemiEchelonBasisOfDomain ], 0,
    function( V )

    local base,    # list of base vectors
          heads,   # list of numbers of leading columns
          ech,     # echelonized basis, if known
          vectors, #
          row,     # one vector in 'ech'
          B,       # basis record, result
          m,       # number of rows in generators
          n,       # number of columns in generators
          zero,    # zero of the field
          i,       # loop over rows
          k;       # loop over columns

    base  := [];
    heads := [];
    zero  := Zero( LeftActingDomain( V ) );

    # We use the semi-echelonized basis.
    # All we have to do is to sort the basis vectors such that the
    # pivot elements are in increasing order, and to zeroize all
    # elements in the pivot columns except the pivot itself.

    ech:= SemiEchelonBasisOfDomain( V );
    vectors:= BasisVectors( ech );
    heads := ShallowCopy( ech!.heads );
    n:= Length( heads );

    for i in [ 1 .. n ] do
      if heads[i] <> 0 then

        # Eliminate the 'ech!.heads[i]'-th row with all those rows
        # that are below this row and have a bigger pivot element.
        row:= ShallowCopy( vectors[ ech!.heads[i] ] );
        for k in [ i+1 .. n ] do
          if heads[k] <> 0 and ech!.heads[k] > ech!.heads[i] then
            AddRowVector( row, vectors[ ech!.heads[k] ], - row[k] );
          fi;
        od;
        Add( base, row );
        heads[i]:= Length( base );

      fi;
    od;

    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep
                            and IsCanonicalBasis ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, base );
    SetIsEmpty( B, IsEmpty( base ) );

    B!.heads:= heads;

    # Return the basis.
    return B;
    end );

InstallMethod( CanonicalBasis,
    "method for Gaussian row space",
    true,
    [ IsGaussianSpace and IsGaussianRowSpaceRep ], 0,
    function( V )

    local base,    # list of base vectors
          heads,   # list of numbers of leading columns
          ech,     # echelonized basis, if known
          vectors, #
          row,     # one vector in 'ech'
          B,       # basis record, result
          m,       # number of rows in generators
          n,       # number of columns in generators
          zero,    # zero of the field
          i,       # loop over rows
          k;       # loop over columns

    base  := [];
    heads := Zero( [ 1 .. V!.vectordim ] );
    zero  := Zero( LeftActingDomain( V ) );

    if not IsEmpty( GeneratorsOfLeftModule( V ) ) then

      # Make a copy to avoid changing the original argument.
      B:= List( GeneratorsOfLeftModule( V ), ShallowCopy );
      m:= Length( B );
      n:= Length( B[1] );

      # Triangulize the matrix
      TriangulizeMat( B );

      # and keep only the nonzero rows of the triangular matrix.
      i:= 1;
      base := [];
      for k in [ 1 .. n ] do
        if i <= m and B[i][k] <> zero then
          base[i]:= B[i];
          heads[k]:= i;
          i:= i + 1;
        fi;
      od;

    fi;

    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep
                            and IsCanonicalBasis ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, base );
    SetIsEmpty( B, IsEmpty( base ) );

    B!.heads:= heads;

    # Return the basis.
    return B;
    end );


#############################################################################
##
##  5. Methods for full row spaces
##

#############################################################################
##
#M  IsFullRowModule( V )
##
InstallMethod( IsFullRowModule,
    "method for Gaussian row space",
    true,
    [ IsGaussianSpace and IsGaussianRowSpaceRep ], 0,
    V -> Dimension( V ) = V!.vectordim );
     
InstallMethod( IsFullRowModule,
    "method for non-Gaussian row space",
    true,
    [ IsVectorSpace and IsNonGaussianRowSpaceRep ], 0,
    ReturnFalse );

InstallOtherMethod( IsFullRowModule,
    "method for arbitrary free left module",
    true,
    [ IsLeftModule ], 0,
    function( V )
    local gens, R;

    # A full row module is a free left module.
    if not IsFreeLeftModule( V ) then
      return false;
    fi;

    # The elements of a full row module are row vectors over the
    # left acting domain,
    # and the dimension equals the length of the row vectors.
    gens:= GeneratorsOfLeftModule( V );
    if IsEmpty( gens ) then
      gens:= [ Zero( V ) ];
    fi;
    R:= LeftActingDomain( V );
    return     ForAll( gens,
                       row -> IsRowVector( row ) and IsSubset( R, row ) )
           and Dimension( V ) = Length( gens[1] );
    end );


#############################################################################
##
#M  CanonicalBasis( <V> )
##
InstallMethod( CanonicalBasis, true,
    [ IsGaussianSpace and IsGaussianRowSpaceRep and IsFullRowModule ], 0,
    function( V )
    local B;
    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsCanonicalBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep
                            and IsCanonicalBasisFullRowModule ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    B!.heads:= [ 1 .. V!.vectordim ];
    return B;
    end );


#############################################################################
##
##  6. Methods for collections of subspaces of full row spaces
##

#############################################################################
##
#R  IsSubspacesFullRowSpaceRep
##
IsSubspacesFullRowSpaceRep := NewRepresentation(
    "IsSubspacesFullRowSpaceRep",
    IsSubspacesVectorSpace,
    [] );


#############################################################################
##
#R  IsDimSubspacesFullRowSpaceIteratorRep
##
IsDimSubspacesFullRowSpaceIteratorRep := NewRepresentation(
    "IsDimSubspacesFullRowSpaceIteratorRep",
    IsComponentObjectRep,
    [ "V", "field", "n", "k", "choiceiter", "actchoice", "spaceiter" ] );


#############################################################################
##
#R  IsAllSubspacesFullRowSpaceIteratorRep
##
IsAllSubspacesFullRowSpaceIteratorRep := NewRepresentation(
    "IsAllSubspacesFullRowSpaceIteratorRep",
    IsComponentObjectRep,
    [ "dim", "V", "actdim", "actdimiter" ] );


#############################################################################
##
#M  Iterator( <subspaces> ) . . . . . for subspaces of finite full row module
##
InstallMethod( Iterator,
    "method for subspaces collection of a (finite) full row module",
    true,
    [ IsDomain and IsSubspacesFullRowSpaceRep ], 0,
    function( D )

    local V,      # the vector space
          n,      # dimension of 'V'
          k,
          iter;   # iterator, result

    V:= D!.structure;

    if not IsFinite( V ) then
      TryNextMethod();
    fi;

    k:= D!.dimension;
    n:= Dimension( V );

    if IsInt( D!.dimension ) then

      # Loop over subspaces of fixed dimension 'k'.
      # For that, loop over all possible choices of 'k' ordered positions
      # in '[ 1 .. n ]', and for every such choice, loop over all
      # possibilities to fill the positions in the canonical basis
      # that has these positions as pivot columns.

      # If the choice is $[ a_1, a_2, \ldots, a_k ]$ then there are
      # \[ (a_2-a_1-1)+2(a_3-a_2-1)+\cdots + (k-1)(a_k-a_{k-1}-1)+k(n-a_k)
      #    = \sum_{i=1}^{k-1} i(a_{i+1}-a_i-1) + k(n-a_k)
      #    = k n - \frac{1}{2}k(k-1) - \sum_{i=1}^k a_i \]
      # positions that can be chosen arbitrarily, so we may loop over
      # the elements of a space of this dimension.

      iter:= Objectify( NewKind( IteratorsFamily,
                                     IsIterator
                                 and IsDimSubspacesFullRowSpaceIteratorRep ),
                        rec(
                             V          := V,
                             field      := LeftActingDomain( V ),
                             n          := n,
                             k          := k,
                             choiceiter := Iterator( Combinations( [ 1..n ],
                                                     D!.dimension ) )
#T better make this *really* clever!
                            ) );
      # Initialize.
      iter!.actchoice:= NextIterator( iter!.choiceiter );
      iter!.spaceiter:= IteratorByBasis( CanonicalBasis( FullRowSpace(
           iter!.field, n * k - k * (k - 1) / 2
                               - Sum( iter!.actchoice ) ) ) );
      Add( iter!.actchoice, n+1 );

    else

      # Loop over all subspaces of 'V'.
      # For that, use iterators for subspaces of fixed dimension,
      # and loop over all dimensions.
      iter:= Objectify( NewKind( IteratorsFamily,
                                     IsIterator
                                 and IsAllSubspacesFullRowSpaceIteratorRep ),
                        rec(
                             V          := V,
                             dim        := n,
                             actdim     := 0,
                             actdimiter := Iterator( SubspacesDim( V, 0 ) )
                            ) );

    fi;

    # Return the iterator.
    return iter;
    end );

InstallMethod( IsDoneIterator, true,
    [ IsIterator and IsDimSubspacesFullRowSpaceIteratorRep ], 0,
    iter ->     IsDoneIterator( iter!.choiceiter )
            and IsDoneIterator( iter!.spaceiter ) );

InstallMethod( NextIterator, true,
    [ IsIterator and IsDimSubspacesFullRowSpaceIteratorRep ], 0,
    function( iter )

    local dim,
          vector,
          pos,
          base,
          i,
          j,
          k,
          n,
          diff;

    k:= iter!.k;
    n:= iter!.n;

    if IsDoneIterator( iter!.spaceiter ) then

      # Get the next choice of pivot positions,
      # and install an iterator for spaces with this choice.
      iter!.actchoice:= NextIterator( iter!.choiceiter );
      dim:= n * k - k * (k - 1) / 2 - Sum( iter!.actchoice );
      Add( iter!.actchoice, n + 1 );
      iter!.spaceiter:= IteratorByBasis(
          CanonicalBasis( FullRowSpace( iter!.field, dim ) ) );

    fi;

    # Construct the canonical basis of the space.
    vector:= NextIterator( iter!.spaceiter );
    pos:= 0;
    base:= NullMat( k, n, iter!.field );
    for i in [ 1 .. k ] do
      base[i][ iter!.actchoice[i] ]:= One( iter!.field );
      for j in [ i .. k ] do
        diff:= iter!.actchoice[ j+1 ] - iter!.actchoice[j] - 1;
        if diff > 0 then
          base[i]{ [ iter!.actchoice[j]+1 .. iter!.actchoice[j+1]-1 ] }:=
                   vector{ [ pos + 1 .. pos + diff ] };
          pos:= pos + diff;
        fi;
      od;
    od;

    return Subspace( iter!.V, base, "basis" );
    end );

InstallMethod( IsDoneIterator, true,
    [ IsIterator and IsAllSubspacesFullRowSpaceIteratorRep ], 0,
    iter ->     iter!.actdim = iter!.dim
            and IsDoneIterator( iter!.actdimiter ) );

InstallMethod( NextIterator, true,
    [ IsIterator and IsAllSubspacesFullRowSpaceIteratorRep ], 0,
    function( iter )
    if IsDoneIterator( iter!.actdimiter ) then
      iter!.actdim:= iter!.actdim + 1;
      iter!.actdimiter:= Iterator(Subspaces( iter!.V, iter!.actdim));
    fi;
    return NextIterator( iter!.actdimiter );
    end );


#############################################################################
##
#M  SubspacesDim( <V>, <dim> )
#M  SubspacesAll( <V> )
##
InstallMethod( SubspacesDim,
    "method for (Gaussian) full row space",
    true,
    [ IsGaussianSpace and IsFullRowModule and IsGaussianRowSpaceRep,
#T really needed ?
      IsInt ], 0,
    function( V, dim )
    return Objectify( NewKind( CollectionsFamily( FamilyObj( V ) ),
                               IsDomain and IsSubspacesFullRowSpaceRep ),
                      rec(
                           structure  := V,
                           dimension  := dim
                          )
                     );
    end );

InstallMethod( SubspacesAll, true,
    [ IsGaussianSpace and IsFullRowModule and IsGaussianRowSpaceRep ], 0,
#T really needed ?
    V -> Objectify( NewKind( CollectionsFamily( FamilyObj( V ) ),
                             IsDomain and IsSubspacesFullRowSpaceRep ),
                    rec(
                         structure  := V,
                         dimension  := "all"
                        )
                   ) );


#############################################################################
##
##  7. Methods for mutable bases of Gaussian row spaces
##

#############################################################################
##
#R  IsMutableBasisOfGaussianRowSpaceRep( <B> )
##
##  The default mutable bases of Gaussian row spaces are semi-echelonized.
##  Note that we switch to a mutable basis of representation
##  'IsMutableBasisByImmutableBasisRep' if the mutable basis is closed by a
##  vector that makes the space non-Gaussian.
##
IsMutableBasisOfGaussianRowSpaceRep := NewRepresentation(
    "IsMutableBasisOfGaussianRowSpaceRep",
    IsComponentObjectRep and IsMutable,
    [ "heads", "basisVectors", "leftActingDomain", "zero" ] );


#############################################################################
##
#M  MutableBasisByGenerators( <R>, <vectors> )  . . . . . for matrix over <R>
#M  MutableBasisByGenerators( <R>, <vectors>, <zero> )  . for matrix over <R>
##
InstallMethod( MutableBasisByGenerators,
    "method to construct mutable bases of row spaces",
    IsElmsColls,
    [ IsRing, IsMatrix ], 0,
    function( R, vectors )
    local B, newvectors;

    if ForAny( vectors, v -> not IsSubset( R, v ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that uses a nice mutable basis.
      B:= MutableBasisViaNiceMutableBasisMethod2( R, vectors );

    else

      # Note that 'vectors' is not empty.
      newvectors:= SemiEchelonMat( vectors );

      B:= Objectify( NewKind( FamilyObj( vectors ),
                                  IsMutableBasis
                              and IsMutableBasisOfGaussianRowSpaceRep ),
                     rec(
                          basisVectors:= ShallowCopy( newvectors.vectors ),
                          heads:= ShallowCopy( newvectors.heads ),
                          zero:= Zero( newvectors.vectors[1] ),
                          leftActingDomain := R
                          ) );

    fi;

    return B;
    end );

IsIdenticalObjXObj := function( F1, F2, F3 )
    return IsIdentical( F1, F3 );
end;

InstallOtherMethod( MutableBasisByGenerators,
    "method to construct mutable bases of row spaces",
    IsIdenticalObjXObj,
    [ IsRing, IsList, IsRowVector ], 0,
    function( R, vectors, zero )
    local B;

    if ForAny( vectors, v -> not IsSubset( R, v ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that uses a nice mutable basis.
      B:= MutableBasisViaNiceMutableBasisMethod3( R, vectors, zero );

    else

      B:= Objectify( NewKind( CollectionsFamily( FamilyObj( zero ) ),
                                  IsMutableBasis
                              and IsMutableBasisOfGaussianRowSpaceRep ),
                     rec(
                          zero:= zero,
                          leftActingDomain := R
                          ) );

      if IsEmpty( vectors ) then

        B!.basisVectors:= [];
        B!.heads:= List( zero, x -> 0 );

      else

        vectors:= SemiEchelonMat( vectors );
        B!.basisVectors:= ShallowCopy( vectors.vectors );
        B!.heads:= ShallowCopy( vectors.heads );

      fi;

    fi;

    return B;
    end );


#############################################################################
##
#M  PrintObj( <MB> )  . . . . . . print mutable basis of a Gaussian row space
##
InstallMethod( PrintObj,
    "method for a mutable basis of a Gaussian row space",
    true,
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep ], 0,
    function( MB )
    Print( "<mutable basis over ", MB!.leftActingDomain, ", ",
           Length( MB!.basisVectors ), " vectors>" );
    end );


#############################################################################
##
#M  BasisVectors( <MB> )  . . . . . for mutable basis of a Gaussian row space
##
InstallOtherMethod( BasisVectors,
    "method for a mutable basis of a Gaussian row space",
    true,
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep ], 0,
    MB -> Immutable( MB!.basisVectors ) );


#############################################################################
##
#M  CloseMutableBasis( <MB>, <v> )  . .  for mut. basis of Gaussian row space
##
InstallMethod( CloseMutableBasis,
    "method for a mut. basis of a Gaussian row space, and a row vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep,
      IsRowVector ], 0,
    function( MB, v )
    local V,              # corresponding free left module
          ncols,          # dimension of the row vectors
          zero,           # zero scalar
          heads,          # heads info of the basis
          basisvectors,   # list of basis vectors of 'MB'
          j;              # loop over 'heads'

    # Check whether the mutable basis belongs to a Gaussian row space
    # after the closure.
    if not IsSubset( MB!.leftActingDomain, v ) then

      # Change the representation to a mutable basis by immutable basis.
#T better mechanism!
      basisvectors:= Concatenation( MB!.basisVectors, [ v ] );
      V:= LeftModuleByGenerators( MB!.leftActingDomain, basisvectors );
      UseBasis( V, basisvectors );

      SetFilterObj( MB, IsMutableBasisByImmutableBasisRep );
      ResetFilterObj( MB, IsMutableBasisOfGaussianRowSpaceRep );

      MB!.immutableBasis:= BasisOfDomain( V );

    else

      # Reduce 'v' with the known basis vectors.
      v:= ShallowCopy( v );
      ncols:= Length( v );
      heads:= MB!.heads;

      if ncols <> Length( MB!.heads ) then
        Error( "<v> must have same length as 'MB!.heads'" );
      fi;

      zero:= Zero( v[1] );
      basisvectors:= MB!.basisVectors;

      for j in [ 1 .. ncols ] do
        if heads[j] <> 0 then
          AddRowVector( v, basisvectors[ heads[j] ], - v[j] );
        fi;
      od;

      # If necessary add the sifted vector, and update the basis info.
      j := PositionNot( v, zero );
      if j <= ncols then
        MultRowVector( v, Inverse( v[j] ) );
        Add( basisvectors, v );
        heads[j]:= Length( basisvectors );
      fi;

    fi;
    end );


#############################################################################
##
#M  IsContainedInSpan( <MB>, <v> )  . .  for mut. basis of Gaussian row space
##
InstallMethod( IsContainedInSpan,
    "method for a mut. basis of a Gaussian row space, and a row vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep,
      IsRowVector ], 0,
    function( MB, v )
    local V,              # corresponding free left module
          ncols,          # dimension of the row vectors
          zero,           # zero scalar
          heads,          # heads info of the basis
          basisvectors,   # list of basis vectors of 'MB'
          j;              # loop over 'heads'

    if not IsSubset( MB!.leftActingDomain, v ) then

      return false;

    else

      # Reduce 'v' with the known basis vectors.
      v:= ShallowCopy( v );
      ncols:= Length( v );
      heads:= MB!.heads;

      if ncols <> Length( MB!.heads ) then
        return false;
      fi;

      zero:= Zero( v[1] );
      basisvectors:= MB!.basisVectors;

      for j in [ 1 .. ncols ] do
        if heads[j] <> 0 then
          AddRowVector( v, basisvectors[ heads[j] ], - v[j] );
        fi;
      od;

      # Check whether the sifted vector is zero.
      return IsZero( v );

    fi;
    end );


#############################################################################
##
#M  ImmutableBasis( <MB> )  . . . . for mutable basis of a Gaussian row space
##
InstallMethod( ImmutableBasis,
    "method for a mutable basis of a Gaussian row space",
    true,
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep ], 0,
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


#############################################################################
##
IsAffineSpace := NewRepresentation( "IsAffineSpace",
    IsDomain and IsAttributeStoringRep, [ "space" ] );

IsAffineSpaceEnumerator := NewRepresentation( "IsAffineSpaceEnumerator",
    IsDomainEnumerator and IsAttributeStoringRep, [ "affineSpace" ] );

IsProjectiveSpace := NewRepresentation( "IsProjectiveSpace",
    IsDomain and IsAttributeStoringRep, [ "space" ] );

IsProjectiveSpaceEnumerator := NewRepresentation
    ( "IsProjectiveSpaceEnumerator",
      IsDomainEnumerator and IsAttributeStoringRep, [ "projectiveSpace" ] );

#############################################################################
##
#F  AffineSpace( <space> )  . . . . .  constructor function for affine spaces
##
AffineSpace := function( space )
    return Objectify( NewKind( FamilyObj( space ), IsAffineSpace ),
                   rec( space := space ) );
end;

InstallMethod( PrintObj, true, [ IsAffineSpace ], 0,
    function( obj )
    Print( "AffineSpace( ", obj!.space, " )" );
end );

InstallMethod( Size, true, [ IsAffineSpace ], 0, obj -> Size( obj!.space ) );

InstallMethod( Enumerator,"affine", true, [ IsAffineSpace ], 0,
    function( aspace )
    local   enum;
    
    enum := Objectify( NewKind( FamilyObj( aspace ),
                    IsAffineSpaceEnumerator ), rec
            ( spaceEnumerator := Enumerator( aspace!.space ) ) );
    SetUnderlyingCollection( enum, aspace );
    return enum;
end );

InstallMethod( \[\], true, [ IsAffineSpaceEnumerator, IsInt ], 0,
    function( aspace, num )
    return Concatenation( aspace!.spaceEnumerator[ num ],
      [ One( LeftActingDomain( UnderlyingCollection( aspace )!.space ) ) ] );
end );
        
InstallMethod( Position, true,
        [ IsAffineSpaceEnumerator, IsObject, IsZeroCyc ], 0,
    function( aspace, elm, zero )
    return Position( aspace!.spaceEnumerator,
                   elm{ [ 1 .. Length( elm ) - 1 ] } );
end );

#############################################################################
##
#F  ProjectiveSpace( <space> )  .  constructor function for projective spaces
##
ProjectiveSpace := function( space )
    return Objectify( NewKind( FamilyObj( space ), IsProjectiveSpace ),
                   rec( space := space ) );
end;
    
InstallMethod( PrintObj, true, [ IsProjectiveSpace ], 0,
    function( obj )
    Print( "ProjectiveSpace( ", obj!.space, " )" );
end );

InstallMethod( Size, true, [ IsProjectiveSpace ], 0,
    function( obj )
    local  q,  d;
    
    q := Size( LeftActingDomain( obj!.space ) );
    d := Dimension( obj!.space );
    return ( q ^ d - 1 ) / ( q - 1 );
end );

InstallMethod( Enumerator,"projective", true, [ IsProjectiveSpace ], 0,
    function( pspace )
    local   enum;
    
    enum := Objectify( NewKind( FamilyObj( pspace ),
        IsProjectiveSpaceEnumerator ), rec( enumeratorField :=
                    Enumerator( LeftActingDomain( pspace!.space ) ) ) );
    SetUnderlyingCollection( enum, pspace );
    return enum;
end );

InstallMethod( \[\], true, [ IsProjectiveSpaceEnumerator, IsInt ], 0,
    function( pspace, num )
    local   F,  sp,  f,  v,  zero,  q,  n,  i,  l,  L;
    
    f := pspace!.enumeratorField;
    pspace := UnderlyingCollection( pspace );
    sp := pspace!.space;
    F := LeftActingDomain( sp );
    q := Size( F );
    n := Dimension( sp );
    v := Zero( F ) * [ 1 .. n ];
    num := num - 1;
    
    # Find the number of entries after the leading 1.
    l := 0;
    L := 1;
    while num >= L  do
        l := l + 1;
        L := L * q + 1;
    od;
    num := num - ( L - 1 ) / q;
    v[ n - l ] := One( F );
    for i  in [ n - l + 1 .. n ]  do
        v[ i ] := f[ num mod q + 1 ];
        num := QuoInt( num, q );
    od;
    return v;
end );
        
InstallMethod( PositionCanonical, true,
        [ IsProjectiveSpaceEnumerator, IsObject ], 0,
    function( pspace, elm )
    local   F,  sp,  f,  zero,  q,  n,  l,  num,  val,  i;
    
    f := pspace!.enumeratorField;
    pspace := UnderlyingCollection( pspace );
    sp := pspace!.space;
    F := LeftActingDomain( sp );
    zero := Zero( F );
    q := Size( F );
    n := Dimension( sp );
    l := 1;
    
    # Find the first entry different from zero.
    while elm[ l ] = zero  do
        l := l + 1;
    od;
    elm := elm / elm[ l ];
    
    num := 1;
    for i  in [ 0 .. n - l - 1 ]  do
        num := num + q ^ i;
    od;
    val := 1;
    for i  in [ l + 1 .. n ]  do
        num := num + val * ( Position( f, elm[ i ] ) - 1 );
        val := val * q;
    od;
    return num;
end );

#T mutable bases for Gaussian row and matrix spaces should allow 'SiftedVector'!
#T mutable bases for Gaussian row and matrix spaces are always semi-ech.
#T (note that we construct a mutable basis only if we want to do successive
#T closures)

#############################################################################
##
#E  vspcrow.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



