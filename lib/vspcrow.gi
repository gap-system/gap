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
##  This file contains methods for row spaces.
##  A row space is a vector space whose elements are row vectors.
##
##  The coefficients field need *not* contain all entries of the row vectors.
##  If it does then the space is a *Gaussian row space*,
##  with better methods to deal with bases.
##  If it does not then the bases use the mechanism of associated bases.
##
##  (See the file `vspcmat.gi' for methods for matrix spaces.)
##
##  For all row spaces, the value of the attribute `DimensionOfVectors' is
##  the length of the row vectors in the space.
##
##  1. Domain constructors for row spaces
##  2. Methods for bases of non-Gaussian row spaces
##  3. Methods for semi-echelonized bases of Gaussian row spaces
##  4. Methods for row spaces
##  5. Methods for full row spaces
##  6. Methods for collections of subspaces of full row spaces
##  7. Methods for mutable bases of Gaussian row spaces
##  8. Methods installed by somebody else without documenting this ...
##


#############################################################################
##
##  1. Domain constructors for row spaces
##

#############################################################################
##
#M  LeftModuleByGenerators( <F>, <mat>[, <zerorow>] )
##
##  We keep these special methods since row spaces are the most usual ones,
##  and the explicit construction shall not be slowed down by the call of
##  `CheckForHandlingByNiceBasis'.
##  However, the method installed for the filter `IsNonGaussianRowSpace'
##  would be sufficient to force `IsGaussianRowSpace'.
##
##  Additionally, we guarantee that vector spaces really know that their
##  left acting domain is a division ring.
##
InstallMethod( LeftModuleByGenerators,
    "for division ring and matrix over it",
    IsElmsColls,
    [ IsDivisionRing, IsMatrix ],
    function( F, mat )
    local V,typ;

    typ:=IsAttributeStoringRep and HasIsEmpty and IsFiniteDimensional;
    if ForAll( mat, row -> IsSubset( F, row ) ) then
      typ:=typ and IsGaussianRowSpace;
    else
      typ:=typ and IsVectorSpace and IsRowModule and IsNonGaussianRowSpace;
    fi;

    if Length(mat)>0 and ForAny(mat,x->not IsZero(x)) then
      typ:=typ and IsNonTrivial;
    else
      typ:=typ and IsTrivial;
    fi;

    if HasIsFinite(F) then
      if IsFinite(F) then
        typ:=typ and IsFinite;
      else
        typ:=typ and HasIsFinite; # i.e. not finite
      fi;
    fi;

    V:= Objectify( NewType( FamilyObj( mat ), typ), rec() );

    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( mat ) );
    SetDimensionOfVectors( V, Length( mat[1] ) );

    return V;
    end );

InstallMethod( LeftModuleByGenerators,
    "for division ring, empty list, and row vector",
    [ IsDivisionRing, IsList and IsEmpty, IsRowVector ],
    function( F, empty, zero )
    local V,typ;

    # Check whether this method is the right one.
    if not IsIdenticalObj( FamilyObj( F ), FamilyObj( zero ) ) then
      TryNextMethod();
    fi;
#T explicit 2nd argument above!

    typ:=IsAttributeStoringRep and IsGaussianRowSpace and IsTrivial;

    V:= Objectify( NewType( CollectionsFamily( FamilyObj( F ) ),typ),
                   rec() );
    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, empty );
    SetZero( V, zero );
    SetDimension( V, 0 );
    SetDimensionOfVectors( V, Length( zero ) );

    return V;
    end );

InstallMethod( LeftModuleByGenerators,
    "for division ring, matrix over it, and row vector",
    [ IsDivisionRing, IsMatrix, IsRowVector ],
    function( F, mat, zero )
    local V,typ;

    # Check whether this method is the right one.
    if not IsElmsColls( FamilyObj( F ), FamilyObj( mat ) ) then
      TryNextMethod();
    fi;
#T explicit 2nd argument above!

    typ:=IsAttributeStoringRep and HasIsEmpty and IsFiniteDimensional;
    if ForAll( mat, row -> IsSubset( F, row ) ) then
      typ:=typ and IsGaussianRowSpace;
    else
      typ:=typ and IsVectorSpace and IsRowModule and IsNonGaussianRowSpace;
    fi;

    if Length(mat)>0 and ForAny(mat,x->not IsZero(x)) then
      typ:=typ and IsNonTrivial;
    else
      typ:=typ and IsTrivial;
    fi;

    if HasIsFinite(F) then
      if IsFinite(F) then
        typ:=typ and IsFinite;
      else
        typ:=typ and HasIsFinite; # i.e. not finite
      fi;
    fi;

    V:= Objectify( NewType( FamilyObj( mat ), typ), rec() );

    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( mat ) );
    SetZero( V, zero );
    SetDimensionOfVectors( V, Length( mat[1] ) );

    return V;
    end );

InstallOtherMethod( LeftModuleByGenerators,
    "for division ring and list of vector objects",
    IsElmsColls,
    [ IsDivisionRing, IsList ],
    # ensure it ranks above the generic method
    function( F, mat )
    local V, typ, K, row;

    # filter for vector objects, not compressed FF vectors
    if not ForAll(mat,x->IsVectorObj(x) and not IsDataObjectRep(x)) then
      TryNextMethod();
    fi;
    typ:=IsAttributeStoringRep and HasIsEmpty and IsFiniteDimensional;
    if ForAll( mat, row -> IsSubset( F, BaseDomain(row) ) ) then
      # Replace 'mat' by vector objects with base domain 'F'.
      mat:= List( mat, v -> ChangedBaseDomain( v, F ) );
      typ:=typ and IsGaussianRowSpace;
    else
      # Replace 'mat' by vector objects with base domain containing 'F'.
      K:= F;
      for row in mat do
        K:= ClosureDivisionRing( K, BaseDomain( row ) );
      od;
      mat:= List( mat, v -> ChangedBaseDomain( v, K ) );
      typ:=typ and IsVectorSpace and IsRowModule and IsNonGaussianRowSpace;
#FIXME: Setting the filter 'IsNonGaussianRowSpace' enables the handling
#       via nice bases, but there is currently no support for that
#       in the case of vector spaces of 'IsVectorObj' objects.
#       In particular, the 'else' branch does not work.
#       See https://github.com/gap-system/gap/issues/5347
#       and https://github.com/gap-system/gap/discussions/5346
#       for more information.
    fi;

    if Length(mat)>0 and ForAny(mat,x->not IsZero(x)) then
      typ:=typ and IsNonTrivial;
    else
      typ:=typ and IsTrivial;
    fi;

    if HasIsFinite(F) then
      if IsFinite(F) then
        typ:=typ and IsFinite;
      else
        typ:=typ and HasIsFinite; # i.e. not finite
      fi;
    fi;

    V:= Objectify( NewType( FamilyObj( mat ), typ), rec() );

    SetLeftActingDomain( V, F );
    SetGeneratorsOfLeftModule( V, AsList( mat ) );
    SetDimensionOfVectors( V, Length( mat[1] ) );

    return V;
    end );


#############################################################################
##
##  2. Methods for bases of non-Gaussian row spaces
##

#############################################################################
##
#M  NiceFreeLeftModuleInfo( <V> )
#M  NiceVector( <V>, <v> )
#M  UglyVector( <V>, <r> )
##
##  The purpose of the check is twofold.
##
##  First, we check whether <V> is a non-Gaussian row space.
##  If yes then it gets the filter `IsNonGaussianRowSpace' that indicates
##  that it is handled via the mechanism of nice bases.
##
##  Second, we set the filter `IsRowModule' if <V> consists of row vectors.
##  If additionally <V> turns out to be Gaussian then we set also the filter
##  `IsGaussianSpace'.
##
InstallHandlingByNiceBasis( "IsNonGaussianRowSpace", rec(
    detect:= function( R, mat, V, zero )
      if IsEmpty( mat ) then
        if     IsRowVector( zero )
           and IsIdenticalObj( FamilyObj( R ), FamilyObj( zero ) ) then
          SetFilterObj( V, IsRowModule );
          if IsDivisionRing( R ) then
            SetFilterObj( V, IsGaussianRowSpace );
            return fail;
          fi;
        fi;
        return false;
      fi;
      if    not IsMatrix( mat )
         or not IsElmsColls( FamilyObj( R ), FamilyObj( mat ) ) then
        return false;
      fi;
      SetFilterObj( V, IsRowModule );
      if ForAll( mat, row -> IsSubset( R, row ) ) then
        if IsDivisionRing( R ) then
          SetFilterObj( V, IsGaussianRowSpace );
        fi;
        return fail;
      fi;
      return true;
      end,

    NiceFreeLeftModuleInfo := function( V )
      local vgens,  # vector space generators of `V'
            F,      # left acting domain of `V'
            K;      # field generated by entries in elements of `V'

      vgens:= GeneratorsOfLeftModule( V );
      F:= LeftActingDomain( V );
      if not IsEmpty( vgens ) then
        K:= ClosureField( F, Concatenation( vgens ) );
#T cheaper way?
        return Basis( AsField( Intersection( K, F ), K ) );
      fi;
      end,

    NiceVector := function( V, v )
      local list, entry, new;
      list:= [];
      for entry in v do
        new:= Coefficients( NiceFreeLeftModuleInfo( V ), entry );
        if new = fail then
          return fail;
        fi;
        Append( list, new );
      od;
      return list;
      end,

    UglyVector := function( V, v )
      local FB,  # basis vectors of the basis of the field extension
            n,   # degree of the field extension
            w,   # associated vector, result
            i;   # loop variable

      FB:= BasisVectors( NiceFreeLeftModuleInfo( V ) );
      n:= Length( FB );
      w:= [];
      for i in [ 1 .. Length( v ) / n ] do
        w[i]:= v{ [ n*(i-1)+1 .. n*i ] } * FB;
      od;
      return w;
      end ) );


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
##  (So there is no need for `IsBasisGaussianRowSpace').
##
##  If basis vectors are known and if the space is nontrivial
##  then the component `heads' is bound.
##
DeclareRepresentation( "IsSemiEchelonBasisOfGaussianRowSpaceRep",
    IsAttributeStoringRep,
    [ "heads" ] );

InstallTrueMethod( IsSmallList,
    IsList and IsSemiEchelonBasisOfGaussianRowSpaceRep );


#############################################################################
##
#M  LinearCombination( <B>, <coeff> )
##
InstallMethod( LinearCombination, IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianRowSpaceRep, IsRowVector ],
        function( B, coeff )
    if Length(coeff) = 0 then
        TryNextMethod();
    fi;
    return coeff * BasisVectors( B );
    end );


#############################################################################
##
#M  Coefficients( <B>, <v> )  .  method for semi-ech. basis of Gaussian space
##

BindGlobal( "COEFFS_SEMI_ECH_BASIS", function( B, v )
    local vectors,   # basis vectors of `B'
          heads,     # heads info of `B'
          len,       # length of `v'
          F,         # allowed coefficients
          coeff,     # coefficients list, result
          i,         # loop over `v'
          pos;       # heads position

    # Check whether the vector has the right length.
    # (The heads info is not stored before the basis vectors are known.)
    vectors:= BasisVectors( B );
    if IsEmpty( vectors ) then
      return [];
    fi;
    heads:= B!.heads;
    len:= Length( v );
    if len <> Length( heads ) then
      return fail;
    fi;
    F:= LeftActingDomain( UnderlyingLeftModule( B ) );

    # Preset the coefficients list with zeroes.
    coeff:= ListWithIdenticalEntries( Length( vectors ), Zero( v[1] ) );

    # Compute the coefficients of the base vectors.
    v:= ShallowCopy( v );
    i:= PositionNonZero( v );
    while i <= len do
      pos:= heads[i];
      if pos = 0 or not v[i] in F then
        return fail;
      else
        coeff[ pos ]:= v[i];
        AddRowVector( v, vectors[ pos ], - v[i] );
      fi;
      i:= PositionNonZero( v );
    od;

    # Return the coefficients.
    return coeff;
end );

InstallMethod( Coefficients,
    "for semi-ech. basis of a Gaussian row space, and a row vector",
    IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianRowSpaceRep, IsRowVector ],
    COEFFS_SEMI_ECH_BASIS);

InstallMethod( Coefficients,
    "for semi-ech. basis of a Gaussian row space, and vector object",
    IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianRowSpaceRep, IsVectorObj ],
    COEFFS_SEMI_ECH_BASIS);

#############################################################################
##
#F  SiftedVectorForGaussianRowSpace( <F>, <vectors>, <heads>, <v> )
##
##  is the remainder of the row vector <v> after sifting through the
##  (mutable) <F>-basis with besis vectors <vectors> and heads information
##  <heads>.
##
BindGlobal( "SiftedVectorForGaussianRowSpace",
    function( F, vectors, heads, v )
    local zero,    # zero of the field
          i;       # loop over basis vectors

    if Length( heads ) <> Length( v ) or not IsSubset( F, v ) then
      return fail;
    fi;

    zero:= Zero( v[1] );

    # Compute the coefficients of the `B' vectors.
    v:= ShallowCopy( v );
    for i in [ 1 .. Length( heads ) ] do
      if heads[i] <> 0 and v[i] <> zero then
        AddRowVector( v, vectors[ heads[i] ], - v[i] );
      fi;
    od;

    # Return the remainder.
    return v;
end );


#############################################################################
##
#M  SiftedVector( <B>, <v> )
##
##  If `<B>!.heads[<i>]' is nonzero this means that the <i>-th column is
##  leading column of the row `<B>!.heads[<i>]'.
##
InstallMethod( SiftedVector,
    "for semi-ech. basis of Gaussian row space, and row vector",
    IsCollsElms,
    [ IsBasis and IsSemiEchelonBasisOfGaussianRowSpaceRep, IsRowVector ],
    function( B, v )
    return SiftedVectorForGaussianRowSpace(
               LeftActingDomain( UnderlyingLeftModule( B ) ),
               BasisVectors( B ), B!.heads, v );
    end );


#############################################################################
##
#F  HeadsInfoOfSemiEchelonizedMat( <mat>, <dim> )
##
##  is the `heads' information of the matrix <mat> with <dim> columns
##  if <mat> can be viewed as a semi-echelonized basis
##  of a Gaussian row space, and `fail' otherwise.
#T into `matrix.gi' ?
##
BindGlobal( "HeadsInfoOfSemiEchelonizedMat", function( mat, dim )
    local zero,     # zero of the field
          one,      # one of the field
          nrows,    # number of rows
          heads,    # list of pivot rows
          i,        # loop over rows
          j,        # pivot column
          k;        # loop over lower rows

    nrows:= Length( mat );
    heads:= ListWithIdenticalEntries( dim, 0 );

    if 0 < nrows then

      zero := Zero( mat[1][1] );
      one  := One( zero );

      # Loop over the columns.
      for i in [ 1 .. nrows ] do

        j:= PositionNonZero( mat[i] );
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
end );


#############################################################################
##
#M  IsSemiEchelonized( <B> )
##
##  A basis of a Gaussian row space over a division ring with identity
##  element $e$ is in semi-echelon form if the leading entry of every row is
##  equal to $e$, and all entries exactly below that position are zero.
##
##  (This form is obtained on application of `SemiEchelonMat' to a matrix.)
##
InstallMethod( IsSemiEchelonized,
    "for basis of a Gaussian row space",
    [ IsBasis ],
    function( B )
    local V;
    V:= UnderlyingLeftModule( B );
    if not ( IsRowSpace( V ) and IsGaussianRowSpace( V ) ) then
#T The basis does not know whether it is a basis of a row space at all.
      TryNextMethod();
    else
      return HeadsInfoOfSemiEchelonizedMat( BasisVectors( B ),
                                            DimensionOfVectors( V ) ) <> fail;
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
InstallOtherMethod( \*, IsIdenticalObj, [ IsRowSpace, IsMatrix ],
    function( V, mat )
    if IsTrivial( V ) then
      return V;
    fi;
    return LeftModuleByGenerators( LeftActingDomain( V ),
               List( GeneratorsOfLeftModule( V ), v -> v * mat ) );
    end );

InstallOtherMethod( \^, IsIdenticalObj, [ IsRowSpace, IsMatrix ],
    function( V, mat )
    if IsTrivial( V ) then
      return V;
    fi;
    return LeftModuleByGenerators( LeftActingDomain( V ),
               List( GeneratorsOfLeftModule( V ), v -> v * mat ) );
    end );


#############################################################################
##
#M  \in( <v>, <V> ) . . . . . . . . . . for row vector and Gaussian row space
##
InstallMethod( \in,
    "for row vector and Gaussian row space",
    IsElmsColls,
    [ IsRowVector, IsGaussianRowSpace ],
    function( v, V )
    if IsEmpty( v ) then
      return DimensionOfVectors( V ) = 0;
    elif DimensionOfVectors( V ) <> Length( v ) then
      return false;
    else
      v:= SiftedVector( Basis( V ), v );
#T any basis supports sifting?
      return v <> fail and DimensionOfVectors( V ) < PositionNonZero( v );
    fi;
    end );


#############################################################################
##
#M  Basis( <V> )  . . . . . . . . . . . . . . . . . .  for Gaussian row space
#M  Basis( <V>, <vectors> ) . . . . . . . . . . . . .  for Gaussian row space
#M  BasisNC( <V>, <vectors> ) . . . . . . . . . . . .  for Gaussian row space
##
##  Distinguish the cases whether the space <V> is a *Gaussian* row vector
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
    "for Gaussian row space (construct a semi-echelonized basis)",
    [ IsGaussianRowSpace ],
    SemiEchelonBasis );

InstallMethod( Basis,
    "for Gaussian row space and matrix (try semi-echelonized)",
    IsIdenticalObj,
    [ IsGaussianRowSpace, IsMatrix ],
    function( V, gens )
    local heads, B, v;

    # Test whether the vectors form a semi-echelonized basis.
    # (If not then give up.)
    heads:= HeadsInfoOfSemiEchelonizedMat( gens, DimensionOfVectors( V ) );
    if heads = fail then
      TryNextMethod();
    fi;

    # Construct the basis.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );
    if IsEmpty( gens ) then
      SetIsEmpty( B, true );
    else
      SetIsRectangularTable( B, true );
    fi;

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
    "for Gaussian row space and matrix (try semi-echelonized)",
    IsIdenticalObj,
    [ IsGaussianRowSpace, IsMatrix ],
    function( V, gens )
    local heads, B;

    # Test whether the vectors form a semi-echelonized basis.
    # (If not then give up.)
    heads:= HeadsInfoOfSemiEchelonizedMat( gens, DimensionOfVectors( V ) );
    if heads = fail then
      TryNextMethod();
    fi;

    # Construct the basis.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );
    if IsEmpty( gens ) then
      SetIsEmpty( B, true );
    else
      SetIsRectangularTable( B, true );
    fi;

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
    IsGaussianRowSpace and HasCanonicalBasis and IsAttributeStoringRep, 20,
    CanonicalBasis );

InstallMethod( SemiEchelonBasis,
    "for Gaussian row space",
    [ IsGaussianRowSpace ],
    function( V )
    local B, gens;

    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
                   rec() );

    gens:= GeneratorsOfLeftModule( V );
    if ForAll( gens, IsZero ) then
      SetIsEmpty( B, true );
    else
      SetIsRectangularTable( B, true );
    fi;

    SetUnderlyingLeftModule( B, V );
    return B;
    end );

InstallOtherMethod( SemiEchelonBasis,
    "for Gaussian row space and list of vector objects",
    IsIdenticalObj,
    [ IsGaussianRowSpace, IsList ],
    function( V, gens )
    local heads,   # heads info for the basis
          B,       # the basis, result
          F,       # base domain
          gensi,   # immutable copy
          flag,
          v;       # loop over vector space generators

    flag:=false;
    if ForAll(gens,x->IsVectorObj(x) and not IsDataObjectRep(x)) then
      # What is meant here:
      # 'gens' is a list of vector objects that are not necessarily lists.
      flag:=true;
    elif not IsMatrix(gens) then
      TryNextMethod();
    fi;

    # Check that the vectors form a semi-echelonized basis.
    heads:= HeadsInfoOfSemiEchelonizedMat( gens, DimensionOfVectors( V ) );
    if heads = fail then
      return fail;
    fi;

    # Construct the basis.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
                   rec() );
    if IsEmpty( gens ) then
      SetIsEmpty( B, true );
    else
      SetIsRectangularTable( B, true );
    fi;
    SetUnderlyingLeftModule( B, V );
    F:= LeftActingDomain( V );
    if flag then
      # In the case of proper vector objects,
      # we want to keep their representation
      # (since the user had good reason to give us these objects)
      # but perhaps the base domain must be adjusted.
      gensi:= Immutable( List( gens, v -> ChangedBaseDomain( v, F ) ) );
    else
      # We expect 'gens' to be a list of lists.
      gensi:= ImmutableMatrix( F, gens );
    fi;
    SetBasisVectors( B, gensi );

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
    "for Gaussian row space and matrix",
    IsIdenticalObj,
    [ IsGaussianRowSpace, IsMatrix ],
    function( V, gens )
    local B;  # the basis, result

    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
                   rec() );
    if IsEmpty( gens ) then
      SetIsEmpty( B, true );
    else
      SetIsRectangularTable( B, true );
    fi;
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );

    # Provide the `heads' information.
    B!.heads:= HeadsInfoOfSemiEchelonizedMat( gens, DimensionOfVectors( V ) );

    # Return the basis.
    return B;
    end );

InstallOtherMethod( SemiEchelonBasisNC,
    "for Gaussian row space and list of vector objects",
    IsIdenticalObj,
    [ IsGaussianRowSpace, IsList ],
    function( V, gens )
    local B;  # the basis, result

    # filter for vector objects, not compressed FF vectors
    if not ForAll(gens,x->IsVectorObj(x) and not IsDataObjectRep(x)) then
      # We expect that the method for `IsMatrix` is applicable.
      TryNextMethod();
    fi;

    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep ),
                   rec() );
    if IsEmpty( gens ) then
      SetIsEmpty( B, true );
    else
      SetIsRectangularTable( B, true );
    fi;
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, gens );

    # Provide the `heads' information.
    B!.heads:= HeadsInfoOfSemiEchelonizedMat( gens, DimensionOfVectors( V ) );

    # Return the basis.
    return B;
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . . . . for semi-ech. basis of Gaussian row space
##
InstallMethod( BasisVectors,
    "for semi-ech. basis of a Gaussian row space",
    [ IsBasis and IsSemiEchelonBasisOfGaussianRowSpaceRep ],
    function( B )
    local V, gens, vectors;

    # Check that the basis is not a canonical basis;
    # in this case we need another method.
    if HasIsCanonicalBasis( B ) and IsCanonicalBasis( B ) then
      TryNextMethod();
    fi;

    V:= UnderlyingLeftModule( B );

    # Note that we must not ask for the dimension here \ldots
    gens:= GeneratorsOfLeftModule( V );

    if IsEmpty( gens ) then

      B!.heads:= 0 * [ 1 .. DimensionOfVectors( V ) ];
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
#M  Zero( <V> ) . . . . . . . . . . . . . . . . . . . . . . . for a row space
##
InstallOtherMethod( Zero,
    "for a row space",
    [ IsRowSpace ],
function(V)
local d,z;
  d:=LeftActingDomain(V);
  z:=Zero( d ) * [ 1 .. DimensionOfVectors( V ) ];
  if IsField(d) and IsFinite(d) and Size(d)<=256 then
    z := ImmutableVector( d, z );
  fi;
  return z;
end);


#############################################################################
##
#M  IsZero( <v> )
##
InstallMethod( IsZero,
    "for a row vector",
    [ IsRowVector ],
    v -> IsEmpty( v ) or Length( v ) < PositionNonZero( v ) );


#############################################################################
##
#M  AsLeftModule( <F>, <rows> ) . . . . . . . .  for division ring and matrix
##
InstallMethod( AsLeftModule,
    "for division ring and matrix",
    IsElmsColls,
    [ IsDivisionRing, IsMatrix ],
    function( F, vectors )
    local m;

    if not IsPrimePowerInt( Length( vectors ) ) then
      return fail;
    elif ForAll( vectors, v -> IsSubset( F, v ) ) then
#T other check!

      # All vector entries lie in `F'.
      # (We work destructively.)
      m:= SemiEchelonMatDestructive( List( vectors, ShallowCopy ) ).vectors;
      if IsEmpty( m ) then
        m:= LeftModuleByGenerators( F, [], vectors[1] );
      else
        m:= FreeLeftModule( F, m, "basis" );
      fi;

    else

      # We have at most a non-Gaussian row space.
      m:= LeftModuleByGenerators( F, vectors );

    fi;

    # Check that the space equals the list of vectors.
    if Size( m ) <> Length( vectors ) then
      return fail;
    fi;

    # Return the space.
    return m;
    end );


#############################################################################
##
#M  \+( <U1>, <U2> )  . . . . . . . . . . . .  sum of two Gaussian row spaces
##
InstallOtherMethod( \+,
    "for two Gaussian row spaces",
    IsIdenticalObj,
    [ IsGaussianRowSpace, IsGaussianRowSpace ],
    function( V, W )
    local S,          # sum of <V> and <W>, result
          mat;        # basis vectors of the sum

    if   DimensionOfVectors( V ) <> DimensionOfVectors( W ) then
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
    "for two Gaussian row spaces",
    IsIdenticalObj,
    [ IsGaussianRowSpace, IsGaussianRowSpace ],
    function( V, W )
    local S,          # intersection of `V' and `W', result
          mat;        # basis vectors of the intersection

    if   DimensionOfVectors( V ) <> DimensionOfVectors( W ) then
      S:= [];
    elif Dimension( V ) = 0 then
      S:= V;
    elif Dimension( W ) = 0 then
      S:= W;
    elif LeftActingDomain( V ) <> LeftActingDomain( W ) then
      S:= Intersection2( LeftActingDomain( V ), LeftActingDomain( W ) );
      S:= Intersection2( AsVectorSpace( S, V ), AsVectorSpace( S, W ) );
    else

    # Compute the intersection of two spaces over the same field.
    if ForAll(GeneratorsOfLeftModule(V),
        x->IsVectorObj(x) and not IsDataObjectRep(x))
      and ForAll(GeneratorsOfLeftModule(W),
        x->IsVectorObj(x) and not IsDataObjectRep(x)) then
      mat:= SumIntersectionMat( Matrix(LeftActingDomain(V),
          GeneratorsOfLeftModule( V )),Matrix(LeftActingDomain(W),
                                  GeneratorsOfLeftModule( W ) ))[2];
    else
      mat:= SumIntersectionMat( BasisVectors(SemiEchelonBasis( V )),
                                BasisVectors(SemiEchelonBasis( W )) )[2];
    fi;
#T why not just the generators if no basis is known yet?
      if IsEmpty( mat ) then
        S:= TrivialSubspace( V );
      else
        S:= LeftModuleByGenerators( LeftActingDomain( V ), mat );
        UseBasis( S, mat );
        SetSemiEchelonBasis(S, SemiEchelonBasisNC(S,mat));
      fi;

    fi;

    return S;
    end );


#############################################################################
##
#M  NormedRowVectors( <V> )
##
InstallMethod( NormedRowVectors,
    "for Gaussian row space",
    [ IsGaussianRowSpace ],
    function( V )
    local base,       # basis vectors
          elms,       # element list, result
          elms2,      # intermediate element list
          F,          # `LeftActingDomain( V )'
          q,          # `Size( F )'
          fieldelms,  # elements of `F' (in other succession)
          j,          # loop over `base'
          new,        # intermediate element list
          pos,        # position in `new' to store the next element
          len,        # actual length of `elms2'
          i,          # loop over field elements
          toadd,      # vector to add to known vectors
          k,          # loop over `elms2'
          v;          # one normed row vector

    if not IsFinite( V ) then
      Error( "sorry, cannot compute normed vectors of infinite domain <V>" );
    fi;

    base:= Reversed( BasisVectors( CanonicalBasis( V ) ) );
    if Length( base ) = 0 then
      return [];
    fi;

    elms      := [ base[1] ];
    elms2     := [ base[1] ];
    F         := LeftActingDomain( V );
    q         := Size( F );
    fieldelms := List( AsSSortedList( F ), x -> x - 1 );

    for j in [ 1 .. Length( base ) - 1 ] do

      # Here `elms2' has the form
      # $b_i + M = b_i + \langle b_{i+1}, \ldots, b_n \rangle$.
      # Compute $b_{i-1} + \bigcup_{\lambda\in F} \lambda b_i + ( b_i + M )$.
      new:= [];
      pos:= 0;
      len:= Length( elms2 );
      for i in fieldelms do
        toadd:= base[j+1] + i * base[j];
        for k in [ 1 .. len ] do
          v:= elms2[k] + toadd;
          v:= ImmutableVector( q, v );
          new[ pos + k ]:= v;
        od;
        pos:= pos + len;
      od;
      elms2:= new;

      # `elms2' is a set here.
      Append( elms, elms2 );

    od;

    # The list is strictly sorted, so we store this.
    MakeImmutable( elms );
    Assert( 1, IsSSortedList( elms ) );
    SetIsSSortedList( elms, true );

    # Return the result.
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
    "for Gaussian row space with known semi-ech. basis",
    [ IsGaussianRowSpace and HasSemiEchelonBasis ],
    function( V )
    local base,    # list of base vectors
          heads,   # list of numbers of leading columns
          ech,     # echelonized basis, if known
          vectors, #
          row,     # one vector in `ech'
          B,       # basis record, result
          n,       # number of columns in generators
          i,       # loop over rows
          k;       # loop over columns

    base  := [];

    # We use the semi-echelonized basis.
    # All we have to do is to sort the basis vectors such that the
    # pivot elements are in increasing order, and to zeroize all
    # elements in the pivot columns except the pivot itself.

    ech:= SemiEchelonBasis( V );
    vectors:= BasisVectors( ech );
    if IsEmpty( vectors ) then
      SetIsEmpty( ech, true );
      SetIsCanonicalBasis( ech, true );
      return ech;
    fi;
    heads := ShallowCopy( ech!.heads );
    n:= Length( heads );

    for i in [ 1 .. n ] do
      if heads[i] <> 0 then

        # Eliminate the `ech!.heads[i]'-th row with all those rows
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

    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep
                            and IsCanonicalBasis ),
                   rec() );
    SetIsRectangularTable( B, true );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, base );

    B!.heads:= heads;

    # Return the basis.
    return B;
    end );

InstallMethod( CanonicalBasis,
    "for Gaussian row space",
    [ IsGaussianRowSpace ],
    function( V )

    local base,    # list of base vectors
          heads,   # list of numbers of leading columns
          B,       # basis record, result
          m,       # number of rows in generators
          n,       # number of columns in generators
          zero,    # zero of the field
          i,       # loop over rows
          k;       # loop over columns

    base  := [];
    heads := ListWithIdenticalEntries( DimensionOfVectors( V ), 0 );
    zero  := Zero( LeftActingDomain( V ) );

    if not IsEmpty( GeneratorsOfLeftModule( V ) ) then

      # Make a copy to avoid changing the original argument.
      B:= List( GeneratorsOfLeftModule( V ), ShallowCopy );
      # filter for vector objects, not compressed FF vectors
      if ForAny(B,x->IsVectorObj(x) and not IsDataObjectRep(x)) then
        B:=List(B,Unpack);
      fi;
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

    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep
                            and IsCanonicalBasis ),
                   rec() );
    if IsEmpty( base ) then
      SetIsEmpty( B, true );
    else
      SetIsRectangularTable( B, true );
    fi;
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, base );

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
    "for Gaussian row space",
    [ IsGaussianRowSpace ],
    V -> Dimension( V ) = DimensionOfVectors( V ) );

InstallMethod( IsFullRowModule,
    "for non-Gaussian row space",
    [ IsVectorSpace and IsNonGaussianRowSpace ],
    ReturnFalse );

InstallOtherMethod( IsFullRowModule,
    "for arbitrary free left module",
    [ IsLeftModule ],
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
InstallMethod( CanonicalBasis,
    "for a full row space",
    [ IsFullRowModule and IsVectorSpace ],
    function( V )
    local B;
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasis
                            and IsSemiEchelonized
                            and IsSemiEchelonBasisOfGaussianRowSpaceRep
                            and IsCanonicalBasisFullRowModule ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    B!.heads:= [ 1 .. DimensionOfVectors( V ) ];
    if DimensionOfVectors( V ) = 0 then
      SetIsEmpty( B, true );
    else
      SetIsRectangularTable( B, true );
    fi;
    return B;
    end );


#############################################################################
##
##  6. Methods for collections of subspaces of full row spaces
##

#############################################################################
##
#R  IsSubspacesFullRowSpaceDefaultRep
##
DeclareRepresentation( "IsSubspacesFullRowSpaceDefaultRep",
    IsSubspacesVectorSpaceDefaultRep,
    [] );


#############################################################################
##
#M  Iterator( <subspaces> ) . . . . . for subspaces of finite full row module
##
BindGlobal( "IsDoneIterator_SubspacesDim",
    iter ->     IsDoneIterator( iter!.choiceiter )
            and IsDoneIterator( iter!.spaceiter ) );

BindGlobal( "NextIterator_SubspacesDim", function( iter )
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
      iter!.actchoice:= ShallowCopy(NextIterator( iter!.choiceiter ));
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

BindGlobal( "ShallowCopy_SubspacesDim",
    iter -> rec( V          := iter!.V,
                 field      := iter!.field,
                 n          := iter!.n,
                 k          := iter!.k,
                 choiceiter := ShallowCopy( iter!.choiceiter ),
                 actchoice  := iter!.actchoice,
                 spaceiter  := ShallowCopy( iter!.spaceiter ) ) );

BindGlobal( "IsDoneIterator_SubspacesAll",
    iter ->     iter!.actdim = iter!.dim
            and IsDoneIterator( iter!.actdimiter ) );

BindGlobal( "NextIterator_SubspacesAll", function( iter )
    if IsDoneIterator( iter!.actdimiter ) then
      iter!.actdim:= iter!.actdim + 1;
      iter!.actdimiter:= Iterator(Subspaces( iter!.V, iter!.actdim));
    fi;
    return NextIterator( iter!.actdimiter );
    end );

BindGlobal( "ShallowCopy_SubspacesAll",
    iter -> rec( V          := iter!.V,
                 dim        := iter!.dim,
                 actdim     := iter!.actdim,
                 actdimiter := ShallowCopy( iter!.actdimiter ) ) );

InstallMethod( Iterator,
    "for subspaces collection of a (finite) full row module",
    [ IsSubspacesVectorSpace and IsSubspacesFullRowSpaceDefaultRep ],
    function( D )
    local V,      # the vector space
          n,      # dimension of `V'
          k,
          iter;   # iterator, result

    V:= D!.structure;

    if not IsFinite( V ) then
      TryNextMethod();
    fi;

    k:= D!.dimension;
    n:= Dimension( V );

    if IsInt( D!.dimension ) then

      # Loop over subspaces of fixed dimension `k'.
      # For that, loop over all possible choices of `k' ordered positions
      # in `[ 1 .. n ]', and for every such choice, loop over all
      # possibilities to fill the positions in the canonical basis
      # that has these positions as pivot columns.

      # If the choice is $[ a_1, a_2, \ldots, a_k ]$ then there are
      # \[ (a_2-a_1-1)+2(a_3-a_2-1)+\cdots + (k-1)(a_k-a_{k-1}-1)+k(n-a_k)
      #    = \sum_{i=1}^{k-1} i(a_{i+1}-a_i-1) + k(n-a_k)
      #    = k n - \frac{1}{2}k(k-1) - \sum_{i=1}^k a_i \]
      # positions that can be chosen arbitrarily, so we may loop over
      # the elements of a space of this dimension.

      iter:= IteratorByFunctions( rec(
                 IsDoneIterator := IsDoneIterator_SubspacesDim,
                 NextIterator   := NextIterator_SubspacesDim,
                 ShallowCopy    := ShallowCopy_SubspacesDim,

                 V              := V,
                 field          := LeftActingDomain( V ),
                 n              := n,
                 k              := k,
                 choiceiter     := Iterator( Combinations( [ 1..n ],
                                                 D!.dimension ) ) ) );
#T better make this *really* clever!
      # Initialize.
      iter!.actchoice:= ShallowCopy(NextIterator( iter!.choiceiter ));
      iter!.spaceiter:= IteratorByBasis( CanonicalBasis( FullRowSpace(
           iter!.field, n * k - k * (k - 1) / 2
                               - Sum( iter!.actchoice ) ) ) );
      Add( iter!.actchoice, n+1 );

    else

      # Loop over all subspaces of `V'.
      # For that, use iterators for subspaces of fixed dimension,
      # and loop over all dimensions.
      iter:= IteratorByFunctions( rec(
                 IsDoneIterator := IsDoneIterator_SubspacesAll,
                 NextIterator   := NextIterator_SubspacesAll,
                 ShallowCopy    := ShallowCopy_SubspacesAll,

                 V              := V,
                 dim            := n,
                 actdim         := 0,
                 actdimiter     := Iterator( Subspaces( V, 0 ) ) ) );

    fi;

    # Return the iterator.
    return iter;
    end );


#############################################################################
##
#M  Subspaces( <V>, <dim> )
##
InstallMethod( Subspaces,
    "for (Gaussian) full row space",
    [ IsFullRowModule and IsVectorSpace, IsInt ],
    function( V, dim )
    return Objectify( NewType( CollectionsFamily( FamilyObj( V ) ),
                                   IsSubspacesVectorSpace
                               and IsSubspacesFullRowSpaceDefaultRep ),
                      rec(
                           structure  := V,
                           dimension  := dim
                          )
                     );
    end );

InstallOtherMethod( Subspaces,
    "for (Gaussian) full row space",
    [ IsFullRowModule and IsVectorSpace, IsString ],
    function( V, all )
    return Subspaces( V );
    end );


#############################################################################
##
#M  Subspaces( <V> )
##
InstallMethod( Subspaces,
    [ IsFullRowModule and IsVectorSpace ],
    V -> Objectify( NewType( CollectionsFamily( FamilyObj( V ) ),
                                 IsSubspacesVectorSpace
                             and IsSubspacesFullRowSpaceDefaultRep ),
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
##  `IsMutableBasisByImmutableBasisRep' if the mutable basis is closed by a
##  vector that makes the space non-Gaussian.
##
DeclareRepresentation( "IsMutableBasisOfGaussianRowSpaceRep",
    IsComponentObjectRep,
    [ "heads", "basisVectors", "leftActingDomain", "zero" ] );


#############################################################################
##
#M  MutableBasis( <R>, <vectors> )  . . . . . . . . . . . for matrix over <R>
#M  MutableBasis( <R>, <vectors>, <zero> )  . . . . . . . for matrix over <R>
##
InstallMethod( MutableBasis,
    "method to construct mutable bases of row spaces",
    IsElmsColls,
    [ IsRing, IsMatrix ],
    function( R, vectors )
    local B, newvectors;

    if ForAny( vectors, v -> not IsSubset( R, v ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that stores an immutable basis.
      TryNextMethod();

    else

      # Note that `vectors' is not empty.
      newvectors:= SemiEchelonMat( vectors );

      B:= Objectify( NewType( FamilyObj( vectors ),
                                  IsMutableBasis
                              and IsMutable
                              and IsMutableBasisOfGaussianRowSpaceRep ),
                     rec(
                          basisVectors:= ShallowCopy( newvectors.vectors ),
                          heads:= ShallowCopy( newvectors.heads ),
                          zero:= Zero( vectors[1] ),
                          leftActingDomain := R
                          ) );

    fi;

    return B;
    end );

InstallOtherMethod( MutableBasis,
    "method to construct mutable bases of row spaces",
    IsFamXFam,
    [ IsRing, IsList, IsRowVector ],
    function( R, vectors, zero )
    local B;

    if ForAny( vectors, v -> not IsSubset( R, v ) ) then

      # If Gaussian elimination is not allowed,
      # we construct a mutable basis that stores an immutable basis.
      TryNextMethod();

    else

      B:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                  IsMutableBasis
                              and IsMutable
                              and IsMutableBasisOfGaussianRowSpaceRep ),
                     rec(
                          zero:= zero,
                          leftActingDomain := R
                          ) );

      if IsEmpty( vectors ) then

        B!.basisVectors:= [];
        B!.heads:= ListWithIdenticalEntries( Length( zero ), 0 );

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
#M  ViewObj( <MB> ) . . . . . . .  view mutable basis of a Gaussian row space
##
InstallMethod( ViewObj,
    "for a mutable basis of a Gaussian row space",
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep ],
    function( MB )
    Print( "<mutable basis over ", MB!.leftActingDomain, ", ",
           Pluralize( Length( MB!.basisVectors ), "vector" ), ">" );
    end );


#############################################################################
##
#M  PrintObj( <MB> )  . . . . . . print mutable basis of a Gaussian row space
##
InstallMethod( PrintObj,
    "for a mutable basis of a Gaussian row space",
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep ],
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
#M  BasisVectors( <MB> )  . . . . . for mutable basis of a Gaussian row space
##
InstallOtherMethod( BasisVectors,
    "for a mutable basis of a Gaussian row space",
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep ],
    MB -> Immutable( MB!.basisVectors ) );


#############################################################################
##
#M  CloseMutableBasis( <MB>, <v> )  . .  for mut. basis of Gaussian row space
##
InstallMethod( CloseMutableBasis,
    "for a mut. basis of a Gaussian row space, and a row vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutable and IsMutableBasisOfGaussianRowSpaceRep,
      IsRowVector ],
    function( MB, v )
    local V,              # corresponding free left module
          ncols,          # dimension of the row vectors
          zero,           # zero scalar
          heads,          # heads info of the basis
          basisvectors,   # list of basis vectors of `MB'
          j;              # loop over `heads'

    # Check whether the mutable basis belongs to a Gaussian row space
    # after the closure.
    if not IsSubset( MB!.leftActingDomain, v ) then

      # Change the representation to a mutable basis by immutable basis.
#T better mechanism?
      basisvectors:= Concatenation( MB!.basisVectors, [ v ] );
      V:= LeftModuleByGenerators( MB!.leftActingDomain, basisvectors );
      UseBasis( V, basisvectors );

      SetFilterObj( MB, IsMutableBasisByImmutableBasisRep );
      ResetFilterObj( MB, IsMutableBasisOfGaussianRowSpaceRep );

      MB!.immutableBasis:= Basis( V );
      return true;

    else

      # Reduce `v' with the known basis vectors.
      v:= ShallowCopy( v );
      ncols:= Length( v );
      heads:= MB!.heads;

      if ncols <> Length( heads ) then
        Error( "<v> must have same length as `MB!.heads'" );
      fi;

      zero:= Zero( v[1] );
      basisvectors:= MB!.basisVectors;

      for j in [ 1 .. ncols ] do
        if zero <> v[j] and heads[j] <> 0 then
#T better loop with `PositionNonZero'?
          AddRowVector( v, basisvectors[ heads[j] ], - v[j] );
        fi;
      od;

      # If necessary add the sifted vector, and update the basis info.
      j := PositionNonZero( v );
      if j <= ncols then
        MultVector( v, Inverse( v[j] ) );
        Add( basisvectors, v );
        heads[j]:= Length( basisvectors );
        return true;
      else
        # The basis was not extended.
        return false;
      fi;

    fi;
    end );


#############################################################################
##
#M  IsContainedInSpan( <MB>, <v> )  . .  for mut. basis of Gaussian row space
##
InstallMethod( IsContainedInSpan,
    "for a mut. basis of a Gaussian row space, and a row vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep,
      IsRowVector ],
    function( MB, v )
    local
          ncols,          # dimension of the row vectors
          heads,          # heads info of the basis
          basisvectors,   # list of basis vectors of `MB'
          j;              # loop over `heads'

    if not IsSubset( MB!.leftActingDomain, v ) then

      return false;

    else

      # Reduce `v' with the known basis vectors.
      v:= ShallowCopy( v );
      ncols:= Length( v );
      heads:= MB!.heads;

      if ncols <> Length( MB!.heads ) then
        return false;
      fi;

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
    "for a mutable basis of a Gaussian row space",
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep ],
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


#############################################################################
##
#M  SiftedVector( <MB>, <v> ) . . . for mutable basis of a Gaussian row space
##
##  If `<MB>!.heads[<i>]' is nonzero this means that the <i>-th column is
##  leading column of the row `<MB>!.heads[<i>]'.
##
InstallOtherMethod( SiftedVector,
    "for mutable basis of Gaussian row space, and row vector",
    IsCollsElms,
    [ IsMutableBasis and IsMutableBasisOfGaussianRowSpaceRep, IsRowVector ],
    function( MB, v )
    return SiftedVectorForGaussianRowSpace(
               MB!.leftActingDomain, MB!.basisVectors, MB!.heads, v );
    end );


#############################################################################
##
#F  OnLines( <vec>, <g> ) . . . . . . . .  for operation on projective points
##
InstallGlobalFunction( OnLines, function( vec, g )
    local c;
    vec:= OnPoints( vec, g );
    c:= PositionNonZero( vec );
    if c <= Length( vec ) then

      # Normalize from the *left* if the matrices act from the right!
      vec:= Inverse( vec[c] ) * vec;

    fi;
    return vec;
end );


#############################################################################
##
#M  NormedRowVector( <v> )
##
InstallMethod( NormedRowVector,
    "for a row vector of scalars",
    [ IsRowVector and IsScalarCollection ],
function( v )
    local   depth;

    if 0 < Length(v)  then
        depth:=PositionNonZero( v );
        if depth <= Length(v) then
            return Inverse(v[depth]) * v;
        else
            return ShallowCopy(v);
        fi;
    else
        return ShallowCopy(v);
    fi;
end );


#T mutable bases for Gaussian row and matrix spaces are always semi-ech.
#T (note that we construct a mutable basis only if we want to do successive
#T closures)


#############################################################################
##
##  8. Methods installed by somebody else without documenting this ...
##


#############################################################################
##
#F  ExtendedVectors( <V> )  . . . . . . . . . . . . . . . . . for a row space
##
BindGlobal( "ElementNumber_ExtendedVectors", function( enum, n )
    if Length( enum ) < n then
      Error( "<enum>[", n, "] must have an assigned value" );
    fi;
    n:= Concatenation( enum!.spaceEnumerator[n], [ enum!.one ] );
    return ImmutableVector( enum!.q, n );
end );

BindGlobal( "NumberElement_ExtendedVectors", function( enum, elm )
    if not IsList( elm ) or Length( elm ) <> enum!.len
                         or elm[ enum!.len ] <> enum!.one then
      return fail;
    fi;
    # special case for dimension 1: here, the truncated vector would be an
    # empty list, and there are problems with trivial vector spaces over
    # length 0 vectors (see e.g. issue #2117, PR #2125)
    if Length( elm ) = 1 then return 1; fi;
    return Position( enum!.spaceEnumerator,
                     elm{ [ 1 .. Length( elm ) - 1 ] } );
end );

BindGlobal( "NumberElement_ExtendedVectorsFF", function( enum, elm )
    # test whether the vector is indeed compact over the right finite field
    if not IsGF2VectorRep( elm ) and not Is8BitVectorRep( elm ) then
      return NumberElement_ExtendedVectors( enum, elm );
    fi;

    # Problem with GF(4) vectors over GF(2)
    if ( IsGF2VectorRep( elm ) and enum!.q <> 2 )
       or ( Is8BitVectorRep( elm ) and enum!.q = 2 ) then
      return NumberElement_ExtendedVectors( enum, elm );
    fi;

    # compute index via number
    if not IsList( elm ) or Length( elm ) <> enum!.len
                         or elm[ enum!.len ] <> enum!.one then
      return fail;
    fi;
    # We exploit that NumberFFVector is defined by position in a sorted list
    # of all vectors. Therefore, for coefficients v1, ..., vn, we have
    # NumberFFVector([v1,...,vn,1],q) = NumberFFVector([v1,...,vn],q)*q+1
    return QuoInt( NumberFFVector( elm, enum!.q ), enum!.q ) + 1;
end );

BindGlobal( "Length_ExtendedVectors", T -> Length( T!.spaceEnumerator ) );

BindGlobal( "PrintObj_ExtendedVectors", function( T )
    Print( "A( ", T!.space, " )" );
end );

BindGlobal( "ExtendedVectors", function( V )
    local enum;

    enum:= EnumeratorByFunctions( FamilyObj( V ), rec(
               ElementNumber   := ElementNumber_ExtendedVectors,
               NumberElement   := NumberElement_ExtendedVectors,
               Length          := Length_ExtendedVectors,
               PrintObj        := PrintObj_ExtendedVectors,

               spaceEnumerator := Enumerator( V ),
               space           := V,
               one             := One( LeftActingDomain( V ) ),
               len             := Length( Zero( V ) ) + 1 ) );

    enum!.q:= Size( LeftActingDomain( V ) );
    if     IsFinite( LeftActingDomain( V ) )
       and IsPrimeInt( Size( LeftActingDomain( V ) ) )
       and Size( LeftActingDomain( V ) ) < 256
       and IsInternalRep( One( LeftActingDomain( V ) ) ) then
      SetFilterObj( enum, IsQuickPositionList );
      enum!.NumberElement:= NumberElement_ExtendedVectorsFF;
    fi;

    return enum;
end );


#############################################################################
##
#F  EnumeratorOfNormedRowVectors( <V> )  . . . . . . for a Gaussian row space
##
##  This had been called `OneDimSubspacesTransversal' in {\GAP}~4.3,
##  and special code in `ActionHomomorphismConstructor' relied on the fact
##  that one of its arguments was *not* an object returned by
##  `OneDimSubspacesTransversal'.
##  Now the result is just the ``sparse equivalent'' of `NormedRowVectors',
##  it does not carry any nasty `PositionCanonical' magic.
##
BindGlobal( "ElementNumber_NormedRowVectors", function( T, num )
    local   f,  v,  q,  n,  nnum, i,  l,  L;

    f := T!.enumeratorField;
    q := Length( f );
    n := T!.dimension;
    v := ListWithIdenticalEntries( n, Zero( T!.one ) );
    nnum:= num;
    num := num - 1;

    # Find the number of entries after the leading 1.
    l := 0;
    L := 1;
    while num >= L  do
        l := l + 1;
        L := L * q + 1;
    od;
    num := num - ( L - 1 ) / q;
    if n <= l then
      Error( "<T>[", nnum, "] must have an assigned value" );
    fi;
    v[ n - l ] := T!.one;
    for i  in [ n - l + 1 .. n ]  do
        v[ i ] := f[ num mod q + 1 ];
        num := QuoInt( num, q );
    od;
    return ImmutableVector( q, v );
end );

BindGlobal( "NumberElement_NormedRowVectors", function( T, elm )
    local   f,  zero,  q,  n,  l,  num,  val,  i;

    f := T!.enumeratorField;
    zero := Zero( T!.one );
    q := Length( f );
    n := T!.dimension;
    l := 1;

    if    not IsRowVector( elm )
       or not IsCollsElms( FamilyObj( T ), FamilyObj( elm ) )
       or Length( elm ) <> T!.dimension then
      return fail;
    fi;

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

BindGlobal( "Length_NormedRowVectors", function( T )
    local  q,  d;

    q := Length( T!.enumeratorField );
    d := T!.dimension;
    return ( q ^ d - 1 ) / ( q - 1 );
end );

BindGlobal( "PrintObj_NormedRowVectors", function( T )
    Print( "EnumeratorOfNormedRowVectors( ", T!.domain, " )" );
end );

BindGlobal( "EnumeratorOfNormedRowVectors", function( V )
    if not ( IsFullRowModule( V ) and IsFinite( V ) ) then
      Error( "<V> must be a finite full row space" );
    fi;

    return EnumeratorByFunctions( FamilyObj( V ), rec(
               ElementNumber   := ElementNumber_NormedRowVectors,
               NumberElement   := NumberElement_NormedRowVectors,
               Length          := Length_NormedRowVectors,
               PrintObj        := PrintObj_NormedRowVectors,

               enumeratorField := Enumerator( LeftActingDomain( V ) ),
               domain          := V,
               dimension       := Dimension( V ),
               one             := One( LeftActingDomain( V ) ) ) );
end );


#############################################################################
##
#F  OrthogonalSpaceInFullRowSpace( U ) . . . . . . . . .compute the dual to U
##
InstallMethod( OrthogonalSpaceInFullRowSpace,
    "dual space for Gaussian row space",
    [ IsGaussianRowSpace ],
function( U )
    local base, n, i, null;
    base := ShallowCopy( Basis( U ) );
    n := Length( Zero( U ) );
    for i in [Length(base)+1..n] do
        Add( base, Zero(U) );
    od;
    null := NullspaceMat( TransposedMat( base ) );
    return VectorSpace( LeftActingDomain(U), null, Zero(U), "basis" );
end );
