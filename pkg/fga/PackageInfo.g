#############################################################################
##  
#W PackageInfo.g               FGA package                  Christian Sievers
##
## The package info file for the FGA package
##
#H @(#)$Id: PackageInfo.g,v 1.8 2005/05/27 14:38:55 gap Exp $
##
#Y 2003 - 2005
##

SetPackageInfo( rec(

PackageName := "FGA",
Subtitle := "Free Group Algorithms",
Version := "1.1.0.1",
#        dd/mm/yyyy
Date := "27/05/2005",

ArchiveURL := "http://www.icm.tu-bs.de/ag_algebra/software/sievers/FGA/FGA-1.1.0.1",
ArchiveFormats := ".tar.gz",

Persons := [
  rec( 
    LastName      := "Sievers",
    FirstNames    := "Christian",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "c.sievers@tu-bs.de",
#    WWWHome       := "",
    PostalAddress := Concatenation(
            [ "Christian Sievers\n", 
              "Fachbereich Mathematik und Informatik\n",
              "Institut Computational Mathematics\n",
              "Technische Universit\"at Braunschweig\n",
              "Pockelsstr. 14\n",
              "D-38106 Braunschweig,\n",
              "Germany" ]),
    Place         := "Braunschweig",
    Institution   := "TU Braunschweig"  )
    ],

Status := "accepted",

CommunicatedBy := "Edmund Robertson (St. Andrews)",
AcceptDate := "05/2005",

##  For a central overview of all packages and a collection of all package
##  archives it is necessary to have two files accessible which should be
##  contained in each package:
##     - A README file, containing a short abstract about the package
##       content and installation instructions.
##     - The file you are currently reading or editing!
##  You must specify URLs for these two files, these allow to automate 
##  the updating of package information on the GAP Website, and inclusion
##  and updating of the package in the GAP distribution.
#
README_URL := "http://www.icm.tu-bs.de/ag_algebra/software/sievers/FGA/README",
PackageInfoURL := "http://www.icm.tu-bs.de/ag_algebra/software/sievers/FGA/PackageInfo.g",

##  Here you  must provide a short abstract explaining the package content 
##  in HTML format (used on the package overview Web page) and an URL 
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
##  Please, use '<span class="pkgname">GAP</span>' and
##  '<span class="pkgname">MyPKG</span>' for specifing package names.
##  
AbstractHTML := 
  "The <span class=\"pkgname\">FGA</span> package installs methods for \
   computations with finitely generated subgroups of free groups and \
   provides a presentation for their automorphism groups.",

PackageWWWHome := "http://www.icm.tu-bs.de/ag_algebra/software/sievers/FGA/",
                  
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
##  Also, provide the information about autoloadability of the documentation.
##  
##  Please, don't include unnecessary files (.log, .aux, .dvi, .ps, ...) in
##  the provided documentation archive.
##  
# in case of several help books give a list of such records here:
PackageDoc := rec(
  # use same as in GAP            
  BookName  := "FGA",
  # format/extension can be one of .zoo, .tar.gz, .tar.bz2, -win.zip
  # Archive := "",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  # the path to the .six file used by GAP's help system
  SixFile   := "doc/manual.six",
  # a longer title of the book, this together with the book name should
  # fit on a single text line (appears with the '?books' command in GAP)
  LongTitle := "Free Group Algorithms",
  # Should this help book be autoloaded when GAP starts up? This should
  # usually be 'true', otherwise say 'false'. 
  Autoload  := true
),


##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?
Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,
#BannerString := ""

Autoload := true,

##  *Optional*, but recommended: path relative to package root to a file which 
##  contains as many tests of the package functionality as sensible.
TestFile := "tst/testall.g",

Keywords := ["free groups", "inverse finite automata",
             "basic coset enumeration",
             "finite presentation of the automorphism group of a free group"]

));


#############################################################################
##
#E
