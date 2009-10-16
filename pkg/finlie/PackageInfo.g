#############################################################################
##
#W  PackageInfo.g       GAP 4 Package `FinLie'                   Bettina Eick
##

SetPackageInfo( rec(

PackageName := "FinLie",
Subtitle    := "Computation with finite Lie algebras",
Version     := "1.0",
Date        := "07/03/2005",

ArchiveFormats := ".tar",
ArchiveURL     := 
  "http://cayley.math.nat.tu-bs.de/software/eick/finlie/finlie-1.0",

Persons          := [ 
  rec( LastName      := "Eick",
       FirstNames    := "Bettina",
       IsAuthor      := true,
       IsMaintainer  := true,
       Email         := "b.eick@tu-bs.de",
       WWWHome       := "http://www.tu-bs.de/~beick",
       PostalAddress := Concatenation([
               "Institut Computational Mathematics",
               "TU Braunschweig\n",
               "Pockelsstr. 14 \n D-38106 Braunschweig \n Germany"] ),
       Place         := "Braunschweig",
       Institution   := "TU Braunschweig") ],

Status              := "dev",

README_URL 
  := "http://cayley.math.nat.tu-bs.de/software/eick/finlie/README",
PackageInfoURL 
  := "http://cayley.math.nat.tu-bs.de/software/eick/finlie/PackageInfo.g",

AbstractHTML     :=
"This package provides algorithms for computations with finite Lie algebras",

PackageWWWHome 
  := "http://cayley.math.nat.tu-bs.de/software/eick/finlie",

PackageDoc     := rec(
                BookName  := "finlie",
                ArchiveURLSubset   := [ "doc", "htm" ],
                HTMLStart := "htm/chapters.htm",
                PDFFile   := "doc/manual.pdf",
                SixFile   := "doc/manual.six",
                LongTitle := "Computation with finite Lie algebras",
                Autoload  := true),

Dependencies    := rec(
                GAP                    := ">= 4.3fix4",
                NeededOtherPackages    := [],
                SuggestedOtherPackages := [],
                ExternalConditions     := []),

AvailabilityTest := ReturnTrue,
BannerString     := "Loading FinLie 1.0  ...\n",
Autoload         := false,
Keywords         := [] ));

