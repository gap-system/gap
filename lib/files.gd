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
#O  ReadAsFunction( <string> )  . . . . . . . . . . . read a file as function
##
ReadAsFunction := NewOperation(
    "ReadAsFunction",
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
            if IsDirectoryPath(path) = true  then
                Add( dirs, Directory(path) );
            fi;
        od;
        if 0 < Length(dirs)  then
            DIRECTORIES_LIBRARY.(name) := Immutable(dirs);
        else
            return fail;
        fi;
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
    local   name,  path,  dirs,  dir,  tmp;

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
        tmp := Concatenation( dir, "pkg/", name, "/", path );
        if IsDirectoryPath(path) = true  then
            Add( dirs, Directory(tmp) );
        fi;
    od;
    if 0 < Length(dirs)  then
        return dirs;
    else
        return fail;
    fi;
end;


#############################################################################
##
#F  DirectoriesSystemPrograms() . . . . .  directories of the system programs
##
DIRECTORIES_PROGRAMS := false;

DirectoriesSystemPrograms := function()
    if DIRECTORIES_PROGRAMS = false  then
        DIRECTORIES_PROGRAMS := List( DIRECTORIES_SYSTEM_PROGRAMS,
                                      x -> Directory(x) );
    fi;
    return DIRECTORIES_PROGRAMS;
end;


#############################################################################
##
#F  DirectoryTemporary( <hint> )  . . . . . . .  create a temporary directory
##
DIRECTORIES_TEMPORARY := [];

DirectoryTemporary := function( arg )
    local   dir;

    # check arguments
    if 1 < Length(arg)  then
        Error( "usage: DirectoryTemporary( [<hint>] )" );
    fi;

    # create temporary directory
    dir := TmpDirectory();
    if dir = fail  then
        return fail;
    fi;

    # remember directory name and return
    Add( DIRECTORIES_TEMPORARY, dir );
    return Directory(dir);
end;


#T THIS IS A HACK UNTIL 'RemoveDirectory' IS AVAILABLE
InputTextNone := "2b defined";
OutputTextNone := "2b defined";
Process := "2b defined";

InstallAtExit( function()
    local    i,  input,  output,  tmp,  rm,  proc;

    input  := InputTextNone();
    output := OutputTextNone();
    tmp    := Directory("/tmp");
    rm     := Filename( DirectoriesSystemPrograms(), "rm" );
    if rm = fail  then
        Print("#W  cannot execute 'rm' to remove temporary directories\n");
        return;
    fi;

    for i  in DIRECTORIES_TEMPORARY  do
        proc := Process( tmp, rm, input, output, [ "-rf", i ] );
    od;

end );


#############################################################################
##
#F  DirectoryCurrent()  . . . . . . . . . . . . . . . . . . current directory
##
#T  THIS IS A HACK (will not work if SetDirectoryCurrent is implemented)
DIRECTORY_CURRENT := false;

DirectoryCurrent := function()
    if IsBool(DIRECTORY_CURRENT)  then
        DIRECTORY_CURRENT := Directory("./");
    fi;
    return DIRECTORY_CURRENT;
end;


#############################################################################
##

#F  CrcFile( <filename> ) . . . . . . . . . . . . . . . . .  create crc value
##
CrcFile := function( name )
    if IsReadableFile(name) <> true  then
        return fail;
    fi;
    return GAP_CRC(name);
end;


#############################################################################
##
#F  LoadDynamicModule( <filename> ) . . . . . . . . . . . . . . load a module
##
LoadDynamicModule := function( arg )

    if Length(arg) = 1  then
        if not LOAD_DYN( arg[1], false )  then
            Error( "no support for dynamic loading" );
        fi;
    elif Length(arg) = 2  then
        if not LOAD_DYN( arg[1], arg[2] )  then
            Error( "<crc> mismatch (or no support for dynamic loading)" );
        fi;
    else
        Error( "usage: LoadDynamicModule( <filename> )" );
    fi;

end;


#############################################################################
##

#F  CreateCompletionFiles( <path> ) . . . . . . . create "lib/readX.co" files
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
        com := Filename( path, ReplacedString( i[1], ".g", ".co" ) );
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
