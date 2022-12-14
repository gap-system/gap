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


#############################################################################
##
#M  IsEqualSet( <list1>, <list2> )  . . . . . . . . . . . . . . for two lists
##
InstallMethod( IsEqualSet,
    "for two lists",
    true,
    [ IsList, IsList ], 0,
    function( list1, list2 )
    return Set( list1 ) = Set( list2 );
    end );


#############################################################################
##
#M  IsEqualSet( <list1>, <list2> )  . .  for two internally represented lists
##
InstallMethod( IsEqualSet,
    "for two internally represented lists",
    true,
    [ IsList and IsInternalRep, IsList and IsInternalRep ], 0,
    IS_EQUAL_SET );


#############################################################################
##
#M  IsSubsetSet( <list1>, <list2> ) . . . . . . . . . . . . . . for two lists
##
InstallMethod( IsSubsetSet,
    "for two lists",
    true,
    [ IsList, IsList ], 0,
    function( list1, list2 )
    list1:= Set( list1 );
    return ForAll( Set( list2 ), x -> x in list1 );
    end );


#############################################################################
##
#M  IsSubsetSet( <list1>, <list2> ) . .  for two internally represented lists
##
InstallMethod( IsSubsetSet,
    "for two internally represented lists",
    true,
    [ IsList and IsInternalRep, IsList and IsInternalRep ], 0,
    IS_SUBSET_SET );


#############################################################################
##
#M  AddSet( <set>, <obj> )  . . . . . . . . . .  for mutable list, and object
##
InstallMethod( AddSet,
    "for mutable list, and object",
    true,
    [ IsList and IsMutable, IsObject ], 0,
    function( set, obj )
    local pos, len;
    if not IsSSortedList( set ) then
      Error( "<set> must be a mutable proper set" );
    fi;
    pos:= PositionSorted( set, obj );
    if pos>Length(set) then
      set[ pos ]:= obj;
    elif set[ pos ] <> obj then
      len:= Length( set );
      set{ [ pos+1 .. len+1 ] }:= set{ [ pos .. len ] };
      set[ pos ]:= obj;
    fi;
    end );


#############################################################################
##
#M  AddSet( <set>, <obj> )  . . . . . for mutable int. repr. list, and object
##
InstallMethod( AddSet,
    "for mutable internally represented list, and object",
    true,
    [ IsList and IsInternalRep and IsMutable, IsObject ], 0,
    ADD_SET );


#############################################################################
##
#M  RemoveSet( <set>, <obj> ) . . . . for mutable int. repr. list, and object
##
InstallMethod( RemoveSet,
    "for mutable internally represented list, and object",
    true,
    [ IsList and IsInternalRep and IsMutable, IsObject ], 0,
    REM_SET );


#############################################################################
##
#M  RemoveSet( <set>, <obj> ) . . . . . . . . .  for mutable list, and object
##
InstallMethod( RemoveSet,
    "for mutable list, and object",
    true,
    [ IsList and IsMutable, IsObject ], 0,
    function( set, obj )
    local pos, len;
    if not IsSSortedList( set ) then
      Error( "<set> must be a mutable proper set" );
    fi;
    pos:= PositionSorted( set, obj );
    len:= Length( set );
    if pos <= len and set[ pos ] = obj then
      set{ [ pos .. len-1 ] }:= set{ [ pos+1 .. len ] };
      Unbind( set[ len ] );
    fi;
    end );


#############################################################################
##
#M  UniteSet( <set>, <list> ) . . . . .  for two internally represented lists
##
InstallMethod( UniteSet,
    "for two internally represented lists, the first being mutable",
    true,
    [ IsList and IsInternalRep and IsMutable, IsList and IsInternalRep ], 0,
    UNITE_SET );


#############################################################################
##
#M  UniteSet( <set>, <list> ) . . . . . . .  for two lists, the first mutable
##
InstallMethod( UniteSet,
    "for two lists, the first being mutable",
    true,
    [ IsList and IsMutable, IsList ], 0,
    function( set, list )
    local obj;
    if not IsSSortedList( set ) then
      Error( "<set> must be a mutable proper set" );
    fi;
    for obj in list do
      AddSet( set, obj );
    od;
    end );


#############################################################################
##
#M  IntersectSet( <set>, <list> ) . . .  for two internally represented lists
##
InstallMethod( IntersectSet,
    "for two internally represented lists, the first being mutable",
    true,
    [ IsList and IsInternalRep and IsMutable, IsList and IsInternalRep ], 0,
    INTER_SET );


#############################################################################
##
#M  IntersectSet( <set>, <list> ) . . . . .  for two lists, the first mutable
##
InstallMethod( IntersectSet,
    "for two lists, the first being mutable",
    true,
    [ IsList and IsMutable, IsList ], 0,
    function( set, list )
    local obj,i;
    if not IsSSortedList( set ) then
      Error( "<set> must be a mutable proper set" );
    fi;
    i:= 1;
    while i <= Length( set ) do
      obj:= set[i];
      if not obj in list then
          RemoveSet( set, obj );
      else
          i:= i+1;
      fi;
    od;

    end );


#############################################################################
##
#M  SubtractSet( <set>, <list> )  . . .  for two internally represented lists
##
InstallMethod( SubtractSet,
    "for two internally represented lists, the first being mutable",
    true,
    [ IsList and IsInternalRep and IsMutable, IsList and IsInternalRep ], 0,
    SUBTR_SET );


#############################################################################
##
#M  SubtractSet( <set>, <list> )  . . . . .  for two lists, the first mutable
##
InstallMethod( SubtractSet,
    "for two lists, the first being mutable",
    true,
    [ IsList and IsMutable, IsList ], 0,
    function( set, list )
    local obj;
    if not IsSSortedList( set ) then
      Error( "<set> must be a mutable proper set" );
    fi;
    for obj in list do
      RemoveSet( set, obj );
    od;
    end );


#############################################################################
##
##  Fallback methods to give better user feedback if the first argument is
##  not mutable or not a set
##
BindGlobal("_REQUIRE_MUTABLE_SET",
    function( set, obj )
    if not IsMutable(set) or not IsSSortedList( set ) then
      Error( "<set> must be a mutable proper set" );
    fi;
    TryNextMethod();
    end );
InstallOtherMethod( AddSet, "for two objects", [ IsObject, IsObject ], _REQUIRE_MUTABLE_SET);
InstallOtherMethod( RemoveSet, "for two objects", [ IsObject, IsObject ], _REQUIRE_MUTABLE_SET);
InstallOtherMethod( UniteSet, "for two objects", [ IsObject, IsObject ], _REQUIRE_MUTABLE_SET);
InstallOtherMethod( IntersectSet, "for two objects", [ IsObject, IsObject ], _REQUIRE_MUTABLE_SET);
InstallOtherMethod( SubtractSet, "for two objects", [ IsObject, IsObject ], _REQUIRE_MUTABLE_SET);
