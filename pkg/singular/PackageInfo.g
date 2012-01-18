#############################################################################
##
#W    PackageInfo.g        Package singular            Willem de Graaf
#W                                                     Marco Costantini
##
#H    @(#)$Id: PackageInfo.g,v 1.22 2011/09/10 16:35:12 alexk Exp $
##
#Y    Copyright (C) 2003 Willem de Graaf and Marco Costantini
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##


SetPackageInfo( rec(
PackageName := "singular",
Subtitle := "The GAP interface to Singular",

PackageWWWHome := "http://www.gap-system.org/HostedGapPackages/singular/",

# on a new release, change the version/date twice here, in init.g and in 
# doc/singular.xml

Version := "11.08.11",
Date := "11/08/2011",

ArchiveURL := Concatenation( ~.PackageWWWHome, "singular-", ~.Version ),
ArchiveFormats := ".tar.gz",

Persons := [
  rec(
  LastName := "Costantini",
  FirstNames := "Marco",
  IsAuthor := true,
  IsMaintainer := false,
  Email := "costanti@science.unitn.it",
  WWWHome := "http://www-math.science.unitn.it/~costanti/",
  Place := "Trento",
  Institution := "Department of Mathematics, University of Trento"
  ),

  rec(
  LastName := "de Graaf",
  FirstNames := "Willem",
  IsAuthor := true,
  IsMaintainer := false,
  Email := "degraaf@science.unitn.it",
  WWWHome := "http://www.science.unitn.it/~degraaf/",
  PostalAddress := Concatenation( [
                     "Willem de Graaf\n",
                     "Dipartimento di Matematica\n",
                     "Università degli Studi di Trento\n",
                     "I-38050 Povo (Trento)\n",
                     "Italy" ] ),
  Place := "Trento",
  Institution := "Department of Mathematics, University of Trento"
  )
],

Status := "deposited",
#CommunicatedBy := "",
#AcceptDate := "",

README_URL := Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),

AbstractHTML :=
  "The <span class=\"pkgname\">singular</span> package provides an interface \
   from <span class=\"pkgname\">GAP</span> to the computer algebra system \
   <span class=\"pkgname\">Singular</span>.",

PackageDoc := rec(
  BookName  := "singular",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "The GAP interface to Singular",
  Autoload  := true
),

Dependencies := rec(
  GAP := ">=4", # recommended >=4.2 under unix or >=4.4 under windows
  NeededOtherPackages := [  ],
  # for reading online help, GapDoc is used
  SuggestedOtherPackages := [ [ "GapDoc", ">= 0.99" ] ], 
  ExternalConditions := [ ["Requires the computer algebra system Singular",
                           "http://www.singular.uni-kl.de/"] ]
),
AvailabilityTest := ReturnTrue,
Autoload := false,
# the banner
# BannerString := 
# "The GAP interface to Singular, by Marco Costantini and Willem de Graaf\n",

#TestFile := "tst/testall.g",
Keywords := [ "Interface to Singular", "Groebner bases" ]

));


#############################################################################
#E
