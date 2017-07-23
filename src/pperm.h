#ifndef GAP_PPERM_H
#define GAP_PPERM_H

/****************************************************************************
**
*F  OnTuplesPPerm( <tup>, <f> )  . . . .  operations on tuples of points
**
**  'OnTuplesPPerm'  returns  the  image  of  the  tuple  <tup>   under  the
**  PPerm <f>.
*/

extern Obj OnTuplesPPerm(Obj set, Obj f);

/****************************************************************************
**
*F  OnSetsPPerm( <set>, <f> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsPPerm' returns the  image of the  tuple <set> under the
**  partial perm <f>.
*/

extern Obj OnSetsPPerm(Obj set, Obj f);

/****************************************************************************

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/****************************************************************************

*F  InitInfoPPerm()  . . . . . . . . . . . . . . . table of init functions
*/

StructInitInfo * InitInfoPPerm(void);

#endif    // GAP_PPERM_H
