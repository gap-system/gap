#############################################################################
##
#W  files.gd                    GAP Library                      Frank Celler
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for files and directories.
##
Revision.files_gd :=
    "@(#)$Id: files.gd,v 4.49 2009/07/10 14:28:11 gap Exp $";


#############################################################################
##
#C  IsDirectory	. . . . . . . . . . . . . . . . . . . category of directories
##
##  <ManSection>
##  <Filt Name="IsDirectory" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsDirectory", IsObject );


#############################################################################
##
#V  DirectoriesFamily . . . . . . . . . . . . . . . . . family of directories
##
##  <ManSection>
##  <Var Name="DirectoriesFamily"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "DirectoriesFamily", NewFamily( "DirectoriesFamily" ) );


#############################################################################
##
#F  USER_HOME_EXPAND . . . . . . . . . . . . .  expand leading ~ in file name
##
##  <ManSection>
##  <Func Name="USER_HOME_EXPAND" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("USER_HOME_EXPAND");


#############################################################################
##
#O  Directory( <string> ) . . . . . . . . . . . . . . .  new directory object
##
##  <#GAPDoc Label="Directory">
##  <ManSection>
##  <Oper Name="Directory" Arg='string'/>
##
##  <Description>
##  returns a directory object for the string <A>string</A>.
##  <Ref Func="Directory"/> understands <C>"."</C> for
##  <Q>current directory</Q>, that is,
##  the directory in which &GAP; was started.
##  It also understands absolute paths.
##  <P/>
##  If the variable <C>GAPInfo.UserHome</C> is defined (this may depend on
##  the operating system) then <Ref Func="Directory"/> understands a string
##  with a leading <C>~</C> (tilde) character for a path relative to the
##  user's home directory (but a  string beginning with <C>"~other_user"</C>
##  is <E>not</E> interpreted as a path relative to <C>other_user</C>'s
##  home directory, as in a UNIX shell).
##  <P/>
##  Paths are otherwise taken relative to the current directory.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Directory", [ IsString ] );


#############################################################################
##
#O  Filename( <dir>, <name> ) . . . . . . . . . . . . . . . . . . find a file
#O  Filename( <list-of-dirs>, <name> )  . . . . . . . . . . . . . find a file
##
##  <#GAPDoc Label="Filename">
##  <ManSection>
##  <Heading>Filename</Heading>
##  <Oper Name="Filename" Arg='dir, name'
##   Label="for a directory and a string"/>
##  <Oper Name="Filename" Arg='list-of-dirs, name'
##   Label="for a list of directories and a string"/>
##
##  <Description>
##  If the first argument is a directory object <A>dir</A>,
##  <Ref Func="Filename" Label="for a directory and a string"/> returns the
##  (system dependent) filename as a string for the file with name
##  <A>name</A> in the directory <A>dir</A>.
##  <Ref Func="Filename" Label="for a directory and a string"/> returns the
##  filename regardless of whether the directory contains a file with name
##  <A>name</A> or not.
##  <P/>
##  If the first argument is a list <A>list-of-dirs</A>
##  (possibly of length 1) of directory objects, then
##  <Ref Func="Filename" Label="for a list of directories and a string"/>
##  searches the directories in order, and returns the filename for the file
##  <A>name</A> in the first directory which contains a file <A>name</A> or
##  <K>fail</K> if no directory contains a file <A>name</A>.
##  <P/>
##  <E>For example</E>,
##  in order to locate the system program <C>date</C> use
##  <Ref Func="DirectoriesSystemPrograms"/> together with the second form of
##  <Ref Func="Filename" Label="for a list of directories and a string"/>.
##  <P/>
##  <Log><![CDATA[
##  gap> path := DirectoriesSystemPrograms();;
##  gap> date := Filename( path, "date" );
##  "/bin/date"
##  ]]></Log>
##  <P/>
##  In order to locate the library file <F>files.gd</F> use
##  <Ref Func="DirectoriesLibrary"/> together with the second form of
##  <Ref Func="Filename" Label="for a list of directories and a string"/>.
##  <P/>
##  <Log><![CDATA[
##  gap> path := DirectoriesLibrary();;
##  gap> Filename( path, "files.gd" );
##  "./lib/files.gd"
##  ]]></Log>
##  <P/>
##  In order to construct filenames for new files in a temporary directory
##  use <Ref Func="DirectoryTemporary"/> together with the first form of
##  <Ref Func="Filename" Label="for a directory and a string"/>.
##  <P/>
##  <Log><![CDATA[
##  gap> tmpdir := DirectoryTemporary();;
##  gap> Filename( [ tmpdir ], "file.new" );
##  fail
##  gap> Filename( tmpdir, "file.new" );
##  "/var/tmp/tmp.0.021738.0001/file.new"
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Filename", [ IsList, IsString ] );


#############################################################################
##
#O  Read( <name-file> ) . . . . . . . . . . . . . . . . . . . . . read a file
##
##  <#GAPDoc Label="Read">
##  <ManSection>
##  <Oper Name="Read" Arg='name-file'/>
##
##  <Description>
##  reads the input from the file with the filename <A>name-file</A>,
##  which must be given as a string.
##  <P/>
##  <Ref Func="Read"/> first opens the file <A>name-file</A>.
##  If the file does not exist, or if &GAP; cannot open it,
##  e.g., because of access restrictions, an error is signalled.
##  <P/>
##  Then the contents of the file are read and evaluated, but the results are
##  not printed.  The reading and evaluations happens exactly as described
##  for the main loop (see <Ref Sect="Main Loop"/>).
##  <P/>
##  If a statement in the file causes an error a break loop is entered
##  (see&nbsp;<Ref Sect="Break Loops"/>).
##  The input for this break loop is not taken from the file, but from the
##  input connected to the <C>stderr</C> output of &GAP;.
##  If <C>stderr</C> is not connected to a terminal,
##  no break loop is entered.
##  If this break loop is left with <K>quit</K> (or <B>Ctrl-D</B>),
##  &GAP; exits from the <Ref Func="Read"/> command, and from all enclosing
##  <Ref Func="Read"/> commands, so that control is normally returned to an
##  interactive prompt.
##  The <K>QUIT</K> statement (see&nbsp;<Ref Sect="Leaving GAP"/>) can also
##  be used in the break loop to exit &GAP; immediately.
##  <P/>
##  Note that a statement must not begin in one file and end in another.
##  I.e., <E>eof</E> (<E>e</E>nd-<E>o</E>f-<E>f</E>ile) is not treated as
##  whitespace,
##  but as a special symbol that must not appear inside any statement.
##  <P/>
##  Note that one file may very well contain a read statement causing another
##  file to be read, before input is again taken from the first file.
##  There is an operating system dependent maximum on the number of files
##  that may be open simultaneously.  Usually it is 15.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Read", [ IsString ] );


#############################################################################
##
#O  ReadTest( <string> )  . . . . . . . . . . . . . . . . .  read a test file
##
##  <ManSection>
##  <Oper Name="ReadTest" Arg='string'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "ReadTest", [ IsString ] );


#############################################################################
##
#O  ReadAsFunction( <name-file> ) . . . . . . . . . . read a file as function
##
##  <#GAPDoc Label="ReadAsFunction">
##  <ManSection>
##  <Oper Name="ReadAsFunction" Arg='name-file'/>
##
##  <Description>
##  reads the file with filename <A>name-file</A> as a function
##  and returns this function.
##  <P/>
##  <E>Example</E>
##  <P/>
##  Suppose that the file <F>/tmp/example.g</F> contains the following
##  <P/>
##  <Log><![CDATA[
##  local a;
##  
##  a := 10;
##  return a*10;
##  ]]></Log>
##  <P/>
##  Reading the file as a function will not affect a global variable <C>a</C>.
##  <P/>
##  <Log><![CDATA[
##  gap> a := 1;
##  1
##  gap> ReadAsFunction("/tmp/example.g")();
##  100
##  gap> a;
##  1
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ReadAsFunction", [ IsString ] );


#############################################################################
##
#F  DirectoryContents(<name>)
##
##  <#GAPDoc Label="DirectoryContents">
##  <ManSection>
##  <Func Name="DirectoryContents" Arg='name'/>
##
##  <Description>
##  This function returns a list of filenames/directory names that reside in
##  the directory with name <A>name</A> (given as a string).
##  It is an error, if such a directory does not exist. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DirectoryContents");


#############################################################################
##
#F  DirectoriesLibrary( [<name>] )  . . . . . . .  directories of the library
##
##  <#GAPDoc Label="DirectoriesLibrary">
##  <ManSection>
##  <Func Name="DirectoriesLibrary" Arg='[name]'/>
##
##  <Description>
##  <Ref Func="DirectoriesLibrary"/> returns the directory objects for the
##  &GAP; library <A>name</A> as a list.
##  <A>name</A> must be one of <C>"lib"</C> (the default), <C>"grp"</C>,
##  <C>"prim"</C>, and so on.
##  <P/>
##  The string <C>""</C> is also legal and with this argument
##  <Ref Func="DirectoriesLibrary"/> returns the list of
##  &GAP; root directories.
##  The return value of this call differs from <C>GAPInfo.RootPaths</C>
##  in that the former is a list of directory objects
##  and the latter a list of strings.
##  <P/>
##  The directory <A>name</A> must exist in at least one of the
##  root directories,
##  otherwise <K>fail</K> is returned.
##  <!-- why the hell was this defined that way?-->
##  <!-- returning an empty list would be equally good!-->
##  <P/>
##  As the files in the &GAP; root directory
##  (see&nbsp;<Ref Sect="GAP Root Directory"/>) can be distributed into
##  different directories in the filespace a list of directories is returned.
##  In order to find an existing file in a &GAP; root directory you should
##  pass that list to
##  <Ref Func="Filename" Label="for a directory and a string"/> as the first
##  argument.
##  In order to create a filename for a new file inside a &GAP; root
##  directory you should pass the first entry of that list.
##  However, creating files inside the &GAP; root directory is not
##  recommended, you should use <Ref Func="DirectoryTemporary"/> instead.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="DirectoriesSystemPrograms">
##  <ManSection>
##  <Func Name="DirectoriesSystemPrograms" Arg=''/>
##
##  <Description>
##  <Ref Func="DirectoriesSystemPrograms"/> returns the directory objects
##  for the list of directories where the system programs reside, as a list.
##  Under UNIX this would usually represent <C>$PATH</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
#F  DirectoryTemporary( [<hint>] )  . . . . . .  create a temporary directory
##
##  <#GAPDoc Label="DirectoryTemporary">
##  <ManSection>
##  <Func Name="DirectoryTemporary" Arg='[hint]'/>
##
##  <Description>
##  returns a directory object in the category <C>IsDirectory</C>
##  for a <E>new</E> temporary directory.
##  This is guaranteed to be newly created and empty immediately after the
##  call to <Ref Func="DirectoryTemporary"/>.
##  &GAP; will make a reasonable effort to <E>remove</E> this directory
##  either when a garbage collection collects the directory object or upon
##  termination of the &GAP; job that created the directory.
##  <P/>
##  <A>hint</A> can be used by <Ref Func="DirectoryTemporary"/> to construct
##  the name of the directory but <Ref Func="DirectoryTemporary"/> is free
##  to use only a part of <A>hint</A> or even ignore it completely.
##  <P/>
##  If <Ref Func="DirectoryTemporary"/> is unable to create a new directory,
##  <K>fail</K> is returned.
##  In this case <Ref Func="LastSystemError"/> can be used to get information
##  about the error.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DirectoryTemporary", function( arg )
    local   dir;

    # check arguments
    if 1 < Length(arg)  then
        Error( "usage: DirectoryTemporary( [<hint>] )" );
    fi;

    # create temporary directory

    if ARCH_IS_WINDOWS() then
      # Under Windows, the cygwin environment may return a path under /tmp,
      # but this is actually mapped to
      # C:/Documents and Settings/Username/.../Temp
      # A path /tmp/... then causes problems with external binaries that do not
      # use cygwin. Therefore it seems to be better to use the Windows Temp
      # directory. The lack of subdirectories then potentially could cause
      # problems if several instances of a package run at the same time,
      # however -- Windows being primarily single-user -- this seems
      # unlikely.
      #T Create subdirectories with random name. (How to create directory?)
      dir:="C:/WINDOWS/Temp/";
    else
      dir := TmpDirectory();
      if dir = fail  then
	return fail;
      fi;
      # remember directory name
      Add( GAPInfo.DirectoriesTemporary, dir );
    fi;

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
##  <#GAPDoc Label="DirectoryCurrent">
##  <ManSection>
##  <Func Name="DirectoryCurrent" Arg=''/>
##
##  <Description>
##  returns the directory object for the current directory.
##  <!--  THIS IS A HACK (will not work if SetDirectoryCurrent is implemented)-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="CrcFile">
##  <ManSection>
##  <Func Name="CrcFile" Arg='name-file'/>
##
##  <Description>
##  computes a checksum value for the file with filename <A>name-file</A>
##  and returns this value as an integer.
##  See Section&nbsp;<Ref Sect="CRC Numbers"/> for an example.
##  The function returns <K>fail</K> if a system error occurred, say,
##  for example, if <A>name-file</A> does not exist.
##  In this case the function <Ref Func="LastSystemError"/>
##  can be used to get information about the error.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <ManSection>
##  <Func Name="LoadDynamicModule" Arg='filename [, crc ]'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Func Name="LoadStaticModule" Arg='filename [, crc ]'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <#GAPDoc Label="Edit">
##  <ManSection>
##  <Func Name="Edit" Arg='filename'/>
##
##  <Description>
##  <Ref Func="Edit"/> starts an editor with the file whose filename is given
##  by the string <A>filename</A>, and reads the file back into &GAP;
##  when you exit the editor again.
##  <P/>
##  You should set the &GAP; variable <C>EDITOR</C> to the name of
##  the editor that you usually use, e.g., <F>/usr/ucb/vi</F>.
##  On Windows you can use <C>edit.com</C>.
##  This can for example be done in your <F>.gaprc</F> file
##  (see the sections on operating system dependent features
##  in Chapter&nbsp;<Ref Chap="Installing GAP"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Edit" );


#############################################################################
##
#F  CreateCompletionFiles() . . . . . . . . . . . create "lib/readX.co" files
#F  CreateCompletionFiles( <path> ) . . . . . . . create "lib/readX.co" files
##
##  <#GAPDoc Label="CreateCompletionFiles">
##  <ManSection>
##  <Func Name="CreateCompletionFiles" Arg='[path]'/>
##
##  <Description>
##  To create completion files you must have write permissions to
##  <A>path</A>, which defaults to the first &GAP; root directory.
##  Start &GAP; with the <C>-N</C> option (to suppress the reading of any
##  existing completion files),
##  then execute the command <C>CreateCompletionFiles( <A>path</A> );</C>,
##  where <A>path</A> is a string giving a path to the home directory of
##  &GAP; (the  directory containing the <F>lib</F> directory).
##  <P/>
##  This produces, in addition to lots of informational output,
##  the completion files.
##  <P/>
##  <Log><![CDATA[
##  $ gap4 -N
##  gap> CreateCompletionFiles();
##  #I  converting "gap4/lib/read2.g" to "gap4/lib/read2.co"
##  #I    parsing "gap4/lib/process.gd"
##  #I    parsing "gap4/lib/listcoef.gi"
##  ...
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CreateCompletionFiles" );


#############################################################################
##
#O  CheckCompletionFiles()  . . . . . . . . . . .  check the completion files
##
##  <ManSection>
##  <Oper Name="CheckCompletionFiles" Arg=''/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CheckCompletionFiles");

# the character set definitions might be needed when processing files, thus
# they must come earlier.
BIND_GLOBAL("CHARS_DIGITS",Immutable(SSortedList("0123456789")));
BIND_GLOBAL("CHARS_UALPHA",
  Immutable(SSortedList("ABCDEFGHIJKLMNOPQRSTUVWXYZ")));
BIND_GLOBAL("CHARS_LALPHA",
  Immutable(SSortedList("abcdefghijklmnopqrstuvwxyz")));


#############################################################################
##
#E

