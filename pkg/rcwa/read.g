#############################################################################
##
#W  read.g                  GAP4 Package `RCWA'                   Stefan Kohl
##
##  Read the implementation part of the package.
##
#############################################################################

ReadPackage( "rcwa", "gap/general.g" );
ReadPackage( "rcwa", "gap/rcwaaux.g" );
ReadPackage( "rcwa", "gap/rcwamap.gi" );
ReadPackage( "rcwa", "gap/rcwamono.gi" );
ReadPackage( "rcwa", "gap/rcwagrp.gi" );

if    IsBound( GAPInfo.PackagesLoaded.fr )
  and CompareVersionNumbers( GAPInfo.PackagesLoaded.fr[2], "1.1.3" )
then ReadPackage( "rcwa", "gap/frdepend.gi" ); fi;

#############################################################################
##
#E  read.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here