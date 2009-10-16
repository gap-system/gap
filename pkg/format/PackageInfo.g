#############################################################################
##
##  PackageInfo file for the FORMAT package.   
##                                       Bettina Eick and Charles R.B. Wright
##

SetPackageInfo( rec(

##  This is case sensitive, use your preferred spelling.
PackageName := "FORMAT",

Subtitle := "Computing with formations of finite solvable groups.",

##  See '?Extending: Version Numbers' in GAP help for an explanation
##  of valid version numbers.
Version := "1.1",

##  Release date of the current version in dd/mm/yyyy format.
Date := "19/02/2003",

##  URL of the archive(s) of the current package release, but *without*
##  the format extension(s), like '.zoo', which are given next.
##  The archive file name must be changed with each version of the archive
##  (and probably somehow contain the package name an version).
ArchiveURL := "http://www.uoregon.edu/~wright/RESEARCH/format-1.1",

##  All provided formats as list of file extensions, separated by white
##  space or commas.
##  Currently recognized formats are:
##      .zoo       the (GAP-traditional) zoo-format with "!TEXT!" comments
##                 for text files
##      .tar.gz    the UNIX standard
##      .tar.bz2   compressed with 'bzip2', often smaller than with gzip
##      -win.zip   zip-format for DOS/Windows, text files must have DOS
##                 style line breaks (CRLF)
##
##  In the future we may also provide .deb or .rpm formats which allow
##  a convenient installation and upgrading on Linux systems.
##
ArchiveFormats := ".tar.gz",

##  If not all of the archive formats mentioned above are provided, these
##  can be produced at the GAP side. Therefore it is necessary to know which
##  files of the package distribution are text files which should be unpacked
##  with operating system specific line breaks. There are the following
##  possibilities to specify the text files:
##
##    - specify below a component 'TextFiles' which is a list of names of the
##      text files, relative to the package root directory (e.g., "lib/bla.g")
##    - specify below a component 'BinaryFiles' as list of names, then all other
##      files are taken as text files.
##    - if no 'TextFiles' or 'BinaryFiles' are given and a .zoo archive is
##      provided, then the files in that archive with a "!TEXT!" comment are
##      taken as text files
##    - otherwise: exactly the files with names matching the regular expression
##      ".*\(\.txt\|\.gi\|\.gd\|\.g\|\.c\|\.h\|\.htm\|\.html\|\.xml\|\.tex\|\.six\|\.bib\|\.tst\|README.*\|INSTALL.*\|Makefile\)"
##      are taken as text files
##
##  (Example: Just providing a .tar.gz file will often result in useful
##  archives)
##
#TextFiles := ["init.g", ......],
#BinaryFiles := ["doc/manual.dvi", ......],


##  Information about authors and maintainers. Specify for each person a
##  record with the following information:
##
##
Persons := [
  rec(
      LastName      := "Eick",
      FirstNames    := "Bettina",
      IsAuthor      := true,
      IsMaintainer  := true,
      Email         := "b.eick@tu-bs.de",
      WWWHome       := "http://www-public.tu-bs.de:8080/~beick",
      PostalAddress := Concatenation( [
                         "Bettina Eick\n",
                         "Institut Computational Mathematics\n",
                         "Technische Universit\"at Braunschweig\n",
                         "Pockelsstr. 14, D-38106 Braunschweig, Germany" ] ),
      Place         := "Braunschweig",
      Institution   := "Fachbereich Mathematik und Informatik"
    ),

  rec(
      LastName := "Wright",
      FirstNames := "Charles R.B.",
      IsAuthor := true,
      IsMaintainer := true,
      Email := "wright@math.uoregon.edu",
      WWWHome := "http://www.uoregon.edu/~wright",
      Place := "Eugene",
      Institution := "University of Oregon"
  )
],

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "accepted",

##  You must provide the next two entries in case of status "accepted":
# format: 'name (place)'
CommunicatedBy := "Joachim Neubüser (Aachen)",
# format: mm/yyyy
AcceptDate := "12/2000",

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
README_URL := "http://www.uoregon.edu/~wright/RESEARCH/README.format",
PackageInfoURL := "http://www.uoregon.edu/~wright/RESEARCH/PackageInfo.g",

##  Here you  must provide a short abstract explaining the package content
##  in HTML format (used on the package overview Web page) and an URL
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
# Please, use '<span class="pkgname">GAP</span>' and
# '<span class="pkgname">MyPKG</span>' for specifing package names.
AbstractHTML := "This package provides functions for computing with \
formations of finite solvable groups.",

PackageWWWHome := "http://www.uoregon.edu/~wright/RESEARCH/format.html",

##  On the GAP Website there is an online version of all manuals in the
##  GAP distribution. To handle the documentation of a package it is
##  necessary to have:
##     - an archive containing the package documentation (if possible
##       HTML and PDF-format)
##     - the start file of the HTML documentation (if provided), relative to
##       package root
##     - the PDF-file relative to the package root
##  For links to other package manuals or the GAP manuals one can assume
##  relative paths as in a standard GAP installation.
##  Also, provide the information which is currently given in your packages
##  init.g file in the command DeclarePackage(Auto)Documentation
##  (for future simplification of the package loading mechanism).
##
##  Please, remove all unnecessary files (.log, .aux, .dvi, .ps, ...) from
##  the documentation archive.
##
# in case of several help books give a list of entries here:
PackageDoc := rec(
  # use same as in GAP
  BookName := "FORMAT",
  # format/extension can be one of .zoo, .tar.gz, .tar.bz2, -win.zip
  #Archive := "",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile := "doc/manual.pdf",
  # the path to the .six file used by GAP's help system
  SixFile := "doc/manual.six",
  # a longer title of the book, this together with the book name should
  # fit on a single text line (appears with the '?books' command in GAP)
  LongTitle := "Formations of Finite Soluble Groups",
  # Should this help book be autoloaded when GAP starts up? This should
  # usually be 'true', otherwise say 'false'.
  Autoload := true
),


##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?
Dependencies := rec(
  # GAP version, use version strings for specifying exact versions,
  # prepend a '>=' for specifying a least version.
  GAP := ">=4.3",
  # list of pairs [package name, (least) version],  package name is case
  # insensitive, least version denoted with '>=' prepended to version string.
  # without these, the package will not load

######   FORMAT is just GAP code and doesn't depend on other packages,
######   so this is easy:
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

#  Provide a test function for the availability of this package, see
#  documentation of 'Declare(Auto)Package', this is the <tester> function.
#  For packages which will not fully work, use 'Info(InfoWarning, 1,
#  ".....")' statements. For packages containing nothing but GAP code,
#  just say 'ReturnTrue' here.
#  (When this is used for package loading in the future the availability
#  tests of other packages, as given above, will be done automatically and
#  need not be included here.)
AvailabilityTest := ReturnTrue,

Autoload := false,

##  Optional, but recommended: path relative to package root to a file which
##  contains as many tests of the package functionality as sensible.
# TestFile := "tst/manual_input", not strictly speaking a test file

##  Optional: Here you can list some keyword related to the topic
##  of the package.
Keywords := ["formations", "soluble", "group"]

));

