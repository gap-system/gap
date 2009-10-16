#############################################################################
##  
##  PackageInfo.g for the package `float'                   Laurent Bartholdi
##
## $Id: PackageInfo.g,v 1.1 2008/04/21 18:38:07 gap Exp $
##
SetPackageInfo( rec(
PackageName := "Float",
Subtitle := "Integration of mpfr and mpfi in GAP",
Version := "0.0",
## <#GAPDoc Label="Version">
## 0.0
## <#/GAPDoc>
Date := "21/4/2008",
ArchiveURL := Concatenation("http://mad.epfl.ch/~laurent/Float/float-",~.Version),
ArchiveFormats := ".tar.gz .zoo",
Persons := [
  rec( 
    LastName      := "Bartholdi",
    FirstNames    := "Laurent",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "laurent.bartholdi@gmail.com",
    WWWHome       := "http://mad.epfl.ch/~laurent",
    PostalAddress := Concatenation( [
                       "EPFL SB SMA IMB\n",
                       "Station 8\n",
                       "1015 Lausanne\n",
                       "Switzerland" ] ),
    Place         := "Lausanne",
    Institution   := "EPFL"
  )
],

Status := "started",

README_URL := "http://mad.epfl.ch/~laurent/Float/README.float",
PackageInfoURL := "http://mad.epfl.ch/~laurent/Float/PackageInfo.g",
AbstractHTML := "The <span class=\"pkgname\">Float</span> package allows \
                    GAP to manipulate floating-point numbers with arbitrary \
                    precision. It is based on MPFR",
PackageWWWHome := "http://mad.epfl.ch/~laurent/Float/",

PackageDoc := rec(
  BookName  := "Float",
  Archive := Concatenation("http://mad.epfl.ch/~laurent/FR/floatdoc-",~.Version,".tar.gz"),
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Floating-point numbers",
  Autoload  := true
),

Dependencies := rec(
  GAP := ">=4.4.9",
  NeededOtherPackages := [["GAPDoc",">=1.0"]],
  SuggestedOtherPackages := [],
  ExternalConditions := []                      
),

AvailabilityTest := ReturnTrue,

Autoload := false,
TestFile := "tst/testall.g",
Keywords := ["floating-point"]
));
