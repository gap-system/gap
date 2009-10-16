#############################################################################
##
#A  wyckoff.gd                Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##

#############################################################################
##
#R  IsWyckoffPosition . . . . . . . . . . . . . . . . . . . IsWyckoffPosition
##
DeclareRepresentation( "IsWyckoffPosition", 
    IsComponentObjectRep and IsAttributeStoringRep, 
    [ "basis", "translation", "spaceGroup", "class" ] );

#############################################################################
##
#F  WyckoffPositionObject . . . . . . . . . . .make a Wyckoff position object
##
DeclareGlobalFunction( "WyckoffPositionObject" );

#############################################################################
##
#F  WyckoffSpaceGroup . . . . . . . . . . . . .space group of WyckoffPosition
##
DeclareOperation( "WyckoffSpaceGroup", [ IsWyckoffPosition ] );

#############################################################################
##
#F  WyckoffTranslation . . . . . . . . . .translation of representative space
##
DeclareOperation( "WyckoffTranslation", [ IsWyckoffPosition ] );

#############################################################################
##
#F  WyckoffBasis . . . . . . . . . . . . . . . .basis of representative space
##
DeclareOperation( "WyckoffBasis", [ IsWyckoffPosition ] );

#############################################################################
##
#F  ReduceAffineSubspaceLattice . . . . reduce affine subspace modulo lattice
##
DeclareGlobalFunction( "ReduceAffineSubspaceLattice" );

#############################################################################
##
#F  ImageAffineSubspaceLattice . . . .image of affine subspace modulo lattice
##
DeclareGlobalFunction( "ImageAffineSubspaceLattice" );

#############################################################################
##
#F  ImageAffineSubspaceLatticePointwise . . . . . . image of pointwise affine 
#F                                                    subspace modulo lattice
##
DeclareGlobalFunction( "ImageAffineSubspaceLatticePointwise" );

#############################################################################
##
#A  WyckoffStabilizer . . . . . . . . . stabilizer of representative subspace
##
DeclareAttribute( "WyckoffStabilizer", IsWyckoffPosition );

#############################################################################
##
#F  WyckoffOrbit . . . . . . . . . . . . orbit of pointwise subspace lattices
##
DeclareAttribute( "WyckoffOrbit", IsWyckoffPosition );

#############################################################################
##
#A  WyckoffPositions( <S> ) . . . . . . . . . . . . . . . . Wyckoff positions 
##
DeclareAttribute( "WyckoffPositions", IsAffineCrystGroupOnLeftOrRight );

#############################################################################
##
#F  WyckoffPositionsByStabilizer( S, stabs ) . . Wyckoff pos. for given stabs 
##
DeclareGlobalFunction( "WyckoffPositionsByStabilizer" );

#############################################################################
##
#F  IsWyckoffGraph( G ) . . . . . . . . . . . . . . . . . . . .IsWyckoffGraph 
##
DeclareFilter( "IsWyckoffGraph" );

#############################################################################
##
#F  WyckoffGraphFun( W, def ) . . . . . . . . . . . . display a Wyckoff graph 
##
DeclareGlobalFunction( "WyckoffGraphFun" ); 

#############################################################################
##
#O  WyckoffGraph( S, def ) . . . . . . . . . . . . . .display a Wyckoff graph 
##
DeclareOperation( "WyckoffGraph", 
    [ IsAffineCrystGroupOnLeftOrRight, IsRecord ] );
