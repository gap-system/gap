#############################################################################
##
#W  chapter-9.tst                  FR Package               Laurent Bartholdi
##
#H  @(#)$Id: chapter-9.tst,v 1.1 2011/05/17 08:26:15 gap Exp $
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
gap> Info(InfoFR,1,"9.2 Spiders");
#I  9.2 Spiders
gap> e := AllExternalAngles(5);
[ [  ], [ [ 1/3, 2/3 ] ], [ [ 1/7, 2/7 ], [ 3/7, 4/7 ], [ 5/7, 6/7 ] ],                             
  [ [ 1/15, 2/15 ], [ 1/5, 4/15 ], [ 2/5, 3/5 ], [ 7/15, 8/15 ], [ 11/15, 4/5 ], [ 13/15, 14/15 ] 
     ], [ [ 1/31, 2/31 ], [ 3/31, 4/31 ], [ 5/31, 6/31 ], [ 7/31, 8/31 ], [ 9/31, 10/31 ], 
      [ 11/31, 12/31 ], [ 13/31, 18/31 ], [ 14/31, 17/31 ], [ 15/31, 16/31 ], [ 19/31, 20/31 ], 
      [ 21/31, 22/31 ], [ 23/31, 24/31 ], [ 25/31, 26/31 ], [ 27/31, 28/31 ], [ 29/31, 30/31 ] ] ]
gap> ForAll(Concatenation(e),p->SupportingRays(PolynomialIMGMachine(2,[p[1]]))[2][1][1]*2 in [p[1],p[2],p[1]+1,p[2]+1]);
true
gap> z := Indeterminate(COMPLEX_FIELD,"z");
z
gap> a := ComplexRootsOfUnivariatePolynomial((z-1)*(3*z^2-2*z^3)+1);                           
[ -0.426536, 0.598631+I*0.565259, 0.598631-I*0.565259, 1.72927-I*1.33227e-15 ]                      
gap> c := ComplexRootsOfUnivariatePolynomial((z^3+z)^3+z);
[ 0, -0.557573-I*0.540347, -0.557573+I*0.540347, 0.557573+I*0.540347, 0.557573-I*0.540347,          
  -0.264425-I*1.26049, -0.264425+I*1.26049, 0.264425+I*1.26049, 0.264425-I*1.26049 ]
gap> am := List(a,a->IMGMachine((a-1)*(3*z^2-2*z^3)+1));
[ <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f2*f3*f1*f4 ]>,   
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f3*f2*f1*f4 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f3*f2*f1*f4 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f3*f1*f2*f4 ]> ]
gap> cm := List(c,c->IMGMachine(z^3+c));
[ <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f2) on <object>/[ f1*f2 ]>,         
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f3*f1*f2*f4 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f3*f1*f2*f4 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f3*f1*f2*f4 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f3*f1*f2*f4 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f1*f3*f2*f4 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f1*f3*f2*f4 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f1*f3*f2*f4 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] and adder FRElement(...,f4) on <object>/[ f1*f3*f2*f4 ]> ]
gap> m := ListX(am,cm,Mating);
[ <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g1 ]>,                               
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f2*f1*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f1*f2*g1 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f1*f2*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f1*f2*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f1*f2*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f1*f2*g3*g1*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f1*f2*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f1*f2*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f1*f2*g1*g3*g2 ]>, 
  <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f3*f1*f2*g1*g3*g2 ]> ]
gap> RationalFunction(NewIMGMachine(am[1]));
1.2169361217367749006*z^3+(-2.7949976186160654379)*z^2+1.5311664371377240457
gap> RationalFunction(m[2]);
((0.14188947370286095206-I*0.16266995683015450513)*z^3+(0.98428986782983918236+I*0.608213940746446\
74621)*z^2+(0.67159729963093917071+I*0.52974076487878440922)*z+(-0.016308506846588664146-I*2.33724\
65421219272841))/((-0.00092285623486518741313-I*0.41440623466828135912)*z^3+(2.1907848145533077577\
-I*0.36706232964383039841)*z^2+(1.6399836221010133386-I*0.084762578914258798757)*z+1)
gap> RationalFunction(m[6]);
rec( machine := <FR machine with alphabet [ 1, 2, 3 ] on <object>/[ f2*f3*f1*g1*g3*g2 ]>,           
  matrix := [ [ 1/2, 1 ], [ 1/2, 0 ] ], 
  obstruction := [ g1*g3*g2*f1*g2^-1*g3^-1, f1^-1*f3^-1*f2*f3*f1*g2 ], 
  spider := <marked sphere on <triangulation with 11 vertices, 54 edges and 18 faces> marked by [ \
f1, f2, f3, g1, g2, g3 ] -> [ f5*f1^-1*f3^-1*f5^-1, f5*f1^-1*f3^-1*f4*f2^-1*f5*f4^-1*f3*f1*f5^-1, \
f5*f1^-1*f3^-1*f4*f3*f1*f5^-1, f2*f4^-1*f3*f1*f3^-1*f4*f2^-1, f2*f4^-1, f2*f4^-1*f3*f5^-1*f4*f2^-1\
 ]> )
gap> 
gap> STOP_TEST( "chapter-9.tst", 10^10 );

#E chapter-9.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 