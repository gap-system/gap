#############################################################################
##
##  PackageInfo.g        GAP4 Package `Polenta'                Bjoern Assmann
##  

SetPackageInfo( rec(

PackageName := "Polenta",
Subtitle := "Polycyclic presentations for matrix groups",
Version := "1.2.7",
Date := "17/06/2007",

ArchiveURL := Concatenation([ 
"http://www.cs.st-andrews.ac.uk/~bjoern/software/Polenta/Polenta-", 
~.Version]),
ArchiveFormats := ".tar.gz",


Persons := [

  rec(
      LastName      := "Assmann",
      FirstNames    := "Bjoern",
      IsAuthor      := true,
      WWWHome       := "http://www.dcs.st-and.ac.uk/~bjoern"
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


README_URL := "http://www.cs.st-andrews.ac.uk/~bjoern/software/Polenta/README",
PackageInfoURL := "http://www.cs.st-andrews.ac.uk/~bjoern/software/Polenta/PackageInfo.g",

AbstractHTML := 
"The <span class=\"pkgname\">Polenta</span> package provides  methods to compute polycyclic presentations of matrix groups (finite or infinite). As a by-product, this package gives some functionality to compute certain module series for modules of solvable groups. For example, if G is a rational polycyclic matrix group, then we can compute the radical series of the natural Q[G]-module Q^d.",

PackageWWWHome := "http://www.cs.st-andrews.ac.uk/~bjoern/software/Polenta",

PackageDoc := rec(          
  BookName  := "Polenta",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Polycyclic presentations for matrix groups",
  Autoload  := true),

Dependencies := rec(
  GAP := ">= 4.3fix4",
  NeededOtherPackages := [[ "polycyclic", ">=1.1" ],
                          [ "alnuth" , "2.2.3"], ],
  SuggestedOtherPackages := [ ["aclib", "1.0"]],
), 

AvailabilityTest := ReturnTrue,             
BannerString := Concatenation([ 
"Loading Polenta ",
~.Version,
" ... \n" ]),     
Autoload := true,
TestFile := "tst/testall.g",
Keywords := ["polycyclic presentations", "matrix groups", "test solvability", "triangularizable subgroup", "unipotent subgroup", "radical series", "composition series of triangularizable groups" ]

));

#############################################################################
##
#E













