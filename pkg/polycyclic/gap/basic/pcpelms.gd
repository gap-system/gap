#############################################################################
##
#W  pcpelms.gd                   Polycyc                         Bettina Eick
##

#############################################################################
##
## Introduce the category of pcp elements
##
DeclareCategory( "IsPcpElement", IsMultiplicativeElementWithInverse );
DeclareCategoryFamily( "IsPcpElement" );
DeclareCategoryCollections( "IsPcpElement" );

#############################################################################
##
## Introduce the representation of pcp elements
##
DeclareRepresentation( "IsPcpElementRep", 
                        IsComponentObjectRep,
                        ["collector", 
                         "exponents", 
                         "depth",
                         "leading",
                         "name" ] );

#############################################################################
##
## Operations
##
DeclareOperation( "Exponents",       [ IsPcpElementRep ] );
DeclareOperation( "NameTag",         [ IsPcpElementRep ] );
DeclareOperation( "GenExpList",      [ IsPcpElementRep ] );
DeclareOperation( "Depth",           [ IsPcpElementRep ] );
DeclareOperation( "LeadingExponent", [ IsPcpElementRep ] );

#############################################################################
##
## Some functions
##
DeclareGlobalFunction( "PcpElementConstruction" );
DeclareGlobalFunction( "PcpElementByExponentsNC" );
DeclareGlobalFunction( "PcpElementByExponents" );
DeclareGlobalFunction( "PcpElementByGenExpListNC" );
DeclareGlobalFunction( "PcpElementByGenExpList" );

#############################################################################
##
## Some attributes
##
DeclareAttribute( "TailOfElm",        IsPcpElement );
DeclareAttribute( "RelativeOrderPcp", IsPcpElement );
DeclareAttribute( "RelativeIndex",    IsPcpElement );
DeclareAttribute( "FactorOrder",      IsPcpElement );
 

