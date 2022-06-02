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
##  This file contains the operations for process.
##


#############################################################################
##  <#GAPDoc Label="[1]{process}">
##  &GAP; can call other programs, such programs are called <E>processes</E>.
##  There are two kinds of processes:
##  first there are processes that are started, run and return a result,
##  while &GAP; is suspended until the process terminates.
##  Then there are processes that will run in parallel to &GAP; as
##  subprocesses and &GAP; can communicate and control the processes using
##  streams (see&nbsp;<Ref Func="InputOutputLocalProcess"/>).
##  <#/GAPDoc>
##


#############################################################################
##
#O  Process( <dir>, <prg>, <stream-in>, <stream-out>, <options> )
##
##  <#GAPDoc Label="Process">
##  <ManSection>
##  <Oper Name="Process" Arg='dir, prg, stream-in, stream-out, options'/>
##
##  <Description>
##  <Ref Oper="Process"/> runs a new process and returns when the process terminates.
##  It returns the return value of the process if the operating system
##  supports such a concept.
##  <P/>
##  The first argument <A>dir</A> is a directory object (see&nbsp;<Ref Sect="Directories"/>)
##  which will be the current directory (in the usual UNIX or MS-DOS sense)
##  when the program is run.
##  This will only matter if the program accesses files (including running
##  other programs) via relative path names.
##  In particular, it has nothing to do with finding the binary to run.
##  <P/>
##  In general the directory will either be the current directory, which is
##  returned by <Ref Func="DirectoryCurrent"/>
##  &ndash;this was the behaviour of &GAP;&nbsp;3&ndash;
##  or a temporary directory returned by <Ref Func="DirectoryTemporary"/>.
##  If one expects that the process creates temporary or log files the latter
##  should be used because &GAP; will attempt to remove these directories
##  together with all the files in them when quitting.
##  <P/>
##  If a program of a &GAP; package which does not only consist of &GAP;
##  code needs to be launched in a directory relative to certain data
##  libraries, then the first entry of <Ref Func="DirectoriesPackageLibrary"/>
##  should be used.
##  The argument of <Ref Func="DirectoriesPackageLibrary"/> should be the path to the
##  data library relative to the package directory.
##  <P/>
##  If a program calls other programs and needs to be launched in a directory
##  containing the executables for such a &GAP; package then the first entry
##  of <Ref Func="DirectoriesPackagePrograms"/> should be used.
##  <P/>
##  The latter two alternatives should only be used if absolutely necessary
##  because otherwise one risks accumulating log or core files in the package
##  directory.
##  <P/>
##  <Log><![CDATA[
##  gap> ls := PathSystemProgram( "ls" );;
##  gap> stdin := InputTextUser();;
##  gap> stdout := OutputTextUser();;
##  gap> path := DirectoriesSystemPrograms();;
##  gap> Process( path[1], ls, stdin, stdout, ["-c"] );;
##  awk    ls     mkdir
##  gap> # current directory, here the root directory
##  gap> Process( DirectoryCurrent(), ls, stdin, stdout, ["-c"] );;
##  bin    lib    trans  tst    CVS    grp    prim   thr    two
##  src    dev    etc    tbl    doc    pkg    small  tom
##  gap> # create a temporary directory
##  gap> tmpdir := DirectoryTemporary();;
##  gap> Process( tmpdir, ls, stdin, stdout, ["-c"] );;
##  gap> PrintTo( Filename( tmpdir, "emil" ) );
##  gap> Process( tmpdir, ls, stdin, stdout, ["-c"] );;
##  emil
##  ]]></Log>
##  <P/>
##  <A>prg</A> is the filename of the program to launch,
##  for portability it should be the result of
##  <Ref Oper="Filename" Label="for a directory and a string"/>
##  and should pass <Ref Func="IsExecutableFile"/>.
##  Note that <Ref Oper="Process"/> does <E>no</E> searching through a list
##  of directories, this is done by
##  <Ref Oper="Filename" Label="for a directory and a string"/>.
##  <P/>
##  <A>stream-in</A> is the input stream that delivers the characters to the
##  process.
##  For portability it should either be <Ref Func="InputTextNone"/>
##  (if the process reads no characters), <Ref Func="InputTextUser"/>,
##  the result of a call to <Ref Oper="InputTextFile"/>
##  from which no characters have been read, or the result of a call to
##  <Ref Oper="InputTextString"/>.
##  <P/>
##  <Ref Oper="Process"/> is free to consume <E>all</E> the input even if the program itself
##  does not require any input at all.
##  <P/>
##  <A>stream-out</A> is the output stream which receives the characters from the
##  process.
##  For portability it should either be <Ref Func="OutputTextNone"/> (if the process
##  writes no characters), <Ref Func="OutputTextUser"/>, the result of a call to
##  <Ref Oper="OutputTextFile"/> to which no characters have been written, or the result
##  of a call to <Ref Oper="OutputTextString"/>.
##  <P/>
##  <A>options</A> is a list of strings which are passed to the process as command
##  line argument.
##  Note that no substitutions are performed on the strings,
##  i.e., they are passed immediately to the process and are not processed by
##  a command interpreter (shell).
##  Further note that each string is passed as one argument,
##  even if it contains <E>space</E> characters.
##  Note that input/output redirection commands are <E>not</E> allowed as
##  <A>options</A>.
##  <P/>
##  In order to find a system program use <Ref Func="PathSystemProgram"/>.
##  <P/>
##  <Log><![CDATA[
##  gap> date := PathSystemProgram( "date" );
##  "/bin/date"
##  ]]></Log>
##  <P/>
##  The next example shows how to execute <C>date</C> with no argument and no input,
##  and collect the output into a string stream.
##  <P/>
##  <Log><![CDATA[
##  gap> str := "";; a := OutputTextString(str,true);;
##  gap> Process( DirectoryCurrent(), date, InputTextNone(), a, [] );
##  0
##  gap> CloseStream(a);
##  gap> Print(str);
##  Fri Jul 11 09:04:23 MET DST 1997
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
UNBIND_GLOBAL( "Process" );
DeclareOperation( "Process",
    [ IsDirectory, IsString, IsInputStream, IsOutputStream, IsList ] );

#############################################################################
##
#F  Exec( <cmd>, <option1>, ..., <optionN> )  . . . . . . . execute a command
##
##  <#GAPDoc Label="Exec">
##  <ManSection>
##  <Func Name="Exec" Arg='cmd, option1, ..., optionN'/>
##
##  <Description>
##  <Ref Func="Exec"/> runs a shell in the current directory to execute the command given
##  by the string <A>cmd</A> with options <A>option1</A>, ..., <A>optionN</A>.
##  <P/>
##  <Log><![CDATA[
##  gap> Exec( "date" );
##  Thu Jul 24 10:04:13 BST 1997
##  ]]></Log>
##  <P/>
##  <A>cmd</A> is interpreted by the shell and therefore we can make use of the
##  various features that a shell offers as in following example.
##  <P/>
##  <Log><![CDATA[
##  gap> Exec( "echo \"GAP is great!\" > foo" );
##  gap> Exec( "cat foo" );
##  GAP is great!
##  gap> Exec( "rm foo" );
##  ]]></Log>
##  <P/>
##  Because <A>cmd</A> is interpreted by a shell, it is difficult to pass
##  arguments containing spaces or quotes reliably, and the exit code of the
##  command is not available.
##  For new code <Ref Func="RunProcess"/> is therefore usually the better
##  choice.
##  <P/>
##  <Ref Func="Exec"/> calls the more general operation <Ref Oper="Process"/>.
##  The function <Ref Func="Edit"/> should be used to call an editor from
##  within &GAP;.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Exec" );



#############################################################################
##
#F  RunProcess( <cmd>[, <arg1>, ...][, <options>] ) . . . . . run a program
##
##  <#GAPDoc Label="RunProcess">
##  <ManSection>
##  <Func Name="RunProcess" Arg='cmd[, arg1, ..., argN][, options]'/>
##
##  <Description>
##  <Ref Func="RunProcess"/> runs the program <A>cmd</A> with the arguments
##  <A>arg1</A>, ..., <A>argN</A>, waits for it to terminate, and returns a
##  record describing the outcome.
##  <P/>
##  If <A>cmd</A> contains no path separator, it is looked up in the
##  directories returned by <Ref Func="DirectoriesSystemPrograms"/>;
##  otherwise it is used as a path as-is.
##  Each argument must be a string or an integer, the latter being converted
##  via <Ref Attr="String"/>.
##  <P/>
##  No shell is involved: the arguments are handed to the program verbatim.
##  There is thus no need to quote or escape arguments containing spaces or
##  other special characters, and the behaviour does not depend on which
##  shell happens to be installed.
##  The flip side is that shell features are not available, so unlike
##  <Ref Func="Exec"/> one cannot use redirections such as
##  <C>&gt;/dev/null</C>, pipes, or wildcard expansion.
##  <P/>
##  The returned record always has the component <C>status</C>, the exit code
##  of the program.
##  A nonzero exit code is not treated as an error by
##  <Ref Func="RunProcess"/>; it is up to the caller to check it.
##  <P/>
##  <Log><![CDATA[
##  gap> res := RunProcess("echo", "GAP is great!");
##  rec( output := "GAP is great!\n", status := 0 )
##  gap> RunProcess("false").status;
##  1
##  ]]></Log>
##  <P/>
##  The optional final argument <A>options</A> is a record which may have the
##  following components.
##  <List>
##  <Mark><C>directory</C></Mark>
##  <Item>
##    the directory in which the program is run, as a directory object
##    (see&nbsp;<Ref Sect="Directories"/>);
##    it defaults to <Ref Func="DirectoryCurrent"/>.
##  </Item>
##  <Mark><C>input</C></Mark>
##  <Item>
##    an input stream serving as the standard input of the program.
##    By default the program receives no input at all; note that this differs
##    from <Ref Func="Exec"/>, which passes on whatever the user types.
##  </Item>
##  <Mark><C>output</C></Mark>
##  <Item>
##    an output stream receiving the standard output of the program.
##    By default the output is captured and returned in the <C>output</C>
##    component of the result record; if this option is given, the result
##    record has no <C>output</C> component.
##  </Item>
##  </List>
##  <P/>
##  <Log><![CDATA[
##  gap> input := InputTextString("hello\n");;
##  gap> RunProcess("sort", rec(input := input, output := OutputTextUser()));
##  hello
##  rec( status := 0 )
##  ]]></Log>
##  <P/>
##  The standard error stream of the program is currently inherited from
##  &GAP; and cannot be redirected or captured, since &GAP; has no support
##  for this yet.
##  <P/>
##  <Ref Func="RunProcess"/> calls the more general operation
##  <Ref Oper="Process"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RunProcess" );
