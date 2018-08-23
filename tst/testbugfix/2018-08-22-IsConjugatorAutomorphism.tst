gap> a:=Group((9,11)(10,12)(13,15)(14,16), (1,5,3,7)(2,6,4,8));;
gap> hom:=GroupHomomorphismByImages(a,a,[a.1,a.2*a.1],[a.1,a.2]);;
gap> IsConjugatorAutomorphism(hom);
false
