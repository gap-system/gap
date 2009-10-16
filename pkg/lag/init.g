#############################################################################
##  
#W    init.g                 The LAG package                     Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##


# declare package name and version, enable automatic loading when GAP starts
DeclareAutoPackage("lag", "3.0", true);

# install the documentation
DeclarePackageAutoDocumentation( "lag", "doc" );

if BANNER and not QUIET then
  ReadPkg("lag", "lib/banner.g");
fi;

# read the function declarations
ReadPkg("lag/lib/lag.gd");

# read the other part of code
ReadPkg("lag/lib/lag.g");
