/*
 * Small program to test libgap linkability and basic working
 */
#include "common.h"

void test_eval(const char * cmd)
{
    Obj  res, ires;
    Int  rc, i;
    printf("gap> %s\n", cmd);
    res = GAP_EvalString(cmd);
    rc = GAP_LenList(res);
    for (i = 1; i <= rc; i++) {
        ires = GAP_ElmList(res, i);
        if (GAP_ElmList(ires, 1) == GAP_True) {
            Char * buffer = GAP_CSTR_STRING(GAP_ElmList(ires, 5));
            if (buffer)
                printf("%s\n", buffer);
        }
    }
}
