/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

// LibGAP API - API for using GAP as shared library.

#include <signal.h>

#include "libgap-api.h"
#include "libgap_intern.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "funcs.h"
#include "gap.h"
#include "gapstate.h"
#include "gasman.h"
#ifdef USE_GASMAN
#include "gasman_intern.h"
#endif
#include "gvars.h"
#include "integer.h"
#include "lists.h"
#include "macfloat.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "precord.h"
#include "range.h"
#include "records.h"
#include "streams.h"
#include "stringobj.h"

#include <stdio.h>

static BOOL UsingLibGap = FALSE;

BOOL IsUsingLibGap(void)
{
    return UsingLibGap;
}


//
// Setup and initialisation
//
void GAP_Initialize(int              argc,
                    char **          argv,
                    GAP_CallbackFunc markBagsCallback,
                    GAP_CallbackFunc errorCallback,
                    int              handleSignals)
{
    UsingLibGap = TRUE;

    InitializeGap(&argc, argv, handleSignals);
    SetExtraMarkFuncBags(markBagsCallback);
    STATE(JumpToCatchCallback) = errorCallback;

    GAP_True = True;
    GAP_False = False;
    GAP_Fail = Fail;
}


////
//// Garbage collector interface
////
void GAP_MarkBag(Obj obj)
{
    MarkBag(obj);
}

void GAP_CollectBags(BOOL full)
{
    CollectBags(0, full);
}


////
//// program evaluation and execution
////

Obj GAP_EvalString(const char * cmd)
{
    Obj instream;
    Obj res;
    Obj viewObjFunc, streamFunc;

    streamFunc = GAP_ValueGlobalVariable("InputTextString");
    viewObjFunc = GAP_ValueGlobalVariable("ViewObj");

    instream = DoOperation1Args(streamFunc, MakeString(cmd));
    res = READ_ALL_COMMANDS(instream, False, True, viewObjFunc);
    return res;
}


////
//// variables
////

Obj GAP_ValueGlobalVariable(const char * name)
{
    UInt gvar = GVarName(name);
    GAP_ASSERT(gvar != 0);
    return ValAutoGVar(gvar);
}

int GAP_CanAssignGlobalVariable(const char * name)
{
    UInt gvar = GVarName(name);
    return !(IsReadOnlyGVar(gvar) || IsConstantGVar(gvar));
}

void GAP_AssignGlobalVariable(const char * name, Obj value)
{
    UInt gvar = GVarName(name);
    AssGVar(gvar, value);
}

////
//// arithmetic
////

int GAP_EQ(Obj a, Obj b)
{
    return EQ(a, b);
}

int GAP_LT(Obj a, Obj b)
{
    return LT(a, b);
}

int GAP_IN(Obj a, Obj b)
{
    return IN(a, b);
}

Obj GAP_SUM(Obj a, Obj b)
{
    return SUM(a, b);
}

Obj GAP_DIFF(Obj a, Obj b)
{
    return DIFF(a, b);
}

Obj GAP_PROD(Obj a, Obj b)
{
    return PROD(a, b);
}

Obj GAP_QUO(Obj a, Obj b)
{
    return QUO(a, b);
}

Obj GAP_LQUO(Obj a, Obj b)
{
    return LQUO(a, b);
}

Obj GAP_POW(Obj a, Obj b)
{
    return POW(a, b);
}

Obj GAP_COMM(Obj a, Obj b)
{
    return COMM(a, b);
}

Obj GAP_MOD(Obj a, Obj b)
{
    return MOD(a, b);
}


////
//// booleans
////

Obj GAP_True;
Obj GAP_False;
Obj GAP_Fail;


////
//// calls
////

Obj GAP_CallFuncList(Obj func, Obj args)
{
    return CallFuncList(func, args);
}

Obj GAP_CallFuncArray(Obj func, UInt narg, Obj args[])
{
    Obj result;
    Obj list;

    if (TNUM_OBJ(func) == T_FUNCTION) {

        // call the function
        switch (narg) {
        case 0:
            result = CALL_0ARGS(func);
            break;
        case 1:
            result = CALL_1ARGS(func, args[0]);
            break;
        case 2:
            result = CALL_2ARGS(func, args[0], args[1]);
            break;
        case 3:
            result = CALL_3ARGS(func, args[0], args[1], args[2]);
            break;
        case 4:
            result = CALL_4ARGS(func, args[0], args[1], args[2], args[3]);
            break;
        case 5:
            result =
                CALL_5ARGS(func, args[0], args[1], args[2], args[3], args[4]);
            break;
        case 6:
            result = CALL_6ARGS(func, args[0], args[1], args[2], args[3],
                                args[4], args[5]);
            break;
        default:
            list = NewPlistFromArray(args, narg);
            result = CALL_XARGS(func, list);
        }
    }
    else {
        list = NewPlistFromArray(args, narg);
        result = DoOperation2Args(CallFuncListOper, func, list);
    }

    return result;
}

Obj GAP_CallFunc0Args(Obj func)
{
    Obj result;

    if (TNUM_OBJ(func) == T_FUNCTION) {
        result = CALL_0ARGS(func);
    }
    else {
        Obj list = NewEmptyPlist();
        result = DoOperation2Args(CallFuncListOper, func, list);
    }

    return result;
}

Obj GAP_CallFunc1Args(Obj func, Obj a1)
{
    Obj result;

    if (TNUM_OBJ(func) == T_FUNCTION) {
        result = CALL_1ARGS(func, a1);
    }
    else {
        Obj list = NewPlistFromArgs(a1);
        result = DoOperation2Args(CallFuncListOper, func, list);
    }

    return result;
}

Obj GAP_CallFunc2Args(Obj func, Obj a1, Obj a2)
{
    Obj result;

    if (TNUM_OBJ(func) == T_FUNCTION) {
        result = CALL_2ARGS(func, a1, a2);
    }
    else {
        Obj list = NewPlistFromArgs(a1, a2);
        result = DoOperation2Args(CallFuncListOper, func, list);
    }

    return result;
}

Obj GAP_CallFunc3Args(Obj func, Obj a1, Obj a2, Obj a3)
{
    Obj result;

    if (TNUM_OBJ(func) == T_FUNCTION) {
        result = CALL_3ARGS(func, a1, a2, a3);
    }
    else {
        Obj list = NewPlistFromArgs(a1, a2, a3);
        result = DoOperation2Args(CallFuncListOper, func, list);
    }

    return result;
}


////
//// floats
////

Int GAP_IsMacFloat(Obj obj)
{
    return IS_MACFLOAT(obj);
}

double GAP_ValueMacFloat(Obj obj)
{
    if (!IS_MACFLOAT(obj)) {
        ErrorMayQuit("<obj> is not a MacFloat", 0, 0);
    }
    return (double)VAL_MACFLOAT(obj);
}

Obj GAP_NewMacFloat(double x)
{
    return NEW_MACFLOAT(x);
}


////
//// integers
////

int GAP_IsInt(Obj obj)
{
    return obj && IS_INT(obj);
}

int GAP_IsSmallInt(Obj obj)
{
    return obj && IS_INTOBJ(obj);
}

int GAP_IsLargeInt(Obj obj)
{
    return obj && IS_LARGEINT(obj);
}

Obj GAP_MakeObjInt(const UInt * limbs, Int size)
{
    return MakeObjInt(limbs, size);
}

Obj GAP_NewObjIntFromInt(Int val)
{
    return ObjInt_Int(val);
}

Int GAP_ValueInt(Obj obj)
{
    return Int_ObjInt(obj);
}

Int GAP_SizeInt(Obj obj)
{
    RequireInt("GAP_SizeInt", obj);
    if (obj == INTOBJ_INT(0))
        return 0;
    Int size = (IS_INTOBJ(obj) ? 1 : SIZE_INT(obj));
    return IS_POS_INT(obj) ? size : -size;
}

const UInt * GAP_AddrInt(Obj obj)
{
    if (obj && IS_LARGEINT(obj))
        return CONST_ADDR_INT(obj);
    else
        return 0;
}

////
//// lists
////

int GAP_IsList(Obj obj)
{
    return obj && IS_LIST(obj);
}

UInt GAP_LenList(Obj obj)
{
    return LEN_LIST(obj);
}

void GAP_AssList(Obj list, UInt pos, Obj val)
{
    if (val)
        ASS_LIST(list, pos, val);
    else
        UNB_LIST(list, pos);
}

Obj GAP_ElmList(Obj list, UInt pos)
{
    if (pos == 0)
        return 0;
    return ELM0_LIST(list, pos);
}

Obj GAP_NewPlist(Int capacity)
{
    return NEW_PLIST(T_PLIST_EMPTY, capacity);
}

static BOOL fitsInIntObj(Int i)
{
    return INT_INTOBJ_MIN <= i && i <= INT_INTOBJ_MAX;
}

Obj GAP_NewRange(Int len, Int low, Int inc)
{
    if (!inc) return GAP_Fail;
    if (!fitsInIntObj(len)) return GAP_Fail;
    if (!fitsInIntObj(low)) return GAP_Fail;
    if (!fitsInIntObj(inc)) return GAP_Fail;
    Int high = low + (len - 1) * inc;
    if (!fitsInIntObj(high)) return GAP_Fail;
    return NEW_RANGE(len, low, inc);
}


////
//// matrix obj
////

static Obj IsMatrixOrMatrixObjFilt;
static Obj IsMatrixFilt;
static Obj IsMatrixObjFilt;
static Obj NrRowsAttr;
static Obj NrColsAttr;

// Returns 1 if <obj> is a GAP matrix or matrix obj, 0 if not.
int GAP_IsMatrixOrMatrixObj(Obj obj)
{
    return obj && CALL_1ARGS(IsMatrixOrMatrixObjFilt, obj) == True;
}

// Returns 1 if <obj> is a GAP matrix, 0 if not.
int GAP_IsMatrix(Obj obj)
{
    return obj && CALL_1ARGS(IsMatrixFilt, obj) == True;
}

// Returns 1 if <obj> is a GAP matrix obj, 0 if not.
int GAP_IsMatrixObj(Obj obj)
{
    return obj && CALL_1ARGS(IsMatrixObjFilt, obj) == True;
}

// Returns the number of rows of the given GAP matrix obj.
// If <mat> is not a GAP matrix obj, an error may be raised.
UInt GAP_NrRows(Obj mat)
{
    Obj nrows = CALL_1ARGS(NrRowsAttr, mat);
    return UInt_ObjInt(nrows);
}

// Returns the number of columns of the given GAP matrix or matrix obj.
// If <mat> is not a GAP matrix or matrix obj, an error may be raised.
UInt GAP_NrCols(Obj mat)
{
    Obj ncols = CALL_1ARGS(NrColsAttr, mat);
    return UInt_ObjInt(ncols);
}

// Assign <val> at the <row>, <col> into the GAP matrix or matrix obj <mat>.
// If <val> is zero, then this unbinds the list entry.
// If <mat> is not a GAP matrix or matrix obj, an error may be raised.
void GAP_AssMat(Obj mat, UInt row, UInt col, Obj val)
{
    Obj r = ObjInt_UInt(row);
    Obj c = ObjInt_UInt(col);
    ASS_MAT(mat, r, c, val);
}

// Returns the element at the <row>, <col> in the GAP matrix obj <mat>.
// Returns 0 if <row> or <col> are out of bounds, i.e., if either
// is zero, or larger than the number of rows respectively columns of <mat>.
// If <mat> is not a GAP matrix or matrix obj, an error may be raised.
Obj GAP_ElmMat(Obj mat, UInt row, UInt col)
{
    Obj r = ObjInt_UInt(row);
    Obj c = ObjInt_UInt(col);
    return ELM_MAT(mat, r, c);
}


////
//// records
////

int GAP_IsRecord(Obj obj)
{
    return obj && IS_REC(obj);
}

void GAP_AssRecord(Obj rec, Obj name, Obj val)
{
    UInt rnam = RNamObj(name);
    ASS_REC(rec, rnam, val);
}

Obj GAP_ElmRecord(Obj rec, Obj name)
{
    UInt rnam = RNamObj(name);
    if (ISB_REC(rec, rnam))
        return ELM_REC(rec, rnam);
    return 0;
}

Obj GAP_NewPrecord(Int capacity)
{
    return NEW_PREC(capacity);
}

////
//// strings
////

int GAP_IsString(Obj obj)
{
    return obj && IS_STRING_REP(obj);
}

UInt GAP_LenString(Obj obj)
{
    return GET_LEN_STRING(obj);
}

Obj GAP_MakeString(const char * string)
{
    return MakeString(string);
}

Obj GAP_MakeStringWithLen(const char * string, UInt len)
{
    return MakeStringWithLen(string, len);
}

Obj GAP_MakeImmString(const char * string)
{
    return MakeImmString(string);
}

char * GAP_CSTR_STRING(Obj string)
{
    if (!IS_STRING_REP(string))
        return 0;
    return CSTR_STRING(string);
}

Int GAP_ValueOfChar(Obj obj)
{
    if (TNUM_OBJ(obj) != T_CHAR) {
        return -1;
    }
    return (Int)CHAR_VALUE(obj);
}

Obj GAP_CharWithValue(UChar obj)
{
    return ObjsChar[obj];
}

jmp_buf * GAP_GetReadJmpError(void)
{
    return &(STATE(ReadJmpError));
}


static volatile sig_atomic_t EnterStackCount = 0;
static volatile Int RecursionDepth;


// These are wrapped by the macros GAP_EnterStack() and GAP_LeaveStack()
// respectively.
void GAP_EnterStack_(void * StackTop)
{
    if (EnterStackCount < 0) {
        EnterStackCount = -EnterStackCount;
    }
    else {
        if (EnterStackCount == 0) {
#ifdef USE_GASMAN
            SetStackBottomBags(StackTop);
#endif
        }
        EnterStackCount++;
    }
}

void GAP_LeaveStack_(void)
{
    EnterStackCount--;
}

void GAP_EnterDebugMessage_(char * message, char * file, int line)
{
    fprintf(stderr, "%s: %d; %s:%d\n", message, EnterStackCount, file, line);
}

int GAP_Error_Prejmp_(const char * file, int line)
{
    GAP_ENTER_DEBUG_MESSAGE("Error_Prejmp", file, line);
    if (EnterStackCount > 0) {
        return 1;
    }
    RecursionDepth = GetRecursionDepth();
    return 0;
}

/* Helper function for GAP_Error_Postjmp_ (see libgap-api.h) which manipulates
 * EnterStackCount in the (generally unlikely) case of returning from a
 * longjmp
 */
void GAP_Error_Postjmp_Returning_(void)
{
    /* This only should have been called from the outer-most
     * GAP_EnterStack() call so make sure it resets the EnterStackCount;
     * We set EnterStackCount to its negative which indicates to
     * GAP_EnterStack that we just returned from a long jump and should
     * reset EnterStackCount to its value at the return point rather than
     * increment it again */
    if (EnterStackCount > 0) {
        EnterStackCount = -EnterStackCount;
    }
    SetRecursionDepth(RecursionDepth);
}


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    InitFopyGVar("IsMatrixOrMatrixObj", &IsMatrixOrMatrixObjFilt);
    InitFopyGVar("IsMatrix", &IsMatrixFilt);
    InitFopyGVar("IsMatrixObj", &IsMatrixObjFilt);
    InitFopyGVar("NrRows", &NrRowsAttr);
    InitFopyGVar("NrCols", &NrColsAttr);

    return 0;
}

/****************************************************************************
**
*F  InitInfoLibGapApi() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "libgap",
    .initKernel = InitKernel,
};

StructInitInfo * InitInfoLibGapApi ( void )
{
    return &module;
}
