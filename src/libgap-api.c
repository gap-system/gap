// LibGAP API - API for using GAP as shared library.

#include "libgap-api.h"

#include "bool.h"
#include "opers.h"
#include "calls.h"
#include "gapstate.h"
#include "gvars.h"
#include "lists.h"
#include "plist.h"
#include "streams.h"
#include "stringobj.h"

//
// Setup and initialisation
//
void GAP_Initialize(int          argc,
                    char **      argv,
                    char **      env,
                    CallbackFunc markBagsCallback,
                    CallbackFunc errorCallback)
{
    InitializeGap(&argc, argv, env);
    SetExtraMarkFuncBags(markBagsCallback);
    STATE(JumpToCatchCallback) = errorCallback;
}


// Combines GVarName and ValGVar. For a given string, it returns the value
// of the gvar with name <name>, or NULL if the global variable is not
// defined.
Obj GAP_ValueGlobalVariable(const char * name)
{
    UInt gvar = GVarName(name);
    // TODO: GVarName should never return 0?
    if (gvar != 0) {
        return ValGVar(gvar);
    }
    else {
        return NULL;
    }
}

//
// Evaluate a string of GAP commands
//
// To see an example of how to use this function
// see tst/testlibgap/basic.c
//
Obj GAP_EvalString(const char * cmd)
{
    Obj instream;
    Obj res;
    Obj viewObjFunc, streamFunc;

    streamFunc = GAP_ValueGlobalVariable("InputTextString");
    viewObjFunc = GAP_ValueGlobalVariable("ViewObj");

    instream = DoOperation1Args(streamFunc, MakeString(cmd));
    res = READ_ALL_COMMANDS(instream, False, True, viewObjFunc);
    return res;
}

//
// Returns the GAP object containing
// <string>
Obj GAP_MakeString(char * string)
{
    return MakeString(string);
}

//
// Returns a pointer to the
// contents of the GAP string object <string>
char * GAP_CSTR_STRING(Obj string)
{
    return CSTR_STRING(string);
}

//
// Returns a new empty plain list
// with capacity <capacity>
Obj GAP_NewPlist(Int capacity)
{
    return NEW_PLIST(T_PLIST_EMPTY, capacity);
}
