#############################################################################
##
#W  commsemi.tst        GAP Library         Andrew Solomon and Isabel Araujo
##
#H  @(#)$Id: commsemi.tst,v 1.7 2000/06/01 15:44:31 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id: commsemi.tst,v 1.7 2000/06/01 15:44:31 gap Exp $");
gap> RequirePackage("commsemi");
true
gap> 
gap> f:=FreeSemigroup("a","b","c","d");
<free semigroup on the generators [ a, b, c, d ]>
gap> a:=GeneratorsOfSemigroup(f)[1];
a
gap> b:=GeneratorsOfSemigroup(f)[2];
b
gap> c:=GeneratorsOfSemigroup(f)[3];
c
gap> d:=GeneratorsOfSemigroup(f)[4];
d
gap> g:=f/[ [a*a,d],[b*c,d],[b*b,c],[c*a*c*a*c*a*c,a*b*a*b*a*b*a],
>  [b*a*c*a*b*a*c*a,a*b*a*c*a*b*a*c] ];;
gap> h:=Abelianization(g);
<fp semigroup on the generators [ a, b, c, d ]>
gap> hkbrws:=KnuthBendixRewritingSystem(h);;
gap> Size(h);
24
gap> Elements(h);
[ a, b, c, d, a*b, a*c, a*d, b*d, c*d, d^2, a*b*d, a*c*d, a*d^2, b*d^2, 
  c*d^2, d^3, a*b*d^2, a*c*d^2, a*d^3, b*d^3, c*d^3, d^4, a*b*d^3, b*d^4 ]
gap> Length(last);
24
gap> #adjoining a zero to our semigroup h
gap> h0:=Range(InjectionZeroMagma(h));
<semigroup with 5 generators>
gap> Elements(h0);
[ 0, a, b, c, d, a*b, a*c, a*d, b*d, c*d, d^2, a*b*d, a*c*d, a*d^2, b*d^2, 
  c*d^2, d^3, a*b*d^2, a*c*d^2, a*d^3, b*d^3, c*d^3, d^4, a*b*d^3, b*d^4 ]
gap> Size(h0);
25
gap> GeneratorsOfSemigroup(h0);
[ a, b, c, d, 0 ]
gap> a0:=GeneratorsOfSemigroup(h0)[1];
a
gap> b0:=GeneratorsOfSemigroup(h0)[2];
b
gap> c0:=GeneratorsOfSemigroup(h0)[3];
c
gap> d0:=GeneratorsOfSemigroup(h0)[4];
d
gap> o:=GeneratorsOfSemigroup(h0)[5];
0
gap> b0*c0*a0^2=d0^2;
true
gap> 
gap> f:=FreeMonoid("a","b");
<free monoid on the generators [ a, b ]>
gap> a:=GeneratorsOfMonoid(f)[1];
a
gap> b:=GeneratorsOfMonoid(f)[2];
b
gap> e:=Identity(f);
<identity ...>
gap> m:=f/[[a*a,e],[b*b*b,e],[a*b*a*b*a*b,e]];
<fp monoid on the generators [ a, b ]>
gap> k:=KnuthBendixRewritingSystem(m);;
gap> AsSortedList(Rules(k));
[ [ a^2, <identity ...> ], [ b^3, <identity ...> ],
  [ a*b*a*b*a*b, <identity ...> ] ]
gap> MakeConfluent(k);
gap> AsSortedList(Rules(k));
[ [ a^2, <identity ...> ], [ b^3, <identity ...> ], [ a*b*a*b, b^2*a ],
  [ a*b^2*a, b*a*b ], [ b*a*b*a, a*b^2 ], [ b^2*a*b^2, a*b*a ] ]
gap> Elements(m);
[ <identity ...>, a, b, a*b, b*a, b^2, a*b*a, a*b^2, b*a*b, b^2*a, b*a*b^2, 
  b^2*a*b ]
gap> Size(m);
12
gap> a:=GeneratorsOfSemigroup(m)[2];
a
gap> b:=GeneratorsOfSemigroup(m)[3];
b
gap> e:=GeneratorsOfSemigroup(m)[1];
<identity ...>
gap> ab:=MagmaCongruenceByGeneratingPairs(m,
> [[a*b,b*a],[a*e,e*a],[b*e,e*b]]);;
gap> h:=m/ab;
<fp monoid on the generators [ a, b ]>
gap> a:=GeneratorsOfSemigroup(h)[2];
a
gap> b:=GeneratorsOfSemigroup(h)[3];
b
gap> e:=GeneratorsOfSemigroup(h)[1];
<identity ...>
gap> a*b*e^4=e*b*e*a*e^2;
true
gap> Size(h);
3
gap> 
gap> f:=FreeSemigroup("a","b");
<free semigroup on the generators [ a, b ]>
gap> x:=GeneratorsOfSemigroup(f);
[ a, b ]
gap> a:=x[1];;b:=x[2];;
gap> g:=f/[ [a^3,a],[b^2,b]];
<fp semigroup on the generators [ a, b ]>
gap> h:=Abelianization(g);
<fp semigroup on the generators [ a, b ]>
gap> y:=GeneratorsOfSemigroup(h);
[ a, b ]
gap> v:=y[1]^2;
a^2
gap> BasisOfSemigroupIdeal(h,v);
[ a ]
gap> 
gap> f:=FreeSemigroup("a","b","c");
<free semigroup on the generators [ a, b, c ]>
gap> x:=GeneratorsOfSemigroup(f);
[ a, b, c ]
gap> a:=x[1];;b:=x[2];;c:=x[3];;
gap> g:=f/[ [a^2,c],[b^3,c],[c^3,a*c],[a*b^2,c],
>  [c*b,a*c],[b*c,a*c]];
<fp semigroup on the generators [ a, b, c ]>
gap> h:=Abelianization(g);
<fp semigroup on the generators [ a, b, c ]>
gap> y:=GeneratorsOfSemigroup(h);
[ a, b, c ]
gap> BasisOfSemigroupIdeal(h,y[1]);
[ c, b^3, a ]
gap> 
gap> f:=FreeSemigroup(3);;
gap> x:=GeneratorsOfSemigroup(f);;
gap> r:=[ [x[2]*x[1],x[1]*x[2]] , [x[3]*x[1],x[1]*x[3]] ,
>  [x[3]*x[2],x[2]*x[3]] , [x[1]^5,x[2]*x[3]],
>  [x[2]^4,x[1]*x[3]] , [x[3]^2,x[1]*x[2]] ];;
gap> g:=f/r;
<fp semigroup on the generators [ s1, s2, s3 ]>
gap> phi:=EpimorphismAbelianization(g);
MappingByFunction( <fp semigroup on the generators 
[ s1, s2, s3 ]>, <fp semigroup on the generators 
[ s1, s2, s3 ]>, function( g ) ... end )
gap> h:=Range(phi);
<fp semigroup on the generators [ s1, s2, s3 ]>
gap> IsCommutative(h);                         # true
true
gap> kbrws := KnuthBendixRewritingSystem(h);;
gap> MakeConfluent(kbrws);                     # time = 120
gap> Size(h);                                  # 39; time = 10
39
gap> Elements(h);                              # time = 3020
[ s1, s2, s3, s1^2, s1*s2, s1*s3, s2^2, s2*s3, s1^3, s1^2*s2, s1^2*s3, 
  s1*s2^2, s1*s2*s3, s2^3, s2^2*s3, s1^4, s1^3*s2, s1^3*s3, s1^2*s2^2, 
  s1^2*s2*s3, s1*s2^3, s1*s2^2*s3, s2^3*s3, s1^4*s2, s1^4*s3, s1^3*s2^2, 
  s1^3*s2*s3, s1^2*s2^3, s1^2*s2^2*s3, s1*s2^3*s3, s1^4*s2^2, s1^4*s2*s3, 
  s1^3*s2^3, s1^3*s2^2*s3, s1^2*s2^3*s3, s1^4*s2^3, s1^4*s2^2*s3, 
  s1^3*s2^3*s3, s1^4*s2^3*s3 ]
gap> 
gap> f:=FreeSemigroup("a","b");
<free semigroup on the generators [ a, b ]>
gap> x:=GeneratorsOfSemigroup(f);;a:=x[1];;b:=x[2];;
gap> r:=[ [a^3,a],[b^2,a*b] ];
[ [ a^3, a ], [ b^2, a*b ] ]
gap> h:=Abelianization(f/r);;
gap> Elements(h);              # [ a, b, a^2, a*b, a^2*b ]
[ a, b, a^2, a*b, a^2*b ]
gap> IsConfluent(KnuthBendixRewritingSystem(h));
true
gap> 
gap> f := FreeSemigroup( "a" , "b" );;
gap> a := GeneratorsOfSemigroup( f )[ 1 ];
a
gap> b := GeneratorsOfSemigroup( f )[ 2 ];;
gap> h := Abelianization( f / [ [ a^3 , a ],[ b^2 , a*b ] ]);
<fp semigroup on the generators [ a, b ]>
gap> IsFinite( h );
true
gap> EpimorphismToLargestSemilatticeHomomorphicImage(h);
MappingByFunction( <fp semigroup on the generators 
[ a, b ]>, <fp semigroup on the generators [ a, b ]>, function( g ) ... end )
gap>  LargestSemilatticeHomomorphicImage(h);
<fp semigroup on the generators [ a, b ]>
gap> ArchimedeanRelation(h);
<equivalence relation on Semigroup( [ a, b ] ) >
gap> el := Elements( h );
[ a, b, a^2, a*b, a^2*b ]
gap> ha := GreensHClassOfElement(h,el[1]);
{a}
gap> StabilizerOfGreensClass(ha);
<semigroup with 1 generator>
gap> commrws := CommutativeSemigroupRws(h);
Commutative Semigroup Rewriting System for Semigroup( [ a, b ] ) with rules 
[ [ b^2, a*b ], [ a^3, a ] ]
gap> VectorRulesOfCommutativeSemigroupRws(commrws);
[ [ [ 0, 2 ], [ 1, 1 ] ], [ [ 3, 0 ], [ 1, 0 ] ] ]
gap> id := SemigroupIdealByGenerators(h,[el[1],el[2]]);
<SemigroupIdeal with 2 generators>
gap> BasisOfSemigroupIdeal(id);
[ b, a ]
gap> f := FreeMonoid( "a" , "b" );;
gap> a := GeneratorsOfMonoid( f )[ 1 ]; 
a
gap> b := GeneratorsOfMonoid( f )[ 2 ];;
gap> h := Abelianization( f / [ [ a^3 , a ],[ b^2 , a*b ] ]);
<fp monoid on the generators [ a, b ]>
gap> IsFinite( h ); 
true
gap> EpimorphismToLargestSemilatticeHomomorphicImage(h);
MappingByFunction( <fp monoid on the generators 
[ a, b ]>, <fp monoid on the generators [ a, b ]>, function( g ) ... end )
gap> LargestSemilatticeHomomorphicImage(h);
<fp monoid on the generators [ a, b ]>
gap> ArchimedeanRelation(h);
<equivalence relation on Monoid( [ a, b ], ... ) >
gap> el := Elements( h ); 
[ <identity ...>, a, b, a^2, a*b, a^2*b ]
gap> ha := GreensHClassOfElement(h,el[3]);
{b}
gap> StabilizerOfGreensClass(ha);
<trivial group>
gap> commrws := CommutativeSemigroupRws(h);
Commutative Semigroup Rewriting System for Monoid( [ a, b ], ... ) with rules 
[ [ b^2, a*b ], [ a^3, a ] ]
gap> VectorRulesOfCommutativeSemigroupRws(commrws);
[ [ [ 0, 2 ], [ 1, 1 ] ], [ [ 3, 0 ], [ 1, 0 ] ] ]
gap> id := SemigroupIdealByGenerators(h,[el[1],el[2]]);
<SemigroupIdeal with 2 generators>
gap> Size(id);
6
gap> id := SemigroupIdealByGenerators(h,[el[2],el[3]]);
<SemigroupIdeal with 2 generators>
gap> BasisOfSemigroupIdeal(id);
[ b, a ]
gap> 
gap> STOP_TEST( "commsemi.tst", 30000000 );

#############################################################################
##
#E  commsemi.tst . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


