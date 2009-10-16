#############################################################################
##  
##  PackageInfo.g for the package `IPCQ'                         Bettina Eick
##  

SetPackageInfo( rec(

PackageName := "IPCQ",
Subtitle := "Computing infinite polycyclic quotients",
Version := "0.9",
Date := "16/12/2003",
ArchiveURL := "", 
ArchiveFormats := ".tar.gz",

Persons := [
  rec( 
      LastName      := "Eick",
      FirstNames    := "Bettina",
      IsAuthor      := true,
      IsMaintainer  := true,
      Email         := "b.eick@tu-bs.de",
      WWWHome       := "http://www.tu-bs.de/~beick",
      PostalAddress := Concatenation( [
            "Institut f\"ur Geometrie, Algebra und diskrete Mathematik\n",
            "TU Braunschweig\n",
            "Pockelsstr. 14\n D-38106 Braunschweig\n Germany" ] ),
      Place         := "Braunschweig",
      Institution   := "TU Braunschweig") ],

Status := "dev",
#CommunicatedBy := "",
#AcceptDate := "",

README_URL := "",
PackageInfoURL := "",
AbstractHTML := "",
PackageWWWHome := "",
               
PackageDoc := rec(
  BookName  := "IPCQ",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Computing infinite polycyclic quotients",
  Autoload  := false),

Dependencies := rec(
  GAP := ">=4.3",
  NeededOtherPackages := [["polycyclic", "1.0"], 
                          ["aclib", "1.0"],
                          ["vecenum", "0.9"]],
  SuggestedOtherPackages := [],
  ExternalConditions := [] ),

AvailabilityTest := ReturnTrue,
BannerString := "Loading IPCQ 0.9 ... \n",
Autoload := false,
Keywords := ["polycyclic quotients"]

));


