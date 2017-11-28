#############################################################################
##
#W  files.gd                    GAP Library                      Frank Celler
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for files and directories.
##


#############################################################################
##
#C  IsDirectory	. . . . . . . . . . . . . . . . . . . category of directories
##
##  <#GAPDoc Label="IsDirectory">
##  <ManSection>
##  <Filt Name="IsDirectory" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsDirectory"/> is a category of directories. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
#F  DirectoryHome() . . . . . . . . . . . . . . .  new directory object
##
##  <#GAPDoc Label="DirectoryHome">
##  <ManSection>
##  <Func Name="DirectoryHome" Arg=''/>
##
##  <Description>
##  returns a directory object for the users home directory, defined as a
##  directory in which the user will typically have full read and write
##  access.
##  The function is intended to provide a cross-platform interface to a
##  directory that is easily accessible by the user.
##
##  Under Unix systems (including Mac OS X) this will be the
##  usual user home directory. Under Windows it will the users 
##  <C>My Documents</C> folder (or the appropriate name under different
##  languages).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DirectoryHome" );

#############################################################################
##
#F  DirectoryDesktop() . . . . . . . . . . . . . . .  new directory object
##
##  <#GAPDoc Label="DirectoryDesktop">
##  <ManSection>
##  <Func Name="DirectoryDesktop" Arg=''/>
##
##  <Description>
##  returns a directory object for the users desktop directory as defined on
##  many modern operating systems. 
##  The function is intended to provide a cross-platform interface to a
##  directory that is easily accessible by the user.
##
##  Under Unix systems (including Mac OS X) this will be the
##  <C>Desktop</C> directory in the users home directory if it exists, and
##  the users home directory otherwise. 
##  Under Windows it will the users <C>Desktop</C> folder
##  (or the appropriate name under different
##  languages).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DirectoryDesktop" );


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
DeclareOperation( "Filename", [ IsDirectory, IsString ] );
DeclareOperation( "Filename", [ IsList, IsString ] );

DeclareOperation( "ExternalFilename", [ IsDirectory, IsString ] );
DeclareOperation( "ExternalFilename", [ IsList, IsString ] );

#############################################################################
##
#O  Read( <filename> ) . . . . . . . . . . . . . . . . . . . . . read a file
##
##  <#GAPDoc Label="Read">
##  <ManSection>
##  <Oper Name="Read" Arg='filename'/>
##
##  <Description>
##  reads the input from the file with the filename <A>filename</A>,
##  which must be given as a string.
##  <P/>
##  <Ref Func="Read"/> first opens the file <A>filename</A>.
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
##  There is an upper limit of 15 on the number of files
##  that may be open simultaneously.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Read", [ IsString ] );


#############################################################################
##
#O  ReadAsFunction( <filename> ) . . . . . . . . . . read a file as function
##
##  <#GAPDoc Label="ReadAsFunction">
##  <ManSection>
##  <Oper Name="ReadAsFunction" Arg='filename'/>
##
##  <Description>
##  reads the file with filename <A>filename</A> as a function
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
##  <Func Name="DirectoryContents" Arg='dir'/>
##
##  <Description>
##  This function returns a list of filenames/directory names that reside in
##  the directory <A>dir</A>. The argument <A>dir</A> can either be given as 
##  a string indicating the name of the directory or as a directory object
##  (see <Ref Filt="IsDirectory"/>).
##  It is an error, if such a directory does not exist. 
##  <P/>
##  The ordering of the list entries can depend on the operating system.
##  <P/>
##  An interactive way to show the contents of a directory is provided by the
##  function <Ref Func="BrowseDirectory" BookName="browse"/> from the
##  &GAP; package <Package>Browse</Package>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DirectoryContents");


#############################################################################
##
#F  IsDirectoryPath(<name>)
## 
BIND_GLOBAL("IsDirectoryPath", function(dirname)
  local str;
  if IsDirectory(dirname) then
    dirname := dirname![1];
  fi;
  return IsDirectoryPathString(dirname);
end);

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
##  <A>name</A> must be one of <C>"lib"</C> (the default), <C>"doc"</C>,
##  <C>"tst"</C>, and so on.
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
##  As the files in the &GAP; root directories
##  (see&nbsp;<Ref Sect="GAP Root Directories"/>) can be distributed into
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
        if IsHPCGAP then
            GAPInfo.DirectoriesPrograms :=
                AtomicList( GAPInfo.DirectoriesPrograms );
        fi;
    fi;
    return GAPInfo.DirectoriesPrograms;
end );


#############################################################################
##
#F  DirectoryTemporary() . . . . . . . . . . . . create a temporary directory
##
##  <#GAPDoc Label="DirectoryTemporary">
##  <ManSection>
##  <Func Name="DirectoryTemporary" Arg=''/>
##
##  <Description>
##  returns a directory object in the category <Ref Filt="IsDirectory"/>
##  for a <E>new</E> temporary directory.
##  This is guaranteed to be newly created and empty immediately after the
##  call to <Ref Func="DirectoryTemporary"/>.
##  &GAP; will make a reasonable effort to remove this directory
##  upon termination of the &GAP; job that created the directory.
##  <P/>
##  If <Ref Func="DirectoryTemporary"/> is unable to create a new directory,
##  <K>fail</K> is returned.
##  In this case <Ref Func="LastSystemError"/> can be used to get information
##  about the error.
##  <P/>
##  A warning message is given if more than 1000 temporary directories are 
##  created in any &GAP; session.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DIRECTORY_TEMPORARY_COUNT := 0;
DIRECTORY_TEMPORART_LIMIT := 1000;
InfoTempDirectories := fail;




BIND_GLOBAL( "DirectoryTemporary", function( arg )
    local   dir,drive,a;

    # check arguments
    if 1 < Length(arg)  then
        Error( "usage: DirectoryTemporary( )" );
    fi;

  # create temporary directory

  dir := TmpDirectory();
  if dir = fail  then
    return fail;
  fi;
  if ARCH_IS_WINDOWS() then
    # We want to deliver a Windows path
    if dir{[1..10]} = "/cygdrive/" then
        drive := dir[11];
        dir := Concatenation("C:",dir{[12..Length(dir)]});
        dir[1] := drive;
    fi;
  fi;

  # remember directory name
  Add( GAPInfo.DirectoriesTemporary, dir );
  
  DIRECTORY_TEMPORARY_COUNT := DIRECTORY_TEMPORARY_COUNT + 1;
  if DIRECTORY_TEMPORARY_COUNT = DIRECTORY_TEMPORART_LIMIT then
      Info(InfoTempDirectories,1, DIRECTORY_TEMPORART_LIMIT, " temporary directories made in this session");
      DIRECTORY_TEMPORART_LIMIT := DIRECTORY_TEMPORART_LIMIT*10;
  fi;
  
  return Directory(dir);
end );

DeclareGlobalFunction( "RemoveDirectoryRecursively" );

InstallAtExit( function()
  local path;
  for path in GAPInfo.DirectoriesTemporary do
      RemoveDirectoryRecursively(path);
  od;
  end );


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
#F  CrcFile( <filename> )  . . . . . . . . . . . . . . . .  create crc value
##
##  <#GAPDoc Label="CrcFile">
##  <ManSection>
##  <Func Name="CrcFile" Arg='filename'/>
##
##  <Description>
##  CRC (cyclic redundancy check) numbers provide a certain method of doing
##  checksums. They are used by &GAP; to check whether
##  files have changed.
##  <P/>
##  <Ref Func="CrcFile"/> computes a checksum value for the file with
##  filename <A>filename</A> and returns this value as an integer.
##  The function returns <K>fail</K> if a system error occurred, say,
##  for example, if <A>filename</A> does not exist.
##  In this case the function <Ref Func="LastSystemError"/>
##  can be used to get information about the error.
##  <P/>
##  <Log><![CDATA[
##  gap> CrcFile( "lib/morpheus.gi" );
##  2705743645
##  ]]></Log>
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
##  &GAP; will call your preferred editor if you call
##  <C>SetUserPreference("Editor", <A>path</A>);</C>
##  where <A>path</A> is the  path to your editor, 
##  e.g., <F>/usr/bin/vim</F>.
##  On Windows you can use <C>edit.com</C>. 
##  <P/>
##  Under Mac OS X, you should use
##  <C>SetUserPreference("Editor", "open");</C>, this will open 
##  the file in the default editor. If you call 
##  <C>SetUserPreference("EditorOptions", ["-t"]);</C>, the file
##  will open in <F>TextEdit</F>, and 
##  <C>SetUserPreference("EditorOptions", ["-a", "&lt;appl&gt;"]);</C>
##  will open the file using the application <C>&lt;appl&gt;</C>.
##  <P/>
##  This can for example be done in your <F>gap.ini</F> file,
##  see Section <Ref Subsect="subsect:gap.ini file"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Edit" );

# the character set definitions might be needed when processing files, thus
# they must come earlier.
BIND_GLOBAL("CHARS_DIGITS",Immutable(SSortedList("0123456789")));
BIND_GLOBAL("CHARS_UALPHA",
  Immutable(SSortedList("ABCDEFGHIJKLMNOPQRSTUVWXYZ")));
BIND_GLOBAL("CHARS_LALPHA",
  Immutable(SSortedList("abcdefghijklmnopqrstuvwxyz")));
BIND_GLOBAL("CHARS_SYMBOLS",Immutable(SSortedList(
  " !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")));


#############################################################################
##
#E
