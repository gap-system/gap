/*
 * Small program to test libgap linkability and basic working
 */
#include "common.h"


void records(void)
{
    Obj r, nam, val, ret;

    r = GAP_NewPrecord(5);
    nam = GAP_MakeString("key");
    val = GAP_MakeString("value");

    GAP_AssRecord(r, nam, val);
    ret = GAP_ElmRecord(r, nam);

    assert(ret == val);
}


int main(int argc, char ** argv)
{
    printf("# Initializing GAP...\n");
    GAP_Initialize(argc, argv, 0, 0, 1);
    printf("# Testing records... ");
    records();
    printf("success\n");
    printf("# done\n");
    return 0;
}
