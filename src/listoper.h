/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares  the functions of the  package with the operations for
**  generic lists.
*/

#ifndef GAP_LISTOPER_H
#define GAP_LISTOPER_H

#include "common.h"

/****************************************************************************
**
*F  EqListList(<listL>,<listR>) . . . . . . . . . test if two lists are equal
*F  LtListList(<listL>,<listR>) . . . . . . . . . test if two lists are equal
**
*/
Int EqListList(Obj listL, Obj listR);
Int LtListList(Obj listL, Obj listR);


/****************************************************************************
**
*F  SumSclList(<listL>,<listR>) . . . . . . . . .  sum of a scalar and a list
*F  SumListScl(<listL>,<listR>) . . . . . . . . .  sum of a list and a scalar
*F  SumListList<listL>,<listR>)  . . . . . . . . . . . . .  sum of two lists
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
Obj SumSclList(Obj listL, Obj listR);
Obj SumListScl(Obj listL, Obj listR);
Obj SumListList(Obj listL, Obj listR);


/****************************************************************************
**
*F  DiffSclList(<listL>,<listR>)  . . . . . difference of a scalar and a list
*F  DiffListScl(<listL>,<listR>)  . . . . . difference of a list and a scalar
*F  DiffListList(<listL>,<listR>) . . . . . . . . . . difference of two lists
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
Obj DiffSclList(Obj listL, Obj listR);
Obj DiffListScl(Obj listL, Obj listR);
Obj DiffListList(Obj listL, Obj listR);


/****************************************************************************
**
*F  ProdSclList(<listL>,<listR>)  . . . . . .  product of a scalar and a list
*F  ProdListScl(<listL>,<listR>)  . . . . . .  product of a list and a scalar
*F  ProdListList(<listL>,<listR>) . . . . . . . . . . .  product of two lists
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
Obj ProdSclList(Obj listL, Obj listR);
Obj ProdListScl(Obj listL, Obj listR);
Obj ProdListList(Obj listL, Obj listR);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoListOper()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoListOper ( void );


#endif // GAP_LISTOPER_H
