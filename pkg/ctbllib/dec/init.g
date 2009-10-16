##############################################################################
##
#W  init.g                                                       Thomas Breuer
##
#H  @(#)$Id: init.g,v 1.3 2007/08/01 11:22:56 gap Exp $
##
#Y  Copyright  (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  The formatting information can be found in `format.g'.
##  Declarations and implementation of the functions needed can be found in
##  `make.gd' and `make.gi', respectively.
##

ReadPackage( "ctbllib", "ctbltoc/init.g" );
ReadPackage( "ctbllib", "dec/gap/format.g" );
ReadPackage( "ctbllib", "dec/gap/make.gd"  );
ReadPackage( "ctbllib", "dec/gap/make.gi"  );


HTMLDataDirectory := Directory(
    "/usr/local/www-homes/Thomas.Breuer/ctbllib/dec/tex/" );

HTMLDataDirectoryLocal := DirectoriesPackageLibrary(
    "ctbllib", "dec/tex/" )[1];


##############################################################################
##
#E

