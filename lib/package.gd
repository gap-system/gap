#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains support for &GAP; packages.
##
#T TODO: document the utilities
#T   `SuggestUpgrades'
#T   `LoadAllPackages'
#T   `PackageAvailabilityInfo'
##


#############################################################################
##
#V  GAPInfo.PackagesInfo
#V  GAPInfo.PackagesLoaded
#V  GAPInfo.PackageLoadingMessages
#V  GAPInfo.PackageInfoCurrent
#V  GAPInfo.PackagesInfoInitialized
#V  GAPInfo.PackageExtensionsLoaded
#V  GAPInfo.PackageExtensionsPending
##
##  <ManSection>
##  <Var Name="GAPInfo.PackagesInfo"/>
##  <Var Name="GAPInfo.PackagesLoaded"/>
##  <Var Name="GAPInfo.PackageLoadingMessages"/>
##  <Var Name="GAPInfo.PackageInfoCurrent"/>
##  <Var Name="GAPInfo.PackagesInfoInitialized"/>
##  <Var Name="GAPInfo.PackageExtensionsLoaded"/>
##  <Var Name="GAPInfo.PackageExtensionsPending"/>
##
##  <Description>
##  These global variables are used in the administration of &GAP; packages.
##  <P/>
##  <Ref Var="GAPInfo.PackagesInfo"/> is a mutable record,
##  its component names are the names of those
##  packages for which the <F>PackageInfo.g</F> files have been read.
##  (These packages are not necessarily loaded.)
##  <P/>
##  <Ref Var="GAPInfo.PackagesLoaded"/> is a mutable record,
##  its component names are the names of those &GAP; packages that are
##  already loaded.
##  The component for each package is a list of length four, the entries
##  being the path to the &GAP; root directory that contains the package,
##  the package version, the package name, and a boolean indicating whether
##  the package finished loading.
##  For each package, the value gets bound in the <Ref Func="LoadPackage"/>
##  call.
##  <P/>
##  <Ref Var="GAPInfo.PackageLoadingMessages"/> is a list of triples
##  in which the first entry is the name of the package to which the message
##  belongs, the second entry is the severity of the message
##  (see <Ref Func="DisplayPackageLoadingLog"/>), and the third entry is the
##  list of strings that form the message.
##  <P/>
##  <Ref Var="GAPInfo.PackageInfoCurrent"/> is the record that has been
##  temporarily set by <C>SetPackageInfo</C> after a <F>PackageInfo.g</F>
##  file has been read.
##  <P/>
##  <Ref Var="GAPInfo.PackagesInfoInitialized"/> is set to <K>true</K>
##  after <Ref Func="InitializePackagesInfoRecords"/> has evaluated the
##  <F>PackageInfo.g</F> files in all <F>pkg</F> subdirectories of &GAP;
##  root directories.
##  <P/>
##  <Ref Var="GAPInfo.PackageExtensionsLoaded"/> is the list that contains
##  those entries from <C>Extensions</C> in <F>PackageInfo.g</F>
##  files (together with the name of the package to which the extension
##  belongs) such that the extensions in question have already been loaded,
##  and <Ref Var="GAPInfo.PackageExtensionsPending"/> is the list of those
##  such entries such that the extensions in question has not yet been
##  loaded.
##  </Description>
##  </ManSection>
##
if IsHPCGAP then
    GAPInfo.PackagesInfo := AtomicRecord( rec() );
    GAPInfo.PackagesLoaded := AtomicRecord( rec() );
    GAPInfo.PackageLoadingMessages := AtomicList( [] );
    GAPInfo.PackageExtensionsLoaded := AtomicList( [] );
    GAPInfo.PackageExtensionsPending := AtomicList( [] );
else
    GAPInfo.PackagesInfo := rec();
    GAPInfo.PackagesLoaded := rec();
    GAPInfo.PackageLoadingMessages := [];
    GAPInfo.PackageExtensionsLoaded := [];
    GAPInfo.PackageExtensionsPending := [];
fi;


#############################################################################
##
#F  CompareVersionNumbers( <supplied>, <required>[, "equal"] )
##
##  <#GAPDoc Label="CompareVersionNumbers">
##  <ManSection>
##  <Func Name="CompareVersionNumbers" Arg='supplied, required[, "equal"]'/>
##
##  <Description>
##  A version number is a string which contains nonnegative integers separated
##  by non-numeric characters. Examples of valid version numbers are for
##  example:
##  <P/>
##  <Log><![CDATA[
##  "1.0"   "3.141.59"  "2-7-8.3" "5 release 2 patchlevel 666"
##  ]]></Log>
##  <P/>
##  <Ref Func="CompareVersionNumbers"/>
##  compares two version numbers, given as strings.
##  They are split at non-digit characters,
##  the resulting integer lists are compared lexicographically.
##  The routine tests whether <A>supplied</A> is at least as large as
##  <A>required</A>, and returns <K>true</K> or <K>false</K> accordingly.
##  A version number ending in <C>dev</C> is considered to be infinite.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CompareVersionNumbers" );


#############################################################################
##
#F  PackageInfo( <pkgname> )
##
##  <ManSection>
##  <Func Name="PackageInfo" Arg='pkgname'/>
##
##  <Description>
##  Fetch the list of info records for the package with name <A>pkgname</A>.
##  This information is assumed to be set by
##  <Ref Func="InitializePackagesInfoRecords"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PackageInfo" );


#############################################################################
##
#F  RECORDS_FILE( <name> )
##
##  <ManSection>
##  <Func Name="RECORDS_FILE" Arg='name'/>
##
##  <Description>
##  a helper (for <Ref Func="InitializePackagesInfoRecords"/>),
##  get records from a file
##  First removes everything in each line which starts with a <C>&hash;</C>,
##  then splits remaining content at whitespace.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "RECORDS_FILE" );


#############################################################################
##
#F  SetPackageInfo( <record> )
##
##  <ManSection>
##  <Func Name="SetPackageInfo" Arg='record'/>
##
##  <Description>
##  Each <F>PackageInfo.g</F> file contains a call to
##  <Ref Func="SetPackageInfo"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SetPackageInfo" );


#############################################################################
##
#F  InitializePackagesInfoRecords()
##
##  <ManSection>
##  <Func Name="InitializePackagesInfoRecords" Arg=''/>
##
##  <Description>
##  This function reads all <F>PackageInfo.g</F> files
##  in all <F>pkg</F> subdirectories of &GAP; root directories,
##  checks the conditions in <C>GAPInfo.PackagesRestrictions</C>,
##  and sorts the lists of records according to descending package
##  version numbers.
##  <P/>
##  The function initializes global records.
##  <List>
##  <Mark><C>GAPInfo.PackagesInfo</C></Mark>
##  <Item>
##       the record with the lists of info records of all existing packages;
##       they are looked up in all subdirectories of <F>pkg</F>
##       subdirectories of &GAP; root directories,
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InitializePackagesInfoRecords" );


#############################################################################
##
#F  LinearOrderByPartialWeakOrder( <pairs>, <weights> )
##
##  <ManSection>
##  <Func Name="LinearOrderByPartialWeakOrder" Arg='pairs, weights'/>
##
##  <Description>
##  Let <A>pairs</A> be a finite list
##  <M>[ [ x_1, y_1 ], [ x_2, y_2 ], \ldots ]</M>, where the <M>x_i</M> and
##  <M>y_i</M> are &GAP; objects for which the comparison with <C>=</C> is
##  defined.
##  Let <A>weights</A> be a finite list
##  <M>[ [ z_1, w_1 ], [ z_2, w_2 ], \ldots ]</M> where the <M>z_i</M> occur
##  among the <M>x_i</M>, <M>y_i</M> and the <M>w_i</M> are nonnegative
##  integers.
##  <P/>
##  We interpret this input as the definition of a partial weak order on the
##  <M>x_i</M>, <M>y_i</M>,
##  given by <M>x_1 \leq y_1, x_2 \leq y_2, \ldots</M>.
##  We call <M>w_i</M> the weight of <M>z_i</M>.
##  <P/>
##  The output is a record with the components <C>cycles</C> and
##  <C>weights</C>.
##  The value of <C>cycles</C> is a list <M>[ c_1, c_2, \ldots ]</M>,
##  where each <M>c_i</M> is a list of the <M>x_i</M> and <M>y_i</M>,
##  with the following property.
##  For each pair <M>[ x, y ]</M> in the input list where
##  <M>x</M> occurs in <M>c_j</M> and <M>y</M> occurs in <M>c_k</M>,
##  we have <M>j \leq k</M>, and <M>j = k</M> holds only if the input
##  contains a cycle of the form <M>[ x, y ], [ y, z ], \ldots, [ ., x ]</M>.
##  <P/>
##  So each <M>c_i</M> consists of a single element
##  if the input does not contain such cycles.
##  <P/>
##  Furthermore, if no entry of <M>c_j</M> is comparable with any entry of
##  <M>c_k</M>, w.r.t.&nbsp;the transitive closure of the given weak partial
##  ordering and if the maximal weight of the entries in <M>c_j</M>
##  is smaller than the maximal weight of the entries in <M>c_k</M>
##  then we have <M>j \leq k</M>.
##  <P/>
##  The value of <C>weights</C> is a list of the same length as <C>cycles</C>
##  where the <M>i</M>-th entry is the maximal weight of the members of the
##  <M>i</M>-th entry in <C>cycles</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "LinearOrderByPartialWeakOrder" );


#############################################################################
##
#F  PackageAvailabilityInfo( <name>, <version>, <record>, <suggested>,
#F      <checkall> )
##
##  Let <A>name</A> and <A>version</A> be strings,
##  <A>record</A> be a record,
##  and <A>suggested</A> and <A>checkall</A> be either <K>true</K> or
##  <K>false</K>.
##  This function tests whether the &GAP; package <A>name</A> is available
##  for loading in a version that is at least <A>version</A>, or equal to
##  <A>version</A> if the first character of <A>version</A> is <C>=</C>,
##  see Section <Ref Sect="Version Numbers"/>
##  for details about version numbers.
##  <P/>
##  As usual, the argument <A>name</A> is case insensitive.
##  <P/>
##  The result is <K>true</K> if the package <A>name</A> is already loaded,
##  <K>false</K> if it cannot be loaded in the desired version,
##  and the string denoting the &GAP; root path where the package resides
##  if the package is available, but not yet loaded.
##  (In recursive calls, also <K>fail</K> may be returned, which means that
##  the decision will be made on an outer level.)
##  <P/>
##  There can be various reasons for the return value <K>false</K>:
##  <List>
##  <Item>
##    No version of the package is installed,
##  </Item>
##  <Item>
##    the required version is not installed,
##  </Item>
##  <Item>
##    some needed package cannot be loaded, or
##  </Item>
##  <Item>
##    the <C>AvailabilityTest</C> function in the <F>PackageInfo.g</F> file
##    of the package returned <K>false</K>.
##  </Item>
##  </List>
##  <P/>
##  The arguments <A>record</A> and <A>suggested</A> are used
##  for loading packages, as follows.
##  <P/>
##  The record <A>record</A> collects information about the needed and
##  suggested packages of the package <A>name</A>, which allows one to
##  compute an appropriate loading order of these packages.
##  After the call, the value of the component <C>LoadInfo</C> of
##  <A>record</A> is a record with the components
##  <List>
##  <Item>
##    <C>name</C> (the name of the package),
##  </Item>
##  <Item>
##    <C>comment</C> (a string that is empty or describes why the package
##    cannot be loaded, independent of the installed version), and
##  </Item>
##  <Item>
##    <C>versions</C> (a list of records, one for each installed version of
##    the package that has been checked; each such record has the components
##    <C>version</C>, <C>comment</C>, and <C>dependencies</C>,
##    where the latter is a list of records for each needed package that was
##    checked, and each entry has the same format as the <C>LoadInfo</C>
##    record itself.
##  </Item>
##  </List>
##  <P/>
##  Finally, the value of <A>suggested</A> determines whether needed and
##  suggested packages are considered (value <K>true</K>) or only needed
##  packages (value <K>false</K>);
##  the latter is used for example in <Ref Func="TestPackageAvailability"/>.
##  <P/>
##  The argument <A>checkall</A> will be <K>false</K> when the function is
##  called by <Ref Func="LoadPackage"/>;
##  the value <K>true</K> means that all checks are performed,
##  even if some have turned out to be not satisfied.
##  This is useful when one is interested in the reasons why the package
##  <A>name</A> cannot be loaded.
##
DeclareGlobalFunction( "PackageAvailabilityInfo" );


#############################################################################
##
#F  TestPackageAvailability( <name>[, <version>][, <checkall>] )
##
##  <#GAPDoc Label="TestPackageAvailability">
##  <ManSection>
##  <Func Name="TestPackageAvailability" Arg='name[, version][, checkall]'/>
##
##  <Description>
##  For strings <A>name</A> and <A>version</A>, this function tests
##  whether the  &GAP; package <A>name</A> is available for loading in a
##  version that is at least <A>version</A>, or equal to <A>version</A>
##  if the first character of <A>version</A> is <C>=</C>
##  (see <Ref Func="CompareVersionNumbers"/> for further
##  details about version numbers).
##  <P/>
##  The result is <K>true</K> if the package is already loaded,
##  <K>fail</K> if it is not available,
##  and the string denoting the &GAP; root path where the package resides
##  if it is available, but not yet loaded.
##  So the package <A>name</A> is available if the result of
##  <Ref Func="TestPackageAvailability"/> is not equal to <K>fail</K>.
##  <P/>
##  If the optional argument <A>checkall</A> is <K>true</K> then all
##  dependencies are checked, even if some have turned out to be not
##  satisfied.
##  This is useful when one is interested in the reasons why the package
##  <A>name</A> cannot be loaded.
##  In this situation, calling first <Ref Func="TestPackageAvailability"/>
##  and then <Ref Func="DisplayPackageLoadingLog"/> with argument
##  <Ref Var="PACKAGE_INFO"/> will give an overview of these reasons.
##  <P/>
##  You should <E>not</E> call <Ref Func="TestPackageAvailability"/> in
##  the test function of a package (the value of the component
##  <C>AvailabilityTest</C> in the <F>PackageInfo.g</F> file of the package,
##  see <Ref Sect="The PackageInfo.g File"/>),
##  because <Ref Func="TestPackageAvailability"/> calls this test function.
##  <!-- otherwise we run into an infinite recursion -->
##  <P/>
##  The argument <A>name</A> is case insensitive.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TestPackageAvailability" );


#############################################################################
##
#F  IsPackageLoaded( <name>[, <version>] )
##
##  <#GAPDoc Label="IsPackageLoaded">
##  <ManSection>
##  <Func Name="IsPackageLoaded" Arg='name[, version]'/>
##
##  <Description>
##  For strings <A>name</A> and <A>version</A>, this function tests
##  whether the &GAP; package <A>name</A> is already loaded in a
##  version that is at least <A>version</A>, or equal to <A>version</A>
##  if the first character of <A>version</A> is <C>=</C>
##  (see <Ref Func="CompareVersionNumbers"/> for further
##  details about version numbers).
##  <P/>
##  The result is <K>true</K> if the package is already loaded,
##  <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsPackageLoaded" );


#############################################################################
##
#F  DisplayPackageLoadingLog( [<severity>] )
#I  InfoPackageLoading
#V  PACKAGE_ERROR
#V  PACKAGE_WARNING
#V  PACKAGE_INFO
#V  PACKAGE_DEBUG
#F  LogPackageLoadingMessage( <severity>, <message>[, <name>] )
##
##  <#GAPDoc Label="DisplayPackageLoadingLog">
##  <ManSection>
##  <Func Name="DisplayPackageLoadingLog" Arg='[severity]'/>
##  <InfoClass Name="InfoPackageLoading"/>
##  <Var Name="PACKAGE_ERROR"/>
##  <Var Name="PACKAGE_WARNING"/>
##  <Var Name="PACKAGE_INFO"/>
##  <Var Name="PACKAGE_DEBUG"/>
##  <Func Name="LogPackageLoadingMessage" Arg='severity, message[, name]'/>
##
##  <Description>
##  Whenever &GAP; considers loading a package, log messages are collected
##  in a global list.
##  The messages for the current &GAP; session can be displayed with
##  <Ref Func="DisplayPackageLoadingLog"/>.
##  To each message, a <Q>severity</Q> is assigned,
##  which is one of <Ref Var="PACKAGE_ERROR"/>, <Ref Var="PACKAGE_WARNING"/>,
##  <Ref Var="PACKAGE_INFO"/>, <Ref Var="PACKAGE_DEBUG"/>,
##  in increasing order.
##  The function <Ref Func="DisplayPackageLoadingLog"/> shows only the
##  messages whose severity is at most <A>severity</A>,
##  the default for <A>severity</A> is <Ref Var="PACKAGE_WARNING"/>.
##  <P/>
##  The intended meaning of the severity levels is as follows.
##  <P/>
##  <List>
##  <Mark>PACKAGE_ERROR</Mark>
##  <Item>
##    should be used whenever &GAP; will run into an error
##    during package loading,
##    where the reason of the error shall be documented in the global list.
##  </Item>
##  <Mark>PACKAGE_WARNING</Mark>
##  <Item>
##    should be used whenever &GAP; has detected a reason why a package
##    cannot be loaded,
##    and where the message describes how to solve this problem,
##    for example if a package binary is missing.
##  </Item>
##  <Mark>PACKAGE_INFO</Mark>
##  <Item>
##    should be used whenever &GAP; has detected a reason why a package
##    cannot be loaded,
##    and where it is not clear how to solve this problem,
##    for example if the package is not compatible with other installed
##    packages.
##  </Item>
##  <Mark>PACKAGE_DEBUG</Mark>
##  <Item>
##    should be used for other messages reporting what &GAP; does when it
##    loads packages (checking dependencies, reading files, etc.).
##    One purpose is to record in which order packages have been considered
##    for loading or have actually been loaded.
##  </Item>
##  </List>
##  <P/>
##  The log messages are created either by the functions of &GAP;'s
##  package loading mechanism or in the code of your package, for example
##  in the <C>AvailabilityTest</C> function of the package's
##  <F>PackageInfo.g</F> file (see <Ref Sect="The PackageInfo.g File"/>),
##  using <Ref Func="LogPackageLoadingMessage"/>.
##  The arguments of this function are <A>severity</A>
##  (which must be one of the above severity levels),
##  <A>message</A> (which must be either a string or a list of strings),
##  and optionally <A>name</A> (which must be the name of the package to
##  which the message belongs).
##  The argument <A>name</A> is not needed if the function is called from
##  a call of a package's <C>AvailabilityTest</C> function
##  (see <Ref Sect="The PackageInfo.g File"/>)
##  or is called from a package file that is read from <F>init.g</F> or
##  <F>read.g</F>; in these cases, the name of the current package
##  (stored in the record <C>GAPInfo.PackageCurrent</C>) is taken.
##  According to the above list, the <A>severity</A> argument of
##  <Ref Func="LogPackageLoadingMessage"/> calls in a package's
##  <C>AvailabilityTest</C> function is either <Ref Var="PACKAGE_WARNING"/>
##  or <Ref Var="PACKAGE_INFO"/>.
##  <P/>
##  If you want to see the log messages already during the package loading
##  process, you can set the level of the info class
##  <Ref InfoClass="InfoPackageLoading"/> to one of the severity values
##  listed above;
##  afterwards the messages with at most this severity are shown immediately
##  when they arise.
##  In order to make this work already for autoloaded packages,
##  you can call <C>SetUserPreference("InfoPackageLoadingLevel",
##  <A>lev</A>);</C> to set the desired severity level <A>lev</A>.
##  This can for example be done in your <F>gap.ini</F> file,
##  see Section <Ref Subsect="subsect:gap.ini file"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DisplayPackageLoadingLog" );
BIND_GLOBAL( "PACKAGE_ERROR",   1 );
BIND_GLOBAL( "PACKAGE_WARNING", 2 );
BIND_GLOBAL( "PACKAGE_INFO",    3 );
BIND_GLOBAL( "PACKAGE_DEBUG",   4 );
DeclareGlobalFunction( "LogPackageLoadingMessage" );


#############################################################################
##
#F  IsPackageMarkedForLoading( <name>, <version> )
##
##  <#GAPDoc Label="IsPackageMarkedForLoading">
##  <ManSection>
##  <Func Name="IsPackageMarkedForLoading" Arg='name, version'/>
##
##  <Description>
##  This function can be used in the code of a package <M>A</M>
##  for testing whether the package <A>name</A> in version <A>version</A>
##  will be loaded after the <Ref Func="LoadPackage"/> call for the package
##  <M>A</M> has been executed.
##  This means that the package <A>name</A> had been loaded before,
##  or has been (directly or indirectly) requested as a needed or suggested
##  package of the package <M>A</M> or of a package whose loading
##  requested that <M>A</M> was loaded.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsPackageMarkedForLoading" );


#############################################################################
##
#F  DefaultPackageBannerString( <inforec> )
##
##  <ManSection>
##  <Func Name="DefaultPackageBannerString" Arg='inforec[, useShortBanner]'/>
##
##  <Description>
##  For a record <A>inforec</A> as stored in the <F>PackageInfo.g</F> file
##  of a &GAP; package,
##  this function returns a string denoting a banner for the package.
##  If the optional argument <A>useShortBanner</A> is set to <K>true</K>,
##  only the first line of the default banner (including the name, version and
##  description of the package) is returned.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "DefaultPackageBannerString" );


#############################################################################
##
#F  DirectoriesPackagePrograms( <name> )
##
##  <#GAPDoc Label="DirectoriesPackagePrograms">
##  <ManSection>
##  <Func Name="DirectoriesPackagePrograms" Arg='name'/>
##
##  <Description>
##  <Index Key="GAPInfo.Architecture"><C>GAPInfo.Architecture</C></Index>
##  returns a list that is either empty or contains one directory object
##  <C>dir</C> that describes the place where external binaries of the
##  &GAP; package <A>name</A> should be located.
##  <P/>
##  In the latter case,
##  <C>dir</C> is the <C>bin/</C><A>architecture</A> subdirectory of a
##  directory where the package <A>name</A> is installed,
##  where <A>architecture</A> is the architecture on which &GAP; has been
##  compiled (this can be accessed as <C>GAPInfo.Architecture</C>,
##  see <Ref Var="GAPInfo"/>),
##  and where the package directory belongs to the version of <A>name</A>
##  that is already loaded
##  or is currently going to be loaded
##  or would be the first version &GAP; would try to load if no other version
##  is explicitly prescribed.
##  (If the package <A>name</A> is not yet loaded then we cannot guarantee
##  that the directory belongs to a version that really can be loaded.)
##  <P/>
##  Note that <Ref Func="DirectoriesPackagePrograms"/> is likely to be called
##  in the <C>AvailabilityTest</C> function in the package's
##  <F>PackageInfo.g</F> file (see <Ref Sect="The PackageInfo.g File"/>).
##  <P/>
##  <Log><![CDATA[
##  gap> DirectoriesPackagePrograms( "nq" );
##  [ dir("/home/gap/4.0/pkg/nq/bin/x86_64-pc-linux-gnu-default64-kv3/") ]
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DirectoriesPackagePrograms" );


#############################################################################
##
#F  DirectoriesPackageLibrary( <name>[, <path>] )
##
##  <#GAPDoc Label="DirectoriesPackageLibrary">
##  <ManSection>
##  <Func Name="DirectoriesPackageLibrary" Arg='name[, path]'/>
##
##  <Description>
##  takes the string <A>name</A>, a name of a &GAP; package,
##  and returns a list that is either empty or contains one directory object
##  <C>dir</C> that describes the place where the library functions of
##  this &GAP; package should be located.
##  <P/>
##  In the latter case,
##  <C>dir</C> is the <A>path</A> subdirectory of a
##  directory where the package <A>name</A> is installed,
##  where the default for <A>path</A> is <C>"lib"</C>,
##  and where the package directory belongs to the version of <A>name</A>
##  that is already loaded
##  or is currently going to be loaded
##  or would be the first version &GAP; would try to load if no other version
##  is explicitly prescribed.
##  (If the package <A>name</A> is not yet loaded then we cannot guarantee
##  that the directory belongs to a version that really can be loaded.)
##  <P/>
##  Note that <Ref Func="DirectoriesPackageLibrary"/> is likely to be called
##  in the <C>AvailabilityTest</C> function in the package's
##  <F>PackageInfo.g</F> file (see <Ref Sect="The PackageInfo.g File"/>).
##  <P/>
##  As an example, the following returns a directory object for the library
##  functions of the &GAP; package <Package>Example</Package>:
##  <P/>
##  <Log><![CDATA[
##  gap> DirectoriesPackageLibrary( "Example", "gap" );
##  [ dir("/home/werner/gap/4.0/pkg/example/gap/") ]
##  ]]></Log>
##  <P/>
##  Observe that we needed the second argument <C>"gap"</C> here,
##  since <Package>Example</Package>'s library functions are in the
##  subdirectory <F>gap</F> rather than <F>lib</F>.
##  <P/>
##  In order to find a subdirectory deeper than one level in a package
##  directory, the second argument is again necessary whether or not the
##  desired subdirectory relative to the package's directory begins with
##  <F>lib</F>.
##  The directories in <A>path</A> should be separated by <C>/</C> (even on
##  systems, like Windows, which use <C>\</C> as the directory separator).
##  For example, suppose there is a package <C>somepackage</C> with a
##  subdirectory <F>m11</F> in the directory <F>data</F>,
##  then we might expect the following:
##  <P/>
##  <Log><![CDATA[
##  gap> DirectoriesPackageLibrary( "somepackage", "data/m11" );
##  [ dir("/home/werner/gap/4.0/pkg/somepackage/data/m11") ]
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DirectoriesPackageLibrary" );


#############################################################################
##
#F  ReadPackage( [<name>, ]<file> )
#F  RereadPackage( [<name>, ]<file> )
##
##  <#GAPDoc Label="ReadPackage">
##  <ManSection>
##  <Func Name="ReadPackage" Arg='[name, ]file'/>
##  <Func Name="RereadPackage" Arg='[name, ]file'/>
##
##  <Description>
##  Called with two strings <A>name</A> and <A>file</A>,
##  <Ref Func="ReadPackage"/> reads the file <A>file</A>
##  of the &GAP; package <A>name</A>,
##  where <A>file</A> is given as a path relative to the home directory
##  of <A>name</A>. Note that <A>file</A> is read in the namespace
##  of the package, see Section <Ref Sect="Namespaces"/> for details.
##  <P/>
##  If only one argument <A>file</A> is given,
##  this should be the path of a file relative to the <F>pkg</F> subdirectory
##  of &GAP; root paths (see&nbsp;<Ref Sect="GAP Root Directories"/>).
##  Note that in this case, the package name is assumed to be equal to the
##  first part of <A>file</A>,
##  <E>so the one argument form is not recommended</E>.
##  <P/>
##  The absolute path is determined as follows.
##  If the package in question has already been loaded then the file in the
##  directory of the loaded version is read.
##  If the package is available but not yet loaded then the directory given
##  by <Ref Func="TestPackageAvailability"/> is used, without
##  prescribed version number.
##  (Note that the <Ref Func="ReadPackage"/> call does <E>not</E> force the
##  package to be loaded.)
##  <P/>
##  If the file is readable then <K>true</K> is returned,
##  otherwise a warning is displayed (for <Ref Func="ReadPackage"/>)
##  or <K>false</K> is returned (for <Ref Func="RereadPackage"/>).
##  <P/>
##  Each of <A>name</A> and <A>file</A> should be a string.
##  The <A>name</A> argument is case insensitive.
##  <P/>
##  <Ref Func="RereadPackage"/> does the same as <Ref Func="ReadPackage"/>,
##  except that also read-only global variables are overwritten
##  (cf.&nbsp;<Ref Func="Reread"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ReadPackage" );

DeclareGlobalFunction( "RereadPackage" );


#############################################################################
##
#F  LoadPackageDocumentation( <info> )
##
##  <ManSection>
##  <Func Name="LoadPackageDocumentation" Arg='info'/>
##
##  <Description>
##  Let <A>info</A> be a record as defined in the <F>PackageInfo.g</F> file
##  of a package.
##  <Ref Func="LoadPackageDocumentation"/> loads all books of the
##  documentation for this package.
##  <P/>
##  Note that this function might run twice for a package, first in the
##  autoloading process (where the package itself is not necessarily loaded)
##  and later when the package gets loaded.
##  In this situation, the names used by the help viewer differ before and
##  after the true loading.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "LoadPackageDocumentation" );


#############################################################################
##
#F  LoadPackage( <name>[, <version>][, <banner>] )
##
##  <#GAPDoc Label="LoadPackage">
##  <ManSection>
##  <Func Name="LoadPackage" Arg='name[, version][, banner]'/>
##
##  <Description>
##  loads the &GAP; package with name <A>name</A>.
##  <P/>
##  As an example, the following loads the &GAP; package
##  <Package>SONATA</Package> (case insensitive) which provides methods for the
##  construction and analysis of finite nearrings:
##  <P/>
##  <Log><![CDATA[
##  gap> LoadPackage("sonata");
##  ... some more lines with package banner(s) ...
##  true
##  ]]></Log>
##  <P/>
##  The package name is case insensitive and may be appropriately abbreviated.
##  At the time of writing, for example, <C>LoadPackage("semi");</C>
##  will load the <Package>Semigroups</Package> package, and
##  <C>LoadPackage("js");</C> will load the <Package>json</Package> package.
##  If the abbreviation cannot be uniquely completed,
##  a list of available completions will be offered,
##  and <Ref Func="LoadPackage"/> returns <K>fail</K>.
##  Thus the names of <E>all</E> installed packages can be shown by calling
##  <C>LoadPackage("");</C>.
##  <P/>
##  When the optional argument string <A>version</A> is present,
##  the package will only be loaded in a version number
##  equal to or greater than <A>version</A>
##  (see&nbsp;<Ref Func="CompareVersionNumbers"/>).
##  If the first character of <A>version</A> is <C>=</C>
##  then only that version will be loaded.
##  <P/>
##  <Ref Func="LoadPackage"/> will return <K>true</K> if the package has been
##  successfully loaded,
##  and will return <K>fail</K> if the package could not be loaded.
##  The latter may be the case if the package is not installed, if necessary
##  binaries have not been compiled, or if the version number of the
##  available version is too small.
##  If the package cannot be loaded, <Ref Func="TestPackageAvailability"/>
##  can be used to find the reasons. Also,
##  <Ref Func="DisplayPackageLoadingLog"/> can be used to find out more
##  about the failure. To see the problems directly, one can
##  change the verbosity using the user preference
##  <C>InfoPackageLoadingLevel</C>, see <Ref InfoClass="InfoPackageLoading"/>
##  for details.
##  <P/>
##  If the package <A>name</A> has already been loaded in a version number
##  equal to or greater than <A>version</A>,  <Ref Func="LoadPackage"/>
##  returns <K>true</K> without doing anything else.
##  <P/>
##  If the optional argument <A>banner</A> is present then it must be either
##  <K>true</K> or <K>false</K>;
##  in the latter case, the effect is that no package banner is printed.
##  <P/>
##  After a package has been loaded, all its code becomes
##  available to use with the rest of the &GAP; library.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "LoadPackage" );

##  <#GAPDoc Label="LoadPackageAutomatic">
##  <Subsection Label="LoadPackageAutomatic">
##  <Heading>Automatic loading of &GAP; packages</Heading>
##  When &GAP; is started some packages are loaded automatically,
##  and these belong to two categories.
##  The first are those packages which are needed to start &GAP;
##  (at the present time, the only such package is &GAPDoc;).
##  Their list is contained in
##  <C>GAPInfo.Dependencies.NeededOtherPackages</C>.
##  The second are packages which are loaded during &GAP; startup by default.
##  The latter list may be obtained by calling
##  <C>UserPreference("PackagesToLoad")</C> and is customisable as described
##  in Section <Ref BookName="ref" Sect="Configuring User preferences"/>.
##  <P/>
##  While &GAP; will not start if any of the packages from the former group
##  is missing, loading of the packages from the latter group may be
##  suppressed by using the <C>-A</C> command line option
##  (see <Ref Sect="Command Line Options" />).
##  <P/>
##  If for some reason you don't want certain packages to be automatically
##  loaded, &GAP; provides three levels for disabling autoloading.
##  <P/>
##  <Index Key="NOAUTO"><C>NOAUTO</C></Index>
##  The autoloading of specific packages can be overwritten <E>for the whole
##  &GAP; installation</E> by putting a file <F>NOAUTO</F> into a <F>pkg</F>
##  directory that contains lines with the names of packages which should
##  not be automatically loaded.
##  <P/>
##  Furthermore, <E>individual users</E> can disable the autoloading of
##  specific packages by putting the names of these packages into the list
##  that is assigned to the user preference <Q>ExcludeFromAutoload</Q>,
##  for example in the user's <F>gap.ini</F> file
##  (see&nbsp;<Ref Subsect="subsect:gap.ini file"/>).
##  <P/>
##  Using the <C>-A</C> command line option when starting &GAP;
##  (see&nbsp;<Ref Sect="Command Line Options"/>),
##  automatic loading of packages is switched off
##  <E>for this &GAP; session</E>.
##  <P/>
##  In any of the above three cases, the packages listed in
##  <C>GAPInfo.Dependencies.NeededOtherPackages</C> are still loaded
##  automatically, and an error is signalled if any of these packages
##  is unavailable.
##  <P/>
##  See <Ref Func="SetPackagePath"/> for a way to force the loading of a
##  prescribed package version.
##  See also <Ref Func="ExtendRootDirectories"/> for a method of adding
##  directories containing packages <E>after</E> &GAP; has been started.
##  </Subsection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  LoadAllPackages()
##
##  <ManSection>
##  <Func Name="LoadAllPackages" Arg=''/>
##
##  <Description>
##  loads all installed packages that can be loaded, in alphabetical order.
##  This admittedly trivial function is used for example in automatic tests.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "LoadAllPackages" );


#############################################################################
##
#F  SetPackagePath( <pkgname>, <pkgpath> )
##
##  <#GAPDoc Label="SetPackagePath">
##  <ManSection>
##  <Func Name="SetPackagePath" Arg='pkgname, pkgpath'/>
##
##  <Description>
##  This function can be used to force &GAP; to load a particular version of
##  a package, even though newer versions of the package are available.
##  <P/>
##  Let <A>pkgname</A> and <A>pkgpath</A> be strings denoting the name of a
##  &GAP; package and the path to a directory where a version of this package
##  can be found (i.&nbsp;e., calling <Ref Oper="Directory"/> with the
##  argument <A>pkgpath</A> will yield a directory that contains the file
##  <F>PackageInfo.g</F> of the package).
##  <P/>
##  If the package <A>pkgname</A> is already loaded with an installation path
##  different from <A>pkgpath</A> then <Ref Func="SetPackagePath"/> signals
##  an error.
##  If the package <A>pkgname</A> is not yet loaded then
##  <Ref Func="SetPackagePath"/> erases the information about available
##  versions of the package <A>pkgname</A>, and stores the record that is
##  contained in the <F>PackageInfo.g</F> file at <A>pkgpath</A> instead,
##  such that only the version installed at <A>pkgpath</A> can be loaded
##  with <Ref Func="LoadPackage"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SetPackagePath" );


#############################################################################
##
#F  ExtendRootDirectories( <paths> )
##
##  <#GAPDoc Label="ExtendRootDirectories">
##  <ManSection>
##  <Func Name="ExtendRootDirectories" Arg='paths'/>
##
##  <Description>
##  Let <A>paths</A> be a list of strings that denote paths to intended
##  &GAP; root directories (see <Ref Sect="GAP Root Directories"/>).
##  The function <Ref Func="ExtendRootDirectories"/> adds these paths to
##  the global list <C>GAPInfo.RootPaths</C> and calls the initialization of
##  available &GAP; packages,
##  such that later calls to <Ref Func="LoadPackage"/> will find the &GAP;
##  packages that are contained in <F>pkg</F> subdirectories of the
##  directories given by <A>paths</A>.
##  <P/>
##  Note that the purpose of this function is to make &GAP; packages in the
##  given directories available.
##  It cannot be used to influence the start of &GAP;,
##  because the &GAP; library is loaded before
##  <Ref Func="ExtendRootDirectories"/> can be called
##  (and because <C>GAPInfo.RootPaths</C> is not used for reading the
##  &GAP; library).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ExtendRootDirectories" );

#############################################################################
##
#F  InstalledPackageVersion( <name> )
##
##  <#GAPDoc Label="InstalledPackageVersion">
##  <ManSection>
##  <Func Name="InstalledPackageVersion" Arg='name'/>
##
##  <Description>
##  If the &GAP; package with name <A>name</A> has already been loaded then
##  <Ref Func="InstalledPackageVersion"/> returns the string denoting
##  the version number of this version of the package.
##  If the package is available but has not yet been loaded then the version
##  number string for that version of the package that currently would be
##  loaded.
##  (Note that loading <E>another</E> package might force loading
##  another version of the package <A>name</A>,
##  so the result of <Ref Func="InstalledPackageVersion"/> will be
##  different afterwards.)
##  If the package is not available then <K>fail</K> is returned.
##  <P/>
##  The argument <A>name</A> is case insensitive.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InstalledPackageVersion" );


#############################################################################
##
#F  AutoloadPackages()
##
##  <ManSection>
##  <Func Name="AutoloadPackages" Arg=''/>
##
##  <Description>
##  We ignore packages for which the user has disabled autoloading,
##  in particular we do not autoload their package documentation.
##  <P/>
##  For those packages which shall not be autoloaded but their documentation
##  shall be autoloaded,
##  this is done <E>without</E> checking the availability of the package;
##  so it might be that documentation is available for packages
##  that in fact cannot be loaded in the current &GAP; session.
##  <!-- note that we could run the tester function,
##  but this might cause <C>Print</C> statements saying that some package
##  cannot be loaded which at the moment shall not be loaded
##  - would this be better? -->
##  <P/>
##  First the packages in <C>GAPInfo.Dependencies.NeededOtherPackages</C> are
##  loaded, using <Ref Func="LoadPackage"/>.
##  If some needed packages are not loadable then an error is signalled.
##  Then those packages in the list <C>UserPreference( "PackagesToLoad" )</C>
##  are loaded (if they are available) that do not occur in the list
##  <C>UserPreference( "ExcludeFromAutoload" )</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AutoloadPackages" );


#############################################################################
##
#F  GAPDocManualLab(<pkgname>) . create manual.lab for package w/ GAPDoc docs
##
##  <ManSection>
##  <Func Name="GAPDocManualLab" Arg='pkgname'/>
##
##  <Description>
##  For a package <A>pkgname</A> with &GAPDoc; documentation,
##  <Ref Func="GAPDocManualLab"/> builds a <F>manual.lab</F> file from the
##  &GAPDoc;-produced <F>manual.six</F> file
##  so that the <F>gapmacro.tex</F>-compiled manuals can access
##  the labels of package <A>pkgname</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "GAPDocManualLabFromSixFile" );

DeclareGlobalFunction( "GAPDocManualLab" );


#############################################################################
##
#F  DeclareAutoreadableVariables( <pkgname>, <filename>, <varlist> )
##
##  <#GAPDoc Label="DeclareAutoreadableVariables">
##  <ManSection>
##  <Func Name="DeclareAutoreadableVariables"
##   Arg='pkgname, filename, varlist'/>
##
##  <Description>
##  Let <A>pkgname</A> be the name of a package,
##  let <A>filename</A> be the name of a file relative to the home directory
##  of this package,
##  and let <A>varlist</A> be a list of strings that are the names of global
##  variables which get bound when the file is read.
##  <Ref Func="DeclareAutoreadableVariables"/> notifies the names in
##  <A>varlist</A> such that the first attempt to access one of the variables
##  causes the file to be read.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DeclareAutoreadableVariables" );


#############################################################################
##
##  Tests whether loading a package works and does not obviously break
##  anything.
##  (This is very preliminary.)
##

#############################################################################
##
#F  ValidatePackageInfo( <info> )
##
##  <#GAPDoc Label="ValidatePackageInfo">
##  <ManSection>
##  <Func Name="ValidatePackageInfo" Arg='info'/>
##
##  <Description>
##  This function is intended to support package authors who create or
##  modify <F>PackageInfo.g</F> files.
##  (It is <E>not</E> called when these files are read during the startup of
##  &GAP; or when packages are actually loaded.)
##  <P/>
##  The argument <A>info</A> must be either a record as is contained in a
##  <F>PackageInfo.g</F> file
##  or a string which describes the path to such a file.
##  The result is <K>true</K> if the record or the contents of the file,
##  respectively, has correct format, and <K>false</K> otherwise;
##  in the latter case information about the incorrect components is printed.
##  These diagnostic messages can be suppressed by setting the global option
##  <C>quiet</C> to <K>true</K>.
##  <P/>
##  Note that the components used for package loading are checked as well as
##  the components that are needed for composing the package overview web
##  page or for updating the package archives.
##  <P/>
##  If <A>info</A> is a string then <Ref Func="ValidatePackageInfo"/> checks
##  additionally whether those package files exist that are mentioned in the
##  file <F>info</F>, for example the <F>manual.six</F> file of the package
##  documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
#T  Add an argument that distinguishes components needed for loading the
#T  package and those needed only for submitted packages?
##
DeclareGlobalFunction( "ValidatePackageInfo" );


#############################################################################
##
#F  SuggestUpgrades( <versions> )  compare installed vs. distributed versions
##
##  <ManSection>
##  <Func Name="SuggestUpgrades" Arg='versions'/>
##
##  <Description>
##  <A>versions</A> must be a list of pairs such as
##  <C>[ [ "GAPKernel", "4.4.0" ], [ "GAPLibrary", "4.4.0" ],
##       [ "AtlasRep", "1.2" ], ...
##     ]</C>
##  where the second arguments are version numbers from the current official
##  distribution.
##  The function compares this with the available Kernel, Library, and
##  Package versions and prints some text summarizing the result.
##  <P/>
##  On the &GAP; website, under <Q>Download</Q>/<Q>Upgrade/Bugfixes</Q>,
##  a call of the function <Ref Func="SuggestUpgrades"/> appears for
##  <Q>cut-and-paste</Q> purposes.
##  <P/>
##  For 4.4 not yet documented, we should think about improvements first.
##  (e.g., how to download the necessary information in the background)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SuggestUpgrades" );


#############################################################################
##
#F  BibEntry( "GAP"[, <key>] )
#F  BibEntry( <pkgname>[, <key>] )
#F  BibEntry( <pkginfo>[, <key>] )
##
##  <#GAPDoc Label="BibEntry">
##  <ManSection>
##  <Func Name="BibEntry" Arg='pkgname[, key]'/>
##
##  <Returns>
##  a string in BibXMLext format
##  (see <Ref Sect="The BibXMLext Format" BookName="gapdoc"/>)
##  that can be used for referencing the &GAP; system or a &GAP; package.
##  </Returns>
##
##  <Description>
##  If the argument <A>pkgname</A> is the string <C>"GAP"</C>,
##  the function returns an entry for the current version of &GAP;.
##  <P/>
##  Otherwise, if a string <A>pkgname</A> is given, which is the name of a
##  &GAP; package, an entry for this package is returned;
##  this entry is computed from the <F>PackageInfo.g</F> file of
##  <E>the current version</E> of the package,
##  see <Ref Func="InstalledPackageVersion"/>.
##  If no package with name <A>pkgname</A> is installed then the empty string
##  is returned.
##  <P/>
##  A string for <E>a different version</E> of &GAP; or a package
##  can be computed by entering, as the argument <A>pkgname</A>,
##  the desired record from the <F>PackageInfo.g</F> file.
##  (One can access these records using the function <C>PackageInfo</C>.)
##  <P/>
##  In each of the above cases, an optional argument <A>key</A> can be
##  given, a string which is then used as the key of the Bib&TeX; entry
##  instead of the default key that is generated from the system/package name
##  and the version number.
##  <P/>
##  <Ref Func="BibEntry"/> requires the functions
##  <Ref Func="FormatParagraph" BookName="gapdoc"/> and
##  <Ref Func="NormalizedNameAndKey" BookName="gapdoc"/>
##  from the &GAP; package &GAPDoc;.
##  <P/>
##  The functions <Ref Func="ParseBibXMLextString" BookName="gapdoc"/>
##  and <Ref Func="StringBibXMLEntry" BookName="gapdoc"/>
##  can be used to create for example a Bib&TeX; entry from the return value,
##  as follows.
##  <P/>
##  <Log><![CDATA[
##  gap> bib:= BibEntry( "GAP", "GAP4.5" );;
##  gap> Print( bib, "\n" );
##  <entry id="GAP4.5"><misc>
##    <title><C>GAP</C> &ndash; <C>G</C>roups, <C>A</C>lgorithms,
##           and <C>P</C>rogramming, <C>V</C>ersion 4.5.1</title>
##    <howpublished><URL>https://www.gap-system.org</URL></howpublished>
##    <key>GAP</key>
##    <keywords>groups; *; gap; manual</keywords>
##    <other type="organization">The GAP <C>G</C>roup</other>
##  </misc></entry>
##  gap> parse:= ParseBibXMLextString( bib );;
##  gap> Print( StringBibXMLEntry( parse.entries[1], "BibTeX" ) );
##  @misc{ GAP4.5,
##    title =            {{GAP}   {\textendash}   {G}roups,   {A}lgorithms,  and
##                        {P}rogramming, {V}ersion 4.5.1},
##    organization =     {The GAP {G}roup},
##    howpublished =     {\href                      {https://www.gap-system.org}
##                        {\texttt{https://www.gap-system.org}}},
##    key =              {GAP},
##    keywords =         {groups; *; gap; manual}
##  }
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BibEntry" );


#############################################################################
##
#F  Cite()
##
##  <#GAPDoc Label="Cite">
##  <ManSection>
##  <Func Name="Cite" Arg='[pkgname[, key]]'/>
##
##  <Description>
##  Used with no arguments or with argument <C>"GAP"</C> (case-insensitive),
##  <Ref Func="Cite"/> displays instructions on citing the version of &GAP;
##  that is being used. Suggestions are given in plain text, HTML, BibXML
##  and BibTeX formats. The same instructions are also contained in the
##  <F>CITATION</F> file in the &GAP; root directory.
##  <P/>
##  If <A>pkgname</A> is the name of a &GAP; package, instructions on
##  citing this package will be displayed. They will be produced from the
##  <F>PackageInfo.g</F> file of the working version of this package that
##  must be available in the &GAP; installation being used. Otherwise, one
##  will get a warning that no working version of the package is available.
##  <P/>
##  The optional 2nd argument <A>key</A> has the same meaning as in
##  <Ref Func="BibEntry"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Cite" );


#############################################################################
##
#F  ShowPackageVariables( <pkgname>[, <version>][, <arec>] )
#F  PackageVariablesInfo( <pkgname>, <version> )
##
##  <#GAPDoc Label="ShowPackageVariables">
##  <ManSection>
##  <Func Name="ShowPackageVariables" Arg='pkgname[, version][, arec]'/>
##  <Func Name="PackageVariablesInfo" Arg='pkgname, version'/>
##
##  <Description>
##  Let <A>pkgname</A> be the name of a &GAP; package.
##  If the package <A>pkgname</A> is available but not yet loaded then
##  <Ref Func="ShowPackageVariables"/> prints a list of global variables
##  that become bound and of methods that become installed
##  when the package is loaded.
##  (For that, &GAP; actually loads the package.)
##  <P/>
##  If a version number <A>version</A> is given
##  (see Section&nbsp;<Ref Sect="Version Numbers" BookName="ref"/>)
##  then this version of the package is considered.
##  <P/>
##  An error message is printed if (the given version of) the package
##  is not available or already loaded.
##  <P/>
##  Information is printed about new and redeclared global variables,
##  and about names of global variables introduced in the package
##  that differ from existing globals only by case;
##  note that the &GAP; help system is case insensitive,
##  so it is difficult to document identifiers that differ only by case.
##  <P/>
##  Info lines for undocumented variables are marked with an asterisk
##  <C>*</C>.
##  <P/>
##  The following entries are omitted from the list:
##  default setter methods for attributes and properties that are declared
##  in the package,
##  and <C>Set<A>attr</A></C> and <C>Has<A>attr</A></C> type variables
##  where <A>attr</A> is an attribute or property.
##  <P/>
##  The output can be customized using the optional record <A>arec</A>,
##  the following components of this record are supported.
##  <List>
##  <Mark><C>show</C></Mark>
##  <Item>
##    a list of strings describing those kinds of variables which shall be
##    shown, such as <C>"new global functions"</C>;
##    the default are all kinds that appear in the package,
##  </Item>
##  <Mark><C>showDocumented</C></Mark>
##  <Item>
##    <K>true</K> (the default) if documented variables shall be shown,
##    and <K>false</K> otherwise,
##  </Item>
##  <Mark><C>showUndocumented</C></Mark>
##  <Item>
##    <K>true</K> (the default) if undocumented variables shall be shown,
##    and <K>false</K> otherwise,
##  </Item>
##  <Mark><C>showPrivate</C></Mark>
##  <Item>
##    <K>true</K> (the default) if variables from the package's name space
##    (see Section <Ref Sect="Namespaces"/>) shall be shown,
##    and <K>false</K> otherwise,
##  </Item>
##  <Mark><C>Display</C></Mark>
##  <Item>
##    a function that takes a string and shows it on the screen;
##    the default is <Ref Func="Print"/>,
##    another useful value is <Ref Func="Pager"/>.
##  </Item>
##  </List>
##  <P/>
##  An interactive variant of <Ref Func="ShowPackageVariables"/> is the
##  function <Ref Func="BrowsePackageVariables" BookName="browse"/> that is
##  provided by the &GAP; package <Package>Browse</Package>.
##  For this function, it is not sensible to assume that the package
##  <A>pkgname</A> is not yet loaded before the function call,
##  because one might be interested in packages that must be loaded before
##  <Package>Browse</Package> itself can be loaded.
##  The solution is that
##  <Ref Func="BrowsePackageVariables" BookName="browse"/> takes the output
##  of <Ref Func="PackageVariablesInfo"/> as its second argument.
##  The function <Ref Func="PackageVariablesInfo"/> is used by both
##  <Ref Func="ShowPackageVariables"/> and
##  <Ref Func="BrowsePackageVariables" BookName="browse"/> for collecting the
##  information about the package in question, and can be called before the
##  package <Package>Browse</Package> is loaded.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ShowPackageVariables" );

DeclareGlobalFunction( "PackageVariablesInfo" );
