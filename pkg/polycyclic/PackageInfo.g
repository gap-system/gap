#############################################################################
##
#W  PackageInfo.g       GAP 4 Package `polycyclic'               Bettina Eick
#W                                                              Werner Nickel
#W                                                                   Max Horn
##  
#H  @(#)$Id: PackageInfo.g,v 1.33 2011/06/17 13:57:49 gap Exp $
##

SetPackageInfo( rec(

PackageName := "Polycyclic",
Subtitle    := "Computation with polycyclic groups",
Version     := "2.8.1",
Date        := "24/05/2011",

Persons          := [ 
  rec( LastName      := "Eick",
       FirstNames    := "Bettina",
       IsAuthor      := true,
       IsMaintainer  := true,
       Email         := "beick@tu-bs.de",
       PostalAddress := Concatenation(
               "AG Algebra und Diskrete Mathematik\n",
               "Institut Computational Mathematics\n",
               "TU Braunschweig\n",
               "Pockelsstr. 14\n",
               "D-38106 Braunschweig\n",
               "Germany" ),
       Place         := "Braunschweig",
       Institution   := "TU Braunschweig"),

  rec( LastName      := "Nickel",
       FirstNames    := "Werner",
       IsAuthor      := true,
       IsMaintainer  := false,
       Email         := "nickel@mathematik.tu-darmstadt.de",
       WWWHome       := "http://www.mathematik.tu-darmstadt.de/~nickel",
       PostalAddress := Concatenation( 
               "Fachbereich Mathematik\n",
               "TU Darmstadt\n",
               "Schlossgartenstr. 7\n",
               "64289 Darmstadt\n",
               "Germany" ),
       Place         := "Darmstadt, Germany",
       Institution   := "Fachbereich Mathematik, TU Darmstadt"),

  rec( LastName      := "Horn",
       FirstNames    := "Max",
       IsAuthor      := true,
       IsMaintainer  := true,
       Email         := "mhorn@tu-bs.de",
       WWWHome       := "http://www.icm.tu-bs.de/~mhorn",
       PostalAddress := Concatenation(
               "AG Algebra und Diskrete Mathematik\n",
               "Institut Computational Mathematics\n",
               "TU Braunschweig\n",
               "Pockelsstr. 14\n",
               "D-38106 Braunschweig\n",
               "Germany" ),
       Place         := "Braunschweig",
       Institution   := "TU Braunschweig")
    ],

Status              := "accepted",
CommunicatedBy   := "Charles Wright (Eugene)",
AcceptDate       := "01/2004",

PackageWWWHome := "http://www.icm.tu-bs.de/ag_algebra/software/polycyclic/",

ArchiveFormats := ".tar.gz .tar.bz2",
ArchiveURL     := Concatenation( ~.PackageWWWHome, "polycyclic-", ~.Version ),
README_URL     := Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),

AbstractHTML     :=
"This package provides various algorithms for computations with polycyclic groups defined by polycyclic presentations.",


PackageDoc     := rec(
                BookName  := "polycyclic",
                ArchiveURLSubset   := [ "doc", "htm" ],
                HTMLStart := "htm/chapters.htm",
                PDFFile   := "doc/manual.pdf",
                SixFile   := "doc/manual.six",
                LongTitle := "Computation with polycyclic groups",
                Autoload  := true),

Dependencies    := rec(
                GAP                    := ">= 4.4",
                NeededOtherPackages    := [["alnuth", "1.0"],
                                           ["autpgrp","1.0"]],
                SuggestedOtherPackages := [["nq","1.0"]],
                ExternalConditions     := [ ]),

AvailabilityTest := ReturnTrue,
BannerString     := Concatenation( "Loading polycyclic ",
                            String( ~.Version ), " ...\n" ),
Autoload         := true,
Keywords         := [ 
 "finitely generated nilpotent groups",
 "metacyclic groups",
 "collection",
 "consistency check",
 "solvable word problem",
 "normalizers","centralizers", "intersection",
 "conjugacy problem",
 "subgroups of finite index",
 "torsion subgroup", "finite subgroups",
 "extensions",
 "complements",
 "cohomology groups",
 "orbit-stabilizer algorithms",
 "fitting subgroup",
 "center",
 "infinite groups",
 "polycyclic generating sequence",
 "polycyclic presentation",
 "polycyclic group",
 "polycyclically presented group",
 "polycyclic presentation",
 "maximal subgroups", 
 "Schur cover",
 "Schur multiplicator" ]
));

