#############################################################################
##
#W  package.g                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains support for share packages.
##
Revision.package_g :=
    "@(#)$Id$";


#############################################################################
##

#F  RequirePackage( <name> )  . . . . . . . . . . . . locate and load package
##
LOADED_PACKAGES := rec();

RequirePackage := function( name )
    local   init,  path;

    # load it only once
    if IsBound(LOADED_PACKAGES.(name))  then
        return;
    fi;

    # locate the init file
    path := DirectoriesPackageLibrary(name,"");
    if path = fail  then
        Error( "package \"", name, "\" is not installed" );
    fi;
    init := Filename( path, "init.g" );
    if init = fail  then
        Error( "cannot locate \"init.g\", please check the installation" );
    fi;

    # and read it
    LOADED_PACKAGES.(name) := path;
    Read(init);

end;


#############################################################################
##
#F  ReadPkg( <name>, <file> ) . . . . . . . . . . . . . . load a package file
##
ReadPkg := function( arg )
    local   file;

    # unravel the argument
    if IsList(arg[1]) and not IsString(arg[1]) then
        arg := arg[1];
    fi;

    # check that we know the package
    if not IsBound(LOADED_PACKAGES.(arg[1]))  then
        Error( "package \"", arg[1], "\" not loaded" );
    fi;

    # and read the file
    file := Filename( LOADED_PACKAGES.(arg[1]), arg[2] );
    if file = fail  then
       Error("cannot locate file \"",arg[2],"\" in package \"",arg[1],"\"");
    fi;

    # read it
    Read(file);

end;

#############################################################################
##
#F  RereadPkg( <name>, <file> ) . . . . . . . . . . . . reload a package file
##
##  This and the previous function could probably be done with less repetition
##
RereadPkg := function( arg )
    local   file;

    # unravel the argument
    if IsList(arg[1]) and not IsString(arg[1]) then
        arg := arg[1];
    fi;

    # check that we know the package
    if not IsBound(LOADED_PACKAGES.(arg[1]))  then
        Error( "package \"", arg[1], "\" not loaded" );
    fi;

    # and read the file
    file := Filename( LOADED_PACKAGES.(arg[1]), arg[2] );
    if file = fail  then
       Error("cannot locate file \"",arg[2],"\" in package \"",arg[1],"\"");
    fi;

    # read it
    Reread(file);

end;

#############################################################################
##
#F  DeclarePackageDocumentation( <pkg>, <doc> ) . . location of documentation
##
DeclarePackageDocumentation := function( pkg, doc )

    # check that the package is loaded
    if not IsBound(LOADED_PACKAGES.(pkg))  then
        Error( "package \"", pkg, "\" not loaded" );
    fi;

    # declare the location
    Append( HELP_BOOKS, [ 
        pkg,
        Concatenation( "pkg/", pkg, "/", doc ),
        Concatenation( "Share Package `", pkg, "'" ) ] );
end;




#############################################################################
##

#E  package.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
