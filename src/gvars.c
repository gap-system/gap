/****************************************************************************
**
*A  gvars.c                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of the global variables package.
**
**  The global variables  package  is the   part of the  kernel that  manages
**  global variables, i.e., the global namespace.  A global variable binds an
**  identifier to a value.
**
**  A global variable can be automatic.   That means that the global variable
**  binds the  identifier to a function and  an argument.   When the value of
**  the global variable is needed, the  function is called with the argument.
**  This function call  should, as a side-effect, execute  an assignment of a
**  value to the global variable, otherwise an error is signalled.
**
**  A global variable can have a number of internal copies, i.e., C variables
**  that always reference the same value as the global variable.
**  It can also have a special type of internal copy (a fopy) only used for
**  functions,  where  the internal copies
**  only reference the same value as the global variable if it is a function.
**  Otherwise the internal copies reference functions that signal an error.
*/
char *          Revision_gvars_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TNUM_OBJ, SIZE_OBJ, ...    */

#include        "scanner.h"             /* Pr                              */

#define INCLUDE_DECLARATION_PART
#include        "gvars.h"               /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "calls.h"               /* CALL_1ARGS, Function            */

#include        "lists.h"               /* LEN_LIST, ELM_LIST, ShallowCopy */

#include        "plist.h"               /* LEN_PLIST, SET_LEN_PLIST,   ... */
#include        "string.h"              /* IsString                        */

#include        "gap.h"                 /* Error                           */

#include        "bool.h"

/****************************************************************************
**
*V  ValGVars  . . . . . . . . . . . . . . . . . .  values of global variables
*V  PtrGVars  . . . . . . . . . . . . . pointer to values of global variables
**
**  'ValGVars' is the bag containing the values of the global variables.
**
**  'PtrGVars' is a pointer  to the 'ValGVars'  bag.  This makes it faster to
**  access global variables.
**
**  Since a   garbage  collection may move   this  bag around,    the pointer
**  'PtrGVars' must be  revalculated afterwards.   This  should be done by  a
**  function in this package, but is still done in 'VarsAfterCollectBags'.
*/
Obj             ValGVars;

Obj *           PtrGVars;


/****************************************************************************
**
*F  VAL_GVAR(<gvar>)  . . . . . . . . . . . . . . .  value of global variable
**
**  'VAL_GVAR' returns the  value of the global  variable  <gvar>.  If <gvar>
**  has no  assigned value, 'VAL_GVAR' returns 0.   In this case <gvar> might
**  be an automatic global variable, and one should call 'ValAutoGVar', which
**  will return the value of <gvar>  after evaluating <gvar>-s expression, or
**  0 if <gvar> was not an automatic variable.
**
**  'VAL_GVAR' is defined in the declaration part of this package as follows
**
#define VAL_GVAR(gvar)          PtrGVars[ (gvar) ]
*/


/****************************************************************************
**
*V  NameGVars . . . . . . . . . . . . . . . . . . . names of global variables
*V  WriteGVars  . . . . . . . . . . . . .  writable flags of global variables
*V  ExprGVars . . . . . . . . . .  expressions for automatic global variables
*V  BopiesGVars . . . . . . . . . . . . . internal copies of global variables
*V  FopiesGVars . . . . . . . .  internal function copies of global variables
*V  CountGVars  . . . . . . . . . . . . . . . . .  number of global variables
*/
Obj             NameGVars;
Obj             WriteGVars;
Obj             ExprGVars;
Obj             CopiesGVars;
Obj             FopiesGVars;
UInt            CountGVars;


/****************************************************************************
**
*V  TableGVars  . . . . . . . . . . . . . .  hashed table of global variables
*V  SizeGVars . . . . . . .  current size of hashed table of global variables
*/
Obj             TableGVars;
UInt            SizeGVars;


/****************************************************************************
**
*V  ErrorMustEvalToFuncFunc . . . . . . . . .  function that signals an error
*F  ErrorMustEvalToFuncHandler(<self>,<args>) . handler that signals an error
**
**  'ErrorMustEvalToFuncFunc' is a (variable number of  args)  function  that
**  signals the error ``Function: <func> be a function''.
**
**  'ErrorMustEvalToFuncHandler'  is  the  handler  that  signals  the  error
**  ``Function: <func> must be a function''.
*/
Obj             ErrorMustEvalToFuncFunc;

Obj             ErrorMustEvalToFuncHandler (
    Obj                 self,
    Obj                 args )
{
    ErrorQuit(
        "Function Calls: <func> must be a function",
        0L, 0L );
    return 0;
}


/****************************************************************************
**
*V  ErrorMustHaveAssObjFunc . . . . . . . . .  function that signals an error
*F  ErrorMustHaveAssObjHandler(<self>,<args>) . handler that signals an error
**
**  'ErrorMustHaveAssObjFunc' is a (variable number of  args)  function  that
**  signals the error ``Variable: <<unknown>> must have an assigned value''.
**
**  'ErrorMustHaveAssObjHandler'  is  the  handler  that  signals  the  error
**  ``Variable: <<unknown>> must have an assigned value''.
*/
Obj             ErrorMustHaveAssObjFunc;

Obj             ErrorMustHaveAssObjHandler (
    Obj                 self,
    Obj                 args )
{
    ErrorQuit(
        "Variable: <<unknown>> must have an assigned value",
        0L, 0L );
    return 0;
}


/****************************************************************************
**
*F  AssGVar(<gvar>,<val>) . . . . . . . . . . . . assign to a global variable
**
**  'AssGVar' assigns the value <val> to the global variable <gvar>.
*/
void            AssGVar (
    UInt                gvar,
    Obj                 val )
{
    Obj                 cops;           /* list of internal copies         */
    Obj *               copy;           /* one copy                        */
    UInt                i;              /* loop variable                   */
    Char *              name;           /* name of a function              */
    Obj                 onam;          /* object of <name>                */

    /* make certain that the variable is not read only                     */
    while ( ELM_PLIST( WriteGVars, gvar ) == INTOBJ_INT(0) ) {
        ErrorReturnVoid(
            "Variable: '%s' is read only",
            (Int)CSTR_STRING( ELM_PLIST(NameGVars,gvar) ), 0L,
            "you can return after makeing it writable" );
    }

    /* assign the value to the global variable                             */
    VAL_GVAR(gvar) = val;
    CHANGED_BAG( ValGVars );

    /* if the global variable was automatic, convert it to normal          */
    SET_ELM_PLIST( ExprGVars, gvar, 0 );

    /* assign the value to all the internal copies                         */
    cops = ELM_PLIST( CopiesGVars, gvar );
    if ( cops != 0 ) {
        for ( i = 1; i <= LEN_PLIST(cops); i++ ) {
            copy  = (Obj*) ELM_PLIST(cops,i);
            *copy = val;
        }
    }

    /* if the value is a function, assign it to all the internal fopies    */
    cops = ELM_PLIST( FopiesGVars, gvar );
    if ( cops != 0 && val != 0 && TNUM_OBJ(val) == T_FUNCTION ) {
        for ( i = 1; i <= LEN_PLIST(cops); i++ ) {
            copy  = (Obj*) ELM_PLIST(cops,i);
            *copy = val;
        }
    }

    /* if the values is not a function, assign the error function          */
    else if ( cops != 0 && val != 0 /* && TNUM_OBJ(val) != T_FUNCTION */ ) {
        for ( i = 1; i <= LEN_PLIST(cops); i++ ) {
            copy  = (Obj*) ELM_PLIST(cops,i);
            *copy = ErrorMustEvalToFuncFunc;
        }
    }

    /* if this was an unbind, assign the other error function              */
    else if ( cops != 0 /* && val == 0 */ ) {
        for ( i = 1; i <= LEN_PLIST(cops); i++ ) {
            copy  = (Obj*) ELM_PLIST(cops,i);
            *copy = ErrorMustHaveAssObjFunc;
        }
    }

    /* assign name to a function                                           */
    if ( val != 0 && TNUM_OBJ(val) == T_FUNCTION && NAME_FUNC(val) == 0 ) {
	name = NameGVar(gvar);
	onam = NEW_STRING(SyStrlen(name));
	SyStrncat( CSTR_STRING(onam), name, SyStrlen(name) );
	RetypeBag( onam, IMMUTABLE_TNUM(TNUM_OBJ(onam)) );
	NAME_FUNC(val) = onam;
	CHANGED_BAG(val);
    }
}


/****************************************************************************
**
*F  ValAutoGVar(<gvar>) . . . . . . . .  value of a automatic global variable
**
**  'ValAutoGVar' returns the value of the global variable <gvar>.  This will
**  be 0 if  <gvar> has  no assigned value.    It will also cause a  function
**  call, if <gvar> is automatic.
*/
Obj             ValAutoGVar (
    UInt                gvar )
{
    Obj                 func;           /* function to call for automatic  */
    Obj                 arg;            /* argument to pass for automatic  */

    /* if this is an automatic variable, make the function call            */
    if ( VAL_GVAR(gvar) == 0 && ELM_PLIST( ExprGVars, gvar ) != 0 ) {

        /* make the function call                                          */
        func = ELM_PLIST( ELM_PLIST( ExprGVars, gvar ), 1 );
        arg  = ELM_PLIST( ELM_PLIST( ExprGVars, gvar ), 2 );
        CALL_1ARGS( func, arg );

        /* if this is still an automatic variable, this is an error        */
        while ( VAL_GVAR(gvar) == 0 ) {
            ErrorReturnVoid(
       "Variable: automatic variable '%s' must get a value by function call",
                (Int)CSTR_STRING( ELM_PLIST(NameGVars,gvar) ), 0L,
                "you can return after assigning a value" );
        }

    }

    /* return the value                                                    */
    return VAL_GVAR(gvar);
}


/****************************************************************************
**
*F  NameGVar(<gvar>)  . . . . . . . . . . . . . . . name of a global variable
**
**  'NameGVar' returns the name of the global variable <gvar> as a C string.
*/
Char *          NameGVar (
    UInt                gvar )
{
    return CSTR_STRING( ELM_PLIST( NameGVars, gvar ) );
}


/****************************************************************************
**
*F  GVarName(<name>)  . . . . . . . . . . . . . .  global variable for a name
**
**  'GVarName' returns the global variable with the name <name>.
*/
UInt GVarName (
    SYS_CONST Char *    name )
{
    Obj                 gvar;           /* global variable (as imm intval) */
    UInt                pos;            /* hash position                   */
    Char                namx [1024];    /* temporary copy of <name>        */
    Obj                 string;         /* temporary string value <name>   */
    Obj                 table;          /* temporary copy of <TableGVars>  */
    Obj                 gvar2;          /* one element of <table>          */
    SYS_CONST Char *    p;              /* loop variable                   */
    UInt                i;              /* loop variable                   */

    /* start looking in the table at the following hash position           */
    pos = 0;
    for ( p = name; *p != '\0'; p++ ) {
        pos = 65599 * pos + *p;
    }
    pos = (pos % SizeGVars) + 1;

    /* look through the table until we find a free slot or the global      */
    while ( (gvar = ELM_PLIST( TableGVars, pos )) != 0
         && SyStrncmp( NameGVar( INT_INTOBJ(gvar) ), name, 1023 ) ) {
        pos = (pos % SizeGVars) + 1;
    }

    /* if we did not find the global variable, make a new one and enter it */
    /* (copy the name first, to avoid a stale pointer in case of a GC)     */
    if ( gvar == 0 ) {
        CountGVars++;
        gvar = INTOBJ_INT(CountGVars);
        SET_ELM_PLIST( TableGVars, pos, gvar );
        namx[0] = '\0';
        SyStrncat( namx, name, 1023 );
        string = NEW_STRING( SyStrlen(namx) );
        SyStrncat( CSTR_STRING(string), namx, SyStrlen(namx) );
        GROW_PLIST(    ValGVars,    CountGVars );
        SET_LEN_PLIST( ValGVars,    CountGVars );
        SET_ELM_PLIST( ValGVars,    CountGVars, 0 );
        GROW_PLIST(    NameGVars,   CountGVars );
        SET_LEN_PLIST( NameGVars,   CountGVars );
        SET_ELM_PLIST( NameGVars,   CountGVars, string );
        CHANGED_BAG(   NameGVars );
        GROW_PLIST(    WriteGVars,  CountGVars );
        SET_LEN_PLIST( WriteGVars,  CountGVars );
        SET_ELM_PLIST( WriteGVars,  CountGVars, INTOBJ_INT(1) );
        GROW_PLIST(    ExprGVars,   CountGVars );
        SET_LEN_PLIST( ExprGVars,   CountGVars );
        SET_ELM_PLIST( ExprGVars,   CountGVars, 0 );
        GROW_PLIST(    CopiesGVars, CountGVars );
        SET_LEN_PLIST( CopiesGVars, CountGVars );
        SET_ELM_PLIST( CopiesGVars, CountGVars, 0 );
        GROW_PLIST(    FopiesGVars, CountGVars );
        SET_LEN_PLIST( FopiesGVars, CountGVars );
        SET_ELM_PLIST( FopiesGVars, CountGVars, 0 );
        PtrGVars = ADDR_OBJ( ValGVars );
    }

    /* if the table is too crowed, make a larger one, rehash the names     */
    if ( SizeGVars < 3 * CountGVars / 2 ) {
        table = TableGVars;
        SizeGVars = 2 * SizeGVars + 1;
        TableGVars = NEW_PLIST( T_PLIST, SizeGVars );
        SET_LEN_PLIST( TableGVars, SizeGVars );
        for ( i = 1; i <= (SizeGVars-1)/2; i++ ) {
            gvar2 = ELM_PLIST( table, i );
            if ( gvar2 == 0 )  continue;
            pos = 0;
            for ( p = NameGVar( INT_INTOBJ(gvar2) ); *p != '\0'; p++ ) {
                pos = 65599 * pos + *p;
            }
            pos = (pos % SizeGVars) + 1;
            while ( ELM_PLIST( TableGVars, pos ) != 0 ) {
                pos = (pos % SizeGVars) + 1;
            }
            SET_ELM_PLIST( TableGVars, pos, gvar2 );
        }
    }

    /* return the global variable                                          */
    return INT_INTOBJ(gvar);
}

/****************************************************************************
**
*V  CopyAndFopyGVars . . kernel table of kernel copies and "fopies" of global
**                       variables
**
**  This needs to be kept inside the kernel so that the copies can be updated
**  after loading a workspace.
*/  

typedef struct  { 
  Obj * copy;
  UInt isFopy;
  Char * name;
} TNumCopyGVar;

#ifndef MAX_COPY_AND_FOPY_GVARS
#define MAX_COPY_AND_FOPY_GVARS 20000
#endif

static TNumCopyGVar CopyAndFopyGVars[MAX_COPY_AND_FOPY_GVARS];

static NCopyAndFopyGVars = 0;

/****************************************************************************
**
*F  InitCopyGVar(<gvar>,<copy>) . . . .  declare C variable as copy of global
**
**  'InitCopyGVar' makes  the C variable <cvar>  at address  <copy> a copy of
**  <gvar>.
*/
void            InitCopyGVar (
    UInt                gvar,
    Obj *               copy )
{
    Obj                 cops;           /* copies list                     */
    UInt                ncop;           /* number of copies                */

    /* get the copies list and its length                                  */
    if ( ELM_PLIST( CopiesGVars, gvar ) != 0 ) {
        cops = ELM_PLIST( CopiesGVars, gvar );
    }
    else {
        cops = NEW_PLIST( T_PLIST, 0 );
        SET_ELM_PLIST( CopiesGVars, gvar, cops );
        CHANGED_BAG(CopiesGVars)
    }
    ncop = LEN_PLIST(cops);

    /* append the copy to the copies list                                  */
    GROW_PLIST( cops, ncop+1 );
    SET_LEN_PLIST( cops, ncop+1 );
    SET_ELM_PLIST( cops, ncop+1, (Obj)copy );
    CHANGED_BAG(cops)

    /* now copy the value of <gvar> to <cvar>                              */
    *copy = VAL_GVAR(gvar);

    /* make a record in the kernel also, for saving and loading */
    if (NCopyAndFopyGVars >= MAX_COPY_AND_FOPY_GVARS)
      {
        Pr("Panic, no room to record CopyGVar\n",0L,0L);
        SyExit(1);
      }
    CopyAndFopyGVars[NCopyAndFopyGVars].copy = copy;
    CopyAndFopyGVars[NCopyAndFopyGVars].isFopy = 0;
    CopyAndFopyGVars[NCopyAndFopyGVars].name = NameGVar(gvar);
    NCopyAndFopyGVars++;
}


/****************************************************************************
**
*F  InitFopyGVar(<gvar>,<copy>) . . . .  declare C variable as copy of global
**
**  'InitFopyGVar' makes the C variable <cvar> at address <copy> a (function)
**  copy of   <gvar>.  That means  that whenever  the  value  of  <gvar> is a
**  function, then <cvar> will reference the same  value (i.e., will hold the
**  same bag identifier).  When the  value of <gvar> is  not a function, then
**  <cvar> will reference a function that signals the  error ``<func> must be
**  a   function''.  When <gvar>  has  no  assigned value,  then <cvar>  will
**  reference a  function  that  signals  the error  ``<gvar>  must  have  an
**  assigned value''.
*/
void            InitFopyGVar (
    UInt                gvar,
    Obj *               copy )
{
    Obj                 cops;           /* copies list                     */
    UInt                ncop;           /* number of copies                */

    /* get the copies list and its length                                  */
    if ( ELM_PLIST( FopiesGVars, gvar ) != 0 ) {
        cops = ELM_PLIST( FopiesGVars, gvar );
    }
    else {
        cops = NEW_PLIST( T_PLIST, 0 );
        SET_ELM_PLIST( FopiesGVars, gvar, cops );
        CHANGED_BAG(FopiesGVars)
    }
    ncop = LEN_PLIST(cops);

    /* append the copy to the copies list                                  */
    GROW_PLIST( cops, ncop+1 );
    SET_LEN_PLIST( cops, ncop+1 );
    SET_ELM_PLIST( cops, ncop+1, (Obj)copy );
    CHANGED_BAG(cops)

    /* now copy the value of <gvar> to <cvar>                              */
    if ( VAL_GVAR(gvar) != 0 && TNUM_OBJ(VAL_GVAR(gvar)) == T_FUNCTION ) {
        *copy = VAL_GVAR(gvar);
    }
    else if ( VAL_GVAR(gvar) != 0 ) {
        *copy = ErrorMustEvalToFuncFunc;
    }
    else {
        *copy = ErrorMustHaveAssObjFunc;
    }
    
    /* make a record in the kernel also, for saving and loading */
    if (NCopyAndFopyGVars >= MAX_COPY_AND_FOPY_GVARS)
      {
        Pr("Panic, no room to record FopyGVar\n",0L,0L);
        SyExit(1);
      }
    CopyAndFopyGVars[NCopyAndFopyGVars].copy = copy;
    CopyAndFopyGVars[NCopyAndFopyGVars].isFopy = 1;
    CopyAndFopyGVars[NCopyAndFopyGVars].name = NameGVar(gvar);
    NCopyAndFopyGVars++;
}


/****************************************************************************
**
*V  Tilde . . . . . . . . . . . . . . . . . . . . . . . . global variable '~'
**
**  'Tilde' is  the global variable '~', the  one used in expressions such as
**  '[ [ 1, 2 ], ~[1] ]'.
**
**  Actually  when such expressions  appear in functions, one should probably
**  use a local variable.  But for now this is good enough.
*/
UInt Tilde;


/****************************************************************************
**
*F  MakeReadOnlyGVar( <gvar> )  . . . . . .  make a global variable read only
*/
Obj MakeReadOnlyGVarFunc;

void MakeReadOnlyGVar (
    UInt                gvar )
{       
    SET_ELM_PLIST( WriteGVars, gvar, INTOBJ_INT(0) );
    CHANGED_BAG(WriteGVars)
}


/****************************************************************************
**
*F  MakeReadOnlyGVarHandler(<self>,<name>)   make a global variable read only
**
**  'MakeReadOnlyGVarHandler' implements the function 'MakeReadOnlyGVar'.
**
**  'MakeReadOnlyGVar( <name> )'
**
**  'MakeReadOnlyGVar' make the global  variable with the name <name>  (which
**  must be a GAP string) read only.
*/
Obj MakeReadOnlyGVarHandler (
    Obj                 self,
    Obj                 name )
{       
    /* check the argument                                                  */
    while ( ! IsStringConv( name ) ) {
        name = ErrorReturnObj(
            "MakeReadOnlyGVar: <name> must be a string (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(name)].name), 0L,
            "you can return a string for <name>" );
    }

    /* get the variable and make it read only                              */
    MakeReadOnlyGVar(GVarName(CSTR_STRING(name)));

    /* return void                                                         */
    return 0;
}


/****************************************************************************
**
*F  MakeReadWriteGVar( <gvar> ) . . . . . . make a global variable read write
*/
Obj MakeReadWriteGVarFunc;

void MakeReadWriteGVar (
    UInt                gvar )
{
    SET_ELM_PLIST( WriteGVars, gvar, INTOBJ_INT(1) );
    CHANGED_BAG(WriteGVars)
}


/****************************************************************************
**
*F  MakeReadWriteGVarHandler(<self>,<name>) make a global variable read write
**
**  'MakeReadWriteGVarHandler' implements the function 'MakeReadWriteGVar'.
**
**  'MakeReadWriteGVar( <name> )'
**
**  'MakeReadWriteGVar' make the global  variable with the name <name>  (which
**  must be a GAP string) read and writable.
*/
Obj MakeReadWriteGVarHandler (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( name ) ) {
        name = ErrorReturnObj(
            "MakeReadWriteGVar: <name> must be a string (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(name)].name), 0L,
            "you can return a string for <name>" );
    }

    /* get the variable and make it read write                             */
    MakeReadWriteGVar(GVarName(CSTR_STRING(name)));

    /* return void                                                         */
    return 0;
}


/****************************************************************************
**
*F  AUTOHandler() . . . . . . . . . . . . .   make automatic global variables
**
**  'AUTOHandler' implements the internal function 'AUTO'.
**
**  'AUTO( <func>, <arg>, <name1>, ... )'
**
**  'AUTO' makes   the global variables,  whose  names are given  the strings
**  <name1>, <name2>, ..., automatic.  That means  that when the value of one
**  of  those global  variables  is requested,  then  the function  <func> is
**  called and the  argument <arg>  is passed.   This function  call  should,
**  cause the execution  of an assignment to  that global variable, otherwise
**  an error is signalled.
*/
Obj             AUTOFunc;

Obj             AUTOHandler (
    Obj                 self,
    Obj                 args )
{
    Obj                 func;           /* the function to call            */
    Obj                 arg;            /* the argument to pass            */
    Obj                 list;           /* function and argument list      */
    Obj                 name;           /* one name (as a GAP string)      */
    UInt                gvar;           /* one global variable             */
    UInt                i;              /* loop variable                   */

    /* check that there are enough arguments                               */
    if ( LEN_LIST(args) < 2 ) {
        ErrorQuit(
            "usage: AUTO( <func>, <arg>, <name1>... )",
            0L, 0L );
        return 0;
    }

    /* get and check the function                                          */
    func = ELM_LIST( args, 1 );
    while ( TNUM_OBJ(func) != T_FUNCTION ) {
        func = ErrorReturnObj(
            "AUTO: <func> must be a function (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(func)].name), 0L,
            "you can return a function for <func>" );
    }

    /* get the argument                                                    */
    arg = ELM_LIST( args, 2 );

    /* make the list of function and argument                              */
    list = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( list, 2 );
    SET_ELM_PLIST( list, 1, func );
    SET_ELM_PLIST( list, 2, arg );

    /* make the global variables automatic                                 */
    for ( i = 3; i <= LEN_LIST(args); i++ ) {
        name = ELM_LIST( args, i );
        while ( ! IsStringConv(name) ) {
            name = ErrorReturnObj(
                "AUTO: <name> must be a string (not a %s)",
                (Int)(InfoBags[TNUM_OBJ(name)].name), 0L,
                "you can return a string for <name>" );
        }
        gvar = GVarName( CSTR_STRING(name) );
        SET_ELM_PLIST( ValGVars,   gvar, 0    );
        SET_ELM_PLIST( ExprGVars, gvar, list );
        CHANGED_BAG(   ExprGVars );
    }

    /* return void                                                         */
    return 0;
}


/****************************************************************************
**
*F  iscomplete( <name>, <len> ) . . . . . . . .  find the completions of name
*F  completion( <name>, <len> ) . . . . . . . .  find the completions of name
*/
UInt            iscomplete_gvar (
    Char *              name,
    UInt                len )
{
    Char *              curr;
    UInt                i, k;

    for ( i = 1; i <= CountGVars; i++ ) {
        curr = NameGVar( i );
        for ( k = 0; name[k] != 0 && curr[k] == name[k]; k++ ) ;
        if ( k == len && curr[k] == '\0' )  return 1;
    }
    return 0;
}

UInt            completion_gvar (
    Char *              name,
    UInt                len )
{
    Char *              curr;
    Char *              next;
    UInt                i, k;

    next = 0;
    for ( i = 1; i <= CountGVars; i++ ) {
        curr = NameGVar( i );
        for ( k = 0; name[k] != 0 && curr[k] == name[k]; k++ ) ;
        if ( k < len || curr[k] <= name[k] )  continue;
        if ( next != 0 ) {
            for ( k = 0; curr[k] != '\0' && curr[k] == next[k]; k++ ) ;
            if ( k < len || next[k] < curr[k] )  continue;
        }
        next = curr;
    }

    if ( next != 0 ) {
        for ( k = 0; next[k] != '\0'; k++ )
            name[k] = next[k];
        name[k] = '\0';
    }

    return next != 0;
}


/****************************************************************************
**
*F  FuncIDENTS_GVAR( <self> ) . . . . . . . . . .  idents of global variables
*/
Obj FuncIDENTS_GVAR (
    Obj                 self )
{
    extern Obj          NameGVars;
    Obj                 copy;
    UInt                i;

    copy = NEW_PLIST( T_PLIST+IMMUTABLE, LEN_PLIST(NameGVars) );
    for ( i = 1;  i <= LEN_PLIST(NameGVars);  i++ ) {
        SET_ELM_PLIST( copy, i, ELM_PLIST( NameGVars, i ) );
    }
    SET_LEN_PLIST( copy, LEN_PLIST(NameGVars) );
    return copy;
}


/****************************************************************************
**
*F  FuncASS_GVAR( <self>, <gvar>, <val> ) . . . . assign to a global variable
*/
Obj FuncASS_GVAR (
    Obj                 self,
    Obj                 gvar,
    Obj                 val )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( gvar ) ) {
        gvar = ErrorReturnObj(
            "READ: <gvar> must be a string (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(gvar)].name), 0L,
            "you can return a string for <gvar>" );
    }

    AssGVar( GVarName( CSTR_STRING(gvar) ), val );
    return 0L;
}


/****************************************************************************
**
*F  FuncISB_GVAR( <self>, <gvar> )  . . check assignment of a global variable
*/
Obj FuncISB_GVAR (
    Obj                 self,
    Obj                 gvar )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( gvar ) ) {
        gvar = ErrorReturnObj(
            "READ: <gvar> must be a string (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(gvar)].name), 0L,
            "you can return a string for <gvar>" );
    }

    return ValAutoGVar( GVarName( CSTR_STRING(gvar) ) ) ? True : False;
}


/****************************************************************************
**
*F  InitGVars() . . . . . . . . . . . initialize the global variables package
**
**  'InitGVars' initializes the global variables package.
*/
void            InitGVars ( void )
{
    /* make the error functions for 'AssGVar'                              */
    InitGlobalBag( &ErrorMustEvalToFuncFunc, "gvars: error function 1" );
    InitHandlerFunc( ErrorMustEvalToFuncHandler,
                     "error must evaluate to a function");
    ErrorMustEvalToFuncFunc = NewFunctionC( "ErrorMustEvalToFunc", -1L,"args",
                                ErrorMustEvalToFuncHandler );
    
    InitGlobalBag( &ErrorMustHaveAssObjFunc, "gvars: error function 2" );
    InitHandlerFunc( ErrorMustHaveAssObjHandler,
                     "error must have associated object");
    ErrorMustHaveAssObjFunc = NewFunctionC( "ErrorMustHaveAssObj", -1L,"args",
                                ErrorMustHaveAssObjHandler );

    /* make the lists for global variables                                 */
    CountGVars = 0;
    InitGlobalBag( &ValGVars, "gvars: values" );
    ValGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( ValGVars, 0 );
    PtrGVars = ADDR_OBJ( ValGVars );
    InitGlobalBag( &NameGVars, "gvars: names" );
    NameGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( NameGVars, 0 );
    InitGlobalBag( &WriteGVars, "gvars: writable flags" );
    WriteGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( WriteGVars, 0 );
    InitGlobalBag( &ExprGVars, "gvars: expressions for AUTO" );
    ExprGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( ExprGVars, 0 );
    InitGlobalBag( &CopiesGVars, "gvars: kernel copies" );
    CopiesGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( CopiesGVars, 0 );
    InitGlobalBag( &FopiesGVars, "gvars: kernel fopies"  );
    FopiesGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( FopiesGVars, 0 );

    /* make the list of global variables                                   */
    SizeGVars = 997;
    InitGlobalBag( &TableGVars, "gvars: hash tables" );
    TableGVars = NEW_PLIST( T_PLIST, SizeGVars );
    SET_LEN_PLIST( TableGVars, SizeGVars );

    /* create the global variable '~'                                      */
    Tilde = GVarName( "~" );

    /* install the functions 'MakeReadOnlyGVar' and 'MakeReadWriteGVar'    */
    InitHandlerFunc( MakeReadOnlyGVarHandler, "make gvar read only");
    MakeReadOnlyGVarFunc = NewFunctionC( "MakeReadOnlyGVar", 1L, "name",
                                MakeReadOnlyGVarHandler );
    AssGVar( GVarName( "MakeReadOnlyGVar" ), MakeReadOnlyGVarFunc );

    InitHandlerFunc( MakeReadWriteGVarHandler, "make gvar read write");
    MakeReadWriteGVarFunc = NewFunctionC( "MakeReadWriteGVar", 1L, "name",
                                MakeReadWriteGVarHandler );
    AssGVar( GVarName( "MakeReadWriteGVar" ), MakeReadWriteGVarFunc );
            
    /* install the function 'AUTO'                                         */
    InitHandlerFunc( AUTOHandler, "AUTO");
    AUTOFunc = NewFunctionC( "AUTO", -1L, "args", AUTOHandler );
    AssGVar( GVarName( "AUTO" ), AUTOFunc );

    C_NEW_GVAR_FUNC( "IDENTS_GVAR", 0L, "",
                  FuncIDENTS_GVAR,
           "src/gap.c:IDENTS_GVAR" );

    C_NEW_GVAR_FUNC( "ISB_GVAR", 1L, "gvar",
                  FuncISB_GVAR,
           "src/gap.c:ISB_GVAR" );

    C_NEW_GVAR_FUNC( "ASS_GVAR", 2L, "gvar, value",
                  FuncASS_GVAR,
           "src/gap.c:ASS_GVAR" );

}



