/****************************************************************************
**
*A  listoper.h                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares  the functions of the  package with the operations for
**  generic lists.
*/
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_listoper_h =
   "@(#)$Id$";
#endif


extern  Obj             ProdListScl (
            Obj                 listL,
            Obj                 listR );


/****************************************************************************
**
*F  InitListOper()  . . . . . . . . . . .  initialize generic list operations
**
**  'InitListOper' initializes the generic list operations.
*/
extern  void            InitListOper ( void );



