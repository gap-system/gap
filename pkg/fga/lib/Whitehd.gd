#############################################################################
##
#W  Whitehd.gd               FGA package                    Christian Sievers
##
##  Declarations for computations with Whitehead automorphisms
##
#H  @(#)$Id: Whitehd.gd,v 1.1 2005/02/22 15:23:33 gap Exp $
##
#Y  2004 - 2005
##
Revision.("fga/lib/Whitehd_gd") :=
    "@(#)$Id: Whitehd.gd,v 1.1 2005/02/22 15:23:33 gap Exp $";

DeclareAttribute( "FGA_WhiteheadParams", IsGroupHomomorphism );
DeclareAttribute( "FGA_WhiteheadAutomorphisms", IsFreeGroup );
DeclareAttribute( "FGA_NielsenAutomorphisms", IsFreeGroup );

DeclareGlobalFunction( "FGA_WhiteheadAutomorphism" );
DeclareGlobalFunction( "FGA_WhiteheadAnalyse" );
DeclareGlobalFunction( "FGA_WhiteheadToPQOU" );
DeclareGlobalFunction( "FGA_NikToPQ" );
DeclareGlobalFunction( "FGA_TiToPQ" );
DeclareGlobalFunction( "FGA_ExtSymListRepToPQO" );
DeclareGlobalFunction( "FGA_CurryAutToPQOU" );
