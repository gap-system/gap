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

#include "libgap-api.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "gap.h"
#include "gapstate.h"
#include "gvars.h"
#include "integer.h"
#include "lists.h"
#include "macfloat.h"
#include "opers.h"
#include "plist.h"
#include "streams.h"
#include "stringobj.h"

//
// Setup and initialisation
//
void GAP_Initialize(int              argc,
                    char **          argv,
                    GAP_CallbackFunc markBagsCallback,
                    GAP_CallbackFunc errorCallback)
{
    InitializeGap(&argc, argv);
    SetExtraMarkFuncBags(markBagsCallback);
    STATE(JumpToCatchCallback) = errorCallback;

    GAP_True = True;
    GAP_False = False;
    GAP_Fail = Fail;
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
    // TODO: GVarName should never return 0?
    if (gvar != 0) {
        return ValGVar(gvar);
    }
    else {
        return NULL;
    }
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
