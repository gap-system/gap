/****************************************************************************
**
*W  compiled.h                  GAP source                   Martin Schoenert
**
**  This package defines macros and functions that are used by compiled code.
**  Those macros and functions should go into the appropriate packages.
*/
#include        "system.h"              /* system dependent part           */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "read.h"                /* reader                          */

#include        "gvars.h"               /* global variables                */
#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* basic arithmetic                */

#include        "integer.h"             /* integers                        */
#include        "rational.h"            /* rationals                       */
#include        "cyclotom.h"            /* cyclotomics                     */
#include        "finfield.h"            /* finite fields and ff elements   */

#include        "bool.h"                /* booleans                        */
#include        "permutat.h"            /* permutations                    */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "listoper.h"            /* operations for generic lists    */
#include        "listfunc.h"            /* functions for generic lists     */
#include        "plist.h"               /* plain lists                     */
#include        "set.h"                 /* plain sets                      */
#include        "vector.h"              /* functions for plain vectors     */
#include        "blister.h"             /* boolean lists                   */
#include        "range.h"               /* ranges                          */
#include        "string.h"              /* strings                         */

#include        "objfgelm.h"            /* objects of free groups          */
#include        "objpcgel.h"            /* objects of polycyclic groups    */
#include        "objscoll.h"            /* single collector                */
#include        "objcftl.h"             /* from the left collect           */

#include        "dt.h"                  /* deep thought                    */
#include        "dteval.h"              /* deep though evaluation          */

#include        "sctable.h"             /* structure constant table        */
#include        "costab.h"              /* coset table                     */
#include        "tietze.h"              /* tietze helper functions         */

#include        "code.h"                /* coder                           */

#include        "vars.h"                /* variables                       */
#include        "exprs.h"               /* expressions                     */
#include        "stats.h"               /* statements                      */
#include        "funcs.h"               /* functions                       */


#include        "intrprtr.h"            /* interpreter                     */

#include        "compiler.h"            /* compiler                        */

#include        "compstat.h"            /* statically linked modules       */

#include        "saveload.h"            /* saving and loading              */

#include        "streams.h"             /* streams package                 */
#include        "sysfiles.h"            /* file input/output               */
#include        "weakptr.h"             /* weak pointers                   */


extern Obj InfoDecision;
extern Obj InfoDoPrint;
extern Obj CurrentAssertionLevel;

extern Obj NewAndFilter (
    Obj                 oper1,
    Obj                 oper2 );


/* types, should go into 'gvars.c' and 'records.c' * * * * * * * * * * * * */

typedef UInt    GVar;

typedef UInt    RNam;


/* checks, should go into 'gap.c'  * * * * * * * * * * * * * * * * * * * * */

#define CHECK_BOUND(obj,name) \
 if ( obj == 0 ) ErrorQuitBound(name);

#define CHECK_FUNC_RESULT(obj) \
 if ( obj == 0 ) ErrorQuitFuncResult();

#define CHECK_INT_SMALL(obj) \
 if ( ! IS_INTOBJ(obj) ) ErrorQuitIntSmall(obj);

#define CHECK_INT_SMALL_POS(obj) \
 if ( ! IS_INTOBJ(obj) || INT_INTOBJ(obj) <= 0 ) ErrorQuitIntSmallPos(obj);

#define CHECK_INT_POS(obj) \
 if ( TNUM_OBJ(obj) != T_INTPOS && (! IS_INTOBJ(obj) || INT_INTOBJ(obj) <= 0) ) ErrorQuitIntPos(obj);

#define CHECK_BOOL(obj) \
 if ( obj != True && obj != False ) ErrorQuitBool(obj);

#define CHECK_FUNC(obj) \
 if ( TNUM_OBJ(obj) != T_FUNCTION ) ErrorQuitFunc(obj);

#define CHECK_NR_ARGS(narg,args) \
 if ( narg != LEN_PLIST(args) ) ErrorQuitNrArgs(narg,args);


/* higher variables, should go into 'vars.c' * * * * * * * * * * * * * * * */

#define SWITCH_TO_NEW_FRAME     SWITCH_TO_NEW_LVARS
#define SWITCH_TO_OLD_FRAME     SWITCH_TO_OLD_LVARS

#define CURR_FRAME              CurrLVars
#define CURR_FRAME_1UP          ENVI_FUNC( PTR_BAG( CURR_FRAME     )[0] )
#define CURR_FRAME_2UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_1UP )[0] )
#define CURR_FRAME_3UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_2UP )[0] )
#define CURR_FRAME_4UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_3UP )[0] )
#define CURR_FRAME_5UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_4UP )[0] )
#define CURR_FRAME_6UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_5UP )[0] )
#define CURR_FRAME_7UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_6UP )[0] )

/* #define OBJ_LVAR(lvar)  PtrLVars[(lvar)+2] */
#define OBJ_LVAR_0UP(lvar) \
    OBJ_LVAR(lvar)
#define OBJ_LVAR_1UP(lvar) \
    PTR_BAG(CURR_FRAME_1UP)[(lvar)+2]
#define OBJ_LVAR_2UP(lvar) \
    PTR_BAG(CURR_FRAME_2UP)[(lvar)+2]
#define OBJ_LVAR_3UP(lvar) \
    PTR_BAG(CURR_FRAME_3UP)[(lvar)+2]
#define OBJ_LVAR_4UP(lvar) \
    PTR_BAG(CURR_FRAME_4UP)[(lvar)+2]
#define OBJ_LVAR_5UP(lvar) \
    PTR_BAG(CURR_FRAME_5UP)[(lvar)+2]
#define OBJ_LVAR_6UP(lvar) \
    PTR_BAG(CURR_FRAME_6UP)[(lvar)+2]
#define OBJ_LVAR_7UP(lvar) \
    PTR_BAG(CURR_FRAME_7UP)[(lvar)+2]
#define OBJ_LVAR_8UP(lvar) \
    PTR_BAG(CURR_FRAME_8UP)[(lvar)+2]

/* #define ASS_LVAR(lvar,obj) do { PtrLVars[(lvar)+2] = (obj); } while ( 0 ) */
#define ASS_LVAR_0UP(lvar,obj) \
    ASS_LVAR(lvar,obj)
#define ASS_LVAR_1UP(lvar,obj) \
    do { PTR_BAG(CURR_FRAME_1UP)[(lvar)+2] = (obj); CHANGED_BAG(CURR_FRAME_1UP); } while ( 0 )
#define ASS_LVAR_2UP(lvar,obj) \
    do { PTR_BAG(CURR_FRAME_2UP)[(lvar)+2] = (obj); CHANGED_BAG(CURR_FRAME_2UP); } while ( 0 )
#define ASS_LVAR_3UP(lvar,obj) \
    do { PTR_BAG(CURR_FRAME_3UP)[(lvar)+2] = (obj); CHANGED_BAG(CURR_FRAME_3UP); } while ( 0 )
#define ASS_LVAR_4UP(lvar,obj) \
    do { PTR_BAG(CURR_FRAME_4UP)[(lvar)+2] = (obj); CHANGED_BAG(CURR_FRAME_4UP); } while ( 0 )
#define ASS_LVAR_5UP(lvar,obj) \
    do { PTR_BAG(CURR_FRAME_5UP)[(lvar)+2] = (obj); CHANGED_BAG(CURR_FRAME_5UP); } while ( 0 )
#define ASS_LVAR_6UP(lvar,obj) \
    do { PTR_BAG(CURR_FRAME_6UP)[(lvar)+2] = (obj); CHANGED_BAG(CURR_FRAME_6UP); } while ( 0 )
#define ASS_LVAR_7UP(lvar,obj) \
    do { PTR_BAG(CURR_FRAME_7UP)[(lvar)+2] = (obj); CHANGED_BAG(CURR_FRAME_7UP); } while ( 0 )
#define ASS_LVAR_8UP(lvar,obj) \
    do { PTR_BAG(CURR_FRAME_8UP)[(lvar)+2] = (obj); CHANGED_BAG(CURR_FRAME_8UP); } while ( 0 )


/* objects, should into 'objects.c'  * * * * * * * * * * * * * * * * * * * */

/* there should be a function for C_ELM_POSOBJ */
#define C_ELM_POSOBJ( elm, list, pos ) NOT_READY_YET


#define C_ELM_POSOBJ_NLE( elm, list, pos ) \
    if ( TNUM_OBJ(list) == T_POSOBJ ) { \
        elm = ELM_PLIST( list, pos ); \
    } \
    else { \
        elm = ELMW_LIST( list, pos ); \
    }

#define C_ASS_POSOBJ_INTOBJ( list, pos, elm ) \
    if ( TNUM_OBJ(list) == T_POSOBJ ) { \
        if ( SIZE_OBJ(list)/sizeof(Obj)-1 < pos ) { \
            ResizeBag( list, (pos+1)*sizeof(Obj) ); \
        } \
        SET_ELM_PLIST( list, pos, elm ); \
    } \
    else { \
        ASS_LIST( list, pos, elm ); \
    }

#define C_ASS_POSOBJ( list, pos, elm ) \
    if ( TNUM_OBJ(list) == T_POSOBJ ) { \
        if ( SIZE_OBJ(list)/sizeof(Obj)-1 < pos ) { \
            ResizeBag( list, (pos+1)*sizeof(Obj) ); \
        } \
        SET_ELM_PLIST( list, pos, elm ); \
        CHANGED_BAG(list); \
    } \
    else { \
        ASS_LIST( list, pos, elm ); \
    }



/* lists, should go into 'lists.c' * * * * * * * * * * * * * * * * * * * * */
#define C_LEN_LIST(len,list) \
 len = LENGTH(list);

#define C_LEN_LIST_FPL(len,list) \
 if ( TNUM_OBJ(list) >= FIRST_PLIST_TNUM && \
      TNUM_OBJ(list) <= LAST_PLIST_TNUM ) { \
  len = INTOBJ_INT( LEN_PLIST(list) ); \
 } \
 else { \
  len = LENGTH(list); \
 }




#define C_ELM_LIST(elm,list,p) \
 elm = IS_INTOBJ(p) ? ELM_LIST( list, INT_INTOBJ(p) ) : ELMB_LIST(list, p);

#define C_ELM_LIST_NLE(elm,list,p) \
 elm = IS_INTOBJ(p) ? ELMW_LIST( list, INT_INTOBJ(p) ) : ELMB_LIST(list, p);

#define C_ELM_LIST_FPL(elm,list,p) \
 if ( IS_INTOBJ(p) && \
      TNUM_OBJ(list) >= FIRST_PLIST_TNUM && \
      TNUM_OBJ(list) <= LAST_PLIST_TNUM ) { \
  if ( INT_INTOBJ(p) <= LEN_PLIST(list) ) { \
   elm = ELM_PLIST( list, INT_INTOBJ(p) ); \
   if ( elm == 0 ) elm = ELM_LIST( list, INT_INTOBJ(p) ); \
  } else elm = ELM_LIST( list, INT_INTOBJ(p) ); \
 } else C_ELM_LIST( elm, list, p )

#define C_ELM_LIST_NLE_FPL(elm,list,p) \
 if ( IS_INTOBJ(p) && \
      TNUM_OBJ(list) >= FIRST_PLIST_TNUM && \
      TNUM_OBJ(list) <= LAST_PLIST_TNUM ) { \
  elm = ELM_PLIST( list, INT_INTOBJ(p) ); \
 } else C_ELM_LIST_NLE(elm, list, p)

#define C_ASS_LIST(list,p,rhs) \
  if (IS_INTOBJ(p)) ASS_LIST( list, INT_INTOBJ(p), rhs ); \
  else ASSB_LIST(list, p, rhs);

#define C_ASS_LIST_FPL(list,p,rhs) \
 if ( IS_INTOBJ(p) && TNUM_OBJ(list) == T_PLIST ) { \
  if ( LEN_PLIST(list) < INT_INTOBJ(p) ) { \
   GROW_PLIST( list, (UInt)INT_INTOBJ(p) ); \
   SET_LEN_PLIST( list, INT_INTOBJ(p) ); \
  } \
  SET_ELM_PLIST( list, INT_INTOBJ(p), rhs ); \
  CHANGED_BAG( list ); \
 } \
 else { \
  C_ASS_LIST( list, p, rhs ) \
 }

#define C_ASS_LIST_FPL_INTOBJ(list,p,rhs) \
 if ( IS_INTOBJ(p) && TNUM_OBJ(list) == T_PLIST) { \
  if ( LEN_PLIST(list) < INT_INTOBJ(p) ) { \
   GROW_PLIST( list, (UInt)INT_INTOBJ(p) ); \
   SET_LEN_PLIST( list, INT_INTOBJ(p) ); \
  } \
  SET_ELM_PLIST( list, INT_INTOBJ(p), rhs ); \
 } \
 else { \
  C_ASS_LIST( list, p, rhs ) \
 }

#define C_ISB_LIST( list, pos) \
  ((IS_INTOBJ(pos) ? ISB_LIST(list, INT_INTOBJ(pos)) : ISBB_LIST( list, pos)) ? True : False)

#define C_UNB_LIST( list, pos) \
   if (IS_INTOBJ(pos)) UNB_LIST(list, INT_INTOBJ(pos)); else UNBB_LIST(list, pos);

extern  void            AddList (
            Obj                 list,
            Obj                 obj );

extern  void            AddPlist (
            Obj                 list,
            Obj                 obj );

#define C_ADD_LIST(list,obj) \
 AddList( list, obj );

#define C_ADD_LIST_FPL(list,obj) \
 if ( TNUM_OBJ(list) == T_PLIST) { \
  AddPlist( list, obj ); \
 } \
 else { \
  AddList( list, obj ); \
 }

#define GF_ITERATOR     ITERATOR
#define GF_IS_DONE_ITER IS_DONE_ITER
#define GF_NEXT_ITER    NEXT_ITER

extern  Obj             GF_ITERATOR;
extern  Obj             GF_IS_DONE_ITER;
extern  Obj             GF_NEXT_ITER;


/****************************************************************************
**
*E  compiled.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



