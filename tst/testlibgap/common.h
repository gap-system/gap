#include <stdio.h>
#include <unistd.h>
#include <compiled.h>
#include <libgap-api.h>
extern char ** environ;

UInt GAP_List_Length(Obj list);
Obj GAP_List_AtPosition(Obj list, Int pos);
UInt GAP_String_Length(Obj string);
Int GAP_String_GetCString(Obj string, Char * buffer, UInt n);
void test_eval(const char * cmd);
