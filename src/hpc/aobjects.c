/****************************************************************************
**
*W  threadapi.c                 GAP source                    Reimer Behrends
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the GAP interface for thread primitives.
*/
#include <assert.h>
#include <setjmp.h>                     /* jmp_buf, setjmp, longjmp */
#include <string.h>                     /* memcpy */
#include <stdlib.h>

#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>

#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/read.h>                   /* reader */
#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */
#include <src/ariths.h>                 /* basic arithmetic */

#include <src/gmpints.h>                /* integers */
#include <src/bool.h>                   /* booleans */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/listoper.h>               /* operations for generic lists */
#include <src/listfunc.h>               /* functions for generic lists */
#include <src/plist.h>                  /* plain lists */

#include <src/code.h>                   /* coder */

#include <src/exprs.h>                  /* expressions */
#include <src/stats.h>                  /* statements */
#include <src/funcs.h>                  /* functions */

#include <src/fibhash.h>

#include <src/stringobj.h>

#include <src/hpc/thread.h>
#include <src/hpc/traverse.h>
#include <src/hpc/tls.h>
#include <src/vars.h>                   /* variables */

#include <src/hpc/aobjects.h>


#include <src/intrprtr.h>               /* interpreter */

#include <src/compiler.h>               /* compiler */

Obj TYPE_ALIST;
Obj TYPE_AREC;
Obj TYPE_TLREC;

#define ALIST_LEN(x) ((x) >> 2)
#define ALIST_POL(x) ((x) & 3)
#define CHANGE_ALIST_LEN(x, y) (((x) & 3) | ((y) << 2))
#define CHANGE_ALIST_POL(x, y) (((x) & ~3) | y)

#define ALIST_RW 0
#define ALIST_W1 1
#define ALIST_WX 2

#define AREC_RW 1
#define AREC_W1 0
#define AREC_WX (-1)

typedef union AtomicObj
{
  AtomicUInt atom;
  Obj obj;
} AtomicObj;

#define ADDR_ATOM(bag) ((AtomicObj *)(ADDR_OBJ(bag)))

#ifndef WARD_ENABLED

static UInt UsageCap[sizeof(UInt)*8];

Obj TypeAList(Obj obj)
{
  Obj result;
  Obj *addr;
  addr = ADDR_OBJ(obj);
  MEMBAR_READ();
  result = addr[1];
  return result != NULL ? result : TYPE_ALIST;
}

Obj TypeARecord(Obj obj)
{
  Obj result;
  MEMBAR_READ();
  result = ADDR_OBJ(obj)[0];
  return result != NULL ? result : TYPE_AREC;
}

int IsTypedARecord(Obj obj)
{
  MEMBAR_READ();
  return TNUM_OBJ(obj) == T_AREC && ADDR_OBJ(obj)[0] != NULL;
}

Obj TypeTLRecord(Obj obj)
{
  return TYPE_TLREC;
}

void SetTypeAList(Obj obj, Obj kind)
{
  switch (TNUM_OBJ(obj)) {
    case T_ALIST:
    case T_FIXALIST:
      HashLock(obj);
      ADDR_OBJ(obj)[1] = kind;
      CHANGED_BAG(obj);
      RetypeBag(obj, T_APOSOBJ);
      HashUnlock(obj);
      break;
    case T_APOSOBJ:
      HashLock(obj);
      ADDR_OBJ(obj)[1] = kind;
      CHANGED_BAG(obj);
      HashUnlock(obj);
      break;
  }
  MEMBAR_WRITE();
}

void SetTypeARecord(Obj obj, Obj kind)
{
  ADDR_OBJ(obj)[0] = kind;
  CHANGED_BAG(obj);
  RetypeBag(obj, T_ACOMOBJ);
  MEMBAR_WRITE();
}


static Int AlwaysMutable( Obj obj)
{
  return 1;
}

static void ArgumentError(char *message)
{
  ErrorQuit(message, 0, 0);
}

static Obj NewFixedAtomicList(UInt length)
{
  Obj result = NewBag(T_FIXALIST, sizeof(AtomicObj) * (length + 2));
  MEMBAR_WRITE();
  return result;
}

Obj NewAtomicList(UInt length)
{
  Obj result = NewBag(T_ALIST, sizeof(AtomicObj) * (length + 2));
  MEMBAR_WRITE();
  return result;
}

static Obj NewAtomicListFrom(Obj list)
{
  Obj result;
  UInt len, i;
  AtomicObj *data;
  len = LEN_LIST(list);
  result = NewAtomicList(len);
  data = ADDR_ATOM(result);
  data++->atom = CHANGE_ALIST_LEN(ALIST_RW, len);
  data++->obj = NULL;
  for (i=1; i<= len; i++)
    data++->obj = ELM0_LIST(list, i);
  MEMBAR_WRITE(); /* Should not be necessary, but better be safe. */
  CHANGED_BAG(result);
  return result;
}

static Obj FuncAtomicList(Obj self, Obj args)
{
  Obj init;
  Obj result;
  AtomicObj *data;
  Int i, len;
  switch (LEN_PLIST(args)) {
    case 1:
      init = ELM_PLIST(args, 1);
      if (!IS_LIST(init) && (!IS_INTOBJ(init) || INT_INTOBJ(init) <=0) )
        ArgumentError("AtomicList: Argument must be list or positive integer");
      if (IS_LIST(init)) {
	return NewAtomicListFrom(init);
      } else {
        len = INT_INTOBJ(init);
	result = NewAtomicList(len);
	data = ADDR_ATOM(result);
	data++->atom = CHANGE_ALIST_LEN(ALIST_RW, len);
	data++->obj = NULL;
	for (i=1; i<= len; i++)
	  data++->obj = (Obj) 0;
	CHANGED_BAG(result);
	MEMBAR_WRITE(); /* Should not be necessary, but better be safe. */
	return result;
      }
    case 2:
      if (!IS_INTOBJ(ELM_PLIST(args, 1)))
        ArgumentError("AtomicList: First argument must be a non-negative integer");
      len = INT_INTOBJ(ELM_PLIST(args, 1));
      if (len < 0)
        ArgumentError("AtomicList: First argument must be a non-negative integer");
      result = NewAtomicList(len);
      init = ELM_PLIST(args, 2);
      data = ADDR_ATOM(result);
      data++->atom = CHANGE_ALIST_LEN(ALIST_RW, len);
      data++->obj = NULL;
      for (i=1; i<=len; i++)
        data++->obj = init;
      CHANGED_BAG(result);
      MEMBAR_WRITE(); /* Should not be necessary, but better be safe. */
      return result;
    default:
      ArgumentError("AtomicList: Too many arguments");
      return (Obj) 0; /* flow control hint */
  }
}

static Obj FuncFixedAtomicList(Obj self, Obj args)
{
  Obj init;
  Obj result;
  AtomicObj *data;
  Int i, len;
  switch (LEN_PLIST(args)) {
    case 1:
      init = ELM_PLIST(args, 1);
      if (!IS_LIST(init) && (!IS_INTOBJ(init) || INT_INTOBJ(init) <=0) )
        ArgumentError("FixedAtomicList: Argument must be list or positive integer");
      if (IS_LIST(init)) {
	len = LEN_LIST(init);
	result = NewFixedAtomicList(len);
	data = ADDR_ATOM(result);
	data++->atom = CHANGE_ALIST_LEN(ALIST_RW, len);
	data++->obj = NULL;
	for (i=1; i<= len; i++)
	  data++->obj = ELM0_LIST(init, i);
	CHANGED_BAG(result);
	MEMBAR_WRITE(); /* Should not be necessary, but better be safe. */
	return result;
      } else {
        len = INT_INTOBJ(init);
	result = NewFixedAtomicList(len);
	data = ADDR_ATOM(result);
	data++->atom = CHANGE_ALIST_LEN(ALIST_RW, len);
	data++->obj = NULL;
	for (i=1; i<= len; i++)
	  data++->obj = (Obj) 0;
	CHANGED_BAG(result);
	MEMBAR_WRITE(); /* Should not be necessary, but better be safe. */
	return result;
      }
    case 2:
      if (!IS_INTOBJ(ELM_PLIST(args, 1)))
        ArgumentError("FixedAtomicList: First argument must be a non-negative integer");
      len = INT_INTOBJ(ELM_PLIST(args, 1));
      if (len < 0)
        ArgumentError("FixedAtomicList: First argument must be a non-negative integer");
      result = NewFixedAtomicList(len);
      init = ELM_PLIST(args, 2);
      data = ADDR_ATOM(result);
      data++->atom = CHANGE_ALIST_LEN(ALIST_RW, len);
      data++->obj = NULL;
      for (i=1; i<=len; i++)
        data++->obj = init;
      CHANGED_BAG(result);
      MEMBAR_WRITE(); /* Should not be necessary, but better be safe. */
      return result;
    default:
      ArgumentError("FixedAtomicList: Too many arguments");
      return (Obj) 0; /* flow control hint */
  }
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
          ArgumentError("MakeFixedAtomicList: Argument must be atomic list");
	  return (Obj) 0; /* flow control hint */
      }
      HashUnlock(list);
      break;
    default:
      ArgumentError("MakeFixedAtomicList: Argument must be atomic list");
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
  Obj result;
  AtomicObj *addr;
  if (TNUM_OBJ(list) != T_ALIST && TNUM_OBJ(list) != T_FIXALIST)
    ArgumentError("GET_ATOMIC_LIST: First argument must be an atomic list");
  addr = ADDR_ATOM(list);
  len = ALIST_LEN((UInt) addr[0].atom);
  if (!IS_INTOBJ(index))
    ArgumentError("GET_ATOMIC_LIST: Second argument must be an integer");
  n = INT_INTOBJ(index);
  if (n <= 0 || n > len)
    ArgumentError("GET_ATOMIC_LIST: Index out of range");
  MEMBAR_READ(); /* read barrier */
  return addr[n+1].obj;
}

static Obj FuncSET_ATOMIC_LIST(Obj self, Obj list, Obj index, Obj value)
{
  UInt n;
  UInt len;
  AtomicObj *addr;
  if (TNUM_OBJ(list) != T_ALIST && TNUM_OBJ(list) != T_FIXALIST)
    ArgumentError("SET_ATOMIC_LIST: First argument must be an atomic list");
  addr = ADDR_ATOM(list);
  len = ALIST_LEN((UInt) addr[0].atom);
  if (!IS_INTOBJ(index))
    ArgumentError("SET_ATOMIC_LIST: Second argument must be an integer");
  n = INT_INTOBJ(index);
  if (n <= 0 || n > len)
    ArgumentError("SET_ATOMIC_LIST: Index out of range");
  addr[n+1].obj = value;
  CHANGED_BAG(list);
  MEMBAR_WRITE(); /* write barrier */
  return (Obj) 0;
}

static Obj FuncCOMPARE_AND_SWAP(Obj self, Obj list, Obj index, Obj old, Obj new)
{
  UInt n;
  UInt len;
  AtomicObj aold, anew;
  AtomicObj *addr;
  Obj result;
  switch (TNUM_OBJ(list)) {
    case T_FIXALIST:
    case T_APOSOBJ:
      break;
    default:
      ArgumentError("COMPARE_AND_SWAP: First argument must be a fixed atomic list");
  }
  addr = ADDR_ATOM(list);
  len = ALIST_LEN((UInt)addr[0].atom);
  if (!IS_INTOBJ(index))
    ArgumentError("COMPARE_AND_SWAP: Second argument must be an integer");
  n = INT_INTOBJ(index);
  if (n <= 0 || n > len)
    ArgumentError("COMPARE_AND_SWAP: Index out of range");
  aold.obj = old;
  anew.obj = new;
  result = COMPARE_AND_SWAP(&(addr[n+1].atom), aold.atom, anew.atom) ?
    True : False;
  if (result == True)
    CHANGED_BAG(list);
  return result;
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
      ArgumentError("ATOMIC_ADDITION: First argument must be a fixed atomic list");
  }
  addr = ADDR_ATOM(list);
  len = ALIST_LEN((UInt) addr[0].atom);
  if (!IS_INTOBJ(index))
    ArgumentError("ATOMIC_ADDITION: Second argument must be an integer");
  n = INT_INTOBJ(index);
  if (n <= 0 || n > len)
    ArgumentError("ATOMIC_ADDITION: Index out of range");
  if (!IS_INTOBJ(inc))
    ArgumentError("ATOMIC_ADDITION: increment is not an integer");
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
  AtomicObj *data;
  UInt i, len;
  if (TNUM_OBJ(list) != T_ALIST)
    ArgumentError("AddAtomicList: First argument must be an atomic list");
  return INTOBJ_INT(AddAList(list, obj));
}

Obj FromAtomicList(Obj list)
{
  Obj result;
  AtomicObj *data;
  UInt i, len;
  data = ADDR_ATOM(list);
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
    ArgumentError("FromAtomicList: First argument must be an atomic list");
  return FromAtomicList(list);
}

static void MarkAtomicList(Bag bag)
{
  UInt len;
  AtomicObj *ptr, *ptrend;
  ptr = ADDR_ATOM(bag);
  len = ALIST_LEN((UInt)(ptr++->atom));
  ptrend = ptr + len + 1;
  while (ptr < ptrend)
    MARK_BAG(ptr++->obj);
}

/* T_AREC_INNER substructure:
 * ADDR_OBJ(rec)[0] == capacity, must be a power of 2.
 * ADDR_OBJ(rec)[1] == log2(capacity).
 * ADDR_OBJ(rec)[2] == estimated size (occupied slots).
 * ADDR_OBJ(rec)[3] == update policy.
 * ADDR_OBJ(rec)[4..] == hash table of pairs of objects
 */

#define AR_CAP 0
#define AR_BITS 1
#define AR_SIZE 2
#define AR_POL 3
#define AR_DATA 4

/* T_TLREC_INNER substructure:
 * ADDR_OBJ(rec)[0] == number of subrecords
 * ADDR_OBJ(rec)[1] == default values
 * ADDR_OBJ(rec)[2] == constructors
 * ADDR_OBJ(rec)[3..] == table of per-thread subrecords
 */

#define TLR_SIZE 0
#define TLR_DEFAULTS 1
#define TLR_CONSTRUCTORS 2
#define TLR_DATA 3

static void MarkTLRecordInner(Bag bag)
{
  Bag *ptr, *ptrend;
  UInt n;
  ptr = PTR_BAG(bag);
  n = (UInt) *ptr;
  ptrend = ptr + n + TLR_DATA;
  ptr++;
  while (ptr < ptrend) {
    MARK_BAG(*ptr);
    ptr++;
  }
}

static Obj GetTLInner(Obj obj)
{
  Obj contents = ADDR_ATOM(obj)->obj;
  MEMBAR_READ(); /* read barrier */
  return contents;
}

static void MarkTLRecord(Bag bag)
{
  Bag contents = GetTLInner(bag);
  MARK_BAG(contents);
}


static void MarkAtomicRecord(Bag bag)
{
  MARK_BAG(GetTLInner(bag));
}

static void MarkAtomicRecord2(Bag bag)
{
  AtomicObj *p = ADDR_ATOM(bag);
  UInt cap = p->atom;
  p += 5;
  while (cap) {
    MARK_BAG(p->obj);
    p += 2;
    cap--;
  }
}

static void ExpandTLRecord(Obj obj)
{
  AtomicObj contents, newcontents;
  Obj *table, *newtable;
  do {
    contents = *ADDR_ATOM(obj);
    table = ADDR_OBJ(contents.obj);
    UInt thread = TLS(threadID);
    if (thread < (UInt)*table)
      return;
    newcontents.obj = NewBag(T_TLREC_INNER, sizeof(Obj) * (thread+TLR_DATA+1));
    newtable = ADDR_OBJ(newcontents.obj);
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
      ALIST_LEN((UInt)(ADDR_OBJ(obj)[0])), 0L);
  else
    Pr("<atomic list of size %d>", ALIST_LEN((UInt)(ADDR_OBJ(obj)[0])), 0L);
}

static inline Obj ARecordObj(Obj record)
{
  return ADDR_OBJ(record)[1];
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
  Obj *table = ADDR_OBJ(contents);
  Obj record = 0;
  Obj defrec = table[TLR_DEFAULTS];
  int comma = 0;
  AtomicObj *deftable;
  int i;
  if (TLS(threadID) < (UInt)table[TLR_SIZE]) {
    record = table[TLR_DATA+TLS(threadID)];
  }
  Pr("%2>rec( %2>", 0L, 0L);
  if (record) {
    for (i = 1; i <= LEN_PREC(record); i++) {
      Obj val = GET_ELM_PREC(record, i);
      Pr("%I", (Int)NAME_RNAM(labs((Int)GET_RNAM_PREC(record, i))), 0L);
      Pr ("%< := %>", 0L, 0L);
      if (val)
	PrintObj(val);
      else
        Pr("<undefined>", 0L, 0L);
      if (i < LEN_PREC(record))
        Pr("%2<, %2>", 0L, 0L);
      else
        comma = 1;
    }
  }
  HashLockShared(defrec);
  deftable = ARecordTable(defrec);
  for (i = 0; i < deftable[AR_CAP].atom; i++) {
    UInt key = deftable[AR_DATA+2*i].atom;
    Obj value = deftable[AR_DATA+2*i+1].obj;
    UInt dummy;
    if (key && (!record || !FindPRec(record, key, &dummy, 0))) {
      if (comma)
	Pr("%2<, %2>", 0L, 0L);
      Pr("%I", (Int)(NAME_RNAM(key)), 0L);
      Pr ("%< := %>", 0L, 0L);
      PrintObj(CopyTraversed(value));
      comma = 1;
    }
  }
  HashUnlockShared(defrec);
  Pr(" %4<)", 0L, 0L);
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
  Int policy;
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
      if (policy < 0) {
        HashUnlockShared(record);
	return 0;
      }
      if (policy) {
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
      } else {
        Obj result;
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
        if (policy < 0) {
	  result = 0;
	  break;
	}
	if (policy) {
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
    if (policy < 0)
      result = (Obj) 0;
    else {
      if (policy)
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
    ArgumentError("FromAtomicRecord: First argument must be an atomic record");
  return FromAtomicRecord(record);
}

static Obj FuncFromAtomicComObj(Obj self, Obj comobj)
{
  if (TNUM_OBJ(comobj) != T_ACOMOBJ)
    ArgumentError("FromAtomicComObj: First argument must be an atomic record");
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
  table[AR_POL].atom = 1;
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

static void SetARecordUpdatePolicy(Obj record, UInt policy)
{
  AtomicObj *table = ARecordTable(record);
  table[AR_POL].atom = policy;
}

static UInt GetARecordUpdatePolicy(Obj record)
{
  AtomicObj *table = ARecordTable(record);
  return table[AR_POL].atom;
}

Obj ElmARecord(Obj record, UInt rnam)
{
  Obj result;
  for (;;) {
    result = GetARecordField(record, rnam);
    if (result)
      return result;
    ErrorReturnVoid("Record: '<atomic record>.%s' must have an assigned value",
      (UInt)NAME_RNAM(rnam), 0L,
      "you can 'return;' after assigning a value" );
  }
}

void AssARecord(Obj record, UInt rnam, Obj value)
{
   Obj result = SetARecordField(record, rnam, value);
   if (!result)
     ErrorReturnVoid("Record: '<atomic record>.%s' already has an assigned value",
       (UInt)NAME_RNAM(rnam), 0L,
       "you can 'return';");

}

void UnbARecord(Obj record, UInt rnam) {
   SetARecordField(record, rnam, Undefined);
}

Int IsbARecord(Obj record, UInt rnam)
{
  return GetARecordField(record, rnam) != (Obj) 0;
}

Obj ShallowCopyARecord(Obj obj)
{
  Obj copy, inner, innerCopy;
  HashLock(obj);
  copy = NewBag(TNUM_BAG(obj), SIZE_BAG(obj));
  memcpy(ADDR_OBJ(copy), ADDR_OBJ(obj), SIZE_BAG(obj));
  inner = ADDR_OBJ(obj)[1];
  innerCopy = NewBag(TNUM_BAG(inner), SIZE_BAG(inner));
  memcpy(ADDR_OBJ(innerCopy), ADDR_OBJ(inner), SIZE_BAG(inner));
  ADDR_OBJ(copy)[1] = innerCopy;
  HashUnlock(obj);
  CHANGED_BAG(innerCopy);
  CHANGED_BAG(copy);
  return copy;
}

Obj CopyARecord(Obj obj, Int mutable)
{
#if 0
  UInt i, len;
  Obj result;
  Obj copied = TLS(CopiedObjs);
  if (copied)
  {
    len = LEN_PLIST(copied);
    for (i=1; i<=len; i+=2) {
      if (ELM_PLIST(copied, i) == obj)
        return ELM_PLIST(copied, i+1);
    }
  }
  else
  {
    len = 0;
    TLS(CopiedObjs) = copied = NEW_PLIST(T_PLIST, 2);
    SET_LEN_PLIST(copied, 2);
  }
  result = ShallowCopyARecord(obj);
  SET_ELM_PLIST(copied, len+1, obj);
  SET_ELM_PLIST(copied, len+2, result);
  return result;
#endif
  return obj;
}

Obj CopyAList(Obj obj, Int mutable)
{
  return obj;
}

void CleanARecord(Obj obj)
{
}

void CleanAList(Obj obj)
{
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
  if (!tlrecord || !FindPRec(tlrecord, rnam, &pos, 1)) {
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
	  if (!FindPRec(tlrecord, rnam, &pos, 1))
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

Obj ElmTLRecord(Obj record, UInt rnam)
{
  Obj result;
  for (;;) {
    result = GetTLRecordField(record, rnam);
    if (result)
      return result;
    ErrorReturnVoid("Record: '<thread-local record>.%s' must have an assigned value",
      (UInt)NAME_RNAM(rnam), 0L,
      "you can 'return;' after assigning a value" );
  }
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

void UnbTLRecord(Obj record, UInt rnam)
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


Int IsbTLRecord(Obj record, UInt rnam)
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
      if (IS_INTOBJ(arg)) {
	if (INT_INTOBJ(arg) <= 0)
          ArgumentError("AtomicRecord: capacity must be a positive integer");
        return NewAtomicRecord(INT_INTOBJ(arg));
      }
      switch (TNUM_OBJ(arg)) {
        case T_PREC:
	case T_PREC+IMMUTABLE:
	  return NewAtomicRecordFrom(arg);
      }
      ArgumentError("AtomicRecord: argument must be an integer or record");
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
    ArgumentError("GET_ATOMIC_RECORD: First argument must be an atomic record");
  if (!IsStringConv(field))
    ArgumentError("GET_ATOMIC_RECORD: Second argument must be a string");
  fieldname = RNamName(CSTR_STRING(field));
  result = GetARecordField(record, fieldname);
  return result ? result : def;
}

static Obj FuncSET_ATOMIC_RECORD(Obj self, Obj record, Obj field, Obj value)
{
  UInt fieldname;
  Obj result;
  if (TNUM_OBJ(record) != T_AREC)
    ArgumentError("SET_ATOMIC_RECORD: First argument must be an atomic record");
  if (!IsStringConv(field))
    ArgumentError("SET_ATOMIC_RECORD: Second argument must be a string");
  fieldname = RNamName(CSTR_STRING(field));
  result = SetARecordField(record, fieldname, value);
  if (!result)
    ErrorQuit("SET_ATOMIC_RECORD: Field '%s' already exists",
      (UInt) CSTR_STRING(field), 0L);
  return result;
}

static Obj FuncUNBIND_ATOMIC_RECORD(Obj self, Obj record, Obj field)
{
  UInt fieldname;
  Obj exists;
  if (TNUM_OBJ(record) != T_AREC)
    ArgumentError("UNBIND_ATOMIC_RECORD: First argument must be an atomic record");
  if (!IsStringConv(field))
    ArgumentError("UNBIND_ATOMIC_RECORD: Second argument must be a string");
  fieldname = RNamName(CSTR_STRING(field));
  if (GetARecordUpdatePolicy(record) <= 0)
    ErrorQuit("UNBIND_ATOMIC_RECORD: Record elements cannot be changed",
      (UInt) CSTR_STRING(field), 0L);
  exists = GetARecordField(record, fieldname);
  if (exists)
    SetARecordField(record, fieldname, (Obj) 0);
  return (Obj) 0;
}

static Obj FuncATOMIC_RECORD_REPLACEMENT(Obj self, Obj record, Obj policy)
{
  if (TNUM_OBJ(record) != T_AREC)
    ArgumentError("ATOMIC_RECORD_REPLACEMENT: First argument must be an atomic record");
  if (policy == Fail)
    SetARecordUpdatePolicy(record, -1);
  else if (policy == False)
    SetARecordUpdatePolicy(record, 0);
  else if (policy == True)
    SetARecordUpdatePolicy(record, 1);
  else
    ArgumentError("ATOMIC_RECORD_REPLACEMENT: Second argument must be true, false, or fail");
  return (Obj) 0;
}

static Obj CreateTLDefaults(Obj defrec) {
  Region *saved_region = TLS(currentRegion);
  Obj result;
  UInt i;
  TLS(currentRegion) = LimboRegion;
  result = NewBag(T_PREC, SIZE_BAG(defrec));
  memcpy(ADDR_OBJ(result), ADDR_OBJ(defrec), SIZE_BAG(defrec));
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
  REGION(constructors) = LimboRegion;
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
  Obj result;
  switch (LEN_PLIST(args)) {
    case 0:
      return NewTLRecord(NEW_PREC(0), NEW_PREC(0));
    case 1:
      if (TNUM_OBJ(ELM_PLIST(args, 1)) != T_PREC)
        ArgumentError("ThreadLocalRecord: First argument must be a record");
      return NewTLRecord(ELM_PLIST(args, 1), NEW_PREC(0));
    case 2:
      if (TNUM_OBJ(ELM_PLIST(args, 1)) != T_PREC)
        ArgumentError("ThreadLocalRecord: First argument must be a record");
      if (TNUM_OBJ(ELM_PLIST(args, 2)) != T_PREC ||
          !OnlyConstructors(ELM_PLIST(args, 2)))
        ArgumentError("ThreadLocalRecord: Second argument must be a record containing parameterless functions");
      return NewTLRecord(ELM_PLIST(args, 1), ELM_PLIST(args, 2));
    default:
      ArgumentError("ThreadLocalRecord: Too many arguments");
      return (Obj) 0; /* flow control hint */
  }
}

static Obj FuncSetTLDefault(Obj self, Obj record, Obj name, Obj value)
{
  if (TNUM_OBJ(record) != T_TLREC)
    ArgumentError("SetTLDefault: First argument must be a thread-local record");
  if (!IS_STRING(name) && !IS_INTOBJ(name))
    ArgumentError("SetTLDefault: Second argument must be a string or integer");
  SetTLDefault(record, RNamObj(name), value);
  return (Obj) 0;
}

static Obj FuncSetTLConstructor(Obj self, Obj record, Obj name, Obj function)
{
  if (TNUM_OBJ(record) != T_TLREC)
    ArgumentError("SetTLConstructor: First argument must be a thread-local record");
  if (!IS_STRING(name) && !IS_INTOBJ(name))
    ArgumentError("SetTLConstructor: Second argument must be a string or integer");
  if (TNUM_OBJ(function) != T_FUNCTION)
    ArgumentError("SetTLConstructor: Third argument must be a function");
  SetTLConstructor(record, RNamObj(name), function);
  return (Obj) 0;
}

static Int IsListAList(Obj list)
{
  return 1;
}

static Int IsSmallListAList(Obj list)
{
  return 1;
}

static Int IsRecNot(Obj obj)
{
  return 0;
}

static Int IsRecYes(Obj obj)
{
  return 1;
}

static Int LenListAList(Obj list)
{
  MEMBAR_READ();
  return (Int)(ALIST_LEN((UInt)ADDR_ATOM(list)[0].atom));
}

Obj LengthAList(Obj list)
{
  MEMBAR_READ();
  return INTOBJ_INT(ALIST_LEN((UInt)ADDR_ATOM(list)[0].atom));
}

Obj Elm0AList(Obj list, Int pos)
{
  AtomicObj *addr = ADDR_ATOM(list);
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
  AtomicObj *addr = ADDR_ATOM(list);
  UInt len;
  MEMBAR_READ();
  len = ALIST_LEN((UInt)addr[0].atom);
  Obj result;
  while (pos < 1 || pos > len) {
    Obj posobj;
    do {
      posobj = ErrorReturnObj(
	"Atomic List Element: <pos>=%d is an invalid index for <list>",
	(Int) pos, 0L,
	"you can replace value <pos> via 'return <pos>;'" );
    } while (!IS_INTOBJ(posobj));
    pos = INT_INTOBJ(posobj);
  }
  for (;;) {
    result = addr[1+pos].obj;
    if (result) {
      MEMBAR_READ();
      return result;
    }
    ErrorReturnVoid(
	"Atomic List Element: <list>[%d] must have an assigned value",
	(Int)pos, 0L,
	"you can 'return;' after assigning a value" );
  }
}

Int IsbAList(Obj list, Int pos) {
  AtomicObj *addr = ADDR_ATOM(list);
  UInt len;
  MEMBAR_READ();
  len = ALIST_LEN((UInt) addr[0].atom);
  return pos >= 1 && pos <= len && addr[1+pos].obj;
}

void AssFixAList(Obj list, Int pos, Obj obj)
{
  UInt pol = (UInt)ADDR_ATOM(list)[0].atom;
  UInt len = ALIST_LEN(pol);
  while (pos < 1 || pos > len) {
    Obj posobj;
    do {
      posobj = ErrorReturnObj(
	"Atomic List Element: <pos>=%d is an invalid index for <list>",
	(Int) pos, 0L,
	"you can replace value <pos> via 'return <pos>;'" );
    } while (!IS_INTOBJ(posobj));
    pos = INT_INTOBJ(posobj);
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

void AssAList(Obj list, Int pos, Obj obj)
{
  AtomicObj *addr;
  UInt len, newlen, pol;
  if (pos < 1) {
    ErrorQuit(
	"Atomic List Element: <pos>=%d is an invalid index for <list>",
	(Int) pos, 0L);
    return; /* flow control hint */
  }
  HashLockShared(list);
  addr = ADDR_ATOM(list);
  pol = (UInt)addr[0].atom;
  len = ALIST_LEN(pol);
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
      ErrorQuit("Atomic List Assignment: extending fixed size atomic list",
	0L, 0L);
      return; /* flow control hint */
    }
    addr = ADDR_ATOM(list);
    if (pos > SIZE_BAG(list)/sizeof(AtomicObj) - 2) {
      Obj newlist;
      newlen = len;
      do {
	newlen = newlen * 3 / 2 + 1 ;
      } while (pos > newlen);
      newlist = NewBag(T_ALIST, sizeof(AtomicObj) * ( 2 + newlen));
      memcpy(PTR_BAG(newlist), PTR_BAG(list), sizeof(AtomicObj)*(2+len));
      addr = ADDR_ATOM(newlist);
      addr[0].atom = CHANGE_ALIST_LEN(pol, pos);
      MEMBAR_WRITE();
      /* TODO: Won't work with GASMAN */
      PTR_BAG(list) = PTR_BAG(newlist);
      MEMBAR_WRITE();
    } else {
      addr[0].atom = CHANGE_ALIST_LEN(pol, pos);
      MEMBAR_WRITE();
    }
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
	HashUnlock(list);
	ErrorQuit("Atomic List Assignment: <list>[%d] already has an assigned value", pos, (Int) 0);
      }
      break;
  }
  CHANGED_BAG(list);
  MEMBAR_WRITE();
  HashUnlock(list);
}

UInt AddAList(Obj list, Obj obj)
{
  AtomicObj *addr;
  UInt len, newlen, pol;
  HashLock(list);
  if (TNUM_OBJ(list) != T_ALIST) {
    HashUnlock(list);
    ErrorQuit("Atomic List Assignment: extending fixed size atomic list",
      0L, 0L);
    return 0; /* flow control hint */
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
    PTR_BAG(list) = PTR_BAG(newlist);
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

void UnbAList(Obj list, Int pos)
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

void InitAObjectsState()
{
    TLS(tlRecords) = (Obj)0;
}

void DestroyAObjectsState()
{
    Obj  records;
    UInt i, len;
    records = TLS(tlRecords);
    if (records) {
        len = LEN_PLIST(records);
        for (i = 1; i <= len; i++)
            UpdateThreadRecord(ELM_PLIST(records, i), (Obj)0);
    }
}

#endif /* WARD_ENABLED */

Obj MakeAtomic(Obj obj) {
  if (IS_LIST(obj))
    return NewAtomicListFrom(obj);
  else if (TNUM_OBJ(obj) == T_PREC)
    return NewAtomicRecordFrom(obj);
  else
    return (Obj) 0;
}

Obj FuncMakeWriteOnceAtomic(Obj self, Obj obj) {
  switch (TNUM_OBJ(obj)) {
    case T_ALIST:
    case T_FIXALIST:
    case T_APOSOBJ:
      HashLock(obj);
      ADDR_ATOM(obj)[0].atom =
        CHANGE_ALIST_POL(ADDR_ATOM(obj)[0].atom, ALIST_W1);
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

Obj FuncMakeReadWriteAtomic(Obj self, Obj obj) {
  switch (TNUM_OBJ(obj)) {
    case T_ALIST:
    case T_FIXALIST:
    case T_APOSOBJ:
      HashLock(obj);
      ADDR_ATOM(obj)[0].atom =
        CHANGE_ALIST_POL(ADDR_ATOM(obj)[0].atom, ALIST_RW);
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

Obj FuncMakeStrictWriteOnceAtomic(Obj self, Obj obj) {
  switch (TNUM_OBJ(obj)) {
    case T_ALIST:
    case T_FIXALIST:
    case T_APOSOBJ:
      HashLock(obj);
      ADDR_ATOM(obj)[0].atom =
        CHANGE_ALIST_POL(ADDR_ATOM(obj)[0].atom, ALIST_WX);
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

Obj BindOncePosObj(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
  Int n;
  Bag *contents;
  Bag result;
  if (!IS_INTOBJ(index) || ((n = INT_INTOBJ(index)) <= 0)) {
    FuncError("index for positional object must be a positive integer");
    return (Obj) 0; /* flow control hint */
  }
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
      PTR_BAG(obj) = (void *)(mptr[0]);
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

Obj BindOnceAPosObj(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
  UInt n;
  UInt len;
  AtomicObj anew;
  AtomicObj *addr;
  Obj result;
  /* atomic positional objects aren't resizable. */
  addr = ADDR_ATOM(obj);
  MEMBAR_READ();
  len = ALIST_LEN(addr[0].atom);
  if (!IS_INTOBJ(index))
    FuncError("Second argument must be an integer");
  n = INT_INTOBJ(index);
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


Obj BindOnceComObj(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
  FuncError("not yet implemented");
  return (Obj) 0;
}


Obj BindOnceAComObj(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
  FuncError("not yet implemented");
  return (Obj) 0;
}


Obj BindOnce(Obj obj, Obj index, Obj *new, int eval, const char *currFuncName) {
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

Obj FuncBindOnce(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 0, "BindOnce");
  return result ? result : new;
}

Obj FuncStrictBindOnce(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 0, "StrictBindOnce");
  if (result)
    ErrorQuit("StrictBindOnce: Element already initialized", 0L, 0L);
  return result;
}

Obj FuncTestBindOnce(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 0, "TestBindOnce");
  return result ? False : True;
}

Obj FuncBindOnceExpr(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 1, "BindOnceExpr");
  return result ? result : new;
}

Obj FuncTestBindOnceExpr(Obj self, Obj obj, Obj index, Obj new) {
  Obj result;
  result = BindOnce(obj, index, &new, 1, "TestBindOnceExpr");
  return result ? False : True;
}


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/

static StructGVarFunc GVarFuncs [] = {

    { "AtomicList", -1, "list|count, obj",
      FuncAtomicList, "src/aobjects.c:AtomicList" },

    { "FixedAtomicList", -1, "list|count, obj",
      FuncFixedAtomicList, "src/aobjects.c:FixedAtomicList" },

    { "MakeFixedAtomicList", 1, "list",
      FuncMakeFixedAtomicList, "src/aobjects.c:MakeFixedAtomicList" },

    { "FromAtomicList", 1, "list",
      FuncFromAtomicList, "src/aobjects.c:FromAtomicList" },

    { "AddAtomicList", 2, "list, obj",
      FuncAddAtomicList, "src/aobjects.c:AddAtomicList" },

    { "GET_ATOMIC_LIST", 2, "list, index",
      FuncGET_ATOMIC_LIST, "src/aobjects.c:GET_ATOMIC_LIST" },

    { "SET_ATOMIC_LIST", 3, "list, index, value",
      FuncSET_ATOMIC_LIST, "src/aobjects.c:SET_ATOMIC_LIST" },

    { "COMPARE_AND_SWAP", 4, "list, index, old, new",
      FuncCOMPARE_AND_SWAP, "src/aobjects.c:COMPARE_AND_SWAP" },

    { "ATOMIC_ADDITION", 3, "list, index, inc",
      FuncATOMIC_ADDITION, "src/aobjects.c:ATOMIC_ADDITION" },

    { "AtomicRecord", -1, "[capacity]",
      FuncAtomicRecord, "src/aobjects.c:AtomicRecord" },
   
    { "IS_ATOMIC_LIST", 1, "object",
      FuncIS_ATOMIC_LIST, "src/abjects.c:IS_ATOMIC_LIST" },

    { "IS_FIXED_ATOMIC_LIST", 1, "object",
      FuncIS_FIXED_ATOMIC_LIST, "src/abjects.c:IS_FIXED_ATOMIC_LIST" },

    { "IS_ATOMIC_RECORD", 1, "object",
      FuncIS_ATOMIC_RECORD, "src/abjects.c:IS_ATOMIC_RECORD" },

    { "GET_ATOMIC_RECORD", 3, "record, field, default",
      FuncGET_ATOMIC_RECORD, "src/aobjects.c:GET_ATOMIC_RECORD" },

    { "SET_ATOMIC_RECORD", 3, "record, field, value",
      FuncSET_ATOMIC_RECORD, "src/aobjects.c:SET_ATOMIC_RECORD" },

    { "UNBIND_ATOMIC_RECORD", 2, "record, field",
      FuncUNBIND_ATOMIC_RECORD, "src/aobjects.c:UNBIND_ATOMIC_RECORD" },

    { "ATOMIC_RECORD_REPLACEMENT", 2, "record, policy",
      FuncATOMIC_RECORD_REPLACEMENT, "src/aobjects.c:ATOMIC_RECORD_REPLACEMENT" },
    { "FromAtomicRecord", 1, "record",
      FuncFromAtomicRecord, "src/aobjects.c:FromAtomicRecord" },

    { "FromAtomicComObj", 1, "record",
      FuncFromAtomicComObj, "src/aobjects.c:FromAtomicComObj" },

    { "ThreadLocalRecord", -1, "record [, record]",
      FuncThreadLocalRecord, "src/aobjects.c:ThreadLocalRecord" },

    { "SetTLDefault", 3, "thread-local record, name, value",
      FuncSetTLDefault, "src/aobjects.c:SetTLDefault" },

    { "SetTLConstructor", 3, "thread-local record, name, function",
      FuncSetTLConstructor, "src/aobjects.c:SetTLConstructor" },

    { "MakeWriteOnceAtomic", 1, "obj",
      FuncMakeWriteOnceAtomic, "src/aobjects.c:MakeWriteOnceAtomic" },

    { "MakeReadWriteAtomic", 1, "obj",
      FuncMakeReadWriteAtomic, "src/aobjects.c:MakeReadWriteAtomic" },

    { "MakeStrictWriteOnceAtomic", 1, "obj",
      FuncMakeStrictWriteOnceAtomic, "src/aobjects.c:MakeStrictWriteOnceAtomic" },

    { "BindOnce", 3, "obj, index, value",
      FuncBindOnce, "src/aobjects.c:BindOnce" },

    { "StrictBindOnce", 3, "obj, index, value",
      FuncStrictBindOnce, "src/aobjects.c:StrictBindOnce" },

    { "TestBindOnce", 3, "obj, index, value",
      FuncTestBindOnce, "src/aobjects.c:TestBindOnce" },

    { "BindOnceExpr", 3, "obj, index, func",
      FuncBindOnceExpr, "src/aobjects.c:BindOnceExpr" },

    { "TestBindOnceExpr", 3, "obj, index, func",
      FuncTestBindOnceExpr, "src/aobjects.c:TestBindOnceExpr" },

    { 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  UInt i, cap;
  /* compute UsageCap */
  for (i=0; i<=3; i++)
    UsageCap[i] = (1<<i)-1;
  UsageCap[4] = 13;
  UsageCap[5] = 24;
  UsageCap[6] = 48;
  UsageCap[7] = 96;
  for (i=8; i<sizeof(UInt)*8; i++)
    UsageCap[i] = (1<<i)/3 * 2;
  /* install info string */
  InfoBags[T_ALIST].name = "atomic list";
  InfoBags[T_FIXALIST].name = "fixed atomic list";
  InfoBags[T_APOSOBJ].name = "atomic positional object";
  InfoBags[T_AREC].name = "atomic record";
  InfoBags[T_ACOMOBJ].name = "atomic component object";
  InfoBags[T_TLREC].name = "thread-local record";
  
  /* install the kind methods */
  TypeObjFuncs[ T_ALIST ] = TypeAList;
  TypeObjFuncs[ T_FIXALIST ] = TypeAList;
  TypeObjFuncs[ T_APOSOBJ ] = TypeAList;
  TypeObjFuncs[ T_AREC ] = TypeARecord;
  TypeObjFuncs[ T_ACOMOBJ ] = TypeARecord;
  TypeObjFuncs[ T_TLREC ] = TypeTLRecord;
  SetTypeObjFuncs[ T_ALIST ] = SetTypeAList;
  SetTypeObjFuncs[ T_FIXALIST ] = SetTypeAList;
  SetTypeObjFuncs[ T_APOSOBJ ] = SetTypeAList;
  SetTypeObjFuncs[ T_AREC ] = SetTypeARecord;
  SetTypeObjFuncs[ T_ACOMOBJ ] = SetTypeARecord;
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
  IsMutableObjFuncs [ T_ALIST ] = AlwaysMutable;
  IsMutableObjFuncs [ T_FIXALIST ] = AlwaysMutable;
  IsMutableObjFuncs [ T_AREC ] = AlwaysMutable;
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
  /* install list functions */
  IsListFuncs[T_FIXALIST] = IsListAList;
  IsSmallListFuncs[T_FIXALIST] = IsSmallListAList;
  LenListFuncs[T_FIXALIST] = LenListAList;
  LengthFuncs[T_FIXALIST] = LengthAList;
  Elm0ListFuncs[T_FIXALIST] = Elm0AList;
  Elm0vListFuncs[T_FIXALIST] = Elm0AList;
  ElmListFuncs[T_FIXALIST] = ElmAList;
  ElmvListFuncs[T_FIXALIST] = ElmAList;
  ElmwListFuncs[T_FIXALIST] = ElmAList;
  AssListFuncs[T_FIXALIST] = AssFixAList;
  UnbListFuncs[T_FIXALIST] = UnbAList;
  IsbListFuncs[T_FIXALIST] = IsbAList;
  CopyObjFuncs[ T_FIXALIST ] = CopyAList;
  CleanObjFuncs[ T_FIXALIST ] = CleanAList;
  IsListFuncs[T_ALIST] = IsListAList;
  IsSmallListFuncs[T_ALIST] = IsSmallListAList;
  LenListFuncs[T_ALIST] = LenListAList;
  LengthFuncs[T_ALIST] = LengthAList;
  Elm0ListFuncs[T_ALIST] = Elm0AList;
  Elm0vListFuncs[T_ALIST] = Elm0AList;
  ElmListFuncs[T_ALIST] = ElmAList;
  ElmvListFuncs[T_ALIST] = ElmAList;
  ElmwListFuncs[T_ALIST] = ElmAList;
  AssListFuncs[T_ALIST] = AssAList;
  UnbListFuncs[T_ALIST] = UnbAList;
  IsbListFuncs[T_ALIST] = IsbAList;
  CopyObjFuncs[ T_ALIST ] = CopyAList;
  CleanObjFuncs[ T_ALIST ] = CleanAList;
  CopyObjFuncs[ T_APOSOBJ ] = CopyAList;
  CleanObjFuncs[ T_APOSOBJ ] = CleanAList;
  /* AsssListFuncs[T_ALIST] = AsssAList; */
  /* install record functions */
  ElmRecFuncs[ T_AREC ] = ElmARecord;
  IsbRecFuncs[ T_AREC ] = IsbARecord;
  AssRecFuncs[ T_AREC ] = AssARecord;
  CopyObjFuncs[ T_AREC ] = CopyARecord;
  ShallowCopyObjFuncs[ T_AREC ] = ShallowCopyARecord;
  CleanObjFuncs[ T_AREC ] = CleanARecord;
  IsRecFuncs[ T_AREC ] = IsRecYes;
  UnbRecFuncs[ T_AREC ] = UnbARecord;
  CopyObjFuncs[ T_ACOMOBJ ] = CopyARecord;
  CleanObjFuncs[ T_ACOMOBJ ] = CleanARecord;
  IsRecFuncs[ T_ACOMOBJ ] = IsRecNot;
  ElmRecFuncs[ T_TLREC ] = ElmTLRecord;
  IsbRecFuncs[ T_TLREC ] = IsbTLRecord;
  AssRecFuncs[ T_TLREC ] = AssTLRecord;
  IsRecFuncs[ T_TLREC ] = IsRecYes;
  UnbRecFuncs[ T_TLREC ] = UnbTLRecord;
  /* return success                                                      */
  return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
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
*F  InitInfoAObjects() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "aobjects",                         /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                         		/* postRestore                    */
};

StructInitInfo * InitInfoAObjects ( void )
{
    return &module;
}
