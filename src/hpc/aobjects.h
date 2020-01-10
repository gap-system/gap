/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_AOBJECTS_H
#define GAP_AOBJECTS_H

#include "objects.h"
#include "hpc/atomic.h"

#ifndef HPCGAP
#error This header is only meant to be used with HPC-GAP
#endif

StructInitInfo *InitInfoAObjects(void);
Obj NewAtomicRecord(UInt capacity);
Obj SetARecordField(Obj record, UInt field, Obj obj);
Obj GetARecordField(Obj record, UInt field);
Obj ElmARecord(Obj record, UInt rnam);
BOOL IsbARecord(Obj record, UInt rnam);
void AssARecord(Obj record, UInt rnam, Obj value);
void UnbARecord(Obj record, UInt rnam);

void AssTLRecord(Obj record, UInt field, Obj obj);
Obj GetTLRecordField(Obj record, UInt field);
Obj FromAtomicRecord(Obj record);
void SetTLDefault(Obj record, UInt rnam, Obj value);
void SetTLConstructor(Obj record, UInt rnam, Obj func);

Obj NewAtomicList(UInt tnum, UInt capacity);
Obj FromAtomicList(Obj list);
UInt AddAList(Obj list, Obj obj);
void AssAList(Obj list, Int pos, Obj obj);
Obj ElmAList(Obj list, Int pos);
Obj Elm0AList(Obj list, Int pos);
Obj LengthAList(Obj list);


/*****************************************************************************
**
*F  CompareAndSwapObj(<addr>, <old>, <new_>)
**
**  Atomically compare *<addr> with <old> and exchange for <new_>.
**
**  The function implements the usual compare-and-swap semantics for
**  objects. It atomically does the following:
**
**    (1) Compare *<addr> with <old>.
**    (2) Exchange *<addr> with <new_> if the comparison succeeded.
**
**  It returns a non-zero value if the comparison in (1) succeeded, zero
**  otherwise.
**  markuspf: renamed new to new_ for compatibility with C++ packages.
*/

EXPORT_INLINE int CompareAndSwapObj(Obj *addr, Obj old, Obj new_) {
#ifndef WARD_ENABLED
  return COMPARE_AND_SWAP((AtomicUInt *) addr,
    (AtomicUInt) old, (AtomicUInt) new_);
#endif
}

/*****************************************************************************
**
*F  ATOMIC_SET_ELM_PLIST(<list>, <index>, <value>)
*F  ATOMIC_SET_ELM_PLIST_ONCE(<list>, <index>, <value>)
*F  ATOMIC_ELM_PLIST(<list>, <index>)
**
**  Set or access plain lists atomically. The plain lists must be of fixed
**  size and not be resized concurrently with such operations. The functions
**  assume that <index> is in the range 1..LEN_PLIST(<list>).
**
**  <value> must be an atomic or immutable object or access to it must be
**  properly regulated by locks.
**
**  'ATOMIC_ELM_PLIST' and 'ATOMIC_SET_ELM_PLIST' read and write plain lists,
**  annotated with memory barriers that ensure that concurrent threads do
**  not read objects that have not been fully initialized.
**
**  'ATOMIC_SET_ELM_PLIST_ONCE' assigns a value similar to 'SET_PLIST',
**  but only if <list>[<index>] is currently unbound. If that value has
**  been bound already, it will return the existing value; otherwise it
**  assigns <value> and returns it.
**
**  Canonical usage to read or initialize the field of a plist is as
**  follows:
**
**    obj = ATOMIC_ELM_PLIST(list, index);
**    if (!obj) {
**       obj = ...;
**       obj = ATOMIC_SET_ELM_PLIST(list, index, obj);
**    }
**
**  This construction ensures that while <obj> may be calculated more
**  than once, all threads will share the same value; furthermore,
**  reading an alreadu initialized value is generally very cheap,
**  incurring the cost of a read, a read barrier, and a branch (which,
**  after initialization, will generally predicted correctly by branch
**  prediction logic).
*/


EXPORT_INLINE void ATOMIC_SET_ELM_PLIST(Obj list, UInt index, Obj value) {
#ifndef WARD_ENABLED
  Obj *contents = ADDR_OBJ(list);
  MEMBAR_WRITE(); /* ensure that contents[index] becomes visible to
                   * other threads only after value has become visible,
                   * too.
                   */
  contents[index] = value;
#endif
}

EXPORT_INLINE Obj ATOMIC_SET_ELM_PLIST_ONCE(Obj list, UInt index, Obj value) {
#ifndef WARD_ENABLED
  Obj *contents = ADDR_OBJ(list);
  Obj result;
  for (;;) {
    result = contents[index];
    if (result) {
      MEMBAR_READ(); /* matching memory barrier. */
      return result;
    }
    if (COMPARE_AND_SWAP((AtomicUInt *)(contents+index),
      (AtomicUInt) 0, (AtomicUInt) value)) {
      /* no extra memory barrier needed, a full barrier is implicit in the
       * COMPARE_AND_SWAP() call.
       */
      return value;
    }
  }
#endif
}

EXPORT_INLINE Obj ATOMIC_ELM_PLIST(Obj list, UInt index) {
#ifndef WARD_ENABLED
  const Obj *contents = CONST_ADDR_OBJ(list);
  Obj result;
  result = contents[index];
  MEMBAR_READ(); /* matching memory barrier. */
  return result;
#endif
}

#endif // GAP_AOBJECTS_H
