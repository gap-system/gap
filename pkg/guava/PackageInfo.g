#############################################################################
##
#W  PackageInfo.g                GUAVA Package                        Greg Gamble
#W                                                               Frank Lübeck
#W                                                               David Joyner
##
#H  @(#)$Id: PackageInfo.g,v 1.7 2004/12/20 21:26:05 gap Exp $

SetPackageInfo( rec(

  PackageName := "GUAVA",
  Subtitle := "a GAP package for computing with error-correcting codes",
  Version := "2.0",
  Date    := "20/12/2004",
  ArchiveURL 
          := "http://cadigweb.ew.usna.edu/~wdj/gap/GUAVA/guava",
  ArchiveFormats 
          := ".tar.gz",

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
      LastName      := "Cramwinckel",
      FirstNames    := "Jasper",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "",
      WWWHome       := "",
      PostalAddress := "",
      Place         := "Delft",
      Institution   := "Delft University of Technology"
    ),
    rec( 
      LastName      := "Roijackers",
      FirstNames    := "Erik",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "",
      WWWHome       := "",
      PostalAddress := "",
      Place         := "Delft",
      Institution   := "Delft University of Technology"
    ),
    rec( 
      LastName      := "Baart",
      FirstNames    := "Reinald",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "",
      WWWHome       := "",
      PostalAddress := "",
      Place         := "Delft",
      Institution   := "Delft University of Technology"
    ),
    rec( 
      LastName      := "Minkes",
      FirstNames    := "Eric",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "",
      WWWHome       := "",
      PostalAddress := "",
      Place         := "Delft",
      Institution   := "Delft University of Technology"
    ),
    rec( 
      LastName      := "Ruscio",
      FirstNames    := "Lea",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "",
      WWWHome       := "",
      PostalAddress := "",
      Place         := "Edinburgh",
      Institution   := "The University of Edinburgh"
    ),
    rec( 
      LastName      := "Joyner",
      FirstNames    := "David",
      IsAuthor      := true,
      IsMaintainer  := true,
      Email         := "wdj@usna.edu",
      WWWHome       := "http://cadigweb.ew.usna.edu/~wdj/homepage.html",
      PostalAddress := Concatenation( [
                         "W. David Joyner\n",
                         "Mathematics Department\n",
                         "U. S. Naval Academy\n",
                         "Annapolis, MD 21402\n",
                         "USA" ] ),
      Place         := "Annapolis",
      Institution   := "U. S. Naval Academy"
    )
  ],  

  Status  := "accepted",
  CommunicatedBy 
          := "Charles Wright (Eugene)",
  AcceptDate 
          := "02/2003",

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

  README_URL := "http://cadigweb.ew.usna.edu/~wdj/gap/GUAVA/README.guava",
  PackageInfoURL := "http://cadigweb.ew.usna.edu/~wdj/gap/GUAVA/PackageInfo.g",

##  Here you  must provide a short abstract explaining the package content 
##  in HTML format (used on the package overview Web page) and an URL 
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
##  Please, use '<span class="pkgname">GAP</span>' and
##  '<span class="pkgname">MyPKG</span>' for specifing package names.
##  

  AbstractHTML := 
    "<span class=\"pkgname\">GUAVA</span> is a <span class=\"pkgname\">GAP</span>package for computing with codes. <span class=\"pkgname\">GUAVA</span> can construct unrestricted, linear and cyclic codes, transform one code into another, construct a new code from two other codes, and can calculate important data of codes very fast.",

  PackageWWWHome := "http://cadigweb.ew.usna.edu/~wdj/gap/GUAVA/",
                  
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
    BookName  := "GUAVA",
    ArchiveURLSubset := ["doc", "htm"],
    # format/extension can be one of .zoo, .tar.gz, .tar.bz2, -win.zip
    #Archive   := "http://cadigweb.ew.usna.edu/~wdj/gap/GUAVA/guava.tar.gz",
    HTMLStart := "htm/chapters.htm",
    PDFFile   := "doc/manual.pdf",
    # the path to the .six file used by GAP's help system
    SixFile   := "doc/manual.six",
    # a longer title of the book, this together with the book name should
    # fit on a single text line (appears with the '?books' command in GAP)
    LongTitle := "GUAVA Coding Theory Package",
    Subtitle := "error-correcting codes computations",
    # Should this help book be autoloaded when GAP starts up? This should
    # usually be 'true', otherwise say 'false'. 
    Autoload := true
  ),

##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?

  Dependencies := rec(
    # GAP version, use version strings for specifying exact versions,
    # prepend a '>=' for specifying a least version.
    GAP := ">= 4.3",
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
      local path;

      # Test for existence of the compiled binary
      path := DirectoriesPackagePrograms( "guava" );

      if ForAny( ["desauto", "leonconv", "wtdist"], 
                 f -> Filename( path, f ) = fail ) then
          Info( InfoWarning, 1,
                "Package ``GUAVA'': the C code programs are not compiled." );
          Info( InfoWarning, 1,
                "Some GUAVA functions, e.g. `ConstantWeightSubcode', ",
                "will be unavailable. ");
          Info( InfoWarning, 1,
                "See ?Installing GUAVA" );
      fi;
      return true;
    end,


##  Suggest here if the package should be *automatically loaded* when GAP is 
##  started.  This should usually be 'false'. Say 'true' only if your package 
##  provides some improvements of the GAP library which are likely to enhance 
##  the overall system performance for many users.

  Autoload := false,

##  *Optional*, but recommended: path relative to package root to a file which 
##  contains as many tests of the package functionality as sensible.
#TestFile := "tst/testall.g",

##  *Optional*: Here you can list some keyword related to the topic 
##  of the package.

  Keywords := [ "code", "codeword", "Hamming", "linear code", "cyclic code" ]

));


