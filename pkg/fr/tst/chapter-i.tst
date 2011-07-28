#############################################################################
##
#W  chapter-i.tst                  FR Package               Laurent Bartholdi
##
#H  @(#)$Id: chapter-i.tst,v 1.1 2010/11/01 15:04:59 gap Exp $
##
#Y  Copyright (C) 2010,  Laurent Bartholdi
##
#############################################################################
##
##  This file tests IMG functions
##
#############################################################################

gap> START_TEST("fr:chapter i");
gap> 
gap> Info(InfoFR,1,"Testing Triangulations");
#I Testing Triangulations
gap> if IsBound(MacFloat) then Float := MacFloat; fi;
gap> z := Float(0);; o := Float(1);; m := Float(-1);;
gap> oct := [[o,z,z],[z,o,z],[z,z,o],[m,z,z],[z,m,z],[z,z,m]];;
gap> s := Sqrt(Float(1/3));;
gap> cube := [[s,s,s],[s,s,-s],[s,-s,s],[-s,s,s],[s,-s,-s],[-s,s,-s],[-s,-s,s],[-s,-s,-s]];;
gap> DelaunayTriangulation(cube);
<triangulation with 8 vertices, 36 edges and 12 faces>
gap> DelaunayTriangulation(cube{[1,5]});
<triangulation with 5 vertices, 18 edges and 6 faces>
gap> p := [[z,z,o],[z,z,-o],SphereP1(P1Point(1/1000)),SphereP1(P1Point(0,1000))];
[ [ 0, 0, 1 ], [ 0, 0, -1 ], [ 0.002, 0, 0.999998 ], [ 0, 0.002, -0.999998 ] ]
gap> DelaunayTriangulation(p);
<triangulation with 76 vertices, 444 edges and 148 faces>
gap>
gap> Info(InfoFR,1,"Testing rabbit and z^2+i twists");
#I  Testing rabbit and z^2+i twists
gap> z := Indeterminate(COMPLEX_FIELD,"z":old);;
gap> ri := PolynomialIMGMachine(2,[],[1/6]);
<FR machine with alphabet [ 1, 2 ] and adder f4 on Group( [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>
gap> model := StateSet(ri);
<free group on the generators [ f1, f2, f3, f4 ]>
gap> twist := GroupHomomorphismByImages(model,model,GeneratorsOfGroup(model),[model.1,model.2^(model.3*model.2),model.3^model.2,model.4]);
[ f1, f2, f3, f4 ] -> [ f1, f2^-1*f3^-1*f2*f3*f2, f2^-1*f3*f2, f4 ]
gap>
gap> r := PolynomialIMGMachine(2,[1/7],[]);
<FR machine with alphabet [ 1, 2 ] and adder f4 on Group( [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>
gap> model := StateSet(r);
<free group on the generators [ f1, f2, f3, f4 ]>
gap> twist := GroupHomomorphismByImages(model,model,GeneratorsOfGroup(model),[model.1^(model.2*model.1),model.2^model.1,model.3,model.4]);
[ f1, f2, f3, f4 ] -> [ f1^-1*f2^-1*f1*f2*f1, f1^-1*f2*f1, f3, f4 ]
gap> rt := List([0..4],i->r*twist^i);
[ <FR machine with alphabet [ 1, 2 ] and adder f4 on Group( [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>,
  <FR machine with alphabet [ 1, 2 ] and adder f4 on Group( [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>,
  <FR machine with alphabet [ 1, 2 ] and adder f4 on Group( [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>,
  <FR machine with alphabet [ 1, 2 ] and adder f4 on Group( [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>,
  <FR machine with alphabet [ 1, 2 ] and adder f4 on Group( [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]> 
 ]
gap> m := PolynomialIMGMachine(3,[[3/4,1/12],[1/4,7/12]],[]);
<FR machine with alphabet [ 1, 2, 3 ] and adder f3 on Group( [ f1, f2, f3 ] )/[ f3*f2*f1 ]>
gap>
gap> Info(InfoFR,1,"Testing RationalFunction");
#I  Testing RationalFunction

gap> f := RationalFunction(PolynomialIMGMachine(2,[],[7/16]):param_unicritical);
#I  Spider converged
z^2+(-1.7712570233562493361+I*0.066161509079842548717)
gap>
gap> Info(InfoFR,1,"Testing Pilgrim's obstructed blowup of the torus");
gap> F := FreeGroup("a","b","c","d");
<free group on the generators [ a, b, c, d ]>
gap> AssignGeneratorVariables(F); o := One(F);
#I  Assigned the global variables [ a, b, c, d ]
<identity ...>
gap> M := FRMachine(F,[[c^-1,o,o,o,c],[o,o,o,d,d^-1],[a,o,o,a^-1,o],[b,o,d,a,c]],
>                   [(1,5)(2,4,3),(1,2)(4,5),(1,4)(2,3,5),()]);
<FR machine with alphabet [ 1, 2, 3, 4, 5 ] on Group( [ a, b, c, d ] )>
gap> SetIMGRelator(M,d*c*b*a);
gap> RationalFunction(M);
#I  Testing multicurve [ f3^-1, f3 ] for an obstruction
#I  Thurston matrix is [ [ 1, 0 ], [ 1, 0 ] ]
rec( machine := <FR machine with alphabet [ 1, 2, 3, 4, 5 ] on Group( 
    [ a, b, c, d ] )/[ d*c*b*a ]>, matrix := [ [ 1 ] ], obstruction := [ a*c ], 
  spider := <spider on <triangulation with 6 vertices, 24 edges and 
    8 faces> marked by GroupHomomorphismByImages( Group( [ a, b, c, d ] ), Group( 
    [ f1, f2, f3 ] ), [ a, b, c, d ], [ f3^-1*f2^-1, f1, f2, f2*f3*f1^-1*f2^-1 ] )> )
gap>
gap> Info(InfoFR,1,"Testing mating of airplane with z^2+i");
#I  Testing mating of airplane with z^2+i
gap> m := Mating(PolynomialIMGMachine(2,[3/7],[]),ChangeFRMachineBasis(PolynomialIMGMachine(2,[],[1/6]),(1,2)));
<FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3, g1, g2, g3 ] )/[ f3*f2*f1*g3*g2*g1 ]>
gap> AssignGeneratorVariables(StateSet(m));
#I  Assigned the global variables [ f1, f2, f3, g1, g2, g3 ]
gap> i := FreeGroup("f1","f2","f3","g1","x");
<free group on the generators [ f1, f2, f3, g1, x ]>
gap> m2 := SubFRMachine(ChangeFRMachineBasis(m,[f1^-1*g2,One(StateSet(m))]),
>   GroupHomomorphismByImages(i,StateSet(m),GeneratorsOfGroup(i),[f1^g2,f2,f3,g1,f1*g3/f1*g2]));
<FR machine with alphabet [ 1, 2 ] on Group( [ f1, f2, f3, g1, x ] )/[ f3*f2*x*f1*g1 ]>
gap> RationalFunction(m2);
#I  Spider converged
((1.2124559038021927689-I*0.087764304220948482046)*z^2+(1.964875607954824606+I*1.99403771059344484\
61)*z+(0.9762151209935474501+I*2.3322725352956343962))/((-3.0384469829619939751-I*3.04368905362465\
01179)*z+1)
gap>
gap> Info(InfoFR,1,"Testing a folding");
gap> fold1 := NewIMGMachine("a=<,,b,,,B>(1,2,3)(4,5,6)","b=<,,b*a/b,,,B*A/B>","A=<,,b*a,,,B*A>(3,6)","B=(1,6,5,4,3,2)");;
<FR machine with alphabet [ 1, 2, 3, 4, 5, 6 ] on Group( [ a, b, A, B ] )/[ a*B*A*b ]>
gap>
gap> STOP_TEST( "chapter-i.tst", 3*10^8 );

#E chapter-i.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
