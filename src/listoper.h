/****************************************************************************
**
*W  listoper.h                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares  the functions of the  package with the operations for
**  generic lists.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_listoper_h =
   "@(#)$Id$";
#endif


extern  Obj             ProdListScl (
            Obj                 listL,
            Obj                 listR );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupListOper() . . . . . . . . .  initialize the generic list operations
**
**  C = constant, R = record, L = list,   X = extrnl, V = virtual
**
**  s = scalar, v = vector, m = matrix, e = empty,  - = nothing
**  i = incomplete type (call 'XTNum' and try again), ] = end marker
**
** 0    0    1    1    2    2    3    3    4    4    5    5    6    6
** 0    5    0    5    0    5    0    5    0    5    0    5    0    5
** CCCCCCCCCCCCRRLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLXXXXVVV
*/
extern void SetupListOper ( void );


/****************************************************************************
**
*F  InitListOper()  . . . . . . . . .  initialize the generic list operations
**
**  'InitListOper' initializes the generic list operations.
*/
extern void InitListOper ( void );


/****************************************************************************
**
*F  CheckListOper() . check the initialisation of the generic list operations
*/
extern void CheckListOper ( void );


/****************************************************************************
**

*E  listoper.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
