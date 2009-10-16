####################################################################################################
##
##  PackageInfo.g                         GAP4 Package `FactInt'                         Stefan Kohl
##  
#H  @(#)$Id: PackageInfo.g,v 1.31 2009/05/28 22:20:43 stefan Exp $
##

SetPackageInfo( rec(

PackageName      := "FactInt",
Subtitle         := "Advanced Methods for Factoring Integers", 
Version          := "1.5.2",
Date             := "26/09/2007",
ArchiveURL       := "http://univlora.edu.al/personel/kohl/factint/factint-1.5.2",
ArchiveFormats   := ".tar.gz",
Persons          := [
                      rec( LastName      := "Kohl",
                           FirstNames    := "Stefan",
                           IsAuthor      := true,
                           IsMaintainer  := true,
                           Email         := "kohl@univlora.edu.al",
                           WWWHome       := "http://univlora.edu.al/personel/kohl/",
                           PostalAddress := Concatenation("Departamenti i Matematikes\n",
                                                          "Universiteti \"Ismail Qemali\" ",
                                                          "Vlore\nLagja: Pavaresia\n",
                                                          "Vlore / Albania"),
                           Place         := "Vlore / Albania",
                           Institution   := "University of Vlora"
                         )
                    ],
Status           := "accepted",
CommunicatedBy   := "Mike Atkinson (St. Andrews)",
AcceptDate       := "07/1999",
PackageWWWHome   := "http://univlora.edu.al/personel/kohl/factint.html",
README_URL       := "http://univlora.edu.al/personel/kohl/factint/README.factint",
PackageInfoURL   := "http://univlora.edu.al/personel/kohl/factint/PackageInfo.g",
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
                                   "\nby Stefan Kohl, kohl@univlora.edu.al\n\n" ),
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