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
