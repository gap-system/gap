# Verify that creating a group of cyclotomics is not possible
#
gap> Group([1]);
#I  no groups of cyclotomics allowed because of incompatible ^
Error, usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)
gap> Group([1],1);
#I  no groups of cyclotomics allowed because of incompatible ^
Error, usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)
gap> Group([],1);
Error, no groups of cyclotomics allowed because of incompatible ^

#
gap> GroupByGenerators([1]);
Error, no groups of cyclotomics allowed because of incompatible ^
gap> GroupByGenerators([1],1);
Error, no groups of cyclotomics allowed because of incompatible ^
gap> GroupByGenerators([],1);
Error, no groups of cyclotomics allowed because of incompatible ^

#
gap> GroupWithGenerators([1]);
Error, no groups of cyclotomics allowed because of incompatible ^
gap> GroupWithGenerators([1],1);
Error, no groups of cyclotomics allowed because of incompatible ^
gap> GroupWithGenerators([],1);
Error, no groups of cyclotomics allowed because of incompatible ^
