#############################################################################
##
#W  PackageInfo.g             ANUPQ Package                       Greg Gamble
#W                                                               Frank Lübeck
##
#H  @(#)$Id: PackageInfo.g,v 1.6 2006/01/24 04:57:16 gap Exp $

SetPackageInfo( rec(

  PackageName := "ANUPQ",
  Subtitle    := "ANU p-Quotient",
  Version     := "3.0",
  Date        := "24/01/2006",
  ArchiveURL  := "http://www.math.rwth-aachen.de/~Greg.Gamble/ANUPQ/anupq-3.0",
  ArchiveFormats 
              := ".zoo",

##    - if no 'TextFiles' or 'BinaryFiles' are given and a .zoo archive is
##      provided, then the files in that archive with a "!TEXT!" comment are
##      taken as text files
##    - otherwise: exactly the files with names matching the regular expression
##      ".*\(\.txt\|\.gi\|\.gd\|\.g\|\.c\|\.h\|\.htm\|\.html\|\.xml\|\.tex\|\.six\|\.bib\|\.tst\|README.*\|INSTALL.*\|Makefile\)"
##      are taken as text files
##  
##  These entries are *optional*.
#TextFiles := ["init.g", ......],
#BinaryFiles := ["doc/manual.dvi", ......],


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
      IsMaintainer  := true,
      Email         := "nickel@mathematik.tu-darmstadt.de",
      WWWHome       := "http://www.mathematik.tu-darmstadt.de/~nickel",
      PostalAddress := Concatenation(
                         "AG 2, Fachbereich Mathematik, TU Darmstadt\n",
                         "Schlossgartenstr. 7, 64289 Darmstadt\n",
                         "Germany" ),
      Place         := "Darmstadt",
      Institution   := "TU Darmstadt"
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
    )
  ],  

  Status      := "accepted",
  CommunicatedBy 
              := "Charles Wright (Eugene)",
  AcceptDate  := "04/2002",

##  For a central overview of all packages and a collection of all package
##  archives it is necessary to have two files accessible which should be
##  contained in each package:
##     - A README file, containing a short abstract about the package
##       content and installation instructions.
##     - The file you are currently reading or editing!
##  You must specify URLs for these two files, these allow to automate 
##  the updating of package information on the GAP Website, and inclusion
##  and updating of the package in the GAP distribution.
##  

  README_URL := "http://www.math.rwth-aachen.de/~Greg.Gamble/ANUPQ/README",
  PackageInfoURL 
         := "http://www.math.rwth-aachen.de/~Greg.Gamble/ANUPQ/PackageInfo.g",

##  Here you  must provide a short abstract explaining the package content 
##  in HTML format (used on the package overview Web page) and an URL 
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
##  Please, use '<span class="pkgname">GAP</span>' and
##  '<span class="pkgname">MyPKG</span>' for specifing package names.
##  

  AbstractHTML := 
    "The <span class=\"pkgname\">ANUPQ</span> package provides an interactive \
     interface to the p-quotient, p-group generation and standard presentation \
     algorithms of the ANU pq C program. The package supersedes the earlier \
     <span class=\"pkgname\">GAP</span> 3 version (1.0).",

  PackageWWWHome := "http://www.math.rwth-aachen.de/~Greg.Gamble/ANUPQ/",
                  
##  On the GAP Website there is an online version of all manuals in the
##  GAP distribution. To handle the documentation of a package it is
##  necessary to have:
##     - an archive containing the package documentation (in at least one 
##       of HTML or PDF-format, preferably both formats)
##     - the start file of the HTML documentation (if provided), *relative to
##       package root*
##     - the PDF-file (if provided) *relative to the package root*
##  For links to other package manuals or the GAP manuals one can assume 
##  relative paths as in a standard GAP installation. 
##  Also, provide the information which is currently given in your packages 
##  init.g file in the command DeclarePackage(Auto)Documentation
##  (for future simplification of the package loading mechanism).
##  
##  Please, don't include unnecessary files (.log, .aux, .dvi, .ps, ...) in
##  the provided documentation archive.
##  
# in case of several help books give a list of such records here:

  PackageDoc := rec(
    # use same as in GAP            
    BookName  := "ANUPQ",
    # format/extension can be one of .zoo, .tar.gz, .tar.bz2, -win.zip
    Archive   := 
      "http://www.math.rwth-aachen.de/~Greg.Gamble/ANUPQ/anupq-3.0.zoo",
    ArchiveURLSubset
              := ["doc", "htm"],
    HTMLStart := "htm/chapters.htm",
    PDFFile   := "doc/manual.pdf",
    # the path to the .six file used by GAP's help system
    SixFile   := "doc/manual.six",
    # a longer title of the book, this together with the book name should
    # fit on a single text line (appears with the '?books' command in GAP)
    LongTitle := "ANU p-Quotient",
    # Should this help book be autoloaded when GAP starts up? This should
    # usually be 'true', otherwise say 'false'. 
    Autoload := false
  ),

##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?

  Dependencies := rec(
    # GAP version, use version strings for specifying exact versions,
    # prepend a '>=' for specifying a least version.
    GAP := ">= 4.4",
    # list of pairs [package name, (least) version],  package name is case
    # insensitive, least version denoted with '>=' prepended to version string.
    # without these, the package will not load
    NeededOtherPackages := [ [ "autpgrp", ">=1.2" ] ],
    # without these the package will issue a warning while loading
    SuggestedOtherPackages := [ ],
    # needed external conditions (programs, operating system, ...)  provide 
    # just strings as text or
    # pairs [text, URL] where URL  provides further information
    # about that point.
    # (no automatic test will be done for this, do this in your 
    # 'AvailabilityTest' function below)
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
                  " <", ~.Persons[2].Email, ">\n",
    "        and   ", ~.Persons[1].FirstNames, " ", ~.Persons[1].LastName,
                  "  <", ~.Persons[1].Email, ">\n\n",
    "            For help, type: ?", ~.PackageDoc.BookName, "\n",
    "-------------------------------------------------------------\n"),

##  Suggest here if the package should be *automatically loaded* when GAP is 
##  started.  This should usually be 'false'. Say 'true' only if your package 
##  provides some improvements of the GAP library which are likely to enhance 
##  the overall system performance for many users.

  Autoload := false,

##  *Optional*, but recommended: path relative to package root to a file which 
##  contains as many tests of the package functionality as sensible.

  TestFile := "tst/anupqeg.tst",

##  *Optional*: Here you can list some keyword related to the topic 
##  of the package.

  Keywords := [ "p-quotient", "p-group generation", 
                "descendant", "standard presentation" ]

));
