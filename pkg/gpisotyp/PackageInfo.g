#############################################################################
##  
##  PackageInfo.g file for the GAP 4 package GpIsoTyp           Thomas Breuer
##  
SetPackageInfo( rec(
PackageName :=
  "GpIsoTyp",
Version :=
  "1.0",
Autoload :=
  # The package is an auxiliary package for other (autoloadable) packages,
  # it will be required by them.
  false,
Date :=
  "DD/MM/YYYY",
ArchiveURL :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer/gpisotyp/gpisotyp1r0",
ArchiveFormats :=
  ".tar.gz,.zoo",
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
#  "...",
#AcceptDate :=
#  "MM/YYYY",
README_URL :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer/gpisotyp/README",
PackageInfoURL :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer/gpisotyp/PackageInfo.g",
AbstractHTML := Concatenation( [
  "Isomorphism types of finite groups, ..."
  ] ),
PackageWWWHome :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer/gpisotyp",
PackageDoc := rec(
  BookName :=
    "gpisotyp",
  Archive :=
    "http://www.math.rwth-aachen.de/~Thomas.Breuer/gpisotyp1r0doc.tar.gz",
  HTMLStart :=
    "htm/chapters.html",
  PDFFile :=
    "doc/manual.pdf",
  SixFile :=
    "doc/manual.six",
  LongTitle :=
    "Isomorphism Types of Finite Groups",
  Autoload :=
    false
  ),
Dependencies := rec(
  GAP :=
    "4.3",
  NeededOtherPackages :=
    [],
  SuggestedOtherPackages :=
    [],
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

