# View and Print of an algebraic extension show its actual base field
gap> x := Indeterminate(Rationals, "x");;
gap> F := AlgebraicExtension(Rationals, x^2-2);
<algebraic extension over the Rationals of degree 2>
gap> Print(F, "\n");
<algebraic extension over the Rationals of degree 2>
gap> L := AlgebraicExtension(CF(3), x^2-2);
<algebraic extension over CF(3) of degree 2>
gap> Print(L, "\n");
<algebraic extension over CF(3) of degree 2>
gap> AlgebraicExtension(F, Indeterminate(F)^2-3);
<algebraic extension over <algebraic extension over the Rationals of degree 
2> of degree 2>
