## Costantini bug, in inverting lists of compressed vectors
gap> p := 3;; e := 16;;
gap> g := ElementaryAbelianGroup(p^e);;
gap> l := PCentralLieAlgebra(g);;
gap> b := Basis(l);;
gap> b2 := b;;
gap> RelativeBasis(b,b2);;
