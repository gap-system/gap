####################################################################################################
##
##  PackageInfo.g                      GAP4 Package `ResClasses'                         Stefan Kohl
##
####################################################################################################

SetPackageInfo( rec(

PackageName      := "ResClasses",
Subtitle         := "Set-Theoretic Computations with Residue Classes",
Version          := "3.0.4",
Date             := "01/11/2011",
ArchiveURL       := Concatenation("http://www.gap-system.org/DevelopersPages/StefanKohl/",
                                  "resclasses/resclasses-3.0.4"),
ArchiveFormats   := "-win.zip", # ".tar.gz" when providing text files with UNIX-style line breaks
Persons          := [
                      rec( LastName      := "Kohl",
                           FirstNames    := "Stefan",
                           IsAuthor      := true,
                           IsMaintainer  := true,
                           Email         := "stefan@mcs.st-and.ac.uk",
                           WWWHome       := "http://www.gap-system.org/DevelopersPages/StefanKohl/"
                           # , PostalAddress := Concatenation("Department of Mathematics\n",
                           #                                "University of Vlora\n",
                           #                                "Lagjja: Pavaresia\n",
                           #                                "Vlore / Albania"),
                           # Place         := "Vlore / Albania",
                           # Institution   := "University of Vlora"
                         )
                    ],
Status           := "deposited",
PackageWWWHome   := "http://www.gap-system.org/DevelopersPages/StefanKohl/resclasses.html",
README_URL       := Concatenation("http://www.gap-system.org/DevelopersPages/StefanKohl/",
                                  "resclasses/README.resclasses"),
PackageInfoURL   := Concatenation("http://www.gap-system.org/DevelopersPages/StefanKohl/",
                                  "resclasses/PackageInfo.g"),
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
                         GAP                    := ">=4.5.2",
                         NeededOtherPackages    := [ ["GAPDoc",">=1.4"], ["Polycyclic",">=2.6"] ],
                         SuggestedOtherPackages := [ ],
                         ExternalConditions     := [ ]
                       ),
AvailabilityTest := ReturnTrue,
BannerString     := Concatenation( "\nLoading ResClasses ", ~.Version,
                                   " (Computations with Residue Classes)",
                                   "\nby Stefan Kohl, stefan@mcs.st-and.ac.uk\n\n" ),
Autoload         := false,
TestFile         := "tst/testall.g",
Keywords         := [ "residue classes", "integers", "number theory" ]

) );

####################################################################################################
##
#E  PackageInfo.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here