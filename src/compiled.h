/****************************************************************************
**
*W  compiled.h                  GAP source                   Martin Schoenert
**
**  This package defines macros and functions that are used by compiled code.
**  Those macros and functions should go into the appropriate packages.
*/
#include        "system.h"
#include        "gasman.h"
#include        "objects.h"
#include        "gvars.h"
#include        "calls.h"
#include        "ariths.h"
#include        "records.h"
#include        "lists.h"
#include        "bool.h"
#include        "integer.h"
#include        "precord.h"
#include        "plist.h"
#include        "string.h"
#include        "code.h"
#include        "vars.h"
#include        "gap.h"
#include        "permutat.h"


extern Obj InfoDecision;
extern Obj InfoDoPrint;
extern Obj CurrentAssertionLevel;

extern Obj NewAndFilter (
    Obj                 oper1,
    Obj                 oper2 );


extern Obj Array2Perm(
    Obj                 array );


/* types, should go into 'gvars.c' and 'records.c' * * * * * * * * * * * * */

typedef UInt    GVar;

typedef UInt    RNam;


/* checks, should go into 'gap.c'  * * * * * * * * * * * * * * * * * * * * */

#define CHECK_BOUND(obj,name) \
 if ( obj == 0 ) ErrorQuitBound(name);

extern  void            ErrorQuitBound (
            Char *              name );

#define CHECK_FUNC_RESULT(obj) \
 if ( obj == 0 ) ErrorQuitFuncResult();

extern  void            ErrorQuitFuncResult ( void );

#define CHECK_INT_SMALL(obj) \
 if ( ! IS_INTOBJ(obj) ) ErrorQuitIntSmall(obj);

extern  void            ErrorQuitIntSmall (
            Obj                 obj );

#define CHECK_INT_SMALL_POS(obj) \
 if ( ! IS_INTOBJ(obj) || INT_INTOBJ(obj) <= 0 ) ErrorQuitIntSmallPos(obj);

extern  void            ErrorQuitIntSmallPos (
            Obj                 obj );

#define CHECK_BOOL(obj) \
 if ( obj != True && obj != False ) ErrorQuitBool(obj);

extern  void            ErrorQuitBool (
            Obj                 obj );

#define CHECK_FUNC(obj) \
 if ( TNUM_OBJ(obj) != T_FUNCTION ) ErrorQuitFunc(obj);

extern  void            ErrorQuitFunc (
            Obj                 obj );

#define CHECK_NR_ARGS(narg,args) \
 if ( narg != LEN_PLIST(args) ) ErrorQuitNrArgs(narg,args);

extern  void            ErrorQuitNrArgs (
            Int                 narg,
            Obj                 args );


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


/* arithmetic, should go into 'ariths.c' * * * * * * * * * * * * * * * * * */

#define C_SUM(val,left,right) \
 val = SUM( left, right );

#define C_SUM_FIA(val,left,right) \
 if ( ! ARE_INTOBJS(left,right) || ! SUM_INTOBJS(val,left,right) ) { \
  val = SUM( left, right ); \
 }

#define C_SUM_INTOBJS(val,left,right) \
 if ( ! SUM_INTOBJS(val,left,right) ) { \
  val = SUM( left, right ); \
 }

#define C_AINV(val,left) \
 val = AINV( left );

#define C_AINV_FIA(val,left) \
 val = AINV( left );

#define C_AINV_INTOBJS(val,left) \
 val = AINV( left );

#define C_DIFF(val,left,right) \
 val = DIFF( left, right );

#define C_DIFF_FIA(val,left,right) \
 if ( ! ARE_INTOBJS(left,right) || ! DIFF_INTOBJS(val,left,right) ) { \
  val = DIFF( left, right ); \
 }

#define C_DIFF_INTOBJS(val,left,right) \
 if ( ! DIFF_INTOBJS(val,left,right) ) { \
  val = DIFF( left, right ); \
 }

#define C_PROD(val,left,right) \
 val = PROD( left, right );

#define C_PROD_FIA(val,left,right) \
 if ( ! ARE_INTOBJS(left,right) || ! PROD_INTOBJS(val,left,right) ) { \
  val = PROD( left, right ); \
 }

#define C_PROD_INTOBJS(val,left,right) \
 if ( ! PROD_INTOBJS(val,left,right) ) { \
  val = PROD( left, right ); \
 }


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
 len = INTOBJ_INT( LEN_LIST(list) );

#define C_LEN_LIST_FPL(len,list) \
 if ( TNUM_OBJ(list) == T_PLIST ) { \
  len = INTOBJ_INT( LEN_PLIST(list) ); \
 } \
 else { \
  len = INTOBJ_INT( LEN_LIST(list) ); \
 }

#define C_ELM_LIST(elm,list,p) \
 elm = ELM_LIST( list, p );

#define C_ELM_LIST_NLE(elm,list,p) \
 elm = ELMW_LIST( list, p );

#define C_ELM_LIST_FPL(elm,list,p) \
 if ( TNUM_OBJ(list) == T_PLIST ) { \
  if ( p <= LEN_PLIST(list) ) { \
   elm = ELM_PLIST( list, p ); \
   if ( elm == 0 ) elm = ELM_LIST( list, p ); \
  } else elm = ELM_LIST( list, p ); \
 } else elm = ELM_LIST( list, p );

#define C_ELM_LIST_NLE_FPL(elm,list,p) \
 if ( TNUM_OBJ(list) == T_PLIST ) { \
  elm = ELM_PLIST( list, p ); \
 } else elm = ELMW_LIST( list, p );

#define C_ASS_LIST(list,p,rhs) \
 ASS_LIST( list, p, rhs ); \

#define C_ASS_LIST_FPL(list,p,rhs) \
 if ( TNUM_OBJ(list) == T_PLIST ) { \
  if ( LEN_PLIST(list) < p ) { \
   GROW_PLIST( list, p ); \
   SET_LEN_PLIST( list, p ); \
  } \
  SET_ELM_PLIST( list, p, rhs ); \
  CHANGED_BAG( list ); \
 } \
 else { \
  ASS_LIST( list, p, rhs ); \
 }

#define C_ASS_LIST_FPL_INTOBJ(list,p,rhs) \
 if ( TNUM_OBJ(list) == T_PLIST ) { \
  if ( LEN_PLIST(list) < p ) { \
   GROW_PLIST( list, p ); \
   SET_LEN_PLIST( list, p ); \
  } \
  SET_ELM_PLIST( list, p, rhs ); \
 } \
 else { \
  ASS_LIST( list, p, rhs ); \
 }

extern  void            AddList (
            Obj                 list,
            Obj                 obj );

extern  void            AddPlist (
            Obj                 list,
            Obj                 obj );

#define C_ADD_LIST(list,obj) \
 AddList( list, obj );

#define C_ADD_LIST_FPL(list,obj) \
 if ( TNUM_OBJ(list) == T_PLIST ) { \
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

extern  Obj             ElmsListCheck (
            Obj                 list,
            Obj                 poss );

extern  void            ElmsListLevelCheck (
            Obj                 lists,
            Obj                 poss,
            Int                 level );

extern  void            AsssListCheck (
            Obj                 list,
            Obj                 poss,
            Obj                 rhss );

extern  void            AsssListLevelCheck (
            Obj                 lists,
            Obj                 poss,
            Obj                 rhss,
            Int                 level );


/* strings, should go into 'string.c'  * * * * * * * * * * * * * * * * * * */

/* ranges, should go into 'range.c'  * * * * * * * * * * * * * * * * * * * */

extern  Obj             Range2Check (
            Obj                 first,
            Obj                 last );

extern  Obj             Range3Check (
            Obj                 first,
            Obj                 second,
            Obj                 last );


/****************************************************************************
**
*E  compiled.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



