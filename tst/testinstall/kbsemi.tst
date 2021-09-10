gap> START_TEST("kbsemi.tst");
gap> F:=FreeGroup(2);
<free group on the generators [ f1, f2 ]>
gap> mhom:=IsomorphismFpMonoid(F);;
gap> mon:=Image(mhom);
<fp monoid on the generators [ f1, f1^-1, f2, f2^-1 ]>
gap> k:=KnuthBendixRewritingSystem(mon);;
gap> k1:=ShallowCopy(k);;
gap> MakeKnuthBendixRewritingSystemConfluent(k1);
gap> k = k1;
true

#
gap> f := FreeSemigroup("a","b");;
gap> a := f.1;; b := f.2;;
gap> s := f/[[a*b,b],[b*a,a]];;
gap> rws := KnuthBendixRewritingSystem(s);
Knuth Bendix Rewriting System for Semigroup( [ a, b ] ) with rules 
[ [ a*b, b ], [ b*a, a ] ]
gap> IsConfluent(rws);
false
gap> rws1 := ShallowCopy(rws);
Knuth Bendix Rewriting System for Semigroup( [ a, b ] ) with rules 
[ [ a*b, b ], [ b*a, a ] ]
gap> rws1 = rws;
true
gap> IsConfluent(rws1);
false
gap> MakeKnuthBendixRewritingSystemConfluent(rws1);
gap> rws1 = rws;
false
gap> MakeKnuthBendixRewritingSystemConfluent(rws);
gap> rws1 = rws;
true

# Some more tests for Knuth-Bendix rewriting
gap> CreateKnuthBendixRewritingSystem(FamilyObj(1), x -> x);
Error, Can only create a KB rewriting system for an fp semigroup or monoid
gap> M := FreeMonoid(2);; N := M / [ [M.1, M.2] ];;
gap> CreateKnuthBendixRewritingSystem(FamilyObj(Representative(N)), x -> x);
Error, Second argument must be a reduction ordering
gap> kbrws := KnuthBendixRewritingSystem(N);
Knuth Bendix Rewriting System for Monoid( [ m1, m2 ] ) with rules 
[ [ m2, m1 ] ]
gap> kbrws := KnuthBendixRewritingSystem(N, {x,y} -> [y,x]);
Error, <expr> must be 'true' or 'false' (not a dense plain list)
gap> kbrws := KnuthBendixRewritingSystem(N, \<);
Knuth Bendix Rewriting System for Monoid( [ m1, m2 ] ) with rules 
[ [ m2, m1 ] ]
gap> F := FreeGroup(2);; G := F / [ F.1^2, F.2^2, (F.1 * F.2)^6 ];;
gap> kbrws := KnuthBendixRewritingSystem(Image(IsomorphismFpMonoid(G)));;
gap> IsConfluent(kbrws);
false
gap> IsReduced(kbrws);
true
gap> kbrws2 := ShallowCopy(kbrws);;
gap> kbrws = kbrws2;
true
gap> IsConfluent(kbrws2);
false
gap> IsReduced(kbrws2);
true
gap> MakeKnuthBendixRewritingSystemConfluent(kbrws);
gap> IsConfluent(kbrws);
true
gap> IsConfluent(kbrws2);
false
gap> kbrws = kbrws2;
false
gap> S := FreeSemigroup(2);; T := S / [ [S.1, S.2] ];;
gap> KnuthBendixRewritingSystem(S, \<);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `KnuthBendixRewritingSystem' on 2 argume\
nts
gap> M := FreeMonoid(2);; N := M / [ [M.1, M.2] ];;
gap> KnuthBendixRewritingSystem(N, \<);
Knuth Bendix Rewriting System for Monoid( [ m1, m2 ] ) with rules 
[ [ m2, m1 ] ]

#
gap> STOP_TEST("kbsemi.tst");
