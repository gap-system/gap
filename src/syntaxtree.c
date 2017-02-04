/****************************************************************************
**
*W  syntaxtree.c
**
*/
#include        <stdarg.h>              /* variable argument list macros   */
#include        "system.h"              /* Ints, UInts                     */


#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gvars.h"               /* global variables                */

#include        "ariths.h"              /* basic arithmetic                */
#include        "integer.h"

#include        "bool.h"                /* booleans                        */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "calls.h"               /* generic call mechanism          */
/*N 1996/06/16 mschoene func expressions should be different from funcs    */

#include        "lists.h"               /* generic lists                   */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "plist.h"               /* plain lists                     */

#include        "stringobj.h"              /* strings                         */

#include        "code.h"                /* coder                           */

#include        "exprs.h"               /* expressions                     */
#include        "stats.h"               /* statements                      */

#include        "compiler.h"            /* compiler                        */

#include        "hpc/tls.h"             /* thread-local storage            */

#include        "vars.h"                /* variables                       */


/****************************************************************************
**

*F * * * * * * * * * * * * * compilation flags  * * * * * * * * * * * * * * *
*/

#if 0
/****************************************************************************
**


*V  SyntaxTreeFastIntArith  . . option to emit code that handles small ints. faster
*/
Int SyntaxTreeFastIntArith;


/****************************************************************************
**
*V  SyntaxTreeFastPlainLists  . option to emit code that handles plain lists faster
*/
Int SyntaxTreeFastPlainLists ;


/****************************************************************************
**
*V  SyntaxTreeFastListFuncs . . option to emit code that inlines calls to functions
*/
Int SyntaxTreeFastListFuncs;


/****************************************************************************
**
*V  SyntaxTreeCheckTypes  . . . . option to emit code that assumes all types are ok.
*/
Int SyntaxTreeCheckTypes ;


/****************************************************************************
**
*V  SyntaxTreeCheckListElements .  option to emit code that assumes list elms exist
*/
Int SyntaxTreeCheckListElements;

/****************************************************************************
**
*V  SyntaxTreeOptNames . .  names for all the compiler options passed by gac
**
*/

struct SyntaxTreeOptStruc { const Char *extname;
  Int *variable;
  Int val;};

struct SyntaxTreeOptStruc CompOptNames[] = {
  { "FAST_INT_ARITH", &SyntaxTreeFastIntArith, 1 },
  { "FAST_PLAIN_LISTS", &SyntaxTreeFastPlainLists, 1 },
  { "FAST_LIST_FUNCS", &SyntaxTreeFastListFuncs, 1 },
  { "NO_CHECK_TYPES", &SyntaxTreeCheckTypes, 0 },
  { "NO_CHECK_LIST_ELMS", &SyntaxTreeCheckListElements, 0 }};

#define N_SyntaxTreeOpts  (sizeof(CompOptNames)/sizeof(struct CompOptStruc))


/****************************************************************************
**
*F  SetSyntaxTreeileOpts( <string> ) . . parse the compiler options from <string>
**                                 and set the appropriate variables
**                                 unrecognised options are ignored for now
*/
#include <ctype.h>


/****************************************************************************
**
*T  CVar  . . . . . . . . . . . . . . . . . . . . . . .  type for C variables
**
**  A C variable represents the result of compiling an expression.  There are
**  three cases (distinguished by the least significant two bits).
**
**  If the  expression is an  immediate integer  expression, the  C  variable
**  contains the value of the immediate integer expression.
**
**  If the  expression is an immediate reference  to a  local variable, the C
**  variable contains the index of the local variable.
**
**  Otherwise the expression  compiler emits code  that puts the value of the
**  expression into a  temporary variable,  and  the C variable contains  the
**  index of that temporary variable.
*/
typedef UInt           CVar;

#define IS_INTG_CVAR(c) ((((UInt)(c)) & 0x03) == 0x01)
#define INTG_CVAR(c)    (((Int)(c)) >> 2)
#define CVAR_INTG(i)    ((((UInt)(i)) << 2) + 0x01)

#define IS_TEMP_CVAR(c) ((((UInt)(c)) & 0x03) == 0x02)
#define TEMP_CVAR(c)    (((UInt)(c)) >> 2)
#define CVAR_TEMP(l)    ((((UInt)(l)) << 2) + 0x02)

#define IS_LVAR_CVAR(c) ((((UInt)(c)) & 0x03) == 0x03)
#define LVAR_CVAR(c)    (((UInt)(c)) >> 2)
#define CVAR_LVAR(l)    ((((UInt)(l)) << 2) + 0x03)


/****************************************************************************
**
*F  SetInfoCVar( <cvar>, <type> ) . . . . . . .  set the type of a C variable
*F  GetInfoCVar( <cvar> ) . . . . . . . . . . .  get the type of a C variable
*F  HasInfoCVar( <cvar>, <type> ) . . . . . . . test the type of a C variable
**
*F  NewInfoCVars()  . . . . . . . . . allocate a new info bag for C variables
*F  CopyInfoCVars( <dst>, <src> ) . .  copy between info bags for C variables
*F  MergeInfoCVars( <dst>, <src> )  . . . merge two info bags for C variables
*F  IsEqInfoCVars( <dst>, <src> ) . . . compare two info bags for C variables
**
**  With each function we  associate a C  variables information bag.  In this
**  bag we store  the number of the  function, the number of local variables,
**  the  number of local  variables that  are used  as higher variables,  the
**  number  of temporaries  used,  the number of  loop  variables needed, the
**  current  number  of used temporaries.
**
**  Furthermore for  each local variable and  temporary we store what we know
**  about this local variable or temporary, i.e., whether the variable has an
**  assigned value, whether that value is an integer, a boolean, etc.
**
**  'SetInfoCVar' sets the    information   for  the  C variable      <cvar>.
**  'GetInfoCVar' gets   the   information  for   the  C    variable  <cvar>.
**  'HasInfoCVar' returns true if the C variable <cvar> has the type <type>.
**
**  'NewInfoCVars'  creates    a    new    C  variables     information  bag.
**  'CopyInfoCVars' copies the C  variables information from <src> to  <dst>.
**  'MergeInfoCVars' merges the C variables information  from <src> to <dst>,
**  i.e., if there are two paths to a  certain place in  the source and <dst>
**  is the information gathered  along one path  and <src> is the information
**  gathered along the other path, then  'MergeInfoCVars' stores in <dst> the
**  information for   that   point  (independent   of  the  path  travelled).
**  'IsEqInfoCVars' returns   true  if <src>    and <dst> contain   the  same
**  information.
**
**  Note that  the numeric  values for the  types  are defined such  that  if
**  <type1> implies <type2>, then <type1> is a bitwise superset of <type2>.
*/
typedef UInt4           LVar;

#define INFO_FEXP(fexp)         PROF_FUNC(fexp)
#define NEXT_INFO(info)         PTR_BAG(info)[0]
#define NR_INFO(info)           (*((Int*)(PTR_BAG(info)+1)))
#define NLVAR_INFO(info)        (*((Int*)(PTR_BAG(info)+2)))
#define NHVAR_INFO(info)        (*((Int*)(PTR_BAG(info)+3)))
#define NTEMP_INFO(info)        (*((Int*)(PTR_BAG(info)+4)))
#define NLOOP_INFO(info)        (*((Int*)(PTR_BAG(info)+5)))
#define CTEMP_INFO(info)        (*((Int*)(PTR_BAG(info)+6)))
#define TNUM_LVAR_INFO(info,i)  (*((Int*)(PTR_BAG(info)+7+(i))))

#define TNUM_TEMP_INFO(info,i)  \
    (*((Int*)(PTR_BAG(info)+7+NLVAR_INFO(info)+(i))))

#define SIZE_INFO(nlvar,ntemp)  (sizeof(Int) * (8 + (nlvar) + (ntemp)))

#define W_UNUSED                0       /* TEMP is currently unused        */
#define W_HIGHER                (1L<<0) /* LVAR is used as higher variable */
#define W_UNKNOWN               ((1L<<1) | W_HIGHER)
#define W_UNBOUND               ((1L<<2) | W_UNKNOWN)
#define W_BOUND                 ((1L<<3) | W_UNKNOWN)
#define W_INT                   ((1L<<4) | W_BOUND)
#define W_INT_SMALL             ((1L<<5) | W_INT)
#define W_INT_POS               ((1L<<6) | W_INT)
#define W_BOOL                  ((1L<<7) | W_BOUND)
#define W_FUNC                  ((1L<<8) | W_BOUND)
#define W_LIST                  ((1L<<9) | W_BOUND)

#define W_INT_SMALL_POS         (W_INT_SMALL | W_INT_POS)

void            SetInfoCVar (
    CVar                cvar,
    UInt                type )
{
    Bag                 info;           /* its info bag                    */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC );

    /* set the type of a temporary                                         */
    if ( IS_TEMP_CVAR(cvar) ) {
        TNUM_TEMP_INFO( info, TEMP_CVAR(cvar) ) = type;
    }

    /* set the type of a lvar (but do not change if its a higher variable) */
    else if ( IS_LVAR_CVAR(cvar)
           && TNUM_LVAR_INFO( info, LVAR_CVAR(cvar) ) != W_HIGHER ) {
        TNUM_LVAR_INFO( info, LVAR_CVAR(cvar) ) = type;
    }
}

Int             GetInfoCVar (
    CVar                cvar )
{
    Bag                 info;           /* its info bag                    */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC );

    /* get the type of an integer                                          */
    if ( IS_INTG_CVAR(cvar) ) {
        return ((0 < INTG_CVAR(cvar)) ? W_INT_SMALL_POS : W_INT_SMALL);
    }

    /* get the type of a temporary                                         */
    else if ( IS_TEMP_CVAR(cvar) ) {
        return TNUM_TEMP_INFO( info, TEMP_CVAR(cvar) );
    }

    /* get the type of a lvar                                              */
    else if ( IS_LVAR_CVAR(cvar) ) {
        return TNUM_LVAR_INFO( info, LVAR_CVAR(cvar) );
    }

    /* hmm, avoid warning by compiler                                      */
    else {
        return 0;
    }
}

Int             HasInfoCVar (
    CVar                cvar,
    Int                 type )
{
    return ((GetInfoCVar( cvar ) & type) == type);
}


Bag             NewInfoCVars ( void )
{
    Bag                 old;
    Bag                 new;
    old = INFO_FEXP( CURR_FUNC );
    new = NewBag( TNUM_BAG(old), SIZE_BAG(old) );
    return new;
}

void            CopyInfoCVars (
    Bag                 dst,
    Bag                 src )
{
    Int                 i;
    if ( SIZE_BAG(dst) < SIZE_BAG(src) )  ResizeBag( dst, SIZE_BAG(src) );
    if ( SIZE_BAG(src) < SIZE_BAG(dst) )  ResizeBag( src, SIZE_BAG(dst) );
    NR_INFO(dst)    = NR_INFO(src);
    NLVAR_INFO(dst) = NLVAR_INFO(src);
    NHVAR_INFO(dst) = NHVAR_INFO(src);
    NTEMP_INFO(dst) = NTEMP_INFO(src);
    NLOOP_INFO(dst) = NLOOP_INFO(src);
    CTEMP_INFO(dst) = CTEMP_INFO(src);
    for ( i = 1; i <= NLVAR_INFO(src); i++ ) {
        TNUM_LVAR_INFO(dst,i) = TNUM_LVAR_INFO(src,i);
    }
    for ( i = 1; i <= NTEMP_INFO(dst) && i <= NTEMP_INFO(src); i++ ) {
        TNUM_TEMP_INFO(dst,i) = TNUM_TEMP_INFO(src,i);
    }
}

void            MergeInfoCVars (
    Bag                 dst,
    Bag                 src )
{
    Int                 i;
    if ( SIZE_BAG(dst) < SIZE_BAG(src) )  ResizeBag( dst, SIZE_BAG(src) );
    if ( SIZE_BAG(src) < SIZE_BAG(dst) )  ResizeBag( src, SIZE_BAG(dst) );
    if ( NTEMP_INFO(dst)<NTEMP_INFO(src) )  NTEMP_INFO(dst)=NTEMP_INFO(src);
    for ( i = 1; i <= NLVAR_INFO(src); i++ ) {
        TNUM_LVAR_INFO(dst,i) &= TNUM_LVAR_INFO(src,i);
    }
    for ( i = 1; i <= NTEMP_INFO(dst) && i <= NTEMP_INFO(src); i++ ) {
        TNUM_TEMP_INFO(dst,i) &= TNUM_TEMP_INFO(src,i);
    }
}

Int             IsEqInfoCVars (
    Bag                 dst,
    Bag                 src )
{
    Int                 i;
    if ( SIZE_BAG(dst) < SIZE_BAG(src) )  ResizeBag( dst, SIZE_BAG(src) );
    if ( SIZE_BAG(src) < SIZE_BAG(dst) )  ResizeBag( src, SIZE_BAG(dst) );
    for ( i = 1; i <= NLVAR_INFO(src); i++ ) {
        if ( TNUM_LVAR_INFO(dst,i) != TNUM_LVAR_INFO(src,i) ) {
            return 0;
        }
    }
    for ( i = 1; i <= NTEMP_INFO(dst) && i <= NTEMP_INFO(src); i++ ) {
        if ( TNUM_TEMP_INFO(dst,i) != TNUM_TEMP_INFO(src,i) ) {
            return 0;
        }
    }
    return 1;
}


/****************************************************************************
**
*F  NewTemp( <name> ) . . . . . . . . . . . . . . .  allocate a new temporary
*F  FreeTemp( <temp> )  . . . . . . . . . . . . . . . . . .  free a temporary
**
**  'NewTemp' allocates  a  new  temporary   variable (<name>  is   currently
**  ignored).
**
**  'FreeTemp' frees the temporary <temp>.
**
**  Currently  allocations and deallocations   of  temporaries are done  in a
**  strict nested (laff -- last allocated, first freed) order.  This means we
**  do not have to search for unused temporaries.
*/
typedef UInt4           Temp;

Temp            NewTemp (
    const Char *        name )
{
    Temp                temp;           /* new temporary, result           */
    Bag                 info;           /* information bag                 */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC );

    /* take the next available temporary                                   */
    CTEMP_INFO( info )++;
    temp = CTEMP_INFO( info );

    /* maybe make room for more temporaries                                */
    if ( NTEMP_INFO( info ) < temp ) {
        if ( SIZE_BAG(info) < SIZE_INFO( NLVAR_INFO(info), temp ) ) {
            ResizeBag( info, SIZE_INFO( NLVAR_INFO(info), temp+7 ) );
        }
        NTEMP_INFO( info ) = temp;
    }
    TNUM_TEMP_INFO( info, temp ) = W_UNKNOWN;

    /* return the temporary                                                */
    return temp;
}

void            FreeTemp (
    Temp                temp )
{
    Bag                 info;           /* information bag                 */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC );

    /* check that deallocations happens in the correct order               */
    if ( temp != CTEMP_INFO( info ) && SyntaxTreePass == 2 ) {
        Pr("PROBLEM: freeing t_%d, should be t_%d\n",(Int)temp,CTEMP_INFO(info));
    }

    /* free the temporary                                                  */
    TNUM_TEMP_INFO( info, temp ) = W_UNUSED;
    CTEMP_INFO( info )--;
}


/****************************************************************************
**
*F  SyntaxTreeSetUseHVar( <hvar> )  . . . . . . . . register use of higher variable
*F  SyntaxTreeGetUseHVar( <hvar> )  . . . . . . . . get use mode of higher variable
*F  GetLevlHVar( <hvar> ) . . . . . . . . . . .  get level of higher variable
*F  GetIndxHVar( <hvar> ) . . . . . . . . . . .  get index of higher variable
**
**  'SyntaxTreeSetUseHVar'  register (during pass 1)   that the variable <hvar>  is
**  used  as   higher  variable, i.e.,  is  referenced   from inside  a local
**  function.  Such variables  must be allocated  in  a stack frame  bag (and
**  cannot be mapped to C variables).
**
**  'SyntaxTreeGetUseHVar' returns nonzero if the variable <hvar> is used as higher
**  variable.
**
**  'GetLevlHVar' returns the level of the  higher variable <hvar>, i.e., the
**  number of  frames  that must be  walked upwards   for the  one containing
**  <hvar>.  This may be properly  smaller than 'LEVEL_HVAR(<hvar>)', because
**  only those compiled functions that have local variables  that are used as
**  higher variables allocate a stack frame.
**
**  'GetIndxHVar' returns the index of the higher  variable <hvar>, i.e., the
**  position of <hvar> in the stack frame.  This may be properly smaller than
**  'INDEX_HVAR(<hvar>)', because only those  local variable that are used as
**  higher variables are allocated in a stack frame.
*/
typedef UInt4           HVar;

void            SyntaxTreeSetUseHVar (
    HVar                hvar )
{
    Bag                 info;           /* its info bag                    */
    Int                 i;              /* loop variable                   */

    /* only mark in pass 1                                                 */
    if ( SyntaxTreePass != 1 )  return;

    /* walk up                                                             */
    info = INFO_FEXP( CURR_FUNC );
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        info = NEXT_INFO( info );
    }

    /* set mark                                                            */
    if ( TNUM_LVAR_INFO( info, (hvar & 0xFFFF) ) != W_HIGHER ) {
        TNUM_LVAR_INFO( info, (hvar & 0xFFFF) ) = W_HIGHER;
        NHVAR_INFO(info) = NHVAR_INFO(info) + 1;
    }

}

Int             SyntaxTreeGetUseHVar (
    HVar                hvar )
{
    Bag                 info;           /* its info bag                    */
    Int                 i;              /* loop variable                   */

    /* walk up                                                             */
    info = INFO_FEXP( CURR_FUNC );
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        info = NEXT_INFO( info );
    }

    /* get mark                                                            */
    return (TNUM_LVAR_INFO( info, (hvar & 0xFFFF) ) == W_HIGHER);
}

UInt            GetLevlHVar (
    HVar                hvar )
{
    UInt                levl;           /* level of higher variable        */
    Bag                 info;           /* its info bag                    */
    Int                 i;              /* loop variable                   */

    /* walk up                                                             */
    levl = 0;
    info = INFO_FEXP( CURR_FUNC );
#if 0
    if ( NHVAR_INFO(info) != 0 ) 
#endif
      levl++;
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        info = NEXT_INFO( info );
#if 0
        if ( NHVAR_INFO(info) != 0 ) 
#endif
          levl++;
    }

    /* return level (the number steps to go up)                            */
    return levl - 1;
}

UInt            GetIndxHVar (
    HVar                hvar )
{
    UInt                indx;           /* index of higher variable        */
    Bag                 info;           /* its info bag                    */
    Int                 i;              /* loop variable                   */

    /* walk up                                                             */
    info = INFO_FEXP( CURR_FUNC );
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        info = NEXT_INFO( info );
    }

    /* walk right                                                          */
    indx = 0;
    for ( i = 1; i <= (hvar & 0xFFFF); i++ ) {
        if ( TNUM_LVAR_INFO( info, i ) == W_HIGHER )  indx++;
    }

    /* return the index                                                    */
    return indx;
}


/****************************************************************************
**
*F  SyntaxTreeSetUseGVar( <gvar>, <mode> )  . . . . register use of global variable
*F  SyntaxTreeGetUseGVar( <gvar> )  . . . . . . . . get use mode of global variable
**
**  'SyntaxTreeSetUseGVar' registers (during pass 1) the use of the global variable
**  with identifier <gvar>.
**
**  'SyntaxTreeGetUseGVar'  returns the bitwise OR  of all the <mode> arguments for
**  the global variable with identifier <gvar>.
**
**  Currently the interpretation of the <mode> argument is as follows
**
**  If '<mode> &  COMP_USE_GVAR_ID' is nonzero, then  the produced code shall
**  define  and initialize 'G_<name>'    with  the identifier of  the  global
**  variable (which may  be different from  <gvar>  by the time the  compiled
**  code is actually run).
**
**  If '<mode> & COMP_USE_GVAR_COPY' is nonzero, then the produced code shall
**  define  and initialize 'GC_<name>' as a  copy of  the global variable
**  (see 'InitCopyGVar' in 'gvars.h').
**
**  If '<mode> & COMP_USE_GVAR_FOPY' is nonzero, then the produced code shall
**  define and  initialize  'GF_<name>' as   a  function copy  of the  global
**  variable (see 'InitFopyGVar' in 'gvars.h').
*/
typedef UInt    GVar;

#define COMP_USE_GVAR_ID        (1L << 0)
#define COMP_USE_GVAR_COPY      (1L << 1)
#define COMP_USE_GVAR_FOPY      (1L << 2)

Bag             SyntaxTreeInfoGVar;

void            SyntaxTreeSetUseGVar (
    GVar                gvar,
    UInt                mode )
{
    /* only mark in pass 1                                                 */
    if ( SyntaxTreePass != 1 )  return;

    /* resize if neccessary                                                */
    if ( SIZE_OBJ(SyntaxTreeInfoGVar)/sizeof(UInt) <= gvar ) {
        ResizeBag( SyntaxTreeInfoGVar, sizeof(UInt)*(gvar+1) );
    }

    /* or with <mode>                                                      */
    ((UInt*)PTR_BAG(SyntaxTreeInfoGVar))[gvar] |= mode;
}

UInt            SyntaxTreeGetUseGVar (
    GVar                gvar )
{
    return ((UInt*)PTR_BAG(SyntaxTreeInfoGVar))[gvar];
}


/****************************************************************************
**
*F  SyntaxTreeSetUseRNam( <rnam>, <mode> )  . . . . . . register use of record name
*F  SyntaxTreeGetUseRNam( <rnam> )  . . . . . . . . . . get use mode of record name
**
**  'SyntaxTreeSetUseRNam' registers  (during pass  1) the use   of the record name
**  with identifier <rnam>.  'SyntaxTreeGetUseRNam'  returns the bitwise OR  of all
**  the <mode> arguments for the global variable with identifier <rnam>.
**
**  Currently the interpretation of the <mode> argument is as follows
**
**  If '<mode> & COMP_USE_RNAM_ID'  is nonzero, then  the produced code shall
**  define and initialize  'R_<name>' with the  identifier of the record name
**  (which may be  different from <rnam> when the  time the  compiled code is
**  actually run).
*/
typedef UInt    RNam;

#define COMP_USE_RNAM_ID        (1L << 0)

Bag             SyntaxTreeInfoRNam;

void            SyntaxTreeSetUseRNam (
    RNam                rnam,
    UInt                mode )
{
    /* only mark in pass 1                                                 */
    if ( SyntaxTreePass != 1 )  return;

    /* resize if neccessary                                                */
    if ( SIZE_OBJ(SyntaxTreeInfoRNam)/sizeof(UInt) <= rnam ) {
        ResizeBag( SyntaxTreeInfoRNam, sizeof(UInt)*(rnam+1) );
    }

    /* or with <mode>                                                      */
    ((UInt*)PTR_BAG(SyntaxTreeInfoRNam))[rnam] |= mode;
}

UInt            SyntaxTreeGetUseRNam (
    RNam                rnam )
{
    return ((UInt*)PTR_BAG(SyntaxTreeInfoRNam))[rnam];
}


/****************************************************************************
**
*F  SyntaxTreeCheckBound( <obj>, <name> ) emit code to check that <obj> has a value
*/
void SyntaxTreeCheckBound (
    CVar                obj,
    Char *              name )
{
    if ( ! HasInfoCVar( obj, W_BOUND ) ) {
        if ( SyntaxTreeCheckTypes ) {
            Emit( "CHECK_BOUND( %c, \"%s\" )\n", obj, name );
        }
        SetInfoCVar( obj, W_BOUND );
    }
}


/****************************************************************************
**
*F  SyntaxTreeCheckFuncResult( <obj> )  . emit code to check that <obj> has a value
*/
void SyntaxTreeCheckFuncResult (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_BOUND ) ) {
        if ( SyntaxTreeCheckTypes ) {
            Emit( "CHECK_FUNC_RESULT( %c )\n", obj );
        }
        SetInfoCVar( obj, W_BOUND );
    }
}


/****************************************************************************
**
*F  SyntaxTreeCheckIntSmall( <obj> )   emit code to check that <obj> is a small int
*/
void SyntaxTreeCheckIntSmall (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_INT_SMALL ) ) {
        if ( SyntaxTreeCheckTypes ) {
            Emit( "CHECK_INT_SMALL( %c )\n", obj );
        }
        SetInfoCVar( obj, W_INT_SMALL );
    }
}



/****************************************************************************
**
*F  SyntaxTreeCheckIntSmallPos( <obj> ) emit code to check that <obj> is a position
*/
void SyntaxTreeCheckIntSmallPos (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_INT_SMALL_POS ) ) {
        if ( SyntaxTreeCheckTypes ) {
            Emit( "CHECK_INT_SMALL_POS( %c )\n", obj );
        }
        SetInfoCVar( obj, W_INT_SMALL_POS );
    }
}

/****************************************************************************
**
*F  SyntaxTreeCheckIntPos( <obj> ) emit code to check that <obj> is a position
*/
void SyntaxTreeCheckIntPos (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_INT_POS ) ) {
        if ( SyntaxTreeCheckTypes ) {
            Emit( "CHECK_INT_POS( %c )\n", obj );
        }
        SetInfoCVar( obj, W_INT_POS );
    }
}


/****************************************************************************
**
*F  SyntaxTreeCheckBool( <obj> )  . . .  emit code to check that <obj> is a boolean
*/
void SyntaxTreeCheckBool (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_BOOL ) ) {
        if ( SyntaxTreeCheckTypes ) {
            Emit( "CHECK_BOOL( %c )\n", obj );
        }
        SetInfoCVar( obj, W_BOOL );
    }
}



/****************************************************************************
**
*F  SyntaxTreeCheckFunc( <obj> )  . . . emit code to check that <obj> is a function
*/
void SyntaxTreeCheckFunc (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_FUNC ) ) {
        if ( SyntaxTreeCheckTypes ) {
            Emit( "CHECK_FUNC( %c )\n", obj );
        }
        SetInfoCVar( obj, W_FUNC );
    }
}


/****************************************************************************
**

*F * * * * * * * * * * * *  compile expressions * * * * * * * * * * * * * * *
*/

static inline Obj NewSyntaxTreeNode(const char *type, Int size)
{
    Obj result;
    Obj typestr;

    C_NEW_STRING_CONST(typestr, type);
    result = NEW_PREC(size);
    AssPrec(RNamName("type"), typestr);
    return result;
}


/****************************************************************************
**

*F  SyntaxTreeExpr( <expr> )  . . . . . . . . . . . . . . . . compile an expression
**
**  'SyntaxTreeExpr' compiles the expression <expr> and returns the C variable that
**  will contain the result.
*/
Obj (* SyntaxTreeExprFuncs[256]) ( Expr expr );


Obj SyntaxTreeExpr(Expr expr)
{
    return (* SyntaxTreeExprFuncs[ TNUM_EXPR(expr) ])( expr );
}


/****************************************************************************
**
*F  SyntaxTreeUnknownExpr( <expr> ) . . . . . . . . . . . .  log unknown expression
*/
Obj SyntaxTreeUnknownExpr(Expr expr)
{
    return Fail;
}


/****************************************************************************
**
*F  SyntaxTreeBoolExpr( <expr> )  . . . . . . . compile bool expr and return C bool
*/
Obj (* SyntaxTreeBoolExprFuncs[256]) ( Expr expr );

Obj SyntaxTreeBoolExpr(Expr expr)
{
    return (* SyntaxTreeBoolExprFuncs[ TNUM_EXPR(expr) ])( expr );
}

/****************************************************************************
**
*F  SyntaxTreeUnknownBool( <expr> ) . . . . . . . . . .  use 'CompExpr' and convert
*/
Obj SyntaxTreeUnknownBool(Expr expr)
{
    /* compile the expression and check that the value is boolean          */
    /* TODO: Check boolean? */
    return SyntaxTreeExpr( expr );
}

/****************************************************************************
**
*F  SyntaxTreeFunccall0to6Args( <expr> )  . . . T_FUNCCALL_0ARGS...T_FUNCCALL_6ARGS
*/
extern CVar SyntaxTreeRefGVarFopy (Expr expr);

/****************************************************************************
**
*F  SyntaxTreeFunccallXArgs( <expr> ) . . . . . . . . . . . . . .  T_FUNCCALL_XARGS
*/
CVar SyntaxTreeFunccall(Expr expr)
{
    Obj result;
    Obj funcl

    CVar                argl;           /* argument list                   */
    CVar                argi;           /* <i>-th argument                 */
    UInt                narg;           /* number of arguments             */
    UInt                i;              /* loop variable                   */

    result = NewSyntaxTreeNode("funccall", 5);

    /* compile the reference to the function                               */
    if ( TNUM_EXPR( FUNC_CALL(expr) ) == T_REF_GVAR ) {
        func = SyntaxTreeRefGVarFopy( FUNC_CALL(expr) );
    }
    else {
        func = SyntaxTreeExpr( FUNC_CALL(expr) );
        //    SyntaxTreeCheckFunc( func );
    }
    AssPrec(result, RNamName("function"), func);

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_EXPR(expr));
    args = NEW_PLIST( T_LIST, narg);
    SET_LEN_PLIST(args, narg);

    for ( i = 1; i <= narg; i++ ) {
        argi = SyntaxTreeExpr( ARGI_CALL( expr, i ) );
        SET_ELM_PLIST(args, i, argi);
    }
    AssPRec(result, RNamName("args"), args);
    return result;
}

/****************************************************************************
**
*F  SyntaxTreeFunccallXArgs( <expr> ) . . . . . . . . . . . . . .  T_FUNCCALL_OPTS
*/
CVar SyntaxTreeFunccallOpts(Expr expr)
{
    return Fail;
    /*
  CVar opts = SyntaxTreeExpr(ADDR_STAT(expr)[0]);
  GVar pushOptions;
  GVar popOptions;
  CVar result;
  pushOptions = GVarName("PushOptions");
  popOptions = GVarName("PopOptions");
  SyntaxTreeSetUseGVar(pushOptions, COMP_USE_GVAR_FOPY);
  SyntaxTreeSetUseGVar(popOptions, COMP_USE_GVAR_FOPY);
  Emit("CALL_1ARGS( GF_PushOptions, %c );\n", opts);
  if (IS_TEMP_CVAR( opts) ) FreeTemp( TEMP_CVAR( opts ));
  result = SyntaxTreeExpr(ADDR_STAT(expr)[1]);
  Emit("CALL_0ARGS( GF_PopOptions );\n");
  return result; */
}
     

/****************************************************************************
**
*F  SyntaxTreeFuncExpr( <expr> )  . . . . . . . . . . . . . . . . . . . T_FUNC_EXPR
*/
CVar SyntaxTreeFuncExpr(Expr expr)
{
    Obj result;

    CVar                func;           /* function, result                */
    CVar                tmp;            /* dummy body                      */

    Obj                 fexs;           /* function expressions list       */
    Obj                 fexp;           /* function expression             */
    Int                 nr;             /* number of the function          */

    result = NewSyntaxTreeNode("funcexpr", 1);

    /*
    AssPRec(result, RNamName("narg"), );
    AssPRec(result, RNamName("body"), );
    */
    return result;

    #if 0
    /* get the number of the function                                      */
    fexs = FEXS_FUNC( CURR_FUNC );
    fexp = ELM_PLIST( fexs, ((Int*)ADDR_EXPR(expr))[0] );
    nr   = NR_INFO( INFO_FEXP( fexp ) );

    /* allocate a new temporary for the function                           */
    func = CVAR_TEMP( NewTemp( "func" ) );

    /* make the function (all the pieces are in global variables)          */
    Emit( "%c = NewFunction( NameFunc[%d], NargFunc[%d], NamsFunc[%d]",
          func, nr, nr, nr );
    Emit( ", HdlrFunc%d );\n", nr );

    /* this should probably be done by 'NewFunction'                       */
    Emit( "ENVI_FUNC( %c ) = TLS(CurrLVars);\n", func );
    tmp = CVAR_TEMP( NewTemp( "body" ) );
    Emit( "%c = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );\n", tmp );
    Emit( "SET_STARTLINE_BODY(%c, INTOBJ_INT(%d));\n", tmp, INT_INTOBJ(GET_STARTLINE_BODY(BODY_FUNC(fexp))));
    Emit( "SET_ENDLINE_BODY(%c, INTOBJ_INT(%d));\n", tmp, INT_INTOBJ(GET_ENDLINE_BODY(BODY_FUNC(fexp))));
    Emit( "SET_FILENAME_BODY(%c, FileName);\n",tmp);
    Emit( "BODY_FUNC(%c) = %c;\n", func, tmp );
    FreeTemp( TEMP_CVAR( tmp ) );

    Emit( "CHANGED_BAG( TLS(CurrLVars) );\n" );

    /* we know that the result is a function                               */
    SetInfoCVar( func, W_FUNC );

    /* return the number of the C variable that will hold the function     */
    return func;
    #endif
}


/****************************************************************************
**
*F  SyntaxTreeOr( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  T_OR
*/
Obj SyntaxTreeOr(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("or", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeBoolExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"), SyntaxTreeBoolExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeAnd(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("and",3);

    AssPRec(result, "left", SyntaxTreeExpr(ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr(ADDR_EXPR(expr)[0]));

    return result;
}

Obj SyntaxTreeNot(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("not", 2);
    AssPRec(result, "op", SynaxTreeBoolExpr( ADDR_EXPR(expr)[0]));

    return result;
}

Obj SyntaxTreeEq(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("eq", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"),SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeNe(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("neq", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, RNamName("right"),SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return val;
}

Obj SyntaxTreeLt(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("lt", 3);

    AssPRec(result, RNamName("left"), SyntaxTreeExpr( ADDR_EXPR(expr)[0] ) );
    AssPRec(result, RNamName("right"),  SyntaxTreeExpr( ADDR_EXPR(expr)[1] ) );

    return result;
}

Obj SyntaxTreeGe(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("ge", 3);

    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeGt(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("gt", 3);

    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeLe(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("le", 3);

    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeIn(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("in", 3);

    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeSum(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("sum", 3);

    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeAInv(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("ainv", 2);
    AssPRec(result, "op", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeDiff(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("diff", 3);
    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeProd(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("prod", 3);

    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeInv(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("inv", 3);

    AssPRec(result, "op", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));

    return result;
}

Obj SyntaxTreeQuo(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("quot", 3);

    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreeMod(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("mod", 3);

    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

Obj SyntaxTreePow(Expr expr)
{
    Obj result;

    result = NewSyntaxTreeNode("mod", 3);

    AssPRec(result, "left", SyntaxTreeExpr( ADDR_EXPR(expr)[0]));
    AssPRec(result, "right", SyntaxTreeExpr( ADDR_EXPR(expr)[1]));

    return result;
}

/* TODO: Probably do not need this for syntax tree */
/* But we have type information available (i.e. this is an integer
   expression!)
   need to find out where it comes from?
*/
Obj SyntaxTreeIntExpr(Expr expr)
{
    return Fail;
}

Obj SyntaxTreeTrueExpr(Expr expr)
{
    /* TODO: Maybe make a tree node? */
    return True;
}

Obj SyntaxTreeFalseExpr(Expr expr)
{
    /* TODO: Maybe make a tree node? */
    return False;
}

Obj SyntaxTreeCharExpr(Expr expr)
{
    /* TODO: How do I make a character literal? */
    /* Emit( "%c = ObjsChar[%d];\n", val, (Int)(((UChar*)ADDR_EXPR(expr))[0])); */
    return Fail;
}

Obj SyntaxTreePermExpr (Expr expr)
{
    Obj result;
    Obj perm;

    result = NewSyntaxTreeNode("permexpr", 2);

    /* check for the identity                                              */
    if ( SIZE_EXPR(expr) == 0 ) {
        AssPRec(result, RNamName("perm"), IdentityPerm);
    } else {
        /* loop over the cycles                                                */
        n = SIZE_EXPR(expr)/sizeof(Expr);
        perm = NEW_PLIST( T_PLIST, n );
        SET_LEN_PLIST( perm, n );

        for ( i = 1;  i <= n;  i++ ) {
            cycle = ADDR_EXPR(expr)[i-1];
            csize = SIZE_EXPR(cycle)/sizeof(Expr);
            cyc = NEW_PLIST( T_PLIST, csize );
            SET_LEN_PLIST( cyc, csize );
            SET_ELM_PLIST( perm, i, cyc );
            CHANGED_BAG( perm );

            /* loop over the entries of the cycle                              */
            for ( j = 1;  j <= csize;  j++ ) {
                val = SyntaxTreeExpr( ADDR_EXPR(cycle)[j-1] );
                SET_ELM_PLIST( cyc, j, val );
                CHANGED_BAG(cyc);
            }
        }
        AssPRec(result, "perm", Array2Perm(perm));
    }

    return perm;
}

/* TODO: FInd out why record and list subexpressions are handled
   special */
Obj SyntaxTreeListExpr (Expr expr)
{
    Obj result;
    Obj list;
    Int len;
    Int i;

    result = NewSyntaxTreeNode("listexpr", 2);
    len = SIZE_EXPR( expr ) / sizeof(Expr);

    list = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(list, len);

    for(i=1;i<=len;i++) {
        if(ADDR_EXPR(expr)[i-1] == 0) {
            continue;
        } else {
            SET_ELM_PLIST(list, i, SyntaxTreeExpr(ADDR_EXPR(expr)[i-1]));
            CHANGED_BAG(list);
        }
    }

    AssPRec(result, "list", list);

    return result;
}

/* TODO: Deal With tilde */
Obj SyntaxTreeListTildeExpr(Expr expr)
{
    return Fail;
#if 0
    CVar                list;           /* list value, result              */
    CVar                tilde;          /* old value of tilde              */

    /* remember the old value of '~'                                       */
    tilde = CVAR_TEMP( NewTemp( "tilde" ) );
    Emit( "%c = VAL_GVAR( Tilde );\n", tilde );

    /* create the list value                                               */
    list = SyntaxTreeListExpr1( expr );

    /* assign the list to '~'                                              */
    Emit( "AssGVarUnsafe( Tilde, %c );\n", list );

    /* evaluate the subexpressions into the list value                     */
    SyntaxTreeListExpr2( list, expr );

    /* restore old value of '~'                                            */
    Emit( "AssGVarUnsafe( Tilde, %c );\n", tilde );
    if ( IS_TEMP_CVAR( tilde ) )  FreeTemp( TEMP_CVAR( tilde ) );

    /* return the list value                                               */
    return list;
#endif
}

Obj SyntaxTreeRangeExpr(Expr expr)
{
    Obj result, first, second, last;

    result = NewSyntaxTreeNode("rangeexpr", 4);

    if ( SIZE_EXPR(expr) == 2 * sizeof(Expr) ) {
        first  = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
        second = 0;
        last   = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );
    } else {
        first  = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
        second = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );
        last   = SyntaxTreeExpr( ADDR_EXPR(expr)[2] );
    }

    AssPRec(result, RNamName("first"), first);
    AssPRec(result, RNamName("second"), second);
    AssPRec(result, RNamName("last"), last);

    return range;
}

Obj SyntaxTreeStringExpr(Expr expr)
{
    Obj result, string;

    result = NewSyntaxTreeNode("stringexpr",2);

    C_NEW_STRING( string, SIZE_EXPR(expr)-1-sizeof(UInt),
                  sizeof(UInt) + (Char*)ADDR_EXPR(expr) );


    AssPRec( result, RNamName("string"), string );

    return result;
}

Obj SyntaxTreeRecExpr(Expr expr)
{
    Obj result, rec;
    Obj key, val, tmp;
    Expr tmp;
    Int len;

    result = NewSyntaxTreeNode("recexpr", 2);

    len = SIZE_EXPR(expr) / (2*sizeof(Expr));
    rec = NEW_PREC(len);

    for ( i = 1; i <= len; i++ ) {
        tmp = ADDR_EXPR(expr)[2*i-1];
        if(tmp == 0 ) {
            continue;
        } else {
            val = SyntaxTreeExpr(tmp);
            tmp = ADDR_EXPR(expr)[2*i-2];
            key = SyntaxTreeExpr(tmp);

            AssPRec( rec, (UInt)RNamObj(key), val);
        }
    }
    SortPRecRNam( rec, 0 );
    AssPRec(result, RNamName("rec"), rec);

    /* return the result                                                   */
    return result;
}

/* TODO: Deal with tilde */
Obj SyntaxTreeRecTildeExpr(Expr expr)
{
    return Fail;
#if 0
    CVar                rec;            /* record value, result            */
    CVar                tilde;          /* old value of tilde              */

    /* remember the old value of '~'                                       */
    tilde = CVAR_TEMP( NewTemp( "tilde" ) );
    Emit( "%c = VAL_GVAR( Tilde );\n", tilde );

    /* create the record value                                             */
    rec = SyntaxTreeRecExpr1( expr );

    /* assign the record value to the variable '~'                         */
    Emit( "AssGVarUnsafe( Tilde, %c );\n", rec );

    /* evaluate the subexpressions into the record value                   */
    SyntaxTreeRecExpr2( rec, expr );

    /* restore the old value of '~'                                        */
    Emit( "AssGVarUnsafe( Tilde, %c );\n", tilde );
    if ( IS_TEMP_CVAR( tilde ) )  FreeTemp( TEMP_CVAR( tilde ) );

    /* return the record value                                             */
    return rec;
#endif
}

Obj SyntaxTreeRefLVar(Expr expr)
{
    Obj result;
    LVar                lvar;           /* local variable                  */

    result = NewSyntaxTreeNode("lvar", 2);

    if ( IS_REFLVAR(expr) ) {
        lvar = LVAR_REFLVAR(expr);
    } else {
        lvar = (LVar)(ADDR_EXPR(expr)[0]);
    }

    /* TODO: Local variable references */
    AssPRec(result, RNamName("variable"), INTOBJ_INT(lvar));

    return result;
}

Obj SyntaxTreeIsbLVar(Expr expr)
{
    Obj result;
    LVar lvar;

    result = NewSyntaxTreeNode("isblvar", 2);

    lvar = (LVar)(ADDR_EXPR(expr)[0]);

    AssPRec(result, RNamName("variable"), INTOBJ_INT(lvar));

    return result;
}

Obj SyntaxTreeRefHVar(Expr expr)
{
    Obj result;
    HVar hvar;

    /*
     * TODO: Deal with higher variables? This is not necessary for a
     * syntax tree!
     */
    result = NewSyntaxTreeNode("refhvar", 2);
    hvar = (HVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("variable"), INTOBJ_INT(hvar));

    return result;
}

Obj SyntaxTreeIsbHVar(Expr expr)
{
    Obj result;
    HVar hvar;

    result = NewSyntaxTreeNode("isbhvar", 2);
    hvar = (HVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamObj("variable"), INTOBJ_INT(hvar));
    SetInfoCVar( isb, W_BOOL );

    return result;
}

Obj SyntaxTreeRefGVar(Expr expr) 
{
    Obj result;
    GVar gvar;

    result = NewSyntaxTreeNode("refgvar", 2);
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVar(gvar));

    return result;
}

Obj SyntaxTreeRefGVarFopy(Expr expr)
{
    Obj result;
    GVar gvar;

    result = NewSyntaxTreeNode("refgvarfopy", 2);
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVar(gvar));

    return result;
}

Obj SyntaxTreeIsbGVar(Expr expr)
{
    Obj result;
    GVar gvar;

    result = NewSyntaxTreeNode("isbgvar", 2);
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVar(gvar));

    return result;
}

Obj SyntaxTreeElmList(Expr expr)
{
    Obj result;
    Obj list;
    Obj elm;

    result = NewSyntaxTreeNode("elmlist", 3);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);

    return result;
}

Obj SyntaxTreeElmsList(Expr expr)
{
    Obj result;
    Obj elms;
    Obj list;
    Obj poss;

    result = NewSyntaxTreeNode("elmslist", 3);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    poss = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPrec(result, RNamName("poss"), poss);

    return result;
}

Obj SyntaxTreeElmListLev(Expr expr)
{
    Obj result;

    Obj lists;
    Obj pos;
    Obj level;

    result = NewSyntaxTreeNode("elmlistlev", 3);

    lists = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );
    level = INTOBJ_INT((Int)(ADDR_EXPR(expr)[2]));

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("level"), level);

    return result;
}

Obj SyntaxTreeElmsListLev(Expr expr)
{
    Obj result;
    Obj lists;
    Obj poss;
    Obj level;

    result = NewSyntaxTreeNode("elmslistlev", 3);

    lists = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    poss = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );
    level = INTOBJ_INT((Int)(ADDR_EXPR(expr)[2]));

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("poss"), poss);
    AssPRec(result, RNamName("level"), level);

    return result;
}

Obj SyntaxTreeIsbList(Expr expr)
{
    Obj result;
    Obj list;
    Obj pos;

    result = NewSyntaxTreeNode("isblist",2);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    ASsPRec(result, RNamName("pos"), pos);

    return result;
}

Obj SyntaxTreeElmRecName(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("elmrecname", 2);

    record = SyntaxTreeExpr(ADDR_EXPR(expr)[0]);
    rnam = SyntaxTreeExpr(ADDR_EXPR(expr)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeElmRecExpr(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("elmrecexpr", 2);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeIsbRecName(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("isbrecname", 2);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeIsbRecExpr(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("isbrecname", 2);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeElmPosObj(Expr expr)
{
    Obj result;
    Obj list;
    Obj pos;

    result = NewSyntaxTreeNode("elmposobj", 2);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);

    return result;
}

/* TODO: figure out while this is not present in the compiler */
Obj SyntaxTreeElmsPosObj(Expr expr)
{
    return Fail;
}

/* TODO: figure out while this is not present in the compiler */
Obj SyntaxTreeElmPosObjLev(Expr expr)
{
    return Fail;
}

/* TODO: figure out while this is not present in the compiler */
Obj SyntaxTreeElmsPosObjLev(Expr expr)
{
    return Fail;
}

Obj SyntaxTreeIsbPosObj(Expr expr)
{
    Obj result;
    Obj list;
    Obj pos;

    result = NewSyntaxTreeNode("isbposobj", 2);

    list = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    pos = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);

    return result;
}

Obj SyntaxTreeElmComObjName(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("elmcomobjname", 3);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr(ADDR_EXPR(expr)[1]);

    AssPRec(result, RNamName("record", record));
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeElmComObjExpr(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("elmcomobj", 3);

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeIsbComObjName(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("isbcomobjname", 3);

    record = SyntaxTreeExpr(ADDR_EXPR(expr)[0]);
    rnam = SyntaxTreeExpr(ADDR_EXPR(expr)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj SyntaxTreeIsbComObjExpr(Expr expr)
{
    Obj result;
    Obj record;
    Obj rnam;

    result = NewSyntaxTreeNode("isbcomobjexpr",3 );

    record = SyntaxTreeExpr( ADDR_EXPR(expr)[0] );
    rnam = SyntaxTreeExpr( ADDR_EXPR(expr)[1] );

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), rnam);

    return result;
}

Obj (* SyntaxTreeStatFuncs[256])(Stat stat);

Obj SyntaxTreeStat( Stat stat )
{
    return (* SyntaxTreeStatFuncs[ TNUM_STAT(stat) ])( stat );
}

Obj SyntaxTreeUnknownStat(Stat stat)
{
    return NewSyntaxTreeNode("unknownstat",1);
}

/* TODO: Options? */
Obj SyntaxTreeProccall(Stat stat)
{
    Obj result;
    Obj args;
    Obj func;
    UInt narg;
    UInt i;

    result = NewSyntaxTreeNode("proccall", 2);

    /* TODO: What to do about this? */
    /* compile the reference to the function                               */
    if ( TNUM_EXPR( FUNC_CALL(stat) ) == T_REF_GVAR ) {
        /* mhm */
        func = SyntaxTreeRefGVarFopy( FUNC_CALL(stat) );
    } else {
        func = SyntaxTreeExpr( FUNC_CALL(stat) );
        SyntaxTreeCheckFunc( func );
    }
    AssPRec(result, RNamName("function"), func);

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_STAT(stat));
    args = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(args, narg);
    for ( i = 1; i <= narg; i++ ) {
        SET_ELM_PLIST(args, i, SyntaxTreeExpr( ARGI_CALL(stat,i) ) );
    }
    AssPRec(result, args);
    return result;
}

Obj SyntaxTreeProccallOpts(Stat stat)
{
    return Fail;
#if 0
  CVar opts = SyntaxTreeExpr(ADDR_STAT(stat)[0]);
  GVar pushOptions;
  GVar popOptions;
  pushOptions = GVarName("PushOptions");
  popOptions = GVarName("PopOptions");
  SyntaxTreeSetUseGVar(pushOptions, COMP_USE_GVAR_FOPY);
  SyntaxTreeSetUseGVar(popOptions, COMP_USE_GVAR_FOPY);
  Emit("CALL_1ARGS( GF_PushOptions, %c );\n", opts);
  if (IS_TEMP_CVAR( opts) ) FreeTemp( TEMP_CVAR( opts ));
  SyntaxTreeStat(ADDR_STAT(stat)[1]);
  Emit("CALL_0ARGS( GF_PopOptions );\n");
#endif
}

Obj SyntaxTreeSeqStat(Stat stat)
{
    Obj result;
    Obj list;
    UInt nr;
    UInt i;

    result = NewSyntaxTreeNode("seqstat", 2);

    /* get the number of statements                                        */
    nr = SIZE_STAT( stat ) / sizeof(Stat);
    list = NEW_PLIST(T_LIST, nr);
    SET_LEN_PLIST(list, nr);

    /* compile the statements                                              */
    for ( i = 1; i <= nr; i++ ) {
        SET_ELM_PLIST(list, i, SyntaxTreeStat( ADDR_STAT( stat )[i-1] ) );
        CHANGED_BAG(list);
    }
    AssPRec(result, RNamName("statements"), list);

    return result;
}

Obj SyntaxTreeIf(Stat stat)
{
    Obj result;

    Obj cond;
    Obj then;
    Obj elif;
    Obj branches;

    Int nr;

    result = NewSyntaxTreeNode("if", 3);

    nr = SIZE_STAT( stat ) / (2*sizeof(Stat));

    cond = SyntaxTreeBoolExpr( ADDR_STAT( stat )[0] );
    then = SyntaxTreeStat( ADDR_STAT( stat )[1] );

    AssPRec(result, RNamName("condition"), cond);
    AssPRec(result, RNamName("then"), then);

    branches = NEW_PLIST(T_LIST, nr);
    SET_LEN_PLIST(branches, nr);
    AssPRec(result, RNamName("branches"), branches);

    for ( i = 2; i <= nr; i++ ) {

        elif = NewSyntaxTreeNode("elif", 3);

        if ( i == nr && TNUM_EXPR(ADDR_STAT(stat)[2*(i-1)]) == T_TRUE_EXPR )
            break;

        cond = SyntaxTreeBoolExpr( ADDR_STAT( stat )[2*(i-1)] );
        then = SyntaxTreeStat( ADDR_STAT( stat )[2*(i-1)+1] );
        AssPRec(elif, RNamName("condition"), cond);
        AssPRec(elif, RNamName("then"), then);
        SET_ELM_PLIST(branches, i, elif);
        CHANGED_BAG(branches);
    }

    /* handle 'else' branch                                                */
    if ( i == nr ) {
        brelse = SyntaxTreeStat( ADDR_STAT( stat )[2*(i-1)+1] );
        AssPRec(result, RNamName("else"), brelse)
    }

    return result;
}

void SyntaxTreeFor(Stat stat)
{
    Obj result;
    Obj variable;
    Obj body;
    UInt i, nr;

    result = NewSyntaxTreeNode(result, 4);

    AssPRec(result, "variable", SyntaxTreeExpr(ADDR_STAT(stat)[0]));
    AssPRec(result, "collection", SyntaxTreeExpr(ADDR_STAT(stat)[1]));

    nr = SIZE_STAT(stat)/sizeof(Stat);
    body = NEW_PLIST(T_LIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for ( i = 2; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
        SET_ELM_PLIST(body, i - 1, SyntaxTreeStat( ADDR_STAT(stat)[i] ) );
    }

    return result;
}

Obj SyntaxTreeWhile(Stat stat )
{
    Obj result;
    Obj condition;
    Obj body;
    UInt nr, i;

    result = NewSyntaxTreeNode("while", 3);

    cond = SyntaxTreeBoolExpr( ADDR_STAT(stat)[0] );
    nr = SIZE_STAT(stat)/sizeof(Stat);

    body = NEW_PLIST(T_LIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for ( i = 1; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
        SET_ELM_PLIST(body, i, SyntaxTreeStat( ADDR_STAT(stat)[i] ));
        CHANGED_BAG(body);
    }

    return result;
}

Obj SyntaxTreeRepeat(Stat stat)
{
    Obj result;
    Obj condition;
    Obj body;
    UInt i, nr;

    result = NewSyntaxTreeNode("repeat", 4);

    cond = SyntaxTreeBoolExpr( ADDR_STAT(stat)[0] );
    AssPRec(result, RNamName("condition"), cond);

    nr = SIZE_STAT(stat)/sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for ( i = 1; i < nr; i++ ) {
        SET_ELM_PLIST(body, i, SyntaxTreeStat( ADDR_STAT(stat)[i] ) );
        CHANGED_BAG(body);
    }

    return result;
}

Obj SyntaxTreeBreak(Stat stat)
{
    return NewSyntaxTreeNode("break",1);
}

Obj SyntaxTreeContinue(Stat stat)
{
    return NewSyntaxTreeNode("continue", 1);
}

Obj SyntaxTreeReturnObj(Stat stat)
{
    Obj result;
    Obj obj;

    result = NewSyntaxTreeNode("return", 2);
    obj = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    AssPRec(result, RNamName("obj"), obj);

    return result;
}

Obj SyntaxTreeReturnVoid(Stat stat)
{
    return NewSyntaxTreeNode("return", 2);
}

Obj SyntaxTreeAssLVar(Stat stat)
{
    Obj result;
    Obj lvar;
    Obj rhs;

    result = NewSyntaxTreeNode("AssLVar", 2);

    /* TODO: make sure this works correctly */
    lvar = (LVar)(ADDR_STAT(stat)[0]);
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("lvar"), lvar);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbLVar(Stat stat)
{
    Obj result;
    Obj lvar;

    result = NewSyntaxTreeNode("UnbindLVar", 2);
    lvar = (LVar)(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("lvar"), lvar);

    return result;
}

Obj SyntaxTreeAssHVar(Stat stat)
{
    Obj result;
    Obj hvar;
    Obj rhs;

    result = NewSyntaxTreeNode("AssHVar", 2);

    hvar = (HVar)(ADDR_STAT(stat)[0]);
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("hvar"), hvar);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbHVar(Stat stat)
{
    Obj result;
    Obj hvar;

    result = NewSyntaxTreeNode("UnbindHVar", 2);

    hvar = (HVar)(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("hvar"), hvar);

    return result;
}

Obj SyntaxTreeAssGVar(Stat stat)
{
    Obj result;
    Obj gvar;
    Obj rhs;

    result = NewSyntaxTreeNode("AssGVar", 2);

    gvar = (GVar)(ADDR_STAT(stat)[0]);
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    AssPRec(result, RNamName("gvar"), gvar);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbGVar(Stat stat)
{
    Obj result;
    Obj gvar;

    result = NewSyntaxTreeNode("UnbGVar");

    gvar = (GVar)(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("gvar"), gvar);

    return result;
}

Obj SyntaxTreeAssList(Stat stat)
{
    Obj result;
    Obj list;
    Obj pos;
    Obj rhs;

    result = NewSyntaxTreeNode("AssList", 2);

    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    AssPRec(result, RNamName("list"), list);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeAsssList (Stat stat)
{
    CVar                list;           /* list                            */
    CVar                poss;           /* positions                       */
    CVar                rhss;           /* right hand sides                */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    poss = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    /* emit the code                                                       */
    Emit( "AsssListCheck( %c, %c, %c );\n", list, poss, rhss );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhss ) )  FreeTemp( TEMP_CVAR( rhss ) );
    if ( IS_TEMP_CVAR( poss ) )  FreeTemp( TEMP_CVAR( poss ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  SyntaxTreeAssListLev( <stat> )  . . . . . . . . . . . . . . . .  T_ASS_LIST_LEV
*/
void SyntaxTreeAssListLev (
    Stat                stat )
{
    CVar                lists;          /* lists                           */
    CVar                pos;            /* position                        */
    CVar                rhss;           /* right hand sides                */
    Int                 level;          /* level                           */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expressions                                        */
    lists = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    SyntaxTreeCheckIntSmallPos( pos );

    /* compile the right hand sides                                        */
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    /* get the level                                                       */
    level = (Int)(ADDR_STAT(stat)[3]);

    /* emit the code                                                       */
    Emit( "AssListLevel( %c, %c, %c, %d );\n", lists, pos, rhss, level );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhss  ) )  FreeTemp( TEMP_CVAR( rhss  ) );
    if ( IS_TEMP_CVAR( pos   ) )  FreeTemp( TEMP_CVAR( pos   ) );
    if ( IS_TEMP_CVAR( lists ) )  FreeTemp( TEMP_CVAR( lists ) );
}


/****************************************************************************
**
*F  SyntaxTreeAsssListLev( <stat> ) . . . . . . . . . . . . . . . . T_ASSS_LIST_LEV
*/
void SyntaxTreeAsssListLev (
    Stat                stat )
{
    CVar                lists;          /* list                            */
    CVar                poss;           /* positions                       */
    CVar                rhss;           /* right hand sides                */
    Int                 level;          /* level                           */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expressions                                        */
    lists = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    poss = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    /* get the level                                                       */
    level = (Int)(ADDR_STAT(stat)[3]);

    /* emit the code                                                       */
    Emit( "AsssListLevelCheck( %c, %c, %c, %d );\n",
          lists, poss, rhss, level );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhss  ) )  FreeTemp( TEMP_CVAR( rhss ) );
    if ( IS_TEMP_CVAR( poss  ) )  FreeTemp( TEMP_CVAR( poss ) );
    if ( IS_TEMP_CVAR( lists ) )  FreeTemp( TEMP_CVAR( lists ) );
}


/****************************************************************************
**
*F  SyntaxTreeUnbList( <stat> ) . . . . . . . . . . . . . . . . . . . .  T_UNB_LIST
*/
void SyntaxTreeUnbList (
    Stat                stat )
{
    CVar                list;           /* list, left operand              */
    CVar                pos;            /* position, left operand          */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    SyntaxTreeCheckIntPos( pos );

    /* emit the code                                                       */
    Emit( "C_UNB_LIST( %c, %c );\n", list, pos );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  SyntaxTreeAssRecName( <stat> )  . . . . . . . . . . . . . . . .  T_ASS_REC_NAME
*/
void SyntaxTreeAssRecName (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    SyntaxTreeSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* compile the right hand side                                         */
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    /* emit the code for the assignment                                    */
    Emit( "ASS_REC( %c, R_%n, %c );\n", record, NAME_RNAM(rnam), rhs );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  SyntaxTreeAssRecExpr( <stat> )  . . . . . . . . . . . . . . . .  T_ASS_REC_EXPR
*/
void SyntaxTreeAssRecExpr (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    CVar                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    /* emit the code for the assignment                                    */
    Emit( "ASS_REC( %c, RNamObj(%c), %c );\n", record, rnam, rhs );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  SyntaxTreeUnbRecName( <stat> )  . . . . . . . . . . . . . . . .  T_UNB_REC_NAME
*/
void SyntaxTreeUnbRecName (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    SyntaxTreeSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code for the assignment                                    */
    Emit( "UNB_REC( %c, R_%n );\n", record, NAME_RNAM(rnam) );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  SyntaxTreeUnbRecExpr( <stat> )  . . . . . . . . . . . . . . . .  T_UNB_REC_EXPR
*/
void            SyntaxTreeUnbRecExpr (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    CVar                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    /* emit the code for the assignment                                    */
    Emit( "UNB_REC( %c, RNamObj(%c) );\n", record, rnam );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  SyntaxTreeAssPosObj( <stat> ) . . . . . . . . . . . . . . . . . .  T_ASS_POSOBJ
*/
void SyntaxTreeAssPosObj (
    Stat                stat )
{
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    SyntaxTreeCheckIntSmallPos( pos );

    /* compile the right hand side                                         */
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    /* emit the code                                                       */
    if ( HasInfoCVar( rhs, W_INT_SMALL ) ) {
        Emit( "C_ASS_POSOBJ_INTOBJ( %c, %i, %c )\n", list, pos, rhs );
    }
    else {
        Emit( "C_ASS_POSOBJ( %c, %i, %c )\n", list, pos, rhs );
    }

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs  ) )  FreeTemp( TEMP_CVAR( rhs  ) );
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}



/****************************************************************************
**
*F  SyntaxTreeAsssPosObj( <stat> )  . . . . . . . . . . . . . . . . . T_ASSS_POSOBJ
*/
void SyntaxTreeAsssPosObj (
    Stat                stat )
{
    CVar                list;           /* list                            */
    CVar                poss;           /* positions                       */
    CVar                rhss;           /* right hand sides                */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    poss = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhss = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    /* emit the code                                                       */
    Emit( "AsssPosObjCheck( %c, %c, %c );\n", list, poss, rhss );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhss ) )  FreeTemp( TEMP_CVAR( rhss ) );
    if ( IS_TEMP_CVAR( poss ) )  FreeTemp( TEMP_CVAR( poss ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  SyntaxTreeAssPosObjLev( <stat> )  . . . . . . . . . . . . . .  T_ASS_POSOBJ_LEV
*/
void SyntaxTreeAssPosObjLev (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TNUM %d;\n", TNUM_STAT(stat) );
}


/****************************************************************************
**
*F  SyntaxTreeAsssPosObjLev( <stat> ) . . . . . . . . . . . . . . T_ASSS_POSOBJ_LEV
*/
void SyntaxTreeAsssPosObjLev (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TNUM %d;\n", TNUM_STAT(stat) );
}


/****************************************************************************
**
*F  SyntaxTreeUnbPosObj( <stat> ) . . . . . . . . . . . . . . . . . .  T_UNB_POSOBJ
*/
void SyntaxTreeUnbPosObj (
    Stat                stat )
{
    CVar                list;           /* list, left operand              */
    CVar                pos;            /* position, left operand          */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    pos = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    SyntaxTreeCheckIntSmallPos( pos );

    /* emit the code                                                       */
    Emit( "if ( TNUM_OBJ(%c) == T_POSOBJ ) {\n", list );
    Emit( "if ( %i <= SIZE_OBJ(%c)/sizeof(Obj)-1 ) {\n", pos, list );
    Emit( "SET_ELM_PLIST( %c, %i, 0 );\n", list, pos );
    Emit( "}\n}\n" );
    Emit( "else {\n" );
    Emit( "UNB_LIST( %c, %i );\n", list, pos );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  SyntaxTreeAssComObjName( <stat> ) . . . . . . . . . . . . . . T_ASS_COMOBJ_NAME
*/
void SyntaxTreeAssComObjName (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    SyntaxTreeSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* compile the right hand side                                         */
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    /* emit the code for the assignment                                    */
    Emit( "if ( TNUM_OBJ(%c) == T_COMOBJ ) {\n", record );
    Emit( "AssPRec( %c, R_%n, %c );\n", record, NAME_RNAM(rnam), rhs );
    Emit( "#ifdef HPCGAP\n" );
    Emit( "} else if ( TNUM_OBJ(%c) == T_ACOMOBJ ) {\n", record );
    Emit( "AssARecord( %c, R_%n, %c );\n", record, NAME_RNAM(rnam), rhs );
    Emit( "#endif\n" );
    Emit( "}\nelse {\n" );
    Emit( "ASS_REC( %c, R_%n, %c );\n", record, NAME_RNAM(rnam), rhs );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  SyntaxTreeAssComObjExpr( <stat> ) . . . . . . . . . . . . . . T_ASS_COMOBJ_EXPR
*/
void SyntaxTreeAssComObjExpr (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    CVar                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = SyntaxTreeExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhs = SyntaxTreeExpr( ADDR_STAT(stat)[2] );

    /* emit the code for the assignment                                    */
    Emit( "if ( TNUM_OBJ(%c) == T_COMOBJ ) {\n", record );
    Emit( "AssPRec( %c, RNamObj(%c), %c );\n", record, rnam, rhs );
    Emit( "#ifdef HPCGAP\n" );
    Emit( "} else if ( TNUM_OBJ(%c) == T_ACOMOBJ ) {\n", record );
    Emit( "AssARecord( %c, RNamObj(%c), %c );\n", record, rnam, rhs );
    Emit( "#endif\n" );
    Emit( "}\nelse {\n" );
    Emit( "ASS_REC( %c, RNamObj(%c), %c );\n", record, rnam, rhs );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  SyntaxTreeUnbComObjName( <stat> ) . . . . . . . . . . . . . . T_UNB_COMOBJ_NAME
*/
void SyntaxTreeUnbComObjName (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    SyntaxTreeSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code for the assignment                                    */
    Emit( "if ( TNUM_OBJ(%c) == T_COMOBJ ) {\n", record );
    Emit( "UnbPRec( %c, R_%n );\n", record, NAME_RNAM(rnam) );
    Emit( "#ifdef HPCGAP\n" );
    Emit( "} else if ( TNUM_OBJ(%c) == T_ACOMOBJ ) {\n", record );
    Emit( "UnbARecord( %c, R_%n );\n", record, NAME_RNAM(rnam) );
    Emit( "#endif\n" );
    Emit( "}\nelse {\n" );
    Emit( "UNB_REC( %c, R_%n );\n", record, NAME_RNAM(rnam) );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  SyntaxTreeUnbComObjExpr( <stat> ) . . . . . . . . . . . . . . T_UNB_COMOBJ_EXPR
*/
void SyntaxTreeUnbComObjExpr (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( SyntaxTreePass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = SyntaxTreeExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = SyntaxTreeExpr( ADDR_STAT(stat)[1] );
    SyntaxTreeSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code for the assignment                                    */
    Emit( "if ( TNUM_OBJ(%c) == T_COMOBJ ) {\n", record );
    Emit( "UnbPRec( %c, RNamObj(%c) );\n", record, rnam );
    Emit( "#ifdef HPCGAP\n" );
    Emit( "} else if ( TNUM_OBJ(%c) == T_ACOMOBJ ) {\n", record );
    Emit( "UnbARecord( %c, RNamObj(%c) );\n", record, rnam );
    Emit( "#endif\n" );
    Emit( "}\nelse {\n" );
    Emit( "UNB_REC( %c, RNamObj(%c) );\n", record, rnam );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}

/****************************************************************************
**
*F  SyntaxTreeEmpty( <stat> )  . . . . . . . . . . . . . . . . . . . . . . . T_EMPY
*/
void SyntaxTreeEmpty (
    Stat                stat )
{
  Emit("\n/* ; */\n");
  Emit(";");
}
  
/****************************************************************************
**
*F  SyntaxTreeInfo( <stat> )  . . . . . . . . . . . . . . . . . . . . . . .  T_INFO
*/
void SyntaxTreeInfo (
    Stat                stat )
{
    CVar                tmp;
    CVar                sel;
    CVar                lev;
    CVar                lst;
    Int                 narg;
    Int                 i;

    Emit( "\n/* Info( ... ); */\n" );
    sel = SyntaxTreeExpr( ARGI_INFO( stat, 1 ) );
    lev = SyntaxTreeExpr( ARGI_INFO( stat, 2 ) );
    lst = CVAR_TEMP( NewTemp( "lst" ) );
    tmp = CVAR_TEMP( NewTemp( "tmp" ) );
    Emit( "%c = CALL_2ARGS( InfoDecision, %c, %c );\n", tmp, sel, lev );
    Emit( "if ( %c == True ) {\n", tmp );
    if ( IS_TEMP_CVAR( tmp ) )  FreeTemp( TEMP_CVAR( tmp ) );
    narg = NARG_SIZE_INFO(SIZE_STAT(stat))-2;
    Emit( "%c = NEW_PLIST( T_PLIST, %d );\n", lst, narg );
    Emit( "SET_LEN_PLIST( %c, %d );\n", lst, narg );
    for ( i = 1;  i <= narg;  i++ ) {
        tmp = SyntaxTreeExpr( ARGI_INFO( stat, i+2 ) );
        Emit( "SET_ELM_PLIST( %c, %d, %c );\n", lst, i, tmp );
        Emit( "CHANGED_BAG(%c);\n", lst );
        if ( IS_TEMP_CVAR( tmp ) )  FreeTemp( TEMP_CVAR( tmp ) );
    }
    Emit( "CALL_1ARGS( InfoDoPrint, %c );\n", lst );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( lst ) )  FreeTemp( TEMP_CVAR( lst ) );
    if ( IS_TEMP_CVAR( lev ) )  FreeTemp( TEMP_CVAR( lev ) );
    if ( IS_TEMP_CVAR( sel ) )  FreeTemp( TEMP_CVAR( sel ) );
}


/****************************************************************************
**
*F  SyntaxTreeAssert2( <stat> ) . . . . . . . . . . . . . . . . . .  T_ASSERT_2ARGS
*/
void SyntaxTreeAssert2 (
    Stat                stat )
{
    CVar                lev;            /* the level                       */
    CVar                cnd;            /* the condition                   */

    Emit( "\n/* Assert( ... ); */\n" );
    lev = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    Emit( "if ( ! LT(CurrentAssertionLevel, %c) ) {\n", lev );
    cnd = SyntaxTreeBoolExpr( ADDR_STAT(stat)[1] );
    Emit( "if ( ! %c ) {\n", cnd );
    Emit( "ErrorReturnVoid(\"Assertion failure\",0L,0L,\"you may 'return;'\"" );
    Emit( ");\n");
    Emit( "}\n" );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( cnd ) )  FreeTemp( TEMP_CVAR( cnd ) );
    if ( IS_TEMP_CVAR( lev ) )  FreeTemp( TEMP_CVAR( lev ) );
}


/****************************************************************************
**
*F  SyntaxTreeAssert3( <stat> ) . . . . . . . . . . . . . . . . . .  T_ASSERT_3ARGS
*/
void SyntaxTreeAssert3 (
    Stat                stat )
{
    CVar                lev;            /* the level                       */
    CVar                cnd;            /* the condition                   */
    CVar                msg;            /* the message                     */

    Emit( "\n/* Assert( ... ); */\n" );
    lev = SyntaxTreeExpr( ADDR_STAT(stat)[0] );
    Emit( "if ( ! LT(CurrentAssertionLevel, %c) ) {\n", lev );
    cnd = SyntaxTreeBoolExpr( ADDR_STAT(stat)[1] );
    Emit( "if ( ! %c ) {\n", cnd );
    msg = SyntaxTreeExpr( ADDR_STAT(stat)[2] );
    Emit( "if ( %c != (Obj)(UInt)0 )", msg );
    Emit( "{\n if ( IS_STRING_REP ( %c ) )\n", msg);
    Emit( "   PrintString1( %c);\n else\n   PrintObj(%c);\n}\n", msg, msg );
    Emit( "}\n" );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( msg ) )  FreeTemp( TEMP_CVAR( msg ) );
    if ( IS_TEMP_CVAR( cnd ) )  FreeTemp( TEMP_CVAR( cnd ) );
    if ( IS_TEMP_CVAR( lev ) )  FreeTemp( TEMP_CVAR( lev ) );
}

#endif

static Obj SyntaxTreeFunc( Obj func )
{
    Obj result;
    Obj str;
    Obj name;
    Obj stats;

    Bag                 info;           /* info bag for this function      */
    Int                 narg;           /* number of arguments             */
    Int                 nloc;           /* number of locals                */
    Obj                 fexs;           /* function expression list        */
    Bag                 oldFrame;       /* old frame                       */
    Int                 i;              /* loop variable                   */
    Int                 prevarargs;     /* we have varargs with a prefix   */

    result = NEW_PREC(5);

    /* TODO: Deal with variadic functions */
    /*
    prevarargs = 0;
    if(narg < -1) prevarargs = 1;
    if (narg < 0) {
      narg = -narg;
    }
    */

    C_NEW_STRING_CONST(str, "function");
    AssPRec(result, RNamName("type"), str);

    /* functions don't have names, do they? */
    //  AssPRec(result, RNamName("name"), NAME_FUNC(func));

    narg = NARG_FUNC(func);
    AssPRec(result, RNamName("narg"), INTOBJ_INT(narg));

    nloc = NLOC_FUNC(func);
    AssPRec(result, RNamName("nloc"), INTOBJ_INT(nloc));

    /* switch to this function (so that 'ADDR_STAT' and 'ADDR_EXPR' work)  */
    SWITCH_TO_NEW_LVARS( func, narg, nloc, oldFrame );
    stats = SyntaxTreeStat( FIRST_STAT_CURR_FUNC );
    SWITCH_TO_OLD_LVARS( oldFrame );

    AssPrec(result, RNamName("stats"), stats);

    return result;
}

Obj FuncSYNTAX_TREE ( Obj self, Obj func )
{
    return SyntaxTreeFunc(func);
}

static StructGVarFunc GVarFuncs [] = {
    { "SYNTAX_TREE", 1, "func",
      FuncSYNTAX_TREE, "src/syntaxtree.c:SYNTAX_TREE" },

    { 0 }

};

static Int InitKernel (
    StructInitInfo *    module )
{
    Int                 i;              /* loop variable                   */

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* announce the global variables                                       */
    InitGlobalBag( &SyntaxTreeGVar,  "src/compiler.c:SyntaxTreeInfoGVar"  );
    InitGlobalBag( &SyntaxTreeRNam,  "src/compiler.c:SyntaxTreeInfoRNam"  );
    InitGlobalBag( &SyntaxTreeFunctions, "src/compiler.c:SyntaxTreeFunctions" );

    /* enter the expression compilers into the table                       */
    for ( i = 0; i < 256; i++ ) {
        SyntaxTreeExprFuncs[ i ] = SyntaxTreeUnknownExpr;
    }

    SyntaxTreeExprFuncs[ T_FUNCCALL_0ARGS  ] = SyntaxTreeFunccall0to6Args;
    SyntaxTreeExprFuncs[ T_FUNCCALL_1ARGS  ] = SyntaxTreeFunccall0to6Args;
    SyntaxTreeExprFuncs[ T_FUNCCALL_2ARGS  ] = SyntaxTreeFunccall0to6Args;
    SyntaxTreeExprFuncs[ T_FUNCCALL_3ARGS  ] = SyntaxTreeFunccall0to6Args;
    SyntaxTreeExprFuncs[ T_FUNCCALL_4ARGS  ] = SyntaxTreeFunccall0to6Args;
    SyntaxTreeExprFuncs[ T_FUNCCALL_5ARGS  ] = SyntaxTreeFunccall0to6Args;
    SyntaxTreeExprFuncs[ T_FUNCCALL_6ARGS  ] = SyntaxTreeFunccall0to6Args;
    SyntaxTreeExprFuncs[ T_FUNCCALL_XARGS  ] = SyntaxTreeFunccallXArgs;
    SyntaxTreeExprFuncs[ T_FUNC_EXPR       ] = SyntaxTreeFuncExpr;

    SyntaxTreeExprFuncs[ T_OR              ] = SyntaxTreeOr;
    SyntaxTreeExprFuncs[ T_AND             ] = SyntaxTreeAnd;
    SyntaxTreeExprFuncs[ T_NOT             ] = SyntaxTreeNot;
    SyntaxTreeExprFuncs[ T_EQ              ] = SyntaxTreeEq;
    SyntaxTreeExprFuncs[ T_NE              ] = SyntaxTreeNe;
    SyntaxTreeExprFuncs[ T_LT              ] = SyntaxTreeLt;
    SyntaxTreeExprFuncs[ T_GE              ] = SyntaxTreeGe;
    SyntaxTreeExprFuncs[ T_GT              ] = SyntaxTreeGt;
    SyntaxTreeExprFuncs[ T_LE              ] = SyntaxTreeLe;
    SyntaxTreeExprFuncs[ T_IN              ] = SyntaxTreeIn;

    SyntaxTreeExprFuncs[ T_SUM             ] = SyntaxTreeSum;
    SyntaxTreeExprFuncs[ T_AINV            ] = SyntaxTreeAInv;
    SyntaxTreeExprFuncs[ T_DIFF            ] = SyntaxTreeDiff;
    SyntaxTreeExprFuncs[ T_PROD            ] = SyntaxTreeProd;
    SyntaxTreeExprFuncs[ T_INV             ] = SyntaxTreeInv;
    SyntaxTreeExprFuncs[ T_QUO             ] = SyntaxTreeQuo;
    SyntaxTreeExprFuncs[ T_MOD             ] = SyntaxTreeMod;
    SyntaxTreeExprFuncs[ T_POW             ] = SyntaxTreePow;

    SyntaxTreeExprFuncs[ T_INTEXPR         ] = SyntaxTreeIntExpr;
    SyntaxTreeExprFuncs[ T_INT_EXPR        ] = SyntaxTreeIntExpr;
    SyntaxTreeExprFuncs[ T_TRUE_EXPR       ] = SyntaxTreeTrueExpr;
    SyntaxTreeExprFuncs[ T_FALSE_EXPR      ] = SyntaxTreeFalseExpr;
    SyntaxTreeExprFuncs[ T_CHAR_EXPR       ] = SyntaxTreeCharExpr;
    SyntaxTreeExprFuncs[ T_PERM_EXPR       ] = SyntaxTreePermExpr;
    SyntaxTreeExprFuncs[ T_PERM_CYCLE      ] = SyntaxTreeUnknownExpr;
    SyntaxTreeExprFuncs[ T_LIST_EXPR       ] = SyntaxTreeListExpr;
    SyntaxTreeExprFuncs[ T_LIST_TILD_EXPR  ] = SyntaxTreeListTildeExpr;
    SyntaxTreeExprFuncs[ T_RANGE_EXPR      ] = SyntaxTreeRangeExpr;
    SyntaxTreeExprFuncs[ T_STRING_EXPR     ] = SyntaxTreeStringExpr;
    SyntaxTreeExprFuncs[ T_REC_EXPR        ] = SyntaxTreeRecExpr;
    SyntaxTreeExprFuncs[ T_REC_TILD_EXPR   ] = SyntaxTreeRecTildeExpr;

    SyntaxTreeExprFuncs[ T_REFLVAR         ] = SyntaxTreeRefLVar;
    SyntaxTreeExprFuncs[ T_ISB_LVAR        ] = SyntaxTreeIsbLVar;
    SyntaxTreeExprFuncs[ T_REF_HVAR        ] = SyntaxTreeRefHVar;
    SyntaxTreeExprFuncs[ T_ISB_HVAR        ] = SyntaxTreeIsbHVar;
    SyntaxTreeExprFuncs[ T_REF_GVAR        ] = SyntaxTreeRefGVar;
    SyntaxTreeExprFuncs[ T_ISB_GVAR        ] = SyntaxTreeIsbGVar;

    SyntaxTreeExprFuncs[ T_ELM_LIST        ] = SyntaxTreeElmList;
    SyntaxTreeExprFuncs[ T_ELMS_LIST       ] = SyntaxTreeElmsList;
    SyntaxTreeExprFuncs[ T_ELM_LIST_LEV    ] = SyntaxTreeElmListLev;
    SyntaxTreeExprFuncs[ T_ELMS_LIST_LEV   ] = SyntaxTreeElmsListLev;
    SyntaxTreeExprFuncs[ T_ISB_LIST        ] = SyntaxTreeIsbList;
    SyntaxTreeExprFuncs[ T_ELM_REC_NAME    ] = SyntaxTreeElmRecName;
    SyntaxTreeExprFuncs[ T_ELM_REC_EXPR    ] = SyntaxTreeElmRecExpr;
    SyntaxTreeExprFuncs[ T_ISB_REC_NAME    ] = SyntaxTreeIsbRecName;
    SyntaxTreeExprFuncs[ T_ISB_REC_EXPR    ] = SyntaxTreeIsbRecExpr;

    SyntaxTreeExprFuncs[ T_ELM_POSOBJ      ] = SyntaxTreeElmPosObj;
    SyntaxTreeExprFuncs[ T_ELMS_POSOBJ     ] = SyntaxTreeElmsPosObj;
    SyntaxTreeExprFuncs[ T_ELM_POSOBJ_LEV  ] = SyntaxTreeElmPosObjLev;
    SyntaxTreeExprFuncs[ T_ELMS_POSOBJ_LEV ] = SyntaxTreeElmsPosObjLev;
    SyntaxTreeExprFuncs[ T_ISB_POSOBJ      ] = SyntaxTreeIsbPosObj;
    SyntaxTreeExprFuncs[ T_ELM_COMOBJ_NAME ] = SyntaxTreeElmComObjName;
    SyntaxTreeExprFuncs[ T_ELM_COMOBJ_EXPR ] = SyntaxTreeElmComObjExpr;
    SyntaxTreeExprFuncs[ T_ISB_COMOBJ_NAME ] = SyntaxTreeIsbComObjName;
    SyntaxTreeExprFuncs[ T_ISB_COMOBJ_EXPR ] = SyntaxTreeIsbComObjExpr;

    SyntaxTreeExprFuncs[ T_FUNCCALL_OPTS   ] = SyntaxTreeFunccallOpts;
    
    /* enter the boolean expression compilers into the table               */
    for ( i = 0; i < 256; i++ ) {
        SyntaxTreeBoolExprFuncs[ i ] = SyntaxTreeUnknownBool;
    }

    SyntaxTreeBoolExprFuncs[ T_OR              ] = SyntaxTreeOrBool;
    SyntaxTreeBoolExprFuncs[ T_AND             ] = SyntaxTreeAndBool;
    SyntaxTreeBoolExprFuncs[ T_NOT             ] = SyntaxTreeNotBool;
    SyntaxTreeBoolExprFuncs[ T_EQ              ] = SyntaxTreeEqBool;
    SyntaxTreeBoolExprFuncs[ T_NE              ] = SyntaxTreeNeBool;
    SyntaxTreeBoolExprFuncs[ T_LT              ] = SyntaxTreeLtBool;
    SyntaxTreeBoolExprFuncs[ T_GE              ] = SyntaxTreeGeBool;
    SyntaxTreeBoolExprFuncs[ T_GT              ] = SyntaxTreeGtBool;
    SyntaxTreeBoolExprFuncs[ T_LE              ] = SyntaxTreeLeBool;
    SyntaxTreeBoolExprFuncs[ T_IN              ] = SyntaxTreeInBool;

    /* enter the statement compilers into the table                        */
    for ( i = 0; i < 256; i++ ) {
        SyntaxTreeStatFuncs[ i ] = SyntaxTreeUnknownStat;
    }

    SyntaxTreeStatFuncs[ T_PROCCALL_0ARGS  ] = SyntaxTreeProccall0to6Args;
    SyntaxTreeStatFuncs[ T_PROCCALL_1ARGS  ] = SyntaxTreeProccall0to6Args;
    SyntaxTreeStatFuncs[ T_PROCCALL_2ARGS  ] = SyntaxTreeProccall0to6Args;
    SyntaxTreeStatFuncs[ T_PROCCALL_3ARGS  ] = SyntaxTreeProccall0to6Args;
    SyntaxTreeStatFuncs[ T_PROCCALL_4ARGS  ] = SyntaxTreeProccall0to6Args;
    SyntaxTreeStatFuncs[ T_PROCCALL_5ARGS  ] = SyntaxTreeProccall0to6Args;
    SyntaxTreeStatFuncs[ T_PROCCALL_6ARGS  ] = SyntaxTreeProccall0to6Args;
    SyntaxTreeStatFuncs[ T_PROCCALL_XARGS  ] = SyntaxTreeProccallXArgs;

    SyntaxTreeStatFuncs[ T_SEQ_STAT        ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT2       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT3       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT4       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT5       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT6       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_SEQ_STAT7       ] = SyntaxTreeSeqStat;
    SyntaxTreeStatFuncs[ T_IF              ] = SyntaxTreeIf;
    SyntaxTreeStatFuncs[ T_IF_ELSE         ] = SyntaxTreeIf;
    SyntaxTreeStatFuncs[ T_IF_ELIF         ] = SyntaxTreeIf;
    SyntaxTreeStatFuncs[ T_IF_ELIF_ELSE    ] = SyntaxTreeIf;
    SyntaxTreeStatFuncs[ T_FOR             ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR2            ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR3            ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR_RANGE       ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR_RANGE2      ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_FOR_RANGE3      ] = SyntaxTreeFor;
    SyntaxTreeStatFuncs[ T_WHILE           ] = SyntaxTreeWhile;
    SyntaxTreeStatFuncs[ T_WHILE2          ] = SyntaxTreeWhile;
    SyntaxTreeStatFuncs[ T_WHILE3          ] = SyntaxTreeWhile;
    SyntaxTreeStatFuncs[ T_REPEAT          ] = SyntaxTreeRepeat;
    SyntaxTreeStatFuncs[ T_REPEAT2         ] = SyntaxTreeRepeat;
    SyntaxTreeStatFuncs[ T_REPEAT3         ] = SyntaxTreeRepeat;
    SyntaxTreeStatFuncs[ T_BREAK           ] = SyntaxTreeBreak;
    SyntaxTreeStatFuncs[ T_CONTINUE        ] = SyntaxTreeContinue;
    SyntaxTreeStatFuncs[ T_RETURN_OBJ      ] = SyntaxTreeReturnObj;
    SyntaxTreeStatFuncs[ T_RETURN_VOID     ] = SyntaxTreeReturnVoid;

    SyntaxTreeStatFuncs[ T_ASS_LVAR        ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_01     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_02     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_03     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_04     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_05     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_06     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_07     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_08     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_09     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_10     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_11     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_12     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_13     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_14     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_15     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_ASS_LVAR_16     ] = SyntaxTreeAssLVar;
    SyntaxTreeStatFuncs[ T_UNB_LVAR        ] = SyntaxTreeUnbLVar;
    SyntaxTreeStatFuncs[ T_ASS_HVAR        ] = SyntaxTreeAssHVar;
    SyntaxTreeStatFuncs[ T_UNB_HVAR        ] = SyntaxTreeUnbHVar;
    SyntaxTreeStatFuncs[ T_ASS_GVAR        ] = SyntaxTreeAssGVar;
    SyntaxTreeStatFuncs[ T_UNB_GVAR        ] = SyntaxTreeUnbGVar;

    SyntaxTreeStatFuncs[ T_ASS_LIST        ] = SyntaxTreeAssList;
    SyntaxTreeStatFuncs[ T_ASSS_LIST       ] = SyntaxTreeAsssList;
    SyntaxTreeStatFuncs[ T_ASS_LIST_LEV    ] = SyntaxTreeAssListLev;
    SyntaxTreeStatFuncs[ T_ASSS_LIST_LEV   ] = SyntaxTreeAsssListLev;
    SyntaxTreeStatFuncs[ T_UNB_LIST        ] = SyntaxTreeUnbList;
    SyntaxTreeStatFuncs[ T_ASS_REC_NAME    ] = SyntaxTreeAssRecName;
    SyntaxTreeStatFuncs[ T_ASS_REC_EXPR    ] = SyntaxTreeAssRecExpr;
    SyntaxTreeStatFuncs[ T_UNB_REC_NAME    ] = SyntaxTreeUnbRecName;
    SyntaxTreeStatFuncs[ T_UNB_REC_EXPR    ] = SyntaxTreeUnbRecExpr;

    SyntaxTreeStatFuncs[ T_ASS_POSOBJ      ] = SyntaxTreeAssPosObj;
    SyntaxTreeStatFuncs[ T_ASSS_POSOBJ     ] = SyntaxTreeAsssPosObj;
    SyntaxTreeStatFuncs[ T_ASS_POSOBJ_LEV  ] = SyntaxTreeAssPosObjLev;
    SyntaxTreeStatFuncs[ T_ASSS_POSOBJ_LEV ] = SyntaxTreeAsssPosObjLev;
    SyntaxTreeStatFuncs[ T_UNB_POSOBJ      ] = SyntaxTreeUnbPosObj;
    SyntaxTreeStatFuncs[ T_ASS_COMOBJ_NAME ] = SyntaxTreeAssComObjName;
    SyntaxTreeStatFuncs[ T_ASS_COMOBJ_EXPR ] = SyntaxTreeAssComObjExpr;
    SyntaxTreeStatFuncs[ T_UNB_COMOBJ_NAME ] = SyntaxTreeUnbComObjName;
    SyntaxTreeStatFuncs[ T_UNB_COMOBJ_EXPR ] = SyntaxTreeUnbComObjExpr;

    SyntaxTreeStatFuncs[ T_INFO            ] = SyntaxTreeInfo;
    SyntaxTreeStatFuncs[ T_ASSERT_2ARGS    ] = SyntaxTreeAssert2;
    SyntaxTreeStatFuncs[ T_ASSERT_3ARGS    ] = SyntaxTreeAssert3;
    SyntaxTreeStatFuncs[ T_EMPTY           ] = SyntaxTreeEmpty;

    SyntaxTreeStatFuncs[ T_PROCCALL_OPTS   ] = SyntaxTreeProccallOpts;
    /* return success                                                      */
#endif
    return 0;
}

static Int PostRestore (
    StructInitInfo *    module )
{
    return 0;
}

static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return PostRestore( module );
}

static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "syntaxtree",                       /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    PostRestore                         /* postRestore                    */
};

StructInitInfo * InitInfoSyntaxTree ( void )
{
    return &module;
}


/****************************************************************************
**
*E  compiler.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



