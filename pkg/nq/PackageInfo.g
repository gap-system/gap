#############################################################################
##  
##  PackageInfo.g                  NQ                           Werner Nickel
##  
##  Based on Frank Lübeck's template for PackageInfo.g.
##  

SetPackageInfo( rec(

PackageName := "nq",
Subtitle := "Nilpotent Quotients of Finitely Presented Groups",
Version := "2.4dev",
Date    := "12/01/2012",
##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "2.4dev">
##  <!ENTITY RELEASEDATE "12 January 2012">
##  <#/GAPDoc>

Persons := [
  rec( LastName      := "Horn",
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

  rec( LastName      := "Nickel",
       FirstNames    := "Werner",
       IsAuthor      := true,
       IsMaintainer  := false,
       # MH: Werner rarely (if at all) replies to emails sent to this
       # old email address. To discourage users from sending bug reports
       # there, I have disabled it here.
       #Email         := "nickel@mathematik.tu-darmstadt.de",
       WWWHome       := "http://www.mathematik.tu-darmstadt.de/~nickel/",
     )

],

Status         := "accepted",
CommunicatedBy := "Joachim Neubüser (RWTH Aachen)",
AcceptDate     := "01/2003",

PackageWWWHome := "http://www.icm.tu-bs.de/ag_algebra/software/NQ/",

ArchiveFormats := ".tar.gz .tar.bz2",
ArchiveURL     := Concatenation( ~.PackageWWWHome, "nq-", ~.Version ),
README_URL     := Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),

AbstractHTML   := Concatenation( 
  "This package provides access to the ANU nilpotent quotient ",
  "program for computing nilpotent factor groups of finitely ",
  "presented groups."
  ),

                  
PackageDoc := rec(
  BookName  := "nq",
  ArchiveURLSubset := [ "doc" ],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Nilpotent Quotient Algorithm",
  Autoload  := false
),

Dependencies := rec(
  GAP                    := ">= 4.4",
  NeededOtherPackages    := [ ["polycyclic", "1.0"] ],
  SuggestedOtherPackages := [ ["GAPDoc", "1.3"] ],
  ExternalConditions     := [ "needs a UNIX system with C-compiler",
                              "needs GNU multiple precision library" ]
),

AvailabilityTest := function()
    local   path;
    
    # test for existence of the compiled binary
    path := DirectoriesPackagePrograms( "nq" );

    if Filename( path, "nq" ) = fail then
        Info( InfoWarning, 1,
              "Package ``nq'': The executable program is not available" );
        return fail;
    fi;
    return true;
end,

BannerString     := Concatenation(
  "Loading nq ", ~.Version, " (Nilpotent Quotient Algorithm)\n",
  "  by Werner Nickel\n",
  "  maintained by Max Horn (mhorn@tu-bs.de)\n"
  ),

Autoload := false,

TestFile := "gap/nq.tst",

Keywords := [
  "nilpotent quotient algorithm",
  "nilpotent presentations",
  "finitely presented groups",
  "finite presentations   ",
  "commutators",
  "lower central series",
  "identical relations",
  "expression trees",
  "nilpotent Engel groups",
  "right and left Engel elements",
  "computational"
  ]
));


