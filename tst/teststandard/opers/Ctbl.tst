gap> START_TEST("Ctbl.tst");

#
gap> g:=Group((1,2,3),(1,2));;w:=WreathProductImprimitiveAction(g,g);;
gap> w:=Image(IsomorphismSpecialPcGroup(w));;
gap> Length(ConjugacyClasses(w));
22
gap> Length(Irr(w));
22

#
gap> STOP_TEST("Ctbl.tst",1);
