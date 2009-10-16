#############################################################################
##
#W    init.g                 The Example package                Werner Nickel
#W                                                                Greg Gamble
##
##    @(#)$Id: init.g,v 4.11 2006/01/31 11:18:12 gap Exp $
##

#############################################################################
##  Starting from GAP 4.4 and having  a  PackageInfo.g  file  available,  the
##  commands  `DeclarePackage'  and   `DeclarePackageAutoDocumentation'   are
##  ignored. They are substituted by the entries:
##   .PackageName, .Version, .PackageDoc, .Dependencies and .AvailabilityTest
##  specified in the PackageInfo.g file.
##
##  Since GAP 4.4, commands with `Pkg' in their name have `Package'  instead,
##  e.g. `ReadPkg' became `ReadPackage'.
##

#############################################################################
##
#R  Read the declaration files.
##
ReadPackage( "example", "gap/files.gd" );

#E  init.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here

