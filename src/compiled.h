/****************************************************************************
**
*W  compiled.h                  GAP source                   Martin Schönert
**
**  This package defines macros and functions that are used by compiled code.
**  Those macros and functions should go into the appropriate packages.
*/

#ifndef GAP_COMPILED_H
#define GAP_COMPILED_H

#ifdef __cplusplus
extern "C" {
#define GAP_IN_EXTERN_C
#endif

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
#include        "macfloat.h"            /* machine floats                  */

#include        "bool.h"                /* booleans                        */
#include        "permutat.h"            /* permutations                    */
#include        "trans.h"               /* transformation                  */
#include        "pperm.h"               /* partial perms                   */

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
#include        "stringobj.h"              /* strings                         */

#include        "code.h"                /* coder                           */
#include        "hpc/tls.h"                 /* thread-local storage            */

#include        "objfgelm.h"            /* objects of free groups          */
#include        "objpcgel.h"            /* objects of polycyclic groups    */
#include        "objscoll.h"            /* single collector                */
#include        "objcftl.h"             /* from the left collect           */

#include        "dt.h"                  /* deep thought                    */
#include        "dteval.h"              /* deep thought evaluation          */

#include        "sctable.h"             /* structure constant table        */
#include        "costab.h"              /* coset table                     */
#include        "tietze.h"              /* tietze helper functions         */

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

#include        "vars.h"                /* variables                       */

#include        "hpc/aobjects.h"            /* atomic variables                */
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
 if ( ! IS_POS_INTOBJ(obj) ) ErrorQuitIntSmallPos(obj);

#define CHECK_INT_POS(obj) \
 if ( TNUM_OBJ(obj) != T_INTPOS && ( ! IS_POS_INTOBJ(obj)) ) ErrorQuitIntPos(obj);

#define CHECK_BOOL(obj) \
 if ( obj != True && obj != False ) ErrorQuitBool(obj);

#define CHECK_FUNC(obj) \
 if ( TNUM_OBJ(obj) != T_FUNCTION ) ErrorQuitFunc(obj);

#define CHECK_NR_ARGS(narg,args) \
 if ( narg != LEN_PLIST(args) ) ErrorQuitNrArgs(narg,args);


/* higher variables, should go into 'vars.c' * * * * * * * * * * * * * * * */

#define SWITCH_TO_NEW_FRAME     SWITCH_TO_NEW_LVARS
#define SWITCH_TO_OLD_FRAME     SWITCH_TO_OLD_LVARS

#define CURR_FRAME              TLS(CurrLVars)
#define CURR_FRAME_1UP          ENVI_FUNC( PTR_BAG( CURR_FRAME     )[0] )
#define CURR_FRAME_2UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_1UP )[0] )
#define CURR_FRAME_3UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_2UP )[0] )
#define CURR_FRAME_4UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_3UP )[0] )
#define CURR_FRAME_5UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_4UP )[0] )
#define CURR_FRAME_6UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_5UP )[0] )
#define CURR_FRAME_7UP          ENVI_FUNC( PTR_BAG( CURR_FRAME_6UP )[0] )

/* #define OBJ_LVAR(lvar)  TLS(PtrLVars)[(lvar)+2] */
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

/* #define ASS_LVAR(lvar,obj) do { TLS(PtrLVars)[(lvar)+2] = (obj); } while ( 0 ) */
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
    else if ( TNUM_OBJ(list) == T_APOSOBJ ) \
        elm = ElmAList( list, pos ); \
    else { \
        elm = ELMW_LIST( list, pos ); \
    }

#define C_ASS_POSOBJ_INTOBJ( list, pos, elm ) \
    if ( TNUM_OBJ(list) == T_POSOBJ ) { \
        if ( SIZE_OBJ(list)/sizeof(Obj)-1 < pos ) { \
            ResizeBag( list, (pos+1)*sizeof(Obj) ); \
        } \
        SET_ELM_PLIST( list, pos, elm ); \
    } else if (TNUM_OBJ(list) == T_APOSOBJ) { \
    AssAList( list, pos, elm ); \
    } else { \
        ASS_LIST( list, pos, elm ); \
    }

#define C_ASS_POSOBJ( list, pos, elm ) \
    if ( TNUM_OBJ(list) == T_POSOBJ ) { \
        if ( SIZE_OBJ(list)/sizeof(Obj)-1 < pos ) { \
            ResizeBag( list, (pos+1)*sizeof(Obj) ); \
        } \
        SET_ELM_PLIST( list, pos, elm ); \
        CHANGED_BAG(list); \
    } else if (TNUM_OBJ(list) == T_APOSOBJ) { \
    AssAList( list, pos, elm ); \
    } else { \
        ASS_LIST( list, pos, elm ); \
    }



/* lists, should go into 'lists.c' * * * * * * * * * * * * * * * * * * * * */
#define C_LEN_LIST(len,list) \
 len = LENGTH(list);

#define C_LEN_LIST_FPL(len,list) \
 if ( IS_PLIST(list) ) { \
  len = INTOBJ_INT( LEN_PLIST(list) ); \
 } \
 else { \
  len = LENGTH(list); \
 }




#define C_ELM_LIST(elm,list,p) \
 elm = IS_POS_INTOBJ(p) ? ELM_LIST( list, INT_INTOBJ(p) ) : ELMB_LIST(list, p);

#define C_ELM_LIST_NLE(elm,list,p) \
 elm = IS_POS_INTOBJ(p) ? ELMW_LIST( list, INT_INTOBJ(p) ) : ELMB_LIST(list, p);

#define C_ELM_LIST_FPL(elm,list,p) \
 if ( IS_POS_INTOBJ(p) && IS_PLIST(list) ) { \
  if ( INT_INTOBJ(p) <= LEN_PLIST(list) ) { \
   elm = ELM_PLIST( list, INT_INTOBJ(p) ); \
   if ( elm == 0 ) elm = ELM_LIST( list, INT_INTOBJ(p) ); \
  } else elm = ELM_LIST( list, INT_INTOBJ(p) ); \
 } else C_ELM_LIST( elm, list, p )

#define C_ELM_LIST_NLE_FPL(elm,list,p) \
 if ( IS_POS_INTOBJ(p) && IS_PLIST(list) ) { \
  elm = ELM_PLIST( list, INT_INTOBJ(p) ); \
 } else C_ELM_LIST_NLE(elm, list, p)

#define C_ASS_LIST(list,p,rhs) \
  if (IS_POS_INTOBJ(p)) ASS_LIST( list, INT_INTOBJ(p), rhs ); \
  else ASSB_LIST(list, p, rhs);

#define C_ASS_LIST_FPL(list,p,rhs) \
 if ( IS_POS_INTOBJ(p) && TNUM_OBJ(list) == T_PLIST ) { \
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
 if ( IS_POS_INTOBJ(p) && TNUM_OBJ(list) == T_PLIST) { \
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
  ((IS_POS_INTOBJ(pos) ? ISB_LIST(list, INT_INTOBJ(pos)) : ISBB_LIST( list, pos)) ? True : False)

#define C_UNB_LIST( list, pos) \
   if (IS_POS_INTOBJ(pos)) UNB_LIST(list, INT_INTOBJ(pos)); else UNBB_LIST(list, pos);

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



/* More or less all of this will get inlined away */

/* Allocate a bag suitable for a size-byte integer of type type. 
   The allocation may need to be bigger than size bytes 
   due to limb size or other aspects of the representation */

static inline  Obj C_MAKE_INTEGER_BAG( UInt size, UInt type)  {
  /* Round size up to nearest multiple of INTEGER_ALLOCATION_SIZE */
  return NewBag(type,INTEGER_ALLOCATION_SIZE*
		((size + INTEGER_ALLOCATION_SIZE-1)/INTEGER_ALLOCATION_SIZE));
}


/* Set 2 bytes of data in an integer */

static inline void C_SET_LIMB2(Obj bag, UInt limbnumber, UInt2 value)  {

#if INTEGER_UNIT_SIZE == 2
  ((UInt2 *)ADDR_OBJ(bag))[limbnumber] = value;
#elif INTEGER_UNIT_SIZE == 4
  UInt4 *p;
  if (limbnumber % 2) {
    p = ((UInt4 *)ADDR_OBJ(bag)) + (limbnumber-1) / 2;
    *p = (*p & 0xFFFFUL) | ((UInt4)value << 16);
  } else {
    p = ((UInt4 *)ADDR_OBJ(bag)) + limbnumber / 2;
    *p = (*p & 0xFFFF0000UL) | (UInt4)value;
  }
#else
  UInt8 *p;
    p  = ((UInt8 *)ADDR_OBJ(bag)) + limbnumber/4;
    switch(limbnumber % 4) {
    case 0: 
      *p = (*p & 0xFFFFFFFFFFFF0000UL) | (UInt8)value;
      break;
    case 1:
      *p = (*p & 0xFFFFFFFF0000FFFFUL) | ((UInt8)value << 16);
      break;
    case 2:
      *p = (*p & 0xFFFF0000FFFFFFFFUL) | ((UInt8)value << 32);
      break;
    case 3:
      *p = (*p & 0x0000FFFFFFFFFFFFUL) | ((UInt8)value << 48);
      break;
    }
#endif  
}

static inline void C_SET_LIMB4(Obj bag, UInt limbnumber, UInt4 value)  {

#if INTEGER_UNIT_SIZE == 4
  ((UInt4 *)ADDR_OBJ(bag))[limbnumber] = value;
#elif INTEGER_UNIT_SIZE == 8
  UInt8 *p;
  if (limbnumber % 2) {
    p = ((UInt8*)ADDR_OBJ(bag)) + (limbnumber-1) / 2;
    *p = (*p & 0xFFFFFFFFUL) | ((UInt8)value << 32);
  } else {
    p = ((UInt8 *)ADDR_OBJ(bag)) + limbnumber / 2;
    *p = (*p & 0xFFFFFFFF00000000UL) | (UInt8)value;
  }
#else
  ((UInt2 *)ADDR_OBJ(bag))[2*limbnumber] = (UInt2)(value & 0xFFFFUL);
  ((UInt2 *)ADDR_OBJ(bag))[2*limbnumber+1] = (UInt2)(value >>16);
#endif  
}



static inline void C_SET_LIMB8(Obj bag, UInt limbnumber, UInt8 value)  { 
#if INTEGER_UNIT_SIZE == 8
  ((UInt8 *)ADDR_OBJ(bag))[limbnumber] = value;
#elif INTEGER_UNIT_SIZE == 4
  ((UInt4 *)ADDR_OBJ(bag))[2*limbnumber] = (UInt4)(value & 0xFFFFFFFFUL);
  ((UInt4 *)ADDR_OBJ(bag))[2*limbnumber+1] = (UInt4)(value >>32);
#else
  ((UInt2 *)ADDR_OBJ(bag))[4*limbnumber] = (UInt2)(value & 0xFFFFULL);
  ((UInt2 *)ADDR_OBJ(bag))[4*limbnumber+1] = (UInt2)((value & 0xFFFF0000ULL) >>16);
  ((UInt2 *)ADDR_OBJ(bag))[4*limbnumber+2] = (UInt2)((value & 0xFFFF00000000ULL) >>32);
  ((UInt2 *)ADDR_OBJ(bag))[4*limbnumber+3] = (UInt2)(value >>48);
#endif
}

/* C_MAKE_MED_INT handles numbers between 2^28 and 2^60 in magnitude,
   and is used in code compiled on 64 bit systems. If the target system
   is 64 bit an immediate integer is constructed. If the target is 32 bits then
   an 8-byte large integer is constructed using the representation-neutral 
   macros above 

   C_NORMALIZE_64BIT is called when a large integer has been
   constructed (because the literal was large on the compiling system)
   and might be small on the target system. */

 
#ifdef SYS_IS_64_BIT 
static inline Obj C_MAKE_MED_INT( Int8 value ) {
  return INTOBJ_INT(value);
}

static inline Obj C_NORMALIZE_64BIT(Obj o) {
  Int value =  *(Int *)ADDR_OBJ(o);
  if (value < 0)
    return o;
  if (TNUM_OBJ(o) == T_INTNEG)
    value = -value;
  if (-(1L << 60) <= value && value < (1L << 60))
    return INTOBJ_INT(value);
  else
    return o;    
}


#else
static inline Obj C_MAKE_MED_INT( Int8 value ) {
  Obj x;
  UInt type;
  if (value < 0) {
    type = T_INTNEG;
    value = -value;
  } else
    type = T_INTPOS;

  x = C_MAKE_INTEGER_BAG(8,type);
  C_SET_LIMB8(x,0,(UInt8)value);
  return x;
}

static inline Obj C_NORMALIZE_64BIT( Obj o) {
  return o;
}

#endif

#ifdef __cplusplus
}
#undef GAP_IN_EXTERN_C
#endif
    
#endif // GAP_COMPILED_H

/****************************************************************************
**
*E  compiled.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
