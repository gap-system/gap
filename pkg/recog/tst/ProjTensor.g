# ProjTensor:
# Usage: ReadPackage("recog","tst/ProjTensor.g");
LoadPackage("recog");
ReadPackage("recog","tst/products.g");
g := GL(4,5);
h := SL(6,5);
k := TensorProductOfMatrixGroup(g,h);
Print("Testing ProjTensor:\n");
RECOG.TestGroup(k,true,Size(PGL(4,5))*Size(PSL(6,5)));
Print("\n");
