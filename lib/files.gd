#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations for files and directories.
##


#############################################################################
##
#C  IsDirectory . . . . . . . . . . . . . . . . . . . category of directories
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
##  <Ref Oper="Directory"/> understands <C>"."</C> for
##  <Q>current directory</Q>, that is,
##  the directory in which &GAP; was started.
##  It also understands absolute paths.
##  <P/>
##  If the variable <C>GAPInfo.UserHome</C> is defined (this may depend on
##  the operating system) then <Ref Oper="Directory"/> understands a string
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
##  returns a directory object for the user's home directory, defined as a
##  directory in which the user will typically have full read and write
##  access.
##  The function is intended to provide a cross-platform interface to a
##  directory that is easily accessible by the user.
##  <P/>
##  Under Unix systems (including macOS) this will be the
##  usual user home directory. Under Windows it will be the user's
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
##  returns a directory object for the user's desktop directory as defined on
##  many modern operating systems.
##  The function is intended to provide a cross-platform interface to a
##  directory that is easily accessible by the user.
##  <P/>
##  Under Unix systems (including macOS) this will be the
##  <C>Desktop</C> directory in the user's home directory if it exists, and
##  the user's home directory otherwise.
##  Under Windows it will be the user's <C>Desktop</C> folder
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
##  <Ref Oper="Filename" Label="for a directory and a string"/> returns the
##  (system dependent) filename as a string for the file with name
##  <A>name</A> in the directory <A>dir</A>.
##  <Ref Oper="Filename" Label="for a directory and a string"/> returns the
##  filename regardless of whether the directory contains a file with name
##  <A>name</A> or not.
##  <P/>
##  If the first argument is a list <A>list-of-dirs</A>
##  (possibly of length 1) of directory objects, then
##  <Ref Oper="Filename" Label="for a list of directories and a string"/>
##  searches the directories in order, and returns the filename for the file
##  <A>name</A> in the first directory which contains a file <A>name</A> or
##  <K>fail</K> if no directory contains a file <A>name</A>.
##  <P/>
##  <E>For example</E>,
##  in order to locate the system program <C>date</C> use
##  <Ref Func="PathSystemProgram"/>.
##  <P/>
##  <Log><![CDATA[
##  gap> date := PathSystemProgram( "date" );
##  "/bin/date"
##  ]]></Log>
##  <P/>
##  In order to locate the library file <F>files.gd</F> use
##  <Ref Func="DirectoriesLibrary"/> together with the second form of
##  <Ref Oper="Filename" Label="for a list of directories and a string"/>.
##  <P/>
##  <Log><![CDATA[
##  gap> path := DirectoriesLibrary();;
##  gap> Filename( path, "files.gd" );
##  "./lib/files.gd"
##  ]]></Log>
##  <P/>
##  In order to construct filenames for new files in a temporary directory
##  use <Ref Func="DirectoryTemporary"/> together with the first form of
##  <Ref Oper="Filename" Label="for a directory and a string"/>.
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
##  <Ref Oper="Read"/> first opens the file <A>filename</A>.
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
##  &GAP; exits from the <Ref Oper="Read"/> command, and from all enclosing
##  <Ref Oper="Read"/> commands, so that control is normally returned to an
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
#F  DirectoryContents(<dir>)
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
##  If an error occurs (the specified directory does not exist or has no
##  read permissions), <K>fail</K> is returned.
##  In this case <Ref Func="LastSystemError"/> can be used to get information
##  about the error.
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
##  <Ref Oper="Filename" Label="for a directory and a string"/> as the first
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
#F  PathSystemProgram( <name> ) . . . . . . . . . .  path of a system program
##
##  <#GAPDoc Label="PathSystemProgram">
##  <ManSection>
##  <Func Name="PathSystemProgram" Arg='name'/>
##
##  <Description>
##  <Ref Func="PathSystemProgram"/> returns either the path of the first
##  executable file <A>name</A> in one of the directories returned by
##  <Ref Func="DirectoriesSystemPrograms"/>,
##  or <K>fail</K> if no such file exists.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "PathSystemProgram", function( name )
    local dir, path;

    for dir in DirectoriesSystemPrograms() do
      path:= Filename( dir, name );
      if IsExecutableFile( path ) then
        return path;
      fi;
    od;

    return fail;
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
    local   dir;

    # check arguments
    if 1 < Length(arg)  then
        Error( "usage: DirectoryTemporary( )" );
    fi;

  # create temporary directory

  dir := TmpDirectory();
  if dir = fail  then
    return fail;
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
      if IS_DIR(path) then
          RemoveDirectoryRecursively(path);
      else
          PRINT_TO("*errout*", "Temporary directory already removed: ", path, "\n");
      fi;
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
        GAPInfo.DirectoryCurrent := Directory(GAP_getcwd());
    fi;
    return GAPInfo.DirectoryCurrent;
end );


#############################################################################
##
#F  ChangeDirectoryCurrent()  . . . . . . . . . . .  change current directory
##
##  <#GAPDoc Label="ChangeDirectoryCurrent">
##  <ManSection>
##  <Func Name="ChangeDirectoryCurrent" Arg='path'/>
##
##  <Description>
##  Changes the current directory. Returns <K>true</K> on success and
##  <K>fail</K> on failure.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ChangeDirectoryCurrent", function( path )
    if GAP_chdir(path) = true then
        GAPInfo.DirectoryCurrent := Directory(GAP_getcwd());
        return true;
    else
        return fail;
    fi;
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
##  <Index>hash function</Index>
##  <Index>checksum</Index>
##  This function computes a CRC (cyclic redundancy check) number for the
##  content of the file <A>filename</A>.
##  <P/>
##  <Ref Func="CrcFile"/> computes a CRC (cyclic redundancy check) checksum
##  value for the file with filename <A>filename</A> and returns this value
##  as an integer. The function returns <K>fail</K> if an error occurred,
##  for example, if <A>filename</A> does not exist.
##  In this case the function <Ref Func="LastSystemError"/>
##  can be used to get information about the error.
##  See also <Ref Func="CrcFile"/> and <Ref Func="HexSHA256"/>.
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
#F  LoadDynamicModule( <filename> ) . . . . . .  try to load a dynamic module
##
##  <#GAPDoc Label="LoadDynamicModule">
##  <ManSection>
##  <Func Name="LoadDynamicModule" Arg='filename'/>
##
##  <Description>
##  To load a compiled file, the command <Ref Func="LoadDynamicModule"/> is
##  used. This command loads <A>filename</A> as module.
##  <P/>
##  <Log><![CDATA[
##  gap> LoadDynamicModule("./test.so");
##  ]]></Log>
##  <P/>
##  On some operating systems, once you have loaded a dynamic module with a
##  certain filename, loading another with the same filename will have no
##  effect, even if the file on disk has changed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "LoadDynamicModule", function( filename )

    if not LOAD_DYN( filename )  then
        Error( "no support for dynamic loading" );
    fi;

end );

#############################################################################
##
#F  LoadStaticModule( <filename> ) . . . . . . .  try to load a static module
##
##  <ManSection>
##  <Func Name="LoadStaticModule" Arg='filename'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "LoadStaticModule", function( filename )

    if not filename in SHOW_STAT() then
        Error( "unknown static module ", filename );
    fi;

    if not LOAD_STAT( filename )  then
        Error( "loading static module ", filename, " failed" );
    fi;

end );


#############################################################################
##
#F  IsKernelExtensionAvailable( <pkgname> [, <modname> ] )
##
##  <#GAPDoc Label="IsKernelExtensionAvailable">
##  <ManSection>
##  <Func Name="IsKernelExtensionAvailable" Arg='pkgname[, modname]'/>
##
##  <Description>
##  For use by packages: Search for a loadable kernel module inside package
##  <A>pkgname</A> with name <A>modname</A> and return <K>true</K> if found,
##  otherwise <K>false</K>.
##  If <A>modname</A> is omitted, then <A>pkgname</A> is used instead. Note
##  that package names are case insensitive, but <A>modname</A> is not.
##  <P/>
##  This function first appeared in GAP 4.12. It is typically called in the
##  <C>AvailabilityTest</C> function of a package
##  (see <Ref Subsect="Test for the Existence of GAP Package Binaries"/>).
##  <Log><![CDATA[
##  gap> IsKernelExtensionAvailable("myPackageWithKernelExtension");
##  true
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "IsKernelExtensionAvailable", function( pkgname, modname... )
    local fname;

    if Length(modname) = 0 then
        modname := pkgname;
    elif Length(modname) = 1 then
        modname := modname[1];
    else
        Error( "usage: IsKernelExtensionAvailable( <pkgname> [, <modname> ] )" );
    fi;

    if modname in SHOW_STAT() then
        return true;
    fi;
    fname := Filename(DirectoriesPackagePrograms(pkgname), Concatenation(modname, ".so"));
    if fname <> fail then
        return IS_LOADABLE_DYN(fname);
    fi;
    return false;
end );


#############################################################################
##
#F  LoadKernelExtension( <pkgname> [, <modname> ] )
##
##  <#GAPDoc Label="LoadKernelExtension">
##  <ManSection>
##  <Func Name="LoadKernelExtension" Arg='pkgname[, modname]'/>
##
##  <Description>
##  For use by packages: Search for a loadable kernel module inside package
##  <A>pkgname</A> with name <A>modname</A>, and load it if found.
##  If <A>modname</A> is omitted, then <A>pkgname</A> is used instead. Note
##  that package names are case insensitive, but <A>modname</A> is not.
##  <P/>
##  This function first appeared in GAP 4.12. It is typically called in the
##  <F>init.g</F> file of a package.
##  <P/>
##  Previously, packages with a kernel module typically used code like this:
##  <Listing><![CDATA[
##  path := Filename(DirectoriesPackagePrograms("SomePackage"), "SomePackage.so");
##  if path <> fail then
##    LoadDynamicModule(path);
##  fi;
##  ]]></Listing>
##  That can now be replaced by the following, which also produces more
##  helpful error messages for the user:
##  <Listing><![CDATA[
##  LoadKernelExtension("SomePackage");
##  ]]></Listing>
##  For packages where the name of the kernel extension is not identical to
##  that of the package, you can either rename the kernel extension to have a
##  matching name (recommended if you only have a single kernel extension in
##  your package, which is how we recommend to set up things anyway), or else
##  use the two argument version:
##  <Log><![CDATA[
##  LoadKernelExtension("SomePackage", "kext"); # this will look for kext.so
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "LoadKernelExtension", function( pkgname, modname... )
    local fname;

    if Length(modname) = 0 then
        modname := pkgname;
    elif Length(modname) = 1 then
        modname := modname[1];
    else
        Error( "usage: LoadKernelExtension( <pkgname> [, <modname> ] )" );
    fi;

    if modname in SHOW_STAT() then
        LoadStaticModule(modname);
        return true;
    fi;
    fname := Filename(DirectoriesPackagePrograms(pkgname), Concatenation(modname, ".so"));
    if fname <> fail then
        LoadDynamicModule(fname);
        return true;
    fi;
    return false;
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
##  Under macOS, you should use
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


##  <#GAPDoc Label="HexSHA256">
##  <ManSection>
##  <Func Name="HexSHA256" Arg='string'/>
##  <Func Name="HexSHA256" Arg='stream' Label="for a stream"/>
##
##  <Description>
##  <Index>hash function</Index>
##  <Index>checksum</Index>
##  Return the SHA-256 cryptographic checksum of the bytes in <A>string</A>,
##  resp. of the data in the input stream object <A>stream</A>
##  (see Chapter&nbsp;<Ref Chap="Streams"/> to learn about streams)
##  when read from the current position until EOF (end-of-file).
##  <P/>
##  The checksum is returned as string with 64 lowercase hexadecimal digits.
##  <Example><![CDATA[
##  gap> HexSHA256("abcd");
##  "88d4266fd4e6338d13b845fcf289579d209c897823b9217da3e161936f031589"
##  gap> HexSHA256(InputTextString("abcd"));
##  "88d4266fd4e6338d13b845fcf289579d209c897823b9217da3e161936f031589"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("HexSHA256");

BIND_GLOBAL("GAP_SHA256_State_Type",
           NewType(NewFamily("GAP_SHA256_State_Family"), IsObject) );
