# Creating a group from an empty list of generators must report that the
# identity element is needed, see issue #6499
#
gap> Group([]);
Error, Group(<gens>) with an empty list <gens> is not supported, use Group(<ge\
ns>,<id>) to specify the identity element <id>
gap> Group("");
Error, Group(<gens>) with an empty list <gens> is not supported, use Group(<ge\
ns>,<id>) to specify the identity element <id>

#
gap> GroupWithGenerators([]);
Error, the identity element must be given as second argument if the list of ge\
nerators is empty
gap> GroupByGenerators([]);
Error, the identity element must be given as second argument if the list of ge\
nerators is empty

# the type of an empty string knows `IsCollection' but not `IsEmpty',
# so this used to silently return a group without an identity element
gap> GroupWithGenerators("");
Error, the identity element must be given as second argument if the list of ge\
nerators is empty
gap> GroupByGenerators("");
Error, the identity element must be given as second argument if the list of ge\
nerators is empty

#
gap> Group([], ());
Group(())
gap> GroupWithGenerators([], ());
Group(())
gap> GroupByGenerators([], ());
Group(())

# the same with the empty string as the empty list of generators
gap> Group("", ());
Group(())
gap> GroupWithGenerators("", ());
Group(())
gap> GroupByGenerators("", ());
Group(())
gap> GeneratorsOfGroup( GroupWithGenerators( "", () ) );
[  ]

# the identity element is still checked
gap> GroupWithGenerators("", 1);
Error, no groups of cyclotomics allowed because of incompatible ^
