#############################################################################
##
#W  PackageInfo.g              The LAGUNA package                Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
#H  $Id: PackageInfo.g,v 1.24 2009/05/30 21:13:40 alexk Exp $
##
#############################################################################

SetPackageInfo( rec(

PackageName := "LAGUNA",
Subtitle := "Lie AlGebras and UNits of group Algebras",
Version := "3.5.0",
Date := "30/05/2009",
ArchiveURL := "http://www.cs.st-andrews.ac.uk/~alexk/laguna/laguna-3.5.0",
ArchiveFormats := ".tar.gz .tar.bz2 -win.zip",

#TextFiles := ["init.g", ......],
#BinaryFiles := ["doc/manual.dvi", ......],

Persons := [
  rec(
    LastName      := "Bovdi",
    FirstNames    := "Victor",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "vbovdi@math.klte.hu",
    PostalAddress := Concatenation( [ 
                     "Institute of Mathematics and Informatics\n", 
                     "University of Debrecen\n", 
                     "P.O.Box 12, Debrecen\n", 
                     "H-4010 Hungary" ] ),
    Place         := "Debrecen",
    Institution   := "University of Debrecen"
     ),
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
    LastName := "Rossmanith",
    FirstNames := "Richard",
    IsAuthor := true,
    IsMaintainer := false,
    Email := "richard.rossmanith@d-fine.de",
    PostalAddress := Concatenation( [
                     "d-fine GmbH\n",
                     "Mergenthalerallee 55\n",
                     "65760 Eschborn/Frankfurt, Germany" ] ),
    Place         := "Frankfurt",
    Institution   := "d-fine GmbH"              
     ),
  rec( 
    LastName      := "Schneider",
    FirstNames    := "Csaba",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "csaba.schneider@sztaki.hu",
    WWWHome       := "http://www.sztaki.hu/~schneider",
    PostalAddress := Concatenation( [
                     "Csaba Schneider\n",
                     "Informatics Laboratory\n",
                     "Computer and Automation Research Institute\n",
                     "The Hungarian Academy of Sciences\n",
	                 "1111 Budapest, Lagymanyosi u. 11, Hungary" ]),
    Place         := "Budapest",
    Institution   := "Computer and Automation Research Institute"
     )
],

Status := "accepted",
CommunicatedBy := "Herbert Pahlings (Aachen)",
AcceptDate := "06/2003",

README_URL := "http://www.cs.st-andrews.ac.uk/~alexk/laguna/README.laguna",
PackageInfoURL := "http://www.cs.st-andrews.ac.uk/~alexk/laguna/PackageInfo.g",
AbstractHTML := "The <span class=\"pkgname\">LAGUNA</span> package replaces the <span class=\"pkgname\">LAG</span> package and provides functionality for calculation of the normalized unit group of the modular group algebra of the finite p-group and for investigation of Lie algebra associated with group algebras and other associative algebras.",
PackageWWWHome := "http://www.cs.st-andrews.ac.uk/~alexk/laguna.htm",
                  
PackageDoc := rec(
  BookName := "LAGUNA",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "Lie AlGebras and UNits of group Algebras",
  Autoload := true
),

Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [ ["GAPDoc", ">= 0.99999"] ],
  SuggestedOtherPackages := [ ["Sophus", ">= 1.2"] ],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,
Autoload := true,
#TestFile := "tst/testall.g",

Keywords := ["group ring", "modular group algebra", "Lie algebra", "unit group"]

));