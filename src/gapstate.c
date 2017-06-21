/***********************************************************************
 **
 *W  gapstate.c      GAP source                 Markus Pfeiffer
 **
 **
 ** This file declares all variables that are considered state for the
 ** interpreter
 **
 */

#include "system.h"
#include "gapstate.h"

#define MAX_FUNC_EXPR_NESTING 1024

static Stat MainOffsBodyStack[MAX_FUNC_EXPR_NESTING];
static UInt MainLoopStack[MAX_FUNC_EXPR_NESTING];

static GAPState _MainGAPState;

GAPState * MainGAPState = 0;

void InitMainGAPState(void)
{
    // with GASMAN mallocing this struct could
    // lead to unwanted effects.
    MainGAPState = &_MainGAPState;
    MainGAPState->OffsBodyStack = MainOffsBodyStack;
    MainGAPState->LoopStack = MainLoopStack;
}

void InitGAPState(GAPState * state)
{
    InitScannerState(state);
    InitStatState(state);
    InitExprState(state);
    InitCoderState(state);
    InitOpersState(state);

    // RunConstructors?
}

void DestroyGAPState(GAPState * state)
{
    DestroyScannerState(state);
    DestroyStatState(state);
    DestroyExprState(state);
    DestroyCoderState(state);
    DestroyOpersState(state);
}
