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
##  This file contains methods for *row modules*, that is,
##  free left modules consisting of row vectors.
##
##  Especially methods for *full row modules* $R^n$ are contained.
##
##  (See the file `modulmat.gi' for the methods for matrix modules.)
##


#############################################################################
##
#F  FullRowModule( <R>, <n> )
##
InstallGlobalFunction( FullRowModule, function( R, n )
local M,typ;   # the free module record, result

    if not ( IsRing( R ) and IsInt( n ) and 0 <= n ) then
      Error( "usage: FullRowModule( <R>, <n> ) for ring <R>" );
    fi;

    typ:=IsFreeLeftModule and IsFullRowModule and IsAttributeStoringRep
         and HasIsEmpty;

    if IsDivisionRing( R ) then
      typ:=typ and IsGaussianSpace;
    fi;

    if n=0 then
      typ:=typ and IsTrivial;
    else
      typ:=typ and IsNonTrivial;
    fi;

    if n<>infinity and HasIsFinite(R) and IsFinite(R) then
      typ:=typ and IsFinite;
    elif n<>0 and HasIsFinite(R) and not IsFinite(R) then
      typ:=typ and HasIsFinite;
    fi;


    M:= Objectify( NewType( CollectionsFamily( FamilyObj( R ) ),
                            typ ),
                    rec() );

    SetLeftActingDomain( M, R );
    SetDimensionOfVectors( M, n );

    return M;
end );


#############################################################################
##
#M  \^( <R>, <n> )  . . . . . . . . . . . . . . . full row module over a ring
##
InstallOtherMethod( \^,
    "for ring and integer (delegate to `FullRowModule')",
    [ IsRing, IsInt ],
    FullRowModule );


#############################################################################
##
#M  IsRowModule .  return `false' for objects which are not free left modules
##
InstallOtherMethod( IsRowModule,
    "return `false' for objects which are not free left modules",
    true, [ IsObject ], 0,
    function ( obj )
    if not IsFreeLeftModule(obj) then
        return false;
    else
        TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsRowModule( <M> )
##
InstallMethod( IsRowModule,
    "for a free left module",
    [ IsFreeLeftModule ],
    M -> IsRowVector( Zero( M ) ) );


#############################################################################
##
#M  IsFullRowModule( M )
##
InstallMethod( IsFullRowModule,
    "for free left (row) module",
    [ IsFreeLeftModule ],
    M ->     IsRowModule( M )
         and Dimension( M ) = DimensionOfVectors( M )
         and ForAll( GeneratorsOfLeftModule( M ),
                     v -> IsSubset( LeftActingDomain( M ), v ) ) );


#############################################################################
##
#M  Dimension( <M> )
##
InstallMethod( Dimension,
    "for full row module",
    [ IsFreeLeftModule and IsFullRowModule ],
    DimensionOfVectors );


#############################################################################
##
#M  Random( <M> )
##1
InstallMethodWithRandomSource( Random,
    "for a random source and a full row module",
    [ IsRandomSource, IsFreeLeftModule and IsFullRowModule ],
    function( rs, M )
    local R,v;
    R:= LeftActingDomain( M );
    v := List( [ 1 .. DimensionOfVectors( M ) ], x -> Random( rs, R ) );
    if IsField(R) then
      if IsHPCGAP then
        if Size(R) <= 256 then
          v := CopyToVectorRep(v,Size(R));
        fi;
      else
        ConvertToVectorRep(v,R);
      fi;
    fi;
    return v;
    end );


#############################################################################
##
#M  Representative( <M> )
##
InstallMethod( Representative,
    "for full row module",
    [ IsFreeLeftModule and IsFullRowModule ],
    M -> ListWithIdenticalEntries( DimensionOfVectors( M ),
                                   Zero( LeftActingDomain( M ) ) ) );


#############################################################################
##
#M  GeneratorsOfLeftModule( <V> )
##
InstallMethod( GeneratorsOfLeftModule,
    "for full row module",
    [ IsFreeLeftModule and IsFullRowModule ],
    M -> IdentityMat( DimensionOfVectors( M ), LeftActingDomain( M ) ) );


#############################################################################
##
#M  ViewObj( <M> )
##
InstallMethod( ViewObj,
    "for full row module",
    [ IsFreeLeftModule and IsFullRowModule ],
    function( M )
    Print( "( " );
    View( LeftActingDomain( M ) );
    Print( "^", DimensionOfVectors( M ), " )" );
    end );


#############################################################################
##
#M  ViewString( <M> ) . . . . . . . . . . . . . . . . .  for full row modules
##
InstallMethod( ViewString, "for full row modules", true,
               [ IsFreeLeftModule and IsFullRowModule ], 0, String );


#############################################################################
##
#M  PrintObj( <M> )
##
InstallMethod( PrintObj,
    "for full row module",
    [ IsFreeLeftModule and IsFullRowModule ],
    function( M )
    Print( "( ", LeftActingDomain( M ), "^", DimensionOfVectors( M ), " )" );
    end );


#############################################################################
##
#M  String( <M> ) . . . . . . . . . . . . . . . . . . .  for full row modules
##
InstallMethod( String, "for full row modules", true,
               [ IsFreeLeftModule and IsFullRowModule ], 0,
  M -> Concatenation(List(["( ",LeftActingDomain(M),"^",
                                DimensionOfVectors(M)," )"], String)) );


#############################################################################
##
#M  \in( <v>, <V> )
##
InstallMethod( \in,
    "for full row module",
    IsElmsColls,
    [ IsRowVector, IsFreeLeftModule and IsFullRowModule ],
    function( v, M )
    return     Length( v ) = DimensionOfVectors( M )
           and IsSubset( LeftActingDomain( M ), v );
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . . .  for a canonical basis of a full row module
##
InstallMethod( BasisVectors,
    "for canonical basis of a full row module",
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisFullRowModule ],
    function( B )
    B:= UnderlyingLeftModule( B );
    return IdentityMat( DimensionOfVectors( B ), LeftActingDomain( B ) );
    end );


#############################################################################
##
#M  CanonicalBasis( <V> )
##
InstallMethod( CanonicalBasis,
    "for a full row module",
    [ IsFreeLeftModule and IsFullRowModule ],
    function( V )
    local B;
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasis
                            and IsCanonicalBasisFullRowModule
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
    end );


#############################################################################
##
#M  Basis( <M> )  . . . . . . . . . . . . . . . . . . . . for full row module
##
InstallMethod( Basis,
    "for full row module (delegate to `CanonicalBasis')",
    [ IsFreeLeftModule and IsFullRowModule ], CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#M  Coefficients( <B>, <v> )  . .  for a canonical basis of a full row module
##
InstallMethod( Coefficients,
    "for canonical basis of a full row module",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasisFullRowModule, IsRowVector ],
    function( B, v )
    local V, R;
    V:= UnderlyingLeftModule( B );
    R:= LeftActingDomain( V );
    if Length( v ) = DimensionOfVectors( V ) and IsSubset( R, v ) then
      return ShallowCopy( v );
    else
      return fail;
    fi;
    end );


#############################################################################
##
#M  IsCanonicalBasisFullRowModule( <B> )  . . . . . . . . . . . . for a basis
##
InstallMethod( IsCanonicalBasisFullRowModule,
    "for a basis",
    [ IsBasis ],
    B ->     IsFullRowModule( UnderlyingLeftModule( B ) )
         and IsCanonicalBasis( B ) );


#############################################################################
##
#M  EnumeratorByBasis( <B> )  . . . .  for canonical basis of full row module
##
BindGlobal( "NumberElement_FiniteFullRowModule", function( e, v )
    local len, n, i, pos;

    if not IsDenseList( v ) then
      return fail;
    fi;
    len:= Length( v );
    if len <> e!.dimension then
      return fail;
    fi;
    n:= 0;
    i:= 1;

    while i <= len and v[i] = e!.coeffszero do
      i:= i+1;
    od;

    while i <= len do
      pos:= Position( e!.coeffsenum, v[i], 0 );
      if pos = fail then
        return fail;
      fi;
      n:= e!.q * n + pos - 1;
      i:= i+1;
    od;

    return n + 1;
end );

BindGlobal( "PosVecEnumFF", function( enum, v )
    local i,l;

    if    not IsCollsElms( FamilyObj( enum ), FamilyObj( v ) )
       or not IsRowVector( v )
       or Length( v ) <> enum!.dimension then
      return fail;
    fi;

  # test whether the vector is indeed compact over a finite field
  if not IsDataObjectRep(v) then

    # the degree of the field extension q provides
    l:= LogInt( enum!.q, Characteristic(v) );
    for i in v do
      if not (IsFFE(i) and IsInt(l/DegreeFFE(i))) then
        # cannot convert, wrong type of object
        return NumberElement_FiniteFullRowModule( enum, v );
      fi;
    od;

    v := ImmutableVector( enum!.q, v );
    if not IsDataObjectRep(v) then
      # cannot convert, wrong type of object
      return NumberElement_FiniteFullRowModule( enum, v );
    fi;
  fi;
  # Problem with GF(4) vectors over GF(2)
  if ( IsGF2VectorRep(v) and enum!.q <> 2 )
     or ( Is8BitVectorRep(v) and enum!.q = 2 ) then
    return NumberElement_FiniteFullRowModule( enum, v );
  fi;

  # compute index via number
  v:= NumberFFVector( v, enum!.q );
  if v <> fail then
    v:= v+1;
  fi;
  return v;
end);

BindGlobal( "ElementNumber_FiniteFullRowModule", function( enum, n )
    local v, i;

    if Size( enum ) < n then
      Error( "<enum>[", n, "] must have an assigned value" );
    fi;
    v:= ShallowCopy( enum!.zerovector );
    i:= Length( v );
    n:= n-1;
    while 0 < n do
      v[i]:= enum!.coeffsenum[ RemInt( n, enum!.q ) + 1 ];
      n:= QuoInt( n, enum!.q );
      i:= i-1;
    od;
    if IsFFE( enum!.coeffszero ) then
      v := ImmutableVector( enum!.q, v );
    fi;
    MakeImmutable( v );
    return v;
    end );


BindGlobal( "NumberElement_InfiniteFullRowModule", function( enum, vector )
    local n,
          i,
          max,
          maxpos,
          pos,
          len;

    if not IsCollsElms( FamilyObj( enum ), FamilyObj( vector ) )
       or not IsList( vector ) then
      return fail;
    fi;
    n:= Length( vector );
    if n <> enum!.dimension then
      return fail;
    fi;

    # Replace the entries of `vector' by their positions.
    vector:= List( vector, x -> Position( enum!.coeffsenum, x, 0 ) );
    if fail in vector then
      return fail;
    fi;
    vector:= vector - 1;

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

    # Compute the positions of `max' in `vector',
    maxpos:= [];
    for i in [ 1 .. n ] do
      if vector[i] = max then
        Add( maxpos, i-1 );
      fi;
    od;

    # Compute the number of those elements with same distribution
    # of `max' as in `vector' that come before `vector'.
    pos:= 0;
    for i in [ n, n-1 .. 1 ] do
      if vector[i] <> max then
        pos:= pos * max + vector[i];
      fi;
    od;
    pos:= pos + 1;

    # Compute the number of those elements with smaller distribution
    # of `max'.
    # Consider the following example.
    # 1   3 4     7
    # m ? m m ? ? m ? ... ?       (`vector', the `?' mean entries < `m')
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


BindGlobal( "ElementNumber_InfiniteFullRowModule", function( enum, N )
    local n,
          val,
          max,
          maxpos,
          pos,
          vector,
          i,
          quorem;

    # Catch the special case.
    n:= enum!.dimension;
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

    # Compute the values of the element that are strictly smaller than `max'.
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
    return Immutable( vector );
    end );


InstallMethod( EnumeratorByBasis,
    "for enumerator via canonical basis of a full row module",
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisFullRowModule ],
    function( B )
    local V, F, enum;

    V:= UnderlyingLeftModule( B );
    F:= LeftActingDomain( V );

    if IsFinite( F ) then

      enum:= EnumeratorByFunctions( V, rec(
                 ElementNumber := ElementNumber_FiniteFullRowModule,
                 NumberElement := NumberElement_FiniteFullRowModule,

                 coeffsenum    := Enumerator( F ),
                 q             := Size( F ),
                 coeffszero    := Zero( F ),
                 zerovector    := Zero( V ),
                 dimension     := Dimension( V ) ) );

      if IsField( F ) and Size( F ) < 256 and IsInternalRep( One( F ) ) then
        # Use a more efficient method for `Position'.
        enum!.NumberElement:= PosVecEnumFF;
        SetFilterObj( enum, IsQuickPositionList );
      fi;
      SetFilterObj( enum, IsSSortedList );

      return enum;

    elif IsFiniteDimensional( V ) then

      # The ring is infinite, use the canonical ordering of $\N_0^n$
      # as defined for the iterator.
      return EnumeratorByFunctions( V, rec(
                 ElementNumber := ElementNumber_InfiniteFullRowModule,
                 NumberElement := NumberElement_InfiniteFullRowModule,

                 dimension     := Dimension( V ),
                 coeffsenum    := Enumerator( F ) ) );

    else
      Error( "not implemented for infinite dimensional free modules" );
    fi;
    end );


#############################################################################
##
#M  IteratorByBasis( <B> )  . . . . . . for canon. basis of a full row module
##
BindGlobal( "NextIterator_FiniteFullRowModule", function( iter )
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

BindGlobal( "IsDoneIterator_FiniteFullRowModule",
    iter -> iter!.counter = iter!.limit );

BindGlobal( "ShallowCopy_FiniteFullRowModule",
    iter -> rec( dimension    := iter!.dimension,
                 counter      := ShallowCopy( iter!.counter ),
                 position     := iter!.position,
                 q            := iter!.q,
                 limit        := ShallowCopy( iter!.limit ),
                 ringelements := iter!.ringelements ) );

BindGlobal( "NextIterator_InfiniteFullRowModule", function( iter )
    local dim,        # dimension of the free module
          vector,     # positions of the coefficients in `iter!.coeffsenum'
                      # of the previous element
          result,     # coefficients of the previous element
          max1,       # one less than the maximal entry in `vector'
          max,        # maximal entry in `vector'
          firstval,   # first entry in `iter!.coeffsenum'
          i;          # loop variable

    # (Increase the counter.)

    dim      := iter!.dimension;
    vector   := iter!.vector;
    result   := iter!.result;
    max1     := iter!.maxentry - 1;
    firstval := iter!.firstval;

    # If not all entries in `vector' are `max1' or `max1 + 1' then
    # increase the counter formed by the positions with entry
    # different from `max1 + 1', and return the result.
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

    # Otherwise if all entries are `max1 + 1', increase the maximum.
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

    # Otherwise get the next start configuration with maximum `max'.
    # (The entries of `vector' are now either `1' or `max'.)
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
            "there should be a position with value different from `max'" );
    end );

BindGlobal( "ShallowCopy_InfiniteFullRowModule",
    iter -> rec( dim        := iter!.dimension,
                 vector     := ShallowCopy( iter!.vector ),
                 result     := ShallowCopy( iter!.result ),
                 coeffsenum := iter!.coeffsenum,
                 maxentry   := iter!.maxentry,
                 firstval   := iter!.firstval,
                 maxval     := iter!.maxval ) );

InstallMethod( IteratorByBasis,
    "for canonical basis of a full row module",
    [ IsBasis and IsCanonicalBasisFullRowModule ],
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

      return IteratorByFunctions( rec(
                 IsDoneIterator := IsDoneIterator_FiniteFullRowModule,
                 NextIterator   := NextIterator_FiniteFullRowModule,
                 ShallowCopy    := ShallowCopy_FiniteFullRowModule,

                 dimension      := dim,
                 counter        := counter,
                 position       := 1,
                 q              := q,
                 limit          := List( [ 1 .. dim ], x -> q ),
                 ringelements   := EnumeratorSorted( F ) ) );

    else

      enum:= Enumerator( LeftActingDomain( V ) );
      vector:= List( [ 1 .. dim ], x -> 0 );
#     vector[1]:= -1;
      firstval:= enum[1];
      result:= List( [ 1 .. dim ], x -> firstval );

      return IteratorByFunctions( rec(
                 IsDoneIterator := ReturnFalse,
                 NextIterator   := NextIterator_InfiniteFullRowModule,
                 ShallowCopy    := ShallowCopy_InfiniteFullRowModule,

                 dimension      := dim,
                 vector         := vector,
                 result         := result,
                 coeffsenum     := enum,
                 maxentry       := 0,
                 firstval       := firstval,
                 maxval         := firstval ) );

    fi;
    end );
