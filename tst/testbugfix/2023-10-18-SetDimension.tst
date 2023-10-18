# issue reported by Michel Lavrauw on 18 October 2023
gap> LoadPackage("fining",false);
true
gap> G:=ProjectivityGroup(PG(8,2));
The FinInG projectivity group PGL(9,2)
gap> H:=Group(Identity(G));
<projective collineation group with 1 generators>
gap> Size(H); # this used to run into an error
1
gap> IsTrivial(H);
true
gap> IsNonTrivial(H); # this used to return "true"
false
