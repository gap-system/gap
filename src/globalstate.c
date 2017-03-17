/***********************************************************************
 **
 *W  globalstate.c      GAP source                 Markus Pfeiffer
 **
 **
 ** This file declares all variables that are considered state for the
 ** interpreter
 **
 */

#include <src/globalstate.h>

#define MAX_FUNC_EXPR_NESTING 1024

static Stat MainOffsBodyStack[MAX_FUNC_EXPR_NESTING];
static UInt MainLoopStack[MAX_FUNC_EXPR_NESTING];

static GlobalState _MainGlobalState;

GlobalState *MainGlobalState = 0;

void InitMainGlobalState(void)
{
    // with GASMAN mallocing this struct could
    // lead to unwanted effects.
    MainGlobalState = &_MainGlobalState;
    MainGlobalState->OffsBodyStack = MainOffsBodyStack;
    MainGlobalState->LoopStack = MainLoopStack;
}

void InitGlobalState(GlobalState *state)
{
    InitScannerState(state);
    InitStatState(state);
    InitExprState(state);
    InitCoderState(state);
    InitOpersState(state);

    // RunConstructors?
}

void DestroyGlobal(GlobalState *state)
{
    DestroyScannerState(state);
    DestroyStatState(state);
    DestroyExprState(state);
    DestroyCoderState(state);
    DestroyOpersState(state);
}
