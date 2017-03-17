#############################################################################
##
#W  morpheus.tst                GAP tests                    Alexander Hulpke
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This  file  tests the automorphism routines
##
gap> START_TEST("morpheus.tst");
gap> g:=Group((1,2,3,4),(1,3));;
gap> a:=AutomorphismGroup(g);;
gap> inn:=InnerAutomorphismsAutomorphismGroup(a);;
gap> iso1:=IsomorphismGroups(a,g);;
gap> iso1=fail;
false
gap> iso2:=IsomorphismGroups(g,a);;
gap> iso2=fail;
false
gap> iso3:=iso2*iso1;;
gap> if not iso3 in inn then iso3:=iso3*iso3;fi;
gap> r:=RepresentativeAction(g,GeneratorsOfGroup(g),
>           List(GeneratorsOfGroup(g),i->Image(iso3,i)),OnTuples);;
gap> r=fail;
false
gap> iso4:=iso3*InnerAutomorphism(g,r^-1);;
gap> iso4=IdentityMapping(g);
true
gap> g:=TransitiveGroup(6,7);;
gap> IsSolvableGroup(g);
true
gap> Size(AutomorphismGroup(g));
24
gap> g:=Group((1,2,3),(1,2));;
gap> g:=Image(IsomorphismPcGroup(DirectProduct(g,g,g,g)));;
gap> Size(g);
1296
gap> Size(AutomorphismGroup(g))/Size(g);
24
gap> g:=Group((1,2,3),(4,5,6),(7,8),(9,10),(11,12,13,14,15));
Group([ (1,2,3), (4,5,6), (7,8), (9,10), (11,12,13,14,15) ])
gap> a:=AutomorphismGroup(g);;
gap> Size(a);
1152
gap> Size(DerivedSubgroup(a));
72
gap> p:=IsomorphismPcGroup(a);;
gap> Image(p,a.1);;
gap> Image(p,a.1*a.2);;
gap> Pcgs(a);;
gap> s4 := Group( (3,4), (1,2,3,4) );;
gap> d8 := Subgroup( s4, [ (1,2)(3,4), (1,2,3,4) ] );;
gap> autd8 := AutomorphismGroup( d8 );;
gap> Size(autd8);
8
gap> DisplayCompositionSeries(AutomorphismGroup(SymmetricGroup(3)));
G (size 6)
 | Z(2)
S (1 gens, size 3)
 | Z(3)
1 (size 1)

# that's all, folks
gap> STOP_TEST( "morpheus.tst", 1);

#############################################################################
##
#E
