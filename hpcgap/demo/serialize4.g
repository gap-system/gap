InstallSerializer("8-bit vectors", [ Is8BitVectorRep ], function(obj)
  return [1, "Vec8Bit", obj, Q_VEC8BIT(obj), IS_MUTABLE_OBJ(obj)];
end);

InstallDeserializer("Vec8Bit", function(obj, q, mut)
  SET_TYPE_OBJ(obj, TYPE_VEC8BIT(q, mut));
  return obj;
end);

InstallSerializer("8-bit matrices", [ Is8BitMatrixRep ], function(obj)
  return [1, "Mat8Bit", obj, Q_VEC8BIT(obj[1]), IS_MUTABLE_OBJ(obj)];
end);

InstallDeserializer("Mat8Bit", function(obj, q, mut)
  Objectify(TYPE_MAT8BIT(q, mut), obj);
  return obj;
end);

InstallSerializer("GF(2) vectors", [ IsGF2VectorRep ], function(obj)
  return [1, "VecGF2", obj, IS_MUTABLE_OBJ(obj)];
end);

InstallDeserializer("VecGF2", function(obj, mut)
  if mut then
    SET_TYPE_OBJ(obj, TYPE_LIST_GF2VEC);
  else
    SET_TYPE_OBJ(obj, TYPE_LIST_GF2VEC_IMM);
  fi;
  return obj;
end);

InstallSerializer("GF(2) matrices", [ IsGF2MatrixRep ], function(obj)
  return [1, "MatGF2", obj, IS_MUTABLE_OBJ(obj)];
end);

InstallDeserializer("MatGF2", function(obj, mut)
  Objectify(TYPE_LIST_GF2MAT, obj);
  if not mut then
    MakeImmutable(obj);
  fi;
  return obj;
end);

