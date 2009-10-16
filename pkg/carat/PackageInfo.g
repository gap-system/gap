#############################################################################
##
##  PackageInfo.g for Carat
##

SetPackageInfo( rec(

PackageName := "Carat",

Subtitle := "Interface to CARAT, a crystallographic groups package",

Version := "2.0.1",

Date := "18/12/2006",

ArchiveURL := 
  "http://www.itap.physik.uni-stuttgart.de/~gaehler/gap/Carat/carat-2.0.1",

ArchiveFormats := ".zoo",

Persons := [
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
  )
],

Status := "accepted",

CommunicatedBy := "Herbert Pahlings (Aachen)",

AcceptDate := "02/2000",

README_URL := 
  "http://www.itap.physik.uni-stuttgart.de/~gaehler/gap/Carat/README.carat",
PackageInfoURL := 
  "http://www.itap.physik.uni-stuttgart.de/~gaehler/gap/Carat/PackageInfo.g",

AbstractHTML := 
"This package provides <span class=\"pkgname\">GAP</span> interface \
routines to some of the stand-alone programs of <a \
href=\"http://wwwb.math.rwth-aachen.de/carat\">CARAT</a>, a package \
for the computation with crystallographic groups. CARAT is to a large \
extent complementary to the <span class=\"pkgname\">GAP</span> package \
<span class=\"pkgname\">Cryst</span>. In particular, it provides \
routines for the computation of normalizers and conjugators of \
finite unimodular groups in GL(n,Z), and routines for the computation \
of Bravais groups, which are all missing in <span class=\"pkgname\">Cryst\
</span>. A catalog of Bravais groups up to dimension 6 is also provided.",

PackageWWWHome := 
  "http://www.itap.physik.uni-stuttgart.de/~gaehler/gap/packages.php",

PackageDoc  := rec(
  BookName  := "Carat",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Interface to CARAT, a crystallographic groups package",
  Autoload  := true
),

Dependencies := rec(
  GAP := ">=4.2",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := function()
  local path;
  # Carat is available only on UNIX
  if not ARCH_IS_UNIX() then
     Info( InfoWarning, 3, "Package Carat is available only on UNIX" );
     return false;
  fi;  
  # test the existence of a compiled binary; since there are
  # so many, we do not test for all of them, hoping for the best
  path := DirectoriesPackagePrograms( "carat" );
  if Filename( path, "Z_equiv" ) = fail then
     Info( InfoWarning, 3, "Package Carat: The binaries must be compiled" );
     return false;
  fi;
  return true;
end,

Autoload := true,

#TestFile := "tst/testall.g",

Keywords := [ "crystallographic groups", "finite unimodular groups", "GLnZ" ]

));

