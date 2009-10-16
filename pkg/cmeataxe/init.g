#############################################################################
##
#W  init.g                 share package 'cmeataxe'             Thomas Breuer
##
#H  @(#)$Id: init.g,v 1.1 2000/04/19 09:07:19 gap Exp $
##

# Announce the package version.
DeclarePackage( "cmeataxe", "2.4", function()

#T check the version of the standalones!
#T (mringe!!)

    return true;
end );

# Install the documentation.
DeclarePackageAutoDocumentation( "cmeataxe", "doc" );


#############################################################################
##
#E

