/*
 * Small program to test libgap linkability and basic working
 */
#include "common.h"
int main(int argc, char ** argv)
{
    printf("# Initializing GAP...\n");
    GAP_Initialize(argc, argv, 0, 0, 1);
    test_eval("1+2+3;");
    test_eval("g:=FreeGroup(2);");
    test_eval("a:=g.1;");
    test_eval("b:=g.2;");
    test_eval("lis:=[a^2, a^2, b*a];");
    test_eval("h:=g/lis;");
    test_eval("c:=h.1;");
    test_eval("Set([1..1000000], i->Order(c));");
    printf("# done\n");
    return 0;
}
