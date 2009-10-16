#############################################################################
##
#W  PackageInfo.g            Sophus Package                  Csaba Schneider 
##                                                               
#H  $Id: PackageInfo.g,v 1.19 2006/01/23 14:34:59 gap Exp $


SetPackageInfo( rec(

  PackageName := "Sophus",
  Subtitle := "Computing in nilpotent Lie algebras",
  Version := "1.22",
  Date    := "30/08/2005",
  ArchiveURL := "http://www.sztaki.hu/~schneider/Research/Sophus/sophus1r22",
  ArchiveFormats := ".tar.gz",

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

  Status  := "accepted",
  CommunicatedBy 
          := "Alexander Konovalov (Zaporozhye)",
  AcceptDate 
          := "10/2004",

##  For a central overview of all packages and a collection of all package
##  archives it is necessary to have two files accessible which should be
##  contained in each package:
##     - A README file, containing a short abstract about the package
##       content and installation instructions.
##     - The file you are currently reading or editing!
##  You must specify URLs for these two files, these allow to automate 
##  the updating of package information on the GAP Website, and inclusion
##  and updating of the package in the GAP distribution.


  README_URL := "http://www.sztaki.hu/~schneider/Research/Sophus/README",
  PackageInfoURL := "http://www.sztaki.hu/~schneider/Research/Sophus/PackageInfo.g",

##  Here you  must provide a short abstract explaining the package content 
##  in HTML format (used on the package overview Web page) and an URL 
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
##  Please, use '<span class="pkgname">GAP</span>' and
##  '<span class="pkgname">MyPKG</span>' for specifing package names.
##  

  AbstractHTML := "http://www.sztaki.hu/~schneider/Research/Sophus/",

  PackageWWWHome := "http://www.sztaki.hu/~schneider/Research/Sophus/",
                  
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
    BookName  := "Sophus",
    # format/extension can be one of .zoo, .tar.gz, .tar.bz2, -win.zip
    Archive   := "http://www.sztaki.hu/~schneider/Research/Sophus/sophusdoc1r22.tar.gz",
    HTMLStart := "Doc/chap0.html",
    PDFFile   := "Doc/manual.pdf",
    # the path to the .six file used by GAP's help system
    SixFile   := "Doc/manual.six",
    # a longer title of the book, this together with the book name should
    # fit on a single text line (appears with the '?books' command in GAP)
    LongTitle := "Computing with nilpotent Lie algebras",
    # Should this help book be autoloaded when GAP starts up? This should
    # usually be 'true', otherwise say 'false'. 
    Autoload := true 
  ),

##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?

  Dependencies := rec(
    # GAP version, use version strings for specifying exact versions,
    # prepend a '>=' for specifying a least version.
    GAP := ">= 4.3fix4",
    # list of pairs [package name, (least) version],  package name is case
    # insensitive, least version denoted with '>=' prepended to version string.
    # without these, the package will not load
    NeededOtherPackages := [["autpgrp","1.2"],["gapdoc", "0.9999"]],
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

  AvailabilityTest := ReturnTrue,

##  Suggest here if the package should be *automatically loaded* when GAP is 
##  started.  This should usually be 'false'. Say 'true' only if your package 
##  provides some improvements of the GAP library which are likely to enhance 
##  the overall system performance for many users.

  Autoload := true,

##  *Optional*, but recommended: path relative to package root to a file which 
##  contains as many tests of the package functionality as sensible.

# TestFile := "",

##  *Optional*: Here you can list some keyword related to the topic 
##  of the package.

  Keywords := [ "nilpotent Lie algebras" ]

));
