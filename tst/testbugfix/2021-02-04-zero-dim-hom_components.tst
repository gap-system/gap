# zero-dimensional hom_components #4245
gap> l := FreeLieAlgebra(Integers,1);
<free left module over Integers, and ring, with 1 generator>
gap> List([0..2],Grading(l).hom_components);
[ <free left module over Integers, with 0 generators>, 
  <free left module over Integers, with 1 generator>, 
  <free left module over Integers, with 0 generators> ]
gap> a := FreeAssociativeAlgebra(Integers,2);
<free left module over Integers, and ring, with 2 generators>
gap> List([0..2],Grading(a).hom_components);
[ <free left module over Integers, with 0 generators>, 
  <free left module over Integers, with 2 generators>, 
  <free left module over Integers, with 4 generators> ]
