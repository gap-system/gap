#############################################################################
##
#W  rest.gi                     GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains various odds and ends.
##
Revision.rest_gi :=
    "@(#)$Id$";


# Booleans
BooleanFamily           := NewFamily(  "BooleanFamily", IS_BOOL );
KIND_BOOL               := NewKind(     BooleanFamily,
                            IS_BOOL and IsInternalRep );


# Characters
CharsFamily             := NewFamily(  "CharsFamily", IsChar );
KIND_CHAR               := NewKind(     CharsFamily,
                            IsChar and IsInternalRep );

# Records
RecordsFamily           := NewFamily(  "RecordsFamily", IS_REC );
KIND_PREC_MUTABLE       := NewKind(     RecordsFamily,
                            IS_MUTABLE_OBJ and IS_REC and IsInternalRep );
KIND_PREC_IMMUTABLE     := NewKind(     RecordsFamily,
                            IS_REC and IsInternalRep );


# Integers, Rationals, and Cyclotomics
CyclotomicsFamily       := NewFamily(  "CyclotomicsFamily", IsCyclotomic );
IsSmallIntRep           := NewRepresentation( "IsSmallIntRep",
                            IsInternalRep, "", IsObject );
KIND_INT_SMALL_ZERO     := NewKind(     CyclotomicsFamily,
                            IsInt and IsZeroCyc and IsSmallIntRep );
KIND_INT_SMALL_NEG      := NewKind(     CyclotomicsFamily,
                            IsInt and IsNegRat and IsSmallIntRep );
KIND_INT_SMALL_POS      := NewKind(     CyclotomicsFamily,
                            IsInt and IsPosRat and IsSmallIntRep );
KIND_INT_LARGE_NEG      := NewKind(     CyclotomicsFamily,
                            IsInt and IsNegRat and IsInternalRep );
KIND_INT_LARGE_POS      := NewKind(     CyclotomicsFamily,
                            IsInt and IsPosRat and IsInternalRep );
KIND_RAT_NEG            := NewKind(     CyclotomicsFamily,
                            IsRat and IsNegRat and IsInternalRep );
KIND_RAT_POS            := NewKind(     CyclotomicsFamily,
                            IsRat and IsPosRat and IsInternalRep );
KIND_CYC                := NewKind(     CyclotomicsFamily,
                            IsCyc           and IsInternalRep );

SetOne(            CyclotomicsFamily, 1    );
SetZero(           CyclotomicsFamily, 0    );
SetCharacteristic( CyclotomicsFamily, 0    );
SetIsUFDFamily(    CyclotomicsFamily, true );

IsInfinity := NewRepresentation( "IsInfinity",
    IsCyclotomic and IsAttributeStoringRep,
    [] );
infinity:= Objectify( NewKind( CyclotomicsFamily, IsInfinity ), rec() );
InstallMethod( \=,
    "method for cyclotomic and 'infinity'",
    IsIdentical, [ IsCyc, IsInfinity ], 0, ReturnFalse );
InstallMethod( \=,
    "method for 'infinity' and cyclotomic",
    IsIdentical, [ IsInfinity, IsCyc ], 0, ReturnFalse );
InstallMethod( \=,
    "method for 'infinity' and 'infinity'",
    IsIdentical, [ IsInfinity, IsInfinity ], 0, ReturnTrue );
InstallMethod( \<,
    "method for cyclotomic and 'infinity'",
    IsIdentical, [ IsCyc, IsInfinity ], 0, ReturnTrue );
InstallMethod( \<,
    "method for 'infinity' and cyclotomic",
    IsIdentical, [ IsInfinity, IsCyc ], 0, ReturnFalse );
InstallMethod( \<,
    "method for 'infinity' and 'infinity'",
    IsIdentical, [ IsInfinity, IsInfinity ], 0, ReturnFalse );
SetName( infinity, "infinity" );


# Finite Field Elements
MAXSIZE_GF_INTERNAL := 2^16;

FAMS_FFE  := [];
KINDS_FFE := [];
KIND_FFE  := function ( p )
    if not IsBound( KINDS_FFE[p] )  then
        FAMS_FFE[p] := NewFamily( "FFEFamily", IS_FFE );
        SetIsUFDFamily( FAMS_FFE[p], true );
        SetCharacteristic( FAMS_FFE[p], p );
        KINDS_FFE[p] := NewKind( FAMS_FFE[p], IS_FFE and IsInternalRep );
    fi;
    return KINDS_FFE[p];
end;

InstallMethod( DegreeFFE,
    "method for internal FFE",
    true,
    [ IsFFE and IsInternalRep ], 0,
    DEGREE_FFE_DEFAULT );

InstallMethod( LogFFE,
    "method for two internal FFEs",
    IsIdentical,
    [ IsFFE and IsInternalRep, IsFFE and IsInternalRep ], 0,
    LOG_FFE_DEFAULT );

InstallMethod( IntFFE,
    "method for internal FFE",
    true, [ IsFFE and IsInternalRep ], 0,
    INT_FFE_DEFAULT );

#############################################################################
##
#F  SUM_FFE_LARGE
#F  DIFF_FFE_LARGE
#F  PROD_FFE_LARGE
#F  QUO_FFE_LARGE
#F  LOG_FFE_LARGE
##
SUM_FFE_LARGE := function(arg) Error( "not supported yet" ); end;
DIFF_FFE_LARGE := function(arg) Error( "not supported yet" ); end;
PROD_FFE_LARGE := function(arg) Error( "not supported yet" ); end;
QUO_FFE_LARGE := function(arg) Error( "not supported yet" ); end;
LOG_FFE_LARGE := function(arg) Error( "not supported yet" ); end;


# Permutations
PermutationsFamily      := NewFamily(  "PermutationsFamily", IS_PERM );
IsPerm2Rep              := NewRepresentation( "IsPerm2Rep",
                            IsInternalRep, "", IsObject );
IsPerm4Rep              := NewRepresentation( "IsPerm4Rep",
                            IsInternalRep, "", IsObject );
KIND_PERM2              := NewKind(     PermutationsFamily,
                            IS_PERM and IsPerm2Rep );
KIND_PERM4              := NewKind(     PermutationsFamily,
                            IS_PERM and IsPerm4Rep );

SetOne( PermutationsFamily, () );

InstallMethod( SmallestMovedPointPerm,
    "method for a permutation",
    true,
    [ IsPerm and IsInternalRep ], 0,
#T why internal?
    function( p )
    local   i;
    
    if p = ()  then
#T test 'IsOne' ?
        return infinity;
    fi;
    i := 1;
    while i ^ p = i  do
        i := i + 1;
    od;
    return i;
end );

InstallMethod( LargestMovedPointPerm,
    "method for an internal permutation",
    true,
    [ IsPerm and IsInternalRep ], 0,
    LARGEST_MOVED_POINT_PERM );

InstallMethod( NrMovedPointsPerm,
    "method for a permutation",
    true,
    [ IsPerm ], 0,
    function( perm )
    local mov, pnt;
    mov:= 0;
    if perm <> () then
      for pnt in [ SmallestMovedPointPerm( perm )
                   .. LargestMovedPointPerm( perm ) ] do
        if pnt ^ perm <> pnt then
          mov:= mov + 1;
        fi;
      od;
    fi;
    return mov;
    end );


#############################################################################
##
#F  KIND_RANGE_SSORT_MUTABLE
##
KIND_RANGE_SSORT_MUTABLE := Subkind(
                            KIND_LIST_HOM( CyclotomicsFamily, 4 ),
                            IsRange and IsMutable );


#############################################################################
##
#F  KIND_RANGE_NSORT_MUTABLE
##
KIND_RANGE_NSORT_MUTABLE := Subkind(
                            KIND_LIST_HOM( CyclotomicsFamily, 2 ),
                            IsRange and IsMutable );


#############################################################################
##
#F  KIND_RANGE_SSORT_IMMUTABLE
##
KIND_RANGE_SSORT_IMMUTABLE := Subkind(
                              KIND_LIST_HOM( CyclotomicsFamily, 4 ),
                              IsRange );


#############################################################################
##
#F  KIND_RANGE_NSORT_IMMUTABLE
##
KIND_RANGE_NSORT_IMMUTABLE := Subkind(
                              KIND_LIST_HOM( CyclotomicsFamily, 2 ),
                              IsRange );


#############################################################################
##
#M  String( <n> ) . . . . . . . . . . . . . . . . . . . . . .  for an integer
##
InstallMethod( String,
    "method for an integer",
    true,
    [ IsInt ], 0,
    STRING_INT );


#############################################################################
##
#M  String( <str> ) . . . . . . . . . . . . . . . . . . . . . .  for a string
##
InstallMethod( String,
    "method for a string",
    true,
    [ IsString ], 0,
    IdFunc );


#############################################################################
##
#F  LogInt( <n>, <base> ) . . . . . . . . . . . . . . logarithm of an integer
##
LogInt := function ( n, base )
    local   log;

    # check arguments
    if n    <= 0  then Error("<n> must be positive");  fi;
    if base <= 1  then Error("<base> must be greater than 1");  fi;

    # 'log(b)' returns $log_b(n)$ and divides 'n' by 'b^log(b)'
    log := function ( b )
        local   i;
        if b > n  then return 0;  fi;
        i := log( b^2 );
        if b > n  then return 2 * i;
        else  n := QuoInt( n, b );  return 2 * i + 1;  fi;
    end;

    return log( base );
end;


############################################################################
##
#F  WordAlp( <alpha>, <nr> ) . . . . . .  <nr>-th word over alphabet <alpha>
##
##  is a string that is the <nr>-th word over the alphabet <alpha>,
##  w.r. to word length and lexicographical order.
##  The empty word is 'WordAlp( <alpha>, 0 )'.
##
WordAlp := function( alpha, nr )

    local lalpha,   # length of the alphabet
          word,     # the result
          nrmod;    # position of letter

    lalpha:= Length( alpha );
    word:= "";
    while nr <> 0 do
      nrmod:= nr mod lalpha;
      if nrmod = 0 then nrmod:= lalpha; fi;
      Add( word, alpha[ nrmod ] );
      nr:= ( nr - nrmod ) / lalpha;
    od;
    return Reversed( word );
end;


#############################################################################
##
#E  rest.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



