/****************************************************************************
**
*W  listoper.h                  GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares  the functions of the  package with the operations for
**  generic lists.
*/

#ifndef GAP_LISTOPER_H
#define GAP_LISTOPER_H

/* These functions are exported because specialised methods may want to
   fall back on them from other files (eg vec8bit) */

extern  Obj             ProdListScl (
            Obj                 listL,
            Obj                 listR );

extern Obj SumListList( Obj listL, Obj listR);
extern Obj ProdListList( Obj listL, Obj listR);
extern Obj DiffListList( Obj listL, Obj listR);

/****************************************************************************
**
*F  EqListList(<listL>,<listR>) . . . . . . . . . test if two lists are equal
*F  LtListList(<listL>,<listR>) . . . . . . . . . test if two lists are equal
**
*/
extern Int             EqListList (
    Obj                 listL,
    Obj                 listR );

extern Int             LtListList (
    Obj                 listL,
    Obj                 listR );

/****************************************************************************
**
*F  SumList(<listL>,<listR>)  . . . . . . . . . . . . . . . . .  sum of lists
*F  SumSclList(<listL>,<listR>) . . . . . . . . .  sum of a scalar and a list
*F  SumListScl(<listL>,<listR>) . . . . . . . . .  sum of a list and a scalar
*F  SumListList<listL>,<listR>)  . . . . . . . . . . . . .  sum of two lists
**
**  'SumList' is the extended dispatcher for the  sums involving lists.  That
**  is, whenever  two operands are  added and at  least one operand is a list
**  and 'SumFuncs'  does not point to  a special  function, then 'SumList' is
**  called.  'SumList' determines the extended  types of the operands  (e.g.,
**  'T_INT', 'T_VECTOR',  'T_MATRIX', 'T_LISTX') and then  dispatches through
**  'SumFuncs' again.
**
**  'SumSclList' is a generic function  for the first kind  of sum, that of a
**  scalar and a list.
**
**  'SumListScl' is a generic function for the second  kind of sum, that of a
**  list and a scalar.
**
**  'SumListList' is a generic  function for the third kind  of sum,  that of
**  two lists.
*/


Obj             SumSclList (
    Obj                 listL,
    Obj                 listR );

Obj             SumListScl (
    Obj                 listL,
    Obj                 listR );

Obj             SumListList (
    Obj                 listL,
    Obj                 listR );

/****************************************************************************
**
*F  DiffList(<listL>,<listR>) . . . . . . . . . . . . . . difference of lists
*F  DiffSclList(<listL>,<listR>)  . . . . . difference of a scalar and a list
*F  DiffListScl(<listL>,<listR>)  . . . . . difference of a list and a scalar
*F  DiffListList(<listL>,<listR>) . . . . . . . . . . difference of two lists
**
**  'DiffList' is  the   extended dispatcher for   the  differences involving
**  lists.  That  is, whenever two operands are  subtracted and at  least one
**  operand is a list and  'DiffFuncs' does not  point to a special function,
**  then 'DiffList' is called.   'DiffList' determines the extended  types of
**  the operands (e.g.,  'T_INT', 'T_VECTOR', 'T_MATRIX', 'T_LISTX') and then
**  dispatches through 'DiffFuncs' again.
**
**  'DiffSclList' is a  generic function  for  the first  kind of difference,
**  that of a scalar and a list.
**
**  'DiffListScl'  is a generic function for the  second kind of  difference,
**  that of a list and a scalar.
**
**  'DiffListList' is  a generic function for the  third  kind of difference,
**  that of two lists.
*/


Obj             DiffSclList (
    Obj                 listL,
    Obj                 listR );

Obj             DiffListScl (
    Obj                 listL,
    Obj                 listR );

Obj             DiffListList (
    Obj                 listL,
    Obj                 listR );

/****************************************************************************
**
*F  ProdList(<listL>,<listR>) . . . . . . . . . . . . . . .  product of lists
*F  ProdSclList(<listL>,<listR>)  . . . . . .  product of a scalar and a list
*F  ProdListScl(<listL>,<listR>)  . . . . . .  product of a list and a scalar
*F  ProdListList(<listL>,<listR>) . . . . . . . . . . .  product of two lists
**
**  'ProdList' is the extended  dispatcher for the products  involving lists.
**  That is, whenever two operands are multiplied and at least one operand is
**  a list   and  'ProdFuncs' does not    point to a  special function,  then
**  'ProdList' is called.  'ProdList'   determines the extended types  of the
**  operands (e.g.,   'T_INT',  'T_VECTOR', 'T_MATRIX',  'T_LISTX')  and then
**  dispatches through 'ProdFuncs' again.
**
**  'ProdSclList' is a generic  function for the first  kind of product, that
**  of a scalar and a list.  Note that this  includes kind of product defines
**  the product of a matrix with a list of matrices.
**
**  'ProdListScl' is a generic function for the  second kind of product, that
**  of a  list  and a  scalar.  Note that   this kind of  product defines the
**  product of a  matrix with a vector, the  product of two matrices, and the
**  product of a list of matrices and a matrix.
**
**  'ProdListList' is a generic function for the third  kind of product, that
**  of two lists.  Note that this kind of product  defines the product of two
**  vectors, a vector and a matrix, and the product of a vector and a list of
**  matrices.
*/

Obj             ProdSclList (
    Obj                 listL,
    Obj                 listR );

Obj             ProdListScl (
    Obj                 listL,
    Obj                 listR );

Obj             ProdListList (
    Obj                 listL,
    Obj                 listR );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoListOper()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoListOper ( void );


#endif // GAP_LISTOPER_H

/****************************************************************************
**

*E  listoper.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
