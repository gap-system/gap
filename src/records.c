/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the generic record package.
**
**  This package  provides a uniform  interface to  the functions that access
**  records and the elements for the other packages in the GAP kernel.
*/

#include "records.h"

#include "bool.h"
#include "error.h"
#include "gaputils.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "stringobj.h"

#ifdef HPCGAP
#include "hpc/thread.h"
#include <pthread.h>
#endif


static Obj HashRNam;

static Obj NamesRNam;

/****************************************************************************
**
*F  IS_VALID_RNAM(<rnam>) . . . . . . . . . . . . .  check if <rnam> is valid
**
**  'IS_VALID_RNAM' returns if <rnam> is a valid record name.
*/
static BOOL IS_VALID_RNAM(UInt rnam)
{
    return rnam != 0 && rnam <= LEN_PLIST(NamesRNam);
}

extern inline Obj NAME_RNAM(UInt rnam)
{
    return ELM_PLIST(NamesRNam, rnam);
}


#ifdef HPCGAP

/****************************************************************************
**
*F  RNameLock . . . . . . . . . . . . . . . . . . . . .  lock for name table
**
**  'CountRnam' is the number of record names.
*/
static pthread_rwlock_t RNameLock;

static void HPC_LockNames(int write)
{
  if (PreThreadCreation)
    return;
  if (write)
    pthread_rwlock_wrlock(&RNameLock);
  else
    pthread_rwlock_rdlock(&RNameLock);
}

static void HPC_UnlockNames(void)
{
  if (!PreThreadCreation)
    pthread_rwlock_unlock(&RNameLock);
}

#endif


static inline UInt HashString( const Char * name, UInt len )
{
    UInt hash = 0;
    while ( len-- > 0 ) {
        hash = 65599 * hash + *name++;
    }
    return hash;
}

static inline int EqString(Obj str, const Char * name, UInt len)
{
    if (GET_LEN_STRING(str) != len)
        return 0;
    return memcmp(CONST_CSTR_STRING(str), name, len) == 0;
}

/****************************************************************************
**
*F  RNamName(<name>)  . . . . . . . . . . . . convert a name to a record name
**
**  'RNamName' returns  the record name with the  name  <name> (which is  a C
**  string).
*/
UInt            RNamName (
    const Char *        name )
{
    return RNamNameWithLen(name, strlen(name));
}

UInt RNamNameWithLen(const Char * name, UInt len)
{
    Obj                 rnam;           /* record name (as imm intobj)     */
    UInt                pos;            /* hash position                   */
    Char                namx [1024];    /* temporary copy of <name>        */
    Obj                 string;         /* temporary string object <name>  */
    Obj                 table;          /* temporary copy of <HashRNam>    */
    Obj                 rnam2;          /* one element of <table>          */
    UInt                i;              /* loop variable                   */
    UInt                sizeRNam;

    if (len > 1023) {
        // Note: We can't pass 'name' here, as it might get moved by garbage collection
        ErrorQuit("Record names must consist of at most 1023 characters", 0, 0);
    }

    /* start looking in the table at the following hash position           */
    const UInt hash = HashString( name, len );

#ifdef HPCGAP
    HPC_LockNames(0); /* try a read lock first */
#endif

    /* look through the table until we find a free slot or the global      */
    sizeRNam = LEN_PLIST(HashRNam);
    pos = (hash % sizeRNam) + 1;
    while ( (rnam = ELM_PLIST( HashRNam, pos )) != 0
         && !EqString( NAME_RNAM( INT_INTOBJ(rnam) ), name, len ) ) {
        pos = (pos % sizeRNam) + 1;
    }
    if (rnam != 0) {
#ifdef HPCGAP
      HPC_UnlockNames();
#endif
      return INT_INTOBJ(rnam);
    }
#ifdef HPCGAP
    if (!PreThreadCreation) {
      HPC_UnlockNames(); /* switch to a write lock */
      HPC_LockNames(1);
      /* look through the table until we find a free slot or the global      */
      sizeRNam = LEN_PLIST(HashRNam);
      pos = (hash % sizeRNam) + 1;
      while ( (rnam = ELM_PLIST( HashRNam, pos )) != 0
           && !EqString( NAME_RNAM( INT_INTOBJ(rnam) ), name, len ) ) {
          pos = (pos % sizeRNam) + 1;
      }
    }
    if (rnam != 0) {
      HPC_UnlockNames();
      return INT_INTOBJ(rnam);
    }
#endif

    /* if we did not find the global variable, make a new one and enter it */
    /* (copy the name first, to avoid a stale pointer in case of a GC)     */
    memcpy( namx, name, len );
    namx[len] = 0;
    string = MakeImmString(namx);

    const UInt countRNam = PushPlist(NamesRNam, string);
    rnam = INTOBJ_INT(countRNam);
    SET_ELM_PLIST( HashRNam, pos, rnam );

    /* if the table is too crowded, make a larger one, rehash the names     */
    if ( sizeRNam < 3 * countRNam / 2 ) {
        table = HashRNam;
        sizeRNam = 2 * sizeRNam + 1;
        HashRNam = NEW_PLIST( T_PLIST, sizeRNam );
        SET_LEN_PLIST( HashRNam, sizeRNam );
#ifdef HPCGAP
        /* The list is briefly non-public, but this is safe, because
         * the mutex protects it from being accessed by other threads.
         */
        MakeBagPublic(HashRNam);
#endif
        for ( i = 1; i <= (sizeRNam-1)/2; i++ ) {
            rnam2 = ELM_PLIST( table, i );
            if ( rnam2 == 0 )  continue;
            string = NAME_RNAM( INT_INTOBJ(rnam2) );
            pos = HashString( CONST_CSTR_STRING( string ), GET_LEN_STRING( string) );
            pos = (pos % sizeRNam) + 1;
            while ( ELM_PLIST( HashRNam, pos ) != 0 ) {
                pos = (pos % sizeRNam) + 1;
            }
            SET_ELM_PLIST( HashRNam, pos, rnam2 );
        }
    }
#ifdef HPCGAP
    HPC_UnlockNames();
#endif

    /* return the record name                                              */
    return INT_INTOBJ(rnam);
}


/****************************************************************************
**
*F  RNamIntg(<intg>)  . . . . . . . . . . convert an integer to a record name
**
**  'RNamIntg' returns the record name corresponding to the integer <intg>.
*/
UInt            RNamIntg (
    Int                 intg )
{
    Char                name [32];      /* integer converted to a string   */
    Char *              p;              /* loop variable                   */
    UInt negative;

    /* convert the integer to a string                                     */
    p = name + sizeof(name);  *--p = '\0';
    negative = (intg < 0);
    if ( negative ) {
        intg = -intg;
    }
   
    do {
        *--p = '0' + intg % 10;
    } while ( (intg /= 10) != 0 );
    if( negative ) {
        *--p = '-';
    }

    /* return the name                                                     */
    return RNamName( p );
}


/****************************************************************************
**
*F  RNamObj(<obj>)  . . . . . . . . . . .  convert an object to a record name
**
**  'RNamObj' returns the record name  corresponding  to  the  object  <obj>,
**  which currently must be a string or an integer.
*/
UInt            RNamObj (
    Obj                 obj )
{
    /* convert integer object                                              */
    if ( IS_INTOBJ(obj) ) {
        return RNamIntg( INT_INTOBJ(obj) );
    }

    /* convert string object (empty string may have type T_PLIST)          */
    else if ( IsStringConv(obj) && IS_STRING_REP(obj) ) {
        return RNamName( CONST_CSTR_STRING(obj) );
    }

    /* otherwise fail                                                      */
    else {
        RequireArgumentEx("Record", obj, 0, "'<rec>.(<obj>)' <obj> must be a string or a small integer");
    }
}


/****************************************************************************
**
*F  FuncRNamObj(<self>,<obj>)  . . . .  convert an object to a record name
**
**  'FuncRNamObj' implements the internal function 'RNamObj'.
**
**  'RNamObj( <obj> )'
**
**  'RNamObj' returns the record name  corresponding  to  the  object  <obj>,
**  which currently must be a string or an integer.
*/
static Obj FuncRNamObj(Obj self, Obj obj)
{
    return INTOBJ_INT( RNamObj( obj ) );
}


/****************************************************************************
**
*F  GetValidRNam( <funcname>, <rnam> ) . check if <rnam> is a valid prec rnam
*/
UInt GetValidRNam(const char * funcname, Obj rnam)
{
    UInt val = GetPositiveSmallInt(funcname, rnam);
    RequireArgumentCondition(funcname, rnam, IS_VALID_RNAM(val),
                             "must be a valid rnam");
    return val;
}


/****************************************************************************
**
*F  FuncNameRNam(<self>,<rnam>)  . . . . convert a record name to a string
**
**  'FuncNameRNam' implements the internal function 'NameRNam'.
**
**  'NameRNam( <rnam> )'
**
**  'NameRNam' returns the string corresponding to the record name <rnam>.
*/
static Obj FuncNameRNam(Obj self, Obj rnam)
{
    Int inam = GetValidRNam("NameRNam", rnam);
    Obj oname = NAME_RNAM(inam);
    return CopyToStringRep(oname);
}


/****************************************************************************
**
*F  IS_REC(<obj>) . . . . . . . . . . . . . . . . . . . is an object a record
*V  IsRecFuncs[<type>]  . . . . . . . . . . . . . . . . table of record tests
**
**  'IS_REC' returns a nonzero value if the object <obj> is a  record  and  0
**  otherwise.
*/
BOOL (*IsRecFuncs[LAST_REAL_TNUM + 1])(Obj obj);

static Obj IsRecFilt;

static Obj FiltIS_REC(Obj self, Obj obj)
{
    return (IS_REC(obj) ? True : False);
}

static BOOL IsRecObject(Obj obj)
{
    return (DoFilter( IsRecFilt, obj ) == True);
}


/****************************************************************************
**
*F  ELM_REC(<rec>,<rnam>) . . . . . . . . . . select an element from a record
**
**  'ELM_REC' returns the element, i.e., the value of the component, with the
**  record name <rnam> in  the record <rec>.   An error is signalled if <rec>
**  is not a record or if <rec> has no component with the record name <rnam>.
*/
Obj             (*ElmRecFuncs[LAST_REAL_TNUM+1]) ( Obj rec, UInt rnam );

static Obj ElmRecOper;

static Obj ElmRecHandler(Obj self, Obj rec, Obj rnam)
{
    return ELM_REC(rec, GetValidRNam("Record Element", rnam));
}

static Obj ElmRecError(Obj rec, UInt rnam)
{
    RequireArgument("Record Element", rec, "must be a record");
}

static Obj ElmRecObject(Obj obj, UInt rnam)
{
  Obj elm;
  elm = DoOperation2Args( ElmRecOper, obj, INTOBJ_INT(rnam) );
  if (elm == 0)
      ErrorMayQuit("Record access method must return a value", 0, 0);
  return elm;

}


/****************************************************************************
**
*F  ISB_REC(<rec>,<rnam>) . . . . . . . . . test for an element from a record
**
**  'ISB_REC' returns 1 if the record <rec> has a component with  the  record
**  name <rnam> and 0 otherwise.  An error is signalled if  <rec>  is  not  a
**  record.
*/
BOOL (*IsbRecFuncs[LAST_REAL_TNUM + 1])(Obj rec, UInt rnam);

static Obj IsbRecOper;

static Obj IsbRecHandler(Obj self, Obj rec, Obj rnam)
{
    return (ISB_REC(rec, GetValidRNam("Record IsBound", rnam)) ? True
                                                               : False);
}

static BOOL IsbRecError(Obj rec, UInt rnam)
{
    RequireArgument("Record IsBound", rec, "must be a record");
}

static BOOL IsbRecObject(Obj obj, UInt rnam)
{
    return (DoOperation2Args( IsbRecOper, obj, INTOBJ_INT(rnam) ) == True);
}


/****************************************************************************
**
*F  ASS_REC(<rec>,<rnam>,<obj>) . . . . . . . . . . . . .  assign to a record
**
**  'ASS_REC' assigns the object <obj>  to  the  record  component  with  the
**  record name <rnam> in the record <rec>.  An error is signalled  if  <rec>
**  is not a record.
*/
void            (*AssRecFuncs[LAST_REAL_TNUM+1]) ( Obj rec, UInt rnam, Obj obj );

static Obj AssRecOper;

static Obj AssRecHandler(Obj self, Obj rec, Obj rnam, Obj obj)
{
    ASS_REC(rec, GetValidRNam("Record Assignment", rnam), obj);
    return 0;
}

static void AssRecError(Obj rec, UInt rnam, Obj obj)
{
    RequireArgument("Record Assignment", rec, "must be a record");
}

static void AssRecObject(Obj obj, UInt rnam, Obj val)
{
    DoOperation3Args( AssRecOper, obj, INTOBJ_INT(rnam), val );
}


/****************************************************************************
**
*F  UNB_REC(<rec>,<rnam>) . . . . . . unbind a record component from a record
**
**  'UNB_REC' removes the record component  with the record name <rnam>  from
**  the record <rec>.
*/
void            (*UnbRecFuncs[LAST_REAL_TNUM+1]) ( Obj rec, UInt rnam );

static Obj UnbRecOper;

static Obj UnbRecHandler(Obj self, Obj rec, Obj rnam)
{
    UNB_REC(rec, GetValidRNam("Record Unbind", rnam));
    return 0;
}

static void UnbRecError(Obj rec, UInt rnam)
{
    RequireArgument("Record Unbind", rec, "must be a record");
}

static void UnbRecObject(Obj obj, UInt rnam)
{
    DoOperation2Args( UnbRecOper, obj, INTOBJ_INT(rnam) );
}


/****************************************************************************
**
*F  iscomplete( <name>, <len> ) . . . . . . . .  find the completions of name
*F  completion( <name>, <len> ) . . . . . . . .  find the completions of name
*/
BOOL iscomplete_rnam(Char * name, UInt len)
{
    const Char *        curr;
    UInt                i, k;
    const UInt          countRNam = LEN_PLIST(NamesRNam);

    for ( i = 1; i <= countRNam; i++ ) {
        curr = CONST_CSTR_STRING( NAME_RNAM( i ) );
        for ( k = 0; name[k] != 0 && curr[k] == name[k]; k++ ) ;
        if (k == len && curr[k] == '\0')
            return TRUE;
    }
    return FALSE;
}

UInt            completion_rnam (
    Char *              name,
    UInt                len )
{
    const Char *        curr;
    const Char *        next;
    UInt                i, k;
    const UInt          countRNam = LEN_PLIST(NamesRNam);

    next = 0;
    for ( i = 1; i <= countRNam; i++ ) {
        curr = CONST_CSTR_STRING( NAME_RNAM( i ) );
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

static Obj FuncALL_RNAMES(Obj self)
{
    Obj                 copy, s;
    UInt                i;
    Obj                 name;
    const UInt          countRNam = LEN_PLIST(NamesRNam);

    copy = NEW_PLIST_IMM( T_PLIST, countRNam );
    for ( i = 1;  i <= countRNam;  i++ ) {
        name = NAME_RNAM( i );
        s = CopyToStringRep(name);
        SET_ELM_PLIST( copy, i, s );
    }
    SET_LEN_PLIST( copy, countRNam );
    return copy;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_REC, "obj", &IsRecFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    { "ELM_REC",  2, "obj, rnam", &ElmRecOper, 
      ElmRecHandler, "src/records.c:ELM_REC" },

    { "ISB_REC",  2, "obj, rnam", &IsbRecOper, 
      IsbRecHandler, "src/records.c:ISB_REC" },

    { "ASS_REC",  3, "obj, rnam, val", &AssRecOper, 
      AssRecHandler, "src/records.c:ASS_REC" },

    { "UNB_REC",  2, "obj, rnam", &UnbRecOper, 
      UnbRecHandler, "src/records.c:UNB_REC" },

    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(RNamObj, obj),
    GVAR_FUNC_1ARGS(NameRNam, rnam),
    GVAR_FUNC_0ARGS(ALL_RNAMES),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                type;           /* loop variable                   */

    /* make the list of names of record names                              */
    InitGlobalBag( &NamesRNam, "src/records.c:NamesRNam" );

    /* make the hash list of record names                                  */
    InitGlobalBag( &HashRNam, "src/records.c:HashRNam" );

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrOpersFromTable( GVarOpers );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* make and install the 'IS_REC' filter                                */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(IsRecFuncs[ type ] == 0);
        IsRecFuncs[ type ] = AlwaysNo;
    }
    for ( type = FIRST_RECORD_TNUM; type <= LAST_RECORD_TNUM; type++ ) {
        IsRecFuncs[ type ] = AlwaysYes;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsRecFuncs[ type ] = IsRecObject;
    }


    /* make and install the 'ELM_REC' operations                           */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(ElmRecFuncs[ type ] == 0);
        ElmRecFuncs[ type ] = ElmRecError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        ElmRecFuncs[ type ] = ElmRecObject;
    }


    /* make and install the 'ISB_REC' operation                            */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(IsbRecFuncs[ type ] == 0);
        IsbRecFuncs[ type ] = IsbRecError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsbRecFuncs[ type ] = IsbRecObject;
    }


    /* make and install the 'ASS_REC' operation                            */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(AssRecFuncs[ type ] == 0);
        AssRecFuncs[ type ] = AssRecError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        AssRecFuncs[ type ] = AssRecObject;
    }


    /* make and install the 'UNB_REC' operation                            */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(UnbRecFuncs[ type ] == 0);
        UnbRecFuncs[ type ] = UnbRecError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        UnbRecFuncs[ type ] = UnbRecObject;
    }

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* make the list of names of record names                              */
    NamesRNam = NEW_PLIST( T_PLIST, 0 );
#ifdef HPCGAP
    MakeBagPublic(NamesRNam);
#endif

    /* make the hash list of record names                                  */
    HashRNam = NEW_PLIST( T_PLIST, 14033 );
    SET_LEN_PLIST( HashRNam, 14033 );
#ifdef HPCGAP
    MakeBagPublic(HashRNam);
#endif

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarOpersFromTable( GVarOpers );
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  InitInfoRecords() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "records",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoRecords ( void )
{
    return &module;
}
