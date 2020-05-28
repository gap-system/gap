/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions that deal with weak pointer objects.
**  A weak pointer object looks like a plain list, except that its entries
**  are NOT kept alive through a garbage collection (unless they are contained
**  in some other kind of object).
*/

#include "weakptr.h"

#include "bool.h"
#include "error.h"
#ifdef USE_GASMAN
#include "gasman_intern.h"
#endif
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "saveload.h"

#ifdef HPCGAP
#include "hpc/guards.h"
#include "hpc/traverse.h"
#endif

#ifdef USE_BOEHM_GC
# ifdef HPCGAP
#  define GC_THREADS
# endif
# include <gc/gc.h>
#endif

#ifdef USE_JULIA_GC
#include "julia.h"
#include "julia_gc.h"
#endif

#define RequireWPObj(funcname, op)                                           \
    RequireArgumentCondition(funcname, op, TNUM_OBJ(op) == T_WPOBJ,          \
                             "must be a weak pointer object")


/****************************************************************************
**
*F
*/

#if defined(USE_BOEHM_GC)

static inline void REGISTER_WP(Obj wp, UInt pos, Obj obj)
{
    void ** ptr = (void **)(ADDR_OBJ(wp) + pos);
    GC_general_register_disappearing_link(ptr, obj);
}

static inline void FORGET_WP(Obj wp, UInt pos)
{
    void ** ptr = (void **)(ADDR_OBJ(wp) + pos);
    GC_unregister_disappearing_link(ptr);
}

#endif


/****************************************************************************
**
*F  STORE_LEN_WPOBJ(<wp>,<len>) . . . . . . . . set the length of a WP object
**
**  'STORE_LEN_WPOBJ' sets the length of the WP object <wp> to <len>.
** 
**  Objects at the end of <wp> may evaporate, so the stored length can only
**  be regarded as an upper bound.
*/
static inline void STORE_LEN_WPOBJ(Obj wp, Int len)
{
    ADDR_OBJ(wp)[0] = INTOBJ_INT(len);
}


/****************************************************************************
**
*F  STORED_LEN_WPOBJ(<wp>) . . . . . . . . . . . stored length of a WP object
**
**  'STORED_LEN_WPOBJ' returns the stored length of the WP object <wp> 
**  as a C integer.
**
**  Note that as the list can mutate under your feet, the length may be
**  an overestimate.
*/
static inline Int STORED_LEN_WPOBJ(Obj wp)
{
    return INT_INTOBJ(CONST_ADDR_OBJ(wp)[0]);
}


/****************************************************************************
**
*F  ELM_WPOBJ(<wp>,<pos>) . . . . . . . . . . . . .  get entry of a WP object
**
**  'ELM_WPOBJ' return the <pos>-th element of the WP object <wp>. <pos> must
**  be a positive integer less than or equal  to the physical length of <wp>.
**  If <wp> has no assigned element at position <pos>, 'ELM_WPOBJ' returns 0.
*/
static inline Obj ELM_WPOBJ(Obj list, UInt pos)
{
    Bag elm = CONST_ADDR_OBJ(list)[pos];

#ifdef USE_GASMAN
    if (IsWeakDeadBag(elm)) {
        ADDR_OBJ(list)[pos] = 0;
        return 0;
    }
#endif

#ifdef USE_JULIA_GC
    if (!IS_BAG_REF(elm))
        return elm;
    jl_weakref_t * wref = (jl_weakref_t *)elm;
    if (wref->value == jl_nothing) {
        ADDR_OBJ(list)[pos] = 0;
        return 0;
    }
    elm = (Obj)(wref->value);
#endif

    return elm;
}


/****************************************************************************
**
*F  SET_ELM_WPOBJ(<wp>,<pos>,<val>) . . . . . . . .  set entry of a WP object
**
**  'SET_ELM_WPOBJ' sets the <pos>-th element of the WP object <wp> to <val>.
*/
static inline void SET_ELM_WPOBJ(Obj list, UInt pos, Obj val)
{
#ifndef USE_JULIA_GC
    ADDR_OBJ(list)[pos] = val;
#else
    Obj * ptr = ADDR_OBJ(list);
    if (!IS_BAG_REF(val)) {
        ptr[pos] = val;
        return;
    }
    if (!IS_BAG_REF(ptr[pos])) {
        ptr[pos] = (Bag)jl_gc_new_weakref((jl_value_t *)val);
        jl_gc_wb_back(BAG_HEADER(list));
    }
    else {
        jl_weakref_t * wref = (jl_weakref_t *)(ptr[pos]);
        wref->value = (jl_value_t *)val;
        jl_gc_wb(wref, BAG_HEADER(val));
    }
#endif
}


/****************************************************************************
**
*F  GROW_WPOBJ(<wp>,<need>) . . .  ensure weak pointer object is large enough
**
**  'GROW_WPOBJ' grows the weak pointer object <wp> if necessary to ensure
**  that it has room for at least <need> elements.
*/
static inline void GROW_WPOBJ(Obj wp, UInt need)
{
  UInt                plen;           /* new physical length             */
  UInt                good;           /* good new physical length        */

    // if there is already enough space, do nothing
    if (need < SIZE_OBJ(wp)/sizeof(Obj))
        return;

    if (need > INT_INTOBJ_MAX)
        ErrorMayQuit("GrowWPObj: List size too large", 0, 0);

    // find out how large the object should become at least (we grow by
    // at least 25%, like plain lists)
    /* find out how large the plain list should become                     */
    good = 5 * (SIZE_OBJ(wp)/sizeof(Obj)-1) / 4 + 4;

    /* but maybe we need more                                              */
    if ( need < good ) { plen = good; }
    else               { plen = need; }

    if (plen > INT_INTOBJ_MAX)
        plen = INT_INTOBJ_MAX;

#ifdef USE_BOEHM_GC
    Obj copy = NewBag(T_WPOBJ, (plen+1) * sizeof(Obj));
    STORE_LEN_WPOBJ(copy, STORED_LEN_WPOBJ(wp));

    UInt i;
    for (i = 1; i <= STORED_LEN_WPOBJ(wp); i++) {
      volatile Obj tmp = ELM_WPOBJ(wp, i);
#ifdef HPCGAP
      MEMBAR_READ();
#endif
      if (IS_BAG_REF(tmp) && ELM_WPOBJ(wp, i)) {
        FORGET_WP(wp, i);
        REGISTER_WP(copy, i, tmp);
      }
      SET_ELM_WPOBJ(wp, i, 0);
      SET_ELM_WPOBJ(copy, i, tmp);
    }
    SET_PTR_BAG(wp, PTR_BAG(copy));
#else
    // resize the weak pointer object
    ResizeBag( wp, ((plen)+1)*sizeof(Obj) );
#endif
}


/****************************************************************************
**
*F  FuncWeakPointerObj(<self>,<list>) . . . . . .  make a weak pointer object
**
**  Handler for the GAP function WeakPointerObject(<list>), which makes a new
**  WP object.
*/

static Obj FuncWeakPointerObj(Obj self, Obj list)
{
  Obj wp; 
  Int i;
  Int len; 
#ifdef USE_BOEHM_GC
  /* We need to make sure that the list stays live until
   * after REGISTER_WP(); on architectures that pass
   * arguments in registers (x86_64, SPARC, etc), the
   * argument register may be reused. In conjunction with
   * loop unrolling, the reference to 'list' may then be
   * destroyed before REGISTER_WP() is called.
   */
  volatile Obj list2 = list;
#endif
  len = LEN_LIST(list);
  if (len > INT_INTOBJ_MAX)
      ErrorMayQuit("WeakPointerObj: List size too large", 0, 0);

  wp = (Obj) NewBag(T_WPOBJ, (len+1)*sizeof(Obj));
  STORE_LEN_WPOBJ(wp,len); 
  for (i = 1; i <= len ; i++) 
    { 
#ifdef USE_BOEHM_GC
      Obj tmp = ELM0_LIST(list2, i);
      SET_ELM_WPOBJ(wp, i, tmp);
      if (IS_BAG_REF(tmp))
        REGISTER_WP(wp, i, tmp);
#else
      SET_ELM_WPOBJ(wp, i, ELM0_LIST(list, i));
#endif
      CHANGED_BAG(wp);          /* this must be here in case list is 
                                 in fact an object and causes a GC in the 
                                 element access method */
    }

  return wp; 
} 


/****************************************************************************
**
*F  LengthWPObj(<wp>) . . . . . . . . . . . . . . current length of WP object
**
**  'LengthWPObj' returns the length of the WP object <wp> as a C integer.
**  The value cannot be trusted past a garbage collection, as trailing items
**  may evaporate.
**   
**  Any identifiers of trailing objects that have evaporated in a garbage
**  collection are cleaned up by this function. However, for HPC-GAP, this
**  only happens if we have exclusive write access.
*/

static Int LengthWPObj(Obj wp)
{
  Int changed = 0;
  Int len = STORED_LEN_WPOBJ(wp);
#ifdef HPCGAP
  if (!CheckExclusiveWriteAccess(wp))
    return len;
#endif

  Obj elm;
  while (len > 0) {
    elm = ELM_WPOBJ(wp, len);
    if (elm)
        break;
    changed = 1;
    len--;
  }
  if (changed)
    STORE_LEN_WPOBJ(wp,len);
  return len;
}

/****************************************************************************
**
*F  FuncLengthWPObj(<wp>) . . . . . . . . . . . . current length of WP object
**
**  'FuncLengthWPObj' is a handler for a GAP function that returns the length
**  of the WP object <wp>. The value cannot be trusted past a garbage
**  collection, as trailing items may evaporate.
*/

static Obj FuncLengthWPObj(Obj self, Obj wp)
{
    RequireWPObj(SELF_NAME, wp);
    return INTOBJ_INT(LengthWPObj(wp));
}


/****************************************************************************
**
*F  FuncSetElmWPObj(<self>,<wp>,<pos>,<obj>) . .  set an entry in a WP object
**
**  'FuncSetElmWPObj'  is a handler for a GAP function that sets an entry in
**  a WP object.
*/

static Obj FuncSetElmWPObj(Obj self, Obj wp, Obj pos, Obj val)
{
    RequireWPObj(SELF_NAME, wp);
    UInt ipos = GetPositiveSmallInt("SetElmWPObj", pos);

#ifdef USE_BOEHM_GC
  /* Ensure reference remains visible to GC in case val is
   * stored in a register and the register is reused before
   * REGISTER_WP() is called.
   */
  volatile Obj val2 = val;
#endif
  if (LengthWPObj(wp)  < ipos)
    {
      GROW_WPOBJ(wp, ipos);
      STORE_LEN_WPOBJ(wp,ipos);
    }
#ifdef USE_BOEHM_GC
  volatile Obj tmp = ELM_WPOBJ(wp, ipos);
#ifdef HPCGAP
  MEMBAR_READ();
#endif
  if (IS_BAG_REF(tmp) && ELM_WPOBJ(wp, ipos))
    FORGET_WP(wp, ipos);
  SET_ELM_WPOBJ(wp, ipos, val2);
  if (IS_BAG_REF(val2))
    REGISTER_WP(wp, ipos, val2);
#else
  SET_ELM_WPOBJ(wp, ipos, val);
#endif
  CHANGED_BAG(wp);
  return 0;
}

/****************************************************************************
**
*F  IsBoundElmWPObj(<wp>,<pos>) .  . . . . is an entry bound in a WP object
**
**  'IsBoundElmWPObj' returns 1 is there is (currently) a live
**  value at position pos or the WP object wp and  0 otherwise, cleaning up a
**  dead entry if there is one
** */


static BOOL IsBoundElmWPObj(Obj wp, Obj pos)
{
    RequireWPObj("IsBoundElmWPObj", wp);
    UInt ipos = GetPositiveSmallInt("IsBoundElmWPObj", pos);

#ifdef HPCGAP
  volatile
#endif
  Obj elm;
  if ( LengthWPObj(wp) < ipos ) 
    {
      return 0;
    }
  elm = ELM_WPOBJ(wp,ipos);
#ifdef HPCGAP
  MEMBAR_READ();
  if (elm == 0 || ELM_WPOBJ(wp, ipos) == 0)
      return 0;
#else
  if (elm == 0)
      return 0;
#endif
  return 1;
}

/****************************************************************************
**
*F  FuncIsBoundElmWPObj(<self>,<wp>,<pos>) . . IsBound handler for WP objects
**
**  GAP  handler for IsBound  test on WP object.   Remember that bindings can
**  evaporate in any garbage collection.
*/
static Obj FuncIsBoundElmWPObj(Obj self, Obj wp, Obj pos)
{
  return IsBoundElmWPObj(wp, pos) ? True : False;
}


/****************************************************************************
**
*F  FuncUnbindElmWPObj(<self>,<wp>,<pos>) . . . Unbind handler for WP objects
**
**  GAP  handler for Unbind on WP object. 
*/

static Obj FuncUnbindElmWPObj(Obj self, Obj wp, Obj pos)
{
    RequireWPObj(SELF_NAME, wp);
    UInt ipos = GetPositiveSmallInt("UnbindElmWPObj", pos);

  Int len = LengthWPObj(wp);
  if ( ipos <= len ) {
#ifdef USE_BOEHM_GC
    /* Ensure the result is visible on the stack in case a garbage
     * collection happens after the read.
     */
    volatile Obj tmp = ELM_WPOBJ(wp, ipos);
#ifdef HPCGAP
    MEMBAR_READ();
#endif
    if (ELM_WPOBJ(wp, ipos)) {
      if (IS_BAG_REF(tmp))
        FORGET_WP(wp, ipos);
      SET_ELM_WPOBJ(wp, ipos, 0);
    }
#else
    SET_ELM_WPOBJ(wp, ipos, 0);
#endif
  }
  return 0;
}


/****************************************************************************
**
*F  ElmDefWPList(<wp>,<ipos>,<def>)
**
**  Provide implementation of 'ElmDefListFuncs'.
*/
static Obj ElmDefWPList(Obj wp, Int ipos, Obj def)
{
    GAP_ASSERT(TNUM_OBJ(wp) == T_WPOBJ);
    GAP_ASSERT(ipos >= 1);

#ifdef HPCGAP
  if ( LengthWPObj(wp) < ipos )
      return def;
#else
  if ( STORED_LEN_WPOBJ(wp) < ipos )
      return def;
#endif

#ifdef USE_BOEHM_GC
  volatile
#endif
  Obj elm = ELM_WPOBJ(wp,ipos);
#ifdef HPCGAP
  MEMBAR_READ();
  if (elm == 0 || ELM_WPOBJ(wp, ipos) == 0)
      return def;
#else
  if (elm == 0)
      return def;
#endif
  return elm;
}


/****************************************************************************
**
*F  FuncElmWPObj(<self>,<wp>,<pos>) . . . . . . . access entry of a WP object
**
**  GAP handler for access to WP object. If the entry is not bound, then fail
**  is  returned. It would not be  correct to return  an error, because there
**  would be no  way  to  safely access  an  element, which  might  evaporate
**  between a  call   to IsBound and the    access. This, of  course,  causes
**  possible  confusion  with a WP  object which  does have  a  value of fail
**  stored in  it. This, however  can be  checked  with a subsequent  call to
**  IsBound, relying on the fact  that fail can never  dissapear in a garbage
**  collection.
*/
static Obj FuncElmWPObj(Obj self, Obj wp, Obj pos)
{
    RequireWPObj(SELF_NAME, wp);
    UInt ipos = GetPositiveSmallInt("ElmWPObj", pos);

    return ElmDefWPList(wp, ipos, Fail);
}


/****************************************************************************
**
*F  TypeWPObj(<wp>) . . . . . . . . . . . . . . . . . . . . type of WP object
**
**  This returns the library variable TYPE_WPOBJ. All WP objects have the
**  same type.
*/

static Obj TYPE_WPOBJ;

static Obj TypeWPObj(Obj wp)
{
  return TYPE_WPOBJ;
}


/****************************************************************************
**
*F  FuncIsWPObj(<self>,<wp>) . . . . . . . . handler for GAP function IsWPObj
*/
static Obj IsWPObjFilt;

static Obj FiltIsWPObj(Obj self, Obj wp)
{
  return (TNUM_OBJ(wp) == T_WPOBJ) ? True : False;
}

/****************************************************************************
**
*F  MarkWeakPointerObj(<wp>) . . . . . . . . . . . . . . . . Marking function
*F  SweepWeakPointerObj(<src>,<dst>,<len>) . . . . . . . .  Sweeping function
**
**  These functions are installed for GASMAN to use in garbage collection.
**  The sweeping function must clean up any dead weak pointers encountered so
**  that, after a full GC, the masterpointers occupied by the dead weak
**  pointers can be reclaimed.  
*/

#if defined(USE_GASMAN)

static void MarkWeakPointerObj(Obj wp)
{
    // can't use the stored length here, in case we are in the middle of
    // copying
    const UInt len = SIZE_BAG(wp) / sizeof(Obj) - 1;
    for (UInt i = 1; i <= len; i++) {
        MarkBagWeakly(CONST_ADDR_OBJ(wp)[i]);
    }
}

static void SweepWeakPointerObj( Bag *src, Bag *dst, UInt len)
{
  Bag elm;
  while (len --)
    {
      elm = *src++;
      *dst ++ = IsWeakDeadBag(elm) ? (Bag) 0 : elm;
    }
}

#endif

#ifdef USE_JULIA_GC

static void MarkWeakPointerObj(Obj wp)
{
    // can't use the stored length here, in case we are in the middle of
    // copying
    const UInt len = SIZE_BAG(wp) / sizeof(Obj) - 1;
    for (UInt i = 1; i <= len; i++) {
        Bag elm = CONST_ADDR_OBJ(wp)[i];
        if (IS_BAG_REF(elm))
            MarkJuliaWeakRef(elm);
    }
}

#endif


#ifdef USE_THREADSAFE_COPYING
#ifndef WARD_ENABLED
static void TraverseWPObj(TraversalState * traversal, Obj obj)
{
    UInt  len = STORED_LEN_WPOBJ(obj);
    const Obj * ptr = CONST_ADDR_OBJ(obj) + 1;
    while (len) {
        volatile Obj tmp = *ptr;
        MEMBAR_READ();
        if (IS_BAG_REF(tmp) && IS_BAG_REF(*ptr))
            QueueForTraversal(traversal, *ptr);
        ptr++;
        len--;
    }
}

static void CopyWPObj(TraversalState * traversal, Obj copy, Obj original)
{
    UInt  len = STORED_LEN_WPOBJ(original);
    const Obj * ptr = CONST_ADDR_OBJ(original) + 1;
    Obj * copyptr = ADDR_OBJ(copy) + 1;
    while (len--) {
        volatile Obj tmp = *ptr;
        MEMBAR_READ();
        if (IS_BAG_REF(tmp) && IS_BAG_REF(*ptr)) {
            *copyptr = ReplaceByCopy(traversal, tmp);
#ifdef USE_BOEHM_GC
            GC_general_register_disappearing_link((void **)copyptr, tmp);
#endif
        }
        ptr++;
        copyptr++;
    }
}

#endif // WARD_ENABLED

#else

/****************************************************************************
**
*F  CopyObjWPObj(<obj>,<mut>) . . . . . . . . . . . . . . .  copy a WP object
**
**  Note  that an  immutable   copy of  a  weak  pointer  object is a  normal
**  immutable plist. An Immutable WP object is a contradiction.
**
*N  I am far from clear that this is safe from a badly timed GC during copying.
**
*/

static Obj CopyObjWPObj(Obj obj, Int mut)
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */
    Obj                 elm;
    UInt                i;              /* loop variable                   */

    // immutable input is handled by COPY_OBJ
    GAP_ASSERT(IS_MUTABLE_OBJ(obj));

    // This may get smaller if a GC occurs during copying
    UInt len = LengthWPObj(obj);

    /* make a copy                                                         */
    if ( mut ) {
        copy = NewBag( T_WPOBJ, SIZE_OBJ(obj) );
        ADDR_OBJ(copy)[0] = CONST_ADDR_OBJ(obj)[0];
    }
    else {
        copy = NEW_PLIST_IMM(T_PLIST, len);
        // Set length as plist is constructed
    }

    /* leave a forwarding pointer                                          */
    PrepareCopy(obj, copy);

    // copy the subvalues. Loop goes up so length of PLIST is set correctly
    for (i = 1; i <= len; i++) {
        elm = ELM_WPOBJ(obj, i);
        if (elm) {
            tmp = COPY_OBJ(elm, mut);
            if (mut)
                SET_ELM_WPOBJ(copy, i, tmp);
            else {
                SET_ELM_PLIST(copy, i, tmp);
                SET_LEN_PLIST(copy, i);
            }
            CHANGED_BAG( copy );
        }
    }

    /* return the copy                                                     */
    return copy;
}

#endif // !defined(USE_THREADSAFE_COPYING)


/****************************************************************************
**
*F  MakeImmutableWPObj(<obj>) . . . . . . . . . . . . make immutable in place
**
*/

static void MakeImmutableWPObj(Obj obj)
{
#ifdef USE_BOEHM_GC
  UInt i;
  UInt len = 0;
  Obj  copy = NEW_PLIST(T_PLIST, STORED_LEN_WPOBJ(obj));
  for (i = 1; i <= STORED_LEN_WPOBJ(obj); i++) {
#ifdef HPCGAP
    volatile Obj tmp = ELM_WPOBJ(obj, i);
    MEMBAR_READ();
    if (tmp) {
      if (IS_BAG_REF(tmp) && ELM_WPOBJ(obj, i)) {
        FORGET_WP(obj, i);
      }
      len = i;
    }
#else
    Obj tmp = ELM_WPOBJ(obj, i);
    if (tmp) {
      if (IS_BAG_REF(tmp)) {
        FORGET_WP(obj, i);
      }
      len = i;
    }
#endif
    SET_ELM_PLIST(copy, i, tmp);
  }
  SET_LEN_PLIST(copy, len);
  SET_PTR_BAG(obj, PTR_BAG(copy));

  // Note: there is brief moment here where the WP obj has been turned into a
  // mutable plist, but not yet been made immutable. This should be fine as
  // long as the object is non-public, i.e., owned exclusively by the current
  // thread.

#else
    // recompute stored length
    UInt len = LengthWPObj(obj);

    // remove any weak dead bags, by relying on side-effect of ELM_WPOBJ
    for (UInt i = 1; i <= len; i++) {
#ifdef USE_JULIA_GC
        Obj elm = ELM_WPOBJ(obj, i);
        if (IS_BAG_REF(elm)) {
            // write back the entries using ADDR_OBJ (not SET_ELM_WPOBJ) to
            // get rid of the jl_weakref_t objects
            ADDR_OBJ(obj)[i] = elm;
        }
#else
        ELM_WPOBJ(obj, i);
#endif
    }

    // change the type - this works correctly, as the layout of weak pointer
    // objects and plists is identical, and we removed all weak dead bags,
    // and set the length properly.
    RetypeBag(obj, (len == 0) ? T_PLIST_EMPTY : T_PLIST);
#endif

    // make the plist immutable (and recursively any subobjects); note that
    // this can cause garbage collections, hence we must do it after we
    // completed conversion of the WP object into a plist
    MakeImmutable(obj);
}

#if !defined(USE_THREADSAFE_COPYING)

/****************************************************************************
**
*F  CleanObjWPObj(<obj>) . . . . . . . . . . . . . . . . . .  clean WP object
*/
static void CleanObjWPObj(Obj obj)
{
    UInt                i;              /* loop variable                   */
    Obj                 elm;            /* subobject                       */

    /* clean the subvalues                                                 */
    for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i++ ) {
        elm = ELM_WPOBJ(obj, i);
        if (elm)
            CLEAN_OBJ(elm);
    }

}

#endif //!defined(USE_THREADSAFE_COPYING)


/****************************************************************************
**
*F  SaveWPObj(<wpobj>)
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveWPObj(Obj wpobj)
{
    UInt len = STORED_LEN_WPOBJ(wpobj);
    SaveUInt(len);
    for (UInt i = 1; i <= len; i++) {
        SaveSubObj(ELM_WPOBJ(wpobj, i));
    }
}
#endif


/****************************************************************************
**
*F  LoadWPObj(<wpobj>)
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadWPObj(Obj wpobj)
{
    const UInt len = LoadUInt();
    STORE_LEN_WPOBJ(wpobj, len);
    for (UInt i = 1; i <= len; i++) {
        SET_ELM_WPOBJ(wpobj, i, LoadSubObj());
    }
}
#endif


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_WPOBJ, "weak pointer object" },
  { -1,      ""                    }
};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IsWPObj, "obj", &IsWPObjFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(WeakPointerObj, list),
    GVAR_FUNC_1ARGS(LengthWPObj, wp),
    GVAR_FUNC_3ARGS(SetElmWPObj, wp, pos, val),
    GVAR_FUNC_2ARGS(IsBoundElmWPObj, wp, pos),
    GVAR_FUNC_2ARGS(UnbindElmWPObj, wp, pos),
    GVAR_FUNC_2ARGS(ElmWPObj, wp, pos),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel(<module>) . . . . . . . . .  initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the marking and sweeping methods                            */
#if defined(USE_BOEHM_GC)
    /* force atomic allocation of these pointers */
    InitMarkFuncBags ( T_WPOBJ,          MarkNoSubBags   );
#elif defined(USE_GASMAN)
    InitMarkFuncBags ( T_WPOBJ,          MarkWeakPointerObj   );
    InitSweepFuncBags( T_WPOBJ,          SweepWeakPointerObj  );
#elif defined(USE_JULIA_GC)
    InitMarkFuncBags ( T_WPOBJ,          MarkWeakPointerObj   );
#else
#error Unknown garbage collector implementation, no weak pointer object implemention available
#endif

    /* typing method                                                       */
    TypeObjFuncs[ T_WPOBJ ] = TypeWPObj;
    ImportGVarFromLibrary( "TYPE_WPOBJ", &TYPE_WPOBJ );

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* saving function                                                     */
#ifdef GAP_ENABLE_SAVELOAD
    SaveObjFuncs[ T_WPOBJ ] = SaveWPObj;
    LoadObjFuncs[ T_WPOBJ ] = LoadWPObj;
#endif

    // List functions
    ElmDefListFuncs[T_WPOBJ] = ElmDefWPList;

#ifdef USE_THREADSAFE_COPYING
    SetTraversalMethod(T_WPOBJ, TRAVERSE_BY_FUNCTION, TraverseWPObj, CopyWPObj);
#else
    /* copying functions                                                   */
    CopyObjFuncs[  T_WPOBJ           ] = CopyObjWPObj;
    CleanObjFuncs[ T_WPOBJ           ] = CleanObjWPObj;
#endif

    MakeImmutableObjFuncs[ T_WPOBJ ] = MakeImmutableWPObj;
    return 0;
}


/****************************************************************************
**
*F  InitLibrary(<module>) . . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  InitInfoWeakPtr() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "weakptr",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoWeakPtr ( void )
{
    return &module;
}
