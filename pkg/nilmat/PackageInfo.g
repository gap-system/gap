#############################################################################
##  
##  PackageInfo.g for the package `Nilmat'                       Bettina Eick 
##  
##  This is a GAP readable file. Of course you can change and remove all
##  comments as you like.
##  
##  This file contains meta-information on the package. It is used by
##  the package loading mechanism and the upgrade mechanism for the
##  redistribution of the package via the GAP website.
##  
##  For the LoadPackage mechanism in GAP >= 4.4 only the entries
##  .PackageName, .Version, .PackageDoc, .Dependencies, .AvailabilityTest
##  .Autoload   are needed. The other entries are relevant if the
##  package shall be distributed for other GAP users, in particular if it
##  shall be redistributed via the GAP Website.
##
##  With a new release of the package at least the entries .Version, .Date and
##  .ArchiveURL must be updated.

SetPackageInfo( rec(

PackageName := "Nilmat",
Subtitle := "Computing with nilpotent matrix groups",
Version := "1.1",
Date := "31/03/2007",

Persons := [
  rec( 
    LastName      := "Detinko",
    FirstNames    := "Alla",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "alla.detinko@nuigalway.ie",
    WWWHome       := "http://larmor.nuigalway.ie/staff/adetinko.shtml",
    PostalAddress := Concatenation( [
                       "Department of Mathematics\n",
                       "National University of Ireland, Galway\n",
                       "University Road, Galway\n",
                       "Ireland" ] ),
    Place         := "Galway",
    Institution   := "NUI Galway"),
  rec( 
    LastName      := "Eick",
    FirstNames    := "Bettina",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "beick@tu-bs.de",
    WWWHome       := "http://www-public.tu-bs.de:8080/~beick",
    PostalAddress := Concatenation( [
                       "Institut Computational Mathematics\n",
                       "TU Braunschweig\n",
                       "38106 Braunschweig\n",
                       "Germany" ] ),
    Place         := "Braunschweig",
    Institution   := "TU Braunschweig"),
  rec( 
    LastName      := "Flannery",
    FirstNames    := "Dane",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "dane.flannery@nuigalway.ie",
    WWWHome       := "http://www.maths.nuigalway.ie/~dane",
    PostalAddress := Concatenation( [
                       "Department of Mathematics\n",
                       "National University of Ireland, Galway\n",
                       "University Road, Galway\n",
                       "Ireland" ] ),
    Place         := "Galway",
    Institution   := "NUI Galway")
],

Status := "dev",

ArchiveURL := 
  "http://larmor.nuigalway.ie/~dane/nilmat/nilmat-1.0",
README_URL := 
  "http://larmor.nuigalway.ie/~dane/nilmat/README",
PackageInfoURL := 
  "http://larmor.nuigalway.ie/~dane/nilmat/PackageInfo.g",
ArchiveFormats := ".tar.gz",
PackageWWWHome := 
  "http://larmor.nuigalway.ie/~dane/nilmat",

AbstractHTML := 
  "The <span class=\"pkgname\">Nilmat</span> package contains methods for checking whether a finitely generated matrix group over a finite field or the field of rational numbers is nilpotent, methods for computing with such nilpotent matrix groups and methods for contructing important classes of such nilpotent matrix groups.",
               
PackageDoc := rec(
  BookName  := "Nilmat",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Computation with nilpotent matrix groups",
  Autoload  := true
),

Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [["Polenta", ">=1,0"]],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,
BannerString := Concatenation("Loading Nilmat ", String( ~.Version ), "...\n"),
Autoload := false,
Keywords := ["nilpotent groups", "matrix groups"]

));
