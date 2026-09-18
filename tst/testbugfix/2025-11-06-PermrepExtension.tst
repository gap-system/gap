# permrep of extension, computed automatically
# See <https://github.com/gap-system/gap/issues/6151>.
gap> G:=Group([(1,2,3),(1,2)(3,4),(1,2)(4,5),(1,2)(5,6), (7,8), (9,10,11) ]);;
gap> F:=GF(5);;
gap> M:=IrreducibleModules(G,F,5)[2][6];;
gap> M2:=rec(field:=F,generators:=List(M.generators,m->DirectSumMat(m,m)));;
gap> ext:=Extensions(G,M2);;
gap> List(ext,Size);
[ 21093750000 ]
