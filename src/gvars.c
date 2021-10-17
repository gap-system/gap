/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
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

#include "gvars.h"

#include "bool.h"
#include "calls.h"
#include "error.h"
#include "gapstate.h"
#include "integer.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "stringobj.h"
#include "sysstr.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#include "hpc/guards.h"
#include "hpc/thread.h"
#include <pthread.h>
#endif

#include <stdio.h>


#ifdef HPCGAP
#define USE_GVAR_BUCKETS
#endif


#ifdef USE_GVAR_BUCKETS

#define GVAR_BUCKETS 1024
#define GVAR_BUCKET_SIZE 1024

#define GVAR_BUCKET(gvar) ((UInt)(gvar) / GVAR_BUCKET_SIZE)
#define GVAR_INDEX(gvar) ((UInt)(gvar) % GVAR_BUCKET_SIZE + 1)

#endif

/****************************************************************************
**
*V  ValGVars  . . . . . . . . . . . . . . . . . .  values of global variables
*V  PtrGVars  . . . . . . . . . . . . . pointer to values of global variables
**
*/
#ifdef USE_GVAR_BUCKETS
/*
**  'ValGVars' references the bags containing the values of the global
**  variables.
**
**  'PtrGVars' is a pointer  to the 'ValGVars' bag+1. This makes it faster to
**  access global variables.
*/
static Obj   ValGVars[GVAR_BUCKETS];
static Obj * PtrGVars[GVAR_BUCKETS];
#else
/*
**  'ValGVars' is the bag containing the values of the global variables.
**
**  'PtrGVars' is a pointer  to the 'ValGVars'  bag.  This makes it faster to
**  access global variables.
**
**  Since a   garbage  collection may move   this  bag around,    the pointer
**  'PtrGVars' must be  recalculated afterwards.   This is done in function
**  'GVarsAfterCollectBags' which is called by 'VarsAfterCollectBags'.
*/
static Obj   ValGVars;
static Obj * PtrGVars;
#endif


#ifdef HPCGAP

/****************************************************************************
**
*V  TLVars  . . . . . . . . . . . . . . . . . . . . . thread-local variables
*/

static Obj TLVars;

/****************************************************************************
**
*V  GVarLock  . . . . . . . . . . . . . . . . . .  lock for global variables
**
**  This lock is only needed for accessing global variables by name rather
**  than index and to initialize copy/fopy information.
*/

static pthread_rwlock_t GVarLock;
static void *GVarLockOwner;
static UInt GVarLockDepth;

static void LockGVars(int write) {
  if (PreThreadCreation)
    return;
  if (GVarLockOwner == GetTLS()) {
    GVarLockDepth++;
    return;
  }
  if (write) {
    pthread_rwlock_wrlock(&GVarLock);
    GVarLockOwner = GetTLS();
    GVarLockDepth = 1;
  }
  else
    pthread_rwlock_rdlock(&GVarLock);
}

static void UnlockGVars(void) {
  if (PreThreadCreation)
    return;
  if (GVarLockOwner == GetTLS()) {
    GVarLockDepth--;
    if (GVarLockDepth != 0)
      return;
    GVarLockOwner = NULL;
  }
  pthread_rwlock_unlock(&GVarLock);
}

#endif

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
*/

#ifdef USE_GVAR_BUCKETS

// FIXME/TODO: Do we still need the VAL_GVAR_INTERN macro, or can we replace
// it by ValGVar everywhere? The difference is of course the memory barrier,
// which might cause a performance penalty (OTOH, not using it right now might
// or might not be a bug?!?)
#define VAL_GVAR_INTERN(gvar)   (PtrGVars[GVAR_BUCKET(gvar)] \
                                    [GVAR_INDEX(gvar)-1])

#else

#define VAL_GVAR_INTERN(gvar)   PtrGVars[ (gvar) ]

#endif


inline Obj ValGVar(UInt gvar) {
  Obj result = VAL_GVAR_INTERN(gvar);
#ifdef HPCGAP
  MEMBAR_READ();
#endif
  return result;
}


/****************************************************************************
**
*V  NameGVars . . . . . . . . . . . . . . . . . . . names of global variables
*V  FlagsGVars  . . . . . . . . . . . . flags of global variables (see below)
*V  ExprGVars . . . . . . . . . .  expressions for automatic global variables
*V  CopiesGVars . . . . . . . . . . . . . internal copies of global variables
*V  FopiesGVars . . . . . . . .  internal function copies of global variables
*/
#ifdef USE_GVAR_BUCKETS
static Obj             NameGVars[GVAR_BUCKETS];
static Obj             FlagsGVars[GVAR_BUCKETS];
static Obj             ExprGVars[GVAR_BUCKETS];
static Obj             CopiesGVars[GVAR_BUCKETS];
static Obj             FopiesGVars[GVAR_BUCKETS];

#define ELM_GVAR_LIST( list, gvar ) \
    ELM_PLIST( list[GVAR_BUCKET(gvar)], GVAR_INDEX(gvar) )

#define SET_ELM_GVAR_LIST( list, gvar, val ) \
    SET_ELM_PLIST( list[GVAR_BUCKET(gvar)], GVAR_INDEX(gvar), val )

#define CHANGED_GVAR_LIST( list, gvar ) \
    CHANGED_BAG( list[GVAR_BUCKET(gvar)] );

#else   // USE_GVAR_BUCKETS

static Obj             NameGVars;
static Obj             FlagsGVars;
static Obj             ExprGVars;
static Obj             CopiesGVars;
static Obj             FopiesGVars;

#define ELM_GVAR_LIST( list, gvar ) \
    ELM_PLIST( list, gvar )

#define SET_ELM_GVAR_LIST( list, gvar, val ) \
    SET_ELM_PLIST( list, gvar, val )

#define CHANGED_GVAR_LIST( list, gvar ) \
    CHANGED_BAG( list );

#endif

// FlagsGVars contains information about global variables.
// Once cast to a GVarFlagInfo struct, this information is:
//

typedef enum {
    GVarAssignable = 0,
    GVarReadOnly = 1,
    GVarConstant = 2,
} GVarWriteFlag;

typedef struct {
    // 'gvarWriteFlag' is a value of type GVarWriteFlag which denotes whether
    // the variable is assignable, read-only, or constant.
    unsigned char gvarWriteFlag : 2;

    // 'hasExprCopiesFopies' indicates whether the variable has ever had a
    // non-default value assigned to ExprGVars, CopiesGVars or FopiesGVars.
    // Note that this value is never cleared at present, so it can be set to 1
    // while these three arrays all have their default value, but if it is 0
    // these arrays definitely have their default values.
    unsigned char hasExprCopiesFopies : 1;

    // 'isDeclared' indicates whether the variable was marked by
    // 'DeclareGlobalName' in which case no "Unbound global variable" syntax
    // warnings should be issued for it.
    unsigned char isDeclared : 1;
} GVarFlagInfo;

// If this size increases, the type used in GetGVarFlags and
// SetGVarFlags below must be changed
GAP_STATIC_ASSERT(sizeof(GVarFlagInfo) == sizeof(unsigned char),
                  "GVarFlagInfo size mismatch");

static GVarFlagInfo GetGVarFlagInfo(Int gvar)
{
    unsigned char val = INT_INTOBJ(ELM_GVAR_LIST(FlagsGVars, gvar));
    GVarFlagInfo  info;
    // This is technically the safest way of converting a struct to an integer
    // and is optimised away by the compiler
    memcpy(&info, &val, sizeof(GVarFlagInfo));
    return info;
}

static void SetGVarFlagInfo(Int gvar, GVarFlagInfo info)
{
    unsigned char val;
    // This is technically the safest way of converting an integer into a
    // struct and is optimised away by the compiler
    memcpy(&val, &info, sizeof(GVarFlagInfo));
    SET_ELM_GVAR_LIST(FlagsGVars, gvar, INTOBJ_INT(val));
}

static void InitGVarFlagInfo(Int gvar)
{
    // This is equal to setting all members of GVarFlagInfo to 0
    SET_ELM_GVAR_LIST(FlagsGVars, gvar, INTOBJ_INT(0));
}


// Helper functions to more easily set members of GVarFlagInfo
static void SetGVarWriteState(Int gvar, GVarWriteFlag w)
{
    GVarFlagInfo info = GetGVarFlagInfo(gvar);
    info.gvarWriteFlag = w;
    SetGVarFlagInfo(gvar, info);
}

static void SetHasExprCopiesFopies(Int gvar, BOOL set)
{
    GVarFlagInfo info = GetGVarFlagInfo(gvar);
    info.hasExprCopiesFopies = set;
    SetGVarFlagInfo(gvar, info);
}

static void SetIsDeclaredName(Int gvar, BOOL set)
{
    GVarFlagInfo info = GetGVarFlagInfo(gvar);
    info.isDeclared = set;
    SetGVarFlagInfo(gvar, info);
}

BOOL IsDeclaredGVar(UInt gvar)
{
    GVarFlagInfo info = GetGVarFlagInfo(gvar);
    return info.isDeclared;
}


/****************************************************************************
**
*V  CountGVars  . . . . . . . . . . . .  number of global variables, as T_INT
*/
static Obj             CountGVars;

/****************************************************************************
**
*V  TableGVars  . . . . . . . . . . . . . .  hashed table of global variables
*/
static Obj             TableGVars;


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

static Obj ErrorMustEvalToFuncHandler(Obj self, Obj args)
{
    ErrorQuit("Function Calls: <func> must be a function", 0, 0);
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

static Obj ErrorMustHaveAssObjHandler(Obj self, Obj args)
{
    ErrorQuit("Variable: <<unknown>> must have an assigned value", 0, 0);
    return 0;
}


/****************************************************************************
**
*F  AssGVar(<gvar>,<val>) . . . . . . . . . . . . assign to a global variable
**
**  'AssGVar' assigns the value <val> to the global variable <gvar>.
*/

static Obj REREADING;                   /* Copy of GAP global variable REREADING */

// We store pointers to C global variables as GAP immediate integers.
static Obj * ELM_COPS_PLIST(Obj cops, UInt i)
{
    UInt val = UInt_ObjInt(ELM_PLIST(cops, i));
    val <<= 2;
    return (Obj *)val;
}

// Assign 'val' to name 'gvar'. 'hasExprCopiesFopies' can be false if this
// variable has a non-default value assigned to ExprGVars, CopiesGVars or
// FopiesGVars (this is a performance optimisation). If 'giveNameToFunc'
// is TRUE then if 'val' is a function without a name it will be given the
// name 'gvar'.
static void AssGVarInternal(UInt gvar,
                            Obj  val,
                            BOOL hasExprCopiesFopies,
                            BOOL giveNameToFunc)
{
    Obj                 cops;           /* list of internal copies         */
    Obj *               copy;           /* one copy                        */
    UInt                i;              /* loop variable                   */
    Obj                 onam;           /* object of <name>                */

    /* assign the value to the global variable                             */
#ifdef HPCGAP
    if (!VAL_GVAR_INTERN(gvar)) {
        Obj expr = ExprGVar(gvar);
        if (IS_INTOBJ(expr)) {
          AssTLRecord(TLVars, INT_INTOBJ(expr), val);
          return;
        }
    }
    MEMBAR_WRITE();
#endif
    VAL_GVAR_INTERN(gvar) = val;
    CHANGED_GVAR_LIST( ValGVars, gvar );

    /* assign name to a function                                           */
#ifdef HPCGAP
    if (IS_BAG_REF(val) && REGION(val) == 0) { /* public region? */
#endif
        if (giveNameToFunc && val != 0 && TNUM_OBJ(val) == T_FUNCTION &&
            NAME_FUNC(val) == 0) {
            onam = CopyToStringRep(NameGVar(gvar));
            MakeImmutable(onam);
            SET_NAME_FUNC(val, onam);
            CHANGED_BAG(val);
        }
#ifdef HPCGAP
    }
#endif


    if (!hasExprCopiesFopies) {
        // No need to perform any of the remaining checks
        return;
    }

    /* if the global variable was automatic, convert it to normal          */
    SET_ELM_GVAR_LIST( ExprGVars, gvar, 0 );

    /* assign the value to all the internal copies                         */
    cops = ELM_GVAR_LIST( CopiesGVars, gvar );
    if ( cops != 0 ) {
        for ( i = 1; i <= LEN_PLIST(cops); i++ ) {
            copy = ELM_COPS_PLIST(cops, i);
            *copy = val;
        }
    }

    /* if the value is a function, assign it to all the internal fopies    */
    cops = ELM_GVAR_LIST( FopiesGVars, gvar );
#ifdef HPCGAP
    if (IS_BAG_REF(val) && REGION(val) == 0) { /* public region? */
#endif
    if ( cops != 0 && val != 0 && TNUM_OBJ(val) == T_FUNCTION ) {
        for ( i = 1; i <= LEN_PLIST(cops); i++ ) {
            copy = ELM_COPS_PLIST(cops, i);
            *copy = val;
        }
    }
#ifdef HPCGAP
    }
#endif

    /* if the values is not a function, assign the error function          */
    else if ( cops != 0 && val != 0 /* && TNUM_OBJ(val) != T_FUNCTION */ ) {
        for ( i = 1; i <= LEN_PLIST(cops); i++ ) {
            copy = ELM_COPS_PLIST(cops, i);
            *copy = ErrorMustEvalToFuncFunc;
        }
    }

    /* if this was an unbind, assign the other error function              */
    else if ( cops != 0 /* && val == 0 */ ) {
        for ( i = 1; i <= LEN_PLIST(cops); i++ ) {
            copy = ELM_COPS_PLIST(cops, i);
            *copy = ErrorMustHaveAssObjFunc;
        }
    }
}

void AssGVar(UInt gvar, Obj val)
{
    GVarFlagInfo info = GetGVarFlagInfo(gvar);

    if (info.gvarWriteFlag != GVarAssignable) {
        /* make certain that the variable is not read only */
        if ((REREADING != True) && info.gvarWriteFlag == GVarReadOnly) {
            ErrorMayQuit("Variable: '%g' is read only", (Int)NameGVar(gvar),
                         0);
        }

        // Make certain variable is not constant
        if (info.gvarWriteFlag == GVarConstant) {
            ErrorMayQuit("Variable: '%g' is constant", (Int)NameGVar(gvar),
                         0);
        }
    }

    AssGVarInternal(gvar, val, info.hasExprCopiesFopies, TRUE);
}

// This is a kernel-only variant of AssGVar which will change read-only
// variables, which is used for constants like:
// Time, MemoryAllocated, last, last2, last3
// Does not automatically give a name to functions based on variable name,
// as these names are not given by users.
void AssGVarWithoutReadOnlyCheck(UInt gvar, Obj val)
{
    GVarFlagInfo info = GetGVarFlagInfo(gvar);

    // Make certain variable is not constant
    if (info.gvarWriteFlag == GVarConstant) {
        ErrorMayQuit("Variable: '%g' is constant", (Int)NameGVar(gvar), 0);
    }

    AssGVarInternal(gvar, val, info.hasExprCopiesFopies, FALSE);
}


/****************************************************************************
**
*F  ValAutoGVar(<gvar>) . . . . . . . . value of an automatic global variable
**
**  'ValAutoGVar' returns the value of the global variable <gvar>.  This will
**  be 0 if  <gvar> has  no assigned value.    It will also cause a  function
**  call, if <gvar> is automatic.
*/
Obj             ValAutoGVar (
    UInt                gvar )
{
    Obj                 val;
    Obj                 expr;
    Obj                 func;           /* function to call for automatic  */
    Obj                 arg;            /* argument to pass for automatic  */

    val = ValGVar(gvar);

    /* if this is an automatic variable, make the function call            */
    if ( val == 0 && (expr = ExprGVar(gvar)) != 0 ) {

#ifdef HPCGAP
        if (IS_INTOBJ(expr)) {
          /* thread-local variable */
          return GetTLRecordField(TLVars, INT_INTOBJ(expr));
        }
#endif
        /* make the function call                                          */
        func = ELM_PLIST( expr, 1 );
        arg  = ELM_PLIST( expr, 2 );
        CALL_1ARGS( func, arg );

        /* if this is still an automatic variable, this is an error        */
        val = ValGVar(gvar);
        if (val == 0) {
            ErrorMayQuit("Variable: automatic variable '%g' must get a value "
                         "by function call",
                         (Int)NameGVar(gvar), 0);
        }

    }

    /* return the value                                                    */
    return val;
}

/****************************************************************************
**
*F  ValGVarTL(<gvar>) . . . . . . . . value of a global/thread-local variable
**
**  'ValGVarTL' returns the value of the global or thread-local variable
**  <gvar>.
*/
#ifdef HPCGAP
Obj             ValGVarTL (
    UInt                gvar )
{
    Obj                 expr;
    Obj                 val;

    val = ValGVar(gvar);
    /* is this a thread-local variable? */
    if ( val == 0 && (expr = ExprGVar(gvar)) != 0 ) {

        if (IS_INTOBJ(expr)) {
          /* thread-local variable */
          return GetTLRecordField(TLVars, INT_INTOBJ(expr));
        }
    }

    /* return the value                                                    */
    return val;
}

static Obj FuncIsThreadLocalGVar(Obj self, Obj name)
{
    RequireStringRep(SELF_NAME, name);

  UInt gvar = GVarName(CONST_CSTR_STRING(name));
  return (VAL_GVAR_INTERN(gvar) == 0 && IS_INTOBJ(ExprGVar(gvar))) ?
    True: False;
}
#endif


#ifdef USE_GVAR_BUCKETS
static Obj NewGVarBucket(void)
{
    Obj result = NEW_PLIST(T_PLIST, GVAR_BUCKET_SIZE);
    SET_LEN_PLIST(result, GVAR_BUCKET_SIZE);
#ifdef HPCGAP
    MakeBagPublic(result);
#endif
    return result;
}
#endif

Obj NameGVar ( UInt gvar )
{
    return ELM_GVAR_LIST( NameGVars, gvar );
}

Obj ExprGVar ( UInt gvar )
{
    return ELM_GVAR_LIST( ExprGVars, gvar );
}

#define NSCHAR '@'

/* TL: Obj CurrNamespace = 0; */

static Obj FuncSET_NAMESPACE(Obj self, Obj str)
{
    STATE(CurrNamespace) = str;
    return 0;
}

static Obj FuncGET_NAMESPACE(Obj self)
{
    return STATE(CurrNamespace);
}


static inline UInt HashString( const Char * name )
{
    UInt hash = 0;
    while ( *name ) {
        hash = 65599 * hash + *name++;
    }
    return hash;
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
    const Char *        cns;            /* Pointer to current namespace    */
    UInt                pos;            /* hash position                   */
    Obj                 string;         /* temporary string value <name>   */
    Obj                 table;          /* temporary copy of <TableGVars>  */
    Obj                 gvar2;          /* one element of <table>          */
    UInt                i;              /* loop variable                   */
    Int                 len;            /* length of name                  */
    UInt                sizeGVars;      // size of <TableGVars>

    /* First see whether it could be namespace-local: */
    cns = STATE(CurrNamespace) ? CONST_CSTR_STRING(STATE(CurrNamespace)) : "";
    if (*cns) {   /* only if a namespace is set */
        len = strlen(name);
        if (name[len-1] == NSCHAR) {
            gap_strlcpy(gvarbuf, name, 512);
            gap_strlcat(gvarbuf, cns, sizeof(gvarbuf));
            name = gvarbuf;
        }
    }

    /* start looking in the table at the following hash position           */
    const UInt hash = HashString( name );
#ifdef HPCGAP
    LockGVars(0);
#endif

    /* look through the table until we find a free slot or the global      */
    sizeGVars = LEN_PLIST(TableGVars);
    pos = (hash % sizeGVars) + 1;
    while ( (gvar = ELM_PLIST( TableGVars, pos )) != 0
         && strncmp( CONST_CSTR_STRING( NameGVar( INT_INTOBJ(gvar) ) ), name, 1023 ) ) {
        pos = (pos % sizeGVars) + 1;
    }

#ifdef HPCGAP
    if (gvar == 0 && !PreThreadCreation) {
        /* upgrade to write lock and repeat search */
        UnlockGVars();
        LockGVars(1);

        /* look through the table until we find a free slot or the global  */
        sizeGVars = LEN_PLIST(TableGVars);
        pos = (hash % sizeGVars) + 1;
        while ( (gvar = ELM_PLIST( TableGVars, pos )) != 0
             && strncmp( CONST_CSTR_STRING( NameGVar( INT_INTOBJ(gvar) ) ), name, 1023 ) ) {
            pos = (pos % sizeGVars) + 1;
        }
    }
#endif

    /* if we did not find the global variable, make a new one and enter it */
    /* (copy the name first, to avoid a stale pointer in case of a GC)     */
    if ( gvar == 0 ) {
        const UInt numGVars = INT_INTOBJ(CountGVars) + 1;
        CountGVars = INTOBJ_INT(numGVars);
        gvar = INTOBJ_INT(numGVars);
        SET_ELM_PLIST( TableGVars, pos, gvar );
        if (name != gvarbuf)
            gap_strlcpy(gvarbuf, name, sizeof(gvarbuf));
        string = MakeImmString(gvarbuf);

#ifdef USE_GVAR_BUCKETS
        UInt gvar_bucket = GVAR_BUCKET(numGVars);
        if (!ValGVars[gvar_bucket]) {
           ValGVars[gvar_bucket] = NewGVarBucket();
           PtrGVars[gvar_bucket] = ADDR_OBJ(ValGVars[gvar_bucket])+1;
           NameGVars[gvar_bucket] = NewGVarBucket();
           FlagsGVars[gvar_bucket] = NewGVarBucket();
           ExprGVars[gvar_bucket] = NewGVarBucket();
           CopiesGVars[gvar_bucket] = NewGVarBucket();
           FopiesGVars[gvar_bucket] = NewGVarBucket();
        }
#else
        GROW_PLIST(    ValGVars,    numGVars );
        SET_LEN_PLIST( ValGVars,    numGVars );
        GROW_PLIST(    NameGVars,   numGVars );
        SET_LEN_PLIST( NameGVars,   numGVars );
        GROW_PLIST(FlagsGVars, numGVars);
        SET_LEN_PLIST(FlagsGVars, numGVars);
        GROW_PLIST(    ExprGVars,   numGVars );
        SET_LEN_PLIST( ExprGVars,   numGVars );
        GROW_PLIST(    CopiesGVars, numGVars );
        SET_LEN_PLIST( CopiesGVars, numGVars );
        GROW_PLIST(    FopiesGVars, numGVars );
        SET_LEN_PLIST( FopiesGVars, numGVars );
        PtrGVars = ADDR_OBJ( ValGVars );
#endif
        SET_ELM_GVAR_LIST( ValGVars,    numGVars, 0 );
        SET_ELM_GVAR_LIST( NameGVars,   numGVars, string );
        CHANGED_GVAR_LIST( NameGVars,   numGVars );
        InitGVarFlagInfo( numGVars );
        SET_ELM_GVAR_LIST( ExprGVars,   numGVars, 0 );
        SET_ELM_GVAR_LIST( CopiesGVars, numGVars, 0 );
        SET_ELM_GVAR_LIST( FopiesGVars, numGVars, 0 );

        /* if the table is too crowded, make a larger one, rehash the names     */
        if ( sizeGVars < 3 * numGVars / 2 ) {
            table = TableGVars;
            sizeGVars = 2 * sizeGVars + 1;
            TableGVars = NEW_PLIST( T_PLIST, sizeGVars );
            SET_LEN_PLIST( TableGVars, sizeGVars );
#ifdef HPCGAP
            MakeBagPublic(TableGVars);
#endif
            for ( i = 1; i <= (sizeGVars-1)/2; i++ ) {
                gvar2 = ELM_PLIST( table, i );
                if ( gvar2 == 0 )  continue;
                pos = HashString( CONST_CSTR_STRING( NameGVar( INT_INTOBJ(gvar2) ) ) );
                pos = (pos % sizeGVars) + 1;
                while ( ELM_PLIST( TableGVars, pos ) != 0 ) {
                    pos = (pos % sizeGVars) + 1;
                }
                SET_ELM_PLIST( TableGVars, pos, gvar2 );
            }
        }
    }

#ifdef HPCGAP
    UnlockGVars();
#endif

    /* return the global variable                                          */
    return INT_INTOBJ(gvar);
}


/****************************************************************************
**
*F  MakeReadOnlyGVar( <gvar> )  . . . . . .  make a global variable read only
*/
void MakeReadOnlyGVar (
    UInt                gvar )
{
    if (IsConstantGVar(gvar)) {
        ErrorMayQuit("Variable: '%g' is constant", (Int)NameGVar(gvar), 0);
    }
    SetGVarWriteState(gvar, GVarReadOnly);
}

/****************************************************************************
**
*F  MakeConstantGVar( <gvar> )  . . . . . .  make a global variable constant
*/
void MakeConstantGVar(UInt gvar)
{
    SetGVarWriteState(gvar, GVarConstant);
}


/****************************************************************************
**
*F  MakeThreadLocalVar( <gvar> )  . . . . . .  make a variable thread-local
*/
#ifdef HPCGAP
void MakeThreadLocalVar (
    UInt                gvar,
    UInt                rnam )
{       
    Obj value = ValGVar(gvar);
    VAL_GVAR_INTERN(gvar) = (Obj) 0;
    if (IS_INTOBJ(ExprGVar(gvar)))
       value = (Obj) 0;
    SET_ELM_GVAR_LIST( ExprGVars, gvar, INTOBJ_INT(rnam) );
    SetHasExprCopiesFopies(gvar, 1);
    CHANGED_GVAR_LIST( ExprGVars, gvar );
    if (value && TLVars)
        SetTLDefault(TLVars, rnam, value);
}
#endif


/****************************************************************************
**
*F  FuncDeclareGlobalName(<self>,<name>)
*/
Obj FuncDeclareGlobalName(Obj self, Obj name)
{
    RequireStringRep("DeclareGlobalName", name);
    SetIsDeclaredName(GVarName(CONST_CSTR_STRING(name)), 1);
    return 0;
}


/****************************************************************************
**
*F  FuncMakeReadOnlyGVar(<self>,<name>)   make a global variable read only
**
**  'FuncMakeReadOnlyGVar' implements the function 'MakeReadOnlyGVar'.
**
**  'MakeReadOnlyGVar( <name> )'
**
**  'MakeReadOnlyGVar' make the global  variable with the name <name>  (which
**  must be a GAP string) read only.
*/
static Obj FuncMakeReadOnlyGVar(Obj self, Obj name)
{
    RequireStringRep(SELF_NAME, name);
    MakeReadOnlyGVar(GVarName(CONST_CSTR_STRING(name)));
    return 0;
}

/****************************************************************************
**
*F  FuncMakeConstantGVar(<self>,<name>)   make a global variable constant
**
**  'FuncMakeConstantGVar' implements the function 'MakeConstantGVar'.
**
**  'MakeConstantGVar( <name> )'
**
**  'MakeConstantGVar' make the global  variable with the name <name>  (which
**  must be a GAP string) constant.
*/
static Obj FuncMakeConstantGVar(Obj self, Obj name)
{
    RequireStringRep(SELF_NAME, name);
    MakeConstantGVar(GVarName(CONST_CSTR_STRING(name)));
    return 0;
}

/****************************************************************************
**
*F  MakeReadWriteGVar( <gvar> ) . . . . . . make a global variable read write
*/
void MakeReadWriteGVar (
    UInt                gvar )
{
    if (IsConstantGVar(gvar)) {
        ErrorMayQuit("Variable: '%g' is constant", (Int)NameGVar(gvar), 0);
    }
    SetGVarWriteState(gvar, GVarAssignable);
}


/****************************************************************************
**
*F  FuncMakeReadWriteGVar(<self>,<name>) make a global variable read write
**
**  'FuncMakeReadWriteGVar' implements the function 'MakeReadWriteGVar'.
**
**  'MakeReadWriteGVar( <name> )'
**
**  'MakeReadWriteGVar' make the global  variable with the name <name>  (which
**  must be a GAP string) read and writable.
*/
static Obj FuncMakeReadWriteGVar(Obj self, Obj name)
{
    RequireStringRep(SELF_NAME, name);
    MakeReadWriteGVar(GVarName(CONST_CSTR_STRING(name)));
    return 0;
}

/****************************************************************************
**
*F  IsReadOnlyGVar( <gvar> ) . . . . . . return status of a global variable
*/
BOOL IsReadOnlyGVar(UInt gvar)
{
    return GetGVarFlagInfo(gvar).gvarWriteFlag == GVarReadOnly;
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
    RequireStringRep(SELF_NAME, name);
    return IsReadOnlyGVar(GVarName(CONST_CSTR_STRING(name))) ? True : False;
}

/****************************************************************************
**
*F  IsConstantGVar( <gvar> ) . . . . . . return if a variable is a constant
*/
BOOL IsConstantGVar(UInt gvar)
{
    return GetGVarFlagInfo(gvar).gvarWriteFlag == GVarConstant;
}

/****************************************************************************
**
*F  FuncIsConstantGVar( <name> ) . . .handler for GAP function
**
*/

static Obj FuncIsConstantGVar(Obj self, Obj name)
{
    RequireStringRep(SELF_NAME, name);
    return IsConstantGVar(GVarName(CONST_CSTR_STRING(name))) ? True : False;
}


/****************************************************************************
**
*F  FuncAUTO() . . . . . . . . . . . . .   make automatic global variables
**
**  'FuncAUTO' implements the internal function 'AUTO'.
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
static Obj FuncAUTO(Obj self, Obj args)
{
    Obj                 func;           /* the function to call            */
    Obj                 arg;            /* the argument to pass            */
    Obj                 list;           /* function and argument list      */
    Obj                 name;           /* one name (as a GAP string)      */
    UInt                gvar;           /* one global variable             */
    UInt                i;              /* loop variable                   */

    /* get and check the function                                          */
    func = ELM_LIST( args, 1 );
    RequireFunction(SELF_NAME, func);

    /* get the argument                                                    */
    arg = ELM_LIST( args, 2 );

    /* make the list of function and argument                              */
    list = NewPlistFromArgs(func, arg);

    /* make the global variables automatic                                 */
    for ( i = 3; i <= LEN_LIST(args); i++ ) {
        name = ELM_LIST( args, i );
        RequireStringRep(SELF_NAME, name);
        gvar = GVarName( CONST_CSTR_STRING(name) );
        SET_ELM_GVAR_LIST( ValGVars, gvar, 0 );
        SET_ELM_GVAR_LIST( ExprGVars, gvar, list );
        SetHasExprCopiesFopies(gvar, 1);
        CHANGED_GVAR_LIST( ExprGVars, gvar );
    }

    return 0;
}


/****************************************************************************
**
*F  iscomplete( <name>, <len> ) . . . . . . . .  find the completions of name
*F  completion( <name>, <len> ) . . . . . . . .  find the completions of name
*/
BOOL iscomplete_gvar(Char * name, UInt len)
{
    const Char *        curr;
    UInt                i, k;
    UInt                numGVars;

    numGVars = INT_INTOBJ(CountGVars);
    for ( i = 1; i <= numGVars; i++ ) {
        curr = CONST_CSTR_STRING( NameGVar( i ) );
        for ( k = 0; name[k] != 0 && curr[k] == name[k]; k++ ) ;
        if (k == len && curr[k] == '\0')
            return TRUE;
    }
    return FALSE;
}

UInt            completion_gvar (
    Char *              name,
    UInt                len )
{
    const Char *        curr;
    const Char *        next;
    UInt                i, k;
    UInt                numGVars;

    numGVars = INT_INTOBJ(CountGVars);
    next = 0;
    for ( i = 1; i <= numGVars; i++ ) {
        /* consider only variables which are currently bound for completion */
        if ( VAL_GVAR_INTERN( i ) || ELM_GVAR_LIST( ExprGVars, i )) {
            curr = CONST_CSTR_STRING( NameGVar( i ) );
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
static Obj FuncIDENTS_GVAR(Obj self)
{
    Obj                 copy;
    UInt                i;
    UInt                numGVars;
    Obj                 strcopy;

#ifdef HPCGAP
    LockGVars(0);
    numGVars = INT_INTOBJ(CountGVars);
    UnlockGVars();
#else
    numGVars = INT_INTOBJ(CountGVars);
#endif

    copy = NEW_PLIST_IMM( T_PLIST, numGVars );
    for ( i = 1;  i <= numGVars;  i++ ) {
        /* Copy the string here, because we do not want members of NameGVars
         * accessible to users, as these strings must not be changed */
        strcopy = CopyToStringRep( NameGVar( i ) );
        SET_ELM_PLIST( copy, i, strcopy );
        CHANGED_BAG( copy );
    }
    SET_LEN_PLIST( copy, numGVars );
    return copy;
}

static Obj FuncIDENTS_BOUND_GVARS(Obj self)
{
    Obj                 copy;
    UInt                i, j;
    UInt                numGVars;
    Obj                 strcopy;

#ifdef HPCGAP
    LockGVars(0);
    numGVars = INT_INTOBJ(CountGVars);
    UnlockGVars();
#else
    numGVars = INT_INTOBJ(CountGVars);
#endif

    copy = NEW_PLIST_IMM( T_PLIST, numGVars );
    for ( i = 1, j = 1;  i <= numGVars;  i++ ) {
        if ( VAL_GVAR_INTERN( i ) || ELM_GVAR_LIST( ExprGVars, i ) ) {
           /* Copy the string here, because we do not want members of
            * NameGVars accessible to users, as these strings must not be
            * changed */
           strcopy = CopyToStringRep( NameGVar( i ) );
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
static Obj FuncASS_GVAR(Obj self, Obj gvar, Obj val)
{
    RequireStringRep(SELF_NAME, gvar);
    AssGVar( GVarName( CONST_CSTR_STRING(gvar) ), val );
    return 0;
}


/****************************************************************************
**
*F  FuncISB_GVAR( <self>, <gvar> )  . . check assignment of a global variable
*/
static Obj FuncISB_GVAR(Obj self, Obj gvar)
{
    RequireStringRep(SELF_NAME, gvar);

    UInt gv = GVarName( CONST_CSTR_STRING(gvar) );
    if (VAL_GVAR_INTERN(gv))
      return True;
    Obj expr = ExprGVar(gv);
#ifdef HPCGAP
    if (expr && !IS_INTOBJ(expr)) /* auto gvar */
      return True;
    if (!expr || !TLVars)
      return False;
    return GetTLRecordField(TLVars, INT_INTOBJ(expr)) ? True : False;
#else
    return expr ? True : False;
#endif
}

/****************************************************************************
**
*F  FuncIS_AUTO_GVAR( <self>, <gvar> ) . . check if a global variable is auto
*/

static Obj FuncIS_AUTO_GVAR(Obj self, Obj gvar)
{
    RequireStringRep(SELF_NAME, gvar);
    Obj expr = ExprGVar(GVarName( CONST_CSTR_STRING(gvar) ) );
    return (expr && !IS_INTOBJ(expr)) ? True : False;
}


/****************************************************************************
**
*F  FuncVAL_GVAR( <self>, <gvar> )  . . contents of a global variable
*/

static Obj FuncVAL_GVAR(Obj self, Obj gvar)
{
    Obj val;

    RequireStringRep(SELF_NAME, gvar);

    val = ValAutoGVar( GVarName( CONST_CSTR_STRING(gvar) ) );

    if (val == 0)
        ErrorMayQuit("VAL_GVAR: No value bound to %g", (Int)gvar, 0);
    return val;
}

/****************************************************************************
**
*F  FuncUNB_GVAR( <self>, <gvar> )  . . unbind a global variable
*/

static Obj FuncUNB_GVAR(Obj self, Obj gvar)
{
    RequireStringRep(SELF_NAME, gvar);
    AssGVar( GVarName( CONST_CSTR_STRING(gvar) ), (Obj)0 );
    return 0;
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

enum {
    MAX_COPY_AND_FOPY_GVARS = 30000
};

static StructCopyGVar CopyAndFopyGVars[MAX_COPY_AND_FOPY_GVARS];
static Int NCopyAndFopyGVars = 0;


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
*/
void InitCopyGVar (
    const Char *        name ,
    Obj *               copy )
{
    /* make a record in the kernel for saving and loading                  */
#ifdef HPCGAP
    LockGVars(1);
#endif
    if ( NCopyAndFopyGVars >= MAX_COPY_AND_FOPY_GVARS ) {
#ifdef HPCGAP
        UnlockGVars();
#endif
        Panic("no room to record CopyGVar");
    }
    CopyAndFopyGVars[NCopyAndFopyGVars].copy = copy;
    CopyAndFopyGVars[NCopyAndFopyGVars].isFopy = 0;
    CopyAndFopyGVars[NCopyAndFopyGVars].name = name;
    NCopyAndFopyGVars++;
#ifdef HPCGAP
    UnlockGVars();
#endif
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
#ifdef HPCGAP
    LockGVars(1);
#endif
    if ( NCopyAndFopyGVars >= MAX_COPY_AND_FOPY_GVARS ) {
#ifdef HPCGAP
        UnlockGVars();
#endif
        Panic("no room to record FopyGVar");
    }
    CopyAndFopyGVars[NCopyAndFopyGVars].copy = copy;
    CopyAndFopyGVars[NCopyAndFopyGVars].isFopy = 1;
    CopyAndFopyGVars[NCopyAndFopyGVars].name = name;
    NCopyAndFopyGVars++;
#ifdef HPCGAP
    UnlockGVars();
#endif
}


/****************************************************************************
**
*F  UpdateCopyFopyInfo()  . . . . . . . . . .  convert kernel info into plist
*/
static Int NCopyAndFopyDone = 0;

#ifdef HPCGAP
static void DeclareAllGVars( void );
#endif

void UpdateCopyFopyInfo ( void )
{
    Obj                 cops;           /* copies list                     */
    UInt                gvar;
    const Char *        name;           /* name of the variable            */
    Obj *               copy;           /* address of the copy             */

#ifdef HPCGAP
    LockGVars(1);
#endif
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
#ifdef HPCGAP
                MakeBagPublic(cops);
#endif
                SET_ELM_GVAR_LIST( FopiesGVars, gvar, cops );
                SetHasExprCopiesFopies(gvar, 1);
                CHANGED_GVAR_LIST( FopiesGVars, gvar );
            }
        }
        else {
            cops = ELM_GVAR_LIST( CopiesGVars, gvar );
            if ( cops == 0 ) {
                cops = NEW_PLIST( T_PLIST, 0 );
#ifdef HPCGAP
                MakeBagPublic(cops);
#endif
                SET_ELM_GVAR_LIST( CopiesGVars, gvar, cops );
                SetHasExprCopiesFopies(gvar, 1);
                CHANGED_GVAR_LIST( CopiesGVars, gvar );
            }
        }

        // append the copy to the copies list
        // As C global variables are 4-byte aligned,
        // we shift them down to make it more likely they
        // will fit in an immediate integer.
        GAP_ASSERT(((UInt)copy & 3) == 0);
        PushPlist(cops, ObjInt_UInt((UInt)copy >> 2));

        /* now copy the value of <gvar> to <cvar>                          */
        Obj val = ValGVar(gvar);
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
#ifdef HPCGAP
    DeclareAllGVars();
    UnlockGVars();
#endif
}


/****************************************************************************
**
*F  RemoveCopyFopyInfo()  . . . remove the info about copies of gvars from ws
*/
static void RemoveCopyFopyInfo( void )
{
#ifdef HPCGAP
    LockGVars(1);
#endif

#ifdef USE_GVAR_BUCKETS
    UInt        i, k, l;

    for (k = 0; k < ARRAY_SIZE(CopiesGVars); ++k) {
        if (CopiesGVars[k] == 0)
            continue;
        l = LEN_PLIST(CopiesGVars[k]);
        for ( i = 1; i <= l; i++ )
            SET_ELM_PLIST( CopiesGVars[k], i, 0 );
    }

    for (k = 0; k < ARRAY_SIZE(FopiesGVars); ++k) {
        if (FopiesGVars[k] == 0)
            continue;
        l = LEN_PLIST(FopiesGVars[k]);
        for ( i = 1; i <= l; i++ )
            SET_ELM_PLIST( FopiesGVars[k], i, 0 );
    }

#else
    UInt        i, l;

    l = LEN_PLIST(CopiesGVars);
    for ( i = 1; i <= l; i++ )
        SET_ELM_GVAR_LIST( CopiesGVars, i, 0 );
    l = LEN_PLIST(FopiesGVars);
    for ( i = 1; i <= l; i++ )
        SET_ELM_GVAR_LIST( FopiesGVars, i, 0 );
#endif

    NCopyAndFopyDone = 0;

#ifdef HPCGAP
    UnlockGVars();
#endif
}


/****************************************************************************
**
*/
static void GVarsAfterCollectBags(void)
{
#ifdef USE_GVAR_BUCKETS
  for (int i = 0; i < GVAR_BUCKETS; i++) {
    if (ValGVars[i])
      PtrGVars[i] = ADDR_OBJ( ValGVars[i] ) + 1;
    else
      break;
  }
#else
  if (ValGVars)
    PtrGVars = ADDR_OBJ( ValGVars );
#endif
}


#ifdef HPCGAP

static GVarDescriptor * FirstDeclaredGVar;
static GVarDescriptor * LastDeclaredGVar;

/****************************************************************************
**
*F  DeclareGVar(<gvar>, <name>) . . . . . .  declare global variable by name
*F  GVarValue(<gvar>) . . . . . . . . . return value of <gvar>, 0 if unbound
*F  GVarObj(<gvar>) . . . . . . . . return value of <gvar>, error if unbound
*F  GVarFunction(<gvar>) . . return value of <gvar>, error if not a function
*F  GVarOptFunction(<gvar>) return value of <gvar>, 0 if unbound/no function
*F  SetGVar(<gvar>, <obj>) . . . . . . . . . . . . .  assign <obj> to <gvar>
*/

void DeclareGVar(GVarDescriptor *gvar, const char *name)
{
  gvar->ref = NULL;
  gvar->name = name;
  gvar->next = NULL;
  if (LastDeclaredGVar) {
    LastDeclaredGVar->next = gvar;
    LastDeclaredGVar = gvar;
  } else {
    FirstDeclaredGVar = gvar;
    LastDeclaredGVar = gvar;
  }
}

static void DeclareAllGVars( void )
{
  GVarDescriptor *gvar;
  for (gvar = FirstDeclaredGVar; gvar; gvar = gvar->next) {
    UInt index = GVarName(gvar->name);
    gvar->ref = &(VAL_GVAR_INTERN(index));
  }
  FirstDeclaredGVar = LastDeclaredGVar = 0;
}

Obj GVarValue(GVarDescriptor *gvar)
{
  Obj result = *(gvar->ref);
  MEMBAR_READ();
  return result;
}

Obj GVarObj(GVarDescriptor *gvar)
{
  Obj result = *(gvar->ref);
  if (!result)
    ErrorQuit("Global variable '%s' not initialized", (UInt)(gvar->name), 0);
  MEMBAR_READ();
  return result;
}

Obj GVarFunction(GVarDescriptor *gvar)
{
  Obj result = *(gvar->ref);
  if (!result)
    ErrorQuit("Global variable '%s' not initialized", (UInt)(gvar->name), 0);
  if (REGION(result))
    ErrorQuit("Global variable '%s' is not a function", (UInt)(gvar->name), 0);
  ImpliedWriteGuard(result);
  if (TNUM_OBJ(result) != T_FUNCTION)
    ErrorQuit("Global variable '%s' is not a function", (UInt)(gvar->name), 0);
  MEMBAR_READ();
  return result;
}

Obj GVarOptFunction(GVarDescriptor *gvar)
{
  Obj result = *(gvar->ref);
  if (!result)
    return (Obj) 0;
  if (REGION(result))
    return (Obj) 0;
  ImpliedWriteGuard(result);
  if (TNUM_OBJ(result) != T_FUNCTION)
    return (Obj) 0;
  MEMBAR_READ();
  return result;
}

void SetGVar(GVarDescriptor *gvar, Obj obj)
{
  MEMBAR_WRITE();
  *(gvar->ref) = obj;
}

#endif


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_1ARGS(MakeReadOnlyGVar, name),
    GVAR_FUNC_1ARGS(MakeReadWriteGVar, name),
    GVAR_FUNC_1ARGS(MakeConstantGVar, name),
    GVAR_FUNC_1ARGS(IsReadOnlyGVar, name),
    GVAR_FUNC_1ARGS(IsConstantGVar, name),
    GVAR_FUNC(AUTO, -3, "func, arg, names..."),

    GVAR_FUNC_1ARGS(DeclareGlobalName, name),

    GVAR_FUNC_0ARGS(IDENTS_GVAR),
    GVAR_FUNC_0ARGS(IDENTS_BOUND_GVARS),
    GVAR_FUNC_1ARGS(ISB_GVAR, gvar),
    GVAR_FUNC_1ARGS(IS_AUTO_GVAR, gvar),
    GVAR_FUNC_2ARGS(ASS_GVAR, gvar, value),
    GVAR_FUNC_1ARGS(VAL_GVAR, gvar),
    GVAR_FUNC_1ARGS(UNB_GVAR, gvar),
    GVAR_FUNC_1ARGS(SET_NAMESPACE, str),
    GVAR_FUNC_0ARGS(GET_NAMESPACE),
#ifdef HPCGAP
    GVAR_FUNC_1ARGS(IsThreadLocalGVar, name),
#endif

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* init global bags and handler                                        */
    InitGlobalBag( &ErrorMustEvalToFuncFunc,
                   "src/gvars.c:ErrorMustEvalToFuncFunc" );
    InitGlobalBag( &ErrorMustHaveAssObjFunc,
                   "src/gvars.c:ErrorMustHaveAssObjFunc" );
#ifdef USE_GVAR_BUCKETS
    int i;
    static char cookies[6][GVAR_BUCKETS][10];

    for (i=0; i<GVAR_BUCKETS; i++) {
      sprintf((cookies[0][i]), "Vgv%d", i);
      sprintf((cookies[1][i]), "Ngv%d", i);
      sprintf((cookies[2][i]), "Wgv%d", i);
      sprintf((cookies[3][i]), "Egv%d", i);
      sprintf((cookies[4][i]), "Cgv%d", i);
      sprintf((cookies[5][i]), "Fgv%d", i);
      InitGlobalBag( ValGVars+i, (cookies[0][i]) );
      InitGlobalBag( NameGVars+i, (cookies[1][i]) );
      InitGlobalBag(FlagsGVars + i, (cookies[2][i]));
      InitGlobalBag( ExprGVars+i, (cookies[3][i]) );
      InitGlobalBag( CopiesGVars+i, (cookies[4][i]) );
      InitGlobalBag( FopiesGVars+i, (cookies[5][i])  );
    }
#else
    InitGlobalBag( &ValGVars,
                   "src/gvars.c:ValGVars" );
    InitGlobalBag( &NameGVars,
                   "src/gvars.c:NameGVars" );
    InitGlobalBag(&FlagsGVars, "src/gvars.c:FlagsGVars");
    InitGlobalBag( &ExprGVars,
                   "src/gvars.c:ExprGVars" );
    InitGlobalBag( &CopiesGVars,
                   "src/gvars.c:CopiesGVars" );
    InitGlobalBag( &FopiesGVars,
                   "src/gvars.c:FopiesGVars"  );
#endif

    InitGlobalBag( &STATE(CurrNamespace),
                   "src/gvars.c:CurrNamespace" );

    CountGVars = INTOBJ_INT(0);
    InitGlobalBag( &CountGVars,
                   "src/gvars.c:CountGVars" );

    InitGlobalBag( &TableGVars,
                   "src/gvars.c:TableGVars" );

    InitHandlerFunc( ErrorMustEvalToFuncHandler,
                     "src/gvars.c:ErrorMustEvalToFuncHandler" );
    InitHandlerFunc( ErrorMustHaveAssObjHandler,
                     "src/gvars.c:ErrorMustHaveAssObjHandler" );

#ifdef USE_GASMAN
    // install post-GC callback
    RegisterAfterCollectFuncBags(GVarsAfterCollectBags);
#endif

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

#ifdef HPCGAP
    /* For thread-local variables */
    InitCopyGVar("ThreadVar", &TLVars);
#endif

    /* Get a copy of REREADING                                             */
    ImportGVarFromLibrary("REREADING", &REREADING);
    
    
    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/

static Int PostRestore (
    StructInitInfo *    module )
{
    // restore PtrGVars
    GVarsAfterCollectBags();

    /* update fopies and copies                                            */
    UpdateCopyFopyInfo();

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
*F  PostSave( <module> ) . . . . . . . . . . . . . after save workspace
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
#ifdef HPCGAP
    /* Init lock */
    pthread_rwlock_init(&GVarLock, NULL);
#endif

    /* make the error functions for 'AssGVar'                              */
    ErrorMustEvalToFuncFunc = NewFunctionC(
        "ErrorMustEvalToFunc", -1, "args", ErrorMustEvalToFuncHandler);
    
    ErrorMustHaveAssObjFunc = NewFunctionC(
        "ErrorMustHaveAssObj", -1, "args", ErrorMustHaveAssObjHandler);

#if !defined(USE_GVAR_BUCKETS)
    /* make the lists for global variables                                 */
    ValGVars = NEW_PLIST( T_PLIST, 0 );
    NameGVars = NEW_PLIST( T_PLIST, 0 );
    FlagsGVars = NEW_PLIST(T_PLIST, 0);
    ExprGVars = NEW_PLIST( T_PLIST, 0 );
    CopiesGVars = NEW_PLIST( T_PLIST, 0 );
    FopiesGVars = NEW_PLIST( T_PLIST, 0 );
#endif

    /* make the list of global variables                                   */
    TableGVars = NEW_PLIST( T_PLIST, 14033 );
    SET_LEN_PLIST( TableGVars, 14033 );
#ifdef HPCGAP
    MakeBagPublic(TableGVars);
#endif

    /* fix C vars                                                          */
    PostRestore( module );

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

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
        Pr("#W  failed to updated copies and fopies\n", 0, 0);
    }

    return ! success;
}


static Int InitModuleState(void)
{
    /* Create the current namespace: */
    STATE(CurrNamespace) = NEW_STRING(0);
    SET_LEN_STRING(STATE(CurrNamespace), 0);

    return 0;
}


/****************************************************************************
**
*F  InitInfoGVars() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "gvars",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .checkInit = CheckInit,
    .preSave = PreSave,
    .postSave = PostSave,
    .postRestore = PostRestore,
    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoGVars ( void )
{
    return &module;
}
