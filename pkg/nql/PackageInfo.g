#############################################################################
##  
##  PackageInfo.g                  NQL                          René Hartung 
##  
#H   @(#)$Id: PackageInfo.g,v 1.24 2010/09/04 12:54:32 gap Exp $ 
##
##  Based on Frank Luebeck's template for PackageInfo.g.
##  

SetPackageInfo( rec(

PackageName := "NQL",
Subtitle := "Nilpotent Quotients of L-Presented Groups",
Version := "0.10",
Date    := "04/09/2010",

Persons := [
  rec(
  LastName      := "Hartung",
  FirstNames    := "René",
  IsAuthor      := true,
  IsMaintainer  := true,
  Email         := "rhartung [ed] uni-math.gwdg.de",
  WWWHome       := "http://www.uni-math.gwdg.de/rhartung",
  PostalAddress := Concatenation( "Georg-August Universität zu Göttingen\n",
                                  "Mathematisches Institut\n",
                                  "Bunsenstraße 3-5\n",
                                  "D-37073 Göttingen\n",
                                  "Germany" ),
  Place         := "Göttingen, Germany",
  Institution   := "Georg-August Universität zu Göttingen"
  )
],

Status         := "accepted",
CommunicatedBy := "Alexander Konovalov (St Andrews)",
AcceptDate     := "02/2009",

PackageWWWHome := "http://www.uni-math.gwdg.de/rhartung/pub/nql/",

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
                              ["FGA", ">= 1.1.0.1"] ], 
  SuggestedOtherPackages := [ ["ParGAP", ">= 1.1.2" ],
                              ["AutPGrp", ">= 1.4"],
                              ["ACE", ">= 5.0" ] ],
  ExternalConditions     := [ ]
),

Autoload := false,

Keywords := [ "nilpotent quotient algorithm",
              "nilpotent presentations",
              "finitely generated groups",
              "Grigorchuk group",
              "Gupta-Sidki group",
              "L-presented groups",
              "finite index subgroup of L-presented groups", 
              "coset enumeration",
              "recursively presented groups",
              "infinite presentations",
              "commutators",
              "lower central series",
              "Free Engel groups", "Free Burnside groups",
              "computational", "parallel computing" ]
));
