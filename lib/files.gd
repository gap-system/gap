#############################################################################
##
#W  files.gd                    GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for files and directories.
##
Revision.files_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsDirectory
##
IsDirectory := NewCategory(
    "IsDirectory",
    IsObject );


#############################################################################
##

#V  DirectoriesFamily
##
DirectoriesFamily := NewFamily( "DirectoriesFamily" );


#############################################################################
##

#O  Directory( <string> )
##
Directory := NewOperation(
    "Directory",
    [ IsString ] );


#############################################################################
##
#O  Filename( <list>, <string> )
##
Filename := NewOperation(
    "Filename",
    [ IsList, IsString ] );


#############################################################################
##
#O  Read( <string> )
##
Read := NewOperation(
    "Read",
    [ IsString ] );


#############################################################################
##
#O  ReadTest( <string> )
##
ReadTest := NewOperation(
    "ReadTest",
    [ IsString ] );


#############################################################################
##

#F  DirectoriesLibrary( <name> )
##
DIRECTORIES_LIBRARY := rec();

DirectoriesLibrary := function( arg )
    local   name,  dirs,  dir,  path;

    if 0 = Length(arg)  then
        name := "lib";
    elif 1 = Length(arg)  then
        name := arg[1];
    else
        Error( "DirectoriesLibrary( [<name>] )" );
    fi;

    if '\\' in name or ':' in name  then
        Error( "<name> must not contain '\\' or ':'" );
    fi;
    if not IsBound(DIRECTORIES_LIBRARY.(name))  then
        dirs := [];
        for dir  in GAP_ROOT_PATHS  do
            path := Concatenation( dir, name );
            Add( dirs, Directory(path) );
        od;
        DIRECTORIES_LIBRARY.(name) := Immutable(dirs);
    fi;

    return DIRECTORIES_LIBRARY.(name);
end;


#############################################################################
##
#F  DirectoriesPackagePrograms( <name> )
##
DirectoriesPackagePrograms := function( name )
    local   arch,  dirs,  dir,  path;

    arch := GAP_ARCHITECTURE;
    dirs := [];
    for dir  in GAP_ROOT_PATHS  do
        path := Concatenation( dir, "pkg/", name, "/bin/", arch, "/" );
        Add( dirs, Directory(path) );
    od;
    return dirs;
end;


#############################################################################
##

#E  files.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
