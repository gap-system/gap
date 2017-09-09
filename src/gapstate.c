/***********************************************************************
 **
 *W  gapstate.c      GAP source                 Markus Pfeiffer
 **
 **
 ** This file declares all variables that are considered state for the
 ** interpreter
 **
 */

#include <src/system.h>
#include <src/gapstate.h>

GAPState MainGAPState;

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
