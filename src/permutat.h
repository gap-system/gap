/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file defines the functions for permutations (small and large).
*/

#ifndef GAP_PERMUTAT_H
#define GAP_PERMUTAT_H

#include "objects.h"

/****************************************************************************
**
*F  NEW_PERM2(<deg>)  . . . . . . . . . . . .  make a new (small) permutation
*F  DEG_PERM2(<perm>) . . . . . . . . . . . . . degree of (small) permutation
*F  ADDR_PERM2(<perm>)  . . . . . . . absolute address of (small) permutation
*F  NEW_PERM4(<deg>)  . . . . . . . . . . . .  make a new (large) permutation
*F  DEG_PERM4(<perm>) . . . . . . . . . . . . . degree of (large) permutation
*F  ADDR_PERM4(<perm>)  . . . . . . . absolute address of (large) permutation
*/
EXPORT_INLINE UInt SIZEBAG_PERM2(UInt deg)
{
    return sizeof(Obj) + deg * sizeof(UInt2);
}

EXPORT_INLINE Obj NEW_PERM2(UInt deg)
{
    return NewBag(T_PERM2, SIZEBAG_PERM2(deg));
}

EXPORT_INLINE UInt DEG_PERM2(Obj perm)
{
    return (SIZE_OBJ(perm) - sizeof(Obj)) / sizeof(UInt2);
}

EXPORT_INLINE UInt2 * ADDR_PERM2(Obj perm)
{
    return (UInt2 *)(ADDR_OBJ(perm) + 1);
}

EXPORT_INLINE const UInt2 * CONST_ADDR_PERM2(Obj perm)
{
    return (const UInt2 *)(CONST_ADDR_OBJ(perm) + 1);
}

EXPORT_INLINE UInt SIZEBAG_PERM4(UInt deg)
{
    return sizeof(Obj) + deg * sizeof(UInt4);
}

EXPORT_INLINE Obj NEW_PERM4(UInt deg)
{
    return NewBag(T_PERM4, SIZEBAG_PERM4(deg));
}

EXPORT_INLINE UInt DEG_PERM4(Obj perm)
{
    return (SIZE_OBJ(perm) - sizeof(Obj)) / sizeof(UInt4);
}

EXPORT_INLINE UInt4 * ADDR_PERM4(Obj perm)
{
    return (UInt4 *)(ADDR_OBJ(perm) + 1);
}

EXPORT_INLINE const UInt4 * CONST_ADDR_PERM4(Obj perm)
{
    return (const UInt4 *)(CONST_ADDR_OBJ(perm) + 1);
}

EXPORT_INLINE Obj STOREDINV_PERM(Obj perm)
{
    Obj inv = ADDR_OBJ(perm)[0];
    /* Check inv has the same TNAM as perm
      This is checked below in SET_STOREDINV_PERM, but could
      be invalidated if either perm or inv is changed in-place */
    GAP_ASSERT(!inv || (TNUM_OBJ(perm) == TNUM_OBJ(inv)));
    return inv;
}

/* SET_STOREDINV_PERM should only be used in neither perm, nor inv has
   a stored inverse already.  It's OK (although inefficient) if perm and inv
   are identical */
EXPORT_INLINE void SET_STOREDINV_PERM(Obj perm, Obj inv)
{
    /* check for the possibility that inv is in a different representation to
       perm. It could be that perm actually acts on < 2^16 points but is in
       PERM4 representation and some clever code has represented the inverse
       as PERM2. It could be that someone introduces a new representation
       altogether */
    if (TNUM_OBJ(inv) == TNUM_OBJ(perm)) {
        GAP_ASSERT(STOREDINV_PERM(perm) == 0 && STOREDINV_PERM(inv) == 0);
        ADDR_OBJ(perm)[0] = inv;
        CHANGED_BAG(perm);
        ADDR_OBJ(inv)[0] = perm;
        CHANGED_BAG(inv);
    }
}

/* Clear the stored inverse. This is required if 'perm' changes TNUM.
   Also clears the stored inverse of the stored inverse (which should be
   perm). */
EXPORT_INLINE void CLEAR_STOREDINV_PERM(Obj perm)
{
    Obj inv = ADDR_OBJ(perm)[0];
    if (inv) {
        ADDR_OBJ(inv)[0] = 0;
        ADDR_OBJ(perm)[0] = 0;
    }
}


/****************************************************************************
**
*F  IMAGE(<i>,<pt>,<dg>)  . . . . . .  image of <i> under <pt> of degree <dg>
**
**  'IMAGE'  returns the  image of the   point <i> under  the permutation  of
**  degree <dg> pointed to  by <pt>.   If the  point  <i> is greater  than or
**  equal to <dg> the image is <i> itself.
**
**  'IMAGE' is  implemented as a macro so  do not use  it with arguments that
**  have side effects.
*/
#define IMAGE(i,pt,dg)  (((i) < (dg)) ? (pt)[(i)] : (i))

#define IS_PERM2(perm)  (TNUM_OBJ(perm) == T_PERM2)
#define IS_PERM4(perm)  (TNUM_OBJ(perm) == T_PERM4)


EXPORT_INLINE BOOL IS_PERM(Obj f)
{
    return (TNUM_OBJ(f) == T_PERM2 || TNUM_OBJ(f) == T_PERM4);
}


/****************************************************************************
**
*V  IdentityPerm  . . . . . . . . . . . . . . . . . . .  identity permutation
**
**  'IdentityPerm' is an identity permutation.
*/
extern  Obj             IdentityPerm;


/****************************************************************************
**
*F  OnTuplesPerm( <tup>, <perm> )  . . . .  operations on tuples of points
**
**  'OnTuplesPerm'  returns  the  image  of  the  tuple  <tup>   under  the
**  permutation <perm>.  It is called from 'FuncOnTuples'.
*/
Obj OnTuplesPerm(Obj tup, Obj perm);


/****************************************************************************
**
*F  OnSetsPerm( <set>, <perm> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsPerm' returns the  image of the  tuple <set> under the permutation
**  <perm>.  It is called from 'FuncOnSets'.
*/
Obj OnSetsPerm(Obj set, Obj perm);


/****************************************************************************
**
*F  Array2Perm( <array> ) . . . . . . . . . convert array of cycles into perm
**
**  This function may be used by C code generated by the GAP compiler.
*/
Obj Array2Perm(Obj array);

/****************************************************************************
**
*F  LargestMovedPointPerm(perm) . . . . . . . . largest point moved by a perm
*/
UInt LargestMovedPointPerm(Obj perm);


/****************************************************************************
**
*F  TrimPerm( <perm>, <m> ) . . . . . . .  trim the permutation to degree <m>
**
**  Trim <perm> to degree <m> and if possible change it to a T_PERM2 bag.
**  No checks are performed, the caller is responsible for ensuring that this
**  operation is valid.
*/
void TrimPerm(Obj perm, UInt m);


/****************************************************************************
**
*F  ScanPermCycle( <perm>, <m>, <cycle>, <len>, <readElm> )
*/
UInt ScanPermCycle(
    Obj perm, UInt m, Obj cycle, UInt cycleLen, Obj (*readElm)(Obj, Int));


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoPermutat()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPermutat ( void );


#endif // GAP_PERMUTAT_H
