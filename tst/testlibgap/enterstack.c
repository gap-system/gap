/*
 * Test that GAP objects referenced only from local variables of the
 * function calling GAP_Enter() survive garbage collection
 */
#include "common.h"

// overwrite stale copies of GAP objects left on the stack by earlier calls
static __attribute__((noinline)) void clobber_stack(void)
{
    char volatile buf[4096];
    for (size_t i = 0; i < sizeof(buf); i++)
        buf[i] = 0;
}

static void test_local(void)
{
    // volatile keeps the list in this function's stack frame
    Obj volatile list;
    int          ok = GAP_Enter();
    if (ok) {
        list = GAP_NewPlist(1);
        GAP_AssList(list, 1, GAP_NewObjIntFromInt(42));
        clobber_stack();
        GAP_CollectBags(1);
        // reuse the memory of the list if it was wrongly freed
        for (int i = 0; i < 1000; i++)
            GAP_NewPlist(1);
        printf("%d %d\n", (int)GAP_LenList(list),
               (int)GAP_ValueInt(GAP_ElmList(list, 1)));
    }
    GAP_Leave();
}

int main(int argc, char ** argv)
{
    GAP_Initialize(argc, argv, 0, 0, 1);
    test_local();
    return 0;
}
