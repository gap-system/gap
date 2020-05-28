/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions handling Info statements.
*/


#include "info.h"

#include "bool.h"
#include "calls.h"
#include "error.h"
#include "gapstate.h"
#include "gvars.h"
#include "modules.h"
#include "plist.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#endif

enum {
    INFODATA_NUM = 1,
    INFODATA_CURRENTLEVEL,
    INFODATA_CLASSNAME,
    INFODATA_HANDLER,
    INFODATA_OUTPUT,
};

static Obj InfoDecision;
static Obj IsInfoClassListRep;
static Obj DefaultInfoHandler;
static Obj ResetShowUsedInfoClassesHandler;
static Obj ShowUsedInfoClassesHandler;


static Obj FuncShowUsedInfoClasses(Obj self, Obj choice)
{
    RequireTrueOrFalse(SELF_NAME, choice);

    if (choice == True) {
        STATE(ShowUsedInfoClassesActive) = 1;
        CALL_0ARGS(ResetShowUsedInfoClassesHandler);
    }
    else {
        STATE(ShowUsedInfoClassesActive) = 0;
    }

    return 0;
}

void InfoDoPrint(Obj cls, Obj lvl, Obj args)
{
    if (IS_PLIST(cls))
        cls = ELM_PLIST(cls, 1);
#ifdef HPCGAP
    Obj fun = Elm0AList(cls, INFODATA_HANDLER);
#else
    Obj fun = ELM_PLIST(cls, INFODATA_HANDLER);
#endif
    if (!fun)
        fun = DefaultInfoHandler;

    CALL_3ARGS(fun, cls, lvl, args);
}


Obj InfoCheckLevel(Obj selectors, Obj level)
{
    if (STATE(ShowUsedInfoClassesActive)) {
        CALL_2ARGS(ShowUsedInfoClassesHandler, selectors, level);
    }
    // Fast-path the most common failing case.
    // The fast-path only deals with the case where all arguments are of the
    // correct type, and were False is returned.
    if (CALL_1ARGS(IsInfoClassListRep, selectors) == True) {
#ifdef HPCGAP
        Obj index = ElmAList(selectors, INFODATA_CURRENTLEVEL);
#else
        Obj index = ELM_PLIST(selectors, INFODATA_CURRENTLEVEL);
#endif
        if (IS_INTOBJ(index) && IS_INTOBJ(level)) {
            // < on INTOBJs compares the represented integers.
            if (index < level) {
                return False;
            }
        }
    }
    return CALL_2ARGS(InfoDecision, selectors, level);
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {
    GVAR_FUNC_1ARGS(ShowUsedInfoClasses, choice), { 0, 0, 0, 0, 0 }
};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable(GVarFuncs);

    /* The work of handling Info messages is delegated to the GAP level */
    ImportFuncFromLibrary("InfoDecision", &InfoDecision);
    ImportFuncFromLibrary("DefaultInfoHandler", &DefaultInfoHandler);
    ImportFuncFromLibrary("IsInfoClassListRep", &IsInfoClassListRep);
    ImportFuncFromLibrary("RESET_SHOW_USED_INFO_CLASSES",
                          &ResetShowUsedInfoClassesHandler);
    ImportFuncFromLibrary("SHOW_USED_INFO_CLASSES",
                          &ShowUsedInfoClassesHandler);

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{

    InitGVarFuncsFromTable(GVarFuncs);

    ExportAsConstantGVar(INFODATA_CURRENTLEVEL);
    ExportAsConstantGVar(INFODATA_CLASSNAME);
    ExportAsConstantGVar(INFODATA_HANDLER);
    ExportAsConstantGVar(INFODATA_OUTPUT);
    ExportAsConstantGVar(INFODATA_NUM);

    return 0;
}

/****************************************************************************
**
*F  InitInfoInfo()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "info",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoInfo(void)
{
    return &module;
}
