#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for lists in general.
##


#############################################################################
##
#M  methods for nesting depths for some quick cases
##

InstallMethod(NestingDepthA, [IsCyclotomicCollection and IsGeneralizedRowVector],
        v->1);
InstallMethod(NestingDepthM, [IsCyclotomicCollection and IsMultiplicativeGeneralizedRowVector],
        v->1);
InstallMethod(NestingDepthA, [IsFFECollection and IsGeneralizedRowVector],
        v->1);
InstallMethod(NestingDepthM, [IsFFECollection and IsMultiplicativeGeneralizedRowVector],
        v->1);

InstallMethod(NestingDepthA, [IsCyclotomicCollColl and
        IsGeneralizedRowVector],
        m->2);

InstallMethod(NestingDepthM, [IsCyclotomicCollColl and
        IsOrdinaryMatrix and IsMultiplicativeGeneralizedRowVector],
        function( m )
    local t;
    t := TNUM_OBJ(m[1]);
    if FIRST_LIST_TNUM > t or LAST_LIST_TNUM < t then
        TryNextMethod();
    else
        return 2;
    fi;
end );

#T just a temporary (?) hack in order to exclude lists of class functions

InstallMethod(NestingDepthA, [IsFFECollColl and IsGeneralizedRowVector],

        m->2);

InstallMethod(NestingDepthM, [IsFFECollColl and IsOrdinaryMatrix and IsMultiplicativeGeneralizedRowVector],
           function(m)
    local t;
    t := TNUM_OBJ(m[1]);
    if FIRST_LIST_TNUM > t or LAST_LIST_TNUM < t then
        TryNextMethod();
    else
        return 2;
    fi;
end);


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
    [ IsList and IsSmallList, IsList and IsSmallList ],
    EQ_LIST_LIST_DEFAULT );

InstallMethod( EQ,
    "for two finite lists (not necessarily small)",
    IsIdenticalObj,
    [ IsList and IsFinite, IsList and IsFinite ],
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
    [ IsList and IsEmpty, IsList ],
    SUM_FLAGS, #can't do better
    function( empty, list )
    return IsEmpty( list );
    end );


InstallMethod( EQ,
    "for two lists, the second being empty",
    [ IsList, IsList and IsEmpty ],
    SUM_FLAGS, #can't do better
    function( list, empty )
    return IsEmpty( list );
    end );


#############################################################################
##
#M  \=( <list1>, <list2> )  . . .. . . . . . . . . .  for two lists
##
InstallMethod( EQ,
    "for two lists with length - last resort",
    IsIdenticalObj,
    [ IsList and HasLength, IsList and HasLength ],
function(list1, list2)
  if Length(list1) <> Length(list2) then
    return false;
  fi;

  # use the kernel method if small lists
  if IsSmallList(list1) and IsSmallList(list2) then
    return EQ_LIST_LIST_DEFAULT(list1, list2);
  fi;

  if IsInfinity(Length(list1)) then
    ## warning - trying to compare infinite lists
    Info(InfoWarning, 1, "EQ: Attempting EQ on infinite lists");
  fi;

  TryNextMethod();
end);

InstallMethod( EQ,
    "for two lists - last resort",
    IsIdenticalObj,
    [ IsList, IsList],
function(list1, list2)
  local i;

  # just compare elementwise
  i := 1;
  while true do
      while IsBound(list1[i]) and IsBound(list2[i]) do
          if list1[i] <> list2[i] then
              return false;
          fi;
          i := i + 1;
      od;

      if IsBound(list1[i]) or IsBound(list2[i]) then
          return false;
      fi;

      # Now we've found an unbound spot on both lists
      # maybe we know enough to stop now
      # anyway at this stage we really must check the Lengths and hope
      # that they are computable now.

      if Length(list1) <= i then
          return Length(list2) <= i;
      elif Length(list2) <= i then
          return false;
      fi;

      i := i + 1;
  od;
end);


InstallMethod( LT,
    "for two small homogeneous lists",
    IsIdenticalObj,
    [ IsHomogeneousList and IsSmallList,
      IsHomogeneousList and IsSmallList ],
    LT_LIST_LIST_DEFAULT );

InstallMethod( LT,
    "for two finite homogeneous lists (not necessarily small)",
    IsIdenticalObj,
    [ IsHomogeneousList and IsFinite, IsHomogeneousList and IsFinite ],
    LT_LIST_LIST_FINITE );


#############################################################################
##
#M  \in( <obj>, <list> )
##
InstallMethod( IN,
    "for an object, and an empty list",
    [ IsObject, IsList and IsEmpty ],
    ReturnFalse );

InstallMethod( IN,
    "for wrong family relation",
    IsNotElmsColls,
    [ IsObject, IsCollection ],
    SUM_FLAGS, # can't do better
    ReturnFalse );

InstallMethod( IN,
    "for an object, and a small list",
    [ IsObject, IsList and IsSmallList ],
    IN_LIST_DEFAULT );

InstallMethod( IN,
    "for an object, and a list",
    [ IsObject, IsList ],
    function( elm, list )
    local len, i;
    if IsSmallList( list ) then
      return IN_LIST_DEFAULT( elm, list );
    elif IsFinite( list ) then
      len:= Length( list );
      i:= 1;
      while i <= len do
        if IsBound( list[i] ) and elm = list[i] then
          return true;
        fi;
        i:= i+1;
      od;
      return false;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  <elm> \in <whole-family>
##
InstallMethod( IN,
    "for an object, and a collection that contains the whole family",
    IsElmsColls,
    [ IsObject, IsCollection and IsWholeFamily ],
    SUM_FLAGS, # can't do better
    ReturnTrue );


#############################################################################
##
#M  Display( <list> )
##
InstallMethod( Display,
    "for a (finite) list",
    [ IsList ],
    function( list )
    Print( list, "\n" );
    end );


#############################################################################
##
#M  String( <list> )  . . . . . . . . . . . . . . . . . . . . . .  for a list
#M  String( <range> ) . . . . . . . . . . . . . . . . . . . . . . for a range
##
InstallMethod( String,
    "for a (finite) list",
    [ IsList ],
    function ( list )
    local   str, i;

    # Check that we are in the right method.
    if not IsFinite( list ) then
      TryNextMethod();
    fi;

    # We cannot handle the case of an empty string in the method for strings
    # because the type of the empty string need not satisfy the requirement
    # `IsString'.
    if IsEmptyString( list ) then
      return "";
    fi;

    str := "[ ";
    for i in [ 1 .. Length( list ) ]  do
        if IsBound( list[ i ] )  then
          if IsStringRep( list[i] )
             or ( IsString( list[i] ) and not IsEmpty( list[i] ) ) then
            Append( str, "\"" );
            Append( str, String( list[i] ) );
            Append( str, "\"" );
          else
            Append( str, String( list[i] ) );
          fi;
        fi;
        if i <> Length( list )  then
            Append( str, ", " );
        fi;
    od;
    Append( str, " ]" );
    ConvertToStringRep( str );
    return str;
    end );

InstallMethod( ViewString, "call ViewString and incorporate hints",
  [ IsList and IsFinite],
function ( list )
local   str,ls, i;

  # We have to handle empty string and empty list specially because
  # IsString( [ ] ) returns true

  if Length(list) = 0 then
    if IsEmptyString( list ) then
      return "\"\"";
    else
      return "[  ]";
    fi;
  fi;

  if IsString( list ) then
    return VIEW_STRING_FOR_STRING(list);
  fi;

  # make strings for objects in l
  ls:=[];
  for i in [1..Length(list)] do
    if IsBound(list[i]) then
      str:=ViewString(list[i]);
      if str=DEFAULTVIEWSTRING then
        # there might not be a method
        str:=String(list[i]);
      fi;
      ls[i]:=str;
    else
      ls[i]:="";
    fi;
  od;

  # The line break hints are consistent with those
  # that appear in the kernel function 'PrintListDefault'
  # and in the 'ViewObj' method for finite lists.
  str:= "\>\>[ \>\>";
  for i in [ 1 .. Length( list ) ]  do
    if ls[i] <> "" then
      if 1 < i then
        Append( str, "\<,\< \>\>" );
      fi;
      Append( str, ls[i] );
    elif 1 < i then
      Append( str, "\<,\<\>\>" );
    fi;
  od;
  Append( str, " \<\<\<\<]" );
  ConvertToStringRep( str );
  return str;
end );

InstallMethod( DisplayString,
    "for a range",
    [ IsRange ],
    range -> Concatenation( String( range ), "\n" ) );

InstallMethod( ViewString,
    "for a range",
    [ IsRange ],
    function( list )
    local   str;
    str := "[ ";
    Append( str, String( list[1] ) );
    if Length( list ) > 1 then
      if Length(list) = 2 or list[2] - list[1] <> 1 then
        Append( str, ", " );
        Append( str, String( list[2] ) );
      fi;
      if Length(list) > 2 then
        Append( str, " .. " );
        Append( str, String( list[ Length( list ) ] ) );
      fi;
    fi;
    Append( str, " ]" );
    Assert(0, IsStringRep(str));
    ConvertToStringRep( str );
    return str;
    end );

InstallMethod( String,
    "for a range",
    [ IsRange ],
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
    [ IsList ],
    Length );

InstallOtherMethod( Size,
    "for a list that is a collection",
    [ IsList and IsCollection ],
    Length );


#############################################################################
##
#M  Representative( <list> )
##
InstallOtherMethod( Representative,
    "for a list",
    [ IsList ],
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
    [ IsList and IsEmpty ],
    function( list )
    Error( "<C> must be nonempty to have a representative" );
    end );

InstallOtherMethod( RepresentativeSmallest,
    "for a strictly sorted list",
    [ IsSSortedList ],
    function( list )
    return list[1];
    end );

InstallOtherMethod(
    RepresentativeSmallest,
    "for a list",
    [ IsList ],
    MinimumList );


#############################################################################
##
#M  Random( <list> )  . . . . . . . . . . . . . . . .  for a dense small list
##
InstallMethod( Random,
    "for a dense small list",
    [ IsList and IsDenseList and IsSmallList ],
    RandomList );

InstallMethod( Random,
    "for a dense (small) list",
    [ IsList and IsDenseList ],
    function( list )
    if IsSmallList( list ) then
      return RandomList( list );
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
    [ IsList ],
    list -> Length( list ) <= MAX_SIZE_LIST_INTERNAL );


#############################################################################
##
#M  IsSmallList( <non-list> )
##
InstallOtherMethod( IsSmallList,
    "for a non-list",
    [ IsObject ],
    function( nonlist )
    if IsList( nonlist ) then
      TryNextMethod();
    else
      return false;
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
Perform( [ ConstantTimeAccessList, ShallowCopy ], function(op)

    InstallMethod( op,
        "for a list",
        [ IsList ],
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
        [ IsList and IsSSortedList ],
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
        [ IsList and IsDenseList ],
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
        [ IsList and IsDenseList and IsSSortedList ],
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

end);

InstallMethod( ConstantTimeAccessList,
    "for a constant time access list",
    [ IsList and IsConstantTimeAccessList ],
    SUM_FLAGS, # can't do better
    Immutable );


#############################################################################
##
#M  AsList( <list> )
##
InstallOtherMethod( AsList,
    "for a list",
    [ IsList ],
    list -> ConstantTimeAccessList( Enumerator( list ) ) );

InstallOtherMethod( AsList,
    "for a constant time access list",
    [ IsList and IsConstantTimeAccessList ],
    Immutable );


#############################################################################
##
#M  AsPlist( <list> )
##
InstallOtherMethod( AsPlist,
    "for a plist",
    [IsList and IsPlistRep],
    x -> x );

InstallOtherMethod( AsPlist,
    "for a list",
    [ IsList ],
    function(l)
    l:=AsList(l);
    if not IsPlistRep(l) then
      l:=PlainListCopy(l); # explicit copy for objects that claim to
                                       # be constant time access but not plists.
    fi;
    return l;
    end );


#############################################################################
##
#M  AsSSortedList( <list> )
##
##  If <list> is a (not necessarily dense) list whose elements lie in the
##  same family then 'AsSSortedList' is applicable.
##
InstallOtherMethod( AsSSortedList,
    "for a list",
    [ IsList ],
    list -> ConstantTimeAccessList( EnumeratorSorted( list ) ) );

InstallOtherMethod(AsSSortedList,
    "for a plist",
    [IsList and IsPlistRep],
    AsSSortedListList );

InstallOtherMethod(AsSSortedList,
     "for a list",
     [ IsList ],
     l -> AsSSortedListList( AsPlist( l ) ) );

InstallMethod( AsSSortedList,
    "for a strictly sorted list",
    [ IsSSortedList ],
    SUM_FLAGS,
    Immutable );


#############################################################################
##
#M  Enumerator( <list> )
##
InstallOtherMethod( Enumerator,
    "for a list",
    [ IsList ],
    Immutable );


#############################################################################
##
#M  EnumeratorSorted( <list> )
##
InstallOtherMethod( EnumeratorSorted,
    "for a plist",
    [IsList and IsPlistRep],
    function( l )
    if IsSSortedList( l ) then
      return l;
    fi;
    return AsSSortedListList( l );
    end );

InstallOtherMethod( EnumeratorSorted, "for a list", [ IsList ],
function(l)
    if IsSSortedList(l) then
      return l;
    fi;
    return AsSSortedListList(AsPlist(l));
end);


#############################################################################
##
#M  SSortedList( <list> )  . . . . . . . . . . . set of the elements of a list
##
InstallMethod( SSortedList, "for a plist",
    [ IsList and IsPlistRep ],
    SSortedListList );

InstallMethod( SSortedList, "for a list",
    [ IsList ],
    l->SSortedListList(AsPlist(l)) );


#############################################################################
##
#M  SSortedList( <list>, <func> )
##
InstallMethod( SSortedList,
    "for a list, and a function",
    [ IsList, IsFunction ],
    function ( list, func )
    local   res, i, squashsize;
    squashsize := 100;
    res := [];
    for i in list do
        Add( res, func( i ) );
        if Length(res) > squashsize then
            res := Set(res);
            squashsize := Maximum(100, Size(res) * 2);
        fi;
    od;
    return Set(res);
    end );


#############################################################################
##
#F  IteratorList( <list> )
##
##  returns an iterator constructed from the list <list>,
##  which stores the underlying list in the component `list'
##  and the current position in the component `pos'.
##
##  It may happen that the underlying list is a enumerator of a domain
##  whose size cannot be computed easily.
##  In such cases, the methods for `IsDoneIterator' and `NextIterator'
##  shall avoid calling `Length' for the enumerator.
##  Therefore a special representation exist for iterators of dense immutable
##  lists.
##  (Note that the `Length' call is unavoidable for iterators of non-dense
##  lists.)
##
BindGlobal( "IsDoneIterator_List",
    iter -> ( iter!.pos >= iter!.len ) );

BindGlobal( "NextIterator_List", function ( iter )
    local p, l;
    p := iter!.pos;
    if p = iter!.len then
        Error("<iter> is exhausted");
    fi;
    l := iter!.list;
    p := p + 1;
    while not IsBound( l[ p ] ) do
        p := p + 1;
    od;
    iter!.pos := p;
    return l[ p ];
    end );


BindGlobal( "NextIterator_DenseList", function ( iter )
    local p;
    p := iter!.pos + 1;
    iter!.pos := p;
    #if not IsBound( iter!.list[ iter!.pos ] ) then
    #    Error("<iter> is exhausted");
    #fi;
    return iter!.list[ p ];
    end );

BindGlobal( "ShallowCopy_List",
    iter -> rec( list := iter!.list,
                 pos  := iter!.pos,
                 len  := iter!.len ) );

InstallGlobalFunction( IteratorList, function ( list )
    local   iter;

    iter := rec(
                list := list,
                pos  := 0,
                len := Length(list),
                IsDoneIterator := IsDoneIterator_List,
                ShallowCopy := ShallowCopy_List );

    if IsDenseList( list ) and not IsMutable( list ) then
      iter.NextIterator := NextIterator_DenseList;
    else
      iter.NextIterator := NextIterator_List;
    fi;

    return IteratorByFunctions( iter );
end );


#############################################################################
##
#M  Iterator( <list> )
##
InstallOtherMethod( Iterator,
    "for a list",
    [ IsList ],
    IteratorList );


#############################################################################
##
#M  IteratorSorted( <list> )
##
InstallOtherMethod( IteratorSorted,
    "for a list",
    [ IsList ],
    function( list )
    if IsSSortedList( list ) then
      return IteratorList( list );
    else
      return IteratorList( SSortedListList( list ) );
#T allowed??
    fi;
    end );


#############################################################################
##
#M  SumOp( <list> ) . . . . . . . . . . . . . . . . . . . .  for a dense list
##
InstallOtherMethod( SumOp,
    "for a dense list",
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
#M  <list>{<poss>}
#M  <list>{<poss>}:=<objs>
##
##  `ELMS_LIST_DEFAULT' applies `LEN_LIST' to both of its arguments,
##  so its use is restricted to small lists.
##
##  `ASSS_LIST_DEFAULT' tries to change its first argument into a plain list,
##  and applies `LEN_LIST' to the other two arguments,
##  so also the usage of `ASSS_LIST_DEFAULT' is restricted to small lists.
##
InstallMethod( ELMS_LIST,
    "for a small list and a small dense list",
    [ IsList and IsSmallList, IsDenseList and IsSmallList ],
    ELMS_LIST_DEFAULT );

InstallMethod( ELMS_LIST,
    "for a list and a dense list",
    [ IsList, IsDenseList ],
    function( list, poslist )
    local choice, i;
    if IsSmallList( poslist ) then
      if IsSmallList( list ) then
        return ELMS_LIST_DEFAULT( list, poslist );
      else
        choice:= [];
        for i in poslist do
          Add( choice, list[i] );
        od;
        return choice;
      fi;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( ASSS_LIST,
    "for a small mutable list, a small dense list, and a small list",
    [ IsList and IsSmallList and IsMutable, IsDenseList and IsSmallList,
      IsList and IsSmallList ],
    ASSS_LIST_DEFAULT );

InstallMethod( ASSS_LIST,
    "for a mutable list, a dense list, and a list",
    [ IsList and IsMutable, IsDenseList, IsList ],
    function( list, poslist, vallist )
    local i;
    if IsSmallList( poslist ) and IsSmallList( vallist ) then
      if IsSmallList( list ) then
        ASSS_LIST_DEFAULT( list, poslist, vallist );
      else
        for i in [ 1 .. Length( poslist ) ] do
          list[ poslist[i] ]:= vallist[i];
        od;
      fi;
    else
      TryNextMethod();
    fi;
end );

InstallOtherMethod( ASS_LIST,
    "error message for immutable list",
    [IsList, IsPosInt, IsObject], -100,
    function(list, pos, v)
    if not IsMutable( list ) then
        Error("The list you are trying to assign to is immutable");
    else
        TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsSSortedList( <non-list> )
##
InstallOtherMethod( IsSSortedList,
   "for non-lists",
   [ IsObject ],
   function( nonlist )
   if IsList( nonlist ) then
     TryNextMethod();
   else
     return false;
   fi;
   end );


#############################################################################
##
#M  IsSSortedList(<list>)
##
InstallMethod( IsSSortedList,
    "for a small list",
    [ IsSmallList ],
    IS_SSORT_LIST_DEFAULT );

InstallMethod( IsSSortedList,
    "for a homogeneous list (not nec. finite)",
    [ IsHomogeneousList ],
    function( list )
    local i;
    if IsSmallList( list ) then
      return IS_SSORT_LIST_DEFAULT( list );
    else
      i:= 1;
      while i+1 <= Length( list ) do
        if list[ i+1 ] <= list[i] then
          return false;
        fi;
        i:= i+1;
      od;
    fi;
    end );


#############################################################################
##
#M  IsSortedList(<list>)
##
InstallMethod( IsSortedList,
    "for a finite list",
    [ IsList and IsFinite ],
    function(l)
    local i;
    # shortcut: strictly sorted is stored for internally represented lists
    if IsInternalRep( l ) and IsSSortedList( l ) then
      return true;
    fi;

    if not IsBound(l[1]) then
        return false;
    fi;
    for i in [1..Length(l)-1] do
      if not IsBound(l[i+1]) or l[i+1] < l[i] then
        return false;
      fi;
    od;
    return true;
end);

InstallMethod( IsSortedList,
    "for a list (not nec. finite)",
    [ IsList ],
    function( list )
    local i;
    i:= 1;
    if not IsBound(list[1]) then
        return false;
    fi;
    while i+1 <= Length( list ) do
      if not IsBound(list[i+1]) or list[ i+1 ] < list[i] then
        return false;
      fi;
      i:= i+1;
    od;
    return true;
end );


#############################################################################
##
#M  IsSortedList( <non-list> )
##
InstallOtherMethod( IsSortedList,
   "for non-lists",
   [ IsObject ],
   function( nonlist )
   if IsList( nonlist ) then
     TryNextMethod();
   else
     return false;
   fi;
   end );


#############################################################################
##
#M  IsDuplicateFree( <list> )
##
InstallMethod( IsDuplicateFree,
    "for a finite list",
    [ IsList ],
    function( list )
    local i;
    if not IsDenseList( list ) then
      return false;
    elif not IsFinite( list ) then
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
#M  DifferenceLists . . . . . . . . list without the elements in another list
##
InstallMethod( DifferenceLists,
    "homogeneous lists",
    [IsHomogeneousList, IsHomogeneousList],
    function( list1, list2 )
    local   diff,  e;

    list2 := Set( list2 );
    diff := [];
    for e in list1 do
        if not e in list2 then
            Add( diff, e );
        fi;
    od;
    return diff;
    end );


#############################################################################
##
#M  IsPositionsList(<list>)
##
InstallMethod( IsPositionsList,
    "for a small homogeneous list",
    [ IsHomogeneousList and IsSmallList ],
    IS_POSS_LIST_DEFAULT );

InstallMethod( IsPositionsList,
    "for a homogeneous list",
    [ IsHomogeneousList ],
    function( list )
    if IsSmallList( list ) then
      return IS_POSS_LIST_DEFAULT( list );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsPositionsList( <non-list> )
##
InstallOtherMethod( IsPositionsList,
   "for non-lists",
   [ IsObject ],
   function( nonlist )
   if IsList( nonlist ) then
     TryNextMethod();
   else
     return false;
   fi;
   end );


#############################################################################
##
#M  Position( <list>, <obj>, <from> )
##
InstallMethod( Position,
    "for a small list, an object, and an integer",
    [ IsList and IsSmallList, IsObject, IsInt ],
    POS_LIST_DEFAULT );

InstallMethod( Position,
    "for a (small) list, an object, and an integer",
    [ IsList, IsObject, IsInt ],
    function( list, obj, start )
    if IsSmallList( list ) then
      return POS_LIST_DEFAULT( list, obj, start );
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
    ReturnFail );

InstallMethod( Position,
    "for a small sorted list, an object, and an integer",
    [ IsSSortedList and IsSmallList, IsObject, IsInt ],
    function ( list, obj, start )
    local   pos;

#N  1996/08/14 M.Schönert 'POSITION_SORTED_LIST' should take 3 arguments
#T  (This method is used only for ``external'' lists, the kernel methods
#T  `PosPlistSort', `PosPlistHomSort' support the argument `start'.)
    if start = 0 then
      pos := POSITION_SORTED_LIST( list, obj );
      # `PositionSorted' will not return fail. Therefore we have to test
      # explicitly once it had been called.
      if pos > Length( list ) or list[pos] <> obj then
        return fail;
      fi;
    else
      pos := POS_LIST_DEFAULT( list, obj, start );
    fi;
    return pos;
end );

InstallMethod( Position,
    "for a sorted list, an object, and an integer",
    [ IsSSortedList, IsObject, IsInt ],
    function ( list, obj, start )
    local   pos;
    if IsSmallList( list ) then
      if start = 0 then
        pos := POSITION_SORTED_LIST( list, obj );
        # `PositionSorted' will not return fail. Therefore we have to test
        # explicitly once it had been called.
        if pos > Length( list ) or list[pos] <> obj then
          return fail;
        fi;
      else
        pos := POS_LIST_DEFAULT( list, obj, start );
      fi;
      return pos;
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
    [ IsDuplicateFreeList, IsObject, IsPosInt ],
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
#F  Positions( <list>, <obj> )
##
InstallGlobalFunction( Positions,

  function( list, obj )

    local res, p;

    if IsPlistRep(list) then
      res := [];
      p   := 0;
      while true do
        p := Position(list,obj,p);
        if p <> fail then
          Add(res,p);
        else
          break;
        fi;
      od;
    else
      res:= PositionsOp(list,obj);
    fi;

    SetIsSSortedList( res, true );

    return res;
  end );
# generic method for non-plain lists
InstallMethod(PositionsOp, [IsList, IsObject], function(list, obj)
  local res, p;
  res := [];
  p := Position(list, obj);
  while p <> fail do
    Add(res, p);
    p := Position(list, obj, p);
  od;
  return res;
end);

#############################################################################
##
#M  PositionCanonical( <list>, <obj> )  . .  for internally represented lists
##
InstallMethod( PositionCanonical,
    "for internally represented lists, fall back on `Position'",
    [ IsList and IsInternalRep, IsObject ],
    function( list, obj )
    return Position( list, obj, 0 );
end );

InstallMethod( PositionCanonical,
    "internal small sorted lists, use `POSITION_SORTED_LIST'",
    [ IsList and IsInternalRep and IsSSortedList and IsSmallList, IsObject ],
function(l,o)
local p;
  p:=POSITION_SORTED_LIST(l,o);
  if p=0 or p>Length(l) or l[p]<>o then
    return fail;
  else
    return p;
  fi;
end);


#############################################################################
##
#M  PositionNthOccurrence( <list>, <obj>, <n> ) . . call `Position' <n> times
##
InstallMethod( PositionNthOccurrence,
    "for list, object, integer",
    [ IsList, IsObject, IsInt ],
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
#M  PositionNthOccurrence( <blist>, <bool>, <n> )  kernel function for blists
##
InstallMethod( PositionNthOccurrence,
    "for boolean list, boolean, integer",
    [ IsBlist, IsBool, IsInt ],
    function( blist, bool, n )
    if bool then  return PositionNthTrueBlist( blist, n );
            else  TryNextMethod();                          fi;
    end );


#############################################################################
##
#F  PositionSorted( <list>, <obj>[, <func> ] )
#M  PositionSortedOp( <list>, <obj> )
#M  PositionSortedOp( <list>, <obj>, <func> )
##
InstallGlobalFunction( PositionSorted, function(arg)
  if IsPlistRep(arg[1]) then
    if Length(arg) = 3 then
      return CallFuncList(POSITION_SORTED_LIST_COMP, arg);
    else
      return CallFuncList(POSITION_SORTED_LIST, arg);
    fi;
  else
    return CallFuncList(PositionSortedOp, arg);
  fi;
end);

InstallMethod( PositionSortedOp,
    "for small list, and object",
    [ IsList and IsSmallList, IsObject ],
    POSITION_SORTED_LIST );

InstallMethod( PositionSortedOp,
    [ IsList, IsObject ],
    function( list, elm )
    if IsSmallList( list ) then
      return POSITION_SORTED_LIST( list, elm );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( PositionSortedOp,
    "for small list, object, and function",
    [ IsList and IsSmallList, IsObject, IsFunction ],
    POSITION_SORTED_LIST_COMP );

InstallMethod( PositionSortedOp,
    "for list, object, and function",
    [ IsList, IsObject, IsFunction ],
    function( list, elm, func )
    if IsSmallList( list ) then
      return POSITION_SORTED_LIST_COMP( list, elm, func );
    else
      TryNextMethod();
    fi;
    end );

#############################################################################
##
#F  PositionSortedBy( <list>, <val>, <func> )
#F  PositionSortedByOp( <list>, <val>, <func> )
##
InstallGlobalFunction( PositionSortedBy, function( list, val, func )
  if IsPlistRep(list) then
    return POSITION_SORTED_BY(list, val, func);
  else
    return PositionSortedByOp(list, val, func);
  fi;
end);

InstallMethod( PositionSortedByOp,
    "for a dense plain list, an object and a function",
    [ IsDenseList and IsPlistRep, IsObject, IsFunction ],
    POSITION_SORTED_BY);

InstallMethod( PositionSortedByOp,
    "for a dense list, an object and a function",
    [ IsDenseList, IsObject, IsFunction ],
function ( list, val, func )
local l, h, m;
  # simple binary search. The entry is in the range [l..h]
  l := 0;
  h := Length(list) + 1;
  while l + 1 < h do        # list[l] < val && val <= list[h]
    m := QuoInt(l + h, 2);  # l < m < h
    if func(list[m]) < val then
      l := m;      # it's not in [lo..m], so take the upper part.
    else
      h := m;      # So val<=list[m][1], so the new range is [1..m].
    fi;
  od;
  return h;
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
#M  PositionProperty( <list>, <func>, <from> )
##

InstallMethod( PositionProperty,
    "for list and function",
    [ IsList, IsFunction ],
    function ( list, func )
    local i;
    for i in [ 1 .. Length( list ) ] do
        if IsBound( list[i] ) then
           if func( list[ i ] ) then
               return i;
           fi;
        fi;
    od;
    return fail;
    end );

InstallMethod( PositionProperty,
    "for list, function, and integer",
    [ IsList, IsFunction, IsInt ],
    function( list, func, from )
    local i;

    if from < 0 then
      from:= 0;
    fi;
    for i in [ from+1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        if func( list[i] ) then
          return i;
        fi;
      fi;
    od;
    return fail;
    end );

InstallMethod( PositionProperty,
    "for dense list and function",
    [ IsDenseList, IsFunction ],
    function ( list, func )
    local i;
    for i in [ 1 .. Length( list ) ] do
        if func( list[ i ] ) then
            return i;
        fi;
    od;
    return fail;
    end );

InstallMethod( PositionProperty,
    "for dense list, function, and integer",
    [ IsDenseList, IsFunction, IsInt ],
    function( list, func, from )
    local i;

    if from < 0 then
      from:= 0;
    fi;
    for i in [ from+1 .. Length( list ) ] do
      if func( list[i] ) then
        return i;
      fi;
    od;
    return fail;
    end );


#############################################################################
##
#M  PositionMaximum(<list>[, <func>]) .  position of the largest element
#M  PositionMinimum(<list>[, <func>]) .  position of the smallest element
##

InstallGlobalFunction( PositionMaximum,
    function ( args... )
    local list, func, i, bestval, bestindex, ival;

    if Length(args) < 1 or Length(args) > 2
       or not(IsList(args[1]))
       or (Length(args) = 2 and not(IsFunction(args[2]))) then
        ErrorNoReturn("Usage: PositionMaximum(<list>, [<func>])");
    fi;

    list := args[1];
    if Length(args) = 2 then
        func := args[2];
    else
        func := IdFunc;
    fi;

    bestindex := fail;
    for i in [ 1 .. Length( list ) ] do
        if IsBound( list[i] ) then
            ival := func ( list[ i ] );

            if not( IsBound(bestval) ) or ival > bestval then
                bestval := ival;
                bestindex := i;
            fi;
        fi;
    od;
    return bestindex;
    end );

InstallGlobalFunction( PositionMinimum,
    function ( args... )
    local list, func, i, bestval, bestindex, ival;

    if Length(args) < 1 or Length(args) > 2
       or not(IsList(args[1]))
       or (Length(args) = 2 and not(IsFunction(args[2]))) then
        ErrorNoReturn("Usage: PositionMinimum(<list>, [<func>])");
    fi;

    list := args[1];
    if Length(args) = 2 then
        func := args[2];
    else
        func := IdFunc;
    fi;

    bestindex := fail;
    for i in [ 1 .. Length( list ) ] do
        if IsBound( list[i] ) then
            ival := func ( list[ i ] );

            if not( IsBound(bestval) ) or ival < bestval then
                bestval := ival;
                bestindex := i;
            fi;
        fi;
    od;
    return bestindex;
    end );

#############################################################################
##
#M  PositionsProperty(<list>,<func>)  . positions of elements with a property
##
InstallMethod( PositionsProperty,
    "for list and function",
    [ IsList, IsFunction ],
    function( list, func )
    local result, i;

    result:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[ i ] ) and func( list[i] ) then
        Add( result, i );
      fi;
    od;

    SetIsSSortedList( result, true );

    return result;
    end );

InstallMethod( PositionsProperty,
    "for dense list and function",
    [ IsDenseList, IsFunction ],
    function( list, func )
    local result, i;

    result:= [];
    for i in [ 1 .. Length( list ) ] do
      if func( list[i] ) then
        Add( result, i );
      fi;
    od;

    SetIsSSortedList( result, true );

    return result;
    end );


#############################################################################
##
#M  PositionBound( <list> ) . . . . . . . . . . position of first bound entry
##
InstallMethod( PositionBound,
    "for a list",
    [ IsList ],
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
#M  PositionsBound( <list> ) . . . . . . . . . positions of all bound entries
##
InstallGlobalFunction( PositionsBound, function( list )
    local i, bound;

    if IsDenseList( list ) then
        return [ 1 .. Length( list ) ];
    fi;

    bound := [];
    for i in [ 1 .. Length( list ) ] do
        if IsBound( list[i] )  then
            Add( bound, i );
        fi;
    od;

    SetIsSSortedList( bound, true );

    return bound;
end );


#############################################################################
##
#M  PositionSublist( <list>,<sub>[,<ind>] )
##
InstallMethod( PositionSublist,
    "list,sub,pos",
    [IsList,IsList,IS_INT],
    function( list,sub,start )
      local n, m, next, j, max, i;

  n:=Length(list);
  m:=Length(sub);
  start:=Position(list, sub[1], start);

  # trivial case
  if m = 1 or start = fail then
    return start;
  fi;

  # string-match algorithm, cf. Manber, section 6.7

  # compute the next entries
  next:=[-1,0];
  for i in [3..m] do
    j:=next[i-1]+1;
    while j>0 and sub[i-1]<>sub[j] do
      j:=next[j]+1;
    od;
    next[i]:=j;
  od;

  if Maximum(next) * 3 < m then
    # in this case reduce overhead and use naive loop
    i := start;
    max := n - m + 1;
    while i<>fail and i <= max do
      for j in [2..m] do
        if list[i+j-1] <> sub[j] then
          j := 0;
          break;
        fi;
      od;
      if j <> 0 then
        return i;
      fi;
      i:=Position(list, sub[1], i);
    od;
    return fail;

  fi;

  # otherwise repeat with Manber
  i:=start;
  j:=1;
  while i<=n do
    if sub[j]=list[i] then
      i:=i+1;
      j:=j+1;
    else
      j:=next[j]+1;
      if j=0 then
        j:=1;
        i:=i+1;
      fi;
    fi;
    if j=m+1 then
      return i-m;
    fi;
  od;
  return fail;
end);

# no installation restrictions to avoid extra installations for empty list
#T but the first two arguments should be in `IsList', shouldn't they?
InstallOtherMethod( PositionSublist,
    "list, sub",
    [IsObject,IsObject],
    function( list,sub )
    return PositionSublist(list,sub,0);
    end);

InstallOtherMethod( PositionSublist,
    "empty list,sub,pos",
    [IsEmpty,IsList,IS_INT],
    ReturnFail);

InstallOtherMethod( PositionSublist,
    "list,empty,pos",
    [IsList,IsEmpty,IS_INT],
    function(a,b,c)
    return Maximum(c+1,1);
    end);


#############################################################################
##
#M  IsMatchingSublist( <list>,<sub>[,<ind>] )
##
InstallMethod( IsMatchingSublist,
    "list,sub,pos",
    IsFamFamX,
    [IsList,IsList,IS_INT],
    function( list,sub,first )
    local last;

    last:=first+Length(sub)-1;
    return Length(list) >= last and list{[first..last]} = sub;
    end);

# no installation restrictions to avoid extra installations for empty list
InstallOtherMethod( IsMatchingSublist,
    "list, sub",
    [IsObject,IsObject],
    function( list,sub )
    return IsMatchingSublist(list,sub,1);
    end);

InstallOtherMethod( IsMatchingSublist,
    "empty list,sub,pos",
    [IsEmpty,IsList,IS_INT],
    function(list,sub,first )
    return not IsEmpty(sub);
    end);

InstallOtherMethod( IsMatchingSublist,
    "list,empty,pos",
    [IsList,IsEmpty,IS_INT],
    ReturnTrue);


#############################################################################
##
#M  Add( <list>, <obj> )
##
InstallMethod( Add,
    "for mutable list and list",
    [ IsList and IsMutable, IsObject ],
    ADD_LIST_DEFAULT );

InstallMethod( Add, "three arguments fast version",
        [ IsPlistRep and IsList and IsMutable, IsObject, IsPosInt],
        function(l, o, p)
    local len;
    len := Length(l);
    if p <= len then
        CopyListEntries(l,p,1,l,p+1,1,len-p+1);
    fi;
    l[p] := o;
    return;
end);

InstallMethod( Add, "three arguments fast version sorted",
        [ IsPlistRep and IsSSortedList and IsMutable, IsObject, IsPosInt],
        function(l, o, p)
    local len;
    len := Length(l);
    if p <= len then
        CopyListEntries(l,p,1,l,p+1,1,len-p+1);
    fi;
    l[p] := o;
    if IS_DENSE_LIST(l) and (p = 1 or l[p-1] < o) and (p = len+1 or o < l[p+1]) then
        SET_IS_SSORTED_PLIST(l);
    fi;
    return;
end);

InstallMethod( Add, "three arguments general version",
        [IsList and IsMutable, IsObject, IsPosInt],
        function(l, o, p)
    local len;
    len := Length(l);
    if p <= len then
        l{[len+1,len..p+1]} := l{[len,len-1..p]};
    fi;
    l[p] := o;
    return;
end);


#############################################################################
##
#M  Remove(<list>[,<pos>])
##

InstallMethod(Remove, "one argument", [IsList and IsMutable],
        function(l)
    local x,len;
    len := Length(l);
    if len = 0 then
      Error("Remove: list <l> must not be empty.\n");
    fi;
    x := l[len];
    Unbind(l[len]);
    return x;
end);

InstallEarlyMethod(Remove,
        function(l,p)
    local ret,x,len;
    if not (IsPlistRep(l) and IsMutable(l) and IsPosInt(p)) then
        TryNextMethod();
    fi;
    len := Length(l);
    ret := IsBound(l[p]);
    if ret then
        x := l[p];
    fi;
    if p <= len then
        CopyListEntries(l,p+1,1,l,p,1,len-p);
        Unbind(l[len]);
    fi;
    if ret then
        return x;
    fi;
end);

InstallMethod(Remove, "two arguments, general", [IsList and IsMutable, IsPosInt],
        function(l,p)
    local ret,x,len;
    len := Length(l);
    ret := IsBound(l[p]);
    if ret then
        x := l[p];
    fi;
    if p <= len then
        l{[p..len-1]} := l{[p+1..len]};
        Unbind(l[len]);
    fi;
    if ret then
        return x;
    fi;
end);




#############################################################################
##
#M  Append(<list1>,<list2>)
##
BindGlobal( "APPEND_LIST_DEFAULT", function ( list1, list2 )
    local  len1, len2, i;
    len1 := Length(list1);
    len2 := Length(list2);
    if len1 = infinity then
        Error("Append: can't append to an infinite list");
    fi;
    if len2 = infinity then
        Error("Append: Default method can't append an infinite list");
    fi;
    for i  in [1..len2]  do
        if IsBound(list2[i])  then
            list1[len1+i] := list2[i];
        fi;
    od;
end );

InstallMethod( Append,
    "for mutable list and list",
    [ IsList and IsMutable , IsList ],
    APPEND_LIST_DEFAULT );


InstallMethod( Append,
    "for mutable list in plist representation, and small list",
    [ IsList and IsPlistRep and IsMutable, IsList and IsSmallList ],
    APPEND_LIST_INTR );


#############################################################################
##
#F  Apply( <list>, <func> ) . . . . . . . .  apply a function to list entries
##
InstallGlobalFunction( Apply, function( list, func )
    local i;
    for i in [1..Length( list )] do
        if IsBound(list[i]) then
            list[i] := func( list[i] );
        fi;
    od;
end );


#############################################################################
##
#F  Concatenation( <list1>, <list2>, ... )
#F  Concatenation( <list> )
##
InstallGlobalFunction( Concatenation, function ( arg )
    local  res, i;
    if Length( arg ) = 1 and IsList( arg[1] )  then
        arg := arg[1];
    fi;
    if Length( arg ) = 0  then
        return [  ];
    fi;
    if not IsList( arg[1] ) then
        Error( "Concatenation: arguments must be lists" );
    fi;
    res := ShallowCopy( arg[1] );
    for i  in [ 2 .. Length( arg ) ]  do
        if not IsList( arg[i] ) then
            Error( "Concatenation: arguments must be lists" );
        fi;
        Append( res, arg[i] );
    od;
    return res;
end );


#############################################################################
##
#M  Compacted( <list> ) . . . . . . . . . . . . . .  remove holes from a list
##
InstallMethod( Compacted,
    "for a list",
    [ IsList ],
    function ( list )
    local   res,        # compacted of <list>, result
            elm;        # element of <list>
    if IsDenseList(list) then
      return ShallowCopy(list);
    fi;
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
    [ IsList ],
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
    [ IsList ],
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
    [ IsList ],
    DuplicateFreeList );


#############################################################################
##
#M  Flat( <list> )  . . . . . . . list of elements of a nested list structure
##
InstallMethod( Flat,
    "for a list",
    [ IsList ],
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
#F  Reversed( <list> )  . . . . . . . . . . .  reverse the elements in a list
##
##  Note that the special case that <list> is a range is dealt with by the
##  `{}' implementation, we need not introduce a special treatment for this.
##
InstallGlobalFunction( Reversed,
    function( list )
    local tnum, len;
    tnum:= TNUM_OBJ( list );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      len:= Length( list );
      return list{ [ len, len-1 .. 1 ] };
    else
      return ReversedOp( list );
    fi;
end );


#############################################################################
##
#M  ReversedOp( <list> )  . . . . . . . . . .  reverse the elements in a list
##
##  We install just two generic methods;
##  they deal with (non-internal) finite lists only.
##
InstallMethod( ReversedOp,
    "for a dense list",
    [ IsDenseList ],
    function( list )
    local len;
    if not IsFinite( list ) then
      TryNextMethod();
    fi;
    len:= Length( list );
    return list{ [ len, len-1 .. 1 ] };
    end );

InstallMethod( ReversedOp,
    "for a range",
    [ IsRange ],
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
#M  Shuffle( <list> ) . . . . . . . . . . . . . . . . permute entries randomly
InstallMethod(Shuffle, [IsDenseList and IsMutable], function(l)
  local len, j, tmp, i;
  len := Length(l);
  for i in [1..len-1] do
    j := Random(i, len);
    if i <> j then
      tmp := l[i];
      l[i] := l[j];
      l[j] := tmp;
    fi;
  od;
  return l;
end);

#############################################################################
##
#M  Sort( <list>[, <func>] )
##
InstallMethod( Sort,
    "for a mutable small list",
    [ IsList and IsMutable and IsSmallList ],
    SORT_LIST );

InstallMethod( StableSort,
    "for a mutable small list",
    [ IsList and IsMutable and IsSmallList ],
    STABLE_SORT_LIST );

InstallMethod( Sort,
    "for a mutable list",
    [ IsList and IsMutable ],
    function( list )
    if IsSmallList( list ) then
      SORT_LIST( list );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( StableSort,
    "for a mutable list",
    [ IsList and IsMutable ],
    function( list )
    if IsSmallList( list ) then
      STABLE_SORT_LIST( list );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( Sort,
    "for a mutable set",
    [ IsList and IsMutable and IsSortedList ], SUM_FLAGS,
    Ignore );

InstallMethod( StableSort,
    "for a mutable set",
    [ IsList and IsMutable and IsSortedList ], SUM_FLAGS,
    Ignore );

InstallMethod( Sort,
    "for a mutable small list and a function",
    [ IsList and IsMutable and IsSmallList, IsFunction ],
    SORT_LIST_COMP );

InstallMethod( StableSort,
    "for a mutable small list and a function",
    [ IsList and IsMutable and IsSmallList, IsFunction ],
    STABLE_SORT_LIST_COMP );

InstallMethod( Sort,
    "for a mutable list and a function",
    [ IsList and IsMutable, IsFunction ],
    function( list, func )
    if IsSmallList( list ) then
      SORT_LIST_COMP( list, func );
    else
      TryNextMethod();
  fi;
end );

InstallMethod( StableSort,
    "for a mutable list and a function",
    [ IsList and IsMutable, IsFunction ],
    function( list, func )
    if IsSmallList( list ) then
      STABLE_SORT_LIST_COMP( list, func );
    else
      TryNextMethod();
  fi;
end );

#############################################################################
##
#M  SortBy( <list>, <func> )
##

InstallMethod( SortBy, "for a mutable list and a function",
        [IsList and IsMutable, IsFunction ],
        function(list, func)
    local images;
    images := List(list, func);
    SortParallel(images, list);
    return;
end);

InstallMethod( StableSortBy, "for a mutable list and a function",
        [IsList and IsMutable, IsFunction ],
        function(list, func)
    local images;
    images := List(list, func);
    StableSortParallel(images, list);
    return;
end);

#############################################################################
##
#F  SORT_MUTABILITY_ERROR_HANDLER( <list> )
#F  SORT_MUTABILITY_ERROR_HANDLER( <list>, <func> )
#F  SORT_MUTABILITY_ERROR_HANDLER( <list1>, <list2> )
#F  SORT_MUTABILITY_ERROR_HANDLER( <list1>, <list2>, <func> )
##
##  This function will be installed as method for `Sort', `Sortex' and
##  `SortParallel', for the sake of a more gentle error message.
##
BindGlobal( "SORT_MUTABILITY_ERROR_HANDLER", function( arg )
  if    ( Length( arg ) = 1 and IsMutable( arg[1] ) )
     or ( Length( arg ) = 2 and IsMutable( arg[1] )
            and ( IsFunction( arg[2] ) or IsMutable( arg[2] ) ) )
     or ( Length( arg ) = 3 and IsMutable( arg[1] )
            and IsMutable( arg[2] ) ) then
    TryNextMethod();
  fi;
  Error( "immutable lists cannot be sorted" );
end );

InstallOtherMethod( Sort,
    "for an immutable list",
    [ IsList ],
    SORT_MUTABILITY_ERROR_HANDLER );

InstallOtherMethod( StableSort,
    "for an immutable list",
    [ IsList ],
    SORT_MUTABILITY_ERROR_HANDLER );

InstallOtherMethod( Sort,
    "for an immutable list and a function",
    [ IsList, IsFunction ],
    SORT_MUTABILITY_ERROR_HANDLER );

InstallOtherMethod( StableSort,
    "for an immutable list and a function",
    [ IsList, IsFunction ],
    SORT_MUTABILITY_ERROR_HANDLER );


#############################################################################
##
#M  Sortex( <list> ) . . sort a list (stable), return the applied permutation
##
InstallMethod( Sortex,
    "for a mutable list",
    [ IsList and IsMutable ],
    function ( list )
    local   n,  index;

    # {\GAP} supports permutations only up to `MAX_SIZE_LIST_INTERNAL'.
    if not IsSmallList( list ) then
      Error( "<list> must have length at most ", MAX_SIZE_LIST_INTERNAL );
    fi;

    n := Length(list);
    index := [1..n];
    StableSortParallel(list, index);
    return PermList(index)^-1;

    end );

InstallMethod( Sortex,
    "for a mutable list and a function",
    [ IsList and IsMutable, IsFunction ],
    function ( list, comp )
    local   n,  index;

    # {\GAP} supports permutations only up to `MAX_SIZE_LIST_INTERNAL'.
    if not IsSmallList( list ) then
      Error( "<list> must have length at most ", MAX_SIZE_LIST_INTERNAL );
  fi;

    n := Length(list);
    index := [1..n];
    StableSortParallel(list, index, comp);
    return PermList(index)^-1;

    end );

InstallMethod( Sortex,
    "for a mutable sorted list",
    [ IsDenseList and IsSortedList and IsMutable ], SUM_FLAGS,
    list -> () );

InstallOtherMethod( Sortex,
    "for an immutable list",
    [ IsList ],
    SORT_MUTABILITY_ERROR_HANDLER );


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
InstallMethod( SortingPerm,
    [ IsDenseList ],
    function( list )
        local copy;

        copy := ShallowCopy(list);
        return Sortex(copy);
    end );

InstallMethod( SortingPerm,
    "for a dense and sorted list",
    [ IsDenseList and IsSortedList ], SUM_FLAGS,
    list -> () );


#############################################################################
##
#M  SortParallel( <list>, <list2> ) . . . . . . .  sort two lists in parallel
##
InstallMethod( SortParallel,
    "for two mutable lists",
    [ IsList and IsMutable,
      IsList and IsMutable ],
    SORT_PARA_LIST );

InstallMethod( StableSortParallel,
    "for two mutable lists",
    [ IsList and IsMutable,
      IsList and IsMutable ],
    STABLE_SORT_PARA_LIST );

#############################################################################
##
#M  SortParallel( <sorted>, <list> )
##
InstallMethod( SortParallel,
    "for a mutable set and a dense mutable list",
    [ IsDenseList and IsSortedList and IsMutable,
      IsDenseList and IsMutable ],
    SUM_FLAGS,
    Ignore );

InstallMethod( StableSortParallel,
    "for a mutable set and a dense mutable list",
    [ IsDenseList and IsSortedList and IsMutable,
      IsDenseList and IsMutable ],
    SUM_FLAGS,
    Ignore );

#############################################################################
##
#M  SortParallel( <list>, <list2>, <func> )
##
InstallMethod( SortParallel,
    "for mutable lists, and function",
    [ IsList and IsMutable,
      IsList and IsMutable,
      IsFunction ],
    SORT_PARA_LIST_COMP );

InstallMethod( StableSortParallel,
    "for two mutable lists, and function",
    [ IsList and IsMutable,
      IsList and IsMutable,
      IsFunction ],
    STABLE_SORT_PARA_LIST_COMP );

InstallOtherMethod( SortParallel,
    "for two immutable lists",
    [IsList,IsList],
    SORT_MUTABILITY_ERROR_HANDLER);

InstallOtherMethod( StableSortParallel,
    "for two immutable lists",
    [IsList,IsList],
    SORT_MUTABILITY_ERROR_HANDLER);

InstallOtherMethod( SortParallel,
    "for two immutable lists and function",
    [IsList,IsList,IsFunction],
    SORT_MUTABILITY_ERROR_HANDLER);

InstallOtherMethod( StableSortParallel,
    "for two immutable lists and function",
    [IsList,IsList,IsFunction],
    SORT_MUTABILITY_ERROR_HANDLER);

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
    "for a list",
    [ IsList ],
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
    "for a list and a seed",
    [ IsList, IsObject ],
    function ( list, max )
    local elm;
    for elm in list do
        if max < elm  then
            max := elm;
        fi;
    od;
    return max;
    end );

InstallMethod( MaximumList,
    "for a range",
    [ IsRange ],
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

InstallMethod( MaximumList,
    "for a range and a seed",
    [ IsRange, IsObject ],
    function ( range, max )
    local len;
    len := Length(range);
    if max < range[1] then
        max := range[1];
    fi;
    if len > 0 and max < range[len] then
        max := range[len];
    fi;
    return max;
    end );

InstallMethod( MaximumList,
    "for a sorted list",
    [ IsSSortedList ],
    function ( list )
    local len;
    len := Length(list);
    if len = 0 then
      Error( "MaximumList: <list> must contain at least one element" );
    fi;
    return list[len];
    end );

InstallMethod( MaximumList,
    "for a sorted list and a seed",
    [ IsSSortedList, IsObject ],
    function ( list, max )
    local len;
    len := Length(list);
    if len > 0 and list[len] > max then
        return list[len];
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
    "for a list",
    [ IsList ],
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
    "for a list",
    [ IsList, IsObject ],
    function ( list, min )
    local elm;
    for elm  in list  do
        if elm < min then
            min := elm;
        fi;
    od;
    return min;
    end );

InstallMethod( MinimumList,
    "for a range",
    [ IsRange ],
    function ( range )
    local min, len;
    len := Length(range);
    if len = 0 then
        Error( "MinimumList: <range> must contain at least one element" );
    fi;
    min := range[ len ];
    if range[1] < min then
        return range[1];
    fi;
    return min;
    end );

InstallMethod( MinimumList,
    "for a range and a seed",
    [ IsRange, IsObject ],
    function ( range, min )
    local len;
    len := Length(range);
    if min > range[1] then
        min := range[1];
    fi;
    if len > 0 and min > range[len] then
        min := range[len];
    fi;
    return min;
    end );

InstallMethod( MinimumList,
    "for a sorted list",
    [ IsSSortedList ],
    function ( list )
    if Length(list) = 0 then
      Error( "MinimumList: <list> must contain at least one element" );
    fi;
    return list[1];
    end );

InstallMethod( MinimumList,
    "for a sorted list and a seed",
    [ IsSSortedList, IsObject ],
    function ( list, min )
    if Length(list) > 0 and list[1] < min then
        return list[1];
    fi;
    return min;
    end );

#############################################################################
##
#F  Cartesian( <list1>, <list2>, ... )
#F  Cartesian( <list> )
##
DeclareGlobalName( "Cartesian2" );
BindGlobal( "Cartesian2", function ( list, n, tup, i )
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
end );

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
    [ IsList, IS_PERM ],
    function( list, perm )
    # this was proposed by Jean Michel
    return list{ OnTuples( [ 1 .. Length( list ) ], perm^-1 ) };
    end );


#############################################################################
##
#F  First( <C>, <func> )  . . .  find first element in a list with a property
##
InstallEarlyMethod( First,
    function ( C )
    local tnum, elm;
    tnum:= TNUM_OBJ( C );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      for elm in C do
        return elm;
      od;
      return fail;
    fi;
    TryNextMethod();
    end );

InstallEarlyMethod( First,
    function ( C, func )
    local tnum, elm;
    tnum:= TNUM_OBJ( C );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      for elm in C do
        if func( elm ) then
          return elm;
        fi;
      od;
      return fail;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  First( <C>, <func> ) . . . . find first element in a list with a property
##
InstallMethod( First,
    "for a list or collection and a function",
    [ IsListOrCollection, IsFunction ],
    function ( C, func )
    local elm;
    for elm in C do
        if func( elm ) then
            return elm;
        fi;
    od;
    return fail;
    end );

InstallMethod( First,
    "for a list or collection",
    [ IsListOrCollection ],
    function ( C )
    local elm;
    for elm in C do
        return elm;
    od;
    return fail;
    end );


#############################################################################
##
#F  Last( <C>, <func> )  . . . .  find last element in a list with a property
##
InstallGlobalFunction( Last,
    function ( C, func... )
    local tnum, i;
    if Length( func ) > 1 then
      Error( "too many arguments" );
    fi;
    tnum:= TNUM_OBJ( C );
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      if Length( func ) = 0 then
        func := ReturnTrue;
      else
        func := func[1];
      fi;
      for i in [Length(C),Length(C)-1..1] do
          if IsBound(C[i]) and func(C[i]) then
              return C[i];
          fi;
      od;
      return fail;
    elif Length( func ) = 0 then
      return LastOp( C );
    else
      return LastOp( C, func[1] );
    fi;
end );


#############################################################################
##
#M  LastOp( <C>, <func> )  . . .  find last element in a list with a property
##
InstallMethod( LastOp,
    "for a list and a function",
    [ IsList and IsFinite, IsFunction ],
    function ( list, func )
    local i;
    for i in [Length(list),Length(list)-1..1] do
        if IsBound(list[i]) and func(list[i]) then
            return list[i];
        fi;
    od;
    return fail;
    end );

InstallMethod( LastOp,
    "for a list",
    [ IsList and IsFinite ],
    function ( list )
    return LastOp(list, ReturnTrue);
    end );


#############################################################################
##
#M  Iterated( <list>, <func> )  . . . . . . .  iterate a function over a list
##
InstallMethod( Iterated,
    "for a list and a function",
    [ IsList, IsFunction ],
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
#M  ListN( <list1>, <list2>, ..., <listn>, <f> )
##
InstallGlobalFunction( ListN, function ( arg )
    local num, func, len;

    num := Length(arg) -1;
    func := arg[num+1];
    Unbind( arg[num+1] );
    len := Length(arg[1]);

    if not IsFunction(func) then
        Error("Last argument must be a function");
    elif ForAny( arg, a -> not IsList(a) or Length(a) <> len ) then
        Error("<arg1>, ..., <argn> must be lists of the same length");
    fi;

    return List( [1..len],
                 i -> CallFuncList( func,  List( [1..num],
                                                  j -> arg[j][i] ) ) );
end );

#############################################################################
##
#M  IsBound( list[i] ) . . . . . . . . . . . . . . .  IsBound for dense lists
##
InstallMethod( IsBound\[\],
    "for a dense list and positive integer",
    [ IsDenseList, IsPosInt ],
    function( list, index )
    return index <= Length( list );
    end );

#############################################################################
##
#M  IsBound( list[i] ) . . . . . IsBound for small lists with large arguments
##
InstallMethod( IsBound\[\],
    "for a small list and large positive integer",
    [ IsSmallList, IsPosInt ],
    function( list, index )
    if IsSmallIntRep(index) then
        TryNextMethod();
    else
        return false;
    fi;
    end );

#############################################################################
##
##  Arithmetic behaviour of lists
##


#############################################################################
##
#M  ZeroOp( <list> ) . . . . . . . . . . .  for small list in `IsListDefault'
#M  ZeroSameMutability( <list> ) . . . . .  for small list in `IsListDefault'
##
##  Default methods are installed only for small lists in `IsListDefault'.
##  For those lists, `Zero' is defined pointwise.
##  (If the lists are inhomogeneous then strange things may happen,
##  for example `Zero( <l1> + <l2> )' is in general different from
##  `Zero( <l1> ) + Zero( <l2> )'.)
##
InstallOtherMethod( ZeroMutable,
    [ IsListDefault and IsSmallList ],
    ZERO_MUT_LIST_DEFAULT );

InstallOtherMethod( ZeroSameMutability,
    [ IsListDefault and IsSmallList ],
    ZERO_LIST_DEFAULT );


#############################################################################
##
#M  AdditiveInverseOp( <list> )  . . . . .  for small list in `IsListDefault'
#M  AdditiveInverseSameMutability( <list> ) for small list in `IsListDefault'
##
##  Default methods are installed only for small lists in `IsListDefault'.
##  For those lists, `AdditiveInverse' is defined pointwise.
##
InstallOtherMethod( AdditiveInverseMutable,
    [ IsListDefault and IsSmallList ],
    AINV_MUT_LIST_DEFAULT );

InstallOtherMethod( AdditiveInverseSameMutability,
    [ IsListDefault and IsSmallList ],
    AINV_LIST_DEFAULT );


#############################################################################
##
#M  <grv> + <nonlist>  . . . . . . . . . .  for small list in `IsListDefault'
#M  <nonlist> + <grv>  . . . . . . . . . .  for small list in `IsListDefault'
##
##  Default methods are installed only for small lists in `IsListDefault'.
##  For those lists, the sum with an object that is neither a list nor a
##  domain is defined pointwise.
##
InstallOtherMethod( \+,
    [ IsListDefault and IsSmallList, IsObject ],
    function( list, nonlist )
    if IsList( nonlist ) or IsDomain( nonlist ) then
      TryNextMethod();
    else
      return SUM_LIST_SCL_DEFAULT( list, nonlist );
    fi;
    end );

InstallOtherMethod( \+,
    [ IsObject, IsListDefault and IsSmallList ],
    function( nonlist, list )
    if IsList( nonlist ) or IsDomain( nonlist ) then
      TryNextMethod();
    else
      return SUM_SCL_LIST_DEFAULT( nonlist, list );
    fi;
    end );


#############################################################################
##
#F  LIST_WITH_HOMOGENEOUS_MUTABILITY_LEVEL( <list>, <level> )
##
DeclareGlobalFunction( "LIST_WITH_HOMOGENEOUS_MUTABILITY_LEVEL" );

InstallGlobalFunction( LIST_WITH_HOMOGENEOUS_MUTABILITY_LEVEL,
    function( list, level )
    local i;

    if not IsCopyable( list ) then
      return list;
    elif level <= 0 then
      return Immutable( list );
    fi;
    list:= ShallowCopy( list );
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        list[i]:= LIST_WITH_HOMOGENEOUS_MUTABILITY_LEVEL( list[i], level - 1 );
      fi;
    od;
    return list;
    end );


#############################################################################
##
#F  IMMUTABILITY_LEVEL( <list> )
##
DeclareGlobalFunction( "IMMUTABILITY_LEVEL2" );

InstallGlobalFunction( IMMUTABILITY_LEVEL2, function( list )
    if not IsGeneralizedRowVector( list ) or IsEmpty( list ) then
      return 0;
    elif IsMutable( list ) then
      return IMMUTABILITY_LEVEL2( list[ PositionBound( list ) ] );
    else
      return 1 + IMMUTABILITY_LEVEL2( list[ PositionBound( list ) ] );
    fi;
    end );

BindGlobal( "IMMUTABILITY_LEVEL", function( list )
    if IsMutable( list ) then
      return IMMUTABILITY_LEVEL2( list );
    else
      return infinity;
    fi;
end );


#############################################################################
##
#F  SUM_LISTS_SPECIAL( <left>, <right>, <depthleft>, <depthright> )
##
##  This is a generic addition function for two small lists <left>, <right>
##  in `IsListDefault' which have additive nesting depths <depthleft> and
##  <depthright>, respectively.
##
##  If at least one of <left>, <right> is non-dense or has additive nesting
##  depth at least $3$, `SUM_LISTS_SPECIAL' is called by the generic `\+'
##  method for two small lists in `IsListDefault'.
##
BindGlobal( "SUM_LISTS_SPECIAL",
    function( left, right, depthleft, depthright )
    local result, len1, len2, i, depth, depth2;

    result:= [];
    len1:= Length( left );
    len2:= Length( right );

    # Compute the sum.
    if depthleft = depthright then
      if len1 < len2 then
        len1:= len2;
      fi;
      for i in [ 1 .. len1 ] do
        if IsBound( left[i] ) then
          if IsBound( right[i] ) then
            result[i]:= left[i] + right[i];
          else
            result[i]:= ShallowCopy( left[i]);
          fi;
        elif IsBound( right[i] ) then
          result[i]:= ShallowCopy(right[i]);
        fi;
      od;
    elif depthleft < depthright then
      for i in [ 1 .. len2 ] do
        if IsBound( right[i] ) then
          result[i]:= left + right[i];
        fi;
      od;
    else
      for i in [ 1 .. len1 ] do
        if IsBound( left[i] ) then
          result[i]:= left[i] + right;
        fi;
      od;
    fi;

    # Adjust the mutability status.
    depth:= IMMUTABILITY_LEVEL( left );
    depth2:= IMMUTABILITY_LEVEL( right );
    if depth2 < depth then
      depth:= depth2;
    fi;
    if depth = infinity then
      result:= Immutable( result );
    else
      result:= LIST_WITH_HOMOGENEOUS_MUTABILITY_LEVEL( result,
                   NestingDepthA( result ) - depth );
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#M  <list1> + <list2>  . . . . . . . . for two small lists in `IsListDefault'
##
##  A default method is installed only for two small lists in
##  `IsListDefault'.
##  For those lists, the sum is computed depending on the additive nesting
##  depth.
##
InstallOtherMethod( \+,
    [ IsListDefault and IsSmallList, IsListDefault and IsSmallList ],
    function( left, right )
    local depth1, depth2;

    depth1:= NestingDepthA( left );
    depth2:= NestingDepthA( right );
    if    (2 < depth1 and not IsDenseList( left ))
          or (2 < depth2 and not IsDenseList( right )) then
        return SUM_LISTS_SPECIAL( left, right, depth1, depth2 );
    elif depth1 = depth2 then
      return SUM_LIST_LIST_DEFAULT( left, right );
    elif depth1 < depth2 then
      return SUM_SCL_LIST_DEFAULT( left, right );
    else
      return SUM_LIST_SCL_DEFAULT( left, right );
    fi;
    end );


#############################################################################
##
#M  <obj1> - <obj2>
##
##  For two {\GAP} objects $x$ and $y$ of which one is in
##  `IsGeneralizedRowVector' and the other is either not a list or is
##  also in `IsGeneralizedRowVector',
##  $x - y$ is defined as $x + (-y)$.
##  For this case, we install a default method that relies on `\+'.
##
##  A (better?) default method is installed only for two small lists in
##  `IsListDefault'.
##
InstallOtherMethod( \-,
    [ IsGeneralizedRowVector, IsGeneralizedRowVector ],
    function( grv1, grv2 )
    return grv1 + (-grv2);
    end );

InstallOtherMethod( \-,
    [ IsGeneralizedRowVector, IsObject ],
    function( grv, nonlist )
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    return grv + (-nonlist);
    end );

InstallOtherMethod( \-,
    [ IsObject, IsGeneralizedRowVector ],
    function( nonlist, grv )
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    return nonlist + (-grv);
    end );

InstallOtherMethod( \-,
    [ IsListDefault and IsSmallList, IsListDefault and IsSmallList ],
    function( left, right )
    local depth1, depth2;

    depth1:= NestingDepthA( left );
    depth2:= NestingDepthA( right );
    if    (2 < depth1 and not IsDenseList( left ))
       or (2 < depth2 and not IsDenseList( right )) then
      return SUM_LISTS_SPECIAL( left, - right, depth1, depth2 );
    elif depth1 = depth2 then
      return DIFF_LIST_LIST_DEFAULT( left, right );
    elif depth1 < depth2 then
      return DIFF_SCL_LIST_DEFAULT( left, right );
    else
      return DIFF_LIST_SCL_DEFAULT( left, right );
    fi;
    end );


#############################################################################
##
#M  OneOp( <matrix> ) . . . . . . . . . . . . . for matrix in `IsListDefault'
#M  OneSameMutability( <matrix> ) . . . . . . . for matrix in `IsListDefault'
##
InstallOtherMethod( OneOp,
    [ IsListDefault ],
    function( mat )
    if IsSmallList( mat ) and NestingDepthM( mat ) mod 2 = 0 then
      return ONE_MATRIX_MUTABLE( mat );
    else
      TryNextMethod();
    fi;
    end );

InstallOtherMethod( OneSameMutability,
    [ IsListDefault ],
    function( mat )
    if IsSmallList( mat ) and NestingDepthM( mat ) mod 2 = 0 then
      return ONE_MATRIX_SAME_MUTABILITY( mat );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  InverseOp( <matrix> ) . . . . . . . . . . . for matrix in `IsListDefault'
#M  InverseSameMutability( <matrix> ) . . . . . for matrix in `IsListDefault'
##
##  The `INV_MAT_DEFAULT' methods are faster for lists of FFEs because they
##  use `AddRowVector', etc.
##
InstallOtherMethod( InverseOp,
    "for default list whose rows are vectors of FFEs",
    [ IsListDefault and IsRingElementTable and IsFFECollColl ],
    function( mat )
    if NestingDepthM( mat ) mod 2 = 0 and IsSmallList( mat ) then
        if IsRectangularTable( mat ) then
            return INV_MAT_DEFAULT_MUTABLE( mat );
        else
            return fail;
        fi;
    else
      TryNextMethod();
    fi;
    end );

InstallOtherMethod( InverseOp,
    "for default list over a ring without zero divisors",
    [ IsListDefault and IsZDFRECollColl ],
    function( mat )
    if NestingDepthM( mat ) mod 2 = 0 and IsSmallList( mat ) then
        if IsRectangularTable( mat ) then
            return INV_MATRIX_MUTABLE( mat );
        else
            return fail;
        fi;
    else
      TryNextMethod();
    fi;
    end );

InstallOtherMethod( InverseSameMutability,
    "for default list whose rows are vectors of FFEs",
    [ IsListDefault and IsRingElementTable and IsFFECollColl ],
    function( mat )
    if NestingDepthM( mat ) mod 2 = 0 and IsSmallList( mat ) then
        if IsRectangularTable( mat ) then
            return INV_MAT_DEFAULT_SAME_MUTABILITY( mat );
        else
            return fail;
        fi;
    else
      TryNextMethod();
    fi;
    end );

InstallOtherMethod( InverseSameMutability,
    "for default list over a ring without zero divisors",
    [ IsListDefault and IsZDFRECollColl ],
    function( mat )
    if NestingDepthM( mat ) mod 2 = 0 and IsSmallList( mat ) then
        if IsRectangularTable( mat ) then
            return INV_MATRIX_SAME_MUTABILITY( mat );
        else
            return fail;
        fi;
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
    PROD );


#############################################################################
##
#M  <mgrv> * <nonlist> . . . . . . . . . .  for small list in `IsListDefault'
#M  <nonlist> * <mgrv> . . . . . . . . . .  for small list in `IsListDefault'
##
##  Default methods are installed only for small lists in `IsListDefault'.
##  For those lists, the product with an object that is neither a list nor a
##  domain is defined pointwise.
##
InstallOtherMethod( \*,
    [ IsListDefault and IsSmallList, IsObject ],
    function( list, nonlist )
    if IsList( nonlist ) or IsDomain( nonlist ) then
      TryNextMethod();
    else
      return PROD_LIST_SCL_DEFAULT( list, nonlist );
    fi;
    end );

InstallOtherMethod( \*,
    [ IsObject, IsListDefault and IsSmallList ],
    function( nonlist, list )
    if IsList( nonlist ) or IsDomain( nonlist ) then
      TryNextMethod();
    else
      return PROD_SCL_LIST_DEFAULT( nonlist, list );
    fi;
    end );


#############################################################################
##
#F  LIST_WITH_HOLES( <list>, <func> )
##
BindGlobal( "LIST_WITH_HOLES", function( list, func )
    local result, i;

    result:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        result[i]:= func( list[i] );
      fi;
    od;
    return result;
    end );
#T Note that the two-argument version of `List' is defined only for dense
#T lists -- I think this restriction could be removed now!


#############################################################################
##
#F  PROD_LISTS_SPECIAL( <left>, <right>, <depthleft>, <depthright> )
##
##  This is a generic multiplication function for two small lists <left>,
##  <right> in `IsListDefault' which have multiplicative nesting depths
##  <depthleft> and <depthright>, respectively.
##
##  If at least one of <left>, <right> is non-dense or has multiplicative
##  nesting depth at least $3$, `PROD_LISTS_SPECIAL' is called by the generic
##  `\*' method for two small lists in `IsListDefault'.
##
BindGlobal( "PROD_LISTS_SPECIAL",
    function( left, right, depthleft, depthright )
    local len1, len2, prods, i, result, depth, depth2;

    # Compute the product.
    if IsOddInt( depthleft ) then
      if IsOddInt( depthright ) or depthleft < depthright then
        # vector product
        len1:= Length( left );
        len2:= Length( right );
        if len2 < len1 then
          len1:= len2;
        fi;
        prods:= [];
        for i in [ 1 .. len1 ] do
          if IsBound( left[i] ) and IsBound( right[i] ) then
            Add( prods, left[i] * right[i] );
          fi;
        od;
        if IsEmpty( prods ) then
          Error( "no summands to add up in mult. of <left> and <right>" );
        fi;
        result:= prods[1];
        for i in [ 2 .. Length( prods ) ] do
          result:= result + prods[i];
        od;
      else
        # <vec> * <scl>
        result:= LIST_WITH_HOLES( left, x -> x * right );
      fi;
    elif IsOddInt( depthright ) then
      if depthleft < depthright then
        # <scl> * <vec>
        result:= LIST_WITH_HOLES( right, x -> left * x );
      else
        # <mat> * <vec>
        result:= LIST_WITH_HOLES( left, x -> x * right );
      fi;
    elif depthleft = depthright then
      # <mat> * <mat>
      result:= LIST_WITH_HOLES( left, x -> x * right );
    elif depthleft < depthright then
      # <scl> * <mat>
      result:= LIST_WITH_HOLES( right, x -> left * x );
    else
      # <mat> * <scl>
      result:= LIST_WITH_HOLES( left, x -> x * right );
    fi;

    # Adjust the mutability status.
    depth:= IMMUTABILITY_LEVEL( left );
    depth2:= IMMUTABILITY_LEVEL( right );
    if depth2 < depth then
      depth:= depth2;
    fi;
    if depth = infinity then
      result:= Immutable( result );
    else
      result:= LIST_WITH_HOMOGENEOUS_MUTABILITY_LEVEL( result,
                   NestingDepthA( result ) - depth );
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#M  <list1> * <list2>  . . . . . . . . for two small lists in `IsListDefault'
##
##  A default method is installed only for two small lists in
##  `IsListDefault'.
##  For those lists, the product is defined depending on the multiplicative
##  nesting depths of the arguments.
##
InstallOtherMethod( \*,
    [ IsListDefault and IsSmallList, IsListDefault and IsSmallList ],
    function( left, right )
    local depth1, depth2, depthDiff, prod;

    depth1:= NestingDepthM( left );
    depth2:= NestingDepthM( right );
    if    (2 < depth1 and not IsDenseList( left ))
          or (2 < depth2 and not IsDenseList( right ))
          or  3 < depth1 or 3 < depth2 then
      return PROD_LISTS_SPECIAL( left, right, depth1, depth2 );
    elif IsOddInt( depth1 ) then
      if IsOddInt( depth2 ) or depth1 < depth2 then
          # <vec> * <vec> or <vec> * <mat>
          depthDiff := depth1 - depth2;
          if depthDiff < -1 or depthDiff > 1 then
              return PROD_LISTS_SPECIAL(left, right, depth1, depth2 );
          else
              return PROD_LIST_LIST_DEFAULT( left, right, depthDiff );
          fi;
      else
        # <vec> * <scl>
        return PROD_LIST_SCL_DEFAULT( left, right );
      fi;
    elif depth1 < depth2 then
      # <scl> * <vec> or <scl> * <mat>
      return PROD_SCL_LIST_DEFAULT( left, right );
  elif IsEvenInt(depth1) and IsOddInt(depth2) and depth1 > depth2 then
      # <mat>*<vec> may need to adjust mutability
      prod := PROD_LIST_SCL_DEFAULT( left, right );
      if IsMutable(prod) and not IsMutable(right) and
         not IsMutable(left[PositionBound(left)]) then
          MakeImmutable(prod);
      fi;
      return prod;
  else
      # <mat> * <scl> or  <mat> * <mat>
      return PROD_LIST_SCL_DEFAULT( left, right );
  fi;
end );


InstallMethod( \*,
        "More efficient non-recursive kernel method for vector*matrix of cyclotomics",
        [ IsListDefault and IsSmallList and IsCyclotomicCollection and
          IsPlistRep,
          IsListDefault and IsSmallList and IsCyclotomicCollColl and
          IsPlistRep and IsRectangularTable],
function(v, mat)
  local prod;
  if ForAny(mat, r-> not IsPlistRep(r)) then
    TryNextMethod();
  fi;
  prod := PROD_VECTOR_MATRIX(v, mat);
  if not IsMutable(v) and not IsMutable(mat) then
    MakeImmutable(prod);
  fi;
  return prod;
end);

InstallMethod( \*,
        "More efficient non-recursive method for matrix*matrix of cyclotomics",
        [ IsListDefault and IsSmallList and IsCyclotomicCollColl,
          IsListDefault and IsSmallList and IsCyclotomicCollColl and
          IsPlistRep and IsRectangularTable],
        function(m1,m2)
    local prod, row;
    if ForAny(m2, r-> not IsPlistRep(r)) or
       ForAny(m1, r-> not IsPlistRep(r)) then
      TryNextMethod();
    fi;
    prod := List(m1, row-> PROD_VECTOR_MATRIX(row, m2));
    if not IsMutable(m1) and not IsMutable(m2) then
        MakeImmutable(prod);
    fi;
    return prod;
end);


#############################################################################
##
#F  MOD_LIST_SCL_DEFAULT( <list>, <scalar> )
#F  MOD_SCL_LIST_DEFAULT( <scalar>, <list> )
#F  MOD_LIST_LIST_DEFAULT( <left>, <right> )
##
BindGlobal( "MOD_LIST_SCL_DEFAULT", function( list, scalar )
    local result, i;

    result:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        result[i]:= list[i] mod scalar;
      fi;
    od;
    if not IsMutable( list ) and not IsMutable( scalar ) then
      result:= Immutable( result );
    fi;
    return result;
    end );

BindGlobal( "MOD_SCL_LIST_DEFAULT", function( scalar, list )
    local result, i;

    result:= [];
    for i in [ 1 .. Length( list ) ] do
      if IsBound( list[i] ) then
        result[i]:= scalar mod list[i];
      fi;
    od;
    if not IsMutable( list ) and not IsMutable( scalar ) then
      result:= Immutable( result );
    fi;
    return result;
    end );

BindGlobal( "MOD_LIST_LIST_DEFAULT", function( left, right )
    local result, i;

    result:= [];
    for i in [ 1 .. Maximum( Length( left ), Length( right ) ) ] do
      if IsBound( left[i] ) then
        if IsBound( right[i] ) then
          result[i]:= left[i] mod right[i];
        elif IsCopyable( left[i] ) then
          result[i]:= ShallowCopy( left[i] );
        else
          result[i]:= left[i];
        fi;
      elif IsBound( right[i] ) then
        if IsCopyable( right[i] ) then
          result[i]:= ShallowCopy( right[i] );
        else
          result[i]:= right[i];
        fi;
      fi;
    od;
    if not IsMutable( left ) and not IsMutable( right ) then
      result:= Immutable( result );
    fi;
    return result;
    end );


#############################################################################
##
#M  <grv> mod <nonlist>  . . . . . . . . .  for small list in `IsListDefault'
#M  <nonlist> mod <grv>  . . . . . . . . .  for small list in `IsListDefault'
##
##  Default methods are installed only for small lists in `IsListDefault'.
##  For those lists,
##  the result of `mod' with a non-list is defined pointwise.
##
InstallOtherMethod( \mod,
    [ IsListDefault and IsSmallList, IsObject ],
    function( list, nonlist )
    if IsList( nonlist ) then
      TryNextMethod();
    else
      return MOD_LIST_SCL_DEFAULT( list, nonlist );
    fi;
    end );

InstallOtherMethod( \mod,
    [ IsObject, IsListDefault and IsSmallList ],
    function( nonlist, list )
    if IsList( nonlist ) then
      TryNextMethod();
    else
      return MOD_SCL_LIST_DEFAULT( nonlist, list );
    fi;
    end );


#############################################################################
##
#M  <list1> mod <list2>  . . . . . . . for two small lists in `IsListDefault'
##
##  A default method is installed only for two small lists in
##  `IsListDefault'.
##  For those lists, `mod' is defined depending on the multiplicative nesting
##  depth.
##
InstallOtherMethod( \mod,
    [ IsListDefault and IsSmallList, IsListDefault and IsSmallList ],
    function( left, right )
    local depth1, depth2;

    depth1:= NestingDepthM( left );
    depth2:= NestingDepthM( right );
    if depth1 = depth2 then
      return MOD_LIST_LIST_DEFAULT( left, right );
    elif depth1 < depth2 then
      return MOD_SCL_LIST_DEFAULT( left, right );
    else
      return MOD_LIST_SCL_DEFAULT( left, right );
    fi;
    end );


#############################################################################
##
#M  LeftQuotient( <obj1>, <obj2> )
##
##  For two {\GAP} objects $x$ and $y$ of which one is in
##  `IsMultiplicativeGeneralizedRowVector' and the other is either not a list
##  or is also in `IsMultiplicativeGeneralizedRowVector',
##  $`LeftQuotient'( x, y )$ is defined as $x^{-1} y$.
##  For this case, we install a default method that relies on `Inverse' and
##  `\*'.
##
InstallOtherMethod( LeftQuotient,
    [ IsMultiplicativeGeneralizedRowVector,
      IsMultiplicativeGeneralizedRowVector ],
    function( grv1, grv2 )
    return grv1^(-1) * grv2;
    end );

InstallOtherMethod( LeftQuotient,
    [ IsMultiplicativeGeneralizedRowVector, IsObject ],
    function( grv, nonlist )
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    return grv^(-1) * nonlist;
    end );

InstallOtherMethod( LeftQuotient,
    [ IsObject, IsMultiplicativeGeneralizedRowVector ],
    function( nonlist, grv )
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    return nonlist^(-1) * grv;
    end );


#############################################################################
##
##  (end of the list arithmetic stuff)
##


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
InstallGlobalFunction( UnionBlist, function( arg )
local   union,  blist,blists;
if Length(arg)=1 and not IsBlist(arg[1]) then
      blists:=arg[1];
    else
      blists:=arg;
    fi;

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
InstallGlobalFunction( IntersectionBlist, function( arg )
local   intersection,  blist,blists;
    if Length(arg)=1 and not IsBlist(arg[1]) then
      blists:=arg[1];
    else
      blists:=arg;
    fi;

    # make a list with all bits set.
    intersection:=BlistList([1..Length(blists[1])],[1..Length(blists[1])]);
    for blist  in blists  do
        IntersectBlist( intersection, blist );
    od;
    return intersection;
end );


#############################################################################
##
#F  ListWithIdenticalEntries( <n>, <obj> )
##
InstallGlobalFunction( ListWithIdenticalEntries,
LIST_WITH_IDENTICAL_ENTRIES );


#############################################################################
##
#M  ViewObj( <list> ) . . . . . . . . . . . . . . . . .  view the sub-objects
##
##  This is  a very naive  method which will view   the sub-objects. A better
##  method is needed eventually looking out for long list or homogeneous list
##  or dense list, etc.
##
##  The line break hints are consistent with those
##  that appear in the kernel function 'PrintListDefault'
##  and in the 'ViewString' method for finite lists.
##
InstallMethod( ViewObj,
    "for a finite list",
    [ IsList and IsFinite ],
    {} -> RankFilter(IsList) + 1 - RankFilter(IsList and IsFinite),
function( list )
    local   i;

    if 0 = Length(list) and IsInternalRep(list)  then
        PrintObj( list );
    elif 0 < Length(list) and IsString(list)  then
        View(list); # there is a special method for strings
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
    "for a range",
    [ IsList and IsFinite and IsRange ],
    function( list )
    Print( "[ " );
    if   Length( list ) = 1 then
      Print( list[1] );
    elif Length( list ) = 2 then
      Print( list[1], ", ", list[2] );
    elif 2 < Length( list ) then
      if list[2] - list[1] <> 1  then
        Print( list[1], ", ", list[2], " .. ", list[ Length( list ) ] );
      else
        Print( list[1], " .. ", list[ Length( list ) ] );
      fi;
    fi;
    Print( " ]" );
    end );

#############################################################################
##
#M  PositionNot( <list>, <obj>, <from-minus-one> ) . . . . . . default method
#M  PositionNot( <list>, <obj> ) . . . . . . default method, defers to above
##
##
InstallMethod( PositionNot, "default method ", [IsList, IsObject, IsInt ],
        POSITION_NOT);

InstallOtherMethod( PositionNot, "default value of third argument ",
        [IsList, IsObject],
        function(l,x)
    return POSITION_NOT(l,x,0);
end
  );

InstallMethod( PositionNonZero, "default method", [IsHomogeneousList],
        function(l)
    if Length(l) = 0 then
        return 1;
    else
        return POSITION_NOT(l, Zero(l[1]), 0);
    fi;
end);

InstallMethod( PositionNonZero, "default method with start", [IsHomogeneousList, IsInt ],
        function(l,from)
    if Length(l) = 0 then
        return from+1;
    fi;
    return POSITION_NOT(l, Zero(l[1]), from);
end);


#############################################################################
##
#M  CanEasilyCompareElements( <obj> )
##
InstallMethod(CanEasilyCompareElements,"homogeneous list",
  [IsHomogeneousList],
function(l)
  return Length(l)=0 or CanEasilyCompareElements(l[1]);
end);

InstallTrueMethod(CanEasilyCompareElements, IsHomogeneousList and IsEmpty);

#############################################################################
##
#M  CanEasilySortElements( <obj> )
##
InstallMethod(CanEasilySortElements,"homogeneous list",
  [IsHomogeneousList],
function(l)
  return Length(l)=0 or CanEasilySortElements(l[1]);
end);

InstallTrueMethod(CanEasilySortElements, IsHomogeneousList and IsEmpty);

#############################################################################
##
#M  Elements( <coll> )
##
##  for gap3 compatibility. Because `InfoWarning' is not available
##  immediately this is not in coll.gi, but in the later read list.gi
##
InstallGlobalFunction(Elements,function(coll)
  Info(InfoPerformance,2,
    "`Elements' is an outdated synonym for `AsSSortedList'");
  Info(InfoPerformance,2,
    "If sortedness is not required, `AsList' might be much faster!");
  return AsSSortedList(coll);
end);



#############################################################################
##
#M  IsRectangularTable( <obj> )
##
InstallMethod( IsRectangularTable, "kernel method for a plain list",
        [IsTable and IsPlistRep],
        IsRectangularTablePlist);

InstallMethod( IsRectangularTable, "generic",
    [ IsList ],
        function(l)
    local len, i, lenl;
    if not IsTable( l ) then
      return false;
    fi;
    lenl := Length(l);
    if lenl = 1 then
        return true;
    fi;
    len := Length(l[1]);
    for i in [2..lenl] do
        if Length(l[i]) <> len then
            return false;
        fi;
    od;
    return true;
end);

#
# Stuff for better storage of blists (trans grp. library)
#

BLISTNIBBLES:=MakeImmutable([
  [   true,   true,   true,   true ],
  [   true,   true,   true,  false ],
  [   true,   true,  false,   true ],
  [   true,   true,  false,  false ],
  [   true,  false,   true,   true ],
  [   true,  false,   true,  false ],
  [   true,  false,  false,   true ],
  [   true,  false,  false,  false ],
  [  false,   true,   true,   true ],
  [  false,   true,   true,  false ],
  [  false,   true,  false,   true ],
  [  false,   true,  false,  false ],
  [  false,  false,   true,   true ],
  [  false,  false,   true,  false ],
  [  false,  false,  false,   true ],
  [  false,  false,  false,  false ],
]);
BLISTZERO:=MakeImmutable(BlistList([1..8],[]));
HEXNIBBLES:=MakeImmutable("0123456789ABCDEF");

BindGlobal( "DECODE_BITS_TO_HEX", function(b,i)
local v;
  v:=0;
  if b[i+0] then v:=v+8; fi;
  if b[i+1] then v:=v+4; fi;
  if b[i+2] then v:=v+2; fi;
  if b[i+3] then v:=v+1; fi;
  return HEXNIBBLES[v+1];
end );

InstallGlobalFunction(HexStringBlist,function(b)
local i,n,s;
  n:=Length(b);
  i:=1;
  s:="";
  while i+3<=n do
    Add(s,DECODE_BITS_TO_HEX(b,i));
    i:=i+4;
  od;
  if i <= n then
    b:=b{[i..n]};
    while Length(b)<4 do
      Add(b,false);
    od;
    Add(s,DECODE_BITS_TO_HEX(b,1));
  fi;
  if IsOddInt(Length(s)) then Add(s,'0'); fi;
  return s;
end);

InstallGlobalFunction(HexStringBlistEncode,function(b)
local i,n,s,t,u,zero;
  zero:="00";
  n:=Length(b);
  i:=1;
  s:="";
  u:=0;
  while i+7<=n do
    t:="";
    Add(t,DECODE_BITS_TO_HEX(b,i));
    Add(t,DECODE_BITS_TO_HEX(b,i+4));
    if t<>zero then
      if u>0 then
        if u=1 then
          Append(s,zero);
        else
          Add(s,'s');
          Append(s,HexStringInt(256+u){[2,3]});
        fi;
        u:=0;
      fi;
      Append(s,t);
    else
      u:=u+1;
      if u=255 then
        Add(s,'s');
        Append(s,HexStringInt(256+u){[2,3]});
        u:=0;
      fi;
    fi;
    i:=i+8;
  od;
  b:=b{[i..n]};
  while Length(b)<8 do
    Add(b,false);
  od;
  t:="";
  Add(t,DECODE_BITS_TO_HEX(b,1));
  Add(t,DECODE_BITS_TO_HEX(b,5));
  if t<>zero then
    if u>0 then
      if u=1 then
        Append(s,zero);
      else
        Add(s,'s');
        Append(s,HexStringInt(256+u){[2,3]});
      fi;
      u:=0;
    fi;
    Append(s,t);
  fi;
  return s;
end);

InstallGlobalFunction(BlistStringDecode,function(arg)
local s,b,i,j,l;
  s:=arg[1];
  b:=[];
  i:=1;
  while i<=Length(s) do
    if s[i]='s' then
      for j in [1..IntHexString(s{[i+1,i+2]})] do
        Append(b,BLISTZERO);
      od;
      i:=i+3;
    else
      l:=IntHexString(s{[i]});
      Append(b,BLISTNIBBLES[16-l]);
      l:=IntHexString(s{[i+1]});
      Append(b,BLISTNIBBLES[16-l]);
      i:=i+2;
    fi;
  od;
  if Length(arg)>1 then
    l:=arg[2];
    while Length(b)<l do
      Append(b,BLISTZERO);
    od;
    if Length(b)>l then
      b:=b{[1..l]};
    fi;
  fi;
  IsBlist(b);
  return b;
end);

InstallMethod(IntersectSet,
        "for two ranges",
        [IsRange and IsRangeRep and IsMutable,
         IsRange and IsRangeRep ],
        INTER_RANGE);

InstallGlobalFunction(Average,l->1/Length(l)*Sum(l));

InstallGlobalFunction(Median,
function(l)
  l:=ShallowCopy(l);
  Sort(l);
  return l[Int((Length(l)+1)/2)];
end);

InstallGlobalFunction(Variance,
function(l)
    local avg;
    avg := Average(l);
    return Average(List(l, x -> (x-avg)^2));
end);
