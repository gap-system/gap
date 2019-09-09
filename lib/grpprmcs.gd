#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Ákos Seress.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##

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
