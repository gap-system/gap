#############################################################################
##
#W    sift.gd              The GenSift package                Max Neunhoeffer
##                                                             Cheryl Praeger
##                                                            Csaba Schneider
##
##    @(#)$Id: sift.gd,v 1.2 2009/07/25 22:15:27 gap Exp $
##
##  This file contains the declarations for the generic implementation of 
##  the sift methods.
##

DeclareGlobalFunction( "PrepareSiftRecords" );

DeclareGlobalVariable( "GeneralizedSiftProfile" );

DeclareGlobalFunction( "ResetGeneralizedSiftProfile" );
DeclareGlobalFunction( "DisplayGeneralizedSiftProfile" );

DeclareGlobalFunction( "BasicSiftRandom" );
DeclareGlobalFunction( "BasicSiftCosetReps" );
DeclareGlobalFunction( "BasicSiftCosetRepsWithT" );
DeclareGlobalFunction( "BasicSiftShort" );

DeclareGlobalFunction( "SiftHasOrderInByOrder" );
DeclareGlobalFunction( "SiftHasOrderInByProjOrder" );
DeclareGlobalFunction( "SiftHasOrderInBlackBox" );

DeclareGlobalFunction( "IsMemberOrderOfElement" );
DeclareGlobalFunction( "IsMemberOrders" );
DeclareGlobalFunction( "IsMemberConjugates" );
DeclareGlobalFunction( "IsMemberIsOne" );
DeclareGlobalFunction( "IsMemberCentralizer" );
DeclareGlobalFunction( "IsMemberCentralizers" );
DeclareGlobalFunction( "IsMemberNormalizerOfCyclicSubgroup" );
DeclareGlobalFunction( "IsMemberNormalizer" );
DeclareGlobalFunction( "IsMemberWithSetConjugating" );
DeclareGlobalFunction( "IsMemberWithSet" );
DeclareGlobalFunction( "IsMemberSet" );
DeclareGlobalFunction( "IsMemberSetWithExtraEls" );

DeclareGlobalFunction( "GeneralizedSift" );
DeclareGlobalFunction( "TestGeneralizedSift" );
DeclareGlobalFunction( "CheckSLPOfResult" );
DeclareGlobalFunction( "ShortSift" );
DeclareGlobalFunction( "MakeCompleteSLP" );

DeclareGlobalVariable( "PreSift" );

