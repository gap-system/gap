/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file implements the arithmetic for elements from  cyclotomic  fields
**  $Q(e^{{2 \pi i}/n}) = Q(e_n)$,  which  we  call  cyclotomics  for  short.
*/

#ifndef GAP_CYCLOTOM_H
#define GAP_CYCLOTOM_H

#include "objects.h"


/****************************************************************************
**
*F  IS_CYC . . . . . . . . . . . . . . . . test if the object is a cyclotomic
**
**  'IS_CYC' returns 1 if the argument object's tnum indicates that it is an
**  internal integer, rational or (proper) cyclotomic object, otherwise 0.
*/
EXPORT_INLINE BOOL IS_CYC(Obj o)
{
    return TNUM_OBJ(o) <= T_CYC;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoCyc() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoCyc ( void );


#endif // GAP_CYCLOTOM_H
