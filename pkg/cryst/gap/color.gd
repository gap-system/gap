#############################################################################
##
#A  color.gd                  Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Cryst - the crystallographic groups package for GAP (color groups)
##  

#############################################################################
##
#P  IsColorGroup( G ) . . . . . . . . . . . . . . . . . .is it a color group?
##
DeclareProperty( "IsColorGroup", IsGroup );

#############################################################################
##
#A  ColorSubgroup( G ) . . . . . . . . . . . . . . extract the color subgroup
##
DeclareAttribute( "ColorSubgroup", IsColorGroup );

#############################################################################
##
#A  ColorCosetList( G ) . . . . . . . . . . . . . .color labelling coset list
##
DeclareAttribute( "ColorCosetList", IsColorGroup );

#############################################################################
##
#A  ColorPermGroup( G ) . . . . . . . . . . . . . . . . . . . color PermGroup
##
DeclareAttribute( "ColorPermGroup", IsColorGroup );

#############################################################################
##
#A  ColorHomomorphism( G ) . . . . . . . . . .homomorphism to color PermGroup
##
DeclareAttribute( "ColorHomomorphism", IsColorGroup );

#############################################################################
##
#F  ColorOfElement( G, elem ) . . . . . . . . . . . . . . color of an element
##
DeclareGlobalFunction( "ColorOfElement" );

#############################################################################
##
#F  ColorGroup( G, H ) . . . . . . . . . . . . . . . . . . make a color group
##
DeclareGlobalFunction( "ColorGroup" );
