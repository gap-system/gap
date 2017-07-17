gap> START_TEST("StructuralCopy.tst");

# Blist
gap> a:=[true];; IsBlistRep(a);
true
gap> b:=[a,a];; IsIdenticalObj(b[1],b[2]);
true
gap> c:=StructuralCopy(b);; IsIdenticalObj(c[1],c[2]);
true

# Plist
gap> a:=[1];; IsPlistRep(a);
true
gap> b:=[a,a];; IsIdenticalObj(b[1],b[2]);
true
gap> c:=StructuralCopy(b);; IsIdenticalObj(c[1],c[2]);
true

# String
gap> a:="test";; IsStringRep(a);
true
gap> b:=[a,a];; IsIdenticalObj(b[1],b[2]);
true
gap> c:=StructuralCopy(b);; IsIdenticalObj(c[1],c[2]);
true

#
gap> STOP_TEST("StructuralCopy.tst");
