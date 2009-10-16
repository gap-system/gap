#################################
## Testing equivalence relations
##################################

# first a set example
x := [1,2,3];
er := EquivalenceRelationByPartition(Domain(x),[[1,2],[3]]);
e2 := EquivalenceClassOfElement(er,2);
f2 := EquivalenceClassOfElement(er,2);
e2 = f2; # should be true
f3 := EquivalenceClassOfElement(er,3);
f3=f2; # should be false

# A semigroup example
t := Transformation([2,3,1]);
s := Transformation([3,3,1]);
S := Semigroup(s,t);
e := Elements(S);
c := MagmaCongruenceByGeneratingPairs(S,[[e[9],e[12]]]);
cc1 := EquivalenceClassOfElement(c,e[1]);
cc2 := EquivalenceClassOfElement(c,e[2]);
cc1=cc2; # dies
EquivalenceRelationPartition(c);
cc1=cc2;   # works
Set([cc1,cc2]);

# another semigroup example
# used to fail due to an infinite recurse in general mappings 
# equality

f:=FreeSemigroup("a","b","c");
x:=GeneratorsOfSemigroup(f);
a:=x[1];;b:=x[2];;c:=x[3];;
r:= [ [a*a,a],[b*b,b],[c*c,c] ];
s:=Abelianization(f/r);
x:=GeneratorsOfSemigroup(s);
a:=x[1];;b:=x[2];;c:=x[3];;
cong1 := MagmaCongruenceByGeneratingPairs(s,[[a*b,a*c]]);
cong2 := MagmaCongruenceByGeneratingPairs(s,[[a*b,b*c]]);
cong1=cong2;

# This crashed because of the infinite domain enumerator Length->Size
# recursion bug
Enumerator(UnderlyingRelation(cong1));

##  tests Length(enumerator of a green's class)
f:=FreeSemigroup("a","b","c");
x:=GeneratorsOfSemigroup(f);
a:=x[1];;b:=x[2];;c:=x[3];;
r:= [ [a*a,a],[b*b,b],[c*c,c] ];
s:=Abelianization(f/r);
g := GreensRRelation(s);
cl := EquivalenceClassOfElement(g, GeneratorsOfSemigroup(s)[1]);
Length(Enumerator(cl));

##  crash code if it doesn't work
##  see hack in inflist.gi
##
##  recursion depth trap (5000)
##  at
##  return Size( UnderlyingCollection( enum ) );
##  Length( Enumerator( C ) ) called from
##  Size( UnderlyingCollection( enum ) ) called from
##  Length( Enumerator( C ) ) called from
##  Size( UnderlyingCollection( enum ) ) called from
##  Length( Enumerator( C ) ) called from
##

