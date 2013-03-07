l := List([1..6], x -> One(GF(7)) * x);
CONV_VEC8BIT(l, 7);

InstallSerializer("8-bit vectors", [ Is8BitVectorRep ], function(obj)
  return [1, "Vec8Bit", obj, Q_VEC8BIT(obj)];
end);

InstallDeserializer("Vec8Bit", function(obj, q)
  local t;
  t := [ One(GF(q)) ];
  CONV_VEC8BIT(t, q);
  SET_TYPE_OBJ(obj, TYPE_OBJ(t));
  return obj;
end);

s := SerializeToNativeString(l);
d := DeserializeNativeString(s);
Print("Input:  ", l, "\n");
Print("Output: ", d, "\n");
