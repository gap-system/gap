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
    [ IsList and IsEmpty, IsList ], 
    SUM_FLAGS, #can't do better
    function( empty, list )
    return IsEmpty( list );
    end );


InstallMethod( EQ,
    "for two lists, the second being empty",
    true,
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
    [ IsList and HasLength, IsList and HasLength ], 0,
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
    [ IsList, IsList], 0,
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
      
        #
        # Now we've found an unbound spot on both lists
        # maybe we know enough to stop now
      # anyway at this stage we really must check the Lengths and hope
      # that they are computable now.
      
      if Length(list1) <= i then
          return Length(list2) <= i;
      elif Length(list2) <= i then
          return false;
      fi;
  od;
end);



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

InstallMethod( IN,
    "for wrong family relation",
    IsNotElmsColls,
    [ IsObject, IsCollection ], 
    SUM_FLAGS, # can't do better
    ReturnFalse );

InstallMethod( IN,
    "for an object, and a small list",
    true,
    [ IsObject, IsList and IsSmallList ], 0,
    IN_LIST_DEFAULT );

InstallMethod( IN,
    "for an object, and a list",
    true,
    [ IsObject, IsList ], 0,
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
    RETURN_TRUE );

#############################################################################
##
#M  Display( <list> )
##
InstallMethod( Display, "for a (finite) list", true, [ IsList ], 0,
function ( list )
  Print(list,"\n");
end);

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

InstallOtherMethod(RepresentativeSmallest,"for a list",true,[IsList],0,
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
#M  IsSmallList( <non-list> )
##
InstallOtherMethod( IsSmallList,
    "for a non-list",
    true,
    [ IsObject ], 0,
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
    [ IsList and IsConstantTimeAccessList ], 
    SUM_FLAGS, # cant't do better
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
#M  AsPlist( <list> )
##
InstallOtherMethod( AsPlist, "for a plist", true, [IsList and IsPlistRep], 0,
  x->x);

InstallOtherMethod( AsPlist, "for a list", true, [ IsList ], 0,
function(l)
  l:=AsList(l);
  if not IsPlistRep(l) then
    l:=List([1..Length(l)],i->l[i]); # explicit copy for objects that claim to
    # be constant time access but not plists.
  fi;
  return l;
end);

#############################################################################
##
#M  AsSSortedList( <list> )
##
##  If <list> is a (not necessarily dense) list whose elements lie in the
##  same family then 'AsSSortedList' is applicable.
##
InstallOtherMethod( AsSSortedList,
    "for a list",
    true,
    [ IsList ],
    0,
    list -> ConstantTimeAccessList( EnumeratorSorted( list ) ) );

InstallOtherMethod(AsSSortedList,"for a plist",true,[IsList and IsPlistRep],0,
    AsSSortedListList );

InstallOtherMethod(AsSSortedList, "for a list", true, [ IsList ], 0,
  l->AsSSortedListList(AsPlist(l)));

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
InstallOtherMethod(EnumeratorSorted,"for a plist",true,
  [IsList and IsPlistRep],0, 
function(l)
	if IsSSortedList(l) then
		return l;
	fi;
	return AsSSortedListList(l);
end);

InstallOtherMethod( EnumeratorSorted, "for a list", true, [ IsList ], 0,
function(l)
	if IsSSortedList(l) then
		return l;
	fi;
	return AsSSortedListList(AsPlist(l));
end);


#############################################################################
##
#M  ListOp( <list> )
#M  ListOp( <list>, <func> )
##
InstallMethod( ListOp,
    "for a list",
    true,
    [ IsList ], 0,
    ShallowCopy );

InstallMethod( ListOp,
    "for a dense list",
    true,
    [ IsList and IsDenseList ], 0,
    list -> list{ [ 1 .. Length( list ) ] } );

InstallMethod( ListOp,
    "for a dense list, and a function",
    true, [ IsDenseList, IsFunction ], 0,
    function ( list, func )
    local   res, i;
    res := [];
    for i  in [ 1 .. Length( list ) ] do
        res[i] := func( list[i] );
    od;
    return res;
    end );
    
InstallMethod( ListOp,
    "for any list, and a function",
    true, [ IsList, IsFunction ], 0,
    function ( list, func )
    local   res, i;
    res := [];
    for i  in [ 1 .. Length( list ) ] do
        if IsBound(list[i]) then
            Add(res,func( list[i] ));
        fi;
    od;
    return res;
end );


#############################################################################
##
#M  SSortedList( <list> )  . . . . . . . . . . . set of the elements of a list
##
InstallOtherMethod( SSortedList, "for a plist",
    true, [ IsList and IsPlistRep ], 0,
    SSortedListList );

InstallOtherMethod( SSortedList, "for a list",
    true, [ IsList ], 0,
    l->SSortedListList(AsPlist(l)) );


#############################################################################
##
#M  SSortedList( <list>, <func> )
##
InstallOtherMethod( SSortedList,
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
#R  IsListIteratorRep( <iter> )
#R  IsDenseListIteratorRep( <iter> )
##
##  are representations for iterators constructed from lists,
##  which store the underlying list in the component `list'
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
DeclareRepresentation( "IsListIteratorRep", IsComponentObjectRep,
    [ "pos", "list" ] );

DeclareRepresentation( "IsDenseListIteratorRep", IsListIteratorRep, [] );


InstallMethod( IsDoneIterator,
    "for a list iterator",
    true,
    [ IsIterator and IsListIteratorRep ], 0,
    iter -> (iter!.pos = Length( iter!.list )) );

InstallMethod( NextIterator,
    "for a list iterator",
    true,
    [ IsIterator and IsMutable and IsListIteratorRep ], 0,
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


InstallMethod( IsDoneIterator,
    "for a dense list iterator",
    true,
    [ IsIterator and IsDenseListIteratorRep ], 0,
    iter -> not IsBound( iter!.list[ iter!.pos + 1 ] ) );

InstallMethod( NextIterator,
    "for a dense list iterator",
    true,
    [ IsIterator and IsMutable and IsDenseListIteratorRep ], 0,
    function ( iter )
    iter!.pos := iter!.pos + 1;
    if not IsBound( iter!.list[ iter!.pos ] ) then
        Error("<iter> is exhausted");
    fi;
    return iter!.list[ iter!.pos ];
    end );


InstallMethod( ShallowCopy,
    "for a list iterator",
    true,
    [ IsIterator and IsListIteratorRep ], 0,
    iter -> Objectify( Subtype( TypeObj( iter ), IsMutable ),
                rec( list := iter!.list,
                     pos  := iter!.pos ) ) );

InstallGlobalFunction( IteratorList, function ( list )
    local   iter;
    iter := rec(
        list := list,
        pos  := 0
    );

    if IsDenseList( list ) and not IsMutable( list ) then
        
        return Objectify( NewType( IteratorsFamily,
                                 IsMutable and IsDenseListIteratorRep ),
                        iter );
    else
      return Objectify( NewType( IteratorsFamily,
                                 IsMutable and IsListIteratorRep ),
                        iter );
    fi;
end );

#############################################################################
##
#M  Iterator( <list> )
##
InstallOtherMethod( Iterator,
    "for a list",
    true,
    [ IsList ], 0,
    IteratorList );


#############################################################################
##
#M  IteratorSorted( <list> )
##
InstallOtherMethod( IteratorSorted,
    "for a list",
    true,
    [ IsList ], 0,
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
##  `ELMS_LIST_DEFAULT' applies `LEN_LIST' to both of its arguments,
##  so its use is restricted to small lists.
##
##  `ASSS_LIST_DEFAULT' tries to change its first argument into a plain list,
##  and applies `LEN_LIST' to the other two arguments,
##  so also the usage of `ASSS_LIST_DEFAULT' is restricted to small lists.
##
InstallMethod( ELMS_LIST,
    "for a small list and a small dense list",
    true,
    [ IsList and IsSmallList, IsDenseList and IsSmallList ], 0,
    ELMS_LIST_DEFAULT );

InstallMethod( ELMS_LIST,
    "for a list and a dense list",
    true,
    [ IsList, IsDenseList ], 0,
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
    true,
    [ IsList and IsSmallList and IsMutable, IsDenseList and IsSmallList,
      IsList and IsSmallList ], 0,
    ASSS_LIST_DEFAULT );

InstallMethod( ASSS_LIST,
    "for a mutable list, a dense list, and a list",
    true,
    [ IsList and IsMutable, IsDenseList, IsList ], 0,
    function( list, poslist, vallist )
    local i;
    if IsSmallList( poslist ) and IsSmallList( vallist ) then
      if IsSmallList( list ) then
        return ASSS_LIST_DEFAULT( list, poslist, vallist );
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
        true,
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
   true,
   [ IsObject ], 0,
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
    "for a small homogeneous list",
    true,
    [ IsHomogeneousList and IsSmallList ], 0,
    IS_SSORT_LIST_DEFAULT );

InstallMethod( IsSSortedList,
    "for a homogeneous list (not nec. finite)",
    true,
    [ IsHomogeneousList ], 0,
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
InstallMethod( IsSortedList, "for a finite list", true,
    [ IsList and IsFinite ], 0,
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

InstallMethod( IsSortedList, "for a list (not nec. finite)", true,
    [ IsList ], 0,
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
   true,
   [ IsObject ], 0,
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
    true,
    [ IsList ], 0,
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
        true,
        [IsHomogeneousList, IsHomogeneousList], 0,
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
#M  IsPositionsList( <non-list> )
##
InstallOtherMethod( IsPositionsList,
   "for non-lists",
   true,
   [ IsObject ], 0,
   function( nonlist )
   if IsList( nonlist ) then
     TryNextMethod();
   else
     return false;
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

InstallMethod( Position,
    "for a small sorted list, an object, and an integer",
    true,
    [ IsSSortedList and IsSmallList, IsObject, IsInt ], 0,
    function ( list, obj, start )
    local   pos;

#N  1996/08/14 M.Schoenert 'POSITION_SORTED_LIST' should take 3 arguments
    if start = 0 then  pos := POSITION_SORTED_LIST( list, obj );
                 else  pos := POS_LIST_DEFAULT( list, obj, start );  fi;
    # `PositionSorted' will not return fail. Therefore we have to test
    # explicitly once it had been called.
    if pos = 0  or (start=0 and (pos>Length(list) or list[pos]<>obj))
      then return fail;
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
      # `PositionSorted' will not return fail. Therefore we have to test
      # explicitly once it had been called.
      if pos = 0  or (start=0 and (pos>Length(list) or list[pos]<>obj))
                  then  return fail;
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
#M  PositionCanonical( <list>, <obj> )  . .  for internally represented lists
##
InstallMethod( PositionCanonical,
    "for internally represented lists, fall back on `Position'",
    true, # the list may be non-homogeneous.
    [ IsList and IsInternalRep, IsObject ], 0,
    function( list, obj )
    return Position( list, obj, 0 );
end );

InstallMethod( PositionCanonical,
    "for internally represented small sorted lists, fall back on `Position'",
    true, # the list may be non-homogeneous.
    [ IsList and IsInternalRep and IsSSortedList and IsSmallList, IsObject ], 0,
    POSITION_SORTED_LIST);

#############################################################################
##
#M  PositionNthOccurrence( <list>, <obj>, <n> ) . . call `Position' <n> times
##
InstallMethod( PositionNthOccurrence,
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
#M  PositionNthOccurrence( <blist>, <bool>, <n> )  kernel function for blists
##
InstallMethod( PositionNthOccurrence,
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
    "for small list, and object",
    true,
    [ IsList and IsSmallList, IsObject ], 0,
    POSITION_SORTED_LIST );

InstallMethod( PositionSorted,
    "for list, and object",
    true,
    [ IsList, IsObject ], 0,
    function( list, elm )
    if IsSmallList( list ) then
      return POSITION_SORTED_LIST( list, elm );
    else
      TryNextMethod();
    fi;
    end );

InstallOtherMethod( PositionSorted,
    "for small list, object, and function",
    true,
    [ IsList and IsSmallList, IsObject, IsFunction ], 0,
    POSITION_SORTED_LIST_COMP );

InstallOtherMethod( PositionSorted,
    "for list, object, and function",
    true,
    [ IsList, IsObject, IsFunction ], 0,
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
#M  PositionSublist( <list>,<sub>[,<ind>] )
##
InstallMethod( PositionSublist,"list,sub,pos",IsFamFamX,
  [IsList,IsList,IS_INT], 0,
function( list,sub,start )
local m,n,i,j,next;

  # string-match algorithm, cf. Manber, section 6.7

  n:=Length(list);
  m:=Length(sub);
  # compute the next entries
  next:=[-1,0];
  for i in [3..m] do
    j:=next[i-1]+1;
    while j>0 and sub[i-1]<>sub[j] do
      j:=next[j]+1;
    od;
    next[i]:=j;
  od;

  i:=Maximum(1,start+1); # to catch index 0
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
InstallOtherMethod( PositionSublist,"list, sub",true,
  [IsObject,IsObject], 0,
function( list,sub )
  return PositionSublist(list,sub,0);
end);

InstallOtherMethod( PositionSublist,"empty list,sub,pos",true,
  [IsEmpty,IsList,IS_INT], 0, ReturnFail);

InstallOtherMethod( PositionSublist,"list,empty,pos",true,
  [IsList,IsEmpty,IS_INT], 0,
function(a,b,c)
  return Maximum(c+1,1);
end);


#############################################################################
##
#M  IsMatchingSublist( <list>,<sub>[,<ind>] )
##
InstallMethod( IsMatchingSublist,"list,sub,pos",IsFamFamX,
  [IsList,IsList,IS_INT], 0,
function( list,sub,first )
local last;

  last:=first+Length(sub)-1;
  return Length(list) >= last and list{[first..last]} = sub;
end);

# no installation restrictions to avoid extra installations for empty list
InstallOtherMethod( IsMatchingSublist,"list, sub",true,
  [IsObject,IsObject], 0,
function( list,sub )
  return IsMatchingSublist(list,sub,1);
end);

InstallOtherMethod( IsMatchingSublist,"empty list,sub,pos",true,
  [IsEmpty,IsList,IS_INT], 0, 
function(list,sub,first )
  return not IsEmpty(sub);
end);

InstallOtherMethod( IsMatchingSublist,"list,empty,pos",true,
  [IsList,IsEmpty,IS_INT], 0, ReturnTrue);


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
end;

InstallMethod( Append,
    "for mutable list and list",
    true,
    [ IsList and IsMutable , IsList ],
    0,
    APPEND_LIST_DEFAULT );


InstallMethod( Append,
    "for mutable list in plist representation and list",
    true,
    [ IsList and IsPlistRep and IsMutable, IsList  ],
    0,
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
    res := ShallowCopy( arg[1] );
    for i  in [ 2 .. Length( arg ) ]  do
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
#F  Reversed( <list> )  . . . . . . . . . . .  reverse the elements in a list
##
##  Note that the special case that <list> is a range is dealt with by the
##  `{}' implementation, we need not introduce a special treatment for this.
##
InstallGlobalFunction( Reversed,
    function( list )
    local tnum, len;
    tnum:= TNUM_OBJ_INT( list );
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
#F  SORT_MUTABILITY_ERROR_HANDLER( <list> )
#F  SORT_MUTABILITY_ERROR_HANDLER( <list>, <func> )
#F  SORT_MUTABILITY_ERROR_HANDLER( <list1>, <list2> )
##
##  This function will be installed as method for `Sort', `Sortex' and
##  `SortParallel', for the sake of a more gentle error message.
##
BindGlobal( "SORT_MUTABILITY_ERROR_HANDLER", function( arg )
  if    ( Length( arg ) = 1 and IsMutable( arg[1] ) )
     or ( Length( arg ) = 2 and IsMutable( arg[1] )
            and ( IsFunction( arg[2] ) or IsMutable( arg[2] ) ) ) then
    TryNextMethod();
  fi;
  Error( "immutable lists cannot be sorted" );
end );

InstallOtherMethod( Sort,
    "for an immutable list",
    true,
    [ IsList ], 0,
    SORT_MUTABILITY_ERROR_HANDLER );

InstallOtherMethod( Sort,
    "for an immutable list and a function",
    true,
    [ IsList, IsFunction ], 0,
    SORT_MUTABILITY_ERROR_HANDLER );


#############################################################################
##
#F  IsLexicographicallyLess( <list1>, <list2> )
##
InstallGlobalFunction( IsLexicographicallyLess, function( list1, list2 )
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
#M  Sortex( <list> ) . . sort a list (stable), return the applied permutation
##
InstallMethod( Sortex, "for a mutable list", true,
    [ IsList and IsMutable ], 0,
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


InstallOtherMethod( Sortex,
    "for an immutable list",
    true,
    [ IsList ], 0,
    SORT_MUTABILITY_ERROR_HANDLER );

InstallOtherMethod( Sortex,
    "for an immutable list and a function",
    true,
    [ IsList, IsFunction ], 0,
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
UseKernelSort := true;
InstallMethod( SortParallel,
    "for two dense and mutable lists",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList and IsMutable ],
    0,
    function ( list, para )
    local l, both, i;

    ##
    ##  The following code will go after a period of tests.
    ##
    if UseKernelSort then
        SORT_PARA_LIST( list, para );
        return;
    fi;

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

    if UseKernelSort then
        SORT_PARA_LIST_COMP( list, para, isLess );
        return;
    fi;

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


InstallOtherMethod( SortParallel,"for two immutable lists",
  true,[IsList,IsList],0,
  SORT_MUTABILITY_ERROR_HANDLER);
InstallOtherMethod( SortParallel,"for two immutable lists and function",
  true, [IsList,IsList,IsFunction],0,
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
InstallMethod( MaximumList, "for a list", true,
    [ IsList ], 0,
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

InstallMethod( MaximumList,"for a sorted list",true, [ IsSSortedList ], 0,
function ( l )
local min;
  if Length( l ) = 0 then
      Error( "MaximumList: <list> must contain at least one element" );
  fi;
  return l[Length(l)];
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
InstallMethod( MinimumList, "for a list", true,
    [ IsList ], 0,
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

InstallMethod( MinimumList,"for a sorted list",true, [ IsSSortedList ], 0,
function ( l )
local min;
  if Length( l ) = 0 then
      Error( "MinimumList: <list> must contain at least one element" );
  fi;
  return l[1];
end );


#############################################################################
##
#F  Cartesian( <list1>, <list2> ... )
#F  Cartesian( <list> )
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
MakeReadOnlyGlobal( "Cartesian2" );

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
    tnum:= TNUM_OBJ_INT( C );
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
    "for a list or collection and a function",
    true,
    [ IsListOrCollection, IsFunction ], 0,
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
    true,
    [ IsDenseList, IsPosInt ], 0,
    function( list, index )
    return index <= Length( list );
    end );


#############################################################################
##
#M  ZeroOp( <list> ) . . . . . . . . . for internal list of add-elm-with-zero
#M  ZeroOp( <list> ) . . . . . . . . . . . . . . . . . . . . . for dense list
##
##  For any dense list, `Zero' is defined pointwise.
##  (If the lists are inhomogeneous then strange things may happen,
##  for example `Zero( <l1> + <l2> )' is in general different from
##  `Zero( <l1> ) + Zero( <l2> )'.)
##
##  Note that for non-internal lists, it may be unwanted that the zero is
##  allowed to be an internal list.
##
InstallMethod( ZeroOp,
    "for internal additive-element-with-zero list",
    true,
    [ IsAdditiveElementWithZeroList and IsListDefault ], 0,
    ZERO_LIST_DEFAULT );

InstallOtherMethod( ZeroOp,
    "for any dense and small list",   
    true,
    [ IsDenseList and IsSmallList ], 0,
    list -> List( list, ZeroOp ) );

InstallOtherMethod( ZeroOp,
    "for any dense list (see if it's small)",   
    true,
    [ IsDenseList ], 0,
    function(l)
      if IsSmallList(l) then
    return List(l, ZeroOp);
    else
      TryNextMethod();
     fi; end	);

     
     
#############################################################################
##
#M  AdditiveInverseOp( <list> )  . . . for internal list of add-elm-with-inv.
##
##  For any dense list, `AdditiveInverse' is defined pointwise.
##
##  Note that for non-internal lists, it may be unwanted that the inverse is
##  allowed to be an internal list.
##
InstallMethod( AdditiveInverseOp,
    "for internal additive-element-with-inverse list",
    true,
    [ IsAdditiveElementWithInverseList and IsListDefault ], 0,
    AINV_LIST_DEFAULT );

InstallOtherMethod( AdditiveInverseOp,
    "for any dense and small list",   
    true,
    [ IsDenseList and IsSmallList ], 0,
    AINV_LIST_DEFAULT);

InstallOtherMethod( AdditiveInverseOp,
    "for any dense list (see if it's small)",   
    true,
    [ IsDenseList ], 0,
    function(l)
      if IsSmallList(l) then
    return AINV_LIST_DEFAULT(l);
    else
      TryNextMethod();
     fi; end	);


#############################################################################
##
#M  <elm> - <list>
#M  <list> - <elm>
#M  <elm> - <table>
#M  <table> - <elm>
##
##  If <list> is a list and <elm> is an object that is *not* a list then
##  the difference `<elm> - <list>' and the difference `<list> - <elm>' are
##  defined as lists with entry `<elm> - <list>[$i$]' resp.
##  `<list>[$i$] - <elm>' at $i$-th position.
##  The result is mutable if and only if <list> is mutable.
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
    if not IsMutable( list ) then
      MakeImmutable( diff );
    fi;
    return diff;
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
    if not IsMutable( list ) then
      MakeImmutable( diff );
    fi;
    return diff;
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
    [ IsList and IsListDefault, IsList and IsListDefault ], 0,
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
    [ IsAdditiveElementWithInverseList and IsListDefault,
      IsAdditiveElementWithInverseList and IsListDefault ], 0,
    DIFF_LIST_LIST_DEFAULT );


#############################################################################
##
#M  OneOp( <matrix> ) . . . . . . . . . . . . . . . .  for an ordinary matrix
##
##  Note that the standard method applies only to ordinary matrices.
##  (All internally represented matrices are ordinary.)
##
InstallOtherMethod( OneOp,
    "default for small ordinary matrix",
    true,
    [ IsOrdinaryMatrix and IsSmallList ], 0,
    ONE_MATRIX );

InstallOtherMethod( OneOp,
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
#M  InverseOp( <matrix> ) . . . . . . . . . . . . . .  for an ordinary matrix
##
##  Note that the standard method applies only to ordinary matrices.
##  (All internally represented matrices are ordinary.)
##
##  The INV_MAT_DEFAULT methods are faster for lists of FFEs because they
##  use AddRowVector, etc.
##
    
InstallOtherMethod( InverseOp,
    "default for small matrix whose rows are vectors of FFEs",
    true,
    [ IsOrdinaryMatrix and IsSmallList and
      IsCommutativeElementCollColl and IsRingElementTable and
      IsFFECollColl ], 0,
    INV_MAT_DEFAULT );

InstallOtherMethod( InverseOp,
    "default for ordinary matrix whose rows are vectors of FFEs",
    true,
    [ IsOrdinaryMatrix and IsCommutativeElementCollColl and IsRingElementTable 
          and IsFFECollColl], 0,
    function( mat )
    if IsSmallList( mat ) then
      return INV_MAT_DEFAULT( mat );
    else
      TryNextMethod();
    fi;
    end );

    
InstallOtherMethod( InverseOp,
    "default for small ordinary matrix",
    true,
    [ IsOrdinaryMatrix and IsSmallList and IsZDFRECollColl], 0,
    INV_MATRIX );

InstallOtherMethod( InverseOp,
    "default for ordinary matrix",
    true,
    [ IsOrdinaryMatrix and IsZDFRECollColl ], 0,
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
##  list with entry `<elm> + <list>[$i$]' at $i$-th position.
##  The result is mutable if and only if <list> is mutable.
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
        sum[i]:= list[i] + nonlist;
      fi;
    od;
    if not IsMutable( list ) then
      sum:= Immutable( sum );
    fi;
    return sum;
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
    if not IsMutable( list ) then
      sum:= Immutable( sum );
    fi;
    return sum;
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
    [ IsList and IsListDefault, IsList and IsListDefault ], 0,
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
    [ IsDenseList and IsListDefault,
      IsDenseList and IsListDefault ], 0,
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
##  as list with entry `<elm> * <list>[$i$]' resp.
##  `<list>[$i$] * <elm>' at $i$-th position.
##  The result is mutable if and only if <list> is mutable.
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
    if not IsMutable( list ) then
      prod:= Immutable( prod );
    fi;
    return prod;
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
    if not IsMutable( list ) then
      prod:= Immutable( prod );
    fi;
    return prod;
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
    [ IsExtRElementList, IsMultiplicativeElement ], 0,
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
##  Note that the above definition does *not* automatically imply the
##  mutability rule that the product of two lists is mutable (if applicable)
##  except if the two operands are immutable.
##  Namely, if <list1> is a list of immutable objects and <list2> is a
##  mutable matrix whose rows are immutable then the sum
##  $\sum_{i=1}^n <list1>[i] * <list2>[i]$ is immutable but the result vector
##  is expected to be mutable.
##
InstallOtherMethod( \*,
    "for dense list of non-lists and dense list",
    true,
    [ IsDenseList, IsDenseList ], 0,
    function( list1, list2 )
    if ForAny( list1, IsList ) then
      TryNextMethod();
    else
      return PROD_LIST_LIST_DEFAULT( list1, list2 );
    fi;
    end );

InstallOtherMethod( \*,
    "for dense internal list of lists and dense list",
    true,
    [ IsDenseList and IsListDefault, IsDenseList ], 0,
    function( list1, list2 )
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
    [ IsRingElementList and IsSmallList and IsListDefault,
      IsRingElementList and IsSmallList and IsListDefault], 0,
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

InstallOtherMethod( \*, "row vector * matrix",
        IsElmsColls,
        [ IsRowVector and IsSmallList and IsCommutativeElementCollection
          and IsRingElementList, IsMatrix and IsRingElementTable
          and IsSmallList], 0,
        PROD_VEC_MAT_DEFAULT);

InstallOtherMethod( \*, "row vector * matrix",
        IsElmsColls,
        [ IsRowVector and IsCommutativeElementCollection and
          IsRingElementList, IsMatrix and IsSmallList ], 0,
       function(v,m)
    if IsSmallList(v) then
        return PROD_VEC_MAT_DEFAULT(v,m);
    else
       TryNextMethod();
   fi;
end);

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
    [ IsRingElementTable and IsListDefault,
      IsRingElementTable and IsListDefault ],
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
#M  <list> mod <elm>
##
##  If <list> is a homogenous list and <elm> is an object of teh same
##  family as the elements of the list then
##  the remainder  '<list> mod <elm>'  is defined
##  as list with entry `<list>[$i$] mod <elm>'  at $i$-th position.
##  The result is mutable if and only if <list> is mutable.
##
InstallMethod( \mod, "for a homog list and a compatible element",
        IsCollsElms, [IsHomogeneousList, IsObject], 0,
        function(l,x)
    return List(l, y-> y mod x);
end);


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
InstallGlobalFunction( ListWithIdenticalEntries, function( n, obj )
    local list, i, c;
    if IsChar(obj) then
      list := "";
    else  
      list:= [];
    fi;
    for i in [ 1 .. n ] do
      list[i]:= obj;
    od;
    return list;
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
#F  ListSorted( <coll> )
#F  AsListSorted(<coll>)
##
##  These operations are obsolete and will vanish in future versions. They
##  are included solely for temporary compatibility with beta releases but
##  should *never* be used. Use `SSortedList' and `AsSSortedList' instead!
ListSorted := function(coll)
  Info(InfoWarning,1,"The command `ListSorted' will *not* be supported in",
        "further versions!");
  return SSortedList(coll);
end;

AsListSorted := function(coll)
  Info(InfoWarning,1,"The command `AsListSorted' will *not* be supported in",
        "further versions!");
  return AsSSortedList(coll);
end;

#############################################################################
##
#M  SetIsSSortedList( <list>, <val> ) . . . . . . . . method for kernel lists
##


InstallMethod( SetIsSSortedList, 
        "method for an internal list and a Boolean", 
        true, 
        [IsList and IsInternalRep, IsBool],
        0,
        function(l,val)        
    if val then   
        SET_FILTER_LIST(l, IS_SSORT_LIST);
    else
        SET_FILTER_LIST(l, IS_NSORT_LIST);
    fi;
end);
        
#############################################################################
##
#F  PlainListCopy( <list> ) . . . . . . . . . . make a plain list copy of
##                                          a list
##
##  This is intended for use in certain rare situations, such as before
##  Objectifying. Normally, ConstantAccessTimeList should be enough
##
##  This function guarantees that the reult will be a plain list, distinct
##  from the input object.
##

InstallGlobalFunction(PlainListCopy, function( list )
    local tnum, copy;
    
    if not IsSmallList( list ) then
        Error("PlainListCopy: argument must be a small list");
    fi;
    
    # This is enough much of the time
    copy := ShallowCopy(list);
    
    # now do a cheap check on copy
    tnum := TNUM_OBJ_INT(copy);
    if FIRST_LIST_TNUM > tnum or LAST_LIST_TNUM < tnum then
        copy := PlainListCopyOp( copy );
    fi;
    Assert(2, not IsIdenticalObj(list,copy));
    Assert(2, TNUM_OBJ_INT(copy) >= FIRST_LIST_TNUM);
    Assert(2, TNUM_OBJ_INT(copy) <= LAST_LIST_TNUM);
    return copy;
end);

#############################################################################
##
#M  PositionNot( <list>, <obj>, <from-minus-one> ) . . . . . . default method
#M  PositionNot( <list>, <obj> ) . . . . . . default method, defers to above
##
##

InstallMethod( PositionNot, "default method ", true, [IsList, IsObject, IsInt ], 0,
        POSITION_NOT);

InstallOtherMethod( PositionNot, "default value of third argument ", 
        true, [IsList, IsObject], 0,
        function(l,x) return PositionNot(l,x,0); end);

#############################################################################
##
#M  CanEasilyCompareElements( <obj> )
##
InstallMethod(CanEasilyCompareElements,"homogeneous list",
  true, [IsHomogeneousList],0,
function(l)
  return Length(l)=0 or CanEasilyCompareElements(l[1]);
end);

InstallMethod(CanEasilyCompareElements,"empty homogeneous list",
  true, [IsHomogeneousList and IsEmpty],0,
function(l)
  return true;
end);

#############################################################################
##
#M  CanEasilySortElements( <obj> )
##
InstallMethod(CanEasilySortElements,"homogeneous list",
  true, [IsHomogeneousList],0,
function(l)
  return Length(l)=0 or CanEasilySortElements(l[1]);
end);

InstallMethod(CanEasilySortElements,"empty homogeneous list",
  true, [IsHomogeneousList and IsEmpty],0,
function(l)
  return true;
end);


#############################################################################
##
#M  Elements( <coll> )
##
##  for gap3 compatibility. Because `InfoWarning' is not availkable
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
InstallMethod( IsRectangularTable, "kernel method for a plain list", true,
        [IsTable and IsPlistRep], 0,
        IsRectangularTablePlist);

InstallMethod( IsRectangularTable, "generic", true,
    [ IsList ], 0, 
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

BLISTBYTES:=[];
HEXBYTES:=[];
BLISTBYTES1:=[];
HEXBYTES1:=[];
BindGlobal("HexBlistSetup",function()
local BLISTFT,BLISTIND;
  if Length(BLISTBYTES)>0 then return;fi;
  BLISTFT:=[false,true];
  for BLISTIND in [0..255] do
    BLISTBYTES[BLISTIND+1]:=
      BLISTFT{1+Reversed(CoefficientsQadic(256+BLISTIND,2){[1..8]})};
    IsBlist(BLISTBYTES[BLISTIND+1]);
    MakeImmutable(BLISTBYTES[BLISTIND+1]);
    HEXBYTES[BLISTIND+1]:=HexStringInt(256+BLISTIND){[2,3]};
    MakeImmutable(HEXBYTES[BLISTIND+1]);
  od;
  SortParallel(BLISTBYTES,HEXBYTES);
  HEXBYTES1:=ShallowCopy(HEXBYTES);
  BLISTBYTES1:=ShallowCopy(BLISTBYTES);
  SortParallel(HEXBYTES1,BLISTBYTES1);
end);

InstallGlobalFunction(HexStringBlist,function(b)
local i,n,s;
  HexBlistSetup();
  n:=Length(b);
  i:=1;
  s:="";
  while i+7<=n do
    Append(s,HEXBYTES[PositionSorted(BLISTBYTES,b{[i..i+7]})]);
    i:=i+8;
  od;
  b:=b{[i..n]};
  while Length(b)<8 do
    Add(b,false);
  od;
  Append(s,HEXBYTES[PositionSorted(BLISTBYTES,b)]);
  return s;
end);

InstallGlobalFunction(HexStringBlistEncode,function(b)
local i,n,s,t,u,zero;
  HexBlistSetup();
  zero:="00";
  n:=Length(b);
  i:=1;
  s:="";
  u:=0;
  while i+7<=n do
    t:=HEXBYTES[PositionSorted(BLISTBYTES,b{[i..i+7]})];
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
  b:=HEXBYTES[PositionSorted(BLISTBYTES,b)];
  if b<>zero then
    if u>0 then
      if u=1 then
	Append(s,zero);
      else
	Add(s,'s');
	Append(s,HexStringInt(256+u){[2,3]});
      fi;
      u:=0;
    fi;
    Append(s,b);
  fi;
  return s;
end);

InstallGlobalFunction(BlistStringDecode,function(arg)
local s,b,i,j,zero,l;
  HexBlistSetup();
  zero:=BLISTBYTES1[PositionSorted(HEXBYTES1,"00")];
  s:=arg[1];
  b:=[];
  i:=1;
  while i<=Length(s) do
    if s[i]='s' then
      for j in [1..IntHexString(s{[i+1,i+2]})] do
        Append(b,zero);
      od;
      i:=i+3;
    else
      Append(b,BLISTBYTES1[PositionSorted(HEXBYTES1,s{[i,i+1]})]);
      i:=i+2;
    fi;
  od;
  if Length(arg)>1 then
    l:=arg[2];
    while Length(b)<l do
      Append(b,zero);
    od;
    if Length(b)>l then
      b:=b{[1..l]};
    fi;
  fi;
  IsBlist(b);
  return b;
end);





#############################################################################
##
#E
##

