####################################################################################################
##
##  PackageInfo.g                         GAP4 Package `RCWA'                            Stefan Kohl
##  
#H  @(#)$Id: PackageInfo.g,v 1.112 2009/05/28 22:18:44 stefan Exp $
##

SetPackageInfo( rec(

PackageName      := "RCWA",
Subtitle         := "Residue-Class-Wise Affine Groups",
Version          := "3.dev",
Date             := "15/02/2009",
ArchiveURL       := "http://univlora.edu.al/personel/kohl/rcwa/rcwa-3.0.0",
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
CommunicatedBy   := "Bettina Eick (Braunschweig)",
AcceptDate       := "04/2005",
PackageWWWHome   := "http://univlora.edu.al/personel/kohl/rcwa.html",
README_URL       := "http://univlora.edu.al/personel/kohl/rcwa/README.rcwa",
PackageInfoURL   := "http://univlora.edu.al/personel/kohl/rcwa/PackageInfo.g",
AbstractHTML     := Concatenation("This package provides implementations of algorithms and ",
                                  "methods for computing in certain infinite permutation groups. ",
                                  "For an abstract, see ",
                                  "<a href = \"",~.PackageWWWHome,"\">here</a>."),
PackageDoc       := rec(
                         BookName         := "RCWA",
                         ArchiveURLSubset := ["doc"],
                         HTMLStart        := "doc/chap0.html",
                         PDFFile          := "doc/manual.pdf",
                         SixFile          := "doc/manual.six",
                         LongTitle        := "[R]esidue-[C]lass-[W]ise [A]ffine groups",
                         Autoload         := true
                       ),
Dependencies     := rec(
                         GAP                    := ">=4.4.12",
                         NeededOtherPackages    := [ ["ResClasses",">=3.0.0"], ["GRAPE",">=4.0"],
                                                     ["Polycyclic",">=2.4"], ["GAPDoc",">=1.1"] ],
                         SuggestedOtherPackages := [ ], #[ ["FR",">=0.714285"] ],
                         ExternalConditions     := [ ]
                       ),
AvailabilityTest := ReturnTrue,
BannerString     := Concatenation( "\nLoading RCWA ", ~.Version,
                                   " ([R]esidue-[C]lass-[W]ise [A]ffine groups)",
                                   "\nby Stefan Kohl, kohl@univlora.edu.al\n\n" ),
Autoload         := false,
TestFile         := "tst/testall.g",
Keywords         := [ "infinite permutation groups", "geometric group theory",
                      "combinatorial group theory", "permutation groups over rings",
                      "residue-class-wise affine groups", "residue-class-wise affine mappings",
                      "Collatz conjecture", "3n+1 conjecture" ]

) );

####################################################################################################
##
#E  PackageInfo.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here