/****************************************************************************
**
*W  objccoll.c                  GAP source                      Werner Nickel
**
**
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file  contains  the collection functions of  combinatorial collectors
**  for finite p-groups.  The code in this file  is an extension to the single
**  collector module.  All necessary initialisations  are done in that module.
**  The interface to a combinatorial collection function is identical with the
**  interface to the corresponding single collector function.
**
*/
#include        "system.h"              /* Ints, UInts                     */


#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gvars.h"               /* global variables                */
#include        "gap.h"                 /* error handling, initialisation  */
#include        "tls.h"                 /* thread-local storage            */

#include        "calls.h"               /* generic call mechanism          */

#include        "records.h"             /* generic records                 */
#include        "lists.h"               /* generic lists                   */

#include        "bool.h"                /* booleans                        */

#include        "precord.h"             /* plain records                   */

#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "code.h"                /* coder                           */

#include        "objfgelm.h"            /* objects of free groups          */

#include        "objscoll.h"            /* single collector                */

#include        "objccoll.h"            /* combinatorial collector         */


#define CB(x)       C8Bits_ ## x
#define UIntN       UInt1
#include "objccoll-8bit.h"

#define CB(x)       C16Bits_ ## x
#define UIntN       UInt2
#include "objccoll-16bit.h"

#define CB(x)       C32Bits_ ## x
#define UIntN       UInt4
#include "objccoll-32bit.h"


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
**
**  This module does  not   need much initialisation  because  all  necessary
**  initialisations are done in the single collector module.
*/


/****************************************************************************
**
*F  InitInfoCombiCollector()  . . . . . . . . . . . . table of init functions
**
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "objccoll",                         /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    0,                                  /* initKernel                     */
    0,                                  /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoCombiCollector ( void )
{
    return &module;
}


/****************************************************************************
**

*E  objccoll.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
