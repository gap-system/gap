# 2012/11/21 (SL)
gap> s := FreeSemigroup("a","b");
<free semigroup on the generators [ a, b ]>
gap> t := Subsemigroup(s,[s.1]);
<infinite commutative semigroup with 1 generator>
gap> t := Subsemigroup(s,[s.1]);
<infinite commutative semigroup with 1 generator>
gap> HasSize(t);
true
gap> Size(t);
infinity
gap> t := Subsemigroup(s, []);
<empty semigroup>
gap> HasSize(t);
true
gap> Size(t);
0
