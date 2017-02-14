## Testing if an element is in a Green's D equivalence class (fix 2 no. 12)
gap> s := Semigroup(Transformation([1,1,3,4]),Transformation([1,2,2,4]));;
gap> dc := GreensDClasses(s);;
gap> ForAll(dc, c->Transformation([1,1,3,4]) in c);
false
