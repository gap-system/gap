# Reported by don't know, # 5609
gap> f := FreeGroup("a", "b", "c", "d", "e");;
gap> a := f.1;;b := f.2;;c := f.3;;d := f.4;;e := f.5;;
gap> g := f / [a^2, b^2, c^2, d^2, e^2, (a*b)^5, (a*c)^2, (a*d)^2, (a*e)^2,
> (b*c)^3, (b*d)^2, (b*e)^2, (c*d)^3, (c*e)^2, (d*e)^3];;
gap> w1 := ElementOfFpGroup(FamilyObj(g.1), a*b*c*d*e);;
gap> w2 := ElementOfFpGroup(FamilyObj(g.1),
> b*a*b*c*b*a*b*a*c*b*a*d*c*e*d*c*b*a*b*a*c*d*e*b*c*a*b*a*b*c*d*c*b*a
> *b*c*a*b*a*b*c);;
gap> w3 := ElementOfFpGroup(FamilyObj(g.1),
> b*a*b*c*b*a*d*c*b*a*b*a*c*b*a*d*e*d*c*b*a*b*c*d*e*a*b*a*b*c*d*b*a*b
> *c*a*b*a*b*c*d*c*b);;
gap> w4 := ElementOfFpGroup(FamilyObj(g.1),
> b*c*b*a*b*a*d*c*b*a*b*a*c*b*a*b*c*d*c*b*a*b*a*c*d*b*c*a*b*a*b*c*d*e
> *b*c*a*b*a*b*c*d*b*a*b*c*a*b);;
gap> w5 := ElementOfFpGroup(FamilyObj(g.1),
> b*a*b*a*c*d*c*b*a*b*a*c*b*a*d*c*b*a*b*c*d*e*d*c*b*a*b*c*d*a*b*c*a*b
> *a*b*c*d*e*b*a*b*c*d*b*c*a*b*a*b*c);;
gap> s := Subgroup(g, [w1, w2, w3, w4, w5]);;
gap> s1 := Subgroup(g, [w1, w2^-2, w3*w2^-1, w3^-1*w2^-1, w4*w2^-1,
> w4^-1*w2^-1, w5*w2^-1, w5^-1*w2^-1]);;
gap> s2:=Subgroup(g,[w1^-2, w2, w3, w4*w1^-1, w1*w2*w1^-1, w1*w3*w1^-1, w5]);;
gap> ab := MaximalAbelianQuotient(s);;
gap> q1 := GQuotients(s1, SymmetricGroup(2));;
gap> q2 := GQuotients(s2, SymmetricGroup(2));;
gap> k1 := Kernel(q1[7]);;
gap> nr:=First(Concatenation([7],[1..Length(q2)]),x->Kernel(q2[x])=k1);;
gap> k2 := Kernel(q2[nr]);;
gap> k1=k2;
true
gap> Image(ab,k1)=Image(ab,k2);
true
