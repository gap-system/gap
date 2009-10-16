#############################################################################
##
#W    init.g            share package 'ipcq'  
##

#############################################################################
##
#D Declare the package
##
DeclarePackage( "ipcq", "1.0", function() return true; end );
DeclarePackageDocumentation( "ipcq", "doc" );

#############################################################################
##
#D Require used share packages
##
pc := RequirePackage("polycyclic");
ve := RequirePackage("vecenum");
ac := RequirePackage("aclib");

#############################################################################
##
#D The Banner
##
if BANNER and not QUIET then
    ReadPkg("ipcq", "gap/banner.g");
fi;


#############################################################################
##
#D Read .gd files
##
ReadPkg("ipcq", "gap/ipcq.gd");

#############################################################################
##
#D Global Vars
##
CHECKIPCQ := false;
