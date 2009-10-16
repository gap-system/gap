#############################################################################
##
#W PackageInfo.g           The Congruence package                   Ann Dooms
#W                                                               Eric Jespers
#W                                                        Alexander Konovalov
#W                                                             Helena Verrill
##
#H $Id: PackageInfo.g,v 1.2 2008/05/28 23:58:02 alexk Exp $
##
#############################################################################

SetPackageInfo( rec(

PackageName    := "Congruence",
Subtitle       := "Congruence subgroups of SL(2,Integers)",
Version        := "1.0",
Date           := "29/05/2008",
ArchiveURL := "http://www.cs.st-andrews.ac.uk/~alexk/congruence/congruence-1.0",
ArchiveFormats := ".tar.gz .tar.bz2 -win.zip",

#TextFiles := ["init.g", ......],
#BinaryFiles := ["doc/manual.dvi", ......],

Persons := [
  rec(
    LastName      := "Dooms",
    FirstNames    := "Ann",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "andooms@vub.ac.be",
    WWWHome       := "http://homepages.vub.ac.be/~andooms",
    PostalAddress := Concatenation( [
                     "Department of Mathematics\n",
                     "Vrije Universiteit Brussel\n", 
                     "Pleinlaan 2, Brussels, B-1050 Belgium" ] ),
    Place         := "Brussels",
    Institution   := "Vrije Universiteit Brussel"
     ),     
  rec(
    LastName      := "Jespers",
    FirstNames    := "Eric",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "efjesper@vub.ac.be",
    WWWHome       := "http://homepages.vub.ac.be/~efjesper",
    PostalAddress := Concatenation( [
                     "Department of Mathematics\n",
                     "Vrije Universiteit Brussel\n", 
                     "Pleinlaan 2, Brussels, B-1050 Belgium" ] ),
    Place         := "Brussels",
    Institution   := "Vrije Universiteit Brussel"
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
    LastName      := "Verrill",
    FirstNames    := "Helena",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "verrill@math.lsu.edu",
    WWWHome       := "http://www.math.lsu.edu/~verrill",
    PostalAddress := Concatenation( [
                     "Department of Mathematics\n",
                     "Louisiana State University\n",
                     "Baton Rouge, Louisiana, 70803-4918\n",
                     "USA" ] ),
    Place         := "Baton Rouge",
    Institution   := "Louisiana State University"
     )      
],

Status := "dev",
#CommunicatedBy := "",
#AcceptDate := "",

README_URL := "http://www.cs.st-andrews.ac.uk/~alexk/congruence/README.congruence",
PackageInfoURL := "http://www.cs.st-andrews.ac.uk/~alexk/congruence/PackageInfo.g",
AbstractHTML := "The <span class=\"pkgname\">Congruence </span> package ...",
PackageWWWHome := "http://www.cs.st-andrews.ac.uk/~alexk/congruence.htm",
                  
PackageDoc := rec(
  BookName := "Congruence",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "Congruence subgroups of SL(2,Integers)",
  Autoload := true
),

Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [ ["GAPDoc", ">= 1.0"] ],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,
Autoload := false,
TestFile := "tst/cong.tst",

Keywords := ["congruence subgroup", "Farey symbol"]
));
