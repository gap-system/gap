ReadGapRoot("demo/bench.g");
m := List([1..1000], l->List([1..1000], x -> x+l));

# Declare globals
s := fail;
m2 := fail;

tser := Bench(do s := SerializeToNativeString(m); od);
tdes := Bench(do m2 := DeserializeNativeString(s); od);

Print("Serialization/Deserialization of a 1000x1000 integer matrix\n");
Print("Output length:   ", Length(s), "\n");
Print("Serialization:   ", tser, " seconds\n");
Print("Deserialization: ", tdes, " seconds\n");

