#############################################################################
##
#W  PackageInfo.g              The UnitLib package        Alexander Konovalov
#W                                                            Elena Yakimenko
##
#H  $Id: PackageInfo.g,v 1.10 2009/05/31 20:21:26 alexk Exp $
##
#############################################################################

SetPackageInfo( rec(

PackageName := "UnitLib",
Subtitle := "Library of normalized unit groups of modular group algebras",
Version := "3.0.0",
Date := "31/05/2009",
ArchiveURL := Concatenation( 
	[ "http://www.cs.st-andrews.ac.uk/~alexk/unitlib/unitlib-", ~.Version ] ),
ArchiveFormats := ".tar.gz .tar.bz2 -win.zip",

#TextFiles := ["init.g", ......],
#BinaryFiles := ["doc/manual.dvi", ......],

Persons := [
  rec(
    LastName      := "Konovalov",
    FirstNames    := "Alexander",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "konovalov@member.ams.org",
    WWWHome       := "http://www.cs.st-andrews.ac.uk/~alexk/",
    PostalAddress := Concatenation( [
                     "School of Computer Science\n",
                     "University of St Andrews\n",
                     "Jack Cole Building, North Haugh,\n",
                     "St Andrews, Fife, KY16 9SX, Scotland" ] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
     ),
  rec(
    LastName      := "Yakimenko",
    FirstNames    := "Elena",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "k-algebra@zsu.zp.ua",
    PostalAddress := Concatenation( [
                     "Department of Mathematics\n",
                     "Zaporozhye National University\n", 
                     "Zaporozhye, 69600 Ukraine" ] ),
    Place         := "Zaporozhye",
    Institution   := "Zaporozhye National University"
     )
],

Status := "accepted",
CommunicatedBy := "Bettina Eick (Braunschweig)",
AcceptDate := "03/2007",

README_URL := "http://www.cs.st-andrews.ac.uk/~alexk/unitlib/README.unitlib",
PackageInfoURL := "http://www.cs.st-andrews.ac.uk/~alexk/unitlib/PackageInfo.g",
AbstractHTML := "The <span class=\"pkgname\">UnitLib</span> package extends the <span class=\"pkgname\">LAGUNA</span> package and provides the library of normalized unit groups of modular group algebras of all finite p-groups of order not greater than 243 over the field of p elements.",
PackageWWWHome := "http://www.cs.st-andrews.ac.uk/~alexk/unitlib.htm",
                  
PackageDoc := rec(
  BookName := "UnitLib",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "The library of normalized unit groups of modular group algebras",
  Autoload := true
),

Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [ ["GAPDoc", ">= 0.99999"], 
                           ["LAGUNA", ">= 3.4"], 
                           ["qaos", ">= main-1.0.19"] ],
  SuggestedOtherPackages := [ ["SCSCP", ">=1.1.4"] ],
  ExternalConditions := [ "partially needs cURL (http://curl.haxx.se)" ]
),

AvailabilityTest := ReturnTrue,
Autoload := false,
#TestFile := "tst/testall.g",

Keywords := ["group ring", "modular group algebra", "normalized unit group"]

));