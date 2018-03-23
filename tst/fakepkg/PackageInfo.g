#
# fakepkg: A fake package for use by the GAP test suite
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "fakepkg",
Subtitle := "A fake package for use by the GAP test suite",
Version := "0.1",
Date := "21/03/2018", # dd/mm/yyyy format

Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Active",
    LastName := "Author",
    WWWHome := "https://fakepkg.gap-system.org/~author",
    Email := "a.author@fakepkg.gap-system.org",
  ),
  rec(
    IsAuthor := true,
    IsMaintainer := false,
    FirstNames := "Retired",
    LastName := "Author",
    Email := "r.author@fakepkg.gap-system.org",
  ),
  rec(
    IsAuthor := false,
    IsMaintainer := true,
    FirstNames := "Only",
    LastName := "Maintainer",
    WWWHome := "https://fakepkg.gap-system.org/~maintainer",
  ),
  rec(
    IsAuthor := false,
    IsMaintainer := false,
    FirstNames := "Some",
    LastName := "Contributor",
  ),
],

#SourceRepository := rec( Type := "TODO", URL := "URL" ),
#IssueTrackerURL := "TODO",
#SupportEmail := "TODO",

PackageWWWHome := "https://fakepkg.gap-system.org/",

PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL     := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL     := Concatenation( ~.PackageWWWHome,
                                 "/", ~.PackageName, "-", ~.Version ),

ArchiveFormats := ".tar.gz",

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "dev",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "fakepkg",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "A fake package for use by the GAP test suite",
),

Dependencies := rec(
  GAP := ">= 4.9",
  NeededOtherPackages := [ [ "GAPDoc", ">= 1.6.1" ] ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [ ],
),

AvailabilityTest := ReturnTrue,

# use an empty banner string, so that we get identical output regardless
# of whether GAP is started with -q or -b, or not.
BannerString := "",

TestFile := "tst/testall.g",

#Keywords := [ "TODO" ],

));


