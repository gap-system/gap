
#include <src/system.h>                 /* system dependent part */
#include <src/globalstate.h>

#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/bool.h>                   /* booleans */

#include <src/gmpints.h>                /* integers */
#include <src/intfuncs.h>               /* hashing */

#include <src/permutat.h>               /* permutations */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/range.h>                  /* ranges */
#include <src/stringobj.h>              /* strings */

#include <src/saveload.h>               /* saving and loading */

#include <src/set.h>                    /* sets */

#include <src/code.h>                   /* coder */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/tls.h>                /* thread-local storage */

#ifndef GAP_PPERM_H
#define GAP_PPERM_H

/****************************************************************************
**
*F  OnTuplesPPerm( <tup>, <f> )  . . . .  operations on tuples of points
**
**  'OnTuplesPPerm'  returns  the  image  of  the  tuple  <tup>   under  the
**  PPerm <f>.
*/

extern Obj OnTuplesPPerm ( Obj set, Obj f );

/****************************************************************************
**
*F  OnSetsPPerm( <set>, <f> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsPPerm' returns the  image of the  tuple <set> under the 
**  partial perm <f>. 
*/

extern Obj OnSetsPPerm ( Obj set, Obj f );

/****************************************************************************

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/****************************************************************************

*F  InitInfoPPerm()  . . . . . . . . . . . . . . . table of init functions
*/

StructInitInfo * InitInfoPPerm ( void );

#endif // GAP_PPERM_H
