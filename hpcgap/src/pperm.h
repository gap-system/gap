
#include        "system.h"              /* system dependent part           */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* basic arithmetic                */

#include        "bool.h"                /* booleans                        */

#include        "integer.h"             /* integers                        */
#include        "intfuncs.h"            /* hashing                         */

#include        "permutat.h"            /* permutations                    */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */
#include        "range.h"               /* ranges                          */
#include        "stringobj.h"              /* strings                         */

#include        "saveload.h"            /* saving and loading              */

#include        "set.h"                 /* sets                            */

#include	"code.h"		/* coder                           */
#include	"hpc/thread.h"		/* threads			   */
#include	"hpc/tls.h"			/* thread-local storage		   */

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
