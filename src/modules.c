/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file implements APIs for GAP modules, including builtin modules,
**  or static and dynamic modules used by packages and end users to provide
**  kernel extensions.
*/

#include "modules.h"

#include "ariths.h"
#include "bool.h"
#include "code.h"
#include "compstat.h"
#include "error.h"
#include "funcs.h"
#include "gap.h"
#include "gapstate.h"
#include "gvars.h"
#include "integer.h"
#include "intobj.h"
#include "io.h"
#include "lists.h"
#include "modules_builtin.h"
#include "opers.h"
#include "plist.h"
#include "saveload.h"
#include "streams.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "sysopt.h"
#include "sysstr.h"
#include "vars.h"

#include "config.h"

#ifdef HAVE_DLOPEN
#include <dlfcn.h>
#endif

#include <stdio.h>


/****************************************************************************
**
*F  Modules . . . . . . . . . . . . . . . . . . . . . . . . . list of modules
*/
#ifndef MAX_MODULES
#define MAX_MODULES 1000
#endif


#ifndef MAX_MODULE_FILENAMES
#define MAX_MODULE_FILENAMES (MAX_MODULES * 50)
#endif

static Char   LoadedModuleFilenames[MAX_MODULE_FILENAMES];
static Char * NextLoadedModuleFilename = LoadedModuleFilenames;

typedef struct {

    // pointer to the actual StructInitInfo
    StructInitInfo * info;

    // filename relative to GAP_ROOT or absolute
    Char * filename;

    // true if the filename is GAP_ROOT relative
    Int isGapRootRelative;

} StructInitInfoExt;


static StructInitInfoExt Modules[MAX_MODULES];
static UInt       NrModules;
static UInt       NrBuiltinModules;


typedef struct {
    const Char * name;
    Obj *        address;
} StructImportedGVars;

#ifndef MAX_IMPORTED_GVARS
#define MAX_IMPORTED_GVARS 1024
#endif

static StructImportedGVars ImportedGVars[MAX_IMPORTED_GVARS];
static Int                 NrImportedGVars;

static StructImportedGVars ImportedFuncs[MAX_IMPORTED_GVARS];
static Int                 NrImportedFuncs;

static Int StateNextFreeOffset = 0; // Start of next free memory area (as offset into GAPState.StateSlots)

static void RegisterModuleState(StructInitInfo * info)
{
    UInt size = info->moduleStateSize;
    if (size == 0)
        return;

    if (SyDebugLoading) {
        fprintf(stderr, "#I    module '%s' reserved %d bytes module state\n", info->name, (int)size);
    }

    // using moduleStateSize without moduleStateOffsetPtr makes no sense
    GAP_ASSERT(info->moduleStateOffsetPtr);

    // check that we have enough free space
    assert((STATE_SLOTS_SIZE - StateNextFreeOffset) >= size);

    // record start offset of this module's state
    *info->moduleStateOffsetPtr = StateNextFreeOffset;

    // ... and 'allocate' the requested amount of storage
    StateNextFreeOffset += size;
    StateNextFreeOffset = (StateNextFreeOffset + sizeof(Obj)-1) & ~(sizeof(Obj)-1);
}


/*************************************************************************
**
*F * * * * * * * * * functions for dynamical/static modules * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncGAP_CRC( <self>, <name> ) . . . . . . . create a crc value for a file
*/
static Obj FuncGAP_CRC(Obj self, Obj filename)
{
    RequireStringRep(SELF_NAME, filename);
    return ObjInt_Int(SyGAPCRC(CONST_CSTR_STRING(filename)));
}


/****************************************************************************
**
*F  ActivateModule( <info> )
*/
Int ActivateModule(StructInitInfo * info)
{
    Int res = 0;

    RegisterModuleState(info);

    if (info->initKernel) {
        res = info->initKernel(info);
    }

    int flag = 0;
#ifdef GAP_ENABLE_SAVELOAD
    flag = SyRestoring != 0;
#endif
    if (!flag) {
        UpdateCopyFopyInfo();

        if (info->initLibrary) {
            // Start a new executor to run the outer function of the module in
            // global context
            Bag oldLvars = SWITCH_TO_BOTTOM_LVARS();
            res = res || info->initLibrary(info);
            SWITCH_TO_OLD_LVARS(oldLvars);
        }
    }

    if (res) {
        Pr("#W  init functions returned non-zero exit code\n", 0, 0);
    }

    if (info->initModuleState)
        res = res || (info->initModuleState)();

    return res;
}


/****************************************************************************
**
*F  LookupStaticModule(<name>)
*/
StructInitInfo * LookupStaticModule(const char * name)
{
    for (int k = 0; CompInitFuncs[k]; k++) {
        StructInitInfo * info = (*(CompInitFuncs[k]))();
        if (info && streq(name, info->name)) {
            return info;
        }
    }
    return 0;
}


/****************************************************************************
**
*F  SyLoadModule( <name>, <func> )  . . . . . . . . .  load a compiled module
**
**  This function attempts to load a compiled module <name>.
**  If successful, it returns 0, and sets <func> to a pointer to the init
**  function of the module. In case of an error, <func> is set to 0, and the
**  return value is a pointer to a string with more information.
*/
#ifdef HAVE_DLOPEN
static const char * SyLoadModule(const Char * name, InitInfoFunc * func)
{
    void * handle = dlopen(name, RTLD_LAZY | RTLD_LOCAL);
    if (handle == 0) {
        *func = 0;
        return dlerror();
    }

    *func = (InitInfoFunc)dlsym(handle, "Init__Dynamic");
    if (*func == 0)
        return "symbol 'Init__Dynamic' not found";

    return 0;
}
#endif


/****************************************************************************
**
*F  FuncIS_LOADABLE_DYN( <self>, <name> ) . test if a dyn. module is loadable
*/
static Obj FuncIS_LOADABLE_DYN(Obj self, Obj filename)
{
    RequireStringRep(SELF_NAME, filename);

#if !defined(HAVE_DLOPEN)
    return False;
#else

    InitInfoFunc init;

    // try to load the module
    SyLoadModule(CONST_CSTR_STRING(filename), &init);
    if (init == 0)
        return False;

    // get the description structure
    StructInitInfo * info = (*init)();
    if (info == 0)
        return False;

    // info->type should not be larger than kernel version
    if (info->type / 10 > GAP_KERNEL_API_VERSION)
        return False;

    // info->type should not have an older major version
    if (info->type / 10000 < GAP_KERNEL_MAJOR_VERSION)
        return False;

    // info->type % 10 should be 0, 1 or 2, for the 3 types of module
    if (info->type % 10 > 2)
        return False;

    return True;
#endif
}


/****************************************************************************
**
*F  FuncLOAD_DYN( <self>, <name> ) . . . . . . . try to load a dynamic module
*/
static Obj FuncLOAD_DYN(Obj self, Obj filename)
{
    RequireStringRep(SELF_NAME, filename);

#if !defined(HAVE_DLOPEN)
    /* no dynamic library support                                          */
    if (SyDebugLoading) {
        Pr("#I  LOAD_DYN: no support for dynamical loading\n", 0, 0);
    }
    return False;
#else

    InitInfoFunc init;

    // try to read the module
    const char * res = SyLoadModule(CONST_CSTR_STRING(filename), &init);
    if (res)
        ErrorQuit("failed to load dynamic module %g, %s", (Int)filename, (Int)res);

    // get the description structure
    StructInitInfo * info = (*init)();
    if (info == 0)
        ErrorQuit("call to init function failed", 0, 0);

    // info->type should not be larger than kernel version
    if (info->type / 10 > GAP_KERNEL_API_VERSION)
        ErrorMayQuit("LOAD_DYN: kernel module built for newer "
                     "version of GAP",
                     0, 0);

    // info->type should not have an older major version
    if (info->type / 10000 < GAP_KERNEL_MAJOR_VERSION)
        ErrorMayQuit("LOAD_DYN: kernel module built for older "
                     "version of GAP",
                     0, 0);

    // info->type % 10 should be 0, 1 or 2, for the 3 types of module
    if (info->type % 10 > 2)
        ErrorMayQuit("LOAD_DYN: Invalid kernel module", 0, 0);

    ActivateModule(info);
    RecordLoadedModule(info, 0, CONST_CSTR_STRING(filename));

    return True;
#endif
}


/****************************************************************************
**
*F  FuncLOAD_STAT( <self>, <name> ) . . . . . . . try to load a static module
*/
static Obj FuncLOAD_STAT(Obj self, Obj filename)
{
    StructInitInfo * info = 0;

    RequireStringRep(SELF_NAME, filename);

    /* try to find the module                                              */
    info = LookupStaticModule(CONST_CSTR_STRING(filename));
    if (info == 0) {
        if (SyDebugLoading) {
            Pr("#I  LOAD_STAT: no module named '%g' found\n", (Int)filename,
               0);
        }
        return False;
    }

    ActivateModule(info);
    RecordLoadedModule(info, 0, CONST_CSTR_STRING(filename));

    return True;
}


/****************************************************************************
**
*F  FuncSHOW_STAT() . . . . . . . . . . . . . . . . . . . show static modules
*/
static Obj FuncSHOW_STAT(Obj self)
{
    Obj              modules;
    Obj              name;
    StructInitInfo * info;
    Int              k;
    Int              im;

    /* count the number of install modules                                 */
    for (k = 0, im = 0; CompInitFuncs[k]; k++) {
        info = (*(CompInitFuncs[k]))();
        if (info == 0) {
            continue;
        }
        im++;
    }

    /* make a list of modules with crc values                              */
    modules = NEW_PLIST(T_PLIST, 2 * im);

    for (k = 0; CompInitFuncs[k]; k++) {
        info = (*(CompInitFuncs[k]))();
        if (info == 0) {
            continue;
        }
        name = MakeImmString(info->name);

        PushPlist(modules, name);

        /* compute the crc value                                           */
        PushPlist(modules, ObjInt_Int(info->crc));
    }

    return modules;
}


/****************************************************************************
**
*F  FuncLoadedModules( <self> ) . . . . . . . . . . . list all loaded modules
*/
static Obj FuncLoadedModules(Obj self)
{
    Int              i;
    StructInitInfo * m;
    Obj              str;
    Obj              list;

    /* create a list                                                       */
    list = NEW_PLIST(T_PLIST, NrModules * 3);
    SET_LEN_PLIST(list, NrModules * 3);
    for (i = 0; i < NrModules; i++) {
        m = Modules[i].info;
        if (IS_MODULE_BUILTIN(m->type)) {
            SET_ELM_PLIST(list, 3 * i + 1, ObjsChar[(Int)'b']);
            CHANGED_BAG(list);
            str = MakeImmString(m->name);
            SET_ELM_PLIST(list, 3 * i + 2, str);
            SET_ELM_PLIST(list, 3 * i + 3, INTOBJ_INT(m->version));
        }
        else if (IS_MODULE_DYNAMIC(m->type)) {
            SET_ELM_PLIST(list, 3 * i + 1, ObjsChar[(Int)'d']);
            CHANGED_BAG(list);
            str = MakeImmString(m->name);
            SET_ELM_PLIST(list, 3 * i + 2, str);
            CHANGED_BAG(list);
            str = MakeImmString(Modules[i].filename);
            SET_ELM_PLIST(list, 3 * i + 3, str);
        }
        else if (IS_MODULE_STATIC(m->type)) {
            SET_ELM_PLIST(list, 3 * i + 1, ObjsChar[(Int)'s']);
            CHANGED_BAG(list);
            str = MakeImmString(m->name);
            SET_ELM_PLIST(list, 3 * i + 2, str);
            CHANGED_BAG(list);
            str = MakeImmString(Modules[i].filename);
            SET_ELM_PLIST(list, 3 * i + 3, str);
        }
    }
    return list;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitBagNamesFromTable( <table> )  . . . . . . . . .  initialise bag names
*/
void InitBagNamesFromTable(const StructBagNames * tab)
{
    Int i;

    for (i = 0; tab[i].tnum != -1; i++) {
        SET_TNAM_TNUM(tab[i].tnum, tab[i].name);
    }
}


/****************************************************************************
**
*F  InitClearFiltsTNumsFromTable( <tab> ) . . .  initialise clear filts tnums
*/
void InitClearFiltsTNumsFromTable(const Int * tab)
{
    Int i;

    for (i = 0; tab[i] != -1; i += 2) {
        ClearFiltsTNums[tab[i]] = tab[i + 1];
        ClearFiltsTNums[tab[i] | IMMUTABLE] = tab[i + 1] | IMMUTABLE;
    }
}


/****************************************************************************
**
*F  InitHasFiltListTNumsFromTable( <tab> )  . . initialise tester filts tnums
*/
void InitHasFiltListTNumsFromTable(const Int * tab)
{
    Int i;

    for (i = 0; tab[i] != -1; i += 3) {
        HasFiltListTNums[tab[i]][tab[i + 1]] = tab[i + 2];
        HasFiltListTNums[tab[i] | IMMUTABLE][tab[i + 1]] = tab[i + 2];
    }
}


/****************************************************************************
**
*F  InitSetFiltListTNumsFromTable( <tab> )  . . initialise setter filts tnums
*/
void InitSetFiltListTNumsFromTable(const Int * tab)
{
    Int i;

    for (i = 0; tab[i] != -1; i += 3) {
        SetFiltListTNums[tab[i]][tab[i + 1]] = tab[i + 2];
        SetFiltListTNums[tab[i] | IMMUTABLE][tab[i + 1]] =
            tab[i + 2] | IMMUTABLE;
    }
}


/****************************************************************************
**
*F  InitResetFiltListTNumsFromTable( <tab> )  initialise unsetter filts tnums
*/
void InitResetFiltListTNumsFromTable(const Int * tab)
{
    Int i;

    for (i = 0; tab[i] != -1; i += 3) {
        ResetFiltListTNums[tab[i]][tab[i + 1]] = tab[i + 2];
        ResetFiltListTNums[tab[i] | IMMUTABLE][tab[i + 1]] =
            tab[i + 2] | IMMUTABLE;
    }
}

static Obj ValidatedArgList(const char * name, int nargs, const char * argStr)
{
    Obj args = ArgStringToList(argStr);
    int len = LEN_PLIST(args);
    if (nargs >= 0 && len != nargs)
        fprintf(stderr,
                "#W %s takes %d arguments, but argument string is '%s'"
                " which implies %d arguments\n",
                name, nargs, argStr, len);
    return args;
}

/****************************************************************************
**
*F  InitGVarFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
void InitGVarFiltsFromTable(const StructGVarFilt * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        UInt gvar = GVarName(tab[i].name);
        Obj  name = NameGVar(gvar);
        Obj  args = ValidatedArgList(tab[i].name, 1, tab[i].argument);
        AssReadOnlyGVar(gvar, NewFilter(name, args, tab[i].handler));
    }
}


/****************************************************************************
**
*F  InitGVarAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
void InitGVarAttrsFromTable(const StructGVarAttr * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        UInt gvar = GVarName(tab[i].name);
        Obj  name = NameGVar(gvar);
        Obj  args = ValidatedArgList(tab[i].name, 1, tab[i].argument);
        AssReadOnlyGVar(gvar, NewAttribute(name, args, tab[i].handler));
    }
}

/****************************************************************************
**
*F  InitGVarPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
void InitGVarPropsFromTable(const StructGVarProp * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        UInt gvar = GVarName(tab[i].name);
        Obj  name = NameGVar(gvar);
        Obj  args = ValidatedArgList(tab[i].name, 1, tab[i].argument);
        AssReadOnlyGVar(gvar, NewProperty(name, args, tab[i].handler));
    }
}


/****************************************************************************
**
*F  InitGVarOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
void InitGVarOpersFromTable(const StructGVarOper * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        UInt gvar = GVarName(tab[i].name);
        Obj  name = NameGVar(gvar);
        Obj  args = ValidatedArgList(tab[i].name, tab[i].nargs, tab[i].args);
        AssReadOnlyGVar(
            gvar, NewOperation(name, tab[i].nargs, args, tab[i].handler));
    }
}

static void SetupFuncInfo(Obj func, const Char * cookie)
{
    // The string <cookie> usually has the form "PATH/TO/FILE.c:FUNCNAME".
    // We check if that is the case, and if so, split it into the parts before
    // and after the colon. In addition, the file path is cut to only contain
    // the last two '/'-separated components.
    const Char * pos = strchr(cookie, ':');
    if (pos) {
        Obj location = MakeImmString(pos + 1);

        Obj  filename;
        char buffer[512];
        Int  len = 511 < (pos - cookie) ? 511 : pos - cookie;
        memcpy(buffer, cookie, len);
        buffer[len] = 0;

        Char * start = strrchr(buffer, '/');
        if (start) {
            while (start > buffer && *(start - 1) != '/')
                start--;
        }
        else
            start = buffer;
        filename = MakeImmString(start);

        Obj body_bag = NewFunctionBody();
        SET_FILENAME_BODY(body_bag, filename);
        SET_LOCATION_BODY(body_bag, location);
        SET_BODY_FUNC(func, body_bag);
        CHANGED_BAG(body_bag);
        CHANGED_BAG(func);
    }
}

/****************************************************************************
**
*F  InitGVarFuncsFromTable( <tab> ) . . . . . . . . . . . . . . new functions
*/
void InitGVarFuncsFromTable(const StructGVarFunc * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        UInt gvar = GVarName(tab[i].name);
        Obj  name = NameGVar(gvar);
        Obj  args = ValidatedArgList(tab[i].name, tab[i].nargs, tab[i].args);
        Obj  func = NewFunction(name, tab[i].nargs, args, tab[i].handler);
        SetupFuncInfo(func, tab[i].cookie);
        AssReadOnlyGVar(gvar, func);
    }
}


/****************************************************************************
**
*F  InitHdlrFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
void InitHdlrFiltsFromTable(const StructGVarFilt * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        InitHandlerFunc(tab[i].handler, tab[i].cookie);
        InitFopyGVar(tab[i].name, tab[i].filter);
    }
}


/****************************************************************************
**
*F  InitHdlrAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
void InitHdlrAttrsFromTable(const StructGVarAttr * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        InitHandlerFunc(tab[i].handler, tab[i].cookie);
        InitFopyGVar(tab[i].name, tab[i].attribute);
    }
}


/****************************************************************************
**
*F  InitHdlrPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
void InitHdlrPropsFromTable(const StructGVarProp * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        InitHandlerFunc(tab[i].handler, tab[i].cookie);
        InitFopyGVar(tab[i].name, tab[i].property);
    }
}


/****************************************************************************
**
*F  InitHdlrOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
void InitHdlrOpersFromTable(const StructGVarOper * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        InitHandlerFunc(tab[i].handler, tab[i].cookie);
        InitFopyGVar(tab[i].name, tab[i].operation);
    }
}


/****************************************************************************
**
*F  InitHdlrFuncsFromTable( <tab> ) . . . . . . . . . . . . . . new functions
*/
void InitHdlrFuncsFromTable(const StructGVarFunc * tab)
{
    Int i;

    for (i = 0; tab[i].name != 0; i++) {
        InitHandlerFunc(tab[i].handler, tab[i].cookie);
    }
}


/****************************************************************************
**
*F  ImportGVarFromLibrary( <name>, <address> )  . . .  import global variable
*/


void ImportGVarFromLibrary(const Char * name, Obj * address)
{
    if (NrImportedGVars == 1024) {
        Pr("#W  warning: too many imported GVars\n", 0, 0);
    }
    else {
        ImportedGVars[NrImportedGVars].name = name;
        ImportedGVars[NrImportedGVars].address = address;
        NrImportedGVars++;
    }
    if (address != 0) {
        InitCopyGVar(name, address);
    }
}


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/


void ImportFuncFromLibrary(const Char * name, Obj * address)
{
    if (NrImportedFuncs == 1024) {
        Pr("#W  warning: too many imported Funcs\n", 0, 0);
    }
    else {
        ImportedFuncs[NrImportedFuncs].name = name;
        ImportedFuncs[NrImportedFuncs].address = address;
        NrImportedFuncs++;
    }
    if (address != 0) {
        InitFopyGVar(name, address);
    }
}


/****************************************************************************
**
*F  FuncExportToKernelFinished( <self> )  . . . . . . . . . . check functions
*/
static Obj FuncExportToKernelFinished(Obj self)
{
    UInt i;
    Int  errs = 0;
    Obj  val;

    SyInitializing = 0;
    for (i = 0; i < NrImportedGVars; i++) {
        if (ImportedGVars[i].address == 0) {
            val = ValAutoGVar(GVarName(ImportedGVars[i].name));
            if (val == 0) {
                errs++;
                if (!SyQuiet) {
                    Pr("#W  global variable '%s' has not been defined\n",
                       (Int)ImportedFuncs[i].name, 0);
                }
            }
        }
        else if (*ImportedGVars[i].address == 0) {
            errs++;
            if (!SyQuiet) {
                Pr("#W  global variable '%s' has not been defined\n",
                   (Int)ImportedGVars[i].name, 0);
            }
        }
        else {
            MakeReadOnlyGVar(GVarName(ImportedGVars[i].name));
        }
    }

    for (i = 0; i < NrImportedFuncs; i++) {
        if (ImportedFuncs[i].address == 0) {
            val = ValAutoGVar(GVarName(ImportedFuncs[i].name));
            if (val == 0 || !IS_FUNC(val)) {
                errs++;
                if (!SyQuiet) {
                    Pr("#W  global function '%s' has not been defined\n",
                       (Int)ImportedFuncs[i].name, 0);
                }
            }
        }
        else if (*ImportedFuncs[i].address == ErrorMustEvalToFuncFunc ||
                 *ImportedFuncs[i].address == ErrorMustHaveAssObjFunc) {
            errs++;
            if (!SyQuiet) {
                Pr("#W  global function '%s' has not been defined\n",
                   (Int)ImportedFuncs[i].name, 0);
            }
        }
        else {
            MakeReadOnlyGVar(GVarName(ImportedFuncs[i].name));
        }
    }

    return errs == 0 ? True : False;
}


/****************************************************************************
**
*F  RecordLoadedModule( <module> )  . . . . . . . . store module in <Modules>
*/

void RecordLoadedModule(StructInitInfo * info,
                        Int              isGapRootRelative,
                        const Char *     filename)
{
    UInt len;
    if (NrModules == MAX_MODULES) {
        Panic("no room to record module");
    }
    len = strlen(filename);
    if (NextLoadedModuleFilename + len + 1 >
        LoadedModuleFilenames + MAX_MODULE_FILENAMES) {
        Panic("no room for module filename");
    }
    *NextLoadedModuleFilename = '\0';
    memcpy(NextLoadedModuleFilename, filename, len + 1);
    Modules[NrModules].info = info;
    Modules[NrModules].filename = NextLoadedModuleFilename;
    NextLoadedModuleFilename += len + 1;
    Modules[NrModules].isGapRootRelative = isGapRootRelative;
    NrModules++;
}

#ifdef GAP_ENABLE_SAVELOAD

void SaveModules(void)
{
    SaveUInt(NrModules - NrBuiltinModules);
    for (UInt i = NrBuiltinModules; i < NrModules; i++) {
        SaveUInt(Modules[i].info->type);
        SaveUInt(Modules[i].isGapRootRelative);
        SaveCStr(Modules[i].filename);
    }
}

void LoadModules(void)
{
    Char buf[256];
    UInt nMods = LoadUInt();
    for (UInt i = 0; i < nMods; i++) {
        UInt type = LoadUInt();
        UInt isGapRootRelative = LoadUInt();
        LoadCStr(buf, 256);
        if (isGapRootRelative)
            READ_GAP_ROOT(buf);
        else {
            StructInitInfo * info = NULL;
            /* Search for user module static case first */
            if (IS_MODULE_STATIC(type)) {
                info = LookupStaticModule(buf);
                if (info == 0) {
                    Panic("Static module %s not found in loading kernel",
                          buf);
                }
            }
            else {
                /* and dynamic case */
                InitInfoFunc init;

#ifdef HAVE_DLOPEN
                const char * res = SyLoadModule(buf, &init);
                if (init == 0) {
                    Panic("failed to load dynamic module %s, %s\n", buf, res);
                }
                info = (*init)();
                if (info == 0) {
                    Panic("failed to init dynamic module %s\n", buf);
                }
#else
                Panic("workspace require dynamic module %s, but dynamic "
                      "loading not supported",
                      buf);
#endif
            }

            ActivateModule(info);
            RecordLoadedModule(info, 0, buf);
        }
    }
}

#endif

void ModulesSetup(void)
{
    NrImportedGVars = 0;
    NrImportedFuncs = 0;
    NrModules = 0;
    for (UInt i = 0; InitFuncsBuiltinModules[i]; i++) {
        if (NrModules == MAX_MODULES) {
            Panic("too many builtin modules");
        }
        StructInitInfo * info = InitFuncsBuiltinModules[i]();
        Modules[NrModules++].info = info;
        if (SyDebugLoading) {
            fputs("#I  InitInfo(builtin ", stderr);
            fputs(info->name, stderr);
            fputs(")\n", stderr);
        }

        RegisterModuleState(info);
    }
    NrBuiltinModules = NrModules;
}

void ModulesInitKernel(void)
{
    for (UInt i = 0; i < NrBuiltinModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->initKernel) {
            if (SyDebugLoading) {
                fputs("#I  InitKernel(builtin ", stderr);
                fputs(info->name, stderr);
                fputs(")\n", stderr);
            }
            Int ret = info->initKernel(info);
            if (ret) {
                Panic("InitKernel(builtin %s) returned non-zero value", info->name);
            }
        }
    }
}

void ModulesInitLibrary(void)
{
    for (UInt i = 0; i < NrBuiltinModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->initLibrary) {
            if (SyDebugLoading) {
                fputs("#I  InitLibrary(builtin ", stderr);
                fputs(info->name, stderr);
                fputs(")\n", stderr);
            }
            Int ret = info->initLibrary(info);
            if (ret) {
                Panic("InitLibrary(builtin %s) returned non-zero value", info->name);
            }
        }
    }
}

void ModulesCheckInit(void)
{
    for (UInt i = 0; i < NrModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->checkInit) {
            if (SyDebugLoading) {
                fputs("#I  CheckInit(builtin ", stderr);
                fputs(info->name, stderr);
                fputs(")\n", stderr);
            }
            Int ret = info->checkInit(info);
            if (ret) {
                Panic("CheckInit(builtin %s) returned non-zero value", info->name);
            }
        }
    }
}

void ModulesInitModuleState(void)
{
    for (UInt i = 0; i < NrModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->initModuleState) {
            if (SyDebugLoading) {
                fputs("#I  InitModuleState(", stderr);
                fputs(info->name, stderr);
                fputs(")\n", stderr);
            }
            Int ret = info->initModuleState();
            if (ret) {
                Panic("InitModuleState(builtin %s) returned non-zero value", info->name);
            }
        }
    }
}

void ModulesDestroyModuleState(void)
{
    for (UInt i = 0; i < NrModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->destroyModuleState) {
            if (SyDebugLoading) {
                fputs("#I  DestroyModuleState(", stderr);
                fputs(info->name, stderr);
                fputs(")\n", stderr);
            }
            Int ret = info->destroyModuleState();
            if (ret) {
                Panic("DestroyModuleState(builtin %s) returned non-zero value", info->name);
            }
        }
    }
}


#ifdef GAP_ENABLE_SAVELOAD

Int ModulesPreSave(void)
{
    for (UInt i = 0; i < NrModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->preSave != NULL && info->preSave(info)) {
            Pr("Failed to save workspace -- problem reported in %s\n",
               (Int)info->name, 0);
            // roll back all save preparations
            while (i--) {
                info = Modules[i].info;
                info->postSave(info);
            }
            return 1;
        }
    }
    return 0;
}

void ModulesPostSave(void)
{
    for (UInt i = 0; i < NrModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->postSave != NULL)
            info->postSave(info);
    }
}

void ModulesPostRestore(void)
{
    for (UInt i = 0; i < NrModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->postRestore) {
            if (SyDebugLoading) {
                fputs("#I  PostRestore(builtin ", stderr);
                fputs(info->name, stderr);
                fputs(")\n", stderr);
            }
            Int ret = info->postRestore(info);
            if (ret) {
                Panic("PostRestore(builtin %s) returned non-zero value", info->name);
            }
        }
    }
}

#endif


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {
    GVAR_FUNC_1ARGS(GAP_CRC, filename),
    GVAR_FUNC_1ARGS(IS_LOADABLE_DYN, filename),
    GVAR_FUNC_1ARGS(LOAD_DYN, filename),
    GVAR_FUNC_1ARGS(LOAD_STAT, filename),
    GVAR_FUNC_0ARGS(SHOW_STAT),
    GVAR_FUNC_0ARGS(LoadedModules),
    GVAR_FUNC_0ARGS(ExportToKernelFinished),
    { 0, 0, 0, 0, 0 }
};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    // init filters and functions
    InitHdlrFuncsFromTable(GVarFuncs);

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    // init filters and functions
    InitGVarFuncsFromTable(GVarFuncs);

    return 0;
}


/****************************************************************************
**
*F  InitInfoModules() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "modules",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoModules(void)
{
    return &module;
}
