#############################################################################
##  
##  PackageInfo.g                  NQL                          René Hartung 
##  
#H   @(#)$Id: PackageInfo.g,v 1.21 2009/08/31 07:55:22 gap Exp $ 
##
##  Based on Frank Luebeck's template for PackageInfo.g.
##  

SetPackageInfo( rec(

PackageName := "NQL",
Subtitle := "Nilpotent Quotients of L-Presented Groups",
Version := "0.08",
Date    := "31/08/2009",

Persons := [
  rec(
  LastName      := "Hartung",
  FirstNames    := "René",
  IsAuthor      := true,
  IsMaintainer  := true,
  Email         := "r.hartung [ed] tu-braunschweig.de",
  WWWHome       := "http://www-public.tu-bs.de:8080/~y0019492/",
  PostalAddress := Concatenation( "University of Braunschweig\n",
                                  "Institute of Computational Mathematics \n",
                                  "Pockelstrasse 14\n",
                                  "38106 Braunschweig\n",
                                  "Germany" ),
  Place         := "Braunschweig, Germany",
  Institution   := "Institute of Computational Mathematics, University of Braunschweig"
  )
],

Status         := "accepted",
CommunicatedBy := "Alexander Konovalov (St Andrews)",
AcceptDate     := "02/2009",

PackageWWWHome := "http://www-public.tu-bs.de:8080/~y0019492/pub/nql/",

ArchiveFormats := ".tar.gz",
ArchiveURL     := Concatenation( ~.PackageWWWHome, "nql-",~.Version),
README_URL     := Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),

AbstractHTML   := Concatenation( 
               "The NQL Package defines new GAP objects to work with ",
               "L-presented groups. The main part of the package is a ",
               "nilpotent quotient algorithm for L-presented groups. ",
               "That is an algorithm which takes as input an L-presented ",
               "group L and a positive integer c. It computes a polycyclic ",
               "presentation for the lower central series quotient ",
               "L/gamma_c(L)."),

                  
PackageDoc := rec(
  BookName  := "NQL",
  ArchiveURLSubset := [ "doc", "htm" ],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Nilpotent Quotient Algorithm for L-presented Groups",
  Autoload  := false 
),

AvailabilityTest := function()
    return true;
end,

Dependencies := rec(
  GAP                    := ">= 4.4",
  NeededOtherPackages    := [ ["polycyclic", ">= 2.5"], 
                              ["FGA", ">= 1.1.0.1"],
                              ["AutPGrp", ">= 1.4"] ],
  SuggestedOtherPackages := [ ["ParGAP", ">= 1.1.2" ] ],
# SuggestedOtherPackages := [ ["FR", ">= 0.90" ] ],
  ExternalConditions     := [ ]
),

Autoload := false,

Keywords := [ "nilpotent quotient algorithm",
              "nilpotent presentations",
              "finitely generated groups",
              "Grigorchuk group",
              "L-presented groups",
              "recursively presented groups",
              "infinite presentations",
              "commutators",
              "lower central series",
              "Free Engel groups", "Free Burnside groups",
              "computational", "parallel computing" ]
));
