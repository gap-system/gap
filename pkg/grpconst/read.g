#############################################################################
##
#W    read.g               share package 'grpconst'        Hans Ulrich Besche
##                                                               Bettina Eick

#############################################################################
##
## the banner
##
if not QUIET and BANNER then
    ReadPkg( "grpconst", "gap/banner.g");
fi;

#############################################################################
##
## files containing the Frattini extension method
##
ReadPkg( "grpconst", "gap/irred.gi");
ReadPkg( "grpconst", "gap/intdiv.gi");
ReadPkg( "grpconst", "gap/semisim.gi");
ReadPkg( "grpconst", "gap/fratfree.gi");
ReadPkg( "grpconst", "gap/risotest.gi");
ReadPkg( "grpconst", "gap/frattext.gi");
ReadPkg( "grpconst", "gap/disting.gi");

#############################################################################
##
## files containing the cyclic split extension method
##
ReadPkg( "grpconst/gap/cycl.gi");

#############################################################################
##
## files containing the upwards extension method
##
ReadPkg( "grpconst/gap/upext.gi");
ReadPkg( "grpconst/gap/nocentre.gi");

#############################################################################
##
## files containing the main header function
##
ReadPkg( "grpconst", "gap/grpconst.gi");
