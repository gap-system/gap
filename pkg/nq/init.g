#############################################################################
##
#W    init.g               GAP 4 package 'nq'                   Werner Nickel
##
##    @(#)$Id: init.g,v 1.20 2007/02/06 18:06:30 werner Exp $
##

##
##    Announce the package version and test for the existence of the package 
##    polycyclic and the binary.
##
DeclarePackage( "nq", "2.2",

  function()
    local   path;
    
    if TestPackageAvailability( "GAPDoc", "" ) = fail then
        Info( InfoWarning, 1, 
              "Loading the nq package: GAPDoc not available" );
    fi;

    if TestPackageAvailability( "polycyclic", "1.0" ) = fail then
        Info( InfoWarning, 1, 
              "Loading the nq package: package polycyclic must be available" );
        return fail;
    fi;

    # test for existence of the compiled binary
    path := DirectoriesPackagePrograms( "nq" );

    if Filename( path, "nq" ) = fail then
        Info( InfoWarning, 1,
              "Package ``nq'': The executable program is not available" );
        return fail;
    fi;

    return true;
end );

# install the documentation
DeclarePackageDocumentation( "nq", "doc", "ANU NQ", 
        "Computation of nilpotent quotients" );


if IsList( TestPackageAvailability( "polycyclic", "1.0" ) ) then
    HideGlobalVariables( "BANNER" );
    BANNER := false;
    RequirePackage( "polycyclic" );
    UnhideGlobalVariables( "BANNER" );
fi;

if IsList( TestPackageAvailability( "GAPDoc", "" ) ) then
    HideGlobalVariables( "BANNER" );
    BANNER := false;
    RequirePackage( "GAPDoc", "" );
    UnhideGlobalVariables( "BANNER" );
fi;

ReadPkg("nq", "gap/nq.gd");
ReadPkg("nq", "gap/exptree.gd");
