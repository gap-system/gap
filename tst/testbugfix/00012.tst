## Testing if Green's D classes can be compared for finite semigroups
gap> s := Transformation([1,1,3,4,5]);;
gap> c := Transformation([2,3,4,5,1]);;
gap> op5 := Semigroup(s,c);;
gap> dcl := GreensDClasses(op5);;
gap> ForAny(Cartesian(dcl,dcl), x->IsGreensLessThanOrEqual(x[1],x[2]));
true
