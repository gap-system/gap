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

*F * * * * * * * * * streams and files related functions  * * * * * * * * * *
*/


/****************************************************************************
**

*F  FuncREAD_AS_FUNC( <filename> )  . . . . . . . . . . . . . . . read a file
*/
extern Obj READ_AS_FUNC (
            Char *              filename );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  ImportGVarFromLibrary( <name>, <address> )  . . .  import global variable
*/
extern void ImportGVarFromLibrary(
	    Char *	    name,
	    Obj *           address );


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/
extern void ImportFuncFromLibrary(
	    Char *	    name,
	    Obj *           address );


/****************************************************************************
**

*E  gap.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


