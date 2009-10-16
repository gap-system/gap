#############################################################################
##
#W  read.g                 Interface to Carat                   Franz G"ahler
##
#Y  Copyright (C) 1999-2006,  Franz G"ahler,       ITAP, Stuttgart University
##

# location of Carat binaries
BindGlobal( "CARAT_BIN_DIR", DirectoriesPackagePrograms( "carat" ) );

# directory for temporary files created by interface routines
BindGlobal( "CARAT_TMP_DIR", DirectoryTemporary() );

# low level Carat interface routines
ReadPackage( "carat", "gap/carat.gi" );

# methods for functions declared in GAP library
ReadPackage( "carat", "gap/methods.gi" );


