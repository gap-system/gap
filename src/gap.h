/****************************************************************************
**
*A  gap.h                       GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the various read-eval-print loops and  related  stuff.
*/
#ifdef  INCLUDE_DECLARATION_PART
char * Revision_gap_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F  Complete(<list>)  . . . . . . . . . . . . . . . . . . . . complete a file
*/
extern  Obj             CompNowFuncs;

extern  UInt            CompNowCount;


/****************************************************************************
**
*F  Error( <msg>, <arg1>, <arg2> )  . . . . . . . . . . . . . signal an error
*/
extern void ErrorQuit (
            Char *              msg,
            Int                 arg1,
            Int                 arg2 );

extern Obj ErrorReturnObj (
            Char *              msg,
            Int                 arg1,
            Int                 arg2,
            Char *              msg2 );

extern void ErrorReturnVoid (
            Char *              msg,
            Int                 arg1,
            Int                 arg2,
            Char *              msg2 );


/****************************************************************************
**

*E  gap.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


