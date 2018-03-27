# Disallow creating groups with non-associative generators.
# See issue #823
gap> Group(2.0);
#I  no groups of floats allowed because of incompatible ^
Error, usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)
gap> Group(2.0,3.0);
#I  no groups of floats allowed because of incompatible ^
Error, usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)
gap> Group([], 1.0);
<trivial group>
gap> Group([2.0], 1.0);
#I  no groups of floats allowed because of incompatible ^
Error, usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)
