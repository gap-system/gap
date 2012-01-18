#############################################################################
##
#W    init.g            GAP 4 package 'polycyclic'               Bettina Eick
#W                                                              Werner Nickel
#W                                                                   Max Horn
##


#############################################################################
##
#D Read .gd files
##
ReadPkg( "polycyclic", "gap/matrix/matrix.gd");
ReadPkg( "polycyclic", "gap/basic/infos.gd");
ReadPkg( "polycyclic", "gap/basic/collect.gd");
ReadPkg( "polycyclic", "gap/basic/pcpelms.gd");
ReadPkg( "polycyclic", "gap/basic/pcpgrps.gd");
ReadPkg( "polycyclic", "gap/basic/pcppcps.gd");
ReadPkg( "polycyclic", "gap/basic/grphoms.gd");
ReadPkg( "polycyclic", "gap/basic/basic.gd");
ReadPkg( "polycyclic", "gap/cohom/cohom.gd");
ReadPkg( "polycyclic", "gap/matrep/matrep.gd");
ReadPkg( "polycyclic", "gap/matrep/unitri.gd");
ReadPkg( "polycyclic", "gap/pcpgrp/pcpgrp.gd");
ReadPkg( "polycyclic", "gap/exam/exam.gd");

#############################################################################
##
#R  Compatibility mode
##
##    With 4.5, calcreps2 has been renamed to Calcreps2. Since we use it,
##    we have to declare it here.
##
if not CompareVersionNumbers( GAPInfo.Version, "4.5.0") then
    if not IsBound( Calcreps2 ) then
        DeclareSynonym( "Calcreps2", calcreps2 );
    fi;
fi;
