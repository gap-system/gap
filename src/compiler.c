/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the GAP to C compiler.
*/

#include "compiler.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "code.h"
#include "error.h"
#include "exprs.h"
#include "gvars.h"
#include "integer.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "records.h"
#include "stats.h"
#include "stringobj.h"
#include "sysopt.h"
#include "sysstr.h"
#include "vars.h"

#include <stdarg.h>


/****************************************************************************
**
*F * * * * * * * * * * * * * compilation flags  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  CompFastIntArith  . . option to emit code that handles small ints. faster
*/
static Int CompFastIntArith;


/****************************************************************************
**
*V  CompFastPlainLists  . option to emit code that handles plain lists faster
*/
static Int CompFastPlainLists;


/****************************************************************************
**
*V  CompFastListFuncs . . option to emit code that inlines calls to functions
*/
static Int CompFastListFuncs;


/****************************************************************************
**
*V  CompCheckTypes . . . . option to emit code that assumes all types are ok.
*/
static Int CompCheckTypes;


/****************************************************************************
**
*V  CompCheckListElements .  option to emit code that assumes list elms exist
*/
static Int CompCheckListElements;


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
**  unnecessary  computations during the first pass,  the  advantage is that
**  the two passes are guaranteed to do exactly the same computations.
*/
static Int CompPass;


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
static Obj compilerMagic2;


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
**  number  of temporaries  used,  the current  number  of used temporaries.
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
#define SET_INFO_FEXP(fexp,x)   SET_PROF_FUNC(fexp,x)
#define NEXT_INFO(info)         PTR_BAG(info)[1]
#define NR_INFO(info)           (*((Int*)(PTR_BAG(info)+2)))
#define NLVAR_INFO(info)        (*((Int*)(PTR_BAG(info)+3)))
#define NHVAR_INFO(info)        (*((Int*)(PTR_BAG(info)+4)))
#define NTEMP_INFO(info)        (*((Int*)(PTR_BAG(info)+5)))
#define CTEMP_INFO(info)        (*((Int*)(PTR_BAG(info)+6)))
#define TNUM_LVAR_INFO(info,i)  (*((Int*)(PTR_BAG(info)+7+(i))))

#define TNUM_TEMP_INFO(info,i)  \
    (*((Int*)(PTR_BAG(info)+7+NLVAR_INFO(info)+(i))))

#define SIZE_INFO(nlvar,ntemp)  (sizeof(Int) * (1 + 7 + (nlvar) + (ntemp)))

#define W_UNUSED                0       /* TEMP is currently unused        */
#define W_HIGHER                (1<<0) /* LVAR is used as higher variable */
#define W_UNKNOWN               ((1<<1) | W_HIGHER)
#define W_UNBOUND               ((1<<2) | W_UNKNOWN)
#define W_BOUND                 ((1<<3) | W_UNKNOWN)
#define W_INT                   ((1<<4) | W_BOUND)
#define W_INT_SMALL             ((1<<5) | W_INT)
#define W_INT_POS               ((1<<6) | W_INT)
#define W_BOOL                  ((1<<7) | W_BOUND)
#define W_FUNC                  ((1<<8) | W_BOUND)
#define W_LIST                  ((1<<9) | W_BOUND)

#define W_INT_SMALL_POS         (W_INT_SMALL | W_INT_POS)

static void SetInfoCVar(CVar cvar, UInt type)
{
    Bag                 info;           /* its info bag                    */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC() );

    /* set the type of a temporary                                         */
    if ( IS_TEMP_CVAR(cvar) ) {
        TNUM_TEMP_INFO( info, TEMP_CVAR(cvar) ) = type;
    }

    /* set the type of a lvar (but do not change if it is a higher variable) */
    else if ( IS_LVAR_CVAR(cvar)
           && TNUM_LVAR_INFO( info, LVAR_CVAR(cvar) ) != W_HIGHER ) {
        TNUM_LVAR_INFO( info, LVAR_CVAR(cvar) ) = type;
    }
}

static Int GetInfoCVar(CVar cvar)
{
    Bag                 info;           /* its info bag                    */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC() );

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

static Int HasInfoCVar(CVar cvar, Int type)
{
    return ((GetInfoCVar( cvar ) & type) == type);
}


static Bag NewInfoCVars(void)
{
    Bag                 old;
    Bag                 new;
    old = INFO_FEXP( CURR_FUNC() );
    new = NewBag( TNUM_BAG(old), SIZE_BAG(old) );
    return new;
}

static void CopyInfoCVars(Bag dst, Bag src)
{
    Int                 i;
    if ( SIZE_BAG(dst) < SIZE_BAG(src) )  ResizeBag( dst, SIZE_BAG(src) );
    if ( SIZE_BAG(src) < SIZE_BAG(dst) )  ResizeBag( src, SIZE_BAG(dst) );
    NR_INFO(dst)    = NR_INFO(src);
    NLVAR_INFO(dst) = NLVAR_INFO(src);
    NHVAR_INFO(dst) = NHVAR_INFO(src);
    NTEMP_INFO(dst) = NTEMP_INFO(src);
    CTEMP_INFO(dst) = CTEMP_INFO(src);
    for ( i = 1; i <= NLVAR_INFO(src); i++ ) {
        TNUM_LVAR_INFO(dst,i) = TNUM_LVAR_INFO(src,i);
    }
    for ( i = 1; i <= NTEMP_INFO(dst) && i <= NTEMP_INFO(src); i++ ) {
        TNUM_TEMP_INFO(dst,i) = TNUM_TEMP_INFO(src,i);
    }
}

static void MergeInfoCVars(Bag dst, Bag src)
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

static BOOL IsEqInfoCVars(Bag dst, Bag src)
{
    Int                 i;
    if ( SIZE_BAG(dst) < SIZE_BAG(src) )  ResizeBag( dst, SIZE_BAG(src) );
    if ( SIZE_BAG(src) < SIZE_BAG(dst) )  ResizeBag( src, SIZE_BAG(dst) );
    for ( i = 1; i <= NLVAR_INFO(src); i++ ) {
        if ( TNUM_LVAR_INFO(dst,i) != TNUM_LVAR_INFO(src,i) ) {
            return FALSE;
        }
    }
    for ( i = 1; i <= NTEMP_INFO(dst) && i <= NTEMP_INFO(src); i++ ) {
        if ( TNUM_TEMP_INFO(dst,i) != TNUM_TEMP_INFO(src,i) ) {
            return FALSE;
        }
    }
    return TRUE;
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

static Temp NewTemp(const Char * name)
{
    Temp                temp;           /* new temporary, result           */
    Bag                 info;           /* information bag                 */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC() );

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

static void FreeTemp(Temp temp)
{
    Bag                 info;           /* information bag                 */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC() );

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

static void CompSetUseHVar(HVar hvar)
{
    Bag                 info;           /* its info bag                    */
    Int                 i;              /* loop variable                   */

    /* only mark in pass 1                                                 */
    if ( CompPass != 1 )  return;

    /* walk up                                                             */
    info = INFO_FEXP( CURR_FUNC() );
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        info = NEXT_INFO( info );
    }

    /* set mark                                                            */
    if ( TNUM_LVAR_INFO( info, (hvar & 0xFFFF) ) != W_HIGHER ) {
        TNUM_LVAR_INFO( info, (hvar & 0xFFFF) ) = W_HIGHER;
        NHVAR_INFO(info) = NHVAR_INFO(info) + 1;
    }

}

static Int CompGetUseHVar(HVar hvar)
{
    Bag                 info;           /* its info bag                    */
    Int                 i;              /* loop variable                   */

    /* walk up                                                             */
    info = INFO_FEXP( CURR_FUNC() );
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        info = NEXT_INFO( info );
    }

    /* get mark                                                            */
    return (TNUM_LVAR_INFO( info, (hvar & 0xFFFF) ) == W_HIGHER);
}

static UInt GetLevlHVar(HVar hvar)
{
    UInt                levl;           /* level of higher variable        */
    Bag                 info;           /* its info bag                    */
    Int                 i;              /* loop variable                   */

    /* walk up                                                             */
    levl = 0;
    info = INFO_FEXP( CURR_FUNC() );
    levl++;
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        info = NEXT_INFO( info );
          levl++;
    }

    /* return level (the number steps to go up)                            */
    return levl - 1;
}

static UInt GetIndxHVar(HVar hvar)
{
    UInt                indx;           /* index of higher variable        */
    Bag                 info;           /* its info bag                    */
    Int                 i;              /* loop variable                   */

    /* walk up                                                             */
    info = INFO_FEXP( CURR_FUNC() );
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

#define COMP_USE_GVAR_ID        (1 << 0)
#define COMP_USE_GVAR_COPY      (1 << 1)
#define COMP_USE_GVAR_FOPY      (1 << 2)

static Bag CompInfoGVar;

static void CompSetUseGVar(GVar gvar, UInt mode)
{
    /* only mark in pass 1                                                 */
    if ( CompPass != 1 )  return;

    /* resize if necessary                                                */
    if ( SIZE_OBJ(CompInfoGVar)/sizeof(UInt) <= gvar ) {
        ResizeBag( CompInfoGVar, sizeof(UInt)*(gvar+1) );
    }

    /* or with <mode>                                                      */
    ((UInt*)PTR_BAG(CompInfoGVar))[gvar] |= mode;
}

static UInt CompGetUseGVar(GVar gvar)
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

#define COMP_USE_RNAM_ID        (1 << 0)

static Bag CompInfoRNam;

static void CompSetUseRNam(RNam rnam, UInt mode)
{
    /* only mark in pass 1                                                 */
    if ( CompPass != 1 )  return;

    /* resize if necessary                                                */
    if ( SIZE_OBJ(CompInfoRNam)/sizeof(UInt) <= rnam ) {
        ResizeBag( CompInfoRNam, sizeof(UInt)*(rnam+1) );
    }

    /* or with <mode>                                                      */
    ((UInt*)PTR_BAG(CompInfoRNam))[rnam] |= mode;
}

static UInt CompGetUseRNam(RNam rnam)
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
**  'Emit' supports the following '%' format elements:
**  - '%d' formats an integer,
**  - '%s' formats a string,
**  - '%S' formats a string with all the necessary escapes,
**  - '%g' formats a GAP string,
**  - '%G' formats a GAP string with all the necessary escapes,
**  - '%C' does the same but uses only valid C escapes,
**  - '%n' formats a name ('_' is converted to '__', special characters are
**         converted to '_<hex1><hex2>')
**  - '%c' formats a C variable ('INTOBJ_INT(<int>)' for integers, 'a_<name>'
**         for arguments, 'l_<name>' for locals, 't_<nr>' for temporaries),
**  - '%i' formats a C variable as an integer ('<int>' for integers, and for
**         everything else the same as INT_INTOBJ(%c) would produce
**  - '%%' outputs a single '%'.
*/
static Int EmitIndent;

static Int EmitIndent2;

static void Emit(const char * fmt, ...)
{
    Int                 narg;           /* number of arguments             */
    va_list             ap;             /* argument list pointer           */
    Int                 dint;           /* integer argument                */
    CVar                cvar;           /* C variable argument             */
    Char *              string;         /* string argument                 */
    const Char *        p;              /* loop variable                   */
    const Char *        hex = "0123456789ABCDEF";

    /* are we in pass 2?                                                   */
    if ( CompPass != 2 )  return;

    /* get the information bag                                             */
    narg = NARG_FUNC( CURR_FUNC() );
    if (narg < 0) {
        narg = -narg;
    }

    /* loop over the format string                                         */
    va_start( ap, fmt );
    for ( p = fmt; *p != '\0'; p++ ) {

        /* print an indent, except for preprocessor commands               */
        if ( *fmt != '#' ) {
            if ( 0 < EmitIndent2 && *p == '}' ) EmitIndent2--;
            while ( 0 < EmitIndent2-- )  Pr(" ", 0, 0);
        }

        /* format an argument                                              */
        if ( *p == '%' ) {
            p++;

            /* emit an integer                                             */
            if ( *p == 'd' ) {
                dint = va_arg( ap, Int );
                Pr("%d", dint, 0);
            }

            // emit a C string
            else if ( *p == 's' || *p == 'S' ) {
                const Char f[] = { '%', *p, 0 };
                string = va_arg( ap, Char* );
                Pr(f, (Int)string, 0);
            }

            // emit a GAP string
            else if ( *p == 'g' || *p == 'G' || *p == 'C' ) { 
                const Char f[] = { '%', *p, 0 };
                Obj str = va_arg( ap, Obj );
                Pr(f, (Int)str, 0);
            }

            /* emit a name                                                 */
            else if ( *p == 'n' ) {
                Obj str = va_arg( ap, Obj );
                UInt i = 0;
                Char c;
                while ((c = CONST_CSTR_STRING(str)[i++])) {
                    if ( IsAlpha(c) || IsDigit(c) ) {
                        Pr("%c", (Int)c, 0);
                    }
                    else if ( c == '_' ) {
                        Pr("__", 0, 0);
                    }
                    else {
                        Pr("_%c%c",hex[((UInt)c)/16],hex[((UInt)c)%16]);
                    }
                }
            }

            /* emit a C variable                                           */
            else if ( *p == 'c' ) {
                cvar = va_arg( ap, CVar );
                if ( IS_INTG_CVAR(cvar) ) {
                    Int x = INTG_CVAR(cvar);
                    if (x >= -(1 << 28) && x < (1 << 28))
                        Pr("INTOBJ_INT(%d)", x, 0);
                    else
                        Pr("ObjInt_Int8(%d)", x, 0);
                }
                else if ( IS_TEMP_CVAR(cvar) ) {
                    Pr("t_%d", TEMP_CVAR(cvar), 0);
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
                    Pr("%d", INTG_CVAR(cvar), 0);
                }
                else if ( IS_TEMP_CVAR(cvar) ) {
                    Pr("Int_ObjInt(t_%d)", TEMP_CVAR(cvar), 0);
                }
                else if ( LVAR_CVAR(cvar) <= narg ) {
                    Emit( "Int_ObjInt(a_%n)", NAME_LVAR( LVAR_CVAR(cvar) ) );
                }
                else {
                    Emit( "Int_ObjInt(l_%n)", NAME_LVAR( LVAR_CVAR(cvar) ) );
                }
            }

            /* emit a '%'                                                  */
            else if ( *p == '%' ) {
                Pr("%%", 0, 0);
            }

            /* what                                                        */
            else {
                Pr("%%illegal format statement", 0, 0);
            }

        }

        else if ( *p == '{' ) {
            Pr("{", 0, 0);
            EmitIndent++;
        }
        else if ( *p == '}' ) {
            Pr("}", 0, 0);
            EmitIndent--;
        }
        else if ( *p == '\n' ) {
            Pr("\n", 0, 0);
            EmitIndent2 = EmitIndent;
        }

        else {
            Pr("%c", (Int)(*p), 0);
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
static void CompCheckBound(CVar obj, Obj name)
{
    if ( ! HasInfoCVar( obj, W_BOUND ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_BOUND( %c, \"%g\" );\n", obj, name );
        }
        SetInfoCVar( obj, W_BOUND );
    }
}


/****************************************************************************
**
*F  CompCheckFuncResult( <obj> )  . emit code to check that <obj> has a value
*/
static void CompCheckFuncResult(CVar obj)
{
    if ( ! HasInfoCVar( obj, W_BOUND ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_FUNC_RESULT( %c );\n", obj );
        }
        SetInfoCVar( obj, W_BOUND );
    }
}


/****************************************************************************
**
*F  CompCheckIntSmall( <obj> )   emit code to check that <obj> is a small int
*/
static void CompCheckIntSmall(CVar obj)
{
    if ( ! HasInfoCVar( obj, W_INT_SMALL ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_INT_SMALL( %c );\n", obj );
        }
        SetInfoCVar( obj, W_INT_SMALL );
    }
}



/****************************************************************************
**
*F  CompCheckIntSmallPos( <obj> ) emit code to check that <obj> is a position
*/
static void CompCheckIntSmallPos(CVar obj)
{
    if ( ! HasInfoCVar( obj, W_INT_SMALL_POS ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_INT_SMALL_POS( %c );\n", obj );
        }
        SetInfoCVar( obj, W_INT_SMALL_POS );
    }
}

/****************************************************************************
**
*F  CompCheckIntPos( <obj> ) emit code to check that <obj> is a position
*/
static void CompCheckIntPos(CVar obj)
{
    if ( ! HasInfoCVar( obj, W_INT_POS ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_INT_POS( %c );\n", obj );
        }
        SetInfoCVar( obj, W_INT_POS );
    }
}


/****************************************************************************
**
*F  CompCheckBool( <obj> )  . . .  emit code to check that <obj> is a boolean
*/
static void CompCheckBool(CVar obj)
{
    if ( ! HasInfoCVar( obj, W_BOOL ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_BOOL( %c );\n", obj );
        }
        SetInfoCVar( obj, W_BOOL );
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
static CVar (*CompExprFuncs[256])(Expr expr);


static CVar CompExpr(Expr expr)
{
    return (* CompExprFuncs[ TNUM_EXPR(expr) ])( expr );
}


/****************************************************************************
**
*F  CompUnknownExpr( <expr> ) . . . . . . . . . . . .  log unknown expression
*/
static CVar CompUnknownExpr(Expr expr)
{
    Emit( "CANNOT COMPILE EXPRESSION OF TNUM %d;\n", TNUM_EXPR(expr) );
    return 0;
}



/****************************************************************************
**
*F  CompBoolExpr( <expr> )  . . . . . . . compile bool expr and return C bool
*/
static CVar (*CompBoolExprFuncs[256])(Expr expr);

static CVar CompBoolExpr(Expr expr)
{
    return (* CompBoolExprFuncs[ TNUM_EXPR(expr) ])( expr );
}


/****************************************************************************
**
*F  CompUnknownBool( <expr> ) . . . . . . . . . .  use 'CompExpr' and convert
*/
static CVar CompUnknownBool(Expr expr)
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

    return res;
}
    
/****************************************************************************
**
*V  G_Length  . . . . . . . . . . . . . . . . . . . . . . . function 'Length'
*/
static GVar G_Length;


/****************************************************************************
**
*F  CompFunccall0to6Args( <expr> )  . . . EXPR_FUNCCALL_0ARGS...EXPR_FUNCCALL_6ARGS
*/
static CVar CompRefGVarFopy(Expr expr);


static CVar CompFunccall0to6Args(Expr expr)
{
    CVar                result;         /* result, result                  */
    CVar                func;           /* function                        */
    CVar                args [8];       /* arguments                       */
    Int                 narg;           /* number of arguments             */
    Int                 i;              /* loop variable                   */

    /* special case to inline 'Length'                                     */
    if ( CompFastListFuncs
      && TNUM_EXPR( FUNC_CALL(expr) ) == EXPR_REF_GVAR
      && READ_EXPR( FUNC_CALL(expr), 0 ) == G_Length
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
    if ( TNUM_EXPR( FUNC_CALL(expr) ) == EXPR_REF_GVAR ) {
        func = CompRefGVarFopy( FUNC_CALL(expr) );
    }
    else {
        func = CompExpr( FUNC_CALL(expr) );
    }

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_EXPR(expr));
    for ( i = 1; i <= narg; i++ ) {
        args[i] = CompExpr( ARGI_CALL(expr,i) );
    }

    /* emit the code for the function call                                 */
    Emit( "if ( TNUM_OBJ( %c ) == T_FUNCTION ) {\n", func );
    Emit( "%c = CALL_%dARGS( %c", result, narg, func );
    for ( i = 1; i <= narg; i++ ) {
        Emit( ", %c", args[i] );
    }
    Emit( " );\n" );
    Emit( "}\n" );
    Emit( "else {\n" );
    Emit( "%c = DoOperation2Args( CallFuncListOper, %c, NewPlistFromArgs(", result, func);
    if (narg >= 1) {
        Emit( " %c", args[1] );
    }
    for ( i = 2; i <= narg; i++ ) {
        Emit( ", %c", args[i] );
    }
    Emit( " ) );\n" );
    Emit( "}\n" );

    /* emit code for the check (sets the information for the result)       */
    CompCheckFuncResult( result );

    /* free the temporaries                                                */
    for ( i = narg; 1 <= i; i-- ) {
        if ( IS_TEMP_CVAR( args[i] ) )  FreeTemp( TEMP_CVAR( args[i] ) );
    }
    if ( IS_TEMP_CVAR( func ) )  FreeTemp( TEMP_CVAR( func ) );

    return result;
}


/****************************************************************************
**
*F  CompFunccallXArgs( <expr> ) . . . . . . . . . . . . . EXPR_FUNCCALL_XARGS
*/
static CVar CompFunccallXArgs(Expr expr)
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
    if ( TNUM_EXPR( FUNC_CALL(expr) ) == EXPR_REF_GVAR ) {
        func = CompRefGVarFopy( FUNC_CALL(expr) );
    }
    else {
        func = CompExpr( FUNC_CALL(expr) );
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

    /* emit the code for the function call                                 */
    Emit( "if ( TNUM_OBJ( %c ) == T_FUNCTION ) {\n", func );
    Emit( "%c = CALL_XARGS( %c, %c );\n", result, func, argl );
    Emit( "}\n" );
    Emit( "else {\n" );
    Emit( "%c = DoOperation2Args( CallFuncListOper, %c, %c );\n", result, func, argl );
    Emit( "}\n" );

    /* emit code for the check (sets the information for the result)       */
    CompCheckFuncResult( result );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( argl ) )  FreeTemp( TEMP_CVAR( argl ) );
    if ( IS_TEMP_CVAR( func ) )  FreeTemp( TEMP_CVAR( func ) );

    return result;
}

/****************************************************************************
**
*F  CompFunccallXArgs( <expr> ) . . . . . . . . . . . . .  EXPR_FUNCCALL_OPTS
*/
static CVar CompFunccallOpts(Expr expr)
{
  CVar opts = CompExpr(READ_STAT(expr, 0));
  GVar pushOptions;
  GVar popOptions;
  CVar result;
  pushOptions = GVarName("PushOptions");
  popOptions = GVarName("PopOptions");
  CompSetUseGVar(pushOptions, COMP_USE_GVAR_FOPY);
  CompSetUseGVar(popOptions, COMP_USE_GVAR_FOPY);
  Emit("CALL_1ARGS( GF_PushOptions, %c );\n", opts);
  if (IS_TEMP_CVAR( opts) ) FreeTemp( TEMP_CVAR( opts ));
  result = CompExpr(READ_STAT(expr, 1));
  Emit("CALL_0ARGS( GF_PopOptions );\n");
  return result;
}
     

/****************************************************************************
**
*F  CompFuncExpr( <expr> ) . . . . . . . . . . . . . . . . . . . .  EXPR_FUNC
*/
static CVar CompFuncExpr(Expr expr)
{
    CVar                func;           /* function, result                */
    CVar                tmp;            /* dummy body                      */

    Obj                 fexp;           /* function expression             */
    Int                 nr;             /* number of the function          */

    /* get the number of the function                                      */
    fexp = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 0));
    nr   = NR_INFO( INFO_FEXP( fexp ) );

    /* allocate a new temporary for the function                           */
    func = CVAR_TEMP( NewTemp( "func" ) );

    /* make the function (all the pieces are in global variables)          */
    Int narg = NARG_FUNC(fexp);
    Emit( "%c = NewFunction( NameFunc[%d], %d", func, nr, narg );
    if (narg != 0) {
        Obj nams = NAMS_FUNC(fexp);
        if (narg < 0)
            narg = -narg;
        Emit( ", ArgStringToList(\"" );
        Emit( "%g", ELM_PLIST(nams, 1) );
        for (Int i = 2; i <= narg; i++) {
            Emit( ",%g", ELM_PLIST(nams, i) );
        }
        Emit( "\")" );
    }
    else {
        Emit( ", 0" );
    }
    Emit( ", HdlrFunc%d );\n", nr );

    /* this should probably be done by 'NewFunction'                       */
    Emit( "SET_ENVI_FUNC( %c, STATE(CurrLVars) );\n", func );
    tmp = CVAR_TEMP( NewTemp( "body" ) );
    Emit( "%c = NewFunctionBody();\n", tmp );
    Emit( "SET_STARTLINE_BODY(%c, %d);\n", tmp, GET_STARTLINE_BODY(BODY_FUNC(fexp)));
    Emit( "SET_ENDLINE_BODY(%c, %d);\n", tmp, GET_ENDLINE_BODY(BODY_FUNC(fexp)));
    Emit( "SET_FILENAME_BODY(%c, FileName);\n",tmp);
    Emit( "SET_BODY_FUNC(%c, %c);\n", func, tmp );
    FreeTemp( TEMP_CVAR( tmp ) );

    /* we know that the result is a function                               */
    SetInfoCVar( func, W_FUNC );

    /* return the number of the C variable that will hold the function     */
    return func;
}


/****************************************************************************
**
*F  CompOr( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . .  EXPR_OR
*/
static CVar CompOr(Expr expr)
{
    CVar                val;            /* or, result                      */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */
    Bag                 only_left;      /* info after evaluating only left */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the left expression                                         */
    left = CompBoolExpr(READ_EXPR(expr, 0));
    Emit( "%c = (%c ? True : False);\n", val, left );
    Emit( "if ( %c == False ) {\n", val );
    only_left = NewInfoCVars();
    CopyInfoCVars( only_left, INFO_FEXP(CURR_FUNC()) );

    /* compile the right expression                                        */
    right = CompBoolExpr(READ_EXPR(expr, 1));
    Emit( "%c = (%c ? True : False);\n", val, right );
    Emit( "}\n" );

    /* we know that the result is boolean                                  */
    MergeInfoCVars( INFO_FEXP(CURR_FUNC()), only_left );
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    return val;
}


/****************************************************************************
**
*F  CompOrBool( <expr> ) . . . . . . . . . . . . . . . . . . . . . .  EXPR_OR
*/
static CVar CompOrBool(Expr expr)
{
    CVar                val;            /* or, result                      */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */
    Bag                 only_left;      /* info after evaluating only left */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the left expression                                         */
    left = CompBoolExpr(READ_EXPR(expr, 0));
    Emit( "%c = %c;\n", val, left );
    Emit( "if ( ! %c ) {\n", val );
    only_left = NewInfoCVars();
    CopyInfoCVars( only_left, INFO_FEXP(CURR_FUNC()) );

    /* compile the right expression                                        */
    right = CompBoolExpr(READ_EXPR(expr, 1));
    Emit( "%c = %c;\n", val, right );
    Emit( "}\n" );

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    MergeInfoCVars( INFO_FEXP(CURR_FUNC()), only_left );
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    return val;
}


/****************************************************************************
**
*F  CompAnd( <expr> ) . . . . . . . . . . . . . . . . . . . . . . .  EXPR_AND
*/
static CVar CompAnd(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right1;         /* right operand 1                 */
    CVar                right2;         /* right operand 2                 */
    Bag                 only_left;      /* info after evaluating only left */

    /* allocate a temporary for the result                                 */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the left expression                                         */
    left = CompExpr(READ_EXPR(expr, 0));
    only_left = NewInfoCVars();
    CopyInfoCVars( only_left, INFO_FEXP(CURR_FUNC()) );

    /* emit the code for the case that the left value is 'false'           */
    Emit( "if ( %c == False ) {\n", left );
    Emit( "%c = %c;\n", val, left );
    Emit( "}\n" );

    /* emit the code for the case that the left value is 'true'            */
    Emit( "else if ( %c == True ) {\n", left );
    right1 = CompExpr(READ_EXPR(expr, 1));
    CompCheckBool( right1 );
    Emit( "%c = %c;\n", val, right1 );
    Emit( "}\n" );

    /* emit the code for the case that the left value is a filter          */
    Emit( "else if (IS_FILTER( %c ) ) {\n", left );
    right2 = CompExpr(READ_EXPR(expr, 1));
    Emit( "%c = NewAndFilter( %c, %c );\n", val, left, right2 );
    Emit( "}\n" );

    /* signal an error                                                     */
    Emit( "else {\n" );
    Emit( "RequireArgumentEx(0, %c, \"<expr>\",\n"
            "\"must be 'true' or 'false' or a filter\" );\n", left );
    Emit( "}\n" );

    /* we know precious little about the result                            */
    MergeInfoCVars( INFO_FEXP(CURR_FUNC()), only_left );
    SetInfoCVar( val, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right2 ) )  FreeTemp( TEMP_CVAR( right2 ) );
    if ( IS_TEMP_CVAR( right1 ) )  FreeTemp( TEMP_CVAR( right1 ) );
    if ( IS_TEMP_CVAR( left   ) )  FreeTemp( TEMP_CVAR( left   ) );

    return val;
}


/****************************************************************************
**
*F  CompAndBool( <expr> ) . . . . . . . . . . . . . . . . . . . . .  EXPR_AND
*/
static CVar CompAndBool(Expr expr)
{
    CVar                val;            /* or, result                      */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */
    Bag                 only_left;      /* info after evaluating only left */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the left expression                                         */
    left = CompBoolExpr(READ_EXPR(expr, 0));
    Emit( "%c = %c;\n", val, left );
    Emit( "if ( %c ) {\n", val );
    only_left = NewInfoCVars();
    CopyInfoCVars( only_left, INFO_FEXP(CURR_FUNC()) );

    /* compile the right expression                                        */
    right = CompBoolExpr(READ_EXPR(expr, 1));
    Emit( "%c = %c;\n", val, right );
    Emit( "}\n" );

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    MergeInfoCVars( INFO_FEXP(CURR_FUNC()), only_left );
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    return val;
}


/****************************************************************************
**
*F  CompNot( <expr> ) . . . . . . . . . . . . . . . . . . . . . . .  EXPR_NOT
*/
static CVar CompNot(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* operand                         */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the operand                                                 */
    left = CompBoolExpr(READ_EXPR(expr, 0));

    /* invert the operand                                                  */
    Emit( "%c = (%c ? False : True);\n", val, left );

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( left ) )  FreeTemp( TEMP_CVAR( left ) );

    return val;
}


/****************************************************************************
**
*F  CompNotBoot( <expr> ) . . . . . . . . . . . . . . . . . . . . .  EXPR_NOT
*/
static CVar CompNotBool(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* operand                         */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the operand                                                 */
    left = CompBoolExpr(READ_EXPR(expr, 0));

    /* invert the operand                                                  */
    Emit( "%c = (Obj)(UInt)( ! ((Int)%c) );\n", val, left );

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( left ) )  FreeTemp( TEMP_CVAR( left ) );

    return val;
}


/****************************************************************************
**
*F  CompEq( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . .  EXPR_EQ
*/
static CVar CompEq(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompEqBool( <expr> ) . . . . . . . . . . . . . . . . . . . . . .  EXPR_EQ
*/
static CVar CompEqBool(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompNe( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . .  EXPR_NE
*/
static CVar CompNe(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompNeBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  EXPR_NE
*/
static CVar CompNeBool(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompLt( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  EXPR_LT
*/
static CVar CompLt(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompLtBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  EXPR_LT
*/
static CVar CompLtBool(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompGe( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  EXPR_GE
*/
static CVar CompGe(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompGeBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  EXPR_GE
*/
static CVar CompGeBool(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompGt( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  EXPR_GT
*/
static CVar CompGt(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompGtBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  EXPR_GT
*/
static CVar CompGtBool(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompLe( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  EXPR_LE
*/
static CVar CompLe(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompLeBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  EXPR_LE
*/
static CVar CompLeBool(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompIn( <expr> )  . . . . . . . . . . . . . . . . . . . . . . . . .  EXPR_IN
*/
static CVar CompIn(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

    /* emit the code                                                       */
    Emit( "%c = (IN( %c, %c ) ?  True : False);\n", val, left, right );

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    return val;
}


/****************************************************************************
**
*F  CompInBool( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  EXPR_IN
*/
static CVar CompInBool(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

    /* emit the code                                                       */
    Emit( "%c = (Obj)(UInt)(IN( %c, %c ));\n", val, left, right );

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    return val;
}


/****************************************************************************
**
*F  CompSum( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . EXPR_SUM
*/
static CVar CompSum(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompAInv( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  EXPR_AINV
*/
static CVar CompAInv(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the operands                                                */
    left = CompExpr(READ_EXPR(expr, 0));

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

    return val;
}


/****************************************************************************
**
*F  CompDiff( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  EXPR_DIFF
*/
static CVar CompDiff(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompProd( <expr> )  . . . . . . . . . . . . . . . . . . . . . . .  EXPR_PROD
*/
static CVar CompProd(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompQuo( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . EXPR_QUO
*/
static CVar CompQuo(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

    /* emit the code                                                       */
    Emit( "%c = QUO( %c, %c );\n", val, left, right );

    /* set the information for the result                                  */
    SetInfoCVar( val, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    return val;
}


/****************************************************************************
**
*F  CompMod( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . EXPR_MOD
*/
static CVar CompMod(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompPow( <expr> ) . . . . . . . . . . . . . . . . . . . . . . . . . EXPR_POW
*/
static CVar CompPow(Expr expr)
{
    CVar                val;            /* result                          */
    CVar                left;           /* left operand                    */
    CVar                right;          /* right operand                   */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the two operands                                            */
    left  = CompExpr( READ_EXPR(expr, 0) );
    right = CompExpr( READ_EXPR(expr, 1) );

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

    return val;
}


/****************************************************************************
**
*F  CompIntExpr( <expr> ) . . . . . . . . . . . . . . .  EXPR_INT/EXPR_INTPOS
**
**  This is complicated by the need to produce code that will compile
**  correctly in 32 or 64 bit and with or without GMP.
**
**  The problem is that when we compile the code, we know the integer
**  representation of the stored literal in the compiling process but NOT the
**  representation which will apply to the compiled code or the endianness
**
**  The solution to this is macros: C_SET_LIMB4(bag, limbnumber, value)
**                                  C_SET_LIMB8(bag, limbnumber, value)
**
**  we compile using the one appropriate for the compiling system, but their
**  definition depends on the limb size of the target system.
**
*/
void C_SET_LIMB4(Obj bag, UInt limbnumber, UInt4 value)
{
#ifdef SYS_IS_64_BIT
    UInt8 * p;
    if (limbnumber % 2) {
        p = ((UInt8 *)ADDR_OBJ(bag)) + (limbnumber - 1) / 2;
        *p = (*p & 0xFFFFFFFFUL) | ((UInt8)value << 32);
    }
    else {
        p = ((UInt8 *)ADDR_OBJ(bag)) + limbnumber / 2;
        *p = (*p & 0xFFFFFFFF00000000UL) | (UInt8)value;
    }
#else
    ((UInt4 *)ADDR_OBJ(bag))[limbnumber] = value;
#endif
}


void C_SET_LIMB8(Obj bag, UInt limbnumber, UInt8 value)
{
#ifdef SYS_IS_64_BIT
    ((UInt8 *)ADDR_OBJ(bag))[limbnumber] = value;
#else
    ((UInt4 *)ADDR_OBJ(bag))[2 * limbnumber] = (UInt4)(value & 0xFFFFFFFFUL);
    ((UInt4 *)ADDR_OBJ(bag))[2 * limbnumber + 1] = (UInt4)(value >> 32);
#endif
}


static CVar CompIntExpr(Expr expr)
{
    CVar                val;
    Int                 siz;
    Int                 i;
    UInt                typ;

    if ( IS_INTEXPR(expr) ) {
        return CVAR_INTG( INT_INTEXPR(expr) );
    }
    else {
        // get the actual integer
        Obj obj = EVAL_EXPR(expr);

        val = CVAR_TEMP( NewTemp( "val" ) );
        siz = SIZE_OBJ(obj);
        typ = TNUM_OBJ(obj);
        if ( typ == T_INTPOS ) {
            Emit( "%c = NewWordSizedBag(T_INTPOS, %d);\n", val, siz);
            SetInfoCVar(val, W_INT_POS);
        }
        else {
            GAP_ASSERT(typ == T_INTNEG);
            Emit( "%c = NewWordSizedBag(T_INTNEG, %d);\n", val, siz);
            SetInfoCVar(val, W_INT);
        }

        for ( i = 0; i < siz/sizeof(UInt); i++ ) {
            UInt limb = CONST_ADDR_INT(obj)[i];
#ifdef SYS_IS_64_BIT 
            Emit("C_SET_LIMB8( %c, %d, %dLL);\n", val, i, limb);
#else
            Emit("C_SET_LIMB4( %c, %d, %dL);\n", val, i, limb);
#endif
        }
        if (siz <= 8) {
            Emit("#ifdef SYS_IS_64_BIT");
            Emit("%c = C_NORMALIZE_64BIT(%c);\n", val,val);
            Emit("#endif");
        }
        return val;
    }
}

/****************************************************************************
**
*F  CompTildeExpr( <expr> )  . . . . . . . . . . . . . . . . . . EXPR_TILDE
*/
static CVar CompTildeExpr(Expr expr)
{
    Emit( "if ( ! STATE(Tilde) ) {\n");
    Emit( "    ErrorMayQuit(\"'~' does not have a value here\", 0, 0);\n" );
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
*F  CompTrueExpr( <expr> )  . . . . . . . . . . . . . . . . . . . EXPR_TRUE
*/
static CVar CompTrueExpr(Expr expr)
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
*F  CompFalseExpr( <expr> ) . . . . . . . . . . . . . . . . . .  EXPR_FALSE
*/
static CVar CompFalseExpr(Expr expr)
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
*F  CompCharExpr( <expr> )  . . . . . . . . . . . . . . . . . . . EXPR_CHAR
*/
static CVar CompCharExpr(Expr expr)
{
    CVar                val;            /* result                          */

    /* allocate a new temporary for the char value                         */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code                                                       */
    Emit( "%c = ObjsChar[%d];\n", val, READ_EXPR(expr, 0));

    /* we know that we have a value                                        */
    SetInfoCVar( val, W_BOUND );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  CompPermExpr( <expr> )  . . . . . . . . . . . . . . . . . . . EXPR_PERM
*/
static CVar CompPermExpr(Expr expr)
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
        cycle = READ_EXPR(expr, i - 1);
        csize = SIZE_EXPR(cycle)/sizeof(Expr);
        Emit( "%c = NEW_PLIST( T_PLIST, %d );\n", lcyc, csize );
        Emit( "SET_LEN_PLIST( %c, %d );\n", lcyc, csize );
        Emit( "SET_ELM_PLIST( %c, %d, %c );\n", lprm, i, lcyc );
        Emit( "CHANGED_BAG( %c );\n", lprm );

        /* loop over the entries of the cycle                              */
        for ( j = 1;  j <= csize;  j++ ) {
            val = CompExpr(READ_EXPR(cycle, j - 1));
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
*F  CompListExpr( <expr> )  . . . . . . . . . . . . . . . . . . . EXPR_LIST
*/
static CVar CompListExpr1(Expr expr);
static void CompListExpr2(CVar list, Expr expr);
static CVar CompRecExpr1(Expr expr);
static void CompRecExpr2(CVar rec, Expr expr);

static CVar CompListExpr(Expr expr)
{
    CVar                list;           /* list, result                    */

    /* compile the list expression                                         */
    list = CompListExpr1( expr );
    CompListExpr2( list, expr );

    return list;
}


/****************************************************************************
**
*F  CompListTildeExpr( <expr> ) . . . . . . . . . . . . . . EXPR_LIST_TILDE
*/
static CVar CompListTildeExpr(Expr expr)
{
    CVar                list;           /* list value, result              */
    CVar                tilde;          /* old value of tilde              */

    /* remember the old value of '~'                                       */
    tilde = CVAR_TEMP( NewTemp( "tilde" ) );
    Emit( "%c = STATE(Tilde);\n", tilde );

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
static CVar CompListExpr1(Expr expr)
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
static void CompListExpr2(CVar list, Expr expr)
{
    CVar                sub;            /* subexpression                   */
    Int                 len;            /* logical length of the list      */
    Int                 i;              /* loop variable                   */

    /* get the length of the list                                          */
    len = SIZE_EXPR( expr ) / sizeof(Expr);

    /* emit the code to fill the list                                      */
    for ( i = 1; i <= len; i++ ) {

        /* if the subexpression is empty                                   */
        if (READ_EXPR(expr, i - 1) == 0) {
            continue;
        }

        /* special case if subexpression is a list expression              */
        else if (TNUM_EXPR(READ_EXPR(expr, i - 1)) == EXPR_LIST) {
            sub = CompListExpr1(READ_EXPR(expr, i - 1));
            Emit( "SET_ELM_PLIST( %c, %d, %c );\n", list, i, sub );
            Emit( "CHANGED_BAG( %c );\n", list );
            CompListExpr2(sub, READ_EXPR(expr, i - 1));
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* special case if subexpression is a record expression            */
        else if (TNUM_EXPR(READ_EXPR(expr, i - 1)) == EXPR_REC) {
            sub = CompRecExpr1(READ_EXPR(expr, i - 1));
            Emit( "SET_ELM_PLIST( %c, %d, %c );\n", list, i, sub );
            Emit( "CHANGED_BAG( %c );\n", list );
            CompRecExpr2(sub, READ_EXPR(expr, i - 1));
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* general case                                                    */
        else {
            sub = CompExpr(READ_EXPR(expr, i - 1));
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
*F  CompRangeExpr( <expr> ) . . . . . . . . . . . . . . . . . .  EXPR_RANGE
*/
static CVar CompRangeExpr(Expr expr)
{
    CVar                range;          /* range, result                   */
    CVar                first;          /* first  element                  */
    CVar                second;         /* second element                  */
    CVar                last;           /* last   element                  */

    /* allocate a new temporary for the range                              */
    range = CVAR_TEMP( NewTemp( "range" ) );

    /* evaluate the expressions                                            */
    if ( SIZE_EXPR(expr) == 2 * sizeof(Expr) ) {
        first  = CompExpr( READ_EXPR(expr, 0) );
        second = 0;
        last   = CompExpr( READ_EXPR(expr, 1) );
    }
    else {
        first  = CompExpr( READ_EXPR(expr, 0) );
        second = CompExpr( READ_EXPR(expr, 1) );
        last   = CompExpr( READ_EXPR(expr, 2) );
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
static CVar CompStringExpr(Expr expr)
{
    CVar                string;         /* string value, result            */
    Obj                 str;            // the actual string object

    /* allocate a new temporary for the string                             */
    string = CVAR_TEMP( NewTemp( "string" ) );

    // get the string of this expression
    str = EVAL_EXPR(expr);

    /* create the string and copy the stuff                                */
    Emit( "%c = MakeString( \"%C\" );\n", string, str);

    /* we know that the result is a list                                   */
    SetInfoCVar( string, W_LIST );

    /* return the string                                                   */
    return string;
}


/****************************************************************************
**
*F  CompRecExpr( <expr> ) . . . . . . . . . . . . . . . . . . . .  EXPR_REC
*/
static CVar CompRecExpr(Expr expr)
{
    CVar                rec;            /* record value, result            */

    /* compile the record expression                                       */
    rec = CompRecExpr1( expr );
    CompRecExpr2( rec, expr );

    return rec;
}


/****************************************************************************
**
*F  CompRecTildeExpr( <expr> )  . . . . . . . . . . . . . .  EXPR_REC_TILDE
*/
static CVar CompRecTildeExpr(Expr expr)
{
    CVar                rec;            /* record value, result            */
    CVar                tilde;          /* old value of tilde              */

    /* remember the old value of '~'                                       */
    tilde = CVAR_TEMP( NewTemp( "tilde" ) );
    Emit( "%c = STATE(Tilde);\n", tilde );

    /* create the record value                                             */
    rec = CompRecExpr1( expr );

    /* assign the record value to the variable '~'                         */
    Emit( "STATE(Tilde) = %c;\n", rec );

    /* evaluate the subexpressions into the record value                   */
    CompRecExpr2( rec, expr );

    /* restore the old value of '~'                                        */
    Emit( "STATE(Tilde) = %c;\n", tilde );
    if ( IS_TEMP_CVAR( tilde ) )  FreeTemp( TEMP_CVAR( tilde ) );

    /* return the record value                                             */
    return rec;
}


/****************************************************************************
**
*F  CompRecExpr1( <expr> )  . . . . . . . . . . . . . . . . . . . . . . local
*/
static CVar CompRecExpr1(Expr expr)
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
static void CompRecExpr2(CVar rec, Expr expr)
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
        tmp = READ_EXPR(expr, 2 * i - 2);
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
        tmp = READ_EXPR(expr, 2 * i - 1);
        if ( tmp == 0 ) {
            if ( IS_TEMP_CVAR( rnam ) )  FreeTemp( TEMP_CVAR( rnam ) );
            continue;
        }

        /* special case if subexpression is a list expression             */
        else if ( TNUM_EXPR( tmp ) == EXPR_LIST ) {
            sub = CompListExpr1( tmp );
            Emit( "AssPRec( %c, (UInt)%c, %c );\n", rec, rnam, sub );
            CompListExpr2( sub, tmp );
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* special case if subexpression is a record expression            */
        else if ( TNUM_EXPR( tmp ) == EXPR_REC ) {
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
*F  CompRefLVar( <expr> ) . . . . . . .  EXPR_REF_LVAR
*/
static CVar CompRefLVar(Expr expr)
{
    CVar                val;            /* value, result                   */
    LVar                lvar;           /* local variable                  */

    lvar = LVAR_REF_LVAR(expr);

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
*F  CompIsbLVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  EXPR_ISB_LVAR
*/
static CVar CompIsbLVar(Expr expr)
{
    CVar                isb;            /* isbound, result                 */
    CVar                val;            /* value                           */
    LVar                lvar;           /* local variable                  */

    /* get the local variable                                              */
    lvar = (LVar)(READ_EXPR(expr, 0));

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

    return isb;
}


/****************************************************************************
**
*F  CompRefHVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  EXPR_REF_HVAR
*/
static CVar CompRefHVar(Expr expr)
{
    CVar                val;            /* value, result                   */
    HVar                hvar;           /* higher variable                 */

    /* get the higher variable                                             */
    hvar = (HVar)(READ_EXPR(expr, 0));
    CompSetUseHVar( hvar );

    /* allocate a new temporary for the value                              */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* emit the code to get the value                                      */
    Emit( "%c = OBJ_HVAR( (%d << 16) | %d );\n",
          val, GetLevlHVar(hvar), GetIndxHVar(hvar) );

    /* emit the code to check that the variable has a value                */
    CompCheckBound( val, NAME_HVAR(hvar) );

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  CompIsbHVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  EXPR_ISB_HVAR
*/
static CVar CompIsbHVar(Expr expr)
{
    CVar                isb;            /* isbound, result                 */
    CVar                val;            /* value                           */
    HVar                hvar;           /* higher variable                 */

    /* get the higher variable                                             */
    hvar = (HVar)(READ_EXPR(expr, 0));
    CompSetUseHVar( hvar );

    /* allocate new temporaries for the value and the result               */
    val = CVAR_TEMP( NewTemp( "val" ) );
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* emit the code to get the value                                      */
    Emit( "%c = OBJ_HVAR( (%d << 16) | %d );\n",
          val, GetLevlHVar(hvar), GetIndxHVar(hvar) );

    /* emit the code to check that the variable has a value                */
    Emit( "%c = ((%c != 0) ? True : False);\n", isb, val );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( val ) )  FreeTemp( TEMP_CVAR( val ) );

    return isb;
}


/****************************************************************************
**
*F  CompRefGVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  EXPR_REF_GVAR
*/
static CVar CompRefGVar(Expr expr)
{
    CVar                val;            /* value, result                   */
    GVar                gvar;           /* higher variable                 */

    /* get the global variable                                             */
    gvar = (GVar)(READ_EXPR(expr, 0));
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
static CVar CompRefGVarFopy(Expr expr)
{
    CVar                val;            /* value, result                   */
    GVar                gvar;           /* higher variable                 */

    /* get the global variable                                             */
    gvar = (GVar)(READ_EXPR(expr, 0));
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
*F  CompIsbGVar( <expr> ) . . . . . . . . . . . . . . . . . . . .  EXPR_ISB_GVAR
*/
static CVar CompIsbGVar(Expr expr)
{
    CVar                isb;            /* isbound, result                 */
    CVar                val;            /* value, result                   */
    GVar                gvar;           /* higher variable                 */

    /* get the global variable                                             */
    gvar = (GVar)(READ_EXPR(expr, 0));
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

    return isb;
}


/****************************************************************************
**
*F  CompElmList( <expr> ) . . . . . . . . . . . . . . . . . . . .  EXPR_ELM_LIST
*/
static CVar CompElmList(Expr expr)
{
    CVar                elm;            /* element, result                 */
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the list expression (checking is done by 'ELM_LIST')        */
    list = CompExpr(READ_EXPR(expr, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_EXPR(expr, 1));
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
*F  CompElmsList( <expr> )  . . . . . . . . . . . . . . . . . . . EXPR_ELMS_LIST
*/
static CVar CompElmsList(Expr expr)
{
    CVar                elms;           /* elements, result                */
    CVar                list;           /* list                            */
    CVar                poss;           /* positions                       */

    /* allocate a new temporary for the elements                           */
    elms = CVAR_TEMP( NewTemp( "elms" ) );

    /* compile the list expression (checking is done by 'ElmsListCheck')   */
    list = CompExpr(READ_EXPR(expr, 0));

    /* compile the position expression (checking done by 'ElmsListCheck')  */
    poss = CompExpr(READ_EXPR(expr, 1));

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
*F  CompElmListLev( <expr> )  . . . . . . . . . . . . . . . .  EXPR_ELM_LIST_LEV
*/
static CVar CompElmListLev(Expr expr)
{
    CVar                lists;          /* lists                           */
    CVar                pos;            /* position                        */
    UInt                level;          /* level                           */

    /* compile the lists expression                                        */
    lists = CompExpr(READ_EXPR(expr, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_EXPR(expr, 1));
    CompCheckIntSmallPos( pos );

    /* get the level                                                       */
    level = READ_EXPR(expr, 2);

    /* emit the code to select the elements from several lists (to <lists>)*/
    Emit( "ElmListLevel( %c, %c, %d );\n", lists, pos, level );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos   ) )  FreeTemp( TEMP_CVAR( pos   ) );

    /* return the lists                                                    */
    return lists;
}


/****************************************************************************
**
*F  CompElmsListLev( <expr> ) . . . . . . . . . . . . . . . . EXPR_ELMS_LIST_LEV
*/
static CVar CompElmsListLev(Expr expr)
{
    CVar                lists;          /* lists                           */
    CVar                poss;           /* positions                       */
    UInt                level;          /* level                           */

    /* compile the lists expression                                        */
    lists = CompExpr(READ_EXPR(expr, 0));

    /* compile the position expression (checking done by 'ElmsListLevel')  */
    poss = CompExpr(READ_EXPR(expr, 1));

    /* get the level                                                       */
    level = READ_EXPR(expr, 2);

    /* emit the code to select the elements from several lists (to <lists>)*/
    Emit( "ElmsListLevelCheck( %c, %c, %d );\n", lists, poss, level );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( poss  ) )  FreeTemp( TEMP_CVAR( poss  ) );

    /* return the lists                                                    */
    return lists;
}


/****************************************************************************
**
*F  CompIsbList( <expr> ) . . . . . . . . . . . . . . . . . . . .  EXPR_ISB_LIST
*/
static CVar CompIsbList(Expr expr)
{
    CVar                isb;            /* isbound, result                 */
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the list expression (checking is done by 'ISB_LIST')        */
    list = CompExpr(READ_EXPR(expr, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_EXPR(expr, 1));
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
*F  CompElmRecName( <expr> )  . . . . . . . . . . . . . . . .  EXPR_ELM_REC_NAME
*/
static CVar CompElmRecName(Expr expr)
{
    CVar                elm;            /* element, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the record expression (checking is done by 'ELM_REC')       */
    record = CompExpr(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);
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
*F  CompElmRecExpr( <expr> )  . . . . . . . . . . . . . . . .  EXPR_ELM_REC_EXPR
*/
static CVar CompElmRecExpr(Expr expr)
{
    CVar                elm;            /* element, result                 */
    CVar                record;         /* the record, left operand        */
    CVar                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the record expression (checking is done by 'ELM_REC')       */
    record = CompExpr(READ_EXPR(expr, 0));

    /* compile the record name expression                                  */
    rnam = CompExpr(READ_EXPR(expr, 1));

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
*F  CompIsbRecName( <expr> )  . . . . . . . . . . . . . . . .  EXPR_ISB_REC_NAME
*/
static CVar CompIsbRecName(Expr expr)
{
    CVar                isb;            /* isbound, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the record expression (checking is done by 'ISB_REC')       */
    record = CompExpr(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code to test the element                                   */
    Emit( "%c = (ISB_REC( %c, R_%n ) ? True : False);\n",
          isb, record, NAME_RNAM(rnam) );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    return isb;
}


/****************************************************************************
**
*F  CompIsbRecExpr( <expr> )  . . . . . . . . . . . . . . . .  EXPR_ISB_REC_EXPR
*/
static CVar CompIsbRecExpr(Expr expr)
{
    CVar                isb;            /* isbound, result                 */
    CVar                record;         /* the record, left operand        */
    CVar                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the record expression (checking is done by 'ISB_REC')       */
    record = CompExpr(READ_EXPR(expr, 0));

    /* compile the record name expression                                  */
    rnam = CompExpr(READ_EXPR(expr, 1));

    /* emit the code to test the element                                   */
    Emit( "%c = (ISB_REC( %c, RNamObj(%c) ) ? True : False);\n",
          isb, record, rnam );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    return isb;
}


/****************************************************************************
**
*F  CompElmPosObj( <expr> ) . . . . . . . . . . . . . . . . . .  EXPR_ELM_POSOBJ
*/
static CVar CompElmPosObj(Expr expr)
{
    CVar                elm;            /* element, result                 */
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the list expression (checking is done by 'ELM_LIST')        */
    list = CompExpr(READ_EXPR(expr, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_EXPR(expr, 1));
    CompCheckIntSmallPos( pos );

    /* emit the code to get the element                                    */
    Emit( "%c = ElmPosObj( %c, %i );\n", elm, list, pos );

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
*F  CompIsbPosObj( <expr> ) . . . . . . . . . . . . . . . . . .  EXPR_ISB_POSOBJ
*/
static CVar CompIsbPosObj(Expr expr)
{
    CVar                isb;            /* isbound, result                 */
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the list expression (checking is done by 'ISB_LIST')        */
    list = CompExpr(READ_EXPR(expr, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_EXPR(expr, 1));
    CompCheckIntSmallPos( pos );

    /* emit the code to test the element                                   */
    Emit( "%c = IsbPosObj( %c, %i ) ? True : False;\n", isb, list, pos );

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
*F  CompElmObjName( <expr> )  . . . . . . . . . . . . . . . EXPR_ELM_COMOBJ_NAME
*/
static CVar CompElmComObjName(Expr expr)
{
    CVar                elm;            /* element, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the record expression (checking is done by 'ELM_REC')       */
    record = CompExpr(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code to select the element of the record                   */
    Emit( "%c = ElmComObj( %c, R_%n );\n", elm, record, NAME_RNAM(rnam) );

    /* we know that we have a value                                        */
    SetInfoCVar( elm, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    /* return the element                                                  */
    return elm;
}



/****************************************************************************
**
*F  CompElmComObjExpr( <expr> ) . . . . . . . . . . . . . . EXPR_ELM_COMOBJ_EXPR
*/
static CVar CompElmComObjExpr(Expr expr)
{
    CVar                elm;            /* element, result                 */
    CVar                record;         /* the record, left operand        */
    CVar                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the element                            */
    elm = CVAR_TEMP( NewTemp( "elm" ) );

    /* compile the record expression (checking is done by 'ELM_REC')       */
    record = CompExpr(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = CompExpr(READ_EXPR(expr, 1));

    /* emit the code to select the element of the record                   */
    Emit( "%c = ElmComObj( %c, RNamObj(%c) );\n", elm, record, rnam );

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
*F  CompIsbComObjName( <expr> ) . . . . . . . . . . . . . . EXPR_ISB_COMOBJ_NAME
*/
static CVar CompIsbComObjName(Expr expr)
{
    CVar                isb;            /* isbound, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the record expression (checking is done by 'ISB_REC')       */
    record = CompExpr(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = READ_EXPR(expr, 1);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code to test the element                                   */
    Emit( "%c = IsbComObj( %c, R_%n ) ? True : False;\n",
          isb, record, NAME_RNAM(rnam) );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

    return isb;
}


/****************************************************************************
**
*F  CompIsbComObjExpr( <expr> ) . . . . . . . . . . . . . . EXPR_ISB_COMOBJ_EXPR
*/
static CVar CompIsbComObjExpr(Expr expr)
{
    CVar                isb;            /* isbound, result                 */
    CVar                record;         /* the record, left operand        */
    UInt                rnam;           /* the name, right operand         */

    /* allocate a new temporary for the result                             */
    isb = CVAR_TEMP( NewTemp( "isb" ) );

    /* compile the record expression (checking is done by 'ISB_REC')       */
    record = CompExpr(READ_EXPR(expr, 0));

    /* get the name (stored immediately in the expression)                 */
    rnam = CompExpr(READ_EXPR(expr, 1));

    /* emit the code to test the element                                   */
    Emit( "%c = IsbComObj( %c, RNamObj(%c) ) ? True : False;\n",
          isb, record, rnam );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );

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
static void (*CompStatFuncs[256])(Stat stat);

static void CompStat(Stat stat)
{
    (* CompStatFuncs[ TNUM_STAT(stat) ])( stat );
}


/****************************************************************************
**
*F  CompUnknownStat( <stat> ) . . . . . . . . . . . . . . . . signal an error
*/
static void CompUnknownStat(Stat stat)
{
    Emit( "CANNOT COMPILE STATEMENT OF TNUM %d;\n", TNUM_STAT(stat) );
}


/****************************************************************************
**
*V  G_Add . . . . . . . . . . . . . . . . . . . . . . . . . .  function 'Add'
*/
static GVar G_Add;


/****************************************************************************
**
*F  CompProccall0to6Args( <stat> )  . . . STAT_PROCCALL_0ARGS...STAT_PROCCALL_6ARGS
*/
static void CompProccall0to6Args(Stat stat)
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
      && TNUM_EXPR( FUNC_CALL(stat) ) == EXPR_REF_GVAR
      && READ_EXPR( FUNC_CALL(stat), 0 ) == G_Add
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
    if ( TNUM_EXPR( FUNC_CALL(stat) ) == EXPR_REF_GVAR ) {
        func = CompRefGVarFopy( FUNC_CALL(stat) );
    }
    else {
        func = CompExpr( FUNC_CALL(stat) );
    }

    /* compile the argument expressions                                    */
    narg = NARG_SIZE_CALL(SIZE_STAT(stat));
    for ( i = 1; i <= narg; i++ ) {
        args[i] = CompExpr( ARGI_CALL(stat,i) );
    }

    /* emit the code for the procedure call                                */
    Emit( "if ( TNUM_OBJ( %c ) == T_FUNCTION ) {\n", func );
    Emit( "CALL_%dARGS( %c", narg, func );
    for ( i = 1; i <= narg; i++ ) {
        Emit( ", %c", args[i] );
    }
    Emit( " );\n" );
    Emit( "}\n" );
    Emit( "else {\n" );
    Emit( "DoOperation2Args( CallFuncListOper, %c, NewPlistFromArgs(", func);
    if (narg >= 1) {
        Emit( " %c", args[1] );
    }
    for ( i = 2; i <= narg; i++ ) {
        Emit( ", %c", args[i] );
    }
    Emit( " ) );\n" );
    Emit( "}\n" );

    /* free the temporaries                                                */
    for ( i = narg; 1 <= i; i-- ) {
        if ( IS_TEMP_CVAR( args[i] ) )  FreeTemp( TEMP_CVAR( args[i] ) );
    }
    if ( IS_TEMP_CVAR( func ) )  FreeTemp( TEMP_CVAR( func ) );
}


/****************************************************************************
**
*F  CompProccallXArgs . . . . . . . . . . . . . . . . . . .  STAT_PROCCALL_XARGS
*/
static void CompProccallXArgs(Stat stat)
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
    if ( TNUM_EXPR( FUNC_CALL(stat) ) == EXPR_REF_GVAR ) {
        func = CompRefGVarFopy( FUNC_CALL(stat) );
    }
    else {
        func = CompExpr( FUNC_CALL(stat) );
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
    Emit( "if ( TNUM_OBJ( %c ) == T_FUNCTION ) {\n", func );
    Emit( "CALL_XARGS( %c, %c );\n", func, argl );
    Emit( "}\n" );
    Emit( "else {\n" );
    Emit( "DoOperation2Args( CallFuncListOper, %c, %c );\n", func, argl );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( argl ) )  FreeTemp( TEMP_CVAR( argl ) );
    if ( IS_TEMP_CVAR( func ) )  FreeTemp( TEMP_CVAR( func ) );
}

/****************************************************************************
**
*F  CompProccallXArgs( <expr> ) . . . . . . . . . . . . . .  STAT_PROCCALL_OPTS
*/
static void CompProccallOpts(Stat stat)
{
  CVar opts = CompExpr(READ_STAT(stat, 0));
  GVar pushOptions;
  GVar popOptions;
  pushOptions = GVarName("PushOptions");
  popOptions = GVarName("PopOptions");
  CompSetUseGVar(pushOptions, COMP_USE_GVAR_FOPY);
  CompSetUseGVar(popOptions, COMP_USE_GVAR_FOPY);
  Emit("CALL_1ARGS( GF_PushOptions, %c );\n", opts);
  if (IS_TEMP_CVAR( opts) ) FreeTemp( TEMP_CVAR( opts ));
  CompStat(READ_STAT(stat, 1));
  Emit("CALL_0ARGS( GF_PopOptions );\n");
}
     

/****************************************************************************
**
*F  CompSeqStat( <stat> ) . . . . . . . . . . . . .  STAT_SEQ_STAT...STAT_SEQ_STAT7
*/
static void CompSeqStat(Stat stat)
{
    UInt                nr;             /* number of statements            */
    UInt                i;              /* loop variable                   */

    /* get the number of statements                                        */
    nr = SIZE_STAT( stat ) / sizeof(Stat);

    /* compile the statements                                              */
    for ( i = 1; i <= nr; i++ ) {
        CompStat(READ_STAT(stat, i - 1));
    }
}


/****************************************************************************
**
*F  CompIf( <stat> )  . . . . . . . . STAT_IF/STAT_IF_ELSE/STAT_IF_ELIF/STAT_IF_ELIF_ELSE
*/
static void CompIf(Stat stat)
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
        PrintExpr(READ_EXPR(stat, 0));
        Emit( " then */\n" );
    }

    /* compile the expression                                              */
    cond = CompBoolExpr(READ_STAT(stat, 0));

    /* emit the code to test the condition                                 */
    Emit( "if ( %c ) {\n", cond );
    if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );

    /* remember what we know after evaluating the first condition          */
    info_in = NewInfoCVars();
    CopyInfoCVars( info_in, INFO_FEXP(CURR_FUNC()) );

    /* compile the body                                                    */
    CompStat(READ_STAT(stat, 1));

    /* remember what we know after executing the first body                */
    info_out = NewInfoCVars();
    CopyInfoCVars( info_out, INFO_FEXP(CURR_FUNC()) );

    /* emit the rest code                                                  */
    Emit( "\n}\n" );

    /* loop over the 'elif' branches                                       */
    for ( i = 2; i <= nr; i++ ) {

        /* do not handle 'else' branch here                                */
        if (i == nr && TNUM_EXPR(READ_STAT(stat, 2 * (i - 1))) == EXPR_TRUE)
            break;

        /* print a comment                                                 */
        if ( CompPass == 2 ) {
            Emit( "\n/* elif " );
            PrintExpr(READ_EXPR(stat, 2 * (i - 1)));
            Emit( " then */\n" );
        }

        /* emit the 'else' to connect this branch to the 'if' branch       */
        Emit( "else {\n" );

        /* this is what we know if we enter this branch                    */
        CopyInfoCVars( INFO_FEXP(CURR_FUNC()), info_in );

        /* compile the expression                                          */
        cond = CompBoolExpr(READ_STAT(stat, 2 * (i - 1)));

        /* emit the code to test the condition                             */
        Emit( "if ( %c ) {\n", cond );
        if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );

        /* remember what we know after evaluating all previous conditions  */
        CopyInfoCVars( info_in, INFO_FEXP(CURR_FUNC()) );

        /* compile the body                                                */
        CompStat(READ_STAT(stat, 2 * (i - 1) + 1));

        /* remember what we know after executing one of the previous bodies*/
        MergeInfoCVars( info_out, INFO_FEXP(CURR_FUNC()) );

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
        CopyInfoCVars( INFO_FEXP(CURR_FUNC()), info_in );

        /* compile the body                                                */
        CompStat(READ_STAT(stat, 2 * (i - 1) + 1));

        /* remember what we know after executing one of the previous bodies*/
        MergeInfoCVars( info_out, INFO_FEXP(CURR_FUNC()) );

        /* emit the rest code                                              */
        Emit( "\n}\n" );

    }

    /* fake empty 'else' branch                                            */
    else {

        /* this is what we know if we enter this branch                    */
        CopyInfoCVars( INFO_FEXP(CURR_FUNC()), info_in );

        /* remember what we know after executing one of the previous bodies*/
        MergeInfoCVars( info_out, INFO_FEXP(CURR_FUNC()) );

    }

    /* close all unbalanced parenthesis                                    */
    for ( i = 2; i <= nr; i++ ) {
        if (i == nr && TNUM_EXPR(READ_STAT(stat, 2 * (i - 1))) == EXPR_TRUE)
            break;
        Emit( "}\n" );
    }
    Emit( "/* fi */\n" );

    /* put what we know into the current info                              */
    CopyInfoCVars( INFO_FEXP(CURR_FUNC()), info_out );

}


/****************************************************************************
**
*F  CompFor( <stat> ) . . . . . . . STAT_FOR...STAT_FOR3/STAT_FOR_RANGE...STAT_FOR_RANGE3
*/
static void CompFor(Stat stat)
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
    if ( IS_REF_LVAR( READ_STAT(stat, 0) )
      && ! CompGetUseHVar( LVAR_REF_LVAR( READ_STAT(stat, 0) ) )
      && TNUM_EXPR( READ_STAT(stat, 1) ) == EXPR_RANGE
      && SIZE_EXPR( READ_STAT(stat, 1) ) == 2*sizeof(Expr) ) {

        /* print a comment                                                 */
        if ( CompPass == 2 ) {
            Emit( "\n/* for " );
            PrintExpr(READ_EXPR(stat, 0));
            Emit( " in " );
            PrintExpr(READ_EXPR(stat, 1));
            Emit( " do */\n" );
        }

        /* get the local variable                                          */
        var = LVAR_REF_LVAR(READ_STAT(stat, 0));

        /* allocate a new temporary for the loop variable                  */
        lidx = CVAR_TEMP( NewTemp( "lidx" ) );

        /* compile and check the first and last value                      */
        first = CompExpr(READ_EXPR(READ_STAT(stat, 1), 0));
        CompCheckIntSmall( first );

        /* compile and check the last value                                */
        /* if the last value is in a local variable,                       */
        /* we must copy it into a temporary,                               */
        /* because the local variable may change its value in the body     */
        last = CompExpr(READ_EXPR(READ_STAT(stat, 1), 1));
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
            CopyInfoCVars( prev, INFO_FEXP(CURR_FUNC()) );
            if ( HasInfoCVar( first, W_INT_SMALL_POS ) ) {
                SetInfoCVar( CVAR_LVAR(var), W_INT_SMALL_POS );
            }
            else {
                SetInfoCVar( CVAR_LVAR(var), W_INT_SMALL );
            }
            for ( i = 2; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
                CompStat(READ_STAT(stat, i));
            }
            MergeInfoCVars( INFO_FEXP(CURR_FUNC()), prev );
        } while ( ! IsEqInfoCVars( INFO_FEXP(CURR_FUNC()), prev ) );
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
            CompStat(READ_STAT(stat, i));
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
            PrintExpr(READ_EXPR(stat, 0));
            Emit( " in " );
            PrintExpr(READ_EXPR(stat, 1));
            Emit( " do */\n" );
        }

        /* get the variable (initialize them first to please 'lint')       */
        if ( IS_REF_LVAR( READ_STAT(stat, 0) )
          && ! CompGetUseHVar( LVAR_REF_LVAR( READ_STAT(stat, 0) ) ) ) {
            var = LVAR_REF_LVAR( READ_STAT(stat, 0) );
            vart = 'l';
        }
        else if (IS_REF_LVAR(READ_STAT(stat, 0))) {
            var = LVAR_REF_LVAR(READ_STAT(stat, 0));
            vart = 'm';
        }
        else if (TNUM_EXPR(READ_STAT(stat, 0)) == EXPR_REF_HVAR) {
            var = READ_EXPR(READ_STAT(stat, 0), 0);
            vart = 'h';
        }
        else /* if ( TNUM_EXPR( READ_STAT(stat, 0) ) == EXPR_REF_GVAR ) */ {
            var = READ_EXPR(READ_STAT(stat, 0), 0);
            CompSetUseGVar( var, COMP_USE_GVAR_ID );
            vart = 'g';
        }

        /* allocate a new temporary for the loop variable                  */
        lidx   = CVAR_TEMP( NewTemp( "lidx"   ) );
        elm    = CVAR_TEMP( NewTemp( "elm"    ) );
        islist = CVAR_TEMP( NewTemp( "islist" ) );

        /* compile and check the first and last value                      */
        list = CompExpr(READ_STAT(stat, 1));

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
            CopyInfoCVars( prev, INFO_FEXP(CURR_FUNC()) );
            if ( vart == 'l' ) {
                SetInfoCVar( CVAR_LVAR(var), W_BOUND );
            }
            for ( i = 2; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
                CompStat(READ_STAT(stat, i));
            }
            MergeInfoCVars( INFO_FEXP(CURR_FUNC()), prev );
        } while ( ! IsEqInfoCVars( INFO_FEXP(CURR_FUNC()), prev ) );
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
            Emit( "ASS_HVAR( (%d << 16) | %d, %c );\n",
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
            CompStat(READ_STAT(stat, i));
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
*F  CompWhile( <stat> ) . . . . . . . . . . . . . . . . .  STAT_WHILE...STAT_WHILE3
*/
static void CompWhile(Stat stat)
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
        CopyInfoCVars( prev, INFO_FEXP(CURR_FUNC()) );
        cond = CompBoolExpr(READ_STAT(stat, 0));
        Emit( "if ( ! %c ) break;\n", cond );
        if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );
        for ( i = 1; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
            CompStat(READ_STAT(stat, i));
        }
        MergeInfoCVars( INFO_FEXP(CURR_FUNC()), prev );
    } while ( ! IsEqInfoCVars( INFO_FEXP(CURR_FUNC()), prev ) );
    Emit( "}\n" );
    CompPass = pass;

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* while " );
        PrintExpr(READ_EXPR(stat, 0));
        Emit( " do */\n" );
    }

    /* emit the code for the loop                                          */
    Emit( "while ( 1 ) {\n" );

    /* compile the condition                                               */
    cond = CompBoolExpr(READ_STAT(stat, 0));
    Emit( "if ( ! %c ) break;\n", cond );
    if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );

    /* compile the body                                                    */
    for ( i = 1; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
        CompStat(READ_STAT(stat, i));
    }

    /* thats it                                                            */
    Emit( "\n}\n" );
    Emit( "/* od */\n" );

}


/****************************************************************************
**
*F  CompRepeat( <stat> )  . . . . . . . . . . . . . . .  STAT_REPEAT...STAT_REPEAT3
*/
static void CompRepeat(Stat stat)
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
        CopyInfoCVars( prev, INFO_FEXP(CURR_FUNC()) );
        for ( i = 1; i < SIZE_STAT(stat)/sizeof(Stat); i++ ) {
            CompStat(READ_STAT(stat, i));
        }
        cond = CompBoolExpr(READ_STAT(stat, 0));
        Emit( "if ( %c ) break;\n", cond );
        if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );
        MergeInfoCVars( INFO_FEXP(CURR_FUNC()), prev );
    } while ( ! IsEqInfoCVars( INFO_FEXP(CURR_FUNC()), prev ) );
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
        CompStat(READ_STAT(stat, i));
    }

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* until " );
        PrintExpr(READ_EXPR(stat, 0));
        Emit( " */\n" );
    }

    /* compile the condition                                               */
    cond = CompBoolExpr(READ_STAT(stat, 0));
    Emit( "if ( %c ) break;\n", cond );
    if ( IS_TEMP_CVAR( cond ) )  FreeTemp( TEMP_CVAR( cond ) );

    /* thats it                                                            */
    Emit( "} while ( 1 );\n" );
}


/****************************************************************************
**
*F  CompBreak( <stat> ) . . . . . . . . . . . . . . . . . . . . . . . STAT_BREAK
*/
static void CompBreak(Stat stat)
{
    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    Emit( "break;\n" );
}

/****************************************************************************
**
*F  CompContinue( <stat> ) . . . . . . . . . . . . . . . . . . . . STAT_CONTINUE
*/
static void CompContinue(Stat stat)
{
    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    Emit( "continue;\n" );
}


/****************************************************************************
**
*F  CompReturnObj( <stat> ) . . . . . . . . . . . . . . . . . .  STAT_RETURN_OBJ
*/
static void CompReturnObj(Stat stat)
{
    CVar                obj;            /* returned object                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the expression                                              */
    obj = CompExpr(READ_STAT(stat, 0));

    /* emit code to remove stack frame                                     */
    Emit( "SWITCH_TO_OLD_FRAME(oldFrame);\n" );

    /* emit code to return from function                                   */
    Emit( "return %c;\n", obj );

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( obj ) )  FreeTemp( TEMP_CVAR( obj ) );
}


/****************************************************************************
**
*F  CompReturnVoid( <stat> )  . . . . . . . . . . . . . . . . . STAT_RETURN_VOID
*/
static void CompReturnVoid(Stat stat)
{
    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* emit code to remove stack frame                                     */
    Emit( "SWITCH_TO_OLD_FRAME(oldFrame);\n" );

    /* emit code to return from function                                   */
    Emit( "return 0;\n" );
}


/****************************************************************************
**
*F  CompAssLVar( <stat> ) . . . . . . . . . . . .  STAT_ASS_LVAR...T_ASS_LVAR_16
*/
static void CompAssLVar(Stat stat)
{
    LVar                lvar;           /* local variable                  */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the right hand side expression                              */
    rhs = CompExpr(READ_STAT(stat, 1));

    /* emit the code for the assignment                                    */
    lvar = (LVar)(READ_STAT(stat, 0));
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
*F  CompUnbLVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  STAT_UNB_LVAR
*/
static void CompUnbLVar(Stat stat)
{
    LVar                lvar;           /* local variable                  */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* emit the code for the assignment                                    */
    lvar = (LVar)(READ_STAT(stat, 0));
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
*F  CompAssHVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  STAT_ASS_HVAR
*/
static void CompAssHVar(Stat stat)
{
    HVar                hvar;           /* higher variable                 */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the right hand side expression                              */
    rhs = CompExpr(READ_STAT(stat, 1));

    /* emit the code for the assignment                                    */
    hvar = (HVar)(READ_STAT(stat, 0));
    CompSetUseHVar( hvar );
    Emit( "ASS_HVAR( (%d << 16) | %d, %c );\n",
          GetLevlHVar(hvar), GetIndxHVar(hvar), rhs );

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( rhs ) )  FreeTemp( TEMP_CVAR( rhs ) );
}


/****************************************************************************
**
*F  CompUnbHVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  STAT_UNB_HVAR
*/
static void CompUnbHVar(Stat stat)
{
    HVar                hvar;           /* higher variable                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* emit the code for the assignment                                    */
    hvar = (HVar)(READ_STAT(stat, 0));
    CompSetUseHVar( hvar );
    Emit( "ASS_HVAR( (%d << 16) | %d, 0 );\n",
          GetLevlHVar(hvar), GetIndxHVar(hvar) );
}


/****************************************************************************
**
*F  CompAssGVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  STAT_ASS_GVAR
*/
static void CompAssGVar(Stat stat)
{
    GVar                gvar;           /* global variable                 */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the right hand side expression                              */
    rhs = CompExpr(READ_STAT(stat, 1));

    /* emit the code for the assignment                                    */
    gvar = (GVar)(READ_STAT(stat, 0));
    CompSetUseGVar( gvar, COMP_USE_GVAR_ID );
    Emit( "AssGVar( G_%n, %c );\n", NameGVar(gvar), rhs );

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( rhs ) )  FreeTemp( TEMP_CVAR( rhs ) );
}


/****************************************************************************
**
*F  CompUnbGVar( <stat> ) . . . . . . . . . . . . . . . . . . . .  STAT_UNB_GVAR
*/
static void CompUnbGVar(Stat stat)
{
    GVar                gvar;           /* global variable                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* emit the code for the assignment                                    */
    gvar = (GVar)(READ_STAT(stat, 0));
    CompSetUseGVar( gvar, COMP_USE_GVAR_ID );
    Emit( "AssGVar( G_%n, 0 );\n", NameGVar(gvar) );
}


/****************************************************************************
**
*F  CompAssList( <stat> ) . . . . . . . . . . . . . . . . . . . .  STAT_ASS_LIST
*/
static void CompAssList(Stat stat)
{
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr(READ_STAT(stat, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_STAT(stat, 1));
    CompCheckIntPos( pos );

    /* compile the right hand side                                         */
    rhs = CompExpr(READ_STAT(stat, 2));

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
*F  CompAsssList( <stat> )  . . . . . . . . . . . . . . . . . . . STAT_ASSS_LIST
*/
static void CompAsssList(Stat stat)
{
    CVar                list;           /* list                            */
    CVar                poss;           /* positions                       */
    CVar                rhss;           /* right hand sides                */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr(READ_STAT(stat, 0));

    /* compile and check the position expression                           */
    poss = CompExpr(READ_STAT(stat, 1));

    /* compile the right hand side                                         */
    rhss = CompExpr(READ_STAT(stat, 2));

    /* emit the code                                                       */
    Emit( "AsssListCheck( %c, %c, %c );\n", list, poss, rhss );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhss ) )  FreeTemp( TEMP_CVAR( rhss ) );
    if ( IS_TEMP_CVAR( poss ) )  FreeTemp( TEMP_CVAR( poss ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  CompAssListLev( <stat> )  . . . . . . . . . . . . . . . .  STAT_ASS_LIST_LEV
*/
static void CompAssListLev(Stat stat)
{
    CVar                lists;          /* lists                           */
    CVar                pos;            /* position                        */
    CVar                rhss;           /* right hand sides                */
    UInt                level;          /* level                           */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expressions                                        */
    lists = CompExpr(READ_STAT(stat, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_STAT(stat, 1));
    CompCheckIntSmallPos( pos );

    /* compile the right hand sides                                        */
    rhss = CompExpr(READ_STAT(stat, 2));

    /* get the level                                                       */
    level = READ_STAT(stat, 3);

    /* emit the code                                                       */
    Emit( "AssListLevel( %c, %c, %c, %d );\n", lists, pos, rhss, level );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhss  ) )  FreeTemp( TEMP_CVAR( rhss  ) );
    if ( IS_TEMP_CVAR( pos   ) )  FreeTemp( TEMP_CVAR( pos   ) );
    if ( IS_TEMP_CVAR( lists ) )  FreeTemp( TEMP_CVAR( lists ) );
}


/****************************************************************************
**
*F  CompAsssListLev( <stat> ) . . . . . . . . . . . . . . . . STAT_ASSS_LIST_LEV
*/
static void CompAsssListLev(Stat stat)
{
    CVar                lists;          /* list                            */
    CVar                poss;           /* positions                       */
    CVar                rhss;           /* right hand sides                */
    UInt                level;          /* level                           */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expressions                                        */
    lists = CompExpr(READ_STAT(stat, 0));

    /* compile and check the position expression                           */
    poss = CompExpr(READ_STAT(stat, 1));

    /* compile the right hand side                                         */
    rhss = CompExpr(READ_STAT(stat, 2));

    /* get the level                                                       */
    level = READ_STAT(stat, 3);

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
*F  CompUnbList( <stat> ) . . . . . . . . . . . . . . . . . . . .  STAT_UNB_LIST
*/
static void CompUnbList(Stat stat)
{
    CVar                list;           /* list, left operand              */
    CVar                pos;            /* position, left operand          */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr(READ_STAT(stat, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_STAT(stat, 1));
    CompCheckIntPos( pos );

    /* emit the code                                                       */
    Emit( "C_UNB_LIST( %c, %c );\n", list, pos );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  CompAssRecName( <stat> )  . . . . . . . . . . . . . . . .  STAT_ASS_REC_NAME
*/
static void CompAssRecName(Stat stat)
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* compile the right hand side                                         */
    rhs = CompExpr(READ_STAT(stat, 2));

    /* emit the code for the assignment                                    */
    Emit( "ASS_REC( %c, R_%n, %c );\n", record, NAME_RNAM(rnam), rhs );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompAssRecExpr( <stat> )  . . . . . . . . . . . . . . . .  STAT_ASS_REC_EXPR
*/
static void CompAssRecExpr(Stat stat)
{
    CVar                record;         /* record, left operand            */
    CVar                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = CompExpr(READ_STAT(stat, 1));

    /* compile the right hand side                                         */
    rhs = CompExpr(READ_STAT(stat, 2));

    /* emit the code for the assignment                                    */
    Emit( "ASS_REC( %c, RNamObj(%c), %c );\n", record, rnam, rhs );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompUnbRecName( <stat> )  . . . . . . . . . . . . . . . .  STAT_UNB_REC_NAME
*/
static void CompUnbRecName(Stat stat)
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code for the assignment                                    */
    Emit( "UNB_REC( %c, R_%n );\n", record, NAME_RNAM(rnam) );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompUnbRecExpr( <stat> )  . . . . . . . . . . . . . . . .  STAT_UNB_REC_EXPR
*/
static void CompUnbRecExpr(Stat stat)
{
    CVar                record;         /* record, left operand            */
    CVar                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr(READ_STAT(stat, 0));

    /* get the name expression                                             */
    rnam = CompExpr(READ_STAT(stat, 1));

    /* emit the code for the assignment                                    */
    Emit( "UNB_REC( %c, RNamObj(%c) );\n", record, rnam );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompAssPosObj( <stat> ) . . . . . . . . . . . . . . . . . .  STAT_ASS_POSOBJ
*/
static void CompAssPosObj(Stat stat)
{
    CVar                list;           /* list                            */
    CVar                pos;            /* position                        */
    CVar                rhs;            /* right hand side                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr(READ_STAT(stat, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_STAT(stat, 1));
    CompCheckIntSmallPos( pos );

    /* compile the right hand side                                         */
    rhs = CompExpr(READ_STAT(stat, 2));

    /* emit the code                                                       */
    Emit( "AssPosObj( %c, %i, %c );\n", list, pos, rhs );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs  ) )  FreeTemp( TEMP_CVAR( rhs  ) );
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  CompUnbPosObj( <stat> ) . . . . . . . . . . . . . . . . . .  STAT_UNB_POSOBJ
*/
static void CompUnbPosObj(Stat stat)
{
    CVar                list;           /* list, left operand              */
    CVar                pos;            /* position, left operand          */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the list expression                                         */
    list = CompExpr(READ_STAT(stat, 0));

    /* compile and check the position expression                           */
    pos = CompExpr(READ_STAT(stat, 1));
    CompCheckIntSmallPos( pos );

    /* emit the code                                                       */
    Emit( "UnbPosObj( %c, %i );\n", list, pos );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}


/****************************************************************************
**
*F  CompAssComObjName( <stat> ) . . . . . . . . . . . . . . STAT_ASS_COMOBJ_NAME
*/
static void CompAssComObjName(Stat stat)
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* compile the right hand side                                         */
    rhs = CompExpr(READ_STAT(stat, 2));

    /* emit the code for the assignment                                    */
    Emit( "AssComObj( %c, R_%n, %c );\n", record, NAME_RNAM(rnam), rhs );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompAssComObjExpr( <stat> ) . . . . . . . . . . . . . . STAT_ASS_COMOBJ_EXPR
*/
static void CompAssComObjExpr(Stat stat)
{
    CVar                record;         /* record, left operand            */
    CVar                rnam;           /* name, left operand              */
    CVar                rhs;            /* rhs, right operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = CompExpr(READ_STAT(stat, 1));

    /* compile the right hand side                                         */
    rhs = CompExpr(READ_STAT(stat, 2));

    /* emit the code for the assignment                                    */
    Emit( "AssComObj( %c, RNamObj(%c), %c );\n", record, rnam, rhs );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs    ) )  FreeTemp( TEMP_CVAR( rhs    ) );
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompUnbComObjName( <stat> ) . . . . . . . . . . . . . . STAT_UNB_COMOBJ_NAME
*/
static void CompUnbComObjName(Stat stat)
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr(READ_STAT(stat, 0));

    /* get the name (stored immediately in the statement)                  */
    rnam = READ_STAT(stat, 1);
    CompSetUseRNam( rnam, COMP_USE_RNAM_ID );

    /* emit the code for the assignment                                    */
    Emit( "UnbComObj( %c, R_%n );\n", record, NAME_RNAM(rnam) );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}


/****************************************************************************
**
*F  CompUnbComObjExpr( <stat> ) . . . . . . . . . . . . . . STAT_UNB_COMOBJ_EXPR
*/
static void CompUnbComObjExpr(Stat stat)
{
    CVar                record;         /* record, left operand            */
    UInt                rnam;           /* name, left operand              */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the record expression                                       */
    record = CompExpr(READ_STAT(stat, 0));

    /* get the name expression                                             */
    rnam = CompExpr(READ_STAT(stat, 1));

    /* emit the code for the assignment                                    */
    Emit( "UnbComObj( %c, RNamObj(%c) );\n", record, rnam );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rnam   ) )  FreeTemp( TEMP_CVAR( rnam   ) );
    if ( IS_TEMP_CVAR( record ) )  FreeTemp( TEMP_CVAR( record ) );
}

/****************************************************************************
**
*F  CompEmpty( <stat> )  . . . . . . . . . . . . . . . . . . . . . . . T_EMPY
*/
static void CompEmpty(Stat stat)
{
    // do nothing
}
  
/****************************************************************************
**
*F  CompInfo( <stat> )  . . . . . . . . . . . . . . . . . . . . . . .  STAT_INFO
*/
static void CompInfo(Stat stat)
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
    Emit( "%c = InfoCheckLevel( %c, %c );\n", tmp, sel, lev );
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
    Emit( "InfoDoPrint( %c, %c, %c );\n", sel, lev, lst );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( lst ) )  FreeTemp( TEMP_CVAR( lst ) );
    if ( IS_TEMP_CVAR( lev ) )  FreeTemp( TEMP_CVAR( lev ) );
    if ( IS_TEMP_CVAR( sel ) )  FreeTemp( TEMP_CVAR( sel ) );
}


/****************************************************************************
**
*F  CompAssert2( <stat> ) . . . . . . . . . . . . . . . . . .  STAT_ASSERT_2ARGS
*/
static void CompAssert2(Stat stat)
{
    CVar                lev;            /* the level                       */
    CVar                cnd;            /* the condition                   */

    Emit( "\n/* Assert( ... ); */\n" );
    lev = CompExpr(READ_STAT(stat, 0));
    Emit( "if ( STATE(CurrentAssertionLevel) >= %i ) {\n", lev );
    cnd = CompBoolExpr(READ_STAT(stat, 1));
    Emit( "if ( ! %c ) {\n", cnd );
    Emit( "AssertionFailure();\n" );
    Emit( "}\n" );
    Emit( "}\n" );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( cnd ) )  FreeTemp( TEMP_CVAR( cnd ) );
    if ( IS_TEMP_CVAR( lev ) )  FreeTemp( TEMP_CVAR( lev ) );
}


/****************************************************************************
**
*F  CompAssert3( <stat> ) . . . . . . . . . . . . . . . . . .  STAT_ASSERT_3ARGS
*/
static void CompAssert3(Stat stat)
{
    CVar                lev;            /* the level                       */
    CVar                cnd;            /* the condition                   */
    CVar                msg;            /* the message                     */

    Emit( "\n/* Assert( ... ); */\n" );
    lev = CompExpr(READ_STAT(stat, 0));
    Emit( "if ( STATE(CurrentAssertionLevel) >= %i ) {\n", lev );
    cnd = CompBoolExpr(READ_STAT(stat, 1));
    Emit( "if ( ! %c ) {\n", cnd );
    msg = CompExpr(READ_STAT(stat, 2));
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
static Obj CompFunctions;

static void CompFunc(Obj func)
{
    Bag                 info;           /* info bag for this function      */
    Int                 narg;           /* number of arguments             */
    Int                 nloc;           /* number of locals                */
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

        UInt nr = PushPlist( CompFunctions, func );

        info = NewKernelBuffer(SIZE_INFO(narg+nloc,8));
        NEXT_INFO(info)  = INFO_FEXP( CURR_FUNC() );
        NR_INFO(info)    = nr;
        NLVAR_INFO(info) = narg + nloc;
        NHVAR_INFO(info) = 0;
        NTEMP_INFO(info) = 0;

        SET_INFO_FEXP(func, info);
        CHANGED_BAG(func);

    }

    /* switch to this function (so that 'CONST_ADDR_STAT' and 'CONST_ADDR_EXPR' work)  */
    oldFrame = SWITCH_TO_NEW_LVARS(func, narg, nloc);

    /* get the info bag                                                    */
    info = INFO_FEXP( CURR_FUNC() );

    /* compile the inner functions                                         */
    Obj values = VALUES_BODY(BODY_FUNC(func));
    if (values) {
        UInt len = LEN_PLIST(values);
        for (i = 1; i <= len; i++) {
            Obj val = ELM_PLIST(values, i);
            if (IS_FUNC(val))
                CompFunc(val);
        }
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

    for ( i = 1; i <= nloc; i++ ) {
        if ( ! CompGetUseHVar( i+narg ) ) {
            Emit( "(void)%c;\n", CVAR_LVAR(i+narg) );
        }
    }

    /* emit the code for the higher variables                              */
    Emit( "Bag oldFrame;\n" );

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
    Emit( "\n/* allocate new stack frame */\n" );
    Emit( "SWITCH_TO_NEW_FRAME(self,%d,0,oldFrame);\n",NHVAR_INFO(info));
    if (NHVAR_INFO(info) > 0) {
        Emit("MakeHighVars(STATE(CurrLVars));\n");
    }
    for ( i = 1; i <= narg; i++ ) {
        if ( CompGetUseHVar( i ) ) {
            Emit( "ASS_LVAR( %d, %c );\n",GetIndxHVar(i),CVAR_LVAR(i));
        }
    }

    /* we know all the arguments have values                               */
    for ( i = 1; i <= narg; i++ ) {
        SetInfoCVar( CVAR_LVAR(i), W_BOUND );
    }
    for ( i = narg+1; i <= narg+nloc; i++ ) {
        SetInfoCVar( CVAR_LVAR(i), W_UNBOUND );
    }

    /* compile the body                                                    */
    CompStat( OFFSET_FIRST_STAT );

    /* emit the code to switch back to the old frame and return            */
    Emit( "\n/* return; */\n" );

    Emit( "SWITCH_TO_OLD_FRAME(oldFrame);\n" );
    Emit( "return 0;\n" );
    Emit( "}\n" );

    /* switch back to old frame                                            */
    SWITCH_TO_OLD_LVARS( oldFrame );
}


/****************************************************************************
**
*F  CompileFunc( <filename>, <func>, <name>, <magic1>, <magic2> ) . . compile
*/
Int CompileFunc(Obj filename, Obj func, Obj name, Int magic1, Obj magic2)
{
    Int                 i;              /* loop variable                   */
    UInt                col;
    UInt                compFunctionsNr;

    /* open the output file                                                */
    TypOutputFile output = { 0 };
    if (!OpenOutput(&output, CONST_CSTR_STRING(filename), FALSE)) {
        return 0;
    }
    col = SyNrCols;
    SyNrCols = 255;

    /* store the magic values                                              */
    compilerMagic1 = magic1;
    compilerMagic2 = magic2;

    /* create 'CompInfoGVar' and 'CompInfoRNam'                            */
    CompInfoGVar = NewKernelBuffer(sizeof(UInt) * 1024);
    CompInfoRNam = NewKernelBuffer(sizeof(UInt) * 1024);

    /* create the list to collection the function expressions              */
    CompFunctions = NEW_PLIST( T_PLIST, 8 );

    /* first collect information about variables                           */
    CompPass = 1;
    CompFunc( func );

    /* ok, lets emit some code now                                         */
    CompPass = 2;
    compFunctionsNr = LEN_PLIST( CompFunctions );

    /* emit code to include the interface files                            */
    Emit( "/* C file produced by GAC */\n" );
    Emit( "#include \"compiled.h\"\n" );
    Emit( "#define FILE_CRC  \"%d\"\n", magic1 );

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
    Emit( "static Obj  NameFunc[%d];\n", compFunctionsNr+1 );
    Emit( "static Obj FileName;\n" );


    /* now compile the handlers                                            */
    CompFunc( func );

    // emit the code for PostRestore
    Emit( "\n/* 'PostRestore' restore gvars, rnams, functions */\n" );
    Emit( "static Int PostRestore ( StructInitInfo * module )\n" );
    Emit( "{\n" );
    Emit( "\n/* global variables used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoGVar)/sizeof(UInt); i++ ) {
        if ( CompGetUseGVar( i ) ) {
            Emit( "G_%n = GVarName( \"%g\" );\n",
                   NameGVar(i), NameGVar(i) );
        }
    }
    Emit( "\n/* record names used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoRNam)/sizeof(UInt); i++ ) {
        if ( CompGetUseRNam( i ) ) {
            Emit( "R_%n = RNamName( \"%g\" );\n",
                  NAME_RNAM(i), NAME_RNAM(i) );
        }
    }
    Emit( "\n/* information for the functions */\n" );
    for ( i = 1; i <= compFunctionsNr; i++ ) {
        Obj n = NAME_FUNC(ELM_PLIST(CompFunctions,i));
        if ( n != 0 && IsStringConv(n) ) {
            Emit( "NameFunc[%d] = MakeImmString(\"%G\");\n", i, n );
        }
        else {
            Emit( "NameFunc[%d] = 0;\n", i );
        }
    }
    Emit( "\n" );
    Emit( "return 0;\n" );
    Emit( "\n}\n" );
    Emit( "\n" );

    // emit the code for InitKernel
    Emit( "\n/* 'InitKernel' sets up data structures, fopies, copies, handlers */\n" );
    Emit( "static Int InitKernel ( StructInitInfo * module )\n" );
    Emit( "{\n" );
    Emit( "\n/* global variables used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoGVar)/sizeof(UInt); i++ ) {
        if ( CompGetUseGVar( i ) & COMP_USE_GVAR_COPY ) {
            Emit( "InitCopyGVar( \"%g\", &GC_%n );\n",
                  NameGVar(i), NameGVar(i) );
        }
        if ( CompGetUseGVar( i ) & COMP_USE_GVAR_FOPY ) {
            Emit( "InitFopyGVar( \"%g\", &GF_%n );\n",
                  NameGVar(i), NameGVar(i) );
        }
    }
    Emit( "\n/* information for the functions */\n" );
    Emit( "InitGlobalBag( &FileName, \"%g:FileName(\"FILE_CRC\")\" );\n",
          magic2 );
    for ( i = 1; i <= compFunctionsNr; i++ ) {
        Emit( "InitHandlerFunc( HdlrFunc%d, \"%g:HdlrFunc%d(\"FILE_CRC\")\" );\n",
              i, compilerMagic2, i );
        Emit( "InitGlobalBag( &(NameFunc[%d]), \"%g:NameFunc[%d](\"FILE_CRC\")\" );\n", 
               i, magic2, i );
    }
    Emit( "\n" );
    Emit( "return 0;\n" );
    Emit( "\n}\n" );

    // emit the code for InitLibrary
    Emit( "\n/* 'InitLibrary' sets up gvars, rnams, functions */\n" );
    Emit( "static Int InitLibrary ( StructInitInfo * module )\n" );
    Emit( "{\n" );
    Emit( "Obj func1;\n" );
    Emit( "Obj body1;\n" );
    Emit( "\n/* Complete Copy/Fopy registration */\n" );
    Emit( "UpdateCopyFopyInfo();\n" );
    Emit( "FileName = MakeImmString( \"%g\" );\n", magic2 );
    Emit( "PostRestore(module);\n" );
    Emit( "\n/* create all the functions defined in this module */\n" );
    Emit( "func1 = NewFunction(NameFunc[1],%d,0,HdlrFunc1);\n", NARG_FUNC(ELM_PLIST(CompFunctions,1)) );
    Emit( "SET_ENVI_FUNC( func1, STATE(CurrLVars) );\n" );
    Emit( "body1 = NewFunctionBody();\n" );
    Emit( "SET_BODY_FUNC( func1, body1 );\n" );
    Emit( "CHANGED_BAG( func1 );\n");
    Emit( "CALL_0ARGS( func1 );\n" );
    Emit( "\n" );
    Emit( "return 0;\n" );
    Emit( "\n}\n" );

    /* emit the initialization code                                        */
    Emit( "\n/* <name> returns the description of this module */\n" );
    Emit( "static StructInitInfo module = {\n" );
    if (streq("Init_Dynamic", CONST_CSTR_STRING(name))) {
        Emit( ".type        = MODULE_DYNAMIC,\n" );
    }
    else {
        Emit( ".type        = MODULE_STATIC,\n" );
    }
    Emit( ".name        = \"%g\",\n", magic2 );
    Emit( ".crc         = %d,\n",     magic1 );
    Emit( ".initKernel  = InitKernel,\n" );
    Emit( ".initLibrary = InitLibrary,\n" );
    Emit( ".postRestore = PostRestore,\n" );
    Emit( "};\n" );
    Emit( "\n" );
    Emit( "StructInitInfo * %n ( void )\n", name );
    Emit( "{\n" );
    Emit( "return &module;\n" );
    Emit( "}\n" );
    Emit( "\n/* compiled code ends here */\n" );

    /* close the output file                                               */
    SyNrCols = col;
    CloseOutput(&output);

    return compFunctionsNr;
}


/****************************************************************************
**
*F  FuncCOMPILE_FUNC( <self>, <output>, <func>, <name>, <magic1>, <magic2> )
*/
static Obj FuncCOMPILE_FUNC(Obj self, Obj arg)
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
    }
    output = ELM_LIST( arg, 1 );
    func   = ELM_LIST( arg, 2 );
    name   = ELM_LIST( arg, 3 );
    magic1 = ELM_LIST( arg, 4 );
    magic2 = ELM_LIST( arg, 5 );

    RequireStringRep(SELF_NAME, output);
    RequireFunction(SELF_NAME, func);
    RequireStringRep(SELF_NAME, name);
    RequireSmallInt(SELF_NAME, magic1);
    RequireStringRep(SELF_NAME, magic2);

    /* possible optimiser flags                                            */
    CompFastIntArith        = 1;
    CompFastPlainLists      = 1;
    CompFastListFuncs       = 1;
    CompCheckTypes          = 1;
    CompCheckListElements   = 1;

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
    
    /* compile the function                                                */
    nr = CompileFunc(
        output, func, name,
        INT_INTOBJ(magic1), magic2 );


    return INTOBJ_INT(nr);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(COMPILE_FUNC, -1, "arg"),
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

    CompExprFuncs[ EXPR_FUNCCALL_0ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ EXPR_FUNCCALL_1ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ EXPR_FUNCCALL_2ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ EXPR_FUNCCALL_3ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ EXPR_FUNCCALL_4ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ EXPR_FUNCCALL_5ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ EXPR_FUNCCALL_6ARGS  ] = CompFunccall0to6Args;
    CompExprFuncs[ EXPR_FUNCCALL_XARGS  ] = CompFunccallXArgs;
    CompExprFuncs[ EXPR_FUNC       ] = CompFuncExpr;

    CompExprFuncs[ EXPR_OR              ] = CompOr;
    CompExprFuncs[ EXPR_AND             ] = CompAnd;
    CompExprFuncs[ EXPR_NOT             ] = CompNot;
    CompExprFuncs[ EXPR_EQ              ] = CompEq;
    CompExprFuncs[ EXPR_NE              ] = CompNe;
    CompExprFuncs[ EXPR_LT              ] = CompLt;
    CompExprFuncs[ EXPR_GE              ] = CompGe;
    CompExprFuncs[ EXPR_GT              ] = CompGt;
    CompExprFuncs[ EXPR_LE              ] = CompLe;
    CompExprFuncs[ EXPR_IN              ] = CompIn;

    CompExprFuncs[ EXPR_SUM             ] = CompSum;
    CompExprFuncs[ EXPR_AINV            ] = CompAInv;
    CompExprFuncs[ EXPR_DIFF            ] = CompDiff;
    CompExprFuncs[ EXPR_PROD            ] = CompProd;
    CompExprFuncs[ EXPR_QUO             ] = CompQuo;
    CompExprFuncs[ EXPR_MOD             ] = CompMod;
    CompExprFuncs[ EXPR_POW             ] = CompPow;

    CompExprFuncs[ EXPR_INT         ] = CompIntExpr;
    CompExprFuncs[ EXPR_INTPOS        ] = CompIntExpr;
    CompExprFuncs[ EXPR_TRUE       ] = CompTrueExpr;
    CompExprFuncs[ EXPR_FALSE      ] = CompFalseExpr;
    CompExprFuncs[ EXPR_TILDE      ] = CompTildeExpr;
    CompExprFuncs[ EXPR_CHAR       ] = CompCharExpr;
    CompExprFuncs[ EXPR_PERM       ] = CompPermExpr;
    CompExprFuncs[ EXPR_PERM_CYCLE      ] = CompUnknownExpr;
    CompExprFuncs[ EXPR_LIST       ] = CompListExpr;
    CompExprFuncs[ EXPR_LIST_TILDE ] = CompListTildeExpr;
    CompExprFuncs[ EXPR_RANGE      ] = CompRangeExpr;
    CompExprFuncs[ EXPR_STRING     ] = CompStringExpr;
    CompExprFuncs[ EXPR_REC        ] = CompRecExpr;
    CompExprFuncs[ EXPR_REC_TILDE  ] = CompRecTildeExpr;

    CompExprFuncs[ EXPR_REF_LVAR         ] = CompRefLVar;
    CompExprFuncs[ EXPR_ISB_LVAR        ] = CompIsbLVar;
    CompExprFuncs[ EXPR_REF_HVAR        ] = CompRefHVar;
    CompExprFuncs[ EXPR_ISB_HVAR        ] = CompIsbHVar;
    CompExprFuncs[ EXPR_REF_GVAR        ] = CompRefGVar;
    CompExprFuncs[ EXPR_ISB_GVAR        ] = CompIsbGVar;

    CompExprFuncs[ EXPR_ELM_LIST        ] = CompElmList;
    CompExprFuncs[ EXPR_ELMS_LIST       ] = CompElmsList;
    CompExprFuncs[ EXPR_ELM_LIST_LEV    ] = CompElmListLev;
    CompExprFuncs[ EXPR_ELMS_LIST_LEV   ] = CompElmsListLev;
    CompExprFuncs[ EXPR_ISB_LIST        ] = CompIsbList;
    CompExprFuncs[ EXPR_ELM_REC_NAME    ] = CompElmRecName;
    CompExprFuncs[ EXPR_ELM_REC_EXPR    ] = CompElmRecExpr;
    CompExprFuncs[ EXPR_ISB_REC_NAME    ] = CompIsbRecName;
    CompExprFuncs[ EXPR_ISB_REC_EXPR    ] = CompIsbRecExpr;

    CompExprFuncs[ EXPR_ELM_POSOBJ      ] = CompElmPosObj;
    CompExprFuncs[ EXPR_ISB_POSOBJ      ] = CompIsbPosObj;
    CompExprFuncs[ EXPR_ELM_COMOBJ_NAME ] = CompElmComObjName;
    CompExprFuncs[ EXPR_ELM_COMOBJ_EXPR ] = CompElmComObjExpr;
    CompExprFuncs[ EXPR_ISB_COMOBJ_NAME ] = CompIsbComObjName;
    CompExprFuncs[ EXPR_ISB_COMOBJ_EXPR ] = CompIsbComObjExpr;

    CompExprFuncs[ EXPR_FUNCCALL_OPTS   ] = CompFunccallOpts;
    
    /* enter the boolean expression compilers into the table               */
    for ( i = 0; i < 256; i++ ) {
        CompBoolExprFuncs[ i ] = CompUnknownBool;
    }

    CompBoolExprFuncs[ EXPR_OR              ] = CompOrBool;
    CompBoolExprFuncs[ EXPR_AND             ] = CompAndBool;
    CompBoolExprFuncs[ EXPR_NOT             ] = CompNotBool;
    CompBoolExprFuncs[ EXPR_EQ              ] = CompEqBool;
    CompBoolExprFuncs[ EXPR_NE              ] = CompNeBool;
    CompBoolExprFuncs[ EXPR_LT              ] = CompLtBool;
    CompBoolExprFuncs[ EXPR_GE              ] = CompGeBool;
    CompBoolExprFuncs[ EXPR_GT              ] = CompGtBool;
    CompBoolExprFuncs[ EXPR_LE              ] = CompLeBool;
    CompBoolExprFuncs[ EXPR_IN              ] = CompInBool;

    /* enter the statement compilers into the table                        */
    for ( i = 0; i < 256; i++ ) {
        CompStatFuncs[ i ] = CompUnknownStat;
    }

    CompStatFuncs[ STAT_PROCCALL_0ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ STAT_PROCCALL_1ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ STAT_PROCCALL_2ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ STAT_PROCCALL_3ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ STAT_PROCCALL_4ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ STAT_PROCCALL_5ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ STAT_PROCCALL_6ARGS  ] = CompProccall0to6Args;
    CompStatFuncs[ STAT_PROCCALL_XARGS  ] = CompProccallXArgs;

    CompStatFuncs[ STAT_SEQ_STAT        ] = CompSeqStat;
    CompStatFuncs[ STAT_SEQ_STAT2       ] = CompSeqStat;
    CompStatFuncs[ STAT_SEQ_STAT3       ] = CompSeqStat;
    CompStatFuncs[ STAT_SEQ_STAT4       ] = CompSeqStat;
    CompStatFuncs[ STAT_SEQ_STAT5       ] = CompSeqStat;
    CompStatFuncs[ STAT_SEQ_STAT6       ] = CompSeqStat;
    CompStatFuncs[ STAT_SEQ_STAT7       ] = CompSeqStat;
    CompStatFuncs[ STAT_IF              ] = CompIf;
    CompStatFuncs[ STAT_IF_ELSE         ] = CompIf;
    CompStatFuncs[ STAT_IF_ELIF         ] = CompIf;
    CompStatFuncs[ STAT_IF_ELIF_ELSE    ] = CompIf;
    CompStatFuncs[ STAT_FOR             ] = CompFor;
    CompStatFuncs[ STAT_FOR2            ] = CompFor;
    CompStatFuncs[ STAT_FOR3            ] = CompFor;
    CompStatFuncs[ STAT_FOR_RANGE       ] = CompFor;
    CompStatFuncs[ STAT_FOR_RANGE2      ] = CompFor;
    CompStatFuncs[ STAT_FOR_RANGE3      ] = CompFor;
    CompStatFuncs[ STAT_WHILE           ] = CompWhile;
    CompStatFuncs[ STAT_WHILE2          ] = CompWhile;
    CompStatFuncs[ STAT_WHILE3          ] = CompWhile;
    CompStatFuncs[ STAT_REPEAT          ] = CompRepeat;
    CompStatFuncs[ STAT_REPEAT2         ] = CompRepeat;
    CompStatFuncs[ STAT_REPEAT3         ] = CompRepeat;
    CompStatFuncs[ STAT_BREAK           ] = CompBreak;
    CompStatFuncs[ STAT_CONTINUE        ] = CompContinue;
    CompStatFuncs[ STAT_RETURN_OBJ      ] = CompReturnObj;
    CompStatFuncs[ STAT_RETURN_VOID     ] = CompReturnVoid;

    CompStatFuncs[ STAT_ASS_LVAR        ] = CompAssLVar;
    CompStatFuncs[ STAT_UNB_LVAR        ] = CompUnbLVar;
    CompStatFuncs[ STAT_ASS_HVAR        ] = CompAssHVar;
    CompStatFuncs[ STAT_UNB_HVAR        ] = CompUnbHVar;
    CompStatFuncs[ STAT_ASS_GVAR        ] = CompAssGVar;
    CompStatFuncs[ STAT_UNB_GVAR        ] = CompUnbGVar;

    CompStatFuncs[ STAT_ASS_LIST        ] = CompAssList;
    CompStatFuncs[ STAT_ASSS_LIST       ] = CompAsssList;
    CompStatFuncs[ STAT_ASS_LIST_LEV    ] = CompAssListLev;
    CompStatFuncs[ STAT_ASSS_LIST_LEV   ] = CompAsssListLev;
    CompStatFuncs[ STAT_UNB_LIST        ] = CompUnbList;
    CompStatFuncs[ STAT_ASS_REC_NAME    ] = CompAssRecName;
    CompStatFuncs[ STAT_ASS_REC_EXPR    ] = CompAssRecExpr;
    CompStatFuncs[ STAT_UNB_REC_NAME    ] = CompUnbRecName;
    CompStatFuncs[ STAT_UNB_REC_EXPR    ] = CompUnbRecExpr;

    CompStatFuncs[ STAT_ASS_POSOBJ      ] = CompAssPosObj;
    CompStatFuncs[ STAT_UNB_POSOBJ      ] = CompUnbPosObj;
    CompStatFuncs[ STAT_ASS_COMOBJ_NAME ] = CompAssComObjName;
    CompStatFuncs[ STAT_ASS_COMOBJ_EXPR ] = CompAssComObjExpr;
    CompStatFuncs[ STAT_UNB_COMOBJ_NAME ] = CompUnbComObjName;
    CompStatFuncs[ STAT_UNB_COMOBJ_EXPR ] = CompUnbComObjExpr;

    CompStatFuncs[ STAT_INFO            ] = CompInfo;
    CompStatFuncs[ STAT_ASSERT_2ARGS    ] = CompAssert2;
    CompStatFuncs[ STAT_ASSERT_3ARGS    ] = CompAssert3;
    CompStatFuncs[ STAT_EMPTY           ] = CompEmpty;

    CompStatFuncs[ STAT_PROCCALL_OPTS   ] = CompProccallOpts;
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

    return PostRestore( module );
}


/****************************************************************************
**
*F  InitInfoCompiler() . . . . . . . . . . . . . . .  table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "compiler",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = PostRestore
};

StructInitInfo * InitInfoCompiler ( void )
{
    return &module;
}
