#############################################################################
##
#W  PackageInfo.g             ANUPQ Package                       Greg Gamble
#W                                                              Werner Nickel
#W                                                             Eamonn O'Brien
#W                                                                   Max Horn
##
#H  @(#)$Id: PackageInfo.g,v 1.9 2012/01/13 11:24:32 gap Exp $

SetPackageInfo( rec(

PackageName := "ANUPQ",
Subtitle    := "ANU p-Quotient",
Version     := "3.1",
Date        := "??/??/2011",

Persons := [ 
  rec( 
    LastName      := "Gamble",
    FirstNames    := "Greg",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "gregg@math.rwth-aachen.de",
    WWWHome       := "http://www.math.rwth-aachen.de/~Greg.Gamble",
    PostalAddress := Concatenation(
                       "Greg Gamble\n",
                       "Department of Mathematics and Statistics\n",
                       "Curtin University of Technology\n",
                       "GPO Box U 1987\n",
                       "Perth WA 6845\n",
                       "Australia" ),
    Place         := "Perth",
    Institution   := "Curtin University of Technology"
  ),
  rec( 
    LastName      := "Nickel",
    FirstNames    := "Werner",
    IsAuthor      := true,
    IsMaintainer  := false,
     # MH: Werner rarely (if at all) replies to emails sent to this
     # old email address. To discourage users from sending bug reports
     # there, I have disabled it here.
     #Email         := "nickel@mathematik.tu-darmstadt.de",
     WWWHome       := "http://www.mathematik.tu-darmstadt.de/~nickel/",
  ),
  rec( 
    LastName      := "O'Brien",
    FirstNames    := "Eamonn",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "obrien@math.auckland.ac.nz",
    WWWHome       := "http://www.math.auckland.ac.nz/~obrien",
    PostalAddress := Concatenation(
                       "Department of Mathematics\n",
                       "University of Auckland\n",
                       "Private Bag 92019\n",
                       "Auckland\n",
                       "New Zealand\n" ),
    Place         := "Auckland",
    Institution   := "University of Auckland"
  ),
  rec(
   LastName      := "Horn",
   FirstNames    := "Max",
   IsAuthor      := false,
   IsMaintainer  := true,
   Email         := "mhorn@tu-bs.de",
   WWWHome       := "http://www.icm.tu-bs.de/~mhorn",
   PostalAddress := Concatenation(
           "AG Algebra und Diskrete Mathematik\n",
           "Institut Computational Mathematics\n",
           "TU Braunschweig\n",
           "Pockelsstr. 14\n",
           "D-38106 Braunschweig\n",
           "Germany" ),
   Place         := "Braunschweig",
   Institution   := "TU Braunschweig"
 ),
],  

Status         := "accepted",
CommunicatedBy := "Charles Wright (Eugene)",
AcceptDate     := "04/2002",

PackageWWWHome := "http://www.math.rwth-aachen.de/~Greg.Gamble/ANUPQ/",

ArchiveURL     := Concatenation( ~.PackageWWWHome, "anupq-", ~.Version ),
ArchiveFormats := ".tar.gz .zoo", # TODO: Add .tar.bz2, get rid of .zoo
README_URL     := Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),

AbstractHTML := 
  "The <span class=\"pkgname\">ANUPQ</span> package provides an interactive \
   interface to the p-quotient, p-group generation and standard presentation \
   algorithms of the ANU pq C program. The package supersedes the earlier \
   <span class=\"pkgname\">GAP</span> 3 version (1.0).",

PackageDoc := rec(
  BookName  := "ANUPQ",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "ANU p-Quotient",
  Autoload := false
),

Dependencies := rec(
  GAP := ">= 4.4",
  NeededOtherPackages := [ [ "autpgrp", ">=1.2" ] ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := []
),

AvailabilityTest := 
  function()
    local status;
    status := true;

    # test for existence of the compiled binary
    if Filename( DirectoriesPackagePrograms( "anupq" ), "pq" ) = fail then
        Info( InfoWarning, 1,
              "Package ``ANUPQ'': the executable program is not available" );
        status := fail;
    fi;

    # Dependencies above will ensure that ANUPQ fails to load if
    # AutPGrp (>= 1.2) is not available. This is here to explain why.
    if TestPackageAvailability("autpgrp", "1.2") = fail then
        Info( InfoWarning, 1,
              "Package ``ANUPQ'': requires the AutPGrp package (>= 1.2)" );
        Info( InfoWarning, 1,
              "for the AutomorphismGroupPGroup function. It is also needed" );
        Info( InfoWarning, 1,
              "by the pq binary when it needs GAP to compute stabilisers.");
        Info( InfoWarning, 1,
              "E.g. see the note for ?PqDescendants" );
        status := fail;
    fi;

    return status;
  end,

BannerString := Concatenation( 
  "-------------------------------------------------------------\n",
  "Loading ", ~.PackageDoc.BookName, " ", ~.Version, 
  " (", ~.PackageDoc.LongTitle, " package)\n",
  "C code by  ", ~.Persons[3].FirstNames, " ", ~.Persons[3].LastName,
                " <", ~.Persons[3].Email, ">\n",
  "           (ANU pq binary version: 1.8)\n",
  "GAP code by ", ~.Persons[2].FirstNames, " ", ~.Persons[2].LastName,
                "\n",
                #" <", ~.Persons[2].Email, ">\n",
  "        and   ", ~.Persons[1].FirstNames, " ", ~.Persons[1].LastName,
                "  <", ~.Persons[1].Email, ">\n\n",
  "            For help, type: ?", ~.PackageDoc.BookName, "\n",
  "-------------------------------------------------------------\n"),

Autoload := false,

TestFile := "tst/anupqeg.tst",

Keywords := [
  "p-quotient",
  "p-group generation",
  "descendant",
  "standard presentation",
  ]
));
