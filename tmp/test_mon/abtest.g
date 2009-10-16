##########################################################################
##
##  abtest.g
##  Finitely presented abelian semigroups 
##
##########################################################################
##########################################################################

##################################
# Basic finite examples
#
##################################
f:=FreeSemigroup("a","b","c","d");
a:=GeneratorsOfSemigroup(f)[1];
b:=GeneratorsOfSemigroup(f)[2];
c:=GeneratorsOfSemigroup(f)[3];
d:=GeneratorsOfSemigroup(f)[4];
g:=f/[ [a*a,d],[b*c,d],[b*b,c],[c*a*c*a*c*a*c,a*b*a*b*a*b*a],
[b*a*c*a*b*a*c*a,a*b*a*c*a*b*a*c] ];;
h:=Abelianization(g);
hkbrws:=KnuthBendixRewritingSystem(h);;
Size(h);
Elements(h);   
Length(Elements(h));
#adjoining a zero to our semigroup h
h0:=Range(InjectionZeroMagma(h));
Elements(h0);
Size(h0);
GeneratorsOfSemigroup(h0);
a0:=GeneratorsOfSemigroup(h0)[1];
b0:=GeneratorsOfSemigroup(h0)[2];
c0:=GeneratorsOfSemigroup(h0)[3];
d0:=GeneratorsOfSemigroup(h0)[4];
o:=GeneratorsOfSemigroup(h0)[5]; 
b0*c0*a0^2=d0^2;

########################################
# Build "abelianization" as a quotient
#
########################################
f:=FreeMonoid("a","b");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
e:=Identity(f);
m:=f/[[a*a,e],[b*b*b,e],[a*b*a*b*a*b,e]];
k:=KnuthBendixRewritingSystem(m);
Rules(k);
MakeConfluent(k);
Rules(k);
Elements(m);
Size(m);
a:=GeneratorsOfSemigroup(m)[2];
b:=GeneratorsOfSemigroup(m)[3];
e:=GeneratorsOfSemigroup(m)[1];
ab:=SemigroupCongruenceByGeneratingPairs(m,
 [[a*b,b*a],[a*e,e*a],[b*e,e*b]]);
h:=m/ab;
a:=GeneratorsOfSemigroup(h)[2];
b:=GeneratorsOfSemigroup(h)[3];
e:=GeneratorsOfSemigroup(h)[1];
a*b*e^4=e*b*e*a*e^2;
Size(h);

#Examples with the ideal generators

f:=FreeSemigroup("a","b");
x:=GeneratorsOfSemigroup(f);
a:=x[1];;b:=x[2];;
g:=f/[ [a^3,a],[b^2,b]];
h:=Abelianization(g);
y:=GeneratorsOfSemigroup(h);
v:=y[1]^2;
ReducedSetOfGeneratorsOfPrincipalIdealOfSemigroup(h,v);    # result is [ a ]

f:=FreeSemigroup("a","b","c");
x:=GeneratorsOfSemigroup(f);
a:=x[1];;b:=x[2];;c:=x[3];;
g:=f/[ [a^2,c],[b^3,c],[c^3,a*c],[a*b^2,c],
[c*b,a*c],[b*c,a*c]];
h:=Abelianization(g);
y:=GeneratorsOfSemigroup(h);
ReducedSetOfGeneratorsOfPrincipalIdealOfSemigroup(h,y[1]);   #[ a, c]

f:=FreeSemigroup(3);;
x:=GeneratorsOfSemigroup(f);;
r:=[ [x[2]*x[1],x[1]*x[2]] , [x[3]*x[1],x[1]*x[3]] ,
[x[3]*x[2],x[2]*x[3]] , [x[1]^5,x[2]*x[3]],
[x[2]^4,x[1]*x[3]] , [x[3]^2,x[1]*x[2]] ];;
g:=f/r;
phi:=EpimorphismAbelianization(g);
h:=Range(phi);
IsCommutative(h);                         # true
kbrws := KnuthBendixRewritingSystem(h);
MakeConfluent(kbrws);                     # time = 120 
Size(h);                                  # 39; time = 10
Elements(h);                              # time = 3020

f:=FreeSemigroup("a","b");
x:=GeneratorsOfSemigroup(f);;a:=x[1];;b:=x[2];;
r:=[ [a^3,a],[b^2,a*b] ];
h:=Abelianization(f/r);;
Elements(h);              # [ a, b, a^2, a*b, a^2*b ]
IsConfluent(KnuthBendixRewritingSystem(h));

# example of GreensLessThanOrEqual
# (method for Greens classes of an fp commutative smg)
f := FreeSemigroup( "a", "b","c");;
x := GeneratorsOfSemigroup( f );; a := x[1];; b := x[2];; c := x[3];;
g := f/[ [a^2,c], [b^3,c], [c^3,a*c], [a*b^2,c] ];
phi := EpimorphismAbelianization( g );;h := Range( phi );;
el := Elements( h );
D := GreensDRelation( h );
d1 := EquivalenceClassOfElement( D, el[1] );;
d2 := EquivalenceClassOfElement( D, el[2] );;
d3 := EquivalenceClassOfElement( D, el[3] );;
d4 := EquivalenceClassOfElement( D, el[4] );;
d5 := EquivalenceClassOfElement( D, el[5] );;
d6 := EquivalenceClassOfElement( D, el[6] );;
IsGreensLessThanOrEqual( d1,d2);
R := GreensRRelation( h );
r1 := EquivalenceClassOfElement( R, el[1] );;
r2 := EquivalenceClassOfElement( R, el[2] );;
