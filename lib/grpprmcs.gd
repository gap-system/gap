#############################################################################
##
#W  grpprmcs.gd                 GAP library                       Akos Seress
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
#H  @(#)$Id: grpprmcs.gd,v 4.8 2002/04/15 10:04:52 sal Exp $
##
Revision.grpprmcs_gd :=
    "@(#)$Id: grpprmcs.gd,v 4.8 2002/04/15 10:04:52 sal Exp $";

DeclareGlobalFunction( "NonPerfectCSPG" );
DeclareGlobalFunction( "PerfectCSPG" );
DeclareGlobalFunction( "CasesCSPG" );
DeclareGlobalFunction( "FindNormalCSPG" );
DeclareGlobalFunction( "FindRegularNormalCSPG" );
DeclareGlobalFunction( "NinKernelCSPG" );
DeclareGlobalFunction( "RegularNinKernelCSPG" );
DeclareGlobalFunction( "NormalizerStabCSPG" );
DeclareGlobalFunction( "TransStabCSPG" );
DeclareGlobalFunction( "PullbackKernelCSPG" );
DeclareGlobalFunction( "PullbackCSPG" );
DeclareGlobalFunction( "CosetRepAsWord" );
DeclareGlobalFunction( "ImageInWord" );
DeclareGlobalFunction( "SiftAsWord" );
DeclareGlobalFunction( "InverseAsWord" );
DeclareGlobalFunction( "RandomElmAsWord" );
DeclareGlobalFunction( "CentralizerNormalCSPG" );
DeclareGlobalFunction( "CentralizerNormalTransCSPG" );
DeclareGlobalFunction( "CentralizerTransSymmCSPG" );
DeclareGlobalFunction( "IntersectionNormalClosurePermGroup" );
DeclareGlobalFunction( "ActionAbelianCSPG" );
DeclareGlobalFunction( "ImageOnAbelianCSPG" );


#############################################################################
##
#F  ChiefSeriesOfGroup( [<H>, ]<G>[, <through>] )
##
#T  Eventually this function should be moved to another file.
##
DeclareGlobalFunction( "ChiefSeriesOfGroup" );


#############################################################################
##
#E

