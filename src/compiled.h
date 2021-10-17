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

// HACK: for backwards compatibility with packages that need it,
// include stdio.h here. Should be removed once all packages are
// updated to not need it.
#include <stdio.h>

// HACK: most (all?) GAP packages with a kernel extension include compiled.h
// to get all GAP headers. They should ultimately all switch to including
// gap_all.h; however that header has only been available since GAP 4.11.0, so
// it will take some time for packages to make the switch.
#include "gap_all.h"

#ifdef __cplusplus
extern "C" {
#endif

extern Obj InfoDecision;


/* types, should go into 'gvars.c' and 'records.c' * * * * * * * * * * * * */

typedef UInt    GVar;

typedef UInt    RNam;


/* checks, should go into 'gap.c'  * * * * * * * * * * * * * * * * * * * * */

#define CHECK_BOUND(obj, name)                                               \
    if (obj == 0)                                                            \
        ErrorQuit("variable '%s' must have an assigned value", (Int)name, 0);

#define CHECK_FUNC_RESULT(obj)                                               \
    if (obj == 0)                                                            \
        ErrorQuit("function must return a value", 0, 0);

static inline void CHECK_INT_SMALL(Obj obj)
{
    RequireSmallInt(0, obj);
}

static inline void CHECK_INT_SMALL_POS(Obj obj)
{
    RequirePositiveSmallInt(0, obj);
}

static inline void CHECK_INT_POS(Obj obj)
{
    if (!IS_POS_INT(obj))
        RequireArgument(0, obj, "must be a positive integer");
}

static inline void CHECK_BOOL(Obj expr)
{
    RequireTrueOrFalse(0, expr); // use <expr> to match interpreter error
}

static inline void CHECK_FUNC(Obj obj)
{
    RequireFunction(0, obj);
}

#define CHECK_NR_ARGS(narg, args)                                            \
    if (narg != LEN_PLIST(args))                                             \
        ErrorMayQuitNrArgs(narg, LEN_PLIST(args));

#define CHECK_NR_AT_LEAST_ARGS(narg, args)                                   \
    if (narg - 1 > LEN_PLIST(args))                                          \
        ErrorMayQuitNrAtLeastArgs(narg - 1, LEN_PLIST(args));

/* higher variables, should go into 'vars.c' * * * * * * * * * * * * * * * */

#define SWITCH_TO_NEW_FRAME(func, narg, nloc, old)                           \
    (old) = SWITCH_TO_NEW_LVARS((func), (narg), (nloc))
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


/* More or less all of this will get inlined away */
void C_SET_LIMB4(Obj bag, UInt limbnumber, UInt4 value);
void C_SET_LIMB8(Obj bag, UInt limbnumber, UInt8 value);


#ifdef __cplusplus
} // extern "C"
#endif

#endif // GAP_COMPILED_H
