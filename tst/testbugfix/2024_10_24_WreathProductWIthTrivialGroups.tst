#
gap> START_TEST("WreathProductWithTrivialGroups.tst");
gap> P := SymmetricGroup(3);;
gap> IP := Group( One(P) );;
gap> M := GL(6, 5);;
gap> IM := Group( One(M) );;

# Generators should not contain the identity element,
# unless the group is trivial.
gap> checkGens := function(G)
>      local gens;
>      gens := GeneratorsOfGroup(G);
>      return gens = [One(G)] or ForAll(gens, g -> g <> One(G));
>    end;;

# imprimitive perm, trivial top
gap> checkGens( WreathProduct(P, IP) );
true

# imprimitive perm, trivial base
gap> checkGens( WreathProduct(IP, P) );
true

# imprimitive perm, trivial base and top
gap> checkGens( WreathProduct(IP, IP) );
true

# imprimitive mat, trivial top
gap> checkGens( WreathProduct(M, IP) );
true

# imprimitive mat, trivial base
gap> checkGens( WreathProduct(IM, P) );
true

# imprimitive mat, trivial base and top
gap> checkGens( WreathProduct(IM, IP) );
true

# product action perm, trivial top
gap> checkGens( WreathProductProductAction(P, IP) );
true

# product action perm, trivial base
gap> checkGens( WreathProductProductAction(IP, P) );
true

# product action perm, trivial base and top
gap> checkGens( WreathProductProductAction(IP, IP) );
true

#
gap> K := Group([ () ]);;
gap> H := Group([ (1,2,3,4,5,6,7), (6,7,8) ]);;
gap> G := WreathProduct(K, H);;
gap> WreathProductInfo(G).components;
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ] ]

#
gap> STOP_TEST("WreathProductWithTrivialGroups.tst");
