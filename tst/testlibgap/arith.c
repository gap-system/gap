/*
 * Small program to test libgap linkability and basic working
 */
#include "common.h"
int main(int argc, char ** argv)
{
    Int a = 42;
    Obj b, c;
    printf("# Initializing GAP...\n");
    GAP_Initialize(argc, argv, environ, 0L, 0L);
    b = INTOBJ_INT(a); 
    b = INV(b);  
    ViewObj(b);  
    Pr("\n", 0L, 0L); 
    CollectBags(0, 1);    // full GC
    ViewObj(b);  
    Pr("\n", 0L, 0L); 
    printf("# done\n");
    return 0;
}
