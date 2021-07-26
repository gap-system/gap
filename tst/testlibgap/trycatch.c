/*
 * Small program to test libgap linkability and basic working
 */
#include "trycatch.h"
#include "common.h"

static int level = 0;

static void handle_trycatch(TryCatchMode mode)
{
    switch (mode) {
    case TryEnter:
        level++;
        printf("%d: Entering GAP_TRY section\n", level);
        break;
    case TryLeave:
        printf("%d: Leaving GAP_TRY section\n", level);
        level--;
        break;
    case TryCatch:
        printf("%d: Caught error in GAP_TRY section\n", level);
        level--;
        break;
    }
}

int main(int argc, char ** argv)
{
    printf("# Initializing GAP...\n");
    GAP_Initialize(argc, argv, 0, 0, 1);
    test_eval("OnBreak := false;;");
    // Necessary to redirect error printing to stdout.
    test_eval("MakeReadWriteGVar(\"ERROR_OUTPUT\");");
    test_eval("ERROR_OUTPUT := MakeImmutable(\"*stdout*\");;");

    RegisterTryCatchHandler(handle_trycatch);
    test_eval("Display(CALL_WITH_CATCH(function() return 314; end, []));;");
    test_eval("Display(CALL_WITH_CATCH(function() return [][1]; end, []));;");
    return 0;
}
