#############################################################################
##
#W  modulrow.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for *row modules*, that is,
##  free left modules consisting of row vectors.
##
##  Especially methods for *full row modules* $R^n$ are contained.
##
##  (See the file 'modulmat.gi' for the methods for matrix modules.)
##
Revision.modulrow_gi :=
    "@(#)$Id$";


#############################################################################
##
#R  IsRowModuleRep( <V> )
##
##  A *row module* is a free left module whose elements are lists of scalars.
##
IsRowModuleRep := NewRepresentation( "IsRowModuleRep",
    IsComponentObjectRep,
    [ "vectordim" ] );

InstallTrueMethod( IsFiniteDimensional,
    IsRowModuleRep and IsFreeLeftModule );


#############################################################################
##
#M  LeftModuleByGenerators( <R>, <mat> )  . . . . . .  construct a row module
##
InstallMethod( LeftModuleByGenerators,
    "method for ring and matrix (elements in the same family)",
    IsElmsColls,
    [ IsRing, IsMatrix ], 0,
    function( R, mat )
    local V;

    V:= Objectify( NewKind( FamilyObj( mat ),
                                IsLeftModule
                            and IsRowModuleRep
                            and IsAttributeStoringRep ),
                   rec() );
    SetLeftActingDomain( V, R );
    SetGeneratorsOfLeftModule( V, AsList( mat ) );

    # Set the vector dimension.
    V!.vectordim:= Length( mat[1] );

    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <R>, <mat>, <zero> )  . .  construct a row module
##
InstallOtherMethod( LeftModuleByGenerators,
    "method for ring, matrix (over the ring), and row vector",
    true,
#T explicit 2nd argument above!
    [ IsRing, IsHomogeneousList, IsRowVector ], 0,
    function( R, mat, zero )
    local V;

    # Check whether this method is the right one.
    if not (     HasCollectionsFamily( FamilyObj( R ) )
             and IsIdentical( FamilyObj( R ), FamilyObj( zero ) )
             and (    IsEmpty( mat )
                   or IsIdentical( CollectionsFamily( FamilyObj( R ) ),
                                   FamilyObj( mat ) ) ) ) then
      TryNextMethod();
    fi;

    V:= Objectify( NewKind( CollectionsFamily( FamilyObj( zero ) ),
                                IsLeftModule
                            and IsRowModuleRep
                            and IsAttributeStoringRep ),
                   rec() );
    SetLeftActingDomain( V, R );
    SetGeneratorsOfLeftModule( V, AsList( mat ) );
    SetZero( V, zero );
    V!.vectordim:= Length( mat[1] );

    return V;
    end );


#############################################################################
##
#F  FullRowModule( <R>, <n> )
##
FullRowModule := function( R, n )

    local M;   # the free module record, result

    if not ( IsRing( R ) and IsInt( n ) and 0 <= n ) then
      Error( "usage: FullRowModule( <R>, <n> ) for ring <R>" );
    fi;

    if IsDivisionRing( R ) then
      M:= Objectify( NewKind( CollectionsFamily( FamilyObj( R ) ),
                                  IsFreeLeftModule
                              and IsGaussianSpace
                              and IsRowModuleRep
                              and IsFullRowModule
                              and IsAttributeStoringRep ),
                     rec() );
    else
      M:= Objectify( NewKind( CollectionsFamily( FamilyObj( R ) ),
                                  IsFreeLeftModule
                              and IsRowModuleRep
                              and IsFullRowModule
                              and IsAttributeStoringRep ),
                     rec() );
    fi;
    SetLeftActingDomain( M, R );
    M!.vectordim:= n;

    return M;
end;


#############################################################################
##
#M  \^( <R>, <n> )  . . . . . . . . . . . . . . . full row module over a ring
##
InstallOtherMethod( \^,
    "method for ring and integer (delegate to 'FullRowModule')",
    true,
    [ IsRing, IsInt ], 0,
    FullRowModule );


#############################################################################
##
#M  IsFullRowModule( M )
##
InstallMethod( IsFullRowModule,
    "method for free row module that is a row module",
    true,
    [ IsFreeLeftModule and IsRowModuleRep ], 0,
    M ->     Dimension( M ) = M!.vectordim
         and ForAll( GeneratorsOfLeftModule( M ),
                     v -> IsSubset( LeftActingDomain( M ), v ) ) );
     

#############################################################################
##
#M  Dimension( <M> )
##
InstallMethod( Dimension,
    "method for full row module",
    true,
    [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], 0,
    M -> M!.vectordim );


#############################################################################
##
#M  Random( <M> )
##
InstallMethod( Random,
    "method for full row module",
    true,
    [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], 0,
    function( M )
    local R;
    R:= LeftActingDomain( M );
    return List( [ 1 .. M!.vectordim ], x -> Random( R ) );
    end );


#############################################################################
##
#M  GeneratorsOfLeftModule( <V> )
##
InstallMethod( GeneratorsOfLeftModule,
    "method for full row module",
    true, [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], 0,
    M -> IdentityMat( M!.vectordim, LeftActingDomain( M ) ) );


#############################################################################
##
#M  PrintObj( <M> )
##
InstallMethod( PrintObj,
    "method for full row module",
    true, [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], 0,
    function( M )
    Print( "( ", LeftActingDomain( M ), "^", M!.vectordim, " )" );
    end );


#############################################################################
##
#M  \in( <v>, <V> )
##
InstallMethod( \in,
    "method for full row module",
    IsElmsColls,
    [ IsRowVector, IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ],
    0,
    function( v, M )
    return     Length( v ) = M!.vectordim
           and IsSubset( LeftActingDomain( M ), v );
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . . .  for a canonical basis of a full row module
##
InstallMethod( BasisVectors,
    "method for canonical basis of a full row module",
    true,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisFullRowModule ], 0,
    function( B )
    B:= UnderlyingLeftModule( B );
    return IdentityMat( B!.vectordim, LeftActingDomain( B ) );
    end );


#############################################################################
##
#M  CanonicalBasis( <V> )
##
InstallMethod( CanonicalBasis, true,
    [ IsFreeLeftModule and IsFullRowModule ], 0,
    function( V )
    local B;
    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsCanonicalBasis
                            and IsCanonicalBasisFullRowModule
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
    end );


#############################################################################
##
#M  Coefficients( <B>, <v> )  . .  for a canonical basis of a full row module
##
InstallMethod( Coefficients,
    "method for canonical basis of a full row module",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasisFullRowModule, IsRowVector ], 0,
    function( B, v )
    local V, R;
    V:= UnderlyingLeftModule( B );
    R:= LeftActingDomain( V );
    if Length( v ) = V!.vectordim and IsSubset( R, v ) then
      return ShallowCopy( v );
    else
      return fail;
    fi;
    end );


#############################################################################
##
#R  IsEnumeratorOfFiniteFullRowModuleRep( <iter> )
##
IsEnumeratorOfFiniteFullRowModuleRep := NewRepresentation(
    "IsEnumeratorOfFiniteFullRowModuleRep",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "coeffsenum", "q", "zerovector" ] );


#############################################################################
##
#M  Position( <enum>, <elm>, 0 )  .  for enumerator of finite full row module
##
InstallOtherMethod( Position,
    "method for enumerator via canonical basis of a finite full row module",
    true,
#T ?
#T    [ IsList and IsEnumeratorOfFiniteFullRowModuleRep, IsRowVector,
    [ IsList and IsEnumeratorOfFiniteFullRowModuleRep, IsList,
      IsZeroCyc ], 0,
    function( e, v, zero )
    local n, i;
    n:= 0;
    for i in [ PositionNot( v, zero ) .. Length( v ) ] do
      n:= e!.q * n + Position( e!.coeffsenum, v[i], 0 ) - 1;
    od;
    return n + 1;
    end );


#############################################################################
##
#M  \[\]( <enum>, <n> ) . . . . . .  for enumerator of finite full row module
##
InstallMethod( \[\],
    "method for enumerator via canonical basis of a finite full row module",
    true,
    [ IsList and IsEnumeratorOfFiniteFullRowModuleRep,
      IsPosRat and IsInt ], 0,
    function( e, n )
    local v, i;
    v:= ShallowCopy( e!.zerovector );
    i:= Length( v );
    n:= n-1;
    while 0 < n do
      v[i]:= e!.coeffsenum[ RemInt( n, e!.q ) + 1 ];
      n:= QuoInt( n, e!.q );
      i:= i-1;
    od;
    return v;
    end );


#############################################################################
##
#R  IsEnumeratorOfInfiniteFullRowModuleRep( <iter> )
##
IsEnumeratorOfInfiniteFullRowModuleRep := NewRepresentation(
    "IsEnumeratorOfInfiniteFullRowModuleRep",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "dim", "coeffsenum" ] );


#############################################################################
##
#M  Position( <enum>, <elm>, 0 )  . .  for enumerator of inf. full row module
##
InstallOtherMethod( Position,
    "method for enumerator via canonical basis of an inf. full row module",
    true,
    [ IsList and IsEnumeratorOfInfiniteFullRowModuleRep, IsRowVector,
      IsZeroCyc ], 0,
    function( enum, vector, zero )
    local n,
          i,
          max,
          maxpos,
          pos,
          len;

    n:= Length( vector );
    if n <> enum!.dim then
      return fail;
    fi;

    # Replace the entries of 'vector' by their positions.
    vector:= List( vector, x -> Position( enum!.coeffsenum, x, 0 ) - 1 );

    # Find the maximal entry in the vector, and its number.
    max:= vector[1];
    for i in [ 2 .. n ] do
      if max < vector[i] then
        max:= vector[i];
      fi;
    od;
    if max = 0 then
      return 1;
    fi;

    # Compute the positions of 'max' in 'vector',
    maxpos:= [];
    for i in [ 1 .. n ] do
      if vector[i] = max then
        Add( maxpos, i-1 );
      fi;
    od;

    # Compute the number of those elements with same distribution
    # of 'max' as in 'vector' that come before 'vector'.
    pos:= 0;
    for i in [ n, n-1 .. 1 ] do
      if vector[i] <> max then
        pos:= pos * max + vector[i];
      fi;
    od;
    pos:= pos + 1;

    # Compute the number of those elements with smaller distribution
    # of 'max'.
    # Consider the following example.
    # 1   3 4     7
    # m ? m m ? ? m ? ... ?       ('vector', the '?' mean entries < 'm')
    # * * * * * * ? ? ... ?       gives (m+1)^6 m^{n-6}
    # * * * ? ? ? m ? ... ?       gives (m+1)^3 m^{n-3-1}
    # * * ? m ? ? m ? ... ?       gives (m+1)^2 m^{n-2-2}
    # ? ? m m ? ? m ? ... ?       gives (m+1)^0 m^{n-0-3}

    len:= Length( maxpos );
    for i in [ len, len-1 .. 1 ] do
      pos:= pos + ( max + 1 )^maxpos[i] * max^( n - len - maxpos[i] + i );
    od;

    return pos;
    end );


#############################################################################
##
#M  \[\]( <enum>, <n> ) . . . . .  for enumerator of infinite full row module
##
InstallMethod( \[\],
    "method for enumerator via canonical basis of a inf. full row module",
    true,
    [ IsList and IsEnumeratorOfInfiniteFullRowModuleRep,
      IsPosRat and IsInt ], 0,
    function( enum, N )

    local n,
          val,
          max,
          maxpos,
          pos,
          vector,
          i,
          quorem;

    # Catch the special case.
    n:= enum!.dim;
    if N = 1 then
      val:= enum!.coeffsenum[1];
      return List( [ 1 .. n ], x -> val );
    fi;

    # Compute the maximal entry of the element.
    max:= 1;
    while max^n < N do
      max:= max + 1;
    od;

    # Compute the positions of the maximal entry.
    maxpos:= [];
    repeat
      pos:= 0;
      val:= (max-1)^( n - Length( maxpos ) );
      while val < N do
        pos:= pos + 1;
        val:= val * max / ( max - 1 );
      od;
      if 0 < pos then
        N:= N - val * ( max - 1 ) / max;
        Add( maxpos, pos );
      fi;
    until pos = 0;
    maxpos:= Reversed( maxpos );

    # Compute the values of the element that are strictly smaller than 'max'.
    vector:= [];
    N:= N - 1;
    for i in [ 1 .. n ] do
      if i in maxpos then
        vector[i]:= max;
      else
        quorem:= QuotientRemainder( Integers, N, max-1 );
        vector[i]:= quorem[2] + 1;
        N:= quorem[1];
      fi;
    od;

    # Translate the positions to values.
    for i in [ 1 .. n ] do
      vector[i]:= enum!.coeffsenum[ vector[i] ];
    od;

    # Return the element.
    return vector;
    end );


#############################################################################
##
#M  EnumeratorByBasis( <B> )  . . . .  for canonical basis of full row module
##
InstallMethod( EnumeratorByBasis,
    "method for enumerator via canonical basis of a full row module",
    true,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisFullRowModule ], 0,
    function( B )

    local V, F;

    V:= UnderlyingLeftModule( B );
    F:= LeftActingDomain( V );

    if IsFinite( F ) then

      F:= Objectify( NewKind( FamilyObj( V ),
                              IsEnumeratorOfFiniteFullRowModuleRep ),
                     rec(
                          coeffsenum := Enumerator( F ),
                          q          := Size( F ),
                          zerovector := Zero( V )
                         ) );
      SetUnderlyingCollection( F, V );
      return F;

    elif IsFiniteDimensional( V ) then

      # The ring is infinite, use the canonical ordering of $\N_0^n$
      # as defined for the iterator.
      F:= Objectify( NewKind( FamilyObj( V ),
                              IsEnumeratorOfInfiniteFullRowModuleRep ),
                     rec(
                          dim        := Dimension( V ),
                          coeffsenum := Enumerator( F )
                         ) );
      SetUnderlyingCollection( F, V );
      return F;

    else
      Error( "not implemented for infinite dimensional free modules" );
    fi;

    end );


#############################################################################
##
#R  IsIteratorOfFiniteFullRowModuleRep( <iter> )
##
IsIteratorOfFiniteFullRowModuleRep := NewRepresentation(
    "IsIteratorOfFiniteFullRowModuleRep",
    IsComponentObjectRep,
    [ "dimension", "counter", "position", "q", "limit", "ringelements" ] );


#############################################################################
##
#M  NextIterator( <iter> )  . . . . .  for iterator of finite full row module
##
InstallMethod( NextIterator,
    "method for iterator w.r.t. canonical basis of finite full row module",
    true,
    [ IsIterator and IsIteratorOfFiniteFullRowModuleRep ], 0,
    function( iter )
    local pos;

    # Increase the counter.
    pos:= iter!.dimension;
    while iter!.counter[ pos ] = iter!.q do
      iter!.counter[ pos ]:= 1;
      pos:= pos - 1;
    od;
    iter!.counter[ pos ]:= iter!.counter[ pos ] + 1;

    # Return the linear combination.
    return iter!.ringelements{ iter!.counter };
    end );


#############################################################################
##
#M  IsDoneIterator( <iter> )  . . . .  for iterator of finite full row module
##
InstallMethod( IsDoneIterator, true,
    [ IsIterator and IsIteratorOfFiniteFullRowModuleRep ], 0,
    iter -> iter!.counter = iter!.limit );


#############################################################################
##
#R  IsIteratorOfInfiniteFullRowModuleRep( <iter> )
##
IsIteratorOfInfiniteFullRowModuleRep := NewRepresentation(
    "IsIteratorOfInfiniteFullRowModuleRep",
    IsComponentObjectRep,
    [ "dim", "maxentry", "vector", "coeffsenum" ] );


#############################################################################
##
#M  NextIterator( <iter> )  . . . . .  for iterator of finite full row module
##
InstallMethod( NextIterator,
    "method for iterator w.r.t. canonical basis of infinite full row module",
    true,
    [ IsIterator and IsIteratorOfInfiniteFullRowModuleRep ], 0,
    function( iter )
    local dim,        # dimension of the free module
          vector,     # positions of the coefficients in 'iter!.coeffsenum'
                      # of the previous element
          result,     # coefficients of the previous element
          max1,       # one less than the maximal entry in 'vector'
          max,        # maximal entry in 'vector'
          firstval,   # first entry in 'iter!.coeffsenum'
          i;          # loop variable

    # (Increase the counter.)

    dim      := iter!.dim;
    vector   := iter!.vector;
    result   := iter!.result;
    max1     := iter!.maxentry - 1;
    firstval := iter!.firstval;

    # If not all entries in 'vector' are 'max1' or 'max1 + 1' then
    # increase the counter formed by the positions with entry
    # different from 'max1 + 1', and return the result.
    for i in [ 1 .. dim ] do
      if vector[i] < max1 then
        vector[i]:= vector[i] + 1;
        result[i]:= iter!.coeffsenum[ vector[i] ];
        return ShallowCopy( result );
      elif vector[i] = max1 then
        vector[i]:= 1;
        result[i]:= firstval;
      fi;
    od;

    # Otherwise if all entries are 'max1 + 1', increase the maximum.
    max:= iter!.maxentry;
    if dim < PositionNot( vector, max ) then
      max:= max + 1;
      iter!.maxentry:= max;
      vector[1]:= max;
      iter!.maxval:= iter!.coeffsenum[ max ];
      result[1]:= iter!.maxval;
      for i in [ 2 .. dim ] do
        vector[i]:= 1;
        result[i]:= firstval;
      od;
      return ShallowCopy( result );
    fi;

    # Otherwise get the next start configuration with maximum 'max'.
    # (The entries of 'vector' are now either '1' or 'max'.)
    for i in [ 1 .. dim ] do
      if vector[i] = max then
        vector[i]:= 1;
        result[i]:= firstval;
      else
        vector[i]:= max;
        result[i]:= iter!.maxval;
        return ShallowCopy( result );
      fi;
    od;

    Assert( 2, true,
            "there should be a position with value different from 'max'" );
    end );


#############################################################################
##
#M  IsDoneIterator( <iter> )  . . . .  for iterator of finite full row module
##
InstallMethod( IsDoneIterator, true,
    [ IsIterator and IsIteratorOfInfiniteFullRowModuleRep ], 0,
    ReturnFalse );


#############################################################################
##
#M  IteratorByBasis( <B> )  . . . . . . for canon. basis of a full row module
##
InstallMethod( IteratorByBasis,
    "method for canonical basis of a full row module",
    true,
    [ IsBasis and IsCanonicalBasisFullRowModule ],
    0,
    function( B )

    local V,
          F,
          dim,
          counter,
          q,
          enum,
          vector,
          firstval,
          result;

    V:= UnderlyingLeftModule( B );
    dim:= Dimension( V );

    if dim = 0 then

      return TrivialIterator( Zero( V ) );

    elif IsFinite( LeftActingDomain( V ) ) then

      F:= LeftActingDomain( V );
      counter := List( [ 1 .. dim ], x -> 1 );
      counter[ Length( counter ) ]:= 0;
      q:= Size( F );

      return Objectify( NewKind( IteratorsFamily,
                                     IsIterator
                                 and IsIteratorOfFiniteFullRowModuleRep ),
                        rec(
                            dimension    := dim,
                            counter      := counter,
                            position     := 1,
                            q            := q,
                            limit        := List( [ 1 .. dim ], x -> q ),
                            ringelements := EnumeratorSorted( F )
                           ) );

    else

      enum:= Enumerator( LeftActingDomain( V ) );
      vector:= List( [ 1 .. dim ], x -> 0 );
#     vector[1]:= -1;
      firstval:= enum[1];
      result:= List( [ 1 .. dim ], x -> firstval );

      return Objectify( NewKind( IteratorsFamily,
                                     IsIterator
                                 and IsIteratorOfInfiniteFullRowModuleRep ),
                        rec(
                             dim        := dim,
                             vector     := vector,
                             result     := result,
                             coeffsenum := enum,
                             maxentry   := 0,
                             firstval   := firstval,
                             maxval     := firstval
                           ) );

    fi;
    end );


#############################################################################
##
#M  BasisOfDomain( <M> )  . . . . . . . . . . . . . . . . for full row module
##
InstallMethod( BasisOfDomain,
    "method for full row module",
    true,
    [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], SUM_FLAGS,
    CanonicalBasis );


#############################################################################
##
#E  modulrow.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



