#############################################################################
##
#W  init.g               share package 'itc'                   Volkmar Felsch
##
#H  @(#)$Id: init.g,v 1.8 2004/01/06 10:35:20 gap Exp $
##

# Announce the package version and test for the existence of the binary.
DeclarePackage( "itc", "1.4",
    function()
      local test;
      test:= TestPackageAvailability( "xgap", "4.02" );
      if   test = fail then
        Info( InfoWarning, 1,
          "Package `itc' needs share package `xgap' version at least 4.02" );
      elif test <> true then
        Info( InfoWarning, 1,
          "Package `itc' must be loaded from XGAP" );
      fi;
      return test = true;
    end );

# Install the documentation.
DeclarePackageAutoDocumentation( "itc", "doc" );

# read the actual code. 
ReadPkg( "itc/gap/itc.gd" );
ReadPkg( "itc/gap/itc.gi" );

