#############################################################################
##
#W  coll.gi                     GAP library                  Martin Schoenert
#W                                                            & Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for collections in general.
##
Revision.coll_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  CollectionsFamily(<F>)  . . . . . . . . . . . . . . . . .  generic method
##
InstallMethod( CollectionsFamily,
    "method for a family",
    true, [ IsFamily ], 90,
    function ( F )
    local   colls, coll_req, coll_imp, elms_flags, tmp;
    coll_req := IsCollection;
    coll_imp := IsObject;
    elms_flags := F!.IMP_FLAGS;
    for tmp  in CATEGORIES_COLLECTIONS  do
        if IS_SUBSET_FLAGS( elms_flags, FLAGS_FILTER( tmp[1] ) )  then
            coll_imp := coll_imp and tmp[2];
        fi;
    od;
    colls := NewFamily( "CollectionsFamily(...)", coll_req, coll_imp );
    SetElementsFamily( colls, F );
    return colls;
    end );


#############################################################################
##
#V  IteratorsFamily
##
IteratorsFamily := NewFamily( "IteratorsFamily", IsIterator );


#############################################################################
##
#M  PrintObj( <iter> )  . . . . . . . . . . . . . . . . . . print an iterator
##
InstallMethod( PrintObj,
    "method for an iterator",
    true, [ IsIterator ], 0,
    function( iter ) Print( "<iterator>" ); end );


#############################################################################
##
#M  IsEmpty(<C>)  . . . . . . . . . . . . . . . test if a collection is empty
##
InstallImmediateMethod( IsEmpty,
    IsCollection and HasSize, 0,
    function ( C )
    return (Size( C ) = 0);
    end );

InstallMethod( IsEmpty,
    "method for a collection",
    true, [ IsCollection ], 0,
    function ( C )
    return (Size( C ) = 0);
    end );

InstallMethod( IsEmpty,
    "method for a list",
    true, [ IsList ], 0,
    function ( list )
    return (Length( list ) = 0);
    end );
#T non-homogeneous lists should know that they are nonempty


#############################################################################
##
#M  IsTrivial(<C>)  . . . . . . . . . . . .  test if a collection ist trivial
##
InstallImmediateMethod( IsTrivial,
    IsCollection and HasSize, 0,
    function ( C )
    return (Size( C ) = 1);
    end );

InstallMethod( IsTrivial,
    "method for a collection",
    true, [ IsCollection ], 0,
    function ( C )
    return (Size( C ) = 1);
    end );


#############################################################################
##
#M  IsFinite(<C>) . . . . . . . . . . . . . .  test if a collection is finite
##
InstallImmediateMethod( IsFinite,
    IsCollection and HasSize, 0,
    function ( C )
    return not IsIdentical( Size( C ), infinity );
    end );

InstallMethod( IsFinite,
    "method for a collection",
    true,
    [ IsCollection ], 0,
    function ( C )
    return Size( C ) < infinity;
    end );


#############################################################################
##
#M  IsWholeFamily(<C>)  . . .  test if a collection contains the whole family
##
InstallMethod( IsWholeFamily,
    "method for a collection",
    true, [ IsCollection ], 0,
    function ( C )
    Error( "cannot test whether <C> contains the family of its elements" );
    end );


#############################################################################
##
#M  Size(<C>) . . . . . . . . . . . . . . . . . . . . .  size of a collection
##
InstallImmediateMethod( Size,
    IsCollection and HasIsFinite, 0,
    function ( C )
    if IsFinite( C ) then
        TryNextMethod();
    fi;
    return infinity;
    end );

InstallImmediateMethod( Size,
    IsCollection and HasAsList, 0,
    function ( C )
    return Length( AsList( C ) );
    end );

InstallMethod( Size,
    "method for a collection",
    true,
    [ IsCollection ], 0,
    function ( C )
    return Length( Enumerator( C ) );
    end );


#############################################################################
##
#M  Representative(<C>)
##
InstallMethod( Representative,
    "method for a collection",
    true, [ IsCollection ], 0,
    function ( C )
    local   elm;
    for elm in Enumerator( C ) do
        return elm;
    od;
    Error( "<C> must be nonempty to have a representative" );
    end );

InstallMethod( Representative,
    "method for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    function ( C )
    local   elm;
    for elm in C do
        return elm;
    od;
    Error( "<C> must be nonempty to have a representative" );
    end );

InstallImmediateMethod( RepresentativeSmallest,
    IsCollection and HasEnumeratorSorted, 1000,
    C -> EnumeratorSorted( C )[1] );

InstallImmediateMethod( RepresentativeSmallest,
    IsCollection and HasAsListSorted, 1000,
    C -> AsListSorted( C )[1] );

InstallMethod( RepresentativeSmallest,
    "method for a collection",
    true, [ IsCollection ], 0,
    function ( C )
    local   elm;
    for elm in EnumeratorSorted( C ) do
        return elm;
    od;
    Error( "<C> must be nonempty to have a representative" );
    end );


#############################################################################
##
#M  Random( <C> ) . . . . . . . . . . . . . . . . . . . . .  for a collection
##
##  The default function for random selection in a finite collection computes
##  an enumerator of <C> and selects a random element of this list using the
##  function 'RANDOM_LIST', which is a pseudo random number generator.
##
InstallMethod( Random,
    "method for a collection that is an internal list",
    true, [ IsCollection and IsList and IsInternalRep ], 100,
#T ?
    RANDOM_LIST );

InstallMethod( Random,
    "method for a collection",
    true, [ IsCollection ], 10,
    function ( C )
    if not IsFinite( C ) then
        TryNextMethod();
    fi;
    return RANDOM_LIST( Enumerator( C ) );
    end );


#############################################################################
##
#R  IsConstantTimeAccessListRep( <list> )
##
##  This is implied by 'IsList and InternalRep',
##  so all strings, Boolean lists, ranges, and internal plain lists are
##  in this representation.
##
##  But also enumerators can have this representation if they know about
##  constant time access to their elements.
##
IsConstantTimeAccessListRep := NewRepresentation(
    "IsConstantTimeAccessListRep", IsObject, [] );

InstallTrueMethod( IsConstantTimeAccessListRep, IsList and IsInternalRep );


#############################################################################
##
#M  AsList( <coll> )
##
InstallMethod( AsList,
    "method for a collection",
    true,
    [ IsCollection ],
    0,
    coll -> ConstantTimeAccessList( Enumerator( coll ) ) );

InstallMethod( AsList,
    "method for collections that are constant time access lists",
    true,
    [ IsCollection and IsConstantTimeAccessListRep ],
    0,
    Immutable );


#############################################################################
##
#M  AsListSorted( <coll> )
##
InstallMethod( AsListSorted,
    "method for a collection",
    true,
    [ IsCollection ],
    0,
    coll -> ConstantTimeAccessList( EnumeratorSorted( coll ) ) );

InstallOtherMethod( AsListSorted,
    "method for a collection that is a constant time access list",
    true,
    [ IsCollection and IsConstantTimeAccessListRep ],
    0,
    AsListSortedList );


#############################################################################
##
#M  Enumerator(<C>)
##
InstallImmediateMethod( Enumerator,
    IsCollection and HasAsList, 0,
    AsList );

InstallMethod( Enumerator,
    "method for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    Immutable );


#############################################################################
##
#M  PrintObj( <enum> )  . . . . . . . . . . . . . . . . . print an enumerator
##
InstallMethod( PrintObj,
    "method for an enumerator",
    true, [ IsEnumerator ], 0,
    function( enum )
    Print( "<enumerator>" );
    end );


#############################################################################
##
#M  IsBound( <enum>, <pos> )  . . . . . . . . . . . . . . . . for enumerators
##
InstallMethod( IsBound\[\],
    "method for a list and a positive integer",
    true, [ IsList, IsPosRat and IsInt ], 0,
    function( enum, pos )
    return enum[ pos ] <> fail;
    end );
#T is that reasonable at all?


#############################################################################
##
#M  EnumeratorSorted(<C>)
##
InstallImmediateMethod( EnumeratorSorted,
    IsCollection and HasAsListSorted, 0,
    AsListSorted );

InstallMethod( EnumeratorSorted,
    "method for a collection",
    true, [ IsCollection ], 0,
    coll -> AsListSortedList( Enumerator( coll ) ) );

InstallMethod( EnumeratorSorted,
    "method for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    AsListSortedList );


#############################################################################
##
#M  List( <coll> )
##
InstallMethod( List,
    "method for a collection",
    true, [ IsCollection ], 0,
    C -> ShallowCopy( Enumerator( C ) ) );

InstallMethod( List,
    "method for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    ShallowCopy );


#############################################################################
##
#M  List( <coll>, <func> )
##
InstallOtherMethod( List,
    "method for a list/collection, and a function",
    true, [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local   res, elm;
    res := [];
    for elm in C do
        Add( res, func( elm ) );
    od;
    return res;
    end );


#############################################################################
##
#M  ListSorted( <C> )
##
InstallMethod( ListSorted,
    "method for a collection",
    true, [ IsCollection ], 0,
    C -> ShallowCopy( EnumeratorSorted( C ) ) );

InstallMethod( ListSorted,
    "method for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    ListSortedList );


#############################################################################
##
#M  ListSorted( <C>, <func> )
##
InstallOtherMethod( ListSorted,
    "method for a collection, and a function",
    true, [ IsCollection, IsFunction ], 0,
    function ( C, func )
    return ListSortedList( List( C, func ) );
    end );


#############################################################################
##
#M  Iterator(<C>)
##
InstallMethod( Iterator,
    "method for a collection",
    true, [ IsCollection ], 0,
    C -> IteratorList( Enumerator( C ) ) );

InstallMethod( Iterator,
    "method for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    C -> IteratorList( C ) );

InstallOtherMethod( Iterator,
    "method for an iterator",
    true, [ IsIterator ], 0,
    IdFunc );
#T or change the for-loop to accept iterators?


#############################################################################
##
#M  IteratorSorted(<C>)
##
InstallMethod( IteratorSorted,
    "method for a collection",
    true, [ IsCollection ], 0,
    C -> IteratorList( EnumeratorSorted( C ) ) );

InstallMethod( IteratorSorted,
    "method for a collection that is a list",
    true, [ IsCollection and IsList ], 0,
    C -> IteratorList( ListSortedList( C ) ) );


#############################################################################
##
#R  IsTrivialIterator( <iter> )
##
IsTrivialIterator := NewRepresentation( "IsTrivialIterator",
    IsComponentObjectRep, [ "element", "isDone" ] );


#############################################################################
##
#F  TrivialIterator( <elm> )
##
TrivialIterator := function( elm )
    return Objectify( NewType( IteratorsFamily,
                               IsIterator and IsTrivialIterator ),
                      rec( element := elm, isDone := false ) );
end;

InstallMethod( IsDoneIterator,
    "method for a trivial iterator",
    true, [ IsIterator and IsTrivialIterator ], SUM_FLAGS,
    iter -> iter!.isDone );

InstallMethod( NextIterator,
    "method for a trivial iterator",
    true, [ IsIterator and IsTrivialIterator ], SUM_FLAGS,
    function( iter )
    iter!.isDone:= true;
    return iter!.element;
    end );

InstallMethod( Iterator,
    "method for a trivial collection",
    true, [ IsCollection and IsTrivial ], SUM_FLAGS,
    D -> TrivialIterator( Enumerator( D )[1] ) );


#############################################################################
##
#M  Sum( <C> )  . . . . . . . . . . . . . . . . . . . . for a list/collection
##
InstallMethod( Sum,
    "method for a list/collection",
    true,
    [ IsListOrCollection ], 0,
    function ( C )
    local   sum;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        sum := NextIterator( C );
        while not IsDoneIterator( C ) do
            sum := sum + NextIterator( C );
        od;
    else
        sum := 0;
    fi;
    return sum;
    end );


#############################################################################
##
#M  Sum( <C>, <func> )  . . . . . . . . for a list/collection, and a function
##
InstallOtherMethod( Sum,
    "method for a list/collection, and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local   sum;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        sum := func( NextIterator( C ) );
        while not IsDoneIterator( C ) do
            sum := sum + func( NextIterator( C ) );
        od;
    else
        sum := 0;
    fi;
    return sum;
    end );


#############################################################################
##
#M  Sum( <C>, <init> )  . . . . . . .  for a list/collection, and init. value
##
InstallOtherMethod( Sum,
    "method for a list/collection, and init. value",
    true,
    [ IsListOrCollection, IsAdditiveElement ], 0,
    function ( C, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init + NextIterator( C );
    od;
    return init;
    end );


#############################################################################
##
#M  Sum( <C>, <func>, <init> )  . . for a list/coll., a func., and init. val.
##
InstallOtherMethod( Sum,
    "method for a list/collection, and a function, and an initial value",
    true,
    [ IsListOrCollection, IsFunction, IsAdditiveElement ], 0,
    function ( C, func, init )
    local   sum, i;
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init + func( NextIterator( C ) );
    od;
    return init;
    end );


#############################################################################
##
#M  Product( <C> )  . . . . . . . . . . . . . . . . . . for a list/collection
##
InstallMethod( Product,
    "method for a list/collection",
    true,
    [ IsListOrCollection ], 0,
    function ( C )
    local   prod;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        prod := NextIterator( C );
        while not IsDoneIterator( C ) do
            prod := prod * NextIterator( C );
        od;
    else
        prod := 1;
    fi;
    return prod;
    end );


#############################################################################
##
#M  Product( <C>, <func> )  . . . . . . for a list/collection, and a function
##
InstallOtherMethod( Product,
    "method for a list/collection, and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local   prod, i;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        prod := func( NextIterator( C ) );
        while not IsDoneIterator( C ) do
            prod := prod * func( NextIterator( C ) );
        od;
    else
        prod := 1;
    fi;
    return prod;
    end );


#############################################################################
##
#M  Product( <C>, <init> )  . . . . .  for a list/collection, and init. value
##
InstallOtherMethod( Product,
    "method for a list/collection, and initial value",
    true,
    [ IsListOrCollection, IsMultiplicativeElement ], 0,
    function ( C, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init * NextIterator( C );
    od;
    return init;
    end );


#############################################################################
##
#M  Product( <C>, <func>, <init> )  . . . . for list/coll., func., init. val.
##
InstallOtherMethod( Product,
    "method for a list/collection, a function, and an initial value",
    true,
    [ IsListOrCollection, IsFunction, IsMultiplicativeElement ], 0,
    function ( C, func, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init * func( NextIterator( C ) );
    od;
    return init;
    end );


#############################################################################
##
#F  ProductMod(<l>,<m>) . . . . . . . . . . . . . . . . . .  Product(l) mod m
##
ProductMod := function(l,m)
local i,p;
  if l=[] then
    p:=1; 
  else
    p:=l[1]^0;
  fi;
  for i in l do
    p:=p*i mod m;
  od;
  return p;
end;


#############################################################################
##
#M  Filtered(<C>,<func>)  . . . . . . . extract elements that have a property
##
InstallMethod( Filtered,
    "method for a list/collection, and a function",
    true, [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local res, elm;
    res := [];
    for elm in C do
        if func( elm ) then
            Add( res, elm );
        fi;
    od;
    return res;
    end );

InstallMethod( Filtered,
    "method for an empty list/collection, and a function",
    true, [ IsEmpty, IsFunction ], SUM_FLAGS,
    function( list, func )
    return [];
    end );


#############################################################################
##
#M  Number( <C>, <func> ) . . . . . . . . count elements that have a property
##
InstallMethod( Number,
    "method for a list/collection, and a function",
    true, [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local nr, elm;
    nr := 0;
    for elm in C do
        if func( elm ) then
            nr:= nr + 1;
        fi;
    od;
    return nr;
    end );


#############################################################################
##
#M  Number( <C> ) . . . . . . . . . . . . count elements that have a property
##
InstallOtherMethod( Number,
    "method for a list/collection",
    true,
    [ IsListOrCollection ], 0,
    function ( C )
    local nr, elm;
    nr := 0;
    for elm in C do
        nr := nr + 1;
    od;
    return nr;
    end );


#############################################################################
##
#M  ForAll(<C>,<func>)  . . . . .  test a property for all elements of a list
##
InstallMethod( ForAll,
    "method for a list/collection, and a function",
    true, [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local elm;
    for elm in C do
        if not func( elm ) then
            return false;
        fi;
    od;
    return true;
    end );

InstallOtherMethod( ForAll,
    "method for an empty list/collection, and a function",
    true,
    [ IsEmpty, IsFunction ], SUM_FLAGS,
    ReturnTrue );


#############################################################################
##
#M  ForAny(<C>,<func>)  . . . . . . test a property for any element of a list
##
InstallMethod( ForAny,
    "method for a list/collection, and a function",
    true, [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local elm;
    for elm in C do
        if func( elm ) then
            return true;
        fi;
    od;
    return false;
    end );

InstallOtherMethod( ForAny,
    "method for an empty list/collection, and a function",
    true,
    [ IsEmpty, IsFunction ], SUM_FLAGS,
    ReturnFalse );


#############################################################################
##
#M  ListX(<obj>,...)
##
ListXHelp := function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                ListXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    Add( result, CallFuncList( gens[i+1], vals ) );
end;

ListXHelp2 := function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                ListXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    Add( result, gens[i+1]( val1, val2 ) );
end;

ListXHelp1 := function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val2  in gen  do
                ListXHelp2( result, gens, i+1, val1, val2 );
            od;
            return;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    Add( result, gens[i+1]( val1 ) );
end;

ListXHelp0 := function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val1  in gen  do
                ListXHelp1( result, gens, i+1, val1 );
            od;
            return;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    Add( result, gens[i+1]() );
end;

ListX := function ( arg )
    local   result;
    result := [];
    ListXHelp0( result, arg, 0 );
    return result;
end;


#############################################################################
##
#M  SetX(<obj>,...)
##
SetXHelp := function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                SetXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    AddSet( result, CallFuncList( gens[i+1], vals ) );
end;

SetXHelp2 := function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                SetXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    AddSet( result, gens[i+1]( val1, val2 ) );
end;

SetXHelp1 := function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val2  in gen  do
                SetXHelp2( result, gens, i+1, val1, val2 );
            od;
            return;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    AddSet( result, gens[i+1]( val1 ) );
end;

SetXHelp0 := function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsCollection( gen )  then
            for val1  in gen  do
                SetXHelp1( result, gens, i+1, val1 );
            od;
            return;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    AddSet( result, gens[i+1]() );
end;

SetX := function ( arg )
    local   result;
    result := [];
    SetXHelp0( result, arg, 0 );
    return result;
end;


#############################################################################
##
#M  SumX(<obj>,...)
##
SumXHelp := function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                result := SumXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return result;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    if result = fail then
        result := CallFuncList( gens[i+1], vals );
    else
        result := result + CallFuncList( gens[i+1], vals );
    fi;
    return result;
end;

SumXHelp2 := function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                result := SumXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return result;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1, val2 );
    else
        result := result + gens[i+1]( val1, val2 );
    fi;
    return result;
end;

SumXHelp1 := function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val2  in gen  do
                result := SumXHelp2( result, gens, i+1, val1, val2 );
            od;
            return result;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1 );
    else
        result := result + gens[i+1]( val1 );
    fi;
    return result;
end;

SumXHelp0 := function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val1  in gen  do
                result := SumXHelp1( result, gens, i+1, val1 );
            od;
            return result;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    if result = fail then
        result := gens[i+1]();
    else
        result := result + gens[i+1]();
    fi;
    return result;
end;

SumX := function ( arg )
    local   result;
    result := fail;
    result := SumXHelp0( result, arg, 0 );
    return result;
end;


#############################################################################
##
#M  ProductX(<obj>,...)
##
ProductXHelp := function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                result := ProductXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return result;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    if result = fail then
        result := CallFuncList( gens[i+1], vals );
    else
        result := result * CallFuncList( gens[i+1], vals );
    fi;
    return result;
end;

ProductXHelp2 := function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                result := ProductXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return result;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1, val2 );
    else
        result := result * gens[i+1]( val1, val2 );
    fi;
    return result;
end;

ProductXHelp1 := function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val2  in gen  do
                result := ProductXHelp2( result, gens, i+1, val1, val2 );
            od;
            return result;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1 );
    else
        result := result * gens[i+1]( val1 );
    fi;
    return result;
end;

ProductXHelp0 := function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsCollection( gen )  then
            for val1  in gen  do
                result := ProductXHelp1( result, gens, i+1, val1 );
            od;
            return result;
        else
            Error("gens[",i+1,"] must be a list, a boolean, or a function");
        fi;
    od;
    if result = fail then
        result := gens[i+1]();
    else
        result := result * gens[i+1]();
    fi;
    return result;
end;

ProductX := function ( arg )
    local   result;
    result := fail;
    result := ProductXHelp0( result, arg, 0 );
    return result;
end;


#############################################################################
##
#M  IsSubset( <C1>, <C2> )
##
InstallMethod( IsSubset,
    "method for two collections in different families",
    IsNotIdentical,
    [ IsCollection,
      IsCollection ],
    0,
    ReturnFalse );

InstallMethod( IsSubset,
    "method for empty list and collection",
    true,
    [ IsList and IsEmpty,
      IsCollection ],
    0,
    function( empty, coll )
    return IsEmpty( coll );
    end );

InstallMethod( IsSubset,
    "method for collection and empty list",
    true,
    [ IsCollection,
      IsList and IsEmpty ],
    0,
    ReturnTrue );

InstallMethod( IsSubset,
    "method for two collections, the first containing the whole family",
    IsIdentical,
    [ IsCollection and IsWholeFamily,
      IsCollection ], 
    SUM_FLAGS+2,
    ReturnTrue );


InstallMethod( IsSubset,
    "method for two collections, check for identity",
    IsIdentical, 
    [ IsCollection,
      IsCollection ],
    SUM_FLAGS+1,

function ( D, E )
    if not IsIdentical( D, E ) then
        TryNextMethod();
    fi;
    return true;
end );


InstallMethod( IsSubset,
    "method for two collections with known sizes, check sizes",
    IsIdentical, 
    [ IsCollection and HasSize,
      IsCollection and HasSize ],
    SUM_FLAGS,

function ( D, E )
    if Size( E ) <= Size( D ) then
        TryNextMethod();
    fi;
    return false;
end );


InstallOtherMethod( IsSubset,
    "method for two internal lists",
    IsIdentical,
    [ IsList and IsInternalRep,
      IsList and IsInternalRep ],
    0,
    IsSubsetSet );


InstallMethod( IsSubset,
    "method for two collections that are internal lists",
    IsIdentical,
    [ IsCollection and IsList and IsInternalRep,
      IsCollection and IsList and IsInternalRep ], 0,
    IsSubsetSet );


InstallMethod( IsSubset,
    "method for two collections with known 'AsListSorted'",
    IsIdentical,
    [ IsCollection and HasAsListSorted,
      IsCollection and HasAsListSorted ],
    0,

function ( D, E )
    return IsSubsetSet( AsListSorted( D ), AsListSorted( E ) );
end );


InstallMethod( IsSubset,
    "method for two collections (loop over the elements of the second)",
    IsIdentical,
    [ IsCollection,
      IsCollection ],
    0,

function( D, E )
    return ForAll( E, e -> e in D );
end );


#############################################################################
##
#M  Intersection( <C>, ... )
##
IntersectionSet := function ( C1, C2 )
    local   I;
    if Length( C1 ) < Length( C2 ) then
        I := Set( C1 );
        IntersectSet( I, C2 );
    else
        I := Set( C2 );
        IntersectSet( I, C1 );
    fi;
    return I;
end;

InstallOtherMethod( Intersection2,
    "method for two lists",
    true, [ IsList, IsList ], 0,
    IntersectionSet );

InstallMethod( Intersection2,
    "method for two collections that are lists",
    IsIdentical,
    [ IsCollection and IsList, IsCollection and IsList ], 0,
    IntersectionSet );

InstallMethod( Intersection2,
    "method for two collections, the second being a list",
    IsIdentical, [ IsCollection, IsCollection and IsList ], 0,
    function ( C1, C2 )
    local   I, elm;
    if IsFinite( C1 ) then
        I := ShallowCopy( AsListSorted( C1 ) );
        IntersectSet( I, C2 );
    else
        I := [];
        for elm in C2 do
            if elm in C1 then
                AddSet( I, elm );
            fi;
        od;
    fi;
    return I;
    end );

InstallMethod( Intersection2,
    "method for two collections, the first being a list",
    IsIdentical, [ IsCollection and IsList, IsCollection ], 0,
    function ( C1, C2 )
    local   I, elm;
    if IsFinite( C2 ) then
        I := ShallowCopy( AsListSorted( C2 ) );
        IntersectSet( I, C1 );
    else
        I := [];
        for elm in C1 do
            if elm in C2 then
                AddSet( I, elm );
            fi;
        od;
    fi;
    return I;
    end );

InstallMethod( Intersection2,
    "method for two collections",
    IsIdentical, [ IsCollection, IsCollection ], 0,
    function ( C1, C2 )
    local   I, elm;
    if IsFinite( C1 ) then
        if IsFinite( C2 ) then
            I := ShallowCopy( AsListSorted( C1 ) );
            IntersectSet( I, AsListSorted( C2 ) );
        else
            I := [];
            for elm in C1 do
                if elm in C2 then
                    AddSet( I, elm );
                fi;
            od;
        fi;
    elif IsFinite( C2 ) then
        I := [];
        for elm in C2 do
            if elm in C1 then
                AddSet( I, elm );
            fi;
        od;
    else
        TryNextMethod();
    fi;
    return I;
    end );

Intersection := function ( arg )
    local   I,          # intersection, result
            D,          # domain or list, running over the arguments
            copied,     # true if I is a list not identical to anything else
            i;          # loop variable

    # unravel the argument list if necessary
    if Length(arg) = 1  then
        arg := arg[1];
    fi;

    # start with the first domain or list
    I := arg[1];
    copied := false;

    # loop over the other domains or lists
    for i  in [2..Length(arg)]  do
        D := arg[i];
        if IsList( I ) and IsList( D )  then
            if not copied then I := Set( I ); fi;
            IntersectSet( I, D );
            copied := true;
        else
            I := Intersection2( I, D );
            copied := false;
        fi;
    od;

    # return the intersection
    if IsList( I ) and not IsSSortedList( I ) then
        I := Set( I );
    fi;
    return I;
end;


#############################################################################
##
#M  Union(<C>,...)
##
UnionSet := function ( C1, C2 )
    local   I;
    if Length( C1 ) < Length( C2 ) then
        I := Set( C2 );
        UniteSet( I, C1 );
    else
        I := Set( C1 );
        UniteSet( I, C2 );
    fi;
    return I;
end;

InstallMethod( Union2,
    "method for two collections that are lists",
    IsIdentical,
    [ IsCollection and IsList, IsCollection and IsList ], 0,
    UnionSet );

InstallOtherMethod( Union2,
    "method for two lists",
    true, [ IsList, IsList ], 0,
    UnionSet );

InstallMethod( Union2,
    "method for two collections, the second being a list",
    IsIdentical, [ IsCollection, IsCollection and IsList ], 0,
    function ( C1, C2 )
    local   I;
    if IsFinite( C1 ) then
        I := ShallowCopy( AsListSorted( C1 ) );
        UniteSet( I, C2 );
    else
        Error("sorry, cannot unite <C2> with the infinite collection <C1>");
    fi;
    return I;
    end );

InstallMethod( Union2,
    "method for two collections, the first being a list",
    IsIdentical, [ IsCollection and IsList, IsCollection ], 0,
    function ( C1, C2 )
    local   I;
    if IsFinite( C2 ) then
        I := ShallowCopy( AsListSorted( C2 ) );
        UniteSet( I, C1 );
    else
        Error("sorry, cannot unite <C1> with the infinite collection <C2>");
    fi;
    return I;
    end );

InstallMethod( Union2,
    "method for two collections",
    IsIdentical, [ IsCollection, IsCollection ], 0,
    function ( C1, C2 )
    local   I;
    if IsFinite( C1 ) then
        if IsFinite( C2 ) then
            I := ShallowCopy( AsListSorted( C1 ) );
            UniteSet( I, AsListSorted( C2 ) );
        else
            Error("sorry, cannot unite <C1> with the infinite collection <C2>");
        fi;
    elif IsFinite( C2 ) then
        Error("sorry, cannot unite <C2> with the infinite collection <C1>");
    else
        TryNextMethod();
    fi;
    return I;
    end );

Union := function ( arg )
    local   U,          # union, result
            D,          # domain or list, running over the arguments
            copied,     # true if I is a list not identical to anything else
            i;          # loop variable

    # unravel the argument list if necessary
    if Length(arg) = 1  then
        arg := arg[1];
    fi;
    
    # empty case first
    if Length( arg ) = 0  then
        return [  ];
    fi;
    
    # start with the first domain or list
    U := arg[1];
    copied := false;

    # loop over the other domains or lists
    for i  in [2..Length(arg)]  do
        D := arg[i];
        if IsList( U ) and IsList( D )  then
            if not copied then U := Set( U ); fi;
            UniteSet( U, D );
            copied := true;
        else
            U := Union2( U, D );
            copied := false;
        fi;
    od;

    # return the union
    if IsList( U ) and not IsSSortedList( U ) then
        U := Set( U );
    fi;
    return U;
end;


#############################################################################
##
#M  Difference(<C1>,<C2>)
##
InstallOtherMethod( Difference,
    "method for empty list, and collection",
    true, [ IsList and IsEmpty, IsListOrCollection ], 0,
    function ( C1, C2 )
    return [];
    end );

InstallOtherMethod( Difference,
    "method for collection, and empty list",
    true, [ IsCollection, IsList and IsEmpty ], 0,
    function ( C1, C2 )
    return ShallowCopy( C1 );
    end );

InstallMethod( Difference,
    "method for two collections that are lists",
    IsIdentical, [ IsCollection and IsList, IsCollection and IsList ], 0,
    function ( C1, C2 )
    C1 := Set( C1 );
    SubtractSet( C1, C2 );
    return C1;
    end );

InstallMethod( Difference,
    "method for two collections",
    IsIdentical, [ IsCollection, IsCollection ], 0,
    function ( C1, C2 )
    local   D, elm;
    if IsFinite( C1 ) then
        if IsFinite( C2 ) then
            D := ShallowCopy( AsListSorted( C1 ) );
            SubtractSet( D, AsListSorted( C2 ) );
        else
            D := [];
            for elm in C1 do
                if not elm in C2 then
                    AddSet( D, elm );
                fi;
            od;
        fi;
    else
        Error("sorry, cannot subtract from the infinite domain <C1>");
    fi;
    return D;
    end );

InstallMethod( Difference,
    "method for two collections, the first being a list",
    IsIdentical, [ IsCollection and IsList, IsCollection ], 0,
    function ( C1, C2 )
    local   D, elm;
    if IsFinite( C2 )  then
        D := Set( C1 );
        SubtractSet( D, AsListSorted( C2 ) );
    else
        D := [];
        for elm in C1 do
            if not elm in C2 then
                AddSet( D, elm );
            fi;
        od;
    fi;
    return D;
    end );

InstallMethod( Difference,
    "method for two collections, the second being a list",
    IsIdentical, [ IsCollection, IsCollection and IsList ], 0,
    function ( C1, C2 )
    local   D;
    if IsFinite( C1 ) then
        D := ShallowCopy( AsListSorted( C1 ) );
        SubtractSet( D, C2 );
    else
        Error( "sorry, cannot subtract from the infinite domain <D>" );
    fi;
    return D;
    end );


#############################################################################
##
#E  coll.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here


