/*
 * Small program to test libgap linkability and basic working
 */
#include <stdio.h>
#include <unistd.h>

#include <src/compiled.h>
#include <src/sage_interface.h>
#include <src/sage_interface_internal.h>

extern char ** environ;

void error_handler(char * msg)
{
    printf("Error: %s\n", msg);
}

void eval(char * cmd)
{
    printf("Input:\n%s", cmd);
    libgap_start_interaction(cmd);

    libgap_enter();
    ReadEvalCommand(TLS(BottomLVars), 0);
    ViewObjHandler(TLS(ReadEvalResult));
    char * out = libgap_get_output();
    libgap_exit();

    printf("Output:\n%s", out);
    libgap_finish_interaction();
}

int main(int argc, char **argv)
{
    libgap_set_error_handler(&error_handler);
    libgap_initialize(argc, argv);
    printf("Initialized\n");

    libgap_enter();
    CollectBags(0, 1);    // full GC
    libgap_exit();

    eval("1+2+3;\n");
    eval("g:=FreeGroup(2);\n");
    eval("a:=g.1;\n");
    eval("b:=g.2;\n");
    eval("lis:=[a^2, a^2, b*a];\n");
    eval("h:=g/lis;\n");
    eval("c:=h.1;\n");
    eval("Set([1..1000000], i->Order(c));\n");

    libgap_finalize();
    return 0;
}


/*
g:=FreeGroup(2);
a:=g.1;
b:=g.2;
lis:=[a^2, a^2, b*a];
h:=g/lis;
c:=h.1;
Set([1..300000], i->Order(c));
 */
