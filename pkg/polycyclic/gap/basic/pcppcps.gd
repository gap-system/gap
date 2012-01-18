#############################################################################
##
#W  pcppcgs.gd                   Polycyc                         Bettina Eick
##

#############################################################################
##
## induced and canonical generating sets + parallel versions
##
DeclareGlobalFunction( "AddToIgs" );
DeclareGlobalFunction( "AddToIgsParallel" );
DeclareGlobalFunction( "IgsParallel" );
DeclareGlobalFunction( "CgsParallel" );

#############################################################################
##
## Introduce the category and representation of Pcp's
##
DeclareCategory( "IsPcp", IsObject );
DeclareRepresentation( "IsPcpRep",
                        IsComponentObjectRep,
                        ["gens", "rels", "denom", "numer", "one", "group" ] );

#############################################################################
##
## Create their family and their type
##
BindGlobal( "PcpFamily", NewFamily( "PcpFamily", IsPcp, IsPcp ) );
BindGlobal( "PcpType", NewType( PcpFamily, IsPcpRep ) );

#############################################################################
##
## Basic attributes and properties
##
DeclareGlobalFunction( "GeneratorsOfPcp" );
DeclareGlobalFunction( "RelativeOrdersOfPcp" );
DeclareGlobalFunction( "DenominatorOfPcp" );
DeclareGlobalFunction( "NumeratorOfPcp" );
DeclareGlobalFunction( "GroupOfPcp" );
DeclareGlobalFunction( "OneOfPcp" );

DeclareGlobalFunction( "IsSNFPcp" );
DeclareGlobalFunction( "IsTailPcp" );

#############################################################################
##
## The main function to create an pcp 
##
DeclareGlobalFunction( "Pcp" );

#############################################################################
##
## Introduce two global variables to steer the usage of pcps
##
if not IsBound( USE_NORMED_PCS ) then USE_NORMED_PCS := false; fi;
if not IsBound( USE_CANONICAL_PCS ) then USE_CANONICAL_PCS := true; fi;
