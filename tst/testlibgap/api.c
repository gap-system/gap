/*
 * Small program to test libgap api functions.
 *
 * Note that we only test whether the API functions
 * work to a reasonable extent, the functionality of 
 * the GAP system is tested in extensive tests of the
 * system itself.
 *
 * TODO: Test error handling
 *
 */
#include "common.h"


void records(void)
{
    Obj r, nam, val, ret;

    r = GAP_NewPrecord(5);
    nam = GAP_MakeString("key");
    val = GAP_MakeString("value");

    assert(GAP_IsRecord(r) != 0);
    assert(GAP_IsRecord(0) == 0);
    assert(GAP_IsRecord(val) == 0);

    GAP_AssRecord(r, nam, val);
    ret = GAP_ElmRecord(r, nam);
    assert(ret == val);

    ret = GAP_ElmRecord(r, val);
    assert(ret == 0);
}

void lists(void)
{
    Obj r, val, val2, ret;

    r = GAP_NewPlist(5);
    val = GAP_MakeString("value");
    val2 = GAP_NewPrecord(5);

    assert(GAP_IsList(r) != 0);
    assert(GAP_IsList(0) == 0);
    assert(GAP_IsList(val2) == 0);

    GAP_AssList(r, 1, val);
    ret = GAP_ElmList(r, 1);
    assert(ret == val);

    ret = GAP_ElmList(r, 2);
    assert(ret == 0);

    GAP_AssList(r, 1, 0);
    ret = GAP_ElmList(r, 1);
    assert(ret == 0);
}

void strings(void)
{
    const char *ts = "Hello, world!";
    Obj r, r2;

    assert(GAP_IsString(0) == 0);

    r = GAP_MakeString(ts);
    assert(GAP_LenString(r) == strlen(ts));
    assert(GAP_IsString(r) != 0);
    assert(strcmp(GAP_CSTR_STRING(r),ts) == 0);

    r2 = GAP_MakeImmString(ts);
    assert(GAP_LenString(r2) == strlen(ts));
    assert(GAP_IsString(r2) != 0);
    assert(strcmp(GAP_CSTR_STRING(r2),ts) == 0);
}

void integers(void)
{
    Obj i1,i2,o;

    o = GAP_MakeString("test");
    assert(GAP_IsInt(o) == 0);
    assert(GAP_IsSmallInt(o) == 0);
    assert(GAP_IsLargeInt(o) == 0);

    const UInt limbs[1] = { 0 };
    i1 = GAP_MakeObjInt(limbs, 1);
    assert(GAP_IsInt(i1) != 0);
    assert(GAP_IsSmallInt(i1) != 0);
    assert(GAP_IsLargeInt(i1) == 0);

    const UInt limbs2[8] = { 1, 1, 1, 1, 1, 1, 1, 1 };
    i2 = GAP_MakeObjInt(limbs2, -8);
    assert(GAP_IsInt(i2) != 0);
    assert(GAP_IsSmallInt(i2) == 0);
    assert(GAP_IsLargeInt(i2) != 0);
    assert(GAP_SizeInt(i2) == -8);

    assert(memcmp(GAP_AddrInt(i2), limbs2, sizeof(UInt) * 8) == 0);
}

void operations(void)
{
    Obj a, b, c, l;

    const UInt limbs[1] = { 1 };
    const UInt limbs2[8] = { 1, 1, 1, 1, 1, 1, 1, 1 };

    // TODO: Should this work?
    c = GAP_MakeObjInt(0, 0);
    a = GAP_MakeObjInt(limbs, 1);
    b = GAP_MakeObjInt(limbs2, -8);
    l = GAP_NewPlist(2);

    assert(GAP_EQ(a, a) != 0);
    assert(GAP_EQ(a, b) == 0);

    assert(GAP_LT(a, b) == 0);
    assert(GAP_LT(b, a) != 0);

    assert(GAP_IN(a, l) == 0);

    assert(GAP_EQ(GAP_SUM(a, b), GAP_SUM(b,a)) != 0);

    // TODO: More sensible test than just executing?
    // TODO: More objects?
    GAP_DIFF(a, b);
    GAP_DIFF(a, c);
    GAP_PROD(a, b);
    GAP_QUO(a, b);
    GAP_LQUO(b, b);
    GAP_POW(b, a);
    GAP_COMM(a, b);

    GAP_MOD(a, b);
}

void globalvars(void)
{
    Obj a;
    int x;

    a = GAP_ValueGlobalVariable("yaddayaddayadda");
    assert(a == 0);

    // Hopefully this always exists.
    a = GAP_ValueGlobalVariable("GAPInfo");
    assert(GAP_IsRecord(a) != 0);

    x = GAP_CanAssignGlobalVariable("GAPInfo");
    assert(x == 0);

    x = GAP_CanAssignGlobalVariable("GAPInfo_copy");
    assert(x != 0);

    GAP_AssignGlobalVariable("GAPInfo_copy", a);
    a = GAP_ValueGlobalVariable("GAPInfo_copy");
    assert(a != 0);
}

int main(int argc, char ** argv)
{
    printf("# Initializing GAP...\n");
    GAP_Initialize(argc, argv, 0, 0, 1);

    printf("# Testing strings... ");
    strings();
    printf("success\n");

    printf("# Testing records... ");
    records();
    printf("success\n");

    printf("# Testing lists... ");
    lists();
    printf("success\n");

    printf("# Testing integers... ");
    integers();
    printf("success\n");

    printf("# Testing operations... ");
    operations();
    printf("success\n");

    printf("# Testing global variables... ");
    globalvars();
    printf("success\n");

    printf("# done\n");
    return 0;
}
