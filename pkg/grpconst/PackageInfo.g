#############################################################################
##  
##  PackageInfo.g for the package `GrpConst'                     Bettina Eick

SetPackageInfo( rec(

PackageName := "GrpConst",
Subtitle := "Constructing the Groups of a Given Order",
Version := "2.1",
Date := "19/11/2002",
ArchiveURL := "http://www-public.tu-bs.de:8080/~beick/soft/grpconst/grpconst-2.0",
ArchiveFormats := ".tar.gz",

Persons := [

 rec(
      LastName      := "Besche",
      FirstNames    := "Hans Ulrich",
      IsAuthor      := true,
      IsMaintainer  := true,
      Email         := "hubesche@tu-bs.de",
      WWWHome       := "http://www-public.tu-bs.de:8080/~hubesche",
      PostalAddress := Concatenation( [
            "Institut Computational Mathematics",
            "TU Braunschweig\n",
            "Pockelsstr. 14\n D-38106 Braunschweig\n Germany" ] ),
      Place         := "Braunschweig",
      Institution   := "TU Braunschweig"),

 rec(
      LastName      := "Eick",
      FirstNames    := "Bettina",
      IsAuthor      := true,
      IsMaintainer  := true,
      Email         := "b.eick@tu-bs.de",
      WWWHome       := "http://www-public.tu-bs.de:8080/~beick",
      PostalAddress := Concatenation( [
            "Institut Computational Mathematics",
            "TU Braunschweig\n",
            "Pockelsstr. 14\n D-38106 Braunschweig\n Germany" ] ),
      Place         := "Braunschweig",
      Institution   := "TU Braunschweig"),
],

Status := "accepted",
CommunicatedBy := "Charles Wright (Eugene)",
AcceptDate := "07/1999",

README_URL := "http://www-public.tu-bs.de:8080/~beick/soft/grpconst/README",
PackageInfoURL := "http://www-public.tu-bs.de:8080/~beick/soft/grpconst/PackageInfo.g",

AbstractHTML := 
"The <span class=\"pkgname\">GrpConst</span> package contains methods to construct up to isomorphism the groups of a given order. The FrattiniExtensionMethod constructs all soluble groups of a given order. On request it gives only those that are (or are not) nilpotent or supersolvable or that do (or do not) have normal Sylow subgroups for some given set of primes. The CyclicSplitExtensionMethod constructs all groups having a normal Sylow subgroup for orders of the type p^n *q. The method relies on the availability of a list of all groups of order p^n. The UpwardsExtensions algorithm takes as input a permutation group G and a positive integer s and returns a list of permutation groups, one for each extension of G by a soluble group of order a divisor of s. This method can used to construct the non-solvable groups of a given order by taking the perfect groups of certain orders as input for G. The programs in this package have been used to construct a large part of the Small Groups library.",

PackageWWWHome := "http://www-public.tu-bs.de:8080/~beick/so.html",
               
PackageDoc := rec(
  BookName  := "GrpConst",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Constructing the Groups of a Given Order",
  Autoload  := true),

Dependencies := rec(
  GAP := ">=4.3",
  NeededOtherPackages := [["autpgrp", "1.0"], ["irredsol", "0.9"]],
  SuggestedOtherPackages := [],
  ExternalConditions := [] ),

AvailabilityTest := ReturnTrue,
BannerString := "Loading GrpConst 2.0 ... \n",
Autoload := false,
Keywords := ["constructing groups of small order", 
             "Frattini extension method",
             "Cyclic split extension method",
             "Upwards extension method"]

));


