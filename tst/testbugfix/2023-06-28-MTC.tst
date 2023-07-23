# Overly eager cyclic replace in MTC, #5467

gap> f := FreeGroup(4);;
gap> g := f / [f.1^2, f.2^2, f.3^2, f.4^2, (f.1*f.4)^2, (f.2*f.4)^2,
> (f.3*f.4)^4, (f.1*f.2)^4, (f.1*f.3)^2, (f.2*f.3)^4, (f.1*f.2*f.3*f.2)^3,
> (f.2*f.3*f.4*f.3)^3];;
gap> h := Subgroup(g, [g.1,g.2,g.3]);;
gap> iso2 := IsomorphismFpGroupByGenerators(h, GeneratorsOfGroup(h));;
gap> h2 := Image(iso2);;
gap> Size(h2);
72
