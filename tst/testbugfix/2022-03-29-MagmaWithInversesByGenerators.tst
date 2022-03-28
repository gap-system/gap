# Fix family for MagmaWithInversesByGenerators with empty generators
gap> M1 := MagmaWithInversesByGenerators(FamilyObj( [(1,2)] ), [ ]);
Group(())
gap> M2 := MagmaWithInversesByGenerators(FamilyObj([1]), []);
<trivial group>
gap> One(M2);
1
