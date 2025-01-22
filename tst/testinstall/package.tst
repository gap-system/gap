#@local entry,equ,pair,sml,oldTermEncoding,pkginfo,info,mockpkgpath,old_warning_level,p,n,filename,IsDateFormatValid,loadinfo,eval_loadinfo
gap> START_TEST("package.tst");

# CompareVersionNumbers( <supplied>, <required>[, \"equal\"] )
gap> sml:= [ [ "", "dev" ], [ "a", "1" ], [ "a", "b1c" ], [ "1", "2" ],
>      [ "a1b", "1c1" ], [ "1a2", "b2c1d" ], [ "a1b2c3", "d1e3" ],
>      [ "1a2b3", "c1d2e4f" ] ];;
gap> equ:= [ [ "a", "" ], [ "a1b", "1" ], [ "a1b2c", "1a2" ],
>      [ "a1b2c3d", "1a2b3" ] ];;
gap> for pair in sml do
>   if   CompareVersionNumbers( pair[1], pair[2] ) then
>     Error( "wrong result for ", pair );
>   elif not CompareVersionNumbers( pair[2], pair[1] ) then
>     Error( "wrong result for ", Reversed( pair ) );
>   elif CompareVersionNumbers( pair[1], pair[2], "equal" ) then
>     Error( "wrong result for ", pair, " and \"equal\"" );
>   elif CompareVersionNumbers( pair[2], pair[1], "equal" ) then
>     Error( "wrong result for ", Reversed( pair ), " and \"equal\"" );
>   fi;
> od;
gap> for pair in equ do
>   if   not CompareVersionNumbers( pair[1], pair[2] ) then
>     Error( "wrong result for ", pair );
>   elif not CompareVersionNumbers( pair[2], pair[1] ) then
>     Error( "wrong result for ", Reversed( pair ) );
>   elif not CompareVersionNumbers( pair[1], pair[2], "equal" ) then
>     Error( "wrong result for ", pair, " and \"equal\"" );
>   elif not CompareVersionNumbers( pair[2], pair[1], "equal" ) then
>     Error( "wrong result for ", Reversed( pair ), " and \"equal\"" );
>   fi;
> od;
gap> for entry in Set( Concatenation( Concatenation( [ sml, equ ] ) ) ) do
>   if   not CompareVersionNumbers( entry, entry ) then
>     Error( "wrong result for ", [ entry, entry ] );
>   elif not CompareVersionNumbers( entry, entry, "equal" ) then
>     Error( "wrong result for ", [ entry, entry ], " and \"equal\"" );
>   fi;
> od;
gap> ReadPackage("packagename");
Error, packagename is not a filename in the form 'package/filepath'

#
# Test the default package banner
#
gap> oldTermEncoding := GAPInfo.TermEncoding;;
gap> GAPInfo.TermEncoding := "ISO-8859-1";; # HACK

#
gap> Display(DefaultPackageBannerString(rec()));
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------


# 
gap> pkginfo := rec(
>         PackageName := "TestPkg",
>         Version := "1.0",
>         PackageWWWHome := "https://www.gap-system.org",
>         PackageDoc := [ rec( LongTitle := "A test package" ) ],
>         Persons := [ rec( IsAuthor := true,
>                           IsMaintainer := true,
>                           FirstNames := "Lord",
>                           LastName := "Vader",
>                           WWWHome := "https://www.gap-system.org/~darth"
>                           ) ]);;

# just one author & maintainer
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


# add a maintainer who is not an author
gap> Add(pkginfo.Persons, rec( IsAuthor := false, IsMaintainer := true,
>                           FirstNames := "Luke", LastName := "Skywalker",
>                           Email := "luke.skywalker@gap-system.org" ));
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth).
maintained by:
   Lord Vader (https://www.gap-system.org/~darth) and
   Luke Skywalker (luke.skywalker@gap-system.org).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


# add an author who is not a maintainer
gap> Add(pkginfo.Persons, rec( IsAuthor := true, IsMaintainer := false,
>                           FirstNames := "Leia", LastName := "Organa" ));
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth) and
   Leia Organa.
maintained by:
   Lord Vader (https://www.gap-system.org/~darth) and
   Luke Skywalker (luke.skywalker@gap-system.org).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


# add a contributor
gap> Add(pkginfo.Persons, rec( IsAuthor := false, IsMaintainer := false,
>                           FirstNames := "Yoda", LastName := "",
>                           WWWHome := "https://www.gap-system.org/~yoda"));
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth) and
   Leia Organa.
with contributions by:
   Yoda  (https://www.gap-system.org/~yoda).
maintained by:
   Lord Vader (https://www.gap-system.org/~darth) and
   Luke Skywalker (luke.skywalker@gap-system.org).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


# test what happens if all are authors and maintainers
gap> for p in pkginfo.Persons do p.IsAuthor:=true; p.IsMaintainer:=true; od;
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth),
   Luke Skywalker (luke.skywalker@gap-system.org),
   Leia Organa, and
   Yoda  (https://www.gap-system.org/~yoda).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


# test what happens if all are authors but not maintainers
gap> for p in pkginfo.Persons do p.IsAuthor:=true; p.IsMaintainer:=false; od;
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth),
   Luke Skywalker (luke.skywalker@gap-system.org),
   Leia Organa, and
   Yoda  (https://www.gap-system.org/~yoda).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


# test what happens if all are maintainers but not authors
gap> for p in pkginfo.Persons do p.IsAuthor:=false; p.IsMaintainer:=true; od;
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading TestPkg 1.0 (A test package)
maintained by:
   Lord Vader (https://www.gap-system.org/~darth),
   Luke Skywalker (luke.skywalker@gap-system.org),
   Leia Organa, and
   Yoda  (https://www.gap-system.org/~yoda).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


# test what happens if all are contributors
gap> for p in pkginfo.Persons do p.IsAuthor:=false; p.IsMaintainer:=false; od;
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading TestPkg 1.0 (A test package)
with contributions by:
   Lord Vader (https://www.gap-system.org/~darth),
   Luke Skywalker (luke.skywalker@gap-system.org),
   Leia Organa, and
   Yoda  (https://www.gap-system.org/~yoda).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


# test IssueTrackerURL
gap> pkginfo.IssueTrackerURL := "https://issues.gap-system.org/";;
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading TestPkg 1.0 (A test package)
with contributions by:
   Lord Vader (https://www.gap-system.org/~darth),
   Luke Skywalker (luke.skywalker@gap-system.org),
   Leia Organa, and
   Yoda  (https://www.gap-system.org/~yoda).
Homepage: https://www.gap-system.org
Report issues at https://issues.gap-system.org/
-----------------------------------------------------------------------------


#
gap> GAPInfo.TermEncoding := oldTermEncoding;;

#
# 
#
gap> ValidatePackageInfo(rec());
#E  component `PackageName' must be bound to a nonempty string
#E  component `Subtitle' must be bound to a string
#E  component `Version' must be bound to a nonempty string that does not start\
 with `='
#E  component `Date' must be bound to a string of the form yyyy-mm-dd or dd/mm\
/yyyy that represents a date since 1999
#E  component `License' must be bound to a nonempty string containing an SPDX \
ID
#E  component `ArchiveURL' must be bound to a string started with http://, htt\
ps:// or ftp://
#E  component `ArchiveFormats' must be bound to a string
#E  component `README_URL' must be bound to a string started with http://, htt\
ps:// or ftp://
#E  component `PackageInfoURL' must be bound to a string started with http://,\
 https:// or ftp://
#E  component `AbstractHTML' must be bound to a string
#E  component `PackageWWWHome' must be bound to a string started with http://,\
 https:// or ftp://
#E  component `PackageDoc' must be bound to a record or a list of records
false
gap> ValidatePackageInfo(rec() : quiet);
false
gap> info := rec(
>     PackageName := "pkg",
>     Subtitle := "desc",
>     Version := "0",
>     Date := "01/20/2015",      # invalid date, validator should flag it
>     License := "GPL-2.0-or-later",
>     ArchiveURL := "https://",
>     ArchiveFormats := "",
>     README_URL := "https://",
>     PackageInfoURL := "https://",
>     AbstractHTML := "",
>     PackageWWWHome := "https://",
>     AvailabilityTest := "invalid",  # ought to be a function
>   );;
gap> ValidatePackageInfo(info);
#E  component `Date' must be bound to a string of the form yyyy-mm-dd or dd/mm\
/yyyy that represents a date since 1999
#E  component `PackageDoc' must be bound to a record or a list of records
#E  component `AvailabilityTest', if present, must be bound to a function
false
gap> info := rec(
>     PackageName := "pkg",
>     Subtitle := "desc",
>     Version := "0",
>     Date := "2013-05-22",     # valid ISO 8601 date
>     License := "GPL-2.0-or-later",
>     ArchiveURL := "https://",
>     ArchiveFormats := "",
>     README_URL := "https://",
>     PackageInfoURL := "https://",
>     AbstractHTML := "",
>     PackageWWWHome := "https://",
>     AvailabilityTest := ReturnTrue,
>   );;
gap> ValidatePackageInfo(info);
#E  component `PackageDoc' must be bound to a record or a list of records
false
gap> info := rec(
>     PackageName := "pkg",
>     Subtitle := "desc",
>     Version := "0",
>     Date := "2013-22-05",      # invalid date, validator should flag it
>     License := "GPL-2.0-or-later",
>     ArchiveURL := "https://",
>     ArchiveFormats := "",
>     README_URL := "https://",
>     PackageInfoURL := "https://",
>     AbstractHTML := "",
>     PackageWWWHome := "https://",
>     AvailabilityTest := ReturnTrue,
>   );;
gap> ValidatePackageInfo(info);
#E  component `Date' must be bound to a string of the form yyyy-mm-dd or dd/mm\
/yyyy that represents a date since 1999
#E  component `PackageDoc' must be bound to a record or a list of records
false
gap> info := rec(
>     PackageName := "pkg",
>     Subtitle := "desc",
>     Version := "0",
>     Date := "2013-05-22-",   # invalid date, validator should flag it
>     License := "GPL-2.0-or-later",
>     ArchiveURL := "https://",
>     ArchiveFormats := "",
>     README_URL := "https://",
>     PackageInfoURL := "https://",
>     AbstractHTML := "",
>     PackageWWWHome := "https://",
>     AvailabilityTest := ReturnTrue,
>   );;
gap> ValidatePackageInfo(info);
#E  component `Date' must be bound to a string of the form yyyy-mm-dd or dd/mm\
/yyyy that represents a date since 1999
#E  component `PackageDoc' must be bound to a record or a list of records
false
gap> info := rec(
>     PackageName := "pkg",
>     Subtitle := "desc",
>     Version := "0",
>     Date := "01/02/3000",
>     License := "GPL-2.0-or-later",
>     ArchiveURL := "https://",
>     ArchiveFormats := "",
>     README_URL := "https://",
>     PackageInfoURL := "https://",
>     AbstractHTML := "",
>     PackageWWWHome := "https://",
>     PackageDoc := rec(),    # incomplete PackageDoc record
>     AvailabilityTest := ReturnTrue,
>   );;
gap> ValidatePackageInfo(info);
#E  component `BookName' must be bound to a string
#E  component `ArchiveURLSubset' must be bound to a list of strings denoting r\
elative paths to readable files or directories
#E  component `HTMLStart' must be bound to a string denoting a relative path t\
o a readable file
#E  component `PDFFile' must be bound to a string denoting a relative path to \
a readable file
#E  component `SixFile' must be bound to a string denoting a relative path to \
a readable file
#E  component `LongTitle' must be bound to a string
false
gap> info.PackageDoc := rec(
>     BookName := "",
>     ArchiveURLSubset := [],
>     HTMLStart := Filename(DirectoriesLibrary(), "init.g"),
>     PDFFile := Filename(DirectoriesLibrary(), "init.g"),
>     SixFile := Filename(DirectoriesLibrary(), "init.g"),
>     LongTitle := "",
>   );;
gap> ValidatePackageInfo(info);
true

#
# Deal with mock package
#

# first, force "unload" it (this is a very bad idea in general,
# but for this mock package, it is OK because we control everything)
gap> Unbind(GAPInfo.PackagesInfo.mockpkg);
gap> Unbind(GAPInfo.PackagesLoaded.mockpkg);
gap> for n in [ "mockpkg_GlobalFunction", "mockpkg_Operation", "mockpkg_Attribute", "mockpkg_Property", "mockpkg_ExtensionData" ] do
>   if IsBoundGlobal(n) then
>     MakeReadWriteGlobal(n);
>     UnbindGlobal(n);
>   fi;
> od;

#
gap> TestPackageAvailability("non-existing-package");
fail
gap> TestPackageAvailability("mockpkg");
fail
gap> TestPackageAvailability("MOCKPKG");
fail
gap> TestPackageAvailability("mockpkg", "=0.1");
fail
gap> TestPackageAvailability("mockpkg", ">=0.1");
fail
gap> TestPackageAvailability("mockpkg", "=2.0");
fail
gap> TestPackageAvailability("mockpkg", ">=2.0");
fail

#
gap> IsPackageLoaded("non-existing-package");
false
gap> IsPackageLoaded("mockpkg");
false
gap> IsPackageLoaded("MOCKPKG");
false
gap> IsPackageLoaded("mockpkg", "=0.1");
false
gap> IsPackageLoaded("mockpkg", ">=0.1");
false
gap> IsPackageLoaded("mockpkg", "=2.0");
false
gap> IsPackageLoaded("mockpkg", ">=2.0");
false

# load mockpkg first via SetPackagePath and later via
# ExtendPackageDirectories
gap> mockpkgpath := DirectoriesLibrary("tst/mockpkg")[1];;
gap> ValidatePackageInfo(Filename(mockpkgpath, "PackageInfo.g"));
true

# before we tell GAP about "mockpkg" explicitly, it doesn't know about it
gap> PackageInfo("mockpkg");
[  ]
gap> GetPackageNameForPrefix("mock");
"mock"

# point GAP at mockpkg
gap> SetPackagePath("mockpkg", mockpkgpath);

# ... now GAP "knows" the package
gap> GetPackageNameForPrefix("mock");
"mockpkg"

#
gap> TestPackageAvailability("non-existing-package");
fail
gap> TestPackageAvailability("mockpkg") = Filename(mockpkgpath, "");
oops, should not print here
true
gap> TestPackageAvailability("MOCKPKG") = Filename(mockpkgpath, "");
oops, should not print here
true
gap> TestPackageAvailability("mockpkg", "=0.1") = Filename(mockpkgpath, "");
oops, should not print here
true
gap> TestPackageAvailability("mockpkg", ">=0.1") = Filename(mockpkgpath, "");
oops, should not print here
true
gap> TestPackageAvailability("mockpkg", "=2.0");
fail
gap> TestPackageAvailability("mockpkg", ">=2.0");
fail

#
gap> IsPackageLoaded("non-existing-package");
false
gap> IsPackageLoaded("mockpkg");
false
gap> IsPackageLoaded("MOCKPKG");
false
gap> IsPackageLoaded("mockpkg", "=0.1");
false
gap> IsPackageLoaded("mockpkg", ">=0.1");
false
gap> IsPackageLoaded("mockpkg", "=2.0");
false
gap> IsPackageLoaded("mockpkg", ">=2.0");
false

# instruct GAP to load the package, and record all its declarations
# the help book of mockpkg might already have been loaded in other tests
# -> we suppress a warning about this
gap> old_warning_level := InfoLevel( InfoWarning );;
gap> SetInfoLevel( InfoWarning, 0 );
gap> PackageVariablesInfo("mockpkg", "0.1");;
oops, should not print here
oops, should not print here
gap> SetInfoLevel( InfoWarning, old_warning_level );
gap> ShowPackageVariables("mockpkg");
new global functions:
  mockpkg_GlobalFunction(  )*

new global variables:
  mockpkg_ExtensionData*

new operations:
  mockpkg_Operation( arg )*

new attributes:
  mockpkg_Attribute( ... )*

new properties:
  mockpkg_Property( ... )*

new methods:
  mockpkg_Attribute( G )*
  mockpkg_Operation( G, n )*
  mockpkg_Property( ... )*


# Cite() expects GAPInfo.Date to be of the form "YYYY-MM-DD" or "YYYY-Mon-DD" (or "today")
gap> IsDateFormatValid := function( datestring )
>      local val;
>      if datestring = "today" then
>        return true;
>      fi;
>      val:= SplitString( datestring, "-" );
>      if Length( val ) <> 3 then
>        return false;
>      fi;
>      return Int( val[1] ) in [ 1900 .. 2100 ] and ( val[2] in NameMonth or Int( val[2] ) in [ 1 .. 12 ] ) and Int( val[3] ) in [ 1 .. 31 ];
>    end;;
gap> IsDateFormatValid( GAPInfo.Date );
true

# Test the Cite() command (output changed with GAPDoc 1.6.6 and again with 1.6.7)
#@if CompareVersionNumbers(InstalledPackageVersion("gapdoc"), "1.6.7")
gap> Cite("mockpkg");
Please use one of the following samples
to cite mockpkg version from this installation

Text:

[AAM18]  Author,  A., Author, R. and Maintainer, O., mockpkg, A mock package
for   use   by  the  GAP  test  suite,  Version  0.1  (2018),  GAP  package,
https://mockpkg.gap-system.org/.

HTML:

<p class='BibEntry'>
[<span class='BibKey'>AAM18</span>]   <b class='BibAuthor'>Author, A., Author,\
 R. and Maintainer, O.</b>,
 <i class='BibTitle'>mockpkg, A mock package for use by the GAP test suite,
         Version 0.1</i>
 (<span class='BibYear'>2018</span>)<br />
(<span class='BibNote'>GAP package</span>),
<span class='BibHowpublished'><a href="https://mockpkg.gap-system.org/">https:\
//mockpkg.gap-system.org/</a></span>.
</p>

BibXML:

<entry id="mockpkg"><misc>
  <author>
    <name><first>Active</first><last>Author</last></name>
    <name><first>Retired</first><last>Author</last></name>
    <name><first>Only</first><last>Maintainer</last></name>
  </author>
  <title><C>mockpkg</C>, <C>A mock package for use by the GAP test suite</C>,
         <C>V</C>ersion 0.1</title>
  <howpublished><URL>https://mockpkg.gap-system.org/</URL></howpublished>
  <month>Mar</month>
  <year>2018</year>
  <note>GAP package</note>
</misc></entry>

BibTeX:

@misc{ mockpkg,
  author =           {Author, A. and Author, R. and Maintainer, O.},
  title =            {{mockpkg},  {A  mock  package  for use by the GAP test
                      suite}, {V}ersion 0.1},
  month =            {Mar},
  year =             {2018},
  note =             {GAP package},
  howpublished =     {\href                {https://mockpkg.gap-system.org/}
                      {\texttt{https://mockpkg.gap\texttt{\symbol{45}}system.o\
rg/}}},
  printedkey =       {AAM18}
}


#@else
gap> Cite("mockpkg");
Please use one of the following samples
to cite mockpkg version from this installation

Text:

[AAM18]  Author,  A., Author, R. and Maintainer, O., mockpkg, A mock package
for   use   by  the  GAP  test  suite,  Version  0.1  (2018),  GAP  package,
https://mockpkg.gap-system.org/.

HTML:

<p class='BibEntry'>
[<span class='BibKey'>AAM18</span>]   <b class='BibAuthor'>Author, A., Author,\
 R. and Maintainer, O.</b>,
 <i class='BibTitle'>mockpkg, A mock package for use by the GAP test suite,
         Version 0.1</i>
 (<span class='BibYear'>2018</span>)<br />
(<span class='BibNote'>GAP package</span>),
<span class='BibHowpublished'><a href="https://mockpkg.gap-system.org/">https:\
//mockpkg.gap-system.org/</a></span>.
</p>

BibXML:

<entry id="mockpkg"><misc>
  <author>
    <name><first>Active</first><last>Author</last></name>
    <name><first>Retired</first><last>Author</last></name>
    <name><first>Only</first><last>Maintainer</last></name>
  </author>
  <title><C>mockpkg</C>, A mock package for use by the GAP test suite,
         <C>V</C>ersion 0.1</title>
  <howpublished><URL>https://mockpkg.gap-system.org/</URL></howpublished>
  <month>Mar</month>
  <year>2018</year>
  <note>GAP package</note>
</misc></entry>

BibTeX:

@misc{ mockpkg,
  author =           {Author, A. and Author, R. and Maintainer, O.},
  title =            {{mockpkg},  A  mock  package  for  use by the GAP test
                      suite, {V}ersion 0.1},
  month =            {Mar},
  year =             {2018},
  note =             {GAP package},
  howpublished =     {\href                {https://mockpkg.gap-system.org/}
                      {\texttt{https://mockpkg.gap-system.org/}}},
  printedkey =       {AAM18}
}


#@fi

#
gap> TestPackageAvailability("non-existing-package");
fail
gap> TestPackageAvailability("mockpkg");
true
gap> TestPackageAvailability("MOCKPKG");
true
gap> TestPackageAvailability("mockpkg", "=0.1");
true
gap> TestPackageAvailability("mockpkg", ">=0.1");
true
gap> TestPackageAvailability("mockpkg", "=2.0");
fail
gap> TestPackageAvailability("mockpkg", ">=2.0");
fail

#
gap> IsPackageLoaded("non-existing-package");
false
gap> IsPackageLoaded("mockpkg");
true
gap> IsPackageLoaded("MOCKPKG");
true
gap> IsPackageLoaded("mockpkg", "=0.1");
true
gap> IsPackageLoaded("mockpkg", ">=0.1");
true
gap> IsPackageLoaded("mockpkg", "=2.0");
false
gap> IsPackageLoaded("mockpkg", ">=2.0");
false

# now add the directory with mockpkgpath as a new package directory
gap> ExtendPackageDirectories( [ mockpkgpath ] );

# make sure that the newly discovered installation path matches
# the path from which mockpkg was loaded above
gap> Last( GAPInfo.PackagesInfo.mockpkg ).InstallationPath =
>      GAPInfo.PackagesLoaded.mockpkg[1];
true

#
gap> SetPackagePath( "mockpkg", Filename( mockpkgpath, "" ) );
gap> SetPackagePath( "mockpkg", "/some/other/directory" );
Error, another version of package mockpkg is already loaded

#
# Test collecting information when calling LoadPackage, using the mock package
# ('eval_loadinfo' is an example how one can evaluate the returned info.)
#
gap> eval_loadinfo:= function( r, indent... )
> local rr;
> if Length( indent ) = 0 then
>   indent:= "";
> else
>   indent:= indent[1];
> fi;
> Print( indent, "consider package ", r.name, "\n" );
> indent:= Concatenation( indent, "  " );
> if IsBound( r.comment ) and r.comment <> "" then
>   Print( indent, "comment: ", r.comment, "\n" );
> fi;
> if IsBound( r.versions ) then
>   for rr in r.versions do
>     Print( indent, "consider version ", rr.version, ":\n" );
>     if IsBound( rr.comment ) and rr.comment <> "" then
>       Print( indent, "  comment: ", rr.comment, "\n" );
>     fi;
>     if Length( rr.dependencies ) <> 0 then
>       Print( indent, "  dependencies:\n" );
>       Perform( rr.dependencies,
>                x -> eval_loadinfo( x, Concatenation( indent, "    " ) ) );
>     fi;
>   od;
> fi;
> return "";
> end;;

#
gap> SetPackagePath("mockpkg", mockpkgpath);
gap> old_warning_level := InfoLevel( InfoWarning );;
gap> SetInfoLevel( InfoWarning, 0 );

# Try to load a different version of the package.
gap> loadinfo:= rec();;
gap> LoadPackage( "mockpkg", "=0.0" : LoadInfo:= loadinfo );
fail
gap> loadinfo;
rec( 
  comment := "package 'mockpkg' is already loaded, required version =0.0 is no\
t compatible with the actual version", name := "mockpkg", versions := [  ] )
gap> eval_loadinfo( loadinfo );;
consider package mockpkg
  comment: package 'mockpkg' is already loaded, required version =0.0 is not c\
ompatible with the actual version

# Force "unload" it (see above, we have done this already once).
gap> Unbind(GAPInfo.PackagesInfo.mockpkg);
gap> Unbind(GAPInfo.PackagesLoaded.mockpkg);
gap> for n in [ "mockpkg_GlobalFunction", "mockpkg_Operation", "mockpkg_Attribute", "Setmockpkg_Attribute", "Hasmockpkg_Attribute", "mockpkg_Property", "Setmockpkg_Property", "Hasmockpkg_Property", "mockpkg_ExtensionData" ] do
>   if IsBoundGlobal(n) then
>     MakeReadWriteGlobal(n);
>     UnbindGlobal(n);
>   fi;
> od;

# Notify the package again
gap> SetPackagePath("mockpkg", mockpkgpath);

# Force unavailability of the mock package, for various reasons.
# Try to load the package into a not admissible GAP version.
gap> GAPInfo.PackagesInfo.mockpkg:= ShallowCopy( GAPInfo.PackagesInfo.mockpkg );;
gap> info:= GAPInfo.PackagesInfo.mockpkg;;
gap> info[1]:= ShallowCopy( info[1] );;
gap> info:= info[1];;
gap> info.Dependencies:= ShallowCopy( info.Dependencies );;
gap> info.Dependencies.GAP:= "=0.0";;
gap> loadinfo:= rec();;
gap> LoadPackage( "mockpkg" : LoadInfo:= loadinfo );
fail
gap> Unbind( info.Dependencies.GAP );
gap> loadinfo;
rec( comment := "", name := "mockpkg", 
  versions := 
    [ rec( comment := "GAP version =0.0 is required, ", dependencies := [  ], 
          version := "0.1" ) ] )
gap> eval_loadinfo( loadinfo );;
consider package mockpkg
  consider version 0.1:
    comment: GAP version =0.0 is required, 

# Try again to load the package into a not admissible GAP version.
gap> info.Dependencies.NeededOtherPackages:= [ [ "GAP", "=0.0" ] ];;
gap> info.AvailabilityTest:= ReturnTrue;;
gap> loadinfo:= rec();;
gap> LoadPackage( "mockpkg" : LoadInfo:= loadinfo );
fail
gap> info.Dependencies.NeededOtherPackages:= [];;
gap> loadinfo;
rec( comment := "", name := "mockpkg", 
  versions := 
    [ 
      rec( comment := "", 
          dependencies := 
            [ 
              rec( 
                  comment := "required GAP version =0.0 is not compatible with \
the actual version", name := "gap", versions := [  ] ) ], version := "0.1" ) 
     ] )
gap> eval_loadinfo( loadinfo );;
consider package mockpkg
  consider version 0.1:
    dependencies:
      consider package gap
        comment: required GAP version =0.0 is not compatible with the actual v\
ersion

# Try to load the package with a too restrictive availability test.
gap> info:= GAPInfo.PackagesInfo.mockpkg[1];;
gap> info.AvailabilityTest:= ReturnFalse;;
gap> loadinfo:= rec();;
gap> LoadPackage( "mockpkg" : LoadInfo:= loadinfo );
fail
gap> info.AvailabilityTest:= ReturnTrue;;
gap> loadinfo;
rec( comment := "", name := "mockpkg", 
  versions := 
    [ rec( comment := "the AvailabilityTest function returned false, ", 
          dependencies := [  ], version := "0.1" ) ] )
gap> eval_loadinfo( loadinfo );;
consider package mockpkg
  consider version 0.1:
    comment: the AvailabilityTest function returned false, 

# Try to load the package with not satisfied dependencies.
gap> info.Dependencies.NeededOtherPackages:= [ [ "mockpkg", "=0.0" ] ];;
gap> loadinfo:= rec();;
gap> LoadPackage( "mockpkg" : LoadInfo:= loadinfo );
fail
gap> loadinfo;
rec( comment := "", name := "mockpkg", 
  versions := 
    [ 
      rec( comment := "", 
          dependencies := 
            [ 
              rec( 
                  comment := "for package 'mockpkg', version 0.1 is assumed on \
an outer level, but version =0.0 is required here", name := "mockpkg", 
                  versions := [  ] ) ], version := "0.1" ) ] )
gap> eval_loadinfo( loadinfo );;
consider package mockpkg
  consider version 0.1:
    dependencies:
      consider package mockpkg
        comment: for package 'mockpkg', version 0.1 is assumed on an outer lev\
el, but version =0.0 is required here
gap> Unbind( info.Dependencies.OtherPackagesLoadedInAdvance );
gap> Unbind( GAPInfo.PackagesInfo.mockpkg2 );
gap> info.Dependencies.NeededOtherPackages:= [ [ "gapdoc", "=0.0" ] ];;
gap> loadinfo:= rec();;
gap> LoadPackage( "mockpkg" : LoadInfo:= loadinfo );
fail
gap> loadinfo;
rec( comment := "", name := "mockpkg", 
  versions := 
    [ 
      rec( comment := "", 
          dependencies := 
            [ 
              rec( 
                  comment := "package 'gapdoc' is already loaded, required vers\
ion =0.0 is not compatible with the actual version", name := "gapdoc", 
                  versions := [  ] ) ], version := "0.1" ) ] )
gap> eval_loadinfo( loadinfo );;
consider package mockpkg
  consider version 0.1:
    dependencies:
      consider package gapdoc
        comment: package 'gapdoc' is already loaded, required version =0.0 is \
not compatible with the actual version

# Try to load an unknown package.
gap> loadinfo:= rec();;
gap> LoadPackage( "unavailable_package" : LoadInfo:= loadinfo );
fail
gap> loadinfo;
rec( comment := "package is not listed in GAPInfo.PackagesInfo", 
  name := "unavailable_package" )
gap> eval_loadinfo( loadinfo );;
consider package unavailable_package
  comment: package is not listed in GAPInfo.PackagesInfo
gap> SetInfoLevel( InfoWarning, old_warning_level );

#
gap> STOP_TEST( "package.tst" );
