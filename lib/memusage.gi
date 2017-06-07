#############################################################################
##
#W  memusage.gi                   GAP library
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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

InstallGlobalFunction( NewObjectMarker, function()
  local marks, len;
  marks := rec();
  len := 2 * MASTER_POINTER_NUMBER(2^100);
  marks.marks := BlistList([1..len], []);
  marks.ids := [];
  # If this is set to some higher values the clearing of the entries
  # takes more time than creating .marks from scratch.
  marks.maxids := QuoInt(Length(marks.marks), 30);
  return marks;
end);

InstallGlobalFunction( MarkObject, function(marks, obj)
  local id, res;
  id := MASTER_POINTER_NUMBER(obj);
  if id > Length(marks.marks) then
    marks.marks :=  BlistList( [ 1 .. 2 * id ],
                                    PositionsTrueBlist(marks.marks));
  fi;
  if marks.maxids > Length(marks.ids) then
    Add(marks.ids, id);
  fi;
  res := marks.marks[id];
  marks.marks[id] := true;
  return res;
end);

InstallGlobalFunction( UnmarkObject, function(marks, obj)
  local id;
  id := MASTER_POINTER_NUMBER(obj);
  if id > Length(marks.marks) or not marks.marks[id] then
    return false;
  else
    marks.marks[id] := false;
    return true;
  fi;
end);

InstallGlobalFunction( ClearObjectMarker, function(marks)
  if Length(marks.ids) < marks.maxids then
    marks.marks{marks.ids} := BlistList([1..Length(marks.ids)], []);
  else
    marks.marks := BlistList([1..Length(marks.marks)], []);
  fi;
  marks.ids := [];
end);

#############################################################################
##
#M  MemoryUsage( <obj> ) . . . . . . . . . . . . .return fail in general
##  
BIND_GLOBAL( "MEMUSAGECACHE", NewObjectMarker( ) );
MEMUSAGECACHE_DEPTH := 0;

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

InstallMethod( MemoryUsage, "generic fallback method",
  [ IsObject ],
  function( o )
    local mem,known,i,s;

    if SHALLOW_SIZE(o) = 0 then
        return MU_MemPointer;
    fi;

    if MU_AddToCache( o ) then
        return 0;    # already counted
    fi;

    MEMUSAGECACHE_DEPTH := MEMUSAGECACHE_DEPTH + 1;

    # Count the bag, the header, and the master pointer
    mem := SHALLOW_SIZE(o) + MU_MemBagHeader + MU_MemPointer;
    if IS_POSOBJ(o) then
        # Again the bag, its header, and the master pointer
        for i in [1..LEN_POSOBJ(o)] do
            if IsBound(o![i]) then
                if SHALLOW_SIZE(o![i]) > 0 then    # a subobject!
                    mem := mem + MemoryUsage(o![i]);
                fi;
            fi;
        od;
    elif IS_COMOBJ(o) then
        # Again the bag, its header, and the master pointer
        for i in NamesOfComponents(o) do
            s := o!.(i);
            if SHALLOW_SIZE(s) > 0 then    # a subobject!
                mem := mem + MemoryUsage(s);
            fi;
        od;
    elif TNUM_OBJ_INT(o) >= FIRST_EXTERNAL_TNUM then
        # Since we are in the fallback method, clearly there is no
        # MemoryUsage method installed for the given object.
        if not IsGF2VectorRep(o) and not Is8BitVectorRep(o) then
            Info(InfoWarning, 1, "No MemoryUsage method installed for ",
                                 TNUM_OBJ(o)[2],
                                 ", reported usage may be too low" );
        fi;
    fi;
    MU_Finalize();
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
