/****************************************************************************
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002-2018 The GAP Group
**
**  This files declares APIs for GAP modules, including builtin modules,
**  or static and dynamic modules used by packages and end users to provide
**  kernel extensions.
*/

#include <src/modules.h>

#include <src/ariths.h>
#include <src/bool.h>
#include <src/code.h>
#include <src/compstat.h>
#include <src/error.h>
#include <src/funcs.h>
#include <src/integer.h>
#include <src/gap.h>
#include <src/gapstate.h>
#include <src/gvars.h>
#include <src/intobj.h>
#include <src/io.h>
#include <src/lists.h>
#include <src/opers.h>
#include <src/plist.h>
#include <src/saveload.h>
#include <src/streams.h>
#include <src/stringobj.h>
#include <src/sysfiles.h>


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

Char   LoadedModuleFilenames[MAX_MODULE_FILENAMES];
Char * NextLoadedModuleFilename = LoadedModuleFilenames;

extern const InitInfoFunc InitFuncsBuiltinModules[];

StructInitInfoExt Modules[MAX_MODULES];
UInt              NrModules;
UInt              NrBuiltinModules;


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


/*************************************************************************
**
*F * * * * * * * * * functions for dynamical/static modules * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncGAP_CRC( <self>, <name> ) . . . . . . . create a crc value for a file
*/
Obj FuncGAP_CRC(Obj self, Obj filename)
{
    /* check the argument                                                  */
    while (!IsStringConv(filename)) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)", (Int)TNAM_OBJ(filename),
            0L, "you can replace <filename> via 'return <filename>;'");
    }

    /* compute the crc value                                               */
    return INTOBJ_INT(SyGAPCRC(CSTR_STRING(filename)));
}


/****************************************************************************
**
*F  FuncLOAD_DYN( <self>, <name>, <crc> ) . . .  try to load a dynamic module
*/
Obj FuncLOAD_DYN(Obj self, Obj filename, Obj crc)
{
    StructInitInfo * info;
    Obj              crc1;
    Int              res;
    InitInfoFunc     init;

    /* check the argument                                                  */
    while (!IsStringConv(filename)) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)", (Int)TNAM_OBJ(filename),
            0L, "you can replace <filename> via 'return <filename>;'");
    }
    while (!IS_INTOBJ(crc) && crc != False) {
        crc = ErrorReturnObj(
            "<crc> must be a small integer or 'false' (not a %s)",
            (Int)TNAM_OBJ(crc), 0L,
            "you can replace <crc> via 'return <crc>;'");
    }

    /* try to read the module                                              */
    res = SyLoadModule(CSTR_STRING(filename), &init);
    if (res == 1)
        ErrorQuit("module '%g' not found", (Int)filename, 0L);
    else if (res == 3)
        ErrorQuit("symbol 'Init_Dynamic' not found", 0L, 0L);
    else if (res == 5)
        ErrorQuit("forget symbol failed", 0L, 0L);

    /* no dynamic library support                                          */
    else if (res == 7) {
        if (SyDebugLoading) {
            Pr("#I  LOAD_DYN: no support for dynamical loading\n", 0L, 0L);
        }
        return False;
    }

    /* get the description structure                                       */
    info = (*init)();
    if (info == 0)
        ErrorQuit("call to init function failed", 0L, 0L);

    // info->type should not be larger than kernel version
    if (info->type / 10 > GAP_KERNEL_API_VERSION)
        ErrorMayQuit("LOAD_DYN: kernel module built for newer "
                     "version of GAP",
                     0L, 0L);

    // info->type should not have an older major version
    if (info->type / 10000 < GAP_KERNEL_MAJOR_VERSION)
        ErrorMayQuit("LOAD_DYN: kernel module built for older "
                     "version of GAP",
                     0L, 0L);

    // info->type % 10 should be 0, 1 or 2, for the 3 types of module
    if (info->type % 10 > 2)
        ErrorMayQuit("LOAD_DYN: Invalid kernel module", 0L, 0L);

    /* check the crc value                                                 */
    if (crc != False) {
        crc1 = INTOBJ_INT(info->crc);
        if (!EQ(crc, crc1)) {
            if (SyDebugLoading) {
                Pr("#I  LOAD_DYN: crc values do not match, gap ", 0L, 0L);
                PrintInt(crc);
                Pr(", dyn ", 0L, 0L);
                PrintInt(crc1);
                Pr("\n", 0L, 0L);
            }
            return False;
        }
    }

    /* link and init me                                                    */
    res = (info->initKernel)(info);
    UpdateCopyFopyInfo();

    /* Start a new executor to run the outer function of the module
       in global context */
    ExecBegin(STATE(BottomLVars));
    res = res || (info->initLibrary)(info);
    ExecEnd(res ? STATUS_ERROR : STATUS_END);
    if (res) {
        Pr("#W  init functions returned non-zero exit code\n", 0L, 0L);
    }
    RecordLoadedModule(info, 0, CSTR_STRING(filename));

    return True;
}


/****************************************************************************
**
*F  FuncLOAD_STAT( <self>, <name>, <crc> )  . . . . try to load static module
*/
Obj FuncLOAD_STAT(Obj self, Obj filename, Obj crc)
{
    StructInitInfo * info = 0;
    Obj              crc1;
    Int              res;
    Int              k;

    /* check the argument                                                  */
    while (!IsStringConv(filename)) {
        filename = ErrorReturnObj(
            "<filename> must be a string (not a %s)", (Int)TNAM_OBJ(filename),
            0L, "you can replace <filename> via 'return <filename>;'");
    }
    while (!IS_INTOBJ(crc) && crc != False) {
        crc = ErrorReturnObj(
            "<crc> must be a small integer or 'false' (not a %s)",
            (Int)TNAM_OBJ(crc), 0L,
            "you can replace <crc> via 'return <crc>;'");
    }

    /* try to find the module                                              */
    for (k = 0; CompInitFuncs[k]; k++) {
        info = (*(CompInitFuncs[k]))();
        if (info && !strcmp(CSTR_STRING(filename), info->name)) {
            break;
        }
    }
    if (CompInitFuncs[k] == 0) {
        if (SyDebugLoading) {
            Pr("#I  LOAD_STAT: no module named '%g' found\n", (Int)filename,
               0L);
        }
        return False;
    }

    /* check the crc value                                                 */
    if (crc != False) {
        crc1 = INTOBJ_INT(info->crc);
        if (!EQ(crc, crc1)) {
            if (SyDebugLoading) {
                Pr("#I  LOAD_STAT: crc values do not match, gap ", 0L, 0L);
                PrintInt(crc);
                Pr(", stat ", 0L, 0L);
                PrintInt(crc1);
                Pr("\n", 0L, 0L);
            }
            return False;
        }
    }

    /* link and init me                                                    */
    res = (info->initKernel)(info);
    UpdateCopyFopyInfo();

    /* Start a new executor to run the outer function of the module
       in global context */
    ExecBegin(STATE(BottomLVars));
    res = res || (info->initLibrary)(info);
    ExecEnd(res ? STATUS_ERROR : STATUS_END);
    if (res) {
        Pr("#W  init functions returned non-zero exit code\n", 0L, 0L);
    }
    RecordLoadedModule(info, 0, CSTR_STRING(filename));

    return True;
}


/****************************************************************************
**
*F  FuncSHOW_STAT() . . . . . . . . . . . . . . . . . . . show static modules
*/
Obj FuncSHOW_STAT(Obj self)
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
    SET_LEN_PLIST(modules, 2 * im);

    for (k = 0, im = 1; CompInitFuncs[k]; k++) {
        info = (*(CompInitFuncs[k]))();
        if (info == 0) {
            continue;
        }
        name = MakeImmString(info->name);

        SET_ELM_PLIST(modules, im, name);

        /* compute the crc value                                           */
        SET_ELM_PLIST(modules, im + 1, INTOBJ_INT(info->crc));
        im += 2;
    }

    return modules;
}


/****************************************************************************
**
*F  FuncLoadedModules( <self> ) . . . . . . . . . . . list all loaded modules
*/
Obj FuncLoadedModules(Obj self)
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
        InfoBags[tab[i].tnum].name = tab[i].name;
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
        Obj  name = NameGVarObj(gvar);
        Obj  args = ValidatedArgList(tab[i].name, 1, tab[i].argument);
        AssReadOnlyGVar(gvar, NewFilter(name, 1, args, tab[i].handler));
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
        Obj  name = NameGVarObj(gvar);
        Obj  args = ValidatedArgList(tab[i].name, 1, tab[i].argument);
        AssReadOnlyGVar(gvar, NewAttribute(name, 1, args, tab[i].handler));
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
        Obj  name = NameGVarObj(gvar);
        Obj  args = ValidatedArgList(tab[i].name, 1, tab[i].argument);
        AssReadOnlyGVar(gvar, NewProperty(name, 1, args, tab[i].handler));
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
        Obj  name = NameGVarObj(gvar);
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

        Obj body_bag = NewBag(T_BODY, sizeof(BodyHeader));
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
        Obj  name = NameGVarObj(gvar);
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
        Pr("#W  warning: too many imported GVars\n", 0L, 0L);
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
        Pr("#W  warning: too many imported Funcs\n", 0L, 0L);
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
Obj FuncExportToKernelFinished(Obj self)
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
                       (Int)ImportedFuncs[i].name, 0L);
                }
            }
        }
        else if (*ImportedGVars[i].address == 0) {
            errs++;
            if (!SyQuiet) {
                Pr("#W  global variable '%s' has not been defined\n",
                   (Int)ImportedGVars[i].name, 0L);
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
                       (Int)ImportedFuncs[i].name, 0L);
                }
            }
        }
        else if (*ImportedFuncs[i].address == ErrorMustEvalToFuncFunc ||
                 *ImportedFuncs[i].address == ErrorMustHaveAssObjFunc) {
            errs++;
            if (!SyQuiet) {
                Pr("#W  global function '%s' has not been defined\n",
                   (Int)ImportedFuncs[i].name, 0L);
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
        Pr("panic: no room to record module\n", 0L, 0L);
    }
    len = strlen(filename);
    if (NextLoadedModuleFilename + len + 1 >
        LoadedModuleFilenames + MAX_MODULE_FILENAMES) {
        Pr("panic: no room for module filename\n", 0L, 0L);
    }
    *NextLoadedModuleFilename = '\0';
    memcpy(NextLoadedModuleFilename, filename, len + 1);
    Modules[NrModules].info = info;
    Modules[NrModules].filename = NextLoadedModuleFilename;
    NextLoadedModuleFilename += len + 1;
    Modules[NrModules].isGapRootRelative = isGapRootRelative;
    NrModules++;
}


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
                UInt k;
                for (k = 0; CompInitFuncs[k]; k++) {
                    info = (*(CompInitFuncs[k]))();
                    if (info == 0) {
                        continue;
                    }
                    if (!strcmp(buf, info->name)) {
                        break;
                    }
                }
                if (CompInitFuncs[k] == 0) {
                    Pr("Static module %s not found in loading kernel\n",
                       (Int)buf, 0L);
                    SyExit(1);
                }
            }
            else {
                /* and dynamic case */
                InitInfoFunc init;

                Int res = SyLoadModule(buf, &init);

                if (res != 0) {
                    Pr("Failed to load needed dynamic module %s, error code "
                       "%d\n",
                       (Int)buf, res);
                    SyExit(1);
                }
                info = (*init)();
                if (info == 0) {
                    Pr("Failed to init needed dynamic module %s, error code "
                       "%d\n",
                       (Int)buf, (Int)info);
                    SyExit(1);
                }
            }
            /* link and init me */
            (info->initKernel)(info);
            RecordLoadedModule(info, 0, buf);
        }
    }
}

void ModulesSetup(void)
{
    NrImportedGVars = 0;
    NrImportedFuncs = 0;
    NrModules = 0;
    for (UInt i = 0; InitFuncsBuiltinModules[i]; i++) {
        if (NrModules == MAX_MODULES) {
            FPUTS_TO_STDERR("panic: too many builtin modules\n");
            SyExit(1);
        }
        StructInitInfo * info = InitFuncsBuiltinModules[i]();
        Modules[NrModules++].info = info;
        if (SyDebugLoading) {
            FPUTS_TO_STDERR("#I  InitInfo(builtin ");
            FPUTS_TO_STDERR(info->name);
            FPUTS_TO_STDERR(")\n");
        }
    }
    NrBuiltinModules = NrModules;
}

void ModulesInitKernel(void)
{
    for (UInt i = 0; i < NrBuiltinModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->initKernel) {
            if (SyDebugLoading) {
                FPUTS_TO_STDERR("#I  InitKernel(builtin ");
                FPUTS_TO_STDERR(info->name);
                FPUTS_TO_STDERR(")\n");
            }
            Int ret = info->initKernel(info);
            if (ret) {
                FPUTS_TO_STDERR("#I  InitKernel(builtin ");
                FPUTS_TO_STDERR(info->name);
                FPUTS_TO_STDERR(") returned non-zero value\n");
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
                FPUTS_TO_STDERR("#I  InitLibrary(builtin ");
                FPUTS_TO_STDERR(info->name);
                FPUTS_TO_STDERR(")\n");
            }
            Int ret = info->initLibrary(info);
            if (ret) {
                FPUTS_TO_STDERR("#I  InitLibrary(builtin ");
                FPUTS_TO_STDERR(info->name);
                FPUTS_TO_STDERR(") returned non-zero value\n");
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
                FPUTS_TO_STDERR("#I  CheckInit(builtin ");
                FPUTS_TO_STDERR(info->name);
                FPUTS_TO_STDERR(")\n");
            }
            Int ret = info->checkInit(info);
            if (ret) {
                FPUTS_TO_STDERR("#I  CheckInit(builtin ");
                FPUTS_TO_STDERR(info->name);
                FPUTS_TO_STDERR(") returned non-zero value\n");
            }
        }
    }
}

Int ModulesPreSave(void)
{
    for (UInt i = 0; i < NrModules; i++) {
        StructInitInfo * info = Modules[i].info;
        if (info->preSave != NULL && info->preSave(info)) {
            Pr("Failed to save workspace -- problem reported in %s\n",
               (Int)info->name, 0L);
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
                FPUTS_TO_STDERR("#I  PostRestore(builtin ");
                FPUTS_TO_STDERR(info->name);
                FPUTS_TO_STDERR(")\n");
            }
            Int ret = info->postRestore(info);
            if (ret) {
                FPUTS_TO_STDERR("#I  PostRestore(builtin ");
                FPUTS_TO_STDERR(info->name);
                FPUTS_TO_STDERR(") returned non-zero value\n");
            }
        }
    }
}


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {
    GVAR_FUNC(GAP_CRC, 1, "filename"),
    GVAR_FUNC(LOAD_DYN, 2, "filename, crc"),
    GVAR_FUNC(LOAD_STAT, 2, "filename, crc"),
    GVAR_FUNC(SHOW_STAT, 0, ""),
    GVAR_FUNC(LoadedModules, 0, ""),
    GVAR_FUNC(ExportToKernelFinished, 0, ""),
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

    // return success
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

    // return success
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
