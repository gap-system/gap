#############################################################################
##
#W  list.gi                     GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains methods for lists in general.
##
Revision.list_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  methods for comparisons
##
##  The default method `EQ_LIST_LIST_DEFAULT' is applicable only to small
##  lists in the sense of `IsSmallList'.
##  For finite lists that do not know to be small, first this property is
##  checked, and if the lists are not small then the loop is done in {\GAP}.
##
InstallMethod( EQ,
    "for two small lists",
    IsIdenticalObj,
    [ IsList and IsSmallList, IsList and IsSmallList ], 0,
    EQ_LIST_LIST_DEFAULT );

InstallMethod( EQ,
    "for two finite lists (not necessarily small)",
    IsIdenticalObj,
    [ IsList and IsFinite, IsList and IsFinite ], 0,
    function( list1, list2 )

    local len, i;

    # We ask for being small in order to catch the default methods
    # directly in the next call if possible.
    if IsSmallList( list1 ) then
      if IsSmallList( list2 ) then
        return EQ_LIST_LIST_DEFAULT( list1, list2 );
      else
        return false;
      fi;
    elif IsSmallList( list2 ) then
      return false;
    else

      # None of the lists is small.
      len:= Length( list1 );
      if len <> Length( list2 ) then
        return false;
      fi;

      i:= 1;
      while i <= len do
        if IsBound( list1[i] ) then
          if IsBound( list2[i] ) then
            if list1[i] <> list2[i] then
              return false;
            fi;
          else
            return false;
          fi;
        elif IsBound( list2[i] ) then
          return false;
        fi;
        i:= i+1;
      od;
      return true;

    fi;
    end );


InstallMethod( EQ,
    "for two lists, the first being empty",
    true,
    [ IsList and IsEmpty, IsList ], SUM_FLAGS,
    function( empty, list )
    return IsEmpty( list );
    end );


InstallMethod( EQ,
    "for two lists, the second being empty",
    true,
    [ IsList, IsList and IsEmpty ], SUM_FLAGS,
    function( list, empty )
    return IsEmpty( list );
    end );


InstallMethod( LT,
    "for two small homogeneous lists",
    IsIdenticalObj,
    [ IsHomogeneousList and IsSmallList,
      IsHomogeneousList and IsSmallList ], 0,
    LT_LIST_LIST_DEFAULT );

InstallMethod( LT,
    "for two finite homogeneous lists (not necessarily small)",
    IsIdenticalObj,
    [ IsHomogeneousList and IsFinite, IsHomogeneousList and IsFinite ], 0,
    LT_LIST_LIST_FINITE );


#############################################################################
##
#M  \in( <obj>, <list> )
##
InstallMethod( IN,
    "for an object, and an empty list",
    true,
    [ IsObject, IsList and IsEmpty ], 0,
    ReturnFalse );


#############################################################################
##
#M  <elm> \in <whole-family>
##
InstallMethod( IN,
    "for an object, and a collection that contains the whole family",
    IsElmsColls,
    [ IsObject, IsCollection and IsWholeFamily ],
    SUM_FLAGS,
    RETURN_TRUE );

InstallMethod( IN,
    "for wrong family relation",
    IsNotElmsColls,
    [ IsObject, IsCollection ], 0,
    ReturnFalse );

InstallMethod( IN,
    "for an object, and a small list",
    IsElmsColls,
    [ IsObject, IsList and IsSmallList ], 0,
    IN_LIST_DEFAULT );

InstallMethod( IN,
    "for an object, and a finite list",
    IsElmsColls,
    [ IsObject, IsList and IsFinite ], 0,
    function( elm, list )
    local len, i;
    if IsSmallList( list ) then
      return IN_LIST_DEFAULT( elm, list );
    else
      len:= Length( list );
      i:= 1;
      while i <= len do
        if IsBound( list[i] ) and elm = list[i] then
          return true;
        fi;
        i:= i+1;
      od;
      return false;
    fi;
    end );


#############################################################################
##
#M  String( <list> )  . . . . . . . . . . . . . . . . . . . . . .  for a list
#M  String( <range> ) . . . . . . . . . . . . . . . . . . . . . . for a range
##
InstallMethod( String,
    "for a (finite) list",
    true,
    [ IsList ], 0,
    function ( list )
    local   str, i;

    # Check that we are in the right method.
    if not IsFinite( list ) then
      TryNextMethod();
    fi;

    # We cannot handle the case of an empty string in the method for strings
    # because the type of the empty string need not satify the requirement
    # `IsString'.
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
    "for a range",
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
#M  Size( <list> )  . . . . . . . . . . . . . . . . . . . . . . .  for a list
##
InstallOtherMethod( Size,
    "for a list",
    true,
    [ IsList ],
    0,
    Length );

InstallOtherMethod( Size,
    "for a list that is a collection",
    true,
    [ IsList and IsCollection ],
    0,
    Length );


#############################################################################
##
#M  Representative( <list> )
##
InstallOtherMethod( Representative,
    "for a list",
    true,
    [ IsList ],
    0,
    function( list )
    local elm;
    for elm in list do
      return elm;
    od;
    Error( "<list> must be nonempty to have a representative" );
    end );


#############################################################################
##
#M  RepresentativeSmallest( <list> )
##
InstallOtherMethod( RepresentativeSmallest,
    "for an empty list",
    true, [ IsList and IsEmpty ], 0,
    function ( list )
    Error( "<C> must be nonempty to have a representative" );
    end );

InstallOtherMethod( RepresentativeSmallest,
    "for a strictly sorted list",
    true, [ IsSSortedList ], 0,
    function ( list )
    return list[1];
    end );

InstallOtherMethod( RepresentativeSmallest,
    "for a homogeneous list",
    true, [ IsHomogeneousList ], 0,
    MinimumList );


#############################################################################
##
#M  Random( <list> )  . . . . . . . . . . . . . . . .  for a dense small list
##
InstallOtherMethod( Random,
    "for a dense small list",
    true,
    [ IsList and IsDenseList and IsSmallList ], 0,
    RANDOM_LIST );

InstallOtherMethod( Random,
    "for a dense (small) list",
    true,
    [ IsList and IsDenseList ], 0,
    function( list )
    if IsSmallList( list ) then
      return RANDOM_LIST( list );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsSmallList( <list> )
##
InstallMethod( IsSmallList,
    "for a list",
    true,
    [ IsList ], 0,
    list -> Length( list ) <= MAX_SIZE_LIST_INTERNAL );


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

    InstallMethod( op,
        "for a list",
        true,
        [ IsList ], 0,
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

    InstallMethod( op,
        "for a strictly sorted list",
        true,
        [ IsList and IsSSortedList ], 0,
        function( list )
        local   new,  i;

        new:= [  ];
        for i  in [ 1 .. Length( list ) ]  do
            if IsBound( list[ i ] )  then
                new[ i ] := list[ i ];
            fi;
        od;
        SetIsSSortedList( new, true );
        return new;
    end );

    InstallMethod( op,
        "for a dense list",
        true,
        [ IsList and IsDenseList ], 0,
        function( list )
        if IsSmallList( list ) then
            return list{ [ 1 .. Length( list ) ] };
        else
            Error( "resulting list would be too large (length ",
                   Length( list ), ")" );
        fi;
    end );

    InstallMethod( op,
        "for a strictly sorted dense list",
        true,
        [ IsList and IsDenseList and IsSSortedList ], 0,
        function( list )
        if IsSmallList( list ) then
            list:= list{ [ 1 .. Length( list ) ] };
            SetIsSSortedList( list, true );
            return list;
        else
            Error( "resulting list would be too large (length ",
                   Length( list ), ")" );
        fi;
    end );

od;

InstallMethod( ConstantTimeAccessList,
    "for a constant time access list",
    true,
    [ IsList and IsConstantTimeAccessList ], SUM_FLAGS,
    Immutable );


#############################################################################
##
#M  AsList( <list> )
##
InstallOtherMethod( AsList,
    "for a list",
    true,
    [ IsList ],
    0,
    list -> ConstantTimeAccessList( Enumerator( list ) ) );

InstallOtherMethod( AsList,
    "for a constant time access list",
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
    "for a list",
    true,
    [ IsList ],
    0,
    list -> ConstantTimeAccessList( EnumeratorSorted( list ) ) );

InstallOtherMethod( AsListSorted,
    "for a constant time access list",
    true,
    [ IsList and IsConstantTimeAccessList ],
    0,
    AsListSortedList );


#############################################################################
##
#M  Enumerator( <list> )
##
InstallOtherMethod( Enumerator,
    "for a list",
    true, [ IsList ], 0,
    Immutable );


#############################################################################
##
#M  EnumeratorSorted( <list> )
##
InstallOtherMethod( EnumeratorSorted,
    "for a list",
    true, [ IsList ], 0,
    AsListSortedList );


#############################################################################
##
#M  ListOp( <list> )
#M  ListOp( <list>, <func> )
##
InstallOtherMethod( ListOp,
    "for a list",
    true,
    [ IsList ], 0,
    ShallowCopy );

InstallOtherMethod( ListOp,
    "for a dense list",
    true,
    [ IsList and IsDenseList ], 0,
    list -> list{ [ 1 .. Length( list ) ] } );

InstallOtherMethod( ListOp,
    "for a list, and a function",
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
    "for a list",
    true, [ IsList ], 0,
    ListSortedList );


#############################################################################
##
#M  ListSorted( <list>, <func> )
##
InstallOtherMethod( ListSorted,
    "for a list, and a function",
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
#M  Iterator( <list> )
##
DeclareRepresentation( "IsListIteratorRep",
        IsComponentObjectRep, "pos, list" );

InstallMethod( IsDoneIterator,
    "for a list iterator",
    true, [ IsIterator and IsListIteratorRep ], 0,
    iter -> (iter!.pos = Length( iter!.list )) );

InstallMethod( NextIterator,
    "for a list iterator",
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

InstallGlobalFunction( IteratorList, function ( list )
    local   iter;
    iter := rec(
        list := list,
        pos  := 0
    );
    return Objectify( NewType( IteratorsFamily, IsListIteratorRep ), iter );
end );

InstallOtherMethod( Iterator,
    "for a list",
    true, [ IsList ], 0,
    IteratorList );


#############################################################################
##
#M  IteratorSorted(<list>)
##
InstallOtherMethod( IteratorSorted,
    "for a list",
    true, [ IsList ], 0,
    list -> IteratorList( ListSortedList( list ) ) );


#############################################################################
##
#M  SumOp( <list> ) . . . . . . . . . . . . . . . . . . . .  for a dense list
##
InstallOtherMethod( SumOp,
    "for a dense list",
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
#M  SumOp( <list>, <init> ) . . . . . . . . . . for a list, and initial value
##
InstallOtherMethod( SumOp,
    "for a list, and initial value",
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
#M  SumOp( <list>, <func> ) . . . . . . . .  for a dense list, and a function
##
InstallOtherMethod( SumOp,
    "for a dense list, and a function",
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
#M  SumOp( <list>, <func>, <init> ) . . . for list, function, and init. value
##
InstallOtherMethod( SumOp,
    "for a list, a function, and initial value",
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
#M  ProductOp( <list> ) . . . . . . . . . . . . . . . . . .  for a dense list
##
InstallOtherMethod( ProductOp,
    "for a dense list",
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
#M  ProductOp( <list>, <init> ) . . . . . . . . for a list, and initial value
##
InstallOtherMethod( ProductOp,
    "for a list, and initial value",
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
#M  ProductOp( <list>, <func> ) . . . . . .  for a dense list, and a function
##
InstallOtherMethod( ProductOp,
    "for a dense list and a function",
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
#M  ProductOp( <list>, <func>, <init> ) . for list, function, and init. value
##
InstallOtherMethod( ProductOp,
    "for a list, a function, and initial value",
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
    "for a list and a small dense list",
    true, [ IsList, IsDenseList and IsSmallList ], 0,
    ELMS_LIST_DEFAULT );

InstallMethod( ELMS_LIST,
    "for a list and a dense list",
    true, [ IsList, IsDenseList ], 0,
    function( list, poslist )
    if IsSmallList( poslist ) then
      return ELMS_LIST_DEFAULT( list, poslist );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( ASSS_LIST,
    "for a mutable list, a small dense list, and a list",
    true, [ IsList and IsMutable, IsDenseList and IsSmallList, IsList ], 0,
    ASSS_LIST_DEFAULT );

InstallMethod( ASSS_LIST,
    "for a mutable list, a dense list, and a list",
    true, [ IsList and IsMutable, IsDenseList, IsList ], 0,
    function( list, poslist, vallist )
    if IsSmallList( poslist ) and IsSmallList( vallist ) then
      return ASSS_LIST_DEFAULT( list, poslist, vallist );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsSSortedList(<list>)
##
InstallMethod( IsSSortedList,
    "for a small homogeneous list",
    true, [ IsHomogeneousList and IsSmallList ], 0,
    IS_SSORT_LIST_DEFAULT );

InstallMethod( IsSSortedList,
    "for a homogeneous list",
    true, [ IsHomogeneousList ], 0,
    function( list )
    if IsSmallList( list ) then
      return IS_SSORT_LIST_DEFAULT( list );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsDuplicateFreeList(<list>)
##
InstallMethod( IsDuplicateFreeList,
    "for a finite list",
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
    "for a small homogeneous list",
    true,
    [ IsHomogeneousList and IsSmallList ], 0,
    IS_POSS_LIST_DEFAULT );

InstallMethod( IsPositionsList,
    "for a homogeneous list",
    true,
    [ IsHomogeneousList ], 0,
    function( list )
    if IsSmallList( list ) then
      return IS_POSS_LIST_DEFAULT( list );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Position(<list>,<obj>,<from>)
##
InstallMethod( Position,
    "for a small list, an object, and an integer",
    true,
    [ IsList and IsSmallList, IsObject, IsInt ], 0,
    function( list, obj, start )
    local   pos;
    pos := POS_LIST_DEFAULT( list, obj, start );
    if pos = 0  then  return fail;
                else  return pos;   fi;
    end );

InstallMethod( Position,
    "for a (small) list, an object, and an integer",
    true,
    [ IsList, IsObject, IsInt ], 0,
    function( list, obj, start )
    local pos;
    if IsSmallList( list ) then
      pos:= POS_LIST_DEFAULT( list, obj, start );
      if pos = 0 then return fail;
                 else return pos; fi;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( Position,
    "for a homog. list, an object not in the elements family, and an int.",
    function( F1, F2, F3 )
        return HasElementsFamily(F1)
           and not IsIdenticalObj( ElementsFamily(F1), F2 );
    end,
    [ IsHomogeneousList,
      IsObject,
      IsInt ],
    0,
    RETURN_FAIL );

#N  1996/08/14 M.Schoenert 'POSITION_SORTED_LIST' should take 3 arguments
InstallMethod( Position,
    "for a small sorted list, an object, and an integer",
    true,
    [ IsSSortedList and IsSmallList, IsObject, IsInt ], 0,
    function ( list, obj, start )
    local   pos;

    if start = 0 then  pos := POSITION_SORTED_LIST( list, obj );
                 else  pos := POS_LIST_DEFAULT( list, obj, start );  fi;
    if pos = 0  then  return fail;
                else  return pos;   fi;
end );

InstallMethod( Position,
    "for a sorted list, an object, and an integer",
    true,
    [ IsSSortedList, IsObject, IsInt ], 0,
    function ( list, obj, start )
    local   pos;
    if IsSmallList( list ) then
      if start = 0 then  pos := POSITION_SORTED_LIST( list, obj );
                   else  pos := POS_LIST_DEFAULT( list, obj, start );  fi;
      if pos = 0  then  return fail;
                  else  return pos;   fi;
    else
      TryNextMethod();
    fi;
end );

#############################################################################
##
#M  Position(<list>,<obj>,<from>)
##
##  The following method is installed for external lists since internal lists
##  do not store whether they are duplicate free.
##  For external lists such as special enumerators of domains,
##  e.g.~`Integers', one needs only a special method for `Position' with
##  third argument zero (installed with requirement `IsZeroCyc'),
##  the case of a positive third argument is then handled by the following
##  generic method.
##
InstallMethod( Position,
    "for duplicate free list, object, and positive integer",
    true,
    [ IsDuplicateFreeList, IsObject, IsPosInt ], 0,
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
InstallMethod( PositionCanonical,
    "fall back on `Position'",
    IsCollsElms,
    [ IsList, IsObject ], 0,
    function( list, obj )
    return Position( list, obj, 0 );
    end );


#############################################################################
##
#M  PositionNthOccurence( <list>, <obj>, <n> )  . . call `Position' <n> times
##
InstallMethod( PositionNthOccurence,
    "for list, object, integer",
    true,
    [ IsList, IsObject, IsInt ], 0,
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
    "for boolean list, boolean, integer",
    true,
    [ IsBlist, IsBool, IsInt ], 0,
    function( blist, bool, n )
    if bool then  return PositionNthTrueBlist( blist, n );
            else  TryNextMethod();                          fi;
    end );


#############################################################################
##
#M  PositionSorted( <list>, <obj> )
#M  PositionSorted( <list>, <obj>, <func> )
##
InstallMethod( PositionSorted,
    "for small homogeneous list and object",
    true,
    [ IsHomogeneousList and IsSmallList, IsObject ], 0,
    POSITION_SORTED_LIST );

InstallMethod( PositionSorted,
    "for homogeneous list and object",
    true,
    [ IsHomogeneousList, IsObject ], 0,
    function( list, elm )
    if IsSmallList( list ) then
      return POSITION_SORTED_LIST( list, elm );
    else
      TryNextMethod();
    fi;
    end );

InstallOtherMethod( PositionSorted,
    "for small homogeneous list, object, and function",
    true,
    [ IsHomogeneousList and IsSmallList, IsObject, IsFunction ], 0,
    POSITION_SORTED_LIST_COMP );

InstallOtherMethod( PositionSorted,
    "for homogeneous list, object, and function",
    true,
    [ IsHomogeneousList, IsObject, IsFunction ], 0,
    function( list, elm, func )
    if IsSmallList( list ) then
      return POSITION_SORTED_LIST_COMP( list, elm, func );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#F  PositionSet( <list>, <obj> )
#F  PositionSet( <list>, <obj>, <func> )
##
InstallGlobalFunction( PositionSet, function( arg )
    local list, obj, pos;
    if Length( arg ) = 2 and IsList( arg[1] ) then
      list := arg[1];
      obj  := arg[2];
      pos  := PositionSorted( list, obj );
    elif Length( arg ) = 3 and IsList( arg[1] ) and IsFunction( arg[3] ) then
      list := arg[1];
      obj  := arg[2];
      pos  := PositionSorted( list, obj, arg[3] );
    else
      Error( "usage: PositionSet( <list>, <elm>[, <func>] )" );
    fi;

    if ( not IsBound( list[ pos ] ) ) or list[ pos ] <> obj then
      pos:= fail;
    fi;
    return pos;
    end );


#############################################################################
##
#M  PositionProperty(<list>,<func>) .  position of an element with a property
##
InstallMethod( PositionProperty,
    "for dense list and function",
    true,
    [ IsDenseList, IsFunction ], 0,
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
#M  PositionBound( <list> ) . . . . . . . . . . position of first bound entry
##
InstallMethod( PositionBound,
    "for a dense list",
    true,
    [ IsList ], 0,
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
#M  Add( <list>, <obj> )
##
InstallMethod( Add,
    "for mutable list and list",
    true,
    [ IsList and IsMutable, IsObject ], 0,
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
    "for mutable list and list",
    true,
    [ IsList and IsMutable, IsList ],
    0,
    APPEND_LIST_DEFAULT );


InstallMethod( Append,
    "for mutable list in plist representation and list",
    true,
    [ IsList and IsPlistRep and IsMutable, IsList ],
    0,
    APPEND_LIST_INTR );


#############################################################################
##
#F  Apply( <list>, <func> ) . . . . . . . .  apply a function to list entries
##
InstallGlobalFunction( Apply, function( list, func )
    local i;
    for i in [1..Length( list )] do
        list[i] := func( list[i] );
    od;
end );


#############################################################################
##
#M  Concatenation( <list>, ... )
##
InstallGlobalFunction( Concatenation, function ( arg )
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
end );


#############################################################################
##
#M  Compacted( <list> ) . . . . . . . . . . . . . .  remove holes from a list
##
InstallMethod( Compacted,
    "for a list",
    true,
    [ IsList ], 0,
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
#M  Collected( <list> ) . . . . .
##
InstallMethod( Collected,
    "for a list",
    true,
    [ IsList ], 0,
    function ( list )
    local   res,        # collected, result
            col,        # one element of collected list
            sorted,     # list in sorted order
            elm;        # one element of list

    # special case for empty list
    if IsEmpty( list ) then
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
#M  DuplicateFreeList( <list> )  . . . . duplicate free list of list elements
##
InstallMethod( DuplicateFreeList,
    "for a list",
    true,
    [ IsList ], 0,
    function ( list )
    local l,i;
    l:= [];
    for i in list do
      if not i in l then
        Add(l,i);
      fi;
    od;
    return l;
    end );


#############################################################################
##
#M  AsDuplicateFreeList( <list> )  . . . duplicate free list of list elements
##
InstallMethod( AsDuplicateFreeList,
    "for a list",
    true,
    [ IsList ], 0,
    DuplicateFreeList );


#############################################################################
##
#M  Flat( <list> )  . . . . . . . list of elements of a nested list structure
##
InstallMethod( Flat,
    "for a list",
    true,
    [ IsList ], 0,
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
#M  Reversed( <list> )  . . . . . . . . . . .  reverse the elements in a list
##
InstallMethod( Reversed,
    "for a dense list",
    true,
    [ IsDenseList ], 0,
    function ( list )
    local len;

    if not IsFinite( list ) then
      TryNextMethod();
    fi;

    len:= Length( list );
    return list{ [ len, len-1 .. 1 ] };
    end );

InstallMethod( Reversed,
    "for a range",
    true,
    [ IsRange ], 0,
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
    "for a mutable small list",
    true,
    [ IsList and IsMutable and IsSmallList ], 0,
    SORT_LIST );

InstallMethod( Sort,
    "for a mutable list",
    true,
    [ IsList and IsMutable ], 0,
    function( list )
    if IsSmallList( list ) then
      SORT_LIST( list );
    else
      TryNextMethod();
    fi;
    end );

InstallOtherMethod( Sort,
    "for a mutable small list and a function",
    true,
    [ IsList and IsMutable and IsSmallList, IsFunction ],
    0,
    SORT_LIST_COMP );

InstallOtherMethod( Sort,
    "for a mutable list and a function",
    true,
    [ IsList and IsMutable, IsFunction ],
    0,
    function( list, func )
    if IsSmallList( list ) then
      SORT_LIST_COMP( list, func );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#F  Lexicographically( <list1>, <list2> )
##
InstallGlobalFunction( Lexicographically, function( list1, list2 )
    local len, i;
    len:= Minimum( Length( list1 ), Length( list2 ) );
    for i in [ 1 .. len ]  do
      if list1[i] < list2[i] then
        return true;
      elif list2[i] < list1[i] then
        return false;
      fi;
    od;
    return len < Length( list2 );
end );


#############################################################################
##
#M  Sortex(<list>) . . . sort a list (stable), return the applied permutation
##
InstallMethod( Sortex,
    "for a mutable homogeneous list",
    true,
    [ IsHomogeneousList and IsMutable ], 0,
    function ( list )
    local   both, perm, i;

    # {\GAP} supports permutations only up to `MAX_SIZE_LIST_INTERNAL'.
    if not IsSmallList( list ) then
      Error( "<list> must have length at most ", MAX_SIZE_LIST_INTERNAL );
    fi;

    # make a new list that contains the elements of <list> and their indices
    both := [];
    for i in [ 1 .. Length( list ) ] do
        both[i] := [ list[i], i ];
    od;

    # Sort the new list according to the first item (stable).
    # This needs more memory than a call of 'Sort' but is much faster.
    # (The change was proposed by Frank Luebeck.)
    both := Set( both );

    # Copy back and remember the permutation.
    perm := [];
    for i in [ 1 .. Length( list ) ] do
        list[i] := both[i][1];
        perm[i] := both[i][2];
    od;

    # If the entries are immutable then store that the list is sorted.
    IsSSortedList( list );

    # return the permutation mapping old <list> onto the sorted list
    return PermList( perm )^(-1);
    end );


#############################################################################
##
#F  PermListList( <list1>, <list2> )   what permutation of <list1> is <list2>
##
InstallGlobalFunction( PermListList, function( list1, list2 )
    local perm;

    # to not destroy list1 and list2
    list1:= ShallowCopy(list1);
    list2:= ShallowCopy(list2);

    perm:= Sortex( list2 ) / Sortex( list1 );
    if list1 <> list2 then 
      return fail;
    else
      return perm;
    fi;
end );


#############################################################################
##
#M  SortingPerm( <list> )
##
InstallGlobalFunction( SortingPerm, function( list )                                         
    local  both, perm, i, l;

    # {\GAP} supports permutations only up to `MAX_SIZE_LIST_INTERNAL'.
    if not IsSmallList( list ) then
      Error( "<list> must have length at most ", MAX_SIZE_LIST_INTERNAL );
    fi;

    # make a new list that contains the elements of <list> and their indices
    both := [];
    l:= Length( list );
    for i in [ 1 .. l ] do
        both[i] := [ list[i], i ];
    od;

    # Sort the new list according to the first item (stable).
    # This needs more memory than a call of 'Sort' but is much faster.
    # (The change was proposed by Frank Luebeck.)
    both := Set( both );

    # Remember the permutation.
    perm := [];
    perm{ [ 1 .. l ] }:= both{ [ 1 .. l ] }[2];

    # return the permutation mapping <list> onto the sorted list
    return PermList( perm )^(-1);
    end );


#############################################################################
##
#M  SortParallel( <list>, <list2> ) . . . . . . .  sort two lists in parallel
##
InstallMethod( SortParallel,
    "for homogeneous mutable list and dense mutable list",
    true,
    [ IsHomogeneousList and IsMutable,
      IsDenseList and IsMutable ],
    0,
    function ( list, para )
    local l, both, i;
    l:= Length( list );
    both:= [];                          
    for i in [ 1 .. l ] do                                         
      both[i]:= [ list[i], i, para[i] ];
    od;                                    
    both:= Set( both );
    for i in [ 1 .. l ] do
      list[i]:= both[i][1];
      para[i]:= both[i][3];
    od;

    # If the entries are immutable then store that the list is sorted.
    IsSSortedList( list );
    end );


#############################################################################
##
#M  SortParallel( <empty>, <empty> )
##
InstallOtherMethod( SortParallel,
    "for two empty lists",
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
    "for two dense and mutable lists, and function",
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
    "for two empty lists, and function",
    true,
    [ IsList and IsEmpty and IsMutable,
      IsList and IsEmpty and IsMutable,
      IsFunction ],
    0,
    Ignore );


#############################################################################
##
#F  Maximum( <obj>, ... )
##
InstallGlobalFunction( Maximum, function ( arg )
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
end );


#############################################################################
##
#M  MaximumList( <list> )
##
InstallMethod( MaximumList,
    "for a homomgeneous list",
    true,
    [ IsHomogeneousList ], 0,
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
    "for a range",
    true,
    [ IsRange ], 0,
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
#F  Minimum( <obj>, ... )
##
InstallGlobalFunction( Minimum, function ( arg )
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
end );


#############################################################################
##
#M  MinimumList( <list> )
##
InstallMethod( MinimumList,
    "for a homogeneous list",
    true,
    [ IsHomogeneousList ], 0,
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
    "for a range",
    true,
    [ IsRange ], 0,
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
#F  Cartesian( <list>, ... )
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

InstallGlobalFunction( Cartesian, function ( arg )
    if Length(arg) = 1  then
        return Cartesian2( arg[1], Length(arg[1]), [], 1 );
    else
        return Cartesian2( arg, Length(arg), [], 1 );
    fi;
end );


#############################################################################
##
#M  Permuted( <list>, <perm> )  . . . apply permutation <perm> to list <list>
##
InstallMethod( Permuted,
    "for a list and a permutation",
    true,
    [ IsList, IS_PERM ], 0,
    function ( list, perm )
    # this was proposed by Jean Michel
    return list{ OnTuples( [ 1 .. Length( list ) ], perm^-1 ) };
    end );


#############################################################################
##
#F  First( <C>, <func> )  . . .  find first element in a list with a property
##
InstallGlobalFunction( First,
    function ( C, func )
    local tnum, elm;
    tnum:= TNUM_OBJ( C )[1];
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      for elm in C do
          if func( elm ) then
              return elm;
          fi;
      od;
      return fail;
    else
      return FirstOp( C, func );
    fi;
end );


#############################################################################
##
#M  FirstOp( <C>, <func> )  . .  find first element in a list with a property
##
InstallMethod( FirstOp,
    "for a list and a function",
    true,
    [ IsList, IsFunction ], 0,
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
#M  Iterated( <list>, <func> )  . . . . . . .  iterate a function over a list
##
InstallMethod( Iterated,
    "for a list and a function",
    true,
    [ IsList, IsFunction ], 0,
    function ( list, func )
    local   res, i;
    if IsEmpty( list ) then
      Error( "Iterated: <list> must contain at least one element" );
    fi;
    res:= list[1];
    for i in [ 2 .. Length( list ) ] do
      res:= func( res, list[i] );
    od;
    return res;
    end );


#############################################################################
##
#M  IsBound( list[i] ) . . . . . . . . . . . . . . .  IsBound for dense lists
##
InstallMethod( IsBound\[\],
    "for a dense list and positive integer",
    true,
    [ IsDenseList, IsPosInt ], 0,
    function( list, index )
    return index <= Length( list );
    end );


#############################################################################
##
#M  methods for arithmetic operations
##
##  Several methods for list arithmetics must be installed with certain
##  restrictions, since installing them as admissible for all lists (or at
##  least for all small lists) would cause problems for extensions.
##  For example, we are interested in Lie matrices, and the default method
##  to add two lists pointwise must *not* be applicable,
##  because it is allowed to return a list in internal representation,
##  but we want the sum to be again a Lie matrix.
##
##  So we decided to restrict the scope of the default methods to those lists
##  for which we know that they work, namely for lists in `IsInternalRep'
##  and for lists in `IsGF2VectorRep' and `IsGF2MatrixRep'.
##  For that, we construct a representation that covers these three.
##
#R  IsListDefaultRep
##
DeclareRepresentation( "IsListDefaultRep", IsObject, [] );
#T this is not really clean ...

InstallTrueMethod( IsListDefaultRep, IsInternalRep );
InstallTrueMethod( IsListDefaultRep, IsGF2VectorRep );
InstallTrueMethod( IsListDefaultRep, IsGF2MatrixRep );


#############################################################################
##
#M  Zero( <list> ) . . . . . . . . . . for internal list of add-elm-with-zero
##
##  Note that for non-internal lists, it may be unwanted that the zero is
##  allowed to be an internal list.
##
InstallMethod( ZERO,
    "for internal additive-element-with-zero list",
    true,
    [ IsAdditiveElementWithZeroList and IsListDefaultRep ], 0,
    ZERO_LIST_DEFAULT );


#############################################################################
##
#M  AdditiveInverse( <list> )  . . . . for internal list of add-elm-with-inv.
##
##  Note that for non-internal lists, it may be unwanted that the inverse is
##  allowed to be an internal list.
##
InstallMethod( AdditiveInverse,
    "for internal additive-element-with-inverse list",
    true,
    [ IsAdditiveElementWithInverseList and IsListDefaultRep ], 0,
    AINV_LIST_DEFAULT );


#############################################################################
##
#M  <elm> - <list>
#M  <list> - <elm>
#M  <elm> - <table>
#M  <table> - <elm>
##
##  If <list> is a list and <elm> is an object that is *not* a list then
##  the difference `<elm> - <list>' and the difference `<list> - <elm>' are
##  defined as immutable lists with entry `<elm> - <list>[$i$]' resp.
##  `<list>[$i$] - <elm>' at $i$-th position.
##
##  Special methods are installed for certain family relations of <elm>
##  and <list>.
##
InstallOtherMethod( \-,                                                      
    "for list and non-list",                                                
    true,                                                                       
    [ IsList, IsObject ], 0,                 
    function( list, nonlist )
    local diff, i;                                                      
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    diff:= [];
    for i in [ 1 .. Length( list ) ] do   
      if IsBound( list[i] ) then
        diff[i]:= list[i] - nonlist;
      fi;
    od;
    return Immutable( diff );
    end );

InstallOtherMethod( \-,                        
    "for non-list and list",   
    true,                                       
    [ IsObject, IsList ], 0,
    function( nonlist, list )
    local diff, i;
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    diff:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        diff[i]:= nonlist - list[i];
      fi;
    od;
    return Immutable( diff );
    end );


DIFF_SCL_LIST_TRY := function( elm, list )
    if IsSmallList( list ) then
      return DIFF_SCL_LIST_DEFAULT( elm, list );
    else
      TryNextMethod();
    fi;
end;

DIFF_LIST_SCL_TRY := function( list, elm )
    if IsSmallList( list ) then
      return DIFF_LIST_SCL_DEFAULT( list, elm );
    else
      TryNextMethod();
    fi;
end;

InstallOtherMethod( \-,
    "for additive-element-with-inverse and small ext-a-element list",
    IsElmsColls,
    [ IsAdditiveElementWithInverse, IsExtAElementList and IsSmallList ], 0,
    DIFF_SCL_LIST_DEFAULT );

InstallOtherMethod( \-,
    "for additive-element-with-inverse and ext-a-element list",
    IsElmsColls,
    [ IsAdditiveElementWithInverse, IsExtAElementList ], 0,
    DIFF_SCL_LIST_TRY );


InstallOtherMethod( \-,
    "for additive-element-with-inverse and empty list",
    true,
    [ IsAdditiveElementWithInverse, IsList and IsEmpty ], 0,
    DIFF_SCL_LIST_DEFAULT );


InstallMethod( \-,
    "for small ext-a-element list and additive-element-with-inverse",
    IsCollsElms,
    [ IsExtAElementList and IsSmallList, IsAdditiveElementWithInverse ], 0,
    DIFF_LIST_SCL_DEFAULT );

InstallMethod( \-,
    "for ext-a-element list and additive-element-with-inverse",
    IsCollsElms,
    [ IsExtAElementList, IsAdditiveElementWithInverse ], 0,
    DIFF_LIST_SCL_TRY );


InstallOtherMethod( \-,
    "for empty list and additive-element-with-inverse",
    true,
    [ IsList and IsEmpty, IsAdditiveElementWithInverse ], 0,
    DIFF_LIST_SCL_DEFAULT );


InstallOtherMethod( \-,
    "for additive-element-with-inverse and small ext-a-element table",
    IsElmsCollColls,
    [ IsAdditiveElementWithInverse, IsExtAElementTable and IsSmallList ], 0,
    DIFF_SCL_LIST_DEFAULT );

InstallOtherMethod( \-,
    "for additive-element-with-inverse and ext-a-element table",
    IsElmsCollColls,
    [ IsAdditiveElementWithInverse, IsExtAElementTable ], 0,
    DIFF_SCL_LIST_TRY );


InstallOtherMethod( \-,
    "for small ext-a-element table and additive-element-with-inverse",
    IsCollCollsElms,
    [ IsExtAElementTable and IsSmallList, IsAdditiveElementWithInverse ], 0,
    DIFF_LIST_SCL_DEFAULT );

InstallOtherMethod( \-,
    "for ext-a-element table and additive-element-with-inverse",
    IsCollCollsElms,
    [ IsExtAElementTable, IsAdditiveElementWithInverse ], 0,
    DIFF_LIST_SCL_TRY );


#############################################################################
##
#M  <list1> - <list2>
##
##  The difference of two internal lists <list1>, <list2> of equal length is
##  defined pointwise, i.e., the result is an immutable internal list of the
##  same length, with entry `<list1>[$i$] - <list2>[$i$]' at $i$-th position.
##
##  Note that we must require the lists to be internal since it may be
##  unwanted that the difference of two non-internal lists is allowed to be
##  internal; for example think of Lie matrices.
##
##  Special methods are installed for the case of dense lists in the same
##  family.
##
InstallOtherMethod( \-,
    "for two internal lists",
    true,
    [ IsList and IsListDefaultRep, IsList and IsListDefaultRep ], 0,
    function( list1, list2 )
    local diff, len, i;
    diff:= [];
    len:= Length( list1 );
    if len <> Length( list2 ) then
      Error( "<list1> and <list2> must have equal length" );
    fi;
    for i in [ 1 .. len ] do
      if IsBound( list1[i] ) then
        if IsBound( list2[i] ) then
          diff[i]:= list1[i] - list2[i];
        else
          diff[i]:= list1[i];
        fi;
      elif IsBound( list2[i] ) then
        diff[i]:= - list2[i];
      fi;
    od;
    return Immutable( diff );
    end );


InstallMethod( \-,
    "for two internal additive-element-with-inverse lists",
    IsIdenticalObj,
    [ IsAdditiveElementWithInverseList and IsListDefaultRep,
      IsAdditiveElementWithInverseList and IsListDefaultRep ], 0,
    DIFF_LIST_LIST_DEFAULT );


#############################################################################
##
#M  One( <matrix> ) . . . . . . . . . . . . . . . . .  for an ordinary matrix
##
##  Note that the standard method applies only to ordinary matrices.
##  (All internally represented matrices are ordinary.)
##
InstallOtherMethod( One,
    "default for small ordinary matrix",
    true,
    [ IsOrdinaryMatrix and IsSmallList ], 0,
    ONE_MATRIX );

InstallOtherMethod( One,
    "default for ordinary matrix",
    true,
    [ IsOrdinaryMatrix ], 0,
    function( mat )
    if IsSmallList( mat ) then
      return ONE_MATRIX( mat );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Inverse( <matrix> ) . . . . . . . . . . . . . . .  for an ordinary matrix
##
##  Note that the standard method applies only to ordinary matrices.
##  (All internally represented matrices are ordinary.)
##
InstallOtherMethod( Inverse,
    "default for small ordinary matrix",
    true,
    [ IsOrdinaryMatrix and IsSmallList ], 0,
    INV_MATRIX );

InstallOtherMethod( Inverse,
    "default for ordinary matrix",
    true,
    [ IsOrdinaryMatrix ], 0,
    function( mat )
    if IsSmallList( mat ) then
      return INV_MATRIX( mat );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  <vector> ^ <matrix>
##
InstallOtherMethod( \^,
    "using `PROD' for ring element list and ring element table",
    IsElmsColls,
    [ IsRingElementList, IsRingElementTable ],
    0,
    PROD );


#############################################################################
##
#M  <elm> + <list>
#M  <list> + <elm>
#M  <elm> + <table>
#M  <table> + <elm>
##
##  If <list> is a list and <elm> is an object that is *not* a list then
##  the sum `<elm> + <list>' and the sum `<list> + <elm>' are defined as
##  immutable list with entry `<elm> + <list>[$i$]' at $i$-th position.
##
##  Special methods are installed for certain family relations of <elm> and
##  <list>.
##
InstallOtherMethod( \+,
    "for list and non-list",
    true,
    [ IsList, IsObject ], 0,
    function( list, nonlist )
    local sum, i;
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    sum:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        sum[i]:= nonlist + list[i];
      fi;
    od;
    return Immutable( sum );
    end );

InstallOtherMethod( \+,
    "for non-list and list",
    true,
    [ IsObject, IsList ], 0,
    function( nonlist, list )
    local sum, i;
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    sum:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        sum[i]:= nonlist + list[i];
      fi;
    od;
    return Immutable( sum );
    end );


SUM_SCL_LIST_TRY := function( elm, list )
    if IsSmallList( list ) then
      return SUM_SCL_LIST_DEFAULT( elm, list );
    else
      TryNextMethod();
    fi;
end;

SUM_LIST_SCL_TRY := function( list, elm )
    if IsSmallList( list ) then
      return SUM_LIST_SCL_DEFAULT( list, elm );
    else
      TryNextMethod();
    fi;
end;

InstallMethod( \+,
    "additive element + small ext-a-element list",
    IsElmsColls,
    [ IsAdditiveElement, IsExtAElementList and IsSmallList ], 0,
    SUM_SCL_LIST_DEFAULT );

InstallMethod( \+,
    "additive element + ext-a-element list",
    IsElmsColls,
    [ IsAdditiveElement, IsExtAElementList ], 0,
    SUM_SCL_LIST_TRY );


InstallOtherMethod( \+,
    "additive element + empty list",
    true,
    [ IsAdditiveElement, IsList and IsEmpty ], 0,
    SUM_SCL_LIST_DEFAULT );


InstallMethod( \+,
    "small ext-a-element list + additive element",
    IsCollsElms,
    [ IsExtAElementList and IsSmallList, IsAdditiveElement ], 0,
    SUM_LIST_SCL_DEFAULT );

InstallMethod( \+,
    "ext-a-element list + additive element",
    IsCollsElms,
    [ IsExtAElementList, IsAdditiveElement ], 0,
    SUM_LIST_SCL_TRY );


InstallOtherMethod( \+,
    "empty list + additive element",
    true,
    [ IsList and IsEmpty, IsAdditiveElement ], 0,
    SUM_LIST_SCL_DEFAULT );


InstallOtherMethod( \+,
    "additive element + small ext-a-element table",
    IsElmsCollColls,
    [ IsAdditiveElement, IsExtAElementTable and IsSmallList ], 0,
    SUM_SCL_LIST_DEFAULT );

InstallOtherMethod( \+,
    "additive element + ext-a-element table",
    IsElmsCollColls,
    [ IsAdditiveElement, IsExtAElementTable ], 0,
    SUM_SCL_LIST_TRY );


InstallOtherMethod( \+,
    "small ext-a-element table + additive element",
    IsCollCollsElms,
    [ IsExtAElementTable and IsSmallList, IsAdditiveElement ], 0,
    SUM_LIST_SCL_DEFAULT );

InstallOtherMethod( \+,
    "ext-a-element table + additive element",
    IsCollCollsElms,
    [ IsExtAElementTable, IsAdditiveElement ], 0,
    SUM_LIST_SCL_TRY );


#############################################################################
##
#M  <list1> + <list2>
##
##  The sum of two internal lists <list1>, <list2> of equal length is defined
##  pointwise, i.e., the result is an immutable internal list of the same
##  length, with entry `<list1>[$i$] + <list2>[$i$]' at $i$-th position.
##
##  Note that we must require the lists to be internal since it may be
##  unwanted that the sum of two non-internal lists is allowed to be
##  internal; for example think of Lie matrices.
##
##  Special methods are installed for the case of dense lists in the same
##  family.
##
InstallOtherMethod( \+,
    "for two internal lists",
    true,
    [ IsList and IsListDefaultRep, IsList and IsListDefaultRep ], 0,
    function( list1, list2 )
    local sum, len, i;
    sum:= [];
    len:= Length( list1 );
    if len <> Length( list2 ) then
      Error( "<list1> and <list2> must have equal length" );
    fi;
    for i in [ 1 .. len ] do
      if IsBound( list1[i] ) then
        if IsBound( list2[i] ) then
          sum[i]:= list1[i] + list2[i];
        else
          sum[i]:= list1[i];
        fi;
      elif IsBound( list2[i] ) then
        sum[i]:= list2[i];
      fi;
    od;
    return Immutable( sum );
    end );

InstallOtherMethod( \+,
    "dense internal list + dense internal list",
    IsIdenticalObj,
    [ IsDenseList and IsListDefaultRep,
      IsDenseList and IsListDefaultRep ], 0,
    SUM_LIST_LIST_DEFAULT );


#############################################################################
##
#M  <elm> * <list>
#M  <list> * <elm>
#M  <elm> * <table>
#M  <table> * <elm>
##
##  If <list> is a list and <elm> is an object that is *not* a list then
##  the product `<elm> * <list>' and the product `<list> * <elm>' are defined
##  as immutable list with entry `<elm> * <list>[$i$]' resp.
##  `<list>[$i$] * <elm>' at $i$-th position.
##
##  Special methods are installed for certain family relations of <elm> and
##  <list>.
##
InstallOtherMethod( \*,
    "for list and non-list",
    true,
    [ IsList, IsObject ], 0,
    function( list, nonlist )
    local prod, i;
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    prod:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        prod[i]:= list[i] * nonlist;
      fi;
    od;
    return Immutable( prod );
    end );

InstallOtherMethod( \*,
    "for non-list and list",
    true,
    [ IsObject, IsList ], 0,
    function( nonlist, list )
    local prod, i;
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    prod:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        prod[i]:= nonlist * list[i];
      fi;
    od;
    return Immutable( prod );
    end );


PROD_SCL_LIST_TRY := function( elm, list )
    if IsSmallList( list ) then
      return PROD_SCL_LIST_DEFAULT( elm, list );
    else
      TryNextMethod();
    fi;
end;

PROD_LIST_SCL_TRY := function( list, elm )
    if IsSmallList( list ) then
      return PROD_LIST_SCL_DEFAULT( list, elm );
    else
      TryNextMethod();
    fi;
end;


InstallMethod( \*,
    "multiplicative element * small ext-l-element list",
    IsElmsColls,
    [ IsMultiplicativeElement, IsExtLElementList and IsSmallList ], 0,
    PROD_SCL_LIST_DEFAULT );

InstallMethod( \*,
    "multiplicative element * ext-l-element list",
    IsElmsColls,
    [ IsMultiplicativeElement, IsExtLElementList ], 0,
    PROD_SCL_LIST_TRY );


InstallOtherMethod( \*,
    "multiplicative element * empty list",
    true,
    [ IsMultiplicativeElement, IsList and IsEmpty ], 0,
    PROD_SCL_LIST_DEFAULT );


InstallMethod( \*,
    "small ext-r-element list * multiplicative element",
    IsCollsElms,
    [ IsExtRElementList and IsSmallList, IsMultiplicativeElement ], 0,
    PROD_LIST_SCL_DEFAULT );

InstallMethod( \*,
    "ext-r-element list * multiplicative element",
    IsCollsElms,
    [ IsExtRElementList and IsSmallList, IsMultiplicativeElement ], 0,
    PROD_LIST_SCL_TRY );


InstallOtherMethod( \*,
    "empty list * multiplicative element",
    true,
    [ IsList and IsEmpty, IsMultiplicativeElement ], 0,
    PROD_LIST_SCL_DEFAULT );


InstallOtherMethod( \*,
    "multiplicative element * small ext-l-element table",
    IsElmsCollColls,
    [ IsMultiplicativeElement, IsExtLElementTable and IsSmallList ], 0,
    PROD_SCL_LIST_DEFAULT );

InstallOtherMethod( \*,
    "multiplicative element * ext-l-element table",
    IsElmsCollColls,
    [ IsMultiplicativeElement, IsExtLElementTable ], 0,
    PROD_SCL_LIST_TRY );


InstallOtherMethod( \*,
    "small ext-r-element * multiplicative element",
    IsCollCollsElms,
    [ IsExtRElementTable and IsSmallList, IsMultiplicativeElement ], 0,
    PROD_LIST_SCL_DEFAULT );

InstallOtherMethod( \*,
    "ext-r-element * multiplicative element",
    IsCollCollsElms,
    [ IsExtRElementTable, IsMultiplicativeElement ], 0,
    PROD_LIST_SCL_TRY );


#############################################################################
##
#M  <list1> * <list2>
##
##  If <list1> is a dense list whose entries are *not* lists then the product
##  of <list1> with the dense list <list2> of same length $n$ is defined as
##  $\sum_{i=1}^n <list1>[i] * <list2>[i]$.
##  This covers the standard scalar product of two vectors and the
##  product of a vector and a matrix.
##
##  If <list1> is a nonempty dense internal list of lists of same length $m$
##  then the product of <list1> with the dense list <list2> of length $m$
##  is defined as the list with entry `<list1>[$i$] * <list2>' at $i$-th
##  position.
##  This covers the product of an internal ordinary matrix with an internal
##  row vector and the product of two ordinary matrices.
##
##  Special methods are installed for the case of certain family relations
##  between <list1> and <list2>.
##
InstallOtherMethod( \*,
    "for dense list of non-lists and dense list",
    true,
    [ IsDenseList, IsDenseList ], 0,
    function( list1, list2 )
    local prod, i;
    if ForAny( list1, IsList ) then
      TryNextMethod();
    else
      return PROD_LIST_LIST_DEFAULT( list1, list2 );
    fi;
    end );

InstallOtherMethod( \*,
    "for dense internal list of lists and dense list",
    true,
    [ IsDenseList and IsListDefaultRep, IsDenseList ], 0,
    function( list1, list2 )
    local prod, i;
    if IsEmpty( list1 ) or ForAny( list1, row -> not IsList( row ) ) then
      TryNextMethod();
    else
      return PROD_LIST_SCL_DEFAULT( list1, list2 );
    fi;
    end );


PROD_LIST_LIST_TRY := function( list1, list2 )
    if IsSmallList( list1 ) and IsSmallList( list2 ) then
      return PROD_LIST_LIST_DEFAULT( list1, list2 );
    else
      TryNextMethod();
    fi;
end;

InstallMethod( \*,
    "small ring element list * small ring element list",
    IsIdenticalObj,
    [ IsRingElementList and IsSmallList,
      IsRingElementList and IsSmallList ], 0,
    PROD_LIST_LIST_DEFAULT );

InstallMethod( \*,
    "ring element list * ring element list",
    IsIdenticalObj,
    [ IsRingElementList, IsRingElementList ], 0,
    PROD_LIST_LIST_TRY );


InstallOtherMethod( \*,
    "small ring element list * small ring element table",
    IsElmsColls,
    [ IsRingElementList and IsSmallList,
      IsRingElementTable and IsSmallList ], 0,
    PROD_LIST_LIST_DEFAULT );

InstallOtherMethod( \*,
    "ring element list * ring element table",
    IsElmsColls,
    [ IsRingElementList, IsRingElementTable ], 0,
    PROD_LIST_LIST_TRY );


InstallOtherMethod( \*,
    "small cyclotomics list * small ffe table",
    true,
    [ IsRingElementList and IsCyclotomicCollection and IsSmallList,
      IsRingElementTable and IsFFECollColl and IsSmallList ], 0,
    PROD_LIST_LIST_DEFAULT );

InstallOtherMethod( \*,
    "cyclotomics list * ffe table",
    true,
    [ IsRingElementList and IsCyclotomicCollection,
      IsRingElementTable and IsFFECollColl ], 0,
    PROD_LIST_LIST_TRY );


InstallOtherMethod( \*,
    "small ffe list * small cyclotomics table",
    true,
    [ IsRingElementList and IsFFECollection and IsSmallList,
      IsRingElementTable and IsCyclotomicCollColl and IsSmallList ], 0,
    PROD_LIST_LIST_DEFAULT );

InstallOtherMethod( \*,
    "ffe list * cyclotomics table",
    true,
    [ IsRingElementList and IsFFECollection,
      IsRingElementTable and IsCyclotomicCollColl ], 0,
    PROD_LIST_LIST_TRY );


InstallOtherMethod( \*,
    "small ring element table * small ring element list",
    IsCollsElms,
    [ IsRingElementTable and IsSmallList,
      IsRingElementList and IsSmallList ], 0,
    PROD_LIST_SCL_DEFAULT );

InstallOtherMethod( \*,
    "ring element table * ring element list",
    IsCollsElms,
    [ IsRingElementTable, IsRingElementList ], 0,
    PROD_LIST_SCL_TRY );


InstallOtherMethod( \*,
    "internal ring element table * internal ring element table",
    IsIdenticalObj,
    [ IsRingElementTable and IsListDefaultRep,
      IsRingElementTable and IsListDefaultRep ],
    1, # higher than the method immediately below!
    PROD_LIST_SCL_DEFAULT );

InstallOtherMethod( \*,
    "ord. matrix & ring element table * ord. matrix & ring element table",
    IsIdenticalObj,
    [ IsRingElementTable and IsOrdinaryMatrix,
      IsRingElementTable and IsOrdinaryMatrix ], 0,
    PROD_LIST_SCL_TRY );


InstallOtherMethod( \*,
    "small cyclotomics table * small ffe table",
    true,
    [ IsRingElementTable and IsCyclotomicCollColl and IsSmallList,
      IsRingElementTable and IsFFECollColl and IsSmallList], 0,
    PROD_LIST_SCL_DEFAULT );

InstallOtherMethod( \*,
    "cyclotomics table * ffe table",
    true,
    [ IsRingElementTable and IsCyclotomicCollColl,
      IsRingElementTable and IsFFECollColl ], 0,
    PROD_LIST_SCL_TRY );


InstallOtherMethod( \*,
    "small ffe table * small cyclotomics table",
    true,
    [ IsRingElementTable and IsFFECollColl and IsSmallList,
      IsRingElementTable and IsCyclotomicCollColl and IsSmallList ], 0,
    PROD_LIST_SCL_DEFAULT );

InstallOtherMethod( \*,
    "ffe table * cyclotomics table",
    true,
    [ IsRingElementTable and IsFFECollColl,
      IsRingElementTable and IsCyclotomicCollColl ], 0,
    PROD_LIST_SCL_TRY );


#############################################################################
##
#F  DifferenceBlist ( <blist1>, <blist2> )
##
InstallGlobalFunction( DifferenceBlist, function( a, b )
    a:= ShallowCopy( a );
    SubtractBlist( a, b );
    return a;
end );

#############################################################################
##
#F  UnionBlist( <blists> )  . . . . . . . . . . . . . . . . . union of blists
##
InstallGlobalFunction( UnionBlist, function( blists )
    local   union,  blist;
    
    union := BlistList( [ 1 .. Length( blists[ 1 ] ) ], [  ] );
    for blist  in blists  do
        UniteBlist( union, blist );
    od;
    return union;
end );

#############################################################################
##
#F  IntersectionBlist( <blists> )  . . . . . . . . . . intersection of blists
##
InstallGlobalFunction( IntersectionBlist, function( blists )
    local   intersection,  blist;
    
    intersection := BlistList( [ 1 .. Length( blists[ 1 ] ) ], [  ] );
    for blist  in blists  do
        IntersectBlist( intersection, blist );
    od;
    return intersection;
end );

#############################################################################
##
#F  ListWithIdenticalEntries( <n>, <obj> )
##
InstallGlobalFunction( ListWithIdenticalEntries, function( n, obj )
    local list, i;
    list:= [];
    for i in [ 1 .. n ] do
      list[i]:= obj;
    od;
    return list;
end );


#############################################################################
##
#F  ProductPol( <coeffs_f>, <coeffs_g> )  . . . .  product of two polynomials
##
InstallGlobalFunction( ProductPol, function( f, g )
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
end );


#############################################################################
##
#F  ValuePol( <coeffs_f>, <x> ) . . . . . .  evaluate a polynomial at a point
##
InstallGlobalFunction( ValuePol, function( f, x )
    local  value, i, id;
    id := x ^ 0;
    value := 0 * id;
    i := Length(f);
    while 0 < i  do
        value := value * x + id * f[i];
        i := i-1;
    od;
    return value;
end );


#############################################################################
##
#M  ViewObj( <list> ) . . . . . . . . . . . . . . . . .  view the sub-objects
##
##  This is  a very naive  method which will view   the sub-objects. A better
##  method is needed eventually looking out for long list or homogeneous list
##  or dense list, etc.
##
InstallMethod( ViewObj,
    "for finite lists",
    true,
    [ IsList and IsFinite ],
    0,

function( list )
    local   i;

    if 0 = Length(list) and IsInternalRep(list)  then
        PrintObj( list );
    elif 0 < Length(list) and IsString(list)  then
        Print( "\"", list, "\"" );
    else
        Print( "\>\>[ \>\>" );
        for i  in [ 1 .. Length(list) ]  do
            if IsBound(list[i])  then
                if 1 < i then Print( "\<,\< \>\>" ); fi;
                
                # This is needed to handle recursive objects nicely
                SET_PRINT_OBJ_INDEX(i);
                
                ViewObj(list[i]);
            elif 1 < i then Print( "\<,\<\>\>" );
        fi;
        od;
        Print( " \<\<\<\<]" );
    fi;
end );

InstallMethod( ViewObj,
    "for ranges",
    true,
    [ IsList and IsFinite and IsRange ],
    0,
    function( list )      
    Print( "[ ", list[1] );    
    if 1 < Length( list ) then                   
      if list[2] - list[1] <> 1  then
        Print( ", ", list[2] );    
      fi;                                
      Print( " .. ", list[ Length( list ) ] );
    fi;         
    Print( " ]" );
    end );                                  
    

#############################################################################
##

#E  list.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


