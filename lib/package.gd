#############################################################################
##
#W  package.gd                  GAP Library                      Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id: package.gd,v 4.3 2009/08/12 12:04:34 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains support for &GAP; packages.
##
##  The following global variables are used for package loading
##  (see `lib/system.g').
##  `GAPInfo.PackagesLoaded',
##  `GAPInfo.PackagesInfo',
##  `GAPInfo.PackagesInfoAutoload',
##  `GAPInfo.PackagesInfoAutoloadDocumentation',
##  `GAPInfo.PackagesInfoInitialized',
##  `GAPInfo.PackagesNames',
##  `GAPInfo.PackagesRestrictions', and
##  `GAPInfo.PackageInfoCurrent'.
##
#T TODO:
#T - document the utilities `SuggestUpgrades', `CheckPackageLoading',
#T   `ShowPackageVariables', `LoadAllPackages', `ValidatePackageInfo'.
##
Revision.package_gd :=
    "@(#)$Id: package.gd,v 4.3 2009/08/12 12:04:34 gap Exp $";

#T remove this as soon as possible (currently used in several packages)
PACKAGES_VERSIONS:= rec();


#############################################################################
##
#F  CompareVersionNumbers( <supplied>, <required>[, "equal"] )
##
##  <#GAPDoc Label="CompareVersionNumbers">
##  <ManSection>
##  <Func Name="CompareVersionNumbers" Arg='supplied, required[, "equal"]'/>
##
##  <Description>
##  compares two version numbers, given as strings.
##  They are split at non-digit characters,
##  the resulting integer lists are compared lexicographically.
##  The routine tests whether <A>supplied</A> is at least as large as
##  <A>required</A>, and returns <K>true</K> or <K>false</K> accordingly.
##  A version number ending in <C>dev</C> is considered to be infinite.
##  See Section&nbsp;<Ref Sect="Version Numbers"/>
##  for details about version numbers.
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
##  Each <F>PackageInfo.g</F> file contains a call to <C>SetPackageInfo</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SetPackageInfo" );


#############################################################################
##
#F  InitializePackagesInfoRecords( <delay> )
##
##  <ManSection>
##  <Func Name="InitializePackagesInfoRecords" Arg='delay'/>
##
##  <Description>
##  If the argument <A>delay</A> is <K>true</K> then only a few
##  initializations are preformed;
##  this is used for delaying the initialization until the first call of
##  <Ref Func="TestPackageAvailability"/> (such that the information is
##  available in the first <Ref Func="LoadPackage"/> call)
##  if autoloading packages is switched off.
##  <P/>
##  If <A>delay</A> is <K>false</K> then all <F>PackageInfo.g</F> files
##  in all <F>pkg</F> subdirectories of &GAP; root directories are read,
##  the conditions in <C>GAPInfo.PackagesRestrictions</C> are checked,
##  and the lists of records are sorted according to descending package
##  version numbers.
##  <P/>
##  The function initializes three global records.
##  <List>
##  <Mark><C>GAPInfo.PackagesInfo</C></Mark>
##  <Item>
##       the record with the lists of info records of all existing packages;
##       they are looked up in all subdirectories of <F>pkg</F>
##       subdirectories of &GAP; root directories,
##  </Item>
##  <Mark><C>GAPInfo.PackagesInfoAutoload</C></Mark>
##  <Item>
##       the record with the lists of info records for all those existing
##       packages for which at least one version is to be autoloaded,
##       according to the exclusion list in the <F>NOAUTO</F> file
##       and to the package's <F>PackageInfo.g</F> file,
##  </Item>
##  <Mark><C>GAPInfo.PackagesInfoAutoloadDocumentation</C></Mark>
##  <Item>
##       the record with the lists of info records for all those existing
##       packages which are not scheduled for autoloading
##       but for which at least one version has autoloadable documentation,
##       according to its <F>PackageInfo.g</F> file.
##  </Item>
##  </List>
##  <P/>
##  <C>GAPInfo.PackagesNames</C> is set to the list of the names of those
##  packages that are marked in <C>GAPInfo.Dependencies</C> for being
##  automatically loaded.
##  This choice can be modified in the user's <F>.gaprc</F> file;
##  <Ref Func="LoadPackage"/> will be called automatically only for those
##  packages whose names occur in <C>GAPInfo.PackagesNames</C> <E>after</E>
##  the <F>.gaprc</F> file has been read.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InitializePackagesInfoRecords" );


#############################################################################
##
#F  TestPackageAvailability( <name>, <version>[, <intest>] )
##
##  <#GAPDoc Label="TestPackageAvailability">
##  <ManSection>
##  <Func Name="TestPackageAvailability" Arg='name, version[, intest]'/>
##
##  <Description>
##  For strings <A>name</A> and <A>version</A>, this function tests
##  whether the  &GAP; package <A>name</A> is available for loading in a
##  version that is at least <A>version</A>, or equal to <A>version</A>
##  if the first character of <A>version</A> is <C>=</C>,
##  see Section <Ref Sect="Version Numbers"/>
##  for details about version numbers.
##  <P/>
##  The result is <K>true</K> if the package is already loaded,
##  <K>fail</K> if it is not available,
##  and the string denoting the &GAP; root path where the package resides
##  if it is available, but not yet loaded.
##  A test function (the value of the component <C>AvailabilityTest</C>
##  in the <F>PackageInfo.g</F> file of the package) should therefore test
##  for the result of <Ref Func="TestPackageAvailability"/> being not equal
##  to <K>fail</K>.
##  <P/>
##  The argument <A>name</A> is case insensitive.
##  <P/>
##  The optional argument <A>intest</A> is a list of pairs
##  <C>[ <A>pkgnam</A>, <A>pkgversion</A> ]</C> such that the function
##  has been called with these arguments on outer levels.
##  (Note that several packages may require each other, with different
##  required versions.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TestPackageAvailability" );


#############################################################################
##
#V  PACKAGE_ERROR
#V  PACKAGE_WARNING
#V  PACKAGE_INFO
#V  PACKAGE_DEBUG
##
##  ...
##
BIND_GLOBAL( "PACKAGE_ERROR",   1 );
BIND_GLOBAL( "PACKAGE_WARNING", 2 );
BIND_GLOBAL( "PACKAGE_INFO",    3 );
BIND_GLOBAL( "PACKAGE_DEBUG",   4 );


#############################################################################
##
#F  LogPackageLoadingMessage( <severity>, <message> )
##
##  ...
##
DeclareGlobalFunction( "LogPackageLoadingMessage" );


#############################################################################
##
#F  DisplayPackageLoadingLog( [<severity>] )
##
##  ...
##
DeclareGlobalFunction( "DisplayPackageLoadingLog" );


#############################################################################
##
#F  IsPackageMarkedForLoading( <name>, <version> )
##
##  This function can be used in the code of the implementation part of a
##  package <M>A</M>,
##  for testing whether the package <name> in version <version> will be
##  available after the <Ref Func="LoadPackage"/> call for the package
##  <M>A</M> has been executed.
##  This means that the package <A>name</A> had been available before,
##  or has been (directly or indirectly requested as a needed or suggested
##  package of the package <M>A</M> or of a package whose loading
##  requested that <M>A</M> was loaded.
##
DeclareGlobalFunction( "IsPackageMarkedForLoading" );


#############################################################################
##
#F  DefaultPackageBannerString( <inforec> )
##
##  <ManSection>
##  <Func Name="DefaultPackageBannerString" Arg='inforec'/>
##
##  <Description>
##  For a record <A>inforec</A> as stored in the <F>PackageInfo.g</F> file
##  of a &GAP; package,
##  this function returns a string denoting a banner for the package.
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
##  returns a list of the <C>bin/<A>architecture</A></C> subdirectories
##  of all packages <A>name</A> where <A>architecture</A> is the architecture
##  on which &GAP;
##  <!-- As soon as <C>GAPInfo</C> is documented, add a cross-reference to it here!-->
##  has been compiled and the version of the installed package coincides with
##  the version of the package <A>name</A> that either is already loaded
##  or that would be the first version &GAP; would try to load
##  (if no other version is explicitly prescribed).
##  <P/>
##  Note that <Ref Func="DirectoriesPackagePrograms"/> is likely to be called
##  in the <C>AvailabilityTest</C> function in the package's
##  <F>PackageInfo.g</F> file, so we cannot guarantee that the returned
##  directories belong to a version that really can be loaded.
##  <P/>
##  The directories returned by <Ref Func="DirectoriesPackagePrograms"/>
##  are the place where external binaries of the &GAP; package <A>name</A>
##  for the current package version and the current architecture
##  should be located.
##  <P/>
##  <Log><![CDATA[
##  gap> DirectoriesPackagePrograms( "nq" );
##  [ dir("/home/werner/gap/4.0/pkg/nq/bin/i686-unknown-linux2.0.30-gcc/") ]
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
##  and returns a list of directory objects for those sub-directory/ies
##  containing the library functions of this &GAP; package,
##  for the version that is already loaded or would be loaded if no other
##  version is explicitly prescribed,
##  up to one directory for each <F>pkg</F> sub-directory of a path in
##  <C>GAPInfo.RootPaths</C>.
##  <!-- As soon as <C>GAPInfo</C> is documented, add a cross-reference to it here!-->
##  The default is that the library functions are in the subdirectory <F>lib</F>
##  of the &GAP; package's home directory.
##  If this is not the case, then the second argument <A>path</A> needs to be
##  present and must be a string that is a path name relative to the home
##  directory  of the &GAP; package with name <A>name</A>.
##  <P/>
##  Note that <Ref Func="DirectoriesPackageLibrary"/> may be called in the
##  <C>AvailabilityTest</C> function in the package's <F>PackageInfo.g</F>
##  file,
##  so we cannot guarantee that the returned directories belong to a version
##  that really can be loaded.
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
##  of <A>name</A>.
##  <P/>
##  If only one argument <A>file</A> is given,
##  this should be the path of a file relative to the <F>pkg</F> subdirectory
##  of &GAP; root paths (see&nbsp;<Ref Sect="GAP Root Directory"/>).
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
##  otherwise <K>false</K>.
##  <P/>
##  Each of <A>name</A>, <A>file</A> and <A>pkg-file</A> should be a string.
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
#F  LoadPackageDocumentation( <info>, <all> )
##
##  <ManSection>
##  <Func Name="LoadPackageDocumentation" Arg='info, all'/>
##
##  <Description>
##  Let <A>info</A> be a record as defined in the <F>PackageInfo.g</F> file
##  of a package.
##  <Ref Func="LoadPackageDocumentation"/> loads books of the documentation
##  for this package.
##  If <A>all</A> is <K>true</K> then <E>all</E> books are loaded,
##  otherwise only the <E>autoloadable</E> books are loaded.
##  <P/>
##  Note that this function might run twice for a package, first in the
##  autoloading process (where the package itself is not necessarily loaded)
##  and later when the package is loaded.
##  In this situation, the names used by the help viewer differ before and
##  after the true loading.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "LoadPackageDocumentation" );


#############################################################################
##
#F  LoadPackage( <name>[, <version>[, <banner>[, <outercalls>]]] )
##
##  <#GAPDoc Label="LoadPackage">
##  <ManSection>
##  <Func Name="LoadPackage" Arg='name[, version[, banner[, outercalls]]]'/>
##
##  <Description>
##  loads the &GAP; package with name <A>name</A>.
##  If the optional version string <A>version</A> is given,
##  the package will only be loaded in a version number at least as large as
##  <A>version</A>,
##  or equal to <A>version</A> if its first character is <C>=</C>
##  (see&nbsp;<Ref Sect="Version Numbers"/>).
##  The argument <A>name</A> is case insensitive.
##  <P/>
##  <Ref Func="LoadPackage"/> will return <K>true</K> if the package has been
##  successfully loaded
##  and will return <K>fail</K> if the package could not be loaded.
##  The latter may be the case if the package is not installed, if necessary
##  binaries have not been compiled, or if the version number of the
##  available version is too small.
##  <P/>
##  If the package <A>name</A> has already been loaded in a version number
##  at least or equal to <A>version</A>, respectively,
##  <Ref Func="LoadPackage"/> returns <K>true</K> without doing anything
##  else.
##  <P/>
##  If the optional third argument <A>banner</A> is <K>false</K>
##  then no package banner is printed.
##  The fourth argument <A>outercalls</A> is used only for recursive calls of
##  <Ref Func="LoadPackage"/>,
##  when the loading process for a package triggers the loading of other
##  packages.
##  <P/>
##  After a package has been loaded its code and documentation should be
##  available as other parts of the &GAP; library are.
##  <P/>
##  When &GAP; is started then some packages are loaded automatically.
##  These are the packages listed in the <C>NeededOtherPackages</C> and
##  (if this is not disabled, see below) <C>SuggestedOtherPackages</C>
##  components of the record <C>GAPInfo.Dependencies</C>.
##  <P/>
##  &GAP; prints the list of names of all &GAP; packages which have been
##  loaded (either by automatic
##  loading or via <Ref Func="LoadPackage"/> commands in one's <F>.gaprc</F>
##  file or the like) at the end of the initialization process.
##  <P/>
##  A &GAP; package may also install only its documentation automatically
##  but still need loading by <Ref Func="LoadPackage"/>.
##  In this situation the online
##  help displays <C>(not loaded)</C> in the header lines of the manual
##  pages belonging to this &GAP; package.
##  <P/>
##  If for some reason you don't want certain packages to be automatically
##  loaded, &GAP; provides three levels for disabling autoloading:
##  <P/>
##  <Index Key="NOAUTO"><C>NOAUTO</C></Index>
##  The autoloading of specific packages can be overwritten <E>for the whole
##  &GAP; installation</E> by putting a file <F>NOAUTO</F> into a <F>pkg</F>
##  directory that contains lines with the names of packages which should
##  not be automatically loaded.
##  <P/>
##  Furthermore, <E>individual users</E> can disable the autoloading of
##  specific packages by using the following command in their <F>.gaprc</F>
##  file (see&nbsp;<Ref Sect="The .gaprc file"/>).
##  <P/>
##  <C>ExcludeFromAutoload( <A>pkgnames</A> );</C>
##  <P/>
##  where <A>pkgnames</A> is the list of names of the &GAP; packages in
##  question.
##  <P/>
##  Using the <C>-A</C> command line option when starting up &GAP;
##  (see&nbsp;<Ref Sect="Command Line Options"/>),
##  automatic loading is switched off <E>for this &GAP; session</E>,
##  and the scanning of the <F>pkg</F> directories containing the installed
##  packages is delayed until the first call of <Ref Func="LoadPackage"/>.
##  <P/>
##  In any of the above three cases, the packages listed in
##  <C>GAPInfo.Dependencies.NeededOtherPackages</C> are still loaded
##  automatically, and an error is signalled if not all of these packages
##  are available.
##  <P/>
##  The global option <C>OnlyNeeded</C> (see <Ref Chap="Options Stack"/>)
##  can be used to suppress loading the suggested packages of the package
##  in question.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#T document the ordering in which dependent read.g files are read!
##
DeclareGlobalFunction( "LoadPackage" );

RequirePackage:= LoadPackage;
#T to be removed as soon as `init.g' files in old format have disappeared


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
##  Only the packages in the list <C>GAPInfo.PackagesNames</C> are considered
##  for autoloading.
##  Note that we ignore packages for which the user has disabled autoloading,
##  in particular we do not autoload their package documentation.
##  <P/>
##  For those packages which shall not be autoloaded but their documentation
##  shall be autoloaded,
##  this is done <E>without</E> checking the availability of the package;
##  so it might be that documentation is available for packages
##  that in fact cannot be loaded in the current &GAP; session.
##  <!-- note that we could run the tester function, but this might cause <C>Print</C>-->
##  <!-- statements saying that some package cannot be loaded which at the moment-->
##  <!-- shall not be loaded - would this be better?-->
##  <P/>
##  It is assumed that <Ref Func="InitializePackagesInfoRecords"/> has set
##  the list <C>GAPInfo.PackagesNames</C> according to the needed and
##  suggested packages listed in <C>GAPInfo.Dependencies</C>.
##  <P/>
##  Then the user may have decided to exclude some packages from
##  <C>GAPInfo.PackagesNames</C>, using <Ref Func="ExcludeFromAutoload"/>.
##  <P/>
##  Then <Ref unc="AutoloadPackages"/> is called.
##  First the packages in <C>GAPInfo.Dependencies.NeededOtherPackages</C> are
##  loaded, using <Ref Func="LoadPackage"/>.
##  If some needed packages are not mentioned in <C>GAPInfo.PackagesNames</C>
##  or are not loadable then an error is signalled.
##  Then those packages in <C>GAPInfo.Dependencies.SuggestedOtherPackages</C>
##  are loaded (if they are available) whose names are contained in
##  <C>GAPInfo.PackagesNames</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AutoloadPackages" );


#############################################################################
##
#F  ExcludeFromAutoload( <pkgname1>, <pkgname2>, ... )
##
##  <ManSection>
##  <Func Name="ExcludeFromAutoload" Arg='pkgname1, pkgname2, ...'/>
##
##  <Description>
##  This function is intended for disabling autoloading of those packages
##  whose names are given as arguments,
##  via a call in the user's <F>.gaprc</F> file.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ExcludeFromAutoload" );


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
##  <!-- This is used in the Ext manual -->
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
#F  ValidatePackageInfo( <record> )
#F  ValidatePackageInfo( <filename> )
##
##  <ManSection>
##  <Func Name="ValidatePackageInfo" Arg='record'/>
##  <Func Name="ValidatePackageInfo" Arg='filename'/>
##
##  <Description>
##  This function is intended to support package authors who create or
##  modify <F>PackageInfo.g</F> files.
##  (It is <E>not</E> called when these files are read during the startup of
##  &GAP; or when packages are actually loaded.)
##  <P/>
##  The argument must be either a record <A>record</A> as is contained in a
##  <F>PackageInfo.g</F> file or a a string <A>filename</A> which describes
##  the path to such a file.
##  The result is <K>true</K> if the record or the contents of the file,
##  respectively, has correct format, and <K>false</K> otherwise;
##  in the latter case information about the incorrect components is printed.
##  <P/>
##  Note that the components used for package loading are checked as well as
##  the components that are needed for composing the package overview Web
##  page or for updating the package archives.
##  <!-- Add an argument that distinguishes components needed for loading the-->
##  <!-- package and those needed only for submitted packages!-->
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ValidatePackageInfo" );


#############################################################################
##
#F  CheckPackageLoading( <pkgname> )
##
##  <ManSection>
##  <Func Name="CheckPackageLoading" Arg='pkgname'/>
##
##  <Description>
##  Start &GAP; with the command line option <C>-A</C>,
##  then call this function once.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CheckPackageLoading" );


#############################################################################
##
#F  SuggestUpgrades( versions ) . . compare installed with distributed versions
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
##  Package versions and print some text summarizing the result.
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
##  <ManSection>
##  <Func Name="BibEntry" Arg='"GAP"[, key]'/>
##  <Func Name="BibEntry" Arg='pkgname[, key]'/>
##  <Func Name="BibEntry" Arg='pkginfo[, key]'/>
##
##  <Description>
##  <Ref Func="BibEntry"/> returns a string representing a Bib&TeX; entry for
##  referencing the &GAP; system or a &GAP; package.
##  <P/>
##  When called with argument the string <C>"GAP"</C>,
##  the function returns an entry for the current version of &GAP;.
##  <P/>
##  When a string <A>pkgname</A> is given as an argument,
##  an entry for the &GAP; package with name <A>pkgname</A> is returned,
##  which is computed from the record at the first position in the list
##  returned by <Ref Func="PackageInfo"/> when this is called with the
##  argument <A>pkgname</A>;
##  if no package with name <A>pkgname</A> is loadable then the empty string
##  is returned.
##  An entry for a prescribed version of a package can be computed by
##  entering, as the argument <A>pkginfo</A>,
##  the desired record from the list returned by <Ref Func="PackageInfo"/>.
##  <P/>
##  In each of the above cases, an optional argument <A>key</A> can be
##  given, a string which is then used as the key of the Bib&TeX; entry
##  instead of the default key that is generated from the system/package name
##  and the version number;
##  the version number should be part of any key,
##  in order to be able to cite different versions of &GAP;
##  or of a &GAP; package.
##  <P/>
##  This function requires the functions
##  <Ref Func="FormatParagraph" BookName="gapdoc"/> and
##  <Ref Func="NormalizedNameAndKey"/> from the &GAP; package &GAPDoc;;
##  <K>fail</K> is returned if this package is not available.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "BibEntry" );


#############################################################################
##
#F  PackageVariablesInfo( <pkgname>[, <version>] )
##
##  <ManSection>
##  <Func Name="PackageVariablesInfo" Arg='pkgname[, version]'/>
##
##  <Description>
##  This is currently the function that does the work for
##  <Ref Func="ShowPackageVariables"/>.
##  In the future, better interfaces for such overviews are desirable,
##  so it makes sense to separate the computation of the data from the
##  actual rendering.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PackageVariablesInfo" );


#############################################################################
##
#F  ShowPackageVariables( <pkgname>[, <version>] )
##
##  <ManSection>
##  <Func Name="ShowPackageVariables" Arg='pkgname[, version]'/>
##
##  <Description>
##  Let <A>pkgname</A> be the name of a &GAP; package.
##  If the package <A>pkgname</A> is available but not yet loaded then
##  <C>ShowPackageVariables</C> prints a list of global variables that become
##  bound and of methods that become installed when the package is loaded.
##  (For that, the package is actually loaded,
##  so <Ref Func="ShowPackageVariables"/> can be called only once
##  for the same package in the same &GAP; session.)
##  <P/>
##  If a version number <A>version</A> is given
##  (see Section&nbsp;<Ref Sect="Version Numbers"/>)
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
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ShowPackageVariables" );


#############################################################################
##
#E

