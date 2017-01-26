## bug 17 for fix 4
gap> f := FreeGroup( 2 );;
gap> g := f/[f.1^4,f.2^4,Comm(f.1,f.2)];;
gap> Length(Elements(g));
16
gap> NrPrimitiveGroups(441);
24
