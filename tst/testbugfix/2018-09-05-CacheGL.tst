gap> g:=SL(4,3);;
gap> NiceMonomorphism(g);;
gap> g:=GL(4,3);;
gap> hom:=NiceMonomorphism(g);;
gap> List(GeneratorsOfGroup(g),x->Image(hom,x));;
