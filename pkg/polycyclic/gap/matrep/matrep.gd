#############################################################################
##
##  This defines the operation for computing (lower) unitriangular
##  matrix representations for finitely generated torsion-free nilpotent
##  groups.
##
#G  UnitriangularMatrixRepresentation . . . . . . . . . . . . . . . . . . . .
##
DeclareOperation( "UnitriangularMatrixRepresentation", [IsGroup] );

DeclareProperty( "IsHomomorphismIntoMatrixGroup", 
                  IsGroupGeneralMappingByImages );

DeclareGlobalFunction( "IsMatrixRepresentation" );
