#############################################################################
##
##  PackageInfo.g for the GAP 4 package AtlasRep                Thomas Breuer
##
SetPackageInfo( rec(
PackageName :=
  "AtlasRep",
MyVersion :=
  "1r5p0",
MyWWWHome :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer",
Subtitle :=
  "A GAP Interface to the Atlas of Group Representations",
Version :=
  JoinStringsWithSeparator( SplitString( ~.MyVersion, "rp" ), "." ),
Date :=
  # "03/04/2001" -- Version 1.0
  # "23/10/2002" -- Version 1.1
  # "06/11/2003" -- Version 1.2
  # "05/04/2004" -- Version 1.2.1
  # "06/06/2007" -- Version 1.3
  # "01/10/2007" -- Version 1.3.1
  # "23/06/2008" -- Version 1.4
  "12/07/2011", # -- Version 1.5.0
PackageWWWHome :=
  Concatenation( ~.MyWWWHome, "/", LowercaseString( ~.PackageName ) ),
ArchiveURL :=
  Concatenation( ~.PackageWWWHome, "/", LowercaseString( ~.PackageName ),
                 ~.MyVersion ),
ArchiveFormats :=
  ".tar.gz,.zoo",
Persons := [
  rec(
    LastName := "Wilson",
    FirstNames := "Robert A.",
    IsAuthor := true,
    IsMaintainer := false,
    Email := "R.A.Wilson@qmul.ac.uk",
    WWWHome := "http://www.maths.qmw.ac.uk/~raw",
    Place := "London",
    Institution := Concatenation( [
      "School of Mathematical Sciences, ",
      "Queen Mary, University of London",
      ] ),
    ),
  rec(
    LastName := "Parker",
    FirstNames := "Richard A.",
    IsAuthor := true,
    IsMaintainer := false,
    Email := "richpark@gmx.co.uk",
  ),
  rec(
    LastName := "Nickerson",
    FirstNames := "Simon",
    IsAuthor := true,
    IsMaintainer := false,
    WWWHome := "http://nickerson.org.uk/groups",
    Institution := Concatenation( [
      "School of Mathematics, ",
      "University of Birmingham",
      ] ),
  ),
  rec(
    LastName := "Bray",
    FirstNames := "John N.",
    IsAuthor := true,
    IsMaintainer := false,
    Email := "J.N.Bray@qmul.ac.uk",
    WWWHome := "http://www.maths.qmw.ac.uk/~jnb",
    Place := "London",
    Institution := Concatenation( [
      "School of Mathematical Sciences, ",
      "Queen Mary, University of London",
      ] ),
  ),
  rec(
    LastName := "Breuer",
    FirstNames := "Thomas",
    IsAuthor := true,
    IsMaintainer := true,
    Email := "sam@math.rwth-aachen.de",
    WWWHome := ~.MyWWWHome,
    Place := "Aachen",
    Institution := "Lehrstuhl D für Mathematik, RWTH Aachen",
    PostalAddress := Concatenation( [
      "Thomas Breuer\n",
      "Lehrstuhl D für Mathematik\n",
      "Templergraben 64\n",
      "52062 Aachen\n",
      "Germany"
      ] ),
  ),
  ],
Status :=
  "accepted",
CommunicatedBy :=
  "Herbert Pahlings (Aachen)",
AcceptDate :=
  "04/2001",
README_URL :=
  Concatenation( ~.PackageWWWHome, "/README" ),
PackageInfoURL :=
  Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
AbstractHTML := Concatenation( [
  "The package provides a <span class=\"pkgname\">GAP</span> interface ",
  "to the <a href=\"http://brauer.maths.qmul.ac.uk/Atlas\">",
  "Atlas of Group Representations</a>"
  ] ),
PackageDoc := rec(
  BookName :=
    "AtlasRep",
  ArchiveURLSubset :=
    [ "doc" ],
  HTMLStart :=
    "doc/chap0.html",
  PDFFile :=
    "doc/manual.pdf",
  SixFile :=
    "doc/manual.six",
  LongTitle :=
    "An Atlas of Group Representations",
  ),
Dependencies := rec(
  GAP :=
    ">= 4.4.12",                 # do not really need GAP 4.5 features
  NeededOtherPackages :=
    [ [ "gapdoc", ">= 1.2" ],
#     [ "gpisotyp", ">= 1.0" ],
    ],
  SuggestedOtherPackages :=
    [ [ "browse", ">= 1.4" ],    # want `BrowseData.SortKeyFunctionBibRec'
      [ "ctbllib", ">= 1.1.4" ], # want `LIBTABLE.NameReplacements'
      [ "tomlib", ">= 1.2.1" ],
      [ "io", ">= 3.3" ] ],
#T suggest also mfer! -> yields data extensions
  # needed external conditions (programs, operating system, ...)  provide
  # just strings as text or
  # pairs [text, URL] where URL  provides further information
  # about that point.
  # (no automatic test will be done for this, do this in your
  # 'AvailabilityTest' function below)
  ExternalConditions :=
    []
  ),
AvailabilityTest :=
  ReturnTrue,
TestFile :=
  "tst/testall.g",
Keywords :=
  ["group representations", "finite simple groups"]
) );


#############################################################################
##
#E

