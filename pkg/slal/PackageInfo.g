#############################################################################
##
##  PackageInfo.g file for the package SLAL
##  Marco Costantini Willem de Graaf and ...
##

SetPackageInfo( rec(
PackageName := "slal",
Subtitle := "Small Lie Algebras Library",

# on a new release, change the version/date twice here, in init.g and in 
# doc/slal.xml

Version := "4.07.07",
Date := "07/07/2004",
ArchiveURL := Concatenation([
 "http://www-math.science.unitn.it/~costanti/gap_code/slal/slal-", 
  ~.Version]),
ArchiveFormats := ".tar.gz",

Persons := [
  rec(
  LastName := "Costantini",
  FirstNames := "Marco",
  IsAuthor := true,
  IsMaintainer := true,
  Email := "costanti@science.unitn.it",
  WWWHome := "http://www-math.science.unitn.it/~costanti/",
  PostalAddress := Concatenation( [
                     "Marco Costantini\n",
                     "Dipartimento di Matematica\n",
                     "Università degli Studi di Trento\n",
                     "I-38050 Povo (Trento)\n",
                     "Italy" ] ),
  Place := "Trento",
  Institution := "Department of Mathematics, University of Trento"
  ),

  rec(
  LastName := "de Graaf",
  FirstNames := "Willem",
  IsAuthor := true,
  IsMaintainer := true,
  Email := "quagroup@hetnet.nl",
  WWWHome := "http://www-circa.mcs.st-and.ac.uk/~wdg/",
  Place := "Utrecht",
  Institution := "Mathematisch Instituut Universiteit Utrecht"
  )
],

Status := "dev",
#CommunicatedBy := "",
#AcceptDate := "",

README_URL := "http://www-math.science.unitn.it/~costanti/gap_code/slal/README",
PackageInfoURL :=
 "http://www-math.science.unitn.it/~costanti/gap_code/slal/PackageInfo.g",

AbstractHTML :=
  "The <span class=\"pkgname\">slal</span> package provides a \
   a Small Lie Algebras Library.",

PackageWWWHome := "http://www-math.science.unitn.it/~costanti/#slal",

PackageDoc := rec(
  BookName  := "slal",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Small Lie Algebras Library",
  Autoload  := true
),

Dependencies := rec(
  GAP := ">=4", 
  NeededOtherPackages := [ ["singular", "0" ] ],
  SuggestedOtherPackages := [  ],
  ExternalConditions := [  ]
),
AvailabilityTest := ReturnTrue,
Autoload := false,
# the banner
BannerString := 
"Small Lie Algebras Library\n",

#TestFile := "tst/testall.g",
Keywords := ["Lie algebras"]

));

