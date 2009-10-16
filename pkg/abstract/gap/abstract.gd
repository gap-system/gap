DeclareCategory("IsAbstraction", IsObject);
AbstractionsFamily := NewFamily("AbstractionsFamily",IsObject,IsAbstraction);

#
# The five abstractions
#

DeclareCategory("IsAbstractGroupAbstraction",   IsAbstraction);
DeclareCategory("IsGeneratedGroupAbstraction",  IsAbstraction);
DeclareCategory("IsConcreteGroupAbstraction",   IsAbstraction);
DeclareCategory("IsCharacterAbstraction",       IsAbstraction);
DeclareCategory("IsRepresentationAbstraction",  IsAbstraction);

#
# Permutation and matrix representations are different
#
DeclareCategory("IsPermutationRepresentationAbstraction", IsRepresentationAbstraction);
DeclareCategory("IsPermutationCharacterAbstraction", IsCharacterAbstraction);
DeclareCategory("IsMatrixRepresentationAbstraction", IsRepresentationAbstraction);
DeclareCategory("IsMatrixCharacterAbstraction", IsCharacterAbstraction);

#
# Attributes to link them around
#

DeclareAttribute("CurrentRepresentationOfConcreteGroupAbstraction",
        IsConcreteGroupAbstraction, "mutable");
DeclareAttribute("CurrentGeneratedGroupOfConcreteGroupAbstraction",
        IsConcreteGroupAbstraction, "mutable");
DeclareAttribute("CurrentAbstractGroupOfGeneratedGroupAbstraction",
        IsGeneratedGroupAbstraction, "mutable");
DeclareAttribute("CurrentCharacterOfRepresentationAbstraction",
        IsRepresentationAbstraction, "mutable");
DeclareAttribute("CurrentAbstractGroupOfCharacterAbstraction",
        IsCharacterAbstraction, "mutable");

#
# and in the other direction (one->many)
#

DeclareAttribute("KnownCharactersOfAbstractGroup",
        IsAbstractGroupAbstraction, "mutable");
DeclareAttribute("KnownGeneratedGroupsOfAbstractGroup",
        IsAbstractGroupAbstraction, "mutable");
DeclareAttribute("KnownRepresentationsOfCharacter",
        IsCharacterAbstraction, "mutable");
DeclareAttribute("KnownConcreteGroupsOfGeneratedGroup", IsGeneratedGroupAbstraction,
        "mutable");
DeclareAttribute("KnownConcreteGroupsOfRepresentation", IsRepresentationAbstraction,
        "mutable");

#
# The link to real GAP objects
#

DeclareAttribute("KnownGroupsOfConcreteGroupAbstraction", IsConcreteGroupAbstraction,"mutable");
DeclareAttribute("AbstractionsOfGroup", IsGroup);

#
# We may want this for global searching, etc.
#

DeclareGlobalVariable("KnownAbstractGroupAbstractions");

#
# Some things that are not attributes but which we might want to store
#

DeclareAttribute("IsomorphismTypeFiniteSimpleGroupOfAbstractGroup", 
        IsAbstractGroupAbstraction);

#
# generic Machinery
#

DeclareGlobalFunction( "InstallAbstractionMaintenance" );
DeclareGlobalFunction( "PropagateMaintainedDataToAbstractions" );

DeclareOperation("ParentAbstraction",[IsGroup, IsString]);
DeclareOperation("ParentAbstraction",[IsAbstraction, IsString]);
DeclareOperation("AllKnownChildrenOfAbstraction",[IsAbstraction,IsString]);