#############################################################################
##  
##  PackageInfo.g for Cryst
##  

SetPackageInfo( rec(

PackageName := "Cryst",

Subtitle := "Computing with crystallographic groups",


Version := "4.1.6",

Date := "31/9/2007",

ArchiveURL := 
  "http://www.itap.physik.uni-stuttgart.de/~gaehler/gap/Cryst/cryst-4.1.6",

ArchiveFormats := ".zoo",

Persons := [
  rec(
    LastName := "Eick",
    FirstNames := "Bettina",
    IsAuthor := true,
    IsMaintainer := true,
    Email := "beick@tu-bs.de",
    WWWHome := "http://www-public.tu-bs.de:8080/~beick/",
    #PostalAddress := "",           
    Place := "Braunschweig",
    Institution := "Institut Computational Mathematics, TU Braunschweig"
  ),
  rec(
    LastName := "Gähler",
    FirstNames := "Franz",
    IsAuthor := true,
    IsMaintainer := true,
    Email := "gaehler@itap.physik.uni-stuttgart.de",
    WWWHome := "http://www.itap.physik.uni-stuttgart.de/~gaehler/",
    #PostalAddress := "",           
    Place := "Stuttgart",
    Institution := "ITAP, Universität Stuttgart"
  ),
  rec(
    LastName := "Nickel",
    FirstNames := "Werner",
    IsAuthor := true,
    IsMaintainer := true,
    Email := "nickel@mathematik.tu-darmstadt.de",
    WWWHome := "http://www.mathematik.tu-darmstadt.de/~nickel/",
    #PostalAddress := "",           
    Place := "Darmstadt",
    Institution := "Fachbereich 4, AG 2, TU Darmstadt"
  )
],

Status := "accepted",

CommunicatedBy := "Herbert Pahlings (Aachen)",

AcceptDate := "02/2000",

README_URL := 
  "http://www.itap.physik.uni-stuttgart.de/~gaehler/gap/Cryst/README.cryst",
PackageInfoURL := 
  "http://www.itap.physik.uni-stuttgart.de/~gaehler/gap/Cryst/PackageInfo.g",

AbstractHTML := 
"This package, previously known as <span class=\"pkgname\">CrystGAP</span>, \
provides a rich set of methods for the computation with affine \
crystallographic groups, in particular space groups. Affine \
crystallographic groups are fully supported both in representations \
acting from the right or from the left, the latter one being preferred \
by crystallographers. Functions to determine representatives of all \
space group types of a given dimension are also provided. Where \
necessary, <span class=\"pkgname\">Cryst</span> can also make use of \
functionality provided by the package <span class=\"pkgname\">Carat</span>.",

PackageWWWHome := 
  "http://www.itap.physik.uni-stuttgart.de/~gaehler/gap/packages.php",

PackageDoc  := rec(
  BookName  := "Cryst",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Computing with crystallographic groups",
  Autoload  := true
),

Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [ [ "Carat", ">=1.1" ],
                              [ "polycyclic", ">=1.0" ],
                              [ "XGAP", ">=4.18" ] 
  ],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,

Autoload := true,
BannerString := "Loading Cryst 4.4.1 ... \n",

#TestFile := "tst/testall.g",

Keywords := [ "crystallographic groups", 
              "affine crystallographic groups",
              "space groups",
              "color groups",
              "point group",
              "Wyckoff positions",
              "International Tables for Cystallography",
              "maximal subgroups",
              "normalizer" ]
));
