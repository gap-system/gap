#############################################################################
##
#W  grppc.tst                 GAP tests                     Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997
##
##

gap> START_TEST("$Id$");
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
gap> local g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,r,f,g,rws,x;
gap> f:=FreeGroup(14); g:=GeneratorsOfGroup(f); g1:=g[1]; g2:=g[2];
gap> g3:=g[3]; g4:=g[4]; g5:=g[5]; g6:=g[6]; g7:=g[7]; g8:=g[8]; g9:=g[9];
gap> g10:=g[10]; g11:=g[11]; g12:=g[12]; g13:=g[13]; g14:=g[14];
gap> rws:=SingleCollector(f,[ 2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2 ]);
gap> r:=[ [1,g2], ]; for x in r do SetPower(rws,x[1],x[2]);od;
gap> r:=[ [3,1,g3^2*g4], [4,1,g4^2*g5], [5,1,g5^2*g6], [6,1,g3*g6^2],
gap> [7,1,g7*g9], [8,1,g8*g10], [9,1,g9*g11], [10,1,g10*g12], [11,1,g11*g13],
gap> [12,1,g12*g14],[13,1,g7*g13],[14,1,g8*g14], [3,2,g3^2*g5], [4,2,g4^2*g6],
gap> [5,2,g3*g5^2], [6,2,g4*g6^2], [7,2,g7*g11], [8,2,g8*g12], [9,2,g9*g13],
gap> [10,2,g10*g14], [11,2,g7*g11], [12,2,g8*g12],[13,2,g9*g13],[14,2,g10*g14],
gap> [7,3,g7*g8],[8,3,g7],[9,4,g9*g10],[10,4,g9], [11,5,g11*g12], [12,5,g11],
gap> [13,6,g13*g14], [14,6,g13] ];
gap> for x in r do SetCommutator(rws,x[1],x[2],x[3]);od;
gap> return GroupByRwsNC(rws); end;; G:=G();;
gap> gens:=GeneratorsOfGroup(G);;
gap> u:=Group( gens[2], gens[3]*gens[5], gens[4]*gens[6], gens[7], gens[8],
gap> gens[9], gens[10], gens[11], gens[12], gens[13], gens[14] );;
gap> v:=Group( gens[1], gens[2], gens[3]*gens[5], gens[4]*gens[6],
gap> gens[7]*gens[11],gens[8]*gens[12],gens[9]*gens[13], gens[10]*gens[14]);;
gap> Intersection(u,v);;
gap> g:=Group((1,15,8,4,14,9)(2,16,7,3,13,10)(5,18,12)(6,17,11),
gap> (1,3)(2,4)(7,9)(8,10)(13,15)(14,16),
gap> (1,3,6)(2,4,5)(7,9,12)(8,10,11)(13,15,18)(14,16,17),
gap> (5,6)(7,8)(9,10)(13,14)(15,16),(1,2)(7,8)(13,14),(1,2)(3,4)(5,6),
gap> (7,8)(9,10)(11,12),(13,14)(15,16)(17,18));;
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
gap> Length(Complementclasses( G, S ));
1

# that's all, folks
gap> STOP_TEST( "grppc.tst", 17634147 );

#############################################################################
##
#E  grppc.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
