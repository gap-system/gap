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

#include <intobj.h>


void records(void)
{
    Obj r, nam, val, ret;

    r = GAP_NewPrecord(5);
    nam = GAP_MakeString("key");
    val = GAP_MakeString("value");

    assert(GAP_IsRecord(r));
    assert(!GAP_IsRecord(0));
    assert(!GAP_IsRecord(val));

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

    assert(GAP_IsList(r));
    assert(!GAP_IsList(0));
    assert(!GAP_IsList(val2));

    GAP_AssList(r, 1, val);
    ret = GAP_ElmList(r, 1);
    assert(ret == val);

    ret = GAP_ElmList(r, 2);
    assert(ret == 0);

    GAP_AssList(r, 1, 0);
    ret = GAP_ElmList(r, 1);
    assert(ret == 0);
}

void matrices(void)
{
    Obj mat, val, row, ret;

    mat = GAP_NewPlist(1);
    val = INTOBJ_INT(42);

    assert(!GAP_IsMatrixObj(mat));   // empty list, not yet a matrix
    assert(!GAP_IsMatrixObj(0));
    assert(!GAP_IsMatrixObj(val));

    row = GAP_NewPlist(2);
    GAP_AssList(row, 1, INTOBJ_INT(1));
    GAP_AssList(row, 2, INTOBJ_INT(2));
    GAP_AssList(mat, 1, row);
    assert(!GAP_IsMatrixObj(row));
    assert(GAP_IsMatrixObj(mat));

    GAP_AssMat(mat, 1, 1, val);
    ret = GAP_ElmMat(mat, 1, 1);
    assert(ret == val);
}

void strings(void)
{
    const char *ts = "Hello, world!";
    Obj r, r2;

    assert(!GAP_IsString(0));

    r = GAP_MakeString(ts);
    assert(GAP_LenString(r) == strlen(ts));
    assert(GAP_IsString(r));
    assert(strcmp(GAP_CSTR_STRING(r),ts) == 0);

    r2 = GAP_MakeImmString(ts);
    assert(GAP_LenString(r2) == strlen(ts));
    assert(GAP_IsString(r2));
    assert(strcmp(GAP_CSTR_STRING(r2),ts) == 0);
}

void integers(void)
{
    Obj i1,i2,o;

    o = GAP_MakeString("test");
    assert(!GAP_IsInt(o));
    assert(!GAP_IsSmallInt(o));
    assert(!GAP_IsLargeInt(o));

    const UInt limbs[1] = { 0 };
    i1 = GAP_MakeObjInt(limbs, 1);
    assert(GAP_IsInt(i1));
    assert(GAP_IsSmallInt(i1));
    assert(!GAP_IsLargeInt(i1));

    const UInt limbs2[8] = { 1, 1, 1, 1, 1, 1, 1, 1 };
    i2 = GAP_MakeObjInt(limbs2, -8);
    assert(GAP_IsInt(i2));
    assert(!GAP_IsSmallInt(i2));
    assert(GAP_IsLargeInt(i2));
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

    assert(GAP_EQ(a, a));
    assert(!GAP_EQ(a, b));

    assert(!GAP_LT(a, b));
    assert(GAP_LT(b, a));

    assert(!GAP_IN(a, l));

    assert(GAP_EQ(GAP_SUM(a, b), GAP_SUM(b,a)));

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
    assert(GAP_IsRecord(a));

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

    printf("# Testing matrices... ");
    matrices();
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
