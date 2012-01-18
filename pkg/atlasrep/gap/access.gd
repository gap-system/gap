#############################################################################
##
#W  access.gd            GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,   Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions for low level access to data from the
##  ATLAS of Group Representations.
##


#############################################################################
##
#V  AGR
##
##  <#GAPDoc Label="AGR">
##  <ManSection>
##  <Var Name="AGR"/>
##
##  <Description>
##  is a record whose components are functions and data that are used by the
##  higher level interface functions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "AGR", rec( GAPnamesRec:= rec() ) );


#############################################################################
##
#V  InfoAtlasRep
##
##  <#GAPDoc Label="InfoAtlasRep">
##  <ManSection>
##  <InfoClass Name="InfoAtlasRep"/>
##
##  <Description>
##  If the info level of <Ref InfoClass="InfoAtlasRep"/> is at least <M>1</M>
##  then information about <K>fail</K> results of functions in the
##  <Package>AtlasRep</Package> package is printed.
##  If the info level is at least <M>2</M> then information about calls to
##  external programs is printed.
##  The default level is <M>0</M>, no information is printed on this level.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoAtlasRep" );


#############################################################################
##
##  Filenames Used in the Atlas of Group Representations
##
##  <#GAPDoc Label="[1]{access}">
##  The data of each local &GAP; version of the <Package>ATLAS</Package> of
##  Group Representations are either private
##  (see Chapter&nbsp;<Ref Chap="chap:Private Extensions"/>)
##  or are stored in the two directories <F>datagens</F> and <F>dataword</F>.
##  In the following, we describe the format of filenames in the latter two
##  directories, as a reference of the <Q>official</Q> part of the
##  <Package>ATLAS</Package>.
##  <P/>
##  In the directory <F>datagens</F>,
##  the generators for the <E>representations</E> available are stored,
##  the directory <F>dataword</F> contains the <E>programs</E> to compute
##  conjugacy class representatives,<Index>class representatives</Index>
##  generators of maximal subgroups,<Index>maximal subgroups</Index>
##  images of generators under automorphisms <Index>automorphisms</Index>
##  of a given group <M>G</M> from standard generators of <M>G</M>,
##  and to check and compute standard generators (see
##  Section&nbsp;<Ref Sect="sect:Standard Generators Used in AtlasRep"/>).
##  <P/>
##  The name of each data file in the
##  <Package>ATLAS</Package> of Group Representations
##  describes the contents of the file.
##  This section lists the definitions of the filenames used.
##  <P/>
##  Each filename consists of two parts, separated by a minus sign <C>-</C>.
##  The first part is always of the form <A>groupname</A><C>G</C><A>i</A>,
##  where the integer <A>i</A> denotes the <A>i</A>-th set of standard
##  generators for the group <M>G</M>, say,
##  with <Package>ATLAS</Package>-file name <A>groupname</A>
##  (see&nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>).
##  The translations of the name <A>groupname</A> to the name(s) used within
##  &GAP; is given by the component <C>GAPnames</C> of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/>.
##  <P/>
##  The filenames in the directory <F>dataword</F> have one of the following
##  forms.
##  In each of these cases, the suffix <C>W</C><A>n</A> means that <A>n</A>
##  is the version number of the program.
##  <List>
##  <#Include Label="type:cyclic:format">
##  <#Include Label="type:classes:format">
##  <#Include Label="type:cyc2ccls:format">
##  <#Include Label="type:maxes:format">
##  <#Include Label="type:maxstd:format">
##  <#Include Label="type:out:format">
##  <#Include Label="type:switch:format">
##  <#Include Label="type:check:format">
##  <#Include Label="type:pres:format">
##  <#Include Label="type:find:format">
##  <#Include Label="type:otherscripts:format">
##  </List>
##  <P/>
##  The filenames in the directory <F>datagens</F> have one of the following
##  forms.
##  In each of these cases,
##  <A>id</A> is a (possibly empty) string that starts with a lowercase
##  alphabet letter (see&nbsp;<Ref Func="IsLowerAlphaChar" BookName="ref"/>),
##  and <A>m</A> is a nonnegative integer, meaning that the generators are
##  written w.r.t.&nbsp;the <A>m</A>-th basis (the meaning is defined by the
##  <Package>ATLAS</Package> developers).
##  <P/>
##  <List>
##  <#Include Label="type:matff:format">
##  <#Include Label="type:perm:format">
##  <#Include Label="type:matalg:format">
##  <#Include Label="type:matint:format">
##  <#Include Label="type:quat:format">
##  <#Include Label="type:matmodn:format">
##  </List>
##  <#/GAPDoc>
##


#############################################################################
##
#F  AGR.ParseFilenameFormat( <string>, <format> )
##
##  <#GAPDoc Label="AGRParseFilenameFormat">
##  <ManSection>
##  <Func Name="AGR.ParseFilenameFormat" Arg='string, format'/>
##
##  <Returns>
##  a list of strings and integers if <A>string</A> matches <A>format</A>,
##  and <K>fail</K> otherwise.
##  </Returns>
##  <Description>
##  Let <A>string</A> be a filename, and <A>format</A> be a list
##  <M>[ [ c_1, c_2, \ldots, c_n ], [ f_1, f_2, \ldots, f_n ] ]</M>
##  such that each entry <M>c_i</M> is a list of strings and of functions
##  that take a character as their argument and return <F>true</F> or
##  <F>false</F>,
##  and such that each entry <M>f_i</M> is a function for parsing a filename,
##  such as the currently undocumented functions <C>ParseForwards</C> and
##  <C>ParseBackwards</C>.
##  <!-- %T add a cross-reference to gpisotyp!-->
##  <P/>
##  <Ref Func="AGR.ParseFilenameFormat"/> returns a list of strings and
##  integers such that the concatenation of their
##  <Ref Attr="String" BookName="ref"/> values yields <A>string</A> if
##  <A>string</A> matches <A>format</A>,
##  and <K>fail</K> otherwise.
##  Matching is defined as follows.
##  Splitting <A>string</A> at each minus character (<C>-</C>)
##  yields <M>m</M> parts <M>s_1, s_2, \ldots, s_m</M>.
##  The string <A>string</A> matches <A>format</A> if <M>s_i</M> matches
##  the conditions in <M>c_i</M>, for <M>1 \leq i \leq n</M>,
##  in the sense that applying <M>f_i</M> to <M>s_i</M>
##  and <M>c_i</M> yields a non-<K>fail</K> result.
##  <P/>
##  <Example><![CDATA[
##  gap> format:= [ [ [ IsChar, "G", IsDigitChar ],
##  >                 [ "p", IsDigitChar, AGR.IsLowerAlphaOrDigitChar,
##  >                   "B", IsDigitChar, ".m", IsDigitChar ] ],
##  >               [ ParseBackwards, ParseForwards ] ];;
##  gap> AGR.ParseFilenameFormat( "A6G1-p10B0.m1", format );
##  [ "A6", "G", 1, "p", 10, "", "B", 0, ".m", 1 ]
##  gap> AGR.ParseFilenameFormat( "A6G1-p15aB0.m1", format );
##  [ "A6", "G", 1, "p", 15, "a", "B", 0, ".m", 1 ]
##  gap> AGR.ParseFilenameFormat( "A6G1-f2r16B0.m1", format );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  AtlasOfGroupRepresentationsLocalFilename( <dirname>, <groupname>,
#F      <filename>, <type> )
##
##  This implements the <E>location</E> step of the access to data files.
##  The return value is a pair, the first entry being <K>true</K> if the
##  file is already locally available, and <K>false</K> otherwise,
##  and the second entry being a list of pairs
##  <C>[ <A>path</A>, <A>r</A> ]</C>,
##  where <A>path</A> is the local path where the file can be found,
##  or a list of such paths
##  (after the file has been transferred if the first entry is <K>false</K>),
##  and <A>r</A> is the record of functions to be used for transferring the
##  file.
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsLocalFilename" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsLocalFilenameTransfer( <dirname>, <groupname>,
#F      <filename>, <type> )
##
##  This implements the <E>location</E> and <E>fetch</E> steps
##  of the access to data files.
##  The return value is either <K>fail</K>
##  or a pair <C>[ <A>path</A>, <A>r</A> ]</C>
##  where <A>path</A> is either the local path (which really exists)
##  and <C>r</C> is the record containing the function to be used for reading
##  and interpreting the file contents.
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsLocalFilenameTransfer" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates()
##
##  <#GAPDoc Label="AGRTestTableOfContentsRemoteUpdates">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates"
##  Arg=''/>
##
##  <Returns>
##  the list of names of all locally available data files
##  that should be removed.
##  </Returns>
##  <Description>
##  This function fetches the file <F>changes.html</F> from the package's
##  home page, extracts the times of changes for the data files in question,
##  and compares them with the times of the last changes of the local data
##  files.
##  For that, the &GAP; package <Package>IO</Package>
##  <Cite Key="IO"/><Index>IO package</Index>
##  is needed;
##  if it is not available then an error message is printed,
##  and <K>fail</K> is returned.
##  <P/>
##  If the time of the last modification of a server file is later than
##  that of the local copy then the local file must be updated.
##  <Index Key="touch"><C>touch</C></Index>
##  (This means that <C>touch</C>ing files in the local directories
##  will cheat this function.)
##  <P/>
##  It is useful that a system administrator (i.&nbsp;e., someone who has
##  the permission to remove files from the data directories)
##  runs this function from time to time,
##  and afterwards removes the files in the list that is returned.
##  This way, new versions of these files will be fetched automatically
##  from the servers when a user asks for their data.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction(
    "AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates" );


#############################################################################
##
#F  AGR.FileContents( <dirname>, <groupname>, <filename>, <type> )
##
##  <#GAPDoc Label="AGRFileContents">
##  <ManSection>
##  <Func Name="AGR.FileContents" Arg='dirname, groupname, filename, type'/>
##
##  <Returns>
##  the &GAP; object obtained from reading and interpreting the file(s) with
##  name(s) <A>filename</A>.
##  </Returns>
##  <Description>
##  Let <A>dirname</A> and <A>groupname</A> be strings,
##  <A>filename</A> be a string or a list of strings,
##  and <A>type</A> be a data type (see <Ref Func="AGR.DeclareDataType"/>).
##  <A>dirname</A> must be one of <C>"datagens"</C>, <C>"dataword"</C>,
##  or the <A>dirid</A> value of a private directory,
##  see <Ref Func="AtlasOfGroupRepresentationsNotifyPrivateDirectory"/>.
##  If <A>groupname</A> is the <Package>ATLAS</Package>-file name of a group
##  <M>G</M> (see
##  Section <Ref Sect="sect:Group Names Used in the AtlasRep Package"/>),
##  and if <A>filename</A> is either the name of an accessible file in the
##  <A>dirname</A> directory of the <Package>ATLAS</Package>,
##  or a list of such filenames,
##  with data concerning <M>G</M> and for the data type <C>type</C>,
##  then <Ref Func="AGR.FileContents"/> returns
##  the contents of the corresponding file(s),
##  in the sense that the file(s) (or equivalent ones, see
##  Section <Ref Subsect="subsect:Customizing the Access to Data files"/>)
##  is/are read, and the result is interpreted if necessary;
##  otherwise <K>fail</K> is returned.
##  <P/>
##  Note that if <A>filename</A> refers to file(s) already stored in the
##  <A>dirname</A> directory then <Ref Func="AGR.FileContents"/>
##  does <E>not</E> check whether the table of contents of the
##  <Package>ATLAS</Package> of Group Representations actually contains
##  <A>filename</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  FilenameAtlas( <dirname>, <groupname>, <filename> )
##
##  This function was documented in version 1.2 of the package.
##  We keep it for backwards compatibility reasons,
##  but leave it undocumented.
##
DeclareGlobalFunction( "FilenameAtlas" );


#############################################################################
##
#V  AtlasOfGroupRepresentationsAccessFunctionsDefault
##
##  <#GAPDoc Label="AccessFunctionsDefault">
##  We discuss the three steps listed in Section
##  <Ref Subsect="subsect:Customizing the Access to Data files"/>.
##  <P/>
##  For creating an overview of the locally available data,
##  the first of these steps must be available independent of
##  actually accessing the file in question.
##  For updating the local copy of the server data,
##  the second of the above steps must be available independent of
##  the third one.
##  Therefore, the package provides the possibility to extend the default
##  behaviour by adding new records to the <C>accessFunctions</C>
##  component of <Ref Var="AtlasOfGroupRepresentationsInfo"/>.
##  Its components are as follows.
##  <P/>
##  <List>
##  <Mark>
##  <C>location( <A>filename</A>, <A>groupname</A>, <A>dirname</A>,
##               <A>type</A> )</C>
##  </Mark>
##  <Item>
##    Let <A>filename</A> be the default filename (without path)
##    of the required file, or a list of such filenames.
##    Let <A>groupname</A> be the <Package>ATLAS</Package> name of the group
##    to which the data in these files belong,
##    <A>dirname</A> be the default directory name (one of <C>"datagens"</C>,
##    <C>"dataword"</C>, or the <A>dirid</A> value of a private directory,
##    see <Ref Func="AtlasOfGroupRepresentationsNotifyPrivateDirectory"/>),
##    and <A>type</A> be the data type
##    (see <Ref Func="AGR.DeclareDataType"/>).
##    This function must return either the absolute path(s) where the
##    mechanism implemented by the current record expects the local version
##    of the given file(s),
##    or <K>fail</K> if this function does not feel responsible for these
##    file(s).
##    In the latter case,
##    the <C>location</C> function in another record will know a path.
##    <P/>
##    The file(s) is/are regarded as not locally available
##    if all installed <C>location</C> functions return either <K>fail</K>
##    or paths of nonexisting files,
##    in the sense of <Ref Func="IsExistingFile" BookName="ref"/>.
##  </Item>
##  <Mark>
##  <C>fetch( <A>filepath</A>, <A>filename</A>, <A>groupname</A>,
##            <A>dirname</A>, <A>type</A> )</C>
##  </Mark>
##  <Item>
##    This function is called when a file is not locally available
##    and if the <C>location</C> function in the current record has returned
##    a path or a list of paths.
##    The arguments <A>dirname</A> and <A>type</A>
##    must be the same as for the <C>location</C> function,
##    and <A>filepath</A> and <A>filename</A> must be strings
##    (<E>not</E> lists of strings).
##    <P/>
##    The return value must be <K>true</K> if the function succeeded with
##    making the file locally available (including postprocessing if
##    applicable), and <K>false</K> otherwise.
##  </Item>
##  <Mark><C>contents( <A>filepath</A>, <A>type</A> )</C></Mark>
##  <Item>
##    This function is called when the <C>location</C> function in the
##    current record has returned the path(s) <A>filepath</A>,
##    and if either these are paths of existing files
##    or the <C>fetch</C> function in the current record has been called
##    for these paths, and the return value was <K>true</K>.
##    The argument <A>type</A> must be the same as for the <C>location</C>
##    and the <C>fetch</C> functions.
##    <P/>
##    The return value must be the contents of the file(s),
##    in the sense that the &GAP; matrix, matrix list, permutation,
##    permutation list, or program described by the file(s) is returned.
##    This means that besides reading the file(s) via the appropriate
##    function, interpreting the contents may be necessary.
##  </Item>
##  <Mark><C>description</C></Mark>
##  <Item>
##    This must be a short string that describes for which kinds of files
##    the functions in the current record are intended,
##    which file formats are supported etc.
##    The value is used by
##    <Ref Func="AtlasOfGroupRepresentationsUserParameters"/>.
##  </Item>
##  <Mark><C>active</C></Mark>
##  <Item>
##    The current <C>accessFunctions</C> record is ignored
##    by <Ref Func="AGR.FileContents"/> if the value is not <K>true</K>.
##  </Item>
##  </List>
##  <P/>
##  In <Ref Func="AGR.FileContents"/>, the records in the
##  <C>accessFunctions</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/> are considered in reversed
##  order.
##  <P/>
##  By default, the <C>accessFunctions</C> list contains three records.
##  Only for one of them, the <C>active</C> component has the value
##  <K>true</K>.
##  One of the other two records can be used to change the access to
##  permutation representations and to matrix representations over finite
##  fields such that &MeatAxe; binary files
##  are transferred and read instead of &MeatAxe; text files.
##  The fourth record makes sense only if a local server is accessible,
##  i.&nbsp;e., if the server files can be read directly,
##  without being transferred into the data directories of the package.
##  <#/GAPDoc>
##
DeclareGlobalVariable( "AtlasOfGroupRepresentationsAccessFunctionsDefault" );


#############################################################################
##
##  The Tables of Contents of the Atlas of Group Representations
##
##  <#GAPDoc Label="toc">
##  The list of data currently available is stored in several
##  <E>tables of contents</E>,
##  one for the local &GAP; data, one for the data on remote servers,
##  and one for each private data directory.
##  These tables of contents are created by
##  <Ref Func="ReloadAtlasTableOfContents"/>.
##  <P/>
##  It is assumed that the local data directories contain only
##  files that are also available on servers.
##  Private extensions to the database
##  (cf. Section&nbsp;<Ref Sect="sect:Extending the Atlas Database"/>
##  and Chapter&nbsp;<Ref Chap="chap:Private Extensions"/>)
##  cannot be handled by putting the data files into the local directories.
##  <P/>
##  Each table of contents is represented by a record whose components are
##  the <Package>ATLAS</Package>-file names of the groups (see
##  Section&nbsp;<Ref Sect="sect:Group Names Used in the AtlasRep Package"/>)
##  and <C>lastupdated</C>, a string describing the date of the last update
##  of this table of contents.
##  The value for each group name is a record whose components are the names
##  of those data types
##  (see Section&nbsp;<Ref Sect="sect:Data Types Used in the AGR"/>)
##  for which data are available.
##  <P/>
##  Here are the administrational functions that are used to build the tables
##  of contents.
##  Some of them may be useful also for private extensions of the package
##  (see Chapter&nbsp;<Ref Chap="chap:Private Extensions"/>).
##  <P/>
##  The following functions define group names, available representations,
##  and straight line programs.
##  <P/>
##  <List>
##  <#Include Label="AGR.GNAN">
##  <#Include Label="AGR.GRP">
##  <#Include Label="AGR.TOC">
##  </List>
##  <P/>
##  The following functions add data about the groups and their
##  standard generators.
##  The function calls must be executed after the corresponding
##  <C>AGR.GNAN</C> calls.
##  <P/>
##  <List>
##  <#Include Label="AGR.GRS">
##  <#Include Label="AGR.MXN">
##  <#Include Label="AGR.MXO">
##  <#Include Label="AGR.MXS">
##  <#Include Label="AGR.KERPRG">
##  <#Include Label="AGR.STDCOMP">
##  </List>
##  <P/>
##  The following functions add data about representations or
##  straight line programs that are already known.
##  The function calls must be executed after the corresponding
##  <C>AGR.TOC</C> calls.
##  <P/>
##  <List>
##  <#Include Label="AGR.RNG">
##  <#Include Label="AGR.TOCEXT">
##  <#Include Label="AGR.API">
##  <#Include Label="AGR.CHAR">
##  </List>
##  <P/>
##  These functions are used to create the initial table of contents for the
##  server data of the <Package>AtlasRep</Package> package when the file
##  <F>gap/atlasprm.g</F> of the package is read.
##  <#/GAPDoc>
##


#############################################################################
##
#F  AtlasDataGAPFormatFile( <filename> )
##
##  <ManSection>
##  <Func Name="AtlasDataGAPFormatFile" Arg='filename'/>
##
##  <Description>
##  Let <A>filename</A> be the name of a file containing the generators of a
##  representation in characteristic zero such that reading the file via
##  <Ref Func="ReadAsFunction" BookName="ref"</C> yields a record
##  containing the list of the generators and additional information.
##  Then <Ref Func="AtlasDataGAPFormatFile"/> returns this record.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AtlasDataGAPFormatFile" );


#############################################################################
##
#F  AtlasStringOfFieldOfMatrixEntries( <mats> )
#F  AtlasStringOfFieldOfMatrixEntries( <filename> )
##
##  <ManSection>
##  <Func Name="AtlasStringOfFieldOfMatrixEntries" Arg='mats'/>
##  <Func Name="AtlasStringOfFieldOfMatrixEntries" Arg='filename'/>
##
##  <Description>
##  For a nonempty list <A>mats</A> of matrices of cyclotomics,
##  let <M>F</M> be the field generated by all matrix entries.
##  <Ref Func="AtlasStringOfFieldOfMatrixEntries"/> returns a pair
##  <M>[ F, <A>descr</A> ]</M>
##  where <A>descr</A> is a string describing <M>F</M>, as follows.
##  If <M>F</M> is a quadratic field then <A>descr</A> is of the form
##  <C>"Field([Sqrt(<A>n</A>)])"</C> where <A>n</A> is an integer;
##  if <M>F</M> is the <A>n</A>-th cyclotomic field,
##  for a positive integer <A>n</A>
##  then <A>descr</A> is of the form <C>"Field([E(<A>n</A>)])"</C>;
##  otherwise <A>descr</A> is the <Ref Func="String" BookName="ref"/> value
##  of the field object.
##  <P/>
##  If the argument is a string <A>filename</A> then <A>mats</A> is obtained
##  by reading the file with name <A>filename</A> via
##  <Ref Func="ReadAsFunction" BookName="ref"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AtlasStringOfFieldOfMatrixEntries" );


#############################################################################
##
#F  AtlasTableOfContents( <dirname> )
##
##  <ManSection>
##  <Func Name="AtlasTableOfContents" Arg='dirname'/>
##
##  <Description>
##  This function returns a record with components
##  <C>groupnames</C> and <C>TableOfContents</C>.
##  <P/>
##  If <A>dirname</A> is the string <C>"local"</C> or the name of a private
##  data directory then the value of the <C>groupnames</C> component is equal
##  to the value of the <C>groupnames</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/>;
##  if <A>dirname</A> is <C>"remote"</C> then the value of the
##  <C>groupnames</C> component is the union of this list and the list of
##  triples corresponding to the groups currently available on the servers.
##  <P/>
##  The value of the <C>TableOfContents</C> component is a record whose
##  components are <C>lastupdated</C> (date and time of the last update of
##  this table of contents) and the names that occur as the last entries in
##  the <C>groupnames</C> triples;
##  the value of each such component is a record whose components are the
##  names of the available data types, see
##  <Ref Sect="sect:Data Types Used in the ATLAS of Group Representations"/>,
##  for example <C>perm</C>, <C>matff</C>, <C>classes</C>, and <C>maxes</C>,
##  all lists.
##  If <A>dirname</A> is <C>"local"</C> or the name of a private data
##  directory then the contents of the local &GAP; installation or of the
##  data directory with this name is considered.
##  If <A>dirname</A> is <C>"remote"</C> then the data available on the
##  servers (see&nbsp;<Ref Var="AtlasOfGroupRepresentationsInfo"/>)
##  is considered.
##  <P/>
##  If <A>dirname</A> is <C>"remote"</C> then the result is either known in
##  advance or (if one has deliberately unbound the value) is computed by
##  fetching the file <F>atlasprm.g</F> from the package's homepage.
##  If <A>dirname</A> is <C>"local"</C> then the result is computed by
##  checking which of the files from the <C>"remote"</C> table of contents
##  are in fact locally available.
##  If <A>dirname</A> is the name of a private directory then the result is
##  computed by inspecting the contents of this directory plus the contents
##  of its subdirectories (one layer deep).
##  <P/>
##  One can customize the meaning of local availability,
##  see Section <Ref Sect="sect:How to Customize the Access to Data files"/>.
##  <P/>
##  Once a (local or remote) table of contents has been computed using
##  <Ref Func="AtlasTableOfContents"/>,
##  it is stored in the <C>TableOfContents</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/>,
##  and is just fetched when <Ref Func="AtlasTableOfContents"/> is called
##  again.
##  Recomputation can be forced using
##  <Ref Func="ReloadAtlasTableOfContents"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AtlasTableOfContents" );


#############################################################################
##
#F  ReloadAtlasTableOfContents( <dirname> )
##
##  <#GAPDoc Label="ReloadAtlasTableOfContents">
##  <ManSection>
##  <Func Name="ReloadAtlasTableOfContents" Arg='dirname'/>
##
##  <Returns>
##  <K>fail</K> if the required table of contents could not be reloaded,
##  otherwise <K>true</K>.
##  </Returns>
##  <Description>
##  Let <A>dirname</A> be a string, which must be one of <C>"remote"</C>,
##  <C>"local"</C>, or the name of a private data directory
##  (see Chapter&nbsp;<Ref Chap="chap:Private Extensions"/>).
##  <P/>
##  In the case of <C>"remote"</C>, the file <F>atlasprm.g</F> is fetched
##  from the package's home page, and then read into &GAP;.
##  In the case of <C>"local"</C>, the subset of the data listed in the
##  <C>"remote"</C> table of contents is considered that are actually
##  available in the local data directories.
##  In the case of a private directory, its contents is inspected,
##  and the table of contents for <A>dirname</A> is replaced
##  by the one obtained from inspecting the actual contents of the data
##  directories (see
##  Section&nbsp;<Ref Sect="sect:The Tables of Contents of the AGR"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ReloadAtlasTableOfContents" );


#############################################################################
##
#F  StoreAtlasTableOfContents( <filename> )
##
##  <#GAPDoc Label="StoreAtlasTableOfContents">
##  <ManSection>
##  <Func Name="StoreAtlasTableOfContents" Arg='filename'/>
##
##  <Description>
##  Let <A>filename</A> be a string. 
##  This function prints the loaded table of contents of
##  the servers to the file with name <A>filename</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StoreAtlasTableOfContents" );


#############################################################################
##  
#F  ReplaceAtlasTableOfContents( <filename> )
##
##  <#GAPDoc Label="ReplaceAtlasTableOfContents">
##  <ManSection>
##  <Func Name="ReplaceAtlasTableOfContents" Arg='filename'/>
##
##  <Description>
##  Let <A>filename</A> be the name of a file that has been created with
##  <Ref Func="StoreAtlasTableOfContents"/>.
##  <P/>
##  <Ref Func="ReplaceAtlasTableOfContents"/> first removes the information
##  that &GAP; has stored about the table of contents of the servers,
##  and then reads the file with name <A>filename</A>,
##  thus replacing the previous information by the stored one.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ReplaceAtlasTableOfContents" );


#############################################################################
##
#F  StringOfAtlasTableOfContents( "remote" )
##
##  <ManSection>
##  <Func Name="StringOfAtlasTableOfContents" Arg='"remote"'/>
##
##  <Description>
##  If the argument is the string <C>"remote"</C> then
##  this function returns a string that encodes the
##  currently stored value of the table of contents for the remote data
##  of the <Package>ATLAS</Package> of Group Representations,
##  in terms of calls to <C>AGR.GNAN</C>, <C>AGR.GRP</C>, etc.
##  <P/>
##  This function is used for automatically creating updates of the file
##  <F>gap/atlasprm.g</F> of the <Package>AtlasRep</Package> package.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "StringOfAtlasTableOfContents" );


#############################################################################
##
##  <#GAPDoc Label="[3]{access}">
##  After the <Package>AtlasRep</Package> package has been loaded into the
##  &GAP; session, one can add private data.
##  However, one should <E>not</E> add private files to the local data
##  directories of the package, or modify files in these directories.
##  Instead, additional data should be put into separate directories.
##  It should be noted that a data file is fetched from a server only if
##  the local data directories do not contain a file with this name,
##  independent of the contents of the files.
##  (As a consequence, corrupted files in the local data directories are
##  <E>not</E> automatically replaced by a correct server file.)
##  <#/GAPDoc>
##


#############################################################################
##
#F  AtlasOfGroupRepresentationsNotifyPrivateDirectory( <dir>[, <dirid>]
#F     [, <test>] )
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsNotifyPrivateDirectory">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsNotifyPrivateDirectory"
##  Arg='dir[, dirid][, test]'/>
##
##  <Returns>
##  <K>true</K> if none of the filenames with admissible format in the
##  directory <A>dir</A> is contained in other data directories
##  and if the data belongs to groups whose names have been declared,
##  otherwise <K>false</K>.
##  </Returns>
##  <Description>
##  Let <A>dir</A> be a directory
##  (see <Ref Sect="Directories" BookName="ref"/>)
##  or a string denoting the name of a directory
##  (such that the &GAP; object describing this directory can be obtained by
##  calling <Ref Func="Directory" BookName="ref"/> with the argument
##  <A>dir</A>).
##  In the following, let <A>dirname</A> be the name of the directory.
##  So <A>dirname</A> can be an absolute path or a path relative
##  to the home directory of the user (starting with a tilde character
##  <C>~</C>)
##  or a path relative to the directory where &GAP; was started.
##  <P/>
##  If the optional argument <A>dirid</A> is given, it must be a string.
##  This value will be used in the <C>identifier</C> components of the
##  records that are returned by interface functions (see
##  Section&nbsp;<Ref Sect="sect:Accessing Data of the AtlasRep Package"/>)
##  for data contained in the directory <A>dir</A>.
##  Note that the directory name may be different in different &GAP;
##  sessions or for different users who want to access the same data,
##  whereas the <C>identifier</C> components shall be independent of such
##  differences.
##  The default for <A>dirid</A> is <A>dirname</A>.
##  <P/>
##  If the optional argument <A>test</A> is given, it must be <K>true</K> or
##  <K>false</K>.
##  In the <K>true</K> case, consistency checks are switched on while the
##  file <F>toc.g</F> is read.
##  This costs some extra time, but it is recommended after each extension of
##  the file <F>toc.g</F>.
##  The default for <A>test</A> is <K>false</K>.
##  <P/>
##  <Ref Func="AtlasOfGroupRepresentationsNotifyPrivateDirectory"/> notifies
##  the data in the directory <A>dir</A> to the <Package>AtlasRep</Package>
##  package.
##  First the pair <C>[ <A>dirname</A>, <A>dirid</A> ]</C>
##  is added to the <C>private</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/>.
##  If the directory contains a file with the name <F>toc.g</F> then this
##  file is read;
##  this file is useful for adding new group names using <C>AGR.GNAN</C> and
##  for adding describing data about the representations,
##  see Section&nbsp;<Ref Sect="sect:The Tables of Contents of the AGR"/>.
##  Next the table of contents of the private directory is built from the
##  list of files contained in the private directory or in its subdirectories
##  (one layer deep).
##  <P/>
##  Only those files are considered whose names match an admissible format
##  (see Section&nbsp;<Ref Sect="sect:Filenames Used in the AGR"/>).
##  Filenames that are already contained in another data directory of the
##  <Package>AtlasRep</Package> package are ignored,
##  and messages about these filenames are printed if the info level of
##  <Ref InfoClass="InfoAtlasRep"/> is at least <M>1</M>.
##  <P/>
##  Note that this implies that the files of the <Q>official</Q>
##  (i.e. non-private) data directories have priority over files in private
##  directories.
##  <P/>
##  If the directory contains files for groups whose names have not been
##  declared before and if the info level of <Ref InfoClass="InfoAtlasRep"/>
##  is at least <M>1</M> then a message about these names is printed.
##  <P/>
##  For convenience, the user may collect the notifications of private data
##  directories in the file <F>gaprc</F> (see
##  Section&nbsp;<Ref Sect="The gap.ini and gaprc files" BookName="ref"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsNotifyPrivateDirectory" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsForgetPrivateDirectory( <dirid> )
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsForgetPrivateDirectory">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsForgetPrivateDirectory"
##  Arg='dirid'/>
##
##  <Description>
##  If <A>dirid</A> is the identifier of a private data directory that has
##  been notified with
##  <Ref Func="AtlasOfGroupRepresentationsNotifyPrivateDirectory"/>
##  then <Ref Func="AtlasOfGroupRepresentationsForgetPrivateDirectory"/>
##  removes the directory from the list of notified private directories;
##  this means that from then on, the data in this directory cannot be
##  accessed anymore in the current session.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsForgetPrivateDirectory" );


#############################################################################
##
#E

