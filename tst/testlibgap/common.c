/*
 * Small program to test libgap linkability and basic working
 */
#include "common.h"

UInt GAP_List_Length(Obj list)
{
    return LEN_LIST(list);
}

Obj GAP_List_AtPosition(Obj list, Int pos)
{
    return ELM_LIST(list, pos);
}

UInt GAP_String_Length(Obj string)
{
    return GET_LEN_STRING(string);
}

Int GAP_String_GetCString(Obj string, Char * buffer, UInt n)
{
    UInt len;

    if (IS_STRING(string)) {
        if (!IS_STRING_REP(string))
            string = CopyToStringRep(string);
        len = GET_LEN_STRING(string) + 1;
        if (len >= n)
            len = n - 1;
        // Have to use mempcy because GAP strings can contain
        // \0.
        memcpy(buffer, CSTR_STRING(string), len);
        if (len == n - 1)
            buffer[n] = '\0';
        return 1;
    }
    return 0;
}

void test_eval(const char * cmd)
{
    Obj  res, ires;
    Int  rc, i;
    Char buffer[4096];
    printf("gap> %s\n", cmd);
    res = GAP_EvalString(cmd);
    rc = GAP_List_Length(res);
    for (i = 1; i <= rc; i++) {
        ires = GAP_List_AtPosition(res, i);
        if (GAP_List_AtPosition(ires, 1) == True) {
            GAP_String_GetCString(GAP_List_AtPosition(ires, 5), buffer,
                                  sizeof(buffer));
            printf("%s\n", buffer);
        }
    }
}
