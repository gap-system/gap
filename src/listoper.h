/****************************************************************************
**
*W  listoper.h                  GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file declares  the functions of the  package with the operations for
**  generic lists.
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_listoper_h =
   "@(#)$Id$";
#endif

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

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoListOper()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoListOper ( void );


/****************************************************************************
**

*E  listoper.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
