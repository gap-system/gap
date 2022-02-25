gap> START_TEST("Matobjnz.tst");

#
gap> p:=NextPrimeInt(MAXSIZE_GF_INTERNAL);;
gap> g:=AlternatingGroup(5);;
gap> mo:=IrreducibleModules(g,GF(p));;
gap> Set(List(mo[2],x->x.dimension));
[ 1, 4, 5, 6 ]
gap> h:=Group(mo[2][2].generators);
<matrix group with 2 generators>
gap> Size(h);
60
gap> Length(ConjugacyClassesSubgroups(h));
9

#
gap> STOP_TEST("Matobjnz.tst",1);
