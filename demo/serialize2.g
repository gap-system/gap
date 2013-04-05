ReadGapRoot("demo/serialize4.g");

l := List([1..6], x -> One(GF(7)) * x);
ConvertToVectorRep(l, 7);

l2 := List([1..6], x -> One(GF(2)) * x);
ConvertToVectorRep(l2, 2);

x := One(GF(5));
y := x * 2;

m := [ [ x, y ], [ y, x ] ];
ConvertToMatrixRep(m, 5);

x := One(GF(2));
y := 0 * x;

m2 := [ [ x, y ], [ y, x] ];
ConvertToMatrixRep(m, 2);

for val in [ l, l2, m, m2] do
  s := SerializeToNativeString(val);
  d := DeserializeNativeString(s);
  Print("Input:  ", val, "\n");
  Print("Output: ", d, "\n");
od;
