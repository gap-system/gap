#############################################################################
##
#W  grpconst.gd                   Grpconst                       Bettina Eick
#W                                                         Hans Ulrich Besche
##
Revision.("grpconst/gap/grpconst_gd") :=
    "@(#)$Id: grpconst.gd,v 1.11 2007/05/08 11:11:51 gap Exp $";

#############################################################################
##
#I InfoClass
##
DeclareInfoClass( "InfoGrpCon" );

#############################################################################
##
##
DeclareAttribute( "FrattiniFactor", IsGroup );
DeclareAttribute( "FrattExtInfo", IsGroup, "mutable" );
DeclareAttribute( "Projections", IsGroup );

# aus irred.gi
DeclareGlobalFunction( "IsFaithfulModule");
DeclareGlobalFunction( "IsMaximalPrimePower");
DeclareGlobalFunction( "GModuleByGroup");
DeclareGlobalFunction( "ReduceToClasses");
DeclareGlobalFunction( "IrreducibleEmbeddings");
DeclareGlobalFunction( "IrreducibleGroupsByAbelian");
DeclareGlobalFunction( "IrreducibleGroupsByCatalogue");
DeclareGlobalFunction( "IrreducibleGroupsByEmbeddings");
DeclareGlobalFunction( "IrreducibleGroups");

# aus semisim.gi
DeclareGlobalFunction( "BlockDiagonalMat");
DeclareGlobalFunction( "Choices");
DeclareGlobalFunction( "EmbeddingIntoGL");
DeclareGlobalFunction( "SemiSimpleGroups");

# aus fratfree.gi
DeclareGlobalFunction( "RunSubdirectProductInfo");
DeclareGlobalFunction( "SocleComplements");
DeclareGlobalFunction( "ExtensionBySocle");
DeclareGlobalFunction( "CheckFlags");
DeclareGlobalFunction( "CompareFlagsAndSize");
DeclareGlobalFunction( "FrattiniFreeBySocle");
DeclareGlobalFunction( "FrattiniFreeBySize");
DeclareGlobalFunction( "FrattiniFactorCandidates");

# aus frattext.gi
DeclareGlobalFunction( "EnlargedModule" );
DeclareGlobalFunction( "FindUniqueModules" );
DeclareGlobalFunction( "FrattiniExtensionsOfCode");
DeclareGlobalFunction( "FrattiniExtensionsOfGroup" );
DeclareGlobalFunction( "FrattiniExtensions" );
DeclareGlobalFunction( "FrattiniExtensionMethod" );

# aus risotest.gi
DeclareGlobalFunction( "AddRandomTestInfosFEM" );
DeclareGlobalFunction( "PermGensGensFEM" );
DeclareGlobalFunction( "RandomIsomorphismTestFEM" );
DeclareGlobalFunction( "ReducedByIsomorphismsFEM" );

# aus disting.gi
DeclareGlobalFunction( "DiffCocList" );
DeclareGlobalFunction( "DistinguishGroups" );

# aus cycl.gi
DeclareGlobalFunction( "CyclicSplitExtensionsUp");
DeclareGlobalFunction( "CyclicSplitExtensionsDown");
DeclareGlobalFunction( "CyclicSplitExtensions");
DeclareGlobalFunction( "CyclicSplitExtensionMethod");
DeclareGlobalFunction( "CyclicGenerator");

# aus upext.gi 
DeclareGlobalFunction( "SolvableResidual");
DeclareGlobalFunction( "GroupOfInnerAutomorphismSpecial");
DeclareGlobalFunction( "CyclicExtensionByTuple");
DeclareGlobalFunction( "CyclicExtensions");
DeclareGlobalFunction( "UpwardsExtensions");

# aus grpconst.gi
DeclareGlobalFunction( "AllNonSolublePerfectGroups" );
DeclareGlobalFunction( "ConstructAllGroups" );
