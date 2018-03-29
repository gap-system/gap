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

#include <src/error.h>
#include <src/modules.h>

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
*F  InitializeGap( <argc>, <argv> ) . . . . . . . . . . . . . . . .  init GAP
*/
extern void InitializeGap (
            int *               pargc,
            char *              argv [],
            char *              environ [] );


#endif // GAP_GAP_H
