#############################################################################
##
#W  package.tst               GAP Library                       Thomas Breuer
##
##
#Y  Copyright (C)  2005,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
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
>                           FirstNames := "Lord",
>                           LastName := "Vader",
>                           WWWHome := "https://www.gap-system.org/~darth"
>                           ) ]);;

#
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading  TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


#
gap> Add(pkginfo.Persons, rec( IsAuthor := true, FirstNames := "Luke",
>                           LastName := "Skywalker", Email := "luke.skywalker@gap-system.org" ));
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading  TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth) and
   Luke Skywalker (luke.skywalker@gap-system.org).
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


#
gap> Add(pkginfo.Persons, rec( IsAuthor := true, FirstNames := "Leia", LastName := "Organa" ));
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading  TestPkg 1.0 (A test package)
by Lord Vader (https://www.gap-system.org/~darth),
   Luke Skywalker (luke.skywalker@gap-system.org), and
   Leia Organa.
Homepage: https://www.gap-system.org
-----------------------------------------------------------------------------


#
gap> for p in pkginfo.Persons do p.IsAuthor:=false; p.IsMaintainer:=true; od;
gap> Display(DefaultPackageBannerString(pkginfo));
-----------------------------------------------------------------------------
Loading  TestPkg 1.0 (A test package)
maintained by Lord Vader (https://www.gap-system.org/~darth),
              Luke Skywalker (luke.skywalker@gap-system.org), and
              Leia Organa.
Homepage: https://www.gap-system.org
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
# Deal with fake package
#
gap> fakepkgpath := DirectoriesLibrary("tst/fakepkg")[1];;
gap> ValidatePackageInfo(Filename(fakepkgpath, "PackageInfo.g"));
true

# before we tell GAP about "fakepkg" explicitly, it doesn't know about it
gap> PackageInfo("fakepkg");
[  ]
gap> GetPackageNameForPrefix("fake");
"fake"

# point GAP at fakepkg
gap> SetPackagePath("fakepkg", fakepkgpath);

# ... now it "knows" it
gap> GetPackageNameForPrefix("fake");
"fakepkg"

# instruct GAP to load the package, and record all its declarations
gap> PackageVariablesInfo("fakepkg", "0.1");;
gap> ShowPackageVariables("fakepkg");
new global functions:
  fakepkg_GlobalFunction(  )*

new operations:
  fakepkg_Operation( arg )*

new attributes:
  fakepkg_Attribute( ... )*

new properties:
  fakepkg_Property( ... )*

new methods:
  fakepkg_Attribute( G )*
  fakepkg_Operation( G, n )*
  fakepkg_Property( ... )*


# Test the Cite() command
gap> Cite("fakepkg");
Please use one of the following samples
to cite fakepkg version from this installation

Text:

[AAM18]  Author,  A., Author, R. and Maintainer, O., fakepkg, A fake package
for  use  by  the  GAP  test  suite,  Version  0.1  (2018),  (GAP  package),
https://fakepkg.gap-system.org/.

HTML:

<p class='BibEntry'>
[<span class='BibKey'>AAM18</span>]   <b class='BibAuthor'>Author, A., Author,\
 R. and Maintainer, O.</b>,
 <i class='BibTitle'>fakepkg, A fake package for use by the GAP test suite,
         Version 0.1</i>
 (<span class='BibYear'>2018</span>)<br />
(<span class='BibNote'>GAP package</span>),
<span class='BibHowpublished'><a href="https://fakepkg.gap-system.org/">https:\
//fakepkg.gap-system.org/</a></span>.
</p>

BibXML:

<entry id="fakepkg0.1"><misc>
  <author>
    <name><first>Active</first><last>Author</last></name>
    <name><first>Retired</first><last>Author</last></name>
    <name><first>Only</first><last>Maintainer</last></name>
  </author>
  <title><C>fakepkg</C>, A fake package for use by the GAP test suite,
         <C>V</C>ersion 0.1</title>
  <howpublished><URL>https://fakepkg.gap-system.org/</URL></howpublished>
  <month>Mar</month>
  <year>2018</year>
  <note>GAP package</note>
</misc></entry>

BibTeX:

@misc{ fakepkg0.1,
  author =           {Author, A. and Author, R. and Maintainer, O.},
  title =            {{fakepkg},  A  fake  package  for  use by the GAP test
                      suite, {V}ersion 0.1},
  month =            {Mar},
  year =             {2018},
  note =             {GAP package},
  howpublished =     {\href                {https://fakepkg.gap-system.org/}
                      {\texttt{https://fakepkg.gap-system.org/}}},
  printedkey =       {AAM18}
}


#
gap> STOP_TEST( "package.tst", 1);

#############################################################################
##
#E
