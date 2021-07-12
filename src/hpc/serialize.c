/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "hpc/serialize.h"

#include "bool.h"
#include "calls.h"
#include "error.h"
#include "gvars.h"
#include "modules.h"
#include "objset.h"
#include "plist.h"
#include "precord.h"
#include "rational.h"
#include "records.h"
#include "stringobj.h"
#include "trycatch.h"

#include "hpc/aobjects.h"

#include <stdio.h>

typedef struct SerializerState {
    Obj                   stack;
    Obj    obj;
    UInt   index;
    SerializerInterface * dispatcher;
    Obj    registry;
} SerializerState;

typedef struct DeserializerState {
    Obj                     stack;
    Obj                     obj;
    UInt                    index;
    DeserializerInterface * dispatcher;
} DeserializerState;


#ifndef WARD_ENABLED

static SerializationFunction   SerializationFuncByTNum[256];
static DeserializationFunction DeserializationFuncByTNum[256];


/* Native string serialization */

static void
WriteBytesNativeString(SerializerState * state, void * addr, UInt count)
{
    Obj  target = state->obj;
    UInt size = GET_LEN_STRING(target);
    GROW_STRING(target, size + count + 1);
    memcpy(CSTR_STRING(target) + size, addr, count);
    SET_LEN_STRING(target, size + count);
}

static void WriteTNumNativeString(SerializerState * state, UInt tnum)
{
    UChar buf[1];
    buf[0] = (UChar)tnum;
    WriteBytesNativeString(state, buf, 1);
}

static void WriteByteNativeString(SerializerState * state, UChar byte)
{
    UChar buf[1];
    buf[0] = (UChar)byte;
    WriteBytesNativeString(state, buf, 1);
}

#define ADDR_BYTE(obj) ((UChar *)ADDR_OBJ(obj))

static void WriteByteBlockNativeString(SerializerState * state,
                                       Obj               obj,
                                       UInt              offset,
                                       UInt              len)
{
    WriteBytesNativeString(state, &len, sizeof(len));
    WriteBytesNativeString(state, ADDR_BYTE(obj) + offset, len);
}

static void WriteImmediateObjNativeString(SerializerState * state, Obj obj)
{
    WriteBytesNativeString(state, &obj, sizeof(obj));
}

static SerializerInterface NativeStringSerializer = {
    WriteTNumNativeString,
    WriteByteNativeString,
    WriteByteBlockNativeString,
    WriteImmediateObjNativeString,
};

/* Native string deserialization */

static void
ReadBytesNativeString(DeserializerState * state, void * addr, UInt size)
{
    Obj  str = state->obj;
    UInt max = GET_LEN_STRING(str);
    UInt off = state->index;
    if (off + size > max)
        ErrorQuit("ReadBytesNativeString: Bad deserialization input", 0, 0);
    memcpy(addr, CONST_CSTR_STRING(str) + off, size);
    state->index += size;
}

static UInt ReadTNumNativeString(DeserializerState * state)
{
    UChar buf[1];
    ReadBytesNativeString(state, buf, 1);
    return buf[0];
}

static UChar ReadByteNativeString(DeserializerState * state)
{
    UChar buf[1];
    ReadBytesNativeString(state, buf, 1);
    return buf[0];
}

static UInt ReadByteBlockLengthNativeString(DeserializerState * state)
{
    UInt len;
    ReadBytesNativeString(state, &len, sizeof(len));
    /* The following is to prevent out-of-memory errors on malformed input,
     * where incorrect values can result in huge length values: */
    if (len + state->index > GET_LEN_STRING(state->obj))
        ErrorQuit("ReadByteBlockLengthNativeString: Bad deserialization input", 0, 0);
    return len;
}

static void ReadByteBlockDataNativeString(DeserializerState * state,
                                          Obj                 obj,
                                          UInt                offset,
                                          UInt                len)
{
    ReadBytesNativeString(state, ADDR_BYTE(obj) + offset, len);
}

static Obj ReadImmediateObjNativeString(DeserializerState * state)
{
    Obj obj;
    ReadBytesNativeString(state, &obj, sizeof(obj));
    return obj;
}

static DeserializerInterface NativeStringDeserializer = {
    ReadTNumNativeString,
    ReadByteNativeString,
    ReadByteBlockLengthNativeString,
    ReadByteBlockDataNativeString,
    ReadImmediateObjNativeString,
};

/* Dispatch functions */

static inline void WriteTNum(SerializerState * state, UInt tnum)
{
    state->dispatcher->WriteTNum(state, tnum);
}

static inline void WriteByte(SerializerState * state, UChar byte)
{
    state->dispatcher->WriteByte(state, byte);
}

static inline void
WriteByteBlock(SerializerState * state, Obj obj, UInt offset, UInt len)
{
    state->dispatcher->WriteByteBlock(state, obj, offset, len);
}

static inline void WriteImmediateObj(SerializerState * state, Obj obj)
{
    state->dispatcher->WriteImmediateObj(state, obj);
}

static inline UInt ReadTNum(DeserializerState * state)
{
    return state->dispatcher->ReadTNum(state);
}

static inline UChar ReadByte(DeserializerState * state)
{
    return state->dispatcher->ReadByte(state);
}

static inline UInt ReadByteBlockLength(DeserializerState * state)
{
    return state->dispatcher->ReadByteBlockLength(state);
}

static inline void
ReadByteBlockData(DeserializerState * state, Obj obj, UInt offset, UInt len)
{
    state->dispatcher->ReadByteBlockData(state, obj, offset, len);
}

static inline Obj ReadImmediateObj(DeserializerState * state)
{
    return state->dispatcher->ReadImmediateObj(state);
}

/* Auxiliary serialization/deserialization functions */

static void SerializeBinary(SerializerState * state, Obj obj)
{
    WriteTNum(state, TNUM_OBJ(obj));
    WriteByteBlock(state, obj, 0, SIZE_OBJ(obj));
}

static Obj DeserializeBinary(DeserializerState * state, UInt tnum)
{
    UInt len = ReadByteBlockLength(state);
    Obj  result = NewBag(tnum, len);
    ReadByteBlockData(state, result, 0, len);
    return result;
}

static inline BOOL IsBasicObj(Obj obj)
{
    // FIXME: hard coding T_MACFLOAT like this seems like a bad idea
    return !obj || TNUM_OBJ(obj) <= T_MACFLOAT;
}

#define T_BACKREF 255
#define OBJ_BACKREF(x) ((Obj)((x) << 2))
#define BACKREF_OBJ(obj) (((UInt)(obj)) >> 2)

static int SerializedAlready(SerializerState * state, Obj obj)
{
    Obj ref = LookupObjMap(state->registry, obj);
    if (ref) {
        WriteTNum(state, T_BACKREF);
        WriteImmediateObj(state, OBJ_BACKREF(INT_INTOBJ(ref)));
        return 1;
    }
    else {
        state->index++;
        AddObjMap(state->registry, obj, INTOBJ_INT(state->index));
        return 0;
    }
}

/* TNum-specific serialization/deserialization functions */

static void RegisterSerializerFunctions(UInt                    tnum,
                                        SerializationFunction   sfun,
                                        DeserializationFunction dfun)
{
    SerializationFuncByTNum[tnum] = sfun;
    DeserializationFuncByTNum[tnum] = dfun;
}

static void SerializeObj(SerializerState * state, Obj obj)
{
    if (!obj) {
        /* Handle unbound list elements correctly */
        WriteTNum(state, T_BACKREF);
        WriteImmediateObj(state, INTOBJ_INT(0));
        return;
    }
    SerializationFuncByTNum[TNUM_OBJ(obj)](state, obj);
}

static Obj DeserializeObj(DeserializerState * state)
{
    UInt tnum = ReadTNum(state);
    return DeserializationFuncByTNum[tnum](state, tnum);
}

static void SerializeInt(SerializerState * state, Obj obj)
{
    Int n = INT_INTOBJ(obj);
    WriteTNum(state, T_INT);
    if (n >= -32 && n <= 31) {
        WriteByte(state, ((n + 32) << 2) + 1);
    }
    else if (n >= -8192 && n <= 8191) {
        n += 8192;
        WriteByte(state, ((n >> 8) << 2) + 2);
        WriteByte(state, n & 0xff);
    }
    else {
        WriteByte(state, 0);
        WriteImmediateObj(state, obj);
    }
}

static Obj DeserializeInt(DeserializerState * state, UInt tnum)
{
    Int n = ReadByte(state);
    switch (n & 3) {
    case 1:
        n >>= 2;
        n -= 32;
        return INTOBJ_INT(n);
    case 2:
        n >>= 2;
        n <<= 8;
        n += ReadByte(state);
        n -= 8192;
        return INTOBJ_INT(n);
    default:
        if (n)
            ErrorQuit("DeserializeInt: Bad deserialization input (n = %d)", n, 0);
        return ReadImmediateObj(state);
    }
}

static void SerializeRat(SerializerState * state, Obj obj)
{
    WriteTNum(state, TNUM_OBJ(obj));
    SerializeObj(state, NUM_RAT(obj));
    SerializeObj(state, DEN_RAT(obj));
}

static Obj DeserializeRat(DeserializerState * state, UInt tnum)
{
    Obj result, n, d;
    n = DeserializeObj(state);
    d = DeserializeObj(state);
    result = NewBag(tnum, 2 * sizeof(Obj));
    SET_NUM_RAT(result, n);
    SET_DEN_RAT(result, d);
    return result;
}

static void SerializeFFE(SerializerState * state, Obj obj)
{
    UInt ffe = (UInt)obj;
    WriteTNum(state, T_FFE);
    WriteByte(state, (ffe >> 24) & 0xff);
    WriteByte(state, (ffe >> 16) & 0xff);
    WriteByte(state, (ffe >> 8) & 0xff);
    WriteByte(state, ffe & 0xff);
}

static Obj DeserializeFFE(DeserializerState * state, UInt tnum)
{
    UInt ffe = 0;
    ffe = ReadByte(state);
    ffe <<= 8;
    ffe |= ReadByte(state);
    ffe <<= 8;
    ffe |= ReadByte(state);
    ffe <<= 8;
    ffe |= ReadByte(state);
    return (Obj)ffe;
}

static void SerializeChar(SerializerState * state, Obj obj)
{
    UChar ch = CHAR_VALUE(obj);
    WriteTNum(state, T_CHAR);
    WriteByte(state, ch);
}

static Obj DeserializeChar(DeserializerState * state, UInt tnum)
{
    UChar ch = ReadByte(state);
    return ObjsChar[ch];
}

/* Defines from cyclotom.c: */
#define SIZE_CYC(cyc) (SIZE_OBJ(cyc) / (sizeof(Obj) + sizeof(UInt4)))
#define COEFS_CYC(cyc) (ADDR_OBJ(cyc))
#define EXPOS_CYC(cyc, len) ((UInt4 *)(ADDR_OBJ(cyc) + (len)))

static void SerializeCyc(SerializerState * state, Obj obj)
{
    UInt len, i;
    WriteTNum(state, T_CYC);
    len = SIZE_CYC(obj);
    WriteImmediateObj(state, INTOBJ_INT(len));
    for (i = 0; i < len; i++) {
        SerializeObj(state, COEFS_CYC(obj)[i]);
    }
    for (i = 1; i < len; i++) {
        WriteImmediateObj(state, INTOBJ_INT(EXPOS_CYC(obj, len)[i]));
    }
}

static Obj DeserializeCyc(DeserializerState * state, UInt tnum)
{
    Obj  result;
    UInt i, len;
    len = INT_INTOBJ(ReadImmediateObj(state));
    result = NewBag(T_CYC, len * (sizeof(Obj) + sizeof(UInt4)));
    for (i = 0; i < len; i++)
        COEFS_CYC(result)[i] = DeserializeObj(state);
    for (i = 1; i < len; i++)
        EXPOS_CYC(result, len)[i] = INT_INTOBJ(ReadImmediateObj(state));
    return result;
}

static void SerializeBool(SerializerState * state, Obj obj)
{
    WriteTNum(state, T_BOOL);
    if (obj == False) {
        WriteByte(state, 0);
    }
    else if (obj == True) {
        WriteByte(state, 1);
    }
    else if (obj == Fail) {
        WriteByte(state, 2);
    }
    else
        ErrorQuit("Internal serialization error: Bad boolean value", 0, 0);
}

static Obj DeserializeBool(DeserializerState * state, UInt tnum)
{
    UChar byte = ReadByte(state);
    switch (byte) {
    case 0:
        return False;
    case 1:
        return True;
    case 2:
        return Fail;
    default:
        ErrorQuit("DeserializeBool: Bad deserialization input %d", (Int)byte, 0);
        return (Obj)0; /* flow control hint */
    }
}

static void SerializeList(SerializerState * state, Obj obj)
{
    UInt i, j, len;
    if (SerializedAlready(state, obj))
        return;
    len = LEN_PLIST(obj);
    WriteTNum(state, TNUM_OBJ(obj));
    WriteImmediateObj(state, INTOBJ_INT(len));
    for (i = 1; i <= len; i++) {
        Obj el = ELM_PLIST(obj, i);
        if (IsBasicObj(el))
            SerializeObj(state, el);
        else {
            break;
        }
    }
    for (j = len; j >= i; j--) {
        Obj el = ELM_PLIST(obj, j);
        PushPlist(state->stack, el);
    }
}

static Obj DeserializeList(DeserializerState * state, UInt tnum)
{
    UInt i, len = INT_INTOBJ(ReadImmediateObj(state));
    Obj  result = NEW_PLIST(tnum, len);
    SET_LEN_PLIST(result, len);
    PushPlist(state->stack, result);
    for (i = 1; i <= len; i++)
        SET_ELM_PLIST(result, i, DeserializeObj(state));
    return result;
}

static void SerializeObjSet(SerializerState * state, Obj obj)
{
    UInt i, len;
    if (SerializedAlready(state, obj))
        return;
    len = (UInt)(ADDR_OBJ(obj)[OBJSET_USED]);
    WriteTNum(state, TNUM_OBJ(obj));
    WriteImmediateObj(state, INTOBJ_INT(len));
    len = (UInt)(ADDR_OBJ(obj)[OBJSET_SIZE]);
    for (i = 0; i < len; i++) {
        Obj el = ADDR_OBJ(obj)[OBJSET_HDRSIZE + i];
        if (!el || el == Undefined)
            continue;
        if (IsBasicObj(el))
            SerializeObj(state, el);
        else {
            PushPlist(state->stack, el);
        }
    }
}

static Obj DeserializeObjSet(DeserializerState * state, UInt tnum)
{
    UInt i, len = INT_INTOBJ(ReadImmediateObj(state));
    Obj  result = NewObjSet();
    PushPlist(state->stack, result);
    for (i = 1; i <= len; i++)
        AddObjSet(result, DeserializeObj(state));
    return result;
}

static void SerializeObjMap(SerializerState * state, Obj obj)
{
    UInt i, len;
    if (SerializedAlready(state, obj))
        return;
    len = (UInt)(ADDR_OBJ(obj)[OBJSET_USED]);
    WriteTNum(state, TNUM_OBJ(obj));
    WriteImmediateObj(state, INTOBJ_INT(len));
    len = (UInt)(ADDR_OBJ(obj)[OBJSET_SIZE]);
    for (i = 0; i < len; i++) {
        Obj key = ADDR_OBJ(obj)[OBJSET_HDRSIZE + 2 * i];
        Obj val = ADDR_OBJ(obj)[OBJSET_HDRSIZE + 2 * i + 1];
        if (!key || key == Undefined)
            continue;
        if (IsBasicObj(key) && IsBasicObj(val)) {
            SerializeObj(state, key);
            SerializeObj(state, val);
        }
        else {
            PushPlist(state->stack, val);
            PushPlist(state->stack, key);
        }
    }
}

static Obj DeserializeObjMap(DeserializerState * state, UInt tnum)
{
    UInt i, len = INT_INTOBJ(ReadImmediateObj(state));
    Obj  result = NewObjMap();
    PushPlist(state->stack, result);
    for (i = 1; i <= len; i++) {
        Obj key = DeserializeObj(state);
        Obj val = DeserializeObj(state);
        AddObjMap(result, key, val);
    }
    return result;
}

static void SerializeRecord(SerializerState * state, Obj obj)
{
    UInt i, j, len;
    if (SerializedAlready(state, obj))
        return;
    WriteTNum(state, TNUM_OBJ(obj));
    len = LEN_PREC(obj);
    WriteImmediateObj(state, INTOBJ_INT(len));
    for (i = 1; i <= len; i++) {
        // get the rnam, which may be negative (if the record was sorted)
        Int rnam = GET_RNAM_PREC(obj, i);
        // since rnams can change across sessions, we store only its name
        Obj rnams = NAME_RNAM(rnam >= 0 ? rnam : -rnam);
        WriteByteBlock(state, rnams, sizeof(UInt), GET_LEN_STRING(rnams));
    }
    for (i = 1; i <= len; i++) {
        Obj el = GET_ELM_PREC(obj, i);
        if (IsBasicObj(el))
            SerializeObj(state, el);
        else {
            break;
        }
    }
    for (j = len; j >= i; j--) {
        Obj el = GET_ELM_PREC(obj, j);
        PushPlist(state->stack, el);
    }
}

static Obj DeserializeRecord(DeserializerState * state, UInt tnum)
{
    UInt i, len = INT_INTOBJ(ReadImmediateObj(state));
    Obj  result = NEW_PREC(len);
    Obj  rnams = NEW_STRING(11);
    SET_LEN_PREC(result, len);
    PushPlist(state->stack, result);
    for (i = 1; i <= len; i++) {
        UInt rnam, rnamlen = ReadByteBlockLength(state);
        GROW_STRING(rnams, rnamlen + 1);
        ReadByteBlockData(state, rnams, sizeof(Obj), rnamlen);
        CSTR_STRING(rnams)[rnamlen] = '\0';
        rnam = RNamName(CONST_CSTR_STRING(rnams));
        SET_RNAM_PREC(result, i, rnam);
    }
    for (i = 1; i <= len; i++) {
        Obj el = DeserializeObj(state);
        SET_ELM_PREC(result, i, el);
    }
    SortPRecRNam(result, 0);
    if (tnum == T_PREC + IMMUTABLE)
        RetypeBag(result, tnum);
    return result;
}

static void SerializeString(SerializerState * state, Obj obj)
{
    if (SerializedAlready(state, obj))
        return;
    WriteTNum(state, TNUM_OBJ(obj));
    WriteByteBlock(state, obj, sizeof(UInt), GET_LEN_STRING(obj));
}

static Obj DeserializeString(DeserializerState * state, UInt tnum)
{
    UInt len = ReadByteBlockLength(state);
    Obj  result = NewBag(tnum, SIZEBAG_STRINGLEN(len));
    SET_LEN_STRING(result, len);
    ReadByteBlockData(state, result, sizeof(UInt), len);
    CSTR_STRING(result)[len] = '\0';
    PushPlist(state->stack, result);
    return result;
}

static void SerializeBlist(SerializerState * state, Obj obj)
{
    if (SerializedAlready(state, obj))
        return;
    WriteTNum(state, TNUM_OBJ(obj));
    WriteByteBlock(state, obj, 0, SIZE_OBJ(obj));
}

static Obj DeserializeBlist(DeserializerState * state, UInt tnum)
{
    UInt len = ReadByteBlockLength(state);
    Obj  result = NewBag(tnum, len);
    ReadByteBlockData(state, result, 0, len);
    PushPlist(state->stack, result);
    return result;
}

static void SerializeRange(SerializerState * state, Obj obj)
{
    WriteTNum(state, TNUM_OBJ(obj));
    WriteImmediateObj(state, ADDR_OBJ(obj)[0]);
    WriteImmediateObj(state, ADDR_OBJ(obj)[1]);
    WriteImmediateObj(state, ADDR_OBJ(obj)[2]);
}

static Obj DeserializeRange(DeserializerState * state, UInt tnum)
{
    Obj result, r1, r2, r3;
    r1 = ReadImmediateObj(state);
    r2 = ReadImmediateObj(state);
    r3 = ReadImmediateObj(state);
    result = NewBag(tnum, 3 * sizeof(Obj));
    ADDR_OBJ(result)[0] = r1;
    ADDR_OBJ(result)[1] = r2;
    ADDR_OBJ(result)[2] = r3;
    return result;
}

static GVarDescriptor SerializableRepresentationGVar;
static GVarDescriptor TYPE_UNKNOWN_GVar;
static GVarDescriptor DESERIALIZER_GVar;
static GVarDescriptor SERIALIZATION_TAG_GVar;
static GVarDescriptor DESERIALIZATION_TAG_INT_GVar;
static GVarDescriptor DESERIALIZATION_TAG_STRING_GVar;
static GVarDescriptor SERIALIZATION_UPDATE_TAGS_GVar;
static GVarDescriptor SERIALIZATION_TAGS_NEED_UPDATE_GVar;

static void SerRepError(void)
{
    ErrorQuit("SerializableRepresentation must return a list prefixed by a "
              "string or integer and string",
              0, 0);
}

static Obj PosObjToList(Obj obj)
{
    UInt i, len = SIZE_OBJ(obj) / sizeof(Obj) - 1;
    Obj  result = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(result, len);
    for (i = 1; i <= len; i++)
        SET_ELM_PLIST(result, i, ELM_PLIST(obj, i));
    return result;
}

/**
 *  Serialization of Typed Objects
 *  ------------------------------
 *
 *  Typed objects -- i.e., those with the T_DATOBJ, T_POSOBJ, or T_COMOBJ
 *  types that contain a type object to guide method selection -- require a
 *  special approach to serialization, as we cannot serialize the type objects
 *  themselves. Not only would that add considerable overhead, type objects
 *  are required to be unique for each type.
 *
 *  The easiest way is to associate a globally unique integer or string tag
 *  with each type for which objects need to be serialized. The global
 *  variable `SERIALIZATION_TAG` maps the unique numeric id of each type
 *  object to its corresponding tag. The global variables
 *  `DESERIALIZATION_TAG_INT` and `DESERIALIZATION_TAG_STRING` reverse this
 *  mapping.
 *
 *  It is recommended to use this approach whenever possible, because it is
 *  usually faster than the alternatives.
 *
 *  This mechanism is not always sufficient. For example, objects may contain
 *  attributes that would add excessive extra payload to the serialization
 *  process and may not be properly integrated with global data structures at
 *  the receiving end.
 *
 *  Thus, we also support a more general process to convert an object into a
 *  serializable representation. To that end, one needs to install a method
 *  `SerializableRepresentation` for such a type. This method must return a
 *  list using a specific format.
 *
 */

static Obj LookupIntTag(Obj tag)
{
    Obj map = GVarObj(&DESERIALIZATION_TAG_INT_GVar);
    Obj func = (Obj)0;
    Obj result;
retry:
    switch (map ? TNUM_OBJ(map) : -1) {
    case T_OBJMAP:
    case T_OBJMAP + IMMUTABLE:
        result = LookupObjMap(map, tag);
        if (result || func)
            return result;
        if (GVarObj(&SERIALIZATION_TAGS_NEED_UPDATE_GVar) == False)
            return (Obj)0;
        func = GVarFunction(&SERIALIZATION_UPDATE_TAGS_GVar);
        if (!func)
            return (Obj)0;
        CALL_0ARGS(func);
        map = GVarObj(&DESERIALIZATION_TAG_INT_GVar);
        goto retry; /* more readable than a loop around the switch */
    default:
        ErrorQuit("Deserialization tag map for int tags is corrupted", 0, 0);
        return (Obj)0; /* flow control hint */
    }
}

static Obj DeserializeTypedObj(DeserializerState * state, UInt tnum)
{
    UInt namelen, len, i;
    Obj  name, args, deserialization_rec, func, type, tag;
    Obj  result;
    UInt rnam, tagtnum;
    tagtnum = ReadTNum(state);
    switch (tagtnum) {
    case T_INT:
    case T_STRING:
    case T_STRING + IMMUTABLE:
        if (tagtnum == T_INT) {
            tag = DeserializeInt(state, T_INT);
            type = LookupIntTag(tag);
        }
        else {
            tag = DeserializeString(state, T_STRING);
            rnam = RNamObj(tag);
            type = ELM_REC(GVarObj(&DESERIALIZATION_TAG_STRING_GVar), rnam);
        }
        if (!type || TNUM_OBJ(type) != T_POSOBJ)
            ErrorQuit("DeserializeTypedObj: Failed to deserialize type", 0, 0);
        switch (tnum) {
        case T_DATOBJ:
            len = ReadByteBlockLength(state);
            result = NewBag(T_DATOBJ, len + sizeof(Obj));
            ReadByteBlockData(state, result, sizeof(Obj), len);
            break;
        case T_POSOBJ:
            result = DeserializeObj(state);
            if (!IS_PLIST(result))
                ErrorQuit("DeserializeTypedObj: expected plist, got %s", (Int)TNAM_OBJ(result), 0);
            break;
        case T_PREC:
            result = DeserializeObj(state);
            if (TNUM_OBJ(result) != T_COMOBJ)
                ErrorQuit("DeserializeTypedObj: expected component object, got %s", (Int)TNAM_OBJ(result), 0);
            break;
        default:
            ErrorQuit("DeserializeTypedObj: unexpected tnum %d (%s)", tnum, (Int)TNAM_TNUM(tnum));
            return (Obj)0; /* flow control hint */
        }
        SET_TYPE_OBJ(result, type);
        return result;
    case T_PLIST:
        /* continue on to the more general deserialization method */
        break;
    default:
        ErrorQuit("DeserializeTypedObj: unexpected tagtnum ", tagtnum, (Int)TNAM_TNUM(tagtnum));
        return (Obj)0; /* flow control hint */
    }
    namelen = ReadByteBlockLength(state);
    name = NEW_STRING(namelen);
    ReadByteBlockData(state, name, sizeof(UInt), namelen);
    rnam = RNamName(CONST_CSTR_STRING(name));
    len = INT_INTOBJ(ReadImmediateObj(state));
    args = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(args, len);
    for (i = 1; i <= len; i++) {
        if (ReadByte(state)) {
            Obj  obj;
            UInt blen;
            switch (ReadTNum(state)) {
            case T_DATOBJ:
                blen = ReadByteBlockLength(state);
                obj = NewBag(T_DATOBJ, blen + sizeof(Obj));
                ReadByteBlockData(state, obj, sizeof(Obj), blen);
                SET_TYPE_OBJ(obj, GVarObj(&TYPE_UNKNOWN_GVar));
                break;
            default:
                obj = DeserializeObj(state);
                break;
            }
            SET_ELM_PLIST(args, i, obj);
        }
        else {
            Obj obj = DeserializeObj(state);
            SET_ELM_PLIST(args, i, obj);
        }
    }
    deserialization_rec = GVarObj(&DESERIALIZER_GVar);
    if (!deserialization_rec)
        ErrorQuit("DeserializeTypedObj: failed to retrieve deserialization_rec", 0, 0);
    func = ELM_REC(deserialization_rec, rnam);
    if (!func || TNUM_OBJ(func) != T_FUNCTION)
        ErrorQuit("DeserializeTypedObj: deserialization_rec has bad function", 0, 0);
    result = CallFuncList(func, args);
    return result;
}

static Obj LookupTypeTag(Obj type)
{
    Obj tags = GVarObj(&SERIALIZATION_TAG_GVar);
    Obj func, result;
    if (tags && TNUM_OBJ(tags) == T_OBJMAP) {
        result = LookupObjMap(tags, type);
        if (result)
            return result;
        if (GVarObj(&SERIALIZATION_TAGS_NEED_UPDATE_GVar) == False)
            return (Obj)0;
        func = GVarFunction(&SERIALIZATION_UPDATE_TAGS_GVar);
        if (func)
            CALL_0ARGS(func);
        tags = GVarObj(&SERIALIZATION_TAG_GVar);
        result = LookupObjMap(tags, type);
        return result;
    }
    return (Obj)0;
}

static void SerializeTypedObj(SerializerState * state, Obj obj)
{
    Obj         type, rep, el1, el2, name;
    Int         skip, start, len;
    static char typeerror[] =
        "Serialization has encountered an object with a missing type";
    if (SerializedAlready(state, obj))
        return;
    type = TYPE_OBJ(obj);
    if (!type)
        ErrorQuit(typeerror, 0, 0);
    rep = LookupTypeTag(type);
    if (rep) {
        WriteTNum(state, TNUM_OBJ(obj));
        switch (TNUM_OBJ(rep)) {
        case T_INT:
        case T_STRING:
        case T_STRING + IMMUTABLE:
            SerializeObj(state, rep);
            UInt sp = LEN_PLIST(state->stack);
            switch (TNUM_OBJ(obj)) {
            case T_DATOBJ:
                WriteByteBlock(state, obj, sizeof(Obj),
                               SIZE_OBJ(obj) - sizeof(Obj));
                break;
            case T_POSOBJ:
                SerializeList(state, PosObjToList(obj));
                break;
            case T_COMOBJ:
                SerializeRecord(state, obj);
                break;
            }
            while (LEN_PLIST(state->stack) > sp) {
                SerializeObj(state, PopPlist(state->stack));
            }
            return;
        }
    }
    WriteTNum(state, TNUM_OBJ(obj));
    rep = CALL_1ARGS(GVarFunction(&SerializableRepresentationGVar), obj);
    if (!rep || !IS_PLIST(rep) || LEN_PLIST(rep) == 0) {
        SerRepError();
        return;
    }
    WriteByte(state, T_PLIST);
    el1 = ELM_PLIST(rep, 1);
    len = LEN_PLIST(rep);
    if (len >= 2)
        el2 = ELM_PLIST(rep, 2);
    else
        el2 = 0;
    if (IS_STRING(el1)) {
        skip = 0;
        start = 2;
        name = el1;
    }
    else {
        if (!IS_INTOBJ(el1))
            SerRepError();
        skip = INT_INTOBJ(el1);
        if (skip < 0 || skip + 2 > len)
            SerRepError();
        start = 3;
        name = el2;
        if (!name || !IS_STRING(name))
            SerRepError();
    }
    WriteByteBlock(state, name, sizeof(UInt), GET_LEN_STRING(name));
    WriteImmediateObj(state, INTOBJ_INT(len - start + 1));
    while (start <= len && skip > 0) {
        Obj  el = ELM_PLIST(rep, start);
        UInt sp = LEN_PLIST(state->stack);
        switch (TNUM_OBJ(el)) {
        case T_DATOBJ:
            WriteByte(state, 1);
            WriteTNum(state, T_DATOBJ);
            WriteByteBlock(state, el, sizeof(Obj),
                           SIZE_OBJ(el) - sizeof(Obj));
            break;
        case T_POSOBJ:
            WriteByte(state, 0);
            SerializeList(state, PosObjToList(el));
            break;
        case T_COMOBJ:
            WriteByte(state, 0);
            SerializeRecord(state, el);
            break;
        case T_APOSOBJ:
            WriteByte(state, 0);
            SerializeObj(state, FromAtomicList(el));
            break;
        case T_ACOMOBJ:
            WriteByte(state, 0);
            SerializeObj(state, FromAtomicRecord(el));
            break;
        default:
            WriteByte(state, 0);
            SerializeObj(state, el);
        }
        while (LEN_PLIST(state->stack) > sp) {
            SerializeObj(state, PopPlist(state->stack));
        }
        start++;
        skip--;
    }
    while (start <= len) {
        Obj  el = ELM_PLIST(rep, start);
        UInt sp = LEN_PLIST(state->stack);
        WriteByte(state, 0);
        SerializeObj(state, el);
        while (LEN_PLIST(state->stack) > sp) {
            SerializeObj(state, PopPlist(state->stack));
        }
        start++;
    }
}

static Obj DeserializeBackRef(DeserializerState * state, UInt tnum)
{
    UInt ref = BACKREF_OBJ(ReadImmediateObj(state));
    if (!ref) /* special case for unbound entries */
        return (Obj)0;
    UInt len = LEN_PLIST(state->stack);
    if (ref > len)
        ErrorQuit("DeserializeBackRef: ref %d exceeds stack size %d", ref, len);
    return ELM_PLIST(state->stack, ref);
}

static void SerializeError(SerializerState * state, Obj obj)
{
    ErrorQuit("Cannot serialize objects of type %s, tnum %d", (Int)TNAM_OBJ(obj), (Int)TNUM_OBJ(obj));
}

static Obj DeserializeError(DeserializerState * state, UInt tnum)
{
    ErrorQuit("Cannot deserialize objects of type %s, tnum %d", (Int)TNAM_TNUM(tnum), (Int)tnum);
    return Fail;
}

static Obj FuncSERIALIZE_TO_NATIVE_STRING(Obj self, Obj obj)
{
    SerializerState state;

    state.stack = NEW_PLIST(T_PLIST, 0);
    state.registry = NewObjMap();
    state.dispatcher = &NativeStringSerializer;
    state.obj = NEW_STRING(0);
    state.index = 0;

    SerializeObj(&state, obj);
    while (LEN_PLIST(state.stack) > 0)
        SerializeObj(&state, PopPlist(state.stack));

    return state.obj;
}

static Obj FuncDESERIALIZE_NATIVE_STRING(Obj self, Obj string)
{
    DeserializerState state;

    if (!IS_STRING_REP(string))
        ErrorQuit("DESERIALIZE_NATIVE_STRING: argument must be a string", 0,
                  0);

    state.stack = NEW_PLIST(T_PLIST, 0);
    state.dispatcher = &NativeStringDeserializer;
    state.obj = string;
    state.index = 0;

    return DeserializeObj(&state);
}

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/

static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_1ARGS(SERIALIZE_TO_NATIVE_STRING, obj),
    GVAR_FUNC_1ARGS(DESERIALIZE_NATIVE_STRING, string),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    UInt                 i;

    for (i = 0; i <= T_BACKREF; i++) {
        RegisterSerializerFunctions(i, SerializeError, DeserializeError);
    }

    RegisterSerializerFunctions(T_INT, SerializeInt, DeserializeInt);
    RegisterSerializerFunctions(T_INTPOS, SerializeBinary, DeserializeBinary);
    RegisterSerializerFunctions(T_INTNEG, SerializeBinary, DeserializeBinary);
    RegisterSerializerFunctions(T_RAT, SerializeRat, DeserializeRat);
    RegisterSerializerFunctions(T_CYC, SerializeCyc, DeserializeCyc);
    RegisterSerializerFunctions(T_FFE, SerializeFFE, DeserializeFFE);
    RegisterSerializerFunctions(T_MACFLOAT, SerializeBinary, DeserializeBinary);
    RegisterSerializerFunctions(T_PERM2, SerializeBinary, DeserializeBinary);
    RegisterSerializerFunctions(T_PERM4, SerializeBinary, DeserializeBinary);
    // TODO: add support for T_TRANS2/4, T_PPERM2/4
    RegisterSerializerFunctions(T_BOOL, SerializeBool, DeserializeBool);
    RegisterSerializerFunctions(T_CHAR, SerializeChar, DeserializeChar);

    for (i = FIRST_RECORD_TNUM; i <= LAST_RECORD_TNUM; i++) {
        RegisterSerializerFunctions(i, SerializeRecord, DeserializeRecord);
    }
    for (i = FIRST_PLIST_TNUM; i <= LAST_PLIST_TNUM; i++) {
        RegisterSerializerFunctions(i, SerializeList, DeserializeList);
    }
    for (i = T_RANGE_NSORT; i <= T_RANGE_SSORT + IMMUTABLE; i++) {
        RegisterSerializerFunctions(i, SerializeRange, DeserializeRange);
    }
    for (i = T_BLIST; i <= T_BLIST_SSORT + IMMUTABLE; i++) {
        RegisterSerializerFunctions(i, SerializeBlist, DeserializeBlist);
    }
    for (i = T_STRING; i <= T_STRING_SSORT + IMMUTABLE; i++) {
        RegisterSerializerFunctions(i, SerializeString, DeserializeString);
    }

    RegisterSerializerFunctions(T_OBJSET, SerializeObjSet, DeserializeObjSet);
    RegisterSerializerFunctions(T_OBJMAP, SerializeObjMap, DeserializeObjMap);

    RegisterSerializerFunctions(T_COMOBJ, SerializeTypedObj, DeserializeTypedObj);
    RegisterSerializerFunctions(T_POSOBJ, SerializeTypedObj, DeserializeTypedObj);
    RegisterSerializerFunctions(T_DATOBJ, SerializeTypedObj, DeserializeTypedObj);
    RegisterSerializerFunctions(T_ACOMOBJ, SerializeTypedObj, DeserializeTypedObj);
    RegisterSerializerFunctions(T_APOSOBJ, SerializeTypedObj, DeserializeTypedObj);

    RegisterSerializerFunctions(T_BACKREF, SerializeError, DeserializeBackRef);

    /* gvars */
    DeclareGVar(&SerializableRepresentationGVar,
                "SerializableRepresentation");
    DeclareGVar(&TYPE_UNKNOWN_GVar, "TYPE_UNKNOWN");
    DeclareGVar(&DESERIALIZER_GVar, "DESERIALIZER");
    DeclareGVar(&SERIALIZATION_TAG_GVar, "SERIALIZATION_TAG");
    DeclareGVar(&DESERIALIZATION_TAG_INT_GVar, "DESERIALIZATION_TAG_INT");
    DeclareGVar(&DESERIALIZATION_TAG_STRING_GVar,
                "DESERIALIZATION_TAG_STRING");
    DeclareGVar(&SERIALIZATION_UPDATE_TAGS_GVar, "SERIALIZATION_UPDATE_TAGS");
    DeclareGVar(&SERIALIZATION_TAGS_NEED_UPDATE_GVar,
                "SERIALIZATION_TAGS_NEED_UPDATE");

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable(GVarFuncs);

    return 0;
}

/****************************************************************************
**
*F  InitInfoObjSet() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "serialize",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoSerialize(void)
{
    return &module;
}

#endif
