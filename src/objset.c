/****************************************************************************
**
*W  objset.c                   GAP source                    Reimer Behrends
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the GAP interface for thread primitives.
*/
#include <assert.h>
#include <string.h>                     /* memcpy */
#include <stdlib.h>

#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>

#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */

#include <src/gap.h>                    /* error handling, initialisation */
#include <src/gvars.h>                  /* global variables */
#include <src/bool.h>                   /* booleans */
#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */

#include <src/fibhash.h>

#include <src/objset.h>

#include <src/scanner.h>

#include <src/hpc/tls.h>

#include <src/util.h>

Obj TYPE_OBJSET;
Obj TYPE_OBJMAP;

static Obj TypeObjSet(Obj obj) {
  return TYPE_OBJSET;
}

static Obj TypeObjMap(Obj obj) {
  return TYPE_OBJMAP;
}

/** Object sets and maps --------------------
 *
 *  Object sets and maps are hash tables where identity is determined
 *  according to the IsIdenticalObj() relation. They are primarily intended
 *  for code that needs to traverse object structures in order to remember if
 *  an object has already been seen by the traversal algorithm. They can also
 *  be used as sparse lists with integer keys and as proper sets and maps for
 *  short integers and small finite field elements.
 *
 *  Object sets and object maps consist of four header words describing the
 *  map layout, followed by a list of entries containing the actual set/map
 *  data. The size of that list is always a power of 2.
 *
 *  The first header word contains the size of the data list, the second
 *  header word contains the base 2 logarithm of that size, the third word
 *  contains the number of entries actually in use, and the fourth word
 *  contains the number of deleted but not reused entries.
 *
 *  Entries in the data list comprise either a single GAP object for sets or a
 *  (key, value) pair of GAP objects for maps.
 *
 *  Unused entries contain a null pointer; deleted entries for sets and the
 *  keys of deleted entries for sets contain the special boolean value
 *  `Undefined`. Values of deleted entries contain a null pointer.
 */


#define DEFAULT_OBJSET_BITS 2
#define DEFAULT_OBJSET_SIZE (1 << DEFAULT_OBJSET_BITS)

#define OBJSET_SIZE 0
#define OBJSET_BITS 1
#define OBJSET_USED 2
#define OBJSET_DIRTY 3

#define ADDR_WORD(obj) ((UInt *)(ADDR_OBJ(obj)))

/**
 *  Functions to print object maps and sets
 *  ---------------------------------------
 */

static void PrintObjSet(Obj set) {
  UInt i, size = ADDR_WORD(set)[OBJSET_SIZE];
  Int comma = 0;
  Pr("OBJ_SET([ ", 0L, 0L);
  for (i=0; i < size; i++) {
    Obj obj = ADDR_OBJ(set)[OBJSET_HDRSIZE + i ];
    if (obj && obj != Undefined) {
      if (comma) {
        Pr(", ", 0L, 0L);
      } else {
        comma = 1;
      }
      PrintObj(obj);
    }
  }
  Pr(" ])", 0L, 0L);
}

static void PrintObjMap(Obj map) {
  UInt i, size = ADDR_WORD(map)[OBJSET_SIZE];
  Int comma = 0;
  Pr("OBJ_MAP([ ", 0L, 0L);
  for (i=0; i < size; i++) {
    Obj obj = ADDR_OBJ(map)[OBJSET_HDRSIZE + i * 2 ];
    if (obj && obj != Undefined) {
      if (comma) {
        Pr(", ", 0L, 0L);
      } else {
        comma = 1;
      }
      PrintObj(obj);
      Pr(", ", 0L, 0L);
      PrintObj(ADDR_OBJ(map)[OBJSET_HDRSIZE + i * 2 + 1]);
    }
  }
  Pr(" ])", 0L, 0L);
}

/**
 *  Garbage collector support for object maps and sets
 *  --------------------------------------------------
 *
 *  These functions are not yet implemented.
 */

static void MarkObjSet(Obj obj) {
  UInt size = ADDR_WORD(obj)[OBJSET_SIZE];
  MarkArrayOfBags( ADDR_OBJ(obj) + OBJSET_HDRSIZE, size );
}

static void MarkObjMap(Obj obj) {
  UInt size = ADDR_WORD(obj)[OBJSET_SIZE];
  MarkArrayOfBags( ADDR_OBJ(obj) + OBJSET_HDRSIZE, 2 * size );
}

/**
 *  The primary hash function
 *  -------------------------
 *
 *  Hashing is done using Fibonacci hashing (Knuth) modulo the
 *  size of the table.
 */


static inline UInt ObjHash(Obj set, Obj obj) {
  return FibHash((UInt) obj, ADDR_WORD(set)[OBJSET_BITS]);
}


/**
 *  `NewObjSet()`
 *  -------------
 *
 *  Create and return a new object set.
 */

Obj NewObjSet() {
  Obj result = NewBag(T_OBJSET,
    (OBJSET_HDRSIZE+DEFAULT_OBJSET_SIZE)*sizeof(Bag));
  ADDR_WORD(result)[OBJSET_SIZE] = DEFAULT_OBJSET_SIZE;
  ADDR_WORD(result)[OBJSET_BITS] = DEFAULT_OBJSET_BITS;
  ADDR_WORD(result)[OBJSET_USED] = 0;
  ADDR_WORD(result)[OBJSET_DIRTY] = 0;
  return result;
}

/**
 *  `CheckObjSetForCleanUp()`
 *  -------------------------
 *
 *  Determine if there is an excess number of deleted entries in `set` and
 *  compact the set if necessary. The additional paramater `expand` can be
 *  set to a non-zero value to reserve space for that many additional entries
 *  that will be inserted right after compaction.
 */

static void ResizeObjSet(Obj set, UInt bits);

static void CheckObjSetForCleanUp(Obj set, UInt expand) {
  UInt size = ADDR_WORD(set)[OBJSET_SIZE];
  UInt bits = ADDR_WORD(set)[OBJSET_BITS];
  UInt used = ADDR_WORD(set)[OBJSET_USED] + expand;
  UInt dirty = ADDR_WORD(set)[OBJSET_DIRTY];
  if (used * 3 >= size * 2)
    ResizeObjSet(set, bits+1);
  else if (dirty && dirty >= used)
    ResizeObjSet(set, bits);
}

/**
 *  `FindObjSet()`
 *  --------------
 *
 *  Locate `obj` within `set`. Return -1 if `obj` was not found, otherwise
 *  return the position within the data, starting with zero for the first
 *  entry.
 */

Int FindObjSet(Obj set, Obj obj) {
  UInt size = ADDR_WORD(set)[OBJSET_SIZE];
  UInt hash = ObjHash(set, obj);
  GAP_ASSERT(hash >= 0 && hash < size);
  for (;;) {
    Obj current;
    current = ADDR_OBJ(set)[OBJSET_HDRSIZE+hash];
    if (!current)
      return -1;
    if (current == obj)
      return (Int) hash;
    hash++;
    if (hash >= size)
      hash = 0;
  }
}

/**
 *  `AddObjSetNew()`
 *  ----------------
 *
 *  Add `obj` to `set`.
 *
 *  Precondition: `set` must not already contain `obj`.
 */

static void AddObjSetNew(Obj set, Obj obj) {
  UInt size = ADDR_WORD(set)[OBJSET_SIZE];
  UInt hash = ObjHash(set, obj);
  GAP_ASSERT(TNUM_OBJ(set) == T_OBJSET);
  GAP_ASSERT(hash >= 0 && hash < size);
  for (;;) {
    Obj current;
    current = ADDR_OBJ(set)[OBJSET_HDRSIZE+hash];
    if (!current) {
      ADDR_OBJ(set)[OBJSET_HDRSIZE+hash] = obj;
      ADDR_WORD(set)[OBJSET_USED]++;
      CHANGED_BAG(set);
      return;
    }
    if (current == Undefined) {
      ADDR_OBJ(set)[OBJSET_HDRSIZE+hash] = obj;
      ADDR_WORD(set)[OBJSET_USED]++;
      ADDR_WORD(set)[OBJSET_DIRTY]--;
      GAP_ASSERT(ADDR_WORD(set)[OBJSET_DIRTY] >= 0);
      CHANGED_BAG(set);
      return;
    }
    hash++;
    if (hash >= size)
      hash = 0;
  }
}

/**
 *  `AddObjSet()`
 *  -------------
 *
 *  This function adds `obj` to `set` if the set doesn't contain it already.
 */

void AddObjSet(Obj set, Obj obj) {
  if (FindObjSet(set, obj) >= 0)
    return;
  CheckObjSetForCleanUp(set, 1);
  AddObjSetNew(set, obj);
}

/**
 *  `RemoveObjSet()`
 *  ----------------
 *
 *  This function removes `obj` from `set` unless the set doesn't contain it.
 */

void RemoveObjSet(Obj set, Obj obj) {
  Int pos = FindObjSet(set, obj);
  if (pos >= 0) {
    ADDR_OBJ(set)[OBJSET_HDRSIZE+pos] = Undefined;
    ADDR_WORD(set)[OBJSET_USED]--;
    ADDR_WORD(set)[OBJSET_DIRTY]++;
    CHANGED_BAG(set);
    CheckObjSetForCleanUp(set, 0);
  }
}

/**
 *  `ClearObjSet()`
 *  ---------------
 *
 *  This function removes all objects from `set`.
 */

void ClearObjSet(Obj set) {
  Obj new = NewObjSet();
  SwapMasterPoint(set, new);
  CHANGED_BAG(set);
}

/**
 *  `ObjSetValues()`
 *  ---------------
 *
 *  This function returns the elements of the set as a list.
 */

Obj ObjSetValues(Obj set) {
  UInt len = ADDR_WORD(set)[OBJSET_USED];
  UInt size = ADDR_WORD(set)[OBJSET_SIZE];
  UInt p, i;
  Obj result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  for (i=0, p=1; i < size; i++) {
    Obj el = ADDR_OBJ(set)[OBJSET_HDRSIZE + i];
    if (el && el != Undefined) {
      SET_ELM_PLIST(result, p, el);
      p++;
    }
  }
  GAP_ASSERT(p == len + 1);
  CHANGED_BAG(result);
  return result;
}

/**
 *  `ResizeObjSet()`
 *  ----------------
 *
 *  This function resizes `set` to have room for `2^bits` entries.
 *
 *  Precondition: the number of entries in `set` must be less than
 *  `2^bits`. There must be at least one free entry remaining.
 */

static void ResizeObjSet(Obj set, UInt bits) {
  UInt i, new_size = (1 << bits);
  Int size = ADDR_WORD(set)[OBJSET_SIZE];
  Obj new = NewBag(T_OBJSET, (OBJSET_HDRSIZE+new_size)*sizeof(Bag)*4);
  GAP_ASSERT(TNUM_OBJ(set) == T_OBJSET);
  GAP_ASSERT(new_size >= size);
  ADDR_WORD(new)[OBJSET_SIZE] = new_size;
  ADDR_WORD(new)[OBJSET_BITS] = bits;
  ADDR_WORD(new)[OBJSET_USED] = 0;
  ADDR_WORD(new)[OBJSET_DIRTY] = 0;
  for (i = OBJSET_HDRSIZE + size - 1; i >= OBJSET_HDRSIZE; i--) {
    Obj obj = ADDR_OBJ(set)[i];
    if (obj && obj != Undefined) {
      AddObjSetNew(new, obj);
    }
  }
  SwapMasterPoint(set, new);
  CHANGED_BAG(set);
}

/**
 *  `NewObjMap()`
 *  -------------
 *
 *  Create a new object map.
 */

Obj NewObjMap() {
  Obj result = NewBag(T_OBJMAP, (4+2*DEFAULT_OBJSET_SIZE)*sizeof(Bag));
  ADDR_WORD(result)[OBJSET_SIZE] = DEFAULT_OBJSET_SIZE;
  ADDR_WORD(result)[OBJSET_BITS] = DEFAULT_OBJSET_BITS;
  ADDR_WORD(result)[OBJSET_USED] = 0;
  ADDR_WORD(result)[OBJSET_DIRTY] = 0;
  return result;
}

/**
 *  `CheckObjMapForCleanUp()`
 *  -------------------------
 *
 *  Determine if there is an excess number of deleted entries in `map` and
 *  compact the map if necessary. The additional paramater `expand` can be
 *  set to a non-zero value to reserve space for that many additional entries
 *  that will be inserted right after compaction.
 */

static void ResizeObjMap(Obj map, UInt bits);

static void CheckObjMapForCleanUp(Obj map, UInt expand) {
  UInt size = ADDR_WORD(map)[OBJSET_SIZE];
  UInt bits = ADDR_WORD(map)[OBJSET_BITS];
  UInt used = ADDR_WORD(map)[OBJSET_USED] + expand;
  UInt dirty = ADDR_WORD(map)[OBJSET_DIRTY];
  if (used * 3 >= size * 2)
    ResizeObjMap(map, bits+1);
  else if (dirty && dirty >= used)
    ResizeObjMap(map, bits);
}

/**
 *  `FindObjMap()`
 *  --------------
 *
 *  Locate the data entry with key `obj` within `map`. Return -1 if such an
 *  entry was not found, otherwise return the position within the data,
 *  starting with zero for the first entry.
 */

Int FindObjMap(Obj map, Obj obj) {
  UInt size = ADDR_WORD(map)[OBJSET_SIZE];
  UInt hash = ObjHash(map, obj);
  for (;;) {
    Obj current;
    current = ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2];
    if (!current)
      return -1;
    if (current == obj)
      return (Int) hash;
    hash++;
    if (hash >= size)
      hash = 0;
  }
}

/**
 *  `LookupObjMap()`
 *  ----------------
 *
 *  Locate the data entry with key `obj` within `map`. Return a null pointer
 *  if such an entry was not found, otherwise return the corresponding value.
 */

Obj LookupObjMap(Obj map, Obj obj) {
  Int index = FindObjMap(map, obj);
  if (index < 0)
    return (Obj) 0;
  return ADDR_OBJ(map)[OBJSET_HDRSIZE+index*2+1];
}

/**
 *  `AddObjMapNew()`
 *  ----------------
 *
 *  Add an entry `(key, value)` to `map`.
 *  
 *  Precondition: No other entry with key `key` exists within `map`.
 */

static void AddObjMapNew(Obj map, Obj key, Obj value) {
  UInt size = ADDR_WORD(map)[OBJSET_SIZE];
  UInt hash = ObjHash(map, key);
  for (;;) {
    Obj current;
    current = ADDR_OBJ(map)[OBJSET_HDRSIZE+hash * 2];
    if (!current) {
      ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2] = key;
      ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2+1] = value;
      ADDR_WORD(map)[OBJSET_USED]++;
      CHANGED_BAG(map);
      return;
    }
    if (current == Undefined) {
      ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2] = key;
      ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2+1] = value;
      ADDR_WORD(map)[OBJSET_USED]++;
      ADDR_WORD(map)[OBJSET_DIRTY]--;
      CHANGED_BAG(map);
      return;
    }
    hash++;
    if (hash >= size)
      hash = 0;
  }
}

/**
 *  `AddObjMap()`
 *  -------------
 *
 *  Add a data entry `(key, value)` to `map`. If `map` already contains an
 *  entry with that key, its value will be replaced.
 */

void AddObjMap(Obj map, Obj key, Obj value) {
  Int pos;
  pos = FindObjMap(map, key);
  if (pos >= 0) {
    ADDR_OBJ(map)[OBJSET_HDRSIZE+pos*2+1] = value;
    CHANGED_BAG(map);
    return;
  }
  CheckObjMapForCleanUp(map, 1);
  AddObjMapNew(map, key, value);
}

/**
 *  `RemoveObjMap()`
 *  ----------------
 *
 *  Remove the data entry with key `key` from `map` if such an entry exists.
 */

void RemoveObjMap(Obj map, Obj key) {
  Int pos = FindObjMap(map, key);
  if (pos >= 0) {
    ADDR_OBJ(map)[OBJSET_HDRSIZE+pos*2] = Undefined;
    ADDR_OBJ(map)[OBJSET_HDRSIZE+pos*2+1] = (Obj) 0;
    ADDR_WORD(map)[OBJSET_USED]--;
    ADDR_WORD(map)[OBJSET_DIRTY]++;
    CHANGED_BAG(map);
    CheckObjMapForCleanUp(map, 0);
  }
}

/**
 *  `ClearObjMap()`
 *  ---------------
 *
 *  Remove all data entries from `map`.
 */

void ClearObjMap(Obj map) {
  Obj new = NewObjMap();
  SwapMasterPoint(map, new);
}

/**
 *  `ObjMapValues()`
 *  ---------------
 *
 *  This function returns all values from the map.
 */

Obj ObjMapValues(Obj set) {
  UInt len = ADDR_WORD(set)[OBJSET_USED];
  UInt size = ADDR_WORD(set)[OBJSET_SIZE];
  UInt p, i;
  Obj result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  for (i=0, p=1; i < size; i++) {
    Obj el = ADDR_OBJ(set)[OBJSET_HDRSIZE + 2*i+1];
    if (el && el != Undefined) {
      SET_ELM_PLIST(result, p, el);
      p++;
    }
  }
  GAP_ASSERT(p == len + 1);
  CHANGED_BAG(result);
  return result;
}

/**
 *  `ObjMapKeys()`
 *  ---------------
 *
 *  This function returns all keys from the map.
 */

Obj ObjMapKeys(Obj set) {
  UInt len = ADDR_WORD(set)[OBJSET_USED];
  UInt size = ADDR_WORD(set)[OBJSET_SIZE];
  UInt p, i;
  Obj result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  for (i=0, p=1; i < size; i++) {
    Obj el = ADDR_OBJ(set)[OBJSET_HDRSIZE + 2*i];
    if (el && el != Undefined) {
      SET_ELM_PLIST(result, p, el);
      p++;
    }
  }
  GAP_ASSERT(p == len + 1);
  CHANGED_BAG(result);
  return result;
}



/**
 *  `ResizeObjMap()`
 *  ----------------
 *
 *  Resizes `map` so that it contains `2^bits` entries.
 *
 *  Precondition: The number of entries in `map` must be less than `2^bits`.
 */

static void ResizeObjMap(Obj map, UInt bits) {
  UInt i, new_size = (1 << bits);
  UInt size = ADDR_WORD(map)[OBJSET_SIZE];
  GAP_ASSERT(new_size >= size);
  Obj new = NewBag(T_OBJMAP,
    (OBJSET_HDRSIZE+2*new_size)*sizeof(Bag));
  ADDR_WORD(new)[OBJSET_SIZE] = new_size;
  ADDR_WORD(new)[OBJSET_BITS] = bits;
  ADDR_WORD(new)[OBJSET_USED] = 0;
  ADDR_WORD(new)[OBJSET_DIRTY] = 0;
  for (i = 0; i < size; i++) {
    Obj obj = ADDR_OBJ(map)[OBJSET_HDRSIZE+i*2];
    if (obj && obj != Undefined) {
      AddObjMapNew(new, obj,
        ADDR_OBJ(map)[OBJSET_HDRSIZE+i*2+1]);
    }
  }
  SwapMasterPoint(map, new);
  CHANGED_BAG(map);
  CHANGED_BAG(new);
}

/**
 *  `FuncOBJ_SET()`
 *  ---------------
 *
 *  GAP function to create a new object set.
 *
 *  It takes an optional argument that must be a list containing the elements
 *  of the new set. If no argument is provided, an empty set is created.
 */

static Obj FuncOBJ_SET(Obj self, Obj arg) {
  Obj result;
  Obj list;
  UInt i, len;
  switch (LEN_PLIST(arg)) {
    case 0:
      return NewObjSet();
    case 1:
      list = ELM_PLIST(arg, 1);
      if (!IS_LIST(list))
        ErrorQuit("OBJ_SET: Argument must be a list", 0L, 0L);
      result = NewObjSet();
      len = LEN_LIST(list);
      for (i = 1; i <= len; i++) {
        Obj obj = ELM_LIST(list, i);
        if (obj)
          AddObjSet(result, obj);
      }
      CHANGED_BAG(result);
      return result;
    default:
      ErrorQuit("OBJ_SET: Too many arguments", 0L, 0L);
      return (Obj) 0; /* flow control hint */
  }
}

/**
 *  `CheckArgument()`
 *  -----------------
 *
 *  Utility function to check that an argument is an object set
 *  or map. The parameters `t1` and `t2` are allowed TNUMs, usually
 *  the mutable and immutable version. The parameter `t2` can also
 *  be negative if only one `tnum` is allowed. In this case, `t1`
 *  must be the mutable version.
 */

static void CheckArgument(char *func, Obj obj, Int t1, Int t2) {
  Int tnum = TNUM_OBJ(obj);
  if (t2 < 0 && tnum == t1+IMMUTABLE) {
    ErrorQuit("%s: First argument must be a mutable %s",
      (Int) func,
      (Int) InfoBags[t1].name);
  }
  if (tnum != t1 && tnum != t2) {
    ErrorQuit("%s: First argument must be an %s",
      (Int) func,
      (Int) InfoBags[t1].name);
  }
}

/**
 *  `FuncADD_OBJ_SET()`
 *  -------------------
 *
 *  GAP function to add `obj` to `set`.
 */

static Obj FuncADD_OBJ_SET(Obj self, Obj set, Obj obj) {
  CheckArgument("ADD_OBJ_SET", set, T_OBJSET, -1);
  AddObjSet(set, obj);
  return (Obj) 0;
}

/**
 *  `FuncREMOVE_OBJ_SET()`
 *  ----------------------
 *
 *  GAP function to remove `obj` from `set`.
 */

static Obj FuncREMOVE_OBJ_SET(Obj self, Obj set, Obj obj) {
  CheckArgument("REMOVE_OBJ_SET", set, T_OBJSET, -1);
  RemoveObjSet(set, obj);
  return (Obj) 0;
}

/**
 *  `FuncFIND_OBJ_SET()`
 *  ----------------------
 *
 *  GAP function to test if `obj` is contained in `set`. Returns `true` or
 *  `false`.
 */

static Obj FuncFIND_OBJ_SET(Obj self, Obj set, Obj obj) {
  Int pos;
  CheckArgument("FIND_OBJ_SET", set, T_OBJSET, T_OBJSET+IMMUTABLE);
  pos = FindObjSet(set, obj);
  return pos >= 0 ? True : False;
}

/**
 *  `FuncCLEAR_OBJ_SET()`
 *  ---------------------
 *
 *  GAP function to remove all objects from `set`.
 */

static Obj FuncCLEAR_OBJ_SET(Obj self, Obj set) {
  CheckArgument("CLEAR_OBJ_SET", set, T_OBJSET, -1);
  ClearObjSet(set);
  return (Obj) 0;
}

/**
 *  `FuncOBJ_SET_VALUES()`
 *  ---------------------
 *
 *  GAP function to return values in set as a list.
 */

static Obj FuncOBJ_SET_VALUES(Obj self, Obj set) {
  CheckArgument("OBJ_SET_VALUES", set, T_OBJSET, -1);
  return ObjSetValues(set);
}

/**
 *  `FuncOBJ_MAP()`
 *  ---------------
 *
 *  GAP function to create a new object map.
 *
 *  It takes an optional argument that must be a list containing the
 *  keys and values for the new map. Keys and values must alternate and
 *  there must be an equal number of keys and values. If no argument is
 *  provided, an empty map is created.
 */

static Obj FuncOBJ_MAP(Obj self, Obj arg) {
  Obj result;
  Obj list;
  UInt i, len;
  switch (LEN_PLIST(arg)) {
    case 0:
      return NewObjMap();
    case 1:
      list = ELM_PLIST(arg, 1);
      if (!IS_LIST(list) || LEN_LIST(list) % 2 != 0)
        ErrorQuit("OBJ_MAP: Argument must be a list with even length", 0L, 0L);
      result = NewObjMap();
      len = LEN_LIST(list);
      for (i = 1; i <= len; i += 2) {
        Obj key = ELM_LIST(list, i);
        Obj value = ELM_LIST(list, i+1);
        if (key && value)
          AddObjMap(result, key, value);
      }
      return result;
    default:
      ErrorQuit("OBJ_MAP: Too many arguments", 0L, 0L);
      return (Obj) 0; /* flow control hint */
  }
}

/**
 *  `FuncADD_OBJ_MAP()`
 *  -------------------
 *
 *  GAP function to add a (key, value) pair to an object map.
 */

static Obj FuncADD_OBJ_MAP(Obj self, Obj map, Obj key, Obj value) {
  CheckArgument("ADD_OBJ_MAP", map, T_OBJMAP, -1);
  AddObjMap(map, key, value);
  return (Obj) 0;
}

/**
 *  `FuncFIND_OBJ_MAP()`
 *  --------------------
 *
 *  GAP function to locate an entry with key `key` within `map`. The
 *  function returns the corresponding value if found and `defvalue`
 *  otherwise.
 */

static Obj FuncFIND_OBJ_MAP(Obj self, Obj map, Obj key, Obj defvalue) {
  Int pos;
  CheckArgument("FIND_OBJ_MAP", map, T_OBJMAP, T_OBJMAP+IMMUTABLE);
  pos = FindObjMap(map, key);
  if (pos < 0)
    return defvalue;
  return ADDR_OBJ(map)[OBJSET_HDRSIZE + 2 * pos + 1];
}

/**
 *  `FuncCONTAINS_OBJ_MAP()`
 *  ------------------------
 *
 *  GAP function to locate an entry with key `key` within `map`. The
 *  function returns true if such an entry exists, false otherwise.
 */

static Obj FuncCONTAINS_OBJ_MAP(Obj self, Obj map, Obj key, Obj defvalue) {
  Int pos;
  CheckArgument("FIND_OBJ_MAP", map, T_OBJMAP, T_OBJMAP+IMMUTABLE);
  pos = FindObjMap(map, key);
  return pos >= 0 ? True : False;
}

/**
 *  `FuncREMOVE_OBJ_MAP()`
 *  ----------------------
 *
 *  GAP function to remove the entry with key `key` from `map` if it
 *  exists.
 */

static Obj FuncREMOVE_OBJ_MAP(Obj self, Obj map, Obj key) {
  CheckArgument("REMOVE_OBJ_MAP", map, T_OBJMAP, -1);
  RemoveObjMap(map, key);
  return (Obj) 0;
}

/**
 *  `FuncCLEAR_OBJ_MAP()`
 *  ---------------------
 *
 *  GAP function to remove all objects from `map`.
 */

static Obj FuncCLEAR_OBJ_MAP(Obj self, Obj map) {
  CheckArgument("CLEAR_OBJ_MAP", map, T_OBJMAP, -1);
  ClearObjMap(map);
  return (Obj) 0;
}

/**
 *  `FuncOBJ_MAP_VALUES()`
 *  ---------------------
 *
 *  GAP function to return values in set as a list.
 */

static Obj FuncOBJ_MAP_VALUES(Obj self, Obj map) {
  CheckArgument("OBJ_MAP_VALUES", map, T_OBJMAP, -1);
  return ObjMapValues(map);
}


/**
 *  `FuncOBJ_MAP_KEYS()`
 *  ---------------------
 *
 *  GAP function to return keys in set as a list.
 */

static Obj FuncOBJ_MAP_KEYS(Obj self, Obj map) {
  CheckArgument("OBJ_MAP_KEYS", map, T_OBJMAP, -1);
  return ObjMapKeys(map);
}


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/

static StructGVarFunc GVarFuncs [] = {

    { "OBJ_SET", -1, "[list]",
      FuncOBJ_SET, "src/objset.c:OBJ_SET" },

    { "ADD_OBJ_SET", 2, "objset, obj",
      FuncADD_OBJ_SET, "src/objset.c:ADD_OBJ_SET" },

    { "REMOVE_OBJ_SET", 2, "objset, obj",
      FuncREMOVE_OBJ_SET, "src/objset.c:REMOVE_OBJ_SET" },

    { "FIND_OBJ_SET", 2, "objset, obj",
      FuncFIND_OBJ_SET, "src/objset.c:FIND_OBJ_SET" },

    { "CLEAR_OBJ_SET", 1, "objset",
      FuncCLEAR_OBJ_SET, "src/objset.c:CLEAR_OBJ_SET" },

    { "OBJ_SET_VALUES", 1, "objset",
      FuncOBJ_SET_VALUES, "src/objset.c:OBJ_SET_VALUES" },

    { "OBJ_MAP", -1, "[list]",
      FuncOBJ_MAP, "src/objset.c:OBJ_MAP" },

    { "ADD_OBJ_MAP", 3, "objmap, key, value",
      FuncADD_OBJ_MAP, "src/objset.c:ADD_OBJ_MAP" },

    { "REMOVE_OBJ_MAP", 2, "objmap, obj",
      FuncREMOVE_OBJ_MAP, "src/objset.c:REMOVE_OBJ_MAP" },

    { "FIND_OBJ_MAP", 3, "objmap, obj, default",
      FuncFIND_OBJ_MAP, "src/objset.c:FIND_OBJ_MAP" },

    { "CONTAINS_OBJ_MAP", 2, "objmap, obj",
      FuncCONTAINS_OBJ_MAP, "src/objset.c:CONTAINS_OBJ_MAP" },

    { "CLEAR_OBJ_MAP", 1, "objmap",
      FuncCLEAR_OBJ_MAP, "src/objset.c:CLEAR_OBJ_MAP" },

    { "OBJ_MAP_VALUES", 1, "objmap",
      FuncOBJ_MAP_VALUES, "src/objset.c:OBJ_MAP_VALUES" },

    { "OBJ_MAP_KEYS", 1, "objmap",
      FuncOBJ_MAP_KEYS, "src/objset.c:OBJ_MAP_KEYS" },

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  /* install info string */
  InfoBags[T_OBJSET].name = "object set";
  InfoBags[T_OBJSET+IMMUTABLE].name = "immutable object set";
  InfoBags[T_OBJMAP].name = "object map";
  InfoBags[T_OBJMAP+IMMUTABLE].name = "immutable object map";
  /* install kind functions */
  TypeObjFuncs[T_OBJSET] = TypeObjSet;
  TypeObjFuncs[T_OBJSET+IMMUTABLE] = TypeObjSet;
  TypeObjFuncs[T_OBJMAP] = TypeObjMap;
  TypeObjFuncs[T_OBJMAP+IMMUTABLE] = TypeObjMap;
  /* install global variables */
  InitCopyGVar("TYPE_OBJSET", &TYPE_OBJSET);
  InitCopyGVar("TYPE_OBJMAP", &TYPE_OBJMAP);
  /* install mark functions */
  InitMarkFuncBags(T_OBJSET, MarkObjSet);
  InitMarkFuncBags(T_OBJMAP, MarkObjMap);
  InitMarkFuncBags(T_OBJSET+IMMUTABLE, MarkObjSet);
  InitMarkFuncBags(T_OBJMAP+IMMUTABLE, MarkObjMap);
  /* install print functions */
  PrintObjFuncs[ T_OBJSET ] = PrintObjSet;
  PrintObjFuncs[ T_OBJSET+IMMUTABLE ] = PrintObjSet;
  PrintObjFuncs[ T_OBJMAP ] = PrintObjMap;
  PrintObjFuncs[ T_OBJMAP+IMMUTABLE ] = PrintObjMap;
  /* install mutability functions */
  IsMutableObjFuncs [ T_OBJSET ] = AlwaysYes;
  IsMutableObjFuncs [ T_OBJSET+IMMUTABLE ] = AlwaysNo;
  IsMutableObjFuncs [ T_OBJMAP ] = AlwaysYes;
  IsMutableObjFuncs [ T_OBJMAP+IMMUTABLE ] = AlwaysNo;
  // init filters and functions
  InitHdlrFuncsFromTable( GVarFuncs );
  /* return success                                                      */
  return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  InitInfoObjSet() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "objset",                           /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoObjSets ( void )
{
    return &module;
}
