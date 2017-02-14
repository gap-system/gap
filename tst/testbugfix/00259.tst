# 2012/09/26 (AH)
gap> p:=7;;
gap> F:=FreeGroup("a","b","c","d","e","f");;
gap> G:=F/[ F.1^p, F.2^p, F.3^p, F.4^p, F.5^p, F.6^p,
> Comm(F.2,F.1)*F.3^-1, Comm(F.3,F.1)*F.4^-1,
> Comm(F.4,F.1)*F.5^-1, Comm(F.4,F.2)*F.6^-1,
> Comm(F.5,F.2)*F.6^-1, Comm(F.4,F.3)*F.6,
> Comm(F.1,F.5), Comm(F.1,F.6), Comm(F.2,F.3),
> Comm(F.2,F.6), Comm(F.3,F.5), Comm(F.3,F.6),
> Comm(F.4,F.5), Comm(F.4,F.6), Comm(F.5,F.6)];;
gap> G:=Image(IsomorphismPermGroup(G));;
gap> DerivedSubgroup(G)=FrattiniSubgroup(G);
true
gap> sd1:=StructureDescription(DerivedSubgroup(G));;
gap> sd2:=StructureDescription(FrattiniSubgroup(G));;
gap> sd1=sd2;
true
