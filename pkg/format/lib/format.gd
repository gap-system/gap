#############################################################################
##
#W  format.gd                        FORMAT                      Bettina Eick
#W                                      conversion from GAP3 by C.R.B. Wright 
##
Revision.("format/lib/format.gd") :=
    "@(#)$Id: format.gd,v 1.5 2000/10/31 17:16:29 gap Exp $";

#############################################################################
##
#I InfoForm
##
DeclareInfoClass( "InfoForm" );
# SetInfoLevel(InfoForm, 1);

#############################################################################
#C IsFormation
##
DeclareCategory("IsFormation", IsObject);

#############################################################################
#R IsFormationRep( <rep> )
##
DeclareRepresentation("IsFormationRep",
IsFormation and IsComponentObjectRep and IsAttributeStoringRep, []);

#############################################################################
#V FormationFamily( <obj> )
##
FormationFamily:=NewFamily("FamilyOfFormations", IsFormation); 

#############################################################################
#V FormationType( <obj> )
##
FormationType:=NewType(FormationFamily, IsFormation and IsFormationRep);

#############################################################################

#############################################################################
#A NameOfFormation( <formation> )
##
DeclareAttribute("NameOfFormation", IsFormation);

#############################################################################
#A ScreenOfFormation( <formation> )
##
DeclareAttribute("ScreenOfFormation", IsFormation);

#############################################################################
#A SupportOfFormation( <formation> )
##
DeclareAttribute("SupportOfFormation", IsFormation);

#############################################################################
#A ResidualFunctionOfFormation( <formation> )
##
DeclareAttribute("ResidualFunctionOfFormation", IsFormation);

#############################################################################
#A NilpotentResidual( <group> )
##
DeclareAttribute("NilpotentResidual", IsGroup);

#############################################################################
#A ElementaryAbelianProductResidual( <group> )
##
DeclareAttribute("ElementaryAbelianProductResidual", IsGroup);


#############################################################################

#############################################################################
#P IsIntegrated( <formation> )
##
DeclareProperty("IsIntegrated", IsFormation);


#############################################################################

#############################################################################
#O  ResidualWrtFormation( <group>, <formation> ) 
##
KeyDependentOperation("ResidualWrtFormation", IsGroup, IsFormation, ReturnTrue);

#############################################################################
#O  PResidual( <group>, <prime> )
##
KeyDependentOperation("PResidual", IsGroup, IsPosInt, "prime");

#############################################################################
#O  PiResidual( <group>, <primes> )
##
KeyDependentOperation("PiResidual", IsGroup, IsList, ReturnTrue);

#############################################################################
#O  AbelianExponentResidual( <group> )
##
KeyDependentOperation("AbelianExponentResidual", 
  IsGroup, IsPosInt, ReturnTrue);

#############################################################################
#O  FNormalizerWrtFormation( <group>, <formation> )
##
KeyDependentOperation("FNormalizerWrtFormation", 
  IsGroup, IsFormation, ReturnTrue);

#############################################################################
#O  CoveringSubgroup1( <group>, <formation> )
##
KeyDependentOperation("CoveringSubgroup1", IsGroup, IsFormation, ReturnTrue);

#############################################################################
#O  CoveringSubgroup2( <group>, <formation> )
##
KeyDependentOperation("CoveringSubgroup2", 
  IsGroup, IsFormation, ReturnTrue);

#############################################################################

##  for general.gi

#############################################################################
#O  PPart( <element>, <prime> )
##
DeclareOperation("PPart", [IsMultiplicativeElementWithInverse, IsPosInt]);

#############################################################################
#O  PPrimePart( <element>, <prime> )
##
DeclareOperation("PPrimePart", [IsMultiplicativeElementWithInverse, 
  IsPosInt]);

#############################################################################
#O  PiPrimePart( <element>, <primes> )
##
DeclareOperation("PiPrimePart", [IsMultiplicativeElementWithInverse, IsList]);

#############################################################################
#O  CoprimeResidual( <group>, <primes> )
##
DeclareOperation("CoprimeResidual", [IsGroup, IsList]);

#############################################################################
#F  FCommutatorPcgs. . . . . . . . . . . . . . . . . . . . . . . . . . .local
##
DeclareGlobalFunction("FCommutatorPcgs");

#############################################################################
#F  FCentralTest. . . . . . . . . . . . . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("FCentralTest");

#############################################################################
#F  FExponents. . . . . . . . . . . . . . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("FExponents");

#############################################################################
#O  GpByNiceMonomorphism( <nice>, <grp> )
## 
##  Same as undocumented GroupByNiceMonomorphism from the library.
DeclareOperation(
    "GpByNiceMonomorphism",
    [ IsGroupHomomorphism, IsGroup ] );

##  for formation.gi

#############################################################################
#O  FormationObj( <record> )
##
DeclareOperation("FormationObj", [IsRecord]);

#############################################################################
#O  Formation( <object> )
##  various argument possibilities
DeclareOperation("Formation", [IsObject]);

#############################################################################
#O  ProductOfFormations( <formation>, <formation> )
##
DeclareOperation("ProductOfFormations", [IsFormation,IsFormation]);

#############################################################################
#O  Integrated( <formation> )
##
DeclareOperation("Integrated", [IsFormation]);

#############################################################################
#O  ChangedSupport( <formation>, <primes> )
##
DeclareOperation("ChangedSupport",[IsFormation,IsList]);

## for residual.gi

#############################################################################
#O  ResidualSubgroupFromScreen( <group>, <formation> )
##
DeclareOperation("ResidualSubgroupFromScreen", [IsGroup, 
  IsFormation and HasScreenOfFormation]);

## for normalizer.gi

#############################################################################
#F  NormalizedPcgs. . . . . . . . . . . . . . . . . . . . . . . . . . . local
##  Returns equivalent induced pcgs with leading coefficients 1.
DeclareGlobalFunction("NormalizedPcgs");

#############################################################################
#F  InducedNilpotentSeries. . . . . . . . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("InducedNilpotentSeries" );

#############################################################################
#F  LeastBadFNormalizerIndex. . . . . . . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("LeastBadFNormalizerIndex");

#############################################################################
#F  ChangeGenerator. . . . . . . . . . . . . . . . . . . . . . . . . . .local
##
DeclareGlobalFunction("ChangeGenerator");

#############################################################################
#F  RefinedBaseLayer. . . . . . . . . . . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("RefinedBaseLayer");

#############################################################################
#F  FSystem. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .local
##
DeclareGlobalFunction("FSystem");

#############################################################################
#A  SystemNormalizer( <group >)
##
DeclareAttribute("SystemNormalizer", IsGroup);

## for covering.gi  

#############################################################################
#O  CoveringSubgroupWrtFormation( <group>, <formation> )
##
DeclareOperation("CoveringSubgroupWrtFormation", 
  [IsGroup, IsFormation and HasScreenOfFormation]);

#############################################################################
#A  CarterSubgroup( <group> )
##
DeclareAttribute("CarterSubgroup", IsGroup);

#E  End of format.gd
