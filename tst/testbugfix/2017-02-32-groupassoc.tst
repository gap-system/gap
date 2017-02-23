# Disallow creating groups with non-associative generators.
# See issue #823
gap> Group(2.0);
#I  default `IsGeneratorsOfMagmaWithInverses' method returns `true' for [ 2 ]
Error, usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)
gap> Group(2.0,3.0);
#I  default `IsGeneratorsOfMagmaWithInverses' method returns `true' for [ 2, 3 ]
Error, usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)
gap> Group([], 1.0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `GroupByGenerators' on 2 arguments
gap> Group([2.0], 1.0);
#I  default `IsGeneratorsOfMagmaWithInverses' method returns `true' for [ 2 ]
Error, usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)

#
gap> M := [[1.0,0.0],[0.0,1.0]];;
gap> Group(M);
Error, usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)
