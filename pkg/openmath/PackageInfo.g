#############################################################################
##
#W    PackageInfo.g       OpenMath Package             Marco Costantini
##
#H    @(#)$Id: PackageInfo.g,v 1.43 2009/05/26 16:42:07 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##    PackageInfo.g file
##

Revision.("openmath/PackageInfo.g") :=
    "@(#)$Id: PackageInfo.g,v 1.43 2009/05/26 16:42:07 alexk Exp $";


SetPackageInfo( rec(
PackageName := "OpenMath",
Subtitle := "OpenMath functionality in GAP",


Version := "10.0.4",
Date := "26/05/2009",


ArchiveURL := Concatenation([
 "http://www.cs.st-andrews.ac.uk/~alexk/openmath/openmath-",~.Version]),
ArchiveFormats := ".tar.gz .tar.bz2",


Persons := [
  rec(
    LastName      := "Costantini",
    FirstNames    := "Marco",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "costanti@science.unitn.it",
    # WWWHome       := "http://www-math.science.unitn.it/~costanti/",
    Place         := "Trento",
    Institution   := "Department of Mathematics, University of Trento"
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
    LastName      := "Solomon",
    FirstNames    := "Andrew",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "andrew@illywhacker.net",
    WWWHome       := "http://www.illywhacker.net/",
    PostalAddress := Concatenation( [
    "Faculty of IT\n",
    "University of Technology, Sydney\n",
    "Broadway, NSW 2007\n",
    "Australia" ] ),
    Institution   := "Faculty of Information Technology, University of Technology, Sydney."
  ),
],

Status := "deposited",
#CommunicatedBy := "",
#AcceptDate := "",

README_URL := "http://www.cs.st-andrews.ac.uk/~alexk/openmath/README",
PackageInfoURL := "http://www.cs.st-andrews.ac.uk/~alexk/openmath/PackageInfo.g",


AbstractHTML := 

"This package provides an <a href=\"http://www.openmath.org/\">OpenMath</a> \
phrasebook for <span class=\"pkgname\">GAP</span>. \
This package allows <span class=\"pkgname\">GAP</span> users to import \
and export mathematical objects encoded in OpenMath, for the purpose of \
exchanging them with other applications that are OpenMath enabled.",


PackageWWWHome := "http://www.cs.st-andrews.ac.uk/~alexk/openmath.htm",


PackageDoc := rec(
  BookName  := "OpenMath",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "OpenMath functionality in GAP",
  Autoload  := true
),

Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [ [ "GapDoc", ">= 1.2" ], [ "IO", ">= 3.0"] ],
  # GapDoc provides the function ParseTreeXMLString
  # IO is needed to generate random string from really random source 
  SuggestedOtherPackages := [ [ "MONOID", ">=3.0" ] ],
  ExternalConditions := [ ]
),

AvailabilityTest := ReturnTrue,

Autoload := false,

TestFile := "tst/test_new",

Keywords := [ "OpenMath", "OpenMath Phrasebook", "Phrasebook" ]

));


#############################################################################
#E
