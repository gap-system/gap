#############################################################################
##
#W  coll.gi                     GAP library                  Martin Schoenert
#W                                                            & Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
InstallMethod( PrintObj, true, [ IsIterator ], 0,
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
    true, [ IsCollection ], 0,
    function ( C )
    return (Size( C ) = 0);
    end );


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
    true, [ IsCollection ], 0,
    function ( C )
    return (Size( C ) = 1);
    end );


#############################################################################
##
#M  IsFinite(<C>) . . . . . . . . . . . . . . test if a collection ist finite
##
InstallImmediateMethod( IsFinite,
    IsCollection and HasSize, 0,
    function ( C )
    return not IsIdentical( Size( C ), infinity );
    end );

InstallMethod( IsFinite,
    true, [ IsCollection ], 0,
    function ( C )
    return not IsIdentical( Size( C ), infinity );
    end );


#############################################################################
##
#M  IsWholeFamily(<C>)  . . .  test if a collection contains the whole family
##
InstallMethod( IsWholeFamily,
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
    true, [ IsCollection ], 0,
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
#M  Random(<C>)
##
InstallMethod( Random,
    "method for collections that are lists",
    true, [ IsCollection and IsList ], 100,
#T ?
    function ( C )
    return RANDOM_LIST( C );
    end );

InstallMethod( Random,
    "method for collections",
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
    "method for collections",
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
    "method for collections",
    true,
    [ IsCollection ],
    0,
    coll -> ConstantTimeAccessList( EnumeratorSorted( coll ) ) );

InstallOtherMethod( AsListSorted,
    "method for collections that are constant time access lists",
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
    "method for collections that are lists",
    true, [ IsCollection and IsList ], 0,
    Immutable );


#############################################################################
##
#M  PrintObj( <enum> )  . . . . . . . . . . . . . . . . . print an enumerator
##
InstallMethod( PrintObj, true, [ IsEnumerator ], 0,
    function( enum )
    Print( "<enumerator>" );
    end );


#############################################################################
##
#M  IsBound( <enum>, <pos> )  . . . . . . . . . . . . . . . . for enumerators
##
InstallMethod( IsBound\[\], true, [ IsList, IsPosRat and IsInt ], 0,
    function( enum, pos )
    return enum[ pos ] <> fail;
    end );


#############################################################################
##
#M  EnumeratorSorted(<C>)
##
InstallImmediateMethod( EnumeratorSorted,
    IsCollection and HasAsListSorted, 0,
    AsListSorted );

InstallMethod( EnumeratorSorted,
    true, [ IsCollection ], 0,
    coll -> AsListSortedList( Enumerator( coll ) ) );

InstallMethod( EnumeratorSorted,
    "method for collections that are lists",
    true, [ IsCollection and IsList ], 0,
    AsListSortedList );


#############################################################################
##
#M  List( <coll> )
##
InstallMethod( List,
    "method for collections",
    true, [ IsCollection ], 0,
    C -> ShallowCopy( Enumerator( C ) ) );

InstallMethod( List,
    "method for collections that are lists",
    true, [ IsCollection and IsList ], 0,
    ShallowCopy );

InstallOtherMethod( List,
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
    "method for collections",
    true, [ IsCollection ], 0,
    C -> ShallowCopy( EnumeratorSorted( C ) ) );

InstallMethod( ListSorted,
    "method for collections that are lists",
    true, [ IsCollection and IsList ], 0,
    C -> ShallowCopy( ListSortedList( C ) ) );


#############################################################################
##
#M  ListSorted( <C>, <func> )
##
InstallOtherMethod( ListSorted, true, [ IsCollection, IsFunction ], 0,
    function ( C, func )
    return ListSortedList( List( C, func ) );
    end );


#############################################################################
##
#M  Iterator(<C>)
##
InstallMethod( Iterator,
    "method for collections",
    true, [ IsCollection ], 0,
    C -> IteratorList( Enumerator( C ) ) );

InstallMethod( Iterator,
    "method for collections that are lists",
    true, [ IsCollection and IsList ], 0,
    C -> IteratorList( C ) );

InstallOtherMethod( Iterator,
    "method for iterators",
    true, [ IsIterator ], 0,
    IdFunc );
#T or change the for-loop to accept iterators?


#############################################################################
##
#M  IteratorSorted(<C>)
##
InstallMethod( IteratorSorted,
    "method for collections",
    true, [ IsCollection ], 0,
    C -> IteratorList( EnumeratorSorted( C ) ) );

InstallMethod( IteratorSorted,
    "method for collections that are lists",
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
    return Objectify( NewKind( IteratorsFamily,
                               IsIterator and IsTrivialIterator ),
                      rec( element := elm, isDone := false ) );
end;

InstallMethod( IsDoneIterator,
    true, [ IsIterator and IsTrivialIterator ], SUM_FLAGS,
    iter -> iter!.isDone );

InstallMethod( NextIterator,
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
#M  Sum(<C>)
##
InstallMethod( Sum,
    true, [ IsListOrCollection ], 0,
    function ( C )
    local   sum, i;
    i := Iterator( C );
    if not IsDoneIterator( i ) then
        sum := NextIterator( i );
        while not IsDoneIterator( i ) do
            sum := sum + NextIterator( i );
        od;
    else
        sum := 0;
    fi;
    return sum;
    end );

InstallOtherMethod( Sum,
    true, [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local   sum, i;
    i := Iterator( C );
    if not IsDoneIterator( i ) then
        sum := func( NextIterator( i ) );
        while not IsDoneIterator( i ) do
            sum := sum + func( NextIterator( i ) );
        od;
    else
        sum := 0;
    fi;
    return sum;
    end );


#############################################################################
##
#M  Product(<C>
##
InstallMethod( Product,
    true, [ IsListOrCollection ], 0,
    function ( C )
    local   prod, i;
    i := Iterator( C );
    if not IsDoneIterator( i ) then
        prod := NextIterator( i );
        while not IsDoneIterator( i ) do
            prod := prod * NextIterator( i );
        od;
    else
        prod := 1;
    fi;
    return prod;
    end );

InstallOtherMethod( Product,
    true, [ IsListOrCollection, IsFunction ], 0,
    function ( C, func )
    local   prod, i;
    i := Iterator( C );
    if not IsDoneIterator( i ) then
        prod := func( NextIterator( i ) );
        while not IsDoneIterator( i ) do
            prod := prod * func( NextIterator( i ) );
        od;
    else
        prod := 1;
    fi;
    return prod;
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

InstallMethod( Filtered, true, [ IsEmpty, IsFunction ], 0,
    function( list, func )
    return [];
    end );

#############################################################################
##
#M  Number(<C>,<func>)  . . . . . . . . . count elements that have a property
##
InstallMethod( Number,
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

InstallOtherMethod( Number, true,
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

InstallOtherMethod( ForAll, true,
    [ IsEmpty, IsFunction ], 0,
    ReturnTrue );


#############################################################################
##
#M  ForAny(<C>,<func>)  . . . . . . test a property for any element of a list
##
InstallMethod( ForAny,
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

InstallOtherMethod( ForAny, true,
    [ IsEmpty, IsFunction ], 0,
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
    IsNotIdentical,
    [ IsCollection,
      IsCollection ],
    0,
    false );


InstallMethod( IsSubset,
    IsIdentical,
    [ IsCollection and IsWholeFamily,
      IsCollection ], 
    SUM_FLAGS+2,
    true );


InstallMethod( IsSubset,
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
    IsIdentical,
    [ IsList,
      IsList ],
    0,
    IsSubsetSet );


InstallMethod( IsSubset,
    IsIdentical,
    [ IsCollection and HasAsListSorted,
      IsCollection and HasAsListSorted ],
    0,

function ( D, E )
    return IsSubsetSet( AsListSorted( D ), AsListSorted( E ) );
end );


InstallMethod( IsSubset,
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
    true, [ IsList, IsList ], 0,
    IntersectionSet );

InstallMethod( Intersection2,
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

InstallOtherMethod( Union2,
    true, [ IsList, IsList ], 0,
    UnionSet );

InstallMethod( Union2,
    IsIdentical, [ IsCollection, IsCollection and IsList ], 0,
    function ( C1, C2 )
    local   I, elm;
    if IsFinite( C1 ) then
        I := ShallowCopy( AsListSorted( C1 ) );
        UniteSet( I, C2 );
    else
        Error("sorry, cannot unite <C2> with the infinite collection <C1>");
    fi;
    return I;
    end );

InstallMethod( Union2,
    IsIdentical, [ IsCollection and IsList, IsCollection ], 0,
    function ( C1, C2 )
    local   I, elm;
    if IsFinite( C2 ) then
        I := ShallowCopy( AsListSorted( C2 ) );
        UniteSet( I, C1 );
    else
        Error("sorry, cannot unite <C1> with the infinite collection <C2>");
    fi;
    return I;
    end );

InstallMethod( Union2,
    IsIdentical, [ IsCollection, IsCollection ], 0,
    function ( C1, C2 )
    local   I, elm;
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
    true, [ IsList and IsEmpty, IsCollection ], 0,
    function ( C1, C2 )
    return [];
    end );

InstallOtherMethod( Difference,
    true, [ IsCollection, IsList and IsEmpty ], 0,
    function ( C1, C2 )
    return ShallowCopy( C1 );
    end );

InstallMethod( Difference,
    IsIdentical, [ IsCollection and IsList, IsCollection and IsList ], 0,
    function ( C1, C2 )
    C1 := Set( C1 );
    SubtractSet( C1, C2 );
    return C1;
    end );

InstallMethod( Difference,
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
#M  <elm> \in <whole-family>
##
InstallMethod(  \in,
    IsElmsColls,
    [ IsObject, IsCollection and IsWholeFamily ],
    SUM_FLAGS,
    RETURN_TRUE );


#############################################################################
##
#E  coll.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here


