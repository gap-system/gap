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

#endif
