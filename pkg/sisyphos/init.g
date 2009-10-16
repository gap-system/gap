#############################################################################
##
#W  init.g                 share package 'sisyphos'          Martin Wursthorn
##
#H  @(#)$Id: init.g,v 1.1 2000/10/23 17:05:00 gap Exp $
##

# Announce the package version.
DeclarePackage( "sisyphos", "0.8", function()
    local path, file;

    # Test for existence of the compiled binary.
    path:= DirectoriesPackagePrograms( "sisyphos" );
    file:= Filename( path, "sis" );
    if file = fail then
      Info( InfoWarning, 1,
            "Package ``sisyphos'': The program `sis' is not compiled");
      return false;
    fi;
    return true;
end );

# Install the documentation.
# DeclarePackageAutoDocumentation( "sisyphos", "doc" );

# Read the banner.
ReadPkg( "sisyphos", "banner.g" );

# Read the declaration part.
ReadPkg( "sisyphos", "gap/callsis.gd" );
ReadPkg( "sisyphos", "gap/sisyphos.gd" );


#############################################################################
##
#E

