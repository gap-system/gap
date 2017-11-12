/****************************************************************************
**
*W  weakptr.c                   GAP source                       Steve Linton
**
**
*Y  Copyright (C)  1997,  School of Mathematical and Computational Sciences,
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
*Y                        University of St Andrews, Scotland
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions that deal with weak pointer objects
**  A weak pointer object looks like a plain list, except that its entries
**  are NOT kept alive through a garbage collection (unless they are contained
**  in some other kind of object). 
*/
#include <src/system.h>                 /* system dependent part */


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/bool.h>                   /* booleans */

#include <src/weakptr.h>                /* weak pointers */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/saveload.h>               /* saving and loading */
#include <src/opers.h>                  /* generic operations */

#include <src/scanner.h>                /* scanner */
#include <src/hpc/guards.h>

#ifdef BOEHM_GC
# ifdef HPCGAP
#  define GC_THREADS
# endif
# include <gc/gc.h>
#endif


/****************************************************************************
**
*F  STORE_LEN_WPOBJ(<wp>,<len>) . . . . . . .  set the length of a WP object
**
**  'STORE_LEN_WPOBJ' sets the length of  the WP object  <wp> to <len>.
**
**  Note  that 'STORE_LEN_WPOBJ'  is a macro, so do not call it with  arguments
**  that have side effects.
** 
**  Objects at the end of wp may evaporate, so the stored length can only
**  be regarded as an upper bound.
*/

#define STORE_LEN_WPOBJ(wp,len)         (ADDR_OBJ(wp)[0] = (Obj)(len))


/****************************************************************************
**
*F  STORED_ LEN_WPOBJ(<wp>). . .. . . . . . .  stored length of a WP Object
**
**  'STORED_LEN_WPOBJ' returns the stored length of the WP object <wp> 
**  as a C integer.
**
**  Note that 'STORED_LEN_WPOBJ' is a  macro, so do  not call it 
**  with arguments that have side effects.
**
**  Note that as the list can mutate under your feet, the length may be
**  an overestimate
*/

#define STORED_LEN_WPOBJ(wp)                 ((Int)(CONST_ADDR_OBJ(wp)[0]))

/****************************************************************************
**
*F  ELM_WPOBJ(<wp>,<pos>) . . . . . . . . . . . . . element of a WP object
**
**  'ELM_WPOBJ' return the <wp>-th element of the WP object <wp>.  <pos> must
**  be a positive integer less than or equal  to the physical length of <wp>.
**  If <wp> has no assigned element at position <pos>, 'ELM_WPOBJ' returns 0.
**
**  If the entry died at a recent garbage collection, it will return a Bag ID
**  for which IS_WEAK_DEAD_BAG will return 1
**
**  Note that  'ELM_WPOBJ' is a macro, so do  not call it with arguments that
**  have side effects.  
**
**  ELM_WPOBJ(<wp>,<pos>) is a valid lvalue and may be assigned to
*/

#define ELM_WPOBJ(list,pos)             (ADDR_OBJ(list)[pos])


/****************************************************************************
**
*F  GROW_WPOBJ(<wp>,<plen>) . make sure a weak pointer object is large enough
**
**  'GROW_WPOBJ' grows the weak pointer   object <wp> if necessary  to
**  ensure that it has room for at least <plen> elements.
**
**  Note that 'GROW_WPOBJ' is a macro, so do not call it with arguments that
**  have side effects.  */

#define GROW_WPOBJ(wp,plen)   ((plen) < SIZE_OBJ(wp)/sizeof(Obj) ? \
                                 0L : GrowWPObj(wp,plen) )

Int GrowWPObj (
               Obj                 wp,
               UInt                need )
{
  UInt                plen;           /* new physical length             */
  UInt                good;           /* good new physical length        */

    /* find out how large the object should become                     */
    good = 5 * (SIZE_OBJ(wp)/sizeof(Obj)-1) / 4 + 4;

    /* but maybe we need more                                              */
    if ( need < good ) { plen = good; }
    else               { plen = need; }

#ifndef BOEHM_GC
    /* resize the plain list                                               */
    ResizeBag( wp, ((plen)+1)*sizeof(Obj) );
#else
    Obj copy = NewBag(T_WPOBJ, (plen+1) * sizeof(Obj));
    STORE_LEN_WPOBJ(copy, STORED_LEN_WPOBJ(wp));

    UInt i;
    for (i = 1; i <= STORED_LEN_WPOBJ(wp); i++) {
      volatile Obj tmp = ELM_WPOBJ(wp, i);
      MEMBAR_READ();
      if (IS_BAG_REF(tmp) && ELM_WPOBJ(wp, i)) {
        FORGET_WP(&ELM_WPOBJ(wp, i));
        REGISTER_WP(&ELM_WPOBJ(copy, i), tmp);
      }
      ELM_WPOBJ(wp, i) = 0;
      ELM_WPOBJ(copy, i) = tmp;
    }
    SET_PTR_BAG(wp, PTR_BAG(copy));
#endif

    /* return something (to please some C compilers)                       */
    return 0L;
}


/****************************************************************************
**
*F  FuncWeakPointerObj( <self>, <list> ) . . . . . .make a weak pointer object
**
** Handler  for the GAP function  WeakPointerObject(<list>), which makes a new
** WP object 
*/

Obj FuncWeakPointerObj( Obj self, Obj list ) { 
  Obj wp; 
  Int i;
  Int len; 
#ifdef BOEHM_GC
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
  wp = (Obj) NewBag(T_WPOBJ, (len+1)*sizeof(Obj));
  STORE_LEN_WPOBJ(wp,len); 
  for (i = 1; i <= len ; i++) 
    { 
#ifdef BOEHM_GC
      Obj tmp = ELM0_LIST(list2, i);
      ELM_WPOBJ(wp,i) = tmp;
      if (IS_BAG_REF(tmp))
        REGISTER_WP(&ELM_WPOBJ(wp, i), tmp);
#else
      ELM_WPOBJ(wp,i) = ELM0_LIST(list,i); 
#endif
      CHANGED_BAG(wp);          /* this must be here in case list is 
                                 in fact an object and causes a GC in the 
                                 element access method */
    }

  return wp; 
} 


/****************************************************************************
**
*F  LengthWPObj(<wp>) . . . . . . . . . . . . . . current length of WP Object
**
**  'LengthWPObj(<wp>)' returns  the   current length  of WP  Object  as  a C
**  integer  the   value cannot be   trusted past  a   garbage collection, as
**  trailing items may evaporate.
**   
**  Any identifiers of trailing objects that have evaporated in a garbage
**  collection are cleaned up by this function. However, for HPC-GAP, this
**  only happens if we have exclusive write access.
*/

Int LengthWPObj(Obj wp)
{
  Int changed = 0;
  Int len = STORED_LEN_WPOBJ(wp);
#ifdef HPCGAP
  if (!CheckExclusiveWriteAccess(wp))
    return len;
#endif

#ifndef BOEHM_GC
  Obj elm;
  while (len > 0 && 
         (!(elm = ELM_WPOBJ(wp,len)) ||
          IS_WEAK_DEAD_BAG(elm))) {
    changed = 1;
    if (elm)
      ELM_WPOBJ(wp,len) = 0;
    len--;
  }
#else
  while (len > 0 && !ELM_WPOBJ(wp, len)) {
    changed = 1;
    len--;
  }
#endif
  if (changed)
    STORE_LEN_WPOBJ(wp,len);
  return len;
}

/****************************************************************************
**
*F  FuncLengthWPObj(<wp>) . . . . . . . . . . . . current length of WP Object
**
**  'FuncLengthWPObj(<wp>)' is a handler for a  GAP function that returns the
**  current length of WP  Object. The value  cannot be trusted past a garbage
**  collection, as trailing items may evaporate.
** 
*/

Obj FuncLengthWPObj(Obj self, Obj wp)
{
  if (TNUM_OBJ(wp) != T_WPOBJ)
    {
      ErrorMayQuit("LengthWPObj: argument must be a weak pointer object, not a %s",
                   (Int)TNAM_OBJ(wp), 0);
    }
  return INTOBJ_INT(LengthWPObj(wp));
}


/****************************************************************************
**
*F  FuncSetElmWPObj(<self>, <wp>, <pos>, <obj> ) . set an entry in a WP Object
**
**  'FuncSetElmWPObj(<self>, <wp>,  <pos>, <obj>  )'  is a  handler for a GAP
**  function that sets an entry in a WP object.
** 
*/

Obj FuncSetElmWPObj(Obj self, Obj wp, Obj pos, Obj val)
{
  if (TNUM_OBJ(wp) != T_WPOBJ)
    {
      ErrorMayQuit("SetElmWPObj: First argument must be a weak pointer object, not a %s",
                   (Int)TNAM_OBJ(wp), 0);
    }

  if (!IS_INTOBJ(pos))
    {
      ErrorMayQuit("SetElmWPObj: Position must be a small integer, not a %s",
                (Int)TNAM_OBJ(pos),0L);
    }

  UInt ipos = INT_INTOBJ(pos);
  if (ipos < 1)
    {
      ErrorMayQuit("SetElmWPObj: Position must be a positive integer",0L,0L);
    }

#ifdef BOEHM_GC
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
#ifdef BOEHM_GC
  volatile Obj tmp = ELM_WPOBJ(wp, ipos);
  MEMBAR_READ();
  if (IS_BAG_REF(tmp) && ELM_WPOBJ(wp, ipos))
    FORGET_WP(&ELM_WPOBJ(wp, ipos));
  ELM_WPOBJ(wp,ipos) = val2;
  if (IS_BAG_REF(val2))
    REGISTER_WP(&ELM_WPOBJ(wp, ipos), val2);
#else
  ELM_WPOBJ(wp,ipos) = val;
#endif
  CHANGED_BAG(wp);
  return 0;
}

/****************************************************************************
**
*F  IsBoundElmWPObj( <wp>, <pos> ) .  . . . . is an entry bound in a WP Object
**
**  'IsBoundElmWPObj( <wp>, <pos> )' returns 1 is there is (currently) a live
**  value at position pos or the WP object wp and  0 otherwise, cleaning up a
**  dead entry if there is one
** */


Int IsBoundElmWPObj( Obj wp, Obj pos)
{
  if (TNUM_OBJ(wp) != T_WPOBJ)
    {
      ErrorMayQuit("IsBoundElmWPObj: First argument must be a weak pointer object, not a %s",
                   (Int)TNAM_OBJ(wp), 0);
    }

  if (!IS_INTOBJ(pos))
    {
      ErrorMayQuit("IsBoundElmWPObj: Position must be a small integer, not a %s",
                (Int)TNAM_OBJ(pos),0L);
    }

  UInt ipos = INT_INTOBJ(pos);
  if (ipos < 1)
    {
      ErrorMayQuit("IsBoundElmWPObj: Position must be a positive integer",0L,0L);
    }

#ifdef BOEHM_GC
  volatile
#endif
  Obj elm;
  if ( LengthWPObj(wp) < ipos ) 
    {
      return 0;
    }
  elm = ELM_WPOBJ(wp,ipos);
#ifdef BOEHM_GC
  MEMBAR_READ();
  if (elm == 0 || ELM_WPOBJ(wp, ipos) == 0)
      return 0;
#else
  if (IS_WEAK_DEAD_BAG(elm))
    {
      ELM_WPOBJ(wp,ipos) = 0;
      return 0;
    }
  if (elm == 0)
      return 0;
#endif
  return 1;
}

/****************************************************************************
**
*F  FuncIsBoundElmWPObj( <self>, <wp>, <pos> ) . . . . . . .IsBound WP Object
**
**  GAP  handler for IsBound  test on WP Object.   Remember that bindings can
**  evaporate in any garbage collection.
*/


Obj FuncIsBoundElmWPObj( Obj self, Obj wp, Obj pos)
{
  return IsBoundElmWPObj(wp, pos) ? True : False;
}


/****************************************************************************
**
*F  FuncUnbindElmWPObj( <self>, <wp>, <pos> ) . . . . . . . .Unbind WP Object
**
**  GAP  handler for Unbind on WP Object. 
*/

Obj FuncUnbindElmWPObj( Obj self, Obj wp, Obj pos)
{
  if (TNUM_OBJ(wp) != T_WPOBJ)
    {
      ErrorMayQuit("UnbindElmWPObj: First argument must be a weak pointer object, not a %s",
                   (Int)TNAM_OBJ(wp), 0);
    }

  if (!IS_INTOBJ(pos))
    {
      ErrorMayQuit("UnbindElmWPObj: Position must be a small integer, not a %s",
                (Int)TNAM_OBJ(pos),0L);
    }

  UInt ipos = INT_INTOBJ(pos);
  if (ipos < 1)
    {
      ErrorMayQuit("UnbindElmWPObj: Position must be a positive integer",0L,0L);
    }

  Int len = LengthWPObj(wp);
  if ( ipos <= len ) {
#ifndef BOEHM_GC
    ELM_WPOBJ( wp, ipos) =  0;
#else
    /* Ensure the result is visible on the stack in case a garbage
     * collection happens after the read.
     */
    volatile Obj tmp = ELM_WPOBJ(wp, ipos);
    MEMBAR_READ();
    if (ELM_WPOBJ(wp, ipos)) {
      if (IS_BAG_REF(tmp))
        FORGET_WP( &ELM_WPOBJ(wp, ipos));
      ELM_WPOBJ( wp, ipos) =  0;
    }
#endif
  }
  return 0;
}


/****************************************************************************
**
*F  FuncElmWPObj( <self>, <wp>, <pos> ) . . . . . . . . . . .Access WP Object
**
**  GAP handler for access to WP Object. If the entry is not bound, then fail
**  is  returned. It would not be  correct to return  an error, because there
**  would be no  way  to  safely access  an  element, which  might  evaporate
**  between a  call   to Isbound and the    access. This, of  course,  causes
**  possible  confusion  with a WP  object which  does have  a  value of fail
**  stored in  it. This, however  can be  checked  with a subsequent  call to
**  IsBound, relying on the fact  that fail can never  dissapear in a garbage
**  collection.
*/

#include <stdio.h>

// Provide implementation of ElmDefListFuncs
Obj ElmDefWPList(Obj wp, Int ipos, Obj def)
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

#ifdef BOEHM_GC
  volatile
#endif
  Obj elm = ELM_WPOBJ(wp,ipos);
#ifdef BOEHM_GC
  MEMBAR_READ();
  if (elm == 0 || ELM_WPOBJ(wp, ipos) == 0)
      return def;
#else
  if (IS_WEAK_DEAD_BAG(elm))
    {
      ELM_WPOBJ(wp,ipos) = 0;
      return def;
    }
  if (elm == 0)
      return def;
#endif
  return elm;
}

Obj FuncElmWPObj(Obj self, Obj wp, Obj pos)
{
    if (TNUM_OBJ(wp) != T_WPOBJ) {
        ErrorMayQuit("ElmWPObj: First argument must be a weak pointer "
                     "object, not a %s",
                     (Int)TNAM_OBJ(wp), 0);
    }

    if (!IS_INTOBJ(pos)) {
        ErrorMayQuit("ElmWPObj: Position must be a small integer, not a %s",
                     (Int)TNAM_OBJ(pos), 0L);
    }

    Int ipos = INT_INTOBJ(pos);
    if (ipos < 1) {
        ErrorMayQuit("ElmWPObj: Position must be a positive integer", 0L, 0L);
    }

    return ElmDefWPList(wp, ipos, Fail);
}


/****************************************************************************
**
*F  TypeWPObj( <wp> ) . . . . . . . . . . . . . . . . . . . Type of WP Object
**
**  This is imported from the library variable  TYPE_WPOBJ. They all have the
**  same type
*/

Obj TYPE_WPOBJ;              

Obj TypeWPObj( Obj wp )
{
  return TYPE_WPOBJ;
}


/****************************************************************************
**
*F  FuncIsWPObj( <self>, <wp>) . . . . . . . Handler for GAP function IsWPObj
*/
static Obj IsWPObjFilt;

Obj FuncIsWPObj( Obj self, Obj wp)
{
  return (TNUM_OBJ(wp) == T_WPOBJ) ? True : False;
}

/****************************************************************************
**
*F  MarkWeakPointerObj( <wp> ) . . . . . . . . . . . . . . . Marking function
*F  SweepWeakPointerObj( <src>, <dst>, <len> ) . . . . . . .Sweeping function
**
**  These functions are installed for GASMAN to use in garbage collection. The
**  sweeping function must  clean up any  dead  weak pointers encountered  so
**  that, after a  full  GC, the  masterpointers  occupied by the  dead  weak
**  pointers can be reclaimed.  
*/

#if !defined(BOEHM_GC)

static void MarkWeakPointerObj( Obj wp) 
{
  Int i;
  /* can't use the stored length here, in case we
     are in the middle of copying */
  for (i = 1; i <= (SIZE_BAG(wp)/sizeof(Obj))-1; i++)
    MarkBagWeakly(ELM_WPOBJ(wp,i));
}

static void SweepWeakPointerObj( Bag *src, Bag *dst, UInt len)
{
  Bag elm;
  while (len --)
    {
      elm = *src++;
      *dst ++ = IS_WEAK_DEAD_BAG(elm) ? (Bag) 0 : elm;
    }
}

#endif


/****************************************************************************
**
*F  CopyObjWPObj( <obj>, <mut> ) . . . . . . . . .  copy a positional object
**
**  Note  that an  immutable   copy of  a  weak  pointer  object is a  normal
**  immutable plist. An Immutable WP object is a contradiction.
**
*N  I am far from clear that this is safe from a badly timed GC during copying.
**
*/

Obj CopyObjWPObj (
    Obj                 obj,
    Int                 mut )
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */
    Obj                 elm;
    UInt                i;              /* loop variable                   */

    /* make a copy                                                         */
    if ( mut ) {
        copy = NewBag( T_WPOBJ, SIZE_OBJ(obj) );
        ADDR_OBJ(copy)[0] = CONST_ADDR_OBJ(obj)[0];
    }
    else {
        copy = NewBag( T_PLIST+IMMUTABLE, SIZE_OBJ(obj) );
        SET_LEN_PLIST(copy,LengthWPObj(obj));
    }

    /* leave a forwarding pointer                                          */
    tmp = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( tmp, 2 );
    SET_ELM_PLIST( tmp, 1, CONST_ADDR_OBJ(obj)[0] );
    SET_ELM_PLIST( tmp, 2, copy );
    ADDR_OBJ(obj)[0] = tmp;
    CHANGED_BAG(obj);

    /* now it is copied                                                    */
    RetypeBag( obj, T_WPOBJ + COPYING );

    /* copy the subvalues                                                  */
    for ( i =  SIZE_OBJ(obj)/sizeof(Obj)-1; i > 0; i-- ) {
        elm = CONST_ADDR_OBJ(obj)[i];
        if ( elm != 0  && !IS_WEAK_DEAD_BAG(elm)) {
            tmp = COPY_OBJ( elm, mut );
            ADDR_OBJ(copy)[i] = tmp;
            CHANGED_BAG( copy );
        }
    }

    /* return the copy                                                     */
    return copy;
}

/****************************************************************************
**
*F  MakeImmutableWPObj( <obj> ) . . . . . . . . . . make immutable in place
**
*/

void MakeImmutableWPObj( Obj obj )
{
  UInt i;
  
#ifndef BOEHM_GC
  /* remove any weak dead bags */
  for (i = 1; i <= STORED_LEN_WPOBJ(obj); i++)
    {
      Obj elm = ELM_WPOBJ(obj,i);
      if (elm != 0 && IS_WEAK_DEAD_BAG(elm)) 
        ELM_WPOBJ(obj,i) = 0;
    }
  /* Change the type */
  RetypeBag( obj, T_PLIST+IMMUTABLE);
#else
  UInt len = 0;
  Obj copy = NewBag(T_PLIST+IMMUTABLE, SIZE_BAG(obj));
  for (i = 1; i <= STORED_LEN_WPOBJ(obj); i++) {
    volatile Obj tmp = ELM_WPOBJ(obj, i);
    MEMBAR_READ();
    if (IS_BAG_REF(tmp)) {
      if (ELM_WPOBJ(obj, i)) {
        FORGET_WP(&ELM_WPOBJ(obj, i));
        len = i;
      }
    } else {
      len = i;
    }
    SET_ELM_PLIST(copy, i, tmp);
  }
  SET_LEN_PLIST(copy, len);
  SET_PTR_BAG(obj, PTR_BAG(copy));
#endif
}

/****************************************************************************
**
*F  CleanObjWPObj( <obj> ) . . . . . . . . . . . . . . . . . . .  clean WPobj
*/
void CleanObjWPObj (
    Obj                 obj )
{
}


/****************************************************************************
**
*F  CopyObjWPObjCopy( <obj>, <mut> ) . . . . . . . . . .  . copy a WPobj copy
*/
Obj CopyObjWPObjCopy (
    Obj                 obj,
    Int                 mut )
{
    return ELM_PLIST( CONST_ADDR_OBJ(obj)[0], 2 );
}


/****************************************************************************
**
*F  CleanObjWPObjCopy( <obj> ) . . . . . . . . . . . . . . clean WPobj copy
*/
void CleanObjWPObjCopy (
    Obj                 obj )
{
    UInt                i;              /* loop variable                   */
    Obj                 elm;            /* subobject                       */

    /* remove the forwarding pointer                                       */
    ADDR_OBJ(obj)[0] = ELM_PLIST( CONST_ADDR_OBJ(obj)[0], 1 );
    CHANGED_BAG(obj);

    /* now it is cleaned                                                   */
    RetypeBag( obj, TNUM_OBJ(obj) - COPYING );

    /* clean the subvalues                                                 */
    for ( i = 1; i < SIZE_OBJ(obj)/sizeof(Obj); i++ ) {
        elm = CONST_ADDR_OBJ(obj)[i];
        if ( elm != 0  && !IS_WEAK_DEAD_BAG(elm)) 
          CLEAN_OBJ( elm );
    }

}

/****************************************************************************
**
*F  FinalizeWeapPointerObj( <wpobj> )
*/

#if defined(HPCGAP) && !defined(BOEHM_GC)
void FinalizeWeakPointerObj( Obj wpobj )
{
    volatile Obj keep = wpobj;
    UInt i, len;
    len = STORED_LEN_WPOBJ(wpobj);
    for (i = 1; i <= len; i++) {
      volatile Obj tmp = ELM_WPOBJ(wpobj, i);
      MEMBAR_READ();
      if (IS_BAG_REF(tmp) && ELM_WPOBJ(wpobj, i))
        FORGET_WP(&ELM_WPOBJ(wpobj, i));
    }
}
#endif

/****************************************************************************
**
*F  SaveWPObj( <wpobj> )
*/

void SaveWPObj( Obj wpobj )
{
  UInt len, i;
  Obj *ptr;
  Obj x;
  ptr = ADDR_OBJ(wpobj)+1;
  len = STORED_LEN_WPOBJ(wpobj);
  SaveUInt(len);
  for (i = 1; i <= len; i++)
    {
      x = *ptr;
      if (IS_WEAK_DEAD_BAG(x))
        {
          SaveSubObj(0);
          *ptr = 0;
        }
      else
        SaveSubObj(x);
      ptr++;
    }
}

/****************************************************************************
**
*F  LoadWPObj( <wpobj> )
*/

void LoadWPObj( Obj wpobj )
{
  UInt len, i;
  Obj *ptr;
  ptr = ADDR_OBJ(wpobj)+1;
  len =   LoadUInt();
  STORE_LEN_WPOBJ(wpobj, len);
  for (i = 1; i <= len; i++)
    {
      *ptr++ = LoadSubObj();
    }
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILTER(IsWPObj, "obj", &IsWPObjFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(WeakPointerObj, 1, "list"),
    GVAR_FUNC(LengthWPObj, 1, "wp"),
    GVAR_FUNC(SetElmWPObj, 3, "wp, pos, val"),
    GVAR_FUNC(IsBoundElmWPObj, 2, "wp, pos"),
    GVAR_FUNC(UnbindElmWPObj, 2, "wp, pos"),
    GVAR_FUNC(ElmWPObj, 2, "wp, pos"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* install the marking and sweeping methods                            */
    InfoBags[ T_WPOBJ          ].name = "object (weakptr)";
    InfoBags[ T_WPOBJ +COPYING ].name = "object (weakptr, copied)";

#ifdef BOEHM_GC
    /* force atomic allocation of these pointers */
    InitMarkFuncBags ( T_WPOBJ,          MarkNoSubBags   );
    InitMarkFuncBags ( T_WPOBJ +COPYING, MarkNoSubBags   );
#else
    InitMarkFuncBags ( T_WPOBJ,          MarkWeakPointerObj   );
    InitSweepFuncBags( T_WPOBJ,          SweepWeakPointerObj  );
    InitMarkFuncBags ( T_WPOBJ +COPYING, MarkWeakPointerObj   );
    InitSweepFuncBags( T_WPOBJ +COPYING, SweepWeakPointerObj  );
  #ifdef HPCGAP
    InitFreeFuncBag( T_WPOBJ, FinalizeWeakPointerObj );
    InitFreeFuncBag( T_WPOBJ+COPYING, FinalizeWeakPointerObj );
  #endif
#endif

    /* typing method                                                       */
    TypeObjFuncs[ T_WPOBJ ] = TypeWPObj;
    ImportGVarFromLibrary( "TYPE_WPOBJ", &TYPE_WPOBJ );

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* saving function                                                     */
    SaveObjFuncs[ T_WPOBJ ] = SaveWPObj;
    LoadObjFuncs[ T_WPOBJ ] = LoadWPObj;

    // List functions
    ElmDefListFuncs[T_WPOBJ] = ElmDefWPList;

    /* copying functions                                                   */
    CopyObjFuncs[  T_WPOBJ           ] = CopyObjWPObj;
    CopyObjFuncs[  T_WPOBJ + COPYING ] = CopyObjWPObjCopy;
    CleanObjFuncs[ T_WPOBJ           ] = CleanObjWPObj;
    CleanObjFuncs[ T_WPOBJ + COPYING ] = CleanObjWPObjCopy;

    MakeImmutableObjFuncs[ T_WPOBJ ] = MakeImmutableWPObj;
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
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoWeakPtr() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "weakptr",                          /* name                           */
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

StructInitInfo * InitInfoWeakPtr ( void )
{
    return &module;
}
