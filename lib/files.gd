#############################################################################
##
#W  files.gd                    GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for files and directories.
##
Revision.files_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsDirectory	. . . . . . . . . . . . . . . . . . . category of directories
##
DeclareCategory(
    "IsDirectory",
    IsObject );


#############################################################################
##
#V  DirectoriesFamily . . . . . . . . . . . . . . . . . family of directories
##
DirectoriesFamily := NewFamily( "DirectoriesFamily" );

#############################################################################
##
#F  USER_HOME_EXPAND . . . . . . . . . . . . .  expand leading ~ in file name
##  
DeclareGlobalFunction("USER_HOME_EXPAND");


#############################################################################
##

#O  Directory( <string> ) . . . . . . . . . . . . . . .  new directory object
##
DeclareOperation(
    "Directory",
    [ IsString ] );


#############################################################################
##
#O  Filename( <list>, <string> )  . . . . . . . . . . . . . . . . find a file
##
DeclareOperation(
    "Filename",
    [ IsList, IsString ] );


#############################################################################
##
#O  Read( <string> )  . . . . . . . . . . . . . . . . . . . . . . read a file
##
DeclareOperation(
    "Read",
    [ IsString ] );


#############################################################################
##
#O  ReadTest( <string> )  . . . . . . . . . . . . . . . . .  read a test file
##
DeclareOperation(
    "ReadTest",
    [ IsString ] );


#############################################################################
##
#O  ReadAsFunction( <string> )  . . . . . . . . . . . read a file as function
##
DeclareOperation(
    "ReadAsFunction",
    [ IsString ] );


#############################################################################
##

#F  DirectoriesLibrary( <name> )  . . . . . . . .  directories of the library
##
BIND_GLOBAL( "DIRECTORIES_LIBRARY", rec() );

BIND_GLOBAL( "DirectoriesLibrary", function( arg )
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
end );


#############################################################################
##
#F  DirectoriesPackagePrograms( <name> )
##
##  returns a list of the `bin/<architecture>' subdirectories of all
##  packages <name> where <architecture> is the architecture on which {\GAP}
##  has been compiled. The directories returned by
##  `DirectoriesPackagePrograms' is the place where external binaries for
##  the share package <name> and the current architecture should be located.
BIND_GLOBAL( "DirectoriesPackagePrograms", function( name )
    local   arch,  dirs,  dir,  path;

    arch := GAP_ARCHITECTURE;
    dirs := [];
    for dir  in GAP_ROOT_PATHS  do
        path := Concatenation( dir, "pkg/", name, "/bin/", arch, "/" );
        Add( dirs, Directory(path) );
    od;
    return dirs;
end );


#############################################################################
##
#F  DirectoriesPackageLibrary( <name> [,<path>] )
##
##  takes the string <name>, a name of a share package and returns a list  of
##  directory  objects  for  the  sub-directory/ies  containing  the  library
##  functions of the share package, up to one for each `pkg' sub-directory of
##  a path in `GAP_ROOT_PATHS'. The default is that the library functions are
##  in the subdirectory `lib' of the share package's home directory. If  this
##  is not the case, then the second argument <path> needs to be present  and
##  must be a string that is a path name relative to the  home  directory  of
##  the share package with name <name>.
BIND_GLOBAL( "DirectoriesPackageLibrary", function( arg )
    local   name,  path,  dirs,  dir,  tmp;

    if IsEmpty(arg) or 2 < Length(arg) then
        Error( "usage: DirectoriesPackageLibrary( <name> [,<path>] )\n" );
    elif not ForAll(arg, IsString) then
        Error( "string argument(s) expected\n" );
    fi;

    name := arg[1];
    if 1 = Length(arg)  then
        path := "lib";
    else
        path := arg[2];
    fi;

    if '\\' in name or ':' in name  then
        Error( "<name> must not contain '\\' or ':'" );
    fi;
    dirs := [];
    for dir  in GAP_ROOT_PATHS  do
        tmp := Concatenation( dir, "pkg/", name, "/", path );
        if IsDirectoryPath(tmp) = true  then
            Add( dirs, Directory(tmp) );
        fi;
    od;
    if 0 < Length(dirs)  then
        return dirs;
    else
        return fail;
    fi;
end );


#############################################################################
##
#F  DirectoriesSystemPrograms() . . . . .  directories of the system programs
##
DIRECTORIES_PROGRAMS := false;

BIND_GLOBAL( "DirectoriesSystemPrograms", function()
    if DIRECTORIES_PROGRAMS = false  then
        DIRECTORIES_PROGRAMS := List( DIRECTORIES_SYSTEM_PROGRAMS,
                                      x -> Directory(x) );
    fi;
    return DIRECTORIES_PROGRAMS;
end );


#############################################################################
##
#F  DirectoryTemporary( <hint> )  . . . . . . .  create a temporary directory
##
BIND_GLOBAL( "DIRECTORIES_TEMPORARY", [] );

BIND_GLOBAL( "DirectoryTemporary", function( arg )
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
end );


#T THIS IS A HACK UNTIL `RemoveDirectory' IS AVAILABLE
InputTextNone := "2b defined";
OutputTextNone := "2b defined";
Process := "2b defined";

if ARCH_IS_UNIX() then
  # as we use `rm' this will only run under UNIX.
  InstallAtExit( function()
      local    i,  input,  output,  tmp,  rm,  proc;

      input  := InputTextNone();
      output := OutputTextNone();
      tmp    := Directory("/tmp");
      rm     := Filename( DirectoriesSystemPrograms(), "rm" );
      if rm = fail  then
	  Print("#W  cannot execute `rm' to remove temporary directories\n");
	  return;
      fi;

      for i  in DIRECTORIES_TEMPORARY  do
	  proc := Process( tmp, rm, input, output, [ "-rf", i ] );
      od;

  end );
fi;

#############################################################################
##
#F  DirectoryCurrent()  . . . . . . . . . . . . . . . . . . current directory
##
#T  THIS IS A HACK (will not work if SetDirectoryCurrent is implemented)
DIRECTORY_CURRENT := false;

BIND_GLOBAL( "DirectoryCurrent", function()
    if IsBool(DIRECTORY_CURRENT)  then
        DIRECTORY_CURRENT := Directory("./");
    fi;
    return DIRECTORY_CURRENT;
end );


#############################################################################
##

#F  CrcFile( <filename> ) . . . . . . . . . . . . . . . . .  create crc value
##
BIND_GLOBAL( "CrcFile", function( name )
    if IsReadableFile(name) <> true  then
        return fail;
    fi;
    return GAP_CRC(name);
end );


#############################################################################
##
#F  LoadDynamicModule( <filename> [, <crc> ] )  . . . . . . . . load a module
##
BIND_GLOBAL( "LoadDynamicModule", function( arg )

    if Length(arg) = 1  then
        if not LOAD_DYN( arg[1], false )  then
            Error( "no support for dynamic loading" );
        fi;
    elif Length(arg) = 2  then
        if not LOAD_DYN( arg[1], arg[2] )  then
            Error( "<crc> mismatch (or no support for dynamic loading)" );
        fi;
    else
        Error( "usage: LoadDynamicModule( <filename> [, <crc> ] )" );
    fi;

end );

#############################################################################
##
#F  LoadStaticModule( <filename> [, <crc> ] )   . . . . . . . . load a module
##
BIND_GLOBAL( "LoadStaticModule", function( arg )

    if Length(arg) = 1  then
        if not arg[1] in SHOW_STAT() then
            Error( "unknown static module ", arg[1] );
        fi;

        if not LOAD_STAT( arg[1], false )  then
            Error( "loading static module ", arg[1], " failed" );
        fi;
    elif Length(arg) = 2  then
        if not arg[1] in SHOW_STAT() then
            Error( "unknown static module ", arg[1] );
        fi;

        if not LOAD_STAT( arg[1], arg[2] )  then
            Error( "loading static module ", arg[1], 
                   " failed, possible crc mismatch" );
        fi;
    else
        Error( "usage: LoadStaticModule( <filename> [, <crc> ] )" );
    fi;

end );


#############################################################################
##

#V  EDITOR  . . . . . . . . . . . . . . . . . . . . default editor for `Edit'
##
EDITOR := "vi";


#############################################################################
##
#F  Edit( <filename> )  . . . . . . . . . . . . . . . . .  edit and read file
##
##  `Edit' starts an editor with the file whose filename is given by the
##  string <filename>, and reads the file back into {\GAP} when you exit the
##  editor again.
##  You should set the {\GAP} variable `EDITOR' to the name of
##  the editor that you usually use, e.g., `/usr/ucb/vi'.
##  This can for example be done in your `.gaprc' file (see the sections on
##  operating system dependent features in Chapter~"Installing GAP").
##
DeclareGlobalFunction( "Edit" );


#############################################################################
##

#O  CreateCompletionFiles( <path> ) . . . . . . . create "lib/readX.co" files
##
DeclareGlobalFunction("CreateCompletionFiles");


#############################################################################
##
#O  CheckCompletionFiles()  . . . . . . . . . . .  check the completion files
##
DeclareGlobalFunction("CheckCompletionFiles");


#############################################################################
##

#E

