# Issue related to IsomorphismPartialPermSemigroup and
# IsomorphismPartialPermMonoid for a trivial perm group with 0 generators
# Examples reported on issue #1783 on github.com/gap-system/gap
gap> iso := [];;
gap> iso[1] := IsomorphismPartialPermSemigroup(SymmetricGroup(1));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> iso[2] := IsomorphismPartialPermSemigroup(Group([()]));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> iso[3] := IsomorphismPartialPermSemigroup(Group([], ()));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> iso[4] := IsomorphismPartialPermMonoid(SymmetricGroup(1));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> iso[5] := IsomorphismPartialPermMonoid(Group([()]));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> iso[6] := IsomorphismPartialPermMonoid(Group([], ()));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> ForAll(iso, map -> () ^ map = EmptyPartialPerm());
true
gap> inv := List(iso, InverseGeneralMapping);;
gap> ForAll(inv, map -> EmptyPartialPerm() ^ map = ());
true
