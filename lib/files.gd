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

#C  IsDirectory	. . . . . . . . . . . . . . . . . . . category of directories
##
IsDirectory := NewCategory(
    "IsDirectory",
    IsObject );


#############################################################################
##
#V  DirectoriesFamily . . . . . . . . . . . . . . . . . family of directories
##
DirectoriesFamily := NewFamily( "DirectoriesFamily" );


#############################################################################
##

#O  Directory( <string> ) . . . . . . . . . . . . . . .  new directory object
##
Directory := NewOperation(
    "Directory",
    [ IsString ] );


#############################################################################
##
#O  Filename( <list>, <string> )  . . . . . . . . . . . . . . . . find a file
##
Filename := NewOperation(
    "Filename",
    [ IsList, IsString ] );


#############################################################################
##
#O  Read( <string> )  . . . . . . . . . . . . . . . . . . . . . . read a file
##
Read := NewOperation(
    "Read",
    [ IsString ] );


#############################################################################
##
#O  ReadTest( <string> )  . . . . . . . . . . . . . . . . .  read a test file
##
ReadTest := NewOperation(
    "ReadTest",
    [ IsString ] );


#############################################################################
##

#F  DirectoriesLibrary( <name> )  . . . . . . . .  directories of the library
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
#F  DirectoriesPackagePrograms( <name> )  . . . . directories of the packages
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
#F  DirectoriesPackageLibrary( <name>, <path> ) . directories of the packages
##
DirectoriesPackageLibrary := function( arg )
    local   name,  path,  dirs,  dir;

    name := arg[1];
    if 1 = Length(arg)  then
        path := "lib";
    elif 2 = Length(arg)  then
        path := arg[2];
    else
        Error( "DirectoriesPackageLibrary( <name> [,<path>] )" );
    fi;

    if '\\' in name or ':' in name  then
        Error( "<name> must not contain '\\' or ':'" );
    fi;
    dirs := [];
    for dir  in GAP_ROOT_PATHS  do
        path := Concatenation( dir, "pkg/", name, "/", path );
        Add( dirs, Directory(path) );
    od;
    return dirs;
end;


#############################################################################
##

#F  CreateCompletionFiles( <path> ) . . . . . . .  create "lib/compX.g" files
##
CreateCompletionFiles := function( arg )
    local   path,  input,  i,  com,  read,  j,  crc;

    # get the path to the output
    if 0 = Length(arg)  then
        path := DirectoriesLibrary("")[1];
    elif 1 = Length(arg)  then
        path := Directory(arg[1]);
    fi;
    input := DirectoriesLibrary("");

    # loop over the list of completable files
    for i  in COMPLETABLE_FILES  do

        # convert "read" into "comp"
        com := Filename( path, ReplacedString( i[1], "read", "comp" ) );
        if com = fail  then
            Error( "cannot create output file" );
        fi;
        Print( "#I  converting \"", i[1], "\" to \"", com, "\"\n" );

        # now find the input file
        read := List( i[2], x -> [ x, Filename( input, x ) ] );
        if ForAny( read, x -> x[2] = fail )  then
            Error( "cannot locate input files" );
        fi;

        # create the completion files
        PRINT_TO( com, "# completion of \"", i[1], "\"\n" );
        APPEND_TO( com, "RANK_FILTER_LIST := ", i[3], ";\n" );
        for j  in read  do

            # create a crc value
            Print( "#I    parsing \"", j[1], "\"\n" );
            crc := GAP_CRC(j[2]);

            # create header
            APPEND_TO( com, "COM_RESULT := COM_FILE( \"", j[1], "\", ",
                crc, " );\n", "if not IsBound(COM_RESULT)  then\nError(\"",
                "cannot locate file \\\"", j[1], "\\\"\");\nelif ",
                "COM_RESULT ", " = 3  then\n" );

            # create completion
            MAKE_INIT( com, j[2] );

            APPEND_TO( com, "fi;\n" );
        od;
    od;
end;


#############################################################################
##

#E  files.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
