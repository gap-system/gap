gap> START_TEST("SubdirectProduct.tst");
gap> f:=FreeGroup("a", "b");;
gap> g:=f/[ f.1^6, f.2^4, f.1^3*f.2^(-2), f.2^(-1)*f.1*f.2*f.1];;
gap> Size(g);
12
gap> g0:=Subgroup(g, [g.1^2]);;
gap> g1:=g/g0;;
gap> ff:=FreeGroup("c");;
gap> h:=ff/[ff.1^12];;
gap> Size(h);
12
gap> h0:=Subgroup(h,[h.1^4]);;
gap> h1:=h/h0;;
gap> ng:=NaturalHomomorphismByNormalSubgroup(g,g0);;
gap> nh:=NaturalHomomorphismByNormalSubgroup(h,h0);;
gap> phi:=IsomorphismGroups(g1,h1);;
gap> ghom:=CompositionMapping(phi, ng);;
gap> hhom:=nh;;
gap> nn:=SubdirectProduct(g,h,ghom,hhom);;
gap> Size(nn);
36
gap> Projection(nn,1);
[ f1, f2, f3, f4 ] -> [ b, a^9, a^4, <identity ...> ]
gap> Projection(nn,2);
[ f1, f2, f3, f4 ] -> [ c^9, c^6, <identity ...>, c^4 ]
gap> STOP_TEST("SubdirectProduct.tst", 10000);
