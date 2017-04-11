
#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>

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
#include <src/listfunc.h>               /* functions for lists */
#include <src/plist.h>                  /* plain lists */
#include <src/range.h>                  /* ranges */
#include <src/stringobj.h>              /* strings */

#include <src/saveload.h>               /* saving and loading */

#include <src/set.h>                    /* sets */

#include <src/code.h>                   /* coder */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/tls.h>                /* thread-local storage */

#ifndef GAP_TRANS_H
#define GAP_TRANS_H

extern UInt INIT_TRANS2(Obj f);
extern UInt INIT_TRANS4(Obj f);

#define IMG_TRANS(f)      (*(Obj*)(ADDR_OBJ(f)))
#define KER_TRANS(f)      (*((Obj*)(ADDR_OBJ(f))+1))
#define EXT_TRANS(f)      (*((Obj*)(ADDR_OBJ(f))+2))

#define NEW_TRANS2(deg)   NewBag(T_TRANS2, deg*sizeof(UInt2)+3*sizeof(Obj))
#define ADDR_TRANS2(f)    ((UInt2*)((Obj*)(ADDR_OBJ(f))+3))
#define DEG_TRANS2(f)     ((UInt)(SIZE_OBJ(f)-3*sizeof(Obj))/sizeof(UInt2))
#define RANK_TRANS2(f)    (IMG_TRANS(f)==NULL?INIT_TRANS2(f):LEN_PLIST(IMG_TRANS(f)))

#define NEW_TRANS4(deg)   NewBag(T_TRANS4, deg*sizeof(UInt4)+3*sizeof(Obj))
#define ADDR_TRANS4(f)    ((UInt4*)((Obj*)(ADDR_OBJ(f))+3))
#define DEG_TRANS4(f)     ((UInt)(SIZE_OBJ(f)-3*sizeof(Obj))/sizeof(UInt4))
#define RANK_TRANS4(f)    (IMG_TRANS(f)==NULL?INIT_TRANS4(f):LEN_PLIST(IMG_TRANS(f)))

#define IS_TRANS(f)       (TNUM_OBJ(f)==T_TRANS2||TNUM_OBJ(f)==T_TRANS4)
#define RANK_TRANS(f)     (TNUM_OBJ(f)==T_TRANS2?RANK_TRANS2(f):RANK_TRANS4(f))
#define DEG_TRANS(f)      (TNUM_OBJ(f)==T_TRANS2?DEG_TRANS2(f):DEG_TRANS4(f))

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
**
*V  EqPermTrans22 . . . . . . . . . . . . . . . . .  
**
**  The actual equality checking function for Perm2 and Trans2.
*/
Int EqPermTrans22 (UInt                degL,
                   UInt                degR, 
                   UInt2 *             ptLstart,       
                   UInt2 *             ptRstart);

/****************************************************************************
**
*V  EqPermTrans44 . . . . . . . . . . . . . . . . .  
**
**  The actual equality checking function for Perm4 and Trans4.
*/
Int EqPermTrans44 (UInt                degL,
                   UInt                degR, 
                   UInt4 *             ptLstart,       
                   UInt4 *             ptRstart);

/****************************************************************************

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/****************************************************************************

*F  InitInfoTrans()  . . . . . . . . . . . . . . . table of init functions
*/

StructInitInfo * InitInfoTrans ( void );

#endif // GAP_TRANS_H
