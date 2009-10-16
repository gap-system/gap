####################################################################################################
##
##  PackageInfo.g                      GAP4 Package `ResClasses'                         Stefan Kohl
##  
#H  @(#)$Id: PackageInfo.g,v 1.59 2009/05/28 22:19:57 stefan Exp $
##

SetPackageInfo( rec(

PackageName      := "ResClasses",
Subtitle         := "Set-Theoretic Computations with Residue Classes",
Version          := "3.dev",
Date             := "15/02/2009",
ArchiveURL       := "http://univlora.edu.al/personel/kohl/resclasses/resclasses-3.0.0",
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
Status           := "deposited",
PackageWWWHome   := "http://univlora.edu.al/personel/kohl/resclasses.html",
README_URL       := "http://univlora.edu.al/personel/kohl/resclasses/README.resclasses",
PackageInfoURL   := "http://univlora.edu.al/personel/kohl/resclasses/PackageInfo.g",
AbstractHTML     := Concatenation("This package permits to compute with set-theoretic ",
                                  "unions of residue classes of&nbsp;Z and a few other rings. ",
                                  "In particular it provides methods for computing unions, ",
                                  "intersections and differences of these sets."),
PackageDoc       := rec(
                         BookName         := "ResClasses",
                         ArchiveURLSubset := ["doc"],
                         HTMLStart        := "doc/chap0.html",
                         PDFFile          := "doc/manual.pdf",
                         SixFile          := "doc/manual.six",
                         LongTitle        := Concatenation("Computations with Residue Classes ",
                                                           "and their Set-Theoretic Unions"),
                         Autoload         := true
                       ),
Dependencies     := rec(
                         GAP                    := ">=4.4.12",
                         NeededOtherPackages    := [ ["GAPDoc",">=1.1"], ["Polycyclic",">=2.4"] ],
                         SuggestedOtherPackages := [ ],
                         ExternalConditions     := [ ]
                       ),
AvailabilityTest := ReturnTrue,
BannerString     := Concatenation( "\nLoading ResClasses ", ~.Version,
                                   " (Computations with Residue Classes)",
                                   "\nby Stefan Kohl, kohl@univlora.edu.al\n\n" ),
Autoload         := true,
TestFile         := "tst/testall.g",
Keywords         := [ "residue classes", "integers", "number theory" ]

) );

####################################################################################################
##
#E  PackageInfo.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here