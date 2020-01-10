/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_VEC8BIT_H
#define GAP_VEC8BIT_H

#include "objects.h"
#include "opers.h"

/****************************************************************************
**
*F  RewriteGF2Vec( <vec>, <q> ) . . .
**                convert a GF(2) vector into a GF(2^k) vector in place
**
*/
void RewriteGF2Vec(Obj vec, UInt q);


/****************************************************************************
**
*F  CopyVec8Bit( <list>, <mut> ) . . . . . . . . . . . . . . copying function
**
*/
Obj CopyVec8Bit(Obj list, UInt mut);


/****************************************************************************
**
*F  IS_VEC8BIT_REP( <obj> ) . . .  check that <obj> is in 8bit GFQ vector rep
*/
extern Obj IsVec8bitRep;

EXPORT_INLINE BOOL IS_VEC8BIT_REP(Obj obj)
{
    return TNUM_OBJ(obj) == T_DATOBJ && True == DoFilter(IsVec8bitRep, obj);
}


/****************************************************************************
**
*F  PlainVec8Bit( <list> ) . . . convert an 8bit vector into an ordinary list
**
**  'PlainVec8Bit' converts the  vector <list> to a plain list.
*/
void PlainVec8Bit(Obj list);


/****************************************************************************
**
*F  ASS_VEC8BIT( <list>, <pos>, <elm> ) . . . .  set an elm of an 8bit vector
**
*/
void ASS_VEC8BIT(Obj list, Obj pos, Obj elm);


/****************************************************************************
**
*F  ZeroVec8Bit( <list> ) . . . make a new 8 bit vector
**
*/
Obj ZeroVec8Bit(UInt q, UInt len, UInt mut);


/****************************************************************************
**
**  Low-level access, needed for meataxe64 package
**
*/
Obj GetFieldInfo8Bit(UInt q);


/****************************************************************************
**
*F  LEN_VEC8BIT( <vec> ) . . . . . . . . . . . . length of an 8 bit GF vector
**
**  'LEN_VEC8BIT' returns the logical length of the 8bit GFQ vector <list>,
**  as a C integer.
*/
EXPORT_INLINE UInt LEN_VEC8BIT(Obj list)
{
    return (UInt)CONST_ADDR_OBJ(list)[1];
}


/****************************************************************************
**
*F  SET_LEN_VEC8BIT( <vec>, <len> )  . . . . set length of an 8 bit GF vector
**
**  'SET_LEN_VEC8BIT' sets the logical length of the 8bit GFQ vector <vec>,
**  to the C integer <len>.
**
*/
EXPORT_INLINE void SET_LEN_VEC8BIT(Obj list, UInt len)
{
    ADDR_OBJ(list)[1] = (Obj)len;
}


/****************************************************************************
**
*F  FIELD_VEC8BIT( <vec> ) . . . . . . . . . field size of an 8 bit GF vector
**
**  'FIELD_VEC8BIT' returns the field size Q of the 8bit GFQ vector <list>,
**  as a C integer.
*/
EXPORT_INLINE UInt FIELD_VEC8BIT(Obj list)
{
    return (UInt)CONST_ADDR_OBJ(list)[2];
}


/****************************************************************************
**
*F  SET_FIELD_VEC8BIT( <vec>, <q> )  . . set field size of an 8 bit GF vector
**
**  'SET_FIELD_VEC8BIT' sets the field size of the 8bit GFQ vector <vec>,
**  to the C integer <q>.
*/
EXPORT_INLINE void SET_FIELD_VEC8BIT(Obj list, UInt q)
{
    ADDR_OBJ(list)[2] = (Obj)q;
}


/****************************************************************************
**
*F  BLOCKS_VEC8BIT( <list> ) . . . . . . . . first block of a 8bit GFQ vector
**
**  returns a pointer to the start of the data of the 8bit GFQ vector
*/
EXPORT_INLINE UInt * BLOCKS_VEC8BIT(Obj list)
{
    return (UInt *)(ADDR_OBJ(list) + 3);
}

EXPORT_INLINE const UInt * CONST_BLOCKS_VEC8BIT(Obj list)
{
    return (const UInt *)(CONST_ADDR_OBJ(list) + 3);
}


/****************************************************************************
**
*F  BYTES_VEC8BIT( <list> ) . . . . . . . . . first byte of a 8bit GFQ vector
**
**  returns a pointer to the start of the data of the 8bit GFQ vector
*/
EXPORT_INLINE UInt1 * BYTES_VEC8BIT(Obj list)
{
    return (UInt1 *)BLOCKS_VEC8BIT(list);
}

EXPORT_INLINE const UInt1 * CONST_BYTES_VEC8BIT(Obj list)
{
    return (const UInt1 *)CONST_BLOCKS_VEC8BIT(list);
}


/****************************************************************************
**
*F  Q_FIELDINFO_8BIT( <obj> )       . . . access to fields in structure
*F  P_FIELDINFO_8BIT( <obj> )
*F  ELS_BYTE_FIELDINFO_8BIT( <obj> )
*F  SETELT_FIELDINFO_8BIT( <obj> )
*F  GETELT_FIELDINFO_8BIT( <obj> )
*F  ADD_FIELDINFO_8BIT( <obj> )
*F  SET_XXX_FIELDINFO_8BIT( <obj>, <xxx> ) . . .setters needed by ANSI
**                                         needed for scalar but not pointers
*/
struct FieldInfo8Bit {
    Obj   type;
    UInt  q;                        // field size, 3 <= q <= 256
    UInt  p;                        // prime
    UInt  d;                        // degree; q = p^d
    UInt  e;                        // number of elements per byte; <= 5
    Obj   FFE_FELT[256];            // position in GAP < order  by number
    Obj   GAPSEQ[256];              // numbering from FFV
    UInt1 FELT_FFE[256];            // immediate FFE by number
    UInt1 SETELT[256 * 256 * 5];    // set element lookup (5 is largest possible value for e)
    UInt1 GETELT[256 * 5];          // get element lookup
    UInt1 SCALAR[256 * 256];        // scalar multiply
    UInt1 INNER[256 * 256];         // inner product
    UInt1 PMULL[256 * 256];         // one lot of polynomial multiply data
    UInt1 PMULU[256 * 256];         // the other lot of polynomial data (only used if e > 1)
    UInt1 ADD[256 * 256];           // add byte (only used if p > 2)
};

typedef struct FieldInfo8Bit * FieldInfo8BitPtr;
typedef const struct FieldInfo8Bit * ConstFieldInfo8BitPtr;

EXPORT_INLINE FieldInfo8BitPtr FIELDINFO_8BIT(Obj info)
{
    return (FieldInfo8BitPtr)ADDR_OBJ(info);
}

EXPORT_INLINE ConstFieldInfo8BitPtr CONST_FIELDINFO_8BIT(Obj info)
{
    return (ConstFieldInfo8BitPtr)CONST_ADDR_OBJ(info);
}

EXPORT_INLINE UInt Q_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->q;
}

EXPORT_INLINE UInt P_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->p;
}

EXPORT_INLINE UInt D_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->d;
}

EXPORT_INLINE UInt ELS_BYTE_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->e;
}

EXPORT_INLINE const Obj *CONST_FFE_FELT_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->FFE_FELT;
}

EXPORT_INLINE Obj FFE_FELT_FIELDINFO_8BIT(Obj info, UInt i)
{
    GAP_ASSERT(i < 256);
    return CONST_FIELDINFO_8BIT(info)->FFE_FELT[i];
}

EXPORT_INLINE const Obj * GAPSEQ_FELT_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->GAPSEQ;
}

EXPORT_INLINE void SET_GAPSEQ_FELT_FIELDINFO_8BIT(Obj info, UInt i, Obj d)
{
    GAP_ASSERT(i < 256);
    FIELDINFO_8BIT(info)->GAPSEQ[i] = d;
}

EXPORT_INLINE const UInt1 * FELT_FFE_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->FELT_FFE;
}

EXPORT_INLINE const UInt1 * SETELT_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->SETELT;
}

EXPORT_INLINE const UInt1 * GETELT_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->GETELT;
}

EXPORT_INLINE const UInt1 * SCALAR_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->SCALAR;
}

EXPORT_INLINE const UInt1 * INNER_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->INNER;
}

EXPORT_INLINE const UInt1 * PMULL_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->PMULL;
}

EXPORT_INLINE const UInt1 * PMULU_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->PMULU;
}

EXPORT_INLINE const UInt1 * ADD_FIELDINFO_8BIT(Obj info)
{
    return CONST_FIELDINFO_8BIT(info)->ADD;
}



/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoVec8bit() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoVec8bit(void);


#endif    // GAP_VEC8BIT_H
