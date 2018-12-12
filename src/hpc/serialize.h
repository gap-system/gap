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

#include "system.h"

typedef void (*SerializationFunction)(Obj obj);
typedef Obj (*DeserializationFunction)(UInt tnum);

typedef struct SerializerInterface {
  void (*WriteTNum)(UInt tnum);
  void (*WriteByte)(UChar tnum);
  void (*WriteByteBlock)(Obj obj, UInt offset, UInt len);
  void (*WriteImmediateObj)(Obj obj);
} SerializerInterface;

typedef struct DeserializerInterface {
  UInt (*ReadTNum)(void);
  UChar (*ReadByte)(void);
  UInt (*ReadByteBlockLength)(void);
  void (*ReadByteBlockData)(Obj obj, UInt offset, UInt len);
  Obj (*ReadImmediateObj)(void);
} DeserializerInterface;

StructInitInfo * InitInfoSerialize ( void );

#endif /* GAP_SERIALIZE_H */
