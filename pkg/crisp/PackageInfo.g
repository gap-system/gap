#############################################################################
##  
##  Packageinfo.g for CRISP package                       (Burkhard Höfling)
##
##  adapted from PackageInfo.g template by Frank Luebeck
##  

SetPackageInfo( rec(

##  This is case sensitive, use your preferred spelling.

PackageName := "CRISP",
Subtitle := "Computing with Radicals, Injectors, Schunck classes and Projectors",
##  See '?Extending: Version Numbers' in GAP help for an explanation
##  of valid version numbers.
Version := "1.3.5",

##  Release date of the current version in dd/mm/yyyy format.
Date := "22/11/2011",

BannerString := Concatenation ("\
----------------------------------------------------------------------\n\
                        CRISP Version ", ~.Version, "\n\
  Computing with Radicals, Injectors, Schunck classes and Projectors\n\
                         by Burkhard Höfling\n\
----------------------------------------------------------------------\n"),

##  URL of the archive(s) of the current package release, but *without*
##  the format extension(s), like '.zoo', which are given next.
##  The archive file name *must be changed* with each version of the archive
##  (and probably somehow contain the package name and version).
ArchiveURL := "http://www.icm.tu-bs.de/~bhoeflin/crisp/crisp-1r3n5",

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
ArchiveFormats := ".tar.bz2", # the others are generated automatically
# ArchiveFormats := ".zoo",

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
##  (Remark: Just providing a .tar.gz file will often result in useful
##  archives)
##  
##  These entries are *optional*.
BinaryFiles := ["doc/manual.pdf"],

##  Information about authors and maintainers. Specify for each person a 
##  record with the following information:
##  
##     rec(
##     # these are compulsory, characters are interpreted as latin-1, so
##     # German umlauts and other western European special characters are ok:
##     LastName := "Mueller",
##     FirstNames := "Fritz Eduard",
##  
##     # At least one of the following two entries must be given and set 
##     # to 'true' (an entry can be left out if value is not 'true'):
##     IsAuthor := true;
##     IsMaintainer := true;
##  
##     # At least one of the following three entries must be given.
##     # - preferably email address and WWW homepage
##     # - postal address not needed if email or WWW address available
##     # - if no contact known, specify postal address as "no address known"
##     Email := "Mueller@no.org",
##     # complete URL, starting with protocol
##     WWWHome := "http://www.no.org/~Mueller",
##     # separate lines by '\n' (*optional*)
##     PostalAddress := "Dr. F. Mueller\nNo Org Institute\nNo Place 13\n\
##     12345 Notown\nNocountry"
##     
##     # If you want, add one or both of the following entries (*optional*)
##     Place := "Notown",
##     Institution := "Institute for Nothing"
##     )
##  
Persons := [
  rec(
  LastName := "Höfling",
  FirstNames := "Burkhard",
  IsAuthor := true,
  IsMaintainer := true,
  WWWHome := "http://www.icm.tu-bs.de/~bhoeflin",
  Email := "b.hoefling@tu-bs.de"
  )
# provide such a record for each author and/or maintainer ...
  
],

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "deposited"     for packages for which the GAP developers agreed 
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages 
##    "other"         for all other packages
##
Status := "accepted",

##  You must provide the next two entries if and only if the status is 
##  "accepted":
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
README_URL := "http://www.icm.tu-bs.de/~bhoeflin/crisp/README",
PackageInfoURL := "http://www.icm.tu-bs.de/~bhoeflin/crisp/PackageInfo.g",

##  Here you  must provide a short abstract explaining the package content 
##  in HTML format (used on the package overview Web page) and an URL 
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
##  Please, use '<span class="pkgname">GAP</span>' and
##  '<span class="pkgname">MyPKG</span>' for specifing package names.
##  
AbstractHTML := "The <span class=\"pkgname\">GAP</span> package <span \
class=\"pkgname\">CRISP</span> provides algorithms for computing \
subgroups of finite solvable groups related to a group class \
<i>C</i>. In particular, it allows to compute <i>C</i>-radicals and \
<i>C</i>-injectors for Fitting classes (and Fitting sets) <i>C</i>, \
<i>C</i>-residuals for formations <i>C</i>, and <i>C</i>-projectors \
for Schunck classes <i>C</i>. In order to carry out these \
computations, the group class <i>C</i> must be represented by an \
algorithm which can decide membership in the group class.</p> \
 \
<p>Moreover, <span class=\"pkgname\">CRISP</span> contains algorithms \
for the computation of normal subgroups invariant under a \
prescribed set of automorphisms and belonging to a given group \
class.</p> \
 \
<p>This includes an improved method to compute the set of all \
normal subgroups of a finite solvable group, its characteristic \
subgroups, minimal normal subgroups and the socle and \
<i>p</i>-socles for given primes <i>p</i>.",

PackageWWWHome := "http://www.icm.tu-bs.de/~bhoeflin/crisp/index.html",
                  
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
  BookName := "CRISP",
  # format/extension can be one of .zoo, .tar.gz, .tar.bz2, -win.zip
  # Archive := "http://www.math.rwth-aachen.de/~Frank.Luebeck/EDIM/edimdoc-1p1.tar.bz2",
  ArchiveURLSubset := ["doc", "html"],
  HTMLStart := "html/chapters.htm",
  PDFFile := "doc/manual.pdf",
  # the path to the .six file used by GAP's help system
  SixFile := "doc/manual.six",
  # a longer title of the book, this together with the book name should
  # fit on a single text line (appears with the '?books' command in GAP)
  LongTitle := "Computing Radicals, Injectors, Projectors of solvable groups",
  # Should this help book be autoloaded when GAP starts up? This should
  # usually be 'true', otherwise say 'false'. 
  Autoload := true
),


##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?
Dependencies := rec(
  # GAP version, use version strings for specifying exact versions,
  # prepend a '>=' for specifying a least version.
  GAP := ">=4.4.12",
  # list of pairs [package name, (least) version],  package name is case
  # insensitive, least version denoted with '>=' prepended to version string.
  # without these, the package will not load
  # NeededOtherPackages := [["GAPDoc", ">= 0.99"]],
  NeededOtherPackages := [],
  # without these the package will issue a warning while loading
  # SuggestedOtherPackages := [],
  SuggestedOtherPackages := [],
  # needed external conditions (programs, operating system, ...)  provide 
  # just strings as text or
  # pairs [text, URL] where URL  provides further information
  # about that point.
  # (no automatic test will be done for this, do this in your 
  # 'AvailabilityTest' function below)
  # ExternalConditions := []
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
# AvailabilityTest := ReturnTrue,
AvailabilityTest := ReturnTrue,

##  Suggest here if the package should be *automatically loaded* when GAP is 
##  started.  This should usually be 'false'. Say 'true' only if your package 
##  provides some improvements of the GAP library which are likely to enhance 
##  the overall system performance for many users.
Autoload := true,

##  *Optional*, but recommended: path relative to package root to a file which 
##  contains as many tests of the package functionality as sensible.
TestFile := "tst/test.tst",

##  *Optional*: Here you can list some keyword related to the topic 
##  of the package.
# Keywords := ["Smith normal form", "p-adic", "rational matrix inversion"]
Keywords := ["radical", "residual", "projector", "injector", 
   "formation", "Fitting class", "Fitting set", "Schunck class",
   "group class", "normal subgropus", "minimal normal subgropus", "socle"]

));


