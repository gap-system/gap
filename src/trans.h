
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

#include        "permutat.h"            /* permutations                    */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */
#include        "range.h"               /* ranges                          */
#include        "string.h"              /* strings                         */

#include        "saveload.h"            /* saving and loading              */

#include        "set.h"                 /* sets                            */

#ifndef GAP_TRANS_H
#define GAP_TRANS_H

/****************************************************************************
**
*F  OnTuplesTrans( <tup>, <f> )  . . . .  operations on tuples of points
**
**  'OnTuplesTrans'  returns  the  image  of  the  tuple  <tup>   under  the
**  transformation <f>.
*/
extern Obj OnTuplesTrans ( Obj tup, Obj f );

/****************************************************************************
**
*F  OnSetsTrans( <set>, <f> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsTrans' returns the  image of the  tuple <set> under the 
**  transformation <f>. 
*/
extern Obj OnSetsTrans ( Obj set, Obj f );

/****************************************************************************
**
*V  IdentityTrans  . . . . . . . . . . . . . . . . .  identity transformation
**
**  'IdentityTrans' is an identity transformation.
*/
extern  Obj             IdentityTrans;

/****************************************************************************

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/****************************************************************************

*F  InitInfoTrans()  . . . . . . . . . . . . . . . table of init functions
*/

StructInitInfo * InitInfoTrans ( void );

#endif // GAP_TRANS_H
