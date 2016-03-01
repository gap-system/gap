/***********************************************************************
 **
 *W  interpreterstate.c      GAP source                 Markus Pfeiffer
 **
 **
 ** This file declares all variables that are considered state for the
 ** interpreter
 **
 */

#include "interpreterstate.h"

// InterpreterState *MainInterpreterState;

void InitInterpreter(void)
{
    // Warning: malloc
    // MainInterpreterState = malloc(sizeof(MainInterpreterState));
}

void InitInterpreterState(InterpreterState *state)
{
    InitScannerState(state);
    InitStatState(state);
    InitExprState(state);
    InitCoderState(state);
    InitOpersState(state);

    // RunConstructors?
}

void DestroyInterpreterState(InterpreterState *state)
{
    DestroyScannerState(state);
    DestroyStatState(state);
    DestroyExprState(state);
    DestroyCoderState(state);
    DestroyOpersState(state);
}
