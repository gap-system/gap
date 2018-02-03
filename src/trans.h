#ifndef GAP_TRANS_H
#define GAP_TRANS_H

#include <src/objects.h>

static inline BOOL IS_TRANS(Obj f)
{
    return (TNUM_OBJ(f) == T_TRANS2 || TNUM_OBJ(f) == T_TRANS4);
}

static inline Obj NEW_TRANS2(UInt deg)
{
    GAP_ASSERT(deg <= 65536);
    return NewBag(T_TRANS2, deg * sizeof(UInt2) + 3 * sizeof(Obj));
}

static inline UInt2 * ADDR_TRANS2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS2);
    return ((UInt2 *)((Obj *)(ADDR_OBJ(f)) + 3));
}

static inline const UInt2 * CONST_ADDR_TRANS2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS2);
    return ((const UInt2 *)((const Obj *)(CONST_ADDR_OBJ(f)) + 3));
}

static inline UInt DEG_TRANS2(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS2);
    return ((UInt)(SIZE_OBJ(f) - 3 * sizeof(Obj)) / sizeof(UInt2));
}

UInt RANK_TRANS2(Obj f);

static inline Obj NEW_TRANS4(UInt deg)
{
    // No assert here since we allow creating new T_TRANS4's when the degree
    // is low enough to fit in a T_TRANS2.
    return NewBag(T_TRANS4, deg * sizeof(UInt4) + 3 * sizeof(Obj));
}

static inline UInt4 * ADDR_TRANS4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS4);
    return ((UInt4 *)((Obj *)(ADDR_OBJ(f)) + 3));
}

static inline const UInt4 * CONST_ADDR_TRANS4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS4);
    return ((const UInt4 *)((const Obj *)(CONST_ADDR_OBJ(f)) + 3));
}

static inline UInt DEG_TRANS4(Obj f)
{
    GAP_ASSERT(TNUM_OBJ(f) == T_TRANS4);
    return ((UInt)(SIZE_OBJ(f) - 3 * sizeof(Obj)) / sizeof(UInt4));
}

UInt RANK_TRANS4(Obj f);

static inline Obj NEW_TRANS(UInt deg)
{
    if (deg < 65536) {
        return NEW_TRANS2(deg);
    }
    else {
        return NEW_TRANS4(deg);
    }
}

static inline UInt DEG_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return (TNUM_OBJ(f) == T_TRANS2 ? DEG_TRANS2(f) : DEG_TRANS4(f));
}

static inline UInt RANK_TRANS(Obj f)
{
    GAP_ASSERT(IS_TRANS(f));
    return (TNUM_OBJ(f) == T_TRANS2 ? RANK_TRANS2(f) : RANK_TRANS4(f));
}

/****************************************************************************
**
*F  OnTuplesTrans( <tup>, <f> )  . . . .  operations on tuples of points
**
**  'OnTuplesTrans'  returns  the  image  of  the  tuple  <tup>   under  the
**  transformation <f>.
*/
extern Obj OnTuplesTrans(Obj tup, Obj f);

/****************************************************************************
**
*F  OnSetsTrans( <set>, <f> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsTrans' returns the  image of the  tuple <set> under the
**  transformation <f>.
*/
extern Obj OnSetsTrans(Obj set, Obj f);

/****************************************************************************
**
*V  IdentityTrans  . . . . . . . . . . . . . . . . .  identity transformation
**
**  'IdentityTrans' is an identity transformation.
*/
extern Obj IdentityTrans;

/****************************************************************************
**
*V  EqPermTrans22 . . . . . . . . . . . . . . . . .
**
**  The actual equality checking function for Perm2 and Trans2.
*/
Int EqPermTrans22(UInt degL, UInt degR, const UInt2 * ptLstart, const UInt2 * ptRstart);

/****************************************************************************
**
*V  EqPermTrans44 . . . . . . . . . . . . . . . . .
**
**  The actual equality checking function for Perm4 and Trans4.
*/
Int EqPermTrans44(UInt degL, UInt degR, const UInt4 * ptLstart, const UInt4 * ptRstart);

/****************************************************************************
**
*F HashFuncForTrans( <f>) . . . hash transformation
**
** Returns a hash value for a transformation
*/

Int HashFuncForTrans(Obj f);

/****************************************************************************

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/****************************************************************************

*F  InitInfoTrans()  . . . . . . . . . . . . . . . table of init functions
*/

StructInitInfo * InitInfoTrans(void);

#endif    // GAP_TRANS_H
