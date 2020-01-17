/*
 * Small program to test libgap ability to load workspaces.
 * Also shows how to directly pass command line arguments to libgap.
 */
#include "common.h"

#include <string.h>

int main(int argc, char ** argv)
{
    char *args[50];
    char lpar[3] = "-L";
    char wsname[16] = "/tmp/libgap.ws"; /* the name must match the one used in wscreate.c */
    memcpy(args, argv, argc*sizeof(char*));
    args[argc] = lpar;
    args[argc+1] = wsname;
    args[argc+2] = NULL;
    GAP_Initialize(argc+2, args, 0, 0, 1);
    printf("# looking at saved stuff...\n");
    test_eval("g;");
    test_eval("a;");
    test_eval("b;");
    test_eval("[a^2, a^2, b*a];");
    test_eval("Order(h);");
    printf("# done\n");
    return 0;
}
