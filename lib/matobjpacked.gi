#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

#############################################################################
#
# Packed matrix and vector objects. The kernel functions PACKMAT_* in
# src/packmat.c do the work and check their arguments; most are installed
# as methods directly. They find the base domain and the field context in
# the data of the object's type (PackedRepContext).
#

# n for GF(n), n prime, or Integers mod n; else fail
BindGlobal( "PACKMAT_Modulus", function( R )
    local n;
    if ( IsFFECollection( R ) and IsField( R ) )
       or ( IsZmodnZObjNonprimeCollection( R ) and IsRingWithOne( R ) ) then
      n := Characteristic( R );
      if n > 0 and Size( R ) = n then
        return n;
      fi;
    fi;
    return fail;
  end );

# The kernel's fallback for entries other than FFEs of the base field and
# ZmodnZObj of its type, such as Z(9)^4 for GF(3)
BindGlobal( "PACKMAT_EntryResidue", function( R, x )
    if x in R then
      return Int( x );
    fi;
    return fail;
  end );

InstallMethod( PackedRepContext,
  [ IsSemiring ],
  function( R )
    local n, data, tdata, efam, mfilter, vfilter, mfam, vfam;

    # otherwise every call would make a new context
    if not IsAttributeStoringRep( R ) then
      Error( "<R> must store its attributes" );
    fi;

    n := PACKMAT_Modulus( R );
    if n <> fail then
      data := PACKMAT_FIELD_BAG( n, One( R ) );
    fi;
    if n = fail or data = fail then
      Error( "packed matrices need GF(p) or Integers mod n with n < 2^64 ",
             "as base domain, not ", R );
    fi;

    # shared by the four types, see src/packmat.c
    tdata := MakeImmutable( [ R, data, One( R ), Zero( R ) ] );

    mfilter := IsPackedMatrixRep;
    vfilter := IsPackedVectorRep;
    efam := ElementsFamily( FamilyObj( R ) );
    if CanEasilyCompareElementsFamily( efam ) then
      mfilter := mfilter and CanEasilyCompareElements;
      vfilter := vfilter and CanEasilyCompareElements;
    fi;
    mfam := CollectionsFamily( FamilyObj( R ) );
    vfam := FamilyObj( R );
    return rec(
      matrix := NewType( mfam, mfilter and IsMutable, tdata ),
      immutableMatrix := NewType( mfam, mfilter, tdata ),
      vector := NewType( vfam, vfilter and IsMutable, tdata ),
      immutableVector := NewType( vfam, vfilter, tdata ) );
  end );


#############################################################################
##
##  Constructors
##
##  Entries are always checked, since they must be converted; so the
##  'check' option changes nothing.
##
InstallTagBasedMethod( NewMatrix,
  IsPackedMatrixRep,
  function( filter, R, ncols, list )
    local nd;

    # a flat list of entries, as for IsGenericMatrixRep
    if Length( list ) > 0 and not IsVectorObj( list[1] ) then
      nd := NestingDepthA( list );
      if nd < 2 or nd mod 2 = 1 then
        if Length( list ) mod ncols <> 0 then
          Error( "NewMatrix: Length of <list> is not a multiple of <ncols>" );
        fi;
        list := List( [ 0, ncols .. Length( list ) - ncols ],
                      i -> list{ [ i + 1 .. i + ncols ] } );
      fi;
    fi;
    return PACKMAT_MATRIX( PackedRepContext( R ).matrix, ncols, list );
  end );

InstallTagBasedMethod( NewZeroMatrix,
  IsPackedMatrixRep,
  { filter, R, nrows, ncols } ->
    PACKMAT_ZERO_MATRIX( PackedRepContext( R ).matrix, nrows, ncols ) );

InstallTagBasedMethod( NewIdentityMatrix,
  IsPackedMatrixRep,
  { filter, R, n } ->
    PACKMAT_IDENTITY_MATRIX( PackedRepContext( R ).matrix, n ) );

InstallTagBasedMethod( NewVector,
  IsPackedVectorRep,
  { filter, R, list } -> PACKMAT_VECTOR( PackedRepContext( R ).vector, list ) );

InstallTagBasedMethod( NewZeroVector,
  IsPackedVectorRep,
  { filter, R, len } ->
    PACKMAT_ZERO_VECTOR( PackedRepContext( R ).vector, len ) );

# The generic methods for matrix and vector objects as input call Unpack;
# these give compressed and packed input to the kernel as it is.
BindGlobal( "PACKMAT_MatrixFrom", function( R, M )
    local ncols;
    ncols := NumberColumns( M );
    if not ( IsList( M ) or IsPackedMatrixRep( M ) ) then
      M := Unpack( M );
    fi;
    return PACKMAT_MATRIX( PackedRepContext( R ).matrix, ncols, M );
  end );

InstallMethod( Matrix,
  [ IsOperation, IsSemiring, IsMatrixObj ],
  1,
  function( filt, R, M )
    if not IsIdenticalObj( filt, IsPackedMatrixRep ) then
      TryNextMethod();
    fi;
    return PACKMAT_MatrixFrom( R, M );
  end );

InstallMethod( Matrix,
  [ IsMatrixObj, IsPackedMatrixRep ],
  { M, example } -> PACKMAT_MatrixFrom( BaseDomain( example ), M ) );

InstallMethod( Vector,
  [ IsOperation, IsSemiring, IsVectorObj ],
  1,
  function( filt, R, v )
    if not IsIdenticalObj( filt, IsPackedVectorRep ) then
      TryNextMethod();
    fi;
    return PACKMAT_VECTOR( PackedRepContext( R ).vector, v );
  end );

InstallMethod( Vector,
  [ IsVectorObj, IsPackedVectorRep ],
  { v, example } ->
    PACKMAT_VECTOR( PackedRepContext( BaseDomain( example ) ).vector, v ) );


#############################################################################
##
##  Attributes
##
InstallMethod( ConstructingFilter, [ IsPackedMatrixRep ],
  M -> IsPackedMatrixRep );

InstallMethod( ConstructingFilter, [ IsPackedVectorRep ],
  v -> IsPackedVectorRep );

InstallMethod( CompatibleVectorFilter, [ IsPackedMatrixRep ],
  M -> IsPackedVectorRep );

InstallMethod( BaseDomain, [ IsPackedMatrixRep ], PACKMAT_BASE_DOMAIN );
InstallMethod( BaseDomain, [ IsPackedVectorRep ], PACKMAT_BASE_DOMAIN );

InstallMethod( OneOfBaseDomain, [ IsPackedMatrixRep ],
  PACKMAT_ONE_OF_BASE_DOMAIN );
InstallMethod( OneOfBaseDomain, [ IsPackedVectorRep ],
  PACKMAT_ONE_OF_BASE_DOMAIN );

InstallMethod( ZeroOfBaseDomain, [ IsPackedMatrixRep ],
  PACKMAT_ZERO_OF_BASE_DOMAIN );
InstallMethod( ZeroOfBaseDomain, [ IsPackedVectorRep ],
  PACKMAT_ZERO_OF_BASE_DOMAIN );

InstallMethod( NumberRows, [ IsPackedMatrixRep ], PACKMAT_NROWS );
InstallMethod( NumberColumns, [ IsPackedMatrixRep ], PACKMAT_NCOLS );
InstallMethod( Length, [ IsPackedVectorRep ], PACKMAT_LENGTH );


#############################################################################
##
##  Entries
##
InstallMethod( MatElm, [ IsPackedMatrixRep, IsPosInt, IsPosInt ],
  PACKMAT_MAT_ELM );

InstallMethod( SetMatElm, [ IsPackedMatrixRep, IsPosInt, IsPosInt, IsObject ],
  PACKMAT_SET_MAT_ELM );

InstallMethod( \[\], [ IsPackedVectorRep, IsPosInt ], PACKMAT_VEC_ELM );

InstallMethod( \[\]\:\=, [ IsPackedVectorRep, IsPosInt, IsObject ],
  PACKMAT_SET_VEC_ELM );

InstallMethod( \[\], [ IsPackedMatrixRep, IsPosInt ],
  function( M, pos )
    ErrorNoReturn( "row access unsupported; use M[i,j] or RowsOfMatrix(M)" );
  end );

InstallMethod( Unpack, [ IsPackedMatrixRep ], PACKMAT_UNPACK );
InstallMethod( Unpack, [ IsPackedVectorRep ], PACKMAT_UNPACK );


#############################################################################
##
##  Whole objects
##
##  = needs identical base domains; < is that of Unpack and errors for
##  different base domains. The hash depends on dimensions and entries.
##
InstallMethod( \=, [ IsPackedMatrixRep, IsPackedMatrixRep ], PACKMAT_EQ_MAT );
InstallMethod( \=, [ IsPackedVectorRep, IsPackedVectorRep ], PACKMAT_EQ_VEC );
InstallMethod( \<, [ IsPackedMatrixRep, IsPackedMatrixRep ], PACKMAT_LT_MAT );
InstallMethod( \<, [ IsPackedVectorRep, IsPackedVectorRep ], PACKMAT_LT_VEC );

InstallMethod( IsZero, [ IsPackedMatrixRep ], PACKMAT_IS_ZERO );
InstallMethod( IsZero, [ IsPackedVectorRep ], PACKMAT_IS_ZERO );
InstallMethod( IsOne, [ IsPackedMatrixRep ], PACKMAT_IS_ONE );

# rank above the method for row spaces, which expects lists
InstallMethod( SparseIntKey, [ IsObject, IsPackedMatrixRep ],
  { dom, key } -> PACKMAT_HASH );
InstallMethod( SparseIntKey, [ IsObject, IsPackedVectorRep ],
  {} -> RankFilter( IsFFECollColl and IsGaussianRowSpace ),
  { dom, key } -> PACKMAT_HASH );

InstallMethod( ShallowCopy, [ IsPackedMatrixRep ],
  M -> PACKMAT_COPY( M, PackedRepContext( BaseDomain( M ) ).matrix ) );

InstallMethod( MutableCopyMatrix, [ IsPackedMatrixRep ],
  M -> PACKMAT_COPY( M, PackedRepContext( BaseDomain( M ) ).matrix ) );

InstallMethod( ShallowCopy, [ IsPackedVectorRep ],
  v -> PACKMAT_COPY( v, PackedRepContext( BaseDomain( v ) ).vector ) );


#############################################################################
##
##  Printing, as for IsGenericMatrixRep and IsPlistVectorRep
##
BindGlobal( "PACKMAT_BaseDomainString", function( R )
    if IsFinite( R ) and IsField( R ) then
      return Concatenation( "GF(", String( Size( R ) ), ")" );
    fi;
    return String( R );
  end );

InstallMethod( ViewObj, [ IsPackedMatrixRep ],
  function( M )
    Print( "<" );
    if not IsMutable( M ) then
      Print( "immutable " );
    fi;
    Print( NrRows( M ), "x", NrCols( M ),
           " packed matrix over ", BaseDomain( M ), ">" );
  end );

InstallMethod( PrintObj, [ IsPackedMatrixRep ],
  function( M )
    Print( "NewMatrix(IsPackedMatrixRep,",
           PACKMAT_BaseDomainString( BaseDomain( M ) ), ",",
           NrCols( M ), ",", Unpack( M ), ")" );
  end );

InstallMethod( String, [ IsPackedMatrixRep ],
  M -> Concatenation( "NewMatrix(IsPackedMatrixRep,",
           PACKMAT_BaseDomainString( BaseDomain( M ) ), ",",
           String( NrCols( M ) ), ",", String( Unpack( M ) ), ")" ) );

InstallMethod( Display, [ IsPackedMatrixRep ],
  function( M )
    local rows, i;
    Print( "<" );
    if not IsMutable( M ) then
      Print( "immutable " );
    fi;
    Print( NrRows( M ), "x", NrCols( M ),
           " packed matrix over ", BaseDomain( M ), ":\n" );
    rows := Unpack( M );
    for i in [ 1 .. Length( rows ) ] do
      if i = 1 then
        Print( "[" );
      else
        Print( " " );
      fi;
      Print( rows[i], "\n" );
    od;
    Print( "]>\n" );
  end );

InstallMethod( ViewObj, [ IsPackedVectorRep ],
  function( v )
    Print( "<" );
    if not IsMutable( v ) then
      Print( "immutable " );
    fi;
    Print( "packed vector over ", BaseDomain( v ), " of length ", Length( v ),
           ">" );
  end );

InstallMethod( PrintObj, [ IsPackedVectorRep ],
  function( v )
    Print( "NewVector(IsPackedVectorRep,",
           PACKMAT_BaseDomainString( BaseDomain( v ) ), ",", Unpack( v ), ")" );
  end );

InstallMethod( String, [ IsPackedVectorRep ],
  v -> Concatenation( "NewVector(IsPackedVectorRep,",
           PACKMAT_BaseDomainString( BaseDomain( v ) ), ",",
           String( Unpack( v ) ), ")" ) );

InstallMethod( Display, [ IsPackedVectorRep ],
  function( v )
    Print( "<a packed vector over ", BaseDomain( v ), ":\n" );
    Print( Unpack( v ), "\n>\n" );
  end );
