#############################################################################
##
#W    init.g               share package 'example'              Werner Nickel
##
##    @(#)$Id: init.g,v 1.1 2000/07/04 11:35:18 sal Exp $
##

# announce the package version 
DeclarePackage("abstract","0.0",
  function()
    return true;
  end);

# install the documentation
DeclarePackageAutoDocumentation( "abstract", "doc" );

