#############################################################################
##
#W  morpheus.tst                GAP tests                    Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  tests the automorphism routines
##

gap> START_TEST("$Id$");

gap> g:=SmallGroup(8,3);;
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
gap> r:=RepresentativeOperation(g,GeneratorsOfGroup(g),List(GeneratorsOfGroup(g),i->Image(iso3,i)),OnTuples);;
gap> r=fail;
false
gap> iso4:=iso3*InnerAutomorphism(g,r^-1);;
gap> iso4=IdentityMapping(g);
true

gap> g:=Group((1,2,3),(4,5,6),(7,8),(9,10),(11,12,13,14,15));
Group( [ (1,2,3), (4,5,6), (7,8), ( 9,10), (11,12,13,14,15) ], ... )
gap> a:=AutomorphismGroup(g);;
gap> Size(a);
1152
gap> Size(DerivedSubgroup(a));
72
gap> p:=IsomorphismPcGroup(a);;
gap> Image(p,a.1);;
gap> Image(p,a.1*a.2);;
gap> Pcgs(a);;

# thats all, folks
gap> STOP_TEST( "morpheus.tst", 1 );

#############################################################################
##
#E  morpheus.tst  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
