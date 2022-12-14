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
##  gap> path := DirectoriesSystemPrograms();;
##  gap> ls := Filename( path, "ls" );;
##  gap> stdin := InputTextUser();;
##  gap> stdout := OutputTextUser();;
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
##  In order to find a system program use <Ref Func="DirectoriesSystemPrograms"/>
##  together with <Ref Oper="Filename" Label="for a directory and a string"/>.
##  <P/>
##  <Log><![CDATA[
##  gap> path := DirectoriesSystemPrograms();;
##  gap> date := Filename( path, "date" );
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
##  <Ref Func="Exec"/> calls the more general operation <Ref Oper="Process"/>.
##  The function <Ref Func="Edit"/> should be used to call an editor from
##  within &GAP;.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Exec" );
