#############################################################################
##  
##  PackageInfo.g for the package `float'                   Laurent Bartholdi
##
## $Id: PackageInfo.g,v 1.2 2011/04/08 14:26:30 gap Exp $
##
SetPackageInfo( rec(
PackageName := "Float",
Subtitle := "Integration of mpfr and mpfi in GAP",
Version := "0.1",
## <#GAPDoc Label="Version">
## 0.1
## <#/GAPDoc>
Date := "08/03/2011",
ArchiveURL := Concatenation("http://www.uni-math.gwdg.de/laurent/Float/float-",~.Version),
ArchiveFormats := ".tar.gz .zoo",
Persons := [
  rec( 
    LastName      := "Bartholdi",
    FirstNames    := "Laurent",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "laurent.bartholdi@gmail.com",
    WWWHome       := "http://www.uni-math.gwdg.de/laurent",
    PostalAddress := Concatenation( [
                       "Mathematisches Institut\n",
                       "Bunsenstraße 3—5\n",
                       "D-37073 Göttingen\n",
                       "Germany" ] ),
    Place         := "Göttingen",
    Institution   := "Georg-August Universität zu Göttingen"
  )
],

Status := "started",

README_URL := "http://www.uni-math.gwdg.de/laurent/Float/README.float",
PackageInfoURL := "http://www.uni-math.gwdg.de/laurent/Float/PackageInfo.g",
AbstractHTML := "The <span class=\"pkgname\">Float</span> package allows \
                    GAP to manipulate floating-point numbers with arbitrary \
                    precision. It is based on MPFR",
PackageWWWHome := "http://www.uni-math.gwdg.de/laurent/Float/",

PackageDoc := rec(
  BookName  := "Float",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Floating-point numbers",
  Autoload  := true
),

Dependencies := rec(
  GAP := ">=4.5.0",
  NeededOtherPackages := [["GAPDoc",">=1.0"]],
  SuggestedOtherPackages := [],
  ExternalConditions := []                      
),

AvailabilityTest := ReturnTrue,

Autoload := false,
TestFile := "tst/testall.g",
Keywords := ["floating-point"]
));
