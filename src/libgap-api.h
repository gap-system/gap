// LibGAP API - API for using GAP as shared library.

#ifndef LIBGAP_API_H
#define LIBGAP_API_H

#include "gap.h"

typedef void (*CallbackFunc)(void);

// Initialisation and finalization

void GAP_Initialize(int          argc,
                    char **      argv,
                    char **      env,
                    CallbackFunc markBagsCallback,
                    CallbackFunc errorCallback);

Obj GAP_ValueGlobalVariable(const char * name);
Obj GAP_EvalString(const char * cmd);
Obj GAP_MakeString(char * string);
char * GAP_CSTR_STRING(Obj string);
Obj GAP_NewPlist(Int capacity);

#endif
