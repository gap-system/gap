#############################################################################
##
#W  frattfree.gd                GAP library                      Bettina Eick
##
Revision.frattfree_gd :=
    "@(#)$Id$:";

#############################################################################
##
#I Info
##
InfoFFConst := NewInfoClass( "InfoFFConst" );

#############################################################################
##
#A Projections
##
Projections := NewAttribute( "Projections", IsGroup );
SetProjections := Setter( Projections );
HasProjections := Tester( Projections );

#############################################################################
##
#P IsFrattiniFree
##
IsFrattiniFree := NewProperty( "IsFrattiniFree", IsGroup );
SetIsFrattiniFree := Setter( IsFrattiniFree );
HasIsFrattiniFree := Tester( IsFrattiniFree );

#############################################################################
##
#A Socle
##
Socle := NewAttribute( "Socle", IsGroup );
SetSocle := Setter( Socle );
HasSocle := Tester( Socle );

#############################################################################
##
#A SocleComplement
##
SocleComplement := NewAttribute( "SocleComplement", IsGroup );
SetSocleComplement := Setter( SocleComplement );
HasSocleComplement := Tester( SocleComplement );

#############################################################################
##
#A SocleDimensions
##
SocleDimensions := NewAttribute( "SocleDimensions", IsGroup );
SetSocleDimensions := Setter( SocleDimensions );
HasSocleDimensions := Tester( SocleDimensions );

DiagonalMat
    := NewOperationArgs("DiagonalMat");
RunSubdirectProductInfo
    := NewOperationArgs("RunSubdirectProductInfo");
IsConjugateMatGroup
    := NewOperationArgs("IsConjugateMatGroup");
IsFaithfulModule
    := NewOperationArgs("IsFaithfulModule");
IrreducibleSubgroupsOfGL
    := NewOperationArgs("IrreducibleSubgroupsOfGL");
SemiSimpleGroups
    := NewOperationArgs("SemiSimpleGroups");
Uncollected
    := NewOperationArgs("Uncollected");
SocleComplementAbelianSocle
    := NewOperationArgs("SocleComplementAbelianSocle");
NonInnerGroups
    := NewOperationArgs("NonInnerGroups");
FittingFreeGroupsBySocleAndSize
    := NewOperationArgs("FittingFreeGroupsBySocleAndSize");
MySplitExtensionSolvable
    := NewOperationArgs("MySplitExtensionSolvable");
MySplitExtensionNonSolvable
    := NewOperationArgs("MySplitExtensionNonSolvable");
FrattiniFreeGroups
    := NewOperationArgs("FrattiniFreeGroups");
FrattiniFreeSolvableGroupsBySize
    := NewOperationArgs("FrattiniFreeSolvableGroupsBySize");
