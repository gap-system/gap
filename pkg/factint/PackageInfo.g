####################################################################################################
##
##  PackageInfo.g                         GAP4 Package `FactInt'                         Stefan Kohl
##  
####################################################################################################

SetPackageInfo( rec(

PackageName      := "FactInt",
Subtitle         := "Advanced Methods for Factoring Integers", 
Version          := "1.5.3",
Date             := "16/06/2011",
ArchiveURL       := "http://www.gap-system.org/DevelopersPages/StefanKohl/factint/factint-1.5.3",
ArchiveFormats   := "-win.zip", # ".tar.gz" when providing text files with UNIX-style line breaks
Persons          := [
                      rec( LastName      := "Kohl",
                           FirstNames    := "Stefan",
                           IsAuthor      := true,
                           IsMaintainer  := true,
                           Email         := "stefan@mcs.st-and.ac.uk",
                           WWWHome       := "http://www.gap-system.org/DevelopersPages/StefanKohl/",
                           PostalAddress := Concatenation("Department of Mathematics\n",
                                                          "University of Vlora\n",
                                                          "Lagjja: Pavaresia\n",
                                                          "Vlore / Albania"),
                           Place         := "Vlore / Albania",
                           Institution   := "University of Vlora"
                         )
                    ],
Status           := "accepted",
CommunicatedBy   := "Mike Atkinson (St. Andrews)",
AcceptDate       := "07/1999",
PackageWWWHome   := "http://www.gap-system.org/DevelopersPages/StefanKohl/factint.html",
README_URL       := "http://www.gap-system.org/DevelopersPages/StefanKohl/factint/README.factint",
PackageInfoURL   := "http://www.gap-system.org/DevelopersPages/StefanKohl/factint/PackageInfo.g",
AbstractHTML     := Concatenation("This package provides routines for factoring integers, ",
                                  "in particular:</p>\n<ul>\n  <li>Pollard's <em>p</em>-1</li>\n",
                                  "  <li>Williams' <em>p</em>+1</li>\n  <li>Elliptic Curves ",
                                  "Method (ECM)</li>\n  <li>Continued Fraction Algorithm ",
                                  "(CFRAC)</li>\n  <li>Multiple Polynomial Quadratic Sieve ",
                                  "(MPQS)</li>\n</ul>\n<p>It also provides access to Richard P. ",
                                  "Brent's tables of factors of integers of the form ",
                                  "<em>b</em>^<em>k</em> +/- 1."),
PackageDoc       := rec(
                         BookName         := "FactInt",
                         ArchiveURLSubset := ["doc"],
                         HTMLStart        := "doc/chap0.html",
                         PDFFile          := "doc/manual.pdf",
                         SixFile          := "doc/manual.six",
                         LongTitle        := "A GAP4 Package for FACToring INTegers",
                         Autoload         := true
                       ),
Dependencies     := rec(
                         GAP                    := ">=4.4.9",
                         NeededOtherPackages    := [ ["GAPDoc",">=1.0"] ],
                         SuggestedOtherPackages := [ ],
                         ExternalConditions     := [ ]
                       ),
AvailabilityTest := ReturnTrue,
BannerString     := Concatenation( "\nLoading FactInt ", ~.Version,
                                   " (Routines for Integer Factorization )",
                                   "\nby Stefan Kohl, stefan@mcs.st-and.ac.uk\n\n" ),
Autoload         := true,
TestFile         := "factint.tst",
Keywords         := [ "Integer factorization", "ECM", "Elliptic Curves Method",
                      "MPQS", "Multiple Polynomial Quadratic Sieve", "CFRAC",
                      "Continued Fraction Algorithm", "Pollard's p-1", "Williams' p+1",
                      "Cunningham Tables", "Richard P. Brent's Factor Tables" ]

) );

####################################################################################################
##
#E  PackageInfo.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here