/****************************************************************************
**
*W  gap.h                       GAP source                   Martin Schoenert
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

*V  Last  . . . . . . . . . . . . . . . . . . . . . . global variable  'last'
**
**  'Last',  'Last2', and 'Last3'  are the  global variables 'last', 'last2',
**  and  'last3', which are automatically  assigned  the result values in the
**  main read-eval-print loop.
*/
extern UInt Last;


/****************************************************************************
**
*V  Last2 . . . . . . . . . . . . . . . . . . . . . . global variable 'last2'
*/
extern UInt Last2;


/****************************************************************************
**
*V  Last3 . . . . . . . . . . . . . . . . . . . . . . global variable 'last3'
*/
extern UInt Last3;


/****************************************************************************
**
*V  Time  . . . . . . . . . . . . . . . . . . . . . . global variable  'time'
**
**  'Time' is the global variable 'time', which is automatically assigned the
**  time the last command took.
*/
extern UInt Time;


/****************************************************************************
**

*F * * * * * * * * * * * * * * print and error  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  FuncPrint( <self>, <args> ) . . . . . . . . . . . . . . . .  print <args>
*/
extern Obj FuncPrint (
    Obj                 self,
    Obj                 args );


/****************************************************************************
**
*F  ErrorQuit( <msg>, <arg1>, <arg2> )  . . . . . . . . . . .  print and quit
*/
extern void ErrorQuit (
            Char *              msg,
            Int                 arg1,
            Int                 arg2 );


/****************************************************************************
**
*F  ErrorReturnObj( <msg>, <arg1>, <arg2>, <msg2> ) . .  print and return obj
*/
extern Obj ErrorReturnObj (
            Char *              msg,
            Int                 arg1,
            Int                 arg2,
            Char *              msg2 );


/****************************************************************************
**
*F  ErrorReturnVoid( <msg>, <arg1>, <arg2>, <msg2> )  . . .  print and return
*/
extern void ErrorReturnVoid (
            Char *              msg,
            Int                 arg1,
            Int                 arg2,
            Char *              msg2 );


extern void InitGap (
            int *               pargc,
            char *              argv [] );


/****************************************************************************
**

*F * * * * * * * * * functions for creating the init file * * * * * * * * * *
*/



/****************************************************************************
**

*F  Complete( <list> )  . . . . . . . . . . . . . . . . . . . complete a file
*/
extern Obj  CompNowFuncs;
extern UInt CompNowCount;

extern void Complete (
            Obj                 list );


/****************************************************************************
**
*F  DoComplete<i>args(...)  . . . . . . . . . . .  handler to complete a file
*/
extern Obj DoComplete0args (
            Obj                 self );

extern Obj DoComplete1args (
            Obj                 self,
            Obj                 arg1 );

extern Obj DoComplete2args (
            Obj                 self,
            Obj                 arg1,
            Obj                 arg2 );

extern Obj DoComplete3args (
            Obj                 self,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3 );

extern Obj DoComplete4args (
            Obj                 self,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4 );

extern Obj DoComplete5args (
            Obj                 self,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5 );

extern Obj DoComplete6args (
            Obj                 self,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5,
            Obj                 arg6 );

extern Obj DoCompleteXargs (
            Obj                 self,
            Obj                 args );



/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  ImportGVarFromLibrary( <name>, <address> )  . . .  import global variable
*/
extern void ImportGVarFromLibrary(
            Char *          name,
            Obj *           address );


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/
extern void ImportFuncFromLibrary(
            Char *          name,
            Obj *           address );


/****************************************************************************
**

*E  gap.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


