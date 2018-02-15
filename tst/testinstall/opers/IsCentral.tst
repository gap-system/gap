gap> START_TEST("IsCentral.tst");

#
# for groups
#
gap> G:=SymmetricGroup(3);;

# a group and an element
gap> List(AsSet(G), g -> [g, IsCentral(G,g)]);
[ [ (), true ], [ (2,3), false ], [ (1,2), false ], [ (1,2,3), false ], 
  [ (1,3,2), false ], [ (1,3), false ] ]

# a group and a subgroup
gap> G:=SymmetricGroup(3);;
gap> List(Set(AllSubgroups(G)), H -> [H, IsCentral(G, H)]);
[ [ Group(()), true ], [ Group([ (2,3) ]), false ], 
  [ Group([ (1,2,3), (2,3) ]), false ], [ Group([ (1,2) ]), false ], 
  [ Group([ (1,2,3) ]), false ], [ Group([ (1,3) ]), false ] ]

#
# a set of matrices for the other tests
#
gap> gens := [ DiagonalMat([1,0]), [[0,1],[0,0]], DiagonalMat([1,1]) ];;

#
# for a magma
#
gap> M:=Magma(gens);
<magma with 3 generators>
gap> List(AsSet(M), x->IsCentral(M,x));
[ true, false, false, true ]
gap> IsCentral(M, Submagma(M, []));
true
gap> List(AsSet(M), x->IsCentral(M,Submagma(M,[x])));
[ true, false, false, true ]

#
# for a magma with one
#
gap> M:=MagmaWithOne(gens);
<magma-with-one with 3 generators>
gap> List(AsSet(M), x->IsCentral(M,x));
[ true, false, false, true ]
gap> IsCentral(M, Submagma(M, []));
true
gap> List(AsSet(M), x->IsCentral(M,Submagma(M,[x])));
[ true, false, false, true ]

#
# for an algebra
#
gap> A:=Algebra(Rationals, gens);
<algebra over Rationals, with 3 generators>
gap> List(GeneratorsOfAlgebra(A), x->IsCentral(A,x));
[ false, false, true ]
gap> List(GeneratorsOfAlgebra(A), x->IsCentral(A,Subalgebra(A,[x])));
[ false, false, true ]

#
# for an algebra with one
#
gap> A:=AlgebraWithOne(Rationals, gens);
<algebra-with-one over Rationals, with 3 generators>
gap> List(GeneratorsOfAlgebraWithOne(A), x->IsCentral(A,x));
[ false, false, true ]
gap> List(GeneratorsOfAlgebraWithOne(A), x->IsCentral(A,Subalgebra(A,[x])));
[ false, false, true ]

#
# for a ring
#
gap> R:=Ring(gens);
<free left module over Integers, and ring, with 3 generators>
gap> SetIsAssociative(R,true);
gap> List(GeneratorsOfLeftOperatorRing(R), x->IsCentral(R,x));
[ false, false, true ]
gap> List(GeneratorsOfLeftOperatorRing(R), x->IsCentral(R,SubringNC(R,[x])));
[ false, false, true ]

#
# for a ring with one
#
gap> R:=RingWithOne(gens);
<free left module over Integers, and ring-with-one, with 3 generators>
gap> SetIsAssociative(R,true);
gap> List(GeneratorsOfLeftOperatorRingWithOne(R), x->IsCentral(R,x));
[ false, false, true ]
gap> List(GeneratorsOfLeftOperatorRingWithOne(R), x->IsCentral(R,SubringNC(R,[x])));
[ false, false, true ]

#
gap> STOP_TEST("IsCentral.tst", 10000);
