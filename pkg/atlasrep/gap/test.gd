#############################################################################
##
#W  test.gd              GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: test.gd,v 1.39 2008/04/16 15:57:26 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration of functions to test the data
##  available in the &ATLAS; of Group Representations.
##
##  1. Sanity Checks for the Atlas of Group Representations
##     (These checks are performed when `tst/testall.g' is read.)
##  2. Further Tests
##     (These checks are *not* performed automatically when
##     `tst/testall.g' is read since they require server access
##     or are very time consuming.
##
Revision.( "atlasrep/gap/test_gd" ) :=
    "@(#)$Id: test.gd,v 1.39 2008/04/16 15:57:26 gap Exp $";


#############################################################################
##
##  1. Sanity Checks for the Atlas of Group Representations
##
##  These checks are performed when `tst/testall.g' is read.
##
##  <#GAPDoc Label="[1]{test}">
##  The fact that the &ATLAS; of Group Representations is designed as an
##  open database
##  (see Section&nbsp;<Ref Subsect="subsect:Local or remote access"/>)
##  makes it especially desirable to have consistency checks available
##  which can be run automatically
##  whenever new data are added by the developers of the &ATLAS;.
##  The tests described in the following can also be used
##  for private extensions of the package
##  (see Chapter&nbsp;<Ref Chap="chap:Private Extensions"/>).
##  <P/>
##  The file <F>tst/testall.g</F> of the package
##  contains <Ref Func="ReadTest" BookName="ref"/> statements
##  for executing a collection of such sanity checks;
##  one can run them by starting &GAP; in the <F>tst</F> directory,
##  and then calling <C>Read( "testall.g" )</C>.
##  If no problem occurs then &GAP; prints only lines starting with one of
##  the following.
##  <P/>
##  <Log><![CDATA[
##  + $Id:
##  + GAP4stones:
##  ]]></Log>
##  <P/>
##  The required space and time for running these tests
##  depends on the amount of locally available data.
##  <P/>
##  The examples in this manual form a part of these tests,
##  they are collected in the file <F>tst/docxpl.tst</F> of the package.
##  <P/>
##  The file <F>tst/atlasrep.tst</F> contains calls to the functions
##  <Ref Func="AtlasOfGroupRepresentationsTestGroupOrders"/>, which checks
##  the consistency of the stored group orders and the actual data,
##  <Ref Func="AtlasOfGroupRepresentationsTestFileHeaders"/>, which checks
##  the consistency of the names of &MeatAxe; text files and the first lines
##  of the files, and
##  <Ref Func="AtlasOfGroupRepresentationsTestWords"/>, which checks whether
##  the available programs do what they promise.
##  <P/>
##  The calls to <Ref Func="AtlasOfGroupRepresentationsTestFiles"/>,
##  <Ref Func="AtlasOfGroupRepresentationsTestClassScripts"/>, and
##  <Ref Func="AGR_TestMinimalDegrees"/> are not
##  part of the tests that are run by reading <F>tst/testall.g</F>.
##  <P/>
##  All these tests apply only to the <E>local</E> table of contents
##  (see Section&nbsp;<Ref Sect="sect:The Tables of Contents of the AGR"/>),
##  that is, only those data files are checked that are actually available
##  in the local &GAP; installation.
##  No files are fetched from servers during these tests.
##  <P/>
##  Further tests, such as the consistency of different versions of server
##  data, exist but are not part of the distributed package.
##  <#/GAPDoc>
##


#############################################################################
##
#V  AtlasRepHardCases
##
##  This is a record whose components belong to the various tests,
##  and list data which shall be omitted from the tests
##  because they would be too space or time consuming.
##
DeclareGlobalVariable( "AtlasRepHardCases" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestGroupOrders()
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsTestGroupOrders">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestGroupOrders" Arg=''/>
##
##  <Returns>
##  <K>false</K> if a contradiction was found, <K>true</K> otherwise.
##  </Returns>
##  <Description>
##  This function checks whether the group orders stored in the
##  <C>GAPnames</C> component of <Ref Var="AtlasOfGroupRepresentationsInfo"/>
##  coincide with the orders computed
##  from an &ATLAS; permutation representation of degree up to <M>10^4</M>,
##  from the character table or the table of marks with the given name,
##  or from the inner structure of the name (supported is a splitting of the
##  name at the first dot (<C>.</C>), where the two parts of the name are
##  examined with the same criteria in order to derive the group order).
##  <P/>
##  A message is printed for each group name
##  for which no order is stored (and perhaps now can be stored),
##  for which the stored group order cannot be verified, 
##  for which a contradiction was found.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestGroupOrders" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestSubgroupOrders()
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsTestSubgroupOrders">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestSubgroupOrders" Arg=''/>
##
##  <Returns>
##  <K>false</K> if a contradiction was found, <K>true</K> otherwise.
##  </Returns>
##  <Description>
##  This function checks whether the orders of maximal subgroups stored in
##  the <C>GAPnames</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/>
##  coincide with the orders computed
##  from an &ATLAS; permutation representation of degree up to <M>10^4</M>,
##  from the character table or the table of marks with the given name,
##  or from the information about maximal subgroups of a factor group
##  modulo a central subgroup that is contained in the derived subgroup.
##  <P/>
##  A message is printed for each group name
##  for which no order is stored (and perhaps now can be stored),
##  for which the stored group order cannot be verified, 
##  for which a contradiction was found.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestSubgroupOrders" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestStdCompatibility( [true] )
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsTestStdCompatibility">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestStdCompatibility" Arg=''/>
##
##  <Returns>
##  <K>false</K> if a contradiction was found, <K>true</K> otherwise.
##  </Returns>
##  <Description>
##  This function checks whether the compatibility info stored in
##  the <C>GAPnames</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/>
##  coincide with computed values.
##  <P/>
##  The following criterion is used for computing the value for a group
##  <M>G</M>.
##  Use the &GAP; Character Table Library to determine factor groups <M>F</M>
##  of <M>G</M> for which standard generators are defined and moreover a
##  presentation in terms of these standard generators is known.
##  Evaluate the relators of the presentation in the standard generators of
##  <M>G</M>, and let <M>N</M> be the normal closure of these elements in
##  <M>G</M>.
##  Then mapping the standard generators of <M>F</M> to the <M>N</M>cosets of
##  the standard generators of <M>G</M> is an epimorphism.
##  If <M>|G/N| = |F|</M> holds then <M>G/N</M> and <M>F</M> are isomorphic,
##  and the standard generators of <M>G</M> and <M>F</M> are compatible in
##  the sense that mapping the standard generators of <M>G</M> to their
##  <M>N</M>-cosets yields standard generators of <M>F</M>.
##  <P/>
##  A message is printed for each group name
##  for which no compatibility info was stored and now can be stored,
##  for which the stored info cannot be verified, 
##  for which a contradiction was found.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestStdCompatibility" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestCompatibleMaxes( [true] )
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsTestCompatibleMaxes">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestCompatibleMaxes" Arg=''/>
##
##  <Returns>
##  <K>false</K> if a contradiction was found, <K>true</K> otherwise.
##  </Returns>
##  <Description>
##  This function checks whether the information about maximal subgroups
##  stored in the <C>maxext</C> components of the records stored in the
##  <C>TableOfContents.remote</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/>
##  coincide with computed values.
##  <P/>
##  The following criterion is used for computing the value for a group
##  <M>G</M>.
##  If <M>F</M> is a factor group of <M>G</M> such that the standard
##  generators of <M>G</M> and <M>F</M> are compatible
##  (see <Ref Func="AtlasOfGroupRepresentationsTestStdCompatibility"/>)
##  and if there are a presentation for <M>F</M> and a permutation
##  representation of <M>G</M> then it is checked whether the <C>"maxes"</C>
##  type scripts for <M>F</M> can be used to compute also generators for the
##  maximal subgroups of <M>G</M>;
##  if not then words in terms of the standard generators are computed
##  such that the results of the script for <M>F</M> together with the
##  images of these words describe the corresponding maximal subgroup of
##  <M>G</M>.
##  <P/>
##  A message is printed for each group name
##  for which no compatibility info was stored and now can be stored,
##  for which the stored info cannot be verified, 
##  for which a contradiction was found.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestCompatibleMaxes" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestWords( [<tocid>[, <groupname>]][,]
#F                                        [<verbose>] )
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsTestWords">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestWords"
##   Arg='[tocid[, groupname]]'/>
##
##  <Returns>
##  <K>false</K> if an error occurs, otherwise <K>true</K>.
##  </Returns>
##  <Description>
##  Called with one argument <A>tocid</A>, a string,
##  <Ref Func="AtlasOfGroupRepresentationsTestWords"/> processes all programs
##  that are stored in the directory with identifier <A>tocid</A>
##  (see Section&nbsp;<Ref Func="sect:Adding a Private Data Directory"/>),
##  using the function stored in the <C>TestWords</C> component of the
##  data type in question.
##  The contents of the local <F>dataword</F> directory can be checked by
##  entering <C>"local"</C>,
##  which is also the default.
##  <P/>
##  If the string <A>groupname</A>, an &ATLAS;-file name that occurs as a
##  component name in the table of contents of the directory, is given as
##  the second argument then only the data files for this group are tested.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestWords" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestFileHeaders( [<tocid>[, <groupname>]] )
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsTestFileHeaders">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestFileHeaders"
##  Arg='[tocid[, groupname]]'/>
##
##  <Returns>
##  <K>false</K> if an error occurs, otherwise <K>true</K>.
##  </Returns>
##  <Description>
##  First suppose that this function is called with two arguments
##  <A>tocid</A>, the identifier of a directory
##  (see Section&nbsp;<Ref Func="sect:Adding a Private Data Directory"/>),
##  and <A>groupname</A>, an &ATLAS;-file name that occurs as a component
##  name in the table of contents of the directory.
##  The function checks for those data files for <A>groupname</A> in the
##  <A>tocid</A> directory that are in &MeatAxe; text format whether the
##  filename and the header line are consistent;
##  it checks the data file in &GAP; format whether the file name is
##  consistent with the contents of the file.
##  <P/>
##  If only one argument <A>tocid</A> is given then all representations
##  available for <A>groupname</A> are checked with the three argument
##  version.
##  <P/>
##  If only one argument <A>tocid</A> is given then all available groups in
##  the directory with identifier <A>tocid</A> are checked;
##  the contents of the local <C>dataword</C> directory can be checked by
##  entering <C>"local"</C>, which is also the default for <A>tocid</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestFileHeaders" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestBinaryFormat()
##
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestBinaryFormat" Arg=''/>
##
##  <Description>
##  It is checked whether all those files in the <C>datagens</C> directory
##  that contain finite field matrices in <C>C</C>-&MeatAxe; format have the
##  property that applying first <Ref Func="CMtxBinaryFFMatOrPerm"/> and then
##  <Ref Func="FFMatOrPermCMtxBinary"/> yields the same matrix.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestBinaryFormat" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestStandardization( [<groupname>] )
##
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestStandardization"
##  Arg='[groupname]'/>
##
##  <Returns>
##  <K>false</K> if an error occurs, otherwise <K>true</K>.
##  </Returns>
##  <Description>
##  Currently it is just checked whether all generating sets corresponding to
##  the same set of standard generators have the same element orders.
##  <P/>
##  <E>@As soon as the definition of standard generators becomes transparent
##  in &GAP;, more should be done!@</E>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestStandardization" );


#############################################################################
##
##  2. Further Tests
##
##  These checks are *not* performed automatically when
##  `tst/testall.g' is read since they require server access
##  or are very time consuming.
##


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
#F  AtlasOfGroupRepresentationsTestFiles( [<tocid>[,<groupname>]] )
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsTestFiles">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestFiles"
##  Arg='[tocid[,groupname]]'/>
##
##  <Returns>
##  <K>false</K> if an error occurs, otherwise <K>true</K>.
##  </Returns>
##  <Description>
##  This function is an analogue of
##  <Ref Func="AtlasOfGroupRepresentationsTestFileHeaders"/>.
##  It checks whether reading &MeatAxe; text files with
##  <Ref Func="ScanMeatAxeFile"/> returns non-<K>fail</K> results.
##  It does not check whether the first line of a &MeatAxe; text file is
##  consistent with the filename, since this is tested by
##  <Ref Func="AtlasOfGroupRepresentationsTestFileHeaders"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestFiles" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestClassScripts( [<groupname>] )
##
##  <#GAPDoc Label="AtlasOfGroupRepresentationsTestClassScripts">
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestClassScripts"
##  Arg='[groupname]'/>
##
##  <Returns>
##  <K>false</K> if an error occurs, otherwise <K>true</K>.
##  </Returns>
##  <Description>
##  First suppose that
##  <Ref Func="AtlasOfGroupRepresentationsTestClassScripts"/> is called
##  with one argument <A>groupname</A>, the name of a component in
##  <C>AtlasOfGroupRepresentationsInfo.TableOfContents.( "local" )</C>.
##  If the &GAP; table library contains an ordinary character table with
##  <Ref Func="Identifier" Label="for character tables" BookName="ref"/>
##  value the &GAP; name corresponding to <A>groupname</A>
##  then it is checked whether all those straight line programs for this
##  group that return class representatives are consistent with the character
##  table in the sense that the class names used occur for the table,
##  and that the element orders and centralizer orders for the classes are
##  correct.
##  <P/>
##  If no argument is given then all available groups are checked with the
##  one argument version.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestClassScripts" );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestCycToCcls( [<groupname>] )
##
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestCycToCcls" Arg='[groupname]'/>
##
##  <Returns>
##  <K>false</K> if an error occurs, otherwise <K>true</K>.
##  </Returns>
##  <Description>
##  First suppose that <Ref Func="AtlasOfGroupRepresentationsTestCycToCcls"/>
##  is called with one argument <A>groupname</A>, the name of a component in
##  <C>AtlasOfGroupRepresentationsInfo.TableOfContents.( "local" )</C>.
##  If the &GAP; Character Table Library <Cite Key="CTblLib"/> contains
##  an ordinary character table with
##  <Ref Func="Identifier" Label="for character tables" BookName="ref"/>
##  value the &GAP; name corresponding to <A>groupname</A>
##  then it is checked whether there is a straight line program for computing
##  representatives of cyclic subgroups such that the straight line program
##  for computing class representatives from the outputs is missing and can
##  be computed automatically; in this case the missing script is printed
##  if the level of <Ref InfoClass="InfoAtlasRep"/> is at least <M>1</M>.
##  <P/>
##  If no argument is given then all available groups are checked with the
##  one argument version.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AtlasOfGroupRepresentationsTestCycToCcls" );


#############################################################################
##
#E

