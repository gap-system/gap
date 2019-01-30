#@local entry,equ,pair,sml,oldTermEncoding,pkginfo,info,mockpkgpath,p,n
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
Loading  TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


# add a maintainer who is not an author
gap> Add(pkginfo.Persons, rec( IsAuthor := false, IsMaintainer := true,
>                           FirstNames := "Luke", LastName := "Skywalker",
>                           Email := "luke.skywalker@gap-system.org" ));
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading  TestPkg 1.0 (A test package)
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
Loading  TestPkg 1.0 (A test package)
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
Loading  TestPkg 1.0 (A test package)
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
Loading  TestPkg 1.0 (A test package)
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
Loading  TestPkg 1.0 (A test package)
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
Loading  TestPkg 1.0 (A test package)
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
Loading  TestPkg 1.0 (A test package)
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
Loading  TestPkg 1.0 (A test package)
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
#E  component `Date' must be bound to a string of the form `dd/mm/yyyy'
#E  component `ArchiveURL' must be bound to a string started with http://, htt\
ps:// or ftp://
#E  component `ArchiveFormats' must be bound to a string
#E  component `Status' must be bound to one of "accepted", "deposited", "dev",\
 "other"
#E  component `README_URL' must be bound to a string started with http://, htt\
ps:// or ftp://
#E  component `PackageInfoURL' must be bound to a string started with http://,\
 https:// or ftp://
#E  component `AbstractHTML' must be bound to a string
#E  component `PackageWWWHome' must be bound to a string started with http://,\
 https:// or ftp://
#E  component `PackageDoc' must be bound to a record or a list of records
#E  component `AvailabilityTest' must be bound to a function
false
gap> info := rec(
>     PackageName := "pkg",
>     Subtitle := "desc",
>     Version := "0",
>     Date := "01/02/3000",
>     ArchiveURL := "https://",
>     ArchiveFormats := "",
>     Status := "other",
>     README_URL := "https://",
>     PackageInfoURL := "https://",
>     AbstractHTML := "",
>     PackageWWWHome := "https://",
>     PackageDoc := rec(),
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
gap> for n in [ "mockpkg_GlobalFunction", "mockpkg_Operation", "mockpkg_Attribute", "mockpkg_Property" ] do
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
gap> IsPackageLoaded("mockpkg", "=0.1");
false
gap> IsPackageLoaded("mockpkg", ">=0.1");
false
gap> IsPackageLoaded("mockpkg", "=2.0");
false
gap> IsPackageLoaded("mockpkg", ">=2.0");
false

#
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
gap> IsPackageLoaded("mockpkg", "=0.1");
false
gap> IsPackageLoaded("mockpkg", ">=0.1");
false
gap> IsPackageLoaded("mockpkg", "=2.0");
false
gap> IsPackageLoaded("mockpkg", ">=2.0");
false

# instruct GAP to load the package, and record all its declarations
gap> PackageVariablesInfo("mockpkg", "0.1");;
oops, should not print here
oops, should not print here
gap> ShowPackageVariables("mockpkg");
new global functions:
  mockpkg_GlobalFunction(  )*

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


# Test the Cite() command
gap> Cite("mockpkg");
Please use one of the following samples
to cite mockpkg version from this installation

Text:

[AAM18]  Author,  A., Author, R. and Maintainer, O., mockpkg, A mock package
for  use  by  the  GAP  test  suite,  Version  0.1  (2018),  (GAP  package),
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

<entry id="mockpkg0.1"><misc>
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

@misc{ mockpkg0.1,
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


#
gap> TestPackageAvailability("non-existing-package");
fail
gap> TestPackageAvailability("mockpkg");
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
gap> IsPackageLoaded("mockpkg", "=0.1");
true
gap> IsPackageLoaded("mockpkg", ">=0.1");
true
gap> IsPackageLoaded("mockpkg", "=2.0");
false
gap> IsPackageLoaded("mockpkg", ">=2.0");
false

#
gap> STOP_TEST( "package.tst", 1);
