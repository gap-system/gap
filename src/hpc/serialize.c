#include <src/system.h>
#include <src/gapstate.h>
#include <src/gasman.h>
#include <src/code.h>
#include <src/objects.h>
#include <src/calls.h>
#include <src/gvars.h>
#include <src/bool.h>
#include <src/plist.h>
#include <src/precord.h>
#include <src/records.h>
#include <src/scanner.h>
#include <src/stringobj.h>
#include <src/gap.h>
#include <src/lists.h>
#include <src/hpc/aobjects.h>
#include <src/hpc/tls.h>
#include <src/hpc/serialize.h>
#include <src/objset.h>

#include <string.h>
#include <stdio.h>

#define SERIALIZER ((SerializerInterface *)(STATE(Serialization).dispatcher))

#define DESERIALIZER                                                         \
    ((DeserializerInterface *)(STATE(Serialization).dispatcher))

/**
 *  `POS_NUMB_TYPE`
 *  ---------------
 *
 *  The constant `POS_NUMB_TYPE` must match the definition in lib/type1.g; it
 *  is the offset at which a type's unique numeric id is stored within the
 *  type object.
 */

#define POS_NUMB_TYPE 4


#ifndef WARD_ENABLED

SerializationFunction   SerializationFuncByTNum[256];
DeserializationFunction DeserializationFuncByTNum[256];


static void DeserializationError(void)
{
    ErrorQuit("Bad deserialization input", 0L, 0L);
}

/* Manage serialization state */

void SaveSerializationState(volatile SerializationState * state)
{
    *state = STATE(Serialization);
}

void RestoreSerializationState(volatile SerializationState * state)
{
    STATE(Serialization) = *state;
}


/* Native string serialization */

static void WriteBytesNativeString(void * addr, UInt count)
{
    Obj  target = STATE(Serialization).obj;
    UInt size = GET_LEN_STRING(target);
    GROW_STRING(target, size + count + 1);
    memcpy(CSTR_STRING(target) + size, addr, count);
    SET_LEN_STRING(target, size + count);
}

static void WriteTNumNativeString(UInt tnum)
{
    UChar buf[1];
    buf[0] = (UChar)tnum;
    WriteBytesNativeString(buf, 1);
}

static void WriteByteNativeString(UChar byte)
{
    UChar buf[1];
    buf[0] = (UChar)byte;
    WriteBytesNativeString(buf, 1);
}

#define ADDR_BYTE(obj) ((UChar *)ADDR_OBJ(obj))

static void WriteByteBlockNativeString(Obj obj, UInt offset, UInt len)
{
    WriteBytesNativeString(&len, sizeof(len));
    WriteBytesNativeString(ADDR_BYTE(obj) + offset, len);
}

static void WriteImmediateObjNativeString(Obj obj)
{
    WriteBytesNativeString(&obj, sizeof(obj));
}

static SerializerInterface NativeStringSerializer = {
    WriteTNumNativeString,
    WriteByteNativeString,
    WriteByteBlockNativeString,
    WriteImmediateObjNativeString,
};

static void InitNativeStringSerializer(Obj string)
{
    STATE(Serialization).stack = NEW_PLIST(T_PLIST, 0);
    STATE(Serialization).registry = NewObjMap();
    STATE(Serialization).dispatcher = &NativeStringSerializer;
    STATE(Serialization).obj = string;
    STATE(Serialization).index = 0;
}

/* Native string deserialization */

static void ReadBytesNativeString(void * addr, UInt size)
{
    Obj  str = STATE(Serialization).obj;
    UInt max = GET_LEN_STRING(str);
    UInt off = STATE(Serialization).index;
    if (off + size > max)
        DeserializationError();
    memcpy(addr, CSTR_STRING(str) + off, size);
    STATE(Serialization).index += size;
}

static UInt ReadTNumNativeString(void)
{
    UChar buf[1];
    ReadBytesNativeString(buf, 1);
    return buf[0];
}

static UChar ReadByteNativeString(void)
{
    UChar buf[1];
    ReadBytesNativeString(buf, 1);
    return buf[0];
}

static UInt ReadByteBlockLengthNativeString(void)
{
    UInt len;
    ReadBytesNativeString(&len, sizeof(len));
    /* The following is to prevent out-of-memory errors on malformed input,
     * where incorrect values can result in huge length values: */
    if (len + STATE(Serialization).index >
        GET_LEN_STRING(STATE(Serialization).obj))
        DeserializationError();
    return len;
}

static void ReadByteBlockDataNativeString(Obj obj, UInt offset, UInt len)
{
    ReadBytesNativeString(ADDR_BYTE(obj) + offset, len);
}

static Obj ReadImmediateObjNativeString(void)
{
    Obj obj;
    ReadBytesNativeString(&obj, sizeof(obj));
    return obj;
}

static DeserializerInterface NativeStringDeserializer = {
    ReadTNumNativeString,
    ReadByteNativeString,
    ReadByteBlockLengthNativeString,
    ReadByteBlockDataNativeString,
    ReadImmediateObjNativeString,
};

static void InitNativeStringDeserializer(Obj string)
{
    STATE(Serialization).stack = NEW_PLIST(T_PLIST, 0);
    STATE(Serialization).dispatcher = &NativeStringDeserializer;
    STATE(Serialization).obj = string;
    STATE(Serialization).index = 0;
}

/* Dispatch functions */

static inline void WriteTNum(UInt tnum)
{
    SERIALIZER->WriteTNum(tnum);
}

static inline void WriteByte(UChar byte)
{
    SERIALIZER->WriteByte(byte);
}

static inline void WriteByteBlock(Obj obj, UInt offset, UInt len)
{
    SERIALIZER->WriteByteBlock(obj, offset, len);
}

static inline void WriteImmediateObj(Obj obj)
{
    SERIALIZER->WriteImmediateObj(obj);
}

static inline UInt ReadTNum(void)
{
    return DESERIALIZER->ReadTNum();
}

static inline UChar ReadByte(void)
{
    return DESERIALIZER->ReadByte();
}

static inline UInt ReadByteBlockLength(void)
{
    return DESERIALIZER->ReadByteBlockLength();
}

static inline void ReadByteBlockData(Obj obj, UInt offset, UInt len)
{
    DESERIALIZER->ReadByteBlockData(obj, offset, len);
}

static inline Obj ReadImmediateObj(void)
{
    return DESERIALIZER->ReadImmediateObj();
}

/* Auxiliary serialization/deserialization functions */

static void SerializeBinary(Obj obj)
{
    WriteTNum(TNUM_OBJ(obj));
    WriteByteBlock(obj, 0, SIZE_OBJ(obj));
}

static Obj DeserializeBinary(UInt tnum)
{
    UInt len = ReadByteBlockLength();
    Obj  result = NewBag(tnum, len);
    ReadByteBlockData(result, 0, len);
    return result;
}

static inline int IsBasicObj(Obj obj)
{
    // FIXME: hard coding T_MACFLOAT like this seems like a bad idea
    return !obj || TNUM_OBJ(obj) <= T_MACFLOAT;
}

static inline void PushObj(Obj obj)
{
    Obj  stack = STATE(Serialization).stack;
    UInt len = LEN_PLIST(stack);
    len++;
    GROW_PLIST(stack, len);
    SET_LEN_PLIST(stack, len);
    SET_ELM_PLIST(stack, len, obj);
}

static inline Obj PopObj(void)
{
    Obj  stack = STATE(Serialization).stack;
    UInt len = LEN_PLIST(stack);
    Obj  result = ELM_PLIST(stack, len);
    SET_ELM_PLIST(stack, len, (Obj)0);
    len--;
    SET_LEN_PLIST(stack, len);
    return result;
}

#define T_BACKREF 255
#define OBJ_BACKREF(x) ((Obj)((x) << 2))
#define BACKREF_OBJ(obj) (((UInt)(obj)) >> 2)

int SerializedAlready(Obj obj)
{
    Obj ref = LookupObjMap(STATE(Serialization).registry, obj);
    if (ref) {
        WriteTNum(T_BACKREF);
        WriteImmediateObj(OBJ_BACKREF(INT_INTOBJ(ref)));
        return 1;
    }
    else {
        STATE(Serialization).index++;
        AddObjMap(STATE(Serialization).registry, obj,
                  INTOBJ_INT(STATE(Serialization).index));
        return 0;
    }
}

/* TNum-specific serialization/deserialization functions */

void RegisterSerializerFunctions(UInt                    tnum,
                                 SerializationFunction   sfun,
                                 DeserializationFunction dfun)
{
    SerializationFuncByTNum[tnum] = sfun;
    DeserializationFuncByTNum[tnum] = dfun;
}

void SerializeObj(Obj obj)
{
    if (!obj) {
        /* Handle unbound list elements correctly */
        WriteTNum(T_BACKREF);
        WriteImmediateObj(INTOBJ_INT(0));
        return;
    }
    SerializationFuncByTNum[TNUM_OBJ(obj)](obj);
}

Obj DeserializeObj(void)
{
    UInt tnum = ReadTNum();
    return DeserializationFuncByTNum[tnum](tnum);
}

void SerializeInt(Obj obj)
{
    Int n = INT_INTOBJ(obj);
    WriteTNum(T_INT);
    if (n >= -32 && n <= 31) {
        WriteByte(((n + 32) << 2) + 1);
    }
    else if (n >= -8192 && n <= 8191) {
        n += 8192;
        WriteByte(((n >> 8) << 2) + 2);
        WriteByte(n & 0xff);
    }
    else {
        WriteByte(0);
        WriteImmediateObj(obj);
    }
}

Obj DeserializeInt(UInt tnum)
{
    Int n = ReadByte();
    switch (n & 3) {
    case 1:
        n >>= 2;
        n -= 32;
        return INTOBJ_INT(n);
    case 2:
        n >>= 2;
        n <<= 8;
        n += ReadByte();
        n -= 8192;
        return INTOBJ_INT(n);
    default:
        if (n)
            DeserializationError();
        return ReadImmediateObj();
    }
}

void SerializeFFE(Obj obj)
{
    UInt ffe = (UInt)obj;
    WriteTNum(T_FFE);
    WriteByte((ffe >> 24) & 0xff);
    WriteByte((ffe >> 16) & 0xff);
    WriteByte((ffe >> 8) & 0xff);
    WriteByte(ffe & 0xff);
}

Obj DeserializeFFE(UInt tnum)
{
    UInt ffe = 0;
    ffe = ReadByte();
    ffe <<= 8;
    ffe |= ReadByte();
    ffe <<= 8;
    ffe |= ReadByte();
    ffe <<= 8;
    ffe |= ReadByte();
    return (Obj)ffe;
}

void SerializeChar(Obj obj)
{
    UChar ch = *(char *)ADDR_OBJ(obj);
    WriteTNum(T_CHAR);
    WriteByte(ch);
}

Obj DeserializeChar(UInt tnum)
{
    UChar ch = ReadByte();
    return ObjsChar[ch];
}

/* Defines from cyclotom.c: */
#define SIZE_CYC(cyc) (SIZE_OBJ(cyc) / (sizeof(Obj) + sizeof(UInt4)))
#define COEFS_CYC(cyc) (ADDR_OBJ(cyc))
#define EXPOS_CYC(cyc, len) ((UInt4 *)(ADDR_OBJ(cyc) + (len)))

void SerializeCyc(Obj obj)
{
    UInt len, i;
    WriteTNum(T_CYC);
    len = SIZE_CYC(obj);
    WriteImmediateObj(INTOBJ_INT(len));
    for (i = 0; i < len; i++) {
        SerializeObj(COEFS_CYC(obj)[i]);
    }
    for (i = 1; i < len; i++) {
        WriteImmediateObj(INTOBJ_INT(EXPOS_CYC(obj, len)[i]));
    }
}

Obj DeserializeCyc(UInt tnum)
{
    Obj  result;
    UInt i, len;
    len = INT_INTOBJ(ReadImmediateObj());
    result = NewBag(T_CYC, len * (sizeof(Obj) + sizeof(UInt4)));
    for (i = 0; i < len; i++)
        COEFS_CYC(result)[i] = DeserializeObj();
    for (i = 1; i < len; i++)
        EXPOS_CYC(result, len)[i] = INT_INTOBJ(ReadImmediateObj());
    return result;
}

void SerializeBool(Obj obj)
{
    WriteTNum(T_BOOL);
    if (obj == False) {
        WriteByte(0);
    }
    else if (obj == True) {
        WriteByte(1);
    }
    else if (obj == Fail) {
        WriteByte(2);
    }
    else if (obj == SuPeRfail) {
        WriteByte(3);
    }
    else
        ErrorQuit("Internal serialization error: Bad boolean value", 0L, 0L);
}

Obj DeserializeBool(UInt tnum)
{
    UChar byte = ReadByte();
    switch (byte) {
    case 0:
        return False;
    case 1:
        return True;
    case 2:
        return Fail;
    case 3:
        return SuPeRfail;
    default:
        DeserializationError();
        return (Obj)0; /* flow control hint */
    }
}

void SerializeList(Obj obj)
{
    UInt i, j, len;
    if (SerializedAlready(obj))
        return;
    len = LEN_PLIST(obj);
    WriteTNum(TNUM_OBJ(obj));
    WriteImmediateObj(INTOBJ_INT(len));
    for (i = 1; i <= len; i++) {
        Obj el = ELM_PLIST(obj, i);
        if (IsBasicObj(el))
            SerializeObj(el);
        else {
            break;
        }
    }
    for (j = len; j >= i; j--) {
        Obj el = ELM_PLIST(obj, j);
        PushObj(el);
    }
}

Obj DeserializeList(UInt tnum)
{
    UInt i, len = INT_INTOBJ(ReadImmediateObj());
    Obj  result = NEW_PLIST(tnum, len);
    SET_LEN_PLIST(result, len);
    PushObj(result);
    for (i = 1; i <= len; i++)
        SET_ELM_PLIST(result, i, DeserializeObj());
    return result;
}

void SerializeObjSet(Obj obj)
{
    UInt i, len;
    if (SerializedAlready(obj))
        return;
    len = (UInt)(ADDR_OBJ(obj)[OBJSET_USED]);
    WriteTNum(TNUM_OBJ(obj));
    WriteImmediateObj(INTOBJ_INT(len));
    len = (UInt)(ADDR_OBJ(obj)[OBJSET_SIZE]);
    for (i = 0; i < len; i++) {
        Obj el = ADDR_OBJ(obj)[OBJSET_HDRSIZE + i];
        if (!el || el == Undefined)
            continue;
        if (IsBasicObj(el))
            SerializeObj(el);
        else {
            PushObj(el);
        }
    }
}

Obj DeserializeObjSet(UInt tnum)
{
    UInt i, len = INT_INTOBJ(ReadImmediateObj());
    Obj  result = NewObjSet();
    PushObj(result);
    for (i = 1; i <= len; i++)
        AddObjSet(result, DeserializeObj());
    return result;
}

void SerializeObjMap(Obj obj)
{
    UInt i, len;
    if (SerializedAlready(obj))
        return;
    len = (UInt)(ADDR_OBJ(obj)[OBJSET_USED]);
    WriteTNum(TNUM_OBJ(obj));
    WriteImmediateObj(INTOBJ_INT(len));
    len = (UInt)(ADDR_OBJ(obj)[OBJSET_SIZE]);
    for (i = 0; i < len; i++) {
        Obj key = ADDR_OBJ(obj)[OBJSET_HDRSIZE + 2 * i];
        Obj val = ADDR_OBJ(obj)[OBJSET_HDRSIZE + 2 * i + 1];
        if (!key || key == Undefined)
            continue;
        if (IsBasicObj(key) && IsBasicObj(val)) {
            SerializeObj(key);
            SerializeObj(val);
        }
        else {
            PushObj(val);
            PushObj(key);
        }
    }
}

Obj DeserializeObjMap(UInt tnum)
{
    UInt i, len = INT_INTOBJ(ReadImmediateObj());
    Obj  result = NewObjSet();
    PushObj(result);
    for (i = 1; i <= len; i++) {
        Obj key = DeserializeObj();
        Obj val = DeserializeObj();
        AddObjMap(result, key, val);
    }
    return result;
}

void SerializeRecord(Obj obj)
{
    UInt i, j, len;
    if (SerializedAlready(obj))
        return;
    WriteTNum(TNUM_OBJ(obj));
    len = LEN_PREC(obj);
    WriteImmediateObj(INTOBJ_INT(len));
    for (i = 1; i <= len; i++) {
        UInt rnam = GET_RNAM_PREC(obj, i);
        Obj  rnams = ELM_PLIST(NamesRNam, rnam);
        WriteByteBlock(rnams, sizeof(UInt), GET_LEN_STRING(rnams));
    }
    for (i = 1; i <= len; i++) {
        Obj el = GET_ELM_PREC(obj, i);
        if (IsBasicObj(el))
            SerializeObj(el);
        else {
            break;
        }
    }
    for (j = len; j >= i; j--) {
        Obj el = GET_ELM_PREC(obj, j);
        PushObj(el);
    }
}

Obj DeserializeRecord(UInt tnum)
{
    UInt i, len = INT_INTOBJ(ReadImmediateObj());
    Obj  result = NEW_PREC(len);
    Obj  rnams = NEW_STRING(11);
    SET_LEN_PREC(result, len);
    PushObj(result);
    for (i = 1; i <= len; i++) {
        UInt rnam, rnamlen = ReadByteBlockLength();
        GROW_STRING(rnams, rnamlen + 1);
        ReadByteBlockData(rnams, sizeof(Obj), rnamlen);
        CSTR_STRING(rnams)[rnamlen] = '\0';
        rnam = RNamName(CSTR_STRING(rnams));
        SET_RNAM_PREC(result, i, rnam);
    }
    for (i = 1; i <= len; i++) {
        Obj el = DeserializeObj();
        SET_ELM_PREC(result, i, el);
    }
    SortPRecRNam(result, 1);
    if (tnum == T_PREC + IMMUTABLE)
        RetypeBag(result, tnum);
    return result;
}

void SerializeString(Obj obj)
{
    if (SerializedAlready(obj))
        return;
    WriteTNum(TNUM_OBJ(obj));
    WriteByteBlock(obj, sizeof(UInt), GET_LEN_STRING(obj));
}

Obj DeserializeString(UInt tnum)
{
    UInt len = ReadByteBlockLength();
    Obj  result = NewBag(tnum, SIZEBAG_STRINGLEN(len));
    SET_LEN_STRING(result, len);
    ReadByteBlockData(result, sizeof(UInt), len);
    CSTR_STRING(result)[len] = '\0';
    PushObj(result);
    return result;
}

void SerializeBlist(Obj obj)
{
    if (SerializedAlready(obj))
        return;
    WriteTNum(TNUM_OBJ(obj));
    WriteByteBlock(obj, 0, SIZE_OBJ(obj));
}

Obj DeserializeBlist(UInt tnum)
{
    UInt len = ReadByteBlockLength();
    Obj  result = NewBag(tnum, len);
    ReadByteBlockData(result, 0, len);
    PushObj(result);
    return result;
}

void SerializeRange(Obj obj)
{
    WriteTNum(TNUM_OBJ(obj));
    WriteImmediateObj(ADDR_OBJ(obj)[0]);
    WriteImmediateObj(ADDR_OBJ(obj)[1]);
    WriteImmediateObj(ADDR_OBJ(obj)[2]);
}

Obj DeserializeRange(UInt tnum)
{
    Obj result, r1, r2, r3;
    r1 = ReadImmediateObj();
    r2 = ReadImmediateObj();
    r3 = ReadImmediateObj();
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
              0L, 0L);
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

Obj LookupIntTag(Obj tag)
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
        ErrorQuit("Deserialization tag map for int tags is corrupted", 0L,
                  0L);
        return (Obj)0; /* flow control hint */
    }
}

Obj DeserializeTypedObj(UInt tnum)
{
    UInt namelen, len, i;
    Obj  name, args, deserialization_rec, func, type, tag;
    Obj  result;
    UInt rnam, tagtnum;
    tagtnum = ReadTNum();
    switch (tagtnum) {
    case T_INT:
    case T_STRING:
    case T_STRING + IMMUTABLE:
        if (tagtnum == T_INT) {
            tag = DeserializeInt(T_INT);
            type = LookupIntTag(tag);
        }
        else {
            tag = DeserializeString(T_STRING);
            rnam = RNamObj(tag);
            type = ELM_REC(GVarObj(&DESERIALIZATION_TAG_STRING_GVar), rnam);
        }
        if (!type || TNUM_OBJ(type) != T_POSOBJ)
            DeserializationError();
        switch (tnum) {
        case T_DATOBJ:
            len = ReadByteBlockLength();
            result = NewBag(T_DATOBJ, len + sizeof(Obj));
            ReadByteBlockData(result, sizeof(Obj), len);
            break;
        case T_POSOBJ:
            result = DeserializeObj();
            if (!IS_PLIST(result))
                DeserializationError();
            break;
        case T_PREC:
            result = DeserializeObj();
            if (TNUM_OBJ(result) != T_COMOBJ)
                DeserializationError();
            break;
        default:
            DeserializationError();
            return (Obj)0; /* flow control hint */
        }
        SET_TYPE_OBJ(result, type);
        return result;
    case T_PLIST:
        /* continue on to the more general deserialization method */
        break;
    default:
        DeserializationError();
        return (Obj)0; /* flow control hint */
    }
    namelen = ReadByteBlockLength();
    name = NEW_STRING(namelen);
    ReadByteBlockData(name, sizeof(UInt), namelen);
    rnam = RNamName(CSTR_STRING(name));
    len = INT_INTOBJ(ReadImmediateObj());
    args = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(args, len);
    for (i = 1; i <= len; i++) {
        if (ReadByte()) {
            Obj  obj;
            UInt blen;
            switch (ReadTNum()) {
            case T_DATOBJ:
                blen = ReadByteBlockLength();
                obj = NewBag(T_DATOBJ, blen + sizeof(Obj));
                ReadByteBlockData(obj, sizeof(Obj), blen);
                SET_TYPE_OBJ(obj, GVarObj(&TYPE_UNKNOWN_GVar));
                break;
            default:
                obj = DeserializeObj();
                break;
            }
            SET_ELM_PLIST(args, i, obj);
        }
        else {
            Obj obj = DeserializeObj();
            SET_ELM_PLIST(args, i, obj);
        }
    }
    deserialization_rec = GVarObj(&DESERIALIZER_GVar);
    if (!deserialization_rec)
        DeserializationError();
    func = ELM_REC(deserialization_rec, rnam);
    if (!func || TNUM_OBJ(func) != T_FUNCTION)
        DeserializationError();
    switch (len) {
    case 0:
        result = CALL_0ARGS(func);
        break;
    case 1:
        result = CALL_1ARGS(func, ELM_PLIST(args, 1));
        break;
    case 2:
        result = CALL_2ARGS(func, ELM_PLIST(args, 1), ELM_PLIST(args, 2));
        break;
    case 3:
        result = CALL_3ARGS(func, ELM_PLIST(args, 1), ELM_PLIST(args, 2),
                            ELM_PLIST(args, 3));
        break;
    case 4:
        result = CALL_4ARGS(func, ELM_PLIST(args, 1), ELM_PLIST(args, 2),
                            ELM_PLIST(args, 3), ELM_PLIST(args, 4));
        break;
    case 5:
        result = CALL_5ARGS(func, ELM_PLIST(args, 1), ELM_PLIST(args, 2),
                            ELM_PLIST(args, 3), ELM_PLIST(args, 4),
                            ELM_PLIST(args, 5));
        break;
    case 6:
        result = CALL_6ARGS(func, ELM_PLIST(args, 1), ELM_PLIST(args, 2),
                            ELM_PLIST(args, 3), ELM_PLIST(args, 4),
                            ELM_PLIST(args, 5), ELM_PLIST(args, 6));
        break;
    default:
        result = CALL_XARGS(func, args);
        break;
    }
    return result;
}

Obj LookupTypeTag(Obj type)
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

void SerializeTypedObj(Obj obj)
{
    Obj         type, rep, el1, el2, name;
    Int         skip, start, len;
    static char typeerror[] =
        "Serialization has encountered an object with a missing type";
    if (SerializedAlready(obj))
        return;
    type = *(ADDR_OBJ(obj));
    if (!type)
        ErrorQuit(typeerror, 0L, 0L);
    if ((rep = LookupTypeTag(type))) {
        WriteTNum(TNUM_OBJ(obj));
        switch (TNUM_OBJ(rep)) {
        case T_INT:
        case T_STRING:
        case T_STRING + IMMUTABLE:
            SerializeObj(rep);
            UInt sp = LEN_PLIST(STATE(Serialization).stack);
            switch (TNUM_OBJ(obj)) {
            case T_DATOBJ:
                WriteByteBlock(obj, sizeof(Obj), SIZE_OBJ(obj) - sizeof(Obj));
                break;
            case T_POSOBJ:
                SerializeList(PosObjToList(obj));
                break;
            case T_COMOBJ:
                SerializeRecord(obj);
                break;
            }
            while (LEN_PLIST(STATE(Serialization).stack) > sp) {
                SerializeObj(PopObj());
            }
            return;
        }
    }
    WriteTNum(TNUM_OBJ(obj));
    rep = CALL_1ARGS(GVarFunction(&SerializableRepresentationGVar), obj);
    if (!rep || !IS_PLIST(rep) || LEN_PLIST(rep) == 0) {
        SerRepError();
        return;
    }
    WriteByte(T_PLIST);
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
    WriteByteBlock(name, sizeof(UInt), GET_LEN_STRING(name));
    WriteImmediateObj(INTOBJ_INT(len - start + 1));
    while (start <= len && skip > 0) {
        Obj  el = ELM_PLIST(rep, start);
        UInt sp = LEN_PLIST(STATE(Serialization).stack);
        switch (TNUM_OBJ(el)) {
        case T_DATOBJ:
            WriteByte(1);
            WriteTNum(T_DATOBJ);
            WriteByteBlock(el, sizeof(Obj), SIZE_OBJ(el) - sizeof(Obj));
            break;
        case T_POSOBJ:
            WriteByte(0);
            SerializeList(PosObjToList(el));
            break;
        case T_COMOBJ:
            WriteByte(0);
            SerializeRecord(el);
            break;
        case T_APOSOBJ:
            WriteByte(0);
            SerializeObj(FromAtomicList(el));
            break;
        case T_ACOMOBJ:
            WriteByte(0);
            SerializeObj(FromAtomicRecord(el));
            break;
        default:
            WriteByte(0);
            SerializeObj(el);
        }
        while (LEN_PLIST(STATE(Serialization).stack) > sp) {
            SerializeObj(PopObj());
        }
        start++;
        skip--;
    }
    while (start <= len) {
        Obj  el = ELM_PLIST(rep, start);
        UInt sp = LEN_PLIST(STATE(Serialization).stack);
        WriteByte(0);
        SerializeObj(el);
        while (LEN_PLIST(STATE(Serialization).stack) > sp) {
            SerializeObj(PopObj());
        }
        start++;
    }
}

Obj DeserializeBackRef(UInt tnum)
{
    UInt ref = BACKREF_OBJ(ReadImmediateObj());
    if (!ref) /* special case for unbound entries */
        return (Obj)0;
    if (ref > LEN_PLIST(STATE(Serialization).stack))
        DeserializationError();
    return ELM_PLIST(STATE(Serialization).stack, ref);
}

void SerializeError(Obj obj)
{
    char         buf[16];
    const Char * type = InfoBags[TNUM_OBJ(obj)].name;
    if (!type) {
        sprintf(buf, "<%d>", (int)TNUM_OBJ(obj));
        type = buf;
    }
    ErrorQuit("Cannot serialize object of type %s", (UInt)type, 0L);
}

Obj DeserializeError(UInt tnum)
{
    DeserializationError();
    return Fail;
}

Obj FuncSERIALIZE_NATIVE_STRING(Obj self, Obj obj)
{
    Obj                         result;
    volatile SerializationState state;
    syJmp_buf                   readJmpError;
    SaveSerializationState(&state);
    InitNativeStringSerializer(NEW_STRING(0));
    memcpy(readJmpError, STATE(ReadJmpError), sizeof(syJmp_buf));
    if (sySetjmp(STATE(ReadJmpError))) {
        memcpy(STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf));
        RestoreSerializationState(&state);
        syLongjmp(&(STATE(ReadJmpError)), 1);
    }
    SerializeObj(obj);
    while (LEN_PLIST(STATE(Serialization).stack) > 0)
        SerializeObj(PopObj());
    result = STATE(Serialization).obj;
    memcpy(STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf));
    RestoreSerializationState(&state);
    return result;
}

Obj FuncDESERIALIZE_NATIVE_STRING(Obj self, Obj string)
{
    Obj                         result;
    volatile SerializationState state;
    syJmp_buf                   readJmpError;

    SaveSerializationState(&state);

    if (!IS_STRING(string))
        ErrorQuit("DESERIALIZE_NATIVE_STRING: argument must be a string", 0L,
                  0L);
    memcpy(readJmpError, STATE(ReadJmpError), sizeof(syJmp_buf));
    if (sySetjmp(STATE(ReadJmpError))) {
        memcpy(STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf));
        RestoreSerializationState(&state);
        syLongjmp(&(STATE(ReadJmpError)), 1);
    }
    InitNativeStringDeserializer(string);
    result = DeserializeObj();
    memcpy(STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf));
    RestoreSerializationState(&state);
    return result;
}

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/

static StructGVarFunc GVarFuncs[] = {

    { "SERIALIZE_TO_NATIVE_STRING", 1, "obj", FuncSERIALIZE_NATIVE_STRING,
      "src/objset.c:SERIALIZE_NATIVE_STRING" },

    { "DESERIALIZE_NATIVE_STRING", 1, "string", FuncDESERIALIZE_NATIVE_STRING,
      "src/objset.c:DESERIALIZE_NATIVE_STRING" },

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    UInt                 i;
    static const unsigned char binary_serializable_tnums[] = {
        // FIXME: add T_TRANS2/4, T_PPERM2/4
        T_INTPOS, T_INTNEG, T_RAT, T_PERM2, T_PERM4, T_MACFLOAT
    };
    static const unsigned char typed_serializable_tnums[] = {
        T_DATOBJ, T_POSOBJ, T_COMOBJ, T_APOSOBJ, T_ACOMOBJ
    };
    for (i = 0; i <= T_BACKREF; i++) {
        RegisterSerializerFunctions(i, SerializeError, DeserializeError);
    }
    for (i = 0; i < sizeof(binary_serializable_tnums); i++) {
        RegisterSerializerFunctions(binary_serializable_tnums[i],
                                    SerializeBinary, DeserializeBinary);
    }
    RegisterSerializerFunctions(T_INT, SerializeInt, DeserializeInt);
    RegisterSerializerFunctions(T_FFE, SerializeFFE, DeserializeFFE);
    RegisterSerializerFunctions(T_BOOL, SerializeBool, DeserializeBool);
    RegisterSerializerFunctions(T_CHAR, SerializeChar, DeserializeChar);
    RegisterSerializerFunctions(T_CYC, SerializeCyc, DeserializeCyc);
    for (i = FIRST_PLIST_TNUM; i <= LAST_PLIST_TNUM; i++) {
        RegisterSerializerFunctions(i, SerializeList, DeserializeList);
    }
    for (i = FIRST_RECORD_TNUM; i <= LAST_RECORD_TNUM; i++) {
        RegisterSerializerFunctions(i, SerializeRecord, DeserializeRecord);
    }
    for (i = T_RANGE_NSORT; i < T_BLIST; i++) {
        RegisterSerializerFunctions(i, SerializeRange, DeserializeRange);
    }
    for (i = T_BLIST; i < T_STRING; i++) {
        RegisterSerializerFunctions(i, SerializeBlist, DeserializeBlist);
    }
    for (i = T_STRING; i <= T_STRING_SSORT + IMMUTABLE; i++) {
        RegisterSerializerFunctions(i, SerializeString, DeserializeString);
    }
    for (i = 0; i < sizeof(typed_serializable_tnums); i++) {
        RegisterSerializerFunctions(typed_serializable_tnums[i],
                                    SerializeTypedObj, DeserializeTypedObj);
    }

    RegisterSerializerFunctions(T_OBJSET, SerializeObjSet, DeserializeObjSet);
    RegisterSerializerFunctions(T_OBJMAP, SerializeObjMap, DeserializeObjMap);

    RegisterSerializerFunctions(T_BACKREF, SerializeError,
                                DeserializeBackRef);

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

    /* return success                                                      */
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

    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  InitInfoObjSet() . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN, /* type                           */
    "serialize",    /* name                           */
    0,              /* revision entry of c file       */
    0,              /* revision entry of h file       */
    0,              /* version                        */
    0,              /* crc                            */
    InitKernel,     /* initKernel                     */
    InitLibrary,    /* initLibrary                    */
    0,              /* checkInit                      */
    0,              /* preSave                        */
    0,              /* postSave                       */
    0               /* postRestore                    */
};

StructInitInfo * InitInfoSerialize(void)
{
    return &module;
}

#endif
