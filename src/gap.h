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
SYS_CONST char * Revision_gap_h =
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
            SYS_CONST Char *    msg,
            Int                 arg1,
            Int                 arg2 );


/****************************************************************************
**
*F  ErrorQuitBound( <name> )  . . . . . . . . . . . . . . .  unbound variable
*/
extern void ErrorQuitBound (
    Char *              name );


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
*F  ErrorReturnObj( <msg>, <arg1>, <arg2>, <msg2> ) . .  print and return obj
*/
extern Obj ErrorReturnObj (
            SYS_CONST Char *    msg,
            Int                 arg1,
            Int                 arg2,
            SYS_CONST Char *    msg2 );


/****************************************************************************
**
*F  ErrorReturnVoid( <msg>, <arg1>, <arg2>, <msg2> )  . . .  print and return
*/
extern void ErrorReturnVoid (
            SYS_CONST Char *    msg,
            Int                 arg1,
            Int                 arg2,
            SYS_CONST Char *    msg2 );


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
*F  IS_UNCOMPLETED_FUNC( <func> ) . . . . . . . . . . . is <func> uncompleted
*/
#define IS_UNCOMPLETED_FUNC(func) \
    (TNUM_OBJ(func)==T_FUNCTION && HDLR_FUNC(func,0)==DoComplete0args)


/****************************************************************************
**
*F  COMPLETE_FUNC( <func> ) . . . . . . . . . . . . . . . . . complete <func>
*/
#define COMPLETE_FUNC( func ) \
    (Complete( BODY_FUNC(func) ))


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
#define LAST_FN                 FN_IS_TABLE


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  ImportGVarFromLibrary( <name>, <address> )  . . .  import global variable
*/
extern void ImportGVarFromLibrary(
            SYS_CONST Char *    name,
            Obj *               address );


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/
extern void ImportFuncFromLibrary(
            SYS_CONST Char *    name,
            Obj *               address );


/****************************************************************************
**
*V  Revisions . . . . . . . . . . . . . . . . . .  record of revision numbers
*/
extern Obj Revisions;


/****************************************************************************
**
*F  SET_REVISION( <file>, <revision> )
*/
#define SET_REVISION( file, revision ) \
  do { \
      extern SYS_CONST char * revision; \
      UInt                    rev_rnam; \
      Obj                     rev_str; \
      rev_rnam = RNamName(file); \
      C_NEW_STRING( rev_str, SyStrlen(revision), revision ); \
      RESET_FILT_LIST( rev_str, FN_IS_MUTABLE ); \
      AssPRec( Revisions, rev_rnam, rev_str ); \
  } while (0)


/****************************************************************************
**
*F  InitializeGap( <argc>, <argv> ) . . . . . . . . . . . . . . . .  init GAP
*/
extern void InitializeGap (
            int *               pargc,
            char *              argv [] );


/****************************************************************************
**

*E  gap.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


