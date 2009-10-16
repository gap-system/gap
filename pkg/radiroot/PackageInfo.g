#############################################################################
##  
#W PackageInfo.g               RadiRoot package               Andreas Distler
##
## The package info file for the RadiRoot package
##
#H $Id: PackageInfo.g,v 1.7 2008/01/22 11:57:43 gap Exp $
##
#Y 2006
##

SetPackageInfo( rec(

PackageName := "RadiRoot",
Subtitle := "Roots of a Polynomial as Radicals",
Version := "2.4",
Date := "22/01/2008",

ArchiveURL := Concatenation([
"http://www.icm.tu-bs.de/ag_algebra/software/distler/radiroot/radiroot-",
~.Version]),
ArchiveFormats := ".tar.gz",

Persons := [
  rec(
      LastName      := "Distler",
      FirstNames    := "Andreas",
      IsAuthor      := true,
      IsMaintainer  := true,
      Email         := "a.distler@tu-bs.de",
      #WWWHome       := "http://www.tu-bs.de/~beick",
      PostalAddress := Concatenation( [
            "Mathematical Institute\n",
            "University of St Andrews\n",
            "North Haugh\n St Andrews, Fife, KY16 9SS\n Scotland, UK" ] ),
      Place         := "St. Andrews",
      Institution   := "University of St Andrews")
    ],

Status := "accepted",
CommunicatedBy := "Edmund Robertson (St Andrews)",
AcceptDate := "02/2007",

README_URL := "http://www.icm.tu-bs.de/ag_algebra/software/distler/radiroot/README",
PackageInfoURL := "http://www.icm.tu-bs.de/ag_algebra/software/distler/radiroot/PackageInfo.g",

##  Here you  must provide a short abstract explaining the package content 
##  in HTML format (used on the package overview Web page) and an URL 
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
##  Please, use '<span class="pkgname">GAP</span>' and
##  '<span class="pkgname">MyPKG</span>' for specifing package names.
##  
AbstractHTML := 
  "The <span class=\"pkgname\">RadiRoot</span> package installs a method to \
   display the roots of a rational polynomial as radicals if it is solvable.",

PackageWWWHome := "http://www.icm.tu-bs.de/ag_algebra/software/distler/radiroot/",
                  
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
  BookName  := "RadiRoot",
  # format/extension can be one of .zoo, .tar.gz, .tar.bz2, -win.zip
  # Archive := "http://cayley.math.nat.tu-bs.de/software/sievers/FGA/FGA-Doc-1.0.tar.gz",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  # the path to the .six file used by GAP's help system
  SixFile   := "doc/manual.six",
  # a longer title of the book, this together with the book name should
  # fit on a single text line (appears with the '?books' command in GAP)
  LongTitle := "Roots of a Polynomial as Radicals",
  # Should this help book be autoloaded when GAP starts up? This should
  # usually be 'true', otherwise say 'false'. 
  Autoload  := true
),


##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?
Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [[ "alnuth", ">=2.2.3" ]],
  SuggestedOtherPackages := [],
  ExternalConditions := ["latex and the dvi-viewer xdvi are recommended"]
),

AvailabilityTest := ReturnTrue,

Autoload := false,

##  *Optional*, but recommended: path relative to package root to a file which 
##  contains as many tests of the package functionality as sensible.
TestFile := "tst/testall.g",

Keywords := ["roots", "radicals"]

));


#############################################################################
##
#E
