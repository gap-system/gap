# Larger quotient finder hangs
gap> f:=FreeGroup("F1","F2","F3","F5");;
gap> F1:=f.1;;F2:=f.2;;F3:=F.3;;F5:=F.4;;
gap> rels:=[ F2^4, F3^-2*F2^2, F1^-1*F5*F1*F5^-1, F3^-1*F5^-1*F3*F5, F5^4,
>   F2^-1*F5^-1*F2*F5, F3^-1*F5*F1^-1*F3*F5*F1^-1, F2^2*F1*F3^2*F1^-1,
>   F2*F3^-1*(F2*F3)^2, (F1*F2)^2*F1*F2^-1, F5^2*F1^-6,
>   F3*F2^-1*F1^3*F2*F3^-1*F1^-3 ];;
gap> G:=f/rels;;
gap> perms2:=[(1,2)(3,6,5,4)(7,8,9),(1,2)(3,6,5,4)(7,8)(9,10),
>   (1,2)(3,6,5,4)(7,8)(10,11), (3,4,5,6) ];;
gap> hom:=GroupHomomorphismByImages(G,Group(perms2),
> GeneratorsOfGroup(G),perms2);;
gap> u:=Group([ (8,10)(9,11), (8,10)(9,11), (1,2)(3,4,5,6)(7,8,9,11,10),
>   (1,2), (3,6,5,4) ]);;
gap> v:=LargerQuotientBySubgroupAbelianization(hom,u);
Group(<fp, no generators known>)
gap> w:=Intersection(Kernel(hom),v);
Group(<fp, no generators known>)
gap> Size(Image(DefiningQuotientHomomorphism(w)));
960
