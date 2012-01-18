#############################################################################
##
##  PackageInfo.g        GAP4 Package `Polenta'                Bjoern Assmann
##  

SetPackageInfo( rec(

PackageName := "Polenta",
Subtitle := "Polycyclic presentations for matrix groups",
Version := "1.3",
Date := "23/09/2011",
##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "1.3">
##  <!ENTITY RELEASEDATE "23 September 2011">
##  <#/GAPDoc>

Persons := [

  rec(
      LastName      := "Assmann",
      FirstNames    := "Bjoern",
      IsAuthor      := true,
      WWWHome       := "http://www.cs.st-andrews.ac.uk/~bjoern/"
  ),

  rec( LastName      := "Horn",
       FirstNames    := "Max",
       IsAuthor      := false,
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

Status := "accepted",
CommunicatedBy := "Charles Wright (Eugene)",
AcceptDate := "08/2005",

PackageWWWHome := "http://www.icm.tu-bs.de/ag_algebra/software/Polenta/",

ArchiveFormats := ".tar.gz .tar.bz2",
ArchiveURL     := Concatenation( ~.PackageWWWHome, "polenta-", ~.Version ),
README_URL     := Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),

AbstractHTML := 
"The <span class=\"pkgname\">Polenta</span> package provides  methods to compute polycyclic presentations of matrix groups (finite or infinite). As a by-product, this package gives some functionality to compute certain module series for modules of solvable groups. For example, if G is a rational polycyclic matrix group, then we can compute the radical series of the natural Q[G]-module Q^d.",

PackageDoc := rec(          
  BookName  := "polenta",
  ArchiveURLSubset := [ "doc" ],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Polycyclic presentations for matrix groups",
  Autoload  := true),

Dependencies := rec(
  GAP := ">= 4.4",
  NeededOtherPackages := [[ "polycyclic", "2.0" ],
                          [ "alnuth" , "2.2.3"],
                          [ "radiroot", "2.4" ],
                         ],
  SuggestedOtherPackages := [ ["aclib", "1.0"]],
), 

AvailabilityTest := ReturnTrue,             
BannerString := Concatenation([ "Loading Polenta ", ~.Version, " ... \n" ]),     
Autoload := true,
TestFile := "tst/testall.g",
Keywords := [
  "polycyclic presentations",
  "matrix groups",
  "test solvability",
  "triangularizable subgroup",
  "unipotent subgroup",
  "radical series",
  "composition series of triangularizable groups"
]

));

#############################################################################
##
#E
