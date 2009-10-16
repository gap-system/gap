
# utilities implemented elsewhere
RequirePackage( "genus" );    # because of `SizesSimpleGroupsInfo'
RequirePackage( "atlasrep" ); # because of `CurrentDateTimeString'


##############################################################################
##
#V  HTMLDataDirectory
#V  HTMLDataDirectoryLocal
##
HTMLDataDirectory := Directory(
    "/usr/local/www-homes/Thomas.Breuer/ctbllib/ctbldata/" );

HTMLDataDirectoryLocal := DirectoriesPackageLibrary(
    "ctbllib", "ctbltoc" )[1];


##############################################################################
##

#  utilities implemented here
ReadPkg( "ctbllib", "ctbltoc/gap/htmlutil.g" );

# the functions themselves
ReadPkg( "ctbllib", "ctbltoc/gap/htmltbl.g" );


##############################################################################
##
#E

