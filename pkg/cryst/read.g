#############################################################################
##
#A  read.g                    Cryst library                     Bettina Eick
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
#R  read the general stuff for integer matrix groups
##
ReadPackage( "cryst", "gap/common.gi" );  # routines for integral matrices

#############################################################################
##
#R  read the crystallographic groups specific functions
##
ReadPackage( "cryst", "gap/hom.gi" );     # methods for PointHomomorphisms
ReadPackage( "cryst", "gap/cryst.gi" );   # methods for CrystGroups
ReadPackage( "cryst", "gap/cryst2.gi" );  # more methods for CrystGroups
ReadPackage( "cryst", "gap/fpgrp.gi" );   # FpGroup for CrystGroups 
                                          # and PointGroups
ReadPackage( "cryst", "gap/zass.gi" );    # methods for Zassenhaus algorithm
ReadPackage( "cryst", "gap/max.gi" );     # methods for maximal subgroups
ReadPackage( "cryst", "gap/wyckoff.gi" ); # methods for Wyckoff positions
ReadPackage( "cryst", "gap/color.gi" );   # methods for color groups

if IsBound( GAPInfo.PackagesLoaded.xgap ) then
  ReadPackage( "cryst", "gap/wypopup.gi" ); # popup menu for Wyckoff graph
  ReadPackage( "cryst", "gap/wygraph.gi" ); # Wyckoff graph methods; needs XGAP
else
  ReadPackage( "cryst", "gap/noxgap.gi" );  # dummy for WyckoffGraph
fi;

if IsBound( GAPInfo.PackagesLoaded.polycyclic ) then
  # PcpGroup for CrystGroups and PointGroups
  ReadPackage( "cryst", "gap/pcpgrp.gi" );
fi;

#############################################################################
##
#R  read the orbit stabilizer methods
##
ReadPackage( "cryst", "gap/orbstab.gi" ); # Orbit, Stabilizer & Co.
ReadPackage( "cryst", "gap/equiv.gi" );   # conjugator between space groups

#############################################################################
##
#R  load the IT space group catalogue
##
ReadPackage( "cryst", "grp/spacegrp.grp" ); # the catalogue
ReadPackage( "cryst", "grp/spacegrp.gi" );  # access functions
