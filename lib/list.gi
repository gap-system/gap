#############################################################################
##
#W  list.gi                     GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for lists in general.
##
Revision.list_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  methods for comparisons
##
InstallMethod( EQ,
    "method for two homogeneous lists",
    IsIdentical, [ IsHomogeneousList, IsHomogeneousList ], 0,
    EQ_LIST_LIST_DEFAULT );
InstallMethod( EQ,
    "method for two lists, the first being empty",
    true, [ IsList and IsEmpty, IsList ], SUM_FLAGS,
    function( empty, list )
    return IsEmpty( list );
end );
InstallMethod( EQ,
    "method for two lists, the second being empty",
    true, [ IsList, IsList and IsEmpty ], SUM_FLAGS,
    function( list, empty )
    return IsEmpty( list );
end );
InstallMethod( LT,
    "method for two homogeneous lists",
    IsIdentical, [ IsHomogeneousList, IsHomogeneousList ], 0,
    LT_LIST_LIST_DEFAULT );

#############################################################################
##
#M  \in( <obj>, <list> )
##
InstallMethod( IN,
    "method for an object, and an empty list",
    true,
    [ IsObject, IsList and IsEmpty ], 0,
    ReturnFalse );

#############################################################################
##
#M  <elm> \in <whole-family>
##
InstallMethod( IN,
    "method for an object, and a collection that contains the whole family",
    IsElmsColls,
    [ IsObject, IsCollection and IsWholeFamily ],
    SUM_FLAGS,
    RETURN_TRUE );

InstallMethod( IN,
    "method for wrong family relation",
    IsNotElmsColls,
    [ IsObject, IsCollection ], 0,
    ReturnFalse );

InstallMethod( IN,
    "method for an object, and a list",
    true,
    [ IsObject, IsList ], 0,
    IN_LIST_DEFAULT );
#T internal lists only?


#############################################################################
##
#M  Length( <list> )  . . . . . . . . . . . . . . . . .  for an infinite list
##
InstallMethod( Length,
    "method for an infinite list",
    true,
    [ IsList and HasIsFinite ], 0,
    function( list )
    if IsFinite( list ) then
      TryNextMethod();
    else
      return infinity;
    fi;
    end );


#############################################################################
##
#M  String( <list> )  . . . . . . . . . . . . . . . . . . . . . .  for a list
#M  String( <range> ) . . . . . . . . . . . . . . . . . . . . . . for a range
##
InstallMethod( String,
    "method for a finite list",
    true,
    [ IsList ], 0,
    function ( list )
    local   str, i;

    # Check that we are in the right method.
    if not IsFinite( list ) then
      TryNextMethod();
    fi;

    # We cannot handle the case of an empty string in the method for strings
    # because the type of the empty string does not satify the requirement
    # 'IsString'.
    if IsEmptyString( list ) then
      return "";
    fi;

    str := "[ ";
    for i in [ 1 .. Length( list ) ]  do
        if IsBound( list[ i ] )  then
            Append( str, String( list[ i ] ) );
        fi;
        if i <> Length( list )  then
            Append( str, ", " );
        fi;
    od;
    Append( str, " ]" );
    ConvertToStringRep( str );
    return str;
    end );

InstallMethod( String,
    "method for a range",
    true,
    [ IsRange ], 0,
    function( list )
    local   str;
    str := Concatenation( "[ ", String( list[ 1 ] ) );
    if Length( list ) > 1  then
        if list[ 2 ] - list[ 1 ] <> 1  then
            Append( str, ", " );
            Append( str, String( list[ 2 ] ) );
        fi;
        Append( str, " .. " );
        Append( str, String( list[ Length( list ) ] ) );
    fi;
    Append( str, " ]" );
    ConvertToStringRep( str );
    return str;
    end );


#############################################################################
##
#M  Size(<set>) . . . . . . . . . . . . . . . . . . . . . . . . .  for a list
##
InstallOtherMethod( Size,
    "method for a list",
    true,
    [ IsList ],
    0,
    Length );

InstallOtherMethod( Size,
    "method for a list that is a collection",
    true,
    [ IsList and IsCollection ],
    0,
    Length );


#############################################################################
##
#M  Representative(<list>)
##
InstallOtherMethod( Representative,
    "method for an empty list",
    true,
    [ IsList and IsEmpty ],
    0,

function ( list )
    Error( "<C> must be nonempty to have a representative" );
end );


InstallOtherMethod( Representative,
    "method for a list",
    true,
    [ IsList ],
    0,

function ( list )
    return list[1];
end );


#############################################################################
##
#M  RepresentativeSmallest(<list>)
##
InstallOtherMethod( RepresentativeSmallest,
    "method for an empty list",
    true, [ IsList and IsEmpty ], 0,
    function ( list )
    Error( "<C> must be nonempty to have a representative" );
    end );

InstallOtherMethod( RepresentativeSmallest,
    "method for a strictly sorted list",
    true, [ IsSSortedList ], 0,
    function ( list )
    return list[1];
    end );

InstallOtherMethod( RepresentativeSmallest,
    "method for a homogeneous list",
    true, [ IsHomogeneousList ], 0,
    function ( list )
    return MinimumList( list );
    end );


#############################################################################
##
#M  Random( <list> )  . . . . . . . . . . . . . . . for a dense internal list
##
InstallOtherMethod( Random,
    "method for a dense internal list",
    true,
    [ IsList and IsDenseList and IsInternalRep ], 0,
    RANDOM_LIST );


#############################################################################
##
#M  Random( <list> )  . . . . . . . . . . . . . . . .  for a short dense list
##
InstallOtherMethod( Random,
    "method for a short dense list",
    true,
    [ IsList and IsDenseList ], 0,
    function( list )
    if Length( list ) < 2^28 then
      return RANDOM_LIST( list );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  ConstantTimeAccessList( <list> )
#M  ShallowCopy( <list> )
##
##  `ConstantTimeAccessList' and   `ShallowCopy' have  the same  methods  for
##  lists:       These methods     return     mutable   lists,     but  since
##  `ConstantTimeAccessList' is an  attribute, its results are made immutable
##  by the kernel.
##
##  `ConstantTimeAccessList' has   an additional ``almost  immediate method''
##  constant time access lists: this method just  returns the argument. (This
##  cannot work for `ShallowCopy', because the argument could be immutable.)
##
for op  in [ ConstantTimeAccessList, ShallowCopy ]  do

    InstallMethod( op, true, [ IsList ], 0,
        function( list )
        local   new,  i;
        
        new:= [  ];
        for i  in [ 1 .. Length( list ) ]  do
            if IsBound( list[ i ] )  then
                new[ i ] := list[ i ];
            fi;
        od;
        return new;
    end );
        
    InstallMethod( op, true, [ IsList and IsDenseList ], 0,
        function( list )
        if TNUM_OBJ( Length( list ) )[ 1 ] = 0  then
            return list{ [ 1 .. Length( list ) ] };
        else
            Error( "resulting list would be too large (length ",
                   Length( list ), ")" );
        fi;
    end );
    
od;

InstallMethod( ConstantTimeAccessList,
    "method for a constant time access list",
    true,
    [ IsList and IsConstantTimeAccessList ], SUM_FLAGS,
    Immutable );


#############################################################################
##
#M  AsList( <list> )
##
InstallOtherMethod( AsList,
    "method for a list",
    true,
    [ IsList ],
    0,
    list -> ConstantTimeAccessList( Enumerator( list ) ) );

InstallOtherMethod( AsList,
    "method for a constant time access list",
    true,
    [ IsList and IsConstantTimeAccessList ],
    0,
    Immutable );


#############################################################################
##
#M  AsListSorted( <list> )
##
##  If <list> is a (not necessarily dense) list whose elements lie in the
##  same family then 'AsListSorted' is applicable.
##
InstallOtherMethod( AsListSorted,
    "method for a list",
    true,
    [ IsList ],
    0,
    list -> ConstantTimeAccessList( EnumeratorSorted( list ) ) );

InstallOtherMethod( AsListSorted,
    "method for a constant time access list",
    true,
    [ IsList and IsConstantTimeAccessList ],
    0,
    AsListSortedList );


#############################################################################
##
#M  Enumerator( <list> )
##
InstallOtherMethod( Enumerator,
    "method for a list",
    true, [ IsList ], 0,
    Immutable );


#############################################################################
##
#M  EnumeratorSorted( <list> )
##
InstallOtherMethod( EnumeratorSorted,
    "method for a list",
    true, [ IsList ], 0,
    AsListSortedList );


#############################################################################
##
#M  List(<list>)
##
InstallOtherMethod( List,
    "method for a list",
    true, [ IsList ], 0,
    ShallowCopy );

InstallOtherMethod( List,
    "method for a dense list",
    true, [ IsList and IsDenseList ], 0,
    list -> list{ [ 1 .. Length( list ) ] } );

InstallOtherMethod( List,
    "method for a list, and a function",
    true, [ IsList, IsFunction ], 0,
    function ( list, func )
    local   res, i;
    res := [];
    for i  in [ 1 .. Length( list ) ] do
        res[i] := func( list[i] );
    od;
    return res;
    end );


#############################################################################
##
#M  ListSorted( <list> )  . . . . . . . . . . . set of the elements of a list
##
InstallOtherMethod( ListSorted,
    "method for a list",
    true, [ IsList ], 0,
    ListSortedList );


#############################################################################
##
#M  ListSorted( <list>, <func> )
##
InstallOtherMethod( ListSorted,
    "method for a list, and a function",
    true, [ IsList, IsFunction ], 0,
    function ( list, func )
    local   res, i;
    res := [];
    for i  in [ 1 .. Length( list ) ] do
        AddSet( res, func( list[i] ) );
    od;
    return res;
    end );


#############################################################################
##
#M  Iterator(<list>)
##
IsListIteratorRep :=
    NewRepresentation( "IsListIteratorRep",
        IsComponentObjectRep, "pos, list" );

InstallMethod( IsDoneIterator,
    "method for a list iterator",
    true, [ IsIterator and IsListIteratorRep ], 0,
    function ( iter )
        return (iter!.pos = Length( iter!.list ));
    end );

InstallMethod( NextIterator,
    "method for a list iterator",
    true, [ IsIterator and IsListIteratorRep ], 0,
    function ( iter )
    if iter!.pos = Length( iter!.list ) then
        Error("<iter> is exhausted");
    fi;
    iter!.pos := iter!.pos + 1;
    while not IsBound( iter!.list[ iter!.pos ] ) do
        iter!.pos := iter!.pos + 1;
    od;
    return iter!.list[ iter!.pos ];
    end );

IteratorList := function ( list )
    local   iter;
    iter := rec(
        list := list,
        pos  := 0
    );
    return Objectify( NewType( IteratorsFamily, IsListIteratorRep ), iter );
end;

InstallOtherMethod( Iterator,
    "method for a list",
    true, [ IsList ], 0,
    IteratorList );


#############################################################################
##
#M  IteratorSorted(<list>)
##
InstallOtherMethod( IteratorSorted,
    "method for a list",
    true, [ IsList ], 0,
    list -> IteratorList( ListSortedList( list ) ) );


#############################################################################
##
#M  Sum( <list> ) . . . . . . . . . . . . . . . . . . . . .  for a dense list
##
InstallOtherMethod( Sum,
    "method for a dense list",
    true,
    [ IsDenseList ], 1,
    function ( list )
    local   sum, i;
    if IsEmpty(list) then
        sum := 0;
    else
        sum := list[1];
        for i in [2..Length(list)] do
            sum := sum + list[i];
        od;
    fi;
    return sum;
    end );


#############################################################################
##
#M  Sum( <list>, <init> ) . . . . . . . . . . . for a list, and initial value
##
InstallOtherMethod( Sum,
    "method for a list, and initial value",
    true,
    [ IsList, IsAdditiveElement ], 1,
    function ( list, init )
    local elm;
    for elm in list do
      init := init + elm;
    od;
    return init;
    end );


#############################################################################
##
#M  Sum( <list>, <func> ) . . . . . . . . .  for a dense list, and a function
##
InstallOtherMethod( Sum,
    "method for a dense list, and a function",
    true,
    [ IsDenseList, IsFunction ], 1,
    function( list, func )
    local   sum, i;
    if IsEmpty(list) then
        sum := 0;
    else
        sum := func( list[1] );
        for i in [2..Length(list)] do
            sum := sum + func( list[i] );
        od;
    fi;
    return sum;
    end );


#############################################################################
##
#M  Sum( <list>, <func>, <init> ) . . . . for list, function, and init. value
##
InstallOtherMethod( Sum,
    "method for a list, a function, and initial value",
    true,
    [ IsList, IsFunction, IsAdditiveElement ], 1,
    function ( list, func, init )
    local elm;
    for elm in list do
      init := init + func( elm );
    od;
    return init;
    end );


#############################################################################
##
#M  Product( <list> ) . . . . . . . . . . . . . . . . . . .  for a dense list
##
InstallOtherMethod( Product,
    "method for a dense list",
    true,
    [ IsDenseList ], 1,
    function ( list )
    local   prod, i;
    if IsEmpty(list) then
        prod := 1;
    else
        prod := list[1];
        for i in [2..Length(list)] do
            prod := prod * list[i];
        od;
    fi;
    return prod;
    end );


#############################################################################
##
#M  Product( <list>, <init> ) . . . . . . . . . for a list, and initial value
##
InstallOtherMethod( Product,
    "method for a list, and initial value",
    true,
    [ IsList, IsMultiplicativeElement ], 1,
    function ( list, init )
    local elm;
    for elm in list do
      init := init * elm;
    od;
    return init;
    end );


#############################################################################
##
#M  Product( <list>, <func> ) . . . . . . .  for a dense list, and a function
##
InstallOtherMethod( Product,
    "method for a dense list and a function",
    true,
    [ IsDenseList, IsFunction ], 1,
    function( list, func )
    local prod, i;
    if IsEmpty(list) then
        prod := 1;
    else
        prod := func( list[1] );
        for i in [2..Length(list)] do
            prod := prod * func( list[i] );
        od;
    fi;
    return prod;
    end );


#############################################################################
##
#M  Product( <list>, <func>, <init> ) . . for list, function, and init. value
##
InstallOtherMethod( Product,
    "method for a list, a function, and initial value",
    true,
    [ IsList, IsFunction, IsMultiplicativeElement ], 1,
    function ( list, func, init )
    local elm;
    for elm in list do
      init := init * func( elm );
    od;
    return init;
    end );


#############################################################################
##
#M  Elm0List
##
InstallMethod( Elm0List,
    true, [ IsList, IsInt ], 0,
    function ( list, pos )
    if IsBound( list[pos] ) then
        return list[pos];
    else
        return fail;
    fi;
    end );


#############################################################################
##
#M  <list>{<poss>}
#M  <list>{<poss>}:=<objs>
##
InstallMethod( ELMS_LIST,
    true, [ IsList, IsDenseList ], 0,
    ELMS_LIST_DEFAULT );

InstallMethod( ASSS_LIST,
    true, [ IsList and IsMutable, IsDenseList, IsList ], 0,
    ASSS_LIST_DEFAULT );


#############################################################################
##
#M  IsSSortedList(<list>)
##
InstallMethod( IsSSortedList,
    true, [ IsHomogeneousList ], 0,
    IS_SSORT_LIST_DEFAULT );


#############################################################################
##
#M  IsDuplicateFreeList(<list>)
##
InstallMethod( IsDuplicateFreeList,
    "method for a finite list",
    true, [ IsDenseList ], 0,
    function( list )
    local i;
    if not IsFinite( list ) then
      TryNextMethod();
    fi;
    for i in [ 1 .. Length( list ) ] do
      if Position( list, list[i], 0 ) < i then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  IsPositionsList(<list>)
##
InstallMethod( IsPositionsList,
    true, [ IsHomogeneousList ], 0,
    IS_POSS_LIST_DEFAULT );


#############################################################################
##
#M  Position(<list>,<obj>,<from>)
##
InstallMethod( Position,
    true, [ IsList, IsObject, IsInt ], 0,
    function( list, obj, start )
    local   pos;
    
    pos := POS_LIST_DEFAULT( list, obj, start );
    if pos = 0  then  return fail;
                else  return pos;   fi;
end );
            
InstallMethod( Position,
    function( F1, F2, F3 )
        return HasElementsFamily(F1)
           and not IsIdentical( ElementsFamily(F1), F2 );
    end,
    [ IsHomogeneousList,
      IsObject,
      IsInt ],
    0,
    RETURN_FAIL );


#N  1996/08/14 M.Schoenert 'POSITION_SORTED_LIST' should take 3 arguments
InstallMethod( Position,
    true, [ IsSSortedList, IsObject, IsInt ], 0,
    function ( list, obj, start )
    local   pos;
    
    if start = 0 then  pos := POSITION_SORTED_LIST( list, obj );
                 else  pos := POS_LIST_DEFAULT( list, obj, start );  fi;
    if pos = 0  then  return fail;
                else  return pos;   fi;
end );

InstallMethod( Position, true,
    [ IsDuplicateFreeList, IsObject, IsPosRat and IsInt ], 0,
    function( list, obj, start )
    local pos;
    pos:= Position( list, obj, 0 );
    if pos <> fail and start < pos then
      return pos;
    else
      return fail;
    fi;
    end );

#############################################################################
##
#M  PositionCanonical( <list>, <obj> )  . . . . . . . . . . .  default method
##
InstallMethod( PositionCanonical, "fall back on `Position'", IsCollsElms,
    [ IsList, IsObject ], 0,
    function( list, obj )
    return Position( list, obj, 0 );
end );

#############################################################################
##
#M  PositionNthOccurence( <list>, <obj>, <n> )  . . call `Position' <n> times
##
InstallMethod( PositionNthOccurence,
    true, [ IsList, IsObject, IsInt ], 0,
    function( list, obj, n )
    local   pos,  i;
    
    pos := 0;
    for i  in [ 1 .. n ]  do
        pos := Position( list, obj, pos );
        if pos = fail  then
            return fail;
        fi;
    od;
    return pos;
end );

#############################################################################
##
#M  PositionNthOccurence( <blist>, <bool>, <n> )   kernel function for blists
##
InstallMethod( PositionNthOccurence,
    true, [ IsBlist, IsBool, IsInt ], 0,
    function( blist, bool, n )
    if bool = true  then  return PositionNthTrueBlist( blist, n );
                    else  TryNextMethod();                          fi;
end );
                    
#############################################################################
##
#M  PositionSorted(<list>,<obj>)
##
InstallMethod( PositionSorted,
    true, [ IsHomogeneousList, IsObject ], 0,
    POSITION_SORTED_LIST );

InstallOtherMethod( PositionSorted, true,
    [ IsHomogeneousList, IsObject, IsFunction ], 0,
    POSITION_SORTED_LIST_COMP );

#############################################################################
##
#F  PositionSortedWC(<list>,<obj>) . .  returns 'fail' is object is not found
##
PositionSortedWC := function(l,obj)
local p;
  p:=PositionSorted(l,obj);
  if (not IsBound(l[p])) or l[p]<>obj then
    p:=fail;
  fi;
  return p;
end;


#############################################################################
##
#M  PositionProperty(<list>,<func>) .  position of an element with a property
##
InstallMethod( PositionProperty,
    true, [ IsDenseList, IsFunction ], 0,
    function ( list, func )
    local i;
    for i in [ 1 .. Length( list ) ] do
        if func( list[ i ] ) then
            return i;
        fi;
    od;
    return fail;
    end );


#############################################################################
##
#M  PositionBound(<list>) . . . . . . . . . . . position of first bound entry
##
InstallMethod( PositionBound,
    true, [ IsList ], 0,
    function( list )
    local i;
    for i in [ 1 .. Length( list ) ] do
        if IsBound( list[i] )  then
            return i;
        fi;
    od;
    return fail;
    end );


#############################################################################
##
#M  Add(<list>,<obj>)
##
InstallMethod( Add,
    true, [ IsList and IsMutable, IsObject ], 0,
    ADD_LIST_DEFAULT );


#############################################################################
##
#M  Append(<list1>,<list2>)
##
APPEND_LIST_DEFAULT := function ( list1, list2 )
    local  len1, len2, i;
    len1 := Length(list1);
    len2 := Length(list2);
    for i  in [1..len2]  do
        if IsBound(list2[i])  then
            list1[len1+i] := list2[i];
        fi;
    od;
end;

InstallMethod( Append,
    true,
    [ IsList and IsMutable,
      IsList ],
    0,
    APPEND_LIST_DEFAULT );


InstallMethod( Append,
    true,
    [ IsList and IsInternalRep and IsMutable,
      IsList ],
    0,
    APPEND_LIST_INTR );


#############################################################################
##
#M  Concatenation(<list>,...)
##
Concatenation := function ( arg )
    local  cat, lst;

    cat := [];
    if Length(arg) = 1  and IsList(arg[1])  then
        for lst  in arg[1]  do
            Append( cat, lst );
        od;
    else
        for lst  in arg  do
            Append( cat, lst );
        od;
    fi;

    return cat;
end;


#############################################################################
##
#M  Compacted(<list>) . . . . . . . . . . . . . . .  remove holes from a list
##
InstallMethod( Compacted,
    true, [ IsList ], 0,
    function ( list )
    local   res,        # compacted of <list>, result
            elm;        # element of <list>
    res := [];
    for elm in list do
        Add( res, elm );
    od;
    return res;
    end );


#############################################################################
##
#M  Collected(<list>) . . . . .
##
InstallMethod( Collected,
    true, [ IsList and IsEmpty ], 0,
    function ( list )
    return [];
    end );

InstallMethod( Collected,
    true, [ IsList ], 0,
    function ( list )
    local   res,        # collected, result
            col,        # one element of collected list
            sorted,     # list in sorted order
            elm;        # one element of list

    # special case for empty list
    if Length( list ) = 0 then
        return [];
    fi;

    # sort a shallow copy of the list
    sorted := ShallowCopy( list );
    Sort( sorted );

    # now collect
    res := [];
    col := [ sorted[1], 0 ];
    for elm in sorted do
        if elm <> col[1] then
            Add( res, col );
            col := [ elm, 0 ];
        fi;
        col[2] := col[2] + 1;
    od;
    Add( res, col );

    # return the collected list
    return res;
    end );


#############################################################################
##
#M  DuplicateFreeList(<list>)  . . . . . duplicate free list of list elements
##
InstallMethod( DuplicateFreeList, true, [ IsList ], 0,
function ( list )
local l,i;
  l:=[];
  for i in list do
    if not i in l then
      Add(l,i);
    fi;
  od;
  return l;
end );

#############################################################################
##
#M  AsDuplicateFreeList(<list>)  . . . . duplicate free list of list elements
##
InstallMethod( AsDuplicateFreeList, true, [ IsList ], 0, DuplicateFreeList);

#############################################################################
##
#M  Flat(<list>)  . . . . . . . . list of elements of a nested list structure
##
InstallMethod( Flat,
    true, [ IsList ], 0,
    function ( list )
    local   res,        # list <list> flattened, result
            elm;        # one element of <list>
    res := [];
    for elm in list do
        if not IsList(elm)  then
            Add( res, elm );
        else
            Append( res, Flat(elm) );
        fi;
    od;
    return res;
    end );


#############################################################################
##
#M  Reversed(<list>)  . . . . . . . . . . . .  reverse the elements in a list
##
InstallMethod( Reversed,
    true,
    [ IsDenseList ], 0,
    function ( list )
    local res, len, i;
    res := [];
    len := Length( list );
    for i in [ 0 .. len-1 ] do
        Add( res, list[len-i] );
    od;
    return res;
    end );

InstallMethod( Reversed,
    true, [ IsRange ], 1,
    function ( list )
    local len;
    len := Length( list );
    if len = 0 then
        return [];
    elif len = 1 then
        return [ list[1] ];
    else
        return [ list[len], list[len-1] .. list[1] ];
    fi;
    end );


#############################################################################
##
#M  Sort(<list>)
##
InstallMethod( Sort,
    true, [ IsList and IsMutable], 0,
    SORT_LIST );

InstallOtherMethod( Sort,
    true,
    [ IsList and IsMutable,
      IsFunction ],
    0,
    SORT_LIST_COMP );


#############################################################################
##
#F  Sortex(<list>) . . . sort a list (stable), return the applied permutation
##
InstallMethod( Sortex,
    true, [ IsHomogeneousList and IsMutable ], 0,
    function ( list )
    local   both, perm, i;

    # make a new list that contains the elements of <list> and their indices
    both := [];
    for i in [ 1 .. Length( list ) ] do
        both[i] := [ list[i], i ];
    od;

    # Sort the new list according to the first item (stable).
    # This needs more memory than a call of 'Sort' but is much faster.
    # (The change was proposed by Frank Luebeck.)
    both := Set( both );

    # copy back and remember the permutation
    perm := [];
    for i in [ 1 .. Length( list ) ] do
        list[i] := both[i][1];
        perm[i] := both[i][2];
    od;

    # return the permutation mapping old <list> onto the sorted list
    return PermList( perm )^(-1);
    end );


#############################################################################
##
#F  SortParallel( <list>, <list2> ) . . . . . . .  sort two lists in parallel
##
InstallMethod( SortParallel,
    "method for homogeneous mutable list and dense mutable list",
    true,
    [ IsHomogeneousList and IsMutable,
      IsDenseList and IsMutable ],
    0,
    function ( list, para )
    local   gap,        # gap width
            l, p,       # elements from <list> and <para>
            i, k;       # loop variables

    gap := 1;
    while 9*gap+4 < Length( list ) do
        gap := 3*gap+1;
    od;
    while 0 < gap do
        for i in [ gap+1 .. Length( list ) ] do
            l := list[i];
            p := para[i];
            k := i;
            while gap < k and l < list[k-gap] do
                list[k] := list[k-gap];
                para[k] := para[k-gap];
                k := k-gap;
            od;
            list[k] := l;
            para[k] := p;
        od;
        gap := QUO_INT( gap, 3 );
    od;
    end );


#############################################################################
##
#M  SortParallel( <empty>, <empty> )
##
InstallOtherMethod( SortParallel,
    "method for two empty lists",
    true,
    [ IsList and IsEmpty and IsMutable,
      IsList and IsEmpty and IsMutable ],
    0,
    Ignore );


#############################################################################
##
#M  SortParallel( <list>, <list2>, <func> )
##
InstallOtherMethod( SortParallel,
    "method for two dense and mutable lists, and function",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList and IsMutable,
      IsFunction ],
    0,

function ( list, para, isLess )
    local   gap,        # gap width
            l, p,       # elements from <list> and <para>
            i, k;       # loop variables

    gap := 1;
    while 9*gap+4 < Length( list ) do
        gap := 3*gap+1;
    od;
    while 0 < gap do
        for i in [ gap+1 .. Length( list ) ] do
            l := list[i];
            p := para[i];
            k := i;
            while gap < k and isLess( l, list[k-gap] ) do
                list[k] := list[k-gap];
                para[k] := para[k-gap];
                k := k-gap;
            od;
            list[k] := l;
            para[k] := p;
        od;
        gap := QUO_INT( gap, 3 );
    od;
end );


#############################################################################
##
#M  SortParallel( <empty>, <empty>, <func> )
##
InstallOtherMethod( SortParallel,
    "method for two empty lists, and function",
    true,
    [ IsList and IsEmpty and IsMutable,
      IsList and IsEmpty and IsMutable,
      IsFunction ],
    0,
    Ignore );


#############################################################################
##
#M  Maximum(<obj>,...)
##
Maximum := function ( arg )
    if Length( arg ) = 1 then
        return MaximumList( arg[1] );
    elif Length( arg ) > 2 then
        return MaximumList( arg );
    elif Length( arg ) = 2 then
        if arg[1] > arg[2] then
            return arg[1];
        else
            return arg[2];
        fi;
    else
        Error( "usage: Maximum( <arg1>,... )" );
    fi;
end;

InstallMethod( MaximumList,
    true, [ IsHomogeneousList ], 0,
    function ( list )
    local max, elm;
    if Length( list ) = 0 then
        Error( "MaximumList: <list> must contain at least one element" );
    fi;
    max := list[ Length( list ) ];
    for elm in list do
        if max < elm  then
            max := elm;
        fi;
    od;
    return max;
    end );

InstallMethod( MaximumList,
    true, [ IsRange ], 0,
    function ( range )
    local max;
    if Length( range ) = 0 then
        Error( "MaximumList: <range> must contain at least one element" );
    fi;
    max := range[ Length( range ) ];
    if max < range[1] then
        return range[1];
    fi;
    return max;
    end );


#############################################################################
##
#M  Minimum(<obj>,...)
##
Minimum := function ( arg )
    if Length( arg ) = 1 then
        return MinimumList( arg[1] );
    elif Length( arg ) > 2 then
        return MinimumList( arg );
    elif Length( arg ) = 2 then
        if arg[1] < arg[2] then
            return arg[1];
        else
            return arg[2];
        fi;
    else
        Error( "usage: Minimum( <arg1>,... )" );
    fi;
end;

InstallMethod( MinimumList,
    true, [ IsHomogeneousList ], 0,
    function ( list )
    local min, elm;
    if Length( list ) = 0 then
        Error( "MinimumList: <list> must contain at least one element" );
    fi;
    min := list[ Length( list ) ];
    for elm  in list  do
        if elm < min then
            min := elm;
        fi;
    od;
    return min;
    end );

InstallMethod( MinimumList,
    true, [ IsRange ], 1,
    function ( range )
    local min;
    if Length( range ) = 0 then
        Error( "MinimumList: <range> must contain at least one element" );
    fi;
    min := range[ Length( range ) ];
    if range[1] < min then
        return range[1];
    fi;
    return min;
    end );


#############################################################################
##
#M  Cartesian(<list>,...)
##
Cartesian2 := function ( list, n, tup, i )
    local  tups,  l;
    if i = n+1  then
        tup := ShallowCopy(tup);
        tups := [ tup ];
    else
        tups := [];
        for l  in list[i]  do
            tup[i] := l;
            Append( tups, Cartesian2( list, n, tup, i+1 ) );
        od;
    fi;
    return tups;
end;

Cartesian := function ( arg )
    if Length(arg) = 1  then
        return Cartesian2( arg[1], Length(arg[1]), [], 1 );
    else
        return Cartesian2( arg, Length(arg), [], 1 );
    fi;
end;


#############################################################################
##
#M  Permuted(<list>,<perm>) . . . . . apply permutation <perm> to list <list>
##
InstallMethod( Permuted,
    true, [ IsList, IS_PERM ], 0,
    function ( list, perm )
    # this was proposed by Jean Michel
    return list{ OnTuples( [ 1 .. Length( list ) ], perm^-1 ) };
    end );


#############################################################################
##
#M  First(<C>,<func>) . . . . .  find first element in a list with a property
##
InstallMethod( First,
    true, [ IsList, IsFunction ], 0,
    function ( C, func )
    local elm;
    for elm in C do
        if func( elm ) then
            return elm;
        fi;
    od;
    return fail;
    end );

#############################################################################
##
#F  Apply(list,func)
##
Apply := function(list,func)
local i;
  for i in [1..Length(list)] do
    list[i]:=func(list[i]);
  od;
end;

#############################################################################
##
#M  Iterated(<list>,<func>) . . . . . . . . .  iterate a function over a list
##
InstallMethod( Iterated,
    true, [ IsList, IsFunction ], 0,
    function ( list, func )
    local   res, i;
    if Length( list ) = 0 then
        Error( "Iterated: <list> must contain at least one element" );
    fi;
    res := list[1];
    for i in [ 2 .. Length( list ) ] do
        res := func( res, list[i] );
    od;
    return res;
end );
    
#############################################################################
##
#M  IsBound(list[i]) . . . . . . . . . . . . . . . . .IsBound for Dense lists
##
    
InstallMethod( IsBound\[\], true, [ IsDenseList, IsInt ], 0,
        function( list, index )
    return index > 0 and index <= Length(list);
end);
    

#############################################################################
##
#M  methods for arithmetic operations
##
InstallMethod( ZERO,
    true, [ IsAdditiveElementWithZeroList ], 0,
    ZERO_LIST_DEFAULT );

InstallMethod( AINV,
    true, [ IsAdditiveElementWithInverseList ], 0,
    AINV_LIST_DEFAULT );


InstallOtherMethod( DIFF,
    IsElmsColls, [ IsAdditiveElementWithInverse, IsExtAElementList ], 0,
    DIFF_SCL_LIST_DEFAULT );

InstallOtherMethod( DIFF,
    true,        [ IsAdditiveElementWithInverse, IsList and IsEmpty ], 0,
    DIFF_SCL_LIST_DEFAULT );

InstallMethod( DIFF,
    IsCollsElms, [ IsExtAElementList, IsAdditiveElementWithInverse ], 0,
    DIFF_LIST_SCL_DEFAULT );

InstallOtherMethod( DIFF,
    true,        [ IsList and IsEmpty, IsAdditiveElementWithInverse ], 0,
    DIFF_LIST_SCL_DEFAULT );

InstallOtherMethod( DIFF,
    IsElmsCollColls, [ IsAdditiveElementWithInverse, IsExtAElementTable ], 0,
    DIFF_SCL_LIST_DEFAULT );

InstallOtherMethod( DIFF,
    IsCollCollsElms, [ IsExtAElementTable, IsAdditiveElementWithInverse ], 0,
    DIFF_LIST_SCL_DEFAULT );

InstallMethod( DIFF,
    IsIdentical,
    [ IsAdditiveElementWithInverseList, IsAdditiveElementWithInverseList ], 0,
    DIFF_LIST_LIST_DEFAULT );


InstallOtherMethod( ONE,
    true, [ IsMatrix ], 0,
    ONE_MATRIX );

InstallOtherMethod( INV,
    true, [ IsMatrix ], 0,
    INV_MATRIX );

InstallOtherMethod( POW,
    true, [ IsRingElementList, IsRingElementTable ], 0, PROD );


#############################################################################
##
#F  <list> + <list>
##
InstallMethod( \+,
    "additive element + ext-a-element list",
    IsElmsColls,
    [ IsAdditiveElement,
      IsExtAElementList ],
    0,
    SUM_SCL_LIST_DEFAULT );


InstallOtherMethod( \+,
    "additive element + empty list",
    true,
    [ IsAdditiveElement,
      IsList and IsEmpty ],
    0,
    SUM_SCL_LIST_DEFAULT );


InstallMethod( \+,
    "ext-a-element list + additive element",
    IsCollsElms,
    [ IsExtAElementList,
      IsAdditiveElement ],
    0,
    SUM_LIST_SCL_DEFAULT );


InstallOtherMethod( \+,
    "empty list + additive element",
    true,
    [ IsList and IsEmpty,
      IsAdditiveElement ],
    0,
    SUM_LIST_SCL_DEFAULT );


InstallOtherMethod( \+,
    "additive element + ext-a-element table",
    IsElmsCollColls,
    [ IsAdditiveElement,
      IsExtAElementTable ],
    0,
    SUM_SCL_LIST_DEFAULT );


InstallOtherMethod( \+,
    "ext-a-element table + additive element",
    IsCollCollsElms,
    [ IsExtAElementTable,
      IsAdditiveElement ],
    0,
    SUM_LIST_SCL_DEFAULT );

InstallMethod( \+,
    "additive element list + additive element list",
    IsIdentical,
    [ IsAdditiveElementList,
      IsAdditiveElementList ],
    0,
    SUM_LIST_LIST_DEFAULT );


#############################################################################
##
#M  <list> * <list>
##
InstallMethod( \*,
    "multiplicative element * ext-l-element list",
    IsElmsColls,
    [ IsMultiplicativeElement,
      IsExtLElementList ],
    0,
    PROD_SCL_LIST_DEFAULT );


InstallOtherMethod( \*,
    "multiplicative element * empty list",
    true,
    [ IsMultiplicativeElement,
      IsList and IsEmpty ],
    0,
    PROD_SCL_LIST_DEFAULT );


InstallMethod( \*,
    "ext-r-element list * multiplicative element",
    IsCollsElms,
    [ IsExtRElementList,
      IsMultiplicativeElement ],
    0,
    PROD_LIST_SCL_DEFAULT );


InstallOtherMethod( \*,
    "empty list * multiplicative element",
    true,
    [ IsList and IsEmpty,
      IsMultiplicativeElement ],
    0,
    PROD_LIST_SCL_DEFAULT );


InstallOtherMethod( \*,
    "multiplicative element * ext-l-element table",
    IsElmsCollColls,
    [ IsMultiplicativeElement,
      IsExtLElementTable ],
    0,
    PROD_SCL_LIST_DEFAULT );


InstallOtherMethod( \*,
    "ext-r-element * multiplicative element",
    IsCollCollsElms,
    [ IsExtRElementTable,
      IsMultiplicativeElement ],
    0,
    PROD_LIST_SCL_DEFAULT );


InstallMethod( \*,
    "ring element list * ring element list",
    IsIdentical,
    [ IsRingElementList,
      IsRingElementList ],
    0,
    PROD_LIST_LIST_DEFAULT );


InstallOtherMethod( \*,
    "ring element list * ring element table",
    IsElmsColls,
    [ IsRingElementList,
      IsRingElementTable ],
    0,
    PROD_LIST_LIST_DEFAULT );


InstallOtherMethod( \*,
    "cyclotomics list * ffe table",
    true,
    [ IsRingElementList and IsCyclotomicsCollection,
      IsRingElementTable and IsFFECollColl ],
    0,
    PROD_LIST_LIST_DEFAULT );


InstallOtherMethod( \*,
    "ffe list * cyclotomics table",
    true,
    [ IsRingElementList and IsFFECollection,
      IsRingElementTable and IsCyclotomicsCollColl ],
    0,
    PROD_LIST_LIST_DEFAULT );


InstallOtherMethod( \*,
    "ring element table * ring element list",
    IsCollsElms,
    [ IsRingElementTable,
      IsRingElementList ],
    0,
    PROD_LIST_SCL_DEFAULT );


InstallOtherMethod( \*,
    "ring element table * ring element table",
    IsIdentical,
    [ IsRingElementTable,
      IsRingElementTable ],
    0,
    PROD_LIST_SCL_DEFAULT );


InstallOtherMethod( \*,
    "cyclotomics table * ffe table",
    true,
    [ IsRingElementTable and IsCyclotomicsCollColl,
      IsRingElementTable and IsFFECollColl ],
    0,
    PROD_LIST_SCL_DEFAULT );


InstallOtherMethod( \*,
    "ffe table * cyclotomics table",
    true,
    [ IsRingElementTable and IsFFECollColl,
      IsRingElementTable and IsCyclotomicsCollColl ],
    0,
    PROD_LIST_SCL_DEFAULT );


#############################################################################
##
#M  \*( <elm>, <list> ) . . . . . . . . . . . . . . . . .  for non-list <elm>
##
##  If <elm> is not a list then we return the list of products of <elm> with
##  the entries of the list <list>.
##
InstallOtherMethod( \*,
    "product of mult. element that is not a list, and list",
    true,
    [ IsMultiplicativeElement,
      IsList ],
    0,
    function( elm, list )
    local new, i;
    if IsList( elm ) then
      TryNextMethod();
    fi;
    new:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        new[i]:= elm * list[i];
      fi;
    od;
    return Immutable( new );
    end );


#############################################################################
##
#M  \*( <list>, <elm> ) . . . . . . . . . . . . . . . . .  for non-list <elm>
##
##  If <elm> is not a list then we return the list of products of the entries
##  of the list <list> with <elm>.
##
InstallOtherMethod( \*,
    "product of list and mult. element that is not a list",
    true,
    [ IsList,
      IsMultiplicativeElement ],
    0,
    function( list, elm )
    local new, i;
    if IsList( elm ) then
      TryNextMethod();
    fi;
    new:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        new[i]:= list[i] * elm;
      fi;
    od;
    return Immutable( new );
    end );


#############################################################################
##
#F  DifferenceBlist
##
DifferenceBlist := function(a,b)
  a:=ShallowCopy(a);
  SubtractBlist(a,b);
  return a;
end;


#############################################################################
##
#F  ListWithIdenticalEntries( <n>, <obj> )
##
ListWithIdenticalEntries := function( n, obj )
    local list, i;
    list:= [];
    for i in [ 1 .. n ] do
      list[i]:= obj;
    od;
    return list;
end;


#############################################################################
##
#F  ProductPol( <coeffs_f>, <coeffs_g> )  . . . .  product of two polynomials
##
ProductPol := function( f, g )
    local  prod,  q,  m,  n,  i,  k;
    m := Length(f);  while 1 < m  and f[m] = 0  do m := m-1;  od;
    n := Length(g);  while 1 < n  and g[n] = 0  do n := n-1;  od;
#T other zero elements are not allowed?
    prod := [];
    for i  in [ 2 .. m+n ]  do
        q := 0;
        for k  in [ Maximum(1,i-n) .. Minimum(m,i-1) ]  do
            q := q + f[k] * g[i-k];
        od;
        prod[i-1] := q;
    od;
    return prod;
end;


#############################################################################
##
#F  ValuePol( <coeffs_f>, <x> ) . . . . . .  evaluate a polynomial at a point
##
ValuePol := function( f, x )
    local  value, i, id;
    id := x ^ 0;
    value := 0 * id;
    i := Length(f);
    while 0 < i  do
        value := value * x + id * f[i];
        i := i-1;
    od;
    return value;
end;


#############################################################################
##

#E  list.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


