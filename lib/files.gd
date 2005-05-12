#############################################################################
##
#W  files.gd                    GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for files and directories.
##
Revision.files_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsDirectory	. . . . . . . . . . . . . . . . . . . category of directories
##
DeclareCategory( "IsDirectory", IsObject );


#############################################################################
##
#V  DirectoriesFamily . . . . . . . . . . . . . . . . . family of directories
##
BIND_GLOBAL( "DirectoriesFamily", NewFamily( "DirectoriesFamily" ) );


#############################################################################
##
#F  USER_HOME_EXPAND . . . . . . . . . . . . .  expand leading ~ in file name
##
DeclareGlobalFunction("USER_HOME_EXPAND");


#############################################################################
##
#O  Directory( <string> ) . . . . . . . . . . . . . . .  new directory object
##
##  returns a directory object for the string <string>.
##  `Directory' understands `.' for ``current directory'', that is, the
##  directory in which {\GAP} was started.
##  It also understands absolute paths.
##
##  If the variable `GAPInfo.UserHome' is defined (this may depend on the
##  operating system) then `Directory' understands a string with a leading
##  `~' character for a path relative to the user's home directory.
##
##  Paths are otherwise taken relative to the current directory.
##
DeclareOperation( "Directory", [ IsString ] );


#############################################################################
##
#O  Filename( <dir>, <name> ) . . . . . . . . . . . . . . . . . . find a file
#O  Filename( <list-of-dirs>, <name> )  . . . . . . . . . . . . . find a file
##
##  If the first argument is a directory object <dir>, `Filename' returns the
##  (system dependent) filename as a string for the file with name <name>  in
##  the directory <dir>.
##  `Filename' returns the filename regardless of whether the directory
##  contains a file with name <name> or not.
##
##  If the first argument is a list <list-of-dirs> (possibly of length 1) of
##  directory objects, then `Filename' searches the directories in order, and
##  returns the filename for the file <name> in the first directory which
##  contains a file <name> or `fail' if no directory contains a file <name>.
##
DeclareOperation( "Filename", [ IsList, IsString ] );


#############################################################################
##
#O  Read( <name-file> ) . . . . . . . . . . . . . . . . . . . . . read a file
##
##  reads the input from the file with the filename <name-file>, which must
##  be given as a string.
##
##  `Read' first opens the file <name-file>.  If the file does not exist, or
##  if {\GAP} cannot open it, e.g., because of access restrictions,
##  an error is signalled.
##
##  Then the contents of the file are read and evaluated, but the results are
##  not printed.  The reading and evaluations happens exactly as described
##  for the main loop (see "Main Loop").
##
##  If a statement in the file causes an error a break loop is entered
##  (see~"Break Loops").
##  The input for this break loop is not taken from the file, but from the
##  input connected to the `stderr' output of {\GAP}.
##  If `stderr' is not connected to a terminal, no break loop is entered.
##  If this break loop is left with `quit' (or `<ctr>-D'), {\GAP} exits from
##  the `Read' command, and from all enclosing `Read' commands,
##  so that control is normally returned to an interactive prompt.
##  The `QUIT' statement (see~"Leaving GAP") can also be used in the break
##  loop to exit {\GAP} immediately.
##
##  Note that a statement must not begin in one file and end in another.
##  I.e., <eof> (`end-of-file') is not treated as whitespace,
##  but as a special symbol that must not appear inside any statement.
##
##  Note that one file may very well contain a read statement causing another
##  file to be read, before input is again taken from the first file.
##  There is an operating system dependent maximum on the number of files
##  that may be open simultaneously.  Usually it is 15.
##
DeclareOperation( "Read", [ IsString ] );


#############################################################################
##
#O  ReadTest( <string> )  . . . . . . . . . . . . . . . . .  read a test file
##
DeclareOperation( "ReadTest", [ IsString ] );


#############################################################################
##
#O  ReadAsFunction( <name-file> ) . . . . . . . . . . read a file as function
##
##  reads the file with filename <name-file> as a function and returns this
##  function.
##
DeclareOperation( "ReadAsFunction", [ IsString ] );

#############################################################################
##
#F  DirectoryContents(<name>)
## 
##  This function returns a list of filenames/directory names that reside in
##  the directory with name <name> (given as a string). It is an error, if
##  such a directory does not exist. 
DeclareGlobalFunction("DirectoryContents");


#############################################################################
##
#F  DirectoriesLibrary(  )  . . . . . . . . . . .  directories of the library
#F  DirectoriesLibrary( <name> )  . . . . . . . .  directories of the library
##
##  returns the directory objects for the {\GAP} library <name> as a list.
##  <name> must be one of `"lib"' (the default), `"grp"', `"prim"',
##  and so on.
##  The string `""' is also legal and with this argument `DirectoriesLibrary'
##  returns the list of {\GAP} root directories; the return value of
##  `DirectoriesLibrary("");' differs from `GAPInfo.RootPaths' in that the
##  former is a list of directory objects and the latter a list of strings.
##
##  The directory <name> must exist in at least one of the root directories,
##  otherwise `fail' is returned.
#T why the hell was this defined that way?
#T returning an empty list would be equally good!
##
##  As the files in the {\GAP} root directory (see~"GAP Root Directory") can
##  be distributed into different directories in the filespace a list of
##  directories is returned.  In order to find an existing file in a {\GAP}
##  root directory you should pass that list to `Filename' (see~"Filename")
##  as the first argument.
##  In order to create a filename for a new file inside a {\GAP} root
##  directory you should pass the first entry of that list.
##  However, creating files inside the {\GAP} root directory is not
##  recommended, you should use `DirectoryTemporary' instead.
##
BIND_GLOBAL( "DirectoriesLibrary", function( arg )
    local   name,  dirs,  dir,  path;

    if 0 = Length(arg)  then
        name := "lib";
    elif 1 = Length(arg)  then
        name := arg[1];
    else
        Error( "usage: DirectoriesLibrary( [<name>] )" );
    fi;

    if '\\' in name or ':' in name  then
        Error( "<name> must not contain '\\' or ':'" );
    fi;
    if not IsBound( GAPInfo.DirectoriesLibrary.( name ) )  then
        dirs := [];
        for dir  in GAPInfo.RootPaths  do
            path := Concatenation( dir, name );
            if IsDirectoryPath(path) = true  then
                Add( dirs, Directory(path) );
            fi;
        od;
        if 0 < Length(dirs)  then
            GAPInfo.DirectoriesLibrary.( name ) := Immutable(dirs);
        else
            return fail;
        fi;
    fi;

    return GAPInfo.DirectoriesLibrary.( name );
end );



#############################################################################
##
#F  DirectoriesSystemPrograms() . . . . .  directories of the system programs
##
##  `DirectoriesSystemPrograms' returns the directory objects for the list of
##  directories where the system programs reside as a list.  Under UNIX this
##  would usually represent `\$PATH'.
##
BIND_GLOBAL( "DirectoriesSystemPrograms", function()
    if GAPInfo.DirectoriesPrograms = false  then
        GAPInfo.DirectoriesPrograms :=
            List( GAPInfo.DirectoriesSystemPrograms, Directory );
    fi;
    return GAPInfo.DirectoriesPrograms;
end );


#############################################################################
##
#F  DirectoryTemporary( <hint> )  . . . . . . .  create a temporary directory
#F  DirectoryTemporary()  . . . . . . . . . . .  create a temporary directory
##
##  returns  a directory  object in the   category `IsDirectory' for a  *new*
##  temporary directory.   This is guaranteed to  be  newly created and empty
##  immediately  after the call to `DirectoryTemporary'.   {\GAP} will make a
##  reasonable effort   to *remove* this   directory  either  when a  garbage
##  collection  collects the directory   object  or upon termination  of  the
##  {\GAP}   job that   created  the  directory.     <hint> can  be  used  by
##  `DirectoryTemporary' to construct    the  name  of the    directory   but
##  `DirectoryTemporary' is free to use only a  part of <hint> or even ignore
##  it completely.
##
##  If `DirectoryTemporary' is  unable to create a  new  directory, `fail' is
##  returned.  In this case `LastSystemError' can be  used to get information
##  about the error.
##
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
    Add( GAPInfo.DirectoriesTemporary, dir );
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

      for i  in GAPInfo.DirectoriesTemporary  do
	  proc := Process( tmp, rm, input, output, [ "-rf", i ] );
      od;

  end );
fi;


#############################################################################
##
#F  DirectoryCurrent()  . . . . . . . . . . . . . . . . . . current directory
##
##  returns the directory object for the current directory.
#T  THIS IS A HACK (will not work if SetDirectoryCurrent is implemented)
##
BIND_GLOBAL( "DirectoryCurrent", function()
    if IsBool( GAPInfo.DirectoryCurrent )  then
        GAPInfo.DirectoryCurrent := Directory("./");
    fi;
    return GAPInfo.DirectoryCurrent;
end );


#############################################################################
##
#F  CrcFile( <name-file> )  . . . . . . . . . . . . . . . .  create crc value
##
##  computes a checksum value for the file with filename <name-file> and
##  returns this value as an integer.
##  See Section~"CRC Numbers" for an example.
##  The function returns `fail' if a system error occurred, say, for example,
##  if <name-file> does not exist.
##  In this case the function `LastSystemError' (see~"LastSystemError")
##  can be used to get information about the error.
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

#F  CreateCompletionFiles() . . . . . . . . . . . create "lib/readX.co" files
#F  CreateCompletionFiles( <path> ) . . . . . . . create "lib/readX.co" files
##
##  To create  completion files you must  have write permissions to `<path>',
##  which defaults to the  first root directory.   Start {\GAP} with the `-N'
##  option (to  suppress the reading  of any existing completion files), then
##  execute the command `CreateCompletionFiles( <path> );', where <path> is a
##  string giving a   path to the home   directory of  {\GAP} (the  directory
##  containing the `lib' directory).
##
##  This produces, in addition to lots of informational output,
##  the completion files.
##
DeclareGlobalFunction( "CreateCompletionFiles" );


#############################################################################
##
#O  CheckCompletionFiles()  . . . . . . . . . . .  check the completion files
##
DeclareGlobalFunction("CheckCompletionFiles");


#############################################################################
##

#E

