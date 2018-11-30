/*
 * Small program to test libgap ability to save workspaces.
 * Ought to be used with wsload.c
 */
#include "common.h"
int main(int argc, char ** argv)
{
    GAP_Initialize(argc, argv, 0, 0, 1);
    test_eval("g:=FreeGroup(2);");
    test_eval("a:=g.1;");
    test_eval("b:=g.2;");
    test_eval("lis:=[a^2, a^2, b*a];");
    test_eval("h:=g/lis;");
    /* TODO: use unique temporary filename to avoid a race */
    test_eval("SaveWorkspace(\"/tmp/libgap.ws\");\n");
    printf("# done\n");
    return 0;
}
