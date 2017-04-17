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
*V  AlarmJumpBuffer . . . . . .long jump buffer used for timeouts 
**
**  Needs to be visible to code in read.c that stores away execution state 
*/


extern syJmp_buf AlarmJumpBuffers[];
extern UInt NumAlarmJumpBuffers;


/****************************************************************************
**

*F  ViewObjHandler  . . . . . . . . . handler to view object and catch errors
*/
extern UInt ViewObjGVar;
extern UInt CustomViewGVar;

extern void ViewObjHandler ( Obj obj );


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
*F RegisterBreakloopObserver( <func> )
**
** Register a function which will be called when the break loop is entered
** and left. Function should take a single Int argument which will be 1 when
** break loop is entered, 0 when leaving.
**
** Note that it is also possible to leave the break loop (or any GAP code)
** by longjmping. This should be tracked with RegisterSyLongjmpObserver.
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
            Int                 arg2 );

/****************************************************************************
**
*F  ErrorMayQuit( <msg>, <arg1>, <arg2> )  . print, enter break loop and quit
**                                           no option to return anything.
*/
extern void ErrorMayQuit (
            const Char *        msg,
            Int                 arg1,
            Int                 arg2 );


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
extern void ErrorQuitFuncResult ( void );


/****************************************************************************
**
*F  ErrorQuitIntSmall( <obj> )  . . . . . . . . . . . . . not a small integer
*/
extern void ErrorQuitIntSmall (
    Obj                 obj );


/****************************************************************************
**
*F  ErrorQuitIntSmallPos( <obj> ) . . . . . . .  not a positive small integer
*/
extern void ErrorQuitIntSmallPos (
    Obj                 obj );

/****************************************************************************
**
*F  ErrorQuitIntPos( <obj> ) . . . . . . .  not a positive  integer
*/
extern void ErrorQuitIntPos (
    Obj                 obj );


/****************************************************************************
**
*F  ErrorQuitBool( <obj> )  . . . . . . . . . . . . . . . . . . not a boolean
*/
extern void ErrorQuitBool (
    Obj                 obj );


/****************************************************************************
**
*F  ErrorQuitFunc( <obj> )  . . . . . . . . . . . . . . . . .  not a function
*/
extern void ErrorQuitFunc (
    Obj                 obj );


/****************************************************************************
**
*F  ErrorQuitNrArgs( <narg>, <args> ) . . . . . . . wrong number of arguments
*/
extern void ErrorQuitNrArgs (
    Int                 narg,
    Obj                 args );

/****************************************************************************
**
*F  ErrorQuitNrAtLeastArgs( <narg>, <args> ) . . . . . . not enough arguments
*/
extern void ErrorQuitNrAtLeastArgs (
    Int                 narg,
    Obj                 args );

/****************************************************************************
**
*F  ErrorQuitRange3( <first>, <second>, <last> ) . . .divisibility rules
*/
extern void ErrorQuitRange3 (
    Obj                 first,
    Obj                 second,
    Obj                 last);


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

/* TL: extern Obj ErrorLVars;
   TL: extern Obj ErrorLVars0;
 */

/****************************************************************************
**
*T  ExecStatus . . . .  type of status values returned by read, eval and exec
**                      subroutines, explaining why evaluation, or execution
**                      has terminated.
**
**  Values are powers of two, although I do not currently know of any
**  cirumstances where they can get combined
**
** STATUS_END           0    ran off the end of the code 
** STATUS_RETURN_VAL    1    value returned  
** STATUS_RETURN_VOID   2    void returned   
** STATUS_TNM           4    try-next-method 
** STATUS_QUIT          8    quit command
** STATUS_EOF          16    End of file 
** STATUS_ERROR        32    error
** STATUS_QQUIT        64    QUIT command
*/

typedef UInt ExecStatus;

#define STATUS_END         0
#define STATUS_RETURN_VAL  1
#define STATUS_RETURN_VOID 2
#define STATUS_TNM         4
#define STATUS_QUIT        8
#define STATUS_EOF        16
#define STATUS_ERROR      32
#define STATUS_QQUIT      64



// TL: extern UInt UserHasQuit;
// TL: extern UInt UserHasQUIT;
extern UInt SystemErrorCode;

/****************************************************************************
**

*F * * * * * * * * * * * * * important filters  * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  FN_IS_MUTABLE . . . . . . . . . . . . . . . filter number for `IsMutable'
*/
#define FN_IS_MUTABLE           1


/****************************************************************************
**
*V  FN_IS_EMPTY . . . . . . . . . . . . . . . . . filter number for `IsEmpty'
*/
#define FN_IS_EMPTY             2


/****************************************************************************
**
*V  FN_IS_SSORT . . . . . . . . . . . . . . filter number for `IsSSortedList'
*/
#define FN_IS_SSORT             3


/****************************************************************************
**
*V  FN_IS_NSORT . . . . . . . . . . . . . . filter number for `IsNSortedList'
*/
#define FN_IS_NSORT             4


/****************************************************************************
**
*V  FN_IS_DENSE . . . . . . . . . . . . . . . filter number for `IsDenseList'
*/
#define FN_IS_DENSE             5


/****************************************************************************
**
*V  FN_IS_NDENSE  . . . . . . . . . . . . .  filter number for `IsNDenseList'
*/
#define FN_IS_NDENSE            6


/****************************************************************************
**
*V  FN_IS_HOMOG . . . . . . . . . . . . filter number for `IsHomogeneousList'
*/
#define FN_IS_HOMOG             7


/****************************************************************************
**
*V  FN_IS_NHOMOG  . . . . . . . . .  filter number for `IsNonHomogeneousList'
*/
#define FN_IS_NHOMOG            8


/****************************************************************************
**
*V  FN_IS_TABLE . . . . . . . . . . . . . . . . . filter number for `IsTable'
*/
#define FN_IS_TABLE             9

/****************************************************************************
**
*V  FN_IS_RECT . . . . . . . . . . . . filter number for `IsRectangularTable'
*/
#define FN_IS_RECT             10
#define LAST_FN                 FN_IS_RECT


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  FillInVersion -- obsolete function, only kept for backwards compatibility
**  with packages using it.
*/
static inline void FillInVersion ( StructInitInfo * module ) {}


/****************************************************************************
**
*F  InitBagNamesFromTable( <table> )  . . . . . . . . .  initialise bag names
*/
extern void InitBagNamesFromTable (
    StructBagNames *            tab );


/****************************************************************************
**
*F  InitClearFiltsTNumsFromTable( <tab> ) . . .  initialise clear filts tnums
*/
extern void InitClearFiltsTNumsFromTable (
    Int *               tab );


/****************************************************************************
**
*F  InitHasFiltListTNumsFromTable( <tab> )  . . initialise tester filts tnums
*/
extern void InitHasFiltListTNumsFromTable (
    Int *               tab );


/****************************************************************************
**
*F  InitSetFiltListTNumsFromTable( <tab> )  . . initialise setter filts tnums
*/
extern void InitSetFiltListTNumsFromTable (
    Int *               tab );


/****************************************************************************
**
*F  InitResetFiltListTNumsFromTable( <tab> )  initialise unsetter filts tnums
*/
extern void InitResetFiltListTNumsFromTable (
    Int *               tab );


/****************************************************************************
**
*F  InitGVarFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
extern void InitGVarFiltsFromTable (
    StructGVarFilt *    tab );


/****************************************************************************
**
*F  InitGVarAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
extern void InitGVarAttrsFromTable (
    StructGVarAttr *    tab );


/****************************************************************************
**
*F  InitGVarPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
extern void InitGVarPropsFromTable (
    StructGVarProp *    tab );


/****************************************************************************
**
*F  InitGVarOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
extern void InitGVarOpersFromTable (
    StructGVarOper *    tab );


/****************************************************************************
**
*F  InitGVarFuncsFromTable( <tab> ) . . . . . . . . . . . . . .  new function
*/
extern void InitGVarFuncsFromTable (
    StructGVarFunc *    tab );


/****************************************************************************
**
*F  InitHdlrFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
extern void InitHdlrFiltsFromTable (
    StructGVarFilt *    tab );


/****************************************************************************
**
*F  InitHdlrAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
extern void InitHdlrAttrsFromTable (
    StructGVarAttr *    tab );


/****************************************************************************
**
*F  InitHdlrPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
extern void InitHdlrPropsFromTable (
    StructGVarProp *    tab );


/****************************************************************************
**
*F  InitHdlrOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
extern void InitHdlrOpersFromTable (
    StructGVarOper *    tab );


/****************************************************************************
**
*F  InitHdlrFuncsFromTable( <tab> ) . . . . . . . . . . . . . . new functions
*/
extern void InitHdlrFuncsFromTable (
    StructGVarFunc *    tab );


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

*V  Revisions . . . . . . . . . . . . . . . . . .  record of revision numbers
*/
extern Obj Revisions;


extern Obj Error;
extern Obj ErrorInner;

/****************************************************************************
**

*F  Modules . . . . . . . . . . . . . . . . . . . . . . . . . list of modules
*/
extern StructInitInfo * Modules [];
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
    Char *                  filename );




/****************************************************************************
**

*F  InitializeGap( <argc>, <argv> ) . . . . . . . . . . . . . . . .  init GAP
*/
extern void InitializeGap (
            int *               pargc,
            char *              argv [],
            char *              environ [] );


#endif // GAP_GAP_H

/****************************************************************************
**

*E  gap.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
