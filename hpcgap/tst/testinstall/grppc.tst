#############################################################################
##
#W  grppc.tst                 GAP tests                     Alexander Hulpke
##
##
#Y  Copyright (C)  1997
##
##  To be listed in testinstall.g
##
gap> START_TEST("grppc.tst");
gap> h:=Group((1,2,3,4),(1,2));;
gap> m:=IsomorphismPcGroup(h);;
gap> hh:=Image(m,h);;
gap> pcgs:=Pcgs(hh);;
gap> ForAll(pcgs,i->PreImagesRepresentative(m,i) in h);
true
gap> g:=WreathProduct(Group((1,2,3),(1,2)),Group((1,2,3,4,5,6,7)));;
gap> i:=IsomorphismPcGroup(g);;
gap> g:=Range(i);;
gap> u:=Subgroup(g,GeneratorsOfGroup(g){[2..15]});;
gap> n:=Subgroup(g,[g.1]);;
gap> v:=Normalizer(u,n);;
gap> IsSubgroup(u,v);
true
gap> G:=function()
> local g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,r,f,g,rws,x;
> f:=FreeGroup(IsSyllableWordsFamily,14); g:=GeneratorsOfGroup(f);
> g1:=g[1]; g2:=g[2];
> g3:=g[3]; g4:=g[4]; g5:=g[5]; g6:=g[6]; g7:=g[7]; g8:=g[8]; g9:=g[9];
> g10:=g[10]; g11:=g[11]; g12:=g[12]; g13:=g[13]; g14:=g[14];
> rws:=SingleCollector(f,[ 2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2 ]);
> r:=[ [1,g2], ]; for x in r do SetPower(rws,x[1],x[2]);od;
> r:=[ [3,1,g3^2*g4], [4,1,g4^2*g5], [5,1,g5^2*g6], [6,1,g3*g6^2],
> [7,1,g7*g9], [8,1,g8*g10], [9,1,g9*g11], [10,1,g10*g12], [11,1,g11*g13],
> [12,1,g12*g14],[13,1,g7*g13],[14,1,g8*g14], [3,2,g3^2*g5], [4,2,g4^2*g6],
> [5,2,g3*g5^2], [6,2,g4*g6^2], [7,2,g7*g11], [8,2,g8*g12], [9,2,g9*g13],
> [10,2,g10*g14], [11,2,g7*g11], [12,2,g8*g12],[13,2,g9*g13],[14,2,g10*g14],
> [7,3,g7*g8],[8,3,g7],[9,4,g9*g10],[10,4,g9], [11,5,g11*g12], [12,5,g11],
> [13,6,g13*g14], [14,6,g13] ];
> for x in r do SetCommutator(rws,x[1],x[2],x[3]);od;
> return GroupByRwsNC(rws); end;; G:=G();;
gap> gens:=GeneratorsOfGroup(G);;
gap> u:=Group( gens[2], gens[3]*gens[5], gens[4]*gens[6], gens[7], gens[8],
> gens[9], gens[10], gens[11], gens[12], gens[13], gens[14] );;
gap> v:=Group( gens[1], gens[2], gens[3]*gens[5], gens[4]*gens[6],
> gens[7]*gens[11],gens[8]*gens[12],gens[9]*gens[13], gens[10]*gens[14]);;
gap> Intersection(u,v);;
gap> g:=Group((1,15,8,4,14,9)(2,16,7,3,13,10)(5,18,12)(6,17,11),
> (1,3)(2,4)(7,9)(8,10)(13,15)(14,16),
> (1,3,6)(2,4,5)(7,9,12)(8,10,11)(13,15,18)(14,16,17),
> (5,6)(7,8)(9,10)(13,14)(15,16),(1,2)(7,8)(13,14),(1,2)(3,4)(5,6),
> (7,8)(9,10)(11,12),(13,14)(15,16)(17,18));;
gap> cl:=ConjugacyClasses(Image(IsomorphismPcGroup(g),g));;
gap> G := Group( ( 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14), (15,16) );;
gap> sys := SylowSystem( G );;
gap> List( sys, Size );                                                
[ 4, 7 ]
gap> List(sys,i->Length(AsList(i)));
[ 4, 7 ]
gap> G := SmallGroup( 144, 183 );;
gap> F := FittingSubgroup( G );;
gap> S := SylowSubgroup( F, 2 );;
gap> Length(ComplementClassesRepresentatives( G, S ));
1
gap> c:=111738634087016687677581080419779823937672962105281999064930026947977838341505382863502660652163271927890657789545865354105698690880491419382732505129685548945886493976382779091529311779061982182942409366242406420035526825355893426176;
111738634087016687677581080419779823937672962105281999064930026947977838341505\
382863502660652163271927890657789545865354105698690880491419382732505129685548\
945886493976382779091529311779061982182942409366242406420035526825355893426176
gap> PcGroupCode (c, 43008);
<pc group of size 43008 with 13 generators>
gap> G:=
> 62914798297585954914426131977340386523695645250865424229791550956377401783;;
gap> G:=PcGroupCode(G,24570);;
gap> x := G.1*G.3*G.5;;y := x^4;;
gap> RepresentativeAction(G,x,y)=fail;
false
gap> G:=2353881588135032924850825470669869647984062942442421472263823;;
gap> G:=PcGroupCode(G,7938);;                                          
gap> x:=G.3*G.5^2*G.6^3*G.7^3;;
gap> RepresentativeAction(G,x,x^2)<>fail;
true
gap> RepresentativeAction(G,x,x^2);
f1*f2

# that's all, folks
gap> STOP_TEST( "grppc.tst", 3200000);

#############################################################################
##
#E
