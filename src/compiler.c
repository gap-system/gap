/****************************************************************************
**
*W  compiler.c                  GAP source                   Ferencz Rakowczi
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the GAP to C compiler.
*/
char * Revision_compiler_c =
   "@(#)$Id$";

#include        <stdarg.h>              /* variable argument list macros   */

#include        "system.h"              /* Ints, UInts                     */
#include        "scanner.h"             /* Pr                              */
#include        "gasman.h"              /* NewBag, CHANGED_BAG             */

#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "gvars.h"               /* InitGVars                       */

#include        "calls.h"               /* NARG_FUNC, NLOC_FUNC, NAMS_FU...*/
/*N 1996/06/16 mschoene func expressions should be different from funcs    */

#include        "lists.h"               /* ELM_LIST                        */

#include        "records.h"             /* RNamIntg                        */

#include        "plist.h"               /* LEN_PLIST, ELM_PLIST, ...       */

#include        "string.h"              /* LEN_STRING, CSTR_STRING, ...    */

#include        "code.h"                /* Stat, Expr, TYPE_EXPR, ADDR_E...*/

#include        "exprs.h"               /* PrintExpr                       */
#include        "stats.h"               /* PrintStat                       */

#include        "vars.h"                /* SWITCH_TO_NEW_LVARS, ...        */

#define INCLUDE_DECLARATION_PART
#include        "compiler.h"            /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**
*V  CompFastIntArith  . . option to emit code that handles small ints. faster
*V  CompFastPlainLists  . option to emit code that handles plain lists faster
*V  CompFastListFuncs . . option to emit code that inlines calls to functions
*V  CompCheckTypes  . . .  option to emit code that assumes all types are ok.
*V  CompCheckListElements .  option to emit code that assumes list elms exist
*/
Int             CompFastIntArith = 1;

Int             CompFastPlainLists = 1;

Int             CompFastListFuncs = 1;

Int             CompCheckTypes = 1;

Int             CompCheckListElements = 1;


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
**  the two passes are guaranteed to do exactely the same computations.
*/
Int             CompPass;


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
typedef UInt4           CVar;

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
*F  SetInfoCVar(<cvar>,<type>)  . . . . . . . .  set the type of a C variable
*F  GetInfoCVar(<cvar>) . . . . . . . . . . . .  get the type of a C variable
*F  HasInfoCVar(<cvar>,<type>)  . . . . . . . . test the type of a C variable
**
*F  NewInfoCVars()  . . . . . . . . . allocate a new info bag for C variables
*F  CopyInfoCVars(<dst>,<src>)  . . .  copy between info bags for C variables
*F  MergeInfoCVars(<dst>,<src>) . . . . . merge two info bags for C variables
*F  IsEqInfoCVars(<dst>,<src>)  . . . . compare two info bags for C variables
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
#define TYPE_LVAR_INFO(info,i)  (*((Int*)(PTR_BAG(info)+7+(i))))
#define TYPE_TEMP_INFO(info,i)  (*((Int*)(PTR_BAG(info)+7+NLVAR_INFO(info)+(i))))
#define SIZE_INFO(nlvar,ntemp)  (sizeof(Int) * (7 + (nlvar) + (ntemp)))

#define W_UNUSED                0       /* TEMP is currently unused        */
#define W_HIGHER                (1L<<0) /* LVAR is used as higher variable */
#define W_UNKNOWN               ((1L<<1) | W_HIGHER)
#define W_UNBOUND               ((1L<<2) | W_UNKNOWN)
#define W_BOUND                 ((1L<<3) | W_UNKNOWN)
#define W_INT                   ((1L<<4) | W_BOUND)
#define W_INT_SMALL             ((1L<<5) | W_INT)
#define W_INT_SMALL_POS         ((1L<<6) | W_INT_SMALL)
#define W_BOOL                  ((1L<<7) | W_BOUND)
#define W_FUNC                  ((1L<<8) | W_BOUND)
#define W_LIST                  ((1L<<9) | W_BOUND)

void            SetInfoCVar (
    CVar                cvar,
    UInt                type )
{
    Bag                 info;           /* its info bag                    */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC );

    /* set the type of a temporary                                         */
    if ( IS_TEMP_CVAR(cvar) ) {
        TYPE_TEMP_INFO( info, TEMP_CVAR(cvar) ) = type;
    }

    /* set the type of a lvar (but do not change if its a higher variable) */
    else if ( IS_LVAR_CVAR(cvar)
           && TYPE_LVAR_INFO( info, LVAR_CVAR(cvar) ) != W_HIGHER ) {
        TYPE_LVAR_INFO( info, LVAR_CVAR(cvar) ) = type;
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
        return TYPE_TEMP_INFO( info, TEMP_CVAR(cvar) );
    }

    /* get the type of a lvar                                              */
    else if ( IS_LVAR_CVAR(cvar) ) {
        return TYPE_LVAR_INFO( info, LVAR_CVAR(cvar) );
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
    new = NewBag( TYPE_BAG(old), SIZE_BAG(old) );
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
        TYPE_LVAR_INFO(dst,i) = TYPE_LVAR_INFO(src,i);
    }
    for ( i = 1; i <= NTEMP_INFO(dst) && i <= NTEMP_INFO(src); i++ ) {
        TYPE_TEMP_INFO(dst,i) = TYPE_TEMP_INFO(src,i);
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
        TYPE_LVAR_INFO(dst,i) &= TYPE_LVAR_INFO(src,i);
    }
    for ( i = 1; i <= NTEMP_INFO(dst) && i <= NTEMP_INFO(src); i++ ) {
        TYPE_TEMP_INFO(dst,i) &= TYPE_TEMP_INFO(src,i);
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
        if ( TYPE_LVAR_INFO(dst,i) != TYPE_LVAR_INFO(src,i) ) {
            return 0;
        }
    }
    for ( i = 1; i <= NTEMP_INFO(dst) && i <= NTEMP_INFO(src); i++ ) {
        if ( TYPE_TEMP_INFO(dst,i) != TYPE_TEMP_INFO(src,i) ) {
            return 0;
        }
    }
    return 1;
}


/****************************************************************************
**
*F  NewTemp(<name>) . . . . . . . . . . . . . . . .  allocate a new temporary
*F  FreeTemp(<temp>)  . . . . . . . . . . . . . . . . . . .  free a temporary
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
    Char *              name )
{
    Temp                temp;           /* new temporary, result           */
    Bag                 info;           /* information bag                 */

    /* get the information bag                                             */
    info = INFO_FEXP( CURR_FUNC );

    /* take the next available temporary                                   */
    CTEMP_INFO( info )++;
    temp = CTEMP_INFO( info );
    TYPE_TEMP_INFO( info, temp ) = W_UNKNOWN;

    /* maybe make room for more temporaries                                */
    if ( NTEMP_INFO( info ) < temp ) {
        if ( SIZE_BAG(info) < SIZE_INFO(NLVAR_INFO(info), temp ) ) {
            ResizeBag( info, SIZE_INFO(NLVAR_INFO(info), temp+7 ) );
        }
        NTEMP_INFO( info ) = temp;
    }

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
        Pr("PROBLEM: freeing t_%d, should be t_%c\n",temp,CTEMP_INFO(info));
    }

    /* free the temporary                                                  */
    TYPE_TEMP_INFO( info, temp ) = W_UNUSED;
    CTEMP_INFO( info )--;
}


/****************************************************************************
**
*F  CompSetUseHVar(<hvar>)  . . . . . . . . . register use of higher variable
*F  CompGetUseHVar(<hvar>)  . . . . . . . . . get use mode of higher variable
*F  GetLevlHVar(<hvar>) . . . . . . . . . . . .  get level of higher variable
*F  GetIndxHVar(<hvar>) . . . . . . . . . . . .  get index of higher variable
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
    if ( TYPE_LVAR_INFO( info, (hvar & 0xFFFF) ) != W_HIGHER ) {
        TYPE_LVAR_INFO( info, (hvar & 0xFFFF) ) = W_HIGHER;
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
    return (TYPE_LVAR_INFO( info, (hvar & 0xFFFF) ) == W_HIGHER);
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
    if ( NHVAR_INFO(info) != 0 ) levl++;
    for ( i = 1; i <= (hvar >> 16); i++ ) {
        info = NEXT_INFO( info );
        if ( NHVAR_INFO(info) != 0 ) levl++;
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
        if ( TYPE_LVAR_INFO( info, i ) == W_HIGHER )  indx++;
    }

    /* return the index                                                    */
    return indx;
}


/****************************************************************************
**
*F  CompSetUseGVar(<gvar>,<mode>) . . . . . . register use of global variable
*F  CompGetUseGVar(<gvar>)  . . . . . . . . . get use mode of global variable
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
**  define  and initialize 'GC_<name>' as a  copy of  the the global variable
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
*F  CompSetUseRNam(<rnam>,<mode>) . . . . . . . . register use of record name
*F  CompGetUseRNam(<rnam>)  . . . . . . . . . . . get use mode of record name
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
*F  Emit(<fmt>,...) . . . . . . . . . . . . . . . . . . . . . . . . emit code
**
**  'Emit' outputs the   string  <fmt> and the  other  arguments,  which must
**  correspond  to the '%'  format elements  in  <fmt>.  Nothing  is actually
**  outputted if 'CompPass' is not 2.
**
**  'Emit' supports  the following  '%'   format elements: '%d'   formats  an
**  integer,  '%s'  formats a  string, '%S'  formats   a string with  all the
**  necessary escapes, '%n' formats a name ('_' is converted to '__', special
**  characters are  converted to '_<hex1><hex2>'), '%c'  formats a C variable
**  ('INTOBJ_INT(<int>)'  for integers,  'a_<name>' for arguments, 'l_<name>'
**  for locals, 't_<nr>' for temporaries), and '%%' outputs a single '%'.
*/
Int             EmitIndent;

Int             EmitIndent2;

void            Emit (
    char *              fmt,
    ... )
{
    Int                 narg;           /* number of arguments             */
    va_list             ap;             /* argument list pointer           */
    Int                 dint;           /* integer argument                */
    CVar                cvar;           /* C variable argument             */
    Char *              string;         /* string argument                 */
    Char *              p;              /* loop variable                   */
    Char *              q;              /* loop variable                   */
    Char *              hex = "0123456789ABCDEF";

    /* are we in pass 2?                                                   */
    if ( CompPass != 2 )  return;

    /* get the information bag                                             */
    narg = (NARG_FUNC( CURR_FUNC ) != -1 ? NARG_FUNC( CURR_FUNC ) : 1);

    /* loop over the format string                                         */
    va_start( ap, fmt );
    for ( p = fmt; *p != '\0'; p++ ) {

        /* print an indent                                                 */
        if ( 0 < EmitIndent2 && *p == '}' ) EmitIndent2--;
        while ( 0 < EmitIndent2-- )  Pr( " ", 0L, 0L );

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
                    Pr( "INTOBJ_INT(%d)", INTG_CVAR(cvar), 0L );
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
*F  CompCheckBound(<obj>,<name>)  . emit code to check that <obj> has a value
*F  CompCheckFuncResult(<obj>)  . . emit code to check that <obj> has a value
*F  CompCheckIntSmall(<obj>)  . emit code to check that <obj> is a small int.
*F  CompCheckIntSmallPos(<obj>) . emit code to check that <obj> is a position
*F  CompCheckBool(<obj>)  . . . .  emit code to check that <obj> is a boolean
*F  CompCheckFunc(<obj>)  . . . . emit code to check that <obj> is a function
*/

void            CompCheckBound (
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

void            CompCheckFuncResult (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_BOUND ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_FUNC_RESULT( %c )\n", obj );
        }
        SetInfoCVar( obj, W_BOUND );
    }
}

void            CompCheckIntSmall (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_INT_SMALL ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_INT_SMALL( %c )\n", obj );
        }
        SetInfoCVar( obj, W_INT_SMALL );
    }
}

void            CompCheckIntSmallPos (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_INT_SMALL_POS ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_INT_SMALL_POS( %c )\n", obj );
        }
        SetInfoCVar( obj, W_INT_SMALL_POS );
    }
}

void            CompCheckBool (
    CVar                obj )
{
    if ( ! HasInfoCVar( obj, W_BOOL ) ) {
        if ( CompCheckTypes ) {
            Emit( "CHECK_BOOL( %c )\n", obj );
        }
        SetInfoCVar( obj, W_BOOL );
    }
}

void            CompCheckFunc (
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
*F  CompExpr(<expr>)  . . . . . . . . . . . . . . . . . compile an expression
**
**  'CompExpr' compiles the expression <expr> and returns the C variable that
**  will contain the result.
*/

CVar            (* CompExprFuncs[256]) ( Expr expr );

CVar            CompExpr (
    Expr                expr )
{
    return (* CompExprFuncs[ TYPE_EXPR(expr) ])( expr );
}

CVar            CompUnknownExpr (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}

CVar            (* CompBoolExprFuncs[256]) ( Expr expr );

CVar            CompBoolExpr (
    Expr                expr )
{
    return (* CompBoolExprFuncs[ TYPE_EXPR(expr) ])( expr );
}

CVar            CompUnknownBool (
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
    Emit( "%c = (Obj)(%c != False);\n", res, val );

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( res, W_BOOL );

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( val ) )  FreeTemp( TEMP_CVAR( val ) );

    /* return the result                                                   */
    return res;
}
    
extern  CVar            CompRefGVarFopy (
            Expr                expr );

GVar            G_Length;

CVar            CompFunccall0to6Args (
    Expr                expr )
{
    CVar                result;         /* result, result                  */
    CVar                func;           /* function                        */
    CVar                args [8];       /* arguments                       */
    Int                 narg;           /* number of arguments             */
    Int                 i;              /* loop variable                   */

    /* special case to inline 'Length'                                     */
    if ( CompFastListFuncs
      && TYPE_EXPR( FUNC_CALL(expr) ) == T_REF_GVAR
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
    if ( TYPE_EXPR( FUNC_CALL(expr) ) == T_REF_GVAR ) {
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

CVar            CompFunccallXArgs (
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
    if ( TYPE_EXPR( FUNC_CALL(expr) ) == T_REF_GVAR ) {
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

CVar            CompFuncExpr (
    Expr                expr )
{
    CVar                func;           /* function, result                */
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
    Emit( "%c = NewFunction(NameFunc[%d],NargFunc[%d],NamsFunc[%d],HdlrFunc%d);\n",
          func, nr, nr, nr, nr );

    /* this should probably be done by 'NewFunction'                       */
    Emit( "ENVI_FUNC( %c ) = CurrLVars;\n", func );
    Emit( "CHANGED_BAG( CurrLVars );\n" );

    /* we know that the result is a function                               */
    SetInfoCVar( func, W_FUNC );

    /* return the number of the C variable that will hold the function     */
    return func;
}

CVar            CompOr (
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

CVar            CompOrBool (
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

CVar            CompAnd (
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

CVar            CompAndBool (
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

CVar            CompNot (
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

CVar            CompNotBool (
    Expr                expr )
{
    CVar                val;            /* result                          */
    CVar                left;           /* operand                         */

    /* allocate a new temporary for the result                             */
    val = CVAR_TEMP( NewTemp( "val" ) );

    /* compile the operand                                                 */
    left = CompBoolExpr( ADDR_EXPR(expr)[0] );

    /* invert the operand                                                  */
    Emit( "%c = (Obj)( ! ((Int)%c) );\n", val, left );

    /* we know that the result is boolean                                  */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( left ) )  FreeTemp( TEMP_CVAR( left ) );

    /* return the result                                                   */
    return val;
}

CVar            CompEq (
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
        Emit( "%c = ((((Int)%c) == ((Int)%c)) ? True : False);\n", val, left, right);
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

CVar            CompEqBool (
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
        Emit( "%c = (Obj)(((Int)%c) == ((Int)%c));\n", val, left, right);
    }
    else {
        Emit( "%c = (Obj)(EQ( %c, %c ));\n", val, left, right );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}

CVar            CompNe (
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
        Emit( "%c = ((((Int)%c) == ((Int)%c)) ? False : True);\n", val, left, right );
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

CVar            CompNeBool (
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
        Emit( "%c = (Obj)(((Int)%c) != ((Int)%c));\n", val, left, right );
    }
    else {
        Emit( "%c = (Obj)( ! EQ( %c, %c ));\n", val, left, right );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}

CVar            CompLt (
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

CVar            CompLtBool (
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
        Emit( "%c = (Obj)(((Int)%c) < ((Int)%c));\n", val, left, right );
    }
    else {
        Emit( "%c = (Obj)(LT( %c, %c ));\n", val, left, right );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}

CVar            CompGe (
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
        Emit( "%c = ((((Int)%c) < ((Int)%c)) ? False : True);\n", val, left, right );
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

CVar            CompGeBool (
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
        Emit( "%c = (Obj)(((Int)%c) >= ((Int)%c));\n", val, left, right );
    }
    else {
        Emit( "%c = (Obj)(! LT( %c, %c ));\n", val, left, right );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}

CVar            CompGt (
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
        Emit( "%c = ((((Int)%c) < ((Int)%c)) ? True : False);\n", val, right, left );
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

CVar            CompGtBool (
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
        Emit( "%c = (Obj)(((Int)%c) < ((Int)%c));\n", val, right, left );
    }
    else {
        Emit( "%c = (Obj)(LT( %c, %c ));\n", val, right, left );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}

CVar            CompLe (
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
        Emit( "%c = ((((Int)%c) < ((Int)%c)) ?  False : True);\n", val, right, left );
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
        Emit( "%c = (Obj)(((Int)%c) >= ((Int)%c));\n", val, right, left );
    }
    else {
        Emit( "%c = (Obj)(! LT( %c, %c ));\n", val, right, left );
    }

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}

CVar            CompIn (
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

CVar            CompInBool (
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
    Emit( "%c = (Obj)(IN( %c, %c ));\n", val, left, right );

    /* we know that the result is boolean (should be 'W_CBOOL')            */
    SetInfoCVar( val, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( right ) )  FreeTemp( TEMP_CVAR( right ) );
    if ( IS_TEMP_CVAR( left  ) )  FreeTemp( TEMP_CVAR( left  ) );

    /* return the result                                                   */
    return val;
}

CVar            CompSum (
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

CVar            CompAInv (
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

CVar            CompDiff (
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

CVar            CompProd (
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

CVar            CompInv (
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

CVar            CompQuo (
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

CVar            CompMod (
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

CVar            CompPow (
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

CVar            CompIntExpr (
    Expr                expr )
{
    if ( IS_INTEXPR(expr) ) {
        return CVAR_INTG( INT_INTEXPR(expr) );
    }
    else {
        Emit( "CANNOT COMPILE LARGE INTEGER EXPRESSIONS;\n" );
        return 0;
    }
}

CVar            CompTrueExpr (
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

CVar            CompFalseExpr (
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

CVar            CompPermExpr (
    Expr                expr )
{
    Emit( "CANNOT COMPILE PERM EXPRESSIONS;\n" );
    return 0;
}

CVar            CompListExpr1 ( Expr expr );
void            CompListExpr2 ( CVar list, Expr expr );
CVar            CompRecExpr1 ( Expr expr );
void            CompRecExpr2 ( CVar rec, Expr expr );

CVar            CompListExpr (
    Expr                expr )
{
    CVar                list;           /* list, result                    */

    /* compile the list expression                                         */
    list = CompListExpr1( expr );
    CompListExpr2( list, expr );

    /* return the result                                                   */
    return list;
}

CVar            CompListTildeExpr (
    Expr                expr )
{
    CVar                list;           /* list value, result              */
    CVar                tilde;          /* old value of tilde              */

    /* remember the old value of '~'                                       */
    tilde = CVAR_TEMP( NewTemp( "tilde" ) );
    Emit( "%c = VAL_GVAR( Tilde );\n", tilde );

    /* create the list value                                               */
    list = CompListExpr1( expr );

    /* assign the list to '~'                                              */
    Emit( "AssGVar( Tilde, %c );\n", list );

    /* evaluate the subexpressions into the list value                     */
    CompListExpr2( list, expr );

    /* restore old value of '~'                                            */
    Emit( "AssGVar( Tilde, %c );\n", tilde );
    if ( IS_TEMP_CVAR( tilde ) )  FreeTemp( TEMP_CVAR( tilde ) );

    /* return the list value                                               */
    return list;
}

CVar            CompListExpr1 (
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

void            CompListExpr2 (
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
        else if ( TYPE_EXPR( ADDR_EXPR(expr)[i-1] ) == T_LIST_EXPR ) {
            sub = CompListExpr1( ADDR_EXPR(expr)[i-1] );
            Emit( "SET_ELM_PLIST( %c, %d, %c );\n", list, i, sub );
            Emit( "CHANGED_BAG( %c );\n", list );
            CompListExpr2( sub, ADDR_EXPR(expr)[i-1] );
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* special case if subexpression is a record expression            */
        else if ( TYPE_EXPR( ADDR_EXPR(expr)[i-1] ) == T_REC_EXPR ) {
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

CVar            CompRangeExpr (
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

CVar            CompStringExpr (
    Expr                expr )
{
    CVar                string;         /* string value, result            */

    /* allocate a new temporary for the string                             */
    string = CVAR_TEMP( NewTemp( "string" ) );

    /* create the string and copy the stuff                                */
    Emit( "C_NEW_STRING( %c, %d, \"%S\" )\n",
          string, SIZE_EXPR(expr)-1, (Char*)ADDR_EXPR(expr) );

    /* we know that the result is a list                                   */
    SetInfoCVar( string, W_LIST );

    /* return the string                                                   */
    return string;
}

CVar            CompRecExpr (
    Expr                expr )
{
    CVar                rec;            /* record value, result            */

    /* compile the record expression                                       */
    rec = CompRecExpr1( expr );
    CompRecExpr2( rec, expr );

    /* return the result                                                   */
    return rec;
}

CVar            CompRecTildeExpr (
    Expr                expr )
{
    CVar                rec;            /* record value, result            */
    CVar                tilde;          /* old value of tilde              */

    /* remember the old value of '~'                                       */
    tilde = CVAR_TEMP( NewTemp( "tilde" ) );
    Emit( "%c = VAL_GVAR( Tilde );\n", tilde );

    /* create the record value                                             */
    rec = CompRecExpr1( expr );

    /* assign the record value to the variable '~'                         */
    Emit( "AssGVar( Tilde, %c );\n", rec );

    /* evaluate the subexpressions into the record value                   */
    CompRecExpr2( rec, expr );

    /* restore the old value of '~'                                        */
    Emit( "AssGVar( Tilde, %c );\n", tilde );
    if ( IS_TEMP_CVAR( tilde ) )  FreeTemp( TEMP_CVAR( tilde ) );

    /* return the record value                                             */
    return rec;
}

CVar            CompRecExpr1 (
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
        Emit( "SET_RNAM_PREC( %c, %d, (UInt)%c );\n", rec, i, rnam );
        if ( IS_TEMP_CVAR( rnam ) )  FreeTemp( TEMP_CVAR( rnam ) );

        /* if the subexpression is empty (cannot happen for records)       */
        tmp = ADDR_EXPR(expr)[2*i-1];
        if ( tmp == 0 ) {
            continue;
        }

        /* special case if subexpression is a list expression             */
        else if ( TYPE_EXPR( tmp ) == T_LIST_EXPR ) {
            sub = CompListExpr1( tmp );
            Emit( "SET_ELM_PREC( %c, %d, %c );\n", rec, i, sub );
            Emit( "CHANGED_BAG( %c );\n", rec );
            CompListExpr2( sub, tmp );
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* special case if subexpression is a record expression            */
        else if ( TYPE_EXPR( tmp ) == T_REC_EXPR ) {
            sub = CompRecExpr1( tmp );
            Emit( "SET_ELM_PREC( %c, %d, %c );\n", rec, i, sub );
            Emit( "CHANGED_BAG( %c );\n", rec );
            CompRecExpr2( sub, tmp );
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

        /* general case                                                    */
        else {
            sub = CompExpr( tmp );
            Emit( "SET_ELM_PREC( %c, %d, %c );\n", rec, i, sub );
            if ( ! HasInfoCVar( sub, W_INT_SMALL ) ) {
                Emit( "CHANGED_BAG( %c );\n", rec );
            }
            if ( IS_TEMP_CVAR( sub ) )  FreeTemp( TEMP_CVAR( sub ) );
        }

    }

}

CVar            CompRefLVar (
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

CVar            CompIsbLVar (
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

CVar            CompRefHVar (
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

CVar            CompIsbHVar (
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

CVar            CompRefGVar (
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

CVar            CompRefGVarFopy (
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

CVar            CompIsbGVar (
    Expr                expr )
{
    CVar                isb;            /* isbound, result                 */
    CVar                val;            /* value, result                   */
    GVar                gvar;           /* higher variable                 */

    /* get the global variable                                             */
    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    CompSetUseGVar( gvar, COMP_USE_GVAR_COPY );

    /* allocate new temporaries for the value and the result               */
    val = CVAR_TEMP( NewTemp( "val" ) );
    isb = CVAR_TEMP( NewTemp( "isb" ) );

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

CVar            CompElmList (
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
    if (        CompCheckListElements &&   CompFastPlainLists ) {
        Emit( "C_ELM_LIST_FPL( %c, %c, %i )\n", elm, list, pos );
    }
    else if (   CompCheckListElements && ! CompFastPlainLists ) {
        Emit( "C_ELM_LIST( %c, %c, %i );\n", elm, list, pos );
    }
    else if ( ! CompCheckListElements &&   CompFastPlainLists ) {
        Emit( "C_ELM_LIST_NLE_FPL( %c, %c, %i );\n", elm, list, pos );
    }
    else {
        Emit( "C_ELM_LIST_NLE( %c, %c, %i );\n", elm, list, pos );
    }

    /* we know that we have a value                                        */
    SetInfoCVar( elm, W_BOUND );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );

    /* return the element                                                  */
    return elm;
}

CVar            CompElmsList (
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

CVar            CompElmListLev (
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
    Emit( "ElmListLevel( %c, %i, %d );\n", lists, pos, level );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos   ) )  FreeTemp( TEMP_CVAR( pos   ) );
    if ( IS_TEMP_CVAR( lists ) )  FreeTemp( TEMP_CVAR( lists ) );

    /* return the lists                                                    */
    return lists;
}

CVar            CompElmsListLev (
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
    if ( IS_TEMP_CVAR( lists ) )  FreeTemp( TEMP_CVAR( lists ) );

    /* return the lists                                                    */
    return lists;
}

CVar            CompIsbList (
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
    Emit( "%c = (ISB_LIST( %c, %i ) ? True : False);\n", isb, list, pos );

    /* we know that the result is boolean                                  */
    SetInfoCVar( isb, W_BOOL );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );

    /* return the element                                                  */
    return isb;
}

CVar            CompElmRecName (
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

CVar            CompElmRecExpr (
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

CVar            CompIsbRecName (
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

CVar            CompIsbRecExpr (
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

CVar            CompElmPosObj (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}

CVar            CompElmsPosObj (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}

CVar            CompElmPosObjLev (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}

CVar            CompElmsPosObjLev (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}

CVar            CompIsbPosObj (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}

CVar            CompElmComObjName (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}

CVar            CompElmComObjExpr (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}

CVar            CompIsbComObjName (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}

CVar            CompIsbComObjExpr (
    Expr                expr )
{
    Emit( "CANNOT COMPILE EXPRESSION OF TYPE %d;\n", TYPE_EXPR(expr) );
    return 0;
}


/****************************************************************************
**
*F  CompStat(<stat>)  . . . . . . . . . . . . . . . . . . compile a statement
**
**  'CompStat' compiles the statement <stat>.
*/

void            (* CompStatFuncs[256]) ( Stat stat );

void            CompStat (
    Stat                stat )
{
    (* CompStatFuncs[ TYPE_STAT(stat) ])( stat );
}

void            CompUnknownStat (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

GVar            G_Add;

void            CompProccall0to6Args (
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
      && TYPE_EXPR( FUNC_CALL(stat) ) == T_REF_GVAR
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
    if ( TYPE_EXPR( FUNC_CALL(stat) ) == T_REF_GVAR ) {
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

void            CompProccallXArgs (
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
    if ( TYPE_EXPR( FUNC_CALL(stat) ) == T_REF_GVAR ) {
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

void            CompSeqStat (
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

void            CompIf (
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
        if ( i == nr && TYPE_EXPR(ADDR_STAT(stat)[2*(i-1)]) == T_TRUE_EXPR )
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
        if ( i == nr && TYPE_EXPR(ADDR_STAT(stat)[2*(i-1)]) == T_TRUE_EXPR )
            break;
        Emit( "}\n" );
    }
    Emit( "/* fi */\n" );

    /* put what we know into the current info                              */
    CopyInfoCVars( INFO_FEXP(CURR_FUNC), info_out );

}

void            CompFor (
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
      && TYPE_EXPR( ADDR_STAT(stat)[1] ) == T_RANGE_EXPR
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
        else if ( T_REF_LVAR <= TYPE_EXPR( ADDR_STAT(stat)[0] )
               && TYPE_EXPR( ADDR_STAT(stat)[0] ) <= T_REF_LVAR_16
               && ! CompGetUseHVar( ADDR_EXPR( ADDR_STAT(stat)[0] )[0] ) ) {
            var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
            vart = 'l';
        }
        else if ( T_REF_LVAR <= TYPE_EXPR( ADDR_STAT(stat)[0] )
               && TYPE_EXPR( ADDR_STAT(stat)[0] ) <= T_REF_LVAR_16 ) {
            var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
            vart = 'm';
        }
        else if ( TYPE_EXPR( ADDR_STAT(stat)[0] ) == T_REF_HVAR ) {
            var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
            vart = 'h';
        }
        else /* if ( TYPE_EXPR( ADDR_STAT(stat)[0] ) == T_REF_GVAR ) */ {
            var = (UInt)(ADDR_EXPR( ADDR_STAT(stat)[0] )[0]);
            vart = 'g';
        }

        /* allocate a new temporary for the loop variable                  */
        lidx   = CVAR_TEMP( NewTemp( "lidx"   ) );
        elm    = CVAR_TEMP( NewTemp( "elm"    ) );
        islist = CVAR_TEMP( NewTemp( "islist" ) );

        /* compile and check the first and last value                      */
        list = CompExpr( ADDR_STAT(stat)[1] );

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
        Emit( "if ( IS_LIST(%c) ) {\n", list );
        Emit( "%c = (Obj)1;\n", islist );
        Emit( "%c = INTOBJ_INT(1);\n", lidx );
        Emit( "}\n" );
        Emit( "else {\n" );
        Emit( "%c = (Obj)0;\n", islist );
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

void            CompWhile (
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

void            CompRepeat (
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
    Emit( "while ( 1 );\n" );
}

void            CompBreak (
    Stat                stat )
{
    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    Emit( "break;\n" );
}

void            CompReturnObj (
    Stat                stat )
{
    CVar                obj;            /* returned object                 */

    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* compile the expression                                              */
    obj = CompExpr( ADDR_STAT(stat)[0] );

    /* emit code to remove stack frame (if neccessary)                     */
    if ( NHVAR_INFO( INFO_FEXP(CURR_FUNC) ) != 0 ) {
        Emit( "SWITCH_TO_OLD_FRAME(oldFrame);\n" );
    }

    /* emit code to return from function                                   */
    Emit( "return %c;\n", obj );

    /* free the temporary                                                  */
    if ( IS_TEMP_CVAR( obj ) )  FreeTemp( TEMP_CVAR( obj ) );
}

void            CompReturnVoid (
    Stat                stat )
{
    /* print a comment                                                     */
    if ( CompPass == 2 ) {
        Emit( "\n/* " ); PrintStat( stat ); Emit( " */\n" );
    }

    /* emit code to remove stack frame (if neccessary)                     */
    if ( NHVAR_INFO( INFO_FEXP(CURR_FUNC) ) != 0 ) {
        Emit( "SWITCH_TO_OLD_FRAME(oldFrame);\n" );
    }

    /* emit code to return from function                                   */
    Emit( "return 0;\n" );
}

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

void            CompUnbLVar (
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

void            CompAssHVar (
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

void            CompUnbHVar (
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

void            CompAssGVar (
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

void            CompAssList (
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
    if ( CompFastPlainLists ) {
        if ( HasInfoCVar( rhs, W_INT_SMALL ) ) {
            Emit( "C_ASS_LIST_FPL_INTOBJ( %c, %i, %c )\n", list, pos, rhs );
        }
        else {
            Emit( "C_ASS_LIST_FPL( %c, %i, %c )\n", list, pos, rhs );
        }
    }
    else {
        Emit( "C_ASS_LIST( %c, %i, %c );\n", list, pos, rhs );
    }

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhs  ) )  FreeTemp( TEMP_CVAR( rhs  ) );
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}

void            CompAsssList (
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

void            CompAssListLev (
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
    Emit( "AssListLevel( %c, %i, %c, %d );\n", lists, pos, rhss, level );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( rhss  ) )  FreeTemp( TEMP_CVAR( rhss  ) );
    if ( IS_TEMP_CVAR( pos   ) )  FreeTemp( TEMP_CVAR( pos   ) );
    if ( IS_TEMP_CVAR( lists ) )  FreeTemp( TEMP_CVAR( lists ) );
}

void            CompAsssListLev (
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

void            CompUnbList (
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
    Emit( "UNB_LIST( %c, %i );\n", list, pos );

    /* free the temporaries                                                */
    if ( IS_TEMP_CVAR( pos  ) )  FreeTemp( TEMP_CVAR( pos  ) );
    if ( IS_TEMP_CVAR( list ) )  FreeTemp( TEMP_CVAR( list ) );
}

void            CompAssRecName (
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

void            CompAssRecExpr (
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

void            CompUnbRecName (
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

void            CompAssPosObj (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompAsssPosObj (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompAssPosObjLev (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompAsssPosObjLev (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompUnbPosObj (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompAssComObjName (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompAssComObjExpr (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompUnbComObjName (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompUnbComObjExpr (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompInfo (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}

void            CompAssert (
    Stat                stat )
{
    Emit( "CANNOT COMPILE STATEMENT OF TYPE %d;\n", TYPE_STAT(stat) );
}


/****************************************************************************
**
*F  CompFunc(<func>)  . . . . . . . . . . . . . . . . . .  compile a function
**
**  'CompFunc' compiles the function <func>, i.e., it emits  the code for the
**  handler of the function <func> and the handlers of all its subfunctions.
*/
Obj             CompFunctions;

Int             CompFunctionsNr;

void            CompFunc (
    Obj                 func )
{
    Bag                 info;           /* info bag for this function      */
    Int                 narg;           /* number of arguments             */
    Int                 nloc;           /* number of locals                */
    Obj                 fexs;           /* function expression list        */
    Bag                 oldFrame;       /* old frame                       */
    Int                 i;              /* loop variable                   */

    /* get the number of arguments and locals                              */
    narg = (NARG_FUNC(func) != -1 ? NARG_FUNC(func) : 1);
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
    for ( i = 1; i <= LEN_PLIST(fexs); i++ ) {
        CompFunc( ELM_PLIST( fexs, i ) );
    }

    /* emit the code for the function header and the arguments             */
    Emit( "\n/* handler for function %d */\n", NR_INFO(info));
    if ( narg == 0 ) {
        Emit( "static Obj  HdlrFunc%d (\n", NR_INFO(info) );
        Emit( " Obj  self )\n" );
        Emit( "{\n" );
    }
    else if ( narg <= 6 ) {
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
    if ( NHVAR_INFO(info) != 0 ) {
        Emit( "Bag oldFrame;\n" );
    }

    /* emit the code to get the arguments for xarg functions               */
    if ( 6 < narg ) {
        Emit( "CHECK_NR_ARGS( %d, args )\n", narg );
        for ( i = 1; i <= narg; i++ ) {
            Emit( "%c = ELM_PLIST( args, %d );\n", CVAR_LVAR(i), i );
        }
    }

    /* emit the code to switch to a new frame for outer functions          */
    if ( NHVAR_INFO(info) != 0 ) {
        Emit( "\n/* allocate new stack frame */\n" );
        Emit( "SWITCH_TO_NEW_FRAME(self,%d,0,oldFrame);\n",NHVAR_INFO(info));
        for ( i = 1; i <= narg; i++ ) {
            if ( CompGetUseHVar( i ) ) {
                Emit( "ASS_LVAR( %d, %c );\n",GetIndxHVar(i),CVAR_LVAR(i));
            }
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
    CompStat( FIRST_STAT_CURR_FUNC );

    /* emit the code to switch back to the old frame and return            */
    Emit( "\n/* return; */\n" );
    if ( NHVAR_INFO(info) != 0 ) {
        Emit( "SWITCH_TO_OLD_FRAME(oldFrame);\n" );
    }
    Emit( "return 0;\n" );
    Emit( "}\n" );

    /* switch back to old frame                                            */
    SWITCH_TO_OLD_LVARS( oldFrame );
}


/****************************************************************************
**
*F  CompileFunc(<output>,<func>,<name>,<magic1>,<magic2>) . . . . . . compile
*/
Int             CompileFunc (
    Char *              output,
    Obj                 func,
    Char *              name,
    Int                 magic1,
    Int                 magic2 )
{
    Int                 i;              /* loop variable                   */
    Obj                 n;              /* temporary                       */

    /* open the output file                                                */
    if ( ! OpenOutput( output ) ) {
        return 0;
    }

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
    Emit( "#include <compiled.h>\n" );

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

    /* emit the code for the function that links this module to GAP        */
    Emit( "\n/* 'Link' links this module to GAP */\n" );
    Emit( "static void Link ( void )\n" );
    Emit( "{\n" );
    Emit( "\n/* global variables used in handlers */\n" );
    for ( i = 1; i < SIZE_OBJ(CompInfoGVar)/sizeof(UInt); i++ ) {
        if ( CompGetUseGVar( i ) ) {
            Emit( "G_%n = GVarName( \"%s\" );\n",
                   NameGVar(i), NameGVar(i) );
        }
        if ( CompGetUseGVar( i ) & COMP_USE_GVAR_COPY ) {
            Emit( "InitCopyGVar( G_%n, &GC_%n );\n",
                  NameGVar(i), NameGVar(i) );
        }
        if ( CompGetUseGVar( i ) & COMP_USE_GVAR_FOPY ) {
            Emit( "InitFopyGVar( G_%n, &GF_%n );\n",
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
        Emit( "InitGlobalBag( &(NameFunc[%d]) );\n", i );
        n = NAME_FUNC(ELM_PLIST(CompFunctions,i));
        if ( n != 0 && IsStringConv(n) ) {
            Emit( "C_NEW_STRING( NameFunc[%d], %d, \"%S\" )\n",
                  i, SyStrlen(CSTR_STRING(n)), CSTR_STRING(n) );
        }
        else {
            Emit( "C_NEW_STRING( NameFunc[%d], 14, \"local function\" )\n",
                  i );
        }
        Emit( "InitGlobalBag( &(NamsFunc[%d]) );\n", i );
        Emit( "NamsFunc[%d] = 0;\n", i );
        Emit( "NargFunc[%d] = %d;\n",
              i, NARG_FUNC(ELM_PLIST(CompFunctions,i)));
    }
    Emit( "\n}\n" );
    Emit( "\n" );

    /* now compile the handlers                                            */
    CompFunc( func );

    /* emit the code for the function that makes the main function         */
    Emit( "\n/* 'Function1' returns the main function of this module */\n" );
    Emit( "static Obj  Function1 ( void )\n" );
    Emit( "{\n" );
    Emit( "Obj  func1;\n" );
    Emit( "func1 = NewFunction(NameFunc[1],NargFunc[1],NamsFunc[1],HdlrFunc1);\n" );
    Emit( "ENVI_FUNC( func1 ) = CurrLVars;\n" );
    Emit( "CHANGED_BAG( CurrLVars );\n" );
    Emit( "return func1;\n" );
    Emit( "}\n" );
    Emit( "\n" );

    /* emit the initialization code                                        */
    Emit( "\n/* <name> returns the description of this module */\n" );
    Emit( "static StructCompInitInfo Description = {\n" );
    Emit( "/* magic1    = */ %d,\n", magic1 );
    Emit( "/* magic2    = */ %d,\n", magic2 );
    Emit( "/* link      = */ Link,\n" );
    Emit( "/* function1 = */ Function1,\n" );
    Emit( "/* functions = */ 0 };\n" );
    Emit( "\n" );
    Emit( "StructCompInitInfo *  %n ( void )\n", name );
    Emit( "{\n" );
    Emit( "return &Description;\n" );
    Emit( "}\n" );
    Emit( "\n/* compiled code ends here */\n" );

    /* close the output file                                               */
    CloseOutput();

    /* return success                                                      */
    return CompFunctionsNr;
}

Obj             CompileFuncFunc;

Obj             CompileFuncHandler (
    Obj                 self,
    Obj                 output,
    Obj                 func,
    Obj                 name,
    Obj                 magic1,
    Obj                 magic2 )
{
    Int                 nr;

    /* check the arguments                                                 */
    if ( ! IsStringConv( output ) ) {
        ErrorQuit("CompileFunc: <output> must be a string",0L,0L);
    }
    if ( TYPE_OBJ(func) != T_FUNCTION ) {
        ErrorQuit("CompileFunc: <func> must be a function",0L,0L);
    }
    if ( ! IsStringConv( name ) ) {
        ErrorQuit("CompileFunc: <name> must be a string",0L,0L);
    }
    if ( ! IS_INTOBJ(magic1) ) {
        ErrorQuit("CompileFunc: <magic1> must be an integer",0L,0L);
    }
    if ( ! IS_INTOBJ(magic2) ) {
        ErrorQuit("CompileFunc: <magic2> must be an integer",0L,0L);
    }

    /* compile the function                                                */
    nr = CompileFunc(
        CSTR_STRING(output), func, CSTR_STRING(name),
        INT_INTOBJ(magic1), INT_INTOBJ(magic2) );

    /* return the result                                                   */
    return INTOBJ_INT(nr);
}


/****************************************************************************
**
*F  InitCompiler()  . . . . . . . . . . . . . . . . . initialize the compiler
*/
void            InitCompiler ( void )
{
    Int                 i;              /* loop variable                   */

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
    CompExprFuncs[ T_REF_LVAR        ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_01     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_02     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_03     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_04     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_05     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_06     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_07     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_08     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_09     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_10     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_11     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_12     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_13     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_14     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_15     ] = CompRefLVar;
    CompExprFuncs[ T_REF_LVAR_16     ] = CompRefLVar;
    CompExprFuncs[ T_ISB_LVAR        ] = CompIsbLVar;
    CompExprFuncs[ T_REF_HVAR        ] = CompRefHVar;
    CompExprFuncs[ T_ISB_HVAR        ] = CompIsbHVar;
    CompExprFuncs[ T_REF_GVAR        ] = CompRefGVar;
    CompExprFuncs[ T_ISB_GVAR        ] = CompIsbGVar;

    CompExprFuncs[ T_ELM_LIST        ] = CompElmList;
    CompExprFuncs[ T_ELMS_LIST       ] = CompElmsList;
    CompExprFuncs[ T_ELM_LIST_LEV    ] = CompElmListLev;
    CompExprFuncs[ T_ELMS_LIST_LEV   ] = CompElmsListLev;
    CompExprFuncs[ T_ISB_LIST        ] = CompIsbLVar;
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
    CompStatFuncs[ T_RETURN_OBJ      ] = CompReturnObj;
    CompStatFuncs[ T_RETURN_VOID     ] = CompReturnVoid;

    CompStatFuncs[ T_ASS_LVAR        ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_01     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_02     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_03     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_04     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_05     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_06     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_07     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_08     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_09     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_10     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_11     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_12     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_13     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_14     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_15     ] = CompAssLVar;
    CompStatFuncs[ T_ASS_LVAR_16     ] = CompAssLVar;
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
    CompStatFuncs[ T_ASSERT_2ARGS    ] = CompAssert;
    CompStatFuncs[ T_ASSERT_3ARGS    ] = CompAssert;

    /* get the identifiers of 'Length' and 'Add' (for inlining)            */
    G_Length = GVarName( "Length" );
    G_Add = GVarName( "Add" );

    /* announce the global variables                                       */
    InitGlobalBag( &CompInfoGVar );
    InitGlobalBag( &CompInfoRNam );
    InitGlobalBag( &CompFunctions  );

    /* make the compile function                                           */
    CompileFuncFunc = NewFunctionC(
        "CompileFunc", 5L, "output, func, name, magic1, magic2",
        CompileFuncHandler );
    AssGVar( GVarName( "CompileFunc" ),
        CompileFuncFunc );
}


/****************************************************************************
**
*E  compiler.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



