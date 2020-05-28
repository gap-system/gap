/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the GAP interface for thread primitives.
*/

#include "objset.h"

#include "bool.h"
#include "error.h"
#include "fibhash.h"
#include "gaputils.h"
#include "gvars.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "saveload.h"

#ifdef HPCGAP
#include "hpc/traverse.h"
#endif

static Obj TYPE_OBJSET;
static Obj TYPE_OBJMAP;

static Obj TypeObjSet(Obj obj)
{
    return TYPE_OBJSET;
}

static Obj TypeObjMap(Obj obj)
{
    return TYPE_OBJMAP;
}

static inline BOOL IS_OBJSET(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    return tnum == T_OBJSET || tnum == T_OBJSET + IMMUTABLE;
}

static inline BOOL IS_OBJMAP(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    return tnum == T_OBJMAP || tnum == T_OBJMAP + IMMUTABLE;
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
#define CONST_ADDR_WORD(obj) ((const UInt *)(CONST_ADDR_OBJ(obj)))

/**
 *  Functions to print object maps and sets
 *  ---------------------------------------
 */

static void PrintObjSet(Obj set)
{
  UInt i, size = CONST_ADDR_WORD(set)[OBJSET_SIZE];
  Int comma = 0;
  Pr("OBJ_SET([ ", 0, 0);
  for (i=0; i < size; i++) {
    Obj obj = CONST_ADDR_OBJ(set)[OBJSET_HDRSIZE + i ];
    if (obj && obj != Undefined) {
      if (comma) {
        Pr(", ", 0, 0);
      } else {
        comma = 1;
      }
      PrintObj(obj);
    }
  }
  Pr(" ])", 0, 0);
}

static void PrintObjMap(Obj map)
{
  UInt i, size = CONST_ADDR_WORD(map)[OBJSET_SIZE];
  Int comma = 0;
  Pr("OBJ_MAP([ ", 0, 0);
  for (i=0; i < size; i++) {
    Obj obj = CONST_ADDR_OBJ(map)[OBJSET_HDRSIZE + i * 2 ];
    if (obj && obj != Undefined) {
      if (comma) {
        Pr(", ", 0, 0);
      } else {
        comma = 1;
      }
      PrintObj(obj);
      Pr(", ", 0, 0);
      PrintObj(CONST_ADDR_OBJ(map)[OBJSET_HDRSIZE + i * 2 + 1]);
    }
  }
  Pr(" ])", 0, 0);
}

/**
 *  Garbage collector support for object maps and sets
 *  --------------------------------------------------
 *
 *  These functions are not yet implemented.
 */

static void MarkObjSet(Obj obj)
{
  UInt size = CONST_ADDR_WORD(obj)[OBJSET_SIZE];
  MarkArrayOfBags( ADDR_OBJ(obj) + OBJSET_HDRSIZE, size );
}

static void MarkObjMap(Obj obj)
{
  UInt size = CONST_ADDR_WORD(obj)[OBJSET_SIZE];
  MarkArrayOfBags( ADDR_OBJ(obj) + OBJSET_HDRSIZE, 2 * size );
}

/**
 *  The primary hash function
 *  -------------------------
 *
 *  Hashing is done using Fibonacci hashing (Knuth) modulo the
 *  size of the table.
 */


static inline UInt ObjHash(Obj set, Obj obj)
{
  return FibHash((UInt) obj, CONST_ADDR_WORD(set)[OBJSET_BITS]);
}


/**
 *  `NewObjSet()`
 *  -------------
 *
 *  Create and return a new object set.
 */

Obj NewObjSet(void) {
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

static void CheckObjSetForCleanUp(Obj set, UInt expand)
{
  UInt size = CONST_ADDR_WORD(set)[OBJSET_SIZE];
  UInt bits = CONST_ADDR_WORD(set)[OBJSET_BITS];
  UInt used = CONST_ADDR_WORD(set)[OBJSET_USED] + expand;
  UInt dirty = CONST_ADDR_WORD(set)[OBJSET_DIRTY];
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
  GAP_ASSERT(IS_OBJSET(set));
  UInt size = CONST_ADDR_WORD(set)[OBJSET_SIZE];
  UInt hash = ObjHash(set, obj);
  GAP_ASSERT(hash < size);
  for (;;) {
    Obj current;
    current = CONST_ADDR_OBJ(set)[OBJSET_HDRSIZE+hash];
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

static void AddObjSetNew(Obj set, Obj obj)
{
  UInt size = CONST_ADDR_WORD(set)[OBJSET_SIZE];
  UInt hash = ObjHash(set, obj);
  GAP_ASSERT(TNUM_OBJ(set) == T_OBJSET);
  GAP_ASSERT(hash < size);
  for (;;) {
    Obj current;
    current = CONST_ADDR_OBJ(set)[OBJSET_HDRSIZE+hash];
    if (!current) {
      ADDR_OBJ(set)[OBJSET_HDRSIZE+hash] = obj;
      ADDR_WORD(set)[OBJSET_USED]++;
      CHANGED_BAG(set);
      return;
    }
    if (current == Undefined) {
      ADDR_OBJ(set)[OBJSET_HDRSIZE+hash] = obj;
      ADDR_WORD(set)[OBJSET_USED]++;
      GAP_ASSERT(ADDR_WORD(set)[OBJSET_DIRTY] >= 1);
      ADDR_WORD(set)[OBJSET_DIRTY]--;
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
  GAP_ASSERT(TNUM_OBJ(set) == T_OBJSET);
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
  GAP_ASSERT(TNUM_OBJ(set) == T_OBJSET);
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
  GAP_ASSERT(TNUM_OBJ(set) == T_OBJSET);
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
  GAP_ASSERT(IS_OBJSET(set));
  UInt len = CONST_ADDR_WORD(set)[OBJSET_USED];
  UInt size = CONST_ADDR_WORD(set)[OBJSET_SIZE];
  UInt p, i;
  Obj result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  for (i=0, p=1; i < size; i++) {
    Obj el = CONST_ADDR_OBJ(set)[OBJSET_HDRSIZE + i];
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

static void ResizeObjSet(Obj set, UInt bits)
{
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

#ifdef GAP_ENABLE_SAVELOAD
static void SaveObjSet(Obj set)
{
    UInt size = ADDR_WORD(set)[OBJSET_SIZE];
    UInt bits = ADDR_WORD(set)[OBJSET_BITS];
    UInt used = ADDR_WORD(set)[OBJSET_USED];
    SaveUInt(size);
    SaveUInt(bits);
    SaveUInt(used);
    for (UInt i = 0; i < size; i++) {
        Obj val = ADDR_OBJ(set)[OBJSET_HDRSIZE + i];
        if (!val || val == Undefined)
            continue;
        SaveSubObj(val);
    }
}

static void LoadObjSet(Obj set)
{
    UInt size = LoadUInt();
    UInt bits = LoadUInt();
    UInt used = LoadUInt();

    ADDR_WORD(set)[OBJSET_SIZE] = size;
    ADDR_WORD(set)[OBJSET_BITS] = bits;
    ADDR_WORD(set)[OBJSET_USED] = 0;
    ADDR_WORD(set)[OBJSET_DIRTY] = 0;

    for (UInt i = 1; i <= used; i++) {
        Obj val = LoadSubObj();
        AddObjSetNew(set, val);
    }
}
#endif


#ifdef USE_THREADSAFE_COPYING
#ifndef WARD_ENABLED
static void TraverseObjSet(TraversalState * traversal, Obj obj)
{
    UInt i, len = *(UInt *)(CONST_ADDR_OBJ(obj) + OBJSET_SIZE);
    for (i = 0; i < len; i++) {
        Obj item = CONST_ADDR_OBJ(obj)[OBJSET_HDRSIZE + i];
        if (item && item != Undefined)
            QueueForTraversal(traversal, item);
    }
}

static void CopyObjSet(TraversalState * traversal, Obj copy, Obj original)
{
    UInt i, len = *(UInt *)(CONST_ADDR_OBJ(original) + OBJSET_SIZE);
    for (i = 0; i < len; i++) {
        Obj item = CONST_ADDR_OBJ(original)[OBJSET_HDRSIZE + i];
        ADDR_OBJ(copy)[OBJSET_HDRSIZE + i] = ReplaceByCopy(traversal, item);
    }
}
#endif // WARD_ENABLED
#endif


/**
 *  `NewObjMap()`
 *  -------------
 *
 *  Create a new object map.
 */

Obj NewObjMap(void) {
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

static void CheckObjMapForCleanUp(Obj map, UInt expand)
{
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
  GAP_ASSERT(IS_OBJMAP(map));
  UInt size = CONST_ADDR_WORD(map)[OBJSET_SIZE];
  UInt hash = ObjHash(map, obj);
  for (;;) {
    Obj current;
    current = CONST_ADDR_OBJ(map)[OBJSET_HDRSIZE+hash*2];
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
  return CONST_ADDR_OBJ(map)[OBJSET_HDRSIZE+index*2+1];
}

/**
 *  `AddObjMapNew()`
 *  ----------------
 *
 *  Add an entry `(key, value)` to `map`.
 *  
 *  Precondition: No other entry with key `key` exists within `map`.
 */

static void AddObjMapNew(Obj map, Obj key, Obj value)
{
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
  GAP_ASSERT(TNUM_OBJ(map) == T_OBJMAP);
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
  GAP_ASSERT(TNUM_OBJ(map) == T_OBJMAP);
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
  GAP_ASSERT(TNUM_OBJ(map) == T_OBJMAP);
  Obj new = NewObjMap();
  SwapMasterPoint(map, new);
}

/**
 *  `ObjMapValues()`
 *  ---------------
 *
 *  This function returns all values from the map.
 */

Obj ObjMapValues(Obj map)
{
  GAP_ASSERT(IS_OBJMAP(map));
  UInt len = CONST_ADDR_WORD(map)[OBJSET_USED];
  UInt size = CONST_ADDR_WORD(map)[OBJSET_SIZE];
  UInt p, i;
  Obj result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  for (i=0, p=1; i < size; i++) {
    Obj el = CONST_ADDR_OBJ(map)[OBJSET_HDRSIZE + 2*i+1];
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

Obj ObjMapKeys(Obj map)
{
  GAP_ASSERT(IS_OBJMAP(map));
  UInt len = CONST_ADDR_WORD(map)[OBJSET_USED];
  UInt size = CONST_ADDR_WORD(map)[OBJSET_SIZE];
  UInt p, i;
  Obj result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  for (i=0, p=1; i < size; i++) {
    Obj el = CONST_ADDR_OBJ(map)[OBJSET_HDRSIZE + 2*i];
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

static void ResizeObjMap(Obj map, UInt bits)
{
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

#ifdef GAP_ENABLE_SAVELOAD
static void SaveObjMap(Obj map)
{
    UInt size = ADDR_WORD(map)[OBJSET_SIZE];
    UInt bits = ADDR_WORD(map)[OBJSET_BITS];
    UInt used = ADDR_WORD(map)[OBJSET_USED];
    SaveUInt(size);
    SaveUInt(bits);
    SaveUInt(used);
    for (UInt i = 0; i < size; i++) {
        Obj key = ADDR_OBJ(map)[OBJSET_HDRSIZE + 2 * i];
        Obj val = ADDR_OBJ(map)[OBJSET_HDRSIZE + 2 * i + 1];
        if (!key || key == Undefined)
            continue;
        SaveSubObj(key);
        SaveSubObj(val);
    }
}

static void LoadObjMap(Obj map)
{
    UInt size = LoadUInt();
    UInt bits = LoadUInt();
    UInt used = LoadUInt();

    ADDR_WORD(map)[OBJSET_SIZE] = size;
    ADDR_WORD(map)[OBJSET_BITS] = bits;
    ADDR_WORD(map)[OBJSET_USED] = 0;
    ADDR_WORD(map)[OBJSET_DIRTY] = 0;

    for (UInt i = 1; i <= used; i++) {
        Obj key = LoadSubObj();
        Obj val = LoadSubObj();
        AddObjMapNew(map, key, val);
    }
}
#endif

#ifdef USE_THREADSAFE_COPYING
#ifndef WARD_ENABLED
static void TraverseObjMap(TraversalState * traversal, Obj obj)
{
    UInt i, len = *(UInt *)(CONST_ADDR_OBJ(obj) + OBJSET_SIZE);
    for (i = 0; i < len; i++) {
        Obj key = CONST_ADDR_OBJ(obj)[OBJSET_HDRSIZE + 2 * i];
        Obj val = CONST_ADDR_OBJ(obj)[OBJSET_HDRSIZE + 2 * i + 1];
        if (key && key != Undefined) {
            QueueForTraversal(traversal, key);
            QueueForTraversal(traversal, val);
        }
    }
}

static void CopyObjMap(TraversalState * traversal, Obj copy, Obj original)
{
    UInt i, len = *(UInt *)(CONST_ADDR_OBJ(original) + OBJSET_SIZE);
    for (i = 0; i < len; i++) {
        Obj key = CONST_ADDR_OBJ(original)[OBJSET_HDRSIZE + 2 * i];
        Obj val = CONST_ADDR_OBJ(original)[OBJSET_HDRSIZE + 2 * i + 1];
        ADDR_OBJ(copy)[OBJSET_HDRSIZE + 2 * i] = ReplaceByCopy(traversal, key);
        ADDR_OBJ(copy)[OBJSET_HDRSIZE + 2 * i + 1] = ReplaceByCopy(traversal, val);
    }
}
#endif
#endif

/**
 *  `FuncOBJ_SET()`
 *  ---------------
 *
 *  GAP function to create a new object set.
 *
 *  It takes an optional argument that must be a list containing the elements
 *  of the new set. If no argument is provided, an empty set is created.
 */

static Obj FuncOBJ_SET(Obj self, Obj arg)
{
  Obj result;
  Obj list;
  UInt i, len;
  switch (LEN_PLIST(arg)) {
    case 0:
      return NewObjSet();
    case 1:
      list = ELM_PLIST(arg, 1);
      if (!IS_LIST(list))
        ErrorQuit("OBJ_SET: Argument must be a list", 0, 0);
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
      ErrorQuit("OBJ_SET: Too many arguments", 0, 0);
      return (Obj) 0; /* flow control hint */
  }
}

/**
 *  `FuncADD_OBJ_SET()`
 *  -------------------
 *
 *  GAP function to add `obj` to `set`.
 */

static Obj FuncADD_OBJ_SET(Obj self, Obj set, Obj obj)
{
    RequireArgumentCondition(SELF_NAME, set, TNUM_OBJ(set) == T_OBJSET,
                             "must be a mutable object set");

    AddObjSet(set, obj);
    return 0;
}

/**
 *  `FuncREMOVE_OBJ_SET()`
 *  ----------------------
 *
 *  GAP function to remove `obj` from `set`.
 */

static Obj FuncREMOVE_OBJ_SET(Obj self, Obj set, Obj obj)
{
    RequireArgumentCondition(SELF_NAME, set, TNUM_OBJ(set) == T_OBJSET,
                             "must be a mutable object set");

    RemoveObjSet(set, obj);
    return 0;
}

/**
 *  `FuncFIND_OBJ_SET()`
 *  ----------------------
 *
 *  GAP function to test if `obj` is contained in `set`. Returns `true` or
 *  `false`.
 */

static Obj FuncFIND_OBJ_SET(Obj self, Obj set, Obj obj)
{
    RequireArgumentCondition(SELF_NAME, set, IS_OBJSET(set),
                             "must be an object set");

    Int pos = FindObjSet(set, obj);
    return pos >= 0 ? True : False;
}

/**
 *  `FuncCLEAR_OBJ_SET()`
 *  ---------------------
 *
 *  GAP function to remove all objects from `set`.
 */

static Obj FuncCLEAR_OBJ_SET(Obj self, Obj set)
{
    RequireArgumentCondition(SELF_NAME, set, TNUM_OBJ(set) == T_OBJSET,
                             "must be a mutable object set");

    ClearObjSet(set);
    return 0;
}

/**
 *  `FuncOBJ_SET_VALUES()`
 *  ---------------------
 *
 *  GAP function to return values in set as a list.
 */

static Obj FuncOBJ_SET_VALUES(Obj self, Obj set)
{
    RequireArgumentCondition(SELF_NAME, set, IS_OBJSET(set),
                             "must be an object set");

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

static Obj FuncOBJ_MAP(Obj self, Obj arg)
{
  Obj result;
  Obj list;
  UInt i, len;
  switch (LEN_PLIST(arg)) {
    case 0:
      return NewObjMap();
    case 1:
      list = ELM_PLIST(arg, 1);
      if (!IS_LIST(list) || LEN_LIST(list) % 2 != 0)
        ErrorQuit("OBJ_MAP: Argument must be a list with even length", 0, 0);
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
      ErrorQuit("OBJ_MAP: Too many arguments", 0, 0);
      return (Obj) 0; /* flow control hint */
  }
}

/**
 *  `FuncADD_OBJ_MAP()`
 *  -------------------
 *
 *  GAP function to add a (key, value) pair to an object map.
 */

static Obj FuncADD_OBJ_MAP(Obj self, Obj map, Obj key, Obj value)
{
    RequireArgumentCondition(SELF_NAME, map, TNUM_OBJ(map) == T_OBJMAP,
                             "must be a mutable object map");

    AddObjMap(map, key, value);
    return 0;
}

/**
 *  `FuncFIND_OBJ_MAP()`
 *  --------------------
 *
 *  GAP function to locate an entry with key `key` within `map`. The
 *  function returns the corresponding value if found and `defvalue`
 *  otherwise.
 */

static Obj FuncFIND_OBJ_MAP(Obj self, Obj map, Obj key, Obj defvalue)
{
    RequireArgumentCondition(SELF_NAME, map, IS_OBJMAP(map),
                             "must be an object map");

    Int pos = FindObjMap(map, key);
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

static Obj FuncCONTAINS_OBJ_MAP(Obj self, Obj map, Obj key)
{
    RequireArgumentCondition(SELF_NAME, map, IS_OBJMAP(map),
                             "must be an object map");

    Int pos = FindObjMap(map, key);
    return pos >= 0 ? True : False;
}

/**
 *  `FuncREMOVE_OBJ_MAP()`
 *  ----------------------
 *
 *  GAP function to remove the entry with key `key` from `map` if it
 *  exists.
 */

static Obj FuncREMOVE_OBJ_MAP(Obj self, Obj map, Obj key)
{
    RequireArgumentCondition(SELF_NAME, map, TNUM_OBJ(map) == T_OBJMAP,
                             "must be a mutable object map");

    RemoveObjMap(map, key);
    return 0;
}

/**
 *  `FuncCLEAR_OBJ_MAP()`
 *  ---------------------
 *
 *  GAP function to remove all objects from `map`.
 */

static Obj FuncCLEAR_OBJ_MAP(Obj self, Obj map)
{
    RequireArgumentCondition(SELF_NAME, map, TNUM_OBJ(map) == T_OBJMAP,
                             "must be a mutable object map");

    ClearObjMap(map);
    return 0;
}

/**
 *  `FuncOBJ_MAP_VALUES()`
 *  ---------------------
 *
 *  GAP function to return values in set as a list.
 */

static Obj FuncOBJ_MAP_VALUES(Obj self, Obj map)
{
    RequireArgumentCondition(SELF_NAME, map, IS_OBJMAP(map),
                             "must be an object map");

    return ObjMapValues(map);
}


/**
 *  `FuncOBJ_MAP_KEYS()`
 *  ---------------------
 *
 *  GAP function to return keys in set as a list.
 */

static Obj FuncOBJ_MAP_KEYS(Obj self, Obj map)
{
    RequireArgumentCondition(SELF_NAME, map, IS_OBJMAP(map),
                             "must be an object map");

    return ObjMapKeys(map);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_OBJSET          , "object set" },
  { T_OBJSET+IMMUTABLE, "immutable object set" },
  { T_OBJMAP          , "object map" },
  { T_OBJMAP+IMMUTABLE, "immutable object map" },
  { -1, "" }
};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC(OBJ_SET, -1, "[list]"),
    GVAR_FUNC_2ARGS(ADD_OBJ_SET, set, obj),
    GVAR_FUNC_2ARGS(REMOVE_OBJ_SET, set, obj),
    GVAR_FUNC_2ARGS(FIND_OBJ_SET, set, obj),
    GVAR_FUNC_1ARGS(CLEAR_OBJ_SET, set),
    GVAR_FUNC_1ARGS(OBJ_SET_VALUES, set),
    GVAR_FUNC(OBJ_MAP, -1, "[list]"),
    GVAR_FUNC_3ARGS(ADD_OBJ_MAP, map, key, value),
    GVAR_FUNC_2ARGS(REMOVE_OBJ_MAP, map, obj),
    GVAR_FUNC_3ARGS(FIND_OBJ_MAP, map, obj, default),
    GVAR_FUNC_2ARGS(CONTAINS_OBJ_MAP, map, obj),
    GVAR_FUNC_1ARGS(CLEAR_OBJ_MAP, map),
    GVAR_FUNC_1ARGS(OBJ_MAP_VALUES, map),
    GVAR_FUNC_1ARGS(OBJ_MAP_KEYS, map),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  // set the bag type names (for error messages and debugging)
  InitBagNamesFromTable( BagNames );

  /* install kind functions */
  TypeObjFuncs[T_OBJSET          ] = TypeObjSet;
  TypeObjFuncs[T_OBJSET+IMMUTABLE] = TypeObjSet;
  TypeObjFuncs[T_OBJMAP          ] = TypeObjMap;
  TypeObjFuncs[T_OBJMAP+IMMUTABLE] = TypeObjMap;
  /* install global variables */
  InitCopyGVar("TYPE_OBJSET", &TYPE_OBJSET);
  InitCopyGVar("TYPE_OBJMAP", &TYPE_OBJMAP);
  /* install mark functions */
  InitMarkFuncBags(T_OBJSET          , MarkObjSet);
  InitMarkFuncBags(T_OBJSET+IMMUTABLE, MarkObjSet);
  InitMarkFuncBags(T_OBJMAP          , MarkObjMap);
  InitMarkFuncBags(T_OBJMAP+IMMUTABLE, MarkObjMap);
  /* install print functions */
  PrintObjFuncs[ T_OBJSET           ] = PrintObjSet;
  PrintObjFuncs[ T_OBJSET+IMMUTABLE ] = PrintObjSet;
  PrintObjFuncs[ T_OBJMAP           ] = PrintObjMap;
  PrintObjFuncs[ T_OBJMAP+IMMUTABLE ] = PrintObjMap;

#ifdef USE_THREADSAFE_COPYING
  SetTraversalMethod(T_OBJSET, TRAVERSE_BY_FUNCTION, TraverseObjSet, CopyObjSet);
  SetTraversalMethod(T_OBJMAP, TRAVERSE_BY_FUNCTION, TraverseObjMap, CopyObjMap);
#endif

#ifdef GAP_ENABLE_SAVELOAD
  // Install saving functions
  SaveObjFuncs[ T_OBJSET            ] = SaveObjSet;
  SaveObjFuncs[ T_OBJSET +IMMUTABLE ] = SaveObjSet;
  SaveObjFuncs[ T_OBJMAP            ] = SaveObjMap;
  SaveObjFuncs[ T_OBJMAP +IMMUTABLE ] = SaveObjMap;

  LoadObjFuncs[ T_OBJSET            ] = LoadObjSet;
  LoadObjFuncs[ T_OBJSET +IMMUTABLE ] = LoadObjSet;
  LoadObjFuncs[ T_OBJMAP            ] = LoadObjMap;
  LoadObjFuncs[ T_OBJMAP +IMMUTABLE ] = LoadObjMap;
#endif

  // init filters and functions
  InitHdlrFuncsFromTable( GVarFuncs );
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

    return 0;
}

/****************************************************************************
**
*F  InitInfoObjSet() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "objset",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoObjSets ( void )
{
    return &module;
}
