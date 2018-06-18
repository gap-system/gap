#
# make sure OnTuples works correct even for plists that don't know they
# are empty
#
gap> adj := [[2], [], [2]];;
gap> new := List([1, 2], i -> []);;
gap> perm := (2, 1);;
gap> for i in [1, 2] do
> new[i ^ perm] := Concatenation(new[i ^ perm], adj[i]);;
> od;
gap> List(new, TNAM_OBJ);
[ "list (plain)", "list (plain)" ]
gap> List(new, x -> OnTuples(x, perm));
[ [  ], [ 1 ] ]
gap> List(new, TNAM_OBJ);
[ "list (plain)", "list (plain)" ]
gap> List(new, x -> OnSets(x, perm));
[ [  ], [ 1 ] ]
