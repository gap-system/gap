/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This package defines macros and functions that are used by compiled code.
**  Those macros and functions should go into the appropriate packages.
*/

#ifndef GAP_COMPILED_H
#define GAP_COMPILED_H

#ifdef __cplusplus
extern "C" {
#endif

#include "ariths.h"
#include "blister.h"
#include "bool.h"
#include "calls.h"
#include "code.h"
#include "collectors.h"
#include "compiler.h"
#include "compstat.h"
#include "costab.h"
#include "cyclotom.h"
#include "dt.h"
#include "dteval.h"
#include "error.h"
#include "exprs.h"
#include "finfield.h"
#include "funcs.h"
#include "gap.h"
#include "gapstate.h"
#include "gasman.h"
#include "gvars.h"
#include "integer.h"
#include "intrprtr.h"
#include "io.h"
#include "iostream.h"
#include "listfunc.h"
#include "listoper.h"
#include "lists.h"
#include "macfloat.h"
#include "modules.h"
#include "objcftl.h"
#include "objects.h"
#include "objfgelm.h"
#include "objpcgel.h"
#include "opers.h"
#include "permutat.h"
#include "plist.h"
#include "pperm.h"
#include "precord.h"
#include "range.h"
#include "rational.h"
#include "read.h"
#include "records.h"
#include "saveload.h"
#include "scanner.h"
#include "sctable.h"
#include "set.h"
#include "stats.h"
#include "streams.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "system.h"
#include "tietze.h"
#include "trans.h"
#include "vars.h"
#include "vector.h"
#include "weakptr.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#include "hpc/serialize.h"
#include "hpc/threadapi.h"
#include "hpc/traverse.h"
#endif

extern Obj InfoDecision;


// for compatibility with the Digraphs package
UInt COUNT_TRUES_BLOCK(UInt block);
UInt COUNT_TRUES_BLOCKS(const UInt * ptr, UInt nblocks);


/* types, should go into 'gvars.c' and 'records.c' * * * * * * * * * * * * */

typedef UInt    GVar;

typedef UInt    RNam;


/* checks, should go into 'gap.c'  * * * * * * * * * * * * * * * * * * * * */

#define CHECK_BOUND(obj, name)                                               \
    if (obj == 0)                                                            \
        ErrorQuit("variable '%s' must have an assigned value", (Int)name, 0L);

#define CHECK_FUNC_RESULT(obj)                                               \
    if (obj == 0)                                                            \
        ErrorQuit("function must return a value", 0L, 0L);

#define CHECK_INT_SMALL(obj) RequireSmallInt(0, obj, "<obj>");

#define CHECK_INT_SMALL_POS(obj) RequirePositiveSmallInt(0, obj, "<obj>");

#define CHECK_INT_POS(obj)                                                   \
    if (!IS_POS_INT(obj))                                                    \
        RequireArgumentEx(0, obj, "<obj>", "must be a positive integer");

#define CHECK_BOOL(obj)                                                      \
    if (obj != True && obj != False)                                         \
        RequireArgumentEx(0, obj, "<obj>", "must be 'true' or 'false'");

#define CHECK_FUNC(obj) RequireFunction(0, obj);

#define CHECK_NR_ARGS(narg, args)                                            \
    if (narg != LEN_PLIST(args))                                             \
        ErrorMayQuitNrArgs(narg, LEN_PLIST(args));

#define CHECK_NR_AT_LEAST_ARGS(narg, args)                                   \
    if (narg - 1 > LEN_PLIST(args))                                          \
        ErrorMayQuitNrAtLeastArgs(narg - 1, LEN_PLIST(args));

/* higher variables, should go into 'vars.c' * * * * * * * * * * * * * * * */

#define SWITCH_TO_NEW_FRAME     SWITCH_TO_NEW_LVARS
#define SWITCH_TO_OLD_FRAME     SWITCH_TO_OLD_LVARS_AND_FREE


/* lists, should go into 'lists.c' * * * * * * * * * * * * * * * * * * * * */
#define C_LEN_LIST(len,list) \
 len = LENGTH(list);

#define C_LEN_LIST_FPL(len,list) \
 if ( IS_PLIST(list) ) { \
  len = INTOBJ_INT( LEN_PLIST(list) ); \
 } \
 else { \
  len = LENGTH(list); \
 }




#define C_ELM_LIST(elm,list,p) \
 elm = IS_POS_INTOBJ(p) ? ELM_LIST( list, INT_INTOBJ(p) ) : ELMB_LIST(list, p);

#define C_ELM_LIST_NLE(elm,list,p) \
 elm = IS_POS_INTOBJ(p) ? ELMW_LIST( list, INT_INTOBJ(p) ) : ELMB_LIST(list, p);

#define C_ELM_LIST_FPL(elm,list,p) \
 if ( IS_POS_INTOBJ(p) && IS_PLIST(list) ) { \
  if ( INT_INTOBJ(p) <= LEN_PLIST(list) ) { \
   elm = ELM_PLIST( list, INT_INTOBJ(p) ); \
   if ( elm == 0 ) elm = ELM_LIST( list, INT_INTOBJ(p) ); \
  } else elm = ELM_LIST( list, INT_INTOBJ(p) ); \
 } else C_ELM_LIST( elm, list, p )

#define C_ELM_LIST_NLE_FPL(elm,list,p) \
 if ( IS_POS_INTOBJ(p) && IS_PLIST(list) ) { \
  elm = ELM_PLIST( list, INT_INTOBJ(p) ); \
 } else C_ELM_LIST_NLE(elm, list, p)

#define C_ASS_LIST(list,p,rhs) \
  if (IS_POS_INTOBJ(p)) ASS_LIST( list, INT_INTOBJ(p), rhs ); \
  else ASSB_LIST(list, p, rhs);

#define C_ASS_LIST_FPL(list,p,rhs) \
 if ( IS_POS_INTOBJ(p) && TNUM_OBJ(list) == T_PLIST ) { \
  if ( LEN_PLIST(list) < INT_INTOBJ(p) ) { \
   GROW_PLIST( list, (UInt)INT_INTOBJ(p) ); \
   SET_LEN_PLIST( list, INT_INTOBJ(p) ); \
  } \
  SET_ELM_PLIST( list, INT_INTOBJ(p), rhs ); \
  CHANGED_BAG( list ); \
 } \
 else { \
  C_ASS_LIST( list, p, rhs ) \
 }

#define C_ASS_LIST_FPL_INTOBJ(list,p,rhs) \
 if ( IS_POS_INTOBJ(p) && TNUM_OBJ(list) == T_PLIST) { \
  if ( LEN_PLIST(list) < INT_INTOBJ(p) ) { \
   GROW_PLIST( list, (UInt)INT_INTOBJ(p) ); \
   SET_LEN_PLIST( list, INT_INTOBJ(p) ); \
  } \
  SET_ELM_PLIST( list, INT_INTOBJ(p), rhs ); \
 } \
 else { \
  C_ASS_LIST( list, p, rhs ) \
 }

#define C_ISB_LIST( list, pos) \
  ((IS_POS_INTOBJ(pos) ? ISB_LIST(list, INT_INTOBJ(pos)) : ISBB_LIST( list, pos)) ? True : False)

#define C_UNB_LIST( list, pos) \
   if (IS_POS_INTOBJ(pos)) UNB_LIST(list, INT_INTOBJ(pos)); else UNBB_LIST(list, pos);

#define C_ADD_LIST(list,obj) \
 AddList( list, obj );

#define C_ADD_LIST_FPL(list,obj) \
 if ( TNUM_OBJ(list) == T_PLIST) { \
  AddPlist( list, obj ); \
 } \
 else { \
  AddList( list, obj ); \
 }

#define GF_ITERATOR     ITERATOR
#define GF_IS_DONE_ITER IS_DONE_ITER
#define GF_NEXT_ITER    NEXT_ITER

extern  Obj             GF_ITERATOR;
extern  Obj             GF_IS_DONE_ITER;
extern  Obj             GF_NEXT_ITER;



/* More or less all of this will get inlined away */

EXPORT_INLINE void C_SET_LIMB4(Obj bag, UInt limbnumber, UInt4 value)
{
#ifdef SYS_IS_64_BIT 
  UInt8 *p;
  if (limbnumber % 2) {
    p = ((UInt8*)ADDR_OBJ(bag)) + (limbnumber-1) / 2;
    *p = (*p & 0xFFFFFFFFUL) | ((UInt8)value << 32);
  } else {
    p = ((UInt8 *)ADDR_OBJ(bag)) + limbnumber / 2;
    *p = (*p & 0xFFFFFFFF00000000UL) | (UInt8)value;
  }
#else
  ((UInt4 *)ADDR_OBJ(bag))[limbnumber] = value;
#endif  
}


EXPORT_INLINE void C_SET_LIMB8(Obj bag, UInt limbnumber, UInt8 value)
{ 
#ifdef SYS_IS_64_BIT 
  ((UInt8 *)ADDR_OBJ(bag))[limbnumber] = value;
#else
  ((UInt4 *)ADDR_OBJ(bag))[2*limbnumber] = (UInt4)(value & 0xFFFFFFFFUL);
  ((UInt4 *)ADDR_OBJ(bag))[2*limbnumber+1] = (UInt4)(value >>32);
#endif
}


#ifdef __cplusplus
} // extern "C"
#endif
    
#endif // GAP_COMPILED_H
