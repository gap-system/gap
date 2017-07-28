/****************************************************************************
**
*W  vec8bit.h                    GAP source                     Steve Linton
**
**
*Y  Copyright (C)  1997,  St Andrews
*/

#ifndef GAP_VEC8BIT_H
#define GAP_VEC8BIT_H


/****************************************************************************
**
*F  RewriteGF2Vec( <vec>, <q> ) . . .
**                convert a GF(2) vector into a GF(2^k) vector in place
**
*/

extern void RewriteGF2Vec( Obj vec, UInt q);

/****************************************************************************
**
*F  CopyVec8Bit( <list>, <mut> ) .copying function
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
*F  FuncASS_VEC8BIT( <self>, <list>, <pos>, <elm> ) set an elm of a GF2 vector
**
*/
extern Obj FuncASS_VEC8BIT (
    Obj                 self,
    Obj                 list,
    Obj                 pos,
    Obj                 elm );

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoVec8bit()  . . . . . . . . . . . . . . . . table of init functions
*/
extern StructInitInfo * InitInfoVec8bit ( void );


#endif // GAP_VEC8BIT_H
