#############################################################################
##
#W  PackageInfo.g            ACE Package                          Greg Gamble
#W                                                               Frank Lübeck
##
#H  @(#)$Id: PackageInfo.g,v 1.3 2006/01/26 16:21:28 gap Exp $

SetPackageInfo( rec(

  PackageName := "ACE",
  Subtitle    := "Advanced Coset Enumerator",
  Version     := "5.0",
  Date        := "26/01/2006",
  ArchiveURL  := "http://www.math.rwth-aachen.de/~Greg.Gamble/ACE/ace-5.0",
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
      Email         := "gregg@itee.uq.edu.au",
      WWWHome       := "http://www.math.rwth-aachen.de/~Greg.Gamble",
      PostalAddress := Concatenation( [
                         "Greg Gamble\n",
                         "School of Mathematics and Statistics\n",
                         "Curtin University of Technology\n",
                         "GPO Box U 1987\n",
                         "Perth WA 6845\n",
                         "Australia" ] ),
      Place         := "Perth",
      Institution   := "Curtin University of Technology"
    ),
    rec( 
      LastName      := "Hulpke",
      FirstNames    := "Alexander",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "hulpke@math.colostate.edu",
      WWWHome       := "http://www.math.colostate.edu/~hulpke",
      PostalAddress := Concatenation( [
                         "Alexander Hulpke\n",
                         "Department of Mathematics\n",
                         "Colorado State University\n",
                         "Weber Building\n",
                         "Fort Collins, CO 80523\n",
                         "USA" ] ),
      Place         := "Fort Collins",
      Institution   := "Colorado State University"
    ),
    rec( 
      LastName      := "Havas",
      FirstNames    := "George",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "havas@itee.uq.edu.au",
      WWWHome       := "http://www.itee.uq.edu.au/~havas",
      PostalAddress := Concatenation( [
                         "George Havas\n",
                         "Centre for Discrete Mathematics and Computing\n",
                         "Department of Information Technology ",
                         "and Electrical Engineering\n",
                         "The University of Queensland\n",
                         "St. Lucia 4072\n",
                         "Australia" ] ),
      Place         := "Brisbane",
      Institution   := "The University of Queensland"
    ),
    rec( 
      LastName      := "Ramsay",
      FirstNames    := "Colin",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "cram@itee.uq.edu.au",
      WWWHome       := "http://www.itee.uq.edu.au/~cram",
      PostalAddress := Concatenation( [
                         "Colin Ramsay\n",
                         "Centre for Discrete Mathematics and Computing\n",
                         "Department of Information Technology ",
                         "and Electrical Engineering\n",
                         "The University of Queensland\n",
                         "St. Lucia 4072\n",
                         "Australia" ] ),
      Place         := "Brisbane",
      Institution   := "The University of Queensland"
    )
  ],  

  Status      := "accepted",
  CommunicatedBy 
              := "Joachim Neubüser (Aachen)",
  AcceptDate  := "04/2001",

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

  README_URL := "http://www.math.rwth-aachen.de/~Greg.Gamble/ACE/README",
  PackageInfoURL 
             := "http://www.math.rwth-aachen.de/~Greg.Gamble/ACE/PackageInfo.g",

##  Here you  must provide a short abstract explaining the package content 
##  in HTML format (used on the package overview Web page) and an URL 
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
##  Please, use '<span class="pkgname">GAP</span>' and
##  '<span class="pkgname">MyPKG</span>' for specifing package names.
##  

  AbstractHTML := 
    "The <span class=\"pkgname\">ACE</span> package provides both an \
     interactive and non-interactive interface with the Todd-Coxeter coset\
     enumeration functions of the ACE (Advanced Coset Enumerator) C program.",

  PackageWWWHome := "http://www.math.rwth-aachen.de/~Greg.Gamble/ACE/",
                  
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

  PackageDoc  := rec(
    # use same as in GAP            
    BookName  := "ACE",
    # format/extension can be one of .zoo, .tar.gz, .tar.bz2, -win.zip
    Archive   := 
      "http://www.math.rwth-aachen.de/~Greg.Gamble/ACE/ace-5.0.zoo",
    ArchiveURLSubset 
              := ["doc", "htm"],
    HTMLStart := "htm/chapters.htm",
    PDFFile   := "doc/manual.pdf",
    # the path to the .six file used by GAP's help system
    SixFile   := "doc/manual.six",
    # a longer title of the book, this together with the book name should
    # fit on a single text line (appears with the '?books' command in GAP)
    LongTitle := "Advanced Coset Enumerator",
    # Should this help book be autoloaded when GAP starts up? This should
    # usually be 'true', otherwise say 'false'. 
    Autoload  := true
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
    NeededOtherPackages := [],
    # without these the package will issue a warning while loading
    SuggestedOtherPackages := [],
    # needed external conditions (programs, operating system, ...)  provide 
    # just strings as text or
    # pairs [text, URL] where URL  provides further information
    # about that point.
    # (no automatic test will be done for this, do this in your 
    # 'AvailabilityTest' function below)
    ExternalConditions := []
  ),

## Provide a test function for the availability of this package, see
## documentation of 'Declare(Auto)Package', this is the <tester> function.
## For packages which will not fully work, use 'Info(InfoWarning, 1,
## ".....")' statements. For packages containing nothing but GAP code,
## just say 'ReturnTrue' here.
## (When this is used for package loading in the future the availability
## tests of other packages, as given above, will be done automatically and
## need not be included here.)

  AvailabilityTest := 
    function()
      # Test for existence of the compiled binary
      if Filename(DirectoriesPackagePrograms("ace"), "ace") = fail then
        Info(InfoWarning, 1,
             "Package ``ACE'': The program `ace' is not compiled");
        return fail;
      fi;
      return true;
    end,

##  The LoadPackage mechanism can produce a default banner from the info
##  in this file. If you are not happy with it, you can provide a string
##  here that is used as a banner. GAP decides when the banner is shown and
##  when it is not shown. *optional* (note the ~-syntax in this example)
  BannerString := Concatenation(
  "---------------------------------------------------------------------------",
  "\n",
  "Loading    ", ~.PackageName, " (", ~.Subtitle, ") ", ~.Version, "\n",
  "GAP code by ", ~.Persons[1].FirstNames, " ", ~.Persons[1].LastName,
        " <", ~.Persons[1].Email, "> (address for correspondence)\n",
  "       ", ~.Persons[2].FirstNames, " ", ~.Persons[2].LastName,
        " (", ~.Persons[2].WWWHome, ")\n",
  "           [uses ACE binary (C code program) version: 3.001]\n",
  "C code by  ", ~.Persons[3].FirstNames, " ", ~.Persons[3].LastName,
        " (", ~.Persons[3].WWWHome, ")\n",
  "           ", ~.Persons[4].FirstNames, " ", ~.Persons[4].LastName,
         " (", ~.Persons[4].WWWHome, ")\n\n",
  "                 For help, type: ?ACE\n",
  "---------------------------------------------------------------------------",
  "\n" ),

##  Suggest here if the package should be *automatically loaded* when GAP is 
##  started.  This should usually be 'false'. Say 'true' only if your package 
##  provides some improvements of the GAP library which are likely to enhance 
##  the overall system performance for many users.

  Autoload := false,

##  *Optional*, but recommended: path relative to package root to a file which 
##  contains as many tests of the package functionality as sensible.

  TestFile := "tst/aceds.tst",

##  *Optional*: Here you can list some keyword related to the topic 
##  of the package.

  Keywords := [ "coset enumeration", "Felsch strategy", "HLT strategy",
                "coset table", "index", "maxcosets", "activecosets" ]

));


