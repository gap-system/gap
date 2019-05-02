/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the various read-eval-print loops and  related  stuff.
*/

#ifndef GAP_GAP_H
#define GAP_GAP_H

#include "system.h"


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
*F  UpdateLast(<newLast>, <lastDepth>)
**
**  Updates Last, Last2 and Last3 by the new result 'newLast'.
**  <lastDepth> determines how many of these variables should be updated, starting
**  always with 'Last'.
*/
void UpdateLast(Obj newLast, Int lastDepth);


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

void ViewObjHandler(Obj obj);


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
*S  MAX_FUNC_EXPR_NESTING_BITS
*S  MAX_FUNC_EXPR_NESTING . . . . . . . . . . . . . . . maximal nesting level
**
**  GAP functions can be nested; any function 'A' can contain definition of
**  another function 'B', and function 'B' then has full access to the local
**  variables of 'A', including its arguments. As encoding access to such
**  "higher" local variables must be encoded in limited storage, we also
**  limit how deeply functions can be nested.
*/
enum {
    MAX_FUNC_EXPR_NESTING_BITS = 10,
    MAX_FUNC_EXPR_NESTING      = 1L << MAX_FUNC_EXPR_NESTING_BITS,
};


/****************************************************************************
**
*S  MAX_FUNC_LVARS_BITS
*S  MAX_FUNC_LVARS_MASK
*S  MAX_FUNC_LVARS  . . . .  maximal numbers of local variables in a function
**
**  Note that function arguments also count as local variables.
*/
enum {
    MAX_FUNC_LVARS_BITS = 16,
    MAX_FUNC_LVARS      = 1L << MAX_FUNC_LVARS_BITS,
    MAX_FUNC_LVARS_MASK = MAX_FUNC_LVARS - 1,
};


/****************************************************************************
**
*F  IsUsingLibGap()  . . . . . . . . 1 if GAP is being used a library, else 0
*/
int IsUsingLibGap(void);

/****************************************************************************
**
*F  InitializeGap( <argc>, <argv>, <handleSignals> )  . . . . . . .  init GAP
*/
void InitializeGap(int * pargc, char * argv[], UInt handleSignals);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoGap() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoGap(void);


#endif // GAP_GAP_H
