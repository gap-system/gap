#############################################################################
##
#W  chapter-9.tst                  FR Package               Laurent Bartholdi
##
#H  @(#)$Id: chapter-9.tst,v 1.2 2011/09/20 11:45:35 gap Exp $
##
#Y  Copyright (C) 2011,  Laurent Bartholdi
##
#############################################################################
##
##  This file tests the functions explained in chapter 9 of the manual
##
#############################################################################

gap> START_TEST("fr:chapter 9");
gap> 
gap> Info(InfoFR,1,"9.2 Supporting rays");
#I  9.2 Supporting rays
gap> e := EquivalenceRelationPartition(ExternalAnglesRelation(2,5));
[ [ 1/31, 2/31 ], [ 1/15, 2/15 ], [ 3/31, 4/31 ], [ 1/7, 2/7 ],
  [ 5/31, 6/31 ], [ 1/5, 4/15 ], [ 7/31, 8/31 ], [ 9/31, 10/31 ],
  [ 1/3, 2/3 ], [ 11/31, 12/31 ], [ 2/5, 3/5 ], [ 13/31, 18/31 ],
  [ 3/7, 4/7 ], [ 14/31, 17/31 ], [ 7/15, 8/15 ], [ 15/31, 16/31 ],
  [ 19/31, 20/31 ], [ 21/31, 22/31 ], [ 5/7, 6/7 ], [ 11/15, 4/5 ],
  [ 23/31, 24/31 ], [ 25/31, 26/31 ], [ 13/15, 14/15 ], [ 27/31, 28/31 ],
  [ 29/31, 30/31 ] ]
gap> ForAll(e,p->SupportingRays(PolynomialIMGMachine(2,[p[1]]))[2][1][1]*2 in [p[1],p[2],p[1]+1,p[2]+1]);
true
gap> 
gap> Info(InfoFR,1,"Shishikura-Tan Lei matings");
#I  Shishikura-Tan Lei matings
gap> SetFloats(IEEE754FLOAT);
gap> z := Indeterminate(COMPLEX_FIELD,"z" : old);
z
gap> a := ComplexRootsOfUnivariatePolynomial((z-1)*(3*z^2-2*z^3)+1);
[ 0.598631+I*0.565259, -0.426536+I*5.55112e-17, 0.598631-I*0.565259, 1.72927 ]
gap> c := ComplexRootsOfUnivariatePolynomial((z^3+z)^3+z);
[ 0., 0.557573+I*0.540347, -0.557573+I*0.540347, -0.557573-I*0.540347,
  0.557573-I*0.540347, 0.264425+I*1.26049, -0.264425+I*1.26049,
  -0.264425-I*1.26049, 0.264425-I*1.26049 ]
gap> am := List(a,a->IMGMachine((a-1)*(3*z^2-2*z^3)+1));
[ <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f3*f2*f1*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f2*f3*f1*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f3*f2*f1*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f3*f1*f2*f4 ]> ]
gap> cm := List(c,c->IMGMachine(z^3+c));
[ <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f2) on Group(
    [ f1, f2 ] )/[ f1*f2 ]>,
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group( 
    [ f1, f2, f3, f4 ] )/[ f3*f1*f2*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f3*f1*f2*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f3*f1*f2*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f3*f1*f2*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f1*f3*f2*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f1*f3*f2*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f1*f3*f2*f4 ]>, 
  <FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f1*f3*f2*f4 ]> ]
gap> m := ListX(am,cm,Mating);;
gap> RationalFunction(NewIMGMachine(am[2]));
1.2169361217367749*z^3+(-2.7949976186160654)*z^2+1.531166437137724
gap> RationalFunction(m[9+2]);
((0.20737809489211967+I*0.059903784202786192)*z^3+(0.50320902396568734+I*1.041\
8883912544126)*z^2+(0.67159729963052428+I*0.52974076487884736)*z+(-1.269818894\
5582305-I*1.962281157501601))/((0.41095999268340794+I*0.053341010580933532)*z^\
3+(1.258046841995262+I*1.8307350984983999)*z^2+(1.4285826192918973+I*0.8098658\
3790292765)*z+1.)
gap> 
gap> Info(InfoFR,1,"An obstructed mating");
#I  An obstructed mating
gap> RationalFunction(m[9+8]);
rec( machine := <FR machine with alphabet [ 1 .. 3 ] on Group(
    [ f1, f2, f3, g1, g2, g3 ] )/[ f2*f3*f1*g1*g3*g2 ]>,
  matrix := [ [ 1/2, 1 ], [ 1/2, 0 ] ], obstruction := [ f1*g1, f2^-1*g2^-1 ], 
  spider := <marked sphere on <triangulation with 9 vertices, 42 edges and 14 \
faces> marked by [ f1, f2, f3, g1, g2, g3 ] -> [ f1^-1*f4^-1, f3^-1*f2*f3, f3^\
-1*f5, f4*f1*f5^-1*f4^-1, f2^-1*f3, f4 ]> )
gap> 
gap> Info(InfoFR,1,"Testing Triangulations");
#I  Testing Triangulations
gap> if IsBound(MacFloat) then Float := MacFloat; fi;
gap> oct := List([[1.,0.,0.],[0.,1.,0.],[0.,0.,1.],[-1.,0.,0.],[0.,-1.,0.],[0.,0.,-1.]],P1Sphere);;
gap> s := Sqrt(Float(1/3));;
gap> cube := List([[s,s,s],[s,s,-s],[s,-s,s],[-s,s,s],[s,-s,-s],[-s,s,-s],[-s,-s,s],[-s,-s,-s]],P1Sphere);;
gap> DelaunayTriangulation(cube);
<triangulation with 11 vertices, 54 edges and 18 faces>
gap> DelaunayTriangulation(cube{[1,5]});
<triangulation with 6 vertices, 24 edges and 8 faces>
gap> p := List([[0.,0.,1.],[0.,0.,-1.],SphereP1(P1Point(1/10000)),SphereP1(P1Point(0,10000))],P1Sphere);
[ 0+0i, P1infinity, 0.0001+0i, -0+10000i ]
gap> DelaunayTriangulation(p,100.);
<triangulation with 32 vertices, 180 edges and 60 faces>
gap> 
gap> Info(InfoFR,1,"Testing rabbit and z^2+i twists");
#I  Testing rabbit and z^2+i twists
gap> z := Indeterminate(COMPLEX_FIELD,"z":old);;
gap> ri := PolynomialIMGMachine(2,[],[1/6]);
<FR machine with alphabet [ 1 .. 2 ] and adder FRElement(...,f4) on Group(
[ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>
gap> model := StateSet(ri);
<free group on the generators [ f1, f2, f3, f4 ]>
gap> twist := GroupHomomorphismByImages(model,model,GeneratorsOfGroup(model),[model.1,model.2^(model.3*model.2),model.3^model.2,model.4]);
[ f1, f2, f3, f4 ] -> [ f1, f2^-1*f3^-1*f2*f3*f2, f2^-1*f3*f2, f4 ]
gap> 
gap> r := PolynomialIMGMachine(2,[1/7],[]);
<FR machine with alphabet [ 1 .. 2 ] and adder FRElement(...,f4) on Group(
[ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>
gap> model := StateSet(r);
<free group on the generators [ f1, f2, f3, f4 ]>
gap> twist := GroupHomomorphismByImages(model,model,GeneratorsOfGroup(model),[model.1^(model.2*model.1),model.2^model.1,model.3,model.4]);
[ f1, f2, f3, f4 ] -> [ f1^-1*f2^-1*f1*f2*f1, f1^-1*f2*f1, f3, f4 ]
gap> rt := List([0..4],i->r*twist^i);
[ <FR machine with alphabet [ 1 .. 2 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>,
  <FR machine with alphabet [ 1 .. 2 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>,
  <FR machine with alphabet [ 1 .. 2 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>,
  <FR machine with alphabet [ 1 .. 2 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]>,
  <FR machine with alphabet [ 1 .. 2 ] and adder FRElement(...,f4) on Group(
    [ f1, f2, f3, f4 ] )/[ f4*f3*f2*f1 ]> ]
gap> m := PolynomialIMGMachine(3,[[3/4,1/12],[1/4,7/12]],[]);
<FR machine with alphabet [ 1 .. 3 ] and adder FRElement(...,f3) on Group(
[ f1, f2, f3 ] )/[ f3*f2*f1 ]>
gap> 
gap> Info(InfoFR,1,"Testing RationalFunction");
#I  Testing RationalFunction

gap> f := RationalFunction(PolynomialIMGMachine(2,[],[7/16]):param_unicritical);
z^2+(-1.7712570233553744+I*0.066161509077873187)
gap> 
gap> Info(InfoFR,1,"Testing Pilgrim's obstructed blowup of the torus");
#I  Testing Pilgrim's obstructed blowup of the torus
gap> F := FreeGroup("a","b","c","d");
<free group on the generators [ a, b, c, d ]>
gap> Unbind(a); Unbind(b); Unbind(c); Unbind(d);
gap> AssignGeneratorVariables(F); o := One(F);;
#I  Assigned the global variables [ a, b, c, d ]
gap> M := FRMachine(F,[[c^-1,o,o,o,c],[o,o,o,d,d^-1],[a,o,o,a^-1,o],[b,o,d,a,c]],
>                   [(1,5)(2,4,3),(1,2)(4,5),(1,4)(2,3,5),()]);
<FR machine with alphabet [ 1 .. 5 ] on Group( [ a, b, c, d ] )>
gap> SetIMGRelator(M,d*c*b*a);
gap> RationalFunction(M);
rec( machine := <FR machine with alphabet [ 1 .. 5 ] on Group( [ a, b, c, d ]
     )/[ d*c*b*a ]>, matrix := [ [ 1 ] ], obstruction := [ a*c ],
  spider := <marked sphere on <triangulation with 8 vertices, 36 edges and 12 \
faces> marked by [ a, b, c, d ] -> [ f2^-1, f3*f1^-1, f2*f3^-1, f2*f1*f2^-1 ]>\
 )
gap> 
gap> Info(InfoFR,1,"Testing mating of airplane with z^2+i");
#I  Testing mating of airplane with z^2+i
gap> m := Mating(PolynomialIMGMachine(2,[3/7],[]),PolynomialIMGMachine(2,[],[1/6]));
<FR machine with alphabet [ 1 .. 2 ] on Group( [ f1, f2, f3, g1, g2, g3 ]
 )/[ f3*f2*f1*g3*g2*g1 ]>
gap> Unbind(f1); Unbind(f2); Unbind(f3); Unbind(g1); Unbind(g2); Unbind(g3); 
gap> AssignGeneratorVariables(StateSet(m));
#I  Assigned the global variables [ f1, f2, f3, g1, g2, g3 ]
gap> i := FreeGroup("f1","f2","f3","g1","x");
<free group on the generators [ f1, f2, f3, g1, x ]>
gap> tm := ChangeFRMachineBasis(m,[f1^-1*g2,One(StateSet(m))]);;
gap> inj := GroupHomomorphismByImages(i,StateSet(m),GeneratorsOfGroup(i),[f1^g2,f2,f3,g1,f1*g3/f1*g2]);
[ f1, f2, f3, g1, x ] -> [ g2^-1*f1*g2, f2, f3, g1, f1*g3*f1^-1*g2 ]
gap> m2 := SubFRMachine(tm,inj);
<FR machine with alphabet [ 1 .. 2 ] on Group( [ f1, f2, f3, g1, x ]
 )/[ f3*f2*x*f1*g1 ]>
gap> RationalFunction(m2);
((-1.1225810141288928+I*0.46643730390689359)*z^2+(1.9648756079579599+I*1.99403\
7710592715)*z+(-0.18911847630899942-I*2.5212547160630749))/((3.844618700167240\
7+I*1.9274621069466134)*z+1.)
gap> 
gap> Info(InfoFR,1,"Testing a folding");
#I  Testing a folding
gap> fold1 := NewIMGMachine("a=<,,b,,,B>(1,2,3)(4,5,6)","b=<,,b*a/b,,,B*A/B>","A=<,,b*a,,,B*A>(3,6)","B=(1,6,5,4,3,2)");
<FR machine with alphabet [ 1 .. 6 ] on Group( [ a, b, A, B ] )/[ a*B*A*b ]>
gap> 
gap> STOP_TEST( "chapter-9.tst", 10^10 );

#E chapter-9.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 