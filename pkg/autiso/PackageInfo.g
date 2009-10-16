#############################################################################
##  
##  PackageInfo.g for the package `autiso'                      Bettina Eick
##  
SetPackageInfo( rec(
PackageName := "AutIso",
Subtitle := "Computing automorphisms and isomorphisms",
Version := "1.0",
Date := "17/04/2007",

Persons := [
  rec( 
    LastName      := "Eick",
    FirstNames    := "Bettina",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "beick@tu-bs.de",
    WWWHome       := "http://www.tu-bs.de/~beick",
    PostalAddress := Concatenation( [
                       "Institut Computational Mathematics\n",
                       "Pockelsstrasse 14, 38106 Braunschweig\n",
                       "Germany" ] ),
    Place         := "Braunschweig",
    Institution   := "TU Braunschweig"
  ) ],

Status := "dev",

ArchiveURL := "",
README_URL := "",
PackageInfoURL := "",
PackageWWWHome := "",
ArchiveFormats := ".tar.gz",

AbstractHTML := 
  "The <span class=\"pkgname\">AutIso</span> package contains methods to determine automorpism groups and testing isomorphisms for p-groups, modular group algebras and Lie algebras over finite fields",

               
PackageDoc := rec(
  BookName  := "AutIso",
  Archive := "",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Computing automorphisms and isomorphisms",
  Autoload  := true
),


Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [["polycyclic", ">=1.0"], 
                          ["laguna", ">=1.0"]],
  SuggestedOtherPackages := [["liealgdb", ">=1.0"]],
  ExternalConditions := []
),


BannerString := "Loading AutIso 1.0... \n",
AvailabilityTest := ReturnTrue,
Autoload := false,
Keywords := ["mip"]

));


