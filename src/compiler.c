/****************************************************************************
**
*W  compiler.c                  GAP source                       Frank Celler
*W                                                         & Ferenc Ràkòczi
*W                                                         & Martin Schönert
**
**
*Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the GAP to C compiler.
*/
#include <stdarg.h>                     /* variable argument list macros */
#include <src/system.h>                 /* Ints, UInts */
#include <src/gapstate.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gvars.h>                  /* global variables */

#include <src/ariths.h>                 /* basic arithmetic */
#include <src/gmpints.h>

#include <src/bool.h>                   /* booleans */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/calls.h>                  /* generic call mechanism */
/*N 1996/06/16 mschoene func expressions should be different from funcs    */

#include <src/lists.h>                  /* generic lists */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/plist.h>                  /* plain lists */

#include <src/stringobj.h>              /* strings */

#include <src/code.h>                   /* coder */

#include <src/exprs.h>                  /* expressions */
#include <src/stats.h>                  /* statements */

#include <src/compiler.h>               /* compiler */

#include <src/hpc/tls.h>                /* thread-local storage */

#include <src/vars.h>                   /* variables */


/****************************************************************************
**

*F * * * * * * * * * * * * * compilation flags  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**


*V  CompFastIntArith  . . option to emit code that handles small ints. faster
*/
Int CompFastIntArith;


/****************************************************************************
**
*V  CompFastPlainLists  . option to emit code that handles plain lists faster
*/
Int CompFastPlainLists ;


/****************************************************************************
**
*V  CompFastListFuncs . . option to emit code that inlines calls to functions
*/
Int CompFastListFuncs;


/****************************************************************************
**
*V  CompCheckTypes  . . . . option to emit code that assumes all types are ok.
*/
Int CompCheckTypes ;


/****************************************************************************
**
*V  CompCheckListElements .  option to emit code that assumes list elms exist
*/
Int CompCheckListElements;


/****************************************************************************
**
*V  CompCheckPosObjElements .  option to emit code that assumes pos elm exist
*/
Int CompCheckPosObjElements;


/****************************************************************************
**
*V  CompPass  . . . . . . . . . . . . . . . . . . . . . . . . . compiler pass
**
**  'CompPass' holds the number of the current pass.
**
**  The compiler does two passes over the source.
**
**  In the first pass it only collects information but emits no code.
**
**  It finds  out which global  variables and record names  are used, so that
**  the  compiler can output  code to define  and initialize global variables
**  'G_<name>' resp. 'R_<name>' to hold their identifiers.
**
**  It finds out   which arguments and local  variables  are used  as  higher
**  variables  from inside local functions,  so that  the compiler can output
**  code to allocate and manage a stack frame for them.
**
**  It finds out how many temporary variables are used, so that the compiler
**  can output code to define corresponding local variables.
**
**  In the second pass it emits code.
**
**  The only difference between the  first pass and  the second pass is  that
**  'Emit'  emits  no code  during the first  pass.   While  this causes many
**  unneccessary  computations during the first pass,  the  advantage is that
**  the two passes are guaranteed to do exactly the same computations.
*/
Int CompPass;


/****************************************************************************
**

*F * * * * * * * * * * * * temp, C, local functions * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  compilerMagic1  . . . . . . . . . . . . . . . . . . . . .  current magic1
*/
static Int compilerMagic1;


/****************************************************************************
**
*V  compilerMagic2  . . . . . . . . . . . . . . . . . . . . .  current magic2
*/
static Char * compilerMagic2;


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
    if ( temp != CTEMP_INFO( info ) && CompPass == 2 ) {
        Pr("PROBLEM: freeing t_%d, should be t_%d\n",(Int)temp,CTEMP_INFO(info));
    }

    /* free the temporary                                                  */
    TNUM_TEMP_INFO( info, temp ) = W_UNUSED;
    CTEMP_INFO( info )--;
}


/****************************************************************************
**
*F  CompSetUseHVar( <hvar> )  . . . . . . . . register use of higher variable
*F  CompGetUseHVar( <hvar> )  . . . . . . . . get use mode of higher variable
*F  GetLevlHVar( <hvar> ) . . . . . . . . . . .  get level of higher variable
*F  GetIndxHVar( <hvar> ) . . . . . . . . . . .  get index of higher variable
**
**  'CompSetUseHVar'  register (during pass 1)   that the variable <hvar>  is
**  used  as   higher  variable, i.e.,  is  referenced   from inside  a local
**  function.  Such variables  must be allocated  in  a stack frame  bag (and
**  cannot be mapped to C variables).
**
**  'CompGetUseHVar' returns nonzero if the variable <hvar> is used as higher
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

void            CompSetUseHVar (
    HVar                hvar )
{
    Bag                 info;           /* its info bag                    */
    Int                 i;              /* loop variable                   */

    /* only mark in pass 1                                                 */
    if ( CompPass != 1 )  return;

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

Int             CompGetUseHVar (
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
    levl++;
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        info = NEXT_INFO( info );
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
*F  CompSetUseGVar( <gvar>, <mode> )  . . . . register use of global variable
*F  CompGetUseGVar( <gvar> )  . . . . . . . . get use mode of global variable
**
**  'CompSetUseGVar' registers (during pass 1) the use of the global variable
**  with identifier <gvar>.
**
**  'CompGetUseGVar'  returns the bitwise OR  of all the <mode> arguments for
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

Bag             CompInfoGVar;

void            CompSetUseGVar (
    GVar                gvar,
    UInt                mode )
{
    /* only mark in pass 1                                                 */
    if ( CompPass != 1 )  return;

    /* resize if neccessary                                                */
    if ( SIZE_OBJ(CompInfoGVar)/sizeof(UInt) <= gvar ) {
        ResizeBag( CompInfoGVar, sizeof(UInt)*(gvar+1) );
    }

    /* or with <mode>                                                      */
    ((UInt*)PTR_BAG(CompInfoGVar))[gvar] |= mode;
}

UInt            CompGetUseGVar (
    GVar                gvar )
{
    return ((UInt*)PTR_BAG(CompInfoGVar))[gvar];
}


/****************************************************************************
**
*F  CompSetUseRNam( <rnam>, <mode> )  . . . . . . register use of record name
*F  CompGetUseRNam( <rnam> )  . . . . . . . . . . get use mode of record name
**
**  'CompSetUseRNam' registers  (during pass  1) the use   of the record name
**  with identifier <rnam>.  'CompGetUseRNam'  returns the bitwise OR  of all
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

Bag             CompInfoRNam;

void            CompSetUseRNam (
    RNam                rnam,
    UInt                mode )
{
    /* only mark in pass 1                                                 */
    if ( CompPass != 1 )  return;

    /* resize if neccessary                                                */
    if ( SIZE_OBJ(CompInfoRNam)/sizeof(UInt) <= rnam ) {
        ResizeBag( CompInfoRNam, sizeof(UInt)*(rnam+1) );
    }

    /* or with <mode>                                                      */
    ((UInt*)PTR_BAG(CompInfoRNam))[rnam] |= mode;
}

UInt            CompGetUseRNam (
    RNam                rnam )
{
    return ((UInt*)PTR_BAG(CompInfoRNam))[rnam];
}


/****************************************************************************
**
*F  Emit( <fmt>, ... )  . . . . . . . . . . . . . . . . . . . . . . emit code
**
**  'Emit' outputs the   string  <fmt> and the  other  arguments,  which must
**  correspond  to the '%'  format elements  in  <fmt>.  Nothing  is actually
**  outputted if 'CompPass' is not 2.
**
**  'Emit'   supports the following   '%'  format elements:  '%d' formats  an
**  integer,   '%s' formats a  string,  '%S' formats a    string with all the
**  necessary escapes, %C does the same  but uses only  valid C escapes, '%n'
**  formats a  name   ('_' is  converted   to '__',  special  characters  are
**  converted to     '_<hex1><hex2>'),    '%c'  formats     a  C     variable
**  ('INTOBJ_INT(<int>)'  for integers,  'a_<name>' for arguments, 'l_<name>'
**  for locals, 't_<nr>' for temporaries), and '%%' outputs a single '%'.
*/
Int             EmitIndent;

Int             EmitIndent2;

void            Emit (
    const char *        fmt,
    ... )
{
    Int                 narg;           /* number of arguments             */
    va_list             ap;             /* argument list pointer           */
    Int                 dint;           /* integer argument                */
    CVar                cvar;           /* C variable argument             */
    Char *              string;         /* string argument                 */
    const Char *        p;              /* loop variable                   */
    Char *              q;              /* loop variable                   */
    const Char *        hex = "0123456789ABCDEF";

    /* are we in pass 2?                                                   */
    if ( CompPass != 2 )  return;

    /* get the information bag                                             */
    narg = NARG_FUNC( CURR_FUNC );
    if (narg < 0) {
        narg = -narg;
    }

    /* loop over the format string                                         */
    va_start( ap, fmt );
    for ( p = fmt; *p != '\0'; p++ ) {

        /* print an indent, except for preprocessor commands               */
        if ( *fmt != '#' ) {
            if ( 0 < EmitIndent2 && *p == '}' ) EmitIndent2--;
            while ( 0 < EmitIndent2-- )  Pr( " ", 0L, 0L );
        }

        /* format an argument                                              */
        if ( *p == '%' ) {
            p++;

            /* emit an integer                                             */
            if ( *p == 'd' ) {
                dint = va_arg( ap, Int );
                Pr( "%d", dint, 0L );
            }

            /* emit a string                                               */
            else if ( *p == 's' ) {
                string = va_arg( ap, Char* );
                Pr( "%s", (Int)string, 0L );
            }

            /* emit a string                                               */
            else if ( *p == 'S' ) {
                string = va_arg( ap, Char* );
                Pr( "%S", (Int)string, 0L );
            }

            /* emit a string                                               */
            else if ( *p == 'C' ) {
                string = va_arg( ap, Char* );
                Pr( "%C", (Int)string, 0L );
            }

            /* emit a name                                                 */
            else if ( *p == 'n' ) {
                string = va_arg( ap, Char* );
                for ( q = string; *q != '\0'; q++ ) {
                    if ( IsAlpha(*q) || IsDigit(*q) ) {
                        Pr( "%c", (Int)(*q), 0L );
                    }
                    else if ( *q == '_' ) {
                        Pr( "__", 0L, 0L );
                    }
                    else {
                        Pr("_%c%c",hex[((UInt)*q)/16],hex[((UInt)*q)%16]);
                    }
                }
            }

            /* emit a C variable                                           */
            else if ( *p == 'c' ) {
                cvar = va_arg( ap, CVar );
                if ( IS_INTG_CVAR(cvar) ) {
                    Int x = INTG_CVAR(cvar);
                    if (x >= -(1L <<28) && x < (1L << 28))
                        Pr( "INTOBJ_INT(%d)", x, 0L );
                    else
                        Pr( "C_MAKE_MED_INT(%d)", x, 0L );
                }
                else if ( IS_TEMP_CVAR(cvar) ) {
                    Pr( "t_%d", TEMP_CVAR(cvar), 0L );
                }
                else if ( LVAR_CVAR(cvar) <= narg ) {
                    Emit( "a_%n", NAME_LVAR( LVAR_CVAR(cvar) ) );
                }
                else {
                    Emit( "l_%n", NAME_LVAR( LVAR_CVAR(cvar) ) );
                }
            }

            /* emit a C variable                                           */
            else if ( *p == 'i' ) {
                cvar = va_arg( ap, CVar );
                if ( IS_INTG_CVAR(cvar) ) {
                    Pr( "%d", INTG_CVAR(cvar), 0L );
                }
                else if ( IS_TEMP_CVAR(cvar) ) {
                    Pr( "INT_INTOBJ(t_%d)", TEMP_CVAR(cvar), 0L );
                }
                else if ( LVAR_CVAR(cvar) <= narg ) {
                    Emit( "INT_INTOBJ(a_%n)", NAME_LVAR( LVAR_CVAR(cvar) ) );
                }
                else {
                    Emit( "INT_INTOBJ(l_%n)", NAME_LVAR( LVAR_CVAR(cvar) ) );
                }
            }

            /* emit a '%'                                                  */
            else if ( *p == '%' ) {
                Pr( "%%", 0L, 0L );
            }

            /* what                                                        */
            else {
                Pr( "%%illegal format statement", 0L, 0L );
            }

        }

        else if ( *p == '{' ) {
            Pr( "{", 0L, 0L );
            EmitIndent++;
        }
        else if ( *p == '}' ) {
            Pr( "}", 0L, 0L );
            EmitIndent--;
        }
        else if ( *p == '\n' ) {
            Pr( "\n", 0L, 0L );
            EmitIndent2 = EmitIndent;
        }

        else {
            Pr( "%c", (Int)(*p), 0L );
        }

    }
    va_end( ap );

}


/****************************************************************************
**

*F * * * * * * * * * * * * * * compile checks * * * * * * * * * * * * * * * *
*/


/****************************************************************************
**


*F  CompCheckBound( <obj>, <name> ) emit code to check that <obj> has a value
*/
void CompCheckBound (
    CVar                obj,
    Char *              name )
{
    if ( ! HasInfoCVar( obj, W_BOUND ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_BOUND( %c, \"%s\" )\n", obj, name );
        }
        SetInfoCVar( obj, W_BOUND );
    }
}


/****************************************************************************
**
*F  CompCheckFuncResult( <obj> )  . emit code to check that <obj> has a value
*/
void CompCheckFuncResult (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_BOUND ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_FUNC_RESULT( %c )\n", obj );
        }
        SetInfoCVar( obj, W_BOUND );
    }
}


/****************************************************************************
**
*F  CompCheckIntSmall( <obj> )   emit code to check that <obj> is a small int
*/
void CompCheckIntSmall (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_INT_SMALL ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_INT_SMALL( %c )\n", obj );
        }
        SetInfoCVar( obj, W_INT_SMALL );
    }
}



/****************************************************************************
**
*F  CompCheckIntSmallPos( <obj> ) emit code to check that <obj> is a position
*/
void CompCheckIntSmallPos (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_INT_SMALL_POS ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_INT_SMALL_POS( %c )\n", obj );
        }
        SetInfoCVar( obj, W_INT_SMALL_POS );
    }
}

/****************************************************************************
**
*F  CompCheckIntPos( <obj> ) emit code to check that <obj> is a position
*/
void CompCheckIntPos (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_INT_POS ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_INT_POS( %c )\n", obj );
        }
        SetInfoCVar( obj, W_INT_POS );
    }
}


/****************************************************************************
**
*F  CompCheckBool( <obj> )  . . .  emit code to check that <obj> is a boolean
*/
void CompCheckBool (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_BOOL ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_BOOL( %c )\n", obj );
        }
        SetInfoCVar( obj, W_BOOL );
    }
}



/****************************************************************************
**
*F  CompCheckFunc( <obj> )  . . . emit code to check that <obj> is a function
*/
void CompCheckFunc (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_FUNC ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_FUNC( %c )\n", obj );
        }
        SetInfoCVar( obj, W_FUNC );
    }
}


/****************************************************************************
**

*F * * * * * * * * * * * *  compile expressions * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  CompExpr( <expr> )  . . . . . . . . . . . . . . . . compile an expression
**
**  'CompExpr' compiles the expression <expr> and returns the C variable that
**  will contain the result.
*/
CVar (* CompExprFuncs[256]) ( Expr expr );


CVar CompExpr (
    Expr                expr )
{
    return (* CompExprFuncs[ TNUM_EXPR(expr) ])( expr );
}


/****************************************************************************
**
*F  CompUnknownExpr( <expr> ) . . . . . . . . . . . .  log unknown expression
*/
CVar CompUnknownExpr (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TNUM %d;\n", TNUM_EXPR(expr) );
    return 0;
}



/****************************************************************************
**
*F  CompBoolExpr( <expr> )  . . . . . . . compile bool expr and return C bool
*/
CVar (* CompBoolExprFuncs[256]) ( Expr expr );

CVar CompBoolExpr (
    Expr                expr )
{
    return (* CompBoolExprFuncs[ TNUM_EXPR(expr) ])( expr );
}


/****************************************************************************
**
*F  CompUnknownBool( <expr> ) . . . . . . . . . .  use 'CompExpr' and convert
*/
CVar CompUnknownBool (
    Expr                expr )
{
    CVar                res;            /* result                          */
    CVar                val;            /* value of expression             */

    /* allocate a new temporary for the result                             */
    res = CVAR_TEMP( NewTemp( "res" ) );

    /* compile the expression and check that the value is boolean          */
    val = CompExpr( expr );
    CompCheckBool( val );

    /* emit code to store the C boolean value in the result                */
    Emit( "%c = (Obj)(UInt)(%c != False);\n", res, val );

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( res, W_BOOL );

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( val ) )  FreeTemp( TEMP_CVAR( val ) );

    /* return the result                                                   */
    return res;
}
    
/****************************************************************************
**
*V  G_Length  . . . . . . . . . . . . . . . . . . . . . . . function 'Length'
*/
GVar G_Length;



/****************************************************************************
**
*F  CompFunccall0to6Args( <expr> )  . . . T_FUNCCALL_0ARGS...T_FUNCCALL_6ARGS
*/
extern CVar CompRefGVarFopy (
            Expr                expr );


CVar CompFunccall0to6Args (
    Expr                expr )
{
    CVar                result;         /* result, result                  */
    CVar                func;           /* function                        */
    CVar                args [8];       /* arguments                       */
    Int                 narg;           /* number of arguments             */
    Int                 i;              /* loop variable                   */

    /* special case to inline 'Length'                                     */
    if ( CompFastListFuncs
      && TNUM_EXPR( FUNC_CALL(expr) ) == T_REF_GVAR
      && ADDR_EXPR( FUNC_CALL(expr) )[0] == G_Length
      && NARG_SIZE_CALL(SIZE_EXPR(expr)) == 1 ) {
        result = CVAR_TEMP( NewTemp( "result" ) );
        args[1] = CompExpr( ARGI_CALL(expr,1) );
        if ( CompFastPlainLists ) {
            Emit( "C_LEN_LIST_FPL( %c, %c )\n", result, args[1] );
        }
        else {
            Emit( "C_LEN_LIST( %c, %c )\n", result, args[1] );
        }
        SetInfoCVar( result, W_INT_SMALL );
        if ( IS_TEMP_CVAR( args[1] ) )  FreeTemp( TEMP_CVAR( args[1] ) );
        return result;
    }

    /* allocate a temporary for the result                                 */
    result = CVAR_TEMP( NewTemp( "result" ) );

    /* compile the reference to the function                               */
    if ( TNUM_EXPR( FUNC_CALL(expr) ) == T_REF_GVAR ) {
        func = CompRefGVarFopy( FUNC_CALL(expr) );
    }
    else {
        func = CompExpr( FUNC_CALL(expr) );
        CompCheckFunc( func );
    }

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_EXPR(expr));
    for ( i = 1; i <= narg; i++ ) {
        args[i] = CompExpr( ARGI_CALL(expr,i) );
    }

    /* emit the code for the procedure call                                */
    Emit( "%c = CALL_%dARGS( %c", result, narg, func );
    for ( i = 1; i <= narg; i++ ) {
        Emit( ", %c", args[i] );
    }
    Emit( " );\n" );

    /* emit code for the check (sets the information for the result)       */
    CompCheckFuncResult( result );

    /* free the temporaries                                                */
    for ( i = narg; 1 <= i; i-- ) {
        if ( IS_TEMP_CVAR( args[i] ) )  FreeTemp( TEMP_CVAR( args[i] ) );
    }
    if ( IS_TEMP_CVAR( func ) )  FreeTemp( TEMP_CVAR( func ) );

    /* return the result                                                   */
    return result;
}


/****************************************************************************
**
*F  CompFunccallXArgs( <expr> ) . . . . . . . . . . . . . .  T_FUNCCALL_XARGS
*/
CVar CompFunccallXArgs (
    Expr                expr )
{
    CVar                result;         /* result, result                  */
    CVar                func;           /* function                        */
    CVar                argl;           /* argument list                   */
    CVar                argi;           /* <i>-th argument                 */
    UInt                narg;           /* number of arguments             */
    UInt                i;              /* loop variable                   */

    /* allocate a temporary for the result                                 */
    result = CVAR_TEMP( NewTemp( "result" ) );

    /* compile the reference to the function                               */
    if ( TNUM_EXPR( FUNC_CALL(expr) ) == T_REF_GVAR ) {
        func = CompRefGVarFopy( FUNC_CALL(expr) );
    }
    else {
        func = CompExpr( FUNC_CALL(expr) );
        CompCheckFunc( func );
    }

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_EXPR(expr));
    argl = CVAR_TEMP( NewTemp( "argl" ) );
    Emit( "%c = NEW_PLIST( T_PLIST, %d );\n", argl, narg );
    Emit( "SET_LEN_PLIST( %c, %d );\n", argl, narg );
    for ( i = 1; i <= narg; i++ ) {
        argi = CompExpr( ARGI_CALL( expr, i ) );
        Emit( "SET_ELM_PLIST( %c, %d, %c );\n", argl, i, argi );
        if ( ! HasInfoCVar( argi, W_INT_SMALL ) ) {
            Emit( "CHANGED_BAG( %c );\n", argl );
        }
        if ( IS_TEMP_CVAR( argi ) )  FreeTemp( TEMP_CVAR( argi ) );
    }

    /* emit the code for the procedure call                                */
    Emit( "%c = CALL_XARGS( %c, %c );\n", result, func, argl );

    /* emit code for the check (sets the information for the result)       */
    CompCheckFuncResult( result );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( argl ) )  FreeTemp( TEMP_CVAR( argl ) );
    if ( IS_TEMP_CVAR( func ) )  FreeTemp( TEMP_CVAR( func ) );

    /* return the result                                                   */
    return result;
}

/****************************************************************************
**
*F  CompFunccallXArgs( <expr> ) . . . . . . . . . . . . . .  T_FUNCCALL_OPTS
*/
CVar CompFunccallOpts(
                      Expr expr)
{
  CVar opts = CompExpr(ADDR_STAT(expr)[0]);
  GVar pushOptions;
  GVar popOptions;
  CVar result;
  pushOptions = GVarName("PushOptions");
  popOptions = GVarName("PopOptions");
  CompSetUseGVar(pushOptions, COMP_USE_GVAR_FOPY);
  CompSetUseGVar(popOptions, COMP_USE_GVAR_FOPY);
  Emit("CALL_1ARGS( GF_PushOptions, %c );\n", opts);
  if (IS_TEMP_CVAR( opts) ) FreeTemp( TEMP_CVAR( opts ));
  result = CompExpr(ADDR_STAT(expr)[1]);
  Emit("CALL_0ARGS( GF_PopOptions );\n");
  return result;
}
     

/****************************************************************************
**
*F  CompFuncExpr( <expr> )  . . . . . . . . . . . . . . . . . . . T_FUNC_EXPR
*/
CVar CompFuncExpr (
    Expr                expr )
{
    CVar                func;           /* function, result                */
    CVar                tmp;            /* dummy body                      */

    Obj                 fexs;           /* function expressions list       */
    Obj                 fexp;           /* function expression             */
    Int                 nr;             /* number of the function          */

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
    Emit( "ENVI_FUNC( %c ) = STATE(CurrLVars);\n", func );
    tmp = CVAR_TEMP( NewTemp( "body" ) );
    Emit( "%c = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj) );\n", tmp );
    Emit( "SET_STARTLINE_BODY(%c, INTOBJ_INT(%d));\n", tmp, INT_INTOBJ(GET_STARTLINE_BODY(BODY_FUNC(fexp))));
    Emit( "SET_ENDLINE_BODY(%c, INTOBJ_INT(%d));\n", tmp, INT_INTOBJ(GET_ENDLINE_BODY(BODY_FUNC(fexp))));
    Emit( "SET_FILENAME_BODY(%c, FileName);\n",tmp);
    Emit( "BODY_FUNC(%c) = %c;\n", func, tmp );
    FreeTemp( TEMP_CVAR( tmp ) );

    Emit( "CHANGED_BAG( STATE(CurrLVars) );\n" );

    /* we know that the result is a function                               */
    SetInfoCVar( func, W_FUNC );

    /* return the number of the C variable that will hold the function     */
    return func;
}


/****************************************************************************
**
*F  CompOr( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  T_OR
*/
CVar CompOr (
    Expr                expr )
{
    CVar                val;            /* or, result                      */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */
    Bag                 only_left;      /* info after evaluating only left */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the left expression                                         */
    left = CompBoolExpr( ADDR_EXPR(expr)[0] );
    Emit( "%c = (%c ? True : False);\n", val, left );
    Emit( "if ( %c == False ) {\n", val );
    only_left = NewInfoCVars();
    CopyInfoCVars( only_left, INFO_FEXP(CURR_FUNC) );

    /* compile the right expression                                        */
    right = CompBoolExpr( ADDR_EXPR(expr)[1] );
    Emit( "%c = (%c ? True : False);\n", val, right );
    Emit( "}\n" );

    /* we know that the result is boolean                                  */
    MergeInfoCVars( INFO_FEXP(CURR_FUNC), only_left );
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompOrBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_OR
*/
CVar CompOrBool (
    Expr                expr )
{
    CVar                val;            /* or, result                      */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */
    Bag                 only_left;      /* info after evaluating only left */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the left expression                                         */
    left = CompBoolExpr( ADDR_EXPR(expr)[0] );
    Emit( "%c = %c;\n", val, left );
    Emit( "if ( ! %c ) {\n", val );
    only_left = NewInfoCVars();
    CopyInfoCVars( only_left, INFO_FEXP(CURR_FUNC) );

    /* compile the right expression                                        */
    right = CompBoolExpr( ADDR_EXPR(expr)[1] );
    Emit( "%c = %c;\n", val, right );
    Emit( "}\n" );

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    MergeInfoCVars( INFO_FEXP(CURR_FUNC), only_left );
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompAnd( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . T_AND
*/
CVar CompAnd (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right1;         /* right operand 1                 */
    CVar                right2;         /* right operand 2                 */
    Bag                 only_left;      /* info after evaluating only left */

    /* allocate a temporary for the result                                 */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the left expression                                         */
    left = CompExpr( ADDR_EXPR(expr)[0] );
    only_left = NewInfoCVars();
    CopyInfoCVars( only_left, INFO_FEXP(CURR_FUNC) );

    /* emit the code for the case that the left value is 'false'           */
    Emit( "if ( %c == False ) {\n", left );
    Emit( "%c = %c;\n", val, left );
    Emit( "}\n" );

    /* emit the code for the case that the left value is 'true'            */
    Emit( "else if ( %c == True ) {\n", left );
    right1 = CompExpr( ADDR_EXPR(expr)[1] );
    CompCheckBool( right1 );
    Emit( "%c = %c;\n", val, right1 );
    Emit( "}\n" );

    /* emit the code for the case that the left value is a filter          */
    Emit( "else {\n" );
    CompCheckFunc( left );
    right2 = CompExpr( ADDR_EXPR(expr)[1] );
    CompCheckFunc( right2 );
    Emit( "%c = NewAndFilter( %c, %c );\n", val, left, right2 );
    Emit( "}\n" );

    /* we know precious little about the result                            */
    MergeInfoCVars( INFO_FEXP(CURR_FUNC), only_left );
    SetInfoCVar( val, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right2 ) )  FreeTemp( TEMP_CVAR( right2 ) );
    if ( IS_TEMP_CVAR( right1 ) )  FreeTemp( TEMP_CVAR( right1 ) );
    if ( IS_TEMP_CVAR( left   ) )  FreeTemp( TEMP_CVAR( left   ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompAndBool( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . T_AND
*/
CVar CompAndBool (
    Expr                expr )
{
    CVar                val;            /* or, result                      */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */
    Bag                 only_left;      /* info after evaluating only left */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the left expression                                         */
    left = CompBoolExpr( ADDR_EXPR(expr)[0] );
    Emit( "%c = %c;\n", val, left );
    Emit( "if ( %c ) {\n", val );
    only_left = NewInfoCVars();
    CopyInfoCVars( only_left, INFO_FEXP(CURR_FUNC) );

    /* compile the right expression                                        */
    right = CompBoolExpr( ADDR_EXPR(expr)[1] );
    Emit( "%c = %c;\n", val, right );
    Emit( "}\n" );

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    MergeInfoCVars( INFO_FEXP(CURR_FUNC), only_left );
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompNot( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . T_NOT
*/
CVar CompNot (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* operand                         */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the operand                                                 */
    left = CompBoolExpr( ADDR_EXPR(expr)[0] );

    /* invert the operand                                                  */
    Emit( "%c = (%c ? False : True);\n", val, left );

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( left ) )  FreeTemp( TEMP_CVAR( left ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompNotBoot( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . T_NOT
*/
CVar CompNotBool (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* operand                         */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the operand                                                 */
    left = CompBoolExpr( ADDR_EXPR(expr)[0] );

    /* invert the operand                                                  */
    Emit( "%c = (Obj)(UInt)( ! ((Int)%c) );\n", val, left );

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( left ) )  FreeTemp( TEMP_CVAR( left ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompEq( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  T_EQ
*/
CVar CompEq (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
Emit("%c = ((((Int)%c) == ((Int)%c)) ? True : False);\n", val, left, right);
    }
    else {
        Emit( "%c = (EQ( %c, %c ) ? True : False);\n", val, left, right );
    }

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompEqBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_EQ
*/
CVar CompEqBool (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
        Emit( "%c = (Obj)(UInt)(((Int)%c) == ((Int)%c));\n", val, left, right);
    }
    else {
        Emit( "%c = (Obj)(UInt)(EQ( %c, %c ));\n", val, left, right );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompNe( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  T_NE
*/
CVar CompNe (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
Emit("%c = ((((Int)%c) == ((Int)%c)) ? False : True);\n", val, left, right);
    }
    else {
        Emit( "%c = (EQ( %c, %c ) ? False : True);\n", val, left, right );
    }

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompNeBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_NE
*/
CVar CompNeBool (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
        Emit( "%c = (Obj)(UInt)(((Int)%c) != ((Int)%c));\n", val, left, right );
    }
    else {
        Emit( "%c = (Obj)(UInt)( ! EQ( %c, %c ));\n", val, left, right );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompLt( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  T_LT
*/
CVar CompLt (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
Emit( "%c = ((((Int)%c) < ((Int)%c)) ? True : False);\n", val, left, right );
    }
    else {
        Emit( "%c = (LT( %c, %c ) ? True : False);\n", val, left, right );
    }

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompLtBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_LT
*/
CVar CompLtBool (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
        Emit( "%c = (Obj)(UInt)(((Int)%c) < ((Int)%c));\n", val, left, right );
    }
    else {
        Emit( "%c = (Obj)(UInt)(LT( %c, %c ));\n", val, left, right );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompGe( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  T_GE
*/
CVar CompGe (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
 Emit("%c = ((((Int)%c) < ((Int)%c)) ? False : True);\n", val, left, right);
    }
    else {
        Emit( "%c = (LT( %c, %c ) ? False : True);\n", val, left, right );
    }

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompGeBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_GE
*/
CVar CompGeBool (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
        Emit( "%c = (Obj)(UInt)(((Int)%c) >= ((Int)%c));\n", val, left, right );
    }
    else {
        Emit( "%c = (Obj)(UInt)(! LT( %c, %c ));\n", val, left, right );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompGt( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  T_GT
*/
CVar CompGt (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
 Emit("%c = ((((Int)%c) < ((Int)%c)) ? True : False);\n", val, right, left);
    }
    else {
        Emit( "%c = (LT( %c, %c ) ? True : False);\n", val, right, left );
    }

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompGtBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_GT
*/
CVar CompGtBool (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
        Emit( "%c = (Obj)(UInt)(((Int)%c) < ((Int)%c));\n", val, right, left );
    }
    else {
        Emit( "%c = (Obj)(UInt)(LT( %c, %c ));\n", val, right, left );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompLe( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  T_LE
*/
CVar CompLe (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
Emit("%c = ((((Int)%c) < ((Int)%c)) ?  False : True);\n", val, right, left);
    }
    else {
        Emit( "%c = (LT( %c, %c ) ?  False : True);\n", val, right, left );
    }

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompLeBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_LE
*/
CVar            CompLeBool (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
        Emit( "%c = (Obj)(UInt)(((Int)%c) >= ((Int)%c));\n", val, right, left );
    }
    else {
        Emit( "%c = (Obj)(UInt)(! LT( %c, %c ));\n", val, right, left );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompIn( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  T_IN
*/
CVar CompIn (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    Emit( "%c = (IN( %c, %c ) ?  True : False);\n", val, left, right );

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompInBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_IN
*/
CVar CompInBool (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    Emit( "%c = (Obj)(UInt)(IN( %c, %c ));\n", val, left, right );

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompSum( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . T_SUM
*/
CVar CompSum (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
        Emit( "C_SUM_INTOBJS( %c, %c, %c )\n", val, left, right );
    }
    else if ( CompFastIntArith ) {
        Emit( "C_SUM_FIA( %c, %c, %c )\n", val, left, right );
    }
    else {
        Emit( "C_SUM( %c, %c, %c )\n", val, left, right );
    }

    /* set the information for the result                                  */
    if ( HasInfoCVar(left,W_INT) && HasInfoCVar(right,W_INT) ) {
        SetInfoCVar( val, W_INT );
    }
    else {
        SetInfoCVar( val, W_BOUND );
    }

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompAInv( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_AINV
*/
CVar CompAInv (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the operands                                                */
    left  = CompExpr( ADDR_EXPR(expr)[0] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) ) {
        Emit( "C_AINV_INTOBJS( %c, %c )\n", val, left );
    }
    else if ( CompFastIntArith ) {
        Emit( "C_AINV_FIA( %c, %c )\n", val, left );
    }
    else {
        Emit( "C_AINV( %c, %c )\n", val, left );
    }

    /* set the information for the result                                  */
    if ( HasInfoCVar(left,W_INT) ) {
        SetInfoCVar( val, W_INT );
    }
    else {
        SetInfoCVar( val, W_BOUND );
    }

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompDiff( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_DIFF
*/
CVar CompDiff (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
        Emit( "C_DIFF_INTOBJS( %c, %c, %c )\n", val, left, right );
    }
    else if ( CompFastIntArith ) {
        Emit( "C_DIFF_FIA( %c, %c, %c )\n", val, left, right );
    }
    else {
        Emit( "C_DIFF( %c, %c, %c )\n", val, left, right );
    }

    /* set the information for the result                                  */
    if ( HasInfoCVar(left,W_INT) && HasInfoCVar(right,W_INT) ) {
        SetInfoCVar( val, W_INT );
    }
    else {
        SetInfoCVar( val, W_BOUND );
    }

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompProd( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  T_PROD
*/
CVar CompProd (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    if ( HasInfoCVar(left,W_INT_SMALL) && HasInfoCVar(right,W_INT_SMALL) ) {
        Emit( "C_PROD_INTOBJS( %c, %c, %c )\n", val, left, right );
    }
    else if ( CompFastIntArith ) {
        Emit( "C_PROD_FIA( %c, %c, %c )\n", val, left, right );
    }
    else {
        Emit( "C_PROD( %c, %c, %c )\n", val, left, right );
    }

    /* set the information for the result                                  */
    if ( HasInfoCVar(left,W_INT) && HasInfoCVar(right,W_INT) ) {
        SetInfoCVar( val, W_INT );
    }
    else {
        SetInfoCVar( val, W_BOUND );
    }

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompInv( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . T_INV
**
** C_INV is not defined, so I guess this never gets called SL
**
*/
CVar CompInv (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the operands                                                */
    left  = CompExpr( ADDR_EXPR(expr)[0] );

    /* emit the code                                                       */
    Emit( "C_INV( %c, %c )\n", val, left );

    /* set the information for the result                                  */
    SetInfoCVar( val, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompQuo( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . T_QUO
*/
CVar CompQuo (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    Emit( "%c = QUO( %c, %c );\n", val, left, right );

    /* set the information for the result                                  */
    SetInfoCVar( val, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompMod( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . T_MOD
*/
CVar CompMod (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    Emit( "%c = MOD( %c, %c );\n", val, left, right );

    /* set the information for the result                                  */
    if ( HasInfoCVar(left,W_INT) && HasInfoCVar(right,W_INT) ) {
        SetInfoCVar( val, W_INT );
    }
    else {
        SetInfoCVar( val, W_BOUND );
    }

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompPow( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . T_POW
*/
CVar CompPow (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( ADDR_EXPR(expr)[0] );
    right = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code                                                       */
    Emit( "%c = POW( %c, %c );\n", val, left, right );

    /* set the information for the result                                  */
    if ( HasInfoCVar(left,W_INT) && HasInfoCVar(right,W_INT) ) {
        SetInfoCVar( val, W_INT );
    }
    else {
        SetInfoCVar( val, W_BOUND );
    }

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}


/****************************************************************************
**
*F  CompIntExpr( <expr> ) . . . . . . . . . . . . . . .  T_INTEXPR/T_INT_EXPR
*
* This is complicated by the need to produce code that will compile correctly
* in 32 or 64 bit and with or without GMP.
*
* The problem is that when we compile the code, we know the integer representation
* of the stored literal in the compiling process
* but NOT the representation which will apply to the compiled code or the endianness
*
* The solution to this is macros: C_MAKE_INTEGER_BAG( size, type) 
*                                 C_SET_LIMB2(bag, limbnumber, value)
*                                 C_SET_LIMB4(bag, limbnumber, value)
*                                 C_SET_LIMB8(bag, limbnumber, value)
*
* we compile using the one appropriate for the compiling system, but their
* definition depends on the limb size of the target system.
*
*/

CVar CompIntExpr (
    Expr                expr )
{
    CVar                val;
    Int                 siz;
    Int                 i;
    UInt                typ;

    if ( IS_INTEXPR(expr) ) {
        return CVAR_INTG( INT_INTEXPR(expr) );
    }
    else {
        val = CVAR_TEMP( NewTemp( "val" ) );
        siz = SIZE_EXPR(expr) - sizeof(UInt);
        typ = *(UInt *)ADDR_EXPR(expr);
        Emit( "%c = C_MAKE_INTEGER_BAG(%d, %d);\n",val, siz, typ);
        if ( typ == T_INTPOS ) {
            SetInfoCVar(val, W_INT_POS);
        }
        else {
            SetInfoCVar(val, W_INT);
        }

        for ( i = 0; i < siz/INTEGER_UNIT_SIZE; i++ ) {
#if INTEGER_UNIT_SIZE == 2
            Emit( "C_SET_LIMB2( %c, %d, %d);\n",val, i, ((UInt2 *)((UInt *)ADDR_EXPR(expr) + 1))[i]);
#elif INTEGER_UNIT_SIZE == 4
            Emit( "C_SET_LIMB4( %c, %d, %dL);\n",val, i, ((UInt4 *)((UInt *)ADDR_EXPR(expr) + 1))[i]);
#elif INTEGER_UNIT_SIZE == 8
            Emit( "C_SET_LIMB8( %c, %d, %dLL);\n",val, i, ((UInt8*)((UInt *)ADDR_EXPR(expr) + 1))[i]);
#else
            #error unsupported INTEGER_UNIT_SIZE
#endif
        }
        if (siz <= 8)
            Emit("%c = C_NORMALIZE_64BIT(%c);\n", val,val);
        return val;
    }
}

/****************************************************************************
**
*F  CompTildeExpr( <expr> )  . . . . . . . . . . . . . . . . . . T_TILDE_EXPR
*/
CVar CompTildeExpr (
    Expr                expr )
{
    Emit( "if ( ! STATE(Tilde) ) {\n");
    Emit( "    ErrorMayQuit(\"'~' does not have a value here\",0L,0L);\n" );
    Emit( "}\n" );
    CVar                val;            /* value, result                   */

    /* allocate a new temporary for the 'true' value                       */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code                                                       */
    Emit( "%c = STATE(Tilde);\n", val );

    /* return '~'                                                       */
    return val;
}

/****************************************************************************
**
*F  CompTrueExpr( <expr> )  . . . . . . . . . . . . . . . . . . . T_TRUE_EXPR
*/
CVar CompTrueExpr (
    Expr                expr )
{
    CVar                val;            /* value, result                   */

    /* allocate a new temporary for the 'true' value                       */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code                                                       */
    Emit( "%c = True;\n", val );

    /* we know that the result is boolean ;-)                              */
    SetInfoCVar( val, W_BOOL );

    /* return 'true'                                                       */
    return val;
}


/****************************************************************************
**
*F  CompFalseExpr( <expr> ) . . . . . . . . . . . . . . . . . .  T_FALSE_EXPR
*/
CVar CompFalseExpr (
    Expr                expr )
{
    CVar                val;            /* value, result                   */

    /* allocate a new temporary for the 'false' value                      */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code                                                       */
    Emit( "%c = False;\n", val );

    /* we know that the result is boolean ;-)                              */
    SetInfoCVar( val, W_BOOL );

    /* return 'false'                                                      */
    return val;
}


/****************************************************************************
**
*F  CompCharExpr( <expr> )  . . . . . . . . . . . . . . . . . . . T_CHAR_EXPR
*/
CVar            CompCharExpr (
    Expr                expr )
{
    CVar                val;            /* result                          */

    /* allocate a new temporary for the char value                         */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code                                                       */
    Emit( "%c = ObjsChar[%d];\n", val, (Int)(((UChar*)ADDR_EXPR(expr))[0]));

    /* we know that we have a value                                        */
    SetInfoCVar( val, W_BOUND );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  CompPermExpr( <expr> )  . . . . . . . . . . . . . . . . . . . T_PERM_EXPR
*/
CVar CompPermExpr (
    Expr                expr )
{
    CVar                perm;           /* result                          */
    CVar                lcyc;           /* one cycle as list               */
    CVar                lprm;           /* perm as list of list cycles     */
    CVar                val;            /* one point                       */
    Int                 i;
    Int                 j;
    Int                 n;
    Int                 csize;
    Expr                cycle;

    /* check for the identity                                              */
    if ( SIZE_EXPR(expr) == 0 ) {
        perm = CVAR_TEMP( NewTemp( "idperm" ) );
        Emit( "%c = IdentityPerm;\n", perm );
        SetInfoCVar( perm, W_BOUND );
        return perm;
    }

    /* for each cycle create a list                                        */
    perm = CVAR_TEMP( NewTemp( "perm" ) );
    lcyc = CVAR_TEMP( NewTemp( "lcyc" ) );
    lprm = CVAR_TEMP( NewTemp( "lprm" ) );

    /* start with the identity permutation                                 */
    Emit( "%c = IdentityPerm;\n", perm );

    /* loop over the cycles                                                */
    n = SIZE_EXPR(expr)/sizeof(Expr);
    Emit( "%c = NEW_PLIST( T_PLIST, %d );\n", lprm, n );
    Emit( "SET_LEN_PLIST( %c, %d );\n", lprm, n );

    for ( i = 1;  i <= n;  i++ ) {
        cycle = ADDR_EXPR(expr)[i-1];
        csize = SIZE_EXPR(cycle)/sizeof(Expr);
        Emit( "%c = NEW_PLIST( T_PLIST, %d );\n", lcyc, csize );
        Emit( "SET_LEN_PLIST( %c, %d );\n", lcyc, csize );
        Emit( "SET_ELM_PLIST( %c, %d, %c );\n", lprm, i, lcyc );
        Emit( "CHANGED_BAG( %c );\n", lprm );

        /* loop over the entries of the cycle                              */
        for ( j = 1;  j <= csize;  j++ ) {
            val = CompExpr( ADDR_EXPR(cycle)[j-1] );
            Emit( "SET_ELM_PLIST( %c, %d, %c );\n", lcyc, j, val );
            Emit( "CHANGED_BAG( %c );\n", lcyc );
            if ( IS_TEMP_CVAR(val) )  FreeTemp( TEMP_CVAR(val) );
        }
    }
    Emit( "%c = Array2Perm( %c );\n", perm, lprm );

    /* free the termporaries                                               */
    FreeTemp( TEMP_CVAR(lprm) );
    FreeTemp( TEMP_CVAR(lcyc) );

    return perm;
}


/****************************************************************************
**
*F  CompListExpr( <expr> )  . . . . . . . . . . . . . . . . . . . T_LIST_EXPR
*/
extern CVar CompListExpr1 ( Expr expr );
extern void CompListExpr2 ( CVar list, Expr expr );
extern CVar CompRecExpr1 ( Expr expr );
extern void CompRecExpr2 ( CVar rec, Expr expr );

CVar CompListExpr (
    Expr                expr )
{
    CVar                list;           /* list, result                    */

    /* compile the list expression                                         */
    list = CompListExpr1( expr );
    CompListExpr2( list, expr );

    /* return the result                                                   */
    return list;
}


/****************************************************************************
**
*F  CompListTildeExpr( <expr> ) . . . . . . . . . . . . . .  T_LIST_TILD_EXPR
*/
CVar CompListTildeExpr (
    Expr                expr )
{
    CVar                list;           /* list value, result              */
    CVar                tilde;          /* old value of tilde              */

    /* remember the old value of '~'                                       */
    tilde = CVAR_TEMP( NewTemp( "tilde" ) );
    Emit( "%c = STATE( Tilde );\n", tilde );

    /* create the list value                                               */
    list = CompListExpr1( expr );

    /* assign the list to '~'                                              */
    Emit( "STATE(Tilde) = %c;\n", list );

    /* evaluate the subexpressions into the list value                     */
    CompListExpr2( list, expr );

    /* restore old value of '~'                                            */
    Emit( "STATE(Tilde) = %c;\n", tilde );
    if ( IS_TEMP_CVAR( tilde ) )  FreeTemp( TEMP_CVAR( tilde ) );

    /* return the list value                                               */
    return list;
}


/****************************************************************************
**
*F  CompListExpr1( <expr> ) . . . . . . . . . . . . . . . . . . . . . . local
*/
CVar CompListExpr1 (
    Expr                expr )
{
    CVar                list;           /* list, result                    */
    Int                 len;            /* logical length of the list      */

    /* get the length of the list                                          */
    len = SIZE_EXPR( expr ) / sizeof(Expr);

    /* allocate a temporary for the list                                   */
    list = CVAR_TEMP( NewTemp( "list" ) );

    /* emit the code to make the list                                      */
    Emit( "%c = NEW_PLIST( T_PLIST, %d );\n", list, len );
    Emit( "SET_LEN_PLIST( %c, %d );\n", list, len );

    /* we know that <list> is a list                                       */
    SetInfoCVar( list, W_LIST );

    /* return the list                                                     */
    return list;
}


/****************************************************************************
**
*F  CompListExpr2( <list>, <expr> ) . . . . . . . . . . . . . . . . . . local
*/
void CompListExpr2 (
    CVar                list,
    Expr                expr )
{
    CVar                sub;            /* subexpression                   */
    Int                 len;            /* logical length of the list      */
    Int                 i;              /* loop variable                   */

    /* get the length of the list                                          */
    len = SIZE_EXPR( expr ) / sizeof(Expr);

    /* emit the code to fill the list                                      */
    for ( i = 1; i <= len; i++ ) {

        /* if the subexpression is empty                                   */
        if ( ADDR_EXPR(expr)[i-1] == 0 ) {
            continue;
        }

        /* special case if subexpression is a list expression              */
        else if ( TNUM_EXPR( ADDR_EXPR(expr)[i-1] ) == T_LIST_EXPR ) {
            sub = CompListExpr1( ADDR_EXPR(expr)[i-1] );
            Emit( "SET_ELM_PLIST( %c, %d, %c );\n", list, i, sub );
            Emit( "CHANGED_BAG( %c );\n", list );
            CompListExpr2( sub, ADDR_EXPR(expr)[i-1] );
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* special case if subexpression is a record expression            */
        else if ( TNUM_EXPR( ADDR_EXPR(expr)[i-1] ) == T_REC_EXPR ) {
            sub = CompRecExpr1( ADDR_EXPR(expr)[i-1] );
            Emit( "SET_ELM_PLIST( %c, %d, %c );\n", list, i, sub );
            Emit( "CHANGED_BAG( %c );\n", list );
            CompRecExpr2( sub, ADDR_EXPR(expr)[i-1] );
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* general case                                                    */
        else {
            sub = CompExpr( ADDR_EXPR(expr)[i-1] );
            Emit( "SET_ELM_PLIST( %c, %d, %c );\n", list, i, sub );
            if ( ! HasInfoCVar( sub, W_INT_SMALL ) ) {
                Emit( "CHANGED_BAG( %c );\n", list );
            }
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

    }

}


/****************************************************************************
**
*F  CompRangeExpr( <expr> ) . . . . . . . . . . . . . . . . . .  T_RANGE_EXPR
*/
CVar CompRangeExpr (
    Expr                expr )
{
    CVar                range;          /* range, result                   */
    CVar                first;          /* first  element                  */
    CVar                second;         /* second element                  */
    CVar                last;           /* last   element                  */

    /* allocate a new temporary for the range                              */
    range = CVAR_TEMP( NewTemp( "range" ) );

    /* evaluate the expressions                                            */
    if ( SIZE_EXPR(expr) == 2 * sizeof(Expr) ) {
        first  = CompExpr( ADDR_EXPR(expr)[0] );
        second = 0;
        last   = CompExpr( ADDR_EXPR(expr)[1] );
    }
    else {
        first  = CompExpr( ADDR_EXPR(expr)[0] );
        second = CompExpr( ADDR_EXPR(expr)[1] );
        last   = CompExpr( ADDR_EXPR(expr)[2] );
    }

    /* emit the code                                                       */
    if ( SIZE_EXPR(expr) == 2 * sizeof(Expr) ) {
        Emit( "%c = Range2Check( %c, %c );\n",
              range, first, last );
    }
    else {
        Emit( "%c = Range3Check( %c, %c, %c );\n",
              range, first, second, last );
    }

    /* we know that the result is a list                                   */
    SetInfoCVar( range, W_LIST );

    /* free the temporaries                                                */
    if ( SIZE_EXPR(expr) == 2 * sizeof(Expr) ) {
        if ( IS_TEMP_CVAR( last   ) )  FreeTemp( TEMP_CVAR( last   ) );
        if ( IS_TEMP_CVAR( first  ) )  FreeTemp( TEMP_CVAR( first  ) );
    }
    else {
        if ( IS_TEMP_CVAR( last   ) )  FreeTemp( TEMP_CVAR( last   ) );
        if ( IS_TEMP_CVAR( second ) )  FreeTemp( TEMP_CVAR( second ) );
        if ( IS_TEMP_CVAR( first  ) )  FreeTemp( TEMP_CVAR( first  ) );
    }

    /* return the range                                                    */
    return range;
}


/****************************************************************************
**
*F  CompStringExpr( <expr> )  . . . . . . . . . . compile a string expression
*/
CVar CompStringExpr (
    Expr                expr )
{
    CVar                string;         /* string value, result            */

    /* allocate a new temporary for the string                             */
    string = CVAR_TEMP( NewTemp( "string" ) );

    /* create the string and copy the stuff                                */
    Emit( "C_NEW_STRING( %c, %d, \"%C\" );\n",

          /* the sizeof(UInt) offset is to get past the length of the string
             which is now stored in the front of the literal */
          string, SIZE_EXPR(expr)-1-sizeof(UInt),
          sizeof(UInt)+ (Char*)ADDR_EXPR(expr) );

    /* we know that the result is a list                                   */
    SetInfoCVar( string, W_LIST );

    /* return the string                                                   */
    return string;
}


/****************************************************************************
**
*F  CompRecExpr( <expr> ) . . . . . . . . . . . . . . . . . . . .  T_REC_EXPR
*/
CVar CompRecExpr (
    Expr                expr )
{
    CVar                rec;            /* record value, result            */

    /* compile the record expression                                       */
    rec = CompRecExpr1( expr );
    CompRecExpr2( rec, expr );

    /* return the result                                                   */
    return rec;
}


/****************************************************************************
**
*F  CompRecTildeExpr( <expr> )  . . . . . . . . . . . . . . . T_REC_TILD_EXPR
*/
CVar CompRecTildeExpr (
    Expr                expr )
{
    CVar                rec;            /* record value, result            */
    CVar                tilde;          /* old value of tilde              */

    /* remember the old value of '~'                                       */
    tilde = CVAR_TEMP( NewTemp( "tilde" ) );
    Emit( "%c = STATE( Tilde );\n", tilde );

    /* create the record value                                             */
    rec = CompRecExpr1( expr );

    /* assign the record value to the variable '~'                         */
    Emit( "STATE( Tilde ) = %c;\n", rec );

    /* evaluate the subexpressions into the record value                   */
    CompRecExpr2( rec, expr );

    /* restore the old value of '~'                                        */
    Emit( "STATE( Tilde ) = %c;\n", tilde );
    if ( IS_TEMP_CVAR( tilde ) )  FreeTemp( TEMP_CVAR( tilde ) );

    /* return the record value                                             */
    return rec;
}


/****************************************************************************
**
*F  CompRecExpr1( <expr> )  . . . . . . . . . . . . . . . . . . . . . . local
*/
CVar CompRecExpr1 (
    Expr                expr )
{
    CVar                rec;            /* record value, result            */
    Int                 len;            /* number of components            */

    /* get the number of components                                        */
    len = SIZE_EXPR( expr ) / (2*sizeof(Expr));

    /* allocate a new temporary for the record                             */
    rec = CVAR_TEMP( NewTemp( "rec" ) );

    /* emit the code to allocate the new record object                     */
    Emit( "%c = NEW_PREC( %d );\n", rec, len );

    /* we know that we have a value                                        */
    SetInfoCVar( rec, W_BOUND );

    /* return the record                                                   */
    return rec;
}


/****************************************************************************
**
*F  CompRecExpr2( <rec>, <expr> ) . . . . . . . . . . . . . . . . . . . local
*/
void            CompRecExpr2 (
    CVar                rec,
    Expr                expr )
{
    CVar                rnam;           /* name of component               */
    CVar                sub;            /* value of subexpression          */
    Int                 len;            /* number of components            */
    Expr                tmp;            /* temporary variable              */
    Int                 i;              /* loop variable                   */

    /* get the number of components                                        */
    len = SIZE_EXPR( expr ) / (2*sizeof(Expr));

    /* handle the subexpressions                                           */
    for ( i = 1; i <= len; i++ ) {

        /* handle the name                                                 */
        tmp = ADDR_EXPR(expr)[2*i-2];
        rnam = CVAR_TEMP( NewTemp( "rnam" ) );
        if ( IS_INTEXPR(tmp) ) {
            CompSetUseRNam( (UInt)INT_INTEXPR(tmp), COMP_USE_RNAM_ID );
            Emit( "%c = (Obj)R_%n;\n",
                  rnam, NAME_RNAM((UInt)INT_INTEXPR(tmp)) );
        }
        else {
            sub = CompExpr( tmp );
            Emit( "%c = (Obj)RNamObj( %c );\n", rnam, sub );
        }

        /* if the subexpression is empty (cannot happen for records)       */
        tmp = ADDR_EXPR(expr)[2*i-1];
        if ( tmp == 0 ) {
            if ( IS_TEMP_CVAR( rnam ) )  FreeTemp( TEMP_CVAR( rnam ) );
            continue;
        }

        /* special case if subexpression is a list expression             */
        else if ( TNUM_EXPR( tmp ) == T_LIST_EXPR ) {
            sub = CompListExpr1( tmp );
            Emit( "AssPRec( %c, (UInt)%c, %c );\n", rec, rnam, sub );
            CompListExpr2( sub, tmp );
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* special case if subexpression is a record expression            */
        else if ( TNUM_EXPR( tmp ) == T_REC_EXPR ) {
            sub = CompRecExpr1( tmp );
            Emit( "AssPRec( %c, (UInt)%c, %c );\n", rec, rnam, sub );
            CompRecExpr2( sub, tmp );
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* general case                                                    */
        else {
            sub = CompExpr( tmp );
            Emit( "AssPRec( %c, (UInt)%c, %c );\n", rec, rnam, sub );
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        if ( IS_TEMP_CVAR( rnam ) )  FreeTemp( TEMP_CVAR( rnam ) );
    }
    Emit( "SortPRecRNam( %c, 0 );\n", rec );

}


/****************************************************************************
**
*F  CompRefLVar( <expr> ) . . . . . . .  T_REFLVAR
*/
CVar CompRefLVar (
    Expr                expr )
{
    CVar                val;            /* value, result                   */
    LVar                lvar;           /* local variable                  */

    /* get the local variable                                              */
    if ( IS_REFLVAR(expr) ) {
        lvar = LVAR_REFLVAR(expr);
    }
    else {
        lvar = (LVar)(ADDR_EXPR(expr)[0]);
    }

    /* emit the code to get the value                                      */
    if ( CompGetUseHVar( lvar ) ) {
        val = CVAR_TEMP( NewTemp( "val" ) );
        Emit( "%c = OBJ_LVAR( %d );\n", val, GetIndxHVar(lvar) );
    }
    else {
        val = CVAR_LVAR(lvar);
    }

    /* emit code to check that the variable has a value                    */
    CompCheckBound( val, NAME_LVAR(lvar) );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  CompIsbLVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  T_ISB_LVAR
*/
CVar CompIsbLVar (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                val;            /* value                           */
    LVar                lvar;           /* local variable                  */

    /* get the local variable                                              */
    lvar = (LVar)(ADDR_EXPR(expr)[0]);

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* emit the code to get the value                                      */
    if ( CompGetUseHVar( lvar ) ) {
        val = CVAR_TEMP( NewTemp( "val" ) );
        Emit( "%c = OBJ_LVAR( %d );\n", val, GetIndxHVar(lvar) );
    }
    else {
        val = CVAR_LVAR(lvar);
    }

    /* emit the code to check that the variable has a value                */
    Emit( "%c = ((%c != 0) ? True : False);\n", isb, val );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( val ) )  FreeTemp( TEMP_CVAR( val ) );

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  CompRefHVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  T_REF_HVAR
*/
CVar CompRefHVar (
    Expr                expr )
{
    CVar                val;            /* value, result                   */
    HVar                hvar;           /* higher variable                 */

    /* get the higher variable                                             */
    hvar = (HVar)(ADDR_EXPR(expr)[0]);
    CompSetUseHVar( hvar );

    /* allocate a new temporary for the value                              */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code to get the value                                      */
    Emit( "%c = OBJ_LVAR_%dUP( %d );\n",
          val, GetLevlHVar(hvar), GetIndxHVar(hvar) );

    /* emit the code to check that the variable has a value                */
    CompCheckBound( val, NAME_HVAR(hvar) );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  CompIsbHVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  T_ISB_HVAR
*/
CVar CompIsbHVar (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                val;            /* value                           */
    HVar                hvar;           /* higher variable                 */

    /* get the higher variable                                             */
    hvar = (HVar)(ADDR_EXPR(expr)[0]);
    CompSetUseHVar( hvar );

    /* allocate new temporaries for the value and the result               */
    val = CVAR_TEMP( NewTemp( "val" ) );
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* emit the code to get the value                                      */
    Emit( "%c = OBJ_LVAR_%dUP( %d );\n",
          val, GetLevlHVar(hvar), GetIndxHVar(hvar) );

    /* emit the code to check that the variable has a value                */
    Emit( "%c = ((%c != 0) ? True : False);\n", isb, val );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( val ) )  FreeTemp( TEMP_CVAR( val ) );

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  CompRefGVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  T_REF_GVAR
*/
CVar CompRefGVar (
    Expr                expr )
{
    CVar                val;            /* value, result                   */
    GVar                gvar;           /* higher variable                 */

    /* get the global variable                                             */
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    CompSetUseGVar( gvar, COMP_USE_GVAR_COPY );

    /* allocate a new global variable for the value                        */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code to get the value                                      */
    Emit( "%c = GC_%n;\n", val, NameGVar(gvar) );

    /* emit the code to check that the variable has a value                */
    CompCheckBound( val, NameGVar(gvar) );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  CompRefGVarFopy( <expr> ) . . . . . . . . . . . . . . . . . . . . . local
*/
CVar CompRefGVarFopy (
    Expr                expr )
{
    CVar                val;            /* value, result                   */
    GVar                gvar;           /* higher variable                 */

    /* get the global variable                                             */
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    CompSetUseGVar( gvar, COMP_USE_GVAR_FOPY );

    /* allocate a new temporary for the value                              */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code to get the value                                      */
    Emit( "%c = GF_%n;\n", val, NameGVar(gvar) );

    /* we know that the object in a function copy is a function            */
    SetInfoCVar( val, W_FUNC );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  CompIsbGVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  T_ISB_GVAR
*/
CVar CompIsbGVar (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                val;            /* value, result                   */
    GVar                gvar;           /* higher variable                 */

    /* get the global variable                                             */
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    CompSetUseGVar( gvar, COMP_USE_GVAR_COPY );

    /* allocate new temporaries for the value and the result               */
    isb = CVAR_TEMP( NewTemp( "isb" ) );
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code to get the value                                      */
    Emit( "%c = GC_%n;\n", val, NameGVar(gvar) );

    /* emit the code to check that the variable has a value                */
    Emit( "%c = ((%c != 0) ? True : False);\n", isb, val );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( val ) )  FreeTemp( TEMP_CVAR( val ) );

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  CompElmList( <expr> ) . . . . . . . . . . . . . . . . . . . .  T_ELM_LIST
*/
CVar CompElmList (
    Expr                expr )
{
    CVar                elm;            /* element, result                 */
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the list expression (checking is done by 'ELM_LIST')        */
    list = CompExpr( ADDR_EXPR(expr)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_EXPR(expr)[1] );
    CompCheckIntPos( pos );

    /* emit the code to get the element                                    */
    if (        CompCheckListElements &&   CompFastPlainLists ) {
        Emit( "C_ELM_LIST_FPL( %c, %c, %c )\n", elm, list, pos );
    }
    else if (   CompCheckListElements && ! CompFastPlainLists ) {
        Emit( "C_ELM_LIST( %c, %c, %c );\n", elm, list, pos );
    }
    else if ( ! CompCheckListElements &&   CompFastPlainLists ) {
        Emit( "C_ELM_LIST_NLE_FPL( %c, %c, %c );\n", elm, list, pos );
    }
    else {
        Emit( "C_ELM_LIST_NLE( %c, %c, %c );\n", elm, list, pos );
    }

    /* we know that we have a value                                        */
    SetInfoCVar( elm, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  CompElmsList( <expr> )  . . . . . . . . . . . . . . . . . . . T_ELMS_LIST
*/
CVar CompElmsList (
    Expr                expr )
{
    CVar                elms;           /* elements, result                */
    CVar                list;           /* list                            */
    CVar                poss;           /* positions                       */

    /* allocate a new temporary for the elements                           */
    elms = CVAR_TEMP( NewTemp( "elms" ) );

    /* compile the list expression (checking is done by 'ElmsListCheck')   */
    list = CompExpr( ADDR_EXPR(expr)[0] );

    /* compile the position expression (checking done by 'ElmsListCheck')  */
    poss = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code to get the element                                    */
    Emit( "%c = ElmsListCheck( %c, %c );\n", elms, list, poss );

    /* we know that the elements are a list                                */
    SetInfoCVar( elms, W_LIST );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( poss ) )  FreeTemp( TEMP_CVAR( poss ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );

    /* return the elements                                                 */
    return elms;
}


/****************************************************************************
**
*F  CompElmListLev( <expr> )  . . . . . . . . . . . . . . . .  T_ELM_LIST_LEV
*/
CVar CompElmListLev (
    Expr                expr )
{
    CVar                lists;          /* lists                           */
    CVar                pos;            /* position                        */
    Int                 level;          /* level                           */

    /* compile the lists expression                                        */
    lists = CompExpr( ADDR_EXPR(expr)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_EXPR(expr)[1] );
    CompCheckIntSmallPos( pos );

    /* get the level                                                       */
    level = (Int)(ADDR_EXPR(expr)[2]);

    /* emit the code to select the elements from several lists (to <lists>)*/
    Emit( "ElmListLevel( %c, %c, %d );\n", lists, pos, level );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos   ) )  FreeTemp( TEMP_CVAR( pos   ) );

    /* return the lists                                                    */
    return lists;
}


/****************************************************************************
**
*F  CompElmsListLev( <expr> ) . . . . . . . . . . . . . . . . T_ELMS_LIST_LEV
*/
CVar CompElmsListLev (
    Expr                expr )
{
    CVar                lists;          /* lists                           */
    CVar                poss;           /* positions                       */
    Int                 level;          /* level                           */

    /* compile the lists expression                                        */
    lists = CompExpr( ADDR_EXPR(expr)[0] );

    /* compile the position expression (checking done by 'ElmsListLevel')  */
    poss = CompExpr( ADDR_EXPR(expr)[1] );

    /* get the level                                                       */
    level = (Int)(ADDR_EXPR(expr)[2]);

    /* emit the code to select the elements from several lists (to <lists>)*/
    Emit( "ElmsListLevelCheck( %c, %c, %d );\n", lists, poss, level );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( poss  ) )  FreeTemp( TEMP_CVAR( poss  ) );

    /* return the lists                                                    */
    return lists;
}


/****************************************************************************
**
*F  CompIsbList( <expr> ) . . . . . . . . . . . . . . . . . . . .  T_ISB_LIST
*/
CVar CompIsbList (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the list expression (checking is done by 'ISB_LIST')        */
    list = CompExpr( ADDR_EXPR(expr)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_EXPR(expr)[1] );
    CompCheckIntPos( pos );

    /* emit the code to test the element                                   */
    Emit( "%c = C_ISB_LIST( %c, %c );\n", isb, list, pos );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );

    /* return the element                                                  */
    return isb;
}


/****************************************************************************
**
*F  CompElmRecName( <expr> )  . . . . . . . . . . . . . . . .  T_ELM_REC_NAME
*/
CVar CompElmRecName (
    Expr                expr )
{
    CVar                elm;            /* element, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the record expression (checking is done by 'ELM_REC')       */
    record = CompExpr( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = (UInt)(ADDR_EXPR(expr)[1]);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code to select the element of the record                   */
    Emit( "%c = ELM_REC( %c, R_%n );\n", elm, record, NAME_RNAM(rnam) );

    /* we know that we have a value                                        */
    SetInfoCVar( elm, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  CompElmRecExpr( <expr> )  . . . . . . . . . . . . . . . .  T_ELM_REC_EXPR
*/
CVar CompElmRecExpr (
    Expr                expr )
{
    CVar                elm;            /* element, result                 */
    CVar                record;         /* the record, left operand        */
    CVar                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the record expression (checking is done by 'ELM_REC')       */
    record = CompExpr( ADDR_EXPR(expr)[0] );

    /* compile the record name expression                                  */
    rnam = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code to select the element of the record                   */
    Emit( "%c = ELM_REC( %c, RNamObj(%c) );\n", elm, record, rnam );

    /* we know that we have a value                                        */
    SetInfoCVar( elm, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  CompIsbRecName( <expr> )  . . . . . . . . . . . . . . . .  T_ISB_REC_NAME
*/
CVar CompIsbRecName (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the record expression (checking is done by 'ISB_REC')       */
    record = CompExpr( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = (UInt)(ADDR_EXPR(expr)[1]);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code to test the element                                   */
    Emit( "%c = (ISB_REC( %c, R_%n ) ? True : False);\n",
          isb, record, NAME_RNAM(rnam) );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  CompIsbRecExpr( <expr> )  . . . . . . . . . . . . . . . .  T_ISB_REC_EXPR
*/
CVar CompIsbRecExpr (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                record;         /* the record, left operand        */
    CVar                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the record expression (checking is done by 'ISB_REC')       */
    record = CompExpr( ADDR_EXPR(expr)[0] );

    /* compile the record name expression                                  */
    rnam = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code to test the element                                   */
    Emit( "%c = (ISB_REC( %c, RNamObj(%c) ) ? True : False);\n",
          isb, record, rnam );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  CompElmPosObj( <expr> ) . . . . . . . . . . . . . . . . . .  T_ELM_POSOBJ
*/
CVar CompElmPosObj (
    Expr                expr )
{
    CVar                elm;            /* element, result                 */
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the list expression (checking is done by 'ELM_LIST')        */
    list = CompExpr( ADDR_EXPR(expr)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_EXPR(expr)[1] );
    CompCheckIntSmallPos( pos );

    /* emit the code to get the element                                    */
    if (        CompCheckPosObjElements ) {
        Emit( "C_ELM_POSOBJ( %c, %c, %i )\n", elm, list, pos );
    }
    else if ( ! CompCheckPosObjElements ) {
        Emit( "C_ELM_POSOBJ_NLE( %c, %c, %i );\n", elm, list, pos );
    }

    /* we know that we have a value                                        */
    SetInfoCVar( elm, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  CompElmsPosObj( <expr> )  . . . . . . . . . . . . . . . . . T_ELMS_POSOBJ
*/
CVar CompElmsPosObj (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TNUM %d;\n", TNUM_EXPR(expr) );
    return 0;
}


/****************************************************************************
**
*F  CompElmPosObjLev( <expr> )  . . . . . . . . . . . . . .  T_ELM_POSOBJ_LEV
*/
CVar CompElmPosObjLev (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TNUM %d;\n", TNUM_EXPR(expr) );
    return 0;
}


/****************************************************************************
**
*F  CompElmsPosObjLev( <expr> ) . . . . . . . . . . . . . . . . T_ELMS_POSOBJ
*/
CVar CompElmsPosObjLev (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TNUM %d;\n", TNUM_EXPR(expr) );
    return 0;
}


/****************************************************************************
**
*F  CompIsbPosObj( <expr> ) . . . . . . . . . . . . . . . . . .  T_ISB_POSOBJ
*/
CVar CompIsbPosObj (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the list expression (checking is done by 'ISB_LIST')        */
    list = CompExpr( ADDR_EXPR(expr)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_EXPR(expr)[1] );
    CompCheckIntSmallPos( pos );

    /* emit the code to test the element                                   */
    Emit( "if ( TNUM_OBJ(%c) == T_POSOBJ ) {\n", list );
    Emit( "%c = (%i <= SIZE_OBJ(%c)/sizeof(Obj)-1\n", isb, pos, list );
    Emit( "   && ELM_PLIST(%c,%i) != 0 ? True : False);\n", list, pos );
    Emit( "#ifdef HPCGAP\n" );
    Emit( "} else if ( TNUM_OBJ(%c) == T_APOSOBJ ) {\n", list );
    Emit( "%c = Elm0AList(%c,%i) != 0 ? True : False;\n", isb, list, pos );
    Emit( "#endif\n" );
    Emit( "}\nelse {\n" );
    Emit( "%c = (ISB_LIST( %c, %i ) ? True : False);\n", isb, list, pos );
    Emit( "}\n" );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );

    /* return the element                                                  */
    return isb;
}


/****************************************************************************
**
*F  CompElmObjName( <expr> )  . . . . . . . . . . . . . . . T_ELM_COMOBJ_NAME
*/
CVar CompElmComObjName (
    Expr                expr )
{
    CVar                elm;            /* element, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the record expression (checking is done by 'ELM_REC')       */
    record = CompExpr( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = (UInt)(ADDR_EXPR(expr)[1]);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code to select the element of the record                   */
    Emit( "if ( TNUM_OBJ(%c) == T_COMOBJ ) {\n", record );
    Emit( "%c = ElmPRec( %c, R_%n );\n", elm, record, NAME_RNAM(rnam) );
    Emit( "#ifdef HPCGAP\n" );
    Emit( "} else if ( TNUM_OBJ(%c) == T_ACOMOBJ) {\n", record );
    Emit( "%c = ElmARecord( %c, R_%n );\n", elm, record, NAME_RNAM(rnam) );
    Emit( "#endif\n" );
    Emit( "}\nelse {\n" );
    Emit( "%c = ELM_REC( %c, R_%n );\n", elm, record, NAME_RNAM(rnam) );
    Emit( "}\n" );

    /* we know that we have a value                                        */
    SetInfoCVar( elm, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    /* return the element                                                  */
    return elm;
}



/****************************************************************************
**
*F  CompElmComObjExpr( <expr> ) . . . . . . . . . . . . . . T_ELM_COMOBJ_EXPR
*/
CVar CompElmComObjExpr (
    Expr                expr )
{
    CVar                elm;            /* element, result                 */
    CVar                record;         /* the record, left operand        */
    CVar                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the record expression (checking is done by 'ELM_REC')       */
    record = CompExpr( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code to select the element of the record                   */
    Emit( "if ( TNUM_OBJ(%c) == T_COMOBJ ) {\n", record );
    Emit( "%c = ElmPRec( %c, RNamObj(%c) );\n", elm, record, rnam );
    Emit( "#ifdef HPCGAP\n" );
    Emit( "} else if ( TNUM_OBJ(%c) == T_ACOMOBJ ) {\n", record );
    Emit( "%c = ElmARecord( %c, RNamObj(%c) );\n", elm, record, rnam );
    Emit( "#endif\n" );
    Emit( "}\nelse {\n" );
    Emit( "%c = ELM_REC( %c, RNamObj(%c) );\n", elm, record, rnam );
    Emit( "}\n" );

    /* we know that we have a value                                        */
    SetInfoCVar( elm, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  CompIsbComObjName( <expr> ) . . . . . . . . . . . . . . T_ISB_COMOBJ_NAME
*/
CVar CompIsbComObjName (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the record expression (checking is done by 'ISB_REC')       */
    record = CompExpr( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = (UInt)(ADDR_EXPR(expr)[1]);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code to test the element                                   */
    Emit( "if ( TNUM_OBJ(%c) == T_COMOBJ ) {\n", record );
    Emit( "%c = (IsbPRec( %c, R_%n ) ? True : False);\n",
          isb, record, NAME_RNAM(rnam) );
    Emit( "#ifdef HPCGAP\n" );
    Emit( "} else if ( TNUM_OBJ(%c) == T_ACOMOBJ ) {\n", record );
    Emit( "%c = (IsbARecord( %c, R_%n ) ? True : False);\n",
                isb, record, NAME_RNAM(rnam) );
    Emit( "#endif\n" );
    Emit( "}\nelse {\n" );
    Emit( "%c = (ISB_REC( %c, R_%n ) ? True : False);\n",
          isb, record, NAME_RNAM(rnam) );
    Emit( "}\n" );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**
*F  CompIsbComObjExpr( <expr> ) . . . . . . . . . . . . . . T_ISB_COMOBJ_EXPR
*/
CVar CompIsbComObjExpr (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the record expression (checking is done by 'ISB_REC')       */
    record = CompExpr( ADDR_EXPR(expr)[0] );

    /* get the name (stored immediately in the expression)                 */
    rnam = CompExpr( ADDR_EXPR(expr)[1] );

    /* emit the code to test the element                                   */
    Emit( "if ( TNUM_OBJ(%c) == T_COMOBJ ) {\n", record );
    Emit( "%c = (IsbPRec( %c, RNamObj(%c) ) ? True : False);\n",
          isb, record, rnam );
    Emit( "#ifdef HPCGAP\n" );
    Emit( "} else if ( TNUM_OBJ(%c) == T_ACOMOBJ ) {\n", record );
    Emit( "%c = (IsbARecord( %c, RNamObj(%c) ) ? True : False);\n",
                isb, record, rnam );
    Emit( "#endif\n" );
    Emit( "}\nelse {\n" );
    Emit( "%c = (ISB_REC( %c, RNamObj(%c) ) ? True : False);\n",
          isb, record, rnam );
    Emit( "}\n" );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    /* return the result                                                   */
    return isb;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * compile statements * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  CompStat( <stat> )  . . . . . . . . . . . . . . . . . compile a statement
**
**  'CompStat' compiles the statement <stat>.
*/
void (* CompStatFuncs[256]) ( Stat stat );

void CompStat (
    Stat                stat )
{
    (* CompStatFuncs[ TNUM_STAT(stat) ])( stat );
}


/****************************************************************************
**
*F  CompUnknownStat( <stat> ) . . . . . . . . . . . . . . . . signal an error
*/
void CompUnknownStat (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TNUM %d;\n", TNUM_STAT(stat) );
}


/****************************************************************************
**
*V  G_Add . . . . . . . . . . . . . . . . . . . . . . . . . .  function 'Add'
*/
GVar G_Add;


/****************************************************************************
**
*F  CompProccall0to6Args( <stat> )  . . . T_PROCCALL_0ARGS...T_PROCCALL_6ARGS
*/
void CompProccall0to6Args (
    Stat                stat )
{
    CVar                func;           /* function                        */
    CVar                args[8];        /* arguments                       */
    UInt                narg;           /* number of arguments             */
    UInt                i;              /* loop variable                   */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* special case to inline 'Add'                                        */
    if ( CompFastListFuncs
      && TNUM_EXPR( FUNC_CALL(stat) ) == T_REF_GVAR
      && ADDR_EXPR( FUNC_CALL(stat) )[0] == G_Add
      && NARG_SIZE_CALL(SIZE_EXPR(stat)) == 2 ) {
        args[1] = CompExpr( ARGI_CALL(stat,1) );
        args[2] = CompExpr( ARGI_CALL(stat,2) );
        if ( CompFastPlainLists ) {
            Emit( "C_ADD_LIST_FPL( %c, %c )\n", args[1], args[2] );
        }
        else {
            Emit( "C_ADD_LIST( %c, %c )\n", args[1], args[2] );
        }
        if ( IS_TEMP_CVAR( args[2] ) )  FreeTemp( TEMP_CVAR( args[2] ) );
        if ( IS_TEMP_CVAR( args[1] ) )  FreeTemp( TEMP_CVAR( args[1] ) );
        return;
    }

    /* compile the reference to the function                               */
    if ( TNUM_EXPR( FUNC_CALL(stat) ) == T_REF_GVAR ) {
        func = CompRefGVarFopy( FUNC_CALL(stat) );
    }
    else {
        func = CompExpr( FUNC_CALL(stat) );
        CompCheckFunc( func );
    }

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_STAT(stat));
    for ( i = 1; i <= narg; i++ ) {
        args[i] = CompExpr( ARGI_CALL(stat,i) );
    }

    /* emit the code for the procedure call                                */
    Emit( "CALL_%dARGS( %c", narg, func );
    for ( i = 1; i <= narg; i++ ) {
        Emit( ", %c", args[i] );
    }
    Emit( " );\n" );

    /* free the temporaries                                                */
    for ( i = narg; 1 <= i; i-- ) {
        if ( IS_TEMP_CVAR( args[i] ) )  FreeTemp( TEMP_CVAR( args[i] ) );
    }
    if ( IS_TEMP_CVAR( func ) )  FreeTemp( TEMP_CVAR( func ) );
}


/****************************************************************************
**
*F  CompProccallXArgs . . . . . . . . . . . . . . . . . . .  T_PROCCALL_XARGS
*/
void CompProccallXArgs (
    Stat                stat )
{
    CVar                func;           /* function                        */
    CVar                argl;           /* argument list                   */
    CVar                argi;           /* <i>-th argument                 */
    UInt                narg;           /* number of arguments             */
    UInt                i;              /* loop variable                   */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the reference to the function                               */
    if ( TNUM_EXPR( FUNC_CALL(stat) ) == T_REF_GVAR ) {
        func = CompRefGVarFopy( FUNC_CALL(stat) );
    }
    else {
        func = CompExpr( FUNC_CALL(stat) );
        CompCheckFunc( func );
    }

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_STAT(stat));
    argl = CVAR_TEMP( NewTemp( "argl" ) );
    Emit( "%c = NEW_PLIST( T_PLIST, %d );\n", argl, narg );
    Emit( "SET_LEN_PLIST( %c, %d );\n", argl, narg );
    for ( i = 1; i <= narg; i++ ) {
        argi = CompExpr( ARGI_CALL( stat, i ) );
        Emit( "SET_ELM_PLIST( %c, %d, %c );\n", argl, i, argi );
        if ( ! HasInfoCVar( argi, W_INT_SMALL ) ) {
            Emit( "CHANGED_BAG( %c );\n", argl );
        }
        if ( IS_TEMP_CVAR( argi ) )  FreeTemp( TEMP_CVAR( argi ) );
    }

    /* emit the code for the procedure call                                */
    Emit( "CALL_XARGS( %c, %c );\n", func, argl );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( argl ) )  FreeTemp( TEMP_CVAR( argl ) );
    if ( IS_TEMP_CVAR( func ) )  FreeTemp( TEMP_CVAR( func ) );
}

/****************************************************************************
**
*F  CompProccallXArgs( <expr> ) . . . . . . . . . . . . . .  T_PROCCALL_OPTS
*/
void CompProccallOpts(
                      Stat stat)
{
  CVar opts = CompExpr(ADDR_STAT(stat)[0]);
  GVar pushOptions;
  GVar popOptions;
  pushOptions = GVarName("PushOptions");
  popOptions = GVarName("PopOptions");
  CompSetUseGVar(pushOptions, COMP_USE_GVAR_FOPY);
  CompSetUseGVar(popOptions, COMP_USE_GVAR_FOPY);
  Emit("CALL_1ARGS( GF_PushOptions, %c );\n", opts);
  if (IS_TEMP_CVAR( opts) ) FreeTemp( TEMP_CVAR( opts ));
  CompStat(ADDR_STAT(stat)[1]);
  Emit("CALL_0ARGS( GF_PopOptions );\n");
}
     

/****************************************************************************
**
*F  CompSeqStat( <stat> ) . . . . . . . . . . . . .  T_SEQ_STAT...T_SEQ_STAT7
*/
void CompSeqStat (
    Stat                stat )
{
    UInt                nr;             /* number of statements            */
    UInt                i;              /* loop variable                   */

    /* get the number of statements                                        */
    nr = SIZE_STAT( stat ) / sizeof(Stat);

    /* compile the statements                                              */
    for ( i = 1; i <= nr; i++ ) {
        CompStat( ADDR_STAT( stat )[i-1] );
    }
}


/****************************************************************************
**
*F  CompIf( <stat> )  . . . . . . . . T_IF/T_IF_ELSE/T_IF_ELIF/T_IF_ELIF_ELSE
*/
void CompIf (
    Stat                stat )
{
    CVar                cond;           /* condition                       */
    UInt                nr;             /* number of branches              */
    Bag                 info_in;        /* information at branch begin     */
    Bag                 info_out;       /* information at branch end       */
    UInt                i;              /* loop variable                   */

    /* get the number of branches                                          */
    nr = SIZE_STAT( stat ) / (2*sizeof(Stat));

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* if " );
        PrintExpr( ADDR_STAT(stat)[0] );
        Emit( " then */\n" );
    }

    /* compile the expression                                              */
    cond = CompBoolExpr( ADDR_STAT( stat )[0] );

    /* emit the code to test the condition                                 */
    Emit( "if ( %c ) {\n", cond );
    if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );

    /* remember what we know after evaluating the first condition          */
    info_in = NewInfoCVars();
    CopyInfoCVars( info_in, INFO_FEXP(CURR_FUNC) );

    /* compile the body                                                    */
    CompStat( ADDR_STAT( stat )[1] );

    /* remember what we know after executing the first body                */
    info_out = NewInfoCVars();
    CopyInfoCVars( info_out, INFO_FEXP(CURR_FUNC) );

    /* emit the rest code                                                  */
    Emit( "\n}\n" );

    /* loop over the 'elif' branches                                       */
    for ( i = 2; i <= nr; i++ ) {

        /* do not handle 'else' branch here                                */
        if ( i == nr && TNUM_EXPR(ADDR_STAT(stat)[2*(i-1)]) == T_TRUE_EXPR )
            break;

        /* print a comment                                                 */
        if ( CompPass == 2 ) {
            Emit( "\n/* elif " );
            PrintExpr( ADDR_STAT(stat)[2*(i-1)] );
            Emit( " then */\n" );
        }

        /* emit the 'else' to connect this branch to the 'if' branch       */
        Emit( "else {\n" );

        /* this is what we know if we enter this branch                    */
        CopyInfoCVars( INFO_FEXP(CURR_FUNC), info_in );

        /* compile the expression                                          */
        cond = CompBoolExpr( ADDR_STAT( stat )[2*(i-1)] );

        /* emit the code to test the condition                             */
        Emit( "if ( %c ) {\n", cond );
        if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );

        /* remember what we know after evaluating all previous conditions  */
        CopyInfoCVars( info_in, INFO_FEXP(CURR_FUNC) );

        /* compile the body                                                */
        CompStat( ADDR_STAT( stat )[2*(i-1)+1] );

        /* remember what we know after executing one of the previous bodies*/
        MergeInfoCVars( info_out, INFO_FEXP(CURR_FUNC) );

        /* emit the rest code                                              */
        Emit( "\n}\n" );

    }

    /* handle 'else' branch                                                */
    if ( i == nr ) {

        /* print a comment                                                 */
        if ( CompPass == 2 ) {
            Emit( "\n/* else */\n" );
        }

        /* emit the 'else' to connect this branch to the 'if' branch       */
        Emit( "else {\n" );

        /* this is what we know if we enter this branch                    */
        CopyInfoCVars( INFO_FEXP(CURR_FUNC), info_in );

        /* compile the body                                                */
        CompStat( ADDR_STAT( stat )[2*(i-1)+1] );

        /* remember what we know after executing one of the previous bodies*/
        MergeInfoCVars( info_out, INFO_FEXP(CURR_FUNC) );

        /* emit the rest code                                              */
        Emit( "\n}\n" );

    }

    /* fake empty 'else' branch                                            */
    else {

        /* this is what we know if we enter this branch                    */
        CopyInfoCVars( INFO_FEXP(CURR_FUNC), info_in );

        /* remember what we know after executing one of the previous bodies*/
        MergeInfoCVars( info_out, INFO_FEXP(CURR_FUNC) );

    }

    /* close all unbalanced parenthesis                                    */
    for ( i = 2; i <= nr; i++ ) {
        if ( i == nr && TNUM_EXPR(ADDR_STAT(stat)[2*(i-1)]) == T_TRUE_EXPR )
            break;
        Emit( "}\n" );
    }
    Emit( "/* fi */\n" );

    /* put what we know into the current info                              */
    CopyInfoCVars( INFO_FEXP(CURR_FUNC), info_out );

}


/****************************************************************************
**
*F  CompFor( <stat> ) . . . . . . . T_FOR...T_FOR3/T_FOR_RANGE...T_FOR_RANGE3
*/
void CompFor (
    Stat                stat )
{
    UInt                var;            /* loop variable                   */
    Char                vart;           /* variable type                   */
    CVar                list;           /* list to loop over               */
    CVar                islist;         /* is the list a proper list       */
    CVar                first;          /* first loop index                */
    CVar                last;           /* last  loop index                */
    CVar                lidx;           /* loop index variable             */
    CVar                elm;            /* element of list                 */
    Int                 pass;           /* current pass                    */
    Bag                 prev;           /* previous temp-info              */
    Int                 i;              /* loop variable                   */

    /* handle 'for <lvar> in [<first>..<last>] do'                         */
    if ( IS_REFLVAR( ADDR_STAT(stat)[0] )
      && ! CompGetUseHVar( LVAR_REFLVAR( ADDR_STAT(stat)[0] ) )
      && TNUM_EXPR( ADDR_STAT(stat)[1] ) == T_RANGE_EXPR
      && SIZE_EXPR( ADDR_STAT(stat)[1] ) == 2*sizeof(Expr) ) {

        /* print a comment                                                 */
        if ( CompPass == 2 ) {
            Emit( "\n/* for " );
            PrintExpr( ADDR_STAT(stat)[0] );
            Emit( " in " );
            PrintExpr( ADDR_STAT(stat)[1] );
            Emit( " do */\n" );
        }

        /* get the local variable                                          */
        var = LVAR_REFLVAR( ADDR_STAT(stat)[0] );

        /* allocate a new temporary for the loop variable                  */
        lidx = CVAR_TEMP( NewTemp( "lidx" ) );

        /* compile and check the first and last value                      */
        first = CompExpr( ADDR_EXPR( ADDR_STAT(stat)[1] )[0] );
        CompCheckIntSmall( first );

        /* compile and check the last value                                */
        /* if the last value is in a local variable,                       */
        /* we must copy it into a temporary,                               */
        /* because the local variable may change its value in the body     */
        last  = CompExpr( ADDR_EXPR( ADDR_STAT(stat)[1] )[1] );
        CompCheckIntSmall( last  );
        if ( IS_LVAR_CVAR(last) ) {
            elm = CVAR_TEMP( NewTemp( "last" ) );
            Emit( "%c = %c;\n", elm, last );
            last = elm;
        }

        /* find the invariant temp-info                                    */
        pass = CompPass;
        CompPass = 99;
        prev = NewInfoCVars();
        do {
            CopyInfoCVars( prev, INFO_FEXP(CURR_FUNC) );
            if ( HasInfoCVar( first, W_INT_SMALL_POS ) ) {
                SetInfoCVar( CVAR_LVAR(var), W_INT_SMALL_POS );
            }
            else {
                SetInfoCVar( CVAR_LVAR(var), W_INT_SMALL );
            }
            for ( i = 2; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
                CompStat( ADDR_STAT(stat)[i] );
            }
            MergeInfoCVars( INFO_FEXP(CURR_FUNC), prev );
        } while ( ! IsEqInfoCVars( INFO_FEXP(CURR_FUNC), prev ) );
        CompPass = pass;

        /* emit the code for the loop                                      */
        Emit( "for ( %c = %c;\n",                lidx, first );
        Emit( "      ((Int)%c) <= ((Int)%c);\n", lidx, last  );
        Emit( "      %c = (Obj)(((UInt)%c)+4) ", lidx, lidx  );
        Emit( ") {\n" );

        /* emit the code to copy the loop index into the loop variable     */
        Emit( "%c = %c;\n", CVAR_LVAR(var), lidx );

        /* set what we know about the loop variable                        */
        if ( HasInfoCVar( first, W_INT_SMALL_POS ) ) {
            SetInfoCVar( CVAR_LVAR(var), W_INT_SMALL_POS );
        }
        else {
            SetInfoCVar( CVAR_LVAR(var), W_INT_SMALL );
        }

        /* compile the body                                                */
        for ( i = 2; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
            CompStat( ADDR_STAT(stat)[i] );
        }

        /* emit the end code                                               */
        Emit( "\n}\n" );
        Emit( "/* od */\n" );

        /* free the temporaries                                            */
        if ( IS_TEMP_CVAR( last  ) )  FreeTemp( TEMP_CVAR( last  ) );
        if ( IS_TEMP_CVAR( first ) )  FreeTemp( TEMP_CVAR( first ) );
        if ( IS_TEMP_CVAR( lidx  ) )  FreeTemp( TEMP_CVAR( lidx  ) );

    }

    /* handle other loops                                                  */
    else {

        /* print a comment                                                 */
        if ( CompPass == 2 ) {
            Emit( "\n/* for " );
            PrintExpr( ADDR_STAT(stat)[0] );
            Emit( " in " );
            PrintExpr( ADDR_STAT(stat)[1] );
            Emit( " do */\n" );
        }

        /* get the variable (initialize them first to please 'lint')       */
        if ( IS_REFLVAR( ADDR_STAT(stat)[0] )
          && ! CompGetUseHVar( LVAR_REFLVAR( ADDR_STAT(stat)[0] ) ) ) {
            var = LVAR_REFLVAR( ADDR_STAT(stat)[0] );
            vart = 'l';
        }
        else if ( IS_REFLVAR( ADDR_STAT(stat)[0] ) ) {
            var = LVAR_REFLVAR( ADDR_STAT(stat)[0] );
            vart = 'm';
        }
        else if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_HVAR ) {
            var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
            vart = 'h';
        }
        else /* if ( TNUM_EXPR( ADDR_STAT(stat)[0] ) == T_REF_GVAR ) */ {
            var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
            CompSetUseGVar( var, COMP_USE_GVAR_ID );
            vart = 'g';
        }

        /* allocate a new temporary for the loop variable                  */
        lidx   = CVAR_TEMP( NewTemp( "lidx"   ) );
        elm    = CVAR_TEMP( NewTemp( "elm"    ) );
        islist = CVAR_TEMP( NewTemp( "islist" ) );

        /* compile and check the first and last value                      */
        list = CompExpr( ADDR_STAT(stat)[1] );

        /* SL Patch added to try and avoid a bug */
        if (IS_LVAR_CVAR(list))
          {
            CVar copylist;
            copylist = CVAR_TEMP( NewTemp( "copylist" ) );
            Emit("%c = %c;\n",copylist, list);
            list = copylist;
          }
        /* end of SL patch */

        /* find the invariant temp-info                                    */
        pass = CompPass;
        CompPass = 99;
        prev = NewInfoCVars();
        do {
            CopyInfoCVars( prev, INFO_FEXP(CURR_FUNC) );
            if ( vart == 'l' ) {
                SetInfoCVar( CVAR_LVAR(var), W_BOUND );
            }
            for ( i = 2; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
                CompStat( ADDR_STAT(stat)[i] );
            }
            MergeInfoCVars( INFO_FEXP(CURR_FUNC), prev );
        } while ( ! IsEqInfoCVars( INFO_FEXP(CURR_FUNC), prev ) );
        CompPass = pass;

        /* emit the code for the loop                                      */
        /* (plenty ugly because of iterator handling)                      */
        Emit( "if ( IS_SMALL_LIST(%c) ) {\n", list );
        Emit( "%c = (Obj)(UInt)1;\n", islist );
        Emit( "%c = INTOBJ_INT(1);\n", lidx );
        Emit( "}\n" );
        Emit( "else {\n" );
        Emit( "%c = (Obj)(UInt)0;\n", islist );
        Emit( "%c = CALL_1ARGS( GF_ITERATOR, %c );\n", lidx, list );
        Emit( "}\n" );
        Emit( "while ( 1 ) {\n" );
        Emit( "if ( %c ) {\n", islist );
        Emit( "if ( LEN_LIST(%c) < %i )  break;\n", list, lidx );
        Emit( "%c = ELMV0_LIST( %c, %i );\n", elm, list, lidx );
        Emit( "%c = (Obj)(((UInt)%c)+4);\n", lidx, lidx );
        Emit( "if ( %c == 0 )  continue;\n", elm );
        Emit( "}\n" );
        Emit( "else {\n" );
        Emit( "if ( CALL_1ARGS( GF_IS_DONE_ITER, %c ) != False )  break;\n",
              lidx );
        Emit( "%c = CALL_1ARGS( GF_NEXT_ITER, %c );\n", elm, lidx );
        Emit( "}\n" );

        /* emit the code to copy the loop index into the loop variable     */
        if ( vart == 'l' ) {
            Emit( "%c = %c;\n",
                  CVAR_LVAR(var), elm );
        }
        else if ( vart == 'm' ) {
            Emit( "ASS_LVAR( %d, %c );\n",
                  GetIndxHVar(var), elm );
        }
        else if ( vart == 'h' ) {
            Emit( "ASS_LVAR_%dUP( %d, %c );\n",
                  GetLevlHVar(var), GetIndxHVar(var), elm );
        }
        else if ( vart == 'g' ) {
            Emit( "AssGVar( G_%n, %c );\n",
                  NameGVar(var), elm );
        }

        /* set what we know about the loop variable                        */
        if ( vart == 'l' ) {
            SetInfoCVar( CVAR_LVAR(var), W_BOUND );
        }

        /* compile the body                                                */
        for ( i = 2; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
            CompStat( ADDR_STAT(stat)[i] );
        }

        /* emit the end code                                               */
        Emit( "\n}\n" );
        Emit( "/* od */\n" );

        /* free the temporaries                                            */
        if ( IS_TEMP_CVAR( list   ) )  FreeTemp( TEMP_CVAR( list   ) );
        if ( IS_TEMP_CVAR( islist ) )  FreeTemp( TEMP_CVAR( islist ) );
        if ( IS_TEMP_CVAR( elm    ) )  FreeTemp( TEMP_CVAR( elm    ) );
        if ( IS_TEMP_CVAR( lidx   ) )  FreeTemp( TEMP_CVAR( lidx   ) );

    }

}


/****************************************************************************
**
*F  CompWhile( <stat> ) . . . . . . . . . . . . . . . . .  T_WHILE...T_WHILE3
*/
void CompWhile (
    Stat                stat )
{
    CVar                cond;           /* condition                       */
    Int                 pass;           /* current pass                    */
    Bag                 prev;           /* previous temp-info              */
    UInt                i;              /* loop variable                   */

    /* find an invariant temp-info                                         */
    /* the emits are probably not needed                                   */
    pass = CompPass;
    CompPass = 99;
    Emit( "while ( 1 ) {\n" );
    prev = NewInfoCVars();
    do {
        CopyInfoCVars( prev, INFO_FEXP(CURR_FUNC) );
        cond = CompBoolExpr( ADDR_STAT(stat)[0] );
        Emit( "if ( ! %c ) break;\n", cond );
        if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );
        for ( i = 1; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
            CompStat( ADDR_STAT(stat)[i] );
        }
        MergeInfoCVars( INFO_FEXP(CURR_FUNC), prev );
    } while ( ! IsEqInfoCVars( INFO_FEXP(CURR_FUNC), prev ) );
    Emit( "}\n" );
    CompPass = pass;

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* while " );
        PrintExpr( ADDR_STAT(stat)[0] );
        Emit( " od */\n" );
    }

    /* emit the code for the loop                                          */
    Emit( "while ( 1 ) {\n" );

    /* compile the condition                                               */
    cond = CompBoolExpr( ADDR_STAT(stat)[0] );
    Emit( "if ( ! %c ) break;\n", cond );
    if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );

    /* compile the body                                                    */
    for ( i = 1; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
        CompStat( ADDR_STAT(stat)[i] );
    }

    /* thats it                                                            */
    Emit( "\n}\n" );
    Emit( "/* od */\n" );

}


/****************************************************************************
**
*F  CompRepeat( <stat> )  . . . . . . . . . . . . . . .  T_REPEAT...T_REPEAT3
*/
void CompRepeat (
    Stat                stat )
{
    CVar                cond;           /* condition                       */
    Int                 pass;           /* current pass                    */
    Bag                 prev;           /* previous temp-info              */
    UInt                i;              /* loop variable                   */

    /* find an invariant temp-info                                         */
    /* the emits are probably not needed                                   */
    pass = CompPass;
    CompPass = 99;
    Emit( "do {\n" );
    prev = NewInfoCVars();
    do {
        CopyInfoCVars( prev, INFO_FEXP(CURR_FUNC) );
        for ( i = 1; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
            CompStat( ADDR_STAT(stat)[i] );
        }
        cond = CompBoolExpr( ADDR_STAT(stat)[0] );
        Emit( "if ( %c ) break;\n", cond );
        if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );
        MergeInfoCVars( INFO_FEXP(CURR_FUNC), prev );
    } while ( ! IsEqInfoCVars( INFO_FEXP(CURR_FUNC), prev ) );
    Emit( "} while ( 1 );\n" );
    CompPass = pass;

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* repeat */\n" );
    }

    /* emit the code for the loop                                          */
    Emit( "do {\n" );

    /* compile the body                                                    */
    for ( i = 1; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
        CompStat( ADDR_STAT(stat)[i] );
    }

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* until " );
        PrintExpr( ADDR_STAT(stat)[0] );
        Emit( " */\n" );
    }

    /* compile the condition                                               */
    cond = CompBoolExpr( ADDR_STAT(stat)[0] );
    Emit( "if ( %c ) break;\n", cond );
    if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );

    /* thats it                                                            */
    Emit( "} while ( 1 );\n" );
}


/****************************************************************************
**
*F  CompBreak( <stat> ) . . . . . . . . . . . . . . . . . . . . . . . T_BREAK
*/
void CompBreak (
    Stat                stat )
{
    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    Emit( "break;\n" );
}

/****************************************************************************
**
*F  CompContinue( <stat> ) . . . . . . . . . . . . . . . . . . . . T_CONTINUE
*/
void CompContinue (
    Stat                stat )
{
    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    Emit( "continue;\n" );
}


/****************************************************************************
**
*F  CompReturnObj( <stat> ) . . . . . . . . . . . . . . . . . .  T_RETURN_OBJ
*/
void CompReturnObj (
    Stat                stat )
{
    CVar                obj;            /* returned object                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the expression                                              */
    obj = CompExpr( ADDR_STAT(stat)[0] );

    /* emit code to remove stack frame                                     */
    Emit( "RES_BRK_CURR_STAT();\n" );
    Emit( "SWITCH_TO_OLD_FRAME(oldFrame);\n" );

    /* emit code to return from function                                   */
    Emit( "return %c;\n", obj );

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( obj ) )  FreeTemp( TEMP_CVAR( obj ) );
}


/****************************************************************************
**
*F  CompReturnVoid( <stat> )  . . . . . . . . . . . . . . . . . T_RETURN_VOID
*/
void CompReturnVoid (
    Stat                stat )
{
    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* emit code to remove stack frame                                     */
    Emit( "RES_BRK_CURR_STAT();\n");
    Emit( "SWITCH_TO_OLD_FRAME(oldFrame);\n" );

    /* emit code to return from function                                   */
    Emit( "return 0;\n" );
}


/****************************************************************************
**
*F  CompAssLVar( <stat> ) . . . . . . . . . . . .  T_ASS_LVAR...T_ASS_LVAR_16
*/
void            CompAssLVar (
    Stat                stat )
{
    LVar                lvar;           /* local variable                  */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the right hand side expression                              */
    rhs = CompExpr( ADDR_STAT(stat)[1] );

    /* emit the code for the assignment                                    */
    lvar = (LVar)(ADDR_STAT(stat)[0]);
    if ( CompGetUseHVar( lvar ) ) {
        Emit( "ASS_LVAR( %d, %c );\n", GetIndxHVar(lvar), rhs );
    }
    else {
        Emit( "%c = %c;\n", CVAR_LVAR(lvar), rhs );
        SetInfoCVar( CVAR_LVAR(lvar), GetInfoCVar( rhs ) );
    }

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( rhs ) )  FreeTemp( TEMP_CVAR( rhs ) );
}


/****************************************************************************
**
*F  CompUnbLVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  T_UNB_LVAR
*/
void CompUnbLVar (
    Stat                stat )
{
    LVar                lvar;           /* local variable                  */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* emit the code for the assignment                                    */
    lvar = (LVar)(ADDR_STAT(stat)[0]);
    if ( CompGetUseHVar( lvar ) ) {
        Emit( "ASS_LVAR( %d, 0 );\n", GetIndxHVar(lvar) );
    }
    else {
        Emit( "%c = 0;\n", CVAR_LVAR( lvar ) );
        SetInfoCVar( lvar, W_UNBOUND );
    }
}


/****************************************************************************
**
*F  CompAssHVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  T_ASS_HVAR
*/
void CompAssHVar (
    Stat                stat )
{
    HVar                hvar;           /* higher variable                 */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the right hand side expression                              */
    rhs = CompExpr( ADDR_STAT(stat)[1] );

    /* emit the code for the assignment                                    */
    hvar = (HVar)(ADDR_STAT(stat)[0]);
    CompSetUseHVar( hvar );
    Emit( "ASS_LVAR_%dUP( %d, %c );\n",
          GetLevlHVar(hvar), GetIndxHVar(hvar), rhs );

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( rhs ) )  FreeTemp( TEMP_CVAR( rhs ) );
}


/****************************************************************************
**
*F  CompUnbHVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  T_UNB_HVAR
*/
void CompUnbHVar (
    Stat                stat )
{
    HVar                hvar;           /* higher variable                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* emit the code for the assignment                                    */
    hvar = (HVar)(ADDR_STAT(stat)[0]);
    CompSetUseHVar( hvar );
    Emit( "ASS_LVAR_%dUP( %d, 0 );\n",
          GetLevlHVar(hvar), GetIndxHVar(hvar) );
}


/****************************************************************************
**
*F  CompAssGVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  T_ASS_GVAR
*/
void CompAssGVar (
    Stat                stat )
{
    GVar                gvar;           /* global variable                 */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the right hand side expression                              */
    rhs = CompExpr( ADDR_STAT(stat)[1] );

    /* emit the code for the assignment                                    */
    gvar = (GVar)(ADDR_STAT(stat)[0]);
    CompSetUseGVar( gvar, COMP_USE_GVAR_ID );
    Emit( "AssGVar( G_%n, %c );\n", NameGVar(gvar), rhs );

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( rhs ) )  FreeTemp( TEMP_CVAR( rhs ) );
}


/****************************************************************************
**
*F  CompUnbGVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  T_UNB_GVAR
*/
void            CompUnbGVar (
    Stat                stat )
{
    GVar                gvar;           /* global variable                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* emit the code for the assignment                                    */
    gvar = (GVar)(ADDR_STAT(stat)[0]);
    CompSetUseGVar( gvar, COMP_USE_GVAR_ID );
    Emit( "AssGVar( G_%n, 0 );\n", NameGVar(gvar) );
}


/****************************************************************************
**
*F  CompAssList( <stat> ) . . . . . . . . . . . . . . . . . . . .  T_ASS_LIST
*/
void CompAssList (
    Stat                stat )
{
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_STAT(stat)[1] );
    CompCheckIntPos( pos );

    /* compile the right hand side                                         */
    rhs = CompExpr( ADDR_STAT(stat)[2] );

    /* emit the code                                                       */
    if ( CompFastPlainLists ) {
        if ( HasInfoCVar( rhs, W_INT_SMALL ) ) {
            Emit( "C_ASS_LIST_FPL_INTOBJ( %c, %c, %c )\n", list, pos, rhs );
        }
        else {
            Emit( "C_ASS_LIST_FPL( %c, %c, %c )\n", list, pos, rhs );
        }
    }
    else {
        Emit( "C_ASS_LIST( %c, %c, %c );\n", list, pos, rhs );
    }

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs  ) )  FreeTemp( TEMP_CVAR( rhs  ) );
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  CompAsssList( <stat> )  . . . . . . . . . . . . . . . . . . . T_ASSS_LIST
*/
void CompAsssList (
    Stat                stat )
{
    CVar                list;           /* list                            */
    CVar                poss;           /* positions                       */
    CVar                rhss;           /* right hand sides                */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    poss = CompExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhss = CompExpr( ADDR_STAT(stat)[2] );

    /* emit the code                                                       */
    Emit( "AsssListCheck( %c, %c, %c );\n", list, poss, rhss );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhss ) )  FreeTemp( TEMP_CVAR( rhss ) );
    if ( IS_TEMP_CVAR( poss ) )  FreeTemp( TEMP_CVAR( poss ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  CompAssListLev( <stat> )  . . . . . . . . . . . . . . . .  T_ASS_LIST_LEV
*/
void CompAssListLev (
    Stat                stat )
{
    CVar                lists;          /* lists                           */
    CVar                pos;            /* position                        */
    CVar                rhss;           /* right hand sides                */
    Int                 level;          /* level                           */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expressions                                        */
    lists = CompExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_STAT(stat)[1] );
    CompCheckIntSmallPos( pos );

    /* compile the right hand sides                                        */
    rhss = CompExpr( ADDR_STAT(stat)[2] );

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
*F  CompAsssListLev( <stat> ) . . . . . . . . . . . . . . . . T_ASSS_LIST_LEV
*/
void CompAsssListLev (
    Stat                stat )
{
    CVar                lists;          /* list                            */
    CVar                poss;           /* positions                       */
    CVar                rhss;           /* right hand sides                */
    Int                 level;          /* level                           */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expressions                                        */
    lists = CompExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    poss = CompExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhss = CompExpr( ADDR_STAT(stat)[2] );

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
*F  CompUnbList( <stat> ) . . . . . . . . . . . . . . . . . . . .  T_UNB_LIST
*/
void CompUnbList (
    Stat                stat )
{
    CVar                list;           /* list, left operand              */
    CVar                pos;            /* position, left operand          */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_STAT(stat)[1] );
    CompCheckIntPos( pos );

    /* emit the code                                                       */
    Emit( "C_UNB_LIST( %c, %c );\n", list, pos );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  CompAssRecName( <stat> )  . . . . . . . . . . . . . . . .  T_ASS_REC_NAME
*/
void CompAssRecName (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* compile the right hand side                                         */
    rhs = CompExpr( ADDR_STAT(stat)[2] );

    /* emit the code for the assignment                                    */
    Emit( "ASS_REC( %c, R_%n, %c );\n", record, NAME_RNAM(rnam), rhs );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompAssRecExpr( <stat> )  . . . . . . . . . . . . . . . .  T_ASS_REC_EXPR
*/
void CompAssRecExpr (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    CVar                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = CompExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhs = CompExpr( ADDR_STAT(stat)[2] );

    /* emit the code for the assignment                                    */
    Emit( "ASS_REC( %c, RNamObj(%c), %c );\n", record, rnam, rhs );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompUnbRecName( <stat> )  . . . . . . . . . . . . . . . .  T_UNB_REC_NAME
*/
void CompUnbRecName (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code for the assignment                                    */
    Emit( "UNB_REC( %c, R_%n );\n", record, NAME_RNAM(rnam) );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompUnbRecExpr( <stat> )  . . . . . . . . . . . . . . . .  T_UNB_REC_EXPR
*/
void            CompUnbRecExpr (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    CVar                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = CompExpr( ADDR_STAT(stat)[1] );

    /* emit the code for the assignment                                    */
    Emit( "UNB_REC( %c, RNamObj(%c) );\n", record, rnam );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompAssPosObj( <stat> ) . . . . . . . . . . . . . . . . . .  T_ASS_POSOBJ
*/
void CompAssPosObj (
    Stat                stat )
{
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_STAT(stat)[1] );
    CompCheckIntSmallPos( pos );

    /* compile the right hand side                                         */
    rhs = CompExpr( ADDR_STAT(stat)[2] );

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
*F  CompAsssPosObj( <stat> )  . . . . . . . . . . . . . . . . . T_ASSS_POSOBJ
*/
void CompAsssPosObj (
    Stat                stat )
{
    CVar                list;           /* list                            */
    CVar                poss;           /* positions                       */
    CVar                rhss;           /* right hand sides                */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    poss = CompExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhss = CompExpr( ADDR_STAT(stat)[2] );

    /* emit the code                                                       */
    Emit( "AsssPosObjCheck( %c, %c, %c );\n", list, poss, rhss );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhss ) )  FreeTemp( TEMP_CVAR( rhss ) );
    if ( IS_TEMP_CVAR( poss ) )  FreeTemp( TEMP_CVAR( poss ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  CompAssPosObjLev( <stat> )  . . . . . . . . . . . . . .  T_ASS_POSOBJ_LEV
*/
void CompAssPosObjLev (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TNUM %d;\n", TNUM_STAT(stat) );
}


/****************************************************************************
**
*F  CompAsssPosObjLev( <stat> ) . . . . . . . . . . . . . . T_ASSS_POSOBJ_LEV
*/
void CompAsssPosObjLev (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TNUM %d;\n", TNUM_STAT(stat) );
}


/****************************************************************************
**
*F  CompUnbPosObj( <stat> ) . . . . . . . . . . . . . . . . . .  T_UNB_POSOBJ
*/
void CompUnbPosObj (
    Stat                stat )
{
    CVar                list;           /* list, left operand              */
    CVar                pos;            /* position, left operand          */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr( ADDR_STAT(stat)[0] );

    /* compile and check the position expression                           */
    pos = CompExpr( ADDR_STAT(stat)[1] );
    CompCheckIntSmallPos( pos );

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
*F  CompAssComObjName( <stat> ) . . . . . . . . . . . . . . T_ASS_COMOBJ_NAME
*/
void CompAssComObjName (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* compile the right hand side                                         */
    rhs = CompExpr( ADDR_STAT(stat)[2] );

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
*F  CompAssComObjExpr( <stat> ) . . . . . . . . . . . . . . T_ASS_COMOBJ_EXPR
*/
void CompAssComObjExpr (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    CVar                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = CompExpr( ADDR_STAT(stat)[1] );

    /* compile the right hand side                                         */
    rhs = CompExpr( ADDR_STAT(stat)[2] );

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
*F  CompUnbComObjName( <stat> ) . . . . . . . . . . . . . . T_UNB_COMOBJ_NAME
*/
void CompUnbComObjName (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

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
*F  CompUnbComObjExpr( <stat> ) . . . . . . . . . . . . . . T_UNB_COMOBJ_EXPR
*/
void CompUnbComObjExpr (
    Stat                stat )
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr( ADDR_STAT(stat)[0] );

    /* get the name (stored immediately in the statement)                  */
    rnam = CompExpr( ADDR_STAT(stat)[1] );
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

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
*F  CompEmpty( <stat> )  . . . . . . . . . . . . . . . . . . . . . . . T_EMPY
*/
void CompEmpty (
    Stat                stat )
{
  Emit("\n/* ; */\n");
  Emit(";");
}
  
/****************************************************************************
**
*F  CompInfo( <stat> )  . . . . . . . . . . . . . . . . . . . . . . .  T_INFO
*/
void CompInfo (
    Stat                stat )
{
    CVar                tmp;
    CVar                sel;
    CVar                lev;
    CVar                lst;
    Int                 narg;
    Int                 i;

    Emit( "\n/* Info( ... ); */\n" );
    sel = CompExpr( ARGI_INFO( stat, 1 ) );
    lev = CompExpr( ARGI_INFO( stat, 2 ) );
    lst = CVAR_TEMP( NewTemp( "lst" ) );
    tmp = CVAR_TEMP( NewTemp( "tmp" ) );
    Emit( "%c = CALL_2ARGS( InfoDecision, %c, %c );\n", tmp, sel, lev );
    Emit( "if ( %c == True ) {\n", tmp );
    if ( IS_TEMP_CVAR( tmp ) )  FreeTemp( TEMP_CVAR( tmp ) );
    narg = NARG_SIZE_INFO(SIZE_STAT(stat))-2;
    Emit( "%c = NEW_PLIST( T_PLIST, %d );\n", lst, narg );
    Emit( "SET_LEN_PLIST( %c, %d );\n", lst, narg );
    for ( i = 1;  i <= narg;  i++ ) {
        tmp = CompExpr( ARGI_INFO( stat, i+2 ) );
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
*F  CompAssert2( <stat> ) . . . . . . . . . . . . . . . . . .  T_ASSERT_2ARGS
*/
void CompAssert2 (
    Stat                stat )
{
    CVar                lev;            /* the level                       */
    CVar                cnd;            /* the condition                   */

    Emit( "\n/* Assert( ... ); */\n" );
    lev = CompExpr( ADDR_STAT(stat)[0] );
    Emit( "if ( ! LT(CurrentAssertionLevel, %c) ) {\n", lev );
    cnd = CompBoolExpr( ADDR_STAT(stat)[1] );
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
*F  CompAssert3( <stat> ) . . . . . . . . . . . . . . . . . .  T_ASSERT_3ARGS
*/
void CompAssert3 (
    Stat                stat )
{
    CVar                lev;            /* the level                       */
    CVar                cnd;            /* the condition                   */
    CVar                msg;            /* the message                     */

    Emit( "\n/* Assert( ... ); */\n" );
    lev = CompExpr( ADDR_STAT(stat)[0] );
    Emit( "if ( ! LT(CurrentAssertionLevel, %c) ) {\n", lev );
    cnd = CompBoolExpr( ADDR_STAT(stat)[1] );
    Emit( "if ( ! %c ) {\n", cnd );
    msg = CompExpr( ADDR_STAT(stat)[2] );
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



/****************************************************************************
**

*F * * * * * * * * * * * * * * start compiling  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  CompFunc( <func> )  . . . . . . . . . . . . . . . . .  compile a function
**
**  'CompFunc' compiles the function <func>, i.e., it emits  the code for the
**  handler of the function <func> and the handlers of all its subfunctions.
*/
Obj CompFunctions;
Int CompFunctionsNr;

void CompFunc (
    Obj                 func )
{
    Bag                 info;           /* info bag for this function      */
    Int                 narg;           /* number of arguments             */
    Int                 nloc;           /* number of locals                */
    Obj                 fexs;           /* function expression list        */
    Bag                 oldFrame;       /* old frame                       */
    Int                 i;              /* loop variable                   */
    Int                 prevarargs;     /* we have varargs with a prefix   */

    /* get the number of arguments and locals                              */
    narg = NARG_FUNC(func);
    prevarargs = 0;
    if(narg < -1) prevarargs = 1;
    if (narg < 0) {
        narg = -narg;
    }

    nloc = NLOC_FUNC(func);

    /* in the first pass allocate the info bag                             */
    if ( CompPass == 1 ) {

        CompFunctionsNr++;
        GROW_PLIST(    CompFunctions, CompFunctionsNr );
        SET_ELM_PLIST( CompFunctions, CompFunctionsNr, func );
        SET_LEN_PLIST( CompFunctions, CompFunctionsNr );
        CHANGED_BAG(   CompFunctions );

        info = NewBag( T_STRING, SIZE_INFO(narg+nloc,8) );
        NEXT_INFO(info)  = INFO_FEXP( CURR_FUNC );
        NR_INFO(info)    = CompFunctionsNr;
        NLVAR_INFO(info) = narg + nloc;
        NHVAR_INFO(info) = 0;
        NTEMP_INFO(info) = 0;
        NLOOP_INFO(info) = 0;

        INFO_FEXP(func) = info;
        CHANGED_BAG(func);

    }

    /* switch to this function (so that 'ADDR_STAT' and 'ADDR_EXPR' work)  */
    SWITCH_TO_NEW_LVARS( func, narg, nloc, oldFrame );

    /* get the info bag                                                    */
    info = INFO_FEXP( CURR_FUNC );

    /* compile the innner functions                                        */
    fexs = FEXS_FUNC(func);
    for ( i = 1;  i <= LEN_PLIST(fexs);  i++ ) {
        CompFunc( ELM_PLIST( fexs, i ) );
    }

    /* emit the code for the function header and the arguments             */
    Emit( "\n/* handler for function %d */\n", NR_INFO(info));
    if ( narg == 0 ) {
        Emit( "static Obj  HdlrFunc%d (\n", NR_INFO(info) );
        Emit( " Obj  self )\n" );
        Emit( "{\n" );
    }
    else if ( narg <= 6 && !prevarargs ) {
        Emit( "static Obj  HdlrFunc%d (\n", NR_INFO(info) );
        Emit( " Obj  self,\n" );
        for ( i = 1; i < narg; i++ ) {
            Emit( " Obj  %c,\n", CVAR_LVAR(i) );
        }
        Emit( " Obj  %c )\n", CVAR_LVAR(narg) );
        Emit( "{\n" );
    }
    else {
        Emit( "static Obj  HdlrFunc%d (\n", NR_INFO(info) );
        Emit( " Obj  self,\n" );
        Emit( " Obj  args )\n" );
        Emit( "{\n" );
        for ( i = 1; i <= narg; i++ ) {
            Emit( "Obj  %c;\n", CVAR_LVAR(i) );
        }
    }

    /* emit the code for the local variables                               */
    for ( i = 1; i <= nloc; i++ ) {
        if ( ! CompGetUseHVar( i+narg ) ) {
            Emit( "Obj %c = 0;\n", CVAR_LVAR(i+narg) );
        }
    }

    /* emit the code for the temporaries                                   */
    for ( i = 1; i <= NTEMP_INFO(info); i++ ) {
        Emit( "Obj %c = 0;\n", CVAR_TEMP(i) );
    }
    for ( i = 1; i <= NLOOP_INFO(info); i++ ) {
        Emit( "Int l_%d = 0;\n", i );
    }

    /* emit the code for the higher variables                              */
    Emit( "Bag oldFrame;\n" );
    Emit( "OLD_BRK_CURR_STAT\n");

    /* emit the code to get the arguments for xarg functions               */
    if ( 6 < narg ) {
        Emit( "CHECK_NR_ARGS( %d, args )\n", narg );
        for ( i = 1; i <= narg; i++ ) {
            Emit( "%c = ELM_PLIST( args, %d );\n", CVAR_LVAR(i), i );
        }
    }

   if ( prevarargs ) {
        Emit( "CHECK_NR_AT_LEAST_ARGS( %d, args )\n", narg );
        for ( i = 1; i < narg; i++ ) {
            Emit( "%c = ELM_PLIST( args, %d );\n", CVAR_LVAR(i), i );
        }
        Emit( "Obj x_temp_range = Range2Check(INTOBJ_INT(%d), INTOBJ_INT(LEN_PLIST(args)));\n", narg);
        Emit( "%c = ELMS_LIST(args , x_temp_range);\n", CVAR_LVAR(narg));
    }

    /* emit the code to switch to a new frame for outer functions          */
#if 1
    /* Try and get better debugging by always doing this */
    if (1) {
#else
      /* this was the old code */
    if ( NHVAR_INFO(info) != 0 ) {
#endif
        Emit( "\n/* allocate new stack frame */\n" );
        Emit( "SWITCH_TO_NEW_FRAME(self,%d,0,oldFrame);\n",NHVAR_INFO(info));
        for ( i = 1; i <= narg; i++ ) {
            if ( CompGetUseHVar( i ) ) {
                Emit( "ASS_LVAR( %d, %c );\n",GetIndxHVar(i),CVAR_LVAR(i));
            }
        }
    }
    else {
        Emit( "\n/* restoring old stack frame */\n" );
        Emit( "oldFrame = STATE(CurrLVars);\n" );
        Emit( "SWITCH_TO_OLD_FRAME(ENVI_FUNC(self));\n" );
    }

    /* emit the code to save and zero the "current statement" information
     so that the break loop behaves */
    Emit( "REM_BRK_CURR_STAT();\n");
    Emit( "SET_BRK_CURR_STAT(0);\n");
    
    /* we know all the arguments have values                               */
    for ( i = 1; i <= narg; i++ ) {
        SetInfoCVar( CVAR_LVAR(i), W_BOUND );
    }
    for ( i = narg+1; i <= narg+nloc; i++ ) {
        SetInfoCVar( CVAR_LVAR(i), W_UNBOUND );
    }

    /* compile the body                                                    */
    CompStat( FIRST_STAT_CURR_FUNC );

    /* emit the code to switch back to the old frame and return            */
    Emit( "\n/* return; */\n" );
    Emit( "RES_BRK_CURR_STAT();\n" );
    Emit( "SWITCH_TO_OLD_FRAME(oldFrame);\n" );
    Emit( "return 0;\n" );
    Emit( "}\n" );

    /* switch back to old frame                                            */
    SWITCH_TO_OLD_LVARS( oldFrame );
}


/****************************************************************************
**
*F  CompileFunc( <output>, <func>, <name>, <magic1>, <magic2> ) . . . compile
*/
Int CompileFunc (
    Char *              output,
    Obj                 func,
    Char *              name,
    Int                 magic1,
    Char *              magic2 )
{
    Int                 i;              /* loop variable                   */
    Obj                 n;              /* temporary                       */
    UInt                col;

    /* open the output file                                                */
    if ( ! OpenOutput( output ) ) {
        return 0;
    }
    col = SyNrCols;
    SyNrCols = 255;

    /* store the magic values                                              */
    compilerMagic1 = magic1;
    compilerMagic2 = magic2;

    /* create 'CompInfoGVar' and 'CompInfoRNam'                            */
    CompInfoGVar = NewBag( T_STRING, sizeof(UInt) * 1024 );
    CompInfoRNam = NewBag( T_STRING, sizeof(UInt) * 1024 );

    /* create the list to collection the function expressions              */
    CompFunctionsNr = 0;
    CompFunctions = NEW_PLIST( T_PLIST, 8 );
    SET_LEN_PLIST( CompFunctions, 0 );

    /* first collect information about variables                           */
    CompPass = 1;
    CompFunc( func );

    /* ok, lets emit some code now                                         */
    CompPass = 2;

    /* emit code to include the interface files                            */
    Emit( "/* C file produced by GAC */\n" );
    Emit( "#include <src/compiled.h>\n" );

    /* emit code for global variables                                      */
    Emit( "\n/* global variables used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoGVar)/sizeof(UInt); i++ ) {
        if ( CompGetUseGVar( i ) ) {
            Emit( "static GVar G_%n;\n", NameGVar(i) );
        }
        if ( CompGetUseGVar( i ) & COMP_USE_GVAR_COPY ) {
            Emit( "static Obj  GC_%n;\n", NameGVar(i) );
        }
        if ( CompGetUseGVar( i ) & COMP_USE_GVAR_FOPY ) {
            Emit( "static Obj  GF_%n;\n", NameGVar(i) );
        }
    }

    /* emit code for record names                                          */
    Emit( "\n/* record names used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoRNam)/sizeof(UInt); i++ ) {
        if ( CompGetUseRNam( i ) ) {
            Emit( "static RNam R_%n;\n", NAME_RNAM(i) );
        }
    }

    /* emit code for the functions                                         */
    Emit( "\n/* information for the functions */\n" );
    Emit( "static Obj  NameFunc[%d];\n", CompFunctionsNr+1 );
    Emit( "static Obj  NamsFunc[%d];\n", CompFunctionsNr+1 );
    Emit( "static Int  NargFunc[%d];\n", CompFunctionsNr+1 );
    Emit( "static Obj  DefaultName;\n" );
    Emit( "static Obj FileName;\n" );


    /* now compile the handlers                                            */
    CompFunc( func );

    /* emit the code for the function that links this module to GAP        */
    Emit( "\n/* 'InitKernel' sets up data structures, fopies, copies, handlers */\n" );
    Emit( "static Int InitKernel ( StructInitInfo * module )\n" );
    Emit( "{\n" );
    Emit( "\n/* global variables used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoGVar)/sizeof(UInt); i++ ) {
        if ( CompGetUseGVar( i ) & COMP_USE_GVAR_COPY ) {
            Emit( "InitCopyGVar( \"%s\", &GC_%n );\n",
                  NameGVar(i), NameGVar(i) );
        }
        if ( CompGetUseGVar( i ) & COMP_USE_GVAR_FOPY ) {
            Emit( "InitFopyGVar( \"%s\", &GF_%n );\n",
                  NameGVar(i), NameGVar(i) );
        }
    }
    Emit( "\n/* information for the functions */\n" );
    Emit( "InitGlobalBag( &DefaultName, \"%s:DefaultName(%d)\" );\n",
          magic2, magic1 );
    Emit( "InitGlobalBag( &FileName, \"%s:FileName(%d)\" );\n",
          magic2, magic1 );
    for ( i = 1; i <= CompFunctionsNr; i++ ) {
        Emit( "InitHandlerFunc( HdlrFunc%d, \"%s:HdlrFunc%d(%d)\" );\n",
              i, compilerMagic2, i, compilerMagic1 );
        Emit( "InitGlobalBag( &(NameFunc[%d]), \"%s:NameFunc[%d](%d)\" );\n", 
               i, magic2, i, magic1 );
        n = NAME_FUNC(ELM_PLIST(CompFunctions,i));
        if ( n != 0 && IsStringConv(n) ) {
            Emit( "InitGlobalBag( &(NamsFunc[%d]), \"%s:NamsFunc[%d](%d)\" );\n",
                  i, magic2, i, magic1 );
        }
    }
    Emit( "\n/* return success */\n" );
    Emit( "return 0;\n" );
    Emit( "\n}\n" );

    Emit( "\n/* 'InitLibrary' sets up gvars, rnams, functions */\n" );
    Emit( "static Int InitLibrary ( StructInitInfo * module )\n" );
    Emit( "{\n" );
    Emit( "Obj func1;\n" );
    Emit( "Obj body1;\n" );
    Emit( "\n/* Complete Copy/Fopy registration */\n" );
    Emit( "UpdateCopyFopyInfo();\n" );
    Emit( "\n/* global variables used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoGVar)/sizeof(UInt); i++ ) {
        if ( CompGetUseGVar( i ) ) {
            Emit( "G_%n = GVarName( \"%s\" );\n",
                   NameGVar(i), NameGVar(i) );
        }
    }
    Emit( "\n/* record names used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoRNam)/sizeof(UInt); i++ ) {
        if ( CompGetUseRNam( i ) ) {
            Emit( "R_%n = RNamName( \"%s\" );\n",
                  NAME_RNAM(i), NAME_RNAM(i) );
        }
    }
    Emit( "\n/* information for the functions */\n" );
    Emit( "C_NEW_STRING( DefaultName, 14, \"local function\" );\n" );
    Emit( "C_NEW_STRING( FileName, %d, \"%s\" );\n", strlen(magic2), magic2 );
    for ( i = 1; i <= CompFunctionsNr; i++ ) {
        n = NAME_FUNC(ELM_PLIST(CompFunctions,i));
        if ( n != 0 && IsStringConv(n) ) {
            Emit( "C_NEW_STRING( NameFunc[%d], %d, \"%S\" );\n",
                  i, strlen(CSTR_STRING(n)), CSTR_STRING(n) );
        }
        else {
            Emit( "NameFunc[%d] = DefaultName;\n", i );
        }
        Emit( "NamsFunc[%d] = 0;\n", i );
        Emit( "NargFunc[%d] = %d;\n", i, NARG_FUNC(ELM_PLIST(CompFunctions,i)));
    }
    Emit( "\n/* create all the functions defined in this module */\n" );
    Emit( "func1 = NewFunction(NameFunc[1],NargFunc[1],NamsFunc[1],HdlrFunc1);\n" );
    Emit( "ENVI_FUNC( func1 ) = STATE(CurrLVars);\n" );
    Emit( "CHANGED_BAG( STATE(CurrLVars) );\n" );
    Emit( "body1 = NewBag( T_BODY, NUMBER_HEADER_ITEMS_BODY*sizeof(Obj));\n" );
    Emit( "BODY_FUNC( func1 ) = body1;\n" );
    Emit( "CHANGED_BAG( func1 );\n");
    Emit( "CALL_0ARGS( func1 );\n" );
    Emit( "\n/* return success */\n" );
    Emit( "return 0;\n" );
    Emit( "\n}\n" );

    Emit( "\n/* 'PostRestore' restore gvars, rnams, functions */\n" );
    Emit( "static Int PostRestore ( StructInitInfo * module )\n" );
    Emit( "{\n" );
    Emit( "\n/* global variables used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoGVar)/sizeof(UInt); i++ ) {
        if ( CompGetUseGVar( i ) ) {
            Emit( "G_%n = GVarName( \"%s\" );\n",
                   NameGVar(i), NameGVar(i) );
        }
    }
    Emit( "\n/* record names used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoRNam)/sizeof(UInt); i++ ) {
        if ( CompGetUseRNam( i ) ) {
            Emit( "R_%n = RNamName( \"%s\" );\n",
                  NAME_RNAM(i), NAME_RNAM(i) );
        }
    }
    Emit( "\n/* information for the functions */\n" );
    for ( i = 1; i <= CompFunctionsNr; i++ ) {
        n = NAME_FUNC(ELM_PLIST(CompFunctions,i));
        if ( n == 0 || ! IsStringConv(n) ) {
            Emit( "NameFunc[%d] = DefaultName;\n", i );
        }
        Emit( "NamsFunc[%d] = 0;\n", i );
        Emit( "NargFunc[%d] = %d;\n", i, NARG_FUNC(ELM_PLIST(CompFunctions,i)));
    }
    Emit( "\n/* return success */\n" );
    Emit( "return 0;\n" );
    Emit( "\n}\n" );
    Emit( "\n" );

    /* emit the initialization code                                        */
    Emit( "\n/* <name> returns the description of this module */\n" );
    Emit( "static StructInitInfo module = {\n" );
    if ( ! strcmp( "Init_Dynamic", name ) ) {
        Emit( "/* type        = */ %d,\n",     MODULE_DYNAMIC ); 
    }
    else {
        Emit( "/* type        = */ %d,\n",     MODULE_STATIC ); 
    }
    Emit( "/* name        = */ \"%C\",\n", magic2 );
    Emit( "/* revision_c  = */ %d,\n",     0 );
    Emit( "/* revision_h  = */ %d,\n",     0 );
    Emit( "/* version     = */ %d,\n",     0 );
    Emit( "/* crc         = */ %d,\n",     magic1 );
    Emit( "/* initKernel  = */ InitKernel,\n" );
    Emit( "/* initLibrary = */ InitLibrary,\n" );
    Emit( "/* checkInit   = */ 0,\n" );
    Emit( "/* preSave     = */ 0,\n" );
    Emit( "/* postSave    = */ 0,\n" );
    Emit( "/* postRestore = */ PostRestore\n" );
    Emit( "};\n" );
    Emit( "\n" );
    Emit( "StructInitInfo * %n ( void )\n", name );
    Emit( "{\n" );
    Emit( "return &module;\n" );
    Emit( "}\n" );
    Emit( "\n/* compiled code ends here */\n" );

    /* close the output file                                               */
    SyNrCols = col;
    CloseOutput();

    /* return success                                                      */
    return CompFunctionsNr;
}


/****************************************************************************
**
*F  FuncCOMPILE_FUNC( <self>, <output>, <func>, <name>, <magic1>, <magic2> )
*/
Obj FuncCOMPILE_FUNC (
    Obj                 self,
    Obj                 arg )
{
    Obj                 output;
    Obj                 func;
    Obj                 name;
    Obj                 magic1;
    Obj                 magic2;
    Int                 nr;
    Int                 len;

    /* unravel the arguments                                               */
    len = LEN_LIST(arg); 
    if ( len < 5 ) {
        ErrorQuit( "usage: COMPILE_FUNC( <output>, <func>, <name>, %s",
                   (Int)"<magic1>, <magic2>, ... )", 0 );
        return 0;
    }
    output = ELM_LIST( arg, 1 );
    func   = ELM_LIST( arg, 2 );
    name   = ELM_LIST( arg, 3 );
    magic1 = ELM_LIST( arg, 4 );
    magic2 = ELM_LIST( arg, 5 );

    /* check the arguments                                                 */
    if ( ! IsStringConv( output ) ) {
        ErrorQuit("CompileFunc: <output> must be a string",0L,0L);
    }
    if ( TNUM_OBJ(func) != T_FUNCTION ) {
        ErrorQuit("CompileFunc: <func> must be a function",0L,0L);
    }
    if ( ! IsStringConv( name ) ) {
        ErrorQuit("CompileFunc: <name> must be a string",0L,0L);
    }
    if ( ! IS_INTOBJ(magic1) ) {
        ErrorQuit("CompileFunc: <magic1> must be an integer",0L,0L);
    }
    if ( ! IsStringConv(magic2) ) {
        ErrorQuit("CompileFunc: <magic2> must be a string",0L,0L);
    }

    /* possible optimiser flags                                            */
    CompFastIntArith        = 1;
    CompFastPlainLists      = 1;
    CompFastListFuncs       = 1;
    CompCheckTypes          = 1;
    CompCheckListElements   = 1;
    CompCheckPosObjElements = 0;

    if ( 6 <= len ) {
        CompFastIntArith        = EQ( ELM_LIST( arg,  6 ), True );
    }
    if ( 7 <= len ) {
        CompFastPlainLists      = EQ( ELM_LIST( arg,  7 ), True );
    }
    if ( 8 <= len ) {
        CompFastListFuncs       = EQ( ELM_LIST( arg,  8 ), True );
    }
    if ( 9 <= len ) {
        CompCheckTypes          = EQ( ELM_LIST( arg,  9 ), True );
    }
    if ( 10 <= len ) {
        CompCheckListElements   = EQ( ELM_LIST( arg, 10 ), True );
    }
    if ( 11 <= len ) {
        CompCheckPosObjElements = EQ( ELM_LIST( arg, 11 ), True );
    }
    
    /* compile the function                                                */
    nr = CompileFunc(
        CSTR_STRING(output), func, CSTR_STRING(name),
        INT_INTOBJ(magic1), CSTR_STRING(magic2) );


    /* return the result                                                   */
    return INTOBJ_INT(nr);
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "COMPILE_FUNC", -1, "arg",
      FuncCOMPILE_FUNC, "src/compiler.c:COMPILE_FUNC" },

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    Int                 i;              /* loop variable                   */

    CompFastIntArith = 1;
    CompFastListFuncs = 1;
    CompFastPlainLists = 1;
    CompCheckTypes = 1;
    CompCheckListElements = 1;
    CompCheckPosObjElements = 0;
    CompPass = 0;
    
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* announce the global variables                                       */
    InitGlobalBag( &CompInfoGVar,  "src/compiler.c:CompInfoGVar"  );
    InitGlobalBag( &CompInfoRNam,  "src/compiler.c:CompInfoRNam"  );
    InitGlobalBag( &CompFunctions, "src/compiler.c:CompFunctions" );

    /* enter the expression compilers into the table                       */
    for ( i = 0; i < 256; i++ ) {
        CompExprFuncs[ i ] = CompUnknownExpr;
    }

    CompExprFuncs[ T_FUNCCALL_0ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ T_FUNCCALL_1ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ T_FUNCCALL_2ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ T_FUNCCALL_3ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ T_FUNCCALL_4ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ T_FUNCCALL_5ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ T_FUNCCALL_6ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ T_FUNCCALL_XARGS  ] = CompFunccallXArgs;
    CompExprFuncs[ T_FUNC_EXPR       ] = CompFuncExpr;

    CompExprFuncs[ T_OR              ] = CompOr;
    CompExprFuncs[ T_AND             ] = CompAnd;
    CompExprFuncs[ T_NOT             ] = CompNot;
    CompExprFuncs[ T_EQ              ] = CompEq;
    CompExprFuncs[ T_NE              ] = CompNe;
    CompExprFuncs[ T_LT              ] = CompLt;
    CompExprFuncs[ T_GE              ] = CompGe;
    CompExprFuncs[ T_GT              ] = CompGt;
    CompExprFuncs[ T_LE              ] = CompLe;
    CompExprFuncs[ T_IN              ] = CompIn;

    CompExprFuncs[ T_SUM             ] = CompSum;
    CompExprFuncs[ T_AINV            ] = CompAInv;
    CompExprFuncs[ T_DIFF            ] = CompDiff;
    CompExprFuncs[ T_PROD            ] = CompProd;
    CompExprFuncs[ T_INV             ] = CompInv;
    CompExprFuncs[ T_QUO             ] = CompQuo;
    CompExprFuncs[ T_MOD             ] = CompMod;
    CompExprFuncs[ T_POW             ] = CompPow;

    CompExprFuncs[ T_INTEXPR         ] = CompIntExpr;
    CompExprFuncs[ T_INT_EXPR        ] = CompIntExpr;
    CompExprFuncs[ T_TRUE_EXPR       ] = CompTrueExpr;
    CompExprFuncs[ T_FALSE_EXPR      ] = CompFalseExpr;
    CompExprFuncs[ T_TILDE_EXPR      ] = CompTildeExpr;
    CompExprFuncs[ T_CHAR_EXPR       ] = CompCharExpr;
    CompExprFuncs[ T_PERM_EXPR       ] = CompPermExpr;
    CompExprFuncs[ T_PERM_CYCLE      ] = CompUnknownExpr;
    CompExprFuncs[ T_LIST_EXPR       ] = CompListExpr;
    CompExprFuncs[ T_LIST_TILD_EXPR  ] = CompListTildeExpr;
    CompExprFuncs[ T_RANGE_EXPR      ] = CompRangeExpr;
    CompExprFuncs[ T_STRING_EXPR     ] = CompStringExpr;
    CompExprFuncs[ T_REC_EXPR        ] = CompRecExpr;
    CompExprFuncs[ T_REC_TILD_EXPR   ] = CompRecTildeExpr;

    CompExprFuncs[ T_REFLVAR         ] = CompRefLVar;
    CompExprFuncs[ T_ISB_LVAR        ] = CompIsbLVar;
    CompExprFuncs[ T_REF_HVAR        ] = CompRefHVar;
    CompExprFuncs[ T_ISB_HVAR        ] = CompIsbHVar;
    CompExprFuncs[ T_REF_GVAR        ] = CompRefGVar;
    CompExprFuncs[ T_ISB_GVAR        ] = CompIsbGVar;

    CompExprFuncs[ T_ELM_LIST        ] = CompElmList;
    CompExprFuncs[ T_ELMS_LIST       ] = CompElmsList;
    CompExprFuncs[ T_ELM_LIST_LEV    ] = CompElmListLev;
    CompExprFuncs[ T_ELMS_LIST_LEV   ] = CompElmsListLev;
    CompExprFuncs[ T_ISB_LIST        ] = CompIsbList;
    CompExprFuncs[ T_ELM_REC_NAME    ] = CompElmRecName;
    CompExprFuncs[ T_ELM_REC_EXPR    ] = CompElmRecExpr;
    CompExprFuncs[ T_ISB_REC_NAME    ] = CompIsbRecName;
    CompExprFuncs[ T_ISB_REC_EXPR    ] = CompIsbRecExpr;

    CompExprFuncs[ T_ELM_POSOBJ      ] = CompElmPosObj;
    CompExprFuncs[ T_ELMS_POSOBJ     ] = CompElmsPosObj;
    CompExprFuncs[ T_ELM_POSOBJ_LEV  ] = CompElmPosObjLev;
    CompExprFuncs[ T_ELMS_POSOBJ_LEV ] = CompElmsPosObjLev;
    CompExprFuncs[ T_ISB_POSOBJ      ] = CompIsbPosObj;
    CompExprFuncs[ T_ELM_COMOBJ_NAME ] = CompElmComObjName;
    CompExprFuncs[ T_ELM_COMOBJ_EXPR ] = CompElmComObjExpr;
    CompExprFuncs[ T_ISB_COMOBJ_NAME ] = CompIsbComObjName;
    CompExprFuncs[ T_ISB_COMOBJ_EXPR ] = CompIsbComObjExpr;

    CompExprFuncs[ T_FUNCCALL_OPTS   ] = CompFunccallOpts;
    
    /* enter the boolean expression compilers into the table               */
    for ( i = 0; i < 256; i++ ) {
        CompBoolExprFuncs[ i ] = CompUnknownBool;
    }

    CompBoolExprFuncs[ T_OR              ] = CompOrBool;
    CompBoolExprFuncs[ T_AND             ] = CompAndBool;
    CompBoolExprFuncs[ T_NOT             ] = CompNotBool;
    CompBoolExprFuncs[ T_EQ              ] = CompEqBool;
    CompBoolExprFuncs[ T_NE              ] = CompNeBool;
    CompBoolExprFuncs[ T_LT              ] = CompLtBool;
    CompBoolExprFuncs[ T_GE              ] = CompGeBool;
    CompBoolExprFuncs[ T_GT              ] = CompGtBool;
    CompBoolExprFuncs[ T_LE              ] = CompLeBool;
    CompBoolExprFuncs[ T_IN              ] = CompInBool;

    /* enter the statement compilers into the table                        */
    for ( i = 0; i < 256; i++ ) {
        CompStatFuncs[ i ] = CompUnknownStat;
    }

    CompStatFuncs[ T_PROCCALL_0ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ T_PROCCALL_1ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ T_PROCCALL_2ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ T_PROCCALL_3ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ T_PROCCALL_4ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ T_PROCCALL_5ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ T_PROCCALL_6ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ T_PROCCALL_XARGS  ] = CompProccallXArgs;

    CompStatFuncs[ T_SEQ_STAT        ] = CompSeqStat;
    CompStatFuncs[ T_SEQ_STAT2       ] = CompSeqStat;
    CompStatFuncs[ T_SEQ_STAT3       ] = CompSeqStat;
    CompStatFuncs[ T_SEQ_STAT4       ] = CompSeqStat;
    CompStatFuncs[ T_SEQ_STAT5       ] = CompSeqStat;
    CompStatFuncs[ T_SEQ_STAT6       ] = CompSeqStat;
    CompStatFuncs[ T_SEQ_STAT7       ] = CompSeqStat;
    CompStatFuncs[ T_IF              ] = CompIf;
    CompStatFuncs[ T_IF_ELSE         ] = CompIf;
    CompStatFuncs[ T_IF_ELIF         ] = CompIf;
    CompStatFuncs[ T_IF_ELIF_ELSE    ] = CompIf;
    CompStatFuncs[ T_FOR             ] = CompFor;
    CompStatFuncs[ T_FOR2            ] = CompFor;
    CompStatFuncs[ T_FOR3            ] = CompFor;
    CompStatFuncs[ T_FOR_RANGE       ] = CompFor;
    CompStatFuncs[ T_FOR_RANGE2      ] = CompFor;
    CompStatFuncs[ T_FOR_RANGE3      ] = CompFor;
    CompStatFuncs[ T_WHILE           ] = CompWhile;
    CompStatFuncs[ T_WHILE2          ] = CompWhile;
    CompStatFuncs[ T_WHILE3          ] = CompWhile;
    CompStatFuncs[ T_REPEAT          ] = CompRepeat;
    CompStatFuncs[ T_REPEAT2         ] = CompRepeat;
    CompStatFuncs[ T_REPEAT3         ] = CompRepeat;
    CompStatFuncs[ T_BREAK           ] = CompBreak;
    CompStatFuncs[ T_CONTINUE        ] = CompContinue;
    CompStatFuncs[ T_RETURN_OBJ      ] = CompReturnObj;
    CompStatFuncs[ T_RETURN_VOID     ] = CompReturnVoid;

    CompStatFuncs[ T_ASS_LVAR        ] = CompAssLVar;
    CompStatFuncs[ T_UNB_LVAR        ] = CompUnbLVar;
    CompStatFuncs[ T_ASS_HVAR        ] = CompAssHVar;
    CompStatFuncs[ T_UNB_HVAR        ] = CompUnbHVar;
    CompStatFuncs[ T_ASS_GVAR        ] = CompAssGVar;
    CompStatFuncs[ T_UNB_GVAR        ] = CompUnbGVar;

    CompStatFuncs[ T_ASS_LIST        ] = CompAssList;
    CompStatFuncs[ T_ASSS_LIST       ] = CompAsssList;
    CompStatFuncs[ T_ASS_LIST_LEV    ] = CompAssListLev;
    CompStatFuncs[ T_ASSS_LIST_LEV   ] = CompAsssListLev;
    CompStatFuncs[ T_UNB_LIST        ] = CompUnbList;
    CompStatFuncs[ T_ASS_REC_NAME    ] = CompAssRecName;
    CompStatFuncs[ T_ASS_REC_EXPR    ] = CompAssRecExpr;
    CompStatFuncs[ T_UNB_REC_NAME    ] = CompUnbRecName;
    CompStatFuncs[ T_UNB_REC_EXPR    ] = CompUnbRecExpr;

    CompStatFuncs[ T_ASS_POSOBJ      ] = CompAssPosObj;
    CompStatFuncs[ T_ASSS_POSOBJ     ] = CompAsssPosObj;
    CompStatFuncs[ T_ASS_POSOBJ_LEV  ] = CompAssPosObjLev;
    CompStatFuncs[ T_ASSS_POSOBJ_LEV ] = CompAsssPosObjLev;
    CompStatFuncs[ T_UNB_POSOBJ      ] = CompUnbPosObj;
    CompStatFuncs[ T_ASS_COMOBJ_NAME ] = CompAssComObjName;
    CompStatFuncs[ T_ASS_COMOBJ_EXPR ] = CompAssComObjExpr;
    CompStatFuncs[ T_UNB_COMOBJ_NAME ] = CompUnbComObjName;
    CompStatFuncs[ T_UNB_COMOBJ_EXPR ] = CompUnbComObjExpr;

    CompStatFuncs[ T_INFO            ] = CompInfo;
    CompStatFuncs[ T_ASSERT_2ARGS    ] = CompAssert2;
    CompStatFuncs[ T_ASSERT_3ARGS    ] = CompAssert3;
    CompStatFuncs[ T_EMPTY           ] = CompEmpty;

    CompStatFuncs[ T_PROCCALL_OPTS   ] = CompProccallOpts;
    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
    /* get the identifiers of 'Length' and 'Add' (for inlining)            */
    G_Length = GVarName( "Length" );
    G_Add    = GVarName( "Add"    );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return PostRestore( module );
}


/****************************************************************************
**
*F  InitInfoCompiler() . . . . . . . . . . . . . . .  table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "compiler",                         /* name                           */
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

StructInitInfo * InitInfoCompiler ( void )
{
    return &module;
}


/****************************************************************************
**

*E  compiler.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



