#############################################################################
##
#A  init.g                  Cryst library                        Bettina Eick
#A                                                              Franz Gaehler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##               Cryst - the crystallographic groups package
##  
##                            GAP 4 Version
##

#############################################################################
##
#R  read the declaration files
##
ReadPackage( "cryst", "gap/cryst.gd" );    # declarations for AffineCrystGroups
ReadPackage( "cryst", "gap/hom.gd" );      # declarations for homomorphism
ReadPackage( "cryst", "gap/wyckoff.gd" );  # declarations for Wyckoff position
ReadPackage( "cryst", "gap/zass.gd" );     # declarations for Zassenhaus alg.
ReadPackage( "cryst", "gap/max.gd" );      # declarations for maximal subgroups
ReadPackage( "cryst", "gap/color.gd" );    # declarations for color groups
ReadPackage( "cryst", "gap/equiv.gd" );    # isomorphism test for space groups
ReadPackage( "cryst", "grp/spacegrp.gd" ); # the IT space group catalogue
