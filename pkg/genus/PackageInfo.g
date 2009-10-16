#############################################################################
##  
##  PackageInfo.g file for the GAP 4 package Genus              Thomas Breuer
##  
SetPackageInfo( rec(
PackageName :=
  "Genus",
Version :=
  "1.0",
Autoload :=
  false,
Date :=
  "../../2003",
ArchiveURL :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer/genus/genus1r0",
ArchiveFormats :=
  ".tgz,.zoo",
Persons := [
  rec(
    LastName := "Breuer",
    FirstNames := "Thomas",
    IsAuthor := true,
    IsMaintainer := true,
    Email := "sam@math.rwth-aachen.de",
    WWWHome := "http://www.math.rwth-aachen/~Thomas.Breuer",
    Place := "Aachen",
    Institution := "Lehrstuhl D f&uuml;r Mathematik, RWTH Aachen",
    PostalAddress := Concatenation( [
      "Thomas Breuer\n",
      "Lehrstuhl D f&uuml;r Mathematik\n",
      "Templergraben 64\n",
      "52062 Aachen\n",
      "Germany"
      ] )
  ),
  ],
Status :=
  "deposited",
#CommunicatedBy :=
#  "Herbert Pahlings (Aachen)",
#AcceptDate :=
#  "../2003",
README_URL :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer/genus/README",
PackageInfoURL :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer/genus/PackageInfo.g",
AbstractHTML := Concatenation( [
  "The package provides ..."
  ] ),
PackageWWWHome :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer/genus",
PackageDoc := rec(
  BookName :=
    "Genus",
  Archive :=
    "http://www.math.rwth-aachen.de/~Thomas.Breuer/genus1r0doc.tar.gz",
  HTMLStart :=
    "htm/chapters.html",
  PDFFile :=
    "doc/manual.pdf",
  SixFile :=
    "doc/manual.six",
  LongTitle :=
    "...",
  Autoload :=
    true
  ),
Dependencies := rec(
  GAP :=
    "4.4",
  NeededOtherPackages :=
    [], # [["gpisotyp", ">= 1.0"]],
  SuggestedOtherPackages :=
    [],
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
  ["..."]
) );

#############################################################################
##  
#E

