/****************************************************************************
**
*W  vec8bit.h                    GAP source                     Steve Linton
**
**
*Y  Copyright (C)  1997,  St Andrews
*/

#ifndef GAP_VEC8BIT_H
#define GAP_VEC8BIT_H

#include <src/system.h>

/****************************************************************************
**
*F  RewriteGF2Vec( <vec>, <q> ) . . .
**                convert a GF(2) vector into a GF(2^k) vector in place
**
*/

extern void RewriteGF2Vec( Obj vec, UInt q);

/****************************************************************************
**
*F  CopyVec8Bit( <list>, <mut> ) . . . . . . . . . . . . . . copying function
**
*/

extern Obj CopyVec8Bit( Obj list, UInt mut );

/****************************************************************************
**
*F  IS_VEC8BIT_REP( <obj> )  . . . . . . check that <obj> is in 8bit GFQ vector rep
*/
extern Obj IsVec8bitRep;

#define IS_VEC8BIT_REP(obj) \
  (TNUM_OBJ(obj)==T_DATOBJ && True == DoFilter(IsVec8bitRep,obj))



/****************************************************************************
**
*F  PlainVec8Bit( <list> ) . . . convert an 8bit vector into an ordinary list
**
**  'PlainVec8Bit' converts the  vector <list> to a plain list.
*/
extern void PlainVec8Bit ( Obj                 list );

/****************************************************************************
**
*F  FuncASS_VEC8BIT( <self>, <list>, <pos>, <elm> ) set an elm of an 8bit vector
**
*/
extern Obj FuncASS_VEC8BIT (
    Obj                 self,
    Obj                 list,
    Obj                 pos,
    Obj                 elm );


/****************************************************************************
**
*F  ZeroVec8Bit( <list> ) . . . make a new 8 bit vector
**
*/
extern Obj ZeroVec8Bit(UInt q, UInt len, UInt mut);

/****************************************************************************
**
**  Low-level access, needed for meataxe64 package
**
*/

extern Obj GetFieldInfo8Bit(UInt q);


/****************************************************************************
**
*F  LEN_VEC8BIT( <vec> ) . . . . . . . . . . . . length of an 8 bit GF vector
**
**  'LEN_VEC8BIT' returns the logical length of the 8bit GFQ vector <list>,
**  as a C integer.
**
**  Note that 'LEN_VEC8BIT' is a macro, so do not call it with  arguments that
**  have side effects.
*/
#define LEN_VEC8BIT(list) ((Int)(CONST_ADDR_OBJ(list)[1]))

/****************************************************************************
**
*F  SET_LEN_VEC8BIT( <vec>, <len> )  . . . . set length of an 8 bit GF vector
**
**  'SET_LEN_VEC8BIT' sets the logical length of the 8bit GFQ vector <vec>,
**  to the C integer <len>.
**
*/
#define SET_LEN_VEC8BIT(list, len) ((ADDR_OBJ(list)[1] = (Obj)(len)))

/****************************************************************************
**
*F  FIELD_VEC8BIT( <vec> ) . . . . . . . . . field size of an 8 bit GF vector
**
**  'FIELD_VEC8BIT' returns the field size Q of the 8bit GFQ vector <list>,
**  as a C integer.
**
**  Note that 'FIELD_VEC8BIT' is a macro, so do not call it with  arguments
**  that have side effects.
*/

#define FIELD_VEC8BIT(list) ((Int)(CONST_ADDR_OBJ(list)[2]))

/****************************************************************************
**
*F  SET_FIELD_VEC8BIT( <vec>, <q> )  . . set field size of an 8 bit GF vector
**
**  'SET_FIELD_VEC8BIT' sets the field size of the 8bit GFQ vector <vec>,
**  to the C integer <q>.
**
*/
#define SET_FIELD_VEC8BIT(list, q) ((ADDR_OBJ(list)[2] = (Obj)(q)))


/****************************************************************************
**
*F  BYTES_VEC8BIT( <list> ) . . . . . . . . . first byte of a 8bit GFQ vector
**
**  returns a pointer to the start of the data of the 8bit GFQ vector
*/
#define BYTES_VEC8BIT(list) ((UInt1 *)(ADDR_OBJ(list) + 3))


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
**
**  For machines with alignment restrictions. it's important to put all
**  the word-sized data BEFORE all the byte-sized data (especially FFE_FELT...
**  which may have odd length
**
**  Note ADD has to be last, because it is not there in characteristic 2
*/

#define Q_FIELDINFO_8BIT(info) ((UInt)(CONST_ADDR_OBJ(info)[1]))
#define SET_Q_FIELDINFO_8BIT(info, q) (ADDR_OBJ(info)[1] = (Obj)(q))
#define P_FIELDINFO_8BIT(info) ((UInt)(CONST_ADDR_OBJ(info)[2]))
#define SET_P_FIELDINFO_8BIT(info, p) (ADDR_OBJ(info)[2] = (Obj)(p))
#define D_FIELDINFO_8BIT(info) ((UInt)(CONST_ADDR_OBJ(info)[3]))
#define SET_D_FIELDINFO_8BIT(info, d) (ADDR_OBJ(info)[3] = (Obj)(d))
#define ELS_BYTE_FIELDINFO_8BIT(info) ((UInt)(CONST_ADDR_OBJ(info)[4]))
#define SET_ELS_BYTE_FIELDINFO_8BIT(info, e) (ADDR_OBJ(info)[4] = (Obj)(e))
#define FFE_FELT_FIELDINFO_8BIT(info) (ADDR_OBJ(info) + 5)
#define GAPSEQ_FELT_FIELDINFO_8BIT(info)                                     \
    (ADDR_OBJ(info) + 5 + Q_FIELDINFO_8BIT(info))
#define FELT_FFE_FIELDINFO_8BIT(info)                                        \
    ((UInt1 *)(GAPSEQ_FELT_FIELDINFO_8BIT(info) + Q_FIELDINFO_8BIT(info)))
#define SETELT_FIELDINFO_8BIT(info)                                          \
    (FELT_FFE_FIELDINFO_8BIT(info) + Q_FIELDINFO_8BIT(info))
#define GETELT_FIELDINFO_8BIT(info)                                          \
    (SETELT_FIELDINFO_8BIT(info) +                                           \
     256 * Q_FIELDINFO_8BIT(info) * ELS_BYTE_FIELDINFO_8BIT(info))
#define SCALAR_FIELDINFO_8BIT(info)                                          \
    (GETELT_FIELDINFO_8BIT(info) + 256 * ELS_BYTE_FIELDINFO_8BIT(info))
#define INNER_FIELDINFO_8BIT(info)                                           \
    (SCALAR_FIELDINFO_8BIT(info) + 256 * Q_FIELDINFO_8BIT(info))
#define PMULL_FIELDINFO_8BIT(info) (INNER_FIELDINFO_8BIT(info) + 256 * 256)
#define PMULU_FIELDINFO_8BIT(info) (PMULL_FIELDINFO_8BIT(info) + 256 * 256)
#define ADD_FIELDINFO_8BIT(info)                                             \
    (PMULU_FIELDINFO_8BIT(info) +                                            \
     ((ELS_BYTE_FIELDINFO_8BIT(info) == 1) ? 0 : 256 * 256))


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoVec8bit()  . . . . . . . . . . . . . . . . table of init functions
*/
extern StructInitInfo * InitInfoVec8bit ( void );


#endif // GAP_VEC8BIT_H
