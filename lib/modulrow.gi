#############################################################################
##
#W  modulrow.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains methods for *row modules*, that is,
##  free left modules consisting of row vectors.
##
##  Especially methods for *full row modules* $R^n$ are contained.
##
##  (See the file `modulmat.gi' for the methods for matrix modules.)
##
Revision.modulrow_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  FullRowModule( <R>, <n> )
##
InstallGlobalFunction( FullRowModule, function( R, n )

    local M;   # the free module record, result

    if not ( IsRing( R ) and IsInt( n ) and 0 <= n ) then
      Error( "usage: FullRowModule( <R>, <n> ) for ring <R>" );
    fi;

    if IsDivisionRing( R ) then
      M:= Objectify( NewType( CollectionsFamily( FamilyObj( R ) ),
                                  IsFreeLeftModule
                              and IsGaussianSpace
                              and IsFullRowModule
                              and IsAttributeStoringRep ),
                     rec() );
    else
      M:= Objectify( NewType( CollectionsFamily( FamilyObj( R ) ),
                                  IsFreeLeftModule
                              and IsFullRowModule
                              and IsAttributeStoringRep ),
                     rec() );
    fi;
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
#M  IsRowModule( <M> )
##
InstallMethod( IsRowModule,
    "for a free left module",
    [ IsFreeLeftModule ],
    function( M )
    local gens;
    gens:= GeneratorsOfLeftModule( M );
    return    ( IsEmpty( gens ) and IsRowVector( Zero( M ) ) )
           or IsMatrix( gens );
    end );


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
##
InstallMethod( Random,
    "for full row module",
    [ IsFreeLeftModule and IsFullRowModule ],
    function( M )
    local R;
    R:= LeftActingDomain( M );
    return List( [ 1 .. DimensionOfVectors( M ) ], x -> Random( R ) );
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
#R  IsEnumeratorOfFiniteFullRowModuleRep( <iter> )
##
DeclareRepresentation( "IsEnumeratorOfFiniteFullRowModuleRep",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "coeffsenum", "q", "zerovector", "coeffszero" ] );

#############################################################################
##
#R  IsEnumeratorOfFiniteFullRowModuleFFRep( <iter> )
##
DeclareRepresentation( "IsEnumeratorOfFiniteFullRowModuleFFRep",
    IsEnumeratorOfFiniteFullRowModuleRep,
    [ "coeffsenum", "q", "zerovector", "coeffszero" ] );


#############################################################################
##
#M  Position( <enum>, <elm>, 0 )  .  for enumerator of finite full row module
##
BindGlobal( "PosVecEnum", function( arg )
    local e, v, len, n, i, pos;

    e:= arg[1];
    v:= arg[2];
    len:= Length( v );
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

InstallMethod( Position,
    "for enumerator via canonical basis of a finite full row module",
    [ IsList and IsEnumeratorOfFiniteFullRowModuleRep, IsList,
      IsZeroCyc ], 0,PosVecEnum);

InstallMethod( PositionCanonical,
    "for enumerator via canonical basis of a finite full row module",
    [ IsList and IsEnumeratorOfFiniteFullRowModuleRep, IsList ],
    PosVecEnum);

BindGlobal("PosVecEnumFF",function(arg)
local v,i,l;
  v:=arg[2];
  # test whether the vector is indeed compact over a finite field
  if not IsDataObjectRep(v) then

    # the degree of the field extension q provides
    l:=LogInt(arg[1]!.q,Characteristic(v));
    for i in v do
      if not (IsFFE(i) and IsInt(l/DegreeFFE(i))) then
	TryNextMethod(); # cannot convert, wrong type of object
      fi;
    od;

    if ConvertToVectorRep(v,arg[1]!.q)=fail then
      TryNextMethod(); # cannot convert, wrong type of object
    fi;
  fi;
  # Problem with GF(4) vectors over GF(2)
  if (IsGF2VectorRep(v) and arg[1]!.q<>2)
     or (Is8BitVectorRep(v) and arg[1]!.q=2) then
    TryNextMethod();
  fi;

  # compute index via number
  v:=NumberFFVector(v,arg[1]!.q);
  if v=fail then
    return v;
  else
    return v+1;
  fi;
end);

InstallMethod( Position,
    "for enumerator via canonical basis, over built-in finite field",
    [ IsList and IsEnumeratorOfFiniteFullRowModuleFFRep, IsRowVector,
      IsZeroCyc ],
    PosVecEnumFF);

InstallMethod( PositionCanonical,
    "for enumerator via canonical basis, over built-in finite field",
    [ IsList and IsEnumeratorOfFiniteFullRowModuleFFRep, IsRowVector ],
    PosVecEnumFF);

#############################################################################
##
#M  \[\]( <enum>, <n> ) . . . . . .  for enumerator of finite full row module
##
InstallMethod( \[\],
    "for enumerator via canonical basis of a finite full row module",
    [ IsList and IsEnumeratorOfFiniteFullRowModuleRep,
      IsPosInt ],
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
    ConvertToVectorRep(v,e!.q);
    return v;
    end );


#############################################################################
##
#R  IsEnumeratorOfInfiniteFullRowModuleRep( <iter> )
##
DeclareRepresentation( "IsEnumeratorOfInfiniteFullRowModuleRep",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "dim", "coeffsenum" ] );


#############################################################################
##
#M  Position( <enum>, <elm>, 0 )  . .  for enumerator of inf. full row module
##
InstallOtherMethod( Position,
    "for enumerator via canonical basis of an inf. full row module",
    [ IsList and IsEnumeratorOfInfiniteFullRowModuleRep, IsRowVector,
      IsZeroCyc ],
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

    # Replace the entries of `vector' by their positions.
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
    # m ? m m ? ? m ? ... ?       ('vector', the `?' mean entries < `m')
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
    "for enumerator via canonical basis of a inf. full row module",
    [ IsList and IsEnumeratorOfInfiniteFullRowModuleRep,
      IsPosInt ],
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
    return vector;
    end );


#############################################################################
##
#M  EnumeratorByBasis( <B> )  . . . .  for canonical basis of full row module
##
InstallMethod( EnumeratorByBasis,
    "for enumerator via canonical basis of a full row module",
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisFullRowModule ],
    function( B )

    local V, F,filter;

    V:= UnderlyingLeftModule( B );
    F:= LeftActingDomain( V );

    if IsFinite( F ) then

      # By construction, the enumerator is sorted.
      filter:= IsEnumeratorOfFiniteFullRowModuleRep and IsSSortedList;

      if IsFinite(LeftActingDomain(V)) and IsPrimeInt(Size(LeftActingDomain(V)))
        and Size(LeftActingDomain(V))<256
	and IsInternalRep(One(LeftActingDomain(V))) then
	filter:=IsEnumeratorOfFiniteFullRowModuleFFRep and IsQuickPositionList;
      fi;

      F:= Objectify( NewType( FamilyObj( V ), filter ),
                     rec(
                          coeffsenum := Enumerator( F ),
                          q          := Size( F ),
			  coeffszero := Zero(F),
                          zerovector := Zero( V )
                         ) );
      SetUnderlyingCollection( F, V );
      return F;

    elif IsFiniteDimensional( V ) then

      # The ring is infinite, use the canonical ordering of $\N_0^n$
      # as defined for the iterator.
      F:= Objectify( NewType( FamilyObj( V ),
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
DeclareRepresentation( "IsIteratorOfFiniteFullRowModuleRep",
    IsComponentObjectRep,
    [ "dimension", "counter", "position", "q", "limit", "ringelements" ] );


#############################################################################
##
#M  NextIterator( <iter> )  . . . . .  for iterator of finite full row module
##
InstallMethod( NextIterator,
    "for mutable iterator w.r.t. canonical basis of finite full row module",
    [ IsIterator and IsMutable and IsIteratorOfFiniteFullRowModuleRep ],
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
InstallMethod( IsDoneIterator,
    "for iterator w.r.t. canonical basis of finite full row module",
    [ IsIterator and IsIteratorOfFiniteFullRowModuleRep ],
    iter -> iter!.counter = iter!.limit );


#############################################################################
##
#M  ShallowCopy( <iter> ) . . . . . .  for iterator of finite full row module
##
InstallMethod( ShallowCopy,
    "for iterator w.r.t. canonical basis of finite full row module",
    [ IsIterator and IsIteratorOfFiniteFullRowModuleRep ],
    iter -> Objectify( Subtype( TypeObj( iter ), IsMutable ),
                       rec( dimension    := iter!.dim,
                            counter      := ShallowCopy( iter!.counter ),
                            position     := iter!.position,
                            q            := iter!.q,
                            limit        := ShallowCopy( iter!.limit ),
                            ringelements := iter!.ringelements ) ) );


#############################################################################
##
#R  IsIteratorOfInfiniteFullRowModuleRep( <iter> )
##
DeclareRepresentation( "IsIteratorOfInfiniteFullRowModuleRep",
    IsComponentObjectRep,
    [ "dim", "maxentry", "vector", "coeffsenum", "result", "firstval",
      "maxval" ] );


#############################################################################
##
#M  NextIterator( <iter> )  . . . . .  for iterator of finite full row module
##
InstallMethod( NextIterator,
    "for mutable iterator w.r.t. canon. basis of infinite full row module",
    [ IsIterator and IsMutable and IsIteratorOfInfiniteFullRowModuleRep ],
    function( iter )
    local dim,        # dimension of the free module
          vector,     # positions of the coefficients in `iter!.coeffsenum'
                      # of the previous element
          result,     # coefficients of the previous element
          max1,       # one less than the maximal entry in `vector'
          max,        # maximal entry in `vector'
          firstval,   # first entry in `iter!.coeffsenum'
          i;          # loop variable

    # (Increase the counter.)

    dim      := iter!.dim;
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


#############################################################################
##
#M  IsDoneIterator( <iter> )  . . . .  for iterator of finite full row module
##
InstallMethod( IsDoneIterator,
    "for iterator w.r.t. canonical basis of finite full row module",
    [ IsIterator and IsIteratorOfInfiniteFullRowModuleRep ],
    ReturnFalse );


#############################################################################
##
#M  ShallowCopy( <iter> ) . . . . . .  for iterator of finite full row module
##
InstallMethod( ShallowCopy,
    "for iterator w.r.t. canonical basis of finite full row module",
    [ IsIterator and IsIteratorOfInfiniteFullRowModuleRep ],
    iter -> Objectify( Subtype( TypeObj( iter ), IsMutable ),
                       rec(
                             dim        := iter!.dim,
                             vector     := ShallowCopy( iter!.vector ),
                             result     := ShallowCopy( iter!.result ),
                             coeffsenum := iter!.coeffsenum,
                             maxentry   := iter!.maxentry,
                             firstval   := iter!.firstval,
                             maxval     := iter!.maxval
                           ) ) );


#############################################################################
##
#M  IteratorByBasis( <B> )  . . . . . . for canon. basis of a full row module
##
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

      return Objectify( NewType( IteratorsFamily,
                                     IsIterator
                                 and IsMutable
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

      return Objectify( NewType( IteratorsFamily,
                                     IsIterator
                                 and IsMutable
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
#M  Basis( <M> )  . . . . . . . . . . . . . . . . . . . . for full row module
##
InstallMethod( Basis,
    "for full row module",
    [ IsFreeLeftModule and IsFullRowModule ], SUM_FLAGS,
    CanonicalBasis );


#############################################################################
##
#E

