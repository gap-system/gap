/****************************************************************************
**
*W  gap.h                       GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the various read-eval-print loops and  related  stuff.
*/

#ifndef GAP_GAP_H
#define GAP_GAP_H

#include <src/system.h>

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
*F  ViewObjHandler  . . . . . . . . . handler to view object and catch errors
*/
extern UInt ViewObjGVar;

extern void ViewObjHandler ( Obj obj );


/****************************************************************************
**
*F * * * * * * * * * * * * * * print and error  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  RegisterBreakloopObserver( <func> )
**
**  Register a function which will be called when the break loop is entered
**  and left. Function should take a single Int argument which will be 1 when
**  break loop is entered, 0 when leaving.
**
**  Note that it is also possible to leave the break loop (or any GAP code)
**  by longjmping. This should be tracked with RegisterSyLongjmpObserver.
*/

typedef void (*intfunc)(Int);

Int RegisterBreakloopObserver(intfunc func);

/****************************************************************************
**
*F  ErrorQuit( <msg>, <arg1>, <arg2> )  . . . . . . . . . . .  print and quit
*/
extern void ErrorQuit (
            const Char *        msg,
            Int                 arg1,
            Int                 arg2 ) NORETURN;

/****************************************************************************
**
*F  ErrorMayQuit( <msg>, <arg1>, <arg2> )  . print, enter break loop and quit
**                                           no option to return anything.
*/
extern void ErrorMayQuit (
            const Char *        msg,
            Int                 arg1,
            Int                 arg2 ) NORETURN;


/****************************************************************************
**
*F  ErrorQuitBound( <name> )  . . . . . . . . . . . . . . .  unbound variable
*/
extern void ErrorQuitBound (
    const Char *        name );


/****************************************************************************
**
*F  ErrorQuitFuncResult() . . . . . . . . . . . . . . . . must return a value
*/
extern void ErrorQuitFuncResult ( void ) NORETURN;


/****************************************************************************
**
*F  ErrorQuitIntSmall( <obj> )  . . . . . . . . . . . . . not a small integer
*/
extern void ErrorQuitIntSmall(Obj obj) NORETURN;


/****************************************************************************
**
*F  ErrorQuitIntSmallPos( <obj> ) . . . . . . .  not a positive small integer
*/
extern void ErrorQuitIntSmallPos(Obj obj) NORETURN;

/****************************************************************************
**
*F  ErrorQuitIntPos( <obj> ) . . . . . . .  not a positive  integer
*/
extern void ErrorQuitIntPos(Obj obj) NORETURN;


/****************************************************************************
**
*F  ErrorQuitBool( <obj> )  . . . . . . . . . . . . . . . . . . not a boolean
*/
extern void ErrorQuitBool(Obj obj) NORETURN;


/****************************************************************************
**
*F  ErrorQuitFunc( <obj> )  . . . . . . . . . . . . . . . . .  not a function
*/
extern void ErrorQuitFunc(Obj obj) NORETURN;


/****************************************************************************
**
*F  ErrorQuitNrArgs( <narg>, <args> ) . . . . . . . wrong number of arguments
*/
extern void ErrorQuitNrArgs (
    Int                 narg,
    Obj                 args ) NORETURN;

/****************************************************************************
**
*F  ErrorQuitNrAtLeastArgs( <narg>, <args> ) . . . . . . not enough arguments
*/
extern void ErrorQuitNrAtLeastArgs (
    Int                 narg,
    Obj                 args ) NORETURN;

/****************************************************************************
**
*F  ErrorQuitRange3( <first>, <second>, <last> ) . . .divisibility rules
*/
extern void ErrorQuitRange3 (
    Obj                 first,
    Obj                 second,
    Obj                 last) NORETURN;


/****************************************************************************
**
*F  ErrorReturnObj( <msg>, <arg1>, <arg2>, <msg2> ) . .  print and return obj
*/
extern Obj ErrorReturnObj (
            const Char *        msg,
            Int                 arg1,
            Int                 arg2,
            const Char *        msg2 );


/****************************************************************************
**
*F  ErrorReturnVoid( <msg>, <arg1>, <arg2>, <msg2> )  . . .  print and return
*/
extern void ErrorReturnVoid (
            const Char *        msg,
            Int                 arg1,
            Int                 arg2,
            const Char *        msg2 );


/****************************************************************************
**
*T  ExecStatus . . . .  type of status values returned by read, eval and exec
**                      subroutines, explaining why evaluation, or execution
**                      has terminated.
**
**  Values are powers of two, although I do not currently know of any
**  cirumstances where they can get combined
*/

typedef UInt ExecStatus;

enum {
    STATUS_END         =  0,    // ran off the end of the code
    STATUS_RETURN_VAL  =  1,    // value returned
    STATUS_RETURN_VOID =  2,    // void returned
    STATUS_BREAK       =  4,    // 'break' statement
    STATUS_QUIT        =  8,    // quit command
    STATUS_CONTINUE    =  8,    // 'continue' statement
    STATUS_EOF         = 16,    // End of file
    STATUS_ERROR       = 32,    // error
    STATUS_QQUIT       = 64,    // QUIT command
};


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitBagNamesFromTable( <table> )  . . . . . . . . .  initialise bag names
*/
extern void InitBagNamesFromTable(const StructBagNames * tab);


/****************************************************************************
**
*F  InitClearFiltsTNumsFromTable( <tab> ) . . .  initialise clear filts tnums
*/
extern void InitClearFiltsTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitHasFiltListTNumsFromTable( <tab> )  . . initialise tester filts tnums
*/
extern void InitHasFiltListTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitSetFiltListTNumsFromTable( <tab> )  . . initialise setter filts tnums
*/
extern void InitSetFiltListTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitResetFiltListTNumsFromTable( <tab> )  initialise unsetter filts tnums
*/
extern void InitResetFiltListTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitGVarFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
extern void InitGVarFiltsFromTable(const StructGVarFilt * tab);


/****************************************************************************
**
*F  InitGVarAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
extern void InitGVarAttrsFromTable(const StructGVarAttr * tab);


/****************************************************************************
**
*F  InitGVarPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
extern void InitGVarPropsFromTable(const StructGVarProp * tab);


/****************************************************************************
**
*F  InitGVarOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
extern void InitGVarOpersFromTable(const StructGVarOper * tab);


/****************************************************************************
**
*F  InitGVarFuncsFromTable( <tab> ) . . . . . . . . . . . . . .  new function
*/
extern void InitGVarFuncsFromTable(const StructGVarFunc * tab);


/****************************************************************************
**
*F  InitHdlrFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
extern void InitHdlrFiltsFromTable(const StructGVarFilt * tab);


/****************************************************************************
**
*F  InitHdlrAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
extern void InitHdlrAttrsFromTable(const StructGVarAttr * tab);


/****************************************************************************
**
*F  InitHdlrPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
extern void InitHdlrPropsFromTable(const StructGVarProp * tab);


/****************************************************************************
**
*F  InitHdlrOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
extern void InitHdlrOpersFromTable(const StructGVarOper * tab);


/****************************************************************************
**
*F  InitHdlrFuncsFromTable( <tab> ) . . . . . . . . . . . . . . new functions
*/
extern void InitHdlrFuncsFromTable(const StructGVarFunc * tab);


/****************************************************************************
**
*F  ImportGVarFromLibrary( <name>, <address> )  . . .  import global variable
*/
extern void ImportGVarFromLibrary(
            const Char *        name,
            Obj *               address );


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/
extern void ImportFuncFromLibrary(
            const Char *        name,
            Obj *               address );


/****************************************************************************
**
*F  Modules . . . . . . . . . . . . . . . . . . . . . . . . . list of modules
*/
typedef struct {

    // pointer to the actual StructInitInfo
    StructInitInfo * info;

    // filename relative to GAP_ROOT or absolute
    Char *           filename;

    // true if the filename is GAP_ROOT relative
    Int              isGapRootRelative;

} StructInitInfoExt;

extern StructInitInfoExt Modules [];
extern UInt NrModules;
extern UInt NrBuiltinModules;




/****************************************************************************
**
*F  RecordLoadedModule( <module> )  . . . . . . . . store module in <Modules>
**
**  The filename argument is a C string. A copy of it is taken in some
**   private space and added to the module info.
*/
extern void RecordLoadedModule (
    StructInitInfo *        module,
    Int                     isGapRootRelative,
    const Char *            filename );




/****************************************************************************
**
*F  InitializeGap( <argc>, <argv> ) . . . . . . . . . . . . . . . .  init GAP
*/
extern void InitializeGap (
            int *               pargc,
            char *              argv [],
            char *              environ [] );


#endif // GAP_GAP_H
