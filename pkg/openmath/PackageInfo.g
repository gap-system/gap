###########################################################################
##
#W    PackageInfo.g            OpenMath Package            Marco Costantini
##                                                      Alexander Konovalov
##                                                              Max Nicosia
##                                                           Andrew Solomon
##
#Y    Copyright (C) 1999, 2000, 2001, 2006, 2007-2011
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##    PackageInfo.g file
##
SetPackageInfo( rec(
PackageName := "OpenMath",
Subtitle := "OpenMath functionality in GAP",

Version := "11.0.0",
Date := "28/10/2011",
##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "11.0.0">
##  <!ENTITY RELEASEDATE "28 October 2011">
##  <#/GAPDoc>


PackageWWWHome := "http://www.cs.st-andrews.ac.uk/~alexk/openmath/",

ArchiveURL := Concatenation( ~.PackageWWWHome, "openmath-", ~.Version ),
ArchiveFormats := ".tar.gz",

Persons := [
  rec(
    LastName      := "Costantini",
    FirstNames    := "Marco",
    IsAuthor      := true,
    IsMaintainer  := false,
    PostalAddress := "no address known"
  ),
 
  rec(
    LastName      := "Konovalov",
    FirstNames    := "Alexander",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "alexk@mcs.st-andrews.ac.uk",
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
    LastName      := "Nicosia",
    FirstNames    := "Max",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "ln73@st-andrews.ac.uk",
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

Status := "accepted",
CommunicatedBy := "David Joyner (Annapolis)",
AcceptDate := "08/2010",

AbstractHTML := 

"This package provides an <a href=\"http://www.openmath.org/\">OpenMath</a> \
phrasebook for <span class=\"pkgname\">GAP</span>. \
This package allows <span class=\"pkgname\">GAP</span> users to import \
and export mathematical objects encoded in OpenMath, for the purpose of \
exchanging them with other applications that are OpenMath enabled.",

README_URL := 
  Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL := 
  Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
  
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
  GAP := ">=4.4.12",
  # Needed packages:
  # GapDoc provides the function ParseTreeXMLString
  # IO is needed to generate random string from really random source 
  NeededOtherPackages := [ [ "GapDoc", ">= 1.3" ], 
                           [ "IO", ">= 3.0"] ],
  SuggestedOtherPackages := [ [ "MONOID", ">=3.0" ] ],
  ExternalConditions := [ ]
),

AvailabilityTest := ReturnTrue,

Autoload := false,

TestFile := "tst/testall.g",

Keywords := [ "OpenMath", "Phrasebook" ]

));


#############################################################################
#E
