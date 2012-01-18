#############################################################################
##
##  PackageInfo.g for the GAP 4 package CTblLib                 Thomas Breuer
##
SetPackageInfo( rec(
PackageName :=
  "CTblLib",
MyVersion :=
  "1r2p0",
MyWWWHome :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer",
Subtitle :=
  "The GAP Character Table Library",
Version :=
  JoinStringsWithSeparator( SplitString( ~.MyVersion, "rp" ), "." ),
Date :=
  # "21/01/2002" -- Version 1.0
  # "18/11/2003" -- Version 1.1.0
  # "20/11/2003" -- Version 1.1.1
  # "27/11/2003" -- Version 1.1.2
  # "31/03/2004" -- Version 1.1.3
  "31/10/2011",
PackageWWWHome :=
  Concatenation( ~.MyWWWHome, "/", LowercaseString( ~.PackageName ) ),
ArchiveURL :=
  Concatenation( ~.PackageWWWHome, "/", LowercaseString( ~.PackageName ),
                 ~.MyVersion ),
ArchiveFormats :=
  ".tar.gz,.zoo",
Persons := [
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
#   rec(  
#     LastName      := "Claßen-Houben",
#     FirstNames    := "Michael",
#     IsAuthor      := true, 
#     IsMaintainer  := false,
#     Email         := "michael@oph.rwth-aachen.de",
#     Place         := "Aachen",
#     Institution   := "RWTH Aachen"
#   ),
  ],
Status :=
  "deposited",
#CommunicatedBy :=
#  "name (place)",
#AcceptDate :=
#  "MM/YYYY",
README_URL :=
  Concatenation( ~.PackageWWWHome, "/README" ),
PackageInfoURL :=
  Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
AbstractHTML := Concatenation( [
  "The package contains the <span class=\"pkgname\">GAP</span> ",
  "Character Table Library"
  ] ),
PackageDoc := rec(
  BookName :=
    "CTblLib",
  ArchiveURLSubset :=
    [ "doc", "htm" ],
  HTMLStart :=
    "doc/chap0.html",
  PDFFile :=
    "doc/manual.pdf",
  SixFile :=
    "doc/manual.six",
  LongTitle :=
    "The GAP Character Table Library",
  ),
Dependencies := rec(
  GAP :=
    ">= 4.4",
  OtherPackagesLoadedInAdvance :=
    [],
  NeededOtherPackages :=
    [ [ "gapdoc", ">= 0.9" ] ],
   # [["gpisotyp", ">= 1.0"]],
  SuggestedOtherPackages :=
    [ [ "tomlib", ">= 1.0" ],     # because of the interface
      [ "Browse", ">= 1.1" ],     # because of database attributes and overview functions
      [ "chevie", ">= 1.0" ] ],   # because of Deligne-Lusztig names
  ExternalConditions :=
    [],
  ),
AvailabilityTest :=
  ReturnTrue,
TestFile :=
  "tst/testall.g",
Keywords :=
  [ "ordinary character table", "Brauer table", "generic character table",
    "decomposition matrix", "class fusion", "power map",
    "permutation character", "table automorphism",
    "central extension", "projective character",
    "Atlas Of Finite Groups" ],
 )
 );

#############################################################################
##
#E

