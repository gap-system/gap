#############################################################################
##
#W  process.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for process.
##
Revision.process_gd :=
    "@(#)$Id$";


#############################################################################
#1
##  {\GAP} can call other programs, such programs are called *processes*.
##  There are two kinds of processes:
##  First there are processes that are started, run and return a result,
##  while {\GAP} is suspended until the process terminates.
##  Then there are processes that will run in parallel to {\GAP} as
##  subprocesses and {\GAP} can communicate and control the processes using
##  streams (see~"InputOutputLocalProcess").
##


#############################################################################
##
#O  Process( <dir>, <prg>, <stream-in>, <stream-out>, <options> )
##
##  `Process' runs a new process and returns when the process terminates.
##  It returns the return value of the process if the operating system
##  supports such a concept.
##
##  The first argument <dir> is a directory object (see~"Directories")
##  which will be the current directory (in the usual UNIX or MSDOS sense)
##  when the program is run.
##  This will only matter if the program accesses files (including running
##  other programs) via relative path names.
##  In particular, it has nothing to do with finding the binary to run.
##
##  In general the directory will either be the current directory, which is
##  returned by `DirectoryCurrent' (see~"DirectoryCurrent")
##  --this was the behaviour of {\GAP}~3--
##  or a temporary directory returned by `DirectoryTemporary'
##  (see~"DirectoryTemporary").
##  If one expects that the process creates temporary or log files the latter
##  should be used because {\GAP} will attempt to remove these directories
##  together with all the files in them when quitting.
##
##  If a program of a {\GAP} package which does not only consist of {\GAP}
##  code needs to be launched in a directory relative to certain data
##  libraries, then the first entry of `DirectoriesPackageLibrary' should be
##  used.
##  The argument of `DirectoriesPackageLibrary' should be the path to the
##  data library relative to the package directory.
##
##  If a program calls other programs and needs to be launched in a directory
##  containing the executables for such a {\GAP} package then the first entry
##  of `DirectoriesPackagePrograms' should be used.
##
##  The latter two alternatives should only be used if absolutely necessary
##  because otherwise one risks accumulating log or core files in the package
##  directory.
##
##  *Examples*
##
##  %notest
##  \beginexample
##  gap> path := DirectoriesSystemPrograms();;
##  gap> ls := Filename( path, "ls" );;
##  gap> stdin := InputTextUser();;
##  gap> stdout := OutputTextUser();;
##  gap> Process( path[1], ls, stdin, stdout, ["-c"] );;
##  awk    ls     mkdir
##  \endexample
##  
##  %notest
##  \beginexample
##  gap> # current directory, here the root directory
##  gap> Process( DirectoryCurrent(), ls, stdin, stdout, ["-c"] );;
##  bin    lib    trans  tst    CVS    grp    prim   thr    two
##  src    dev    etc    tbl    doc    pkg    small  tom
##  \endexample
##
##  %notest
##  \beginexample
##  gap> # create a temporary directory
##  gap> tmpdir := DirectoryTemporary();;
##  gap> Process( tmpdir, ls, stdin, stdout, ["-c"] );;
##  gap> PrintTo( Filename( tmpdir, "emil" ) );
##  gap> Process( tmpdir, ls, stdin, stdout, ["-c"] );;
##  emil
##  \endexample
##
##  <prg> is the filename of the program to launch, for portability it should
##  be the result of `Filename' (see~"Filename") and should pass
##  `IsExecutableFile'.
##  Note that `Process' does *no* searching through a list of directories,
##  this is done by `Filename'.
##
##  <stream-in> is the input stream that delivers the characters to the
##  process.
##  For portability it should either be `InputTextNone' (if the process reads
##  no characters), `InputTextUser', the result of a call to `InputTextFile'
##  from which no characters have been read, or the result of a call to
##  `InputTextString'.
##
##  `Process' is free to consume *all* the input even if the program itself
##  does not require any input at all.
##
##  <stream-out> is the output stream which receives the characters from the
##  process.
##  For portability it should either be `OutputTextNone' (if the process
##  writes no characters), `OutputTextUser', the result of a call to
##  `OutputTextFile' to which no characters have been written, or the result
##  of a call to `OutputTextString'.
##
##  <options> is a list of strings which are passed to the process as command
##  line argument.
##  Note that no substitutions are performed on the strings,
##  i.e., they are passed immediately to the process and are not processed by
##  a command interpreter (shell).
##  Further note that each string is passed as one argument,
##  even if it contains <space> characters.
##  Note that input/output redirection commands are *not* allowed as
##  <options>.
##
##  *Examples*
##
##  In order to find a system program use `DirectoriesSystemPrograms'
##  together with `Filename'.
##
##  \beginexample
##  gap> path := DirectoriesSystemPrograms();;
##  gap> date := Filename( path, "date" );
##  "/bin/date"
##  \endexample
##
##  Now execute `date' with no argument and no input, collect the output into
##  a string stream.
##
##  %notest
##  \beginexample
##  gap> str := "";; a := OutputTextString(str,true);;
##  gap> Process( DirectoryCurrent(), date, InputTextNone(), a, [] );
##  0
##  gap> CloseStream(a);
##  gap> Print(str);
##  Fri Jul 11 09:04:23 MET DST 1997
##  \endexample
##
UNBIND_GLOBAL( "Process" );
DeclareOperation( "Process",
    [ IsDirectory, IsString, IsInputStream, IsOutputStream, IsList ] );


#############################################################################
##
#F  Exec( <cmd>, <option1>, ..., <optionN> )  . . . . . . . execute a command
##
##  `Exec' runs a shell in the current directory to execute the command given
##  by the string <cmd> with options `<option1>, ..., <optionN>'.
##
##  %notest
##  \beginexample
##  gap> Exec( "date" );
##  Thu Jul 24 10:04:13 BST 1997
##  \endexample
##
##  <cmd> is interpreted by the shell and therefore we can make use of the
##  various features that a shell offers as in following example.
##
##  %notest
##  \beginexample
##  gap> Exec( "echo \"GAP is great!\" > foo" );
##  gap> Exec( "cat foo" );
##  GAP is great!
##  gap> Exec( "rm foo" );
##  \endexample
##
##  `Exec' calls the more general operation `Process' (see~"Process").
##  `Edit' (see~"Edit") should be used to call an editor from within {\GAP}.
##
DeclareGlobalFunction( "Exec" );


#############################################################################
##
#E

