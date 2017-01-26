## Testing AssociatedReesMatrixSemigroupOfDClass.
##         IsZeroSimpleSemigroup, IsomorphismReesMatrixSemigroup,
##         and MatrixOfReesZeroMatrixSemigroup
##         create Greens D classes correctly.
gap> rms := AssociatedReesMatrixSemigroupOfDClass(dcl[5]);;
gap> s := Transformation([1,1,2]);;
gap> c := Transformation([2,3,1]);;
gap> op3 := Semigroup(s,c);;
gap> IsRegularSemigroup(op3);;
gap> dcl := GreensDClasses(op3);;
gap> dcl := SortedList(ShallowCopy(dcl));;
gap> d2 := dcl[2];; d1:= dcl[1];;
gap> i2 := SemigroupIdealByGenerators(op3,[Representative(d2)]);;
gap> GeneratorsOfSemigroup(i2);;
gap> i1 := SemigroupIdealByGenerators(i2,[Representative(d1)]);;
gap> GeneratorsOfSemigroup(i1);;
gap> c1 := ReesCongruenceOfSemigroupIdeal(i1);;
gap> q := i2/c1;;
gap> IsZeroSimpleSemigroup(q);;
gap> irms := IsomorphismReesZeroMatrixSemigroup(q);;
gap> MatrixOfReesZeroMatrixSemigroup(Range(irms));;
gap> g := Group( (1,2),(1,2,3) );;
gap> i := TrivialSubgroup( g );;
gap> CentralizerModulo( g, i, (1,2) );
Group([ (1,2) ])
