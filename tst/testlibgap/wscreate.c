/*
 * Small program to test libgap linkability and basic working
 */
#include "common.h"
int main(int argc, char ** argv)
{
    GAP_Initialize(argc, argv, environ, 0L, 0L);
    CollectBags(0, 1);    // full GC
    test_eval("g:=FreeGroup(2);");
    test_eval("a:=g.1;");
    test_eval("b:=g.2;");
    test_eval("lis:=[a^2, a^2, b*a];");
    test_eval("h:=g/lis;");
    test_eval("SaveWorkspace(\"/tmp/libgap.ws\");\n");
    printf("# done\n");
    return 0;
}
