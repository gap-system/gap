/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains functionality for tracing how often internal operations
** (like +, ^, -) are executed on each TNUM.
**
*/

#include "tracing.h"

#include "bool.h"
#include "gaputils.h"
#include "integer.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "precord.h"
#include "records.h"

#include <setjmp.h>

static Obj RecordedStats;

// Report the 1 argument operation 'name' was applied to 'op'
void ReportWrappedOperation1(const char * cname, Obj op)
{
    UInt name = RNamName(cname);
    if (!ISB_REC(RecordedStats, name)) {
        Obj list = NEW_PLIST(T_PLIST, 0);
        ASS_REC(RecordedStats, name, list);
    }
    Obj list = ELM_REC(RecordedStats, name);

    UInt tnam = TNUM_OBJ(op) + 1;
    Obj  val = ELM0_LIST(list, tnam);
    if (!val) {
        val = INTOBJ_INT(0);
    }

    // Cannot use SUM here, as that is traced, so would cause a loop
    UInt8 intval = Int8_ObjInt(val);
    intval++;
    val = ObjInt_Int8(intval);

    ASS_LIST(list, tnam, val);
}

// Report the 2 argument operation 'name' was applied to 'op1' and 'op2'
void ReportWrappedOperation2(const char * cname, Obj op1, Obj op2)
{
    UInt name = RNamName(cname);
    if (!ISB_REC(RecordedStats, name)) {
        Obj list = NEW_PLIST(T_PLIST, 0);
        ASS_REC(RecordedStats, name, list);
    }
    Obj list = ELM_REC(RecordedStats, name);

    UInt tnam1 = TNUM_OBJ(op1) + 1;
    Obj  pos = ELM0_LIST(list, tnam1);
    if (!pos) {
        pos = NEW_PLIST(T_PLIST, 0);
        ASS_LIST(list, tnam1, pos);
    }

    UInt tnam2 = TNUM_OBJ(op2) + 1;
    Obj  val = ELM0_LIST(pos, tnam2);
    if (!val) {
        val = INTOBJ_INT(0);
    }

    // Cannot use SUM here, as that is traced, so would cause a loop
    UInt8 intval = Int8_ObjInt(val);
    intval++;
    val = ObjInt_Int8(intval);

    ASS_LIST(pos, tnam2, val);
}

typedef struct {
    voidfunc activate;
    voidfunc deactivate;
} voidfuncs;

// Store the list of operators which can have tracing enabled and disabled
// 64 Controllers allows for future growth, but can be increased if the
// asserts below are ever triggered
static voidfuncs Controllers[64];
static int       TrackingActive;

void InstallOpWrapper(voidfunc activate, voidfunc deactivate)
{
    int pos = 0;
    while (pos < ARRAY_SIZE(Controllers) && Controllers[pos].activate != 0) {
        pos++;
    }
    assert(pos < ARRAY_SIZE(Controllers));
    voidfuncs val = { activate, deactivate };
    Controllers[pos] = val;
}

static Obj FuncTraceInternalMethods(Obj self)
{
    if (TrackingActive) {
        return Fail;
    }
    int pos = 0;
    while (pos < ARRAY_SIZE(Controllers) && Controllers[pos].activate != 0) {
        Controllers[pos].activate();
        pos++;
    }
    TrackingActive = 1;
    RecordedStats = NEW_PREC(0);
    return True;
}

static Obj FuncUntraceInternalMethods(Obj self)
{
    if (!TrackingActive) {
        return Fail;
    }
    int pos = 0;
    while (pos < ARRAY_SIZE(Controllers) && Controllers[pos].deactivate != 0) {
        Controllers[pos].deactivate();
        pos++;
    }
    TrackingActive = 0;
    return 0;
}

static Obj FuncGET_TRACED_INTERNAL_METHODS_COUNTS(Obj self)
{
    return RecordedStats;
}

static Obj FuncClearTraceInternalMethodsCounts(Obj self)
{
    RecordedStats = NEW_PREC(0);
    return 0;
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

    GVAR_FUNC_0ARGS(TraceInternalMethods),
    GVAR_FUNC_0ARGS(UntraceInternalMethods),
    GVAR_FUNC_0ARGS(GET_TRACED_INTERNAL_METHODS_COUNTS),
    GVAR_FUNC_0ARGS(ClearTraceInternalMethodsCounts),
    { 0, 0, 0, 0, 0 }
};


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable(GVarFuncs);

    RecordedStats = NEW_PREC(0);
    return 0;
}

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    InitGlobalBag(&RecordedStats, "src/tracing.c:RecordedStats");
    return 0;
}


/****************************************************************************
**
*F  InitInfoStats() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "tracing",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoTracing(void)
{
    return &module;
}
