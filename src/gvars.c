/****************************************************************************
**
*W  gvars.c                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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
#include <src/system.h>                 /* Ints, UInts */
#include <src/gapstate.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */

#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/code.h>                   /* coder */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */

#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/bool.h>                   /* booleans */

#include <src/hpc/tls.h>                /* thread-local storage */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/aobjects.h>           /* atomic objects */

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
Obj   ValGVars;

Obj * PtrGVars;


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
*V  CopiesGVars . . . . . . . . . . . . . internal copies of global variables
*V  FopiesGVars . . . . . . . .  internal function copies of global variables
*V  CountGVars  . . . . . . . . . . . . . . . . .  number of global variables
*/
Obj             NameGVars;
Obj             WriteGVars;
Obj             ExprGVars;
Obj             CopiesGVars;
Obj             FopiesGVars;
UInt            CountGVars;


#define ELM_GVAR_LIST( list, gvar ) \
    ELM_PLIST( list, gvar )

#define SET_ELM_GVAR_LIST( list, gvar, val ) \
    SET_ELM_PLIST( list, gvar, val )


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

static Obj REREADING;                   /* Copy of GAP global variable REREADING */

/****************************************************************************
**
** AssGVarUnsafe(<gvar>,<val>)
**
** Assign to a global variable with no safety checks
** - Does not check if the variable is readonly
** - Does not check if it is automatic, has internal copies or fopies
**
** The current main use of this function is to handle the `~` variable,
** both for speed and because it is marked read-only to avoid users editing
** it.
*/

void            AssGVarUnsafe (
    UInt                gvar,
    Obj                 val )
{
    /* assign the value to the global variable                             */
    VAL_GVAR(gvar) = val;
    CHANGED_BAG( ValGVars );

}

void            AssGVar (
    UInt                gvar,
    Obj                 val )
{
    Obj                 cops;           /* list of internal copies         */
    Obj *               copy;           /* one copy                        */
    UInt                i;              /* loop variable                   */
    Obj                 onam;           /* object of <name>                */

    /* make certain that the variable is not read only                     */
    while ( (REREADING != True) &&
            (ELM_GVAR_LIST( WriteGVars, gvar ) == INTOBJ_INT(0)) ) {
            
        if(gvar == Tilde) {
                ErrorMayQuit("'~' cannot be assigned",0L,0L);
        }
        else {
            ErrorReturnVoid(
                "Variable: '%s' is read only",
                (Int)NameGVar(gvar), 0L,
                "you can 'return;' after making it writable" );
        }
    }

    /* assign the value to the global variable                             */
    VAL_GVAR(gvar) = val;
    CHANGED_BAG( ValGVars );

    /* if the global variable was automatic, convert it to normal          */
    SET_ELM_GVAR_LIST( ExprGVars, gvar, 0 );

    /* assign the value to all the internal copies                         */
    cops = ELM_GVAR_LIST( CopiesGVars, gvar );
    if ( cops != 0 ) {
        for ( i = 1; i <= LEN_PLIST(cops); i++ ) {
            copy  = (Obj*) ELM_PLIST(cops,i);
            *copy = val;
        }
    }

    /* if the value is a function, assign it to all the internal fopies    */
    cops = ELM_GVAR_LIST( FopiesGVars, gvar );
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
        onam = CopyToStringRep(NameGVarObj(gvar));
        RESET_FILT_LIST( onam, FN_IS_MUTABLE );
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
    if ( VAL_GVAR(gvar) == 0 && ExprGVar( gvar ) != 0 ) {

        /* make the function call                                          */
        func = ELM_PLIST( ExprGVar( gvar ), 1 );
        arg  = ELM_PLIST( ExprGVar( gvar ), 2 );
        CALL_1ARGS( func, arg );

        /* if this is still an automatic variable, this is an error        */
        while ( VAL_GVAR(gvar) == 0 ) {
            ErrorReturnVoid(
       "Variable: automatic variable '%s' must get a value by function call",
                (Int)NameGVar(gvar), 0L,
                "you can 'return;' after assigning a value" );
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
    return CSTR_STRING( ELM_GVAR_LIST( NameGVars, gvar ) );
}

Obj NameGVarObj ( UInt gvar )
{
    return ELM_GVAR_LIST( NameGVars, gvar );
}

Obj ExprGVar ( UInt gvar )
{
    return ELM_GVAR_LIST( ExprGVars, gvar );
}

#define NSCHAR '@'

/* TL: Obj CurrNamespace = 0; */

Obj FuncSET_NAMESPACE(Obj self, Obj str)
{
    STATE(CurrNamespace) = str;
    return 0;
}

Obj FuncGET_NAMESPACE(Obj self)
{
    return STATE(CurrNamespace);
}

/****************************************************************************
**
*F  GVarName(<name>)  . . . . . . . . . . . . . .  global variable for a name
**
**  'GVarName' returns the global variable with the name <name>.
*/
UInt GVarName ( 
    const Char *        name )
{
    Obj                 gvar;           /* global variable (as imm intval) */
    Char                gvarbuf[1024];  /* temporary copy for namespace    */
    Char *              cns;            /* Pointer to current namespace    */
    UInt                pos;            /* hash position                   */
    Char                namx [1024];    /* temporary copy of <name>        */
    Obj                 string;         /* temporary string value <name>   */
    Obj                 table;          /* temporary copy of <TableGVars>  */
    Obj                 gvar2;          /* one element of <table>          */
    const Char *        p;              /* loop variable                   */
    UInt                i;              /* loop variable                   */
    Int                 len;            /* length of name                  */

    /* First see whether it could be namespace-local: */
    cns = CSTR_STRING(STATE(CurrNamespace));
    if (*cns) {   /* only if a namespace is set */
        len = strlen(name);
        if (name[len-1] == NSCHAR) {
            strlcpy(gvarbuf, name, 512);
            strlcat(gvarbuf, cns, sizeof(gvarbuf));
            name = gvarbuf;
        }
    }

    /* start looking in the table at the following hash position           */
    pos = 0;
    for ( p = name; *p != '\0'; p++ ) {
        pos = 65599 * pos + *p;
    }
    pos = (pos % SizeGVars) + 1;

    /* look through the table until we find a free slot or the global      */
    while ( (gvar = ELM_PLIST( TableGVars, pos )) != 0
         && strncmp( NameGVar( INT_INTOBJ(gvar) ), name, 1023 ) ) {
        pos = (pos % SizeGVars) + 1;
    }

    /* if we did not find the global variable, make a new one and enter it */
    /* (copy the name first, to avoid a stale pointer in case of a GC)     */
    if ( gvar == 0 ) {
        CountGVars++;
        gvar = INTOBJ_INT(CountGVars);
        SET_ELM_PLIST( TableGVars, pos, gvar );
        strlcpy(namx, name, sizeof(namx));
        C_NEW_STRING_DYN(string, namx);

        RESET_FILT_LIST( string, FN_IS_MUTABLE );
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
void MakeReadOnlyGVar (
    UInt                gvar )
{       
    SET_ELM_GVAR_LIST( WriteGVars, gvar, INTOBJ_INT(0) );
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
            (Int)TNAM_OBJ(name), 0L,
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
void MakeReadWriteGVar (
    UInt                gvar )
{
    SET_ELM_GVAR_LIST( WriteGVars, gvar, INTOBJ_INT(1) );
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
            (Int)TNAM_OBJ(name), 0L,
            "you can return a string for <name>" );
    }

    /* get the variable and make it read write                             */
    MakeReadWriteGVar(GVarName(CSTR_STRING(name)));

    /* return void                                                         */
    return 0;
}

/****************************************************************************
**
*F  IsReadOnlyGVar( <gvar> ) . . . . . . return status of a global variable
*/
Int IsReadOnlyGVar (
    UInt                gvar )
{
    return !INT_INTOBJ(ELM_GVAR_LIST(WriteGVars, gvar));
}


/****************************************************************************
**
*F  FuncIsReadOnlyGVar( <name> ) . . .handler for GAP function
**
*/

static Obj FuncIsReadOnlyGVar (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( name ) ) {
        name = ErrorReturnObj(
            "IsReadOnlyGVar: <name> must be a string (not a %s)",
            (Int)TNAM_OBJ(name), 0L,
            "you can return a string for <name>" );
    }

    /* get the answer                             */
    return IsReadOnlyGVar(GVarName(CSTR_STRING(name))) ? True : False;
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
            (Int)TNAM_OBJ(func), 0L,
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
                (Int)TNAM_OBJ(name), 0L,
                "you can return a string for <name>" );
        }
        gvar = GVarName( CSTR_STRING(name) );
        SET_ELM_GVAR_LIST( ValGVars, gvar, 0 );
        SET_ELM_GVAR_LIST( ExprGVars, gvar, list );
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
        /* consider only variables which are currently bound for completion */
        if ( VAL_GVAR( i ) || ELM_GVAR_LIST( ExprGVars, i )) {
            curr = NameGVar( i );
            for ( k = 0; name[k] != 0 && curr[k] == name[k]; k++ ) ;
            if ( k < len || curr[k] <= name[k] )  continue;
            if ( next != 0 ) {
                for ( k = 0; curr[k] != '\0' && curr[k] == next[k]; k++ ) ;
                if ( k < len || next[k] < curr[k] )  continue;
            }
            next = curr;
        }
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
    Obj                 copy;
    UInt                i;
    UInt                numGVars;
    Obj                 strcopy;

    numGVars = LEN_PLIST(NameGVars);
    copy = NEW_PLIST( T_PLIST+IMMUTABLE, numGVars );
    for ( i = 1;  i <= numGVars;  i++ ) {
        /* Copy the string here, because we do not want members of NameGVars
         * accessable to users, as these strings must not be changed */
        strcopy = CopyToStringRep( NameGVarObj( i ) );
        SET_ELM_PLIST( copy, i, strcopy );
        CHANGED_BAG( copy );
    }
    SET_LEN_PLIST( copy, numGVars );
    return copy;
}

Obj FuncIDENTS_BOUND_GVARS (
    Obj                 self )
{
    Obj                 copy;
    UInt                i, j;
    UInt                numGVars;
    Obj                 strcopy;

    numGVars = LEN_PLIST(NameGVars);
    copy = NEW_PLIST( T_PLIST+IMMUTABLE, numGVars );
    for ( i = 1, j = 1;  i <= numGVars;  i++ ) {
        if ( VAL_GVAR( i ) || ELM_GVAR_LIST( ExprGVars, i ) ) {
           /* Copy the string here, because we do not want members of
            * NameGVars accessable to users, as these strings must not be
            * changed */
           strcopy = CopyToStringRep( NameGVarObj( i ) );
           SET_ELM_PLIST( copy, j, strcopy );
           CHANGED_BAG( copy );
           j++;
        }
    }
    SET_LEN_PLIST( copy, j - 1 );
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
            (Int)TNAM_OBJ(gvar), 0L,
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
  UInt gv;
    /* check the argument                                                  */
    while ( ! IsStringConv( gvar ) ) {
        gvar = ErrorReturnObj(
            "ISB_GVAR: <gvar> must be a string (not a %s)",
            (Int)TNAM_OBJ(gvar), 0L,
            "you can return a string for <gvar>" );
    }

    gv = GVarName( CSTR_STRING(gvar) );
    return ( VAL_GVAR( gv ) || ExprGVar( gv )) ? True : False;
}


/****************************************************************************
**
*F  FuncVAL_GVAR( <self>, <gvar> )  . . contents of a global variable
*/

Obj FuncVAL_GVAR (
    Obj                 self,
   Obj                 gvar )
{
  Obj val;
    /* check the argument                                                  */
    while ( ! IsStringConv( gvar ) ) {
        gvar = ErrorReturnObj(
            "VAL_GVAR: <gvar> must be a string (not a %s)",
            (Int)TNAM_OBJ(gvar), 0L,
            "you can return a string for <gvar>" );
    }

    /* get the value */
    val = ValAutoGVar( GVarName( CSTR_STRING(gvar) ) );

    while (val == (Obj) 0)
      val = ErrorReturnObj("VAL_GVAR: No value bound to %s",
                           (Int)CSTR_STRING(gvar), (Int) 0,
                           "you can return a value" );
    return val;
}

/****************************************************************************
**
*F  FuncUNB_GVAR( <self>, <gvar> )  . . unbind a global variable
*/

Obj FuncUNB_GVAR (
    Obj                 self,
    Obj                 gvar )
{
    /* check the argument                                                  */
    while ( ! IsStringConv( gvar ) ) {
        gvar = ErrorReturnObj(
            "UNB_GVAR: <gvar> must be a string (not a %s)",
            (Int)TNAM_OBJ(gvar), 0L,
            "you can return a string for <gvar>" );
    }

    /*  */
    AssGVar( GVarName( CSTR_STRING(gvar) ), (Obj)0 );
    return (Obj) 0;
}



/****************************************************************************
**

*F * * * * * * * * * * * * * copies and fopies  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  CopyAndFopyGVars  . . . . . .  kernel table of kernel copies and "fopies"
**
**  This needs to be kept inside the kernel so that the copies can be updated
**  after loading a workspace.
*/  
typedef struct  { 
    Obj *               copy;
    UInt                isFopy;
    const Char *        name;
} StructCopyGVar;

#ifndef MAX_COPY_AND_FOPY_GVARS
#define MAX_COPY_AND_FOPY_GVARS         30000
#endif

static StructCopyGVar CopyAndFopyGVars[MAX_COPY_AND_FOPY_GVARS];
static Int NCopyAndFopyGVars;


/****************************************************************************
**
*F  InitCopyGVar( <name>, <copy> )  . .  declare C variable as copy of global
**
**  'InitCopyGVar' makes  the C variable <cvar>  at address  <copy> a copy of
**  the global variable named <name> (which must be a kernel string).
**
**  The function only registers the  information in <CopyAndFopyGVars>.  At a
**  latter stage one  has to call  'UpdateCopyFopyInfo' to actually enter the
**  information stored in <CopyAndFopyGVars> into a plain list.
**
**  This is OK for garbage collection, but  a real problem  for saving in any
**  event, this information  does not really want to  be saved  because it is
**  kernel centred rather than workspace centred.
**
**  Accordingly we     provide  two    functions    `RemoveCopyFopyInfo'  and
**  `RestoreCopyFopyInfo' to  remove  or restore   the  information from  the
**  workspace.  The  Restore  function is  also   intended to  be used  after
**  loading a saved workspace
*/
void InitCopyGVar (
    const Char *        name ,
    Obj *               copy )
{
    /* make a record in the kernel for saving and loading                  */
    if ( NCopyAndFopyGVars >= MAX_COPY_AND_FOPY_GVARS ) {
        Pr( "Panic, no room to record CopyGVar\n", 0L, 0L );
        SyExit(1);
    }
    CopyAndFopyGVars[NCopyAndFopyGVars].copy = copy;
    CopyAndFopyGVars[NCopyAndFopyGVars].isFopy = 0;
    CopyAndFopyGVars[NCopyAndFopyGVars].name = name;
    NCopyAndFopyGVars++;
}


/****************************************************************************
**
*F  InitFopyGVar( <name>, <copy> )  . .  declare C variable as copy of global
**
**  'InitFopyGVar' makes the C variable <cvar> at address <copy> a (function)
**  copy  of the  global variable <gvar>,  whose name  is <name>.  That means
**  that whenever   the value  of   <gvar> is a    function, then <cvar> will
**  reference the same value (i.e., will hold the same bag identifier).  When
**  the value  of <gvar>  is not a   function, then  <cvar> will  reference a
**  function  that signals  the error ``<func>  must be  a function''.   When
**  <gvar> has no assigned value, then <cvar> will  reference a function that
**  signals the error ``<gvar> must have an assigned value''.
*/
void InitFopyGVar (
    const Char *        name,
    Obj *               copy )
{
    /* make a record in the kernel for saving and loading                  */
    if ( NCopyAndFopyGVars >= MAX_COPY_AND_FOPY_GVARS ) {
        Pr( "Panic, no room to record FopyGVar\n", 0L, 0L );
        SyExit(1);
    }
    CopyAndFopyGVars[NCopyAndFopyGVars].copy = copy;
    CopyAndFopyGVars[NCopyAndFopyGVars].isFopy = 1;
    CopyAndFopyGVars[NCopyAndFopyGVars].name = name;
    NCopyAndFopyGVars++;
}


/****************************************************************************
**
*F  UpdateCopyFopyInfo()  . . . . . . . . . .  convert kernel info into plist
*/
static Int NCopyAndFopyDone;

void UpdateCopyFopyInfo ( void )
{
    Obj                 cops;           /* copies list                     */
    UInt                ncop;           /* number of copies                */
    UInt                gvar;
    const Char *        name;           /* name of the variable            */
    Obj *               copy;           /* address of the copy             */

    /* loop over new copies and fopies                                     */
    for ( ; NCopyAndFopyDone < NCopyAndFopyGVars; NCopyAndFopyDone++ ) {
        name = CopyAndFopyGVars[NCopyAndFopyDone].name;
        copy = CopyAndFopyGVars[NCopyAndFopyDone].copy;
        gvar = GVarName(name);

        /* get the copies list and its length                              */
        if ( CopyAndFopyGVars[NCopyAndFopyDone].isFopy ) {
            cops = ELM_GVAR_LIST( FopiesGVars, gvar );
            if ( cops == 0 ) {
                cops = NEW_PLIST( T_PLIST, 0 );
                SET_ELM_GVAR_LIST( FopiesGVars, gvar, cops );
                CHANGED_BAG(FopiesGVars);
            }
        }
        else {
            cops = ELM_GVAR_LIST( CopiesGVars, gvar );
            if ( cops == 0 ) {
                cops = NEW_PLIST( T_PLIST, 0 );
                SET_ELM_GVAR_LIST( CopiesGVars, gvar, cops );
                CHANGED_BAG(CopiesGVars);
            }
        }
        ncop = LEN_PLIST(cops);

        /* append the copy to the copies list                              */
        GROW_PLIST( cops, ncop+1 );
        SET_LEN_PLIST( cops, ncop+1 );
        SET_ELM_PLIST( cops, ncop+1, (Obj)copy );
        CHANGED_BAG(cops);

        /* now copy the value of <gvar> to <cvar>                          */
        Obj val = VAL_GVAR(gvar);
        if ( CopyAndFopyGVars[NCopyAndFopyDone].isFopy ) {
            if ( val != 0 && IS_FUNC(val) ) {
                *copy = val;
            }
            else if ( val != 0 ) {
                *copy = ErrorMustEvalToFuncFunc;
            }
            else {
                *copy = ErrorMustHaveAssObjFunc;
            }
        }
        else {
            *copy = val;
        }
    }
}


/****************************************************************************
**
*F  RemoveCopyFopyInfo()  . . . remove the info about copies of gvars from ws
*/
void RemoveCopyFopyInfo( void )
{
    UInt        i, l;

    l = LEN_PLIST(CopiesGVars);
    for ( i = 1; i <= l; i++ )
        SET_ELM_GVAR_LIST( CopiesGVars, i, 0 );
    l = LEN_PLIST(FopiesGVars);
    for ( i = 1; i <= l; i++ )
        SET_ELM_GVAR_LIST( FopiesGVars, i, 0 );
    NCopyAndFopyDone = 0;
    return;
}


/****************************************************************************
**
*F  RestoreCopyFopyInfo() . . .  restore the info from the copy in the kernel
*/
void RestoreCopyFopyInfo( void )
{
    NCopyAndFopyDone = 0;
    UpdateCopyFopyInfo();
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

    { "MakeReadOnlyGVar", 1, "name",
      MakeReadOnlyGVarHandler, "src/gap.c:MakeReadOnlyGVar" },

    { "MakeReadWriteGVar", 1, "name",
      MakeReadWriteGVarHandler, "src/gap.c:MakeReadWriteGVar" },

    { "IsReadOnlyGVar", 1, "name",
      FuncIsReadOnlyGVar, "src/gap.c:IsReadOnlyGVar" },

    { "AUTO", -1, "args",
      AUTOHandler, "src/gap.c:AUTO" },
               
    { "IDENTS_GVAR", 0L, "",
      FuncIDENTS_GVAR, "src/gap.c:IDENTS_GVAR" },

    { "IDENTS_BOUND_GVARS", 0L, "",
      FuncIDENTS_BOUND_GVARS, "src/gap.c:IDENTS_BOUND_GVARS" },

    { "ISB_GVAR", 1L, "gvar",
      FuncISB_GVAR, "src/gap.c:ISB_GVAR" },

    { "ASS_GVAR", 2L, "gvar, value",
      FuncASS_GVAR, "src/gap.c:ASS_GVAR" },

    { "VAL_GVAR", 1L, "gvar",
      FuncVAL_GVAR, "src/gap.c:VAL_GVAR" },

    { "UNB_GVAR", 1L, "gvar",
      FuncUNB_GVAR, "src/gap.c:UNB_GVAR" },

    { "SET_NAMESPACE", 1L, "str",
      FuncSET_NAMESPACE, "src/gvars.c:SET_NAMESPACE" },

    { "GET_NAMESPACE", 0L, "",
      FuncGET_NAMESPACE, "src/gvars.c:GET_NAMESPACE" },

    { 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
  ValGVars = (Obj) 0;
  NCopyAndFopyGVars = 0;
  NCopyAndFopyDone = 0;
  InitHandlerRegistration();
  
    /* init global bags and handler                                        */
    InitGlobalBag( &ErrorMustEvalToFuncFunc,
                   "src/gvars.c:ErrorMustEvalToFuncFunc" );
    InitGlobalBag( &ErrorMustHaveAssObjFunc,
                   "src/gvars.c:ErrorMustHaveAssObjFunc" );
    InitGlobalBag( &ValGVars,
                   "src/gvars.c:ValGVars" );
    InitGlobalBag( &NameGVars,
                   "src/gvars.c:NameGVars" );
    InitGlobalBag( &WriteGVars,
                   "src/gvars.c:WriteGVars" );
    InitGlobalBag( &ExprGVars,
                   "src/gvars.c:ExprGVars" );
    InitGlobalBag( &CopiesGVars,
                   "src/gvars.c:CopiesGVars" );
    InitGlobalBag( &FopiesGVars,
                   "src/gvars.c:FopiesGVars"  );
    InitGlobalBag( &TableGVars,
                   "src/gvars.c:TableGVars" );
    InitGlobalBag( &STATE(CurrNamespace),
                   "src/gvars.c:CurrNamespace" );

    InitHandlerFunc( ErrorMustEvalToFuncHandler,
                     "src/gvars.c:ErrorMustEvalToFuncHandler" );
    InitHandlerFunc( ErrorMustHaveAssObjHandler,
                     "src/gvars.c:ErrorMustHaveAssObjHandler" );

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* Get a copy of REREADING                                             */
    ImportGVarFromLibrary("REREADING", &REREADING);
    
    
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
    /* make the lists for global variables                                 */
    CountGVars = LEN_PLIST( ValGVars );
    PtrGVars   = ADDR_OBJ( ValGVars );
    SizeGVars  = LEN_PLIST( TableGVars );

    /* create the global variable '~'                                      */
    Tilde = GVarName( "~" );

#if !defined(HPCGAP)
    /* stop unauthorised changes to '~'                                    */
    // FIXME: enabling this causes HPC-GAP to crash
    MakeReadOnlyGVar(Tilde);
#endif

    /* update fopies and copies                                            */
    UpdateCopyFopyInfo();

    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  PreSave( <module> ) . . . . . . . . . . . . . before save workspace
*/
static Int PreSave (
    StructInitInfo *    module )
{
  RemoveCopyFopyInfo();
  return 0;
}

/****************************************************************************
**
*F  PostSave( <module> ) . . . . . . . . . . . . . aftersave workspace
*/
static Int PostSave (
    StructInitInfo *    module )
{
  UpdateCopyFopyInfo();
  return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* make the error functions for 'AssGVar'                              */
    ErrorMustEvalToFuncFunc = NewFunctionC(
        "ErrorMustEvalToFunc", -1,"args", ErrorMustEvalToFuncHandler );
    
    ErrorMustHaveAssObjFunc = NewFunctionC(
        "ErrorMustHaveAssObj", -1L,"args", ErrorMustHaveAssObjHandler );

    /* make the lists for global variables                                 */
    ValGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( ValGVars, 0 );

    NameGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( NameGVars, 0 );

    WriteGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( WriteGVars, 0 );

    ExprGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( ExprGVars, 0 );

    CopiesGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( CopiesGVars, 0 );

    FopiesGVars = NEW_PLIST( T_PLIST, 0 );
    SET_LEN_PLIST( FopiesGVars, 0 );

    /* make the list of global variables                                   */
    SizeGVars  = 14033;
    TableGVars = NEW_PLIST( T_PLIST, SizeGVars );
    SET_LEN_PLIST( TableGVars, SizeGVars );

    /* Create the current namespace: */
    STATE(CurrNamespace) = NEW_STRING(0);
    SET_LEN_STRING(STATE(CurrNamespace),0);
    
    /* fix C vars                                                          */
    PostRestore( module );

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  CheckInit( <module> ) . . . . . . . . . . . . . . .  check initialisation
*/
static Int CheckInit (
    StructInitInfo *    module )
{
    Int                 success = 1;

    if ( NCopyAndFopyGVars != NCopyAndFopyDone ) {
        success = 0;
        Pr( "#W  failed to updated copies and fopies\n", 0L, 0L );
    }

    /* return success                                                      */
    return ! success;
}


/****************************************************************************
**
*F  InitInfoGVars() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "gvars",                            /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    CheckInit,                          /* checkInit                      */
    PreSave,                            /* preSave                        */
    PostSave,                            /* postSave                       */
    PostRestore                         /* postRestore                    */
};

StructInitInfo * InitInfoGVars ( void )
{
    return &module;
}


/****************************************************************************
**

*E  gvars.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
