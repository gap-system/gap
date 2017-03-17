#############################################################################
##
#W  object.gi                   GAP library                  Martin Schönert
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains some methods applicable to objects in general.
##


#############################################################################
##
#M  '<obj1> = <obj2>' . . . . . . . . . . . for objects in different families
##
InstallMethod( \=,
    "for two objects in different families",
    IsNotIdenticalObj,
    [ IsObject,
      IsObject ],
    0,
    false );


#############################################################################
##
#M  \=( <fam1>, <fam2> )  . . . . . . . . . . . . . . . . .  for two families
##
InstallMethod( \=,
     "for two families: delegate to `IsIdenticalObj'",
     true,
     [ IsFamily, IsFamily], 0,
     IS_IDENTICAL_OBJ );


#############################################################################
##
#M  \<( <obj1>, <obj2> )  . . . . . . . for two objects in different families
##
##  <#GAPDoc Label="[1]{object.gi}">
##  Only for the following kinds of objects, an ordering via <C>&lt;</C> of objects
##  in <E>different</E> families (see&nbsp;<Ref Sect="Families"/>) is supported.
##  Rationals (see&nbsp;<Ref Func="IsRat"/>) are smallest,
##  next are cyclotomics (see&nbsp;<Ref Func="IsCyclotomic"/>),
##  followed by finite field elements (see&nbsp;<Ref Func="IsFFE"/>);
##  finite field elements in different characteristics are compared
##  via their characteristics,
##  next are permutations (see&nbsp;<Ref Func="IsPerm"/>),
##  followed by the boolean values <K>true</K>, <K>false</K>, and <K>fail</K>
##  (see&nbsp;<Ref Func="IsBool"/>),
##  characters (such as <C>{</C>}a{'}', see&nbsp;<Ref Func="IsChar"/>),
##  and lists (see&nbsp;<Ref Func="IsList"/>) are largest;
##  note that two lists can be compared with <C>&lt;</C> if and only if their
##  elements are again objects that can be compared with <C>&lt;</C>.
##  <P/>
##  For other objects, &GAP; does <E>not</E> provide an ordering via <C>&lt;</C>.
##  The reason for this is that a total ordering of all &GAP; objects
##  would be hard to maintain when new kinds of objects are introduced,
##  and such a total ordering is hardly used in its full generality.
##  <P/>
##  However, for objects in the filters listed above, the ordering via <C>&lt;</C>
##  has turned out to be useful.
##  For example, one can form <E>sorted lists</E> containing integers and nested
##  lists of integers, and then search in them using <C>PositionSorted</C>
##  (see&nbsp;<Ref Sect="Finding Positions in Lists"/>).
##  <P/>
##  Of course it would in principle be possible to define an ordering
##  via <C>&lt;</C> also for certain other objects,
##  by installing appropriate methods for the operation <C>\&lt;</C>.
##  But this may lead to problems at least as soon as one loads &GAP; code
##  in which the same is done, under the assumption that one is completely
##  free to define an ordering via <C>&lt;</C> for other objects than the ones
##  for which the <Q>official</Q> &GAP; provides already an ordering via <C>&lt;</C>.
##  <#/GAPDoc>
##
TO_COMPARE := [
    [ IsCyclotomic, "cyclotomic" ],
    [ IsFFE,        "finite field element" ],
    [ IsPerm,       "permutation" ],
    [ IsBool,       "boolean" ],
    [ IsChar,       "character" ],
    [ IsList,       "list" ],
                                              ];
MAKE_COMP := function()
    local i, j, func, infostr;

    for i in [ 1 .. Length( TO_COMPARE ) ] do
      for j in [ 1 .. Length( TO_COMPARE ) ] do
        if i <> j then
          if i < j then func:= ReturnTrue; else func:= ReturnFalse; fi;
          infostr:= "for a ";
          APPEND_LIST_INTR( infostr, TO_COMPARE[i][2] );
          APPEND_LIST_INTR( infostr, ", and a " );
          APPEND_LIST_INTR( infostr, TO_COMPARE[j][2] );
          InstallMethod( \<, infostr, true,
              [ TO_COMPARE[i][1], TO_COMPARE[j][1] ], 0, func );
        fi;
      od;
    od;
end;
MAKE_COMP();

InstallMethod( \<,
    "for two finite field elements in different characteristic",
    IsNotIdenticalObj,
    [ IsFFE, IsFFE ], 0,
    function( z1, z2 )
    return Characteristic( z1 ) < Characteristic( z2 );
    end );

InstallMethod( \<,
    "for two small lists, possibly in different families",
    true,
    [ IsList and IsSmallList, IsList and IsSmallList ], 0,
    LT_LIST_LIST_DEFAULT );

LT_LIST_LIST_FINITE := function( list1, list2 )
    
    local len, i;
    
    # We ask for being small in order to catch the default methods
    # directly in the next call if possible.
    if IsSmallList( list1 ) and IsSmallList( list2 ) then
      return LT_LIST_LIST_DEFAULT( list1, list2 );
    else
        
      len:= Minimum( Length( list1 ), Length( list2 ) );
      i:= 1;                      
      while i <= len do
        if list1[i] < list2[i] then
          return true;
        elif list2[i] < list1[i] then
          return false;
        fi;
        i:= i+1;
      od;
      return len < Length( list2 );

    fi;
end;

InstallMethod( \<,
    "for two finite lists, possibly in different families",
    true,
    [ IsList, IsList ], 0,
    LT_LIST_LIST_FINITE );

#############################################################################
##
#M  String( <obj> ) . . . . . . . . . . . . default String method for objects
##  
##      
InstallMethod(String, [IsObject], o-> "<object>");

#############################################################################
##
#M  PrintObj( <obj> ) . . . . . . . . . . . default Print method for objects
##  
##      
InstallMethod(PrintObj, "default method delegating to PrintString",
  [IsObject], function(o) Print(PrintString(o)); end );
  
#############################################################################
##
#M  PrintString( <obj> ) . . . . . . . . . . . . default delegating to String
##
##
InstallMethod(PrintString, "default method delegating to String",
  [IsObject], -1, String);

# this command is useful to construct strings made of objects. It calls
# PrintString to its arguments and concatenates them. It is used in the
# library, but is not meant to be documented. (LB)
#
BIND_GLOBAL("STRINGIFY", function(arg)
    local s, i;
    s := ShallowCopy(String(arg[1]));
    for i in [2..Length(arg)] do
        Append(s,String(arg[i]));
    od;
    return s;
end);

BIND_GLOBAL("PRINT_STRINGIFY", function(arg)
    local s, i;
    s := ShallowCopy(PrintString(arg[1]));
    for i in [2..Length(arg)] do
        Append(s,"\>");
        Append(s,PrintString(arg[i]));
        Append(s,"\<");
    od;
    return s;
end);

#############################################################################
##
#F  StripLineBreakCharacters( <string> ) . . . removes \< and \> characters
##
InstallGlobalFunction( StripLineBreakCharacters,
  function(st)
    local res,c;
    res := EmptyString(Length(st));
    for c in st do 
        if c <> '\<' and c <> '\>' then
            Add(res,c);
        fi;
    od;
    ShrinkAllocationString(res);
    return res;
  end);

#############################################################################
##
#M  PrintString( <obj>, <width> )  . . . . . convert object into a string
##
InstallMethod( PrintString,
    "for an object, and a positive integer",
    true,
    [ IsObject,
      IsPosInt ],
    0,

function( str, n )

    local   blanks, fill;

    str:= PrintString( str );

    # If <width> is too small, return.
    if Length( str ) >= n then
        return ShallowCopy(str);
    fi;

    # If <width> is positive, blanks are filled in from the left.
    blanks := "                                                 ";
    fill := n - Length( str );
    while fill > 0  do
        if fill >= Length( blanks )  then
            str := Concatenation( blanks, str );
        else
            str := Concatenation( blanks{ [ 1 .. fill ] }, str );
        fi;
        fill := n - Length( str );
    od;
    return str;
end );


InstallMethod( PrintString,
    "for an object, and a negative integer",
    true,
    [ IsObject,
      IsNegRat and IsInt ],
    0,

function( str, n )

    local   blanks, fill;

    str:= PrintString( str );

    # If <width> is too small, return.
    if Length( str ) >= -n then
        return ShallowCopy(str);
    fi;

    # If <width> is negative, blanks are filled in from the right.
    blanks := "                                                 ";
    fill :=  - n - Length( str );
    while fill > 0  do
        if fill >= Length( blanks )  then
            str := Concatenation( str, blanks );
        else
            str := Concatenation( str, blanks{ [ 1 .. fill ] } );
        fi;
        fill :=  - n - Length( str );
    od;
    return str;
end );


InstallMethod( PrintString,
    "for an object, and zero",
    true,
    [ IsObject,
      IsZeroCyc ],
    0,

function( str, zero ) 
    return PrintString( str ); 
end );


#############################################################################
##
#M  String( <obj>, <width> )  . . . . . convert object into a string
##
InstallMethod( String,
    "for an object, and a positive integer",
    true,
    [ IsObject,
      IsPosInt ],
    0,

function( str, n )

    local   blanks, fill;

    str:= String( str );

    # If <width> is too small, return.
    if Length( str ) >= n then
        return ShallowCopy(str);
    fi;

    # If <width> is positive, blanks are filled in from the left.
    blanks := "                                                 ";
    fill := n - Length( str );
    while fill > 0  do
        if fill >= Length( blanks )  then
            str := Concatenation( blanks, str );
        else
            str := Concatenation( blanks{ [ 1 .. fill ] }, str );
        fi;
        fill := n - Length( str );
    od;
    return str;
end );


InstallMethod( String,
    "for an object, and a negative integer",
    true,
    [ IsObject,
      IsNegRat and IsInt ],
    0,

function( str, n )

    local   blanks, fill;

    str:= String( str );

    # If <width> is too small, return.
    if Length( str ) >= -n then
        return ShallowCopy(str);
    fi;

    # If <width> is negative, blanks are filled in from the right.
    blanks := "                                                 ";
    fill :=  - n - Length( str );
    while fill > 0  do
        if fill >= Length( blanks )  then
            str := Concatenation( str, blanks );
        else
            str := Concatenation( str, blanks{ [ 1 .. fill ] } );
        fi;
        fill :=  - n - Length( str );
    od;
    return str;
end );


InstallMethod( String,
    "for an object, and zero",
    true,
    [ IsObject,
      IsZeroCyc ],
    0,

function( str, zero ) 
    return ShallowCopy(String( str )); 
end );


#############################################################################
##
#M  PrintObj( <obj> )
##
InstallMethod( PrintObj,
    "for an object with name",
    true,
    [ HasName ],
    SUM_FLAGS, # override anything specific
    function ( obj )  Print( Name( obj ) ); end );


#############################################################################
##
#M  ViewObj( <obj> )  . . . . . . . . . . . . . . . . for an object with name
##
InstallMethod( ViewObj,
    "for an object with name",
    true,
    [ HasName ],
    SUM_FLAGS, # override anything specific
    function ( obj )  Print( Name( obj ) ); end );


#############################################################################
##
#V  DEFAULTVIEWSTRING . . . . . . . . . default string returned by ViewString
##
BIND_GLOBAL("DEFAULTVIEWSTRING", MakeImmutable("<object>"));


#############################################################################
##
#M  ViewObj( <obj> )  . . . . . try view string before delegating to PrintObj
##
InstallMethod( ViewObj,
    "default method trying ViewString",
    true,
    [ IsObject ],
    1, # beat the PrintObj installation in oper1.g
    function ( obj )  
      local st;
      st := ViewString(obj);
      if not(IsIdenticalObj(st,DEFAULTVIEWSTRING)) then
          Print(st);
      else
          TryNextMethod();
      fi;
    end );


#############################################################################
##
#M  ViewString( <obj> ) . . . . . . . . . . . . . . . for an object with name
##
InstallMethod( ViewString, "for an object with name", true,
               [ HasName ], SUM_FLAGS,  # override anything specific
	       Name );


#############################################################################
##
#M  ViewString( <obj> ) . . . . . . . . . . . . . . . . . . . default method
##
InstallMethod( ViewString, "generic default method", true,
               [ IsObject ], 1 ,   # this has to beat the legacy method
                                   # in the resclasses package
  function(obj)
    return DEFAULTVIEWSTRING;
  end );


#############################################################################
##
#M  ShallowCopy( <obj> )  . . . . . . . . . . . . . . . shallow copy of <obj>
##
InstallMethod( ShallowCopy,
    "for a (not copyable) object",
    true,
    [ IsObject ],
    0,

function( obj )
    if IsCopyable(obj)  then
        TryNextMethod();
    else
        return obj;
    fi;
end );


#############################################################################
##
#M  IsInternallyConsistent( <obj> ) . . . . . . . default method 'ReturnTrue'
##
InstallMethod( IsInternallyConsistent,
    "default method 'ReturnTrue'",
    true,
    [ IsObject ], 0,
    ReturnTrue );


#############################################################################
##
#M  KnownAttributesOfObject( <object> ) . . . . . list of names of attributes
##
InstallMethod( KnownAttributesOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    atomic readonly FILTER_REGION do
        trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_ATTS );
    od;

    # convert it into names
    return List( NamesFilter(trues), x -> x{[8..Length(x)-1]} );
end );


#############################################################################
##
#M  KnownPropertiesOfObject( <object> ) . . . . . list of names of properties
##
InstallMethod( KnownPropertiesOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    atomic readonly FILTER_REGION do
        trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_TPRS );
    od;

    # convert it into names
    return List( NamesFilter(trues), x -> x{[8..Length(x)-1]} );
end );


#############################################################################
##
#M  KnownPropertiesOfObject( <object> ) . . . . . list of names of properties
#M  KnownTruePropertiesOfObject( <object> )  list of names of true properties
##
InstallMethod( KnownTruePropertiesOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    atomic readonly FILTER_REGION do
        trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_PROS );
    od;

    # convert it into names
    return NamesFilter(trues);
end );


#############################################################################
##
#M  CategoriesOfObject( <object> )  . . . . . . . list of names of categories
##
InstallMethod( CategoriesOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    atomic readonly FILTER_REGION do
       trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_CATS );
    od;

    # convert it into names
    return NamesFilter(trues);
end );


#############################################################################
##
#M  RepresentationsOfObject( <object> ) . .  list of names of representations
##
InstallMethod( RepresentationsOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    atomic readonly FILTER_REGION do
        trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_REPS );
    od;

    # convert it into names
    return NamesFilter(trues);
end );


#############################################################################
##
#V  DEFAULTDISPLAYSTRING . . . . . . default string returned by DisplayString
##
BIND_GLOBAL("DEFAULTDISPLAYSTRING", MakeImmutable("<object>\n"));


#############################################################################
##
#M  Display( <obj> )  . . . . . . . . . . . . . . . . . . . display an object
##
##  We do not call `PrintObj' because strings shall be displayed without
##  enclosing doublequotes.
##
InstallMethod( Display,
        "generic: use DisplayString or otherwise PrintObj",
        true,
        [ IsObject ], 0,
  function( obj ) 
    local st;
    st := DisplayString(obj);
    if IsIdenticalObj(st,DEFAULTDISPLAYSTRING) then
        Print(obj, "\n");
    else
        Print(st);
    fi;
end );
    

#############################################################################
##
#M  DisplayString( <obj> )  . . . . . . . . . . display string for an object
##
##  We do not call `PrintObj' because strings shall be displayed without
##  enclosing doublequotes.
##
InstallMethod( DisplayString,
        "generic: return default string",
        true,
        [ IsObject ], -1,
  function( obj ) 
    return DEFAULTDISPLAYSTRING;
  end );

#############################################################################
##
#M  PostMakeImmutable( <obj> ) . . . . . . . . . . . . .do nothing in general
##  

InstallMethod( PostMakeImmutable,
        "unless otherwise directed, do nothing",
        true,
        [IsObject], 0,
        function( obj)
    return;
end );

#############################################################################
##
#M  SetName( <obj>,<name> )
##
##  generic routine to test 2nd argument
##
InstallMethod( SetName, "generic test routine", true, [ IsObject,IsObject ],
  # override setter
  SUM_FLAGS+1,
function( obj,str ) 
  if not IsString(str) then
    Error("SetName: <name> must be a string");
  fi;
  TryNextMethod();
end );
    
#############################################################################
##
#M  PostMakeImmutable( <obj> ) . . . . . . . . . . . . .do nothing in general
##  



#############################################################################
##
#F  NewObjectMarker( )
#F  MarkObject( <marks>, <obj> )
#F  UnmarkObject( <marks>, <obj> )
#F  ClearObjectMarker( <marks> )
##  
##  Utilities to detect identical objects. Used in MemoryUsage below,
##  but probably of independent interest.
##  

InstallGlobalFunction(NewObjectMarker, function()
  return OBJ_SET([]);
end);

InstallGlobalFunction(MarkObject, function(marks, obj)
  local result;
  result := FIND_OBJ_SET(marks, obj);
  ADD_OBJ_SET(marks, obj);
  return result;
end);

InstallGlobalFunction(UnmarkObject, REMOVE_OBJ_SET);

InstallGlobalFunction(ClearObjectMarker, CLEAR_OBJ_SET);

#############################################################################
##
#M  MemoryUsage( <obj> ) . . . . . . . . . . . . .return fail in general
##  
BindThreadLocalConstructor( "MEMUSAGECACHE", NewObjectMarker );
BindThreadLocal("MEMUSAGECACHE_DEPTH", 0);

InstallGlobalFunction( MU_AddToCache, function ( obj )
  return MarkObject(MEMUSAGECACHE, obj);
end );

InstallGlobalFunction( MU_Finalize, function (  )
  local mks, i;
  if MEMUSAGECACHE_DEPTH <= 0  then
      Error( "MemoryUsage depth has gone below zero!" );
  fi;
  MEMUSAGECACHE_DEPTH := MEMUSAGECACHE_DEPTH - 1;
  if MEMUSAGECACHE_DEPTH = 0  then
    ClearObjectMarker(MEMUSAGECACHE);
  fi;
end );

InstallMethod( MemoryUsage, "fallback method for objs without subobjs",
  [ IsObject ],
  function( o )
    local mem;
    mem := SHALLOW_SIZE(o);
    if mem = 0 then 
        return MU_MemPointer;
    else
        # a proper object, thus we have to add it to the database
        # to not count it again!
        if not(MU_AddToCache(o)) then
            mem := mem + MU_MemBagHeader + MU_MemPointer;
            # This is for the bag, the header, and the master pointer
        else 
            mem := 0;   # already counted
        fi;
        if MEMUSAGECACHE_DEPTH = 0 then   
            # we were the first to be called, thus we have to do the cleanup
            ClearObjectMarker( MEMUSAGECACHE );
        fi;
    fi;
    return mem;
  end );

InstallMethod( MemoryUsage, "for a plist",
  [ IsList and IsPlistRep ],
  function( o )
    local mem,known,i;
    known := MU_AddToCache( o );
    if known = false then    # not yet known
        MEMUSAGECACHE_DEPTH := MEMUSAGECACHE_DEPTH + 1;
        mem := SHALLOW_SIZE(o) + MU_MemBagHeader + MU_MemPointer;
        # Again the bag, its header, and the master pointer
        for i in [1..Length(o)] do
            if IsBound(o[i]) then
                if SHALLOW_SIZE(o[i]) > 0 then    # a subobject!
                    mem := mem + MemoryUsage(o[i]);
                fi;
            fi;
        od;
        MU_Finalize();
        return mem;
    fi;
    return 0;    # already counted
  end );

InstallMethod( MemoryUsage, "for a record",
  [ IsRecord ],
  function( o )
    local mem,known,i,s;
    known := MU_AddToCache( o );
    if known = false then    # not yet known
        MEMUSAGECACHE_DEPTH := MEMUSAGECACHE_DEPTH + 1;
        mem := SHALLOW_SIZE(o) + MU_MemBagHeader + MU_MemPointer;
        # Again the bag, its header, and the master pointer
        for i in RecFields(o) do
            s := o.(i);
            if SHALLOW_SIZE(s) > 0 then    # a subobject!
                mem := mem + MemoryUsage(s);
            fi;
        od;
        MU_Finalize();
        return mem;
    fi;
    return 0;    # already counted
  end );

InstallMethod( MemoryUsage, "for a positional object",
  [ IsPositionalObjectRep ],
  function( o )
    local mem,known,i;
    known := MU_AddToCache( o );
    if known = false then    # not yet known
        MEMUSAGECACHE_DEPTH := MEMUSAGECACHE_DEPTH + 1;
        mem := SHALLOW_SIZE(o) + MU_MemBagHeader + MU_MemPointer;
        # Again the bag, its header, and the master pointer
        for i in [1..(SHALLOW_SIZE(o)/MU_MemPointer)-1] do
            if IsBound(o![i]) then
                if SHALLOW_SIZE(o![i]) > 0 then    # a subobject!
                    mem := mem + MemoryUsage(o![i]);
                fi;
            fi;
        od;
        MU_Finalize();
        return mem;
    fi;
    return 0;    # already counted
  end );

InstallMethod( MemoryUsage, "for a component object",
  [ IsComponentObjectRep ],
  function( o )
    local mem,known,i,s;
    known := MU_AddToCache( o );
    if known = false then    # not yet known
        MEMUSAGECACHE_DEPTH := MEMUSAGECACHE_DEPTH + 1;
        mem := SHALLOW_SIZE(o) + MU_MemBagHeader + MU_MemPointer;
        # Again the bag, its header, and the master pointer
        for i in NamesOfComponents(o) do
            s := o!.(i);
            if SHALLOW_SIZE(s) > 0 then    # a subobject!
                mem := mem + MemoryUsage(s);
            fi;
        od;
        MU_Finalize();
        return mem;
    fi;
    return 0;    # already counted
  end );

InstallMethod( MemoryUsage, "for a rational",
  [ IsRat ],
  function( o )
    if IsInt(o) then TryNextMethod(); fi;
    if not(MU_AddToCache(o)) then
        return   SHALLOW_SIZE(o) + MU_MemBagHeader + MU_MemPointer
               + SHALLOW_SIZE(NumeratorRat(o)) 
               + SHALLOW_SIZE(DenominatorRat(o));
    else
        return 0;
    fi;
  end );

InstallMethod( MemoryUsage, "for a function",
  [ IsFunction ],
  function( o )
    if not(MU_AddToCache(o)) then
        return SHALLOW_SIZE(o) + 2*(MU_MemBagHeader + MU_MemPointer) +
               FUNC_BODY_SIZE(o);
    else
        return 0;
    fi;
  end );

# Intentionally ignore families and types:

InstallMethod( MemoryUsage, "for a family",
  [ IsFamily ],
  function( o ) return 0; end );

InstallMethod( MemoryUsage, "for a type",
  [ IsType ],
  function( o ) return 0; end );

#############################################################################
##
#E

