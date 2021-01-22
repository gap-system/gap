/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_VECGF2_H
#define GAP_VECGF2_H

#include "common.h"

/****************************************************************************
**
*F  IS_GF2VEC_REP( <obj> )  . . . . . . check that <obj> is in GF2 vector rep
*/
#define IS_GF2VEC_REP(obj)                                                   \
    (TNUM_OBJ(obj) == T_DATOBJ && DoFilter(IsGF2VectorRep, obj) == True)


/****************************************************************************
**
*F  NEW_GF2VEC( <vec>, <type>, <len> )  . . . . . . . create a new GF2 vector
*/
#define NEW_GF2VEC(vec, type, len)                                           \
    do {                                                                     \
        vec = NewBag(T_DATOBJ, SIZE_PLEN_GF2VEC(len));                       \
        SetTypeDatObj(vec, type);                                            \
        SET_LEN_GF2VEC(vec, len);                                            \
    } while (0)


/****************************************************************************
**
*F  LEN_GF2VEC( <vec> ) . . . . . . . . . . . . . . . . length of a GF vector
**
**  'LEN_GF2VEC' returns the logical length of the GF2 vector <list>,  as a C
**  integer.
**
**  Note that 'LEN_GF2VEC' is a macro, so do not call it with  arguments that
**  have side effects.
*/
#define LEN_GF2VEC(list) ((Int)(CONST_ADDR_OBJ(list)[1]))


/****************************************************************************
**
*F  NUMBER_BLOCKS_GF2VEC( <vec> ) . . . . . . . number of UInt blocks in list
*/
#define NUMBER_BLOCKS_GF2VEC(list) ((LEN_GF2VEC((list)) + BIPEB - 1) / BIPEB)


/****************************************************************************
**
*F  BLOCKS_GF2VEC( <list> ) . . . . . . . . . . . first block of a GF2 vector
**
**  returns a pointer to the start of the data of the GF2 vector
*/
#define BLOCKS_GF2VEC(list) ((UInt *)(ADDR_OBJ(list) + 2))
#define CONST_BLOCKS_GF2VEC(list) ((const UInt *)(CONST_ADDR_OBJ(list) + 2))


/****************************************************************************
**
*F  BLOCK_ELM_GF2VEC( <list>, <pos> ) . . . . . . . . . block of a GF2 vector
**
**  'BLOCK_ELM_GF2VEC' return the   block containing the <pos>-th  element of
**  the  GF2 vector <list> as  a UInt value, which is  also a valid left hand
**  side.  <pos> must be a positive integer less  than or equal to the length
**  of <list>.
**
**  Note that 'BLOCK_ELM_GF2VEC' is a macro, so do not call it with arguments
**  that have side effects.
*/
#define BLOCK_ELM_GF2VEC(list, pos) (BLOCKS_GF2VEC(list)[((pos)-1) / BIPEB])
#define CONST_BLOCK_ELM_GF2VEC(list, pos)                                    \
    (CONST_BLOCKS_GF2VEC(list)[((pos)-1) / BIPEB])


/****************************************************************************
**
*F  SET_LEN_GF2VEC( <list>, <len> ) .  set the logical length of a GF2 vector
**
**  'SET_LEN_GF2VEC' sets the length of the boolean list  <list> to the value
**  <len>, which must be a positive C integer.
**
**  Note that 'SET_LEN_GF2VEC' is a macro, so do  not  call it with arguments
**  that have side effects.
*/
#define SET_LEN_GF2VEC(list, len) (ADDR_OBJ(list)[1] = (Obj)(len))


/****************************************************************************
**
*F  SIZE_PLEN_GF2VEC( <len> ) . . . . . . . . physical length of a GF2 vector
*/
#define SIZE_PLEN_GF2VEC(len)                                                \
    (2 * sizeof(Obj) + ((len) + BIPEB - 1) / BIPEB * sizeof(UInt))


/****************************************************************************
**
*F  MASK_POS_GF2VEC( <pos> )  . . . . bit mask for position of a Boolean list
**
**  MASK_POS_GF2VEC(<pos>) returns a UInt with  a single set bit in  position
**  '(<pos>-1) % BIPEB',
**  useful for accessing the <pos>-th element of a blist.
**
**  Note that 'MASK_POS_GF2VEC' is a  macro, so do not call it with arguments
**  that have side effects.
*/
#define MASK_POS_GF2VEC(pos) (((UInt)1) << ((pos)-1) % BIPEB)


/****************************************************************************
**
*F  ELM_GF2VEC( <list>, <pos> ) . . . . . . . . . . . element of a GF2 vector
**
**  'ELM_GF2VEC' return the <pos>-th element of  the GF2 vector <list>, which
**  is either 'Z(2)' or '0*Z(2)'.  <pos> must be a positive integer less than
**  or equal to the length of <list>.
**
**  Note that 'ELM_GF2VEC' is a macro, so do  not call it with arguments that
**  have side effects.
*/
#define ELM_GF2VEC(list, pos)                                                \
    ((CONST_BLOCK_ELM_GF2VEC(list, pos) & MASK_POS_GF2VEC(pos)) ? GF2One     \
                                                                : GF2Zero)


/****************************************************************************
**
*F  LEN_GF2MAT( <list> )  . . . . . . . . . . . . . . . length of a GF matrix
**
**  'LEN_GF2MAT' returns the logical length of the GF2 matrix <list>,  as a C
**  integer.
**
**  Note that 'LEN_GF2MAT' is a macro, so do not call it with  arguments that
**  have side effects.
*/
#define LEN_GF2MAT(list) (INT_INTOBJ(CONST_ADDR_OBJ(list)[1]))


/****************************************************************************
**
*F  SET_LEN_GF2MAT( <list>, <len> ) . . . . . . set the length of a GF matrix
**
**  'SET_LEN_GF2MAT' sets the logical length of the GF2 matrix <list>, as a C
**  integer.
**
**  Note that 'SET_LEN_GF2MAT' is a  macro, so do not  call it with arguments
**  that have side effects.
*/
#define SET_LEN_GF2MAT(list, len) (ADDR_OBJ(list)[1] = INTOBJ_INT(len))


/****************************************************************************
**
*F  ELM_GF2MAT( <list>, <pos> ) . . . . . . . . . . . element of a GF2 matrix
**
**  'ELM_GF2MAT' returns the <pos>-th element of the GF2 matrix <list>, which
**  is a GF2 vector.  <pos> must be a positive  integer less than or equal to
**  the length of <list>.
**
**  Note that 'ELM_GF2MAT' is a macro, so do  not call it with arguments that
**  have side effects.
*/
#define ELM_GF2MAT(list, pos) (CONST_ADDR_OBJ(list)[pos + 1])


/****************************************************************************
**
*F  SET_ELM_GF2MAT( <list>, <pos>, <elm> )  . . . set element of a GF2 matrix
**
**  'SET_ELM_GF2MAT'  sets the <pos>-th element   of  the GF2 matrix  <list>,
**  which must be a  GF2 vector.  <pos> must  be a positive integer less than
**  or equal to the length of <list>.
**
**  Note that 'ELM_GF2MAT' is a macro, so do  not call it with arguments that
**  have side effects.
*/
#define SET_ELM_GF2MAT(list, pos, elm) (ADDR_OBJ(list)[pos + 1] = elm)


/****************************************************************************
**
*F  SIZE_PLEN_GF2MAT( <len> ) . . . . . . . . physical length of a GF2 matrix
*/
#define SIZE_PLEN_GF2MAT(len) (((len) + 2) * sizeof(Obj))

/****************************************************************************
**
*V  TYPE_LIST_GF2VEC  . . . . . . . . . . . . . . type of a GF2 vector object
*/
extern Obj TYPE_LIST_GF2VEC;


/****************************************************************************
**
*V  TYPE_LIST_GF2VEC_IMM  . . . . . .  type of an immutable GF2 vector object
*/
extern Obj TYPE_LIST_GF2VEC_IMM;

/****************************************************************************
**
*V  TYPE_LIST_GF2VEC_IMM_LOCKED . . . type of an immutable GF2 vector object
**                                          with locked representation
*/
extern Obj TYPE_LIST_GF2VEC_IMM_LOCKED;

/****************************************************************************
**
*V  TYPE_LIST_GF2VEC_LOCKED. . . .  type of a GF2 vector object
**                                          with locked representation
*/
extern Obj TYPE_LIST_GF2VEC_LOCKED;


/****************************************************************************
**
*V  TYPE_LIST_GF2MAT  . . . . . . . . . . . . . . type of a GF2 matrix object
*/
extern Obj TYPE_LIST_GF2MAT;


/****************************************************************************
**
*V  TYPE_LIST_GF2MAT_IMM  . . . . . .  type of an immutable GF2 matrix object
*/
extern Obj TYPE_LIST_GF2MAT_IMM;


extern Obj IsGF2VectorRep;

Obj ShallowCopyVecGF2(Obj vec);

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoGF2Vec()  . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoGF2Vec(void);


#endif    // GAP_VECGF2_H
