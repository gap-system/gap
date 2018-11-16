/****************************************************************************
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002-2018 The GAP Group
**
**  This file declares functions for raising user errors and interacting
**  with the break loop.
**
*/

#ifndef GAP_ERROR_H
#define GAP_ERROR_H

#include "system.h"
#include "intobj.h"

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
extern void ErrorQuit(const Char * msg, Int arg1, Int arg2) NORETURN;

/****************************************************************************
**
*F  ErrorMayQuit( <msg>, <arg1>, <arg2> )  . print, enter break loop and quit
**                                           no option to return anything.
*/
extern void ErrorMayQuit(const Char * msg, Int arg1, Int arg2) NORETURN;


/****************************************************************************
**
*F  ErrorMayQuitNrArgs( <narg>, <actual> ) . . . .  wrong number of arguments
*/
extern void ErrorMayQuitNrArgs(Int narg, Int actual) NORETURN;

/****************************************************************************
**
*F  ErrorMayQuitNrAtLeastArgs( <narg>, <actual> ) . . .  not enough arguments
*/
extern void ErrorMayQuitNrAtLeastArgs(Int narg, Int actual) NORETURN;

/****************************************************************************
**
*F  ErrorQuitRange3( <first>, <second>, <last> ) . . .divisibility rules
*/
extern void ErrorQuitRange3(Obj first, Obj second, Obj last) NORETURN;


/****************************************************************************
**
*F  ErrorReturnObj( <msg>, <arg1>, <arg2>, <msg2> ) . .  print and return obj
*/
extern Obj
ErrorReturnObj(const Char * msg, Int arg1, Int arg2, const Char * msg2);


/****************************************************************************
**
*F  ErrorReturnVoid( <msg>, <arg1>, <arg2>, <msg2> )  . . .  print and return
*/
extern void
ErrorReturnVoid(const Char * msg, Int arg1, Int arg2, const Char * msg2);


/****************************************************************************
**
*F  RequireArgument
*/
extern Obj RequireArgument(const char * funcname,
                           Obj          op,
                           const char * argname,
                           const char * msg);

/****************************************************************************
**
*F  RequireArgumentCondition
*/
#define RequireArgumentCondition(funcname, op, argname, cond, msg)           \
    do {                                                                     \
        if (!(cond)) {                                                       \
            RequireArgument(funcname, op, argname, msg);                     \
        }                                                                    \
    } while (0)


/****************************************************************************
**
*F  RequireInt
*/
#define RequireInt(funcname, op, argname) \
    RequireArgumentCondition(funcname, op, argname, IS_INT(op), \
        "must be an integer")


/****************************************************************************
**
*F  RequireSmallInt
*/
#define RequireSmallInt(funcname, op, argname) \
    RequireArgumentCondition(funcname, op, argname, IS_INTOBJ(op), \
        "must be a small integer")


/****************************************************************************
**
*F  RequirePositiveSmallInt
*/
#define RequirePositiveSmallInt(funcname, op, argname) \
    RequireArgumentCondition(funcname, op, argname, IS_POS_INTOBJ(op), \
        "must be a positive small integer")


/****************************************************************************
**
*F  RequireNonnegativeSmallInt
*/
#define RequireNonnegativeSmallInt(funcname, op) \
    RequireArgumentCondition(funcname, op, #op, IS_NONNEG_INTOBJ(op), \
        "must be a non-negative integer")


/****************************************************************************
**
*F  RequireSmallList
*/
#define RequireSmallList(funcname, op) \
    RequireArgumentCondition(funcname, op, #op, IS_SMALL_LIST(op), \
        "must be a small list")


/****************************************************************************
**
*F  RequireFunction
*/
#define RequireFunction(funcname, op) \
    RequireArgumentCondition(funcname, op, #op, IS_FUNC(op), \
        "must be a function")


/****************************************************************************
**
*F  RequireStringRep
*/
#define RequireStringRep(funcname, op) \
    RequireArgumentCondition(funcname, op, #op, IsStringConv(op), \
        "must be a string")


/****************************************************************************
**
*F  RequirePermutation
*/
#define RequirePermutation(funcname, op) \
    RequireArgumentCondition(funcname, op, #op, IS_PERM(op), \
        "must be a permutation")


/****************************************************************************
**
*F  GetSmallInt
*/
static inline Int GetSmallInt(const char * funcname, Obj op, const char * argname)
{
    RequireSmallInt(funcname, op, argname);
    return INT_INTOBJ(op);
}


/****************************************************************************
**
*F  CheckIsPossList( <desc>, <poss> ) . . . . . . . . . . check for poss list
*/
void CheckIsPossList(const Char * desc, Obj poss);


/****************************************************************************
**
*F  CheckIsDenseList( <desc>, <listName>, <list> ) . . . check for dense list
*/
void CheckIsDenseList(const Char * desc, const Char * listName, Obj list);


/****************************************************************************
**
*F  CheckSameLength
*/
void CheckSameLength(const Char * desc, const Char *leftName, const Char *rightName, Obj left, Obj right);


/****************************************************************************
**
*F * * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoError() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoError(void);


#endif    // GAP_ERROR_H
