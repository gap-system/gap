#############################################################################
##  
##  PackageInfo.g for the package `Aclib'                      Bettina Eick
##  

SetPackageInfo( rec(

PackageName := "AClib",
Subtitle := "Almost Crystallographic Groups - A Library and Algorithms",
Version := "1.1",
Date := "01/10/2003",
ArchiveURL := "http://www-public.tu-bs.de:8080/~beick/soft/aclib/aclib-1.1", 
ArchiveFormats := ".tar.gz",

Persons := [
   rec(
      LastName      := "Dekimpe",
      FirstNames    := "Karel",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "dekimpe@kulak.ac.be",
      WWWHome       := "http://www.kulak.ac.be/~dekimpe",
      PostalAddress := Concatenation( [
                       "Katholieke Universiteit Leuven\n",
                       "Campus Kortrijk, Universitaire Campus\n",
                       "Kortrijk, B 8500\n Belgium"]),
      Place         := "Kortrijk",
      Institution   := "University of Kortrijk"),

  rec( 
      LastName      := "Eick",
      FirstNames    := "Bettina",
      IsAuthor      := true,
      IsMaintainer  := true,
      Email         := "b.eick@tu-bs.de",
      WWWHome       := "http://www-public.tu-bs.de:8080/~beick",
      PostalAddress := Concatenation( [
            "Institut Computational Mathematics\n",
            "TU Braunschweig\n",
            "Pockelsstr. 14\n D-38106 Braunschweig\n Germany" ] ),
      Place         := "Braunschweig",
      Institution   := "TU Braunschweig") ],

Status := "accepted",
CommunicatedBy := "Gerhard Hiss (Aachen)",
AcceptDate := "02/2001",

README_URL := "http://www-public.tu-bs.de:8080/~beick/soft/aclib/README",
PackageInfoURL := "http://www-public.tu-bs.de:8080/~beick/soft/aclib/PackageInfo.g",

AbstractHTML := 
"The <span class=\"pkgname\">AClib</span> package contains a library of almost crystallographic groups and a some algorithms to compute with these groups. A group is called almost crystallographic if it is finitely generated nilpotent-by-finite and has no non-trivial finite normal subgroups. Further, an almost crystallographic group is called almost Bieberbach if it is torsion-free. The almost crystallographic groups of Hirsch length 3 and a part of the almost cyrstallographic groups of Hirsch length 4 have been classified by Dekimpe. This classification includes all almost Bieberbach groups of Hirsch lengths 3 or 4. The AClib package gives access to this classification; that is, the package contains this library of groups in a computationally useful form. The groups in this library are available in two different representations. First, each of the groups of Hirsch length 3 or 4 has a rational matrix representation of dimension 4 or 5, respectively, and such representations are available in this package. Secondly, all the groups in this libraray are (infinite) polycyclic groups and the package also incorporates polycyclic presentations for them. The polycyclic presentations can be used to compute with the given groups using the methods of the Polycyclic package.",
 
PackageWWWHome := "http://www-public.tu-bs.de:8080/~beick/so.html",
               
PackageDoc := rec(
  BookName  := "AClib",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Almost Crystallographic Groups - A Library and Algorithms",
  Autoload  := true),

Dependencies := rec(
  GAP := ">=4.3",
  NeededOtherPackages := [["polycyclic","1.0"], ["crystcat","1.1"]],
  SuggestedOtherPackages := [],
  ExternalConditions := [] ),

AvailabilityTest := ReturnTrue,
BannerString := "Loading AClib 1.1 ... \n",
Autoload := true,
Keywords := ["almost crystallographic groups", "almost Bieberbach group",
             "virtually nilpotent group", "nilpotent-by-finite group", 
             "datalibrary of almost Bieberbach groups"]

));


