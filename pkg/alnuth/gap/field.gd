#############################################################################
##
#W   field.gd           Alnuth - Kant interface                  Bettina Eick
#W                                                             Bjoern Assmann
##

DeclareInfoClass( "InfoAlnuth" );

DeclareRepresentation( "IsBasisOfMatrixField",
                        IsBasis and IsAttributeStoringRep, [] );

DeclareOperation( "ExponentsOfUnits", [IsNumberField, IsCollection] );
DeclareOperation( "RelationLattice", [IsNumberField, IsCollection] );

DeclareProperty( "IsUnitGroup", IsGroup );
DeclareProperty( "IsUnitGroupIsomorphism", IsMapping);
DeclareProperty( "IsNumberFieldByMatrices", IsNumberField );
DeclareProperty( "IsMultGroupByFieldElemsIsomorphism", IsMapping);

DeclareAttribute( "IntegerDefiningPolynomial", IsNumberField );
DeclareAttribute( "IntegerPrimitiveElement", IsNumberField );
DeclareAttribute( "EquationOrderBasis", IsNumberField );
DeclareAttribute( "MaximalOrderBasis", IsNumberField );
DeclareAttribute( "UnitGroup", IsNumberField );
DeclareAttribute( "DefiningPolynomial", IsNumberFieldByMatrices );
DeclareAttribute( "FieldOfUnitGroup", IsGroup );

DeclareGlobalFunction( "FieldOfPolynomial" );
DeclareGlobalFunction( "FieldByMatricesNC" );
DeclareGlobalFunction( "FieldByMatrixBasisNC" );
DeclareGlobalFunction( "FieldByPolynomialNC" );
DeclareGlobalFunction( "FieldByMatrices" );
DeclareGlobalFunction( "FieldByMatrixBasis" );
DeclareGlobalFunction( "FieldByPolynomial" );
DeclareGlobalFunction( "IntersectionOfUnitSubgroups" );
DeclareGlobalFunction( "IntersectionOfTFUnitsByCosets" );
DeclareGlobalFunction( "NormCosetsOfNumberField" );
DeclareGlobalFunction( "IsUnitOfNumberField" );
DeclareGlobalFunction( "RelationLatticeOfTFUnits");
DeclareGlobalFunction( "RelationLatticeModUnits");
DeclareGlobalFunction( "RelationLatticeTF");
DeclareGlobalFunction( "RelationLatticeOfUnits");
DeclareGlobalFunction( "PcpPresentationMultGroupByFieldEl");
DeclareGlobalFunction( "PcpPresentationOfMultiplicativeSubgroup");
