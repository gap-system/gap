/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
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
*F  OpenErrorOutput()  . . . . . . . open the file or stream assigned to the
**                                   ERROR_OUTPUT global variable defined in
**                                   error.g, or "*errout*" otherwise
*/
UInt OpenErrorOutput(void);

/****************************************************************************
**
*F  ErrorQuit( <msg>, <arg1>, <arg2> )  . . . . . . . . . . .  print and quit
*/
void ErrorQuit(const Char * msg, Int arg1, Int arg2) NORETURN;

/****************************************************************************
**
*F  ErrorMayQuit( <msg>, <arg1>, <arg2> )  . print, enter break loop and quit
**                                           no option to return anything.
*/
void ErrorMayQuit(const Char * msg, Int arg1, Int arg2) NORETURN;


/****************************************************************************
**
*F  ErrorMayQuitNrArgs( <narg>, <actual> ) . . . .  wrong number of arguments
*/
void ErrorMayQuitNrArgs(Int narg, Int actual) NORETURN;

/****************************************************************************
**
*F  ErrorMayQuitNrAtLeastArgs( <narg>, <actual> ) . . .  not enough arguments
*/
void ErrorMayQuitNrAtLeastArgs(Int narg, Int actual) NORETURN;

/****************************************************************************
**
*F  ErrorQuitRange3( <first>, <second>, <last> ) . . .divisibility rules
*/
void ErrorQuitRange3(Obj first, Obj second, Obj last) NORETURN;


/****************************************************************************
**
*F  ErrorReturnObj( <msg>, <arg1>, <arg2>, <msg2> ) . .  print and return obj
*/
Obj ErrorReturnObj(const Char * msg, Int arg1, Int arg2, const Char * msg2);


/****************************************************************************
**
*F  ErrorReturnVoid( <msg>, <arg1>, <arg2>, <msg2> )  . . .  print and return
*/
void ErrorReturnVoid(const Char * msg, Int arg1, Int arg2, const Char * msg2);


/****************************************************************************
**
*F  RequireArgumentEx( <funcname>, <op>, <argname>, <msg>)
**
**  Raises an error via ErrorMayQuit with an error message of this form:
**    funcname: <argname> msg (not a %s)
**  Here, %s is replaced by a brief text which describes the type or content
**  of <op>.
**
**  If funcname is 0, then 'funcname: ' is omitted from the message.
**  If argname is 0, then '<argname> ' is omitted from the message.
*/
Obj RequireArgumentEx(const char * funcname,
                      Obj          op,
                      const char * argname,
                      const char * msg) NORETURN;

#define NICE_ARGNAME(op) "<" #op ">"

/****************************************************************************
**
*F  RequireArgument
*/
#define RequireArgument(funcname, op, msg)                                   \
    RequireArgumentEx(funcname, op, NICE_ARGNAME(op), msg)

/****************************************************************************
**
*F  RequireArgumentConditionEx
*/
#define RequireArgumentConditionEx(funcname, op, argname, cond, msg)         \
    do {                                                                     \
        if (!(cond)) {                                                       \
            RequireArgumentEx(funcname, op, argname, msg);                   \
        }                                                                    \
    } while (0)

/****************************************************************************
**
*F  RequireArgumentCondition
*/
#define RequireArgumentCondition(funcname, op, cond, msg)                    \
    RequireArgumentConditionEx(funcname, op, NICE_ARGNAME(op), cond, msg)


/****************************************************************************
**
*F  RequireInt
*/
#define RequireInt(funcname, op)                                             \
    RequireArgumentCondition(funcname, op, IS_INT(op), "must be an integer")


/****************************************************************************
**
*F  RequireSmallInt
*/
#define RequireSmallInt(funcname, op, argname)                               \
    RequireArgumentConditionEx(funcname, op, argname, IS_INTOBJ(op),         \
                               "must be a small integer")


/****************************************************************************
**
*F  RequirePositiveSmallInt
*/
#define RequirePositiveSmallInt(funcname, op, argname)                       \
    RequireArgumentConditionEx(funcname, op, argname, IS_POS_INTOBJ(op),     \
                               "must be a positive small integer")


/****************************************************************************
**
*F  RequireNonnegativeSmallInt
*/
#define RequireNonnegativeSmallInt(funcname, op)                             \
    RequireArgumentCondition(funcname, op, IS_NONNEG_INTOBJ(op),             \
                             "must be a non-negative small integer")


/****************************************************************************
**
*F  RequireSmallList
*/
#define RequireSmallList(funcname, op)                                       \
    RequireArgumentCondition(funcname, op, IS_SMALL_LIST(op),                \
                             "must be a small list")


/****************************************************************************
**
*F  RequireFunction
*/
#define RequireFunction(funcname, op)                                        \
    RequireArgumentCondition(funcname, op, IS_FUNC(op), "must be a function")


/****************************************************************************
**
*F  RequireStringRep
*/
#define RequireStringRep(funcname, op)                                       \
    RequireArgumentCondition(funcname, op, IsStringConv(op),                 \
                             "must be a string")


/****************************************************************************
**
*F  RequirePermutation
*/
#define RequirePermutation(funcname, op)                                     \
    RequireArgumentCondition(funcname, op, IS_PERM(op),                      \
                             "must be a permutation")


/****************************************************************************
**
*F  RequirePlainList
*/
#define RequirePlainList(funcname, op)                                       \
    RequireArgumentCondition(funcname, op, IS_PLIST(op),                     \
                             "must be a plain list")


/****************************************************************************
**
*F  GetSmallIntEx, GetSmallInt
*/
EXPORT_INLINE Int
GetSmallIntEx(const char * funcname, Obj op, const char * argname)
{
    RequireSmallInt(funcname, op, argname);
    return INT_INTOBJ(op);
}

#define GetSmallInt(funcname, op)                                            \
    GetSmallIntEx(funcname, op, NICE_ARGNAME(op))

/****************************************************************************
**
*F  GetPositiveSmallIntEx, GetPositiveSmallInt
*/
EXPORT_INLINE Int
GetPositiveSmallIntEx(const char * funcname, Obj op, const char * argname)
{
    RequirePositiveSmallInt(funcname, op, argname);
    return INT_INTOBJ(op);
}

#define GetPositiveSmallInt(funcname, op)                                    \
    GetPositiveSmallIntEx(funcname, op, NICE_ARGNAME(op))


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
void CheckSameLength(const Char * desc,
                     const Char * leftName,
                     const Char * rightName,
                     Obj          left,
                     Obj          right);


/****************************************************************************
**
*F  CALL_WITH_CATCH
*/
Obj CALL_WITH_CATCH(Obj func, Obj args);


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
