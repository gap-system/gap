#############################################################################
##  
##  PackageInfo.g for the package `AutPGrp'                      Bettina Eick
##  

SetPackageInfo( rec(

PackageName := "AutPGrp",
Subtitle := "Computing the Automorphism Group of a p-Group",
Version := "1.4",
Date := "31/08/2009",
ArchiveURL := "http://www-public.tu-bs.de:8080/~beick/soft/autpgrp/autpgrp-1.4", 
ArchiveFormats := ".tar.gz",

Persons := [
  rec( 
      LastName      := "Eick",
      FirstNames    := "Bettina",
      IsAuthor      := true,
      IsMaintainer  := true,
      Email         := "b.eick@tu-bs.de",
      WWWHome       := "http://www-public.tu-bs.de:8080/~beick",
      PostalAddress := Concatenation( [
            "Institut Computational Mathematics\n",
            "TU Braunschweig\n",
            "Pockelsstr. 14\n D-38106 Braunschweig\n Germany" ] ),
      Place         := "Braunschweig",
      Institution   := "TU Braunschweig"),

    rec(
      LastName      := "O'Brien",
      FirstNames    := "Eamonn",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "obrien@math.auckland.ac.nz",
      WWWHome       := "http://www.math.auckland.ac.nz/~obrien",
      PostalAddress := Concatenation( [
            "Department of Mathematics\n",
            "University of Auckland\n",
            "Private Bag 92019\n Auckland\n New Zealand\n" ] ),
      Place         := "Auckland",
      Institution   := "University of Auckland"
    ) 
],

Status := "accepted",
CommunicatedBy := "Derek F. Holt (Warwick)",
AcceptDate := "09/2000",

README_URL := "http://www-public.tu-bs.de:8080/~beick/soft/autpgrp/README",
PackageInfoURL := "http://www-public.tu-bs.de:8080/~beick/soft/autpgrp/PackageInfo.g",

AbstractHTML := 
"The <span class=\"pkgname\">AutPGrp</span> package introduces a new function to compute the automorphism group of a finite $p$-group. The underlying algorithm is a refinement of the methods described in O'Brien (1995). In particular, this implementation is more efficient in both time and space requirements and hence has a wider range of applications than the ANUPQ method. Our package is written in GAP code and it makes use of a number of methods from the GAP library such as the MeatAxe for matrix groups and permutation group functions. We have compared our method to the others available in GAP. Our package usually out-performs all but the method designed for finite abelian groups. We note that our method uses the small groups library in certain cases and hence our algorithm is more effective if the small groups library is installed.",
 
PackageWWWHome := "http://www-public.tu-bs.de:8080/~beick/so.html",
               
PackageDoc := rec(
  BookName  := "AutPGrp",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Computing the Automorphism Group of a p-Group",
  Autoload  := true),

Dependencies := rec(
  GAP := ">=4.3",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := [] ),

AvailabilityTest := ReturnTrue,
BannerString := "Loading autpgrp 1.4 ... \n",
Autoload := true,
Keywords := ["p-group", "automorphism group"]

));


