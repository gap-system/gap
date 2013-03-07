# Declare the operation for serializable operations.

DeclareOperation("SerializableRepresentation", [ IsObject ]);

BindGlobal("InstallSerializer", function(desc, filters, func)
  InstallMethod(SerializableRepresentation, desc, filters, func);
end);

# A placeholder type for partly deserialized objects.

BindGlobal("UnknownFamily", NewFamily("UnknownFamily", IsObject));
DeclareFilter("IsUnknownObj", IsObject and IsInternalRep);
BindGlobal("TYPE_UNKNOWN", NewType(UnknownFamily, IsUnknownObj));

# Deserializers

BindGlobal("DESERIALIZER", MakeStrictWriteOnceAtomic( rec () ) );

BindGlobal("InstallDeserializer", function(name, func)
  DESERIALIZER.(name) := func;
end);

# Public functions
BindGlobal("SerializeToNativeString", SERIALIZE_TO_NATIVE_STRING);
BindGlobal("DeserializeNativeString", DESERIALIZE_NATIVE_STRING);
