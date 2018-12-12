#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

# Declare the operation for serializable operations.

DeclareOperation("SerializableRepresentation", [ IsObject ]);

BindGlobal("InstallSerializer", function(desc, filters, func)
  InstallMethod(SerializableRepresentation, desc, filters, func);
end);

BindGlobal("SERIALIZATION_TAG_BASE", 1024);

BindGlobal("SERIALIZATION_TAG_REGION", NewSpecialRegion("Serialization Tags"));

SERIALIZATION_TAG := MakeReadOnlyObj(OBJ_MAP());
BindGlobal("SERIALIZATION_TAG_NEW", OBJ_MAP());
LockAndMigrateObj(SERIALIZATION_TAG_NEW, SERIALIZATION_TAG_REGION);
DESERIALIZATION_TAG_INT := MakeReadOnlyObj(OBJ_MAP());
BindGlobal("DESERIALIZATION_TAG_INT_NEW", OBJ_MAP());
LockAndMigrateObj(DESERIALIZATION_TAG_INT_NEW, SERIALIZATION_TAG_REGION);
BindGlobal("DESERIALIZATION_TAG_STRING", AtomicRecord());

SERIALIZATION_TAGS_NEED_UPDATE := false;

BindGlobal("InstallTypeSerializationTag", function(type, tag)
  atomic SERIALIZATION_TAG_REGION do
    if TNUM_OBJ(tag) = T_INT then
      ADD_OBJ_MAP(DESERIALIZATION_TAG_INT_NEW, tag, type);
      ADD_OBJ_MAP(SERIALIZATION_TAG_NEW, type, tag);
    elif IS_STRING(tag) then
      DESERIALIZATION_TAG_STRING.(tag) := type;
      ADD_OBJ_MAP(SERIALIZATION_TAG_NEW, type, tag);
    else
      Error("Type serialization tag must be integer or string");
    fi;
    SERIALIZATION_TAGS_NEED_UPDATE := true;
  od;
end);

BindGlobal("InstallTypeSerializationTagList", function(typelist, basetag)
  local type, i;
  i := 0;
  atomic SERIALIZATION_TAG_REGION do
    for type in typelist do
      InstallTypeSerializationTag(type,
        basetag + SERIALIZATION_TAG_BASE * i);
      i := i + 1;
    od;
  od;
end);

BindGlobal("SERIALIZATION_UPDATE_TAGS", function()
  atomic SERIALIZATION_TAG_REGION do
    if SERIALIZATION_TAGS_NEED_UPDATE then
      DESERIALIZATION_TAG_INT :=
        MakeReadOnlyObj(StructuralCopy(DESERIALIZATION_TAG_INT_NEW));
      SERIALIZATION_TAG :=
        MakeReadOnlyObj(StructuralCopy(SERIALIZATION_TAG_NEW));
      SERIALIZATION_TAGS_NEED_UPDATE := false;
    fi;
  od;
end);

# A placeholder type for partly deserialized objects.

BindGlobal("UnknownFamily", NewFamily("UnknownFamily", IsObject));
DeclareFilter("IsUnknownObj", IsObject and IsInternalRep and IsInternallyMutable);
BindGlobal("TYPE_UNKNOWN", NewType(UnknownFamily, IsUnknownObj));

# Deserializers

BindGlobal("DESERIALIZER", MakeStrictWriteOnceAtomic( rec () ) );

BindGlobal("InstallDeserializer", function(name, func)
  DESERIALIZER.(name) := func;
end);

# Public functions
BindGlobal("SerializeToNativeString", SERIALIZE_TO_NATIVE_STRING);
BindGlobal("DeserializeNativeString", DESERIALIZE_NATIVE_STRING);

# Predefined serialization tag ranges

BindGlobal("SERIALIZATION_BASE_VEC8BIT", 1);
BindGlobal("SERIALIZATION_BASE_MAT8BIT", 2);
BindGlobal("SERIALIZATION_BASE_GF2VEC", 3);
BindGlobal("SERIALIZATION_BASE_GF2MAT", 4);
