#############################################################################
##
#W  grpmat.tst                  GAP tests                   Heiko Theißen
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("grpmat.tst");
gap> i := E(4);; G := Group([[i,0],[0,-i]],[[0,1],[-1,0]]);;
gap> gens := GeneratorsOfGroup( G );; IsSSortedList( gens );
false
gap> TypeObj( ShallowCopy( gens ) ) = false;
false
gap> SetName( G, "Q8" );
gap> One( TrivialSubgroup( G ) );
[ [ 1, 0 ], [ 0, 1 ] ]
gap> Size( G );
8
gap> IsHandledByNiceMonomorphism( G );
true
gap> pcgs := Pcgs( G );;
gap> Print(pcgs,"\n");
Pcgs([ [ [ 0, 1 ], [ -1, 0 ] ], [ [ E(4), 0 ], [ 0, -E(4) ] ], 
  [ [ -1, 0 ], [ 0, -1 ] ] ])
gap> cl := ConjugacyClasses( G );;
gap> Collected(List(cl,i->[Size(i),Order(Representative(i))]));
[ [ [ 1, 1 ], 1 ], [ [ 1, 2 ], 1 ], [ [ 2, 4 ], 3 ] ]
gap> Set(List( cl, c -> ExponentsOfPcElement( pcgs, Representative( c ) )));
[ [ 0, 0, 0 ], [ 0, 0, 1 ], [ 0, 1, 1 ], [ 1, 0, 1 ], [ 1, 1, 0 ] ]
gap> Size( AutomorphismGroup( G ) );
24
gap> g:=GL(4,3);;
gap> Length(ConjugacyClasses(g));
78
gap> gd:=DerivedSubgroup(g);;
gap> Index(g,gd);
2
gap> Length(ConjugacyClasses(gd));
51
gap> hom:=NaturalHomomorphismByNormalSubgroup(gd,Centre(gd));;
gap> u:=PreImage(hom,SylowSubgroup(Image(hom),3));;
gap> Size(u);
1458
gap> Index(u,DerivedSubgroup(u));
54
gap> g:= DerivedSubgroup( SO( 1, 8, 4 ) );;
gap> Collected( Factors( Size( g ) ) );
[ [ 2, 24 ], [ 3, 5 ], [ 5, 4 ], [ 7, 1 ], [ 13, 1 ], [ 17, 2 ] ]
gap> iso:= IsomorphismPermGroup( g );;
gap> img:=Image( iso );;
gap> Size(img);
67010895544320000
gap> IsNaturalGL( TrivialSubgroup( GL(2,2) ) );
false

# Unbind variables so we can GC memory
gap> Unbind(img); Unbind(iso); Unbind(g); Unbind(hom); Unbind(u);
gap> Unbind(g); Unbind(gd); Unbind(G); Unbind(cl); Unbind(pcgs);
gap> STOP_TEST( "grpmat.tst", 1);

#############################################################################
##
#E
