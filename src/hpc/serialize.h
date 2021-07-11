/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_SERIALIZE_H
#define GAP_SERIALIZE_H

#include "common.h"

typedef struct SerializerState SerializerState;
typedef struct DeserializerState DeserializerState;

typedef void (*SerializationFunction)(SerializerState * state, Obj obj);
typedef Obj (*DeserializationFunction)(DeserializerState * state, UInt tnum);

typedef struct SerializerInterface {
    void (*WriteTNum)(SerializerState * state, UInt tnum);
    void (*WriteByte)(SerializerState * state, UChar tnum);
    void (*WriteByteBlock)(SerializerState * state,
                           Obj               obj,
                           UInt              offset,
                           UInt              len);
    void (*WriteImmediateObj)(SerializerState * state, Obj obj);
} SerializerInterface;


typedef struct DeserializerInterface {
    UInt (*ReadTNum)(DeserializerState * state);
    UChar (*ReadByte)(DeserializerState * state);
    UInt (*ReadByteBlockLength)(DeserializerState * state);
    void (*ReadByteBlockData)(DeserializerState * state,
                              Obj                 obj,
                              UInt                offset,
                              UInt                len);
    Obj (*ReadImmediateObj)(DeserializerState * state);
} DeserializerInterface;

StructInitInfo * InitInfoSerialize(void);

#endif /* GAP_SERIALIZE_H */
