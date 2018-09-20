/*
 * Small program to test libgap ability to save workspaces
 */
#include "common.h"
int main(int argc, char ** argv)
{
    printf("# Initializing GAP...\n");
    GAP_Initialize(argc, argv, environ, 0L, 0L);
    printf("# looking at saved stuff...\n");
    test_eval("g;");
    test_eval("a;");
    test_eval("b;");
    test_eval("[a^2, a^2, b*a];");
    test_eval("Order(h);");
    printf("# done\n");
    return 0;
}
