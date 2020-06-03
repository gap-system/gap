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

#include "hpc/aobjects.h"

#include "hpc/guards.h"
#include "hpc/thread.h"
#include "hpc/traverse.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "error.h"
#include "fibhash.h"
#include "gaputils.h"
#include "gvars.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "objects.h"
#include "plist.h"
#include "precord.h"
#include "records.h"
#include "stringobj.h"

#include <stdlib.h>


static Obj TYPE_ALIST;
static Obj TYPE_AREC;
static Obj TYPE_TLREC;

#define ALIST_LEN(x) ((x) >> 2)
#define ALIST_POL(x) ((x) & 3)
#define CHANGE_ALIST_LEN(x, y) (((x) & 3) | ((y) << 2))
#define CHANGE_ALIST_POL(x, y) (((x) & ~3) | y)

typedef enum  {
    ALIST_RW = 0,
    ALIST_W1 = 1,
    ALIST_WX = 2,
} AtomicListPolicy;

typedef enum {
    AREC_RW = 1,
    AREC_W1 = 0,
    AREC_WX = -1,
} AtomicRecordPolicy;

typedef union AtomicObj
{
  AtomicUInt atom;
  Obj obj;
} AtomicObj;

#define ADDR_ATOM(bag) ((AtomicObj *)(ADDR_OBJ(bag)))
#define CONST_ADDR_ATOM(bag) ((const AtomicObj *)(CONST_ADDR_OBJ(bag)))

#ifndef WARD_ENABLED

static UInt UsageCap[sizeof(UInt)*8];

static Obj TypeAList(Obj obj)
{
  Obj result;
  const Obj *addr = CONST_ADDR_OBJ(obj);
  MEMBAR_READ();
  result = addr[1];
  return result != NULL ? result : TYPE_ALIST;
}

static Obj TypeARecord(Obj obj)
{
  Obj result;
  MEMBAR_READ();
  result = CONST_ADDR_OBJ(obj)[0];
  return result != NULL ? result : TYPE_AREC;
}

static Obj TypeTLRecord(Obj obj)
{
  return TYPE_TLREC;
}

static void ArgumentError(const char *message)
{
    ErrorQuit(message, 0, 0);
}

Obj NewAtomicList(UInt tnum, UInt capacity)
{
    Obj result = NewBag(tnum, sizeof(AtomicObj) * (capacity + 2));
    MEMBAR_WRITE();
    return result;
}

static Obj NewAtomicListInit(UInt tnum, UInt len, Obj init)
{
    Obj         result = NewAtomicList(tnum, len);
    AtomicObj * data = ADDR_ATOM(result);
    data->atom = CHANGE_ALIST_LEN(ALIST_RW, len);
    for (UInt i = 1; i <= len; i++)
        data[i + 1].obj = init;
    CHANGED_BAG(result);
    MEMBAR_WRITE();    // Should not be necessary, but better be safe.
    return result;
}

static Obj NewAtomicListFrom(UInt tnum, Obj list)
{
    UInt        len = LEN_LIST(list);
    Obj         result = NewAtomicList(tnum, len);
    AtomicObj * data = ADDR_ATOM(result);
    data->atom = CHANGE_ALIST_LEN(ALIST_RW, len);
    for (UInt i = 1; i <= len; i++)
        data[i + 1].obj = ELM0_LIST(list, i);;
    CHANGED_BAG(result);
    MEMBAR_WRITE();    // Should not be necessary, but better be safe.
    return result;
}

static Obj FuncAtomicList(Obj self, Obj args)
{
  Obj init;
  Int len;
  switch (LEN_PLIST(args)) {
  case 0:
      return NewAtomicList(T_ALIST, 0);
  case 1:
      init = ELM_PLIST(args, 1);
      if (IS_LIST(init)) {
          return NewAtomicListFrom(T_ALIST, init);
      }
      else if (IS_INTOBJ(init) && INT_INTOBJ(init) >= 0) {
          len = INT_INTOBJ(init);
          return NewAtomicListInit(T_ALIST, len, 0);
      }
      else {
          ArgumentError(
              "AtomicList: Argument must be list or a non-negative integer");
      }
    case 2:
        init = ELM_PLIST(args, 1);
        len = IS_INTOBJ(init) ? INT_INTOBJ(init) : -1;
        if (len < 0)
            ArgumentError(
                "AtomicList: First argument must be a non-negative integer");
        init = ELM_PLIST(args, 2);
        return NewAtomicListInit(T_ALIST, len, init);
    default:
      ArgumentError("AtomicList: Too many arguments");
  }
  return (Obj)0; /* flow control hint */
}

static Obj FuncFixedAtomicList(Obj self, Obj args)
{
  Obj init;
  Int len;
  switch (LEN_PLIST(args)) {
  case 0:
      return NewAtomicList(T_FIXALIST, 0);
  case 1:
      init = ELM_PLIST(args, 1);
      if (IS_LIST(init)) {
          return NewAtomicListFrom(T_FIXALIST, init);
      }
      else if (IS_INTOBJ(init) && INT_INTOBJ(init) >= 0) {
          len = INT_INTOBJ(init);
          return NewAtomicListInit(T_FIXALIST, len, 0);
      }
      else {
          ArgumentError("FixedAtomicList: Argument must be list or a "
                        "non-negative integer");
      }
    case 2:
        init = ELM_PLIST(args, 1);
        len = IS_INTOBJ(init) ? INT_INTOBJ(init) : -1;
        if (len < 0)
            ArgumentError("FixedAtomicList: First argument must be a "
                          "non-negative integer");
        init = ELM_PLIST(args, 2);
        return NewAtomicListInit(T_FIXALIST, len, init);
    default:
      ArgumentError("FixedAtomicList: Too many arguments");
  }
  return (Obj)0; /* flow control hint */
}

static Obj FuncMakeFixedAtomicList(Obj self, Obj list) {
  switch (TNUM_OBJ(list)) {
    case T_ALIST:
    case T_FIXALIST:
      HashLock(list);
      switch (TNUM_OBJ(list)) {
        case T_ALIST:
        case T_FIXALIST:
          RetypeBag(list, T_FIXALIST);
          HashUnlock(list);
          return list;
        default:
          HashUnlock(list);
          RequireArgument(SELF_NAME, list, "must be an atomic list");
          return (Obj) 0; /* flow control hint */
      }
      HashUnlock(list);
      break;
    default:
      RequireArgument(SELF_NAME, list, "must be an atomic list");
  }
  return (Obj) 0; /* flow control hint */
}

static Obj FuncIS_ATOMIC_RECORD (Obj self, Obj obj) 
{
        return (TNUM_OBJ(obj) == T_AREC) ? True : False;
}

static Obj FuncIS_ATOMIC_LIST (Obj self, Obj obj) 
{
        return (TNUM_OBJ(obj) == T_ALIST) ? True : False;
}

static Obj FuncIS_FIXED_ATOMIC_LIST (Obj self, Obj obj) 
{
        return (TNUM_OBJ(obj) == T_FIXALIST) ? True : False;
}


static Obj FuncGET_ATOMIC_LIST(Obj self, Obj list, Obj index)
{
  UInt n;
  UInt len;
  const AtomicObj *addr;
  if (TNUM_OBJ(list) != T_ALIST && TNUM_OBJ(list) != T_FIXALIST)
    RequireArgument(SELF_NAME, list, "must be an atomic list");
  addr = CONST_ADDR_ATOM(list);
  len = ALIST_LEN((UInt) addr[0].atom);
  n = GetBoundedInt("GET_ATOMIC_LIST", index, 1, len);
  MEMBAR_READ(); /* read barrier */
  return addr[n+1].obj;
}

// If list[index] is bound then return it, else return 'value'.
// The reason this function exists is that it is not thread-safe to
// check if an index in a list is bound before reading it, as it
// could be unbound before the actual reading is performed.
static Obj ElmDefAList(Obj list, Int n, Obj value)
{
    UInt        len;
    const AtomicObj * addr;
    Obj         val;

    GAP_ASSERT(TNUM_OBJ(list) == T_ALIST || TNUM_OBJ(list) == T_FIXALIST);
    GAP_ASSERT(n > 0);
    addr = CONST_ADDR_ATOM(list);
    len = ALIST_LEN((UInt)addr[0].atom);

    if (n <= 0 || n > len) {
        val = 0;
    }
    else {
        MEMBAR_READ();
        val = addr[n + 1].obj;
    }

    if (val == 0) {
        return value;
    }
    else {
        return val;
    }
}

static Obj FuncSET_ATOMIC_LIST(Obj self, Obj list, Obj index, Obj value)
{
  UInt n;
  UInt len;
  AtomicObj *addr;
  if (TNUM_OBJ(list) != T_ALIST && TNUM_OBJ(list) != T_FIXALIST)
    RequireArgument(SELF_NAME, list, "must be an atomic list");
  addr = ADDR_ATOM(list);
  len = ALIST_LEN((UInt) addr[0].atom);
  n = GetBoundedInt("SET_ATOMIC_LIST", index, 1, len);
  addr[n+1].obj = value;
  CHANGED_BAG(list);
  MEMBAR_WRITE(); /* write barrier */
  return (Obj) 0;
}

static Obj AtomicCompareSwapAList(Obj list, Int index, Obj old, Obj new);

// Given atomic list 'list', assign list[index] the value 'new', if list[index]
// is currently assigned 'old'. This operation is performed atomicly.
static Obj FuncCOMPARE_AND_SWAP(Obj self, Obj list, Obj index, Obj old, Obj new)
{
    Int         len;
    AtomicObj   aold, anew;
    AtomicObj * addr;
    Obj         result;

    UInt n = GetPositiveSmallInt(SELF_NAME, index);

    switch (TNUM_OBJ(list)) {
    case T_FIXALIST:
    case T_APOSOBJ:
      break;
    case T_ALIST:
        return AtomicCompareSwapAList(list, n, old, new);
    default:
        RequireArgument(SELF_NAME, list, "must be an atomic list");
  }
  addr = ADDR_ATOM(list);
  len = ALIST_LEN((UInt)addr[0].atom);

  RequireBoundedInt(SELF_NAME, index, 1, len);
  aold.obj = old;
  anew.obj = new;
  result = COMPARE_AND_SWAP(&(addr[n+1].atom), aold.atom, anew.atom) ?
    True : False;
  if (result == True)
    CHANGED_BAG(list);
  return result;
}

// Similar to COMPARE_AND_SWAP, but assigns list[index] the value 'new'
// if list[index] is currently unbound
static Obj FuncATOMIC_BIND(Obj self, Obj list, Obj index, Obj new)
{
    return FuncCOMPARE_AND_SWAP(self, list, index, 0, new);
}

// Similar to COMPARE_AND_SWAP, but unbinds list[index] if list[index]
// is currently assigned 'old'
static Obj FuncATOMIC_UNBIND(Obj self, Obj list, Obj index, Obj old)
{
    return FuncCOMPARE_AND_SWAP(self, list, index, old, 0);
}

static Obj FuncATOMIC_ADDITION(Obj self, Obj list, Obj index, Obj inc)
{
  UInt n;
  UInt len;
  AtomicObj aold, anew, *addr;
  switch (TNUM_OBJ(list)) {
    case T_FIXALIST:
    case T_APOSOBJ:
      break;
    default:
      RequireArgument(SELF_NAME, list, "must be a fixed atomic list");
  }
  addr = ADDR_ATOM(list);
  len = ALIST_LEN((UInt) addr[0].atom);
  n = GetBoundedInt("ATOMIC_ADDITION", index, 1, len);
  RequireSmallInt(SELF_NAME, index);
  do
  {
    aold = addr[n+1];
    if (!IS_INTOBJ(aold.obj))
      ArgumentError("ATOMIC_ADDITION: list element is not an integer");
    anew.obj = INTOBJ_INT(INT_INTOBJ(aold.obj) + INT_INTOBJ(inc));
  } while (!COMPARE_AND_SWAP(&(addr[n+1].atom), aold.atom, anew.atom));
  return anew.obj;
}


static Obj FuncAddAtomicList(Obj self, Obj list, Obj obj)
{
    if (TNUM_OBJ(list) != T_ALIST)
        RequireArgument(SELF_NAME, list, "must be a non-fixed atomic list");
    return INTOBJ_INT(AddAList(list, obj));
}

Obj FromAtomicList(Obj list)
{
  Obj result;
  const AtomicObj *data;
  UInt i, len;
  data = CONST_ADDR_ATOM(list);
  len = ALIST_LEN((UInt) (data++->atom));
  result = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(result, len);
  MEMBAR_READ();
  for (i=1; i<=len; i++)
    SET_ELM_PLIST(result, i, data[i].obj);
  CHANGED_BAG(result);
  return result;
}

static Obj FuncFromAtomicList(Obj self, Obj list)
{
    if (TNUM_OBJ(list) != T_FIXALIST && TNUM_OBJ(list) != T_ALIST)
        RequireArgument(SELF_NAME, list, "must be an atomic list");
    return FromAtomicList(list);
}

static void MarkAtomicList(Bag bag)
{
  UInt len;
  const AtomicObj *ptr, *ptrend;
  ptr = CONST_ADDR_ATOM(bag);
  len = ALIST_LEN((UInt)(ptr++->atom));
  ptrend = ptr + len + 1;
  while (ptr < ptrend)
    MarkBag(ptr++->obj);
}

/* T_AREC_INNER substructure:
 * ADDR_OBJ(rec)[0] == capacity, must be a power of 2.
 * ADDR_OBJ(rec)[1] == log2(capacity).
 * ADDR_OBJ(rec)[2] == estimated size (occupied slots).
 * ADDR_OBJ(rec)[3] == update policy.
 * ADDR_OBJ(rec)[4..] == hash table of pairs of objects
 */
enum {
    AR_CAP  = 0,
    AR_BITS = 1,
    AR_SIZE = 2,
    AR_POL  = 3,
    AR_DATA = 4,
};

/* T_TLREC_INNER substructure:
 * ADDR_OBJ(rec)[0] == number of subrecords
 * ADDR_OBJ(rec)[1] == default values
 * ADDR_OBJ(rec)[2] == constructors
 * ADDR_OBJ(rec)[3..] == table of per-thread subrecords
 */
enum {
  TLR_SIZE         = 0,
  TLR_DEFAULTS     = 1,
  TLR_CONSTRUCTORS = 2,
  TLR_DATA         = 3,
};

static Obj GetTLInner(Obj obj)
{
  Obj contents = CONST_ADDR_ATOM(obj)->obj;
  MEMBAR_READ(); /* read barrier */
  return contents;
}

static void MarkTLRecord(Bag bag)
{
  MarkBag(GetTLInner(bag));
}


static void MarkAtomicRecord(Bag bag)
{
  MarkBag(GetTLInner(bag));
}

static void MarkAtomicRecord2(Bag bag)
{
  const AtomicObj *p = CONST_ADDR_ATOM(bag);
  UInt cap = p->atom;
  p += 5;
  while (cap) {
    MarkBag(p->obj);
    p += 2;
    cap--;
  }
}

static void ExpandTLRecord(Obj obj)
{
  AtomicObj contents, newcontents;
  do {
    contents = *CONST_ADDR_ATOM(obj);
    const Obj *table = CONST_ADDR_OBJ(contents.obj);
    UInt thread = TLS(threadID);
    if (thread < (UInt)*table)
      return;
    newcontents.obj = NewBag(T_TLREC_INNER, sizeof(Obj) * (thread+TLR_DATA+1));
    Obj *newtable = ADDR_OBJ(newcontents.obj);
    newtable[TLR_SIZE] = (Obj)(thread+1);
    newtable[TLR_DEFAULTS] = table[TLR_DEFAULTS];
    newtable[TLR_CONSTRUCTORS] = table[TLR_CONSTRUCTORS];
    memcpy(newtable + TLR_DATA, table + TLR_DATA,
      (UInt)table[TLR_SIZE] * sizeof(Obj));
  } while (!COMPARE_AND_SWAP(&(ADDR_ATOM(obj)->atom),
    contents.atom, newcontents.atom));
  CHANGED_BAG(obj);
  CHANGED_BAG(newcontents.obj);
}

static void PrintAtomicList(Obj obj)
{

  if (TNUM_OBJ(obj) == T_FIXALIST)
    Pr("<fixed atomic list of size %d>",
      ALIST_LEN((UInt)(CONST_ADDR_OBJ(obj)[0])), 0);
  else
    Pr("<atomic list of size %d>", ALIST_LEN((UInt)(CONST_ADDR_OBJ(obj)[0])), 0);
}

static inline Obj ARecordObj(Obj record)
{
  return CONST_ADDR_OBJ(record)[1];
}

static inline AtomicObj* ARecordTable(Obj record)
{
  return ADDR_ATOM(ARecordObj(record));
}

static void PrintAtomicRecord(Obj record)
{
  UInt cap, size;
  HashLock(record);
  AtomicObj *table = ARecordTable(record);
  cap = table[AR_CAP].atom;
  size = table[AR_SIZE].atom;
  HashUnlock(record);
  Pr("<atomic record %d/%d full>", size, cap);
}

static void PrintTLRecord(Obj obj)
{
  Obj contents = GetTLInner(obj);
  const Obj *table = CONST_ADDR_OBJ(contents);
  Obj record = 0;
  Obj defrec = table[TLR_DEFAULTS];
  int comma = 0;
  AtomicObj *deftable;
  int i;
  if (TLS(threadID) < (UInt)table[TLR_SIZE]) {
    record = table[TLR_DATA+TLS(threadID)];
  }
  Pr("%2>rec( %2>", 0, 0);
  if (record) {
    for (i = 1; i <= LEN_PREC(record); i++) {
      Obj val = GET_ELM_PREC(record, i);
      Pr("%H", (Int)NAME_RNAM(labs(GET_RNAM_PREC(record, i))), 0);
      Pr ("%< := %>", 0, 0);
      if (val)
        PrintObj(val);
      else
        Pr("<undefined>", 0, 0);
      if (i < LEN_PREC(record))
        Pr("%2<, %2>", 0, 0);
      else
        comma = 1;
    }
  }
  HashLockShared(defrec);
  deftable = ARecordTable(defrec);
  for (i = 0; i < deftable[AR_CAP].atom; i++) {
    UInt key = deftable[AR_DATA+2*i].atom;
    Obj value = deftable[AR_DATA+2*i+1].obj;
    if (key && (!record || !PositionPRec(record, key, 0))) {
      if (comma)
        Pr("%2<, %2>", 0, 0);
      Pr("%H", (Int)(NAME_RNAM(key)), 0);
      Pr ("%< := %>", 0, 0);
      PrintObj(CopyTraversed(value));
      comma = 1;
    }
  }
  HashUnlockShared(defrec);
  Pr(" %4<)", 0, 0);
}


Obj GetARecordField(Obj record, UInt field)
{
  AtomicObj *table = ARecordTable(record);
  AtomicObj *data = table + AR_DATA;
  UInt cap, bits, hash, n;
  /* We need a memory barrier to ensure that we see fields that
   * were updated before the table pointer was updated; there is
   * a matching write barrier in the set operation. */
  MEMBAR_READ();
  cap = table[AR_CAP].atom;
  bits = table[AR_BITS].atom;
  hash = FibHash(field, bits);
  n = cap;
  while (n-- > 0)
  {
    UInt key = data[hash*2].atom;
    if (key == field)
    {
      Obj result;
      MEMBAR_READ(); /* memory barrier */
      result = data[hash*2+1].obj;
      if (result != Undefined)
        return result;
    }
    if (!key)
      return (Obj) 0;
    hash++;
    if (hash == cap)
      hash = 0;
  }
  return (Obj) 0;
}

static UInt ARecordFastInsert(AtomicObj *table, AtomicUInt field)
{
  AtomicObj *data = table + AR_DATA;
  UInt cap = table[AR_CAP].atom;
  UInt bits = table[AR_BITS].atom;
  UInt hash = FibHash(field, bits);
  for (;;)
  {
    AtomicUInt key;
    key = data[hash*2].atom;
    if (!key)
    {
      table[AR_SIZE].atom++; /* increase size */
      data[hash*2].atom = field;
      return hash;
    }
    if (key == field)
      return hash;
    hash++;
    if (hash == cap)
      hash = 0;
  }
}

Obj SetARecordField(Obj record, UInt field, Obj obj)
{
  AtomicObj *table, *data, *newtable, *newdata;
  Obj inner, result;
  UInt cap, bits, hash, i, n, size;
  AtomicRecordPolicy policy;
  int have_room;
  HashLockShared(record);
  inner = ARecordObj(record);
  table = ADDR_ATOM(inner);
  data = table + AR_DATA;
  cap = table[AR_CAP].atom;
  bits = table[AR_BITS].atom;
  policy = table[AR_POL].atom;
  hash = FibHash(field, bits);
  n = cap;
  /* case 1: key exists, we can replace it */
  while (n-- > 0)
  {
    UInt key = data[hash*2].atom;
    if (!key)
      break;
    if (key == field)
    {
      MEMBAR_FULL(); /* memory barrier */
      if (policy == AREC_WX) {
        HashUnlockShared(record);
        return 0;
      }
      else if (policy == AREC_RW) {
        AtomicObj old;
        AtomicObj new;
        new.obj = obj;
        do {
          old = data[hash*2+1];
        } while (!COMPARE_AND_SWAP(&data[hash*2+1].atom,
                  old.atom, new.atom));
        CHANGED_BAG(inner);
        HashUnlockShared(record);
        return obj;
      } else { // AREC_W1
        do {
          result = data[hash*2+1].obj;
        } while (!result);
        CHANGED_BAG(inner);
        HashUnlockShared(record);
        return result;
      }
    }
    hash++;
    if (hash == cap)
      hash = 0;
  }
  do {
    size = table[AR_SIZE].atom + 1;
    have_room = (size <= UsageCap[bits]);
  } while (have_room && !COMPARE_AND_SWAP(&table[AR_SIZE].atom,
                         size-1, size));
  /* we're guaranteed to have a non-full table for the insertion step */
  /* if have_room is true */
  if (have_room) for (;;) { /* hash iteration loop */
    AtomicObj old = data[hash*2];
    if (old.atom == field) {
      /* we don't actually need a new entry, so revert the size update */
      do {
        size = table[AR_SIZE].atom;
      } while (!COMPARE_AND_SWAP(&table[AR_SIZE].atom, size, size-1));
      /* continue below */
    } else if (!old.atom) {
      AtomicObj new;
      new.atom = field;
      if (!COMPARE_AND_SWAP(&data[hash*2].atom, old.atom, new.atom))
        continue;
      /* else continue below */
    } else {
      hash++;
      if (hash == cap)
        hash = 0;
      continue;
    }
    MEMBAR_FULL(); /* memory barrier */
    for (;;) { /* CAS loop */
      old = data[hash*2+1];
      if (old.obj) {
        if (policy == AREC_WX) {
          result = 0;
          break;
        }
        else if (policy == AREC_RW) {
          AtomicObj new;
          new.obj = obj;
          if (COMPARE_AND_SWAP(&data[hash*2+1].atom,
              old.atom, new.atom)) {
            result = obj;
            break;
          }
        } else {
          result = old.obj;
          break;
        }
      } else {
        AtomicObj new;
        new.obj = obj;
        if (COMPARE_AND_SWAP(&data[hash*2+1].atom,
            old.atom, new.atom)) {
          result = obj;
          break;
        }
      }
    } /* end CAS loop */
    CHANGED_BAG(inner);
    HashUnlockShared(record);
    return result;
  } /* end hash iteration loop */
  /* have_room is false at this point */
  HashUnlockShared(record);
  HashLock(record);
  inner = NewBag(T_AREC_INNER, sizeof(AtomicObj) * (AR_DATA + cap * 2 * 2));
  newtable = ADDR_ATOM(inner);
  newdata = newtable + AR_DATA;
  newtable[AR_CAP].atom = cap * 2;
  newtable[AR_BITS].atom = bits+1;
  newtable[AR_SIZE].atom = 0; /* size */
  newtable[AR_POL] = table[AR_POL]; /* policy */
  for (i=0; i<cap; i++) {
    UInt key = data[2*i].atom;
    Obj value = data[2*i+1].obj;
    if (key && value != Undefined) {
      n = ARecordFastInsert(newtable, key);
      newdata[2*n+1].obj = value;
    }
  }
  n = ARecordFastInsert(newtable, field);
  if (newdata[2*n+1].obj)
  {
    if (policy == AREC_WX)
      result = (Obj) 0;
    else {
      if (policy == AREC_RW)
        newdata[2*n+1].obj = result = obj;
      else
        result = newdata[2*n+1].obj;
    }
  }
  else
    newdata[2*n+1].obj = result = obj;
  MEMBAR_WRITE(); /* memory barrier */
  ADDR_OBJ(record)[1] = inner;
  CHANGED_BAG(inner);
  CHANGED_BAG(record);
  HashUnlock(record);
  return result;
}

Obj FromAtomicRecord(Obj record)
{
  Obj result;
  AtomicObj *table, *data;
  UInt cap, i;
  table = ARecordTable(record);
  data = table + AR_DATA;
  MEMBAR_READ(); /* memory barrier */
  cap = table[AR_CAP].atom;
  result = NEW_PREC(0);
  for (i=0; i<cap; i++)
  {
    UInt key;
    Obj value;
    key = data[2*i].atom;
    MEMBAR_READ();
    value = data[2*i+1].obj;
    if (key && value && value != Undefined)
      AssPRec(result, key, value);
  }
  return result;
}

static Obj FuncFromAtomicRecord(Obj self, Obj record)
{
    if (TNUM_OBJ(record) != T_AREC)
        RequireArgument(SELF_NAME, record, "must be an atomic record");
    return FromAtomicRecord(record);
}

static Obj FuncFromAtomicComObj(Obj self, Obj comobj)
{
    if (TNUM_OBJ(comobj) != T_ACOMOBJ)
        RequireArgument(SELF_NAME, comobj,
                        "must be an atomic component object");
    return FromAtomicRecord(comobj);
}

Obj NewAtomicRecord(UInt capacity)
{
  Obj arec, result;
  AtomicObj *table;
  UInt bits = 1;
  while (capacity > (1 << bits))
    bits++;
  capacity = 1 << bits;
  arec = NewBag(T_AREC_INNER, sizeof(AtomicObj) * (AR_DATA+2*capacity));
  table = ADDR_ATOM(arec);
  result = NewBag(T_AREC, 2*sizeof(Obj));
  table[AR_CAP].atom = capacity;
  table[AR_BITS].atom = bits;
  table[AR_SIZE].atom = 0;
  table[AR_POL].atom = AREC_RW;
  ADDR_OBJ(result)[1] = arec;
  CHANGED_BAG(arec);
  CHANGED_BAG(result);
  return result;
}

static Obj NewAtomicRecordFrom(Obj precord)
{
  Obj result;
  AtomicObj *table;
  UInt i, pos, len = LEN_PREC(precord);
  result = NewAtomicRecord(len);
  table = ARecordTable(result);
  for (i=1; i<=len; i++) {
    Int field = GET_RNAM_PREC(precord, i);
    if (field < 0)
      field = -field;
    pos = ARecordFastInsert(table, field);
    table[AR_DATA+2*pos+1].obj = GET_ELM_PREC(precord, i);
  }
  CHANGED_BAG(ARecordObj(result));
  CHANGED_BAG(result);
  MEMBAR_WRITE();
  return result;
}

static void SetARecordUpdatePolicy(Obj record, AtomicRecordPolicy policy)
{
  AtomicObj *table = ARecordTable(record);
  table[AR_POL].atom = policy;
}

static AtomicRecordPolicy GetARecordUpdatePolicy(Obj record)
{
  AtomicObj *table = ARecordTable(record);
  return table[AR_POL].atom;
}

Obj ElmARecord(Obj record, UInt rnam)
{
    Obj result = GetARecordField(record, rnam);
    if (!result)
        ErrorMayQuit(
            "Record: '<atomic record>.%g' must have an assigned value",
            (UInt)NAME_RNAM(rnam), 0);
    return result;
}

void AssARecord(Obj record, UInt rnam, Obj value)
{
    Obj result = SetARecordField(record, rnam, value);
    if (!result)
        ErrorMayQuit(
            "Record: '<atomic record>.%g' already has an assigned value",
            (UInt)NAME_RNAM(rnam), 0);
}

void UnbARecord(Obj record, UInt rnam) {
   SetARecordField(record, rnam, Undefined);
}

BOOL IsbARecord(Obj record, UInt rnam)
{
  return GetARecordField(record, rnam) != (Obj) 0;
}

static Obj ShallowCopyARecord(Obj obj)
{
  Obj copy, inner, innerCopy;
  HashLock(obj);
  copy = NewBag(TNUM_BAG(obj), SIZE_BAG(obj));
  memcpy(ADDR_OBJ(copy), CONST_ADDR_OBJ(obj), SIZE_BAG(obj));
  inner = CONST_ADDR_OBJ(obj)[1];
  innerCopy = NewBag(TNUM_BAG(inner), SIZE_BAG(inner));
  memcpy(ADDR_OBJ(innerCopy), CONST_ADDR_OBJ(inner), SIZE_BAG(inner));
  ADDR_OBJ(copy)[1] = innerCopy;
  HashUnlock(obj);
  CHANGED_BAG(innerCopy);
  CHANGED_BAG(copy);
  return copy;
}

static void UpdateThreadRecord(Obj record, Obj tlrecord)
{
  Obj inner;
  do {
    inner = GetTLInner(record);
    ADDR_OBJ(inner)[TLR_DATA+TLS(threadID)] = tlrecord;
    MEMBAR_FULL(); /* memory barrier */
  } while (inner != GetTLInner(record));
  if (tlrecord) {
    if (TLS(tlRecords))
      AssPlist(TLS(tlRecords), LEN_PLIST(TLS(tlRecords))+1, record);
    else {
      TLS(tlRecords) = NEW_PLIST(T_PLIST, 1);
      SET_LEN_PLIST(TLS(tlRecords), 1);
      SET_ELM_PLIST(TLS(tlRecords), 1, record);
      CHANGED_BAG(TLS(tlRecords));
    }
  }
}

Obj GetTLRecordField(Obj record, UInt rnam)
{
  Obj contents, *table;
  Obj tlrecord;
  UInt pos;
  Region *savedRegion = TLS(currentRegion);
  TLS(currentRegion) = TLS(threadRegion);
  ExpandTLRecord(record);
  contents = GetTLInner(record);
  table = ADDR_OBJ(contents);
  tlrecord = table[TLR_DATA+TLS(threadID)];
  if (!tlrecord || !(pos = PositionPRec(tlrecord, rnam, 1))) {
    Obj result;
    Obj defrec = table[TLR_DEFAULTS];
    result = GetARecordField(defrec, rnam);
    if (result) {
      result = CopyTraversed(result);
      if (!tlrecord) {
        tlrecord = NEW_PREC(0);
        UpdateThreadRecord(record, tlrecord);
      }
      AssPRec(tlrecord, rnam, result);
      TLS(currentRegion) = savedRegion;
      return result;
    } else {
      Obj func;
      Obj constructors = table[TLR_CONSTRUCTORS];
      func = GetARecordField(constructors, rnam);
      if (!tlrecord) {
        tlrecord = NEW_PREC(0);
        UpdateThreadRecord(record, tlrecord);
      }
      if (func) {
        if (NARG_FUNC(func) == 0)
          result = CALL_0ARGS(func);
        else
          result = CALL_1ARGS(func, record);
        TLS(currentRegion) = savedRegion;
        if (!result) {
          pos = PositionPRec(tlrecord, rnam, 1);
          if (!pos)
            return 0;
          return GET_ELM_PREC(tlrecord, pos);
        }
        AssPRec(tlrecord, rnam, result);
        return result;
      }
      TLS(currentRegion) = savedRegion;
      return 0;
    }
  }
  TLS(currentRegion) = savedRegion;
  return GET_ELM_PREC(tlrecord, pos);
}

static Obj ElmTLRecord(Obj record, UInt rnam)
{
    Obj result = GetTLRecordField(record, rnam);
    if (!result)
        ErrorMayQuit(
            "Record: '<thread-local record>.%g' must have an assigned value",
            (UInt)NAME_RNAM(rnam), 0);
    return result;
}

void AssTLRecord(Obj record, UInt rnam, Obj value)
{
  Obj contents, *table;
  Obj tlrecord;
  ExpandTLRecord(record);
  contents = GetTLInner(record);
  table = ADDR_OBJ(contents);
  tlrecord = table[TLR_DATA+TLS(threadID)];
  if (!tlrecord) {
    tlrecord = NEW_PREC(0);
    UpdateThreadRecord(record, tlrecord);
  }
  AssPRec(tlrecord, rnam, value);
}

static void UnbTLRecord(Obj record, UInt rnam)
{
  Obj contents, *table;
  Obj tlrecord;
  ExpandTLRecord(record);
  contents = GetTLInner(record);
  table = ADDR_OBJ(contents);
  tlrecord = table[TLR_DATA+TLS(threadID)];
  if (!tlrecord) {
    tlrecord = NEW_PREC(0);
    UpdateThreadRecord(record, tlrecord);
  }
  UnbPRec(tlrecord, rnam);
}


static BOOL IsbTLRecord(Obj record, UInt rnam)
{
  return GetTLRecordField(record, rnam) != (Obj) 0;
}

static Obj FuncAtomicRecord(Obj self, Obj args)
{
  Obj arg;
  switch (LEN_PLIST(args)) {
    case 0:
      return NewAtomicRecord(8);
    case 1:
      arg = ELM_PLIST(args, 1);
      if (IS_POS_INTOBJ(arg)) {
        return NewAtomicRecord(INT_INTOBJ(arg));
      }
      if (IS_PREC(arg)) {
          return NewAtomicRecordFrom(arg);
      }
      ArgumentError("AtomicRecord: argument must be a positive small integer or a record");
    default:
      ArgumentError("AtomicRecord: takes one optional argument");
      return (Obj) 0;
  }
}

static Obj FuncGET_ATOMIC_RECORD(Obj self, Obj record, Obj field, Obj def)
{
  UInt fieldname;
  Obj result;
  if (TNUM_OBJ(record) != T_AREC)
    RequireArgument(SELF_NAME, record, "must be an atomic record");
  RequireStringRep(SELF_NAME, field);
  fieldname = RNamName(CONST_CSTR_STRING(field));
  result = GetARecordField(record, fieldname);
  return result ? result : def;
}

static Obj FuncSET_ATOMIC_RECORD(Obj self, Obj record, Obj field, Obj value)
{
  UInt fieldname;
  Obj result;
  if (TNUM_OBJ(record) != T_AREC)
    RequireArgument(SELF_NAME, record, "must be an atomic record");
  RequireStringRep(SELF_NAME, field);
  fieldname = RNamName(CONST_CSTR_STRING(field));
  result = SetARecordField(record, fieldname, value);
  if (!result)
    ErrorQuit("SET_ATOMIC_RECORD: Field '%s' already exists",
      (UInt) CONST_CSTR_STRING(field), 0);
  return result;
}

static Obj FuncUNBIND_ATOMIC_RECORD(Obj self, Obj record, Obj field)
{
  UInt fieldname;
  Obj exists;
  if (TNUM_OBJ(record) != T_AREC)
    RequireArgument(SELF_NAME, record, "must be an atomic record");
  RequireStringRep(SELF_NAME, field);
  fieldname = RNamName(CONST_CSTR_STRING(field));
  if (GetARecordUpdatePolicy(record) != AREC_RW)
    ErrorQuit("UNBIND_ATOMIC_RECORD: Record elements cannot be changed",
      (UInt) CONST_CSTR_STRING(field), 0);
  exists = GetARecordField(record, fieldname);
  if (exists)
    SetARecordField(record, fieldname, (Obj) 0);
  return (Obj) 0;
}

static Obj CreateTLDefaults(Obj defrec) {
  Region *saved_region = TLS(currentRegion);
  Obj result;
  UInt i;
  TLS(currentRegion) = LimboRegion;
  result = NewBag(T_PREC, SIZE_BAG(defrec));
  memcpy(ADDR_OBJ(result), CONST_ADDR_OBJ(defrec), SIZE_BAG(defrec));
  for (i = 1; i <= LEN_PREC(defrec); i++) {
    SET_ELM_PREC(result, i,
      CopyReachableObjectsFrom(GET_ELM_PREC(result, i), 0, 1, 0));
  }
  CHANGED_BAG(result);
  TLS(currentRegion) = saved_region;
  return NewAtomicRecordFrom(result);
}

static Obj NewTLRecord(Obj defaults, Obj constructors) {
  Obj result = NewBag(T_TLREC, sizeof(AtomicObj));
  Obj inner = NewBag(T_TLREC_INNER, sizeof(Obj) * TLR_DATA);
  ADDR_OBJ(inner)[TLR_SIZE] = 0;
  ADDR_OBJ(inner)[TLR_DEFAULTS] = CreateTLDefaults(defaults);
  WriteGuard(constructors);
  SET_REGION(constructors, LimboRegion);
  MEMBAR_WRITE();
  ADDR_OBJ(inner)[TLR_CONSTRUCTORS] = NewAtomicRecordFrom(constructors);
  ((AtomicObj *)(ADDR_OBJ(result)))->obj = inner;
  CHANGED_BAG(result);
  return result;
}

void SetTLDefault(Obj record, UInt rnam, Obj value) {
  Obj inner = GetTLInner(record);
  SetARecordField(ADDR_OBJ(inner)[TLR_DEFAULTS],
    rnam, CopyReachableObjectsFrom(value, 0, 1, 0));
}

void SetTLConstructor(Obj record, UInt rnam, Obj func) {
  Obj inner = GetTLInner(record);
  SetARecordField(ADDR_OBJ(inner)[TLR_CONSTRUCTORS],
    rnam, func);
}


static int OnlyConstructors(Obj precord) {
  UInt i, len;
  len = LEN_PREC(precord);
  for (i=1; i<=len; i++) {
    Obj elm = GET_ELM_PREC(precord, i);
    if (TNUM_OBJ(elm) != T_FUNCTION || (Int) NARG_FUNC(elm) != 0)
      return 0;
  }
  return 1;
}

static Obj FuncThreadLocalRecord(Obj self, Obj args)
{
    Obj defaults, constructors;
    Int narg = LEN_PLIST(args);

    if (narg >= 2) {
        ArgumentError("ThreadLocalRecord: Too many arguments");
    }

    defaults = (narg >= 1) ? ELM_PLIST(args, 1) : NEW_PREC(0);
    constructors = (narg >= 2) ? ELM_PLIST(args, 2) : NEW_PREC(0);
    RequirePlainRec(SELF_NAME, defaults);
    RequirePlainRec(SELF_NAME, constructors);

    if (!OnlyConstructors(constructors))
        ArgumentError("ThreadLocalRecord: <constructors> must be a record containing parameterless functions");

    return NewTLRecord(defaults, constructors);
}

static Obj FuncSetTLDefault(Obj self, Obj record, Obj name, Obj value)
{
  if (TNUM_OBJ(record) != T_TLREC)
    RequireArgument(SELF_NAME, record, "must be a thread-local record");
  if (!IS_STRING(name) && !IS_INTOBJ(name))
    RequireArgument(SELF_NAME, value, "must be a string or an integer");
  SetTLDefault(record, RNamObj(name), value);
  return (Obj) 0;
}

static Obj FuncSetTLConstructor(Obj self, Obj record, Obj name, Obj function)
{
  if (TNUM_OBJ(record) != T_TLREC)
    RequireArgument(SELF_NAME, record, "must be a thread-local record");
  if (!IS_STRING(name) && !IS_INTOBJ(name))
    RequireArgument(SELF_NAME, name, "must be a string or an integer");
  RequireFunction(SELF_NAME, function);
  SetTLConstructor(record, RNamObj(name), function);
  return (Obj) 0;
}

static Int LenListAList(Obj list)
{
  MEMBAR_READ();
  return (Int)(ALIST_LEN((UInt)CONST_ADDR_ATOM(list)[0].atom));
}

Obj LengthAList(Obj list)
{
  MEMBAR_READ();
  return INTOBJ_INT(ALIST_LEN((UInt)CONST_ADDR_ATOM(list)[0].atom));
}

Obj Elm0AList(Obj list, Int pos)
{
  const AtomicObj *addr = CONST_ADDR_ATOM(list);
  UInt len;
  MEMBAR_READ();
  len = ALIST_LEN((UInt) addr[0].atom);
  if (pos < 1 || pos > len)
    return 0;
  MEMBAR_READ();
  return addr[1+pos].obj;
}

Obj ElmAList(Obj list, Int pos)
{
  const AtomicObj *addr = CONST_ADDR_ATOM(list);
  UInt len;
  MEMBAR_READ();
  len = ALIST_LEN((UInt)addr[0].atom);
  Obj result;
  if (pos < 1 || pos > len) {
      ErrorMayQuit(
          "Atomic List Element: <pos>=%d is an invalid index for <list>",
          (Int)pos, 0);
  }

  result = addr[1 + pos].obj;
  if (!result)
      ErrorMayQuit(
          "Atomic List Element: <list>[%d] must have an assigned value",
          (Int)pos, 0);

  MEMBAR_READ();
  return result;
}

static BOOL IsbAList(Obj list, Int pos)
{
  const AtomicObj *addr = CONST_ADDR_ATOM(list);
  UInt len;
  MEMBAR_READ();
  len = ALIST_LEN((UInt) addr[0].atom);
  return pos >= 1 && pos <= len && addr[1+pos].obj;
}

static void AssFixAList(Obj list, Int pos, Obj obj)
{
  UInt pol = (UInt)CONST_ADDR_ATOM(list)[0].atom;
  UInt len = ALIST_LEN(pol);
  if (pos < 1 || pos > len) {
      ErrorMayQuit(
          "Atomic List Element: <pos>=%d is an invalid index for <list>",
          (Int)pos, 0);
  }
  switch (ALIST_POL(pol)) {
    case ALIST_RW:
      ADDR_ATOM(list)[1+pos].obj = obj;
      break;
    case ALIST_W1:
      COMPARE_AND_SWAP(&ADDR_ATOM(list)[1+pos].atom,
        (AtomicUInt) 0, (AtomicUInt) obj);
      break;
    case ALIST_WX:
      if (!COMPARE_AND_SWAP(&ADDR_ATOM(list)[1+pos].atom,
        (AtomicUInt) 0, (AtomicUInt) obj)) {
        ErrorQuit("Atomic List Assignment: <list>[%d] already has an assigned value", pos, (Int) 0);
      }
      break;
  }
  CHANGED_BAG(list);
  MEMBAR_WRITE();
}

// Ensure the capacity of atomic list 'list' is at least 'pos'.
// Errors if 'pos' is 'list' is fixed length and 'pos' is greater
// than the existing length.
// If this function returns, then the code has a (possibly shared)
// HashLock on the list, which must be released by the caller.
static void EnlargeAList(Obj list, Int pos)
{
    HashLockShared(list);
    AtomicObj * addr = ADDR_ATOM(list);
    UInt        pol = (UInt)addr[0].atom;
    UInt        len = ALIST_LEN(pol);
    if (pos > len) {
        HashUnlockShared(list);
        HashLock(list);
        addr = ADDR_ATOM(list);
        pol = (UInt)addr[0].atom;
        len = ALIST_LEN(pol);
    }
    if (pos > len) {
        if (TNUM_OBJ(list) != T_ALIST) {
            HashUnlock(list);
            ErrorQuit(
                "Atomic List Assignment: extending fixed size atomic list",
                0, 0);
            return; /* flow control hint */
        }
        addr = ADDR_ATOM(list);
        if (pos > SIZE_BAG(list) / sizeof(AtomicObj) - 2) {
            Obj  newlist;
            UInt newlen = len;
            do {
                newlen = newlen * 3 / 2 + 1;
            } while (pos > newlen);
            newlist = NewBag(T_ALIST, sizeof(AtomicObj) * (2 + newlen));
            memcpy(PTR_BAG(newlist), PTR_BAG(list),
                   sizeof(AtomicObj) * (2 + len));
            addr = ADDR_ATOM(newlist);
            addr[0].atom = CHANGE_ALIST_LEN(pol, pos);
            MEMBAR_WRITE();
            /* TODO: Won't work with GASMAN */
            SET_PTR_BAG(list, PTR_BAG(newlist));
            MEMBAR_WRITE();
        }
        else {
            addr[0].atom = CHANGE_ALIST_LEN(pol, pos);
            MEMBAR_WRITE();
        }
    }
}

void AssAList(Obj list, Int pos, Obj obj)
{
  if (pos < 1) {
    ErrorQuit(
        "Atomic List Element: <pos>=%d is an invalid index for <list>",
        (Int) pos, 0);
  }

  EnlargeAList(list, pos);

  AtomicObj * addr = ADDR_ATOM(list);
  UInt        pol = (UInt)addr[0].atom;

  switch (ALIST_POL(pol)) {
    case ALIST_RW:
      ADDR_ATOM(list)[1+pos].obj = obj;
      break;
    case ALIST_W1:
      COMPARE_AND_SWAP(&ADDR_ATOM(list)[1+pos].atom,
        (AtomicUInt) 0, (AtomicUInt) obj);
      break;
    case ALIST_WX:
      if (!COMPARE_AND_SWAP(&ADDR_ATOM(list)[1+pos].atom,
        (AtomicUInt) 0, (AtomicUInt) obj)) {
        HashUnlock(list);
        ErrorQuit("Atomic List Assignment: <list>[%d] already has an assigned value", pos, (Int) 0);
      }
      break;
  }
  CHANGED_BAG(list);
  MEMBAR_WRITE();
  HashUnlock(list);
}

static Obj AtomicCompareSwapAList(Obj list, Int pos, Obj old, Obj new)
{
    if (pos < 1) {
        ErrorQuit(
            "Atomic List Element: <pos>=%d is an invalid index for <list>",
            (Int)pos, 0);
    }

    EnlargeAList(list, pos);

    UInt swap = COMPARE_AND_SWAP(&ADDR_ATOM(list)[1 + pos].atom,
                                 (AtomicUInt)old, (AtomicUInt) new);

    if (!swap) {
        HashUnlock(list);
        return False;
    }
    else {
        CHANGED_BAG(list);
        MEMBAR_WRITE();
        HashUnlock(list);
        return True;
    }
}

UInt AddAList(Obj list, Obj obj)
{
  AtomicObj *addr;
  UInt len, newlen, pol;
  HashLock(list);
  if (TNUM_OBJ(list) != T_ALIST) {
    HashUnlock(list);
    ErrorQuit("Atomic List Assignment: extending fixed size atomic list",
      0, 0);
  }
  addr = ADDR_ATOM(list);
  pol = (UInt)addr[0].atom;
  len = ALIST_LEN(pol);
  if (len + 1 > SIZE_BAG(list)/sizeof(AtomicObj) - 2) {
    Obj newlist;
    newlen = len * 3 / 2 + 1;
    newlist = NewBag(T_ALIST, sizeof(AtomicObj) * ( 2 + newlen));
    memcpy(PTR_BAG(newlist), PTR_BAG(list), sizeof(AtomicObj)*(2+len));
    addr = ADDR_ATOM(newlist);
    addr[0].atom = CHANGE_ALIST_LEN(pol, len + 1);
    MEMBAR_WRITE();
    SET_PTR_BAG(list, PTR_BAG(newlist));
    MEMBAR_WRITE();
  } else {
    addr[0].atom = CHANGE_ALIST_LEN(pol, len + 1);
    MEMBAR_WRITE();
  }
  switch (ALIST_POL(pol)) {
    case ALIST_RW:
      ADDR_ATOM(list)[2+len].obj = obj;
      break;
    case ALIST_W1:
      COMPARE_AND_SWAP(&ADDR_ATOM(list)[2+len].atom,
        (AtomicUInt) 0, (AtomicUInt) obj);
      break;
    case ALIST_WX:
      if (!COMPARE_AND_SWAP(&ADDR_ATOM(list)[2+len].atom,
        (AtomicUInt) 0, (AtomicUInt) obj)) {
        HashUnlock(list);
        ErrorQuit("Atomic List Assignment: <list>[%d] already has an assigned value", len+1, (Int) 0);
      }
      break;
  }
  CHANGED_BAG(list);
  MEMBAR_WRITE();
  HashUnlock(list);
  return len+1;
}

static void UnbAList(Obj list, Int pos)
{
  AtomicObj *addr;
  UInt len, pol;
  HashLockShared(list);
  addr = ADDR_ATOM(list);
  pol = (UInt)addr[0].atom;
  len = ALIST_LEN(pol);
  if (ALIST_POL(pol) != ALIST_RW) {
    HashUnlockShared(list);
    ErrorQuit("Atomic List Unbind: list is in write-once mode", (Int) 0, (Int) 0);
  }
  if (pos >= 1 && pos <= len) {
    addr[1+pos].obj = 0;
    MEMBAR_WRITE();
  }
  HashUnlockShared(list);
}

static Int InitAObjectsState(void)
{
    TLS(tlRecords) = (Obj)0;
    return 0;
}

static Int DestroyAObjectsState(void)
{
    Obj  records;
    UInt i, len;
    records = TLS(tlRecords);
    if (records) {
        len = LEN_PLIST(records);
        for (i = 1; i <= len; i++)
            UpdateThreadRecord(ELM_PLIST(records, i), (Obj)0);
    }
    return 0;
}

#endif /* WARD_ENABLED */

static Obj MakeAtomic(Obj obj) {
  if (IS_LIST(obj))
      return NewAtomicListFrom(T_ALIST, obj);
  else if (TNUM_OBJ(obj) == T_PREC)
    return NewAtomicRecordFrom(obj);
  else
    return (Obj) 0;
}

static Obj FuncMakeWriteOnceAtomic(Obj self, Obj obj) {
  switch (TNUM_OBJ(obj)) {
    case T_ALIST:
    case T_FIXALIST:
    case T_APOSOBJ:
      HashLock(obj);
      ADDR_ATOM(obj)[0].atom =
        CHANGE_ALIST_POL(CONST_ADDR_ATOM(obj)[0].atom, ALIST_W1);
      HashUnlock(obj);
      break;
    case T_AREC:
    case T_ACOMOBJ:
      SetARecordUpdatePolicy(obj, AREC_W1);
      break;
    default:
      obj = MakeAtomic(obj);
      if (obj)
        return FuncMakeWriteOnceAtomic(self, obj);
      ArgumentError("MakeWriteOnceAtomic: argument not an atomic object, list, or record");
  }
  return obj;
}

static Obj FuncMakeReadWriteAtomic(Obj self, Obj obj) {
  switch (TNUM_OBJ(obj)) {
    case T_ALIST:
    case T_FIXALIST:
    case T_APOSOBJ:
      HashLock(obj);
      ADDR_ATOM(obj)[0].atom =
        CHANGE_ALIST_POL(CONST_ADDR_ATOM(obj)[0].atom, ALIST_RW);
      HashUnlock(obj);
      break;
    case T_AREC:
    case T_ACOMOBJ:
      SetARecordUpdatePolicy(obj, AREC_RW);
      break;
    default:
      obj = MakeAtomic(obj);
      if (obj)
        return FuncMakeReadWriteAtomic(self, obj);
      ArgumentError("MakeReadWriteAtomic: argument not an atomic object, list, or record");
  }
  return obj;
}

static Obj FuncMakeStrictWriteOnceAtomic(Obj self, Obj obj) {
  switch (TNUM_OBJ(obj)) {
    case T_ALIST:
    case T_FIXALIST:
    case T_APOSOBJ:
      HashLock(obj);
      ADDR_ATOM(obj)[0].atom =
        CHANGE_ALIST_POL(CONST_ADDR_ATOM(obj)[0].atom, ALIST_WX);
      HashUnlock(obj);
      break;
    case T_AREC:
    case T_ACOMOBJ:
      SetARecordUpdatePolicy(obj, AREC_WX);
      break;
    default:
      obj = MakeAtomic(obj);
      if (obj)
        return FuncMakeStrictWriteOnceAtomic(self, obj);
      ArgumentError("MakeStrictWriteOnceAtomic: argument not an atomic object, list, or record");
  }
  return obj;
}


#define FuncError(message)  ErrorQuit("%s: %s", (Int)currFuncName, (Int)message)

static Obj BindOncePosObj(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
  Int n;
  Bag *contents;
  Bag result;
  n = GetPositiveSmallInt(currFuncName, index);
  ReadGuard(obj);
#ifndef WARD_ENABLED
  contents = PTR_BAG(obj);
  MEMBAR_READ();
  if (SIZE_BAG_CONTENTS(contents) / sizeof(Bag) <= n) {
    HashLock(obj);
    /* resize bag */
    if (SIZE_BAG(obj) / sizeof(Bag) <= n) {
      /* can't use ResizeBag() directly because of guards. */
      /* therefore we create a faux master pointer in the public region. */
      UInt *mptr[2];
      mptr[0] = (UInt *)contents;
      mptr[1] = 0;
      ResizeBag(mptr, sizeof(Bag) * (n+1));
      MEMBAR_WRITE();
      SET_PTR_BAG(obj, (void *)(mptr[0]));
    }
    /* reread contents pointer */
    HashUnlock(obj);
    contents = PTR_BAG(obj);
    MEMBAR_READ();
  }
  /* already bound? */
  result = (Bag)(contents[n]);
  if (result && result != Fail)
    return result;
  if (eval)
    *new = CALL_0ARGS(*new);
  HashLockShared(obj);
  contents = PTR_BAG(obj);
  MEMBAR_READ();
  for (;;) {
    result = (Bag)(contents[n]);
    if (result && result != Fail)
      break;
    if (COMPARE_AND_SWAP((AtomicUInt*)(contents+n),
      (AtomicUInt) result, (AtomicUInt) *new))
      break;
  }
  CHANGED_BAG(obj);
  HashUnlockShared(obj);
  return result == Fail ? (Obj) 0 : result;
#endif
}

static Obj BindOnceAPosObj(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
  UInt n;
  UInt len;
  AtomicObj anew;
  AtomicObj *addr;
  Obj result;
  /* atomic positional objects aren't resizable. */
  addr = ADDR_ATOM(obj);
  MEMBAR_READ();
  len = ALIST_LEN(addr[0].atom);
  n = GetSmallInt(currFuncName, index);
  if (n <= 0 || n > len)
    FuncError("Index out of range");
  result = addr[n+1].obj;
  if (result && result != Fail)
    return result;
  anew.obj = *new;
  if (eval)
    *new = CALL_0ARGS(*new);
  for (;;) {
    result = addr[n+1].obj;
    if (result && result != Fail) {
      break;
    }
    if (COMPARE_AND_SWAP(&(addr[n+1].atom), (AtomicUInt) result, anew.atom))
      break;
  }
  CHANGED_BAG(obj);
  return result == Fail ? (Obj) 0 : result;
}


static Obj BindOnceComObj(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
  FuncError("not yet implemented");
  return (Obj) 0;
}


static Obj BindOnceAComObj(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
  FuncError("not yet implemented");
  return (Obj) 0;
}


static Obj BindOnce(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
  switch (TNUM_OBJ(obj)) {
    case T_POSOBJ:
      return BindOncePosObj(obj, index, new, eval, currFuncName);
    case T_APOSOBJ:
      return BindOnceAPosObj(obj, index, new, eval, currFuncName);
    case T_COMOBJ:
      return BindOnceComObj(obj, index, new, eval, currFuncName);
    case T_ACOMOBJ:
      return BindOnceAComObj(obj, index, new, eval, currFuncName);
    default:
      FuncError("first argument must be a positional or component object");
      return (Obj) 0; /* flow control hint */
  }
}

static Obj FuncBindOnce(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 0, "BindOnce");
  return result ? result : new;
}

static Obj FuncStrictBindOnce(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 0, "StrictBindOnce");
  if (result)
    ErrorQuit("StrictBindOnce: Element already initialized", 0, 0);
  return result;
}

static Obj FuncTestBindOnce(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 0, "TestBindOnce");
  return result ? False : True;
}

static Obj FuncBindOnceExpr(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 1, "BindOnceExpr");
  return result ? result : new;
}

static Obj FuncTestBindOnceExpr(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 1, "TestBindOnceExpr");
  return result ? False : True;
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
    { T_ALIST, "atomic list" },
    { T_FIXALIST, "fixed atomic list" },
    { T_APOSOBJ, "atomic positional object" },
    { T_AREC, "atomic record" },
    { T_ACOMOBJ, "atomic component object" },
    { T_TLREC, "thread-local record" },
    { -1,    "" }
};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/

static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC(AtomicList, -1, "list|count, obj"),
    GVAR_FUNC(FixedAtomicList, -1, "list|count, obj"),
    GVAR_FUNC_1ARGS(MakeFixedAtomicList, list),
    GVAR_FUNC_1ARGS(FromAtomicList, list),
    GVAR_FUNC_2ARGS(AddAtomicList, list, obj),
    GVAR_FUNC_2ARGS(GET_ATOMIC_LIST, list, index),
    GVAR_FUNC_3ARGS(SET_ATOMIC_LIST, list, index, value),
    GVAR_FUNC_4ARGS(COMPARE_AND_SWAP, list, index, old, new),
    GVAR_FUNC_3ARGS(ATOMIC_BIND, list, index, new),
    GVAR_FUNC_3ARGS(ATOMIC_UNBIND, list, index, old),

    GVAR_FUNC_3ARGS(ATOMIC_ADDITION, list, index, inc),
    GVAR_FUNC(AtomicRecord, -1, "[capacity]"),
    GVAR_FUNC_1ARGS(IS_ATOMIC_LIST, object),
    GVAR_FUNC_1ARGS(IS_FIXED_ATOMIC_LIST, object),
    GVAR_FUNC_1ARGS(IS_ATOMIC_RECORD, object),
    GVAR_FUNC_3ARGS(GET_ATOMIC_RECORD, record, field, default),
    GVAR_FUNC_3ARGS(SET_ATOMIC_RECORD, record, field, value),
    GVAR_FUNC_2ARGS(UNBIND_ATOMIC_RECORD, record, field),
    GVAR_FUNC_1ARGS(FromAtomicRecord, record),
    GVAR_FUNC_1ARGS(FromAtomicComObj, record),
    GVAR_FUNC(ThreadLocalRecord, -1, "record [, record]"),
    GVAR_FUNC_3ARGS(SetTLDefault, threadLocalRecord, name, value),
    GVAR_FUNC_3ARGS(SetTLConstructor, threadLocalRecord, name, function),
    GVAR_FUNC_1ARGS(MakeWriteOnceAtomic, obj),
    GVAR_FUNC_1ARGS(MakeReadWriteAtomic, obj),
    GVAR_FUNC_1ARGS(MakeStrictWriteOnceAtomic, obj),
    GVAR_FUNC_3ARGS(BindOnce, obj, index, value),
    GVAR_FUNC_3ARGS(StrictBindOnce, obj, index, value),
    GVAR_FUNC_3ARGS(TestBindOnce, obj, index, value),
    GVAR_FUNC_3ARGS(BindOnceExpr, obj, index, func),
    GVAR_FUNC_3ARGS(TestBindOnceExpr, obj, index, func),
    { 0, 0, 0, 0, 0 }

};

// Forbid comparision and copying of atomic objects, because they
// cannot be done in a thread-safe manner
static Int AtomicRecordErrorNoCompare(Obj arg1, Obj arg2)
{
    ErrorQuit("atomic records cannot be compared with other records", 0, 0);
    // Make compiler happy
    return 0;
}

static Int AtomicListErrorNoCompare(Obj arg1, Obj arg2)
{
    ErrorQuit("atomic lists cannot be compared with other lists", 0, 0);
    // Make compiler happy
    return 0;
}

static Obj AtomicErrorNoShallowCopy(Obj arg1)
{
    ErrorQuit("atomic objects cannot be copied", 0, 0);
    // Make compiler happy
    return 0;
}

#if !defined(USE_THREADSAFE_COPYING)
static Obj AtomicErrorNoCopy(Obj arg1, Int arg2)
{
    ErrorQuit("atomic objects cannot be copied", 0, 0);
    // Make compiler happy
    return 0;
}
#endif

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  UInt i;
  /* compute UsageCap */
  for (i=0; i<=3; i++)
    UsageCap[i] = (1<<i)-1;
  UsageCap[4] = 13;
  UsageCap[5] = 24;
  UsageCap[6] = 48;
  UsageCap[7] = 96;
  for (i=8; i<sizeof(UInt)*8; i++)
    UsageCap[i] = (1<<i)/3 * 2;

  // set the bag type names (for error messages and debugging)
  InitBagNamesFromTable(BagNames);
  
  /* install the kind methods */
  TypeObjFuncs[ T_ALIST ] = TypeAList;
  TypeObjFuncs[ T_FIXALIST ] = TypeAList;
  TypeObjFuncs[ T_APOSOBJ ] = TypeAList;
  TypeObjFuncs[ T_AREC ] = TypeARecord;
  TypeObjFuncs[ T_ACOMOBJ ] = TypeARecord;
  TypeObjFuncs[ T_TLREC ] = TypeTLRecord;
  /* install global variables */
  InitCopyGVar("TYPE_ALIST", &TYPE_ALIST);
  InitCopyGVar("TYPE_AREC", &TYPE_AREC);
  InitCopyGVar("TYPE_TLREC", &TYPE_TLREC);
  /* install mark functions */
  InitMarkFuncBags(T_ALIST, MarkAtomicList);
  InitMarkFuncBags(T_FIXALIST, MarkAtomicList);
  InitMarkFuncBags(T_APOSOBJ, MarkAtomicList);
  InitMarkFuncBags(T_AREC, MarkAtomicRecord);
  InitMarkFuncBags(T_ACOMOBJ, MarkAtomicRecord);
  InitMarkFuncBags(T_AREC_INNER, MarkAtomicRecord2);
  InitMarkFuncBags(T_TLREC, MarkTLRecord);
  /* install print functions */
  PrintObjFuncs[ T_ALIST ] = PrintAtomicList;
  PrintObjFuncs[ T_FIXALIST ] = PrintAtomicList;
  PrintObjFuncs[ T_AREC ] = PrintAtomicRecord;
  PrintObjFuncs[ T_TLREC ] = PrintTLRecord;
  /* install mutability functions */
  IsMutableObjFuncs [ T_ALIST ] = AlwaysYes;
  IsMutableObjFuncs [ T_FIXALIST ] = AlwaysYes;
  IsMutableObjFuncs [ T_AREC ] = AlwaysYes;
  /* mutability for T_ACOMOBJ and T_APOSOBJ is set in objects.c */
  MakeBagTypePublic(T_ALIST);
  MakeBagTypePublic(T_FIXALIST);
  MakeBagTypePublic(T_APOSOBJ);
  MakeBagTypePublic(T_AREC);
  MakeBagTypePublic(T_ACOMOBJ);
  MakeBagTypePublic(T_AREC_INNER);
  MakeBagTypePublic(T_TLREC);
  MakeBagTypePublic(T_TLREC_INNER);
  /* install list functions */

  for (UInt type = T_FIXALIST; type <= T_ALIST; type++) {
      IsListFuncs[type] = AlwaysYes;
      IsSmallListFuncs[type] = AlwaysYes;
      LenListFuncs[type] = LenListAList;
      LengthFuncs[type] = LengthAList;
      Elm0ListFuncs[type] = Elm0AList;
      ElmDefListFuncs[type] = ElmDefAList;
      Elm0vListFuncs[type] = Elm0AList;
      ElmListFuncs[type] = ElmAList;
      ElmvListFuncs[type] = ElmAList;
      ElmwListFuncs[type] = ElmAList;
      UnbListFuncs[type] = UnbAList;
      IsbListFuncs[type] = IsbAList;
  }

  AssListFuncs[T_FIXALIST] = AssFixAList;
  AssListFuncs[T_ALIST] = AssAList;


  /* AsssListFuncs[T_ALIST] = AsssAList; */
  /* install record functions */
  ElmRecFuncs[ T_AREC ] = ElmARecord;
  IsbRecFuncs[ T_AREC ] = IsbARecord;
  AssRecFuncs[ T_AREC ] = AssARecord;
  ShallowCopyObjFuncs[ T_AREC ] = ShallowCopyARecord;
  IsRecFuncs[ T_AREC ] = AlwaysYes;
  UnbRecFuncs[ T_AREC ] = UnbARecord;
  IsRecFuncs[ T_ACOMOBJ ] = AlwaysNo;
  ElmRecFuncs[ T_TLREC ] = ElmTLRecord;
  IsbRecFuncs[ T_TLREC ] = IsbTLRecord;
  AssRecFuncs[ T_TLREC ] = AssTLRecord;
  IsRecFuncs[ T_TLREC ] = AlwaysYes;
  UnbRecFuncs[ T_TLREC ] = UnbTLRecord;

  // Forbit various operations on atomic lists and records we can't
  // perform thread-safely.

  // Ensure that atomic objects cannot be copied
  for (UInt type = FIRST_ATOMIC_TNUM; type <= LAST_ATOMIC_TNUM; type++) {
      ShallowCopyObjFuncs[type] = AtomicErrorNoShallowCopy;
#if !defined(USE_THREADSAFE_COPYING)
      CopyObjFuncs[type] = AtomicErrorNoCopy;
      // Do not error on CleanObj, just leave it as a no-op
#endif // !defined(USE_THREADSAFE_COPYING)
  }


  // Ensure atomic lists can't be compared with other lists
  for (UInt type = FIRST_ATOMIC_LIST_TNUM; type <= LAST_ATOMIC_LIST_TNUM;
       type++) {
      for (UInt t2 = FIRST_LIST_TNUM; t2 <= LAST_LIST_TNUM; ++t2) {
          EqFuncs[type][t2] = AtomicListErrorNoCompare;
          EqFuncs[t2][type] = AtomicListErrorNoCompare;
          LtFuncs[type][t2] = AtomicListErrorNoCompare;
          LtFuncs[t2][type] = AtomicListErrorNoCompare;
      }
      for (UInt t2 = FIRST_ATOMIC_LIST_TNUM; t2 <= LAST_ATOMIC_LIST_TNUM;
           ++t2) {
          EqFuncs[type][t2] = AtomicListErrorNoCompare;
          EqFuncs[t2][type] = AtomicListErrorNoCompare;
          LtFuncs[type][t2] = AtomicListErrorNoCompare;
          LtFuncs[t2][type] = AtomicListErrorNoCompare;
      }
  }

  // Ensure atomic records can't be compared with other records
  for (UInt type = FIRST_ATOMIC_RECORD_TNUM; type <= LAST_ATOMIC_RECORD_TNUM;
       type++) {
      for (UInt t2 = FIRST_RECORD_TNUM; t2 <= LAST_RECORD_TNUM; ++t2) {
          EqFuncs[type][t2] = AtomicRecordErrorNoCompare;
          EqFuncs[t2][type] = AtomicRecordErrorNoCompare;
          LtFuncs[type][t2] = AtomicRecordErrorNoCompare;
          LtFuncs[t2][type] = AtomicRecordErrorNoCompare;
      }
      for (UInt t2 = FIRST_ATOMIC_RECORD_TNUM; t2 <= LAST_ATOMIC_RECORD_TNUM;
           ++t2) {
          EqFuncs[type][t2] = AtomicRecordErrorNoCompare;
          EqFuncs[t2][type] = AtomicRecordErrorNoCompare;
          LtFuncs[type][t2] = AtomicRecordErrorNoCompare;
          LtFuncs[t2][type] = AtomicRecordErrorNoCompare;
      }
  }

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
*F  InitInfoAObjects() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "aobjects",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .initModuleState = InitAObjectsState,
    .destroyModuleState = DestroyAObjectsState,
};

StructInitInfo * InitInfoAObjects ( void )
{
    return &module;
}
